--------------------------------------------------------
--  DDL for Package Body PO_LOCKS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_LOCKS" AS
-- $Header: POXLOCKB.pls 120.0.12010000.3 2011/05/27 10:14:32 lswamina ship $



-----------------------------------------------------------------------------
-- Declare private package variables.
-----------------------------------------------------------------------------

-- Debugging

g_pkg_name                       CONSTANT
   VARCHAR2(30)
   := 'PO_LOCKS'
   ;
g_log_head                       CONSTANT
   VARCHAR2(50)
   := 'po.plsql.' || g_pkg_name || '.'
   ;

g_debug_stmt
   BOOLEAN
   ;
g_debug_unexp
   BOOLEAN
   ;




-----------------------------------------------------------------------------
-- Define procedures.
-----------------------------------------------------------------------------




-------------------------------------------------------------------------------
--Start of Comments
--Name: lock_headers
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  PO_HEADERS_ALL
--  PO_RELEASES_ALL
--  PO_REQUISITION_HEADERS_ALL
--Function:
--  Locks the document headers of the given ids.
--Parameters:
--IN:
--p_doc_type
--  Document type.  Use the g_doc_type_<> variables, where <> is:
--    REQUISITION
--    PA
--    PO
--    RELEASE
--p_doc_level
--  The type of ids that are being passed.  Use g_doc_level_<>
--    HEADER
--    LINE
--    SHIPMENT
--    DISTRIBUTION
--p_doc_level_id_tbl
--  Ids of the doc level type of which to lock the header of the document.
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE lock_headers(
   p_doc_type                       IN             VARCHAR2
,  p_doc_level                      IN             VARCHAR2
,  p_doc_level_id_tbl               IN             po_tbl_number
,  p_calling_mode                   IN             VARCHAR2       DEFAULT   NULL
)
IS

l_log_head     CONSTANT VARCHAR2(100) := g_log_head||'LOCK_HEADERS';
l_progress     VARCHAR2(3) := '000';

l_doc_id_tbl      po_tbl_number;
l_doc_id_key      NUMBER;

----------------------------------------------------------------
-- PO_SESSION_GT column mapping
--
-- num1     doc id
----------------------------------------------------------------

CURSOR l_lock_req_csr(p_doc_id_key NUMBER) IS
SELECT NULL
FROM
   PO_REQUISITION_HEADERS_ALL PRH
,  PO_SESSION_GT IDS
WHERE PRH.requisition_header_id = IDS.num1
AND IDS.key = p_doc_id_key
FOR UPDATE OF PRH.requisition_header_id
NOWAIT
;

CURSOR l_lock_release_csr(p_doc_id_key NUMBER) IS
SELECT NULL
FROM
   PO_RELEASES_ALL POR
,  PO_SESSION_GT IDS
WHERE POR.po_release_id = IDS.num1
AND IDS.key = p_doc_id_key
FOR UPDATE OF POR.po_release_id
NOWAIT
;

CURSOR l_lock_po_csr(p_doc_id_key NUMBER) IS
SELECT NULL
FROM
   PO_HEADERS_ALL POH
,  PO_SESSION_GT IDS
WHERE POH.po_header_id = IDS.num1
AND IDS.key = p_doc_id_key
FOR UPDATE OF POH.po_header_id
NOWAIT
;

/*Bug8512125 - Defined a new set of cursors to lock records when the calling mode is RCV
  This will wait indefinitely till it aquires lock*/

CURSOR l_rcv_lock_req_csr(p_doc_id_key NUMBER) IS
SELECT NULL
FROM
   PO_REQUISITION_HEADERS_ALL PRH
,  PO_SESSION_GT IDS
WHERE PRH.requisition_header_id = IDS.num1
AND IDS.key = p_doc_id_key
FOR UPDATE
;

CURSOR l_rcv_lock_release_csr(p_doc_id_key NUMBER) IS
SELECT NULL
FROM
   PO_RELEASES_ALL POR
,  PO_SESSION_GT IDS
WHERE POR.po_release_id = IDS.num1
AND IDS.key = p_doc_id_key
FOR UPDATE
;

CURSOR l_rcv_lock_po_csr(p_doc_id_key NUMBER) IS
SELECT NULL
FROM
   PO_HEADERS_ALL POH
,  PO_SESSION_GT IDS
WHERE POH.po_header_id = IDS.num1
AND IDS.key = p_doc_id_key
FOR UPDATE
;


BEGIN

IF g_debug_stmt THEN
   PO_DEBUG.debug_begin(l_log_head);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_type', p_doc_type);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_level', p_doc_level);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_level_id_tbl', p_doc_level_id_tbl);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_calling_mode', p_calling_mode);
END IF;

l_progress := '010';

-- Get the header ids for the given doc level ids.

PO_CORE_S.get_document_ids(
   p_doc_type => p_doc_type
,  p_doc_level => p_doc_level
,  p_doc_level_id_tbl => p_doc_level_id_tbl
,  x_doc_id_tbl => l_doc_id_tbl
);

