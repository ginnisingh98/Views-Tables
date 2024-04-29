--------------------------------------------------------
--  DDL for Package Body INVPAGI2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INVPAGI2" as
/* $Header: INVPAG2B.pls 120.24.12010000.16 2010/09/08 04:55:00 ccsingh ship $*/
 /*Values used in IOI to indicate an attribute update to NULL. Added for bug
  * 6417006*/
    g_Upd_Null_CHAR     VARCHAR2(1)  :=  '!';
    g_Upd_Null_NUM      NUMBER       :=  -999999;
    g_Upd_Null_DATE     DATE         :=  NULL;

function assign_item_header_recs(
org_id          number,
all_org         NUMBER          := 2,
prog_appid      NUMBER          := -1,
prog_id         NUMBER          := -1,
request_id      NUMBER          := -1,
user_id         NUMBER          := -1,
login_id        NUMBER          := -1,
err_text in out NOCOPY varchar2,
xset_id   IN     NUMBER       DEFAULT -999,
default_flag IN  NUMBER    DEFAULT  1
) return integer is

   CURSOR header is
      select  inventory_item_id,
              organization_id,
              organization_code,
              item_number,
              item_catalog_group_id,
              copy_item_id,
              copy_item_number,
              copy_organization_id,
              copy_organization_code,
	      --serial_tagging enh -- bug 9913552
	      template_id,
              transaction_id,
              revision,
              cost_of_sales_account,
              encumbrance_account,
              sales_account,
              expense_account,
              segment1,
              segment2,
              segment3,
              segment4,
              segment5,
              segment6,
              segment7,
              segment8,
              segment9,
              segment10,
              segment11,
              segment12,
              segment13,
              segment14,
              segment15,
              segment16,
              segment17,
              segment18,
              segment19,
              segment20,
              set_process_id ,
              rowid,
         --Adding R12 C attribute changes
         style_item_flag,
         style_item_id,
         style_item_number,
         source_system_id,
         source_system_reference
        from MTL_SYSTEM_ITEMS_INTERFACE
        where process_flag = 1
        and set_process_id = xset_id
        and ((organization_id = org_id) or  (all_org = 1));

   --2861248 :Populate Item Id for default revision only

   ---Start: Bug fix 3051653
   CURSOR c_get_revisions(cp_item_number VARCHAR2,cp_revision VARCHAR2,
                          cp_organization_id NUMBER) IS
      SELECT organization_id,item_number
      FROM   mtl_item_revisions_interface
      WHERE  inventory_item_id IS     NULL
      AND    item_number       = cp_item_number
      AND    organization_id   = cp_organization_id
      AND    revision          = cp_revision
      AND    set_process_id    = xset_id
      AND    process_flag      = 1;

   CURSOR ee is
      select rowid ,transaction_id,inventory_item_id
      from mtl_system_items_interface child
      where inventory_item_id is not NULL
      and set_process_id = xset_id
      and process_flag = 1
      and not exists
                (select inventory_item_id
                 from mtl_system_items msi
                 where msi.inventory_item_id = child.inventory_item_id);

   /** Bug 5192495
       Need to select unit_of_measure column instead of unit_of_measure_tl*/
   --3818646 : PUOM from Profile is always in US.
   --Below cursor gets PUOM in session langauge.
   CURSOR c_get_uom (cp_unit_measure VARCHAR2) IS
      SELECT unit_of_measure
      FROM   mtl_units_of_measure_vl
      WHERE  uom_code IN (SELECT uom_code
                          FROM mtl_units_of_measure_tl
                          WHERE unit_of_measure =cp_unit_measure);

   CURSOR c_get_Style ( cp_style_item_number IN VARCHAR2
                       ,cp_organization_id IN NUMBER) IS
      SELECT inventory_item_id
        FROM mtl_system_items_b_kfv
       WHERE concatenated_segments = cp_style_item_number
         AND organization_id = cp_organization_id;

   CURSOR c_item_num_func (cp_catalog_group_id NUMBER)
   IS
      SELECT ITEM_NUM_GEN_METHOD
        FROM
        (
          SELECT  ICC.ITEM_NUM_GEN_METHOD
            FROM  MTL_ITEM_CATALOG_GROUPS_B ICC
           WHERE  ICC.ITEM_NUM_GEN_METHOD IS NOT NULL
             AND  ICC.ITEM_NUM_GEN_METHOD <> 'I'
          CONNECT BY PRIOR ICC.PARENT_CATALOG_GROUP_ID = ICC.ITEM_CATALOG_GROUP_ID
            START WITH ICC.ITEM_CATALOG_GROUP_ID = cp_catalog_group_id
          ORDER BY LEVEL ASC
        )
      WHERE ROWNUM = 1;

   TYPE transaction_type IS TABLE OF mtl_system_items_interface.transaction_id%TYPE
   INDEX BY BINARY_INTEGER;

   TYPE style_number_type IS TABLE OF mtl_system_items_interface.style_item_number%TYPE
   INDEX BY BINARY_INTEGER;

   TYPE org_type IS TABLE OF mtl_system_items_interface.organization_id%TYPE
   INDEX BY BINARY_INTEGER;

   TYPE catalog_type IS TABLE OF mtl_system_items_interface.item_catalog_group_id%TYPE
   INDEX BY BINARY_INTEGER;

   transaction_table transaction_type;
   style_item_num_table style_number_type;
   org_table org_type;
   catalog_table catalog_type;


   status_def_tmp         varchar2(30);
   status_default         varchar2(10);
   uom_default            varchar2(25);
   uom_default_tmp        varchar2(30);
   allow_item_desc_flag   varchar2(1);
   tax_flag               varchar2(1);
   req_required_flag      varchar2(1);
   receiving_flag         varchar2(1) := 'N';
   l_sysdate              date := sysdate;
   l_transaction_type     varchar2(10) := NULL ;
   l_old_organization_id  number := NULL;
   l_item_num_gen         VARCHAR2(1) := 'N';
   org_flag               number :=0;
   org_code               varchar2(3) := NULL;
   l_process_flag_1       number := 1;
   l_process_flag_3       number := 3;
   l_copy_item_id         number := NULL;
   l_copy_org_id          number := NULL;
   l_org_id               number;
   master_org_id          number;
   msiicount              number;
   revs                   number;
   default_rev            varchar2(3);
   rtn_status             number := 1;
   dumm_status            number;
   tran_id                number := 0;
   ASS_ITEM_ERR EXCEPTION;
   LOGGING_ERR  EXCEPTION;
   ERR_TYPE               varchar2(30);
   d_cost_of_sales_account      number;
   d_encumbrance_account        number;
   d_sales_account              number;
   d_expense_account      number;
   exists_id              number;
   seg1                   varchar2(40);
   seg2                   varchar2(40);
   seg3                   varchar2(40);
   error_msg              varchar2(70);
   validation_check_status number := 0;
   process_flag_temp       number := -999;
   op_unit                 number;

   /* Variables for the ff cursor in Dynamic SQL */
   DSQL_ff_transaction_id number;
   DSQL_ff_statement      varchar2(3000);
   DSQL_ff_c              integer; /*pointer to dynamic SQL cursor*/
   DSQL_ff_rows_processed integer;
   ff_statement_temp      varchar2(2000);
   ff_err_temp            varchar2(1000);
   dummy_ret_code         number;

   /* Variables for the second  Dynamic SQL statement*/
   DSQL_inventory_item_id number;
   DSQL_statement         varchar2(3000);
   DSQL_Statement_Msii    varchar2(3000);
   DSQL_c                 integer; /*pointer to dynamic SQL cursor*/
   DSQL_rows_processed    integer;
   statement_temp         varchar2(2000);
   err_temp               varchar2(1000);
   transaction_id_bind    integer;
   flex_id                NUMBER;
   l_effectivity_date     DATE;
   l_rowid                ROWID;

   l_curr_sysdate         DATE;   -- Bug 4539703 this will store sysdate- 1 sec
   ---Start: Bug fix 3051653
   l_item_number          mtl_system_items_interface.item_number%TYPE;
   l_item_id              mtl_system_items_interface.inventory_item_id%TYPE;
   l_Itemid_error         BOOLEAN := FALSE;

   l_org_name             HR_ALL_ORGANIZATION_UNITS_VL.name%TYPE;
   l_msg_text             fnd_new_messages.message_text%TYPE;

   l_inv_debug_level    NUMBER := INVPUTLI.get_debug_level;  --Bug: 4667452
   l_ret_status         VARCHAR2(1);
   l_msg_count          NUMBER;
   l_msg_data           VARCHAR2(100);
   l_style_item_id      NUMBER;
   l_item_num_gen_method VARCHAR2(1);
   l_item_desc_gen_method VARCHAR2(1);
   l_seq_exists NUMBER := 0;

   -- Fix for bug#9336604
   l_schema             VARCHAR2(30);
   l_status             VARCHAR2(1);
   l_industry           VARCHAR2(1);

   -- serial_tagging Enh -- bug 9913552
   x_ret_sts            VARCHAR2(1);
   --bug 10065810
   l_temp_org_id number;

