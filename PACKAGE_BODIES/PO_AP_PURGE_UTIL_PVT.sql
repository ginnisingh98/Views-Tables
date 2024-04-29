--------------------------------------------------------
--  DDL for Package Body PO_AP_PURGE_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_AP_PURGE_UTIL_PVT" AS
/* $Header: POXVPUUB.pls 120.3 2006/01/31 09:50:50 dedelgad noship $ */


-- <DOC PURGE FPJ START>

G_PKG_NAME      CONSTANT VARCHAR2(30) := 'PO_AP_PURGE_UTIL_PVT';
g_fnd_debug     VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
G_MODULE_PREFIX CONSTANT VARCHAR2(40) := 'po.plsql.' || g_pkg_name || '.';

g_batch_limit   CONSTANT NUMBER := 10000;

--*********************************************************************
----------------- Private Procedure Prototypes-------------------------
--*********************************************************************

PROCEDURE filter_req_pon_validation
( x_return_status   OUT NOCOPY  VARCHAR2
);

PROCEDURE filter_po_fte_validation
( x_return_status   OUT NOCOPY  VARCHAR2
);

PROCEDURE filter_po_cst_validation
( x_return_status   OUT NOCOPY VARCHAR2
);

PROCEDURE filter_po_oe_validation
( x_return_status   OUT NOCOPY VARCHAR2
);

PROCEDURE filter_po_pon_validation
( x_return_status   OUT NOCOPY VARCHAR2
);

PROCEDURE filter_po_hr_validation
( x_return_status   OUT NOCOPY VARCHAR2
);

PROCEDURE delete_asl_ref
( x_return_status   OUT NOCOPY  VARCHAR2,
  p_range_low       IN          NUMBER,
  p_range_high      IN          NUMBER
);

PROCEDURE delete_org_assignments
( x_return_status   OUT NOCOPY  VARCHAR2,
  p_range_low       IN          NUMBER,
  p_range_high      IN          NUMBER
);

PROCEDURE delete_drop_ship_po_links
( x_return_status   OUT NOCOPY  VARCHAR2,
  p_range_low       IN          NUMBER,
  p_range_high      IN          NUMBER
);

PROCEDURE delete_fte
( x_return_status   OUT NOCOPY  VARCHAR2,
  p_range_low       IN          NUMBER,
  p_range_high      IN          NUMBER
);

PROCEDURE delete_pon
( x_return_status   OUT NOCOPY  VARCHAR2,
  p_purge_entity    IN          VARCHAR2,
  p_range_low       IN          NUMBER,
  p_range_high      IN          NUMBER
);

PROCEDURE delete_contract_terms
( x_return_status   OUT NOCOPY  VARCHAR2,
  p_range_low       IN          NUMBER,
  p_range_high      IN          NUMBER
);


PROCEDURE delete_price_differentials
( x_return_status   OUT NOCOPY  VARCHAR2,
  p_purge_entity    IN          VARCHAR2,
  p_range_low       IN          NUMBER,
  p_range_high      IN          NUMBER
);

PROCEDURE delete_attr_values
( x_return_status   OUT NOCOPY  VARCHAR2,
  p_range_low       IN          NUMBER,
  p_range_high      IN          NUMBER
);

-- bug3231186
PROCEDURE delete_po_approval_list
( x_return_status   OUT NOCOPY  VARCHAR2,
  p_purge_entity    IN          VARCHAR2,
  p_range_low       IN          NUMBER,
  p_range_high      IN          NUMBER
);

PROCEDURE delete_req_attachments
( x_return_status   OUT NOCOPY  VARCHAR2,
  p_range_low       IN          NUMBER,
  p_range_high      IN          NUMBER
);

PROCEDURE delete_po_attachments
( x_return_status   OUT NOCOPY  VARCHAR2,
  p_range_low       IN          NUMBER,
  p_range_high      IN          NUMBER
);

PROCEDURE delete_po_drafts
( x_return_status   OUT NOCOPY  VARCHAR2,
  p_range_low       IN          NUMBER,
  p_range_high      IN          NUMBER
);

--*********************************************************************
-------------------------- Public Procedures --------------------------
--*********************************************************************


-----------------------------------------------------------------------
--Start of Comments
--Name: seed_po
--Pre-reqs:
--Modifies: po_purge_po_list, po_purge_req_list
--Locks:
--  None
--Function: Construct po purge list for eligible pos that have not been
--          updated since last_activity_date. This is a version from
--          11i FPJ and beyond. it will also populate req purgelist
--Parameters:
--IN:
--p_purge_category
--  Indicate types of records user wants to purge
--p_purge_name
--  name of the purge process
--p_last_activity_date
--  Date which determines whether an already eligible PO should be inserted
--  to purge list or not. POs that have not been updated since this date
--  will not get purged.
--IN OUT:
--OUT:
--x_return_status
--  status of the procedure
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------

--<ACTION FOR 11iX START>
--Initiated by: BAO
--Plan is to move the logic in this procedure PO_AP_PURGE_PVT.seed_po to 11iX

PROCEDURE seed_po
( x_return_status       OUT NOCOPY  VARCHAR2,
  p_purge_category      IN          VARCHAR2,
  p_purge_name          IN          VARCHAR2,
  p_last_activity_date  IN          DATE
) IS

l_api_name      CONSTANT VARCHAR2(50) := 'seed_po';
l_progress      VARCHAR2(3);
l_module        CONSTANT FND_LOG_MESSAGES.module%TYPE :=
                    G_MODULE_PREFIX || l_api_name || '.';

BEGIN

    l_progress := '000';

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_PROCEDURE,
          module    => l_module || l_progress,
          message   => 'Entering ' || g_pkg_name || '.' || l_api_name
        );
        END IF;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_purge_category = PO_AP_PURGE_GRP.G_PUR_CAT_SIMPLE_PO) THEN

        l_progress := '010';

        -- The subquery on po_distributions is to make sure that no invoice
        -- has matched to this PO yet

        --SQL What: Generate a list of POs that are eligibible for purge
        --SQL Why:  This is the initial list of pos to be purged. There will
        --          be additional rules getting applied to this table to
        --          remove records that are actually not eligible for purge

        INSERT INTO po_purge_po_list
        (   po_header_id,
            purge_name,
            double_check_flag
        )
        SELECT  PH.po_header_id,
                p_purge_name,
                'Y'
        FROM    po_headers PH
        WHERE   PH.type_lookup_code IN ('STANDARD', 'PLANNED',
                                        'BLANKET',  'CONTRACT')
        AND     PH.last_update_date <= p_last_activity_date
        AND     (PH.closed_code = 'FINALLY CLOSED'
                 OR PH.cancel_flag = 'Y')
        AND     NOT EXISTS
                    (SELECT NULL
                     FROM   po_releases PR
                     WHERE  PR.po_header_id = PH.po_header_id
                     AND    PR.last_update_date > p_last_activity_date)
        AND     NOT EXISTS
                    (SELECT NULL
                     FROM   po_lines PL
                     WHERE  PL.po_header_id = PH.po_header_id
                     AND    (
                            PL.last_update_date > p_last_activity_date
                            OR
                            EXISTS (
                                SELECT  NULL
                                FROM    po_price_differentials PPD
                                WHERE   PPD.entity_type IN ('PO LINE',
                                                            'BLANKET LINE')
                                AND     PPD.entity_id = PL.po_line_id
                                AND     PPD.last_update_date >
                                        p_last_activity_date)))
        AND     NOT EXISTS
                    (SELECT NULL
                     FROM   po_line_locations PLL
                     WHERE  PLL.po_header_id = PH.po_header_id
                     AND    (
                            PLL.last_update_date > p_last_activity_date
                            OR
                            EXISTS (
                                SELECT  NULL
                                FROM    po_price_differentials PPD
                                WHERE   PPD.entity_type = 'PRICE BREAK'
                                AND     PPD.entity_id = PLL.line_location_id
                                AND     PPD.last_update_date >
                                        p_last_activity_date)))
        AND     NOT EXISTS
                    (SELECT NULL
                     FROM   po_distributions PD
                     WHERE  PD.po_header_id = PH.po_header_id
                     AND    (PD.last_update_date > p_last_activity_date
                             OR
                             EXISTS
                                (SELECT NULL
                                 FROM   ap_invoice_distributions AD
                                 WHERE  AD.po_distribution_id =
                                        PD.po_distribution_id)))
        AND     NOT EXISTS
                    (SELECT NULL
                     FROM   rcv_transactions RT
                     WHERE  RT.po_header_id = PH.po_header_id
                     AND    RT.last_update_date > p_last_activity_date);

        IF (g_fnd_debug = 'Y') THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string
            ( log_level => FND_LOG.LEVEL_STATEMENT,
              module    => l_module || l_progress,
              message   => 'Done Seeded PO for ' || p_purge_category
            );
            END IF;
        END IF;

    ELSIF (p_purge_category = PO_AP_PURGE_GRP.G_PUR_CAT_MATCHED_PO_INV) THEN

        l_progress := '020';

        -- POs that have invoices are still candidates for purging when
        -- purge category = 'MATCHED POS AND INVOICES'

        --SQL What: Generate a list of POs that are eligibible for purge
        --SQL Why:  This is the initial list of pos to be purged. There will
        --          be additional rules getting applied to this table to
        --          remove records that are actually not eligible for purge

        INSERT INTO po_purge_po_list
        (   po_header_id,
            purge_name,
            double_check_flag
        )
        SELECT  PH.po_header_id,
                p_purge_name,
                'Y'
        FROM    po_headers PH
        WHERE   PH.type_lookup_code IN ('STANDARD', 'PLANNED',
                                        'BLANKET',  'CONTRACT')
        AND     PH.last_update_date <= p_last_activity_date
        AND     (PH.closed_code = 'FINALLY CLOSED'
                 OR PH.cancel_flag = 'Y')
        AND     NOT EXISTS
                    (SELECT NULL
                     FROM   po_releases PR
                     WHERE  PR.po_header_id = PH.po_header_id
                     AND    PR.last_update_date > p_last_activity_date)
        AND     NOT EXISTS
                    (SELECT NULL
                     FROM   po_lines PL
                     WHERE  PL.po_header_id = PH.po_header_id
                     AND    (
                            PL.last_update_date > p_last_activity_date
                            OR
                            EXISTS (
                                SELECT  NULL
                                FROM    po_price_differentials PPD
                                WHERE   PPD.entity_type IN ('PO LINE',
                                                            'BLANKET LINE')
                                AND     PPD.entity_id = PL.po_line_id
                                AND     PPD.last_update_date >
                                        p_last_activity_date)))
        AND     NOT EXISTS
                    (SELECT NULL
                     FROM   po_line_locations PLL
                     WHERE  PLL.po_header_id = PH.po_header_id
                     AND    (
                            PLL.last_update_date > p_last_activity_date
                            OR
                            EXISTS (
                                SELECT  NULL
                                FROM    po_price_differentials PPD
                                WHERE   PPD.entity_type = 'PRICE BREAK'
                                AND     PPD.entity_id = PLL.line_location_id
                                AND     PPD.last_update_date >
                                        p_last_activity_date)))
        AND     NOT EXISTS
                    (SELECT NULL
                     FROM   po_distributions PD
                     WHERE  PD.po_header_id = PH.po_header_id
                     AND    PD.last_update_date > p_last_activity_date)
        AND     NOT EXISTS
                    (SELECT NULL
                     FROM   rcv_transactions RT
                     WHERE  RT.po_header_id = PH.po_header_id
                     AND    RT.last_update_date > p_last_activity_date);

        IF (g_fnd_debug = 'Y') THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string
            ( log_level => FND_LOG.LEVEL_STATEMENT,
              module    => l_module || l_progress,
              message   => 'Done seed po for ' || p_purge_category
            );
            END IF;
        END IF;

    END IF; -- p_purge_category = ...

    l_progress := '030';

    -- We will put the req in the purge list even if it has turned into
    -- a PO.

    -- SQL What: Generate a list of requisitions that are eligible for purging
    --           This query is specific for customers at FP level that is
    --           11i FPJ or above
    -- SQL Why:  This is the initial list of reqs to be purged. Later on the
    --           records in this list will be removed if the records are no
    --           longer eligible for purging after additional rules are applied

    INSERT INTO po_purge_req_list
    (   requisition_header_id,
        purge_name,
        double_check_flag
    )
    SELECT  PRH.requisition_header_id,
            p_purge_name,
            'Y'
    FROM    po_requisition_headers PRH
    WHERE   PRH.last_update_date <= p_last_activity_date
    AND     (PRH.closed_code = 'FINALLY CLOSED'
             OR PRH.authorization_status = 'CANCELLED')
    AND     NOT EXISTS
                (SELECT NULL
                 FROM   po_requisition_lines PRL
                 WHERE  PRL.requisition_header_id = PRH.requisition_header_id
                 AND    NVL(PRL.modified_by_agent_flag, 'N') = 'N'
                 AND    (PRL.last_update_date > p_last_activity_date
                         OR
                         PRL.source_type_code = 'INVENTORY'
                         OR
                         EXISTS (
                            SELECT  NULL
                            FROM    po_price_differentials PPD
                            WHERE   PPD.entity_type = 'REQ LINE'
                            AND     PPD.entity_id = PRL.requisition_line_id
                            AND     PPD.last_update_date >
                                    p_last_activity_date)
                         OR
                         EXISTS (
                            SELECT  NULL
                            FROM    po_req_distributions PRD
                            WHERE   PRD.requisition_line_id =
                                    PRL.requisition_line_id
                            AND     PRD.last_update_date >
                                    p_last_activity_date)));


    l_progress := '040';

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_PROCEDURE,
          module    => l_module || l_progress,
          message   => 'Quitting ' || g_pkg_name || '.' || l_api_name
        );
        END IF;
    END IF;

