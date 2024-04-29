--------------------------------------------------------
--  DDL for Package GMF_ITEMCOST_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMF_ITEMCOST_PUB" AUTHID CURRENT_USER AS
/* $Header: GMFPCSTS.pls 120.1.12000000.1 2007/01/17 16:52:27 appldev ship $ */
/*#
 * This is the public interface for OPM Item Cost API.
 * This API can be used for creation, updation, deletion and
 * retrieval of item costs from the cost details table.
 * @rep:scope public
 * @rep:product GMF
 * @rep:displayname GMF Item Cost API
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY GMF_ITEM_COST
*/

-- Definition of all the entities
  TYPE header_rec_type IS RECORD
  (
  period_id                   cm_cmpt_dtl.period_id%TYPE,
  calendar_code	              cm_cldr_hdr_b.calendar_code%TYPE,
  period_code	                cm_cldr_dtl.period_code%TYPE,
  cost_type_id                cm_cmpt_dtl.cost_type_id%TYPE,
  cost_mthd_code	            cm_mthd_mst.cost_mthd_code%TYPE,
  organization_id             cm_cmpt_dtl.organization_id%TYPE,
  organization_code		        mtl_parameters.organization_code%TYPE,
  inventory_item_id		        cm_cmpt_dtl.inventory_item_id%TYPE,
  item_number		              mtl_item_flexfields.item_number%TYPE,
  user_name		                fnd_user.user_name%TYPE
  );

  TYPE this_level_dtl_rec_type IS RECORD
  (
  cmpntcost_id	              NUMBER,
  cost_cmpntcls_id	          NUMBER,
  cost_cmpntcls_code	        cm_cmpt_mst.cost_cmpntcls_code%TYPE,
  cost_analysis_code	        cm_cmpt_dtl.cost_analysis_code%TYPE,
  cmpnt_cost		              NUMBER,
  burden_ind		              NUMBER,
  total_qty		                NUMBER,
  costcalc_orig	              NUMBER,
  rmcalc_type	                NUMBER,
  delete_mark	                NUMBER,
  attribute1		              cm_cmpt_dtl.attribute1%TYPE,
  attribute2		              cm_cmpt_dtl.attribute2%TYPE,
  attribute3                  cm_cmpt_dtl.attribute3%TYPE,
  attribute4                  cm_cmpt_dtl.attribute4%TYPE,
  attribute5                  cm_cmpt_dtl.attribute5%TYPE,
  attribute6                  cm_cmpt_dtl.attribute6%TYPE,
  attribute7                  cm_cmpt_dtl.attribute7%TYPE,
  attribute8                  cm_cmpt_dtl.attribute8%TYPE,
  attribute9                  cm_cmpt_dtl.attribute9%TYPE,
  attribute10                 cm_cmpt_dtl.attribute10%TYPE,
  attribute11                 cm_cmpt_dtl.attribute11%TYPE,
  attribute12                 cm_cmpt_dtl.attribute12%TYPE,
  attribute13                 cm_cmpt_dtl.attribute13%TYPE,
  attribute14                 cm_cmpt_dtl.attribute14%TYPE,
  attribute15                 cm_cmpt_dtl.attribute15%TYPE,
  attribute16                 cm_cmpt_dtl.attribute16%TYPE,
  attribute17                 cm_cmpt_dtl.attribute17%TYPE,
  attribute18                 cm_cmpt_dtl.attribute18%TYPE,
  attribute19                 cm_cmpt_dtl.attribute19%TYPE,
  attribute20                 cm_cmpt_dtl.attribute20%TYPE,
  attribute21                 cm_cmpt_dtl.attribute21%TYPE,
  attribute22                 cm_cmpt_dtl.attribute22%TYPE,
  attribute23                 cm_cmpt_dtl.attribute23%TYPE,
  attribute24                 cm_cmpt_dtl.attribute24%TYPE,
  attribute25                 cm_cmpt_dtl.attribute25%TYPE,
  attribute26                 cm_cmpt_dtl.attribute26%TYPE,
  attribute27                 cm_cmpt_dtl.attribute27%TYPE,
  attribute28                 cm_cmpt_dtl.attribute28%TYPE,
  attribute29                 cm_cmpt_dtl.attribute29%TYPE,
  attribute30		              cm_cmpt_dtl.attribute30%TYPE,
  attribute_category	        cm_cmpt_dtl.attribute_category%TYPE
  );

  TYPE this_level_dtl_tbl_type IS TABLE OF this_level_dtl_rec_type INDEX BY BINARY_INTEGER;

  TYPE lower_level_dtl_rec_type IS RECORD
  (
  cmpntcost_id		            NUMBER,
  cost_cmpntcls_id	          NUMBER,
  cost_cmpntcls_code	        cm_cmpt_mst.cost_cmpntcls_code%TYPE,
  cost_analysis_code	        cm_cmpt_dtl.cost_analysis_code%TYPE,
  cmpnt_cost		              NUMBER,
  delete_mark	                NUMBER
  );

  TYPE lower_level_dtl_tbl_type IS TABLE OF lower_level_dtl_rec_type INDEX BY BINARY_INTEGER;

  TYPE costcmpnt_ids_rec_type IS RECORD
  (
  cost_cmpntcls_id	          NUMBER,
  cost_analysis_code	        cm_cmpt_dtl.cost_analysis_code%TYPE,
  cost_level		              NUMBER,
  cmpntcost_id		            NUMBER
  );

  TYPE costcmpnt_ids_tbl_type IS TABLE OF costcmpnt_ids_rec_type INDEX BY BINARY_INTEGER;

