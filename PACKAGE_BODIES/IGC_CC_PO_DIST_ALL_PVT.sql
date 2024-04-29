--------------------------------------------------------
--  DDL for Package Body IGC_CC_PO_DIST_ALL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGC_CC_PO_DIST_ALL_PVT" AS
/*$Header: IGCCPDTB.pls 120.4.12010000.2 2008/12/11 09:10:08 gaprasad ship $*/

  G_PKG_NAME CONSTANT VARCHAR2(30):= 'IGC_CC_PO_DIST_ALL_PVT';

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
  p_po_dist_rec               IN       po_distributions_all%ROWTYPE
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


        -- Added column distribution_type when inserting in
        -- po_distributions_all. This as as part of the
        -- changes PO have done in PRC.FP.J (3173178)
        -- PO Standalone patch 3205071 is a pre-req for this change
        -- Bidisha S, 23 Oct 2003
	INSERT INTO po_distributions_all (
	po_distribution_id,
	last_update_date,
	last_updated_by,
	po_header_id,
	po_line_id,
	line_location_id ,
	set_of_books_id ,
	code_combination_id,
	quantity_ordered,
	last_update_login,
	creation_date,
	created_by,
	po_release_id ,
	quantity_delivered,
	quantity_billed,
	quantity_cancelled ,
	req_header_reference_num ,
	req_line_reference_num ,
	req_distribution_id,
	deliver_to_location_id ,
	deliver_to_person_id ,
	rate_date ,
	rate,
	amount_billed ,
	accrued_flag ,
	encumbered_flag ,
	encumbered_amount ,
	unencumbered_quantity ,
	unencumbered_amount ,
	failed_funds_lookup_code ,
	gl_encumbered_date ,
	gl_encumbered_period_name ,
	gl_cancelled_date ,
	destination_type_code ,
	destination_organization_id ,
	destination_subinventory ,
	attribute_category ,
	attribute1 ,
	attribute2 ,
	attribute3 ,
	attribute4 ,
	attribute5 ,
	attribute6 ,
	attribute7 ,
	attribute8 ,
	attribute9  ,
	attribute10 ,
	attribute11 ,
	attribute12 ,
	attribute13 ,
	attribute14 ,
	attribute15 ,
	wip_entity_id ,
	wip_operation_seq_num ,
	wip_resource_seq_num ,
	wip_repetitive_schedule_id ,
	wip_line_id ,
	bom_resource_id ,
	budget_account_id ,
	accrual_account_id ,
	variance_account_id ,
	prevent_encumbrance_flag ,
	ussgl_transaction_code ,
	government_context  ,
	destination_context ,
	distribution_num  ,
	source_distribution_id ,
	request_id ,
	program_application_id ,
	program_id ,
	program_update_date ,
	project_id ,
	task_id ,
	expenditure_type ,
	project_accounting_context ,
	expenditure_organization_id ,
	gl_closed_date  ,
	accrue_on_receipt_flag  ,
	expenditure_item_date  ,
	org_id  ,
	kanban_card_id  ,
	award_id  ,
	mrc_rate_date  ,
	mrc_rate  ,
	mrc_encumbered_amount  ,
	mrc_unencumbered_amount  ,
	end_item_unit_number ,
	recoverable_tax  ,
	nonrecoverable_tax  ,
	recovery_rate ,
	tax_recovery_override_flag  ,
        distribution_type
        /*,
	base_amount_billed  ,
	tax_recovery_rate  ,
	mrc_base_amount_billed*/)
	VALUES
	(
	p_po_dist_rec.po_distribution_id,
	p_po_dist_rec.last_update_date,
	p_po_dist_rec.last_updated_by,
	p_po_dist_rec.po_header_id,
	p_po_dist_rec.po_line_id,
	p_po_dist_rec.line_location_id ,
	p_po_dist_rec.set_of_books_id ,
	p_po_dist_rec.code_combination_id,
	p_po_dist_rec.quantity_ordered,
	p_po_dist_rec.last_update_login,
	p_po_dist_rec.creation_date,
	p_po_dist_rec.created_by,
	p_po_dist_rec.po_release_id ,
	p_po_dist_rec.quantity_delivered,
	p_po_dist_rec.quantity_billed,
	p_po_dist_rec.quantity_cancelled ,
	p_po_dist_rec.req_header_reference_num ,
	p_po_dist_rec.req_line_reference_num ,
	p_po_dist_rec.req_distribution_id,
	p_po_dist_rec.deliver_to_location_id ,
	p_po_dist_rec.deliver_to_person_id ,
	p_po_dist_rec.rate_date ,
	p_po_dist_rec.rate,
	p_po_dist_rec.amount_billed ,
	p_po_dist_rec.accrued_flag ,
	p_po_dist_rec.encumbered_flag ,
	p_po_dist_rec.encumbered_amount ,
	p_po_dist_rec.unencumbered_quantity ,
	p_po_dist_rec.unencumbered_amount ,
	p_po_dist_rec.failed_funds_lookup_code ,
	p_po_dist_rec.gl_encumbered_date ,
	p_po_dist_rec.gl_encumbered_period_name ,
	p_po_dist_rec.gl_cancelled_date ,
	p_po_dist_rec.destination_type_code ,
	p_po_dist_rec.destination_organization_id ,
	p_po_dist_rec.destination_subinventory ,
	p_po_dist_rec.attribute_category ,
	p_po_dist_rec.attribute1 ,
	p_po_dist_rec.attribute2 ,
	p_po_dist_rec.attribute3 ,
	p_po_dist_rec.attribute4 ,
	p_po_dist_rec.attribute5 ,
	p_po_dist_rec.attribute6 ,
	p_po_dist_rec.attribute7 ,
	p_po_dist_rec.attribute8 ,
	p_po_dist_rec.attribute9  ,
	p_po_dist_rec.attribute10 ,
	p_po_dist_rec.attribute11 ,
	p_po_dist_rec.attribute12 ,
	p_po_dist_rec.attribute13 ,
	p_po_dist_rec.attribute14 ,
	p_po_dist_rec.attribute15 ,
	p_po_dist_rec.wip_entity_id ,
	p_po_dist_rec.wip_operation_seq_num ,
	p_po_dist_rec.wip_resource_seq_num ,
	p_po_dist_rec.wip_repetitive_schedule_id ,
	p_po_dist_rec.wip_line_id ,
	p_po_dist_rec.bom_resource_id ,
	p_po_dist_rec.budget_account_id ,
	p_po_dist_rec.accrual_account_id ,
	p_po_dist_rec.variance_account_id ,
	p_po_dist_rec.prevent_encumbrance_flag ,
	p_po_dist_rec.ussgl_transaction_code ,
	p_po_dist_rec.government_context  ,
	p_po_dist_rec.destination_context ,
	p_po_dist_rec.distribution_num  ,
	p_po_dist_rec.source_distribution_id ,
	p_po_dist_rec.request_id ,
	p_po_dist_rec.program_application_id ,
	p_po_dist_rec.program_id ,
	p_po_dist_rec.program_update_date ,
	p_po_dist_rec.project_id ,
	p_po_dist_rec.task_id ,
	p_po_dist_rec.expenditure_type ,
	p_po_dist_rec.project_accounting_context ,
	p_po_dist_rec.expenditure_organization_id ,
	p_po_dist_rec.gl_closed_date,
	p_po_dist_rec.accrue_on_receipt_flag  ,
	p_po_dist_rec.expenditure_item_date  ,
	p_po_dist_rec.org_id  ,
	p_po_dist_rec.kanban_card_id  ,
	p_po_dist_rec.award_id  ,
	p_po_dist_rec.mrc_rate_date  ,
	p_po_dist_rec.mrc_rate  ,
	p_po_dist_rec.mrc_encumbered_amount  ,
	p_po_dist_rec.mrc_unencumbered_amount  ,
	p_po_dist_rec.end_item_unit_number ,
	p_po_dist_rec.recoverable_tax  ,
	p_po_dist_rec.nonrecoverable_tax  ,
	p_po_dist_rec.recovery_rate ,
	p_po_dist_rec.tax_recovery_override_flag ,
        p_po_dist_rec.distribution_type/* ,
	p_po_dist_rec.base_amount_billed  ,
	p_po_dist_rec.tax_recovery_rate  ,
	p_po_dist_rec.mrc_base_amount_billed*/);

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
  p_po_dist_rec               IN       po_distributions_all%ROWTYPE

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
	UPDATE po_distributions_all
        SET
		last_update_date                    = p_po_dist_rec.last_update_date,
		last_updated_by                     = p_po_dist_rec.last_updated_by,
		po_header_id                        = p_po_dist_rec.po_header_id,
		po_line_id                          = p_po_dist_rec.po_line_id,
		line_location_id                    = p_po_dist_rec.line_location_id ,
		set_of_books_id                     = p_po_dist_rec.set_of_books_id ,
		code_combination_id                 = p_po_dist_rec.code_combination_id,
		quantity_ordered                    = p_po_dist_rec.quantity_ordered,
		last_update_login                   = p_po_dist_rec.last_update_login,
		creation_date                       = p_po_dist_rec.creation_date,
		created_by                          = p_po_dist_rec.created_by,
		po_release_id                       = p_po_dist_rec.po_release_id ,
		quantity_delivered                  = p_po_dist_rec.quantity_delivered,
		quantity_billed                     = p_po_dist_rec.quantity_billed,
		quantity_cancelled                  = p_po_dist_rec.quantity_cancelled ,
		req_header_reference_num            = p_po_dist_rec.req_header_reference_num ,
		req_line_reference_num              = p_po_dist_rec.req_line_reference_num ,
		req_distribution_id                 = p_po_dist_rec.req_distribution_id,
		deliver_to_location_id              = p_po_dist_rec.deliver_to_location_id ,
		deliver_to_person_id                = p_po_dist_rec.deliver_to_person_id ,
		rate_date                           = p_po_dist_rec.rate_date ,
		rate                                = p_po_dist_rec.rate,
		amount_billed                       = p_po_dist_rec.amount_billed ,
		accrued_flag                        = p_po_dist_rec.accrued_flag ,
		encumbered_flag                     = p_po_dist_rec.encumbered_flag ,
		encumbered_amount                   = p_po_dist_rec.encumbered_amount ,
		unencumbered_quantity               = p_po_dist_rec.unencumbered_quantity ,
		unencumbered_amount                 = p_po_dist_rec.unencumbered_amount ,
		failed_funds_lookup_code            = p_po_dist_rec.failed_funds_lookup_code ,
		gl_encumbered_date                  = p_po_dist_rec.gl_encumbered_date ,
		gl_encumbered_period_name           = p_po_dist_rec.gl_encumbered_period_name ,
		gl_cancelled_date                   = p_po_dist_rec.gl_cancelled_date ,
		destination_type_code               = p_po_dist_rec.destination_type_code ,
		destination_organization_id         = p_po_dist_rec.destination_organization_id ,
		destination_subinventory            = p_po_dist_rec.destination_subinventory ,
		attribute_category                  = p_po_dist_rec.attribute_category ,
		attribute1                          = p_po_dist_rec.attribute1 ,
		attribute2                          = p_po_dist_rec.attribute2 ,
		attribute3                          = p_po_dist_rec.attribute3 ,
		attribute4                          = p_po_dist_rec.attribute4 ,
		attribute5                          = p_po_dist_rec.attribute5 ,
		attribute6                          = p_po_dist_rec.attribute6 ,
		attribute7                          = p_po_dist_rec.attribute7 ,
		attribute8                          = p_po_dist_rec.attribute8 ,
		attribute9                          = p_po_dist_rec.attribute9  ,
		attribute10                         = p_po_dist_rec.attribute10 ,
		attribute11                         = p_po_dist_rec.attribute11 ,
		attribute12                         = p_po_dist_rec.attribute12 ,
		attribute13                         = p_po_dist_rec.attribute13 ,
		attribute14                         = p_po_dist_rec.attribute14 ,
		attribute15                         = p_po_dist_rec.attribute15 ,
		wip_entity_id                       = p_po_dist_rec.wip_entity_id ,
		wip_operation_seq_num               = p_po_dist_rec.wip_operation_seq_num ,
		wip_resource_seq_num                = p_po_dist_rec.wip_resource_seq_num ,
		wip_repetitive_schedule_id          = p_po_dist_rec.wip_repetitive_schedule_id ,
		wip_line_id                         = p_po_dist_rec.wip_line_id ,
		bom_resource_id                     = p_po_dist_rec.bom_resource_id ,
		budget_account_id                   = p_po_dist_rec.budget_account_id ,
		accrual_account_id                  = p_po_dist_rec.accrual_account_id ,
		variance_account_id                 = p_po_dist_rec.variance_account_id ,
		prevent_encumbrance_flag            = p_po_dist_rec.prevent_encumbrance_flag ,
		ussgl_transaction_code              = p_po_dist_rec.ussgl_transaction_code ,
		government_context                  = p_po_dist_rec.government_context  ,
		destination_context                 = p_po_dist_rec.destination_context ,
		distribution_num                    = p_po_dist_rec.distribution_num  ,
		source_distribution_id              = p_po_dist_rec.source_distribution_id ,
		request_id                          = p_po_dist_rec.request_id ,
		program_application_id              = p_po_dist_rec.program_application_id ,
		program_id                          = p_po_dist_rec.program_id ,
		program_update_date                 = p_po_dist_rec.program_update_date ,
		project_id                          = p_po_dist_rec.project_id ,
		task_id                             = p_po_dist_rec.task_id ,
		expenditure_type                    = p_po_dist_rec.expenditure_type ,
		project_accounting_context          = p_po_dist_rec.project_accounting_context ,
		expenditure_organization_id         = p_po_dist_rec.expenditure_organization_id ,
		gl_closed_date                      = p_po_dist_rec.gl_closed_date  ,
		accrue_on_receipt_flag              = p_po_dist_rec.accrue_on_receipt_flag  ,
		expenditure_item_date               = p_po_dist_rec.expenditure_item_date  ,
		org_id                              = p_po_dist_rec.org_id  ,
		kanban_card_id                      = p_po_dist_rec.kanban_card_id  ,
		award_id                            = p_po_dist_rec.award_id  ,
		mrc_rate_date                       = p_po_dist_rec.mrc_rate_date  ,
		mrc_rate                            = p_po_dist_rec.mrc_rate  ,
		mrc_encumbered_amount               = p_po_dist_rec.mrc_encumbered_amount  ,
		mrc_unencumbered_amount             = p_po_dist_rec.mrc_unencumbered_amount  ,
		end_item_unit_number                = p_po_dist_rec.end_item_unit_number ,
		recoverable_tax                     = p_po_dist_rec.recoverable_tax  ,
		nonrecoverable_tax                  = p_po_dist_rec.nonrecoverable_tax  ,
		recovery_rate                       = p_po_dist_rec.recovery_rate ,
		tax_recovery_override_flag          = p_po_dist_rec.tax_recovery_override_flag  /*,
		base_amount_billed                  = p_po_dist_rec.base_amount_billed  ,
		tax_recovery_rate                   = p_po_dist_rec.tax_recovery_rate  ,
		mrc_base_amount_billed              = p_po_dist_rec.mrc_base_amount_billed*/
	WHERE
		po_distribution_id = p_po_dist_rec.po_distribution_id;


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

