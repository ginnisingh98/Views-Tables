--------------------------------------------------------
--  DDL for Package GMF_BURDENDETAILS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMF_BURDENDETAILS_PUB" AUTHID CURRENT_USER AS
/* $Header: GMFPBRDS.pls 120.2.12010000.1 2008/07/30 05:33:25 appldev ship $ */
/*#
 * This is the public interface for OPM Overhead Details API
 * This API can be used for creation, updation, deletion, and
 * retrieval of Overhead Details
 * @rep:scope public
 * @rep:product GMF
 * @rep:displayname GMF Overhead Details API
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY GMF_BURDEN_DETAIL
*/

-- Definition of all the entities
TYPE Burden_Header_Rec_Type IS RECORD
(
  organization_id       cm_brdn_dtl.organization_id%TYPE                ,
  organization_code     mtl_parameters.organization_code%TYPE           ,
  inventory_item_id     mtl_item_flexfields.inventory_item_id%TYPE      ,
  item_number           mtl_item_flexfields.item_number%TYPE            ,
  period_id             cm_brdn_dtl.period_id%TYPE                      ,
  calendar_code         cm_brdn_dtl.calendar_code%TYPE                  ,
  period_code           cm_brdn_dtl.period_code%TYPE                    ,
  cost_type_id          cm_brdn_dtl.cost_type_id%TYPE                   ,
  cost_mthd_code        cm_brdn_dtl.cost_mthd_code%TYPE                 ,
  user_name             fnd_user.user_name%TYPE
  );

TYPE Burden_Dtl_Rec_Type IS RECORD
(
  burdenline_id         NUMBER                                          ,
  resources             cr_rsrc_mst.resources%TYPE                      ,
  cost_cmpntcls_id      NUMBER                                          ,
  cost_cmpntcls_code    cm_cmpt_mst.cost_cmpntcls_code%TYPE             ,
  cost_analysis_code    cm_alys_mst.cost_analysis_code%TYPE             ,
  burden_usage          NUMBER                                          ,
  item_qty              NUMBER                                          ,
  item_uom              cm_brdn_dtl.item_uom%TYPE                       ,
  burden_qty            NUMBER                                          ,
  burden_uom            cm_brdn_dtl.burden_uom%TYPE                     ,
  burden_factor         NUMBER                                          ,
  delete_mark           cm_brdn_dtl.delete_mark%TYPE      := 0
);

TYPE Burden_Dtl_Tbl_Type IS TABLE OF Burden_Dtl_Rec_Type
                        INDEX BY BINARY_INTEGER;

TYPE Burdenline_Ids_Rec_Type IS RECORD
(
  resources             cm_rsrc_dtl.resources%TYPE                      ,
  cost_cmpntcls_id      NUMBER                                          ,
  cost_analysis_code    cm_brdn_dtl.cost_analysis_code%TYPE             ,
  burdenline_id         NUMBER
);

TYPE Burdenline_Ids_Tbl_Type IS TABLE OF Burdenline_Ids_Rec_Type
                        INDEX BY BINARY_INTEGER;

/*#
 * Overhead Details Creation API
 * This API Creates a new Overhead Detail in the Overhead Details Table
 * @param p_api_version Version Number of the API
 * @param p_init_msg_list Flag for initializing message list
 * @param p_commit Flag for commiting the data or not
 * @param x_return_status Return status 'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @param x_msg_count Number of messages on message stack
 * @param x_msg_data Actual message data from message stack
 * @param p_header_rec Overhead header record type
 * @param p_dtl_tbl Overhead details table type
 * @param x_burdenline_ids Overhead details identifier table type
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Overhead Details API
*/
PROCEDURE Create_Burden_Details
(
  p_api_version                 IN  NUMBER                              ,
  p_init_msg_list               IN  VARCHAR2 := FND_API.G_FALSE         ,
  p_commit                      IN  VARCHAR2 := FND_API.G_FALSE         ,

  x_return_status               OUT NOCOPY VARCHAR2                     ,
  x_msg_count                   OUT NOCOPY VARCHAR2                     ,
  x_msg_data                    OUT NOCOPY VARCHAR2                     ,

  p_header_rec                  IN  Burden_Header_Rec_Type              ,
  p_dtl_tbl                     IN  Burden_Dtl_Tbl_Type                 ,

  x_burdenline_ids              OUT NOCOPY Burdenline_Ids_Tbl_Type
);

