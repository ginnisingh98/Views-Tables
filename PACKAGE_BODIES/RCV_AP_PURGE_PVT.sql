--------------------------------------------------------
--  DDL for Package Body RCV_AP_PURGE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RCV_AP_PURGE_PVT" AS
/* $Header: RCVVPUDB.pls 120.1 2005/06/29 00:57:01 pjiang noship $ */

-- <DOC PURGE FPJ START>

g_pkg_name      CONSTANT VARCHAR2(30) := 'RCV_AP_PURGE_PVT';
g_fnd_debug     VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
G_MODULE_PREFIX CONSTANT VARCHAR2(40) := 'po.plsql.' || g_pkg_name || '.';

--*********************************************************************
----------------- Private Procedure Prototypes-------------------------
--*********************************************************************

PROCEDURE delete_costing_data
( x_return_status   OUT NOCOPY  VARCHAR2,
  p_rt_ids_tbl      IN          PO_TBL_NUMBER
);

PROCEDURE delete_rcv_attachments
( x_return_status   OUT NOCOPY  VARCHAR2,
  p_rsh_ids_tbl     IN          PO_TBL_NUMBER,
  p_rti_ids_tbl     IN          PO_TBL_NUMBER
);

--*********************************************************************
-------------------------- Public Procedures --------------------------
--*********************************************************************


-----------------------------------------------------------------------
--Start of Comments
--Name: summarize_receipts
--Pre-reqs:
--Modifies: po_history_receipts
--Locks:
--  None
--Function:
--  Record necessary information for receipt lines that are about to be purged
--  To purge a receipt line, it has to be linked to a PO that is in the purge
--  list
--Parameters:
--IN:
--p_purge_name
--  Name of this purge process
--p_range_size
--  The id range size of the documents being inserted into history tables
--  per commit cycle
--p_req_lower_limit
--  min id among all pos to be purged
--p_req_upper_limit
--  max id among all pos to be purged
--IN OUT:
--OUT:
--x_return_status
--  status of the procedure
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------

PROCEDURE summarize_receipts
( x_return_status       OUT NOCOPY  VARCHAR2,
  p_purge_name          IN          VARCHAR2,
  p_range_size          IN          NUMBER,
  p_po_lower_limit      IN          NUMBER,
  p_po_upper_limit      IN          NUMBER
) IS

l_api_name          VARCHAR2(50) := 'summarize_receipts';
l_progress          VARCHAR2(3);
l_range_low         NUMBER;
l_range_high        NUMBER;

BEGIN

    l_progress := '000';


    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_po_lower_limit = -1) THEN
        RETURN;
    END IF;

    l_range_low := p_po_lower_limit;
    l_range_high := p_po_lower_limit + p_range_size;

    LOOP
        l_progress := '010';

        IF (g_fnd_debug = 'Y') THEN
            asn_debug.put_line('Before insert into phr. low = ' || l_range_low || ' high = ' || l_range_high);
        END IF;

        --bug3256316
        --Added NVL() around effective date check.

        -- SQL What: Insert rcv shipment line information in history
        --           table if the po line it associates with is in the
        --           purge list
        -- SQL Why:  Need to record data in history table before actual
        --           purge happens
        INSERT INTO po_history_receipts
        ( receipt_num,
          shipment_num,
          transaction_date,
          vendor_id,
          receiver_name,
          item_description,
          purge_name
        )
        SELECT  NVL(RSH.receipt_num, -1),
                RSH.shipment_num,
                RSH.shipped_date,
                RSH.vendor_id,
                PAPF.full_name,
                RSL.item_description,
                p_purge_name
        FROM    per_all_people_f PAPF,
                rcv_shipment_lines RSL,
                rcv_shipment_headers RSH,
                po_purge_po_list PPL
        WHERE   PPL.double_check_flag = 'Y'
        AND     PPL.po_header_id = RSL.po_header_id
        AND     PPL.po_header_id BETWEEN l_range_low AND l_range_high
        AND     RSL.shipment_header_id = RSH.shipment_header_id
        AND     RSL.employee_id = PAPF.person_id (+)
        AND     TRUNC(SYSDATE) BETWEEN NVL(PAPF.effective_start_date,
                                           TRUNC(SYSDATE))
                               AND     NVL(PAPF.effective_end_date,
                                           TRUNC(SYSDATE));

        COMMIT;

        l_range_low := l_range_high + 1;
        l_range_high := l_range_low + p_range_size;

        IF (l_range_low > p_po_upper_limit) THEN
            l_progress := '020';
            EXIT;
        END IF;

    END LOOP;

