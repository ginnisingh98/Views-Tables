--------------------------------------------------------
--  DDL for Package Body INV_MGD_MVT_STATS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_MGD_MVT_STATS_PVT" AS
-- $Header: INVVMVTB.pls 120.3.12010000.3 2008/11/03 12:12:34 ajmittal ship $
--+=======================================================================+
--|               Copyright (c) 1998 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     INVVMVTB.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|                                                                       |
--|                                                                       |
--| PROCEDURE LIST                                                        |
--|     Create_Movement_Statistics                                        |
--|     Init_Movement_Record                                              |
--|     Get_Open_Mvmt_Stats_Txns                                          |
--|     Validate_Movement_Statistics                                      |
--|     Update_Movement_Statistics                                        |
--|     Delete_Movement_Statistics                                        |
--|     Validate_Rules                                                    |
--|     Get_Invoice_Transactions                                          |
--|     Get_Pending_Txns                                                  |
--|     Get_PO_Trans_With_Correction                                      |
--|                                                                       |
--| HISTORY                                                               |
--|     04/17/00 pseshadr        Created                                  |
--|     06/12/00 ksaini          Added procedures                         |
--|     07/18/00 ksaini          Added Validate_Rules procedure           |
--|     09/15/00 ksaini          Updated with right message code for      |
--|               incorrect or missing values in Validate_Rules procedure |
--|     09/26/00 ksaini          Corrected return status of validate_rules|
--|     09/29/00 ksaini          Corrected Validation rule for Not        |
--|                         Required fields and incorrect attribute values|
--|     04/01/02 pseshadr        Added  new procedure Get_Pending_Txns    |
--|     08/01/03 tsimmond    Added code to Validate_rules for missing     |
--|                          Trading Partner VAT number exception (FPJ)   |
--|     09/22/03 tsimmond   Corrected code in Validate_record, so that    |
--|                         exception will not be reported first if it can|
--|                         be corrected                                  |
--|     03/30/04 tsimmond  Enhancement request 2757987, changed cursor in |
--|                        Get_Open_Mvmt_Stats_Txns to show only warnings |
--|                        and exceptions for the chosen period           |
--+========================================================================

--===================
-- GLOBALS
--===================

G_PKG_NAME CONSTANT          VARCHAR2(30) := 'INV_MGD_MVT_STATS_PVT';
g_final_excp_list            INV_MGD_MVT_DATA_STR.excp_list ;
G_rpt_page_col               CONSTANT INTEGER      := 78 ;
G_format_space               CONSTANT INTEGER      := 2;
g_mvt_count                  NUMBER;
g_movement_id                NUMBER;
g_parent_movement_id         NUMBER;
g_too_many_transactions_exc  EXCEPTION;
g_no_data_transaction_exc    EXCEPTION;
g_oe_or_om                   VARCHAR2(30);
G_MODULE_NAME CONSTANT VARCHAR2(100) := 'inv.plsql.INV_MGD_MVT_STATS_PVT.';

--========================================================================
-- PROCEDURE : Create_Movement_Statistics PUBLIC
-- PARAMETERS: p_api_version_number    known api version
--             p_init_msg_list         FND_API.G_FALSE not to reset list
--             p_transaction_type      transaction type(inv,rec.,PO etc)
--             x_return_status         return status
--             x_msg_count             number of messages in the list
--             x_msg_data              message text
--             p_material_transaction  material transaction data record
--             p_shipment_transaction  shipment transaction data record
--             p_receipt_transaction   receipt transaction data record
--             p_movement_transaction  movement transaction data record
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : Called by the Process Transaction after all the
--             processing is done to insert the transaction/record
--             into the movement statistics table.
--             This procedure does the insert into the table.
--=======================================================================
PROCEDURE Create_Movement_Statistics
( p_api_version_number   IN  NUMBER
, p_init_msg_list        IN  VARCHAR2
, x_movement_transaction IN OUT NOCOPY
    INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
, x_return_status        OUT NOCOPY VARCHAR2
, x_msg_count            OUT NOCOPY NUMBER
, x_msg_data             OUT NOCOPY VARCHAR2
)
IS
l_api_version_number    CONSTANT NUMBER := 1.0;
l_api_name              CONSTANT VARCHAR2(30) := 'Create_Movement_Statistics';
l_movement_id	        NUMBER;
l_parent_movement_id    NUMBER := NULL;
l_movement_transaction  INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type;
l_insert_flag           VARCHAR2(1);
l_return_status1        VARCHAR2(1);
l_return_status2        VARCHAR2(1);

BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_api_name || '.begin'
                  ,'enter procedure'
                  );
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_return_status1 := 'S';
  l_return_status2 := 'S';

  g_movement_id        := NULL;
  g_parent_movement_id := NULL;

  --  Standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call
    ( l_api_version_number
    , p_api_version_number
    , l_api_name
    , G_PKG_NAME
    )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  l_movement_transaction  := x_movement_transaction;
  l_insert_flag           := 'Y';

  IF l_movement_transaction.movement_id is not null
  THEN
    l_movement_id := l_movement_transaction.movement_id;
  END IF;

  IF l_movement_transaction.movement_status IN ('O','V','P')
  THEN
    INV_MGD_MVT_DEF_ATTR.Default_Attr
    ( p_api_version_number   => 1.0
    , p_init_msg_list        => FND_API.G_FALSE
    , p_movement_transaction => l_movement_transaction
    , x_transaction_nature   => l_movement_transaction.transaction_nature
    , x_delivery_terms       => l_movement_transaction.delivery_terms
    , x_area                 => l_movement_transaction.area
    , x_port                 => l_movement_transaction.port
    , x_csa_code             => l_movement_transaction.csa_code
    , x_oil_reference_code   => l_movement_transaction.oil_reference_code
    , x_container_type_code  => l_movement_transaction.container_type_code
    , x_flow_indicator_code  => l_movement_transaction.flow_indicator_code
    , x_affiliation_reference_code =>
         l_movement_transaction.affiliation_reference_code
    , x_taric_code           => l_movement_transaction.taric_code
    , x_preference_code      => l_movement_transaction.preference_code
    , x_statistical_procedure_code =>
                        l_movement_transaction.statistical_procedure_code
    , x_transport_mode       => l_movement_transaction.transport_mode
    , x_msg_count            => x_msg_count
    , x_msg_data             => x_msg_data
    , x_return_status        => l_return_status1
    );

    INV_MGD_MVT_DEF_ATTR.Default_Value
    ( p_api_version_number      => 1.0
    , p_init_msg_list           => FND_API.G_FALSE
    , p_movement_transaction    => l_movement_transaction
    , x_document_unit_price     => l_movement_transaction.document_unit_price
    , x_document_line_ext_value => l_movement_transaction.document_line_ext_value
    , x_movement_amount         => l_movement_transaction.movement_amount
    , x_stat_ext_value          => l_movement_transaction.stat_ext_value
    , x_msg_count               => x_msg_count
    , x_msg_data                => x_msg_data
    , x_return_status           => l_return_status2
    );

    --yawang fix bug 2268875
    IF l_return_status1 <> 'S'
    THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
        FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                      , G_MODULE_NAME || l_api_name
                      , 'Failed in calling default_attr '||substrb(x_msg_data,1,255)
                      );
      END IF;
    END IF;

    IF l_return_status2 <> 'S'
    THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
        FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                      , G_MODULE_NAME || l_api_name
                      , 'Failed in calling default_Value '||substrb(x_msg_data,1,255)
                      );
      END IF;
    END IF;

    IF (l_return_status1 = 'S' AND l_return_status2 = 'S')
    THEN
      SELECT MTL_MOVEMENT_STATISTICS_S.NEXTVAL
      INTO l_parent_movement_id
      FROM SYS.DUAL;

      INSERT INTO
      MTL_MOVEMENT_STATISTICS(
        movement_id
      , organization_id
      , entity_org_id
      , movement_type
      , movement_status
      , transaction_date
      , last_update_date
      , last_updated_by
      , creation_date
      , created_by
      , last_update_login
      , document_source_type
      , creation_method
      , document_reference
      , document_line_reference
      , document_unit_price
      , document_line_ext_value
      , receipt_reference
      , shipment_reference
      , shipment_line_reference
      , pick_slip_reference
      , customer_name
      , customer_number
      , customer_location
      , transacting_from_org
      , transacting_to_org
      , vendor_name
      , vendor_number
      , vendor_site
      , bill_to_name
      , bill_to_number
      , bill_to_site
      , ship_to_name
      , ship_to_number
      , ship_to_site
      , po_header_id
      , po_line_id
      , po_line_location_id
      , order_header_id
      , order_line_id
      , picking_line_id
      , shipment_header_id
      , shipment_line_id
      , ship_to_customer_id
      , ship_to_site_use_id
      , bill_to_customer_id
      , bill_to_site_use_id
      , vendor_id
      , vendor_site_id
      , from_organization_id
      , to_organization_id
      , parent_movement_id
      , inventory_item_id
      , item_description
      , item_cost
      , transaction_quantity
      , transaction_uom_code
      , primary_quantity
      , invoice_batch_id
      , invoice_id
      , customer_trx_line_id
      , invoice_batch_reference
      , invoice_reference
      , invoice_line_reference
      , invoice_date_reference
      , invoice_quantity
      , invoice_unit_price
      , invoice_line_ext_value
      , outside_code
      , outside_ext_value
      , outside_unit_price
      , currency_code
      , currency_conversion_rate
      , currency_conversion_type
      , currency_conversion_date
      , period_name
      , report_reference
      , report_date
      , category_id
      , weight_method
      , unit_weight
      , total_weight
      , transaction_nature
      , delivery_terms
      , transport_mode
      , alternate_quantity
      , alternate_uom_code
      , dispatch_territory_code
      , destination_territory_code
      , origin_territory_code
      , dispatch_territory_eu_code
      , destination_territory_eu_code
      , origin_territory_eu_code
      , stat_method
      , stat_adj_percent
      , stat_adj_amount
      , stat_ext_value
      , area
      , port
      , stat_type
      , comments
      , commodity_code
      , commodity_description
      , requisition_header_id
      , requisition_line_id
      , picking_line_detail_id
      , attribute1
      , attribute2
      , attribute3
      , attribute4
      , attribute5
      , attribute6
      , attribute7
      , attribute8
      , attribute9
      , attribute10
      , attribute11
      , attribute12
      , attribute13
      , attribute14
      , attribute15
      , edi_sent_flag
      , usage_type
      , zone_code
      , statistical_procedure_code
      , movement_amount
      , taric_code
      , preference_code
      , triangulation_country_code
      , triangulation_country_eu_code
      , csa_code
      , oil_reference_code
      , container_type_code
      , flow_indicator_code
      , affiliation_reference_code
      , set_of_books_period
      , rcv_transaction_id
      , mtl_transaction_id
      , total_weight_uom_code
      , distribution_line_number
      , financial_document_flag
      , edi_transaction_reference
      , edi_transaction_date
      , esl_drop_shipment_code
      , customer_vat_number
       )
      VALUES(
	 l_parent_movement_id
      , l_movement_transaction.organization_id
      , l_movement_transaction.entity_org_id
      , l_movement_transaction.movement_type
      , l_movement_transaction.movement_status
      , TRUNC(l_movement_transaction.transaction_date)
      , l_movement_transaction.last_update_date
      , l_movement_transaction.last_updated_by
      , l_movement_transaction.creation_date
    , l_movement_transaction.created_by
    , l_movement_transaction.last_update_login
    , l_movement_transaction.document_source_type
    , NVL(l_movement_transaction.creation_method,'A')
    , l_movement_transaction.document_reference
    , l_movement_transaction.document_line_reference
    , l_movement_transaction.document_unit_price
    , l_movement_transaction.document_line_ext_value
    , l_movement_transaction.receipt_reference
    , l_movement_transaction.shipment_reference
    , l_movement_transaction.shipment_line_reference
    , l_movement_transaction.pick_slip_reference
    , l_movement_transaction.customer_name
    , l_movement_transaction.customer_number
    , l_movement_transaction.customer_location
    , l_movement_transaction.transacting_from_org
    , l_movement_transaction.transacting_to_org
    , l_movement_transaction.vendor_name
    , l_movement_transaction.vendor_number
    , l_movement_transaction.vendor_site
    , l_movement_transaction.bill_to_name
    , l_movement_transaction.bill_to_number
    , l_movement_transaction.bill_to_site
    , l_movement_transaction.ship_to_name
    , l_movement_transaction.ship_to_number
    , l_movement_transaction.ship_to_site
    , l_movement_transaction.po_header_id
    , l_movement_transaction.po_line_id
    , l_movement_transaction.po_line_location_id
    , l_movement_transaction.order_header_id
    , l_movement_transaction.order_line_id
    , l_movement_transaction.picking_line_id
    , l_movement_transaction.shipment_header_id
    , l_movement_transaction.shipment_line_id
    , l_movement_transaction.ship_to_customer_id
    , l_movement_transaction.ship_to_site_use_id
    , l_movement_transaction.bill_to_customer_id
    , l_movement_transaction.bill_to_site_use_id
    , l_movement_transaction.vendor_id
    , l_movement_transaction.vendor_site_id
    , l_movement_transaction.from_organization_id
    , l_movement_transaction.to_organization_id
    , nvl(l_movement_id,l_parent_movement_id)
    , l_movement_transaction.inventory_item_id
    , l_movement_transaction.item_description
    , l_movement_transaction.item_cost
    , l_movement_transaction.transaction_quantity
    , l_movement_transaction.transaction_uom_code
    , l_movement_transaction.primary_quantity
    , l_movement_transaction.invoice_batch_id
    , l_movement_transaction.invoice_id
    , l_movement_transaction.customer_trx_line_id
    , l_movement_transaction.invoice_batch_reference
    , l_movement_transaction.invoice_reference
    , l_movement_transaction.invoice_line_reference
    , l_movement_transaction.invoice_date_reference
    , l_movement_transaction.invoice_quantity
    , l_movement_transaction.invoice_unit_price
    , l_movement_transaction.invoice_line_ext_value
    , l_movement_transaction.outside_code
    , l_movement_transaction.outside_ext_value
    , l_movement_transaction.outside_unit_price
    , l_movement_transaction.currency_code
    , l_movement_transaction.currency_conversion_rate
    , l_movement_transaction.currency_conversion_type
    , l_movement_transaction.currency_conversion_date
    , l_movement_transaction.period_name
    , l_movement_transaction.report_reference
    , l_movement_transaction.report_date
    , l_movement_transaction.category_id
    , l_movement_transaction.weight_method
    , l_movement_transaction.unit_weight
    , l_movement_transaction.total_weight
    , l_movement_transaction.transaction_nature
    , l_movement_transaction.delivery_terms
    , l_movement_transaction.transport_mode
    , l_movement_transaction.alternate_quantity
    , l_movement_transaction.alternate_uom_code
    , l_movement_transaction.dispatch_territory_code
    , l_movement_transaction.destination_territory_code
    , l_movement_transaction.origin_territory_code
    , l_movement_transaction.dispatch_territory_eu_code
    , l_movement_transaction.destination_territory_eu_code
    , l_movement_transaction.origin_territory_eu_code
    , l_movement_transaction.stat_method
    , l_movement_transaction.stat_adj_percent
    , l_movement_transaction.stat_adj_amount
    , nvl(l_movement_transaction.stat_ext_value,
          l_movement_transaction.movement_amount)
    , l_movement_transaction.area
    , l_movement_transaction.port
    , l_movement_transaction.stat_type
    , l_movement_transaction.comments
    , l_movement_transaction.commodity_code
    , l_movement_transaction.commodity_description
    , l_movement_transaction.requisition_header_id
    , l_movement_transaction.requisition_line_id
    , l_movement_transaction.picking_line_detail_id
    , l_movement_transaction.attribute1
    , l_movement_transaction.attribute2
    , l_movement_Transaction.attribute3
    , l_movement_Transaction.attribute4
    , l_movement_Transaction.attribute5
    , l_movement_Transaction.attribute6
    , l_movement_Transaction.attribute7
    , l_movement_Transaction.attribute8
    , l_movement_Transaction.attribute9
    , l_movement_Transaction.attribute10
    , l_movement_Transaction.attribute11
    , l_movement_Transaction.attribute12
    , l_movement_Transaction.attribute13
    , l_movement_Transaction.attribute14
    , l_movement_Transaction.attribute15
    , l_movement_transaction.edi_sent_flag
    , l_movement_transaction.usage_type
    , l_movement_transaction.zone_code
    , l_movement_transaction.statistical_procedure_code
    , l_movement_transaction.movement_amount
    , l_movement_transaction.taric_code
    , l_movement_transaction.preference_code
    , l_movement_transaction.triangulation_country_code
    , l_movement_transaction.triangulation_country_eu_code
    , l_movement_transaction.csa_code
    , l_movement_transaction.oil_reference_code
    , l_movement_transaction.container_type_code
    , l_movement_transaction.flow_indicator_code
    , l_movement_transaction.affiliation_reference_code
    , l_movement_transaction.set_of_books_period
    , l_movement_transaction.rcv_transaction_id
    , l_movement_transaction.mtl_transaction_id
    , l_movement_transaction.total_weight_uom_code
    , l_movement_transaction.distribution_line_number
      , NVL(l_movement_transaction.financial_document_flag,'NOT_REQUIRED')
      , l_movement_transaction.edi_transaction_reference
      , l_movement_transaction.edi_transaction_date
      , l_movement_transaction.esl_drop_shipment_code
      , l_movement_transaction.customer_vat_number
      );

      g_movement_id        := l_parent_movement_id;
      g_parent_movement_id := nvl(l_movement_id,l_parent_movement_id);

      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
        FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                      , G_MODULE_NAME || l_api_name
                      , 'Insert movement record successfully'
                      );
      END IF;
    END IF;

    x_movement_transaction := l_movement_transaction;
    x_movement_transaction.movement_id := g_movement_id;
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_api_name || '.end'
                  ,'exit procedure'
                  );
  END IF;
