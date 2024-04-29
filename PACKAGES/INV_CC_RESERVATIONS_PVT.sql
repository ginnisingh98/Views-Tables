--------------------------------------------------------
--  DDL for Package INV_CC_RESERVATIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_CC_RESERVATIONS_PVT" AUTHID CURRENT_USER AS
/* $Header: INVDRSVS.pls 120.1 2005/06/19 21:48:11 appldev  $ */
/*------------------------------------------------------------------*/
/* Define reservation record type to use from the Client */
FUNCTION Define_Reserv_Rec_Type return INV_RESERVATION_GLOBAL.MTL_RESERVATION_REC_TYPE ;
/* Procedure to delete all reservation */
--Added NOCOPY hint to x_error_code,x_return_status,x_msg_count,x_msg_data OUT
--parameters to comply with GSCC File.Sql.39 standard. Bug:4410902

PROCEDURE Delete_All_Reservation
(
   p_api_version_number      IN          NUMBER
,  p_init_msg_lst            IN          VARCHAR2 DEFAULT fnd_api.g_false
,  p_mtl_reservation_rec     IN          INV_RESERVATION_GLOBAL.MTL_RESERVATION_REC_TYPE
,  x_error_code              OUT NOCOPY  NUMBER
,  x_return_status           OUT NOCOPY  VARCHAR2
,  x_msg_count               OUT NOCOPY  NUMBER
,  x_msg_data                OUT NOCOPY  VARCHAR2
);
END;

 

/
