--------------------------------------------------------
--  DDL for Package Body CSD_LOGISTICS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSD_LOGISTICS_PVT" as
/* $Header: csdvlogb.pls 120.8.12010000.3 2010/01/11 10:56:53 subhat ship $ */
-- Start of Comments
-- Package name     : CSD_LOGISTICS_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSD_LOGISTICS_PVT';
G_FILE_NAME CONSTANT VARCHAR2(15) := 'csdvlogb.pls';

    /*----------------------------------------------------------------*/

    /*----------------------------------------------------------------*/

	procedure debug(p_msg VARCHAR2) is
	begin
		 --dbms_output.put_line(p_msg);
		 null;
	end;


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
   )
IS

Begin

--need to add more validation here
   csd_mass_rcv_pvt.create_product_txn (
         p_api_version         =>   p_api_version,
         p_commit              =>   p_commit,
         p_init_msg_list       =>   p_init_msg_list,
         p_validation_level    =>   p_validation_level,
         x_return_status       =>   x_return_status,
         x_msg_count           =>   x_msg_count,
         x_msg_data            =>   x_msg_data,
         p_product_txn_rec     =>   p_product_txn_rec,
         p_add_to_order_flag   =>   p_add_to_order_flag
      );

   IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;


End Create_Logistics_Line;


PROCEDURE Create_Default_Logistics
(     p_api_version           IN     NUMBER,
      p_commit                IN     VARCHAR2  := fnd_api.g_false,
      p_init_msg_list         IN     VARCHAR2  := fnd_api.g_false,
      p_validation_level      IN     NUMBER    := fnd_api.g_valid_level_full,
      p_repair_line_id        IN     NUMBER,
      x_return_status         OUT NOCOPY    VARCHAR2,
      x_msg_count             OUT NOCOPY    NUMBER,
      x_msg_data              OUT NOCOPY    VARCHAR2
 )

IS

Begin

--need to add more validation here
    Csd_Process_Pvt.create_default_prod_txn
              (p_api_version      =>   p_api_version,
               p_commit           =>   p_commit,
               p_init_msg_list    =>   p_init_msg_list,
               p_validation_level =>   p_validation_level,
               p_repair_line_id   =>   p_repair_line_id,
               x_return_status    =>   x_return_status,
               x_msg_count        =>   x_msg_count,
               x_msg_data         =>   x_msg_data);

   IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;


