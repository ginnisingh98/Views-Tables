--------------------------------------------------------
--  DDL for Package Body INV_CC_RESERVATIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_CC_RESERVATIONS_PVT" AS
/* $Header: INVDRSVB.pls 120.1 2005/06/19 21:51:22 appldev  $ */
/* This function can be used at client level to define Reservation REC Type */
FUNCTION Define_Reserv_Rec_Type RETURN INV_RESERVATION_GLOBAL.MTL_RESERVATION_REC_TYPE
IS
      l_reserve_rec INV_RESERVATION_GLOBAL.MTL_RESERVATION_REC_TYPE;
BEGIN
    RETURN l_reserve_rec;
EXCEPTION
when others
 then null;
END;

--Added NOCOPY hint to x_error_code,x_return_status,x_msg_count,x_msg_data OUT
--parameters to comply with GSCC File.Sql.39 standard. Bug:4410902
PROCEDURE Delete_All_Reservation
(
   p_api_version_number      IN         NUMBER
,  p_init_msg_lst            IN         VARCHAR2 DEFAULT fnd_api.g_false
,  p_mtl_reservation_rec     IN         INV_RESERVATION_GLOBAL.MTL_RESERVATION_REC_TYPE
,  x_error_code              OUT NOCOPY NUMBER
,  x_return_status           OUT NOCOPY VARCHAR2
,  x_msg_count               OUT NOCOPY NUMBER
,  x_msg_data                OUT NOCOPY VARCHAR2
)

IS
   l_api_version_number   CONSTANT NUMBER      := 1.0;
   l_init_msg_list        VARCHAR2(255) := FND_API.G_TRUE;
   l_api_name             CONSTANT VARCHAR2(30) := 'INV_Delete_All_Reservations';
   l_mtl_reservation_tbl        INV_RESERVATION_GLOBAL.MTL_RESERVATION_TBL_TYPE;
   l_mtl_reservation_rec        INV_RESERVATION_GLOBAL.MTL_RESERVATION_REC_TYPE;
   l_mtl_reservation_tbl_count NUMBER;
   l_return_status VARCHAR2(1);
   l_serial_number INV_RESERVATION_GLOBAL.SERIAL_NUMBER_TBL_TYPE;
   l_error_code NUMBER;
   l_count NUMBER;
   l_msg_count  NUMBER;
   l_msg_data   VARCHAR2(100);
BEGIN
   l_mtl_reservation_rec := p_mtl_reservation_rec ;
   l_mtl_reservation_rec := p_mtl_reservation_rec ;
   inv_reservation_pub.query_reservation(
       p_api_version_number => 1.0,
       x_return_status      => l_return_status,
       x_msg_count          => l_msg_count,
       x_msg_data           => l_msg_data,
       p_query_input        => l_mtl_reservation_rec,
       x_mtl_reservation_tbl => l_mtl_reservation_tbl,
       x_mtl_reservation_tbl_count => l_mtl_reservation_tbl_count,
       x_error_code        => l_error_code);

   if( l_return_status = FND_API.G_RET_STS_ERROR ) then
        raise FND_API.G_EXC_ERROR;
   elsif (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) then
        raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;
   FOR l_counter in  1..l_mtl_reservation_tbl_count
   LOOP
     l_mtl_reservation_rec := l_mtl_reservation_tbl(l_counter);
     inv_reservation_pub.delete_reservation
     (
        p_api_version_number       => 1.0
      , p_init_msg_lst             => fnd_api.g_false
      , x_return_status            => l_return_status
      , x_msg_count                => l_msg_count
      , x_msg_data                 => l_msg_data
      , p_rsv_rec                  => l_mtl_reservation_rec
      , p_serial_number            => l_serial_number
      );

      IF l_return_status = fnd_api.g_ret_sts_error THEN
         RAISE fnd_api.g_exc_error;
      END IF ;

      IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

   END LOOP;
      x_return_status := l_return_status;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data);

    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
            FND_MSG_PUB.Add_Exc_Msg
            (   l_api_name
            ,   'INV_Delete_All_Reservations'
            );
      END IF;
END;
END;

/