EXCEPTION

   WHEN NO_DATA_FOUND THEN
    g_movement_id    := null;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.Set_Name('INV', 'INV_MGD_UPDATE_EXC');
    FND_MSG_PUB.Add;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg
      ( G_PKG_NAME
      , 'Create_Movement_Statistics'
      );
    END IF;
    RAISE g_no_data_transaction_exc;


  WHEN FND_API.G_EXC_ERROR THEN
    g_movement_id    := null;
    x_return_status := FND_API.G_RET_STS_ERROR;
    --  Get message count and data
    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count
    , p_data  => x_msg_data
    );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    g_movement_id    := null;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    --  Get message count and data
    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count
    , p_data  => x_msg_data
    );

  WHEN OTHERS THEN
    g_movement_id    := null;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                             , 'Create_Movement_Statistics'
                             );
    END IF;
    --  Get message count and data
    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count
    , p_data  => x_msg_data
    );
  RAISE;

END Create_Movement_Statistics;

--========================================================================
-- PROCEDURE : Init_Movement_Record
-- PARAMETERS:
--             x_movement_transaction  in out  movement transaction data record
-- COMMENT   : This procedure defaults values for certain attributes which
--             are common for all the transactions.
--             Eg: statistical_procedure_code,creation_method etc.
--=======================================================================
PROCEDURE Init_Movement_Record
( x_movement_transaction IN OUT NOCOPY
    INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
)
IS
  l_api_name CONSTANT VARCHAR2(30) := 'Init_Movement_Record';
BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_api_name || '.begin'
                  ,'enter procedure'
                  );
  END IF;

  x_movement_transaction.last_updated_by                 :=
    NVL(TO_NUMBER(fnd_profile.value('USER_ID')),0);
  x_movement_transaction.creation_date                   := SYSDATE;
  x_movement_transaction.last_update_date                := SYSDATE;
  x_movement_transaction.created_by                      :=
    NVL(TO_NUMBER(fnd_profile.value('USER_ID')),0);
  x_movement_transaction.last_update_login               :=
    NVL(TO_NUMBER(fnd_profile.value('LOGIN_ID')),0);
  x_movement_transaction.weight_method                   := 'S';
  x_movement_transaction.stat_method                     := 'S';
--  x_movement_transaction.creation_method                 := 'A';
IF NVL(x_movement_transaction.movement_status,'N') = 'N' THEN
  x_movement_transaction.movement_status                 := 'O';
END IF;
  x_movement_transaction.edi_sent_flag                   := 'N';
  x_movement_transaction.statistical_procedure_code      :=  NULL;
  x_movement_transaction.transport_mode                  := '3';
  x_movement_transaction.financial_document_flag         := 'NOT_REQUIRED';

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_api_name || '.end'
                  ,'exit procedure'
                  );
  END IF;
END Init_Movement_Record;


--========================================================================
-- PROCEDURE : Get_Open_Mvmt_Stats_Txns    PRIVATE
-- PARAMETERS: val_crsr                    REF cursor
--             x_return_status             return status
--             p_start_date                Transaction start date
--             p_end_date              Transaction end date
-- COMMENT   :
--             This opens the cursor for INV and returns the cursor.
--========================================================================

PROCEDURE Get_Open_Mvmt_Stats_Txns (
   val_crsr                     IN OUT NOCOPY  INV_MGD_MVT_DATA_STR.valCurTyp
 , p_movement_statistics        IN
                  INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
 , p_legal_entity_id            IN  NUMBER
 , p_economic_zone_code         IN  VARCHAR2
 , p_usage_type                 IN  VARCHAR2
 , p_stat_type                  IN  VARCHAR2
 , p_period_name                IN  VARCHAR2
 , p_document_source_type       IN  VARCHAR2
 , x_return_status              OUT NOCOPY VARCHAR2
)
IS
  l_api_name CONSTANT VARCHAR2(30) := 'Get_Open_Mvmt_Stats_Txns';
BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_api_name || '.begin'
                  ,'enter procedure'
                  );
  END IF;

  x_return_status := 'Y';

    IF val_crsr%ISOPEN THEN
	 CLOSE val_crsr;
	   END IF;


OPEN val_crsr FOR
SELECT
    mtl_stats.movement_id
  , mtl_stats.organization_id
  , mtl_stats.entity_org_id
  , mtl_stats.movement_type
  , mtl_stats.movement_status
  , mtl_stats.transaction_date
  , mtl_stats.last_update_date
  , mtl_stats.last_updated_by
  , mtl_stats.creation_date
  , mtl_stats.created_by
  , mtl_stats.last_update_login
  , mtl_stats.document_source_type
  , mtl_stats.creation_method
  , mtl_stats.document_reference
  , mtl_stats.document_line_reference
  , mtl_stats.document_unit_price
  , mtl_stats.document_line_ext_value
  , mtl_stats.receipt_reference
  , mtl_stats.shipment_reference
  , mtl_stats.shipment_line_reference
  , mtl_stats.pick_slip_reference
  , mtl_stats.customer_name
  , mtl_stats.customer_number
  , mtl_stats.customer_location
  , mtl_stats.transacting_from_org
  , mtl_stats.transacting_to_org
  , mtl_stats.vendor_name
  , mtl_stats.vendor_number
  , mtl_stats.vendor_site
  , mtl_stats.bill_to_name
  , mtl_stats.bill_to_number
  , mtl_stats.bill_to_site
  , mtl_stats.po_header_id
  , mtl_stats.po_line_id
  , mtl_stats.po_line_location_id
  , mtl_stats.order_header_id
  , mtl_stats.order_line_id
  , mtl_stats.picking_line_id
  , mtl_stats.shipment_header_id
  , mtl_stats.shipment_line_id
  , mtl_stats.ship_to_customer_id
  , mtl_stats.ship_to_site_use_id
  , mtl_stats.bill_to_customer_id
  , mtl_stats.bill_to_site_use_id
  , mtl_stats.vendor_id
  , mtl_stats.vendor_site_id
  , mtl_stats.from_organization_id
  , mtl_stats.to_organization_id
  , mtl_stats.parent_movement_id
  , mtl_stats.inventory_item_id
  , mtl_stats.item_description
  , mtl_stats.item_cost
  , mtl_stats.transaction_quantity
  , mtl_stats.transaction_uom_code
  , mtl_stats.primary_quantity
  , mtl_stats.invoice_batch_id
  , mtl_stats.invoice_id
  , mtl_stats.customer_trx_line_id
  , mtl_stats.invoice_batch_reference
  , mtl_stats.invoice_reference
  , mtl_stats.invoice_line_reference
  , mtl_stats.invoice_date_reference
  , mtl_stats.invoice_quantity
  , mtl_stats.invoice_unit_price
  , mtl_stats.invoice_line_ext_value
  , mtl_stats.outside_code
  , mtl_stats.outside_ext_value
  , mtl_stats.outside_unit_price
  , mtl_stats.currency_code
  , mtl_stats.currency_conversion_rate
  , mtl_stats.currency_conversion_type
  , mtl_stats.currency_conversion_date
  , mtl_stats.period_name
  , mtl_stats.report_reference
  , mtl_stats.report_date
  , mtl_stats.category_id
  , mtl_stats.weight_method
  , mtl_stats.unit_weight
  , mtl_stats.total_weight
  , mtl_stats.transaction_nature
  , mtl_stats.delivery_terms
  , mtl_stats.transport_mode
  , mtl_stats.alternate_quantity
  , mtl_stats.alternate_uom_code
  , mtl_stats.dispatch_territory_code
  , mtl_stats.destination_territory_code
  , mtl_stats.origin_territory_code
  , mtl_stats.stat_method
  , mtl_stats.stat_adj_percent
  , mtl_stats.stat_adj_amount
  , mtl_stats.stat_ext_value
  , mtl_stats.area
  , mtl_stats.port
  , mtl_stats.stat_type
  , mtl_stats.comments
  , mtl_stats.attribute_category
  , mtl_stats.commodity_code
  , mtl_stats.commodity_description
  , mtl_stats.requisition_header_id
  , mtl_stats.requisition_line_id
  , mtl_stats.picking_line_detail_id
  , mtl_stats.usage_type
  , mtl_stats.zone_code
  , mtl_stats.edi_sent_flag
  , mtl_stats.statistical_procedure_code
  , mtl_stats.movement_amount
  , mtl_stats.triangulation_country_code
  , mtl_stats.csa_code
  , mtl_stats.oil_reference_code
  , mtl_stats.container_type_code
  , mtl_stats.flow_indicator_code
  , mtl_stats.affiliation_reference_code
  , mtl_stats.origin_territory_eu_code
  , mtl_stats.destination_territory_eu_code
  , mtl_stats.dispatch_territory_eu_code
  , mtl_stats.set_of_books_period
  , mtl_stats.taric_code
  , mtl_stats.preference_code
  , mtl_stats.rcv_transaction_id
  , mtl_stats.mtl_transaction_id
  , mtl_stats.total_weight_uom_code
  , mtl_stats.financial_document_flag
  , mtl_stats.customer_vat_number
  , mtl_stats.attribute1
  , mtl_stats.attribute2
  , mtl_stats.attribute3
  , mtl_stats.attribute4
  , mtl_stats.attribute5
  , mtl_stats.attribute6
  , mtl_stats.attribute7
  , mtl_stats.attribute8
  , mtl_stats.attribute9
  , mtl_stats.attribute10
  , mtl_stats.attribute11
  , mtl_stats.attribute12
  , mtl_stats.attribute13
  , mtl_stats.attribute14
  , mtl_stats.attribute15
  , mtl_stats.triangulation_country_eu_code
  , mtl_stats.distribution_line_number
  , mtl_stats.ship_to_name
  , mtl_stats.ship_to_number
  , mtl_stats.ship_to_site
  , mtl_stats.edi_transaction_date
  , mtl_stats.edi_transaction_reference
  , mtl_stats.esl_drop_shipment_code
