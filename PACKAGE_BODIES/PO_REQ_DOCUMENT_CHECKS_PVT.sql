--------------------------------------------------------
--  DDL for Package Body PO_REQ_DOCUMENT_CHECKS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_REQ_DOCUMENT_CHECKS_PVT" AS
/* $Header: POXVRCKB.pls 120.1 2005/06/29 18:50:49 shsiung noship $*/

--CONSTANTS

G_PKG_NAME CONSTANT varchar2(30) := 'PO_REQ_DOCUMENT_CHECKS_PVT';

c_log_head    CONSTANT VARCHAR2(50) := 'po.plsql.'|| G_PKG_NAME || '.';

-- Read the profile option that enables/disables the debug log
g_fnd_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');


-------------------------------------------------------------------------------
--Start of Comments
--Name: check_updatable
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Helper to req_status_check to Find if a Requisition Header/Line is updatable based on status.
--  A Requisition Header is updatable if
--    it is not Pre Approved, not In Process, not canceled, not finally closed.
--  A Line is updatable if it is not canceled, not finally closed.
--Parameters:
--IN:
--p_count
--  Specifies the number of entities in table IN parameters like p_req_header_id
--  Other IN parameters are detailed in main procedure req_status_check
--OUT:
--x_return_status
--  Indicates API return status as 'S', 'E' or 'U'.
--x_req_status_rec
--  Table x_req_status_rec.updateable_flag will be 'Y' or 'N' for each input entity
--x_msg_count
--  The number of messages put into FND Message Stack by this API
--x_msg_data
--  First message put into FND Message Stack by this API
--Notes:
--  The implementation of updatable_flag involves a fake "update dual" statement to
--    optimize performance.
--End of Comments
-------------------------------------------------------------------------------

PROCEDURE check_updatable (
    p_count               IN NUMBER,
    p_req_header_id       IN PO_TBL_NUMBER,
    p_req_line_id         IN PO_TBL_NUMBER,
    p_req_distribution_id IN PO_TBL_NUMBER,
    p_lock_flag           IN VARCHAR2 := 'N',
    x_req_status_rec      IN OUT NOCOPY PO_STATUS_REC_TYPE,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2
) IS

l_api_name       CONSTANT VARCHAR(30) := 'CHECK_UPDATABLE';
l_progress       VARCHAR2(3) := '000';

l_procedure_id   PO_SESSION_GT.key%TYPE;  -- bug3606853

BEGIN

IF g_fnd_debug = 'Y' THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT, c_log_head || '.'||l_api_name||'.'
          || l_progress, 'Entering Procedure '||l_api_name);
    END IF;
END IF;

--To obtimize performance, Execute a fake "update dual" in BULK. The WHERE clause
-- of the fake update statement checks if the current entity is updatable or not.
-- One dual row updated <==> where clause is true <==> current entity is updatable.
-- Later, Examine BULK_ROWCOUNT in a loop to determine updatable_flag
l_progress := '010';

-- bug3606853 START
-- The original approach was to do a fake UPDATE on DUAL table. However, this
-- is causing locking issue (and priviledge). Therefore, BULK INSERT is used
-- instead of BULK UPDATE

l_procedure_id := PO_CORE_S.get_session_gt_nextval;

FORALL i IN 1..p_count
    -- SQL What: Checks if current PO Header/Line/Shipment is in updateable status
    INSERT INTO PO_SESSION_GT
    ( key
    )
    SELECT l_procedure_id
    FROM DUAL
    WHERE
      EXISTS (select null from po_requisition_headers h
        WHERE h.requisition_header_id = p_req_header_id(i)
        AND (h.authorization_status is NULL
             OR h.authorization_status NOT IN ('PRE-APPROVED', 'IN PROCESS'))
        AND (h.cancel_flag is null or h.cancel_flag <> 'Y')
        AND (h.closed_code is NULL or h.closed_code NOT IN ('FINALLY CLOSED')))
      AND (p_req_line_id(i) IS NULL
        OR EXISTS (SELECT null from po_requisition_lines l
        WHERE l.requisition_header_id = p_req_header_id(i)
        and l.requisition_line_id = p_req_line_id(i)
        AND (l.cancel_flag is null or l.cancel_flag <> 'Y')
        AND (l.closed_code is NULL or l.closed_code NOT IN ('FINALLY CLOSED'))
        AND nvl(l.modified_by_agent_flag, 'N') = 'N'))
    ;

