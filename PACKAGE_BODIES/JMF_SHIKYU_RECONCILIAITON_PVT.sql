--------------------------------------------------------
--  DDL for Package Body JMF_SHIKYU_RECONCILIAITON_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JMF_SHIKYU_RECONCILIAITON_PVT" AS
-- $Header: JMFVSKRB.pls 120.18 2006/08/31 02:47:45 rajkrish noship $
--+===========================================================================+
--|               Copyright (c) 2005 Oracle Corporation                       |
--|                       Redwood Shores, CA, USA                             |
--|                         All rights reserved.                              |
--+===========================================================================+
--| FILENAME                                                                  |
--|   JMFVSHRB.pls                                                            |
--|                                                                           |
--| DESCRIPTION                                                               |
--|   This package is used for SHIKYU Reconciliation purposes                 |
--|                                                                           |
--| PROCEDURES:                                                               |
--|   Process_SHIKYU_Reconciliation                                           |
--|                                                                           |
--| FUNCTIONS:                                                                |
--|                                                                           |
--| HISTORY                                                                   |
--|   05/23/2005 rajkrish  Created                                            |
--|   03/27/2006 vchu      Fixed bug 5090721: Set last_update_date,           |
--|                        last_updated_by and last_update_login in the       |
--|                        update statements.                                 |
--|   05/02/2006 vchu      Added the p_skip_po_replen_creation parameter to   |
--|                        the calls to Create_New_Allocations, due to a      |
--|                        signature change made for fixing Bug 5197415.      |
--+===========================================================================+

--=============================================================================
-- TYPE DECLARATIONS
--=============================================================================

--=============================================================================
-- CONSTANTS
--=============================================================================
G_PKG_NAME VARCHAR2(50) := 'JMF_SHIKYU_RECONCILIAITON_PVT' ;
G_MODULE_PREFIX CONSTANT VARCHAR2(50) := 'SHIKYU.plsql.'||G_PKG_NAME || '.';

--=============================================================================
-- GLOBAL VARIABLES
--=============================================================================
g_fnd_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'), 'N');

--=============================================================================
-- PROCEDURES AND FUNCTIONS
--=============================================================================e

------------------------------------------------------------------------
--- Process_quantity_Changes
-- Comments: This api will process the Suncontract Order quantity related
--           changes
-------------------------------------------------------------------------------
PROCEDURE Process_Quantity_Changes
(  p_SUBCONTRACT_PO_SHIPMENT_ID  IN NUMBER
,  p_SUBCONTRACT_PO_HEADER_ID    IN NUMBER
,  p_SUBCONTRACT_PO_LINE_ID      IN NUMBER
,  p_OLD_NEED_BY_DATE            IN DATE
,  p_UOM                         IN VARCHAR2
,  p_CURRENCY                    IN VARCHAR2
,  p_OEM_ORGANIZATION_ID         IN NUMBER
,  p_TP_ORGANIZATION_ID          IN NUMBER
,  p_WIP_ENTITY_ID               IN NUMBER
,  p_OSA_ITEM_ID                 IN NUMBER
,  p_wip_start_quantity          IN NUMBER
,  p_new_need_by_date            IN DATE
,  p_new_ordered_quantity        IN NUMBER
,  p_old_ordered_quantity        IN NUMBER
,  p_puchasing_UOM               IN VARCHAR2
) IS


   l_primary_quantity            NUMBER;
   l_return_status               VARCHAR2(3);
   l_component_new_quantity      NUMBER ;
   l_current_allocated_quantity  NUMBER ;
   l_decreased_qty               NUMBER;
   l_msg_count                   NUMBER ;
   l_msg_data                    VARCHAR2(300) ;
   l_allocation_date             DATE;

  CURSOR C_shikyu_components_CSR IS
  SELECT SUBCONTRACT_PO_SHIPMENT_ID
 ,     SHIKYU_COMPONENT_ID
 ,     OEM_ORGANIZATION_ID
 ,     SHIKYU_COMPONENT_PRICE
 ,     PRIMARY_UOM
 FROM  JMF_SHIKYU_COMPONENTS
 WHERE SUBCONTRACT_PO_SHIPMENT_ID  = p_SUBCONTRACT_PO_SHIPMENT_ID
   ;

l_reduced_allocations_tbl
       JMF_SHIKYU_ALLOCATION_PVT.g_allocation_qty_tbl_type ;

BEGIN

-- The overall logic used in this api:
-- Select the subcontract records where the PO shipment order qty
-- has been changed from the last time reconcile or interlock pgm
-- IF the qty has been increased :
--      Invoke the process WIP api to increase the WIP job qty
--    1 select the new increased component qty
--    2 select the current allocated component qty
--      calculate the difference between 1 and 2
--     create new allocations by invoking the aloocations api

--  IF QTY has been decreased :
--  Invoke the process WIP api to decreased the WIP job qty
--  1 select the new decreased component qty
--  2 select the current allocated component qty
--  reduce allocations for the decreased qty

  IF (g_fnd_debug = 'Y')
  THEN
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX ||
        'Process_Quantity_Changes.Invoked'
                  , 'Entry');
  END IF;
  END IF;

IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX ||
        'p_SUBCONTRACT_PO_SHIPMENT_ID => '
                  , p_SUBCONTRACT_PO_SHIPMENT_ID);
  END IF;
IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX ||
        'p_old_ordered_quantity  => '
                  , p_old_ordered_quantity );
  END IF;
IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX ||
        'p_new_ordered_quantity => '
                  , p_new_ordered_quantity);
  END IF;

    -- Process WIP job
    -- Create new alloacations
   l_allocation_date :=    NULL;
   l_allocation_date :=    JMF_SHIKYU_UTIL.GET_allocation_date
                            ( p_wip_entity_id => p_wip_entity_id );
--dbms_output.put_line(' l_allocation_date => '|| l_allocation_date );
IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX ||
        'l_allocation_date => '
                  , l_allocation_date);
  END IF;

   FOR C_shikyu_components_rec IN C_shikyu_components_CSR
   LOOP

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX ||
        'rajesh Component ID => '
                  , C_shikyu_components_rec.shikyu_component_id);
    END IF;

    l_component_new_quantity     :=
    JMF_SHIKYU_WIP_PVT.Get_component_quantity
    ( p_organization_id             => p_tp_ORGANIZATION_ID
    , p_item_id                     =>
        C_shikyu_components_rec.shikyu_component_id
    , p_SUBCONTRACT_PO_SHIPMENT_ID => p_SUBCONTRACT_PO_SHIPMENT_ID );

--dbms_output.put_line(' l_component_new_quantity => '|| l_component_new_quantity);
 IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX ||
        'l_component_new_quantity => '
                  , l_component_new_quantity);
    END IF;

    l_current_allocated_quantity :=
     NVL( JMF_SHIKYU_UTIL.GET_subcontract_allocated_qty
    (  p_SUBCONTRACT_PO_SHIPMENT_ID  => p_SUBCONTRACT_PO_SHIPMENT_ID
     , p_COMPONENT_ID         =>
           C_shikyu_components_rec.shikyu_component_id ),0) ;

/*dbms_output.put_line(' l_current_allocated_quantity => '||
l_current_allocated_quantity );
dbms_output.put_line(' l_component_new_quantity => '||
l_component_new_quantity);*/
IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX ||
        'l_current_allocated_quantity => '
                  , l_current_allocated_quantity);
    END IF;


    IF  l_component_new_quantity     >     l_current_allocated_quantity
    THEN
--dbms_output.put_line(' Cazll JMF_SHIKYU_ALLOCATION_PVT.Create_New_Allocations');
IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX ||
        'Calling JMF_SHIKYU_ALLOCATION_PVT.Create_New_Allocations SCO   '
                  , p_SUBCONTRACT_PO_SHIPMENT_ID );
    END IF;

      JMF_SHIKYU_ALLOCATION_PVT.Create_New_Allocations
        ( p_api_version             => 1.0
        , p_init_msg_list           => NULL
        , x_return_status           => l_return_status
        , x_msg_count               => l_msg_count
        , x_msg_data                => l_msg_data
     , p_subcontract_po_shipment_id => p_SUBCONTRACT_PO_SHIPMENT_ID
     , p_component_id               =>
         C_shikyu_components_rec.shikyu_component_id
     , p_qty                        =>
         l_component_new_quantity     - l_current_allocated_quantity
     -- p_need_by_date               => l_allocation_date
     , p_skip_po_replen_creation    => 'N'
     );

--dbms_output.put_line(' Out Create_New_Allocations l_return_status => '||
 -- l_return_status );

   ELSIF l_component_new_quantity     <     l_current_allocated_quantity
   THEN
--dbms_output.put_line(' Call JMF_SHIKYU_ALLOCATION_PVT.Reduce_Allocations ');
IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX ||
        'Calling JMF_SHIKYU_ALLOCATION_PVT.Reduce_Allocations '
                  , p_SUBCONTRACT_PO_SHIPMENT_ID );
    END IF;

      JMF_SHIKYU_ALLOCATION_PVT.Reduce_Allocations
      ( p_api_version                  => 1.0
       , p_init_msg_list               => NULL
       , x_return_status               => l_return_status
       , x_msg_count                   => l_msg_count
       , x_msg_data                    => l_msg_data
       , p_subcontract_po_shipment_id  =>
                   p_SUBCONTRACT_PO_SHIPMENT_ID
       , p_component_id               =>
               C_shikyu_components_rec.shikyu_component_id
       , p_replen_so_line_id          =>  NULL
       , p_qty_to_reduce              =>
       l_current_allocated_quantity  - l_component_new_quantity
       , x_reduced_allocations_tbl    => l_reduced_allocations_tbl
       , x_actual_reduced_qty         => l_decreased_qty
       );

