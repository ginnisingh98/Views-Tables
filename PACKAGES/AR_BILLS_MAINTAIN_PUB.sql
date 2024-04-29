--------------------------------------------------------
--  DDL for Package AR_BILLS_MAINTAIN_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_BILLS_MAINTAIN_PUB" AUTHID CURRENT_USER AS
/* $Header: ARBRMAIS.pls 115.6 2002/11/15 01:57:17 anukumar ship $ */


PROCEDURE Complete_BR (

           --   *****  Standard API parameters  *****

                p_api_version      		IN  	NUMBER					,
                p_init_msg_list    		IN  	VARCHAR2 := FND_API.G_TRUE		,
                p_commit           		IN  	VARCHAR2 := FND_API.G_FALSE		,
                p_validation_level 		IN  	NUMBER   := FND_API.G_VALID_LEVEL_FULL	,
                x_return_status    		OUT NOCOPY 	VARCHAR2				,
                x_msg_count        		OUT NOCOPY 	NUMBER					,
                x_msg_data         		OUT NOCOPY 	VARCHAR2				,

           --   *****  Input  parameters  *****

		p_customer_trx_id		IN  	NUMBER	DEFAULT NULL			,


           --   *****  Output parameters  *****

		p_trx_number			OUT NOCOPY 	VARCHAR2				,
		p_doc_sequence_id		OUT NOCOPY 	NUMBER					,
		p_doc_sequence_value		OUT NOCOPY 	NUMBER					,
		p_old_trx_number		OUT NOCOPY 	VARCHAR2				,
		p_status			OUT NOCOPY 	VARCHAR2				);



PROCEDURE UnComplete_BR (

           --   *****  Standard API parameters *****

                p_api_version    		IN  	NUMBER					,
                p_init_msg_list    		IN  	VARCHAR2 := FND_API.G_TRUE		,
                p_commit           		IN  	VARCHAR2 := FND_API.G_FALSE		,
                p_validation_level 		IN  	NUMBER   := FND_API.G_VALID_LEVEL_FULL	,
                x_return_status    		OUT NOCOPY 	VARCHAR2				,
                x_msg_count        		OUT NOCOPY 	NUMBER					,
                x_msg_data         		OUT NOCOPY 	VARCHAR2				,

           --   *****  Input  parameters  *****

		p_customer_trx_id		IN  	NUMBER	DEFAULT NULL			,

           --   *****  Output parameters  *****

		p_status			OUT NOCOPY 	VARCHAR2				);



PROCEDURE Accept_BR (

           --   *****  Standard API parameters *****

                p_api_version      		IN  	NUMBER					,
                p_init_msg_list    		IN  	VARCHAR2 := FND_API.G_TRUE		,
                p_commit           		IN  	VARCHAR2 := FND_API.G_FALSE		,
                p_validation_level 		IN  	NUMBER   := FND_API.G_VALID_LEVEL_FULL	,
                x_return_status    		OUT NOCOPY 	VARCHAR2				,
                x_msg_count        		OUT NOCOPY 	NUMBER					,
                x_msg_data         		OUT NOCOPY 	VARCHAR2				,

           --   *****  Input  parameters  *****

		p_customer_trx_id		IN  	NUMBER	DEFAULT NULL			,
		p_acceptance_date		IN  	DATE	DEFAULT NULL			,
		p_acceptance_gl_date		IN  	DATE	DEFAULT NULL			,
		p_acceptance_comments		IN  	VARCHAR2	DEFAULT NULL		,

           --   *****  Output parameters  *****

		p_status			OUT NOCOPY VARCHAR2					);



PROCEDURE Hold_BR (

           --   *****  Standard API parameters *****

                p_api_version      		IN  	NUMBER					,
                p_init_msg_list    		IN  	VARCHAR2 := FND_API.G_TRUE		,
                p_commit           		IN  	VARCHAR2 := FND_API.G_FALSE		,
                p_validation_level 		IN  	NUMBER   := FND_API.G_VALID_LEVEL_FULL	,
                x_return_status    		OUT NOCOPY 	VARCHAR2				,
                x_msg_count        		OUT NOCOPY 	NUMBER					,
                x_msg_data         		OUT NOCOPY 	VARCHAR2				,

           --   *****  Input  parameters  *****

		p_customer_trx_id		IN  	NUMBER	DEFAULT NULL			,

           --   *****  Output parameters  *****

		p_status			OUT NOCOPY 	VARCHAR2				);