EXCEPTION
WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    FND_MSG_PUB.add_exc_msg
    ( p_pkg_name        => g_pkg_name,
      p_procedure_name  => l_api_name || '.' || l_progress
    );

END seed_po;

--<ACTION FOR 11iX END>

-----------------------------------------------------------------------
--Start of Comments
--Name: filter_more_referenced_req
--Pre-reqs:
--Modifies: po_purge_req_list
--Locks:
--  None
--Function: Exclude REQs that are referenced by records that will not get
--          purged.
--Parameters:
--IN:
--IN OUT:
--OUT:
--x_return_status
--  status of the procedure
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------

PROCEDURE filter_more_referenced_req
( x_return_status       OUT NOCOPY VARCHAR2
) IS

l_api_name      VARCHAR2(50) := 'filter_more_referenced_po';
l_progress      VARCHAR2(3);
l_return_status VARCHAR2(1);
l_module        CONSTANT FND_LOG_MESSAGES.module%TYPE :=
                    G_MODULE_PREFIX || l_api_name || '.';

BEGIN

    l_progress := '000';

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_PROCEDURE,
          module    => l_module || l_progress,
          message   => 'Entering ' || g_pkg_name || '.' || l_api_name
        );
        END IF;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_progress := '010';

    filter_req_pon_validation
    ( x_return_status => l_return_status
    );

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_PROCEDURE,
          module    => l_module || l_progress,
          message   => 'Quitting ' || g_pkg_name || '.' || l_api_name
        );
        END IF;
    END IF;

EXCEPTION
WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.add_exc_msg
    ( p_pkg_name        => g_pkg_name,
      p_procedure_name  => l_api_name || '.' || l_progress
    );

END filter_more_referenced_req;


-----------------------------------------------------------------------
--Start of Comments
--Name: filter_more_referenced_po
--Pre-reqs:
--Modifies: po_purge_po_list
--Locks:
--  None
--Function: Exclude POs that are referenced by records that will not get
--          purged.
--Parameters:
--IN:
--IN OUT:
--OUT:
--x_return_status
--  status of the procedure
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------

PROCEDURE filter_more_referenced_po
( x_return_status       OUT NOCOPY VARCHAR2
) IS

l_api_name      VARCHAR2(50) := 'filter_more_referenced_po';
l_progress      VARCHAR2(3);
l_return_status VARCHAR2(1);
l_module        CONSTANT FND_LOG_MESSAGES.module%TYPE :=
                    G_MODULE_PREFIX || l_api_name || '.';

BEGIN

    l_progress := '000';

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_PROCEDURE,
          module    => l_module || l_progress,
          message   => 'Entering ' || g_pkg_name || '.' || l_api_name
        );
        END IF;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    filter_po_fte_validation
    ( x_return_status   => l_return_status
    );

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    l_progress := '010';

    filter_po_cst_validation
    ( x_return_status   => l_return_status
    );

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    l_progress := '020';

    filter_po_oe_validation
    ( x_return_status   => l_return_status
    );

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    l_progress := '030';

    filter_po_pon_validation
    ( x_return_status   => l_return_status
    );

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- bug3365311
    -- removed filter_po_gms_validation as the check is unnecessary

    l_progress := '050';

    filter_po_hr_validation
    ( x_return_status   => l_return_status
    );

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_PROCEDURE,
          module    => l_module || l_progress,
          message   => 'Quitting ' || g_pkg_name || '.' || l_api_name
        );
        END IF;
    END IF;

EXCEPTION
WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.add_exc_msg
    ( p_pkg_name        => g_pkg_name,
      p_procedure_name  => l_api_name || '.' || l_progress
    );

END filter_more_referenced_po;


-----------------------------------------------------------------------
--Start of Comments
--Name: delete_req_related_records
--Pre-reqs:
--Modifies:
--Locks:
--  None
--Function: Call various procedures to delete additional records when
--          a requisition is purged
--Parameters:
--IN:
--p_range_low
--  lower bound of the req to be purged
--p_range_high
--  upper bound of the req to be purged
--IN OUT:
--OUT:
--x_return_status
--  status of the procedure
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------

PROCEDURE delete_req_related_records
( x_return_status       OUT NOCOPY  VARCHAR2,
  p_range_low           IN          NUMBER,
  p_range_high          IN          NUMBER
) IS

l_api_name      VARCHAR2(50) := 'delete_req_related_records';
l_progress      VARCHAR2(3);
l_return_status VARCHAR2(1);
l_module        CONSTANT FND_LOG_MESSAGES.module%TYPE :=
                    G_MODULE_PREFIX || l_api_name || '.';

BEGIN

    l_progress := '000';

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_PROCEDURE,
          module    => l_module || l_progress,
          message   => 'Entering ' || g_pkg_name || '.' || l_api_name
        );
        END IF;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_progress := '010';

    delete_price_differentials
    ( x_return_status   => l_return_status,
      p_purge_entity    => 'REQ',
      p_range_low       => p_range_low,
      p_range_high      => p_range_high
    );

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    l_progress := '020';

    delete_pon
    ( x_return_status   => l_return_status,
      p_purge_entity    => 'REQ',
      p_range_low       => p_range_low,
      p_range_high      => p_range_high
    );

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    l_progress := '030';

    --bug3231186
    delete_po_approval_list
    ( x_return_status   => l_return_status,
      p_purge_entity    => 'REQ',
      p_range_low       => p_range_low,
      p_range_high      => p_range_high
    );

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    l_progress := '040';

    delete_req_attachments
    ( x_return_status   => l_return_status,
      p_range_low       => p_range_low,
      p_range_high      => p_range_high
    );

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_PROCEDURE,
          module    => l_module || l_progress,
          message   => 'Quitting ' || g_pkg_name || '.' || l_api_name
        );
        END IF;
    END IF;

EXCEPTION
WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.add_exc_msg
    ( p_pkg_name        => g_pkg_name,
      p_procedure_name  => l_api_name || '.' || l_progress
    );

END delete_req_related_records;


-----------------------------------------------------------------------
--Start of Comments
--Name: delete_po_related_records
--Pre-reqs:
--Modifies:
--Locks:
--  None
--Function: Call various procedures to delete additional records when
--          a po is purged
--Parameters:
--IN:
--p_range_low
--  lower bound of the po to be purged
--p_range_high
--  upper bound of the po to be purged
--IN OUT:
--OUT:
--x_return_status
--  status of the procedure
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------

PROCEDURE delete_po_related_records
( x_return_status       OUT NOCOPY  VARCHAR2,
  p_range_low           IN          NUMBER,
  p_range_high          IN          NUMBER
) IS

l_api_name      VARCHAR2(50) := 'delete_po_related_records';
l_progress      VARCHAR2(3);
l_return_status VARCHAR2(1);
l_module        CONSTANT FND_LOG_MESSAGES.module%TYPE :=
                    G_MODULE_PREFIX || l_api_name || '.';

BEGIN

    l_progress := '000';

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_PROCEDURE,
          module    => l_module || l_progress,
          message   => 'Entering ' || g_pkg_name || '.' || l_api_name
        );
        END IF;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_progress := '010';

    delete_asl_ref
    ( x_return_status   => l_return_status,
      p_range_low       => p_range_low,
      p_range_high      => p_range_high
    );

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    l_progress := '020';

    delete_org_assignments
    ( x_return_status   => l_return_status,
      p_range_low       => p_range_low,
      p_range_high      => p_range_high
    );

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    l_progress := '030';

    delete_drop_ship_po_links
    ( x_return_status   => l_return_status,
      p_range_low       => p_range_low,
      p_range_high      => p_range_high
    );

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    l_progress := '040';

    delete_fte
    ( x_return_status   => l_return_status,
      p_range_low       => p_range_low,
      p_range_high      => p_range_high
    );

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    l_progress := '050';

    delete_pon
    ( x_return_status   => l_return_status,
      p_purge_entity    => 'PO',
      p_range_low       => p_range_low,
      p_range_high      => p_range_high
    );

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    l_progress := '060';

    delete_contract_terms
    ( x_return_status   => l_return_status,
      p_range_low       => p_range_low,
      p_range_high      => p_range_high
    );

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- bug3365311
    -- deleted the procedure delete_gms as the call is unnecessary

    l_progress := '080';

    l_progress := '090';

    delete_price_differentials
    ( x_return_status   => l_return_status,
      p_purge_entity    => 'PO',
      p_range_low       => p_range_low,
      p_range_high      => p_range_high
    );

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- <HTML Agreement R12 START>
    l_progress := '100';

    delete_attr_values
    ( x_return_status   => l_return_status,
      p_range_low       => p_range_low,
      p_range_high      => p_range_high
    );

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- <HTML Agreement R12 END>

    l_progress := '110';

    delete_po_attachments
    ( x_return_status   => l_return_status,
      p_range_low       => p_range_low,
      p_range_high      => p_range_high
    );

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    l_progress := '120';

    -- <HTML Agreement R12 START>
    -- Delete Draft documents when we purge pos
    delete_po_drafts
    ( x_return_status   => l_return_status,
      p_range_low       => p_range_low,
      p_range_high      => p_range_high
    );

    -- <HTML Agreement R12 END>

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_PROCEDURE,
          module    => l_module || l_progress,
          message   => 'Quitting ' || g_pkg_name || '.' || l_api_name
        );
        END IF;
    END IF;