-- bug3606853 END

-- Allocate memory for updatable_flag Table to p_count size
l_progress := '020';
x_req_status_rec.updatable_flag := po_tbl_varchar1();
x_req_status_rec.updatable_flag.extend(p_count);

-- Set Updatable_flag for each Entity using BULK_ROWCOUNT
l_progress := '030';
FOR i IN 1..p_count LOOP

    IF SQL%BULK_ROWCOUNT(i) > 0 THEN
        -- Updateable Header/Line found in the fake "update dual" stmt
        x_req_status_rec.updatable_flag(i) := 'Y';

        -- This document is updatable, lock the document if p_lock_flag=Y
        l_progress := '040';
        IF p_lock_flag = 'Y' THEN
            PO_REQ_DOCUMENT_LOCK_GRP.LOCK_requisition (
                p_api_version => 1.0,
                P_req_header_id => p_req_header_id(i),
                x_return_status => x_return_status);

           IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               return;
           END IF;
        END IF; --END of IF p_lock_flag = 'Y'
    ELSE
        x_req_status_rec.updatable_flag(i) := 'N';
    END IF; --END of IF SQL%BULK_ROWCOUNT(i) > 0

END LOOP;

-- bug3606853 START
-- Remove everthing that has been inserted into PO_SESSION_GT by the above
-- dummy insert

DELETE FROM po_session_gt
WHERE key = l_procedure_id;

-- bug3592160 END


x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
        FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_api_name || '.' || l_progress);
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END check_updatable;

-------------------------------------------------------------------------------
--Start of Comments
--Name: check_reservable
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Helper to req_status_check to Find if a Requisition Header/Line is reservable based on status.
--  A Requisition Header/Line is reservable if
--    Authorization Status not APPROVED, AND Closed Code is CLOSED or OPEN,
--Parameters:
--IN:
--p_count
--  Specifies the number of entities in table IN parameters like p_req_header_id
--  Other IN parameters are detailed in main procedure req_status_check
--OUT:
--x_return_status
--  Indicates API return status as 'S', 'E' or 'U'.
--x_req_status_rec
--  Table x_req_status_rec.updateable_flag will be 'Y' or 'N' for each input entity
--x_msg_count
--  The number of messages put into FND Message Stack by this API
--x_msg_data
--  First message put into FND Message Stack by this API
--Notes:
--  The implementation of reservable_flag involves a fake "update dual" statement to
--    optimize performance.
--End of Comments
-------------------------------------------------------------------------------

PROCEDURE check_reservable (
    p_count               IN NUMBER,
    p_req_header_id       IN PO_TBL_NUMBER,
    p_req_line_id         IN PO_TBL_NUMBER,
    p_req_distribution_id IN PO_TBL_NUMBER,
    p_lock_flag           IN VARCHAR2 := 'N',
    x_req_status_rec      IN OUT NOCOPY PO_STATUS_REC_TYPE,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2
) IS

l_api_name       CONSTANT VARCHAR(30) := 'CHECK_RESERVABLE';
l_progress       VARCHAR2(3) := '000';

l_procedure_id   PO_SESSION_GT.key%TYPE;  -- bug3606853
BEGIN

IF g_fnd_debug = 'Y' THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT, c_log_head || '.'||l_api_name||'.'
          || l_progress, 'Entering Procedure '||l_api_name);
    END IF;
END IF;

--To obtimize performance, Execute a fake "update dual" in BULK. The WHERE clause
-- of the fake update statement checks if the current entity is reservable or not.
-- One dual row updated <==> where clause is true <==> current entity is reservable.
-- Later, Examine BULK_ROWCOUNT in a loop to determine reservable_flag
l_progress := '010';

-- bug3606853 START
-- The original approach was to do a fake UPDATE on DUAL table. However, this
-- is causing locking issue (and priviledge). Therefore, BULK INSERT is used
-- instead of BULK UPDATE

l_procedure_id := PO_CORE_S.get_session_gt_nextval;