/*ADDED DELETE PROCEDURE FOR BUG 7492389 */

/*==========================================================================+
 |                       PROCEDURE Delete_Row                               |
 +==========================================================================*/
PROCEDURE Delete_Row
(
  p_api_version               IN       NUMBER,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status             OUT NOCOPY      VARCHAR2,
  x_msg_count                 OUT NOCOPY      NUMBER,
  x_msg_data                  OUT NOCOPY      VARCHAR2,
  ---------------------------------------------
  p_po_distribution_id        IN       po_distributions_all.po_distribution_id%TYPE
)
IS

	l_api_name            CONSTANT VARCHAR2(30)   := 'Delete_Row';
	l_api_version         CONSTANT NUMBER         :=  1.0;

BEGIN

	SAVEPOINT Delete_Row_Pvt ;

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

	DELETE FROM po_distributions_all
      WHERE
      po_distribution_id = p_po_distribution_id;


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
		ROLLBACK TO Delete_Row_Pvt ;
		x_return_status := FND_API.G_RET_STS_ERROR;

		FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                            p_data  => x_msg_data );

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR
	THEN

		ROLLBACK TO Delete_Row_Pvt ;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                            p_data  => x_msg_data );

	WHEN OTHERS
	THEN

		ROLLBACK TO Delete_Row_Pvt ;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

		IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
			FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
                                                  l_api_name);
		END IF;

		FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                            p_data  => x_msg_data );

END Delete_Row;

/* ----------------------------------------------------------------------- */

END IGC_CC_PO_DIST_ALL_PVT;

/
