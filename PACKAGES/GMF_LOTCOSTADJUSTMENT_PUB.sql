--------------------------------------------------------
--  DDL for Package GMF_LOTCOSTADJUSTMENT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMF_LOTCOSTADJUSTMENT_PUB" AUTHID CURRENT_USER AS
/* $Header: GMFPLCAS.pls 120.4.12000000.1 2007/01/17 16:52:36 appldev ship $ */
/*#
 * This is the public API for OPM Lot cost adjustments
 * This API can be used to create, update and delete
 * @rep:scope public
 * @rep:product GMF
 * @rep:displayname GMF Lot Cost Adjustment API
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY GMF_ITEM_COST
*/

TYPE Lc_Adjustment_Header_Rec_Type
IS
RECORD
(
adjustment_id                   gmf_lot_cost_adjustments.adjustment_id%TYPE
, legal_entity_id               gmf_fiscal_policies.legal_entity_id%TYPE
, cost_type_id                  cm_mthd_mst.cost_type_id%TYPE
, cost_mthd_code                cm_mthd_mst.cost_mthd_code%TYPE
, item_id                       mtl_item_flexfields.inventory_item_id%TYPE
, item_number                   mtl_item_flexfields.item_number%TYPE
, organization_id               mtl_parameters.organization_id%TYPE
, organization_code             mtl_parameters.organization_code%TYPE
, lot_number                    mtl_lot_numbers.lot_number%TYPE
, adjustment_date               DATE
, reason_code                   cm_reas_cds.reason_code%TYPE
, delete_mark                   gmf_lot_cost_adjustments.delete_mark%TYPE
, ATTRIBUTE1                    VARCHAR2(240)
, ATTRIBUTE2                    VARCHAR2(240)
, ATTRIBUTE3                    VARCHAR2(240)
, ATTRIBUTE4                    VARCHAR2(240)
, ATTRIBUTE5                    VARCHAR2(240)
, ATTRIBUTE6                    VARCHAR2(240)
, ATTRIBUTE7                    VARCHAR2(240)
, ATTRIBUTE8                    VARCHAR2(240)
, ATTRIBUTE9                    VARCHAR2(240)
, ATTRIBUTE10                   VARCHAR2(240)
, ATTRIBUTE11                   VARCHAR2(240)
, ATTRIBUTE12                   VARCHAR2(240)
, ATTRIBUTE13                   VARCHAR2(240)
, ATTRIBUTE14                   VARCHAR2(240)
, ATTRIBUTE15                   VARCHAR2(240)
, ATTRIBUTE16                   VARCHAR2(240)
, ATTRIBUTE17                   VARCHAR2(240)
, ATTRIBUTE18                   VARCHAR2(240)
, ATTRIBUTE19                   VARCHAR2(240)
, ATTRIBUTE20                   VARCHAR2(240)
, ATTRIBUTE21                   VARCHAR2(240)
, ATTRIBUTE22                   VARCHAR2(240)
, ATTRIBUTE23                   VARCHAR2(240)
, ATTRIBUTE24                   VARCHAR2(240)
, ATTRIBUTE25                   VARCHAR2(240)
, ATTRIBUTE26                   VARCHAR2(240)
, ATTRIBUTE27                   VARCHAR2(240)
, ATTRIBUTE28                   VARCHAR2(240)
, ATTRIBUTE29                   VARCHAR2(240)
, ATTRIBUTE30                   VARCHAR2(240)
, ATTRIBUTE_CATEGORY            VARCHAR2(30)
, user_name                     fnd_user.user_name%TYPE
);

TYPE lc_adjustment_dtls_Rec_Type
IS
RECORD
(
adjustment_dtl_id               gmf_lot_cost_adjustment_dtls.adjustment_dtl_id%TYPE
, adjustment_id                 gmf_lot_cost_adjustment_dtls.adjustment_id%TYPE
, cost_cmpntcls_id              cm_cmpt_mst.cost_cmpntcls_id%TYPE
, cost_cmpntcls_code            cm_cmpt_mst.cost_cmpntcls_code%TYPE
, cost_analysis_code            cm_alys_mst.cost_analysis_code%TYPE
, adjustment_cost               gmf_lot_cost_adjustment_dtls.adjustment_cost%TYPE
, TEXT_CODE                     NUMBER(22)
);

TYPE lc_adjustment_dtls_Tbl_Type
IS
TABLE OF lc_adjustment_dtls_Rec_Type
INDEX BY BINARY_INTEGER;