FORALL i IN 1..p_count
    -- SQL What: Checks if current PO Header/Line/Shipment is in reservable status
    INSERT INTO PO_SESSION_GT
    ( key
    )
    SELECT l_procedure_id
    FROM DUAL
    WHERE
      EXISTS (select null from po_requisition_headers h
        WHERE h.requisition_header_id = p_req_header_id(i)
        AND (h.authorization_status is NULL
             OR h.authorization_status NOT IN ('APPROVED'))
        AND (h.closed_code is NULL or h.closed_code IN ('OPEN', 'CLOSED')))
      AND (p_req_line_id(i) IS NULL
        OR EXISTS (SELECT null from po_requisition_lines l
        WHERE l.requisition_header_id = p_req_header_id(i)
        and l.requisition_line_id = p_req_line_id(i)
        AND (l.closed_code is NULL or l.closed_code IN ('OPEN', 'CLOSED'))))
    ;

-- Allocate memory for reservable_flag Table to p_count size
l_progress := '020';
x_req_status_rec.reservable_flag := po_tbl_varchar1();
x_req_status_rec.reservable_flag.extend(p_count);

-- Set reservable_flag for each Entity using BULK_ROWCOUNT
l_progress := '030';
FOR i IN 1..p_count LOOP

    IF SQL%BULK_ROWCOUNT(i) > 0 THEN
        -- Reservable Header/Line found in the fake "update dual" stmt
        x_req_status_rec.reservable_flag(i) := 'Y';
    ELSE
        x_req_status_rec.reservable_flag(i) := 'N';
    END IF; --END of IF SQL%BULK_ROWCOUNT(i) > 0

END LOOP;

-- bug3606853 START
-- Remove everthing that has been inserted into PO_SESSION_GT by the above
-- dummy insert

DELETE FROM po_session_gt
WHERE key = l_procedure_id;

-- bug3592160 END

x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
        FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_api_name || '.' || l_progress);
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END check_reservable;

-------------------------------------------------------------------------------
--Start of Comments
--Name: check_unreservable
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Helper to req_status_check to Find if a Requisition Header/Line is unreservable based on status.
--  A Requisition Header/Line is unreservable if
--    Any Authorization Status, AND Closed Code is CLOSED or OPEN,
--Parameters:
--IN:
--p_count
--  Specifies the number of entities in table IN parameters like p_req_header_id
--  Other IN parameters are detailed in main procedure req_status_check
--OUT:
--x_return_status
--  Indicates API return status as 'S', 'E' or 'U'.
--x_req_status_rec
--  Table x_req_status_rec.updateable_flag will be 'Y' or 'N' for each input entity
--x_msg_count
--  The number of messages put into FND Message Stack by this API
--x_msg_data
--  First message put into FND Message Stack by this API
--Notes:
--  The implementation of unreservable_flag involves a fake "update dual" statement to
--    optimize performance.
--End of Comments
-------------------------------------------------------------------------------

PROCEDURE check_unreservable (
    p_count               IN NUMBER,
    p_req_header_id       IN PO_TBL_NUMBER,
    p_req_line_id         IN PO_TBL_NUMBER,
    p_req_distribution_id IN PO_TBL_NUMBER,
    p_lock_flag           IN VARCHAR2 := 'N',
    x_req_status_rec      IN OUT NOCOPY PO_STATUS_REC_TYPE,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2
) IS

l_api_name       CONSTANT VARCHAR(30) := 'CHECK_UNRESERVABLE';
l_progress       VARCHAR2(3) := '000';

l_procedure_id   PO_SESSION_GT.key%TYPE;  -- bug3606853

BEGIN

IF g_fnd_debug = 'Y' THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT, c_log_head || '.'||l_api_name||'.'
          || l_progress, 'Entering Procedure '||l_api_name);
    END IF;
END IF;

--To obtimize performance, Execute a fake "update dual" in BULK. The WHERE clause
-- of the fake update statement checks if the current entity is unreservable or not.
-- One dual row updated <==> where clause is true <==> current entity is unreservable.
-- Later, Examine BULK_ROWCOUNT in a loop to determine unreservable_flag
l_progress := '010';

