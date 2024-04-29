--------------------------------------------------------
--  DDL for Package AR_BILLS_CREATION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_BILLS_CREATION_PUB" AUTHID CURRENT_USER AS
/* $Header: ARBRCRES.pls 120.7 2006/02/16 12:30:00 ggadhams ship $ */


PROCEDURE Create_BR_Header (

           --   *****  Standard API parameters *****
                p_api_version      		IN  NUMBER			,
                p_init_msg_list    		IN  VARCHAR2 := FND_API.G_TRUE	,
                p_commit           		IN  VARCHAR2 := FND_API.G_FALSE	,
                p_validation_level 		IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                x_return_status    		OUT NOCOPY VARCHAR2			,
                x_msg_count        		OUT NOCOPY NUMBER			,
                x_msg_data         		OUT NOCOPY VARCHAR2			,

           --   *****  BR Header information parameters *****
		p_trx_number			IN  VARCHAR2	DEFAULT NULL	,
		p_term_due_date			IN  DATE	DEFAULT NULL	,
		p_batch_source_id		IN  NUMBER	DEFAULT NULL	,
		p_cust_trx_type_id		IN  NUMBER	DEFAULT NULL	,
		p_invoice_currency_code 	IN  VARCHAR2	DEFAULT NULL	,
		p_br_amount			IN  NUMBER	DEFAULT NULL	,
		p_trx_date			IN  DATE	DEFAULT NULL	,
		p_gl_date			IN  DATE	DEFAULT NULL	,
		p_drawee_id			IN  NUMBER	DEFAULT NULL	,
		p_drawee_site_use_id		IN  NUMBER	DEFAULT NULL	,
		p_drawee_contact_id		IN  NUMBER	DEFAULT NULL	,
		p_printing_option		IN  VARCHAR2	DEFAULT NULL	,
		p_comments			IN  VARCHAR2	DEFAULT NULL	,
		p_special_instructions		IN  VARCHAR2	DEFAULT NULL	,
		p_drawee_bank_account_id     	IN  NUMBER	DEFAULT NULL	,
		p_remittance_bank_account_id 	IN  NUMBER 	DEFAULT NULL	,
		p_override_remit_account_flag	IN  VARCHAR2	DEFAULT NULL	,
		p_batch_id			IN  NUMBER	DEFAULT NULL	,
		p_doc_sequence_id		IN  NUMBER	DEFAULT NULL	,
		p_doc_sequence_value		IN  NUMBER	DEFAULT NULL	,
		p_created_from			IN  VARCHAR2	DEFAULT NULL	,

           --   ***** Descriptive Flexfield parameters *****
                p_attribute_category		IN  VARCHAR2	DEFAULT NULL	,
		p_attribute1			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute2			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute3			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute4			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute5			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute6			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute7			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute8			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute9			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute10			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute11			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute12			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute13			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute14			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute15			IN  VARCHAR2	DEFAULT NULL	,

           --   ***** Legal Entity and SSA *****
                p_le_id                         IN  NUMBER      DEFAULT NULL    ,
                p_org_id                        IN  NUMBER      DEFAULT NULL    ,
                p_payment_trxn_extn_id          IN  NUMBER      DEFAULT NULL    ,

           --   ***** OUTPUT variables *****
                p_customer_trx_id		OUT NOCOPY NUMBER			,
		p_new_trx_number		OUT NOCOPY VARCHAR2			,
		p_status			OUT NOCOPY VARCHAR2			,
                p_customer_reference            IN  VARCHAR2    DEFAULT NULL            );



