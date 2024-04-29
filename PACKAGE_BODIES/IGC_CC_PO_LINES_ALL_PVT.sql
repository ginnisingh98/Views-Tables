--------------------------------------------------------
--  DDL for Package Body IGC_CC_PO_LINES_ALL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGC_CC_PO_LINES_ALL_PVT" AS
/*$Header: IGCCPLNB.pls 120.4.12000000.1 2007/08/20 12:14:14 mbremkum ship $*/

  G_PKG_NAME CONSTANT VARCHAR2(30):= 'IGC_CC_PO_LINES_ALL_PVT';

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
  p_po_lines_rec              IN       po_lines_all%ROWTYPE
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

	INSERT INTO po_lines_all (
	po_line_id,
	last_update_date,
	last_updated_by,
	po_header_id ,
	line_type_id,
        -- bug 4097669, start 1
        order_type_lookup_code,
        purchase_basis,
        matching_basis,
        -- bug 4097669, end 1
	line_num,
	last_update_login,
	creation_date,
	created_by,
	item_id,
	item_revision,
	category_id,
	item_description ,
	unit_meas_lookup_code,
	quantity_committed,
	committed_amount,
	allow_price_override_flag,
	not_to_exceed_price,
	list_price_per_unit,
	unit_price,
	quantity,
	un_number_id,
	hazard_class_id,
	note_to_vendor,
	from_header_id,
	from_line_id,
	min_order_quantity,
	max_order_quantity,
	qty_rcv_tolerance,
	over_tolerance_error_flag,
	market_price,
	unordered_flag,
	closed_flag,
	user_hold_flag ,
	cancel_flag,
	cancelled_by,
	cancel_date,
	cancel_reason ,
	firm_status_lookup_code,
	firm_date,
	vendor_product_num,
	contract_num,
	taxable_flag,
	tax_name,
	type_1099 ,
	capital_expense_flag,
	negotiated_by_preparer_flag,
	attribute_category,
	attribute1 ,
	attribute2 ,
	attribute3,
	attribute4 ,
	attribute5,
	attribute6,
	attribute7 ,
	attribute8,
	attribute9 ,
	attribute10,
	reference_num ,
	attribute11,
	attribute12,
	attribute13,
	attribute14 ,
	attribute15,
	min_release_amount,
	price_type_lookup_code,
	closed_code,
	price_break_lookup_code,
	ussgl_transaction_code,
	government_context,
	request_id,
	program_application_id,
	program_id ,
	program_update_date,
	closed_date,
	closed_reason,
	closed_by,
	transaction_reason_code,
	org_id,
	qc_grade,
	base_uom,
	base_qty,
	secondary_uom,
	secondary_qty,
	global_attribute_category,
	global_attribute1 ,
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
	line_reference_num,
	project_id,
	task_id,
	expiration_date,
	tax_code_id)
	VALUES
	(p_po_lines_rec.po_line_id,
	p_po_lines_rec.last_update_date,
	p_po_lines_rec.last_updated_by,
	p_po_lines_rec.po_header_id ,
	p_po_lines_rec.line_type_id,
        -- bug 4097669, start 2
        p_po_lines_rec.order_type_lookup_code,
        p_po_lines_rec.purchase_basis,
        p_po_lines_rec.matching_basis,
        -- bug 4097669, end 2
	p_po_lines_rec.line_num,
	p_po_lines_rec.last_update_login,
	p_po_lines_rec.creation_date,
	p_po_lines_rec.created_by,
	p_po_lines_rec.item_id,
	p_po_lines_rec.item_revision,
	p_po_lines_rec.category_id,
	p_po_lines_rec.item_description ,
	p_po_lines_rec.unit_meas_lookup_code,
	p_po_lines_rec.quantity_committed,
	p_po_lines_rec.committed_amount,
	p_po_lines_rec.allow_price_override_flag,
	p_po_lines_rec.not_to_exceed_price,
	p_po_lines_rec.list_price_per_unit,
	p_po_lines_rec.unit_price,
	p_po_lines_rec.quantity,
	p_po_lines_rec.un_number_id,
	p_po_lines_rec.hazard_class_id,
	p_po_lines_rec.note_to_vendor,
	p_po_lines_rec.from_header_id,
	p_po_lines_rec.from_line_id,
	p_po_lines_rec.min_order_quantity,
	p_po_lines_rec.max_order_quantity,
	p_po_lines_rec.qty_rcv_tolerance,
	p_po_lines_rec.over_tolerance_error_flag,
	p_po_lines_rec.market_price,
	p_po_lines_rec.unordered_flag,
	p_po_lines_rec.closed_flag,
	p_po_lines_rec.user_hold_flag ,
	p_po_lines_rec.cancel_flag,
	p_po_lines_rec.cancelled_by,
	p_po_lines_rec.cancel_date,
	p_po_lines_rec.cancel_reason ,
	p_po_lines_rec.firm_status_lookup_code,
	p_po_lines_rec.firm_date,
	p_po_lines_rec.vendor_product_num,
	p_po_lines_rec.contract_num,
	p_po_lines_rec.taxable_flag,
	p_po_lines_rec.tax_name,
	p_po_lines_rec.type_1099 ,
	p_po_lines_rec.capital_expense_flag,
	p_po_lines_rec.negotiated_by_preparer_flag,
	p_po_lines_rec.attribute_category,
	p_po_lines_rec.attribute1 ,
	p_po_lines_rec.attribute2 ,
	p_po_lines_rec.attribute3,
	p_po_lines_rec.attribute4 ,
	p_po_lines_rec.attribute5,
	p_po_lines_rec.attribute6,
	p_po_lines_rec.attribute7 ,
	p_po_lines_rec.attribute8,
	p_po_lines_rec.attribute9 ,
	p_po_lines_rec.attribute10,
	p_po_lines_rec.reference_num ,
	p_po_lines_rec.attribute11,
	p_po_lines_rec.attribute12,
	p_po_lines_rec.attribute13,
	p_po_lines_rec.attribute14 ,
	p_po_lines_rec.attribute15,
	p_po_lines_rec.min_release_amount,
	p_po_lines_rec.price_type_lookup_code,
	p_po_lines_rec.closed_code,
	p_po_lines_rec.price_break_lookup_code,
	p_po_lines_rec.ussgl_transaction_code,
	p_po_lines_rec.government_context,
	p_po_lines_rec.request_id,
	p_po_lines_rec.program_application_id,
	p_po_lines_rec.program_id ,
	p_po_lines_rec.program_update_date,
	p_po_lines_rec.closed_date,
	p_po_lines_rec.closed_reason,
	p_po_lines_rec.closed_by,
	p_po_lines_rec.transaction_reason_code,
	p_po_lines_rec.org_id,
	p_po_lines_rec.qc_grade,
	p_po_lines_rec.base_uom,
	p_po_lines_rec.base_qty,
	p_po_lines_rec.secondary_uom,
	p_po_lines_rec.secondary_qty,
	p_po_lines_rec.global_attribute_category,
	p_po_lines_rec.global_attribute1 ,
	p_po_lines_rec.global_attribute2,
	p_po_lines_rec.global_attribute3,
	p_po_lines_rec.global_attribute4,
	p_po_lines_rec.global_attribute5,
	p_po_lines_rec.global_attribute6,
	p_po_lines_rec.global_attribute7,
	p_po_lines_rec.global_attribute8,
	p_po_lines_rec.global_attribute9,
	p_po_lines_rec.global_attribute10,
	p_po_lines_rec.global_attribute11,
	p_po_lines_rec.global_attribute12,
	p_po_lines_rec.global_attribute13,
	p_po_lines_rec.global_attribute14,
	p_po_lines_rec.global_attribute15,
	p_po_lines_rec.global_attribute16,
	p_po_lines_rec.global_attribute17,
	p_po_lines_rec.global_attribute18,
	p_po_lines_rec.global_attribute19,
	p_po_lines_rec.global_attribute20,
	p_po_lines_rec.line_reference_num,
	p_po_lines_rec.project_id,
	p_po_lines_rec.task_id,
	p_po_lines_rec.expiration_date,
	p_po_lines_rec.tax_code_id);

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
  p_po_lines_rec              IN       po_lines_all%ROWTYPE

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

	UPDATE po_lines_all
        SET
		po_line_id                     = p_po_lines_rec.po_line_id,
		last_update_date               = p_po_lines_rec.last_update_date,
		last_updated_by                = p_po_lines_rec.last_updated_by,
		po_header_id                   = p_po_lines_rec.po_header_id ,
		line_type_id                   = p_po_lines_rec.line_type_id,
		line_num                       = p_po_lines_rec.line_num,
		last_update_login              = p_po_lines_rec.last_update_login,
		creation_date                  = p_po_lines_rec.creation_date,
		created_by                     = p_po_lines_rec.created_by,
		item_id                        = p_po_lines_rec.item_id,
		item_revision                  = p_po_lines_rec.item_revision,
		category_id                    = p_po_lines_rec.category_id,
		item_description               = p_po_lines_rec.item_description ,
		unit_meas_lookup_code          = p_po_lines_rec.unit_meas_lookup_code,
		quantity_committed             = p_po_lines_rec.quantity_committed,
		committed_amount               = p_po_lines_rec.committed_amount,
		allow_price_override_flag      = p_po_lines_rec.allow_price_override_flag,
		not_to_exceed_price            = p_po_lines_rec.not_to_exceed_price,
		list_price_per_unit            = p_po_lines_rec.list_price_per_unit,
		unit_price                     = p_po_lines_rec.unit_price,
		quantity                       = p_po_lines_rec.quantity,
		un_number_id                   = p_po_lines_rec.un_number_id,
		hazard_class_id                = p_po_lines_rec.hazard_class_id,
		note_to_vendor                 = p_po_lines_rec.note_to_vendor,
		from_header_id                 = p_po_lines_rec.from_header_id,
		from_line_id                   = p_po_lines_rec.from_line_id,
		min_order_quantity             = p_po_lines_rec.min_order_quantity,
		max_order_quantity             = p_po_lines_rec.max_order_quantity,
		qty_rcv_tolerance              = p_po_lines_rec.qty_rcv_tolerance,
		over_tolerance_error_flag      = p_po_lines_rec.over_tolerance_error_flag,
		market_price                   = p_po_lines_rec.market_price,
		unordered_flag                 = p_po_lines_rec.unordered_flag,
		closed_flag                    = p_po_lines_rec.closed_flag,
		user_hold_flag                 = p_po_lines_rec.user_hold_flag ,
		cancel_flag                    = p_po_lines_rec.cancel_flag,
		cancelled_by                   = p_po_lines_rec.cancelled_by,
		cancel_date                    = p_po_lines_rec.cancel_date,
		cancel_reason                  = p_po_lines_rec.cancel_reason ,
		firm_status_lookup_code        = p_po_lines_rec.firm_status_lookup_code,
		firm_date                      = p_po_lines_rec.firm_date,
		vendor_product_num             = p_po_lines_rec.vendor_product_num,
		contract_num                   = p_po_lines_rec.contract_num,
		taxable_flag                   = p_po_lines_rec.taxable_flag,
		tax_name                       = p_po_lines_rec.tax_name,
		type_1099                      = p_po_lines_rec.type_1099 ,
		capital_expense_flag           = p_po_lines_rec.capital_expense_flag,
		negotiated_by_preparer_flag    = p_po_lines_rec.negotiated_by_preparer_flag,
		attribute_category             = p_po_lines_rec.attribute_category,
		attribute1                     = p_po_lines_rec.attribute1 ,
		attribute2                     = p_po_lines_rec.attribute2 ,
		attribute3                     = p_po_lines_rec.attribute3,
		attribute4                     = p_po_lines_rec.attribute4 ,
		attribute5                     = p_po_lines_rec.attribute5,
		attribute6                     = p_po_lines_rec.attribute6,
		attribute7                     = p_po_lines_rec.attribute7 ,
		attribute8                     = p_po_lines_rec.attribute8,
		attribute9                     = p_po_lines_rec.attribute9 ,
		attribute10                    = p_po_lines_rec.attribute10,
		reference_num                  = p_po_lines_rec.reference_num ,
		attribute11                    = p_po_lines_rec.attribute11,
		attribute12                    = p_po_lines_rec.attribute12,
		attribute13                    = p_po_lines_rec.attribute13,
		attribute14                    = p_po_lines_rec.attribute14 ,
		attribute15                    = p_po_lines_rec.attribute15,
		min_release_amount             = p_po_lines_rec.min_release_amount,
		price_type_lookup_code         = p_po_lines_rec.price_type_lookup_code,
		closed_code                    = p_po_lines_rec.closed_code,
		price_break_lookup_code        = p_po_lines_rec.price_break_lookup_code,
		ussgl_transaction_code         = p_po_lines_rec.ussgl_transaction_code,
		government_context             = p_po_lines_rec.government_context,
		request_id                     = p_po_lines_rec.request_id,
		program_application_id         = p_po_lines_rec.program_application_id,
		program_id                     = p_po_lines_rec.program_id ,
		program_update_date            = p_po_lines_rec.program_update_date,
		closed_date                    = p_po_lines_rec.closed_date,
		closed_reason                  = p_po_lines_rec.closed_reason,
		closed_by                      = p_po_lines_rec.closed_by,
		transaction_reason_code        = p_po_lines_rec.transaction_reason_code,
		org_id                         = p_po_lines_rec.org_id,
		qc_grade                       = p_po_lines_rec.qc_grade,
		base_uom                       = p_po_lines_rec.base_uom,
		base_qty                       = p_po_lines_rec.base_qty,
		secondary_uom                  = p_po_lines_rec.secondary_uom,
		secondary_qty                  = p_po_lines_rec.secondary_qty,
		global_attribute_category      = p_po_lines_rec.global_attribute_category,
		global_attribute1              = p_po_lines_rec.global_attribute1 ,
		global_attribute2              = p_po_lines_rec.global_attribute2,
		global_attribute3              = p_po_lines_rec.global_attribute3,
		global_attribute4              = p_po_lines_rec.global_attribute4,
		global_attribute5              = p_po_lines_rec.global_attribute5,
		global_attribute6              = p_po_lines_rec.global_attribute6,
		global_attribute7              = p_po_lines_rec.global_attribute7,
		global_attribute8              = p_po_lines_rec.global_attribute8,
		global_attribute9              = p_po_lines_rec.global_attribute9,
		global_attribute10             = p_po_lines_rec.global_attribute10,
		global_attribute11             = p_po_lines_rec.global_attribute11,
		global_attribute12             = p_po_lines_rec.global_attribute12,
		global_attribute13             = p_po_lines_rec.global_attribute13,
		global_attribute14             = p_po_lines_rec.global_attribute14,
		global_attribute15             = p_po_lines_rec.global_attribute15,
		global_attribute16             = p_po_lines_rec.global_attribute16,
		global_attribute17             = p_po_lines_rec.global_attribute17,
		global_attribute18             = p_po_lines_rec.global_attribute18,
		global_attribute19             = p_po_lines_rec.global_attribute19,
		global_attribute20             = p_po_lines_rec.global_attribute20,
		line_reference_num             = p_po_lines_rec.line_reference_num,
		project_id                     = p_po_lines_rec.project_id,
		task_id                        = p_po_lines_rec.task_id,
		expiration_date                = p_po_lines_rec.expiration_date,
		tax_code_id                    = p_po_lines_rec.tax_code_id
	WHERE
		po_line_id = p_po_lines_rec.po_line_id;

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

END IGC_CC_PO_LINES_ALL_PVT;

/