FROM
  MTL_MOVEMENT_STATISTICS mtl_stats
WHERE entity_org_id           = p_legal_entity_id
  AND period_name  = p_period_name
  AND document_source_type    = nvl(p_document_source_type, document_source_type)
  AND zone_code               = p_economic_zone_code
  AND usage_type              = p_usage_type
  AND stat_type               = p_stat_type
  AND (movement_status = 'O' OR (financial_document_flag = 'MISSING'))
ORDER BY
  mtl_stats.movement_id;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_api_name || '.end'
                  ,'exit procedure'
                  );
  END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
	x_return_status := 'N';
    WHEN OTHERS THEN
        x_return_status := 'N';

END Get_Open_Mvmt_Stats_Txns;


--========================================================================
-- PROCEDURE : Update_Movement_Statistics   PRIVATE
--
-- PARAMETERS: x_return_status      Procedure return status
--             x_msg_count          Number of messages in the list
--             x_msg_data           Message text
--             P_MOVEMENT_STATISTICS    Material Movement Statistics transaction
--                                  Input data record
--
-- COMMENT   : Procedure body to Update the Movement
--             Statistics record with the
--             calculated values ( EX: Invoice information, Status etc ).
-- Updated   : 09/Jul/1999
--=======================================================================--
PROCEDURE Update_Movement_Statistics (
  p_movement_statistics  IN
  INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
, x_return_status                OUT NOCOPY    VARCHAR2
, x_msg_count                    OUT NOCOPY    NUMBER
, x_msg_data                     OUT NOCOPY    VARCHAR2
)
IS
l_api_name CONSTANT VARCHAR2(30) := 'Update_Movement_Statistics';
l_api_version_number    CONSTANT NUMBER := 1.0;
l_movement_transaction  INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type;
l_return_status1        VARCHAR2(1);
l_return_status2        VARCHAR2(1);
BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_api_name || '.begin'
                  ,'enter procedure'
                  );
  END IF;
  l_movement_transaction  := p_movement_statistics;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
/*bug #7499719 Call Out Program was not called for Update Movement Statistic*/
IF l_movement_transaction.movement_status IN ('O','V','P')
  THEN
    INV_MGD_MVT_DEF_ATTR.Default_Attr
    ( p_api_version_number   => 1.0
    , p_init_msg_list        => FND_API.G_FALSE
    , p_movement_transaction => l_movement_transaction
    , x_transaction_nature   => l_movement_transaction.transaction_nature
    , x_delivery_terms       => l_movement_transaction.delivery_terms
    , x_area                 => l_movement_transaction.area
    , x_port                 => l_movement_transaction.port
    , x_csa_code             => l_movement_transaction.csa_code
    , x_oil_reference_code   => l_movement_transaction.oil_reference_code
    , x_container_type_code  => l_movement_transaction.container_type_code
    , x_flow_indicator_code  => l_movement_transaction.flow_indicator_code
    , x_affiliation_reference_code =>
         l_movement_transaction.affiliation_reference_code
    , x_taric_code           => l_movement_transaction.taric_code
    , x_preference_code      => l_movement_transaction.preference_code
    , x_statistical_procedure_code =>
                        l_movement_transaction.statistical_procedure_code
    , x_transport_mode       => l_movement_transaction.transport_mode
    , x_msg_count            => x_msg_count
    , x_msg_data             => x_msg_data
    , x_return_status        => l_return_status1
    );

    INV_MGD_MVT_DEF_ATTR.Default_Value
    ( p_api_version_number      => 1.0
    , p_init_msg_list           => FND_API.G_FALSE
    , p_movement_transaction    => l_movement_transaction
    , x_document_unit_price     => l_movement_transaction.document_unit_price
    , x_document_line_ext_value => l_movement_transaction.document_line_ext_value
    , x_movement_amount         => l_movement_transaction.movement_amount
    , x_stat_ext_value          => l_movement_transaction.stat_ext_value
    , x_msg_count               => x_msg_count
    , x_msg_data                => x_msg_data
    , x_return_status           => l_return_status2
    );
    IF l_return_status1 <> 'S'
    THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
        FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                      , G_MODULE_NAME || l_api_name
                      , 'Failed in calling default_attr '||substrb(x_msg_data,1,255)
                      );
      END IF;
    END IF;

    IF l_return_status2 <> 'S'
    THEN
      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
        FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                      , G_MODULE_NAME || l_api_name
                      , 'Failed in calling default_Value '||substrb(x_msg_data,1,255)
                      );
      END IF;
    END IF;
  END IF;
/*bug #7499719 End*/

  UPDATE MTL_MOVEMENT_STATISTICS
  SET movement_id                = P_MOVEMENT_STATISTICS.movement_id
    , organization_id            = P_MOVEMENT_STATISTICS.organization_id
    , entity_org_id              = P_MOVEMENT_STATISTICS.entity_org_id
    , movement_type              = P_MOVEMENT_STATISTICS.movement_type
    , movement_status            = P_MOVEMENT_STATISTICS.movement_status
    , transaction_date           = P_MOVEMENT_STATISTICS.transaction_date
    , last_update_date           = SYSDATE
    , last_updated_by            = NVL
                                   ( TO_NUMBER(FND_PROFILE.Value('USER_ID'))
                                   , last_updated_by
                                   )
    , last_update_login          = NVL
                                   ( TO_NUMBER(FND_PROFILE.Value('LOGIN_ID'))
                                   , last_update_login
                                   )
    , document_source_type       = P_MOVEMENT_STATISTICS.document_source_type
    , creation_method            = P_MOVEMENT_STATISTICS.creation_method
    , document_reference         = P_MOVEMENT_STATISTICS.document_reference
    , document_line_reference    =
	 P_MOVEMENT_STATISTICS.document_line_reference
    , document_unit_price        = l_movement_transaction.document_unit_price
    , document_line_ext_value    =
	 P_MOVEMENT_STATISTICS.document_line_ext_value
    , receipt_reference          = P_MOVEMENT_STATISTICS.receipt_reference
    , shipment_reference         = P_MOVEMENT_STATISTICS.shipment_reference
    , shipment_line_reference    =
	 P_MOVEMENT_STATISTICS.shipment_line_reference
    , pick_slip_reference        = P_MOVEMENT_STATISTICS.pick_slip_reference
    , customer_name              = P_MOVEMENT_STATISTICS.customer_name
    , customer_number            = P_MOVEMENT_STATISTICS.customer_number
    , customer_location          = P_MOVEMENT_STATISTICS.customer_location
    , transacting_from_org       = P_MOVEMENT_STATISTICS.transacting_from_org
    , transacting_to_org         = P_MOVEMENT_STATISTICS.transacting_to_org
    , vendor_name                = P_MOVEMENT_STATISTICS.vendor_name
    , vendor_number              = P_MOVEMENT_STATISTICS.vendor_number
    , vendor_site                = P_MOVEMENT_STATISTICS.vendor_site
    , bill_to_name               = P_MOVEMENT_STATISTICS.bill_to_name
    , bill_to_number             = P_MOVEMENT_STATISTICS.bill_to_number
    , bill_to_site               = P_MOVEMENT_STATISTICS.bill_to_site
    , ship_to_name               = P_MOVEMENT_STATISTICS.ship_to_name
    , ship_to_number             = P_MOVEMENT_STATISTICS.ship_to_number
    , ship_to_site               = P_MOVEMENT_STATISTICS.ship_to_site
    , po_header_id               = P_MOVEMENT_STATISTICS.po_header_id
    , po_line_id                 = P_MOVEMENT_STATISTICS.po_line_id
    , po_line_location_id        = P_MOVEMENT_STATISTICS.po_line_location_id
    , order_header_id            = P_MOVEMENT_STATISTICS.order_header_id
    , order_line_id              = P_MOVEMENT_STATISTICS.order_line_id
    , picking_line_id            = P_MOVEMENT_STATISTICS.picking_line_id
    , shipment_header_id         = P_MOVEMENT_STATISTICS.shipment_header_id
    , shipment_line_id           = P_MOVEMENT_STATISTICS.shipment_line_id
    , ship_to_customer_id        = P_MOVEMENT_STATISTICS.ship_to_customer_id
    , ship_to_site_use_id        = P_MOVEMENT_STATISTICS.ship_to_site_use_id
    , bill_to_customer_id        = P_MOVEMENT_STATISTICS.bill_to_customer_id
    , bill_to_site_use_id        = P_MOVEMENT_STATISTICS.bill_to_site_use_id
    , vendor_id                  = P_MOVEMENT_STATISTICS.vendor_id
    , vendor_site_id             = P_MOVEMENT_STATISTICS.vendor_site_id
    , from_organization_id       = P_MOVEMENT_STATISTICS.from_organization_id
    , to_organization_id         = P_MOVEMENT_STATISTICS.to_organization_id
    , parent_movement_id         = P_MOVEMENT_STATISTICS.parent_movement_id
    , inventory_item_id          = P_MOVEMENT_STATISTICS.inventory_item_id
    , item_description           = P_MOVEMENT_STATISTICS.item_description
    , item_cost                  = P_MOVEMENT_STATISTICS.item_cost
    , transaction_quantity       = P_MOVEMENT_STATISTICS.transaction_quantity
    , transaction_uom_code       = P_MOVEMENT_STATISTICS.transaction_uom_code
    , primary_quantity           = P_MOVEMENT_STATISTICS.primary_quantity
    , invoice_batch_id           = P_MOVEMENT_STATISTICS.invoice_batch_id
    , invoice_id                 = P_MOVEMENT_STATISTICS.invoice_id
    , customer_trx_line_id       = P_MOVEMENT_STATISTICS.customer_trx_line_id
    , invoice_batch_reference    = P_MOVEMENT_STATISTICS.invoice_batch_reference
    , invoice_reference          = P_MOVEMENT_STATISTICS.invoice_reference
    , invoice_line_reference     = P_MOVEMENT_STATISTICS.invoice_line_reference
    , invoice_date_reference     = P_MOVEMENT_STATISTICS.invoice_date_reference
    , invoice_quantity           = P_MOVEMENT_STATISTICS.invoice_quantity
    , invoice_unit_price         = P_MOVEMENT_STATISTICS.invoice_unit_price
    , invoice_line_ext_value     = P_MOVEMENT_STATISTICS.invoice_line_ext_value
    , outside_code               = P_MOVEMENT_STATISTICS.outside_code
    , outside_ext_value          = P_MOVEMENT_STATISTICS.outside_ext_value
    , outside_unit_price         = P_MOVEMENT_STATISTICS.outside_unit_price
    , currency_code              = P_MOVEMENT_STATISTICS.currency_code
    , currency_conversion_rate   = P_MOVEMENT_STATISTICS.currency_conversion_rate
    , currency_conversion_type   = P_MOVEMENT_STATISTICS.currency_conversion_type
    , currency_conversion_date   = P_MOVEMENT_STATISTICS.currency_conversion_date
    , period_name                = P_MOVEMENT_STATISTICS.period_name
    , report_reference           = P_MOVEMENT_STATISTICS.report_reference
    , report_date                = P_MOVEMENT_STATISTICS.report_date
    , category_id                = P_MOVEMENT_STATISTICS.category_id
    , weight_method              = P_MOVEMENT_STATISTICS.weight_method
    , unit_weight                = P_MOVEMENT_STATISTICS.unit_weight
    , total_weight               = P_MOVEMENT_STATISTICS.total_weight
    , transaction_nature         = l_movement_transaction.transaction_nature
    , delivery_terms             = l_movement_transaction.delivery_terms
    , transport_mode             = l_movement_transaction.transport_mode
    , alternate_quantity         = P_MOVEMENT_STATISTICS.alternate_quantity
    , alternate_uom_code         = P_MOVEMENT_STATISTICS.alternate_uom_code
    , dispatch_territory_code    = P_MOVEMENT_STATISTICS.dispatch_territory_code
    , destination_territory_code =
                             P_MOVEMENT_STATISTICS.destination_territory_code
    , origin_territory_code      = P_MOVEMENT_STATISTICS.origin_territory_code
    , dispatch_territory_eu_code =
                             P_MOVEMENT_STATISTICS.dispatch_territory_eu_code
    , destination_territory_eu_code =
                             P_MOVEMENT_STATISTICS.destination_territory_eu_code
    , origin_territory_eu_code   =
                               P_MOVEMENT_STATISTICS.origin_territory_eu_code
    , stat_method                = P_MOVEMENT_STATISTICS.stat_method
    , stat_adj_percent           = P_MOVEMENT_STATISTICS.stat_adj_percent
    , stat_adj_amount            = P_MOVEMENT_STATISTICS.stat_adj_amount
    , stat_ext_value             = l_movement_transaction.stat_ext_value
    , area                       = l_movement_transaction.area
    , port                       = l_movement_transaction.port
    , stat_type                  = P_MOVEMENT_STATISTICS.stat_type
    , commodity_code             = P_MOVEMENT_STATISTICS.commodity_code
    , commodity_description      = P_MOVEMENT_STATISTICS.commodity_description
    , requisition_header_id      = P_MOVEMENT_STATISTICS.requisition_header_id
    , requisition_line_id        = P_MOVEMENT_STATISTICS.requisition_line_id
    , picking_line_detail_id     = P_MOVEMENT_STATISTICS.picking_line_detail_id
    , statistical_procedure_code = l_movement_transaction.statistical_procedure_code
    , comments	                 = P_MOVEMENT_STATISTICS.comments
    , attribute_category	 = P_MOVEMENT_STATISTICS.attribute_category
    , attribute1	         = P_MOVEMENT_STATISTICS.attribute1
    , attribute2	         = P_MOVEMENT_STATISTICS.attribute2
    , attribute3	         = P_MOVEMENT_STATISTICS.attribute3
    , attribute4	         = P_MOVEMENT_STATISTICS.attribute4
    , attribute5	         = P_MOVEMENT_STATISTICS.attribute5
    , attribute6	         = P_MOVEMENT_STATISTICS.attribute6
    , attribute7	         = P_MOVEMENT_STATISTICS.attribute7
    , attribute8	         = P_MOVEMENT_STATISTICS.attribute8
    , attribute9	         = P_MOVEMENT_STATISTICS.attribute9
    , attribute10	         = P_MOVEMENT_STATISTICS.attribute10
    , attribute11	         = P_MOVEMENT_STATISTICS.attribute11
    , attribute12	         = P_MOVEMENT_STATISTICS.attribute12
    , attribute13	         = P_MOVEMENT_STATISTICS.attribute13
    , attribute14	         = P_MOVEMENT_STATISTICS.attribute14
    , attribute15	         = P_MOVEMENT_STATISTICS.attribute15
    , usage_type	         = P_MOVEMENT_STATISTICS.usage_type
    , zone_code	                 = P_MOVEMENT_STATISTICS.zone_code
    , edi_sent_flag	         = P_MOVEMENT_STATISTICS.edi_sent_flag
    , movement_amount	         = l_movement_transaction.movement_amount
    , triangulation_country_code =
                       P_MOVEMENT_STATISTICS.triangulation_country_code
    , triangulation_country_eu_code =
                       P_MOVEMENT_STATISTICS.triangulation_country_eu_code
    , distribution_line_number   =
                       P_MOVEMENT_STATISTICS.distribution_line_number
    , csa_code	                 = l_movement_transaction.csa_code
    , oil_reference_code         = l_movement_transaction.oil_reference_code
    , container_type_code        = l_movement_transaction.container_type_code
    , flow_indicator_code        = l_movement_transaction.flow_indicator_code
    , affiliation_reference_code = l_movement_transaction.affiliation_reference_code
    , financial_document_flag    = P_MOVEMENT_STATISTICS.financial_document_flag
    , set_of_books_period        = P_MOVEMENT_STATISTICS.set_of_books_period
    , edi_transaction_date       = P_MOVEMENT_STATISTICS.edi_transaction_date
    , edi_transaction_reference  =
                              P_MOVEMENT_STATISTICS.edi_transaction_reference
    , taric_code                 = l_movement_transaction.taric_code
    , preference_code            = l_movement_transaction.preference_code
    , rcv_transaction_id         = P_MOVEMENT_STATISTICS.rcv_transaction_id
    , mtl_transaction_id         = P_MOVEMENT_STATISTICS.mtl_transaction_id
    , total_weight_uom_code      = P_MOVEMENT_STATISTICS.total_weight_uom_code
    , esl_drop_shipment_code     = P_MOVEMENT_STATISTICS.esl_drop_shipment_code
    , customer_vat_number        = P_MOVEMENT_STATISTICS.customer_vat_number
    WHERE movement_id            = P_MOVEMENT_STATISTICS.movement_id;

    COMMIT ;
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_api_name || '.end'
                  ,'exit procedure'
                  );
  END IF;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    --  Get message count and data
    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count
    , p_data  => x_msg_data
    );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    --  Get message count and data
    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count
    , p_data  => x_msg_data
    );

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg
      ( G_PKG_NAME
      , 'INV_MGD_MVT_VALIDATE_TXN'
      );
    END IF;
    --  Get message count and data
    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count
    , p_data  => x_msg_data
    );

