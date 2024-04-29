--------------------------------------------------------
--  DDL for Package IGC_CC_OPN_UPD_GET_LNK_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGC_CC_OPN_UPD_GET_LNK_PUB" AUTHID CURRENT_USER AS
/* $Header: IGCOUGLS.pls 120.8.12000000.4 2007/10/24 06:52:08 smannava ship $ */
/*#
 * Contract Commitment Operations API allows the user to update, create,
 * obtain, and link contract commitments from an external source.
 * @rep:scope public
 * @rep:product IGI
 * @rep:lifecycle active
 * @rep:displayname Contract Commitment Operations API
 * @rep:ihelp igi/@iopenapiappx#iopenapiappx  Contract Commitment Open API, Oracle Public Sector International Help
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY IGC_CONTRACT_COMMITMENT
 */
-- Definition of the CC Header record for CC OPEN API process

TYPE cc_header_rec_type IS RECORD (org_id                 igc_cc_headers.org_id%TYPE,
                                   cc_type                igc_cc_headers.cc_type%TYPE,
                                   cc_ref_num             igc_cc_headers.cc_ref_num%TYPE,
                                   cc_num                 igc_cc_headers.cc_num%TYPE,
                                   parent_header_id       igc_cc_headers.parent_header_id%TYPE,
                                   vendor_id              igc_cc_headers.vendor_id%TYPE,
                                   vendor_site_id         igc_cc_headers.vendor_site_id%TYPE,
				   vendor_contact_id      igc_cc_headers.vendor_contact_id%TYPE,
                                   term_id                igc_cc_headers.term_id%TYPE,
                                   location_id            igc_cc_headers.location_id%TYPE,
                                   set_of_books_id        igc_cc_headers.set_of_books_id%TYPE,
                                   cc_desc                igc_cc_headers.cc_desc%TYPE,
                                   cc_start_date          igc_cc_headers.cc_start_date%TYPE,
                                   cc_end_date            igc_cc_headers.cc_end_date%TYPE,
                                   cc_owner_user_id       igc_cc_headers.cc_owner_user_id%TYPE,
                                   cc_preparer_user_id    igc_cc_headers.cc_preparer_user_id%TYPE,
                                   currency_code          igc_cc_headers.currency_code%TYPE,
                                   conversion_type        igc_cc_headers.conversion_type%TYPE,
                                   conversion_date        igc_cc_headers.conversion_date%TYPE,
                                   conversion_rate        igc_cc_headers.conversion_rate%TYPE,
                                   last_update_date       igc_cc_headers.last_update_date%TYPE,
                                   last_updated_by        igc_cc_headers.last_updated_by%TYPE,
                                   last_update_login      igc_cc_headers.last_update_login%TYPE,
                                   created_by             igc_cc_headers.created_by%TYPE,
                                   creation_date          igc_cc_headers.creation_date%TYPE,
                                   context                igc_cc_headers.context%TYPE,
                                   attribute1             igc_cc_headers.attribute1%TYPE,
                                   attribute2             igc_cc_headers.attribute2%TYPE,
                                   attribute3             igc_cc_headers.attribute3%TYPE,
                                   attribute4             igc_cc_headers.attribute4%TYPE,
                                   attribute5             igc_cc_headers.attribute5%TYPE,
                                   attribute6             igc_cc_headers.attribute6%TYPE,
                                   attribute7             igc_cc_headers.attribute7%TYPE,
                                   attribute8             igc_cc_headers.attribute8%TYPE,
                                   attribute9             igc_cc_headers.attribute9%TYPE,
                                   attribute10            igc_cc_headers.attribute10%TYPE,
                                   attribute11            igc_cc_headers.attribute11%TYPE,
                                   attribute12            igc_cc_headers.attribute12%TYPE,
                                   attribute13            igc_cc_headers.attribute13%TYPE,
                                   attribute14            igc_cc_headers.attribute14%TYPE,
                                   attribute15            igc_cc_headers.attribute15%TYPE,
                                   cc_guarantee_flag      igc_cc_headers.cc_guarantee_flag%TYPE
                                  );

