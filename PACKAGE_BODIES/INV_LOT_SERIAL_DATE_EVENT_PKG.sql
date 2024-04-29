--------------------------------------------------------
--  DDL for Package Body INV_LOT_SERIAL_DATE_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_LOT_SERIAL_DATE_EVENT_PKG" AS
/* $Header: INVLSEVB.pls 120.2 2006/06/28 18:28:46 nsinghi noship $ */

PROCEDURE lot_serial_date_notify_cp (
   x_errbuf                   OUT NOCOPY     VARCHAR2
 , x_retcode                  OUT NOCOPY     NUMBER
 , p_organization_id          IN       NUMBER
 , p_structure_id             IN       NUMBER
 , p_category_id              IN       NUMBER
 , p_from_item                IN       VARCHAR2
 , p_to_item                  IN       VARCHAR2
 , p_query_for                IN       VARCHAR2
 , p_from_lot                 IN       VARCHAR2
 , p_to_lot                   IN       VARCHAR2
 , p_from_serial              IN       VARCHAR2
 , p_to_serial                IN       VARCHAR2
 , p_attr_context             IN       VARCHAR2
 , p_date_type                IN       VARCHAR2
 , p_days_in_future           IN       NUMBER
 , p_days_in_past             IN       NUMBER
 , p_include_zero_balance     IN       NUMBER
) AS
   CURSOR cur_lot_template IS
      SELECT mtp.organization_code
           , msi.inventory_item_id
           , msi.concatenated_segments
           , msi.description
           , msi.primary_uom_code
           , msi.secondary_uom_code
           , mln.lot_number
           , mln.gen_object_id
           , ohd.primary_transaction_quantity
           , ohd.secondary_transaction_quantity
           , expiration_date date_column
        FROM mtl_lot_numbers mln
           , mtl_parameters mtp
           , mtl_system_items_kfv msi
           , mtl_onhand_quantities_detail ohd;

   CURSOR cur_serial_template IS
      SELECT mtp.organization_code
           , msi.inventory_item_id
           , msi.concatenated_segments
           , msi.description
           , msi.primary_uom_code
           , msi.secondary_uom_code
           , msn.serial_number
           , msn.gen_object_id
           , msn.current_status
           , mfgl.meaning serial_status
           , msn.initialization_date date_column
        FROM mtl_serial_numbers msn
           , mtl_parameters mtp
           , mtl_system_items_kfv msi
           , mfg_lookups mfgl;

   CURSOR cur_category (
      p_org_id                            NUMBER
    , p_inv_item_id                       NUMBER
    , p_catg_id                           NUMBER
   ) IS
      SELECT mdsv.category_set_id
           , mdsv.category_set_name
           , mdsv.structure_id
           , mcv.category_id
           , mcv.category_concat_segs
        FROM mtl_default_sets_view mdsv
           , mtl_categories_v mcv
           , mtl_item_categories mic
       WHERE mdsv.functional_area_id = 1
         AND mdsv.structure_id = mcv.structure_id
         AND mic.category_set_id = mdsv.category_set_id
         AND mcv.category_id = mic.category_id
         AND mic.organization_id = p_org_id
         AND mic.inventory_item_id = p_inv_item_id
         AND mic.category_id = p_catg_id;

   CURSOR cur_item_category (
      p_org_id                            NUMBER
    , p_inv_item_id                       NUMBER
   ) IS
      SELECT mdsv.category_set_id
           , mdsv.category_set_name
           , mdsv.structure_id
           , mcv.category_id
           , mcv.category_concat_segs
        FROM mtl_default_sets_view mdsv
           , mtl_categories_v mcv
           , mtl_item_categories mic
       WHERE mdsv.functional_area_id = 1
         AND mdsv.structure_id = mcv.structure_id
         AND mic.category_set_id = mdsv.category_set_id
         AND mcv.category_id = mic.category_id
         AND mic.organization_id = p_org_id
         AND mic.inventory_item_id = p_inv_item_id;

   CURSOR cur_item_info (
      p_org_id                            NUMBER
    , p_inv_item_id                       NUMBER
   ) IS
      SELECT mtp.process_enabled_flag
           , msi.process_quality_enabled_flag
        FROM mtl_parameters mtp, mtl_system_items msi
       WHERE mtp.organization_id = p_org_id
         AND mtp.organization_id = msi.organization_id
         AND msi.inventory_item_id = p_inv_item_id;

   TYPE rc IS REF CURSOR;

   l_cursor                   rc;
   l_lot_rec                  cur_lot_template%ROWTYPE;
   l_catg_rec                 cur_category%ROWTYPE;
   l_item_catg_rec            cur_item_category%ROWTYPE;
   l_serial_rec               cur_serial_template%ROWTYPE;
   l_item_info_rec            cur_item_info%ROWTYPE;
   l_catg_rec_found           BOOLEAN;
   l_lot_column_list          VARCHAR2 (2000);
   l_lot_table_list           VARCHAR2 (2000);
   l_lot_where_clause         VARCHAR2 (2000);
   l_lot_group_by             VARCHAR2 (2000);
   l_serial_column_list       VARCHAR2 (2000);
   l_serial_table_list        VARCHAR2 (2000);
   l_serial_where_clause      VARCHAR2 (2000);
   l_onhand_qty_uom           VARCHAR2 (100);
   l_attr_context     fnd_descr_flex_col_usage_vl.descriptive_flex_context_code%TYPE;
   l_attr_ctxt     fnd_descr_flex_col_usage_vl.descriptive_flex_context_code%TYPE;
   l_user_column_name         fnd_descr_flex_col_usage_vl.end_user_column_name%TYPE;
   l_expiration_action_code   mtl_lot_numbers.expiration_action_code%TYPE;
   l_lookup_type              mfg_lookups.lookup_type%TYPE := 'SERIAL_NUM_STATUS';
   l_parameter_list           wf_parameter_list_t  := wf_parameter_list_t();
   l_transaction_id           NUMBER;
   l_user_id                     NUMBER;
   l_ame_transaction_id       VARCHAR2(4000);