EXCEPTION
WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.add_exc_msg
    ( p_pkg_name        => g_pkg_name,
      p_procedure_name  => l_api_name || '.' || l_progress
    );

END summarize_receipts;


-----------------------------------------------------------------------
--Start of Comments
--Name: delete_receipts
--Pre-reqs:
--Modifies: Various RCV transaction tables
--Locks:
--  None
--Function:
--  Delete receiving data when PO are getting purged
--Parameters:
--IN:
--p_range_size
--  Number of documents to be purged per commit cycle
--p_po_lower_limit
--  min id among all pos to be purged
--p_po_upper_limit
--  max id among all pos to be purged
--IN OUT:
--OUT:
--x_return_status
--  status of the procedure
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------

PROCEDURE delete_receipts
( x_return_status       OUT NOCOPY  VARCHAR2,
  p_range_size          IN          NUMBER,
  p_po_lower_limit      IN          NUMBER,
  p_po_upper_limit      IN          NUMBER
) IS


TYPE num_tbltyp IS TABLE OF NUMBER;
l_ids_tbl       num_tbltyp;


l_api_name      VARCHAR2(50) := 'delete_receipts';
l_progress      VARCHAR2(3);

l_range_low     NUMBER;
l_range_high    NUMBER;

l_return_status VARCHAR2(1);

