--------------------------------------------------------
--  DDL for Package Body JMF_SHIKYU_PO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JMF_SHIKYU_PO_PVT" AS
-- $Header: JMFVSKPB.pls 120.24.12010000.2 2008/09/18 18:56:26 rrajkule ship $ --
--+=======================================================================+
--|               Copyright (c) 2005 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     JMFVSKPB.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|   This package contains PO related calls that the Interlock           |
--|   accesses when processing SHIKYU transactions                        |
--| HISTORY                                                               |
--|     05/09/2005 pseshadr       Created                                 |
--|     13/10/2005 vchu           Modified the Process_Replenishment_PO   |
--|                               procedure for the following:            |
--|                               1) Select the location_id of the TP     |
--|                               organization and insert into the        |
--|                               ship_to_location_id column of the       |
--|                               PO_HEADERS_INTERFACE table.             |
--|                               2) Modified the wait logic after        |
--|                               kicking off the concurrent request      |
--|                               for PDOI.                               |
--|     11/11/2005 vchu           Modified the Process_Replenishment_PO   |
--|                               to insert creation_date, batch_id and   |
--|                               process_code to po_headers_interface    |
--|                               table.  Also modified the call to       |
--|                               FND_REQUEST.submit_request to include   |
--|                               the generated batch_id as parameter.    |
--|     12/23/2005 vchu           Modified the Process_Replenishment_PO   |
--|                               procedure to get the need_by_date from  |
--|                               the po_line_locations in order to       |
--|                               handle changes of the need by date of   |
--|                               the Subcontract PO, since Reconciliation|
--|                               conc prg would consider the old date if |
--|                               taking the need_by_date from the        |
--|                               JMF_SUBCONTRACT_ORDERS table.           |
--|     12/27/2005 vchu           Added a COMMIT statement after calling  |
--|                               FND_REQUEST.submit_request in the       |
--|                               Process_Replenishment_PO procedure in   |
--|                               order for the child request to start    |
--|                               immediately.                            |
--|     12/27/2005 vchu           Modified the c_po cursor to get the     |
--|                               line_location_id of the newly created   |
--|                               PO Shipment with the reference_num      |
--|                               being the concatenation of the          |
--|                               subcontract_po_shipment_id and item_id  |
--|     01/19/2005 vchu           Changed the maximum wait time for the   |
--|                               concurrent request to PDOI to be 10     |
--|                               minutes. WAIT_FOR_REQUEST would not     |
--|                               wait for the max wait time if the       |
--|                               concurrent request completes sooner,    |
--|                               which should be the normal case.        |
--|     02/08/2006 vchu           Bug fix for 4912497: Modified the query |
--|                               to get the currency by joining the      |
--|                               gl_sets_of_books table with             |
--|                               hr_organization_information, instead of |
--|                               the org_organization_definitions view,  |
--|                               which has introduced Full Table Scan on |
--|                               FND_PRODUCT_GROUPS and GL_LEDGERS.      |
--|     02/16/2006 vchu           Bug fix for 4997572: Changed the        |
--|                               stamping logic of the reference_num     |
--|                               column in the PO interface tables in    |
--|                               order to account for the cases where    |
--|                               more than one Replenishment POs were    |
--|                               created for a particular shikyu         |
--|                               component of the subcontracting order,  |
--|                               typically date or quantity changes of   |
--|                               SHIKYU Reconciliation.                  |
--|     03/03/2006 vchu           Bug fix for 4912497:  Modified          |
--|                               Process_Replenishment_PO to get the     |
--|                               max(line_location_id) before kicking    |
--|                               off PDOI, in order to speed up the      |
--|                               query to get back the line_location_id  |
--|                               for the Replenishment PO.               |
--|                               (SQL ID 14833933 and 16439305)          |
--|                               Also removed commented code.            |
--|     05/03/2006 vchu           Fixed bug 5201694: Modified             |
--|                               Process_Replenishment_PO to set context |
--|                               to the OU specified in the concurrent   |
--|                               request instead the OU specified in the |
--|                               'MO: Operating Unit' profile option.    |
--|     05/09/2006 vchu           Bug fix for 5212219: Populate project   |
--|                               id and task id into the                 |
--|                               po_distributions_interface table        |
--|                               in order for the corresponding Sales    |
--|                               Order to pick up.                       |
--|     05/11/2006 vchu           Modified the query for getting the      |
--|                               need_by_date of the Subcontracting      |
--|                               Order Shipment in                       |
--|                               Process_Replenishment_PO to get the     |
--|                               promised_date if need_by_date is NULL.  |
--|   01-MAY-2008      kdevadas  Bug 7000413 -  In case of errors during  |
--|                              rep PO creation, the appropriate message |
--|                              is set and displayed in the request log  |
--|   18-SEP-2008      rrajkule  Bug 7383584 -  Changed cursor c_PO to    |
--|                              add one extra where clause to avoid FTS. |
--+=======================================================================+