BEGIN

   FND_FILE.PUT_LINE ( FND_FILE.LOG, 'Calling LOT_SERIAL_DATE_NOTIFY_CP with values ');
   FND_FILE.PUT_LINE ( FND_FILE.LOG, ' p_organization_id : '||to_char(p_organization_id));
   FND_FILE.PUT_LINE ( FND_FILE.LOG, ' p_structure_id : '||to_char(p_structure_id));
   FND_FILE.PUT_LINE ( FND_FILE.LOG, ' p_category_id : '||to_char(p_category_id));
   FND_FILE.PUT_LINE ( FND_FILE.LOG, ' p_from_item : '||p_from_item);
   FND_FILE.PUT_LINE ( FND_FILE.LOG, ' p_to_item : '||p_to_item);
   FND_FILE.PUT_LINE ( FND_FILE.LOG, ' p_query_for : '||p_query_for);
   FND_FILE.PUT_LINE ( FND_FILE.LOG, ' p_from_lot : '||p_from_lot);
   FND_FILE.PUT_LINE ( FND_FILE.LOG, ' p_to_lot : '||p_to_lot);
   FND_FILE.PUT_LINE ( FND_FILE.LOG, ' p_from_serial : '||p_from_serial);
   FND_FILE.PUT_LINE ( FND_FILE.LOG, ' p_to_serial : '||p_to_serial);
   FND_FILE.PUT_LINE ( FND_FILE.LOG, ' p_attr_context : '||p_attr_context);
   FND_FILE.PUT_LINE ( FND_FILE.LOG, ' p_date_type : '||p_date_type);
   FND_FILE.PUT_LINE ( FND_FILE.LOG, ' p_days_in_future : '||to_char(p_days_in_future));
   FND_FILE.PUT_LINE ( FND_FILE.LOG, ' p_days_in_past : '||to_char(p_days_in_past));
   FND_FILE.PUT_LINE ( FND_FILE.LOG, ' p_include_zero_balance : '||to_char(p_include_zero_balance));

   IF p_attr_context = '-999AAAZZZ' THEN
      l_attr_ctxt := ' ';
   ELSE
      l_attr_ctxt := p_attr_context;
   END IF;

   IF l_attr_ctxt <> ' ' THEN
      SELECT end_user_column_name
        INTO l_user_column_name
        FROM fnd_descr_flex_col_usage_vl
       WHERE application_id = 401
         AND descriptive_flexfield_name =
                DECODE (p_query_for
                      , 'LOT', 'Lot Attributes'
                      , 'Serial Attributes'
                       )
         AND enabled_flag = 'Y'
         AND application_column_name = p_date_type
         AND descriptive_flex_context_code = l_attr_ctxt;
   ELSE
      l_user_column_name := p_date_type;
   END IF;

   IF p_query_for = 'LOT' THEN
      l_lot_column_list :=
            ' mtp.organization_code, '
         || ' msi.inventory_item_id, msi.concatenated_segments, msi.description, '
         || ' msi.primary_uom_code, msi.secondary_uom_code, mln.lot_number, '
         || ' mln.gen_object_id, '
         || ' sum(ohd.primary_transaction_quantity) primary_transaction_quantity, '
         || ' sum(ohd.secondary_transaction_quantity) secondary_transaction_quantity, '
         || p_date_type
         || ' date_column  ';
      l_lot_table_list :=
            ' mtl_lot_numbers mln, mtl_parameters mtp, mtl_system_items_kfv msi, '
         || ' mtl_onhand_quantities_detail ohd ';
      l_lot_where_clause :=
            ' mtp.organization_id = :b_organization_id '
         || ' and mtp.organization_id = msi.organization_id '
         || ' and mln.organization_id = msi.organization_id '
         || ' and mln.inventory_item_id = msi.inventory_item_id '
         || ' and mln.organization_id = ohd.organization_id '
         || ' and mln.inventory_item_id = ohd.inventory_item_id '
         || ' and mln.lot_number = ohd.lot_number '
         || ' AND (mln.lot_number >= NVL (:b_from_lot, mln.lot_number) '
         || ' AND mln.lot_number <= NVL (:b_to_lot, mln.lot_number) ) '
         || ' AND (msi.concatenated_segments >= NVL(:b_from_item, msi.concatenated_segments) '
         || ' AND msi.concatenated_segments <= NVL(:b_to_item, msi.concatenated_segments) ) ';
      l_lot_group_by :=
            ' msi.inventory_item_id, msi.concatenated_segments, msi.description, '
         || ' msi.primary_uom_code, msi.secondary_uom_code, '
         || ' mln.lot_number, mtp.organization_code, mln.gen_object_id, '
         || p_date_type;

      IF     p_days_in_future IS NULL
         AND p_days_in_past IS NULL THEN
         l_lot_where_clause :=
               l_lot_where_clause
            || ' and trunc(mln.'
            || p_date_type
            || ' ) =  trunc(sysdate) ';
      ELSIF     p_days_in_future IS NOT NULL
            AND p_days_in_past IS NOT NULL THEN
         l_lot_where_clause :=
               l_lot_where_clause
            || ' and trunc(mln.'
            || p_date_type
            || ' ) between trunc(sysdate) - '
            || p_days_in_past
            || ' and trunc(sysdate) + '
            || p_days_in_future;
      ELSIF     p_days_in_future IS NOT NULL
            AND p_days_in_past IS NULL THEN
         l_lot_where_clause :=
               l_lot_where_clause
            || ' and trunc(mln.'
            || p_date_type
            || ' ) between trunc(sysdate) and trunc(sysdate) + '
            || p_days_in_future;
      ELSIF     p_days_in_past IS NOT NULL
            AND p_days_in_future IS NULL THEN
         l_lot_where_clause :=
               l_lot_where_clause
            || ' and trunc(mln.'
            || p_date_type
            || ' ) between trunc(sysdate) - '
            || p_days_in_past
            || ' and trunc(sysdate) ';
      END IF;

      IF p_include_zero_balance = 2 THEN
         l_lot_group_by :=
               l_lot_group_by
            || ' having sum(ohd.primary_transaction_quantity) > 0 ';
      END IF;

      IF l_attr_ctxt IN ('Global Data Elements', ' ') THEN
         l_attr_context := NULL;
         l_lot_where_clause :=
               l_lot_where_clause
            || ' and ( mln.lot_attribute_category = NVL(:b_attr_context, mln.lot_attribute_category) '
            || ' OR mln.lot_attribute_category is NULL ) ';
      ELSE
         l_attr_context := l_attr_ctxt;
         l_lot_where_clause :=
               l_lot_where_clause
            || ' and mln.lot_attribute_category = :b_attr_context ';
      END IF;

      OPEN l_cursor
       FOR    'select '
           || l_lot_column_list
           || ' from '
           || l_lot_table_list
           || ' where '
           || l_lot_where_clause
           || ' group by '
           || l_lot_group_by
       USING p_organization_id
           , p_from_lot
           , p_to_lot
           , p_from_item
           , p_to_item
           , l_attr_context;

      LOOP
         FETCH l_cursor
          INTO l_lot_rec;

         EXIT WHEN l_cursor%NOTFOUND;
         l_catg_rec_found := TRUE;

         OPEN cur_item_category (p_organization_id, l_lot_rec.inventory_item_id);

         FETCH cur_item_category
          INTO l_item_catg_rec;

         CLOSE cur_item_category;

         IF p_category_id IS NOT NULL THEN
            OPEN cur_category (p_organization_id
                             , l_lot_rec.inventory_item_id
                             , p_category_id
                              );

            FETCH cur_category
             INTO l_catg_rec;

            CLOSE cur_category;

            IF l_catg_rec.category_id IS NULL THEN
               l_catg_rec_found := FALSE;
            END IF;
         END IF;

         IF p_date_type = 'EXPIRATION_DATE' THEN
            SELECT expiration_action_code
              INTO l_expiration_action_code
              FROM mtl_lot_numbers
             WHERE lot_number = l_lot_rec.lot_number
               AND organization_id = p_organization_id
               AND inventory_item_id = l_lot_rec.inventory_item_id;
         END IF;

         IF l_catg_rec_found THEN
            l_onhand_qty_uom :=
                  TO_CHAR (l_lot_rec.primary_transaction_quantity)
               || ' '
               || l_lot_rec.primary_uom_code
               || ' '
               || TO_CHAR (l_lot_rec.secondary_transaction_quantity)
               || ' '
               || l_lot_rec.secondary_uom_code;

            wf_event.addparametertolist ('ORGANIZATION_CODE'
                                       , l_lot_rec.organization_code
                                       , l_parameter_list
                                        );
            wf_event.addparametertolist ('ORGANIZATION_ID'
                                       , p_organization_id
                                       , l_parameter_list
                                        );
            wf_event.addparametertolist ('ITEM_NUMBER'
                                       , l_lot_rec.concatenated_segments
                                       , l_parameter_list
                                        );
            wf_event.addparametertolist ('ITEM_ID'
                                       , l_lot_rec.inventory_item_id
                                       , l_parameter_list
                                        );
            wf_event.addparametertolist ('ITEM_CATEGORY'
                                       , l_item_catg_rec.category_concat_segs
                                       , l_parameter_list
                                        );
            wf_event.addparametertolist ('CATEGORY_ID'
                                       , l_item_catg_rec.category_id
                                       , l_parameter_list
                                        );
            wf_event.addparametertolist ('QUERY_FOR'
                                       , p_query_for
                                       , l_parameter_list
                                        );
            wf_event.addparametertolist ('LOT_NUMBER'
                                       , l_lot_rec.lot_number
                                       , l_parameter_list
                                        );
            wf_event.addparametertolist ('SERIAL_NUMBER'
                                       , NULL
                                       , l_parameter_list
                                        );
            wf_event.addparametertolist ('DATE_CONTEXT'
                                       , l_attr_ctxt
                                       , l_parameter_list
                                        );
            wf_event.addparametertolist ('DATE_TYPE'
                                       , p_date_type
                                       , l_parameter_list
                                        );
            wf_event.addparametertolist ('USER_DATE_TYPE'
                                       , l_user_column_name
                                       , l_parameter_list
                                        );
            wf_event.addparametertolist ('DATE_VALUE'
                                       , l_lot_rec.date_column
                                       , l_parameter_list
                                        );
            wf_event.addparametertolist ('ACTION_CODE'
                                       , l_expiration_action_code
                                       , l_parameter_list
                                        );
            wf_event.addparametertolist ('SERIAL_STATUS'
                                       , NULL
                                       , l_parameter_list
                                        );
            wf_event.addparametertolist ('ONHAND_QTY_UOM'
                                       , l_onhand_qty_uom
                                       , l_parameter_list
                                        );
            wf_event.addparametertolist ('TRANSACTION_ID'
                                       , l_lot_rec.gen_object_id
                                       , l_parameter_list
                                        );
