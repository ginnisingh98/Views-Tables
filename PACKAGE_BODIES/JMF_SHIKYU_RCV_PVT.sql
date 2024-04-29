--------------------------------------------------------
--  DDL for Package Body JMF_SHIKYU_RCV_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JMF_SHIKYU_RCV_PVT" AS
--$Header: JMFVSKVB.pls 120.4 2006/10/11 15:03:14 vmutyala noship $
--+===========================================================================+
--|                    Copyright (c) 2005 Oracle Corporation                  |
--|                       Redwood Shores, California, USA                     |
--|                            All rights reserved.                           |
--+===========================================================================+
--|                                                                           |
--|  FILENAME :           JMFVSKVB.pls                                        |
--|                                                                           |
--|  DESCRIPTION:         Body file of the Process Receiving Transactions     |
--|                       package.                                            |
--|                                                                           |
--|  FUNCTION/PROCEDURE:  process_rcv_header                                  |
--|                       process_rcv_trx                                     |
--|                                                                           |
--|  HISTORY:                                                                 |
--|    10-JUN-2005        jizheng   Created.                                  |
--|    15-JUN-2005        THE2      Add locator_id process logic              |
--|    27-JUN-2005        THE2      Add project_id process logic              |
--|    27-JUN-2005        VMUTYALA  Add from_subinventory and from_locator_id |
--|                                 process logic                             |
--|    27-JUN-2005        THE2      Add replenish_order_line_id process logic |
--|                                                                           |
--|    11/10/2006         vmutyala  Bug 5592230 adding parameter              |
--|                                 p_vendor_site_id to the procedure         |
--|                                 process_rcv_header                        |
--+===========================================================================+

--========================================================================
-- PROCEDURE : process_rcv_header           PUBLIC
-- PARAMETERS: p_vendor_id          IN            NUMBER
--             p_ship_to_org_id     IN            NUMBER
--             x_rcv_header_id      OUT NOCOPY    NUMBER
--             x_group_id           OUT NOCOPY    NUMBER

-- COMMENT   : This procedure inserts records in rev_header_interface for auto_receive
--========================================================================
PROCEDURE  Process_Rcv_Header
( p_vendor_id         IN         NUMBER
, p_vendor_site_id    IN         NUMBER
, p_ship_to_org_id    IN         NUMBER
, x_rcv_header_id     OUT NOCOPY NUMBER
, x_group_id          OUT NOCOPY NUMBER
)
IS
l_api_name             VARCHAR2(50) := 'process_rcv_header';

l_rcv_header_id        rcv_headers_interface.header_interface_id%TYPE;
l_group_id             rcv_headers_interface.group_id%TYPE;

BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    fnd_log.STRING(fnd_log.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX || l_api_name || '.begin'
                  ,'procedure begin');
  END IF;

  SELECT
    rcv_headers_interface_s.NEXTVAL
    , rcv_interface_groups_s.NEXTVAL
  INTO
    l_rcv_header_id
    , l_group_id
  FROM
    dual;

   INSERT INTO RCV_HEADERS_INTERFACE
  ( header_interface_id
   , group_id
   , processing_status_code
   , receipt_source_code
   , transaction_type
   , last_update_date
   , last_updated_by
   , creation_date
   , created_by
   , vendor_id
   , VENDOR_SITE_ID
   , validation_flag
   , Ship_To_Organization_id
   , expected_receipt_date
   )
  VALUES(
    l_rcv_header_id
    , l_group_id
    , 'PENDING'
    , 'VENDOR'
    , 'NEW'
    , SYSDATE
    , fnd_global.LOGIN_ID
    , SYSDATE
    , fnd_global.CONC_LOGIN_ID
    , p_vendor_id
    , p_vendor_site_id
    , 'Y'
    , p_ship_to_org_id
    , SYSDATE);
  COMMIT;

  x_rcv_header_id := l_rcv_header_id;
  x_group_id      := l_group_id;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    fnd_log.STRING(fnd_log.LEVEL_PROCEDURE
                     , G_MODULE_PREFIX || l_api_name || '.end'
                     ,'END procedure. ');
  END IF;

