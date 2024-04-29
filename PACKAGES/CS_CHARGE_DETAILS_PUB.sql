--------------------------------------------------------
--  DDL for Package CS_CHARGE_DETAILS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_CHARGE_DETAILS_PUB" AUTHID CURRENT_USER AS
/* $Header: csxpests.pls 120.13.12010000.2 2010/04/03 18:23:49 rgandhi ship $ */
/*#
 * This public interface for the charges functionality in Oracle Service, provides functions
 * that enables user to create, update, delete, and copy charges data.
 *
 * @rep:scope public
 * @rep:product CS
 * @rep:displayname Service Request Charge Processing
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY CS_SERVICE_CHARGE
 * @rep:metalink 390503.1 Oracle Teleservice Implementation Guide Release 12.0
 */

/**** Above text has been added to enable the integration repository to extract the data from
      the source code file and populate the integration repository schema so that the
      interfaces defined in this package appears in the integration repository.
****/



TYPE Charges_Rec_Type IS RECORD
(
 estimate_detail_id                  NUMBER            := FND_API.G_MISS_NUM,
 incident_id                         NUMBER            := FND_API.G_MISS_NUM,
 charge_line_type                    VARCHAR(30)       := FND_API.G_MISS_CHAR,
 line_number                         NUMBER            := FND_API.G_MISS_NUM,
 business_process_id                 NUMBER            := FND_API.G_MISS_NUM,
 transaction_type_id                 NUMBER            := FND_API.G_MISS_NUM,
 inventory_item_id_in                NUMBER            := FND_API.G_MISS_NUM,
 item_revision                       VARCHAR2(3)       := FND_API.G_MISS_CHAR,
 billing_flag                        VARCHAR2(30)      := FND_API.G_MISS_CHAR,
 txn_billing_type_id                 NUMBER            := FND_API.G_MISS_NUM,
 unit_of_measure_code                VARCHAR2(3)       := FND_API.G_MISS_CHAR,
 quantity_required                   NUMBER            := FND_API.G_MISS_NUM,
 return_reason_code                  VARCHAR2(30)      := FND_API.G_MISS_CHAR,
 customer_product_id                 NUMBER            := FND_API.G_MISS_NUM,
 serial_number                       VARCHAR2(50)      := FND_API.G_MISS_CHAR,
 installed_cp_return_by_date         DATE              := FND_API.G_MISS_DATE,
 new_cp_return_by_date               DATE              := FND_API.G_MISS_DATE,
 sold_to_party_id                    NUMBER            := FND_API.G_MISS_NUM,
 bill_to_party_id                    NUMBER            := FND_API.G_MISS_NUM,
 bill_to_account_id                  NUMBER            := FND_API.G_MISS_NUM,
 bill_to_contact_id                  NUMBER            := FND_API.G_MISS_NUM,
 invoice_to_org_id                   NUMBER            := FND_API.G_MISS_NUM,
 ship_to_party_id                    NUMBER            := FND_API.G_MISS_NUM,
 ship_to_account_id                  NUMBER            := FND_API.G_MISS_NUM,
 ship_to_contact_id                  NUMBER            := FND_API.G_MISS_NUM,
 ship_to_org_id                      NUMBER            := FND_API.G_MISS_NUM,
 contract_line_id                    NUMBER            := FND_API.G_MISS_NUM,
 rate_type_code                      VARCHAR2(40)      := FND_API.G_MISS_CHAR,
 contract_id                         NUMBER            := FND_API.G_MISS_NUM,
 coverage_id                         NUMBER            := FND_API.G_MISS_NUM,
 coverage_txn_group_id               NUMBER            := FND_API.G_MISS_NUM,
 coverage_bill_rate_id               NUMBER            := FND_API.G_MISS_NUM,
 coverage_billing_type_id            NUMBER            := FND_API.G_MISS_NUM,
 price_list_id                       NUMBER            := FND_API.G_MISS_NUM,
 currency_code                       VARCHAR2(15)      := FND_API.G_MISS_CHAR,
 purchase_order_num                  VARCHAR2(50)      := FND_API.G_MISS_CHAR,
 list_price                          NUMBER            := FND_API.G_MISS_NUM,
 con_pct_over_list_price             NUMBER            := FND_API.G_MISS_NUM,
 selling_price                       NUMBER            := FND_API.G_MISS_NUM,
 contract_discount_amount            NUMBER            := FND_API.G_MISS_NUM,
 apply_contract_discount             VARCHAR2(1)       := FND_API.G_MISS_CHAR,
 after_warranty_cost                 NUMBER            := FND_API.G_MISS_NUM,
 transaction_inventory_org           NUMBER            := FND_API.G_MISS_NUM,
 transaction_sub_inventory           VARCHAR2(10)      := FND_API.G_MISS_CHAR,
 rollup_flag                         VARCHAR2(1)       := FND_API.G_MISS_CHAR,
 add_to_order_flag                   VARCHAR2(1)       := FND_API.G_MISS_CHAR,
 order_header_id                     NUMBER            := FND_API.G_MISS_NUM,
 interface_to_oe_flag                VARCHAR2(1)       := FND_API.G_MISS_CHAR,
 no_charge_flag                      VARCHAR2(1)       := FND_API.G_MISS_CHAR,
 line_category_code                  VARCHAR2(6)       := FND_API.G_MISS_CHAR,
 line_type_id                        NUMBER            := FND_API.G_MISS_NUM,
 order_line_id                       NUMBER            := FND_API.G_MISS_NUM,
 conversion_rate                     NUMBER            := FND_API.G_MISS_NUM,
 conversion_type_code                VARCHAR2(30)      := FND_API.G_MISS_CHAR,
 conversion_rate_date                DATE              := FND_API.G_MISS_DATE,
 original_source_id                  NUMBER            := FND_API.G_MISS_NUM,
 original_source_code                VARCHAR2(10)      := FND_API.G_MISS_CHAR,
 source_id                           NUMBER            := FND_API.G_MISS_NUM,
 source_code                         VARCHAR2(10)      := FND_API.G_MISS_CHAR,
 org_id                              NUMBER            := FND_API.G_MISS_NUM,

 --Error Handling
 submit_restriction_message          VARCHAR2(2000)    := FND_API.G_MISS_CHAR,
 submit_error_message                VARCHAR2(2000)    := FND_API.G_MISS_CHAR,

 --Auto Submission Process
 submit_from_system                  VARCHAR2(30)      := FND_API.G_MISS_CHAR,
 line_submitted_flag                 VARCHAR2(1)       := FND_API.G_MISS_CHAR,


 --Billing Engine
 activity_start_time                 DATE              := FND_API.G_MISS_DATE,
 activity_end_time                   DATE              := FND_API.G_MISS_DATE,
 generated_by_bca_engine             VARCHAR2(1)       := FND_API.G_MISS_CHAR,

 attribute1                          VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 attribute2                          VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 attribute3                          VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 attribute4                          VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 attribute5                          VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 attribute6                          VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 attribute7                          VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 attribute8                          VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 attribute9                          VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 attribute10                         VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 attribute11                         VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 attribute12                         VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 attribute13                         VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 attribute14                         VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 attribute15                         VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 context                             VARCHAR2(30)      := FND_API.G_MISS_CHAR,
 pricing_context                     VARCHAR2(30)      := FND_API.G_MISS_CHAR,
 pricing_attribute1                  VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 pricing_attribute2                  VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 pricing_attribute3                  VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 pricing_attribute4                  VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 pricing_attribute5                  VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 pricing_attribute6                  VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 pricing_attribute7                  VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 pricing_attribute8                  VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 pricing_attribute9                  VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 pricing_attribute10                 VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 pricing_attribute11                 VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 pricing_attribute12                 VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 pricing_attribute13                 VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 pricing_attribute14                 VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 pricing_attribute15                 VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 pricing_attribute16                 VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 pricing_attribute17                 VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 pricing_attribute18                 VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 pricing_attribute19                 VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 pricing_attribute20                 VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 pricing_attribute21                 VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 pricing_attribute22                 VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 pricing_attribute23                 VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 pricing_attribute24                 VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 pricing_attribute25                 VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 pricing_attribute26                 VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 pricing_attribute27                 VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 pricing_attribute28                 VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 pricing_attribute29                 VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 pricing_attribute30                 VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 pricing_attribute31                 VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 pricing_attribute32                 VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 pricing_attribute33                 VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 pricing_attribute34                 VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 pricing_attribute35                 VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 pricing_attribute36                 VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 pricing_attribute37                 VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 pricing_attribute38                 VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 pricing_attribute39                 VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 pricing_attribute40                 VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 pricing_attribute41                 VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 pricing_attribute42                 VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 pricing_attribute43                 VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 pricing_attribute44                 VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 pricing_attribute45                 VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 pricing_attribute46                 VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 pricing_attribute47                 VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 pricing_attribute48                 VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 pricing_attribute49                 VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 pricing_attribute50                 VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 pricing_attribute51                 VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 pricing_attribute52                 VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 pricing_attribute53                 VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 pricing_attribute54                 VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 pricing_attribute55                 VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 pricing_attribute56                 VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 pricing_attribute57                 VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 pricing_attribute58                 VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 pricing_attribute59                 VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 pricing_attribute60                 VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 pricing_attribute61                 VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 pricing_attribute62                 VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 pricing_attribute63                 VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 pricing_attribute64                 VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 pricing_attribute65                 VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 pricing_attribute66                 VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 pricing_attribute67                 VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 pricing_attribute68                 VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 pricing_attribute69                 VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 pricing_attribute70                 VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 pricing_attribute71                 VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 pricing_attribute72                 VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 pricing_attribute73                 VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 pricing_attribute74                 VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 pricing_attribute75                 VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 pricing_attribute76                 VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 pricing_attribute77                 VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 pricing_attribute78                 VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 pricing_attribute79                 VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 pricing_attribute80                 VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 pricing_attribute81                 VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 pricing_attribute82                 VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 pricing_attribute83                 VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 pricing_attribute84                 VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 pricing_attribute85                 VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 pricing_attribute86                 VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 pricing_attribute87                 VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 pricing_attribute88                 VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 pricing_attribute89                 VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 pricing_attribute90                 VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 pricing_attribute91                 VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 pricing_attribute92                 VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 pricing_attribute93                 VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 pricing_attribute94                 VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 pricing_attribute95                 VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 pricing_attribute96                 VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 pricing_attribute97                 VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 pricing_attribute98                 VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 pricing_attribute99                 VARCHAR2(150)     := FND_API.G_MISS_CHAR,
 pricing_attribute100                VARCHAR2(150)     := FND_API.G_MISS_CHAR,

--obsoleted columns/columns not used/Columns left for backward compatibility
original_source_number               VARCHAR2(200)     := FND_API.G_MISS_CHAR,
source_number                        VARCHAR2(200)     := FND_API.G_MISS_CHAR,
reference_number                     NUMBER            := FND_API.G_MISS_NUM,
original_system_reference            VARCHAR2(50)      := FND_API.G_MISS_CHAR,
inventory_item_id_out                NUMBER            := FND_API.G_MISS_NUM,
serial_number_out                    VARCHAR2(50)      := FND_API.G_MISS_CHAR,
exception_coverage_used              VARCHAR2(1)       := FND_API.G_MISS_CHAR,
/* Credit Card 9358401 */
instrument_payment_use_id            NUMBER            := FND_API.G_MISS_NUM
) ;


