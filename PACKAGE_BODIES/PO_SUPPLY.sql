--------------------------------------------------------
--  DDL for Package Body PO_SUPPLY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_SUPPLY" AS
/* $Header: RCVRCSUB.pls 120.11.12010000.8 2012/02/06 23:38:45 yuewliu ship $ */



/* ----------------------------------------------------------------------- */
/*                                                                         */
/*                      Private Function Definition                        */
/*                                                                         */
/* ----------------------------------------------------------------------- */


FUNCTION approve_req(p_docid IN NUMBER) RETURN BOOLEAN;


FUNCTION remove_req(
  p_entity_id   IN NUMBER
, p_entity_type IN VARCHAR2
) RETURN BOOLEAN;


FUNCTION remove_req_vend_lines(p_docid IN NUMBER) RETURN BOOLEAN;


FUNCTION update_req_line_qty(
  p_lineid IN NUMBER
, p_qty    IN NUMBER
) RETURN BOOLEAN;


FUNCTION update_req_line_date(
  p_lineid       IN NUMBER
, p_receipt_date IN DATE
) RETURN BOOLEAN;


FUNCTION update_planned_po(
  p_docid       IN     NUMBER
, p_shipid      IN     NUMBER DEFAULT 0
, p_entity_type IN     VARCHAR2
, p_supply_flag IN OUT NOCOPY BOOLEAN
) RETURN BOOLEAN;




/* ----------------------------------------------------------------------- */
/*                                                                         */
/*   Switchboard for PO and Requisition Actions                            */
/*                                                                         */
/*   Invokes the required PO and Requisition functions depending on the    */
/*   Action being passed in                                                */
/*                                                                         */
/* ----------------------------------------------------------------------- */


FUNCTION po_req_supply(
  p_docid               IN NUMBER
, p_lineid              IN NUMBER
, p_shipid              IN NUMBER
, p_action              IN VARCHAR2
, p_recreate_flag       IN BOOLEAN
, p_qty                 IN NUMBER
, p_receipt_date        IN DATE
, p_reservation_action  IN VARCHAR2 DEFAULT NULL  --<R12 PLAN CROSS DOCK>
, p_ordered_uom         IN VARCHAR2 DEFAULT NULL  --5253916
) RETURN BOOLEAN
IS

--<R12 PLAN CROSS DOCK START>
l_recreate_flag     VARCHAR2(1);
l_return_status     VARCHAR2(1);
l_action            VARCHAR2(200);
--<R12 PLAN CROSS DOCK END>

d_module            VARCHAR2(70) := 'po.plsql.PO_SUPPLY.po_req_supply';
d_progress          NUMBER;
l_doc_id            NUMBER;

l_return_value      BOOLEAN;

BEGIN

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module, 'p_docid', p_docid);
    PO_LOG.proc_begin(d_module, 'p_lineid', p_lineid);
    PO_LOG.proc_begin(d_module, 'p_shipid', p_shipid);
    PO_LOG.proc_begin(d_module, 'p_action', p_action);
    PO_LOG.proc_begin(d_module, 'p_recreate_flag', p_recreate_flag);
    PO_LOG.proc_begin(d_module, 'p_qty', p_qty);
    PO_LOG.proc_begin(d_module, 'p_receipt_date', p_receipt_date);
    PO_LOG.proc_begin(d_module, 'p_reservation_action', p_reservation_action);
    PO_LOG.proc_begin(d_module, 'p_ordered_uom', p_ordered_uom);
  END IF;

  d_progress := 10;

  --<R12 PLAN CROSS DOCK START>
  IF p_recreate_flag THEN
    l_recreate_flag := 'Y';
  ELSE
    l_recreate_flag := 'N';
  END IF;
  --<R12 PLAN CROSS DOCK END>

  d_progress := 20;

  BEGIN

    IF (p_action = 'Approve_Req_Supply') THEN

      d_progress := 30;
      l_return_value := approve_req(p_docid => p_docid);

    ELSIF (p_action = 'Remove_Req_Supply') THEN

      d_progress := 40;
      l_return_value := remove_req(
                          p_entity_id   => p_docid
                        , p_entity_type => 'REQ HDR'
                        );

    ELSIF (p_action = 'Remove_Return_Req_Supply') THEN

      d_progress := 50;
      l_return_value := remove_req_vend_lines(p_docid => p_docid);

    ELSIF (p_action = 'Remove_Req_Line_Supply') THEN

      d_progress := 60;
      l_return_value := remove_req(
                          p_entity_id   => p_lineid
                        , p_entity_type => 'REQ LINE'
                        );

    ELSIF (p_action = 'Create_Req_Line_Supply') THEN

      d_progress := 70;
      l_return_value := create_req(
                          p_entity_id   => p_lineid
                        , p_entity_type => 'REQ LINE'
                        );

    ELSIF (p_action = 'Explode_Req') THEN

      d_progress := 80;
      l_return_value := explode(p_lineid => p_lineid);

    ELSIF (p_action = 'Update_Req_Line_Qty') THEN

      d_progress := 90;
      l_return_value := update_req_line_qty(
                          p_lineid => p_lineid
                        , p_qty    => p_qty
                        );

    ELSIF (p_action = 'Update_Req_Line_Date') THEN

      d_progress := 100;
      l_return_value := update_req_line_date(
                          p_lineid       => p_lineid
                        , p_receipt_date => p_receipt_date
                        );

    ELSIF (p_action = 'Approve_PO_Supply') THEN

      d_progress := 110;
      l_return_value := approve_po_supply(p_docid => p_docid);

    ELSIF (p_action = 'Approve_Blanket_Release_Supply') THEN

      d_progress := 120;
      l_return_value := approve_blanket_supply(p_docid => p_docid);

    ELSIF (p_action = 'Approve_Planned_Release_Supply') THEN

      d_progress := 130;
      l_return_value := approve_planned_supply(p_docid => p_docid);

    ELSIF (p_action = 'Create_PO_Supply') THEN

      d_progress := 140;
      l_return_value := create_po_supply(
                          p_entity_id => p_docid
                        , p_entity_type => 'PO'
                        );

    ELSIF (p_action = 'Create_Release_Supply') THEN

      d_progress := 150;
      l_return_value := create_po_supply(
                          p_entity_id => p_docid
                        , p_entity_type => 'RELEASE'
                        );

    ELSIF (p_action = 'Create_PO_Line_Supply') THEN

      d_progress := 160;
      l_return_value := create_po_supply(
                          p_entity_id => p_lineid
                        , p_entity_type => 'PO LINE'
                        );

    ELSIF (p_action = 'Create_PO_Shipment_Supply') THEN

      d_progress := 170;
      l_return_value := create_po_supply(
                          p_entity_id => p_shipid
                        , p_entity_type => 'PO SHIPMENT'
                        );

    ELSIF (p_action = 'Create_Release_Shipment_Supply') THEN

      d_progress := 180;
      l_return_value := create_po_supply(
                          p_entity_id => p_shipid
                        , p_entity_type => 'RELEASE SHIPMENT'
                        );

    ELSIF (p_action = 'Remove_PO_Supply') THEN

      d_progress := 190;
      l_return_value := delete_supply(
                          p_entity_id => p_docid
                        , p_entity_type => 'PO'
                        );

    ELSIF (p_action = 'Remove_Release_Supply') THEN

      d_progress := 200;
      l_return_value := delete_supply(
                          p_entity_id => p_docid
                        , p_entity_type => 'RELEASE'
                        );

    ELSIF (p_action = 'Remove_PO_Line_Supply') THEN

      d_progress := 210;
      l_return_value := update_supply(
                          p_entity_id => p_lineid
                        , p_entity_type => 'PO LINE'
                        );

    ELSIF (p_action = 'Remove_PO_Shipment_Supply') THEN

      d_progress := 220;
      l_return_value := update_supply(
                          p_entity_id => p_shipid
                        , p_entity_type => 'PO SHIPMENT'
                        );

    ELSIF (p_action = 'Remove_Release_Shipment') THEN

      d_progress := 230;
      l_return_value := update_supply(
                          p_entity_id => p_docid
                        , p_entity_type => 'RELEASE SHIPMENT'
                        , p_shipid => p_shipid
                        );

    ELSIF (p_action = 'Cancel_PO_Supply') THEN

      d_progress := 240;
      l_return_value := cancel_supply(
                          p_entity_id => p_docid
                        , p_entity_type => 'PO'
                        );

    ELSIF (p_action = 'Cancel_PO_Line') THEN

      d_progress := 250;
      l_return_value := cancel_supply(
                          p_entity_id => p_lineid
                        , p_entity_type => 'PO LINE'
                        );

    ELSIF (p_action = 'Cancel_PO_Shipment') THEN

      d_progress := 260;
      l_return_value := cancel_supply(
                          p_entity_id => p_shipid
                        , p_entity_type => 'PO SHIPMENT'
                        );

    ELSIF (p_action = 'Cancel_Blanket_Release') THEN

      d_progress := 270;
      l_return_value := cancel_supply(
                          p_entity_id => p_docid
                        , p_entity_type => 'RELEASE'
                        );

    ELSIF (p_action = 'Cancel_Blanket_Shipment') THEN

      d_progress := 280;
      l_return_value := cancel_supply(
                          p_entity_id => p_docid
                        , p_entity_type => 'RELEASE SHIPMENT'
                        , p_shipid => p_shipid
                        );

    ELSIF (p_action = 'Cancel_Planned_Release') THEN

      d_progress := 290;
      l_return_value := cancel_planned(
                          p_entity_id => p_docid
                        , p_entity_type => 'RELEASE'
                        , p_recreate_flag => p_recreate_flag
                        );

    ELSIF (p_action = 'Cancel_Planned_Shipment') THEN

      d_progress := 300;
      l_return_value := cancel_planned(
                          p_entity_id => p_docid
                        , p_entity_type => 'RELEASE SHIPMENT'
                        , p_shipid => p_shipid
                        , p_recreate_flag => p_recreate_flag
                        );

    END IF;  -- Switchboard

    IF (NOT l_return_value) THEN

      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_progress, 'Supply action failed.');
      END IF;

      RAISE PO_CORE_S.g_early_return_exc;

    END IF;


    d_progress := 600;

    l_return_value := maintain_mtl_supply;

    IF (NOT l_return_value) THEN

      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_progress, 'maintain_mtl_supply not successful.');
      END IF;

      RAISE PO_CORE_S.g_early_return_exc;

    END IF;

    d_progress := 700;


    --< R12 PLAN CROSS DOCK START >

    --Maintain Reservations
    --UPDATE_SO_QUANTITY would be passed by OM for update order quantity

    IF (UPPER(p_reservation_action) = 'UPDATE_SO_QUANTITY') THEN

      d_progress := 710;

      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_progress, 'p_reservation_action', p_reservation_action);
      END IF;

      PO_RESERVATION_MAINTAIN_SV.MAINTAIN_RESERVATION(
        p_header_id            => p_docid
      , p_line_id              => p_lineid
      , p_line_location_id     => p_shipid
      , p_action               => p_reservation_action
      , p_ordered_quantity     => p_qty
      , p_recreate_demand_flag => l_recreate_flag
      , p_ordered_uom          => p_ordered_uom   --5253916
      , x_return_status        => l_return_status
      );

    --Bug5060175 START
    ELSIF p_action = 'Explode_Req'  THEN

         d_progress := 720;
         IF (PO_LOG.d_stmt) THEN
           PO_LOG.stmt(d_module, d_progress, 'Calling PO Maintain Reservations for Req split');
         END IF;

         select requisition_header_id
         into l_doc_id
         from po_requisition_lines_all
         where requisition_line_id = p_lineid;

         PO_RESERVATION_MAINTAIN_SV.MAINTAIN_RESERVATION(
           p_header_id            => p_docid
         , p_line_id              => p_lineid
         , p_line_location_id     => p_shipid
         , p_action               => 'Remove_Req_Line_Supply'
         , p_recreate_demand_flag => l_recreate_flag
         , x_return_status        => l_return_status
          );


         PO_RESERVATION_MAINTAIN_SV.MAINTAIN_RESERVATION(
           p_header_id            => l_doc_id
         , p_line_id              => NULL
         , p_line_location_id     => NULL
         , p_action               => 'Approve_Req_Supply'
         , p_recreate_demand_flag => l_recreate_flag
         , x_return_status        => l_return_status
         );

   --Bug5060175 END

    ELSIF p_action NOT IN (    'Remove_PO_Supply'
                              ,'Remove_PO_Line_Supply'
                              ,'Remove_PO_Shipment_Supply'
                         ) THEN

       --Bug 5255656: Reverting the change to pass cancel reservation
       --             actions for Close actions apart from FINALLY_CLOSE
       -- Though the actions would be handled with no action by the INV Reservation API,
       -- it would better to filter out these actions at this point, to facilate better
       -- maintenance

         d_progress := 730;
         IF (PO_LOG.d_stmt) THEN
           PO_LOG.stmt(d_module, d_progress, 'Calling PO Maintain Reservations');
         END IF;

         PO_RESERVATION_MAINTAIN_SV.MAINTAIN_RESERVATION(
           p_header_id            => p_docid
         , p_line_id              => p_lineid
         , p_line_location_id     => p_shipid
         , p_action               => p_action
         , p_recreate_demand_flag => l_recreate_flag
         , x_return_status        => l_return_status
         );

    END IF;  -- IF (UPPER(p_reservation_action) = 'UPDATE_SO_QUANTITY')...

    d_progress := 800;

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_progress, 'Reservation api failed.');
      END IF;

      l_return_value := FALSE;
      RAISE PO_CORE_S.g_early_return_exc;

    END IF;

    -- End Maintain Reservations
    --< R12 PLAN CROSS DOCK END >

    l_return_value := TRUE;

  EXCEPTION
    WHEN PO_CORE_S.g_early_return_exc THEN
      NULL;
  END;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_return(d_module, l_return_value);
    PO_LOG.proc_end(d_module);
  END IF;

  return(l_return_value);