l_rsh_ids_tbl   PO_TBL_NUMBER;
l_rt_ids_tbl    PO_TBL_NUMBER;
l_rti_ids_tbl   PO_TBL_NUMBER;
BEGIN

    l_progress := '000';

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_po_lower_limit = -1) THEN
        RETURN;
    END IF;

    --SQL What: This cursor will divide po_purge_po_list into groups of
    --          records with size p_range_size. Each fetch will return the
    --          highest req id of that group
    --SQL Why:  We want to delete data in smaller groups to avoid running
    --          out of rollback segments

    SELECT  PPL2.po_header_id
    BULK COLLECT INTO l_ids_tbl
    FROM    (SELECT PPL.po_header_id po_header_id,
                    MOD(ROWNUM, p_range_size) mod_result
             FROM   po_purge_po_list PPL
             WHERE  PPL.double_check_flag = 'Y'
             ORDER BY PPL.po_header_id) PPL2
    WHERE   PPL2.mod_result = 0;

    l_progress := '010';

    l_range_low := p_po_lower_limit;

    FOR i IN 0..l_ids_tbl.COUNT LOOP

        IF i = l_ids_tbl.COUNT THEN
            l_range_high := p_po_upper_limit;
        ELSE
            l_range_high := l_ids_tbl(i+1);
        END IF;

        l_progress := '020';

        IF (g_fnd_debug = 'Y') THEN
            asn_debug.put_line('Begin deleting rcv. low = ' || l_range_low ||' high = ' || l_range_high);
        END IF;

        --SQL What: Delete records from rcv_shipment_lines if the pos
        --          they associate with are in the purge list
        DELETE
        FROM    rcv_shipment_lines RSL
        WHERE   EXISTS (
                    SELECT  NULL
                    FROM    po_purge_po_list PPL
                    WHERE   PPL.po_header_id = RSL.po_header_id
                    AND     PPL.double_check_flag = 'Y'
                    AND     PPL.po_header_id BETWEEN l_range_low
                                             AND     l_range_high);

        l_progress := '030';

        --SQL What: Delete records from rcv_shipment_headers if all the
        --          shipment lines for these headers have been deleted, and
        --          there is not pending transaction for these headers. The
        --          returning clause will collect all shipment headers that
        --          have been deleted so that we can notify the same to MRC
        --          in an MRC call out later in this procedure
        DELETE
        FROM    rcv_shipment_headers RSH
        WHERE   NOT EXISTS (
                        SELECT  NULL
                        FROM    rcv_shipment_lines RSL
                        WHERE   RSL.shipment_header_id =
                                RSH.shipment_header_id)
        AND     NOT EXISTS (
                        SELECT  NULL
                        FROM    rcv_transactions_interface RTI
                        WHERE   RTI.shipment_header_id = RSH.shipment_header_id
                        AND     RTI.processing_status_code <> 'COMPLETED')
        RETURNING RSH.shipment_header_id
        BULK COLLECT INTO   l_rsh_ids_tbl;

        IF (g_fnd_debug = 'Y') THEN
            asn_debug.put_line('Deleted ' || l_rsh_ids_tbl.COUNT || ' rsh records');
        END IF;

        l_progress := '040';

        --SQL What: Delete rcv_transactions data
        DELETE
        FROM    rcv_transactions RT
        WHERE   EXISTS (
                    SELECT  NULL
                    FROM    po_purge_po_list PPL
                    WHERE   PPL.po_header_id = RT.po_header_id
                    AND     PPL.double_check_flag = 'Y'
                    AND     PPL.po_header_id BETWEEN l_range_low
                                             AND     l_range_high)
        RETURNING RT.transaction_id, RT.interface_transaction_id
        BULK COLLECT INTO   l_rt_ids_tbl, l_rti_ids_tbl;

        IF (g_fnd_debug = 'Y') THEN
            asn_debug.put_line('Deleted ' || l_rt_ids_tbl.COUNT || ' rt records');
        END IF;

        l_progress := '050';

        -- add a costing API call out to delete
        -- from rcv_sub_ledger_details and rcv_receiving_sub_ledger
        delete_costing_data
        ( x_return_status   => l_return_status,
          p_rt_ids_tbl      => l_rt_ids_tbl
        );

        l_progress := '060';

        --SQL What: Delete rcv_lots_supply data
        DELETE
        FROM    rcv_lots_supply RLS
        WHERE   (RLS.shipment_line_id > 0
                 AND
                 NOT EXISTS (
                        SELECT  NULL
                        FROM    rcv_shipment_lines RSL
                        WHERE   RSL.shipment_line_id = RLS.shipment_line_id))
        OR      (RLS.transaction_id > 0
                 AND
                 NOT EXISTS (
                        SELECT  NULL
                        FROM    rcv_transactions RT
                        WHERE   RT.transaction_id = RLS.transaction_id));

        l_progress := '070';

        --SQL What: Delete rcv_serials_supply data
        DELETE
        FROM    rcv_serials_supply RSS
        WHERE   (RSS.shipment_line_id > 0
                 AND
                 NOT EXISTS (
                        SELECT  NULL
                        FROM    rcv_shipment_lines RSL
                        WHERE   RSL.shipment_line_id = RSS.shipment_line_id))
        OR      (RSS.transaction_id > 0
                 AND
                 NOT EXISTS (
                        SELECT  NULL
                        FROM    rcv_transactions RT
                        WHERE   RT.transaction_id = RSS.transaction_id));

        l_progress := '080';

        --SQL What: Delete rcv_lot_transactions data
        DELETE
        FROM    rcv_lot_transactions RLT
        WHERE   (RLT.shipment_line_id > 0
                 AND
                 NOT EXISTS (
                        SELECT  NULL
                        FROM    rcv_shipment_lines RSL
                        WHERE   RSL.shipment_line_id = RLT.shipment_line_id))
        OR
                (RLT.transaction_id > 0
                 AND
                 NOT EXISTS (
                        SELECT  NULL
                        FROM    rcv_transactions RT
                        WHERE   RT.transaction_id = RLT.transaction_id));

        l_progress := '090';

        --SQL What: Delete rcv_serial_transactions data
        DELETE
        FROM    rcv_serial_transactions RST
        WHERE   (RST.shipment_line_id > 0
                 AND
                 NOT EXISTS (
                        SELECT  NULL
                        FROM    rcv_shipment_lines RSL
                        WHERE   RSL.shipment_line_id = RST.shipment_line_id))
        OR
                (RST.transaction_id > 0
                 AND
                 NOT EXISTS (
                        SELECT  NULL
                        FROM    rcv_transactions RT
                        WHERE   RT.transaction_id = RST.transaction_id));

        l_progress := '100';

        delete_rcv_attachments
        ( x_return_status   => l_return_status,
          p_rsh_ids_tbl     => l_rsh_ids_tbl,
          p_rti_ids_tbl     => l_rti_ids_tbl
        );

        COMMIT;

        l_range_low := l_range_high + 1;

        IF (l_range_low > p_po_upper_limit) THEN
            EXIT;
        END IF;

    END LOOP;