G_MISS_CHRG_REC    Charges_Rec_Type  ;


-- Start of comments
--      API name        : Create_Charge_Details
--      Type            : Public
--      Function        :
--      Pre-reqs        : None.
--      Parameters      :
--
--      IN              : p_api_version: 	Standard Version of API	 	            Required
--                        p_init_msg_list:                                                  Optional
--                        p_commit:             Indicates whether API should commit         Optional
--                        p_validation_level:                                               Optional
--                        p_resp_appl_id:
--                        p_resp_id:
--                        p_user_id:
--                        p_login_id:
--                        p_transaction_control:
--                        p_Charges_Rec: Charges_Rec_Type
--			  p_create_cost_detail - Indicates if Costing API needs to be called
--
--                        Following passed using RECORD Charges_Rec_Type are reuired
--                        or conditionally required
--                         incident_id:               Required
--                         business_process_id:       Required
--                         line_category_code:        Required if the charge line is RETURN
--                         line_type_id:              Required
--                         txn_billing_type_id:
--                         coverage_bill_rate_id:
--
--      OUT             : x_return_status:
--                        x_msg_count:
--                        x_object_version_number:
--                        x_msg_data:
--                        x_estimate_detail_id:
--                        x_line_number:
--			  x_cost_id
--
--      Version : Current version       11.5
--      Notes   : This API is a public API to Create Charge Details.
--
-- End of comments

