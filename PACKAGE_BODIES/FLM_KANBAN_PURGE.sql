--------------------------------------------------------
--  DDL for Package Body FLM_KANBAN_PURGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FLM_KANBAN_PURGE" AS
/* $Header: FLMCPPKB.pls 115.6 2002/11/27 11:00:48 nrajpal noship $ */

/* The Package contains the following procedures
   Purge_Kanban_Cards - This is the procedure used to delete the
    Kanban Cards ('Cancelled Cards Only Or Cancelled and New/Active')
    based on the Delete Option selected by the user.

   Check_Restrictions - This procedure is used for the checking
    the validations for the pull sequences . The following are the
    restrictions before deletion
     - the pull sequence is not appearing on any BOM
     - if the sub/loc is NULL in BOM but the same is defined
       in the Master Items
     - if the sub/loc do not appear as point of supply in any other
       pull sequence.
     - If there are no cards against the pull sequence

       If all validations are passed through then delete the pull
       sequence else if only last the check failed them it is a
       unreferenced pull sequence.

    Purge_Kanban - This is the main procedure and is called from the
      report with the user parameters. This has a cursor to pick up
      the eligible information for the Purge from the main table
      MTL_KANBAN_PULL_SEQUENCES . The above mentioned procedures are
      called for every record in the curor.
     */

PROCEDURE PURGE_KANBAN_CARDS(
                    arg_pull_seq_id       in     number,
                    arg_org_id            in     number,
                    arg_item_id           in     number,
                    arg_subinv            in     varchar2,
                    arg_loc_id            in     number,
                    arg_delete_card       in     number,
                    arg_group_id          in     number,
                    retcode              out     NOCOPY	number,
                    errbuf               out     NOCOPY	varchar2
)
IS
l_record_count NUMBER := 0 ;
l_stmt_num     NUMBER := 0 ;
Begin

      l_stmt_num := 210;
      if (arg_delete_card = G_CANCELLED_CARDS_ONLY) then
           DELETE mtl_kanban_cards
            WHERE organization_id = arg_org_id
              AND pull_sequence_id = arg_pull_seq_id
              AND card_status = 3;

          l_record_count := SQL%ROWCOUNT;

          l_stmt_num := 220;

          if (l_record_count <> 0) then
          INSERT INTO flm_kanban_purge_temp
          (organization_id,
           item_id,
           subinventory_code,
           locator_id,
           count,
           type,
           group_id)
          VALUES
          (arg_org_id,
           arg_item_id,
           arg_subinv,
           arg_loc_id,
           l_record_count,
           G_KANBAN_CARD,
           arg_group_id);
           end if;
      elsif (arg_delete_card = G_CANCELLED_AND_NEW) then
           -- Delete both Cancelled and New/Active Cards .
           l_stmt_num := 230;
           DELETE mtl_kanban_cards
            WHERE organization_id = arg_org_id
              AND pull_sequence_id = arg_pull_seq_id
              AND (
                    (card_status = 3) OR
                    (card_status = 1) AND (supply_status = 1)
              );

           l_record_count := SQL%ROWCOUNT;

           l_stmt_num := 240;

           if (l_record_count <> 0) then
           INSERT INTO flm_kanban_purge_temp(
            organization_id,
            item_id,
            subinventory_code,
            locator_id,
            count,
            type,
            group_id)
           VALUES
           (arg_org_id,
            arg_item_id,
            arg_subinv,
            arg_loc_id,
            l_record_count,
            G_KANBAN_CARD,
            arg_group_id);
           end if;
       end if;

          retcode := G_SUCCESS;

EXCEPTION WHEN OTHERS THEN
          retcode := G_ERROR;
                  errbuf := substr(SQLERRM,1,500);
         MRP_UTIL.MRP_LOG('Error at '||l_stmt_num|| ' in Purge_Kanban_Card');

End Purge_Kanban_Cards;

