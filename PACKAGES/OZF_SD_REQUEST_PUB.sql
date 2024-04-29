--------------------------------------------------------
--  DDL for Package OZF_SD_REQUEST_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_SD_REQUEST_PUB" AUTHID CURRENT_USER AS
/* $Header: ozfpsdrs.pls 120.10.12010000.2 2009/02/04 09:22:16 bkunjan ship $ */
/*#
* This package can be used to Create,Update and Copy Ship & Debit Request
* @rep:scope public
* @rep:product OZF
* @rep:lifecycle active
* @rep:displayname OZF_SD_REQUEST Public API
* @rep:compatibility S
* @rep:businessevent None
* @rep:category BUSINESS_ENTITY OZF_SSD_REQUEST
*/

--   -------------------------------------------------------
--    Record name  SDR_Hdr_rec_type
--   -------------------------------------------------------
TYPE SDR_Hdr_rec_type IS RECORD
(
    request_header_id               NUMBER,
    object_version_number           NUMBER,
    request_number                  VARCHAR2(30),
    request_start_date              DATE,
    request_end_date                DATE,
    user_status_id                  NUMBER,
    request_outcome                 VARCHAR2(30),
    request_currency_code           VARCHAR2(15),
    authorization_number            VARCHAR2(30),
    attribute_category              VARCHAR2(30),
    attribute1                      VARCHAR2(150),
    attribute2                      VARCHAR2(150),
    attribute3                      VARCHAR2(150),
    attribute4                      VARCHAR2(150),
    attribute5                      VARCHAR2(150),
    attribute6                      VARCHAR2(150),
    attribute7                      VARCHAR2(150),
    attribute8                      VARCHAR2(150),
    attribute9                      VARCHAR2(150),
    attribute10                     VARCHAR2(150),
    attribute11                     VARCHAR2(150),
    attribute12                     VARCHAR2(150),
    attribute13                     VARCHAR2(150),
    attribute14                     VARCHAR2(150),
    attribute15                     VARCHAR2(150),
    supplier_id                     NUMBER,
    supplier_site_id                NUMBER,
    supplier_contact_id             NUMBER,
    internal_submission_date        DATE,
    assignee_response_by_date       DATE,
    assignee_response_date          DATE,
    submtd_by_for_supp_approval     NUMBER,
    supplier_response_by_date       DATE,
    supplier_response_date          DATE,
    supplier_submission_date        DATE,
    requestor_id                    NUMBER,
    supplier_quote_number           VARCHAR2(250),
    internal_order_number           NUMBER,
    sales_order_currency            VARCHAR2(15),
    assignee_resource_id            NUMBER,
    org_id                          NUMBER,
    accrual_type                    VARCHAR2(30),
    cust_account_id                 NUMBER,
    request_description             VARCHAR2(4000),
    supplier_contact_email_address  VARCHAR2(2000),
    supplier_contact_phone_number   VARCHAR2(60),
    request_type_setup_id           NUMBER,
    request_basis                   VARCHAR2(1),
    user_id                         NUMBER,
    supplier_contact_name           VARCHAR2(360) --//Bugfix 7822442
);

--   -------------------------------------------------------
--    Record name  SDR_lines_rec_type
--   -------------------------------------------------------

TYPE SDR_lines_rec_type IS RECORD
(
    request_line_id                 NUMBER,
	object_version_number           NUMBER,
	request_header_id              	NUMBER,
	product_context                	VARCHAR2(30),
	inventory_item_id              	NUMBER,
	prod_catg_id                   	NUMBER,
	product_cat_set_id             	NUMBER,
	product_cost                   	NUMBER,
	item_uom                       	VARCHAR2(30),
	requested_discount_type        	VARCHAR2(30),
	requested_discount_value       	NUMBER,
	cost_basis                      NUMBER,
	max_qty                        	NUMBER,
	limit_qty                      	NUMBER,
	design_win                     	VARCHAR2(30),
	end_customer_price             	NUMBER,
	requested_line_amount          	NUMBER,
	approved_discount_type         	VARCHAR2(30),
	approved_discount_value        	NUMBER,
	approved_max_qty               	NUMBER,
	attribute_category             	VARCHAR2(30),
	attribute1                     	VARCHAR2(150),
	attribute2                     	VARCHAR2(150),
	attribute3                     	VARCHAR2(150),
	attribute4                     	VARCHAR2(150),
	attribute5                     	VARCHAR2(150),
	attribute6                     	VARCHAR2(150),
	attribute7                     	VARCHAR2(150),
	attribute8                     	VARCHAR2(150),
	attribute9                     	VARCHAR2(150),
	attribute10                    	VARCHAR2(150),
	attribute11                    	VARCHAR2(150),
	attribute12                    	VARCHAR2(150),
	attribute13                    	VARCHAR2(150),
	attribute14                    	VARCHAR2(150),
	attribute15                    	VARCHAR2(150),
	vendor_approved_flag           	VARCHAR2(1),
	vendor_item_code               	VARCHAR2(240),
	start_date                     	DATE,
	end_date                       	DATE,
	end_customer_price_type         VARCHAR2(30),
	end_customer_tolerance_type     VARCHAR2(30),
	end_customer_tolerance_value    NUMBER,
	org_id                         	NUMBER,
	rejection_code                  VARCHAR2(30),
	requested_discount_currency     VARCHAR2(15),
    product_cost_currency           VARCHAR2(15),
	end_customer_currency           VARCHAR2(15),
    approved_discount_currency      VARCHAR2(15)
	);

