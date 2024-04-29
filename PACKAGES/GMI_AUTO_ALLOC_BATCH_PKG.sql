--------------------------------------------------------
--  DDL for Package GMI_AUTO_ALLOC_BATCH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMI_AUTO_ALLOC_BATCH_PKG" AUTHID CURRENT_USER AS
/*  $Header: GMIALLCS.pls 120.1 2005/06/17 15:04:03 appldev  $ */

/* ===========================================================================
 |                Copyright (c) 2000 Oracle Corporation                    |
 |                        TVP, Reading, England                            |
 |                         All rights reserved                             |
 ===========================================================================
 |  FILENAME                                                               |
 |      GMIALLCS.pls                                                       |
 |                                                                         |
 |  DESCRIPTION                                                            |
 |                                                                         |
 |                                                                         |
 |  HISTORY                                                                |
 |             - Auto_Allocate_Batch					   |
 ===========================================================================
*/

PROCEDURE Auto_Allocate_Batch (
                         errbuf          OUT NOCOPY VARCHAR2
			,retcode         OUT NOCOPY VARCHAR2
                        ,p_api_version   IN   NUMBER
                        ,p_init_msg_list IN   VARCHAR2 DEFAULT FND_API.G_FALSE
                        ,p_commit        IN   VARCHAR2 DEFAULT FND_API.G_FALSE
  		        ,p_batch_id 	 IN   NUMBER);


PROCEDURE Auto_Alloc_Wdd_Line (
			 p_api_version      IN    NUMBER
  			,p_init_msg_list    IN    VARCHAR2
  			,p_commit           IN    VARCHAR2
			,p_wdd_rec          IN    wsh_delivery_details%rowtype
			,p_batch_rec        IN    gmi_auto_allocation_batch%rowtype
			,x_number_of_rows   OUT NOCOPY NUMBER
			,x_qc_grade         OUT NOCOPY VARCHAR2
                        ,x_detailed_qty     OUT NOCOPY NUMBER
			,x_qty_UM           OUT NOCOPY VARCHAR2
			,x_detailed_qty2    OUT NOCOPY NUMBER
			,x_qty_UM2          OUT NOCOPY VARCHAR2
			,x_return_status    OUT NOCOPY VARCHAR2
			,x_msg_count        OUT NOCOPY NUMBER
			,x_msg_data         OUT NOCOPY VARCHAR2);


PROCEDURE Call_Pick_Confirm
  (  p_mo_line_id                    IN    NUMBER
  ,  p_delivery_detail_id            IN    NUMBER DEFAULT NULL
  ,  p_init_msg_list                 IN    NUMBER
  ,  p_move_order_type               IN    NUMBER
  ,  x_delivered_qty                 OUT   NOCOPY NUMBER
  ,  x_qty_UM                        OUT   NOCOPY VARCHAR2
  ,  x_delivered_qty2                OUT   NOCOPY NUMBER
  ,  x_qty_UM2                       OUT   NOCOPY VARCHAR2
  ,  x_return_status                 OUT   NOCOPY VARCHAR2
  ,  x_msg_count                     OUT   NOCOPY NUMBER
  ,  x_msg_data                      OUT   NOCOPY VARCHAR2
  );
PROCEDURE Get_Allocation_Record
   ( p_wdd_line          IN  wsh_delivery_details%rowtype
   , x_allocation_rec    OUT NOCOPY GMI_Auto_Allocate_PUB.gmi_allocation_rec
   , x_ic_item_mst_rec   OUT NOCOPY GMI_Reservation_Util.ic_item_mst_rec
   , x_return_status     OUT NOCOPY VARCHAR2
   , x_msg_count         OUT NOCOPY NUMBER
   , x_msg_data          OUT NOCOPY VARCHAR2
   ) ;


PROCEDURE Insert_Row (
 p_auto_alloc_batch_rec  IN gmi_auto_allocation_batch%ROWTYPE );

FUNCTION Submit_Allocation_Request(P_Batch_Id NUMBER)
 RETURN NUMBER;



END GMI_AUTO_ALLOC_BATCH_PKG;

 

/