l_progress := '020';

-- Put the header ids into the scratchpad so that the cursors work.

SELECT PO_SESSION_GT_S.nextval
INTO l_doc_id_key
FROM DUAL
;

l_progress := '030';

FORALL i IN 1 .. l_doc_id_tbl.COUNT
INSERT INTO PO_SESSION_GT ( key, num1 )
VALUES ( l_doc_id_key, l_doc_id_tbl(i) )
;

l_progress := '040';

-- Cursors lock the rows on OPEN, and we don't need to SELECT anything.
/*Bug8512125 If the calling mode is RCV we run a new set of cursors defined*/

IF (p_calling_mode = 'RCV') THEN

IF (p_doc_type = PO_CORE_S.g_doc_type_REQUISITION) THEN

   l_progress := '050';
   IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress,'requisition');
   END IF;

   OPEN l_rcv_lock_req_csr(p_doc_id_key => l_doc_id_key);
   CLOSE l_rcv_lock_req_csr;

   l_progress := '060';

ELSIF (p_doc_type = PO_CORE_S.g_doc_type_RELEASE) THEN

   l_progress := '070';
   IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress,'release');
   END IF;

   OPEN l_rcv_lock_release_csr(p_doc_id_key => l_doc_id_key);
   CLOSE l_rcv_lock_release_csr;

   l_progress := '080';

ELSIF (p_doc_type IN (PO_CORE_S.g_doc_type_PO, PO_CORE_S.g_doc_type_PA)) THEN

   l_progress := '090';
   IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress,'po, pa');
   END IF;

   OPEN l_rcv_lock_po_csr(p_doc_id_key => l_doc_id_key);
   CLOSE l_rcv_lock_po_csr;

   l_progress := '100';

ELSE

   l_progress := '190';

   RAISE PO_CORE_S.g_INVALID_CALL_EXC;

END IF;

ELSE /* If calling mode is not RCV*/

IF (p_doc_type = PO_CORE_S.g_doc_type_REQUISITION) THEN

   l_progress := '200';
   IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress,'requisition');
   END IF;

   OPEN l_lock_req_csr(p_doc_id_key => l_doc_id_key);
   CLOSE l_lock_req_csr;

   l_progress := '210';

ELSIF (p_doc_type = PO_CORE_S.g_doc_type_RELEASE) THEN

   l_progress := '220';
   IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress,'release');
   END IF;

   OPEN l_lock_release_csr(p_doc_id_key => l_doc_id_key);
   CLOSE l_lock_release_csr;

   l_progress := '230';

ELSIF (p_doc_type IN (PO_CORE_S.g_doc_type_PO, PO_CORE_S.g_doc_type_PA)) THEN

   l_progress := '240';
   IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress,'po, pa');
   END IF;

   OPEN l_lock_po_csr(p_doc_id_key => l_doc_id_key);
   CLOSE l_lock_po_csr;

   l_progress := '250';

ELSE

   l_progress := '300';

   RAISE PO_CORE_S.g_INVALID_CALL_EXC;

END IF;

END IF;


l_progress := '900';

IF g_debug_stmt THEN
   PO_DEBUG.debug_end(l_log_head);
END IF;

EXCEPTION
WHEN OTHERS THEN
   IF g_debug_unexp THEN
      PO_DEBUG.debug_exc(l_log_head,l_progress);
   END IF;
   RAISE;

END lock_headers;




-------------------------------------------------------------------------------
--Start of Comments
--Name: lock_distributions
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  PO_DISTRIBUTIONS_ALL
--  PO_REQ_DISTRIBUTIONS_ALL
--Function:
--  Locks the distributions below the given ids.
--Parameters:
--IN:
--p_doc_type
--  Document type.  Use the g_doc_type_<> variables, where <> is:
--    REQUISITION
--    PA
--    PO
--    RELEASE
--p_doc_level
--  The type of ids that are being passed.  Use g_doc_level_<>
--    HEADER
--    LINE
--    SHIPMENT
--    DISTRIBUTION
--p_doc_level_id_tbl
--  Ids of the doc level type of which to lock the header of the document.
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE lock_distributions(
   p_doc_type                       IN             VARCHAR2
,  p_doc_level                      IN             VARCHAR2
,  p_doc_level_id_tbl               IN             po_tbl_number
)
IS

l_log_head     CONSTANT VARCHAR2(100) := g_log_head||'LOCK_DISTRIBUTIONS';
l_progress     VARCHAR2(3) := '000';

l_dist_id_tbl      po_tbl_number;
l_dist_id_key      NUMBER;

----------------------------------------------------------------
-- PO_SESSION_GT column mapping
--
-- num1     distribution id
----------------------------------------------------------------

CURSOR l_lock_req_csr(p_dist_id_key NUMBER) IS
SELECT NULL
FROM
   PO_REQ_DISTRIBUTIONS_ALL PRD
