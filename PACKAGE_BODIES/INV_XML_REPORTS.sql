--------------------------------------------------------
--  DDL for Package Body INV_XML_REPORTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_XML_REPORTS" AS
/* $Header: INVXREPB.pls 120.6.12010000.4 2009/06/29 11:34:35 aambulka ship $ */
   -- Bug 8425698: store XML encoding specification
   g_xml_encoding  VARCHAR2(100) := '-9999';

   PROCEDURE lot_inventory_report (
      errbuf              OUT NOCOPY      VARCHAR2
    , retcode             OUT NOCOPY      VARCHAR2
    , p_organization_id   IN              NUMBER
    , p_from_item         IN              VARCHAR2
    , p_to_item           IN              VARCHAR2
    , p_from_subinv       IN              VARCHAR2
    , p_to_subinv         IN              VARCHAR2) IS

      qryctx     DBMS_XMLGEN.ctxhandle;
      v_result   CLOB;
      QUERY      VARCHAR2 (32000);
   BEGIN
      QUERY :=
         'SELECT  mp.organization_code  ORG_CODE
                        ,       sysdate REP_DATE, ''' || nvl(p_from_item, ' ') || ''' p_from_item,''' || nvl(p_to_item, ' ') ||  ''' p_to_item,
                                ''' || nvl(p_from_subinv, ' ') || ''' p_from_subinv,''' || nvl(p_to_subinv, ' ') ||  ''' p_to_subinv
                        ,       cursor(select mss.secondary_inventory_name  SUBINV
                                  ,cursor(select msi.concatenated_segments ITEM_NO
                                        ,     msi.description           ITEM_DESC
                                        ,cursor(select mln.lot_number LOT
                                                ,      fnd_date.date_to_displayDT(mln.origination_date) ORIG_DATE
                                                ,      fnd_date.date_to_displayDT(mln.expiration_date)  EXP_DATE
                                                ,      mil.concatenated_segments LOCATOR
                                                ,      sum(ohd.primary_transaction_quantity) QTY
                                                ,      msi.primary_uom_code UOM
                                                ,      sum(nvl(ohd.secondary_transaction_quantity,0)) SEC_QTY
                                                ,      msi.secondary_uom_code SEC_UOM
                                                ,      mms.status_code  STATUS
                                                ,      mln.grade_code        GRADE
                                                from  mtl_lot_numbers mln,
                                                      mtl_item_locations_kfv mil,
                                                      mtl_onhand_quantities_detail ohd,
                                                      mtl_material_statuses_vl mms
                                                WHERE msi.inventory_item_id = mln.inventory_item_id
                                                        AND msi.organization_id = mln.organization_id
                                                        AND mln.status_id = mms.status_id(+)
                                                        AND ohd.organization_id = mln.organization_id
                                                        AND ohd.inventory_item_id = mln.inventory_item_id
                                                        AND ohd.lot_number = mln.lot_number
                                                        AND ohd.locator_id = mil.inventory_location_id(+)
                                                        and ohd.organization_id = mp.organization_id
                                                        and ohd.subinventory_code = mss.secondary_inventory_name
                                                        and ohd.organization_id = msi.organization_id
                                                        and ohd.inventory_item_id = msi.inventory_item_id
                                                group by   mln.lot_number , mln.origination_date,mln.expiration_date
                                                        ,  mil.concatenated_segments
                                                        ,      msi.primary_uom_code
                                                        ,      msi.secondary_uom_code
                                                        ,      mms.status_code
                                                        ,      mln.grade_code
                                                           ) as LOT_DETAILS
                                FROM  mtl_system_items_kfv msi
                                WHERE msi.organization_id = mss.organization_id
                                and   msi.organization_id = mp.organization_id
                                and   msi.lot_control_code = 2';

      IF (    p_from_item IS NOT NULL
          AND p_to_item IS NOT NULL) THEN
         QUERY := QUERY
            || ' AND (msi.concatenated_segments >= '''
            || p_from_item
            || ''' AND msi.concatenated_segments <= '''
            || p_to_item
            || ''')';
      ELSIF (p_from_item IS NOT NULL) THEN
         QUERY := QUERY || ' AND msi.concatenated_segments >= ''' || p_from_item || '''';
      ELSIF (p_to_item IS NOT NULL) THEN
         QUERY := QUERY || ' AND msi.concatenated_segments <= ''' || p_to_item || '''';
      END IF;

      QUERY := QUERY
         || '  and   exists (select '' x '' from mtl_onhand_quantities_detail ohd1
                                            where ohd1.organization_id = mp.organization_id
                                            and ohd1.subinventory_code = mss.secondary_inventory_name
                                            and ohd1.organization_id = msi.organization_id
                                            and ohd1.inventory_item_id = msi.inventory_item_id) ) AS ITEM_DETAILS
                                            FROM mtl_secondary_inventories mss
                                        WHERE mss.organization_id = mp.organization_id';

      IF (    p_from_subinv IS NOT NULL
          AND p_to_subinv IS NOT NULL) THEN
         QUERY := QUERY
            || ' AND (mss.secondary_inventory_name >= '''
            || p_from_subinv
            || '''  AND mss.secondary_inventory_name <= '''
            || p_to_subinv
            || ''')';
      ELSIF (p_from_subinv IS NOT NULL) THEN
         QUERY := QUERY || ' AND mss.secondary_inventory_name >= ''' || p_from_subinv || '''';
      ELSIF (p_to_subinv IS NOT NULL) THEN
         QUERY := QUERY || ' AND mss.secondary_inventory_name <= ''' || p_to_subinv || '''';
      END IF;

      QUERY := QUERY
         || ' AND EXISTS ( SELECT ''x''
                                     FROM mtl_onhand_quantities_detail d
                                     WHERE d.organization_id = mss.organization_id
                                      AND d.subinventory_code = mss.secondary_inventory_name
                                      and d.organization_id = mp.organization_id )) AS SUBINV_DETAILS
                                         FROM mtl_parameters mp
                                        WHERE mp.organization_id = '
         || p_organization_id;

      fnd_file.put_line (fnd_file.LOG, query);

      qryctx := DBMS_XMLGEN.newcontext (QUERY);

      LOOP
         -- now get the result
         v_result := DBMS_XMLGEN.getxml (qryctx);

         -- if there were no rows processed, then quit
         IF v_result IS NULL THEN
            EXIT;
         END IF;

         xml_transfer (p_xml_clob => v_result);
      END LOOP;

      --close context
      DBMS_XMLGEN.closecontext (qryctx);

   EXCEPTION
      WHEN OTHERS THEN
         fnd_file.put_line (fnd_file.LOG, 'Exception in procedure LOT_INVENTORY_REPORT ' || SQLCODE || ' ' || SQLERRM);
   END lot_inventory_report;

   PROCEDURE lot_master_report (
      errbuf              OUT NOCOPY      VARCHAR2
    , retcode             OUT NOCOPY      VARCHAR2
    , p_organization_id   IN              NUMBER
    , p_from_item         IN              VARCHAR2
    , p_to_item           IN              VARCHAR2) IS

      qryctx     DBMS_XMLGEN.ctxhandle;
      v_result   CLOB;
      QUERY      VARCHAR2 (32000);
   BEGIN
      QUERY :=
         ' SELECT   mp.organization_code org,
           sysdate rep_date,''' || nvl(p_from_item, ' ') || ''' p_from_item,''' || nvl(p_to_item, ' ') ||  ''' p_to_item ,
                            cursor(select  msi.concatenated_segments Item_number
                                        ,        msi.description item_desc
                                        , cursor(select  mln.lot_number
                                                ,        mln.description
                                                ,        mln.grade_code
                                                ,        mln.expiration_action_code
                                                ,        fnd_date.date_to_displayDT(mln.expiration_action_date) expiration_action_date
                                                ,        mln.origination_type
                                                ,        mfgl.meaning lot_origination
                                                ,        fnd_date.date_to_displayDT(mln.origination_date) origination_date
                                                ,        fnd_date.date_to_displayDT(mln.expiration_date) expiration_date
                                                ,        fnd_date.date_to_displayDT(mln.retest_date) retest_date
                                                ,        fnd_date.date_to_displayDT(mln.maturity_date) maturity_date
                                                ,        fnd_date.date_to_displayDT(mln.hold_date) hold_date
                                                ,        mln.parent_lot_number
                                                ,        mln.vendor_name
                                                ,        mln.supplier_lot_number
                                                    FROM mtl_lot_numbers mln
                                                        , mfg_lookups mfgl
                                                   WHERE msi.organization_id = mln.organization_id
                                                     AND msi.inventory_item_id = mln.inventory_item_id
                                                     AND mln.origination_type = mfgl.LOOKUP_CODE(+)
                                                     AND mfgl.lookup_type(+) = ''MTL_LOT_ORIGINATION_TYPE'') as LOT_DETAILS
                                           FROM mtl_system_items_kfv msi
                                           WHERE msi.organization_id = mp.organization_id ';

      IF (    p_from_item IS NOT NULL
          AND p_to_item IS NOT NULL) THEN
         QUERY := QUERY
            || ' AND (msi.concatenated_segments >= '''
            || p_from_item
            || ''' AND msi.concatenated_segments <= '''
            || p_to_item
            || ''')';
      ELSIF (p_from_item IS NOT NULL) THEN
         QUERY := QUERY || ' AND msi.concatenated_segments >= ''' || p_from_item || '''';
      ELSIF (p_to_item IS NOT NULL) THEN
         QUERY := QUERY || ' AND msi.concatenated_segments <= ''' || p_to_item || '''';
      END IF;

      QUERY := QUERY
         || ' and msi.lot_control_code = 2 and exists ( select mln1.inventory_item_id from mtl_lot_numbers mln1 where msi.organization_id = mln1.organization_id
                            AND msi.inventory_item_id = mln1.inventory_item_id and mln1.organization_id = mp.organization_id)
                            ORDER BY msi.concatenated_segments) as ITEM_DETAILS
                            from  mtl_parameters mp
                            where mp.organization_id = '
         || p_organization_id;

      fnd_file.put_line (fnd_file.LOG, query);
      qryctx := DBMS_XMLGEN.newcontext (QUERY);

      LOOP
         -- now get the result
         v_result := DBMS_XMLGEN.getxml (qryctx);

         -- if there were no rows processed, then quit
         IF v_result IS NULL THEN
            EXIT;
         END IF;

         xml_transfer (p_xml_clob => v_result);
      END LOOP;

      --close context
      DBMS_XMLGEN.closecontext (qryctx);

   EXCEPTION
      WHEN OTHERS THEN
         fnd_file.put_line (fnd_file.LOG, 'Exception in procedure LOT_MASTER_REPORT ' || SQLCODE || ' ' || SQLERRM);
   END lot_master_report;

   PROCEDURE mat_status_def_report (
      errbuf          OUT NOCOPY      VARCHAR2
    , retcode         OUT NOCOPY      VARCHAR2
    , p_from_status   IN              VARCHAR2
    , p_to_status     IN              VARCHAR2
    , p_sort_order    IN              NUMBER) IS

      qryctx     DBMS_XMLGEN.ctxhandle;
      v_result   CLOB;
      QUERY      VARCHAR2 (32000);
      l_order    VARCHAR2 (10);
      l_range    VARCHAR2 (170)         := NULL;
      l_order_display VARCHAR2(80);
   BEGIN
      IF (p_sort_order = 2) THEN
         l_order := 'DESC';
      ELSE
         l_order := 'ASC';
      END IF;

      SELECT meaning
        INTO l_order_display
        FROM mfg_lookups
       WHERE lookup_type = 'INV_SRS_ASC_DESC'
         AND enabled_flag = 'Y'
         AND lookup_code = NVL(p_sort_order, 1);

      /*
      IF (    p_from_status IS NOT NULL
          AND p_to_status IS NOT NULL) THEN
         l_range := p_from_status || ' - ' || p_to_status;
      ELSIF (p_from_status IS NOT NULL) THEN
         l_range := 'FROM STATUS CODE - ' || p_from_status;
      ELSIF (p_to_status IS NOT NULL) THEN
         l_range := 'TILL STATUS CODE - ' || p_to_status;
      ELSE
         l_range := 'ALL';
      END IF;
      */
    /* Modified below query to accomodate onhand_control flag added for Onhand Material status project Bug 6974968  */
      QUERY :=
            'SELECT  sysdate rep_date,''' || l_order_display || ''' ORDER_BY,''' ||
                     nvl(p_from_status, ' ') || ''' p_from_status,''' ||
                     nvl(p_to_status, ' ') || ''' p_to_status
                ,       mv.status_code
                 ,        mv.description
                 ,        ml1.meaning enabled_flag_value
                 ,        ml2.meaning allow_reservations_flag_value
                 ,        ml3.meaning include_in_atp_flag_value
                 ,        ml4.meaning nettable_flag_value
                 ,        ml5.meaning subinventory_usage_flag_value
                 ,        ml6.meaning locator_usage_flag_value
                 ,        ml7.meaning lot_usage_flag_value
                 ,        ml8.meaning serial_usage_flag_value
                 ,        m19.meaning onhand_usage_flag_value
                 , cursor (select tx.transaction_description
                            from mtl_status_control_v tx
                            where tx.status_id = mv.status_id and tx.is_allowed = 1
                            order by tx.transaction_description) as allowed_transactions
                , cursor (select tx.transaction_description
                          from mtl_status_control_v tx
                          where tx.status_id = mv.status_id and tx.is_allowed = 2
                          order by tx.transaction_description) as disallowed_transactions
                 FROM mtl_material_statuses_vl mv
                ,        mfg_lookups ml1
                ,        mfg_lookups ml2
                ,        mfg_lookups ml3
                ,        mfg_lookups ml4
                ,        mfg_lookups ml5
                ,        mfg_lookups ml6
                ,        mfg_lookups ml7
                ,        mfg_lookups ml8
                ,        mfg_lookups m19
                WHERE ml1.lookup_code = mv.enabled_flag
                 and ml1.lookup_type = ''SYS_YES_NO''
                 and ml2.lookup_code = mv.reservable_type
                 and ml2.lookup_type = ''SYS_YES_NO''
                 and ml3.lookup_code = mv.inventory_atp_code
                 and ml3.lookup_type = ''SYS_YES_NO''
                 and ml4.lookup_code = mv.availability_type
                 and ml4.lookup_type = ''SYS_YES_NO''
                 and ml5.lookup_code = mv.zone_control
                 and ml5.lookup_type = ''SYS_YES_NO''
                 and ml6.lookup_code = mv.locator_control
                 and ml6.lookup_type = ''SYS_YES_NO''
                 and ml7.lookup_code = mv.lot_control
                 and ml7.lookup_type = ''SYS_YES_NO''
                 and ml8.lookup_code = mv.serial_control
                 and ml8.lookup_type = ''SYS_YES_NO''
                 and m19.lookup_code = mv.onhand_control
                 and m19.lookup_type = ''SYS_YES_NO''';

      IF (    p_from_status IS NOT NULL
          AND p_to_status IS NOT NULL) THEN
         QUERY := QUERY
            || 'AND (mv.status_code >= '''
            || p_from_status
            || ''' AND mv.status_code <= '''
            || p_to_status
            || ''')';
      ELSIF (p_from_status IS NOT NULL) THEN
         QUERY := QUERY || 'AND mv.status_code >= ''' || p_from_status || '''';
      ELSIF (p_to_status IS NOT NULL) THEN
         QUERY := QUERY || 'AND mv.status_code <= ''' || p_to_status || '''';
      END IF;

      QUERY := QUERY || ' ORDER BY mv.status_code ' || l_order;

      fnd_file.put_line (fnd_file.LOG, query);

      qryctx := DBMS_XMLGEN.newcontext (QUERY);

      LOOP
         -- now get the result
         v_result := DBMS_XMLGEN.getxml (qryctx);

         -- if there were no rows processed, then quit
         IF v_result IS NULL THEN
            EXIT;
         END IF;

         xml_transfer (p_xml_clob => v_result);
      END LOOP;

      --close context
      DBMS_XMLGEN.closecontext (qryctx);

   EXCEPTION
      WHEN OTHERS THEN
         fnd_file.put_line (fnd_file.LOG, 'Exception in procedure MAT_STATUS_DEF_REPORT ' || SQLCODE || ' ' || SQLERRM);
   END mat_status_def_report;

   PROCEDURE grade_change_history_report (
      errbuf              OUT NOCOPY      VARCHAR2
    , retcode             OUT NOCOPY      VARCHAR2
    , p_organization_id   IN              NUMBER
    , p_item_id           IN              NUMBER
    , p_from_lot          IN              VARCHAR2
    , p_to_lot            IN              VARCHAR2
    , p_from_date         IN              VARCHAR2
    , p_to_date           IN              VARCHAR2) IS

      qryctx     DBMS_XMLGEN.ctxhandle;
      v_result   CLOB;
      QUERY      VARCHAR2 (32000);
      p_from_dt  DATE := fnd_date.canonical_to_date(p_from_date);
      p_to_dt    DATE := fnd_date.canonical_to_date(p_to_date);
   BEGIN
      /* Jalaj Srivastava Bug 4998256
         get the meaning of update_method and not the code */
      QUERY :=
         'SELECT sysdate        rep_date
                ,        ood.organization_code  org_code
                ,        ood.organization_name  org_name
                ,        msi.concatenated_segments Item_No
                ,        msi.primary_uom_code  pri_uom
                ,        DECODE(msi.tracking_quantity_ind,''PS'',msi.secondary_uom_code) sec_uom  /*Bug#5436402*/
                ,        cursor ( select mlgh.lot_number lot_no
                        ,        msi.default_grade def_grade
                        ,        mlgh.old_grade_code  old_grade
                        ,        mlgh.new_grade_code    new_grade
                        ,        DECODE (mlgh.from_mobile_apps_flag, ''Y'', ''Mobile'', ''N'', ''Desktop'') updated_from
                        ,        fnd_date.date_to_displayDT(mlgh.grade_update_date) upd_date
                        ,        fnd.user_name  user_name
                        ,        ml.meaning     upd_method
                        ,        mlgh.primary_quantity  pri_qty
                        ,        mlgh.secondary_quantity        sec_qty
                        ,        mg1.description from_desc
                        ,        mg2.description to_desc
                        ,        mtr.reason_name        reason
                        from     mtl_lot_grade_history mlgh
                        ,        mtl_grades_vl mg1
                        ,        mtl_grades_vl mg2
                        ,        mtl_transaction_reasons mtr
                        ,        fnd_user fnd
                        ,        mfg_lookups ml
                        where    msi.organization_id = mlgh.organization_id
                        AND msi.inventory_item_id = mlgh.inventory_item_id
                        AND mlgh.old_grade_code = mg1.grade_code
                        AND mlgh.new_grade_code = mg2.grade_code
                        AND mlgh.created_by = fnd.user_id
                        AND mlgh.update_reason_id = mtr.reason_id(+)
                        AND ml.lookup_type        = ''MTL_STATUS_UPDATE_METHOD''
                        AND ml.lookup_code        = mlgh.update_method ';

      IF (    p_from_lot IS NOT NULL
          AND p_to_lot IS NOT NULL) THEN
         QUERY := QUERY
            || 'AND (mlgh.lot_number >= '''
            || p_from_lot
            || ''' AND mlgh.lot_number <= '''
            || p_to_lot
            || ''')';
      ELSIF (p_from_lot IS NOT NULL) THEN
         QUERY := QUERY || 'AND mlgh.lot_number >= ''' || p_from_lot || '''';
      ELSIF (p_to_lot IS NOT NULL) THEN
         QUERY := QUERY || 'AND mlgh.lot_number <= ''' || p_to_lot || '''';
      END IF;

      IF (    p_from_date IS NOT NULL
          AND p_to_date IS NOT NULL) THEN
         QUERY := QUERY
            || 'AND (mlgh.grade_update_date >= '''
            || p_from_dt
            || ''' AND mlgh.grade_update_date <= '''
            || p_to_dt
            || ''')';
      ELSIF (p_from_date IS NOT NULL) THEN
         QUERY := QUERY || 'AND mlgh.grade_update_date >= ''' || p_from_date || '''';
      ELSIF (p_to_date IS NOT NULL) THEN
         QUERY := QUERY || 'AND mlgh.grade_update_date <= ''' || p_to_date || '''';
      END IF;

      QUERY := QUERY
         || ' order by mlgh.lot_number, mlgh.grade_update_date) as Lot_details
                                                        FROM org_organization_definitions ood,
                                                                     mtl_system_items_kfv msi
                                                        WHERE ood.organization_id = msi.organization_id
                                                        AND ood.organization_id = '''
         || p_organization_id
         || ''''
         || '
                                                        AND msi.inventory_item_id = '''
         || p_item_id
         || ''''
         || '
                                                        ORDER BY msi.concatenated_segments';

      fnd_file.put_line (fnd_file.LOG, query);

      qryctx := DBMS_XMLGEN.newcontext (QUERY);

      LOOP
         -- now get the result
         v_result := DBMS_XMLGEN.getxml (qryctx);

         -- if there were no rows processed, then quit
         IF v_result IS NULL THEN
            EXIT;
         END IF;

         xml_transfer (p_xml_clob => v_result);
      END LOOP;

      --close context
      DBMS_XMLGEN.closecontext (qryctx);

   EXCEPTION
      WHEN OTHERS THEN
         fnd_file.put_line (fnd_file.LOG, 'Exception in procedure GRADE_CHANGE_HISTORY_REPORT ' || SQLCODE || ' ' || SQLERRM);
   END grade_change_history_report;

/* ***************************************************************
* NAME
*  PROCEDURE - xml_transfer
* PARAMETERS
* DESCRIPTION
*     Procedure used provide the XML as output of the concurrent program.
* HISTORY
*     Namit   31Mar05 - Initial Version
*************************************************************** */
   PROCEDURE xml_transfer (
      p_xml_clob   IN   CLOB) IS

      l_file          CLOB;
      --bug 8238368 kbanddyo increased length of file_varchar2 from 4000 to 32767
      file_varchar2   VARCHAR2 (32767);
      l_len           NUMBER;
      m_len           NUMBER;
      l_limit         NUMBER;
      m_file          CLOB;
      l_xml_header    VARCHAR2(300);  -- Bug 8425698

   BEGIN

      -- Bug 8425698: determine XML encoding
      IF g_xml_encoding = '-9999' THEN
         g_xml_encoding := fnd_profile.value('ICX_CLIENT_IANA_ENCODING');
      END IF;
      l_xml_header := '<?xml version="1.0" encoding="'|| g_xml_encoding ||'"?>';

      l_file  := p_xml_clob;
      l_limit := 1;
      l_len   := DBMS_LOB.getlength (l_file);

      LOOP
         m_file        := DBMS_LOB.SUBSTR(l_file, 4000, l_limit);
         file_varchar2 := TRIM(m_file);
         file_varchar2 := REPLACE(file_varchar2,'<?xml version="1.0"?>',l_xml_header);
         fnd_file.put(fnd_file.output, file_varchar2);
         file_varchar2 := NULL;
         m_file        := NULL;

         IF l_len > l_limit THEN
            l_limit := l_limit + 4000;
         ELSE
            EXIT;
         END IF;
      END LOOP;

   EXCEPTION
      WHEN OTHERS THEN
         fnd_file.put_line (fnd_file.LOG, 'Exception in procedure XML_TRANSFER ' || SQLCODE || ' ' || SQLERRM);
   END xml_transfer;

END inv_xml_reports;

/
