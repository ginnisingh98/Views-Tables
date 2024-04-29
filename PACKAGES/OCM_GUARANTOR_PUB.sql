--------------------------------------------------------
--  DDL for Package OCM_GUARANTOR_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OCM_GUARANTOR_PUB" AUTHID CURRENT_USER AS
/* $Header: OCMPGTRS.pls 120.4 2006/06/30 22:08:05 bsarkar noship $ */
/*#
 * This API creates a guarantor credit request for initiating a credit review
 * for a guarantor.
 * @rep:scope public
 * @rep:doccd 120ocmug.pdf Credit Management API User Notes, Oracle Credit Management User Guide
 * @rep:product OCM
 * @rep:lifecycle active
 * @rep:displayname Create Guarantor Credit Request
 * @rep:category BUSINESS_ENTITY OCM_GUARANTOR_CREDIT_REQUEST
 */

/*#
 * Use this procedure to create a credit request for a guarantor.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Guarantor Credit Request
 */

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
       p_case_folder_id                    IN NUMBER DEFAULT -99,
       p_notes                             IN VARCHAR2,
       p_credit_classification             IN VARCHAR2 DEFAULT 'GUARANTOR',
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
       p_score_model_id	                   IN NUMBER   DEFAULT NULL,
       p_asset_class_code	           	IN VARCHAR2 DEFAULT NULL,
       p_asset_type_code	           IN VARCHAR2 DEFAULT NULL,
       p_description     	           IN VARCHAR2 DEFAULT NULL,
       p_quantity       	           IN NUMBER   DEFAULT NULL,
       p_uom_code                          IN VARCHAR2 DEFAULT NULL,
       p_reference_type                    IN VARCHAR2 DEFAULT NULL,
       p_appraiser                         IN VARCHAR2 DEFAULT NULL,
       p_appraiser_phone                   IN VARCHAR2 DEFAULT NULL,
       p_valuation                         IN NUMBER   DEFAULT NULL,
       p_valuation_method_code             IN VARCHAR2 DEFAULT NULL,
       p_valuation_date                    IN DATE     DEFAULT NULL,
       p_acquisition_date                  IN DATE     DEFAULT NULL,
       p_asset_identifier                  IN VARCHAR2 DEFAULT NULL
       );

END OCM_GUARANTOR_PUB ;

 

/
