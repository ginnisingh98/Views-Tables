--------------------------------------------------------
--  DDL for Package Body ASO_RESERVATION_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_RESERVATION_INT" as
/* $Header: asoprsvb.pls 120.1 2005/06/29 12:37:52 appldev ship $ */
-- Start of Comments
-- Package name     : aso_reservation_int
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

G_PKG_NAME  CONSTANT VARCHAR2(30):= 'ASO_RESERVATION_INT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'asoirsvb.pls';

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Create_reservation
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       P__Rec     IN _Rec_Type  Required
--
--   OUT NOCOPY /* file.sql.39 change */ :
--       x_return_status           OUT NOCOPY /* file.sql.39 change */   VARCHAR2
--       x_msg_count               OUT NOCOPY /* file.sql.39 change */   NUMBER
--       x_msg_data                OUT NOCOPY /* file.sql.39 change */   VARCHAR2
--   Version : Current version 2.0
--   End of Comments
--
PROCEDURE Create_reservation(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_line_rec                   IN   aso_quote_pub.qte_line_rec_type,
    p_shipment_rec               IN   aso_quote_pub.shipment_rec_type,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */   NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    X_quantity_reserved	         OUT NOCOPY /* file.sql.39 change */   NUMBER,
    X_reservation_id             OUT NOCOPY /* file.sql.39 change */   NUMBER
    )
