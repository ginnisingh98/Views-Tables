--------------------------------------------------------
--  DDL for Package Body MSC_X_UDE_PEGGING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_X_UDE_PEGGING" AS
/*  $Header: MSCXCEB.pls 120.2 2006/02/16 01:01:28 pragarwa ship $ */
   PURCHASE_ORDER CONSTANT INTEGER := 13;
   SALES_ORDER CONSTANT INTEGER := 14;


   PROCEDURE get_so_data(parent_id IN NUMBER, so_max_receipt_date OUT NOCOPY DATE, so_min_receipt_date OUT NOCOPY DATE,
                         so_sum_quantity OUT NOCOPY NUMBER)
   IS
   BEGIN
         SELECT min(child.receipt_date), max(child.receipt_date),
                sum(decode(sys_context('MSC','COMPANY_ID'), child.publisher_id, child.primary_quantity, decode(child.publisher_id, child.customer_id, child.supplier_id, child.customer_id), child.tp_quantity, child.quantity))
           INTO so_min_receipt_date, so_max_receipt_date, so_sum_quantity
           FROM msc_sup_dem_entries parent, msc_sup_dem_entries child
          WHERE parent.plan_id = -1
            AND parent.publisher_order_type = PURCHASE_ORDER
            AND exists
                 (select 1 from MSC_X_SECURITY_RULES rule where sysdate between
nvl(rule.EFFECTIVE_FROM_DATE, sysdate-1) and nvl(rule.EFFECTIVE_TO_DATE, sysdate +1)
and nvl(rule.company_id, parent.PUBLISHER_ID) = parent.publisher_id and
nvl(rule.order_type, parent.publisher_order_type) = parent.publisher_order_type and
 nvl(rule.item_id, parent.inventory_item_id) = parent.inventory_item_id and
 nvl(rule.customer_id, nvl(parent.customer_id, -1)) = nvl(parent.customer_id, -1) and
 nvl(rule.supplier_id, nvl(parent.supplier_id, -1)) = nvl(parent.supplier_id, -1) and nvl(rule.customer_site_id,
  nvl(parent.customer_site_id, -1)) = nvl(parent.customer_site_id, -1) and
  nvl(rule.supplier_site_id, nvl(parent.supplier_site_id, -1)) = nvl(parent.supplier_site_id, -1) and
  nvl(rule.org_id, parent.PUBLISHER_SITE_ID) = parent.PUBLISHER_SITE_ID and
  nvl(rule.order_number, nvl(parent.order_number, -1)) = nvl(parent.order_number, -1) and
  (rule.grantee_key = decode(upper(rule.grantee_type), 'USER', FND_GLOBAL.USER_ID, 'COMPANY', sys_context('MSC', 'COMPANY_ID')) or upper(rule.grantee_type) = 'DOCUMENT OWNER' and
  parent.publisher_id = sys_context('MSC', 'COMPANY_ID') or
  upper(rule.grantee_type) ='TRADING PARTNER' and parent.customer_id = sys_context('MSC', 'COMPANY_ID')
  or upper(rule.grantee_type) = 'TRADING PARTNER' and parent.supplier_id = sys_context('MSC', 'COMPANY_ID') or decode(upper(rule.grantee_type),'RESPONSIBILITY', rule.grantee_key) = fnd_global.resp_id or
  (upper(rule.grantee_type) = 'GLOBAL') or (upper(rule.grantee_type)='GROUP' and rule.grantee_key in
  (SELECT group_id FROM msc_group_companies WHERE company_id = sys_context('MSC','COMPANY_ID') AND
  sysdate BETWEEN effective_date and nvl(disable_date,sysdate+1) ) ) ) )
            AND exists
                 (select 1 from MSC_X_SECURITY_RULES rule where sysdate between
nvl(rule.EFFECTIVE_FROM_DATE, sysdate-1) and nvl(rule.EFFECTIVE_TO_DATE, sysdate +1)
and nvl(rule.company_id, child.PUBLISHER_ID) = child.publisher_id and
nvl(rule.order_type, child.publisher_order_type) = child.publisher_order_type and
 nvl(rule.item_id, child.inventory_item_id) = child.inventory_item_id and
 nvl(rule.customer_id, nvl(child.customer_id, -1)) = nvl(child.customer_id, -1) and
 nvl(rule.supplier_id, nvl(child.supplier_id, -1)) = nvl(child.supplier_id, -1) and
 nvl(rule.customer_site_id, nvl(child.customer_site_id, -1)) = nvl(child.customer_site_id, -1) and
 nvl(rule.supplier_site_id, nvl(child.supplier_site_id, -1)) = nvl(child.supplier_site_id, -1) and
 nvl(rule.org_id, child.PUBLISHER_SITE_ID) = child.PUBLISHER_SITE_ID and
 nvl(rule.order_number, nvl(child.order_number, -1)) = nvl(child.order_number, -1) and
 (rule.grantee_key = decode(upper(rule.grantee_type), 'USER', FND_GLOBAL.USER_ID, 'COMPANY', sys_context('MSC', 'COMPANY_ID')) or upper(rule.grantee_type) = 'DOCUMENT OWNER' and
 child.publisher_id = sys_context('MSC', 'COMPANY_ID') or upper(rule.grantee_type) ='TRADING PARTNER' and
 child.customer_id = sys_context('MSC', 'COMPANY_ID') or upper(rule.grantee_type) = 'TRADING PARTNER' and
 child.supplier_id = sys_context('MSC', 'COMPANY_ID') or decode(upper(rule.grantee_type),'RESPONSIBILITY', rule.grantee_key) = fnd_global.resp_id or (upper(rule.grantee_type) = 'GLOBAL') or
 (upper(rule.grantee_type)='GROUP' and rule.grantee_key in (SELECT group_id FROM msc_group_companies WHERE company_id = sys_context('MSC','COMPANY_ID') AND sysdate BETWEEN effective_date and nvl(disable_date,sysdate+1) ) ) ) )
            AND parent.transaction_id = parent_id
            AND parent.order_number = child.end_order_number
          AND nvl(parent.release_number, -1) = nvl(child.end_order_rel_number, -1)
          AND (
               (child.end_order_line_number IS NOT NULL AND
                parent.line_number = child.end_order_line_number )
               OR
               (child.end_order_line_number IS NULL AND
                parent.publisher_id = child.end_order_publisher_id AND
                decode(child.end_order_publisher_site_id,
                         null, parent.publisher_site_id,
                         child.end_order_publisher_site_id) = parent.publisher_site_id AND
                parent.inventory_item_id = child.inventory_item_id )
               OR
               (child.end_order_line_number IS NULL AND
                child.end_order_publisher_id <> child.publisher_id AND
                parent.inventory_item_id = child.inventory_item_id )
             )
           AND (
                (child.end_order_publisher_id IS NOT NULL AND
                 parent.publisher_id = child.end_order_publisher_id AND
                 child.end_order_type IS NOT NULL AND
                 parent.publisher_order_type = child.end_order_type AND
                 decode(child.end_order_publisher_site_id,
                         null, parent.publisher_site_id,
                         child.end_order_publisher_site_id) = parent.publisher_site_id
                )
                OR
                (child.end_order_publisher_id IS NULL AND
                 child.end_order_type IS NOT NULL AND
                 parent.publisher_id = child.publisher_id)
              ) ;

   EXCEPTION
   WHEN OTHERS THEN
      so_max_receipt_date := NULL;
      so_min_receipt_date := NULL;
      so_sum_quantity := NULL;
   END get_so_data;

   PROCEDURE get_po_data (child_transid IN NUMBER, po_need_by_date OUT NOCOPY DATE, po_quantity OUT NOCOPY NUMBER,
                          po_transaction OUT NOCOPY NUMBER)
   IS
      l_need_by_date DATE ;
      l_quantity NUMBER;
      l_po_transaction NUMBER;

   BEGIN

      /**
       * assumes that the given child record is a sales order
       */

      SELECT parent.receipt_date,
      decode(sys_context('MSC','COMPANY_ID'), parent.publisher_id, parent.primary_quantity, decode(parent.publisher_id, parent.customer_id, parent.supplier_id, parent.customer_id), parent.tp_quantity, parent.quantity),
      parent.transaction_id
        INTO l_need_by_date, l_quantity, l_po_transaction
        FROM msc_sup_dem_entries parent, msc_sup_dem_entries child
       WHERE parent.publisher_order_type = PURCHASE_ORDER
         AND parent.plan_id = -1
         AND exists
              (select 1 from MSC_X_SECURITY_RULES rule where sysdate between
nvl(rule.EFFECTIVE_FROM_DATE, sysdate-1) and nvl(rule.EFFECTIVE_TO_DATE, sysdate +1)
and nvl(rule.company_id, parent.PUBLISHER_ID) = parent.publisher_id and
nvl(rule.order_type, parent.publisher_order_type) = parent.publisher_order_type and
 nvl(rule.item_id, parent.inventory_item_id) = parent.inventory_item_id and
 nvl(rule.customer_id, nvl(parent.customer_id, -1)) = nvl(parent.customer_id, -1) and
 nvl(rule.supplier_id, nvl(parent.supplier_id, -1)) = nvl(parent.supplier_id, -1) and
 nvl(rule.customer_site_id, nvl(parent.customer_site_id, -1)) = nvl(parent.customer_site_id, -1) and
 nvl(rule.supplier_site_id, nvl(parent.supplier_site_id, -1)) = nvl(parent.supplier_site_id, -1) and
 nvl(rule.org_id, parent.PUBLISHER_SITE_ID) = parent.PUBLISHER_SITE_ID and
 nvl(rule.order_number, nvl(parent.order_number, -1)) = nvl(parent.order_number, -1) and
 (rule.grantee_key = decode(upper(rule.grantee_type), 'USER', FND_GLOBAL.USER_ID, 'COMPANY', sys_context('MSC', 'COMPANY_ID'))
 or upper(rule.grantee_type) = 'DOCUMENT OWNER' and parent.publisher_id = sys_context('MSC', 'COMPANY_ID') or
 upper(rule.grantee_type) ='TRADING PARTNER' and parent.customer_id = sys_context('MSC', 'COMPANY_ID') or
 upper(rule.grantee_type) = 'TRADING PARTNER' and parent.supplier_id = sys_context('MSC', 'COMPANY_ID') or
 decode(upper(rule.grantee_type),'RESPONSIBILITY', rule.grantee_key) = fnd_global.resp_id or
 (upper(rule.grantee_type) = 'GLOBAL') or (upper(rule.grantee_type)='GROUP' and rule.grantee_key in (SELECT group_id FROM msc_group_companies WHERE company_id = sys_context('MSC','COMPANY_ID') AND sysdate BETWEEN
 effective_date and nvl(disable_date,sysdate+1) ) ) ) )
         AND child.transaction_id = child_transid
         AND parent.order_number = child.end_order_number
         AND ( (child.end_order_line_number IS NOT NULL AND
             child.end_order_line_number = parent.line_number)
            OR
            (child.end_order_line_number IS NULL AND
             parent.publisher_id = child.end_order_publisher_id AND
             decode(child.end_order_publisher_site_id, null,
                    parent.publisher_site_id,
                 child.end_order_publisher_site_id)
              = parent.publisher_site_id  AND
            child.inventory_item_id = parent.inventory_item_id )
            OR
            (child.end_order_line_number IS NULL AND
             child.publisher_id <> child.end_order_publisher_id)
          )
      AND nvl(parent.release_number, -1)
               = nvl(child.end_order_rel_number, -1)
      AND ((child.end_order_publisher_id IS NOT NULL AND
            child.end_order_type IS NOT NULL AND
            child.end_order_type = parent.publisher_order_type AND
            child.end_order_publisher_id = parent.publisher_id AND
            decode(child.end_order_publisher_site_id, null,
                  parent.publisher_site_id,
                child.end_order_publisher_site_id)
                = parent.publisher_site_id
            )
            OR
            (child.end_order_publisher_id IS NULL AND
             child.end_order_type IS NOT NULL AND
             child.publisher_id = parent.publisher_id)
          );

      po_need_by_date := l_need_by_date;
      po_quantity := l_quantity;
      po_transaction := l_po_transaction;

   EXCEPTION
      WHEN OTHERS THEN
         po_need_by_date := NULL;
         po_quantity := NULL;
         po_transaction := NULL;

   END get_po_data;


   FUNCTION days_late(p_transaction_id NUMBER)
   RETURN NUMBER
   AS

      l_order_type NUMBER;
      l_receipt_date DATE;

      po_need_by_date DATE;
      po_quantity NUMBER;
      l_po_transaction NUMBER;

      days_late NUMBER;
      so_max_receipt_date DATE;
      so_min_receipt_date DATE;
      so_sum_quantity NUMBER;

   BEGIN

      SELECT msde.publisher_order_type, msde.receipt_date
        INTO l_order_type, l_receipt_date
        FROM msc_sup_dem_entries msde
      WHERE msde.transaction_id = p_transaction_id
        AND msde.publisher_order_type IN (PURCHASE_ORDER, SALES_ORDER);

      IF l_order_type = SALES_ORDER THEN
         get_po_data(p_transaction_id, po_need_by_date, po_quantity, l_po_transaction);
         days_late := l_receipt_date - po_need_by_date;
      ELSIF l_order_type = PURCHASE_ORDER THEN
         get_so_data(p_transaction_id, so_max_receipt_date, so_min_receipt_date, so_sum_quantity);
         days_late := so_max_receipt_date - l_receipt_date;
      END IF;

      IF days_late > 0 THEN
         RETURN days_late;
      ELSE
         RETURN 0;
      END IF;

   EXCEPTION
   WHEN OTHERS THEN
      RETURN 0;
   END days_late;

   FUNCTION days_early(p_transaction_id NUMBER)
   RETURN NUMBER
   AS

      l_order_type NUMBER;
      l_receipt_date DATE;

      po_need_by_date DATE;
      po_quantity NUMBER;
      l_po_transaction NUMBER;

      days_early NUMBER;
      so_max_receipt_date DATE;
      so_min_receipt_date DATE;
      so_sum_quantity NUMBER;

   BEGIN

      SELECT publisher_order_type, receipt_date
        INTO l_order_type, l_receipt_date
        FROM msc_sup_dem_entries_ui_v
      WHERE transaction_id = p_transaction_id
        AND publisher_order_type in (PURCHASE_ORDER, SALES_ORDER);

      IF l_order_type = SALES_ORDER THEN
         get_po_data(p_transaction_id, po_need_by_date, po_quantity, l_po_transaction);
         days_early := po_need_by_date - l_receipt_date;
      ELSIF l_order_type = PURCHASE_ORDER THEN
         get_so_data(p_transaction_id, so_max_receipt_date, so_min_receipt_date, so_sum_quantity);
         days_early := l_receipt_date - so_min_receipt_date;

      END IF;

   IF days_early > 0 THEN
      RETURN days_early;
   ELSE
      RETURN 0;
   END IF;

   EXCEPTION
   WHEN OTHERS THEN
      RETURN 0;
   END days_early;

   PROCEDURE quantity(p_transaction_id IN NUMBER, po_quantity_required OUT NOCOPY NUMBER, so_quantity_given OUT NOCOPY NUMBER)
   IS
      l_order_type NUMBER;
      l_receipt_date DATE;

      po_need_by_date DATE;
      so_max_receipt_date DATE;
      so_min_receipt_date DATE;
      so_sum_quantity NUMBER;
      l_po_transaction NUMBER;
      l_quantity NUMBER;

   BEGIN

      SELECT publisher_order_type, receipt_date,
             decode(sys_context('MSC','COMPANY_ID'), publisher_id, primary_quantity, decode(publisher_id, customer_id, supplier_id, customer_id), tp_quantity, quantity)
        INTO l_order_type, l_receipt_date, l_quantity
        FROM msc_sup_dem_entries_ui_v
      WHERE transaction_id = p_transaction_id
        AND publisher_order_type in (PURCHASE_ORDER, SALES_ORDER);

      IF l_order_type IN (SALES_ORDER, PURCHASE_ORDER) THEN

         IF l_order_type = SALES_ORDER THEN
            get_po_data(p_transaction_id, po_need_by_date, po_quantity_required, l_po_transaction);
            get_so_data(l_po_transaction, so_max_receipt_date, so_min_receipt_date, so_quantity_given);
         ELSE
            po_quantity_required := l_quantity;
            get_so_data(p_transaction_id, so_max_receipt_date, so_min_receipt_date, so_quantity_given);
         END IF;

      END IF;

   EXCEPTION
   WHEN OTHERS THEN
      RETURN;
   END quantity;

   FUNCTION quantity_excess(p_transaction_id NUMBER)
   RETURN NUMBER
   IS
      quantity_required NUMBER;
      quantity_given NUMBER;
      quantity_excess NUMBER;
   BEGIN

      quantity(p_transaction_id, quantity_required, quantity_given);
      quantity_excess := quantity_given - quantity_required;

      IF quantity_excess > 0 THEN
         RETURN quantity_excess;
      ELSE
         RETURN 0;
      END IF;

   EXCEPTION
   WHEN OTHERS THEN
      RETURN 0;
   END quantity_excess;


   FUNCTION quantity_shortage(p_transaction_id NUMBER)
   RETURN NUMBER
   IS
      quantity_required NUMBER;
      quantity_given NUMBER;
      quantity_short NUMBER;
   BEGIN

      quantity(p_transaction_id, quantity_required, quantity_given);
      quantity_short := quantity_required - quantity_given;

      IF quantity_short >= 0 THEN
         RETURN quantity_short;
      ELSE
         RETURN 0;
      END IF;

   EXCEPTION
   WHEN OTHERS THEN
      RETURN 0;
   END quantity_shortage;

END msc_x_ude_pegging;

/
