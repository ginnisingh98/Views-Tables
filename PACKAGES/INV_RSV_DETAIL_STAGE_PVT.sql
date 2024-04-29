--------------------------------------------------------
--  DDL for Package INV_RSV_DETAIL_STAGE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_RSV_DETAIL_STAGE_PVT" AUTHID CURRENT_USER AS
/* $Header: INVRSDSS.pls 120.0.12010000.1 2010/03/10 13:06:58 viiyer noship $ */

------------------------------------------------------------------------------
-- Note
--   APIs in this package conforms to the PLSQL Business Object API Coding
--   Standard.
------------------------------------------------------------------------------

------------------------------------------------------------------------------
-- Please refers to inv_reservation_global package spec for the definitions
-- of mtl_reservation_rec_type, mtl_reservation_rec_type and
-- serial_number_tbl_type
------------------------------------------------------------------------------

------------------------------------------------------------------------------
-- Procedures and Functions
------------------------------------------------------------------------------
-- Procedure
--   process_reservation
--
-- Description
--   This api will detail and stage an org level or detailed reservation
--
-- Input Paramters
--   p_api_version_number       API version number (current version is 1.0)
--
--   p_init_msg_lst             Whether initialize the error message list or
--                              not.
--                              Should be fnd_api.g_false or fnd_api.g_true
--
--   p_rsv_rec                  Contains info to be used to process the
--                              reservation
--
--   p_serial_number            Contains serial numbers to be staged
--
--   p_rsv_status               'DETAIL' or 'STAGE'
--				IF DETAIL then the reservation would be detailed
--                              to the sku passed
--                              IF STAGE then the reservation would be
--                              detailed and then staged
--
-- Output Parameters
--   x_return_status            = fnd_api.g_ret_sts_success, if succeeded
--                              = fnd_api.g_ret_sts_exc_error, if an expected
--                              error occurred
--                              = fnd_api.g_ret_sts_unexp_error, if
--                              an unexpected error occurred
--
--   x_msg_count                Number of error message in the error message
--                              list
--
--   x_msg_data                 If the number of error message in the error
--                              message list is one, the error message
--                              is in this output parameter
--
 PROCEDURE Process_Reservation
 (
    p_api_version_number IN  NUMBER ,
    p_init_msg_lst       IN  VARCHAR2 DEFAULT fnd_api.g_false ,
    p_rsv_rec            IN  inv_reservation_global.mtl_reservation_rec_type ,
    p_serial_number      IN  inv_reservation_global.serial_number_tbl_type ,
    p_rsv_status         IN  VARCHAR2,
    x_return_status      OUT NOCOPY  VARCHAR2 ,
    x_msg_count          OUT NOCOPY  NUMBER   ,
    x_msg_data           OUT NOCOPY  VARCHAR2
 );

END inv_rsv_detail_stage_pvt ;

/