TYPE SDR_lines_tbl_type IS TABLE OF SDR_lines_rec_type
INDEX BY BINARY_INTEGER;

--   -------------------------------------------------------
--    Record name  SDR_cust_rec_type
--   -------------------------------------------------------
TYPE SDR_cust_rec_type IS RECORD
(
	request_customer_id              NUMBER,
	object_version_number            NUMBER,
	request_header_id              	 NUMBER,
	cust_account_id                	 NUMBER,
	party_id                       	 NUMBER,
	site_use_id                    	 NUMBER,
	cust_usage_code         	     VARCHAR2(30),
	attribute_category             	 VARCHAR2(30),
	attribute1                     	 VARCHAR2(150),
	attribute2                     	 VARCHAR2(150),
	attribute3                     	 VARCHAR2(150),
	attribute4                     	 VARCHAR2(150),
	attribute5                     	 VARCHAR2(150),
	attribute6                     	 VARCHAR2(150),
	attribute7                     	 VARCHAR2(150),
	attribute8                     	 VARCHAR2(150),
	attribute9                     	 VARCHAR2(150),
	attribute10                    	 VARCHAR2(150),
	attribute11                    	 VARCHAR2(150),
	attribute12                    	 VARCHAR2(150),
	attribute13                    	 VARCHAR2(150),
	attribute14                    	 VARCHAR2(150),
    attribute15                    	 VARCHAR2(150),
    end_customer_flag                VARCHAR2(1)
);
TYPE SDR_cust_tbl_type IS TABLE OF SDR_cust_rec_type
INDEX BY BINARY_INTEGER;

---------------------------------------------------------------------
-- API Name
--     create_sd_request
--Type
--   Public
-- PURPOSE
--    This procedure creates Ship and Debit Request
--
-- PARAMETERS
--  IN
--  OUT
-- NOTES
/*#
* This procedure creates a new Ship & Debit Request.
* @param  p_api_version_number  -->  Version of the API.
* @param p_init_msg_list        -->  Whether to initialize the message stack.
* @param p_commit               --> Indicates whether to commit within the program.
* @param p_validation_level     --> Indicates the level of the validation.
* @param x_return_status        --> Indicates the status of the program.
* @param x_msg_count            --> Provides the number of the messages returned by the program.
* @param x_msg_data             --> Returns messages by the program.
* @param p_SDR_hdr_rec          --> Contains details of the new SDR to be created
* @param p_SDR_lines_tbl       --> Table structure contains the product line information for the new SDR
* @param p_SDR_cust_tbl        --> Table structure contains the Customer information for the new SDR
* @param x_request_header_id   --> Returns the id of the new SDR created.
* @rep:scope public
* @rep:lifecycle active
* @rep:displayname Create SDR
* @rep:compatibility S
* @rep:businessevent None
*/

