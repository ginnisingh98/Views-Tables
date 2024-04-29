--------------------------------------------------------
--  DDL for Package Body INV_HV_TXN_PURGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_HV_TXN_PURGE" AS
/* $Header: INVHVPGB.pls 120.0.12010000.2 2008/10/15 11:19:31 sabghosh ship $ */


--Procedure to purge the transaction tables

/* The purge will be carried out by
   1. Creating a temporary table with the required data alone.
   2. Truncating the original table.
   3. Inserting back the rows from the temporarary table to
      the original table.
   4. Commiting the transactions
   5. Dropping the temporary tables

   By this way, if the data to be deleted is very high, the program's performance
   will be better when compared with actually deleting the rows.
   If rows to be deleted are very less then script invtxnpg.sql will be better
   in terms of performance where we wmploy direct deltion from the tables.
*/

/*
   The parameters are
   1. x_errbuf          -- Error buffer to concurrent program
   2. x_retcode         -- Indicates the return status of the concurrent program
   3. p_organization_id -- Organization for which the purge has to be carried out,
                           If this is null then the records for all the organizations
                           will be purged.
   4. p_cut_off_date    -- The records whose transaction_date below this date
                           will be deleted. This is mandatory parameter.
                           This will be also used to check for accounting period.
                           If the period is open then purge won't be carried out.
*/