/*
   FND_FILE.PUT_LINE ( FND_FILE.LOG, 'Raising Lot Event with the following parameters : ');
   FND_FILE.PUT_LINE ( FND_FILE.LOG, ' ORGANIZATION_CODE : '||l_lot_rec.organization_code);
   FND_FILE.PUT_LINE ( FND_FILE.LOG, ' ORGANIZATION_ID : '||to_char(p_organization_id));
   FND_FILE.PUT_LINE ( FND_FILE.LOG, ' ITEM_NUMBER : '||l_lot_rec.concatenated_segments);
   FND_FILE.PUT_LINE ( FND_FILE.LOG, ' ITEM_ID : '||to_char(l_lot_rec.inventory_item_id));
   FND_FILE.PUT_LINE ( FND_FILE.LOG, ' ITEM_CATEGORY : '||l_item_catg_rec.category_concat_segs);
   FND_FILE.PUT_LINE ( FND_FILE.LOG, ' CATEGORY_ID : '||to_char(l_item_catg_rec.category_id));
   FND_FILE.PUT_LINE ( FND_FILE.LOG, ' QUERY_FOR : '||p_query_for);
   FND_FILE.PUT_LINE ( FND_FILE.LOG, ' LOT_NUMBER : '||l_lot_rec.lot_number);
   FND_FILE.PUT_LINE ( FND_FILE.LOG, ' SERIAL_NUMBER : '||NULL);
   FND_FILE.PUT_LINE ( FND_FILE.LOG, ' DATE_CONTEXT : '||l_attr_ctxt);
   FND_FILE.PUT_LINE ( FND_FILE.LOG, ' DATE_TYPE : '||p_date_type);
   FND_FILE.PUT_LINE ( FND_FILE.LOG, ' USER_DATE_TYPE : '||l_user_column_name);
   FND_FILE.PUT_LINE ( FND_FILE.LOG, ' DATE_VALUE : '||to_char(l_lot_rec.date_column, 'dd-mon-yyyy'));
   FND_FILE.PUT_LINE ( FND_FILE.LOG, ' ACTION_CODE : '||l_expiration_action_code);
   FND_FILE.PUT_LINE ( FND_FILE.LOG, ' SERIAL_STATUS : '||NULL);
   FND_FILE.PUT_LINE ( FND_FILE.LOG, ' ONHAND_QTY_UOM : '||l_onhand_qty_uom);
*/
            fnd_file.put_line (fnd_file.log,
                               l_lot_rec.organization_code
                            || ' '
                            || l_lot_rec.concatenated_segments
                            || ' '
                            || l_lot_rec.lot_number
                            || ' '
                            || l_lot_rec.date_column
                           );

            l_user_id := FND_GLOBAL.USER_ID;
            wf_event.RAISE
                  (p_event_name => 'oracle.apps.inv.Date.Notification'
                 , p_parameters => l_parameter_list
                 , p_event_key => TO_CHAR (p_organization_id)
                    || '+-?*'
                    || TO_CHAR (l_lot_rec.inventory_item_id)
                    || '+-?*'
                    || l_lot_rec.lot_number
                    || '+-?*'
                    || p_query_for
                    || '+-?*'
                    || l_item_catg_rec.category_id
                  );
            l_parameter_list.DELETE;

            OPEN cur_item_info (p_organization_id, l_lot_rec.inventory_item_id);

            FETCH cur_item_info
             INTO l_item_info_rec;

            CLOSE cur_item_info;

            IF     l_item_info_rec.process_enabled_flag = 'Y'
               AND NVL (l_item_info_rec.process_quality_enabled_flag, 'N') = 'Y'
               AND p_date_type = 'EXPIRATION_DATE' THEN
	       -- Raise oracle.apps.gmi.lotexpirydate.update and oracle.apps.gmi.lotretestdate.update
	       -- instead of oracle.apps.gmd.lotexpiry and oracle.apps.gmd.lotretest
               wf_event.RAISE
                         (p_event_name => 'oracle.apps.gmi.lotexpirydate.update'
                        , p_event_key => TO_CHAR (p_organization_id)
                           || '-'
                           || TO_CHAR (l_lot_rec.inventory_item_id)
                           || '-'
                           || l_lot_rec.lot_number);
            ELSIF     l_item_info_rec.process_enabled_flag = 'Y'
                  AND NVL (l_item_info_rec.process_quality_enabled_flag, 'N') = 'Y'
                  AND p_date_type = 'RETEST_DATE' THEN
               wf_event.RAISE
                         (p_event_name => 'oracle.apps.gmi.lotretestdate.update'
                        , p_event_key => TO_CHAR (p_organization_id)
                           || '-'
                           || TO_CHAR (l_lot_rec.inventory_item_id)
                           || '-'
                           || l_lot_rec.lot_number);
            END IF;
         END IF;
      END LOOP;

      CLOSE l_cursor;
   ELSIF p_query_for = 'SERIAL' THEN
      l_serial_column_list :=
            ' mtp.organization_code, '
         || ' msi.inventory_item_id, msi.concatenated_segments, msi.description, '
         || ' msi.primary_uom_code, msi.secondary_uom_code, msn.serial_number, '
         || ' msn.gen_object_id, '
         || ' msn.current_status, mfgl.meaning serial_status, '
         || p_date_type
         || ' date_column  ';
      l_serial_table_list :=
            ' mtl_serial_numbers msn, mtl_parameters mtp, mtl_system_items_kfv msi, '
         || ' mfg_lookups mfgl ';
      l_serial_where_clause :=
            ' mtp.organization_id = :b_organization_id '
         || ' and mtp.organization_id = msi.organization_id '
         || ' and msn.current_organization_id = msi.organization_id '
         || ' and msn.inventory_item_id = msi.inventory_item_id '
         || ' AND (msn.serial_number >= NVL (:b_from_serial, msn.serial_number) '
         || ' AND msn.serial_number <= NVL (:b_to_serial, msn.serial_number) ) '
         || ' AND (msi.concatenated_segments >= NVL(:b_from_item, msi.concatenated_segments) '
         || ' AND msi.concatenated_segments <= NVL(:b_to_item, msi.concatenated_segments) ) '
         || ' and msn.current_status = mfgl.lookup_code '
         || ' and mfgl.lookup_type = :b_lookup_type ';

      IF     p_days_in_future IS NULL
         AND p_days_in_past IS NULL THEN
         l_serial_where_clause :=
               l_serial_where_clause
            || ' and trunc(msn.'
            || p_date_type
            || ' ) =  trunc(sysdate) ';
      ELSIF     p_days_in_future IS NOT NULL
            AND p_days_in_past IS NOT NULL THEN
         l_serial_where_clause :=
               l_serial_where_clause
            || ' and trunc(msn.'
            || p_date_type
            || ' ) between trunc(sysdate) - '
            || p_days_in_past
            || ' and trunc(sysdate) + '
            || p_days_in_future;
      ELSIF     p_days_in_future IS NOT NULL
            AND p_days_in_past IS NULL THEN
         l_serial_where_clause :=
               l_serial_where_clause
            || ' and trunc(msn.'
            || p_date_type
            || ' ) between trunc(sysdate) and trunc(sysdate) + '
            || p_days_in_future;
      ELSIF     p_days_in_past IS NOT NULL
            AND p_days_in_future IS NULL THEN
         l_serial_where_clause :=
               l_serial_where_clause
            || ' and trunc(msn.'
            || p_date_type
            || ' ) between trunc(sysdate) - '
            || p_days_in_past
            || ' and trunc(sysdate) ';
      END IF;

      IF p_include_zero_balance = 2 THEN
         l_serial_where_clause :=
                        l_serial_where_clause || ' and msn.current_status = 3 ';
      END IF;

      IF l_attr_ctxt IN ('Global Data Elements', ' ') THEN
         l_attr_context := NULL;
         l_serial_where_clause :=
               l_serial_where_clause
            || ' and ( msn.serial_attribute_category = NVL(:b_attr_context, msn.serial_attribute_category) '
            || ' OR msn.serial_attribute_category is NULL ) ';
      ELSE
         l_attr_context := l_attr_ctxt;
         l_serial_where_clause :=
               l_serial_where_clause
            || ' and msn.serial_attribute_category = :b_attr_context ';
      END IF;

      OPEN l_cursor
       FOR    'select '
           || l_serial_column_list
           || ' from '
           || l_serial_table_list
           || ' where '
           || l_serial_where_clause
       USING p_organization_id
           , p_from_serial
           , p_to_serial
           , p_from_item
           , p_to_item
           , l_lookup_type
           , l_attr_context;

      LOOP
         FETCH l_cursor
          INTO l_serial_rec;

         EXIT WHEN l_cursor%NOTFOUND;
         l_catg_rec_found := TRUE;

         OPEN cur_item_category (p_organization_id, l_lot_rec.inventory_item_id);

         FETCH cur_item_category
          INTO l_item_catg_rec;

         CLOSE cur_item_category;

         IF p_category_id IS NOT NULL THEN
            OPEN cur_category (p_organization_id
                             , l_serial_rec.inventory_item_id
                             , p_category_id
                              );

            FETCH cur_category
             INTO l_catg_rec;

            CLOSE cur_category;

            IF l_catg_rec.category_id IS NULL THEN
               l_catg_rec_found := FALSE;
            END IF;
         END IF;

         IF l_catg_rec_found THEN
            wf_event.addparametertolist ('ORGANIZATION_CODE'
                                       , l_serial_rec.organization_code
                                       , l_parameter_list
                                        );
            wf_event.addparametertolist ('ORGANIZATION_ID'
                                       , p_organization_id
                                       , l_parameter_list
                                        );
            wf_event.addparametertolist ('ITEM_NUMBER'
                                       , l_serial_rec.concatenated_segments
                                       , l_parameter_list
                                        );
            wf_event.addparametertolist ('ITEM_ID'
                                       , l_serial_rec.inventory_item_id
                                       , l_parameter_list
                                        );
            wf_event.addparametertolist ('ITEM_CATEGORY'
                                       , l_item_catg_rec.category_concat_segs
                                       , l_parameter_list
                                        );
            wf_event.addparametertolist ('CATEGORY_ID'
                                       , l_item_catg_rec.category_id
                                       , l_parameter_list
                                        );
            wf_event.addparametertolist ('QUERY_FOR'
                                       , p_query_for
                                       , l_parameter_list
                                        );
            wf_event.addparametertolist ('LOT_NUMBER'
                                       , NULL
                                       , l_parameter_list
                                        );
            wf_event.addparametertolist ('SERIAL_NUMBER'
                                       , l_serial_rec.serial_number
                                       , l_parameter_list
                                        );
            wf_event.addparametertolist ('DATE_CONTEXT'
                                       , l_attr_ctxt
                                       , l_parameter_list
                                        );
            wf_event.addparametertolist ('DATE_TYPE'
                                       , p_date_type
                                       , l_parameter_list
                                        );
            wf_event.addparametertolist ('USER_DATE_TYPE'
                                       , l_user_column_name
                                       , l_parameter_list
                                        );
            wf_event.addparametertolist ('DATE_VALUE'
                                       , l_serial_rec.date_column
                                       , l_parameter_list
                                        );
            wf_event.addparametertolist ('ACTION_CODE'
                                       , NULL
                                       , l_parameter_list
                                        );
            wf_event.addparametertolist ('SERIAL_STATUS'
                                       , l_serial_rec.serial_status
                                       , l_parameter_list
                                        );
            wf_event.addparametertolist ('ONHAND_QTY_UOM'
                                       , NULL
                                       , l_parameter_list
                                        );
            wf_event.addparametertolist ('TRANSACTION_ID'
                                       , l_serial_rec.gen_object_id
                                       , l_parameter_list
                                        );

            l_user_id := FND_GLOBAL.USER_ID;

            fnd_file.put_line (fnd_file.log,
                               l_serial_rec.organization_code
                            || ' '
                            || l_serial_rec.concatenated_segments
                            || ' '
                            || l_serial_rec.serial_number
                            || ' '
                            || l_serial_rec.date_column
                           );

            wf_event.RAISE
                  (p_event_name => 'oracle.apps.inv.Date.Notification'
                 , p_parameters => l_parameter_list
                 , p_event_key => TO_CHAR (p_organization_id)
                    || '+-?*'
                    || TO_CHAR (l_serial_rec.inventory_item_id)
                    || '+-?*'
                    || l_serial_rec.serial_number
                    || '+-?*'
                    || p_query_for
                    || '+-?*'
                    || l_item_catg_rec.category_id
                  );
            l_parameter_list.DELETE;
         END IF;
      END LOOP;

      CLOSE l_cursor;
   END IF;

END lot_serial_date_notify_cp;

END INV_LOT_SERIAL_DATE_EVENT_PKG;

/
