--------------------------------------------------------
--  DDL for Package GMI_OM_ALLOC_API_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMI_OM_ALLOC_API_PUB" AUTHID CURRENT_USER AS
/* $Header: GMIOMAPS.pls 120.0 2005/05/25 16:02:38 appldev noship $ */
/*#
 * This is the public interface for Allocate OPM Orders API.
 * It contains the API for the creation, modification and deletion
 * of OPM allocation information for Order Management,
 * depending on an action code of INSERT, UPDATE or DELETE.
 * @rep:scope public
 * @rep:product GMI
 * @rep:displayname GMI Allocate OPM Orders API
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY GMI_OM_ALLOC_API_PUB
*/

TYPE Ic_Tran_Rec_Type  IS RECORD (
	 trans_id	IC_TRAN_PND.TRANS_ID%TYPE
	,line_id	IC_TRAN_PND.LINE_ID%TYPE
	,lot_id		IC_LOTS_MST.LOT_ID%TYPE
	,lot_no		IC_LOTS_MST.LOT_NO%TYPE
	,sublot_no	IC_LOTS_MST.SUBLOT_NO%TYPE
	,location 	VARCHAR2(50)
	,trans_qty	IC_TRAN_PND.TRANS_QTY%TYPE
	,trans_qty2	IC_TRAN_PND.TRANS_QTY2%TYPE
	,trans_um	IC_TRAN_PND.TRANS_UM%TYPE
	,reason_code	SY_REAS_CDS.REASON_CODE%TYPE
	,trans_date	DATE
	,line_detail_id IC_TRAN_PND.LINE_DETAIL_ID%TYPE
	,action_code	VARCHAR2(10));


/* ========================================================================
|    PARAMETERS:
|   	      p_api_version           Known api versionerror buffer
|             p_init_msg_list        FND_API.G_TRUE to reset list
|             p_commit		     Commit flag. API commits if this is set.
|             p_tran_rec	      Input transaction record
|             x_msg_count             number of messages in the list
|             x_msg_lst               text of messages
|             x_return_status         return status
|
|     VERSION   : current version         1.0
|                 initial version         1.0
|     COMMENT   : Creates,updates or deletes an opm reservation (allocation) in ic_tran_pnd
|		  table with information specified in p_tran_rec.
|
| ========================================================================  */

/*#
 * Allocate OPM Orders API
 * This API creates, updates or deletes an opm allocation in the ic_tran_pnd
 * table with information specified in p_tran_rec.
 * @param p_api_version Version Number of the API
 * @param p_init_msg_list Flag for initializing message list (default 'F')
 * @param p_commit Flag for commiting the data or not (default 'F')
 * @param p_tran_rec Input transaction record plus action code.
 * @param x_msg_count Number of messages on message stack
 * @param x_msg_data Actual message data from message stack
 * @param x_return_status Return status 'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname GMI Allocate OPM Orders API
*/


PROCEDURE Allocate_OPM_Orders (
	 	 p_api_version	 IN   NUMBER
	        ,p_init_msg_list IN   VARCHAR2 DEFAULT FND_API.G_FALSE
		,p_commit	 IN   VARCHAR2 DEFAULT FND_API.G_FALSE
                ,p_tran_rec      IN   ic_tran_rec_type
                ,x_return_status OUT NOCOPY  VARCHAR2
                ,x_msg_count     OUT NOCOPY  NUMBER
                ,x_msg_data      OUT NOCOPY  VARCHAR2 );

PROCEDURE Get_Item_Details (
		p_organization_id    IN	        NUMBER
   	      ,	p_inventory_item_id  IN  	NUMBER
   	      , x_ic_item_mst_rec    OUT NOCOPY IC_ITEM_MST_B%ROWTYPE
              , x_return_status      OUT NOCOPY VARCHAR2
              , x_msg_count          OUT NOCOPY NUMBER
              , x_msg_data           OUT NOCOPY VARCHAR2 );

PROCEDURE Get_Lot_Details (
	      p_item_id             IN         ic_lots_mst.item_id%TYPE
	    , p_lot_no              IN         ic_lots_mst.lot_no%TYPE
	    , p_sublot_no           IN         ic_lots_mst.sublot_no%TYPE
	    , p_lot_id              IN	       ic_lots_mst.lot_id%TYPE
	    , x_ic_lots_mst         OUT NOCOPY ic_lots_mst%ROWTYPE
	    , x_return_status       OUT NOCOPY VARCHAR2
	    , x_msg_count           OUT NOCOPY NUMBER
	    , x_msg_data            OUT NOCOPY VARCHAR2 );

PROCEDURE PrintMsg (
	      p_msg                 IN  VARCHAR2
   	    , p_file_name           IN  VARCHAR2 DEFAULT '0');
END GMI_OM_ALLOC_API_PUB;

 

/