END Update_Movement_Statistics ;

--==================
--LOCAL PROCEDURES
--==================


--========================================================================
-- PROCEDURE : Validate_Record            PRIVATE
-- PARAMETERS: p_movement_statistics      IN  movement transaction record
--             p_movement_stat_usages_rec IN usage record
--             x_movement_statistics      OUT movement transaction record
--             x_return_status            OUT standard output
--             x_record_status            OUT 'Y' if corrected, 'N' otherwise
--
-- VERSION   : current version            1.0
--             initial_version            1.0
-- COMMENT   : Validate the transaction record for its DELIVERY_TERMS,
--             UNIT_WEIGHT/TOTAL_WEIGHT and COMMODITY_CODE.
--=======================================================================
PROCEDURE Validate_Record
( p_movement_stat_usages_rec IN
     INV_MGD_MVT_DATA_STR.Movement_Stat_Usages_Rec_Type
, x_movement_statistics      IN OUT NOCOPY
     INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
, x_return_status            OUT NOCOPY VARCHAR2
, x_record_status            OUT NOCOPY VARCHAR2
, x_updated_flag             OUT NOCOPY VARCHAR2
);

--========================================================================
-- PROCEDURE : Create_Table_Data       PRIVATE
-- PARAMETERS: p_col_name
--             p_message_cd
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : Create the Exception message into the Pl/SQL table. This table
--              will be scanned while printing the Exception
--=========================================================================
  PROCEDURE Create_Table_Data( p_col_name   IN VARCHAR2
                             , p_message_cd IN NUMBER );

--=================
--PROCEDURE BODY
--=================


 --=========================================================================

-- PROCEDURE : Validate_Movement_Statistics  PRIVATE
--
-- PARAMETERS:
--             p_movement_statistics     Material Movement Statistics transaction
--                                       Input data record
--             p_movement_stat_usages_rec usage record
--             x_excp_list               PL/SQL Table type list for storing
--                                       and returning the Exception messages
--             x_return_status           Procedure return status
--             x_msg_count               Number of messages in the list
--             x_msg_data                Message text
--             x_movement_statistics     Material Movement Statistics transaction
--                                       Output data record
--
-- VERSION   : current version           1.0
--             initial version           1.0
--
-- COMMENT   :  Procedure specification to Perform the
--              Validation for the Movement
--             Statistics Record FOR Exceptions
--
-- CREATED  : 10/20/1999
--=============================================================================-
PROCEDURE Validate_Movement_Statistics
 ( p_movement_statistics     IN
     INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
 , p_movement_stat_usages_rec IN
     INV_MGD_MVT_DATA_STR.Movement_Stat_Usages_Rec_Type
 , x_excp_list                OUT NOCOPY
     INV_MGD_MVT_DATA_STR.excp_list
 , x_updated_flag             OUT NOCOPY VARCHAR2
 , x_return_status            OUT NOCOPY VARCHAR2
 , x_msg_count                OUT NOCOPY NUMBER
 , x_msg_data                 OUT NOCOPY VARCHAR2
 , x_movement_statistics      OUT NOCOPY
     INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
 )
IS
l_api_name           CONSTANT VARCHAR2(30) := 'VALIDATE_MOVEMENT_STATISTICS';

-- local variables
l_orig_mvmt_transaction
  INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type;
l_invoice_arrived VARCHAR2(1);
-- removed the use of empty list to reset the list, use DELETE instead
-- l_excp_list_empty INV_MGD_MVT_DATA_STR.excp_list;
l_before_validate
  INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type;
l_new_movement_transaction
  INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type;
--l_created_movement_transaction
 -- INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type;
l_transaction_type VARCHAR2(30);
l_record_status VARCHAR2(1);
l_uom_status    VARCHAR2(1);
l_return_status VARCHAR2(1);
l_updated_flag  VARCHAR2(1);
l_corrected VARCHAR2(1);
validate_rule_flag VARCHAR2(1);

BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_api_name || '.begin'
                  ,'enter procedure'
                  );
  END IF;

  --Initiliaze the Message Stack IF Required
  --IF FND_API.to_Boolean(p_init_msg_list)
  --THEN
    FND_MSG_PUB.initialize;
  --END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  validate_rule_flag := 'Y';

  FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                           , p_data => x_msg_data );

  -- intialize local variables
  l_orig_mvmt_transaction := p_movement_statistics;
  l_corrected := 'Y';
  x_updated_flag :='N';

  --yawang fix bug 2261790, duplicate error messages for same mvt id
  --Clear global exception list
  g_final_excp_list.delete;

  --yawang fix invoice info not picked up even though the invoice is in
  --Get order number for SO, used in call Calc_Invoice_Info
  IF (l_orig_mvmt_transaction.invoice_id IS NULL
     AND l_orig_mvmt_transaction.order_header_id IS NOT NULL)
  THEN
    SELECT
      order_number
    INTO
      l_orig_mvmt_transaction.order_number
    FROM
      oe_order_headers_all
    WHERE header_id = l_orig_mvmt_transaction.order_header_id;
  END IF;

  -- check scenario 1 : movement_status is FROZEN, EXPORT or EDI is sent
  -- modified by yawang, added EXPORT for IDEP support
  IF l_orig_mvmt_transaction.movement_status IN ('F', 'X')
     OR
     l_orig_mvmt_transaction.edi_sent_flag = 'Y'
  THEN
    IF l_orig_mvmt_transaction.financial_document_flag = 'MISSING'
    THEN
      -- get invoice information
      INV_MGD_MVT_FIN_MDTR.Calc_Invoice_Info
      ( p_stat_typ_transaction => p_movement_stat_usages_rec
      , x_movement_transaction => l_orig_mvmt_transaction
      );
      -- if we have an invoice_id that means we found the invoice
      IF l_orig_mvmt_transaction.invoice_id IS NOT NULL
      THEN
        IF l_orig_mvmt_transaction.document_source_type IN ('PO','RTV')
        THEN
          l_transaction_type := 'RECEIPT';
        ELSIF l_orig_mvmt_transaction.document_source_type = 'SO'
        THEN
          l_transaction_type := 'SHIPMENT';
        END IF;
        l_new_movement_transaction := l_orig_mvmt_transaction;
        -- see state diagram for reason of setting status to V and edi to Y
        l_new_movement_transaction.movement_status := 'V';
        l_new_movement_transaction.edi_sent_flag := 'N';

	-- record updated
	x_updated_flag :='Y';

        -- we make it an adjustment if the new record is within a different
        -- period from the original transaction period
        IF l_orig_mvmt_transaction.movement_status IN ('F', 'X')
           OR l_orig_mvmt_transaction.edi_sent_flag = 'Y'
        THEN
          IF l_new_movement_transaction.movement_type = 'A'
          THEN
            l_new_movement_transaction.movement_type := 'AA';
          ELSIF  l_new_movement_transaction.movement_type = 'D'
          THEN
            l_new_movement_transaction.movement_type := 'DA';
          END IF;
        END IF;

        l_new_movement_transaction.financial_document_flag := 'PROCESSED_ADJUSTED';
        l_new_movement_transaction.report_reference := NULL;
        l_new_movement_transaction.report_date := NULL;
        l_new_movement_transaction.edi_transaction_reference := NULL;
        l_new_movement_transaction.edi_transaction_date := NULL;

        l_new_movement_transaction.movement_amount :=
        INV_MGD_MVT_FIN_MDTR.Calc_Movement_Amount
        (p_movement_transaction  => l_new_movement_transaction
         );

        --Calculate freight charge and include in statistics value
        l_new_movement_transaction.stat_ext_value :=
        INV_MGD_MVT_FIN_MDTR.Calc_Statistics_Value
        (p_movement_transaction => l_new_movement_transaction);

        INV_MGD_MVT_STATS_PVT.Create_Movement_Statistics
        ( p_api_version_number   => 1.0
        , p_init_msg_list        => FND_API.G_FALSE
        , x_movement_transaction => l_new_movement_transaction
        , x_msg_count            => x_msg_count
        , x_msg_data             => x_msg_data
        , x_return_status        => x_return_status
        );

        --set original record still no invoice info so that not confusing with
        --newly creatd adjusted record
        l_orig_mvmt_transaction.invoice_batch_id         := null;
        l_orig_mvmt_transaction.invoice_date_reference   := null;
        l_orig_mvmt_transaction.invoice_id               := null;
        l_orig_mvmt_transaction.invoice_quantity         := null;
        l_orig_mvmt_transaction.invoice_unit_price       := null;
        l_orig_mvmt_transaction.invoice_line_ext_value   := null;
        l_orig_mvmt_transaction.customer_trx_line_id     := null;

        --Set the orignal financial flag to not missing so that not picked up again
        --when run exception report
        l_orig_mvmt_transaction.financial_document_flag := 'CREATEDADJ';
      END IF;
    END IF;

  -- check scenario 2 : movement_status is VERIFIED
  ELSIF l_orig_mvmt_transaction.movement_status = 'V'
  THEN
    IF l_orig_mvmt_transaction.financial_document_flag = 'MISSING'
    THEN
      -- get invoice information
      INV_MGD_MVT_FIN_MDTR.Calc_Invoice_Info
      ( p_stat_typ_transaction => p_movement_stat_usages_rec
      , x_movement_transaction => l_orig_mvmt_transaction
      );
      -- if we have an invoice_id that means we found the invoice
      IF l_orig_mvmt_transaction.invoice_id IS NOT NULL
      THEN
        -- see state diagram for reason of setting status to V
        -- and financial_document_flag to PROCESSED_INCLUDED
        l_orig_mvmt_transaction.movement_status:='V';
        l_orig_mvmt_transaction.financial_document_flag:='PROCESSED_INCLUDED';
	-- record updated
	x_updated_flag :='Y';

        l_orig_mvmt_transaction.movement_amount :=
        INV_MGD_MVT_FIN_MDTR.Calc_Movement_Amount
        (p_movement_transaction  => l_orig_mvmt_transaction
        );

        --Calculate freight charge and include in statistics value
        l_orig_mvmt_transaction.stat_ext_value :=
        INV_MGD_MVT_FIN_MDTR.Calc_Statistics_Value
        (p_movement_transaction => l_orig_mvmt_transaction);
      ELSE
        -- see state diagram for reason of setting status to V
        -- and financial_document_flag to MISSING
        l_orig_mvmt_transaction.movement_status:='V';
        l_orig_mvmt_transaction.financial_document_flag:='MISSING';

	-- record updated
	x_updated_flag :='Y';

        -- report exception for MISSING invoice
        IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
        THEN
          FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                        , G_MODULE_NAME || l_api_name
                        ,'Exception: invoice missing'
                        );
        END IF;

        create_table_data( p_col_name   => 'INVOICE_ID'
                         , p_message_cd => 1
                         );
      END IF;
    END IF;

  -- check scenario 3 : movement_stauts is OPEN
  ELSIF l_orig_mvmt_transaction.movement_status = 'O'
  THEN
    -- Call validate rules to validate record per rule sets definitions
        Validate_Rules
        ( p_movement_stat_usages_rec => p_movement_stat_usages_rec
        , x_movement_transaction     => l_orig_mvmt_transaction
        , x_return_status            => x_return_status
        , x_uom_status               => l_uom_status
        , x_msg_count                => x_msg_count
        , x_msg_data                 => x_msg_data
        );

      IF x_return_status = FND_API.G_RET_STS_SUCCESS
      THEN
        validate_rule_flag := 'Y';
      ELSE
        validate_rule_flag := 'N';
      END IF;

      -- Check to see if alternate Uom has been updated
      IF l_uom_status = 'Y'
      THEN
        x_updated_flag := 'Y';
      END IF;


    l_before_validate := l_orig_mvmt_transaction;
    Validate_Record
    ( p_movement_stat_usages_rec => p_movement_stat_usages_rec
    , x_movement_statistics      => l_orig_mvmt_transaction
    , x_return_status            => l_return_status
    , x_record_status            => l_record_status
    , x_updated_flag             => l_updated_flag
    );

    x_updated_flag := l_updated_flag;

    IF l_return_status=FND_API.G_RET_STS_ERROR
       AND l_record_status='N'
    THEN
      -- nothing corrected although we found error
      -- the API will return FND_API.G_RET_STS_ERROR
      l_corrected := 'N';
    ELSE
      -- see state diagram for reason of setting status to V
      -- Added check for rule based validation if Y only then set status to V
      IF validate_rule_flag = 'Y' THEN
         l_orig_mvmt_transaction.movement_status:='V';
      END IF;
    END IF;
    IF l_orig_mvmt_transaction.financial_document_flag = 'MISSING'
    THEN
      -- get invoice information
      INV_MGD_MVT_FIN_MDTR.Calc_Invoice_Info
      ( p_stat_typ_transaction => p_movement_stat_usages_rec
      , x_movement_transaction => l_orig_mvmt_transaction
      );
      -- if we have an invoice_id that means we found the invoice
      IF l_orig_mvmt_transaction.invoice_id IS NOT NULL
      THEN
        -- see state diagram for reason of setting status to V
        -- and financial document flag to PROCESSED_INCLUDED
        -- l_orig_mvmt_transaction.movement_status:='V';
	-- commented above line to add check for rule based validation
	-- Set status to V only if the record is validated
        IF validate_rule_flag = 'Y' THEN
          l_orig_mvmt_transaction.movement_status:='V';
        END IF;
        l_orig_mvmt_transaction.financial_document_flag:='PROCESSED_INCLUDED';
	-- record updated
	x_updated_flag :='Y';

        l_orig_mvmt_transaction.movement_amount :=
        INV_MGD_MVT_FIN_MDTR.Calc_Movement_Amount
        (p_movement_transaction  => l_orig_mvmt_transaction
        );

        --Calculate freight charge and include in statistics value
        l_orig_mvmt_transaction.stat_ext_value :=
        INV_MGD_MVT_FIN_MDTR.Calc_Statistics_Value
        (p_movement_transaction => l_orig_mvmt_transaction);
      ELSE
        -- see state diagram for reason of setting status to V
	-- Set status to V only if the record is validated
        IF validate_rule_flag = 'Y' THEN
          l_orig_mvmt_transaction.movement_status:='V';
        END IF;
        --l_orig_mvmt_transaction.movement_status:='V';
        l_orig_mvmt_transaction.financial_document_flag:='MISSING';
	-- record updated
	x_updated_flag :='Y';
        -- report exception for MISSING invoice
        create_table_data( p_col_name   => 'INVOICE_ID'
                         , p_message_cd => 1
                         );
      END IF;

    -- we are checking 'PROCESS_INCLUDED' just because of previous typo in
    -- the code
    ELSIF l_orig_mvmt_transaction.financial_document_flag in ('PROCESS_INCLUDED','PROCESSED_INCLUDED')
    THEN
      -- get invoice information