-- bug3606853 START
-- The original approach was to do a fake UPDATE on DUAL table. However, this
-- is causing locking issue (and priviledge). Therefore, BULK INSERT is used
-- instead of BULK UPDATE

l_procedure_id := PO_CORE_S.get_session_gt_nextval;

FORALL i IN 1..p_count
    -- SQL What: Checks if current PO Header/Line/Shipment is in unreservable status
    INSERT INTO PO_SESSION_GT
    ( key
    )
    SELECT l_procedure_id
    FROM DUAL
    WHERE
      EXISTS (select null from po_requisition_headers h
        WHERE h.requisition_header_id = p_req_header_id(i)
        AND (h.closed_code is NULL or h.closed_code IN ('OPEN', 'CLOSED')))
      AND (p_req_line_id(i) IS NULL
        OR EXISTS (SELECT null from po_requisition_lines l
        WHERE l.requisition_header_id = p_req_header_id(i)
        AND l.requisition_line_id = p_req_line_id(i)
        AND (l.closed_code is NULL or l.closed_code IN ('OPEN', 'CLOSED'))))
    ;

-- Allocate memory for unreservable_flag Table to p_count size
l_progress := '020';
x_req_status_rec.unreservable_flag := po_tbl_varchar1();
x_req_status_rec.unreservable_flag.extend(p_count);

-- Set unreservable_flag for each Entity using BULK_ROWCOUNT
l_progress := '030';
FOR i IN 1..p_count LOOP

    IF SQL%BULK_ROWCOUNT(i) > 0 THEN
        -- unreservable Header/Line found in the fake "update dual" stmt
        x_req_status_rec.unreservable_flag(i) := 'Y';
    ELSE
        x_req_status_rec.unreservable_flag(i) := 'N';
    END IF; --END of IF SQL%BULK_ROWCOUNT(i) > 0

END LOOP;

-- bug3606853 START
-- Remove everthing that has been inserted into PO_SESSION_GT by the above
-- dummy insert

DELETE FROM po_session_gt
WHERE key = l_procedure_id;

-- bug3592160 END

x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
        FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_api_name || '.' || l_progress);
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END check_unreservable;

-------------------------------------------------------------------------------
--Start of Comments
--Name: get_status
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Helper to req_status_check to find status of a Purchase Order/Release/Line/Shipment
--  The following status fields of PO Header or Release are put into
--     the OUT parameter x_req_status_rec
--   AUTHORIZATION_STATUS, APPROVED_FLAG, CLOSED_CODE, CANCEL_FLAG, FROZEN_FLAG, HOLD_FLAG
--  When an optional Line specified, following Line level values are overwritten
--   CLOSED_CODE, CANCEL_FLAG, HOLD_FLAG
--  When an optional Shipment specified, following Shipment level values are overwritten
--   APPROVED_FLAG, CLOSED_CODE, CANCEL_FLAG
--Parameters:
--IN:
--p_count
--  Specifies the number of entities in table IN parameters like p_header_id, p_release_id
--    All the table IN parameters are assumed to be of the same size
--  Other IN parameters are detailed in main procedure req_status_check
--OUT:
--x_return_status
--  Indicates API return status as 'S', 'E' or 'U'.
--x_req_status_rec
--  The various status fields would have the PO/Rel Line/Shipment status values
--x_msg_count
--  The number of messages put into FND Message Stack by this API
--x_msg_data
--  First message put into FND Message Stack by this API
--End of Comments
-------------------------------------------------------------------------------

PROCEDURE get_status (
    p_count               IN NUMBER,
    p_req_header_id       IN PO_TBL_NUMBER,
    p_req_line_id         IN PO_TBL_NUMBER,
    p_req_distribution_id IN PO_TBL_NUMBER,
    x_req_status_rec      IN OUT NOCOPY PO_STATUS_REC_TYPE,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2
) IS

l_api_name    CONSTANT VARCHAR(30) := 'GET_STATUS';
l_progress    VARCHAR2(3) := '000';
l_sequence    PO_TBL_NUMBER := PO_TBL_NUMBER();

BEGIN

IF g_fnd_debug = 'Y' THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT, c_log_head || '.'||l_api_name||'.'
          || l_progress, 'Entering Procedure '||l_api_name);
    END IF;