PROCEDURE Update_BR_Header (

           --   *****  Standard API parameters *****
                p_api_version      		IN  NUMBER			,
                p_init_msg_list    		IN  VARCHAR2 := FND_API.G_TRUE	,
                p_commit           		IN  VARCHAR2 := FND_API.G_FALSE	,
                p_validation_level 		IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                x_return_status    		OUT NOCOPY VARCHAR2			,
                x_msg_count        		OUT NOCOPY NUMBER			,
                x_msg_data         		OUT NOCOPY VARCHAR2			,

           --   *****  BR Header information parameters *****
		p_customer_trx_id		IN  NUMBER	DEFAULT NULL	,
		p_term_due_date			IN  DATE	DEFAULT NULL	,
		p_cust_trx_type_id		IN  NUMBER	DEFAULT NULL	,
		p_invoice_currency_code 	IN  VARCHAR2	DEFAULT NULL	,
		p_br_amount			IN  NUMBER	DEFAULT NULL	,
		p_trx_date			IN  DATE	DEFAULT NULL	,
		p_gl_date			IN  DATE	DEFAULT NULL	,
		p_drawee_id			IN  NUMBER	DEFAULT NULL	,
		p_drawee_site_use_id		IN  NUMBER	DEFAULT NULL	,
		p_drawee_contact_id		IN  NUMBER	DEFAULT NULL	,
		p_printing_option		IN  VARCHAR2	DEFAULT NULL	,
		p_comments			IN  VARCHAR2	DEFAULT NULL	,
		p_special_instructions		IN  VARCHAR2	DEFAULT NULL	,
		p_drawee_bank_account_id     	IN  NUMBER	DEFAULT NULL	,
		p_remittance_bank_account_id 	IN  NUMBER 	DEFAULT NULL	,
		p_override_remit_account_flag	IN  VARCHAR2	DEFAULT NULL	,
		p_doc_sequence_id		IN  NUMBER	DEFAULT NULL	,
		p_doc_sequence_value		IN  NUMBER	DEFAULT NULL	,
		p_created_from			IN  VARCHAR2	DEFAULT NULL	,

           --   ***** Descriptive Flexfield parameters *****
                p_attribute_category		IN  VARCHAR2	DEFAULT NULL	,
		p_attribute1			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute2			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute3			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute4			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute5			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute6			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute7			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute8			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute9			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute10			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute11			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute12			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute13			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute14			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute15			IN  VARCHAR2	DEFAULT NULL	,
                p_customer_reference            IN  VARCHAR2    DEFAULT NULL    ,
                p_le_id                         IN  NUMBER      DEFAULT NULL    ,
                p_payment_trxn_extn_id          IN  NUMBER      DEFAULT NULL);


PROCEDURE Delete_BR_Header (

           --   *****  Standard API parameters *****
                p_api_version      		IN  NUMBER			,
                p_init_msg_list    		IN  VARCHAR2 := FND_API.G_TRUE	,
                p_commit           		IN  VARCHAR2 := FND_API.G_FALSE	,
                p_validation_level 		IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                x_return_status    		OUT NOCOPY VARCHAR2			,
                x_msg_count        		OUT NOCOPY NUMBER			,
                x_msg_data         		OUT NOCOPY VARCHAR2			,

           --   *****  Input parameters *****
		p_customer_trx_id		IN  NUMBER	DEFAULT NULL	);



PROCEDURE Lock_BR_Header (

           --   *****  Standard API parameters *****
                p_api_version      		IN  NUMBER			,
                p_init_msg_list    		IN  VARCHAR2 := FND_API.G_TRUE	,
                p_commit           		IN  VARCHAR2 := FND_API.G_FALSE	,
                p_validation_level 		IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                x_return_status    		OUT NOCOPY VARCHAR2			,
                x_msg_count        		OUT NOCOPY NUMBER			,
                x_msg_data         		OUT NOCOPY VARCHAR2			,

           --   *****  BR Header information parameters *****
		p_customer_trx_id		IN  NUMBER	DEFAULT NULL	,
		p_term_due_date			IN  DATE	DEFAULT NULL	,
		p_cust_trx_type_id		IN  NUMBER	DEFAULT NULL	,
		p_invoice_currency_code 	IN  VARCHAR2	DEFAULT NULL	,
		p_br_amount			IN  NUMBER	DEFAULT NULL	,
		p_trx_date			IN  DATE	DEFAULT NULL	,
		p_gl_date			IN  DATE	DEFAULT NULL	,
		p_drawee_id			IN  NUMBER	DEFAULT NULL	,
		p_drawee_site_use_id		IN  NUMBER	DEFAULT NULL	,
		p_drawee_contact_id		IN  NUMBER	DEFAULT NULL	,
		p_printing_option		IN  VARCHAR2	DEFAULT NULL	,
		p_comments			IN  VARCHAR2	DEFAULT NULL	,
		p_special_instructions		IN  VARCHAR2	DEFAULT NULL	,
		p_drawee_bank_account_id     	IN  NUMBER	DEFAULT NULL	,
		p_remittance_bank_account_id 	IN  NUMBER 	DEFAULT NULL	,
		p_override_remit_account_flag	IN  VARCHAR2	DEFAULT NULL	,
		p_doc_sequence_id		IN  NUMBER	DEFAULT NULL	,
		p_doc_sequence_value		IN  NUMBER	DEFAULT NULL	,
		p_created_from			IN  VARCHAR2	DEFAULT NULL	,

           --   ***** Descriptive Flexfield parameters *****
                p_attribute_category		IN  VARCHAR2	DEFAULT NULL	,
		p_attribute1			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute2			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute3			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute4			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute5			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute6			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute7			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute8			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute9			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute10			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute11			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute12			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute13			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute14			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute15			IN  VARCHAR2	DEFAULT NULL	,
                p_customer_reference            IN  VARCHAR2    DEFAULT NULL    );