--dbms_output.put_line(' Out Reduce_Allocations l_return_status => '|| l_return_status);

   l_component_new_quantity     := NULL;
   l_current_allocated_quantity := NULL;

    END IF;
--dbms_output.put_line(' Next Loop 1 ');
   END LOOP;

--dbms_output.put_line(' OUT OF Loop ');

  IF (g_fnd_debug = 'Y')
  THEN
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX ||
        'Process_Quantity_Changes. OUT'
                  , 'Entry');
  END IF;
  END IF;

--dbms_output.put_line(' OUT Process_Quantity_Changes ');

END Process_Quantity_Changes ;


-----------------------------------------------------------
--
-----------------------------------------------------------
PROCEDURE update_replenishment_date
( p_subcontract_po_shipment_id IN NUMBER
, p_oem_organization    IN NUMBER
,  p_tp_organization    IN NUMBER
, p_replen_so_line_id   IN NUMBER
, p_replen_so_header_id IN NUMBER
, p_component_id        IN NUMBER
, p_new_ship_date       IN DATE
, p_allocation_date     IN DATE
) IS


l_date            DATE;
l_err_msg_name_tbl             po_tbl_varchar30;
l_err_msg_text_tbl             po_tbl_varchar2000;
x_pos_errors       POS_ERR_TYPE;


-- OM variables --

l_Header_price_Att_tbl      OE_Order_PUB.Header_Price_Att_Tbl_Type;
l_Header_Adj_Att_tbl        OE_Order_PUB.Header_Adj_Att_Tbl_Type;
l_Header_Adj_Assoc_tbl      OE_Order_PUB.Header_Adj_Assoc_Tbl_Type;
l_Line_price_Att_tbl        OE_Order_PUB.Line_Price_Att_Tbl_Type;
l_Line_Adj_Att_tbl          OE_Order_PUB.Line_Adj_Att_Tbl_Type;
l_Line_Adj_Assoc_tbl        OE_Order_PUB.Line_Adj_Assoc_Tbl_Type;
l_hdr_rec                   OE_Order_PUB.Header_Rec_Type;
l_line_rec                  OE_Order_PUB.Line_Rec_Type;
l_line_adj_rec              OE_Order_PUB.Line_Adj_Rec_Type;
l_line_tbl                  OE_Order_PUB.Line_Tbl_Type;
l_line_adj_tbl              OE_Order_PUB.Line_Adj_Tbl_Type;
l_x_header_rec              OE_Order_PUB.Header_Rec_Type;
l_x_Header_Adj_tbl          OE_Order_PUB.Header_Adj_Tbl_Type;
l_x_Header_Scredit_tbl      OE_Order_PUB.Header_Scredit_Tbl_Type;
l_x_line_tbl                OE_Order_PUB.Line_Tbl_Type;
l_x_Line_Adj_tbl            OE_Order_PUB.Line_Adj_Tbl_Type;
l_x_Line_Scredit_tbl        OE_Order_PUB.Line_Scredit_Tbl_Type;
l_action_request_tbl        OE_Order_PUB.request_tbl_type;
l_x_action_request_tbl      OE_Order_PUB.request_tbl_type;
l_x_lot_serial_tbl          OE_Order_PUB.lot_serial_tbl_type;
l_hdr_payment_tbl           OE_Order_PUB.Header_Payment_Tbl_Type;
l_line_payment_tbl          OE_Order_PUB.Line_Payment_Tbl_Type;
l_control_rec               oe_globals.control_rec_type;
l_return_status             Varchar2(30);
l_file_val                  Varchar2(30);
x_msg_count                 number;
x_msg_data                  Varchar2(2000);
x_msg_index                 number;

-- end OM variables --


--------- PO resch variables   ------------------

l_return_number             number ;
x_po_msg_count              number;
x_po_msg_data               Varchar2(2000);
x_po_msg_index              number;
l_po_ship_date              date;
l_api_errors                PO_API_ERRORS_REC_TYPE ;
l_err_msg_name_tbl          po_tbl_varchar30;
l_err_msg_text_tbl          po_tbl_varchar2000;

l_repl_po_header_id         NUMBER ;
l_repl_po_line_id         NUMBER ;
l_repl_po_shipment_id         NUMBER ;
--------- END PO variables

CURSOR C_select_replenishments_CSR
IS
SELECT REPLENISHMENT_SO_LINE_ID
,REPLENISHMENT_SO_HEADER_ID
,SCHEDULE_SHIP_DATE
,REPLENISHMENT_PO_HEADER_ID
,REPLENISHMENT_PO_LINE_ID
,REPLENISHMENT_PO_SHIPMENT_ID
,OEM_ORGANIZATION_ID
,TP_ORGANIZATION_ID
,SHIKYU_COMPONENT_ID
FROM jmf_shikyu_replenishments
WHERE REPLENISHMENT_SO_HEADER_ID = p_replen_so_header_id
AND REPLENISHMENT_SO_LINE_ID = p_replen_so_line_id ;


CURSOR C_PO_details_CSR IS
SELECT poh.segment1
,      poh.revision_num
,      pol.po_line_id
,      pol.line_num
,      poll.line_location_id
,      poll.need_by_date
,     poll.SHIPMENT_NUM
FROM po_headers_all poh
,    po_lines_all pol
,    po_line_locations_all poll
WHERE poh.po_header_id = pol.po_header_id
AND   pol.po_header_id = poll.po_header_id
AND   pol.po_line_id   = poll.po_line_id
AND   poll.line_location_id = l_repl_po_shipment_id
AND   poll.po_header_id     = l_repl_po_header_id
AND   poll.po_line_id       = l_repl_po_line_id
AND   poh.po_header_id      = l_repl_po_header_id
AND   pol.po_line_id        = l_repl_po_line_id ;

BEGIN

IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX ||
        'INTO update_replenishment_date FOR SCO PO SHIPID:  '
                  , p_subcontract_po_shipment_id);
  END IF;

IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX ||
        'p_new_ship_date => '
                  , p_new_ship_date);
  END IF;
IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX ||
        'p_allocation_date => '
                  , p_allocation_date );
  END IF;



FOR C_select_replenishments_REC IN C_select_replenishments_CSR
LOOP
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX ||
        'Start OM rescheduling : REPLENISHMENT_SO_LINE_ID '
                  , C_select_replenishments_REC.REPLENISHMENT_SO_LINE_ID);
    END IF;


   l_line_rec            := OE_Order_PUB.G_MISS_LINE_REC;
   l_line_rec.operation  := oe_globals.G_OPR_UPDATE;

   l_line_rec.line_id            :=
            C_select_replenishments_REC.REPLENISHMENT_SO_LINE_ID;
   l_line_rec.header_id          :=
         C_select_replenishments_REC.REPLENISHMENT_SO_HEADER_ID ;
   l_line_rec.schedule_ship_date :=
           p_new_ship_date ;

   l_line_tbl(1)                := l_line_rec;

oe_debug_pub.add('Before Process_Order',1);
IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX ||
        'OE_Order_PVT.Process_order re-scheduling '
                  , 'calling ');
  END IF;


OE_Order_PVT.Process_order
    (   p_api_version_number       => 1.0
    ,   p_init_msg_list            => FND_API.G_TRUE
    ,   x_return_status            => l_return_status
    ,   x_msg_count                => x_msg_count
    ,   x_msg_data                 => x_msg_data
    ,   p_control_rec              => l_control_rec
--    ,   p_validation_level       => FND_API.G_VALID_LEVEL_NONE
    ,   p_x_header_Rec             => l_hdr_rec
    ,   p_x_line_tbl               => l_line_tbl
 --   ,   p_line_adj_tbl           => l_line_adj_tbl
    ,   p_x_action_request_tbl     => l_action_request_tbl
    ,   p_x_Header_Adj_tbl         => l_x_Header_Adj_tbl
    ,   p_x_Header_Scredit_tbl   => l_x_Header_Scredit_tbl
    ,   p_x_Line_Adj_tbl          => l_x_Line_Adj_tbl
    ,   p_x_Line_Scredit_tbl     => l_x_Line_Scredit_tbl
    ,   p_x_Lot_Serial_tbl        => l_x_lot_serial_tbl
    ,p_x_Header_price_Att_tbl    => l_Header_price_Att_tbl
    ,p_x_Header_Adj_Att_tbl      => l_Header_Adj_Att_tbl
    ,p_x_Header_Adj_Assoc_tbl    => l_Header_Adj_Assoc_tbl
    ,p_x_Line_price_Att_tbl      => l_Line_price_Att_tbl
    ,p_x_Line_Adj_Att_tbl        => l_Line_Adj_Att_tbl
    ,p_x_Line_Adj_Assoc_tbl      => l_Line_Adj_Assoc_tbl
    , p_x_header_payment_tbl     => l_hdr_payment_tbl
    , p_x_line_payment_tbl       => l_line_payment_tbl
    );



IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX ||
        'OE_Order_PVT.Process_order re-scheduling '
                  , 'out ');
  END IF;

IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX ||
        'l_return_status => '|| l_return_status
                  , l_return_status);
  END IF;

  ------ end OM -----------
 IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX ||
        'END  OM rescheduling : REPLENISHMENT_SO_LINE_ID '
                  , C_select_replenishments_REC.REPLENISHMENT_SO_LINE_ID);
    END IF;

