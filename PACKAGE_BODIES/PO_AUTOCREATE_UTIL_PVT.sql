--------------------------------------------------------
--  DDL for Package Body PO_AUTOCREATE_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_AUTOCREATE_UTIL_PVT" AS
/* $Header: POXVACUB.pls 120.0 2005/06/01 21:10:13 appldev noship $ */

G_PKG_NAME      CONSTANT VARCHAR2(30) := 'PO_AUTOCREATE_UTIL_PVT';
G_MODULE_PREFIX CONSTANT VARCHAR2(40) := 'po.plsql.' || g_pkg_name || '.';
g_debug_stmt    CONSTANT    BOOLEAN := PO_DEBUG.is_debug_stmt_on;

/**************** PRIVATE PROCEDURES ****************/

-----------------------------------------------------------------------
--Start of Comments
--Name: add_to_builder_reqs_gt
--Pre-reqs: None
--Modifies: PO_SESSION_GT
--Locks:
--  None
--Function:
--  Insert rows to PO_SESSION_GT. This is done to track builder reqs on
--  the server side
--Parameters:
--IN:
--p_key
--  key in PO_SESSION_GT
--p_req_list
--  table containing requisition_line_id
--IN OUT:
--OUT:
--Returns:
--Notes:
--Testing:
--End of Comments
-----------------------------------------------------------------------
PROCEDURE add_to_builder_reqs_gt
( p_key      IN NUMBER,
  p_req_list IN PO_TBL_NUMBER
) IS

BEGIN

  FORALL i IN 1..p_req_list.COUNT
    INSERT INTO PO_SESSION_GT
    ( key,
      index_num1
    )
    VALUES
    ( p_key,
      p_req_list(i)
    );
END add_to_builder_reqs_gt;



/**************** PUBLIC PROCEDURES ****************/

-----------------------------------------------------------------------
--Start of Comments
--Name: add_to_builder_reqs_gt
--Pre-reqs: None
--Modifies: PO_SESSION_GT
--Locks:
--  None
--Function:
--  Synchronize PO_SESSION_GT with builder reqs. This procedure
--  first cleans up the gt table and then insert into the table with the
--  rows passed in
--Parameters:
--IN:
--p_key
--  key in PO_SESSION_GT
--p_req_list
--  table containing requisition_line_id
--IN OUT:
--OUT:
--Returns:
--Notes:
--Testing:
--End of Comments
-----------------------------------------------------------------------
PROCEDURE synchronize_builder_reqs
( p_key      IN NUMBER,
  p_req_list IN PO_TBL_NUMBER
) IS

l_api_name          CONSTANT VARCHAR2(30) := 'synchronize_builder_reqs';
l_module            CONSTANT FND_LOG_MESSAGES.module%TYPE :=
                            G_MODULE_PREFIX || l_api_name || '.';
l_progress          VARCHAR2(3);

BEGIN

  l_progress := '000';

  IF (g_debug_stmt) THEN
      PO_DEBUG.debug_begin
      ( p_log_head   => l_module
      );

      PO_DEBUG.debug_var
      ( p_log_head => l_module,
        p_progress => l_progress,
        p_name     => 'p_key',
        p_value    => p_key
      );

      PO_DEBUG.debug_var
      ( p_log_head => l_module,
        p_progress => l_progress,
        p_name     => 'p_req_list.COUNT',
        p_value    => p_req_list.COUNT
      );
  END IF;

  clear_builder_reqs_gt
  ( p_key => p_key
  );

  add_to_builder_reqs_gt
  ( p_key => p_key,
    p_req_list => p_req_list
  );

  IF (g_debug_stmt) THEN
      PO_DEBUG.debug_end
      ( p_log_head   => l_module
      );
  END IF;
END synchronize_builder_reqs;


-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--Start of Comments
--Name: add_req_lines_gt
--Pre-reqs:
--  None
--Modifies:
--  po_session_gt
--Locks:
--  None
--Function:
--  Adds the input table of numbers to the PO_SESSION_GT table and returns
--  the GT key for which the values were added.
--Parameters:
--IN:
--p_req_line_id_tbl
--  PO_TBL_NUMBER of Requisition Line IDs to add to the GT table
--Returns:
--  NUMBER representing the key value for which the input values were added
--Notes:
--  None
--Testing:
--  None
--End of Comments
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
FUNCTION add_req_lines_gt
(
    p_req_line_id_tbl          IN          PO_TBL_NUMBER
)
RETURN NUMBER
IS
    l_key                      NUMBER;

