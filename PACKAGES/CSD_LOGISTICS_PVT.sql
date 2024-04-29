--------------------------------------------------------
--  DDL for Package CSD_LOGISTICS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSD_LOGISTICS_PVT" AUTHID CURRENT_USER as
/* $Header: csdvlogs.pls 120.4 2005/09/29 17:18:44 takwong noship $ */
-- Start of Comments
-- Package name     : CSD_LOGISTICS_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

PROCEDURE Create_Logistics_Line(
      p_api_version         IN              NUMBER,
      p_commit              IN              VARCHAR2     := fnd_api.g_false,
      p_init_msg_list       IN              VARCHAR2     := fnd_api.g_false,
      p_validation_level    IN              NUMBER       := fnd_api.g_valid_level_full,
      x_return_status       OUT NOCOPY      VARCHAR2,
      x_msg_count           OUT NOCOPY      NUMBER,
      x_msg_data            OUT NOCOPY      VARCHAR2,
      p_product_txn_rec     IN OUT NOCOPY   csd_process_pvt.product_txn_rec,
      p_add_to_order_flag   IN              VARCHAR2
   );


PROCEDURE Create_Default_Logistics
(     p_api_version           IN     NUMBER,
      p_commit                IN     VARCHAR2  := fnd_api.g_false,
      p_init_msg_list         IN     VARCHAR2  := fnd_api.g_false,
      p_validation_level      IN     NUMBER    := fnd_api.g_valid_level_full,
      p_repair_line_id        IN     NUMBER,
      x_return_status         OUT NOCOPY    VARCHAR2,
      x_msg_count             OUT NOCOPY    NUMBER,
      x_msg_data              OUT NOCOPY    VARCHAR2
 );

     /********************** ************* ****************************************/
    /*---------------------------------------------------------------------------*/
    /* procedure name: UUpdate_Logistics_Line                                  */
    /* description                                                               */
    /* : This is a private API, whose main functionality is to update product*/
    /*   transaction line, interface with OM and progress product trxn line      */
    /*   status through BOOKED status. Once all validations are done it will     */
    /*   private API Update_PRoduct_Txn which will continue to do some more      */
    /*   more validations before actually perfoming user intended action.        */
    /* Note:                                                                     */
    /*   Contract_Line_Id from CSD_Product_Txns_v is assigned to contract_id     */
    /*   in l_Product_Txn_Rec                                                    */
    /* Parameters                                                                */
    /*   p_api_version           IN  Standard API paramater                      */
    /*   p_commit                IN  Standard API paramater                      */
    /*   p_init_msg_list         IN  Standard API paramater                      */
    /*   x_return_status         OUT Standard API paramater                      */
    /*   x_msg_count             OUT Standard API paramater                      */
    /*   x_msg_data              OUT Standard API paramater                      */
    /*   p_Upd_ProductTxn_Rec IN  user input values are stored in this record */
    /*---------------------------------------------------------------------------*/
    procedure Update_Logistics_Line(p_api_version            IN NUMBER,
                                    p_commit                 IN VARCHAR2,
                                    p_init_msg_list          IN VARCHAR2,
                                    p_validation_level       IN NUMBER,
                                    x_return_status          OUT NOCOPY VARCHAR2,
                                    x_msg_count              OUT NOCOPY NUMBER,
                                    x_msg_data               OUT NOCOPY VARCHAR2,
                                    p_Upd_ProdTxn_Rec        IN CSD_LOGISTICS_PUB.Upd_ProdTxn_Rec_Type,
								    x_object_version_number  OUT NOCOPY NUMBER,
								    x_order_header_id        OUT NOCOPY NUMBER,
								    x_order_line_id          OUT NOCOPY NUMBER );


    /*----------------------------------------------------------------*/
    /* procedure name: update_product_txn                             */
    /* description   : procedure to update product txn lines.It is    */
    /*                 called from update_logistics_line API          */
    /*                 This is different from the process_pvt api     */
	/*                 in the sense that this does not commit if      */
	/*                 something fails (booking or release).          */
    /*----------------------------------------------------------------*/

    PROCEDURE update_product_txn(p_api_version      IN NUMBER,
                                 p_commit           IN VARCHAR2,
                                 p_init_msg_list    IN VARCHAR2,
                                 p_validation_level IN NUMBER,
                                 x_product_txn_rec  IN OUT NOCOPY CSD_PROCESS_PVT.PRODUCT_TXN_REC,
                                 x_return_status    OUT NOCOPY VARCHAR2,
                                 x_msg_count        OUT NOCOPY NUMBER,
                                 x_msg_data         OUT NOCOPY VARCHAR2);



End CSD_LOGISTICS_PVT;
 

/
