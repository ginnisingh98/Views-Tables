--------------------------------------------------------
--  DDL for Package GMF_ACTUAL_COST_ADJUSTMENT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMF_ACTUAL_COST_ADJUSTMENT_PUB" AUTHID CURRENT_USER AS
/* $Header: GMFPACAS.pls 120.3.12000000.1 2007/01/17 16:52:13 appldev ship $ */
/*#
 * This is the Actual cost adjustment public user interface for costing
 * It is used to create, update, delete the Actual cost adjustment related costs
 * @rep:scope public
 * @rep:product GMF
 * @rep:displayname GMF Actual Cost Adjustment API
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY GMF_ITEM_COST
*/
  TYPE ADJUSTMENT_REC_TYPE IS  RECORD
  (
  organization_id                 CM_ADJS_DTL.ORGANIZATION_ID%TYPE,
  organization_code               MTL_PARAMETERS.ORGANIZATION_CODE%TYPE,
  inventory_item_id               CM_ADJS_DTL.INVENTORY_ITEM_ID%TYPE,
  item_number                     MTL_ITEM_FLEXFIELDS.ITEM_NUMBER%TYPE,
  cost_type_id                    CM_ADJS_DTL.COST_TYPE_ID%TYPE,
  cost_mthd_code                  CM_MTHD_MST.COST_MTHD_CODE%TYPE,
  period_id                       CM_ADJS_DTL.PERIOD_ID%TYPE,
  calendar_code                   CM_CLDR_HDR_B.CALENDAR_CODE%TYPE,
  period_code                     CM_CLDR_DTL.PERIOD_CODE%TYPE,
  cost_cmpntcls_id                CM_ADJS_DTL.COST_CMPNTCLS_ID%TYPE,
  cost_cmpntcls_code              CM_CMPT_MST.COST_CMPNTCLS_CODE%TYPE,
  cost_analysis_code              CM_ADJS_DTL.COST_ANALYSIS_CODE%TYPE,
  cost_adjust_id                  CM_ADJS_DTL.COST_ADJUST_ID%TYPE,
  adjust_qty                      CM_ADJS_DTL.ADJUST_QTY%TYPE,
  adjust_qty_uom                  CM_ADJS_DTL.ADJUST_QTY_UOM%TYPE,
  adjust_cost                     CM_ADJS_DTL.ADJUST_COST%TYPE,
  reason_code                     CM_ADJS_DTL.REASON_CODE%TYPE,
  adjust_status                   CM_ADJS_DTL.ADJUST_STATUS%TYPE,
  creation_date                   CM_ADJS_DTL.CREATION_DATE%TYPE,
  last_update_login               CM_ADJS_DTL.LAST_UPDATE_LOGIN%TYPE,
  created_by                      CM_ADJS_DTL.CREATED_BY%TYPE,
  last_update_date                CM_ADJS_DTL.LAST_UPDATE_DATE%TYPE,
  last_updated_by                 CM_ADJS_DTL.LAST_UPDATED_BY%TYPE,
  text_code                       CM_ADJS_DTL.TEXT_CODE%TYPE,
  trans_cnt                       CM_ADJS_DTL.TRANS_CNT%TYPE,
  delete_mark                     CM_ADJS_DTL.DELETE_MARK%TYPE,
  request_id                      CM_ADJS_DTL.REQUEST_ID%TYPE,
  program_application_id          CM_ADJS_DTL.PROGRAM_APPLICATION_ID%TYPE,
  program_id                      CM_ADJS_DTL.PROGRAM_ID%TYPE,
  program_update_date             CM_ADJS_DTL.PROGRAM_UPDATE_DATE%TYPE,
  attribute_category              CM_ADJS_DTL.ATTRIBUTE_CATEGORY%TYPE,
  attribute1                      CM_ADJS_DTL.ATTRIBUTE1%TYPE,
  attribute2                      CM_ADJS_DTL.ATTRIBUTE2%TYPE,
  attribute3                      CM_ADJS_DTL.ATTRIBUTE3%TYPE,
  attribute4                      CM_ADJS_DTL.ATTRIBUTE4%TYPE,
  attribute5                      CM_ADJS_DTL.ATTRIBUTE5%TYPE,
  attribute6                      CM_ADJS_DTL.ATTRIBUTE6%TYPE,
  attribute7                      CM_ADJS_DTL.ATTRIBUTE7%TYPE,
  attribute8                      CM_ADJS_DTL.ATTRIBUTE8%TYPE,
  attribute9                      CM_ADJS_DTL.ATTRIBUTE9%TYPE,
  attribute10                     CM_ADJS_DTL.ATTRIBUTE10%TYPE,
  attribute11                     CM_ADJS_DTL.ATTRIBUTE11%TYPE,
  attribute12                     CM_ADJS_DTL.ATTRIBUTE12%TYPE,
  attribute13                     CM_ADJS_DTL.ATTRIBUTE13%TYPE,
  attribute14                     CM_ADJS_DTL.ATTRIBUTE14%TYPE,
  attribute15                     CM_ADJS_DTL.ATTRIBUTE15%TYPE,
  attribute16                     CM_ADJS_DTL.ATTRIBUTE16%TYPE,
  attribute17                     CM_ADJS_DTL.ATTRIBUTE17%TYPE,
  attribute18                     CM_ADJS_DTL.ATTRIBUTE18%TYPE,
  attribute19                     CM_ADJS_DTL.ATTRIBUTE19%TYPE,
  attribute20                     CM_ADJS_DTL.ATTRIBUTE20%TYPE,
  attribute21                     CM_ADJS_DTL.ATTRIBUTE21%TYPE,
  attribute22                     CM_ADJS_DTL.ATTRIBUTE22%TYPE,
  attribute23                     CM_ADJS_DTL.ATTRIBUTE23%TYPE,
  attribute24                     CM_ADJS_DTL.ATTRIBUTE24%TYPE,
  attribute25                     CM_ADJS_DTL.ATTRIBUTE25%TYPE,
  attribute26                     CM_ADJS_DTL.ATTRIBUTE26%TYPE,
  attribute27                     CM_ADJS_DTL.ATTRIBUTE27%TYPE,
  attribute28                     CM_ADJS_DTL.ATTRIBUTE28%TYPE,
  attribute29                     CM_ADJS_DTL.ATTRIBUTE29%TYPE,
  attribute30                     CM_ADJS_DTL.ATTRIBUTE30%TYPE,
  adjustment_ind                  CM_ADJS_DTL.ADJUSTMENT_IND%TYPE,
  subledger_ind                   CM_ADJS_DTL.SUBLEDGER_IND%TYPE,
  adjustment_date                 CM_ADJS_DTL.ADJUSTMENT_DATE%TYPE,
  user_name                       FND_USER.USER_NAME%TYPE
  );