End Create_Default_Logistics;


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
    /*   p_UpdateProductTrxn_Rec IN  user input values are stored in this record */
    /*   X_Product_Txn_Rec       OUT database values are stored in this record   */
    /*---------------------------------------------------------------------------*/
    procedure Update_Logistics_Line(p_api_version            IN NUMBER,
                                    p_commit                 IN VARCHAR2,
                                    p_init_msg_list          IN VARCHAR2,
                                    p_validation_level       IN NUMBER,
                                    x_return_status          OUT NOCOPY VARCHAR2,
                                    x_msg_count              OUT NOCOPY NUMBER,
                                    x_msg_data               OUT NOCOPY VARCHAR2,
                                    p_Upd_ProdTxn_Rec     IN CSD_LOGISTICS_PUB.Upd_ProdTxn_Rec_Type,
								    x_object_version_number  OUT NOCOPY NUMBER,
								    x_order_header_id        OUT NOCOPY NUMBER,
								    x_order_line_id          OUT NOCOPY NUMBER ) IS

        -- Define local constants
        C_API_NAME       CONSTANT VARCHAR2(30) := 'Update_Logistics_Line';
        C_API_VERSION    CONSTANT NUMBER := 1.0;
        C_RO_STATUS_OPEN CONSTANT VARCHAR2(1) := 'O';
        C_YES            CONSTANT VARCHAR2(1) := 'Y';
        C_NO             CONSTANT VARCHAR2(1) := 'N';

        C_PROD_TXN_STS_ENTERED   CONSTANT VARCHAR2(30) := 'ENTERED';
        C_PROD_TXN_STS_BOOKED    CONSTANT VARCHAR2(30) := 'BOOKED';
        C_PROD_TXN_STS_RELEASED  CONSTANT VARCHAR2(30) := 'RELEASED';
        C_PROD_TXN_STS_SHIPPED   CONSTANT VARCHAR2(30) := 'SHIPPED';
        C_PROD_TXN_STS_RECEIVED  CONSTANT VARCHAR2(30) := 'RECEIVED';
        C_PROD_TXN_STS_SUBMITTED CONSTANT VARCHAR2(30) := 'SUBMITTED';

        -- Define Local Variables
        l_RO_Status_Meaning VARCHAR2(80);
        l_RO_NUMBER         VARCHAR2(30);
        l_Order_Header_ID   Number;
		l_ro_Status         CSD_REPAIRS.Status%type;

        -- Define a  record of type
        l_Product_Txn_Rec CSD_PROCESS_PVT.Product_Txn_Rec;

        -- Define a cursor that gets current values for product_Txn_V for a given
        -- product_Transaction_id
        -- RMA is qty is stored as negative in charges but in depot it is captured as
        -- positive value, so while retrieving from charges, should use ABS function.
        -- bug#8589873, FP of bug#8579443. subhat.
        -- select the existing value for picking_rule_id before calling update.
        CURSOR ProdTxn_Cur_Type IS
            SELECT A.Product_Transaction_Id,
                   A.Action_Type,
                   A.Action_Code,
                   A.Inventory_Item_Id,
                   A.Txn_Billing_Type_Id,
                   A.Price_List_Header_ID,
                   ABS(A.Estimate_Quantity),
                   A.Revision,
                   A.source_Serial_Number,
                   A.non_source_Serial_Number,
                   A.Lot_Number,
                   A.Sub_Inventory,
                   A.Return_Reason_Code,
                   A.Return_By_Date,
                   A.PO_Number,
                   A.Invoice_To_Org_Id,
                   A.Ship_To_Org_Id,
                   A.Unit_Of_Measure,
                   A.Charge,
                   A.No_Charge_Flag,
                   A.New_Order_Flag,
                   A.Object_Version_Number,
                   A.Transaction_Status,
                   A.Interface_To_OM_Flag,
                   A.Book_Sales_Order_flag,
                   A.Status,
                   A.Release_Sales_Order_Flag,
                   A.Ship_Sales_Order_Flag,
                   A.Order_Header_Id,
                   A.Order_Line_Id,
                   A.Repair_Line_Id,
                   A.Order_Number,
                   A.Estimate_Detail_Id,
                   A.Contract_Line_Id,
                   A.Business_Process_id,
                   B.incident_id,
                   A.Reference_Number,
                   A.picking_rule_id
              FROM CSD_Product_Txns_v A, CSD_REPAIRS B
             WHERE A.REPAIR_LINE_ID = B.REPAIR_LINE_ID
               AND Product_Transaction_Id =
                   p_Upd_ProdTxn_Rec.Product_Transaction_Id;

        -- Define a cursor that gets Repair NUMBER AND    Repair Status meaning for a given
        -- repair line id
        CURSOR RepairStatus_Cur_Type(p_Repair_Line_Id IN NUMBER) IS
            SELECT dra.Repair_NUMBER, fndl2.meaning Status_Meaning
              FROM Csd_Repairs dra, fnd_lookups fndl2
             WHERE dra.status           = fndl2.lookup_code
		   and fndl2.lookup_type    = 'CSD_REPAIR_STATUS'
		   and dra.repair_line_id = p_Repair_line_id;

        -- Define a cursor that gets currency code for a given Price List Id
        -- VP:SU:03/01
        Cursor PL_CurrencyCode_Cur_Type(p_Price_List_Id Number) Is
            SELECT currency_code
              FROM qp_list_headers_b
             WHERE list_header_id = p_price_list_id;

    BEGIN
        -- Procedure Body

		debug('Entered update_logistics_line pvt');

        -- Create a Save Point before calling Update program
        SAVEPOINT Update_Logistics_Line_Pvt;

        -- Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        -- Standard call to check for API Version compatibility.
        IF Not (FND_API.Compatible_API_Call(c_api_version,
                                            p_api_version,
                                            c_api_name,
                                            G_PKG_NAME))
        THEN
            RAISE FND_API.G_Exc_UnExpected_Error;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean(p_init_msg_list)
        THEN
            FND_MSG_PUB.initialize;
        END IF;

		debug('fetching the current record..Product_Transaction_Id['||p_Upd_ProdTxn_Rec.Product_Transaction_Id||']');
        -- bug#8589873, FP of bug#8579443. subhat.
        -- select the existing value for picking_rule_id before calling update.
        OPEN ProdTxn_Cur_Type;
        FETCH ProdTxn_Cur_Type
            INTO l_Product_Txn_Rec.Product_Transaction_Id,
			     l_Product_Txn_Rec.Action_Type,
				 l_Product_Txn_Rec.Action_Code,
				 l_Product_Txn_Rec.Inventory_Item_Id,
				 l_Product_Txn_Rec.Txn_Billing_Type_Id,
				 l_Product_Txn_Rec.price_list_id,
				 l_Product_Txn_Rec.Quantity,
				 l_Product_Txn_Rec.Revision,
				 l_Product_Txn_Rec.source_Serial_Number,
				 l_Product_Txn_Rec.non_source_Serial_Number,
				 l_Product_Txn_Rec.Lot_Number,
				 l_Product_Txn_Rec.Sub_Inventory,
				 l_Product_Txn_Rec.return_reason,
				 l_Product_Txn_Rec.Return_By_Date,
				 l_Product_Txn_Rec.PO_Number,
				 l_Product_Txn_Rec.Invoice_To_Org_Id,
				 l_Product_Txn_Rec.Ship_To_Org_Id,
				 l_Product_Txn_Rec.unit_of_measure_code,
				 l_Product_Txn_Rec.after_warranty_cost,
				 l_Product_Txn_Rec.No_Charge_Flag,
				 l_Product_Txn_Rec.New_Order_Flag,
				 l_Product_Txn_Rec.Object_Version_Number,
				 l_Product_Txn_Rec.Prod_Txn_Status,
				 l_Product_Txn_Rec.Interface_To_OM_Flag,
				 l_Product_Txn_Rec.Book_Sales_Order_flag,
				 l_ro_status,
			     l_Product_Txn_Rec.Release_Sales_Order_Flag,
				 l_Product_Txn_Rec.Ship_Sales_Order_Flag,
				 l_Product_Txn_Rec.Order_Header_Id,
				 l_Product_Txn_Rec.Order_Line_Id,
				 l_Product_Txn_Rec.Repair_Line_Id,
				 l_Product_Txn_Rec.Order_Number,
				 l_Product_Txn_Rec.Estimate_Detail_Id,
				 l_Product_Txn_Rec.Contract_Id,
				 l_Product_Txn_Rec.Business_Process_id,
				 l_Product_Txn_Rec.incident_id,
				 l_Product_Txn_Rec.source_instance_number,
				 l_Product_Txn_Rec.picking_rule_id;

        CLOSE ProdTxn_Cur_Type;
		debug('object version number fetched ['||l_Product_Txn_Rec.Object_Version_NUMBER||']');

        -- Validate Product_Transaction_Id is null
        CSD_PROCESS_UTIL.Check_Reqd_Param(p_param_value => p_Upd_ProdTxn_Rec.Product_Transaction_id,
                                          p_param_name  => 'Product Transaction ID',
                                          p_api_name    => C_API_Name);

	    debug('Validating the prod txn id');
        -- Validate the Product_Transaction_Id exists in csd_product_transactions
        IF NOT
            (CSD_PROCESS_UTIL.Validate_prod_txn_id(p_prod_txn_id => p_Upd_ProdTxn_Rec.Product_Transaction_id))
        THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        debug('ro status check...');
		-- Check Repair Order Status if it Hold or Closed then raise exception
        IF l_ro_Status <> C_RO_Status_OPEN
        THEN

            OPEN RepairStatus_Cur_Type(l_Product_Txn_Rec.Repair_Line_Id);
            FETCH RepairStatus_Cur_Type
                INTO l_RO_NUMBER, l_RO_Status_Meaning;
            CLOSE RepairStatus_Cur_Type;
            -- RAISE Error message
            FND_MESSAGE.SET_NAME('CSD', 'CSD_RO_NOT_OPEN_NO_PRODTXN_UPD');
            FND_MESSAGE.SET_TOKEN('RO_NUMBER', l_RO_NUMBER);
            FND_MESSAGE.SET_TOKEN('RO_STATUS', l_RO_Status_Meaning);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;

        END IF;

		debug('object version number check, db['||l_Product_Txn_Rec.Object_Version_NUMBER||']');
		debug('input ['||p_Upd_ProdTxn_Rec.Object_Version_Number||']');
        -- Check Object Version NUMBER. Object Version NUMBER FROM parameter should match the value in Database.
        IF l_Product_Txn_Rec.Object_Version_NUMBER <>
           p_Upd_ProdTxn_Rec.Object_Version_Number
        THEN

            FND_MESSAGE.SET_NAME('CSD', 'CSD_OBJECT_VERSION_NUMBER');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;

        END IF;

        -- Set flag attributes values for record UpdateProdTrxn_Rec
        Csd_Logistics_Util.Set_ProductTrxnRec_Flags(p_Upd_ProdTxn_Rec       => p_Upd_ProdTxn_Rec,
                                                    x_Product_Txn_Rec       => l_Product_Txn_Rec);

        -- Some of the attributes that are passed as input parameters to the API can not
        -- be updated by user, so make sure that those attributes are not updated

        IF l_Product_Txn_Rec.Prod_Txn_Status <> C_PROD_TXN_STS_ENTERED
        THEN

            -- Once product transaction line is interfaced then user can make changes
            -- to some attributes. List of these are listed in following API
            Csd_Logistics_Util.Compare_ProductTrxnRec(p_Upd_ProdTxn_Rec => p_Upd_ProdTxn_Rec,
                                                      p_Product_Txn_Rec       => l_Product_Txn_Rec,
                                                      x_Return_Status         => x_Return_Status,
                                                      x_Msg_Data              => x_Msg_Data,
                                                      x_Msg_Count             => x_Msg_Count);

            IF x_Return_Status <> FND_API.G_RET_STS_SUCCESS
            THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

        END IF;

        -- Build Product Txn Rec,
        Csd_Logistics_Util.Build_ProductTxnRec(p_Upd_ProdTxn_Rec => p_Upd_ProdTxn_Rec,
                                               x_Product_Txn_Rec       => l_Product_Txn_Rec);