EXCEPTION

  WHEN others THEN
    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_module, d_progress, SQLCODE || SQLERRM);
    END IF;

    return(FALSE);

END po_req_supply;


/* ----------------------------------------------------------------------- */
/*                                                                         */
/*   Update mtl_supply for an Approve PO Action                            */
/*                                                                         */
/* ----------------------------------------------------------------------- */


FUNCTION approve_po_supply(p_docid IN NUMBER) RETURN BOOLEAN IS

l_auth_status  po_headers.authorization_status%TYPE;

  -- <Doc Manager Rewrite R12>: This cursor was incorrectly accessing
  -- po_requisition_headers instead of po_headers.  Verified against
  -- older Pro*C code, which was using po_headers.

/*Bug 4537860:Hit the _all tables instead of the striped views.*/
CURSOR auth_status(header_id NUMBER)
IS
  SELECT poh.authorization_status
  FROM po_headers_all poh
  WHERE poh.po_header_id = header_id;

d_module        VARCHAR2(70) := 'po.plsql.PO_SUPPLY.approve_po_supply';
d_progress      NUMBER;

l_return_value  BOOLEAN  := FALSE;

BEGIN

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module, 'p_docid', p_docid);
  END IF;

  d_progress := 10;

  OPEN auth_status(p_docid);
  FETCH auth_status INTO l_auth_status;
  CLOSE auth_status;

  d_progress := 20;

  BEGIN

    -- Create PO Supply if the PO has been Approved

    IF (l_auth_status = 'APPROVED') THEN

      d_progress := 30;

      l_return_value := create_po_supply(
                          p_entity_id   => p_docid
                        , p_entity_type => 'PO'
                        );

      IF (NOT l_return_value) THEN

        IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_module, d_progress, 'create_po_supply not successful');
        END IF;

        RAISE PO_CORE_S.g_early_return_exc;
      END IF;


      d_progress := 40;

      -- Remove Old Requisition Supply
      /*Bug 4537860:Hit the _all tables instead of the striped views.*/

      UPDATE mtl_supply ms
      SET ms.quantity = 0
        , ms.change_flag = 'Y'
      WHERE ms.supply_type_code = 'REQ'
        AND ms.supply_source_id IN
            (
              SELECT prl.requisition_line_id
              FROM po_requisition_lines_all prl
                 , po_distributions_all pd
              WHERE prl.line_location_id = pd.line_location_id
                AND pd.po_header_id = p_docid
            );

      d_progress := 50;

      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_progress, 'Updated ' || SQL%ROWCOUNT || ' rows.');
      END IF;

    END IF;  -- if (l_auth_status = 'APPROVED')...

    l_return_value := TRUE;

  EXCEPTION
    WHEN PO_CORE_S.g_early_return_exc THEN
      NULL;
  END;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_return(d_module, l_return_value);
    PO_LOG.proc_end(d_module);
  END IF;

  return (l_return_value);

EXCEPTION
  WHEN others THEN

     IF auth_status%ISOPEN THEN
       close auth_status;
     END IF;

     IF (PO_LOG.d_exc) THEN
       PO_LOG.exc(d_module, d_progress, SQLCODE || SQLERRM);
     END IF;

     return(FALSE);

END approve_po_supply;



/* ----------------------------------------------------------------------- */
/*                                                                         */
/*   Update mtl_supply for an Approve Blanket Release Action               */
/*                                                                         */
/* ----------------------------------------------------------------------- */



FUNCTION approve_blanket_supply(p_docid IN NUMBER)
RETURN BOOLEAN
IS

l_auth_status  po_headers.authorization_status%TYPE;
/*Bug 4537860:Hit the _all tables instead of the striped views.*/
CURSOR auth_status(release_id NUMBER)
IS
  SELECT por.authorization_status
  FROM po_releases_all por
  WHERE por.po_release_id = release_id;

d_module        VARCHAR2(70) := 'po.plsql.PO_SUPPLY.approve_blanket_supply';
d_progress      NUMBER;

l_return_value  BOOLEAN := FALSE;

BEGIN

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module, 'p_docid', p_docid);
  END IF;

  d_progress := 10;

  OPEN auth_status(p_docid);
  FETCH auth_status INTO l_auth_status;
  CLOSE auth_status;

  d_progress := 20;

  BEGIN

    -- Create PO Release Supply if the Release has been Approved

    IF (l_auth_status = 'APPROVED') THEN

      d_progress := 30;

      l_return_value := create_po_supply(
                          p_entity_id => p_docid
                        , p_entity_type => 'RELEASE'
                        );

      IF (NOT l_return_value) THEN

        IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_module, d_progress, 'create_po_supply not successful');
        END IF;

        RAISE PO_CORE_S.g_early_return_exc;
      END IF;


      d_progress := 40;


      -- Remove Old Requisition Supply
--Bugfix5219471: Removed POD and used '_ALL' tables for share memory issue.
      UPDATE mtl_supply ms
      SET ms.quantity = 0
        , ms.change_flag = 'Y'
      WHERE ms.supply_type_code = 'REQ'
        AND ms.supply_source_id IN
            (
              SELECT prl.requisition_line_id
              FROM po_requisition_lines_all prl
                  , po_line_locations_all pll
              WHERE prl.line_location_id = pll.line_location_id
                AND pll.po_release_id = p_docid
            );

      d_progress := 50;

      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_progress, 'Updated ' || SQL%ROWCOUNT || ' rows.');
      END IF;

    END IF;  -- if (l_auth_status = 'APPROVED')...

    l_return_value := TRUE;

  EXCEPTION
    WHEN PO_CORE_S.g_early_return_exc THEN
      NULL;
  END;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_return(d_module, l_return_value);
    PO_LOG.proc_end(d_module);
  END IF;

  return (l_return_value);

EXCEPTION
  WHEN others THEN

     IF auth_status%ISOPEN THEN
       close auth_status;
     END IF;

     IF (PO_LOG.d_exc) THEN
       PO_LOG.exc(d_module, d_progress, SQLCODE || SQLERRM);
     END IF;

     return(FALSE);

END approve_blanket_supply;


/* ----------------------------------------------------------------------- */
/*                                                                         */
/*   Update mtl_supply for an Approve Planned Release Action               */
/*                                                                         */
/* ----------------------------------------------------------------------- */

FUNCTION approve_planned_supply(p_docid IN NUMBER)
RETURN BOOLEAN
IS

l_auth_status  po_releases.authorization_status%TYPE;
l_po_header_id po_releases.po_header_id%TYPE;

l_supply_flag  BOOLEAN;
/*Bug 4537860:Hit the _all tables instead of the striped views.*/
CURSOR auth_status(release_id NUMBER)
IS
  SELECT por.authorization_status, por.po_header_id
  FROM po_releases_all por
  WHERE por.po_release_id = release_id;

d_module        VARCHAR2(70) := 'po.plsql.PO_SUPPLY.approve_planned_supply';
d_progress      NUMBER;

l_return_value  BOOLEAN := FALSE;

BEGIN

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module, 'p_docid', p_docid);
  END IF;

  d_progress := 10;

  OPEN auth_status(p_docid);
  FETCH auth_status INTO l_auth_status, l_po_header_id;
  CLOSE auth_status;

  d_progress := 20;


  BEGIN

    -- Create PO Release Supply if the Release has been Approved

    IF (l_auth_status = 'APPROVED') THEN

      d_progress := 30;

      l_return_value := create_po_supply(
                          p_entity_id => p_docid
                        , p_entity_type => 'RELEASE'
                        );

      IF (NOT l_return_value) THEN

        IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_module, d_progress, 'create_po_supply not successful');
        END IF;

        RAISE PO_CORE_S.g_early_return_exc;
      END IF;


      d_progress := 40;


      -- Remove Planned PO Supply

      -- <Doc Manager Rewrite R12>: Pro*C and existing code
      -- conflicted in how planned PO supply was removed.  The
      -- Pro*C version was used.  Calling create_supply will
      -- do the necessary subtractions.

      l_return_value := create_po_supply(
                          p_entity_id   => l_po_header_id
                        , p_entity_type => 'PO'
                        );

      IF (NOT l_return_value) THEN

        IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_module, d_progress, 'create_po_supply not successful');
        END IF;

        RAISE PO_CORE_S.g_early_return_exc;
      END IF;

    END IF;  -- if (l_auth_status = 'APPROVED')...

    d_progress := 50;

    l_return_value := TRUE;

  EXCEPTION
    WHEN PO_CORE_S.g_early_return_exc THEN
      NULL;
  END;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_return(d_module, l_return_value);
    PO_LOG.proc_end(d_module);
  END IF;

  return (l_return_value);

