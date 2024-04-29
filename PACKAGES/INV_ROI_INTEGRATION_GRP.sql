--------------------------------------------------------
--  DDL for Package INV_ROI_INTEGRATION_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_ROI_INTEGRATION_GRP" AUTHID CURRENT_USER AS
   /* $Header: INVPROIS.pls 120.1 2005/12/19 03:06:12 ragsriva noship $*/

--G_TRUE      CONSTANT NUMBER := 1;
--G_FALSE     CONSTANT NUMBER := 0;

g_ret_sts_success     CONSTANT VARCHAR2(1)           := 'S';
g_ret_sts_error       CONSTANT VARCHAR2(1)           := 'E';
g_ret_sts_unexp_error CONSTANT VARCHAR2(1)           := 'U';


/*Exception definitions */
g_exc_error                    EXCEPTION;
g_exc_unexpected_error         EXCEPTION;

/*Global variable for storing the INV:DEBUG TRACE profile value */
g_debug                        NUMBER     := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);

   PROCEDURE INV_VALIDATE_LOT(
                              x_return_status      		   OUT NOCOPY VARCHAR2              ,
                              x_msg_data           		   OUT NOCOPY VARCHAR2              ,
                              x_msg_count          		   OUT NOCOPY NUMBER                ,
                              p_api_version	 		         IN  NUMBER DEFAULT 1.0           ,
                              p_init_msg_lst	 		         IN  VARCHAR2 := FND_API.G_FALSE  ,
                              p_mtlt_rowid	 		         IN  ROWID                        ,
                              p_transaction_type_id 		   IN  VARCHAR2                     ,
                              p_new_lot			            IN  VARCHAR2                     ,
                              p_item_id	 		            IN  NUMBER                       ,
                              p_to_organization_id		      IN  NUMBER                       ,
                              p_lot_number			         IN  VARCHAR2                     ,
                              p_parent_lot_number			   IN  VARCHAR2                     ,
                              p_lot_quantity			         IN  NUMBER                       ,
                              x_lot_secondary_quantity	   IN  OUT NOCOPY  NUMBER           , ----bug 4025610
                              p_line_secondary_quantity	   IN  NUMBER                       ,
                              p_secondary_unit_of_measure   IN  VARCHAR2                     ,
                              p_transaction_unit_of_measure	IN  VARCHAR2                     ,
                              p_source_document_code		   IN  VARCHAR2                     ,
                              p_OE_ORDER_HEADER_ID	         IN  NUMBER                       ,
                              p_OE_ORDER_LINE_ID	         IN  NUMBER                       ,
                              p_rti_id				            IN  NUMBER                       ,
                              p_revision             		   IN  VARCHAR2                     ,
                              p_subinventory_code    		   IN  VARCHAR2                     ,
                              p_locator_id           		   IN  NUMBER                       ,
                              p_transaction_type            IN  VARCHAR2                     ,
                              p_parent_txn_type             IN  VARCHAR2,
                              p_lot_primary_qty             IN NUMBER -- Bug# 4233182
                              );

   PROCEDURE INV_Synch_Quantities(
                                          x_return_status      		      OUT NOCOPY VARCHAR2              ,
                                          x_msg_data           		      OUT NOCOPY VARCHAR2              ,
                                          x_msg_count          		      OUT NOCOPY NUMBER                ,
                                          x_sum_sourcedoc_quantity	      OUT NOCOPY NUMBER                ,
                                          x_sum_rti_secondary_quantity	   OUT NOCOPY NUMBER                ,
                                          p_api_version	 		            IN  NUMBER DEFAULT 1.0           ,
                                          p_init_msg_lst	 		            IN  VARCHAR2 := FND_API.G_FALSE  ,
                                          p_inventory_item_id    		      IN  NUMBER                       ,
                                          p_to_organization_id		         IN  NUMBER                       ,
                                          p_lot_number  			            IN  VARCHAR2                     ,
                                          p_transaction_unit_of_measure	   IN  VARCHAR2                     ,
                                          p_sourcedoc_unit_of_meaure       IN  VARCHAR2                     ,
                                          p_lot_quantity   			         IN  NUMBER                       ,
                                          p_line_secondary_quantity        IN  NUMBER                       ,
                                          p_secondary_unit_of_measure      IN  VARCHAR2                     ,
                                          p_lot_secondary_quantity         IN  NUMBER
                                          );

   PROCEDURE INV_New_lot(
                         x_return_status         	   			 OUT NOCOPY VARCHAR2                    ,
                         x_msg_count             	  			    OUT NOCOPY NUMBER                      ,
                         x_msg_data             	    			 OUT NOCOPY VARCHAR2                    ,
                         p_api_version	 		                   IN  NUMBER DEFAULT 1.0                 ,
                         p_init_msg_lst	 		                IN  VARCHAR2 := FND_API.G_FALSE        ,
                         p_source_document_code                 IN  VARCHAR2                           ,
                         p_item_id                              IN  NUMBER                             ,
                         p_from_organization_id                 IN  NUMBER                             ,
                         p_to_organization_id                   IN  NUMBER                             ,
                         p_lot_number                           IN  VARCHAR2                           ,
                         p_lot_quantity			                IN  NUMBER                             ,
                         p_lot_secondary_quantity	             IN  NUMBER                             ,
                         p_line_secondary_quantity              IN  NUMBER                             ,
                         p_primary_unit_of_measure              IN  VARCHAR2                           ,
                         p_secondary_unit_of_measure            IN  VARCHAR2                           ,
                         p_uom_code                             IN  VARCHAR2                           ,
                         p_secondary_uom_code                   IN  VARCHAR2                           ,
                         p_reason_id                            IN  NUMBER                             ,
                         P_MLN_REC                              IN  mtl_lot_numbers%ROWTYPE            ,
                         p_mtlt_rowid				                IN  ROWID
                        );


   FUNCTION inv_rma_lot_info_exists(
                                    x_msg_data              OUT NOCOPY VARCHAR2  ,
                                    x_msg_count          	OUT NOCOPY NUMBER	   ,
                                    x_count_rma_lots    		OUT NOCOPY NUMBER    ,
                                    p_oe_order_header_id 	IN VARCHAR2          ,
                                    p_oe_order_line_id		IN VARCHAR2
                                    )RETURN BOOLEAN ;



   PROCEDURE Inv_Validate_rma_quantity(
                                       x_allowed 		         OUT NOCOPY VARCHAR2              ,
                                       x_allowed_quantity 	   OUT NOCOPY NUMBER                ,
                                       x_return_status		   OUT NOCOPY VARCHAR2              ,
                                       x_msg_data           	OUT NOCOPY VARCHAR2              ,
                                       x_msg_count          	OUT NOCOPY NUMBER	               ,
                                       p_api_version	 		   IN  NUMBER DEFAULT 1.0           ,
                                       p_init_msg_list  	      IN  VARCHAR2 := FND_API.G_FALSE  ,
                                       p_item_id  		         IN  NUMBER                       ,
                                       p_lot_number 		      IN	 VARCHAR2                     ,
                                       p_oe_order_header_id 	IN	 NUMBER                       ,
                                       p_oe_order_line_id 		IN	 NUMBER                       ,
                                       p_rma_quantity 		   IN	 NUMBER                       ,
                                       p_trx_unit_of_measure	IN	 VARCHAR2                     ,
                                       p_rti_id		            IN  NUMBER                       ,
                                       p_to_organization_id	   IN	 NUMBER                       ,
                                       p_trx_quantity          IN  NUMBER
                                       );


   PROCEDURE Check_Item_Attributes(
                                   x_return_status          OUT    NOCOPY VARCHAR2
                                   , x_msg_count            OUT    NOCOPY NUMBER
                                   , x_msg_data             OUT    NOCOPY VARCHAR2
                                   , x_lot_cont             OUT    NOCOPY BOOLEAN
                                   , x_child_lot_cont       OUT    NOCOPY BOOLEAN
                                   , p_inventory_item_id    IN     NUMBER
                                   , p_organization_id      IN     NUMBER
                                   );




END INV_ROI_INTEGRATION_GRP;
 

/