/*#
 * Create a charge line associated with a service request. This procedure creates one charge line
 * at a time.For details on the parameters, please refer to the document on Metalink from the URL provided above.
 *
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:displayname Create Service Request Charge Line
 * @rep:primaryinstance
 * @rep:metalink 390503.1 Oracle Teleservice Implementation Guide Release 12.0
*/

/**** Above text has been added to enable the integration repository to extract the data from
      the source code file and populate the integration repository schema so that
      Create_Charge_Details API appears in the integration repository.
****/

PROCEDURE Create_Charge_Details(
        p_api_version              IN         NUMBER,
        p_init_msg_list            IN         VARCHAR2         := FND_API.G_FALSE,
        p_commit                   IN         VARCHAR2         := FND_API.G_FALSE,
        p_validation_level         IN         NUMBER           := FND_API.G_VALID_LEVEL_FULL,
        x_return_status            OUT NOCOPY VARCHAR2,
        x_msg_count                OUT NOCOPY NUMBER,
        x_object_version_number    OUT NOCOPY NUMBER,
        x_msg_data                 OUT NOCOPY VARCHAR2,
        x_estimate_detail_id       OUT NOCOPY NUMBER,
        x_line_number              OUT NOCOPY NUMBER,
        p_resp_appl_id             IN         NUMBER   := FND_GLOBAL.RESP_APPL_ID,
        p_resp_id                  IN         NUMBER   := FND_GLOBAL.RESP_ID,
        p_user_id                  IN         NUMBER   := FND_GLOBAL.USER_ID,
        p_login_id                 IN         NUMBER           := NULL,
        p_transaction_control      IN         VARCHAR2         := FND_API.G_TRUE,
        p_Charges_Rec              IN         Charges_Rec_Type := G_MISS_CHRG_REC
	) ;