END IF;

--Use sequence(i) to simulate i inside FORALL as direct reference to i not allowed
--Initialize sequence array to contain 1,2,3, ..., p_count
l_progress := '010';
l_sequence.extend(p_count);
FOR i IN 1..p_count LOOP
  l_sequence(i) := i;
END LOOP;

l_progress := '020';

delete from po_headers_gt;

-- For all the entities , get Requisition Header status fields into
-- global temprary table while storing sequence into po_headers_gt.PO_HEADER_ID column
l_progress := '030';
FORALL i IN 1..p_count
    INSERT
      INTO po_headers_gt
      ( AGENT_ID, TYPE_LOOKUP_CODE, LAST_UPDATE_DATE, LAST_UPDATED_BY,
        SEGMENT1, SUMMARY_FLAG, ENABLED_FLAG,
        authorization_status, closed_code,
        cancel_flag, PO_HEADER_ID)
    SELECT
      -1, TYPE_LOOKUP_CODE, LAST_UPDATE_DATE, LAST_UPDATED_BY,
      SEGMENT1, SUMMARY_FLAG, ENABLED_FLAG,
      NVL(authorization_status, 'INCOMPLETE'),  nvl(closed_code, 'OPEN'),
      NVL(cancel_flag, 'N'), l_sequence(i)
      FROM po_requisition_headers h
      WHERE h.requisition_header_id = p_req_header_id(i)
    ;


--IF line ID present at an index, overwrite the status fields with Line Level status
l_progress := '040';
FORALL i IN 1..p_count
    UPDATE po_headers_gt gt
      SET (closed_code, cancel_flag)
      =
      (SELECT nvl(closed_code, 'OPEN'), NVL(cancel_flag, 'N')
      FROM po_requisition_lines s
      WHERE s.requisition_line_id = p_req_line_id(i))
    WHERE p_req_line_id(i) is not null and gt.po_header_id = l_sequence(i)
    ;

-- Fetch status fields from global temporary table into pl/sql table.
-- Order by sequence (stored in PO_HEADER_ID column) ensures
--   that input tables like p_header_id are in sync with
--   output status field tables like x_req_status_rec.authorization_status
l_progress := '060';
SELECT
  authorization_status, closed_code,
  cancel_flag
BULK COLLECT INTO
  x_req_status_rec.authorization_status, x_req_status_rec.closed_code,
  x_req_status_rec.cancel_flag
FROM po_headers_gt
ORDER BY PO_HEADER_ID;

x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
        FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_api_name || '.' || l_progress);
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END get_status;

-------------------------------------------------------------------------------
--Start of Comments
--Name: req_status_check
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Finds the status of a Requisition Header/Line. Refer to p_mode parameter
--  and PO_STATUS_REC_TYPE for various status information this procedure can find out.
--  A unique header has to be specified in p_req_header_id.
--  A line can optionally be specified to check status at that level also.
--Parameters:
--IN:
--p_api_version
--  Specifies API version.
--p_req_header_id
--  Specifies Requisition Header ID. This is a required field.
--p_req_line_id := NULL
--  Optionally Specifies Requisition Line ID to check status at line level
--p_req_distribution_id := NULL
--  This is not used currently, may be used in the future.
--p_mode
--  Indicates what status to check.
--    Can contain one or more of the following requests to check status
--      CHECK_UPDATEABLE to check if the current Req Header/Line is updatable
--      GET_STATUS to return various statuses of the current Req Header/Line
--OUT:
--x_return_status
--  Indicates API return status as 'S', 'E' or 'U'.
--x_req_status_rec
--  Contains the returned status elements
--  If p_mode contains CHECK_UPDATEABLE,
--    the updateable_flag would have 'Y' or 'N' for each entity in the Table
--  If p_mode contains GET_APPROVAL_STATUS,
--    various status fields for Header/Line like authorization_status, cancel_flag
--x_msg_count
--  The number of messages put into FND Message Stack by this API
--x_msg_data
--  First message put into FND Message Stack by this API
--Testing:
--  All the input table parameters should have the exact same length.
--  Call the API when 1. only Requisition Header Exist, and 2. Line also exists
--End of Comments
-------------------------------------------------------------------------------