-- Main program which selects all the records from Header PL-SQL table
-- and calls other programs for processing
/*#
 * This API selects all records from the Header PL-SQL table
 * and calls other programs for processing.
 * @param p_api_version API Version
 * @rep:paraminfo {@rep:required}
 * @param p_init_msg_list TRUE should be passed if the Message List is to be
 * initialized
 * @param p_commit If it is set to TRUE it commits work
 * @param p_validation_level To determine which validation steps should be executed
 * and which steps should be skipped. Defaults to FULL Validation
 * @param p_cc_header_rec Contract Commitment Header Record
 * @rep:paraminfo {@rep:required}
 * @param x_return_status Reports the API overall return status as Success, Error or
 * Unexpected
 * @param x_msg_count Number of messages in the API message list
 * @param x_msg_data The message in an encoded format
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Contract Commitment
 * @rep:ihelp igi/@copenapitblx#copenapitblx  Create API Parameters
 * @rep:compatibility S
 */
PROCEDURE CC_Open_API_Main (
   p_api_version         IN   NUMBER,
   p_init_msg_list       IN   VARCHAR2,
   p_commit              IN   VARCHAR2,
   p_validation_level    IN   NUMBER,
   p_cc_header_rec       IN   CC_HEADER_REC_TYPE,
   x_return_status      OUT NOCOPY   VARCHAR2,
   x_msg_count          OUT NOCOPY   NUMBER,
   x_msg_data           OUT NOCOPY   VARCHAR2
);

-- To perform commitment action from an external system on a particular contract commitment.

/*#
 * This API updates standard and release contract commitment types in an external system and
 * updates the control status of the associated contract commitment.
 * @param p_api_version API Version
 * @rep:paraminfo {@rep:required}
 * @param p_init_msg_list TRUE should be passed if the Message List is to be
 * initialized
 * @param p_commit If it is set to TRUE it commits work
 * @param p_validation_level To determine which validation steps should be executed
 * and which steps should be skipped. Defaults to FULL Validation
 * @param p_cc_num Contract Number
 * @rep:paraminfo {@rep:required}
 * @param p_set_of_books_id Set Of Books Id
 * @rep:paraminfo {@rep:required}
 * @param p_org_id Organization Id
 * @rep:paraminfo {@rep:required}
 * @param p_action_code Valid Actions are Close(CL), On Hold(OH), Open(OP) and Release
 * Hold(RH)
 * @rep:paraminfo {@rep:required}
 * @param p_last_updated_by Last Updated User of Headers
 * @rep:paraminfo {@rep:required}
 * @param p_last_update_login Last Updated Login Of Headers
 * @rep:paraminfo {@rep:required}
 * @param x_return_status Reports the API overall return status as Success, Error or
 * Unexpected
 * @param x_msg_count Number of messages in the API message list
 * @param x_msg_data The message in an encoded format
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Contract Commitment
 * @rep:ihelp igi/@copenapiupdtparx#copenapiupdtparx  Update API Parameters
 * @rep:compatibility S
 */
PROCEDURE  CC_Update_Control_Status_API (
   p_api_version         IN   NUMBER,
   p_init_msg_list       IN   VARCHAR2 ,
   p_commit              IN   VARCHAR2,
   p_validation_level    IN   NUMBER,
   p_cc_num              IN   igc_cc_headers.cc_num%TYPE,
   p_set_of_books_id     IN   igc_cc_headers.set_of_books_id%TYPE,
   p_org_id              IN   igc_cc_headers.org_id%TYPE,
   p_action_code	 IN   fnd_lookups.lookup_code%TYPE,
   p_last_updated_by     IN   igc_cc_headers.last_updated_by%TYPE,
   p_last_update_login   IN   igc_cc_headers.last_update_login%TYPE,
   x_return_status      OUT NOCOPY   VARCHAR2,
   x_msg_count          OUT NOCOPY   NUMBER,
   x_msg_data           OUT NOCOPY   VARCHAR2
);

-- Checks if a contract corresponding to the contract reference number exists in
-- Oracle Contract Commitment.

/*#
 * This API retrieves the external reference number associated with a contract commitment in Contract Commitment.
 * If the API returns the external reference number, it can be modified. If an external reference number does not exist,
 * users can enter one.
 * @param p_api_version API Version
 * @rep:paraminfo {@rep:required}
 * @param p_init_msg_list TRUE should be passed if the Message List is to be
 * initialized
 * @param p_commit If it is set to TRUE it commits work
 * @param p_validation_level To determine which validation steps should be executed
 * and which steps should be skipped. Defaults to FULL Validation
 * @param p_cc_num Contract Number
 * @rep:paraminfo {@rep:required}
 * @param p_org_id Organization Id
 * @rep:paraminfo {@rep:required}
 * @param p_set_of_books_id Set Of Books Id
 * @rep:paraminfo {@rep:required}
 * @param x_cc_header_id CC Header Id
 * @param x_cc_ref_num Reference Number
 * @param x_return_status Reports the API overall return status as Success, Error or
 * Unexpected
 * @param x_msg_count Number of messages in the API message list
 * @param x_msg_data The message in an encoded format
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Check Duplicate Contract Commitment
 * @rep:ihelp igi/@copenapiselpar#copenapiselpar  Select API Parameters
 * @rep:compatibility S
 */