PROCEDURE CHECK_RESTRICTIONS(
                    arg_pull_seq_id       in     number,
                    arg_org_id            in     number,
                    arg_item_id           in     number,
                    arg_subinv            in     varchar2,
                    arg_loc_id            in     number,
                    arg_group_id          in     number,
                    retcode              out     NOCOPY	number,
                    errbuf               out     NOCOPY	varchar2
)
IS
l_records_found NUMBER := G_ZERO;
l_stmt_num      NUMBER := G_ZERO;
l_flag          BOOLEAN := TRUE;
Begin

        l_stmt_num := 310;
        retcode := G_SUCCESS;

        SELECT count(*)
          INTO l_records_found
          FROM DUAL
         WHERE EXISTS (
             SELECT 1
               FROM BOM_INVENTORY_COMPONENTS BIC,
                    BOM_BILL_OF_MATERIALS BBM
              WHERE BIC.bill_sequence_id = BBM.bill_sequence_id
                AND BBM.organization_id = arg_org_id
                AND BIC.component_item_id = arg_item_id
                AND BIC.supply_subinventory = arg_subinv
                AND nvl(BIC.supply_locator_id,-1) = nvl(arg_loc_id,-1));

        if (l_records_found <> 0) then
            retcode := G_WARNING;
            return;
        end if;

        l_stmt_num := 320;

        SELECT count(*)
          INTO l_records_found
          FROM DUAL
         WHERE EXISTS (
             SELECT 1
               FROM BOM_INVENTORY_COMPONENTS BIC,
                    BOM_BILL_OF_MATERIALS BBM
              WHERE BIC.bill_sequence_id = BBM.bill_sequence_id
                AND BBM.organization_id = arg_org_id
                AND BIC.component_item_id = arg_item_id
                AND BIC.supply_subinventory IS NULL);

        if (l_records_found > 0) then
           SELECT COUNT(*)
           into l_records_found
           FROM DUAL
           WHERE EXISTS
              ( SELECT 1
                  FROM MTL_SYSTEM_ITEMS
                 WHERE organization_id = arg_org_id
                   AND inventory_item_id = arg_item_id
                   AND wip_supply_subinventory = arg_subinv
                   AND nvl(wip_supply_locator_id,-1) = nvl(arg_loc_id,-1));

          if (l_records_found <> 0) then
            retcode := G_WARNING;
            return;
          end if;
        end if;

        l_stmt_num := 330;

        SELECT COUNT(*)
        into l_records_found
        FROM DUAL
        WHERE EXISTS
              ( SELECT 1
                  FROM MTL_KANBAN_PULL_SEQUENCES
                 WHERE organization_id = arg_org_id
                   AND source_organization_id = organization_id
                   AND inventory_item_id = arg_item_id
                   AND source_subinventory = arg_subinv
                   AND nvl(source_locator_id,-1) = nvl(arg_loc_id,-1));


        if (l_records_found <> 0) then
            retcode := G_WARNING;
            return;
        end if;

        l_stmt_num := 340;

        SELECT COUNT(*)
        into l_records_found
        FROM DUAL
        WHERE EXISTS
              ( SELECT 1
                  FROM MTL_KANBAN_CARDS
                 WHERE organization_id = arg_org_id
                   AND pull_sequence_id = arg_pull_seq_id );

        if (l_records_found <> 0) then

        INSERT INTO flm_kanban_purge_temp
          (organization_id,
           item_id,
           subinventory_code,
           locator_id,
           count,
           type,
           group_id)
          VALUES
          (arg_org_id,
           arg_item_id,
           arg_subinv,
           arg_loc_id,
           1,
           G_EXCEPTION,
           arg_group_id);

           retcode := G_WARNING;
           return;
        end if;

        l_stmt_num := 350;

        DELETE MTL_KANBAN_PULL_SEQUENCES
         WHERE organization_id = arg_org_id
           AND inventory_item_id = arg_item_id
           AND subinventory_name = arg_subinv
           AND nvl(locator_id,-1) = nvl(arg_loc_id,-1) ;

        l_stmt_num := 360;

        INSERT INTO flm_kanban_purge_temp
          (organization_id,
           item_id,
           subinventory_code,
           locator_id,
           count,
           type,
           group_id)
          VALUES
          (arg_org_id,
           arg_item_id,
           arg_subinv,
           arg_loc_id,
           1,
           G_PULL_SEQUENCE,
           arg_group_id);

        l_stmt_num := 380;

        retcode := G_SUCCESS;