--------------------------------------------------------
 ------------------- PO RESCHEDULING --------------------

      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX ||
        'rajesh START PO RESCHEDULING '
      , C_select_replenishments_REC.REPLENISHMENT_PO_SHIPMENT_ID);
      END IF;

     l_repl_po_line_id      := NULL ;
     l_repl_po_header_id    := NULL ;
     l_repl_po_shipment_id  := NULL ;

     l_repl_po_line_id  :=
         C_select_replenishments_REC.replenishment_po_line_id ;
     l_repl_po_header_id :=
          C_select_replenishments_REC.replenishment_po_header_id ;
     l_repl_po_shipment_id :=
                 C_select_replenishments_REC.replenishment_po_shipment_id ;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX ||
        'l_repl_po_header_id => '
      , l_repl_po_header_id);

        FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX ||
        'l_repl_po_line_id => '
      , l_repl_po_line_id);

        FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX ||
        'l_repl_po_shipment_id => '
      , l_repl_po_shipment_id);
    END IF;

   FOR C_PO_details_REC IN C_PO_details_CSR
   LOOP
     IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX ||
        'rajesh Into PO Loop for segment1 => '
      , C_PO_details_REC.segment1);

     END IF;
    BEGIN

          IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                 FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX ||
             'Calling PO_CHANGE_API1_S for : '
                  , C_PO_details_REC.segment1 );
           END IF;

        l_return_number := PO_CHANGE_API1_S.update_po
        (
          X_PO_NUMBER                   =>
                  C_PO_details_REC.segment1
        , X_RELEASE_NUMBER              =>
                 NULL
        , X_REVISION_NUMBER             =>
                NVL(C_PO_details_REC.revision_num,0)
        , X_LINE_NUMBER                 =>
               NVL(C_PO_details_REC.line_num,1)
        , X_SHIPMENT_NUMBER             =>
               NVL(C_PO_details_REC.shipment_num,1)
        , NEW_QUANTITY                  => NULL
        , NEW_PRICE                     => NULL
        , NEW_PROMISED_DATE             => NULL
        , NEW_NEED_BY_DATE              => p_allocation_date
        , LAUNCH_APPROVALS_FLAG         => 'Y'
        , UPDATE_SOURCE                 => NULL
        , VERSION                       => 1.0
        , X_OVERRIDE_DATE               => NULL
         -- <PO_CHANGE_API FPJ START>
        , X_API_ERRORS                  => l_api_errors
          -- <PO_CHANGE_API FPJ END>
       , p_BUYER_NAME                  => null
          -- <INVCONV R12 START>
        , p_secondary_quantity          => null
        , p_preferred_grade             => null
           -- <INVCONV R12 END>
         ) ;

        IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX ||
        'After PO reschedule l_return_number  => ' || l_return_number
      , l_return_number);
        END IF;
    END ;


   END LOOP ; --PO loop

   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX ||
        'Out of PO loop '
                  , 'rajesh ');
    END IF;


 END LOOP ; -- main repl loop

IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX ||
        'OUT OF main loop '
                  , 'rajesh');
  END IF;


 IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX ||
        'completed  update_replenishment_date'
                  , 'EXit');
  END IF;

END update_replenishment_date ;


-----------------------------------------------------------
-- FUNCTION : check pick released
------------------------------------------------------------
FUNCTION check_pick_released
( p_header_id IN NUMBER
, p_line_id   IN NUMBER
) RETURN VARCHAR2

IS

l_id       NUMBER;
l_released VARCHAR2(1);
l_release_status VARCHAR2(3) ;

BEGIN

 IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX ||
        'check_pick_released '
                  , 'ENTRY');
  END IF;

  l_released := 'N' ;
  BEGIN
    SELECT
      delivery_detail_id
    , released_status
    INTO
      l_id
    , l_release_status
    FROM
     WSH_DELIVERY_DETAILS
    WHERE source_header_id = p_header_id
      AND source_line_id   = p_line_id
      AND NVL(released_status,'R') = 'Y' ;

      l_released := 'Y' ;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , 'JMFVSKRB: l_id : l_release_status : l_released = '
                  , l_id || l_release_status || l_released );
     END IF;


    EXCEPTION
    WHEN NO_DATA_FOUND
    THEN
      l_released := 'N' ;

    WHEN TOO_MANY_ROWS
    THEN
     l_released := 'Y' ;

  END;


  RETURN l_released ;


 IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX ||
        'check_pick_released '
                  , 'OUT ');
  END IF;

END check_pick_released ;



-------------------------------------------------------------
--
------------------------------------------------------------
FUNCTION check_repl_retain
 ( p_subcontract_po_shipment_id IN NUMBER
 , p_oem_organization   IN NUMBER
 , p_tp_organization    IN NUMBER
 , p_replen_so_line_id  IN NUMBER
 , p_replen_so_header_id IN NUMBER
 , p_component_id       IN NUMBER
 , p_open_flag          IN VARCHAR2
 , p_booked_flag        IN VARCHAR2
 , p_shipped_quantity    IN VARCHAR2
 , p_invoiced_quantity   IN VARCHAR2
 , p_shipping_interfaced_flag  IN VARCHAR2
 , p_cancelled_flag      IN VARCHAR2
  )  RETURN VARCHAR2 IS

l_check VARCHAR2(1) := 'N' ;
l_REPLENISHMENT_PO_LINE_ID NUMBER;
L_SUBCONTRACT_PO_SHIPMENT_ID NUMBER ;
l_pick_release VARCHAR2(1) := 'N' ;

BEGIN

IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX ||
        'into check_repl_retain'
                  , 'Entry');
  END IF;

IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , 'JMFVSKRB : p_replen_so_line_id => '
                  , p_replen_so_line_id);
  END IF;
IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , 'JMFVSKRB: p_replen_so_header_id => '
                  , p_replen_so_header_id );
  END IF;

l_check := NULL ;

IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX ||
        'shipped : invcd: ship_intf:cncl : '||
        p_shipped_quantity || p_invoiced_quantity || p_shipping_interfaced_flag || p_cancelled_flag
                  , 'rajesh');
  END IF;

IF  NVL(p_open_flag,'N')     = 'N'  OR
    NVL( p_shipped_quantity,0) <>  0  OR
    NVL( p_invoiced_quantity,0) <>  0  OR
    NVL( p_cancelled_flag,'N')  = 'Y'
THEN
   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX ||
        'One of the flag issue '
                  , 'INTO IF ');
   END IF;

   l_check := 'N' ;

ELSIF  NVL( p_shipping_interfaced_flag,'N') = 'Y'
THEN
      l_pick_release := check_pick_released
            ( p_header_id => p_replen_so_header_id
             , p_line_id  => p_replen_so_line_id
            ) ;

     IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , 'JMFVSKRB: AFter check_pick_released => '
                  , l_pick_release );
      END IF;

    IF NVL(l_pick_release,'N') = 'Y'
    THEN
       l_check := 'N' ;
    END IF;

ELSE
      l_check := NULL ;
     IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX ||
        'Into other check as REPL SO is open '
                  , l_check);
      END IF;


  BEGIN
   SELECT  REPLENISHMENT_PO_LINE_ID
   INTO l_REPLENISHMENT_PO_LINE_ID
   FROM jmf_shikyu_replenishments
   WHERE REPLENISHMENT_SO_LINE_ID   = p_replen_so_line_id
     AND REPLENISHMENT_SO_HEADER_ID =  p_replen_so_header_id ;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX ||
        'l_REPLENISHMENT_PO_LINE_ID => '
                  , l_REPLENISHMENT_PO_LINE_ID);
    END IF;

    l_check := NULL ;

   EXCEPTION
    WHEN NO_DATA_FOUND THEN
        l_REPLENISHMENT_PO_LINE_ID := NULL ;
        l_check := 'N' ;

    WHEN TOO_MANY_ROWS THEN
       l_REPLENISHMENT_PO_LINE_ID := NULL ;
        l_check := 'N' ;

   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX ||
        'Too many repl PO attached '
                  , l_check);
      END IF;

   END ;

     IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX ||
        'before sco check l_check => '|| l_check
                  , l_check);
      END IF;


   IF l_check is NULL
   THEN
     BEGIN
      SELECT SUBCONTRACT_PO_SHIPMENT_ID
      INTO   L_SUBCONTRACT_PO_SHIPMENT_ID
      FROM JMF_SHIKYU_ALLOCATIONS
      WHERE SUBCONTRACT_PO_SHIPMENT_ID <>
             p_subcontract_po_shipment_id
       AND REPLENISHMENT_SO_LINE_ID = p_replen_so_line_id ;

      l_check := 'N' ;
   EXCEPTION
    WHEN NO_DATA_FOUND THEN
        L_SUBCONTRACT_PO_SHIPMENT_ID := NULL ;
        l_check := 'Y' ;

      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX ||
        'only one SCO attached l_check => '
                  , l_check);
      END IF;


      WHEN TOO_MANY_ROWS THEN
       L_SUBCONTRACT_PO_SHIPMENT_ID := NULL ;
        l_check := 'N' ;
   END ;
  END IF ;

END IF ;


IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX ||
        'check_repl_retain l_check => '|| l_check
                  , 'About to return ');
  END IF;

RETURN( l_check) ;

END check_repl_retain ;

------------------------------
-------------------------------------------------------------------------
--- Process_Date_Changes
--  Comments: THis api will reconcile for the subcontract PO need by date
--            changes
--------------------------------------------------------------------------
PROCEDURE Process_Date_Changes
(  p_SUBCONTRACT_PO_SHIPMENT_ID  IN NUMBER
,  p_SUBCONTRACT_PO_HEADER_ID    IN NUMBER
,  p_SUBCONTRACT_PO_LINE_ID      IN NUMBER
,  p_OLD_NEED_BY_DATE            IN DATE
,  p_UOM                         IN VARCHAR2
,  p_CURRENCY                    IN VARCHAR2
,  p_OEM_ORGANIZATION_ID         IN NUMBER
,  p_TP_ORGANIZATION_ID          IN NUMBER
,  p_WIP_ENTITY_ID               IN NUMBER
,  p_OSA_ITEM_ID                 IN NUMBER
,  p_wip_start_quantity          IN NUMBER
,  p_new_need_by_date            IN DATE
,  p_new_ordered_quantity        IN NUMBER
,  p_old_ordered_quantity        IN NUMBER
,  p_puchasing_UOM               IN VARCHAR2
) IS

  l_return_status            VARCHAR2(1);
  l_allocation_date          DATE ;
  l_intransit_days           NUMBER ;
  l_total_allocated_qty      NUMBER;
  l_deleted_qty              NUMBER ;
  l_retain                   VARCHAR2(1) ;
  l_component_removed_qty    NUMBER ;
  L_SHIKYU_COMPONENT_ID      NUMBER ;

