--------------------------------------------------------
--  DDL for Package Body PO_PRICE_DIFFERENTIALS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_PRICE_DIFFERENTIALS_PKG" AS
/* $Header: POXVPDTB.pls 120.1 2005/08/31 07:13:45 arudas noship $*/

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--Start of Comments
--Name: insert_row
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Table handler for INSERT of Price Differentials.
--Parameters:
--  None.
--Testing:
--  None.
--End of Comments
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
PROCEDURE insert_row
(   p_price_differential_rec      IN           PO_PRICE_DIFFERENTIALS%ROWTYPE
,   x_row_id                      OUT NOCOPY   ROWID
)
IS
BEGIN

    -- Insert record into PO_PRICE_DIFFERENTIALS base table
    --
    INSERT INTO po_price_differentials
    (   price_differential_id
    ,   price_differential_num
    ,   entity_type
    ,   entity_id
    ,   price_type
    ,   multiplier
    ,   min_multiplier
    ,   max_multiplier
    ,   enabled_flag
    ,   created_by
    ,   creation_date
    ,   last_updated_by
    ,   last_update_date
    ,   last_update_login
    )
    VALUES
    (   p_price_differential_rec.price_differential_id
    ,   p_price_differential_rec.price_differential_num
    ,   p_price_differential_rec.entity_type
    ,   p_price_differential_rec.entity_id
    ,   p_price_differential_rec.price_type
    ,   p_price_differential_rec.multiplier
    ,   p_price_differential_rec.min_multiplier
    ,   p_price_differential_rec.max_multiplier
    ,   p_price_differential_rec.enabled_flag
    ,   p_price_differential_rec.created_by
    ,   p_price_differential_rec.creation_date
    ,   p_price_differential_rec.last_updated_by
    ,   p_price_differential_rec.last_update_date
    ,   p_price_differential_rec.last_update_login
    )
    RETURNING   rowid
    INTO        x_row_id;

EXCEPTION

    WHEN OTHERS THEN
        PO_MESSAGE_S.sql_error('PO_PRICE_DIFFERENTIALS_PKG.insert_row','000',sqlcode);
        raise;

END insert_row;

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--Start of Comments
--Name: update_row
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Table handler for UPDATE of Price Differentials.
--Parameters:
--  None.
--Testing:
--  None.
--End of Comments
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
PROCEDURE update_row
(   p_price_differential_rec      IN        PO_PRICE_DIFFERENTIALS%ROWTYPE
,   p_row_id                      IN        ROWID
)
IS
BEGIN

    -- Update record in PO_PRICE_DIFFERENTIALS base table
    --
    UPDATE po_price_differentials
    SET    price_differential_num = p_price_differential_rec.price_differential_num
    ,      price_type = p_price_differential_rec.price_type
    ,      multiplier = p_price_differential_rec.multiplier
    ,      min_multiplier = p_price_differential_rec.min_multiplier
    ,      max_multiplier = p_price_differential_rec.max_multiplier
    ,      enabled_flag = p_price_differential_rec.enabled_flag
    ,      last_updated_by = p_price_differential_rec.last_updated_by
    ,      last_update_date = p_price_differential_rec.last_update_date
    ,      last_update_login = p_price_differential_rec.last_update_login
    WHERE  rowid = p_row_id;

EXCEPTION

    WHEN OTHERS THEN
        PO_MESSAGE_S.sql_error('PO_PRICE_DIFFERENTIALS_PKG.lock_row','000',sqlcode);
        raise;

END update_row;


-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--Start of Comments
--Name: lock_row
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Table handler for locking of Price Differentials.
--Parameters:
--  None.
--Testing:
--  None.
--End of Comments
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
PROCEDURE lock_row
(   p_form_rec              IN        PO_PRICE_DIFFERENTIALS%ROWTYPE
,   p_row_id                IN        ROWID
)
IS
    l_db_rec                PO_PRICE_DIFFERENTIALS%ROWTYPE;

    CURSOR price_diff_csr IS
        SELECT *
        FROM   po_price_differentials
        WHERE  rowid = p_row_id
        FOR UPDATE NOWAIT;