PROCEDURE UnHold_BR (

           --   *****  Standard API parameters *****

                p_api_version      		IN  	NUMBER					,
                p_init_msg_list    		IN  	VARCHAR2 := FND_API.G_TRUE		,
                p_commit           		IN  	VARCHAR2 := FND_API.G_FALSE		,
                p_validation_level 		IN  	NUMBER   := FND_API.G_VALID_LEVEL_FULL	,
                x_return_status    		OUT NOCOPY 	VARCHAR2				,
                x_msg_count        		OUT NOCOPY 	NUMBER					,
                x_msg_data         		OUT NOCOPY 	VARCHAR2				,

           --   *****  Input  parameters  *****

		p_customer_trx_id		IN  	NUMBER	DEFAULT NULL			,

           --   *****  Output parameters  *****

		p_status			OUT NOCOPY 	VARCHAR2				);



PROCEDURE Select_BR_Remit (

           --   *****  Input  parameters  *****

		p_batch_id			IN  	NUMBER	DEFAULT NULL			,
		p_ps_id				IN  	NUMBER	DEFAULT NULL			,

           --   *****  Output parameters  *****

		p_status			OUT NOCOPY 	VARCHAR2				);



PROCEDURE DeSelect_BR_Remit (

           --   *****  Input  parameters  *****

		p_ps_id				IN  	NUMBER	DEFAULT NULL			,

           --   *****  Output parameters  *****

		p_status			OUT NOCOPY 	VARCHAR2				);



PROCEDURE Cancel_BR_Remit (

           --   *****  Input  parameters  *****

		p_ps_id				IN  	NUMBER	DEFAULT NULL			);



PROCEDURE Approve_BR_Remit (

           --   *****  Input  parameters  *****

		p_batch_id			IN	ar_batches.batch_id%TYPE			,
		p_ps_id				IN	ar_payment_schedules.payment_schedule_id%TYPE	,

           --   *****  Output parameters  *****

         	p_status			OUT NOCOPY 	VARCHAR2					);



PROCEDURE Cancel_BR (

           --   *****  Standard API parameters *****

                p_api_version      		IN  	NUMBER					,
                p_init_msg_list    		IN  	VARCHAR2 := FND_API.G_TRUE		,
                p_commit           		IN  	VARCHAR2 := FND_API.G_FALSE		,
                p_validation_level 		IN  	NUMBER   := FND_API.G_VALID_LEVEL_FULL	,
                x_return_status    		OUT NOCOPY 	VARCHAR2				,
                x_msg_count        		OUT NOCOPY 	NUMBER					,
                x_msg_data         		OUT NOCOPY 	VARCHAR2				,

           --   *****  Input parameters  *****

		p_customer_trx_id		IN  	NUMBER		DEFAULT NULL		,
		p_cancel_date			IN  	DATE		DEFAULT NULL		,
		p_cancel_gl_date		IN  	DATE		DEFAULT NULL		,
		p_cancel_comments		IN  	VARCHAR2	DEFAULT NULL		,


           --   *****  Output parameters  *****

		p_status			OUT NOCOPY 	VARCHAR2				);



PROCEDURE Unpaid_BR (

           --   *****  Standard API parameters *****

                p_api_version      		IN  	NUMBER					,
                p_init_msg_list    		IN  	VARCHAR2 := FND_API.G_TRUE		,
                p_commit           		IN  	VARCHAR2 := FND_API.G_FALSE		,
                p_validation_level 		IN  	NUMBER   := FND_API.G_VALID_LEVEL_FULL	,
                x_return_status    		OUT NOCOPY 	VARCHAR2				,
                x_msg_count        		OUT NOCOPY 	NUMBER					,
                x_msg_data         		OUT NOCOPY 	VARCHAR2				,


           --   *****  Input parameters  *****

		p_customer_trx_id		IN  	NUMBER		DEFAULT NULL		,
		p_unpaid_date			IN  	DATE		DEFAULT NULL		,
		p_unpaid_gl_date		IN  	DATE		DEFAULT NULL		,
		p_unpaid_reason			IN  	VARCHAR2	DEFAULT NULL		,
		p_unpaid_comments		IN  	VARCHAR2	DEFAULT NULL		,

           --   *****  Output parameters  *****

		p_status			OUT NOCOPY 	VARCHAR2				);