CURSOR C_NEED_BY_DATE_CSR IS

 SELECT  alc.SUBCONTRACT_PO_SHIPMENT_ID
       , alc.SHIKYU_COMPONENT_ID
       , alc.REPLENISHMENT_SO_LINE_ID
       , alc.ALLOCATED_QUANTITY
       , alc.UOM
       , oel.line_id
       , oel.header_id
       , oel.schedule_ship_date
       , oel.ordered_quantity
       , oel.shipped_quantity
       , oel.invoiced_quantity
       , oel.CANCELLED_FLAG
       , oel.OPEN_FLAG
       , oel.BOOKED_FLAG
       , oel.shipping_interfaced_flag
  FROM   JMF_SHIKYU_ALLOCATIONS alc
    ,  OE_ORDER_LINES_ALL oel
  WHERE  alc.SUBCONTRACT_PO_SHIPMENT_ID = p_SUBCONTRACT_PO_SHIPMENT_ID
    AND  oel.line_id              = alc.REPLENISHMENT_SO_LINE_ID
    AND oel.open_flag = 'Y'
    AND alc.SHIKYU_COMPONENT_ID  = l_SHIKYU_COMPONENT_ID ;

CURSOR C_SHIKYU_components_CSR IS
SELECT SUBCONTRACT_PO_SHIPMENT_ID
     , SHIKYU_COMPONENT_ID
     , OEM_ORGANIZATION_ID
FROM jmf_shikyu_components
WHERE SUBCONTRACT_PO_SHIPMENT_ID = p_SUBCONTRACT_PO_SHIPMENT_ID
order by SHIKYU_COMPONENT_ID ;

l_deleted_allocations_tbl
         JMF_SHIKYU_ALLOCATION_PVT.g_allocation_qty_tbl_type ;
l_msg_data     VARCHAR2(300);
l_msg_count    NUMBER ;
l_final_ship_date DATE;
l_reschedule_date DATE;

BEGIN


--- The overall logic used:
--  select  the PO subcontract records where the PO shipment need by date
--  has been changed
-- IF the new need_by date has been moved forward:
--  Process WIP job to updated the WIP job dates

--  IF the new need_by date has been moved Backward:
--  invoke api - process WIP job api to update the WIP dates
--  for each allocations , check if the SO replinishment will
-- arrive on time with the lead times
-- IF YES: No action

-- IF NOT:
--  remove allocations for those SO replinishments
--  create new allocations

/*dbms_output.put_line(' INTO process date changes ');
dbms_output.put_line('  p_SUBCONTRACT_PO_SHIPMENT_ID  => '||
         p_SUBCONTRACT_PO_SHIPMENT_ID );
dbms_output.put_line('  p_SUBCONTRACT_PO_HEADER_ID     => '||
            p_SUBCONTRACT_PO_HEADER_ID );
dbms_output.put_line('  p_SUBCONTRACT_PO_LINE_ID    => '||
               p_SUBCONTRACT_PO_LINE_ID );
dbms_output.put_line('  p_OLD_NEED_BY_DATE    => '||
            p_OLD_NEED_BY_DATE );
dbms_output.put_line('  p_UOM                        => '||
             p_UOM );
dbms_output.put_line('  p_CURRENCY              => '||
            p_CURRENCY );
dbms_output.put_line('  p_OEM_ORGANIZATION_ID   => '||
   p_OEM_ORGANIZATION_ID );
dbms_output.put_line('  p_TP_ORGANIZATION_ID           => '||
              p_TP_ORGANIZATION_ID );
dbms_output.put_line('  p_WIP_ENTITY_ID     => '||
           p_WIP_ENTITY_ID );
dbms_output.put_line('  p_OSA_ITEM_ID              => '||
               p_OSA_ITEM_ID );
dbms_output.put_line('  p_wip_start_quantity   => '||
               p_wip_start_quantity );
dbms_output.put_line('  p_new_need_by_date            => '||
             p_new_need_by_date );
dbms_output.put_line('  p_new_ordered_quantity   => '||
             p_new_ordered_quantity );
dbms_output.put_line('  p_old_ordered_quantity   => '||
                 p_old_ordered_quantity );
dbms_output.put_line('  p_puchasing_UOM     => '||
          p_puchasing_UOM ); */

  IF (g_fnd_debug = 'Y')
  THEN
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX ||
        'Process_Date_Changes.Invoked'
                  , 'Entry');
  END IF;
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX ||
        'p_old_need_by_date SCO => '|| p_old_need_by_date
                  , p_old_need_by_date );
  END IF;
 IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX ||
        'p_new_need_by_date SCO => '|| p_new_need_by_date
                  , p_new_need_by_date );
  END IF;
 IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX ||
        'p_SUBCONTRACT_PO_SHIPMENT_ID => '
                  , p_SUBCONTRACT_PO_SHIPMENT_ID );
  END IF;

  END IF;


--dbms_output.put_line('  Start process date ');
--Need by Date of Subcontracting PO moved forward.
--------------------------------------------------
----Date in JMF_Subcontracting_orders is moved forward
   --WIP job start date is moved forward


  IF p_new_need_by_date > p_OLD_NEED_BY_DATE
  THEN
--dbms_output.put_line('  p_new_need_by_date > p_OLD_NEED_BY_DATE ');
     null;
     -- No need to re-allocate in this scenario

   ELSIF p_new_need_by_date < p_old_need_by_date
   THEN
--dbms_output.put_line('  p_new_need_by_date < p_OLD_NEED_BY_DATE ');
       l_allocation_date := null ;
       -- get the WIP completion date
       l_allocation_date :=    JMF_SHIKYU_UTIL.GET_allocation_date
                            ( p_wip_entity_id => p_wip_entity_id );


--dbms_output.put_line('  l_allocation_date => '|| l_allocation_date );
-- rajesh main loop
IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX ||
        'rajesh l_allocation_date => '
                  , l_allocation_date);
  END IF;

FOR C_SHIKYU_components_rec IN C_SHIKYU_components_CSR
LOOP
  l_shikyu_component_id :=
         C_SHIKYU_components_rec.SHIKYU_component_id ;

   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
   FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX ||
        'l_shikyu_component_id => '|| l_shikyu_component_id
                  , l_shikyu_component_id);
   END IF;

    l_component_removed_qty :=  NULL ;

    FOR C_NEED_BY_DATE_rec  IN  C_NEED_BY_DATE_CSR
    LOOP
     l_final_ship_date := NULL ;

     l_final_ship_date :=  JMF_SHIKYU_UTIL.get_final_ship_date
           ( p_oem_organization => p_oem_organization_id
           , p_tp_organization   => p_tp_organization_id
           , p_scheduled_ship_date  => C_NEED_BY_DATE_rec.schedule_ship_date
         ) ;

     IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX ||
        'rajesh l_final_ship_date in current repl => '|| l_final_ship_date
                  , l_final_ship_date);
      END IF;


     IF l_final_ship_date > l_allocation_date
     THEN
--dbms_output.put_line('  delete allocations 1');
--dbms_output.put_line('  C_NEED_BY_DATE_rec.REPLENISHMENT_SO_LINE_ID => '
-- || C_NEED_BY_DATE_rec.REPLENISHMENT_SO_LINE_ID );

