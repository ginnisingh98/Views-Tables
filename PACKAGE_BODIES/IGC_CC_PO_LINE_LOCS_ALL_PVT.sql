--------------------------------------------------------
--  DDL for Package Body IGC_CC_PO_LINE_LOCS_ALL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGC_CC_PO_LINE_LOCS_ALL_PVT" AS
/*$Header: IGCCPLLB.pls 120.4.12010000.2 2008/08/04 14:52:25 sasukuma ship $*/

   G_PKG_NAME CONSTANT VARCHAR2(30):= 'IGC_CC_PO_LINE_LOCS_ALL_PVT';

  -- The flag determines whether to print debug information or not.
  g_debug_flag        VARCHAR2(1) := 'N' ;


/*=======================================================================+
 |                       PROCEDURE Insert_Row                            |
 +=======================================================================*/

PROCEDURE Insert_Row
(
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status             OUT NOCOPY      VARCHAR2,
  x_msg_count                 OUT NOCOPY      NUMBER,
  x_msg_data                  OUT NOCOPY      VARCHAR2,
  ---------------------------------------------
  p_po_line_locs_rec          IN       po_line_locations_all%ROWTYPE
)
IS

  l_api_name            CONSTANT VARCHAR2(30)   := 'Insert_Row';
  l_api_version         CONSTANT NUMBER         :=  1.0;