PROCEDURE Create_BR_Assignment (

           --   *****  Standard API parameters *****
                p_api_version      		IN  NUMBER			,
                p_init_msg_list    		IN  VARCHAR2 := FND_API.G_TRUE	,
                p_commit           		IN  VARCHAR2 := FND_API.G_FALSE	,
                p_validation_level 		IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                x_return_status    		OUT NOCOPY VARCHAR2			,
                x_msg_count        		OUT NOCOPY NUMBER			,
                x_msg_data         		OUT NOCOPY VARCHAR2			,

           --   *****  BR Assignment information parameters *****
		p_customer_trx_id		IN  NUMBER	DEFAULT NULL	,
		p_br_ref_payment_schedule_id	IN  NUMBER	DEFAULT NULL	,
		p_assigned_amount		IN  NUMBER	DEFAULT NULL	,

                p_attribute_category		IN  VARCHAR2	DEFAULT NULL	,
		p_attribute1			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute2			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute3			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute4			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute5			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute6			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute7			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute8			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute9			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute10			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute11			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute12			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute13			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute14			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute15			IN  VARCHAR2	DEFAULT NULL	,

           --   ***** SSA  *****
                p_org_id                        IN  NUMBER      DEFAULT NULL     ,

           --   ***** OUT NOCOPY variables *****
                p_customer_trx_line_id		OUT NOCOPY NUMBER 			);



PROCEDURE Update_BR_Assignment (

           --   *****  Standard API parameters *****
                p_api_version      		IN  NUMBER			,
                p_init_msg_list    		IN  VARCHAR2 := FND_API.G_TRUE	,
                p_commit           		IN  VARCHAR2 := FND_API.G_FALSE	,
                p_validation_level 		IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                x_return_status    		OUT NOCOPY VARCHAR2			,
                x_msg_count        		OUT NOCOPY NUMBER			,
                x_msg_data         		OUT NOCOPY VARCHAR2			,

           --   *****  BR Assignment information parameters *****
		p_customer_trx_id		IN  NUMBER	DEFAULT NULL	,
		p_customer_trx_line_id		IN  NUMBER	DEFAULT NULL	,
		p_br_ref_payment_schedule_id	IN  NUMBER	DEFAULT NULL	,
		p_assigned_amount		IN  NUMBER	DEFAULT NULL	,

                p_attribute_category		IN  VARCHAR2	DEFAULT NULL	,
		p_attribute1			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute2			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute3			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute4			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute5			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute6			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute7			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute8			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute9			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute10			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute11			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute12			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute13			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute14			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute15			IN  VARCHAR2	DEFAULT NULL	);


PROCEDURE Delete_BR_Assignment (

           --   *****  Standard API parameters *****
                p_api_version      		IN  NUMBER			,
                p_init_msg_list    		IN  VARCHAR2 := FND_API.G_TRUE	,
                p_commit           		IN  VARCHAR2 := FND_API.G_FALSE	,
                p_validation_level 		IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                x_return_status    		OUT NOCOPY VARCHAR2			,
                x_msg_count        		OUT NOCOPY NUMBER			,
                x_msg_data         		OUT NOCOPY VARCHAR2			,

           --   *****  BR Assignment info. parameters *****
		p_customer_trx_id		IN  NUMBER	DEFAULT NULL	,
		p_customer_trx_line_id		IN  NUMBER	DEFAULT NULL	);


PROCEDURE Lock_BR_Assignment (

           --   *****  Standard API parameters *****
                p_api_version      		IN  NUMBER			,
                p_init_msg_list    		IN  VARCHAR2 := FND_API.G_TRUE	,
                p_commit           		IN  VARCHAR2 := FND_API.G_FALSE	,
                p_validation_level 		IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                x_return_status    		OUT NOCOPY VARCHAR2			,
                x_msg_count        		OUT NOCOPY NUMBER			,
                x_msg_data         		OUT NOCOPY VARCHAR2			,

           --   *****  BR Assignment info. parameters *****
		p_customer_trx_id		IN  NUMBER	DEFAULT NULL	,
		p_customer_trx_line_id		IN  NUMBER	DEFAULT NULL	,
		p_br_ref_payment_schedule_id	IN  NUMBER	DEFAULT NULL	,
		p_assigned_amount		IN  NUMBER	DEFAULT NULL	,

                p_attribute_category		IN  VARCHAR2	DEFAULT NULL	,
		p_attribute1			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute2			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute3			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute4			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute5			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute6			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute7			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute8			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute9			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute10			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute11			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute12			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute13			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute14			IN  VARCHAR2	DEFAULT NULL	,
		p_attribute15			IN  VARCHAR2	DEFAULT NULL	);