IS
 l_rsv             inv_reservation_global.mtl_reservation_rec_type;
 l_dummy_sn        inv_reservation_global.serial_number_tbl_type;
 l_dummy_sn_out    inv_reservation_global.serial_number_tbl_type;
 l_api_name          CONSTANT VARCHAR2(30) := 'Create_Reservation' ;
 l_api_version_number CONSTANT NUMBER := '1.0';
 l_profile_name     varchar2(240);
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_RESERVATION_PUB;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
 -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

    -- initialize G_Debug_Flag
    ASO_DEBUG_PUB.G_Debug_Flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');

  l_rsv.reservation_id        :=  NULL;
  If p_shipment_rec.request_date = FND_API.G_MISS_DATE Or
     p_shipment_rec.request_date IS NULL Then
    l_rsv.requirement_date  := SYSDATE ;
  Else
    l_rsv.requirement_date  :=  p_shipment_rec.request_date ;
  End If;

 -- 11/2/2000 , For inventory organization fix, separating Master org
 -- and ship from org , for reservation we are defaulting the value of
 -- organization_id from profile ASO_SHIP_FROM_ORG_ID

  l_rsv.organization_id       :=
                      fnd_profile.value(name => 'ASO_SHIP_FROM_ORG_ID');
  If l_rsv.organization_id IS NULL Then
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
       select  user_profile_option_name
       into   l_profile_name
       from   fnd_profile_options_vl
       where  profile_option_name = 'ASO_SHIP_FROM_ORG_ID';

       FND_MESSAGE.Set_Name('ASO', 'ASO_API_NO_PROFILE_VALUE');
       fnd_message.set_token('PROFILE', l_profile_name);
       FND_MSG_PUB.ADD;
    END IF;
    raise FND_API.G_EXC_ERROR;
  End If;

  l_rsv.inventory_item_id     :=  p_line_rec.inventory_item_id;
  l_rsv.demand_source_type_id :=  FND_PROFILE.Value('ASO_TRX_SOURCE_TYPES');
  If l_rsv.demand_source_type_id IS NULL Then
   -- IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
   -- THEN
        FND_MESSAGE.Set_Name('ASO', 'ASO_SOURCE_TYPE_NOT_DEFINED');
        FND_MSG_PUB.ADD;
   --   END IF;
      RAISE FND_API.G_EXC_ERROR;
  End If;

  l_rsv.demand_source_name          := 'ORDER_CAPTURE';
  l_rsv.demand_source_header_id     := p_line_rec.quote_header_id;
  l_rsv.demand_source_line_id       := p_shipment_rec.shipment_id;
  l_rsv.demand_source_delivery      := NULL ;
  l_rsv.primary_uom_code            := p_line_rec.uom_code;
  l_rsv.primary_uom_id              := NULL;
  l_rsv.reservation_uom_code        := NULL;
  l_rsv.reservation_uom_id          := NULL;
  l_rsv.reservation_quantity        := NULL;
  l_rsv.primary_reservation_quantity:= p_shipment_rec.quantity;
  l_rsv.detailed_quantity           := NULL;
  l_rsv.autodetail_group_id         := NULL;
  l_rsv.external_source_code        := NULL;
  l_rsv.external_source_line_id     := NULL;
  l_rsv.supply_source_type_id       :=
               inv_reservation_global.g_source_type_inv;
  l_rsv.supply_source_header_id     := NULL;
  l_rsv.supply_source_line_id       := NULL;
  l_rsv.supply_source_name          := NULL;
  l_rsv.supply_source_line_detail   := NULL;
  l_rsv.revision                    := NULL;
  l_rsv.subinventory_code           := NULL;
  l_rsv.subinventory_id             := NULL;
  l_rsv.locator_id                  := NULL;
  l_rsv.lot_number                  := NULL;
  l_rsv.lot_number_id               := NULL;
  l_rsv.pick_slip_number            := NULL;
  l_rsv.lpn_id                      := NULL;
  l_rsv.attribute_category          := NULL;
  l_rsv.attribute1                  := NULL;
  l_rsv.attribute2                  := NULL;
  l_rsv.attribute3                  := NULL;
  l_rsv.attribute4                  := NULL;
  l_rsv.attribute5                  := NULL;
  l_rsv.attribute6                  := NULL;
  l_rsv.attribute7                  := NULL;
  l_rsv.attribute8                  := NULL;
  l_rsv.attribute9                  := NULL;
  l_rsv.attribute10                 := NULL;
  l_rsv.attribute11                 := NULL;
  l_rsv.attribute12                 := NULL;
  l_rsv.attribute13                 := NULL;
  l_rsv.attribute14                 := NULL;
  l_rsv.attribute15                 := NULL;
  l_rsv.ship_ready_flag             := NULL ;

  inv_reservation_pub.create_reservation(
    p_api_version_number       => 1.0 ,
    p_init_msg_lst             => fnd_api.g_false,
    x_return_status            => x_return_status,
    x_msg_count                => x_msg_count,
    x_msg_data                 => x_msg_data,
    p_rsv_rec                  => l_rsv,
    p_serial_number            => l_dummy_sn,
    x_serial_number            => l_dummy_sn_out,
    p_partial_reservation_flag => fnd_api.g_true,
    p_force_reservation_flag   => fnd_api.g_true,
    p_validation_flag          => fnd_api.g_true,
    x_quantity_reserved        => x_quantity_reserved,
    x_reservation_id           => x_reservation_id);

    l_dummy_sn := l_dummy_sn_out;

   -- Check return status from the above procedure call
      IF x_return_status = FND_API.G_RET_STS_ERROR then
          raise FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


   -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data  );

EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
END create_reservation;

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_reservation
--   Type    :  Public
--   Pre-Req :  reservation_id or (organization_id, inventory_item_id,
--              quote_header_id,quote_line_id) have to be provided.
--              If the value of an attribute of the existing reservation needs
--              update, the new value of the attribute should be assigned
--              to the attribute in p_shipment_rec.For attributes whose
--              value are not to be updated, the values of these attributes
--              in p_shipment_rec should be fnd_api.g_miss_xxx.
--   Parameters:

PROCEDURE Update_reservation(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_line_rec                   IN   aso_quote_pub.qte_line_rec_type,
    p_shipment_rec               IN   aso_quote_pub.shipment_rec_type,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */   NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */   VARCHAR2    )