/*#
 * Lot cost adjustment Creation API
 * This API Creates a Lot cost adjustments in lot cost adjustment Basis Table
 * @param p_api_version Version Number of the API
 * @param p_init_msg_list Flag for initializing message list
 * @param p_commit Flag for commiting the data or not
 * @param x_return_status Return status 'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @param x_msg_count Number of messages on message stack
 * @param x_msg_data Actual message data from message stack
 * @param p_header_rec Adjustment header record
 * @param p_dtl_Tbl  Adjustment details record
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Lot Cost Adjustment API
*/
PROCEDURE Create_LotCost_Adjustment
(
p_api_version           IN              NUMBER
, p_init_msg_list       IN              VARCHAR2 := FND_API.G_FALSE
, p_commit              IN              VARCHAR2 := FND_API.G_FALSE
, x_return_status       OUT     NOCOPY  VARCHAR2
, x_msg_count           OUT     NOCOPY  NUMBER
, x_msg_data            OUT     NOCOPY  VARCHAR2
, p_header_rec          IN OUT  NOCOPY  Lc_Adjustment_Header_Rec_Type
, p_dtl_Tbl             IN OUT  NOCOPY  Lc_adjustment_dtls_Tbl_Type
);

 /*#
 * Lot cost adjustment Update API
 * This API updates a Lot cost adjustments in lot cost adjustment Basis Table
 * @param p_api_version Version Number of the API
 * @param p_init_msg_list Flag for initializing message list
 * @param p_commit Flag for commiting the data or not
 * @param x_return_status Return status 'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @param x_msg_count Number of messages on message stack
 * @param x_msg_data Actual message data from message stack
 * @param p_header_rec Adjustment header record
 * @param p_dtl_Tbl  Adjustment details record
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Lot Cost Adjustment API
 */
PROCEDURE Update_LotCost_Adjustment
(
p_api_version           IN              NUMBER
, p_init_msg_list       IN              VARCHAR2 := FND_API.G_FALSE
, p_commit              IN              VARCHAR2 := FND_API.G_FALSE
, x_return_status       OUT     NOCOPY  VARCHAR2
, x_msg_count           OUT     NOCOPY  NUMBER
, x_msg_data            OUT     NOCOPY  VARCHAR2
, p_header_rec          IN OUT  NOCOPY  Lc_Adjustment_Header_Rec_Type
, p_dtl_Tbl             IN OUT  NOCOPY  lc_adjustment_dtls_Tbl_Type
);

 /*#
 * Lot cost adjustment API for delete
 * This API deletes Lot cost adjustments from lot cost adjustment Basis Table
 * @param p_api_version Version Number of the API
 * @param p_init_msg_list Flag for initializing message list
 * @param p_commit Flag for commiting the data or not
 * @param x_return_status Return status 'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @param x_msg_count Number of messages on message stack
 * @param x_msg_data Actual message data from message stack
 * @param p_header_rec Adjustment header record
 * @param p_dtl_Tbl  Adjustment details record
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Delete Lot Cost Adjustment API
 */
PROCEDURE Delete_LotCost_Adjustment
(
p_api_version           IN              NUMBER
, p_init_msg_list       IN              VARCHAR2 := FND_API.G_FALSE
, p_commit              IN              VARCHAR2 := FND_API.G_FALSE
, x_return_status       OUT     NOCOPY  VARCHAR2
, x_msg_count           OUT     NOCOPY  NUMBER
, x_msg_data            OUT     NOCOPY  VARCHAR2
, p_header_rec          IN OUT  NOCOPY  Lc_Adjustment_Header_Rec_Type
, p_dtl_Tbl             IN OUT  NOCOPY  lc_adjustment_dtls_Tbl_Type
);

 /*#
 * Get Lot cost adjustment API
 * This API get the Lot cost adjustment details
 * @param p_api_version Version Number of the API
 * @param p_init_msg_list Flag for initializing message list
 * @param x_return_status Return status 'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @param x_msg_count Number of messages on message stack
 * @param x_msg_data Actual message data from message stack
 * @param p_header_rec Adjustment header record
 * @param p_dtl_Tbl  Adjustment details record
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Lot Cost Adjustment API
 */
PROCEDURE Get_LotCost_Adjustment
(
p_api_version           IN              NUMBER
, p_init_msg_list       IN              VARCHAR2 := FND_API.G_FALSE
, x_return_status       OUT     NOCOPY  VARCHAR2
, x_msg_count           OUT     NOCOPY  NUMBER
, x_msg_data            OUT     NOCOPY  VARCHAR2
, p_header_rec          IN OUT  NOCOPY  Lc_Adjustment_Header_Rec_Type
, p_dtl_Tbl             OUT     NOCOPY  lc_adjustment_dtls_Tbl_Type
);

END GMF_LotCostAdjustment_PUB ;

 

/