EXCEPTION
  WHEN others THEN

     IF auth_status%ISOPEN THEN
       close auth_status;
     END IF;

     IF (PO_LOG.d_exc) THEN
       PO_LOG.exc(d_module, d_progress, SQLCODE || SQLERRM);
     END IF;

     return(FALSE);

END approve_planned_supply;





/* ----------------------------------------------------------------------- */
/*                                                                         */
/*   Create PO Supply                                                      */
/*                                                                         */
/*   Insert new PO Supply into mtl_supply for Standard or Planned PO       */
/*   Approval, Blanket or Planned Release Approval, Standard or Planned    */
/*   PO Line Approval, Standard or Planned PO Shipment Approval, Blanket   */
/*   or Planned Release Shipment                                           */
/*                                                                         */
/*   New PO Supply is inserted based on Entity Type                        */
/*                                                                         */
/*   	Entity Type	Action                                             */
/*  	-----------	---------------------------------------------      */
/*  	PO		New PO Supply for Standard or Planned PO           */
/*  			Approval                                           */
/*                                                                         */
/*  	RELEASE		New PO Supply for Blanket or Planned Release       */
/*  			Approval                                           */
/*                                                                         */
/*      PO LINE		New PO Supply for Standard or Planned PO Line      */
/*  			Approval                                           */
/*                                                                         */
/*  	PO SHIPMENT	New PO Supply for Standard or Planned PO           */
/*  			Shipment Approval                                  */
/*                                                                         */
/*  	RELEASE         New PO Supply for Blanket or Planned Release       */
/*	SHIPMENT	Shipment                                           */
/*                                                                         */
/* ----------------------------------------------------------------------- */

-- <Doc Manager Rewrite R12>: create_po_supply had conflicting logic in PO_SUPPLY
-- vs. the Pro*C code.  The latter is more accurate, so the method has been changed
-- to reflect the logic in Pro*C wherever there is a conflict.

FUNCTION create_po_supply(
  p_entity_id   IN NUMBER
, p_entity_type IN VARCHAR2
) RETURN BOOLEAN
IS

l_distid               po_distributions.po_distribution_id%TYPE;
l_qty                  po_distributions.quantity_ordered%TYPE;
l_out_poqty            po_distributions.quantity_ordered%TYPE  := 0;
l_line_loc_id          po_distributions.line_location_id%TYPE;

l_supply_qty_in_pouom  po_distributions.quantity_ordered%TYPE  := 0;
l_uom                  po_lines.unit_meas_lookup_code%TYPE;
l_supply_qty           mtl_supply.quantity%TYPE                := 0;
l_supply_uom           mtl_supply.unit_of_measure%TYPE;
l_supply_itemid        mtl_supply.item_id%TYPE;

l_message              VARCHAR2(50);

sql_dist               VARCHAR2(800);
cur_dist               INTEGER;
num_dist               INTEGER;
b_entity_id            NUMBER;

CURSOR supply_lloc(p_line_loc_id NUMBER)
IS
  SELECT SUM(to_org_primary_quantity),
         to_org_primary_uom,
         NVL(item_id, -1)
  FROM mtl_supply
  WHERE supply_type_code IN ('RECEIVING', 'SHIPMENT')
    AND po_line_location_id = p_line_loc_id
  GROUP BY to_org_primary_uom, nvl(item_id, -1);

l_prev_line_loc_id     NUMBER := -9999;

d_module        VARCHAR2(70) := 'po.plsql.PO_SUPPLY.create_po_supply';
d_progress      NUMBER;

l_return_value  BOOLEAN := FALSE;

l_released_qty  po_distributions.quantity_ordered%TYPE;

-- <Bug 9342280 : Added for CLM project>
l_is_clm_po              VARCHAR2(5) := 'N';
l_distribution_type      VARCHAR2(100);
l_matching_basis         VARCHAR2(100);
l_accrue_on_receipt_flag VARCHAR2(100);
l_code_combination_id    NUMBER;
l_budget_account_id      NUMBER;
l_partial_funded_flag    VARCHAR2(100) := 'N';
l_unit_meas_lookup_code  VARCHAR2(100);
l_funded_value           NUMBER;
l_quantity_funded        NUMBER;
l_amount_funded          NUMBER;
l_quantity_received      NUMBER;
l_amount_received        NUMBER;
l_quantity_delivered     NUMBER;
l_amount_delivered       NUMBER;
l_quantity_billed        NUMBER;
l_amount_billed          NUMBER;
l_quantity_cancelled     NUMBER;
l_amount_cancelled       NUMBER;
l_return_status          VARCHAR2(100);
l_dist_count             NUMBER;
-- <CLM END>