/*#
 * This procedure validates the input parameters and invokes the private
 * actual cost adjustment procedure for creating a actual cost adjustment.
 * @param p_api_version indicates api version
 * @param p_init_msg_list initial message list
 * @param p_commit commit parameter
 * @param x_return_status return status
 * @param x_msg_count message count
 * @param x_msg_data message data
 * @param p_adjustment_rec actual cost adjustment record
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Actual Cost Adjustment API
*/
  PROCEDURE CREATE_ACTUAL_COST_ADJUSTMENT
  (
  p_api_version                      IN     NUMBER,
  p_init_msg_list                    IN     VARCHAR2 := FND_API.G_FALSE,
  p_commit                           IN     VARCHAR2 := FND_API.G_FALSE,
  x_return_status                    OUT NOCOPY         VARCHAR2,
  x_msg_count                        OUT NOCOPY         NUMBER,
  x_msg_data                         OUT NOCOPY         VARCHAR2,
  p_adjustment_rec                   IN  OUT NOCOPY     GMF_ACTUAL_COST_ADJUSTMENT_PUB.ADJUSTMENT_REC_TYPE
  );

/*#
 * Update Actaul cost adjustment
 * This is a PL/SQL procedure for update_actual_cost_adjustment API
 * This procedure validates the input parameters and invokes the private
 * actual cost adjustment procedure for update actual cost adjustment.
 * @param p_api_version indicates api version
 * @param p_init_msg_list initial message list
 * @param p_commit commit parameter
 * @param x_return_status return status
 * @param x_msg_count message count
 * @param x_msg_data message data
 * @param p_adjustment_rec actual cost adjustment record
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Actual Cost Adjustment API
*/
  PROCEDURE UPDATE_ACTUAL_COST_ADJUSTMENT
  (
  p_api_version                      IN     NUMBER,
  p_init_msg_list                    IN     VARCHAR2 := FND_API.G_FALSE,
  p_commit                           IN     VARCHAR2 := FND_API.G_FALSE,
  x_return_status                    OUT NOCOPY VARCHAR2,
  x_msg_count                        OUT NOCOPY         NUMBER,
  x_msg_data                         OUT NOCOPY         VARCHAR2,
  p_adjustment_rec                   IN  OUT NOCOPY     GMF_ACTUAL_COST_ADJUSTMENT_PUB.ADJUSTMENT_REC_TYPE
  );