/*
      INV_MGD_MVT_FIN_MDTR.Calc_Invoice_Info
      ( p_movement_transaction => l_orig_mvmt_transaction
      , p_stat_typ_transaction => p_movement_stat_usages_rec
      , x_movement_transaction => l_orig_mvmt_transaction
      );
*/
      -- if we have an invoice_id that means we found the invoice
      IF l_orig_mvmt_transaction.invoice_id IS NOT NULL
      THEN
        -- see state diagram for reason of setting status to V
	-- Set status to V only if the record is validated
        IF validate_rule_flag = 'Y' THEN
          l_orig_mvmt_transaction.movement_status:='V';
        END IF;
        --l_orig_mvmt_transaction.movement_status:='V';
      ELSE
        -- the invoice is not found, raise unexpected error exception
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;
  END IF;

  -- ssui
  -- check if conversion rate is 0, if so, report missing value
  -- call get invoice info to obtain conversion rate information
  -- (the magic of get invoice info is it update exchange rate information
  --  whether or not the invoice is available)
  IF l_orig_mvmt_transaction.currency_conversion_rate = 0
  THEN
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                    , G_MODULE_NAME || l_api_name
                    ,'Exception: currency_conversion_rate missing'
                  );
    END IF;

    create_table_data( p_col_name   => 'CURRENCY_CONVERSION_RATE'
                     , p_message_cd => 1
                     );

    INV_MGD_MVT_FIN_MDTR.Calc_Invoice_Info
    ( p_stat_typ_transaction => p_movement_stat_usages_rec
    , x_movement_transaction => l_orig_mvmt_transaction
    );

	  -- END IF;  ksaini commented out for conversion rate not modified
	  -- Move conversion rate settting check within this segment

	  -- check to see if the conversion rate is still 0, if so, mark
	  -- as exception not corrected, else, report corrected and
	  -- also recalculate movement_amount
	  IF l_orig_mvmt_transaction.currency_conversion_rate = 0
	  THEN
	    l_corrected := 'N';
	  ELSE
	    create_table_data(p_col_name   => 'CURRENCY_CONVERSION_RATE'
			     ,p_message_cd => 4
			     );
	    l_orig_mvmt_transaction.movement_amount :=
	      INV_MGD_MVT_FIN_MDTR.Calc_Movement_Amount
	      (p_movement_transaction => l_orig_mvmt_transaction
	      );

            --Calculate freight charge and include in statistics value
            l_orig_mvmt_transaction.stat_ext_value :=
            INV_MGD_MVT_FIN_MDTR.Calc_Statistics_Value
            (p_movement_transaction => l_orig_mvmt_transaction);
	  END IF;
  END if; --ksaini moved here to encapsulate the condition within previous IF

  -- if l_corrected='N', that means we found errors but didn't correct it
  -- so set return status to error
  IF l_corrected='N'
  THEN
    --ssui: bug 1072889, keep status as OPEN if exception but not corrected
    l_orig_mvmt_transaction.movement_status:='O';
    X_return_status:=FND_API.G_RET_STS_ERROR;
  END IF;

  -- set return exception list
  x_excp_list := g_final_excp_list;
  g_final_excp_list.DELETE;
  x_movement_statistics := l_orig_mvmt_transaction;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_api_name || '.end'
                  ,'exit procedure'
                  );
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    --  Get message count and data
    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count
    , p_data  => x_msg_data
    );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    --  Get message count and data
    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count
    , p_data  => x_msg_data
    );

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg
      ( G_PKG_NAME
      , 'Validate_Movement_Statistics'
      );
    END IF;
    --  Get message count and data
    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count
    , p_data  => x_msg_data
    );
END Validate_Movement_Statistics;

--========================================================================
-- PROCEDURE : Validate_Record            PRIVATE
-- PARAMETERS: p_movement_statistics      IN  movement transaction record
--             p_movement_stat_usages_rec IN usage record
--             x_mtl_transaction          OUT movement transaction record
--             x_return_status            OUT standard output
--             x_record_status            OUT 'Y' if corrected, 'N' otherwise
--
-- VERSION   : current version         1.0
--             initial_version          1.0
-- COMMENT   : Validate the transaction record for its DELIVERY_TERMS,
--             UNIT_WEIGHT/TOTAL_WEIGHT and COMMODITY_CODE.
--=======================================================================
PROCEDURE Validate_Record
( p_movement_stat_usages_rec IN
    INV_MGD_MVT_DATA_STR.Movement_Stat_Usages_Rec_Type
, x_movement_statistics      IN OUT NOCOPY
    INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
, x_return_status            OUT NOCOPY VARCHAR2
, x_record_status            OUT NOCOPY VARCHAR2
, x_updated_flag             OUT NOCOPY VARCHAR2
)
IS
  l_orig_mvmt_transaction
    INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type;
  l_chk NUMBER;
  l_api_name  CONSTANT VARCHAR2(30) := 'Validate_Record';
  l_weight_precision     NUMBER;
  l_total_weight         NUMBER;
  l_rounding_method      VARCHAR2(30);

BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_api_name || '.begin'
                  ,'enter procedure'
                  );
  END IF;

  -- Copy input transaction record to local record for processing
  l_orig_mvmt_transaction := x_movement_statistics;

  -- Init x_return_status and x_record_status
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- x_record_status set to Y for correct record
  -- whenever record missing or incorrect then change the status to N
  x_record_status := 'Y';
  x_updated_flag := 'N';

/*
  -- Delivery Terms Validation
  IF l_orig_mvmt_transaction.delivery_terms is NOT NULL
  THEN
    -- we only check for invalid value
    BEGIN
      SELECT
        1
      INTO
        l_chk
      FROM
        FND_LOOKUPS
      WHERE lookup_type = 'MVT_DELIVERY_TERMS'
        AND lookup_code = l_orig_mvmt_transaction.delivery_terms;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
      create_table_data( p_col_name   => 'DELIVERY_TERMS'
                       , p_message_cd => 2
                       );
       -- 'INCORRECT' value for delivery_terms, set return status to error to
       -- indicate validate found error
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- indicate incorrect record
       x_record_status := 'N';
    END;
  END IF;
*/

  -- Commodity Infomation Validation
  -- check for missing commodity_code, if missing, we call
  -- get_category_id and get_commodity_info
  -- to fix the value
  IF l_orig_mvmt_transaction.commodity_code IS NULL
  THEN

    -----if value can be corrected, correct it first
    ---- and if it can not be corrected, then report an exception

/*    create_table_data(p_col_name   => 'COMMODITY_CODE'
                     ,p_message_cd => 1
                     );

    -- 'MISSING' value, so set return status to error
    x_return_status := FND_API.G_RET_STS_ERROR;

*/

    l_orig_mvmt_transaction.category_id
      := INV_MGD_MVT_UTILS_PKG.Get_Category_Id
         ( p_movement_transaction  => l_orig_mvmt_transaction
         , p_stat_typ_transaction  => p_movement_stat_usages_rec
         );

    INV_MGD_MVT_UTILS_PKG.Get_Commodity_Info
    ( x_movement_transaction => l_orig_mvmt_transaction
    );

    IF l_orig_mvmt_transaction.commodity_code IS NOT NULL
    THEN
      create_table_data(p_col_name   => 'COMMODITY_CODE'
                       ,p_message_cd => 4
                       );
      x_updated_flag :='Y';
    ELSE
      -- record still incorrect , report as an exception
      x_record_status := 'N';

      create_table_data(p_col_name   => 'COMMODITY_CODE'
                     ,p_message_cd => 1
                     );

    -- 'MISSING' value, so set return status to error
    x_return_status := FND_API.G_RET_STS_ERROR;

    END IF;
  END IF;

  -- Unit Weight Validation
  -- check for missing unit weight
  IF l_orig_mvmt_transaction.unit_weight IS NULL
  THEN
    -----if value can be corrected, correct it first
    ---- and if it can not be corrected, then report an exception

/*    create_table_data(p_col_name   => 'UNIT_WEIGHT'
                     ,p_message_cd => 1
                     );
    -- 'MISSING' value, so set return status to error
    x_return_status := FND_API.G_RET_STS_ERROR;
*/
    l_orig_mvmt_transaction.unit_weight :=
      INV_MGD_MVT_UTILS_PKG.Calc_Unit_Weight
      ( p_inventory_item_id => l_orig_mvmt_transaction.inventory_item_id
      , p_organization_id   => l_orig_mvmt_transaction.organization_id
      , p_stat_typ_uom_code => p_movement_stat_usages_rec.weight_uom_code
      , p_tranx_uom_code    => l_orig_mvmt_transaction.transaction_uom_code
      );

    --Fix bug 4866967 and 5203245 get weight precision and rounding method
    INV_MGD_MVT_UTILS_PKG.Get_Weight_Precision
    (p_legal_entity_id      => l_orig_mvmt_transaction.entity_org_id
    , p_zone_code           => l_orig_mvmt_transaction.zone_code
    , p_usage_type          => l_orig_mvmt_transaction.usage_type
    , p_stat_type           => l_orig_mvmt_transaction.stat_type
    , x_weight_precision    => l_weight_precision
    , x_rep_rounding        => l_rounding_method);

    l_total_weight := l_orig_mvmt_transaction.unit_weight *
                      l_orig_mvmt_transaction.transaction_quantity;

    l_orig_mvmt_transaction.total_weight := INV_MGD_MVT_UTILS_PKG.Round_Number
    ( p_number          => l_total_weight
    , p_precision       => l_weight_precision
    , p_rounding_method => l_rounding_method
    );

    IF l_orig_mvmt_transaction.unit_weight IS NOT NULL
    THEN
      create_table_data(p_col_name   => 'UNIT_WEIGHT'
                       ,p_message_cd => 4
                       );
      -- set record status to 'Y' as we made a change
      x_updated_flag := 'Y';
    ELSE
      -- record still incorrect, report an exception
      x_record_status := 'N';
      create_table_data(p_col_name   => 'UNIT_WEIGHT'
                       ,p_message_cd => 1
                       );
      -- 'MISSING' value, so set return status to error
      x_return_status := FND_API.G_RET_STS_ERROR;

    END IF;
  END IF;

  x_movement_statistics := l_orig_mvmt_transaction;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_api_name || '.end'
                  ,'exit procedure'
                  );
  END IF;