BEGIN

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module, 'p_entity_id', p_entity_id);
    PO_LOG.proc_begin(d_module, 'p_entity_type', p_entity_type);
  END IF;

  d_progress := 10;

  BEGIN

    l_return_value := delete_supply(
                        p_entity_id   => p_entity_id
                      , p_entity_type => p_entity_type
                      );

    IF (NOT l_return_value) THEN

      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_progress, 'delete_supply not successful');
      END IF;

      RAISE PO_CORE_S.g_early_return_exc;

    END IF;

    d_progress := 20;

    b_entity_id := p_entity_id;


    -- Setup Dynamic SQL for Distributions
    /*Bug 4537860:Hit the _all tables instead of the striped views.*/
    sql_dist :=    'SELECT pd.po_distribution_id, '
                || 'pd.quantity_ordered - nvl(pd.quantity_delivered, 0) - nvl(pd.quantity_cancelled, 0), '
                || 'pl.unit_meas_lookup_code, '
                || 'pd.line_location_id '
                || 'FROM po_distributions_all pd, po_lines_all pl ';


    IF (p_entity_type = 'PO') THEN

      d_progress := 30;

      sql_dist :=    sql_dist
                  || 'WHERE pd.po_header_id = :b_entity_id '
                  || 'AND pd.po_line_id = pl.po_line_id '
                  || 'AND pd.po_release_id IS NULL ';    -- <Doc Manager Rewrite R12>


    ELSIF (p_entity_type = 'RELEASE') THEN

      d_progress := 40;

      sql_dist :=    sql_dist
                  || 'WHERE pd.po_release_id = :b_entity_id '
                  || 'AND pd.po_line_id = pl.po_line_id ';


    ELSIF (p_entity_type = 'PO LINE') THEN

      d_progress := 50;

      sql_dist :=    sql_dist
                  || 'WHERE pd.po_line_id =  :b_entity_id '
                  || 'AND pd.po_line_id = pl.po_line_id '
                  || 'AND pd.po_release_id IS NULL ';    -- <Doc Manager Rewrite R12>


    ELSIF (p_entity_type IN ('PO SHIPMENT', 'RELEASE SHIPMENT')) THEN

      d_progress := 60;
      sql_dist :=    sql_dist
                  || 'WHERE pd.line_location_id = :b_entity_id '
                  || 'AND pd.po_line_id = pl.po_line_id ';

      -- <Bug 9342280 : Added for CLM project>
      SELECT COUNT(po_distribution_id)
        INTO l_dist_count
        FROM po_distributions_all pd
       WHERE pd.line_location_id = b_entity_id;
      -- <END CLM>

    END IF;  -- IF p_entity_type = ...
    --Bug 9035934 Added the pd.po_distribution_id so that the consumption and recreating of supply
    --both happens in the same order.
    -- <Doc Manager Rewrite R12>: Add order-by clause as in Pro*C
    sql_dist := sql_dist || 'ORDER BY pd.line_location_id,pd.po_distribution_id';

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_progress, 'sql_dist', sql_dist);
    END IF;

    d_progress := 70;

    cur_dist := dbms_sql.open_cursor;
    dbms_sql.parse(cur_dist, sql_dist, dbms_sql.v7);
    dbms_sql.bind_variable(cur_dist, ':b_entity_id', b_entity_id);

    dbms_sql.define_column(cur_dist, 1, l_distid);
    dbms_sql.define_column(cur_dist, 2, l_qty);
    dbms_sql.define_column(cur_dist, 3, l_uom, 25);
    dbms_sql.define_column(cur_dist, 4, l_line_loc_id);

    num_dist := dbms_sql.execute(cur_dist);

    LOOP

      d_progress := 80;

      IF (dbms_sql.fetch_rows(cur_dist) > 0) THEN

        d_progress := 90;

        dbms_sql.column_value(cur_dist, 1, l_distid);
        dbms_sql.column_value(cur_dist, 2, l_qty);
        dbms_sql.column_value(cur_dist, 3, l_uom);
        dbms_sql.column_value(cur_dist, 4, l_line_loc_id);


        IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_module, d_progress, 'l_distid', l_distid);
          PO_LOG.stmt(d_module, d_progress, 'l_qty', l_qty);
          PO_LOG.stmt(d_module, d_progress, 'l_uom', l_uom);
          PO_LOG.stmt(d_module, d_progress, 'l_line_loc_id', l_line_loc_id);
        END IF;

        -- <Doc Manager Rewrite R12 Start> : From Pro*C
        -- For PO distribution, get the sum of quantity already
        -- released against that distribution.

        IF (p_entity_type IN ('PO', 'PO LINE', 'PO SHIPMENT')) THEN

          d_progress := 100;
          /*Bug 4537860:Hit the _all tables instead of the striped views.*/

          SELECT NVL(SUM(pod.quantity_ordered - NVL(pod.quantity_delivered, 0)
                           - NVL(pod.quantity_cancelled, 0)), 0)
          INTO l_released_qty
          FROM po_distributions_all pod
             , po_releases_all por
          WHERE pod.source_distribution_id = l_distid
            AND pod.po_release_id = por.po_release_id
            AND NVL(por.authorization_status, 'IN PROCESS') = 'APPROVED';

        ELSE

          d_progress := 105;
          l_released_qty := 0;

        END IF;  -- p_entity IN ...

        IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_module, d_progress, 'l_released_qty', l_released_qty);
        END IF;

        -- <Doc Manager Rewrite R12 End>


        IF (l_qty < 0) THEN
          l_out_poqty := 0;
        ELSE
          l_out_poqty := l_qty - l_released_qty;  -- <Doc Manager Rewrite R12>
        END IF;

        d_progress := 100;

        IF (l_line_loc_id <> l_prev_line_loc_id) THEN

          -- <Bug 9342280 : Added for CLM project>
          IF (p_entity_type = 'PO SHIPMENT' AND l_dist_count > 1) THEN

              l_is_clm_po           := 'N';
              l_partial_funded_flag := 'N';

              l_is_clm_po := po_clm_intg_grp.is_clm_po(p_po_header_id        => NULL,
                                                       p_po_line_id          => NULL,
                                                       p_po_line_location_id => l_line_loc_id,
                                                       p_po_distribution_id  => NULL);

              IF l_is_clm_po = 'Y' THEN
                po_clm_intg_grp.get_funding_info(p_po_header_id           => NULL,
                                                 p_po_line_id             => NULL,
                                                 p_line_location_id       => l_line_loc_id,
                                                 p_po_distribution_id     => NULL,
                                                 x_distribution_type      => l_distribution_type,
                                                 x_matching_basis         => l_matching_basis,
                                                 x_accrue_on_receipt_flag => l_accrue_on_receipt_flag,
                                                 x_code_combination_id    => l_code_combination_id,
                                                 x_budget_account_id      => l_budget_account_id,
                                                 x_partial_funded_flag    => l_partial_funded_flag,
                                                 x_unit_meas_lookup_code  => l_unit_meas_lookup_code,
                                                 x_funded_value           => l_funded_value,
                                                 x_quantity_funded        => l_quantity_funded,
                                                 x_amount_funded          => l_amount_funded,
                                                 x_quantity_received      => l_quantity_received,
                                                 x_amount_received        => l_amount_received,
                                                 x_quantity_delivered     => l_quantity_delivered,
                                                 x_amount_delivered       => l_amount_delivered,
                                                 x_quantity_billed        => l_quantity_billed,
                                                 x_amount_billed          => l_amount_billed,
                                                 x_quantity_cancelled     => l_quantity_cancelled,
                                                 x_amount_cancelled       => l_amount_cancelled,
                                                 x_return_status          => l_return_status);

            END IF;

          END IF;

          -- if it's clm po, but not partial funded, will use the original logic
          IF l_is_clm_po = 'N' OR l_partial_funded_flag = 'N' THEN

          -- <END CLM>

          l_supply_qty := 0;
          l_supply_qty_in_pouom := 0;

          d_progress := 110;

          OPEN supply_lloc(l_line_loc_id); -- Bug#4962625
          LOOP

            FETCH supply_lloc INTO l_supply_qty, l_supply_uom, l_supply_itemid;
            EXIT WHEN supply_lloc%NOTFOUND;

            IF (PO_LOG.d_stmt) THEN
              PO_LOG.stmt(d_module, d_progress, 'l_supply_qty', l_supply_qty);
              PO_LOG.stmt(d_module, d_progress, 'l_supply_uom', l_supply_uom);
              PO_LOG.stmt(d_module, d_progress, 'l_supply_itemid', l_supply_itemid);
            END IF;

            d_progress := 120;

            IF (l_supply_qty > 0) THEN

              l_supply_qty_in_pouom := l_supply_qty_in_pouom +
                                       INV_CONVERT.INV_UM_CONVERT(
                                         item_id        => l_supply_itemid
                                       , precision      => 5
                                       , from_quantity  => l_supply_qty
                                       , from_unit      => NULL
                                       , to_unit        => NULL
                                       , from_name      => l_supply_uom
                                       , to_name        => l_uom
                                       );

            END IF;  -- IF (l_supply_qty > 0)

          END LOOP;  -- supply_lloc cursor

          IF supply_lloc%ISOPEN THEN
            close supply_lloc;
          END IF;

          d_progress := 130;

          IF (PO_LOG.d_stmt) THEN
            PO_LOG.stmt(d_module, d_progress, 'l_supply_qty_in_pouom', l_supply_qty_in_pouom);
          END IF;

          END IF; -- <Bug 9342280 : Added for CLM project>

          l_prev_line_loc_id := l_line_loc_id;

        END IF;  -- IF (l_line_loc_id <> l_prev_line_loc_id)

        -- <Bug 9342280 : Added for CLM project>
        /* this is for std receipt against multi dists for CLM POs
         * the PO supply qty should be consume against specific dist_id, not in FIFO manner for line_loc_id
         */
        IF (p_entity_type = 'PO SHIPMENT' AND l_dist_count > 1) AND
           (l_is_clm_po = 'Y' AND l_partial_funded_flag = 'Y') THEN

            l_supply_qty          := 0;
            l_supply_qty_in_pouom := 0;

            BEGIN
              SELECT SUM(to_org_primary_quantity),
                     to_org_primary_uom,
                     NVL(item_id, -1)
                INTO l_supply_qty, l_supply_uom, l_supply_itemid
                FROM mtl_supply
               WHERE supply_type_code IN ('RECEIVING', 'SHIPMENT')
                 AND po_distribution_id = l_distid
               GROUP BY to_org_primary_uom, NVL(item_id, -1);
            EXCEPTION
              WHEN OTHERS THEN
                l_supply_qty := 0;
            END;

            IF l_supply_qty > 0 THEN
              l_supply_qty_in_pouom := inv_convert.inv_um_convert(item_id       => l_supply_itemid,
                                                                  precision     => 5,
                                                                  from_quantity => l_supply_qty,
                                                                  from_unit     => NULL,
                                                                  to_unit       => NULL,
                                                                  from_name     => l_supply_uom,
                                                                  to_name       => l_uom);
            END IF;
          END IF;
          -- <END CLM>

        --Bug 9035934 The l_out_poqty should be made 0 only after the l_supply_qty_in_pouom is calculated
        IF (l_out_poqty >= l_supply_qty_in_pouom) THEN
          l_out_poqty := l_out_poqty - l_supply_qty_in_pouom;
          l_supply_qty_in_pouom := 0;
        ELSE
          l_supply_qty_in_pouom := l_supply_qty_in_pouom - l_out_poqty;
          l_out_poqty := 0;
        END IF;

        IF l_out_poqty < 0 THEN
          l_out_poqty := 0;
        END IF;

        d_progress := 140;

        IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_module, d_progress, 'l_supply_qty_in_pouom', l_supply_qty_in_pouom);
          PO_LOG.stmt(d_module, d_progress, 'l_out_poqty', l_out_poqty);
        END IF;

        -- Create PO Supply
        /*Bug 4537860:Hit the _all tables instead of the striped views.*/

        INSERT INTO mtl_supply(supply_type_code,
                               supply_source_id,
                               last_updated_by,
                               last_update_date,
                               last_update_login,
                               created_by,
                               creation_date,
                               po_header_id,
                               po_line_id,
                               po_line_location_id,
                               po_distribution_id,
                               po_release_id,                -- <Doc Manager Rewrite R12>
                               item_id,
                               item_revision,
                               quantity,
                               unit_of_measure,
                               receipt_date,
                               need_by_date,
                               destination_type_code,
                               location_id,
                               to_organization_id,
                               to_subinventory,
                               change_flag)
                        SELECT 'PO',
                               pd.po_distribution_id,
                               pd.last_updated_by,
                               pd.last_update_date,
                               pd.last_update_login,
                               pd.created_by,
                               pd.creation_date,
                               pd.po_header_id,
                               pd.po_line_id,
                               pd.line_location_id,
                               pd.po_distribution_id,
                               pd.po_release_id,
                               pl.item_id,
                               pl.item_revision,
                               l_out_poqty,
                               pl.unit_meas_lookup_code,
                               nvl(pll.promised_date, pll.need_by_date),
                               nvl(pll.promised_date, pll.need_by_date), -- bug 4300150
                               pd.destination_type_code,
                               pd.deliver_to_location_id,
                               pd.destination_organization_id,
                               pd.destination_subinventory,
                               'Y'
                          FROM po_distributions_all pd,
                               po_line_locations_all pll,
                               po_lines_all pl
                         WHERE pd.po_distribution_id = l_distid
                           AND pll.line_location_id = pd.line_location_id
                           AND pl.item_id IS NOT NULL   -- <Complex Work R12>
                           AND pl.po_line_id = pd.po_line_id
                           AND nvl(pll.closed_code, 'OPEN') not in ('FINALLY CLOSED', 'CLOSED', 'CLOSED FOR RECEIVING')
                           AND nvl(pll.cancel_flag, 'N') = 'N'
                           AND nvl(pll.approved_flag, 'Y') = 'Y'
                           AND pll.quantity IS NOT NULL        -- <Doc Manager Rewrite R12>
                           AND not exists
                               (
                                 SELECT 'Supply Exists'
                                 FROM mtl_supply ms1
                                 WHERE ms1.supply_type_code = 'PO'
                                   AND ms1.supply_source_id = pd.po_distribution_id
                               );


        -- <Doc Manager Rewrite R12>: After analysis, no rows is OK, not error.
        -- This is to handle services lines.

      ELSE

        -- no rows in distributions cursor
        EXIT;

      END IF; -- IF (dbms_sql.fetch_rows(cur_dist) > 0)

    END LOOP;  -- dynamic dists cursor

    l_return_value := TRUE;

  EXCEPTION
    WHEN PO_CORE_S.g_early_return_exc THEN
      NULL;
  END;

  IF supply_lloc%ISOPEN THEN
    close supply_lloc;
  END IF;

  IF (dbms_sql.is_open(cur_dist)) THEN
    dbms_sql.close_cursor(cur_dist);
  END IF;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_return(d_module, l_return_value);
    PO_LOG.proc_end(d_module);
  END IF;

  return (l_return_value);

EXCEPTION

  WHEN others THEN

    IF supply_lloc%ISOPEN THEN
      close supply_lloc;
    END IF;

    IF (dbms_sql.is_open(cur_dist)) THEN
      dbms_sql.close_cursor(cur_dist);
    END IF;

    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_module, d_progress, SQLCODE || SQLERRM);
    END IF;

    return(FALSE);

END create_po_supply;


/* ----------------------------------------------------------------------- */
/*                                                                         */
/*   Delete Supply for PO Header or PO Release                             */
/*                                                                         */
/*   New PO Supply is inserted based on Entity Type                        */
/*                                                                         */
/*   	Entity Type		Action                                     */
/*  	-----------		-----------------------------------------  */
/*  	PO			Remove PO Supply for PO Header             */
/*                                                                         */
/*  	RELEASE			Remove PO Supply for PO Release            */
/*                                                                         */
/*  	PO LINE			Remove PO Supply for PO Line               */
/*                                                                         */
/*  	PO SHIPMENT		Remove PO Supply for PO Shipment           */
/*                                                                         */
/*  	RELEASE SHIPMENT	Remove PO Supply for Release Shipment      */
/*                                                                         */
/* ----------------------------------------------------------------------- */


FUNCTION delete_supply(
  p_entity_id   IN NUMBER
, p_entity_type IN VARCHAR2
) RETURN BOOLEAN
IS

d_module        VARCHAR2(70) := 'po.plsql.PO_SUPPLY.delete_supply';
d_progress      NUMBER;