---------------------------------------------------------------------
PROCEDURE create_sd_request(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER      := FND_API.g_valid_level_full,
    x_return_status              OUT  NOCOPY  VARCHAR2,
    x_msg_count                  OUT  NOCOPY  NUMBER,
    x_msg_data                   OUT  NOCOPY  VARCHAR2,
    p_SDR_hdr_rec                IN   SDR_Hdr_rec_type,
    p_SDR_lines_tbl              IN   SDR_lines_tbl_type,
    p_SDR_cust_tbl               IN   SDR_cust_tbl_type,
    x_request_header_id          OUT NOCOPY  NUMBER
);
---------------------------------------------------------------------
-- API Name
--    update_sd_request
--Type
--   Public
-- PURPOSE
--    This procdure updates existing SDR
--
-- PARAMETERS
--  IN
--  OUT
-- NOTES
/*#
* This Procedure updates existinf Ship & Debit Request
* @param  p_api_version_number  -->  Version of the API.
* @param p_init_msg_list        -->  Whether to initialize the message stack.
* @param p_commit               --> Indicates whether to commit within the program.
* @param p_validation_level     --> Indicates the level of the validation.
* @param x_return_status        --> Indicates the status of the program.
* @param x_msg_count            --> Provides the number of the messages returned by the program.
* @param x_msg_data             --> Returns messages by the program.
* @param p_SDR_hdr_rec          --> Contains details of the new SDR to be created
* @param p_SDR_lines_tbl       --> Table structure contains the product line information for the new SDR
* @param p_SDR_cust_tbl        --> Table structure contains the Customer information for the new SDR
* @rep:scope public
* @rep:lifecycle active
* @rep:displayname Update SD Request
* @rep:compatibility S
* @rep:businessevent None
*/

---------------------------------------------------------------------
PROCEDURE update_sd_request(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER      := FND_API.g_valid_level_full,
    x_return_status              OUT  NOCOPY  VARCHAR2,
    x_msg_count                  OUT  NOCOPY  NUMBER,
    x_msg_data                   OUT  NOCOPY  VARCHAR2,
    p_SDR_hdr_rec                IN  SDR_Hdr_rec_type,
    p_SDR_lines_tbl              IN   SDR_lines_tbl_type,
    p_SDR_cust_tbl               IN   SDR_cust_tbl_type
);
---------------------------------------------------------------------
-- API Name
--    copy_sd_request
--Type
--   Public
-- PURPOSE
--    This procdure Copies existing SDR
--
-- PARAMETERS
--  IN
--  OUT
-- NOTES
/*#
* This procedure Copies existing Ship & Debit Request.
* @param p_api_version_number     --> Version of the API.
* @param p_init_msg_list          --> Whether to initialize the message stack.
* @param p_commit                 --> Indicates whether to commit within the program.
* @param p_validation_level       --> Indicates the level of the validation.
* @param x_return_status          --> Indicates the status of the program.
* @param x_msg_count              --> Provides the number of the messages returned by the program.
* @param x_msg_data               --> Returns messages by the program.
* @param p_source_request_id      --> Source Request header ID for Copy
* @param p_new_request_number     --> New Request number
* @param p_accrual_type           --> Accrual type , SUPPLIER/INTERNAL
* @param p_cust_account_id        --> Customer Account Id , Mandatory for INTERNAL offers
* @param p_request_start_date     --> Request Start date
* @param p_request_end_date       --> Requrest End date
* @param p_copy_product_flag      --> Flag Indicates weather to copy Product lines
* @param p_copy_customer_flag     --> Flag Indicates weather to copy Customer Information
* @param p_copy_end_customer_flag --> Flag Indicates weather to copy End-Customer Information
* @param p_request_source         --> Source of the Request : Manual/API
* @param x_request_header_id      --> Returns new Request Header Id.

* @rep:scope public
* @rep:lifecycle active
* @rep:displayname copy_sd_request
* @rep:compatibility S
* @rep:businessevent None
*/
---------------------------------------------------------------------
PROCEDURE copy_sd_request(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER      := FND_API.g_valid_level_full,
    x_return_status              OUT  NOCOPY  VARCHAR2,
    x_msg_count                  OUT  NOCOPY  NUMBER,
    x_msg_data                   OUT  NOCOPY  VARCHAR2,
    p_source_request_id          IN   VARCHAR2,
    p_new_request_number         IN   VARCHAR2,
    p_accrual_type               IN   VARCHAR2,
    p_cust_account_id            IN   NUMBER,
    p_request_start_date         IN   DATE,
    p_request_end_date           IN   DATE,
    p_copy_product_flag          IN   VARCHAR2 DEFAULT 'N',
    p_copy_customer_flag         IN   VARCHAR2 DEFAULT 'N',
    p_copy_end_customer_flag     IN   VARCHAR2 DEFAULT 'N',
    p_request_source             IN   VARCHAR2 DEFAULT 'API',
    x_request_header_id          OUT  NOCOPY NUMBER
);

END OZF_SD_REQUEST_PUB;

/