PROCEDURE Create_Charge_Details(
        p_api_version              IN         NUMBER,
        p_init_msg_list            IN         VARCHAR2         := FND_API.G_FALSE,
        p_commit                   IN         VARCHAR2         := FND_API.G_FALSE,
        p_validation_level         IN         NUMBER           := FND_API.G_VALID_LEVEL_FULL,
        x_return_status            OUT NOCOPY VARCHAR2,
        x_msg_count                OUT NOCOPY NUMBER,
        x_object_version_number    OUT NOCOPY NUMBER,
        x_msg_data                 OUT NOCOPY VARCHAR2,
        x_estimate_detail_id       OUT NOCOPY NUMBER,
        x_line_number              OUT NOCOPY NUMBER,
        p_resp_appl_id             IN         NUMBER   := FND_GLOBAL.RESP_APPL_ID,
        p_resp_id                  IN         NUMBER   := FND_GLOBAL.RESP_ID,
        p_user_id                  IN         NUMBER   := FND_GLOBAL.USER_ID,
        p_login_id                 IN         NUMBER           := NULL,
        p_transaction_control      IN         VARCHAR2         := FND_API.G_TRUE,
        p_Charges_Rec              IN         Charges_Rec_Type := G_MISS_CHRG_REC,
	p_create_cost_detail       IN         VARCHAR2 , --added by bkanimoz for service costing
	x_cost_id		   OUT NOCOPY NUMBER     --added by bkanimoz for service costing
	) ;



-- Start of comments
--      API name        : Update_Charge_Details
--      Type            : Public
--      Function        :
--      Pre-reqs        : None.
--      Parameters      :
--
--      IN              : p_api_version: 	Standard Version of API	 	            Required
--                        p_init_msg_list:                                                  Optional
--                        p_commit:             Indicates whether API should commit         Optional
--                        p_validation_level:                                               Optional
--                        p_resp_appl_id:
--                        p_resp_id:
--                        p_user_id:
--                        p_login_id:
--                        p_transaction_control:
--                        p_Charges_Rec: Charges_Rec_Type
--			  p_update_cost_detail : Indicates if Costing API needs to be called
--
--                        Following passed using RECORD Charges_Rec_Type are reuired
--                        or conditionally required
--                        incident_id:               Required
--                        business_process_id:       Required
--                        line_category_code:        Required if the charge line is RETURN
--                        line_type_id:              Required
--                        txn_billing_type_id:
--                        coverage_bill_rate_id:
--
--      OUT             : x_return_status:
--                        x_msg_count:
--                        x_object_version_number:
--                        x_msg_data:
--
--      Version : Current version       11.5
--      Notes   : This API is a public API to Update Charge Details.
--
-- End of comments