BEGIN

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module, 'p_entity_id', p_entity_id);
    PO_LOG.proc_begin(d_module, 'p_entity_type', p_entity_type);
  END IF;

  d_progress := 10;

  IF (p_entity_type = 'PO') THEN

    DELETE FROM mtl_supply
    WHERE supply_type_code = 'PO'
      AND po_header_id = p_entity_id
      AND po_release_id IS NULL;       -- <Doc Manager Rewrite R12>: From Pro*C

  ELSIF (p_entity_type = 'RELEASE') THEN

    DELETE FROM mtl_supply
    WHERE supply_type_code = 'PO'
      AND po_release_id = p_entity_id;

  ELSIF (p_entity_type = 'PO LINE') THEN

    DELETE FROM mtl_supply
    WHERE supply_type_code = 'PO'
      AND po_line_id = p_entity_id
      AND po_release_id IS NULL;     -- <Doc Manager Rewrite R12>: From Pro*C

  ELSIF (p_entity_type in ('PO SHIPMENT', 'RELEASE SHIPMENT')) THEN

    DELETE FROM mtl_supply
    WHERE supply_type_code = 'PO'
      AND po_line_location_id = p_entity_id;

  END IF;

  d_progress := 30;

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_progress, 'Deleted ' || SQL%ROWCOUNT || ' records');
  END IF;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_return(d_module, TRUE);
    PO_LOG.proc_end(d_module);
  END IF;

  return(TRUE);

EXCEPTION

  WHEN others THEN
    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_module, d_progress, SQLCODE || SQLERRM);
    END IF;

    return(FALSE);

END delete_supply;




/* ----------------------------------------------------------------------- */
/*                                                                         */
/*   Update Supply Quantity to 0 for PO Line, PO Shipment or Release       */
/*   Shipment                                                              */
/*                                                                         */
/*   PO Supply is Updated based on the Entity Type                         */
/*                                                                         */
/*   	Entity Type	Action                                             */
/*  	-----------	---------------------------------------------      */
/*  	PO LINE		Update Supply Quantity for PO Line                 */
/*                                                                         */
/*  	PO SHIPMENT	Update Supply Quantity for PO Shipment             */
/*                                                                         */
/*  	RELEASE 	Update Supply Quantity for Release Shipment        */
/*      SHIPMENT                                                           */
/*                                                                         */
/* ----------------------------------------------------------------------- */


FUNCTION update_supply(
  p_entity_id   IN NUMBER
, p_entity_type IN VARCHAR2
, p_shipid      IN NUMBER DEFAULT 0
) RETURN BOOLEAN
IS

d_module        VARCHAR2(70) := 'po.plsql.PO_SUPPLY.update_supply';
d_progress      NUMBER;

BEGIN

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module, 'p_entity_id', p_entity_id);
    PO_LOG.proc_begin(d_module, 'p_entity_type', p_entity_type);
    PO_LOG.proc_begin(d_module, 'p_shipid', p_shipid);
  END IF;

  d_progress := 10;

  IF (p_entity_type = 'PO LINE') THEN

    UPDATE mtl_supply
    SET quantity = 0
      , change_flag = 'Y'
    WHERE supply_type_code = 'PO'
      AND po_line_id = p_entity_id
      AND po_release_id IS NULL;     -- <Doc Manager Rewrite R12>

  ELSIF (p_entity_type = 'PO SHIPMENT') THEN

    UPDATE mtl_supply
    SET quantity = 0
      , change_flag = 'Y'
    WHERE supply_type_code = 'PO'
      AND po_line_location_id = p_entity_id;

  ELSIF (p_entity_type = 'RELEASE SHIPMENT') THEN

    UPDATE mtl_supply
    SET quantity = 0
      , change_flag = 'Y'
    WHERE supply_type_code = 'PO'
      AND po_release_id = p_entity_id
      AND po_line_location_id = p_shipid;

  END IF;

  d_progress := 30;

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_progress, 'Updated ' || SQL%ROWCOUNT || ' records');
  END IF;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_return(d_module, TRUE);
    PO_LOG.proc_end(d_module);
  END IF;

  return(TRUE);

EXCEPTION

  WHEN others THEN
    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_module, d_progress, SQLCODE || SQLERRM);
    END IF;

    return(FALSE);

END update_supply;



/* ----------------------------------------------------------------------- */
/*                                                                         */
/*   Cancel Supply for PO Header, Line or Shipment                         */
/*                                                                         */
/*   PO Supply is Cancelled based on Entity Type                           */
/*                                                                         */
/*   	Entity Type		Action                                     */
/*  	-----------		---------------------------------------    */
/*  	PO			Cancel PO Supply for PO Header             */
/*                                                                         */
/*  	PO LINE			Cancel PO Supply for PO Line               */
/*                                                                         */
/*  	PO SHIPMENT		Cancel PO Supply for PO Shipment           */
/*                                                                         */
/*  	RELEASE			Cancel PO Supply for PO Release            */
/*                                                                         */
/*  	RELEASE	SHIPMENT	Cancel PO Supply for Release Shipment      */
/*                                                                         */
/* ----------------------------------------------------------------------- */

FUNCTION cancel_supply(
  p_entity_id   IN NUMBER
, p_entity_type IN VARCHAR2
, p_shipid      IN NUMBER
) RETURN BOOLEAN
IS

d_module        VARCHAR2(70) := 'po.plsql.PO_SUPPLY.cancel_supply';
d_progress      NUMBER;

l_return_value  BOOLEAN := FALSE;

BEGIN

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module, 'p_entity_id', p_entity_id);
    PO_LOG.proc_begin(d_module, 'p_entity_type', p_entity_type);
    PO_LOG.proc_begin(d_module, 'p_shipid', p_shipid);
  END IF;

  d_progress := 10;

  -- Requisition Line Supply is created in Cancel PO Routine. We just remove
  -- the existing PO Supply

  IF (p_entity_type = 'PO') THEN

    l_return_value := delete_supply(
                        p_entity_id       => p_entity_id
                      , p_entity_type     => 'PO'
                      );

  ELSIF (p_entity_type = 'PO LINE') THEN

    l_return_value := update_supply(
                        p_entity_id       => p_entity_id
                      , p_entity_type     => 'PO LINE'
                      );

  ELSIF (p_entity_type = 'PO SHIPMENT') THEN

    l_return_value := update_supply(
                        p_entity_id       => p_entity_id
                      , p_entity_type     => 'PO SHIPMENT'
                      );

  ELSIF (p_entity_type = 'RELEASE') THEN

    l_return_value := delete_supply(
                        p_entity_id       => p_entity_id
                      , p_entity_type     => 'RELEASE'
                      );

  ELSIF (p_entity_type = 'RELEASE SHIPMENT') THEN

    l_return_value := update_supply(
                        p_entity_id       => p_entity_id
                      , p_entity_type     => 'RELEASE SHIPMENT'
                      , p_shipid          => p_shipid
                      );

  END IF;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_return(d_module, l_return_value);
    PO_LOG.proc_end(d_module);
  END IF;

  return (l_return_value);

EXCEPTION

  WHEN others THEN
    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_module, d_progress, SQLCODE || SQLERRM);
    END IF;

    return(FALSE);

END cancel_supply;



/* ----------------------------------------------------------------------- */
/*                                                                         */
/*   Cancel Planned Release or Planned Shipment                            */
/*                                                                         */
/*   Update mtl_supply for Cancel Planned Release or Cancel Planned        */
/*   Release Shipment Action                                               */
/*                                                                         */
/*   Cancellation of Planned Release and Planned Shipment is based on      */
/*   Entity Type                                                           */
/*                                                                         */
/*   	Entity Type		Action                                     */
/*  	-----------		------------------------------------------ */
/*  	RELEASE			Cancel Planned Release                     */
/*                                                                         */
/*  	RELEASE	SHIPMENT	Cancel Planned Release Shipment            */
/*                                                                         */
/* ----------------------------------------------------------------------- */


FUNCTION cancel_planned(
  p_entity_id     IN NUMBER
, p_entity_type   IN VARCHAR2
, p_shipid        IN NUMBER DEFAULT 0
, p_recreate_flag IN BOOLEAN
) RETURN BOOLEAN
IS

l_supply_flag  BOOLEAN := TRUE;

l_headid       po_releases.po_header_id%TYPE;

/*Bug 4537860:Hit the _all tables instead of the striped views.*/

CURSOR rel(release_id NUMBER)
IS
  SELECT por.po_header_id
  FROM po_releases_all por
  WHERE por.po_release_id = release_id;

d_module        VARCHAR2(70) := 'po.plsql.PO_SUPPLY.cancel_planned';
d_progress      NUMBER;

l_return_value  BOOLEAN := FALSE;

BEGIN

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module, 'p_entity_id', p_entity_id);
    PO_LOG.proc_begin(d_module, 'p_entity_type', p_entity_type);
    PO_LOG.proc_begin(d_module, 'p_shipid', p_shipid);
    PO_LOG.proc_begin(d_module, 'p_recreate_flag', p_recreate_flag);
  END IF;

  d_progress := 10;

  BEGIN

    -- Remove Planned PO Supply

    IF (p_entity_type = 'RELEASE') THEN

      d_progress := 20;

      l_return_value := delete_supply(
                          p_entity_id    => p_entity_id
                        , p_entity_type  => 'RELEASE'
                        );

      IF (NOT l_return_value) THEN
        IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_module, d_progress, 'delete_supply not successful');
        END IF;

        RAISE PO_CORE_S.g_early_return_exc;
      END IF;


      IF (p_recreate_flag) THEN

        d_progress := 30;

        -- Add to existing Planned PO Supply

        l_return_value := update_planned_po(
                            p_docid        => p_entity_id
                          , p_entity_type  => 'ADD PLANNED'
                          , p_supply_flag  => l_supply_flag
                          );

        IF (NOT l_return_value) THEN
          IF (PO_LOG.d_stmt) THEN
            PO_LOG.stmt(d_module, d_progress, 'update_planned_po not successful');
          END IF;

          RAISE PO_CORE_S.g_early_return_exc;
        END IF;

        -- Insert Planned PO Supply if it does not exist

        IF (NOT l_supply_flag) THEN

          d_progress := 40;

          OPEN rel(p_entity_id);
          FETCH rel INTO l_headid;

          d_progress := 50;

          IF (rel%NOTFOUND) THEN

            IF (PO_LOG.d_stmt) THEN
              PO_LOG.stmt(d_module, d_progress, 'no rows in release cursor');
            END IF;

            l_return_value := TRUE;
            RAISE PO_CORE_S.g_early_return_exc;
          END IF;

          CLOSE rel;

          d_progress := 60;

          l_return_value := create_po_supply(
                              p_entity_id    => p_entity_id
                            , p_entity_type  => 'PO'
                            );

        END IF;  -- if (NOT l_supply_flag)

      END IF;  -- if (p_recreate_flag)

    ELSIF (p_entity_type = 'RELEASE SHIPMENT') THEN

      d_progress := 70;

      l_return_value := update_supply(
                          p_entity_id    => p_entity_id
                        , p_entity_type  => 'RELEASE SHIPMENT'
                        , p_shipid       => p_shipid
                        );

      IF (NOT l_return_value) THEN
        IF (PO_LOG.d_stmt) THEN
          PO_LOG.stmt(d_module, d_progress, 'update_supply not successful');
        END IF;

        RAISE PO_CORE_S.g_early_return_exc;
      END IF;


      IF (p_recreate_flag) THEN

        d_progress := 80;

        -- Add to existing Planned PO Supply

        l_return_value := update_planned_po(
                            p_docid        => p_entity_id
                          , p_shipid       => p_shipid
                          , p_entity_type  => 'UPDATE PLANNED'
                          , p_supply_flag  => l_supply_flag
                          );

        IF (NOT l_return_value) THEN
          IF (PO_LOG.d_stmt) THEN
            PO_LOG.stmt(d_module, d_progress, 'update_planned_po not successful');
          END IF;

          RAISE PO_CORE_S.g_early_return_exc;
        END IF;


        -- Insert Planned PO Supply if it does not exist

        IF (NOT l_supply_flag) THEN

          d_progress := 90;

          l_return_value := create_po_supply(
                              p_entity_id    => p_shipid
                            , p_entity_type  => 'PO SHIPMENT'
                            );

        END IF;  -- if (NOT l_supply_flag)

      END IF;  -- if (p_recreate_flag)

    END IF;  -- if (p_entity_type = ...)

  EXCEPTION
    WHEN PO_CORE_S.g_early_return_exc THEN
      NULL;
  END;

  IF (rel%ISOPEN) THEN
    CLOSE rel;
  END IF;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_return(d_module, l_return_value);
    PO_LOG.proc_end(d_module);
  END IF;

  return (l_return_value);