BEGIN

    l_key := PO_CORE_S.get_session_gt_nextval;

    FORALL i IN 1..p_req_line_id_tbl.COUNT

        INSERT INTO po_session_gt
        (   key
        ,   index_num1
        ) VALUES
        (   l_key
        ,   p_req_line_id_tbl(i)
        );

    return (l_key);

END add_req_lines_gt;

-----------------------------------------------------------------------
--Start of Comments
--Name: clear_builder_reqs_gt
--Pre-reqs: None
--Modifies: PO_SESSION_GT
--Locks:
--  None
--Function:
--  Remove all builder reqs from PO_SESSION_GT table
--Parameters:
--IN:
--p_key
--  key in PO_SESSION_GT
--IN OUT:
--OUT:
--Returns:
--Notes:
--Testing:
--End of Comments
-----------------------------------------------------------------------
PROCEDURE clear_builder_reqs_gt
(
    p_key     IN    NUMBER
)
IS
BEGIN

  DELETE FROM PO_SESSION_GT
  WHERE key = p_key;

END clear_builder_reqs_gt;

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--Start of Comments
--Name: get_and_lock_req_lines_in_pool
--Pre-reqs:
--  None
--Modifies:
--  None
--Locks:
--  po_requisition_lines_all
--Function:
--  Retrieves and locks all Requisition Lines that are specified in the input
--  nested table and are in the Req Pool.
--Parameters:
--IN:
--p_req_line_id_tbl
--  PO_TBL_NUMBER of Requisition Line IDs to add to the GT table
--p_lock_records
--  'Y' or 'N' indicating whether to lock the records that are being retrieved
--OUT:
--x_req_line_id_in_pool_tbl
--  PO_TBL_NUMBER of Req Line IDs which exist in the input nested table
--  as well as the Req Pool
--x_records_locked
--  BOOLEAN indicating whether the records were successfully locked
--Notes:
--  None
--Testing:
--  None
--End of Comments
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
PROCEDURE get_and_lock_req_lines_in_pool
(
    p_req_line_id_tbl          IN          PO_TBL_NUMBER
,   p_lock_records             IN          VARCHAR2
,	x_req_line_id_in_pool_tbl  OUT NOCOPY  PO_TBL_NUMBER
,   x_records_locked           OUT NOCOPY  VARCHAR2
)
IS
    l_key                      NUMBER;

BEGIN

    x_records_locked := 'N';

    -- Initialize GT Table ----------------------------------------------------

    l_key := PO_AUTOCREATE_UTIL_PVT.add_req_lines_gt(p_req_line_id_tbl);


    -- Query and Lock ---------------------------------------------------------

    IF ( p_lock_records = 'Y' ) THEN

        SELECT pool.requisition_line_id
        BULK COLLECT INTO x_req_line_id_in_pool_tbl
        FROM   po_req_lines_in_pool_sec_v pool
        WHERE  pool.requisition_line_id IN ( SELECT selected.index_num1
                                             FROM   po_session_gt selected
                                             WHERE  selected.key = l_key
                                           )
        FOR UPDATE NOWAIT;

        x_records_locked := 'Y';

    -- Query Only -------------------------------------------------------------

    ELSE

        SELECT pool.requisition_line_id
        BULK COLLECT INTO x_req_line_id_in_pool_tbl
        FROM   po_req_lines_in_pool_sec_v pool
        WHERE  pool.requisition_line_id IN ( SELECT selected.index_num1
                                             FROM   po_session_gt selected
                                             WHERE  selected.key = l_key
                                           );

    END IF;

    -- Clean Up GT Table ------------------------------------------------------

    -- Delete Requisition Lines which we previously added to the GT table.

    clear_builder_reqs_gt(l_key);

EXCEPTION

    WHEN OTHERS THEN

        IF ( SQLCODE = -54 )                          -- unable to lock records
        THEN
            x_records_locked := 'N';
        ELSE
            raise;
        END IF;

END get_and_lock_req_lines_in_pool;


END PO_AUTOCREATE_UTIL_PVT;

/