PROCEDURE CC_Get_API (
   p_api_version         IN   NUMBER,
   p_init_msg_list       IN   VARCHAR2,
   p_commit              IN   VARCHAR2,
   p_validation_level    IN   NUMBER,
   p_cc_num              IN   igc_cc_headers.cc_num%TYPE,
   p_org_id              IN   igc_cc_headers.org_id%TYPE,
   p_set_of_books_id     IN   igc_cc_headers.set_of_books_id%TYPE,
   x_cc_header_id	OUT NOCOPY   igc_cc_headers.cc_header_id%TYPE,
   x_cc_ref_num		OUT NOCOPY   igc_cc_headers.cc_ref_num%TYPE,
   x_return_status      OUT NOCOPY   VARCHAR2,
   x_msg_count          OUT NOCOPY   NUMBER,
   x_msg_data           OUT NOCOPY   VARCHAR2
);

-- Links a contract from an external system with a contract in oracle contract commitment.

/*#
 * This API links a contract commitment with an external contract. It is used when a contract commitment
 * exists in Contract Commitment and users want to link it to a contract in an external system.
 * @param p_api_version API Version
 * @rep:paraminfo {@rep:required}
 * @param p_init_msg_list TRUE should be passed if the Message List is to be
 * initialized
 * @param p_commit If it is set to TRUE it commits work
 * @param p_validation_level To determine which validation steps should be executed
 * and which steps should be skipped. Defaults to FULL Validation
 * @param p_cc_ref_num Contract Reference Number
 * @rep:paraminfo {@rep:required}
 * @param p_org_id Organization Id
 * @rep:paraminfo {@rep:required}
 * @param p_set_of_books_id Set Of Books Id
 * @rep:paraminfo {@rep:required}
 * @param p_cc_num Contract Number
 * @rep:paraminfo {@rep:required}
 * @param x_return_status Reports the API overall return status as Success, Error or
 * Unexpected
 * @param x_msg_count Number of messages in the API message list
 * @param x_msg_data The message in an encoded format
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Link Contract Commitment
 * @rep:ihelp igi/@copenapilnkpar#copenapilnkpar  Link API Parameters
 * @rep:compatibility S
 */
PROCEDURE CC_Link_API (
   p_api_version         IN   NUMBER,
   p_init_msg_list       IN   VARCHAR2,
   p_commit              IN   VARCHAR2,
   p_validation_level    IN   NUMBER,
   p_cc_ref_num		 IN   igc_cc_headers.cc_ref_num%TYPE,
   p_org_id              IN   igc_cc_headers.org_id%TYPE,
   p_set_of_books_id     IN   igc_cc_headers.set_of_books_id%TYPE,
   p_cc_num              IN   igc_cc_headers.cc_num%TYPE,
   x_return_status      OUT NOCOPY   VARCHAR2,
   x_msg_count          OUT NOCOPY   NUMBER,
   x_msg_data           OUT NOCOPY   VARCHAR2
);


/* This API is introduced from r12 for MOAC uptake. It validates org_id and sets ORG context. This should be called once before starting of any of Create,Update,Select, Link processes  to intialize MOAC,validate ORG ID and to sets ORG Context */
PROCEDURE Set_Global_Info
          (p_api_version_number  IN NUMBER,
           p_responsibility_id   IN NUMBER,
           p_user_id           IN NUMBER,
           p_resp_appl_id      IN NUMBER,
           p_operating_unit_id   IN NUMBER,
           x_return_status      OUT NOCOPY   VARCHAR2,
           x_msg_count          OUT NOCOPY   NUMBER,
           x_msg_data           OUT NOCOPY   VARCHAR2

);

/* This function is used to determine and get valid operating unit where Contract Commitment is enabled.
-- Returns ORG_ID if valid and CC is enabled or retruns NULL if invalid or CC is not enabled */
FUNCTION GET_VALID_OU
( p_org_id  hr_operating_units.organization_id%TYPE DEFAULT NULL , p_product_code VARCHAR2  )
RETURN NUMBER;
END IGC_CC_OPN_UPD_GET_LNK_PUB;

 

/
