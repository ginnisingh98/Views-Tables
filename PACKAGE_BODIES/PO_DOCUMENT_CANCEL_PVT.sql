--------------------------------------------------------
--  DDL for Package Body PO_DOCUMENT_CANCEL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_DOCUMENT_CANCEL_PVT" AS
/* $Header: POXVDCAB.pls 120.3.12010000.38 2014/09/04 05:01:45 shikapoo ship $ */

-- Read the profile option that enables/disables the debug log
g_fnd_debug CONSTANT VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

g_module_prefix CONSTANT VARCHAR2(50) := 'po.plsql.' || g_pkg_name || '.';

-- <Shared Proc FPJ START>

g_debug_stmt  CONSTANT BOOLEAN := PO_DEBUG.is_debug_stmt_on;
g_debug_unexp CONSTANT BOOLEAN := PO_DEBUG.is_debug_unexp_on;

-- <Shared Proc FPJ END>

--<Bug 14207546 :Cancel Refactoring Project Starts>
--------------------------------------------------------------------------------
--Start of Comments
--Name: isDropShipWithUpdateableSO

--Function:
--  Checks if there are any PO/release drop shipments with updatable sales Orders

--Parameters:
--IN:
--  p_entity_level
--  p_entity_id
--  p_document_type

--RETURNS :
--  TRUE if there are any PO/release drop shipments with updatable sales Order
--       Lines
--  FALSE if there are no PO/release drop shipments with updatable sales Order
--        Lines

--End of Comments
--------------------------------------------------------------------------------

FUNCTION isDropShipWithUpdateableSO(
           p_api_version   IN  NUMBER,
           p_init_msg_list IN  VARCHAR2,
           p_entity_level  IN VARCHAR2,
           p_entity_id     IN NUMBER,
           p_document_type IN VARCHAR2)
  RETURN BOOLEAN
 IS

  d_api_version CONSTANT NUMBER := 1.0;
  d_api_name CONSTANT VARCHAR2(30) := 'isDropShipWithUpdateableSO.';
  d_module   CONSTANT VARCHAR2(100) := g_module_prefix || d_api_name;

  l_progress          VARCHAR2(3)   := '000' ;
  l_so_updatable_flag VARCHAR2(1);
  l_return_status     VARCHAR2(30);
  l_msg_data          VARCHAR2(30);
  l_msg_count         NUMBER;
  l_on_hold           VARCHAR2(30);
  l_order_line_status NUMBER;

  CURSOR l_drop_ship_csr IS
  SELECT line_location_id
  FROM   po_line_locations
  WHERE  NVL(drop_ship_flag, 'N') = 'Y'
  AND   ((p_entity_level = c_entity_level_HEADER
            AND p_document_type <> c_doc_type_RELEASE
			AND po_header_id = p_entity_id)
		 OR
         (p_entity_level = c_entity_level_HEADER
     		AND p_document_type  = c_doc_type_RELEASE
			AND po_release_id = p_entity_id)
		 OR
         (p_entity_level = c_entity_level_LINE
		    AND po_line_id = p_entity_id)
		 OR
         (p_entity_level = c_entity_level_SHIPMENT
		    AND line_location_id = p_entity_id)
		);

  l_drop_ship_row l_drop_ship_csr%ROWTYPE;

 BEGIN
    -- Start standard API initialization
    IF FND_API.to_boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    IF NOT FND_API.compatible_api_call(d_api_version, p_api_version,
                                       d_api_name, g_pkg_name) THEN
      RAISE FND_API.g_exc_unexpected_error;
    END IF;

  IF g_debug_stmt THEN
    PO_DEBUG.debug_begin(d_module);
    PO_DEBUG.debug_var(d_module, l_progress, 'p_entity_id', p_entity_id);
    PO_DEBUG.debug_var(d_module, l_progress, 'p_entity_level', p_entity_level);
    PO_DEBUG.debug_var(d_module, l_progress, 'p_document_type', p_document_type);
  END IF;

  l_progress := '001' ;

  FOR l_drop_ship_row IN l_drop_ship_csr LOOP

    OE_DROP_SHIP_GRP.Get_Order_Line_Status(
	  p_api_version => 1.0,
      p_po_header_id => NULL,
      p_po_release_id => NULL,
      p_po_line_id => NULL,
      p_po_line_location_id => l_drop_ship_row.line_location_id,
      p_mode => 0,
      x_updatable_flag => l_so_updatable_flag,
      x_on_hold => l_on_hold,
      x_order_line_status => l_order_line_status,
      x_return_status => l_return_status,
      x_msg_data => l_msg_data,
      x_msg_count => l_msg_count);

    IF g_debug_stmt THEN
      PO_DEBUG.debug_var(d_module, l_progress, 'line_location_id', l_drop_ship_row.line_location_id);
      PO_DEBUG.debug_var(d_module, l_progress, 'l_so_updatable_flag', l_so_updatable_flag);
      PO_DEBUG.debug_var(d_module, l_progress, 'l_order_line_status', l_order_line_status);
      PO_DEBUG.debug_var(d_module, l_progress, 'l_return_status', l_return_status);
    END IF;

    IF (l_return_status IS NULL) THEN
      l_return_status        := FND_API.g_ret_sts_success;
    END IF;

    IF (l_return_status = FND_API.g_ret_sts_error) THEN
      RAISE FND_API.g_exc_error;
    ELSIF (l_return_status = FND_API.g_ret_sts_unexp_error) THEN
      RAISE FND_API.g_exc_unexpected_error;
    END IF;

    IF l_so_updatable_flag = 'Y' THEN
      IF g_debug_stmt THEN
        PO_DEBUG.debug_stmt(d_module, l_progress, 'Exiting from Loop');
      END IF;

     EXIT;
    END IF;

  END LOOP;

  IF l_so_updatable_flag = 'Y' THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;

EXCEPTION
WHEN OTHERS THEN
  RETURN FALSE;

END isDropShipWithUpdateableSO;


--------------------------------------------------------------------------------
--Start of Comments
--Name: isPartialRcvBilled

--Function:
--  Checks if the entity(PO Headers/Line/Shipment) is either received or billed

--Parameters:
--IN:
--  p_entity_level
--  p_entity_id
--  p_document_type

--RETURNS :
--  TRUE if the document(Header/Line/shipment) is either Received or billed
--  FALSE if the document(Header/Line/shipment) is neither Received nor billed

--End of Comments
--------------------------------------------------------------------------------

FUNCTION isPartialRcvBilled(
           p_api_version    IN  NUMBER,
           p_init_msg_list  IN  VARCHAR2,
           p_entity_level  IN VARCHAR2,
           p_document_type IN VARCHAR2,
           p_entity_id     IN NUMBER)
RETURN BOOLEAN

  IS

    d_api_version CONSTANT NUMBER := 1.0;
    d_api_name CONSTANT VARCHAR2(30) := 'isPartialRcvBilled.';
    d_module   CONSTANT VARCHAR2(100) := g_module_prefix || d_api_name;

    l_progress        VARCHAR2(8)            := '000' ;
    l_partial_rcv_bld NUMBER;
    l_return_status   BOOLEAN;

    BEGIN
      -- Start standard API initialization
      IF FND_API.to_boolean(p_init_msg_list) THEN
          FND_MSG_PUB.initialize;
      END IF;

      IF NOT FND_API.compatible_api_call(d_api_version, p_api_version,
                                        d_api_name, g_pkg_name) THEN
        RAISE FND_API.g_exc_unexpected_error;
      END IF;
      l_partial_rcv_bld := 0;
      l_return_status   := FALSE;

      IF g_debug_stmt THEN
        PO_DEBUG.debug_begin(d_module);
        PO_DEBUG.debug_var(d_module, l_progress, 'p_entity_id', p_entity_id);
        PO_DEBUG.debug_var(d_module, l_progress, 'p_entity_level', p_entity_level);
      END IF;

      BEGIN
        l_progress := '001' ;

        IF (p_entity_level = c_entity_level_HEADER) THEN
          --Canceling Header
          l_progress := '002';
          SELECT 1
          INTO l_partial_rcv_bld
          FROM DUAL
          WHERE EXISTS (SELECT 1
                        FROM  po_line_locations
                        WHERE ( (p_document_type <>c_doc_type_RELEASE
                                 AND po_header_id = p_entity_id)
                               OR(p_document_type = c_doc_type_RELEASE
                                   AND po_release_id = p_entity_id)
                              )
                              AND NVL(cancel_flag, 'N')    <> 'Y'
                              AND NVL(closed_code, 'OPEN') <> 'FINALLY CLOSED'
                              AND (quantity_received > 0
                                   OR quantity_billed > 0 ));

        ELSIF (p_entity_level = c_entity_level_LINE) THEN
          --Canceling Line
          l_progress := '003' ;
          SELECT 1
          INTO   l_partial_rcv_bld
          FROM   DUAL
          WHERE  EXISTS (SELECT 1
                          FROM   po_line_locations
                          WHERE  po_line_id = p_entity_id
                                 AND NVL(cancel_flag, 'N') <> 'Y'
                                 AND NVL(closed_code, 'OPEN') <> 'FINALLY CLOSED'
                                 AND(quantity_received > 0
                                     OR quantity_billed > 0 ));

        ELSE
          --Canceling Shipment
          l_progress := '004';
          SELECT 1
          INTO   l_partial_rcv_bld
          FROM  DUAL
          WHERE EXISTS(SELECT 1
                       FROM  po_line_locations
                       WHERE line_location_id = p_entity_id
                             AND NVL(cancel_flag, 'N') <> 'Y'
                             AND NVL(closed_code, 'OPEN') <> 'FINALLY CLOSED'
                             AND ( quantity_received > 0 OR quantity_billed > 0));

        END IF;

        IF g_debug_stmt THEN
          PO_DEBUG.debug_var(d_module, l_progress, 'l_partial_rcv_bld', l_partial_rcv_bld);
        END IF;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_partial_rcv_bld := 0 ;
          IF g_debug_stmt THEN
            PO_DEBUG.debug_stmt(d_module, l_progress, 'Set l_partial_rcv_bld = 0');
          END IF ;
        WHEN OTHERS THEN
          IF g_debug_stmt THEN
            FND_MSG_PUB.add_exc_msg(g_module_prefix, d_api_name||':'||l_progress||':'||SQLCODE||':'||SQLERRM);
            PO_DEBUG.debug_stmt(d_module, l_progress, 'Exception in isPartialRcvBilled check');
          END IF ;
      END ;

      IF l_partial_rcv_bld > 0 THEN
        l_return_status   := TRUE;
      END IF;

      IF g_debug_stmt THEN
        PO_DEBUG.debug_var(d_module, l_progress, 'l_return_status', l_return_status);
      END IF;

    RETURN l_return_status;

END isPartialRcvBilled;


--------------------------------------------------------------------------------
--Start of Comments
--Name: init_recreate_demand_flag

--Function:
--  Initialize the recreate demad flag for each entity being cancelled
--    Logic: The flag value is calculated based on the following conditions:
--      1.Cancel Requistion Option value in Purchasing Options
--        If the Purchasing Option Value is Always and user i/p value for Cancel
--        reqs flag is No then update the cancel Reqs falg to Y.
--        If the Purchasing Option Value is Never and user i/p value for Cancel
--        reqs flag is Yes then update the cancel Reqs falg to N.
--        Otherwise, Consider User i/p value of Cancel Reqs falg.
--
--      2.CTO Order
--        If the entity (Header/Line/Shipment) being cancelled belong to a CTO
--        order, then do not recreate demand.
--
--      3.Complex PO /CLM Po with partially Received/Billed shipments associated.
--        If the entity (Header/Line/Shipment) being cancelled belong to a CLM /
--        Complex order and the entity is partially rcvd/billed, then do not
--        recreate demand
--
--      4.Drop Shipment with an updatable Sales Order Lines check
--        If any shipemnt associated with currecnt entity being cancelled is a
--        Drop Shipment with an updatable SO, then impose recreate demand.
--
--
--Parameters:
--IN:
--  p_cancel_reqs_flag
--  p_entity_dtl

--IN OUT:

-- OUT:
--  x_return_status
--    FND_API.G_RET_STS_SUCCESS if procedure succeeds
--    FND_API.G_RET_STS_ERROR if procedure fails
--    FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs

--  x_msg_data

--End of Comments
--------------------------------------------------------------------------------



PROCEDURE init_recreate_demand_flag(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2,
            p_cancel_reqs_flag IN OUT NOCOPY VARCHAR2,
            p_entity_dtl       IN OUT NOCOPY po_document_action_pvt.entity_dtl_rec_type_tbl,
            x_return_status    OUT NOCOPY VARCHAR2,
            x_msg_data         OUT NOCOPY VARCHAR2)
  IS

    d_api_version CONSTANT NUMBER := 1.0;
    d_api_name CONSTANT VARCHAR2(30) := 'init_recreate_demand_flag.';
    d_module CONSTANT VARCHAR2(100) := g_module_prefix||d_api_name;


    l_progress VARCHAR2(3) := '000' ;

  BEGIN
      -- Start standard API initialization
    IF FND_API.to_boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    IF NOT FND_API.compatible_api_call(d_api_version, p_api_version,
                                      d_api_name, g_pkg_name) THEN
      RAISE FND_API.g_exc_unexpected_error;
    END IF;


    IF g_debug_stmt THEN
      PO_DEBUG.debug_begin(d_module);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_cancel_reqs_flag', p_cancel_reqs_flag);
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_msg_data      := NULL;
    l_progress      := '001';

    -- for each entity id in the entity record table
    FOR i IN 1..p_entity_dtl.Count LOOP

      IF g_debug_stmt THEN
        PO_DEBUG.debug_var(d_module, l_progress, ' i', i);
        PO_DEBUG.debug_var(d_module, l_progress,'entity recreate_demand_flag', p_entity_dtl(i).recreate_demand_flag);

      END IF;

      IF p_entity_dtl(i).process_entity_flag = 'Y' THEN

        IF  p_cancel_reqs_flag ='Y' THEN
          p_entity_dtl(i).recreate_demand_flag := 'N';
        ELSE
          p_entity_dtl(i).recreate_demand_flag := 'Y';
        END IF;


        IF p_entity_dtl(i).recreate_demand_flag = 'Y' THEN

          l_progress := '006';

          IF is_document_cto_order(
               p_entity_dtl(i).doc_id,
               p_entity_dtl(i).document_type)
          THEN
            l_progress := '007';
            p_entity_dtl(i).recreate_demand_flag := 'N';

          ELSE
            l_progress := '008';
            -- If the document is s Complex PO/CLM PO and is partially rcvd/billed,
            -- then do not  recreate demand

            IF p_entity_dtl(i).document_type <> c_doc_type_RELEASE
               AND
                PO_COMPLEX_WORK_PVT.is_complex_work_po(
                 p_entity_dtl(i).doc_id)
               OR (po_clm_intg_grp.is_clm_po(
                     p_po_header_id => p_entity_dtl(i).doc_id) = 'Y')
            THEN
              l_progress := '009';
              IF isPartialRcvBilled(
                   p_api_version   => 1.0,
                   p_init_msg_list => FND_API.G_FALSE,
                   p_entity_level=> p_entity_dtl(i).entity_level,
                   p_document_type=> p_entity_dtl(i).document_type,
                   p_entity_id=>p_entity_dtl(i).entity_id)
              THEN
                l_progress := '010';
                p_entity_dtl(i).recreate_demand_flag := 'N';
              END IF;

            END IF; --if is_complex_work_po
          END IF; -- if is_document_cto_order

        ELSE
          l_progress := '011';

          IF NOT is_document_cto_order(
                   p_doc_id =>p_entity_dtl(i).doc_id,
                   p_doc_type =>p_entity_dtl(i).document_type)
          THEN

            l_progress := '012';
            -- If any shipemnt associated with currecnt entity being cancelled
            -- is a Drop Shipment with an updatable SO, then impose recreate demand.
            IF isDropShipWithUpdateableSO(
                 p_api_version   => 1.0,
                 p_init_msg_list => FND_API.G_FALSE,
                 p_entity_level=>p_entity_dtl(i).entity_level,
                 p_entity_id=>p_entity_dtl(i).entity_id,
                 p_document_type=>p_entity_dtl(i).document_type)
            THEN

              l_progress := '013';
              p_entity_dtl(i).recreate_demand_flag := 'Y';

            END IF; -- if  isDropShipWithUpdateableSO

          END IF; -- is_document_cto_order
        END IF; --  if recreate_demand_flag ='Y'
      END IF; --if process_entity_flag='Y'

      IF g_debug_stmt THEN
        PO_DEBUG.debug_var(
          d_module,
          l_progress,
          'entity recreate_demand_flag',
          p_entity_dtl(i).recreate_demand_flag);
      END IF;

    END LOOP;

  EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_msg_data := FND_MSG_PUB.GET(
                     P_MSG_INDEX => FND_MSG_PUB.G_LAST,
                     P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.add_exc_msg(g_module_prefix, d_api_name||':'||l_progress||':'||SQLCODE||':'||SQLERRM);

    WHEN FND_API.G_EXC_ERROR THEN
      x_msg_data := FND_MSG_PUB.GET(
                      P_MSG_INDEX => FND_MSG_PUB.G_LAST,
                      P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.add_exc_msg(g_module_prefix, d_api_name||':'||l_progress||':'||SQLCODE||':'||SQLERRM);

    WHEN OTHERS THEN
      IF (G_DEBUG_UNEXP) THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
	FND_LOG.STRING(
          FND_LOG.LEVEL_UNEXPECTED,
          d_module || '.OTHERS_EXCEPTION',
          'EXCEPTION: LOCATION IS ' || l_progress || ' SQL CODE IS '||SQLCODE);
	  END IF;
      END IF;
      FND_MSG_PUB.add_exc_msg(g_module_prefix, d_api_name||':'||l_progress||':'||SQLCODE||':'||SQLERRM);

      x_msg_data := FND_MSG_PUB.GET(
                      P_MSG_INDEX => FND_MSG_PUB.G_LAST,
                      P_ENCODED => 'F');
      x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;

END init_recreate_demand_flag;

--------------------------------------------------------------------------------
--Start of Comments
--Name: denormPlannedPOQty

--Function:
--  Updates the Qty Recvd and Qty billed of schedule releases to Planned Po
--  shipemnts/Distributions.This way we can treat the cancellation as a regular
--  standard PO case.
--
--
--Parameters:
--IN:
--  p_cancel_reqs_flag
--  p_key

--IN OUT:

-- OUT:
--  x_return_status
--    FND_API.G_RET_STS_SUCCESS if procedure succeeds
--    FND_API.G_RET_STS_ERROR if procedure fails
--    FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs



--End of Comments
--------------------------------------------------------------------------------

PROCEDURE denormPlannedPOQty(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2,
            entity_dtl_tbl  IN po_document_action_pvt.entity_dtl_rec_type_tbl,
            p_key           IN po_session_gt.key%TYPE,
            x_return_status OUT NOCOPY VARCHAR2)
  IS

    d_api_version CONSTANT NUMBER := 1.0;
    d_api_name CONSTANT VARCHAR2(30) := 'denormPlannedPOQty.';
    d_module CONSTANT VARCHAR2(100)  := g_module_prefix||d_api_name;
    l_progress VARCHAR2(3)           := '000' ;

 BEGIN
  -- Start standard API initialization
  IF FND_API.to_boolean(p_init_msg_list) THEN
     FND_MSG_PUB.initialize;
  END IF;

  IF NOT FND_API.compatible_api_call(d_api_version, p_api_version,
                                      d_api_name, g_pkg_name) THEN
    RAISE FND_API.g_exc_unexpected_error;
  END IF;


  IF g_debug_stmt THEN
    PO_DEBUG.debug_begin(d_module);
    PO_DEBUG.debug_var(d_module, l_progress, 'p_key', p_key);
  END IF;

  l_progress := '001' ;

  UPDATE  po_line_locations POLL
  SET     (POLL.quantity_billed, POLL.quantity_received)  =
            (SELECT
               SUM( NVL(RELS.quantity_billed, 0) ),
               SUM( NVL(RELS.quantity_received, 0) )
             FROM
               PO_LINE_LOCATIONS RELS
             WHERE
               RELS.source_shipment_id = POLL.line_location_id )
  WHERE   POLL.shipment_type = 'PLANNED'
  AND     POLL.line_location_id IN
            (SELECT num1
             FROM   po_session_gt
             WHERE  char3 = c_entity_level_SHIPMENT
                    AND char2 = c_doc_subtype_PLANNED
            UNION
             SELECT line_location_id
             FROM   po_line_locations,
                    po_session_gt
             WHERE  num1 = po_line_id
                    AND char3 = c_entity_level_LINE
                    AND char2 = c_doc_subtype_PLANNED
                    AND NVL(cancel_flag, 'N')     = 'N'
                    AND NVL(closed_code, 'OPEN') <> 'FINALLY CLOSED'
            UNION
             SELECT line_location_id
             FROM   po_line_locations,
                    po_session_gt
             WHERE  num1 = po_header_id
                    AND char3 = c_entity_level_HEADER
                    AND char2  = c_doc_subtype_PLANNED
                    AND NVL(cancel_flag, 'N') = 'N'
                    AND NVL(closed_code, 'OPEN') <> 'FINALLY CLOSED'
           );

  IF g_debug_stmt THEN
    PO_DEBUG.debug_var(d_module, l_progress, 'Rows Updated the PO line locations table', SQL%ROWCOUNT);
  END IF;

  l_progress := '002' ;

  UPDATE PO_DISTRIBUTIONS_ALL POD
     SET (POD.quantity_billed,POD.quantity_delivered) =
            ( SELECT SUM( NVL(RELD.quantity_billed, 0) ),
                     SUM( NVL(RELD.quantity_delivered, 0) )
                FROM PO_DISTRIBUTIONS RELD
               WHERE RELD.source_distribution_id = POD.po_distribution_id )
   WHERE POD.line_location_id IN
             ( SELECT num1
               FROM   po_session_gt
               WHERE  char3= c_entity_level_SHIPMENT
                      AND char2 = c_doc_subtype_PLANNED
                      AND char5 = 'Y'
             UNION
               SELECT line_location_id
               FROM   po_line_locations,
                      po_session_gt
               WHERE  num1 = po_line_id
                      AND shipment_type = 'PLANNED'
                      AND char3 = c_entity_level_LINE
                      AND char2 = c_doc_subtype_PLANNED
                      AND NVL(cancel_flag, 'N') = 'N'
                      AND char5 = 'Y'
                      AND NVL(closed_code, 'OPEN') <> 'FINALLY CLOSED'
             UNION
              SELECT line_location_id
              FROM   po_line_locations,
                     po_session_gt
              WHERE  num1 = po_header_id
                     AND shipment_type = 'PLANNED'
                     AND char3 = c_entity_level_HEADER
                     AND char2 = c_doc_subtype_PLANNED
                     AND NVL(cancel_flag, 'N') = 'N'
                     AND char5 = 'Y'
                     AND NVL(closed_code, 'OPEN') <> 'FINALLY CLOSED') ;

  IF g_debug_stmt THEN
    PO_DEBUG.debug_var(d_module, l_progress, 'Rows Updated the PO Distributions table', SQL%ROWCOUNT);
  END IF;

 EXCEPTION
   WHEN FND_API.g_exc_error THEN
     FND_MSG_PUB.add_exc_msg(g_module_prefix, d_api_name||':'||l_progress||':'||SQLCODE||':'||SQLERRM);
     x_return_status := FND_API.g_ret_sts_error;
   WHEN FND_API.g_exc_unexpected_error THEN
     FND_MSG_PUB.add_exc_msg(g_module_prefix, d_api_name||':'||l_progress||':'||SQLCODE||':'||SQLERRM);
     x_return_status := FND_API.g_ret_sts_unexp_error;
   WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg(g_module_prefix, d_api_name||':'||l_progress||':'||SQLCODE||':'||SQLERRM);
    x_return_status := FND_API.g_ret_sts_unexp_error;
END denormPlannedPOQty;

--------------------------------------------------------------------------------
--Start of Comments
--Name: update_dist_cancel

--Function:
--
--  Updates the Cancel details on PO Distribution if the entity being canceled is
--  PO/Release Header, PO Line, PO/Release Shipment

--  Updates the following columns :
--   Before Funds Control call
--   -------------------------
--   quantity_cancelled
--   amount_cancelled
--
--   Afer Funds Control Call
--   -------------------------
--   gl_cancelled_date
--   req_distribution_id
--   last_update_date
--   last_updated_by
--   last_update_login
--
--Parameters:
--IN:
--  p_fc_level
--  p_action_date
--  p_entity_level
--  p_entity_id
--  p_document_type
--  p_recreate_demand
--  p_user_id
--  p_login_id


--IN OUT:

-- OUT:
--  x_return_status
--    FND_API.G_RET_STS_SUCCESS if procedure succeeds
--    FND_API.G_RET_STS_ERROR if procedure fails
--    FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs



--End of Comments
--------------------------------------------------------------------------------

PROCEDURE update_dist_cancel(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2,
            p_fc_level        IN VARCHAR2,
            p_action_date     IN DATE,
            p_entity_level    IN VARCHAR2,
            p_entity_id       IN NUMBER,
            p_document_type   IN VARCHAR2,
            p_recreate_demand IN VARCHAR2,
            p_user_id         IN po_lines.last_updated_by%TYPE,
            p_login_id        IN po_lines.last_update_login%TYPE,
            x_return_status   OUT NOCOPY VARCHAR2)
  IS

    d_api_name CONSTANT VARCHAR2(30) := 'update_dist_cancel';
    d_api_version CONSTANT NUMBER := 1.0;
    d_module   CONSTANT VARCHAR2(100) := g_module_prefix||d_api_name;

    l_progress VARCHAR2(3)            := '000' ;

  BEGIN
    -- Start standard API initialization
    IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    IF NOT FND_API.compatible_api_call(d_api_version, p_api_version,
                                        d_api_name, g_pkg_name) THEN
      RAISE FND_API.g_exc_unexpected_error;
    END IF;


    IF g_debug_stmt THEN
      PO_DEBUG.debug_begin(d_module);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_action_date', p_action_date);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_fc_level', p_fc_level);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_entity_id', p_entity_id);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_document_type', p_document_type);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_entity_level', p_entity_level);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_recreate_demand', p_recreate_demand);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_user_id', p_user_id);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_login_id', p_login_id);
    END IF;

    IF p_fc_level = c_before_FC THEN

      l_progress := '001' ;

      UPDATE
        PO_DISTRIBUTIONS_ALL POD
      SET
        pod.quantity_cancelled = pod.quantity_ordered-greatest(
                                                        NVL(quantity_delivered,0),
                                                        NVL(quantity_financed,0),
                                                        NVL(quantity_billed,0)),
        pod.amount_cancelled   = pod.amount_ordered-greatest(
                                                      NVL(amount_delivered,0),
                                                      NVL(amount_financed,0),
                                                      NVL(amount_billed,0)),
        pod.last_update_date   = SYSDATE                                                                                                          ,
        pod.last_updated_by    = p_user_id                                                                                                        ,
        pod.last_update_login  = p_login_id
      WHERE pod.line_location_id IN
            ( SELECT line_location_id
              FROM   po_line_locations
              WHERE  line_location_id = p_entity_id
                    AND  p_entity_level = c_entity_level_SHIPMENT
            UNION ALL
              SELECT line_location_id
              FROM   po_line_locations
              WHERE  po_line_id = p_entity_id
                     AND p_entity_level = c_entity_level_LINE
            UNION ALL
              SELECT line_location_id
              FROM   po_line_locations
              WHERE  po_header_id = p_entity_id
                     AND p_document_type <> c_doc_type_RELEASE
                     AND p_entity_level = c_entity_level_HEADER
            UNION ALL
              SELECT line_location_id
              FROM   po_line_locations
              WHERE  po_release_id = p_entity_id
                     AND p_document_type = c_doc_type_RELEASE
                     AND p_entity_level = c_entity_level_HEADER);




  ELSE

    l_progress := '002' ;

    UPDATE PO_DISTRIBUTIONS_ALL POD
    SET   pod.gl_cancelled_date   = p_action_date,
          pod.req_distribution_id = Decode(
                                      p_recreate_demand,
                                      'Y',
                                      DECODE(
                                        greatest(
                                          NVL(pod.quantity_delivered, 0),
                                          NVL(pod.quantity_billed, 0)),
                                        0,
                                        NULL,
                                        pod.req_distribution_id),
                                      pod.req_distribution_id),
          pod.last_update_date  = SYSDATE  ,
          pod.last_updated_by   = p_user_id,
          pod.last_update_login = p_login_id
    WHERE pod.line_location_id IN
          ( SELECT line_location_id
            FROM   po_line_locations
            WHERE  line_location_id = p_entity_id
                   AND  p_entity_level = c_entity_level_SHIPMENT
          UNION ALL
            SELECT line_location_id
            FROM   po_line_locations
            WHERE  po_line_id = p_entity_id
                   AND p_entity_level = c_entity_level_LINE
          UNION ALL
            SELECT line_location_id
            FROM   po_line_locations
            WHERE  po_header_id = p_entity_id
                   AND p_document_type <> c_doc_type_RELEASE
                   AND p_entity_level = c_entity_level_HEADER
          UNION ALL
            SELECT line_location_id
            FROM   po_line_locations
            WHERE  po_release_id = p_entity_id
                   AND p_document_type = c_doc_type_RELEASE
                   AND p_entity_level = c_entity_level_HEADER);


  END IF;

  IF g_debug_stmt THEN
    PO_DEBUG.debug_var(d_module, l_progress, 'Rows Updated in PO Distributions table', SQL%ROWCOUNT);
  END IF;

EXCEPTION

WHEN FND_API.g_exc_error THEN
  x_return_status := FND_API.g_ret_sts_error;
  FND_MSG_PUB.add_exc_msg(g_module_prefix, d_api_name||':'||l_progress||':'||SQLCODE||':'||SQLERRM);
WHEN FND_API.g_exc_unexpected_error THEN
    x_return_status := FND_API.g_ret_sts_unexp_error;
    FND_MSG_PUB.add_exc_msg(g_module_prefix, d_api_name||':'||l_progress||':'||SQLCODE||':'||SQLERRM);
WHEN OTHERS THEN
  x_return_status := FND_API.g_ret_sts_unexp_error;
  FND_MSG_PUB.add_exc_msg(g_module_prefix, d_api_name||':'||l_progress||':'||SQLCODE||':'||SQLERRM);
END update_dist_cancel;


--------------------------------------------------------------------------------
--Start of Comments
--Name: update_ship_cancel

--Function:
--
--  Updates the Cancel details on PO Shipments if the entity being canceled is
--  PO/Release Header, PO Line, PO/Release Shipment.

--  Updates the following columns :
--   Before Funds Control call
--   -------------------------
--    cancel_flag ='I'
--    cancel_date
--    cancel_reason
--    cancelled_by
--    last_update_date
--    last_updated_by
--    last_update_login
--    quantity_cancelled  - sum(Distributions cancelled quantity)
--    amount_cancelled    - sum(Distributions cancelled amount)
--
--   Afer Funds Control Call
--   -------------------------
--    cancel_flag ='Y'

--
--Parameters:
--IN:
--  p_fc_level
--  p_action_date
--  p_entity_level
--  p_entity_id
--  p_action_date
--  p_document_type
--  p_recreate_demand
--  p_user_id
--  p_login_id


--IN OUT:

-- OUT:
--  x_return_status
--    FND_API.G_RET_STS_SUCCESS if procedure succeeds
--    FND_API.G_RET_STS_ERROR if procedure fails
--    FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs



--End of Comments
--------------------------------------------------------------------------------

