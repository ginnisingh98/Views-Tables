--------------------------------------------------------
--  DDL for Package Body CHV_ITEM_ORDERS_S1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CHV_ITEM_ORDERS_S1" as
/* $Header: CHVPRIOB.pls 115.1 2002/11/26 23:55:40 sbull ship $ */

/*========================= CHV_ITEM_ORDERS_S1 ==============================*/

/*=============================================================================

  PROCEDURE NAME:     get_past_due_qty()

=============================================================================*/
PROCEDURE get_past_due_qty(x_schedule_id                 IN      NUMBER,
                           x_schedule_item_id            IN      NUMBER,
                           x_horizon_start_date          IN      DATE,
                           x_past_due_qty_primary        IN OUT NOCOPY  NUMBER,
                           x_past_due_qty_purch          IN OUT NOCOPY  NUMBER) IS

  x_progress VARCHAR2(3) := NULL;

BEGIN

  SELECT SUM(order_quantity),
         SUM(order_quantity_primary)
  INTO x_past_due_qty_purch,
       x_past_due_qty_primary
  FROM chv_item_orders
  WHERE schedule_id              = x_schedule_id
  AND   schedule_item_id         = x_schedule_item_id
  AND   due_date                 < x_horizon_start_date
--  AND   document_approval_status = 'FIRM'
  AND   supply_document_type     = 'RELEASE';

  EXCEPTION
    WHEN OTHERS THEN
      po_message_s.sql_error('get_past_due_qty', x_progress,sqlcode);
      RAISE;

END get_past_due_qty ;

/*=============================================================================

  PROCEDURE NAME:     get_auth_qty()

=============================================================================*/
PROCEDURE get_auth_qty (x_schedule_id                 IN      NUMBER,
                        x_schedule_item_id            IN      NUMBER,
                        x_authorization_end_date      IN      DATE,
                        x_authorization_qty           IN OUT NOCOPY  NUMBER,
                        x_authorization_qty_primary   IN OUT NOCOPY  NUMBER) IS

  x_progress VARCHAR2(3) := NULL;

BEGIN

/*
 * Initialize the quantities to 0 in case there are no records found.
 */
  x_authorization_qty := 0;
  x_authorization_qty_primary := 0;

  SELECT SUM(order_quantity),
         SUM(order_quantity_primary)
  INTO x_authorization_qty,
       x_authorization_qty_primary
  FROM chv_item_orders
  WHERE schedule_id      = x_schedule_id
  AND   schedule_item_id = x_schedule_item_id
  AND   due_date         < x_authorization_end_date;

  EXCEPTION
    WHEN OTHERS THEN
      po_message_s.sql_error('get_auth_qty', x_progress, sqlcode);
      RAISE;

END get_auth_qty;

END CHV_ITEM_ORDERS_S1;

/