/*#
 * Updates a service request charge line. This procedure updates one charge line at a time.
 * For details on the parameters, please refer to the document on Metalink from the URL provided above.
 *
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:displayname Update Service Request Charge Line
 * @rep:primaryinstance
 * @rep:metalink 390503.1 Oracle Teleservice Implementation Guide Release 12.0
*/

/**** Above text has been added to enable the integration repository to extract the data
      from the source code file and populate the integration repository schema so that
      Update_Charge_Details API appears in the integration repository.
****/
PROCEDURE Update_Charge_Details(
        p_api_version              IN         NUMBER,
        p_init_msg_list            IN         VARCHAR2         := FND_API.G_FALSE,
        p_commit                   IN         VARCHAR2         := FND_API.G_FALSE,
        p_validation_level         IN         NUMBER           := FND_API.G_VALID_LEVEL_FULL,
        x_return_status            OUT NOCOPY VARCHAR2,
        x_msg_count                OUT NOCOPY NUMBER,
        x_object_version_number    OUT NOCOPY NUMBER,
        x_msg_data                 OUT NOCOPY VARCHAR2,
        p_resp_appl_id             IN         NUMBER           := FND_GLOBAL.RESP_APPL_ID,
        p_resp_id                  IN         NUMBER           := FND_GLOBAL.RESP_ID,
        p_user_id                  IN         NUMBER           := FND_GLOBAL.USER_ID,
        p_login_id                 IN         NUMBER           := NULL,
        p_transaction_control      IN         VARCHAR2         := FND_API.G_TRUE,
        p_Charges_Rec              IN         Charges_Rec_Type := G_MISS_CHRG_REC
	) ;

PROCEDURE Update_Charge_Details(
        p_api_version              IN         NUMBER,
        p_init_msg_list            IN         VARCHAR2         := FND_API.G_FALSE,
        p_commit                   IN         VARCHAR2         := FND_API.G_FALSE,
        p_validation_level         IN         NUMBER           := FND_API.G_VALID_LEVEL_FULL,
        x_return_status            OUT NOCOPY VARCHAR2,
        x_msg_count                OUT NOCOPY NUMBER,
        x_object_version_number    OUT NOCOPY NUMBER,
        x_msg_data                 OUT NOCOPY VARCHAR2,
        p_resp_appl_id             IN         NUMBER           := FND_GLOBAL.RESP_APPL_ID,
        p_resp_id                  IN         NUMBER           := FND_GLOBAL.RESP_ID,
        p_user_id                  IN         NUMBER           := FND_GLOBAL.USER_ID,
        p_login_id                 IN         NUMBER           := NULL,
        p_transaction_control      IN         VARCHAR2         := FND_API.G_TRUE,
        p_Charges_Rec              IN         Charges_Rec_Type := G_MISS_CHRG_REC ,
	p_update_cost_detail       IN         VARCHAR2--added by bkanimoz for service costing
	) ;


-- Start of comments
--      API name        : Delete_Charge_Details
--      Type            : Public
--      Function        :
--      Pre-reqs        : None.
--      Parameters      :
--
--      IN              : p_api_version: 	Standard Version of API	 	            Required
--                        p_init_msg_list:                                                  Optional
--                        p_commit:             Indicates whether API should commit         Optional
--                        p_validation_level:                                               Optional
--                        p_transaction_control:
--                        p_estimate_detail_id:
--			  p_delete_cost_detail : Indicates if Costing API needs to be called
--
--      OUT             : x_return_status:
--                        x_msg_count:
--                        x_msg_data:
--
--      Version : Current version       11.5
--      Notes   : This API is a public API to Delete Charge Details.
--
-- End of comments