BEGIN

  SAVEPOINT Insert_Row_Pvt ;

  IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                             p_api_version,
                                             l_api_name,
                                             G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;


  IF FND_API.to_Boolean ( p_init_msg_list )
  THEN
    FND_MSG_PUB.initialize ;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS ;


  INSERT INTO po_line_locations_all (
  line_location_id,
  last_update_date,
  last_updated_by,
  po_header_id,
  po_line_id,
  last_update_login,
  creation_date,
  created_by,
  quantity,
  quantity_received,
  quantity_accepted,
  quantity_rejected,
  quantity_billed,
  quantity_cancelled,
  unit_meas_lookup_code,
  po_release_id,
  ship_to_location_id,
  ship_via_lookup_code,
  need_by_date,
  promised_date,
  last_accept_date,
  price_override,
  encumbered_flag,
  encumbered_date,
  unencumbered_quantity,
  fob_lookup_code,
  freight_terms_lookup_code,
  taxable_flag,
  tax_name,
  estimated_tax_amount,
  from_header_id,
  from_line_id,
  from_line_location_id,
  start_date,
  end_date,
  lead_time,
  lead_time_unit,
  price_discount,
  terms_id,
  approved_flag,
  approved_date,
  closed_flag,
  cancel_flag,
  cancelled_by,
  cancel_date,
  cancel_reason,
  firm_status_lookup_code,
  firm_date,
  attribute_category,
  attribute1,
  attribute2,
  attribute3,
  attribute4,
  attribute5,
  attribute6,
  attribute7,
  attribute8,
  attribute9,
  attribute10,
  unit_of_measure_class,
  encumber_now,
  attribute11,
  attribute12,
  attribute13,
  attribute14,
  attribute15,
  inspection_required_flag,
  receipt_required_flag,
  qty_rcv_tolerance,
  qty_rcv_exception_code,
  enforce_ship_to_location_code,
  allow_substitute_receipts_flag,
  days_early_receipt_allowed,
  days_late_receipt_allowed,
  receipt_days_exception_code,
  invoice_close_tolerance,
  receive_close_tolerance,
  ship_to_organization_id,
  shipment_num,
  source_shipment_id,
  shipment_type,
  closed_code,
  request_id,
  program_application_id,
  program_id,
  program_update_date,
  ussgl_transaction_code,
  government_context,
  receiving_routing_id,
  accrue_on_receipt_flag,
  closed_reason,
  closed_date,
  closed_by,
  org_id,
  global_attribute1,
  global_attribute2,
  global_attribute3,
  global_attribute4,
  global_attribute5,
  global_attribute6,
  global_attribute7,
  global_attribute8,
  global_attribute9,
  global_attribute10,
  global_attribute11,
  global_attribute12,
  global_attribute13,
  global_attribute14,
  global_attribute15,
  global_attribute16,
  global_attribute17,
  global_attribute18,
  global_attribute19,
  global_attribute20,
  global_attribute_category,
  quantity_shipped,
  country_of_origin_code,
  tax_user_override_flag,
  /*match_flag, */
  match_option,
  tax_code_id,
  calculate_tax_flag,
  change_promised_date_reason,
  matching_basis,
  outsourced_assembly          -- Bug 6971366. Added the missing outsource_assembly col
  )
  VALUES
  (
  p_po_line_locs_rec.line_location_id,
  p_po_line_locs_rec.last_update_date,
  p_po_line_locs_rec.last_updated_by,
  p_po_line_locs_rec.po_header_id,
  p_po_line_locs_rec.po_line_id,
  p_po_line_locs_rec.last_update_login,
  p_po_line_locs_rec.creation_date,
  p_po_line_locs_rec.created_by,
  p_po_line_locs_rec.quantity,
  p_po_line_locs_rec.quantity_received,
  p_po_line_locs_rec.quantity_accepted,
  p_po_line_locs_rec.quantity_rejected,
  p_po_line_locs_rec.quantity_billed ,
  p_po_line_locs_rec.quantity_cancelled,
  p_po_line_locs_rec.unit_meas_lookup_code,
  p_po_line_locs_rec.po_release_id,
  p_po_line_locs_rec.ship_to_location_id,
  p_po_line_locs_rec.ship_via_lookup_code,
  p_po_line_locs_rec.need_by_date,
  p_po_line_locs_rec.promised_date,
  p_po_line_locs_rec.last_accept_date,
  p_po_line_locs_rec.price_override,
  p_po_line_locs_rec.encumbered_flag,
  p_po_line_locs_rec.encumbered_date,
  p_po_line_locs_rec.unencumbered_quantity,
  p_po_line_locs_rec.fob_lookup_code,
  p_po_line_locs_rec.freight_terms_lookup_code,
  p_po_line_locs_rec.taxable_flag,
  p_po_line_locs_rec.tax_name,
  p_po_line_locs_rec.estimated_tax_amount,
  p_po_line_locs_rec.from_header_id,
  p_po_line_locs_rec.from_line_id,
  p_po_line_locs_rec.from_line_location_id,
  p_po_line_locs_rec.start_date,
  p_po_line_locs_rec.end_date,
  p_po_line_locs_rec.lead_time,
  p_po_line_locs_rec.lead_time_unit,
  p_po_line_locs_rec.price_discount,
  p_po_line_locs_rec.terms_id,
  p_po_line_locs_rec.approved_flag,
  p_po_line_locs_rec.approved_date,
  p_po_line_locs_rec.closed_flag,
  p_po_line_locs_rec.cancel_flag,
  p_po_line_locs_rec.cancelled_by,
  p_po_line_locs_rec.cancel_date,
  p_po_line_locs_rec.cancel_reason,
  p_po_line_locs_rec.firm_status_lookup_code,
  p_po_line_locs_rec.firm_date,
  p_po_line_locs_rec.attribute_category,
  p_po_line_locs_rec.attribute1,
  p_po_line_locs_rec.attribute2,
  p_po_line_locs_rec.attribute3,
        p_po_line_locs_rec.attribute4,
        p_po_line_locs_rec.attribute5,
        p_po_line_locs_rec.attribute6,
        p_po_line_locs_rec.attribute7,
        p_po_line_locs_rec.attribute8,
        p_po_line_locs_rec.attribute9,
        p_po_line_locs_rec.attribute10,
        p_po_line_locs_rec.unit_of_measure_class,
        p_po_line_locs_rec.encumber_now,
        p_po_line_locs_rec.attribute11,
        p_po_line_locs_rec.attribute12,
        p_po_line_locs_rec.attribute13,
        p_po_line_locs_rec.attribute14,
        p_po_line_locs_rec.attribute15,
        p_po_line_locs_rec.inspection_required_flag,
        p_po_line_locs_rec.receipt_required_flag,
        p_po_line_locs_rec.qty_rcv_tolerance,
        p_po_line_locs_rec.qty_rcv_exception_code,
        p_po_line_locs_rec.enforce_ship_to_location_code,
        p_po_line_locs_rec.allow_substitute_receipts_flag,
        p_po_line_locs_rec.days_early_receipt_allowed,
        p_po_line_locs_rec.days_late_receipt_allowed,
        p_po_line_locs_rec.receipt_days_exception_code,
        p_po_line_locs_rec.invoice_close_tolerance,
        p_po_line_locs_rec.receive_close_tolerance,
        p_po_line_locs_rec.ship_to_organization_id,
        p_po_line_locs_rec.shipment_num,
        p_po_line_locs_rec.source_shipment_id,
        p_po_line_locs_rec.shipment_type,
        p_po_line_locs_rec.closed_code,
        p_po_line_locs_rec.request_id,
        p_po_line_locs_rec.program_application_id,
        p_po_line_locs_rec.program_id,
        p_po_line_locs_rec.program_update_date,
        p_po_line_locs_rec.ussgl_transaction_code,
        p_po_line_locs_rec.government_context,
        p_po_line_locs_rec.receiving_routing_id,
        p_po_line_locs_rec.accrue_on_receipt_flag,
        p_po_line_locs_rec.closed_reason,
        p_po_line_locs_rec.closed_date,
        p_po_line_locs_rec.closed_by,
        p_po_line_locs_rec.org_id,
        p_po_line_locs_rec.global_attribute1,
        p_po_line_locs_rec.global_attribute2,
        p_po_line_locs_rec.global_attribute3,
        p_po_line_locs_rec.global_attribute4,
        p_po_line_locs_rec.global_attribute5,
        p_po_line_locs_rec.global_attribute6,
        p_po_line_locs_rec.global_attribute7,
        p_po_line_locs_rec.global_attribute8,
        p_po_line_locs_rec.global_attribute9,
        p_po_line_locs_rec.global_attribute10,
        p_po_line_locs_rec.global_attribute11,
        p_po_line_locs_rec.global_attribute12,
        p_po_line_locs_rec.global_attribute13,
        p_po_line_locs_rec.global_attribute14,
        p_po_line_locs_rec.global_attribute15,
        p_po_line_locs_rec.global_attribute16,
        p_po_line_locs_rec.global_attribute17,
        p_po_line_locs_rec.global_attribute18,
        p_po_line_locs_rec.global_attribute19,
        p_po_line_locs_rec.global_attribute20,
        p_po_line_locs_rec.global_attribute_category,
        p_po_line_locs_rec.quantity_shipped,
        p_po_line_locs_rec.country_of_origin_code,
        p_po_line_locs_rec.tax_user_override_flag,
        /*p_po_line_locs_rec.match_flag, */
        p_po_line_locs_rec.match_option,
        p_po_line_locs_rec.tax_code_id,
        p_po_line_locs_rec.calculate_tax_flag,
        p_po_line_locs_rec.change_promised_date_reason,
        p_po_line_locs_rec.matching_basis,
        p_po_line_locs_rec.outsourced_assembly     -- Bug 6971366 . Added the missing outsource assembly col.
        ) ;

  IF FND_API.To_Boolean ( p_commit )
  THEN
    COMMIT WORK;
  END IF;

  FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                    p_data  => x_msg_data );

