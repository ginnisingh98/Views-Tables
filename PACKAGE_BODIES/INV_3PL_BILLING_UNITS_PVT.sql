--------------------------------------------------------
--  DDL for Package Body INV_3PL_BILLING_UNITS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_3PL_BILLING_UNITS_PVT" AS
/* $Header: INVVBLUB.pls 120.0.12010000.7 2010/04/28 13:31:28 gjyoti noship $ */


    G_PKG_NAME CONSTANT VARCHAR2(30) := 'INV_3PL_BILLING_UNITS_PVT';
    g_debug       NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

    v_client_id                mtl_billing_rule_lines_v.client_id%type;
    v_client_code              mtl_billing_rule_lines_v.client_code%type;
    v_client_name              mtl_billing_rule_lines_v.client_name%type;
    v_client_number            mtl_billing_rule_lines_v.client_number%type;
    v_contract_id              mtl_billing_rule_lines_v.contract_id%type;
    v_contract_number          mtl_billing_rule_lines_v.contract_number%type;
    v_counter_item_id          mtl_billing_rule_lines_v.counter_item_id%type;
    v_last_computation_Date    mtl_billing_rule_lines_v.last_computation_Date%type;
    v_net_Reading              mtl_billing_rule_lines_v.net_Reading%type;
    v_last_reading             mtl_billing_rule_lines_v.last_reading%type;
    v_billing_uom              mtl_billing_rule_lines_v.billing_uom%type;
    v_service_item_org_id      mtl_billing_rule_lines_v.service_item_org_id%type;
    v_billing_source_id        mtl_billing_rule_lines_v.billing_source_id%type;
    v_billing_source_name      mtl_billing_rule_lines_v.billing_source_name%type;
    v_service_line_start_date  mtl_billing_rule_lines_v.service_line_start_date%type;
    v_service_line_end_date    mtl_billing_rule_lines_v.service_line_end_date%type;


    PROCEDURE debug(
        p_message  IN  VARCHAR2
        ) IS
    BEGIN
        inv_log_util.trace(p_message, G_PKG_NAME , 10 );
    EXCEPTION
        WHEN OTHERS THEN
             NULL;
    END debug;



    PROCEDURE calculate_billing_units
        (
            ERRBUF              OUT NOCOPY VARCHAR2 ,
            RETCODE             OUT NOCOPY NUMBER ,
            p_OU_id             IN NUMBER,
            p_client_id         IN NUMBER,
            p_rule_ID           IN NUMBER,
            p_contract_id       IN NUMBER,
            p_item_id           IN NUMBER,
            p_source_to_date    IN VARCHAR2
        )

    IS

        CURSOR cur_invoice_interface_details (p_contract_id NUMBER)
        IS
        SELECT invoice_date, interface_date, date_start, date_end
          FROM
                (SELECT b.date_transaction invoice_date,
                        b.date_to_interface interface_date,
                        date_start, date_end
                   FROM mtl_agreement_details_v a, oks_level_elements b
                  WHERE a.cle_id = b.cle_id
                    AND a.dnz_chr_id = b.dnz_chr_id
                    AND b.date_completed IS NOT NULL
                    AND a.dnz_chr_id = p_contract_id
                    ORDER BY b.id DESC) invoice_interface_det
         WHERE ROWNUM <2;

        CURSOR sel_eligible_transactions (p_end_date DATE, p_client_code VARCHAR2)
        IS
            SELECT /*+ parallel(MMT) */ MMT.locator_id
                 , MMT.organization_id
                 , WMS_DEPLOY.GET_CLIENT_CODE( inventory_item_id ) CLIENT_CODE
                 , MMT.transaction_action_id
                 , MMT.primary_quantity
                 , MMT.creation_date
              FROM MTL_MATERIAL_TRANSACTIONS MMT
                 , MTL_3PL_LOCATOR_OCCUPANCY MLC
             WHERE MMT.organization_id = MLC.organization_id
               AND WMS_DEPLOY.GET_CLIENT_CODE( MMT.inventory_item_id ) = nvl(p_client_code, MLC.client_code)
               AND MMT.locator_id = MLC.locator_id
               AND MMT.creation_date between MLC.last_invoiced_date and p_end_date
               AND MMT.transaction_action_id not in (5,6,24,30,26,7,11,17,10,9,13,14,56,57)
               AND EXISTS (SELECT 1 FROM mtl_parameters  mp
                            WHERE wms_enabled_flag = 'Y'
                            AND mp.organization_id = mmt.organization_id)
             ORDER BY MMT.inventory_item_id, MMT.locator_id, MMT.creation_date;


        CURSOR sel_new_transactions (p_start_date DATE, p_end_date DATE, p_client_code VARCHAR2)
        IS

                SELECT /*+ parallel(MMT) */ MMT.locator_id
                     , MMT.organization_id
                     , WMS_DEPLOY.GET_CLIENT_CODE( inventory_item_id ) CLIENT_CODE
                     , MMT.transaction_action_id
                     , MMT.primary_quantity
                     , MMT.creation_date
                  FROM MTL_MATERIAL_TRANSACTIONS MMT
                 WHERE
                      WMS_DEPLOY.GET_CLIENT_CODE( MMT.inventory_item_id ) IS NOT NULL
                  AND NOT EXISTS (SELECT 1
                          FROM MTL_3PL_LOCATOR_OCCUPANCY MLC
                         WHERE MMT.organization_id = MLC.organization_id
                           AND WMS_DEPLOY.GET_CLIENT_CODE( MMT.inventory_item_id ) = MLC.client_code
                           AND MMT.locator_id = MLC.locator_id)
                    AND MMT.creation_date BETWEEN p_start_date AND p_end_date
                   AND MMT.transaction_action_id not in (5,6,24,30,26,7,11,17,10,9,13,14,56,57)
                   AND EXISTS (SELECT 1 FROM mtl_parameters  mp
                                WHERE wms_enabled_flag = 'Y'
                                AND mp.organization_id = mmt.organization_id)
              ORDER BY MMT.inventory_item_id, MMT.locator_id, MMT.creation_date;

        CURSOR sel_ct_new_transactions (p_start_date DATE, p_end_date DATE, p_client_code VARCHAR2)
        IS

                SELECT /*+ parallel(MMT) */ MMT.locator_id
                     , MMT.organization_id
                     , WMS_DEPLOY.GET_CLIENT_CODE( inventory_item_id ) CLIENT_CODE
                     , MMT.transaction_action_id
                     , MMT.primary_quantity
                     , MMT.creation_date
                  FROM MTL_MATERIAL_TRANSACTIONS MMT
                 WHERE
                      WMS_DEPLOY.GET_CLIENT_CODE( MMT.inventory_item_id ) IS NOT NULL
                      AND WMS_DEPLOY.GET_CLIENT_CODE( MMT.inventory_item_id ) = p_client_code
                  AND NOT EXISTS (SELECT 1
                          FROM MTL_3PL_LOCATOR_OCCUPANCY MLC
                         WHERE MMT.organization_id = MLC.organization_id
                           AND WMS_DEPLOY.GET_CLIENT_CODE( MMT.inventory_item_id ) = p_client_code
                           AND MMT.locator_id = MLC.locator_id)
                    AND MMT.creation_date BETWEEN p_start_date AND p_end_date
                   AND MMT.transaction_action_id not in (5,6,24,30,26,7,11,17,10,9,13,14,56,57)
                   AND EXISTS (SELECT 1 FROM mtl_parameters  mp
                                WHERE wms_enabled_flag = 'Y'
                                AND mp.organization_id = mmt.organization_id)
              ORDER BY MMT.inventory_item_id, MMT.locator_id, MMT.creation_date;

        l_progress                  NUMBER(2):= 0;
        l_last_invoice_date         DATE;
        l_last_interface_date       DATE;
        l_custom_reading            NUMBER:= 0;
        x_return_Status             VARCHAR2(1);
        l_ret                       BOOLEAN;
        l_meaning                   VARCHAR2(80);
        l_plsql_block               VARCHAR2(4000);
        l_source_to_date            VARCHAR2(100);
        l_src_to_date               DATE;
        l_ctr_value_id              NUMBER;
        l_success                   BOOLEAN := FALSE;
        l_rec_processed             NUMBER(10) := 0;
        l_rec_failed                NUMBER(10) := 0;
        l_client_code               VARCHAR2(10) := NULL;
        l_upgrade_date              DATE := NULL;
        l_space_seeded_src_used     VARCHAR2(1) := 'N';
        x_msg_count                 NUMBER;
        x_msg_data                  VARCHAR2(4000);
        l_counter_item_id           okc_k_items.object1_id1%TYPE;
        l_billing_source_rec        INV_3PL_BILLING_PUB.source_rec_type;

        ERROR_IN_PROGRAM            EXCEPTION;
        l_start_date                DATE;
        l_profile_creation_date     DATE:= NULL;
        l_plsql_blk_failed          VARCHAR2(1):='Y';
        l_plsql_msg_data            VARCHAR2(4000);
        l_printed_in_outfile        VARCHAR2(1):='N';
        d_sql_p                     INTEGER := NULL;
        d_sql_rows_processed        INTEGER := NULL;
        d_sql_stmt                  VARCHAR2(32700) := NULL;
        d_space_seeded_src_used     NUMBER  := 0;
        lc_client_id                mtl_client_parameters.client_id%TYPE;
        lc_client_code              mtl_client_parameters.client_code%TYPE;
        lc_client_name              hz_parties.party_name%TYPE;
        lc_client_number            mtl_client_parameters.client_number%TYPE;
        lc_contract_id              okc_k_headers_all_b.id%TYPE;
        lc_contract_number          okc_k_headers_all_b.contract_number%TYPE;
        lc_counter_item_id          mtl_system_items.inventory_item_id%TYPE;
        lc_net_Reading              csi_counter_readings.net_Reading%TYPE;
        lc_last_reading             csi_counter_readings.net_Reading%TYPE;
        lc_billing_uom              mtl_system_items.primary_uom_code%TYPE;
        lc_service_item_org_id      mtl_billing_rule_lines_v.service_item_org_id%TYPE;
        lc_billing_source_id        mtl_billing_sources_b.billing_source_id%TYPE;
        lc_billing_source_name      mtl_billing_sources_tl.name%TYPE;
        lc_last_computation_Date    DATE;
        lc_service_line_start_date  DATE;
        lc_service_line_end_date    DATE;
        l_transaction_id            NUMBER; /* Added for bug 9657044 */

    BEGIN
        l_source_to_date := fnd_date.date_to_canonical(nvl(to_date(p_source_to_date, 'YYYY/MM/DD HH24:MI:SS'), sysdate));
        l_src_to_date:=  to_Date(l_source_to_date, 'YYYY/MM/DD HH24:MI:SS');

        IF l_src_to_date > SYSDATE THEN
               IF g_debug = 1 THEN
                debug('Source to date can not be a future date ');
               END IF;
            RAISE ERROR_IN_PROGRAM;
        END IF;

        BEGIN
            d_sql_p               := DBMS_SQL.open_cursor;
            d_sql_stmt           :=
                            'SELECT count(*) cnt '
                      || 'FROM mtl_billing_rule_lines rule_lines, '
                      || 'mtl_billing_rule_headers_b rule_headers, '
                      || 'okc_k_headers_all_b contract_headers, '
                      || 'mtl_client_parameters mcp '
                      || 'WHERE rule_headers.billing_rule_header_id = rule_lines.billing_rule_header_id '
                      || 'AND contract_headers.authoring_org_id = :OU_Id '
                      || 'AND rule_headers.service_agreement_id = contract_headers.id '
                      || 'AND mcp.client_code = rule_lines.client_code ';

            d_sql_stmt := d_sql_stmt || 'AND EXISTS ('
                 || 'SELECT 1 '
                 || 'FROM mfg_lookups lookup, mtl_billing_sources_b blsrc '
                 || 'WHERE blsrc.billing_source_code = ''S'' '
                 || 'AND rule_lines.billing_source_id = blsrc.billing_source_id '
                 || 'AND lookup.lookup_type = ''MTL_3PL_SEEDED_SOURCE'' '
                 || 'AND lookup.lookup_code IN (7, 8) '
                 || 'AND blsrc.procedure_code = lookup.lookup_code)';
           IF (p_client_id is NOT NULL) THEN
                d_sql_stmt := d_sql_stmt || ' AND mcp.client_id = :client_id';
            END IF;
            IF (p_rule_id is NOT NULL) THEN
                d_sql_stmt := d_sql_stmt || ' AND rule_headers.billing_rule_header_id = :rule_id';
            END IF;
            IF (p_contract_id is NOT NULL) THEN
                d_sql_stmt := d_sql_stmt || ' AND rule_headers.service_agreement_id = :contract_id';
            END IF;
            IF (p_item_id is NOT NULL) THEN
                d_sql_stmt := d_sql_stmt || ' AND rule_lines.inventory_item_id = :item_id';
            END IF;
            IF g_debug = 1 THEN
               debug('Prepared the statment ');
            END IF;
            DBMS_SQL.parse(d_sql_p, d_sql_stmt, DBMS_SQL.native);
            DBMS_SQL.define_column(d_sql_p, 1, d_space_seeded_src_used);
            IF g_debug = 1 THEN
               debug('Binding the variables ');
            END IF;

            DBMS_SQL.bind_variable(d_sql_p, 'OU_Id', p_OU_Id);
            IF (p_client_id is NOT NULL) THEN
                DBMS_SQL.bind_variable(d_sql_p, 'client_id', p_client_id);
            END IF;
            IF (p_rule_id is NOT NULL) THEN
                DBMS_SQL.bind_variable(d_sql_p, 'rule_id', p_rule_id);
            END IF;
            IF (p_contract_id is NOT NULL) THEN
                DBMS_SQL.bind_variable(d_sql_p, 'contract_id', p_contract_id);
            END IF;
            IF (p_item_id is NOT NULL) THEN
                DBMS_SQL.bind_variable(d_sql_p, 'item_id', p_item_id);
            END IF;

            d_sql_rows_processed  := DBMS_SQL.EXECUTE(d_sql_p);

            LOOP
                BEGIN
                    IF (DBMS_SQL.fetch_rows(d_sql_p) > 0) THEN
                        DBMS_SQL.column_value(d_sql_p, 1, d_space_seeded_src_used);
                        IF g_debug = 1 THEN
                           debug('After fetch , d_space_seeded_src_used-> '||d_space_seeded_src_used);
                        END IF;
                        EXIT;
                    ELSE
                        d_space_seeded_src_used := 0;
                        IF g_debug = 1 THEN
                           debug('Seeded Space source not used -> '||d_space_seeded_src_used);
                        END IF;
                        DBMS_SQL.close_cursor(d_sql_p);
                        EXIT;
                    END IF;
                EXCEPTION
                WHEN OTHERS THEN
                    IF g_debug = 1 THEN
                        debug('Exception while finding Seeded Space source used -> '||sqlerrm);
                    END IF;
                    EXIT;
                END;
            END LOOP;
            IF DBMS_SQL.is_open(d_sql_p) THEN
               DBMS_SQL.close_cursor(d_sql_p);
            END IF;
            EXCEPTION
                WHEN OTHERS THEN
                    d_space_seeded_src_used := 0;
                    IF g_debug = 1 THEN
                        debug('Exception in dynamic sql for seeded space source -> '||sqlerrm);
                    END IF;
                    IF DBMS_SQL.is_open(d_sql_p) THEN
                        DBMS_SQL.close_cursor(d_sql_p);
                    END IF;
        END;

        IF (d_space_seeded_src_used > 0) THEN
            IF g_debug = 1 THEN
                debug('p_client_id not null ? -> '||p_client_id);
            END IF;
            IF p_client_id IS NOT NULL
            THEN
               BEGIN
                    debug('Get l_client_code');
                    SELECT client_code
                      INTO l_client_code
                      FROM mtl_client_parameters
                     WHERE client_id = p_client_id;

                    IF g_debug = 1 THEN
                        debug('l_client_code -> '||l_client_code);
                    END IF;
               EXCEPTION
                    WHEN OTHERS THEN
                        debug(' l_client_code exception -> '||sqlerrm);
                        l_client_code := NULL;
               END;
            END IF;

            BEGIN
                SELECT upgrade_date
                  INTO l_upgrade_date
                  FROM mtl_3pl_locator_occupancy
                 WHERE upgrade_date IS NOT NULL
                 AND ROWNUM <2;

                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        BEGIN
                            SELECT creation_date
                              INTO l_profile_creation_date
                              FROM fnd_profile_options
                             WHERE profile_option_name = 'WMS_DEPLOYMENT_MODE'
                               AND application_id = 385;
                        EXCEPTION
                            WHEN OTHERS THEN
                                l_profile_creation_date:= NULL;
                        END;
                    WHEN OTHERS THEN
                        l_upgrade_date:= NULL;
            END;

            IF g_debug = 1 THEN
                debug('Get eligible Transactions ');
                debug('Going to insert data in locator table ');
            END IF;

            BEGIN
               FOR sel_eligible_rec IN sel_eligible_transactions(l_src_to_date, l_client_code)
                LOOP
                    IF g_debug = 1 THEN
                        debug('In Select sel_eligible_rec for date, code -> '||l_src_to_date||', '||l_client_code);
                    END IF;
                   inv_3pl_loc_pvt.update_locator_capacity(
                               x_return_status              => x_return_status
                             , x_msg_count                  => x_msg_count
                             , x_msg_data                   => x_msg_data
                             , p_inventory_location_id      => sel_eligible_rec.locator_id
                             , p_organization_id            => sel_eligible_rec.organization_id
                             , p_client_code                => sel_eligible_rec.client_code
                             , p_transaction_action_id      => sel_eligible_rec.transaction_action_id
                             , p_quantity                   => sel_eligible_rec.primary_quantity
                             , p_transaction_date           => sel_eligible_rec.creation_date
                             );
                    IF x_return_status  <> fnd_api.g_ret_sts_success THEN
                        x_msg_data := fnd_message.get;
                        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Error =>  '||x_msg_data);
                        IF g_debug = 1 THEN
                            debug('Error from update_locator_capacity - '||x_msg_data);
                        END IF;
                        l_success := FALSE;
                        RAISE ERROR_IN_PROGRAM;
                    END IF;

                END LOOP;

            EXCEPTION
               WHEN OTHERS THEN
                  IF g_debug = 1 THEN
                     debug(l_progress ||' : Got error while selecting eligible transactions');
                     debug(l_progress ||' : Error: '||SQLERRM);
                  END IF;
                  l_success := FALSE;
                  raise ERROR_IN_PROGRAM;
            END;


            IF g_debug = 1 THEN
               debug('Get New Transactions ');
            END IF;

            IF l_upgrade_date IS NOT NULL THEN
                l_start_date := l_upgrade_date;
            ELSE
                l_start_date := l_profile_creation_date ;
            END IF;

            IF l_client_code IS NULL THEN
                BEGIN
                    FOR sel_new_rec IN sel_new_transactions(l_start_date, l_src_to_date, l_client_code)
                        LOOP
                            IF g_debug = 1 THEN
                                debug('In NEW sel_new_transactions for l_start_date, l_src_to_date, l_client_code -> '||l_start_date||', '||l_src_to_date||', '||l_client_code);
                            END IF;

                            inv_3pl_loc_pvt.update_locator_capacity(
                                x_return_status              => x_return_status
                                 , x_msg_count                  => x_msg_count
                                 , x_msg_data                   => x_msg_data
                                 , p_inventory_location_id      => sel_new_rec.locator_id
                                 , p_organization_id            => sel_new_rec.organization_id
                                 , p_client_code                => sel_new_rec.client_code
                                 , p_transaction_action_id      => sel_new_rec.transaction_action_id
                                 , p_quantity                   => sel_new_rec.primary_quantity
                                 , p_transaction_date           => sel_new_rec.creation_date
                                 );
                            IF x_return_status  <> fnd_api.g_ret_sts_success THEN
                                x_msg_data := fnd_message.get;
                                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Error =>  '||x_msg_data);

                                IF g_debug = 1 THEN
                                    debug('Error from update_locator_capacity - '||x_msg_data);
                                END IF;
                                l_success := FALSE;
                                RAISE ERROR_IN_PROGRAM;
                            END IF;

                        END LOOP;

                EXCEPTION
                    WHEN OTHERS THEN
                        IF g_debug = 1 THEN
                         debug(l_progress ||' : Got error while selecting new transactions');
                         debug(l_progress ||' : Error: '||SQLERRM);
                        END IF;
                        l_success := FALSE;
                        RAISE ERROR_IN_PROGRAM;
                END;
            ELSIF l_client_code IS NOT NULL THEN
                BEGIN
                    FOR sel_new_rec IN sel_ct_new_transactions(l_start_date, l_src_to_date, l_client_code)
                        LOOP
                            IF g_debug = 1 THEN
                                debug('In  sel_ct_new_transactions for l_start_date, l_src_to_date, l_client_code -> '||l_start_date||', '||l_src_to_date||', '||l_client_code);
                            END IF;

                            inv_3pl_loc_pvt.update_locator_capacity(
                                x_return_status              => x_return_status
                                 , x_msg_count                  => x_msg_count
                                 , x_msg_data                   => x_msg_data
                                 , p_inventory_location_id      => sel_new_rec.locator_id
                                 , p_organization_id            => sel_new_rec.organization_id
                                 , p_client_code                => sel_new_rec.client_code
                                 , p_transaction_action_id      => sel_new_rec.transaction_action_id
                                 , p_quantity                   => sel_new_rec.primary_quantity
                                 , p_transaction_date           => sel_new_rec.creation_date
                                 );
                            IF x_return_status  <> fnd_api.g_ret_sts_success THEN
                                x_msg_data := fnd_message.get;
                                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Error =>  '||x_msg_data);

                                IF g_debug = 1 THEN
                                    debug('Error from update_locator_capacity - '||x_msg_data);
                                END IF;
                                l_success := FALSE;
                                RAISE ERROR_IN_PROGRAM;
                            END IF;

                        END LOOP;

                EXCEPTION
                    WHEN OTHERS THEN
                        IF g_debug = 1 THEN
                         debug(l_progress ||' : Got error while selecting new transactions for Ct.');
                        debug(l_progress ||' : Error: '||SQLERRM);
                       END IF;
                       l_success := FALSE;
                       RAISE ERROR_IN_PROGRAM;
                END;
            END IF; /* if l_client_code is null */
        END IF; /* d_space_seeded_src_used > 0 */


       IF g_debug = 1 THEN
        debug('Get eligible Contracts ');
       END IF;
        IF p_OU_id IS NOT NULL THEN
               IF g_debug = 1 THEN
                debug('Set correct OU context');
               END IF;
            OKC_CONTEXT.set_okc_org_context( p_OU_id, NULL);
        END IF;

        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' ');
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '--------------------------------------------------------------------------------------------------------------------');
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '    Output Summary ');
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '--------------------------------------------------------------------------------------------------------------------');


        l_success := TRUE;
        d_sql_stmt := NULL;

        debug ('p_rule_id ->  '|| p_rule_id);
        debug ('p_contract_id ->  '|| p_contract_id);
        debug ('p_client_id ->  '|| p_client_id);
        debug ('p_item_id ->  '|| p_item_id);
        debug ('p_OU_id ->  '|| p_OU_id);

        d_sql_p               := DBMS_SQL.open_cursor;
        d_sql_stmt           :=
           'SELECT client_id, client_code, client_name, client_number, '
        || 'contract_id, contract_number, counter_item_id, '
        || 'last_computation_Date, net_Reading, last_reading, '
        || 'billing_uom, service_item_org_id, billing_source_id, '
        || 'billing_source_name, service_line_start_date, '
        || 'service_line_end_date '
        || 'FROM mtl_billing_rule_lines_v rules '
        || 'WHERE authoring_org_id IN ( SELECT organization_id '
        ||      'FROM hr_operating_units hr '
        ||      'WHERE '
        ||      'mo_global.check_access(hr.organization_id)=''Y'') '
        || 'AND EXISTS (SELECT 1 '
        || 'FROM mtl_service_contracts_v active_contracts '
        || 'WHERE active_contracts.id = rules.contract_id) '
        || 'AND :OU_id IN ( SELECT organization_id '
        ||      'FROM  hr_operating_units hr '
        ||      'WHERE '
        ||      'mo_global.check_access(hr.organization_id) = ''Y'') ';

       IF (p_rule_id is NOT NULL) THEN
            d_sql_stmt := d_sql_stmt || 'AND rules.billing_rule_header_id = :rule_id ';
        END IF;
        IF (p_contract_id is NOT NULL) THEN
            d_sql_stmt := d_sql_stmt || 'AND rules.contract_id = :contract_id ';
        END IF;
        IF (p_client_id is NOT NULL) THEN
            d_sql_stmt := d_sql_stmt || 'AND client_id = :client_id ';
        END IF;
        IF (p_item_id is NOT NULL) THEN
            d_sql_stmt := d_sql_stmt || 'AND inventory_item_id =:item_id ';
        END IF;

       IF g_debug = 1 THEN
        debug('Prepared statements for Contracts ');
       END IF;

        DBMS_SQL.parse(d_sql_p, d_sql_stmt, DBMS_SQL.native);
        DBMS_SQL.define_column(d_sql_p, 1, lc_client_id);
        DBMS_SQL.define_column(d_sql_p, 2, lc_client_code, 10);
        DBMS_SQL.define_column(d_sql_p, 3, lc_client_name, 360);
        DBMS_SQL.define_column(d_sql_p, 4, lc_client_number, 30);
        DBMS_SQL.define_column(d_sql_p, 5, lc_contract_id);
        DBMS_SQL.define_column(d_sql_p, 6, lc_contract_number, 120);
        DBMS_SQL.define_column(d_sql_p, 7, lc_counter_item_id);
        DBMS_SQL.define_column(d_sql_p, 8, lc_last_computation_Date);
        DBMS_SQL.define_column(d_sql_p, 9, lc_net_Reading);
        DBMS_SQL.define_column(d_sql_p, 10, lc_last_reading);
        DBMS_SQL.define_column(d_sql_p, 11, lc_billing_uom, 3);
        DBMS_SQL.define_column(d_sql_p, 12, lc_service_item_org_id, 200);
        DBMS_SQL.define_column(d_sql_p, 13, lc_billing_source_id);
        DBMS_SQL.define_column(d_sql_p, 14, lc_billing_source_name, 80);
        DBMS_SQL.define_column(d_sql_p, 15, lc_service_line_start_date);
        DBMS_SQL.define_column(d_sql_p, 16, lc_service_line_end_date);

       IF g_debug = 1 THEN
            debug('Bind the variables');
       END IF;

        DBMS_SQL.bind_variable(d_sql_p, 'OU_Id', p_OU_Id);
        IF (p_client_id is NOT NULL) THEN
            DBMS_SQL.bind_variable(d_sql_p, 'client_id', p_client_id);
        END IF;
        IF (p_rule_id is NOT NULL) THEN
            DBMS_SQL.bind_variable(d_sql_p, 'rule_id', p_rule_id);
        END IF;
        IF (p_contract_id is NOT NULL) THEN
            DBMS_SQL.bind_variable(d_sql_p, 'contract_id', p_contract_id);
        END IF;
        IF (p_item_id is NOT NULL) THEN
            DBMS_SQL.bind_variable(d_sql_p, 'item_id', p_item_id);
        END IF;
        d_sql_rows_processed  := DBMS_SQL.EXECUTE(d_sql_p);

       IF g_debug = 1 THEN
            debug('Fetched ref cursor');
       END IF;

        LOOP
          IF dbms_sql.fetch_rows(d_sql_p) = 0 THEN
             EXIT;
          END IF;

          dbms_sql.column_value(d_sql_p,1,v_client_id);
          dbms_sql.column_value(d_sql_p,2,v_client_code);
          dbms_sql.column_value(d_sql_p,3,v_client_name);
          dbms_sql.column_value(d_sql_p,4,v_client_number);
          dbms_sql.column_value(d_sql_p,5,v_contract_id);
          dbms_sql.column_value(d_sql_p,6,v_contract_number);
          dbms_sql.column_value(d_sql_p,7,v_counter_item_id);
          dbms_sql.column_value(d_sql_p,8,v_last_computation_Date);
          dbms_sql.column_value(d_sql_p,9,v_net_Reading);
          dbms_sql.column_value(d_sql_p,10,v_last_reading);
          dbms_sql.column_value(d_sql_p,11,v_billing_uom);
          dbms_sql.column_value(d_sql_p,12,v_service_item_org_id);
          dbms_sql.column_value(d_sql_p,13,v_billing_source_id);
          dbms_sql.column_value(d_sql_p,14,v_billing_source_name);
          dbms_sql.column_value(d_sql_p,15,v_service_line_start_date);
          dbms_sql.column_value(d_sql_p,16,v_service_line_end_date);

            BEGIN
                SAVEPOINT process_client;
                fnd_message.clear;

              /* Derive Client code, last invoice date, last interface date, last computation date, last updated counter value, last billed counter value, source to date, Billing UOM */
                l_progress := 10;
                OKC_CONTEXT.set_okc_org_context( v_service_item_org_id, NULL);
                IF g_debug = 1 THEN
                    debug('***************************************************************************');
                    debug(' Processing for Client code => '|| v_client_code );
                    debug('***************************************************************************');
                    debug(l_progress ||' : Client id        : '|| v_client_id);
                    debug(l_progress ||' : Client number    : '|| v_client_number);
                    debug(l_progress ||' : Client name      : '|| v_client_name);
                    debug(l_progress ||' : Contract id      : '|| v_contract_id);
                    debug(l_progress ||' : Contract number  : '|| v_contract_number);
                END IF;
                l_printed_in_outfile := 'N';
                    BEGIN
                        l_last_invoice_date := NULL;
                        l_last_interface_date  := NULL;
                      FOR invoice_rec IN cur_invoice_interface_details(v_contract_id)
                        LOOP
                            l_last_invoice_date     := invoice_rec.invoice_date;
                            l_last_interface_date   :=  invoice_rec.interface_date;
                        END LOOP;
                    EXCEPTION
                        WHEN OTHERS THEN
                               IF g_debug = 1 THEN
                                debug(l_progress ||' : Got error while fetching last invoice date, interface date');
                                debug(l_progress ||' : Error: '||SQLERRM);
                               END IF;
                            l_success := FALSE;
                            l_rec_failed := l_rec_failed +1;
                            RAISE ERROR_IN_PROGRAM;
                    END;

                    l_progress := 20;

                    IF g_debug = 1 THEN
                        debug(l_progress ||' : Fetched last invoice date, interface date ');
                        debug(l_progress ||' : l_last_invoice_date : '|| l_last_invoice_date);
                        debug(l_progress ||' : l_last_interface_date : '|| l_last_interface_date);
                        debug(l_progress ||' : v_last_computation_Date : '|| v_last_computation_Date);
                        debug(l_progress ||' : v_billing_source_id : '||v_billing_source_id);
                    END IF;

                    IF ( ( p_source_to_date IS NOT NULL)
                        AND (( SYSDATE > v_service_line_end_date) AND ( to_date(p_source_to_date, 'YYYY/MM/DD HH24:MI:SS') > v_service_line_end_date)) ) THEN
                        -- when run for date > service line end date
                        l_src_to_date := v_service_line_end_date;
                    END IF;

                    debug( 'l_src_to_date to be updated in PUB pl/sql-> '|| l_src_to_date);

                    l_counter_item_id           := v_counter_item_id;
                    l_meaning := NULL;

                    IF v_billing_source_id IS NOT NULL THEN
                        BEGIN
                            SELECT meaning
                            INTO l_meaning
                            FROM mtl_billing_sources_b blsrc, mfg_lookups lookup
                            WHERE billing_source_id = v_billing_source_id
                            AND
                            ( ( decode(blsrc.billing_source_code, 'C', lookup.lookup_type, NULL)  = 'MTL_3PL_CUSTOM_SOURCE')
                              OR  ( decode(blsrc.billing_source_code, 'S', lookup.lookup_type, NULL)  = 'MTL_3PL_SEEDED_SOURCE')
                            )
                            AND blsrc.procedure_code = lookup.lookup_code
                            AND lookup.lookup_type IN ('MTL_3PL_CUSTOM_SOURCE', 'MTL_3PL_SEEDED_SOURCE');

                        EXCEPTION
                            WHEN OTHERS THEN
                                l_success := FALSE;
                                l_rec_failed := l_rec_failed +1;
                                IF g_debug = 1 THEN
                                    debug('Could not get custom/seed procedure name due to error -> '||sqlerrm);
                                END IF;
                                ROLLBACK TO process_client;
                                GOTO next_contract_line;
                        END;
                    ELSE /* v_billing_source_id is not NULL */
                        -- no source attached to this line. No calculation.
                        l_success := TRUE;
                        l_printed_in_outfile := 'Y';
                        ROLLBACK TO process_client;
                        GOTO next_contract_line;
                    END IF;

                    IF g_debug = 1 THEN
                        debug(l_progress ||' : Procedure name : '||  l_meaning );
                        debug(l_progress ||' : l_counter_item_id : '||l_counter_item_id);
                        debug(l_progress ||' : last_computation_Date : '||v_last_computation_date);
                        debug(l_progress ||' : last_counter_reading : '||v_last_reading);
                        debug(l_progress ||' : l_counter_net_reading : '||v_net_Reading);
                        debug(l_progress ||' : l_service_line_start_date : '||v_service_line_start_date);
                    END IF;


                    l_progress := 30;
                    IF g_debug = 1 THEN
                        debug(l_progress ||' : Populate Global structure ');
                    END IF;

                    l_billing_source_rec.client_code            := v_client_code;
                    l_billing_source_rec.client_id              := v_client_id;
                    l_billing_source_rec.client_number          := v_client_number;
                    l_billing_source_rec.client_name            := v_client_name;
                    /* Added to_number for bug 9657044 */
                    l_billing_source_rec.operating_unit         := to_number(v_service_item_org_id);
                    l_billing_source_rec.last_invoice_date      := l_last_invoice_date;
                    l_billing_source_rec.last_interface_date    := l_last_interface_date;
                    l_billing_source_rec.billing_uom            := v_billing_uom;
                    l_billing_source_rec.last_reading           := v_net_Reading;
                    l_billing_source_rec.last_computation_Date  := v_last_computation_date;
                    l_billing_source_rec.service_line_start_date := v_service_line_start_date;
                    l_billing_source_rec.source_to_date         := l_src_to_date;

                  /* populating global structure */
                    IF INV_3PL_BILLING_PUB.set_billing_source_rec(l_billing_source_rec) THEN
                        l_progress := 40;
                        IF g_debug = 1 THEN
                            debug(l_progress ||' : Came back to Calculate Billing Units - Global structure returned true');
                        END IF;
                    END IF;
                    l_progress := 50;

                    IF g_debug = 1 THEN
                        debug(l_progress ||' : Get counter value to be updated for billing from custom procedure ');
                        -- GET THE READING (i.e. Number of units from custom or Seeded source)
                        debug('The PL/SQL to be executed  '||l_meaning);
                    END IF;

                    BEGIN
                        BEGIN
                            debug('In internal BEGIN -> '||l_meaning);
                            l_custom_reading := 0;
                            l_plsql_block := 'BEGIN '||l_meaning||'(:a, :b ); END;';
                            l_plsql_blk_failed := 'N';
                            EXECUTE IMMEDIATE l_plsql_block USING IN OUT l_custom_reading, IN OUT x_return_Status; --, IN OUT x_msg_count, IN OUT x_msg_data;
                            EXCEPTION
                                WHEN OTHERS THEN
                                    l_plsql_msg_data := sqlcode;
                                    IF SQLCODE = -6550 THEN
                                        l_plsql_msg_data := 'PL/SQL procedure -> ' || l_meaning ||' has some errors. Re-compile the procedure';
                                    END IF;
                                    l_success := FALSE;
                                    x_return_Status:= fnd_api.g_ret_sts_error;
                                    l_plsql_blk_failed := 'Y';
                        END;

                        IF g_debug = 1 THEN
                            debug('x_return_Status -> ' ||x_return_Status);
                        END IF;

                        IF x_return_Status = fnd_api.g_ret_sts_success THEN
                            IF g_debug = 1 THEN
                                debug(l_progress ||' : l_custom_reading from custom procedure => '||l_custom_reading );
                            END IF;
                        ELSIF x_return_Status IN  (fnd_api.g_ret_sts_error, fnd_api.g_ret_sts_unexp_error) THEN
                            l_success := FALSE;
                            l_rec_failed := l_rec_failed +1;
                            -- get the messages returned from seeded/custom source
                            l_plsql_blk_failed := 'Y';
                            IF x_return_status  <> fnd_api.g_ret_sts_success THEN
                                x_msg_data := fnd_message.get;
                                if x_msg_data IS NOT NULL THEN
                                    l_plsql_msg_data := x_msg_data;
                                end if;
                                IF g_debug = 1 THEN
                                    debug('Error - '||l_plsql_msg_data);
                                END IF;
                            END IF;

                            ROLLBACK TO process_client;
                            GOTO next_contract_line;
                        END IF;
                    END;
                    l_progress := 60;

                    IF g_debug = 1 THEN
                        debug(l_progress ||' : l_custom_reading => '||l_custom_reading );
                        debug(l_progress ||' : Now call IB api to update counter ');
                    END IF;
                    BEGIN
                       IF g_debug = 1 THEN
                        debug(l_progress ||' : Calculate Cumulative Counter reading ');
                       END IF;

                        l_custom_reading := nvl(l_custom_reading,0) + nvl(v_last_reading, 0);
                        IF g_debug = 1 THEN
                            debug(l_progress ||' : Cumulative Counter reading => '|| l_custom_reading);
                            debug(l_progress ||' : Counter reading > 0, updating ....... ');
                        END IF;

                        /* Added for bug 9657044 */
                        SELECT csi_transactions_s.NEXTVAL
                        INTO l_transaction_id
                        FROM dual;

                        inv_3pl_billing_counter_pvt.inv_insert_readings_using_api(
                        p_counter_id => l_counter_item_id,
                        p_count_date => l_src_to_date , p_new_reading=> l_custom_reading ,
                        p_net_reading => v_net_Reading,
                        p_transaction_id=> l_transaction_id);
                        /* Added l_transaction_id for bug 9657044 */

                        -- No need to print in outfile for successful record
                        l_printed_in_outfile := 'Y';

                    EXCEPTION
                        WHEN OTHERS THEN
                            l_success := FALSE;
                            l_rec_failed := l_rec_failed +1;
                            ROLLBACK TO process_client;
                            GOTO next_contract_line;
                    END;
                    l_progress := 70;

                    <<next_contract_line>>
                    l_progress := 80;

                    if l_printed_in_outfile = 'N'  THEN
                        IF NOT (l_success) THEN
                            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '--------------------------------------------------------------------------------------------------------------------');
                            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Could not update counter reading for the following combination ');
                            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '--------------------------------------------------------------------------------------------------------------------');
                            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '  Client id           : '|| v_client_id);
                            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '  Client number       : '|| v_client_number);
                            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '  Client name         : '|| v_client_name);
                            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '  Contract id         : '|| v_contract_id);
                            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '  Contract number     : '|| v_contract_number);
                            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '  Billing source name : '|| v_billing_source_name);

                            IF (l_plsql_blk_failed = 'Y') AND
                                    (x_return_status  <> fnd_api.g_ret_sts_success) THEN
                                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '  Error from custom/seeded source => '||l_plsql_msg_data);
                            END IF;
                            l_printed_in_outfile := 'Y';

                           IF g_debug = 1 THEN
                            debug(' ----------------------------------------------------------------------');
                            debug('Could not process current record, fetching next if any ');
                           END IF;
                        ELSE
                           IF g_debug = 1 THEN
                            debug('Processed record, fetching next');
                           END IF;
                        END IF;
                    ELSE
                       IF g_debug = 1 THEN
                        debug('Processed record, fetching next');
                       END IF;
                    END IF;
            END;
            l_progress := 90;
            IF g_debug = 1 THEN
                debug('Old number of l_rec_processed => '||l_rec_processed);
            END IF;
            l_rec_processed := l_rec_processed + 1;
            IF g_debug = 1 THEN
                debug('Records processed => '||l_rec_processed);
            END IF;
            COMMIT;
            IF g_debug = 1 THEN
                debug('Committed the current record');
            END IF;
     END LOOP; /* Main Contract Cursor */

    IF DBMS_SQL.is_open(d_sql_p) THEN
       DBMS_SQL.close_cursor(d_sql_p);
    END IF;
    RETCODE := 1;
    IF NOT (l_success) THEN

        l_ret := FND_CONCURRENT.SET_COMPLETION_STATUS('WARNING',ERRBUF);
    ELSE

        l_ret := FND_CONCURRENT.SET_COMPLETION_STATUS('NORMAL',ERRBUF);
    END IF;

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' ');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '--------------------------------------------------------------------------------------------------------------------');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '    SUMMARY OF PROCESSING ');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '--------------------------------------------------------------------------------------------------------------------');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '        Total Records processed -> '|| l_rec_processed);
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '        Number of records failed -> '|| l_rec_failed);

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '        Number of records processed successfully -> '|| to_char(l_rec_processed - l_rec_failed));

    debug(l_progress ||' : Completed Execution ');
    RETURN;

    EXCEPTION
        WHEN ERROR_IN_PROGRAM THEN
            IF DBMS_SQL.is_open(d_sql_p) THEN
            DBMS_SQL.close_cursor(d_sql_p);
            END IF;
            RETCODE := 2;
            IF g_debug = 1 THEN
                debug('Error occurred - '||SQLERRM);
            END IF;
            l_ret := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',ERRBUF);
            ROLLBACK;
            RETURN;
        WHEN OTHERS THEN
            IF DBMS_SQL.is_open(d_sql_p) THEN
               DBMS_SQL.close_cursor(d_sql_p);
            END IF;
            RETCODE := 2;
            IF g_debug = 1 THEN
                debug(' Unexpected error occurred => '||SQLERRM);
            END IF;
            l_ret := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',ERRBUF);
            ROLLBACK;
            RETURN;

    END CALCULATE_BILLING_UNITS;

END INV_3PL_BILLING_UNITS_PVT;


/