/*#
 * Delete Actaul cost adjustment
 * This is a PL/SQL procedure for delete_actual_cost_adjustment API
 * This procedure validates the input parameters and invokes the private
 * actual cost adjustment procedure for delete actual cost adjustment.
 * @param p_api_version indicates api version
 * @param p_init_msg_list initial message list
 * @param p_commit commit parameter
 * @param x_return_status return status
 * @param x_msg_count message count
 * @param x_msg_data message data
 * @param p_adjustment_rec actual cost adjustment record
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Delete Actual Cost Adjustment API
*/
  PROCEDURE DELETE_ACTUAL_COST_ADJUSTMENT
  (
  p_api_version                      IN     NUMBER,
  p_init_msg_list                    IN     VARCHAR2 := FND_API.G_FALSE,
  p_commit                           IN     VARCHAR2 := FND_API.G_FALSE,
  x_return_status                    OUT NOCOPY         VARCHAR2,
  x_msg_count                        OUT NOCOPY         NUMBER,
  x_msg_data                         OUT NOCOPY         VARCHAR2,
  p_adjustment_rec                   IN  OUT NOCOPY     GMF_ACTUAL_COST_ADJUSTMENT_PUB.ADJUSTMENT_REC_TYPE
  );
/*#
 * Get the Actaul cost adjustment
 * This is a PL/SQL procedure for get_actual_cost_adjustment API
 * This procedure validates the input parameters and invokes the private
 * actual cost adjustment procedure to get actual cost adjustment.
 * @param p_api_version indicates api version
 * @param p_init_msg_list initial message list
 * @param x_return_status return status
 * @param x_msg_count message count
 * @param x_msg_data message data
 * @param p_adjustment_rec actual cost adjustment record
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Actual Cost Adjustment API
*/
  PROCEDURE GET_ACTUAL_COST_ADJUSTMENT
  (
  p_api_version                        IN      NUMBER,
  p_init_msg_list                      IN      VARCHAR2 := FND_API.G_FALSE,
  x_return_status                      OUT NOCOPY       VARCHAR2,
  x_msg_count                          OUT NOCOPY       NUMBER,
  x_msg_data                           OUT NOCOPY       VARCHAR2,
  p_adjustment_rec                     IN  OUT NOCOPY   GMF_ACTUAL_COST_ADJUSTMENT_PUB.ADJUSTMENT_REC_TYPE
  );

END GMF_ACTUAL_COST_ADJUSTMENT_PUB ;

 

/