PROCEDURE Endorse_BR (

           --   *****  Standard API parameters *****

                p_api_version  			IN  	NUMBER					,
                p_init_msg_list 		IN  	VARCHAR2 := FND_API.G_TRUE		,
                p_commit        		IN  	VARCHAR2 := FND_API.G_FALSE		,
                p_validation_level		IN  	NUMBER   := FND_API.G_VALID_LEVEL_FULL	,
                x_return_status   		OUT NOCOPY 	VARCHAR2				,
                x_msg_count       		OUT NOCOPY 	NUMBER					,
                x_msg_data        		OUT NOCOPY 	VARCHAR2				,

           --   *****  Input parameters  *****

		p_customer_trx_id		IN  	NUMBER		DEFAULT NULL		,
		p_endorse_date			IN  	DATE		DEFAULT NULL		,
		p_endorse_gl_date		IN  	DATE		DEFAULT NULL		,
		p_adjustment_activity_id 	IN  	NUMBER		DEFAULT NULL		,
		p_endorse_comments		IN  	VARCHAR2	DEFAULT NULL		,
		p_recourse_flag			IN  	VARCHAR2	DEFAULT NULL		,

           --   *****  Output parameters  *****

		p_status			OUT NOCOPY 	VARCHAR2				);



PROCEDURE Protest_BR (

           --   *****  Standard API parameters *****

                p_api_version      		IN  	NUMBER					,
                p_init_msg_list    		IN  	VARCHAR2 := FND_API.G_TRUE		,
                p_commit           		IN  	VARCHAR2 := FND_API.G_FALSE		,
                p_validation_level 		IN  	NUMBER   := FND_API.G_VALID_LEVEL_FULL	,
                x_return_status    		OUT NOCOPY 	VARCHAR2				,
                x_msg_count        		OUT NOCOPY 	NUMBER					,
                x_msg_data         		OUT NOCOPY 	VARCHAR2				,

           --   *****  Input parameters  *****

		p_customer_trx_id		IN  	NUMBER		DEFAULT NULL		,
		p_protest_date			IN  	DATE		DEFAULT NULL		,
		p_protest_comments		IN  	VARCHAR2	DEFAULT NULL		,

           --   *****  Output parameters  *****

		p_status			OUT NOCOPY 	VARCHAR2				);



PROCEDURE Restate_BR (

           --   *****  Standard API parameters *****

                p_api_version   		IN  	NUMBER					,
                p_init_msg_list 		IN  	VARCHAR2 := FND_API.G_TRUE		,
                p_commit        		IN  	VARCHAR2 := FND_API.G_FALSE		,
                p_validation_level		IN  	NUMBER   := FND_API.G_VALID_LEVEL_FULL	,
                x_return_status   		OUT NOCOPY 	VARCHAR2				,
                x_msg_count       		OUT NOCOPY 	NUMBER					,
                x_msg_data        		OUT NOCOPY 	VARCHAR2				,


           --   *****  Input parameters  *****

		p_customer_trx_id		IN  	NUMBER		DEFAULT NULL		,
		p_restatement_date		IN  	DATE		DEFAULT NULL		,
		p_restatement_gl_date		IN  	DATE		DEFAULT NULL		,
		p_restatement_comments		IN  	VARCHAR2	DEFAULT NULL		,


           --   *****  Output parameters  *****

		p_status			OUT NOCOPY VARCHAR2					);