EXCEPTION WHEN OTHERS THEN
        retcode := G_ERROR;
        errbuf := substr(SQLERRM,1,500);
        MRP_UTIL.MRP_LOG('Error at '||l_stmt_num|| ' in Check_Restrictions');
End Check_Restrictions;

PROCEDURE PURGE_KANBAN (
                    errbuf               out     NOCOPY	varchar2,
                    retcode              out     NOCOPY	number,
                    arg_group_id          in     number,
                    arg_org_id            in     number,
                    arg_item_from         in     varchar2,
                    arg_item_to           in     varchar2,
                    arg_subinv_from       in     varchar2,
                    arg_subinv_to         in     varchar2,
                    arg_source_type       in     number,
                    arg_line_id           in     number,
                    arg_supplier_id       in     number,
                    arg_source_org_id     in     number,
                    arg_source_subinv     in     varchar2,
                    arg_delete_card       in     number
)
IS
      /* This cursor is executed for every record in the first cursor and
      will be used fetch any pull sequence chain in the correct order so
      that all the unreferenced pull sequences are deleted in a single loop*/
      CURSOR Cur_Kanban(source in number,item_id in number,in_subinv in varchar2) is
        Select pull_sequence_id,inventory_item_id,
               subinventory_name,locator_id
          from mtl_kanban_pull_sequences
         where organization_id  = arg_org_id
           and inventory_item_id = item_id
           and subinventory_name <= nvl(arg_subinv_from,subinventory_name)
           and subinventory_name >= nvl(arg_subinv_to,subinventory_name)
           and kanban_plan_id = -1
           and ( source IS NULL
            or (
               ((source_type = source)
                      and nvl(source_subinventory, -1) = nvl(arg_source_subinv, nvl(source_subinventory, -1) )  )
           and nvl(source_organization_id, -1) = nvl(arg_source_org_id, nvl(source_organization_id, -1)) )
            or ((source_type = source) and nvl(supplier_id,-1) = nvl(arg_supplier_id,nvl(supplier_id, -1) ) )
            or ((source_type = source) and
                      nvl(source_subinventory, -1) = nvl(arg_source_subinv, nvl(source_subinventory, -1))  )
            or ((source_type = source) and nvl(wip_line_id, -1) = nvl(arg_line_id, nvl(wip_line_id, -1))  ))
         start with subinventory_name = in_subinv and inventory_item_id = item_id and organization_id  = arg_org_id
         connect by prior source_subinventory = subinventory_name and inventory_item_id = item_id
         		and organization_id  = arg_org_id and nvl(prior source_locator_id, -1) = nvl(locator_id, -1);