EXCEPTION
WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.add_exc_msg
    ( p_pkg_name        => g_pkg_name,
      p_procedure_name  => l_api_name || '.' || l_progress
    );

END delete_receipts;



--*********************************************************************
-------------------------- Private Procedures -------------------------
--*********************************************************************

-----------------------------------------------------------------------
--Start of Comments
--Name: delete_costing_data
--Pre-reqs:
--Modifies:
--Locks:
--  None
--Function:
--  Call Costing API to delete records from sub ledger tables where receiving
--  transactions are purged
--Parameters:
--IN:
--p_rt_ids_tbl
--  list of rcv_transactions that have been purged
--IN OUT:
--OUT:
--x_return_status
--  status of the procedure
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------

PROCEDURE delete_costing_data
( x_return_status   OUT NOCOPY  VARCHAR2,
  p_rt_ids_tbl      IN          PO_TBL_NUMBER
) IS

l_api_name      VARCHAR2(50) := 'delete_costing_data';
l_progress      VARCHAR2(3);

l_cst_purge_in_rec RCV_AccrualUtilities_GRP.purge_in_rectype;

l_msg_count  NUMBER;
l_msg_data   VARCHAR2(2000);
l_return_status VARCHAR2(1);
BEGIN

    l_progress := '000';

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Copy the ids to a structure that can be passed to costing API

    FOR i IN 1..p_rt_ids_tbl.COUNT LOOP

        l_cst_purge_in_rec.entity_ids(i) := p_rt_ids_tbl(i);

    END LOOP;

    l_progress := '010';

    RCV_AccrualUtilities_GRP.purge
    ( p_api_version         => 1.0,
      p_init_msg_list       => FND_API.G_TRUE,
      p_commit              => FND_API.G_FALSE,
      x_return_status       => l_return_status,
      x_msg_count           => l_msg_count,
      x_msg_data            => l_msg_data,
      p_purge_entity_type   => 'RCV_TRANSACTIONS',
      p_purge_in_rec        => l_cst_purge_in_rec
    );

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

EXCEPTION
WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.add_exc_msg
    ( p_pkg_name        => g_pkg_name,
      p_procedure_name  => l_api_name || '.' || l_progress
    );

END delete_costing_data;

-----------------------------------------------------------------------
--Start of Comments
--Name: delete_rcv_attachments
--Pre-reqs:
--Modifies:
--Locks:
--  None
--Function:
--  Delete attachments that are associated to the purged receiving records
--Parameters:
--IN:
--p_rsh_ids_tbl
--  list of shipment headers that have been purged
--p_rt_ids_tbl
--  list of interface_transaction_id listed in rcv_transaction records that
--  have been purged
--IN OUT:
--OUT:
--x_return_status
--  status of the procedure
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------

PROCEDURE delete_rcv_attachments
( x_return_status   OUT NOCOPY  VARCHAR2,
  p_rsh_ids_tbl     IN          PO_TBL_NUMBER,
  p_rti_ids_tbl     IN          PO_TBL_NUMBER
) IS

l_api_name      VARCHAR2(50) := 'delete_rcv_attachments';
l_progress      VARCHAR2(3);

BEGIN

    l_progress := '000';

    IF (g_fnd_debug = 'Y') THEN
        asn_debug.put_line('deleting rcv attachments');
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    FOR i IN 1..p_rsh_ids_tbl.COUNT LOOP
        l_progress := '010';

        FND_ATTACHED_DOCUMENTS2_PKG.delete_attachments
        ( x_entity_name             => 'RCV_HEADERS',
          x_pk1_value               => p_rsh_ids_tbl(i),
          x_delete_document_flag    => 'Y'
        );

    END LOOP;

    l_progress := '020';

    FOR i IN 1..p_rti_ids_tbl.COUNT LOOP
        l_progress := '030';

        FND_ATTACHED_DOCUMENTS2_PKG.delete_attachments
        ( x_entity_name             => 'RCV_TRANSACTIONS_INTERFACE',
          x_pk1_value               => p_rti_ids_tbl(i),
          x_delete_document_flag    => 'Y'
        );

    END LOOP;

EXCEPTION
WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.add_exc_msg
    ( p_pkg_name        => g_pkg_name,
      p_procedure_name  => l_api_name || '.' || l_progress
    );

END delete_rcv_attachments;

-- <DOC PURGE FPJ END>

END RCV_AP_PURGE_PVT;

/