IS
  l_rsv_old    inv_reservation_global.mtl_reservation_rec_type;
  l_rsv_new    inv_reservation_global.mtl_reservation_rec_type;
  l_dummy_sn   inv_reservation_global.serial_number_tbl_type;
  l_api_name   CONSTANT VARCHAR2(30) := 'Update_Reservation';
  l_api_version_number CONSTANT NUMBER   := 1.0;
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_RESERVATION_PUB;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
 -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


    -- initialize G_Debug_Flag
    ASO_DEBUG_PUB.G_Debug_Flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');


  l_rsv_old.reservation_id          := p_shipment_rec.reservation_id;
  l_rsv_old.organization_id         := p_line_rec.organization_id;
  l_rsv_old.inventory_item_id       := p_line_rec.inventory_item_id;
  l_rsv_old.demand_source_type_id   :=
           FND_PROFILE.Value('ASO_TRX_SOURCE_TYPES');
   If l_rsv_old.demand_source_type_id IS NULL Then
   -- IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
   -- THEN
        FND_MESSAGE.Set_Name('ASO', 'ASO_SOURCE_TYPE_NOT_DEFINED');
        FND_MSG_PUB.ADD;
    --  END IF;
      RAISE FND_API.G_EXC_ERROR;
  End If;

  l_rsv_old.demand_source_header_id := p_line_rec.quote_header_id;
  l_rsv_old.demand_source_line_id   := p_shipment_rec.shipment_id;

  --specify the new values
  l_rsv_new.primary_reservation_quantity := p_shipment_rec.quantity;
  l_rsv_new.requirement_date             := Nvl(p_shipment_rec.request_date,
                                                Sysdate);

  inv_reservation_pub.update_reservation(
         p_api_version_number        => 1.0,
         p_init_msg_lst              => fnd_api.g_false,
         x_return_status             => x_return_status,
         x_msg_count                 => x_msg_count,
         x_msg_data                  => x_msg_data,
         p_original_rsv_rec          => l_rsv_old,
         p_to_rsv_rec                => l_rsv_new,
         p_original_serial_number    => l_dummy_sn ,
         p_to_serial_number	     => l_dummy_sn ,
         p_validation_flag           => fnd_api.g_true
         );

  -- Check return status from the above procedure call
      IF x_return_status = FND_API.G_RET_STS_ERROR then
          raise FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

  -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data  );
EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
END update_reservation ;

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Delete_reservation
--   Type    :  Public
--   Pre-Req :
--   Parameters:

PROCEDURE Delete_reservation(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_line_rec                   IN   aso_quote_pub.qte_line_rec_type,
    p_shipment_rec               IN   aso_quote_pub.shipment_rec_type,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */   NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */   VARCHAR2
    )
IS
  l_rsv         inv_reservation_global.mtl_reservation_rec_type;
  l_dummy_sn    inv_reservation_global.serial_number_tbl_type;
  l_api_name                CONSTANT VARCHAR2(30) := 'Delete_Reservation';
  l_api_version_number      CONSTANT NUMBER   := 1.0;
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_RESERVATION_PUB;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
 -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


    -- initialize G_Debug_Flag
    ASO_DEBUG_PUB.G_Debug_Flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');


  l_rsv.reservation_id          := p_shipment_rec.reservation_id;
  l_rsv.organization_id         := p_line_rec.organization_id;
  l_rsv.inventory_item_id       := p_line_rec.inventory_item_id;
  l_rsv.demand_source_type_id   :=
           FND_PROFILE.Value('ASO_TRX_SOURCE_TYPES');
   If l_rsv.demand_source_type_id IS NULL Then
   -- IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
   -- THEN
        FND_MESSAGE.Set_Name('ASO', 'ASO_SOURCE_TYPE_NOT_DEFINED');
        FND_MSG_PUB.ADD;
    --  END IF;
      RAISE FND_API.G_EXC_ERROR;
  End If;

  l_rsv.demand_source_header_id := p_line_rec.quote_header_id;
  l_rsv.demand_source_line_id   := p_shipment_rec.shipment_id;

  inv_reservation_pub.delete_reservation(
     p_api_version_number           => 1.0,
     p_init_msg_lst                 => fnd_api.g_false,
     x_return_status                => x_return_status,
     x_msg_count                    => x_msg_count,
     x_msg_data                     => x_msg_data,
     p_rsv_rec                      => l_rsv,
     p_serial_number                => l_dummy_sn );

  -- Check return status from the above procedure call
      IF x_return_status = FND_API.G_RET_STS_ERROR then
          raise FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

   -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data  );
EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
END delete_reservation;

PROCEDURE Transfer_Reservation(
    P_Api_Version_Number         IN  NUMBER,
    P_Init_msg_list              In  VARCHAR2  := FND_API.G_FALSE,
    P_Commit                     IN  VARCHAR2  := FND_API.G_FALSE,
    P_Header_rec                 IN  ASO_QUOTE_PUB.qte_header_rec_type,
    P_Line_rec                   IN  ASO_QUOTE_PUB.qte_line_rec_type,
    P_shipment_rec               IN  ASO_QUOTE_PUB.shipment_rec_type,
    x_new_reservation_id         OUT NOCOPY /* file.sql.39 change */   NUMBER ,
    X_Return_Status              OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    X_Msg_Count                  OUT NOCOPY /* file.sql.39 change */   NUMBER,
    X_Msg_Data                   OUT NOCOPY /* file.sql.39 change */   VARCHAR2 ) IS
  -- declaration of variables
  l_api_version_number    NUMBER  := 1.0 ;
 l_api_name          CONSTANT VARCHAR2(30) := 'Transfer_Reservation' ;
  l_rsv_old               INV_RESERVATION_GLOBAL.Mtl_Reservation_Rec_Type ;
  l_rsv_new               INV_RESERVATION_GLOBAL.Mtl_Reservation_Rec_Type ;
  l_dummy_sn              INV_RESERVATION_GLOBAL.serial_number_tbl_type ;
  l_new_rsv_id        NUMBER ;
  l_return_status     VARCHAR2(240) ;
  l_msg_count         NUMBER ;
  l_msg_data          VARCHAr2(240) ;

BEGIN

     -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Standard Start of API savepoint
      SAVEPOINT TRANSFER_RESERVATION_PUB;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
 -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


    -- initialize G_Debug_Flag
    ASO_DEBUG_PUB.G_Debug_Flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');


  -- existing reservation
  l_rsv_old.reservation_id          := p_shipment_rec.reservation_id;
  l_rsv_old.organization_id         := p_line_rec.organization_id;
  l_rsv_old.inventory_item_id       := p_line_rec.inventory_item_id;
  l_rsv_old.demand_source_type_id   :=
           FND_PROFILE.Value('ASO_TRX_SOURCE_TYPES');
   If l_rsv_old.demand_source_type_id IS NULL Then
   -- IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
   -- THEN
        FND_MESSAGE.Set_Name('ASO', 'ASO_SOURCE_TYPE_NOT_DEFINED');
        FND_MSG_PUB.ADD;
    --  END IF;
      RAISE FND_API.G_EXC_ERROR;
  End If;

  l_rsv_old.demand_source_header_id := p_line_rec.quote_header_id;
  l_rsv_old.demand_source_line_id   := p_shipment_rec.shipment_id;

  --specify the values to which reservation is going to be transferred
  l_rsv_new.demand_source_header_id  := p_header_rec.order_id;
  l_rsv_new.demand_source_line_id    := p_shipment_rec.order_line_id;
  l_rsv_new.demand_source_type_id    :=
            INV_RESERVATION_GLOBAL.g_source_type_oe ;

  INV_RESERVATION_PUB.Transfer_Reservation (
     p_api_version_number => l_api_version_number ,
     p_init_msg_lst      => fnd_api.g_false ,
     x_return_status      => l_return_status ,
     x_msg_count          => l_msg_count ,
     x_msg_data           => l_msg_data ,
     p_is_transfer_supply => fnd_api.g_true ,
     p_original_rsv_rec   => l_rsv_old ,
     p_to_rsv_rec         => l_rsv_new ,
     p_original_serial_number => l_dummy_sn ,
     p_to_serial_number   => l_dummy_sn ,
     p_validation_flag    => fnd_api.g_true ,
     x_to_reservation_id     => l_new_rsv_id );

   -- Check return status from the above procedure call
      IF x_return_status = FND_API.G_RET_STS_ERROR then
          raise FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      x_new_reservation_id := l_new_rsv_id ;

   -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data  );
 EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
END Transfer_Reservation ;
End aso_reservation_int;

/