-- Rajesh: reschedule

       l_retain := NULL ;

       IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                  , G_MODULE_PREFIX ||
        'existing repl will not arrive on time SO LINE ID: '
                  , C_NEED_BY_DATE_rec.REPLENISHMENT_SO_LINE_ID );
       END IF;

       IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                  , G_MODULE_PREFIX ||
        'Call check_repl_retain for C_NEED_BY_DATE_rec.REPLENISHMENT_SO_LINE_ID'
                  , C_NEED_BY_DATE_rec.REPLENISHMENT_SO_LINE_ID );
       END IF;

       l_retain :=
       check_repl_retain
       ( p_subcontract_po_shipment_id => p_subcontract_po_shipment_id
       , p_oem_organization     => p_oem_organization_id
       , p_tp_organization      => p_tp_organization_id
       , p_replen_so_line_id    => C_NEED_BY_DATE_rec.REPLENISHMENT_SO_LINE_ID
       , p_replen_so_header_id  =>  C_NEED_BY_DATE_rec.header_id
       , p_component_id         =>
              C_NEED_BY_DATE_rec.SHIKYU_COMPONENT_ID
       , p_open_flag            => C_NEED_BY_DATE_rec.open_flag
       , p_booked_flag          => C_NEED_BY_DATE_rec.booked_flag
       , p_shipped_quantity     => C_NEED_BY_DATE_rec.shipped_quantity
       , p_invoiced_quantity    => C_NEED_BY_DATE_rec.invoiced_quantity
       , p_shipping_interfaced_flag =>
                   C_NEED_BY_DATE_rec.shipping_interfaced_flag
       , p_cancelled_flag    =>
                     C_NEED_BY_DATE_rec.cancelled_flag
       );

      IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                  , G_MODULE_PREFIX ||
        'rajesh Out of check_repl_retain => '
                  , l_retain );
       END IF;

      IF NVL(l_retain,'Y')  = 'N'
      THEN
         IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                  , G_MODULE_PREFIX ||
        'Call Delete_Allocations for repl SO LINE ID '||
                 C_NEED_BY_DATE_rec.REPLENISHMENT_SO_LINE_ID
                  , C_NEED_BY_DATE_rec.REPLENISHMENT_SO_LINE_ID);
         END IF;

        JMF_SHIKYU_ALLOCATION_PVT.Delete_Allocations
         ( p_api_version                => 1.0
         , p_init_msg_list              => NULL
         , x_return_status              => l_return_status
         , x_msg_count                  => l_msg_count
         , x_msg_data                   => l_msg_data
        , p_subcontract_po_shipment_id =>
             C_NEED_BY_DATE_rec.subcontract_po_shipment_id
        , p_component_id               =>
             C_NEED_BY_DATE_rec.SHIKYU_COMPONENT_ID
        , p_replen_so_line_id          =>
             C_NEED_BY_DATE_rec.REPLENISHMENT_SO_LINE_ID
        , x_deleted_allocations_tbl    =>
                l_deleted_allocations_tbl
        );

        l_component_removed_qty := NVL(l_component_removed_qty,0) +
                        C_NEED_BY_DATE_rec.allocated_quantity ;

         IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                  , G_MODULE_PREFIX ||
             'C_NEED_BY_DATE_rec.allocated_quantity => '
                  , C_NEED_BY_DATE_rec.allocated_quantity );
          END IF;
          IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                  , G_MODULE_PREFIX ||
              'l_component_removed_qty => '
                  , l_component_removed_qty );
           END IF;

       -- END IF; ---l_final_ship_date

      ELSE
       -- Update the existing repl
            IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                  , G_MODULE_PREFIX ||
              'Into the Retain =  Y mode reschedule repl '
                   , C_NEED_BY_DATE_rec.REPLENISHMENT_SO_LINE_ID);
           END IF;
           IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                  , G_MODULE_PREFIX ||
              'Calling JMF_SHIKYU_ONT_PVT.Calculate_Ship_Date for  '
                  , l_allocation_date );
           END IF;


        l_reschedule_date := NULL ;
        JMF_SHIKYU_ONT_PVT.Calculate_Ship_Date
            ( p_subcontract_po_shipment_id =>
                 p_subcontract_po_shipment_id
            , p_component_item_id         =>
            C_NEED_BY_DATE_rec.SHIKYU_COMPONENT_ID
            , p_oem_organization_id      =>
                   p_oem_organization_id
            , p_tp_organization_id     =>
                   p_tp_organization_id
            , p_quantity     =>
                  C_NEED_BY_DATE_rec.allocated_quantity
            , p_need_by_date   => l_allocation_date
            , x_ship_date          => l_reschedule_date );


        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                  , G_MODULE_PREFIX ||
              'rajesh l_reschedule_date => '|| l_reschedule_date
                  , l_reschedule_date );
           END IF;


        IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                  , G_MODULE_PREFIX ||
              'Call update_replenishment_date for SO LINE ID '||
                  C_NEED_BY_DATE_rec.REPLENISHMENT_SO_LINE_ID
                  , C_NEED_BY_DATE_rec.REPLENISHMENT_SO_LINE_ID);
           END IF;

        update_replenishment_date
       ( p_subcontract_po_shipment_id => p_subcontract_po_shipment_id
       , p_oem_organization    => p_oem_organization_id
       ,  p_tp_organization    => p_tp_organization_id
       , p_replen_so_line_id   => C_NEED_BY_DATE_rec.REPLENISHMENT_SO_LINE_ID
       , p_replen_so_header_id =>  C_NEED_BY_DATE_rec.header_id
       , p_component_id        =>
              C_NEED_BY_DATE_rec.SHIKYU_COMPONENT_ID
       , p_new_ship_date => l_reschedule_date
       , p_allocation_date => l_allocation_date
       );

       IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                  , G_MODULE_PREFIX ||
        'Out of update_replenishment_date '
                  , 'rajesh');
       END IF;

      END IF; -- end of reschedule IF
--dbms_output.put_line('  Next in loop ');
      END IF ; -- l_final_ship_date

      END LOOP ;

          IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                  , G_MODULE_PREFIX ||
               'out of  components loop rem qty: '|| l_component_removed_qty
                  , l_component_removed_qty);
             END IF;

      IF NVL(l_component_removed_qty,0) > 0
      THEN
          IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                  , G_MODULE_PREFIX ||
               'Going to call Create new allocations for comp'
                  , l_SHIKYU_component_id );
           END IF;

        JMF_SHIKYU_ALLOCATION_PVT.Create_New_Allocations
        ( p_api_version                => 1.0
        , p_init_msg_list              => NULL
        , x_return_status              => l_return_status
        , x_msg_count                  => l_msg_count
        , x_msg_data                    => l_msg_data
         , p_subcontract_po_shipment_id =>
              p_subcontract_po_shipment_id
         , p_component_id               =>
              l_SHIKYU_component_id
         , p_qty                        =>
              l_component_removed_qty
         , p_skip_po_replen_creation    => 'N'
         );

           IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.string(FND_LOG.LEVEL_STATEMENT
                  , G_MODULE_PREFIX ||
               'out of  Create new allocations for comp'
                  , l_return_status );
             END IF;
       	END IF ; -- l_component_removed_qty IF


      l_component_removed_qty := NULL ;
      l_retain := NULL ;
      l_SHIKYU_component_id := NULL ;

    END LOOP ; -- Main loop ;
--dbms_output.put_line('  out of loop ');
    END IF;


  IF (g_fnd_debug = 'Y')
  THEN
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX ||
        'Process_Date_Changes.OUT'
                  , 'Entry');
  END IF;
  END IF;

--dbms_output.put_line('  out of Process_Date_Changes ');
END Process_Date_Changes ;


--=============================================================================
-- API NAME      : Process_SHIKYU_Reconciliation
-- TYPE          : PRIVATE
-- PRE-REQS      : SHIKYU datamodel and SHIKYU process should exists
-- DESCRIPTION   : Process the SHIKYi reconciliation once the shikyu
--                 Interlock has been run

-- PARAMETERS    :
--   p_api_version        REQUIRED. API version
--   p_init_msg_list      REQUIRED. FND_API.G_TRUE to reset the message list
--                                  FND_API.G_FALSE to not reset it.
--                                  If pass NULL, it means FND_API.G_FALSE.
--   p_commit             OPTIONAL. FND_API.G_TRUE to have API commit the change
--                                  FND_API.G_FALSE to not commit the change.
--                                  Include this if API does DML.
--                                  If pass NULL, it means FND_API.G_FALSE.
--   p_validation_level   OPTIONAL. value between 0 and 100.
--                                  FND_API.G_VALID_LEVEL_NONE  -> 0
--                                  FND_API.G_VALID_LEVEL_FULL  -> 100
--                                  Public APIs should not have this parameter
--                                  since it should always be FULL validation.
--                                  If API perform some level not required by
--                                  some API caller, this parameter should be
--                                  included.
--                                  Product group can define intermediate
--                                  validation levels.
--                                  If pass NULL, it means i
--                                    FND_API.G_VALID_LEVEL_FULL
--
--   x_return_status      REQUIRED. Value can be
--                                  FND_API.G_RET_STS_SUCCESS
--                                  FND_API.G_RET_STS_ERROR
--                                  FND_API.G_RET_STS_UNEXP_ERROR
--   x_msg_count          REQUIRED. Number of messages on the message list
--   x_msg_data           REQUIRED. Return message data if message count is 1
--   p_card_id            REQUIRED. Card ID to be deleted.
-- EXCEPTIONS    :
--
--=============================================================================
PROCEDURE Process_SHIKYU_Reconciliation
( p_api_version               IN  NUMBER
, p_init_msg_list             IN  VARCHAR2
, p_commit                    IN  VARCHAR2
, p_validation_level          IN  NUMBER
, x_return_status             OUT NOCOPY VARCHAR2
, x_msg_count                 OUT NOCOPY NUMBER
, x_msg_data                  OUT NOCOPY VARCHAR2
, P_Operating_unit            IN NUMBER
, p_from_organization         IN NUMBER
, p_to_organization           IN NUMBER
)
IS
l_api_name    CONSTANT VARCHAR2(30) := 'Process_SHIKYU_Reconciliation' ;
l_api_version CONSTANT NUMBER       := 1.0;
l_deleted_qty          NUMBER ;


CURSOR SHIKYU_reconcile_CSR IS
SELECT  sco.SUBCONTRACT_PO_SHIPMENT_ID  SUBCONTRACT_PO_SHIPMENT_ID
,       sco.SUBCONTRACT_PO_HEADER_ID    SUBCONTRACT_PO_HEADER_ID
,       sco.SUBCONTRACT_PO_LINE_ID      SUBCONTRACT_PO_LINE_ID
,       trunc(sco.NEED_BY_DATE)         sco_NEED_BY_DATE
,       sco.UOM                         UOM
,       sco.CURRENCY                    CURRENCY
,       sco.OEM_ORGANIZATION_ID         OEM_ORGANIZATION_ID
,       sco.TP_ORGANIZATION_ID          TP_ORGANIZATION_ID
,       sco.WIP_ENTITY_ID               WIP_ENTITY_ID
,       sco.OSA_ITEM_ID                 OSA_ITEM_ID
,       wdj.start_quantity              start_quantity
,       NVL(trunc(poll.need_by_date), trunc(poll.promised_date))
        pol_need_by_date