,  PO_SESSION_GT DIST_IDS
WHERE PRD.distribution_id = DIST_IDS.num1
AND DIST_IDS.key = p_dist_id_key
FOR UPDATE OF PRD.distribution_id
NOWAIT
;

CURSOR l_lock_nonreq_csr(p_dist_id_key NUMBER) IS
SELECT NULL
FROM
   PO_DISTRIBUTIONS_ALL POD
,  PO_SESSION_GT DIST_IDS
WHERE POD.po_distribution_id = DIST_IDS.num1
AND DIST_IDS.key = p_dist_id_key
FOR UPDATE OF POD.po_distribution_id
NOWAIT
;

BEGIN

IF g_debug_stmt THEN
   PO_DEBUG.debug_begin(l_log_head);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_type', p_doc_type);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_level', p_doc_level);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_level_id_tbl', p_doc_level_id_tbl);
END IF;

l_progress := '010';

-- Get the distribution ids for the given doc level ids.

PO_CORE_S.get_distribution_ids(
   p_doc_type => p_doc_type
,  p_doc_level => p_doc_level
,  p_doc_level_id_tbl => p_doc_level_id_tbl
,  x_distribution_id_tbl => l_dist_id_tbl
);

l_progress := '015';

-- Put the distribution ids in the scratchpad, so that the
-- cursors will work (PL/SQL locking limitations).

SELECT PO_SESSION_GT_S.nextval
INTO l_dist_id_key
FROM DUAL
;

l_progress := '020';

FORALL i IN 1 .. l_dist_id_tbl.COUNT
INSERT INTO PO_SESSION_GT ( key, num1 )
VALUES ( l_dist_id_key, l_dist_id_tbl(i) )
;

l_progress := '030';

-- Cursors lock the rows on OPEN, and we don't need to SELECT into anything.

IF (p_doc_type = PO_CORE_S.g_doc_type_REQUISITION) THEN

   l_progress := '040';
   IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress,'requisition');
   END IF;

   OPEN l_lock_req_csr(p_dist_id_key => l_dist_id_key);
   CLOSE l_lock_req_csr;

   l_progress := '050';

ELSIF (p_doc_type IN (  PO_CORE_S.g_doc_type_PO
                     ,  PO_CORE_S.g_doc_type_PA
                     ,  PO_CORE_S.g_doc_type_RELEASE ))
THEN

   l_progress := '060';
   IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress,'not requisition');
   END IF;

   OPEN l_lock_nonreq_csr(p_dist_id_key => l_dist_id_key);
   CLOSE l_lock_nonreq_csr;

   l_progress := '070';

ELSE

   l_progress := '090';

   RAISE PO_CORE_S.g_INVALID_CALL_EXC;

END IF;

l_progress := '900';

IF g_debug_stmt THEN
   PO_DEBUG.debug_end(l_log_head);
END IF;

EXCEPTION
WHEN OTHERS THEN
   IF g_debug_unexp THEN
      PO_DEBUG.debug_exc(l_log_head,l_progress);
   END IF;
   RAISE;

END lock_distributions;


-------------------------------------------------------------------------------
--Start of Comments
--Name: lock_sourcing_rules
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  MRP_SOURCING_RULES
--Function:
--  Locks the sourcing rules for a given sourcing_rule_id.
--Parameters:
--IN:
--p_sourcing_rule_id
--Sourcing rule id
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE lock_sourcing_rules(
   p_sourcing_rule_id               IN             NUMBER
)
IS

l_log_head     CONSTANT VARCHAR2(100) := g_log_head||'LOCK_SOURCING_RULES';
l_progress     VARCHAR2(3) := '000';

CURSOR l_lock_sourcing_rule_csr(p_sourcing_rule_id NUMBER) IS
SELECT *
FROM MRP_SOURCING_RULES
FOR UPDATE OF sourcing_rule_id
NOWAIT
;

BEGIN

IF g_debug_stmt THEN
   PO_DEBUG.debug_begin(l_log_head);
   PO_DEBUG.debug_var(l_log_head,l_progress,'c', p_sourcing_rule_id);
END IF;

l_progress := '010';


   OPEN l_lock_sourcing_rule_csr(p_sourcing_rule_id => p_sourcing_rule_id);
   CLOSE l_lock_sourcing_rule_csr;

l_progress := '020';


IF g_debug_stmt THEN
   PO_DEBUG.debug_end(l_log_head);
END IF;

EXCEPTION
WHEN OTHERS THEN
   IF g_debug_unexp THEN
      PO_DEBUG.debug_exc(l_log_head,l_progress);
   END IF;
   RAISE;

END lock_sourcing_rules;



-----------------------------------------------------------------------------
-- Initialize package variables.
-----------------------------------------------------------------------------

BEGIN

g_debug_stmt := PO_DEBUG.is_debug_stmt_on;
g_debug_unexp := PO_DEBUG.is_debug_unexp_on;


END PO_LOCKS;

/
