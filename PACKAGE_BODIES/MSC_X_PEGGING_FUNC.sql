--------------------------------------------------------
--  DDL for Package Body MSC_X_PEGGING_FUNC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_X_PEGGING_FUNC" AS
/*  $Header: MSCXPEGB.pls 115.20 2004/04/26 19:05:59 vpillari ship $ */

   /**
    * package to create the function that are used in Enhanced pegging screen
    */

   TYPE date_type IS TABLE OF DATE INDEX BY BINARY_INTEGER ;

   TYPE int_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER ;


   PURCHASE_ORDER CONSTANT INTEGER := 13;
   SALES_ORDER CONSTANT INTEGER := 14;
   ASN CONSTANT INTEGER := 15;
   RECEIPT CONSTANT INTEGER := 16;

   RECEIPT_LEVEL CONSTANT INTEGER := 5;
   ASN_LEVEL CONSTANT INTEGER := 4;
   SO_LEVEL CONSTANT INTEGER := 3;
   OTHER_LEVEL CONSTANT INTEGER := 2;

   LEVEL_5 CONSTANT INTEGER := 5;
   LEVEL_4 CONSTANT INTEGER := 4;
   LEVEL_3 CONSTANT INTEGER := 3;
   LEVEL_2 CONSTANT INTEGER := 2;


   DATE_EXCEP CONSTANT INTEGER := 1;
   QTY_EXCEP CONSTANT INTEGER := 2;
   DEFAULT_FORMAT VARCHAR2(10) := 'MM-DD-YYYY';


   /**
    * the following function returns a string composed of
    * transactionids of immediate children for the required
    * transactionid.

    * @param transaction id as  number
    * @return varchar2 - a string of transids separated with
                       - @transactionIds=
    * NOTE: the @ is used here in place of the ampersand.
    *     : since the ampersand is a reservered character in PL/SQL
    */
   FUNCTION get_transids (arg_transid IN NUMBER,arg_binder IN VARCHAR2) RETURN VARCHAR2
   IS


      var_ids int_type;

      var_order_type number;

      var_start_id number;

      var_retstr VARCHAR2(4000) ;

      var_str CONSTANT VARCHAR2(16) := arg_binder || 'transactionIds=' ;

      i INTEGER := 0;

   BEGIN
      var_start_id := arg_transid;

      SELECT publisher_order_type
        INTO var_order_type
        FROM msc_sup_dem_entries_ui_v -- msc_sup_dem_entries_ui_v
       WHERE transaction_id = arg_transid ;

      if var_order_type <> PURCHASE_ORDER then

         var_start_id := get_immediate_po(arg_transid, var_order_type);

      end if;


      -- now start and peg down
      SELECT a.transaction_id
        BULK COLLECT INTO var_ids
        FROM msc_sup_dem_entries a -- msc_sup_dem_entries_ui_v
       WHERE exists
                 (select 1 from msc_sup_dem_security_v security
                  where security.transaction_id = a.transaction_id )
         AND Level < RECEIPT_LEVEL
       START WITH a.transaction_id = var_start_id
       CONNECT BY PRIOR a.order_number = a.end_order_number
          AND PRIOR nvl(a.release_number, -1) = nvl(a.end_order_rel_number, -1)
          AND (
               (a.end_order_line_number IS NOT NULL AND
                PRIOR a.line_number = a.end_order_line_number )
               OR
               (a.end_order_line_number IS NULL AND
                PRIOR a.publisher_id = a.end_order_publisher_id AND
                decode(a.end_order_publisher_site_id,
                         null, PRIOR a.publisher_site_id,
                         a.end_order_publisher_site_id) = PRIOR a.publisher_site_id AND
                PRIOR a.inventory_item_id = a.inventory_item_id )
               OR
               (a.end_order_line_number IS NULL AND
                a.end_order_publisher_id <> a.publisher_id AND
                PRIOR a.inventory_item_id = a.inventory_item_id )
             )
           AND (
                (a.end_order_publisher_id IS NOT NULL AND
                 PRIOR a.publisher_id = a.end_order_publisher_id AND
                 a.end_order_type IS NOT NULL AND
                 PRIOR a.publisher_order_type = a.end_order_type AND
                 decode(a.end_order_publisher_site_id,
                         null, PRIOR a.publisher_site_id,
                         a.end_order_publisher_site_id) = PRIOR a.publisher_site_id
                )
                OR
                (a.end_order_publisher_id IS NULL AND
                 a.end_order_type IS NOT NULL AND
                 PRIOR a.publisher_id = a.publisher_id)
              ) ;

      if var_ids is not null then
         for i in var_ids.FIRST.. var_ids.LAST loop
            -- now if the length exceeds 4000 then exit
            if (length(var_retstr) + length(var_ids(i)) > 4000) then
               exit;
            end if;
            var_retstr := var_retstr || var_str || var_ids(i);
         end loop;
      end if;

      return var_retstr;
   EXCEPTION
      when others then
         return null;

   END get_transids;



   /**
    * the following function checks if the given
    * transactionid has any children pegged to it

    * @param transaction id as  number
    * @return number of children pegged - excluding itself
    */
   FUNCTION get_child_num (arg_transid IN NUMBER) RETURN NUMBER
   IS
      v_ret_num number;
   BEGIN

      -- PEG DOWN
      SELECT count(a.transaction_id)
        INTO v_ret_num
        FROM msc_sup_dem_entries a-- msc_sup_dem_entries_ui_v
       WHERE exists
                  (select 1 from msc_sup_dem_security_v security
                  where security.transaction_id = a.transaction_id )
         AND a.transaction_id <> arg_transid  -- else the starting rec will be counted as one
       START WITH a.transaction_id = arg_transid
       CONNECT BY
           PRIOR a.order_number = a.end_order_number
       AND PRIOR nvl(a.release_number, -1) = nvl(a.end_order_rel_number, -1)
       AND (
             (a.end_order_line_number IS NOT NULL AND
              PRIOR a.line_number = a.end_order_line_number )
             OR
             (a.end_order_line_number IS NULL AND
              PRIOR a.publisher_id = a.end_order_publisher_id AND
              decode(a.end_order_publisher_site_id,
                       null, PRIOR a.publisher_site_id,
                       a.end_order_publisher_site_id) = PRIOR a.publisher_site_id AND
              PRIOR a.inventory_item_id = a.inventory_item_id )
             OR
             (a.end_order_line_number IS NULL AND
              a.end_order_publisher_id <> a.publisher_id AND
              PRIOR a.inventory_item_id = a.inventory_item_id )
           )
        AND (
              (a.end_order_publisher_id IS NOT NULL AND
               PRIOR a.publisher_id = a.end_order_publisher_id AND
               a.end_order_type IS NOT NULL AND
               PRIOR a.publisher_order_type = a.end_order_type AND
               decode(a.end_order_publisher_site_id,
                       null, PRIOR a.publisher_site_id,
                       a.end_order_publisher_site_id) = PRIOR a.publisher_site_id
              )
              OR
              (a.end_order_publisher_id IS NULL AND
               a.end_order_type IS NOT NULL AND
               PRIOR a.publisher_id = a.publisher_id)
            ) ;


      return v_ret_num;
   EXCEPTION
      when others then
         return 0;

   END get_child_num;



   /**
    * The following function returns the max receipt date as follows.
    * For an SO/ASN/SR row, this will be the receipt date for that SO
    * For a PO row, this will be the last receipt date of all immediate SO pegged to that PO.
    */

   FUNCTION get_receipt_date (arg_transid IN NUMBER) RETURN DATE
   IS
      v_receipt_date date ;
      v_order_type number;

   BEGIN

      /**
       * get the order type of the current order
       * if so then return the receipt date
       * if po then get the max(receipt_date) of all the sos pegged to the po.
       */

      Select publisher_order_type, receipt_date
        Into v_order_type, v_receipt_date
        From msc_sup_dem_entries_ui_v
      Where transaction_id = arg_transid
        and publisher_order_type in (PURCHASE_ORDER, SALES_ORDER, ASN);

      if v_order_type = SALES_ORDER OR v_order_type = ASN then
         return v_receipt_date;
      end if;

      if v_order_type = PURCHASE_ORDER then

         -- PEG DOWN
         SELECT max(a.receipt_date)
           INTO v_receipt_date
           FROM msc_sup_dem_entries a
          WHERE a.plan_id = -1
            AND a.publisher_order_type = SALES_ORDER
            AND exists
                 (select 1 from msc_sup_dem_security_v security
                  where security.transaction_id = a.transaction_id )
            AND Level < LEVEL_3
           START with a.transaction_id = arg_transid
         CONNECT BY PRIOR a.order_number = a.end_order_number
          AND PRIOR nvl(a.release_number, -1) = nvl(a.end_order_rel_number, -1)
          AND (
               (a.end_order_line_number IS NOT NULL AND
                PRIOR a.line_number = a.end_order_line_number )
               OR
               (a.end_order_line_number IS NULL AND
                PRIOR a.publisher_id = a.end_order_publisher_id AND
                decode(a.end_order_publisher_site_id,
                         null, PRIOR a.publisher_site_id,
                         a.end_order_publisher_site_id) = PRIOR a.publisher_site_id AND
                PRIOR a.inventory_item_id = a.inventory_item_id )
               OR
               (a.end_order_line_number IS NULL AND
                a.end_order_publisher_id <> a.publisher_id AND
                PRIOR a.inventory_item_id = a.inventory_item_id )
             )
           AND (
                (a.end_order_publisher_id IS NOT NULL AND
                 PRIOR a.publisher_id = a.end_order_publisher_id AND
                 a.end_order_type IS NOT NULL AND
                 PRIOR a.publisher_order_type = a.end_order_type AND
                 decode(a.end_order_publisher_site_id,
                         null, PRIOR a.publisher_site_id,
                         a.end_order_publisher_site_id) = PRIOR a.publisher_site_id
                )
                OR
                (a.end_order_publisher_id IS NULL AND
                 a.end_order_type IS NOT NULL AND
                 PRIOR a.publisher_id = a.publisher_id)
              ) ;
      end if;

      return v_receipt_date;

   EXCEPTION
      WHEN NO_DATA_FOUND then
         return null;

      WHEN OTHERS then
         return null;

   END get_receipt_date;


   /**
    * Foll function gets the number of days late, as follows
    * For an SO row, this will be [Need By date on the immediate PO - Scheduled Receipt Date on that SO]
    * For a PO row, this will be [Need By date on the PO - Scheduled Receipt Date of the immediate
    *                               SO that will be received last]
    *
    */
   FUNCTION get_days_late (arg_transid IN NUMBER) RETURN NUMBER
   IS
      v_days_late number;

      v_receipt_date date ;
      v_need_by_date date ;
      v_order_type number;

      v_start_id number;

   BEGIN

      /*
       * find out the order type.
       * if it is a sales order then peg up and then peg down
       * if PO then peg down.
       */
      v_start_id := arg_transid;

      Select publisher_order_type,
                decode(publisher_order_type,PURCHASE_ORDER,receipt_date,null),
                decode(publisher_order_type,SALES_ORDER,receipt_date,null)
        Into v_order_type, v_need_by_date, v_receipt_date
        From msc_sup_dem_entries_ui_v
      Where transaction_id = arg_transid
        and publisher_order_type in (PURCHASE_ORDER, SALES_ORDER);

      IF v_order_type = SALES_ORDER THEN
         -- peg up to the PO
         v_start_id := get_immediate_po(arg_transid, v_order_type);

         Select receipt_date
           Into v_need_by_date
           From msc_sup_dem_entries_ui_v
         Where transaction_id = v_start_id ;

      END IF;

      IF v_order_type = PURCHASE_ORDER then
         v_receipt_date := MSC_X_PEGGING_FUNC.get_receipt_date(v_start_id);
      END IF;

      if v_receipt_date <= v_need_by_date then
         return null;
      else
         v_days_late :=  v_receipt_date - v_need_by_date ;

      end if;

      if v_days_late IS NOT NULL then
	    v_days_late:= round(v_days_late,2);
      end if ;

      return v_days_late;

   EXCEPTION
      when others then
         return null;

   END get_days_late ;


   /*
    * The foll function returns the max days late for a po
    */
   FUNCTION get_max_late (arg_transid IN NUMBER) RETURN NUMBER
   IS
      v_order_type number;
      v_max_late number;

   BEGIN

      Select publisher_order_type
        Into v_order_type
        From msc_sup_dem_entries_ui_v
      Where transaction_id = arg_transid ;

      IF v_order_type = PURCHASE_ORDER then

         -- PEG DOWN

         SELECT max(get_days_late(a.transaction_id))
           INTO v_max_late
           FROM msc_sup_dem_entries a
          WHERE a.plan_id = -1
            AND a.publisher_order_type = PURCHASE_ORDER
            AND exists
                 (select 1 from msc_sup_dem_security_v security
                  where security.transaction_id = a.transaction_id )
           START with a.transaction_id = arg_transid
       CONNECT BY PRIOR a.order_number = a.end_order_number
          AND PRIOR nvl(a.release_number, -1) = nvl(a.end_order_rel_number, -1)
          AND (
               (a.end_order_line_number IS NOT NULL AND
                PRIOR a.line_number = a.end_order_line_number )
               OR
               (a.end_order_line_number IS NULL AND
                PRIOR a.publisher_id = a.end_order_publisher_id AND
                decode(a.end_order_publisher_site_id,
                         null, PRIOR a.publisher_site_id,
                         a.end_order_publisher_site_id) = PRIOR a.publisher_site_id AND
                PRIOR a.inventory_item_id = a.inventory_item_id )
               OR
               (a.end_order_line_number IS NULL AND
                a.end_order_publisher_id <> a.publisher_id AND
                PRIOR a.inventory_item_id = a.inventory_item_id )
             )
           AND (
                (a.end_order_publisher_id IS NOT NULL AND
                 PRIOR a.publisher_id = a.end_order_publisher_id AND
                 a.end_order_type IS NOT NULL AND
                 PRIOR a.publisher_order_type = a.end_order_type AND
                 decode(a.end_order_publisher_site_id,
                         null, PRIOR a.publisher_site_id,
                         a.end_order_publisher_site_id) = PRIOR a.publisher_site_id
                )
                OR
                (a.end_order_publisher_id IS NULL AND
                 a.end_order_type IS NOT NULL AND
                 PRIOR a.publisher_id = a.publisher_id)
              ) ;
      END IF;
      IF v_max_late IS NOT NULL then
         v_max_late:=round(v_max_late,2);
      END IF;

      return v_max_late;

   END get_max_late ;



   FUNCTION get_immediate_po (arg_transid IN NUMBER, arg_order_type IN NUMBER) RETURN NUMBER
   IS
      v_transid NUMBER;
      v_level NUMBER := 1;
   BEGIN

      if arg_order_type = SALES_ORDER then
         v_level := LEVEL_2;
      elsif arg_order_type = ASN then
         v_level := LEVEL_3;
      elsif arg_order_type = RECEIPT then
         v_level := LEVEL_4;
      end if;

      -- peg UP
      SELECT sd.transaction_id
        INTO v_transid
        FROM msc_sup_dem_entries sd -- msc_sup_dem_entries_ui_v
       WHERE sd.publisher_order_type = PURCHASE_ORDER
         AND sd.plan_id = -1
         AND exists
              (select 1 from msc_sup_dem_security_v security
               where security.transaction_id = sd.transaction_id )
         AND level = v_level
       START WITH transaction_id = arg_transid
      CONNECT BY
          sd.order_number = PRIOR sd.end_order_number
      AND ( (PRIOR sd.end_order_line_number IS NOT NULL AND
             PRIOR sd.end_order_line_number = sd.line_number)
            OR
            (PRIOR sd.end_order_line_number IS NULL AND
             sd.publisher_id = PRIOR sd.end_order_publisher_id AND
             decode(PRIOR sd.end_order_publisher_site_id, null,
                    sd.publisher_site_id,
                 PRIOR sd.end_order_publisher_site_id)
              = sd.publisher_site_id  AND
            PRIOR sd.inventory_item_id = sd.inventory_item_id )
            OR
            (PRIOR sd.end_order_line_number IS NULL AND
             PRIOR sd.publisher_id <> PRIOR sd.end_order_publisher_id)
          )
      AND nvl(sd.release_number, -1)
               = nvl(PRIOR sd.end_order_rel_number, -1)
      AND ((PRIOR sd.end_order_publisher_id IS NOT NULL AND
            PRIOR sd.end_order_type IS NOT NULL AND
            PRIOR sd.end_order_type = sd.publisher_order_type AND
            PRIOR sd.end_order_publisher_id = sd.publisher_id AND
            decode(PRIOR sd.end_order_publisher_site_id, null,
                  sd.publisher_site_id,
                PRIOR sd.end_order_publisher_site_id)
                = sd.publisher_site_id
            )
            OR
            (PRIOR sd.end_order_publisher_id IS NULL AND
             PRIOR sd.end_order_type IS NOT NULL AND
             PRIOR sd.publisher_id = sd.publisher_id) )
       and rownum = 1;

       return nvl(v_transid, arg_transid);

   END get_immediate_po;


   FUNCTION get_qty_ontime (arg_transid IN NUMBER) RETURN NUMBER
   IS
      v_need_by_date date;
      v_order_type number;
      v_ontime_qty number;
      v_start_id number;
      v_receipt_date date;
   BEGIN
      v_start_id := arg_transid;

      SELECT publisher_order_type,
             decode(publisher_order_type,13,receipt_date,null),
             decode(publisher_order_type,14,receipt_date,null),
             decode(sys_context('MSC','COMPANY_ID'),
                                     publisher_id, primary_quantity,
                                     customer_id, tp_quantity,
                                     supplier_id, tp_quantity,
                                     quantity)
        INTO v_order_type, v_need_by_date, v_receipt_date, v_ontime_qty
        FROM msc_sup_dem_entries_ui_v
       WHERE transaction_id = arg_transid;

      /**
       * if the order is SO
       *   then peg up get the po's need by date
       *   and compare if the so's date is before the need by date.
       * If the order is po
       *   then peg down and then get the sum of qty where the so's date before the PO.
       */

      if v_order_type = SALES_ORDER then
         v_start_id := get_immediate_po(arg_transid,v_order_type)   ;

         SELECT receipt_date
           INTO v_need_by_date
           FROM msc_sup_dem_entries_ui_v
          WHERE transaction_id = v_start_id ;

         if v_need_by_date >= v_receipt_date then
	    v_ontime_qty:=round(v_ontime_qty,6);
            return v_ontime_qty;
         else
            v_ontime_qty := null;
         end if;

      end if;

      if v_order_type = PURCHASE_ORDER then
         -- PEG DOWN
         SELECT sum(decode(sys_context('MSC','COMPANY_ID'),
                         publisher_id, primary_quantity,
                         customer_id, tp_quantity,
                         supplier_id, tp_quantity,
                         quantity) )
           INTO v_ontime_qty
           FROM msc_sup_dem_entries a
          WHERE a.plan_id = -1
            AND a.publisher_order_type = SALES_ORDER
            AND exists
                 (select 1 from msc_sup_dem_security_v security
                  where security.transaction_id = a.transaction_id )
            AND a.receipt_date <= v_need_by_date
            AND LEVEL < LEVEL_3
           START with a.transaction_id = arg_transid
         CONNECT BY PRIOR a.order_number = a.end_order_number
             AND PRIOR nvl(a.release_number, -1) = nvl(a.end_order_rel_number, -1)
             AND (
                  (a.end_order_line_number IS NOT NULL AND
                   PRIOR a.line_number = a.end_order_line_number )
                  OR
                  (a.end_order_line_number IS NULL AND
                   PRIOR a.publisher_id = a.end_order_publisher_id AND
                   decode(a.end_order_publisher_site_id,
                            null, PRIOR a.publisher_site_id,
                            a.end_order_publisher_site_id) = PRIOR a.publisher_site_id AND
                   PRIOR a.inventory_item_id = a.inventory_item_id )
                  OR
                  (a.end_order_line_number IS NULL AND
                   a.end_order_publisher_id <> a.publisher_id AND
                   PRIOR a.inventory_item_id = a.inventory_item_id )
                 )
             AND (
                  (a.end_order_publisher_id IS NOT NULL AND
                   PRIOR a.publisher_id = a.end_order_publisher_id AND
                   a.end_order_type IS NOT NULL AND
                   PRIOR a.publisher_order_type = a.end_order_type AND
                   decode(a.end_order_publisher_site_id,
                           null, PRIOR a.publisher_site_id,
                           a.end_order_publisher_site_id) = PRIOR a.publisher_site_id
                  )
                  OR
                  (a.end_order_publisher_id IS NULL AND
                   a.end_order_type IS NOT NULL AND
                   PRIOR a.publisher_id = a.publisher_id)
                 ) ;
      end if;

      v_ontime_qty:=round(v_ontime_qty,6);

      return v_ontime_qty;

   END get_qty_ontime;


   FUNCTION get_qty_late (arg_transid IN NUMBER) RETURN NUMBER
   IS
      v_need_by_date date;
      v_order_type number;
      v_late_qty number;
      v_start_id number;
      v_receipt_date date;
   BEGIN
      v_start_id := arg_transid;

      SELECT publisher_order_type,
             decode(publisher_order_type,PURCHASE_ORDER,receipt_date,null),
             decode(publisher_order_type,SALES_ORDER,receipt_date,null),
             decode(sys_context('MSC','COMPANY_ID'),
                                     publisher_id, primary_quantity,
                                     customer_id, tp_quantity,
                                     supplier_id, tp_quantity,
                                     quantity)
        INTO v_order_type, v_need_by_date, v_receipt_date, v_late_qty
        FROM msc_sup_dem_entries_ui_v
       WHERE transaction_id = arg_transid;

      /**
       * if the order is SO
       *   then peg up get the po's need by date
       *   and compare if the so's date is after the need by date.
       * If the order is po
       *   then peg down and then get the sum of qty where the so's date after the PO.
       */


      if v_order_type = SALES_ORDER then

         v_start_id := get_immediate_po(arg_transid,v_order_type)   ;

         SELECT receipt_date
           INTO v_need_by_date
           FROM msc_sup_dem_entries_ui_v
          WHERE transaction_id = v_start_id ;

         if v_need_by_date < v_receipt_date then
	    v_late_qty:=round(v_late_qty,6);
            return v_late_qty;
         else
            v_late_qty := null;
         end if;

      end if;

      IF v_order_type = PURCHASE_ORDER THEN

         -- PEG DOWN
         SELECT sum(decode(sys_context('MSC','COMPANY_ID'),
                         publisher_id, primary_quantity,
                         customer_id, tp_quantity,
                         supplier_id, tp_quantity,
                         quantity) )
           INTO v_late_qty
           FROM msc_sup_dem_entries a
          WHERE a.plan_id = -1
            AND a.publisher_order_type = SALES_ORDER
            AND exists
                 (select 1 from msc_sup_dem_security_v security
                  where security.transaction_id = a.transaction_id )
            AND a.receipt_date > v_need_by_date
            AND LEVEL < LEVEL_3
           START with a.transaction_id = arg_transid
         CONNECT BY PRIOR a.order_number = a.end_order_number
             AND PRIOR nvl(a.release_number, -1) = nvl(a.end_order_rel_number, -1)
             AND (
                  (a.end_order_line_number IS NOT NULL AND
                   PRIOR a.line_number = a.end_order_line_number )
                  OR
                  (a.end_order_line_number IS NULL AND
                   PRIOR a.publisher_id = a.end_order_publisher_id AND
                   decode(a.end_order_publisher_site_id,
                            null, PRIOR a.publisher_site_id,
                            a.end_order_publisher_site_id) = PRIOR a.publisher_site_id AND
                   PRIOR a.inventory_item_id = a.inventory_item_id )
                  OR
                  (a.end_order_line_number IS NULL AND
                   a.end_order_publisher_id <> a.publisher_id AND
                   PRIOR a.inventory_item_id = a.inventory_item_id )
                 )
             AND (
                  (a.end_order_publisher_id IS NOT NULL AND
                   PRIOR a.publisher_id = a.end_order_publisher_id AND
                   a.end_order_type IS NOT NULL AND
                   PRIOR a.publisher_order_type = a.end_order_type AND
                   decode(a.end_order_publisher_site_id,
                           null, PRIOR a.publisher_site_id,
                           a.end_order_publisher_site_id) = PRIOR a.publisher_site_id
                  )
                  OR
                  (a.end_order_publisher_id IS NULL AND
                   a.end_order_type IS NOT NULL AND
                   PRIOR a.publisher_id = a.publisher_id)
                 ) ;
      END IF;
      v_late_qty:=round(v_late_qty,6);
      return v_late_qty;

   END get_qty_late;


   FUNCTION get_intransit (arg_transid IN NUMBER) RETURN NUMBER
   IS
      v_intransit_qty number;
      v_order_type number;
      v_start_id number;

   BEGIN
      v_start_id := arg_transid;

      SELECT publisher_order_type,
             decode(sys_context('MSC','COMPANY_ID'),
                                   publisher_id, primary_quantity,
                                   customer_id, tp_quantity,
                                   supplier_id, tp_quantity,
                      quantity)
        INTO v_order_type, v_intransit_qty
        FROM msc_sup_dem_entries_ui_v
       WHERE transaction_id = arg_transid
         AND publisher_order_type in (PURCHASE_ORDER, ASN);

      if v_order_type = ASN then
         v_intransit_qty:=round(v_intransit_qty,6);
         return v_intransit_qty ;
      end if;

      if v_order_type = PURCHASE_ORDER then
         -- PEG DOWN
         SELECT sum(decode(sys_context('MSC','COMPANY_ID'),
                         publisher_id, primary_quantity,
                         customer_id, tp_quantity,
                         supplier_id, tp_quantity,
                         quantity) )
           INTO v_intransit_qty
           FROM msc_sup_dem_entries a
          WHERE a.plan_id = -1
            AND a.publisher_order_type = ASN
            AND exists
                 (select 1 from msc_sup_dem_security_v security
                  where security.transaction_id = a.transaction_id )
            AND LEVEL < LEVEL_4
           START with a.transaction_id = arg_transid
         CONNECT BY PRIOR a.order_number = a.end_order_number
             AND PRIOR nvl(a.release_number, -1) = nvl(a.end_order_rel_number, -1)
             AND (
                  (a.end_order_line_number IS NOT NULL AND
                   PRIOR a.line_number = a.end_order_line_number )
                  OR
                  (a.end_order_line_number IS NULL AND
                   PRIOR a.publisher_id = a.end_order_publisher_id AND
                   decode(a.end_order_publisher_site_id,
                            null, PRIOR a.publisher_site_id,
                            a.end_order_publisher_site_id) = PRIOR a.publisher_site_id AND
                   PRIOR a.inventory_item_id = a.inventory_item_id )
                  OR
                  (a.end_order_line_number IS NULL AND
                   a.end_order_publisher_id <> a.publisher_id AND
                   PRIOR a.inventory_item_id = a.inventory_item_id )

                 )
             AND (
                  (a.end_order_publisher_id IS NOT NULL AND
                   PRIOR a.publisher_id = a.end_order_publisher_id AND
                   a.end_order_type IS NOT NULL AND
                   PRIOR a.publisher_order_type = a.end_order_type AND
                   decode(a.end_order_publisher_site_id,
                           null, PRIOR a.publisher_site_id,
                           a.end_order_publisher_site_id) = PRIOR a.publisher_site_id
                  )
                  OR
                  (a.end_order_publisher_id IS NULL AND
                   a.end_order_type IS NOT NULL AND
                   PRIOR a.publisher_id = a.publisher_id)
                 ) ;
      end if;
      v_intransit_qty:=round(v_intransit_qty,6);
      return v_intransit_qty;

   END get_intransit;


   FUNCTION get_uncommitted (arg_transid IN NUMBER) RETURN NUMBER
   IS
      v_po_qty number;
      v_late_qty number;
      v_ontime_qty number;
      v_uncommitted number;
      v_order_type number;
   BEGIN
      SELECT publisher_order_type,
             decode(sys_context('MSC','COMPANY_ID'),
                                   publisher_id, primary_quantity,
                                   customer_id, tp_quantity,
                                   supplier_id, tp_quantity,
                      quantity)
        INTO v_order_type, v_po_qty
        FROM msc_sup_dem_entries_ui_v
       WHERE transaction_id = arg_transid;


      IF v_order_type = PURCHASE_ORDER then

         BEGIN
            v_late_qty := nvl(get_qty_late(arg_transid),0);

         EXCEPTION
            when others then
               v_late_qty := 0;
         END;

         BEGIN
            v_ontime_qty := nvl(get_qty_ontime(arg_transid),0);
         EXCEPTION
            when others then
               v_ontime_qty := 0;
         END;

         v_uncommitted := v_po_qty - ( v_late_qty + v_ontime_qty);
	 v_uncommitted:=round(v_uncommitted,6);

      END IF;

      return v_uncommitted;

   EXCEPTION
      when others then
         return null;

   END get_uncommitted;


END MSC_X_PEGGING_FUNC;

/