,       poll.quantity                   quantity
,       sco.quantity                    old_ordered_quantity
,       poll.unit_meas_lookup_code      purchasing_uom
,       pol.cancel_flag                 pol_cancel_flag
,       poh.cancel_flag                 poh_cancel_flag
,       poll.cancel_flag                poll_cancel_flag
,      trunc( wdj.SCHEDULED_START_DATE) SCHEDULED_START_DATE
FROM    JMF_SUBCONTRACT_ORDERS  sco
,       po_headers_all          poh
,       po_lines_all            pol
,       po_line_locations_all   poll
,       wip_discrete_jobs       wdj
WHERE   pol.po_header_id         = sco.SUBCONTRACT_PO_HEADER_ID
  and   pol.po_line_id           = sco.SUBCONTRACT_PO_LINE_ID
  and   poll.po_line_id          = pol.po_line_id
  and   poll.line_location_id = sco.SUBCONTRACT_PO_SHIPMENT_ID
  and   wdj.wip_entity_id        = sco.WIP_ENTITY_ID
  and   sco.interlock_status     = 'P'
  and   ( trunc(sco.NEED_BY_DATE)  <>
NVL(trunc(poll.need_by_date), trunc(poll.promised_date)) OR
                sco.quantity <> poll.quantity  OR
                pol.cancel_flag = 'Y' OR
                poh.cancel_flag = 'Y' OR
                poll.cancel_flag = 'Y' )
  and   poh.po_header_id         = sco.SUBCONTRACT_PO_HEADER_ID
  and   pol.po_header_id         = poh.po_header_id
ORDER BY sco.subcontract_po_shipment_id ;

l_SUBCONTRACT_PO_SHIPMENT_ID   NUMBER ;

 CURSOR C_shikyu_cancel_comp_CSR IS
  SELECT SUBCONTRACT_PO_SHIPMENT_ID
 ,     SHIKYU_COMPONENT_ID
 ,     OEM_ORGANIZATION_ID
 ,     SHIKYU_COMPONENT_PRICE
 ,     PRIMARY_UOM
 FROM  JMF_SHIKYU_COMPONENTS
 WHERE SUBCONTRACT_PO_SHIPMENT_ID  = l_subcontract_po_shipment_id ;

 l_used_quantity        NUMBER;

l_deleted_allocations_tbl
         JMF_SHIKYU_ALLOCATION_PVT.g_allocation_qty_tbl_type ;
l_msg_data              VARCHAR2(300);
l_msg_count             NUMBER ;
l_return_status         VARCHAR2(3);
 l_primary_quantity     NUMBER ;

BEGIN

--- First step : calean up invalid data
--  second: reconcile partial transactions
-- Main api for the reconciliation process
-- select the subcontract records where either DATES or qty has been
--changed after interlock OR the PO shipment cancelled

-- IF PO shipment cancelled :
--    cancel the WIP job
--    remove all the allocations for the qty that have not been
--    issued to WIP job yet.

-- IF not cancelled, but date or qty changed:

-- process the date changes
-- process the qty changes

-- update the JMF subcontract table with the new values
-- COMMIT

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , 'JMFVSKRB' ||
         'Process_SHIKYU_Reconciliation.invoked'
                  , 'Entry');
  END IF;


  -- Start API initialization

    FND_MSG_PUB.initialize;


  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- End API initialization

  -- Select the eligible data for Reconciliation

  -- Process the changes due to PO subcontract order NEED BY DATE Only
  -- Process the change due to the PO subcontract QTY changes Only
  -- Process changes due to both PO subcontract need by date and qty changes

   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , 'JMFVSKRB' ||
         'calling  JMF_SHIKYU_UTIL.clean_invalid_data '
                  , 'out cleanup' );
    END IF;

   JMF_SHIKYU_UTIL.clean_invalid_data ;

   COMMIT;

-- dbms_output.put_line(' Calling  Reconcile_Partial_Shipments ');
  IF (g_fnd_debug = 'Y')
  THEN
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , 'JMFVSKRB' ||
         'calling  JMF_SHIKYU_ALLOCATION_PVT.Reconcile_Partial_Shipments'
                  , 'rajesh');
   END IF;
  END IF;

  BEGIN
    JMF_SHIKYU_ALLOCATION_PVT.Reconcile_Partial_Shipments
    ( p_api_version       => 1.0
    , p_init_msg_list     => 'Y'
    , x_return_status     => l_return_status
    , x_msg_count         => l_msg_count
    , x_msg_data          => l_msg_data
    , p_from_organization => p_from_organization
    , p_to_organization   => p_to_organization
    );

    COMMIT;

    EXCEPTION
    WHEN OTHERS THEN
       ROLLBACK;
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX ||
         'JMFVSKRB: OUT OF Reconcile_Partial_Shipments -- EXCEPTION => '
                  , l_return_status);
   END IF;

 END ;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
  FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , G_MODULE_PREFIX ||
         'JMFVSKRB: continue after  Reconcile_Partial_Shipments '
                  , l_return_status);
  END IF;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , 'x_msg_data :: '||  x_msg_data
                  , x_msg_data);
   END IF;


 l_return_status := NULL;

-- dbms_output.put_line(' About to open cursor SHIKYU_reconcile_CSR');
IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , 'About to open cursor SHIKYU_reconcile_CSR'
                  , 'JMFVSKRB' );
   END IF;

 FOR SHIKYU_reconcile_rec IN SHIKYU_reconcile_CSR
 LOOP
  BEGIN
    l_subcontract_po_shipment_id :=
         SHIKYU_reconcile_rec.SUBCONTRACT_PO_SHIPMENT_ID;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , 'JMFVSKRB ' ||
         'INTO CURSOR SHIKYU_reconcile_rec.SUBCONTRACT_PO_SHIPMENT_ID => '
                  , SHIKYU_reconcile_rec.SUBCONTRACT_PO_SHIPMENT_ID );
   END IF;

   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , 'JMFVSKRB ' ||
         'l_subcontract_po_shipment_id => '
                  , l_subcontract_po_shipment_id);
   END IF;

   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
   FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , 'JMFVSKRB: ' ||
         'SHIKYU_reconcile_rec.pol_need_by_date => '
                  , SHIKYU_reconcile_rec.pol_need_by_date);
   END IF;
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , 'JMFVSKRB: ' ||
         'SHIKYU_reconcile_rec.sco_NEED_BY_DATE => '
                  , SHIKYU_reconcile_rec.sco_NEED_BY_DATE);
   END IF;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , 'JMFVSKRB: ' ||
         'SHIKYU_reconcile_rec.old_ordered_quantity =>'
                  , SHIKYU_reconcile_rec.old_ordered_quantity);
   END IF;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , 'JMFVSKRB: ' ||
         'SHIKYU_reconcile_rec.quantity => '
                  , SHIKYU_reconcile_rec.quantity);
   END IF;
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , 'JMFVSKRB: ' ||
         'SHIKYU_reconcile_rec.pol_cancel_flag => '
                  , SHIKYU_reconcile_rec.pol_cancel_flag);
   END IF;
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , 'JMFVSKRB: ' ||
         'SHIKYU_reconcile_rec.poll_cancel_flag => '
                  , SHIKYU_reconcile_rec.poll_cancel_flag);
   END IF;
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , 'JMFVSKRB: ' ||
         'SHIKYU_reconcile_rec.poh_cancel_flag => '
                  , SHIKYU_reconcile_rec.poh_cancel_flag);
   END IF;
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , 'JMFVSKRB: ' ||
         'SHIKYU_reconcile_rec.SUBCONTRACT_PO_SHIPMENT_ID => '
                  , SHIKYU_reconcile_rec.SUBCONTRACT_PO_SHIPMENT_ID);
   END IF;
    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , 'JMFVSKRB: ' ||
         'SHIKYU_reconcile_rec.scheduled_start_dat => '
                  , SHIKYU_reconcile_rec.scheduled_start_date);
   END IF;


    IF SHIKYU_reconcile_rec.pol_cancel_flag = 'Y' OR
       SHIKYU_reconcile_rec.poh_cancel_flag = 'Y' OR
       SHIKYU_reconcile_rec.poll_cancel_flag = 'Y'
    THEN
      BEGIN
     -- Cancel WIP Jobs
     -- Remove all the allocations
       IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , 'JMFVSKRB: ' ||
         'INTO CANCEL for SHIKYU_reconcile_rec.SUBCONTRACT_PO_SHIPMENT_ID '
                  , SHIKYU_reconcile_rec.SUBCONTRACT_PO_SHIPMENT_ID );
       END IF;


        IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , 'JMFVSKRB: ' ||
              'Calling JMF_SHIKYU_WIP_PVT.Process_WIP_Job  D for SCO '
                  ,SHIKYU_reconcile_rec.SUBCONTRACT_PO_SHIPMENT_ID );
         END IF;

      JMF_SHIKYU_WIP_PVT.Process_WIP_Job
      ( p_action                      => 'D'
      , p_SUBCONTRACT_PO_SHIPMENT_ID  =>
                SHIKYU_reconcile_rec.SUBCONTRACT_PO_SHIPMENT_ID
      , p_need_by_date                => NULL
      , p_quantity                    => NULL
      , x_return_status               => l_return_status
      ) ;

       IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , 'JMFVSKRB: ' ||
         'out JMF_SHIKYU_WIP_PVT.Process_WIP_Job ' ||
                  SHIKYU_reconcile_rec.SUBCONTRACT_PO_SHIPMENT_ID
                  ,' l_return_status => '|| l_return_status );
        END IF;

        --COMMIT;

        IF SHIKYU_reconcile_rec.scheduled_start_date > SYSDATE
        THEN
           IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , 'JMFVSKRB: ' ||
         ' SHIKYU_reconcile_rec.scheduled_start_date => '||
                  SHIKYU_reconcile_rec.scheduled_start_date
                  ,' Calling JMF_SHIKYU_ALLOCATION_PVT.Delete_Allocations ');
           END IF;

         JMF_SHIKYU_ALLOCATION_PVT.Delete_Allocations
         ( p_api_version                => 1.0
         , p_init_msg_list              => NULL
         , x_return_status              => l_return_status
         , x_msg_count                  => l_msg_count
         , x_msg_data                   => l_msg_data
          , p_subcontract_po_shipment_id =>
             SHIKYU_reconcile_rec.SUBCONTRACT_PO_SHIPMENT_ID
          , p_component_id               => NULL
          , p_replen_so_line_id          => NULL
          , x_deleted_allocations_tbl    =>
                l_deleted_allocations_tbl
          );

           IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                    , 'JMFVSKRB ' ||
                'out JMF_SHIKYU_ALLOCATION_PVT.Delete_Allocations '
                     ,' l_return_status => '|| l_return_status );
            END IF;

         ELSE