FUNCTION revision RETURN VARCHAR2;

PROCEDURE Create_BR_Trxn_Extension(

           --   *****  Standard API parameters *****
                p_api_version      		IN  NUMBER			,
                p_init_msg_list    		IN  VARCHAR2 := FND_API.G_TRUE	,
                p_commit           		IN  VARCHAR2 := FND_API.G_FALSE	,
                x_return_status    		OUT NOCOPY VARCHAR2	        ,
                x_msg_count        		OUT NOCOPY NUMBER	        ,
                x_msg_data         		OUT NOCOPY VARCHAR2	        ,

           --   *****  BR Header information parameters *****
		p_customer_trx_id		IN  NUMBER	DEFAULT NULL	,
		p_trx_number     		IN  VARCHAR2	DEFAULT NULL	,
		p_org_id                        IN  NUMBER	DEFAULT NULL	,
		p_drawee_id			IN  NUMBER	DEFAULT NULL	,
		p_drawee_site_use_id		IN  NUMBER	DEFAULT NULL	,
		p_payment_channel               IN  VARCHAR2	DEFAULT NULL	,
		p_instrument_assign_id          IN  NUMBER	DEFAULT NULL	,
           --   ***** OUTPUT variables *****
                p_payment_trxn_extn_id          OUT NOCOPY NUMBER	      );

PROCEDURE Update_BR_Trxn_Extension(

           --   *****  Standard API parameters *****
                p_api_version                   IN  NUMBER                      ,
                p_init_msg_list                 IN  VARCHAR2 := FND_API.G_TRUE  ,
                p_commit                        IN  VARCHAR2 := FND_API.G_FALSE ,
                x_return_status                 OUT NOCOPY VARCHAR2             ,
                x_msg_count                     OUT NOCOPY NUMBER               ,
                x_msg_data                      OUT NOCOPY VARCHAR2             ,

           --   *****  BR Header information parameters *****
                p_customer_trx_id               IN  NUMBER      DEFAULT NULL    ,
                p_trx_number                    IN  VARCHAR2    DEFAULT NULL    ,
                p_org_id                        IN  NUMBER      DEFAULT NULL    ,
                p_drawee_id                     IN  NUMBER      DEFAULT NULL    ,
                p_drawee_site_use_id            IN  NUMBER      DEFAULT NULL    ,
                p_payment_channel               IN  VARCHAR2    DEFAULT NULL    ,
                p_instrument_assign_id          IN  NUMBER      DEFAULT NULL    ,
                p_payment_trxn_extn_id          IN  iby_trxn_extensions_v.trxn_extension_id %type );


PROCEDURE Delete_BR_Trxn_Extension(

           --   *****  Standard API parameters *****
                p_api_version                   IN  NUMBER                      ,
                p_init_msg_list                 IN  VARCHAR2 := FND_API.G_TRUE  ,
                p_commit                        IN  VARCHAR2 := FND_API.G_FALSE ,
                x_return_status                 OUT NOCOPY VARCHAR2             ,
                x_msg_count                     OUT NOCOPY NUMBER               ,
                x_msg_data                      OUT NOCOPY VARCHAR2             ,

           --   *****  BR Header information parameters *****
                p_customer_trx_id               IN  NUMBER      DEFAULT NULL    ,
                p_trx_number                    IN  VARCHAR2    DEFAULT NULL    ,
                p_org_id                        IN  NUMBER      DEFAULT NULL    ,
                p_drawee_id                     IN  NUMBER      DEFAULT NULL    ,
                p_drawee_site_use_id            IN  NUMBER      DEFAULT NULL    ,
                p_payment_channel               IN  VARCHAR2    DEFAULT NULL    ,
                p_instrument_assign_id          IN  NUMBER      DEFAULT NULL    ,
                p_payment_trxn_extn_id          IN  iby_trxn_extensions_v.trxn_extension_id %type );


END AR_BILLS_CREATION_PUB;


 

/
