--------------------------------------------------------
--  DDL for Package CSD_LOGISTICS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSD_LOGISTICS_PUB" AUTHID CURRENT_USER as
/* $Header: csdplogs.pls 120.9.12000000.1 2007/01/19 18:18:10 appldev ship $ */
/*#
 * This is the public interface for managing repair logistics . It allows
 * creation/update  of repair logistics lines for a repair order.
 * @rep:scope public
 * @rep:product CSD
 * @rep:displayname  Repair Logistics
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY CSD_REPAIR_LOGISTICS
 */


Type Upd_Prodtxn_Rec_Type IS Record
( Product_Transaction_ID        NUMBER,
  Action_Type                   VARCHAR2(30),
  Action_Code                   VARCHAR2(30),
  Inventory_Item_Id             NUMBER,
  Txn_Billing_Type_Id           NUMBER,
  Price_List_ID                 NUMBER,
  Quantity                      NUMBER,
  Revision                      VARCHAR2(10),
  source_Serial_Number          VARCHAR2(50),
  source_Instance_Id            NUMBER,
  non_source_Serial_Number      VARCHAR2(50),
  non_source_Instance_Id        NUMBER,
  Lot_Number                    VARCHAR2(80),
  Sub_Inventory                 VARCHAR2(30),
  Return_Reason                 VARCHAR2(30),
  Return_By_Date                DATE,
  PO_Number                     VARCHAR2(50),
  Invoice_To_Org_Id             NUMBER,
  Ship_To_Org_Id                NUMBER,
  Unit_Of_Measure_Code          VARCHAR2(3),
  Charge                        NUMBER,
  Interface_To_OM_Flag          VARCHAR2(1),
  Book_Sales_Order_Flag         VARCHAR2(1),
  No_Charge_Flag                VARCHAR2(1),
  New_Order_Flag                VARCHAR2(1),
  Object_Version_Number         NUMBER ,
  Prod_Txn_Status               VARCHAR2(30),
  Context                       VARCHAR2(30),
  Attribute1                    VARCHAR2(150),
  Attribute2                    VARCHAR2(150),
  Attribute3                    VARCHAR2(150),
  Attribute4                    VARCHAR2(150),
  Attribute5                    VARCHAR2(150),
  Attribute6                    VARCHAR2(150),
  Attribute7                    VARCHAR2(150),
  Attribute8                    VARCHAR2(150),
  Attribute9                    VARCHAR2(150),
  Attribute10                   VARCHAR2(150),
  Attribute11                   VARCHAR2(150),
  Attribute12                   VARCHAR2(150),
  Attribute13                   VARCHAR2(150),
  Attribute14                   VARCHAR2(150),
  Attribute15                   VARCHAR2(150)
) ;





-- Start of Comments
-- Package name     : CSD_LOGISTICS_PUB
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

    /*#
    * Creates a new Repair Logistics line for the given Repair order. The Product Pransaction Id
    * Id is generated if a unique number is not passed. Returns the Product Pransaction Id.
	* Product transaction is a technical term for logistics line.
    * @param P_Api_Version api version number
    * @param P_Commit to decide whether to commit the transaction or not, default to false
    * @param P_Init_Msg_List initial the message stack, default to false
    * @param X_Return_Status return status
    * @param X_Msg_Count return message count
    * @param X_Msg_Data return message data
    * @param p_product_txn_rec Logistics line record.
    * @rep:scope public
    * @rep:lifecycle active
    * @rep:displayname Create Logistics Line
    */
/*
    X_product_transaction_id Generated key for the logistics line.
    X_order_header_id If he logistics line is interfaced, this indicates the order  header id created.
    X_order_line_id If the logistics line is interfaced, this indicates the order line id created..
*/
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

    /*#
    * Creates default logistics lines for the repair order based on repair type.
    * @param P_Api_Version api version number
    * @param P_Commit to decide whether to commit the transaction or not, default to false
    * @param P_Init_Msg_List initial the message stack, default to false
    * @param X_Return_Status return status
    * @param X_Msg_Count return message count
    * @param X_Msg_Data return message data
    * @param p_repair_line_id repair line for which the default logistics lines are to be created.
    * @rep:scope public
    * @rep:lifecycle active
    * @rep:displayname Create Default Logitics Lines.
    */

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
    /* procedure name: Update_Logistics_Line                                  */
    /* description                                                               */
    /* : This is the public API, whose main functionality is to update product*/
    /*   transaction line, interface with OM and progress product trxn line      */
    /*   status through BOOKED status. Once all validations are done it will     */
    /*   call private API Update_logistics_linbe which will continue to do some  */
	/*   more validations before actually perfoming user intended action.        */
    /* Note:                                                                     */
    /*                                                       */
    /* Parameters                                                                */
    /*   p_api_version           IN  Standard API paramater                      */
    /*   p_commit                IN  Standard API paramater                      */
    /*   x_return_status         OUT Standard API paramater                      */
    /*   x_msg_count             OUT Standard API paramater                      */
    /*   x_msg_data              OUT Standard API paramater                      */
    /*   p_Upd_ProdTxn_Rec IN  user input values are stored in this record       */
    /*---------------------------------------------------------------------------*/
    /*#
    * Updates a given Logistics line. It is interfaced/booked based on the input flags.
    * @param P_Api_Version api version number
    * @param P_Commit to decide whether to commit the transaction or not, default to false
    * @param P_Init_Msg_List initial the message stack, default to false
    * @param X_Return_Status return status
    * @param X_Msg_Count return message count
    * @param X_Msg_Data return message data
    * @param p_Upd_ProdTxn_Rec This contains the fields to be updated in the logistics line.
    * @param X_object_version_number Updated Object version number of the logistics line.
    * @param X_order_header_id If he logistics line is interfaced, this indicates the order  header id created.
    * @param X_order_line_id If the logistics line is interfaced, this indicates the order line id created.
    * @rep:scope public
    * @rep:lifecycle active
    * @rep:displayname Update Repair Logistics Line.
    */
    procedure Update_Logistics_Line(p_api_version            IN NUMBER,
                                    p_commit                 IN VARCHAR2,
                                    p_init_msg_list          IN VARCHAR2,
                                    x_return_status          OUT NOCOPY VARCHAR2,
                                    x_msg_count              OUT NOCOPY NUMBER,
                                    x_msg_data               OUT NOCOPY VARCHAR2,
                                    p_Upd_ProdTxn_Rec        IN CSD_LOGISTICS_PUB.Upd_ProdTxn_Rec_Type,
								    x_object_version_number  OUT NOCOPY NUMBER,
								    x_order_header_id        OUT NOCOPY NUMBER,
								    x_order_line_id          OUT NOCOPY NUMBER );



End CSD_LOGISTICS_PUB;
 

/