EXCEPTION

  WHEN OTHERS THEN
    IF(FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string( FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_PREFIX || l_api_name || '. OTHER_EXCEPTION '
                    , 'Unknown error'||SQLCODE||SQLERRM);
    END IF;
    RAISE;

END process_rcv_header;

--========================================================================
-- PROCEDURE : process_rcv_trx              PUBLIC
-- PARAMETERS: p_rcv_header_id              IN    NUMBER
--             p_group_id                   IN    NUMBER
--             p_quantity                   IN    NUMBER
--             p_unit_of_measure            IN    VARCHAR2
--             p_po_header_id               IN    NUMBER
--             p_po_line_id                 IN    NUMBER
--             p_po_line_location_id        IN    NUMBER
--             p_po_distribution_id         IN    NUMBER
--             p_subinventory               IN    VARCHAR2
--             p_transaction_type           IN    VARCHAR2
--             p_auto_transact_code         IN    VARCHAR2
--             p_parent_transaction_id      IN    NUMBER

-- COMMENT   : This procedure inserts records in rev_transactions_interface for auto_receive
--========================================================================
PROCEDURE Process_Rcv_Trx
( p_rcv_header_id            IN NUMBER
, p_group_id                 IN NUMBER
, p_quantity                 IN NUMBER
, p_unit_of_measure          IN VARCHAR2
, p_po_header_id             IN NUMBER
, p_po_line_id               IN NUMBER
, p_subinventory             IN VARCHAR2 DEFAULT NULL
, p_transaction_type         IN VARCHAR2
, p_auto_transact_code       IN VARCHAR2 DEFAULT NULL
, p_parent_transaction_id    IN NUMBER
, p_po_line_location_id      IN NUMBER
, p_locator_id               IN NUMBER DEFAULT NULL
, p_project_id               IN NUMBER DEFAULT NULL
, p_from_subinventory        IN VARCHAR2 DEFAULT NULL
, p_from_locator_id          IN NUMBER DEFAULT NULL
, p_replenish_order_line_id  IN NUMBER DEFAULT NULL
)
IS
l_api_name                     VARCHAR2(30) := 'process_rcv_trx';

BEGIN

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    fnd_log.STRING(fnd_log.LEVEL_PROCEDURE
                     , G_MODULE_PREFIX || l_api_name || '.begin'
                     ,'procedure begin');
  END IF;

  INSERT INTO RCV_TRANSACTIONS_INTERFACE
  ( interface_transaction_id
  , header_interface_id
  , group_id
  , last_update_date
  , last_updated_by
  , creation_date
  , created_by
  , transaction_type
  , transaction_date
  , processing_status_code
  , processing_mode_code
  , transaction_status_code
  , quantity                        --quantity
  , unit_of_measure                 --uom
  , auto_transact_code
  , receipt_source_code
  , source_document_code
  , po_header_id
  , po_line_id
  , validation_flag
  , subinventory
  , parent_transaction_id
  , po_line_location_id
  , locator_id
  , project_id
  , from_subinventory
  , from_locator_id
  , replenish_order_line_id
  )
  SELECT
    RCV_TRANSACTIONS_INTERFACE_S.NEXTVAL
    , p_rcv_header_id
    , p_group_id
    , SYSDATE
    , fnd_global.LOGIN_ID
    , SYSDATE
    , fnd_global.LOGIN_ID
    , p_transaction_type -- 'RECEIVE' --  'SHIP',
    , SYSDATE
    , 'PENDING'
    , 'BATCH'
    , 'PENDING'
    , p_quantity
    , p_unit_of_measure
    , p_auto_transact_code -- 'RECEIVE',  --'DELIVER'
    , 'VENDOR'
    , 'PO'
    , p_po_header_id
    , p_po_line_id
    , 'Y'
    , p_subinventory
    , p_parent_transaction_id
    , p_po_line_location_id
    , p_locator_id
    , p_project_id
    , p_from_subinventory
    , p_from_locator_id
    , p_replenish_order_line_id
  FROM DUAL;
  COMMIT;


  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    fnd_log.STRING(fnd_log.LEVEL_PROCEDURE
                     , G_MODULE_PREFIX || l_api_name || '.end'
                     ,'END procedure. '
                   );
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF(FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string( FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_PREFIX || l_api_name || '. OTHER_EXCEPTION '
                    , 'Unknown error'||SQLCODE||SQLERRM);
    END IF;
    RAISE;

END process_rcv_trx;

END JMF_SHIKYU_RCV_PVT;

/
