--------------------------------------------------------
--  DDL for Package GME_SUPPLY_RES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GME_SUPPLY_RES_PVT" AUTHID CURRENT_USER AS
/*  $Header: GMEORESS.pls 120.1 2007/12/24 19:38:45 srpuri ship $
 +=========================================================================+
 |                Copyright (c) 2000 Oracle Corporation                    |
 |                        TVP, Reading, England                            |
 |                         All rights reserved                             |
 +=========================================================================+
 | FILENAME                                                                |
 |    GMIURSVS.pls                                                         |
 |                                                                         |
 | DESCRIPTION                                                             |
 |     This package contains private utilities relating to Reservations    |
 |     against GME Production as a supply source                           |
 |                                                                         |
 |                                                                         |
 | HISTORY                                                                 |
 |     Aug-18-2003  Liping Gao Created                                     |
 +=========================================================================+
  API Name  : GME_SUPPLY_RES_PVT
  Type      : Private
  Function  : This package contains Private Utilities procedures used to
              support change management for Reservations against GME
              Production as a supply source
  Pre-reqs  : N/A
  Parameters: Per function

  Current Vers  : 1.0

*/
TYPE Batch_OM_change_rec is RECORD
   ( Batch_line_id        Number
   , Batch_id             Number
   , fpo_Batch_id         Number
   , Batch_type           Number(5)
   , old_planned_qty      Number
   , new_planned_qty      Number
   , old_trans_qty        Number
   , new_trans_qty        Number
   , old_planned_uom      Varchar2(5)
   , new_planned_uom      Varchar2(5)
   , Actual_qty           Number
   , Batch_status         Number
   , Release_type         Number
   , Cmplt_date           Date
  );

   /*================================================================================
     Procedure
       create_reservation_from_FPO
     Description
       This procedure is invoked during FPO to Batch conversion.  It moves reservations
       from the FPO supply source to the newly generated batches (as a supply source).
   ================================================================================*/
 PROCEDURE create_reservation_from_FPO
 (
    P_FPO_batch_id           IN    NUMBER
  , P_New_batch_id           IN    NUMBER
  , X_return_status          OUT   NOCOPY VARCHAR2
  , X_msg_count              OUT   NOCOPY NUMBER
  , X_msg_data               OUT   NOCOPY VARCHAR2
 );


   /*================================================================================
     Procedure
       notify_CSR
     Description
       This procedure verifies that a reservation relationship exists between sales demand
       and production supply and then initiates issue of workflow notifications to advise
       the customer sales representative that sales reservations are impacted by actions
       to the production supply
   ================================================================================*/
  PROCEDURE notify_CSR
 (
    P_Batch_id               IN    NUMBER default null
  , P_FPO_id                 IN    NUMBER default null
  , P_Batch_line_id          IN    NUMBER default null
  , P_So_line_id             IN    NUMBER default null
  , P_batch_trans_id         IN    NUMBER default null
  , P_organization_id        IN    NUMBER default null
  , P_action_code            IN    VARCHAR2
  , X_return_status          OUT   NOCOPY VARCHAR2
  , X_msg_cont               OUT   NOCOPY NUMBER
  , X_msg_data               OUT   NOCOPY VARCHAR2
 );



   /*================================================================================
     Procedure
       transfer_reservation_to_inv
     Description
       This procedure is invoked during Production Yield.  It transfers reservations
       made against PROD supply to the newly generated INV supply.  The detailing on
       the reservations mirrors the detailing on the WIP Completion yield transactions.
   ================================================================================*/
  PROCEDURE transfer_reservation_to_inv
 (
    p_matl_dtl_rec           IN              gme_material_details%ROWTYPE
  , p_transaction_id         IN              NUMBER
  , x_message_count          OUT NOCOPY      NUMBER
  , x_message_list           OUT NOCOPY      VARCHAR2
  , x_return_status          OUT NOCOPY      VARCHAR2
 );

   /*================================================================================
     Procedure
       query_prod_supply_reservations
     Description
       Retrieve reservations placed against Production as a source of supply.  If
       material_detail_id is supplied, retrieve all the reservations against this supply
       line.   If batch_id only is supplied, retrieve all the reservations against this
       batch/FPO as a source of supply.
   ================================================================================*/
  PROCEDURE query_prod_supply_reservations
 (
    p_matl_dtl_rec               IN              gme_material_details%ROWTYPE
  , x_mtl_reservation_tbl        OUT NOCOPY      inv_reservation_global.mtl_reservation_tbl_type
  , x_mtl_reservation_tbl_count  OUT NOCOPY      NUMBER
  , x_msg_count                  OUT NOCOPY      NUMBER
  , x_msg_data                   OUT NOCOPY      VARCHAR2
  , x_return_status              OUT NOCOPY      VARCHAR2
 );

   /*================================================================================
     Procedure
       relieve_prod_supply_resv
     Description
       This procedure is invoked when there is a decrease in anticipated production
       supply.  It reduces any reservations associated to the supply accordingly.
   ================================================================================*/
  PROCEDURE relieve_prod_supply_resv
(
    p_matl_dtl_rec               IN              gme_material_details%ROWTYPE
  , x_msg_count                  OUT NOCOPY      NUMBER
  , x_msg_data                   OUT NOCOPY      VARCHAR2
  , x_return_status              OUT NOCOPY      VARCHAR2
 );

   /*================================================================================
     Procedure
       delete_prod_supply_resv
     Description
       This procedure is invoked when there is a loss of anticipated production
       supply. This may be as a result of deletion, cancellation or termination.
       The processing deletes any reservations associated to the supply line accordingly.
   ================================================================================*/
  PROCEDURE delete_prod_supply_resv
(
    p_matl_dtl_rec               IN              gme_material_details%ROWTYPE
  , x_msg_count                  OUT NOCOPY      NUMBER
  , x_msg_data                   OUT NOCOPY      VARCHAR2
  , x_return_status              OUT NOCOPY      VARCHAR2
 );

   /*================================================================================
     Procedure
       delete_batch_prod_supply_resv
     Description
       This procedure is invoked when there is a loss of anticipated production
       supply. This may be as a result of cancellation or termination.
       The processing deletes any reservations associated to the batch/FPO accordingly.
   ================================================================================*/
  PROCEDURE delete_batch_prod_supply_resv
(
    p_batch_header_rec           IN              gme_batch_header%ROWTYPE
  , x_msg_count                  OUT NOCOPY      NUMBER
  , x_msg_data                   OUT NOCOPY      VARCHAR2
  , x_return_status              OUT NOCOPY      VARCHAR2
);
END GME_SUPPLY_RES_PVT;

/