--=============================================
-- CONSTANTS
--=============================================
G_PKG_NAME CONSTANT    VARCHAR2(30) := 'JMF_SHIKYU_PO_PVT';
g_log_enabled          BOOLEAN;

--===================
-- PROCEDURES AND FUNCTIONS
--===================


--========================================================================
-- PROCEDURE : Process_Replenishment_PO       PUBLIC
-- PARAMETERS: p_action                   Action
--                                        'C'- Create new job
--                                        'D'- Delete Job
--                                        'U'- Update Job
--            p_subcontract_po_shipment_id OSA Shipment Line
--            p_quantity                   Replenishment Quantity
--            p_item_id                    Component
--            x_return_status         Return Status
-- COMMENT   : This procedure populates data in the interface table
--             and creates a replenishment PO for the subcontracting
--             order shipment line
--========================================================================
PROCEDURE Process_Replenishment_PO
( p_action                 IN  VARCHAR2
, p_subcontract_po_shipment_id IN NUMBER
, p_quantity               IN  NUMBER
, p_item_id                IN  NUMBER
, x_po_line_location_id    OUT NOCOPY NUMBER
, x_return_status          OUT NOCOPY VARCHAR2
)
IS
  l_subcontract_orders_rec    JMF_SUBCONTRACT_ORDERS%ROWTYPE;
  l_quantity                  NUMBER;
  l_interface_header_id       NUMBER;
  l_interface_line_id         NUMBER;
  l_document_number           NUMBER;
  l_vendor_id                 NUMBER;
  l_vendor_site_id            NUMBER;
  l_agent_id                  NUMBER;
  l_po_num_code               VARCHAR2(30);
  l_need_by_date              DATE;
  l_request_id                NUMBER;
  l_user_id                   NUMBER := FND_PROFILE.VALUE('USER_ID');
  l_price                     NUMBER;
  l_item_id                   NUMBER;
  l_po_header_id              NUMBER;
  l_err_count                 NUMBER;
  l_program                   CONSTANT VARCHAR2(30) := 'Process_Replenishment_PO';
  l_phase                     VARCHAR2(80);
  l_status                    BOOLEAN;
  l_dev_phase                 VARCHAR2(80);
  l_con_status                VARCHAR2(80);
  l_dev_status                VARCHAR2(80);
  l_message                   VARCHAR2(240);
  l_org_id                    NUMBER;
  l_currency_code             VARCHAR2(25);
  l_ship_to_location_id       NUMBER;
  l_max_wait                  NUMBER;
  l_batch_id                  NUMBER;
  l_max_line_location_id      NUMBER;
  l_sub_comp             MTL_SYSTEM_ITEMS_B.segment1%TYPE;
  l_order_number         PO_HEADERS_ALL.SEGMENT1%TYPE;
  l_status_flag     BOOLEAN;

  CURSOR c_rec IS
  SELECT *
  FROM   jmf_subcontract_orders
  WHERE  subcontract_po_shipment_id = p_subcontract_po_shipment_id;

  -- Bug fix for 4997572
  -- Changed the query to get the line_location_id of the Replenishment PO Shipment
  -- created by PDOI, since the logic to stamp  the reference_num and line_reference_num
  -- has been changed in order to account for the cases where more than one
  -- Replenishment POs were created for a particular shikyu component of the
  -- subcontracting order, typically SHIKYU Reconciliation.  The reference numbers
  -- are now stamped with the subcontract po shipment id, concatenated with
  -- interface_header_id for reference_num, and interface line id for line_reference_num

  CURSOR c_po IS
  SELECT poll.line_location_id
  FROM   po_line_locations_all poll
     ,   po_headers_all poh
     ,   po_lines_all pol
  WHERE  poll.po_header_id = poh.po_header_id
  AND    poll.po_line_id = pol.po_line_id
  AND    pol.line_reference_num = p_subcontract_po_shipment_id || '-' || l_interface_line_id
  AND    poh.reference_num = p_subcontract_po_shipment_id || '-' || l_interface_header_id
  AND    poh.agent_id = l_agent_id	/*Bug 7383584 : Added extra where clause to stop FTS on po_headers_all table*/
  AND    poll.line_location_id > l_max_line_location_id;