PROCEDURE update_ship_cancel(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2,
            p_fc_level      IN VARCHAR2,
            p_cancel_reason IN VARCHAR2,
            p_entity_level  IN VARCHAR2,
            p_entity_id     IN NUMBER,
            p_action_date   IN DATE,
            p_document_type IN VARCHAR2,
            p_user_id       IN po_lines.last_updated_by%TYPE,
            p_login_id      IN po_lines.last_update_login%TYPE,
            x_return_status IN OUT NOCOPY VARCHAR2)
  IS

  d_api_name CONSTANT VARCHAR2(30) := 'update_ship_cancel';
  d_api_version CONSTANT NUMBER := 1.0;
  d_module   CONSTANT VARCHAR2(100) := g_module_prefix||d_api_name;

  l_progress VARCHAR2(3)            := '000' ;
  l_emp_id   NUMBER                 := FND_GLOBAL.employee_id;
  l_request_id PO_HEADERS.request_id%TYPE := fnd_global.conc_request_id;

 BEGIN
    -- Start standard API initialization
    IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    IF NOT FND_API.compatible_api_call(d_api_version, p_api_version,
                                        d_api_name, g_pkg_name) THEN
      RAISE FND_API.g_exc_unexpected_error;
    END IF;



    IF g_debug_stmt THEN
      PO_DEBUG.debug_begin(d_module);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_cancel_reason', p_cancel_reason);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_fc_level', p_fc_level);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_entity_id', p_entity_id);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_document_type', p_document_type);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_entity_level', p_entity_level);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_user_id', p_user_id);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_login_id', p_login_id);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_action_date', p_action_date);

    END IF;



    IF p_fc_level = c_before_FC THEN

      l_progress := '001' ;

      UPDATE po_line_locations POLL
      SET    POLL.cancel_flag        = 'I'            ,
             --Bug 16575765: CANCEL_DATE is always stamped(SHIPMENT) as sysdate.
             --POLL.cancel_date        = p_action_date        ,
             POLL.cancel_date        = SYSDATE              ,
             POLL.cancel_reason      = p_cancel_reason,
             POLL.cancelled_by       = l_emp_id       ,
             POLL.last_update_date   = SYSDATE        ,
             POLL.last_updated_by    = p_user_id      ,
             POLL.last_update_login  = p_login_id     ,
             POLL.request_id         = DECODE(l_request_id,
                                         NULL,
                                         request_id,
                                         -1,
                                         request_id,
                                         l_request_id) ,
             POLL.quantity_cancelled = (SELECT SUM(NVL(POD.quantity_cancelled,0))
                                        FROM   PO_DISTRIBUTIONS_ALL POD
                                        WHERE  POD.line_location_id=POLL.line_location_id),
             POLL.amount_cancelled  = (SELECT SUM(NVL(POD.amount_cancelled, 0))
                                       FROM   PO_DISTRIBUTIONS_ALL POD
                                       WHERE  POD.line_location_id=POLL.line_location_id)
      WHERE  NVL(poll.cancel_flag, 'N')         = 'N'
             AND NVL(poll.closed_code, 'OPEN') <> 'FINALLY CLOSED'
             AND POLL.line_location_id IN
                   ( SELECT line_location_id
                     FROM   po_line_locations
                     WHERE  line_location_id = p_entity_id
                            AND  p_entity_level = c_entity_level_SHIPMENT
                   UNION ALL
                     SELECT line_location_id
                     FROM   po_line_locations
                     WHERE  po_line_id = p_entity_id
                            AND p_entity_level = c_entity_level_LINE
                   UNION ALL
                     SELECT line_location_id
                     FROM   po_line_locations
                     WHERE  po_header_id = p_entity_id
                            AND p_document_type <> c_doc_type_RELEASE
                            AND p_entity_level = c_entity_level_HEADER
                   UNION ALL
                     SELECT line_location_id
                     FROM   po_line_locations
                     WHERE  po_release_id = p_entity_id
                            AND p_document_type = c_doc_type_RELEASE
                            AND p_entity_level = c_entity_level_HEADER);


  ELSE

    l_progress := '002' ;

    UPDATE po_line_locations POLL
      SET    POLL.cancel_flag = 'Y'
      WHERE  NVL(poll.cancel_flag, 'N')         = 'I'
             AND NVL(poll.closed_code, 'OPEN') <> 'FINALLY CLOSED'
             AND POLL.line_location_id IN
                   ( SELECT line_location_id
                     FROM   po_line_locations
                     WHERE  line_location_id = p_entity_id
                            AND  p_entity_level = c_entity_level_SHIPMENT
                   UNION ALL
                     SELECT line_location_id
                     FROM   po_line_locations
                     WHERE  po_line_id = p_entity_id
                            AND p_entity_level = c_entity_level_LINE
                   UNION ALL
                     SELECT line_location_id
                     FROM   po_line_locations
                     WHERE  po_header_id = p_entity_id
                            AND p_document_type <> c_doc_type_RELEASE
                            AND p_entity_level = c_entity_level_HEADER
                   UNION ALL
                     SELECT line_location_id
                     FROM   po_line_locations
                     WHERE  po_release_id = p_entity_id
                            AND p_document_type = c_doc_type_RELEASE
                            AND p_entity_level = c_entity_level_HEADER);


  END IF;


  IF g_debug_stmt THEN
    PO_DEBUG.debug_var(
      d_module,
      l_progress,
      'Rows Updated in PO LineLocations table',
       SQL%ROWCOUNT);
  END IF;


  EXCEPTION
    WHEN FND_API.g_exc_error THEN
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.add_exc_msg(g_module_prefix, d_api_name||':'||l_progress||':'||SQLCODE||':'||SQLERRM);
    WHEN FND_API.g_exc_unexpected_error THEN
      x_return_status := FND_API.g_ret_sts_unexp_error;
      FND_MSG_PUB.add_exc_msg(g_module_prefix, d_api_name||':'||l_progress||':'||SQLCODE||':'||SQLERRM);
    WHEN OTHERS THEN
      x_return_status := FND_API.g_ret_sts_unexp_error;
      FND_MSG_PUB.add_exc_msg(g_module_prefix, d_api_name||':'||l_progress||':'||SQLCODE||':'||SQLERRM);

END update_ship_cancel;



--------------------------------------------------------------------------------
--Start of Comments
--Name: update_line_qty_price_amt

--Function:
--
--  Updates the Quantity, Price and Amount on the line when its shipment
--   is canceled
--
--Parameters:
--  IN:
--    p_ship_id

--  IN OUT:

--   OUT:
--    x_return_status
--      FND_API.G_RET_STS_SUCCESS if procedure succeeds
--      FND_API.G_RET_STS_ERROR if procedure fails
--      FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs

--End of Comments
--------------------------------------------------------------------------------

PROCEDURE update_line_qty_price_amt(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2,
            p_ship_id IN NUMBER,
            x_return_status OUT NOCOPY VARCHAR2)
  IS

  d_api_version CONSTANT NUMBER := 1.0;
  d_api_name CONSTANT VARCHAR2(30) := 'update_line_qty_price_amt';
  d_module   CONSTANT VARCHAR2(100) := g_module_prefix||d_api_name;

  l_progress VARCHAR2(3)            := '000' ;
  l_emp_id   NUMBER                 := FND_GLOBAL.employee_id;

  BEGIN
    -- Start standard API initialization
    IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    IF NOT FND_API.compatible_api_call(d_api_version, p_api_version,
                                        d_api_name, g_pkg_name) THEN
      RAISE FND_API.g_exc_unexpected_error;
    END IF;


    IF g_debug_stmt THEN
      PO_DEBUG.debug_begin(d_module);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_ship_id', p_ship_id);
    END IF;

    l_progress := '001' ;

    UPDATE po_lines pol
    SET    pol.quantity =(SELECT SUM(
                                   NVL(poll.quantity,0)
                                   - NVL(poll.quantity_cancelled, 0))
                          FROM   po_line_locations POLL
                          WHERE  poll.po_line_id = pol.po_line_id
                                 AND poll.shipment_type IN ('STANDARD','PLANNED'))

    WHERE   pol.po_line_id=(SELECT po_line_id
                            FROM   po_line_locations
                            WHERE  line_location_id = p_ship_id)
            AND pol.order_type_lookup_code IN ('QUANTITY','AMOUNT')
            AND NOT EXISTS (SELECT
                              'PO Line has Qty Milestone Pay Items'
                            FROM  po_line_locations poll2
                            WHERE poll2.po_line_id=pol.po_line_id
                                  AND poll2.payment_type IS NOT NULL);

    IF g_debug_stmt THEN
      PO_DEBUG.debug_var(d_module, l_progress, 'Quanity Updated in PO Lines table', SQL%ROWCOUNT);
    END IF;


    l_progress := '002' ;

    -- For Qty-based lines, only do the update of line price for the
    -- Complex Work Qty Milestone case.
    -- Cancellation of normal PO shipment does not change Line Price

    UPDATE po_lines pol
   	SET    pol.unit_price =
             (SELECT SUM(poll.price_override)
              FROM   po_line_locations POLL
              WHERE  poll.po_line_id = pol.po_line_id
                     AND   poll.shipment_type = 'STANDARD'
                     AND   nvl(poll.cancel_flag, 'N') = 'N'
                     AND   nvl(poll.closed_code, 'OPEN') <> 'FINALLY CLOSED')

    WHERE  pol.po_line_id=(SELECT po_line_id
                           FROM   po_line_locations
                           WHERE  line_location_id= p_ship_id)
   	       AND pol.order_type_lookup_code IN ('QUANTITY', 'AMOUNT')
   	       AND EXISTS
   	             (SELECT 'PO Line has open Qty Milestone Pay Items'
                  FROM   po_line_locations poll2
                  WHERE  poll2.po_line_id = pol.po_line_id
                         AND poll2.payment_type IS NOT NULL
                         AND nvl(poll2.cancel_flag, 'N') = 'N'
                         AND nvl(poll2.closed_code, 'OPEN') <> 'FINALLY CLOSED');



   IF g_debug_stmt THEN
    PO_DEBUG.debug_var(d_module, l_progress, 'Price  Updated in PO Lines table', SQL%ROWCOUNT);
   END IF;


   l_progress := '003' ;

   -- For Services lines, we can have a mix
   --  of Quantity and  Amount based line locations (pay item case).
   -- The logic below will also work for the non-mixed case, as
   -- exists with non-Complex Work shipments

    UPDATE po_lines pol
   	SET    pol.amount= (SELECT SUM(DECODE(
                                    POLL.amount,
                                    NULL,
                                    --Quantity or Amount Line Locations
                                    ((NVL(poll.quantity,0) - NVL(poll.quantity_cancelled,0))
                                      * POLL.price_override),
                                    -- Fixed Price or Rate Line Locations
                                    (NVL(poll.amount, 0) - NVL(poll.amount_cancelled,0))
                                  ))
   	                   FROM   po_line_locations POLL
   	                   WHERE  poll.po_line_id = pol.po_line_id
                       AND    poll.shipment_type IN ('STANDARD','PLANNED'))

    WHERE  pol.po_line_id =(SELECT po_line_id
                            FROM   po_line_locations
                            WHERE  line_location_id= p_ship_id)
    AND    pol.order_type_lookup_code in ('FIXED PRICE', 'RATE');


  IF g_debug_stmt THEN
    PO_DEBUG.debug_var(d_module, l_progress, 'Amount Updated in PO Lines table', SQL%ROWCOUNT);
  END IF;



 EXCEPTION
   WHEN FND_API.g_exc_error THEN
     x_return_status := FND_API.g_ret_sts_error;
     FND_MSG_PUB.add_exc_msg(g_module_prefix, d_api_name||':'||l_progress||':'||SQLCODE||':'||SQLERRM);
   WHEN FND_API.g_exc_unexpected_error THEN
     x_return_status := FND_API.g_ret_sts_unexp_error;
     FND_MSG_PUB.add_exc_msg(g_module_prefix, d_api_name||':'||l_progress||':'||SQLCODE||':'||SQLERRM);
   WHEN OTHERS THEN
     x_return_status := FND_API.g_ret_sts_unexp_error;
     FND_MSG_PUB.add_exc_msg(g_module_prefix, d_api_name||':'||l_progress||':'||SQLCODE||':'||SQLERRM);

END update_line_qty_price_amt;


--------------------------------------------------------------------------------
--Start of Comments
--Name: update_line_cancel

--Function:
--
--  Updates the Cancel details on PO Lines if the entity being canceled is
--  PO/PA Header, PO/PA Line

--  Updates the following columns :
--    Before Funds Control call
--    -------------------------
--     cancel_flag ='I'
--     cancel_date
--     cancel_reason
--     cancelled_by
--     last_update_date
--     last_updated_by
--     last_update_login
--     quantity - sum(Shipments Open Quanity i.e. Quantity-Quantity Cancelled)
--     amount    - sum(Shipments Open Quanity i.e. Amount-Amount Cancelled)
--
--   Afer Funds Control Call
--   -------------------------
--     cancel_flag ='Y'

--Parameters:
--  IN:
--   p_fc_level
--   p_cancel_reason
--   p_entity_level
--   p_entity_id
--   p_action_date
--   p_user_id
--   p_login_id
--
--  IN OUT:
--
--   OUT:
--    x_return_status
--      FND_API.G_RET_STS_SUCCESS if procedure succeeds
--      FND_API.G_RET_STS_ERROR if procedure fails
--      FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs

--End of Comments
--------------------------------------------------------------------------------


PROCEDURE update_line_cancel(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2,
            p_fc_level      IN VARCHAR2,
            p_cancel_reason IN VARCHAR2,
            p_entity_level  IN VARCHAR2,
            p_entity_id     IN NUMBER,
            p_action_date   IN DATE,
            p_user_id       IN po_lines.last_updated_by%TYPE,
            p_login_id      IN po_lines.last_update_login%TYPE,
            p_note_to_vendor IN VARCHAR2,
            x_return_status OUT NOCOPY VARCHAR2)
  IS

    d_api_name CONSTANT VARCHAR2(30) := 'update_line_cancel';
    d_api_version CONSTANT NUMBER := 1.0;
    d_module   CONSTANT VARCHAR2(100) := g_module_prefix||d_api_name;

    l_progress VARCHAR2(3)            := '000' ;
    l_emp_id   NUMBER                 := FND_GLOBAL.employee_id;
    l_request_id PO_HEADERS.request_id%TYPE := fnd_global.conc_request_id;

  BEGIN
    -- Start standard API initialization
    IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    IF NOT FND_API.compatible_api_call(d_api_version, p_api_version,
                                        d_api_name, g_pkg_name) THEN
      RAISE FND_API.g_exc_unexpected_error;
    END IF;


    IF g_debug_stmt THEN
      PO_DEBUG.debug_begin(d_module);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_cancel_reason', p_cancel_reason);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_fc_level', p_fc_level);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_entity_id', p_entity_id);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_entity_level', p_entity_level);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_user_id', p_user_id);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_login_id', p_login_id);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_action_date', p_action_date);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_note_to_vendor', p_note_to_vendor);

    END IF;




   IF p_fc_level = c_before_FC THEN

     l_progress := '001' ;

     UPDATE po_lines pol
     SET    pol.cancel_flag = 'I',
            --Bug 16575765: CANCEL_DATE is always stamped(LINE) as sysdate.
            --pol.cancel_date = p_action_date,
            pol.cancel_date = SYSDATE,
            pol.cancel_reason = p_cancel_reason,
            pol.cancelled_by = l_emp_id,
            pol.last_update_date = sysdate,
            pol.last_updated_by = p_user_id,
            pol.last_update_login = p_login_id,
            pol.note_to_vendor =p_note_to_vendor ,
            pol.request_id     = DECODE(l_request_id,
                                    NULL,
                                    request_id,
                                    -1,
                                    request_id,
                                    l_request_id) ,

            pol.quantity =
              DECODE(pol.quantity,
                NULL,
                pol.quantity,
                (SELECT SUM(NVL(poll.quantity,0) -NVL(poll.quantity_cancelled,0))
        	       FROM  po_line_locations POLL
                 WHERE poll.po_line_id = pol.po_line_id
                       AND poll.shipment_type IN('STANDARD','PLANNED'))
              ),
            pol.amount =
              DECODE(pol.amount,
                NULL,
                pol.amount,
                (SELECT SUM(DECODE(POLL.amount,
                              NULL,
                              ((NVL(poll.quantity,0) -NVL(poll.quantity_cancelled,0))
                                * POLL.price_override),
                              (NVL(poll.amount, 0) -NVL(poll.amount_cancelled,0))
                           )
                        )
                FROM   po_line_locations POLL
                WHERE  poll.po_line_id = pol.po_line_id
                       AND    poll.shipment_type IN ('STANDARD','PLANNED')) )
     WHERE  nvl(pol.cancel_flag,'N') = 'N'
            AND nvl(pol.closed_code,'OPEN') <> 'FINALLY CLOSED'
        	  AND pol.po_line_id IN (
                  SELECT po_line_id
                  FROM   po_lines
                  WHERE  po_line_id= p_entity_id
                         AND p_entity_level=c_entity_level_LINE
                 UNION ALL
                  SELECT po_line_id
                   FROM  po_lines
                   WHERE po_header_id= p_entity_id
                         AND p_entity_level=c_entity_level_HEADER);

   ELSE
     l_progress := '002' ;

     UPDATE po_lines POl
     SET    pol.cancel_flag = 'Y'
     WHERE  nvl(pol.cancel_flag,'N') = 'I'
            AND  nvl(pol.closed_code, 'OPEN') <> 'FINALLY CLOSED'
 	          AND pol.po_line_id IN (
                  SELECT po_line_id
                  FROM   po_lines
                  WHERE  po_line_id= p_entity_id
                         AND p_entity_level=c_entity_level_LINE
                 UNION ALL
                  SELECT po_line_id
                   FROM  po_lines
                   WHERE po_header_id= p_entity_id
                         AND p_entity_level=c_entity_level_HEADER);


   END IF;


  IF g_debug_stmt THEN
    PO_DEBUG.debug_var(d_module, l_progress, 'Rows Updated in PO Lines table', SQL%ROWCOUNT);
  END IF;


  EXCEPTION
    WHEN FND_API.g_exc_error THEN
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.add_exc_msg(g_module_prefix, d_api_name||':'||l_progress||':'||SQLCODE||':'||SQLERRM);
    WHEN FND_API.g_exc_unexpected_error THEN
      x_return_status := FND_API.g_ret_sts_unexp_error;
      FND_MSG_PUB.add_exc_msg(g_module_prefix, d_api_name||':'||l_progress||':'||SQLCODE||':'||SQLERRM);
    WHEN OTHERS THEN
      x_return_status := FND_API.g_ret_sts_unexp_error;
      FND_MSG_PUB.add_exc_msg(g_module_prefix, d_api_name||':'||l_progress||':'||SQLCODE||':'||SQLERRM);

END update_line_cancel;

--------------------------------------------------------------------------------
--Start of Comments
--Name: update_po_header_cancel

--Function:
--
-- Updates the Cancel details on PO Headers if the entity being canceled is
-- PO/PA Header
-- Updates the following columns :
--
--    Before Funds Control call
--    -------------------------
--    cancel_flag ='I'
--    last_update_date
--    last_updated_by
--    last_update_login
--    acceptance_required_flag
--
--    Afer Funds Control Call
--    -------------------------
--     cancel_flag ='Y'
--     closed_code = 'CLOSED'
--     closed_date = sysdate

--Parameters:
--  IN:
--   p_fc_level
--   p_entity_id
--   p_user_id
--   p_login_id
--   p_action_date
--
--  IN OUT:
--
--   OUT:
--    x_return_status
--      FND_API.G_RET_STS_SUCCESS if procedure succeeds
--      FND_API.G_RET_STS_ERROR if procedure fails
--      FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs

--End of Comments
--------------------------------------------------------------------------------


PROCEDURE update_po_header_cancel(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2,
            p_fc_level      IN VARCHAR2,
            p_entity_id     IN NUMBER,
            p_action_date    IN DATE,
            p_user_id       IN po_lines.last_updated_by%TYPE,
            p_login_id      IN po_lines.last_update_login%TYPE,
            p_note_to_vendor IN VARCHAR2,
            x_return_status OUT NOCOPY VARCHAR2)
  IS

    d_api_name CONSTANT VARCHAR2(30) := 'update_po_header_cancel';
    d_api_version CONSTANT NUMBER := 1.0;
    d_module   CONSTANT VARCHAR2(100) := g_module_prefix||d_api_name;

    l_progress VARCHAR2(3)            := '000' ;
    l_emp_id   NUMBER                 := FND_GLOBAL.employee_id;
    l_request_id PO_HEADERS.request_id%TYPE := fnd_global.conc_request_id;

  BEGIN
    -- Start standard API initialization
    IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    IF NOT FND_API.compatible_api_call(d_api_version, p_api_version,
                                        d_api_name, g_pkg_name) THEN
      RAISE FND_API.g_exc_unexpected_error;
    END IF;


    IF g_debug_stmt THEN
      PO_DEBUG.debug_begin(d_module);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_fc_level', p_fc_level);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_entity_id', p_entity_id);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_user_id', p_user_id);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_login_id', p_login_id);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_note_to_vendor', p_note_to_vendor);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_action_date', p_action_date);

    END IF;


    IF p_fc_level = c_before_FC THEN

      l_progress := '001' ;

      UPDATE po_headers poh
      SET    poh.cancel_flag       = 'I'      ,
             poh.last_update_date  = SYSDATE  ,
             poh.note_to_vendor    =p_note_to_vendor ,
             poh.last_updated_by   = p_user_id,
             poh.last_update_login = p_login_id,
             poh.acceptance_required_flag =NULL,
             poh.request_id     = DECODE(l_request_id,
                                    NULL,
                                    request_id,
                                    -1,
                                    request_id,
                                    l_request_id)

      WHERE  poh.po_header_id= p_entity_id;


    ELSE
      l_progress := '002' ;


      UPDATE po_headers poh
      SET    poh.cancel_flag           = 'Y'     ,
             poh.closed_code           = 'CLOSED',
             --Bug 16575765: CLOSED_DATE is always stamped(HEADER) as sysdate.
             --poh.closed_date           = p_action_date
             poh.closed_date = sysdate
      WHERE  NVL(poh.cancel_flag, 'N') = 'I'
             AND poh.po_header_id= p_entity_id;

    END IF;


    IF g_debug_stmt THEN
      PO_DEBUG.debug_var(d_module, l_progress, 'Rows Updated in PO Headers table', SQL%ROWCOUNT);
    END IF;


  EXCEPTION
    WHEN FND_API.g_exc_error THEN
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.add_exc_msg(g_module_prefix, d_api_name||':'||l_progress||':'||SQLCODE||':'||SQLERRM);
    WHEN FND_API.g_exc_unexpected_error THEN
      x_return_status := FND_API.g_ret_sts_unexp_error;
      FND_MSG_PUB.add_exc_msg(g_module_prefix, d_api_name||':'||l_progress||':'||SQLCODE||':'||SQLERRM);
    WHEN OTHERS THEN
      x_return_status := FND_API.g_ret_sts_unexp_error;
      FND_MSG_PUB.add_exc_msg(g_module_prefix, d_api_name||':'||l_progress||':'||SQLCODE||':'||SQLERRM);

  END update_po_header_cancel;


--------------------------------------------------------------------------------
--Start of Comments
--Name: update_rel_header_cancel

--Function:
--
--   Updates the Cancel details on PO Releases if the entity being canceled is
--   Release Header
--   Updates the following columns :
--
--    Before Funds Control call
--    -------------------------
--    cancel_flag ='I'
--    cancel_reason
--    cancelled_by
--    cancel_date
--    last_update_date
--    last_updated_by
--    last_update_login
--
--
--    Afer Funds Control(After Funds Control routine was successful in
--    unencumbering the PO) Call
--    -------------------------
--     cancel_flag ='Y'

--Parameters:
--  IN:
--   p_fc_level
--   p_entity_id
--   p_cancel_reason
--   p_user_id
--   p_login_id
--   p_action_date
--
--  IN OUT:
--
--   OUT:
--    x_return_status
--      FND_API.G_RET_STS_SUCCESS if procedure succeeds
--      FND_API.G_RET_STS_ERROR if procedure fails
--      FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs

--End of Comments
-------------------------------------------------------------------------------
PROCEDURE update_rel_header_cancel(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2,
            p_entity_id     IN NUMBER,
            p_fc_level      IN VARCHAR2,
            p_action_date   IN DATE,
            p_cancel_reason IN VARCHAR2,
            p_note_to_vendor IN VARCHAR2,
            p_user_id       IN po_lines.last_updated_by%TYPE,
            p_login_id      IN po_lines.last_update_login%TYPE,
            x_return_status OUT NOCOPY VARCHAR2)
  IS

    d_api_name CONSTANT VARCHAR2(30) := 'update_rel_header_cancel';
    d_api_version CONSTANT NUMBER := 1.0;
    d_module   CONSTANT VARCHAR2(100) := g_module_prefix||d_api_name;

    l_progress VARCHAR2(3)            := '000' ;
    l_emp_id   NUMBER                 := FND_GLOBAL.employee_id;
    l_request_id PO_HEADERS.request_id%TYPE := fnd_global.conc_request_id;

  BEGIN
    -- Start standard API initialization
    IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    IF NOT FND_API.compatible_api_call(d_api_version, p_api_version,
                                        d_api_name, g_pkg_name) THEN
      RAISE FND_API.g_exc_unexpected_error;
    END IF;


    IF g_debug_stmt THEN
      PO_DEBUG.debug_begin(d_module);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_fc_level', p_fc_level);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_cancel_reason', p_cancel_reason);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_entity_id', p_entity_id);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_user_id', p_user_id);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_login_id', p_login_id);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_action_date', p_action_date);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_note_to_vendor', p_note_to_vendor);

    END IF;



    IF p_fc_level = c_before_FC THEN

      l_progress := '001' ;

      UPDATE po_releases por
      SET    por.cancel_flag       = 'I'            ,
             por.cancel_reason     = p_cancel_reason,
             por.cancelled_by      = l_emp_id       ,
             --Bug 16575765: CANCEL_DATE is always stamped(RELEASE) as sysdate.
             --por.cancel_date       = p_action_date  ,
             por.cancel_date = sysdate,
             por.note_to_vendor    = p_note_to_vendor,
             por.last_update_date  = SYSDATE        ,
             por.last_updated_by   = p_user_id      ,
             por.last_update_login = p_login_id,
             por.request_id     = DECODE(l_request_id,
                                    NULL,
                                    request_id,
                                    -1,
                                    request_id,
                                    l_request_id)

      WHERE  por.po_release_id     = p_entity_id;

    ELSE

      l_progress := '002' ;

      UPDATE po_releases por
      SET    por.cancel_flag = 'Y'
      WHERE  NVL(por.cancel_flag, 'N') = 'I'
             AND por.po_release_id      = p_entity_id;

    END IF;


  IF g_debug_stmt THEN
    PO_DEBUG.debug_var(d_module, l_progress, 'Rows Updated in Release Headers table', SQL%ROWCOUNT);
  END IF;


EXCEPTION

WHEN FND_API.g_exc_error THEN
  x_return_status := FND_API.g_ret_sts_error;
  FND_MSG_PUB.add_exc_msg(g_module_prefix, d_api_name||':'||l_progress||':'||SQLCODE||':'||SQLERRM);
WHEN FND_API.g_exc_unexpected_error THEN
  x_return_status := FND_API.g_ret_sts_unexp_error;
  FND_MSG_PUB.add_exc_msg(g_module_prefix, d_api_name||':'||l_progress||':'||SQLCODE||':'||SQLERRM);
WHEN OTHERS THEN
  x_return_status := FND_API.g_ret_sts_unexp_error;
  FND_MSG_PUB.add_exc_msg(g_module_prefix, d_api_name||':'||l_progress||':'||SQLCODE||':'||SQLERRM);


END update_rel_header_cancel;

--------------------------------------------------------------------------------
--Start of Comments
--Name: update_document

--Function:
--
--  Updates the Cancel details on PO /Release Header/Line/Shipemnts/Distributions
--  based on the entity being canceled.
--
--  1. If the PO Header is Canceled i.e. entity_level=HEADER and document_type=PO
--     then updates PO Headers/Lines/Shipments/Distributions
--
--  2. If the Release Header is Canceled i.e. entity_level=HEADER and
--     document_type =RELEASE then updates Release Header/Shipments/Distributions
--
--  3. If the Blanket Header is Canceled i.e. entity_level=HEADER and
--     document_type =PA nd docuemnt_subtype=BLANKET then updates PA Header/Lines
--
--  4. If the Contract Header is Canceled i.e. entity_level=HEADER and
--     document_type =PA nd docuemnt_subtype=CONTRACT then updates PA Header
--
--  5. If the PO Line is Canceled i.e. entity_level=LINE and document_type =PO
--     then updates PO Lines/Shipments/Distributions
--
--  6. If the PA Line is Canceled i.e. entity_level=LINE and document_type =PO
--     then updates PA Line
--
--  7. If the PO/Release Shipment is Canceled i.e. entity_level=LINE and
--     document_type =PO then updates PO/Release Shipment/Distributions
--
--Parameters:
--  IN:
--     p_entity_level
--     p_action_date
--     p_entity_id
--     p_document_type
--     p_doc_subtype
--     p_cancel_reason
--     p_fc_level
--     p_user_id
--     p_login_id
--
--  IN OUT:
--
--   OUT:
--     x_msg_data
--     x_return_status
--      FND_API.G_RET_STS_SUCCESS if procedure succeeds
--      FND_API.G_RET_STS_ERROR if procedure fails
--      FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs

--End of Comments
--------------------------------------------------------------------------------