l_sql_p             NUMBER         := G_ZERO;
l_sql_stmt          VARCHAR2(3000) := NULL;
l_stmt_num          NUMBER         := G_ZERO;
l_group_id          NUMBER         := G_ZERO;
l_records_processed NUMBER         := G_ZERO;
l_sql_rows          NUMBER         := G_ZERO;
l_where_item        VARCHAR2(1000) := NULL;
ld_pull_seq_id      NUMBER         := G_ZERO;
ld_item_id          NUMBER         := G_ZERO;
ld_subinv           VARCHAR2(10)   := NULL;
ld_loc_id           NUMBER         := G_ZERO;
Begin
       l_stmt_num := 100;
       l_group_id := arg_group_id;
       retcode := G_SUCCESS;


       MRP_UTIL.MRP_LOG('Org-id --> '||to_char(arg_org_id));
       MRP_UTIL.MRP_LOG('Item From --> '||arg_item_from);
       MRP_UTIL.MRP_LOG('Item To --> '||arg_item_to);
       MRP_UTIL.MRP_LOG('Sub From --> '||arg_subinv_from);
       MRP_UTIL.MRP_LOG('Sub To --> '||arg_subinv_to);
       MRP_UTIL.MRP_LOG('WIP Line --> '||to_char(arg_line_id));
       MRP_UTIL.MRP_LOG('Source Org --> '||to_char(arg_source_org_id));
       MRP_UTIL.MRP_LOG('Source Sub --> '||arg_source_subinv);
       MRP_UTIL.MRP_LOG('Source type --> '||to_char(arg_source_type));
       MRP_UTIL.MRP_LOG('Supplier-id --> '||to_char(arg_supplier_id));
       MRP_UTIL.MRP_LOG('Delete Card --> '||to_char(arg_delete_card));

       /* This is the first cursor which will pick up all those sequences
       which do not form a chain in the mtl_kanban_pull_sequences.
       (i.e) If there are 2 pull sequences which form a chain because the
       source-subinventory is the supply sub-inventory for the next then
       only the last in chain will be picked up in this cursor */

       l_sql_p := dbms_sql.open_cursor;
       l_sql_stmt :=
       'SELECT pull_sequence_id, inventory_item_id,'||
       'subinventory_name, locator_id'||
       ' FROM mtl_kanban_pull_sequences MKP1'||
       ' WHERE mkp1.organization_id = :org_id'||
       ' AND mkp1.subinventory_name >= nvl(:sub_from, subinventory_name)'||
       ' AND mkp1.subinventory_name <= nvl(:sub_to, subinventory_name)'||
       ' AND mkp1.kanban_plan_id = -1'||
       ' AND ( :source IS NULL'||
       ' OR ( ((mkp1.source_type = :source) AND (mkp1.source_type = 1) '||
       ' AND ( nvl(mkp1.source_subinventory, -1) = nvl(:source_subinv, nvl(mkp1.source_subinventory ,-1))  ) '||
       ' AND ( nvl(mkp1.source_organization_id, -1) = nvl(:source_org_id, nvl(mkp1.source_organization_id ,-1))   ))'||
       ' OR ((mkp1.source_type = :source) AND (mkp1.source_type = 2) and (nvl(mkp1.supplier_id,-1) = nvl(:supplier_id, nvl(mkp1.supplier_id, -1) )))'||
       ' OR ((mkp1.source_type = :source) AND (mkp1.source_type = 3) and (mkp1.source_subinventory = nvl(:source_subinv, mkp1.source_subinventory)  ))'||
       ' OR ((mkp1.source_type = :source) AND (mkp1.source_type = 4) and nvl(mkp1.wip_line_id, -1) = nvl(:line_id, nvl(mkp1.wip_line_id ,-1))  )))';

       if ((arg_item_from IS NOT NULL) or (arg_item_to IS NOT NULL)) then
          INVKBCGN.query_range_itm(arg_item_from, arg_item_to,l_where_item);
          l_sql_stmt := l_sql_stmt || ' AND ' ||
               ' inventory_item_id in '||
               ' (select inventory_item_id from mtl_system_items ' ||
               ' where ' || l_where_item || ' and organization_id = :org_id) ';
       end if;

       l_sql_stmt := l_sql_stmt || ' AND ' ||
         ' NOT EXISTS (' ||
         ' SELECT 1 FROM ' ||
         ' mtl_kanban_pull_sequences mkp2' ||
         ' where mkp2.inventory_item_id = mkp1.inventory_item_id '||
         '   and mkp2.source_subinventory = mkp1.subinventory_name '||
         '   and mkp2.source_organization_id = mkp2.organization_id '||
         '   and mkp2.subinventory_name >= nvl(:sub_from,mkp2.subinventory_name) '||
         '   and mkp2.subinventory_name <= nvl(:sub_to,mkp2.subinventory_name)   '||
         '   and nvl(mkp2.locator_id,-1) = nvl(mkp1.source_locator_id,-1)) '||
         '   ORDER by mkp1.inventory_item_id ';

       dbms_sql.parse( l_sql_p, l_sql_stmt, dbms_sql.native );

       dbms_sql.define_column(l_sql_p,1,ld_pull_seq_id);
       dbms_sql.define_column(l_sql_p,2,ld_item_id);
       dbms_sql.define_column(l_sql_p,3,ld_subinv,10 );
       dbms_sql.define_column(l_sql_p,4,ld_loc_id);

       dbms_sql.bind_variable(l_sql_p,'org_id', arg_org_id);
       dbms_sql.bind_variable(l_sql_p,'sub_from', arg_subinv_from);
       dbms_sql.bind_variable(l_sql_p,'sub_to', arg_subinv_to);
       dbms_sql.bind_variable(l_sql_p,'source', arg_source_type);
       dbms_sql.bind_variable(l_sql_p,'supplier_id', arg_supplier_id);
       dbms_sql.bind_variable(l_sql_p,'source_org_id', arg_source_org_id);
       dbms_sql.bind_variable(l_sql_p,'source_subinv', arg_source_subinv);
       dbms_sql.bind_variable(l_sql_p,'line_id', arg_line_id);

       l_sql_rows := dbms_sql.execute(l_sql_p);
       LOOP
        if ( dbms_sql.fetch_rows(l_sql_p) > 0 ) then
            dbms_sql.column_value(l_sql_p,1,ld_pull_seq_id);
            dbms_sql.column_value(l_sql_p,2,ld_item_id);
            dbms_sql.column_value(l_sql_p,3,ld_subinv);
            dbms_sql.column_value(l_sql_p,4,ld_loc_id);

            FOR Purge_Rec in Cur_Kanban(arg_source_type,ld_item_id,ld_subinv) LOOP

                    Purge_Kanban_Cards(purge_rec.pull_sequence_id,
                               arg_org_id,
                               purge_rec.inventory_item_id,
                               purge_rec.subinventory_name,
                               purge_rec.locator_id,
                               arg_delete_card,
                               l_group_id,
                               retcode,
                               errbuf);

                   if (retcode = G_ERROR) then
                      APP_EXCEPTION.RAISE_EXCEPTION;
                   end if;

                   l_stmt_num := 300;
                     Check_Restrictions(purge_rec.pull_sequence_id,
                              arg_org_id,
                              purge_rec.inventory_item_id,
                              purge_rec.subinventory_name,
                              purge_rec.locator_id,
                              l_group_id,
                              retcode,
                              errbuf);

                   if (retcode = G_ERROR) then
                      APP_EXCEPTION.RAISE_EXCEPTION;
                   else
                     l_records_processed := l_records_processed + 1;
                     if (l_records_processed = G_BATCH)  then
                        COMMIT;
                        l_records_processed := 0;
                     end if;
                   end if;
               END LOOP;

           else
           -- No more rows in the cursor
              dbms_sql.close_cursor(l_sql_p);
              EXIT;
        end if;
      END LOOP;

      if (retcode <> G_ERROR) and (l_records_processed > 0) then
        COMMIT;
      elsif (retcode = G_ERROR) then
        ROLLBACK;
      end if;

   EXCEPTION WHEN OTHERS THEN
      retcode := G_ERROR;
      if (errbuf = NULL) then
        errbuf := SUBSTR(SQLERRM, 1, 500);
      end if;
      dbms_sql.close_cursor(l_sql_p);
      ROLLBACK;
      MRP_UTIL.MRP_LOG('Error at '||l_stmt_num|| ' in Purge_Kanban_Card');
End Purge_Kanban;
END FLM_KANBAN_PURGE;

/