PROCEDURE Recall_BR (

           --   *****  Standard API parameters *****

                p_api_version      		IN  	NUMBER					,
                p_init_msg_list    		IN  	VARCHAR2 := FND_API.G_TRUE		,
                p_commit           		IN  	VARCHAR2 := FND_API.G_FALSE		,
                p_validation_level 		IN  	NUMBER   := FND_API.G_VALID_LEVEL_FULL	,
                x_return_status    		OUT NOCOPY 	VARCHAR2				,
                x_msg_count        		OUT NOCOPY 	NUMBER					,
                x_msg_data         		OUT NOCOPY 	VARCHAR2				,

           --   *****  Input parameters  *****

		p_customer_trx_id		IN  	NUMBER		DEFAULT NULL		,
		p_recall_date			IN  	DATE		DEFAULT NULL		,
		p_recall_gl_date		IN  	DATE		DEFAULT NULL		,
		p_recall_comments		IN  	VARCHAR2	DEFAULT NULL		,

           --   *****  Output parameters  *****

		p_status			OUT NOCOPY 	VARCHAR2				);



PROCEDURE Eliminate_Risk_BR (

           --   *****  Standard API parameters *****

                p_api_version     		IN  	NUMBER					,
                p_init_msg_list   		IN  	VARCHAR2 := FND_API.G_TRUE		,
                p_commit          		IN  	VARCHAR2 := FND_API.G_FALSE		,
                p_validation_level		IN  	NUMBER   := FND_API.G_VALID_LEVEL_FULL	,
                x_return_status   		OUT NOCOPY 	VARCHAR2				,
                x_msg_count       		OUT NOCOPY 	NUMBER					,
                x_msg_data        		OUT NOCOPY 	VARCHAR2				,


           --   *****  Input parameters  *****

		p_customer_trx_id		IN  	NUMBER		DEFAULT NULL		,
		p_risk_eliminate_date		IN  	DATE		DEFAULT NULL		,
		p_risk_eliminate_gl_date	IN  	DATE		DEFAULT NULL		,
		p_risk_eliminate_comments	IN  	VARCHAR2	DEFAULT NULL		,

           --   *****  Output parameters  *****

		p_status			OUT NOCOPY 	VARCHAR2				);



PROCEDURE UnEliminate_Risk_BR (

           --   *****  Standard API parameters *****

                p_api_version      		IN  	NUMBER					,
                p_init_msg_list    		IN  	VARCHAR2 := FND_API.G_TRUE		,
                p_commit           		IN  	VARCHAR2 := FND_API.G_FALSE		,
                p_validation_level 		IN  	NUMBER   := FND_API.G_VALID_LEVEL_FULL	,
                x_return_status    		OUT NOCOPY 	VARCHAR2				,
                x_msg_count        		OUT NOCOPY 	NUMBER					,
                x_msg_data         		OUT NOCOPY 	VARCHAR2				,

           --   *****  Input parameters  *****

		p_customer_trx_id		IN  	NUMBER		DEFAULT NULL		,
		p_risk_uneliminate_date		IN  	DATE		DEFAULT NULL		,
		p_risk_uneliminate_gl_date	IN  	DATE		DEFAULT NULL		,
		p_risk_uneliminate_comments	IN  	VARCHAR2	DEFAULT NULL		,

           --   *****  Output parameters  *****

		p_status			OUT NOCOPY VARCHAR2					);



PROCEDURE Exchange_BR (

           --   *****  Standard API parameters *****

                p_api_version      		IN  	NUMBER					,
                p_init_msg_list    		IN  	VARCHAR2 := FND_API.G_TRUE		,
                p_commit           		IN  	VARCHAR2 := FND_API.G_FALSE		,
                p_validation_level 		IN  	NUMBER   := FND_API.G_VALID_LEVEL_FULL	,
                x_return_status    		OUT NOCOPY 	VARCHAR2				,
                x_msg_count        		OUT NOCOPY 	NUMBER					,
                x_msg_data         		OUT NOCOPY 	VARCHAR2				,

           --   *****  Input parameters  *****

		p_customer_trx_id		IN 	NUMBER	DEFAULT NULL			,

           --   *****  Output parameters  *****

		p_new_customer_trx_id		OUT NOCOPY 	NUMBER					,
		p_new_trx_number		OUT NOCOPY 	VARCHAR2				);




FUNCTION   revision
                        RETURN VARCHAR2;


END AR_BILLS_MAINTAIN_PUB;


 

/