EXCEPTION
  WHEN others THEN
    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_module, d_progress, SQLCODE || SQLERRM);
    END IF;

    IF (rel%ISOPEN) THEN
      CLOSE rel;
    END IF;

    return(FALSE);

END cancel_planned;



/* ----------------------------------------------------------------------- */
/*                                                                         */
/*   			Maintain mtl_supply                                */
/*                                                                         */
/* ----------------------------------------------------------------------- */

FUNCTION maintain_mtl_supply RETURN BOOLEAN IS

l_uom        mtl_system_items.primary_unit_of_measure%TYPE;
l_lead_time  mtl_system_items.postprocessing_lead_time%TYPE;
l_pri_qty    mtl_supply.to_org_primary_quantity%TYPE;
l_Exclude_From_Planning mtl_supply.EXCLUDE_FROM_PLANNING%TYPE; --<CLM INTG - PLANNING>

-- <Doc Manager Rewrite R12>: Brought in from Pro*C to cursor sup2:
-- 1. index hint
-- 2. order by

/* Bug# 7368176
 * Added an extra FOR UPDATE clause in the below cursor to avoid the
 * deadlock scenario.
 */
 /* Bug 13081689 Added extra ORDER BY clauses in the below cursor to avoid the deadlock scenario.
 */
/*
   <CLM INTG - PLANNING>
   Adding po_header_id, req_header_id and exclude_From_Planning for clm integration with planning
 */

CURSOR sup2
IS
  SELECT /*+ index(mtl_supply MTL_SUPPLY_N10) */
         quantity
       , unit_of_measure
       , nvl(item_id, -1) item_id
       , from_organization_id
       , to_organization_id
       , receipt_date
       , po_header_id
       , req_header_id
       , exclude_From_Planning
       , rowid
  FROM mtl_supply
  WHERE change_flag = 'Y'
  ORDER BY DECODE (supply_type_code,
                     'REQ', 1,
                     'PO',  2,
                     'SHIPMENT', 3,
                     'RECEIVING', 4,
                     5), QUANTITY,
                     SUPPLY_TYPE_CODE,
                     SUPPLY_SOURCE_ID,
                     SHIPMENT_LINE_ID,
                     PO_LINE_ID,
                     PO_DISTRIBUTION_ID,
                     REQ_LINE_ID,
                     RCV_TRANSACTION_ID,
                     ITEM_ID,
                     TO_ORGANIZATION_ID
  FOR UPDATE;

CURSOR uom(from_uom VARCHAR2)
IS
  SELECT muom.unit_of_measure
       , NULL
  FROM mtl_units_of_measure muom
     , mtl_units_of_measure tuom
  WHERE tuom.unit_of_measure = from_uom
    AND tuom.uom_class = muom.uom_class
    AND muom.base_uom_flag = 'Y';

CURSOR uom_itemid(item_id NUMBER, to_org NUMBER)
IS
  SELECT primary_unit_of_measure
       , postprocessing_lead_time
  FROM mtl_system_items
  WHERE inventory_item_id = item_id
    AND organization_id = to_org;

d_module        VARCHAR2(70) := 'po.plsql.PO_SUPPLY.maintain_mtl_supply';
d_progress      NUMBER;

BEGIN

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  d_progress := 10;

  FOR c_sup2 IN sup2
  LOOP

    IF (c_sup2.quantity = 0) THEN

      d_progress := 20;

      DELETE FROM mtl_supply
      WHERE rowid = c_sup2.rowid;

      d_progress := 25;
      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_progress, 'Deleted ' || SQL%ROWCOUNT || ' rows');
      END IF;

    ELSE

      IF (c_sup2.item_id = -1) THEN

        -- one time item

        d_progress := 30;

        OPEN uom(c_sup2.unit_of_measure);
        FETCH uom INTO l_uom, l_lead_time;
        CLOSE uom;

      ELSE

        d_progress := 40;

        OPEN uom_itemid(c_sup2.item_id, c_sup2.to_organization_id);
        FETCH uom_itemid INTO l_uom, l_lead_time;
        CLOSE uom_itemid;

      END IF;  -- if (c_sup2.item_id = -1)

      d_progress := 50;

      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_progress, 'l_uom', l_uom);
        PO_LOG.stmt(d_module, d_progress, 'l_lead_time', l_lead_time);
        PO_LOG.stmt(d_module, d_progress, 'c_sup2.item_id', c_sup2.item_id);
        PO_LOG.stmt(d_module, d_progress, 'c_sup2.quantity', c_sup2.quantity);
        PO_LOG.stmt(d_module, d_progress, 'c_sup2.unit_of_measure', c_sup2.unit_of_measure);
      END IF;

      l_pri_qty := INV_CONVERT.INV_UM_CONVERT(
                     item_id       => c_sup2.item_id
                   , precision     => 5
                   , from_quantity => c_sup2.quantity
                   , from_unit     => NULL
                   , to_unit       => NULL
                   , from_name     => c_sup2.unit_of_measure
                   , to_name       => l_uom
                   );

      d_progress := 60;

      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_progress, 'l_pri_qty', l_pri_qty);
      END IF;

--<CLM INTG - PLANNING>
	DECLARE
	 l_is_clm_document VARCHAR2(1);
	BEGIN
	 l_exclude_From_Planning := c_sup2.exclude_From_Planning;
	 --#1:If its already marked as exclude From Planning Do not Change it
	 IF l_exclude_From_Planning    IS NULL
		 OR l_exclude_From_Planning <> 'Y' THEN
		 d_progress                  := 62;
		 IF (PO_LOG.d_stmt) THEN
			 PO_LOG.stmt(d_module, d_progress, 'Check: exclude From Planning');
		 END IF;
		 --#2:Should perform this Check only when CLM is installed
		 IF PO_CLM_INTG_GRP.IS_CLM_INSTALLED = 'Y' THEN
			 d_progress                 := 64;
			 IF (PO_LOG.d_stmt) THEN
				 PO_LOG.stmt(d_module, d_progress, 'CLM is installed.');
			 END IF;
			 IF c_sup2.po_header_id IS NOT NULL THEN
				 l_is_clm_document       := PO_CLM_INTG_GRP.IS_CLM_DOCUMENT(p_doc_type => 'PO',p_document_id => c_sup2.po_header_id);
			 ELSE
				 IF c_sup2.req_header_id IS NOT NULL THEN
					 l_is_clm_document        := PO_CLM_INTG_GRP.IS_CLM_DOCUMENT(p_doc_type => 'REQUISITION',p_document_id => c_sup2.req_header_id);
				 END IF;
				 --#3: When Both REQ Header Id and PO Header Id or Null, Need not modify anything
			 END IF;
			 d_progress := 66;
			 IF (PO_LOG.d_stmt) THEN
				 PO_LOG.stmt(d_module, d_progress, ' IS CLM document : '
				 ||l_is_clm_document );
			 END IF;
			 --#4: If its a CLM Document, then Exclude it From Planning, else mark it as N
			 IF l_is_clm_document    IS NOT NULL THEN
				 l_exclude_From_Planning := l_is_clm_document;
			 END IF;
		 END IF;
	 END IF;
	EXCEPTION
	WHEN OTHERS THEN
	 NULL;
	END;
 --<CLM INTG - PLANNING>
 /* Bug 9611148: For non-CLM documents, exclude_from_planning should be NULL, not N. */

      UPDATE mtl_supply
      SET to_org_primary_quantity = l_pri_qty
        , to_org_primary_uom = l_uom
        , change_flag = null
        , change_type = null
        , expected_delivery_date =
             DECODE(c_sup2.item_id, -1, to_date(NULL),
                                        c_sup2.receipt_date + NVL(l_lead_time, 0))
        , exclude_From_Planning = DECODE(l_exclude_From_Planning,'Y','Y','N',NULL,NULL)        --<CLM INTG - PLANNING>
      WHERE rowid = c_sup2.rowid;

      d_progress := 70;
      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_progress, 'Updated ' || SQL%ROWCOUNT || ' rows');
      END IF;

    END IF;  -- if (c_sup2.quantity = 0)

  END LOOP;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_return(d_module, TRUE);
    PO_LOG.proc_end(d_module);
  END IF;

  return(TRUE);

EXCEPTION

  WHEN others THEN

    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_module, d_progress, SQLCODE || SQLERRM);
    END IF;

    IF uom%ISOPEN THEN
      close uom;
    END IF;

    IF uom_itemid%ISOPEN THEN
      close uom_itemid;
    END IF;

    return(FALSE);

END maintain_mtl_supply;


/* ----------------------------------------------------------------------- */

  -- Approve Requisition

  -- Create Requisition Supply for an Approve Requisition Action

/* ----------------------------------------------------------------------- */

FUNCTION approve_req(p_docid IN NUMBER) RETURN BOOLEAN
IS

/*Bug 4537860:Hit the _all tables instead of the striped views.*/

CURSOR auth_status(header_id NUMBER)
IS
  SELECT authorization_status
  FROM po_requisition_headers_all
  WHERE requisition_header_id = header_id;

l_auth_status  po_requisition_headers.authorization_status%TYPE;

d_module        VARCHAR2(70) := 'po.plsql.PO_SUPPLY.approve_req';
d_progress      NUMBER;

l_return_value  BOOLEAN := FALSE;