/*#
 * Overhead Details Updation API
 * This API Updates an Overhead Detail in the Overhead Details Table
 * @param p_api_version Version Number of the API
 * @param p_init_msg_list Flag for initializing message list
 * @param p_commit Flag for commiting the data or not
 * @param x_return_status Return status 'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @param x_msg_count Number of messages on message stack
 * @param x_msg_data Actual message data from message stack
 * @param p_header_rec Overhead header record type
 * @param p_dtl_tbl Overhead details table type
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Overhead Details API
*/
PROCEDURE Update_Burden_Details
(
  p_api_version                 IN  NUMBER                              ,
  p_init_msg_list               IN  VARCHAR2 := FND_API.G_FALSE         ,
  p_commit                      IN  VARCHAR2 := FND_API.G_FALSE         ,

  x_return_status               OUT NOCOPY VARCHAR2                     ,
  x_msg_count                   OUT NOCOPY VARCHAR2                     ,
  x_msg_data                    OUT NOCOPY VARCHAR2                     ,

  p_header_rec                  IN  Burden_Header_Rec_Type              ,
  p_dtl_tbl                     IN  Burden_Dtl_Tbl_Type
);

/*#
 * Overhead Details Deletion API
 * This API Deletes an Overhead Detail from the Overhead Details Table
 * @param p_api_version Version Number of the API
 * @param p_init_msg_list Flag for initializing message list
 * @param p_commit Flag for commiting the data or not
 * @param x_return_status Return status 'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @param x_msg_count Number of messages on message stack
 * @param x_msg_data Actual message data from message stack
 * @param p_header_rec Overhead header record type
 * @param p_dtl_tbl Overhead details table type
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Delete Overhead Details API
*/
PROCEDURE Delete_Burden_Details
(
  p_api_version                 IN  NUMBER                              ,
  p_init_msg_list               IN  VARCHAR2 := FND_API.G_FALSE         ,
  p_commit                      IN  VARCHAR2 := FND_API.G_FALSE         ,

  x_return_status               OUT NOCOPY VARCHAR2                     ,
  x_msg_count                   OUT NOCOPY VARCHAR2                     ,
  x_msg_data                    OUT NOCOPY VARCHAR2                     ,

  p_header_rec                  IN  Burden_Header_Rec_Type              ,
  p_dtl_tbl                     IN  Burden_Dtl_Tbl_Type
);

/*#
 * Overhead Details Retrieval API
 * This API Retrieves an Overhead Detail from the Overhead Details Table
 * @param p_api_version Version Number of the API
 * @param p_init_msg_list Flag for initializing message list
 * @param x_return_status Return status 'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @param x_msg_count Number of messages on message stack
 * @param x_msg_data Actual message data from message stack
 * @param p_header_rec Overhead header record type
 * @param x_dtl_tbl Overhead details table type
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Retrieve Overhead Details API
*/
PROCEDURE Get_Burden_Details
(
  p_api_version                 IN  NUMBER                              ,
  p_init_msg_list               IN  VARCHAR2 := FND_API.G_FALSE         ,

  x_return_status               OUT NOCOPY VARCHAR2                     ,
  x_msg_count                   OUT NOCOPY VARCHAR2                     ,
  x_msg_data                    OUT NOCOPY VARCHAR2                     ,

  p_header_rec                  IN  Burden_Header_Rec_Type              ,
  x_dtl_tbl                     OUT NOCOPY Burden_Dtl_Tbl_Type
);

END GMF_BurdenDetails_PUB ;


/
