--------------------------------------------------------
--  DDL for Package Body INV_MWB_QUERY_MANAGER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_MWB_QUERY_MANAGER" AS
/* $Header: INVMWQMB.pls 120.71.12010000.15 2010/04/15 14:57:07 ptian ship $ */

  TYPE DateBindRec IS RECORD(bind_name VARCHAR2(50), bind_value DATE);
  TYPE VarcharBindRec IS RECORD(bind_name VARCHAR2(50), bind_value VARCHAR2(255));
  TYPE NumberBindRec IS RECORD(bind_name VARCHAR2(50), bind_value NUMBER);

  TYPE DateBindRecTab IS TABLE OF DateBindRec INDEX BY PLS_INTEGER;
  TYPE VarcharBindRecTab IS TABLE OF VarcharBindRec INDEX BY PLS_INTEGER;
  TYPE NumberBindRecTab IS TABLE OF NumberBindRec INDEX BY PLS_INTEGER;

  g_date_bind_tab      DateBindRecTab;
  g_number_bind_tab    NumberBindRecTab;
  g_varchar_bind_tab   VarcharBindRecTab;

  g_date_bind_index    PLS_INTEGER;
  g_varchar_bind_index PLS_INTEGER;
  g_number_bind_index  PLS_INTEGER;

  g_pkg_name CONSTANT VARCHAR2(30) := 'INV_MWB_QUERY_MANAGER';

  g_initialize BOOLEAN;

  g_onhand_where_index PLS_INTEGER;
  g_onhand_from_index  PLS_INTEGER;
  g_onhand_group_index PLS_INTEGER;

  g_onhand_1_where_index PLS_INTEGER;
  g_onhand_1_from_index  PLS_INTEGER;
  g_onhand_1_group_index PLS_INTEGER;

  g_inbound_where_index PLS_INTEGER;
  g_inbound_from_index  PLS_INTEGER;
  g_inbound_group_index PLS_INTEGER;

  g_inbound_1_where_index PLS_INTEGER;
  g_inbound_1_from_index  PLS_INTEGER;
  g_inbound_1_group_index PLS_INTEGER;

  g_receiving_1_where_index PLS_INTEGER;
  g_receiving_1_from_index  PLS_INTEGER;
  g_receiving_1_group_index PLS_INTEGER;

  g_receiving_where_index PLS_INTEGER;
  g_receiving_from_index  PLS_INTEGER;
  g_receiving_group_index PLS_INTEGER;

  FUNCTION build_query RETURN VARCHAR2;
  PROCEDURE bind_query(p_cursor_handle IN NUMBER);

  FUNCTION build_onhand_query RETURN VARCHAR2;
  FUNCTION build_inbound_query RETURN VARCHAR2;
  FUNCTION build_receiving_query RETURN VARCHAR2;
  PROCEDURE build_onhand_qf_where;
  PROCEDURE post_query;

  PROCEDURE add_bind_variable(p_bind_name VARCHAR2, p_bind_value DATE) IS
     l_date_bind_rec DateBindRec;
     l_procedure_name VARCHAR2(30);
  BEGIN
     IF g_date_bind_index IS NULL THEN
        g_date_bind_index := 1;
     END IF;
     l_date_bind_rec.bind_name  := p_bind_name;
     l_date_bind_rec.bind_value := p_bind_value;
     inv_mwb_globals.print_msg(g_pkg_name, l_procedure_name, ' Bind Variable : '||p_bind_name||' Bind Value : '||to_char(p_bind_value));
     g_date_bind_tab(g_date_bind_index) := l_date_bind_rec;
     g_date_bind_index := g_date_bind_index + 1;
  END add_bind_variable;

  PROCEDURE add_bind_variable(p_bind_name VARCHAR2, p_bind_value NUMBER) IS
     l_number_bind_rec NumberBindRec;
     l_procedure_name VARCHAR2(30);
  BEGIN
     IF g_number_bind_index IS NULL THEN
        g_number_bind_index := 1;
     END IF;
     l_number_bind_rec.bind_name  := p_bind_name;
     l_number_bind_rec.bind_value := p_bind_value;
     inv_mwb_globals.print_msg(g_pkg_name, l_procedure_name, ' Bind Variable : '||p_bind_name||' Bind Value : '||p_bind_value);
     g_number_bind_tab(g_number_bind_index) := l_number_bind_rec;
     g_number_bind_index := g_number_bind_index + 1;
  END add_bind_variable;

  PROCEDURE add_bind_variable(p_bind_name VARCHAR2, p_bind_value VARCHAR2) IS
     l_varchar_bind_rec VarcharBindRec;
     l_procedure_name VARCHAR2(30);
  BEGIN
     IF g_varchar_bind_index IS NULL THEN
        g_varchar_bind_index := 1;
     END IF;
     l_varchar_bind_rec.bind_name  := p_bind_name;
     l_varchar_bind_rec.bind_value := p_bind_value;
     inv_mwb_globals.print_msg(g_pkg_name, l_procedure_name, ' Bind Variable : '||p_bind_name||' Bind Value : '||p_bind_value);
     g_varchar_bind_tab(g_varchar_bind_index) := l_varchar_bind_rec;
     g_varchar_bind_index := g_varchar_bind_index + 1;
  END add_bind_variable;

  FUNCTION build_insert(p_columns IN SelectColumnTabType) RETURN VARCHAR2 IS
     l_insert_str     inv_mwb_globals.long_str;
     l_temp           inv_mwb_globals.short_str;
     l_pos            NUMBER;
     l_procedure_name VARCHAR2(30);
  BEGIN

     l_procedure_name := 'BUILD_INSERT';
     inv_mwb_globals.print_msg(g_pkg_name, l_procedure_name, 'Entered');
     l_insert_str := 'INSERT INTO mtl_mwb_gtmp (';
--     inv_mwb_globals.print_msg(g_pkg_name, l_procedure_name, l_insert_str);
     l_pos := p_columns.FIRST;
     WHILE l_pos IS NOT NULL LOOP
        IF l_pos = p_columns.FIRST THEN
           l_temp := p_columns(l_pos).column_name;
        ELSE
           l_temp := ' , '||p_columns(l_pos).column_name;
        END IF;
--        inv_mwb_globals.print_msg(g_pkg_name, l_procedure_name, l_temp);
        l_insert_str := l_insert_str||l_temp;
        l_pos := p_columns.NEXT(l_pos);
     END LOOP;

     l_insert_str := l_insert_str || ' ) ';
     inv_mwb_globals.print_msg(g_pkg_name, l_procedure_name, ' ) ');

     RETURN l_insert_str;

  END build_insert;

  FUNCTION build_query(
                 p_select_columns IN SelectColumnTabType
                ,p_from_clause    IN SQLClauseTabType
                ,p_where_clause   IN SQLClauseTabType
                ,p_group_clause   IN SQLClauseTabType
                   ) RETURN VARCHAR2 IS
     l_query_str      inv_mwb_globals.very_long_str;
     l_procedure_name VARCHAR2(30);
     i                PLS_INTEGER;
     j                PLS_INTEGER;
     l_temp           inv_mwb_globals.short_str;
     l_default_status_id    NUMBER; -- Onhand Material Status Support
     l_if_msn Number :=0; --Bug 7611434

  BEGIN

     l_procedure_name := 'BUILD_QUERY';
     inv_mwb_globals.print_msg(g_pkg_name, l_procedure_name, 'Entered');

     IF p_select_columns.COUNT > 0 THEN

        i := p_select_columns.FIRST;
        WHILE i IS NOT NULL LOOP

           IF i = p_select_columns.FIRST THEN
              l_query_str := 'SELECT ';
              l_temp := p_select_columns(i).column_value||' '||p_select_columns(i).column_name;
           ELSE
              l_temp := ' , '||p_select_columns(i).column_value||' '||p_select_columns(i).column_name;
           END IF;
           inv_mwb_globals.print_msg(g_pkg_name, l_procedure_name, l_temp);
           l_query_str := l_query_str || l_temp;

           i := p_select_columns.NEXT(i);
        END LOOP;

     END IF;

     IF p_from_clause.COUNT > 0 THEN

        j := p_from_clause.FIRST;
        WHILE j IS NOT NULL LOOP
           IF j = p_from_clause.FIRST THEN
              l_query_str := l_query_str||' FROM ';
              l_temp := p_from_clause(j);
           ELSE
              l_temp :=  ' , '||p_from_clause(j);
           END IF;
           l_query_str := l_query_str || l_temp;
           inv_mwb_globals.print_msg(g_pkg_name, l_procedure_name, l_temp);
           j := p_from_clause.NEXT(j);
        END LOOP;

     END IF;

     IF p_where_clause.COUNT > 0 THEN

        j := p_where_clause.FIRST;
        WHILE j IS NOT NULL LOOP
           IF j = p_where_clause.FIRST THEN
              l_query_str := l_query_str||' WHERE 1 = 1 ';
           END IF;
           l_temp := ' AND ' || p_where_clause(j);
           l_query_str := l_query_str || l_temp;
           inv_mwb_globals.print_msg(g_pkg_name, l_procedure_name, l_temp);
           j := p_where_clause.NEXT(j);
        END LOOP;

     END IF;

     IF p_group_clause.COUNT > 0 THEN

        j := p_group_clause.FIRST;
        WHILE j IS NOT NULL LOOP
           IF j = p_group_clause.FIRST THEN
              l_query_str := l_query_str||' GROUP BY ';
              l_temp := p_group_clause(j);
           ELSE
              l_temp := ' , '|| p_group_clause(j);
           END IF;
           inv_mwb_globals.print_msg(g_pkg_name, l_procedure_name, l_temp);
           l_query_str := l_query_str || l_temp;
           j := p_group_clause.NEXT(j);
        END LOOP;

     END IF;

      --IF inv_mwb_globals.g_tree_node_type = 'APPTREE_OBJECT_TRUNK' THEN
      --Modified above IF ... THEN for bug 7611434
      IF inv_mwb_globals.g_tree_node_type IN ('APPTREE_OBJECT_TRUNK','LOC','SUB','MATLOC','ORG') THEN
         IF inv_mwb_globals.g_chk_onhand = 1
         AND NVL(inv_mwb_globals.g_chk_receiving,0) = 0
         AND NVL(inv_mwb_globals.g_chk_inbound,0) = 0 THEN

            IF inv_mwb_globals.g_qty_from IS NOT NULL
            OR inv_mwb_globals.g_qty_to IS NOT NULL THEN

               l_query_str := l_query_str || ' HAVING 1 = 1 ';

--               IF inv_mwb_globals.g_view_by <> 'LPN' THEN
                  IF inv_mwb_globals.g_serial_from IS NULL
                  AND inv_mwb_globals.g_serial_to IS NULL
                  AND inv_mwb_globals.g_view_by <> 'SERIAL' THEN

                     --Bug 7611434 Begin
                     begin
                          Select instr(upper(l_query_str),'MTL_SERIAL_NUMBERS',1)
                            into l_if_msn
                            from dual;
                     exception
                            when others then
                                 l_if_msn := 0;
                     end;
                     --Bug 7611434 End

                  if l_if_msn = 0 THEN --Added by Bug 7611434

                     IF NVL(inv_mwb_globals.g_qty_from,-100) = NVL(inv_mwb_globals.g_qty_to,-200) THEN
                        l_query_str := l_query_str || ' AND SUM (MOQD.PRIMARY_TRANSACTION_QUANTITY) = :onhand_qty';
                     END IF;
                     IF inv_mwb_globals.g_qty_from IS NOT NULL THEN
                        l_query_str := l_query_str || ' AND SUM (MOQD.PRIMARY_TRANSACTION_QUANTITY) >= :onhand_from_qty';
                     END IF;
                     IF inv_mwb_globals.g_qty_to IS NOT NULL THEN
                        l_query_str := l_query_str || ' AND SUM (MOQD.PRIMARY_TRANSACTION_QUANTITY) <= :onhand_to_qty';
                     END IF;

                  --Added by Bug 7611434 BEGIN
                  else

                     IF NVL(inv_mwb_globals.g_qty_from,-100) = NVL(inv_mwb_globals.g_qty_to,-200) THEN
                        l_query_str := l_query_str || ' AND count(1) = :onhand_qty';
                     END IF;
                     IF inv_mwb_globals.g_qty_from IS NOT NULL THEN
                        l_query_str := l_query_str || ' AND count(1) >= :onhand_from_qty';
                     END IF;
                     IF inv_mwb_globals.g_qty_to IS NOT NULL THEN
                        l_query_str := l_query_str || ' AND count(1) <= :onhand_to_qty';
                     END IF;

                  end if;
                  --Added by Bug 7611434 END


                  ELSIF inv_mwb_globals.g_serial_from IS NOT NULL
                  OR inv_mwb_globals.g_serial_to IS NOT NULL
                  OR inv_mwb_globals.g_view_by = 'SERIAL' THEN
                     IF NVL(inv_mwb_globals.g_qty_from,-100) = NVL(inv_mwb_globals.g_qty_to,-200) THEN
                        l_query_str := l_query_str || ' AND count(1) = :onhand_qty';
                     END IF;
                     IF inv_mwb_globals.g_qty_from IS NOT NULL THEN
                        l_query_str := l_query_str || ' AND count(1) >= :onhand_from_qty ';
                     END IF;
                     IF inv_mwb_globals.g_qty_to IS NOT NULL THEN
                        l_query_str := l_query_str || ' AND count(1) <= :onhand_to_qty ';
                     END IF;
                  END IF;
/*               ELSIF inv_mwb_globals.g_view_by = 'LPN' THEN
                  IF NVL(inv_mwb_globals.g_qty_from,-100) = NVL(inv_mwb_globals.g_qty_to,-200) THEN
                     l_query_str := l_query_str || ' AND SUM(wlc.primary_quantity) = :onhand_qty';
                  END IF;
                  IF inv_mwb_globals.g_qty_from IS NOT NULL THEN
                     l_query_str := l_query_str || ' AND SUM(wlc.primary_quantity) >= :onhand_from_qty ';
                  END IF;
                  IF inv_mwb_globals.g_qty_to IS NOT NULL THEN
                     l_query_str := l_query_str || ' AND SUM(wlc.primary_quantity) <= :onhand_to_qty ';
                  END IF;
               END IF;
*/
               IF NVL(inv_mwb_globals.g_qty_from,-100) = NVL(inv_mwb_globals.g_qty_to,-200) THEN
                  add_bind_variable('onhand_qty',inv_mwb_globals.g_qty_from);
               END IF;
               IF inv_mwb_globals.g_qty_from IS NOT NULL THEN
                  add_bind_variable('onhand_from_qty',inv_mwb_globals.g_qty_from);
               END IF;
               IF inv_mwb_globals.g_qty_to IS NOT NULL THEN
                  add_bind_variable('onhand_to_qty',inv_mwb_globals.g_qty_to);
               END IF;

            END IF;

         END IF;  -- Onhand quantity queries

         IF inv_mwb_globals.g_chk_inbound = 1
         AND NVL(inv_mwb_globals.g_chk_receiving,0) = 0
         AND NVL(inv_mwb_globals.g_chk_onhand,0) = 0 THEN

           IF inv_mwb_globals.g_qty_from IS NOT NULL
           OR inv_mwb_globals.g_qty_to IS NOT NULL THEN
              l_query_str := l_query_str || ' HAVING 1 = 1 ';
              IF NVL(inv_mwb_globals.g_qty_from,-100) = NVL(inv_mwb_globals.g_qty_to,-200) THEN
                 l_query_str := l_query_str || ' AND SUM(ms.to_org_primary_quantity) = :inbound_qty';
                 add_bind_variable('inbound_qty',inv_mwb_globals.g_qty_from);
              END IF;
              IF inv_mwb_globals.g_qty_from IS NOT NULL THEN
                 l_query_str := l_query_str || ' AND SUM(ms.to_org_primary_quantity) >= :inbound_qty_from';
                 add_bind_variable('inbound_qty_from',inv_mwb_globals.g_qty_from);
              END IF;
              IF inv_mwb_globals.g_qty_to IS NOT NULL THEN
                 l_query_str := l_query_str || ' AND SUM(ms.to_org_primary_quantity) <= :inbound_qty_to';
                 add_bind_variable('inbound_qty_to',inv_mwb_globals.g_qty_to);
              END IF;
           END IF;
         END IF;  -- Inbound quantity queries

         IF inv_mwb_globals.g_chk_receiving = 1
         AND NVL(inv_mwb_globals.g_chk_onhand,0) = 0
         AND NVL(inv_mwb_globals.g_chk_inbound,0) = 0 THEN

            IF inv_mwb_globals.g_qty_from IS NOT NULL
            OR inv_mwb_globals.g_qty_to IS NOT NULL THEN
               l_query_str := l_query_str || ' HAVING 1 = 1';

--               IF inv_mwb_globals.g_view_by = 'LOCATION' THEN
                  IF NVL(inv_mwb_globals.g_qty_from,-100) = NVL(inv_mwb_globals.g_qty_to,-200) THEN
                    l_query_str := l_query_str || ' AND SUM(rs.to_org_primary_quantity) = :receiving_qty ';
                  END IF;
                  IF inv_mwb_globals.g_qty_from IS NOT NULL THEN
                    l_query_str := l_query_str || ' AND SUM(rs.to_org_primary_quantity) >= :receiving_from_qty ';
                  END IF;
                  IF inv_mwb_globals.g_qty_to IS NOT NULL THEN
                    l_query_str := l_query_str || ' AND SUM(rs.to_org_primary_quantity) <= :receiving_to_qty ';
                  END IF;
/*               ELSIF inv_mwb_globals.g_view_by = 'LPN' THEN
                  IF NVL(inv_mwb_globals.g_qty_from,-100) = NVL(inv_mwb_globals.g_qty_to,-200) THEN
                    l_query_str := l_query_str || ' AND SUM(wlc.primary_quantity) = :receiving_qty';
                  END IF;
                  IF inv_mwb_globals.g_qty_from IS NOT NULL THEN
                    l_query_str := l_query_str || ' AND SUM(wlc.primary_quantity) >= :receiving_from_qty';
                  END IF;
                  IF inv_mwb_globals.g_qty_to IS NOT NULL THEN
                    l_query_str := l_query_str || ' AND SUM(wlc.primary_quantity) <= :receiving_to_qty';
                  END IF;
               END IF;
*/

               IF NVL(inv_mwb_globals.g_qty_from,-100) = NVL(inv_mwb_globals.g_qty_to,-200) THEN
                 add_bind_variable('receiving_qty',inv_mwb_globals.g_qty_from);
               END IF;
               IF inv_mwb_globals.g_qty_from IS NOT NULL THEN
                 add_bind_variable('receiving_from_qty',inv_mwb_globals.g_qty_from);
               END IF;
               IF inv_mwb_globals.g_qty_to IS NOT NULL THEN
                 add_bind_variable('receiving_to_qty',inv_mwb_globals.g_qty_to);
               END IF;
            END IF;
         END IF;  -- Receiving quantities query
      END IF; /* inv_mwb_globals.g_tree_node_type = 'APPTREE_OBJECT_TRUNK' */

      -- Onhand Material Status Support
      if(inv_mwb_globals.g_view_by = 'STATUS' AND inv_mwb_globals.g_tree_node_type = 'ONHAND_FOLDER') then
           l_query_str := l_query_str || ' ORDER BY moqd.organization_id, moqd.inventory_item_id, moqd.revision, moqd.subinventory_code, moqd.locator_id, moqd.lot_number ';
      end if;

   RETURN l_query_str;
   END build_query;


  PROCEDURE execute_query IS

     TYPE TempRecCurTyp IS REF CURSOR;

     l_query_str      inv_mwb_globals.very_long_str;
     l_cursor_handle  NUMBER;
     l_rows_affected  NUMBER;

     l_procedure_name VARCHAR2(30);
  BEGIN

     l_procedure_name := 'EXECUTE_QUERY';
     inv_mwb_globals.print_msg(g_pkg_name, l_procedure_name, 'Entered');

     l_query_str := build_query;

     inv_mwb_globals.g_last_query := l_query_str;

/*     delete from rtest1;
     insert into rtest1 values(l_query_str);
     commit;
*/

     l_cursor_handle := dbms_sql.open_cursor;
     dbms_sql.parse(l_cursor_handle, l_query_str, dbms_sql.native);
     bind_query(l_cursor_handle);

     l_rows_affected := dbms_sql.execute(l_cursor_handle);
     inv_mwb_globals.print_msg(g_pkg_name, l_procedure_name, 'Rows created' ||l_rows_affected);
     dbms_sql.close_cursor(l_cursor_handle);
     post_query; -- Updates id to names.

  END execute_query;

  FUNCTION build_query RETURN VARCHAR2 IS
     l_query_str inv_mwb_globals.very_long_str;
     l_procedure_name VARCHAR2(30);
     l_rev_control    NUMBER; -- Bug 6060233
     l_lot_control    NUMBER; -- Bug 6060233
     l_serial_control NUMBER; -- Bug 6060233
     l_lot_controlled    NUMBER := 0; -- Onhand Material Status Support
     l_serial_controlled    NUMBER := 0; -- Onhand Material Status Support
     l_default_status_id    NUMBER; -- Onhand Material Status Support
  BEGIN

     l_procedure_name := 'BUILD_QUERY';
     inv_mwb_globals.print_msg(g_pkg_name, l_procedure_name, 'Entered');

     IF (( NVL(inv_mwb_globals.g_chk_onhand, 0) = 1 AND
          NVL(inv_mwb_globals.g_chk_inbound, 0) = 0 AND
          NVL(inv_mwb_globals.g_chk_receiving, 0) = 0 ) OR
	  NVL(inv_mwb_globals.g_tree_mat_loc_id, 0) = 1) OR
	  (inv_mwb_globals.g_chk_onhand = 0 AND
           inv_mwb_globals.g_chk_receiving = 0 AND
           inv_mwb_globals.g_chk_inbound = 0 AND
           inv_mwb_globals.g_view_by = 'LPN') THEN


          l_query_str := build_insert(g_onhand_select);
          l_query_str := l_query_str || build_query(
                                              g_onhand_select,
                                              g_onhand_from,
                                              g_onhand_where,
                                              g_onhand_group
                                              );




         -- Bug 6060233
            IF (inv_mwb_globals.g_status_id IS NOT NULL) THEN

              IF (inv_mwb_globals.g_view_by = 'LOCATION') THEN

               initialize_onhand_query;
               l_query_str := l_query_str || ' UNION ';

               CASE inv_mwb_globals.g_tree_node_type

                  WHEN 'APPTREE_OBJECT_TRUNK' THEN

                      INV_MWB_LOCATION_TREE.make_common_query_onhand('MOQD');

                      IF inv_mwb_globals.g_detailed = 1 THEN
                         inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SUBINVENTORY_CODE).column_value :=
                         'moqd.subinventory_code';
                         inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOCATOR_ID).column_value :=
                         'moqd.locator_id';
                         inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.REVISION).column_value :=
                         'moqd.revision';

                         inv_mwb_query_manager.add_group_clause('moqd.subinventory_code', 'ONHAND');
                         inv_mwb_query_manager.add_group_clause('moqd.locator_id', 'ONHAND');
                         inv_mwb_query_manager.add_group_clause('moqd.revision', 'ONHAND');
                      END IF;

                      add_qf_where_onhand('ONHAND');

                  WHEN 'ORG' THEN

                      INV_MWB_LOCATION_TREE.make_common_query_onhand('MOQD');

                      inv_mwb_query_manager.add_where_clause('moqd.organization_id = :onh_tree_organization_id', 'ONHAND');
                      inv_mwb_query_manager.add_bind_variable('onh_tree_organization_id', inv_mwb_globals.g_tree_organization_id);
                      inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SUBINVENTORY_CODE).column_value :=
                      'moqd.subinventory_code';
                      inv_mwb_query_manager.add_group_clause('moqd.subinventory_code', 'ONHAND');

                      add_qf_where_onhand('ONHAND');

                  WHEN 'MATLOC' THEN

                      INV_MWB_LOCATION_TREE.make_common_query_onhand('MOQD');
                      inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SUBINVENTORY_CODE).column_value :=
                      'moqd.subinventory_code';
                      inv_mwb_query_manager.add_group_clause('moqd.subinventory_code', 'ONHAND');
                      inv_mwb_query_manager.add_where_clause('moqd.organization_id = :onh_tree_organization_id', 'ONHAND');
                      inv_mwb_query_manager.add_bind_variable('onh_tree_organization_id', inv_mwb_globals.g_tree_organization_id);
                      add_qf_where_onhand('ONHAND');

                  WHEN 'SUB' THEN

                      INV_MWB_LOCATION_TREE.make_common_query_onhand('MOQD');

                      inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SUBINVENTORY_CODE).column_value :=
                      'moqd.subinventory_code';
                      inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOCATOR_ID).column_value :=
                      'moqd.locator_id';

                      inv_mwb_query_manager.add_group_clause('moqd.subinventory_code', 'ONHAND');
                      inv_mwb_query_manager.add_group_clause('moqd.locator_id', 'ONHAND');

                      inv_mwb_query_manager.add_where_clause('moqd.organization_id = :onh_tree_organization_id', 'ONHAND');
                      inv_mwb_query_manager.add_where_clause('moqd.subinventory_code = :onh_tree_subinventory_code', 'ONHAND');

                      inv_mwb_query_manager.add_bind_variable('onh_tree_organization_id', inv_mwb_globals.g_tree_organization_id);
                      inv_mwb_query_manager.add_bind_variable('onh_tree_subinventory_code', inv_mwb_globals.g_tree_subinventory_code);

                      add_qf_where_onhand('ONHAND');

                  WHEN 'LOC' THEN
                      INV_MWB_LOCATION_TREE.make_common_query_onhand('MOQD');

                      inv_mwb_query_manager.add_where_clause('moqd.organization_id = :onh_tree_organization_id', 'ONHAND');
                      inv_mwb_query_manager.add_where_clause('moqd.subinventory_code = :onh_tree_subinventory_code', 'ONHAND');
                      inv_mwb_query_manager.add_where_clause('moqd.locator_id = :onh_tree_loc_id', 'ONHAND');

                      inv_mwb_query_manager.add_bind_variable('onh_tree_organization_id', inv_mwb_globals.g_tree_organization_id);
                      inv_mwb_query_manager.add_bind_variable('onh_tree_subinventory_code', inv_mwb_globals.g_tree_subinventory_code);
                      inv_mwb_query_manager.add_bind_variable('onh_tree_loc_id', inv_mwb_globals.g_tree_loc_id);

                      inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SUBINVENTORY_CODE).column_value :=
                      'moqd.subinventory_code';
                      inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOCATOR_ID).column_value :=
                      'moqd.locator_id';
                      inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LPN_ID).column_value :=
                      'moqd.lpn_id';
	              inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.CG_ID).column_value :=
                      'moqd.cost_group_id';

                      inv_mwb_query_manager.add_group_clause('moqd.subinventory_code', 'ONHAND');
                      inv_mwb_query_manager.add_group_clause('moqd.locator_id', 'ONHAND');
                      inv_mwb_query_manager.add_group_clause('moqd.lpn_id', 'ONHAND');
                      inv_mwb_query_manager.add_group_clause('moqd.cost_group_id', 'ONHAND');

                      add_qf_where_onhand('ONHAND');

                  WHEN 'ITEM' THEN
                      SELECT revision_qty_control_code,
                             lot_control_code,
                             serial_number_control_code
                      INTO   l_rev_control,
                             l_lot_control,
                             l_serial_control
                      FROM mtl_system_items
                      WHERE inventory_item_id = inv_mwb_globals.g_tree_item_id
                      AND organization_id = inv_mwb_globals.g_tree_organization_id;

                      inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.CG_ID).column_value :=
                      'moqd.cost_group_id';
                      inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SUBINVENTORY_CODE).column_value :=
                      'moqd.subinventory_code';
                      inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOCATOR_ID).column_value :=
                      'moqd.locator_id';
                      inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LPN_ID).column_value :=
                      'moqd.lpn_id';

                      inv_mwb_query_manager.add_group_clause('moqd.subinventory_code', 'ONHAND');
                      inv_mwb_query_manager.add_group_clause('moqd.locator_id', 'ONHAND');
                      inv_mwb_query_manager.add_group_clause('moqd.lpn_id', 'ONHAND');
                      inv_mwb_query_manager.add_group_clause('moqd.cost_group_id', 'ONHAND');

                      -- Onhand Material Status Support
                      -- For serial controlled items, the status_id will be populated in post_query of IMVMWQMB.
                      if (inv_cache.set_org_rec(inv_mwb_globals.g_tree_organization_id)) then
                           l_default_status_id :=  inv_cache.org_rec.default_status_id;
                      end if;

                      if inv_cache.set_item_rec(inv_mwb_globals.g_tree_organization_id, inv_mwb_globals.g_tree_item_id) then
                        if (inv_cache.item_rec.serial_number_control_code in (2,5)) then
                             l_serial_controlled := 1; -- Item is serial controlled
                        end if;

                        if (inv_cache.item_rec.lot_control_code <> 1) then
                             l_lot_controlled := 1; -- Item is lot controlled
                        end if;
                      end if;

                      if (l_default_status_id is not null and l_serial_controlled = 0 and l_lot_controlled = 0) then
                        inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.STATUS_ID).column_value :=
                        'moqd.status_id';
                        inv_mwb_query_manager.add_group_clause('moqd.status_id', 'ONHAND');
                      end if;
                      -- End Onhand Material Status Support

                      IF inv_mwb_globals.g_tree_parent_lpn_id IS NOT NULL THEN
                           inv_mwb_query_manager.add_where_clause(
                                                   'moqd.lpn_id = :onh_tree_lpn_id' ,
                                                   'ONHAND'
                                                   );
                      ELSE
                           inv_mwb_query_manager.add_where_clause(
                                                   'moqd.lpn_id IS NULL' ,
                                                   'ONHAND'
                                                   );
                      END IF;

                      IF inv_mwb_globals.g_tree_loc_id IS NOT NULL THEN
                           inv_mwb_query_manager.add_where_clause(
                                                   'moqd.locator_id = :onh_tree_loc_id' ,
                                                   'ONHAND'
                                                   );
                      ELSE
                           inv_mwb_query_manager.add_where_clause(
                                                   'moqd.locator_id IS NULL' ,
                                                   'ONHAND'
                                                   );
                      END IF;

                      IF inv_mwb_globals.g_tree_subinventory_code IS NOT NULL THEN
                           inv_mwb_query_manager.add_where_clause(
                                                   'moqd.subinventory_code = :onh_tree_sub_code' ,
                                                   'ONHAND'
                                                   );
                      END IF;

                      IF inv_mwb_globals.g_tree_parent_lpn_id IS NOT NULL THEN
                           inv_mwb_query_manager.add_bind_variable(
                                                'onh_tree_lpn_id',
                                                inv_mwb_globals.g_tree_parent_lpn_id
                                                );
                      END IF;

                      IF inv_mwb_globals.g_tree_loc_id IS NOT NULL THEN
                           inv_mwb_query_manager.add_bind_variable(
                                                'onh_tree_loc_id',
                                                inv_mwb_globals.g_tree_loc_id
                                                );
                      END IF;

                      IF inv_mwb_globals.g_tree_subinventory_code IS NOT NULL THEN
                           inv_mwb_query_manager.add_bind_variable(
                                                'onh_tree_sub_code',
                                                inv_mwb_globals.g_tree_subinventory_code
                                                );
                      END IF;

                      INV_MWB_LOCATION_TREE.make_common_query_onhand('MOQD');
                      inv_mwb_query_manager.add_where_clause(
                                       'moqd.inventory_item_id = :onh_tree_inventory_item_id' ,
                                       'ONHAND'
                                       );
                      inv_mwb_query_manager.add_where_clause(
                                       'moqd.organization_id = :onh_tree_organization_id' ,
                                       'ONHAND'
                                       );

                      IF l_rev_control = 2 THEN
                         inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.revision).column_value :=
                         'moqd.revision';
                         inv_mwb_query_manager.add_group_clause('moqd.revision', 'ONHAND');
                      END IF;

                      IF NVL(l_rev_control, 1) = 1  AND l_lot_control = 2 THEN
                         inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOT).column_value :=
                         'moqd.lot_number';
                         inv_mwb_query_manager.add_group_clause('moqd.lot_number', 'ONHAND');
                      END IF;
                      add_qf_where_onhand('ONHAND');
                      inv_mwb_query_manager.add_bind_variable(
                                          'onh_tree_organization_id',
                                          inv_mwb_globals.g_tree_organization_id
                                          );
                      inv_mwb_query_manager.add_bind_variable(
                                          'onh_tree_inventory_item_id',
                                          inv_mwb_globals.g_tree_item_id
                                          );

                  WHEN 'REV' THEN

                      INV_MWB_LOCATION_TREE.make_common_query_onhand('MOQD');
                      add_qf_where_onhand('ONHAND');

                      inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SUBINVENTORY_CODE).column_value :=
                      'moqd.subinventory_code';
                      inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOCATOR_ID).column_value :=
                      'moqd.locator_id';
                      inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOT).column_value :=
                      'moqd.lot_number';
                      inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.CG_ID).column_value :=
                      'moqd.cost_group_id';
                      inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LPN_ID).column_value :=
                      'moqd.lpn_id';
                      inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.REVISION).column_value :=
                      'moqd.revision';

                      inv_mwb_query_manager.add_group_clause('moqd.subinventory_code', 'ONHAND');
                      inv_mwb_query_manager.add_group_clause('moqd.locator_id', 'ONHAND');
                      inv_mwb_query_manager.add_group_clause('moqd.lot_number', 'ONHAND');
                      inv_mwb_query_manager.add_group_clause('moqd.cost_group_id', 'ONHAND');
                      inv_mwb_query_manager.add_group_clause('moqd.lpn_id', 'ONHAND');
                      inv_mwb_query_manager.add_group_clause('moqd.revision', 'ONHAND');

                      -- Onhand Material Status Support
                      -- For serial controlled items, the status_id will be populated in post_query of IMVMWQMB.
                      if (inv_cache.set_org_rec(inv_mwb_globals.g_tree_organization_id)) then
                           l_default_status_id :=  inv_cache.org_rec.default_status_id;
                      end if;

                      if inv_cache.set_item_rec(inv_mwb_globals.g_tree_organization_id, inv_mwb_globals.g_tree_item_id) then
                        if (inv_cache.item_rec.serial_number_control_code in (2,5)) then
                             l_serial_controlled := 1; -- Item is serial controlled
                        end if;

                        if (inv_cache.item_rec.lot_control_code <> 1) then
                             l_lot_controlled := 1; -- Item is lot controlled
                        end if;
                      end if;

                      if (l_default_status_id is not null and l_serial_controlled = 0 and l_lot_controlled = 0) then
                        inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.STATUS_ID).column_value :=
                        'moqd.status_id';
                        inv_mwb_query_manager.add_group_clause('moqd.status_id', 'ONHAND');
                      end if;
                      -- End Onhand Material Status Support

                      IF inv_mwb_globals.g_tree_parent_lpn_id IS NOT NULL THEN
                        inv_mwb_query_manager.add_where_clause('moqd.lpn_id = :onh_tree_plpn_id', 'ONHAND');
                        inv_mwb_query_manager.add_bind_variable('onh_tree_plpn_id', inv_mwb_globals.g_tree_parent_lpn_id);
                      ELSE
                        inv_mwb_query_manager.add_where_clause('moqd.lpn_id IS NULL', 'ONHAND');
                      END IF;

                      IF inv_mwb_globals.g_tree_loc_id IS NOT NULL THEN
                        inv_mwb_query_manager.add_where_clause('moqd.locator_id = :onh_tree_loc_id', 'ONHAND');
                        inv_mwb_query_manager.add_bind_variable('onh_tree_loc_id', inv_mwb_globals.g_tree_loc_id);
                      ELSE
                        inv_mwb_query_manager.add_where_clause('moqd.locator_id IS NULL', 'ONHAND');
                      END IF;

                      inv_mwb_query_manager.add_where_clause('moqd.organization_id = :onh_tree_organization_id' ,'ONHAND');
                      inv_mwb_query_manager.add_where_clause('moqd.subinventory_code = :onh_tree_subinventory_code', 'ONHAND');
                      inv_mwb_query_manager.add_where_clause('moqd.inventory_item_id = :onh_tree_item_id' ,'ONHAND');
                      inv_mwb_query_manager.add_where_clause('moqd.revision = :onh_tree_revision' ,'ONHAND');

                      inv_mwb_query_manager.add_bind_variable('onh_tree_organization_id', inv_mwb_globals.g_tree_organization_id);
                      inv_mwb_query_manager.add_bind_variable('onh_tree_subinventory_code', inv_mwb_globals.g_tree_subinventory_code);
                      inv_mwb_query_manager.add_bind_variable('onh_tree_item_id', inv_mwb_globals.g_tree_item_id);
                      inv_mwb_query_manager.add_bind_variable('onh_tree_revision', inv_mwb_globals.g_tree_rev);


                  WHEN 'LPN' THEN

                      INV_MWB_LOCATION_TREE.make_common_query_onhand('MOQD');
                      inv_mwb_query_manager.add_where_clause('moqd.organization_id = :onh_tree_organization_id', 'ONHAND');
                      inv_mwb_query_manager.add_where_clause('moqd.subinventory_code = :onh_tree_subinventory_code', 'ONHAND');
                      inv_mwb_query_manager.add_where_clause('moqd.locator_id = :onh_tree_loc_id', 'ONHAND');
                      inv_mwb_query_manager.add_where_clause('moqd.lpn_id = :onh_tree_plpn_id', 'ONHAND');

                      inv_mwb_query_manager.add_bind_variable('onh_tree_organization_id', inv_mwb_globals.g_tree_organization_id);
                      inv_mwb_query_manager.add_bind_variable('onh_tree_subinventory_code', inv_mwb_globals.g_tree_subinventory_code);
                      inv_mwb_query_manager.add_bind_variable('onh_tree_loc_id', inv_mwb_globals.g_tree_loc_id);
                      inv_mwb_query_manager.add_bind_variable('onh_tree_plpn_id', inv_mwb_globals.g_tree_parent_lpn_id);
                      inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SUBINVENTORY_CODE).column_value :=
                      'moqd.subinventory_code';
                      inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOCATOR_ID).column_value :=
                      'moqd.locator_id';
                      inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LPN_ID).column_value :=
                      'moqd.lpn_id';
                      inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.CG_ID).column_value :=
                      'moqd.cost_group_id';

                      inv_mwb_query_manager.add_group_clause('moqd.subinventory_code', 'ONHAND');
                      inv_mwb_query_manager.add_group_clause('moqd.locator_id', 'ONHAND');
                      inv_mwb_query_manager.add_group_clause('moqd.lpn_id', 'ONHAND');
                      inv_mwb_query_manager.add_group_clause('moqd.cost_group_id', 'ONHAND');

                      add_qf_where_onhand('ONHAND');

                  WHEN 'LOT' THEN

                      INV_MWB_LOCATION_TREE.make_common_query_onhand('MOQD');
                      inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.REVISION).column_value :=
                      'moqd.revision';
                      inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.SUBINVENTORY_CODE).column_value :=
                      'moqd.subinventory_code';
                      inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOCATOR_ID).column_value :=
                      'moqd.locator_id';
                      inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LPN_ID).column_value :=
                      'moqd.lpn_id';
                      inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.CG_ID).column_value :=
                      'moqd.cost_group_id';
                      inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOT).column_value :=
                      'moqd.lot_number';

                      inv_mwb_query_manager.add_group_clause('moqd.revision', 'ONHAND');
                      inv_mwb_query_manager.add_group_clause('moqd.subinventory_code', 'ONHAND');
                      inv_mwb_query_manager.add_group_clause('moqd.locator_id', 'ONHAND');
                      inv_mwb_query_manager.add_group_clause('moqd.lpn_id', 'ONHAND');
                      inv_mwb_query_manager.add_group_clause('moqd.cost_group_id', 'ONHAND');
                      inv_mwb_query_manager.add_group_clause('moqd.lot_number', 'ONHAND');

                      -- Onhand Material Status Support
                      -- For serial controlled items, the status_id will be populated in post_query of IMVMWQMB.
                      if (inv_cache.set_org_rec(inv_mwb_globals.g_tree_organization_id)) then
                           l_default_status_id :=  inv_cache.org_rec.default_status_id;
                      end if;

                      if inv_cache.set_item_rec(inv_mwb_globals.g_tree_organization_id, inv_mwb_globals.g_tree_item_id) then
                        if (inv_cache.item_rec.serial_number_control_code in (2,5)) then
                             l_serial_controlled := 1; -- Item is serial controlled
                        end if;
                      end if;

                      if (l_default_status_id is not null and l_serial_controlled = 0) then
                        inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.STATUS_ID).column_value :=
                        'moqd.status_id';
                        inv_mwb_query_manager.add_group_clause('moqd.status_id', 'ONHAND');
                      end if;
                      -- End Onhand Material Status Support

                      IF inv_mwb_globals.g_tree_rev IS NOT NULL THEN
                        inv_mwb_query_manager.add_where_clause('moqd.revision = :onh_tree_revision' ,'ONHAND');
                        inv_mwb_query_manager.add_bind_variable('onh_tree_revision', inv_mwb_globals.g_tree_rev);
                      END IF;

                      IF inv_mwb_globals.g_tree_parent_lpn_id IS NOT NULL THEN
                        inv_mwb_query_manager.add_where_clause('moqd.lpn_id = :onh_tree_plpn_id', 'ONHAND');
                        inv_mwb_query_manager.add_bind_variable('onh_tree_plpn_id', inv_mwb_globals.g_tree_parent_lpn_id);
                      ELSE
                        inv_mwb_query_manager.add_where_clause('moqd.lpn_id IS NULL', 'ONHAND');
	              END IF;

                      IF inv_mwb_globals.g_tree_loc_id IS NOT NULL THEN
                        inv_mwb_query_manager.add_where_clause('moqd.locator_id = :onh_tree_loc_id', 'ONHAND');
                        inv_mwb_query_manager.add_bind_variable('onh_tree_loc_id', inv_mwb_globals.g_tree_loc_id);
                      ELSE
                        inv_mwb_query_manager.add_where_clause('moqd.locator_id IS NULL', 'ONHAND');
	              END IF;

                      inv_mwb_query_manager.add_where_clause('moqd.organization_id = :onh_tree_organization_id' ,'ONHAND');
                      inv_mwb_query_manager.add_where_clause('moqd.subinventory_code = :onh_tree_subinventory_code', 'ONHAND');
                      inv_mwb_query_manager.add_where_clause('moqd.inventory_item_id = :onh_tree_inventory_item_id' ,'ONHAND');
                      inv_mwb_query_manager.add_where_clause('moqd.lot_number = :onh_tree_lot_num' ,'ONHAND');

                      inv_mwb_query_manager.add_bind_variable('onh_tree_organization_id', inv_mwb_globals.g_tree_organization_id);
                      inv_mwb_query_manager.add_bind_variable('onh_tree_subinventory_code', inv_mwb_globals.g_tree_subinventory_code);
                      inv_mwb_query_manager.add_bind_variable('onh_tree_inventory_item_id', inv_mwb_globals.g_tree_item_id);
                      inv_mwb_query_manager.add_bind_variable('onh_tree_lot_num', inv_mwb_globals.g_tree_node_value);

                      add_qf_where_onhand('ONHAND');

                  WHEN 'SERIAL' THEN
                      -- Dummy code
                      INV_MWB_LOCATION_TREE.make_common_query_onhand('MOQD');
                      inv_mwb_query_manager.add_where_clause('moqd.inventory_item_id = :onh_tree_inventory_item_id' ,'ONHAND'); --Bug 7611434 click tree serial node will not show all items/qty
                      add_qf_where_onhand('ONHAND');
               END CASE;

               l_query_str := l_query_str || build_query(
                                              g_onhand_select,
                                              g_onhand_from,
                                              g_onhand_where,
                                              g_onhand_group
                                              );

            ELSIF (inv_mwb_globals.g_view_by = 'ITEM') THEN

               initialize_onhand_query;
               l_query_str := l_query_str || ' UNION ';

               CASE inv_mwb_globals.g_tree_node_type

                  WHEN 'APPTREE_OBJECT_TRUNK' THEN

                      INV_MWB_ITEM_TREE.make_common_queries('MOQD');
                      add_qf_where_onhand('ONHAND');

                  WHEN 'ORG' THEN

                      INV_MWB_ITEM_TREE.make_common_queries('MOQD');

                      SELECT revision_qty_control_code,
                             lot_control_code,
                             serial_number_control_code
                      INTO   l_rev_control,
                             l_lot_control,
                             l_serial_control
                      FROM   mtl_system_items
                      WHERE  inventory_item_id = inv_mwb_globals.g_tree_item_id
                      AND    organization_id = inv_mwb_globals.g_tree_organization_id;

		      IF inv_mwb_globals.g_chk_onhand = 1 THEN
		         inv_mwb_query_manager.add_where_clause(
                                       'moqd.inventory_item_id = :onh_tree_inventory_item_id' ,
                                       'ONHAND'
                                       );
                         inv_mwb_query_manager.add_where_clause(
                                       'moqd.organization_id = :onh_tree_organization_id' ,
                                       'ONHAND'
                                       );
                         IF l_rev_control = 2 THEN
                              inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.revision).column_value :=
                              'moqd.revision';
                              inv_mwb_query_manager.add_group_clause('moqd.revision', 'ONHAND');
                         END IF;
                         IF NVL(l_rev_control, 1) = 1  AND l_lot_control = 2 THEN
                              inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOT).column_value :=
                              'moqd.lot_number';
                              inv_mwb_query_manager.add_group_clause('moqd.lot_number', 'ONHAND');
                         END IF;

			 inv_mwb_query_manager.add_bind_variable(
                                 'onh_tree_organization_id',
                                 inv_mwb_globals.g_tree_organization_id
                                 );
                         inv_mwb_query_manager.add_bind_variable(
                                 'onh_tree_inventory_item_id',
                                 inv_mwb_globals.g_tree_item_id
                                 );
                      END IF; -- onhand check

                      add_qf_where_onhand('ONHAND');

                  WHEN 'ITEM' THEN

                      INV_MWB_ITEM_TREE.make_common_queries('MOQD');
		      inv_mwb_query_manager.add_where_clause(
                                   'moqd.inventory_item_id = :onh_tree_inventory_item_id' ,
                                   'ONHAND'
                                   );
                      inv_mwb_query_manager.add_bind_variable(
                                'onh_tree_inventory_item_id',
                                inv_mwb_globals.g_tree_item_id
                                );
                      add_qf_where_onhand('ONHAND');

                  WHEN 'REV' THEN

		      SELECT lot_control_code,
                             serial_number_control_code
                      INTO   l_lot_control,
                             l_serial_control
                      FROM   mtl_system_items
                      WHERE  inventory_item_id = inv_mwb_globals.g_tree_item_id
                      AND    organization_id = inv_mwb_globals.g_tree_organization_id;

                      INV_MWB_ITEM_TREE.make_common_queries('MOQD');

		      inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.revision).column_value :=
                      'moqd.revision';
                      inv_mwb_query_manager.add_group_clause('moqd.revision', 'ONHAND');
                      inv_mwb_query_manager.add_where_clause('moqd.inventory_item_id = :onh_tree_inventory_item_id' ,'ONHAND');
                      inv_mwb_query_manager.add_where_clause('moqd.organization_id = :onh_tree_organization_id' ,'ONHAND');
                      inv_mwb_query_manager.add_where_clause('moqd.revision = :onh_tree_revision' ,'ONHAND');
                      IF l_lot_control = 2 THEN
                         inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOT).column_value :=
                                       'moqd.lot_number';
                         inv_mwb_query_manager.add_group_clause('moqd.lot_number', 'ONHAND');
                      END IF;

		      inv_mwb_query_manager.add_bind_variable(
                                 'onh_tree_organization_id',
                                 inv_mwb_globals.g_tree_organization_id
                                 );
                      inv_mwb_query_manager.add_bind_variable(
                                 'onh_tree_inventory_item_id',
                                 inv_mwb_globals.g_tree_item_id
                                 );
                      inv_mwb_query_manager.add_bind_variable(
                                 'onh_tree_revision',
                                 inv_mwb_globals.g_tree_rev
                                 );
                      add_qf_where_onhand('ONHAND');


                  WHEN 'LOT' THEN

                      SELECT revision_qty_control_code,
                             serial_number_control_code
                      INTO   l_rev_control,
                             l_serial_control
                      FROM   mtl_system_items
                      WHERE  organization_id = inv_mwb_globals.g_tree_organization_id
                      AND    inventory_item_id = inv_mwb_globals.g_tree_item_id;

                      INV_MWB_ITEM_TREE.make_common_queries('MOQD');

                      IF l_rev_control = 2 THEN
                           inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.revision).column_value :=
                                          'moqd.revision';
                           inv_mwb_query_manager.add_where_clause('moqd.revision = :onh_tree_revision' ,'ONHAND');
                           inv_mwb_query_manager.add_group_clause('moqd.revision','ONHAND');
                      END IF;
                      inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOT).column_value :=
                      'moqd.lot_number';
                      inv_mwb_query_manager.add_group_clause('moqd.lot_number','ONHAND');

                      inv_mwb_query_manager.add_where_clause('moqd.inventory_item_id = :onh_tree_inventory_item_id' ,'ONHAND');
                      inv_mwb_query_manager.add_where_clause('moqd.organization_id = :onh_tree_organization_id' ,'ONHAND');
                      inv_mwb_query_manager.add_where_clause('moqd.lot_number = :onh_tree_lot_number' ,'ONHAND');

		      inv_mwb_query_manager.add_bind_variable('onh_tree_organization_id', inv_mwb_globals.g_tree_organization_id);
                      inv_mwb_query_manager.add_bind_variable('onh_tree_inventory_item_id', inv_mwb_globals.g_tree_item_id);
                      inv_mwb_query_manager.add_bind_variable('onh_tree_lot_number', inv_mwb_globals.g_tree_lot_number);
                      IF l_rev_control = 2 THEN
                         inv_mwb_query_manager.add_bind_variable('onh_tree_revision', inv_mwb_globals.g_tree_rev);
                      END IF;

                      add_qf_where_onhand('ONHAND');
                  WHEN 'SERIAL' THEN
                      -- Dummy code
                      INV_MWB_ITEM_TREE.make_common_queries('MOQD');
                      add_qf_where_onhand('ONHAND');
               END CASE;

               l_query_str := l_query_str || build_query(
                                              g_onhand_select,
                                              g_onhand_from,
                                              g_onhand_where,
                                              g_onhand_group
                                              );




            ELSIF (inv_mwb_globals.g_view_by = 'COST_GROUP') THEN

               initialize_onhand_query;
               l_query_str := l_query_str || ' UNION ';

               CASE inv_mwb_globals.g_tree_node_type

                  WHEN 'APPTREE_OBJECT_TRUNK' THEN

                      INV_MWB_COST_GROUP_TREE.make_common_queries('MOQD');
                      add_qf_where_onhand('ONHAND');

		  WHEN 'COST_GROUP' THEN

                      INV_MWB_COST_GROUP_TREE.make_common_queries('MOQD');

		      inv_mwb_query_manager.add_where_clause('moqd.cost_group_id = :onh_tree_cost_group_id' ,'ONHAND');
                      inv_mwb_query_manager.add_bind_variable('onh_tree_cost_group_id', inv_mwb_globals.g_tree_cg_id);

                      add_qf_where_onhand('ONHAND');

                  WHEN 'ORG' THEN

                      INV_MWB_COST_GROUP_TREE.make_common_queries('MOQD');

                      inv_mwb_query_manager.add_where_clause('moqd.cost_group_id = :onh_tree_cost_group_id' ,'ONHAND');
                      inv_mwb_query_manager.add_where_clause('moqd.organization_id = :onh_tree_organization_id' ,'ONHAND');
                      inv_mwb_query_manager.add_bind_variable('onh_tree_cost_group_id', inv_mwb_globals.g_tree_cg_id);
                      inv_mwb_query_manager.add_bind_variable('onh_tree_organization_id', inv_mwb_globals.g_tree_organization_id);

                      add_qf_where_onhand('ONHAND');

                  WHEN 'ITEM' THEN

                      INV_MWB_COST_GROUP_TREE.make_common_queries('MOQD');

                      inv_mwb_query_manager.add_where_clause('moqd.cost_group_id = :onh_tree_cost_group_id' ,'ONHAND');
                      inv_mwb_query_manager.add_where_clause('moqd.organization_id = :onh_tree_organization_id' ,'ONHAND');
                      inv_mwb_query_manager.add_where_clause('moqd.inventory_item_id = :onh_tree_inventory_item_id' ,'ONHAND');
                      inv_mwb_query_manager.add_bind_variable('onh_tree_cost_group_id', inv_mwb_globals.g_tree_cg_id);
                      inv_mwb_query_manager.add_bind_variable('onh_tree_organization_id', inv_mwb_globals.g_tree_organization_id);
                      inv_mwb_query_manager.add_bind_variable('onh_tree_inventory_item_id', inv_mwb_globals.g_tree_item_id);

                      add_qf_where_onhand('ONHAND');

                  WHEN 'SERIAL' THEN
                      -- Dummy code
                      INV_MWB_COST_GROUP_TREE.make_common_queries('MOQD');
                      add_qf_where_onhand('ONHAND');
               END CASE;

               l_query_str := l_query_str || build_query(
                                              g_onhand_select,
                                              g_onhand_from,
                                              g_onhand_where,
                                              g_onhand_group
                                              );




            ELSIF (inv_mwb_globals.g_view_by = 'LOT') THEN

               initialize_onhand_query;
               l_query_str := l_query_str || ' UNION ';

               CASE inv_mwb_globals.g_tree_node_type

                  WHEN 'APPTREE_OBJECT_TRUNK' THEN

                      INV_MWB_LOT_TREE.make_common_queries('MOQD');
                      add_qf_where_onhand('ONHAND');

                  WHEN 'ORG' THEN

                      INV_MWB_LOT_TREE.make_common_queries('MOQD');

                      inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOT).column_value :=
                      'moqd.lot_number';
                      inv_mwb_query_manager.add_where_clause(
                                 'moqd.organization_id = :onh_tree_organization_id' ,
                                 'ONHAND'
                                 );
                      inv_mwb_query_manager.add_group_clause(
                                 'moqd.lot_number' ,
                                 'ONHAND'
                                 );
		      inv_mwb_query_manager.add_bind_variable(
                              'onh_tree_organization_id',
                              inv_mwb_globals.g_tree_organization_id
                              );

                      add_qf_where_onhand('ONHAND');

                  WHEN 'ITEM' THEN

		      SELECT revision_qty_control_code,
                             serial_number_control_code
                      INTO   l_rev_control,
                             l_serial_control
                      FROM   mtl_system_items
                      WHERE  organization_id = inv_mwb_globals.g_tree_organization_id
                      AND    inventory_item_id = inv_mwb_globals.g_tree_item_id;

                      INV_MWB_LOT_TREE.make_common_queries('MOQD');

		      inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOT).column_value :=
                      'moqd.lot_number';
                      IF l_rev_control = 2 THEN
                         inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.revision).column_value :=
                         'moqd.revision';
                         inv_mwb_query_manager.add_group_clause(
                                       'moqd.revision' ,
                                       'ONHAND'
                                       );
                      END IF;
                      inv_mwb_query_manager.add_where_clause(
                                    'moqd.organization_id = :onh_tree_organization_id' ,
                                    'ONHAND'
                                    );
                      inv_mwb_query_manager.add_where_clause(
                                    'moqd.lot_number = :onh_tree_lot_number' ,
                                    'ONHAND'
                                    );
                      inv_mwb_query_manager.add_where_clause(
                                    'moqd.inventory_item_id = :onh_tree_inventory_item_id' ,
                                    'ONHAND'
                                    );
                      inv_mwb_query_manager.add_group_clause(
                                    'moqd.lot_number' ,
                                    'ONHAND'
                                    );
		      inv_mwb_query_manager.add_bind_variable(
                              'onh_tree_organization_id',
                              inv_mwb_globals.g_tree_organization_id
                              );
                      inv_mwb_query_manager.add_bind_variable(
                              'onh_tree_lot_number',
                              inv_mwb_globals.g_tree_lot_number
                              );
                      inv_mwb_query_manager.add_bind_variable(
                              'onh_tree_inventory_item_id',
                              inv_mwb_globals.g_tree_item_id
                              );

                      add_qf_where_onhand('ONHAND');

                  WHEN 'REV' THEN

                      null;

                  WHEN 'LOT' THEN

                      INV_MWB_LOT_TREE.make_common_queries('MOQD');

		      inv_mwb_query_manager.g_onhand_select(inv_mwb_query_manager.LOT).column_value :=
                      'moqd.lot_number';
                      inv_mwb_query_manager.add_where_clause(
                                 'moqd.organization_id = :onh_tree_organization_id' ,
                                 'ONHAND'
                                 );
                      inv_mwb_query_manager.add_where_clause(
                                 'moqd.lot_number = :onh_tree_lot_number' ,
                                 'ONHAND'
                                 );
                      inv_mwb_query_manager.add_group_clause(
                                 'moqd.lot_number' ,
                                 'ONHAND'
                                 );
		      inv_mwb_query_manager.add_bind_variable(
                              'onh_tree_organization_id',
                              inv_mwb_globals.g_tree_organization_id
                              );
                      inv_mwb_query_manager.add_bind_variable(
                              'onh_tree_lot_number',
                              inv_mwb_globals.g_tree_lot_number
                              );

                      add_qf_where_onhand('ONHAND');

                  WHEN 'SERIAL' THEN
                      -- Dummy code
                      INV_MWB_LOT_TREE.make_common_queries('MOQD');
                      add_qf_where_onhand('ONHAND');
               END CASE;

               l_query_str := l_query_str || build_query(
                                              g_onhand_select,
                                              g_onhand_from,
                                              g_onhand_where,
                                              g_onhand_group
                                              );


               END IF;
            END IF; -- Status ID not null
            --End bug 6060233



            IF inv_mwb_globals.g_is_nested_lpn = 'YES'
            AND inv_mwb_globals.g_tree_node_type = 'LPN' THEN

              l_query_str := l_query_str || ' UNION ';
              l_query_str := l_query_str || build_query(
                                                 g_onhand_1_select,
                                                 g_onhand_1_from,
                                                 g_onhand_1_where,
                                                 g_onhand_1_group
                                                 );
            END IF;


     ELSIF ( NVL(inv_mwb_globals.g_chk_onhand, 0) = 0 AND
             NVL(inv_mwb_globals.g_chk_inbound, 0) = 1 AND
             NVL(inv_mwb_globals.g_chk_receiving, 0) = 0 ) OR
   	     NVL(inv_mwb_globals.g_tree_mat_loc_id, 0) = 3 THEN

             l_query_str := build_insert(g_inbound_select);
             l_query_str := l_query_str || build_query(
                                                 g_inbound_select,
                                                 g_inbound_from,
                                                 g_inbound_where,
                                                 g_inbound_group
                                                 );

            IF inv_mwb_globals.g_is_nested_lpn = 'YES'
            AND inv_mwb_globals.g_tree_node_type = 'LPN' THEN

              l_query_str := l_query_str || ' UNION ';
              l_query_str := l_query_str || build_query(
                                                 g_inbound_1_select,
                                                 g_inbound_1_from,
                                                 g_inbound_1_where,
                                                 g_inbound_1_group
                                                 );
            END IF;


     ELSIF ( NVL(inv_mwb_globals.g_chk_onhand, 0) = 0 AND
             NVL(inv_mwb_globals.g_chk_inbound, 0) = 0 AND
             NVL(inv_mwb_globals.g_chk_receiving, 0) = 1 ) OR
             NVL(inv_mwb_globals.g_tree_mat_loc_id, 0) = 2 THEN

             l_query_str := build_insert(g_receiving_select);
             l_query_str := l_query_str || build_query(
                                                 g_receiving_select,
                                                 g_receiving_from,
                                                 g_receiving_where,
                                                 g_receiving_group
                                                 );

            inv_mwb_globals.print_msg(g_pkg_name, l_procedure_name, inv_mwb_globals.g_is_nested_lpn || '  --  '||inv_mwb_globals.g_tree_node_type);
            IF inv_mwb_globals.g_is_nested_lpn = 'YES'
            AND inv_mwb_globals.g_tree_node_type = 'LPN' THEN

              l_query_str := l_query_str || ' UNION ';
              l_query_str := l_query_str || build_query(
                                                 g_receiving_1_select,
                                                 g_receiving_1_from,
                                                 g_receiving_1_where,
                                                 g_receiving_1_group
                                                 );
            END IF;


     ELSIF inv_mwb_globals.g_tree_mat_loc_id IS NULL THEN

        l_query_str := build_insert(g_union_select);
        l_query_str := l_query_str || build_query(
                                            g_union_select,
                                            g_null_clause,
                                            g_null_clause,
                                            g_null_clause
                                            );
        l_query_str := l_query_str||' FROM ( ';

        IF NVL(inv_mwb_globals.g_chk_onhand, 0) = 1 THEN

           l_query_str := l_query_str || build_query(
                                               g_onhand_select,
                                               g_onhand_from,
                                               g_onhand_where,
                                               g_onhand_group
                                              );
           l_query_str := l_query_str ||' UNION ';

        END IF;

        IF NVL(inv_mwb_globals.g_chk_inbound, 0) = 1 THEN

           l_query_str := l_query_str || build_query(
                                               g_inbound_select,
                                               g_inbound_from,
                                               g_inbound_where,
                                               g_inbound_group
                                              );

           IF NVL(inv_mwb_globals.g_chk_receiving, 0) = 1 THEN
              l_query_str := l_query_str ||' UNION ';
           END IF;

        END IF;

        IF NVL(inv_mwb_globals.g_chk_receiving, 0) = 1 THEN

           l_query_str := l_query_str || build_query(
                                               g_receiving_select,
                                               g_receiving_from,
                                               g_receiving_where,
                                               g_receiving_group
                                              );

        END IF;

        l_query_str := l_query_str||' ) ';
        l_query_str := l_query_str||build_query(
                                          g_null_select,
                                          g_null_clause,
                                          g_null_clause,
                                          g_union_group
                                          );

     END IF;
     RETURN l_query_str;
  END build_query;

  PROCEDURE post_query IS


     CURSOR C1 IS
     SELECT MATURITY_DATE
           ,HOLD_DATE
           ,SUPPLIER_LOT
           ,PARENT_LOT
           ,DOCUMENT_TYPE
           ,DOCUMENT_TYPE_ID
           ,DOCUMENT_NUMBER
           ,DOCUMENT_LINE_NUMBER
           ,RELEASE_NUMBER
           ,PO_RELEASE_ID
           ,RELEASE_LINE_NUMBER
           ,SHIPMENT_NUMBER
           ,SHIPMENT_HEADER_ID_INTERORG
           ,ASN
           ,SHIPMENT_HEADER_ID_ASN
           ,TRADING_PARTNER
           ,VENDOR_ID
           ,TRADING_PARTNER_SITE
           ,VENDOR_SITE_ID
           ,FROM_ORG
           ,FROM_ORG_ID
           ,TO_ORG
           ,TO_ORG_ID
           ,EXPECTED_RECEIPT_DATE
           ,SHIPPED_DATE
           ,OWNING_ORG
           ,OWNING_ORG_ID
           ,REQ_HEADER_ID
           ,OE_HEADER_ID
           ,PO_HEADER_ID
           ,ORIGINATION_DATE
           ,ACTION_CODE
           ,ACTION_DATE
           ,RETEST_DATE
           ,LOT
           ,SERIAL
           ,UNIT_NUMBER
           ,LOT_EXPIRY_DATE
           ,ORIGINATION_TYPE
           ,ORGANIZATION_CODE
           ,ORG_ID
           ,ITEM
           ,ITEM_DESCRIPTION
           ,ITEM_ID
           ,REVISION
           ,PRIMARY_UOM_CODE
           ,ONHAND
           ,RECEIVING
           ,INBOUND
           ,UNPACKED
           ,PACKED
           ,SECONDARY_UOM_CODE
           ,SECONDARY_ONHAND
           ,SECONDARY_RECEIVING
           ,SECONDARY_INBOUND
           ,SECONDARY_UNPACKED
           ,SECONDARY_PACKED
           ,SUBINVENTORY_CODE
           ,LOCATOR
           ,LOCATOR_ID
           ,LPN
           ,LPN_ID
           ,COST_GROUP
           ,CG_ID
           ,GRADE_CODE
           ,LOADED
           ,PLANNING_PARTY
           ,PLANNING_PARTY_ID
           ,OWNING_PARTY
           ,OWNING_PARTY_ID
	   ,OWNING_ORGANIZATION_ID
	   ,PLANNING_ORGANIZATION_ID
	   ,PLANNING_TP_TYPE
	   ,OWNING_TP_TYPE
	   ,PROJECT_ID
	   ,TASK_ID
           ,STATUS_ID -- Onhand Material Status Support
     FROM  MTL_MWB_GTMP;

     TYPE lookup_meaning_table IS TABLE OF mfg_lookups.meaning%TYPE
     INDEX BY BINARY_INTEGER;

     document_type_meaning   lookup_meaning_table;
     lpn_context_meaning     lookup_meaning_table;
     l_procedure_name        VARCHAR2(30);
     l_mtl_location          VARCHAR2(100);
     l_shipment_num          VARCHAR2(30);
     l_shipped_date          DATE;
     l_from_org              VARCHAR2(30);
     l_to_org                VARCHAR2(30);
     l_lpn_context_id        NUMBER;
     l_vendor_id             NUMBER;
     l_vendor_site_id        NUMBER;
     l_task_id               NUMBER;
     l_project_id            NUMBER;
     l_origination_type      NUMBER;
     l_tracking_qty_ind      VARCHAR2(30) ;
     -- Bug 6993717 : Increased the variable length to 1000
     l_item_name	     VARCHAR2(1000);			-- Bug 6350236
     l_status_name           VARCHAR2(80); -- Onhand Material Status Support
     l_serial_controlled     NUMBER := 0; -- Onhand Material Status Support
     l_default_status_id     NUMBER; -- Onhand Material Status Support

     --Bug 6834805, cached variables
     g_org_id                NUMBER;
     g_org                   VARCHAR2(3);
     g_own_org_id            NUMBER;
     g_sub                   VARCHAR2(10);
     g_cg_id                 NUMBER;
     g_cg                    VARCHAR2(100);
     g_item_id               NUMBER;
     g_loc_id                NUMBER;
     g_loc                   VARCHAR2(200);
     g_lot                   VARCHAR2(30);
     g_org_id_trak_qty       NUMBER;
     g_item_id_trak_qty      NUMBER;

  BEGIN
     l_procedure_name := 'POST_QUERY';
     inv_mwb_globals.print_msg(g_pkg_name, l_procedure_name, 'Entered');

     IF inv_mwb_globals.g_tree_mat_loc_id = 3 THEN
        SELECT meaning BULK COLLECT
        INTO   document_type_meaning
        FROM   mfg_lookups
        WHERE  lookup_type = 'MTL_DOCUMENT_TYPES'
        ORDER BY lookup_code;
     END IF;


     SELECT meaning BULK COLLECT
       INTO lpn_context_meaning
       FROM mfg_lookups
      WHERE lookup_type = 'WMS_LPN_CONTEXT';

      FOR rec IN C1 LOOP

     ---------------- Update organization code ----------------------------

         IF inv_mwb_globals.g_organization_code IS NOT NULL
         AND inv_mwb_globals.g_organization_id IS NOT NULL THEN
           --Bug 6834805
           if (nvl(g_org,'@@@@') <> inv_mwb_globals.g_organization_code) then
            UPDATE MTL_MWB_GTMP
               SET organization_code = inv_mwb_globals.g_organization_code;

            g_org := inv_mwb_globals.g_organization_code;
           end if;
         ELSE
            IF rec.org_id IS NOT NULL THEN
              --Bug 6834805
              if (nvl(g_org_id,-9999) <> rec.org_id) then
                 SELECT organization_code
                   INTO l_to_org
                   FROM mtl_parameters
                  WHERE organization_id = rec.org_id;

                 UPDATE MTL_MWB_GTMP
                    SET organization_code = l_to_org
                      , to_org = l_to_org
                  WHERE org_id = rec.org_id;

                 --g_org_id := rec.org_id;
              end if;
            END IF;
         END IF;

         IF inv_mwb_globals.g_subinventory_code IS NOT NULL THEN
           --Bug 6834805
           if (nvl(g_sub,'@@@@') <> inv_mwb_globals.g_subinventory_code) then
             UPDATE MTL_MWB_GTMP
                SET SUBINVENTORY_CODE = inv_mwb_globals.g_subinventory_code;

             g_sub := inv_mwb_globals.g_subinventory_code;
           end if;
         END IF;

         IF rec.owning_org_id IS NOT NULL THEN
           --Bug 6834805
           if (nvl(g_own_org_id,-9999) <> rec.owning_org_id) then
             UPDATE MTL_MWB_GTMP
                SET owning_org = (SELECT organization_code
                                  FROM mtl_parameters
                                 WHERE organization_id = rec.owning_org_id)
             WHERE owning_org_id = rec.owning_org_id;

             g_own_org_id := rec.owning_org_id;
           end if;
         END IF;

    ----------------- Update LPN ------------------------------------------

         IF rec.lpn_id IS NOT NULL THEN
            BEGIN
               UPDATE MTL_MWB_GTMP
               SET lpn = (SELECT license_plate_number
                           FROM wms_license_plate_numbers
                          WHERE lpn_id = rec.lpn_id)
               WHERE lpn_id = rec.lpn_id;

               UPDATE MTL_MWB_GTMP
               SET loaded = (SELECT 1
                             FROM mtl_material_transactions_temp mmtt, wms_dispatched_tasks wdt
                            WHERE wdt.status = 4
                              AND wdt.task_type <> 2
                              AND wdt.transaction_temp_id = mmtt.transaction_temp_id
                              AND (mmtt.content_lpn_id = rec.lpn_id
                                   OR mmtt.lpn_id = rec.lpn_id))
               WHERE lpn_id = rec.lpn_id;

            EXCEPTION
              WHEN TOO_MANY_ROWS THEN
                  UPDATE MTL_MWB_GTMP
                  SET LOADED = 1
                  WHERE lpn_id = rec.lpn_id;
            END;
         END IF;

    --------------- Update Cost Group -------------------------------------

         IF inv_mwb_globals.g_cost_group IS NOT NULL
         AND inv_mwb_globals.g_cost_group_id IS NOT NULL THEN
           --Bug 6834805
           if (nvl(g_cg,'@@@@') <> inv_mwb_globals.g_cost_group) then
             UPDATE MTL_MWB_GTMP
                SET cost_group = inv_mwb_globals.g_cost_group;

             g_cg := inv_mwb_globals.g_cost_group;
           end if;
         ELSE
            IF rec.cg_id IS NOT NULL THEN
              --Bug 6834805
              if (nvl(g_cg_id,-9999) <> rec.cg_id) then
                UPDATE MTL_MWB_GTMP
                SET cost_group = (SELECT distinct cost_group
                            FROM cst_cost_groups
                           WHERE cost_group_id = rec.cg_id)
                WHERE cg_id = rec.cg_id;

                g_cg_id := rec.cg_id;
              end if;
            END IF;
         END IF;

    ----------------- Update Item ------------------------------------------

         IF rec.item_id IS NOT NULL THEN
	    l_item_name :=  inv_mwb_tree1.GET_ITEM(rec.item_id, rec.org_id);			-- Bug 6350236
            --Bug 6834805
            if (nvl(g_item_id,-9999) <> rec.item_id) then

              UPDATE MTL_MWB_GTMP
               SET   (
                 ITEM
               , ITEM_DESCRIPTION
               , PRIMARY_UOM_CODE
               ) = (
              SELECT
	         l_item_name									-- Bug 6350236
               , DESCRIPTION
               , PRIMARY_UOM_CODE
              FROM mtl_system_items_vl --Bug 7691371
              WHERE inventory_item_id = rec.item_id
              AND organization_id = rec.org_id)
              WHERE item_id = rec.item_id;

              --g_item_id := rec.item_id;
            end if;
         END IF;

    ---------------- Update Locator ---------------------------------------

         IF inv_mwb_globals.g_locator_name IS NOT NULL
         AND inv_mwb_globals.g_locator_id IS NOT NULL THEN
           --Bug 6834805
           if (nvl(g_loc, '@@@@') <> inv_mwb_globals.g_locator_name) then
             UPDATE MTL_MWB_GTMP
             SET locator = substr(inv_mwb_globals.g_locator_name, 1, 100),--Bug6595049: truncating the locator to 100 chars
                 locator_id = inv_mwb_globals.g_locator_id; -- Bug 7408480

             g_loc := inv_mwb_globals.g_locator_name;
          end if;
         ELSE
           IF rec.locator_id IS NOT NULL THEN
             --Bug 6834805
             if (nvl(g_loc_id, -9999) <> rec.locator_id) then

               IF inv_mwb_globals.g_is_projects_enabled_org = 0 THEN
                  UPDATE MTL_MWB_GTMP
                  SET locator = substr((SELECT concatenated_segments
                                  FROM mtl_item_locations_kfv
                                 WHERE inventory_location_id = rec.locator_id), 1, 100)  -- Bug 6595049: truncating the locator to 100 chars
                  WHERE locator_id = rec.locator_id;
               ELSE
                  l_project_id := NULL;
                  l_task_id := NULL;
                 /* Bug # 9288054 : Added extra condition in where clause "locator IS NULL" in below update
		     to improve the performance. We should be upldating only those records
		     which were not already updated for locator field. FP of bug 9209775 */

                  UPDATE MTL_MWB_GTMP
                  SET LOCATOR = substr(INV_PROJECT.GET_LOCATOR(REC.LOCATOR_ID, REC.ORG_ID), 1, 100) -- Bug 6595049: truncating the locator to 100 chars
                  WHERE locator IS NULL AND
		  locator_id = rec.locator_id;

                  SELECT project_id
                       , task_id
                  INTO l_project_id
                     , l_task_id
                  FROM mtl_item_locations_kfv
                  WHERE inventory_location_id = rec.locator_id
                  AND organization_id = rec.org_id;

--BUG 8266074--
--Earlier the project and task id's were never updated in the table MTL_MWB_GTMP
--where as the project number was updated before.
--BUG 8266074--

--START BUG 8266074--
                  IF inv_mwb_globals.g_project_number IS NOT NULL THEN
                    UPDATE MTL_MWB_GTMP
                        SET project_number = inv_mwb_globals.g_project_number
                        , project_id = (SELECT project_id
                                                   FROM pjm_projects_v
                                                  WHERE project_number =  inv_mwb_globals.g_project_number);

                  ELSE
                     IF l_project_id IS NOT NULL THEN
                        UPDATE MTL_MWB_GTMP
                        SET project_number = (SELECT project_number
                                                   FROM pjm_projects_v
                                                  WHERE project_id =  l_project_id) ,
                          project_id =  l_project_id
                         WHERE locator_id = rec.locator_id;
                     END IF;
                  END IF;

                  IF inv_mwb_globals.g_task_number IS NOT NULL THEN

		       UPDATE MTL_MWB_GTMP
                       SET task_number = inv_mwb_globals.g_task_number,
                        task_id = (SELECT task_id
                                                   FROM pjm_tasks_v
                                                  WHERE task_number =  inv_mwb_globals.g_task_number
                                                  AND project_number = inv_mwb_globals.g_project_number);
                  ELSE
-- BUG 8266074 Replacing rec.task_id by l_task_id --
                     IF l_task_id IS NOT NULL THEN
                        UPDATE MTL_MWB_GTMP
                           SET task_number = (SELECT task_number
                                                FROM pjm_tasks_v
                                               WHERE task_id =  l_task_id) ,
                         task_id =  l_task_id
                         WHERE locator_id = rec.locator_id;
--END BUG 8266074--
                     END IF;
                  END IF;
               END IF;
               g_loc_id := rec.locator_id;
             end if;
            END IF;
         END IF;
----------------------------------------------------------------------

         IF rec.po_header_id IS NOT NULL THEN

            IF rec.shipment_header_id_asn IS NOT NULL THEN       -- ASN

               l_mtl_location := document_type_meaning(4);
               SELECT shipment_num, shipped_date
                 INTO l_shipment_num, l_shipped_date
                 FROM rcv_shipment_headers rsh
                WHERE rsh.shipment_header_id = rec.shipment_header_id_asn;

               UPDATE mtl_mwb_gtmp
                  SET document_number = l_shipment_num
                    , shipped_date    = l_shipped_date
                    , document_type   = l_mtl_location
		              , document_type_id = 4
                WHERE shipment_header_id_asn = rec.shipment_header_id_asn;

               IF rec.document_line_number IS NOT NULL THEN
                  UPDATE mtl_mwb_gtmp
                     SET document_line_number = (SELECT line_num
                                                   FROM rcv_shipment_lines rsl
                                                  WHERE rsl.shipment_line_id = rec.document_line_number)
                   WHERE shipment_header_id_asn = rec.shipment_header_id_asn
                     AND document_line_number = rec.document_line_number;
               END IF;
            ELSE   -- PO
               l_mtl_location := document_type_meaning(1);
               UPDATE mtl_mwb_gtmp
                  SET document_number = (SELECT segment1
                                           FROM po_headers_trx_v pha -- CLM project, bug 9403291
                                          WHERE pha.po_header_id = rec.po_header_id)
                                              , document_type = l_mtl_location
                                              , document_type_id = 1
                WHERE po_header_id = rec.po_header_id;

               IF rec.document_line_number IS NOT NULL THEN
                  UPDATE mtl_mwb_gtmp
                     SET document_line_number = (SELECT to_char(line_num)
                                                   FROM po_lines_trx_v pla  -- CLM project, bug 9403291
                                                  WHERE pla.po_line_id = rec.document_line_number)
                   WHERE po_header_id = rec.po_header_id
                     AND document_line_number = rec.document_line_number;
               END IF;
            END IF;
         ELSIF rec.req_header_id IS NOT NULL THEN   -- Req
            l_mtl_location := document_type_meaning(2);
            UPDATE mtl_mwb_gtmp
               SET document_number = (SELECT segment1
                                        FROM po_req_headers_trx_v prha  -- CLM project, bug 9403291
                                       WHERE prha.requisition_header_id = rec.req_header_id)
                 , document_type = l_mtl_location
 	              , document_type_id = 2
             WHERE req_header_id = rec.req_header_id;

            IF rec.document_line_number IS NOT NULL THEN
               UPDATE mtl_mwb_gtmp
                  SET document_line_number = (SELECT line_num
                                                FROM po_req_lines_trx_v prla  -- CLM project,  bug 9403291
                                               WHERE prla.requisition_line_id = rec.document_line_number)
                WHERE req_header_id = rec.req_header_id
                  AND document_line_number = rec.document_line_number;
            END IF;
         ELSIF rec.shipment_header_id_asn IS NOT NULL THEN  -- Interorg
      	   inv_mwb_globals.print_msg(g_pkg_name, l_procedure_name, rec.shipment_header_id_asn);
            l_mtl_location := document_type_meaning(3);
            UPDATE mtl_mwb_gtmp
               SET document_number = (SELECT shipment_num
                                        FROM rcv_shipment_headers rsh
                                       WHERE rsh.shipment_header_id = rec.shipment_header_id_asn)
                 , document_type = l_mtl_location
		           , document_type_id = 3
             WHERE shipment_header_id_asn = rec.shipment_header_id_asn;

            IF rec.document_line_number IS NOT NULL THEN
               UPDATE mtl_mwb_gtmp
                  SET document_line_number = (SELECT line_num
                                                FROM rcv_shipment_lines rsl
                                               WHERE rsl.shipment_line_id = rec.document_line_number)
                WHERE shipment_header_id_asn = rec.shipment_header_id_asn
                  AND document_line_number = rec.document_line_number;
            END IF;
         END IF;

--------------- Update Trading Partner and Trading Partner Site ----------------

         l_vendor_id := rec.vendor_id;
         l_vendor_site_id := rec.vendor_site_id;

         IF rec.po_header_id IS NOT NULL THEN
            SELECT vendor_id
                 , vendor_site_id
              INTO l_vendor_id
                 , l_vendor_site_id
              FROM po_headers_all
             WHERE po_header_id = rec.po_header_id;

            UPDATE mtl_mwb_gtmp
               SET vendor_id = l_vendor_id
                 , vendor_site_id = l_vendor_site_id
             WHERE po_header_id = rec.po_header_id;
         END IF;

         IF rec.vendor_id IS NOT NULL
         OR l_vendor_id IS NOT NULL THEN
            UPDATE mtl_mwb_gtmp
               SET trading_partner = (SELECT vendor_name
                                        FROM po_vendors
                                       WHERE vendor_id = l_vendor_id)
             WHERE vendor_id = l_vendor_id;

            IF rec.vendor_site_id IS NOT NULL
            OR l_vendor_site_id IS NOT NULL THEN
               UPDATE mtl_mwb_gtmp
                  SET trading_partner_site = (SELECT vendor_site_code
                                                FROM po_vendor_sites_all
                                               WHERE vendor_site_id = l_vendor_site_id)
                WHERE vendor_id = l_vendor_id
                  AND vendor_site_id = l_vendor_site_id;
            END IF;
         END IF;



-------------------- Update LPN context ----------------------------------------

         IF rec.lpn_id IS NOT NULL THEN

/*            IF (inv_mwb_globals.g_chk_receiving = 1 AND
                inv_mwb_globals.g_chk_inbound = 0 AND
                inv_mwb_globals.g_chk_onhand = 0
                ) OR inv_mwb_globals.g_tree_mat_loc_id = 2 THEN

               UPDATE mtl_mwb_gtmp
                  SET LPN_CONTEXT = lpn_context_meaning(3)
                WHERE lpn_id = rec.lpn_id;
            ELSE
*/

               SELECT lpn_context
                 INTO l_lpn_context_id
                 FROM wms_license_plate_numbers
                WHERE lpn_id = rec.lpn_id;

               UPDATE mtl_mwb_gtmp
                 SET LPN_CONTEXT = (SELECT meaning
                                      FROM mfg_lookups
                                     WHERE lookup_type = 'WMS_LPN_CONTEXT'
                 AND lookup_code = l_lpn_context_id)
               WHERE lpn_id = rec.lpn_id;
            END IF;
--         END IF;

         IF inv_mwb_globals.g_tree_doc_type_id = 4 THEN
            UPDATE mtl_mwb_gtmp
               SET document_type = document_type_meaning(4)
                 , document_type_id = 4
             WHERE shipment_header_id_asn = rec.shipment_header_id_asn;
         END IF;

         IF rec.planning_tp_type = 1
         AND rec.planning_organization_id IS NOT NULL THEN
            IF inv_mwb_globals.g_planning_party IS NOT NULL THEN
               UPDATE mtl_mwb_gtmp
                 SET planning_party = inv_mwb_globals.g_planning_party;
            ELSE
               UPDATE mtl_mwb_gtmp
                 SET planning_party = (SELECT vendor_name || '-' || vendor_site_code
                                         FROM po_vendor_sites_all ps, po_vendors pv
                                        WHERE pv.vendor_id = ps.vendor_id
                                          AND ps.vendor_site_id = rec.planning_organization_id)
                 WHERE planning_organization_id = rec.planning_organization_id;
            END IF;
         END IF;

         IF rec.owning_tp_type = 1
         AND rec.owning_organization_id IS NOT NULL THEN

            IF inv_mwb_globals.g_owning_party IS NOT NULL THEN
               UPDATE mtl_mwb_gtmp
                  SET owning_party = inv_mwb_globals.g_owning_party;
            ELSE
               UPDATE mtl_mwb_gtmp
               SET owning_party = (SELECT vendor_name || '-' || vendor_site_code
                                     FROM po_vendor_sites_all ps, po_vendors pv
                                    WHERE pv.vendor_id = ps.vendor_id
                                      AND ps.vendor_site_id = rec.owning_organization_id)
               WHERE owning_organization_id = rec.owning_organization_id;
            END IF;
         END IF;

--------------------------------------------------------------------------------
-- Update lot information ------------------------------------------------------

         IF rec.lot IS NOT NULL THEN

          --Bug 6834805
          if (   (nvl(g_lot, '@@@@') <> rec.lot)
              or (nvl(g_item_id,-9999) <> nvl(rec.item_id, -9999))
              or (nvl(g_org_id,-9999) <> nvl(rec.org_id, -9999))
             ) then
     /* Bug 8396954. adding outerjoin condition for mfg_lookups table to get the records
                     even if the origination_type in mtl_lot_numbers is null */
            UPDATE MTL_MWB_GTMP
            SET   (
              ORIGINATION_TYPE
            , ORIGINATION_DATE
            , ACTION_DATE
            , ACTION_CODE
            , RETEST_DATE
            , PARENT_LOT
            , MATURITY_DATE
            , HOLD_DATE
            , SUPPLIER_LOT
            , LOT_EXPIRY_DATE
             ) = (
               SELECT
                    mfg.meaning     /* Bug 5417041  */
                  , mln.origination_date
                  , mln.expiration_action_date
                  , mln.expiration_action_code
                  , mln.retest_date
                  , mln.parent_lot_number
                  , mln.maturity_date
                  , mln.hold_date
                  , mln.supplier_lot_number
                  , mln.expiration_date
               FROM
                    mtl_lot_numbers  mln
                  , mfg_lookups mfg
               WHERE lot_number = rec.lot
                 AND mln.inventory_item_id = rec.item_id
                 AND mln.organization_id = rec.org_id
                 AND mfg.lookup_type(+) = 'MTL_LOT_ORIGINATION_TYPE'
                 AND mfg.lookup_code(+) = mln.origination_type)
            WHERE item_id = rec.item_id
              AND lot = rec.lot;
     /* End of Bug 8396954 */

            -------------------------------------------------------
            -- Grade code and lot expiry information --------------
            UPDATE MTL_MWB_GTMP
               SET (
                   GRADE_CODE
                 , LOT_EXPIRY_DATE
                   ) = (
                        SELECT grade_code
                             , expiration_date
                          FROM mtl_lot_numbers
                         WHERE lot_number = rec.lot
                           AND inventory_item_id = rec.item_id
                           AND organization_id = rec.org_id
                       )
            WHERE LOT = rec.lot and ITEM_ID = rec.item_id;--Bug 9252616

            --g_lot := rec.lot;
            --g_item_id := rec.item_id;
            --g_org_id := rec.org_id;
           end if;
         END IF;

         IF rec.org_id IS NOT NULL
         AND rec.item_id IS NOT NULL THEN
           --Bug 6834805
           if (nvl(g_org_id_trak_qty, -9999) <> rec.org_id
           or nvl(g_item_id_trak_qty, -9999) <> rec.item_id) then

             SELECT tracking_quantity_ind
               INTO l_tracking_qty_ind
               FROM mtl_system_items
              WHERE organization_id = rec.org_id
                AND inventory_item_id = rec.item_id;

              IF nvl(l_tracking_qty_ind, '@@@@') <> 'PS' THEN
                UPDATE mtl_mwb_gtmp
                SET SECONDARY_ONHAND = NULL
                  , SECONDARY_UNPACKED = NULL
                  , SECONDARY_PACKED = NULL
                  , SECONDARY_UOM_CODE = NULL
                WHERE org_id = rec.org_id
                AND item_id = rec.item_id;
              END IF ;

              g_org_id_trak_qty := rec.org_id;
              g_item_id_trak_qty := rec.item_id;
            end if;
         END IF;

       ----------------------------------------------------------------------------------------------

         IF inv_mwb_globals.g_lot_from = inv_mwb_globals.g_lot_to THEN
            UPDATE MTL_MWB_GTMP
               SET LOT = inv_mwb_globals.g_lot_from;
         END IF;

         IF inv_mwb_globals.g_serial_from = inv_mwb_globals.g_serial_to THEN
            UPDATE MTL_MWB_GTMP
              SET SERIAL = inv_mwb_globals.g_serial_from;
         END IF;

      -- Onhand Material Status Support
      ----------------- Update Status ------------------------------------------

         if (inv_cache.set_org_rec(inv_mwb_globals.g_tree_organization_id)) then
            l_default_status_id :=  inv_cache.org_rec.default_status_id;
         end if;

         IF l_default_status_id is NOT NULL THEN
            -- Populating the status column for serial controlled items
            IF rec.org_id IS NOT NULL
            AND rec.item_id IS NOT NULL
            AND rec.SERIAL IS NOT NULL THEN

                select status_id
                into rec.status_id
                from mtl_serial_numbers
                where inventory_item_id = rec.item_id
                and serial_number = rec.SERIAL;

                inv_mwb_globals.print_msg(g_pkg_name, l_procedure_name, 'serial status_id '||rec.status_id);

                UPDATE MTL_MWB_GTMP
                SET   status_id = rec.status_id
                WHERE item_id = rec.item_id
                and serial = rec.SERIAL;

            END IF;

            inv_mwb_globals.print_msg(g_pkg_name, l_procedure_name, 'rec.status_id '||rec.status_id);

            IF rec.status_id IS NOT NULL THEN
              SELECT status_code
              INTO   l_status_name
              FROM   mtl_material_statuses_vl
              WHERE  status_id = rec.status_id;

              inv_mwb_globals.print_msg(g_pkg_name, l_procedure_name, 'status code '||l_status_name);

	      UPDATE MTL_MWB_GTMP
              SET   status = l_status_name
              WHERE status_id = rec.status_id;
            END IF;
         END IF;

             g_lot := rec.lot;
             g_item_id := rec.item_id;
             g_org_id := rec.org_id;
      ----------------- End Update Status ------------------------------------------

      END LOOP;
      inv_mwb_globals.print_msg(g_pkg_name, l_procedure_name, 'exited post query');

  EXCEPTION
  WHEN OTHERS THEN
     inv_mwb_globals.print_msg(g_pkg_name, l_procedure_name, ' SQLERRM : ' ||SQLERRM);
  END post_query;

  PROCEDURE bind_query(p_cursor_handle IN NUMBER) IS
     j                PLS_INTEGER;
     l_procedure_name VARCHAR2(30);
  BEGIN
     l_procedure_name := 'BIND_QUERY';
     inv_mwb_globals.print_msg(g_pkg_name, l_procedure_name, 'Entered');
     IF g_date_bind_tab.COUNT > 0 THEN

        j := g_date_bind_tab.FIRST;
        WHILE j IS NOT NULL LOOP
           dbms_sql.bind_variable(
                    p_cursor_handle,
                    g_date_bind_tab(j).bind_name,
                    g_date_bind_tab(j).bind_value
                    );
           inv_mwb_globals.print_msg(
                           g_pkg_name,
                           l_procedure_name,
                           g_date_bind_tab(j).bind_name || ' => '|| g_date_bind_tab(j).bind_value
                           );
           j := g_date_bind_tab.NEXT(j);
        END LOOP;

     END IF;

     IF g_number_bind_tab.COUNT > 0 THEN

        j := g_number_bind_tab.FIRST;
        WHILE j IS NOT NULL LOOP
           dbms_sql.bind_variable(
                    p_cursor_handle,
                    g_number_bind_tab(j).bind_name,
                    g_number_bind_tab(j).bind_value
                    );
           inv_mwb_globals.print_msg(
                           g_pkg_name,
                           l_procedure_name,
                           g_number_bind_tab(j).bind_name || ' => '|| g_number_bind_tab(j).bind_value
                           );
           j := g_number_bind_tab.NEXT(j);
        END LOOP;

     END IF;

     IF g_varchar_bind_tab.COUNT > 0 THEN

        j := g_varchar_bind_tab.FIRST;
        WHILE j IS NOT NULL LOOP
           dbms_sql.bind_variable(
                    p_cursor_handle,
                    g_varchar_bind_tab(j).bind_name,
                    g_varchar_bind_tab(j).bind_value
                    );
           inv_mwb_globals.print_msg(
                           g_pkg_name,
                           l_procedure_name,
                           g_varchar_bind_tab(j).bind_name || ' => '|| g_varchar_bind_tab(j).bind_value
                           );
           j := g_varchar_bind_tab.NEXT(j);
        END LOOP;

     END IF;
  END bind_query;

  PROCEDURE add_from_clause(p_from_clause IN VARCHAR2, p_target IN VARCHAR2) IS
  BEGIN
     CASE p_target
        WHEN 'ONHAND' THEN
           g_onhand_from(g_onhand_from_index) :=  p_from_clause;
           g_onhand_from_index := g_onhand_from_index + 1;
        WHEN 'INBOUND' THEN
           g_inbound_from(g_inbound_from_index) :=  p_from_clause;
           g_inbound_from_index := g_inbound_from_index + 1;
        WHEN 'RECEIVING' THEN
           g_receiving_from(g_receiving_from_index) :=  p_from_clause;
           g_receiving_from_index := g_receiving_from_index + 1;
        WHEN 'ONHAND_1' THEN
           g_onhand_1_from(g_onhand_1_from_index) :=  p_from_clause;
           g_onhand_1_from_index := g_onhand_1_from_index + 1;
        WHEN 'INBOUND_1' THEN
           g_inbound_1_from(g_inbound_1_from_index) :=  p_from_clause;
           g_inbound_1_from_index := g_inbound_1_from_index + 1;
        WHEN 'RECEIVING_1' THEN
           g_receiving_1_from(g_receiving_1_from_index) :=  p_from_clause;
           g_receiving_1_from_index := g_receiving_1_from_index + 1;
     END CASE;
  END add_from_clause;

  PROCEDURE add_where_clause(p_where_clause IN VARCHAR2, p_target IN VARCHAR2) IS
  BEGIN
     CASE p_target
        WHEN 'ONHAND' THEN
           g_onhand_where(g_onhand_where_index) :=  p_where_clause;
           g_onhand_where_index := g_onhand_where_index + 1;
        WHEN 'INBOUND' THEN
           g_inbound_where(g_inbound_where_index) :=  p_where_clause;
           g_inbound_where_index := g_inbound_where_index + 1;
        WHEN 'RECEIVING' THEN
           g_receiving_where(g_receiving_where_index) :=  p_where_clause;
           g_receiving_where_index := g_receiving_where_index + 1;
        WHEN 'ONHAND_1' THEN
           g_onhand_1_where(g_onhand_1_where_index) :=  p_where_clause;
           g_onhand_1_where_index := g_onhand_1_where_index + 1;
        WHEN 'INBOUND_1' THEN
           g_inbound_1_where(g_inbound_1_where_index) :=  p_where_clause;
           g_inbound_1_where_index := g_inbound_1_where_index + 1;
        WHEN 'RECEIVING_1' THEN
           g_receiving_1_where(g_receiving_1_where_index) :=  p_where_clause;
           g_receiving_1_where_index := g_receiving_1_where_index + 1;
     END CASE;
  END add_where_clause;

  PROCEDURE add_group_clause(p_group_clause IN VARCHAR2, p_target IN VARCHAR2) IS
  BEGIN
     CASE p_target
        WHEN 'ONHAND' THEN
           g_onhand_group(g_onhand_group_index) :=  p_group_clause;
           g_onhand_group_index := g_onhand_group_index + 1;
        WHEN 'INBOUND' THEN
           g_inbound_group(g_inbound_group_index) :=  p_group_clause;
           g_inbound_group_index := g_inbound_group_index + 1;
        WHEN 'RECEIVING' THEN
           g_receiving_group(g_receiving_group_index) :=  p_group_clause;
           g_receiving_group_index := g_receiving_group_index + 1;
        WHEN 'ONHAND_1' THEN
           g_onhand_1_group(g_onhand_1_group_index) :=  p_group_clause;
           g_onhand_1_group_index := g_onhand_1_group_index + 1;
        WHEN 'INBOUND_1' THEN
           g_inbound_1_group(g_inbound_1_group_index) :=  p_group_clause;
           g_inbound_1_group_index := g_inbound_1_group_index + 1;
        WHEN 'RECEIVING_1' THEN
           g_receiving_1_group(g_receiving_1_group_index) :=  p_group_clause;
           g_receiving_1_group_index := g_receiving_1_group_index + 1;
     END CASE;
  END add_group_clause;

  FUNCTION build_attribute_qf_onhand(p_entity IN VARCHAR2) RETURN VARCHAR2 IS
     v_flexfield fnd_dflex.dflex_r;
     v_flexinfo  fnd_dflex.dflex_dr;
     v_contexts  fnd_dflex.contexts_dr;
     v_segments  fnd_dflex.segments_dr;

     l_application_short_name VARCHAR2(10);
     l_flex_name              VARCHAR2(30);
     l_delimiter              VARCHAR2(100);
     l_where                  VARCHAR2(500);
     l_context_name           VARCHAR2(50);
     l_pos                    NUMBER;
     l_alias                  VARCHAR2(10);
     l_bind_variable          VARCHAR2(30);

  BEGIN
     l_application_short_name  := 'INV';
     l_where                   := ' ';

     CASE p_entity
        WHEN 'LOT' THEN
           l_flex_name     := 'Lot Attributes';
           l_alias         := 'mln1';
           l_context_name  := 'Computer';
           l_bind_variable := ':onh_lot_attribute';

        WHEN 'SERIAL' THEN
           l_flex_name     := 'Serial Attributes';
           l_alias         := 'msn';
           l_context_name  := 'Computer';
           l_bind_variable := ':onh_serial_attribute';

     END CASE;

     fnd_dflex.get_flexfield(l_application_short_name, l_flex_name, v_flexfield, v_flexinfo);
     l_delimiter := v_flexinfo.segment_delimeter;

     fnd_dflex.get_contexts(v_flexfield, v_contexts);
     FOR i IN 1..v_contexts.ncontexts LOOP
        IF UPPER(v_contexts.context_code(i)) = UPPER(l_context_name) THEN
           fnd_dflex.get_segments(
                     fnd_dflex.make_context(
                               v_flexfield,
                               v_contexts.context_code(i)
                               ),
                     v_segments,
                     TRUE
                     );

           l_pos := v_segments.application_column_name.FIRST;
           WHILE l_pos IS NOT NULL LOOP
              IF l_pos = v_segments.application_column_name.LAST THEN
                 l_where := l_where||l_alias||'.'||v_segments.application_column_name(l_pos);
              ELSE
                 l_where := l_where||l_alias||'.'||v_segments.application_column_name(l_pos)||'||'||''''||l_delimiter||''''||'||';
              END IF;
              l_pos := v_segments.application_column_name.NEXT(l_pos);
           END LOOP;
           l_where := l_where||' = '||l_bind_variable;

        END IF;
     END LOOP;

     RETURN l_where;

  END build_attribute_qf_onhand;

  PROCEDURE add_qf_where_onhand(p_flag VARCHAR2) IS
    l_procedure_name       VARCHAR2(30);
    l_default_status_id    NUMBER; -- Onhand Material Status Support
  BEGIN
     l_procedure_name := 'ADD_QF_WHERE_ONHAND';
     inv_mwb_globals.print_msg(g_pkg_name, l_procedure_name, 'Entered');

     -- Onhand Material Status Support
      if (inv_mwb_globals.g_organization_id is not null) then
         if (inv_cache.set_org_rec(inv_mwb_globals.g_organization_id)) then
           l_default_status_id :=  inv_cache.org_rec.default_status_id;
         end if;
      elsif (inv_mwb_globals.g_tree_organization_id is not null) then
         if (inv_cache.set_org_rec(inv_mwb_globals.g_tree_organization_id)) then
           l_default_status_id :=  inv_cache.org_rec.default_status_id;
         end if;
      end if;

      CASE p_flag
         WHEN 'ONHAND'  THEN
             /* Bug 8225619. Adding ELSE CONDITION code such that right side grid
                retrieves the organizations which are relevant to particular
                responsibility id and responisibility application id */
            IF inv_mwb_globals.g_organization_id IS NOT NULL THEN
              add_where_clause('moqd.organization_id = :onh_organization_id', 'ONHAND');
              add_bind_variable('onh_organization_id', inv_mwb_globals.g_organization_id);
            ELSE
              add_where_clause(' EXISTS ( SELECT 1 FROM org_access_view oav WHERE oav.organization_id = moqd.organization_id AND oav.responsibility_id   = :responsibility_id AND oav.resp_application_id = :resp_application_id ) ', 'ONHAND');
              add_bind_variable('responsibility_id', inv_mwb_globals.g_responsibility_id);
              add_bind_variable('resp_application_id', inv_mwb_globals.g_resp_application_id);
            END IF;
             /* End of Bug 8225619*/

            IF inv_mwb_globals.g_subinventory_code IS NOT NULL THEN
              add_where_clause('moqd.subinventory_code = :onh_subinventory_code', 'ONHAND');
              add_bind_variable('onh_subinventory_code', inv_mwb_globals.g_subinventory_code);
            END IF;

            IF inv_mwb_globals.g_locator_id IS NOT NULL THEN
              add_where_clause('moqd.locator_id = :onh_locator_id', 'ONHAND');
              add_bind_variable('onh_locator_id', inv_mwb_globals.g_locator_id);
            END IF;

            -- ER(9158529 client)
            IF inv_mwb_globals.g_client_code IS NOT NULL THEN
              add_where_clause('moqd.inventory_item_id in (select DISTINCT inventory_item_id from mtl_system_items_b where wms_deploy.get_client_code(inventory_item_id) = :onh_client_code) ', 'ONHAND');
              add_bind_variable('onh_client_code', inv_mwb_globals.g_client_code);
            END IF;
            -- ER(9158529 client)

            IF inv_mwb_globals.g_inventory_item_id IS NOT NULL THEN
              add_where_clause('moqd.inventory_item_id = :onh_inventory_item_id', 'ONHAND');
              add_bind_variable('onh_inventory_item_id', inv_mwb_globals.g_inventory_item_id);
            END IF;

            IF inv_mwb_globals.g_inventory_item_id IS NULL
  	         AND inv_mwb_globals.g_item_description IS NOT NULL THEN
              inv_mwb_query_manager.add_from_clause('mtl_system_items_kfv msik', 'ONHAND');
              add_where_clause('moqd.inventory_item_id = msik.inventory_item_id', 'ONHAND');
              add_where_clause('moqd.organization_id = msik.organization_id', 'ONHAND');
  	           add_where_clause('msik.description like :onh_item_description', 'ONHAND');
              add_bind_variable('onh_item_description', inv_mwb_globals.g_item_description);
            END IF;

  	    IF inv_mwb_globals.g_revision IS NOT NULL THEN
              add_where_clause('moqd.revision = :onh_revision', 'ONHAND');
              add_bind_variable('onh_revision', inv_mwb_globals.g_revision);
            END IF;

            IF inv_mwb_globals.g_cost_group_id IS NOT NULL THEN
              add_where_clause('moqd.cost_group_id = :onh_cost_group_id', 'ONHAND');
              add_bind_variable('onh_cost_group_id', inv_mwb_globals.g_cost_group_id);
            END IF;

            -- ER(9158529)
            IF inv_mwb_globals.g_category_set_id IS NOT NULL THEN
              add_where_clause('moqd.inventory_item_id in '
                                || ' (select DISTINCT inventory_item_id from mtl_item_categories '
                                || ' where organization_id = :onh_organization_id '
                                || ' and category_set_id = :onh_category_set_id '
                                || ' and category_id = nvl(:onh_category_id, category_id)) ', 'ONHAND');
              add_bind_variable('onh_organization_id', inv_mwb_globals.g_organization_id);
              add_bind_variable('onh_category_set_id', inv_mwb_globals.g_category_set_id);
              add_bind_variable('onh_category_id', inv_mwb_globals.g_category_id);
            END IF;
            -- ER(9158529)

            IF inv_mwb_globals.g_project_id IS NOT NULL THEN
              add_where_clause('moqd.project_id = :onh_project_id', 'ONHAND');
              add_bind_variable('onh_project_id', inv_mwb_globals.g_project_id);
            END IF;

            IF inv_mwb_globals.g_task_id IS NOT NULL THEN
              add_where_clause('moqd.task_id = :onh_task_id', 'ONHAND');
              add_bind_variable('onh_task_id', inv_mwb_globals.g_task_id);
            END IF;

            IF inv_mwb_globals.g_lpn_from_id IS NOT NULL
            OR inv_mwb_globals.g_lpn_to_id IS NOT NULL THEN
               inv_mwb_query_manager.add_from_clause(' wms_license_plate_numbers wlpn ','ONHAND');
               add_where_clause('wlpn.lpn_context IN (1,9,11)', 'ONHAND');
               add_where_clause('moqd.lpn_id = wlpn.lpn_id', 'ONHAND');
            END IF;

            IF inv_mwb_globals.g_tree_parent_lpn_id IS NULL THEN
               IF (inv_mwb_globals.g_lpn_from_id IS NOT NULL AND
                  inv_mwb_globals.g_lpn_to_id IS NOT NULL AND
                  inv_mwb_globals.g_lpn_from_id = inv_mwb_globals.g_lpn_to_id) THEN
                 add_where_clause('moqd.lpn_id = :onh_lpn_from_id', 'ONHAND');
                 add_bind_variable('onh_lpn_from_id', inv_mwb_globals.g_lpn_from_id);

               END IF;

               IF (inv_mwb_globals.g_lpn_from_id IS NOT NULL AND
                  inv_mwb_globals.g_lpn_from_id <> NVL(inv_mwb_globals.g_lpn_to_id, -1) ) THEN
                 add_where_clause('wlpn.license_plate_number >= :onh_lpn_from', 'ONHAND');
                 add_bind_variable('onh_lpn_from', inv_mwb_globals.g_lpn_from);
               END IF;

               IF (inv_mwb_globals.g_lpn_to_id IS NOT NULL AND
                  inv_mwb_globals.g_lpn_to_id <> NVL(inv_mwb_globals.g_lpn_from_id, -1) ) THEN
                 add_where_clause('wlpn.license_plate_number <= :onh_lpn_to', 'ONHAND');
                 add_bind_variable('onh_lpn_to', inv_mwb_globals.g_lpn_to);
               END IF;
            END IF;

            IF  inv_mwb_globals.g_owning_qry_mode = 2 THEN
               add_where_clause('moqd.owning_tp_type = 1', 'ONHAND');
            ELSIF inv_mwb_globals.g_owning_qry_mode = 3 THEN
               add_where_clause('moqd.owning_tp_type = 1', 'ONHAND');
               IF inv_mwb_globals.g_owning_org IS NOT NULL THEN
                  add_where_clause('moqd.owning_organization_id = :onh_owning_org_id', 'ONHAND');
                  add_bind_variable('onh_owning_org_id', inv_mwb_globals.g_owning_org);
               END IF;
            END IF;

            IF  inv_mwb_globals.g_planning_query_mode = 2 THEN
               add_where_clause('moqd.planning_tp_type = 1', 'ONHAND');
            ELSIF inv_mwb_globals.g_planning_query_mode = 3 THEN
               add_where_clause('moqd.planning_tp_type = 1', 'ONHAND');
               IF inv_mwb_globals.g_planning_org IS NOT NULL THEN
                  add_where_clause('moqd.planning_organization_id = :onh_planning_org_id', 'ONHAND');
                  add_bind_variable('onh_planning_org_id', inv_mwb_globals.g_planning_org);
               END IF;
            END IF;

            IF (inv_mwb_globals.g_lot_from IS NOT NULL AND
               inv_mwb_globals.g_lot_to IS NOT NULL AND
               inv_mwb_globals.g_lot_from = inv_mwb_globals.g_lot_to) THEN
              add_where_clause('moqd.lot_number = :onh_lot_from', 'ONHAND');
              add_bind_variable('onh_lot_from', inv_mwb_globals.g_lot_from);
            END IF;

            IF (inv_mwb_globals.g_lot_from IS NOT NULL AND
               inv_mwb_globals.g_lot_from <> NVL(inv_mwb_globals.g_lot_to, -1) ) THEN
              add_where_clause('moqd.lot_number >= :onh_lot_from', 'ONHAND');
              add_bind_variable('onh_lot_from', inv_mwb_globals.g_lot_from);
            END IF;

            IF (inv_mwb_globals.g_lot_to IS NOT NULL AND
               inv_mwb_globals.g_lot_to <> NVL(inv_mwb_globals.g_lot_from, -1) ) THEN
              add_where_clause('moqd.lot_number <= :onh_lot_to', 'ONHAND');
              add_bind_variable('onh_lot_to', inv_mwb_globals.g_lot_to);
            END IF;

/* Bug 8396954, Adding below if condition for checking supplier_lot_number condition */
            IF (inv_mwb_globals.g_supplier_lot_from IS NOT NULL OR
                inv_mwb_globals.g_supplier_lot_to IS NOT NULL ) THEN
                inv_mwb_query_manager.add_from_clause('mtl_lot_numbers mln3', 'ONHAND');
                add_where_clause('moqd.lot_number = mln3.lot_number', 'ONHAND');

                IF (inv_mwb_globals.g_supplier_lot_from IS NOT NULL AND
                   inv_mwb_globals.g_supplier_lot_to IS NOT NULL AND
                   inv_mwb_globals.g_supplier_lot_from = inv_mwb_globals.g_supplier_lot_to) THEN
                   add_where_clause('mln3.supplier_lot_number = :onh_supplier_lot_from', 'ONHAND');
                   add_bind_variable('onh_supplier_lot_from', inv_mwb_globals.g_supplier_lot_from);
                END IF;

                IF (inv_mwb_globals.g_supplier_lot_from IS NOT NULL AND
                   inv_mwb_globals.g_supplier_lot_from <> NVL(inv_mwb_globals.g_supplier_lot_to, -1) ) THEN
                   add_where_clause('mln3.supplier_lot_number >= :onh_supplier_lot_from', 'ONHAND');
                   add_bind_variable('onh_supplier_lot_from', inv_mwb_globals.g_supplier_lot_from);
                END IF;

                IF (inv_mwb_globals.g_supplier_lot_to IS NOT NULL AND
                   inv_mwb_globals.g_supplier_lot_to <> NVL(inv_mwb_globals.g_supplier_lot_from, -1) ) THEN
                   add_where_clause('mln3.supplier_lot_number <= :onh_supplier_lot_to', 'ONHAND');
                   add_bind_variable('onh_supplier_lot_to', inv_mwb_globals.g_supplier_lot_to);
                END IF;
            END IF;
/* End of Bug 8396954 */
        --KMOTUPAL ME # 3922793
            IF (inv_mwb_globals.g_expired_lots = 'Y') THEN
               add_from_clause('mtl_lot_numbers mln2', 'ONHAND');
               add_where_clause('moqd.lot_number = mln2.lot_number', 'ONHAND');
               add_where_clause('moqd.inventory_item_id = mln2.inventory_item_id', 'ONHAND');
               add_where_clause('moqd.organization_id = mln2.organization_id', 'ONHAND');
               add_where_clause('mln2.expiration_date <= :expiration_date', 'ONHAND');
               add_bind_variable('expiration_date', inv_mwb_globals.g_expiration_date);
            END IF;
        --KMOTUPAL ME # 3922793

        --BUG 7556505
	       	IF (inv_mwb_globals.g_parent_lot IS NOT NULL) THEN
        		IF (inv_mwb_globals.g_expired_lots <> 'Y') THEN
	               add_from_clause('mtl_lot_numbers mln2', 'ONHAND');
	               add_where_clause('moqd.lot_number = mln2.lot_number', 'ONHAND');
    	        END IF;
               add_where_clause('mln2.parent_lot_number = :parent_lot_number', 'ONHAND');
               add_bind_variable('parent_lot_number', inv_mwb_globals.g_parent_lot);
            END IF;
	    --BUG 7556505

        --bug # 6633612
            IF (inv_mwb_globals.g_shipment_header_id is not null) THEN
               add_from_clause('rcv_transactions rt', 'ONHAND');
               add_from_clause('mtl_material_transactions mmt', 'ONHAND');
               add_where_clause('rt.shipment_header_id = :shipment_header_id', 'ONHAND');
               add_where_clause('rt.transaction_id = mmt.rcv_transaction_id', 'ONHAND');
               add_where_clause('rt.organization_id = mmt.organization_id', 'ONHAND');
               add_where_clause('rt.transaction_type = ''DELIVER''', 'ONHAND');
               add_where_clause('rt.destination_type_code = ''INVENTORY''', 'ONHAND');
               add_where_clause('mmt.transaction_id = moqd.create_transaction_id', 'ONHAND');
               add_where_clause('mmt.organization_id = moqd.organization_id', 'ONHAND');
	       add_bind_variable('shipment_header_id', inv_mwb_globals.g_shipment_header_id);
            END IF;
        --bug # 6633612

            IF (inv_mwb_globals.g_grade_from_code IS NOT NULL) OR
               (inv_mwb_globals.g_lot_context IS NOT NULL) THEN
               add_from_clause('mtl_lot_numbers mln1', 'ONHAND');
               add_where_clause('moqd.lot_number = mln1.lot_number', 'ONHAND');
               add_where_clause('moqd.inventory_item_id = mln1.inventory_item_id', 'ONHAND');
               add_where_clause('moqd.organization_id = mln1.organization_id', 'ONHAND');

               IF (inv_mwb_globals.g_grade_from_code IS NOT NULL) THEN
                  add_where_clause('mln1.grade_code = :onh_grade_from_code', 'ONHAND');
                  add_bind_variable('onh_grade_from_code', inv_mwb_globals.g_grade_from_code);
               END IF;

               IF (inv_mwb_globals.g_lot_context IS NOT NULL) THEN
                  add_where_clause('mln1.lot_attribute_category = :onh_lot_context', 'ONHAND');
                  add_bind_variable('onh_lot_context', inv_mwb_globals.g_lot_context);
               END IF;

           END IF; -- grade or lot context or lot attributes

           IF (inv_mwb_globals.g_lot_attr_query IS NOT NULL) THEN    -- Bug 7566588 Changes Start
              add_from_clause('mtl_lot_numbers mln', 'ONHAND');
              add_where_clause('moqd.lot_number = mln.lot_number', 'ONHAND');
              add_where_clause('moqd.inventory_item_id = mln.inventory_item_id', 'ONHAND');
              add_where_clause('moqd.organization_id = mln.organization_id', 'ONHAND');
              add_where_clause(inv_mwb_globals.g_lot_attr_query, 'ONHAND');
           END IF;                                                   -- Bug 7566588 Changes End

           IF (inv_mwb_globals.g_planning_org IS NOT NULL) THEN
              add_where_clause('moqd.planning_organization_id = :onh_planning_org', 'ONHAND');
              add_bind_variable('onh_planning_org', inv_mwb_globals.g_planning_org);
           END IF;

           IF (inv_mwb_globals.g_owning_org IS NOT NULL) THEN
              add_where_clause('moqd.owning_organization_id = :onh_owning_org', 'ONHAND');
              add_bind_variable('onh_owning_org', inv_mwb_globals.g_owning_org);
           END IF;

           -- Onhand Material Status Support

           inv_mwb_globals.print_msg(g_pkg_name, l_procedure_name, 'add_qf_onhand defaultstatusid:'|| l_default_status_id);
           inv_mwb_globals.print_msg(g_pkg_name, l_procedure_name, 'view by :'||inv_mwb_globals.g_view_by );

           if inv_mwb_globals.g_status_id is not null then
             if l_default_status_id is not null then
               IF inv_mwb_globals.g_view_by <> 'STATUS' THEN

                 inv_mwb_query_manager.add_from_clause('mtl_system_items msit', 'ONHAND');
                 inv_mwb_query_manager.add_where_clause('moqd.organization_id = msit.organization_id', 'ONHAND');
                 inv_mwb_query_manager.add_where_clause('moqd.inventory_item_id = msit.inventory_item_id', 'ONHAND');
                 inv_mwb_query_manager.add_where_clause('msit.serial_number_control_code IN (1, 6)', 'ONHAND');

                 add_where_clause('moqd.status_id = :onh_status_id', 'ONHAND');
                 add_bind_variable('onh_status_id', inv_mwb_globals.g_status_id);
               end if;
             else
               -- Bug 6060233
               IF inv_mwb_globals.g_view_by <> 'STATUS' THEN

                   inv_mwb_query_manager.add_from_clause('mtl_system_items msit', 'ONHAND');
                   inv_mwb_query_manager.add_from_clause('mtl_item_locations_kfv mil', 'ONHAND');
                   inv_mwb_query_manager.add_from_clause('mtl_lot_numbers mln', 'ONHAND');
                   inv_mwb_query_manager.add_from_clause('mtl_secondary_inventories msi', 'ONHAND');
                   inv_mwb_query_manager.add_where_clause('moqd.organization_id = msit.organization_id', 'ONHAND');
                   inv_mwb_query_manager.add_where_clause('moqd.inventory_item_id = msit.inventory_item_id', 'ONHAND');
                   inv_mwb_query_manager.add_where_clause('moqd.organization_id = mil.organization_id(+)', 'ONHAND');
                   inv_mwb_query_manager.add_where_clause('moqd.locator_id = mil.inventory_location_id(+)', 'ONHAND');
                   inv_mwb_query_manager.add_where_clause('moqd.organization_id = mln.organization_id(+)', 'ONHAND');
                   inv_mwb_query_manager.add_where_clause('moqd.inventory_item_id = mln.inventory_item_id(+)', 'ONHAND');
                   inv_mwb_query_manager.add_where_clause('moqd.lot_number = mln.lot_number(+)', 'ONHAND');
                   inv_mwb_query_manager.add_where_clause('moqd.organization_id = msi.organization_id', 'ONHAND');
                   inv_mwb_query_manager.add_where_clause('moqd.subinventory_code = msi.secondary_inventory_name', 'ONHAND');
                   inv_mwb_query_manager.add_where_clause('(msi.subinventory_type = 1 OR msi.subinventory_type IS NULL)', 'ONHAND');
                   inv_mwb_query_manager.add_where_clause('msit.serial_number_control_code IN (1, 6)', 'ONHAND');

                   inv_mwb_query_manager.add_where_clause('(msi.status_id = :msi_status_id' ||
                                                         ' OR mil.status_id = :mil_status_id' ||
                                                         ' OR mln.status_id = :mln_status_id)', 'ONHAND');

                   inv_mwb_query_manager.add_bind_variable('msi_status_id', inv_mwb_globals.g_status_id);
                   inv_mwb_query_manager.add_bind_variable('mil_status_id', inv_mwb_globals.g_status_id);
                   inv_mwb_query_manager.add_bind_variable('mln_status_id', inv_mwb_globals.g_status_id);
               END IF;
               -- End Bug 6060233
             end if;
           end if;
           -- End Onhand Material Status Support


        WHEN 'ONHAND_MSN' THEN

            IF inv_mwb_globals.g_status_id IS NOT NULL THEN
              if l_default_status_id is null then -- Onhand Material Status Support
               inv_mwb_query_manager.add_from_clause('mtl_item_locations_kfv mil', 'ONHAND');
               inv_mwb_query_manager.add_from_clause('mtl_lot_numbers mln', 'ONHAND');
               inv_mwb_query_manager.add_from_clause('mtl_secondary_inventories msi', 'ONHAND');
               inv_mwb_query_manager.add_where_clause('msn.current_organization_id = mil.organization_id(+)', 'ONHAND');
               inv_mwb_query_manager.add_where_clause('msn.current_locator_id = mil.inventory_location_id(+)', 'ONHAND');
               inv_mwb_query_manager.add_where_clause('msn.current_organization_id = mln.organization_id(+)', 'ONHAND');
               inv_mwb_query_manager.add_where_clause('msn.inventory_item_id = mln.inventory_item_id(+)', 'ONHAND');
               inv_mwb_query_manager.add_where_clause('msn.lot_number = mln.lot_number(+)', 'ONHAND');
               inv_mwb_query_manager.add_where_clause('msn.current_organization_id = msi.organization_id', 'ONHAND');
               inv_mwb_query_manager.add_where_clause('msn.current_subinventory_code = msi.secondary_inventory_name', 'ONHAND');
               inv_mwb_query_manager.add_where_clause('NVL (msn.organization_type, 2) = 2', 'ONHAND');
               inv_mwb_query_manager.add_where_clause('(msi.subinventory_type = 1 OR msi.subinventory_type IS NULL)', 'ONHAND');

               IF inv_mwb_globals.g_view_by <> 'STATUS' THEN

                  -- Bug 6060233
                  inv_mwb_query_manager.add_where_clause('(msi.status_id = :msi_status_id' ||
                                                       ' OR mil.status_id = :mil_status_id' ||
                                                       ' OR mln.status_id = :mln_status_id' ||
                                                       ' OR msn.status_id = :msn_status_id)', 'ONHAND');

                  /*
                  inv_mwb_query_manager.add_where_clause('msi.status_id = :msi_status_id', 'ONHAND');
                  inv_mwb_query_manager.add_where_clause('mil.status_id = :mil_status_id', 'ONHAND');
                  inv_mwb_query_manager.add_where_clause('mln.status_id = :mln_status_id', 'ONHAND');
                  inv_mwb_query_manager.add_where_clause('msn.status_id = :msn_status_id', 'ONHAND');
                  */
                   -- End Bug 6060233

                  inv_mwb_query_manager.add_bind_variable('msi_status_id', inv_mwb_globals.g_status_id);
                  inv_mwb_query_manager.add_bind_variable('mil_status_id', inv_mwb_globals.g_status_id);
                  inv_mwb_query_manager.add_bind_variable('mln_status_id', inv_mwb_globals.g_status_id);
                  inv_mwb_query_manager.add_bind_variable('msn_status_id', inv_mwb_globals.g_status_id);
               END IF;
             else -- Onhand Material Status Support
               inv_mwb_query_manager.add_where_clause('NVL (msn.organization_type, 2) = 2', 'ONHAND');
               IF inv_mwb_globals.g_view_by <> 'STATUS' THEN
                  inv_mwb_query_manager.add_where_clause('msn.status_id = :msn_status_id','ONHAND');
                  inv_mwb_query_manager.add_bind_variable('msn_status_id', inv_mwb_globals.g_status_id);
               END IF;
             end if;
            END IF;

            /* Bug 8225619. Adding ELSE CONDITION code such that right side grid
                retrieves the organizations which are relevant to particular
                responsibility id and responisibility application id */
            IF inv_mwb_globals.g_organization_id IS NOT NULL THEN
              add_where_clause('msn.current_organization_id = :onh_organization_id', 'ONHAND');
              add_bind_variable('onh_organization_id', inv_mwb_globals.g_organization_id);
            ELSE
              add_where_clause(' EXISTS ( SELECT 1 FROM org_access_view oav WHERE oav.organization_id = msn.current_organization_id AND oav.responsibility_id   = :responsibility_id AND oav.resp_application_id = :resp_application_id ) ', 'ONHAND');
              add_bind_variable('responsibility_id', inv_mwb_globals.g_responsibility_id);
              add_bind_variable('resp_application_id', inv_mwb_globals.g_resp_application_id);
            END IF;
             /* End of Bug 8225619. */

            IF inv_mwb_globals.g_subinventory_code IS NOT NULL THEN
              add_where_clause('msn.current_subinventory_code = :onh_subinventory_code', 'ONHAND');
              add_bind_variable('onh_subinventory_code', inv_mwb_globals.g_subinventory_code);
            END IF;

            IF inv_mwb_globals.g_locator_id IS NOT NULL THEN
              add_where_clause('msn.current_locator_id = :onh_locator_id', 'ONHAND');
              add_bind_variable('onh_locator_id', inv_mwb_globals.g_locator_id);
            END IF;

            -- ER(9158529 client)
            IF inv_mwb_globals.g_client_code IS NOT NULL THEN
              add_where_clause('msn.inventory_item_id in (select DISTINCT inventory_item_id from mtl_system_items_b where wms_deploy.get_client_code(inventory_item_id) = :onh_client_code) ', 'ONHAND');
              add_bind_variable('onh_client_code', inv_mwb_globals.g_client_code);
            END IF;
            -- ER(9158529 client)

            IF inv_mwb_globals.g_inventory_item_id IS NOT NULL THEN
              add_where_clause('msn.inventory_item_id = :onh_inventory_item_id', 'ONHAND');
              add_bind_variable('onh_inventory_item_id', inv_mwb_globals.g_inventory_item_id);
            END IF;

            IF inv_mwb_globals.g_revision IS NOT NULL THEN
              add_where_clause('msn.revision = :onh_revision', 'ONHAND');
              add_bind_variable('onh_revision', inv_mwb_globals.g_revision);
            END IF;

            IF inv_mwb_globals.g_cost_group_id IS NOT NULL THEN
              add_where_clause('msn.cost_group_id = :onh_cost_group_id', 'ONHAND');
              add_bind_variable('onh_cost_group_id', inv_mwb_globals.g_cost_group_id);
            END IF;

            -- ER(9158529)
            IF inv_mwb_globals.g_category_set_id IS NOT NULL THEN
              add_where_clause('msn.inventory_item_id in '
                                || ' (select DISTINCT inventory_item_id from mtl_item_categories '
                                || ' where organization_id = :onh_organization_id '
                                || ' and category_set_id = :onh_category_set_id '
                                || ' and category_id = nvl(:onh_category_id, category_id)) ', 'ONHAND');
              add_bind_variable('onh_organization_id', inv_mwb_globals.g_organization_id);
              add_bind_variable('onh_category_set_id', inv_mwb_globals.g_category_set_id);
              add_bind_variable('onh_category_id', inv_mwb_globals.g_category_id);
            END IF;
            -- ER(9158529)

            /*

BUG 8266074
MSN does not have project and task still we are using the same ,
saw this while testing bug 8208141 hence commenting the same

            IF inv_mwb_globals.g_project_id IS NOT NULL THEN
              add_where_clause('msn.project_id = :onh_project_id', 'ONHAND');
              add_bind_variable('onh_project_id', inv_mwb_globals.g_project_id);
            END IF;

            IF inv_mwb_globals.g_task_id IS NOT NULL THEN
              add_where_clause('msn.task_id = :onh_task_id', 'ONHAND');
              add_bind_variable('onh_task_id', inv_mwb_globals.g_task_id);
            END IF;

            */

            IF inv_mwb_globals.g_lpn_from_id IS NOT NULL
            OR inv_mwb_globals.g_lpn_to_id IS NOT NULL THEN
               inv_mwb_query_manager.add_from_clause(' wms_license_plate_numbers wlpn ','ONHAND');
               add_where_clause('msn.lpn_id = wlpn.lpn_id', 'ONHAND');
               add_where_clause('wlpn.lpn_context IN (1,9,11)', 'ONHAND');
            END IF;

            IF inv_mwb_globals.g_tree_parent_lpn_id IS NULL THEN
               IF (inv_mwb_globals.g_lpn_from_id IS NOT NULL AND
                  inv_mwb_globals.g_lpn_to_id IS NOT NULL AND
                  inv_mwb_globals.g_lpn_from_id = inv_mwb_globals.g_lpn_to_id) THEN
                 add_where_clause('msn.lpn_id = :onh_lpn_from_id', 'ONHAND');
                 add_bind_variable('onh_lpn_from_id', inv_mwb_globals.g_lpn_from_id);
               END IF;

               IF (inv_mwb_globals.g_lpn_from_id IS NOT NULL AND
                  inv_mwb_globals.g_lpn_from_id <> NVL(inv_mwb_globals.g_lpn_to_id, -1) ) THEN
                 add_where_clause('wlpn.license_plate_number >= :onh_lpn_from', 'ONHAND');
                 add_bind_variable('onh_lpn_from', inv_mwb_globals.g_lpn_from);
               END IF;

               IF (inv_mwb_globals.g_lpn_to_id IS NOT NULL AND
                  inv_mwb_globals.g_lpn_to_id <> NVL(inv_mwb_globals.g_lpn_from_id, -1) ) THEN
                 add_where_clause('wlpn.license_plate_number <= :onh_lpn_to', 'ONHAND');
                 add_bind_variable('onh_lpn_to', inv_mwb_globals.g_lpn_to);
               END IF;
            END IF;

            IF (inv_mwb_globals.g_lot_from IS NOT NULL AND
               inv_mwb_globals.g_lot_to IS NOT NULL AND
               inv_mwb_globals.g_lot_from = inv_mwb_globals.g_lot_to) THEN
              add_where_clause('msn.lot_number = :onh_lot_from', 'ONHAND');
              add_bind_variable('onh_lot_from', inv_mwb_globals.g_lot_from);
            END IF;

            IF (inv_mwb_globals.g_lot_from IS NOT NULL AND
               inv_mwb_globals.g_lot_from <> NVL(inv_mwb_globals.g_lot_to, -1) ) THEN
              add_where_clause('msn.lot_number >= :onh_lot_from', 'ONHAND');
              add_bind_variable('onh_lot_from', inv_mwb_globals.g_lot_from);
            END IF;

            IF (inv_mwb_globals.g_lot_to IS NOT NULL AND
               inv_mwb_globals.g_lot_to <> NVL(inv_mwb_globals.g_lot_from, -1) ) THEN
              add_where_clause('msn.lot_number <= :onh_lot_to', 'ONHAND');
              add_bind_variable('onh_lot_to', inv_mwb_globals.g_lot_to);
            END IF;

/* Bug 8396954, Adding below if condition for checking supplier_lot_number condition */
            IF (inv_mwb_globals.g_supplier_lot_from IS NOT NULL OR
                inv_mwb_globals.g_supplier_lot_to IS NOT NULL ) THEN
               add_from_clause('mtl_lot_numbers mln3', 'ONHAND');
               add_where_clause('msn.lot_number = mln3.lot_number', 'ONHAND');

               IF (inv_mwb_globals.g_supplier_lot_from IS NOT NULL AND
                   inv_mwb_globals.g_supplier_lot_to IS NOT NULL AND
                   inv_mwb_globals.g_supplier_lot_from = inv_mwb_globals.g_supplier_lot_to) THEN
                   add_where_clause('mln3.supplier_lot_number = :onh_supplier_lot_from', 'ONHAND');
                   add_bind_variable('onh_supplier_lot_from', inv_mwb_globals.g_supplier_lot_from);
               END IF;

               IF (inv_mwb_globals.g_supplier_lot_from IS NOT NULL AND
                   inv_mwb_globals.g_supplier_lot_from <> NVL(inv_mwb_globals.g_supplier_lot_to, -1) ) THEN
                   add_where_clause('mln3.supplier_lot_number >= :onh_supplier_lot_from', 'ONHAND');
                   add_bind_variable('onh_supplier_lot_from', inv_mwb_globals.g_supplier_lot_from);
               END IF;

               IF (inv_mwb_globals.g_supplier_lot_to IS NOT NULL AND
                   inv_mwb_globals.g_supplier_lot_to <> NVL(inv_mwb_globals.g_supplier_lot_from, -1) ) THEN
                   add_where_clause('mln3.supplier_lot_number <= :onh_supplier_lot_to', 'ONHAND');
                   add_bind_variable('onh_supplier_lot_to', inv_mwb_globals.g_supplier_lot_to);
               END IF;
            END IF ;
/* End of Bug 8396954 */
          --KMOTUPAL ME # 3922793
            IF (inv_mwb_globals.g_expired_lots = 'Y') THEN
               add_from_clause('mtl_lot_numbers mln2', 'ONHAND');
               add_where_clause('msn.lot_number = mln2.lot_number', 'ONHAND');
               add_where_clause('msn.inventory_item_id = mln2.inventory_item_id', 'ONHAND');
               add_where_clause('msn.organization_id = mln2.organization_id', 'ONHAND');
               add_where_clause('mln2.expiration_date <= :expiration_date', 'ONHAND');
               add_bind_variable('expiration_date', inv_mwb_globals.g_expiration_date);
            END IF;
          --KMOTUPAL ME # 3922793

    	  --BUG 7556505
    	    IF (inv_mwb_globals.g_parent_lot IS NOT NULL) THEN
        		IF (inv_mwb_globals.g_expired_lots <> 'Y') THEN
	               add_from_clause('mtl_lot_numbers mln2', 'ONHAND');
    	        END IF;
               add_where_clause('mln2.parent_lot_number = :parent_lot_number', 'ONHAND');
               add_bind_variable('parent_lot_number', inv_mwb_globals.g_parent_lot);
             END IF;

    	  --BUG 7556505

          --bug # 6633612
            IF (inv_mwb_globals.g_shipment_header_id is not null) THEN
               add_from_clause('rcv_transactions rt', 'ONHAND');
               add_from_clause('mtl_material_transactions mmt', 'ONHAND');
               add_where_clause('rt.shipment_header_id = :shipment_header_id', 'ONHAND');
               add_where_clause('rt.transaction_id = mmt.rcv_transaction_id', 'ONHAND');
               add_where_clause('rt.organization_id = mmt.organization_id', 'ONHAND');
               add_where_clause('rt.transaction_type = ''DELIVER''', 'ONHAND');
               add_where_clause('rt.destination_type_code = ''INVENTORY''', 'ONHAND');
               add_where_clause('mmt.transaction_id = msn.last_transaction_id', 'ONHAND');
               add_where_clause('mmt.organization_id = msn.current_organization_id', 'ONHAND');
	       add_bind_variable('shipment_header_id', inv_mwb_globals.g_shipment_header_id);
            END IF;
        --bug # 6633612

            IF (inv_mwb_globals.g_serial_from IS NOT NULL AND
               inv_mwb_globals.g_serial_to IS NOT NULL AND
               inv_mwb_globals.g_serial_from = inv_mwb_globals.g_serial_to) THEN
              add_where_clause('msn.serial_number = :onh_serial_from', 'ONHAND');
              add_bind_variable('onh_serial_from', inv_mwb_globals.g_serial_from);
            END IF;

            IF (inv_mwb_globals.g_serial_from IS NOT NULL AND
               inv_mwb_globals.g_serial_from <> NVL(inv_mwb_globals.g_serial_to, -1) ) THEN
              add_where_clause('msn.serial_number >= :onh_serial_from', 'ONHAND');
              add_bind_variable('onh_serial_from', inv_mwb_globals.g_serial_from);
            END IF;

            IF (inv_mwb_globals.g_serial_to IS NOT NULL AND
               inv_mwb_globals.g_serial_to <> NVL(inv_mwb_globals.g_serial_from, -1) ) THEN
              add_where_clause('msn.serial_number <= :onh_serial_to', 'ONHAND');
              add_bind_variable('onh_serial_to', inv_mwb_globals.g_serial_to);
            END IF;

	    IF (inv_mwb_globals.g_serial_attr_query IS NOT NULL) THEN						-- Bug 6429880 Changes starting
		add_where_clause(inv_mwb_globals.g_serial_attr_query, 'ONHAND');
	    END IF;												-- Bug 6429880 Changes ending

            IF (inv_mwb_globals.g_grade_from_code IS NOT NULL
                OR inv_mwb_globals.g_lot_context IS NOT NULL
                OR inv_mwb_globals.g_lot_attr_query IS NOT NULL)       -- Bug 7566588
            AND inv_mwb_globals.g_status_id IS NULL THEN
               add_from_clause('mtl_lot_numbers mln', 'ONHAND');
               add_where_clause('msn.lot_number = mln.lot_number', 'ONHAND');
               add_where_clause('msn.inventory_item_id = mln.inventory_item_id', 'ONHAND');
               add_where_clause('msn.current_organization_id = mln.organization_id', 'ONHAND'); -- Bug 7566588
            END IF;

            IF (inv_mwb_globals.g_grade_from_code IS NOT NULL) THEN
               add_where_clause('mln.grade_code = :onh_grade_from_code', 'ONHAND');
               add_bind_variable('onh_grade_from_code', inv_mwb_globals.g_grade_from_code);
            END IF;

            IF (inv_mwb_globals.g_lot_context IS NOT NULL) THEN
               add_where_clause('mln.lot_attribute_category = :onh_lot_context', 'ONHAND');
               add_bind_variable('onh_lot_context', inv_mwb_globals.g_lot_context);
            END IF;

           IF (inv_mwb_globals.g_lot_attr_query IS NOT NULL) THEN    -- Bug 7566588 Changes Start
              add_where_clause(inv_mwb_globals.g_lot_attr_query, 'ONHAND');
           END IF;                                                   -- Bug 7566588 Changes End

            IF  inv_mwb_globals.g_owning_qry_mode = 2 THEN
               add_where_clause('msn.owning_tp_type = 1', 'ONHAND');
            ELSIF inv_mwb_globals.g_owning_qry_mode = 3 THEN
               add_where_clause('msn.owning_tp_type = 1', 'ONHAND');
               IF inv_mwb_globals.g_owning_org IS NOT NULL THEN
                  add_where_clause('msn.owning_organization_id = :onh_owning_org_id', 'ONHAND');
                  add_bind_variable('onh_owning_org_id', inv_mwb_globals.g_owning_org);
               END IF;
            END IF;

            IF  inv_mwb_globals.g_planning_query_mode = 2 THEN
               add_where_clause('msn.planning_tp_type = 1', 'ONHAND');
            ELSIF inv_mwb_globals.g_planning_query_mode = 3 THEN
               add_where_clause('msn.planning_tp_type = 1', 'ONHAND');
               IF inv_mwb_globals.g_planning_org IS NOT NULL THEN
                  add_where_clause('msn.planning_organization_id = :onh_planning_org_id', 'ONHAND');
                  add_bind_variable('onh_planning_org_id', inv_mwb_globals.g_planning_org);
               END IF;
            END IF;

        END CASE;

  END add_qf_where_onhand;

  PROCEDURE add_qf_where_lpn_node(p_mat_loc IN VARCHAR2) IS
     query_str VARCHAR2(1000);
     flag_rcv BOOLEAN;
     flag_onh BOOLEAN;
     l_procedure_name VARCHAR2(30);
     l_serial_control NUMBER;
  BEGIN
     l_procedure_name := 'ADD_QF_WHERE_LPN_NODE';
     inv_mwb_globals.print_msg(g_pkg_name, l_procedure_name, 'Entered with location : ' || p_mat_loc);

     flag_rcv := FALSE;
     flag_onh := FALSE;

     IF inv_mwb_globals.g_tree_item_id IS NOT NULL THEN
         SELECT serial_number_control_code
         INTO   l_serial_control
         FROM   mtl_system_items
         WHERE  inventory_item_id = inv_mwb_globals.g_tree_item_id
         AND    organization_id = inv_mwb_globals.g_tree_organization_id;
     END IF;

     IF inv_mwb_globals.g_chk_onhand = 0 AND
        inv_mwb_globals.g_chk_receiving = 0 AND
        inv_mwb_globals.g_chk_inbound = 0 THEN
        null;
     ELSE
        IF inv_mwb_globals.g_tree_node_type = 'APPTREE_OBJECT_TRUNK'
        OR inv_mwb_globals.g_tree_node_type = 'ORG' THEN

           query_str := ' wlpn.lpn_context IN ( ';
           IF inv_mwb_globals.g_chk_onhand = 1 THEN
              query_str := query_str || '1,9,11';
              flag_onh := TRUE;
           END IF;

           IF inv_mwb_globals.g_chk_receiving = 1 THEN
              IF flag_onh THEN
                 query_str := query_str || ',';
              END IF;
              query_str := query_str || '3';
           END IF;

           IF inv_mwb_globals.g_chk_inbound = 1 THEN
              IF flag_onh or flag_rcv THEN
                 query_str := query_str || ',';
              END IF;
              query_str := query_str || '6,7';
           END IF;
            query_str := query_str || ' ) ';
            add_where_clause(query_str, p_mat_loc);
	ELSE
             CASE inv_mwb_globals.g_tree_mat_loc_id
                WHEN 1 THEN
                   add_where_clause('wlpn.lpn_context IN (1,9,11)', p_mat_loc);
                WHEN 2 THEN
                   add_where_clause('wlpn.lpn_context = 3', p_mat_loc);
                WHEN 3 THEN
                  add_where_clause('wlpn.lpn_context IN (6,7) ', p_mat_loc);
             END CASE;
	END IF;
     END IF;
     inv_mwb_globals.print_msg(g_pkg_name, l_procedure_name, 'Adding tables to the query : ' || p_mat_loc);
     inv_mwb_query_manager.add_from_clause(' wms_license_plate_numbers wlpn ' , p_mat_loc);
     inv_mwb_query_manager.add_from_clause(' wms_lpn_contents wlc ', p_mat_loc);
     add_where_clause(' wlc.parent_lpn_id = wlpn.lpn_id ', p_mat_loc);

     IF inv_mwb_globals.g_serial_from IS NOT NULL
     OR inv_mwb_globals.g_serial_to IS NOT NULL
     OR inv_mwb_globals.g_tree_serial_number IS NOT NULL
     OR l_serial_control IN (2, 5) THEN
        inv_mwb_query_manager.add_from_clause(' mtl_serial_numbers msn ',p_mat_loc);
        add_where_clause('msn.lpn_id = wlpn.lpn_id', p_mat_loc);
        add_where_clause('msn.current_organization_id = wlc.organization_id', p_mat_loc);
        add_where_clause('msn.inventory_item_id = wlc.inventory_item_id', p_mat_loc);

        IF inv_mwb_globals.g_chk_onhand = 0 AND
           inv_mwb_globals.g_chk_receiving = 0 AND
           inv_mwb_globals.g_chk_inbound = 0 THEN
           null;
        ELSE
            query_str := 'msn.current_status = ';
            IF inv_mwb_globals.g_chk_onhand = 1 THEN
               query_str := query_str || '3';
               flag_onh := TRUE;
            END IF;

            IF inv_mwb_globals.g_chk_inbound = 1
            OR inv_mwb_globals.g_chk_receiving = 1 THEN
               IF flag_onh or flag_rcv THEN
                  query_str := query_str || ',';
               END IF;
               query_str := query_str || '5';
            END IF;
                 add_where_clause(query_str, p_mat_loc);
            END IF;
        END IF;

     IF inv_mwb_globals.g_project_id IS NOT NULL
     OR inv_mwb_globals.g_task_id IS NOT NULL THEN
        inv_mwb_query_manager.add_from_clause(' mtl_item_locations mil ',p_mat_loc);
        add_where_clause('msn.lpn_id = wlpn.lpn_id', p_mat_loc);
        add_where_clause('mil.organization_id = wlc.organization_id', p_mat_loc);
        add_where_clause('wlpn.locator = mil.inventory_location_id', p_mat_loc);
     END IF;

     IF inv_mwb_globals.g_project_id IS NOT NULL THEN
        add_where_clause('mil.project_id = :project_id', p_mat_loc);
        add_bind_variable('project_id', inv_mwb_globals.g_project_id);
     END IF;

     IF inv_mwb_globals.g_task_id IS NOT NULL THEN
        add_where_clause('mil.task_id = :task_id', p_mat_loc);
        add_bind_variable('task_id', inv_mwb_globals.g_task_id);
     END IF;

     IF inv_mwb_globals.g_organization_id IS NOT NULL THEN
        add_where_clause('wlpn.organization_id = :to_organization_id', p_mat_loc);
        add_bind_variable('to_organization_id', inv_mwb_globals.g_organization_id);
     END IF;

     IF inv_mwb_globals.g_subinventory_code IS NOT NULL THEN
        add_where_clause('wlpn.subinventory_code = :to_subinventory_code', p_mat_loc);
        add_bind_variable('to_subinventory_code', inv_mwb_globals.g_subinventory_code);
     END IF;

     IF inv_mwb_globals.g_locator_id IS NOT NULL THEN
        add_where_clause('wlpn.locator_id = :to_locator_id', p_mat_loc);
        add_bind_variable('to_locator_id', inv_mwb_globals.g_locator_id);
     END IF;

     -- ER(9158529 client)
     IF inv_mwb_globals.g_client_code IS NOT NULL THEN
        add_where_clause('wlc.inventory_item_id in (select DISTINCT inventory_item_id from mtl_system_items_b where wms_deploy.get_client_code(inventory_item_id) = :client_code) ', p_mat_loc);
        add_bind_variable('client_code', inv_mwb_globals.g_client_code);
     END IF;
     -- ER(9158529 client)

     IF inv_mwb_globals.g_inventory_item_id IS NOT NULL THEN
        add_where_clause('wlc.inventory_item_id = :inventory_item_id', p_mat_loc);
        add_bind_variable('inventory_item_id', inv_mwb_globals.g_inventory_item_id);
     END IF;

     IF inv_mwb_globals.g_revision IS NOT NULL THEN
        add_where_clause('wlpn.revision = :revision', p_mat_loc);
        add_bind_variable('revision', inv_mwb_globals.g_revision);
     END IF;

     IF inv_mwb_globals.g_cost_group_id IS NOT NULL THEN
        add_where_clause('wlpn.cost_group_id = :cost_group_id', 'INBOUND');
        add_bind_variable('cost_group_id', inv_mwb_globals.g_cost_group_id);
     END IF;

    -- ER(9158529)
    IF inv_mwb_globals.g_category_set_id IS NOT NULL THEN
        add_where_clause('wlc.inventory_item_id in '
                            || ' (select DISTINCT inventory_item_id from mtl_item_categories '
                            || ' where organization_id = :to_organization_id '
                            || ' and category_set_id = :category_set_id '
                            || ' and category_id = nvl(:category_id, category_id))', p_mat_loc);
        add_bind_variable('to_organization_id', inv_mwb_globals.g_organization_id);
        add_bind_variable('category_set_id', inv_mwb_globals.g_category_set_id);
        add_bind_variable('category_id', inv_mwb_globals.g_category_id);
    END IF;
    -- ER(9158529)

      IF (inv_mwb_globals.g_lpn_from_id IS NOT NULL AND
         inv_mwb_globals.g_lpn_to_id IS NOT NULL AND
         inv_mwb_globals.g_lpn_from_id = inv_mwb_globals.g_lpn_to_id) THEN
        add_where_clause('wlpn.lpn_id = :onh_lpn_from_id', p_mat_loc);
        add_bind_variable('onh_lpn_from_id', inv_mwb_globals.g_lpn_from_id);
      END IF;

      IF (inv_mwb_globals.g_lpn_from_id IS NOT NULL AND
         inv_mwb_globals.g_lpn_from_id <> NVL(inv_mwb_globals.g_lpn_to_id, -1) ) THEN
        add_where_clause('wlpn.license_plate_number >= :onh_lpn_from', p_mat_loc);
        add_bind_variable('onh_lpn_from', inv_mwb_globals.g_lpn_from);
      END IF;

      IF (inv_mwb_globals.g_lpn_to_id IS NOT NULL AND
         inv_mwb_globals.g_lpn_to_id <> NVL(inv_mwb_globals.g_lpn_from_id, -1) ) THEN
        add_where_clause('wlpn.license_plate_number <= :onh_lpn_to', p_mat_loc);
        add_bind_variable('onh_lpn_to', inv_mwb_globals.g_lpn_to);
      END IF;

/*

     IF (inv_mwb_globals.g_lpn_from IS NOT NULL AND
         inv_mwb_globals.g_lpn_to IS NOT NULL AND
         inv_mwb_globals.g_lpn_from = inv_mwb_globals.g_lpn_to) THEN
         add_where_clause('wlpn.lpn_id = :lpn_from_id', p_mat_loc);
         add_bind_variable('lpn_from_id', inv_mwb_globals.g_lpn_from_id);
     END IF;

     IF (inv_mwb_globals.g_lpn_from_id IS NOT NULL AND
         inv_mwb_globals.g_lpn_from_id <> NVL(inv_mwb_globals.g_lpn_to_id, -1) ) THEN
         add_where_clause('wlpn.lpn_id >= :lpn_from_id', p_mat_loc);
         add_bind_variable('lpn_from_id', inv_mwb_globals.g_lpn_from_id);
     END IF;

     IF (inv_mwb_globals.g_lpn_to_id IS NOT NULL AND
         inv_mwb_globals.g_lpn_to_id <> NVL(inv_mwb_globals.g_lpn_from_id, -1) ) THEN
         add_where_clause('wlpn.lpn_id <= :lpn_to_id', p_mat_loc);
         add_bind_variable('lpn_to_id', inv_mwb_globals.g_lpn_to_id);
     END IF;
*/

     IF (inv_mwb_globals.g_lot_from IS NOT NULL AND
         inv_mwb_globals.g_lot_to IS NOT NULL AND
         inv_mwb_globals.g_lot_from = inv_mwb_globals.g_lot_to) THEN
         add_where_clause('wlc.lot_number = :lot_from', p_mat_loc);
         add_bind_variable('lot_from', inv_mwb_globals.g_lot_from);
     END IF;

     IF (inv_mwb_globals.g_lot_from IS NOT NULL AND
         inv_mwb_globals.g_lot_from <> NVL(inv_mwb_globals.g_lot_to, -1) ) THEN
         add_where_clause('wlc.lot_number >= :lot_from', p_mat_loc);
         add_bind_variable('lot_from', inv_mwb_globals.g_lot_from);
     END IF;

     IF (inv_mwb_globals.g_lot_to IS NOT NULL AND
         inv_mwb_globals.g_lot_to <> NVL(inv_mwb_globals.g_lot_from, -1) ) THEN
         add_where_clause('wlc.lot_number <= :lot_to', p_mat_loc);
         add_bind_variable('lot_to', inv_mwb_globals.g_lot_to);
     END IF;

/* Bug 8396954, Adding below if condition for checking supplier_lot_number condition */
     IF (inv_mwb_globals.g_supplier_lot_from IS NOT NULL OR
         inv_mwb_globals.g_supplier_lot_to IS NOT NULL ) THEN
         inv_mwb_query_manager.add_from_clause('mtl_lot_numbers mln3', p_mat_loc);
         add_where_clause('wlc.lot_number = mln3.lot_number',p_mat_loc);

         IF (inv_mwb_globals.g_supplier_lot_from IS NOT NULL AND
             inv_mwb_globals.g_supplier_lot_to IS NOT NULL AND
             inv_mwb_globals.g_supplier_lot_from = inv_mwb_globals.g_supplier_lot_to) THEN
             add_where_clause('mln3.supplier_lot_number = :supplier_lot_from', p_mat_loc);
             add_bind_variable('supplier_lot_from', inv_mwb_globals.g_supplier_lot_from);
         END IF;

         IF (inv_mwb_globals.g_supplier_lot_from IS NOT NULL AND
             inv_mwb_globals.g_supplier_lot_from <> NVL(inv_mwb_globals.g_supplier_lot_to, -1) ) THEN
             add_where_clause('mln3.supplier_lot_number >= :supplier_lot_from', p_mat_loc);
             add_bind_variable('supplier_lot_from', inv_mwb_globals.g_supplier_lot_from);
         END IF;

         IF (inv_mwb_globals.g_supplier_lot_to IS NOT NULL AND
              inv_mwb_globals.g_supplier_lot_to <> NVL(inv_mwb_globals.g_supplier_lot_from, -1) ) THEN
              add_where_clause('mln3.supplier_lot_number <= :supplier_lot_to', p_mat_loc);
              add_bind_variable('supplier_lot_to', inv_mwb_globals.g_supplier_lot_to);
          END IF;
     END IF;
/* End of Bug 8396954 */

     IF (inv_mwb_globals.g_serial_from IS NOT NULL AND
         inv_mwb_globals.g_serial_to IS NOT NULL AND
         inv_mwb_globals.g_serial_from = inv_mwb_globals.g_serial_to) THEN
         add_where_clause('msn.serial_number = :serial_from', p_mat_loc);
         add_bind_variable('serial_from', inv_mwb_globals.g_serial_from);
     END IF;

     IF (inv_mwb_globals.g_serial_from IS NOT NULL AND
         inv_mwb_globals.g_serial_from <> NVL(inv_mwb_globals.g_serial_to, -1) ) THEN
         add_where_clause('msn.serial_number >= :serial_from', p_mat_loc);
         add_bind_variable('serial_from', inv_mwb_globals.g_serial_from);
     END IF;

     IF (inv_mwb_globals.g_serial_to IS NOT NULL AND
         inv_mwb_globals.g_serial_to <> NVL(inv_mwb_globals.g_serial_from, -1) ) THEN
         add_where_clause('msn.serial_number <= :serial_to', p_mat_loc);
         add_bind_variable('serial_to', inv_mwb_globals.g_serial_to);
     END IF;

     /* Bug 5448079  */
     /*IF (inv_mwb_globals.g_qty_from IS NOT NULL AND
         inv_mwb_globals.g_qty_to IS NOT NULL AND
         inv_mwb_globals.g_qty_from = inv_mwb_globals.g_qty_to) THEN
         add_where_clause('wlc.quantity = :qty_from', p_mat_loc);
         add_bind_variable('qty_from', inv_mwb_globals.g_qty_from);
     END IF;

     IF (inv_mwb_globals.g_qty_from IS NOT NULL AND
         inv_mwb_globals.g_qty_from <> NVL(inv_mwb_globals.g_qty_to, -1) ) THEN
         add_where_clause('wlc.quantity >= :qty_from', p_mat_loc);
         add_bind_variable('qty_from', inv_mwb_globals.g_qty_from);
     END IF;

     IF (inv_mwb_globals.g_qty_to IS NOT NULL AND
         inv_mwb_globals.g_qty_to <> NVL(inv_mwb_globals.g_qty_from, -1) ) THEN
         add_where_clause('wlc.quantity <= :qty_to', p_mat_loc);
         add_bind_variable('qty_to', inv_mwb_globals.g_qty_to);
     END IF;    */
     /* End of Bug 5448079 */
  END add_qf_where_lpn_node;


  PROCEDURE add_qf_where_receiving(p_flag VARCHAR2) IS
    l_procedure_name VARCHAR2(30);
    l_serial_control NUMBER;
    l_lot_control NUMBER;
  BEGIN
     l_procedure_name := 'ADD_QF_WHERE_RECEIVING';
     inv_mwb_globals.print_msg(g_pkg_name, l_procedure_name, 'Entered');

     BEGIN
        SELECT lot_control_code,
               serial_number_control_code
        INTO   l_lot_control,
               l_serial_control
        FROM   mtl_system_items
        WHERE  inventory_item_id = inv_mwb_globals.g_tree_item_id
        AND    organization_id = inv_mwb_globals.g_tree_organization_id;
     EXCEPTION
      WHEN NO_DATA_FOUND THEN
         NULL;
     END;

     IF p_flag = 'TREE_LPN' THEN
         null;
     ELSIF p_flag = 'RECEIVING' THEN
         inv_mwb_globals.print_msg(g_pkg_name, l_procedure_name, 'Addding table');
         inv_mwb_query_manager.add_from_clause(' rcv_supply rs ','RECEIVING');
         IF (inv_mwb_globals.g_lot_from IS NOT NULL
	          OR inv_mwb_globals.g_lot_to IS NOT NULL)
    	    OR l_lot_control = 2 THEN
            inv_mwb_query_manager.add_from_clause('rcv_lots_supply rls','RECEIVING');
            add_where_clause('rls.shipment_line_id(+) = rs.shipment_line_id', 'RECEIVING');

            IF inv_mwb_globals.g_tree_lot_number IS NULL THEN

               IF (inv_mwb_globals.g_lot_from IS NOT NULL AND
                  inv_mwb_globals.g_lot_to IS NOT NULL AND
                  inv_mwb_globals.g_lot_from = inv_mwb_globals.g_lot_to) THEN
                  add_where_clause('rls.lot_num = :rcv_lot_from', 'RECEIVING');
                  add_bind_variable('rcv_lot_from', inv_mwb_globals.g_lot_from);
               END IF;

               IF (inv_mwb_globals.g_lot_from IS NOT NULL AND
                  inv_mwb_globals.g_lot_from <> NVL(inv_mwb_globals.g_lot_to, -1) ) THEN
                  add_where_clause('rls.lot_num >= :rcv_lot_from', 'RECEIVING');
                  add_bind_variable('rcv_lot_from', inv_mwb_globals.g_lot_from);
               END IF;

               IF (inv_mwb_globals.g_lot_to IS NOT NULL AND
                  inv_mwb_globals.g_lot_to <> NVL(inv_mwb_globals.g_lot_from, -1) ) THEN
                  add_where_clause('rls.lot_num <= :rcv_lot_to', 'RECEIVING');
                  add_bind_variable('rcv_lot_to', inv_mwb_globals.g_lot_to);
               END IF;
           END IF;
     	   END IF;

/* Bug 8396954, Adding below if condition for checking supplier_lot_number condition */
            IF (inv_mwb_globals.g_supplier_lot_from IS NOT NULL OR
               inv_mwb_globals.g_supplier_lot_to IS NOT NULL ) THEN
               inv_mwb_query_manager.add_from_clause('mtl_lot_numbers mln3', 'RECEIVING');
                 inv_mwb_query_manager.add_from_clause('rcv_lots_supply rls1','RECEIVING');
                 add_where_clause('rls1.shipment_line_id(+) = rs.shipment_line_id', 'RECEIVING');
                 add_where_clause('mln3.lot_number = rls1.lot_num', 'RECEIVING');

                IF (inv_mwb_globals.g_supplier_lot_from IS NOT NULL AND
                    inv_mwb_globals.g_supplier_lot_to IS NOT NULL AND
                    inv_mwb_globals.g_supplier_lot_from = inv_mwb_globals.g_supplier_lot_to) THEN
                    add_where_clause('mln3.supplier_lot_number = :rcv_supplier_lot_from', 'RECEIVING');
                    add_bind_variable('rcv_supplier_lot_from', inv_mwb_globals.g_supplier_lot_from);
                END IF;

                IF (inv_mwb_globals.g_supplier_lot_from IS NOT NULL AND
                       inv_mwb_globals.g_supplier_lot_from <> NVL(inv_mwb_globals.g_supplier_lot_to, -1) ) THEN
                           add_where_clause('mln3.supplier_lot_number >= :rcv_supplier_lot_from', 'RECEIVING');
                   add_bind_variable('rcv_supplier_lot_from', inv_mwb_globals.g_supplier_lot_from);
                END IF;

                IF (inv_mwb_globals.g_supplier_lot_to IS NOT NULL AND
                   inv_mwb_globals.g_supplier_lot_to <> NVL(inv_mwb_globals.g_supplier_lot_from, -1) ) THEN
                   add_where_clause('mln3.supplier_lot_number <= :rcv_supplier_lot_to', 'RECEIVING');
                 add_bind_variable('rcv_supplier_lot_to', inv_mwb_globals.g_supplier_lot_to);
                END IF;
                END IF ;
/* End of Bug 8396954 */

         /* Bug 8225619. Adding ELSE CONDITION code such that right side grid
            retrieves the organizations which are relevant to particular
            responsibility id and responisibility application id */
         IF inv_mwb_globals.g_organization_id IS NOT NULL THEN
            add_where_clause('rs.to_organization_id = :rcv_to_organization_id', 'RECEIVING');
            add_bind_variable('rcv_to_organization_id', inv_mwb_globals.g_organization_id);
         ELSE
            add_where_clause(' EXISTS ( SELECT 1 FROM org_access_view oav WHERE oav.organization_id = rs.to_organization_id AND oav.responsibility_id   = :responsibility_id AND oav.resp_application_id = :resp_application_id ) ', 'RECEIVING');
            add_bind_variable('responsibility_id', inv_mwb_globals.g_responsibility_id);
            add_bind_variable('resp_application_id', inv_mwb_globals.g_resp_application_id);
         END IF;
         /* End of Bug 8225619*/

         IF inv_mwb_globals.g_subinventory_code IS NOT NULL THEN
            add_where_clause('rs.to_subinventory = :rcv_to_subinventory_code', 'RECEIVING');
            add_bind_variable('rcv_to_subinventory_code', inv_mwb_globals.g_subinventory_code);
         END IF;

         IF inv_mwb_globals.g_locator_id IS NOT NULL THEN
            add_where_clause('rs.to_locator_id = :rcv_to_locator_id', 'RECEIVING');
            add_bind_variable('rcv_to_locator_id', inv_mwb_globals.g_locator_id);
         END IF;

         -- ER(9158529 client)
         IF inv_mwb_globals.g_client_code IS NOT NULL THEN
            add_where_clause('rs.item_id in (select DISTINCT inventory_item_id from mtl_system_items_b where wms_deploy.get_client_code(inventory_item_id) = :rcv_client_code) ', 'RECEIVING');
            add_bind_variable('rcv_client_code', inv_mwb_globals.g_client_code);
         END IF;
         -- ER(9158529 client)

         IF inv_mwb_globals.g_inventory_item_id IS NOT NULL THEN
            add_where_clause('rs.item_id = :rcv_item_id', 'RECEIVING');
            add_bind_variable('rcv_item_id', inv_mwb_globals.g_inventory_item_id);
         END IF;

         IF inv_mwb_globals.g_inventory_item_id IS NULL
         AND inv_mwb_globals.g_item_description IS NOT NULL THEN
            inv_mwb_query_manager.add_from_clause('mtl_system_items_b msib','RECEIVING');
            add_where_clause('msib.inventory_item_id = rs.item_id', 'RECEIVING');
            add_where_clause('msib.organization_id = rs.to_organization_id', 'RECEIVING');
            add_where_clause('msib.description LIKE :rcv_item_description', 'RECEIVING');
            add_bind_variable('rcv_item_description', inv_mwb_globals.g_item_description);
         END IF;

         IF inv_mwb_globals.g_revision IS NOT NULL THEN
            add_where_clause('rs.item_revision = :rcv_item_revision', 'RECEIVING');
            add_bind_variable('rcv_item_revision', inv_mwb_globals.g_revision);
         END IF;

         -- ER(9158529)
         IF inv_mwb_globals.g_category_set_id IS NOT NULL THEN
            add_where_clause('rs.item_id in '
                                 || ' (select DISTINCT inventory_item_id from mtl_item_categories '
                                 || ' where organization_id = :rcv_to_organization_id '
                                 || ' and category_set_id = :rcv_category_set_id '
                                 || ' and category_id = nvl(:rcv_category_id, category_id))', 'RECEIVING');
            add_bind_variable('rcv_to_organization_id', inv_mwb_globals.g_organization_id);
            add_bind_variable('rcv_category_set_id', inv_mwb_globals.g_category_set_id);
            add_bind_variable('rcv_category_id', inv_mwb_globals.g_category_id);
         END IF;
         -- ER(9158529)

         IF inv_mwb_globals.g_lpn_from_id IS NOT NULL
         OR inv_mwb_globals.g_lpn_to_id IS NOT NULL THEN
            inv_mwb_query_manager.add_from_clause(' wms_license_plate_numbers wlpn ','RECEIVING');
            add_where_clause('rs.lpn_id = wlpn.lpn_id', 'RECEIVING');
         END IF;

         IF (inv_mwb_globals.g_lpn_from_id IS NOT NULL AND
             inv_mwb_globals.g_lpn_to_id IS NOT NULL AND
             inv_mwb_globals.g_lpn_from_id = inv_mwb_globals.g_lpn_to_id) THEN
             add_where_clause('rs.lpn_id = :rcv_lpn_from_id', 'RECEIVING');
             add_bind_variable('rcv_lpn_from_id', inv_mwb_globals.g_lpn_from_id);
         END IF;

         IF (inv_mwb_globals.g_lpn_from_id IS NOT NULL AND
             inv_mwb_globals.g_lpn_from_id <> NVL(inv_mwb_globals.g_lpn_to_id, -1) ) THEN
             add_where_clause('wlpn.license_plate_number >= :rcv_lpn_from', 'RECEIVING');
             add_bind_variable('rcv_lpn_from', inv_mwb_globals.g_lpn_from);
         END IF;

         IF (inv_mwb_globals.g_lpn_to_id IS NOT NULL AND
             inv_mwb_globals.g_lpn_to_id <> NVL(inv_mwb_globals.g_lpn_from_id, -1) ) THEN
             add_where_clause('wlpn.license_plate_number <= :rcv_lpn_to', 'RECEIVING');
             add_bind_variable('rcv_lpn_to', inv_mwb_globals.g_lpn_to);
         END IF;

      ELSIF p_flag = 'MSN_RECEIVING' THEN

         inv_mwb_query_manager.add_from_clause(' mtl_serial_numbers msn ','RECEIVING');
         add_where_clause('msn.current_status = 7', 'RECEIVING');

         /* Bug 8225619. Adding ELSE CONDITION code such that right side grid
            retrieves the organizations which are relevant to particular
            responsibility id and responisibility application id */
         IF inv_mwb_globals.g_organization_id IS NOT NULL THEN
            add_where_clause('msn.current_organization_id = :rcv_to_organization_id', 'RECEIVING');
            add_bind_variable('rcv_to_organization_id', inv_mwb_globals.g_organization_id);
         ELSE
            add_where_clause(' EXISTS ( SELECT 1 FROM org_access_view oav WHERE oav.organization_id = msn.current_organization_id AND oav.responsibility_id   = :responsibility_id AND oav.resp_application_id = :resp_application_id ) ', 'RECEIVING');
            add_bind_variable('responsibility_id', inv_mwb_globals.g_responsibility_id);
            add_bind_variable('resp_application_id', inv_mwb_globals.g_resp_application_id);
         END IF;
         /* End of Bug 8225619*/

         IF inv_mwb_globals.g_subinventory_code IS NOT NULL THEN
            add_where_clause('msn.current_subinventory_code = :rcv_to_subinventory_code', 'RECEIVING');
            add_bind_variable('rcv_to_subinventory_code', inv_mwb_globals.g_subinventory_code);
         END IF;

         IF inv_mwb_globals.g_locator_id IS NOT NULL THEN
            add_where_clause('msn.current_locator_id = :rcv_to_locator_id', 'RECEIVING');
            add_bind_variable('rcv_to_locator_id', inv_mwb_globals.g_locator_id);
         END IF;

         -- ER(9158529 client)
         IF inv_mwb_globals.g_client_code IS NOT NULL THEN
            add_where_clause('msn.inventory_item_id in (select DISTINCT inventory_item_id from mtl_system_items_b where wms_deploy.get_client_code(inventory_item_id) = :rcv_client_code) ', 'RECEIVING');
            add_bind_variable('rcv_client_code', inv_mwb_globals.g_client_code);
         END IF;
         -- ER(9158529 client)

         IF inv_mwb_globals.g_inventory_item_id IS NOT NULL THEN
            add_where_clause('msn.inventory_item_id = :rcv_item_id', 'RECEIVING');
            add_bind_variable('rcv_item_id', inv_mwb_globals.g_inventory_item_id);
         END IF;

         IF inv_mwb_globals.g_inventory_item_id IS NULL
         AND inv_mwb_globals.g_item_description IS NOT NULL THEN
            inv_mwb_query_manager.add_from_clause('mtl_system_items_kfv msik','RECEIVING');
            add_where_clause('msik.inventory_item_id = msn.inventory_item_id', 'RECEIVING');
            add_where_clause('msik.organization_id = msn.current_organization_id', 'RECEIVING');
            add_where_clause('msik.description LIKE '':rcv_item_description''', 'RECEIVING');
            add_bind_variable('rcv_item_description', inv_mwb_globals.g_item_description);
         END IF;

         IF inv_mwb_globals.g_revision IS NOT NULL THEN
            add_where_clause('msn.revision = :rcv_item_revision', 'RECEIVING');
            add_bind_variable('rcv_item_revision', inv_mwb_globals.g_revision);
         END IF;

         -- ER(9158529)
         IF inv_mwb_globals.g_category_set_id IS NOT NULL THEN
            add_where_clause('msn.inventory_item_id in '
                                || ' (select DISTINCT inventory_item_id from mtl_item_categories '
                                || ' where organization_id = :rcv_to_organization_id '
                                || ' and category_set_id = :rcv_category_set_id '
                                || ' and category_id = nvl(:rcv_category_id, category_id))', 'RECEIVING');
            add_bind_variable('rcv_to_organization_id', inv_mwb_globals.g_organization_id);
            add_bind_variable('rcv_category_set_id', inv_mwb_globals.g_category_set_id);
            add_bind_variable('rcv_category_id', inv_mwb_globals.g_category_id);
         END IF;
         -- ER(9158529)

         IF inv_mwb_globals.g_lpn_from_id IS NOT NULL
         OR inv_mwb_globals.g_lpn_to_id IS NOT NULL THEN
            inv_mwb_query_manager.add_from_clause(' wms_license_plate_numbers wlpn ','RECEIVING');
            add_where_clause('msn.lpn_id = wlpn.lpn_id', 'RECEIVING');
         END IF;

         IF (inv_mwb_globals.g_lpn_from_id IS NOT NULL AND
             inv_mwb_globals.g_lpn_to_id IS NOT NULL AND
             inv_mwb_globals.g_lpn_from_id = inv_mwb_globals.g_lpn_to_id) THEN
             add_where_clause('msn.lpn_id = :rcv_lpn_from_id', 'RECEIVING');
             add_bind_variable('rcv_lpn_from_id', inv_mwb_globals.g_lpn_from_id);
         END IF;

         IF (inv_mwb_globals.g_lpn_from_id IS NOT NULL AND
             inv_mwb_globals.g_lpn_from_id <> NVL(inv_mwb_globals.g_lpn_to_id, -1) ) THEN
             add_where_clause('wlpn.license_plate_number >= :rcv_lpn_from', 'RECEIVING');
             add_bind_variable('rcv_lpn_from', inv_mwb_globals.g_lpn_from);
         END IF;

         IF (inv_mwb_globals.g_lpn_to_id IS NOT NULL AND
             inv_mwb_globals.g_lpn_to_id <> NVL(inv_mwb_globals.g_lpn_from_id, -1) ) THEN
             add_where_clause('wlpn.license_plate_number <= :rcv_lpn_to', 'RECEIVING');
             add_bind_variable('rcv_lpn_to', inv_mwb_globals.g_lpn_to);
         END IF;

         IF (inv_mwb_globals.g_serial_from IS NOT NULL AND
            inv_mwb_globals.g_serial_to IS NOT NULL AND
            inv_mwb_globals.g_serial_from = inv_mwb_globals.g_serial_to) THEN
            add_where_clause('msn.serial_number = :rcv_serial_from', 'RECEIVING');
            add_bind_variable('rcv_serial_from', inv_mwb_globals.g_serial_from);
         END IF;

         IF (inv_mwb_globals.g_serial_from IS NOT NULL AND
             inv_mwb_globals.g_serial_from <> NVL(inv_mwb_globals.g_serial_to, -1) ) THEN
             add_where_clause('msn.serial_number >= :rcv_serial_from', 'RECEIVING');
             add_bind_variable('rcv_serial_from', inv_mwb_globals.g_serial_from);
         END IF;

         IF (inv_mwb_globals.g_serial_to IS NOT NULL AND
             inv_mwb_globals.g_serial_to <> NVL(inv_mwb_globals.g_serial_from, -1) ) THEN
             add_where_clause('msn.serial_num <= :rcv_serial_to', 'RECEIVING');
             add_bind_variable('rcv_serial_to', inv_mwb_globals.g_serial_to);
         END IF;

         IF (inv_mwb_globals.g_lot_from IS NOT NULL AND
             inv_mwb_globals.g_lot_to IS NOT NULL AND
             inv_mwb_globals.g_lot_from = inv_mwb_globals.g_lot_to) THEN
             add_where_clause('msn.lot_number = :rcv_lot_from', 'RECEIVING');
             add_bind_variable('rcv_lot_from', inv_mwb_globals.g_lot_from);
         END IF;

         IF (inv_mwb_globals.g_lot_from IS NOT NULL AND
            inv_mwb_globals.g_lot_from <> NVL(inv_mwb_globals.g_lot_to, -1) ) THEN
            add_where_clause('msn.lot_number >= :rcv_lot_from', 'RECEIVING');
            add_bind_variable('rcv_lot_from', inv_mwb_globals.g_lot_from);
         END IF;

         IF (inv_mwb_globals.g_lot_to IS NOT NULL AND
             inv_mwb_globals.g_lot_to <> NVL(inv_mwb_globals.g_lot_from, -1) ) THEN
             add_where_clause('msn.lot_number <= :rcv_lot_to', 'RECEIVING');
             add_bind_variable('rcv_lot_to', inv_mwb_globals.g_lot_to);
         END IF;

/* Bug 8396954, Adding below if condition for checking supplier_lot_number condition */
        IF (inv_mwb_globals.g_supplier_lot_from IS NOT NULL OR
            inv_mwb_globals.g_supplier_lot_to IS NOT NULL ) THEN
            inv_mwb_query_manager.add_from_clause('mtl_lot_numbers mln3', 'RECEIVING');
            add_where_clause('msn.lot_number =mln3.lot_number', 'RECEIVING');

            IF (inv_mwb_globals.g_supplier_lot_from IS NOT NULL AND
               inv_mwb_globals.g_supplier_lot_to IS NOT NULL AND
               inv_mwb_globals.g_supplier_lot_from = inv_mwb_globals.g_supplier_lot_to) THEN
               add_where_clause('mln3.supplier_lot_number = :rcv_supplier_lot_from', 'RECEIVING');
               add_bind_variable('rcv_supplier_lot_from', inv_mwb_globals.g_supplier_lot_from);
            END IF;

            IF (inv_mwb_globals.g_supplier_lot_from IS NOT NULL AND
               inv_mwb_globals.g_supplier_lot_from <> NVL(inv_mwb_globals.g_supplier_lot_to, -1) ) THEN
               add_where_clause('mln3.supplier_lot_number >= :rcv_supplier_lot_from', 'RECEIVING');
               add_bind_variable('rcv_supplier_lot_from', inv_mwb_globals.g_supplier_lot_from);
            END IF;

            IF (inv_mwb_globals.g_supplier_lot_to IS NOT NULL AND
               inv_mwb_globals.g_supplier_lot_to <> NVL(inv_mwb_globals.g_supplier_lot_from, -1) ) THEN
               add_where_clause('mln3.supplier_lot_number <= :rcv_supplier_lot_to', 'RECEIVING');
               add_bind_variable('rcv_supplier_lot_to', inv_mwb_globals.g_supplier_lot_to);
            END IF;
        END IF;
/* End of Bug 8396954 */

      ELSIF p_flag = 'MSN' THEN

         inv_mwb_query_manager.add_from_clause(' rcv_supply rs ','RECEIVING');
         inv_mwb_query_manager.add_from_clause('rcv_serials_supply rss','RECEIVING');
         add_where_clause('rs.shipment_line_id = rss.shipment_line_id (+) ', 'RECEIVING');

         /* Bug 8225619. Adding ELSE CONDITION code such that right side grid
            retrieves the organizations which are relevant to particular
            responsibility id and responisibility application id */
         IF inv_mwb_globals.g_organization_id IS NOT NULL THEN
            add_where_clause('rs.to_organization_id = :rcv_to_organization_id', 'RECEIVING');
            add_bind_variable('rcv_to_organization_id', inv_mwb_globals.g_organization_id);
         ELSE
            add_where_clause(' EXISTS ( SELECT 1 FROM org_access_view oav WHERE oav.organization_id = rs.to_organization_id AND oav.responsibility_id   = :responsibility_id AND oav.resp_application_id = :resp_application_id ) ', 'RECEIVING');
            add_bind_variable('responsibility_id', inv_mwb_globals.g_responsibility_id);
            add_bind_variable('resp_application_id', inv_mwb_globals.g_resp_application_id);
         END IF;
         /* End of Bug 8225619*/

         IF inv_mwb_globals.g_subinventory_code IS NOT NULL THEN
            add_where_clause('rs.to_subinventory = :rcv_to_subinventory_code', 'RECEIVING');
            add_bind_variable('rcv_to_subinventory_code', inv_mwb_globals.g_subinventory_code);
         END IF;

         IF inv_mwb_globals.g_locator_id IS NOT NULL THEN
            add_where_clause('rs.to_locator_id = :rcv_to_locator_id', 'RECEIVING');
            add_bind_variable('rcv_to_locator_id', inv_mwb_globals.g_locator_id);
         END IF;

         -- ER(9158529 client)
         IF inv_mwb_globals.g_client_code IS NOT NULL THEN
            add_where_clause('rs.item_id in (select DISTINCT inventory_item_id from mtl_system_items_b where wms_deploy.get_client_code(inventory_item_id) = :rcv_client_code) ', 'RECEIVING');
            add_bind_variable('rcv_client_code', inv_mwb_globals.g_client_code);
         END IF;
         -- ER(9158529 client)

         IF inv_mwb_globals.g_inventory_item_id IS NOT NULL THEN
            add_where_clause('rs.item_id = :rcv_item_id', 'RECEIVING');
            add_bind_variable('rcv_item_id', inv_mwb_globals.g_inventory_item_id);
         END IF;

         IF inv_mwb_globals.g_inventory_item_id IS NULL
         AND inv_mwb_globals.g_item_description IS NOT NULL THEN
            inv_mwb_query_manager.add_from_clause('mtl_system_items_b msib','RECEIVING');
            add_where_clause('msib.inventory_item_id = rs.item_id', 'RECEIVING');
            add_where_clause('msib.organization_id = rs.to_organization_id', 'RECEIVING');
            add_where_clause('msib.description LIKE :rcv_item_description', 'RECEIVING');
            add_bind_variable('rcv_item_description', inv_mwb_globals.g_item_description);
         END IF;

         IF inv_mwb_globals.g_revision IS NOT NULL THEN
            add_where_clause('rs.item_revision = :rcv_item_revision', 'RECEIVING');
            add_bind_variable('rcv_item_revision', inv_mwb_globals.g_revision);
         END IF;

         -- ER(9158529)
         IF inv_mwb_globals.g_category_set_id IS NOT NULL THEN
            add_where_clause('rs.item_id in '
                                || ' (select DISTINCT inventory_item_id from mtl_item_categories '
                                || ' where organization_id = :rcv_to_organization_id '
                                || ' and category_set_id = :rcv_category_set_id '
                                || ' and category_id = nvl(:rcv_category_id, category_id))', 'RECEIVING');
            add_bind_variable('rcv_to_organization_id', inv_mwb_globals.g_organization_id);
            add_bind_variable('rcv_category_set_id', inv_mwb_globals.g_category_set_id);
            add_bind_variable('rcv_category_id', inv_mwb_globals.g_category_id);
         END IF;
         -- ER(9158529)

         IF inv_mwb_globals.g_lpn_from_id IS NOT NULL
         OR inv_mwb_globals.g_lpn_to_id IS NOT NULL THEN
            inv_mwb_query_manager.add_from_clause(' wms_license_plate_numbers wlpn ','RECEIVING');
            add_where_clause('rs.lpn_id = wlpn.lpn_id', 'RECEIVING');
         END IF;

         IF (inv_mwb_globals.g_lpn_from_id IS NOT NULL AND
             inv_mwb_globals.g_lpn_to_id IS NOT NULL AND
             inv_mwb_globals.g_lpn_from_id = inv_mwb_globals.g_lpn_to_id) THEN
             add_where_clause('rs.lpn_id = :rcv_lpn_from_id', 'RECEIVING');
             add_bind_variable('rcv_lpn_from_id', inv_mwb_globals.g_lpn_from_id);
         END IF;

         IF (inv_mwb_globals.g_lpn_from_id IS NOT NULL AND
             inv_mwb_globals.g_lpn_from_id <> NVL(inv_mwb_globals.g_lpn_to_id, -1) ) THEN
             add_where_clause('wlpn.license_plate_number >= :rcv_lpn_from', 'RECEIVING');
             add_bind_variable('rcv_lpn_from', inv_mwb_globals.g_lpn_from);
         END IF;

         IF (inv_mwb_globals.g_lpn_to_id IS NOT NULL AND
             inv_mwb_globals.g_lpn_to_id <> NVL(inv_mwb_globals.g_lpn_from_id, -1) ) THEN
             add_where_clause('wlpn.license_plate_number <= :rcv_lpn_to', 'RECEIVING');
             add_bind_variable('rcv_lpn_to', inv_mwb_globals.g_lpn_to);
         END IF;

	      IF (inv_mwb_globals.g_serial_from IS NOT NULL AND
             inv_mwb_globals.g_serial_to IS NOT NULL AND
             inv_mwb_globals.g_serial_from = inv_mwb_globals.g_serial_to) THEN
             add_where_clause('rss.serial_num = :rcv_serial_from', 'RECEIVING');
             add_bind_variable('rcv_serial_from', inv_mwb_globals.g_serial_from);
         END IF;

         IF (inv_mwb_globals.g_serial_from IS NOT NULL AND
             inv_mwb_globals.g_serial_from <> NVL(inv_mwb_globals.g_serial_to, -1) ) THEN
             add_where_clause('rss.serial_num >= :rcv_serial_from', 'RECEIVING');
             add_bind_variable('rcv_serial_from', inv_mwb_globals.g_serial_from);
         END IF;

         IF (inv_mwb_globals.g_serial_to IS NOT NULL AND
             inv_mwb_globals.g_serial_to <> NVL(inv_mwb_globals.g_serial_from, -1) ) THEN
             add_where_clause('rss.serial_num <= :rcv_serial_to', 'RECEIVING');
             add_bind_variable('rcv_serial_to', inv_mwb_globals.g_serial_to);
         END IF;

         IF (inv_mwb_globals.g_lot_from IS NOT NULL AND
             inv_mwb_globals.g_lot_to IS NOT NULL AND
             inv_mwb_globals.g_lot_from = inv_mwb_globals.g_lot_to) THEN
             add_where_clause('rss.lot_num = :rcv_lot_from', 'RECEIVING');
             add_bind_variable('rcv_lot_from', inv_mwb_globals.g_lot_from);
         END IF;

         IF (inv_mwb_globals.g_lot_from IS NOT NULL AND
            inv_mwb_globals.g_lot_from <> NVL(inv_mwb_globals.g_lot_to, -1) ) THEN
            add_where_clause('rss.lot_num >= :rcv_lot_from', 'RECEIVING');
            add_bind_variable('rcv_lot_from', inv_mwb_globals.g_lot_from);
         END IF;

         IF (inv_mwb_globals.g_lot_to IS NOT NULL AND
             inv_mwb_globals.g_lot_to <> NVL(inv_mwb_globals.g_lot_from, -1) ) THEN
             add_where_clause('rss.lot_num <= :rcv_lot_to', 'RECEIVING');
             add_bind_variable('rcv_lot_to', inv_mwb_globals.g_lot_to);
         END IF;

/* Bug 8396954, Adding below if condition for checking supplier_lot_number condition */
         IF (inv_mwb_globals.g_supplier_lot_from IS NOT NULL OR
             inv_mwb_globals.g_supplier_lot_to IS NOT NULL ) THEN
             inv_mwb_query_manager.add_from_clause('mtl_lot_numbers mln3', 'RECEIVING');
             add_where_clause('mln3.lot_number = rss.lot_num', 'RECEIVING');

              IF (inv_mwb_globals.g_supplier_lot_from IS NOT NULL AND
                  inv_mwb_globals.g_supplier_lot_to IS NOT NULL AND
                  inv_mwb_globals.g_supplier_lot_from = inv_mwb_globals.g_supplier_lot_to) THEN
                  add_where_clause('mln3.supplier_lot_number = :rcv_supplier_lot_from', 'RECEIVING');
                  add_bind_variable('rcv_supplier_lot_from', inv_mwb_globals.g_supplier_lot_from);
              END IF;
              IF (inv_mwb_globals.g_supplier_lot_from IS NOT NULL AND
                  inv_mwb_globals.g_supplier_lot_from <> NVL(inv_mwb_globals.g_supplier_lot_to, -1) ) THEN
                  add_where_clause('mln3.supplier_lot_number >= :rcv_supplier_lot_from', 'RECEIVING');
                  add_bind_variable('rcv_supplier_lot_from', inv_mwb_globals.g_supplier_lot_from);
              END IF;

              IF (inv_mwb_globals.g_supplier_lot_to IS NOT NULL AND
                  inv_mwb_globals.g_supplier_lot_to <> NVL(inv_mwb_globals.g_supplier_lot_from, -1) ) THEN
                  add_where_clause('mln3.supplier_lot_number <= :rcv_supplier_lot_to', 'RECEIVING');
                  add_bind_variable('rcv_supplier_lot_to', inv_mwb_globals.g_supplier_lot_to);
              END IF;
         END IF ;
/* End of Bug 8396954 */

      END IF;
      inv_mwb_globals.print_msg(g_pkg_name, l_procedure_name, 'exited');
  END add_qf_where_receiving;

   PROCEDURE add_qf_where_inbound(p_flag VARCHAR2) IS
      l_procedure_name VARCHAR2(30);
      l_rev_control    NUMBER;
      l_lot_control    NUMBER;
      l_serial_control NUMBER;
   BEGIN
      l_procedure_name := 'ADD_QF_WHERE_INBOUND';
      inv_mwb_globals.print_msg(g_pkg_name, l_procedure_name, 'Entered');

      IF inv_mwb_globals.g_tree_item_id IS NOT NULL
      AND inv_mwb_globals.g_tree_organization_id IS NOT NULL THEN

         SELECT revision_qty_control_code,
                lot_control_code,
                serial_number_control_code
           INTO l_rev_control,
                l_lot_control,
                l_serial_control
           FROM mtl_system_items
          WHERE inventory_item_id = inv_mwb_globals.g_tree_item_id
            AND organization_id = inv_mwb_globals.g_tree_organization_id;

      END IF;

      inv_mwb_query_manager.add_from_clause(' mtl_supply ms ','INBOUND');
      inv_mwb_query_manager.add_where_clause('ms.supply_type_code <> ''RECEIVING''','INBOUND');
      inv_mwb_query_manager.add_where_clause('ms.destination_type_code = ''INVENTORY''','INBOUND');
      IF inv_mwb_globals.g_po_header_id IS NOT NULL
      OR inv_mwb_globals.g_vendor_id IS NOT NULL
      OR inv_mwb_globals.g_shipment_header_id_asn IS NOT NULL
      OR inv_mwb_globals.g_vendor_item IS NOT NULL THEN

         inv_mwb_globals.print_msg(g_pkg_name, l_procedure_name, 'Supplier tab');

         inv_mwb_query_manager.add_from_clause('po_headers_trx_v pha','INBOUND');     -- CLM project, bug 9403291
         inv_mwb_query_manager.add_where_clause(' pha.po_header_id = ms.po_header_id ','INBOUND');
         inv_mwb_query_manager.add_where_clause('pha.authorization_status = ''APPROVED''', 'INBOUND');

/*         IF inv_mwb_globals.g_include_po_without_asn = 1 THEN
            inv_mwb_query_manager.add_where_clause(' ms.supply_type_code IN (''PO'',''SHIPMENT'')','INBOUND');
         ELSIF inv_mwb_globals.g_include_po_without_asn = 0 THEN
            inv_mwb_query_manager.add_where_clause(' ms.supply_type_code = ''SHIPMENT''','INBOUND');
--            inv_mwb_query_manager.add_where_clause(' ms.shipment_header_id IS NULL','INBOUND');
         END IF;
*/

         IF inv_mwb_globals.g_vendor_id IS NOT NULL THEN
            add_where_clause('pha.vendor_id = :inb_vendor_id', 'INBOUND');
            add_bind_variable('inb_vendor_id', inv_mwb_globals.g_vendor_id);
            IF inv_mwb_globals.g_vendor_site_id IS NOT NULL THEN
               add_where_clause('pha.vendor_site_id = :inb_vendor_site_id', 'INBOUND');
               add_bind_variable('inb_vendor_site_id', inv_mwb_globals.g_vendor_site_id);
            END IF;
         END IF;

         IF inv_mwb_globals.g_vendor_item IS NOT NULL THEN
            inv_mwb_query_manager.add_from_clause('po_lines_trx_v pla ','INBOUND');                  -- CLM project, bug 9403291
            inv_mwb_query_manager.add_where_clause('ms.po_line_id = pla.po_line_id', 'INBOUND');
            inv_mwb_query_manager.add_where_clause('pla.vendor_product_num = :inb_vendor_item', 'INBOUND');
            add_bind_variable('inb_vendor_item', inv_mwb_globals.g_vendor_item);
         END IF;

         IF inv_mwb_globals.g_po_header_id IS NOT NULL THEN
            inv_mwb_query_manager.add_where_clause(' ms.po_header_id = :inb_po_header_id ','INBOUND');
            inv_mwb_query_manager.add_where_clause(' ms.supply_type_code = ''PO'' ','INBOUND');
            add_bind_variable('inb_po_header_id', inv_mwb_globals.g_po_header_id);
         END IF;

         IF  inv_mwb_globals.g_po_release_id IS NOT NULL THEN
            add_where_clause('ms.po_release_id = :inb_po_release_id', 'INBOUND');
            add_bind_variable('inb_po_release_id', inv_mwb_globals.g_po_release_id);
         END IF;

         IF inv_mwb_globals.g_shipment_header_id_asn IS NOT NULL
         OR inv_mwb_globals.g_tree_doc_type_id IN (3,4) THEN
            inv_mwb_query_manager.add_from_clause(' rcv_shipment_headers rsh ','INBOUND');
            add_where_clause('rsh.shipment_header_id(+) = ms.shipment_header_id', 'INBOUND');
         END IF;

         IF inv_mwb_globals.g_shipment_header_id_asn IS NOT NULL THEN
            inv_mwb_query_manager.add_where_clause(' rsh.shipment_header_id = :inb_shipment_header_id_asn ','INBOUND');
            add_bind_variable('inb_shipment_header_id_asn', inv_mwb_globals.g_shipment_header_id_asn);
         END IF;

         IF inv_mwb_globals.g_tree_parent_lpn_id IS NOT NULL
         OR inv_mwb_globals.g_tree_doc_type_id IN (3,4) THEN
            inv_mwb_query_manager.add_from_clause(' rcv_shipment_lines rsl ','INBOUND');
            add_where_clause('rsl.shipment_line_id = ms.shipment_line_id', 'INBOUND');
         END IF;

         IF inv_mwb_globals.g_tree_parent_lpn_id IS NOT NULL THEN
            inv_mwb_query_manager.add_where_clause(' rsl.asn_lpn_id = :inb_asn_lpn_id ','INBOUND');
            add_bind_variable('inb_asn_lpn_id', inv_mwb_globals.g_tree_parent_lpn_id);
         END IF;

         IF inv_mwb_globals.g_organization_id IS NOT NULL THEN
            add_where_clause('ms.to_organization_id = :inb_to_organization_id', 'INBOUND');
            add_bind_variable('inb_to_organization_id', inv_mwb_globals.g_organization_id);
         END IF;

         -- ER(9158529 client)
         IF inv_mwb_globals.g_client_code IS NOT NULL THEN
            add_where_clause('ms.item_id in (select DISTINCT inventory_item_id from mtl_system_items_b where wms_deploy.get_client_code(inventory_item_id) = :inb_client_code) ', 'INBOUND');
            add_bind_variable('inb_client_code', inv_mwb_globals.g_client_code);
         END IF;
         -- ER(9158529 client)

         IF inv_mwb_globals.g_inventory_item_id IS NOT NULL THEN
            add_where_clause('ms.item_id = :inb_item_id', 'INBOUND');
            add_bind_variable('inb_item_id', inv_mwb_globals.g_inventory_item_id);
         END IF;

         IF inv_mwb_globals.g_cost_group_id IS NOT NULL THEN
            add_where_clause('ms.cost_group_id = :inb_cost_group_id', 'INBOUND');
            add_bind_variable('inb_cost_group_id', inv_mwb_globals.g_cost_group_id);
         END IF;

         -- ER(9158529)
         IF inv_mwb_globals.g_category_set_id IS NOT NULL THEN
            add_where_clause('ms.item_id in '
                                || ' (select DISTINCT inventory_item_id from mtl_item_categories '
                                || ' where organization_id = :inb_to_organization_id '
                                || ' and category_set_id = :inb_category_set_id '
                                || ' and category_id = nvl(:inb_category_id, category_id))', 'INBOUND');
            add_bind_variable('inb_to_organization_id', inv_mwb_globals.g_organization_id);
            add_bind_variable('inb_category_set_id', inv_mwb_globals.g_category_set_id);
            add_bind_variable('inb_category_id', inv_mwb_globals.g_category_id);
         END IF;
         -- ER(9158529)

         IF (inv_mwb_globals.g_expected_from_date IS NOT NULL AND
            inv_mwb_globals.g_expected_to_date IS NOT NULL AND
            inv_mwb_globals.g_expected_from_date = inv_mwb_globals.g_expected_to_date) THEN
            add_where_clause('ms.expected_delivery_date = :inb_expected_from_date', 'INBOUND');
            add_bind_variable('inb_expected_from_date', inv_mwb_globals.g_expected_from_date);
         END IF;

         IF inv_mwb_globals.g_expected_from_date IS NOT NULL THEN
            add_where_clause('ms.expected_delivery_date >= :inb_expected_from_date', 'INBOUND');
            add_bind_variable('inb_expected_from_date', inv_mwb_globals.g_expected_from_date);
         END IF;

         IF inv_mwb_globals.g_expected_to_date IS NOT NULL THEN
            add_where_clause('ms.expected_delivery_date <= :inb_expected_to_date', 'INBOUND');
            add_bind_variable('inb_expected_to_date', inv_mwb_globals.g_expected_to_date);
         END IF;

         IF inv_mwb_globals.g_inventory_item_id IS NULL
         AND inv_mwb_globals.g_item_description IS NOT NULL THEN
            add_from_clause(' mtl_system_items_kfv msik ','INBOUND');
            add_where_clause(' ms.item_id = msik.inventory_item_id ', 'INBOUND');
            add_where_clause(' ms.to_organization_id = msik.organization_id ', 'INBOUND');
            add_where_clause(' msik.description like :inb_item_description ', 'INBOUND');
            add_bind_variable('inb_item_description', inv_mwb_globals.g_item_description);
         END IF;


         IF (inv_mwb_globals.g_lot_from IS NOT NULL
         OR  inv_mwb_globals.g_lot_to IS NOT NULL)
         OR (inv_mwb_globals.g_tree_item_id IS NOT NULL
             AND l_lot_control = 2) THEN
            inv_mwb_query_manager.add_from_clause(' rcv_lots_supply rls ','INBOUND');
            add_where_clause('rls.shipment_line_id(+) = ms.shipment_line_id ', 'INBOUND');
         END IF;

         IF (inv_mwb_globals.g_lot_from IS NOT NULL AND
         inv_mwb_globals.g_lot_to IS NOT NULL AND
         inv_mwb_globals.g_lot_from = inv_mwb_globals.g_lot_to) THEN
            add_where_clause('rls.lot_num = :inb_lot_from', 'INBOUND');
            add_bind_variable('inb_lot_from', inv_mwb_globals.g_lot_from);
         END IF;

         IF (inv_mwb_globals.g_lot_from IS NOT NULL AND
         inv_mwb_globals.g_lot_from <> NVL(inv_mwb_globals.g_lot_to, -1) ) THEN
           add_where_clause('rls.lot_num >= :inb_lot_from', 'INBOUND');
           add_bind_variable('inb_lot_from', inv_mwb_globals.g_lot_from);
         END IF;

         IF (inv_mwb_globals.g_lot_to IS NOT NULL AND
         inv_mwb_globals.g_lot_to <> NVL(inv_mwb_globals.g_lot_from, -1) ) THEN
           add_where_clause('rls.lot_num <= :inb_lot_to', 'INBOUND');
           add_bind_variable('inb_lot_to', inv_mwb_globals.g_lot_to);
         END IF;

/* Bug 8396954, Adding below if condition for checking supplier_lot_number condition */
         IF (inv_mwb_globals.g_supplier_lot_from IS NOT NULL OR
               inv_mwb_globals.g_supplier_lot_to IS NOT NULL ) THEN
               inv_mwb_query_manager.add_from_clause('mtl_lot_numbers mln3', 'INBOUND');
                IF NOT ((inv_mwb_globals.g_lot_from IS NOT NULL
                  OR  inv_mwb_globals.g_lot_to IS NOT NULL)
                  OR (inv_mwb_globals.g_tree_item_id IS NOT NULL
                  AND l_lot_control = 2)) THEN
                    inv_mwb_query_manager.add_from_clause(' rcv_lots_supply rls ','INBOUND');
                    add_where_clause('rls.shipment_line_id(+) = ms.shipment_line_id ', 'INBOUND');
                END IF;
               add_where_clause('mln3.lot_number = rls.lot_num', 'INBOUND');

                IF (inv_mwb_globals.g_supplier_lot_from IS NOT NULL AND
                    inv_mwb_globals.g_supplier_lot_to IS NOT NULL AND
                    inv_mwb_globals.g_supplier_lot_from = inv_mwb_globals.g_supplier_lot_to) THEN
                    add_where_clause('mln3.supplier_lot_number = :inb_supplier_lot_from', 'INBOUND');
                    add_bind_variable('inb_supplier_lot_from', inv_mwb_globals.g_supplier_lot_from);
                END IF;

                IF (inv_mwb_globals.g_supplier_lot_from IS NOT NULL AND
                       inv_mwb_globals.g_supplier_lot_from <> NVL(inv_mwb_globals.g_supplier_lot_to, -1) ) THEN
                           add_where_clause('mln3.supplier_lot_number >= :inb_supplier_lot_from', 'INBOUND');
                   add_bind_variable('inb_supplier_lot_from', inv_mwb_globals.g_supplier_lot_from);
                END IF;

                IF (inv_mwb_globals.g_supplier_lot_to IS NOT NULL AND
                   inv_mwb_globals.g_supplier_lot_to <> NVL(inv_mwb_globals.g_supplier_lot_from, -1) ) THEN
                   add_where_clause('mln3.supplier_lot_number <= :inb_supplier_lot_to', 'INBOUND');
                 add_bind_variable('inb_supplier_lot_to', inv_mwb_globals.g_supplier_lot_to);
                END IF;
         END IF ;
/* End of Bug 8396954 */

         IF (inv_mwb_globals.g_serial_from IS NOT NULL
             OR inv_mwb_globals.g_serial_to IS NOT NULL)
            OR (inv_mwb_globals.g_tree_item_id IS NOT NULL
                AND l_serial_control = 2) THEN
            inv_mwb_query_manager.add_from_clause(' rcv_serials_supply rss ','INBOUND');
            add_where_clause('rss.shipment_line_id(+) = ms.shipment_line_id ', 'INBOUND');
         END IF;

         IF (inv_mwb_globals.g_serial_from IS NOT NULL AND
            inv_mwb_globals.g_serial_to IS NOT NULL AND
            inv_mwb_globals.g_serial_from = inv_mwb_globals.g_serial_to) THEN
            add_where_clause('rss.serial_num = :inb_serial_from', 'INBOUND');
            add_bind_variable('inb_serial_from', inv_mwb_globals.g_serial_from);
         END IF;

         IF (inv_mwb_globals.g_serial_from IS NOT NULL AND
            inv_mwb_globals.g_serial_from <> NVL(inv_mwb_globals.g_serial_to, -1) ) THEN
            add_where_clause('rss.serial_num >= :inb_serial_from', 'INBOUND');
            add_bind_variable('inb_serial_from', inv_mwb_globals.g_serial_from);
         END IF;

         IF (inv_mwb_globals.g_serial_to IS NOT NULL AND
            inv_mwb_globals.g_serial_to <> NVL(inv_mwb_globals.g_serial_from, -1) ) THEN
            add_where_clause('rss.serial_num <= :inb_serial_to', 'INBOUND');
            add_bind_variable('inb_serial_to', inv_mwb_globals.g_serial_to);
         END IF;

      ELSIF inv_mwb_globals.g_source_org_id IS NOT NULL
      OR inv_mwb_globals.g_req_header_id IS NOT NULL
      OR inv_mwb_globals.g_internal_order_id IS NOT NULL
      OR inv_mwb_globals.g_shipment_header_id_interorg IS NOT NULL THEN

         inv_mwb_globals.print_msg(g_pkg_name, l_procedure_name, 'Interorg tab');

         inv_mwb_query_manager.add_from_clause(' rcv_shipment_headers rsh ','INBOUND');
         inv_mwb_query_manager.add_from_clause(' rcv_shipment_lines rsl ','INBOUND');

         inv_mwb_query_manager.add_where_clause(' rsh.shipment_header_id(+) = ms.shipment_header_id ', 'INBOUND');
         inv_mwb_query_manager.add_where_clause(' rsl.shipment_line_id(+) = ms.shipment_line_id ', 'INBOUND');
         inv_mwb_query_manager.add_where_clause(' ms.supply_type_code IN (''REQ'',''SHIPMENT'') ', 'INBOUND');
         inv_mwb_query_manager.add_where_clause(' rsh.asn_type IS NULL ', 'INBOUND');


         IF inv_mwb_globals.g_shipment_header_id_interorg IS NOT NULL THEN
            add_where_clause(' rsh.shipment_header_id = :inb_shipment_header_id ', 'INBOUND');
            add_where_clause(' ms.supply_type_code = ''SHIPMENT'' ', 'INBOUND');
            add_bind_variable('inb_shipment_header_id', inv_mwb_globals.g_shipment_header_id_interorg);
         ELSIF inv_mwb_globals.g_req_header_id IS NOT NULL THEN
            inv_mwb_query_manager.add_where_clause(' ms.req_header_id = :inb_req_header_id ', 'INBOUND');
            add_bind_variable('inb_req_header_id', inv_mwb_globals.g_req_header_id);
         END IF;

         IF inv_mwb_globals.g_source_org_id IS NOT NULL THEN
            inv_mwb_query_manager.add_where_clause(' ms.from_organization_id = :inb_from_organization_id ', 'INBOUND');
            add_bind_variable('inb_from_organization_id', inv_mwb_globals.g_source_org_id);
         END IF;

         IF inv_mwb_globals.g_organization_id IS NOT NULL THEN
            add_where_clause('ms.to_organization_id = :inb_to_organization_id', 'INBOUND');
            add_bind_variable('inb_to_organization_id', inv_mwb_globals.g_organization_id);
         END IF;

         -- ER(9158529 client)
         IF inv_mwb_globals.g_client_code IS NOT NULL THEN
            add_where_clause('ms.item_id in (select DISTINCT inventory_item_id from mtl_system_items_b where wms_deploy.get_client_code(inventory_item_id) = :inb_client_code) ', 'INBOUND');
            add_bind_variable('inb_client_code', inv_mwb_globals.g_client_code);
         END IF;
         -- ER(9158529 client)

         IF inv_mwb_globals.g_inventory_item_id IS NOT NULL THEN
            add_where_clause('ms.item_id = :inb_item_id', 'INBOUND');
            add_bind_variable('inb_item_id', inv_mwb_globals.g_inventory_item_id);
         END IF;

         IF inv_mwb_globals.g_revision IS NOT NULL THEN
           add_where_clause('ms.item_revision = :inb_item_revision', 'INBOUND');
           add_bind_variable('inb_item_revision', inv_mwb_globals.g_revision);
         END IF;

         IF inv_mwb_globals.g_cost_group_id IS NOT NULL THEN
            add_where_clause('ms.cost_group_id = :inb_cost_group_id', 'INBOUND');
            add_bind_variable('inb_cost_group_id', inv_mwb_globals.g_cost_group_id);
         END IF;

         -- ER(9158529)
         IF inv_mwb_globals.g_category_set_id IS NOT NULL THEN
            add_where_clause('ms.item_id in '
                                || ' (select DISTINCT inventory_item_id from mtl_item_categories '
                                || ' where organization_id = :inb_to_organization_id '
                                || ' and category_set_id = :inb_category_set_id '
                                || ' and category_id = nvl(:inb_category_id, category_id))', 'INBOUND');
            add_bind_variable('inb_to_organization_id', inv_mwb_globals.g_organization_id);
            add_bind_variable('inb_category_set_id', inv_mwb_globals.g_category_set_id);
            add_bind_variable('inb_category_id', inv_mwb_globals.g_category_id);
         END IF;
         -- ER(9158529)

         IF (inv_mwb_globals.g_expected_from_date IS NOT NULL AND
            inv_mwb_globals.g_expected_to_date IS NOT NULL AND
            inv_mwb_globals.g_expected_from_date = inv_mwb_globals.g_expected_to_date) THEN
            add_where_clause('ms.expected_delivery_date = :inb_expected_from_date', 'INBOUND');
            add_bind_variable('inb_expected_from_date', inv_mwb_globals.g_expected_from_date);
         END IF;

         IF inv_mwb_globals.g_expected_from_date IS NOT NULL THEN
            add_where_clause('ms.expected_delivery_date >= :inb_expected_from_date', 'INBOUND');
            add_bind_variable('inb_expected_from_date', inv_mwb_globals.g_expected_from_date);
         END IF;

         IF inv_mwb_globals.g_expected_to_date IS NOT NULL THEN
            add_where_clause('ms.expected_delivery_date <= :inb_expected_to_date', 'INBOUND');
            add_bind_variable('inb_expected_to_date', inv_mwb_globals.g_expected_to_date);
         END IF;

         IF inv_mwb_globals.g_lpn_from_id IS NOT NULL
         OR inv_mwb_globals.g_lpn_to_id IS NOT NULL THEN
            inv_mwb_query_manager.add_from_clause(' wms_license_plate_numbers wlpn ','INBOUND');
            add_where_clause('rsl.asn_lpn_id = wlpn.lpn_id', 'INBOUND');
         END IF;

         IF (inv_mwb_globals.g_lpn_from_id IS NOT NULL AND
         inv_mwb_globals.g_lpn_to_id IS NOT NULL AND
         inv_mwb_globals.g_lpn_from_id = inv_mwb_globals.g_lpn_to_id) THEN
            add_where_clause('rsl.asn_lpn_id = :inb_lpn_from_id', 'INBOUND');
            add_bind_variable('inb_lpn_from_id', inv_mwb_globals.g_lpn_from_id);
         END IF;

         IF (inv_mwb_globals.g_lpn_from_id IS NOT NULL AND
         inv_mwb_globals.g_lpn_from_id <> NVL(inv_mwb_globals.g_lpn_to_id, -1) ) THEN
            add_where_clause('wlpn.license_plate_number >= :inb_lpn_from', 'INBOUND');
            add_bind_variable('inb_lpn_from', inv_mwb_globals.g_lpn_from);
         END IF;

         IF (inv_mwb_globals.g_lpn_to_id IS NOT NULL AND
         inv_mwb_globals.g_lpn_to_id <> NVL(inv_mwb_globals.g_lpn_from_id, -1) ) THEN
            add_where_clause('wlpn.license_plate_number <= :inb_lpn_to', 'INBOUND');
            add_bind_variable('inb_lpn_to', inv_mwb_globals.g_lpn_to);
         END IF;



         IF (inv_mwb_globals.g_lot_from IS NOT NULL
         OR  inv_mwb_globals.g_lot_to IS NOT NULL)
         OR (inv_mwb_globals.g_tree_item_id IS NOT NULL
             AND l_lot_control = 2) THEN
            inv_mwb_query_manager.add_from_clause(' rcv_lots_supply rls ','INBOUND');
            add_where_clause('rls.shipment_line_id(+) = ms.shipment_line_id ', 'INBOUND');
         END IF;

         IF (inv_mwb_globals.g_lot_from IS NOT NULL AND
         inv_mwb_globals.g_lot_to IS NOT NULL AND
         inv_mwb_globals.g_lot_from = inv_mwb_globals.g_lot_to) THEN
            add_where_clause('rls.lot_num = :inb_lot_from', 'INBOUND');
            add_bind_variable('inb_lot_from', inv_mwb_globals.g_lot_from);
         END IF;

         IF (inv_mwb_globals.g_lot_from IS NOT NULL AND
         inv_mwb_globals.g_lot_from <> NVL(inv_mwb_globals.g_lot_to, -1) ) THEN
           add_where_clause('rls.lot_num >= :inb_lot_from', 'INBOUND');
           add_bind_variable('inb_lot_from', inv_mwb_globals.g_lot_from);
         END IF;

         IF (inv_mwb_globals.g_lot_to IS NOT NULL AND
         inv_mwb_globals.g_lot_to <> NVL(inv_mwb_globals.g_lot_from, -1) ) THEN
           add_where_clause('rls.lot_num <= :inb_lot_to', 'INBOUND');
           add_bind_variable('inb_lot_to', inv_mwb_globals.g_lot_to);
         END IF;

/* Bug 8396954, Adding below if condition for checking supplier_lot_number condition */
         IF (inv_mwb_globals.g_supplier_lot_from IS NOT NULL OR
               inv_mwb_globals.g_supplier_lot_to IS NOT NULL ) THEN
               inv_mwb_query_manager.add_from_clause('mtl_lot_numbers mln3', 'INBOUND');
                IF NOT ((inv_mwb_globals.g_lot_from IS NOT NULL
                  OR  inv_mwb_globals.g_lot_to IS NOT NULL)
                  OR (inv_mwb_globals.g_tree_item_id IS NOT NULL
                  AND l_lot_control = 2)) THEN
                    inv_mwb_query_manager.add_from_clause(' rcv_lots_supply rls ','INBOUND');
                    add_where_clause('rls.shipment_line_id(+) = ms.shipment_line_id ', 'INBOUND');
                END IF;
               add_where_clause('mln3.lot_number = rls.lot_num', 'INBOUND');

                IF (inv_mwb_globals.g_supplier_lot_from IS NOT NULL AND
                    inv_mwb_globals.g_supplier_lot_to IS NOT NULL AND
                    inv_mwb_globals.g_supplier_lot_from = inv_mwb_globals.g_supplier_lot_to) THEN
                    add_where_clause('mln3.supplier_lot_number = :inb_supplier_lot_from', 'INBOUND');
                    add_bind_variable('inb_supplier_lot_from', inv_mwb_globals.g_supplier_lot_from);
                END IF;

                IF (inv_mwb_globals.g_supplier_lot_from IS NOT NULL AND
                       inv_mwb_globals.g_supplier_lot_from <> NVL(inv_mwb_globals.g_supplier_lot_to, -1) ) THEN
                           add_where_clause('mln3.supplier_lot_number >= :inb_supplier_lot_from', 'INBOUND');
                   add_bind_variable('inb_supplier_lot_from', inv_mwb_globals.g_supplier_lot_from);
                END IF;

                IF (inv_mwb_globals.g_supplier_lot_to IS NOT NULL AND
                   inv_mwb_globals.g_supplier_lot_to <> NVL(inv_mwb_globals.g_supplier_lot_from, -1) ) THEN
                   add_where_clause('mln3.supplier_lot_number <= :inb_supplier_lot_to', 'INBOUND');
                 add_bind_variable('inb_supplier_lot_to', inv_mwb_globals.g_supplier_lot_to);
                END IF;
         END IF ;
/* End of Bug 8396954 */

         IF (inv_mwb_globals.g_serial_from IS NOT NULL
             OR inv_mwb_globals.g_serial_to IS NOT NULL)
             OR (inv_mwb_globals.g_tree_item_id IS NOT NULL
             AND l_serial_control =2) THEN
            inv_mwb_query_manager.add_from_clause(' rcv_serials_supply rss ','INBOUND');
            add_where_clause('rss.shipment_line_id = ms.shipment_line_id ', 'INBOUND');
         END IF;

         IF (inv_mwb_globals.g_serial_from IS NOT NULL AND
            inv_mwb_globals.g_serial_to IS NOT NULL AND
            inv_mwb_globals.g_serial_from = inv_mwb_globals.g_serial_to) THEN
            add_where_clause('rss.serial_num = :inb_serial_from', 'INBOUND');
            add_bind_variable('inb_serial_from', inv_mwb_globals.g_serial_from);
         END IF;

         IF (inv_mwb_globals.g_serial_from IS NOT NULL AND
            inv_mwb_globals.g_serial_from <> NVL(inv_mwb_globals.g_serial_to, -1) ) THEN
            add_where_clause('rss.serial_num >= :inb_serial_from', 'INBOUND');
            add_bind_variable('inb_serial_from', inv_mwb_globals.g_serial_from);
         END IF;

         IF (inv_mwb_globals.g_serial_to IS NOT NULL AND
            inv_mwb_globals.g_serial_to <> NVL(inv_mwb_globals.g_serial_from, -1) ) THEN
            add_where_clause('rss.serial_num <= :inb_serial_to', 'INBOUND');
            add_bind_variable('inb_serial_to', inv_mwb_globals.g_serial_to);
         END IF;

         IF inv_mwb_globals.g_inventory_item_id IS NULL
         AND inv_mwb_globals.g_item_description IS NOT NULL THEN
            add_from_clause(' mtl_system_items_kfv msik ','INBOUND');
            add_where_clause(' ms.item_id = msik.inventory_item_id ', 'INBOUND');
            add_where_clause(' ms.to_organization_id = msik.organization_id ', 'INBOUND');
            add_where_clause(' msik.description like :inb_item_description ', 'INBOUND');
            add_bind_variable('inb_item_description', inv_mwb_globals.g_item_description);
         END IF;

      ELSE -- If interorg and supplier tab null

         inv_mwb_query_manager.add_from_clause('rcv_shipment_headers rsh ','INBOUND');
         inv_mwb_query_manager.add_from_clause('rcv_shipment_lines rsl ','INBOUND');
         inv_mwb_query_manager.add_where_clause('rsh.shipment_header_id(+) = ms.shipment_header_id ', 'INBOUND');
         inv_mwb_query_manager.add_where_clause('rsl.shipment_line_id(+) = ms.shipment_line_id', 'INBOUND');

         IF inv_mwb_globals.g_organization_id IS NOT NULL THEN
            add_where_clause('ms.to_organization_id = :inb_to_organization_id', 'INBOUND');
            add_bind_variable('inb_to_organization_id', inv_mwb_globals.g_organization_id);
         END IF;

         -- ER(9158529 client)
         IF inv_mwb_globals.g_client_code IS NOT NULL THEN
            add_where_clause('ms.item_id in (select DISTINCT inventory_item_id from mtl_system_items_b where wms_deploy.get_client_code(inventory_item_id) = :inb_client_code) ', 'INBOUND');
            add_bind_variable('inb_client_code', inv_mwb_globals.g_client_code);
         END IF;
         -- ER(9158529 client)

         IF inv_mwb_globals.g_inventory_item_id IS NOT NULL THEN
            add_where_clause('ms.item_id = :inb_item_id', 'INBOUND');
            add_bind_variable('inb_item_id', inv_mwb_globals.g_inventory_item_id);
         END IF;

         IF inv_mwb_globals.g_revision IS NOT NULL THEN
           add_where_clause('ms.item_revision = :inb_item_revision', 'INBOUND');
           add_bind_variable('inb_item_revision', inv_mwb_globals.g_revision);
         END IF;

         IF inv_mwb_globals.g_cost_group_id IS NOT NULL THEN
            add_where_clause('ms.cost_group_id = :inb_cost_group_id', 'INBOUND');
            add_bind_variable('inb_cost_group_id', inv_mwb_globals.g_cost_group_id);
         END IF;

         -- ER(9158529)
         IF inv_mwb_globals.g_category_set_id IS NOT NULL THEN
            add_where_clause('ms.item_id in '
                                || ' (select DISTINCT inventory_item_id from mtl_item_categories '
                                || ' where organization_id = :inb_to_organization_id '
                                || ' and category_set_id = :inb_category_set_id '
                                || ' and category_id = nvl(:inb_category_id, category_id))', 'INBOUND');
            add_bind_variable('inb_to_organization_id', inv_mwb_globals.g_organization_id);
            add_bind_variable('inb_category_set_id', inv_mwb_globals.g_category_set_id);
            add_bind_variable('inb_category_id', inv_mwb_globals.g_category_id);
         END IF;
         -- ER(9158529)

         IF inv_mwb_globals.g_lpn_from_id IS NOT NULL
         OR inv_mwb_globals.g_lpn_to_id IS NOT NULL THEN
            inv_mwb_query_manager.add_from_clause(' wms_license_plate_numbers wlpn ','INBOUND');
            add_where_clause('rsl.asn_lpn_id = wlpn.lpn_id', 'INBOUND');
         END IF;

         IF (inv_mwb_globals.g_lpn_from_id IS NOT NULL AND
         inv_mwb_globals.g_lpn_to_id IS NOT NULL AND
         inv_mwb_globals.g_lpn_from_id = inv_mwb_globals.g_lpn_to_id) THEN
            add_where_clause('rsl.asn_lpn_id = :inb_lpn_from_id', 'INBOUND');
            add_bind_variable('inb_lpn_from_id', inv_mwb_globals.g_lpn_from_id);
         END IF;

         IF (inv_mwb_globals.g_lpn_from_id IS NOT NULL AND
         inv_mwb_globals.g_lpn_from_id <> NVL(inv_mwb_globals.g_lpn_to_id, -1) ) THEN
            add_where_clause('wlpn.license_plate_number >= :inb_lpn_from', 'INBOUND');
            add_bind_variable('inb_lpn_from', inv_mwb_globals.g_lpn_from);
         END IF;

         IF (inv_mwb_globals.g_lpn_to_id IS NOT NULL AND
         inv_mwb_globals.g_lpn_to_id <> NVL(inv_mwb_globals.g_lpn_from_id, -1) ) THEN
            add_where_clause('wlpn.license_plate_number <= :inb_lpn_to', 'INBOUND');
            add_bind_variable('inb_lpn_to', inv_mwb_globals.g_lpn_to);
         END IF;

         IF inv_mwb_globals.g_lot_from IS NOT NULL
         OR inv_mwb_globals.g_lot_to IS NOT NULL
         OR (inv_mwb_globals.g_tree_item_id IS NOT NULL
             AND l_lot_control = 2)
         OR  inv_mwb_globals.g_tree_lot_number IS NOT NULL THEN
            add_from_clause(' rcv_lots_supply rls ','INBOUND');
            add_where_clause('rls.shipment_line_id(+) = ms.shipment_line_id ', 'INBOUND');
         END IF;

         IF inv_mwb_globals.g_lot_from IS NOT NULL
         AND inv_mwb_globals.g_lot_to IS NOT NULL
         AND inv_mwb_globals.g_lot_from = inv_mwb_globals.g_lot_to THEN
            add_where_clause('rls.lot_num = :inb_lot_from', 'INBOUND');
            add_bind_variable('inb_lot_from', inv_mwb_globals.g_lot_from);
         END IF;

         IF (inv_mwb_globals.g_lot_from IS NOT NULL AND
         inv_mwb_globals.g_lot_from <> NVL(inv_mwb_globals.g_lot_to, -1) ) THEN
           add_where_clause('rls.lot_num >= :inb_lot_from', 'INBOUND');
           add_bind_variable('inb_lot_from', inv_mwb_globals.g_lot_from);
         END IF;

         IF (inv_mwb_globals.g_lot_to IS NOT NULL AND
         inv_mwb_globals.g_lot_to <> NVL(inv_mwb_globals.g_lot_from, -1) ) THEN
           add_where_clause('rls.lot_num <= :inb_lot_to', 'INBOUND');
           add_bind_variable('inb_lot_to', inv_mwb_globals.g_lot_to);
         END IF;

/* Bug 8396954, Adding below if condition for checking supplier_lot_number condition */
         IF (inv_mwb_globals.g_supplier_lot_from IS NOT NULL OR
               inv_mwb_globals.g_supplier_lot_to IS NOT NULL ) THEN
               inv_mwb_query_manager.add_from_clause('mtl_lot_numbers mln3', 'INBOUND');
                IF NOT (inv_mwb_globals.g_lot_from IS NOT NULL
                     OR inv_mwb_globals.g_lot_to IS NOT NULL
                     OR (inv_mwb_globals.g_tree_item_id IS NOT NULL
                     AND l_lot_control = 2)
                     OR  inv_mwb_globals.g_tree_lot_number IS NOT NULL) THEN
                    inv_mwb_query_manager.add_from_clause(' rcv_lots_supply rls ','INBOUND');
                    add_where_clause('rls.shipment_line_id(+) = ms.shipment_line_id ', 'INBOUND');
                END IF;
               add_where_clause('mln3.lot_number = rls.lot_num', 'INBOUND');

                IF (inv_mwb_globals.g_supplier_lot_from IS NOT NULL AND
                    inv_mwb_globals.g_supplier_lot_to IS NOT NULL AND
                    inv_mwb_globals.g_supplier_lot_from = inv_mwb_globals.g_supplier_lot_to) THEN
                    add_where_clause('mln3.supplier_lot_number = :inb_supplier_lot_from', 'INBOUND');
                    add_bind_variable('inb_supplier_lot_from', inv_mwb_globals.g_supplier_lot_from);
                END IF;

                IF (inv_mwb_globals.g_supplier_lot_from IS NOT NULL AND
                       inv_mwb_globals.g_supplier_lot_from <> NVL(inv_mwb_globals.g_supplier_lot_to, -1) ) THEN
                           add_where_clause('mln3.supplier_lot_number >= :inb_supplier_lot_from', 'INBOUND');
                   add_bind_variable('inb_supplier_lot_from', inv_mwb_globals.g_supplier_lot_from);
                END IF;

                IF (inv_mwb_globals.g_supplier_lot_to IS NOT NULL AND
                   inv_mwb_globals.g_supplier_lot_to <> NVL(inv_mwb_globals.g_supplier_lot_from, -1) ) THEN
                   add_where_clause('mln3.supplier_lot_number <= :inb_supplier_lot_to', 'INBOUND');
                 add_bind_variable('inb_supplier_lot_to', inv_mwb_globals.g_supplier_lot_to);
                END IF;
         END IF ;
/* End of Bug 8396954 */

         IF inv_mwb_globals.g_serial_from IS NOT NULL
         OR inv_mwb_globals.g_serial_to IS NOT NULL
         OR (inv_mwb_globals.g_tree_item_id IS NOT NULL
             AND l_serial_control = 2)
         OR inv_mwb_globals.g_tree_serial_number IS NOT NULL THEN
            inv_mwb_query_manager.add_from_clause('rcv_serials_supply rss','INBOUND');
            add_where_clause('rss.shipment_line_id(+) = ms.shipment_line_id', 'INBOUND');
         END IF;

         -- for bug 8420783
         -- for bug 8414727
         IF (inv_mwb_globals.g_lot_from IS NOT NULL
             OR inv_mwb_globals.g_lot_to IS NOT NULL)
             AND (inv_mwb_globals.g_tree_item_id IS NOT NULL
             -- here only for serial control code 2, because for serial control code 2, the query sql will join the rcv_serials_supply
             -- so need to add lot number condition to where_clause.
             AND l_serial_control =2) THEN
            add_where_clause('rss.lot_num = rls.lot_num ', 'INBOUND');
         END IF;
         -- end of bug 8414727
         -- end of bug 8420783

         IF (inv_mwb_globals.g_serial_from IS NOT NULL AND
            inv_mwb_globals.g_serial_to IS NOT NULL AND
            inv_mwb_globals.g_serial_from = inv_mwb_globals.g_serial_to) THEN
            add_where_clause('rss.serial_num = :inb_serial_from', 'INBOUND');
            add_bind_variable('inb_serial_from', inv_mwb_globals.g_serial_from);
         END IF;

         IF (inv_mwb_globals.g_serial_from IS NOT NULL AND
            inv_mwb_globals.g_serial_from <> NVL(inv_mwb_globals.g_serial_to, -1) ) THEN
            add_where_clause('rss.serial_num >= :inb_serial_from', 'INBOUND');
            add_bind_variable('inb_serial_from', inv_mwb_globals.g_serial_from);
         END IF;

         IF (inv_mwb_globals.g_serial_to IS NOT NULL AND
            inv_mwb_globals.g_serial_to <> NVL(inv_mwb_globals.g_serial_from, -1) ) THEN
            add_where_clause('rss.serial_num <= :inb_serial_to', 'INBOUND');
            add_bind_variable('inb_serial_to', inv_mwb_globals.g_serial_to);
         END IF;

         IF inv_mwb_globals.g_inventory_item_id IS NULL
         AND inv_mwb_globals.g_item_description IS NOT NULL THEN
            add_from_clause(' mtl_system_items_kfv msik ','INBOUND');
            add_where_clause(' ms.item_id = msik.inventory_item_id ', 'INBOUND');
            add_where_clause(' ms.to_organization_id = msik.organization_id ', 'INBOUND');
            add_where_clause(' msik.description like :inb_item_description ', 'INBOUND');
            add_bind_variable('inb_item_description', inv_mwb_globals.g_item_description);
         END IF;
   	END IF;

      add_where_clause(' ms.supply_type_code NOT IN (''RECEIVING'') ', 'INBOUND');

      IF inv_mwb_globals.g_organization_id IS NOT NULL THEN
         add_where_clause('ms.to_organization_id = :inb_to_organization_id', 'INBOUND');
         add_bind_variable('inb_to_organization_id', inv_mwb_globals.g_organization_id);
      END IF;

      IF (inv_mwb_globals.g_expected_from_date IS NOT NULL AND
         inv_mwb_globals.g_expected_to_date IS NOT NULL AND
         inv_mwb_globals.g_expected_from_date = inv_mwb_globals.g_expected_to_date) THEN
         add_where_clause('ms.expected_delivery_date = :inb_expected_from_date', 'INBOUND');
         add_bind_variable('inb_expected_from_date', inv_mwb_globals.g_expected_from_date);
      END IF;

      IF inv_mwb_globals.g_expected_from_date IS NOT NULL THEN
         add_where_clause('ms.expected_delivery_date >= :inb_expected_from_date', 'INBOUND');
         add_bind_variable('inb_expected_from_date', inv_mwb_globals.g_expected_from_date);
      END IF;

      IF inv_mwb_globals.g_expected_to_date IS NOT NULL THEN
         add_where_clause('ms.expected_delivery_date <= :inb_expected_to_date', 'INBOUND');
         add_bind_variable('inb_expected_to_date', inv_mwb_globals.g_expected_to_date);
      END IF;

  END add_qf_where_inbound;


  FUNCTION build_onhand_query RETURN VARCHAR2 IS

     l_onhand_exclusive BOOLEAN;
     l_query_str        inv_mwb_globals.very_long_str;
     l_procedure_name   VARCHAR2(30);

  BEGIN

     l_procedure_name := 'BUILD_ONHAND_QUERY';
     inv_mwb_globals.print_msg(g_pkg_name, l_procedure_name, 'Entered');

     IF ( NVL(inv_mwb_globals.g_chk_onhand, 0) = 1 AND
          NVL(inv_mwb_globals.g_chk_inbound, 0) = 0 AND
          NVL(inv_mwb_globals.g_chk_receiving, 0) = 0 ) THEN

        l_onhand_exclusive := TRUE;

     ELSE

        l_onhand_exclusive := FALSE;

     END IF;

     l_query_str := build_query(
                          g_onhand_select,
                          g_onhand_from,
                          g_onhand_where,
                          g_onhand_group
                          );

     RETURN l_query_str;

  END build_onhand_query;

  FUNCTION build_inbound_query RETURN VARCHAR2 IS

     l_query_str      inv_mwb_globals.very_long_str;
     l_procedure_name VARCHAR2(30);

  BEGIN

     l_procedure_name := 'BUILD_INBOUND_QUERY';
     l_query_str      := ' ';

     RETURN l_query_str;

  END build_inbound_query;

  FUNCTION build_receiving_query RETURN VARCHAR2 IS

     l_query_str      inv_mwb_globals.very_long_str;
     l_procedure_name VARCHAR2(30);

  BEGIN

     l_procedure_name := 'BUILD_RECEIVING_QUERY';
     l_query_str      := ' ';

     RETURN l_query_str;

  END build_receiving_query;

  PROCEDURE build_onhand_qf_where IS
  BEGIN
     g_onhand_where(10) := 'moqd.organization_id = :onh_organization_id';
  END build_onhand_qf_where;


  PROCEDURE initialize_onhand_query IS
     l_procedure_name VARCHAR2(30);
     l_temp_rec       SelectColumnRecType;
  BEGIN

     l_procedure_name := 'INITIALIZE_ONHAND_QUERY';

     g_onhand_select.DELETE;
     g_onhand_where.DELETE;
     g_onhand_from.DELETE;
     g_onhand_group.DELETE;

     g_onhand_where_index := 1;
     g_onhand_from_index := 1;
     g_onhand_group_index := 1;

     l_temp_rec.column_name  := 'PO_RELEASE_ID';
     l_temp_rec.column_value := 'NULL';
     g_onhand_select(PO_RELEASE_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'RELEASE_LINE_NUMBER';
     l_temp_rec.column_value := 'NULL';
     g_onhand_select(RELEASE_LINE_NUMBER) := l_temp_rec;

     l_temp_rec.column_name  := 'SHIPMENT_NUMBER';
     l_temp_rec.column_value := 'NULL';
     g_onhand_select(SHIPMENT_NUMBER) := l_temp_rec;

     l_temp_rec.column_name  := 'SHIPMENT_HEADER_ID_INTERORG';
     l_temp_rec.column_value := 'NULL';
     g_onhand_select(SHIPMENT_HEADER_ID_INTERORG) := l_temp_rec;

     l_temp_rec.column_name  := 'ASN';
     l_temp_rec.column_value := 'NULL';
     g_onhand_select(ASN) := l_temp_rec;

     l_temp_rec.column_name  := 'SHIPMENT_HEADER_ID_ASN';
     l_temp_rec.column_value := 'NULL';
     g_onhand_select(SHIPMENT_HEADER_ID_ASN) := l_temp_rec;

     l_temp_rec.column_name  := 'TRADING_PARTNER';
     l_temp_rec.column_value := 'NULL';
     g_onhand_select(TRADING_PARTNER) := l_temp_rec;

     l_temp_rec.column_name  := 'VENDOR_ID';
     l_temp_rec.column_value := 'NULL';
     g_onhand_select(VENDOR_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'TRADING_PARTNER_SITE';
     l_temp_rec.column_value := 'NULL';
     g_onhand_select(TRADING_PARTNER_SITE) := l_temp_rec;

     l_temp_rec.column_name  := 'VENDOR_SITE_ID';
     l_temp_rec.column_value := 'NULL';
     g_onhand_select(VENDOR_SITE_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'FROM_ORG';
     l_temp_rec.column_value := 'NULL';
     g_onhand_select(FROM_ORG) := l_temp_rec;

     l_temp_rec.column_name  := 'FROM_ORG_ID';
     l_temp_rec.column_value := 'NULL';
     g_onhand_select(FROM_ORG_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'TO_ORG';
     l_temp_rec.column_value := 'NULL';
     g_onhand_select(TO_ORG) := l_temp_rec;

     l_temp_rec.column_name  := 'TO_ORG_ID';
     l_temp_rec.column_value := 'NULL';
     g_onhand_select(TO_ORG_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'EXPECTED_RECEIPT_DATE';
     l_temp_rec.column_value := 'NULL';
     g_onhand_select(EXPECTED_RECEIPT_DATE) := l_temp_rec;

     l_temp_rec.column_name  := 'SHIPPED_DATE';
     l_temp_rec.column_value := 'NULL';
     g_onhand_select(SHIPPED_DATE) := l_temp_rec;

     l_temp_rec.column_name  := 'OWNING_ORG';
     l_temp_rec.column_value := 'NULL';
     g_onhand_select(OWNING_ORG) := l_temp_rec;

     l_temp_rec.column_name  := 'OWNING_ORG_ID';
     l_temp_rec.column_value := 'NULL';
     g_onhand_select(OWNING_ORG_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'REQ_HEADER_ID';
     l_temp_rec.column_value := 'NULL';
     g_onhand_select(REQ_HEADER_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'OE_HEADER_ID';
     l_temp_rec.column_value := 'NULL';
     g_onhand_select(OE_HEADER_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'PO_HEADER_ID';
     l_temp_rec.column_value := 'NULL';
     g_onhand_select(PO_HEADER_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'MATURITY_DATE';
     l_temp_rec.column_value := 'NULL';
     g_onhand_select(MATURITY_DATE) := l_temp_rec;

     l_temp_rec.column_name  := 'HOLD_DATE';
     l_temp_rec.column_value := 'NULL';
     g_onhand_select(HOLD_DATE) := l_temp_rec;

     l_temp_rec.column_name  := 'SUPPLIER_LOT';
     l_temp_rec.column_value := 'NULL';
     g_onhand_select(SUPPLIER_LOT) := l_temp_rec;

     l_temp_rec.column_name  := 'PARENT_LOT';
     l_temp_rec.column_value := 'NULL';
     g_onhand_select(PARENT_LOT) := l_temp_rec;

     l_temp_rec.column_name  := 'DOCUMENT_TYPE';
     l_temp_rec.column_value := 'NULL';
     g_onhand_select(DOCUMENT_TYPE) := l_temp_rec;

     l_temp_rec.column_name  := 'DOCUMENT_TYPE_ID';
     l_temp_rec.column_value := 'NULL';
     g_onhand_select(DOCUMENT_TYPE_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'DOCUMENT_NUMBER';
     l_temp_rec.column_value := 'NULL';
     g_onhand_select(DOCUMENT_NUMBER) := l_temp_rec;

     l_temp_rec.column_name  := 'DOCUMENT_LINE_NUMBER';
     l_temp_rec.column_value := 'NULL';
     g_onhand_select(DOCUMENT_LINE_NUMBER) := l_temp_rec;

     l_temp_rec.column_name  := 'RELEASE_NUMBER';
     l_temp_rec.column_value := 'NULL';
     g_onhand_select(RELEASE_NUMBER) := l_temp_rec;

     l_temp_rec.column_name  := 'ORIGINATION_TYPE';
     l_temp_rec.column_value := 'NULL';
     g_onhand_select(ORIGINATION_TYPE) := l_temp_rec;

     l_temp_rec.column_name  := 'ORIGINATION_DATE';
     l_temp_rec.column_value := 'NULL';
     g_onhand_select(ORIGINATION_DATE) := l_temp_rec;

     l_temp_rec.column_name  := 'ACTION_CODE';
     l_temp_rec.column_value := 'NULL';
     g_onhand_select(ACTION_CODE) := l_temp_rec;

     l_temp_rec.column_name  := 'ACTION_DATE';
     l_temp_rec.column_value := 'NULL';
     g_onhand_select(ACTION_DATE) := l_temp_rec;

     l_temp_rec.column_name  := 'RETEST_DATE';
     l_temp_rec.column_value := 'NULL';
     g_onhand_select(RETEST_DATE) := l_temp_rec;

     l_temp_rec.column_name  := 'SECONDARY_UNPACKED';
     l_temp_rec.column_value := 'NULL';
     g_onhand_select(SECONDARY_UNPACKED) := l_temp_rec;

     l_temp_rec.column_name  := 'SECONDARY_PACKED';
     l_temp_rec.column_value := 'NULL';
     g_onhand_select(SECONDARY_PACKED) := l_temp_rec;

     l_temp_rec.column_name  := 'SUBINVENTORY_CODE';
     l_temp_rec.column_value := 'NULL';
     g_onhand_select(SUBINVENTORY_CODE) := l_temp_rec;

     l_temp_rec.column_name  := 'LOCATOR';
     l_temp_rec.column_value := 'NULL';
     g_onhand_select(LOCATOR) := l_temp_rec;

     l_temp_rec.column_name  := 'LOCATOR_ID';
     l_temp_rec.column_value := 'NULL';
     g_onhand_select(LOCATOR_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'LPN';
     l_temp_rec.column_value := 'NULL';
     g_onhand_select(LPN) := l_temp_rec;

     l_temp_rec.column_name  := 'LPN_ID';
     l_temp_rec.column_value := 'NULL';
     g_onhand_select(LPN_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'COST_GROUP';
     l_temp_rec.column_value := 'NULL';
     g_onhand_select(COST_GROUP) := l_temp_rec;

     l_temp_rec.column_name  := 'GRADE_CODE';
     l_temp_rec.column_value := 'NULL';
     g_onhand_select(GRADE_CODE) := l_temp_rec;

     l_temp_rec.column_name  := 'CG_ID';
     l_temp_rec.column_value := 'NULL';
     g_onhand_select(CG_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'LOADED';
     l_temp_rec.column_value := 'NULL';
     g_onhand_select(LOADED) := l_temp_rec;

     l_temp_rec.column_name  := 'PLANNING_PARTY';
     l_temp_rec.column_value := 'NULL';
     g_onhand_select(PLANNING_PARTY) := l_temp_rec;

     l_temp_rec.column_name  := 'PLANNING_PARTY_ID';
     l_temp_rec.column_value := 'NULL';
     g_onhand_select(PLANNING_PARTY_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'OWNING_PARTY';
     l_temp_rec.column_value := 'NULL';
     g_onhand_select(OWNING_PARTY) := l_temp_rec;

     l_temp_rec.column_name  := 'OWNING_PARTY_ID';
     l_temp_rec.column_value := 'NULL';
     g_onhand_select(OWNING_PARTY_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'LOT';
     l_temp_rec.column_value := 'NULL';
     g_onhand_select(LOT) := l_temp_rec;


     l_temp_rec.column_name  := 'SERIAL';
     l_temp_rec.column_value := 'NULL';
     g_onhand_select(SERIAL) := l_temp_rec;

     l_temp_rec.column_name  := 'UNIT_NUMBER';
     l_temp_rec.column_value := 'NULL';
     g_onhand_select(UNIT_NUMBER) := l_temp_rec;

     l_temp_rec.column_name  := 'LOT_EXPIRY_DATE';
     l_temp_rec.column_value := 'NULL';
     g_onhand_select(LOT_EXPIRY_DATE) := l_temp_rec;

     l_temp_rec.column_name  := 'ORGANIZATION_CODE';
     l_temp_rec.column_value := 'NULL';
     g_onhand_select(ORGANIZATION_CODE) := l_temp_rec;

     l_temp_rec.column_name  := 'ORG_ID';
     l_temp_rec.column_value := 'NULL';
     g_onhand_select(ORG_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'ITEM';
     l_temp_rec.column_value := 'NULL';
     g_onhand_select(ITEM) := l_temp_rec;

     l_temp_rec.column_name  := 'ITEM_DESCRIPTION';
     l_temp_rec.column_value := 'NULL';
     g_onhand_select(ITEM_DESCRIPTION) := l_temp_rec;

     l_temp_rec.column_name  := 'ITEM_ID';
     l_temp_rec.column_value := 'NULL';
     g_onhand_select(ITEM_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'REVISION';
     l_temp_rec.column_value := 'NULL';
     g_onhand_select(REVISION) := l_temp_rec;

     l_temp_rec.column_name  := 'PRIMARY_UOM_CODE';
     l_temp_rec.column_value := 'NULL';
     g_onhand_select(PRIMARY_UOM_CODE) := l_temp_rec;

     l_temp_rec.column_name  := 'ONHAND';
     l_temp_rec.column_value := 'NULL';
     g_onhand_select(ONHAND) := l_temp_rec;

     l_temp_rec.column_name  := 'RECEIVING';
     l_temp_rec.column_value := 'NULL';
     g_onhand_select(RECEIVING) := l_temp_rec;

     l_temp_rec.column_name  := 'INBOUND';
     l_temp_rec.column_value := 'NULL';
     g_onhand_select(INBOUND) := l_temp_rec;

     l_temp_rec.column_name  := 'UNPACKED';
     l_temp_rec.column_value := 'NULL';
     g_onhand_select(UNPACKED) := l_temp_rec;

     l_temp_rec.column_name  := 'PACKED';
     l_temp_rec.column_value := 'NULL';
     g_onhand_select(PACKED) := l_temp_rec;

     l_temp_rec.column_name  := 'SECONDARY_UOM_CODE';
     l_temp_rec.column_value := 'NULL';
     g_onhand_select(SECONDARY_UOM_CODE) := l_temp_rec;

     l_temp_rec.column_name  := 'SECONDARY_ONHAND';
     l_temp_rec.column_value := 'NULL';
     g_onhand_select(SECONDARY_ONHAND) := l_temp_rec;

     l_temp_rec.column_name  := 'SECONDARY_RECEIVING';
     l_temp_rec.column_value := 'NULL';
     g_onhand_select(SECONDARY_RECEIVING) := l_temp_rec;

     l_temp_rec.column_name  := 'SECONDARY_INBOUND';
     l_temp_rec.column_value := 'NULL';
     g_onhand_select(SECONDARY_INBOUND) := l_temp_rec;

     l_temp_rec.column_name  := 'OWNING_ORGANIZATION_ID';
     l_temp_rec.column_value := 'NULL';
     g_onhand_select(OWNING_ORGANIZATION_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'PLANNING_ORGANIZATION_ID';
     l_temp_rec.column_value := 'NULL';
     g_onhand_select(PLANNING_ORGANIZATION_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'OWNING_TP_TYPE';
     l_temp_rec.column_value := 'NULL';
     g_onhand_select(OWNING_TP_TYPE) := l_temp_rec;

     l_temp_rec.column_name  := 'PLANNING_TP_TYPE';
     l_temp_rec.column_value := 'NULL';
     g_onhand_select(PLANNING_TP_TYPE) := l_temp_rec;

     -- Onhand Material Status support
     l_temp_rec.column_name  := 'STATUS';
     l_temp_rec.column_value := 'NULL';
     g_onhand_select(STATUS) := l_temp_rec;

     l_temp_rec.column_name  := 'STATUS_ID';
     l_temp_rec.column_value := 'NULL';
     g_onhand_select(STATUS_ID) := l_temp_rec;


  END initialize_onhand_query;

  PROCEDURE initialize_onhand_1_query IS
     l_procedure_name VARCHAR2(30);
     l_temp_rec       SelectColumnRecType;
  BEGIN

     l_procedure_name := 'INITIALIZE_onhand_1_QUERY';

     g_onhand_1_select.DELETE;
     g_onhand_1_where.DELETE;
     g_onhand_1_from.DELETE;
     g_onhand_1_group.DELETE;

     g_onhand_1_where_index := 1;
     g_onhand_1_from_index := 1;
     g_onhand_1_group_index := 1;

     l_temp_rec.column_name  := 'PO_RELEASE_ID';
     l_temp_rec.column_value := 'NULL';
     g_onhand_1_select(PO_RELEASE_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'RELEASE_LINE_NUMBER';
     l_temp_rec.column_value := 'NULL';
     g_onhand_1_select(RELEASE_LINE_NUMBER) := l_temp_rec;

     l_temp_rec.column_name  := 'SHIPMENT_NUMBER';
     l_temp_rec.column_value := 'NULL';
     g_onhand_1_select(SHIPMENT_NUMBER) := l_temp_rec;

     l_temp_rec.column_name  := 'SHIPMENT_HEADER_ID_INTERORG';
     l_temp_rec.column_value := 'NULL';
     g_onhand_1_select(SHIPMENT_HEADER_ID_INTERORG) := l_temp_rec;

     l_temp_rec.column_name  := 'ASN';
     l_temp_rec.column_value := 'NULL';
     g_onhand_1_select(ASN) := l_temp_rec;

     l_temp_rec.column_name  := 'SHIPMENT_HEADER_ID_ASN';
     l_temp_rec.column_value := 'NULL';
     g_onhand_1_select(SHIPMENT_HEADER_ID_ASN) := l_temp_rec;

     l_temp_rec.column_name  := 'TRADING_PARTNER';
     l_temp_rec.column_value := 'NULL';
     g_onhand_1_select(TRADING_PARTNER) := l_temp_rec;

     l_temp_rec.column_name  := 'VENDOR_ID';
     l_temp_rec.column_value := 'NULL';
     g_onhand_1_select(VENDOR_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'TRADING_PARTNER_SITE';
     l_temp_rec.column_value := 'NULL';
     g_onhand_1_select(TRADING_PARTNER_SITE) := l_temp_rec;

     l_temp_rec.column_name  := 'VENDOR_SITE_ID';
     l_temp_rec.column_value := 'NULL';
     g_onhand_1_select(VENDOR_SITE_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'FROM_ORG';
     l_temp_rec.column_value := 'NULL';
     g_onhand_1_select(FROM_ORG) := l_temp_rec;

     l_temp_rec.column_name  := 'FROM_ORG_ID';
     l_temp_rec.column_value := 'NULL';
     g_onhand_1_select(FROM_ORG_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'TO_ORG';
     l_temp_rec.column_value := 'NULL';
     g_onhand_1_select(TO_ORG) := l_temp_rec;

     l_temp_rec.column_name  := 'TO_ORG_ID';
     l_temp_rec.column_value := 'NULL';
     g_onhand_1_select(TO_ORG_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'EXPECTED_RECEIPT_DATE';
     l_temp_rec.column_value := 'NULL';
     g_onhand_1_select(EXPECTED_RECEIPT_DATE) := l_temp_rec;

     l_temp_rec.column_name  := 'SHIPPED_DATE';
     l_temp_rec.column_value := 'NULL';
     g_onhand_1_select(SHIPPED_DATE) := l_temp_rec;

     l_temp_rec.column_name  := 'OWNING_ORG';
     l_temp_rec.column_value := 'NULL';
     g_onhand_1_select(OWNING_ORG) := l_temp_rec;

     l_temp_rec.column_name  := 'OWNING_ORG_ID';
     l_temp_rec.column_value := 'NULL';
     g_onhand_1_select(OWNING_ORG_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'REQ_HEADER_ID';
     l_temp_rec.column_value := 'NULL';
     g_onhand_1_select(REQ_HEADER_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'OE_HEADER_ID';
     l_temp_rec.column_value := 'NULL';
     g_onhand_1_select(OE_HEADER_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'PO_HEADER_ID';
     l_temp_rec.column_value := 'NULL';
     g_onhand_1_select(PO_HEADER_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'MATURITY_DATE';
     l_temp_rec.column_value := 'NULL';
     g_onhand_1_select(MATURITY_DATE) := l_temp_rec;

     l_temp_rec.column_name  := 'HOLD_DATE';
     l_temp_rec.column_value := 'NULL';
     g_onhand_1_select(HOLD_DATE) := l_temp_rec;

     l_temp_rec.column_name  := 'SUPPLIER_LOT';
     l_temp_rec.column_value := 'NULL';
     g_onhand_1_select(SUPPLIER_LOT) := l_temp_rec;

     l_temp_rec.column_name  := 'PARENT_LOT';
     l_temp_rec.column_value := 'NULL';
     g_onhand_1_select(PARENT_LOT) := l_temp_rec;

     l_temp_rec.column_name  := 'DOCUMENT_TYPE';
     l_temp_rec.column_value := 'NULL';
     g_onhand_1_select(DOCUMENT_TYPE) := l_temp_rec;

     l_temp_rec.column_name  := 'DOCUMENT_TYPE_ID';
     l_temp_rec.column_value := 'NULL';
     g_onhand_1_select(DOCUMENT_TYPE_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'DOCUMENT_NUMBER';
     l_temp_rec.column_value := 'NULL';
     g_onhand_1_select(DOCUMENT_NUMBER) := l_temp_rec;

     l_temp_rec.column_name  := 'DOCUMENT_LINE_NUMBER';
     l_temp_rec.column_value := 'NULL';
     g_onhand_1_select(DOCUMENT_LINE_NUMBER) := l_temp_rec;

     l_temp_rec.column_name  := 'RELEASE_NUMBER';
     l_temp_rec.column_value := 'NULL';
     g_onhand_1_select(RELEASE_NUMBER) := l_temp_rec;

     l_temp_rec.column_name  := 'ORIGINATION_TYPE';
     l_temp_rec.column_value := 'NULL';
     g_onhand_1_select(ORIGINATION_TYPE) := l_temp_rec;

     l_temp_rec.column_name  := 'ORIGINATION_DATE';
     l_temp_rec.column_value := 'NULL';
     g_onhand_1_select(ORIGINATION_DATE) := l_temp_rec;

     l_temp_rec.column_name  := 'ACTION_CODE';
     l_temp_rec.column_value := 'NULL';
     g_onhand_1_select(ACTION_CODE) := l_temp_rec;

     l_temp_rec.column_name  := 'ACTION_DATE';
     l_temp_rec.column_value := 'NULL';
     g_onhand_1_select(ACTION_DATE) := l_temp_rec;

     l_temp_rec.column_name  := 'RETEST_DATE';
     l_temp_rec.column_value := 'NULL';
     g_onhand_1_select(RETEST_DATE) := l_temp_rec;

     l_temp_rec.column_name  := 'SECONDARY_UNPACKED';
     l_temp_rec.column_value := 'NULL';
     g_onhand_1_select(SECONDARY_UNPACKED) := l_temp_rec;

     l_temp_rec.column_name  := 'SECONDARY_PACKED';
     l_temp_rec.column_value := 'NULL';
     g_onhand_1_select(SECONDARY_PACKED) := l_temp_rec;

     l_temp_rec.column_name  := 'SUBINVENTORY_CODE';
     l_temp_rec.column_value := 'NULL';
     g_onhand_1_select(SUBINVENTORY_CODE) := l_temp_rec;

     l_temp_rec.column_name  := 'LOCATOR';
     l_temp_rec.column_value := 'NULL';
     g_onhand_1_select(LOCATOR) := l_temp_rec;

     l_temp_rec.column_name  := 'LOCATOR_ID';
     l_temp_rec.column_value := 'NULL';
     g_onhand_1_select(LOCATOR_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'LPN';
     l_temp_rec.column_value := 'NULL';
     g_onhand_1_select(LPN) := l_temp_rec;

     l_temp_rec.column_name  := 'LPN_ID';
     l_temp_rec.column_value := 'NULL';
     g_onhand_1_select(LPN_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'COST_GROUP';
     l_temp_rec.column_value := 'NULL';
     g_onhand_1_select(COST_GROUP) := l_temp_rec;

     l_temp_rec.column_name  := 'GRADE_CODE';
     l_temp_rec.column_value := 'NULL';
     g_onhand_1_select(GRADE_CODE) := l_temp_rec;

     l_temp_rec.column_name  := 'CG_ID';
     l_temp_rec.column_value := 'NULL';
     g_onhand_1_select(CG_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'LOADED';
     l_temp_rec.column_value := 'NULL';
     g_onhand_1_select(LOADED) := l_temp_rec;

     l_temp_rec.column_name  := 'PLANNING_PARTY';
     l_temp_rec.column_value := 'NULL';
     g_onhand_1_select(PLANNING_PARTY) := l_temp_rec;

     l_temp_rec.column_name  := 'PLANNING_PARTY_ID';
     l_temp_rec.column_value := 'NULL';
     g_onhand_1_select(PLANNING_PARTY_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'OWNING_PARTY';
     l_temp_rec.column_value := 'NULL';
     g_onhand_1_select(OWNING_PARTY) := l_temp_rec;

     l_temp_rec.column_name  := 'OWNING_PARTY_ID';
     l_temp_rec.column_value := 'NULL';
     g_onhand_1_select(OWNING_PARTY_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'LOT';
     l_temp_rec.column_value := 'NULL';
     g_onhand_1_select(LOT) := l_temp_rec;


     l_temp_rec.column_name  := 'SERIAL';
     l_temp_rec.column_value := 'NULL';
     g_onhand_1_select(SERIAL) := l_temp_rec;

     l_temp_rec.column_name  := 'UNIT_NUMBER';
     l_temp_rec.column_value := 'NULL';
     g_onhand_1_select(UNIT_NUMBER) := l_temp_rec;

     l_temp_rec.column_name  := 'LOT_EXPIRY_DATE';
     l_temp_rec.column_value := 'NULL';
     g_onhand_1_select(LOT_EXPIRY_DATE) := l_temp_rec;

     l_temp_rec.column_name  := 'ORGANIZATION_CODE';
     l_temp_rec.column_value := 'NULL';
     g_onhand_1_select(ORGANIZATION_CODE) := l_temp_rec;

     l_temp_rec.column_name  := 'ORG_ID';
     l_temp_rec.column_value := 'NULL';
     g_onhand_1_select(ORG_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'ITEM';
     l_temp_rec.column_value := 'NULL';
     g_onhand_1_select(ITEM) := l_temp_rec;

     l_temp_rec.column_name  := 'ITEM_DESCRIPTION';
     l_temp_rec.column_value := 'NULL';
     g_onhand_1_select(ITEM_DESCRIPTION) := l_temp_rec;

     l_temp_rec.column_name  := 'ITEM_ID';
     l_temp_rec.column_value := 'NULL';
     g_onhand_1_select(ITEM_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'REVISION';
     l_temp_rec.column_value := 'NULL';
     g_onhand_1_select(REVISION) := l_temp_rec;

     l_temp_rec.column_name  := 'PRIMARY_UOM_CODE';
     l_temp_rec.column_value := 'NULL';
     g_onhand_1_select(PRIMARY_UOM_CODE) := l_temp_rec;

     l_temp_rec.column_name  := 'ONHAND';
     l_temp_rec.column_value := 'NULL';
     g_onhand_1_select(ONHAND) := l_temp_rec;

     l_temp_rec.column_name  := 'RECEIVING';
     l_temp_rec.column_value := 'NULL';
     g_onhand_1_select(RECEIVING) := l_temp_rec;

     l_temp_rec.column_name  := 'INBOUND';
     l_temp_rec.column_value := 'NULL';
     g_onhand_1_select(INBOUND) := l_temp_rec;

     l_temp_rec.column_name  := 'UNPACKED';
     l_temp_rec.column_value := 'NULL';
     g_onhand_1_select(UNPACKED) := l_temp_rec;

     l_temp_rec.column_name  := 'PACKED';
     l_temp_rec.column_value := 'NULL';
     g_onhand_1_select(PACKED) := l_temp_rec;

     l_temp_rec.column_name  := 'SECONDARY_UOM_CODE';
     l_temp_rec.column_value := 'NULL';
     g_onhand_1_select(SECONDARY_UOM_CODE) := l_temp_rec;

     l_temp_rec.column_name  := 'SECONDARY_ONHAND';
     l_temp_rec.column_value := 'NULL';
     g_onhand_1_select(SECONDARY_ONHAND) := l_temp_rec;

     l_temp_rec.column_name  := 'SECONDARY_RECEIVING';
     l_temp_rec.column_value := 'NULL';
     g_onhand_1_select(SECONDARY_RECEIVING) := l_temp_rec;

     l_temp_rec.column_name  := 'SECONDARY_INBOUND';
     l_temp_rec.column_value := 'NULL';
     g_onhand_1_select(SECONDARY_INBOUND) := l_temp_rec;

     l_temp_rec.column_name  := 'OWNING_ORGANIZATION_ID';
     l_temp_rec.column_value := 'NULL';
     g_onhand_1_select(OWNING_ORGANIZATION_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'PLANNING_ORGANIZATION_ID';
     l_temp_rec.column_value := 'NULL';
     g_onhand_1_select(PLANNING_ORGANIZATION_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'OWNING_TP_TYPE';
     l_temp_rec.column_value := 'NULL';
     g_onhand_1_select(OWNING_TP_TYPE) := l_temp_rec;

     l_temp_rec.column_name  := 'PLANNING_TP_TYPE';
     l_temp_rec.column_value := 'NULL';
     g_onhand_1_select(PLANNING_TP_TYPE) := l_temp_rec;

     -- Onhand Material Status support
     l_temp_rec.column_name  := 'STATUS';
     l_temp_rec.column_value := 'NULL';
     g_onhand_1_select(STATUS) := l_temp_rec;

     l_temp_rec.column_name  := 'STATUS_ID';
     l_temp_rec.column_value := 'NULL';
     g_onhand_1_select(STATUS_ID) := l_temp_rec;


  END initialize_onhand_1_query;


  PROCEDURE initialize_inbound_query IS
     l_procedure_name VARCHAR2(30);
     l_temp_rec       SelectColumnRecType;
  BEGIN

     l_procedure_name := 'INBOUND_INBOUND_QUERY';

     g_inbound_select.DELETE;
     g_inbound_from.DELETE;
     g_inbound_where.DELETE;
     g_inbound_group.DELETE;

     g_inbound_where_index := 1;
     g_inbound_from_index := 1;
     g_inbound_group_index := 1;

     l_temp_rec.column_name  := 'PO_RELEASE_ID';
     l_temp_rec.column_value := 'NULL';
     g_inbound_select(PO_RELEASE_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'RELEASE_LINE_NUMBER';
     l_temp_rec.column_value := 'NULL';
     g_inbound_select(RELEASE_LINE_NUMBER) := l_temp_rec;

     l_temp_rec.column_name  := 'SHIPMENT_NUMBER';
     l_temp_rec.column_value := 'NULL';
     g_inbound_select(SHIPMENT_NUMBER) := l_temp_rec;

     l_temp_rec.column_name  := 'SHIPMENT_HEADER_ID_INTERORG';
     l_temp_rec.column_value := 'NULL';
     g_inbound_select(SHIPMENT_HEADER_ID_INTERORG) := l_temp_rec;

     l_temp_rec.column_name  := 'ASN';
     l_temp_rec.column_value := 'NULL';
     g_inbound_select(ASN) := l_temp_rec;

     l_temp_rec.column_name  := 'SHIPMENT_HEADER_ID_ASN';
     l_temp_rec.column_value := 'NULL';
     g_inbound_select(SHIPMENT_HEADER_ID_ASN) := l_temp_rec;

     l_temp_rec.column_name  := 'TRADING_PARTNER';
     l_temp_rec.column_value := 'NULL';
     g_inbound_select(TRADING_PARTNER) := l_temp_rec;

     l_temp_rec.column_name  := 'VENDOR_ID';
     l_temp_rec.column_value := 'NULL';
     g_inbound_select(VENDOR_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'TRADING_PARTNER_SITE';
     l_temp_rec.column_value := 'NULL';
     g_inbound_select(TRADING_PARTNER_SITE) := l_temp_rec;

     l_temp_rec.column_name  := 'VENDOR_SITE_ID';
     l_temp_rec.column_value := 'NULL';
     g_inbound_select(VENDOR_SITE_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'FROM_ORG';
     l_temp_rec.column_value := 'NULL';
     g_inbound_select(FROM_ORG) := l_temp_rec;

     l_temp_rec.column_name  := 'FROM_ORG_ID';
     l_temp_rec.column_value := 'NULL';
     g_inbound_select(FROM_ORG_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'TO_ORG';
     l_temp_rec.column_value := 'NULL';
     g_inbound_select(TO_ORG) := l_temp_rec;

     l_temp_rec.column_name  := 'TO_ORG_ID';
     l_temp_rec.column_value := 'NULL';
     g_inbound_select(TO_ORG_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'EXPECTED_RECEIPT_DATE';
     l_temp_rec.column_value := 'NULL';
     g_inbound_select(EXPECTED_RECEIPT_DATE) := l_temp_rec;

     l_temp_rec.column_name  := 'SHIPPED_DATE';
     l_temp_rec.column_value := 'NULL';
     g_inbound_select(SHIPPED_DATE) := l_temp_rec;

     l_temp_rec.column_name  := 'OWNING_ORG';
     l_temp_rec.column_value := 'NULL';
     g_inbound_select(OWNING_ORG) := l_temp_rec;

     l_temp_rec.column_name  := 'OWNING_ORG_ID';
     l_temp_rec.column_value := 'NULL';
     g_inbound_select(OWNING_ORG_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'REQ_HEADER_ID';
     l_temp_rec.column_value := 'NULL';
     g_inbound_select(REQ_HEADER_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'OE_HEADER_ID';
     l_temp_rec.column_value := 'NULL';
     g_inbound_select(OE_HEADER_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'PO_HEADER_ID';
     l_temp_rec.column_value := 'NULL';
     g_inbound_select(PO_HEADER_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'MATURITY_DATE';
     l_temp_rec.column_value := 'NULL';
     g_inbound_select(MATURITY_DATE) := l_temp_rec;

     l_temp_rec.column_name  := 'HOLD_DATE';
     l_temp_rec.column_value := 'NULL';
     g_inbound_select(HOLD_DATE) := l_temp_rec;

     l_temp_rec.column_name  := 'SUPPLIER_LOT';
     l_temp_rec.column_value := 'NULL';
     g_inbound_select(SUPPLIER_LOT) := l_temp_rec;

     l_temp_rec.column_name  := 'PARENT_LOT';
     l_temp_rec.column_value := 'NULL';
     g_inbound_select(PARENT_LOT) := l_temp_rec;

     l_temp_rec.column_name  := 'DOCUMENT_TYPE';
     l_temp_rec.column_value := 'NULL';
     g_inbound_select(DOCUMENT_TYPE) := l_temp_rec;

     l_temp_rec.column_name  := 'DOCUMENT_TYPE_ID';
     l_temp_rec.column_value := 'NULL';
     g_inbound_select(DOCUMENT_TYPE_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'DOCUMENT_NUMBER';
     l_temp_rec.column_value := 'NULL';
     g_inbound_select(DOCUMENT_NUMBER) := l_temp_rec;

     l_temp_rec.column_name  := 'DOCUMENT_LINE_NUMBER';
     l_temp_rec.column_value := 'NULL';
     g_inbound_select(DOCUMENT_LINE_NUMBER) := l_temp_rec;

     l_temp_rec.column_name  := 'RELEASE_NUMBER';
     l_temp_rec.column_value := 'NULL';
     g_inbound_select(RELEASE_NUMBER) := l_temp_rec;

     l_temp_rec.column_name  := 'ORIGINATION_TYPE';
     l_temp_rec.column_value := 'NULL';
     g_inbound_select(ORIGINATION_TYPE) := l_temp_rec;

     l_temp_rec.column_name  := 'ORIGINATION_DATE';
     l_temp_rec.column_value := 'NULL';
     g_inbound_select(ORIGINATION_DATE) := l_temp_rec;

     l_temp_rec.column_name  := 'ACTION_CODE';
     l_temp_rec.column_value := 'NULL';
     g_inbound_select(ACTION_CODE) := l_temp_rec;

     l_temp_rec.column_name  := 'ACTION_DATE';
     l_temp_rec.column_value := 'NULL';
     g_inbound_select(ACTION_DATE) := l_temp_rec;

     l_temp_rec.column_name  := 'RETEST_DATE';
     l_temp_rec.column_value := 'NULL';
     g_inbound_select(RETEST_DATE) := l_temp_rec;

     l_temp_rec.column_name  := 'SECONDARY_UNPACKED';
     l_temp_rec.column_value := 'NULL';
     g_inbound_select(SECONDARY_UNPACKED) := l_temp_rec;

     l_temp_rec.column_name  := 'SECONDARY_PACKED';
     l_temp_rec.column_value := 'NULL';
     g_inbound_select(SECONDARY_PACKED) := l_temp_rec;

     l_temp_rec.column_name  := 'SUBINVENTORY_CODE';
     l_temp_rec.column_value := 'NULL';
     g_inbound_select(SUBINVENTORY_CODE) := l_temp_rec;

     l_temp_rec.column_name  := 'LOCATOR';
     l_temp_rec.column_value := 'NULL';
     g_inbound_select(LOCATOR) := l_temp_rec;

     l_temp_rec.column_name  := 'LOCATOR_ID';
     l_temp_rec.column_value := 'NULL';
     g_inbound_select(LOCATOR_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'LPN';
     l_temp_rec.column_value := 'NULL';
     g_inbound_select(LPN) := l_temp_rec;

     l_temp_rec.column_name  := 'LPN_ID';
     l_temp_rec.column_value := 'NULL';
     g_inbound_select(LPN_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'COST_GROUP';
     l_temp_rec.column_value := 'NULL';
     g_inbound_select(COST_GROUP) := l_temp_rec;

     l_temp_rec.column_name  := 'GRADE_CODE';
     l_temp_rec.column_value := 'NULL';
     g_inbound_select(GRADE_CODE) := l_temp_rec;

     l_temp_rec.column_name  := 'CG_ID';
     l_temp_rec.column_value := 'NULL';
     g_inbound_select(CG_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'LOADED';
     l_temp_rec.column_value := 'NULL';
     g_inbound_select(LOADED) := l_temp_rec;

     l_temp_rec.column_name  := 'PLANNING_PARTY';
     l_temp_rec.column_value := 'NULL';
     g_inbound_select(PLANNING_PARTY) := l_temp_rec;

     l_temp_rec.column_name  := 'PLANNING_PARTY_ID';
     l_temp_rec.column_value := 'NULL';
     g_inbound_select(PLANNING_PARTY_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'OWNING_PARTY';
     l_temp_rec.column_value := 'NULL';
     g_inbound_select(OWNING_PARTY) := l_temp_rec;

     l_temp_rec.column_name  := 'OWNING_PARTY_ID';
     l_temp_rec.column_value := 'NULL';
     g_inbound_select(OWNING_PARTY_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'LOT';
     l_temp_rec.column_value := 'NULL';
     g_inbound_select(LOT) := l_temp_rec;


     l_temp_rec.column_name  := 'SERIAL';
     l_temp_rec.column_value := 'NULL';
     g_inbound_select(SERIAL) := l_temp_rec;

     l_temp_rec.column_name  := 'UNIT_NUMBER';
     l_temp_rec.column_value := 'NULL';
     g_inbound_select(UNIT_NUMBER) := l_temp_rec;

     l_temp_rec.column_name  := 'LOT_EXPIRY_DATE';
     l_temp_rec.column_value := 'NULL';
     g_inbound_select(LOT_EXPIRY_DATE) := l_temp_rec;

     l_temp_rec.column_name  := 'ORGANIZATION_CODE';
     l_temp_rec.column_value := 'NULL';
     g_inbound_select(ORGANIZATION_CODE) := l_temp_rec;

     l_temp_rec.column_name  := 'ORG_ID';
     l_temp_rec.column_value := 'NULL';
     g_inbound_select(ORG_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'ITEM';
     l_temp_rec.column_value := 'NULL';
     g_inbound_select(ITEM) := l_temp_rec;

     l_temp_rec.column_name  := 'ITEM_DESCRIPTION';
     l_temp_rec.column_value := 'NULL';
     g_inbound_select(ITEM_DESCRIPTION) := l_temp_rec;

     l_temp_rec.column_name  := 'ITEM_ID';
     l_temp_rec.column_value := 'NULL';
     g_inbound_select(ITEM_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'REVISION';
     l_temp_rec.column_value := 'NULL';
     g_inbound_select(REVISION) := l_temp_rec;

     l_temp_rec.column_name  := 'PRIMARY_UOM_CODE';
     l_temp_rec.column_value := 'NULL';
     g_inbound_select(PRIMARY_UOM_CODE) := l_temp_rec;

     l_temp_rec.column_name  := 'ONHAND';
     l_temp_rec.column_value := 'NULL';
     g_inbound_select(ONHAND) := l_temp_rec;

     l_temp_rec.column_name  := 'RECEIVING';
     l_temp_rec.column_value := 'NULL';
     g_inbound_select(RECEIVING) := l_temp_rec;

     l_temp_rec.column_name  := 'INBOUND';
     l_temp_rec.column_value := 'NULL';
     g_inbound_select(INBOUND) := l_temp_rec;

     l_temp_rec.column_name  := 'UNPACKED';
     l_temp_rec.column_value := 'NULL';
     g_inbound_select(UNPACKED) := l_temp_rec;

     l_temp_rec.column_name  := 'PACKED';
     l_temp_rec.column_value := 'NULL';
     g_inbound_select(PACKED) := l_temp_rec;

     l_temp_rec.column_name  := 'SECONDARY_UOM_CODE';
     l_temp_rec.column_value := 'NULL';
     g_inbound_select(SECONDARY_UOM_CODE) := l_temp_rec;

     l_temp_rec.column_name  := 'SECONDARY_ONHAND';
     l_temp_rec.column_value := 'NULL';
     g_inbound_select(SECONDARY_ONHAND) := l_temp_rec;

     l_temp_rec.column_name  := 'SECONDARY_RECEIVING';
     l_temp_rec.column_value := 'NULL';
     g_inbound_select(SECONDARY_RECEIVING) := l_temp_rec;

     l_temp_rec.column_name  := 'SECONDARY_INBOUND';
     l_temp_rec.column_value := 'NULL';
     g_inbound_select(SECONDARY_INBOUND) := l_temp_rec;

     l_temp_rec.column_name  := 'OWNING_ORGANIZATION_ID';
     l_temp_rec.column_value := 'NULL';
     g_inbound_select(OWNING_ORGANIZATION_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'PLANNING_ORGANIZATION_ID';
     l_temp_rec.column_value := 'NULL';
     g_inbound_select(PLANNING_ORGANIZATION_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'OWNING_TP_TYPE';
     l_temp_rec.column_value := 'NULL';
     g_inbound_select(OWNING_TP_TYPE) := l_temp_rec;

     l_temp_rec.column_name  := 'PLANNING_TP_TYPE';
     l_temp_rec.column_value := 'NULL';
     g_inbound_select(PLANNING_TP_TYPE) := l_temp_rec;

     -- Bug 6843313 Onhand Material Status support
     l_temp_rec.column_name  := 'STATUS';
     l_temp_rec.column_value := 'NULL';
     g_inbound_select(STATUS) := l_temp_rec;

     l_temp_rec.column_name  := 'STATUS_ID';
     l_temp_rec.column_value := 'NULL';
     g_inbound_select(STATUS_ID) := l_temp_rec;

  END initialize_inbound_query;

  PROCEDURE initialize_inbound_1_query IS
     l_procedure_name VARCHAR2(30);
     l_temp_rec       SelectColumnRecType;
  BEGIN

     l_procedure_name := 'INBOUND_inbound_1_QUERY';

     g_inbound_1_select.DELETE;
     g_inbound_1_from.DELETE;
     g_inbound_1_where.DELETE;
     g_inbound_1_group.DELETE;

     g_inbound_1_where_index := 1;
     g_inbound_1_from_index := 1;
     g_inbound_1_group_index := 1;

     l_temp_rec.column_name  := 'PO_RELEASE_ID';
     l_temp_rec.column_value := 'NULL';
     g_inbound_1_select(PO_RELEASE_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'RELEASE_LINE_NUMBER';
     l_temp_rec.column_value := 'NULL';
     g_inbound_1_select(RELEASE_LINE_NUMBER) := l_temp_rec;

     l_temp_rec.column_name  := 'SHIPMENT_NUMBER';
     l_temp_rec.column_value := 'NULL';
     g_inbound_1_select(SHIPMENT_NUMBER) := l_temp_rec;

     l_temp_rec.column_name  := 'SHIPMENT_HEADER_ID_INTERORG';
     l_temp_rec.column_value := 'NULL';
     g_inbound_1_select(SHIPMENT_HEADER_ID_INTERORG) := l_temp_rec;

     l_temp_rec.column_name  := 'ASN';
     l_temp_rec.column_value := 'NULL';
     g_inbound_1_select(ASN) := l_temp_rec;

     l_temp_rec.column_name  := 'SHIPMENT_HEADER_ID_ASN';
     l_temp_rec.column_value := 'NULL';
     g_inbound_1_select(SHIPMENT_HEADER_ID_ASN) := l_temp_rec;

     l_temp_rec.column_name  := 'TRADING_PARTNER';
     l_temp_rec.column_value := 'NULL';
     g_inbound_1_select(TRADING_PARTNER) := l_temp_rec;

     l_temp_rec.column_name  := 'VENDOR_ID';
     l_temp_rec.column_value := 'NULL';
     g_inbound_1_select(VENDOR_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'TRADING_PARTNER_SITE';
     l_temp_rec.column_value := 'NULL';
     g_inbound_1_select(TRADING_PARTNER_SITE) := l_temp_rec;

     l_temp_rec.column_name  := 'VENDOR_SITE_ID';
     l_temp_rec.column_value := 'NULL';
     g_inbound_1_select(VENDOR_SITE_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'FROM_ORG';
     l_temp_rec.column_value := 'NULL';
     g_inbound_1_select(FROM_ORG) := l_temp_rec;

     l_temp_rec.column_name  := 'FROM_ORG_ID';
     l_temp_rec.column_value := 'NULL';
     g_inbound_1_select(FROM_ORG_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'TO_ORG';
     l_temp_rec.column_value := 'NULL';
     g_inbound_1_select(TO_ORG) := l_temp_rec;

     l_temp_rec.column_name  := 'TO_ORG_ID';
     l_temp_rec.column_value := 'NULL';
     g_inbound_1_select(TO_ORG_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'EXPECTED_RECEIPT_DATE';
     l_temp_rec.column_value := 'NULL';
     g_inbound_1_select(EXPECTED_RECEIPT_DATE) := l_temp_rec;

     l_temp_rec.column_name  := 'SHIPPED_DATE';
     l_temp_rec.column_value := 'NULL';
     g_inbound_1_select(SHIPPED_DATE) := l_temp_rec;

     l_temp_rec.column_name  := 'OWNING_ORG';
     l_temp_rec.column_value := 'NULL';
     g_inbound_1_select(OWNING_ORG) := l_temp_rec;

     l_temp_rec.column_name  := 'OWNING_ORG_ID';
     l_temp_rec.column_value := 'NULL';
     g_inbound_1_select(OWNING_ORG_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'REQ_HEADER_ID';
     l_temp_rec.column_value := 'NULL';
     g_inbound_1_select(REQ_HEADER_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'OE_HEADER_ID';
     l_temp_rec.column_value := 'NULL';
     g_inbound_1_select(OE_HEADER_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'PO_HEADER_ID';
     l_temp_rec.column_value := 'NULL';
     g_inbound_1_select(PO_HEADER_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'MATURITY_DATE';
     l_temp_rec.column_value := 'NULL';
     g_inbound_1_select(MATURITY_DATE) := l_temp_rec;

     l_temp_rec.column_name  := 'HOLD_DATE';
     l_temp_rec.column_value := 'NULL';
     g_inbound_1_select(HOLD_DATE) := l_temp_rec;

     l_temp_rec.column_name  := 'SUPPLIER_LOT';
     l_temp_rec.column_value := 'NULL';
     g_inbound_1_select(SUPPLIER_LOT) := l_temp_rec;

     l_temp_rec.column_name  := 'PARENT_LOT';
     l_temp_rec.column_value := 'NULL';
     g_inbound_1_select(PARENT_LOT) := l_temp_rec;

     l_temp_rec.column_name  := 'DOCUMENT_TYPE';
     l_temp_rec.column_value := 'NULL';
     g_inbound_1_select(DOCUMENT_TYPE) := l_temp_rec;

     l_temp_rec.column_name  := 'DOCUMENT_TYPE_ID';
     l_temp_rec.column_value := 'NULL';
     g_inbound_1_select(DOCUMENT_TYPE_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'DOCUMENT_NUMBER';
     l_temp_rec.column_value := 'NULL';
     g_inbound_1_select(DOCUMENT_NUMBER) := l_temp_rec;

     l_temp_rec.column_name  := 'DOCUMENT_LINE_NUMBER';
     l_temp_rec.column_value := 'NULL';
     g_inbound_1_select(DOCUMENT_LINE_NUMBER) := l_temp_rec;

     l_temp_rec.column_name  := 'RELEASE_NUMBER';
     l_temp_rec.column_value := 'NULL';
     g_inbound_1_select(RELEASE_NUMBER) := l_temp_rec;

     l_temp_rec.column_name  := 'ORIGINATION_TYPE';
     l_temp_rec.column_value := 'NULL';
     g_inbound_1_select(ORIGINATION_TYPE) := l_temp_rec;

     l_temp_rec.column_name  := 'ORIGINATION_DATE';
     l_temp_rec.column_value := 'NULL';
     g_inbound_1_select(ORIGINATION_DATE) := l_temp_rec;

     l_temp_rec.column_name  := 'ACTION_CODE';
     l_temp_rec.column_value := 'NULL';
     g_inbound_1_select(ACTION_CODE) := l_temp_rec;

     l_temp_rec.column_name  := 'ACTION_DATE';
     l_temp_rec.column_value := 'NULL';
     g_inbound_1_select(ACTION_DATE) := l_temp_rec;

     l_temp_rec.column_name  := 'RETEST_DATE';
     l_temp_rec.column_value := 'NULL';
     g_inbound_1_select(RETEST_DATE) := l_temp_rec;

     l_temp_rec.column_name  := 'SECONDARY_UNPACKED';
     l_temp_rec.column_value := 'NULL';
     g_inbound_1_select(SECONDARY_UNPACKED) := l_temp_rec;

     l_temp_rec.column_name  := 'SECONDARY_PACKED';
     l_temp_rec.column_value := 'NULL';
     g_inbound_1_select(SECONDARY_PACKED) := l_temp_rec;

     l_temp_rec.column_name  := 'SUBINVENTORY_CODE';
     l_temp_rec.column_value := 'NULL';
     g_inbound_1_select(SUBINVENTORY_CODE) := l_temp_rec;

     l_temp_rec.column_name  := 'LOCATOR';
     l_temp_rec.column_value := 'NULL';
     g_inbound_1_select(LOCATOR) := l_temp_rec;

     l_temp_rec.column_name  := 'LOCATOR_ID';
     l_temp_rec.column_value := 'NULL';
     g_inbound_1_select(LOCATOR_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'LPN';
     l_temp_rec.column_value := 'NULL';
     g_inbound_1_select(LPN) := l_temp_rec;

     l_temp_rec.column_name  := 'LPN_ID';
     l_temp_rec.column_value := 'NULL';
     g_inbound_1_select(LPN_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'COST_GROUP';
     l_temp_rec.column_value := 'NULL';
     g_inbound_1_select(COST_GROUP) := l_temp_rec;

     l_temp_rec.column_name  := 'GRADE_CODE';
     l_temp_rec.column_value := 'NULL';
     g_inbound_1_select(GRADE_CODE) := l_temp_rec;

     l_temp_rec.column_name  := 'CG_ID';
     l_temp_rec.column_value := 'NULL';
     g_inbound_1_select(CG_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'LOADED';
     l_temp_rec.column_value := 'NULL';
     g_inbound_1_select(LOADED) := l_temp_rec;

     l_temp_rec.column_name  := 'PLANNING_PARTY';
     l_temp_rec.column_value := 'NULL';
     g_inbound_1_select(PLANNING_PARTY) := l_temp_rec;

     l_temp_rec.column_name  := 'PLANNING_PARTY_ID';
     l_temp_rec.column_value := 'NULL';
     g_inbound_1_select(PLANNING_PARTY_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'OWNING_PARTY';
     l_temp_rec.column_value := 'NULL';
     g_inbound_1_select(OWNING_PARTY) := l_temp_rec;

     l_temp_rec.column_name  := 'OWNING_PARTY_ID';
     l_temp_rec.column_value := 'NULL';
     g_inbound_1_select(OWNING_PARTY_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'LOT';
     l_temp_rec.column_value := 'NULL';
     g_inbound_1_select(LOT) := l_temp_rec;


     l_temp_rec.column_name  := 'SERIAL';
     l_temp_rec.column_value := 'NULL';
     g_inbound_1_select(SERIAL) := l_temp_rec;

     l_temp_rec.column_name  := 'UNIT_NUMBER';
     l_temp_rec.column_value := 'NULL';
     g_inbound_1_select(UNIT_NUMBER) := l_temp_rec;

     l_temp_rec.column_name  := 'LOT_EXPIRY_DATE';
     l_temp_rec.column_value := 'NULL';
     g_inbound_1_select(LOT_EXPIRY_DATE) := l_temp_rec;

     l_temp_rec.column_name  := 'ORGANIZATION_CODE';
     l_temp_rec.column_value := 'NULL';
     g_inbound_1_select(ORGANIZATION_CODE) := l_temp_rec;

     l_temp_rec.column_name  := 'ORG_ID';
     l_temp_rec.column_value := 'NULL';
     g_inbound_1_select(ORG_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'ITEM';
     l_temp_rec.column_value := 'NULL';
     g_inbound_1_select(ITEM) := l_temp_rec;

     l_temp_rec.column_name  := 'ITEM_DESCRIPTION';
     l_temp_rec.column_value := 'NULL';
     g_inbound_1_select(ITEM_DESCRIPTION) := l_temp_rec;

     l_temp_rec.column_name  := 'ITEM_ID';
     l_temp_rec.column_value := 'NULL';
     g_inbound_1_select(ITEM_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'REVISION';
     l_temp_rec.column_value := 'NULL';
     g_inbound_1_select(REVISION) := l_temp_rec;

     l_temp_rec.column_name  := 'PRIMARY_UOM_CODE';
     l_temp_rec.column_value := 'NULL';
     g_inbound_1_select(PRIMARY_UOM_CODE) := l_temp_rec;

     l_temp_rec.column_name  := 'ONHAND';
     l_temp_rec.column_value := 'NULL';
     g_inbound_1_select(ONHAND) := l_temp_rec;

     l_temp_rec.column_name  := 'RECEIVING';
     l_temp_rec.column_value := 'NULL';
     g_inbound_1_select(RECEIVING) := l_temp_rec;

     l_temp_rec.column_name  := 'INBOUND';
     l_temp_rec.column_value := 'NULL';
     g_inbound_1_select(INBOUND) := l_temp_rec;

     l_temp_rec.column_name  := 'UNPACKED';
     l_temp_rec.column_value := 'NULL';
     g_inbound_1_select(UNPACKED) := l_temp_rec;

     l_temp_rec.column_name  := 'PACKED';
     l_temp_rec.column_value := 'NULL';
     g_inbound_1_select(PACKED) := l_temp_rec;

     l_temp_rec.column_name  := 'SECONDARY_UOM_CODE';
     l_temp_rec.column_value := 'NULL';
     g_inbound_1_select(SECONDARY_UOM_CODE) := l_temp_rec;

     l_temp_rec.column_name  := 'SECONDARY_ONHAND';
     l_temp_rec.column_value := 'NULL';
     g_inbound_1_select(SECONDARY_ONHAND) := l_temp_rec;

     l_temp_rec.column_name  := 'SECONDARY_RECEIVING';
     l_temp_rec.column_value := 'NULL';
     g_inbound_1_select(SECONDARY_RECEIVING) := l_temp_rec;

     l_temp_rec.column_name  := 'SECONDARY_INBOUND';
     l_temp_rec.column_value := 'NULL';
     g_inbound_1_select(SECONDARY_INBOUND) := l_temp_rec;

     l_temp_rec.column_name  := 'OWNING_ORGANIZATION_ID';
     l_temp_rec.column_value := 'NULL';
     g_inbound_1_select(OWNING_ORGANIZATION_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'PLANNING_ORGANIZATION_ID';
     l_temp_rec.column_value := 'NULL';
     g_inbound_1_select(PLANNING_ORGANIZATION_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'OWNING_TP_TYPE';
     l_temp_rec.column_value := 'NULL';
     g_inbound_1_select(OWNING_TP_TYPE) := l_temp_rec;

     l_temp_rec.column_name  := 'PLANNING_TP_TYPE';
     l_temp_rec.column_value := 'NULL';
     g_inbound_1_select(PLANNING_TP_TYPE) := l_temp_rec;

     -- Bug 6843313 Onhand Material Status support
     l_temp_rec.column_name  := 'STATUS';
     l_temp_rec.column_value := 'NULL';
     g_inbound_1_select(STATUS) := l_temp_rec;

     l_temp_rec.column_name  := 'STATUS_ID';
     l_temp_rec.column_value := 'NULL';
     g_inbound_1_select(STATUS_ID) := l_temp_rec;

  END initialize_inbound_1_query;

  PROCEDURE initialize_receiving_query IS
     l_procedure_name VARCHAR2(30);
     l_temp_rec       SelectColumnRecType;
  BEGIN

     l_procedure_name := 'INBOUND_RECEIVING_QUERY';

     g_receiving_select.DELETE;
     g_receiving_from.DELETE;
     g_receiving_where.DELETE;
     g_receiving_group.DELETE;

     g_receiving_from_index := 1;
     g_receiving_where_index := 1;
     g_receiving_group_index := 1;

     l_temp_rec.column_name  := 'PO_RELEASE_ID';
     l_temp_rec.column_value := 'NULL';
     g_receiving_select(PO_RELEASE_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'RELEASE_LINE_NUMBER';
     l_temp_rec.column_value := 'NULL';
     g_receiving_select(RELEASE_LINE_NUMBER) := l_temp_rec;

     l_temp_rec.column_name  := 'SHIPMENT_NUMBER';
     l_temp_rec.column_value := 'NULL';
     g_receiving_select(SHIPMENT_NUMBER) := l_temp_rec;

     l_temp_rec.column_name  := 'SHIPMENT_HEADER_ID_INTERORG';
     l_temp_rec.column_value := 'NULL';
     g_receiving_select(SHIPMENT_HEADER_ID_INTERORG) := l_temp_rec;

     l_temp_rec.column_name  := 'ASN';
     l_temp_rec.column_value := 'NULL';
     g_receiving_select(ASN) := l_temp_rec;

     l_temp_rec.column_name  := 'SHIPMENT_HEADER_ID_ASN';
     l_temp_rec.column_value := 'NULL';
     g_receiving_select(SHIPMENT_HEADER_ID_ASN) := l_temp_rec;

     l_temp_rec.column_name  := 'TRADING_PARTNER';
     l_temp_rec.column_value := 'NULL';
     g_receiving_select(TRADING_PARTNER) := l_temp_rec;

     l_temp_rec.column_name  := 'VENDOR_ID';
     l_temp_rec.column_value := 'NULL';
     g_receiving_select(VENDOR_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'TRADING_PARTNER_SITE';
     l_temp_rec.column_value := 'NULL';
     g_receiving_select(TRADING_PARTNER_SITE) := l_temp_rec;

     l_temp_rec.column_name  := 'VENDOR_SITE_ID';
     l_temp_rec.column_value := 'NULL';
     g_receiving_select(VENDOR_SITE_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'FROM_ORG';
     l_temp_rec.column_value := 'NULL';
     g_receiving_select(FROM_ORG) := l_temp_rec;

     l_temp_rec.column_name  := 'FROM_ORG_ID';
     l_temp_rec.column_value := 'NULL';
     g_receiving_select(FROM_ORG_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'TO_ORG';
     l_temp_rec.column_value := 'NULL';
     g_receiving_select(TO_ORG) := l_temp_rec;

     l_temp_rec.column_name  := 'TO_ORG_ID';
     l_temp_rec.column_value := 'NULL';
     g_receiving_select(TO_ORG_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'EXPECTED_RECEIPT_DATE';
     l_temp_rec.column_value := 'NULL';
     g_receiving_select(EXPECTED_RECEIPT_DATE) := l_temp_rec;

     l_temp_rec.column_name  := 'SHIPPED_DATE';
     l_temp_rec.column_value := 'NULL';
     g_receiving_select(SHIPPED_DATE) := l_temp_rec;

     l_temp_rec.column_name  := 'OWNING_ORG';
     l_temp_rec.column_value := 'NULL';
     g_receiving_select(OWNING_ORG) := l_temp_rec;

     l_temp_rec.column_name  := 'OWNING_ORG_ID';
     l_temp_rec.column_value := 'NULL';
     g_receiving_select(OWNING_ORG_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'REQ_HEADER_ID';
     l_temp_rec.column_value := 'NULL';
     g_receiving_select(REQ_HEADER_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'OE_HEADER_ID';
     l_temp_rec.column_value := 'NULL';
     g_receiving_select(OE_HEADER_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'PO_HEADER_ID';
     l_temp_rec.column_value := 'NULL';
     g_receiving_select(PO_HEADER_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'MATURITY_DATE';
     l_temp_rec.column_value := 'NULL';
     g_receiving_select(MATURITY_DATE) := l_temp_rec;

     l_temp_rec.column_name  := 'HOLD_DATE';
     l_temp_rec.column_value := 'NULL';
     g_receiving_select(HOLD_DATE) := l_temp_rec;

     l_temp_rec.column_name  := 'SUPPLIER_LOT';
     l_temp_rec.column_value := 'NULL';
     g_receiving_select(SUPPLIER_LOT) := l_temp_rec;

     l_temp_rec.column_name  := 'PARENT_LOT';
     l_temp_rec.column_value := 'NULL';
     g_receiving_select(PARENT_LOT) := l_temp_rec;

     l_temp_rec.column_name  := 'DOCUMENT_TYPE';
     l_temp_rec.column_value := 'NULL';
     g_receiving_select(DOCUMENT_TYPE) := l_temp_rec;

     l_temp_rec.column_name  := 'DOCUMENT_TYPE_ID';
     l_temp_rec.column_value := 'NULL';
     g_receiving_select(DOCUMENT_TYPE_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'DOCUMENT_NUMBER';
     l_temp_rec.column_value := 'NULL';
     g_receiving_select(DOCUMENT_NUMBER) := l_temp_rec;

     l_temp_rec.column_name  := 'DOCUMENT_LINE_NUMBER';
     l_temp_rec.column_value := 'NULL';
     g_receiving_select(DOCUMENT_LINE_NUMBER) := l_temp_rec;

     l_temp_rec.column_name  := 'RELEASE_NUMBER';
     l_temp_rec.column_value := 'NULL';
     g_receiving_select(RELEASE_NUMBER) := l_temp_rec;

     l_temp_rec.column_name  := 'ORIGINATION_TYPE';
     l_temp_rec.column_value := 'NULL';
     g_receiving_select(ORIGINATION_TYPE) := l_temp_rec;

     l_temp_rec.column_name  := 'ORIGINATION_DATE';
     l_temp_rec.column_value := 'NULL';
     g_receiving_select(ORIGINATION_DATE) := l_temp_rec;

     l_temp_rec.column_name  := 'ACTION_CODE';
     l_temp_rec.column_value := 'NULL';
     g_receiving_select(ACTION_CODE) := l_temp_rec;

     l_temp_rec.column_name  := 'ACTION_DATE';
     l_temp_rec.column_value := 'NULL';
     g_receiving_select(ACTION_DATE) := l_temp_rec;

     l_temp_rec.column_name  := 'RETEST_DATE';
     l_temp_rec.column_value := 'NULL';
     g_receiving_select(RETEST_DATE) := l_temp_rec;

     l_temp_rec.column_name  := 'SECONDARY_UNPACKED';
     l_temp_rec.column_value := 'NULL';
     g_receiving_select(SECONDARY_UNPACKED) := l_temp_rec;

     l_temp_rec.column_name  := 'SECONDARY_PACKED';
     l_temp_rec.column_value := 'NULL';
     g_receiving_select(SECONDARY_PACKED) := l_temp_rec;

     l_temp_rec.column_name  := 'SUBINVENTORY_CODE';
     l_temp_rec.column_value := 'NULL';
     g_receiving_select(SUBINVENTORY_CODE) := l_temp_rec;

     l_temp_rec.column_name  := 'LOCATOR';
     l_temp_rec.column_value := 'NULL';
     g_receiving_select(LOCATOR) := l_temp_rec;

     l_temp_rec.column_name  := 'LOCATOR_ID';
     l_temp_rec.column_value := 'NULL';
     g_receiving_select(LOCATOR_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'LPN';
     l_temp_rec.column_value := 'NULL';
     g_receiving_select(LPN) := l_temp_rec;

     l_temp_rec.column_name  := 'LPN_ID';
     l_temp_rec.column_value := 'NULL';
     g_receiving_select(LPN_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'COST_GROUP';
     l_temp_rec.column_value := 'NULL';
     g_receiving_select(COST_GROUP) := l_temp_rec;

     l_temp_rec.column_name  := 'GRADE_CODE';
     l_temp_rec.column_value := 'NULL';
     g_receiving_select(GRADE_CODE) := l_temp_rec;

     l_temp_rec.column_name  := 'CG_ID';
     l_temp_rec.column_value := 'NULL';
     g_receiving_select(CG_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'LOADED';
     l_temp_rec.column_value := 'NULL';
     g_receiving_select(LOADED) := l_temp_rec;

     l_temp_rec.column_name  := 'PLANNING_PARTY';
     l_temp_rec.column_value := 'NULL';
     g_receiving_select(PLANNING_PARTY) := l_temp_rec;

     l_temp_rec.column_name  := 'PLANNING_PARTY_ID';
     l_temp_rec.column_value := 'NULL';
     g_receiving_select(PLANNING_PARTY_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'OWNING_PARTY';
     l_temp_rec.column_value := 'NULL';
     g_receiving_select(OWNING_PARTY) := l_temp_rec;

     l_temp_rec.column_name  := 'OWNING_PARTY_ID';
     l_temp_rec.column_value := 'NULL';
     g_receiving_select(OWNING_PARTY_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'LOT';
     l_temp_rec.column_value := 'NULL';
     g_receiving_select(LOT) := l_temp_rec;


     l_temp_rec.column_name  := 'SERIAL';
     l_temp_rec.column_value := 'NULL';
     g_receiving_select(SERIAL) := l_temp_rec;

     l_temp_rec.column_name  := 'UNIT_NUMBER';
     l_temp_rec.column_value := 'NULL';
     g_receiving_select(UNIT_NUMBER) := l_temp_rec;

     l_temp_rec.column_name  := 'LOT_EXPIRY_DATE';
     l_temp_rec.column_value := 'NULL';
     g_receiving_select(LOT_EXPIRY_DATE) := l_temp_rec;

     l_temp_rec.column_name  := 'ORGANIZATION_CODE';
     l_temp_rec.column_value := 'NULL';
     g_receiving_select(ORGANIZATION_CODE) := l_temp_rec;

     l_temp_rec.column_name  := 'ORG_ID';
     l_temp_rec.column_value := 'NULL';
     g_receiving_select(ORG_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'ITEM';
     l_temp_rec.column_value := 'NULL';
     g_receiving_select(ITEM) := l_temp_rec;

     l_temp_rec.column_name  := 'ITEM_DESCRIPTION';
     l_temp_rec.column_value := 'NULL';
     g_receiving_select(ITEM_DESCRIPTION) := l_temp_rec;

     l_temp_rec.column_name  := 'ITEM_ID';
     l_temp_rec.column_value := 'NULL';
     g_receiving_select(ITEM_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'REVISION';
     l_temp_rec.column_value := 'NULL';
     g_receiving_select(REVISION) := l_temp_rec;

     l_temp_rec.column_name  := 'PRIMARY_UOM_CODE';
     l_temp_rec.column_value := 'NULL';
     g_receiving_select(PRIMARY_UOM_CODE) := l_temp_rec;

     l_temp_rec.column_name  := 'ONHAND';
     l_temp_rec.column_value := 'NULL';
     g_receiving_select(ONHAND) := l_temp_rec;

     l_temp_rec.column_name  := 'RECEIVING';
     l_temp_rec.column_value := 'NULL';
     g_receiving_select(RECEIVING) := l_temp_rec;

     l_temp_rec.column_name  := 'INBOUND';
     l_temp_rec.column_value := 'NULL';
     g_receiving_select(INBOUND) := l_temp_rec;

     l_temp_rec.column_name  := 'UNPACKED';
     l_temp_rec.column_value := 'NULL';
     g_receiving_select(UNPACKED) := l_temp_rec;

     l_temp_rec.column_name  := 'PACKED';
     l_temp_rec.column_value := 'NULL';
     g_receiving_select(PACKED) := l_temp_rec;

     l_temp_rec.column_name  := 'SECONDARY_UOM_CODE';
     l_temp_rec.column_value := 'NULL';
     g_receiving_select(SECONDARY_UOM_CODE) := l_temp_rec;

     l_temp_rec.column_name  := 'SECONDARY_ONHAND';
     l_temp_rec.column_value := 'NULL';
     g_receiving_select(SECONDARY_ONHAND) := l_temp_rec;

     l_temp_rec.column_name  := 'SECONDARY_RECEIVING';
     l_temp_rec.column_value := 'NULL';
     g_receiving_select(SECONDARY_RECEIVING) := l_temp_rec;

     l_temp_rec.column_name  := 'SECONDARY_INBOUND';
     l_temp_rec.column_value := 'NULL';
     g_receiving_select(SECONDARY_INBOUND) := l_temp_rec;

     l_temp_rec.column_name  := 'OWNING_ORGANIZATION_ID';
     l_temp_rec.column_value := 'NULL';
     g_receiving_select(OWNING_ORGANIZATION_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'PLANNING_ORGANIZATION_ID';
     l_temp_rec.column_value := 'NULL';
     g_receiving_select(PLANNING_ORGANIZATION_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'OWNING_TP_TYPE';
     l_temp_rec.column_value := 'NULL';
     g_receiving_select(OWNING_TP_TYPE) := l_temp_rec;

     l_temp_rec.column_name  := 'PLANNING_TP_TYPE';
     l_temp_rec.column_value := 'NULL';
     g_receiving_select(PLANNING_TP_TYPE) := l_temp_rec;

     -- Bug 6843313 Onhand Material Status support
     l_temp_rec.column_name  := 'STATUS';
     l_temp_rec.column_value := 'NULL';
     g_receiving_select(STATUS) := l_temp_rec;

     l_temp_rec.column_name  := 'STATUS_ID';
     l_temp_rec.column_value := 'NULL';
     g_receiving_select(STATUS_ID) := l_temp_rec;

  END initialize_receiving_query;

  PROCEDURE initialize_receiving_1_query IS
     l_procedure_name VARCHAR2(30);
     l_temp_rec       SelectColumnRecType;
  BEGIN

     l_procedure_name := 'INBOUND_receiving_1_QUERY';

     g_receiving_1_select.DELETE;
     g_receiving_1_from.DELETE;
     g_receiving_1_where.DELETE;
     g_receiving_1_group.DELETE;

     g_receiving_1_from_index := 1;
     g_receiving_1_where_index := 1;
     g_receiving_1_group_index := 1;

     l_temp_rec.column_name  := 'PO_RELEASE_ID';
     l_temp_rec.column_value := 'NULL';
     g_receiving_1_select(PO_RELEASE_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'RELEASE_LINE_NUMBER';
     l_temp_rec.column_value := 'NULL';
     g_receiving_1_select(RELEASE_LINE_NUMBER) := l_temp_rec;

     l_temp_rec.column_name  := 'SHIPMENT_NUMBER';
     l_temp_rec.column_value := 'NULL';
     g_receiving_1_select(SHIPMENT_NUMBER) := l_temp_rec;

     l_temp_rec.column_name  := 'SHIPMENT_HEADER_ID_INTERORG';
     l_temp_rec.column_value := 'NULL';
     g_receiving_1_select(SHIPMENT_HEADER_ID_INTERORG) := l_temp_rec;

     l_temp_rec.column_name  := 'ASN';
     l_temp_rec.column_value := 'NULL';
     g_receiving_1_select(ASN) := l_temp_rec;

     l_temp_rec.column_name  := 'SHIPMENT_HEADER_ID_ASN';
     l_temp_rec.column_value := 'NULL';
     g_receiving_1_select(SHIPMENT_HEADER_ID_ASN) := l_temp_rec;

     l_temp_rec.column_name  := 'TRADING_PARTNER';
     l_temp_rec.column_value := 'NULL';
     g_receiving_1_select(TRADING_PARTNER) := l_temp_rec;

     l_temp_rec.column_name  := 'VENDOR_ID';
     l_temp_rec.column_value := 'NULL';
     g_receiving_1_select(VENDOR_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'TRADING_PARTNER_SITE';
     l_temp_rec.column_value := 'NULL';
     g_receiving_1_select(TRADING_PARTNER_SITE) := l_temp_rec;

     l_temp_rec.column_name  := 'VENDOR_SITE_ID';
     l_temp_rec.column_value := 'NULL';
     g_receiving_1_select(VENDOR_SITE_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'FROM_ORG';
     l_temp_rec.column_value := 'NULL';
     g_receiving_1_select(FROM_ORG) := l_temp_rec;

     l_temp_rec.column_name  := 'FROM_ORG_ID';
     l_temp_rec.column_value := 'NULL';
     g_receiving_1_select(FROM_ORG_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'TO_ORG';
     l_temp_rec.column_value := 'NULL';
     g_receiving_1_select(TO_ORG) := l_temp_rec;

     l_temp_rec.column_name  := 'TO_ORG_ID';
     l_temp_rec.column_value := 'NULL';
     g_receiving_1_select(TO_ORG_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'EXPECTED_RECEIPT_DATE';
     l_temp_rec.column_value := 'NULL';
     g_receiving_1_select(EXPECTED_RECEIPT_DATE) := l_temp_rec;

     l_temp_rec.column_name  := 'SHIPPED_DATE';
     l_temp_rec.column_value := 'NULL';
     g_receiving_1_select(SHIPPED_DATE) := l_temp_rec;

     l_temp_rec.column_name  := 'OWNING_ORG';
     l_temp_rec.column_value := 'NULL';
     g_receiving_1_select(OWNING_ORG) := l_temp_rec;

     l_temp_rec.column_name  := 'OWNING_ORG_ID';
     l_temp_rec.column_value := 'NULL';
     g_receiving_1_select(OWNING_ORG_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'REQ_HEADER_ID';
     l_temp_rec.column_value := 'NULL';
     g_receiving_1_select(REQ_HEADER_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'OE_HEADER_ID';
     l_temp_rec.column_value := 'NULL';
     g_receiving_1_select(OE_HEADER_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'PO_HEADER_ID';
     l_temp_rec.column_value := 'NULL';
     g_receiving_1_select(PO_HEADER_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'MATURITY_DATE';
     l_temp_rec.column_value := 'NULL';
     g_receiving_1_select(MATURITY_DATE) := l_temp_rec;

     l_temp_rec.column_name  := 'HOLD_DATE';
     l_temp_rec.column_value := 'NULL';
     g_receiving_1_select(HOLD_DATE) := l_temp_rec;

     l_temp_rec.column_name  := 'SUPPLIER_LOT';
     l_temp_rec.column_value := 'NULL';
     g_receiving_1_select(SUPPLIER_LOT) := l_temp_rec;

     l_temp_rec.column_name  := 'PARENT_LOT';
     l_temp_rec.column_value := 'NULL';
     g_receiving_1_select(PARENT_LOT) := l_temp_rec;

     l_temp_rec.column_name  := 'DOCUMENT_TYPE';
     l_temp_rec.column_value := 'NULL';
     g_receiving_1_select(DOCUMENT_TYPE) := l_temp_rec;

     l_temp_rec.column_name  := 'DOCUMENT_TYPE_ID';
     l_temp_rec.column_value := 'NULL';
     g_receiving_1_select(DOCUMENT_TYPE_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'DOCUMENT_NUMBER';
     l_temp_rec.column_value := 'NULL';
     g_receiving_1_select(DOCUMENT_NUMBER) := l_temp_rec;

     l_temp_rec.column_name  := 'DOCUMENT_LINE_NUMBER';
     l_temp_rec.column_value := 'NULL';
     g_receiving_1_select(DOCUMENT_LINE_NUMBER) := l_temp_rec;

     l_temp_rec.column_name  := 'RELEASE_NUMBER';
     l_temp_rec.column_value := 'NULL';
     g_receiving_1_select(RELEASE_NUMBER) := l_temp_rec;

     l_temp_rec.column_name  := 'ORIGINATION_TYPE';
     l_temp_rec.column_value := 'NULL';
     g_receiving_1_select(ORIGINATION_TYPE) := l_temp_rec;

     l_temp_rec.column_name  := 'ORIGINATION_DATE';
     l_temp_rec.column_value := 'NULL';
     g_receiving_1_select(ORIGINATION_DATE) := l_temp_rec;

     l_temp_rec.column_name  := 'ACTION_CODE';
     l_temp_rec.column_value := 'NULL';
     g_receiving_1_select(ACTION_CODE) := l_temp_rec;

     l_temp_rec.column_name  := 'ACTION_DATE';
     l_temp_rec.column_value := 'NULL';
     g_receiving_1_select(ACTION_DATE) := l_temp_rec;

     l_temp_rec.column_name  := 'RETEST_DATE';
     l_temp_rec.column_value := 'NULL';
     g_receiving_1_select(RETEST_DATE) := l_temp_rec;

     l_temp_rec.column_name  := 'SECONDARY_UNPACKED';
     l_temp_rec.column_value := 'NULL';
     g_receiving_1_select(SECONDARY_UNPACKED) := l_temp_rec;

     l_temp_rec.column_name  := 'SECONDARY_PACKED';
     l_temp_rec.column_value := 'NULL';
     g_receiving_1_select(SECONDARY_PACKED) := l_temp_rec;

     l_temp_rec.column_name  := 'SUBINVENTORY_CODE';
     l_temp_rec.column_value := 'NULL';
     g_receiving_1_select(SUBINVENTORY_CODE) := l_temp_rec;

     l_temp_rec.column_name  := 'LOCATOR';
     l_temp_rec.column_value := 'NULL';
     g_receiving_1_select(LOCATOR) := l_temp_rec;

     l_temp_rec.column_name  := 'LOCATOR_ID';
     l_temp_rec.column_value := 'NULL';
     g_receiving_1_select(LOCATOR_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'LPN';
     l_temp_rec.column_value := 'NULL';
     g_receiving_1_select(LPN) := l_temp_rec;

     l_temp_rec.column_name  := 'LPN_ID';
     l_temp_rec.column_value := 'NULL';
     g_receiving_1_select(LPN_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'COST_GROUP';
     l_temp_rec.column_value := 'NULL';
     g_receiving_1_select(COST_GROUP) := l_temp_rec;

     l_temp_rec.column_name  := 'GRADE_CODE';
     l_temp_rec.column_value := 'NULL';
     g_receiving_1_select(GRADE_CODE) := l_temp_rec;

     l_temp_rec.column_name  := 'CG_ID';
     l_temp_rec.column_value := 'NULL';
     g_receiving_1_select(CG_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'LOADED';
     l_temp_rec.column_value := 'NULL';
     g_receiving_1_select(LOADED) := l_temp_rec;

     l_temp_rec.column_name  := 'PLANNING_PARTY';
     l_temp_rec.column_value := 'NULL';
     g_receiving_1_select(PLANNING_PARTY) := l_temp_rec;

     l_temp_rec.column_name  := 'PLANNING_PARTY_ID';
     l_temp_rec.column_value := 'NULL';
     g_receiving_1_select(PLANNING_PARTY_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'OWNING_PARTY';
     l_temp_rec.column_value := 'NULL';
     g_receiving_1_select(OWNING_PARTY) := l_temp_rec;

     l_temp_rec.column_name  := 'OWNING_PARTY_ID';
     l_temp_rec.column_value := 'NULL';
     g_receiving_1_select(OWNING_PARTY_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'LOT';
     l_temp_rec.column_value := 'NULL';
     g_receiving_1_select(LOT) := l_temp_rec;


     l_temp_rec.column_name  := 'SERIAL';
     l_temp_rec.column_value := 'NULL';
     g_receiving_1_select(SERIAL) := l_temp_rec;

     l_temp_rec.column_name  := 'UNIT_NUMBER';
     l_temp_rec.column_value := 'NULL';
     g_receiving_1_select(UNIT_NUMBER) := l_temp_rec;

     l_temp_rec.column_name  := 'LOT_EXPIRY_DATE';
     l_temp_rec.column_value := 'NULL';
     g_receiving_1_select(LOT_EXPIRY_DATE) := l_temp_rec;

     l_temp_rec.column_name  := 'ORGANIZATION_CODE';
     l_temp_rec.column_value := 'NULL';
     g_receiving_1_select(ORGANIZATION_CODE) := l_temp_rec;

     l_temp_rec.column_name  := 'ORG_ID';
     l_temp_rec.column_value := 'NULL';
     g_receiving_1_select(ORG_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'ITEM';
     l_temp_rec.column_value := 'NULL';
     g_receiving_1_select(ITEM) := l_temp_rec;

     l_temp_rec.column_name  := 'ITEM_DESCRIPTION';
     l_temp_rec.column_value := 'NULL';
     g_receiving_1_select(ITEM_DESCRIPTION) := l_temp_rec;

     l_temp_rec.column_name  := 'ITEM_ID';
     l_temp_rec.column_value := 'NULL';
     g_receiving_1_select(ITEM_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'REVISION';
     l_temp_rec.column_value := 'NULL';
     g_receiving_1_select(REVISION) := l_temp_rec;

     l_temp_rec.column_name  := 'PRIMARY_UOM_CODE';
     l_temp_rec.column_value := 'NULL';
     g_receiving_1_select(PRIMARY_UOM_CODE) := l_temp_rec;

     l_temp_rec.column_name  := 'ONHAND';
     l_temp_rec.column_value := 'NULL';
     g_receiving_1_select(ONHAND) := l_temp_rec;

     l_temp_rec.column_name  := 'RECEIVING';
     l_temp_rec.column_value := 'NULL';
     g_receiving_1_select(RECEIVING) := l_temp_rec;

     l_temp_rec.column_name  := 'INBOUND';
     l_temp_rec.column_value := 'NULL';
     g_receiving_1_select(INBOUND) := l_temp_rec;

     l_temp_rec.column_name  := 'UNPACKED';
     l_temp_rec.column_value := 'NULL';
     g_receiving_1_select(UNPACKED) := l_temp_rec;

     l_temp_rec.column_name  := 'PACKED';
     l_temp_rec.column_value := 'NULL';
     g_receiving_1_select(PACKED) := l_temp_rec;

     l_temp_rec.column_name  := 'SECONDARY_UOM_CODE';
     l_temp_rec.column_value := 'NULL';
     g_receiving_1_select(SECONDARY_UOM_CODE) := l_temp_rec;

     l_temp_rec.column_name  := 'SECONDARY_ONHAND';
     l_temp_rec.column_value := 'NULL';
     g_receiving_1_select(SECONDARY_ONHAND) := l_temp_rec;

     l_temp_rec.column_name  := 'SECONDARY_RECEIVING';
     l_temp_rec.column_value := 'NULL';
     g_receiving_1_select(SECONDARY_RECEIVING) := l_temp_rec;

     l_temp_rec.column_name  := 'SECONDARY_INBOUND';
     l_temp_rec.column_value := 'NULL';
     g_receiving_1_select(SECONDARY_INBOUND) := l_temp_rec;

     l_temp_rec.column_name  := 'OWNING_ORGANIZATION_ID';
     l_temp_rec.column_value := 'NULL';
     g_receiving_1_select(OWNING_ORGANIZATION_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'PLANNING_ORGANIZATION_ID';
     l_temp_rec.column_value := 'NULL';
     g_receiving_1_select(PLANNING_ORGANIZATION_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'OWNING_TP_TYPE';
     l_temp_rec.column_value := 'NULL';
     g_receiving_1_select(OWNING_TP_TYPE) := l_temp_rec;

     l_temp_rec.column_name  := 'PLANNING_TP_TYPE';
     l_temp_rec.column_value := 'NULL';
     g_receiving_1_select(PLANNING_TP_TYPE) := l_temp_rec;

     -- Bug 6843313 Onhand Material Status support
     l_temp_rec.column_name  := 'STATUS';
     l_temp_rec.column_value := 'NULL';
     g_receiving_1_select(STATUS) := l_temp_rec;

     l_temp_rec.column_name  := 'STATUS_ID';
     l_temp_rec.column_value := 'NULL';
     g_receiving_1_select(STATUS_ID) := l_temp_rec;

  END initialize_receiving_1_query;

  PROCEDURE initialize_union_query IS
     l_procedure_name VARCHAR2(30);
     l_temp_rec       SelectColumnRecType;
  BEGIN

     l_procedure_name := 'INTIALIZE_COMBINED_QUERY';

     g_date_bind_tab.DELETE;
     g_number_bind_tab.DELETE;
     g_varchar_bind_tab.DELETE;

     g_union_select.DELETE;
     g_union_group.DELETE;

     l_temp_rec.column_name  := 'PO_RELEASE_ID';
     l_temp_rec.column_value := 'PO_RELEASE_ID';
     g_union_select(PO_RELEASE_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'RELEASE_LINE_NUMBER';
     l_temp_rec.column_value := 'RELEASE_LINE_NUMBER';
     g_union_select(RELEASE_LINE_NUMBER) := l_temp_rec;

     l_temp_rec.column_name  := 'SHIPMENT_NUMBER';
     l_temp_rec.column_value := 'SHIPMENT_NUMBER';
     g_union_select(SHIPMENT_NUMBER) := l_temp_rec;

     l_temp_rec.column_name  := 'SHIPMENT_HEADER_ID_INTERORG';
     l_temp_rec.column_value := 'SHIPMENT_HEADER_ID_INTERORG';
     g_union_select(SHIPMENT_HEADER_ID_INTERORG) := l_temp_rec;

     l_temp_rec.column_name  := 'ASN';
     l_temp_rec.column_value := 'ASN';
     g_union_select(ASN) := l_temp_rec;

     l_temp_rec.column_name  := 'SHIPMENT_HEADER_ID_ASN';
     l_temp_rec.column_value := 'SHIPMENT_HEADER_ID_ASN';
     g_union_select(SHIPMENT_HEADER_ID_ASN) := l_temp_rec;

     l_temp_rec.column_name  := 'TRADING_PARTNER';
     l_temp_rec.column_value := 'TRADING_PARTNER';
     g_union_select(TRADING_PARTNER) := l_temp_rec;

     l_temp_rec.column_name  := 'VENDOR_ID';
     l_temp_rec.column_value := 'VENDOR_ID';
     g_union_select(VENDOR_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'TRADING_PARTNER_SITE';
     l_temp_rec.column_value := 'TRADING_PARTNER_SITE';
     g_union_select(TRADING_PARTNER_SITE) := l_temp_rec;

     l_temp_rec.column_name  := 'VENDOR_SITE_ID';
     l_temp_rec.column_value := 'VENDOR_SITE_ID';
     g_union_select(VENDOR_SITE_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'FROM_ORG';
     l_temp_rec.column_value := 'FROM_ORG';
     g_union_select(FROM_ORG) := l_temp_rec;

     l_temp_rec.column_name  := 'FROM_ORG_ID';
     l_temp_rec.column_value := 'FROM_ORG_ID';
     g_union_select(FROM_ORG_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'TO_ORG';
     l_temp_rec.column_value := 'TO_ORG';
     g_union_select(TO_ORG) := l_temp_rec;

     l_temp_rec.column_name  := 'TO_ORG_ID';
     l_temp_rec.column_value := 'TO_ORG_ID';
     g_union_select(TO_ORG_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'EXPECTED_RECEIPT_DATE';
     l_temp_rec.column_value := 'EXPECTED_RECEIPT_DATE';
     g_union_select(EXPECTED_RECEIPT_DATE) := l_temp_rec;

     l_temp_rec.column_name  := 'SHIPPED_DATE';
     l_temp_rec.column_value := 'SHIPPED_DATE';
     g_union_select(SHIPPED_DATE) := l_temp_rec;

     l_temp_rec.column_name  := 'OWNING_ORG';
     l_temp_rec.column_value := 'OWNING_ORG';
     g_union_select(OWNING_ORG) := l_temp_rec;

     l_temp_rec.column_name  := 'OWNING_ORG_ID';
     l_temp_rec.column_value := 'OWNING_ORG_ID';
     g_union_select(OWNING_ORG_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'REQ_HEADER_ID';
     l_temp_rec.column_value := 'REQ_HEADER_ID';
     g_union_select(REQ_HEADER_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'OE_HEADER_ID';
     l_temp_rec.column_value := 'OE_HEADER_ID';
     g_union_select(OE_HEADER_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'PO_HEADER_ID';
     l_temp_rec.column_value := 'PO_HEADER_ID';
     g_union_select(PO_HEADER_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'MATURITY_DATE';
     l_temp_rec.column_value := 'MATURITY_DATE';
     g_union_select(MATURITY_DATE) := l_temp_rec;

     l_temp_rec.column_name  := 'HOLD_DATE';
     l_temp_rec.column_value := 'HOLD_DATE';
     g_union_select(HOLD_DATE) := l_temp_rec;

     l_temp_rec.column_name  := 'SUPPLIER_LOT';
     l_temp_rec.column_value := 'SUPPLIER_LOT';
     g_union_select(SUPPLIER_LOT) := l_temp_rec;

     l_temp_rec.column_name  := 'PARENT_LOT';
     l_temp_rec.column_value := 'PARENT_LOT';
     g_union_select(PARENT_LOT) := l_temp_rec;

     l_temp_rec.column_name  := 'DOCUMENT_TYPE';
     l_temp_rec.column_value := 'DOCUMENT_TYPE';
     g_union_select(DOCUMENT_TYPE) := l_temp_rec;

     l_temp_rec.column_name  := 'DOCUMENT_TYPE_ID';
     l_temp_rec.column_value := 'DOCUMENT_TYPE_ID';
     g_union_select(DOCUMENT_TYPE_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'DOCUMENT_NUMBER';
     l_temp_rec.column_value := 'DOCUMENT_NUMBER';
     g_union_select(DOCUMENT_NUMBER) := l_temp_rec;

     l_temp_rec.column_name  := 'DOCUMENT_LINE_NUMBER';
     l_temp_rec.column_value := 'DOCUMENT_LINE_NUMBER';
     g_union_select(DOCUMENT_LINE_NUMBER) := l_temp_rec;

     l_temp_rec.column_name  := 'RELEASE_NUMBER';
     l_temp_rec.column_value := 'RELEASE_NUMBER';
     g_union_select(RELEASE_NUMBER) := l_temp_rec;

     l_temp_rec.column_name  := 'ORIGINATION_TYPE';
     l_temp_rec.column_value := 'ORIGINATION_TYPE';
     g_union_select(ORIGINATION_TYPE) := l_temp_rec;

     l_temp_rec.column_name  := 'ORIGINATION_DATE';
     l_temp_rec.column_value := 'ORIGINATION_DATE';
     g_union_select(ORIGINATION_DATE) := l_temp_rec;

     l_temp_rec.column_name  := 'ACTION_CODE';
     l_temp_rec.column_value := 'ACTION_CODE';
     g_union_select(ACTION_CODE) := l_temp_rec;

     l_temp_rec.column_name  := 'ACTION_DATE';
     l_temp_rec.column_value := 'ACTION_DATE';
     g_union_select(ACTION_DATE) := l_temp_rec;

     l_temp_rec.column_name  := 'RETEST_DATE';
     l_temp_rec.column_value := 'RETEST_DATE';
     g_union_select(RETEST_DATE) := l_temp_rec;

     l_temp_rec.column_name  := 'SECONDARY_UNPACKED';
     l_temp_rec.column_value := 'SUM(SECONDARY_UNPACKED)';
     g_union_select(SECONDARY_UNPACKED) := l_temp_rec;

     l_temp_rec.column_name  := 'SECONDARY_PACKED';
     l_temp_rec.column_value := 'SUM(SECONDARY_PACKED)';
     g_union_select(SECONDARY_PACKED) := l_temp_rec;

     l_temp_rec.column_name  := 'SUBINVENTORY_CODE';
     l_temp_rec.column_value := 'SUBINVENTORY_CODE';
     g_union_select(SUBINVENTORY_CODE) := l_temp_rec;

     l_temp_rec.column_name  := 'LOCATOR';
     l_temp_rec.column_value := 'LOCATOR';
     g_union_select(LOCATOR) := l_temp_rec;

     l_temp_rec.column_name  := 'LOCATOR_ID';
     l_temp_rec.column_value := 'LOCATOR_ID';
     g_union_select(LOCATOR_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'LPN';
     l_temp_rec.column_value := 'LPN';
     g_union_select(LPN) := l_temp_rec;

     l_temp_rec.column_name  := 'LPN_ID';
     l_temp_rec.column_value := 'LPN_ID';
     g_union_select(LPN_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'COST_GROUP';
     l_temp_rec.column_value := 'COST_GROUP';
     g_union_select(COST_GROUP) := l_temp_rec;

     l_temp_rec.column_name  := 'CG_ID';
     l_temp_rec.column_value := 'CG_ID';
     g_union_select(CG_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'LOADED';
     l_temp_rec.column_value := 'LOADED';
     g_union_select(LOADED) := l_temp_rec;

     l_temp_rec.column_name  := 'PLANNING_PARTY';
     l_temp_rec.column_value := 'PLANNING_PARTY';
     g_union_select(PLANNING_PARTY) := l_temp_rec;

     l_temp_rec.column_name  := 'PLANNING_PARTY_ID';
     l_temp_rec.column_value := 'PLANNING_PARTY_ID';
     g_union_select(PLANNING_PARTY_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'OWNING_PARTY';
     l_temp_rec.column_value := 'OWNING_PARTY';
     g_union_select(OWNING_PARTY) := l_temp_rec;

     l_temp_rec.column_name  := 'OWNING_PARTY_ID';
     l_temp_rec.column_value := 'OWNING_PARTY_ID';
     g_union_select(OWNING_PARTY_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'LOT';
     l_temp_rec.column_value := 'LOT';
     g_union_select(LOT) := l_temp_rec;


     l_temp_rec.column_name  := 'SERIAL';
     l_temp_rec.column_value := 'SERIAL';
     g_union_select(SERIAL) := l_temp_rec;

     l_temp_rec.column_name  := 'UNIT_NUMBER';
     l_temp_rec.column_value := 'UNIT_NUMBER';
     g_union_select(UNIT_NUMBER) := l_temp_rec;

     l_temp_rec.column_name  := 'LOT_EXPIRY_DATE';
     l_temp_rec.column_value := 'LOT_EXPIRY_DATE';
     g_union_select(LOT_EXPIRY_DATE) := l_temp_rec;

     l_temp_rec.column_name  := 'ORGANIZATION_CODE';
     l_temp_rec.column_value := 'ORGANIZATION_CODE';
     g_union_select(ORGANIZATION_CODE) := l_temp_rec;

     l_temp_rec.column_name  := 'ORG_ID';
     l_temp_rec.column_value := 'ORG_ID';
     g_union_select(ORG_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'ITEM';
     l_temp_rec.column_value := 'ITEM';
     g_union_select(ITEM) := l_temp_rec;

     l_temp_rec.column_name  := 'ITEM_DESCRIPTION';
     l_temp_rec.column_value := 'ITEM_DESCRIPTION';
     g_union_select(ITEM_DESCRIPTION) := l_temp_rec;

     l_temp_rec.column_name  := 'ITEM_ID';
     l_temp_rec.column_value := 'ITEM_ID';
     g_union_select(ITEM_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'REVISION';
     l_temp_rec.column_value := 'REVISION';
     g_union_select(REVISION) := l_temp_rec;

     l_temp_rec.column_name  := 'PRIMARY_UOM_CODE';
     l_temp_rec.column_value := 'PRIMARY_UOM_CODE';
     g_union_select(PRIMARY_UOM_CODE) := l_temp_rec;

     l_temp_rec.column_name  := 'ONHAND';
     l_temp_rec.column_value := 'SUM(ONHAND)';
     g_union_select(ONHAND) := l_temp_rec;

     l_temp_rec.column_name  := 'RECEIVING';
     l_temp_rec.column_value := 'SUM(RECEIVING)';
     g_union_select(RECEIVING) := l_temp_rec;

     l_temp_rec.column_name  := 'INBOUND';
     l_temp_rec.column_value := 'SUM(INBOUND)';
     g_union_select(INBOUND) := l_temp_rec;

     l_temp_rec.column_name  := 'UNPACKED';
     l_temp_rec.column_value := 'SUM(UNPACKED)';
     g_union_select(UNPACKED) := l_temp_rec;

     l_temp_rec.column_name  := 'PACKED';
     l_temp_rec.column_value := 'SUM(PACKED)';
     g_union_select(PACKED) := l_temp_rec;

     l_temp_rec.column_name  := 'SECONDARY_UOM_CODE';
     l_temp_rec.column_value := 'SECONDARY_UOM_CODE';
     g_union_select(SECONDARY_UOM_CODE) := l_temp_rec;

     l_temp_rec.column_name  := 'SECONDARY_ONHAND';
     l_temp_rec.column_value := 'SUM(SECONDARY_ONHAND)';
     g_union_select(SECONDARY_ONHAND) := l_temp_rec;

     l_temp_rec.column_name  := 'SECONDARY_RECEIVING';
     l_temp_rec.column_value := 'SUM(SECONDARY_RECEIVING)';
     g_union_select(SECONDARY_RECEIVING) := l_temp_rec;

     l_temp_rec.column_name  := 'SECONDARY_INBOUND';
     l_temp_rec.column_value := 'SUM(SECONDARY_INBOUND)';
     g_union_select(SECONDARY_INBOUND) := l_temp_rec;

     l_temp_rec.column_name  := 'OWNING_ORGANIZATION_ID';
     l_temp_rec.column_value := 'NULL';
     g_union_select(OWNING_ORGANIZATION_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'PLANNING_ORGANIZATION_ID';
     l_temp_rec.column_value := 'NULL';
     g_union_select(PLANNING_ORGANIZATION_ID) := l_temp_rec;

     l_temp_rec.column_name  := 'OWNING_TP_TYPE';
     l_temp_rec.column_value := 'NULL';
     g_union_select(OWNING_TP_TYPE) := l_temp_rec;

     l_temp_rec.column_name  := 'PLANNING_TP_TYPE';
     l_temp_rec.column_value := 'NULL';
     g_union_select(PLANNING_TP_TYPE) := l_temp_rec;

     -- Onhand Material Status support
     l_temp_rec.column_name  := 'STATUS';
     l_temp_rec.column_value := 'STATUS';
     g_union_select(STATUS) := l_temp_rec;

     l_temp_rec.column_name  := 'STATUS_ID';
     l_temp_rec.column_value := 'STATUS_ID';
     g_union_select(STATUS_ID) := l_temp_rec;
     -- End Onhand Material Status Support

     g_union_group(PO_RELEASE_ID) := 'PO_RELEASE_ID';
     g_union_group(RELEASE_LINE_NUMBER) := 'RELEASE_LINE_NUMBER';
     g_union_group(SHIPMENT_NUMBER) := 'SHIPMENT_NUMBER';
     g_union_group(SHIPMENT_HEADER_ID_INTERORG) := 'SHIPMENT_HEADER_ID_INTERORG';
     g_union_group(ASN) := 'ASN';
     g_union_group(SHIPMENT_HEADER_ID_ASN) := 'SHIPMENT_HEADER_ID_ASN';
     g_union_group(TRADING_PARTNER) := 'TRADING_PARTNER';
     g_union_group(VENDOR_ID) := 'VENDOR_ID';
     g_union_group(TRADING_PARTNER_SITE) := 'TRADING_PARTNER_SITE';
     g_union_group(VENDOR_SITE_ID) := 'VENDOR_SITE_ID';
     g_union_group(FROM_ORG) := 'FROM_ORG';
     g_union_group(FROM_ORG_ID) := 'FROM_ORG_ID';
     g_union_group(TO_ORG) := 'TO_ORG';
     g_union_group(TO_ORG_ID) := 'TO_ORG_ID';
     g_union_group(EXPECTED_RECEIPT_DATE) := 'EXPECTED_RECEIPT_DATE';
     g_union_group(SHIPPED_DATE) := 'SHIPPED_DATE';
     g_union_group(OWNING_ORG) := 'OWNING_ORG';
     g_union_group(OWNING_ORG_ID) := 'OWNING_ORG_ID';
     g_union_group(REQ_HEADER_ID) := 'REQ_HEADER_ID';
     g_union_group(OE_HEADER_ID) := 'OE_HEADER_ID';
     g_union_group(PO_HEADER_ID) := 'PO_HEADER_ID';
     g_union_group(MATURITY_DATE) := 'MATURITY_DATE';
     g_union_group(HOLD_DATE) := 'HOLD_DATE';
     g_union_group(SUPPLIER_LOT) := 'SUPPLIER_LOT';
     g_union_group(PARENT_LOT) := 'PARENT_LOT';
     g_union_group(DOCUMENT_TYPE) := 'DOCUMENT_TYPE';
     g_union_group(DOCUMENT_TYPE_ID) := 'DOCUMENT_TYPE_ID';
     g_union_group(DOCUMENT_NUMBER) := 'DOCUMENT_NUMBER';
     g_union_group(DOCUMENT_LINE_NUMBER) := 'DOCUMENT_LINE_NUMBER';
     g_union_group(RELEASE_NUMBER) := 'RELEASE_NUMBER';
     g_union_group(ORIGINATION_TYPE) := 'ORIGINATION_TYPE';
     g_union_group(ORIGINATION_DATE) := 'ORIGINATION_DATE';
     g_union_group(ACTION_CODE) := 'ACTION_CODE';
     g_union_group(ACTION_DATE) := 'ACTION_DATE';
     g_union_group(RETEST_DATE) := 'RETEST_DATE';
     g_union_group(SUBINVENTORY_CODE) := 'SUBINVENTORY_CODE';
     g_union_group(LOCATOR) := 'LOCATOR';
     g_union_group(LOCATOR_ID) := 'LOCATOR_ID';
     g_union_group(LPN) := 'LPN';
     g_union_group(LPN_ID) := 'LPN_ID';
     g_union_group(COST_GROUP) := 'COST_GROUP';
     g_union_group(CG_ID) := 'CG_ID';
     g_union_group(LOADED) := 'LOADED';
     g_union_group(PLANNING_PARTY) := 'PLANNING_PARTY';
     g_union_group(PLANNING_PARTY_ID) := 'PLANNING_PARTY_ID';
     g_union_group(OWNING_PARTY) := 'OWNING_PARTY';
     g_union_group(OWNING_PARTY_ID) := 'OWNING_PARTY_ID';
     g_union_group(LOT) := 'LOT';
     g_union_group(SERIAL) := 'SERIAL';
     g_union_group(UNIT_NUMBER) := 'UNIT_NUMBER';
     g_union_group(LOT_EXPIRY_DATE) := 'LOT_EXPIRY_DATE';
     g_union_group(ORGANIZATION_CODE) := 'ORGANIZATION_CODE';
     g_union_group(ORG_ID) := 'ORG_ID';
     g_union_group(ITEM) := 'ITEM';
     g_union_group(ITEM_DESCRIPTION) := 'ITEM_DESCRIPTION';
     g_union_group(ITEM_ID) := 'ITEM_ID';
     g_union_group(REVISION) := 'REVISION';
     g_union_group(PRIMARY_UOM_CODE) := 'PRIMARY_UOM_CODE';
     g_union_group(SECONDARY_UOM_CODE) := 'SECONDARY_UOM_CODE';
     g_union_group(OWNING_ORGANIZATION_ID) := 'OWNING_ORGANIZATION_ID';
     g_union_group(PLANNING_ORGANIZATION_ID) := 'PLANNING_ORGANIZATION_ID';
     g_union_group(OWNING_TP_TYPE) := 'OWNING_TP_TYPE';
     g_union_group(PLANNING_TP_TYPE) := 'PLANNING_TP_TYPE';

     -- Onhand Material Status support
     g_union_group(STATUS)    := 'STATUS';
     g_union_group(STATUS_ID) := 'STATUS_ID';


  END initialize_union_query;

   PROCEDURE make_nested_lpn_onhand_query IS
      l_procedure_name VARCHAR2(30);
      l_count          NUMBER;
   BEGIN
      l_procedure_name := 'MAKE_NESTED_LPN_QUERY';

      SELECT count(*)
        INTO l_count
        FROM wms_license_plate_numbers wlpn
       WHERE wlpn.parent_lpn_id = inv_mwb_globals.g_tree_parent_lpn_id
         AND wlpn.organization_id = inv_mwb_globals.g_tree_organization_id;

      IF l_count  > 0 THEN
         inv_mwb_globals.g_is_nested_lpn := 'YES';
      ELSE
         inv_mwb_globals.g_is_nested_lpn := 'NO';
         RETURN;
      END IF;

      add_from_clause('wms_license_plate_numbers wlpn', 'ONHAND_1');
      g_onhand_1_select(inv_mwb_query_manager.SUBINVENTORY_CODE).column_value :=
         'wlpn.subinventory_code';
      g_onhand_1_select(inv_mwb_query_manager.LOCATOR_ID).column_value :=
         'wlpn.locator_id';
      g_onhand_1_select(inv_mwb_query_manager.LPN).column_value :=
         'wlpn.license_plate_number';
      g_onhand_1_select(inv_mwb_query_manager.ORG_ID).column_value :=
         'wlpn.organization_id';

      add_group_clause('wlpn.organization_id', 'ONHAND_1');
      add_group_clause('wlpn.subinventory_code', 'ONHAND_1');
      add_group_clause('wlpn.locator_id', 'ONHAND_1');
      add_group_clause('wlpn.license_plate_number', 'ONHAND_1');

      add_where_clause('wlpn.parent_lpn_id = :onh_tree_plpn_id', 'ONHAND_1');
      add_bind_variable('onh_tree_plpn_id', inv_mwb_globals.g_tree_parent_lpn_id);

   END make_nested_lpn_onhand_query;

   PROCEDURE make_nested_lpn_rcv_query IS
      l_procedure_name VARCHAR2(30);
      l_count          NUMBER;
   BEGIN
      l_procedure_name := 'MAKE_NESTED_LPN_RCV_QUERY';

      SELECT count(*)
        INTO l_count
        FROM wms_license_plate_numbers wlpn
       WHERE wlpn.parent_lpn_id = inv_mwb_globals.g_tree_parent_lpn_id
         AND wlpn.organization_id = inv_mwb_globals.g_tree_organization_id;

      IF l_count  > 0 THEN
         inv_mwb_globals.g_is_nested_lpn := 'YES';
      ELSE
         inv_mwb_globals.g_is_nested_lpn := 'NO';
         RETURN;
      END IF;

      inv_mwb_query_manager.add_from_clause('wms_license_plate_numbers wlpn', 'RECEIVING_1');
      g_receiving_1_select(inv_mwb_query_manager.SUBINVENTORY_CODE).column_value :=
         'wlpn.subinventory_code';
      g_receiving_1_select(inv_mwb_query_manager.LOCATOR_ID).column_value :=
         'wlpn.locator_id';
      g_receiving_1_select(inv_mwb_query_manager.LPN).column_value :=
         'wlpn.license_plate_number';
      g_receiving_1_select(inv_mwb_query_manager.ORG_ID).column_value :=
         'wlpn.organization_id';

      add_group_clause('wlpn.organization_id', 'RECEIVING_1');
      add_group_clause('wlpn.subinventory_code', 'RECEIVING_1');
      add_group_clause('wlpn.locator_id', 'RECEIVING_1');
      add_group_clause('wlpn.license_plate_number', 'RECEIVING_1');

      add_where_clause('wlpn.parent_lpn_id = :onh_tree_plpn_id', 'RECEIVING_1');
      add_bind_variable('onh_tree_plpn_id', inv_mwb_globals.g_tree_parent_lpn_id);

   END make_nested_lpn_rcv_query;

   PROCEDURE make_nested_lpn_inbound_query IS
      l_procedure_name VARCHAR2(30);
      l_count          NUMBER;
   BEGIN
      l_procedure_name := 'MAKE_NESTED_LPN_INBOUND_QUERY';

      SELECT count(*)
        INTO l_count
        FROM wms_license_plate_numbers wlpn
       WHERE wlpn.parent_lpn_id = inv_mwb_globals.g_tree_parent_lpn_id
         AND wlpn.organization_id = inv_mwb_globals.g_tree_organization_id;

      IF l_count  > 0 THEN
         inv_mwb_globals.g_is_nested_lpn := 'YES';
      ELSE
         inv_mwb_globals.g_is_nested_lpn := 'NO';
         RETURN;
      END IF;

      add_from_clause('wms_license_plate_numbers wlpn', 'INBOUND_1');

      g_inbound_1_select(inv_mwb_query_manager.SUBINVENTORY_CODE).column_value :=
         'wlpn.subinventory_code';
      g_inbound_1_select(inv_mwb_query_manager.LOCATOR_ID).column_value :=
         'wlpn.locator_id';
      g_inbound_1_select(inv_mwb_query_manager.LPN).column_value :=
         'wlpn.license_plate_number';
      g_inbound_1_select(inv_mwb_query_manager.ORG_ID).column_value :=
         'wlpn.organization_id';

      add_group_clause('wlpn.organization_id', 'INBOUND_1');
      add_group_clause('wlpn.subinventory_code', 'INBOUND_1');
      add_group_clause('wlpn.locator_id', 'INBOUND_1');
      add_group_clause('wlpn.license_plate_number', 'INBOUND_1');

      add_where_clause('wlpn.parent_lpn_id = :onh_tree_plpn_id', 'INBOUND_1');
      add_bind_variable('onh_tree_plpn_id', inv_mwb_globals.g_tree_parent_lpn_id);

   END make_nested_lpn_inbound_query;

END INV_MWB_QUERY_MANAGER;

/