/* Configurable Variables are

   1. max_rows_to_del - This variable determines which approach has to be selected
                        for deleting the rows, either the direct approach or the
                        temp table approach. If the rows to be deleted are less than
                        this value then the records will be deleted directly else
                        it will be deleted via temp table approach.
                        Currently this is set to 100000. But it can be changed
                        based on the requirements
   2. l_bulk_limit    - This is the bulk collect limit for deletion.
                        This can be configured based on the database stats.
                        This is currently set to 5000.

*/

  PROCEDURE Txn_Purge( x_errbuf	         OUT NOCOPY VARCHAR2
                       ,x_retcode	      OUT NOCOPY NUMBER
                       ,p_organization_id	IN  NUMBER   := NULL
                       ,p_cut_off_date		IN  VARCHAR2
                      )
     IS

    l_debug          NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
    l_cut_off_date   DATE   := fnd_date.canonical_to_date(p_cut_off_date);
    s_cut_off_date   VARCHAR2(10);

    s_sql_stmt       VARCHAR2(1000);
    l_ret_msg        BOOLEAN;
    error            VARCHAR2(400);

    cursor_name      INTEGER;
	 rows_processed   INTEGER;
    rows_to_del      NUMBER := 0;
    max_rows_to_del  NUMBER := 100000;
    l_bulk_limit     NUMBER := 5000;

    inv_user_name    VARCHAR2(30);

    TYPE rowidtab IS TABLE OF ROWID INDEX BY BINARY_INTEGER;
    rowid_list       rowidtab;

    x_validation     VARCHAR2(10);
    bad_input_period EXCEPTION;

    CURSOR get_open_period (x_period_start_date DATE , x_organization_id   NUMBER )
      IS  SELECT 'OPEN' sdate
          FROM   org_acct_periods
          WHERE  INV_LE_TIMEZONE_PUB.get_le_day_for_inv_org(x_period_start_date,x_organization_id)
                   >= ( SELECT  MIN(period_start_date)
                        FROM    org_acct_periods
                        WHERE   organization_id = x_organization_id
                                AND  open_flag = 'Y'
                                        )
                 AND open_flag = 'Y';

    CURSOR c_mmta IS
       SELECT ROWID
       FROM     MTL_MATERIAL_TXN_ALLOCATIONS
       WHERE    transaction_date < l_cut_off_date
                AND (p_organization_id IS NULL OR organization_id = p_organization_id);

    CURSOR c_mmt IS
       SELECT ROWID
       FROM     MTL_MATERIAL_TRANSACTIONS
       WHERE    transaction_date < l_cut_off_date
                AND (p_organization_id IS NULL OR organization_id = p_organization_id);


    CURSOR c_mtlt IS
       SELECT ROWID
       FROM     MTL_TRANSACTION_LOT_NUMBERS
       WHERE    transaction_date < l_cut_off_date
                AND (p_organization_id IS NULL OR organization_id = p_organization_id);


    CURSOR c_mut IS
       SELECT ROWID
       FROM     MTL_UNIT_TRANSACTIONS
       WHERE    transaction_date < l_cut_off_date
                AND (p_organization_id IS NULL OR organization_id = p_organization_id);


    CURSOR c_mta IS
       SELECT ROWID
       FROM     MTL_TRANSACTION_ACCOUNTS
       WHERE    transaction_date < l_cut_off_date
                AND (p_organization_id IS NULL OR organization_id = p_organization_id);


  BEGIN

       inv_trx_util_pub.TRACE('Debug Level     = '|| l_debug);
       inv_trx_util_pub.TRACE('Organization Id = '|| p_organization_id);
       inv_trx_util_pub.TRACE('Cut off date    = '|| p_cut_off_date);

       --l_cut_off_date := To_Date( To_Char(fnd_date.canonical_to_date(p_cut_off_date),'MM-DD-RRRR'), 'MM-DD-RRRR');
       s_cut_off_date := To_Char(fnd_date.canonical_to_date(p_cut_off_date),'MM-DD-RRRR');
       inv_trx_util_pub.TRACE('Cut off date (' || l_cut_off_date || ') in MM-DD-RRRR format  = '|| s_cut_off_date);

       inv_user_name := upper('INV');
       inv_trx_util_pub.TRACE('Inventory User Name = '|| inv_user_name);

      /*
         Validate to see if the accounting period is open.
         If period is open then raise bad_input_period exception, else we do nothing.
         If an organization is specified only validate that organization,
         otherwise validate all organizations.
        */
       BEGIN

          IF (l_debug = 1) THEN
            inv_trx_util_pub.TRACE(' Accounting period check' );
          END IF;

          --Organization entered, so check the period of that org only
          IF p_organization_id is not null THEN

             OPEN  get_open_period (l_cut_off_date, p_organization_id);
             FETCH get_open_period INTO  x_validation;
             CLOSE get_open_period;

             IF (l_debug = 1) THEN
               inv_trx_util_pub.TRACE(' Organization_Id = ' || p_organization_id || ' Status = ' || x_validation );
             END IF;

           --Organization not provided, so Loop throught all organizations
           ELSE

             FOR i in (SELECT ood.organization_id FROM org_organization_definitions ood )
         	 LOOP -- Organization loop

               OPEN  get_open_period (l_cut_off_date, i.organization_id);
               FETCH get_open_period INTO  x_validation;
               CLOSE get_open_period;

               IF x_validation = 'OPEN' THEN
                  IF (l_debug = 1) THEN
                     inv_trx_util_pub.TRACE('Accounting period is open for Organization_Id = ' || i.organization_id || ' Status = ' || x_validation );
                  END IF;
                  -- Period is open so exit out of the organization loop
                 EXIT;
               END IF;

             END LOOP; --Organizations loop

           END IF; -- open period check

           --Check for x_validation. If it is open raise exception. Else continue processing.
           IF x_validation = 'OPEN' THEN
             RAISE bad_input_period;
           END IF;

           IF (l_debug = 1) THEN
             inv_trx_util_pub.TRACE(' Open period check completed sucessfully ' );
           END IF;

      EXCEPTION
         WHEN bad_input_period THEN
            IF (l_debug = 1) THEN
               inv_trx_util_pub.TRACE(' Accounting Period is open. Please check the cut-off date ' || l_cut_off_date);
            END IF;
		 	  RAISE fnd_api.g_exc_error;

         WHEN OTHERS THEN
            IF (l_debug = 1) THEN
               inv_trx_util_pub.TRACE(' Exception in open period check: ' || SQLERRM);
            END IF;
		 	  RAISE fnd_api.g_exc_unexpected_error;
      END;



      --Purging MTL_MATERIAL_TXN_ALLOCATIONS
      BEGIN

         IF (l_debug = 1) THEN
             inv_trx_util_pub.TRACE(' Purging MTL_MATERIAL_TXN_ALLOCATIONS ... ' );
         END IF;

         -- This will get the count of rows to be deleted
         BEGIN
            SELECT   count(transaction_id)
            INTO     rows_to_del
            FROM     mtl_material_txn_allocations
            WHERE    transaction_date < l_cut_off_date
                     AND (p_organization_id IS NULL OR organization_id = p_organization_id);

         EXCEPTION
            -- Some exception has occured
            WHEN no_data_found THEN
               IF (l_debug = 1) THEN
                   inv_trx_util_pub.TRACE(' Exception: ' || SQLERRM );
               END IF;
               rows_to_del := 0;


            WHEN OTHERS THEN
               IF (l_debug = 1) THEN
                   inv_trx_util_pub.TRACE(' Exception: ' || SQLERRM );
               END IF;
               rows_to_del := max_rows_to_del + 1;
         END;


         IF rows_to_del < max_rows_to_del THEN
            --Rows to be deleted are less hence delete them directly

            IF (l_debug = 1) THEN
                inv_trx_util_pub.TRACE(' Deleting from MTL_MATERIAL_TXN_ALLOCATIONS -- Direct deletion approach' );
            END IF;

            OPEN c_mmta;
            LOOP

               FETCH c_mmta bulk collect INTO rowid_list limit l_bulk_limit;

               IF rowid_list.first IS NULL THEN
                  inv_trx_util_pub.TRACE(' exiting out of the loop since there are no more records to delete ' );
                  EXIT;
               END IF;

               FORALL i IN rowid_list.first .. rowid_list.last
                  DELETE FROM mtl_material_txn_allocations
                  WHERE ROWID = rowid_list(i);

               COMMIT;
               EXIT WHEN c_mmta%notfound;
            END LOOP;

            IF (l_debug = 1) THEN
                inv_trx_util_pub.TRACE(' Deleted ' || rows_to_del || ' row(s) from MTL_MATERIAL_TXN_ALLOCATIONS ' );
            END IF;

            CLOSE c_mmta;

            IF (l_debug = 1) THEN
                inv_trx_util_pub.TRACE(' Purged MTL_MATERIAL_TXN_ALLOCATIONS sucessfully ' );
            END IF;

         ELSE
               -- Rows to be delted are more hence follow Temp table creation method
               s_sql_stmt :=    ' CREATE TABLE mtl_material_txn_alloc_bu '
                              || ' STORAGE (initial 1 M next 1 M minextents 1 maxextents unlimited) '
                              || ' NOLOGGING AS '
                              || ' SELECT  * FROM  MTL_MATERIAL_TXN_ALLOCATIONS '
                              || ' WHERE 1 = 1 ' ;

                IF p_organization_id IS NOT NULL THEN
                   s_sql_stmt := s_sql_stmt ||  ' and organization_id <>  ' || p_organization_id;
                   s_sql_stmt := s_sql_stmt ||  ' or ( organization_id  = ' || p_organization_id ||
                                                       ' and transaction_date >= to_date( '' ' || s_cut_off_date || ' '' , ''MM-DD-RRRR'' ) )';
                ELSE
                   s_sql_stmt := s_sql_stmt || '  and transaction_date >= to_date( '' ' || s_cut_off_date || ' '' , ''MM-DD-RRRR'' )';
                END IF;

             	 cursor_name := dbms_sql.open_cursor;
            	 DBMS_SQL.PARSE(cursor_name, s_sql_stmt, dbms_sql.native);
            	 rows_processed := dbms_sql.execute(cursor_name);
            	 DBMS_SQL.close_cursor(cursor_name);

                IF (l_debug = 1) THEN
                    inv_trx_util_pub.TRACE(' Temp Table mtl_material_txn_alloc_bu created.' );
                END IF;

                --Truncate the original table
                s_sql_stmt := 'TRUNCATE TABLE '|| inv_user_name || '.MTL_MATERIAL_TXN_ALLOCATIONS';
                cursor_name := dbms_sql.open_cursor;
                DBMS_SQL.PARSE(cursor_name, s_sql_stmt, dbms_sql.native);
                rows_processed := dbms_sql.execute(cursor_name);
                DBMS_SQL.close_cursor(cursor_name);

                IF (l_debug = 1) THEN
                   inv_trx_util_pub.TRACE(' Truncated the table MTL_MATERIAL_TXN_ALLOCATIONS');
                END IF;

                -- Insert required rows back to original table
                s_sql_stmt := 'INSERT INTO MTL_MATERIAL_TXN_ALLOCATIONS SELECT * FROM mtl_material_txn_alloc_bu';
                cursor_name := dbms_sql.open_cursor;
                DBMS_SQL.PARSE(cursor_name, s_sql_stmt, dbms_sql.native);
                rows_processed := dbms_sql.execute(cursor_name);
                DBMS_SQL.close_cursor(cursor_name);

                IF (l_debug = 1) THEN
                   inv_trx_util_pub.TRACE(' Inserted ' || rows_processed || ' row(s) into the table MTL_MATERIAL_TXN_ALLOCATIONS');
                END IF;

                --Commit the transaction
                COMMIT;
                IF (l_debug = 1) THEN
                   inv_trx_util_pub.TRACE(' Commited the transactions ');
                END IF;

                --Drop the temporary table
                s_sql_stmt :=  'DROP TABLE mtl_material_txn_alloc_bu';
                cursor_name := dbms_sql.open_cursor;
                DBMS_SQL.PARSE(cursor_name, s_sql_stmt, dbms_sql.native);
                rows_processed := dbms_sql.execute(cursor_name);
                DBMS_SQL.close_cursor(cursor_name);

                IF (l_debug = 1) THEN
                   inv_trx_util_pub.TRACE(' Dropped the temporary table mtl_material_txn_alloc_bu');
                END IF;

         END IF;

      EXCEPTION
         WHEN OTHERS THEN
            IF (l_debug = 1) THEN
                inv_trx_util_pub.TRACE(' Exception: ' || SQLERRM );
            END IF;

            IF DBMS_SQL.IS_OPEN(cursor_name) THEN
               DBMS_SQL.CLOSE_CURSOR(cursor_name);
            END IF;

            RAISE fnd_api.g_exc_error;
      END;



      --Purging MTL_MATERIAL_TRANSACTIONS
      BEGIN

         IF (l_debug = 1) THEN
             inv_trx_util_pub.TRACE(' Purging MTL_MATERIAL_TRANSACTIONS ... ' );
         END IF;

         -- This will get the count of rows to be deleted
         BEGIN
            SELECT   count(transaction_id)
            INTO     rows_to_del
            FROM     mtl_material_transactions
            WHERE    transaction_date < l_cut_off_date
                     AND (p_organization_id IS NULL OR organization_id = p_organization_id);

         EXCEPTION
            -- Some exception has occured
            WHEN no_data_found THEN
               IF (l_debug = 1) THEN
                   inv_trx_util_pub.TRACE(' Exception: ' || SQLERRM );
               END IF;
               rows_to_del := 0;


            WHEN OTHERS THEN
               IF (l_debug = 1) THEN
                   inv_trx_util_pub.TRACE(' Exception: ' || SQLERRM );
               END IF;
               rows_to_del := max_rows_to_del + 1;
         END;


         IF rows_to_del < max_rows_to_del THEN
            --Rows to be deleted are less hence delete them directly

            IF (l_debug = 1) THEN
                inv_trx_util_pub.TRACE(' Deleting from MTL_MATERIAL_TRANSACTIONS -- Direct deletion approach' );
            END IF;

            OPEN c_mmt;
            LOOP
               FETCH c_mmt bulk collect INTO rowid_list limit l_bulk_limit;

               IF rowid_list.first IS NULL THEN
                  inv_trx_util_pub.TRACE(' exiting out of the loop since there are no more records to delete ' );
                  EXIT;
               END IF;

               FORALL i IN rowid_list.first .. rowid_list.last
                  DELETE FROM mtl_material_transactions
                  WHERE ROWID = rowid_list(i);
               COMMIT;
               EXIT WHEN c_mmt%notfound;
            END LOOP;

            IF (l_debug = 1) THEN
                inv_trx_util_pub.TRACE(' Deleted ' || rows_to_del || ' row(s) from MTL_MATERIAL_TRANSACTIONS ' );
            END IF;

            CLOSE c_mmt;

            IF (l_debug = 1) THEN
                inv_trx_util_pub.TRACE(' Purged MTL_MATERIAL_TRANSACTIONS sucessfully ' );
            END IF;

         ELSE

               -- Rows to be delted are more hence follow Temp table creation method
                s_sql_stmt :=    ' CREATE TABLE mtl_material_transactions_bu '
                              || ' STORAGE (initial 1 M next 1 M minextents 1 maxextents unlimited) '
                              || ' NOLOGGING AS '
                              || ' SELECT  * FROM  MTL_MATERIAL_TRANSACTIONS '
                              || ' WHERE 1 = 1 ' ;

                IF p_organization_id IS NOT NULL THEN
                   s_sql_stmt := s_sql_stmt ||  ' and organization_id <>  ' || p_organization_id;
                   s_sql_stmt := s_sql_stmt ||  ' or ( organization_id  = ' || p_organization_id ||
                                                       ' and transaction_date >= to_date( '' ' || s_cut_off_date || ' '' , ''MM-DD-RRRR'' ) )';
                ELSE
                   s_sql_stmt := s_sql_stmt || '  and transaction_date >= to_date( '' ' || s_cut_off_date || ' '' , ''MM-DD-RRRR'' )';
                END IF;

                cursor_name := dbms_sql.open_cursor;
                DBMS_SQL.PARSE(cursor_name, s_sql_stmt, dbms_sql.native);
                rows_processed := dbms_sql.execute(cursor_name);
                DBMS_SQL.close_cursor(cursor_name);

                IF (l_debug = 1) THEN
                    inv_trx_util_pub.TRACE(' Temp Table mtl_material_transactions_bu created.' );
                END IF;

                --Truncate the original table
                s_sql_stmt := 'TRUNCATE TABLE '|| inv_user_name || '.MTL_MATERIAL_TRANSACTIONS';
                cursor_name := dbms_sql.open_cursor;
                DBMS_SQL.PARSE(cursor_name, s_sql_stmt, dbms_sql.native);
                rows_processed := dbms_sql.execute(cursor_name);
                DBMS_SQL.close_cursor(cursor_name);

                IF (l_debug = 1) THEN
                   inv_trx_util_pub.TRACE(' Truncated the table MTL_MATERIAL_TRANSACTIONS');
                END IF;

                -- Insert required rows back to original table
                s_sql_stmt := 'INSERT INTO MTL_MATERIAL_TRANSACTIONS SELECT * FROM mtl_material_transactions_bu';
                cursor_name := dbms_sql.open_cursor;
                DBMS_SQL.PARSE(cursor_name, s_sql_stmt, dbms_sql.native);
                rows_processed := dbms_sql.execute(cursor_name);
                DBMS_SQL.close_cursor(cursor_name);

                IF (l_debug = 1) THEN
                   inv_trx_util_pub.TRACE(' Inserted ' || rows_processed || ' row(s) into the table MTL_MATERIAL_TRANSACTIONS');
                END IF;

                --Commit the transaction
                COMMIT;
                IF (l_debug = 1) THEN
                   inv_trx_util_pub.TRACE(' Commited the transactions ');
                END IF;

                --Drop the temporary table
                s_sql_stmt :=  'DROP TABLE mtl_material_transactions_bu';
                cursor_name := dbms_sql.open_cursor;
                DBMS_SQL.PARSE(cursor_name, s_sql_stmt, dbms_sql.native);
                rows_processed := dbms_sql.execute(cursor_name);
                DBMS_SQL.close_cursor(cursor_name);

                IF (l_debug = 1) THEN
                   inv_trx_util_pub.TRACE(' Dropped the temporary table mtl_material_transactions_bu');
                END IF;

         END IF;

      EXCEPTION
         WHEN OTHERS THEN
            IF (l_debug = 1) THEN
                inv_trx_util_pub.TRACE(' Exception: ' || SQLERRM );
            END IF;

            IF DBMS_SQL.IS_OPEN(cursor_name) THEN
               DBMS_SQL.CLOSE_CURSOR(cursor_name);
            END IF;

            RAISE fnd_api.g_exc_error;
      END;



      --Purging MTL_TRANSACTION_LOT_NUMBERS
      BEGIN

         IF (l_debug = 1) THEN
             inv_trx_util_pub.TRACE(' Purging MTL_TRANSACTION_LOT_NUMBERS ... ' );
         END IF;

         -- This will get the count of rows to be deleted
         BEGIN
            SELECT   count(transaction_id)
            INTO     rows_to_del
            FROM     mtl_transaction_lot_numbers
            WHERE    transaction_date < l_cut_off_date
                     AND (p_organization_id IS NULL OR organization_id = p_organization_id);

         EXCEPTION
            -- Some exception has occured
            WHEN no_data_found THEN
               IF (l_debug = 1) THEN
                   inv_trx_util_pub.TRACE(' Exception: ' || SQLERRM );
               END IF;
               rows_to_del := 0;


            WHEN OTHERS THEN
               IF (l_debug = 1) THEN
                   inv_trx_util_pub.TRACE(' Exception: ' || SQLERRM );
               END IF;
               rows_to_del := max_rows_to_del + 1;
         END;


         IF rows_to_del < max_rows_to_del THEN
            --Rows to be deleted are less hence delete them directly

            IF (l_debug = 1) THEN
                inv_trx_util_pub.TRACE(' Deleting from MTL_TRANSACTION_LOT_NUMBERS -- Direct deletion approach' );
            END IF;

            OPEN c_mtlt;
            LOOP
               FETCH c_mtlt bulk collect INTO rowid_list limit l_bulk_limit;

               IF rowid_list.first IS NULL THEN
                  inv_trx_util_pub.TRACE(' exiting out of the loop since there are no more records to delete ' );
                  EXIT;
               END IF;

               FORALL i IN rowid_list.first .. rowid_list.last
                  DELETE FROM mtl_transaction_lot_numbers
                  WHERE ROWID = rowid_list(i);
               COMMIT;
               EXIT WHEN c_mtlt%notfound;
            END LOOP;

            IF (l_debug = 1) THEN
                inv_trx_util_pub.TRACE(' Deleted ' || rows_to_del || ' row(s) from MTL_TRANSACTION_LOT_NUMBERS ' );
            END IF;

            CLOSE c_mtlt;

            IF (l_debug = 1) THEN
                inv_trx_util_pub.TRACE(' Purged MTL_TRANSACTION_LOT_NUMBERS sucessfully ' );
            END IF;

         ELSE

               -- Rows to be delted are more hence follow Temp table creation method
                s_sql_stmt :=    ' CREATE TABLE mtl_transaction_lot_numbers_bu '
                              || ' STORAGE (initial 1 M next 1 M minextents 1 maxextents unlimited) '
                              || ' NOLOGGING AS '
                              || ' SELECT  * FROM MTL_TRANSACTION_LOT_NUMBERS '
                              || ' WHERE 1 = 1 ' ;

                IF p_organization_id IS NOT NULL THEN
                   s_sql_stmt := s_sql_stmt ||  ' and organization_id <>  ' || p_organization_id;
                   s_sql_stmt := s_sql_stmt ||  ' or ( organization_id  = ' || p_organization_id ||
                                                       ' and transaction_date >= to_date( '' ' || s_cut_off_date || ' '' , ''MM-DD-RRRR'' ) )';
                ELSE
                   s_sql_stmt := s_sql_stmt || '  and transaction_date >= to_date( '' ' || s_cut_off_date || ' '' , ''MM-DD-RRRR'' )';
                END IF;

                cursor_name := dbms_sql.open_cursor;
                DBMS_SQL.PARSE(cursor_name, s_sql_stmt, dbms_sql.native);
                rows_processed := dbms_sql.execute(cursor_name);
                DBMS_SQL.close_cursor(cursor_name);

                IF (l_debug = 1) THEN
                    inv_trx_util_pub.TRACE(' Temp Table mtl_transaction_lot_numbers_bu created.' );
                END IF;

                --Truncate the original table
                s_sql_stmt := 'TRUNCATE TABLE '|| inv_user_name || '.MTL_TRANSACTION_LOT_NUMBERS';
                cursor_name := dbms_sql.open_cursor;
                DBMS_SQL.PARSE(cursor_name, s_sql_stmt, dbms_sql.native);
                rows_processed := dbms_sql.execute(cursor_name);
                DBMS_SQL.close_cursor(cursor_name);

                IF (l_debug = 1) THEN
                   inv_trx_util_pub.TRACE(' Truncated the table MTL_TRANSACTION_LOT_NUMBERS');
                END IF;

                -- Insert required rows back to original table
                s_sql_stmt := 'INSERT INTO MTL_TRANSACTION_LOT_NUMBERS SELECT * FROM mtl_transaction_lot_numbers_bu';
                cursor_name := dbms_sql.open_cursor;
                DBMS_SQL.PARSE(cursor_name, s_sql_stmt, dbms_sql.native);
                rows_processed := dbms_sql.execute(cursor_name);
                DBMS_SQL.close_cursor(cursor_name);

                IF (l_debug = 1) THEN
                   inv_trx_util_pub.TRACE(' Inserted ' || rows_processed || ' row(s) into the table MTL_TRANSACTION_LOT_NUMBERS');
                END IF;

                --Commit the transaction
                COMMIT;
                IF (l_debug = 1) THEN
                   inv_trx_util_pub.TRACE(' Commited the transactions ');
                END IF;

                --Drop the temporary table
                s_sql_stmt :=  'DROP TABLE mtl_transaction_lot_numbers_bu';
                cursor_name := dbms_sql.open_cursor;
                DBMS_SQL.PARSE(cursor_name, s_sql_stmt, dbms_sql.native);
                rows_processed := dbms_sql.execute(cursor_name);
                DBMS_SQL.close_cursor(cursor_name);

                IF (l_debug = 1) THEN
                   inv_trx_util_pub.TRACE(' Dropped the temporary table mtl_transaction_lot_numbers_bu');
                END IF;

         END IF;

      EXCEPTION
         WHEN OTHERS THEN
            IF (l_debug = 1) THEN
                inv_trx_util_pub.TRACE(' Exception: ' || SQLERRM );
            END IF;

            IF DBMS_SQL.IS_OPEN(cursor_name) THEN
               DBMS_SQL.CLOSE_CURSOR(cursor_name);
            END IF;

            RAISE fnd_api.g_exc_error;
      END;



      --Purging MTL_UNIT_TRANSACTIONS
      BEGIN

         IF (l_debug = 1) THEN
             inv_trx_util_pub.TRACE(' Purging MTL_UNIT_TRANSACTIONS ... ' );
         END IF;

         -- This will get the count of rows to be deleted
         BEGIN
            SELECT   count(transaction_id)
            INTO     rows_to_del
            FROM     mtl_unit_transactions
            WHERE    transaction_date < l_cut_off_date
                     AND (p_organization_id IS NULL OR organization_id = p_organization_id);

         EXCEPTION
            -- Some exception has occured
            WHEN no_data_found THEN
               IF (l_debug = 1) THEN
                   inv_trx_util_pub.TRACE(' Exception: ' || SQLERRM );
               END IF;
               rows_to_del := 0;


            WHEN OTHERS THEN
               IF (l_debug = 1) THEN
                   inv_trx_util_pub.TRACE(' Exception: ' || SQLERRM );
               END IF;
               rows_to_del := max_rows_to_del + 1;
         END;


         IF rows_to_del < max_rows_to_del THEN
            --Rows to be deleted are less hence delete them directly

            IF (l_debug = 1) THEN
                inv_trx_util_pub.TRACE(' Deleting from MTL_UNIT_TRANSACTIONS -- Direct deletion approach' );
            END IF;

            OPEN c_mut;
            LOOP
               FETCH c_mut bulk collect INTO rowid_list limit l_bulk_limit;

               IF rowid_list.first IS NULL THEN
                  inv_trx_util_pub.TRACE(' exiting out of the loop since there are no more records to delete ' );
                  EXIT;
               END IF;

               FORALL i IN rowid_list.first .. rowid_list.last
                  DELETE FROM mtl_unit_transactions
                  WHERE ROWID = rowid_list(i);
               COMMIT;
               EXIT WHEN c_mut%notfound;
            END LOOP;

            IF (l_debug = 1) THEN
                inv_trx_util_pub.TRACE(' Deleted ' || rows_to_del || ' row(s) from MTL_UNIT_TRANSACTIONS ' );
            END IF;

            CLOSE c_mut;

            IF (l_debug = 1) THEN
                inv_trx_util_pub.TRACE(' Purged MTL_UNIT_TRANSACTIONS sucessfully ' );
            END IF;

         ELSE

               -- Rows to be delted are more hence follow Temp table creation method
               s_sql_stmt :=    ' CREATE TABLE mtl_unit_transactions_bu '
                              || ' STORAGE (initial 1 M next 1 M minextents 1 maxextents unlimited) '
                              || ' NOLOGGING AS '
                              || ' SELECT  * FROM  MTL_UNIT_TRANSACTIONS '
                              || ' WHERE 1 = 1 ' ;

               IF p_organization_id IS NOT NULL THEN
                  s_sql_stmt := s_sql_stmt ||  ' and organization_id <>  ' || p_organization_id;
                  s_sql_stmt := s_sql_stmt ||  ' or ( organization_id  = ' || p_organization_id ||
                                                      ' and transaction_date >= to_date( '' ' || s_cut_off_date || ' '' , ''MM-DD-RRRR'' ) )';
               ELSE
                  s_sql_stmt := s_sql_stmt || '  and transaction_date >= to_date( '' ' || s_cut_off_date || ' '' , ''MM-DD-RRRR'' )';
               END IF;

                cursor_name := dbms_sql.open_cursor;
                DBMS_SQL.PARSE(cursor_name, s_sql_stmt, dbms_sql.native);
                rows_processed := dbms_sql.execute(cursor_name);
                DBMS_SQL.close_cursor(cursor_name);

                IF (l_debug = 1) THEN
                    inv_trx_util_pub.TRACE(' Temp Table mtl_unit_transactions_bu created.' );
                END IF;

                --Truncate the original table
                s_sql_stmt := 'TRUNCATE TABLE '|| inv_user_name || '.MTL_UNIT_TRANSACTIONS';
                cursor_name := dbms_sql.open_cursor;
                DBMS_SQL.PARSE(cursor_name, s_sql_stmt, dbms_sql.native);
                rows_processed := dbms_sql.execute(cursor_name);
                DBMS_SQL.close_cursor(cursor_name);

                IF (l_debug = 1) THEN
                   inv_trx_util_pub.TRACE(' Truncated the table MTL_UNIT_TRANSACTIONS');
                END IF;

                -- Insert required rows back to original table
                s_sql_stmt := 'INSERT INTO MTL_UNIT_TRANSACTIONS SELECT * FROM mtl_unit_transactions_bu';
                cursor_name := dbms_sql.open_cursor;
                DBMS_SQL.PARSE(cursor_name, s_sql_stmt, dbms_sql.native);
                rows_processed := dbms_sql.execute(cursor_name);
                DBMS_SQL.close_cursor(cursor_name);

                IF (l_debug = 1) THEN
                   inv_trx_util_pub.TRACE(' Inserted ' || rows_processed || ' row(s) into the table MTL_UNIT_TRANSACTIONS');
                END IF;

                --Commit the transaction
                COMMIT;
                IF (l_debug = 1) THEN
                   inv_trx_util_pub.TRACE(' Commited the transactions ');
                END IF;

                --Drop the temporary table
                s_sql_stmt :=  'DROP TABLE mtl_unit_transactions_bu';
                cursor_name := dbms_sql.open_cursor;
                DBMS_SQL.PARSE(cursor_name, s_sql_stmt, dbms_sql.native);
                rows_processed := dbms_sql.execute(cursor_name);
                DBMS_SQL.close_cursor(cursor_name);

                IF (l_debug = 1) THEN
                   inv_trx_util_pub.TRACE(' Dropped the temporary table mtl_unit_transactions_bu');
                END IF;

         END IF;

      EXCEPTION
         WHEN OTHERS THEN
            IF (l_debug = 1) THEN
                inv_trx_util_pub.TRACE(' Exception: ' || SQLERRM );
            END IF;

            IF DBMS_SQL.IS_OPEN(cursor_name) THEN
               DBMS_SQL.CLOSE_CURSOR(cursor_name);
            END IF;

            RAISE fnd_api.g_exc_error;
      END;



      --Purging MTL_TRANSACTION_ACCOUNTS
      BEGIN

         IF (l_debug = 1) THEN
             inv_trx_util_pub.TRACE(' Purging MTL_TRANSACTION_ACCOUNTS ... ' );
         END IF;

         -- This will get the count of rows to be deleted
         BEGIN
         --Start bug 7336061
            /*SELECT   count(transaction_id)
                                    INTO     rows_to_del
                                    FROM     mtl_transaction_accounts
                                    WHERE    transaction_date < l_cut_off_date
                                    AND (p_organization_id IS NULL OR organization_id = p_organization_id);*/

            IF p_organization_id IS NULL THEN

                 SELECT   COUNT(transaction_id)
                 INTO     rows_to_del
                 FROM     mtl_transaction_accounts
                 WHERE    transaction_date < l_cut_off_date ;

            ELSE

                 SELECT   COUNT(transaction_id)
                 INTO     rows_to_del
                 FROM     mtl_transaction_accounts
                 WHERE    transaction_date < l_cut_off_date
                 AND      organization_id = p_organization_id ;

            END IF ;
         --End bug 7336061
         EXCEPTION
            -- Some exception has occured
            WHEN no_data_found THEN
               IF (l_debug = 1) THEN
                   inv_trx_util_pub.TRACE(' Exception: ' || SQLERRM );
               END IF;
               rows_to_del := 0;


            WHEN OTHERS THEN
               IF (l_debug = 1) THEN
                   inv_trx_util_pub.TRACE(' Exception: ' || SQLERRM );
               END IF;
               rows_to_del := max_rows_to_del + 1;
         END;


         IF rows_to_del < max_rows_to_del THEN
            --Rows to be deleted are less hence delete them directly

            IF (l_debug = 1) THEN
                inv_trx_util_pub.TRACE(' Deleting from MTL_TRANSACTION_ACCOUNTS -- Direct deletion approach' );
            END IF;

            OPEN c_mta;
            LOOP
               FETCH c_mta bulk collect INTO rowid_list limit l_bulk_limit;

               IF rowid_list.first IS NULL THEN
                  inv_trx_util_pub.TRACE(' exiting out of the loop since there are no more records to delete ' );
                  EXIT;
               END IF;

               FORALL i IN rowid_list.first .. rowid_list.last
                  DELETE FROM mtl_transaction_accounts
                  WHERE ROWID = rowid_list(i);
               COMMIT;
               EXIT WHEN c_mta%notfound;
            END LOOP;

            IF (l_debug = 1) THEN
                inv_trx_util_pub.TRACE(' Deleted ' || rows_to_del || ' row(s) from MTL_TRANSACTION_ACCOUNTS ' );
            END IF;

            CLOSE c_mta;

            IF (l_debug = 1) THEN
                inv_trx_util_pub.TRACE(' Purged MTL_TRANSACTION_ACCOUNTS sucessfully ' );
            END IF;

         ELSE

               -- Rows to be delted are more hence follow Temp table creation method
               s_sql_stmt :=    ' CREATE TABLE mtl_transaction_accounts_bu '
                              || ' STORAGE (initial 1 M next 1 M minextents 1 maxextents unlimited) '
                              || ' NOLOGGING AS '
                              || ' SELECT  * FROM  MTL_TRANSACTION_ACCOUNTS '
                              || ' WHERE 1 = 1 ' ;

               IF p_organization_id IS NOT NULL THEN
                  s_sql_stmt := s_sql_stmt ||  ' and organization_id <>  ' || p_organization_id;
                  s_sql_stmt := s_sql_stmt ||  ' or ( organization_id  = ' || p_organization_id ||
                                                      ' and transaction_date >= to_date( '' ' || s_cut_off_date || ' '' , ''MM-DD-RRRR'' ) )';
               ELSE
                  s_sql_stmt := s_sql_stmt || '  and transaction_date >= to_date( '' ' || s_cut_off_date || ' '' , ''MM-DD-RRRR'' )';
               END IF;

                cursor_name := dbms_sql.open_cursor;
                DBMS_SQL.PARSE(cursor_name, s_sql_stmt, dbms_sql.native);
                rows_processed := dbms_sql.execute(cursor_name);
                DBMS_SQL.close_cursor(cursor_name);

                IF (l_debug = 1) THEN
                    inv_trx_util_pub.TRACE(' Temp Table mtl_transaction_accounts_bu created.' );
                END IF;

                --Truncate the original table
                s_sql_stmt := 'TRUNCATE TABLE '|| inv_user_name || '.MTL_TRANSACTION_ACCOUNTS';
                cursor_name := dbms_sql.open_cursor;
                DBMS_SQL.PARSE(cursor_name, s_sql_stmt, dbms_sql.native);
                rows_processed := dbms_sql.execute(cursor_name);
                DBMS_SQL.close_cursor(cursor_name);

                IF (l_debug = 1) THEN
                   inv_trx_util_pub.TRACE(' Truncated the table MTL_TRANSACTION_ACCOUNTS');
                END IF;

                -- Insert required rows back to original table
                s_sql_stmt := 'INSERT INTO MTL_TRANSACTION_ACCOUNTS SELECT * FROM mtl_transaction_accounts_bu';
                cursor_name := dbms_sql.open_cursor;
                DBMS_SQL.PARSE(cursor_name, s_sql_stmt, dbms_sql.native);
                rows_processed := dbms_sql.execute(cursor_name);
                DBMS_SQL.close_cursor(cursor_name);

                IF (l_debug = 1) THEN
                   inv_trx_util_pub.TRACE(' Inserted ' || rows_processed || ' row(s) into the table MTL_TRANSACTION_ACCOUNTS');
                END IF;

                --Commit the transaction
                COMMIT;
                IF (l_debug = 1) THEN
                   inv_trx_util_pub.TRACE(' Commited the transactions ');
                END IF;

                --Drop the temporary table
                s_sql_stmt :=  'DROP TABLE mtl_transaction_accounts_bu';
                cursor_name := dbms_sql.open_cursor;
                DBMS_SQL.PARSE(cursor_name, s_sql_stmt, dbms_sql.native);
                rows_processed := dbms_sql.execute(cursor_name);
                DBMS_SQL.close_cursor(cursor_name);

                IF (l_debug = 1) THEN
                   inv_trx_util_pub.TRACE(' Dropped the temporary table mtl_transaction_accounts_bu');
                END IF;

         END IF;

      EXCEPTION
         WHEN OTHERS THEN
            IF (l_debug = 1) THEN
                inv_trx_util_pub.TRACE(' Exception: ' || SQLERRM );
            END IF;

            IF DBMS_SQL.IS_OPEN(cursor_name) THEN
               DBMS_SQL.CLOSE_CURSOR(cursor_name);
            END IF;

            RAISE fnd_api.g_exc_error;
      END;

    --return sucess
    l_ret_msg  := fnd_concurrent.set_completion_status('NORMAL', 'NORMAL');
    x_retcode  := retcode_success;
    x_errbuf   := NULL;

    inv_trx_util_pub.TRACE('High Volume Transactions Purge completed sucessfully');

  EXCEPTION

     WHEN fnd_api.g_exc_error THEN
      error      := SQLERRM;
      IF (l_debug = 1) THEN
        inv_trx_util_pub.TRACE('The error is '|| error, 'INVHVPG', 9);
      END IF;

      IF c_mmta%ISOPEN THEN
         CLOSE c_mmta;
      END IF;

      IF c_mmt%ISOPEN THEN
         CLOSE c_mmt;
      END IF;

      IF c_mtlt%ISOPEN THEN
         CLOSE c_mtlt;
      END IF;

      IF c_mut%ISOPEN THEN
         CLOSE c_mut;
      END IF;

      IF c_mta%ISOPEN THEN
         CLOSE c_mta;
      END IF;

      l_ret_msg  := fnd_concurrent.set_completion_status('ERROR', 'ERROR');
      x_retcode  := retcode_error;
      x_errbuf   := fnd_msg_pub.get(p_encoded => fnd_api.g_false);

    WHEN fnd_api.g_exc_unexpected_error THEN
      error      := SQLERRM;
      IF (l_debug = 1) THEN
        inv_trx_util_pub.TRACE('The error is '|| error, 'INVHVPG', 9);
      END IF;

      IF c_mmta%ISOPEN THEN
         CLOSE c_mmta;
      END IF;

      IF c_mmt%ISOPEN THEN
         CLOSE c_mmt;
      END IF;

      IF c_mtlt%ISOPEN THEN
         CLOSE c_mtlt;
      END IF;

      IF c_mut%ISOPEN THEN
         CLOSE c_mut;
      END IF;

      IF c_mta%ISOPEN THEN
         CLOSE c_mta;
      END IF;

      l_ret_msg  := fnd_concurrent.set_completion_status('ERROR', 'ERROR');
      x_retcode  := retcode_error;
      x_errbuf   := fnd_msg_pub.get(p_encoded => fnd_api.g_false);

    WHEN OTHERS THEN
      error      := SQLERRM;
      IF (l_debug = 1) THEN
        inv_trx_util_pub.TRACE('The error is '|| error, 'INVHVPG', 9);
      END IF;

      IF c_mmta%ISOPEN THEN
         CLOSE c_mmta;
      END IF;

      IF c_mmt%ISOPEN THEN
         CLOSE c_mmt;
      END IF;

      IF c_mtlt%ISOPEN THEN
         CLOSE c_mtlt;
      END IF;

      IF c_mut%ISOPEN THEN
         CLOSE c_mut;
      END IF;

      IF c_mta%ISOPEN THEN
         CLOSE c_mta;
      END IF;

      l_ret_msg  := fnd_concurrent.set_completion_status('ERROR', 'ERROR');
      x_retcode  := retcode_error;
      x_errbuf   := fnd_msg_pub.get(p_encoded => fnd_api.g_false);

  END Txn_Purge;

END INV_HV_TXN_PURGE;

/