EXCEPTION
WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.add_exc_msg
    ( p_pkg_name        => g_pkg_name,
      p_procedure_name  => l_api_name || '.' || l_progress
    );

END delete_po_related_records;


--*********************************************************************
-------------------------- Private Procedures -------------------------
--*********************************************************************

-----------------------------------------------------------------------
--Start of Comments
--Name: filter_req_pon_validation
--Pre-reqs:
--Modifies: po_purge_po_list
--Locks:
--  None
--Function: Call Sourcing API to determine whether the records in the
--          purge list violates the rules defined in PON if the records are
--          purged.
--          If so, exclude those records from the purge list
--Parameters:
--IN:
--IN OUT:
--OUT:
--x_return_status
--  status of the procedure
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------

PROCEDURE filter_req_pon_validation
( x_return_status   OUT NOCOPY VARCHAR2
) IS

l_api_name      VARCHAR2(50) := 'filter_req_pon_validation';
l_progress      VARCHAR2(3);
l_module        CONSTANT FND_LOG_MESSAGES.module%TYPE :=
                    G_MODULE_PREFIX || l_api_name || '.';

l_in_rec        PON_PO_INTEGRATION_GRP.PURGE_IN_RECTYPE;
l_out_rec       PON_PO_INTEGRATION_GRP.PURGE_OUT_RECTYPE;

l_return_status VARCHAR2(1);
l_msg_count     NUMBER;
l_msg_data      VARCHAR2(2000);

CURSOR  c_po_list IS
SELECT  requisition_header_id
FROM    po_purge_req_list
WHERE   double_check_flag = 'Y';

BEGIN

    l_progress := '000';

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_PROCEDURE,
          module    => l_module || l_progress,
          message   => 'Entering ' || g_pkg_name || '.' || l_api_name
        );
        END IF;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_in_rec.entity_name := 'PO_REQUISITION_HEADERS';

    OPEN c_po_list;

    LOOP
        l_progress := '010';

        FETCH c_po_list
        BULK COLLECT INTO l_in_rec.entity_ids
        LIMIT g_batch_limit;

        EXIT WHEN l_in_rec.entity_ids.COUNT = 0;

        l_progress := '020';

        PON_PO_INTEGRATION_GRP.validate_po_purge
        ( p_api_version         => 1.0,
          p_init_msg_list       => FND_API.G_TRUE,
          p_commit              => FND_API.G_FALSE,
          x_return_status       => l_return_status,
          x_msg_count           => l_msg_count,
          x_msg_data            => l_msg_data,
          p_in_rec              => l_in_rec,
          x_out_rec             => l_out_rec
        );

        IF (g_fnd_debug = 'Y') THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string
            ( log_level => FND_LOG.LEVEL_STATEMENT,
              module    => l_module || l_progress,
              message   => 'After calling pon val api. rtn status = ' ||
                           l_return_status
            );
            END IF;
        END IF;

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        l_progress := '030';

        FORALL i IN 1..l_out_rec.purge_allowed.COUNT
            UPDATE  po_purge_req_list PPRL
            SET     PPRL.double_check_flag = 'N'
            WHERE   PPRL.requisition_header_id = l_in_rec.entity_ids(i)
            AND     l_out_rec.purge_allowed(i) <> 'Y';

    END LOOP;

    l_progress := '040';

    CLOSE c_po_list;

    log_purge_list_count
    ( p_module => l_module || l_progress,
      p_entity => 'REQ'
    );

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_PROCEDURE,
          module    => l_module || l_progress,
          message   => 'Quitting ' || g_pkg_name || '.' || l_api_name
        );
        END IF;
    END IF;

EXCEPTION
WHEN OTHERS THEN
    IF (c_po_list%ISOPEN) THEN
        CLOSE c_po_list;
    END IF;

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.add_exc_msg
    ( p_pkg_name        => g_pkg_name,
      p_procedure_name  => l_api_name || '.' || l_progress
    );

END filter_req_pon_validation;

-----------------------------------------------------------------------
--Start of Comments
--Name: filter_po_fte_validation
--Pre-reqs:
--Modifies: po_purge_po_list
--Locks:
--  None
--Function: Call FTE API to determine whether the record in the purge list
--          violates the rules defined in FTE if the record is purged.
--          If so, exclude the record from the purge list
--Parameters:
--IN:
--IN OUT:
--OUT:
--x_return_status
--  status of the procedure
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------

PROCEDURE filter_po_fte_validation
( x_return_status   OUT NOCOPY  VARCHAR2
) IS

l_api_name      VARCHAR2(50) := 'filter_po_fte_validation';
l_progress      VARCHAR2(3);
l_module        CONSTANT FND_LOG_MESSAGES.module%TYPE :=
                    G_MODULE_PREFIX || l_api_name || '.';

CURSOR  c_po_list IS
SELECT  po_header_id
FROM    po_purge_po_list
WHERE   double_check_flag = 'Y';

l_in_rec    WSH_PO_INTG_TYPES_GRP.purge_in_rectype;
l_out_rec   WSH_PO_INTG_TYPES_GRP.purge_out_rectype;
l_return_status VARCHAR2(1);
l_msg_count     NUMBER;
l_msg_data      VARCHAR2(2000);

BEGIN
    l_progress := '000';

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_PROCEDURE,
          module    => l_module || l_progress,
          message   => 'Entering ' || g_pkg_name || '.' || l_api_name
        );
        END IF;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Do not call FTE API if FTE is not installed or their code level
    -- is lower than that of 11.5.10

    IF (PO_CORE_S.get_product_install_status('FTE') <> 'I'
        OR
        WSH_CODE_CONTROL.Get_Code_Release_Level < '110510') THEN

        IF (g_fnd_debug = 'Y') THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string
            ( log_level => FND_LOG.LEVEL_STATEMENT,
              module    => l_module || l_progress,
              message   => 'Either FTE is not installed or WSH code level ' ||
                           'is not at 11.5.10 level or above. Quitting'
            );
            END IF;
        END IF;

        RETURN;
    END IF; -- if FTP notinstalled or WSH code < 110510

    l_in_rec.caller := 'PO_DOC_PURGE';

    OPEN c_po_list;

    LOOP
        l_progress := '010';

        FETCH c_po_list
        BULK COLLECT INTO l_in_rec.header_ids
        LIMIT g_batch_limit;

        EXIT WHEN l_in_rec.header_ids.COUNT = 0;

        l_progress := '020';

        WSH_PO_INTEGRATION_GRP.Check_Purge
        ( p_api_version_number  => 1.0,
          p_init_msg_list       => FND_API.G_TRUE,
          p_commit              => FND_API.G_FALSE,
          x_return_status       => l_return_status,
          x_msg_count           => l_msg_count,
          x_msg_data            => l_msg_data,
          p_in_rec              => l_in_rec,
          x_out_rec             => l_out_rec
        );

        IF (g_fnd_debug = 'Y') THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string
            ( log_level => FND_LOG.LEVEL_STATEMENT,
              module    => l_module || l_progress,
              message   => 'After calling FTE Validation API. rtn status= ' ||
                           l_return_status
            );
            END IF;
        END IF;

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        l_progress := '030';

        FORALL i IN 1..l_out_rec.purge_allowed.COUNT
            UPDATE  po_purge_po_list PPL
            SET     PPL.double_check_flag = 'N'
            WHERE   PPL.po_header_id = l_in_rec.header_ids(i)
            AND     l_out_rec.purge_allowed(i) <> 'Y';

    END LOOP;

    l_progress := '040';

    CLOSE c_po_list;

    log_purge_list_count
    ( p_module => l_module || l_progress,
      p_entity => 'PO'
    );

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_PROCEDURE,
          module    => l_module || l_progress,
          message   => 'Quitting ' || g_pkg_name || '.' || l_api_name
        );
        END IF;
    END IF;

EXCEPTION
WHEN OTHERS THEN
    IF (c_po_list%ISOPEN) THEN
        CLOSE c_po_list;
    END IF;

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.add_exc_msg
    ( p_pkg_name        => g_pkg_name,
      p_procedure_name  => l_api_name || '.' || l_progress
    );

END filter_po_fte_validation;


-----------------------------------------------------------------------
--Start of Comments
--Name: filter_po_cst_validation
--Pre-reqs:
--Modifies: po_purge_po_list
--Locks:
--  None
--Function: Call Costing API to determine whether the records in the purge list
--          violates the rules defined in CST if the records are purged.
--          If so, exclude those records from the purge list
--Parameters:
--IN:
--IN OUT:
--OUT:
--x_return_status
--  status of the procedure
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------

PROCEDURE filter_po_cst_validation
( x_return_status   OUT NOCOPY  VARCHAR2
) IS

l_api_name      VARCHAR2(50) := 'filter_po_cst_validation';
l_progress      VARCHAR2(3);
l_module        CONSTANT FND_LOG_MESSAGES.module%TYPE :=
                    G_MODULE_PREFIX || l_api_name || '.';

CURSOR  c_po_list IS
SELECT  po_header_id
FROM    po_purge_po_list
WHERE   double_check_flag = 'Y';


l_in_rec      RCV_AccrualUtilities_GRP.purge_in_rectype;
l_out_rec     RCV_AccrualUtilities_GRP.purge_out_rectype;

l_return_status VARCHAR2(1);
l_msg_count     NUMBER;
l_msg_data      VARCHAR2(2000);

BEGIN

    l_progress := '000';

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_PROCEDURE,
          module    => l_module || l_progress,
          message   => 'Entering ' || g_pkg_name || '.' || l_api_name
        );
        END IF;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    OPEN c_po_list;

    LOOP
        l_progress := '010';

        FETCH c_po_list
        BULK COLLECT INTO l_in_rec.entity_ids
        LIMIT g_batch_limit;

        EXIT WHEN l_in_rec.entity_ids.COUNT = 0;

        l_progress := '020';

        RCV_AccrualUtilities_GRP.Validate_PO_Purge
        ( p_api_version         => 1.0,
          p_init_msg_list       => FND_API.G_TRUE,
          p_commit              => FND_API.G_FALSE,
          x_return_status       => l_return_status,
          x_msg_count           => l_msg_count,
          x_msg_data            => l_msg_data,
          p_purge_entity_type   => 'PO_HEADERS',
          p_purge_in_rec        => l_in_rec,
          x_purge_out_rec       => l_out_rec
        );

        IF (g_fnd_debug = 'Y') THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string
            ( log_level => FND_LOG.LEVEL_STATEMENT,
              module    => l_module || l_progress,
              message   => 'After calling CST Val API. rtn status = ' ||
                           l_return_status
            );
            END IF;
        END IF;

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        l_progress := '030';

        FORALL i IN 1..l_out_rec.purge_allowed.COUNT
            UPDATE  po_purge_po_list PPL
            SET     PPL.double_check_flag = 'N'
            WHERE   PPL.po_header_id = l_in_rec.entity_ids(i)
            AND     l_out_rec.purge_allowed(i) <> 'Y';

    END LOOP;

    l_progress := '040';

    CLOSE c_po_list;

    log_purge_list_count
    ( p_module => l_module || l_progress,
      p_entity => 'PO'
    );

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_PROCEDURE,
          module    => l_module || l_progress,
          message   => 'Quitting ' || g_pkg_name || '.' || l_api_name
        );
        END IF;
    END IF;