BEGIN

   update mtl_system_items_interface
   set transaction_id = MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL
   where transaction_id is NULL
   and set_process_id = xset_id;

   --Get profile options for default assignment
   INVPROFL.inv_pr_get_profile('INV',
                                'INV_STATUS_DEFAULT',
                                user_id,
                                -1,
                                401,
                                status_def_tmp,
                                rtn_status,
                                err_text);
   status_default := substr(status_def_tmp,1,10);

   if rtn_status <> 0 and rtn_status <> -9999 then
      tran_id := 0;
      raise ASS_ITEM_ERR;
   else
      if rtn_status = -9999 then
         dumm_status := INVPUOPI.mtl_log_interface_err(
                                0,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                tran_id,
                                err_text,
                                'INV_STATUS_DEFAULT',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_NO_DEFAULT_STATUS',
                                err_text);
         if dumm_status < 0 then
            raise LOGGING_ERR;
         end if;
         rtn_status := 0;
      end if;
   end if;

   INVPROFL.inv_pr_get_profile('INV',
                                'INV_UOM_DEFAULT',
                                user_id,
                                fnd_global.RESP_APPL_ID, --application id
                                fnd_global.resp_id,--responsibility id
                                uom_default_tmp,
                                rtn_status,
                                err_text);
   uom_default := substr(uom_default_tmp,1,25);

   IF l_inv_debug_level IN(101, 102) THEN
      INVPUTLI.info('INVPAGI2: uom default is  '|| uom_default);
   END IF;


   if rtn_status <> 0 and
      rtn_status <> -9999 then
      tran_id := 0;
      raise ASS_ITEM_ERR;
   else
      if rtn_status = -9999 then
         dumm_status := INVPUOPI.mtl_log_interface_err(
                                0,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                tran_id,
                                err_text,
                                'INV_UOM_DEFAULT',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_NO_DEFAULT_UOM',
                                err_text);
         if dumm_status < 0 then
            raise LOGGING_ERR;
         end if;
         rtn_status := 0;
      end if;
   end if;

   --Start 3818646 : PUOM from Profile is always in US.
   OPEN  c_get_uom(uom_default);
   FETCH c_get_uom INTO uom_default;
   CLOSE c_get_uom;
   --End 3818646 : PUOM from Profile is always in US.

   for cr in ee loop
      --User can now populate inventory item id in the interface table.
      l_Itemid_error := FALSE;
      BEGIN
         SELECT MTL_SYSTEM_ITEMS_S.CURRVAL
         INTO l_item_id FROM DUAL;
         IF cr.inventory_item_id > l_item_id THEN
            l_Itemid_error := TRUE;
         END IF;
      EXCEPTION
         WHEN OTHERS THEN
                  --Start Bug 8259665
                        SELECT MTL_SYSTEM_ITEMS_S.NEXTVAL
            INTO l_item_id FROM DUAL;
                        IF cr.inventory_item_id > l_item_id THEN
                l_Itemid_error := TRUE;
                        END IF;
                        --End Bug 8259665
      END;

      IF l_Itemid_error THEN
         dumm_status := INVPUOPI.mtl_log_interface_err(
                                -1,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.transaction_id,
                                'INVPAGI2: Invalid Item ID',
                                'inventory_item_id',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_INVALID_INV_ITEM_ID',
                                err_text);
         if dumm_status < 0 then
            raise LOGGING_ERR;
         end if;

         update mtl_system_items_interface
         set process_flag = l_process_flag_3
         where rowid = cr.rowid ;

      END IF;
   end loop;

  -- Bug 5118572 Handle those items in ICC which have SEQ generated item numbers
  -- R12C changing the implementation of Sequence generation
  IF (INSTR(INV_EGO_REVISION_VALIDATE.Get_Process_Control,'PLM_UI:Y') = 0) THEN

     IF default_flag = 2 THEN --Sequence generated item nos only in pre-defaulting phase

       IF l_inv_debug_level IN(101, 102) THEN
        INVPUTLI.info('INVPAGI2: About to handle sequence generated item number case');
       END IF;

       SELECT DISTINCT item_catalog_group_id BULK COLLECT INTO catalog_table
         FROM mtl_system_items_interface
        WHERE process_flag = 1
          AND set_process_id = xset_id
          AND ((organization_id = org_id) or (all_org = 1))
          AND organization_id IN (SELECT master_organization_id  /*Bug 6158936*/
                                       FROM mtl_parameters)
          AND item_catalog_group_id IS NOT NULL ;

       IF catalog_table.COUNT > 0 THEN
         FOR I IN catalog_table.FIRST .. catalog_table.LAST LOOP
           EGO_IMPORT_PVT.Get_Item_Num_Desc_Gen_Method
                                     (p_item_catalog_group_id => catalog_table(i),
                                      x_item_num_gen_method => l_item_num_gen_method,
                                      x_item_desc_gen_method => l_item_desc_gen_method);
           IF l_item_num_gen_method = 'S' THEN
              UPDATE mtl_system_items_interface msii
                 SET msii.set_process_id = xset_id + 5000000000000
               WHERE msii.process_flag = 1
                 AND msii.set_process_id = xset_id
                 AND nvl(msii.style_item_flag, 'N') <> 'Y' --Bug 6182208
                 AND ((msii.organization_id = org_id) or  (all_org = 1))
                 AND msii.organization_id IN (SELECT master_organization_id /*Bug 6158936*/
                                                 FROM mtl_parameters)
                 AND (msii.item_catalog_group_id IS NOT NULL AND msii.item_catalog_group_id = catalog_table(i));

              IF l_inv_debug_level IN(101, 102) THEN
                 INVPUTLI.info('INVPAGI2: Identified rows for SEQ generation are:' || SQL%ROWCOUNT);
              END IF;

              l_seq_exists := 1;
           END IF;
         END LOOP;

         IF l_seq_exists = 1 THEN
            INV_EGO_REVISION_VALIDATE.Populate_Seq_Gen_Item_Nums ( p_set_id         => xset_id + 5000000000000
                                                                  ,p_org_id         => org_id
                                                                  ,p_all_org        => all_org
                                                                  ,p_rec_status     => 1
                                                                  ,x_return_status  => l_ret_status
                                                                  ,x_msg_count      => l_msg_count
                                                                  ,x_msg_data       => l_msg_data );
            IF l_ret_status <> FND_API.G_RET_STS_SUCCESS THEN
               dumm_status := INVPUOPI.mtl_log_interface_err(
                                         0,
                                        user_id,
                                           login_id,
                                           prog_appid,
                                           prog_id,
                                           request_id,
                                        tran_id,
                                           err_text,
                                           null,
                                          'MTL_SYSTEM_ITEMS_INTERFACE',
                                          'SEQUENCE GEN ITEM NUM ' || l_msg_data,
                                           err_text);
                    UPDATE mtl_system_items_interface
                       SET process_flag = 3
                          ,set_process_id = xset_id
               WHERE set_process_id = xset_id + 5000000000000;
                 ELSE
               UPDATE mtl_system_items_interface
                       SET set_process_id = xset_id
                     WHERE set_process_id = xset_id + 5000000000000;
                 END IF;
         END IF; --Sequence Generated ICC items exist
      END IF; -- Items with NOT NULL ICC exist in batch
      -- End of Bug 5118572
    END IF; --Seq gen Item Nos only in pre defaulting phase

    IF l_inv_debug_level IN(101, 102) THEN
      INVPUTLI.info('INVPAGI2: About to handle SKU items');
    END IF;

    /* Mark all SKU items with no style item to error */
    UPDATE mtl_system_items_interface msii
       SET msii.process_flag = 3
     WHERE msii.process_flag = 1
       AND msii.transaction_type = 'CREATE'
       AND msii.set_process_id = xset_id
       AND msii.organization_id = (SELECT mp.master_organization_id FROM mtl_parameters mp
                                    WHERE mp.organization_id = msii.organization_id )
       AND ( msii.style_item_flag = 'N' AND msii.style_item_id IS NULL AND msii.style_item_number IS NULL)
    RETURNING transaction_id BULK COLLECT INTO transaction_table;

    IF transaction_table.COUNT > 0 THEN
      FOR j IN transaction_table.FIRST .. transaction_table.LAST LOOP
         dumm_status := INVPUOPI.mtl_log_interface_err(
                                      org_id,
                                      user_id,
                                      login_id,
                                      prog_appid,
                                      prog_id,
                                      request_id,
                                      transaction_table(j),
                                      err_text,
                                                  'STYLE_ITEM_ID',
                                      'MTL_SYSTEM_ITEMS_INTERFACE',
                                      'INV_INVALID_STYLE_FOR_SKU' ,
                                      err_text);
      END LOOP;
    END IF;

    /* Resolve Style Item Numbers into Ids for SKU Items */
    SELECT msii.style_item_number,msii.organization_id,transaction_id
      BULK COLLECT INTO style_item_num_table, org_table, transaction_table
      FROM mtl_system_items_interface msii
     WHERE msii.process_flag = 1
       AND msii.transaction_type = 'CREATE'
       AND msii.set_process_id = xset_id
       AND msii.organization_id = (SELECT mp.master_organization_id FROM mtl_parameters mp
                                    WHERE mp.organization_id = msii.organization_id )
       AND ( msii.style_item_flag = 'N' AND msii.style_item_id IS NULL AND msii.style_item_number IS NOT NULL);

    IF style_item_num_table.COUNT > 0 THEN
      FOR I IN style_item_num_table.FIRST .. style_item_num_table.LAST LOOP
        OPEN  c_get_style ( cp_style_item_number => style_item_num_table(i)
                           ,cp_organization_id   => org_table(i));
        FETCH c_get_style INTO l_style_item_id;

        IF c_get_style%NOTFOUND THEN
           dumm_status := INVPUOPI.mtl_log_interface_err(
                                       0,
                                 user_id,
                                         login_id,
                                         prog_appid,
                                         prog_id,
                                         request_id,
                                  transaction_table(i),
                                         err_text,
                                         'STYLE_ITEM_NUMBER',
                                         'MTL_SYSTEM_ITEMS_INTERFACE',
                                         'INV_INVALID_STYLE_FOR_SKU',
                                         err_text);
            IF dumm_status < 0 then
               raise LOGGING_ERR;
            END IF;

            UPDATE mtl_system_items_interface msii
               SET process_flag = 3
             WHERE msii.process_flag = 1
               AND msii.transaction_type = 'CREATE'
               AND msii.set_process_id = xset_id
               AND msii.organization_id = (SELECT mp.master_organization_id FROM mtl_parameters mp
                                            WHERE mp.organization_id = msii.organization_id )
               AND msii.style_item_number = style_item_num_table(i);
        ELSE
            UPDATE mtl_system_items_interface msii
               SET msii.style_item_id = l_style_item_id
             WHERE msii.process_flag = 1
               AND msii.transaction_type = 'CREATE'
               AND msii.set_process_id = xset_id
               AND msii.organization_id = (SELECT mp.master_organization_id FROM mtl_parameters mp
                                            WHERE mp.organization_id = msii.organization_id )
               AND msii.style_item_number = style_item_num_table(i);
        END IF;
        CLOSE c_get_style;
      END LOOP;
    END IF;
   END IF;

   IF l_inv_debug_level IN(101, 102) THEN
      INVPUTLI.info('INVPAGI2: About to enter DSQL block');
   END IF;


   BEGIN /* PL-SQL Block for doing the dynamic SQL part*/

      ff_statement_temp := NULL;
      ff_err_temp := NULL;
      DSQL_ff_c := dbms_sql.open_cursor;
      dummy_ret_code := INVPUTLI.get_dynamic_sql_str(1, ff_statement_temp, ff_err_temp);

      /* Now append the sql statement to the generated dynamic sql where clause
      ** NP 02MAY96 Added xset_id and a i
      ** statement to BIND the set_id variable to DSQL_ff_c */

      --3701962: Changed to exists clause.
      DSQL_ff_statement := 'select msii.transaction_id
         from mtl_system_items_interface msii
         where msii.inventory_item_id is NULL
         and   msii.organization_id is not NULL
         and   msii.process_flag = 1
         and   msii.set_process_id = :set_id_bind
         and exists (select null
                 from mtl_system_items_b msi
                 where msii.organization_id = msi.organization_id and ' || ff_statement_temp || ')';

      dbms_sql.parse(DSQL_ff_c, DSQL_ff_statement, dbms_sql.native);
      dbms_sql.define_column(DSQL_ff_c,1,DSQL_ff_transaction_id);
      dbms_sql.bind_variable(DSQL_ff_c, 'set_id_bind', xset_id);

      DSQL_ff_rows_processed := dbms_sql.execute(DSQL_ff_c);

      IF l_inv_debug_level IN(101, 102) THEN
         INVPUTLI.info('INVPAGI2: About to enter DSQL loop');
      END IF;

      loop
         if dbms_sql.fetch_rows(DSQL_ff_c) > 0 then
            dbms_sql.column_value(DSQL_ff_c,1,DSQL_ff_transaction_id);
            dumm_status := INVPUOPI.mtl_log_interface_err(
                        -1,
                        user_id,
                        login_id,
                        prog_appid,
                        prog_id,
                        request_id,
                        DSQL_ff_transaction_id,
                        'INVPAGI2: Duplicate Org ID and segments in MSI',
                        'inventory_item_id',
                        'MTL_SYSTEM_ITEMS_INTERFACE',
                        'INV_DUPL_ORG_ITEM_SEG',
                        err_text);
            if dumm_status < 0 then
               raise LOGGING_ERR;
            end if;

            update mtl_system_items_interface
            set process_flag = l_process_flag_3
            where transaction_id = DSQL_ff_transaction_id
            and set_process_id = nvl(xset_id, set_process_id);
         else
            -- no more rows, Close cursor and exit
            dbms_sql.close_cursor(DSQL_ff_c);
            exit;
         end if;
      end loop;  -- loop over all rows

      if dbms_sql.is_open(DSQL_ff_c) then
         dbms_sql.close_cursor(DSQL_ff_c);
      end if;
      IF l_inv_debug_level IN(101, 102) THEN
         INVPUTLI.info('INVPAGI2:out of loop ');
      END IF;

   EXCEPTION
      when others then
         if dbms_sql.is_open(DSQL_ff_c) then
            dbms_sql.close_cursor(DSQL_ff_c);
         end if;
         err_text:= 'assign_item_header DSQL 1 '|| SQLERRM;
         dumm_status := INVPUOPI.mtl_log_interface_err(
                        l_org_id,
                        user_id,
                        login_id,
                        prog_appid,
                        prog_id,
                        request_id,
                        tran_id,
                        err_text,
                        null,
                        'MTL_SYSTEM_ITEMS_INTERFACE',
                        'DYN_SQL_ERROR',
                        err_text);

         return(SQLCODE);
   END; /* PL-SQL Block for doing the dynamic SQL part*/

   /* removed + 0 from where condition
   and clause of organization_id to fix bug 7459820 with base bug 7003119 */
   /*Bug 8808591 - Changing driving table according to Perf team suggestion*/
   DSQL_statement := 'select msi.inventory_item_id
                  from mtl_parameters mp,
                       mtl_system_items msi,
                       mtl_system_items_interface msii

                 where msii.transaction_id = :transaction_id_bind
                   and msii.set_process_id = :set_id_bind2
                   and rownum = 1
                   and msi.organization_id = mp.organization_id
                   and ' || ff_statement_temp;

   IF l_inv_debug_level IN(101, 102) THEN
      INVPUTLI.info('INVPAGI2: About to enter header cursorloop');
   END IF;


   update MTL_ITEM_REVISIONS_INTERFACE i
   set i.organization_id = (select o.organization_id
                            from MTL_PARAMETERS o
                            where o.organization_code = i.organization_code)
   where i.organization_id is NULL
   and   set_process_id  = xset_id
   and   i.process_flag  = l_process_flag_1;


   l_old_organization_id := -999 ;

   -- IOI Perf improvements..apply mass template.
   --Start : Performance enhancements
   IF (INSTR(INV_EGO_REVISION_VALIDATE.Get_Process_Control,'PLM_UI:Y') = 0) THEN
      dumm_status := INVPULI2.copy_template_attributes(
                           org_id
                          ,all_org
                          ,prog_appid
                          ,prog_id
                          ,request_id
                          ,user_id
                          ,login_id
                          ,xset_id
                          ,err_text);
      if dumm_status <> 0 then
         raise LOGGING_ERR;
      end if;
   END IF;
  --End : Performance enhancements

   FOR cr in header loop
      IF l_inv_debug_level IN(101, 102) THEN
         INVPUTLI.info('INVPAGI2: Set_id for current_row is '||cr.set_process_id);
      END IF;
      rtn_status  := 0;
      org_flag    := 0;
      tran_id     := cr.transaction_id;
      l_org_id    := cr.organization_id;
      validation_check_status :=  0;
      dumm_status := NULL;

      if cr.item_number is not NULL then
         rtn_status := INVPUOPI.mtl_pr_parse_item_number(
                                cr.item_number,
                                cr.inventory_item_id,
                                cr.transaction_id,
                                cr.organization_id,
                                err_text,
                                cr.rowid);
         if rtn_status < 0 then
            raise ASS_ITEM_ERR;
         end if;
      else
         IF cr.item_catalog_group_id IS NOT NULL THEN
            OPEN  c_item_num_func(cp_catalog_group_id => cr.item_catalog_group_id);
            FETCH c_item_num_func INTO l_item_num_gen;
            CLOSE c_item_num_func;
         ELSE
            l_item_num_gen := 'N';
         END IF;

         if (cr.inventory_item_id is NULL and
             cr.item_number is NULL and
             cr.segment1  is NULL and cr.segment2  is NULL and
             cr.segment3  is NULL and cr.segment4  is NULL and
             cr.segment5  is NULL and cr.segment6  is NULL and
             cr.segment7  is NULL and cr.segment8  is NULL and
             cr.segment9  is NULL and cr.segment10 is NULL and
             cr.segment11 is NULL and cr.segment12 is NULL and
             cr.segment13 is NULL and cr.segment14 is NULL and
             cr.segment15 is NULL and cr.segment16 is NULL and
             cr.segment17 is NULL and cr.segment18 is NULL and
             cr.segment19 is NULL and cr.segment20 is NULL and
             l_item_num_gen <> 'F') then
             dumm_status := INVPUOPI.mtl_log_interface_err(
                                         0,
                                         user_id,
                                         login_id,
                                         prog_appid,
                                         prog_id,
                                         request_id,
                                         tran_id,
                                         err_text,
                                         null,
                                         'MTL_SYSTEM_ITEMS_INTERFACE',
                                         'INV_SEG_ITM_NUMB_VAL',
                                         err_text);
             if dumm_status < 0 then
                raise LOGGING_ERR;
             end if;
             validation_check_status := -1;
          end if;
      end if;

              update mtl_system_items_interface
              --Bug: 2821206 Replaced ltrim with trim for segment1..20
                  set segment1 = trim(segment1),
                      segment2 = trim(segment2),
                      segment3 = trim(segment3),
                      segment4 = trim(segment4),
                      segment5 = trim(segment5),
                      segment6 = trim(segment6),
                      segment7 = trim(segment7),
                      segment8 = trim(segment8),
                      segment9 = trim(segment9),
                      segment10 = trim(segment10),
                      segment11 = trim(segment11),
                      segment12 = trim(segment12),
                      segment13 = trim(segment13),
                      segment14 = trim(segment14),
                      segment15 = trim(segment15),
                      segment16 = trim(segment16),
                      segment17 = trim(segment17),
                      segment18 = trim(segment18),
                      segment19 = trim(segment19),
                      segment20 = trim(segment20) ,
                      description = trim(description),
                      long_description = trim(long_description),
                      attribute_category = trim(attribute_category),
                      attribute1 = trim(attribute1),
                      attribute2 = trim(attribute2),
                      attribute3 = trim(attribute3),
                      attribute4 = trim(attribute4),
                      attribute5 = trim(attribute5),
                      attribute6 = trim(attribute6),
                      attribute7 = trim(attribute7),
                      attribute8 = trim(attribute8),
                      attribute9 = trim(attribute9),
                      attribute10 = trim(attribute10),
                      attribute11 = trim(attribute11),
                      attribute12 = trim(attribute12),
                      attribute13 = trim(attribute13),
                      attribute14 = trim(attribute14),
                      attribute15 = trim(attribute15),
                      /* Start Bug 3713912 */
                      attribute16= trim(attribute16),
                      attribute17= trim(attribute17),
                      attribute18= trim(attribute18),
                      attribute19= trim(attribute19),
                      attribute20= trim(attribute20),
                      attribute21= trim(attribute21),
                      attribute22= trim(attribute22),
                      attribute23= trim(attribute23),
                      attribute24= trim(attribute24),
                      attribute25= trim(attribute25),
                      attribute26= trim(attribute26),
                      attribute27= trim(attribute27),
                      attribute28= trim(attribute28),
                      attribute29= trim(attribute29),
                      attribute30= trim(attribute30),
                      cas_number = trim(cas_number),
                      child_lot_prefix= rtrim(child_lot_prefix),
                      /* End Bug 3713912 */
                      auto_lot_alpha_prefix = trim(auto_lot_alpha_prefix),  -- Rtrim changed to TRIM for bug-5896824
                      start_auto_lot_number = rtrim(start_auto_lot_number),
                      start_auto_serial_number =rtrim(start_auto_serial_number),
                      auto_serial_alpha_prefix =trim(auto_serial_alpha_prefix),  -- Rtrim changed to TRIM for bug-5896824
                      engineering_ecn_code = rtrim(engineering_ecn_code),
                      model_config_clause_name = trim(model_config_clause_name),
                      global_attribute_category = trim(global_attribute_category),
                      global_attribute1 = trim(global_attribute1),
                      global_attribute2 = trim(global_attribute2),
                      global_attribute3 = trim(global_attribute3),
                      global_attribute4 = trim(global_attribute4),
                      global_attribute5 = trim(global_attribute5),
                      global_attribute6 = trim(global_attribute6),
                      global_attribute7 = trim(global_attribute7),
                      global_attribute8 = trim(global_attribute8),
                      global_attribute9 = trim(global_attribute9),
                      global_attribute10 = trim(global_attribute10),
                  global_attribute11 = trim(global_attribute11),
                      global_attribute12 = trim(global_attribute12),
                      global_attribute13 = trim(global_attribute13),
                      global_attribute14 = trim(global_attribute14),
                      global_attribute15 = trim(global_attribute15),
                      global_attribute16 = trim(global_attribute16),
                      global_attribute17 = trim(global_attribute17),
                      global_attribute18 = trim(global_attribute18),
                      global_attribute19 = trim(global_attribute19),
                      global_attribute20 = trim(global_attribute20)
                where rowid = cr.rowid ;
        begin
                select organization_code
                into   org_code
                from mtl_parameters
                where organization_id = cr.organization_id;
        exception
                WHEN NO_DATA_FOUND then
                        org_flag := 1;
        end;


        /** Get some default values from PO_SYSTEM_PARAMETERS
        ** NP 13-MAY-95 New changes for intrastat
        ** This code moved into the cursor scope because it is now
        ** dependent on cr.organization_id value.
        ** Basic Assumption: Either each row of ood has a
        **        non null value for op_unit
        **        and each row of PSPA has a non_null value for org_id
        ** OR
        **       each row of ood has a null value for op_unit
        **       and there is ONLY one row in PSPA and that row has a null
        **       org_id
        **
        ** NP 26-JUL-95 Now defaulting values of
        **         allow_item_desc_flag,req_required_flag
        **         to Y and N instead of NULL.
        **/
      if org_flag <> 1 then

         If    l_old_organization_id <> cr.organization_id     then
         begin
             --Perf Issue : Replaced org_organizations_definitions view.
            select DECODE(ORG_INFORMATION_CONTEXT,
                          'Accounting Information',
                           TO_NUMBER(ORG_INFORMATION3),
                           TO_NUMBER(NULL)) operating_unit
            into   op_unit
            from   hr_organization_information
            where  organization_id = cr.organization_id
              and (org_information_context|| '') ='Accounting Information';

            begin
               select PSPA.ALLOW_ITEM_DESC_UPDATE_FLAG,
                      PSPA.RFQ_REQUIRED_FLAG,
                      PSPA.receiving_flag, PSPA.TAXABLE_FLAG
               into   allow_item_desc_flag,
                      req_required_flag,
                      receiving_flag,
                      tax_flag
               from PO_SYSTEM_PARAMETERS_ALL PSPA
               where  nvl(PSPA.org_id, -111) = nvl(op_unit, -111)
               and rownum = 1;
            exception
               WHEN NO_DATA_FOUND then
                  allow_item_desc_flag := 'Y';
                  req_required_flag := 'N';
                  receiving_flag   := 'N' ;
                  tax_flag        := 'N';
            end;
         exception
            WHEN NO_DATA_FOUND then
               BEGIN
                  SELECT name INTO l_org_name
                  FROM hr_all_organization_units_vl
                  WHERE organization_id = cr.organization_id;
               EXCEPTION
                  WHEN OTHERS THEN
                     l_org_name := cr.organization_id;
               END;
               FND_MESSAGE.SET_NAME ('INV', 'INV_NO_OP_UNIT_FOR_ORG');
               FND_MESSAGE.SET_TOKEN ('ORGANIZATION', l_org_name);
               l_msg_text := FND_MESSAGE.GET;
               err_text := 'No Operating Unit Found for the Organization';
               dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                tran_id,
                                l_msg_text,
                                'ORGANIZATION_ID',
                                'ORG_ORGANIZATION_DEFINITIONS',
                                'INV_IOI_ERR',
                                err_text);
               if dumm_status < 0 then
                  raise LOGGING_ERR;
               end if;
            WHEN OTHERS then
               raise_application_error(-20001, SQLERRM);
         end;
         End If ;

         /* Assign item_id based on segment values using the following two cases
         **        1) if record exists with identical segments, use it's item_id
         **        2) if NO record exists with identical segments, use sequence
         */
         if cr.inventory_item_id is null then
            BEGIN
               IF l_inv_debug_level IN(101, 102) THEN
                  INVPUTLI.info('INVPAGI2: About to process DSQL 2 ');
                    END IF;
               DSQL_c := dbms_sql.open_cursor;
               dbms_sql.parse(DSQL_c, DSQL_statement, dbms_sql.native);
               dbms_sql.define_column(DSQL_c,1,DSQL_inventory_item_id);
               dbms_sql.bind_variable(DSQL_c, 'transaction_id_bind', cr.transaction_id);
               dbms_sql.bind_variable(DSQL_c, 'set_id_bind2', xset_id);
               DSQL_rows_processed := dbms_sql.execute(DSQL_c);

            --There is no loop over all rows; there is actually only ONE row here..
            if dbms_sql.fetch_rows(DSQL_c) > 0 then
               dbms_sql.column_value(DSQL_c,1,DSQL_inventory_item_id);
               exists_id := DSQL_inventory_item_id;

               update MTL_SYSTEM_ITEMS_INTERFACE
               set inventory_item_id = exists_id
               where rowid  = cr.rowid ;

               cr.inventory_item_id := exists_id;
                /* fix for bug 8510589 */
               if dbms_sql.is_open(DSQL_c) then
                  dbms_sql.close_cursor(DSQL_c);
               end if;

            else
               --Adding resolution of Item Id from Master in same batch (from Intf table)
               IF l_inv_debug_level IN(101, 102) THEN
                  INVPUTLI.info('INVPAGI2: About to process DSQL 3 ');
                    END IF;
               -- Fix for bug#9336604
               DSQL_Statement_Msii := 'SELECT /*+ index(msii MTL_SYSTEM_ITEMS_INTERFACE_N6) index(msi MTL_SYSTEM_ITEMS_INTERFACE_N4) */ msi.inventory_item_id
                                        FROM mtl_system_items_interface msi, mtl_system_items_interface msii
                                       WHERE msi.set_process_id = msii.set_process_id
                                          AND msi.organization_id =
                                             (SELECT mp.master_organization_id FROM mtl_parameters mp
                                               WHERE mp.organization_id = msii.organization_id)
                                          AND msii.set_process_id = :set_id_bind2
                                          AND msii.transaction_id = :transaction_id_bind
                                          AND rownum = 1
                                          AND ' ||ff_statement_temp ;

                    if dbms_sql.is_open(DSQL_c) then
                  dbms_sql.close_cursor(DSQL_c);
               end if;

               DSQL_c := dbms_sql.open_cursor;
               dbms_sql.parse(DSQL_c, DSQL_Statement_Msii, dbms_sql.native);
               dbms_sql.define_column(DSQL_c,1,DSQL_inventory_item_id);
               dbms_sql.bind_variable(DSQL_c, 'set_id_bind2', xset_id);
               dbms_sql.bind_variable(DSQL_c, 'transaction_id_bind', cr.transaction_id);
               DSQL_rows_processed := dbms_sql.execute(DSQL_c);

               --There is no loop over all rows; there is actually only ONE row here..
               if dbms_sql.fetch_rows(DSQL_c) > 0 then
                  dbms_sql.column_value(DSQL_c,1,DSQL_inventory_item_id);
                  exists_id := DSQL_inventory_item_id;
               end if;

               if exists_id IS NOT NULL then

                  update MTL_SYSTEM_ITEMS_INTERFACE
                     set inventory_item_id = exists_id
                   where rowid  = cr.rowid ;

                  cr.inventory_item_id := exists_id;
               else
                  -- No such row found. Close the cursor after
                  -- Assigning missing inventory_item_id from sequence

                    IF l_inv_debug_level IN(101, 102) THEN
                       INVPUTLI.info('INVPAGI2: No match in MSI; Creating Inventory Item Id from sequence');
                  END IF;

                  /*update MTL_SYSTEM_ITEMS_INTERFACE
                     set inventory_item_id = MTL_SYSTEM_ITEMS_S.nextval
                   where rowid = cr.rowid
                       returning inventory_item_id INTO cr.inventory_item_id;*/ /*Changed for bug 8808591*/

                  update MTL_SYSTEM_ITEMS_INTERFACE
                     set inventory_item_id = MTL_SYSTEM_ITEMS_S.nextval
                   where rowid = cr.rowid;

                   select  MTL_SYSTEM_ITEMS_S.CURRVAL INTO cr.inventory_item_id FROM DUAL;

                       dbms_sql.close_cursor(DSQL_c);
              end if; -- Row not in MSI and MSII

                    if dbms_sql.is_open(DSQL_c) then
                  dbms_sql.close_cursor(DSQL_c);
               end if;
            end if; --Row not in MSI
            EXCEPTION
               when others then
                  if dbms_sql.is_open(DSQL_c) then
                     dbms_sql.close_cursor(DSQL_c);
                  end if;
                  err_text:= 'assign_item_header DSQL 2 '|| SQLERRM;
                  dumm_status := INVPUOPI.mtl_log_interface_err(
                        l_org_id,
                        user_id,
                        login_id,
                        prog_appid,
                        prog_id,
                        request_id,
                        tran_id,
                        err_text,
                        null,
                        'MTL_SYSTEM_ITEMS_INTERFACE',
                        'DYN_SQL_ERROR',
                        err_text);

                  return(SQLCODE);
            END; /* PLSQL Block for doing the second dynamic SQL*/
         end if;  /*  cr.inventory_item_id is null */

         --  determine if item is in master org.
         IF l_inv_debug_level IN(101, 102) THEN
                 INVPUTLI.info('INVPAGI2: Determining whether the item is in master org');
         END IF;
         if  l_old_organization_id  <>    cr.organization_id then
            select mp.master_organization_id ,
                   mp.starting_revision ,
                   cost_of_sales_account,
                   encumbrance_account,
                   sales_account,
                   expense_account
            into   master_org_id ,
                   default_rev ,
                        d_cost_of_sales_account,
                   d_encumbrance_account,
                   d_sales_account,
                   d_expense_account
            from  mtl_parameters mp
            where mp.organization_id = cr.organization_id;
         End if ;

         if (cr.revision is null) then
            cr.revision := default_rev;
         end if;
         IF l_inv_debug_level IN(101, 102) THEN
            INVPUTLI.info('cr.rev is ' || cr.revision);
              END IF;
         msiicount := 0;

         select count(*) into msiicount
         from mtl_system_items msii
         where cr.inventory_item_id = msii.inventory_item_id
         and   msii.organization_id = master_org_id;
         IF l_inv_debug_level IN(101, 102) THEN
            INVPUTLI.info('Processing itemid '|| cr.inventory_item_id );
            INVPUTLI.info('with Org id '|| cr.organization_id );
            INVPUTLI.info('with segment1 '|| cr.segment1 );
              END IF;
         --assign master_org attribute defaults if in child org AND parent exists

         if ((master_org_id <> cr.organization_id) and (msiicount = 1)) then
            if rtn_status = 0 then
            IF INVPOPIF.g_source_org   /*Added for bug 6372595*/
             THEN
               IF l_inv_debug_level IN(101, 102) THEN
                  INVPUTLI.info('INVPAGI2: calling assign_master_defaults with set_id '||xset_id);
                    END IF;
               rtn_status := INVPUTLI.assign_master_defaults(
                                      cr.transaction_id,
                                      cr.inventory_item_id,
                                      cr.organization_id,
                                      master_org_id,
                                      status_default,
                                      uom_default,
                                      allow_item_desc_flag,
                                      req_required_flag,
                                      err_text,
                                      xset_id ,
                                      cr.rowid);
               if rtn_status < 0  then
                  raise ASS_ITEM_ERR;
                 end if;
                 END IF;  /*Added for bug 6372595*/
              end if;
         else
            if ((master_org_id <> cr.organization_id) and (msiicount = 0)) then
                    if rtn_status = 0 then
                  IF l_inv_debug_level IN(101, 102) THEN
                          INVPUTLI.info('INVPAGI2: Orphan found; about to call error ');
                          INVPUTLI.info('INVPAGI2: Orphan found; checking in msii ');
                  END IF;

                  select count(*) into msiicount
                    from mtl_system_items_interface
                   where inventory_item_id = cr.inventory_item_id
                     and organization_id = master_org_id
                     and set_process_id = xset_id
                     and process_flag in (1,60000+1); /*masters are moved to 60000+ to before calling child create*/

                       if msiicount = 0 then
                     error_msg  := 'Orphan detected. This item has no parent in MSI';
                    validation_check_status :=  -1;
                          dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                tran_id,
                                error_msg,
                                'ORGANIZATION_ID',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_IOI_ORPHAN_CHILD',
                                err_text);
                       if dumm_status < 0 then
                             raise LOGGING_ERR;
                          end if;
                     IF l_inv_debug_level IN(101, 102) THEN
                          INVPUTLI.info('INVPAGI2: Orphan found; error called '|| rtn_status);
                            END IF;
                  else
                     rtn_status := INVPUTLI.predefault_child_master(
                                                     cr.inventory_item_id,
                                 cr.organization_id,
                                 master_org_id,
                                 err_text,
                                 xset_id ,
                                 cr.rowid);
                     if rtn_status < 0  then
                        raise ASS_ITEM_ERR;
                       end if;
                  end if;
                    end if; /*rtn_status = 0*/
            else
                if rtn_status = 0 then
                  IF l_inv_debug_level IN(101, 102) THEN
                        INVPUTLI.info('INVPAGI2: In the new-item-in-master case ');
                     INVPUTLI.info('INVPAGI2: Calling assign_item_defaults with set_id '|| xset_id);
                          END IF;

                  rtn_status := INVPUTLI.assign_item_defaults(
                                                    cr.inventory_item_id,
                                cr.organization_id,
                                status_default,
                                uom_default,
                                allow_item_desc_flag,
                                req_required_flag,
                                tax_flag,
                                err_text,
                                xset_id ,
                                cr.rowid,
                                receiving_flag );
                     if rtn_status < 0  then
                        raise ASS_ITEM_ERR;
                     end if;
                   end if; /*rtn_status = 0*/
            end if;
         end if;

         update MTL_SYSTEM_ITEMS_INTERFACE
         set cost_of_sales_account =   nvl(cost_of_sales_account,d_cost_of_sales_account),
             encumbrance_account   =   nvl(encumbrance_account,d_encumbrance_account),
            sales_account =           nvl(sales_account,d_sales_account),
            expense_account =         nvl(expense_account,d_expense_account)
         where rowid  = cr.rowid ;

        /*Bug 6417006 - Converting '!' to NULL and -999999 to NULL. This done to
         * ensure NULL attribute values while applying
         *    Template with enabled attribute values as NULL. This is for the 'CREATE'
         *    mode of the IOI*/
        UPDATE MTL_SYSTEM_ITEMS_INTERFACE MSII
           SET
	    -- Serial_Tagging Eng -- bug 9913552
	    copy_item_id              = Decode (copy_item_id, g_upd_null_NUM, NULL,
	copy_item_id),
            DESCRIPTION               =  DECODE( DESCRIPTION, g_Upd_Null_CHAR, NULL,
        trim(DESCRIPTION )),
            LONG_DESCRIPTION          =  DECODE( LONG_DESCRIPTION, g_Upd_Null_CHAR, NULL,
        trim(LONG_DESCRIPTION)),
             BUYER_ID                 =        decode(BUYER_ID, g_Upd_Null_NUM, NULL,
        BUYER_ID),
           ACCOUNTING_RULE_ID         =        decode(ACCOUNTING_RULE_ID,g_Upd_Null_NUM,
        NULL, ACCOUNTING_RULE_ID),
            INVOICING_RULE_ID         =        decode(INVOICING_RULE_ID,g_Upd_Null_NUM,
        NULL, INVOICING_RULE_ID),
           ATTRIBUTE_CATEGORY         =        decode(ATTRIBUTE_CATEGORY,
        g_Upd_Null_CHAR, NULL, trim(ATTRIBUTE_CATEGORY)),
           ATTRIBUTE1                 =        decode(ATTRIBUTE1,  g_Upd_Null_CHAR,
        NULL, trim(ATTRIBUTE1)),
           ATTRIBUTE2                 =        decode(ATTRIBUTE2,  g_Upd_Null_CHAR,
        NULL, trim(ATTRIBUTE2)),
           ATTRIBUTE3                 =        decode(ATTRIBUTE3,  g_Upd_Null_CHAR,
        NULL, trim(ATTRIBUTE3)),
           ATTRIBUTE4                 =        decode(ATTRIBUTE4,  g_Upd_Null_CHAR,
        NULL, trim(ATTRIBUTE4)),
           ATTRIBUTE5                 =        decode(ATTRIBUTE5,  g_Upd_Null_CHAR,
        NULL, trim(ATTRIBUTE5)),
           ATTRIBUTE6                 =        decode(ATTRIBUTE6,  g_Upd_Null_CHAR,
        NULL, trim(ATTRIBUTE6)),
           ATTRIBUTE7                 =        decode(ATTRIBUTE7,  g_Upd_Null_CHAR,
        NULL, trim(ATTRIBUTE7)),
           ATTRIBUTE8                 =        decode(ATTRIBUTE8,  g_Upd_Null_CHAR,
        NULL, trim(ATTRIBUTE8)),
           ATTRIBUTE9                 =        decode(ATTRIBUTE9,  g_Upd_Null_CHAR,
        NULL, trim(ATTRIBUTE9)),
           ATTRIBUTE10                 =        decode(ATTRIBUTE10,  g_Upd_Null_CHAR,
        NULL, trim(ATTRIBUTE10)),
           ATTRIBUTE11                =        decode(ATTRIBUTE11,  g_Upd_Null_CHAR,
        NULL, trim(ATTRIBUTE11)),
           ATTRIBUTE12                =        decode(ATTRIBUTE12,  g_Upd_Null_CHAR,
        NULL, trim(ATTRIBUTE12)),
           ATTRIBUTE13                =        decode(ATTRIBUTE13,  g_Upd_Null_CHAR,
        NULL, trim(ATTRIBUTE13)),
           ATTRIBUTE14                =        decode(ATTRIBUTE14,  g_Upd_Null_CHAR,
        NULL, trim(ATTRIBUTE14)),
           ATTRIBUTE15                =        decode(ATTRIBUTE15,  g_Upd_Null_CHAR,
        NULL, trim(ATTRIBUTE15)),
           GLOBAL_ATTRIBUTE_CATEGORY          =
        decode(GLOBAL_ATTRIBUTE_CATEGORY,  g_Upd_Null_CHAR, NULL,
        trim(GLOBAL_ATTRIBUTE_CATEGORY)),
           GLOBAL_ATTRIBUTE1          =         decode(GLOBAL_ATTRIBUTE1,
        g_Upd_Null_CHAR, NULL, trim(GLOBAL_ATTRIBUTE1)),
           GLOBAL_ATTRIBUTE2          =         decode(GLOBAL_ATTRIBUTE2,
        g_Upd_Null_CHAR, NULL, trim(GLOBAL_ATTRIBUTE2)),
           GLOBAL_ATTRIBUTE3          =         decode(GLOBAL_ATTRIBUTE3,
        g_Upd_Null_CHAR, NULL, trim(GLOBAL_ATTRIBUTE3)),
           GLOBAL_ATTRIBUTE4         =         decode(GLOBAL_ATTRIBUTE4,
        g_Upd_Null_CHAR, NULL, trim(GLOBAL_ATTRIBUTE4)),
           GLOBAL_ATTRIBUTE5          =         decode(GLOBAL_ATTRIBUTE5,
        g_Upd_Null_CHAR, NULL, trim(GLOBAL_ATTRIBUTE5)),
           GLOBAL_ATTRIBUTE6          =         decode(GLOBAL_ATTRIBUTE6,
        g_Upd_Null_CHAR, NULL, trim(GLOBAL_ATTRIBUTE6)),
           GLOBAL_ATTRIBUTE7          =         decode(GLOBAL_ATTRIBUTE7,
        g_Upd_Null_CHAR, NULL, trim(GLOBAL_ATTRIBUTE7)),
           GLOBAL_ATTRIBUTE8          =         decode(GLOBAL_ATTRIBUTE8,
        g_Upd_Null_CHAR, NULL, trim(GLOBAL_ATTRIBUTE8)),
           GLOBAL_ATTRIBUTE9          =         decode(GLOBAL_ATTRIBUTE9,
        g_Upd_Null_CHAR, NULL, trim(GLOBAL_ATTRIBUTE9)),
           GLOBAL_ATTRIBUTE10          =         decode(GLOBAL_ATTRIBUTE10,
        g_Upd_Null_CHAR, NULL, trim(GLOBAL_ATTRIBUTE10)),

           GLOBAL_ATTRIBUTE11          =         decode(GLOBAL_ATTRIBUTE11,
        g_Upd_Null_CHAR, NULL, trim(GLOBAL_ATTRIBUTE11)),
           GLOBAL_ATTRIBUTE12          =         decode(GLOBAL_ATTRIBUTE12,
        g_Upd_Null_CHAR, NULL, trim(GLOBAL_ATTRIBUTE12)),
           GLOBAL_ATTRIBUTE13          =         decode(GLOBAL_ATTRIBUTE13,
        g_Upd_Null_CHAR, NULL, trim(GLOBAL_ATTRIBUTE13)),
           GLOBAL_ATTRIBUTE14         =         decode(GLOBAL_ATTRIBUTE14,
        g_Upd_Null_CHAR, NULL, trim(GLOBAL_ATTRIBUTE14)),
           GLOBAL_ATTRIBUTE15          =         decode(GLOBAL_ATTRIBUTE15,
        g_Upd_Null_CHAR, NULL, trim(GLOBAL_ATTRIBUTE15)),
           GLOBAL_ATTRIBUTE16          =         decode(GLOBAL_ATTRIBUTE16,
        g_Upd_Null_CHAR, NULL, trim(GLOBAL_ATTRIBUTE16)),
           GLOBAL_ATTRIBUTE17          =         decode(GLOBAL_ATTRIBUTE17,
        g_Upd_Null_CHAR, NULL, trim(GLOBAL_ATTRIBUTE17)),
           GLOBAL_ATTRIBUTE18          =         decode(GLOBAL_ATTRIBUTE18,
        g_Upd_Null_CHAR, NULL, trim(GLOBAL_ATTRIBUTE18)),
           GLOBAL_ATTRIBUTE19          =         decode(GLOBAL_ATTRIBUTE19,
        g_Upd_Null_CHAR, NULL, trim(GLOBAL_ATTRIBUTE19)),
           GLOBAL_ATTRIBUTE20          =         decode(GLOBAL_ATTRIBUTE20,
        g_Upd_Null_CHAR, NULL, trim(GLOBAL_ATTRIBUTE20)),

           ITEM_CATALOG_GROUP_ID                 =        decode(ITEM_CATALOG_GROUP_ID,
        g_Upd_Null_NUM, NULL, ITEM_CATALOG_GROUP_ID),
           CATALOG_STATUS_FLAG            =       DECODE(CATALOG_STATUS_FLAG,
        g_Upd_Null_CHAR, NULL, trim(CATALOG_STATUS_FLAG)),
           DEFAULT_SHIPPING_ORG                 =        decode(DEFAULT_SHIPPING_ORG,
        g_Upd_Null_NUM, NULL, DEFAULT_SHIPPING_ORG),
           TAXABLE_FLAG                         =        decode(TAXABLE_FLAG,
        g_Upd_Null_CHAR, NULL, trim(TAXABLE_FLAG)),
           PURCHASING_TAX_CODE        =
        decode(PURCHASING_TAX_CODE,g_Upd_Null_CHAR,NULL,trim(PURCHASING_TAX_CODE)),
           QTY_RCV_EXCEPTION_CODE         =        decode(QTY_RCV_EXCEPTION_CODE,
        g_Upd_Null_CHAR, NULL, trim(QTY_RCV_EXCEPTION_CODE)),
           INSPECTION_REQUIRED_FLAG         =        decode(INSPECTION_REQUIRED_FLAG,
        g_Upd_Null_CHAR, NULL, trim(INSPECTION_REQUIRED_FLAG)),
           RECEIPT_REQUIRED_FLAG          =       decode(RECEIPT_REQUIRED_FLAG,
        g_Upd_Null_CHAR, NULL, trim(RECEIPT_REQUIRED_FLAG)),
           MARKET_PRICE                         =        decode(MARKET_PRICE,
        g_Upd_Null_NUM, NULL, MARKET_PRICE),
           HAZARD_CLASS_ID                 =        decode(HAZARD_CLASS_ID,
        g_Upd_Null_NUM, NULL, HAZARD_CLASS_ID),
           QTY_RCV_TOLERANCE                 =        decode(QTY_RCV_TOLERANCE,
        g_Upd_Null_NUM, NULL, QTY_RCV_TOLERANCE),
           LIST_PRICE_PER_UNIT                 =        decode(LIST_PRICE_PER_UNIT,
        g_Upd_Null_NUM, NULL, LIST_PRICE_PER_UNIT),
           UN_NUMBER_ID                         =        decode(UN_NUMBER_ID,
        g_Upd_Null_NUM, NULL, UN_NUMBER_ID),
           PRICE_TOLERANCE_PERCENT         =        decode(PRICE_TOLERANCE_PERCENT,
        g_Upd_Null_NUM, NULL, PRICE_TOLERANCE_PERCENT),
           ASSET_CATEGORY_ID                 =        decode(ASSET_CATEGORY_ID,
        g_Upd_Null_NUM, NULL, ASSET_CATEGORY_ID),
           ROUNDING_FACTOR                 =        decode(ROUNDING_FACTOR,
        g_Upd_Null_NUM, NULL, ROUNDING_FACTOR),
           UNIT_OF_ISSUE                         =        decode(UNIT_OF_ISSUE,
        g_Upd_Null_CHAR, NULL, trim(UNIT_OF_ISSUE)),
           ENFORCE_SHIP_TO_LOCATION_CODE         =
        decode(ENFORCE_SHIP_TO_LOCATION_CODE,  g_Upd_Null_CHAR, NULL,
        trim(ENFORCE_SHIP_TO_LOCATION_CODE)),
           ALLOW_SUBSTITUTE_RECEIPTS_FLAG        =
        decode(ALLOW_SUBSTITUTE_RECEIPTS_FLAG,  g_Upd_Null_CHAR, NULL,
        trim(ALLOW_SUBSTITUTE_RECEIPTS_FLAG)),
           ALLOW_UNORDERED_RECEIPTS_FLAG         =
        decode(ALLOW_UNORDERED_RECEIPTS_FLAG,  g_Upd_Null_CHAR, NULL,
        trim(ALLOW_UNORDERED_RECEIPTS_FLAG)),
           ALLOW_EXPRESS_DELIVERY_FLAG         =
        decode(ALLOW_EXPRESS_DELIVERY_FLAG,  g_Upd_Null_CHAR, NULL,
        trim(ALLOW_EXPRESS_DELIVERY_FLAG)),
           DAYS_EARLY_RECEIPT_ALLOWED         =
        decode(DAYS_EARLY_RECEIPT_ALLOWED,  g_Upd_Null_NUM, NULL,
        DAYS_EARLY_RECEIPT_ALLOWED),
           DAYS_LATE_RECEIPT_ALLOWED         =        decode(DAYS_LATE_RECEIPT_ALLOWED,
        g_Upd_Null_NUM, NULL, DAYS_LATE_RECEIPT_ALLOWED),
           RECEIPT_DAYS_EXCEPTION_CODE         =
        decode(RECEIPT_DAYS_EXCEPTION_CODE,  g_Upd_Null_CHAR, NULL,
        trim(RECEIPT_DAYS_EXCEPTION_CODE)),
           RECEIVING_ROUTING_ID                 =        decode(RECEIVING_ROUTING_ID,
        g_Upd_Null_NUM, NULL, RECEIVING_ROUTING_ID),
           INVOICE_CLOSE_TOLERANCE         =        decode(INVOICE_CLOSE_TOLERANCE,
        g_Upd_Null_NUM, NULL, INVOICE_CLOSE_TOLERANCE),
           RECEIVE_CLOSE_TOLERANCE         =        decode(RECEIVE_CLOSE_TOLERANCE,
        g_Upd_Null_NUM, NULL, RECEIVE_CLOSE_TOLERANCE),
           AUTO_LOT_ALPHA_PREFIX                 =        decode(AUTO_LOT_ALPHA_PREFIX,
        g_Upd_Null_CHAR, NULL, trim(AUTO_LOT_ALPHA_PREFIX)),
           START_AUTO_LOT_NUMBER                 =        decode(START_AUTO_LOT_NUMBER,
        g_Upd_Null_CHAR, NULL, trim(START_AUTO_LOT_NUMBER)),
           SHELF_LIFE_DAYS                 =        decode(SHELF_LIFE_DAYS,
        g_Upd_Null_NUM, NULL, SHELF_LIFE_DAYS),
           START_AUTO_SERIAL_NUMBER         =        decode(START_AUTO_SERIAL_NUMBER,
        g_Upd_Null_CHAR, NULL, trim(START_AUTO_SERIAL_NUMBER)),
           AUTO_SERIAL_ALPHA_PREFIX         =        decode(AUTO_SERIAL_ALPHA_PREFIX,
        g_Upd_Null_CHAR, NULL, trim(AUTO_SERIAL_ALPHA_PREFIX)),
           SOURCE_TYPE                         =        decode(SOURCE_TYPE,
        g_Upd_Null_NUM, NULL, SOURCE_TYPE),
           SOURCE_ORGANIZATION_ID         =        decode(SOURCE_ORGANIZATION_ID,
        g_Upd_Null_NUM, NULL, SOURCE_ORGANIZATION_ID),
           SOURCE_SUBINVENTORY                 =        decode(SOURCE_SUBINVENTORY,
        g_Upd_Null_CHAR, NULL, trim(SOURCE_SUBINVENTORY)),
           EXPENSE_ACCOUNT                 =        decode(EXPENSE_ACCOUNT,
        g_Upd_Null_NUM, NULL, EXPENSE_ACCOUNT),
           ENCUMBRANCE_ACCOUNT                 =        decode(ENCUMBRANCE_ACCOUNT,
        g_Upd_Null_NUM, NULL, ENCUMBRANCE_ACCOUNT),
           UNIT_WEIGHT                         =        decode(UNIT_WEIGHT,
        g_Upd_Null_NUM, NULL, UNIT_WEIGHT),
           WEIGHT_UOM_CODE                 =        decode(WEIGHT_UOM_CODE,
        g_Upd_Null_CHAR, NULL, trim(WEIGHT_UOM_CODE)),
           VOLUME_UOM_CODE                 =        decode(VOLUME_UOM_CODE,
        g_Upd_Null_CHAR, NULL, trim(VOLUME_UOM_CODE)),
           UNIT_VOLUME                         =        decode(UNIT_VOLUME,
        g_Upd_Null_NUM, NULL, UNIT_VOLUME),
           SHRINKAGE_RATE                 =        decode(SHRINKAGE_RATE,
        g_Upd_Null_NUM, NULL, SHRINKAGE_RATE),
           ACCEPTABLE_EARLY_DAYS                 =        decode(ACCEPTABLE_EARLY_DAYS,
        g_Upd_Null_NUM, NULL, ACCEPTABLE_EARLY_DAYS),
           DEMAND_TIME_FENCE_CODE         =        decode(DEMAND_TIME_FENCE_CODE,
        g_Upd_Null_NUM, NULL, DEMAND_TIME_FENCE_CODE),
           STD_LOT_SIZE                         =        decode(STD_LOT_SIZE,
        g_Upd_Null_NUM, NULL, STD_LOT_SIZE),
           LEAD_TIME_LOT_SIZE                 =        decode(LEAD_TIME_LOT_SIZE,
        g_Upd_Null_NUM, NULL, LEAD_TIME_LOT_SIZE),
           CUM_MANUFACTURING_LEAD_TIME         =
        decode(CUM_MANUFACTURING_LEAD_TIME, g_Upd_Null_NUM, NULL,
        CUM_MANUFACTURING_LEAD_TIME),
           OVERRUN_PERCENTAGE                 =        decode(OVERRUN_PERCENTAGE,
        g_Upd_Null_NUM, NULL, OVERRUN_PERCENTAGE),
           ACCEPTABLE_RATE_INCREASE         =        decode(ACCEPTABLE_RATE_INCREASE,
        g_Upd_Null_NUM, NULL, ACCEPTABLE_RATE_INCREASE),
           ACCEPTABLE_RATE_DECREASE         =        decode(ACCEPTABLE_RATE_DECREASE,
        g_Upd_Null_NUM, NULL, ACCEPTABLE_RATE_DECREASE),
           CUMULATIVE_TOTAL_LEAD_TIME         =
        decode(CUMULATIVE_TOTAL_LEAD_TIME,  g_Upd_Null_NUM, NULL,
        CUMULATIVE_TOTAL_LEAD_TIME),
           PLANNING_TIME_FENCE_DAYS         =        decode(PLANNING_TIME_FENCE_DAYS,
        g_Upd_Null_NUM, NULL, PLANNING_TIME_FENCE_DAYS),
           DEMAND_TIME_FENCE_DAYS         =        decode(DEMAND_TIME_FENCE_DAYS,
        g_Upd_Null_NUM, NULL, DEMAND_TIME_FENCE_DAYS),
           RELEASE_TIME_FENCE_CODE  =  decode(RELEASE_TIME_FENCE_CODE, g_Upd_Null_NUM,
        NULL, RELEASE_TIME_FENCE_CODE),
           RELEASE_TIME_FENCE_DAYS  =  decode(RELEASE_TIME_FENCE_DAYS,g_Upd_Null_NUM,
        NULL, RELEASE_TIME_FENCE_DAYS),
           END_ASSEMBLY_PEGGING_FLAG         =        decode(END_ASSEMBLY_PEGGING_FLAG,
        g_Upd_Null_CHAR, NULL, trim(END_ASSEMBLY_PEGGING_FLAG)),
           PLANNING_EXCEPTION_SET         =        decode(PLANNING_EXCEPTION_SET,
        g_Upd_Null_CHAR, NULL, trim(PLANNING_EXCEPTION_SET)),
           BASE_ITEM_ID                         =        decode(BASE_ITEM_ID,
        g_Upd_Null_NUM, NULL, BASE_ITEM_ID),
           FIXED_LEAD_TIME                 =        decode(FIXED_LEAD_TIME,
        g_Upd_Null_NUM, NULL, FIXED_LEAD_TIME),
           VARIABLE_LEAD_TIME                 =        decode(VARIABLE_LEAD_TIME,
        g_Upd_Null_NUM, NULL, VARIABLE_LEAD_TIME),
           WIP_SUPPLY_LOCATOR_ID                 =        decode(WIP_SUPPLY_LOCATOR_ID,
        g_Upd_Null_NUM, NULL, WIP_SUPPLY_LOCATOR_ID),
           WIP_SUPPLY_TYPE                 =        decode(WIP_SUPPLY_TYPE,
        g_Upd_Null_NUM, 1, WIP_SUPPLY_TYPE),  -- Syalaman - Fix for bug 5886000
           WIP_SUPPLY_SUBINVENTORY         =        decode(WIP_SUPPLY_SUBINVENTORY,
        g_Upd_Null_CHAR, NULL, trim(WIP_SUPPLY_SUBINVENTORY)),
           PLANNER_CODE                         =        decode(PLANNER_CODE,
        g_Upd_Null_CHAR, NULL, trim(PLANNER_CODE)),
           FIXED_LOT_MULTIPLIER                 =        decode(FIXED_LOT_MULTIPLIER,
        g_Upd_Null_NUM, NULL, FIXED_LOT_MULTIPLIER),
           CARRYING_COST                         =        decode(CARRYING_COST,
        g_Upd_Null_NUM, NULL, CARRYING_COST),
           POSTPROCESSING_LEAD_TIME         =
        decode(POSTPROCESSING_LEAD_TIME,  g_Upd_Null_NUM,NULL,
        POSTPROCESSING_LEAD_TIME),
           PREPROCESSING_LEAD_TIME         =        decode(PREPROCESSING_LEAD_TIME,
        g_Upd_Null_NUM, NULL, PREPROCESSING_LEAD_TIME),
           FULL_LEAD_TIME                 =        decode(FULL_LEAD_TIME,
        g_Upd_Null_NUM, NULL, FULL_LEAD_TIME),
           ORDER_COST                         =        decode(ORDER_COST,
        g_Upd_Null_NUM, NULL, ORDER_COST),
           MRP_SAFETY_STOCK_PERCENT         =        decode(MRP_SAFETY_STOCK_PERCENT,
        g_Upd_Null_NUM, NULL, MRP_SAFETY_STOCK_PERCENT),
           MIN_MINMAX_QUANTITY                 =        decode(MIN_MINMAX_QUANTITY,
        g_Upd_Null_NUM, NULL, MIN_MINMAX_QUANTITY),
           MAX_MINMAX_QUANTITY                 =        decode(MAX_MINMAX_QUANTITY,
        g_Upd_Null_NUM, NULL, MAX_MINMAX_QUANTITY),
           MINIMUM_ORDER_QUANTITY         =        decode(MINIMUM_ORDER_QUANTITY,
        g_Upd_Null_NUM, NULL, MINIMUM_ORDER_QUANTITY),
           FIXED_ORDER_QUANTITY                 =        decode(FIXED_ORDER_QUANTITY,
        g_Upd_Null_NUM, NULL, FIXED_ORDER_QUANTITY),
           FIXED_DAYS_SUPPLY                 =        decode(FIXED_DAYS_SUPPLY,
        g_Upd_Null_NUM, NULL, FIXED_DAYS_SUPPLY),
           MAXIMUM_ORDER_QUANTITY         =        decode(MAXIMUM_ORDER_QUANTITY,
        g_Upd_Null_NUM, NULL, MAXIMUM_ORDER_QUANTITY),
           ATP_RULE_ID                         =        decode(ATP_RULE_ID,
        g_Upd_Null_NUM, NULL, ATP_RULE_ID),
           PICKING_RULE_ID                 =        decode(PICKING_RULE_ID,
        g_Upd_Null_NUM, NULL, PICKING_RULE_ID),
           POSITIVE_MEASUREMENT_ERROR         =
        decode(POSITIVE_MEASUREMENT_ERROR, g_Upd_Null_NUM, NULL,
        POSITIVE_MEASUREMENT_ERROR),
           NEGATIVE_MEASUREMENT_ERROR         =
        decode(NEGATIVE_MEASUREMENT_ERROR, g_Upd_Null_NUM, NULL,
        NEGATIVE_MEASUREMENT_ERROR),
           SERVICE_STARTING_DELAY         =        decode(SERVICE_STARTING_DELAY,
        g_Upd_Null_NUM, NULL, SERVICE_STARTING_DELAY),
           PAYMENT_TERMS_ID                 =        decode(PAYMENT_TERMS_ID,
        g_Upd_Null_NUM, NULL, PAYMENT_TERMS_ID),
           MATERIAL_BILLABLE_FLAG         =
        decode(MATERIAL_BILLABLE_FLAG,g_Upd_Null_CHAR,NULL,trim(MATERIAL_BILLABLE_FLAG)),
           COVERAGE_SCHEDULE_ID                 =        decode(COVERAGE_SCHEDULE_ID,
        g_Upd_Null_NUM, NULL, COVERAGE_SCHEDULE_ID),
           SERVICE_DURATION_PERIOD_CODE         =
        decode(SERVICE_DURATION_PERIOD_CODE, g_Upd_Null_CHAR, NULL,
        trim(SERVICE_DURATION_PERIOD_CODE)),
           SERVICE_DURATION                 =        decode(SERVICE_DURATION,
        g_Upd_Null_NUM, NULL, SERVICE_DURATION),
           TAX_CODE                         =        decode(TAX_CODE, g_Upd_Null_CHAR,
        NULL, trim(TAX_CODE)),
           OUTSIDE_OPERATION_UOM_TYPE         =
        decode(OUTSIDE_OPERATION_UOM_TYPE,g_Upd_Null_CHAR,NULL,trim(OUTSIDE_OPERATION_UOM_TYPE)),
           SAFETY_STOCK_BUCKET_DAYS         =        decode(SAFETY_STOCK_BUCKET_DAYS,
        g_Upd_Null_NUM, NULL, SAFETY_STOCK_BUCKET_DAYS),
           AUTO_REDUCE_MPS                 =        decode(AUTO_REDUCE_MPS,
        g_Upd_Null_NUM, NULL, trim(AUTO_REDUCE_MPS)),
           ITEM_TYPE                         =        decode(ITEM_TYPE, g_Upd_Null_CHAR,
        NULL, trim(ITEM_TYPE)),
           ATO_FORECAST_CONTROL                 =        decode(ATO_FORECAST_CONTROL,
        g_Upd_Null_NUM, NULL, ATO_FORECAST_CONTROL),
           MAXIMUM_LOAD_WEIGHT                 =        decode(MAXIMUM_LOAD_WEIGHT,
        g_Upd_Null_NUM, NULL, MAXIMUM_LOAD_WEIGHT),
           MINIMUM_FILL_PERCENT                 =
        decode(MINIMUM_FILL_PERCENT,g_Upd_Null_NUM, NULL, MINIMUM_FILL_PERCENT),
           CONTAINER_TYPE_CODE                 =        decode(CONTAINER_TYPE_CODE,
        g_Upd_Null_CHAR, NULL, trim(CONTAINER_TYPE_CODE)),
           INTERNAL_VOLUME                 =        decode(INTERNAL_VOLUME,
        g_Upd_Null_NUM, NULL, INTERNAL_VOLUME),
           OVERCOMPLETION_TOLERANCE_TYPE     =  DECODE( OVERCOMPLETION_TOLERANCE_TYPE,
        g_Upd_Null_NUM, NULL, OVERCOMPLETION_TOLERANCE_TYPE ),
           OVERCOMPLETION_TOLERANCE_VALUE    =  DECODE( OVERCOMPLETION_TOLERANCE_VALUE,
        g_Upd_Null_NUM, NULL, OVERCOMPLETION_TOLERANCE_VALUE ),
           OVER_SHIPMENT_TOLERANCE           =  DECODE( OVER_SHIPMENT_TOLERANCE,
        g_Upd_Null_NUM, NULL, OVER_SHIPMENT_TOLERANCE ),
           UNDER_SHIPMENT_TOLERANCE          =  DECODE(
        UNDER_SHIPMENT_TOLERANCE,g_Upd_Null_NUM, NULL, UNDER_SHIPMENT_TOLERANCE ),
           OVER_RETURN_TOLERANCE             =  DECODE( OVER_RETURN_TOLERANCE,
        g_Upd_Null_NUM, NULL, OVER_RETURN_TOLERANCE ),
           UNDER_RETURN_TOLERANCE            =  DECODE( UNDER_RETURN_TOLERANCE,
        g_Upd_Null_NUM, NULL, UNDER_RETURN_TOLERANCE ),
           RECOVERED_PART_DISP_CODE          =  DECODE( RECOVERED_PART_DISP_CODE,
        g_Upd_Null_CHAR, NULL, trim(RECOVERED_PART_DISP_CODE) ),
           ASSET_CREATION_CODE               =  DECODE( ASSET_CREATION_CODE,
        g_Upd_Null_CHAR, NULL,  trim(ASSET_CREATION_CODE) ),
           DIMENSION_UOM_CODE                =  DECODE( DIMENSION_UOM_CODE,
        g_Upd_Null_CHAR, NULL,  trim(DIMENSION_UOM_CODE) ),
           UNIT_LENGTH                       =  DECODE( UNIT_LENGTH, g_Upd_Null_NUM,
        NULL, UNIT_LENGTH ),
           UNIT_WIDTH                        =  DECODE( UNIT_WIDTH, g_Upd_Null_NUM,
        NULL, UNIT_WIDTH ),
           UNIT_HEIGHT                       =  DECODE( UNIT_HEIGHT, g_Upd_Null_NUM,
        NULL, UNIT_HEIGHT ),
           DEFAULT_LOT_STATUS_ID             =  DECODE( DEFAULT_LOT_STATUS_ID,
        g_Upd_Null_NUM, NULL, DEFAULT_LOT_STATUS_ID ),
           DEFAULT_SERIAL_STATUS_ID          =  DECODE( DEFAULT_SERIAL_STATUS_ID,
        g_Upd_Null_NUM, NULL, DEFAULT_SERIAL_STATUS_ID ),
           INVENTORY_CARRY_PENALTY           =  DECODE( INVENTORY_CARRY_PENALTY,
        g_Upd_Null_NUM, NULL, INVENTORY_CARRY_PENALTY ),
           OPERATION_SLACK_PENALTY           =  DECODE( OPERATION_SLACK_PENALTY,
        g_Upd_Null_NUM, NULL, OPERATION_SLACK_PENALTY ),
           EAM_ITEM_TYPE             =  DECODE( EAM_ITEM_TYPE, g_Upd_Null_NUM, NULL,
        EAM_ITEM_TYPE ),
           EAM_ACTIVITY_TYPE_CODE    =  DECODE( EAM_ACTIVITY_TYPE_CODE, g_Upd_Null_CHAR,
        NULL,  trim(EAM_ACTIVITY_TYPE_CODE) ),
           EAM_ACTIVITY_CAUSE_CODE   =  DECODE( EAM_ACTIVITY_CAUSE_CODE,
        g_Upd_Null_CHAR, NULL,  trim(EAM_ACTIVITY_CAUSE_CODE) ),
           EAM_ACT_NOTIFICATION_FLAG =  DECODE( EAM_ACT_NOTIFICATION_FLAG,
        g_Upd_Null_CHAR, NULL,  trim(EAM_ACT_NOTIFICATION_FLAG) ),
           EAM_ACT_SHUTDOWN_STATUS   =  DECODE( EAM_ACT_SHUTDOWN_STATUS,
        g_Upd_Null_CHAR, NULL,  trim(EAM_ACT_SHUTDOWN_STATUS) ),
           SECONDARY_UOM_CODE        =  DECODE( SECONDARY_UOM_CODE, g_Upd_Null_CHAR,
        NULL,  trim(SECONDARY_UOM_CODE) ),
           DUAL_UOM_DEVIATION_HIGH   =  DECODE( DUAL_UOM_DEVIATION_HIGH, g_Upd_Null_NUM,
        NULL, DUAL_UOM_DEVIATION_HIGH ),
           DUAL_UOM_DEVIATION_LOW    =  DECODE( DUAL_UOM_DEVIATION_LOW, g_Upd_Null_NUM,
        NULL, DUAL_UOM_DEVIATION_LOW ),
           CONTRACT_ITEM_TYPE_CODE   =  DECODE( CONTRACT_ITEM_TYPE_CODE,
        g_Upd_Null_CHAR, NULL,  trim(CONTRACT_ITEM_TYPE_CODE) ),
           SUBSCRIPTION_DEPEND_FLAG  =  DECODE( SUBSCRIPTION_DEPEND_FLAG,
        g_Upd_Null_CHAR, NULL,  trim(SUBSCRIPTION_DEPEND_FLAG) ),
           SERV_REQ_ENABLED_CODE     =  DECODE( SERV_REQ_ENABLED_CODE, g_Upd_Null_CHAR,
        NULL,  trim(SERV_REQ_ENABLED_CODE) ),
           SERV_BILLING_ENABLED_FLAG =  DECODE( SERV_BILLING_ENABLED_FLAG,
        g_Upd_Null_CHAR, NULL,  trim(SERV_BILLING_ENABLED_FLAG) ),
           SERV_IMPORTANCE_LEVEL     =  DECODE( SERV_IMPORTANCE_LEVEL, g_Upd_Null_NUM,
        NULL, SERV_IMPORTANCE_LEVEL ),
           PLANNED_INV_POINT_FLAG    =  DECODE( PLANNED_INV_POINT_FLAG, g_Upd_Null_CHAR,
        NULL,  trim(PLANNED_INV_POINT_FLAG) ),
           LOT_TRANSLATE_ENABLED     =  DECODE( LOT_TRANSLATE_ENABLED, g_Upd_Null_CHAR,
        NULL,  trim(LOT_TRANSLATE_ENABLED) ),
           DEFAULT_SO_SOURCE_TYPE    =  DECODE( DEFAULT_SO_SOURCE_TYPE, g_Upd_Null_CHAR,
        NULL,  trim(DEFAULT_SO_SOURCE_TYPE) ),
           CREATE_SUPPLY_FLAG        =  DECODE( CREATE_SUPPLY_FLAG, g_Upd_Null_CHAR,
        NULL,  trim(CREATE_SUPPLY_FLAG) ),
           SUBSTITUTION_WINDOW_CODE  =  DECODE( SUBSTITUTION_WINDOW_CODE,
        g_Upd_Null_NUM, NULL, SUBSTITUTION_WINDOW_CODE ),
           SUBSTITUTION_WINDOW_DAYS  =  DECODE( SUBSTITUTION_WINDOW_DAYS,
        g_Upd_Null_NUM, NULL, SUBSTITUTION_WINDOW_DAYS ),
           LOT_SUBSTITUTION_ENABLED  =  DECODE( LOT_SUBSTITUTION_ENABLED,
        g_Upd_Null_CHAR, NULL,  trim(LOT_SUBSTITUTION_ENABLED) ),
           MINIMUM_LICENSE_QUANTITY  =  DECODE( MINIMUM_LICENSE_QUANTITY,
        g_Upd_Null_NUM, NULL, MINIMUM_LICENSE_QUANTITY),
           EAM_ACTIVITY_SOURCE_CODE  =  DECODE( EAM_ACTIVITY_SOURCE_CODE,
        g_Upd_Null_CHAR, NULL,  trim(EAM_ACTIVITY_SOURCE_CODE) ),
           IB_ITEM_INSTANCE_CLASS    =  DECODE( IB_ITEM_INSTANCE_CLASS, g_Upd_Null_CHAR,
        NULL,  trim(IB_ITEM_INSTANCE_CLASS) ),
           CONFIG_MODEL_TYPE         =  DECODE( CONFIG_MODEL_TYPE, g_Upd_Null_CHAR,
        NULL,  trim(CONFIG_MODEL_TYPE) ),
           TRACKING_QUANTITY_IND     =  DECODE( TRACKING_QUANTITY_IND, g_Upd_Null_CHAR,
        NULL,  trim(TRACKING_QUANTITY_IND) ),
           ONT_PRICING_QTY_SOURCE    =  DECODE( ONT_PRICING_QTY_SOURCE, g_Upd_Null_CHAR,
        NULL,  trim(ONT_PRICING_QTY_SOURCE) ),
           SECONDARY_DEFAULT_IND     =  DECODE( SECONDARY_DEFAULT_IND, g_Upd_Null_CHAR,
        NULL,  trim(SECONDARY_DEFAULT_IND) ),
           CONFIG_ORGS               =  DECODE( CONFIG_ORGS, g_Upd_Null_CHAR, NULL,
        trim(CONFIG_ORGS) ),
           CONFIG_MATCH              =  DECODE( CONFIG_MATCH, g_Upd_Null_CHAR, NULL,
        trim(CONFIG_MATCH) ),
           LIFECYCLE_ID              =
        decode(LIFECYCLE_ID,g_Upd_Null_NUM,NULL,LIFECYCLE_ID),
           CURRENT_PHASE_ID          =
        decode(CURRENT_PHASE_ID,g_Upd_Null_NUM,NULL,CURRENT_PHASE_ID),
           VMI_MINIMUM_UNITS =  DECODE( VMI_MINIMUM_UNITS,g_Upd_Null_NUM, NULL,
        VMI_MINIMUM_UNITS ) ,
           VMI_MINIMUM_DAYS  =  DECODE( VMI_MINIMUM_DAYS, g_Upd_Null_NUM, NULL,
        VMI_MINIMUM_DAYS ) ,
           VMI_MAXIMUM_UNITS =  DECODE( VMI_MAXIMUM_UNITS,g_Upd_Null_NUM, NULL,
        VMI_MAXIMUM_UNITS ),
           VMI_MAXIMUM_DAYS  =  DECODE( VMI_MAXIMUM_DAYS, g_Upd_Null_NUM, NULL,
        VMI_MAXIMUM_DAYS ),
           VMI_FIXED_ORDER_QUANTITY  =  DECODE( VMI_FIXED_ORDER_QUANTITY,
        g_Upd_Null_NUM, NULL, VMI_FIXED_ORDER_QUANTITY ),
           SO_AUTHORIZATION_FLAG     =  DECODE(SO_AUTHORIZATION_FLAG, g_Upd_Null_NUM,
        NULL, SO_AUTHORIZATION_FLAG ),
           CONSIGNED_FLAG    =  DECODE(CONSIGNED_FLAG, g_Upd_Null_NUM,
        NULL,CONSIGNED_FLAG ),
           ASN_AUTOEXPIRE_FLAG       =  DECODE( ASN_AUTOEXPIRE_FLAG, g_Upd_Null_NUM,
        NULL, ASN_AUTOEXPIRE_FLAG ),
           VMI_FORECAST_TYPE =  DECODE( VMI_FORECAST_TYPE, g_Upd_Null_NUM, NULL,
        VMI_FORECAST_TYPE ),
           FORECAST_HORIZON  =  DECODE( FORECAST_HORIZON, g_Upd_Null_NUM,
        NULL,FORECAST_HORIZON ),
           EXCLUDE_FROM_BUDGET_FLAG  =  DECODE( EXCLUDE_FROM_BUDGET_FLAG,
        g_Upd_Null_NUM, NULL, EXCLUDE_FROM_BUDGET_FLAG ),
           DAYS_TGT_INV_SUPPLY       =  DECODE( DAYS_TGT_INV_SUPPLY,
        g_Upd_Null_NUM,NULL, DAYS_TGT_INV_SUPPLY),
           DAYS_TGT_INV_WINDOW       =  DECODE( DAYS_TGT_INV_WINDOW, g_Upd_Null_NUM,
        NULL, DAYS_TGT_INV_WINDOW ),
           DAYS_MAX_INV_SUPPLY       =  DECODE( DAYS_MAX_INV_SUPPLY,g_Upd_Null_NUM,
        NULL, DAYS_MAX_INV_SUPPLY ),
           DAYS_MAX_INV_WINDOW       =  DECODE( DAYS_MAX_INV_WINDOW, g_Upd_Null_NUM,
        NULL, DAYS_MAX_INV_WINDOW ),
           DRP_PLANNED_FLAG  =  DECODE( DRP_PLANNED_FLAG,  g_Upd_Null_NUM, NULL,
        DRP_PLANNED_FLAG ),
           CRITICAL_COMPONENT_FLAG   =  DECODE( CRITICAL_COMPONENT_FLAG, g_Upd_Null_NUM,
        NULL, CRITICAL_COMPONENT_FLAG ),
           CONTINOUS_TRANSFER        =  DECODE( CONTINOUS_TRANSFER, g_Upd_Null_NUM,
        NULL, CONTINOUS_TRANSFER ),
           CONVERGENCE       =  DECODE( CONVERGENCE, g_Upd_Null_NUM, NULL, CONVERGENCE
        ),
           DIVERGENCE        =  DECODE( DIVERGENCE,  g_Upd_Null_NUM, NULL, DIVERGENCE )
           WHERE
              MSII.rowid = cr.rowid;

    /*End of bug 6417006*/


         if rtn_status = 0 then
            rtn_status := INVPULI4.assign_status_attributes(
                        cr.inventory_item_id,
                        cr.organization_id,
                        err_text,
                        xset_id,
                        cr.rowid);
            if rtn_status <> 0 then
               raise ASS_ITEM_ERR;
            end if;
         end if;

	 --Serial_Tagging Item -- bug 9913552
	 IF g_copy_item_id IS NOT NULL AND g_copy_item_id <>g_upd_null_num THEN

            IF INV_SERIAL_NUMBER_PUB.is_serial_tagged(p_inventory_item_id => g_copy_item_id,
                                                       p_organization_id => cr.organization_id)=2 THEN

               INV_SERIAL_NUMBER_PUB.copy_serial_tag_assignments(
	                                                 p_from_item_id =>g_copy_item_id,
	                                                 p_from_org_id =>cr.organization_id,
	                                                 p_to_item_id => cr.inventory_item_id,
	                                                 p_to_org_id =>cr.organization_id,
	                                                 x_return_status => x_ret_sts);

	       g_copy_item_id := -999999;

               IF x_ret_sts <>FND_API.G_RET_STS_SUCCESS THEN

                  dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                tran_id,
                                error_msg,
                                'SERIAL_TAGGING_FLAG',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_COPY_SER_FAIL_UNEXP',
                                err_text);
                       if dumm_status < 0 then
                             raise LOGGING_ERR;
                          end if;
               END IF;

            END IF ;
         END IF ;
	 -- this is for copy template case during insert mode
	 -- added >1 condition as from PIM UI template_id is always coming as -1
	 IF cr.template_id IS NOT NULL AND cr.template_id > 0 THEN
	    --bug 10065810
            begin
              SELECT  CONTEXT_ORGANIZATION_ID into l_temp_org_id
              FROM mtl_item_templates
              WHERE  template_id=cr.template_id;
            end;

            IF  (INV_SERIAL_NUMBER_PUB.is_serial_tagged(p_template_id=>cr.template_id
	                                                --bug 10065810
                                                        ,p_organization_id=>l_temp_org_id
                                                         )=2) THEN

	          INV_SERIAL_NUMBER_PUB.copy_serial_tag_assignments(
	                                        p_from_template_id => cr.template_id,
						--  bug 10065810
						p_from_org_id      => l_temp_org_id,
	                                        p_to_item_id       => cr.inventory_item_id,
	                                        p_to_org_id        => cr.organization_id,
	                                        x_return_status    =>  x_ret_sts);

            IF x_ret_sts <>FND_API.G_RET_STS_SUCCESS THEN

                  dumm_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                tran_id,
                                error_msg,
                                'SERIAL_TAGGING_FLAG',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'NV_COPY_SER_FAIL_UNEXP',
                                err_text);
                       if dumm_status < 0 then
                             raise LOGGING_ERR;
                          end if;
               END IF;

            END IF ;
         END IF ;



         revs := 0;

         --Start 2861248 :Populate Item Id for default revision only
         ---Start: Bug fix 3051653. Bug Fix 8428488.
         if rtn_status = 0 then
         l_item_id := NULL;
         IF cr.item_number IS NULL THEN
            rtn_status := INVPUOPI.mtl_pr_parse_item_segments(p_row_id    =>cr.rowid
                                                          ,item_number =>l_item_number
                                                          ,item_id     =>l_item_id
                                                          ,err_text    => err_text);
            cr.item_number := l_item_number;
            if rtn_status < 0 then
               raise ASS_ITEM_ERR;
            end if;

            --Bug: 5512333
            IF cr.item_number IS NOT NULL THEN
               rtn_status := INVPUOPI.mtl_pr_parse_item_number(cr.item_number
                                                              ,cr.inventory_item_id
                                                              ,cr.transaction_id
                                                              ,cr.organization_id
                                                              ,err_text
                                                              ,cr.rowid);
               IF rtn_status < 0 THEN
                  raise ASS_ITEM_ERR;
               END IF;
            END IF;
            --End Bug: 5512333
         END IF;
     end if; -- End: Bug Fix 8428488.

         -- bug 4539703
         -- Store sysdate minus 1 sec when inserting default revision data
         l_curr_sysdate := sysdate - 1/86400;

         --default rev should be sysdate
         update /*+ index(MTL_ITEM_REVISIONS_INTERFACE, MTL_ITEM_REVS_INTERFACE_N2) */  -- Bug 9678667 , adding hint suggested by perf team
            mtl_item_revisions_interface
            set effectivity_date = sysdate
          where set_process_id = xset_id
              and process_flag = 1
              /* Bug 9678667 - Start */
              AND inventory_item_id = cr.inventory_item_id
              AND organization_id = cr.organization_id
              /* Bug 9678667 - End */
              and revision       = cr.revision
              and (effectivity_date is null or effectivity_date > sysdate);


         --Passing item number and organization_id to cursor for bug 3051653
         FOR c_revision_record IN c_get_revisions(l_item_number,
                                cr.revision,cr.organization_id) LOOP
            IF l_item_id IS NULL THEN
               dumm_status := INVPUOPI.mtl_pr_parse_flex_name (
                               c_revision_record.organization_id,
                               'MSTK', c_revision_record.item_number,
                               flex_id,   0, err_temp);
            ELSE
               flex_id     := l_item_id;
               dumm_status := 0;
            END IF;


            IF dumm_status = 0 THEN
               update mtl_item_revisions_interface
               set inventory_item_id  = flex_id
               where item_number      = c_revision_record.item_number
               and   set_process_id   = xset_id
               and   organization_id  = c_revision_record.organization_id
               and   revision         = cr.revision
               RETURNING effectivity_date,rowid INTO l_effectivity_date,l_rowid;

               --2885843:Effectivity date to sysdate if passed date is > sysdate
               IF (l_effectivity_date IS NULL
                 OR TRUNC(l_effectivity_date) > TRUNC(SYSDATE)) THEN

                  update mtl_item_revisions_interface
                  set effectivity_date = sysdate
                  where rowid = l_rowid;

               END IF;
            END IF;
         END LOOP;

         --End 2861248 :Populate Item Id for default revision only

         SELECT /*+ use_concat */ count(*) INTO   revs -- Bug 9678667 : Adding hint suggested by perf team
         FROM   mtl_item_revisions_interface
         WHERE  ((organization_id       = cr.organization_id
               AND inventory_item_id = cr.inventory_item_id)
                  OR (organization_id = cr.organization_id
                      AND item_number = cr.item_number))
         AND    revision = cr.revision
         AND    process_flag = 1--Bug No: 3344480
         AND    set_process_id = cr.set_process_id;

         /*** insert a record into the revs interface table because one does not exist
         ** NP 06MAY96 Now inserting xset_id into set_process_id for MIRI
         ** NP 28MAY96 Choose the set_process_id of the relevant record for insertion to MIRI
         ** not the xset_id*/

         l_transaction_type  := 'CREATE' ;
         if (revs = 0) then
                 if (cr.revision = default_rev) then   -- Bug 4539703 for default revision create entry with sysdate -  1 sec
                --Bug 4626774 added request_id in both inserts
      --Adding Source System Id and Source System Reference to ensure Sequence Generated Item Number propogation
                        insert into mtl_item_revisions_interface
                                (organization_id, inventory_item_id, revision,
                                process_flag, transaction_type, set_process_id, implementation_date,
                                effectivity_date, creation_date, last_update_date
                                ,request_id, source_system_id, source_system_reference)
                        values(cr.organization_id, cr.inventory_item_id, cr.revision,
                                l_process_flag_1, l_transaction_type, cr.set_process_id, l_curr_sysdate,
                                l_curr_sysdate, l_curr_sysdate, l_curr_sysdate
                                ,request_id, cr.source_system_id, cr.source_system_reference);
                else
      --Adding Source System Id and Source System Reference to ensure Sequence Generated Item Number propogation
                        insert into mtl_item_revisions_interface
                                (organization_id, inventory_item_id, revision,
                                    process_flag, transaction_type, set_process_id
                                ,request_id, source_system_id, source_system_reference)
                        values (cr.organization_id, cr.inventory_item_id, cr.revision,
                                    l_process_flag_1, l_transaction_type, cr.set_process_id
                                ,request_id, cr.source_system_id, cr.source_system_reference);
                end if;
         end if;

         /*** check to see if a record exists in the revs interface table for this
         ** item/org/rev combination for the DEFAULT STARTING REVISION*/

         if (cr.revision <> default_rev) then
            revs := 0;

            select count(revision) into revs
            from    mtl_item_revisions_interface
            where   set_process_id = xset_id
            and         revision    = default_rev
            AND     process_flag = 1--Bug No: 3344480
            and ((organization_id = cr.organization_id
               and inventory_item_id = cr.inventory_item_id)
                 or(organization_id = cr.organization_id
                    and item_number = cr.item_number));

            /*** insert a record into the revs interface table because one does not exist
            ** for the DEFAULT STARTING REVISION
            ** Included implementation_date, effectivity_date , creation_date and last_update_date in the below
            sql query to insert sysdate value for bug fix 3226359 */

            l_transaction_type  := 'CREATE' ;
            if (revs = 0) then
            -- bug 4539703
            --Bug 4626774 added request_id in the insert
      --Adding Source System Id and Source System Reference to ensure Sequence Generated Item Number propogation
               insert into mtl_item_revisions_interface                    -- create a default revision with sysdate - 1 sec
                           (organization_id, inventory_item_id, revision,
                            process_flag, transaction_type, set_process_id,implementation_date,
                            effectivity_date,creation_date,last_update_date
                            ,request_id, source_system_id, source_system_reference)
               values (cr.organization_id, cr.inventory_item_id, default_rev,
                            l_process_flag_1, l_transaction_type, cr.set_process_id, l_curr_sysdate,
                            l_curr_sysdate, l_curr_sysdate,l_curr_sysdate
                            ,request_id, cr.source_system_id, cr.source_system_reference);
            end if;
         end if;

         /*** we finished one record assignment, let's update it*/
         if (validation_check_status = 0) then
            if (rtn_status = 0) then
                if default_flag = 1 then
                   process_flag_temp := 2;
                else
                   process_flag_temp := 1;
                end if;
            else
                process_flag_temp := 3;
            end if;
         else /*validation check failed */
            process_flag_temp := 3;
         end if;

         update MTL_SYSTEM_ITEMS_INTERFACE
         set process_flag = process_flag_temp,
             creation_date = nvl(creation_date, l_sysdate),
             revision = cr.revision
          where rowid  = cr.rowid ;

          if rtn_status <> 0 then
             if rtn_status=1403 then
                rtn_status := INVPUOPI.mtl_log_interface_err(
                                l_org_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                tran_id,
                                err_text,
                                'DESCRIPTION',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INV_DESC_ITEM_ERROR',
                                err_text);
             else
                rtn_status := INVPUOPI.mtl_log_interface_err(
                                cr.organization_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                cr.transaction_id,
                                err_text,
                                null,
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'BOM_PARSE_ITEM_ERROR',
                                err_text);
             end if;
             if rtn_status < 0 then
                raise LOGGING_ERR;
             end if;
          end if;
       else --org_flag <> 0
          dumm_status := INVPUOPI.mtl_log_interface_err(
                                l_org_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                tran_id,
                                err_text,
                                'ORGANIZATION_ID',
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'INVALID ORGANIZATION',
                                err_text);
          if dumm_status < 0 then
             raise LOGGING_ERR;
          end if;

          update mtl_system_items_interface
          set process_flag = l_process_flag_3
          where rowid = cr.rowid ;
       end if; --org_flag <> 0

       l_old_organization_id   := cr.organization_id ;

    end loop;

    -- Fix for bug#9336604
    IF (FND_INSTALLATION.GET_APP_INFO('INV', l_status, l_industry, l_schema)) THEN

       IF (nvl(fnd_profile.value('EGO_ENABLE_GATHER_STATS'),'N') = 'Y') THEN

        FND_STATS.GATHER_TABLE_STATS(OWNNAME => l_schema,
                                   TABNAME => 'MTL_SYSTEM_ITEMS_INTERFACE',
                                   CASCADE => True);
       END IF;

    END IF;

    return(0);

exception
   when ASS_ITEM_ERR then
      dumm_status := INVPUOPI.mtl_log_interface_err(
                                l_org_id,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                tran_id,
                                err_text,
                                null,
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'BOM_PARSE_ITEM_ERROR',
                                err_text);
        return(rtn_status);

   when LOGGING_ERR then
      return(dumm_status);
   when OTHERS then
      err_text := 'INVPAGI2.assign_item_header_recs:' || SQLERRM;
      dumm_status := INVPUOPI.mtl_log_interface_err(
                                l_org_id ,
                                user_id,
                                login_id,
                                prog_appid,
                                prog_id,
                                request_id,
                                tran_id,
                                err_text,
                                null,
                                'MTL_SYSTEM_ITEMS_INTERFACE',
                                'BOM_PARSE_ITEM_ERROR',
                                err_text);
      if (rtn_status = 0) then
         rtn_status := -1;
      end if;
      return(rtn_status);
end assign_item_header_recs;

end INVPAGI2;

/
