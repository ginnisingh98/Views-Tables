--------------------------------------------------------
--  DDL for Package CSD_LOGISTICS_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSD_LOGISTICS_UTIL" AUTHID CURRENT_USER AS
    /* $Header: csdulogs.pls 120.7 2006/06/14 15:59:55 vparvath noship $ */

    /*---------------------------------------------------------------------------*/
    /* Record name: ItemAttributes_Rec_Type                                      */
    /* description:                                                              */
    /*   SU: Reccrd used for holding item attributes values for a given inventory*/
    /*   item id                                                                 */
    /*---------------------------------------------------------------------------*/
    TYPE ItemAttributes_Rec_Type IS RECORD(
        Serial_Code   NUMBER,
        Lot_Code      NUMBER,
        Revision_Code NUMBER,
        IB_Flag       VARCHAR2(1),
	   reservable_type VARCHAR2(1));
    -- Define global variables here
    g_Concatenated_Segments VARCHAR2(40);

    TYPE PRODTXN_DB_ATTR_REC IS RECORD (
        est_detail_id NUMBER,
        repair_line_id NUMBER,
        curr_submit_order_flag VARCHAR2(1),
        curr_book_order_flag VARCHAR2(1),
        curr_release_order_flag VARCHAR2(1),
        curr_ship_order_flag VARCHAR2(1),
        object_version_num NUMBER,
		txn_type_id   NUMBER);

    create_order EXCEPTION;
    /* Serial number reservation changes, begin*/

    type CSD_SERIAL_RESERVE_REC_TYPE IS RECORD (

       Inventory_Item_Id        MTL_RESERVATIONS.INVENTORY_ITEM_ID%type,
       Inv_organization_Id      MTL_RESERVATIONS.ORGANIZATION_ID%type,
       Reservation_uom_code     MTL_RESERVATIONS.RESERVATION_UOM_CODE%type,
       Serial_Number            MTL_RESERVATIONS.SERIAL_NUMBER%type,
       Lot_Number               MTL_RESERVATIONS.LOT_NUMBER%type,
       Locator_id               MTL_RESERVATIONS.LOCATOR_ID%type,
       Revision                 MTL_RESERVATIONS.REVISION%type,
       Order_Header_Id          MTL_RESERVATIONS.DEMAND_SOURCE_HEADER_ID%type,
       Order_line_Id            MTL_RESERVATIONS.DEMAND_SOURCE_LINE_ID%type,
       Subinventory_Code        MTL_RESERVATIONS.SUBINVENTORY_CODE%type,
       order_schedule_date      DATE

    );
    /* Serial number reservation changes, end*/
    /*---------------------------------------------------------------------------*/
    /* procedure name: Validate_PriceListID                                      */
    /* description : Validate Price List for a given Price List Id               */
    /* SU: comment this helper routine as this validation is done by charges API.*/
    /*---------------------------------------------------------------------------*/
    -- Procedure Validate_PriceListID
    --   ( p_Price_List_Id             IN NUMBER
    --   ) ;

    /*---------------------------------------------------------------------------*/
    /* procedure name: Validate_InventoryItemID                                  */
    /* description   : Helper routine that Validates item for a given item ID    */
    /*                 in the mtl system items table                             */
    /* Parameters Required:                                                      */
    /*   p_Inventory_Item_Id     IN  Item identifier                             */
    /*   x_return_status         OUT Standard API paramater                      */
    /*   x_msg_count             OUT Standard API paramater                      */
    /*   x_msg_data              OUT Standard API paramater                      */
    /*---------------------------------------------------------------------------*/
    PROCEDURE Validate_InventoryItemID(p_Inventory_Item_ID IN NUMBER,
                                       x_return_status     OUT NOCOPY VARCHAR2,
                                       x_msg_count         OUT NOCOPY NUMBER,
                                       x_msg_data          OUT NOCOPY VARCHAR2);

    /*---------------------------------------------------------------------------*/
    /* procedure name: Validate_TxnBillingTypeID                                 */
    /* description   : Helper rutine that validates Billing type for a given Txn */
    /*                 Billing Type ID,                                          */
    /* SU:02/24        Business Process Id, Line Category code, operating Unit   */
    /* Parameters Required:                                                      */
    /*   p_Txn_Billing_Type_Id   IN Txn billing type identifier                  */
    /*   p_BusinessProcessID     IN Business process id                          */
    /*   p_LineOrderCategoryCode IN Line Order Category Code                     */
    /*   p_Operating_Unit_Id     IN Org_ID                                       */
    /*---------------------------------------------------------------------------*/
    PROCEDURE Validate_TxnBillingTypeID(p_Txn_Billing_Type_Id   IN NUMBER,
                                        p_BusinessProcessID     IN NUMBER,
                                        p_LineOrderCategoryCode IN VARCHAR2,
                                        p_Operating_Unit_Id     IN NUMBER);

    /*---------------------------------------------------------------------------*/
    /* procedure name: Validate_Revision                                         */
    /* description   : Define helper routine that validates Revision for a given */
    /*                 Inventory Item Id                                         */
    /* Parameters Required:                                                      */
    /*   p_Inventory_Item_Id IN Item identifier                                  */
    /*   p_Revision          IN Revision from mtl serial numbers                 */
    /*---------------------------------------------------------------------------*/
    PROCEDURE Validate_Revision(p_Inventory_Item_Id IN NUMBER,
                                p_Revision          IN VARCHAR2);

    /*---------------------------------------------------------------------------*/
    /* procedure name: Validate_Instance_ID                                      */
    /* description :   SU:02/24: Validates Instance Id for a given               */
    /*                 Instance Id, Inventory Item Id, party id and account id   */
    /* SU:02/24        and returns serial number and instance number             */
    /* Parameters Required:                                                      */
    /*   p_Inventory_Item_Id IN  Item identifier                                 */
    /*   p_Instance_ID       IN  Instance ID to be validated                     */
    /*   p_Party_Id          IN  owner party identifier                          */
    /*   p_Account_ID        IN  owner account identifier                        */
    /*   x_Instance_Number   OUT Instance number from Item instances             */
    /*   x_Serial_Number     OUT Serial number from Item instances               */
    /*---------------------------------------------------------------------------*/
    PROCEDURE Validate_Instance_ID(p_Inventory_Item_Id IN NUMBER,
                                   p_Instance_ID       IN NUMBER,
                                   p_Party_Id          IN NUMBER,
                                   p_Account_ID        IN NUMBER,
                                   x_Instance_Number   OUT NOCOPY VARCHAR2,
                                   x_Serial_Number     OUT NOCOPY VARCHAR2);

    /*---------------------------------------------------------------------------*/
    /* procedure name: Validate_LotNumber                                        */
    /* description   : Validate Lot Number for a given Inventory Item Id and Lot */
    /* Parameters Required:                                                      */
    /*   p_Inventory_Item_Id IN Item identifier                                  */
    /*   p_Lot_Number        IN Lot number to be validated                       */
    /*---------------------------------------------------------------------------*/
    PROCEDURE Validate_LotNumber(p_Inventory_Item_Id IN NUMBER,
                                 p_Lot_Number        IN VARCHAR2);

    /*---------------------------------------------------------------------------*/
    /* procedure name: Validate_SerialNumber                                     */
    /* description   : Validate Serial Number for a given Inv Item Id            */
    /* Parameters Required:                                                      */
    /*   p_Inventory_Item_Id IN Item identifier                                  */
    /*   p_Serial_Number     IN Serial_Number from mtl serial numbers            */
    /*---------------------------------------------------------------------------*/
    PROCEDURE Validate_SerialNumber(p_Inventory_Item_Id IN NUMBER,
                                    p_Serial_Number     IN VARCHAR2);

    /*---------------------------------------------------------------------------*/
    /* procedure name: Validate_ReasonCode                                       */
    /* description   : Helper routing to validate Reason Code against the List   */
    /*                 of values in fnd lookups                                  */
    /* Parameters Required:                                                      */
    /*   p_ReasonCode -> Lookup value to validate                                */
    /*---------------------------------------------------------------------------*/
    PROCEDURE Validate_ReasonCode(p_ReasonCode IN VARCHAR2);

    /*---------------------------------------------------------------------------*/
    /* procedure name: Validate_UOM                                              */
    /* description   : Helper routine used to validate Unit Of Measure of an     */
    /*                 inventory item id                                         */
    /* Parameters Required:                                                      */
    /*   p_Inventory_Item_Id IN Item identifier                                  */
    /*   p_Unit_Of_Measure   IN Unit of Measure                                  */
    /*---------------------------------------------------------------------------*/
    PROCEDURE Validate_UOM(p_Inventory_Item_Id IN NUMBER,
                           p_Unit_Of_Measure   IN VARCHAR2);

    /*---------------------------------------------------------------------------*/
    /* procedure name: Validate_PartySiteID                                      */
    /* description   : Define Helper routine to validate Party_Site_Id for a     */
    /* SU:02/24:       given party, party site and party use type                */
    /* Parameters Required:                                                      */
    /*   p_Party_ID      IN Unique party identifier                              */
    /*   p_Party_Site_Id IN unique party site identifier                         */
    /*   p_Site_Use_type IN i.e. SHIP_TO and BILL_TO                             */
    /*---------------------------------------------------------------------------*/
    PROCEDURE Validate_PartySiteID(p_Party_ID      IN NUMBER,
                                   p_Party_Site_Id IN NUMBER,
                                   p_Site_Use_type IN VARCHAR2);

    /*---------------------------------------------------------------------------*/
    /* procedure name: Build_ProductTxnRec                                       */
    /* description   :                                                           */
    /*   Purpose of this API is to build  product txn record, by copying all the */
    /*   values from p_UpdateProdTxnRec to Product_Txn_Rec                       */
    /*   Do the check for G_MISS_XXX for following attributes and copy to        */
    /*   x_product_Txn_Rec accordingly.                                          */
    /*   Action_Type, Action_Code, Txn_Billing_Type_ID, Inventory_Item_Id,       */
    /*   Price_List_Id, Quantity, Revision,                                      */
    /*   source Serial_Number, non_source_Serial_Number, Lot_Number,             */
    /*   Sub_Inventory, Instance_Id, Return_Reason, Return_By_Date,              */
    /*   PO_Number, Invoice_To_Org_Id, Ship_To_Org_Id,                           */
    /*   Unit_Of_Measure                                                         */
    /*   Set values for WHO columns. Copy all DFF columns                        */
    /*   Copy Object_Version_Number column too                                   */
    /* Parameters Required:                                                      */
    /*   p_UpdateProductTrxn_Rec IN user input values are stored in this record  */
    /*   x_Product_Txn_Rec       IN OUT database values are stored in this record*/
    /*---------------------------------------------------------------------------*/
    PROCEDURE Build_ProductTxnRec(p_Upd_ProdTxn_Rec       IN CSD_LOGISTICS_PUB.Upd_ProdTxn_Rec_Type,
                                  x_Product_Txn_Rec       IN OUT NOCOPY Csd_Process_Pvt.Product_Txn_Rec);

    /*---------------------------------------------------------------------------*/
    /* procedure name: Get_Concatenated_Segments                                 */
    /* description   : Define helper routine to get concatenated segments name   */
    /*                 for a given Inventory Item Id                             */
    /* Parameters Required:                                                      */
    /*   p_Inventory_Item_Id     IN  Item identifier                             */
    /*   x_Concatenated_Segments OUT Concatenated segments from mtl system ites  */
    /* Notes: Once the Inventory_Item_Id is validated the global variable        */
    /*   g_Concatenated_Segments is populated and then is going to be used by    */
    /*   different helper routines to report error messages.                     */
    /*---------------------------------------------------------------------------*/
    PROCEDURE Get_Concatenated_Segments(p_inventory_item_Id     IN NUMBER,
                                        x_Concatenated_Segments OUT NOCOPY VARCHAR2);

    /*---------------------------------------------------------------------------*/
    /* procedure name: Validate_source_SerialNumber                             */
    /* description   : Helper Routine to validate source_Serial_Number for a    */
    /*                 given serial number                                       */
    /* Parameters Required:                                                      */
    /*   p_Inventory_Item_Id     IN  Item identifier                             */
    /*   x_Concatenated_Segments OUT Concatenated segments from mtl system ites  */
    /*---------------------------------------------------------------------------*/
    PROCEDURE Validate_source_SerialNumber(p_Inventory_Item_ID   IN NUMBER,
                                           p_Serial_Number       IN VARCHAR2,
                                           p_Serial_Control_Code IN NUMBER);

    /*---------------------------------------------------------------------------*/
    /* procedure name: Set_ProductTrxnRec_Flags                                  */
    /* description   :                                                           */
    /*   SU: This procedure is a helper routine to read the values from record   */
    /*   structure UpdateProductTrxn_rec, which is an input parameter for        */
    /*   wrapper API CSD_Process_PVt.Update_Product_Txn_Wrapr and set values     */
    /*   in record structure Product_Txn_Rec which is an out parameter           */
    /* On Error: This procedure is built not to raise any exceptions, as no      */
    /*   exceptions are expected in the body.                                    */
    /* Parameters Required:                                                      */
    /*   p_UpdateProductTrxn_Rec IN user input values are stored in this record  */
    /*   x_Product_Txn_Rec       IN OUT database values are stored in this record*/
    /*---------------------------------------------------------------------------*/
    Procedure Set_ProductTrxnRec_Flags(p_Upd_ProdTxn_Rec IN CSD_LOGISTICS_PUB.Upd_ProdTxn_Rec_Type,
                                       x_Product_Txn_Rec IN OUT NOCOPY CSD_PROCESS_PVT.Product_Txn_Rec);

    /*---------------------------------------------------------------------------*/
    /* procedure name: Validate_ProductTrxnRec                                   */
    /* description   :                                                           */
    /*   SU: This procedure is a helper routine to validate input values from    */
    /*   record structure UpdateProductTrxn_Rec to make sure that values passed  */
    /*   are valid values. This procedure should be called when it is determined */
    /*   that a specific attribute value can be changed by user.                 */
    /* On Error: X_Return_Status variable will have the return status value      */
    /*   X_Msg_Count will have the count of messages in message stack            */
    /*   X_Msg_Data will have a value if X_Msg_Count has value 1                 */
    /* Parameters Required:                                                      */
    /*   p_UpdateProductTrxn_Rec IN user input values are stored in this record  */
    /*   x_Product_Txn_Rec       IN OUT database values are stored in this record*/
    /*   x_return_status         OUT Standard API paramater                      */
    /*   x_msg_count             OUT Standard API paramater                      */
    /*   x_msg_data              OUT Standard API paramater                      */
    /*---------------------------------------------------------------------------*/
    PROCEDURE Validate_ProductTrxnRec(p_Upd_ProdTxn_Rec IN CSD_LOGISTICS_PUB.Upd_ProdTxn_Rec_Type,
                                      p_Product_Txn_Rec       IN Csd_Process_Pvt.Product_Txn_Rec,
                                      x_return_status         OUT NOCOPY VARCHAR2,
                                      x_msg_count             OUT NOCOPY NUMBER,
                                      x_msg_data              OUT NOCOPY VARCHAR2);

    /*---------------------------------------------------------------------------*/
    /* procedure name: Compare_ProductTrxnRec                                    */
    /* description   : compares all the input values with database values        */
    /*   SU: This API will compare user passed input values in record structure  */
    /*   UpdateProductTrxn_Rec and Database values captured in Record structure  */
    /*   Product_Txn_rec.This is because whether attributes values can be updated*/
    /*   depends on product transaction status value and action type values.     */
    /*   These validations are done in the following API and error message is    */
    /*   raised when an attribute value is not supposed to be changed.           */
    /* On Error : X_Return_Status variable will have the return status value     */
    /*   X_Msg_Count will have the count of messages in message stack            */
    /*   X_Msg_Data will have a value if X_Msg_Count has value 1                 */
    /* Parameters Required:                                                      */
    /*   p_UpdateProductTrxn_Rec IN user input values are stored in this record  */
    /*   p_Product_Txn_Rec       IN database values are stored in this record    */
    /*   x_return_status         OUT Standard API paramater                      */
    /*   x_msg_count             OUT Standard API paramater                      */
    /*   x_msg_data              OUT Standard API paramater                      */
    /*---------------------------------------------------------------------------*/
    PROCEDURE Compare_ProductTrxnRec(p_Upd_ProdTxn_Rec       IN CSD_LOGISTICS_PUB.Upd_ProdTxn_Rec_Type,
                                     p_Product_Txn_Rec       IN Csd_Process_Pvt.Product_Txn_Rec,
                                     x_return_status         OUT NOCOPY VARCHAR2,
                                     x_msg_count             OUT NOCOPY NUMBER,
                                     x_msg_data              OUT NOCOPY VARCHAR2);

    /*---------------------------------------------------------------------------*/
    /* procedure name: Get_ProdTrxnStatus_Meaning                                */
    /* description   : gets prod txn status meaning for a prod txn status code   */
    /*                 in fnd lookups                                            */
    /* Parameters Required:                                                      */
    /*   p_ProdTxnStatus_Code IN Lookup code for product transaction status      */
    /*---------------------------------------------------------------------------*/
    FUNCTION Get_ProdTrxnStatus_Meaning(p_ProdTxnStatus_Code IN VARCHAR2)
        RETURN VARCHAR2;

    /*---------------------------------------------------------------------------*/
    /* procedure name: Get_ItemAttributes                                        */
    /* description   :                                                           */
    /*   SU: Gets item attributes like serial number control code, revision      */
    /*   qty control code, lot number control code, IB Flag for a givent item    */
    /*   in service validation organzation                                       */
    /* Parameters Required:                                                      */
    /*   p_Inventory_Item_Id IN  Item identifier                                 */
    /*   x_ItemAttributes    OUT returned values include serial_code,            */
    /*   Revision_Code, Lot_Code and IB_Flag for a given Item                    */
    /*---------------------------------------------------------------------------*/
    PROCEDURE Get_ItemAttributes(p_Inventory_Item_Id IN NUMBER,
    				 p_inv_org_id        IN NUMBER,
                                 x_ItemAttributes    OUT NOCOPY ItemAttributes_Rec_Type);


    /*---------------------------------------------------------------------------*/
    /* procedure name: interface_prodtxn                                        */
    /* description   :                                                           */
    /*   interfaces a given product transaction including all the prod txns      */
    /*   under that incident id.                                                 */
    /* Parameters Required:                                                      */
    /*   p_product_txn_id IN  product transaction record                         */
    /*   x_return_status    OUT return status                                    */
    /*---------------------------------------------------------------------------*/
    procedure interface_prodtxn
    (
	 x_return_status        OUT  NOCOPY VARCHAR2,
      p_product_txn_rec      IN  CSD_PROCESS_PVT.PRODUCT_TXN_REC,
      p_prodtxn_db_attr      IN  CSD_LOGISTICS_UTIL.PRODTXN_DB_ATTR_REC,
	  px_order_rec    		 IN  OUT NOCOPY csd_process_pvt.om_interface_rec
    );

	   /*------------------------------------------------------------------------*/
    /* procedure name: book_prodtxn                                           */
    /* description   :                                                        */
    /*   Books the prod txn record in Depot schema                            */
    /* Parameters Required:                                                   */
    /*   p_product_txn_rec IN  product transaction record                     */
    /*   x_return_status    OUT return status                                 */
    /*------------------------------------------------------------------------*/
    procedure book_prodtxn
    (
	 x_return_status        OUT  NOCOPY VARCHAR2,
      p_product_txn_rec  IN  CSD_PROCESS_PVT.PRODUCT_TXN_REC,
      p_prodtxn_db_attr  IN  CSD_LOGISTICS_UTIL.PRODTXN_DB_ATTR_REC,
 	  px_order_rec       IN  OUT NOCOPY csd_process_pvt.om_interface_rec

    );

    /*------------------------------------------------------------------------*/
    /* procedure name: upd_prodtxn_n_chrgline                                 */
    /* description   :                                                        */
    /*   Updates the prod txn record in Depot schema and charge line          */
    /* Parameters Required:                                                   */
    /*   p_product_txn_rec IN  product transaction record                     */
    /*   x_return_status    OUT return status                                 */
    /*------------------------------------------------------------------------*/
     procedure upd_prodtxn_n_chrgline
    (
      p_product_txn_rec     IN OUT NOCOPY CSD_PROCESS_PVT.PRODUCT_TXN_REC,
      p_prodtxn_db_attr     IN  CSD_LOGISTICS_UTIL.PRODTXN_DB_ATTR_REC,
      x_estimate_detail_id  OUT NOCOPY NUMBER,
      x_repair_line_id      OUT NOCOPY NUMBER,
      x_add_to_order_flag   OUT NOCOPY VARCHAR2,
      x_add_to_order_id     OUT NOCOPY NUMBER,
      x_transaction_type_id OUT NOCOPY NUMBER
    ) ;


    FUNCTION get_prodtxn_db_attr (p_product_txn_id IN NUMBER)
      RETURN CSD_LOGISTICS_UTIL.PRODTXN_DB_ATTR_REC;


    FUNCTION get_order_rec (p_repair_line_id IN NUMBER)
      RETURN csd_process_pvt.om_interface_rec;


    /*------------------------------------------------------------------------*/
    /* procedure name: pickrelease_prodtxn                                    */
    /* description   :                                                        */
    /*   pick releases the prod txn record in Depot schema                    */
    /* Parameters Required:                                                   */
    /*   p_product_txn_rec IN  product transaction record                     */
    /*                                    */
    /*------------------------------------------------------------------------*/
    procedure pickrelease_prodtxn
    (
	 x_return_status        OUT  NOCOPY VARCHAR2,
      p_product_txn_rec  IN  CSD_PROCESS_PVT.PRODUCT_TXN_REC,
      p_prodtxn_db_attr  IN  CSD_LOGISTICS_UTIL.PRODTXN_DB_ATTR_REC,
 	  px_order_rec       IN  OUT NOCOPY csd_process_pvt.om_interface_rec
    );

        /*------------------------------------------------------------------------*/
    /* procedure name: ship_prodtxn                                    */
    /* description   :                                                        */
    /*   ships the prod txn record                   */
    /* Parameters Required:                                                   */
    /*   p_product_txn_rec IN  product transaction record                     */
    /*   x_return_status    OUT return status                                 */
    /*------------------------------------------------------------------------*/
    procedure ship_prodtxn
    (
	 x_return_status        OUT  NOCOPY VARCHAR2,
      p_product_txn_rec  IN  CSD_PROCESS_PVT.PRODUCT_TXN_REC,
      p_prodtxn_db_attr  IN  CSD_LOGISTICS_UTIL.PRODTXN_DB_ATTR_REC,
 	  px_order_rec       IN  OUT NOCOPY csd_process_pvt.om_interface_rec
    );


     /*------------------------------------------------------------------------*/
    /* procedure name: cancel_prodtxn                                    */
    /* description   :                                                        */
    /*   Cancels the prod txn record                   */
    /* Parameters Required:                                                   */
    /*   p_order_header_id IN  order header id                                */
    /*   p_order_line_id   IN  order line id                                */
    /*------------------------------------------------------------------------*/
    PROCEDURE cancel_prodtxn
    ( p_api_version      IN NUMBER,
      p_commit           IN VARCHAR2,
      p_init_msg_list    IN VARCHAR2,
      x_return_status    OUT NOCOPY VARCHAR2,
      x_msg_count        OUT NOCOPY NUMBER,
      x_msg_data         OUT NOCOPY VARCHAR2,
	 p_prod_txn_id      IN  NUMBER,
      p_order_header_id  IN  NUMBER,
      p_order_line_id    IN  NUMBER
    );

     /*------------------------------------------------------------------------*/
    /* procedure name: Reserve_Serial_Number                                    */
    /* description   :                                                        */
    /*   Reserves a given serial numbers for the given order */
    /* Parameters Required:                                                   */
    /*   p_serial_reserve_rec IN  CSD_SERIAL_RESERVE_REC_TYPE                 */
    /*   p_return_status   OUT  VARCHAR2(1)                       */
    /*------------------------------------------------------------------------*/
    PROCEDURE Reserve_Serial_Number
    ( p_serial_reserve_Rec      IN CSD_SERIAL_RESERVE_REC_TYPE,
      x_return_status    OUT NOCOPY VARCHAR2
    );

     /*------------------------------------------------------------------------*/
    /* procedure name: Unreserve_Serial_Number                                    */
    /* description   :                                                        */
    /*   Removes a reservation for the given order */
    /* Parameters Required:                                                   */
    /*   p_serial_reserve_rec IN  CSD_SERIAL_RESERVE_REC_TYPE                 */
    /*   p_return_status   OUT  VARCHAR2(1)                       */
    /*------------------------------------------------------------------------*/
    PROCEDURE Unreserve_Serial_Number
    ( p_serial_reserve_Rec      IN CSD_SERIAL_RESERVE_REC_TYPE,
      x_return_status    OUT NOCOPY VARCHAR2
    );

END Csd_Logistics_Util;
 

/