BEGIN

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module, 'p_docid', p_docid);
  END IF;

  d_progress := 10;

  OPEN auth_status(p_docid);
  FETCH auth_status INTO l_auth_status;
  CLOSE auth_status;

  -- Create Requisition Supply if the Requisition has been Approved

  IF (l_auth_status = 'APPROVED') THEN

    l_return_value := create_req(
                        p_entity_id => p_docid
                      , p_entity_type => 'REQ HDR'
                      );
  ELSE

    l_return_value := TRUE;

  END IF;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_return(d_module, l_return_value);
    PO_LOG.proc_end(d_module);
  END IF;

  return(l_return_value);

EXCEPTION

  WHEN others THEN

    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_module, d_progress, SQLCODE || SQLERRM);
    END IF;

    IF (auth_status%ISOPEN) THEN
      close auth_status;
    END IF;

    return(FALSE);

END approve_req;

/* ----------------------------------------------------------------------- */

  -- Clear Requisition Header, Requisition Lines
/* ----------------------------------------------------------------------- */


FUNCTION remove_req(
           p_entity_id   IN NUMBER
         , p_entity_type IN VARCHAR2
) RETURN BOOLEAN
IS

d_module        VARCHAR2(70) := 'po.plsql.PO_SUPPLY.remove_req';
d_progress      NUMBER;

BEGIN

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module, 'p_entity_id', p_entity_id);
    PO_LOG.proc_begin(d_module, 'p_entity_type', p_entity_type);
  END IF;

  d_progress := 10;

  IF (p_entity_type = 'REQ HDR') THEN

    d_progress := 20;

    UPDATE mtl_supply
    SET quantity = 0
      , change_flag = 'Y'
    WHERE supply_type_code = 'REQ'
      AND req_header_id = p_entity_id;

  ELSIF (p_entity_type = 'REQ LINE') THEN

    d_progress := 30;

    UPDATE mtl_supply
    SET quantity = 0
      , change_flag = 'Y'
    WHERE supply_type_code = 'REQ'
      AND req_line_id = p_entity_id;

  END IF;  -- if (p_entity_type = ...)

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_progress, 'Updated ' || SQL%ROWCOUNT || ' rows');
  END IF;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_return(d_module, TRUE);
    PO_LOG.proc_end(d_module);
  END IF;

  return(TRUE);


EXCEPTION

WHEN others THEN
  IF (PO_LOG.d_exc) THEN
     PO_LOG.exc(d_module, d_progress, SQLCODE || SQLERRM);
  END IF;

  return(FALSE);

END remove_req;

/* ----------------------------------------------------------------------- */

  -- Clear Requisition Vendor Sourced Lines

/* ----------------------------------------------------------------------- */


FUNCTION remove_req_vend_lines(p_docid IN NUMBER) RETURN BOOLEAN IS

d_module        VARCHAR2(70) := 'po.plsql.PO_SUPPLY.remove_req_vend_lines';
d_progress      NUMBER;

BEGIN

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module, 'p_docid', p_docid);
  END IF;

  d_progress := 10;

  /*Bug 4537860:Hit the _all tables instead of the striped views.*/

  UPDATE mtl_supply ms
  SET ms.quantity = 0
    , ms.change_flag = 'Y'
  WHERE ms.supply_type_code = 'REQ'
    AND ms.req_header_id = p_docid
    AND EXISTS
         (
           SELECT 1
           FROM po_requisition_lines_all porl
           WHERE porl.source_type_code = 'VENDOR'
             AND porl.requisition_line_id = ms.req_line_id
             AND porl.line_location_id is null--Bug 13518969
         );

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_progress, 'Updated ' || SQL%ROWCOUNT || ' rows');
  END IF;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_return(d_module, TRUE);
    PO_LOG.proc_end(d_module);
  END IF;

  return(TRUE);

EXCEPTION

WHEN others THEN
  IF (PO_LOG.d_exc) THEN
     PO_LOG.exc(d_module, d_progress, SQLCODE || SQLERRM);
  END IF;

  return(FALSE);

END remove_req_vend_lines;


/* ----------------------------------------------------------------------- */

  -- Create Requisition Header, Line Supply

/* ----------------------------------------------------------------------- */



FUNCTION create_req(
  p_entity_id   IN NUMBER
, p_entity_type IN VARCHAR2
) RETURN BOOLEAN
IS

d_module        VARCHAR2(70) := 'po.plsql.PO_SUPPLY.create_req';
d_progress      NUMBER;

l_return_value  BOOLEAN := FALSE;

BEGIN

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module, 'p_entity_id', p_entity_id);
    PO_LOG.proc_begin(d_module, 'p_entity_type', p_entity_type);
  END IF;

  d_progress := 10;


  IF (p_entity_type = 'REQ HDR') THEN

    d_progress := 20;

    -- <Doc Manager Rewrite R12 Start>: From Pro*C

    /*Bug 4537860:Hit the _all tables instead of the striped views.*/

    DELETE FROM mtl_supply ms1
    WHERE ms1.supply_source_id IN
           (
             SELECT pl.requisition_line_id
             FROM po_requisition_lines_all pl
             WHERE pl.requisition_header_id = p_entity_id
               AND NVL(pl.modified_by_agent_flag, 'N') <> 'Y'
               AND NVL(pl.closed_code, 'OPEN') = 'OPEN'
               AND NVL(pl.cancel_flag, 'N') = 'N'
               AND pl.line_location_id IS NULL
           )
      AND ms1.supply_type_code = 'REQ';

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_progress, 'Deleted ' || SQL%ROWCOUNT || ' rows');
    END IF;

    -- <Doc Manager Rewrite R12 End>

    d_progress := 30;

    /*Bug 4537860:Hit the _all tables instead of the striped views.*/

    INSERT INTO mtl_supply
               (supply_type_code,
                supply_source_id,
                last_updated_by,
                last_update_date,
                last_update_login,
                created_by,
                creation_date,
                req_header_id,
                req_line_id,
                item_id,
                item_revision,
                quantity,
                unit_of_measure,
                receipt_date,
                need_by_date,
                destination_type_code,
                location_id,
                from_organization_id,
                from_subinventory,
                to_organization_id,
                to_subinventory,
                change_flag)
               SELECT 'REQ',
                       prl.requisition_line_id,
                       last_updated_by,
                       last_update_date,
                       last_update_login,
                       created_by,
                       creation_date,
                       prl.requisition_header_id,
                       prl.requisition_line_id,
                       prl.item_id,
                       decode(prl.source_type_code,'INVENTORY', null,
                              prl.item_revision),
                       prl.quantity - ( nvl(prl.QUANTITY_CANCELLED, 0) +
                                        nvl(prl.QUANTITY_DELIVERED, 0) ),
                       prl.unit_meas_lookup_code,
                       prl.need_by_date,
                       prl.need_by_date,
                       prl.destination_type_code,
                       prl.deliver_to_location_id,
                       prl.source_organization_id,
                       prl.source_subinventory,
                       prl.destination_organization_id,
                       prl.destination_subinventory,
                       'Y'
                FROM   po_requisition_lines_all prl
                WHERE  prl.requisition_header_id = p_entity_id
                AND    nvl(prl.modified_by_agent_flag,'N') <> 'Y'
                AND    nvl(prl.CLOSED_CODE,'OPEN') = 'OPEN'
                AND    nvl(prl.CANCEL_FLAG, 'N') = 'N'
                -- <Doc Manager Rewrite R12>: Filter out amount basis
                AND    prl.matching_basis <> 'AMOUNT'
                AND    prl.line_location_id is null
                AND    not exists
                       (SELECT 'supply exists'
                        FROM   mtl_supply ms
			                  WHERE  ms.supply_type_code = 'REQ'
			                  AND ms.supply_source_id = prl.requisition_line_id);

  ELSIF (p_entity_type = 'REQ LINE') THEN

    d_progress := 40;

    INSERT INTO mtl_supply
               (supply_type_code,
                supply_source_id,
                last_updated_by,
                last_update_date,
                last_update_login,
                created_by,
                creation_date,
                req_header_id,
                req_line_id,
                item_id,
                item_revision,
                quantity,
                unit_of_measure,
                receipt_date,
                need_by_date,
                destination_type_code,
                location_id,
                from_organization_id,
                from_subinventory,
                to_organization_id,
                to_subinventory,
                change_flag)
                SELECT 'REQ',
                       prl.requisition_line_id,
                       last_updated_by,
                       last_update_date,
                       last_update_login,
                       created_by,
                       creation_date,
                       prl.requisition_header_id,
                       prl.requisition_line_id,
                       prl.item_id,
                       decode(prl.source_type_code,'INVENTORY', null,
                              prl.item_revision),
                       prl.quantity - ( nvl(prl.QUANTITY_CANCELLED, 0) +
                                        nvl(prl.QUANTITY_DELIVERED, 0) ),
                       prl.unit_meas_lookup_code,
                       prl.need_by_date,
                       prl.need_by_date,
                       prl.destination_type_code,
                       prl.deliver_to_location_id,
                       prl.source_organization_id,
                       prl.source_subinventory,
                       prl.destination_organization_id,
                       prl.destination_subinventory,
                       'Y'
                FROM   po_requisition_lines_all prl
                WHERE  prl.requisition_line_id = p_entity_id
                AND    nvl(prl.modified_by_agent_flag,'N') <> 'Y'
                AND    nvl(prl.CLOSED_CODE, 'OPEN') = 'OPEN'
                AND    nvl(prl.CANCEL_FLAG, 'N') = 'N'
                AND    prl.line_location_id IS NULL
                -- <Doc Manager Rewrite R12 Start>: Add filters from Pro*C
                AND    prl.matching_basis <> 'AMOUNT'
                AND    NOT EXISTS
                          (
                            SELECT 'supply exists'
                            FROM mtl_supply
               			        WHERE supply_type_code = 'REQ'
   			                      AND supply_source_id = prl.requisition_line_id
                          );
                -- <Doc Manager Rewrite R12 End>

  END IF;  -- if p_entity_type = ...

  d_progress := 100;

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_progress, 'Inserted ' || SQL%ROWCOUNT || ' rows');
  END IF;

  -- <Doc Manager Rewrite R12>: After analysis, no rows is OK, not error.
  -- This is to handle services lines.

  l_return_value := TRUE;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_return(d_module, l_return_value);
    PO_LOG.proc_end(d_module);
  END IF;

  return(l_return_value);

EXCEPTION

WHEN others THEN

  IF (PO_LOG.d_exc) THEN
     PO_LOG.exc(d_module, d_progress, SQLCODE || SQLERRM);
  END IF;

  return(FALSE);

END create_req;


/* ----------------------------------------------------------------------- */

  -- Maintain mtl_supply for Explode or Multisource Action

/* ----------------------------------------------------------------------- */

FUNCTION explode(p_lineid IN NUMBER) RETURN BOOLEAN IS

d_module        VARCHAR2(70) := 'po.plsql.PO_SUPPLY.explode';
d_progress      NUMBER;