BEGIN

    OPEN price_diff_csr;

    -- Check if record is currently locked by someone else
    -- ( APP_EXCEPTION.RECORD_LOCK_EXCEPTION will be thrown if fetch fails )
    --
    FETCH price_diff_csr INTO l_db_rec;

    -- Check if record exists
    --
    IF ( price_diff_csr%NOTFOUND )
    THEN
        CLOSE price_diff_csr;
        FND_MESSAGE.set_name('FND','FORM_RECORD_DELETED');
        APP_EXCEPTION.raise_exception;
    END IF;

    -- Check if anybody has modified and committed the record from the time
    -- the data was queried up in the form until now
    --
    IF  (   ( l_db_rec.price_differential_num = p_form_rec.price_differential_num )
        AND ( l_db_rec.price_type = p_form_rec.price_type )
        AND (   ( l_db_rec.multiplier = p_form_rec.multiplier )
            OR  (   ( l_db_rec.multiplier IS NULL )
                AND ( p_form_rec.multiplier IS NULL ) ) )
        AND (   ( l_db_rec.min_multiplier = p_form_rec.min_multiplier )
            OR  (   ( l_db_rec.min_multiplier IS NULL )
                AND ( p_form_rec.min_multiplier IS NULL ) ) )
        AND (   ( l_db_rec.max_multiplier = p_form_rec.max_multiplier )
            OR  (   ( l_db_rec.max_multiplier IS NULL )
                AND ( p_form_rec.max_multiplier IS NULL ) ) )
        AND (   ( l_db_rec.enabled_flag = p_form_rec.enabled_flag )
            OR  (   ( l_db_rec.enabled_flag IS NULL )
                AND ( p_form_rec.enabled_flag IS NULL ) ) )
        )
    THEN

        return;             -- all values match (record is current)

    ELSE

        -- Data in the form is stale. Prompt user to requery data.
        --
        FND_MESSAGE.set_name('FND','FORM_RECORD_CHANGED');
        APP_EXCEPTION.raise_exception;

    END IF;

EXCEPTION

    WHEN OTHERS THEN
        PO_MESSAGE_S.sql_error('PO_PRICE_DIFFERENTIALS_PKG.lock_row','000',sqlcode);
        RAISE;

END lock_row;


-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--Start of Comments
--Name: delete_row
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Table handler for deletion of Price Differentials.
--Parameters:
--  None.
--Testing:
--  None.
--End of Comments
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
PROCEDURE delete_row
(
    p_row_id                IN        ROWID
)
IS
BEGIN

    DELETE FROM 	PO_PRICE_DIFFERENTIALS
    WHERE 			rowid = p_row_id;

EXCEPTION

    WHEN OTHERS THEN
        PO_MESSAGE_S.sql_error('PO_PRICE_DIFFERENTIALS_PKG.delete_row','000',sqlcode);
        RAISE;

END delete_row;

--<HTML Agreements R12 Start>
-------------------------------------------------------------------------------
--Start of Comments
--Name: del_level_specific_price_diff
--Pre-reqs:
-- None.
--Modifies:
-- PO_PRICE_DIFFERENTIALS.
--Locks:
-- None.
--Function:
-- Deletes all the price differentials for a given document level and document
-- level id combination.
--Parameters:
-- IN
-- p_doc_level
--  Document Level {LINE/SHIPMENT}
-- p_doc_level_id
--  Unique Identifier for the Document Line/Shipment
--Testing:
--  None.
--End of Comments
-------------------------------------------------------------------------------

PROCEDURE del_level_specific_price_diff( p_doc_level    IN VARCHAR2
                                        ,p_doc_level_id IN NUMBER)
IS
  l_entity_type PO_PRICE_DIFFERENTIALS.entity_type%type := NULL;

  d_module_name CONSTANT VARCHAR2(100) := 'DEL_LEVEL_SPECIFIC_PRICE_DIFF';
  d_module_base CONSTANT VARCHAR2(70) := 'po.plsql.PO_PRICE_DIFFERENTIALS_PKG.del_level_specific_price_diff';
  d_pos NUMBER := 0;
BEGIN
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module_base, 'p_doc_level', p_doc_level); PO_LOG.proc_begin(d_module_base, 'p_doc_level_id', p_doc_level_id);
  END IF;

  --Get Price differentials entity type for the given Line
  l_entity_type := PO_PRICE_DIFFERENTIALS_PVT.get_entity_type(
                            p_doc_level => p_doc_level
                           ,p_doc_level_id => p_doc_level_id);

  IF(PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module_base, d_pos, 'l_entity_type', l_entity_type);
  END IF;

  d_pos :=10;
  IF l_entity_type IS NULL THEN
    RAISE PO_CORE_S.g_early_return_exc ;
  END IF;

  d_pos :=20;
  PO_PRICE_DIFFERENTIALS_PVT.delete_price_differentials(
                            p_entity_type => l_entity_type
                            ,p_entity_id  => p_doc_level_id);

  d_pos :=30;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module_base,'No of rows deleted',SQL%ROWCOUNT);
    PO_LOG.proc_end(d_module_base);
  END IF;

EXCEPTION
  WHEN PO_CORE_S.g_early_return_exc THEN
    IF PO_LOG.d_stmt THEN
      PO_LOG.stmt(d_module_name,d_pos,'Early exit from ' || d_module_name);
    END IF;
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg(g_pkg_name, d_module_name|| ':'|| d_pos);
    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_module_base, d_pos, SQLCODE || SQLERRM);
    END IF;
    RAISE;
END del_level_specific_price_diff;
--<HTML Agreements R12 End>

END PO_PRICE_DIFFERENTIALS_PKG;

/
