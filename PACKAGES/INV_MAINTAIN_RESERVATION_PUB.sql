--------------------------------------------------------
--  DDL for Package INV_MAINTAIN_RESERVATION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_MAINTAIN_RESERVATION_PUB" AUTHID CURRENT_USER AS
/* $Header: INVPMRVS.pls 120.2.12010000.2 2009/08/11 20:35:10 viiyer ship $*/

------------------------------------------------------------------------------
-- Note
--   APIs in this package conforms to the PLSQL Business Object API Coding
--   Standard.
------------------------------------------------------------------------------


------------------------------------------------------------------------------
-- Please refers to inv_reservation_global package spec for the definitions
-- of mtl_reservation_rec_type, serial_number_tbl_type , mtl_rsv_tbl_type
-- mtl_Maint_Rsv_Rec_Type, Mtl_Maint_Rsv_Tbl_type
------------------------------------------------------------------------------

--
--
-- Procedure
--   MAINTAIN_RESERVATION
--
-- Description
--   API will handle changes to the resevation record based on the action code.
--
-- Input Paramters
--   p_api_version_number   API version number (current version is 1.0 Standard in parameter)
--   p_Init_Msg_lst         Flag to determine to initialize message stack for API, standard input parameter
--   p_header_id            Purchase order header id or requisition header id
--   p_line_id              Purchase order line id or requisition line id
--   p_line_location_id     Purchase order shipment id
--   p_distribution_id      Purchase order distribution_id
--   p_transaction_id       Receiving transaction id
--   p_ordered_quantity     Ordered quantity from order entry form
--   p_ordered_uom          Ordered uom from order entry form
--   p_action               different action codes for po approve/delete, requisition approve/delete
-- Output Parameters
--   x_Return_Status        Return Status of API, Standard out parameter
--   x_Msg_Count            Message count from the stack, standard out parameter
--   x_Msg_Data             Message from message stack, standard out parameter


PROCEDURE MAINTAIN_RESERVATION
(
  p_api_version_number        IN   NUMBER   DEFAULT 1.0
, p_init_msg_lst              IN   VARCHAR2 DEFAULT fnd_api.g_false
, p_header_id                 IN   NUMBER   DEFAULT NULL
, p_line_id                   IN   NUMBER   DEFAULT NULL
, p_line_location_id          IN   NUMBER   DEFAULT NULL
, p_distribution_id           IN   NUMBER   DEFAULT NULL
, p_transaction_id            IN   NUMBER   DEFAULT NULL
, p_ordered_quantity          IN   NUMBER   DEFAULT NULL
, p_ordered_uom               IN   VARCHAR2 DEFAULT NULL
, p_action                    IN   VARCHAR2
, x_return_status             OUT  NOCOPY VARCHAR2
, x_msg_count                 OUT  NOCOPY NUMBER
, x_msg_data                  OUT  NOCOPY VARCHAR2
);



------------------------------------------------------------------------------
-- Procedures and Functions
------------------------------------------------------------------------------
-- Procedure
--   Reduce_Reservations
--
-- Description
--   API will handle changes to the resevation record based on the changes to the supply or demand record changes.
--
-- Input Paramters
--   p_api_version_number   Number    API version number (current version is 1.0 Standard in parameter)
--   p_Init_Msg_lst         Varcahar2(1) (Flag to determine to initialize message stack for API, standard input parameter)
--   p_Mtl_Maint_Rsv_Tbl    Inv_Reservations_Global.mtl_Main_rsv_tbl_type
--   p_Delete_Flag          Varchar2(1)  Accepted values 'Y', 'N' and Null. Null value is equivalent to 'N'
--   p_Sort_By_Criteria     Number
--Out Parameters
--   x_Return_Status        Varchar2(1) (Return Status of API, Standard out parameter)
--   x_Msg_Count            Number (Message count from the stack, standard out parameter)
--   x_Msg_Data             Varchar2(255) (Message from message stack, standard out parameter)
--   x_Quantity_Modified    Number (Quantity that has been reduced or deleted by API)
--   CodeReview.SU.01: Added NoCopy for Out parameters
--   CodeReview.SU.02: Added default value for API_Version_NUmber
--   CodeReview.SU.03: Added default value for Init_Msg_Lst

   Procedure Reduce_Reservation (
        p_API_Version_Number   In   Number default 1.0,
        p_Init_Msg_Lst         In   Varchar2 default fnd_api.G_False,
        x_Return_Status        Out  NoCopy Varchar2,
        x_Msg_Count            Out  NoCopy Number,
        x_Msg_Data             Out  NoCopy Varchar2,
        p_Mtl_Maintain_Rsv_Rec In   Inv_Reservation_Global.Mtl_Maintain_Rsv_Rec_Type,
        p_Delete_Flag          In   Varchar2,
        p_Sort_By_Criteria     In   Number,
        x_Quantity_Modified    Out  NoCopy Number );


/* Bug# 8726146: Made FUNCTION EXISTS_RESERVATION public */
    FUNCTION EXISTS_RESERVATION(
        p_supply_source_header_id  IN NUMBER DEFAULT NULL ,
        p_supply_source_line_id    IN NUMBER DEFAULT NULL ,
        p_supply_source_type_id        IN NUMBER DEFAULT inv_reservation_global.g_source_type_po)
        RETURN BOOLEAN;




END INV_MAINTAIN_RESERVATION_PUB;

/