l_return_value  BOOLEAN := FALSE;

BEGIN

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module, 'p_lineid', p_lineid);
  END IF;

  d_progress := 10;

  BEGIN

    -- Set the Supply Quantity of Parent to 0

    l_return_value := remove_req(
                        p_entity_id   => p_lineid
                      , p_entity_type => 'REQ LINE'
                      );

    IF (NOT l_return_value) THEN
      IF (PO_LOG.d_stmt) THEN
        PO_LOG.stmt(d_module, d_progress, 'remove_req not successful');
      END IF;

      RAISE PO_CORE_S.g_early_return_exc;
    END IF;

    d_progress := 20;

    -- Insert New Supply for each new Line created by the Explode or
    -- Multisource Action

    /*Bug 4537860:Hit the _all tables instead of the striped views.*/

    insert into mtl_supply(supply_type_code,
                           supply_source_id,
                           last_updated_by,
                           last_update_date,
                           last_update_login,
                           created_by,
                           creation_date,
                           req_header_id,
                           req_line_id,
                           item_id,
                           item_revision,
                           quantity,
                           unit_of_measure,
                           receipt_date,
                           need_by_date,
                           destination_type_code,
                           location_id,
                           from_organization_id,
                           from_subinventory,
                           to_organization_id,
                           to_subinventory,
                           change_flag)
                    select 'REQ',
                           prl.requisition_line_id,
                           prl.last_updated_by,
                           prl.last_update_date,
                           prl.last_update_login,
                           prl.created_by,
                           prl.creation_date,
                           prl.requisition_header_id,
                           prl.requisition_line_id,
                           prl.item_id,
                           prl.item_revision,
                           prl.quantity - (nvl(prl.quantity_cancelled, 0) +
                                           nvl(prl.quantity_delivered, 0)),
                           prl.unit_meas_lookup_code,
                           prl.need_by_date,
                           prl.need_by_date,
                           prl.destination_type_code,
                           prl.deliver_to_location_id,
                           prl.source_organization_id,
                           prl.source_subinventory,
                           prl.destination_organization_id,
                           prl.destination_subinventory,
                           'Y'
                      from po_requisition_lines_all prl
                     where prl.requisition_line_id in
                          (select prl1.requisition_line_id
                             from po_requisition_lines_all prl1
                            where prl1.requisition_header_id =
                                 (select prl2.requisition_header_id
                                    from po_requisition_lines_all prl2
                                   where prl2.requisition_line_id = p_lineid
                                     and prl2.modified_by_agent_flag = 'Y'))
                       and nvl(prl.modified_by_agent_flag, 'N') <> 'Y'
                       and nvl(prl.closed_code, 'OPEN') = 'OPEN'
                       and nvl(prl.cancel_flag, 'N') = 'N'
                       and prl.line_location_id is null
                       and not exists
                          (select 'Supply Exists'
                             from mtl_supply
                            where supply_type_code = 'REQ'
                              and supply_source_id = prl.requisition_line_id);


    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_progress, 'Exploded ' || SQL%ROWCOUNT || ' rows');
    END IF;

    l_return_value := TRUE;

  EXCEPTION
    WHEN PO_CORE_S.g_early_return_exc THEN
      NULL;
  END;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_return(d_module, l_return_value);
    PO_LOG.proc_end(d_module);
  END IF;

  return(l_return_value);

EXCEPTION

WHEN others THEN

  IF (PO_LOG.d_exc) THEN
     PO_LOG.exc(d_module, d_progress, SQLCODE || SQLERRM);
  END IF;

  return(FALSE);

END explode;

/* ----------------------------------------------------------------------- */

  -- Updates Requisition Quantity in mtl_supply

/* ----------------------------------------------------------------------- */


FUNCTION update_req_line_qty(
  p_lineid IN NUMBER
, p_qty    IN NUMBER
) RETURN BOOLEAN
IS

d_module        VARCHAR2(70) := 'po.plsql.PO_SUPPLY.update_req_line_qty';
d_progress      NUMBER;

BEGIN

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module, 'p_lineid', p_lineid);
    PO_LOG.proc_begin(d_module, 'p_qty', p_qty);
  END IF;

  d_progress := 10;

  UPDATE mtl_supply
  SET quantity = p_qty
    , change_flag = 'Y'
  WHERE supply_type_code = 'REQ'
    AND req_line_id = p_lineid;

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_progress, 'Updated ' || SQL%ROWCOUNT || ' rows');
  END IF;


  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_return(d_module, TRUE);
    PO_LOG.proc_end(d_module);
  END IF;

  return(TRUE);

EXCEPTION

WHEN others THEN

  IF (PO_LOG.d_exc) THEN
     PO_LOG.exc(d_module, d_progress, SQLCODE || SQLERRM);
  END IF;

  return(FALSE);

END update_req_line_qty;

/* ----------------------------------------------------------------------- */

  -- Updates Receipt Date in mtl_supply

/* ----------------------------------------------------------------------- */

FUNCTION update_req_line_date(
  p_lineid IN NUMBER
, p_receipt_date IN DATE
) RETURN BOOLEAN
IS

d_module        VARCHAR2(70) := 'po.plsql.PO_SUPPLY.update_req_line_date';
d_progress      NUMBER;

BEGIN

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module, 'p_lineid', p_lineid);
    PO_LOG.proc_begin(d_module, 'p_receipt_date', p_receipt_date);
  END IF;

  d_progress := 10;

  UPDATE mtl_supply
  SET receipt_date = p_receipt_date
    , need_by_date = p_receipt_date  -- Bug 3443313
    , change_flag = 'Y'
  WHERE supply_type_code = 'REQ'
    AND req_line_id = p_lineid;

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_progress, 'Updated ' || SQL%ROWCOUNT || ' rows');
  END IF;


  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_return(d_module, TRUE);
    PO_LOG.proc_end(d_module);
  END IF;

  return(TRUE);

EXCEPTION

WHEN others THEN

  IF (PO_LOG.d_exc) THEN
     PO_LOG.exc(d_module, d_progress, SQLCODE || SQLERRM);
  END IF;

  return(FALSE);

END update_req_line_date;



/* ----------------------------------------------------------------------- */

  -- Update Planned PO, Planned PO Shipment Supply

  -- Update of Planned PO is based on Entity Type
  --
  -- 	Entity Type		Action
  --	-----------		------------------------------------------
  --  <Doc Manager Rewrite R12>: REMOVE PLANNED is not used anywhere; removed
  --
  --	UPDATE PLANNED		Update Quantity in mtl_supply
  --
  --	ADD PLANNED		Update Quantity in mtl_supply
  --

/* ----------------------------------------------------------------------- */

FUNCTION update_planned_po(
  p_docid       IN     NUMBER
, p_shipid      IN     NUMBER DEFAULT 0
, p_entity_type IN     VARCHAR2
, p_supply_flag IN OUT NOCOPY BOOLEAN
) RETURN BOOLEAN
IS

d_module        VARCHAR2(70) := 'po.plsql.PO_SUPPLY.update_planned_po';
d_progress      NUMBER;

l_ppo_dist_id_tbl    po_tbl_number;
l_ppo_dist_qty_tbl   po_tbl_number;


BEGIN

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module, 'p_docid', p_docid);
    PO_LOG.proc_begin(d_module, 'p_shipid', p_shipid);
    PO_LOG.proc_begin(d_module, 'p_entity_type', p_entity_type);
    PO_LOG.proc_begin(d_module, 'p_supply_flag', p_supply_flag);
  END IF;

  d_progress := 10;

  IF (p_entity_type = 'UPDATE PLANNED') THEN

    d_progress := 20;

    -- <Doc Manager Rewrite R12>: Use logic from Pro*C
    /*Bug 4537860:Hit the _all tables instead of the striped views.*/

    UPDATE mtl_supply ms
    SET ms.quantity =
         (
           SELECT ms.quantity +
				                      NVL( sum(nvl(pd.quantity_cancelled,0)),0)
			     FROM po_distributions_all pd
			     WHERE pd.po_release_id = p_docid
			       AND pd.line_location_id = p_shipid
			       AND pd.source_distribution_id = ms.supply_source_id
         )
      , ms.change_flag = 'Y'
    WHERE ms.supply_type_code = 'PO'
      AND ms.po_line_location_id =
           (
             SELECT poll. source_shipment_id
				     FROM po_line_locations_all poll
				     WHERE poll.line_location_id = p_shipid
           );

    IF (SQL%NOTFOUND) THEN
      p_supply_flag := FALSE;
    ELSE
      p_supply_flag := TRUE;
    END IF;

  ELSIF (p_entity_type = 'ADD PLANNED') THEN

    -- <Doc Manager Rewrite R12>: Use logic from Pro*C and
    -- use bulk processing to avoid unnecessary nested cursors

    /*Bug 4537860:Hit the _all tables instead of the striped views.*/

    d_progress := 30;

    SELECT pod.source_distribution_id, pod.quantity_ordered
    BULK COLLECT INTO l_ppo_dist_id_tbl, l_ppo_dist_qty_tbl
    FROM po_distributions_all pod
    WHERE pod.po_release_id = p_docid
      AND (pod.po_line_id IS NOT NULL AND pod.line_location_id IS NOT NULL);

    d_progress := 40;

    FORALL i IN 1..l_ppo_dist_id_tbl.COUNT
      UPDATE mtl_supply mts
      SET mts.quantity = l_ppo_dist_qty_tbl(i) -
                         (
                          SELECT NVL(sum(pod.quantity_ordered -
                                       NVL(pod.quantity_cancelled, 0)), 0)
                          FROM po_distributions_all pod
                          WHERE pod.source_distribution_id = l_ppo_dist_id_tbl(i)
                            AND pod.po_line_id IS NOT NULL
                            AND pod.line_location_id IS NOT NULL
                         )
        , mts.change_flag = 'Y'
      WHERE mts.po_distribution_id = l_ppo_dist_id_tbl(i);

    d_progress := 50;

    IF ((l_ppo_dist_id_tbl.COUNT = 0) OR (SQL%NOTFOUND)) THEN
      p_supply_flag := FALSE;
    ELSE
      p_supply_flag := TRUE;
    END IF;

  END IF;

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_progress, 'Updated ' || SQL%ROWCOUNT || ' rows');
  END IF;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_return(d_module, TRUE);
    PO_LOG.proc_end(d_module, 'p_supply_flag', p_supply_flag);
    PO_LOG.proc_end(d_module);
  END IF;

  return(TRUE);

EXCEPTION

WHEN others THEN

  IF (PO_LOG.d_exc) THEN
     PO_LOG.exc(d_module, d_progress, SQLCODE || SQLERRM);
  END IF;

  return(FALSE);

END update_planned_po;


/* ----------------------------------------------------------------------- */
-- Obsolete debug method
/* ----------------------------------------------------------------------- */
FUNCTION get_debug RETURN VARCHAR2 IS
BEGIN
  return NULL;
END get_debug;



END PO_SUPPLY;


/