PROCEDURE req_status_check (
    p_api_version         IN NUMBER,
    p_req_header_id       IN PO_TBL_NUMBER,
    p_req_line_id         IN PO_TBL_NUMBER,
    p_req_distribution_id IN PO_TBL_NUMBER,
    p_mode                IN VARCHAR2,
    p_lock_flag           IN VARCHAR2 := 'N',
    x_req_status_rec      OUT NOCOPY PO_STATUS_REC_TYPE,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2
) IS

l_api_name    CONSTANT VARCHAR(30) := 'req_status_check';
l_api_version CONSTANT NUMBER := 1.0;
l_progress    VARCHAR2(3) := '000';
l_count       NUMBER;

BEGIN

IF g_fnd_debug = 'Y' THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT, c_log_head || '.'||l_api_name||'.'
          || l_progress, 'Entering Procedure '||l_api_name);
    END IF;
END IF;

-- Standard call to check for call compatibility
l_progress := '010';
IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

l_progress := '020'; -- Initialize Local/Output Variables
l_count := p_req_header_id.count;
x_req_status_rec := PO_STATUS_REC_TYPE(null, null, null, null, null, null, null, null, null);

l_progress := '030';

IF INSTR(p_mode, G_CHECK_UPDATEABLE) > 0 THEN

    check_updatable (
        p_count => l_count,
        p_req_header_id => p_req_header_id,
        p_req_line_id => p_req_line_id,
        p_req_distribution_id => p_req_distribution_id,
        p_lock_flag => p_lock_flag,
        x_req_status_rec => x_req_status_rec,
        x_return_status  => x_return_status,
        x_msg_count  => x_msg_count,
        x_msg_data  => x_msg_data);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        return;
    END IF;

END IF; --END of IF INSTR(p_mode, G_CHECK_UPDATEABLE) > 0

l_progress := '033';

IF INSTR(p_mode, G_CHECK_RESERVABLE) > 0 THEN

    check_reservable (
        p_count => l_count,
        p_req_header_id => p_req_header_id,
        p_req_line_id => p_req_line_id,
        p_req_distribution_id => p_req_distribution_id,
        p_lock_flag => p_lock_flag,
        x_req_status_rec => x_req_status_rec,
        x_return_status  => x_return_status,
        x_msg_count  => x_msg_count,
        x_msg_data  => x_msg_data);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        return;
    END IF;

END IF; --END of IF INSTR(p_mode, G_CHECK_RESERVABLE) > 0

l_progress := '036';

IF INSTR(p_mode, G_CHECK_UNRESERVABLE) > 0 THEN

    check_unreservable (
        p_count => l_count,
        p_req_header_id => p_req_header_id,
        p_req_line_id => p_req_line_id,
        p_req_distribution_id => p_req_distribution_id,
        p_lock_flag => p_lock_flag,
        x_req_status_rec => x_req_status_rec,
        x_return_status  => x_return_status,
        x_msg_count  => x_msg_count,
        x_msg_data  => x_msg_data);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        return;
    END IF;

END IF; --END of IF INSTR(p_mode, G_CHECK_UNRESERVABLE) > 0

l_progress := '040';

IF INSTR(p_mode, G_GET_STATUS) > 0 THEN

    get_status (
        p_count => l_count,
        p_req_header_id => p_req_header_id,
        p_req_line_id => p_req_line_id,
        p_req_distribution_id => p_req_distribution_id,
        x_req_status_rec => x_req_status_rec,
        x_return_status  => x_return_status,
        x_msg_count  => x_msg_count,
        x_msg_data  => x_msg_data);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        return;
    END IF;

END IF; --}END of IF INSTR(p_mode, G_GET_STATUS) > 0

l_progress := '050';

IF x_return_status is null THEN -- no valid check status request specified
    FND_MESSAGE.set_name('PO', 'PO_STATCHK_GENERAL_ERROR');
    FND_MESSAGE.set_token('ERROR_TEXT', 'Invalid p_mode: ' || p_mode);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
        FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_api_name || '.' || l_progress);
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END req_status_check;


END PO_REQ_DOCUMENT_CHECKS_PVT;

/