EXCEPTION
WHEN OTHERS THEN
    IF (c_po_list%ISOPEN) THEN
        CLOSE c_po_list;
    END IF;

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.add_exc_msg
    ( p_pkg_name        => g_pkg_name,
      p_procedure_name  => l_api_name || '.' || l_progress
    );

END filter_po_cst_validation;


-----------------------------------------------------------------------
--Start of Comments
--Name: filter_po_oe_validation
--Pre-reqs:
--Modifies: po_purge_po_list
--Locks:
--  None
--Function: Call OE Drop Ship API to determine whether the records in the
--          purge list violates the rules defined in OE if the records are
--          purged.
--          If so, exclude those records from the purge list
--Parameters:
--IN:
--IN OUT:
--OUT:
--x_return_status
--  status of the procedure
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------

PROCEDURE filter_po_oe_validation
( x_return_status   OUT NOCOPY VARCHAR2
) IS

l_api_name      VARCHAR2(50) := 'filter_po_oe_validation';
l_progress      VARCHAR2(3);
l_module        CONSTANT FND_LOG_MESSAGES.module%TYPE :=
                    G_MODULE_PREFIX || l_api_name || '.';

l_hdr_id_tbl    OE_DROP_SHIP_GRP.PO_ENTITY_ID_TBL_TYPE;
l_purge_allowed_tbl OE_DROP_SHIP_GRP.VAL_STATUS_TBL_TYPE;

l_return_status VARCHAR2(1);
l_msg_count     NUMBER;
l_msg_data      VARCHAR2(2000);

CURSOR  c_po_list IS
SELECT  po_header_id
FROM    po_purge_po_list
WHERE   double_check_flag = 'Y';

BEGIN

    l_progress := '000';

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_PROCEDURE,
          module    => l_module || l_progress,
          message   => 'Entering ' || g_pkg_name || '.' || l_api_name
        );
        END IF;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- No need to do validation if PO or OM is not at FPJ level or above

    IF (PO_CODE_RELEASE_GRP.Current_Release <
          PO_CODE_RELEASE_GRP.PRC_11i_Family_Pack_J
        OR OE_CODE_CONTROL.code_release_level < '110510') THEN

        IF (g_fnd_debug = 'Y') THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string
            ( log_level => FND_LOG.LEVEL_STATEMENT,
              module    => l_module || l_progress,
              message   => 'Either PO is not at FPJ or above or OM code ' ||
                           'level is not at 11.5.10 level or above. Quitting'
            );
            END IF;
        END IF;

        RETURN;

    END IF;

    OPEN c_po_list;

    LOOP
        l_progress := '010';

        FETCH c_po_list
        BULK COLLECT INTO l_hdr_id_tbl
        LIMIT g_batch_limit;

        EXIT WHEN l_hdr_id_tbl.COUNT = 0;

        l_progress := '020';

        l_purge_allowed_tbl := OE_DROP_SHIP_GRP.VAL_STATUS_TBL_TYPE();

        OE_DROP_SHIP_GRP.purge_drop_ship_po_validation
        ( p_api_version         => 1.0,
          p_init_msg_list       => FND_API.G_TRUE,
          p_commit              => FND_API.G_FALSE,
          x_return_status       => l_return_status,
          x_msg_count           => l_msg_count,
          x_msg_data            => l_msg_data,
          p_entity              => 'PO_HEADERS',
          p_entity_id_tbl       => l_hdr_id_tbl,
          x_purge_allowed_tbl   => l_purge_allowed_tbl
        );

        IF (g_fnd_debug = 'Y') THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string
            ( log_level => FND_LOG.LEVEL_STATEMENT,
              module    => l_module || l_progress,
              message   => 'After calling OE Val API. rtn status = ' ||
                           l_return_status
            );
            END IF;
        END IF;

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        l_progress := '030';

        IF (l_purge_allowed_tbl IS NOT NULL) THEN

            FORALL i IN 1..l_purge_allowed_tbl.COUNT
                UPDATE  po_purge_po_list PPL
                SET     PPL.double_check_flag = 'N'
                WHERE   PPL.po_header_id = l_hdr_id_tbl(i)
                AND     l_purge_allowed_tbl(i) <> 'Y';

        END IF;

    END LOOP;

    l_progress := '040';

    CLOSE c_po_list;

    log_purge_list_count
    ( p_module => l_module || l_progress,
      p_entity => 'PO'
    );

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_PROCEDURE,
          module    => l_module || l_progress,
          message   => 'Quitting ' || g_pkg_name || '.' || l_api_name
        );
        END IF;
    END IF;

EXCEPTION
WHEN OTHERS THEN
    IF (c_po_list%ISOPEN) THEN
        CLOSE c_po_list;
    END IF;

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.add_exc_msg
    ( p_pkg_name        => g_pkg_name,
      p_procedure_name  => l_api_name || '.' || l_progress
    );

END filter_po_oe_validation;


-----------------------------------------------------------------------
--Start of Comments
--Name: filter_po_pon_validation
--Pre-reqs:
--Modifies: po_purge_po_list
--Locks:
--  None
--Function: Call Sourcing API to determine whether the records in the
--          purge list violates the rules defined in PON if the records are
--          purged.
--          If so, exclude those records from the purge list
--Parameters:
--IN:
--IN OUT:
--OUT:
--x_return_status
--  status of the procedure
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------

PROCEDURE filter_po_pon_validation
( x_return_status   OUT NOCOPY VARCHAR2
) IS

l_api_name      VARCHAR2(50) := 'filter_po_pon_validation';
l_progress      VARCHAR2(3);
l_module        CONSTANT FND_LOG_MESSAGES.module%TYPE :=
                    G_MODULE_PREFIX || l_api_name || '.';

l_in_rec        PON_PO_INTEGRATION_GRP.PURGE_IN_RECTYPE;
l_out_rec       PON_PO_INTEGRATION_GRP.PURGE_OUT_RECTYPE;

l_return_status VARCHAR2(1);
l_msg_count     NUMBER;
l_msg_data      VARCHAR2(2000);

CURSOR  c_po_list IS
SELECT  po_header_id
FROM    po_purge_po_list
WHERE   double_check_flag = 'Y';

BEGIN

    l_progress := '000';

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_PROCEDURE,
          module    => l_module || l_progress,
          message   => 'Entering ' || g_pkg_name || '.' || l_api_name
        );
        END IF;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_in_rec.entity_name := 'PO_HEADERS';

    OPEN c_po_list;

    LOOP
        l_progress := '010';

        FETCH c_po_list
        BULK COLLECT INTO l_in_rec.entity_ids
        LIMIT g_batch_limit;

        EXIT WHEN l_in_rec.entity_ids.COUNT = 0;

        l_progress := '020';

        PON_PO_INTEGRATION_GRP.validate_po_purge
        ( p_api_version         => 1.0,
          p_init_msg_list       => FND_API.G_TRUE,
          p_commit              => FND_API.G_FALSE,
          x_return_status       => l_return_status,
          x_msg_count           => l_msg_count,
          x_msg_data            => l_msg_data,
          p_in_rec              => l_in_rec,
          x_out_rec             => l_out_rec
        );

        IF (g_fnd_debug = 'Y') THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string
            ( log_level => FND_LOG.LEVEL_STATEMENT,
              module    => l_module || l_progress,
              message   => 'After calling pon val api. rtn status = ' ||
                           l_return_status
            );
            END IF;
        END IF;

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        l_progress := '030';

        FORALL i IN 1..l_out_rec.purge_allowed.COUNT
            UPDATE  po_purge_po_list PPL
            SET     PPL.double_check_flag = 'N'
            WHERE   PPL.po_header_id = l_in_rec.entity_ids(i)
            AND     l_out_rec.purge_allowed(i) <> 'Y';

    END LOOP;

    l_progress := '040';

    CLOSE c_po_list;

    log_purge_list_count
    ( p_module => l_module || l_progress,
      p_entity => 'PO'
    );

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_PROCEDURE,
          module    => l_module || l_progress,
          message   => 'Quitting ' || g_pkg_name || '.' || l_api_name
        );
        END IF;
    END IF;

EXCEPTION
WHEN OTHERS THEN
    IF (c_po_list%ISOPEN) THEN
        CLOSE c_po_list;
    END IF;

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.add_exc_msg
    ( p_pkg_name        => g_pkg_name,
      p_procedure_name  => l_api_name || '.' || l_progress
    );

END filter_po_pon_validation;

-----------------------------------------------------------------------
--Start of Comments
--Name: filter_po_hr_validation
--Pre-reqs:
--Modifies: po_purge_po_list
--Locks:
--  None
--Function: Call HR API to determine whether the records in the
--          purge list violates the rules defined in HR if the records are
--          purged.
--          If so, exclude those records from the purge list
--Parameters:
--IN:
--IN OUT:
--OUT:
--x_return_status
--  status of the procedure
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------

PROCEDURE filter_po_hr_validation
( x_return_status   OUT NOCOPY VARCHAR2
) IS

l_api_name      VARCHAR2(50) := 'filter_po_hr_validation';
l_progress      VARCHAR2(3);
l_module        CONSTANT FND_LOG_MESSAGES.module%TYPE :=
                    G_MODULE_PREFIX || l_api_name || '.';

l_in_tbl        HR_PO_INFO.g_table_numbers_t;
l_out_tbl       HR_PO_INFO.g_table_numbers_t;

CURSOR  c_po_list IS
SELECT  po_header_id
FROM    po_purge_po_list
WHERE   double_check_flag = 'Y';

BEGIN

    l_progress := '000';

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_PROCEDURE,
          module    => l_module || l_progress,
          message   => 'Entering ' || g_pkg_name || '.' || l_api_name
        );
        END IF;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    OPEN c_po_list;

    LOOP
        l_progress := '010';

        FETCH c_po_list
        BULK COLLECT INTO l_in_tbl
        LIMIT g_batch_limit;

        EXIT WHEN l_in_tbl.COUNT = 0;

        l_progress := '020';

        HR_PO_INFO.asgs_exist_for_pos
        ( p_po_in_tbl => l_in_tbl,
          p_po_out_tbl => l_out_tbl
        );

        IF (g_fnd_debug = 'Y') THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string
            ( log_level => FND_LOG.LEVEL_STATEMENT,
              module    => l_module || l_progress,
              message   => 'After calling hr val api.'
            );
            END IF;
        END IF;

        l_progress := '030';

        FORALL i IN 1..l_out_tbl.COUNT
            UPDATE  po_purge_po_list PPL
            SET     PPL.double_check_flag = 'N'
            WHERE   PPL.po_header_id = l_out_tbl(i);

    END LOOP;

    l_progress := '040';

    CLOSE c_po_list;

    log_purge_list_count
    ( p_module => l_module || l_progress,
      p_entity => 'PO'
    );

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_PROCEDURE,
          module    => l_module || l_progress,
          message   => 'Quitting ' || g_pkg_name || '.' || l_api_name
        );
        END IF;
    END IF;