/*#
 * Deletes a service request charge line. This procedure deletes one charge line at a time.
 * For details on the parameters, please refer to the document on Metalink from the URL provided above.
 *
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:displayname Delete Service Request Charge Line
 * @rep:primaryinstance
 * @rep:metalink 390503.1 Oracle Teleservice Implementation Guide Release 12.0
*/

/**** Above text has been added to enable the integration repository to extract the data
      from the source code file and populate the integration repository schema so that
      Delete_Charge_Details API appears in the integration repository.
****/
Procedure  Delete_Charge_Details(
        p_api_version         IN         NUMBER,
        p_init_msg_list       IN         VARCHAR2 := FND_API.G_FALSE,
        p_commit              IN         VARCHAR2 := FND_API.G_FALSE,
        p_validation_level    IN         NUMBER   := FND_API.G_VALID_LEVEL_FULL,
        x_return_status       OUT NOCOPY VARCHAR2,
        x_msg_count           OUT NOCOPY NUMBER,
        x_msg_data            OUT NOCOPY VARCHAR2,
        p_transaction_control IN         VARCHAR2 := FND_API.G_TRUE,
        p_estimate_detail_id  IN         NUMBER   := NULL
	)  ;



Procedure  Delete_Charge_Details(
        p_api_version         IN         NUMBER,
        p_init_msg_list       IN         VARCHAR2 := FND_API.G_FALSE,
        p_commit              IN         VARCHAR2 := FND_API.G_FALSE,
        p_validation_level    IN         NUMBER   := FND_API.G_VALID_LEVEL_FULL,
        x_return_status       OUT NOCOPY VARCHAR2,
        x_msg_count           OUT NOCOPY NUMBER,
        x_msg_data            OUT NOCOPY VARCHAR2,
        p_transaction_control IN         VARCHAR2 := FND_API.G_TRUE,
        p_estimate_detail_id  IN         NUMBER   := NULL,
	p_delete_cost_detail  IN VARCHAR2)  ;--added by bkanimoz for service costing


-- Start of comments
--      API name        : Copy_Estimate
--      Type            : Public
--      Function        :
--      Pre-reqs        : None.
--      Parameters      :
--
--      IN              : p_api_version: 	Standard Version of API	 	            Required
--                        p_init_msg_list:                                                  Optional
--                        p_commit:             Indicates whether API should commit         Optional
--                        p_estimate_detail_id:                                             Required
--
--      OUT             : x_return_status:
--                        x_msg_count:
--                        x_msg_data:
--
--      Version : Current version       11.5
--      Notes   : This API is a public API to Copy Estimates To Actuals.
--
-- End of comments

/*#
 * Converts an estimate to a charge line ready for submission to Oracle Order Management. This
 * procedure copies one charge line of type Estimate and creates a new line of type Actual.
 * For details on the parameters, please refer to the document on Metalink from the URL provided above.
 *
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:displayname Process Service Request Charge Line Estimate
 * @rep:primaryinstance
 * @rep:metalink 390503.1 Oracle Teleservice Implementation Guide Release 12.0
*/

/**** Above text has been added to enable the integration repository to extract the data
      from the source code file and populate the integration repository schema so that
      Copy_Estimate API appears in the integration repository.
****/


Procedure  Copy_Estimate(
        p_api_version         IN         NUMBER,
        p_init_msg_list       IN         VARCHAR2 := FND_API.G_FALSE,
        p_commit              IN         VARCHAR2 := FND_API.G_FALSE,
        p_transaction_control IN         VARCHAR2 := FND_API.G_TRUE,
        p_estimate_detail_id  IN         NUMBER   := NULL,
        x_estimate_detail_id  OUT NOCOPY NUMBER,
        x_return_status       OUT NOCOPY VARCHAR2,
        x_msg_count           OUT NOCOPY NUMBER,
        x_msg_data            OUT NOCOPY VARCHAR2)  ;

/**************************************************
 Procedure Body Log_Charges_Rec_Parameters
 This Procedure is used for Logging the charges record paramters.
 This Procedure will only be called from
 CS_Charge_Details_PUB and CS_Charge_Details_PVT Packages only.
**************************************************/

PROCEDURE Log_Charges_Rec_Parameters
( p_Charges_Rec              IN         Charges_Rec_Type
);

END CS_Charge_Details_PUB  ;

/