EXCEPTION

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, 'Validate_Record');
    END IF;

END Validate_Record;

--========================================================================

--========================================================================
-- PROCEDURE : Set_Record_Status
-- PARAMETERS: in_out_status
--
-- COMMENT   : Set the Record Status to 'Y'
--=======================================================================



--========================================================================
-- PROCEDURE : Create_Table_Date       PRIVATE
-- PARAMETERS: p_col_name
--             p_message_cd
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : Create the Exception message into the Pl/SQL table. This table
--              will be scanned while printing the Exception
--=======================================================================--

PROCEDURE create_table_data
( p_col_name   IN VARCHAR2
, p_message_cd IN NUMBER
)
IS
  l_exception_rec INV_MGD_MVT_DATA_STR.Excp_Rec;
BEGIN

  l_exception_rec.excp_col_name   := p_col_name;
  l_exception_rec.excp_message_cd := p_message_cd;
  g_final_excp_list(g_final_excp_list.COUNT + 1) := l_exception_rec;

END create_table_data ;

--========================================================================
-- PROCEDURE : Delete_Movement_Statistics PUBLIC
-- PARAMETERS:
--             p_movement_transaction  movement transaction data record
-- VERSION   : current version         1.0
--             initial version         1.0
-- COMMENT   : Called by the Form to delete a movement record
--=======================================================================
PROCEDURE Delete_Movement_Statistics
( p_movement_transaction IN
    INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
, x_return_status        OUT NOCOPY VARCHAR2
)
IS

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  DELETE FROM MTL_MOVEMENT_STATISTICS
  WHERE movement_id = p_movement_transaction.movement_id
  AND movement_status in ('O','V')
  AND edi_sent_flag  = 'N';

EXCEPTION

  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, 'Delete_Movement_Statistics');
    END IF;

END Delete_Movement_Statistics;


--========================================================================
-- PROCEDURE : Partner_vat_number PRIVATE
-- PARAMETERS: p_movement_transaction  movement transaction data record
--             p_lookup_type
--             p_rule_field_value
--             x_return_status
-- COMMENT   : Called by the Validate_Rules procedure.
--             This procedure creates Partner VAT Number exception.
--=======================================================================
PROCEDURE Partner_vat_number
( p_mvt_transaction_rec IN
  INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
, p_lookup_type IN VARCHAR2
, p_attribute_code IN VARCHAR2
, p_rule_field_value IN VARCHAR2
, x_return_status OUT NOCOPY VARCHAR2
)
IS
l_count NUMBER;
l_count1 NUMBER;
l_form_vat_value VARCHAR2(50);
l_mvt_transaction_rec INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type;
l_api_name CONSTANT VARCHAR2(30) := 'Partner_vat_number';

BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_api_name || '.begin'
                  ,'enter procedure'
                  );
  END IF;

  ---- Initialize x_return_status
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_mvt_transaction_rec:=p_mvt_transaction_rec;

  ----check if the value matches any of the value in the lookup table
  IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                  , G_MODULE_NAME || l_api_name
                  ,'check if the value matches any of the value in the lookup table'
                  );
  END IF;

  SELECT COUNT(*)
  INTO l_count
  FROM fnd_lookups
  WHERE lookup_type = p_lookup_type
    AND lookup_code = p_rule_field_value;

   IF l_count=0
   THEN
     IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
     THEN
       FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                     , G_MODULE_NAME || l_api_name
                     , 'No,the value does not matches any of the values in the lookup table,
                       get the value from the appropiate form'
                     );
     END IF;

     ------check value in the SO or PO or ORG form
     -----for SO
     IF p_mvt_transaction_rec.document_source_type IN ('SO','IO','RMA')
       AND p_mvt_transaction_rec.bill_to_site_use_id IS NOT NULL
     THEN

       l_form_vat_value:=INV_MGD_MVT_UTILS_PKG.Get_Cust_VAT_Number
       ( p_site_use_id  => p_mvt_transaction_rec.bill_to_site_use_id
       );

       IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
       THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                      , G_MODULE_NAME || l_api_name
                      , 'partner=customer, VAT='||l_form_vat_value
                    );
       END IF;

     ------for PO
     ELSIF p_mvt_transaction_rec.document_source_type in ('PO','RTV')
       AND p_mvt_transaction_rec.vendor_site_id IS NOT NULL
     THEN
       INV_MGD_MVT_UTILS_PKG.Get_Vendor_Info
       ( x_movement_transaction => l_mvt_transaction_rec
       );

       l_form_vat_value:=l_mvt_transaction_rec.customer_vat_number;

       IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
       THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                      , G_MODULE_NAME || l_api_name
                      , 'partner=vendor, VAT='||l_form_vat_value
                    );
       END IF;

     ---- for ORG
     ELSIF p_mvt_transaction_rec.document_source_type = 'INV'
     THEN
       l_form_vat_value :=INV_MGD_MVT_UTILS_PKG.Get_Org_VAT_Number
                          ( p_entity_org_id => p_mvt_transaction_rec.entity_org_id
                          , p_date          => p_mvt_transaction_rec.transaction_date);

       IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
       THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                      , G_MODULE_NAME || l_api_name
                      , 'partner=organization, VAT='||l_form_vat_value
                    );
       END IF;

     END IF;

     ----check if the value from the form matches the lookup value
     SELECT COUNT(*)
     INTO l_count1
     FROM fnd_lookups
     WHERE lookup_type = p_lookup_type
       AND lookup_code = l_form_vat_value;

     ----- the value does not match, this is the error
     IF l_count1=0
     THEN
      --Invalid Value for attribute field
      create_table_data(p_col_name   => p_attribute_code
                         ,p_message_cd => 1
                         );
      x_return_status := FND_API.G_RET_STS_ERROR;

      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
      THEN
        FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                      , G_MODULE_NAME || l_api_name
                      , 'The value in the form does not match to any of the lookup values, this is the exception'
                    );
      END IF;

      ----value match, correct value in the mvt_statistics table
      ELSE
        UPDATE mtl_movement_statistics
        SET customer_vat_number=l_form_vat_value
        WHERE movement_id=p_mvt_transaction_rec.movement_id;

        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
        THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                        , G_MODULE_NAME || l_api_name
                        , 'The value in the form matches one of the lookup value,
                           correct value in the mvt_statistics table.'
                      );
        END IF;
      END IF;
   END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_api_name || '.end'
                  ,'exit procedure'
                  );
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    ---x_movement_transaction := p_mvt_transaction_rec;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, 'Partner_vat_number');
    END IF;
    INV_MGD_MVT_UTILS_PKG.Log( INV_MGD_MVT_UTILS_PKG.G_LOG_PROCEDURE,
    '-Partner_vat_number');


END Partner_vat_number;


--========================================================================
-- PROCEDURE : Validate_Rules            PRIVATE
-- PARAMETERS: p_mtl_transaction          IN  movement transaction record
--             x_mtl_transaction          OUT movement transaction record
--             x_return_status            OUT standard output
--             x_msg_count                OUT NUMBER
--             x_msg_data                 OUT VARCHAR2
--
-- VERSION   : current version         1.0
--             initial_version          1.0
-- COMMENT   : Validate the transaction record based Validation Rules
--=======================================================================
PROCEDURE Validate_Rules
( p_movement_stat_usages_rec      IN
    INV_MGD_MVT_DATA_STR.Movement_Stat_Usages_Rec_Type
, x_movement_transaction          IN OUT NOCOPY
    INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
, x_return_status                 OUT NOCOPY VARCHAR2
, x_uom_status                    OUT NOCOPY VARCHAR2
, x_msg_count                     OUT NOCOPY NUMBER
, x_msg_data                      OUT NOCOPY VARCHAR2
)
IS
  l_orig_mvmt_transaction
                   INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type;
  l_chk            NUMBER;
  Rule_field_Value VARCHAR2(240);
  correct_value    VARCHAR2(240);
  valid_value      VARCHAR2(1);
  lookup_value     VARCHAR2(80);
  msg_cd           NUMBER;
  conv_rate        NUMBER;
  l_return_status  VARCHAR2(200);
  l_api_name CONSTANT VARCHAR2(30) := 'Validate_Rules';

--Declare a cursor to fetch Attribute_Property set of Rules defined for the transaction Source Type
  CURSOR Rules IS
  Select ATTRIBUTE_CODE
  , ATTRIBUTE_PROPERTY_CODE
  , ATTRIBUTE_LOOKUP_TYPE
  FROM MTL_MVT_STATS_RULES
  WHERE RULE_SET_CODE = p_movement_stat_usages_rec.Attribute_rule_set_code
    AND SOURCE_TYPE = x_movement_transaction.document_source_type;

BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_api_name || '.begin'
                  ,'enter procedure'
                  );
  END IF;

  -- Initialize to 'N'
  x_uom_status := 'N';

  -- Copy input transaction record to local record for processing
  l_orig_mvmt_transaction := x_movement_transaction;

  -- Init x_return_status
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                    , G_MODULE_NAME || l_api_name
                    , 'RULE_SET_CODE= '||p_movement_stat_usages_rec.Attribute_rule_set_code
                  );
    END IF;

--Check to see if there is a rule defined for any of the user configurable fields

  FOR Rules_rec IN Rules LOOP

    IF Rules_rec.attribute_code= 'ORIGIN_TERRITORY_CODE' Then
       Rule_Field_Value := l_orig_mvmt_transaction.ORIGIN_TERRITORY_CODE;
    ELSIF Rules_rec.attribute_code='TRANSACTION_NATURE' Then
       Rule_Field_Value := l_orig_mvmt_transaction.TRANSACTION_NATURE;
    ELSIF Rules_rec.attribute_code= 'TRANSPORT_MODE' Then
       Rule_Field_Value := l_orig_mvmt_transaction.TRANSPORT_MODE;
    ELSIF Rules_rec.attribute_code= 'PORT' Then
       Rule_Field_Value := l_orig_mvmt_transaction.PORT;
    ELSIF Rules_rec.attribute_code= 'DELIVERY_TERMS' THEN
       Rule_Field_Value := l_orig_mvmt_transaction.DELIVERY_TERMS;
    ELSIF Rules_rec.attribute_code= 'STATISTICAL_PROCEDURE_CODE' THEN
       Rule_Field_Value := l_orig_mvmt_transaction.STATISTICAL_PROCEDURE_CODE;
    ELSIF Rules_rec.attribute_code=  'AREA' THEN
       Rule_Field_Value := l_orig_mvmt_transaction.AREA;
    ELSIF Rules_rec.attribute_code= 'OUTSIDE_CODE' THEN
       Rule_Field_Value := l_orig_mvmt_transaction.OUTSIDE_CODE;
    ELSIF Rules_rec.attribute_code=  'OUTSIDE_UNIT_PRICE' THEN
       Rule_Field_Value := l_orig_mvmt_transaction.OUTSIDE_UNIT_PRICE;
    ELSIF Rules_rec.attribute_code= 'OUTSIDE_EXT_VALUE' THEN
       Rule_Field_Value := l_orig_mvmt_transaction.OUTSIDE_EXT_VALUE;
    ELSIF Rules_rec.attribute_code= 'TRIANGULATION_COUNTRY_CODE' THEN
       Rule_Field_Value := l_orig_mvmt_transaction.TRIANGULATION_COUNTRY_CODE;
    ELSIF Rules_rec.attribute_code= 'CSA_CODE' THEN
       Rule_Field_Value := l_orig_mvmt_transaction.CSA_CODE;
    ELSIF Rules_rec.attribute_code= 'OIL_REFERENCE_CODE' THEN
       Rule_Field_Value := l_orig_mvmt_transaction.OIL_REFERENCE_CODE;
    ELSIF Rules_rec.attribute_code= 'CONTAINER_TYPE_CODE' THEN
       Rule_Field_Value := l_orig_mvmt_transaction.CONTAINER_TYPE_CODE;
    ELSIF Rules_rec.attribute_code= 'FLOW_INDICATOR_CODE' THEN
       Rule_Field_Value := l_orig_mvmt_transaction.FLOW_INDICATOR_CODE;
    ELSIF Rules_rec.attribute_code= 'AFFILIATION_REFERENCE_CODE' THEN
       Rule_Field_Value := l_orig_mvmt_transaction.AFFILIATION_REFERENCE_CODE;
    ------added for FPJ
    ELSIF Rules_rec.attribute_code= 'PARTNER_VAT_NUMBER' THEN
       Rule_Field_Value := l_orig_mvmt_transaction.CUSTOMER_VAT_NUMBER;
    ELSE Rule_Field_Value := NULL;
    END IF;

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                    , G_MODULE_NAME || l_api_name
                    , 'Rules_rec.attribute_code= '||Rules_rec.attribute_code
                  );
    END IF;

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                    , G_MODULE_NAME || l_api_name
                    , 'Rule_Field_Value= '||Rule_Field_Value
                  );
    END IF;

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                    , G_MODULE_NAME || l_api_name
                    , 'Rules_rec.Attribute_property_Code= '||Rules_rec.Attribute_property_Code
                  );
    END IF;