BEGIN

  -- Bug 5201694: Should set context to the OU specified in the concurrent request,
  -- not the OU specified in the 'MO: Operating Unit' profile option.

  --l_org_id := FND_PROFILE.VALUE('ORG_ID');
  l_org_id := mo_global.get_current_org_id;

--  MO_GLOBAL.Init('PO');
  MO_GLOBAL.set_policy_context('S',l_org_id);

  IF g_log_enabled THEN
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN

      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                    , G_PKG_NAME
                    , G_PKG_NAME || ': l_org_id = ' || l_org_id
                    );

      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                    , G_PKG_NAME
                    , G_PKG_NAME || ': p_action = ' || p_action
                      || ', p_subcontract_po_shipment_id = ' || p_subcontract_po_shipment_id
                      || ', p_quantity = ' || p_quantity
                      || ', p_item_id = ' || p_item_id
                    );
    END IF;
  END IF;

  OPEN c_rec;
  FETCH c_rec INTO l_subcontract_orders_rec;
  CLOSE c_rec;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    g_log_enabled := TRUE;
  END IF;

  l_quantity      := p_quantity;
  l_item_id       := p_item_id;

  SELECT NVL(primary_uom_price,0)/NVL(quantity,1)
  INTO   l_price
  FROM   jmf_shikyu_components
  WHERE  subcontract_po_shipment_id = p_subcontract_po_shipment_id
  AND    shikyu_component_id        = l_item_id;

  IF g_log_enabled THEN
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                    , G_PKG_NAME
                    , G_PKG_NAME || ': l_price = ' || l_price
                    );
    END IF;
  END IF;

  SELECT
    org_id
  INTO
    l_org_id
  FROM po_line_locations_all
  WHERE line_location_id = l_subcontract_orders_rec.subcontract_po_shipment_id;

  SELECT
    user_defined_po_num_code
  INTO
    l_po_num_code
  FROM
    po_system_parameters_all
  WHERE  org_id = l_org_id;

  SELECT to_number(hoi.org_information3)
        , to_number(hoi.org_information4)
        , po_headers_interface_s.nextval
        , po_lines_interface_s.nextval
  INTO  l_vendor_id
     ,  l_vendor_site_id
     ,  l_interface_header_id
     ,  l_interface_line_id
  FROM   HR_ORGANIZATION_INFORMATION hoi
  WHERE  hoi.organization_id = l_subcontract_orders_rec.oem_organization_id
  AND    hoi.org_information_context = 'Customer/Supplier Association';

   IF g_log_enabled THEN
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                    , G_PKG_NAME
                    , G_PKG_NAME || ': l_vendor_id = ' || l_vendor_id
                      || ': l_vendor_site_id = ' || l_vendor_site_id
                      || ': l_interface_header_id = ' || l_interface_header_id
                      || ': l_interface_line_id = ' || l_interface_line_id);
    END IF;
  END IF;

  /*
  SELECT glb.currency_code
  INTO   l_currency_code
  FROM   org_organization_definitions ood
     ,   gl_sets_of_books glb
  WHERE  ood.set_of_books_id = glb.set_of_books_id
  AND    ood.organization_id = l_subcontract_orders_rec.oem_organization_id;
  */

  -- Bug 4912497: Modified this query to get the currency from the current
  -- set of books by joining with the hr_organization_information table,
  -- instead of the org_organization_definitions view, which has introduced
  -- the FTS on FND_PRODUCT_GROUPS and GL_LEDGERS

  SELECT glb.currency_code
  INTO   l_currency_code
  FROM   hr_organization_information hoi
     ,   gl_sets_of_books glb
  WHERE  hoi.organization_id = l_subcontract_orders_rec.oem_organization_id
  AND    org_information_context = 'Accounting Information'
  AND    TO_NUMBER(hoi.org_information1) = glb.set_of_books_id;

  IF g_log_enabled THEN
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                    , G_PKG_NAME
                    , G_PKG_NAME || ': l_currency_code = ' || l_currency_code);
    END IF;
  END IF;

  IF l_po_num_code <> 'AUTOMATIC'
  THEN
    l_document_number := l_interface_header_id;
  ELSE
    l_document_number := NULL;
  END IF;

  IF g_log_enabled THEN
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                    , G_PKG_NAME
                    , G_PKG_NAME || ': l_document_number = ' || l_document_number
                    );
    END IF;
  END IF;

  SELECT employee_id
  INTO   l_agent_id
  FROM   fnd_user
  WHERE  user_id = l_user_id;

  IF g_log_enabled THEN
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                    , G_PKG_NAME
                    , G_PKG_NAME || ': l_agent_id = ' || l_agent_id
                    );
    END IF;
  END IF;

  -- To get the actual need_by_date from po_line_locations_all table
  -- since the it might be changed after the intial creation of the
  -- Subcontract PO

  SELECT NVL(need_by_date, promised_date)
  INTO   l_subcontract_orders_rec.need_by_date
  FROM   po_line_locations_all
  WHERE  line_location_id = l_subcontract_orders_rec.subcontract_po_shipment_id;

  IF g_log_enabled THEN
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                    , G_PKG_NAME
                    , G_PKG_NAME || ': l_subcontract_orders_rec.need_by_date = '
                      || l_subcontract_orders_rec.need_by_date
                    );
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                    , G_PKG_NAME
                    , G_PKG_NAME || ': quantity = '
                      || l_quantity
                    );
    END IF;
  END IF;

  -- The need by date on the Replenishment PO is the same as the
  -- planned start date for the OSA item.

  JMF_SHIKYU_WIP_PVT.Compute_Start_Date
  ( p_need_by_date       => l_subcontract_orders_rec.need_by_date
  , p_item_id            => l_subcontract_orders_rec.osa_item_id
  , p_oem_organization   => l_subcontract_orders_rec.oem_organization_id
  , p_tp_organization    => l_subcontract_orders_rec.tp_organization_id
  , p_quantity           => l_quantity
  , x_start_date         => l_need_by_date
  );

  IF g_log_enabled THEN
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                    , G_PKG_NAME
                    , G_PKG_NAME || ': l_quantity = ' || l_quantity || ', l_need_by_date = ' || l_need_by_date
                    );
    END IF;
  END IF;

  l_ship_to_location_id := NULL;

  BEGIN
    SELECT location_id
    INTO   l_ship_to_location_id
    FROM   hr_all_organization_units
    WHERE  organization_id = l_subcontract_orders_rec.tp_organization_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_ship_to_location_id := NULL;
  END;

  IF g_log_enabled THEN
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                    , G_PKG_NAME
                    , G_PKG_NAME || ': l_ship_to_location_id = ' || l_ship_to_location_id);
    END IF;
  END IF;

  l_batch_id := PO_PDOI_UTL.get_next_batch_id;

  IF g_log_enabled THEN
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                    , G_PKG_NAME
                    , G_PKG_NAME || ': l_batch_id = ' || l_batch_id);
    END IF;
  END IF;

  -- Bug fix for 4997572
  -- Stamp the reference_num with the concatenation of the subcontract po
  -- shipment id and interface header id instead of shikyu component id

  INSERT INTO po_headers_interface
  ( interface_header_id
  , action
  , document_type_code
  , document_num
  , vendor_id
  , vendor_site_id
  , agent_id
  , reference_num
  , currency_code
  , ship_to_location_id
  , batch_id
  , process_code
  , approval_status
  , approved_date
  , last_update_date
  , last_updated_by
  , last_update_login
  , creation_date
  , created_by
  )
  VALUES
  ( l_interface_header_id
  , 'ORIGINAL'
  , 'STANDARD'
  , l_document_number
  , l_vendor_id
  , l_vendor_site_id
  , l_agent_id
  , p_subcontract_po_shipment_id || '-' || l_interface_header_id
  , l_currency_code
  , l_ship_to_location_id
  , l_batch_id
  , 'PENDING'
  , 'APPROVED'
  , sysdate
  , sysdate
  , 1
  , 1
  , sysdate
  , 1
  );

  IF g_log_enabled THEN
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                    , G_PKG_NAME
                    , G_PKG_NAME || ': Inserted into po_headers_interface');
    END IF;
  END IF;

  -- Bug fix for 4997572
  -- Stamp the reference_num with the concatenation of the subcontract po
  -- shipment id and interface line id instead of shikyu component id

  INSERT INTO po_lines_interface
  ( interface_header_id
  , interface_line_id
  , line_num
  , item_id
  , quantity
  , need_by_date
  , promised_date
  , unit_price
  , days_early_receipt_allowed
  , days_late_receipt_allowed
  , qty_rcv_tolerance
  , allow_substitute_receipts_flag
  , receiving_routing_id
  , organization_id
  , ship_to_organization_id
  , line_reference_num
  , last_update_date
  , last_updated_by
  , last_update_login
  , creation_date
  , created_by
  , INVOICE_CLOSE_TOLERANCE
  )
  VALUES
  ( l_interface_header_id
  , l_interface_line_id
  , 1
  , l_item_id
  , l_quantity
  , l_need_by_date
  , l_need_by_date
  , l_price
  , 100
  , 100
  , 200
  , 'N'
  , 3
  , l_subcontract_orders_rec.tp_organization_id
  , l_subcontract_orders_rec.tp_organization_id
  --, l_interface_header_id
  , p_subcontract_po_shipment_id || '-' || l_interface_line_id
  , sysdate
  , 1
  , 1
  , sysdate
  , 1
  , 100
  );

  IF g_log_enabled THEN
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                    , G_PKG_NAME
                    , G_PKG_NAME || ': Inserted into po_lines_interface');
    END IF;
  END IF;

  INSERT INTO po_distributions_interface
  ( interface_header_id
  , interface_line_id
  , interface_distribution_id
  , quantity_ordered
  , project_id
  , task_id
  , last_update_date
  , last_updated_by
  , last_update_login
  , creation_date
  , created_by
  )
  VALUES
  ( l_interface_header_id
  , l_interface_line_id
  , PO_DISTRIBUTIONS_INTERFACE_S.nextval
  , l_quantity
  , l_subcontract_orders_rec.project_id
  , l_subcontract_orders_rec.task_id
  , sysdate
  , 1
  , 1
  , sysdate
  , 1
  );

  IF g_log_enabled THEN
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                    , G_PKG_NAME
                    , G_PKG_NAME || ': Inserted into po_distributions_interface');
    END IF;
  END IF;

  -- To get the max line_location_id before calling submit_request
  -- for better performance
  SELECT max(line_location_id)
  INTO   l_max_line_location_id
  FROM   po_line_locations_all;

  l_request_id := FND_REQUEST.submit_request
                  ( application   => 'PO'
                  , program       => 'POXPOPDOI'
                  , description   => ''
                  , start_time    => ''
                  , sub_request   => false
                  , argument1     => ''
                  , argument2     => 'STANDARD'
                  , argument3     => ''
                  , argument4     => 'N'
                  , argument5     => 'N'
                  , argument6     => 'APPROVED'
                  , argument7     => null
                  , argument8     => l_batch_id
                  , argument9     => l_org_id
                  , argument10    => 'N'  );

   -- Need to commit for the concurrent request to PDOI to start immediately
   COMMIT;

   l_status := FND_CONCURRENT.WAIT_FOR_REQUEST
              ( request_id => l_request_id
              , interval   => 1
              , max_wait   => 600
              , phase      => l_phase
              , status     => l_con_status
              , dev_phase  => l_dev_phase
              , dev_status => l_dev_status
              , message    => l_message);

    IF l_dev_phase = 'COMPLETE'
    THEN
      IF l_dev_status IN ('NORMAL','WARNING')
      THEN
        OPEN c_po;
        FETCH c_po INTO x_po_line_location_id;
        IF c_po%NOTFOUND
        THEN
          x_return_status := FND_API.G_RET_STS_ERROR;

          IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                          , G_PKG_NAME
                          , '>> '||l_program||' Error creating PO (1)'
                          );
          END IF;

        ELSE
          x_return_status := FND_API.G_RET_STS_SUCCESS;

          IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                          , G_PKG_NAME
                          , '>> '||l_program||' x_po_line_location_id = ' || x_po_line_location_id
                          );
          END IF;

        END IF;
        CLOSE c_po;

      ELSE
        x_return_status := FND_API.G_RET_STS_ERROR;
        IF g_log_enabled THEN
        IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                         , G_PKG_NAME
                         , '>> '||l_program||' Error creating PO (2): '|| l_message
                         );
        END IF;
        END IF;

      END IF;
    ELSIF l_dev_phase = 'INACTIVE'
    THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      IF g_log_enabled THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                       , G_PKG_NAME
                       , '>> '||l_program||' Manager Inactive'
                       );
      END IF ;
      END IF;

    ELSE
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      IF g_log_enabled THEN
         IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                       , G_PKG_NAME
                       , '>> '||l_program||' Running'
                       );
      END IF;
      END IF;

    END IF;  --dev_phase

  IF x_return_status <> FND_API.G_RET_STS_SUCCESS
  THEN
    FND_MESSAGE.set_name('JMF', 'JMF_SHK_REPLENISH_PO_ERR');
    FND_MSG_PUB.add;

    /*  Bug 7000413 - Start */
    /* Log the error in the Concurrent Request log  if allocation fails */
    BEGIN
      SELECT segment1
      INTO l_order_number
      FROM po_headers_all poh
      WHERE EXISTS
      (SELECT 1 FROM po_line_locations_all poll
       WHERE poll.line_location_id = l_subcontract_orders_rec.subcontract_po_shipment_id
       AND poll.po_header_id = poh.po_header_id);

      SELECT segment1
      INTO l_sub_comp
      FROM mtl_system_items_b
      WHERE inventory_item_id = l_item_id
      AND organization_id = l_subcontract_orders_rec.tp_organization_id;

      fnd_message.set_name('JMF','JMF_SHK_REP_PO_ERROR');
      fnd_message.set_token('SUB_ORDER', l_order_number );
      fnd_message.set_token('SUB_COMP', l_sub_comp);
      l_message := fnd_message.GET();
      fnd_file.put_line(fnd_file.LOG,  l_message);
      l_status_flag := FND_CONCURRENT.set_completion_status('WARNING',NULL);
    EXCEPTION
    WHEN OTHERS THEN
      NULL; -- Return null if there is an error in fetching the message
    END;
    /*  Bug 7000413 - End */

  END IF;

EXCEPTION
WHEN OTHERS THEN
  x_return_status := FND_API.G_RET_STS_ERROR;
  FND_MESSAGE.set_name('JMF', 'JMF_SHK_REPLENISH_PO_ERR');
  FND_MSG_PUB.add;

END Process_Replenishment_PO;

END JMF_SHIKYU_PO_PVT;

/