/*#
 * Item Cost Creation API
 * This API Creates a new Item Cost in the Cost Details table
 * @param p_api_version Version Number of the API
 * @param p_init_msg_list Flag for initializing message list
 * @param p_commit Flag for commiting the data or not
 * @param x_return_status Return status 'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @param x_msg_count Number of messages on message stack
 * @param x_msg_data Actual message data from message stack
 * @param p_header_rec Item cost header record type
 * @param p_this_level_dtl_tbl This level item cost detail table type
 * @param p_lower_level_dtl_Tbl Lower level item cost detail table type
 * @param x_costcmpnt_ids Component cost identifier table type
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Item Cost API
*/
  PROCEDURE Create_Item_Cost
  (
  p_api_version		      IN              NUMBER,
  p_init_msg_list	      IN              VARCHAR2 := FND_API.G_FALSE,
  p_commit		          IN              VARCHAR2 := FND_API.G_FALSE,
  x_return_status	          OUT NOCOPY  VARCHAR2,
  x_msg_count		            OUT NOCOPY  NUMBER,
  x_msg_data		            OUT NOCOPY  VARCHAR2,
  p_header_rec		      IN              Header_Rec_Type,
  p_this_level_dtl_tbl	IN              This_Level_Dtl_Tbl_Type,
  p_lower_level_dtl_Tbl	IN              Lower_Level_Dtl_Tbl_Type,
  x_costcmpnt_ids	          OUT NOCOPY  costcmpnt_ids_tbl_type
  );

/*#
 * Item Cost Updation API
 * This API Updates an Item Cost in the Cost Details table
 * @param p_api_version Version Number of the API
 * @param p_init_msg_list Flag for initializing message list
 * @param p_commit Flag for commiting the data or not
 * @param x_return_status Return status 'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @param x_msg_count Number of messages on message stack
 * @param x_msg_data Actual message data from message stack
 * @param p_header_rec Item cost header record type
 * @param p_this_level_dtl_tbl This level item cost detail table type
 * @param p_lower_level_dtl_Tbl Lower level item cost detail table type
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Item Cost API
*/
  PROCEDURE Update_Item_Cost
  (
  p_api_version		      IN              NUMBER,
  p_init_msg_list	      IN              VARCHAR2 := FND_API.G_FALSE,
  p_commit		          IN              VARCHAR2 := FND_API.G_FALSE,
  x_return_status	          OUT NOCOPY  VARCHAR2,
  x_msg_count		            OUT NOCOPY  NUMBER,
  x_msg_data		            OUT NOCOPY  VARCHAR2,
  p_header_rec		      IN              Header_Rec_Type,
  p_this_level_dtl_tbl	IN              This_Level_Dtl_Tbl_Type,
  p_lower_level_dtl_Tbl	IN              Lower_Level_Dtl_Tbl_Type
  );

/*#
 * Item Cost Deletion API
 * This API Deletes an Item Cost from the Cost Details table
 * @param p_api_version Version Number of the API
 * @param p_init_msg_list Flag for initializing message list
 * @param p_commit Flag for commiting the data or not
 * @param x_return_status Return status 'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @param x_msg_count Number of messages on message stack
 * @param x_msg_data Actual message data from message stack
 * @param p_header_rec Item cost header record type
 * @param p_this_level_dtl_tbl This level item cost detail table type
 * @param p_lower_level_dtl_Tbl Lower level item cost detail table type
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Delete Item Cost API
*/
  PROCEDURE Delete_Item_Cost
  (
  p_api_version		      IN              NUMBER,
  p_init_msg_list	      IN              VARCHAR2 := FND_API.G_FALSE,
  p_commit		          IN              VARCHAR2 := FND_API.G_FALSE,
  x_return_status	          OUT NOCOPY  VARCHAR2,
  x_msg_count		            OUT NOCOPY  NUMBER,
  x_msg_data		            OUT NOCOPY  VARCHAR2,
  p_header_rec		      IN              Header_Rec_Type,
  p_this_level_dtl_tbl	IN              This_Level_Dtl_Tbl_Type,
  p_lower_level_dtl_Tbl	IN              Lower_Level_Dtl_Tbl_Type
  );

/*#
 * Item Cost Retrieval API
 * This API Retrieves an Item Cost from the Cost Details table
 * @param p_api_version Version Number of the API
 * @param p_init_msg_list Flag for initializing message list
 * @param x_return_status Return status 'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @param x_msg_count Number of messages on message stack
 * @param x_msg_data Actual message data from message stack
 * @param p_header_rec Item cost header record type
 * @param x_this_level_dtl_tbl This level item cost detail table type
 * @param x_lower_level_dtl_Tbl Lower level item cost detail table type
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Retrieve Item Cost API
*/
  PROCEDURE Get_Item_Cost
  (
  p_api_version		      IN              NUMBER,
  p_init_msg_list	      IN              VARCHAR2 := FND_API.G_FALSE,
  x_return_status	          OUT NOCOPY  VARCHAR2,
  x_msg_count		            OUT NOCOPY  NUMBER,
  x_msg_data		            OUT NOCOPY  VARCHAR2,
  p_header_rec		      IN              Header_Rec_Type,
  x_this_level_dtl_tbl	    OUT NOCOPY  This_Level_Dtl_Tbl_Type,
  x_lower_level_dtl_Tbl	    OUT NOCOPY  Lower_Level_Dtl_Tbl_Type
  );

END GMF_ITEMCOST_PUB;

 

/