-- dbms_output.put_line('  Cancel components ');
            IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , 'JMFVSKRB: ' ||
                    ' INTO Cancel components SCO SHIPMENT  '
                  ,SHIKYU_reconcile_rec.SUBCONTRACT_PO_SHIPMENT_ID );
            END IF;

          l_used_quantity := NULL;
          FOR C_shikyu_cancel_comp_rec IN C_shikyu_cancel_comp_CSR
          LOOP
             IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
             THEN
                FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , 'JMFVSKRB: ' ||
                      ' CURSOR shikyu_cancel_comp_rec.shikyu_component_id => '
                  ,c_shikyu_cancel_comp_rec.shikyu_component_id );
            END IF;

            l_used_quantity := 0 ;

             IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
             THEN
                FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , 'JMFVSKRB: ' ||
                    'jmf  about invoke JMF_SHIKYU_UTIL.GET_used_quantity for '
                  ,C_shikyu_cancel_comp_rec.shikyu_component_id );
            END IF;

            l_used_quantity :=
             JMF_SHIKYU_UTIL.GET_used_quantity
            ( p_wip_entity_id     =>
             SHIKYU_reconcile_rec.wip_entity_id
             , p_shikyu_component_id  =>
             C_shikyu_cancel_comp_rec.shikyu_component_id
             , p_organization_id      =>
                  SHIKYU_reconcile_rec.oem_organization_id
              );

               IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
               THEN
                FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , 'JMFVSKRB: ' ||
                    ' JMF l_used_quantity => '
                  ,l_used_quantity );
               END IF;


              IF NVL(l_used_quantity,0) <=  0
              THEN
               IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
               THEN
                FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , 'JMFVSKRB: ' ||
                    ' Calling JMF_SHIKYU_ALLOCATION_PVT.Delete_Allocations '
                  ,C_shikyu_cancel_comp_rec.shikyu_component_id );
               END IF;

                JMF_SHIKYU_ALLOCATION_PVT.Delete_Allocations
                 ( p_api_version                => 1.0
                 , p_init_msg_list              => NULL
                 , x_return_status              => l_return_status
                 , x_msg_count                  => l_msg_count
                 , x_msg_data                   => l_msg_data
                 , p_subcontract_po_shipment_id =>
             SHIKYU_reconcile_rec.SUBCONTRACT_PO_SHIPMENT_ID
                 , p_component_id               =>
              C_shikyu_cancel_comp_rec.shikyu_component_id
                 , p_replen_so_line_id          => NULL
                 , x_deleted_allocations_tbl    =>
                     l_deleted_allocations_tbl
                 );
              END IF;
            END LOOP;
          END IF ;  -- Greater than start date

           IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , 'JMFVSKRB' ||
             'JMFVSKRB: UPDATE and COMMIT for SCO PO CANCEL flow  '
                  , SHIKYU_reconcile_rec.SUBCONTRACT_PO_SHIPMENT_ID );
           END IF;


          UPDATE JMF_SUBCONTRACT_ORDERS
          SET interlock_status = 'T'
          WHERE SUBCONTRACT_PO_SHIPMENT_ID =
              SHIKYU_reconcile_rec.SUBCONTRACT_PO_SHIPMENT_ID
           and (   SHIKYU_reconcile_rec.pol_cancel_flag = 'Y' OR
       SHIKYU_reconcile_rec.poh_cancel_flag = 'Y' OR
        SHIKYU_reconcile_rec.poll_cancel_flag = 'Y' );


          COMMIT;

          EXCEPTION
          WHEN OTHERS THEN
           BEGIN
           ROLLBACK ;

           IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , 'JMFVSKRB' ||
             'JMFVSKRB: EXCEPTION 1   in CANCEL FLOW '
                  , SHIKYU_reconcile_rec.SUBCONTRACT_PO_SHIPMENT_ID );
           END IF;
           END ;


       END ;
    ELSE -- NOT cancel logic
        l_return_status := NULL ;
        IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , 'JMFVSKRB ' ||
             'INto NON cancel logic '
                  ,' l_return_status => '|| l_return_status );
        END IF;
        IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , 'JMFVSKRB ' ||
             'SHIKYU_reconcile_rec.SUBCONTRACT_PO_SHIPMENT_ID => '
                  ,SHIKYU_reconcile_rec.SUBCONTRACT_PO_SHIPMENT_ID);
        END IF;

      l_primary_quantity  :=  NULL;
      l_primary_quantity  := JMF_SHIKYU_UTIL.get_prImary_quantity
      ( p_purchasing_UOM     =>
          SHIKYU_reconcile_rec.purchasing_UOM
      , p_quantity           =>
            SHIKYU_reconcile_rec.quantity
      , P_inventory_org_id   => SHIKYU_reconcile_rec.oem_organization_id
      , p_inventory_item_id  => SHIKYU_reconcile_rec.OSA_ITEM_ID ) ;


    -- Update the WIP jobs and update the JMF table

         IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , 'JMFVSKRB ' ||
             'Calling JMF_SHIKYU_WIP_PVT.Process_WIP_Job U for SCO '
                  ,SHIKYU_reconcile_rec.SUBCONTRACT_PO_SHIPMENT_ID );
        END IF;

       JMF_SHIKYU_WIP_PVT.Process_WIP_Job
       ( p_action                      => 'U'
        , p_SUBCONTRACT_PO_SHIPMENT_ID  =>
             SHIKYU_reconcile_rec.SUBCONTRACT_PO_SHIPMENT_ID
        , p_need_by_date                =>
            SHIKYU_reconcile_rec.pol_need_by_date
        , p_quantity                    => l_primary_quantity
        , x_return_status               => l_return_status
        ) ;

        IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , 'JMFVSKRB ' ||
             'out  JMF_SHIKYU_WIP_PVT.Process_WIP_Job with '
                  ,l_return_status );
        END IF;

        IF l_return_status  = 'S'
        THEN
           -- changes IF
             IF ( TRUNC( SHIKYU_reconcile_rec.pol_need_by_date ) <>
             TRUNC(SHIKYU_reconcile_rec.sco_need_by_date) )
               AND ( SHIKYU_reconcile_rec.old_ordered_quantity ) =
               ( SHIKYU_reconcile_rec.quantity )
             THEN

            IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , 'JMFVSKRB ' ||
             'Calling Process_Date_Changes '
                  ,SHIKYU_reconcile_rec.SUBCONTRACT_PO_SHIPMENT_ID );
             END IF;

              Process_Date_Changes
               (  p_SUBCONTRACT_PO_SHIPMENT_ID  =>
                  SHIKYU_reconcile_rec.SUBCONTRACT_PO_SHIPMENT_ID
               ,  p_SUBCONTRACT_PO_HEADER_ID    =>
                  SHIKYU_reconcile_rec.SUBCONTRACT_PO_HEADER_ID
              ,  p_SUBCONTRACT_PO_LINE_ID      =>
                  SHIKYU_reconcile_rec.SUBCONTRACT_PO_LINE_ID
              ,  p_OLD_NEED_BY_DATE            =>
                      SHIKYU_reconcile_rec.sco_NEED_BY_DATE
              ,  p_UOM                         =>
                           SHIKYU_reconcile_rec.UOM
              ,  p_CURRENCY                    =>
                       SHIKYU_reconcile_rec.CURRENCY
              ,  p_OEM_ORGANIZATION_ID         =>
                           SHIKYU_reconcile_rec.OEM_ORGANIZATION_ID
              ,  p_TP_ORGANIZATION_ID          =>
                          SHIKYU_reconcile_rec.tp_ORGANIZATION_ID
              ,  p_WIP_ENTITY_ID               =>
                          SHIKYU_reconcile_rec.WIP_ENTITY_ID
              ,  p_OSA_ITEM_ID                 =>
                             SHIKYU_reconcile_rec.OSA_ITEM_ID
              ,  p_wip_start_quantity          =>
                          SHIKYU_reconcile_rec.start_quantity
              ,  p_new_need_by_date            =>
                        SHIKYU_reconcile_rec.pol_need_by_date
              ,  p_new_ordered_quantity        =>
                          SHIKYU_reconcile_rec.quantity
              ,  p_old_ordered_quantity        =>
                            SHIKYU_reconcile_rec.old_ordered_quantity
              ,  p_puchasing_UOM               =>
                            SHIKYU_reconcile_rec.purchasing_uom
              ) ;


              ELSIF ( TRUNC( SHIKYU_reconcile_rec.pol_need_by_date ) =
                    TRUNC(SHIKYU_reconcile_rec.sco_need_by_date) )
                 AND ( SHIKYU_reconcile_rec.old_ordered_quantity ) <>
                     ( SHIKYU_reconcile_rec.quantity )
              THEN
                -- Process Qty changes

            IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , 'JMFVSKRB ' ||
             'Calling Process_Quantity_Changes '
                  ,SHIKYU_reconcile_rec.SUBCONTRACT_PO_SHIPMENT_ID );
             END IF;

              Process_Quantity_Changes
               (  p_SUBCONTRACT_PO_SHIPMENT_ID  =>
                  SHIKYU_reconcile_rec.SUBCONTRACT_PO_SHIPMENT_ID
               ,  p_SUBCONTRACT_PO_HEADER_ID    =>
                  SHIKYU_reconcile_rec.SUBCONTRACT_PO_HEADER_ID
              ,  p_SUBCONTRACT_PO_LINE_ID      =>
                  SHIKYU_reconcile_rec.SUBCONTRACT_PO_LINE_ID
              ,  p_OLD_NEED_BY_DATE            =>
                      SHIKYU_reconcile_rec.sco_NEED_BY_DATE
              ,  p_UOM                         =>
                           SHIKYU_reconcile_rec.UOM
              ,  p_CURRENCY                    =>
                       SHIKYU_reconcile_rec.CURRENCY
              ,  p_OEM_ORGANIZATION_ID         =>
                           SHIKYU_reconcile_rec.OEM_ORGANIZATION_ID
              ,  p_TP_ORGANIZATION_ID          =>
                          SHIKYU_reconcile_rec.tp_ORGANIZATION_ID
              ,  p_WIP_ENTITY_ID               =>
                          SHIKYU_reconcile_rec.WIP_ENTITY_ID
              ,  p_OSA_ITEM_ID                 =>
                             SHIKYU_reconcile_rec.OSA_ITEM_ID
              ,  p_wip_start_quantity          =>
                          SHIKYU_reconcile_rec.start_quantity
              ,  p_new_need_by_date            =>
                        SHIKYU_reconcile_rec.pol_need_by_date
              ,  p_new_ordered_quantity        =>
                          SHIKYU_reconcile_rec.quantity
              ,  p_old_ordered_quantity        =>
                            SHIKYU_reconcile_rec.old_ordered_quantity
              ,  p_puchasing_UOM               =>
                            SHIKYU_reconcile_rec.purchasing_uom
              ) ;


              ELSIF ( TRUNC( SHIKYU_reconcile_rec.pol_need_by_date ) <>
                     TRUNC(SHIKYU_reconcile_rec.sco_need_by_date) )
                 AND ( SHIKYU_reconcile_rec.old_ordered_quantity ) <>
                     ( SHIKYU_reconcile_rec.quantity )
              THEN

                IF (FND_LOG.LEVEL_PROCEDURE >=
                        FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                       FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , 'JMFVSKRB ' ||
                       'Calling Process_Date_Changes '
                  ,SHIKYU_reconcile_rec.SUBCONTRACT_PO_SHIPMENT_ID );
             END IF;

              Process_Date_Changes
               (  p_SUBCONTRACT_PO_SHIPMENT_ID  =>
                  SHIKYU_reconcile_rec.SUBCONTRACT_PO_SHIPMENT_ID
               ,  p_SUBCONTRACT_PO_HEADER_ID    =>
                  SHIKYU_reconcile_rec.SUBCONTRACT_PO_HEADER_ID
              ,  p_SUBCONTRACT_PO_LINE_ID      =>
                  SHIKYU_reconcile_rec.SUBCONTRACT_PO_LINE_ID
              ,  p_OLD_NEED_BY_DATE            =>
                      SHIKYU_reconcile_rec.sco_NEED_BY_DATE
              ,  p_UOM                         =>
                           SHIKYU_reconcile_rec.UOM
              ,  p_CURRENCY                    =>
                       SHIKYU_reconcile_rec.CURRENCY
              ,  p_OEM_ORGANIZATION_ID         =>
                           SHIKYU_reconcile_rec.OEM_ORGANIZATION_ID
              ,  p_TP_ORGANIZATION_ID          =>
                          SHIKYU_reconcile_rec.tp_ORGANIZATION_ID
              ,  p_WIP_ENTITY_ID               =>
                          SHIKYU_reconcile_rec.WIP_ENTITY_ID
              ,  p_OSA_ITEM_ID                 =>
                             SHIKYU_reconcile_rec.OSA_ITEM_ID
              ,  p_wip_start_quantity          =>
                          SHIKYU_reconcile_rec.start_quantity
              ,  p_new_need_by_date            =>
                        SHIKYU_reconcile_rec.pol_need_by_date
              ,  p_new_ordered_quantity        =>
                          SHIKYU_reconcile_rec.quantity
              ,  p_old_ordered_quantity        =>
                            SHIKYU_reconcile_rec.old_ordered_quantity
              ,  p_puchasing_UOM               =>
                            SHIKYU_reconcile_rec.purchasing_uom
              ) ;


              Process_Quantity_Changes
               (  p_SUBCONTRACT_PO_SHIPMENT_ID  =>
                  SHIKYU_reconcile_rec.SUBCONTRACT_PO_SHIPMENT_ID
               ,  p_SUBCONTRACT_PO_HEADER_ID    =>
                  SHIKYU_reconcile_rec.SUBCONTRACT_PO_HEADER_ID
              ,  p_SUBCONTRACT_PO_LINE_ID      =>
                  SHIKYU_reconcile_rec.SUBCONTRACT_PO_LINE_ID
              ,  p_OLD_NEED_BY_DATE            =>
                      SHIKYU_reconcile_rec.sco_NEED_BY_DATE
              ,  p_UOM                         =>
                           SHIKYU_reconcile_rec.UOM
              ,  p_CURRENCY                    =>
                       SHIKYU_reconcile_rec.CURRENCY
              ,  p_OEM_ORGANIZATION_ID         =>
                           SHIKYU_reconcile_rec.OEM_ORGANIZATION_ID
              ,  p_TP_ORGANIZATION_ID          =>
                          SHIKYU_reconcile_rec.tp_ORGANIZATION_ID
              ,  p_WIP_ENTITY_ID               =>
                          SHIKYU_reconcile_rec.WIP_ENTITY_ID
              ,  p_OSA_ITEM_ID                 =>
                             SHIKYU_reconcile_rec.OSA_ITEM_ID
              ,  p_wip_start_quantity          =>
                          SHIKYU_reconcile_rec.start_quantity
              ,  p_new_need_by_date            =>
                        SHIKYU_reconcile_rec.pol_need_by_date
              ,  p_new_ordered_quantity        =>
                          SHIKYU_reconcile_rec.quantity
              ,  p_old_ordered_quantity        =>
                            SHIKYU_reconcile_rec.old_ordered_quantity
              ,  p_puchasing_UOM               =>
                            SHIKYU_reconcile_rec.purchasing_uom
              ) ;


             END IF; -- changes IF

                IF (FND_LOG.LEVEL_PROCEDURE >=
                    FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , 'JMFVRKSB: '||
                           'UPDATE JMF_SUBCONTRACT_ORDERS '
                         , SHIKYU_reconcile_rec.SUBCONTRACT_PO_SHIPMENT_ID );
                 END IF;


              UPDATE JMF_SUBCONTRACT_ORDERS
              SET    quantity = SHIKYU_reconcile_rec.quantity
                   , need_by_date = SHIKYU_reconcile_rec.pol_need_by_date
                   , last_update_date = sysdate
                   , last_updated_by = FND_GLOBAL.user_id
                   , last_update_login = FND_GLOBAL.login_id
              WHERE  SUBCONTRACT_PO_HEADER_ID =
                     SHIKYU_reconcile_rec.SUBCONTRACT_PO_HEADER_ID
                and  SUBCONTRACT_PO_LINE_ID =
                     SHIKYU_reconcile_rec.SUBCONTRACT_PO_LINE_ID
                and  SUBCONTRACT_PO_SHIPMENT_ID =
                     SHIKYU_reconcile_rec.SUBCONTRACT_PO_SHIPMENT_ID ;

              COMMIT;

                IF (FND_LOG.LEVEL_PROCEDURE >=
                    FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                      FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , 'JMFVRKSB: '||
                           'AFTER UPDATE JMF_SUBCONTRACT_ORDERS '
                         , SHIKYU_reconcile_rec.SUBCONTRACT_PO_SHIPMENT_ID );
                 END IF;


        ELSE  -- return status
          ROLLBACK;
        END IF; -- WIP job
      END IF; -- soc status

    EXCEPTION
    WHEN OTHERS THEN
       ROLLBACK ;
       IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , 'JMFVSKRB: '||
                     ' MAIN LOOP exception for SCO shipment '
                  , SHIKYU_reconcile_rec.SUBCONTRACT_PO_SHIPMENT_ID );
        END IF;
    END ;

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  , 'JMFVSKRB: ' ||
                    ' Done processing SCO shipment => '
                  ,SHIKYU_reconcile_rec.SUBCONTRACT_PO_SHIPMENT_ID );
            END IF;

    END LOOP ;  -- Main Loop