EXCEPTION
WHEN OTHERS THEN
    IF (c_po_list%ISOPEN) THEN
        CLOSE c_po_list;
    END IF;

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.add_exc_msg
    ( p_pkg_name        => g_pkg_name,
      p_procedure_name  => l_api_name || '.' || l_progress
    );

END filter_po_hr_validation;




-----------------------------------------------------------------------
--Start of Comments
--Name: delete_asl_ref
--Pre-reqs:
--Modifies: PO_ASL_DOCUMENTS
--Locks:
--  None
--Function: Delete referenced documents on ASL when the document is purged
--Parameters:
--IN:
--p_range_low
--  lower bound of the po to be purged
--p_range_high
--  upper bound of the po to be purged
--IN OUT:
--OUT:
--x_return_status
--  status of the procedure
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------

PROCEDURE delete_asl_ref
( x_return_status   OUT NOCOPY  VARCHAR2,
  p_range_low       IN          NUMBER,
  p_range_high      IN          NUMBER
) IS

l_api_name      VARCHAR2(50) := 'delete_asl_ref';
l_progress      VARCHAR2(3);
l_module        CONSTANT FND_LOG_MESSAGES.module%TYPE :=
                    G_MODULE_PREFIX || l_api_name || '.';

BEGIN

    l_progress := '000';

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_PROCEDURE,
          module    => l_module || l_progress,
          message   => 'Entering ' || g_pkg_name || '.' || l_api_name
        );
        END IF;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- bug3256316
    -- We should be selecting PPL.po_Header_id instead of NULL

    --SQL What: Delete ASL doc reference for documents that are in the purge
    --          List
    --SQL Why:  When document is purged,the ASL reference becomes useless.
    --          Hence it can be deleted
    DELETE
    FROM    po_asl_documents PAD
    WHERE   PAD.document_header_id IN
            ( SELECT    PPL.po_header_id
              FROM      po_purge_po_list PPL
              WHERE     PPL.double_check_flag = 'Y'
              AND       PPL.po_header_id BETWEEN p_range_low
                                         AND     p_range_high);

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_PROCEDURE,
          module    => l_module || l_progress,
          message   => 'Quitting ' || g_pkg_name || '.' || l_api_name
        );
        END IF;
    END IF;

EXCEPTION
WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.add_exc_msg
    ( p_pkg_name        => g_pkg_name,
      p_procedure_name  => l_api_name || '.' || l_progress
    );

END delete_asl_ref;


-----------------------------------------------------------------------
--Start of Comments
--Name: delete_org_assignments
--Pre-reqs:
--Modifies: PO_GA_ORG_ASSSIGNMENTS, PO_GA_ORG_ASSIGNMENTS_ARCHIVE
--Locks:
--  None
--Function: This procedure removes org assignments for documents that
--          are being purged
--Parameters:
--IN:
--p_range_low
--  lower bound of the po to be purged
--p_range_high
--  upper bound of the po to be purged
--IN OUT:
--OUT:
--x_return_status
--  status of the procedure
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------

PROCEDURE delete_org_assignments
( x_return_status   OUT NOCOPY  VARCHAR2,
  p_range_low       IN          NUMBER,
  p_range_high      IN          NUMBER
) IS

l_api_name      VARCHAR2(50) := 'delete_org_assignments';
l_progress      VARCHAR2(3);
l_module        CONSTANT FND_LOG_MESSAGES.module%TYPE :=
                    G_MODULE_PREFIX || l_api_name || '.';

BEGIN

    l_progress := '000';

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_PROCEDURE,
          module    => l_module || l_progress,
          message   => 'Entering ' || g_pkg_name || '.' || l_api_name
        );
        END IF;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    DELETE
    FROM    po_ga_org_assignments PGOA
    WHERE   PGOA.po_header_id IN
                (SELECT PPL.po_header_id
                 FROM   po_purge_po_list PPL
                 WHERE  PPL.double_check_flag = 'Y'
                 AND    PPL.po_header_id BETWEEN p_range_low
                                         AND     p_range_high);

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_STATEMENT,
          module    => l_module || l_progress,
          message   => 'Deleted PGOA rowcount = ' || SQL%ROWCOUNT
        );
        END IF;
    END IF;

    l_progress := '010';

    DELETE
    FROM    po_ga_org_assignments_archive PGOAA
    WHERE   PGOAA.po_header_id IN
                (SELECT PPL.po_header_id
                 FROM   po_purge_po_list PPL
                 WHERE  PPL.double_check_flag = 'Y'
                 AND    PPL.po_header_id BETWEEN p_range_low
                                         AND     p_range_high);

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_STATEMENT,
          module    => l_module || l_progress,
          message   => 'Deleted PGOAA rowcount = ' || SQL%ROWCOUNT
        );
        END IF;
    END IF;

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_PROCEDURE,
          module    => l_module || l_progress,
          message   => 'Quitting ' || g_pkg_name || '.' || l_api_name
        );
        END IF;
    END IF;

EXCEPTION
WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.add_exc_msg
    ( p_pkg_name        => g_pkg_name,
      p_procedure_name  => l_api_name || '.' || l_progress
    );

END delete_org_assignments;


-----------------------------------------------------------------------
--Start of Comments
--Name: delete_drop_ship_po_links
--Pre-reqs:
--Modifies:
--Locks:
--  None
--Function: Call OM API to remove the relationship between OM and PO
--          when PO document is purged
--Parameters:
--IN:
--p_range_low
--  lower bound of the po to be purged
--p_range_high
--  upper bound of the po to be purged
--IN OUT:
--OUT:
--x_return_status
--  status of the procedure
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------

PROCEDURE delete_drop_ship_po_links
( x_return_status   OUT NOCOPY  VARCHAR2,
  p_range_low       IN          NUMBER,
  p_range_high      IN          NUMBER
) IS

l_api_name      VARCHAR2(50) := 'delete_drop_ship_po_links';
l_progress      VARCHAR2(3);
l_return_status VARCHAR2(1);
l_module        CONSTANT FND_LOG_MESSAGES.module%TYPE :=
                    G_MODULE_PREFIX || l_api_name || '.';

l_po_hdr_tbl    OE_DROP_SHIP_GRP.PO_ENTITY_ID_TBL_TYPE;

l_msg_count     NUMBER;
l_msg_data      VARCHAR2(2000);

BEGIN
    l_progress := '000';

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_PROCEDURE,
          module    => l_module || l_progress,
          message   => 'Entering ' || g_pkg_name || '.' || l_api_name
        );
        END IF;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    SELECT  PPL.po_header_id
    BULK COLLECT
    INTO    l_po_hdr_tbl
    FROM    po_purge_po_list PPL
    WHERE   PPL.po_header_id BETWEEN p_range_low AND p_range_high
    AND     PPL.double_check_flag = 'Y';

    l_progress := '010';

    -- Call OM Drop Ship Purge API only if both PO and OM are at FPJ level
    -- or above

    IF (PO_CODE_RELEASE_GRP.Current_Release >=
          PO_CODE_RELEASE_GRP.PRC_11i_Family_Pack_J
        AND OE_CODE_CONTROL.code_release_level >= '110510') THEN

        l_progress := '020';

        OE_DROP_SHIP_GRP.purge_drop_ship_po_links
        ( p_api_version     => 1.0,
          p_init_msg_list   => FND_API.G_TRUE,
          p_commit          => FND_API.G_FALSE,
          x_return_status   => l_return_status,
          x_msg_count       => l_msg_count,
          x_msg_data        => l_msg_data,
          p_entity          => 'PO_HEADERS',
          p_entity_id_tbl   => l_po_hdr_tbl
        );

        IF (g_fnd_debug = 'Y') THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string
            ( log_level => FND_LOG.LEVEL_STATEMENT,
              module    => l_module || l_progress,
              message   => 'After calling OE purge API. rtn status = ' ||
                            l_return_status
            );
            END IF;
        END IF;

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

    END IF; -- IF PO Level > FPJ and OM level > 110510

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_PROCEDURE,
          module    => l_module || l_progress,
          message   => 'Quitting ' || g_pkg_name || '.' || l_api_name
        );
        END IF;
    END IF;

EXCEPTION
WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.add_exc_msg
    ( p_pkg_name        => g_pkg_name,
      p_procedure_name  => l_api_name || '.' || l_progress
    );

END delete_drop_ship_po_links;


-----------------------------------------------------------------------
--Start of Comments
--Name: delete_fte
--Pre-reqs:
--Modifies:
--Locks:
--  None
--Function: Call FTE API to nofity them what documents have been purged
--Parameters:
--IN:
--p_range_low
--  lower bound of the po to be purged
--p_range_high
--  upper bound of the po to be purged
--IN OUT:
--OUT:
--x_return_status
--  status of the procedure
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------

PROCEDURE delete_fte
( x_return_status   OUT NOCOPY  VARCHAR2,
  p_range_low       IN          NUMBER,
  p_range_high      IN          NUMBER
) IS

l_api_name      VARCHAR2(50) := 'delete_fte';
l_progress      VARCHAR2(3);
l_return_status VARCHAR2(1);
l_module        CONSTANT FND_LOG_MESSAGES.module%TYPE :=
                    G_MODULE_PREFIX || l_api_name || '.';

l_fte_in_rec    WSH_PO_INTG_TYPES_GRP.purge_in_rectype;
l_msg_count     NUMBER;
l_msg_data      VARCHAR2(2000);

BEGIN
    l_progress := '000';

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_PROCEDURE,
          module    => l_module || l_progress,
          message   => 'Entering ' || g_pkg_name || '.' || l_api_name
        );
        END IF;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (PO_CORE_S.get_product_install_status('FTE') <> 'I'
        OR
        WSH_CODE_CONTROL.Get_Code_Release_Level < '110510') THEN

        IF (g_fnd_debug = 'Y') THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string
            ( log_level => FND_LOG.LEVEL_STATEMENT,
              module    => l_module || l_progress,
              message   => 'Either FTE is not installed or WSH code level '||
                           'is not at 11.5.10 level. Quitting'
            );
            END IF;
        END IF;

        RETURN;
    END IF;  -- fte is not installed or wsh code < 110510

    l_fte_in_rec.caller := 'PO_DOC_PURGE';

    SELECT  PPL.po_header_id
    BULK COLLECT
    INTO    l_fte_in_rec.header_ids
    FROM    po_purge_po_list PPL
    WHERE   PPL.double_check_flag = 'Y'
    AND     PPL.po_header_id BETWEEN p_range_low AND p_range_high;

    l_progress := '010';

    WSH_PO_INTEGRATION_GRP.purge
    ( p_api_version_number  => 1.0,
      p_init_msg_list       => FND_API.G_TRUE,
      p_commit              => FND_API.G_FALSE,
      x_return_status       => l_return_status,
      x_msg_count           => l_msg_count,
      x_msg_data            => l_msg_data,
      p_in_rec              => l_fte_in_rec
    );

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_STATEMENT,
          module    => l_module || l_progress,
          message   => 'After calling FTE Purge API. rtn status = ' ||
                        l_return_status
        );
        END IF;
    END IF;

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_PROCEDURE,
          module    => l_module || l_progress,
          message   => 'Quitting ' || g_pkg_name || '.' || l_api_name
        );
        END IF;
    END IF;