PROCEDURE update_document(
            p_api_version     IN  NUMBER,
            p_init_msg_list   IN  VARCHAR2,
            p_entity_level    IN VARCHAR2,
            p_action_date     IN DATE,
            p_entity_id       IN NUMBER,
            p_document_type   IN VARCHAR2,
            p_doc_subtype     IN VARCHAR2,
            p_cancel_reason   IN VARCHAR2,
            p_fc_level        IN VARCHAR2,
            p_recreate_demand IN VARCHAR2,
            p_note_to_vendor  IN VARCHAR2,
            p_user_id         IN po_lines.last_updated_by%TYPE,
            p_login_id        IN po_lines.last_update_login%TYPE,
            x_return_status   OUT NOCOPY VARCHAR2,
            x_msg_data        OUT NOCOPY VARCHAR2)

  IS

    d_api_name CONSTANT VARCHAR2(30) := 'update_document';
    d_api_version CONSTANT NUMBER := 1.0;
    d_module   CONSTANT VARCHAR2(100) := g_module_prefix||d_api_name;

    l_progress VARCHAR2(3)            := '000' ;

  BEGIN
    -- Start standard API initialization
    IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    IF NOT FND_API.compatible_api_call(d_api_version, p_api_version,
                                        d_api_name, g_pkg_name) THEN
      RAISE FND_API.g_exc_unexpected_error;
    END IF;


    IF g_debug_stmt THEN
      PO_DEBUG.debug_begin(d_module);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_entity_level', p_entity_level);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_action_date', p_action_date);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_entity_id', p_entity_id);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_document_type', p_document_type);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_doc_subtype', p_doc_subtype);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_cancel_reason', p_cancel_reason);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_recreate_demand', p_recreate_demand);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_fc_level', p_fc_level);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_user_id', p_user_id);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_login_id', p_login_id );
      PO_DEBUG.debug_var(d_module, l_progress, 'p_note_to_vendor', p_note_to_vendor );
    END IF;

    l_progress      := '002' ;
    x_return_status := FND_API.g_ret_sts_success;
    x_msg_data      := NULL;

    -- This block is applicable to level: Header/Line/Shipment
    -- If the Entity being Canceld belongs to a
    -- Standard/Planned PO or Release, the corresponding distributions
    -- and shipments have to be canceled
    -- So cancelling the distributions and shipments in all cases if the
    -- document type is not 'Purchase Agreement(PA)'

    IF p_document_type <> c_doc_type_PA THEN
      l_progress := '003' ;

      -- Update Cancel details on Distribution
      update_dist_cancel(
        p_api_version=> 1.0,
        p_init_msg_list=>FND_API.G_FALSE,
        p_fc_level => p_fc_level,
        p_action_date => p_action_date,
        p_entity_level => p_entity_level,
        p_entity_id => p_entity_id,
        p_document_type=>p_document_type,
        p_recreate_demand =>p_recreate_demand,
        p_user_id => p_user_id,
        p_login_id => p_login_id,
        x_return_status => x_return_status);

      IF (x_return_status = FND_API.g_ret_sts_error) THEN
        RAISE FND_API.g_exc_error;
      ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
        RAISE FND_API.g_exc_unexpected_error;
      END IF;

      l_progress := '004';

      -- Update Cancel details on Shipment
      update_ship_cancel(
        p_api_version=> 1.0,
        p_init_msg_list=>FND_API.G_FALSE,
        p_fc_level => p_fc_level,
        p_cancel_reason => p_cancel_reason,
        p_entity_level => p_entity_level,
        p_entity_id => p_entity_id,
        p_action_date => p_action_date,
        p_document_type=>p_document_type,
        p_user_id => p_user_id,
        p_login_id => p_login_id,
        x_return_status => x_return_status);

      IF (x_return_status = FND_API.g_ret_sts_error) THEN
        RAISE FND_API.g_exc_error;
      ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
        RAISE FND_API.g_exc_unexpected_error;
      END IF;


    END IF; --IF p_document_type <> c_doc_type_PA

    l_progress := '005';

    -- This block is applicable to level: Header/Line/Shipment
    -- If the Entity being Canceld belongs to a
    -- Standard/Planned PO or Blanket Agreement, the line details need to
    -- be updated
    -- If the PO Shipment is canceled, update(rollup) the qty/amount on line
    -- If the Line/Header is canceled, cancel the corresponding line itself
    -- So Updating the line details in case if the
    -- document type is not 'Release' and subtype is not 'Contract'


    IF(NOT(p_document_type = c_doc_type_RELEASE
            OR p_doc_subtype = c_doc_subtype_CONTRACT)) THEN

      --If the Shipment is canceled
      IF p_entity_level = c_entity_level_SHIPMENT THEN

        l_progress := '006';

        -- Update(rollup) the qty/amount on line
        update_line_qty_price_amt(
          p_api_version=> 1.0,
          p_init_msg_list=>FND_API.G_FALSE,
          p_ship_id=>p_entity_id,
          x_return_status=>x_return_status);

        IF (x_return_status = FND_API.g_ret_sts_error) THEN
          RAISE FND_API.g_exc_error;
        ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
          RAISE FND_API.g_exc_unexpected_error;
        END IF;

      ELSE
        -- If the Line/Header is canceled,
        l_progress := '007';

        --cancel the corresponding line
        update_line_cancel(
          p_api_version=> 1.0,
          p_init_msg_list=>FND_API.G_FALSE,
          p_fc_level => p_fc_level,
          p_cancel_reason =>p_cancel_reason,
          p_entity_level => p_entity_level,
          p_entity_id => p_entity_id,
          p_action_date => p_action_date,
          p_user_id => p_user_id,
          p_login_id => p_login_id,
          p_note_to_vendor =>p_note_to_vendor,
          x_return_status => x_return_status);

        IF (x_return_status = FND_API.g_ret_sts_error) THEN
          RAISE FND_API.g_exc_error;
        ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
          RAISE FND_API.g_exc_unexpected_error;
        END IF;

      END IF; --IF p_entity_level = = c_entity_level_SHIPMENT
    END IF; -- IF (NOT(p_document_type = c_doc_type_RELEASE OR p_doc_subtype = c_doc_subtype_CONTRACT))


    l_progress := '008';

    -- This block is applicable to level: Header
    -- Canceling the document Header

    IF p_entity_level = c_entity_level_HEADER THEN

      -- If the Document is a Release Header
      IF p_document_type = c_doc_type_RELEASE THEN

        l_progress := '009';
        update_rel_header_cancel(
          p_api_version=> 1.0,
          p_init_msg_list=>FND_API.G_FALSE,
          p_fc_level => p_fc_level,
          p_entity_id => p_entity_id,
          p_action_date => p_action_date,
          p_cancel_reason =>p_cancel_reason,
          p_user_id =>p_user_id,
          p_login_id =>p_login_id,
          p_note_to_vendor =>p_note_to_vendor,
          x_return_status =>x_return_status);

      ELSE
        l_progress := '010';
        -- If the Document is a PO/PA  Header
        update_po_header_cancel(
          p_api_version=> 1.0,
          p_init_msg_list=>FND_API.G_FALSE,
          p_fc_level => p_fc_level,
          p_entity_id => p_entity_id,
          p_action_date => p_action_date,
          p_user_id =>p_user_id,
          p_login_id =>p_login_id,
          p_note_to_vendor =>p_note_to_vendor,
          x_return_status =>x_return_status);

      END IF; -- IF p_document_type = c_doc_type_RELEASE

        IF (x_return_status = FND_API.g_ret_sts_error) THEN
          RAISE FND_API.g_exc_error;
        ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
          RAISE FND_API.g_exc_unexpected_error;
        END IF;

    END IF; -- IF p_entity_level = c_entity_level_HEADER



  EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_msg_data := FND_MSG_PUB.GET(
                     P_MSG_INDEX => FND_MSG_PUB.G_LAST,
                     P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.add_exc_msg(g_module_prefix, d_api_name||':'||l_progress||':'||SQLCODE||':'||SQLERRM);

    WHEN FND_API.G_EXC_ERROR THEN
      x_msg_data := FND_MSG_PUB.GET(
                      P_MSG_INDEX => FND_MSG_PUB.G_LAST,
                      P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.add_exc_msg(g_module_prefix, d_api_name||':'||l_progress||':'||SQLCODE||':'||SQLERRM);

    WHEN OTHERS THEN
      IF (G_DEBUG_UNEXP) THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
	FND_LOG.STRING(
          FND_LOG.LEVEL_UNEXPECTED,
          d_module || '.OTHERS_EXCEPTION',
          'EXCEPTION: LOCATION IS ' || l_progress || ' SQL CODE IS '||SQLCODE);
	  END IF;
      END IF;

      FND_MSG_PUB.add_exc_msg(g_module_prefix, d_api_name||':'||l_progress||':'||SQLCODE||':'||SQLERRM);
      x_msg_data := FND_MSG_PUB.GET(
                      P_MSG_INDEX => FND_MSG_PUB.G_LAST,
                      P_ENCODED => 'F');
      x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;

END update_document;

--------------------------------------------------------------------------------
-- Start of Comments
-- Name: cancel_supply
-- Function:
--   Updates MTL_SUPPLY when the gievn entity is cancelled to remove the
--   corresponding PO Supply
--   For this , the common routin po_suply.po_req_supply is calle with appropriate
--   action.
--
--Parameters:
--IN:
-- p_entity_level
-- p_entity_id
-- p_doc_id
-- p_document_type
-- p_doc_subtype
-- p_recreate_flag
--
--IN OUT :
--OUT :
-- x_msg_data
-- x_return_status
--   FND_API.G_RET_STS_SUCCESS if cancel action succeeds
--   FND_API.G_RET_STS_ERROR if cancel action fails
--   FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
--
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE cancel_supply(
            p_api_version     IN  NUMBER,
            p_init_msg_list   IN  VARCHAR2,
            p_entity_level  IN VARCHAR2,
            p_entity_id     IN NUMBER,
            p_doc_id        IN NUMBER,
            p_document_type IN VARCHAR2,
            p_doc_subtype   IN VARCHAR2,
            p_recreate_flag IN VARCHAR2,
            x_return_status IN OUT NOCOPY VARCHAR2,
            x_msg_data      IN OUT NOCOPY VARCHAR2)

  IS

    d_api_name CONSTANT VARCHAR2(30) := 'cancel_supply';
    d_api_version CONSTANT NUMBER := 1.0;
    d_module   CONSTANT VARCHAR2(100) := g_module_prefix||d_api_name;

    l_progress VARCHAR2(3)            := '000' ;


    l_line_id       NUMBER       := 0;
    l_ship_id       NUMBER       := 0;
    l_action        VARCHAR2(30) := NULL;
    l_status        BOOLEAN      := FALSE;
    l_recreate_flag BOOLEAN;


  BEGIN
    -- Start standard API initialization
    IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    IF NOT FND_API.compatible_api_call(d_api_version, p_api_version,
                                        d_api_name, g_pkg_name) THEN
      RAISE FND_API.g_exc_unexpected_error;
    END IF;


    IF g_debug_stmt THEN
      PO_DEBUG.debug_begin(d_module);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_entity_level', p_entity_level);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_entity_id', p_entity_id);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_doc_id', p_doc_id);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_document_type', p_document_type);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_doc_subtype', p_doc_subtype);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_recreate_flag', p_recreate_flag);
    END IF;


    x_return_status := FND_API.g_ret_sts_success;
    x_msg_data      := NULL;
    l_progress      := '001' ;

    -- If the requiistion line is canceled, cancel req line supply
    -- This will be called on cancelling backing req
    IF p_document_type = c_doc_type_REQUISITION THEN
      l_line_id       := p_entity_id;
      l_action        := 'Remove_Req_Line_Supply';

    ELSE
      -- If SPO shipment is canceled, the action will be Cancel_PO_Shipment
      -- If Schedule Release shipment is canceled, the action will be
      -- Cancel_Planned_Shipment
      -- If Blanket Release shipment is canceled, the action will be
      -- Cancel_Blanket_Shipment
      IF p_entity_level = c_entity_level_SHIPMENT THEN
        l_ship_id      := p_entity_id;

        IF p_document_type <> c_doc_type_RELEASE THEN
          l_action         := 'Cancel_PO_Shipment';
        ELSE -- if doc is realse
          IF p_doc_subtype = c_doc_subtype_PLANNED THEN
            l_action      := 'Cancel_Planned_Shipment';
          ELSE
            l_action := 'Cancel_Blanket_Shipment';
          END IF;
        END IF;

      -- If SPO line is canceled, the action will be Cancel_PO_Line
      ELSIF p_entity_level = c_entity_level_LINE THEN

        l_line_id := p_entity_id;
        l_action  := 'Cancel_PO_Line';

        -- If SPO Header is canceled, the action will be Cancel_PO_Supply
        -- If Schedule Release is canceled, the action will be
        -- Cancel_Planned_Release
        -- If Blanket Release is canceled, the action will be
        -- Cancel_Blanket_Release
      ELSE --header level

        IF p_document_type <> c_doc_type_RELEASE THEN
          l_action         := 'Cancel_PO_Supply';
        ELSE -- if doc is realse

          IF p_doc_subtype = c_doc_subtype_PLANNED THEN
            l_action      := 'Cancel_Planned_Release';
          ELSE
            l_action := 'Cancel_Blanket_Release';
          END IF;

        END IF;

      END IF; -- if l_entity_rec_tbl(i).entity_level =  c_entity_level_SHIPMENT
    END IF;

    IF g_debug_stmt THEN
      PO_DEBUG.debug_var(d_module, l_progress, 'l_action', l_action);
      PO_DEBUG.debug_var(d_module, l_progress, 'l_line_id', l_line_id);
      PO_DEBUG.debug_var(d_module, l_progress, 'l_ship_id', l_ship_id);
    END IF ;

    l_progress        := '002' ;
    IF p_recreate_flag = 'Y' THEN
      l_recreate_flag := TRUE;
    ELSE
      l_recreate_flag := FALSE;
    END IF;

    IF g_debug_stmt THEN
      PO_DEBUG.debug_var(d_module, l_progress, 'l_recreate_flag', l_recreate_flag);
    END IF;


    l_progress := '003' ;
    -- For the entity, call the po_req_supply function to cancel mtl supply
    -- with appropriate action.
    l_status := po_supply.po_req_supply(
                  p_docid => p_doc_id,
                  p_lineid =>l_line_id,
                  p_shipid =>l_ship_id,
                  p_action =>l_action,
                  p_recreate_flag =>l_recreate_flag,
                  p_qty =>0,
                  p_receipt_date =>SYSDATE,
                  p_reservation_action=>NULL,
                  p_ordered_uom =>NULL);

    IF g_debug_stmt THEN
      PO_DEBUG.debug_var(d_module, l_progress, 'l_status', l_status);
    END IF;



  EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_msg_data := FND_MSG_PUB.GET(
                    P_MSG_INDEX => FND_MSG_PUB.G_LAST,
                    P_ENCODED => 'F');
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.add_exc_msg(g_module_prefix, d_api_name||':'||l_progress||':'||SQLCODE||':'||SQLERRM);

   WHEN FND_API.G_EXC_ERROR THEN
    x_msg_data := FND_MSG_PUB.GET(
                    P_MSG_INDEX => FND_MSG_PUB.G_LAST,
                    P_ENCODED => 'F');
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.add_exc_msg(g_module_prefix, d_api_name||':'||l_progress||':'||SQLCODE||':'||SQLERRM);

  WHEN OTHERS THEN
    IF (G_DEBUG_UNEXP) THEN
IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
FND_LOG.STRING(
        FND_LOG.LEVEL_UNEXPECTED,
          d_module || '.OTHERS_EXCEPTION',
          'EXCEPTION: LOCATION IS ' || l_progress || ' SQL CODE IS '||SQLCODE);
	  END IF;
    END IF;

    FND_MSG_PUB.add_exc_msg(g_module_prefix, d_api_name||':'||l_progress||':'||SQLCODE||':'||SQLERRM);
    x_msg_data := FND_MSG_PUB.GET(
                    P_MSG_INDEX => FND_MSG_PUB.G_LAST,
                    P_ENCODED => 'F');
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;


END cancel_supply;


--------------------------------------------------------------------------------
-- Start of Comments
-- Name: cancel_tax_lines
-- Function:
--   Cancels tax lines after corresponding PO shipment has been cancelled
--   For this , the common routine PO_TAX_INTERFACE_PVT.cancel_tax_lines is
--   called.
--
--Parameters:
--IN:
--  p_entity_level
--  p_entity_id
--  p_doc_id
--  p_document_type
--  p_doc_subtype
--
--IN OUT :
--OUT :
-- x_msg_data
-- x_return_status
--   FND_API.G_RET_STS_SUCCESS if cancel action succeeds
--   FND_API.G_RET_STS_ERROR if cancel action fails
--   FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
--
--End of Comments
--------------------------------------------------------------------------------

PROCEDURE cancel_tax_lines(
            p_api_version     IN  NUMBER,
            p_init_msg_list   IN  VARCHAR2,
            p_entity_level  IN VARCHAR2,
            p_entity_id     IN NUMBER,
            p_doc_id        IN NUMBER,
            p_document_type IN VARCHAR2,
            p_doc_subtype   IN VARCHAR2,
            x_return_status IN OUT NOCOPY VARCHAR2,
            x_msg_data      IN OUT NOCOPY VARCHAR2)

  IS

    d_api_name CONSTANT VARCHAR2(30) := 'cancel_tax_lines';
    d_api_version CONSTANT NUMBER := 1.0;
    d_module   CONSTANT VARCHAR2(100) := g_module_prefix||d_api_name;

    l_progress VARCHAR2(3)            := '000' ;

    l_msg_count NUMBER := 0;
    l_line_id   NUMBER := 0;
    l_ship_id   NUMBER := 0;


  BEGIN
    -- Start standard API initialization
    IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    IF NOT FND_API.compatible_api_call(d_api_version, p_api_version,
                                        d_api_name, g_pkg_name) THEN
      RAISE FND_API.g_exc_unexpected_error;
    END IF;

    IF g_debug_stmt THEN
      PO_DEBUG.debug_begin(d_module);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_entity_level', p_entity_level);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_entity_id', p_entity_id);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_doc_id', p_doc_id);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_document_type', p_document_type);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_doc_subtype', p_doc_subtype);
    END IF;

    IF p_entity_level = c_entity_level_SHIPMENT THEN
      l_ship_id      := p_entity_id;

    ELSIF p_entity_level = c_entity_level_LINE THEN
      l_line_id         := p_entity_id;

    END IF; -- if l_entity_rec_tbl(i).entity_level =  c_entity_level_SHIPMENT


    IF g_debug_stmt THEN
      PO_DEBUG.debug_var(d_module, l_progress, 'l_line_id', l_line_id);
      PO_DEBUG.debug_var(d_module, l_progress, 'l_ship_id', l_ship_id);
    END IF ;


    PO_TAX_INTERFACE_PVT.cancel_tax_lines(
      p_document_type => p_document_type,
      p_document_id => p_doc_id,
      p_line_id => l_line_id,
      p_shipment_id => l_ship_id,
      x_return_status => x_return_status,
      x_msg_count => l_msg_count,
      x_msg_data => x_msg_data);


    IF (x_return_status = FND_API.g_ret_sts_error) THEN
      RAISE FND_API.g_exc_error;
    ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
      RAISE FND_API.g_exc_unexpected_error;
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_msg_data := FND_MSG_PUB.GET(
                      P_MSG_INDEX => FND_MSG_PUB.G_LAST,
                      P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.add_exc_msg(g_module_prefix, d_api_name||':'||l_progress||':'||SQLCODE||':'||SQLERRM);
       IF (g_debug_unexp) THEN
              IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
	      FND_LOG.string(FND_LOG.level_unexpected,d_module ||'---at '||l_progress || 'UnExpected Error', SQLERRM);
	      END IF;
      END IF;


    WHEN FND_API.G_EXC_ERROR THEN
      x_msg_data := FND_MSG_PUB.GET(
                      P_MSG_INDEX => FND_MSG_PUB.G_LAST,
                      P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.add_exc_msg(g_module_prefix, d_api_name||':'||l_progress||':'||SQLCODE||':'||SQLERRM);
       IF (g_debug_unexp) THEN
              IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
	      FND_LOG.string(FND_LOG.level_unexpected,d_module ||'---at '||l_progress || 'UnExpected Error', SQLERRM);
	      END IF;
      END IF;


    WHEN OTHERS THEN
      IF (G_DEBUG_UNEXP) THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
	FND_LOG.STRING(
          FND_LOG.LEVEL_UNEXPECTED,
          d_module || '.OTHERS_EXCEPTION',
          'EXCEPTION: LOCATION IS ' || l_progress || ' SQL CODE IS '||SQLCODE);
	  END IF;
      END IF;
      FND_MSG_PUB.add_exc_msg(g_module_prefix, d_api_name||':'||l_progress||':'||SQLCODE||':'||SQLERRM);
      x_msg_data := FND_MSG_PUB.GET(
                      P_MSG_INDEX => FND_MSG_PUB.G_LAST,
                      P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END cancel_tax_lines;

--------------------------------------------------------------------------------
-- Start of Comments
-- Name: cancel_pending_change_request
-- Function:
--   When the PO/Po Shipment is Cancelled, then there is no need for any pending
--   Change Request on the PO /PO Shipment to be approved by Buyer.
--   If the underlying req is also canceled When the PO/PO Shipmnet is Canceled ,
-- 	 then there is no need for the requester change request to be approved by
-- 	 manager any more. We should immediately close the requester change request.
--	 If the request change request is a cancel request, we should immediately
--	 accept it, and if it is a change request, we should reject it.
--
--Parameters:
--IN:
-- p_entity_level
-- p_entity_id
-- p_doc_id
-- p_document_type
-- p_doc_subtype
-- p_source
-- p_req_line_id_tbl
--
--IN OUT :
--OUT :
-- x_msg_data
-- x_return_status
--   FND_API.G_RET_STS_SUCCESS if cancel action succeeds
--   FND_API.G_RET_STS_ERROR if cancel action fails
--   FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
--
--End of Comments
--------------------------------------------------------------------------------

PROCEDURE cancel_pending_change_request(
            p_api_version     IN  NUMBER,
            p_init_msg_list   IN  VARCHAR2,
            p_entity_level    IN VARCHAR2,
            p_entity_id       IN NUMBER,
            p_doc_id          IN NUMBER,
            p_document_type   IN VARCHAR2,
            p_doc_subtype     IN VARCHAR2,
            p_source          IN VARCHAR2,
            p_req_line_id_tbl IN PO_ReqChangeRequestWF_PVT.ReqLineID_tbl_type,
            x_return_status   IN OUT NOCOPY VARCHAR2,
            x_msg_data        IN OUT NOCOPY VARCHAR2)

  IS

   d_api_name CONSTANT VARCHAR2(30) := 'cancel_pending_change_request';
   d_api_version CONSTANT NUMBER := 1.0;
   d_module   CONSTANT VARCHAR2(100) := g_module_prefix||d_api_name;

   l_progress  VARCHAR2(8)            := '000' ;
   l_msg_count NUMBER ;
   l_line_id   NUMBER ;
   l_ship_id   NUMBER ;


  BEGIN
    -- Start standard API initialization
    IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    IF NOT FND_API.compatible_api_call(d_api_version, p_api_version,
                                        d_api_name, g_pkg_name) THEN
      RAISE FND_API.g_exc_unexpected_error;
    END IF;



    IF g_debug_stmt THEN
      PO_DEBUG.debug_begin(d_module);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_entity_level', p_entity_level);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_entity_id', p_entity_id);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_doc_id', p_doc_id);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_document_type', p_document_type);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_doc_subtype', p_doc_subtype);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_source', p_source);
    END IF;

    l_msg_count := 0;
    l_line_id   := 0;
    l_ship_id   := 0;



    IF p_entity_level = c_entity_level_SHIPMENT THEN
      l_ship_id      := p_entity_id;

    ELSIF p_entity_level = c_entity_level_LINE THEN
      l_line_id         := p_entity_id;

    END IF; -- if l_entity_rec_tbl(i).entity_level =  c_entity_level_SHIPMENT

    l_progress := '002';

    IF g_debug_stmt THEN
      PO_DEBUG.debug_var(d_module, l_progress, 'l_line_id', l_line_id);
      PO_DEBUG.debug_var(d_module, l_progress, 'l_ship_id', l_ship_id);
    END IF ;

    IF p_req_line_id_tbl IS NOT NULL AND p_req_line_id_tbl.Count>0 THEN

      l_progress := '003';

      -- When there is a pending requester change request going on,
      -- if the PO get canceled, which cause the underlying req calceled
      -- also, there is no need for the requester change request to be
      -- approved by manager any more. We should immediately close the
      -- requester change request. If the request change request is
      -- a cancel request, we should immediately accept it, and if it is
      -- a change request, we should reject it.  */
      PO_ReqChangeRequestWF_PVT.process_cancelled_req_lines (
        p_api_version => 1.0,
        p_init_msg_list => FND_API.G_FALSE,
        p_commit => FND_API.G_FALSE,
        x_return_status => x_return_status,
        x_msg_count => l_msg_count,
        x_msg_data => x_msg_data,
        p_canceledReqLineIDs_tbl => p_req_line_id_tbl );


    ELSIF (p_document_type = c_doc_type_RELEASE) THEN
      l_progress          := '004';

      IF p_entity_level = c_entity_level_HEADER THEN
	      PO_Document_Control_PVT.rel_stop_wf_process(
		      p_api_version   => 1.0,
	        p_init_msg_list => FND_API.G_FALSE,
	        x_return_status => x_return_status,
	        p_doc_type      => p_document_type,
	        p_doc_subtype   => p_doc_subtype,
	        p_doc_id        => p_doc_id );

	    END IF;

      -- abort supplier initiated changes and auto accept any
      -- pending cancellation for shipments if any
      IF nvl(p_source,'NULL') IN(c_HTML_CONTROL_ACTION,c_FORM_CONTROL_ACTION)
      THEN

        l_progress          := '005';
        PO_CHG_REQUEST_PVT.cancel_change_request(
          p_api_version => 1.0,
          p_init_msg_list => FND_API.G_FALSE,
          x_return_status => x_return_status,
          p_po_header_id => NULL,
          p_po_release_id => p_doc_id,
          p_po_line_id => NULL,
          p_po_line_location_id => l_ship_id );
      END IF;
    ELSE

      IF p_entity_level = c_entity_level_HEADER THEN
        l_progress          := '006';
        PO_Document_Control_PVT.po_stop_wf_process(
          p_api_version   => 1.0,
          p_init_msg_list => FND_API.G_FALSE,
          x_return_status => x_return_status,
          p_doc_type      => p_document_type,
          p_doc_subtype   => p_doc_subtype,
          p_doc_id        => p_doc_id );
      END IF;

	    -- abort supplier initiated changes and auto accept any
      -- pending cancellation for shipments if any

      IF nvl(p_source,'NULL') IN(c_HTML_CONTROL_ACTION,c_FORM_CONTROL_ACTION)
      THEN

        l_progress := '007';

        PO_CHG_REQUEST_PVT.cancel_change_request(
          p_api_version => 1.0,
          p_init_msg_list => FND_API.G_FALSE,
          x_return_status => x_return_status,
          p_po_header_id => p_doc_id,
          p_po_release_id => NULL,
          p_po_line_id => l_line_id,
          p_po_line_location_id => l_ship_id );

      END IF;

    END IF; --<if p_doc_type RELEASE>

    IF (x_return_status = FND_API.g_ret_sts_error) THEN
      RAISE FND_API.g_exc_error;
    ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
      RAISE FND_API.g_exc_unexpected_error;
    END IF;



  EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_msg_data := FND_MSG_PUB.GET(
                      P_MSG_INDEX => FND_MSG_PUB.G_LAST,
                      P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.add_exc_msg(g_module_prefix, d_api_name||':'||l_progress||':'||SQLCODE||':'||SQLERRM);

    WHEN FND_API.G_EXC_ERROR THEN
      x_msg_data := FND_MSG_PUB.GET(
                      P_MSG_INDEX => FND_MSG_PUB.G_LAST,
                      P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.add_exc_msg(g_module_prefix, d_api_name||':'||l_progress||':'||SQLCODE||':'||SQLERRM);

    WHEN OTHERS THEN
      IF (G_DEBUG_UNEXP) THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
	FND_LOG.STRING(
          FND_LOG.LEVEL_UNEXPECTED,
          d_module || '.OTHERS_EXCEPTION',
          'EXCEPTION: LOCATION IS ' || l_progress || ' SQL CODE IS '||SQLCODE);
	  END IF;
      END IF;
      FND_MSG_PUB.add_exc_msg(g_module_prefix, d_api_name||':'||l_progress||':'||SQLCODE||':'||SQLERRM);
      x_msg_data := FND_MSG_PUB.GET(
                      P_MSG_INDEX => FND_MSG_PUB.G_LAST,
                      P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END cancel_pending_change_request;



--------------------------------------------------------------------------------
-- Start of Comments
-- Name: fetch_req_lines
-- Function:
--  Fetches all requisition line IDs linked to the document at
--  p_entity_level, specified by p_entity_id.
--
--Parameters:
--IN:
-- p_entity_level
-- p_entity_id
-- p_document_type
-- p_doc_subtype
-- p_fc_level
--
--IN OUT :
--OUT :
-- x_msg_data
-- x_req_line_id_tbl
--   A PL/SQL table of requisition line IDs
-- x_return_status
--   FND_API.G_RET_STS_SUCCESS if cancel action succeeds
--   FND_API.G_RET_STS_ERROR if cancel action fails
--   FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
--
--End of Comments
--------------------------------------------------------------------------------

PROCEDURE fetch_req_lines (
            p_api_version   IN  NUMBER,
            p_init_msg_list IN  VARCHAR2,
            p_entity_id     IN NUMBER,
            p_entity_level  IN VARCHAR2,
            p_document_type IN VARCHAR2,
            p_doc_subtype   IN VARCHAR2,
            p_fc_level      IN VARCHAR2,
            x_return_status OUT NOCOPY VARCHAR2,
            x_req_line_id_tbl OUT NOCOPY PO_ReqChangeRequestWF_PVT.ReqLineID_tbl_type)
  IS

    d_api_name CONSTANT VARCHAR2(30) := 'fetch_req_lines';
    d_api_version CONSTANT NUMBER := 1.0;
    d_module   CONSTANT VARCHAR2(100) := g_module_prefix||d_api_name;

    l_progress VARCHAR2(3)            := '000' ;

    CURSOR l_before_fc_csr IS
      SELECT DISTINCT(prd.requisition_line_id)
      FROM   po_req_distributions_all prd,
             po_line_locations poll  ,
             po_distributions_all pod
      WHERE  pod.line_location_id = poll.line_location_id
             AND pod.req_distribution_id = prd.distribution_id
             AND NVL(poll.cancel_flag, 'N')     = 'I'
             AND NVL(poll.closed_code, 'OPEN') <> 'FINALLY CLOSED'
             AND poll.shipment_type IN(
                   'STANDARD',
                   'PLANNED' ,
                   'BLANKET' ,
                   'PREPAYMENT')
             AND ((p_entity_level = c_entity_level_HEADER
                    AND p_document_type     <> c_doc_type_RELEASE
                    AND pod.po_header_id     = p_entity_id)
                 OR(p_entity_level         = c_entity_level_HEADER
                    AND p_document_type      = c_doc_type_RELEASE
                    AND pod.po_release_id    = p_entity_id)
                 OR(p_entity_level         = c_entity_level_LINE
                    AND pod.po_line_id       = p_entity_id)
                 OR(p_entity_level         = c_entity_level_SHIPMENT
                    AND pod.line_location_id = p_entity_id));


    CURSOR l_after_fc_csr IS
      SELECT DISTINCT(prl.requisition_line_id)
      FROM   po_requisition_lines_all prl,
             po_line_locations poll
      WHERE  prl.line_location_id= (-1 * poll.line_location_id)
             AND NVL(poll.cancel_flag, 'N')     = 'Y'
             AND NVL(poll.closed_code, 'OPEN') <> 'FINALLY CLOSED'
             AND poll.shipment_type IN(
                   'STANDARD',
                   'PLANNED' ,
                   'BLANKET' ,
                   'PREPAYMENT')
             AND ((p_entity_level = c_entity_level_HEADER
                    AND p_document_type     <> c_doc_type_RELEASE
                    AND poll.po_header_id     = p_entity_id)
                 OR(p_entity_level         = c_entity_level_HEADER
                    AND p_document_type      = c_doc_type_RELEASE
                    AND poll.po_release_id    = p_entity_id)
                 OR(p_entity_level         = c_entity_level_LINE
                    AND poll.po_line_id       = p_entity_id)
                 OR(p_entity_level         = c_entity_level_SHIPMENT
                    AND poll.line_location_id = p_entity_id));




  BEGIN
    -- Start standard API initialization
    IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    IF NOT FND_API.compatible_api_call(d_api_version, p_api_version,
                                        d_api_name, g_pkg_name) THEN
      RAISE FND_API.g_exc_unexpected_error;
    END IF;


    IF g_debug_stmt THEN
      PO_DEBUG.debug_begin(d_module);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_entity_level', p_entity_level);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_entity_id', p_entity_id);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_document_type', p_document_type);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_doc_subtype', p_doc_subtype);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_fc_level', p_fc_level);
    END IF;


    IF p_fc_level = c_before_FC THEN
      l_progress := '001';

      OPEN l_before_fc_csr;
      FETCH l_before_fc_csr BULK COLLECT
        INTO x_req_line_id_tbl;

      IF (l_before_fc_csr%NOTFOUND) THEN
        NULL;
      END IF;
      CLOSE l_before_fc_csr;


    ELSE
      l_progress := '002';

      OPEN l_after_fc_csr;
      FETCH l_after_fc_csr BULK COLLECT
        INTO x_req_line_id_tbl;

      IF (l_after_fc_csr%NOTFOUND) THEN
        NULL;
      END IF;
      CLOSE l_after_fc_csr;

    END IF;


    IF g_debug_stmt THEN
      PO_DEBUG.debug_var(
        d_module,
        l_progress,
        'x_req_line_id_tbl count',
        x_req_line_id_tbl.count);
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.add_exc_msg(g_module_prefix, d_api_name||':'||l_progress||':'||SQLCODE||':'||SQLERRM);
      IF(G_DEBUG_UNEXP) THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
	FND_LOG.STRING(
          FND_LOG.LEVEL_UNEXPECTED,
          d_module || '.UNEXPECTED',
          'ERROR: LOCATION IS ' || l_progress || ' SQL CODE IS '||SQLCODE|| ' SQL ERRM IS '||SQLERRM);
	  END IF;
      END IF;


    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.add_exc_msg(g_module_prefix, d_api_name||':'||l_progress||':'||SQLCODE||':'||SQLERRM);
      IF (G_DEBUG_UNEXP) THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
	FND_LOG.STRING(
          FND_LOG.LEVEL_UNEXPECTED,
            d_module || '.ERROR ERROR',
            'ERROR: LOCATION IS ' || l_progress || ' SQL CODE IS '||SQLCODE|| ' SQL ERRM IS '||SQLERRM);
	    END IF;
      END IF;

    WHEN OTHERS THEN
      IF (G_DEBUG_UNEXP) THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
	FND_LOG.STRING(
          FND_LOG.LEVEL_UNEXPECTED,
          d_module || '.OTHERS_EXCEPTION',
          'EXCEPTION: LOCATION IS ' || l_progress || ' SQL CODE IS '||SQLCODE|| ' SQL ERRM IS '||SQLERRM);
	  END IF;
      END IF;
      FND_MSG_PUB.add_exc_msg(g_module_prefix, d_api_name||':'||l_progress||':'||SQLCODE||':'||SQLERRM);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END fetch_req_lines;

--------------------------------------------------------------------------------
--Start of Comments
--Name: calc_uom_conv
--Function:
--  Calculate UOM Conversion between Req Line UOM and its corresponding
--   PO Line UOM
--
--Parameters:
--IN:
-- p_req_line_id
-- p_fc_level
--
--IN OUT :
--OUT :
--RETURNS
-- x_uom_conv:
--   UOM Conversion between Req Line UOM and corresponding PO Line UOM
--
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE calc_uom_conv(
            p_api_version     IN  NUMBER,
            p_init_msg_list   IN  VARCHAR2,
            p_fc_level        IN VARCHAR2,
            p_req_line_id     IN NUMBER,
            x_uom_conv        OUT NOCOPY NUMBER)
  IS

    d_api_name CONSTANT VARCHAR2(30) := 'calc_uom_conv';
    d_api_version CONSTANT NUMBER := 1.0;
    d_module   CONSTANT VARCHAR2(100) := g_module_prefix||d_api_name;

    l_progress VARCHAR2(3)            := '000' ;



  BEGIN
    -- Start standard API initialization
    IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    IF NOT FND_API.compatible_api_call(d_api_version, p_api_version,
                                        d_api_name, g_pkg_name) THEN
      RAISE FND_API.g_exc_unexpected_error;
    END IF;


    IF g_debug_stmt THEN
      PO_DEBUG.debug_begin(d_module);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_req_line_id', p_req_line_id);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_fc_level', p_fc_level);
    END IF;

    x_uom_conv := 1;

    --<<Bug#16515136 START>>
    IF p_fc_level = c_before_FC THEN
      SELECT PO_UOM_S.PO_UOM_CONVERT_P(
				 POL.UNIT_MEAS_LOOKUP_CODE,
				 PORL.UNIT_MEAS_LOOKUP_CODE,
				 PORL.ITEM_ID)
      INTO   x_uom_conv
      FROM   PO_REQUISITION_LINES_ALL PORL,
			   po_line_locations POLL    ,
			   po_lines POL
      WHERE  PORL.LINE_LOCATION_ID        = POLL.LINE_LOCATION_ID
			   AND POLL.PO_LINE_ID          = POL.PO_LINE_ID
			   AND PORL.REQUISITION_LINE_ID = p_req_line_id ;

    ELSE
    	SELECT PO_UOM_S.PO_UOM_CONVERT_P(
				 POL.UNIT_MEAS_LOOKUP_CODE,
				 PORL.UNIT_MEAS_LOOKUP_CODE,
				 PORL.ITEM_ID)
    	INTO   x_uom_conv
    	FROM   PO_REQUISITION_LINES_ALL PORL,
			   po_line_locations POLL    ,
			   po_lines POL
      WHERE  (-1)*PORL.LINE_LOCATION_ID = POLL.LINE_LOCATION_ID
			   AND POLL.PO_LINE_ID          = POL.PO_LINE_ID
			   and porl.requisition_line_id = p_req_line_id ;
    END IF;
    --<<Bug#16515136 END>>

    IF g_debug_stmt THEN
      PO_DEBUG.debug_var(d_module, l_progress, 'x_uom_conv', x_uom_conv);
    END IF;

  EXCEPTION
    WHEN No_Data_Found THEN
      x_uom_conv := 1;
      IF g_debug_stmt THEN
        PO_DEBUG.debug_stmt(d_module, l_progress,'Set l_uom_conv = 0');
      END IF ;
    WHEN OTHERS THEN
      FND_MSG_PUB.add_exc_msg(g_module_prefix, d_api_name||':'||l_progress||':'||SQLCODE||':'||SQLERRM);
      IF g_debug_stmt THEN
        PO_DEBUG.debug_stmt(d_module, l_progress,'Exception in calc_uom_conv check');
      END IF ;