-- dbms_output.put_line('  Out of Main loop ');

    IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE
                  ,  'JMFVSKRB: Process_SHIKYU_Reconciliation. OUT'
                  , 'OUT');
  END IF;
 --dbms_output.put_line('  OUT of Process_SHIKYU_Reconciliation. ');
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
-- dbms_output.put_line('  EXCEPTION: FND_API.G_EXC_ERROR ');
-- dbms_output.put_line('  SQLERRM : '|| SQLERRM );
    ROLLBACK;
    FND_MSG_PUB.Count_And_Get
                             ( p_count => x_msg_count
                             , p_data  => x_msg_data
                             );
    x_return_status := FND_API.g_ret_sts_error;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
-- dbms_output.put_line('  EXCEPTION: FND_API.G_EXC_UNEXPECTED_ERROR ');
-- dbms_output.put_line('  SQLERRM : '|| SQLERRM );
    ROLLBACK ;
    FND_MSG_PUB.Count_And_Get
                             ( p_count => x_msg_count
                             , p_data  => x_msg_data
                             );

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  WHEN OTHERS THEN
    ROLLBACK ;
    FND_MSG_PUB.Count_And_Get
                             ( p_count => x_msg_count
                             , p_data  => x_msg_data
                             );

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF (g_fnd_debug = 'Y')
    THEN
    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_PREFIX ||  '.others_exception'
                    , 'rajesh Exception');
    END IF;
    END IF;

END Process_SHIKYU_Reconciliation ;

END JMF_SHIKYU_RECONCILIAITON_PVT ;

/