EXCEPTION
WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.add_exc_msg
    ( p_pkg_name        => g_pkg_name,
      p_procedure_name  => l_api_name || '.' || l_progress
    );

END delete_fte;


-----------------------------------------------------------------------
--Start of Comments
--Name: delete_pon
--Pre-reqs:
--Modifies:
--Locks:
--  None
--Function: Call PON API to nofity them what documents have been purged
--Parameters:
--IN:
--p_purge_entity
--  'PO' for PO documents
--  'REQ' for Requisition documents
--p_range_low
--  lower bound of the po to be purged
--p_range_high
--  upper bound of the po to be purged
--IN OUT:
--OUT:
--x_return_status
--  status of the procedure
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------

PROCEDURE delete_pon
( x_return_status   OUT NOCOPY  VARCHAR2,
  p_purge_entity    IN          VARCHAR2,
  p_range_low       IN          NUMBER,
  p_range_high      IN          NUMBER
) IS

l_api_name      VARCHAR2(50) := 'delete_pon';
l_progress      VARCHAR2(3);
l_return_status VARCHAR2(1);
l_module        CONSTANT FND_LOG_MESSAGES.module%TYPE :=
                    G_MODULE_PREFIX || l_api_name || '.';

l_in_rec        PON_PO_INTEGRATION_GRP.purge_in_rectype;
l_msg_count     NUMBER;
l_msg_data      VARCHAR2(2000);

BEGIN
    l_progress := '000';

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_PROCEDURE,
          module    => l_module || l_progress,
          message   => 'Entering ' || g_pkg_name || '.' || l_api_name
        );
        END IF;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_purge_entity = 'PO') THEN
        l_in_rec.entity_name := 'PO_HEADERS';

        SELECT  PPL.po_header_id
        BULK COLLECT
        INTO    l_in_rec.entity_ids
        FROM    po_purge_po_list PPL
        WHERE   PPL.double_check_flag = 'Y'
        AND     PPL.po_header_id BETWEEN p_range_low AND p_range_high;

        l_progress := '010';
    ELSE
        l_in_rec.entity_name := 'PO_REQUISITION_HEADERS';

        SELECT  PPRL.requisition_header_id
        BULK COLLECT
        INTO    l_in_rec.entity_ids
        FROM    po_purge_req_list PPRL
        WHERE   PPRL.double_check_flag = 'Y'
        AND     PPRL.requisition_header_id BETWEEN p_range_low
                                           AND     p_range_high;

        l_progress := '020';
    END IF;

    PON_PO_INTEGRATION_GRP.po_purge
    ( p_api_version     => 1.0,
      p_init_msg_list   => FND_API.G_TRUE,
      p_commit          => FND_API.G_FALSE,
      x_return_status   => l_return_status,
      x_msg_count       => l_msg_count,
      x_msg_data        => l_msg_data,
      p_in_rec          => l_in_rec
    );

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_STATEMENT,
          module    => l_module || l_progress,
          message   => 'After calling PON Purge API. rtn status = ' ||
                        l_return_status
        );
        END IF;
    END IF;

    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_PROCEDURE,
          module    => l_module || l_progress,
          message   => 'Quitting ' || g_pkg_name || '.' || l_api_name
        );
        END IF;
    END IF;

EXCEPTION
WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.add_exc_msg
    ( p_pkg_name        => g_pkg_name,
      p_procedure_name  => l_api_name || '.' || l_progress
    );

END delete_pon;



-----------------------------------------------------------------------
--Start of Comments
--Name: delete_contract_terms
--Pre-reqs:
--Modifies:
--Locks:
--  None
--Function: Call OKC API to remove associated contract terms when
--          documents are purged
--Parameters:
--IN:
--p_range_low
--  lower bound of the po to be purged
--p_range_high
--  upper bound of the po to be purged
--IN OUT:
--OUT:
--x_return_status
--  status of the procedure
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------

PROCEDURE delete_contract_terms
( x_return_status   OUT NOCOPY  VARCHAR2,
  p_range_low       IN          NUMBER,
  p_range_high      IN          NUMBER
) IS

l_api_name      VARCHAR2(50) := 'delete_contract_terms';
l_progress      VARCHAR2(3);
l_return_status VARCHAR2(1);
l_module        CONSTANT FND_LOG_MESSAGES.module%TYPE :=
                    G_MODULE_PREFIX || l_api_name || '.';

l_header_tbl    OKC_TERMS_UTIL_GRP.doc_tbl_type;
l_msg_count     NUMBER;
l_msg_data      VARCHAR2(2000);


-- bug3293282
-- Sinec bulk collect into a table of records does not work in 8i, we need
-- to change the select statement into a cursor and fetch the record one by
-- one

-- SQL What: Construct l_header_tbl with doc type and id information
--           for records in the purge list
-- SQL Why:  Prepare input parameter for okc purge api.
CURSOR c_po_list IS
    SELECT  DECODE (PH.type_lookup_code, 'STANDARD', 'PO_STANDARD',
                                         'BLANKET' , 'PA_BLANKET',
                                         'CONTRACT', 'PA_CONTRACT') DOC_TYPE,
            PH.po_header_id DOC_ID
    FROM    po_headers PH,
            po_purge_po_list PPL
    WHERE   PH.po_header_id = PPL.po_header_id
    AND     PPL.double_check_flag = 'Y'
    AND     PPL.po_header_id BETWEEN p_range_low AND p_range_high
    AND     PH.type_lookup_code IN ('STANDARD', 'BLANKET', 'CONTRACT')
    AND     PH.conterms_exist_flag = 'Y';

l_po_list_rec c_po_list%ROWTYPE;
l_rec_count       NUMBER := 0;

BEGIN
    l_progress := '000';

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_PROCEDURE,
          module    => l_module || l_progress,
          message   => 'Entering ' || g_pkg_name || '.' || l_api_name
        );
        END IF;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (PO_CONTERMS_UTL_GRP.is_contracts_enabled = 'N') THEN
        IF (g_fnd_debug = 'Y') THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string
            ( log_level => FND_LOG.LEVEL_STATEMENT,
              module    => l_module || l_progress,
              message   => 'Procurement Contract is not available. Exit ' ||
                           'delete_contract_terms'
            );
            END IF;
        END IF;

        RETURN;
    END IF;

    -- Loop through each record in cursor c_po_list and populate the
    -- same into l_header_tbl. It is done this way since bulk Collect into
    -- table of records is not supported in 8i.

    FOR l_po_list_rec IN c_po_list LOOP
        l_rec_count := l_rec_count + 1;
        l_header_tbl(l_rec_count).doc_type := l_po_list_rec.doc_type;
        l_header_tbl(l_rec_count).doc_id   := l_po_list_rec.doc_id;
    END LOOP;

    IF (l_header_tbl.COUNT = 0) THEN
        RETURN;
    END IF;

    OKC_TERMS_UTIL_GRP.purge_doc
    ( p_api_version     => 1.0,
      p_init_msg_list   => FND_API.G_TRUE,
      p_commit          => FND_API.G_FALSE,
      x_return_status   => l_return_status,
      x_msg_data        => l_msg_data,
      x_msg_count       => l_msg_count,
      p_doc_tbl         => l_header_tbl
    );

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_STATEMENT,
          module    => l_module || l_progress,
          message   => 'After calling okc purge API. rtn status = ' ||
                        l_return_status
        );
        END IF;
    END IF;

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_PROCEDURE,
          module    => l_module || l_progress,
          message   => 'Quitting ' || g_pkg_name || '.' || l_api_name
        );
        END IF;
    END IF;

EXCEPTION
WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.add_exc_msg
    ( p_pkg_name        => g_pkg_name,
      p_procedure_name  => l_api_name || '.' || l_progress
    );

END delete_contract_terms;


-----------------------------------------------------------------------
--Start of Comments
--Name: delete_price_differentials
--Pre-reqs:
--Modifies:
--Locks:
--  None
--Function: Remove records from po_price_differentials when documetns they
--          associate with are getting purged
--Parameters:
--IN:
--p_purge_entity
--  REQ: purge price differentials associated to REQs
--  PO:  purge price differentials associated to POs
--p_range_low
--  lower bound of the req/po to be purged
--p_range_high
--  upper bound of the req/po to be purged
--IN OUT:
--OUT:
--x_return_status
--  status of the procedure
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------

PROCEDURE delete_price_differentials
( x_return_status   OUT NOCOPY  VARCHAR2,
  p_purge_entity    IN          VARCHAR2,
  p_range_low       IN          NUMBER,
  p_range_high      IN          NUMBER
) IS

l_api_name      VARCHAR2(50) := 'delete_price_differentials';
l_progress      VARCHAR2(3);
l_return_status VARCHAR2(1);
l_module        CONSTANT FND_LOG_MESSAGES.module%TYPE :=
                    G_MODULE_PREFIX || l_api_name || '.';

BEGIN

    l_progress := '000';

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_PROCEDURE,
          module    => l_module || l_progress,
          message   => 'Entering ' || g_pkg_name || '.' || l_api_name
        );
        END IF;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_purge_entity = 'REQ') THEN
        l_progress := '010';

        DELETE
        FROM    po_price_differentials PPD
        WHERE   PPD.entity_type = 'REQ LINE'
        AND     EXISTS (
                    SELECT  NULL
                    FROM    po_purge_req_list PPRL,
                            po_requisition_lines RL
                    WHERE   PPRL.requisition_header_id =
                            RL.requisition_header_id
                    AND     RL.requisition_line_id = PPD.entity_id
                    AND     PPRL.double_check_flag = 'Y'
                    AND     PPRL.requisition_header_id BETWEEN p_range_low
                                                       AND     p_range_high);

        IF (g_fnd_debug = 'Y') THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string
            ( log_level => FND_LOG.LEVEL_STATEMENT,
              module    => l_module || l_progress,
              message   => 'Deleted PPD rowcount = ' || SQL%ROWCOUNT
            );
            END IF;
        END IF;

    ELSIF (p_purge_entity = 'PO') THEN
        l_progress := '020';

        DELETE
        FROM    po_price_differentials PPD
        WHERE   PPD.entity_type IN ('PO LINE', 'BLANKET LINE')
        AND     EXISTS (
                    SELECT  NULL
                    FROM    po_purge_po_list PPL,
                            po_lines POL
                    WHERE   PPL.po_header_id = POL.po_header_id
                    AND     POL.po_line_id = PPD.entity_id
                    AND     PPL.double_check_flag = 'Y'
                    AND     PPL.po_header_id BETWEEN p_range_low
                                             AND     p_range_high);

        IF (g_fnd_debug = 'Y') THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string
            ( log_level => FND_LOG.LEVEL_STATEMENT,
              module    => l_module || l_progress,
              message   => 'Deleted PPD rowcount = ' || SQL%ROWCOUNT
            );
            END IF;
        END IF;

        l_progress := '030';

        DELETE
        FROM    po_price_differentials_archive PPD
        WHERE   PPD.entity_type IN ('PO LINE', 'BLANKET LINE')
        AND     EXISTS (
                    SELECT  NULL
                    FROM    po_purge_po_list PPL,
                            po_lines POL
                    WHERE   PPL.po_header_id = POL.po_header_id
                    AND     POL.po_line_id = PPD.entity_id
                    AND     PPL.double_check_flag = 'Y'
                    AND     PPL.po_header_id BETWEEN p_range_low
                                             AND     p_range_high);

        IF (g_fnd_debug = 'Y') THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string
            ( log_level => FND_LOG.LEVEL_STATEMENT,
              module    => l_module || l_progress,
              message   => 'Deleted PPDA rowcount = ' || SQL%ROWCOUNT
            );
            END IF;
        END IF;

        l_progress := '040';

        DELETE
        FROM    po_price_differentials PPD
        WHERE   PPD.entity_type = 'PRICE BREAK'
        AND     EXISTS (
                    SELECT  NULL
                    FROM    po_purge_po_list PPL,
                            po_line_locations PLL
                    WHERE   PPL.po_header_id = PLL.po_header_id
                    AND     PLL.line_location_id = PPD.entity_id
                    AND     PPL.double_check_flag = 'Y'
                    AND     PPL.po_header_id BETWEEN p_range_low
                                             AND     p_range_high);

        IF (g_fnd_debug = 'Y') THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string
            ( log_level => FND_LOG.LEVEL_STATEMENT,
              module    => l_module || l_progress,
              message   => 'Deleted PPD rowcount = ' || SQL%ROWCOUNT
            );
            END IF;
        END IF;

        l_progress := '050';

        DELETE
        FROM    po_price_differentials_archive PPD
        WHERE   PPD.entity_type = 'PRICE BREAK'
        AND     EXISTS (
                    SELECT  NULL
                    FROM    po_purge_po_list PPL,
                            po_line_locations PLL
                    WHERE   PPL.po_header_id = PLL.po_header_id
                    AND     PLL.line_location_id = PPD.entity_id
                    AND     PPL.double_check_flag = 'Y'
                    AND     PPL.po_header_id BETWEEN p_range_low
                                             AND     p_range_high);

        IF (g_fnd_debug = 'Y') THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string
            ( log_level => FND_LOG.LEVEL_STATEMENT,
              module    => l_module || l_progress,
              message   => 'Deleted PPDA rowcount = ' || SQL%ROWCOUNT
            );
            END IF;
        END IF;

    END IF;   -- p_purge_category = 'REQ'

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_PROCEDURE,
          module    => l_module || l_progress,
          message   => 'Quitting ' || g_pkg_name || '.' || l_api_name
        );
        END IF;
    END IF;