EXCEPTION

  WHEN FND_API.G_EXC_ERROR
  THEN

    ROLLBACK TO Insert_Row_Pvt ;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                            p_data  => x_msg_data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR
  THEN
    ROLLBACK TO Insert_Row_Pvt ;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                      p_data  => x_msg_data );

  WHEN OTHERS
  THEN
    ROLLBACK TO Insert_Row_Pvt ;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
                                                  l_api_name);
    END IF;

    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                            p_data  => x_msg_data );

END Insert_Row;
/*-------------------------------------------------------------------------*/


/*==========================================================================+
 |                       PROCEDURE Update_Row                               |
 +==========================================================================*/

PROCEDURE Update_Row
(
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status             OUT NOCOPY      VARCHAR2,
  x_msg_count                 OUT NOCOPY      NUMBER,
  x_msg_data                  OUT NOCOPY      VARCHAR2,
  ---------------------------------------------
  p_po_line_locs_rec          IN       po_line_locations_all%ROWTYPE
)
IS

  l_api_name            CONSTANT VARCHAR2(30)   := 'Update_Row';
  l_api_version         CONSTANT NUMBER         :=  1.0;

BEGIN

  SAVEPOINT Update_Row_Pvt ;

  IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                             p_api_version,
                                             l_api_name,
                                             G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;


  IF FND_API.to_Boolean ( p_init_msg_list )
  THEN
    FND_MSG_PUB.initialize ;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS ;

        /* update */
        UPDATE po_line_locations_all
        SET
    line_location_id             = p_po_line_locs_rec.line_location_id ,
    last_update_date             = p_po_line_locs_rec.last_update_date,
    last_updated_by              = p_po_line_locs_rec.last_updated_by ,
    po_header_id                 = p_po_line_locs_rec.po_header_id ,
    po_line_id                   = p_po_line_locs_rec.po_line_id,
    last_update_login            = p_po_line_locs_rec.last_update_login ,
    creation_date                = p_po_line_locs_rec.creation_date,
    created_by                   = p_po_line_locs_rec.created_by,
    quantity                     = p_po_line_locs_rec.quantity,
    quantity_received            = p_po_line_locs_rec.quantity_received,
    quantity_accepted            = p_po_line_locs_rec.quantity_accepted,
    quantity_rejected            = p_po_line_locs_rec.quantity_rejected,
    quantity_billed              = p_po_line_locs_rec.quantity_billed ,
    quantity_cancelled           = p_po_line_locs_rec.quantity_cancelled,
    unit_meas_lookup_code        = p_po_line_locs_rec.unit_meas_lookup_code,
    po_release_id                = p_po_line_locs_rec.po_release_id,
    ship_to_location_id          = p_po_line_locs_rec.ship_to_location_id,
    ship_via_lookup_code         = p_po_line_locs_rec.ship_via_lookup_code,
    need_by_date                 = p_po_line_locs_rec.need_by_date,
    promised_date                = p_po_line_locs_rec.promised_date,
    last_accept_date             = p_po_line_locs_rec.last_accept_date,
    price_override               = p_po_line_locs_rec.price_override  ,
    encumbered_flag              = p_po_line_locs_rec.encumbered_flag ,
    encumbered_date              = p_po_line_locs_rec.encumbered_date,
    unencumbered_quantity        = p_po_line_locs_rec.unencumbered_quantity,
    fob_lookup_code              = p_po_line_locs_rec.fob_lookup_code,
    freight_terms_lookup_code    = p_po_line_locs_rec.freight_terms_lookup_code,
    taxable_flag                 = p_po_line_locs_rec.taxable_flag,
    tax_name                     = p_po_line_locs_rec.tax_name ,
    estimated_tax_amount         = p_po_line_locs_rec.estimated_tax_amount ,
    from_header_id               = p_po_line_locs_rec.from_header_id ,
    from_line_id                 = p_po_line_locs_rec.from_line_id  ,
    from_line_location_id        = p_po_line_locs_rec.from_line_location_id ,
    start_date                   = p_po_line_locs_rec.start_date,
    end_date                     = p_po_line_locs_rec.end_date,
    lead_time                    = p_po_line_locs_rec.lead_time,
    lead_time_unit               = p_po_line_locs_rec.lead_time_unit,
    price_discount               = p_po_line_locs_rec.price_discount,
    terms_id                     = p_po_line_locs_rec.terms_id  ,
    approved_flag                = p_po_line_locs_rec.approved_flag,
    approved_date                = p_po_line_locs_rec.approved_date,
    closed_flag                  = p_po_line_locs_rec.closed_flag,
    cancel_flag                  = p_po_line_locs_rec.cancel_flag ,
    cancelled_by                 = p_po_line_locs_rec.cancelled_by ,
    cancel_date                  = p_po_line_locs_rec.cancel_date,
    cancel_reason                = p_po_line_locs_rec.cancel_reason ,
    firm_status_lookup_code      = p_po_line_locs_rec.firm_status_lookup_code,
    firm_date                    = p_po_line_locs_rec.firm_date ,
    attribute_category           = p_po_line_locs_rec.attribute_category,
    attribute1                   = p_po_line_locs_rec.attribute1 ,
    attribute2                   = p_po_line_locs_rec.attribute2 ,
    attribute3                   = p_po_line_locs_rec.attribute3 ,
    attribute4                   = p_po_line_locs_rec.attribute4 ,
    attribute5                   = p_po_line_locs_rec.attribute5 ,
    attribute6                   = p_po_line_locs_rec.attribute6 ,
    attribute7                   = p_po_line_locs_rec.attribute7 ,
    attribute8                   = p_po_line_locs_rec.attribute8 ,
    attribute9                   = p_po_line_locs_rec.attribute9 ,
    attribute10                  = p_po_line_locs_rec.attribute10,
    unit_of_measure_class        = p_po_line_locs_rec.unit_of_measure_class,
    encumber_now                 = p_po_line_locs_rec.encumber_now ,
    attribute11                  = p_po_line_locs_rec.attribute11 ,
    attribute12                  = p_po_line_locs_rec.attribute12 ,
    attribute13                  = p_po_line_locs_rec.attribute13 ,
    attribute14                  = p_po_line_locs_rec.attribute14 ,
    attribute15                  = p_po_line_locs_rec.attribute15 ,
    inspection_required_flag     = p_po_line_locs_rec.inspection_required_flag ,
    receipt_required_flag        = p_po_line_locs_rec.receipt_required_flag,
    qty_rcv_tolerance            = p_po_line_locs_rec.qty_rcv_tolerance,
    qty_rcv_exception_code       = p_po_line_locs_rec.qty_rcv_exception_code ,
    enforce_ship_to_location_code = p_po_line_locs_rec.enforce_ship_to_location_code ,
    allow_substitute_receipts_flag = p_po_line_locs_rec.allow_substitute_receipts_flag,
    days_early_receipt_allowed     = p_po_line_locs_rec.days_early_receipt_allowed ,
    days_late_receipt_allowed      = p_po_line_locs_rec.days_late_receipt_allowed ,
    receipt_days_exception_code    = p_po_line_locs_rec.receipt_days_exception_code ,
    invoice_close_tolerance        = p_po_line_locs_rec.invoice_close_tolerance ,
    receive_close_tolerance        = p_po_line_locs_rec.receive_close_tolerance,
    ship_to_organization_id        = p_po_line_locs_rec.ship_to_organization_id ,
    shipment_num                   = p_po_line_locs_rec.shipment_num   ,
    source_shipment_id             = p_po_line_locs_rec.source_shipment_id ,
    shipment_type                  = p_po_line_locs_rec.shipment_type ,
    closed_code                    = p_po_line_locs_rec.closed_code ,
    request_id                     = p_po_line_locs_rec.request_id ,
    program_application_id         = p_po_line_locs_rec.program_application_id,
    program_id                     = p_po_line_locs_rec.program_id ,
    program_update_date            = p_po_line_locs_rec.program_update_date ,
    ussgl_transaction_code         = p_po_line_locs_rec.ussgl_transaction_code ,
    government_context             = p_po_line_locs_rec.government_context ,
    receiving_routing_id           = p_po_line_locs_rec.receiving_routing_id ,
    accrue_on_receipt_flag         = p_po_line_locs_rec.accrue_on_receipt_flag ,
    closed_reason                  = p_po_line_locs_rec.closed_reason  ,
    closed_date                    = p_po_line_locs_rec.closed_date,
    closed_by                      = p_po_line_locs_rec.closed_by  ,
    org_id                         = p_po_line_locs_rec.org_id ,
    global_attribute1              = p_po_line_locs_rec.global_attribute1 ,
    global_attribute2              = p_po_line_locs_rec.global_attribute2 ,
    global_attribute3              = p_po_line_locs_rec.global_attribute3 ,
    global_attribute4              = p_po_line_locs_rec.global_attribute4 ,
    global_attribute5              = p_po_line_locs_rec.global_attribute5 ,
    global_attribute6              = p_po_line_locs_rec.global_attribute6 ,
    global_attribute7              = p_po_line_locs_rec.global_attribute7 ,
    global_attribute8              = p_po_line_locs_rec.global_attribute8 ,
    global_attribute9              = p_po_line_locs_rec.global_attribute9 ,
    global_attribute10             = p_po_line_locs_rec.global_attribute10 ,
    global_attribute11             = p_po_line_locs_rec.global_attribute11 ,
    global_attribute12             = p_po_line_locs_rec.global_attribute12 ,
    global_attribute13             = p_po_line_locs_rec.global_attribute13 ,
    global_attribute14             = p_po_line_locs_rec.global_attribute14 ,
    global_attribute15             = p_po_line_locs_rec.global_attribute15 ,
    global_attribute16             = p_po_line_locs_rec.global_attribute16 ,
    global_attribute17             = p_po_line_locs_rec.global_attribute17 ,
    global_attribute18             = p_po_line_locs_rec.global_attribute18 ,
    global_attribute19             = p_po_line_locs_rec.global_attribute19 ,
    global_attribute20             = p_po_line_locs_rec.global_attribute20 ,
    global_attribute_category      = p_po_line_locs_rec.global_attribute_category ,
    quantity_shipped               = p_po_line_locs_rec.quantity_shipped ,
    country_of_origin_code         = p_po_line_locs_rec.country_of_origin_code ,
    tax_user_override_flag         = p_po_line_locs_rec.tax_user_override_flag ,
    /*match_flag                     = p_po_line_locs_rec.match_flag , */
    match_option                   = p_po_line_locs_rec.match_option ,
    tax_code_id                    = p_po_line_locs_rec.tax_code_id ,
    calculate_tax_flag             = p_po_line_locs_rec.calculate_tax_flag ,
    change_promised_date_reason    = p_po_line_locs_rec.change_promised_date_reason,
   --Bug 7110860 added the coloumn as it is not null
    outsourced_assembly            = p_po_line_locs_rec.outsourced_assembly
  WHERE
    line_location_id = p_po_line_locs_rec.line_location_id;


  IF (SQL%NOTFOUND)
  THEN
    RAISE NO_DATA_FOUND ;
  END IF;


  IF FND_API.To_Boolean ( p_commit )
  THEN
    COMMIT WORK;
  END IF;

  FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                    p_data  => x_msg_data );

EXCEPTION

  WHEN FND_API.G_EXC_ERROR
  THEN
    ROLLBACK TO Update_Row_Pvt ;
    x_return_status := FND_API.G_RET_STS_ERROR;

    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                            p_data  => x_msg_data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR
  THEN

    ROLLBACK TO Update_Row_Pvt ;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                            p_data  => x_msg_data );

  WHEN OTHERS
  THEN

    ROLLBACK TO Update_Row_Pvt ;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
                                                  l_api_name);
    END IF;

    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                            p_data  => x_msg_data );

END Update_Row;
/* ----------------------------------------------------------------------- */

END IGC_CC_PO_LINE_LOCS_ALL_PVT;

/