--bug#6075825
/* Don't need this validation here.
        -- Call Validate_Product_Txn_Rec API to validate each attributes values.
        Csd_Logistics_Util.Validate_ProductTrxnRec(p_Upd_ProdTxn_Rec       => p_Upd_ProdTxn_Rec,
                                                   p_Product_Txn_Rec       => l_Product_Txn_Rec,
                                                   x_Return_Status         => x_Return_Status,
                                                   x_Msg_Data              => x_Msg_Data,
                                                   x_Msg_Count             => x_Msg_Count);

        IF x_Return_Status <> FND_API.G_RET_STS_SUCCESS
        THEN
            --dbms_output.put_line('Validation failed');
            RAISE FND_API.G_EXC_ERROR;
        END IF;
*/
        --Get Currency Code for a given Price List Id
        Open PL_CurrencyCOde_Cur_Type(l_Product_Txn_Rec.Price_List_ID);
        Fetch PL_CurrencyCode_Cur_Type
            Into l_Product_Txn_Rec.Currency_Code;
        Close PL_CurrencyCode_Cur_TYpe;

        -- Call Private API to Update Product Transaction Record
        --    CSD_LOGISTICS_PVT.Update_product_txn
        --dbms_output.put_line('Calling update');
        CSD_LOGISTICS_PVT.Update_product_txn(p_api_version      => 1.0,
                                           p_commit           => fnd_api.g_false,
                                           p_init_msg_list    => fnd_api.g_false,
                                           p_validation_level => fnd_api.g_valid_level_full,
                                           x_product_txn_rec  => l_Product_Txn_Rec,
                                           x_return_status    => x_Return_Status,
                                           x_msg_count        => x_Msg_Count,
                                           x_msg_data         => x_Msg_Data);

        IF x_Return_Status = FND_API.G_RET_STS_ERROR
        THEN
            RAISE FND_API.G_EXC_ERROR;
        ELSIF x_Return_Status = FND_API.G_RET_STS_UNEXP_ERROR
        THEN
            RAISE Fnd_Api.G_Exc_UnExpected_Error;
        END IF;

        x_object_version_number := l_Product_Txn_Rec.object_version_number;
		x_order_header_id       := l_Product_Txn_Rec.order_header_id;
		x_order_line_id         := l_Product_Txn_Rec.order_line_id;


    EXCEPTION

        WHEN Fnd_Api.G_Exc_Error THEN

            x_return_status := Fnd_Api.G_Ret_Sts_Error;

            ROLLBACK TO Update_Logistics_Line_pvt;

            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);

        WHEN Fnd_Api.G_Exc_UnExpected_Error THEN

            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

            ROLLBACK TO Update_Logistics_Line_pvt;

            FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);

        WHEN OTHERS THEN

            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

            ROLLBACK TO Update_Logistics_Line_pvt;

            IF Fnd_Msg_Pub.Check_Msg_Level(Fnd_Msg_Pub.G_Msg_Lvl_Unexp_Error)
            THEN
                Fnd_Msg_Pub.Add_Exc_Msg(G_PKG_NAME, C_api_name);
            END IF;

            FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);

    END Update_Logistics_Line;



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
                                 x_msg_data         OUT NOCOPY VARCHAR2) IS

        l_api_name    CONSTANT VARCHAR2(30) := 'UPDATE_PRODUCT_TXN';
        l_api_version CONSTANT NUMBER := 1.0;
        l_msg_count          NUMBER;
        l_msg_data           VARCHAR2(2000);
        l_msg_index          NUMBER;
        l_estimate_Rec       cs_charge_details_pub.charges_rec_type;
        l_prodtxn_db_attr    CSD_LOGISTICS_UTIL.PRODTXN_DB_ATTR_REC;
		l_order_Rec          csd_process_pvt.om_interface_rec;
		l_est_detail_id      NUMBER;
		l_add_to_order_id    NUMBER;
		l_add_to_order_flag  VARCHAR2(1);
		l_transaction_type_id  NUMBER;
		l_repair_line_id     NUMBER;

        create_order EXCEPTION;
        book_order EXCEPTION;
        release_order EXCEPTION;
        ship_order EXCEPTION;


        -- Variables used in FND Log
        l_error_level number := FND_LOG.LEVEL_ERROR;
        l_mod_name    varchar2(2000) := 'csd.plsql.csd_logistics_pvt.update_product_txn';

	   l_return_Status varchar2(1);

    BEGIN

	SAVEPOINT UPDATE_PRODUCT_TXN_PVT;

        l_prodtxn_db_attr := CSD_LOGISTICS_UTIL.get_prodtxn_db_attr(x_product_txn_rec.product_transaction_id);

        -- Debug message
        -----------------------------------------------------------------------------
        /*********************************************************************
        /* Code here got moved to CSD_LOGISTICS_UTIL.upd_prodtxn_n_chrgline
        **********************************************************************/
        -----------------------------------------------------------------------------
        CSD_LOGISTICS_UTIL.upd_prodtxn_n_chrgline(x_product_txn_rec ,
                                                  l_prodtxn_db_attr,
                                                  l_est_detail_id,
                                                  l_repair_line_id,
                                                  l_add_to_order_flag,
                                                  l_add_to_order_id,
                                                  l_transaction_type_id);

        x_product_txn_Rec.estimate_detail_id := l_est_detail_id;
        x_product_txn_Rec.repair_line_id     := l_repair_line_id;
        x_product_txn_Rec.add_to_order_flag  := l_add_to_order_flag;
        x_product_txn_Rec.order_header_id    := l_add_to_order_id;
        x_product_txn_rec.transaction_type_id := l_transaction_type_id;


        Debug('process_txn_flag      =' ||
              x_product_txn_rec.process_txn_flag);
        Debug('interface_to_om_flag  =' ||
              x_product_txn_rec.interface_to_om_flag);
        Debug('book_sales_order_flag =' ||
              x_product_txn_rec.book_sales_order_flag);
        Debug('release_sales_order_flag =' ||
              x_product_txn_rec.release_sales_order_flag);
        Debug('ship_sales_order_flag =' ||
              x_product_txn_rec.ship_sales_order_flag);


        IF x_product_txn_rec.process_txn_flag = 'Y'
        THEN


            l_order_Rec := CSD_LOGISTICS_UTIL.get_order_rec(x_product_txn_rec.repair_line_id);

            CSD_LOGISTICS_UTIL.interface_prodtxn( x_return_status => l_return_status,
		                     p_product_txn_rec => x_product_txn_rec,
                                     p_prodtxn_db_attr     => l_prodtxn_db_attr,
                                     px_order_rec          => l_order_rec);
            if NOT (l_Return_status = FND_API.G_RET_STS_SUCCESS) THEN
		  	raise create_order;
            END IF;

            IF l_prodtxn_db_attr.curr_book_order_flag <>
               x_product_txn_rec.book_sales_order_flag AND
               x_product_txn_rec.book_sales_order_flag = 'Y'
            THEN
                CSD_LOGISTICS_UTIL.book_prodtxn( x_return_status => l_return_status,
			p_product_txn_rec => x_product_txn_rec,
                        p_prodtxn_db_attr     => l_prodtxn_db_attr,
                        px_order_rec          => l_order_rec);
                if NOT (l_Return_status = FND_API.G_RET_STS_SUCCESS) THEN
				raise book_order;
                END IF;


            END IF; -- end of book order

            IF l_prodtxn_db_attr.curr_release_order_flag <>
               x_product_txn_rec.release_sales_order_flag AND
               x_product_txn_rec.release_sales_order_flag = 'Y'
            THEN
                    CSD_LOGISTICS_UTIL.pickrelease_prodtxn( x_return_status => l_return_status,
				                     p_product_txn_rec => x_product_txn_rec,
              						 p_prodtxn_db_attr     => l_prodtxn_db_attr,
              						 px_order_rec          => l_order_rec);
                    if(l_Return_status = FND_API.G_RET_STS_SUCCESS) THEN
                        raise release_order;
                    END IF;
            END IF; --end of pick-release sales order

            IF l_prodtxn_db_attr.curr_ship_order_flag <>
               x_product_txn_rec.ship_sales_order_flag AND
               x_product_txn_rec.ship_sales_order_flag = 'Y'
            THEN
                    CSD_LOGISTICS_UTIL.ship_prodtxn( x_return_status => l_return_status,
				         p_product_txn_rec => x_product_txn_rec,
                        	    p_prodtxn_db_attr     => l_prodtxn_db_attr,
                        	    px_order_rec          => l_order_rec);

				  if(l_Return_status = FND_API.G_RET_STS_SUCCESS) THEN
					raise ship_order;
				  END IF;
            END IF; -- end of ship sales order

        END IF; --end of process txn

        -- Api body ends here

        -- Standard check of p_commit.
        IF FND_API.To_Boolean(p_commit)
        THEN
            COMMIT WORK;
        END IF;

        -- Standard call to get message count and IF count is  get message info.
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                  p_data  => x_msg_data);
    EXCEPTION
        WHEN CREATE_ORDER THEN
		    rollback to UPDATE_PRODUCT_TXN_PVT;
            x_return_status := FND_API.G_RET_STS_ERROR;
        WHEN BOOK_ORDER THEN
		    rollback to UPDATE_PRODUCT_TXN_PVT;
            x_return_status := FND_API.G_RET_STS_ERROR;
        WHEN RELEASE_ORDER THEN
		    rollback to UPDATE_PRODUCT_TXN_PVT;
            x_return_status := FND_API.G_RET_STS_ERROR;
        WHEN SHIP_ORDER THEN
		    rollback to UPDATE_PRODUCT_TXN_PVT;
            x_return_status := FND_API.G_RET_STS_ERROR;
        WHEN FND_API.G_EXC_ERROR THEN
		    rollback to UPDATE_PRODUCT_TXN_PVT;
            x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		    rollback to UPDATE_PRODUCT_TXN_PVT;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
        WHEN OTHERS THEN
		    rollback to UPDATE_PRODUCT_TXN_PVT;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
                FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
            END IF;
            FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
    END update_product_txn;

End CSD_LOGISTICS_PVT;

/