EXCEPTION
WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.add_exc_msg
    ( p_pkg_name        => g_pkg_name,
      p_procedure_name  => l_api_name || '.' || l_progress
    );

END delete_price_differentials;


-----------------------------------------------------------------------
--Start of Comments
--Name: delete_attr_values
--Pre-reqs:
--Modifies:
--Locks:
--  None
--Function: Remove records from po_attribute_values and
--          po_attribute_values_tlp when documetns they
--          associate with are getting purged
--Parameters:
--IN:
--p_range_low
--  lower bound of the po to be purged
--p_range_high
--  upper bound of the po to be purged
--IN OUT:
--OUT:
--x_return_status
--  status of the procedure
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------

PROCEDURE delete_attr_values
( x_return_status   OUT NOCOPY  VARCHAR2,
  p_range_low       IN          NUMBER,
  p_range_high      IN          NUMBER
) IS

l_api_name      VARCHAR2(50) := 'delete_attr_values';
l_progress      VARCHAR2(3);
l_return_status VARCHAR2(1);
l_module        CONSTANT FND_LOG_MESSAGES.module%TYPE :=
                    G_MODULE_PREFIX || l_api_name || '.';

BEGIN

    l_progress := '000';

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_PROCEDURE,
          module    => l_module || l_progress,
          message   => 'Entering ' || g_pkg_name || '.' || l_api_name
        );
        END IF;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_progress := '010';

    DELETE
    FROM    po_price_differentials PPD
    WHERE   PPD.entity_type IN ('PO LINE', 'BLANKET LINE')
    AND     EXISTS (
                SELECT  NULL
                FROM    po_purge_po_list PPL,
                        po_lines POL
                WHERE   PPL.po_header_id = POL.po_header_id
                AND     POL.po_line_id = PPD.entity_id
                AND     PPL.double_check_flag = 'Y'
                AND     PPL.po_header_id BETWEEN p_range_low
                                         AND     p_range_high);

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_STATEMENT,
          module    => l_module || l_progress,
          message   => 'Deleted PPD rowcount = ' || SQL%ROWCOUNT
        );
        END IF;
    END IF;

    l_progress := '020';

    DELETE
		FROM po_attribute_values PAV
		WHERE PAV.po_line_id IN
		        ( SELECT po_line_id
		          FROM   po_purge_po_list PPL,
                     po_lines POL
              WHERE  PPL.po_header_id = POL.po_header_id
              AND    PPL.double_check_flag = 'Y'
              AND    PPL.po_header_id BETWEEN p_range_low
                                      AND     p_range_high);

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_STATEMENT,
          module    => l_module || l_progress,
          message   => 'Deleted PAV rowcount = ' || SQL%ROWCOUNT
        );
        END IF;
    END IF;

    l_progress := '030';

    DELETE
		FROM po_attribute_values_tlp PAVT
		WHERE PAVT.po_line_id IN
		        ( SELECT po_line_id
		          FROM   po_purge_po_list PPL,
                     po_lines POL
              WHERE  PPL.po_header_id = POL.po_header_id
              AND    PPL.double_check_flag = 'Y'
              AND    PPL.po_header_id BETWEEN p_range_low
                                      AND     p_range_high);

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_STATEMENT,
          module    => l_module || l_progress,
          message   => 'Deleted PAVT rowcount = ' || SQL%ROWCOUNT
        );
        END IF;
    END IF;

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_PROCEDURE,
          module    => l_module || l_progress,
          message   => 'Quitting ' || g_pkg_name || '.' || l_api_name
        );
        END IF;
    END IF;

EXCEPTION
WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.add_exc_msg
    ( p_pkg_name        => g_pkg_name,
      p_procedure_name  => l_api_name || '.' || l_progress
    );

END delete_attr_values;


-----------------------------------------------------------------------
--Start of Comments
--Name: delete_req_attachments
--Pre-reqs:
--Modifies:
--  FND Attachments related tables
--Locks:
--  None
--Function: Delete all the attachments for the reqs in the purge list that
--          fall within the range
--Parameters:
--IN:
--p_range_low
--  lower bound of the req/po to be purged
--p_range_high
--  upper bound of the req/po to be purged
--IN OUT:
--OUT:
--x_return_status
--  status of the procedure
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------

PROCEDURE delete_req_attachments
( x_return_status   OUT NOCOPY  VARCHAR2,
  p_range_low       IN          NUMBER,
  p_range_high      IN          NUMBER
) IS

l_api_name      VARCHAR2(50) := 'delete_req_attachments';
l_progress      VARCHAR2(3);
l_module        CONSTANT FND_LOG_MESSAGES.module%TYPE :=
                    G_MODULE_PREFIX || l_api_name || '.';

CURSOR c_req_header IS
    SELECT  PPRL.requisition_header_id
    FROM    po_purge_req_list PPRL
    WHERE   PPRL.requisition_header_id BETWEEN p_range_low AND p_range_high
    AND     PPRL.double_check_flag = 'Y';

CURSOR c_req_line IS
    SELECT  PRL.requisition_line_id
    FROM    po_purge_req_list PPRL,
            po_requisition_lines PRL
    WHERE   PPRL.requisition_header_id BETWEEN p_range_low AND p_range_high
    AND     PPRL.double_check_flag = 'Y'
    AND     PPRL.requisition_header_id = PRL.requisition_header_id;

BEGIN

    l_progress := '000';

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_PROCEDURE,
          module    => l_module || l_progress,
          message   => 'Entering ' || g_pkg_name || '.' || l_api_name
        );
        END IF;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Delete Req Header Attachments

    FOR rec IN c_req_header LOOP
        l_progress := '010';

        FND_ATTACHED_DOCUMENTS2_PKG.delete_attachments
        ( x_entity_name             => 'REQ_HEADERS',
          x_pk1_value               => rec.requisition_header_id,
          x_delete_document_flag    => 'Y'
        );

    END LOOP;

    l_progress := '020';

    -- Delete Req Line Attachments

    FOR rec IN c_req_line LOOP
        l_progress := '030';

        FND_ATTACHED_DOCUMENTS2_PKG.delete_attachments
        ( x_entity_name             => 'REQ_LINES',
          x_pk1_value               => rec.requisition_line_id,
          x_delete_document_flag    => 'Y'
        );

    END LOOP;

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_PROCEDURE,
          module    => l_module || l_progress,
          message   => 'Quitting ' || g_pkg_name || '.' || l_api_name
        );
        END IF;
    END IF;

EXCEPTION
WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF (c_req_header%ISOPEN) THEN
        CLOSE c_req_header;
    END IF;

    IF (c_req_line%ISOPEN) THEN
        CLOSE c_req_line;
    END IF;

    FND_MSG_PUB.add_exc_msg
    ( p_pkg_name        => g_pkg_name,
      p_procedure_name  => l_api_name || '.' || l_progress
    );

END delete_req_attachments;


-----------------------------------------------------------------------
--Start of Comments
--Name: delete_po_attachments
--Pre-reqs:
--Modifies:
--  FND Attachments related tables
--Locks:
--  None
--Function: Delete all the attachments for the pos (including releases) in the
--          purge list that fall within the range
--Parameters:
--IN:
--p_range_low
--  lower bound of the req/po to be purged
--p_range_high
--  upper bound of the req/po to be purged
--IN OUT:
--OUT:
--x_return_status
--  status of the procedure
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------

PROCEDURE delete_po_attachments
( x_return_status   OUT NOCOPY  VARCHAR2,
  p_range_low       IN          NUMBER,
  p_range_high      IN          NUMBER
) IS

l_api_name      VARCHAR2(50) := 'delete_po_attachments';
l_progress      VARCHAR2(3);
l_module        CONSTANT FND_LOG_MESSAGES.module%TYPE :=
                    G_MODULE_PREFIX || l_api_name || '.';

CURSOR c_po_header IS
    SELECT  PPL.po_header_id
    FROM    po_purge_po_list PPL
    WHERE   PPL.po_header_id BETWEEN p_range_low AND p_range_high
    AND     PPL.double_check_flag = 'Y';

CURSOR c_po_release IS
    SELECT  PR.po_release_id
    FROM    po_purge_po_list PPL,
            po_releases PR
    WHERE   PPL.po_header_id BETWEEN p_range_low AND p_range_high
    AND     PPL.double_check_flag = 'Y'
    AND     PPL.po_header_id = PR.po_header_id;

CURSOR c_po_line IS
    SELECT  POL.po_line_id
    FROM    po_purge_po_list PPL,
            po_lines POL
    WHERE   PPL.po_header_id BETWEEN p_range_low AND p_range_high
    AND     PPL.double_check_flag = 'Y'
    AND     PPL.po_header_id = POL.po_header_id;

CURSOR c_po_shipment IS
    SELECT  POLL.line_location_id
    FROM    po_purge_po_list PPL,
            po_line_locations POLL
    WHERE   PPL.po_header_id BETWEEN p_range_low AND p_range_high
    AND     PPL.double_check_flag = 'Y'
    AND     PPL.po_header_id = POLL.po_header_id;