---------------------

    IF RULE_FIELD_VALUE IS NULL
    THEN
      -- Need to raise an exception only for REQUIRED fields
      IF Rules_rec.Attribute_property_Code = 'REQUIRED_UPDATEABLE'
         OR Rules_rec.Attribute_property_Code = 'REQUIRED_NON_UPDATEABLE'
      THEN
        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
        THEN
          FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                        , G_MODULE_NAME || l_api_name
                        , 'Exception for '||Rules_rec.attribute_code
                        );
        END IF;

        -----special code for Partner VAT Number
        IF Rules_rec.attribute_code='PARTNER_VAT_NUMBER'
        THEN
          Partner_vat_number
          ( p_mvt_transaction_rec => l_orig_mvmt_transaction
          , p_lookup_type         => rules_rec.attribute_lookup_type
          , p_rule_field_value    => rule_field_value
          , p_attribute_code      => Rules_rec.attribute_code
          , x_return_status       => l_return_status
          );

          IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
          THEN
            FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                          , G_MODULE_NAME || l_api_name
                          , 'out of Partner_vat_number with status '||l_return_status
                          );
          END IF;

          x_return_status :=l_return_status;

        -------all other attribute codes
        ELSE

           create_table_data(p_col_name   => Rules_rec.attribute_code
                            ,p_message_cd => 2
                            );

          x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;
      END IF;
    ELSE
       -- Verify if the value is valid from rules table
       -- Only If Lookup Type is defined for this field

      IF Rules_rec.attribute_lookup_type is NOT NULL
      THEN

        -----for Trading Partner VAT
        IF Rules_rec.attribute_code='PARTNER_VAT_NUMBER'
        THEN
          IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
          THEN
            FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                          , G_MODULE_NAME || l_api_name
                          , 'Rules_rec.attribute_code='||Rules_rec.attribute_code
                          );
          END IF;

           Partner_vat_number( p_mvt_transaction_rec => l_orig_mvmt_transaction
                      , p_lookup_type         => rules_rec.attribute_lookup_type
                      , p_rule_field_value    => rule_field_value
                      , p_attribute_code      => Rules_rec.attribute_code
                      , x_return_status       => l_return_status
                      );

           IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
           THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                           , G_MODULE_NAME || l_api_name
                           , 'out of Partner_vat_number with status '||l_return_status
                           );
           END IF;
        ELSE

           BEGIN
              Select MEANING into lookup_value
	      from fnd_lookups
	      where lookup_type = rules_rec.attribute_lookup_type
                and lookup_code = rule_field_value;
             EXCEPTION
	     WHEN NO_DATA_FOUND THEN
	      --Invalid Value for attribute field
               create_table_data(p_col_name   => Rules_rec.attribute_code
                 ,p_message_cd => 2);
		 x_return_status := FND_API.G_RET_STS_ERROR;
	   END;
        END IF;

      END IF;  --Rules_rec.attribute_lookup_type

    END IF; -- IF RULE_FIELD_VALUE IS NULL

END LOOP;


  -- For Rule Type as Alternate_UOM
  BEGIN
  IF l_orig_mvmt_transaction.alternate_uom_code is NULL then

    -- Set x_uom_status to 'Y' to indicate Alternate Uom update
    x_uom_status := 'Y';

    Select Attribute_Code
    Into   l_orig_mvmt_transaction.alternate_uom_code
    From   MTL_MVT_STATS_RULES
    Where  RULE_SET_CODE = p_movement_stat_usages_rec.Alt_Uom_Rule_Set_Code
      And  commodity_code = l_orig_mvmt_transaction.commodity_code;

    -- Get Conversion rate using inv_convert.inv_um_conversion
    inv_convert.inv_um_conversion(
	    from_unit => l_orig_mvmt_transaction.transaction_uom_code
	    , to_unit => l_orig_mvmt_transaction.alternate_uom_code
	    , item_id => l_orig_mvmt_transaction.inventory_item_id
	    , uom_rate => conv_rate);

    -- Calculate alternate quantity
      l_orig_mvmt_transaction.alternate_quantity :=
	   l_orig_mvmt_transaction.transaction_quantity * conv_rate;

  END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      -- No Alternate UOM rule is defined
      --yawang
      IF l_orig_mvmt_transaction.alternate_uom_code IS NULL
      THEN
        x_uom_status := 'N';
      END IF;
  END;



  x_movement_transaction := l_orig_mvmt_transaction;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_api_name || '.end'
                  ,'exit procedure'
                  );
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_movement_transaction := l_orig_mvmt_transaction;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, 'Validate_Rules');
    END IF;

  END; -- Validate Rules

--========================================================================
-- PROCEDURE : Get_Invoice_Transactions    PRIVATE
-- PARAMETERS: inv_crsr                    REF cursor
--             x_return_status             return status
--             p_movement_transaction      Movement stats record
--             p_start_date                Transaction start Date
--             p_end_date                  Transaction End Date
-- COMMENT   : Get the Open and Verified Invoice Transactions
--========================================================================

PROCEDURE Get_Invoice_Transactions (
   inv_crsr                     IN OUT NOCOPY  INV_MGD_MVT_DATA_STR.valCurTyp
 , p_movement_transaction       IN
                  INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
 , p_start_date                 IN  DATE
 , p_end_date                   IN  DATE
 , p_transaction_type           IN  VARCHAR2
 , x_return_status              OUT NOCOPY VARCHAR2
)
IS
  l_api_name CONSTANT VARCHAR2(30) := 'Get_Invoice_Transactions';
BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_api_name || '.begin'
                  ,'enter procedure'
                  );
  END IF;

  x_return_status := 'Y';

    IF inv_crsr%ISOPEN THEN
      CLOSE inv_crsr;
    END IF;


OPEN inv_crsr FOR
SELECT
    mtl_stats.movement_id
  , mtl_stats.organization_id
  , mtl_stats.entity_org_id
  , mtl_stats.movement_type
  , mtl_stats.movement_status
  , mtl_stats.transaction_date
  , mtl_stats.last_update_date
  , mtl_stats.last_updated_by
  , mtl_stats.creation_date
  , mtl_stats.created_by
  , mtl_stats.last_update_login
  , mtl_stats.document_source_type
  , mtl_stats.creation_method
  , mtl_stats.document_reference
  , mtl_stats.document_line_reference
  , mtl_stats.document_unit_price
  , mtl_stats.document_line_ext_value
  , mtl_stats.receipt_reference
  , mtl_stats.shipment_reference
  , mtl_stats.shipment_line_reference
  , mtl_stats.pick_slip_reference
  , mtl_stats.customer_name
  , mtl_stats.customer_number
  , mtl_stats.customer_location
  , mtl_stats.transacting_from_org
  , mtl_stats.transacting_to_org
  , mtl_stats.vendor_name
  , mtl_stats.vendor_number
  , mtl_stats.vendor_site
  , mtl_stats.bill_to_name
  , mtl_stats.bill_to_number
  , mtl_stats.bill_to_site
  , mtl_stats.po_header_id
  , mtl_stats.po_line_id
  , mtl_stats.po_line_location_id
  , mtl_stats.order_header_id
  , mtl_stats.order_line_id
  , mtl_stats.picking_line_id
  , mtl_stats.shipment_header_id
  , mtl_stats.shipment_line_id
  , mtl_stats.ship_to_customer_id
  , mtl_stats.ship_to_site_use_id
  , mtl_stats.bill_to_customer_id
  , mtl_stats.bill_to_site_use_id
  , mtl_stats.vendor_id
  , mtl_stats.vendor_site_id
  , mtl_stats.from_organization_id
  , mtl_stats.to_organization_id
  , mtl_stats.parent_movement_id
  , mtl_stats.inventory_item_id
  , mtl_stats.item_description
  , mtl_stats.item_cost
  , mtl_stats.transaction_quantity
  , mtl_stats.transaction_uom_code
  , mtl_stats.primary_quantity
  , mtl_stats.invoice_batch_id
  , mtl_stats.invoice_id
  , mtl_stats.customer_trx_line_id
  , mtl_stats.invoice_batch_reference
  , mtl_stats.invoice_reference
  , mtl_stats.invoice_line_reference
  , mtl_stats.invoice_date_reference
  , mtl_stats.invoice_quantity
  , mtl_stats.invoice_unit_price
  , mtl_stats.invoice_line_ext_value
  , mtl_stats.outside_code
  , mtl_stats.outside_ext_value
  , mtl_stats.outside_unit_price
  , mtl_stats.currency_code
  , mtl_stats.currency_conversion_rate
  , mtl_stats.currency_conversion_type
  , mtl_stats.currency_conversion_date
  , mtl_stats.period_name
  , mtl_stats.report_reference
  , mtl_stats.report_date
  , mtl_stats.category_id
  , mtl_stats.weight_method
  , mtl_stats.unit_weight
  , mtl_stats.total_weight
  , mtl_stats.transaction_nature
  , mtl_stats.delivery_terms
  , mtl_stats.transport_mode
  , mtl_stats.alternate_quantity
  , mtl_stats.alternate_uom_code
  , mtl_stats.dispatch_territory_code
  , mtl_stats.destination_territory_code
  , mtl_stats.origin_territory_code
  , mtl_stats.stat_method
  , mtl_stats.stat_adj_percent
  , mtl_stats.stat_adj_amount
  , mtl_stats.stat_ext_value
  , mtl_stats.area
  , mtl_stats.port
  , mtl_stats.stat_type
  , mtl_stats.comments
  , mtl_stats.attribute_category
  , mtl_stats.commodity_code
  , mtl_stats.commodity_description
  , mtl_stats.requisition_header_id
  , mtl_stats.requisition_line_id
  , mtl_stats.picking_line_detail_id
  , mtl_stats.usage_type
  , mtl_stats.zone_code
  , mtl_stats.edi_sent_flag
  , mtl_stats.statistical_procedure_code
  , mtl_stats.movement_amount
  , mtl_stats.triangulation_country_code
  , mtl_stats.csa_code
  , mtl_stats.oil_reference_code
  , mtl_stats.container_type_code
  , mtl_stats.flow_indicator_code
  , mtl_stats.affiliation_reference_code
  , mtl_stats.origin_territory_eu_code
  , mtl_stats.destination_territory_eu_code
  , mtl_stats.dispatch_territory_eu_code
  , mtl_stats.set_of_books_period
  , mtl_stats.taric_code
  , mtl_stats.preference_code
  , mtl_stats.rcv_transaction_id
  , mtl_stats.mtl_transaction_id
  , mtl_stats.total_weight_uom_code
  , mtl_stats.financial_document_flag
  , mtl_stats.customer_vat_number
  , mtl_stats.attribute1
  , mtl_stats.attribute2
  , mtl_stats.attribute3
  , mtl_stats.attribute4
  , mtl_stats.attribute5
  , mtl_stats.attribute6
  , mtl_stats.attribute7
  , mtl_stats.attribute8
  , mtl_stats.attribute9
  , mtl_stats.attribute10
  , mtl_stats.attribute11
  , mtl_stats.attribute12
  , mtl_stats.attribute13
  , mtl_stats.attribute14
  , mtl_stats.attribute15
  , mtl_stats.triangulation_country_eu_code
  , mtl_stats.distribution_line_number
  , mtl_stats.ship_to_name
  , mtl_stats.ship_to_number
  , mtl_stats.ship_to_site
  , mtl_stats.edi_transaction_date
  , mtl_stats.edi_transaction_reference
  , mtl_stats.esl_drop_shipment_code
FROM
  MTL_MOVEMENT_STATISTICS mtl_stats
  WHERE entity_org_id         = p_movement_transaction.entity_org_id
  AND document_source_type    = DECODE(p_transaction_type,null,
       document_source_type,'ALL',document_source_type,p_transaction_type )
  AND transaction_date  BETWEEN  trunc(p_start_date -1) and trunc(p_end_date +1)
  AND movement_status  in ('O','V')
  AND financial_document_flag <> 'NOT_REQUIRED'
  ORDER BY   mtl_stats.movement_id;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_api_name || '.end'
                  ,'exit procedure'
                  );
  END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
	x_return_status := 'N';
    WHEN OTHERS THEN
        x_return_status := 'N';

END Get_Invoice_Transactions;

--========================================================================
-- PROCEDURE : Get_PO_Trans_With_Correction    PRIVATE
-- PARAMETERS: inv_crsr                        REF cursor
--             x_return_status                 return status
--             p_legal_entity_id               Movement stats record
--             p_start_date                    Transaction start Date
--             p_end_date                      Transaction End Date
-- COMMENT   : Get the Open, Verified and Pending PO Transactions with
--             correction
--========================================================================

PROCEDURE Get_PO_Trans_With_Correction
 ( inv_crsr                     IN OUT NOCOPY  INV_MGD_MVT_DATA_STR.valCurTyp
 , p_legal_entity_id            IN  NUMBER
 , p_start_date                 IN  DATE
 , p_end_date                   IN  DATE
 , p_transaction_type           IN  VARCHAR2
 , x_return_status              OUT NOCOPY VARCHAR2
)
IS
  l_api_name CONSTANT VARCHAR2(30) := 'Get_PO_Trans_With_Correction';
BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_api_name || '.begin'
                  ,'enter procedure'
                  );
  END IF;

  x_return_status := 'Y';

  IF inv_crsr%ISOPEN
  THEN
    CLOSE inv_crsr;
  END IF;

  OPEN inv_crsr FOR
  SELECT
    mtl_stats.movement_id
  , mtl_stats.organization_id
  , mtl_stats.entity_org_id
  , mtl_stats.movement_type
  , mtl_stats.movement_status
  , mtl_stats.transaction_date
  , mtl_stats.last_update_date
  , mtl_stats.last_updated_by
  , mtl_stats.creation_date
  , mtl_stats.created_by
  , mtl_stats.last_update_login
  , mtl_stats.document_source_type
  , mtl_stats.creation_method
  , mtl_stats.document_reference
  , mtl_stats.document_line_reference
  , mtl_stats.document_unit_price
  , mtl_stats.document_line_ext_value
  , mtl_stats.receipt_reference
  , mtl_stats.shipment_reference
  , mtl_stats.shipment_line_reference
  , mtl_stats.pick_slip_reference
  , mtl_stats.customer_name
  , mtl_stats.customer_number
  , mtl_stats.customer_location
  , mtl_stats.transacting_from_org
  , mtl_stats.transacting_to_org
  , mtl_stats.vendor_name
  , mtl_stats.vendor_number
  , mtl_stats.vendor_site
  , mtl_stats.bill_to_name
  , mtl_stats.bill_to_number
  , mtl_stats.bill_to_site
  , mtl_stats.po_header_id
  , mtl_stats.po_line_id
  , mtl_stats.po_line_location_id
  , mtl_stats.order_header_id
  , mtl_stats.order_line_id
  , mtl_stats.picking_line_id
  , mtl_stats.shipment_header_id
  , mtl_stats.shipment_line_id
  , mtl_stats.ship_to_customer_id
  , mtl_stats.ship_to_site_use_id
  , mtl_stats.bill_to_customer_id
  , mtl_stats.bill_to_site_use_id
  , mtl_stats.vendor_id
  , mtl_stats.vendor_site_id
  , mtl_stats.from_organization_id
  , mtl_stats.to_organization_id
  , mtl_stats.parent_movement_id
  , mtl_stats.inventory_item_id
  , mtl_stats.item_description
  , mtl_stats.item_cost
  , mtl_stats.transaction_quantity
  , mtl_stats.transaction_uom_code
  , mtl_stats.primary_quantity
  , mtl_stats.invoice_batch_id
  , mtl_stats.invoice_id
  , mtl_stats.customer_trx_line_id
  , mtl_stats.invoice_batch_reference
  , mtl_stats.invoice_reference
  , mtl_stats.invoice_line_reference
  , mtl_stats.invoice_date_reference
  , mtl_stats.invoice_quantity
  , mtl_stats.invoice_unit_price
  , mtl_stats.invoice_line_ext_value
  , mtl_stats.outside_code
  , mtl_stats.outside_ext_value
  , mtl_stats.outside_unit_price
  , mtl_stats.currency_code
  , mtl_stats.currency_conversion_rate
  , mtl_stats.currency_conversion_type
  , mtl_stats.currency_conversion_date
  , mtl_stats.period_name
  , mtl_stats.report_reference
  , mtl_stats.report_date
  , mtl_stats.category_id
  , mtl_stats.weight_method
  , mtl_stats.unit_weight
  , mtl_stats.total_weight
  , mtl_stats.transaction_nature
  , mtl_stats.delivery_terms
  , mtl_stats.transport_mode
  , mtl_stats.alternate_quantity
  , mtl_stats.alternate_uom_code
  , mtl_stats.dispatch_territory_code
  , mtl_stats.destination_territory_code
  , mtl_stats.origin_territory_code
  , mtl_stats.stat_method
  , mtl_stats.stat_adj_percent
  , mtl_stats.stat_adj_amount
  , mtl_stats.stat_ext_value
  , mtl_stats.area
  , mtl_stats.port
  , mtl_stats.stat_type
  , mtl_stats.comments
  , mtl_stats.attribute_category
  , mtl_stats.commodity_code
  , mtl_stats.commodity_description
  , mtl_stats.requisition_header_id
  , mtl_stats.requisition_line_id
  , mtl_stats.picking_line_detail_id
  , mtl_stats.usage_type
  , mtl_stats.zone_code
  , mtl_stats.edi_sent_flag
  , mtl_stats.statistical_procedure_code
  , mtl_stats.movement_amount
  , mtl_stats.triangulation_country_code
  , mtl_stats.csa_code
  , mtl_stats.oil_reference_code
  , mtl_stats.container_type_code
  , mtl_stats.flow_indicator_code
  , mtl_stats.affiliation_reference_code
  , mtl_stats.origin_territory_eu_code
  , mtl_stats.destination_territory_eu_code
  , mtl_stats.dispatch_territory_eu_code
  , mtl_stats.set_of_books_period
  , mtl_stats.taric_code
  , mtl_stats.preference_code
  , mtl_stats.rcv_transaction_id
  , mtl_stats.mtl_transaction_id
  , mtl_stats.total_weight_uom_code
  , mtl_stats.financial_document_flag
  , mtl_stats.customer_vat_number
  , mtl_stats.attribute1
  , mtl_stats.attribute2
  , mtl_stats.attribute3
  , mtl_stats.attribute4
  , mtl_stats.attribute5
  , mtl_stats.attribute6
  , mtl_stats.attribute7
  , mtl_stats.attribute8
  , mtl_stats.attribute9
  , mtl_stats.attribute10
  , mtl_stats.attribute11
  , mtl_stats.attribute12
  , mtl_stats.attribute13
  , mtl_stats.attribute14
  , mtl_stats.attribute15
  , mtl_stats.triangulation_country_eu_code
  , mtl_stats.distribution_line_number
  , mtl_stats.ship_to_name
  , mtl_stats.ship_to_number
  , mtl_stats.ship_to_site
  , mtl_stats.edi_transaction_date
  , mtl_stats.edi_transaction_reference
  , mtl_stats.esl_drop_shipment_code
  FROM
    MTL_MOVEMENT_STATISTICS mtl_stats
  WHERE entity_org_id        = p_legal_entity_id
    AND document_source_type IN ('PO', 'RTV')
    AND movement_status  IN ('O','V','P')
    AND transaction_date BETWEEN TRUNC(p_start_date -1)
                             AND TRUNC(p_end_date +1)
    AND rcv_transaction_id
        IN (SELECT parent_transaction_id
              FROM rcv_transactions
             WHERE mvt_stat_status = 'NEW'
               AND transaction_type = 'CORRECT')
  ORDER BY   mtl_stats.movement_id;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_api_name || '.end'
                  ,'exit procedure'
                  );
  END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_return_status := 'N';
    WHEN OTHERS THEN
      x_return_status := 'N';

END Get_PO_Trans_With_Correction;


--========================================================================
-- PROCEDURE : Get_Pending_Txns    PRIVATE
-- PARAMETERS: val_crsr                    REF cursor
--             x_return_status             return status
--             p_transaction_type          Transaction Type
-- COMMENT   :
--             This opens the cursor for INV and returns the cursor.
--========================================================================

PROCEDURE Get_Pending_Txns (
   val_crsr                     IN OUT NOCOPY  INV_MGD_MVT_DATA_STR.valCurTyp
 , p_movement_transaction       IN
                  INV_MGD_MVT_DATA_STR.Movement_Transaction_Rec_Type
 , p_document_source_type       IN  VARCHAR2
 , x_return_status              OUT NOCOPY VARCHAR2
)
IS
  l_api_name CONSTANT VARCHAR2(30) := 'Get_Pending_Txns';
BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_api_name || '.begin'
                  ,'enter procedure'
                  );
  END IF;

  x_return_status := 'Y';

    IF val_crsr%ISOPEN THEN
      CLOSE val_crsr;
    END IF;

OPEN val_crsr FOR
SELECT
    mtl_stats.movement_id
  , mtl_stats.organization_id
  , mtl_stats.entity_org_id
  , mtl_stats.movement_type
  , mtl_stats.movement_status
  , mtl_stats.transaction_date
  , mtl_stats.last_update_date
  , mtl_stats.last_updated_by
  , mtl_stats.creation_date
  , mtl_stats.created_by
  , mtl_stats.last_update_login
  , mtl_stats.document_source_type
  , mtl_stats.creation_method
  , mtl_stats.document_reference
  , mtl_stats.document_line_reference
  , mtl_stats.document_unit_price
  , mtl_stats.document_line_ext_value
  , mtl_stats.receipt_reference
  , mtl_stats.shipment_reference
  , mtl_stats.shipment_line_reference
  , mtl_stats.pick_slip_reference
  , mtl_stats.customer_name
  , mtl_stats.customer_number
  , mtl_stats.customer_location
  , mtl_stats.transacting_from_org
  , mtl_stats.transacting_to_org
  , mtl_stats.vendor_name
  , mtl_stats.vendor_number
  , mtl_stats.vendor_site
  , mtl_stats.bill_to_name
  , mtl_stats.bill_to_number
  , mtl_stats.bill_to_site
  , mtl_stats.po_header_id
  , mtl_stats.po_line_id
  , mtl_stats.po_line_location_id
  , mtl_stats.order_header_id
  , mtl_stats.order_line_id
  , mtl_stats.picking_line_id
  , mtl_stats.shipment_header_id
  , mtl_stats.shipment_line_id
  , mtl_stats.ship_to_customer_id
  , mtl_stats.ship_to_site_use_id
  , mtl_stats.bill_to_customer_id
  , mtl_stats.bill_to_site_use_id
  , mtl_stats.vendor_id
  , mtl_stats.vendor_site_id
  , mtl_stats.from_organization_id
  , mtl_stats.to_organization_id
  , mtl_stats.parent_movement_id
  , mtl_stats.inventory_item_id
  , mtl_stats.item_description
  , mtl_stats.item_cost
  , mtl_stats.transaction_quantity
  , mtl_stats.transaction_uom_code
  , mtl_stats.primary_quantity
  , mtl_stats.invoice_batch_id
  , mtl_stats.invoice_id
  , mtl_stats.customer_trx_line_id
  , mtl_stats.invoice_batch_reference
  , mtl_stats.invoice_reference
  , mtl_stats.invoice_line_reference
  , mtl_stats.invoice_date_reference
  , mtl_stats.invoice_quantity
  , mtl_stats.invoice_unit_price
  , mtl_stats.invoice_line_ext_value
  , mtl_stats.outside_code
  , mtl_stats.outside_ext_value
  , mtl_stats.outside_unit_price
  , mtl_stats.currency_code
  , mtl_stats.currency_conversion_rate
  , mtl_stats.currency_conversion_type
  , mtl_stats.currency_conversion_date
  , mtl_stats.period_name
  , mtl_stats.report_reference
  , mtl_stats.report_date
  , mtl_stats.category_id
  , mtl_stats.weight_method
  , mtl_stats.unit_weight
  , mtl_stats.total_weight
  , mtl_stats.transaction_nature
  , mtl_stats.delivery_terms
  , mtl_stats.transport_mode
  , mtl_stats.alternate_quantity
  , mtl_stats.alternate_uom_code
  , mtl_stats.dispatch_territory_code
  , mtl_stats.destination_territory_code
  , mtl_stats.origin_territory_code
  , mtl_stats.stat_method
  , mtl_stats.stat_adj_percent
  , mtl_stats.stat_adj_amount
  , mtl_stats.stat_ext_value
  , mtl_stats.area
  , mtl_stats.port
  , mtl_stats.stat_type
  , mtl_stats.comments
  , mtl_stats.attribute_category
  , mtl_stats.commodity_code
  , mtl_stats.commodity_description
  , mtl_stats.requisition_header_id
  , mtl_stats.requisition_line_id
  , mtl_stats.picking_line_detail_id
  , mtl_stats.usage_type
  , mtl_stats.zone_code
  , mtl_stats.edi_sent_flag
  , mtl_stats.statistical_procedure_code
  , mtl_stats.movement_amount
  , mtl_stats.triangulation_country_code
  , mtl_stats.csa_code
  , mtl_stats.oil_reference_code
  , mtl_stats.container_type_code
  , mtl_stats.flow_indicator_code
  , mtl_stats.affiliation_reference_code
  , mtl_stats.origin_territory_eu_code
  , mtl_stats.destination_territory_eu_code
  , mtl_stats.dispatch_territory_eu_code
  , mtl_stats.set_of_books_period
  , mtl_stats.taric_code
  , mtl_stats.preference_code
  , mtl_stats.rcv_transaction_id
  , mtl_stats.mtl_transaction_id
  , mtl_stats.total_weight_uom_code
  , mtl_stats.financial_document_flag
  , mtl_stats.customer_vat_number
  , mtl_stats.attribute1
  , mtl_stats.attribute2
  , mtl_stats.attribute3
  , mtl_stats.attribute4
  , mtl_stats.attribute5
  , mtl_stats.attribute6
  , mtl_stats.attribute7
  , mtl_stats.attribute8
  , mtl_stats.attribute9
  , mtl_stats.attribute10
  , mtl_stats.attribute11
  , mtl_stats.attribute12
  , mtl_stats.attribute13
  , mtl_stats.attribute14
  , mtl_stats.attribute15
  , mtl_stats.triangulation_country_eu_code
  , mtl_stats.distribution_line_number
  , mtl_stats.ship_to_name
  , mtl_stats.ship_to_number
  , mtl_stats.ship_to_site
  , mtl_stats.edi_transaction_date
  , mtl_stats.edi_transaction_reference
  , mtl_stats.esl_drop_shipment_code
FROM
  MTL_MOVEMENT_STATISTICS mtl_stats
WHERE entity_org_id        = p_movement_transaction.entity_org_id
  AND document_source_type    = DECODE(p_document_source_type,null,
       document_source_type,'ALL',document_source_type,p_document_source_type )
  AND movement_status      = 'P'
ORDER BY
  mtl_stats.movement_id;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
  THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_NAME || l_api_name || '.end'
                  ,'exit procedure'
                  );
  END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
	x_return_status := 'N';
    WHEN OTHERS THEN
        x_return_status := 'N';

END Get_Pending_Txns;

END INV_MGD_MVT_STATS_PVT;

/
