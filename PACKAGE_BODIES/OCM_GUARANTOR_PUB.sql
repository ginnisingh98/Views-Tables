--------------------------------------------------------
--  DDL for Package Body OCM_GUARANTOR_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OCM_GUARANTOR_PUB" AS
/* $Header: OCMPGTRB.pls 120.5 2006/02/16 17:27:31 bdhotkar noship $ */

  PROCEDURE Create_Guarantor_CreditRequest
     ( p_api_version                       IN NUMBER,
       p_init_msg_list                     IN VARCHAR2 DEFAULT FND_API.G_TRUE,
       p_commit                            IN VARCHAR2,
       p_validation_level                  IN VARCHAR2,
       x_return_status                     OUT NOCOPY VARCHAR2,
       x_msg_count                         OUT NOCOPY NUMBER,
       x_msg_data                          OUT NOCOPY VARCHAR2,
       x_guarantor_credit_request_id       OUT NOCOPY VARCHAR2,
       x_guarantor_application_number      IN OUT NOCOPY VARCHAR2,
       p_party_id                          IN NUMBER,
       p_contact_party_id                  IN NUMBER,
       p_parent_credit_request_id          IN NUMBER,
       p_currency                          IN VARCHAR2,
       p_guaranted_amount                  IN NUMBER,
       p_funding_available_from            IN DATE,
       p_funding_available_to              IN DATE,
       p_case_folder_id                    IN NUMBER  DEFAULT -99,
       p_notes                             IN VARCHAR2,
       p_credit_classification             IN VARCHAR2  DEFAULT 'GUARANTOR',
       p_review_type                       IN VARCHAR2 DEFAULT 'GUARANTOR',
       p_requestor_id                      IN NUMBER,
       p_source_org_id                     IN NUMBER,
       p_source_user_id                    IN NUMBER,
       p_source_resp_id                    IN NUMBER,
       p_source_appln_id                   IN NUMBER,
       p_source_security_group_id          IN NUMBER,
       p_source_name                       IN VARCHAR2,
       p_source_column1                    IN VARCHAR2,
       p_source_column2                    IN VARCHAR2,
       p_source_column3                    IN VARCHAR2,
       p_credit_request_status			   IN VARCHAR2 DEFAULT 'SUBMIT',
       p_review_cycle                      IN VARCHAR2 DEFAULT NULL,
       p_case_folder_number                IN VARCHAR2 DEFAULT NULL,
       p_score_model_id                    IN NUMBER   DEFAULT NULL,
       p_asset_class_code                  IN VARCHAR2 DEFAULT NULL,
       p_asset_type_code                   IN VARCHAR2 DEFAULT NULL,
       p_description                       IN VARCHAR2 DEFAULT NULL,
       p_quantity                          IN NUMBER   DEFAULT NULL,
       p_uom_code                          IN VARCHAR2 DEFAULT NULL,
       p_reference_type                    IN VARCHAR2 DEFAULT NULL,
       p_appraiser                         IN VARCHAR2 DEFAULT NULL,
       p_appraiser_phone                   IN VARCHAR2 DEFAULT NULL,
       p_valuation                         IN NUMBER   DEFAULT NULL,
       p_valuation_method_code             IN VARCHAR2 DEFAULT NULL,
       p_valuation_date                    IN DATE     DEFAULT NULL,
       p_acquisition_date                  IN DATE     DEFAULT NULL,
       p_asset_identifier                  IN VARCHAR2 DEFAULT NULL

       ) IS
--Declare Local variables

 BEGIN