END calc_uom_conv;

--------------------------------------------------------------------------------
--Start of Comments
--Name: calc_qty_canceled
--Function:
--  Calculates the quantity canceled to be updated on requisition line
--
--Parameters:
--IN:
-- p_req_line_id
-- p_uom_conv
--
--IN OUT :
--OUT :
--RETURNS
-- x_qty_cancelled
--
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE calc_qty_canceled(
            p_api_version     IN  NUMBER,
            p_init_msg_list   IN  VARCHAR2,
            p_req_line_id IN NUMBER,
            p_uom_conv    IN NUMBER,
            x_qty_cancelled OUT NOCOPY NUMBER )
  IS

    d_api_name CONSTANT VARCHAR2(30) := 'calc_qty_canceled';
    d_api_version CONSTANT NUMBER := 1.0;
    d_module   CONSTANT VARCHAR2(100) := g_module_prefix|| d_api_name;

    l_progress VARCHAR2(3)            := '000' ;


  BEGIN
    -- Start standard API initialization
    IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    IF NOT FND_API.compatible_api_call(d_api_version, p_api_version,
                                        d_api_name, g_pkg_name) THEN
      RAISE FND_API.g_exc_unexpected_error;
    END IF;


    IF g_debug_stmt THEN
      PO_DEBUG.debug_begin(d_module);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_req_line_id', p_req_line_id);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_uom_conv', p_uom_conv);
    END IF;

    SELECT DECODE(
               SIGN(SUM(PORD.req_line_quantity
                        - p_uom_conv *greatest(NVL(POD.quantity_delivered, 0),
						                            NVL(POD.quantity_billed, 0)
									                      )
			            )
			       ),
              -1,
		        0,
              SUM(PORD.req_line_quantity
                 - p_uom_conv *greatest(NVL(POD.quantity_delivered, 0),
						                     NVL(POD.quantity_billed, 0)
									               )
		        )
		      )
    INTO  x_qty_cancelled
    FROM  PO_DISTRIBUTIONS_ALL POd    ,
          po_req_distributions_all pord,
          po_line_locations POLL
    WHERE pord.requisition_line_id = p_req_line_id
          AND pord.distribution_id   = pod.req_distribution_id
          AND POLL.line_location_id  = POD.line_location_id
          AND POLL.shipment_type IN(
                'STANDARD',
                'PLANNED' ,
                'BLANKET');

  IF g_debug_stmt THEN
    PO_DEBUG.debug_var(d_module, l_progress, 'x_qty_cancelled', x_qty_cancelled);
  END IF;

  EXCEPTION
    WHEN No_Data_Found THEN
      x_qty_cancelled := 0;
      IF g_debug_stmt THEN
        PO_DEBUG.debug_stmt(d_module, l_progress, 'Set p_qty_cancelled = 0');
      END IF ;
    WHEN OTHERS THEN
      FND_MSG_PUB.add_exc_msg(g_module_prefix, d_api_name||':'||l_progress||':'||SQLCODE||':'||SQLERRM);
      IF g_debug_stmt THEN
        PO_DEBUG.debug_stmt(d_module, l_progress, 'Exception in calc_qty_canceled check');
      END IF ;

END calc_qty_canceled;

