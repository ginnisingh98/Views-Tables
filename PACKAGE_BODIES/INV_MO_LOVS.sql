--------------------------------------------------------
--  DDL for Package Body INV_MO_LOVS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_MO_LOVS" AS
  /* $Header: INVMOLB.pls 120.5 2007/01/09 10:15:08 hjogleka noship $ */

  --
  --      Name: GET_MO_LOV_ALL
  --
  --      Input parameters:
  --       p_Organization_Id   which restricts LOV SQL to current org
  --       p_mo_req_number   which restricts LOV SQL to the user input text
  --       p_molov_type      Type of LOV being requested
  --
  --      Output parameters:
  --       x_mo_num_lov      returns LOV rows as reference cursor
  --
  --      Functions: This API returns MO number for a given org
  --                which are in status APPROVED, PREAPPROVED, PART_APPROVED

  /******************************************************************
     The SELECT statement has been modified to get the line_id also
     as part of tbe bug - 2169451

     The select will return the LineNumber and LineId if there is only
     one line for the MoveOrder. Otherwise it returns NULL.
  ******************************************************************/
  PROCEDURE get_mo_lov_all(x_mo_num_lov OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_mo_req_number IN VARCHAR2) IS
  BEGIN
    OPEN x_mo_num_lov FOR
      SELECT   MAX(h.request_number)
             , MAX(h.description)
             , h.header_id
             , MAX(h.move_order_type)
             , DECODE(COUNT(l.line_number), 1, MAX(l.line_number), NULL)
             , DECODE(COUNT(l.line_id), 1, MAX(l.line_id), NULL)
          FROM mtl_txn_request_headers h, mtl_txn_request_lines l
         WHERE h.organization_id = p_organization_id
           AND h.request_number LIKE(p_mo_req_number)
           AND h.header_status IN(3, 7, 8)
           AND l.organization_id = h.organization_id
           AND l.line_status IN(3, 7, 8)
           AND NVL(l.quantity_delivered, 0) < l.quantity
           AND l.header_id = h.header_id
           AND EXISTS(
                SELECT NULL
                  FROM mtl_system_items msi
                 WHERE msi.inventory_item_id = l.inventory_item_id
                   AND msi.organization_id = l.organization_id
                   AND msi.mtl_transactions_enabled_flag = 'Y'
                   AND msi.inventory_item_flag = 'Y'
                   AND msi.bom_item_type = 4)
      GROUP BY h.header_id;
  END get_mo_lov_all;

  --
  --      Name: GET_MO_LOV
  --
  --      Input parameters:
  --       p_Organization_Id   which restricts LOV SQL to current org
  --       p_mo_req_number   which restricts LOV SQL to the user input text
  --       p_molov_type      Type of LOV being requested
  --
  --      Output parameters:
  --       x_mo_num_lov      returns LOV rows as reference cursor
  --
  --      Functions: This API returns MoveOrders for a given org
  --              which are in status APPROVED, PREAPPROVED, PART_APPROVED
  --              for the specified MO_Type and Trx_Type
  --

  /*****************************************************************
     The SELECT statement has been modified to get the line_id also
     as part of tbe bug - 2169451

     The select will return the LineNumber and LineId if there is only
     one line for the MoveOrder. Otherwise it returns NULL.
  *****************************************************************/
  PROCEDURE get_mo_lov(
    x_mo_num_lov      OUT NOCOPY    t_genref
  , p_organization_id IN            NUMBER
  , p_mo_type         IN            NUMBER
  , p_trx_type        IN            NUMBER
  , p_mo_req_number   IN            VARCHAR2
  ) IS
  /*Bug Number:3066941*/
  BEGIN
   IF(p_trx_type =63 )THEN
    OPEN x_mo_num_lov FOR
      SELECT   MAX(h.request_number)
             , MAX(h.description)
             , h.header_id
             , MAX(h.move_order_type)
             , DECODE(COUNT(l.line_number), 1, MAX(l.line_number), NULL)
             , DECODE(COUNT(l.line_id), 1, MAX(l.line_id), NULL)
         FROM mtl_txn_request_headers h, mtl_txn_request_lines l, mtl_transaction_types t
         WHERE l.header_id = h.header_id
           AND l.transaction_type_id = t.transaction_type_id
           AND h.organization_id = p_organization_id
           AND h.header_status IN(3, 7, 8)
           AND h.move_order_type = p_mo_type
           AND t.transaction_action_id=1
	   AND l.transaction_source_type_id=4
	   AND NVL(l.quantity_delivered, 0) < l.quantity
           AND h.request_number LIKE(p_mo_req_number)
      GROUP BY h.header_id;
    ELSIF(p_trx_type =64 )THEN
      OPEN x_mo_num_lov FOR
      SELECT   MAX(h.request_number)
             , MAX(h.description)
             , h.header_id
             , MAX(h.move_order_type)
             , DECODE(COUNT(l.line_number), 1, MAX(l.line_number), NULL)
             , DECODE(COUNT(l.line_id), 1, MAX(l.line_id), NULL)
         FROM mtl_txn_request_headers h, mtl_txn_request_lines l, mtl_transaction_types t
         WHERE l.header_id = h.header_id
           AND l.transaction_type_id = t.transaction_type_id
           AND h.organization_id = p_organization_id
           AND h.header_status IN(3, 7, 8)
           AND h.move_order_type = p_mo_type
           AND t.transaction_action_id=2
	   AND l.transaction_source_type_id=4
	   AND NVL(l.quantity_delivered, 0) < l.quantity
           AND h.request_number LIKE(p_mo_req_number)
      GROUP BY h.header_id;
    ELSE
      OPEN x_mo_num_lov FOR
      SELECT   MAX(h.request_number)
             , MAX(h.description)
             , h.header_id
             , MAX(h.move_order_type)
             , DECODE(COUNT(l.line_number), 1, MAX(l.line_number), NULL)
             , DECODE(COUNT(l.line_id), 1, MAX(l.line_id), NULL)
          FROM mtl_txn_request_headers h, mtl_txn_request_lines l
         WHERE l.header_id = h.header_id
           AND h.organization_id = p_organization_id
           AND h.header_status IN(3, 7, 8)
           AND h.move_order_type = p_mo_type
           AND l.transaction_type_id = NVL(p_trx_type, l.transaction_type_id)
           AND NVL(l.quantity_delivered, 0) < l.quantity
           AND h.request_number LIKE(p_mo_req_number)
      GROUP BY h.header_id;
   END IF;
  END get_mo_lov;

  /*****************************************************************
     The SELECT statement has been modified to get the line_id also
     as part of tbe bug - 2169451

     The select will return the LineNumber and LineId if there is only
     one line for the MoveOrder. Otherwise it returns NULL.
  *****************************************************************/
  --Bug #3796571, filtering MO LOV on Sales Order Number
  PROCEDURE get_pickwavemo_lov(x_pwmo_lov OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_mo_req_number IN VARCHAR2, p_so_number IN VARCHAR2 := NULL) IS
  BEGIN
    --bug #3796571, forking the code for better performance when Sales Order number is not passed.
    IF (p_so_number IS NULL) THEN
      OPEN x_pwmo_lov FOR
        SELECT   MAX(h.request_number)
               , MAX(h.description)
               , h.header_id
               , MAX(h.move_order_type)
               , DECODE(COUNT(l.line_number), 1, MAX(l.line_number), NULL)
               , DECODE(COUNT(l.line_id), 1, MAX(l.line_id), NULL)
            FROM mtl_txn_request_headers h, mtl_txn_request_lines l
           WHERE h.organization_id = p_organization_id
             AND h.request_number LIKE (p_mo_req_number)
             AND h.header_status IN(3, 7, 8)
             AND move_order_type = 3
             AND l.organization_id = h.organization_id
             AND l.line_status IN(3, 7, 8)
             AND NVL(l.quantity_delivered, 0) < l.quantity
             AND l.header_id = h.header_id
             AND EXISTS(
                  SELECT NULL
                    FROM mtl_system_items msi
                   WHERE msi.inventory_item_id = l.inventory_item_id
                     AND msi.organization_id = l.organization_id
                     AND msi.mtl_transactions_enabled_flag = 'Y'
                     AND msi.inventory_item_flag = 'Y'
                     AND msi.bom_item_type = 4)
        GROUP BY h.header_id;
    ELSE
      OPEN x_pwmo_lov FOR
        SELECT   MAX(h.request_number)
               , MAX(h.description)
               , h.header_id
               , MAX(h.move_order_type)
               , DECODE(COUNT(l.line_number), 1, MAX(l.line_number), NULL)
               , DECODE(COUNT(l.line_id), 1, MAX(l.line_id), NULL)
            FROM mtl_txn_request_headers h, mtl_txn_request_lines l
               , mtl_sales_orders mso
           WHERE mso.sales_order_id = l.txn_source_id
             AND (p_so_number IS NULL OR mso.segment1 = p_so_number)
             AND h.organization_id = p_organization_id
             AND h.request_number LIKE (p_mo_req_number)
             AND h.header_status IN(3, 7, 8)
             AND move_order_type = 3
             AND l.organization_id = h.organization_id
             AND l.line_status IN(3, 7, 8)
             AND NVL(l.quantity_delivered, 0) < l.quantity
             AND l.header_id = h.header_id
             AND EXISTS(
                  SELECT NULL
                    FROM mtl_system_items msi
                   WHERE msi.inventory_item_id = l.inventory_item_id
                     AND msi.organization_id = l.organization_id
                     AND msi.mtl_transactions_enabled_flag = 'Y'
                     AND msi.inventory_item_flag = 'Y'
                     AND msi.bom_item_type = 4)
        GROUP BY h.header_id;
    END IF; --IF (p_so_number IS NULL)
  END get_pickwavemo_lov;

  /*****************************************************************
     The SELECT statement has been modified to get the line_id also
     as part of tbe bug - 2169451

     The select will return the LineNumber and LineId if there is only
     one line for the MoveOrder. Otherwise it returns NULL.
  *****************************************************************/
  PROCEDURE get_wipmo_lov(x_pwmo_lov OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_mo_req_number IN VARCHAR2) IS
  BEGIN
    OPEN x_pwmo_lov FOR
      SELECT   MAX(h.request_number)
             , MAX(h.description)
             , h.header_id
             , MAX(h.move_order_type)
             , DECODE(COUNT(l.line_number), 1, MAX(l.line_number), NULL)
             , DECODE(COUNT(l.line_id), 1, MAX(l.line_id), NULL)
          FROM mtl_txn_request_headers h, mtl_txn_request_lines l
         WHERE h.organization_id = p_organization_id
           AND h.request_number LIKE(p_mo_req_number)
           AND h.header_status IN(3, 7, 8)
           AND move_order_type = 5
           AND l.organization_id = h.organization_id
           AND l.line_status IN(3, 7, 8)
           AND NVL(l.quantity_delivered, 0) < l.quantity
           AND l.header_id = h.header_id
           AND EXISTS(
                SELECT NULL
                  FROM mtl_system_items msi
                 WHERE msi.inventory_item_id = l.inventory_item_id
                   AND msi.organization_id = l.organization_id
                   AND msi.mtl_transactions_enabled_flag = 'Y'
                   AND msi.inventory_item_flag = 'Y'
                   AND msi.bom_item_type = 4)
      GROUP BY h.header_id;
  END get_wipmo_lov;

  --      Name: GET_MOLINE_LOV
  --
  --      Input parameters:
  --       p_Organization_Id   which restricts LOV SQL to current org
  --       p_mo_number   which restricts LOV SQL to the user input text
  --       p_line_number   which restricts LOV SQL to specifid Line
  --
  --      Output parameters:
  --       x_mo_line_lov      returns LOV rows as reference cursor
  --
  --      Functions: This API returns MO Line Number for a given org and
  --          MoveOrder headerId which are in status APPROVED, PREAPPROVED
  --                 and PART_APPROVED
  --

  PROCEDURE get_moline_lov(
    x_mo_line_lov     OUT NOCOPY    t_genref
  , p_organization_id IN            NUMBER
  , p_mo_header_id    IN            NUMBER
  , p_line_number     IN            VARCHAR2
  ) IS
  BEGIN
    OPEN x_mo_line_lov FOR
      SELECT line_number, line_id, move_order_type
        FROM mtl_txn_request_lines_v mtrl
       WHERE organization_id = p_organization_id
         AND line_status IN(3, 7, 8)
         AND NVL(quantity_delivered, 0) < quantity
         AND header_id = p_mo_header_id
         AND line_number LIKE(p_line_number)
         AND EXISTS(
              SELECT NULL
                FROM mtl_system_items msi
               WHERE msi.inventory_item_id = mtrl.inventory_item_id
                 AND msi.organization_id = p_organization_id
                 AND msi.mtl_transactions_enabled_flag = 'Y'
                 AND msi.inventory_item_flag = 'Y'
                 AND msi.bom_item_type = 4);
  END get_moline_lov;

  PROCEDURE get_mo_kanban(x_mo_kanban OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_kb_number IN VARCHAR2) IS
  BEGIN
    OPEN x_mo_kanban FOR
      SELECT k.kanban_card_number
           , m.reference_id
           , m.line_id
        FROM mtl_txn_request_lines m, mtl_kanban_cards k
       WHERE m.reference_id = k.kanban_card_id
         AND m.organization_id = p_organization_id
         AND m.reference_type_code = 1
         AND m.line_status IN(3, 7, 8)
         AND NVL(quantity_delivered, 0) < quantity
         AND k.kanban_card_number LIKE(p_kb_number);
  END get_mo_kanban;

  PROCEDURE get_mo_sohdr(x_mo_sohdr OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_sohdr_id IN VARCHAR2) IS
  BEGIN
    OPEN x_mo_sohdr FOR
      SELECT UNIQUE wdd.source_header_number
               FROM wsh_delivery_details wdd
              WHERE wdd.organization_id = p_organization_id
                AND wdd.released_status = 'S'
                AND wdd.source_header_number LIKE(p_sohdr_id);
  END;

  --Bug #3796571, filtering Delivery LOV on Sales Order Number, Move Order, and Pickslip number.
  PROCEDURE get_delivery_num(x_delivery OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_deliv_num IN VARCHAR2, p_so_number IN VARCHAR2 := NULL, p_mo_req_num IN VARCHAR2 := NULL, p_pickslip_number IN VARCHAR2 := NULL) IS
  BEGIN
      --bug 4951734, rewriting query with better performance.
      /*
      SELECT wnd.NAME, wnd.delivery_id
        FROM wsh_new_deliveries wnd, wsh_delivery_details wdd, wsh_delivery_assignments_v wda, mtl_txn_request_lines ml
       WHERE wda.delivery_id = wnd.delivery_id
         AND wda.delivery_detail_id = wdd.delivery_detail_id
         AND wdd.move_order_line_id = ml.line_id
         AND wdd.organization_id = p_organization_id
         AND ml.quantity > NVL(ml.quantity_delivered, 0)
         AND wnd.NAME LIKE(p_deliv_num || '%');
      */

      --bug #3796571, forking the code for better performance when filtering parameters are not passed.
      IF (p_so_number IS NULL AND p_mo_req_num IS NULL AND p_pickslip_number IS NULL) THEN
        OPEN x_delivery FOR
          SELECT UNIQUE wnd.NAME
               , wnd.delivery_id
            FROM wsh_new_deliveries_ob_grp_v wnd
               , wsh_delivery_details_ob_grp_v wdd
               , wsh_delivery_assignments wda
               , mtl_txn_request_lines ml
           WHERE wda.delivery_id = wnd.delivery_id
             AND wda.delivery_detail_id = wdd.delivery_detail_id
             AND wdd.released_status = 'S'
             AND wdd.organization_id = p_organization_id
             AND wdd.move_order_line_id = ml.line_id
             AND ml.organization_id = p_organization_id
             AND ml.inventory_item_id = wdd.inventory_item_id
             AND ml.line_status = 7
             AND ml.transaction_source_type_id IN (2, 8)
             AND wnd.NAME LIKE (p_deliv_num) ;
      ELSIF (p_pickslip_number IS NULL) THEN
        OPEN x_delivery FOR
          SELECT UNIQUE wnd.NAME
               , wnd.delivery_id
            FROM wsh_new_deliveries_ob_grp_v wnd
               , wsh_delivery_details_ob_grp_v wdd
               , wsh_delivery_assignments wda
               , mtl_txn_request_lines ml
               , mtl_txn_request_headers mh
           WHERE wda.delivery_id = wnd.delivery_id
             AND wda.delivery_detail_id = wdd.delivery_detail_id
             AND wdd.released_status = 'S'
             AND wdd.organization_id = p_organization_id
             AND wdd.move_order_line_id = ml.line_id
             AND ml.organization_id = p_organization_id
             AND ml.inventory_item_id = wdd.inventory_item_id
             AND ml.line_status = 7
             AND ml.transaction_source_type_id IN (2, 8)
             AND ml.header_id = mh.header_id
             AND (p_so_number IS NULL OR wdd.source_header_number = p_so_number)
             AND (p_mo_req_num IS NULL OR mh.request_number = p_mo_req_num)
             AND wnd.NAME LIKE (p_deliv_num) ;
      ELSE
        OPEN x_delivery FOR
          SELECT UNIQUE wnd.NAME
               , wnd.delivery_id
            FROM wsh_new_deliveries_ob_grp_v wnd
               , wsh_delivery_details_ob_grp_v wdd
               , wsh_delivery_assignments wda
               , mtl_txn_request_lines ml
               , mtl_txn_request_headers mh
               , mtl_material_transactions_temp mmtt
           WHERE wda.delivery_id = wnd.delivery_id
             AND wda.delivery_detail_id = wdd.delivery_detail_id
             AND wdd.released_status = 'S'
             AND wdd.organization_id = p_organization_id
             AND wdd.move_order_line_id = ml.line_id
             AND ml.organization_id = p_organization_id
             AND ml.inventory_item_id = wdd.inventory_item_id
             AND ml.line_status = 7
             AND ml.transaction_source_type_id IN (2, 8)
             AND ml.header_id = mh.header_id
             AND ml.organization_id = mmtt.organization_id
             AND ml.line_id = mmtt.move_order_line_id
             AND mh.header_id = mmtt.move_order_header_id
             AND (p_so_number IS NULL OR wdd.source_header_number = p_so_number)
             AND (p_mo_req_num IS NULL OR mh.request_number = p_mo_req_num)
             AND (p_pickslip_number IS NULL OR mmtt.pick_slip_number = p_pickslip_number)
             AND wnd.NAME LIKE (p_deliv_num) ;
      END IF;
  END;

  --Bug #3796571, filtering Pickslip LOV on Sales Order Number, Move Order
  PROCEDURE get_pickslip_num(x_pickslip OUT NOCOPY t_genref, p_organization_id IN NUMBER, p_pickslip_num IN VARCHAR2, p_so_number IN VARCHAR2 := NULL, p_mo_req_num IN VARCHAR2 := NULL) IS
  BEGIN
      --bug #3796571, forking the code for better performance when filtering parameters are not passed.
      IF (p_so_number IS NULL AND p_mo_req_num IS NULL) THEN
        OPEN x_pickslip FOR
          SELECT UNIQUE pick_slip_number
            FROM mtl_material_transactions_temp mmtt
            WHERE mmtt.organization_id = p_organization_id
              AND mmtt.pick_slip_number LIKE (p_pickslip_num);
      ELSE
        OPEN x_pickslip FOR
          SELECT UNIQUE pick_slip_number
            FROM mtl_material_transactions_temp mmtt
               , mtl_sales_orders mso
               , mtl_txn_request_headers mh
            WHERE mmtt.organization_id = p_organization_id
              AND mmtt.move_order_header_id = mh.header_id
              AND mso.sales_order_id = mmtt.transaction_source_id
              AND (p_so_number IS NULL OR mso.segment1 = p_so_number)
              AND (p_mo_req_num IS NULL OR mh.request_number = p_mo_req_num)
              AND mmtt.pick_slip_number LIKE (p_pickslip_num);
      END IF;
  END;

  PROCEDURE get_missing_qty_action_lov(x_miss_qty_action OUT NOCOPY t_genref, p_miss_qty_action VARCHAR2) AS
  BEGIN
    OPEN x_miss_qty_action FOR
      SELECT meaning, lookup_code
        FROM mfg_lookups
       WHERE lookup_type = 'INV_MISSING_QTY_ACTIONS'
         AND meaning LIKE p_miss_qty_action
       ORDER BY lookup_code;
  END;

END inv_mo_lovs;

/