BEGIN

    l_progress := '000';

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_PROCEDURE,
          module    => l_module || l_progress,
          message   => 'Entering ' || g_pkg_name || '.' || l_api_name
        );
        END IF;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Delete po header attachments

    FOR rec IN c_po_header LOOP
        l_progress := '010';

        FND_ATTACHED_DOCUMENTS2_PKG.delete_attachments
        ( x_entity_name             => 'PO_HEADERS',
          x_pk1_value               => rec.po_header_id,
          x_delete_document_flag    => 'Y'
        );

        -- Delete PDF doc for the PO

        FND_ATTACHED_DOCUMENTS2_PKG.delete_attachments
        ( x_entity_name             => 'PO_HEAD',
          x_pk1_value               => rec.po_header_id,
          x_delete_document_flag    => 'Y'
        );

    END LOOP;

    l_progress := '020';

    -- Delete po releases attachments

    FOR rec IN c_po_release LOOP
        l_progress := '030';

        FND_ATTACHED_DOCUMENTS2_PKG.delete_attachments
        ( x_entity_name             => 'PO_RELEASES',
          x_pk1_value               => rec.po_release_id,
          x_delete_document_flag    => 'Y'
        );

        -- Delete PDF doc for the release

        FND_ATTACHED_DOCUMENTS2_PKG.delete_attachments
        ( x_entity_name             => 'PO_REL',
          x_pk1_value               => rec.po_release_id,
          x_delete_document_flag    => 'Y'
        );

    END LOOP;

    l_progress := '040';

    -- Delete po line attachments

    FOR rec IN c_po_line LOOP
        l_progress := '050';

        -- If a GA line contains attachements, the references for these
        -- attachments will be under entity PO_LINES and PO_IN_GA_LINES.
        -- When deleting the reference in PO_IN_GA_LINES, we do not need to
        -- remove the actual attachments as they will be taken care of when
        -- we delete reference under entity PO_LINES.

        FND_ATTACHED_DOCUMENTS2_PKG.delete_attachments
        ( x_entity_name             => 'PO_IN_GA_LINES',
          x_pk1_value               => rec.po_line_id,
          x_delete_document_flag    => 'N',
          x_automatically_added_flag=> 'Y'
        );

        FND_ATTACHED_DOCUMENTS2_PKG.delete_attachments
        ( x_entity_name             => 'PO_LINES',
          x_pk1_value               => rec.po_line_id,
          x_delete_document_flag    => 'Y'
        );

    END LOOP;

    l_progress := '060';

    -- Delete po shipment attachments

    FOR rec IN c_po_shipment LOOP
        l_progress := '070';

        FND_ATTACHED_DOCUMENTS2_PKG.delete_attachments
        ( x_entity_name             => 'PO_SHIPMENTS',
          x_pk1_value               => rec.line_location_id,
          x_delete_document_flag    => 'Y'
        );

    END LOOP;

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_PROCEDURE,
          module    => l_module || l_progress,
          message   => 'Quitting ' || g_pkg_name || '.' || l_api_name
        );
        END IF;
    END IF;

EXCEPTION
WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF (c_po_header%ISOPEN) THEN
        CLOSE c_po_header;
    END IF;

    IF (c_po_release%ISOPEN) THEN
        CLOSE c_po_release;
    END IF;

    IF (c_po_line%ISOPEN) THEN
        CLOSE c_po_line;
    END IF;

    IF (c_po_shipment%ISOPEN) THEN
        CLOSE c_po_shipment;
    END IF;

    FND_MSG_PUB.add_exc_msg
    ( p_pkg_name        => g_pkg_name,
      p_procedure_name  => l_api_name || '.' || l_progress
    );

END delete_po_attachments;

-- <HTML Agreement R12 START>

-----------------------------------------------------------------------
--Start of Comments
--Name: delete_po_drafts
--Pre-reqs:
--Modifies:
--
--Locks:
--  None
--Function: Delete all existing drafts for the documents from draft tables
--Parameters:
--IN:
--p_range_low
--  lower bound of the req/po to be purged
--p_range_high
--  upper bound of the req/po to be purged
--IN OUT:
--OUT:
--x_return_status
--  status of the procedure
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------

PROCEDURE delete_po_drafts
( x_return_status   OUT NOCOPY  VARCHAR2,
  p_range_low       IN          NUMBER,
  p_range_high      IN          NUMBER
) IS

l_api_name      VARCHAR2(50) := 'delete_drafts';
l_progress      VARCHAR2(3);
l_module        CONSTANT FND_LOG_MESSAGES.module%TYPE :=
                    G_MODULE_PREFIX || l_api_name || '.';

l_dft_id_tbl    PO_TBL_NUMBER;

BEGIN

    l_progress := '000';

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_PROCEDURE,
          module    => l_module || l_progress,
          message   => 'Entering ' || g_pkg_name || '.' || l_api_name
        );
        END IF;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    SELECT DFT.draft_id
    BULK COLLECT
    INTO  l_dft_id_tbl
    FROM  po_drafts DFT,
          po_purge_po_list PPL
    WHERE DFT.document_id = PPL.po_header_id
    AND   PPL.po_header_id BETWEEN p_range_low AND p_range_high
    AND   PPL.double_check_flag = 'Y';

    -- Delete all drafts for documents in purge list
    FOR i IN 1..l_dft_id_tbl.COUNT LOOP
      PO_DRAFTS_PVT.remove_draft_changes
      ( p_draft_id => l_dft_id_tbl(i),
        p_exclude_ctrl_tbl => FND_API.G_FALSE,
        x_return_status => x_return_status
      );
    END LOOP;

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_PROCEDURE,
          module    => l_module || l_progress,
          message   => 'Quitting ' || g_pkg_name || '.' || l_api_name
        );
        END IF;
    END IF;

EXCEPTION
WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    FND_MSG_PUB.add_exc_msg
    ( p_pkg_name        => g_pkg_name,
      p_procedure_name  => l_api_name || '.' || l_progress
    );

END delete_po_drafts;

-- <HTML Agreement R12 END>

--<bug3231186 START>

-----------------------------------------------------------------------
--Start of Comments
--Name: delete_po_approval_list
--Pre-reqs:
--Modifies:
--  FND Attachments related tables
--Locks:
--  None
--Function: Delete records in PO_APPROVAL_LIST_LINES and
--          PO_APPROVAL_LIST_HEADERS where reqs are purged
--Parameters:
--IN:
--p_purge_entity
--  Currently only 'REQ' is supported
--p_range_low
--  lower bound of the req to be purged
--p_range_high
--  upper bound of the req to be purged
--IN OUT:
--OUT:
--x_return_status
--  status of the procedure
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------

PROCEDURE delete_po_approval_list
( x_return_status   OUT NOCOPY  VARCHAR2,
  p_purge_entity    IN          VARCHAR2,
  p_range_low       IN          NUMBER,
  p_range_high      IN          NUMBER
) IS

l_api_name      VARCHAR2(50) := 'delete_po_approval_list';
l_progress      VARCHAR2(3);
l_module        CONSTANT FND_LOG_MESSAGES.module%TYPE :=
                    G_MODULE_PREFIX || l_api_name || '.';
BEGIN

    l_progress := '000';

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_PROCEDURE,
          module    => l_module || l_progress,
          message   => 'Entering ' || g_pkg_name || '.' || l_api_name
        );
        END IF;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_purge_entity = 'REQ') THEN
        l_progress := '010';

        --SQL What: Delete PO_APPROVAL_LIST_LINES for the REQS being purged
        --SQL Why:  These records should get purged together with the reqs
        DELETE
        FROM    po_approval_list_lines PALL
        WHERE   PALL.approval_list_header_id
                IN ( SELECT PALH.approval_list_header_id
                     FROM   po_approval_list_headers PALH,
                            po_purge_req_list        PPRL
                     WHERE  PPRL.requisition_header_id =
                            PALH.document_id
                     AND    PPRL.double_check_flag = 'Y'
                     AND    PPRL.requisition_header_id BETWEEN  p_range_low
                                                       AND      p_range_high
                     AND    PALH.document_type = 'REQUISITION'
                   );

        IF (g_fnd_debug = 'Y') THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string
            ( log_level => FND_LOG.LEVEL_STATEMENT,
              module    => l_module || l_progress,
              message   => 'Deleted po_appr_lines rowcount = ' || SQL%ROWCOUNT
            );
            END IF;
        END IF;

        l_progress := '020';


        --SQL What: Delete PO_APPROVAL_LIST_HEADERS for the REQS being purged
        --SQL Why:  These records should get purged together with the reqs
        DELETE
        FROM    po_approval_list_headers PALH
        WHERE   PALH.document_type = 'REQUISITION'
        AND     PALH.document_id
                IN ( SELECT PPRL.requisition_header_id
                     FROM   po_purge_req_list PPRL
                     WHERE  PPRL.double_check_flag = 'Y'
                     AND    PPRL.requisition_header_Id  BETWEEN p_range_low
                                                        AND     p_range_high
                   );

        IF (g_fnd_debug = 'Y') THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
              FND_LOG.string
            ( log_level => FND_LOG.LEVEL_STATEMENT,
              module    => l_module || l_progress,
              message   => 'Deleted po_appr_hdrs rowcount = ' || SQL%ROWCOUNT
            );
            END IF;
        END IF;
    END IF;

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_PROCEDURE,
          module    => l_module || l_progress,
          message   => 'Quitting ' || g_pkg_name || '.' || l_api_name
        );
        END IF;
    END IF;

EXCEPTION
WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.add_exc_msg
    ( p_pkg_name        => g_pkg_name,
      p_procedure_name  => l_api_name || '.' || l_progress
    );
END delete_po_approval_list;

--<bug3231186 END>

-----------------------------------------------------------------------
--Start of Comments
--Name: log_purge_list_count
--Pre-reqs:
--Modifies:
--  None
--Locks:
--  None
--Function: Put the record count of the purge table into FND_LOG_MESSAGES,
--          if logging is turned on
--Parameters:
--IN:
--p_module
--  the location where this is called from.
--p_entity
--  the table to report. 'REQ' for PO_PURGE_REQ_LIST
--                       'PO'  for PO_PURGE_PO_LIST
--IN OUT:
--OUT:
--Returns:
--Notes:
--  This procedure will not return any error
--Testing:
--End of Comments
------------------------------------------------------------------------

PROCEDURE log_purge_list_count
( p_module      IN      VARCHAR2,
  p_entity      IN      VARCHAR2
) IS

l_count NUMBER;

BEGIN

    IF (g_fnd_debug = 'Y') THEN
        IF (p_entity = 'REQ') THEN

            SELECT  COUNT(*)
            INTO    l_count
            FROM    po_purge_req_list
            WHERE   double_check_flag = 'Y';

        ELSIF (p_entity = 'PO') THEN

            SELECT  COUNT(*)
            INTO    l_count
            FROM    po_purge_po_list
            WHERE   double_check_flag = 'Y';

        END IF;
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.string
        ( log_level => FND_LOG.LEVEL_STATEMENT,
          module    => p_module,
          message   => p_entity || ' purge list count = ' || l_count
        );
        END IF;

    END IF;

EXCEPTION
WHEN OTHERS THEN
    NULL;
END log_purge_list_count;

-- <DOC PURGE FPJ END>

END PO_AP_PURGE_UTIL_PVT;

/