/* We call AR_CMGT_CREDIT_REQUEST_API to create credit request for Guarantor.
   If the return status is Success then insert the record in the table
   AR_CMGT_GUARANTOR_DATA
*/

		  SAVEPOINT GUAR_CREDIT_REQ_PVT;

		  IF FND_API.to_Boolean( p_init_msg_list )
          THEN
              FND_MSG_PUB.initialize;
          END IF;

          x_return_status         := FND_API.G_RET_STS_SUCCESS;

          AR_CMGT_CREDIT_REQUEST_API.create_credit_request
             (p_api_version                => p_api_version,
              p_init_msg_list              => p_init_msg_list,
              p_commit                     => p_commit,
              p_validation_level           => p_validation_level,
              x_return_status              => x_return_status,
              x_msg_count                  => x_msg_count,
              x_msg_data                   => x_msg_data,
              p_application_number         => x_guarantor_application_number,
              p_application_date           => trunc(sysdate),
              p_requestor_type             => 'EMPLOYEE',
              p_requestor_id               => p_requestor_id,
              p_review_type                => p_review_type,
              p_review_cycle               => p_review_cycle,
              p_credit_classification      => p_credit_classification,
              p_requested_amount           => p_guaranted_amount,
              p_requested_currency         => p_currency,
              p_trx_amount                 => p_guaranted_amount,
              p_trx_currency               => p_currency,
              p_credit_type                => 'TRADE',
              p_term_length                => NULL,
              p_credit_check_rule_id       => NULL,
              p_credit_request_status      => p_credit_request_status,
              p_party_id                   => p_party_id,
              p_cust_account_id            => NULL,
              p_cust_acct_site_id          => NULL,
              p_site_use_id                => NULL,
              p_contact_party_id           => p_contact_party_id,
              p_notes                      => p_notes,
              p_source_org_id              => p_source_org_id,
              p_source_user_id             => p_source_user_id,
              p_source_resp_id             => p_source_resp_id,
              p_source_appln_id            => p_source_appln_id,
              p_source_security_group_id   => p_source_security_group_id,
              p_source_name                => p_source_name,
              p_source_column1             => p_source_column1,
              p_source_column2             => p_source_column2,
              p_source_column3             => p_source_column3,
              p_case_folder_number         => p_case_folder_number,
              p_score_model_id             => p_score_model_id,
              p_credit_request_id          => x_guarantor_credit_request_id,
              p_parent_credit_request_id   => p_parent_credit_request_id,
              p_credit_request_type        => 'GUARANTOR'
             );
 /* If the credit request is created successfully for the guarantor the insert a
    record in table AR_CMGT_GUARANTOR_DATA for this request */

    	  IF x_return_status <> FND_API.G_RET_STS_SUCCESS
    	  THEN
    	  		ROLLBACK TO GUAR_CREDIT_REQ_PVT;
    	  		return;
    	  END IF;

          IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN

            INSERT INTO AR_CMGT_GUARANTOR_DATA
	    (
 	     datapoint_id               ,
  	     credit_request_id          ,
             Guarantor_credit_request_id,
	     last_update_date           ,
   	     last_updated_by            ,
	     creation_date              ,
   	     created_by                 ,
	     last_update_login          ,
	     currency                   ,
    	     guaranteed_amount          ,
    	     funding_available_from     ,
   	     funding_available_to       ,
    	     notes                      ,
    	     case_folder_id             ,
             asset_class_code           ,
             asset_type_code            ,
             description                ,
             quantity                   ,
             uom_code                   ,
             reference_type             ,
             appraiser                  ,
             appraiser_phone            ,
             valuation                  ,
             valuation_method_code      ,
             valuation_date             ,
             acquisition_date           ,
             asset_identifier  ,
	     party_id,
	     contact_party_id
            )
   	    VALUES
  	     (
     	        AR_CMGT_GUARANTOR_DATA_S.nextval,
                p_parent_credit_request_id,
	        x_guarantor_credit_request_id,
      	        sysdate,
     		fnd_global.user_id,
       	 	sysdate,
    	    	fnd_global.user_id,
       	 	fnd_global.login_id,
       	 	p_currency,
		p_guaranted_amount,
		p_funding_available_from,
		p_funding_available_to,
		p_notes,
		p_case_folder_id,
                p_asset_class_code,
                p_asset_type_code ,
                p_description ,
                p_quantity,
                p_uom_code,
                p_reference_type,
                p_appraiser ,
                p_appraiser_phone,
                p_valuation ,
                p_valuation_method_code,
                p_valuation_date ,
                p_acquisition_date,
                p_asset_identifier,
		p_party_id,
		p_contact_party_id
		);
          END IF;

	EXCEPTION
		WHEN OTHERS THEN
			ROLLBACK TO GUAR_CREDIT_REQ_PVT;
			x_return_status := FND_API.G_RET_STS_ERROR;
			x_msg_data := sqlerrm;
END Create_Guarantor_CreditRequest;
END OCM_GUARANTOR_PUB;

/
