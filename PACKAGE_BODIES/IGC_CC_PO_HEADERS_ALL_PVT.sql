--------------------------------------------------------
--  DDL for Package Body IGC_CC_PO_HEADERS_ALL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGC_CC_PO_HEADERS_ALL_PVT" AS
/*$Header: IGCCPHDB.pls 120.3.12000000.2 2007/12/06 14:58:57 bmaddine ship $*/

  G_PKG_NAME CONSTANT VARCHAR2(30):= 'IGC_CC_PO_HEADERS_ALL_PVT';

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
  ----------------------------------------------
  p_po_headers_rec            IN       po_headers_all%ROWTYPE
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


	INSERT INTO po_headers_all (
 	po_header_id               ,
  	agent_id                   ,
  	type_lookup_code           ,
  	last_update_date           ,
  	last_updated_by            ,
  	segment1                   ,
  	summary_flag               ,
  	enabled_flag               ,
  	segment2                   ,
  	segment3                   ,
  	segment4                   ,
  	segment5                   ,
  	start_date_active          ,
  	end_date_active            ,
  	last_update_login          ,
  	creation_date              ,
  	created_by                 ,
  	vendor_id                  ,
  	vendor_site_id             ,
  	vendor_contact_id          ,
  	ship_to_location_id        ,
  	bill_to_location_id        ,
  	terms_id                   ,
  	ship_via_lookup_code       ,
  	fob_lookup_code            ,
  	freight_terms_lookup_code  ,
  	status_lookup_code         ,
  	currency_code              ,
  	rate_type                  ,
  	rate_date                  ,
  	rate                       ,
  	from_header_id             ,
  	from_type_lookup_code      ,
  	start_date                 ,
  	end_date                   ,
  	blanket_total_amount       ,
  	authorization_status       ,
  	revision_num               ,
  	revised_date               ,
  	approved_flag              ,
  	approved_date              ,
  	amount_limit               ,
 	min_release_amount         ,
  	note_to_authorizer         ,
  	note_to_vendor             ,
  	note_to_receiver           ,
  	print_count                ,
  	printed_date               ,
  	vendor_order_num           ,
  	confirming_order_flag      ,
  	comments                   ,
  	reply_date                 ,
  	reply_method_lookup_code   ,
  	rfq_close_date             ,
  	quote_type_lookup_code     ,
  	quotation_class_code       ,
  	quote_warning_delay_unit   ,
  	quote_warning_delay        ,
  	quote_vendor_quote_number  ,
  	acceptance_required_flag   ,
 	 acceptance_due_date        ,
  	closed_date                ,
  	user_hold_flag             ,
  	approval_required_flag     ,
  	cancel_flag                ,
        firm_status_lookup_code    ,
        firm_date                  ,
        frozen_flag                ,
        attribute_category         ,
        attribute1                 ,
        attribute2                 ,
        attribute3                 ,
        attribute4                 ,
        attribute5                 ,
        attribute6                 ,
        attribute7                 ,
        attribute8                 ,
        attribute9                 ,
        attribute10                ,
        attribute11                ,
        attribute12                ,
        attribute13                ,
        attribute14                ,
        attribute15                ,
        closed_code                ,
        ussgl_transaction_code     ,
        government_context         ,
        request_id                 ,
        program_application_id     ,
        program_id                 ,
        program_update_date        ,
        org_id                     ,
        supply_agreement_flag      ,
        edi_processed_flag         ,
        edi_processed_status       ,
        global_attribute_category  ,
        global_attribute1          ,
        global_attribute2          ,
        global_attribute3          ,
        global_attribute4          ,
        global_attribute5          ,
        global_attribute6          ,
        global_attribute7          ,
        global_attribute8          ,
        global_attribute9          ,
        global_attribute10         ,
        global_attribute11         ,
        global_attribute12         ,
        global_attribute13         ,
        global_attribute14         ,
        global_attribute15         ,
        global_attribute16         ,
        global_attribute17         ,
        global_attribute18         ,
        global_attribute19         ,
        global_attribute20         ,
        interface_source_code      ,
        reference_num              ,
        wf_item_type               ,
        wf_item_key                ,
        mrc_rate_type              ,
        mrc_rate_date              ,
        mrc_rate                   ,
        pcard_id                   ,
        price_update_tolerance     ,
        pay_on_code                ,
	style_id		   )
      VALUES
       (
        p_po_headers_rec.po_header_id               ,
        p_po_headers_rec.agent_id                   ,
        p_po_headers_rec.type_lookup_code           ,
        p_po_headers_rec.last_update_date           ,
        p_po_headers_rec.last_updated_by            ,
        p_po_headers_rec.segment1                   ,
        p_po_headers_rec.summary_flag               ,
        p_po_headers_rec.enabled_flag               ,
        p_po_headers_rec.segment2                   ,
        p_po_headers_rec.segment3                   ,
        p_po_headers_rec.segment4                   ,
        p_po_headers_rec.segment5                   ,
        p_po_headers_rec.start_date_active          ,
        p_po_headers_rec.end_date_active            ,
        p_po_headers_rec.last_update_login          ,
        p_po_headers_rec.creation_date              ,
        p_po_headers_rec.created_by                 ,
        p_po_headers_rec.vendor_id                  ,
        p_po_headers_rec.vendor_site_id             ,
        p_po_headers_rec.vendor_contact_id          ,
        p_po_headers_rec.ship_to_location_id        ,
        p_po_headers_rec.bill_to_location_id        ,
        p_po_headers_rec.terms_id                   ,
        p_po_headers_rec.ship_via_lookup_code       ,
        p_po_headers_rec.fob_lookup_code            ,
        p_po_headers_rec.freight_terms_lookup_code  ,
        p_po_headers_rec.status_lookup_code         ,
        p_po_headers_rec.currency_code              ,
        p_po_headers_rec.rate_type                  ,
        p_po_headers_rec.rate_date                  ,
        p_po_headers_rec.rate                       ,
        p_po_headers_rec.from_header_id             ,
        p_po_headers_rec.from_type_lookup_code      ,
        p_po_headers_rec.start_date                 ,
        p_po_headers_rec.end_date                   ,
        p_po_headers_rec.blanket_total_amount       ,
        p_po_headers_rec.authorization_status       ,
        p_po_headers_rec.revision_num               ,
        p_po_headers_rec.revised_date               ,
        p_po_headers_rec.approved_flag              ,
        p_po_headers_rec.approved_date              ,
        p_po_headers_rec.amount_limit               ,
        p_po_headers_rec.min_release_amount         ,
        p_po_headers_rec.note_to_authorizer         ,
        p_po_headers_rec.note_to_vendor             ,
        p_po_headers_rec.note_to_receiver           ,
        p_po_headers_rec.print_count                ,
        p_po_headers_rec.printed_date               ,
        p_po_headers_rec.vendor_order_num           ,
        p_po_headers_rec.confirming_order_flag      ,
        p_po_headers_rec.comments                   ,
        p_po_headers_rec.reply_date                 ,
        p_po_headers_rec.reply_method_lookup_code   ,
        p_po_headers_rec.rfq_close_date             ,
        p_po_headers_rec.quote_type_lookup_code     ,
        p_po_headers_rec.quotation_class_code       ,
        p_po_headers_rec.quote_warning_delay_unit   ,
        p_po_headers_rec.quote_warning_delay        ,
        p_po_headers_rec.quote_vendor_quote_number  ,
        p_po_headers_rec.acceptance_required_flag   ,
        p_po_headers_rec.acceptance_due_date        ,
        p_po_headers_rec.closed_date                ,
        p_po_headers_rec.user_hold_flag             ,
        p_po_headers_rec.approval_required_flag     ,
        p_po_headers_rec.cancel_flag                ,
        p_po_headers_rec.firm_status_lookup_code    ,
        p_po_headers_rec.firm_date                  ,
        p_po_headers_rec.frozen_flag                ,
        p_po_headers_rec.attribute_category         ,
        p_po_headers_rec.attribute1                 ,
        p_po_headers_rec.attribute2                 ,
        p_po_headers_rec.attribute3                 ,
        p_po_headers_rec.attribute4                 ,
        p_po_headers_rec.attribute5                 ,
        p_po_headers_rec.attribute6                 ,
        p_po_headers_rec.attribute7                 ,
        p_po_headers_rec.attribute8                 ,
        p_po_headers_rec.attribute9                 ,
        p_po_headers_rec.attribute10                ,
        p_po_headers_rec.attribute11                ,
        p_po_headers_rec.attribute12                ,
        p_po_headers_rec.attribute13                ,
        p_po_headers_rec.attribute14                ,
        p_po_headers_rec.attribute15                ,
        p_po_headers_rec.closed_code                ,
        p_po_headers_rec.ussgl_transaction_code     ,
        p_po_headers_rec.government_context         ,
        p_po_headers_rec.request_id                 ,
        p_po_headers_rec.program_application_id     ,
        p_po_headers_rec.program_id                 ,
        p_po_headers_rec.program_update_date        ,
        p_po_headers_rec.org_id                     ,
        p_po_headers_rec.supply_agreement_flag      ,
        p_po_headers_rec.edi_processed_flag         ,
        p_po_headers_rec.edi_processed_status       ,
        p_po_headers_rec.global_attribute_category  ,
        p_po_headers_rec.global_attribute1          ,
        p_po_headers_rec.global_attribute2          ,
        p_po_headers_rec.global_attribute3          ,
        p_po_headers_rec.global_attribute4          ,
        p_po_headers_rec.global_attribute5          ,
        p_po_headers_rec.global_attribute6          ,
        p_po_headers_rec.global_attribute7          ,
        p_po_headers_rec.global_attribute8          ,
        p_po_headers_rec.global_attribute9          ,
        p_po_headers_rec.global_attribute10         ,
        p_po_headers_rec.global_attribute11         ,
        p_po_headers_rec.global_attribute12         ,
        p_po_headers_rec.global_attribute13         ,
        p_po_headers_rec.global_attribute14         ,
        p_po_headers_rec.global_attribute15         ,
        p_po_headers_rec.global_attribute16         ,
        p_po_headers_rec.global_attribute17         ,
        p_po_headers_rec.global_attribute18         ,
        p_po_headers_rec.global_attribute19         ,
        p_po_headers_rec.global_attribute20         ,
        p_po_headers_rec.interface_source_code      ,
        p_po_headers_rec.reference_num              ,
        p_po_headers_rec.wf_item_type               ,
        p_po_headers_rec.wf_item_key                ,
        p_po_headers_rec.mrc_rate_type              ,
        p_po_headers_rec.mrc_rate_date              ,
        p_po_headers_rec.mrc_rate                   ,
        p_po_headers_rec.pcard_id                   ,
        p_po_headers_rec.price_update_tolerance     ,
        p_po_headers_rec.pay_on_code		    ,
	1
	);

  	IF FND_API.To_Boolean ( p_commit )
	THEN
    		COMMIT WORK;
  	END iF;

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
---------------------------------------------------
  p_po_headers_rec            IN       po_headers_all%ROWTYPE
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

	UPDATE PO_HEADERS_ALL
	SET
		po_header_id               = p_po_headers_rec.po_header_id,
		agent_id                   = p_po_headers_rec.agent_id,
		type_lookup_code           = p_po_headers_rec.type_lookup_code,
		last_update_date           = p_po_headers_rec.last_update_date,
		last_updated_by            = p_po_headers_rec.last_updated_by,
		segment1                   = p_po_headers_rec.segment1,
		summary_flag               = p_po_headers_rec.summary_flag,
		enabled_flag               = p_po_headers_rec.enabled_flag,
		segment2                   = p_po_headers_rec.segment2,
		segment3                   = p_po_headers_rec.segment3,
		segment4                   = p_po_headers_rec.segment4,
		segment5                   = p_po_headers_rec.segment5,
		start_date_active          = p_po_headers_rec.start_date_active,
		end_date_active            = p_po_headers_rec.end_date_active,
		last_update_login          = p_po_headers_rec.last_update_login,
		creation_date              = p_po_headers_rec.creation_date,
		created_by                 = p_po_headers_rec.created_by,
		vendor_id                  = p_po_headers_rec.vendor_id,
		vendor_site_id             = p_po_headers_rec.vendor_site_id,
		vendor_contact_id          = p_po_headers_rec.vendor_contact_id,
		ship_to_location_id        = p_po_headers_rec.ship_to_location_id,
		bill_to_location_id        = p_po_headers_rec.bill_to_location_id,
		terms_id                   = p_po_headers_rec.terms_id,
		ship_via_lookup_code       = p_po_headers_rec.ship_via_lookup_code,
		fob_lookup_code            = p_po_headers_rec.fob_lookup_code,
		freight_terms_lookup_code  = p_po_headers_rec.freight_terms_lookup_code,
		status_lookup_code         = p_po_headers_rec.status_lookup_code,
		currency_code              = p_po_headers_rec.currency_code,
		rate_type                  = p_po_headers_rec.rate_type,
		rate_date                  = p_po_headers_rec.rate_date,
		rate                       = p_po_headers_rec.rate,
		from_header_id             = p_po_headers_rec.from_header_id,
		from_type_lookup_code      = p_po_headers_rec.from_type_lookup_code,
		start_date                 = p_po_headers_rec.start_date,
		end_date                   = p_po_headers_rec.end_date,
		blanket_total_amount       = p_po_headers_rec.blanket_total_amount,
		authorization_status       = p_po_headers_rec.authorization_status,
		revision_num               = p_po_headers_rec.revision_num,
		revised_date               = p_po_headers_rec.revised_date,
		approved_flag              = p_po_headers_rec.approved_flag,
		approved_date              = p_po_headers_rec.approved_date,
		amount_limit               = p_po_headers_rec.amount_limit,
		min_release_amount         = p_po_headers_rec.min_release_amount,
		note_to_authorizer         = p_po_headers_rec.note_to_authorizer,
		note_to_vendor             = p_po_headers_rec.note_to_vendor,
		note_to_receiver           = p_po_headers_rec.note_to_receiver,
		print_count                = p_po_headers_rec.print_count,
		printed_date               = p_po_headers_rec.printed_date,
		vendor_order_num           = p_po_headers_rec.vendor_order_num,
		confirming_order_flag      = p_po_headers_rec.confirming_order_flag,
		comments                   = p_po_headers_rec.comments,
		reply_date                 = p_po_headers_rec.reply_date,
		reply_method_lookup_code   = p_po_headers_rec.reply_method_lookup_code,
		rfq_close_date             = p_po_headers_rec.rfq_close_date,
		quote_type_lookup_code     = p_po_headers_rec.quote_type_lookup_code,
		quotation_class_code       = p_po_headers_rec.quotation_class_code,
		quote_warning_delay_unit   = p_po_headers_rec.quote_warning_delay_unit,
		quote_warning_delay        = p_po_headers_rec.quote_warning_delay,
		quote_vendor_quote_number  = p_po_headers_rec.quote_vendor_quote_number,
		acceptance_required_flag   = p_po_headers_rec.acceptance_required_flag,
		acceptance_due_date        = p_po_headers_rec.acceptance_due_date,
		closed_date                = p_po_headers_rec.closed_date,
		user_hold_flag             = p_po_headers_rec.user_hold_flag,
		approval_required_flag     = p_po_headers_rec.approval_required_flag,
		cancel_flag                = p_po_headers_rec.cancel_flag,
		firm_status_lookup_code    = p_po_headers_rec.firm_status_lookup_code,
		firm_date                  = p_po_headers_rec.firm_date,
		frozen_flag                = p_po_headers_rec.frozen_flag,
		attribute_category         = p_po_headers_rec.attribute_category,
		attribute1                 = p_po_headers_rec.attribute1,
		attribute2                 = p_po_headers_rec.attribute2,
		attribute3                 = p_po_headers_rec.attribute3,
		attribute4                 = p_po_headers_rec.attribute4,
		attribute5                 = p_po_headers_rec.attribute5,
		attribute6                 = p_po_headers_rec.attribute6,
		attribute7                 = p_po_headers_rec.attribute7,
		attribute8                 = p_po_headers_rec.attribute8,
		attribute9                 = p_po_headers_rec.attribute9,
		attribute10                = p_po_headers_rec.attribute10,
		attribute11                = p_po_headers_rec.attribute11,
		attribute12                = p_po_headers_rec.attribute12,
		attribute13                = p_po_headers_rec.attribute13,
		attribute14                = p_po_headers_rec.attribute14,
		attribute15                = p_po_headers_rec.attribute15,
		closed_code                = p_po_headers_rec.closed_code,
		ussgl_transaction_code     = p_po_headers_rec.ussgl_transaction_code,
		government_context         = p_po_headers_rec.government_context,
		request_id                 = p_po_headers_rec.request_id,
		program_application_id     = p_po_headers_rec.program_application_id,
		program_id                 = p_po_headers_rec.program_id,
		program_update_date        = p_po_headers_rec.program_update_date,
		org_id                     = p_po_headers_rec.org_id,
		supply_agreement_flag      = p_po_headers_rec.supply_agreement_flag,
		edi_processed_flag         = p_po_headers_rec.edi_processed_flag,
		edi_processed_status       = p_po_headers_rec.edi_processed_status,
		global_attribute_category  = p_po_headers_rec.global_attribute_category,
		global_attribute1          = p_po_headers_rec.global_attribute1,
		global_attribute2          = p_po_headers_rec.global_attribute2,
		global_attribute3          = p_po_headers_rec.global_attribute3,
		global_attribute4          = p_po_headers_rec.global_attribute4,
		global_attribute5          = p_po_headers_rec.global_attribute5,
		global_attribute6          = p_po_headers_rec.global_attribute6,
		global_attribute7          = p_po_headers_rec.global_attribute7,
		global_attribute8          = p_po_headers_rec.global_attribute8,
		global_attribute9          = p_po_headers_rec.global_attribute9,
		global_attribute10         = p_po_headers_rec.global_attribute10,
		global_attribute11         = p_po_headers_rec.global_attribute11,
		global_attribute12         = p_po_headers_rec.global_attribute12,
		global_attribute13         = p_po_headers_rec.global_attribute13,
		global_attribute14         = p_po_headers_rec.global_attribute14,
		global_attribute15         = p_po_headers_rec.global_attribute15,
		global_attribute16         = p_po_headers_rec.global_attribute16,
		global_attribute17         = p_po_headers_rec.global_attribute17,
		global_attribute18         = p_po_headers_rec.global_attribute18,
		global_attribute19         = p_po_headers_rec.global_attribute19,
		global_attribute20         = p_po_headers_rec.global_attribute20,
		interface_source_code      = p_po_headers_rec.interface_source_code,
		reference_num              = p_po_headers_rec.reference_num ,
		wf_item_type               = p_po_headers_rec.wf_item_type,
		wf_item_key                = p_po_headers_rec.wf_item_key,
		mrc_rate_type              = p_po_headers_rec.mrc_rate_type,
		mrc_rate_date              = p_po_headers_rec.mrc_rate_date,
		mrc_rate                   = p_po_headers_rec.mrc_rate,
		pcard_id                   = p_po_headers_rec.pcard_id,
		price_update_tolerance     = p_po_headers_rec.price_update_tolerance,
		pay_on_code                = p_po_headers_rec.pay_on_code
	WHERE
		po_header_id = p_po_headers_rec.po_header_id;


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

END IGC_CC_PO_HEADERS_ALL_PVT;

/