--------------------------------------------------------------------------------
-- Start of Comments
-- Name: update_req_details_after_fc
-- Function:
--  Updates the  cancel details(ex: cancel_flag ='Y') on backing requisition lines
--  of the document being canceled after the funds control call
--  (i.e. unencumbering the Document).
--  If p_reacreate_demand_flag ='N' then it just updates::
--    the Cancel_flag to 'Y'of the backing Req Line
--    Quantity on PRD and PRL to be the cancelled quantity on POD
--    and Sum(qty on PRD) resp.
--  If p_reacreate_demand_flag ='Y' then it :
--    Updates the OLD PRD Quantity to be remaining qty i.e. Original PRD
--    Qty-Qty canceled on POD
--    Updates the OLD PRL Quantity to be sum (Quantity on OLD PRD)
--    Updates line_location_id to be null on new PRL.
--
--Parameters:
--IN:
-- p_req_line_id
-- p_recreate_demand_flag
-- p_user_id
-- p_login_id
--
--IN OUT :
--OUT :
-- x_msg_data
-- x_return_status
--     FND_API.G_RET_STS_SUCCESS if cancel action succeeds
--     FND_API.G_RET_STS_ERROR if cancel action fails
--     FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
--
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE update_req_details_after_fc(
            p_api_version          IN  NUMBER,
            p_init_msg_list        IN  VARCHAR2,
            p_req_line_id          IN NUMBER,
            p_recreate_demand_flag IN VARCHAR2,
            p_user_id              IN po_lines.last_updated_by%TYPE,
            p_login_id             IN po_lines.last_update_login%TYPE,
            p_is_new_req_line      IN VARCHAR2,
            x_msg_data             OUT NOCOPY VARCHAR2,
            x_return_status        OUT NOCOPY VARCHAR2)
  IS

    d_api_name CONSTANT VARCHAR2(30) := 'update_req_details_after_fc';
    d_api_version CONSTANT NUMBER := 1.0;
    d_module   CONSTANT VARCHAR2(100) := g_module_prefix|| d_api_name;

    l_progress VARCHAR2(30); --18000459
    l_qty_cancelled      NUMBER;
    l_parent_req_line_id NUMBER;
    l_uom_conv           NUMBER ;
    l_auth_status        VARCHAR2(30);

  BEGIN
    -- Start standard API initialization
    IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    IF NOT FND_API.compatible_api_call(d_api_version, p_api_version,
                                        d_api_name, g_pkg_name) THEN
      RAISE FND_API.g_exc_unexpected_error;
    END IF;


    l_progress := '000' ;

    IF g_debug_stmt THEN
      PO_DEBUG.debug_begin(d_module);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_req_line_id', p_req_line_id);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_recreate_demand_flag', p_recreate_demand_flag);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_user_id', p_user_id);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_login_id', p_login_id);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_is_new_req_line', p_is_new_req_line);

    END IF;


    x_return_status := FND_API.g_ret_sts_success;
    x_msg_data      := NULL;
    l_auth_status   := NULL;
    l_qty_cancelled := 0;
    l_uom_conv      := 0;

    l_progress := '001' ;

    -- If recreate demand is OFF, then the req line has to be canceled
    IF p_recreate_demand_flag = 'N' THEN

      -- Get the UOM conversion between req line and its corresponding PO Line
      calc_uom_conv (
        p_api_version=> 1.0,
        p_init_msg_list=>FND_API.G_FALSE,
        p_fc_level=>c_after_FC,
        p_req_line_id=>p_req_line_id,
        x_uom_conv=>l_uom_conv);

      IF g_debug_stmt THEN
        PO_DEBUG.debug_var(d_module, l_progress, 'l_uom_conv', l_uom_conv);
      END IF;

      l_progress := '002';
      -- Calculate the quantity  canceled to be updated on req line.
      calc_qty_canceled(
        p_api_version=> 1.0,
        p_init_msg_list=>FND_API.G_FALSE,
        p_req_line_id=>p_req_line_id,
        p_uom_conv=>l_uom_conv,
        x_qty_cancelled=>l_qty_cancelled);

      IF g_debug_stmt THEN
        PO_DEBUG.debug_var(d_module, l_progress, 'l_qty_cancelled', l_qty_cancelled);
      END IF;

        -- Update the req distribution quantity to be the quantity canceled on Po Distribution
        UPDATE  PO_REQ_DISTRIBUTIONS PORD
        SET     PORD.req_line_quantity =
               (SELECT DECODE(SIGN(PORD.req_line_quantity
                                     - SUM(l_uom_conv * greatest(NVL(POD.quantity_delivered, 0),
                                                           NVL(POD.quantity_billed, 0)
                                                        )
                                          )
                              ),
                         -1,
                         PORD.req_line_quantity,
                         0,
                         PORD.req_line_quantity,
                         SUM(l_uom_conv * (greatest(NVL(POD.quantity_delivered, 0),
                                             NVL(POD.quantity_billed, 0)) )) )

                FROM  po_line_locations POLL,
                      PO_DISTRIBUTIONS_ALL POD
                WHERE POD.req_distribution_id   = PORD.distribution_id
                      AND POLL.line_location_id = POD.line_location_id
                      AND POLL.shipment_type IN ('STANDARD',
                            'PLANNED' ,
                           'BLANKET') )
        WHERE PORD.requisition_line_id = p_req_line_id ;


        IF g_debug_stmt THEN
          PO_DEBUG.debug_var(d_module, l_progress, 'Rows Updated in PO_REQ_DISTRIBUTIONS table', SQL%ROWCOUNT);
        END IF;

        l_progress := '003' ;

        -- Set the cancel_flag to Y and set back the line_location id to positive
        UPDATE PO_REQUISITION_LINES_ALL PORL
        SET    PORL.cancel_flag         = 'Y'                       ,
               PORL.contractor_status   = NULL                      ,
               PORL.cancel_date         = SYSDATE                   ,
               PORL.line_location_id    = -1 * PORL.line_location_id,
               PORL.quantity_cancelled  = l_qty_cancelled
        WHERE  PORL.requisition_line_id = p_req_line_id;

        IF g_debug_stmt THEN
          PO_DEBUG.debug_var(d_module, l_progress, 'Rows Updated in PO_REQUISITION_LINES_ALL table', SQL%ROWCOUNT);
        END IF;

    ELSE --p_recreate_demand_flag ='Y'


      IF p_is_new_req_line ='Y' THEN
         -- When Recreate_Demand is ON and  new Req line is created
      l_progress := '004' ;
      calc_uom_conv (
          p_api_version=> 1.0,
          p_init_msg_list=>FND_API.G_FALSE,
          p_fc_level=>c_after_FC,
        p_req_line_id=>p_req_line_id,
        x_uom_conv=>l_uom_conv);


      -- The control will come here if the recreate demand is ON and the qty
      -- canceled on po distribution is greater than 0 .
      -- In that case, a new Req Line/distribution will be craeted with the qty
      -- being canceled.
      -- So Just Updating Old Req line and Distribution quantity with the
      -- (original qty-qty canceled).
      -- Note: The p_req_line_id now will be the new req line id created

      l_progress := '005';

      UPDATE PO_REQ_DISTRIBUTIONS_ALL PORD
      SET    PORD.req_line_quantity = (SELECT Least(PORD.req_line_quantity ,
                                                    sum(l_uom_conv *
                                                        Greatest(NVL(POD.quantity_delivered, 0),
                                                         NVL(POD.quantity_billed, 0))
                                                     )
                                                    )
                                      FROM  po_line_locations POLL,
                                            PO_DISTRIBUTIONS_ALL POD
                                      WHERE POD.req_distribution_id   = PORD.distribution_id
                                            AND POLL.line_location_id = POD.line_location_id
                                            AND POLL.shipment_type IN ('STANDARD'  ,
                                                                       'PLANNED'   ,
                                                                        'BLANKET') ),

             PORD.last_update_date  = SYSDATE  ,
             PORD.last_updated_by   = p_user_id,
             PORD.last_update_login = p_login_id
      WHERE PORD.distribution_id IN (
              SELECT PORD1.distribution_id
              FROM   PO_REQUISITION_LINES_ALL PORL_NEW,
                     PO_REQUISITION_LINES_ALL PORL_OLD,
                     PO_REQ_DISTRIBUTIONS_ALL PORD1   ,
                     PO_DISTRIBUTIONS POD
              WHERE PORL_NEW.requisition_line_id = p_req_line_id
                    AND PORL_OLD.requisition_line_id   = (-1) * PORL_NEW.parent_req_line_id
                    AND PORD1.requisition_line_id      = PORL_OLD.requisition_line_id
                    AND POD.req_distribution_id        = PORD1.distribution_id
                    AND NVL(POD.quantity_cancelled, 0) > 0 );

      IF g_debug_stmt THEN
        PO_DEBUG.debug_var(d_module, l_progress, 'Rows Updated in PO_REQ_DISTRIBUTIONS_ALL table', SQL%ROWCOUNT);
      END IF;


	  --18000459  fix begin
	  -- Above sql does not update all req distributions.
	  -- req dists corresponding to (po dists whose qty is completely cancelled) are not handled by above sql.
	  l_progress := '0055';
	  UPDATE PO_REQ_DISTRIBUTIONS_ALL PORD
            SET  PORD.req_line_quantity = 0,
	         PORD.last_update_date  = SYSDATE  ,
                 PORD.last_updated_by   = p_user_id,
                 PORD.last_update_login = p_login_id
	  WHERE  PORD.distribution_id IN (

              SELECT PORD1.distribution_id
              FROM   PO_REQUISITION_LINES_ALL PORL_NEW,
                     PO_REQUISITION_LINES_ALL PORL_OLD,
                     PO_REQ_DISTRIBUTIONS_ALL PORD1
              WHERE PORL_NEW.requisition_line_id = p_req_line_id
                    AND PORL_OLD.requisition_line_id   = (-1) * PORL_NEW.parent_req_line_id
                    AND PORD1.requisition_line_id      = PORL_OLD.requisition_line_id
                    AND NOT EXISTS (  select 'po dist linked to req dist'
				      from po_distributions_all pod
				      where pod.req_distribution_id = PORD1.distribution_id
				   )
	  );

	  IF g_debug_stmt THEN
          PO_DEBUG.debug_var(d_module, l_progress, 'Rows Updated in PO_REQ_DISTRIBUTIONS_ALL table', SQL%ROWCOUNT);
          END IF;
	   --18000459 fix end


      l_progress := '006' ;
      SELECT SUM(PORD.req_line_quantity)
      INTO   l_qty_cancelled
      FROM   PO_REQ_DISTRIBUTIONS_ALL PORD
      WHERE  PORD.distribution_id IN (
               SELECT PORD1.distribution_id
               FROM   PO_REQUISITION_LINES_ALL PORL_NEW,
                      PO_REQUISITION_LINES_ALL PORL_OLD,
                      PO_REQ_DISTRIBUTIONS_ALL PORD1
               WHERE  PORL_NEW.requisition_line_id= p_req_line_id
                      AND PORL_OLD.requisition_line_id= (-1) * PORL_NEW.parent_req_line_id
                      AND PORD1.requisition_line_id = PORL_OLD.requisition_line_id );

      IF g_debug_stmt THEN
        PO_DEBUG.debug_var(d_module, l_progress, 'l_qty_cancelled', l_qty_cancelled);
      END IF;

      l_progress := '007' ;

      -- Updating the  Old Req Line
      UPDATE PO_REQUISITION_LINES_ALL PORL
      SET(
             PORL.QUANTITY        ,
             PORL.LAST_UPDATE_DATE,
             PORL.LAST_UPDATED_BY ,
             PORL.LAST_UPDATE_LOGIN )
           = (SELECT  DECODE(porl.order_type_lookup_code,
                        'RATE', NULL,
                        'FIXED PRICE', NULL,
                        l_qty_cancelled),
                      SYSDATE                        ,
                      p_user_id                      ,
                      p_login_id
              FROM  po_line_locations POLL,
                    po_lines POL
              WHERE PORL.line_location_id  = POLL.line_location_id
                    AND POLL.po_line_id    = POL.po_line_id)
      WHERE   PORL.requisition_line_id = (
                SELECT ((-1) * PORL_NEW.parent_req_line_id)
                FROM   PO_REQUISITION_LINES_ALL PORL_NEW
                WHERE  PORL_NEW.requisition_line_id = p_req_line_id );

      IF g_debug_stmt THEN
        PO_DEBUG.debug_var(d_module, l_progress, 'Rows Updated in PO_REQUISITION_LINES_ALL table', SQL%ROWCOUNT);
      END IF;

      l_progress := '008' ;

      SELECT PORL_OLD.PARENT_REQ_LINE_ID,
             PRH.AUTHORIZATION_STATUS
      INTO   l_parent_req_line_id,
             l_auth_status
      FROM   PO_REQUISITION_LINES_ALL PORL_OLD,
             PO_REQUISITION_LINES_ALL PORL_NEW,
             PO_REQUISITION_HEADERS_ALL PRH
      WHERE  PORL_OLD.requisition_line_id     = (-1) * PORL_NEW.parent_req_line_id
             AND PRH.requisition_header_id    = PORL_NEW.requisition_header_id
             AND PORL_NEW.requisition_line_id = p_req_line_id;


      IF g_debug_stmt THEN
          PO_DEBUG.debug_var(d_module,l_progress,'l_auth_status',l_auth_status);
          PO_DEBUG.debug_var(d_module,l_progress,'l_parent_req_line_id',l_parent_req_line_id);
      END IF;

      -- Need to calculate Reqs in POOL flag :
      -- It should be Y only if Req Header is in Approved status

      l_progress := '009' ;
      -- Updating the new line to free it up,
      UPDATE PO_REQUISITION_LINES_ALL PORL
      SET    PORL.LINE_LOCATION_ID   = NULL,
             PORL.PARENT_REQ_LINE_ID = DECODE(l_parent_req_line_id,
                                         -9999,
                                         NULL,
                                         l_parent_req_line_id),
             LAST_UPDATE_DATE       = SYSDATE                            ,
             LAST_UPDATED_BY        = p_user_id                          ,
             LAST_UPDATE_LOGIN      = p_login_id                         ,
             PORL.REQS_IN_POOL_FLAG = DECODE(l_auth_status,
                                        PO_DOCUMENT_ACTION_PVT.g_doc_status_APPROVED,
                                        'Y',
                                        'N')

      WHERE  PORL.requisition_line_id = p_req_line_id;

        IF g_debug_stmt THEN
          PO_DEBUG.debug_var(d_module,
          l_progress,
          'Rows Updated in PO_REQUISITION_LINES_ALL table',
           SQL%ROWCOUNT);
        END IF;


      ELSE
      -- When Recreate_Demand is ON and no new Req line is created
        l_progress := '010' ;

        SELECT PRH.AUTHORIZATION_STATUS
        INTO   l_auth_status
        FROM   PO_REQUISITION_LINES_ALL PORL,
               PO_REQUISITION_HEADERS_ALL PRH
        WHERE  PRH.requisition_header_id    = PORL.requisition_header_id
              AND PORL.requisition_line_id = p_req_line_id;


        IF g_debug_stmt THEN
          PO_DEBUG.debug_var(d_module,l_progress,'l_auth_status',l_auth_status);
        END IF;

        -- Need to calculate Reqs in POOL flag :
        -- It should be Y only if Req Header is in Approved status

        l_progress := '009' ;
        -- Updating the new line to free it up,
        UPDATE PO_REQUISITION_LINES_ALL PORL
        SET    PORL.LINE_LOCATION_ID   = NULL,
               LAST_UPDATE_DATE       = SYSDATE                            ,
               LAST_UPDATED_BY        = p_user_id                          ,
               LAST_UPDATE_LOGIN      = p_login_id                         ,
               PORL.REQS_IN_POOL_FLAG = DECODE(l_auth_status,
                                          PO_DOCUMENT_ACTION_PVT.g_doc_status_APPROVED,
                                          'Y',
                                          'N')

        WHERE  PORL.requisition_line_id = p_req_line_id;

      IF g_debug_stmt THEN
        PO_DEBUG.debug_var(d_module,
          l_progress,
          'Rows Updated in PO_REQUISITION_LINES_ALL table',
           SQL%ROWCOUNT);
      END IF;

      END IF;  -- If p_is_new_req_line ='Y'

    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_msg_data := FND_MSG_PUB.GET(
                      P_MSG_INDEX => FND_MSG_PUB.G_LAST,
                      P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.add_exc_msg(g_module_prefix, d_api_name||':'||l_progress||':'||SQLCODE||':'||SQLERRM);

    WHEN FND_API.G_EXC_ERROR THEN
      x_msg_data := FND_MSG_PUB.GET(
                      P_MSG_INDEX => FND_MSG_PUB.G_LAST,
                      P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.add_exc_msg(g_module_prefix, d_api_name||':'||l_progress||':'||SQLCODE||':'||SQLERRM);

    WHEN OTHERS THEN
      IF (G_DEBUG_UNEXP) THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
	FND_LOG.STRING(
           FND_LOG.LEVEL_UNEXPECTED,
           d_module || '.OTHERS_EXCEPTION',
           'EXCEPTION: LOCATION IS ' || l_progress || ' SQL CODE IS '||SQLCODE);
	   END IF;
      END IF;

      FND_MSG_PUB.add_exc_msg(g_module_prefix, d_api_name||':'||l_progress||':'||SQLCODE||':'||SQLERRM);
      x_msg_data := FND_MSG_PUB.GET(
                      P_MSG_INDEX => FND_MSG_PUB.G_LAST,
                      P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;


 END update_req_details_after_fc;


--------------------------------------------------------------------------------
--Start of Comments
--Name: is_qty_del_bill_zero
--Function:
-- Finds he PO Distributions corresponding  to each of the Req Distributions
-- of the i/p req line and
-- Returns true if the Qty delivered/Billed is greater than 0 on any of those
-- PO distributions Otherwise returns False.
--
--Parameters:
--IN:
-- p_req_line_id
--IN OUT :
--OUT :
-- RETURNS
--  True
--    If Qty Billed/Delivered is greater than 0 on corresponding PO distribution.
--  False
--    If both Qty Billed/Delivered are 0 on corresponding PO distribution.
--
--End of Comments
--------------------------------------------------------------------------------

FUNCTION is_qty_del_bill_zero(
           p_api_version     IN  NUMBER,
           p_init_msg_list   IN  VARCHAR2,
           p_req_line_id IN NUMBER)
RETURN BOOLEAN
  IS

    d_api_name CONSTANT VARCHAR2(30) := 'is_qty_del_bill_zero';
    d_api_version CONSTANT NUMBER := 1.0;
    d_module   CONSTANT VARCHAR2(100) := g_module_prefix|| d_api_name;

    l_progress VARCHAR2(3)            := '000' ;
    l_is_qty_zero BOOLEAN := FALSE;
    l_qzero       NUMBER  := 0;

  BEGIN
    -- Start standard API initialization
    IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    IF NOT FND_API.compatible_api_call(d_api_version, p_api_version,
                                        d_api_name, g_pkg_name) THEN
      RAISE FND_API.g_exc_unexpected_error;
    END IF;


    IF g_debug_stmt THEN
      PO_DEBUG.debug_begin(d_module);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_req_line_id', p_req_line_id);
    END IF;

  -- Bug 17219745: Adding Nvl condition when quantity delivered/billed is null
  -- Patch is created with bug 17197253 as both issues have fix in this file only.
    BEGIN
      SELECT SUM(greatest(Nvl(pod.quantity_delivered,0),
                   Nvl(pod.quantity_billed,0)))
      INTO   l_qzero
      FROM   PO_DISTRIBUTIONS_ALL POD,
             PO_REQ_DISTRIBUTIONS_ALL PORD
      WHERE  POD.req_distribution_id      = PORD.distribution_id
             AND PORD.requisition_line_id = p_req_line_id;

    EXCEPTION

      WHEN No_Data_Found THEN
        l_qzero := 0;
        IF g_debug_stmt THEN
          PO_DEBUG.debug_stmt(d_module, l_progress, 'Set l_qzero = 0');
        END IF ;
      WHEN OTHERS THEN
        IF g_debug_stmt THEN
          PO_DEBUG.debug_stmt(d_module, l_progress, 'Exception in is_qty_del_bill_zero check');
        END IF ;
        RAISE FND_API.g_exc_unexpected_error;
    END;

    IF g_debug_stmt THEN
      PO_DEBUG.debug_var(d_module, l_progress, 'l_qzero', l_qzero);
    END IF;

    IF l_qzero= 0 THEN
      l_is_qty_zero := TRUE;
    END IF;

  RETURN l_is_qty_zero;

END is_qty_del_bill_zero;

--------------------------------------------------------------------------------
--Start of Comments
--Name: create_req_line
--Function:
-- Creates a new requisition line, setting its quantity to be input qty
-- Insert a new req line with:
-- Line number = Max(current line number on req)
-- requisition_line_id = PO_REQUISITION_LINE_S.NEXTVAL
-- quantity = p_line_quantity.
-- line_location_id= -poll.line_location_id (This is so that no
-- other module uses this req line until funds
-- checker is executed successfully. Then we
-- change line_location_id to Null.)
-- Copy the notes corresponding to the old line.
-- This routine is called only if recreate_demand_flag is ON
--
--Parameters:
--IN:
-- p_old_line_id
-- p_line_quantity
-- p_user_id
-- p_login_id
--
--IN OUT :
--OUT :
-- x_new_line_id
--     Returns the  requisition_line_id of the newly created req line
-- x_msg_data
-- x_return_status
--     FND_API.G_RET_STS_SUCCESS if cancel action succeeds
--     FND_API.G_RET_STS_ERROR if cancel action fails
--     FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
--
--End of Comments
--------------------------------------------------------------------------------

PROCEDURE create_req_line(
            p_api_version     IN  NUMBER,
            p_init_msg_list   IN  VARCHAR2,
            p_old_line_id   IN NUMBER,
            p_line_quantity IN NUMBER,
            p_user_id       IN po_lines.last_updated_by%TYPE,
            p_login_id      IN po_lines.last_update_login%TYPE,
            x_new_line_id   OUT NOCOPY NUMBER,
            x_return_status OUT NOCOPY VARCHAR2,
            x_msg_data      OUT NOCOPY  VARCHAR2)

  IS
    d_api_name CONSTANT VARCHAR2(30) := 'create_req_line';
    d_api_version CONSTANT NUMBER := 1.0;
    d_module   CONSTANT VARCHAR2(100) := g_module_prefix|| d_api_name;

    l_next_line_num NUMBER;
    l_progress      VARCHAR2(3) := '000' ;

  BEGIN
    -- Start standard API initialization
    IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    IF NOT FND_API.compatible_api_call(d_api_version, p_api_version,
                                        d_api_name, g_pkg_name) THEN
      RAISE FND_API.g_exc_unexpected_error;
    END IF;


    IF g_debug_stmt THEN
      PO_DEBUG.debug_begin(d_module);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_old_line_id', p_old_line_id);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_line_quantity', p_line_quantity);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_user_id', p_user_id);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_login_id', p_login_id);
    END IF;

    l_progress      := '001' ;
    x_msg_data      := NULL;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    SELECT NVL(MAX(porl.line_num), 0) + 1
    INTO   l_next_line_num
    FROM   po_requisition_lines_all porl
    WHERE   porl.requisition_header_id
              =(SELECT requisition_header_id
                FROM   po_requisition_lines_all
                WHERE  requisition_line_id = p_old_line_id);

    l_progress := '002' ;

    SELECT PO_REQUISITION_LINES_S.NEXTVAL
    INTO   x_new_line_id
    FROM   SYS.DUAL;

    IF g_debug_stmt THEN
      PO_DEBUG.debug_var(d_module, l_progress, 'x_new_line_id', x_new_line_id);
      PO_DEBUG.debug_var(d_module, l_progress, 'l_next_line_num', l_next_line_num);
    END IF;

    INSERT INTO PO_REQUISITION_LINES_ALL(
      REQUISITION_LINE_ID          ,
      REQUISITION_HEADER_ID        ,
      LINE_NUM                     ,
      LINE_TYPE_ID                 ,
      CATEGORY_ID                  ,
      ITEM_DESCRIPTION             ,
      UNIT_MEAS_LOOKUP_CODE        ,
      UNIT_PRICE                   ,
      QUANTITY                     ,
      DELIVER_TO_LOCATION_ID       ,
      TO_PERSON_ID                 ,
      LAST_UPDATE_DATE             ,
      LAST_UPDATED_BY              ,
      SOURCE_TYPE_CODE             ,
      LAST_UPDATE_LOGIN            ,
      CREATION_DATE                ,
      CREATED_BY                   ,
      ITEM_ID                      ,
      ITEM_REVISION                ,
      QUANTITY_DELIVERED           ,
      SUGGESTED_BUYER_ID           ,
      RFQ_REQUIRED_FLAG            ,
      NEED_BY_DATE                 ,
      LINE_LOCATION_ID             ,
      MODIFIED_BY_AGENT_FLAG       ,
      PARENT_REQ_LINE_ID           ,
      JUSTIFICATION                ,
      NOTE_TO_AGENT                ,
      NOTE_TO_RECEIVER             ,
      PURCHASING_AGENT_ID          ,
      BLANKET_PO_HEADER_ID         ,
      BLANKET_PO_LINE_NUM          ,
      SUGGESTED_VENDOR_NAME        ,
      SUGGESTED_VENDOR_LOCATION    ,
      SUGGESTED_VENDOR_CONTACT     ,
      SUGGESTED_VENDOR_PHONE       ,
      SUGGESTED_VENDOR_PRODUCT_CODE,
      UN_NUMBER_ID                 ,
      HAZARD_CLASS_ID              ,
      MUST_USE_SUGG_VENDOR_FLAG    ,
      REFERENCE_NUM                ,
      ON_RFQ_FLAG                  ,
      URGENT_FLAG                  ,
      CANCEL_FLAG                  ,
      SOURCE_ORGANIZATION_ID       ,
      SOURCE_SUBINVENTORY          ,
      DESTINATION_TYPE_CODE        ,
      DESTINATION_ORGANIZATION_ID  ,
      DESTINATION_SUBINVENTORY     ,
      QUANTITY_CANCELLED           ,
      CANCEL_DATE                  ,
      CANCEL_REASON                ,
      CLOSED_CODE                  ,
      AGENT_RETURN_NOTE            ,
      CHANGED_AFTER_RESEARCH_FLAG  ,
      VENDOR_ID                    ,
      VENDOR_SITE_ID               ,
      VENDOR_CONTACT_ID            ,
      RESEARCH_AGENT_ID            ,
      ON_LINE_FLAG                 ,
      WIP_ENTITY_ID                ,
      WIP_LINE_ID                  ,
      WIP_REPETITIVE_SCHEDULE_ID   ,
      WIP_OPERATION_SEQ_NUM        ,
      WIP_RESOURCE_SEQ_NUM         ,
      BOM_RESOURCE_ID              ,
      ATTRIBUTE_CATEGORY           ,
      DESTINATION_CONTEXT          ,
      INVENTORY_SOURCE_CONTEXT     ,
      VENDOR_SOURCE_CONTEXT        ,
      ATTRIBUTE1                   ,
      ATTRIBUTE2                   ,
      ATTRIBUTE3                   ,
      ATTRIBUTE4                   ,
      ATTRIBUTE5                   ,
      ATTRIBUTE6                   ,
      ATTRIBUTE7                   ,
      ATTRIBUTE8                   ,
      ATTRIBUTE9                   ,
      ATTRIBUTE10                  ,
      ATTRIBUTE11                  ,
      ATTRIBUTE12                  ,
      ATTRIBUTE13                  ,
      ATTRIBUTE14                  ,
      ATTRIBUTE15                  ,
      CURRENCY_CODE                ,
      CURRENCY_UNIT_PRICE          ,
      DOCUMENT_TYPE_CODE           ,
      RATE                         ,
      RATE_DATE                    ,
      RATE_TYPE                    ,
      TAX_CODE_ID                  ,
      TAX_USER_OVERRIDE_FLAG       ,
      TAX_STATUS_INDICATOR         ,
      ORG_ID                       ,
      ORDER_TYPE_LOOKUP_CODE       ,
      PURCHASE_BASIS               ,
      MATCHING_BASIS               ,
      BASE_UNIT_PRICE              ,
      DROP_SHIP_FLAG               ,
      CATALOG_TYPE                 ,
      CATALOG_SOURCE
    )
    SELECT
      x_new_line_id                     ,
      PORL.REQUISITION_HEADER_ID        ,
      l_next_line_num                   ,
      PORL.LINE_TYPE_ID                 ,
      PORL.CATEGORY_ID                  ,
      PORL.ITEM_DESCRIPTION             ,
      PORL.UNIT_MEAS_LOOKUP_CODE        ,
      PORL.unit_price                   ,
      p_line_quantity                   ,
      PORL.DELIVER_TO_LOCATION_ID       ,
      PORL.TO_PERSON_ID                 ,
      SYSDATE                           ,
      p_user_id                         ,
      PORL.SOURCE_TYPE_CODE             ,
      p_login_id                        ,
      PORL.CREATION_DATE                ,
      p_user_id                         ,
      PORL.ITEM_ID                      ,
      PORL.ITEM_REVISION                ,
      0                                 ,
      PORL.SUGGESTED_BUYER_ID           ,
      PORL.RFQ_REQUIRED_FLAG            ,
      PORL.NEED_BY_DATE                 ,
      (-1 * PORL.LINE_LOCATION_ID)      ,
      PORL.MODIFIED_BY_AGENT_FLAG       ,
      (-1 * PORL.REQUISITION_LINE_ID)   ,
      PORL.JUSTIFICATION                ,
      PORL.NOTE_TO_AGENT                ,
      PORL.NOTE_TO_RECEIVER             ,
      PORL.PURCHASING_AGENT_ID          ,
      PORL.BLANKET_PO_HEADER_ID         ,
      PORL.BLANKET_PO_LINE_NUM          ,
      PORL.SUGGESTED_VENDOR_NAME        ,
      PORL.SUGGESTED_VENDOR_LOCATION    ,
      PORL.SUGGESTED_VENDOR_CONTACT     ,
      PORL.SUGGESTED_VENDOR_PHONE       ,
      PORL.SUGGESTED_VENDOR_PRODUCT_CODE,
      PORL.UN_NUMBER_ID                 ,
      PORL.HAZARD_CLASS_ID              ,
      PORL.MUST_USE_SUGG_VENDOR_FLAG    ,
      PORL.REFERENCE_NUM                ,
      PORL.ON_RFQ_FLAG                  ,
      PORL.URGENT_FLAG                  ,
      PORL.CANCEL_FLAG                  ,
      PORL.SOURCE_ORGANIZATION_ID       ,
      PORL.SOURCE_SUBINVENTORY          ,
      PORL.DESTINATION_TYPE_CODE        ,
      PORL.DESTINATION_ORGANIZATION_ID  ,
      PORL.DESTINATION_SUBINVENTORY     ,
      PORL.QUANTITY_CANCELLED           ,
      PORL.CANCEL_DATE                  ,
      PORL.CANCEL_REASON                ,
      PORL.CLOSED_CODE                  ,
      PORL.AGENT_RETURN_NOTE            ,
      PORL.CHANGED_AFTER_RESEARCH_FLAG  ,
      PORL.VENDOR_ID                    ,
      PORL.VENDOR_SITE_ID               ,
      PORL.VENDOR_CONTACT_ID            ,
      PORL.RESEARCH_AGENT_ID            ,
      PORL.ON_LINE_FLAG                 ,
      PORL.WIP_ENTITY_ID                ,
      PORL.WIP_LINE_ID                  ,
      PORL.WIP_REPETITIVE_SCHEDULE_ID   ,
      PORL.WIP_OPERATION_SEQ_NUM        ,
      PORL.WIP_RESOURCE_SEQ_NUM         ,
      PORL.BOM_RESOURCE_ID              ,
      PORL.ATTRIBUTE_CATEGORY           ,
      PORL.DESTINATION_CONTEXT          ,
      PORL.INVENTORY_SOURCE_CONTEXT     ,
      PORL.VENDOR_SOURCE_CONTEXT        ,
      PORL.ATTRIBUTE1                   ,
      PORL.ATTRIBUTE2                   ,
      PORL.ATTRIBUTE3                   ,
      PORL.ATTRIBUTE4                   ,
      PORL.ATTRIBUTE5                   ,
      PORL.ATTRIBUTE6                   ,
      PORL.ATTRIBUTE7                   ,
      PORL.ATTRIBUTE8                   ,
      PORL.ATTRIBUTE9                   ,
      PORL.ATTRIBUTE10                  ,
      PORL.ATTRIBUTE11                  ,
      PORL.ATTRIBUTE12                  ,
      PORL.ATTRIBUTE13                  ,
      PORL.ATTRIBUTE14                  ,
      PORL.ATTRIBUTE15                  ,
      PORL.CURRENCY_CODE                ,
      PORL.CURRENCY_UNIT_PRICE          ,
      PORL.DOCUMENT_TYPE_CODE           ,
      PORL.RATE                         ,
      PORL.RATE_DATE                    ,
      PORL.RATE_TYPE                    ,
      PORL.TAX_CODE_ID                  ,
      PORL.TAX_USER_OVERRIDE_FLAG       ,
      PORL.TAX_STATUS_INDICATOR         ,
      PORL.ORG_ID                       ,
      PORL.ORDER_TYPE_LOOKUP_CODE       ,
      PORL.PURCHASE_BASIS               ,
      PORL.MATCHING_BASIS               ,
      PORL.BASE_UNIT_PRICE              ,
      PORL.DROP_SHIP_FLAG               ,
      PORL.CATALOG_TYPE                 ,
      PORL.CATALOG_SOURCE
    FROM
      PO_REQUISITION_LINES_ALL PORL,
      po_line_locations POLL    ,
      po_lines POL
    WHERE
      PORL.REQUISITION_LINE_ID = p_old_line_id
      AND PORL.LINE_LOCATION_ID  = POLL.LINE_LOCATION_ID
      AND POLL.PO_LINE_ID        = POL.PO_LINE_ID;

    l_progress := '003' ;

    PO_NOTES_SV.COPY_NOTES (
      X_orig_id=>p_old_line_id,
      X_orig_column=> 'REQUISITION_LINE_ID',
      X_orig_table=> 'PO_REQUISITION_LINES',
      X_add_on_title=>NULL,
      X_new_id=> x_new_line_id,
      X_new_column=> 'REQUISITION_LINE_ID',
      X_new_table=> 'PO_REQUISITION_LINES',
      X_last_updated_by=>p_user_id,
      X_last_update_login=> p_login_id);


  EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_msg_data := FND_MSG_PUB.GET(
                      P_MSG_INDEX => FND_MSG_PUB.G_LAST,
                      P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.add_exc_msg(g_module_prefix, d_api_name||':'||l_progress||':'||SQLCODE||':'||SQLERRM);
    WHEN FND_API.G_EXC_ERROR THEN
      x_msg_data := FND_MSG_PUB.GET(
                      P_MSG_INDEX => FND_MSG_PUB.G_LAST,
                      P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.add_exc_msg(g_module_prefix, d_api_name||':'||l_progress||':'||SQLCODE||':'||SQLERRM);
    WHEN OTHERS THEN
      IF (G_DEBUG_UNEXP) THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
	FND_LOG.STRING(
          FND_LOG.LEVEL_UNEXPECTED,
          d_module || '.OTHERS_EXCEPTION',
          'EXCEPTION: LOCATION IS ' || l_progress || ' SQL CODE IS '||SQLCODE);
	  END IF;
      END IF;
       FND_MSG_PUB.add_exc_msg(g_module_prefix, d_api_name||':'||l_progress||':'||SQLCODE||':'||SQLERRM);
      x_msg_data := FND_MSG_PUB.GET(
                      P_MSG_INDEX => FND_MSG_PUB.G_LAST,
                      P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END create_req_line;

--------------------------------------------------------------------------------
--Start of Comments
--Name: create_req_dist
--Function:
--  Create requisition distributions to take the quantity
--  that was ordered but not billed/delivered for the given
--  req line.
--  Insert into PO_REQ_DISTRIBUTIONS.
--  ID = PO_REQ_DISTRIBUTIONS_S.NEXTVAL,
--  requisition_line_id = new_line_id,
--  quantity = quantity_cancelled from associated po_distribution.
--  source_req_dist_id = PORD.distribution_id

-- This routine is called only if recreate_demand_flag is ON

--
--Parameters:
--IN:
--  p_req_line_id
--  p_user_id
--  p_login_id
--
--
--IN OUT :
--OUT :
-- x_msg_data
-- x_return_status
--     FND_API.G_RET_STS_SUCCESS if cancel action succeeds
--     FND_API.G_RET_STS_ERROR if cancel action fails
--     FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
--
--End of Comments
--------------------------------------------------------------------------------

PROCEDURE create_req_dist(
            p_api_version   IN  NUMBER,
            p_init_msg_list IN  VARCHAR2,
            p_req_line_id IN NUMBER,
            p_user_id     IN po_lines.last_updated_by%TYPE,
            p_login_id    IN po_lines.last_update_login%TYPE,
            x_return_status OUT NOCOPY VARCHAR2,
            x_msg_data OUT NOCOPY VARCHAR2)

  IS

    d_api_name CONSTANT VARCHAR2(30) := 'create_req_dist';
    d_api_version CONSTANT NUMBER := 1.0;
    d_module   CONSTANT VARCHAR2(100) := g_module_prefix|| d_api_name;
    l_progress VARCHAR2(3)            := '000' ;
    l_uom_conv NUMBER                 := 0;

  BEGIN
    -- Start standard API initialization
    IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    IF NOT FND_API.compatible_api_call(d_api_version, p_api_version,
                                        d_api_name, g_pkg_name) THEN
      RAISE FND_API.g_exc_unexpected_error;
    END IF;



    IF g_debug_stmt THEN
      PO_DEBUG.debug_begin(d_module);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_req_line_id', p_req_line_id);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_user_id', p_user_id);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_login_id', p_login_id);
    END IF;

    l_progress      := '001' ;
    x_msg_data      := NULL;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    calc_uom_conv (
      p_api_version=> 1.0,
      p_init_msg_list=>FND_API.G_FALSE,
      p_req_line_id=>p_req_line_id,
      p_fc_level=>c_after_FC,
                 x_uom_conv=>l_uom_conv);

    IF g_debug_stmt THEN
      PO_DEBUG.debug_var(d_module, l_progress, 'l_uom_conv', l_uom_conv);
    END IF;

    l_progress := '002' ;

    INSERT INTO PO_REQ_DISTRIBUTIONS_ALL (
      distribution_id            ,
      last_update_date           ,
      last_updated_by            ,
      requisition_line_id        ,
      set_of_books_id            ,
      code_combination_id        ,
      req_line_quantity          ,
      last_update_login          ,
      creation_date              ,
      created_by                 ,
      distribution_num           ,
      gl_encumbered_date         ,
      gl_encumbered_period_name  ,
      gl_cancelled_date          ,
      failed_funds_lookup_code   ,
      source_req_distribution_id ,
      ATTRIBUTE1                 ,
      ATTRIBUTE2                 ,
      ATTRIBUTE3                 ,
      ATTRIBUTE4                 ,
      ATTRIBUTE5                 ,
      ATTRIBUTE6                 ,
      ATTRIBUTE7                 ,
      ATTRIBUTE8                 ,
      ATTRIBUTE9                 ,
      ATTRIBUTE10                ,
      ATTRIBUTE11                ,
      ATTRIBUTE12                ,
      ATTRIBUTE13                ,
      ATTRIBUTE14                ,
      ATTRIBUTE15                ,
      ATTRIBUTE_CATEGORY         ,
      ACCRUAL_ACCOUNT_ID         ,
      BUDGET_ACCOUNT_ID          ,
      VARIANCE_ACCOUNT_ID        ,
      government_context         ,
      project_id                 ,
      task_id                    ,
      expenditure_type           ,
      project_accounting_context ,
      expenditure_organization_id,
      project_related_flag       ,
      expenditure_item_date      ,
      RECOVERY_RATE              ,
      TAX_RECOVERY_OVERRIDE_FLAG ,
      NONRECOVERABLE_TAX         ,
      ORG_ID                     ,
      prevent_encumbrance_flag
      )
    SELECT
      PO_REQ_DISTRIBUTIONS_S.NEXTVAL,
      SYSDATE                          ,
      p_user_id                        ,
      p_req_line_id                    ,
      PORD.set_of_books_id             ,
      PORD.code_combination_id         ,
      (PORD.req_line_quantity
         - l_uom_conv * greatest(NVL(POD.quantity_delivered, 0),
                          NVL(POD.quantity_billed, 0))
       )                                                                           ,
      p_login_id                                                                   ,
      SYSDATE                                                                      ,
      p_user_id                                                                    ,
      rownum                                                                       ,
      PORD.gl_encumbered_date                                                      ,
      PORD.gl_encumbered_period_name                                               ,
      PORD.gl_cancelled_date                                                       ,
      PORD.failed_funds_lookup_code                                                ,
      PORD.distribution_id                                                         ,
      PORD.ATTRIBUTE1                                                              ,
      PORD.ATTRIBUTE2                                                              ,
      PORD.ATTRIBUTE3                                                              ,
      PORD.ATTRIBUTE4                                                              ,
      PORD.ATTRIBUTE5                                                              ,
      PORD.ATTRIBUTE6                                                              ,
      PORD.ATTRIBUTE7                                                              ,
      PORD.ATTRIBUTE8                                                              ,
      PORD.ATTRIBUTE9                                                              ,
      PORD.ATTRIBUTE10                                                             ,
      PORD.ATTRIBUTE11                                                             ,
      PORD.ATTRIBUTE12                                                             ,
      PORD.ATTRIBUTE13                                                             ,
      PORD.ATTRIBUTE14                                                             ,
      PORD.ATTRIBUTE15                                                             ,
      PORD.ATTRIBUTE_CATEGORY                                                      ,
      PORD.ACCRUAL_ACCOUNT_ID                                                      ,
      PORD.BUDGET_ACCOUNT_ID                                                       ,
      PORD.VARIANCE_ACCOUNT_ID                                                     ,
      PORD.government_context                                                      ,
      PORD.project_id                                                              ,
      PORD.task_id                                                                 ,
      PORD.expenditure_type                                                        ,
      PORD.project_accounting_context                                              ,
      PORD.expenditure_organization_id                                             ,
      PORD.project_related_flag                                                    ,
      PORD.expenditure_item_date                                                   ,
      PORD.RECOVERY_RATE                                                           ,
      PORD.TAX_RECOVERY_OVERRIDE_FLAG                                              ,
      (DECODE(
         SIGN(PORD.req_line_quantity
          - l_uom_conv * greatest(NVL(POD.quantity_delivered, 0),
                           NVL(POD.quantity_billed, 0)
                         )
         ),
         -1,
         0,
         (PORD.req_line_quantity
            - l_uom_conv * greatest(NVL(POD.quantity_delivered, 0),
                             NVL(POD.quantity_billed, 0)
                           )
         )
       ) / PORD.req_line_quantity) * PORD.nonrecoverable_tax,
      PORL_NEW.ORG_ID                                                                                                                         ,
      NVL(DECODE( POD.prevent_encumbrance_flag,
            'Y',
            'Y',
            DECODE(
              PORL_NEW.org_id,
              BLANKET.org_id,
              BLANKET.encumbrance_required_flag,
              NULL )
          ),
       'N')

    FROM
      PO_REQ_DISTRIBUTIONS_ALL PORD   ,
      PO_REQUISITION_LINES_ALL PORL_OLD,
      PO_REQUISITION_LINES_ALL PORL_NEW,
      PO_DISTRIBUTIONS_ALL POD         ,
      PO_LINE_LOCATIONS PLL            ,
      po_headers BLANKET
    WHERE
      PORL_NEW.requisition_line_id   = p_req_line_id
      AND PORL_OLD.requisition_line_id = (-1) * PORL_NEW.parent_req_line_id
      AND PORD.requisition_line_id     = PORL_OLD.requisition_line_id
      AND POD.req_distribution_id      = PORD.distribution_id
      AND POD.line_location_id         = PLL.line_location_id
      AND PLL.shipment_type IN (
            'STANDARD',
            'PLANNED' ,
            'BLANKET')
      AND NVL(POD.quantity_cancelled, 0) >= 0
      AND PORL_NEW.blanket_po_header_id   = BLANKET.po_header_id(+)
      AND (PORD.req_line_quantity
             - l_uom_conv * Greatest(NVL(POD.quantity_delivered, 0),
                               NVL(POD.quantity_billed, 0))
           > 0) ;

    -- bug 18647987 starts
    POGMS_PKG.UPDATE_ADLS (p_req_line_id=>p_req_line_id,
                           err_code=>x_return_status,
                           err_msg=>x_msg_data);

    IF (x_return_status = FND_API.g_ret_sts_error) THEN
      RAISE FND_API.g_exc_error;
    ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
      RAISE FND_API.g_exc_unexpected_error;
    END IF;
    -- bug 18647987 ends

  EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_msg_data := FND_MSG_PUB.GET(
                      P_MSG_INDEX => FND_MSG_PUB.G_LAST,
                      P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.add_exc_msg(g_module_prefix, d_api_name||':'||l_progress||':'||SQLCODE||':'||SQLERRM);
    WHEN FND_API.G_EXC_ERROR THEN
      x_msg_data := FND_MSG_PUB.GET(
                      P_MSG_INDEX => FND_MSG_PUB.G_LAST,
                      P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.add_exc_msg(g_module_prefix, d_api_name||':'||l_progress||':'||SQLCODE||':'||SQLERRM);
    WHEN OTHERS THEN
      IF (G_DEBUG_UNEXP) THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
	FND_LOG.STRING(
          FND_LOG.LEVEL_UNEXPECTED,
          d_module || '.OTHERS_EXCEPTION',
          'EXCEPTION: LOCATION IS ' || l_progress || ' SQL CODE IS '||SQLCODE);
	  END IF;
      END IF;

      x_msg_data := FND_MSG_PUB.GET(
                      P_MSG_INDEX => FND_MSG_PUB.G_LAST,
                      P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.add_exc_msg(g_module_prefix, d_api_name||':'||l_progress||':'||SQLCODE||':'||SQLERRM);

  END create_req_dist;

--------------------------------------------------------------------------------
--Start of Comments
--Name: update_requisitions
--Function:
--  Updates the  cancel details on  backing requisition lines.
--  If recreate_demand is OFF, have to cancel the req lines. If before
--   Funds Checker call, change cancel_flag to 'I', if after, change flag
--  If recreate_demand is ON then :
--   If nothing has been billed/delivered:
--   Mark the distributions belonging to the req line.
--   Set the quantity on each req distribution to be that on the
--   PO distribution.
--   Set the quantity on the req line to be the sum of the
--   quantities on the req distributions.  Set the price to be
--   the price_override from the PO shipment times the calculated
--   foreign currency exchange rate (1.0 for base currency POs).
--   Set the unit of measure and unit class to be the same as
--   those on the PO line.
--   Also note that if the fc_mode is c_before_FC,  we have
--   to make sure that no one uses the 'freed-up' req line.
--   This is done by temporarily setting the porl.line_loc_id to
--   the negative of the corresponding poll.line_location_id.
--  When this routine is later called with fc_mode=c_after_FC,
--   this is updated to be Null, and hence freed-up.
--   Otherwise(if billed/delivered >0):
--   Create a new req line.  Set the quantity to be that which has not
--   been billed/delivered.  Set the price, UOM, UOM class as above.
--   Adjust the old req line.  Set the quantity to be that which HAS
--   been billed/delivered.  Set the price, UOM, UOM class as above.
--   Create new req distributions.  Adjust the quantities to be that
--   which has NOT been billed/delivered.
--   Adjust the old req distributions.  Set the quantity to be that
--   which HAS been billed/delivered.  Set the price, UOM,
--   UOM class as above.
--   Same note for fc_mode applies: On the newly created req lines,
--   line_location_id is set to negative of poll.line_location_id
--   if fc_mode=c_before_FC. When fc_mode=c_after_FC, this column
--   will be corrected to be Null.
--
--Parameters:
--IN:
--  p_entity_level
--  p_action_date
--  p_entity_id
--  p_document_type
--  p_doc_subtype
--  p_cancel_reason
--  p_fc_level
--  p_recreate_demand
--  p_req_enc_flag
--  P_user_id
--  p_login_id
--
--
--IN OUT :
--OUT :
-- x_req_line_id_tbl
-- x_msg_data
-- x_return_status
--     FND_API.G_RET_STS_SUCCESS if cancel action succeeds
--     FND_API.G_RET_STS_ERROR if cancel action fails
--     FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
--
--End of Comments
--------------------------------------------------------------------------------

PROCEDURE update_requisitions(
            p_api_version     IN NUMBER,
            p_init_msg_list   IN VARCHAR2,
            p_entity_level    IN VARCHAR2,
            p_action_date     IN DATE,
            p_entity_id       IN NUMBER,
            p_document_type   IN VARCHAR2,
            p_doc_subtype     IN VARCHAR2,
            p_cancel_reason   IN VARCHAR2,
            p_fc_level        IN VARCHAR2,
            p_recreate_demand IN VARCHAR2,
            p_req_enc_flag    IN VARCHAR2,
            p_user_id         IN po_lines.last_updated_by%TYPE,
            p_login_id        IN po_lines.last_update_login%TYPE,
            x_is_new_line     IN OUT NOCOPY VARCHAR2,
            x_return_status   OUT NOCOPY VARCHAR2,
            x_msg_data        OUT NOCOPY VARCHAR2,
            x_req_line_id_tbl OUT NOCOPY PO_ReqChangeRequestWF_PVT.ReqLineID_tbl_type)
  IS

    d_api_name CONSTANT VARCHAR2(30) := 'update_requisitions';
    d_api_version CONSTANT NUMBER := 1.0;
    d_module   CONSTANT VARCHAR2(100) := g_module_prefix|| d_api_name;
    l_progress        VARCHAR2(8)            := '000' ;
    l_qty_cancelled   NUMBER                 := 0;
    l_uom_conv        NUMBER                 := 0;
    l_quantity        NUMBER                 := 0;
    l_msg_count       NUMBER                 := 0;
    l_status          BOOLEAN;
    l_new_req_line_id NUMBER;

    /* Bug 16880686 starts */
    l_req_header_id    PO_REQUISITION_HEADERS.REQUISITION_HEADER_ID%TYPE;
    l_line_location_id PO_LINE_LOCATIONS.LINE_LOCATION_ID%TYPE;
    l_drop_ship_flag   PO_LINE_LOCATIONS.DROP_SHIP_FLAG%TYPE;
    /* Bug 16880686 ends */

  BEGIN
    -- Start standard API initialization
    IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    IF NOT FND_API.compatible_api_call(d_api_version, p_api_version,
                                        d_api_name, g_pkg_name) THEN
      RAISE FND_API.g_exc_unexpected_error;
    END IF;


    IF g_debug_stmt THEN
      PO_DEBUG.debug_begin(d_module);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_entity_level', p_entity_level);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_action_date', p_action_date);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_entity_id', p_entity_id);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_document_type', p_document_type);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_doc_subtype', p_doc_subtype);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_cancel_reason', p_cancel_reason);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_fc_level', p_fc_level);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_recreate_demand', p_recreate_demand);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_req_enc_flag', p_req_enc_flag);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_user_id', p_user_id);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_login_id', p_login_id);
      PO_DEBUG.debug_var(d_module, l_progress, 'x_is_new_line', x_is_new_line);

    END IF;

    l_progress := '002' ;

	-- Bug#16214876:: It was not possible to auocreate PO from the requisition
    -- again after the emergency PO is canceled.
    -- START of BUGFIX#16214876
    IF p_entity_level = 'HEADER'
    THEN

    UPDATE po_requisition_headers_all
    SET emergency_po_num         = NULL
    WHERE
    emergency_po_num =
      (SELECT segment1 FROM po_headers_all
	   WHERE po_header_id = p_entity_id);

    END IF;
    -- END of BUGFIX#16214876

    -- get_linked_req_lines to the entity being canceled
    fetch_req_lines(
      p_api_version=> 1.0,
      p_init_msg_list=>FND_API.G_FALSE,
      p_entity_id => p_entity_id,
      p_entity_level =>p_entity_level,
      p_document_type =>p_document_type,
      p_doc_subtype =>p_doc_subtype,
      p_fc_level => p_fc_level,
      x_return_status =>x_return_status,
      x_req_line_id_tbl =>x_req_line_id_tbl);


    IF (x_return_status = FND_API.g_ret_sts_error) THEN
      RAISE FND_API.g_exc_error;
    ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
      RAISE FND_API.g_exc_unexpected_error;
    END IF;


    IF g_debug_stmt THEN
      PO_DEBUG.debug_var(d_module, l_progress, 'x_req_line_id_tbl.count', x_req_line_id_tbl.count);
    END IF;

    l_progress := '003' ;


    FOR i IN 1..x_req_line_id_tbl.count
    LOOP

      -- If recraete_demand is OFF, We have to cancel the req lines.
      -- If p_fc_level=c_before_FC, then change cancel_flag to 'I',
      -- else change flag to 'Y'
      IF p_recreate_demand = 'N' THEN

        IF p_fc_level = c_before_FC THEN

            x_is_new_line :='N';
          -- Update Cancel_flag to 'I' for the req line and line_location_id
          -- to -line_location_id, so that it will not be fetched else where
          -- till this cancel action completes
          UPDATE PO_REQUISITION_LINES_ALL PORL
          SET    PORL.cancel_flag         = 'I'       ,
                 PORL.LAST_UPDATE_DATE    = SYSDATE   ,
                 PORL.LAST_UPDATED_BY     = p_user_id ,
                 PORL.LAST_UPDATE_LOGIN   = p_login_id,
                 PORL.line_location_id    = -1 * PORL.line_location_id
          WHERE  PORL.requisition_line_id = x_req_line_id_tbl(i);

          IF g_debug_stmt THEN
            PO_DEBUG.debug_var(d_module, l_progress, 'update_req lines before_fc', SQL%ROWCOUNT);
          END IF;

        ELSE

          l_progress := '004' ;

          -- Update Cancel_flag to 'Y',quantity for the req line and its distribution
          update_req_details_after_fc(
            p_api_version=> 1.0,
            p_init_msg_list=>FND_API.G_FALSE,
            p_req_line_id=>x_req_line_id_tbl(i),
            p_recreate_demand_flag=>p_recreate_demand,
            p_user_id=>p_user_id,
            p_login_id=>p_login_id,
            p_is_new_req_line=>x_is_new_line,
            x_msg_data =>x_msg_data,
            x_return_status =>x_return_status);


          IF (x_return_status = FND_API.g_ret_sts_error) THEN
            RAISE FND_API.g_exc_error;
          ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
            RAISE FND_API.g_exc_unexpected_error;
          END IF;

          l_progress := '005' ;

          -- Remove the Req Line Supply from mtl supply table
          cancel_supply(
            p_api_version=> 1.0,
            p_init_msg_list=>FND_API.G_FALSE,
            p_entity_level =>NULL,
            p_entity_id =>x_req_line_id_tbl(i),
            p_doc_id =>x_req_line_id_tbl(i),
            p_document_type =>c_doc_type_REQUISITION,
            p_doc_subtype =>NULL,
            p_recreate_flag =>'N',
            x_return_status =>x_return_status,
            x_msg_data =>x_msg_data);

          IF (x_return_status = FND_API.g_ret_sts_error) THEN
            RAISE FND_API.g_exc_error;
          ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
            RAISE FND_API.g_exc_unexpected_error;
          END IF;


        END IF; --p_fc_level

      ELSE -- If recreate_demand is ON then

        IF p_fc_level = c_before_FC THEN

          l_progress := '006' ;

          -- if nothing has been billed/delivered ,then we don't need
          --  to create a new req line; we just need to update the old one,
          -- since all ordered is cancelled
          IF is_qty_del_bill_zero(
               p_api_version=> 1.0,
               p_init_msg_list=> FND_API.G_FALSE,
               p_req_line_id=>x_req_line_id_tbl(i)) THEN

            x_is_new_line :='N';

            --The below sql will only consider the req distributions which are sourced to a blanket agreement

            UPDATE PO_REQ_DISTRIBUTIONS_ALL PORD
            SET    PORD.last_update_date         = SYSDATE   ,
                   PORD.last_updated_by          = p_user_id ,
                   PORD.last_update_login        = p_login_id,
                   PORD.prevent_encumbrance_flag =
                     (SELECT NVL(DECODE(
                                   POD.prevent_encumbrance_flag,
                                   'Y',
                                   'Y',
                                    DECODE(PORL.org_id,
                                       BLANKET.org_id,
                                       BLANKET.encumbrance_required_flag,
                                       NULL)),
                                  'N')
                      FROM  PO_REQUISITION_LINES_ALL PORL,
                            PO_DISTRIBUTIONS_ALL POD     ,
                            po_line_locations PLL    ,
                            po_headers BLANKET
                      WHERE PORL.requisition_line_id    = PORD.requisition_line_id
                            AND POD.req_distribution_id = PORD.distribution_id
                            AND POD.line_location_id    = PLL.line_location_id
                            AND PLL.shipment_type IN (
                                 'STANDARD',
                                 'PLANNED' ,
                                 'BLANKET')
                            AND PORL.blanket_po_header_id = BLANKET.po_header_id)
            WHERE PORD.requisition_line_id= x_req_line_id_tbl(i)
                  AND EXISTS (SELECT   1
 	                            FROM  po_requisition_lines_all porl
 	                            WHERE porl.requisition_line_id = PORD.requisition_line_id
 	                                  AND porl.blanket_po_header_id IS NOT NULL);

            IF g_debug_stmt THEN
              PO_DEBUG.debug_var(d_module, l_progress, 'update_req Dsitributions before_fc', SQL%ROWCOUNT);
            END IF;


            l_progress := '007' ;

            -- The below sql is to update the prevent encumbrance flag for all the req distributions
 	          -- whose autocreated Standard PO/Release are backed by encumbered GBPA

 	          -- The prevent encumbrance flag is updated to 'Y' when the main document is reserved
 	          -- and is backed by an encumbered BPA
 	          -- The prevent encumbrance flag to 'N' on all the req distributions
 	          -- which were processed during Reserve action

            UPDATE PO_REQ_DISTRIBUTIONS_ALL PORD
 	          SET    PORD.last_update_date = SYSDATE,
 	                 PORD.last_updated_by = p_user_id,
 	                 PORD.last_update_login = p_login_id,
 	                 PORD.prevent_encumbrance_flag =
 	                 DECODE(
                     p_req_enc_flag,
                    'Y',
                    'N',
                    pord.prevent_encumbrance_flag)
 	          WHERE   PORD.requisition_line_id = x_req_line_id_tbl(i)
 	                  AND EXISTS (SELECT 1
 	                              FROM   po_requisition_lines_all porl
 	                              WHERE  porl.requisition_line_id = PORD.requisition_line_id
 	                                     AND porl.blanket_po_header_id IS NULL)
 	                  AND EXISTS (SELECT  1
 	                              FROM    po_distributions_all poda,
 	                                      po_lines pol,
 	                                      po_distributions_all pod
 	                              WHERE   poda.po_header_id = pol.from_header_id
 	                                      AND pol.po_line_id = pod.po_line_id
 	                                      AND pod.req_distribution_id = pord.distribution_id
 	                                      AND pod.distribution_type = c_doc_subtype_STANDARD
 	                              UNION
 	                              SELECT  1
 	                              FROM    po_distributions_all poda,
                                        po_distributions_all pod
 	                              WHERE   pod.req_distribution_id = pord.distribution_id
 	                                      AND pod.distribution_type = c_doc_subtype_BLANKET
 	                                      AND pod.po_header_id = poda.po_header_id
 	                                      AND poda.distribution_type = 'AGREEMENT');

            --Update the requisition line.  Get the quantity from the
            -- requisition distributions first.


            SELECT SUM(PORD.REQ_LINE_QUANTITY)
            INTO   l_quantity
            FROM   PO_REQ_DISTRIBUTIONS_ALL PORD
            WHERE  PORD.REQUISITION_LINE_ID = x_req_line_id_tbl(i);

            IF g_debug_stmt THEN
              PO_DEBUG.debug_var(d_module, l_progress, 'l_quantity', l_quantity);
            END IF;

            l_progress := '008';

            UPDATE PO_REQUISITION_LINES_ALL PORL
            SET(
              PORL.LINE_LOCATION_ID,
              PORL.QUANTITY        ,
              PORL.LAST_UPDATE_DATE,
              PORL.LAST_UPDATED_BY ,
              PORL.LAST_UPDATE_LOGIN) =
              (
              SELECT
                (-1 * PORL.LINE_LOCATION_ID),
                DECODE(porl.order_type_lookup_code,
                  'RATE', NULL,
                  'FIXED PRICE',NULL,
                  l_quantity),
                SYSDATE           ,
                p_user_id         ,
                p_login_id
              FROM po_line_locations POLL,
                   po_lines POL
              WHERE PORL.LINE_LOCATION_ID  = POLL.LINE_LOCATION_ID
                     AND POLL.PO_LINE_ID    = POL.PO_LINE_ID
             )
            WHERE PORL.REQUISITION_LINE_ID = x_req_line_id_tbl(i);

            IF g_debug_stmt THEN
              PO_DEBUG.debug_var(d_module, l_progress, 'update_req Lines before_fc', SQL%ROWCOUNT);
            END IF;

          ELSE

            --  if something has been billed/delivered, we need to create a new
            --  req line for freed up (=cancelled) orders and update the
            --  quantities on oldreq lines and distributions.

            l_progress := '009';

            x_is_new_line :='Y';

            -- Get the UOM conversion between req line and its corresponding PO Line
            calc_uom_conv (
              p_api_version=> 1.0,
              p_init_msg_list=>FND_API.G_FALSE,
              p_fc_level=>c_before_FC,
              p_req_line_id=>x_req_line_id_tbl(i),
              x_uom_conv=>l_uom_conv);


            IF g_debug_stmt THEN
              PO_DEBUG.debug_var(d_module, l_progress, 'l_uom_conv', l_uom_conv);
            END IF;

            l_progress := '010';

            -- Calculate the quantity  left over quanity to be updated on new req line.
            calc_qty_canceled(
              p_api_version=> 1.0,
              p_init_msg_list=>FND_API.G_FALSE,
              p_req_line_id=>x_req_line_id_tbl(i),
              p_uom_conv=>l_uom_conv,
              x_qty_cancelled=>l_qty_cancelled);

            IF g_debug_stmt THEN
              PO_DEBUG.debug_var(d_module, l_progress, 'l_qty_cancelled', l_qty_cancelled);
            END IF;

            IF l_qty_cancelled <> 0 THEN
              -- If the quantity delivered/billed on the PO is less than the quantity
              -- that was ordered  on the Req ,then create new req line and distribution
              create_req_line(
                p_api_version=> 1.0,
                p_init_msg_list=>FND_API.G_FALSE,
                p_old_line_id =>x_req_line_id_tbl(i),
                p_line_quantity =>l_qty_cancelled,
                p_user_id =>p_user_id,
                p_login_id =>p_login_id,
                x_new_line_id =>l_new_req_line_id,
                x_return_status =>x_return_status,
                x_msg_data =>x_msg_data);

              IF (x_return_status = FND_API.g_ret_sts_error) THEN
                RAISE FND_API.g_exc_error;
              ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
                RAISE FND_API.g_exc_unexpected_error;
              END IF;


              create_req_dist(
                p_api_version=> 1.0,
                p_init_msg_list=>FND_API.G_FALSE,
                p_req_line_id=>l_new_req_line_id,
                p_user_id =>p_user_id,
                p_login_id =>p_login_id,
                x_return_status =>x_return_status,
                x_msg_data =>x_msg_data);

              IF (x_return_status = FND_API.g_ret_sts_error) THEN
                RAISE FND_API.g_exc_error;
              ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
                RAISE FND_API.g_exc_unexpected_error;
              END IF;

            ELSE
              -- If l_qty_cancelled =0 (i.e., the quantity delivered/billed on the PO is
              -- greater than or equal to the quantity that was ordered  on the Req)
              -- then we are setting the cancel_flag of the Req line to 'Y',
              -- so that the encumbrance code avoids picking it up.
              -- Note that the "after_fc" cursor in fetch_req_lines does not
              -- fetch these Req lines, as their line_location_id had never
              -- been negated.

              UPDATE PO_REQUISITION_LINES_ALL PORL
              SET    PORL.cancel_flag = 'Y',--doubt
                     PORL.contractor_status   = NULL     ,
                     PORL.cancel_date         = SYSDATE  ,
                     PORL.last_update_date    = SYSDATE  ,
                     PORL.last_updated_by     = p_user_id,
                     PORL.last_update_login   = p_login_id
              WHERE PORL.requisition_line_id = x_req_line_id_tbl(i);

            END IF ; -- l_qty_cancelled<>0


            UPDATE PO_REQ_DISTRIBUTIONS_ALL PORD
            SET    PORD.last_update_date    = SYSDATE  ,
                   PORD.last_updated_by     = p_user_id,
                   PORD.last_update_login   = p_login_id
            WHERE PORD.requisition_line_id = x_req_line_id_tbl(i);


          END IF; -- if is_qty_del_bill_zero

        ELSE --p_fc_level=c_after_FC

          -- Now we have 2 situations after funds checker:
          --   1. No new req lines are created, so all we have to do is null out
          --      PORL.line_location_id (= free up the req line).
          --   2. A new req line with new distribution associated with it must
          --      have been created.So we need to Null out the line_location_id
          --      of this new req. line.
          --      Call supply to create a req supply for the new lines.

          --   Note that The req_line_id available now is the new req line created.
          --   in this situation the old req line (reflecting  amount already
          --   received/billed and hence noncancellable) has
          --   been updated during pre_fundschecker and we don't even get it here.

          update_req_details_after_fc(
            p_api_version=> 1.0,
            p_init_msg_list=>FND_API.G_FALSE,
            p_req_line_id=>x_req_line_id_tbl(i),
            p_recreate_demand_flag=>p_recreate_demand,
            p_user_id=>p_user_id,
            p_login_id=>p_login_id,
            p_is_new_req_line=>x_is_new_line,
            x_return_status =>x_return_status,
            x_msg_data =>x_msg_data);

          IF (x_return_status = FND_API.g_ret_sts_error) THEN
            RAISE FND_API.g_exc_error;
          ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
            RAISE FND_API.g_exc_unexpected_error;
          END IF;

        -- Create req supply for the new lines
          l_status := po_supply.po_req_supply(
                        p_docid => 0,
                        p_lineid =>x_req_line_id_tbl(i),
                        p_shipid =>0,
                        p_action =>'Create_Req_Line_Supply',
                        p_recreate_flag =>TRUE,
                        p_qty =>0,
                        p_receipt_date =>SYSDATE,
                        p_reservation_action=>NULL,
                        p_ordered_uom =>NULL);


        END IF; -- if p_fc_level=c_before_FC
      END IF;  ---p_recreate_demand = 'N'

      /* Bug 16880686 starts */
      /* Need to call OE_DROP_SHIP_GRP.Update_Drop_Ship_links with the line_location_id,
         to remove the link of cancelled PO shipment and SO line from oe_drop_ship_sources.  */

      IF (p_fc_level = c_before_FC ) THEN
         x_return_status := 'S';

         SELECT pll.line_location_id, nvl(pll.drop_ship_flag, 'N')
	 INTO  l_line_location_id, l_drop_ship_flag
	 FROM  po_requisition_lines_all prla, po_line_locations pll
	 --  bug#17427866: use abs for req. line_location_id
         --  WHERE (-1*(prla.line_location_id)) = pll.line_location_id
         WHERE ABS(prla.line_location_id) = pll.line_location_id
	 AND  prla.requisition_line_id = x_req_line_id_tbl(i)
	 AND  rownum = 1;

	 IF g_debug_stmt THEN
	    PO_DEBUG.debug_var(d_module, l_progress, 'x_req_line_id_tbl(i) :', x_req_line_id_tbl(i));
	    PO_DEBUG.debug_var(d_module, l_progress, 'l_line_location_id :', l_line_location_id);
	    PO_DEBUG.debug_var(d_module, l_progress, 'l_drop_ship_flag :', l_drop_ship_flag);
	 END IF;

	 IF l_drop_ship_flag = 'Y' THEN
	    l_progress := '011';

	    SELECT requisition_header_id
	    INTO  l_req_header_id
	    FROM  po_requisition_lines_all prla
	    WHERE prla.requisition_line_id = x_req_line_id_tbl(i);

            IF g_debug_stmt THEN
	       PO_DEBUG.debug_var(d_module, l_progress, 'l_req_header_id :', l_req_header_id);
	    END IF;

	    /* Bug 19217875 */
	    -- In case when partial shipment has been received and remaining cancelled,
	    -- the requisition line gets split into two. Second requisition line has
	    -- available quantity, so now the oe_drop_ship_sources new line should link
	    -- with the new requisition line.

	    IF (l_new_req_line_id IS NOT NULL) THEN
	    	OE_DROP_SHIP_GRP.Update_Drop_Ship_links(
                      p_api_version => 1.0,
                      p_po_header_id => null,
                      p_po_release_id => null,
                      p_po_line_id => null,
                      p_po_line_location_id => l_line_location_id,
                      p_new_req_hdr_id => l_req_header_id,
                      p_new_req_line_id => l_new_req_line_id,
                      x_return_status  => x_return_status,
                      x_msg_data  => x_msg_data,
                      x_msg_count  => l_msg_count);

		IF (x_return_status = FND_API.g_ret_sts_error) THEN
			RAISE FND_API.g_exc_error;
		ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
			RAISE FND_API.g_exc_unexpected_error;
		ELSIF (x_return_status IS NULL) THEN
			x_return_status := 'S';
		END IF;

	    ELSE
	    	OE_DROP_SHIP_GRP.Update_Drop_Ship_links(
                      p_api_version => 1.0,
                      p_po_header_id => null,
                      p_po_release_id => null,
                      p_po_line_id => null,
                      p_po_line_location_id => l_line_location_id,
                      p_new_req_hdr_id => l_req_header_id,
                      p_new_req_line_id => x_req_line_id_tbl(i),
                      x_return_status  => x_return_status,
                      x_msg_data  => x_msg_data,
                      x_msg_count  => l_msg_count);

	    	IF (x_return_status = FND_API.g_ret_sts_error) THEN
			RAISE FND_API.g_exc_error;
		ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
			RAISE FND_API.g_exc_unexpected_error;
		ELSIF (x_return_status IS NULL) THEN
			x_return_status := 'S';
		END IF;

	    END IF;
	 END IF;

         IF g_debug_stmt THEN
            PO_DEBUG.debug_var(d_module, l_progress, 'After Update_Drop_Ship_links: Return Status :', x_return_status);
	    PO_DEBUG.debug_var(d_module, l_progress, 'x_msg_data :', x_msg_data);
	 END IF;
      END IF;

      /* Bug 16880686 ends */

    END LOOP;

  EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_msg_data := FND_MSG_PUB.GET(
                      P_MSG_INDEX => FND_MSG_PUB.G_LAST,
                      P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.add_exc_msg(g_module_prefix, d_api_name||':'||l_progress||':'||SQLCODE||':'||SQLERRM);
      IF (g_debug_unexp) THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
	FND_LOG.STRING(
          FND_LOG.LEVEL_UNEXPECTED,
          d_module || '.Error',
          'Error: LOCATION IS '|| l_progress || ' SQL CODE IS '||SQLCODE);
	  END IF;
      END IF;


    WHEN FND_API.G_EXC_ERROR THEN
      x_msg_data := FND_MSG_PUB.GET(
                      P_MSG_INDEX => FND_MSG_PUB.G_LAST,
                      P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.add_exc_msg(g_module_prefix, d_api_name||':'||l_progress||':'||SQLCODE||':'||SQLERRM);
      IF (g_debug_unexp) THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
	FND_LOG.STRING(
          FND_LOG.LEVEL_UNEXPECTED,
          d_module || '.UnExpected',
          'EXCEPTION: LOCATION IS '|| l_progress || ' SQL CODE IS '||SQLCODE);
	  END IF;
      END IF;

    WHEN OTHERS THEN
      IF (g_debug_unexp) THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
	FND_LOG.STRING(
          FND_LOG.LEVEL_UNEXPECTED,
          d_module || '.OTHERS',
          'EXCEPTION: LOCATION IS '|| l_progress || ' SQL CODE IS '||SQLCODE);
	  END IF;
      END IF;
      FND_MSG_PUB.add_exc_msg(g_module_prefix, d_api_name||':'||l_progress||':'||SQLCODE||':'||SQLERRM);
      x_msg_data := FND_MSG_PUB.GET(
                      P_MSG_INDEX => FND_MSG_PUB.G_LAST,
                      P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;



END update_requisitions;

--------------------------------------------------------------------------------
--Start of Comments
--Name: update_req_po_after_fc
--Function:
--  Updates the  cancel details(ex: cancel_flag ='Y')on document being canceled
--  and backing requisition lines after the funds control call
-- (i.e. unencumbering the Document).

--Parameters:
--IN:
--  p_entity_level
--  p_action_date
--  p_entity_id
--  p_doc_id
--  p_document_type
--  p_doc_subtype
--  p_cancel_reason
--  p_recreate_demand
--  p_req_enc_flag
--  p_user_id
--  p_login_id
--
--
--IN OUT :
--OUT :
-- x_msg_data
-- x_return_status
--     FND_API.G_RET_STS_SUCCESS if cancel action succeeds
--     FND_API.G_RET_STS_ERROR if cancel action fails
--     FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
--
--End of Comments
--------------------------------------------------------------------------------

PROCEDURE update_req_po_after_fc(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2,
            p_entity_level   IN VARCHAR2,
            p_action_date    IN DATE,
            p_entity_id      IN NUMBER,
            p_doc_id         IN NUMBER,
            p_document_type  IN VARCHAR2,
            p_doc_subtype    IN VARCHAR2,
            p_cancel_reason  IN VARCHAR2,
            p_recreate_flag  IN VARCHAR2,
            p_note_to_vendor IN VARCHAR2,
            p_req_enc_flag   IN VARCHAR2,
            p_source         IN VARCHAR2,
            p_user_id        IN po_lines.last_updated_by%TYPE,
            p_login_id       IN po_lines.last_update_login%TYPE,
            x_is_new_line    IN OUT NOCOPY VARCHAR2,
            x_return_status  IN OUT NOCOPY VARCHAR2,
            x_msg_data       IN OUT NOCOPY VARCHAR2)
  IS

    d_api_name CONSTANT VARCHAR2(30) := 'update_req_po_after_fc';
    d_api_version CONSTANT NUMBER := 1.0;
    d_module   CONSTANT VARCHAR2(100) := g_module_prefix|| d_api_name;

    l_progress VARCHAR2(3)            := '000' ;
    l_fc_level CONSTANT VARCHAR2(10)  := c_after_FC;
    l_req_line_id_tbl PO_ReqChangeRequestWF_PVT.ReqLineID_tbl_type;


  BEGIN
    -- Start standard API initialization
    IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    IF NOT FND_API.compatible_api_call(d_api_version, p_api_version,
                                        d_api_name, g_pkg_name) THEN
      RAISE FND_API.g_exc_unexpected_error;
    END IF;


    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_msg_data      := NULL;

    IF g_debug_stmt THEN
      PO_DEBUG.debug_begin(d_module);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_entity_level', p_entity_level);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_action_date', p_action_date);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_entity_id', p_entity_id);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_doc_id', p_doc_id);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_document_type', p_document_type);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_doc_subtype', p_doc_subtype);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_cancel_reason', p_cancel_reason);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_recreate_flag', p_recreate_flag);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_req_enc_flag', p_req_enc_flag);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_user_id', p_user_id);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_login_id', p_login_id);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_note_to_vendor', p_note_to_vendor);
      PO_DEBUG.debug_var(d_module, l_progress, 'x_is_new_line', x_is_new_line);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_source',p_source);

    END IF;


    -- Update the cancel details on document after funds control call (unencumbering the document)
    update_document(
      p_api_version=> 1.0,
      p_init_msg_list=>FND_API.G_FALSE,
      p_entity_level =>p_entity_level,
      p_action_date =>p_action_date,
      p_entity_id =>p_entity_id,
      p_document_type =>p_document_type,
      p_doc_subtype =>p_doc_subtype,
      p_cancel_reason =>p_cancel_reason,
      p_recreate_demand =>p_recreate_flag,
      p_fc_level =>l_fc_level,
      p_note_to_vendor =>p_note_to_vendor,
      p_user_id =>p_user_id,
      p_login_id => p_login_id,
      x_return_status =>x_return_status,
      x_msg_data =>x_msg_data);



    IF (x_return_status = FND_API.g_ret_sts_error) THEN
      RAISE FND_API.g_exc_error;
    ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
      RAISE FND_API.g_exc_unexpected_error;
    END IF;

    l_progress := '001';
    -- Update the backing requisitions accordingly after funds control call
    -- (unencumbering the document)
    update_requisitions(
      p_api_version=> 1.0,
      p_init_msg_list=>FND_API.G_FALSE,
      p_entity_level =>p_entity_level,
      p_action_date =>p_action_date,
      p_entity_id =>p_entity_id,
      p_document_type =>p_document_type,
      p_doc_subtype =>p_doc_subtype,
      p_cancel_reason =>p_cancel_reason,
      p_recreate_demand =>p_recreate_flag,
      p_req_enc_flag  =>p_req_enc_flag,
      p_fc_level =>l_fc_level,
      p_user_id =>p_user_id,
      p_login_id =>p_login_id,
      x_is_new_line =>x_is_new_line,
      x_return_status =>x_return_status,
      x_msg_data =>x_msg_data,
      x_req_line_id_tbl =>l_req_line_id_tbl);

    IF (x_return_status = FND_API.g_ret_sts_error) THEN
      RAISE FND_API.g_exc_error;
    ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
      RAISE FND_API.g_exc_unexpected_error;
    END IF;

    l_progress := '002';

    -- Remove the supply for the entity being canceled
    cancel_supply(
      p_api_version=> 1.0,
      p_init_msg_list=>FND_API.G_FALSE,
      p_entity_level =>p_entity_level,
      p_entity_id =>p_entity_id,
      p_doc_id    =>p_doc_id,
      p_document_type =>p_document_type,
      p_doc_subtype =>p_doc_subtype,
      p_recreate_flag =>p_recreate_flag,
      x_return_status =>x_return_status,
      x_msg_data =>x_msg_data);

    IF (x_return_status = FND_API.g_ret_sts_error) THEN
      RAISE FND_API.g_exc_error;
    ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
      RAISE FND_API.g_exc_unexpected_error;
    END IF;


    l_progress := '003';

    -- Cancel corresponding tax lines
    cancel_tax_lines(
      p_api_version=> 1.0,
      p_init_msg_list=>FND_API.G_FALSE,
      p_entity_level =>p_entity_level,
      p_entity_id =>p_entity_id,
      p_doc_id    =>p_doc_id,
      p_document_type =>p_document_type,
      p_doc_subtype =>p_doc_subtype,
      x_return_status =>x_return_status,
      x_msg_data =>x_msg_data);


    IF (x_return_status = FND_API.g_ret_sts_error) THEN
      RAISE FND_API.g_exc_error;
    ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
      RAISE FND_API.g_exc_unexpected_error;
    END IF;

    l_progress := '004';

    -- As document is being canceled, cancel any pending Change Request on the PO /PO Shipment and
    -- also  any pending requester change request for the  underlying req
    cancel_pending_change_request(
      p_api_version=> 1.0,
      p_init_msg_list=>FND_API.G_FALSE,
      p_entity_level =>p_entity_level,
      p_entity_id =>p_entity_id,
      p_doc_id    =>p_doc_id,
      p_document_type =>p_document_type,
      p_doc_subtype =>p_doc_subtype,
      p_source =>p_source,
      p_req_line_id_tbl =>l_req_line_id_tbl,
      x_return_status =>x_return_status,
      x_msg_data =>x_msg_data);


    IF (x_return_status = FND_API.g_ret_sts_error) THEN
      RAISE FND_API.g_exc_error;
    ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
      RAISE FND_API.g_exc_unexpected_error;
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_msg_data := FND_MSG_PUB.GET(P_MSG_INDEX => FND_MSG_PUB.G_LAST,
                      P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.add_exc_msg(g_module_prefix, d_api_name||':'||l_progress||':'||SQLCODE||':'||SQLERRM);

    WHEN FND_API.G_EXC_ERROR THEN
      x_msg_data := FND_MSG_PUB.GET(P_MSG_INDEX => FND_MSG_PUB.G_LAST,
                                P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.add_exc_msg(g_module_prefix, d_api_name||':'||l_progress||':'||SQLCODE||':'||SQLERRM);


    WHEN OTHERS THEN
      IF (G_DEBUG_UNEXP) THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
	FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED, d_module || '.OTHERS_EXCEPTION', 'EXCEPTION: LOCATION IS ' || l_progress || ' SQL CODE IS '||SQLCODE);
	END IF;
      END IF;
      FND_MSG_PUB.add_exc_msg(g_module_prefix, d_api_name||':'||l_progress||':'||SQLCODE||':'||SQLERRM);
      x_msg_data := FND_MSG_PUB.GET(P_MSG_INDEX => FND_MSG_PUB.G_LAST,
                                P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;



  END update_req_po_after_fc;

--------------------------------------------------------------------------------
--Start of Comments
--Name: update_req_po_before_fc
--Function:
--  Updates the  cancel details(ex: cancel_flag ='I')on document being canceled
--  and backing requisition lines before the funds control call
--  (i.e. unencumbering the Document).

--Parameters:
--IN:
--  p_entity_level
--  p_action_date
--  p_entity_id
--  p_document_type
--  p_doc_subtype
--  p_cancel_reason
--  p_recreate_demand
--  p_req_enc_flag
--  p_user_id
--  p_login_id
--
--
--IN OUT :
--OUT :
-- x_msg_data
-- x_return_status
--     FND_API.G_RET_STS_SUCCESS if cancel action succeeds
--     FND_API.G_RET_STS_ERROR if cancel action fails
--     FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
--
--End of Comments
--------------------------------------------------------------------------------

PROCEDURE update_req_po_before_fc(
            p_api_version     IN NUMBER,
            p_init_msg_list   IN VARCHAR2,
            p_entity_level    IN VARCHAR2,
            p_action_date     IN DATE,
            p_entity_id       IN NUMBER,
            p_document_type   IN VARCHAR2,
            p_doc_subtype     IN VARCHAR2,
            p_cancel_reason   IN VARCHAR2,
            p_recreate_demand IN VARCHAR2,
            p_req_enc_flag    IN VARCHAR2,
            p_note_to_vendor  IN VARCHAR2,
            p_user_id         IN po_lines.last_updated_by%TYPE,
            p_login_id        IN po_lines.last_update_login%TYPE,
            x_is_new_line     IN OUT NOCOPY VARCHAR2,
            x_return_status   IN OUT NOCOPY VARCHAR2,
            x_msg_data        IN OUT NOCOPY VARCHAR2)

IS

  d_api_name CONSTANT VARCHAR2(30) := 'update_req_po_before_fc';
  d_api_version CONSTANT NUMBER := 1.0;
  d_module   CONSTANT VARCHAR2(100) := g_module_prefix|| d_api_name;

  l_progress VARCHAR2(3)            := '000' ;
  l_fc_level VARCHAR2(10)           := c_before_FC ;
  l_req_line_id_tbl PO_ReqChangeRequestWF_PVT.ReqLineID_tbl_type;


BEGIN
  -- Start standard API initialization
  IF FND_API.to_boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  IF NOT FND_API.compatible_api_call(d_api_version, p_api_version,
                                      d_api_name, g_pkg_name) THEN
    RAISE FND_API.g_exc_unexpected_error;
  END IF;


  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_msg_data      := NULL;

  IF g_debug_stmt THEN
    PO_DEBUG.debug_begin(d_module);
    PO_DEBUG.debug_var(d_module, l_progress, 'p_entity_level', p_entity_level);
    PO_DEBUG.debug_var(d_module, l_progress, 'p_action_date', p_action_date);
    PO_DEBUG.debug_var(d_module, l_progress, 'p_entity_id', p_entity_id);
    PO_DEBUG.debug_var(d_module, l_progress, 'p_document_type', p_document_type);
    PO_DEBUG.debug_var(d_module, l_progress, 'p_doc_subtype', p_doc_subtype);
    PO_DEBUG.debug_var(d_module, l_progress, 'p_cancel_reason', p_cancel_reason);
    PO_DEBUG.debug_var(d_module, l_progress, 'p_recreate_demand', p_recreate_demand);
    PO_DEBUG.debug_var(d_module, l_progress, 'p_req_enc_flag', p_req_enc_flag);
    PO_DEBUG.debug_var(d_module, l_progress, 'p_user_id', p_user_id);
    PO_DEBUG.debug_var(d_module, l_progress, 'p_login_id', p_login_id);
    PO_DEBUG.debug_var(d_module, l_progress, 'p_note_to_vendor', p_note_to_vendor);
    PO_DEBUG.debug_var(d_module, l_progress, 'x_is_new_line', x_is_new_line);
  END IF;

  l_progress := '002' ;

  -- Update the cancel details on document before funds control call (unencumbering the document)
  update_document(
    p_api_version=> 1.0,
    p_init_msg_list=>FND_API.G_FALSE,
    p_entity_level =>p_entity_level,
                  p_action_date =>p_action_date,
                  p_entity_id =>p_entity_id,
                  p_document_type =>p_document_type,
                  p_doc_subtype =>p_doc_subtype,
                  p_cancel_reason =>p_cancel_reason,
                  p_recreate_demand=>p_recreate_demand,
                  p_fc_level =>l_fc_level,
    p_note_to_vendor =>p_note_to_vendor,
                  p_user_id =>p_user_id,
                  p_login_id => p_login_id,
                  x_return_status =>x_return_status,
                  x_msg_data =>x_msg_data);

  IF (x_return_status = FND_API.g_ret_sts_error) THEN
    RAISE FND_API.g_exc_error;
  ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
    RAISE FND_API.g_exc_unexpected_error;
  END IF;

  l_progress := '003' ;

  -- Update the backing requisitions accordingly before funds control call (unencumbering the document)
  update_requisitions(
    p_api_version=> 1.0,
    p_init_msg_list=>FND_API.G_FALSE,
    p_entity_level =>p_entity_level,
                      p_action_date =>p_action_date,
                      p_entity_id =>p_entity_id,
                      p_document_type =>p_document_type,
                      p_doc_subtype =>p_doc_subtype,
                      p_cancel_reason =>p_cancel_reason,
                      p_recreate_demand =>p_recreate_demand,
    p_req_enc_flag=>p_req_enc_flag,
                      p_fc_level =>l_fc_level,
                      p_user_id =>p_user_id,
                      p_login_id =>p_login_id,
    x_is_new_line=>x_is_new_line,
                      x_return_status =>x_return_status,
                      x_msg_data =>x_msg_data,
                      x_req_line_id_tbl =>l_req_line_id_tbl);

  IF (x_return_status = FND_API.g_ret_sts_error) THEN
    RAISE FND_API.g_exc_error;
  ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
    RAISE FND_API.g_exc_unexpected_error;
  END IF;

EXCEPTION
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
  x_msg_data := FND_MSG_PUB.GET(P_MSG_INDEX => FND_MSG_PUB.G_LAST,
                                P_ENCODED => 'F');
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  FND_MSG_PUB.add_exc_msg(g_module_prefix, d_api_name||':'||l_progress||':'||SQLCODE||':'||SQLERRM);

WHEN FND_API.G_EXC_ERROR THEN
  x_msg_data := FND_MSG_PUB.GET(P_MSG_INDEX => FND_MSG_PUB.G_LAST,
                                P_ENCODED => 'F');
  x_return_status := FND_API.G_RET_STS_ERROR;
  FND_MSG_PUB.add_exc_msg(g_module_prefix, d_api_name||':'||l_progress||':'||SQLCODE||':'||SQLERRM);

WHEN OTHERS THEN
  IF (G_DEBUG_UNEXP) THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED, d_module || '.OTHERS_EXCEPTION', 'EXCEPTION: LOCATION IS ' || l_progress || ' SQL CODE IS '||SQLCODE);
    END IF;
  END IF;

  x_msg_data := FND_MSG_PUB.GET(P_MSG_INDEX => FND_MSG_PUB.G_LAST,
                                P_ENCODED => 'F');
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  FND_MSG_PUB.add_exc_msg(g_module_prefix, d_api_name||':'||l_progress||':'||SQLCODE||':'||SQLERRM);


END update_req_po_before_fc;

--------------------------------------------------------------------------------
--Start of Comments
--Name: approve_entity
--Function:
--   Approves the entity ebing canceled
--   If the Document Header is Canceled, The entire docuemnt is approved,
--   so calling PO_DOCUMENT_ACTION_PVT.do_approve
--   If the Document Line is cancled, then just the line is approved i.e all its
--   shipments are updated to be Approved.
--   If the Document Shipment is cancled, then just the Shipment is approved


--Parameters:
--IN:
--  p_entity_level
--  p_entity_id
--  p_document_type
--  p_doc_subtype
--  p_reason
--
--
--IN OUT :
--OUT :
-- x_msg_data
-- x_return_status
--     FND_API.G_RET_STS_SUCCESS if cancel action succeeds
--     FND_API.G_RET_STS_ERROR if cancel action fails
--     FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
--
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE approve_entity(
            p_api_version     IN NUMBER,
            p_init_msg_list   IN VARCHAR2,
            p_entity_level  IN VARCHAR2,
            p_entity_id     IN NUMBER,
            p_document_type IN VARCHAR2,
            p_doc_subtype   IN VARCHAR2,
            p_reason        IN VARCHAR2,
            x_return_status OUT NOCOPY VARCHAR2,
            x_msg_data      OUT NOCOPY VARCHAR2)
  IS

    d_api_name CONSTANT VARCHAR2(30) := 'approve_entity';
    d_api_version CONSTANT NUMBER := 1.0;
    d_module   CONSTANT VARCHAR2(100) := g_module_prefix|| d_api_name;

    l_progress         VARCHAR2(8)            := '000' ;
    l_user_id po_lines.last_updated_by%TYPE    := -1;
    l_login_id po_lines.last_update_login%TYPE := -1;



  BEGIN
    -- Start standard API initialization
    IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    IF NOT FND_API.compatible_api_call(d_api_version, p_api_version,
                                        d_api_name, g_pkg_name) THEN
      RAISE FND_API.g_exc_unexpected_error;
    END IF;


    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_msg_data      := NULL;

    IF g_debug_stmt THEN
      PO_DEBUG.debug_begin(d_module);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_entity_level', p_entity_level);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_entity_id', p_entity_id);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_document_type', p_document_type);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_doc_subtype', p_doc_subtype);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_reason', p_reason);
    END IF;

    --Get User ID and Login ID
    l_user_id := FND_GLOBAL.USER_ID;
    IF (FND_GLOBAL.CONC_LOGIN_ID >= 0) THEN
      l_login_id := FND_GLOBAL.CONC_LOGIN_ID;
    ELSE
      l_login_id := FND_GLOBAL.LOGIN_ID;
    END IF;

    IF g_debug_stmt THEN
      PO_DEBUG.debug_var(d_module, l_progress, 'l_user_id', l_user_id);
      PO_DEBUG.debug_var(d_module, l_progress, 'l_login_id', l_login_id);
    END IF;



    -- If the docuemnt Header is Canceled then call do_approve
    IF p_entity_level = c_entity_level_HEADER THEN

      l_progress := '001' ;

      PO_DOCUMENT_ACTION_UTIL.update_doc_auth_status(
        p_document_id => p_entity_id,
        p_document_type => p_document_type,
        p_document_subtype => p_doc_subtype,
        p_new_status       => PO_DOCUMENT_ACTION_PVT.g_doc_status_APPROVED,
        p_user_id          => l_user_id,
        p_login_id         => l_login_id,
        x_return_status    => x_return_status
      );


      IF (x_return_status = FND_API.g_ret_sts_error) THEN
        RAISE FND_API.g_exc_error;
      ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
       RAISE FND_API.g_exc_unexpected_error;
      END IF;

    ELSE
    -- If the document Line/Shipment  is Canceled then approve the corresponding shipemnts
      l_progress := '002' ;

      UPDATE po_line_locations
      SET    approved_flag          = 'Y',
             approved_date          = SYSDATE
      WHERE ( (line_location_id    = p_entity_id
               AND p_entity_level = c_entity_level_SHIPMENT)
            OR(po_line_id       = p_entity_id
               AND p_entity_level = c_entity_level_LINE));

      IF g_debug_stmt THEN
        PO_DEBUG.debug_var(d_module, l_progress, 'Rows Updated the PO line locations table', SQL%ROWCOUNT);
      END IF;

    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_msg_data := FND_MSG_PUB.GET(
                      P_MSG_INDEX => FND_MSG_PUB.G_LAST,
                      P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.add_exc_msg(g_module_prefix, d_api_name||':'||l_progress||':'||SQLCODE||':'||SQLERRM);


    WHEN FND_API.G_EXC_ERROR THEN
      x_msg_data := FND_MSG_PUB.GET(
                      P_MSG_INDEX => FND_MSG_PUB.G_LAST,
                      P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.add_exc_msg(g_module_prefix, d_api_name||':'||l_progress||':'||SQLCODE||':'||SQLERRM);

    WHEN OTHERS THEN
      IF (g_debug_unexp) THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
	FND_LOG.STRING(
          FND_LOG.LEVEL_UNEXPECTED,
          d_module || '.OTHERS',
          'EXCEPTION: LOCATION IS '|| l_progress || ' SQL CODE IS '||SQLCODE);
	  END IF;
      END IF;
      FND_MSG_PUB.add_exc_msg(g_module_prefix, d_api_name||':'||l_progress||':'||SQLCODE||':'||SQLERRM);
      x_msg_data := FND_MSG_PUB.GET(
                      P_MSG_INDEX => FND_MSG_PUB.G_LAST,
                      P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;



END approve_entity;

-- Procedure reverted to its original state for bug 19077847
--------------------------------------------------------------------------------
--Start of Comments
--Name: update_po_rev_archive
--Function:
--   1. Set the entity being canceled to Approved Status.
--     i. If the entity being canceled is in "Approved" status then
--        The entity's authorization status will not be touched
--        In that case,If the Cancel action is at Line/Shipment Level,
--        the header level authorization status will be set to Requires-
--        Reapproval
--     ii. If the entity being canceled is in "Requires Reapproval"/"Rejected"
--         status then
--         * Set the entity to  approved status.
--         * For lower level entities, just approve that record alone
--   2. Archives the Document if the cancel is at Header Level
--   3. Checks and Updates the document revision if necessary

--Parameters:
--IN:
--  p_entity_level
--  p_entity_id
--  p_doc_id
--  p_document_type
--  p_doc_subtype
--  p_action_date
--  p_reason
--	p_user_id
--	p_login_id
--	p_caller
--
--IN OUT :
--OUT :
-- x_msg_data
-- x_return_status
--     FND_API.G_RET_STS_SUCCESS if cancel action succeeds
--     FND_API.G_RET_STS_ERROR if cancel action fails
--     FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
--
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE update_po_rev_archive(
            p_api_version     IN NUMBER,
            p_init_msg_list   IN VARCHAR2,
            p_entity_level  IN VARCHAR2,
            p_entity_id     IN NUMBER,
            p_doc_id        IN NUMBER,
            p_document_type IN VARCHAR2,
            p_doc_subtype   IN VARCHAR2,
            p_action_date   IN DATE,
            p_reason        IN VARCHAR2,
            p_user_id       IN po_lines.last_updated_by%TYPE,
            p_login_id      IN po_lines.last_update_login%TYPE,
            p_caller        IN VARCHAR2,
            x_return_status IN OUT NOCOPY VARCHAR2,
            x_msg_data      IN OUT NOCOPY VARCHAR2)

  IS

    d_api_name CONSTANT VARCHAR2(30) := 'update_po_rev_archive';
    d_api_version CONSTANT NUMBER := 1.0;
    d_module   CONSTANT VARCHAR2(100) := g_module_prefix|| d_api_name;

    l_progress          VARCHAR2(3)            := '000' ;
    l_orig_revision_num NUMBER :=-1;
    l_revision_num      NUMBER :=-1;
    l_msg_count         NUMBER := 0;
    l_count             NUMBER;
    l_employee_id       NUMBER;
    l_action_date       DATE;
    l_sequence_num      NUMBER := 0;
    l_auth_status       VARCHAR2(25);
    l_head_auth_status  VARCHAR2(25);


  BEGIN
    -- Start standard API initialization
    IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    IF NOT FND_API.compatible_api_call(d_api_version, p_api_version,
                                        d_api_name, g_pkg_name) THEN
      RAISE FND_API.g_exc_unexpected_error;
    END IF;


    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_msg_data      := NULL;

    IF g_debug_stmt THEN
      PO_DEBUG.debug_begin(d_module);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_entity_level', p_entity_level);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_entity_id', p_entity_id);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_doc_id', p_doc_id);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_document_type', p_document_type);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_doc_subtype', p_doc_subtype);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_action_date', p_action_date);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_reason', p_reason);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_user_id', p_user_id);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_login_id', p_login_id);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_caller', p_caller);
    END IF;



    l_progress := '001';

    -- Step 1: Identify the Authorization Status of teh entity being canceled
    -- Fetch the Docuemnt header Current Revision and Authorization status
    IF p_document_type = c_doc_type_RELEASE THEN
      SELECT revision_num,
             authorization_status
      INTO   l_orig_revision_num,
             l_head_auth_status
      FROM   po_releases
      WHERE PO_RELEASE_ID = p_doc_id;

    ELSE
      SELECT revision_num,
             authorization_status
      INTO   l_orig_revision_num,
             l_head_auth_status
      FROM   po_headers
      WHERE  PO_HEADER_ID = p_doc_id;

    END IF;

    l_progress := '002';

     -- If the entity bing canceled is Document Shipment/Line,
     -- Get its Authorization Status(Approved/Not Approved)
    IF p_entity_level <> c_entity_level_HEADER THEN

      SELECT COUNT(1)
      INTO   l_count
      FROM   po_line_locations
      WHERE  NVL(approved_flag, 'N')  = 'R'
             AND ( (line_location_id   = p_entity_id
                    AND p_entity_level   = c_entity_level_LINE
                    AND p_document_type <> c_doc_type_PA)
                  OR(line_location_id   = p_entity_id
                     AND p_entity_level   = c_entity_level_SHIPMENT)) ;

      IF l_count> 0 THEN
        l_auth_status := PO_DOCUMENT_ACTION_PVT.g_doc_status_REAPPROVAL;
      ELSE
        l_auth_status := PO_DOCUMENT_ACTION_PVT.g_doc_status_APPROVED;
      END IF;

    ELSE
      l_auth_status := l_head_auth_status;
    END IF;


    IF g_debug_stmt THEN
      PO_DEBUG.debug_var(d_module, l_progress, 'l_orig_revision_num', l_orig_revision_num);
      PO_DEBUG.debug_var(d_module, l_progress, 'l_head_auth_status', l_head_auth_status);
      PO_DEBUG.debug_var(d_module, l_progress, 'l_auth_status', l_auth_status);
    END IF;

    l_progress := '003';

    -- Step 1: Checks and Updates the document revision if necessary

    l_revision_num := l_orig_revision_num;

    -- Find the latest revision number of the entity

    PO_DOCUMENT_REVISION_GRP.Check_New_Revision (
      p_api_version => 1.0,
      p_doc_type => p_document_type,
      p_doc_subtype => p_doc_subtype,
      p_doc_id => p_doc_id,
      p_table_name => 'ALL',
      x_return_status => x_return_status,
      x_doc_revision_num => l_revision_num,
      x_message => x_msg_data);

    IF g_debug_stmt THEN
      PO_DEBUG.debug_var(d_module, l_progress, 'l_revision_num', l_revision_num);
      PO_DEBUG.debug_var(d_module, l_progress, 'l_orig_revision_num', l_orig_revision_num);
    END IF;


    l_progress := '004';


    -- Step 2: Set the entity being canceled to Approved Status
    --If the entity being canceled is in "Requires Reapproval"/"Rejected" status then
    -- Set the entity to  approved status.
    IF l_auth_status <> PO_DOCUMENT_ACTION_PVT.g_doc_status_APPROVED THEN
      approve_entity(
        p_api_version=> 1.0,
        p_init_msg_list=>FND_API.G_FALSE,
        p_entity_level => p_entity_level,
        p_entity_id => p_entity_id,
        p_document_type => p_document_type,
        p_doc_subtype => p_doc_subtype,
        p_reason => p_reason,
        x_return_status => x_return_status,
        x_msg_data => x_msg_data);

    END IF;

    IF (x_return_status = FND_API.g_ret_sts_error) THEN
      RAISE FND_API.g_exc_error;
    ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
      RAISE FND_API.g_exc_unexpected_error;
    END IF;



    l_progress := '005';

    IF p_entity_level = c_entity_level_HEADER THEN

    IF p_document_type = c_doc_type_RELEASE THEN

      UPDATE PO_RELEASES_ALL
      SET    REVISION_NUM = l_revision_num,
             REVISED_DATE = DECODE (
                              revision_num,
                              l_revision_num,
                              REVISED_DATE,
                              SYSDATE),
             LAST_UPDATE_DATE  = SYSDATE     ,
             LAST_UPDATED_BY   = p_user_id   ,
             LAST_UPDATE_LOGIN = p_login_id
      WHERE  PO_RELEASE_ID     = p_doc_id;

      IF g_debug_stmt THEN
        PO_DEBUG.debug_var(d_module, l_progress, 'Rows updated in PO Releases', SQL%ROWCOUNT);
      END IF;

    ELSE
      UPDATE po_headers
      SET    REVISION_NUM = l_revision_num,
             REVISED_DATE = DECODE(
                              revision_num,
                              l_revision_num,
                              REVISED_DATE,
                              SYSDATE),
             LAST_UPDATE_DATE  = SYSDATE     ,
             LAST_UPDATED_BY   = p_user_id   ,
             LAST_UPDATE_LOGIN = p_login_id
      WHERE  PO_HEADER_ID      = p_doc_id;


      IF g_debug_stmt THEN
        PO_DEBUG.debug_var(d_module, l_progress, 'Rows updated in PO Headers', SQL%ROWCOUNT);
      END IF;


    END IF; --if l_document_type = c_doc_type_RELEASE

        l_progress := '006';

        -- archive the PO revision and update the action history table
        -- if the Document Header is Canceled

        PO_DOCUMENT_ARCHIVE_GRP.Archive_PO(
          p_api_version => 1.0,
          p_document_id => p_doc_id,
          p_document_type => p_document_type,
          p_document_subtype => p_doc_subtype,
          p_process => 'APPROVE',
          x_return_status => x_return_status,
          x_msg_count => l_msg_count,
          x_msg_data => x_msg_data);

        IF (x_return_status = FND_API.g_ret_sts_error) THEN
          RAISE FND_API.g_exc_error;
        ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
          RAISE FND_API.g_exc_unexpected_error;
        END IF;

        l_progress := '007';


        SELECT MAX(sequence_num)
        INTO   l_sequence_num
        FROM   PO_ACTION_HISTORY
        WHERE  object_type_code= p_document_type --'PO'
              AND object_sub_type_code = p_doc_subtype   --'STANDARD'
              AND object_id = p_doc_id;

        IF g_debug_stmt THEN
          PO_DEBUG.debug_var(d_module, l_progress, 'l_sequence_num', l_sequence_num);
        END IF;

        BEGIN

          SELECT HR.employee_id
          INTO   l_employee_id
          FROM   FND_USER FND,
                 HR_EMPLOYEES_CURRENT_V HR
          WHERE  FND.user_id         = p_user_id
                 AND FND.employee_id = HR.employee_id ;

        EXCEPTION
          WHEN No_Data_Found THEN
            l_employee_id := NULL;
          WHEN OTHERS THEN
            RAISE;
        END;

        IF g_debug_stmt THEN
          PO_DEBUG.debug_var(d_module, l_progress, 'l_employee_id', l_employee_id);
        END IF;

        l_progress := '008';

        po_forward_sv1.insert_action_history(
          x_object_id=> p_doc_id,
          x_object_type_code =>p_document_type,
          x_object_sub_type_code =>p_doc_subtype,
          x_sequence_num =>l_sequence_num+1,
          x_action_code =>'CANCEL',
          x_action_date =>sysdate, -- <bug 16988589  Action_Date should have timestamp,just use sysdate>
          x_employee_id =>l_employee_id,
          x_approval_path_id =>NULL,
          x_note =>p_reason,
          x_object_revision_num =>l_revision_num,
          x_offline_code =>NULL,
          x_request_id =>NULL,
          x_program_application_id =>NULL,
          x_program_id =>NULL,
          x_program_date =>SYSDATE,
          x_user_id =>p_user_id,
          x_login_id =>p_login_id) ;



    ELSE
      -- if the Document Line/Shipment is Canceled then
      -- Update the Header revision number to the new revision  and  status to
      -- be REQUIRES REAPPROVAL

      l_progress := '009';
      IF p_document_type = c_doc_type_RELEASE THEN

        UPDATE PO_RELEASES
        SET    REVISION_NUM = l_revision_num,
               REVISED_DATE = DECODE (
                                revision_num,
                                l_revision_num,
                                REVISED_DATE,
                                SYSDATE)             ,
               LAST_UPDATE_DATE     = SYSDATE              ,
               LAST_UPDATED_BY      = p_user_id            ,
               LAST_UPDATE_LOGIN    = p_login_id           ,
               AUTHORIZATION_STATUS = PO_DOCUMENT_ACTION_PVT.g_doc_status_REAPPROVAL,
               APPROVED_FLAG        = 'R'
        WHERE PO_RELEASE_ID        = p_doc_id;

        IF g_debug_stmt THEN
          PO_DEBUG.debug_var(d_module, l_progress, 'Rows updated in PO Releases', SQL%ROWCOUNT);
    END IF;

      ELSE
        UPDATE PO_HEADERS
        SET    REVISION_NUM = l_revision_num,
               REVISED_DATE = DECODE (revision_num,
                              l_revision_num, REVISED_DATE,
                               SYSDATE)             ,
               LAST_UPDATE_DATE     = SYSDATE              ,
               LAST_UPDATED_BY      = p_user_id            ,
               LAST_UPDATE_LOGIN    = p_login_id           ,
               AUTHORIZATION_STATUS = PO_DOCUMENT_ACTION_PVT.g_doc_status_REAPPROVAL,
               APPROVED_FLAG        = 'R'
        WHERE PO_HEADER_ID         = p_doc_id;

        IF g_debug_stmt THEN
          PO_DEBUG.debug_var(d_module, l_progress, 'Rows updated in PO Headers', SQL%ROWCOUNT);
        END IF;

      END IF; --if l_document_type = c_doc_type_RELEASE

    END IF; --  if p_entity_level = c_entity_level_HEADER


  EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_msg_data := FND_MSG_PUB.GET(
                      P_MSG_INDEX => FND_MSG_PUB.G_LAST,
                      P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.add_exc_msg(g_module_prefix, d_api_name||':'||l_progress||':'||SQLCODE||':'||SQLERRM);

    WHEN FND_API.G_EXC_ERROR THEN
      x_msg_data := FND_MSG_PUB.GET(
                      P_MSG_INDEX => FND_MSG_PUB.G_LAST,
                      P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MSG_PUB.add_exc_msg(g_module_prefix, d_api_name||':'||l_progress||':'||SQLCODE||':'||SQLERRM);
    WHEN OTHERS THEN
      IF (g_debug_unexp) THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
	FND_LOG.STRING(
          FND_LOG.LEVEL_UNEXPECTED,
          d_module || '.OTHERS',
          'EXCEPTION: LOCATION IS '|| l_progress || ' SQL CODE IS '||SQLCODE);
	  END IF;
      END IF;
      x_msg_data := FND_MSG_PUB.GET(
                      P_MSG_INDEX => FND_MSG_PUB.G_LAST,
                      P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.add_exc_msg(g_module_prefix, d_api_name||':'||l_progress||':'||SQLCODE||':'||SQLERRM);

END update_po_rev_archive;

--------------------------------------------------------------------------------
--Start of Comments
--Name: update_closed_code
--Function:
--  Update the Status of Shipments, based on the Receiving and Invoicing
--  Closure Point Quantities, and Rollup if necessary
--  For example, if  all of a shipment has been received, then the shipment
--  is closed for  receiving
--  Closure Points and Tolerance Levels are set in po_line_locations (for
--  tolerances) and in po_system_parameters (for closed codes) respectively.
--  This method wraps PO_DOCUMENT_ACTION_PVT.auto_close_update_state.      .
--
--
--Parameters:
--IN:
--  p_entity_level
--  p_entity_id
--  p_doc_id
--  p_document_type
--  p_doc_subtype
--  p_user_id
--  p_login_id
--
--IN OUT :
--OUT :
-- x_msg_data
-- x_return_status
--     FND_API.G_RET_STS_SUCCESS if cancel action succeeds
--     FND_API.G_RET_STS_ERROR if cancel action fails
--     FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
--
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE update_closed_code(
            p_api_version   IN NUMBER,
            p_init_msg_list IN VARCHAR2,
            p_entity_level  IN VARCHAR2,
            p_entity_id     IN NUMBER,
            p_doc_id        IN NUMBER,
            p_document_type IN VARCHAR2,
            p_doc_subtype   IN VARCHAR2,
            p_user_id       IN po_lines.last_updated_by%TYPE,
            p_login_id      IN po_lines.last_update_login%TYPE,
            x_return_status OUT NOCOPY VARCHAR2,
            x_msg_data      OUT NOCOPY VARCHAR2)

  IS

    d_api_name CONSTANT VARCHAR2(30) := 'update_closed_code';
    d_api_version CONSTANT NUMBER := 1.0;
    d_module   CONSTANT VARCHAR2(100) := g_module_prefix|| d_api_name;
    l_progress    VARCHAR2(8)            := '000' ;
    l_line_id     NUMBER;
    l_ship_id     NUMBER;
    l_return_code VARCHAR2(30);


  BEGIN
    -- Start standard API initialization
    IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    IF NOT FND_API.compatible_api_call(d_api_version, p_api_version,
                                        d_api_name, g_pkg_name) THEN
      RAISE FND_API.g_exc_unexpected_error;
    END IF;


    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_msg_data      := NULL;

    IF g_debug_stmt THEN
      PO_DEBUG.debug_begin(d_module);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_entity_level', p_entity_level);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_entity_id', p_entity_id);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_doc_id', p_doc_id);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_document_type', p_document_type);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_doc_subtype', p_doc_subtype);
    END IF;

    l_progress       := '001' ;

    IF p_entity_level = c_entity_level_SHIPMENT THEN
      l_ship_id      := p_entity_id;
    ELSIF p_entity_level = c_entity_level_LINE THEN
      l_line_id         := p_entity_id;
    END IF;


    IF g_debug_stmt THEN
      PO_DEBUG.debug_var(d_module, l_progress, 'l_line_id', l_line_id);
      PO_DEBUG.debug_var(d_module, l_progress, 'l_ship_id', l_ship_id);
    END IF;

    l_progress := '002' ;

    PO_DOCUMENT_ACTION_PVT.auto_update_close_state(
      p_document_id => p_doc_id,
      p_document_type => p_document_type,
      p_document_subtype => p_doc_subtype,
      p_line_id => l_line_id,
      p_shipment_id => l_ship_id,
      p_calling_mode => 'PO',
      p_called_from_conc => FALSE,
      x_return_status => x_return_status,
      x_return_code => l_return_code,
      x_exception_msg => x_msg_data );

    IF (x_return_status = FND_API.g_ret_sts_error) THEN
      RAISE FND_API.g_exc_error;
    ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
      RAISE FND_API.g_exc_unexpected_error;
    END IF;



  EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_msg_data := FND_MSG_PUB.GET(
                      P_MSG_INDEX => FND_MSG_PUB.G_LAST,
                      P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MSG_PUB.add_exc_msg(g_module_prefix, d_api_name||':'||l_progress||':'||SQLCODE||':'||SQLERRM);

    WHEN FND_API.G_EXC_ERROR THEN
      x_msg_data := FND_MSG_PUB.GET(
                      P_MSG_INDEX => FND_MSG_PUB.G_LAST,
                      P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.add_exc_msg(g_module_prefix, d_api_name||':'||l_progress||':'||SQLCODE||':'||SQLERRM);


    WHEN OTHERS THEN
      IF (g_debug_unexp) THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
	FND_LOG.STRING(
          FND_LOG.LEVEL_UNEXPECTED,
          d_module || '.OTHERS',
          'EXCEPTION: LOCATION IS '|| l_progress || ' SQL CODE IS '||SQLCODE);
	  END IF;
      END IF;
      x_msg_data := FND_MSG_PUB.GET(
                      P_MSG_INDEX => FND_MSG_PUB.G_LAST,
                      P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.add_exc_msg(g_module_prefix, d_api_name||':'||l_progress||':'||SQLCODE||':'||SQLERRM);
END update_closed_code;

--------------------------------------------------------------------------------
--Start of Comments
--Name: process_cancel_action

--Function:
--  Performs the cancellation of document
--  Update the cancel flag and other relevant coulmns on the document
--  and the backing requisition

--Parameters:
--IN:
--  p_da_call_rec
--  p_key
--  p_user_id
--  p_login_id

--IN OUT :
--OUT :
-- x_msg_data
-- x_return_status -
--    FND_API.G_RET_STS_SUCCESS if cancel action succeeds
--    FND_API.G_RET_STS_ERROR if cancel action fails
--    FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
--
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE process_cancel_action(
            p_api_version   IN NUMBER,
            p_init_msg_list IN VARCHAR2,
            p_da_call_rec   IN OUT NOCOPY po_document_action_pvt.DOC_ACTION_CALL_TBL_REC_TYPE,
            p_key           IN po_session_gt.key%TYPE,
            p_user_id       IN po_lines.last_updated_by%TYPE,
            p_login_id      IN po_lines.last_update_login%TYPE,
            p_po_enc_flag   IN FINANCIALS_SYSTEM_PARAMETERS.purch_encumbrance_flag%TYPE,
            p_req_enc_flag  IN FINANCIALS_SYSTEM_PARAMETERS.req_encumbrance_flag%TYPE,
            x_return_status OUT NOCOPY  VARCHAR2,
            x_msg_data      OUT NOCOPY VARCHAR2)

  IS

    d_api_name CONSTANT VARCHAR2(30) := 'process_cancel_action';
    d_api_version CONSTANT NUMBER := 1.0;
    d_module   CONSTANT VARCHAR2(100) := g_module_prefix|| d_api_name;
    l_progress      VARCHAR2(8)            := '000' ;
    l_cancel_reason VARCHAR2(240); --Bug 15836292
    l_entity_rec_tbl po_document_action_pvt.entity_dtl_rec_type_tbl;
    l_doc_id   NUMBER;
    l_enc_req_flag VARCHAR2(1);
    l_is_new_req_line  VARCHAR2(1);
    l_po_return_code VARCHAR2(25);
    l_online_report_id NUMBER;

  BEGIN
    -- Start standard API initialization
    IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    IF NOT FND_API.compatible_api_call(d_api_version, p_api_version,
                                        d_api_name, g_pkg_name) THEN
      RAISE FND_API.g_exc_unexpected_error;
    END IF;


    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_msg_data      := NULL;

    IF g_debug_stmt THEN
      PO_DEBUG.debug_begin(d_module);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_key', p_key);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_user_id', p_user_id);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_login_id', p_login_id);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_po_enc_flag', p_po_enc_flag);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_req_enc_flag', p_req_enc_flag);
    END IF;

    l_progress := '002' ;

    l_entity_rec_tbl := p_da_call_rec.entity_dtl_record_tbl;
    l_cancel_reason  := p_da_call_rec.reason;
    l_enc_req_flag :='N';

    l_doc_id   := -1;


    IF g_debug_stmt THEN
      PO_DEBUG.debug_var(d_module, l_progress, 'l_cancel_reason', l_cancel_reason);
     END IF;

    -- for each entity id in the entity record table
    FOR i IN 1..l_entity_rec_tbl.Count
    LOOP
      SAVEPOINT process_cancel_action_SP;

      BEGIN

        IF l_entity_rec_tbl(i).process_entity_flag = 'Y' THEN

          IF g_debug_stmt THEN
            PO_DEBUG.debug_var(d_module, l_progress, 'i', i);
            PO_DEBUG.debug_var(d_module, l_progress, 'entity_level', l_entity_rec_tbl(i).entity_level);
            PO_DEBUG.debug_var(d_module, l_progress, 'entity_id', l_entity_rec_tbl(i).entity_id);
            PO_DEBUG.debug_var(d_module, l_progress, 'entity_action_date', l_entity_rec_tbl(i).entity_action_date);
            PO_DEBUG.debug_var(d_module, l_progress, 'document_type', l_entity_rec_tbl(i).document_type);
            PO_DEBUG.debug_var(d_module, l_progress, 'document_subtype', l_entity_rec_tbl(i).document_subtype);
            PO_DEBUG.debug_var(d_module, l_progress, 'recreate_demand_flag', l_entity_rec_tbl(i).recreate_demand_flag);
          END IF;

          l_progress := '003' ;

          l_doc_id := l_entity_rec_tbl(i).doc_id;

          --Update the Cancel Flag('I') and other relevant columns of the
          -- document and backing req
          --If recreate_demand is ON, create the new distributions and lines
          update_req_po_before_fc(
            p_api_version=> 1.0,
            p_init_msg_list=>FND_API.G_FALSE,
            p_entity_level =>l_entity_rec_tbl(i).entity_level,
            p_action_date =>l_entity_rec_tbl(i).entity_action_date,
            p_entity_id =>l_entity_rec_tbl(i).entity_id,
            p_document_type =>l_entity_rec_tbl(i).document_type,
            p_doc_subtype =>l_entity_rec_tbl(i).document_subtype,
            p_cancel_reason =>l_cancel_reason,
            p_recreate_demand => l_entity_rec_tbl(i).recreate_demand_flag,
            p_note_to_vendor =>p_da_call_rec.note_to_vendor,
            p_req_enc_flag  =>p_req_enc_flag,
            x_is_new_line=>l_is_new_req_line,
            p_user_id =>p_user_id,
            p_login_id => p_login_id,
            x_return_status =>x_return_status,
            x_msg_data =>x_msg_data);

          IF (x_return_status = FND_API.g_ret_sts_error) THEN
            RAISE FND_API.g_exc_error;
          ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
            RAISE FND_API.g_exc_unexpected_error;
          END IF;

          IF g_debug_stmt THEN
            PO_DEBUG.debug_var(d_module, l_progress, 'l_is_new_req_line', l_is_new_req_line);
          END IF;


          l_progress := '004' ;

          --Call to encumbrance code is controlled by the "l_enc_req_flag" value
          -- If the Value is 'Y' then call  PO_DOCUMENT_FUNDS_PVT.do_cancel,
          -- otherwise do not call

          --The value of "l_enc_req_flag" is set to 'Y' only when
          -- 1) Document is a blanket purchase agreement,
          --   and both PO and REQ enc are turned on,
          --   and encumbrance_required_flag is 'Y', OR
          -- 2) Document is not a Purchase Agreement, and PO enc is turned on
          IF (l_entity_rec_tbl(i).document_type = c_doc_type_PA
              AND l_entity_rec_tbl(i).document_subtype=c_doc_subtype_BLANKET
              AND p_po_enc_flag='Y'
              AND p_req_enc_flag='Y'
              AND l_entity_rec_tbl(i).entity_level=c_entity_level_HEADER)
          THEN
            BEGIN

              SELECT Nvl(encumbrance_required_flag,'N')
              INTO   l_enc_req_flag
              FROM   po_headers
              WHERE  po_header_id=l_entity_rec_tbl(i).entity_id;

            EXCEPTION
              WHEN No_Data_Found THEN
                l_enc_req_flag:='N';

              WHEN OTHERS THEN
                RAISE FND_API.g_exc_unexpected_error;
            END;
          --Document is not a Purchase Agreement, and PO enc is turned on
         -- Bug 15983778: Instead of po encumbrance flag req enc flag was checked.
          ELSIF(l_entity_rec_tbl(i).document_type <> c_doc_type_PA
                AND p_po_enc_flag='Y')  THEN
            l_enc_req_flag :='Y' ;
          END IF;

          IF g_debug_stmt THEN
            PO_DEBUG.debug_var(d_module, l_progress, 'l_enc_req_flag', l_enc_req_flag);
          END IF;


          l_progress := '005' ;

          IF l_enc_req_flag ='Y' THEN

           -- bug 14766811
           -- Not able to cancel an encumbered PO at shipment level as entity level passed to
           -- encumbrance API is LINE_LOCATION for shipment whereas PO_CORE_S.GET_DOCUMENT_IDS
           -- expect the value to be SHIPMENT. Thus changing the value before calling encumbrance API.
          IF(l_entity_rec_tbl(i).entity_level = PO_Document_Cancel_PVT.c_entity_level_SHIPMENT) THEN
           l_entity_rec_tbl(i).entity_level := PO_CORE_S.g_doc_level_SHIPMENT;
           END IF;

            -- Unencumber the entity
            PO_DOCUMENT_FUNDS_PVT.do_cancel(
              x_return_status => x_return_status,
              p_doc_type => l_entity_rec_tbl(i).document_type,
              p_doc_subtype => l_entity_rec_tbl(i).document_subtype,
              p_doc_level => l_entity_rec_tbl(i).entity_level,
              p_doc_level_id => l_entity_rec_tbl(i).entity_id,
              p_use_enc_gt_flag => PO_DOCUMENT_FUNDS_PVT.g_parameter_NO,
              p_override_funds => PO_DOCUMENT_FUNDS_PVT.g_parameter_USE_PROFILE,
              p_use_gl_date => p_da_call_rec.use_gl_date,
              p_override_date => l_entity_rec_tbl(i).entity_action_date,
              x_po_return_code => l_po_return_code,
              x_online_report_id => l_online_report_id);


            IF (x_return_status = FND_API.g_ret_sts_error) THEN
              RAISE FND_API.g_exc_error;
            ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
              RAISE FND_API.g_exc_unexpected_error;
            END IF;

          -- bug 14766811
          -- Resetting the value of entity level back to original as this is used by other flows.
          IF(l_entity_rec_tbl(i).entity_level = PO_CORE_S.g_doc_level_SHIPMENT) THEN
           l_entity_rec_tbl(i).entity_level := PO_Document_Cancel_PVT.c_entity_level_SHIPMENT;
           END IF;

          END IF;
          l_progress := '006' ;

          -- After Funds Control routine was successful in unencumbering the PO,
          -- update po entity cancel_flags at all levels to 'Y',
          -- and if new req lines were created, to free them up by setting their
          -- line_location_id column to Null.

          update_req_po_after_fc(
            p_api_version=> 1.0,
            p_init_msg_list=>FND_API.G_FALSE,
            p_entity_level =>l_entity_rec_tbl(i).entity_level,
            p_action_date =>l_entity_rec_tbl(i).entity_action_date,
            p_entity_id =>l_entity_rec_tbl(i).entity_id,
            p_doc_id =>l_entity_rec_tbl(i).doc_id,
            p_document_type =>l_entity_rec_tbl(i).document_type,
            p_doc_subtype =>l_entity_rec_tbl(i).document_subtype,
            p_cancel_reason =>l_cancel_reason,
            p_recreate_flag =>l_entity_rec_tbl(i).recreate_demand_flag,
            p_req_enc_flag =>p_req_enc_flag,
            p_note_to_vendor =>p_da_call_rec.note_to_vendor,
            p_source =>p_da_call_rec.caller,
            x_is_new_line=>l_is_new_req_line,
            p_user_id =>p_user_id,
            p_login_id => p_login_id,
            x_return_status =>x_return_status,
            x_msg_data =>x_msg_data);


          IF (x_return_status = FND_API.g_ret_sts_error) THEN
            RAISE FND_API.g_exc_error;
          ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
            RAISE FND_API.g_exc_unexpected_error;
          END IF;

          l_progress := '007' ;

          -- Calling  update closed code only once for a document header id
          -- and not individual entity id
          -- So Checking if this is the last entity or the next entity belongs
          -- to a different doc_id.If So,then making a call to update closed code.
          -- This is based on the assumption/fact that the records in
          -- l_entity_rec_tbl are sorted based on doc_id.This soring is done
          -- while inserting the records back into entity record table from
          -- po_Seesion_gt in the procedure
          -- po_control_action_validations.mark_errored_record(..)
          IF i=l_entity_rec_tbl.Count OR l_doc_id <> l_entity_rec_tbl(i+1).doc_id THEN

            -- After successful update of the relavant columns of the document,
            -- update the closed code on the document
            update_closed_code(
              p_api_version=> 1.0,
              p_init_msg_list=>FND_API.G_FALSE,
              p_entity_level =>c_entity_level_HEADER,
              p_entity_id =>l_entity_rec_tbl(i).doc_id,
              p_doc_id => l_entity_rec_tbl(i).doc_id,
              p_document_type =>l_entity_rec_tbl(i).document_type,
              p_doc_subtype =>l_entity_rec_tbl(i).document_subtype,
              p_user_id =>p_user_id,
              p_login_id => p_login_id,
              x_return_status =>x_return_status,
              x_msg_data =>x_msg_data);

            IF (x_return_status = FND_API.g_ret_sts_error) THEN
              RAISE FND_API.g_exc_error;
            ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
              RAISE FND_API.g_exc_unexpected_error;
            END IF;

          END IF;

          l_progress := '008';


          -- Routine to update the PO revision, and archive the PO
          -- Update the po action history table
          update_po_rev_archive(
            p_api_version=> 1.0,
            p_init_msg_list=>FND_API.G_FALSE,
            p_entity_level =>l_entity_rec_tbl(i).entity_level,
            p_entity_id =>l_entity_rec_tbl(i).entity_id,
            p_doc_id => l_entity_rec_tbl(i).doc_id,
            p_document_type =>l_entity_rec_tbl(i).document_type,
            p_doc_subtype =>l_entity_rec_tbl(i).document_subtype,
            p_reason =>l_cancel_reason,
            p_action_date =>l_entity_rec_tbl(i).entity_action_date,
            p_user_id =>p_user_id,
            p_login_id =>p_login_id,
            p_caller =>p_da_call_rec.caller,
            x_return_status => x_return_status,
            x_msg_data =>x_msg_data);



          IF (x_return_status = FND_API.g_ret_sts_error) THEN
            RAISE FND_API.g_exc_error;
          ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
            RAISE FND_API.g_exc_unexpected_error;
          END IF;


        END IF; --if process_entity_flag='Y'  \

      EXCEPTION
        WHEN FND_API.g_exc_error THEN
          ROLLBACK TO process_cancel_action_SP;
          x_return_status := FND_API.g_ret_sts_error;
          IF (g_debug_unexp) THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
	    FND_LOG.STRING(
              FND_LOG.LEVEL_UNEXPECTED,
              d_module || '.Error',
              'Error: LOCATION IS '|| l_progress || ' SQL CODE IS '||SQLCODE);
	      END IF;
          END IF;
        WHEN FND_API.g_exc_unexpected_error THEN
          ROLLBACK TO process_cancel_action_SP;
          x_return_status := FND_API.g_ret_sts_unexp_error;
          IF (g_debug_unexp) THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
	    FND_LOG.STRING(
              FND_LOG.LEVEL_UNEXPECTED,
              d_module || '.UnExpected',
              'EXCEPTION: LOCATION IS '|| l_progress || ' SQL CODE IS '||SQLCODE);
	      END IF;
          END IF;

        WHEN OTHERS THEN
          ROLLBACK TO process_cancel_action_SP;
          x_return_status := FND_API.g_ret_sts_unexp_error;
          IF (g_debug_unexp) THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
	    FND_LOG.STRING(
              FND_LOG.LEVEL_UNEXPECTED,
              d_module || '.OTHERS',
              'EXCEPTION: LOCATION IS '|| l_progress || ' SQL CODE IS '||SQLCODE);
	      END IF;
          END IF;
      END;

      l_progress := '002' ;
    END LOOP;


  EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_msg_data := FND_MSG_PUB.GET(
                      P_MSG_INDEX => FND_MSG_PUB.G_LAST,
                      P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.add_exc_msg(g_module_prefix, d_api_name||':'||l_progress||':'||SQLCODE||':'||SQLERRM);
    WHEN FND_API.G_EXC_ERROR THEN
      x_msg_data := FND_MSG_PUB.GET(
                      P_MSG_INDEX => FND_MSG_PUB.G_LAST,
                      P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.add_exc_msg(g_module_prefix, d_api_name||':'||l_progress||':'||SQLCODE||':'||SQLERRM);
    WHEN OTHERS THEN
      IF (g_debug_unexp) THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
	FND_LOG.STRING(
          FND_LOG.LEVEL_UNEXPECTED,
          d_module || '.OTHERS',
          'EXCEPTION: LOCATION IS '|| l_progress || ' SQL CODE IS '||SQLCODE);
	  END IF;
      END IF;
      x_msg_data := FND_MSG_PUB.GET(
                      P_MSG_INDEX => FND_MSG_PUB.G_LAST,
                      P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.add_exc_msg(g_module_prefix, d_api_name||':'||l_progress||':'||SQLCODE||':'||SQLERRM);

END process_cancel_action;

--------------------------------------------------------------------------------
--Start of Comments
--Name: insrtEntityRecInSessiongt

--Function:
--  Inserts the entity record in po session gt
--
--   Column Mapping is as :
--    num1  => entity_id
--    char1 => document_type
--    char2 => document_subtype
--    char3 => entity_level
--    char4 => doc_id
--    char5 => process_entity_flag

--Parameters:
--IN:
--  p_entity_rec_tbl

--IN OUT :
--OUT :
-- x_key
-- x_msg_data
-- x_return_status
--     FND_API.G_RET_STS_SUCCESS if cancel action succeeds
--     FND_API.G_RET_STS_ERROR if cancel action fails
--     FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
--
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE insrtEntityRecInSessiongt(
            p_entity_rec_tbl IN po_document_action_pvt.entity_dtl_rec_type_tbl,
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2,
            x_key            OUT NOCOPY po_session_gt.key%TYPE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_data       OUT NOCOPY VARCHAR2)

  IS

    d_api_name CONSTANT VARCHAR2(30) := 'insrtEntityRecInSessiongt';
    d_api_version CONSTANT NUMBER := 1.0;
    d_module   CONSTANT VARCHAR2(100) := g_module_prefix|| d_api_name;
    l_progress VARCHAR2(3)            := '000' ;

  BEGIN
     -- Start standard API initialization
    IF FND_API.to_boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    IF NOT FND_API.compatible_api_call(d_api_version, p_api_version,
                                       d_api_name, g_pkg_name) THEN
      RAISE FND_API.g_exc_unexpected_error;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_msg_data      := NULL;

    IF g_debug_stmt THEN
      PO_DEBUG.debug_begin(d_module);
    END IF;

    l_progress := '001';

    x_key := po_core_s.get_session_gt_nextval;

    IF g_debug_stmt THEN
      PO_DEBUG.debug_var(d_module, l_progress, 'x_key', x_key);
    END IF;

    -- for each entity
    FOR i IN 1.. p_entity_rec_tbl.Count
    LOOP


      INSERT INTO po_session_gt(
        KEY  ,
        num1 ,
        char1,
        char2,
        char3,
        char4,
        char5)
      VALUES(
        x_key                               ,
        P_entity_rec_tbl(i).entity_id       ,
        P_entity_rec_tbl(i).document_type   ,
        P_entity_rec_tbl(i).document_subtype,
        P_entity_rec_tbl(i).entity_level    ,
        P_entity_rec_tbl(i).doc_id          ,
        'Y');


    END LOOP;
  EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_msg_data := FND_MSG_PUB.GET(
                      P_MSG_INDEX => FND_MSG_PUB.G_LAST,
                      P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.add_exc_msg(g_module_prefix, d_api_name||':'||l_progress||':'||SQLCODE||':'||SQLERRM);

    WHEN FND_API.G_EXC_ERROR THEN
      x_msg_data := FND_MSG_PUB.GET(
                      P_MSG_INDEX => FND_MSG_PUB.G_LAST,
                      P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.add_exc_msg(g_module_prefix, d_api_name||':'||l_progress||':'||SQLCODE||':'||SQLERRM);

    WHEN OTHERS THEN
      IF (G_DEBUG_UNEXP) THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
	FND_LOG.STRING(
          FND_LOG.LEVEL_UNEXPECTED,
          d_module || '.OTHERS_EXCEPTION',
          'EXCEPTION: LOCATION IS ' || l_progress || ' SQL CODE IS '||SQLCODE);
	  END IF;
      END IF;
      FND_MSG_PUB.add_exc_msg(g_module_prefix, d_api_name||':'||l_progress||':'||SQLCODE||':'||SQLERRM);
      x_msg_data := FND_MSG_PUB.GET(
                      P_MSG_INDEX => FND_MSG_PUB.G_LAST,
                      P_ENCODED => 'F');
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END insrtEntityRecInSessiongt;


--------------------------------------------------------------------------------
--Start of Comments
--Name: cancel_document

--Function:

--  Modifies: All cancel columns and who columns for this document at the entity
--  level of cancellation.
--  Effects: Cancels the document at the header, line, or shipment level
--    depending upon the document ID parameters after performing validations.
--    Validations include state checks and cancel submission checks. If
--    p_cbc_enabled is 'Y', then the CBC accounting date is updated to be
--    p_action_date. If p_cancel_reqs_flag is 'Y', then backing requisitions
--    will also be cancelled if allowable. Otherwise, they will be recreated.
--    Encumbrance is recalculated for cancelled entities if enabled. If the
--    cancel action is successful, the document's cancel and who columns will be
--    updated at the specified entity level. Otherwise, the document will remain
--    unchanged. All changes will be committed upon success if p_commit is
--    FND_API.G_TRUE.


--Parameters:
--IN:
--  p_da_call_rec
--  p_api_version
--  p_init_msg_list

--IN OUT :
--OUT :
-- x_msg_data
-- x_return_status
--     FND_API.G_RET_STS_SUCCESS if cancel action succeeds
--     FND_API.G_RET_STS_ERROR if cancel action fails
--     FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
--
--End of Comments
--------------------------------------------------------------------------------
 PROCEDURE cancel_document(
            p_da_call_rec   IN OUT NOCOPY po_document_action_pvt.DOC_ACTION_CALL_TBL_REC_TYPE,
            p_api_version   IN  NUMBER,
            p_init_msg_list IN  VARCHAR2,
            x_return_status OUT NOCOPY VARCHAR2,
            x_msg_data      OUT NOCOPY VARCHAR2,
            x_return_code   OUT NOCOPY VARCHAR2
            )
  IS

    d_api_name CONSTANT VARCHAR2(30) := 'cancel_document';
    d_api_version CONSTANT NUMBER := 1.0;
    d_module   CONSTANT VARCHAR2(100) := g_module_prefix|| d_api_name;

    l_progress VARCHAR2(3)            := '000' ;
    l_key po_session_gt.key%TYPE;
    l_user_id po_lines.last_updated_by%TYPE    := -1;
    l_login_id po_lines.last_update_login%TYPE := -1;
    l_po_encumbrance_flag FINANCIALS_SYSTEM_PARAMETERS.purch_encumbrance_flag%TYPE;
    l_req_encumbrance_flag FINANCIALS_SYSTEM_PARAMETERS.req_encumbrance_flag%TYPE;

  BEGIN

     -- Start standard API initialization
    IF FND_API.to_boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    IF NOT FND_API.compatible_api_call(d_api_version, p_api_version,
                                       d_api_name, g_pkg_name) THEN
      RAISE FND_API.g_exc_unexpected_error;
    END IF;

    SAVEPOINT cancel_document_PVT;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_msg_data      := NULL ;

    IF g_debug_stmt THEN
      PO_DEBUG.debug_begin(d_module);
      PO_DEBUG.debug_var(d_module,
        l_progress,
        'online_report_id',
        p_da_call_rec.online_report_id);
    END IF;

    l_progress := '001';

    -- Insert the entity record into po_session_gt
    insrtEntityRecInSessiongt(
      p_api_version=> 1.0,
      p_init_msg_list=>FND_API.G_FALSE,
      p_entity_rec_tbl=>p_da_call_rec.entity_dtl_record_tbl,
      x_key =>l_key,
      x_return_status =>x_return_status,
      x_msg_data =>x_msg_data);

    IF g_debug_stmt THEN
      PO_DEBUG.debug_var(d_module, l_progress, 'l_key', l_key);
    END IF;

    --Get User ID and Login ID
    l_user_id := FND_GLOBAL.USER_ID;
    IF (FND_GLOBAL.CONC_LOGIN_ID >= 0) THEN
      l_login_id := FND_GLOBAL.CONC_LOGIN_ID;
    ELSE
      l_login_id := FND_GLOBAL.LOGIN_ID;
    END IF;

    --Query encumbrance flags from FINANCIALS_SYSTEM_PARAMETERS
    --to validate action_date with encumbrance if necessary
    SELECT NVL(fsp.purch_encumbrance_flag, 'N'),
           NVL(fsp.req_encumbrance_flag, 'N')
     INTO l_po_encumbrance_flag,
          l_req_encumbrance_flag
     FROM financials_system_parameters fsp;


    IF g_debug_stmt THEN
      PO_DEBUG.debug_var(d_module, l_progress, 'l_po_encumbrance_flag',l_po_encumbrance_flag);
      PO_DEBUG.debug_var(d_module, l_progress, 'l_req_encumbrance_flag',l_req_encumbrance_flag);
      PO_DEBUG.debug_var(d_module, l_progress, 'l_login_id', l_login_id);
      PO_DEBUG.debug_var(d_module, l_progress, 'l_user_id', l_user_id);
      PO_DEBUG.debug_var(d_module, l_progress, 'x_return_status', x_return_status);
      PO_DEBUG.debug_var(d_module, l_progress, 'x_msg_data', x_msg_data);
    END IF;

    --Do all the validations related to Cancel Action
    po_control_action_validations.validate_cancel_action(
      p_da_call_rec =>p_da_call_rec,
      p_key =>l_key,
      p_user_id => l_user_id,
      p_login_id =>l_login_id,
      p_po_enc_flag=>l_po_encumbrance_flag,
      p_req_enc_flag=>l_req_encumbrance_flag,
      x_return_status =>x_return_status,
      x_msg_data =>x_msg_data,
      x_return_code=>x_return_code);

    IF (x_return_status = FND_API.g_ret_sts_error) THEN
      RAISE FND_API.g_exc_error;
    ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
      RAISE FND_API.g_exc_unexpected_error;
    END IF;

    IF g_debug_stmt THEN
      PO_DEBUG.debug_var(d_module, l_progress, 'online_report_id',
        p_da_call_rec.online_report_id);
    END IF;

    l_progress := '002';

    --Initialize the flag recreate demad based on the value of cancel_reqs_flag,
    --If PO is a complex PO, the existence of any valid shipment
    --Based on Drop shipments with Updateable Sales Order Lines check
    init_recreate_demand_flag(
      p_api_version=> 1.0,
      p_init_msg_list=>FND_API.G_FALSE,
      p_cancel_reqs_flag => p_da_call_rec.cancel_reqs_flag,
      p_entity_dtl => p_da_call_rec.entity_dtl_record_tbl,
      x_return_status => x_return_status,
      x_msg_data =>x_msg_data);

    IF (x_return_status = FND_API.g_ret_sts_error) THEN
      RAISE FND_API.g_exc_error;
    ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
      RAISE FND_API.g_exc_unexpected_error;
    END IF;

    l_progress := '003';

    -- Upadte the QTY Delivered/Recvd and Qty billed of schedule releases to
    -- Planned Po shipemnts/Distributions.So that the Planned Pos
    -- cancellation can be treated as a regular SPO
    denormPlannedPoQty(
      p_api_version=> 1.0,
      p_init_msg_list=>FND_API.G_FALSE,
      entity_dtl_tbl => p_da_call_rec.entity_dtl_record_tbl,
      p_key => l_key,
      x_return_status => x_return_status);

    IF (x_return_status = FND_API.g_ret_sts_error) THEN
      RAISE FND_API.g_exc_error;
    ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
      RAISE FND_API.g_exc_unexpected_error;
    END IF;

    l_progress := '004';



    -- Perform the cancellation of document
    -- Update the cancel flag and other relevant coulmns on the document
    -- and the backing requisition
    process_cancel_action(
      p_api_version=> 1.0,
      p_init_msg_list=>FND_API.G_FALSE,
      p_da_call_rec =>p_da_call_rec,
      p_key =>l_key,
      p_user_id => l_user_id,
      p_login_id =>l_login_id,
      p_po_enc_flag=>l_po_encumbrance_flag,
      p_req_enc_flag=>l_req_encumbrance_flag,
      x_return_status =>x_return_status,
      x_msg_data =>x_msg_data);

    IF (x_return_status = FND_API.g_ret_sts_error) THEN
      RAISE FND_API.g_exc_error;
    ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
      RAISE FND_API.g_exc_unexpected_error;
    END IF;

    IF g_debug_stmt THEN
      PO_DEBUG.debug_var(d_module,l_progress,'x_return_code',x_return_code);
    END IF;

    -- Check if the process_entity flag is "N' for any of the entities,
    -- then show a standard message as
    -- Cancel action has failed for some douments,
    -- Please run the error report to see the errors.

  EXCEPTION
    WHEN FND_API.g_exc_error THEN
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.add_exc_msg(g_pkg_name, d_api_name||':'||l_progress);
      ROLLBACK TO cancel_document_PVT;
      IF (g_debug_unexp) THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
	FND_LOG.STRING(
          FND_LOG.LEVEL_UNEXPECTED,
          d_module || '.ERROR',
          'EXCEPTION: LOCATION IS ' || l_progress || ' SQL CODE IS '||SQLCODE);
	  END IF;
      END IF;
    WHEN FND_API.g_exc_unexpected_error THEN
      x_return_status := FND_API.g_ret_sts_unexp_error;
      FND_MSG_PUB.add_exc_msg(g_pkg_name, d_api_name||':'||l_progress);
      ROLLBACK TO cancel_document_PVT;

       IF (g_debug_unexp) THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
	FND_LOG.STRING(
          FND_LOG.LEVEL_UNEXPECTED,
          d_module || '.UNEXPECTED ERROR',
          'EXCEPTION: LOCATION IS ' || l_progress || ' SQL CODE IS '||SQLCODE);
	  END IF;
      END IF;


    WHEN OTHERS THEN
      x_return_status := FND_API.g_ret_sts_unexp_error;
      FND_MSG_PUB.add_exc_msg(g_pkg_name, d_api_name||':'||l_progress);
      ROLLBACK TO cancel_document_PVT;

     IF (g_debug_unexp) THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
	FND_LOG.STRING(
          FND_LOG.LEVEL_UNEXPECTED,
          d_module || '.OTHERS EXCEPTION',
          'EXCEPTION: LOCATION IS ' || l_progress || ' SQL CODE IS '||SQLCODE);
	  END IF;
      END IF;

END cancel_document;

/**
 * Function    : is_document_cto_order
 * Description : Determines if the document is a CTO order.
 * Parameters  : p_doc_id - id of the document.
 *               p_doc_type - type of document, either 'PO' or 'RELEASE'
 * Returns     : TRUE if document is a CTO PO. FALSE otherwise.
 * Notes       : See Bug 4571297
*             : Added No_data_found execption as part of Cancel Refactoring Project
 */
FUNCTION is_document_cto_order (
           p_doc_id   IN PO_HEADERS.po_header_id%TYPE,
           p_doc_type IN PO_DOCUMENT_TYPES_ALL_B.document_type_code%TYPE )

  RETURN BOOLEAN
IS

l_cto_order NUMBER;
  d_api_name CONSTANT VARCHAR2(30) := 'is_document_cto_order.';
  d_module   CONSTANT VARCHAR2(100) := g_module_prefix || d_api_name;

  l_progress          VARCHAR2(8)   := '000' ;

BEGIN
BEGIN
     SELECT COUNT(*)
    INTO l_cto_order
    FROM po_requisition_headers_all PRH,
         po_requisition_lines_all PRL,
         po_line_locations POLL
   WHERE PRH.interface_source_code = 'CTO'
     AND PRH.requisition_header_id = PRL.requisition_header_id
     AND PRL.line_location_id = POLL.line_location_id
        AND ( ((p_doc_type = 'PO') AND (POLL.po_header_id = p_doc_id)) OR
              ((p_doc_type = 'RELEASE') AND (POLL.po_release_id = p_doc_id)));

    EXCEPTION

      WHEN No_Data_Found THEN
        l_cto_order := 0;
        IF g_debug_stmt THEN
          PO_DEBUG.debug_stmt(d_module, l_progress, 'Set l_cto_order = 0');
        END IF ;
      WHEN OTHERS THEN
        IF g_debug_stmt THEN
          PO_DEBUG.debug_stmt(d_module, l_progress, 'Exception in is_document_cto_order check');
        END IF ;
        RAISE FND_API.g_exc_unexpected_error;
    END;

  IF (l_cto_order > 0) THEN
    RETURN (TRUE);
  ELSE
    RETURN (FALSE);
  END IF;

EXCEPTION
    WHEN OTHERS THEN
  RAISE FND_API.g_exc_unexpected_error;
END is_document_cto_order;
--<Bug 14207546 :Cancel Refactoring Project Ends>

--------------------------------------------------------------------------------
-- Bug#17805976: add p_entity_id and p_entity_level to
-- procedure val_cancel_backing_reqs

/**
 * Public Procedure: val_cancel_backing_reqs
 * Requires: API message list has been initialized if p_init_msg_list is false.
 *   PO and REQ encumbrance should be on.
 * Modifies: API message list
 * Effects: Ensures that the document has shipments that are not cancelled or
 *   finally closed, and that they are all fully encumbered. Appends to API
 *   message list on error.
 * Returns:
 *   x_return_status - FND_API.G_RET_STS_SUCCESS if validation succeeds
 *                     FND_API.G_RET_STS_ERROR if validation fails
 *                     FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
 */
PROCEDURE val_cancel_backing_reqs
   (p_api_version    IN   NUMBER,
    p_init_msg_list  IN   VARCHAR2,
    x_return_status  OUT  NOCOPY VARCHAR2,
    p_doc_type       IN   PO_DOCUMENT_TYPES.document_type_code%TYPE,
    p_doc_id         IN   NUMBER,
    p_entity_id      IN   NUMBER,           -- Bug#17805976
    p_entity_level   IN   VARCHAR2)         -- Bug#17805976
IS

l_api_name CONSTANT VARCHAR2(30) := 'val_cancel_backing_reqs';
l_api_version CONSTANT NUMBER := 1.0;

BEGIN
--<Bug 4571297> Only perform validation if document is not CTO order
  IF NOT PO_Document_Cancel_PVT.is_document_cto_order
                                 (p_doc_type       => p_doc_type,
                                  p_doc_id         => p_doc_id)
  THEN
    -- Start standard API initialization
    IF FND_API.to_boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;
    IF NOT FND_API.compatible_api_call(l_api_version, p_api_version,
                                       l_api_name, g_pkg_name)
    THEN
        RAISE FND_API.g_exc_unexpected_error;
    END IF;
    x_return_status := FND_API.g_ret_sts_success;
    -- End standard API initialization

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_PROCEDURE) THEN
          FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, g_module_prefix || l_api_name ||
                       '.invoked', 'Type: ' || NVL(p_doc_type,'null') ||
                       ', ID: ' || NVL(TO_CHAR(p_doc_id),'null') ||
                       ' Entity ID : ' || NVL(TO_CHAR(p_entity_id), 'null') ||
                       ' Entity Level: ' || NVL(p_entity_level, 'null'));
        END IF;
    END IF;

    IF NOT PO_Document_Control_PVT.has_shipments
                                    (p_api_version   => 1.0,
                                     p_init_msg_list => FND_API.G_FALSE,
                                     x_return_status => x_return_status,
                                     p_doc_type      => p_doc_type,
                                     p_doc_id        => p_doc_id)
    THEN
        IF (x_return_status <> FND_API.g_ret_sts_success) THEN
            RAISE FND_API.g_exc_unexpected_error;
        END IF;

        -- Document does not have any valid shipments.
        RAISE FND_API.g_exc_error;
    END IF;  --<if has_shipments ...>


    IF PO_Document_Control_PVT.has_unencumbered_shipments
                                    (p_api_version   => 1.0,
                                     p_init_msg_list => FND_API.G_FALSE,
                                     x_return_status => x_return_status,
                                     p_doc_type      => p_doc_type,
                                     p_doc_id        => p_doc_id,
                                     p_entity_id     => p_entity_id,   -- bug#17805976
                                     p_entity_level  => p_entity_level) -- bug#17805976
    THEN
        -- Document has valid, unencumbered shipments. Cannot cancel reqs
        -- because encumbrance is assumed to be on.
        RAISE FND_API.g_exc_error;
    END IF;  --<if has_unencumbered_shipments ...>

    -- Check that an error did not occur in previous procedure call
    IF (x_return_status <> FND_API.g_ret_sts_success) THEN
        RAISE FND_API.g_exc_unexpected_error;
    END IF;

  END IF;

EXCEPTION
    WHEN FND_API.g_exc_error THEN
        x_return_status := FND_API.g_ret_sts_error;
        FND_MESSAGE.set_name('PO','PO_CANCEL_REQ_DISALLOWED');
        IF (g_fnd_debug = 'Y') THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_ERROR) THEN
              FND_LOG.message(FND_LOG.level_error, g_module_prefix || l_api_name
                            || '.cancel_req_disallowed', FALSE);
            END IF;
        END IF;
        FND_MSG_PUB.add;
    WHEN FND_API.g_exc_unexpected_error THEN
        x_return_status := FND_API.g_ret_sts_unexp_error;
    WHEN OTHERS THEN
        x_return_status := FND_API.g_ret_sts_unexp_error;
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
            FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
            IF (g_fnd_debug = 'Y') THEN
                IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
                  FND_LOG.string(FND_LOG.level_unexpected, g_module_prefix ||
                               l_api_name || '.others_exception', 'Exception');
                END IF;
            END IF;
        END IF;
END val_cancel_backing_reqs;


--------------------------------------------------------------------------------
--Start of Comments
--Name: calculate_qty_cancel

--Function:
--
--  Updates the Quanity/Amount Cancelled columns of Po lines/Shipments
--  and Distributions
--  The routine will be called from "Finally Close action"
--
--Parameters:
--IN:
--  p_action_date
--  p_doc_header_id
--  p_line_id
--  p_line_location_id
--  p_document_type
--  p_doc_subtype



--IN OUT:

-- OUT:
--  x_return_status
--    FND_API.G_RET_STS_SUCCESS if procedure succeeds
--    FND_API.G_RET_STS_ERROR if procedure fails
--    FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs



--End of Comments
--------------------------------------------------------------------------------

PROCEDURE calculate_qty_cancel(
            p_api_version       IN NUMBER,
            p_init_msg_list     IN VARCHAR2,
            p_doc_header_id     IN NUMBER,
            p_line_id           IN NUMBER,
            p_line_location_id  IN NUMBER,
            p_document_type     IN VARCHAR2,
            p_doc_subtype       IN VARCHAR2,
            p_action_date       IN DATE,
            x_return_status     OUT NOCOPY VARCHAR2)
  IS

    d_api_name CONSTANT VARCHAR2(30) := 'calculate_qty_cancel';
    d_api_version CONSTANT NUMBER := 1.0;
    d_module   CONSTANT VARCHAR2(100) := g_module_prefix||d_api_name;

    l_progress VARCHAR2(3)            := '000' ;
    l_line_loc_tbl po_tbl_NUMBER;
    l_user_id po_lines.last_updated_by%TYPE    := -1;
    l_login_id po_lines.last_update_login%TYPE := -1;


 -- Bug 17197253: Cancelled Quantity needs to be calculated during Finally close only
 -- for cancelled shipments.
    CURSOR l_ship_cursor(
             p_line_location_id NUMBER,
             p_line_id          NUMBER,
             p_doc_header_id    NUMBER,
             p_document_type    VARCHAR2)
    IS
    SELECT line_location_id
    FROM   po_line_locations
    WHERE  line_location_id = p_line_location_id
            AND p_line_location_id IS NOT NULL
            AND Nvl(cancel_flag, 'N') = 'Y'
    UNION ALL
    SELECT line_location_id
    FROM   po_line_locations
    WHERE  po_line_id = p_line_id
            AND p_line_location_id IS NULL
            AND p_line_id IS NOT NULL
            AND Nvl(cancel_flag, 'N') = 'Y'

    UNION ALL
    SELECT line_location_id
    FROM   po_line_locations
    WHERE  po_header_id = p_doc_header_id
            AND p_line_location_id IS NULL
            AND p_line_id IS NULL
            AND p_doc_header_id IS NOT NULL
            AND p_document_type <> c_doc_type_RELEASE
            AND Nvl(cancel_flag, 'N') = 'Y'

    UNION ALL
    SELECT line_location_id
    FROM   po_line_locations
    WHERE  po_release_id = p_doc_header_id
            AND p_line_location_id IS NULL
            AND p_line_id IS NULL
            AND p_doc_header_id IS NOT NULL
            AND p_document_type = c_doc_type_RELEASE
            AND Nvl(cancel_flag, 'N') = 'Y';



  BEGIN
    -- Start standard API initialization
    IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    IF NOT FND_API.compatible_api_call(d_api_version, p_api_version,
                                        d_api_name, g_pkg_name) THEN
      RAISE FND_API.g_exc_unexpected_error;
    END IF;


    IF g_debug_stmt THEN
      PO_DEBUG.debug_begin(d_module);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_doc_header_id', p_doc_header_id);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_line_id', p_line_id);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_line_location_id', p_line_location_id);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_document_type', p_document_type);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_doc_subtype', p_doc_subtype);
      PO_DEBUG.debug_var(d_module, l_progress, 'p_action_date', p_action_date);

    END IF;

    x_return_status :=FND_API.G_RET_STS_SUCCESS;

    l_progress := '001' ;


    --Get User ID and Login ID
    l_user_id := FND_GLOBAL.USER_ID;
    IF (FND_GLOBAL.CONC_LOGIN_ID >= 0) THEN
      l_login_id := FND_GLOBAL.CONC_LOGIN_ID;
    ELSE
      l_login_id := FND_GLOBAL.LOGIN_ID;
    END IF;

    IF g_debug_stmt THEN
      PO_DEBUG.debug_var(d_module, l_progress, 'l_user_id', l_user_id);
      PO_DEBUG.debug_var(d_module, l_progress, 'l_login_id', l_login_id);
    END IF;

    OPEN l_ship_cursor(p_line_location_id,
            p_line_id,
            p_doc_header_id,
            p_document_type);

    FETCH l_ship_cursor BULK COLLECT INTO
      l_line_loc_tbl;

    CLOSE l_ship_cursor;


    IF g_debug_stmt THEN
      PO_DEBUG.debug_var(d_module, l_progress, 'l_line_loc_tbl.count', l_line_loc_tbl.Count);
    END IF;

    l_progress := '002' ;

    FOR i IN 1..l_line_loc_tbl.Count LOOP

      IF g_debug_stmt THEN
        PO_DEBUG.debug_var(d_module, l_progress, 'l_line_loc_tbl('||i||')', l_line_loc_tbl(i));
      END IF;

      l_progress := '003' ;

      UPDATE
        PO_DISTRIBUTIONS_ALL POD
      SET
        pod.quantity_cancelled = pod.quantity_ordered-greatest(
                                                        NVL(quantity_delivered,0),
                                                        NVL(quantity_financed,0),
                                                        NVL(quantity_billed,0)),
        pod.amount_cancelled   = pod.amount_ordered-greatest(
                                                      NVL(amount_delivered,0),
                                                      NVL(amount_financed,0),
                                                      NVL(amount_billed,0)),
        pod.last_update_date   = p_action_date,
        pod.last_updated_by    = l_user_id,
        pod.last_update_login  = l_login_id
      WHERE pod.line_location_id =l_line_loc_tbl(i);

      IF g_debug_stmt THEN
        PO_DEBUG.debug_var(d_module, l_progress, 'Rows Updated in PO Distributions table', SQL%ROWCOUNT);
      END IF;

      l_progress := '004' ;

      UPDATE po_line_locations POLL
      SET   POLL.last_update_date   = p_action_date,
            POLL.last_updated_by    = l_user_id,
            POLL.last_update_login  = l_login_id,
            POLL.quantity_cancelled = (SELECT SUM(NVL(POD.quantity_cancelled,0))
                                        FROM   PO_DISTRIBUTIONS_ALL POD
                                        WHERE  POD.line_location_id=POLL.line_location_id),
             POLL.amount_cancelled  = (SELECT SUM(NVL(POD.amount_cancelled, 0))
                                       FROM   PO_DISTRIBUTIONS_ALL POD
                                       WHERE  POD.line_location_id=POLL.line_location_id)
      WHERE poll.line_location_id=l_line_loc_tbl(i);

      IF g_debug_stmt THEN
        PO_DEBUG.debug_var(d_module, l_progress, 'Rows Updated in PO Shipments table', SQL%ROWCOUNT);
      END IF;

      l_progress := '005' ;

      UPDATE po_lines pol
      SET   pol.last_update_date   = p_action_date,
            pol.last_updated_by    = l_user_id,
            pol.last_update_login  = l_login_id,
            pol.quantity =
              DECODE(pol.quantity,
                NULL,
                pol.quantity,
                (SELECT SUM(NVL(poll.quantity,0) -NVL(poll.quantity_cancelled,0))
        	       FROM  po_line_locations POLL
                 WHERE poll.po_line_id = pol.po_line_id
                       AND poll.shipment_type IN('STANDARD','PLANNED'))
              ),
            pol.amount =
              DECODE(pol.amount,
                NULL,
                pol.amount,
                (SELECT SUM(DECODE(POLL.amount,
                              NULL,
                              ((NVL(poll.quantity,0) -NVL(poll.quantity_cancelled,0))
                                * POLL.price_override),
                              (NVL(poll.amount, 0) -NVL(poll.amount_cancelled,0))
                           )
                        )
                FROM   po_line_locations POLL
                WHERE  poll.po_line_id = pol.po_line_id
                       AND    poll.shipment_type IN ('STANDARD','PLANNED')) )

      WHERE pol.po_line_id IN(SELECT DISTINCT po_line_id
                              FROM po_line_locations
                              WHERE line_location_id=l_line_loc_tbl(i)
                                    AND shipment_type IN ('STANDARD','PLANNED'));

      IF g_debug_stmt THEN
        PO_DEBUG.debug_var(d_module, l_progress, 'Rows Updated in PO Lines table', SQL%ROWCOUNT);
      END IF;


    END LOOP;

  EXCEPTION

    WHEN FND_API.g_exc_error THEN
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.add_exc_msg(g_module_prefix, d_api_name||':'||l_progress||':'||SQLCODE||':'||SQLERRM);
    WHEN FND_API.g_exc_unexpected_error THEN
      x_return_status := FND_API.g_ret_sts_unexp_error;
      FND_MSG_PUB.add_exc_msg(g_module_prefix, d_api_name||':'||l_progress||':'||SQLCODE||':'||SQLERRM);
    WHEN OTHERS THEN
      x_return_status := FND_API.g_ret_sts_unexp_error;
      FND_MSG_PUB.add_exc_msg(g_module_prefix, d_api_name||':'||l_progress||':'||SQLCODE||':'||SQLERRM);

  END calculate_qty_cancel;


END PO_Document_Cancel_PVT;

/
