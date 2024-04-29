--------------------------------------------------------
--  DDL for Package Body CSD_LOGISTICS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSD_LOGISTICS_PUB" as
/* $Header: csdplogb.pls 120.4 2005/09/29 17:19:40 takwong noship $ */
    /*#
    * This is the public interface for managing repair logistics . It allows
    * creation/update  of repair logistics lines for a repair order.
    * @rep:scope public
    * @rep:product CSD
    * @rep:displayname  Repair Logistics
    * @rep:lifecycle active
    * @rep:category BUSINESS_ENTITY REPAIR_LOGISTICS
    */
-- Start of Comments
-- Package name     : CSD_LOGISTICS_PUB
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSD_LOGISTICS_PUB';
G_FILE_NAME CONSTANT VARCHAR2(15) := 'csdplogb.pls';

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
    * @param X_product_transaction_id Generated key for the logistics line.
    * @param X_order_header_id If he logistics line is interfaced, this indicates the order  header id created.
    * @param X_order_line_id If the logistics line is interfaced, this indicates the order line id created..
    * @rep:scope public
    * @rep:lifecycle active
    * @rep:displayname Create Logistics Line
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
   )
IS

Begin

   --need to add more validation here

   CSD_LOGISTICS_PVT.Create_Logistics_Line(
         p_api_version         =>    p_api_version,
         p_commit              =>    p_commit,
         p_init_msg_list       =>    p_init_msg_list,
         p_validation_level    =>    p_validation_level,
         x_return_status       =>    x_return_status,
         x_msg_count           =>    x_msg_count,
         x_msg_data            =>    x_msg_data,
         p_product_txn_rec     =>    p_product_txn_rec,
         p_add_to_order_flag   =>    p_add_to_order_flag
      );

   IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;

End Create_Logistics_Line;


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
 )

IS

Begin

   --need to add more validation here

   CSD_LOGISTICS_PVT.Create_Default_Logistics
   (     p_api_version        =>    p_api_version,
         p_commit             =>    p_commit,
         p_init_msg_list      =>    p_init_msg_list,
         p_validation_level   =>    p_validation_level,
         p_repair_line_id     =>    p_repair_line_id,
         x_return_status      =>    x_return_status,
         x_msg_count          =>    x_msg_count,
         x_msg_data           =>    x_msg_data
   );

   IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;

End Create_Default_Logistics;

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
    * @param X_order_line_id If the logistics line is interfaced, this indicates the order line id created..
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
								    x_order_line_id          OUT NOCOPY NUMBER ) IS
	    --
	    l_api_name           CONSTANT VARCHAR2(30) := 'Update_Logistics_Line';
	    l_api_version_number CONSTANT NUMBER := 1.0;
	    --
	BEGIN
	    --
	    -- Standard Start of API savepoint
	    SAVEPOINT UPDATE_LOGISTICS_LINE_PUB;
	    -- Standard call to check for call compatibility.
	    IF NOT FND_API.Compatible_API_Call(l_api_version_number,
	                                       p_api_version,
	                                       l_api_name,
	                                       G_PKG_NAME)
	    THEN
	        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	    END IF;
	    -- Initialize message list if p_init_msg_list is set to TRUE.
	    IF FND_API.to_Boolean(p_init_msg_list)
	    THEN
	        FND_MSG_PUB.initialize;
	    END IF;
	    -- Initialize API return status to success
	    x_return_status := FND_API.G_RET_STS_SUCCESS;
	    --
	    -- API body
	    --
	    CSD_LOGISTICS_PVT.Update_Logistics_Line(P_Api_Version           => p_api_version,
	                                     P_Commit                => p_commit,
	                                     P_Init_Msg_List         => p_init_msg_list,
	                                     P_Validation_Level      => FND_API.G_VALID_LEVEL_FULL,
	                                     X_Return_Status         => x_return_status,
	                                     X_Msg_Count             => x_msg_count,
	                                     X_Msg_Data              => x_msg_data,
	                                     P_UPD_PRODTXN_REC       => p_Upd_ProdTxn_Rec,
	                                     X_OBJECT_VERSION_NUMBER => x_object_Version_number,
										 X_ORDER_HEADER_ID       => x_order_header_id,
										 X_ORDER_LINE_ID         => x_order_line_id);
	    --
	    -- Check return status from the above procedure call
	    IF not (x_return_status = FND_API.G_RET_STS_SUCCESS)
	    then
	        ROLLBACK TO UPDATE_LOGISTICS_LINE_PUB;
	        return;
	    END IF;
	    --
	    -- End of API body.
	    --
	    -- Standard check for p_commit
	    IF FND_API.to_Boolean(p_commit)
	    THEN
	        COMMIT WORK;
	    END IF;
	    -- Standard call to get message count and if count is 1, get message info.
	    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
	                              p_data  => x_msg_data);
	    --
	EXCEPTION
	    WHEN Fnd_Api.G_EXC_ERROR THEN
	        x_return_status := Fnd_Api.G_RET_STS_ERROR;
	        ROLLBACK TO UPDATE_LOGISTICS_LINE_PUB;
	        Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
	                                  p_data  => x_msg_data);
	        IF (Fnd_Log.level_error >= Fnd_Log.g_current_runtime_level)
	        THEN
	            Fnd_Log.STRING(Fnd_Log.level_error,
	                           'csd.plsql.csd_logistics_pub.update_logistics_pub',
	                           'EXC_ERROR[' || x_msg_data || ']');
	        END IF;

	    WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
	        x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
	        ROLLBACK TO UPDATE_LOGISTICS_LINE_PUB;
	        Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
	                                  p_data  => x_msg_data);
	        IF (Fnd_Log.level_exception >= Fnd_Log.g_current_runtime_level)
	        THEN
	            Fnd_Log.STRING(Fnd_Log.level_exception,
	                           'csd.plsql.csd_logistics_pub.update_logistics_pub',
	                           'EXC_UNEXP_ERROR[' || x_msg_data || ']');
	        END IF;
	    WHEN OTHERS THEN
	        x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
	        Rollback TO UPDATE_LOGISTICS_LINE_PUB;
	        IF Fnd_Msg_Pub.Check_Msg_Level(Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR)
	        THEN
	            Fnd_Msg_Pub.Add_Exc_Msg(G_PKG_NAME, l_api_name);
	        END IF;
	        Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
	                                  p_data  => x_msg_data);
	        IF (Fnd_Log.level_exception >= Fnd_Log.g_current_runtime_level)
	        THEN
	            Fnd_Log.STRING(Fnd_Log.level_exception,
	                           'csd.plsql.csd_logistics_pub.update_logistics_pub',
	                           'SQL MEssage[' || SQLERRM || ']');
	        END IF;

	End UPDATE_LOGISTICS_LINE;


End CSD_LOGISTICS_PUB;

/
