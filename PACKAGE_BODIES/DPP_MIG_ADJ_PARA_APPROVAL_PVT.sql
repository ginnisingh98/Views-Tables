--------------------------------------------------------
--  DDL for Package Body DPP_MIG_ADJ_PARA_APPROVAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."DPP_MIG_ADJ_PARA_APPROVAL_PVT" AS
/* $Header: dppmigsb.pls 120.0.12010000.6 2009/07/28 07:18:24 anbbalas noship $ */

G_PKG_NAME      CONSTANT VARCHAR2(30) := 'DPP_MIG_ADJ_PARA_APPROVAL_PVT';
G_DEBUG         BOOLEAN               := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_high);
G_FILE_NAME     CONSTANT VARCHAR2(14) := 'dppmigsb.pls';

    ---------------------------------------------------------------------
    -- PROCEDURE
    --    checkMigrationCompletion
    --
    -- PURPOSE
    --    This procedure checks if the migration has already been
    --  completed successfully. If so, it will terminate.
    --
    -- PARAMETERS
    --
    -- NOTES
    --
    ----------------------------------------------------------------------
    PROCEDURE checkMigrationCompletion
    (           p_api_version        IN NUMBER
              , p_init_msg_list      IN VARCHAR2 := fnd_api.g_false
              , p_commit             IN VARCHAR2 := fnd_api.g_false
              , p_validation_level   IN NUMBER   := fnd_api.g_valid_level_full
              , x_return_status      OUT nocopy VARCHAR2
              , x_msg_count          OUT nocopy NUMBER
              , x_msg_data           OUT nocopy VARCHAR2
    )
    AS
        l_api_name    constant  VARCHAR2(30) := 'checkMigrationCompletion';
        l_api_version constant  NUMBER       := 1.0;
        l_full_name   constant  VARCHAR2(60) := g_pkg_name || '.' || l_api_name;

        l_return_status     VARCHAR2(30);
        l_msg_count         NUMBER;
        l_msg_data          VARCHAR2(4000);

        l_txn_count         NUMBER;

        --Cursor to check if there are transactions with no entries in the dpp_execution_processes table
        CURSOR validTransactionsCur
        IS
        SELECT count(1)
        FROM dpp_transaction_headers_all dpp
        WHERE NOT EXISTS
          (SELECT dep.transaction_header_id
          FROM dpp_execution_processes dep
          WHERE dep.transaction_header_id = dpp.transaction_header_id);


    BEGIN
        IF Fnd_Api.to_boolean(p_init_msg_list) THEN
            Fnd_Msg_Pub.initialize;
        END IF;

        IF NOT Fnd_Api.compatible_api_call ( l_api_version,
                                             p_api_version,
                                             l_api_name,
                                             g_pkg_name
        )
        THEN
            RAISE Fnd_Api.g_exc_unexpected_error;
        END IF;

        -- Initialize API return status to sucess
        x_return_status := fnd_api.g_ret_sts_success;

        IF G_DEBUG THEN
          fnd_file.put_line(fnd_file.log, ' Begin checkMigrationCompletion ' );
        END IF;

        OPEN validTransactionsCur;
        FETCH validTransactionsCur INTO l_txn_count;
        CLOSE validTransactionsCur;

        fnd_file.put_line(fnd_file.log, ' Transactions with no entries in the dpp_execution_processes table - ' || l_txn_count );

        IF l_txn_count = 0 THEN
          IF G_DEBUG THEN
             fnd_file.put_line(fnd_file.log, ' Migration has already been performed. ' );
          END IF;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
    EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_msg_data := fnd_message.get_string('DPP','DPP_MIG_COMPLETED_ERR');

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
        );
        IF x_msg_count > 1 THEN
            FOR I IN 1..x_msg_count LOOP
               x_msg_data := SUBSTR((x_msg_data ||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
            END LOOP;
        END IF;

     WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
        fnd_message.set_token('ROUTINE', 'DPP_MIG_ADJ_PARA_APPROVAL_PVT.checkMigrationCompletion');
        fnd_message.set_token('ERRNO', sqlcode);
        fnd_message.set_token('REASON', sqlerrm);
        FND_MSG_PUB.add;

        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
        );
        IF x_msg_count > 1 THEN
            FOR I IN 1..x_msg_count LOOP
               x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
            END LOOP;
        END IF;

    END checkMigrationCompletion;

    ---------------------------------------------------------------------
    -- PROCEDURE
    --    validate_suppTradeProfile
    --
    -- PURPOSE
    --    This procedure checks for the existence of the supplier trade profile
    --  for the supplier and supplier site for the operating unit
    --
    -- PARAMETERS
    --
    -- NOTES
    --
    ----------------------------------------------------------------------
    PROCEDURE validate_suppTradeProfile
    (           p_api_version        IN NUMBER
              , p_init_msg_list      IN VARCHAR2 := fnd_api.g_false
              , p_commit             IN VARCHAR2 := fnd_api.g_false
              , p_validation_level   IN NUMBER   := fnd_api.g_valid_level_full
              , x_return_status      OUT nocopy VARCHAR2
              , x_msg_count          OUT nocopy NUMBER
              , x_msg_data           OUT nocopy VARCHAR2
    )
    AS
        l_api_name    constant  VARCHAR2(30) := 'validate_suppTradeProfile';
        l_api_version constant  NUMBER       := 1.0;
        l_full_name   constant  VARCHAR2(60) := g_pkg_name || '.' || l_api_name;

        l_return_status     VARCHAR2(30);
        l_msg_count         NUMBER;
        l_msg_data          VARCHAR2(4000);

        l_vendor_id         NUMBER;
        l_vendor_name       VARCHAR2(240);
        l_vendor_site_id    NUMBER;
        l_vendor_site_code  VARCHAR2(15);
        l_org_id            NUMBER;
        l_operating_unit    VARCHAR2(240);

        l_setup_missing     VARCHAR2(1) := 'N';

        --Cursor to fetch suppliers without supplier trade profile setup
        CURSOR suppTradeProfile_Cur
        IS
        select distinct vendor_id, vendor_site_id, org_id
          from dpp_transaction_headers_all dtha
          where not exists (select supp_trade_profile_id
                            from ozf_supp_trd_prfls_all ostpa
                            where ostpa.supplier_id = dtha.vendor_id
                              and ostpa.supplier_site_id = dtha.vendor_site_id
                              and ostpa.org_id = dtha.org_id);

         --Cursor to fetch supplier details
         CURSOR supplier_details_cur(p_vendor_id IN NUMBER, p_vendor_site_id IN NUMBER, p_org_id IN NUMBER)
         IS
         select aps.vendor_id, aps.vendor_name, apss.vendor_site_id, apss.vendor_site_code,
                apss.org_id, hr.name
          from ap_suppliers aps, ap_supplier_sites_all apss, hr_operating_units hr
          where aps.vendor_id = p_vendor_id
          and aps.vendor_id = apss.vendor_id
          and apss.vendor_site_id = p_vendor_site_id
          and apss.org_id = p_org_id
          and apss.org_id = hr.organization_id;


    BEGIN
        IF Fnd_Api.to_boolean(p_init_msg_list) THEN
            Fnd_Msg_Pub.initialize;
        END IF;

        IF NOT Fnd_Api.compatible_api_call ( l_api_version,
                                             p_api_version,
                                             l_api_name,
                                             g_pkg_name
        )
        THEN
            RAISE Fnd_Api.g_exc_unexpected_error;
        END IF;

        -- Initialize API return status to sucess
        x_return_status := fnd_api.g_ret_sts_success;

        IF G_DEBUG THEN
          fnd_file.put_line(fnd_file.log, ' Begin validate_suppTradeProfile ' );
        END IF;

        FOR suppTradeProfile_rec IN suppTradeProfile_Cur
        LOOP
          l_setup_missing := 'Y';
          OPEN supplier_details_cur(suppTradeProfile_rec.vendor_id,
                                    suppTradeProfile_rec.vendor_site_id,
                                    suppTradeProfile_rec.org_id);
          FETCH supplier_details_cur INTO l_vendor_id, l_vendor_name,
                                          l_vendor_site_id, l_vendor_site_code,
                                          l_org_id, l_operating_unit;
          CLOSE supplier_details_cur;

          fnd_file.put_line(fnd_file.log, ' Supplier Trade Profile setup not available for ' );
          fnd_file.put_line(fnd_file.log, '   Supplier - ' || l_vendor_name || ' (' || l_vendor_id || ')' );
          fnd_file.put_line(fnd_file.log, '   Supplier Site - ' || l_vendor_site_code || ' (' || l_vendor_site_id || ')' );
          fnd_file.put_line(fnd_file.log, '   Operating Unit - ' || l_operating_unit || ' (' || l_org_id || ')' );

        END LOOP;

        IF l_setup_missing = 'Y' THEN
          fnd_file.put_line(fnd_file.log, ' Please perform the Supplier Trade Profile setup. ' );
          RAISE FND_API.G_EXC_ERROR;
        END IF;
    EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
        );
        IF x_msg_count > 1 THEN
            FOR I IN 1..x_msg_count LOOP
               x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
            END LOOP;
        END IF;

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
        );
        IF x_msg_count > 1 THEN
            FOR I IN 1..x_msg_count LOOP
               x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
            END LOOP;
        END IF;

     WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
        fnd_message.set_token('ROUTINE', 'DPP_MIG_ADJ_PARA_APPROVAL_PVT.validate_suppTradeProfile');
        fnd_message.set_token('ERRNO', sqlcode);
        fnd_message.set_token('REASON', sqlerrm);
        FND_MSG_PUB.add;

     -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
        );
        IF x_msg_count > 1 THEN
            FOR I IN 1..x_msg_count LOOP
               x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
            END LOOP;
        END IF;

    END validate_suppTradeProfile;

    ---------------------------------------------------------------------
    -- PROCEDURE
    --    validate_execProcessSetup
    --
    -- PURPOSE
    --    This procedure checks for the existence of the price protection
    --  execution process setup at the system parameters in Trade Management
    --
    -- PARAMETERS
    --
    -- NOTES
    --
    ----------------------------------------------------------------------
    PROCEDURE validate_execProcessSetup
    (           p_api_version        IN NUMBER
              , p_init_msg_list      IN VARCHAR2 := fnd_api.g_false
              , p_commit             IN VARCHAR2 := fnd_api.g_false
              , p_validation_level   IN NUMBER   := fnd_api.g_valid_level_full
              , x_return_status      OUT nocopy VARCHAR2
              , x_msg_count          OUT nocopy NUMBER
              , x_msg_data           OUT nocopy VARCHAR2
    )
    AS
        l_api_name    constant  VARCHAR2(30) := 'validate_execProcessSetup';
        l_api_version constant  NUMBER       := 1.0;
        l_full_name   constant  VARCHAR2(60) := g_pkg_name || '.' || l_api_name;

        l_return_status     VARCHAR2(30);
        l_msg_count         NUMBER;
        l_msg_data          VARCHAR2(4000);

        l_count             NUMBER := 0;
        l_org_id            NUMBER;
        l_operating_unit    VARCHAR2(240);
        l_setup_missing     VARCHAR2(1) := 'N';

        --Cursor to fetch distinct operating unit
        CURSOR orgId_Cur
        IS
        SELECT DISTINCT org_id
        FROM dpp_transaction_headers_all;

        --Cursor to check if the execution process setup exists at the system parameters
        CURSOR get_process_setup_cnt_csr (p_org_id NUMBER)
        IS
        SELECT COUNT(1)
        FROM ozf_process_setup_all
        WHERE nvl(supp_trade_profile_id,0) = 0
        AND enabled_flag = 'Y'
        AND org_id = p_org_id;

        --Cursor to fetch the operating unit name
        CURSOR operating_unit_cur(p_org_id IN NUMBER)
        IS
        select hr.name
         from hr_operating_units hr
         where hr.organization_id = p_org_id;

    BEGIN
        IF Fnd_Api.to_boolean(p_init_msg_list) THEN
            Fnd_Msg_Pub.initialize;
        END IF;

        IF NOT Fnd_Api.compatible_api_call ( l_api_version,
                                             p_api_version,
                                             l_api_name,
                                             g_pkg_name
        )
        THEN
            RAISE Fnd_Api.g_exc_unexpected_error;
        END IF;

        -- Initialize API return status to sucess
        x_return_status := fnd_api.g_ret_sts_success;

        IF G_DEBUG THEN
          fnd_file.put_line(fnd_file.log, ' Begin validate_execProcessSetup ' );
        END IF;

        FOR orgId_rec IN orgId_Cur
        LOOP
          l_org_id := orgId_rec.org_id;
          OPEN get_process_setup_cnt_csr(l_org_id);
          FETCH get_process_setup_cnt_csr INTO l_count;
          CLOSE get_process_setup_cnt_csr;

          IF G_DEBUG THEN
             fnd_file.put_line(fnd_file.log, ' No of execution processes enabled for the org ' || l_org_id || ' is ' || l_count );
          END IF;

          IF l_count = 0 THEN
            OPEN operating_unit_cur(l_org_id);
            FETCH operating_unit_cur INTO l_operating_unit;
            CLOSE operating_unit_cur;

            l_setup_missing := 'Y';

            fnd_file.put_line(fnd_file.log, ' Execution Process setup not available for Operating Unit - ' || l_operating_unit || ' (' || l_org_id || ')' );
          END IF;

        END LOOP;

        IF l_setup_missing = 'Y' THEN
          IF G_DEBUG THEN
             fnd_file.put_line(fnd_file.log, ' Please perform the Execution Process setup. ' );
          END IF;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
    EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_msg_data := fnd_message.get_string('DPP','DPP_PROCESS_SETUP_MISSING_ERR');

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
        );
        IF x_msg_count > 1 THEN
            FOR I IN 1..x_msg_count LOOP
               x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
            END LOOP;
        END IF;

     WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
        fnd_message.set_token('ROUTINE', 'DPP_MIG_ADJ_PARA_APPROVAL_PVT.validate_execProcessSetup');
        fnd_message.set_token('ERRNO', sqlcode);
        fnd_message.set_token('REASON', sqlerrm);
        FND_MSG_PUB.add;

     -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
        );
        IF x_msg_count > 1 THEN
            FOR I IN 1..x_msg_count LOOP
               x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
            END LOOP;
        END IF;

    END validate_execProcessSetup;

    ---------------------------------------------------------------------
    -- PROCEDURE
    --    insertExecutionProcesses
    --
    -- PURPOSE
    --    This procedure inserts records into the DPP_EXECUTION_PROCESSES
    --  for those transactions for which the entries does not exist. Entires
    --  are based on either supplier trade profile or system parameters
    --  in Trade Management.
    --
    -- PARAMETERS
    --
    -- NOTES
    --
    ----------------------------------------------------------------------
    PROCEDURE insertExecutionProcesses
    (           p_api_version        IN NUMBER
              , p_init_msg_list      IN VARCHAR2 := fnd_api.g_false
              , p_commit             IN VARCHAR2 := fnd_api.g_false
              , p_validation_level   IN NUMBER   := fnd_api.g_valid_level_full
              , x_return_status      OUT nocopy VARCHAR2
              , x_msg_count          OUT nocopy NUMBER
              , x_msg_data           OUT nocopy VARCHAR2
    )
    AS
        l_api_name    constant  VARCHAR2(30) := 'insertExecutionProcesses';
        l_api_version constant  NUMBER       := 1.0;
        l_full_name   constant  VARCHAR2(60) := g_pkg_name || '.' || l_api_name;

        l_return_status     VARCHAR2(30);
        l_msg_count         NUMBER;
        l_msg_data          VARCHAR2(4000);

        l_user_id 	    NUMBER := FND_GLOBAL.USER_ID;
        l_login_id 	    NUMBER := FND_GLOBAL.CONC_LOGIN_ID;

        l_transaction_header_id  NUMBER;
        l_supp_trade_profile_id  NUMBER;
        l_org_id                 NUMBER;

        l_count		         NUMBER := 0;

        TYPE ProcessCodeTab IS TABLE OF DPP_EXECUTION_PROCESSES.PROCESS_CODE%TYPE INDEX BY PLS_INTEGER;
        process_codes            ProcessCodeTab;

        --Cursor to fetch those transactions with no entries in the dpp_execution_processes table
        CURSOR get_valid_transaction_csr
        IS
        SELECT transaction_header_id
        FROM dpp_transaction_headers_all dpp
        WHERE NOT EXISTS
          (SELECT dep.transaction_header_id
          FROM dpp_execution_processes dep
          WHERE dep.transaction_header_id = dpp.transaction_header_id);

       --Cursor to retrieve the supplier trade profile id and org_id
       CURSOR get_supp_trd_prfl_csr (p_transaction_header_id NUMBER)
       IS
       SELECT ostpa.supp_trade_profile_id, dtha.org_id
         FROM dpp_transaction_headers_all dtha, ozf_supp_trd_prfls_all ostpa
         WHERE dtha.transaction_header_id = p_transaction_header_id
         AND dtha.vendor_id = ostpa.supplier_id
         AND dtha.vendor_site_id = ostpa.supplier_site_id
         AND dtha.org_id = ostpa.org_id;

        --Cursor to check if the execution process setup is available either at Supplier Trade Profile or System Parameters
        CURSOR get_process_setup_cnt_csr (p_supp_trade_profile_id NUMBER, p_org_id NUMBER)
        IS
          SELECT COUNT(1)
          FROM OZF_PROCESS_SETUP_ALL
          WHERE nvl(supp_trade_profile_id,0) = nvl(p_supp_trade_profile_id,0)
          AND enabled_flag = 'Y'
          AND org_id = p_org_id;

        --Cursor to fetch the processes either at supplier trade profile or system parameters
        CURSOR get_process_codes_csr (p_supp_trd_prf_id NUMBER, p_org_id NUMBER)
        IS
        SELECT dppl.lookup_code
          FROM dpp_lookups dppl,
              ozf_process_setup_all opsa
          WHERE dppl.lookup_type = 'DPP_EXECUTION_PROCESSES'
          AND dppl.tag is not null
          AND nvl(opsa.supp_trade_profile_id,0) = nvl(p_supp_trd_prf_id,0)
          AND opsa.enabled_flag = 'Y'
          AND opsa.org_id = p_org_id
          AND dppl.lookup_code = opsa.process_code;

    BEGIN
        IF Fnd_Api.to_boolean(p_init_msg_list) THEN
            Fnd_Msg_Pub.initialize;
        END IF;

        IF NOT Fnd_Api.compatible_api_call ( l_api_version,
                                             p_api_version,
                                             l_api_name,
                                             g_pkg_name
        )
        THEN
            RAISE Fnd_Api.g_exc_unexpected_error;
        END IF;

        -- Initialize API return status to sucess
        x_return_status := fnd_api.g_ret_sts_success;

        IF G_DEBUG THEN
          fnd_file.put_line(fnd_file.log, ' Begin insertExecutionProcesses ' );
        END IF;

        FOR get_valid_transaction_rec IN get_valid_transaction_csr
        LOOP
          --Get the supplier trade profile id and org id.
          BEGIN
            l_transaction_header_id := get_valid_transaction_rec.transaction_header_id;
            OPEN get_supp_trd_prfl_csr(l_transaction_header_id);
            FETCH get_supp_trd_prfl_csr INTO l_supp_trade_profile_id, l_org_id;
            CLOSE get_supp_trd_prfl_csr;

            IF G_DEBUG THEN
              fnd_file.put_line(fnd_file.log, ' Supplier Trade Profile Id: ' || l_supp_trade_profile_id  );
              fnd_file.put_line(fnd_file.log, ' Org Id: ' || l_org_id  );
            END IF;
          EXCEPTION
            WHEN OTHERS THEN
              fnd_file.put_line(fnd_file.log,'Exception while fetching supplier trade profile id and org id: ' || SQLERRM);
              fnd_file.new_line(fnd_file.log);
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END;

          --Check if the Process Setup is done for the Supplier, Supplier site and Operating Unit
          BEGIN
            OPEN get_process_setup_cnt_csr(l_supp_trade_profile_id, l_org_id);
            FETCH get_process_setup_cnt_csr INTO l_count;
            CLOSE get_process_setup_cnt_csr;

            IF l_count = 0 THEN	--Process Setup does not exist for the Supplier Trade Profile
              l_supp_trade_profile_id := null;
              IF G_DEBUG THEN
                fnd_file.put_line(fnd_file.log, ' Process Setup does not exist for ' );
                fnd_file.put_line(fnd_file.log, '     Supplier Trade Profile Id: ' || l_supp_trade_profile_id  );
                fnd_file.put_line(fnd_file.log, '     Org Id: ' || l_org_id  );
              END IF;
            END IF;
          EXCEPTION
            WHEN OTHERS THEN
              fnd_file.put_line(fnd_file.log,'Exception while checking if the process setup exists: ' || SQLERRM);
              fnd_file.new_line(fnd_file.log);
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END;

          --Get the process code either from either supplier trade profile or system parameters
          BEGIN
            OPEN get_process_codes_csr(l_supp_trade_profile_id,l_org_id);
              FETCH get_process_codes_csr BULK COLLECT INTO process_codes;
              FORALL idx IN 1..process_codes.COUNT
               --Insert the Process codes into the DPP_EXECUTION_PROCESSES table
               INSERT INTO DPP_EXECUTION_PROCESSES (process_code,
                                              transaction_header_id,
                                              created_by,
                                              creation_date,
                                              last_updated_by,
                                              last_update_date,
                                              last_update_login
               )
               VALUES (process_codes(idx),
                      l_transaction_header_id,
                      l_user_id,
                      sysdate,
                      l_user_id,
                      sysdate,
                      l_login_id
               );
            CLOSE get_process_codes_csr;
          EXCEPTION
            WHEN OTHERS THEN
              fnd_file.put_line(fnd_file.log,'Exception while fetching the process code and inserting into DPP_EXECUTION_PROCESSES: ' || SQLERRM);
              fnd_file.new_line(fnd_file.log);
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END;
        END LOOP;

    EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
        );
        IF x_msg_count > 1 THEN
            FOR I IN 1..x_msg_count LOOP
               x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
            END LOOP;
        END IF;

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
        );
        IF x_msg_count > 1 THEN
            FOR I IN 1..x_msg_count LOOP
               x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
            END LOOP;
        END IF;

     WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
        fnd_message.set_token('ROUTINE', 'DPP_MIG_ADJ_PARA_APPROVAL_PVT.insertExecutionProcesses');
        fnd_message.set_token('ERRNO', sqlcode);
        fnd_message.set_token('REASON', sqlerrm);
        FND_MSG_PUB.add;

        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
        );
        IF x_msg_count > 1 THEN
            FOR I IN 1..x_msg_count LOOP
               x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
            END LOOP;
        END IF;

  END insertExecutionProcesses;

  ---------------------------------------------------------------------
  -- PROCEDURE
  --    clearAllApprovals
  --
  -- PURPOSE
  --    This procedure fetches all the futured dated transactions in
  --	APPROVED, REJECTED and PENDING_APPROVAL status. All such
  --    transactions will be updated ACTIVE status. Further, entries in
  --    the DPP_APPROVAL_ACCESS and AME_TEMP_OLD_APPROVER_LISTS tables
  --    corresponding to all such transactions will be deleted.
  --
  -- PARAMETERS
  --
  -- NOTES
  --
  ----------------------------------------------------------------------
  PROCEDURE clearAllApprovals
  (           p_api_version        IN NUMBER
            , p_init_msg_list      IN VARCHAR2 := fnd_api.g_false
            , p_commit             IN VARCHAR2 := fnd_api.g_false
            , p_validation_level   IN NUMBER   := fnd_api.g_valid_level_full
            , x_return_status      OUT nocopy VARCHAR2
            , x_msg_count          OUT nocopy NUMBER
            , x_msg_data           OUT nocopy VARCHAR2
  )
  AS
      l_api_name    constant  VARCHAR2(30) := 'clearAllApprovals';
      l_api_version constant  NUMBER       := 1.0;
      l_full_name   constant  VARCHAR2(60) := g_pkg_name || '.' || l_api_name;

      l_return_status         VARCHAR2(30);
      l_msg_count             NUMBER;
      l_msg_data              VARCHAR2(4000);

      l_application_id        NUMBER := 9000;
      l_transaction_type      VARCHAR2(30) := 'PRICE PROTECTION';
      l_transaction_header_id VARCHAR2(50);
      l_transaction_number    VARCHAR2(40);

      --Cursor to fetch the future dated transactions in APPROVED, REJECTED and PENDING_APPROVAL status.
      CURSOR validTransactionsCur
      IS
      select transaction_header_id, transaction_number
        from dpp_transaction_headers_all
        where transaction_status IN ( 'APPROVED' , 'REJECTED' , 'PENDING_APPROVAL' )
        and trunc(effective_start_date) > trunc(sysdate);

  BEGIN
      IF Fnd_Api.to_boolean(p_init_msg_list) THEN
          Fnd_Msg_Pub.initialize;
      END IF;

      IF NOT Fnd_Api.compatible_api_call ( l_api_version,
                                           p_api_version,
                                           l_api_name,
                                           g_pkg_name
      )
      THEN
          RAISE Fnd_Api.g_exc_unexpected_error;
      END IF;

      -- Initialize API return status to sucess
      x_return_status := fnd_api.g_ret_sts_success;

      IF G_DEBUG THEN
        fnd_file.put_line(fnd_file.log, ' Begin clearAllApprovals ' );
      END IF;

      BEGIN
	--Delete the approval access
	delete from dpp_approval_access
	where object_id in ( select transaction_header_id
	                     from dpp_transaction_headers_all
			     where transaction_status IN ( 'APPROVED' , 'REJECTED' , 'PENDING_APPROVAL' )
			     and trunc(effective_start_date) > trunc(sysdate) );

	IF G_DEBUG THEN
	   fnd_file.put_line(fnd_file.log, ' Transactions approval entries have been deleted from DPP_APPROVAL_ACCESS' );
        END IF;

      EXCEPTION
	WHEN OTHERS THEN
 	  fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
          fnd_message.set_token('ROUTINE', 'DPP_MIG_ADJ_PARA_APPROVAL_PVT.clearAllApprovals');
          fnd_message.set_token('ERRNO', sqlcode);
	  fnd_message.set_token('REASON', sqlerrm);
	  fnd_msg_pub.add;
	  RAISE fnd_api.g_exc_unexpected_error;
      END;

      FOR validTransactionsRec IN validTransactionsCur
      LOOP
	     l_transaction_header_id := validTransactionsRec.transaction_header_id;
	     l_transaction_number := validTransactionsRec.transaction_number;

        BEGIN
          --Clear the approvals in AME
          ame_api2.clearAllApprovals(l_application_id, l_transaction_type, l_transaction_header_id);
          IF G_DEBUG THEN
	     fnd_file.put_line(fnd_file.log, ' Clear All Approvals from AME for the transaction ' || l_transaction_number );
          END IF;

	EXCEPTION
	  WHEN OTHERS THEN
	     fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
	     fnd_message.set_token('ROUTINE', 'DPP_MIG_ADJ_PARA_APPROVAL_PVT.clearAllApprovals');
	     fnd_message.set_token('ERRNO', sqlcode);
	     fnd_message.set_token('REASON', sqlerrm);
	     FND_MSG_PUB.add;
	     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END;
      END LOOP;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count   => x_msg_count,
          p_data    => x_msg_data
      );
      IF x_msg_count > 1 THEN
          FOR I IN 1..x_msg_count LOOP
             x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
          END LOOP;
      END IF;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
      );
      IF x_msg_count > 1 THEN
          FOR I IN 1..x_msg_count LOOP
             x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
          END LOOP;
      END IF;

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
      fnd_message.set_token('ROUTINE', 'DPP_MIG_ADJ_PARA_APPROVAL_PVT.clearAllApprovals');
      fnd_message.set_token('ERRNO', sqlcode);
      fnd_message.set_token('REASON', sqlerrm);
      FND_MSG_PUB.add;

      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
      );
      IF x_msg_count > 1 THEN
          FOR I IN 1..x_msg_count LOOP
             x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
          END LOOP;
      END IF;

  END clearAllApprovals;

    ---------------------------------------------------------------------
    -- PROCEDURE
    --    update_status
    --
    -- PURPOSE
    --    This procedure updates the status of the transactions
    --
    -- PARAMETERS
    --
    -- NOTES
    --
    ----------------------------------------------------------------------
    PROCEDURE update_status
    (           p_api_version        IN NUMBER
              , p_init_msg_list      IN VARCHAR2 := fnd_api.g_false
              , p_commit             IN VARCHAR2 := fnd_api.g_false
              , p_validation_level   IN NUMBER   := fnd_api.g_valid_level_full
              , x_return_status      OUT nocopy VARCHAR2
              , x_msg_count          OUT nocopy NUMBER
              , x_msg_data           OUT nocopy VARCHAR2
    )
    AS
        l_api_name    constant  VARCHAR2(30) := 'update_status';
        l_api_version constant  NUMBER       := 1.0;
        l_full_name   constant  VARCHAR2(60) := g_pkg_name || '.' || l_api_name;

        l_user_id                  NUMBER := FND_GLOBAL.USER_ID;
        l_login_id                 NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
        l_request_id               NUMBER := FND_GLOBAL.CONC_REQUEST_ID;
        l_program_application_id   NUMBER := FND_GLOBAL.PROG_APPL_ID;
        l_program_id               NUMBER := FND_GLOBAL.CONC_PROGRAM_ID;

        l_return_status     VARCHAR2(30);
        l_msg_count         NUMBER;
        l_msg_data          VARCHAR2(4000);

    BEGIN
        IF Fnd_Api.to_boolean(p_init_msg_list) THEN
            Fnd_Msg_Pub.initialize;
        END IF;

        IF NOT Fnd_Api.compatible_api_call ( l_api_version,
                                             p_api_version,
                                             l_api_name,
                                             g_pkg_name
        )
        THEN
            RAISE Fnd_Api.g_exc_unexpected_error;
        END IF;

        -- Initialize API return status to sucess
        x_return_status := fnd_api.g_ret_sts_success;

        IF G_DEBUG THEN
          fnd_file.put_line(fnd_file.log, ' Begin update_status ' );
        END IF;

        UPDATE dpp_transaction_headers_all
          SET transaction_status = 'APPROVED',
          object_version_number = object_version_number +1,
          last_updated_by = l_user_id,
          last_update_date = sysdate,
          last_update_login = l_login_id,
          request_id = l_request_id,
          program_application_id = l_program_application_id,
          program_id = l_program_id,
          program_update_date = sysdate
          WHERE transaction_status = 'ACTIVE';

        fnd_file.put_line(fnd_file.log, ' No of transactions from ACTIVE to APPROVED: ' || SQL%ROWCOUNT );

        UPDATE dpp_transaction_headers_all
          SET transaction_status = 'PENDING_ADJUSTMENT',
          object_version_number = object_version_number +1,
          last_updated_by = l_user_id,
          last_update_date = sysdate,
          last_update_login = l_login_id,
          request_id = l_request_id,
          program_application_id = l_program_application_id,
          program_id = l_program_id,
          program_update_date = sysdate
          WHERE transaction_status = 'NEW'
          AND TRUNC(effective_start_date) <= TRUNC(SYSDATE);

        fnd_file.put_line(fnd_file.log, ' No of transactions from NEW to PENDING_ADJUSTMENT: ' || SQL%ROWCOUNT );

        UPDATE dpp_transaction_headers_all
          SET transaction_status = 'ACTIVE',
          object_version_number = object_version_number +1,
          last_updated_by = l_user_id,
          last_update_date = sysdate,
          last_update_login = l_login_id,
          request_id = l_request_id,
          program_application_id = l_program_application_id,
          program_id = l_program_id,
          program_update_date = sysdate
          WHERE transaction_status = 'NEW'
          AND TRUNC(effective_start_date) > TRUNC(SYSDATE);

        fnd_file.put_line(fnd_file.log, ' No of transactions from NEW to ACTIVE: ' || SQL%ROWCOUNT );

        UPDATE dpp_transaction_headers_all
          SET transaction_status = 'ACTIVE',
          object_version_number = object_version_number +1,
          last_updated_by = l_user_id,
          last_update_date = sysdate,
          last_update_login = l_login_id,
          request_id = l_request_id,
          program_application_id = l_program_application_id,
          program_id = l_program_id,
          program_update_date = sysdate
          WHERE transaction_status = 'APPROVED'
          AND TRUNC(effective_start_date) > TRUNC(SYSDATE);

        fnd_file.put_line(fnd_file.log, ' No of transactions from APPROVED to ACTIVE: ' || SQL%ROWCOUNT );

        UPDATE dpp_transaction_headers_all
          SET transaction_status = 'ACTIVE',
          object_version_number = object_version_number +1,
          last_updated_by = l_user_id,
          last_update_date = sysdate,
          last_update_login = l_login_id,
          request_id = l_request_id,
          program_application_id = l_program_application_id,
          program_id = l_program_id,
          program_update_date = sysdate
          WHERE transaction_status = 'REJECTED'
          AND TRUNC(effective_start_date) > TRUNC(SYSDATE);

        fnd_file.put_line(fnd_file.log, ' No of transactions from REJECTED to ACTIVE: ' || SQL%ROWCOUNT );

        UPDATE dpp_transaction_headers_all
          SET transaction_status = 'ACTIVE',
          object_version_number = object_version_number +1,
          last_updated_by = l_user_id,
          last_update_date = sysdate,
          last_update_login = l_login_id,
          request_id = l_request_id,
          program_application_id = l_program_application_id,
          program_id = l_program_id,
          program_update_date = sysdate
          WHERE transaction_status = 'PENDING_APPROVAL'
          AND TRUNC(effective_start_date) > TRUNC(SYSDATE);

        fnd_file.put_line(fnd_file.log, ' No of transactions from PENDING_APPROVAL to ACTIVE: ' || SQL%ROWCOUNT );

    EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
        );
        IF x_msg_count > 1 THEN
            FOR I IN 1..x_msg_count LOOP
               x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
            END LOOP;
        END IF;

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
        );
        IF x_msg_count > 1 THEN
            FOR I IN 1..x_msg_count LOOP
               x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
            END LOOP;
        END IF;

     WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
        fnd_message.set_token('ROUTINE', 'DPP_MIG_ADJ_PARA_APPROVAL_PVT.update_status');
        fnd_message.set_token('ERRNO', sqlcode);
        fnd_message.set_token('REASON', sqlerrm);
        FND_MSG_PUB.add;

        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
        );
        IF x_msg_count > 1 THEN
            FOR I IN 1..x_msg_count LOOP
               x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
            END LOOP;
        END IF;

  END update_status;

    ---------------------------------------------------------------------
    -- PROCEDURE
    --    update_transaction_status
    --
    -- PURPOSE
    --    It updates the transaction statuses based on new status order rule
    --
    -- PARAMETERS
    --
    -- NOTES
    --
    ----------------------------------------------------------------------

    PROCEDURE update_transaction_status(
                  errbuf  OUT NOCOPY VARCHAR2
                , retcode OUT NOCOPY VARCHAR2
    )
    IS
    l_api_name          CONSTANT VARCHAR2(30) := 'update_transaction_status';
    l_api_version       CONSTANT NUMBER       := 1.0;
    l_full_name         CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;

    l_return_status     VARCHAR2(30);
    l_msg_count         NUMBER;
    l_msg_data          VARCHAR2(4000);

    l_init_msg_list     VARCHAR2(30) := fnd_api.g_true;
    l_commit            VARCHAR2(30) := fnd_api.g_false;
    l_validation_level  NUMBER       := fnd_api.g_valid_level_full;

    BEGIN
      -- Standard API savepoint
      SAVEPOINT update_transaction_status;

      -- Initialize API return status to sucess
      errbuf :='Success';
      retcode  := 0;
      l_return_status := FND_API.G_RET_STS_SUCCESS;

      IF G_DEBUG THEN
        fnd_file.put_line(fnd_file.LOG,'Check if the migration has already been completed successfully.');
      END IF;

      checkMigrationCompletion(
                p_api_version        => l_api_version
            ,   p_init_msg_list      => l_init_msg_list
            ,   p_commit             => l_commit
            ,   p_validation_level   => l_validation_level
            ,   x_return_status      => l_return_status
            ,   x_msg_count          => l_msg_count
            ,   x_msg_data           => l_msg_data
      ) ;

      IF G_DEBUG THEN
        fnd_file.put_line(fnd_file.log, ' Check migration completion. Return Status: ' || l_return_status || ' Error Msg: ' || l_msg_data);
      END IF;

      IF l_return_status = Fnd_Api.g_ret_sts_error THEN
        fnd_file.put_line(fnd_file.log, l_msg_data);
        errbuf := 'Warning';
        retcode := 1;
        RETURN;
      ELSIF l_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
        RAISE Fnd_Api.g_exc_unexpected_error;
      END IF;

      fnd_file.put_line(fnd_file.log,('-----------------------------------------------------------'));
      fnd_file.put_line(fnd_file.log,('    Migration started at ' || to_char(sysdate,'dd-mon-yyyy hh24:mi:ss')));
      fnd_file.put_line(fnd_file.log,('-----------------------------------------------------------'));

      IF G_DEBUG THEN
        fnd_file.put_line(fnd_file.LOG,'Validate Supplier Trade Profile');
      END IF;

      validate_suppTradeProfile(
                p_api_version        => l_api_version
            ,   p_init_msg_list      => l_init_msg_list
            ,   p_commit             => l_commit
            ,   p_validation_level   => l_validation_level
            ,   x_return_status      => l_return_status
            ,   x_msg_count          => l_msg_count
            ,   x_msg_data           => l_msg_data
      ) ;

      IF G_DEBUG THEN
        fnd_file.put_line(fnd_file.log, ' Validate Supplier Trade Profile. Return Status: ' || l_return_status || ' Error Msg: ' || l_msg_data);
      END IF;

      IF l_return_status = Fnd_Api.g_ret_sts_error THEN
        RAISE Fnd_Api.g_exc_error;
      ELSIF l_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
        RAISE Fnd_Api.g_exc_unexpected_error;
      END IF;

      IF G_DEBUG THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG,'Validate Execution Process Setup');
      END IF;

      validate_execProcessSetup(
                p_api_version        => l_api_version
            ,   p_init_msg_list      => l_init_msg_list
            ,   p_commit             => l_commit
            ,   p_validation_level   => l_validation_level
            ,   x_return_status      => l_return_status
            ,   x_msg_count          => l_msg_count
            ,   x_msg_data           => l_msg_data
      ) ;

      IF G_DEBUG THEN
        fnd_file.put_line(fnd_file.log, ' Validate Execution Process Setup. Return Status: ' || l_return_status || ' Error Msg: ' || l_msg_data);
      END IF;

      IF l_return_status = Fnd_Api.g_ret_sts_error THEN
        fnd_file.put_line(fnd_file.log, l_msg_data);
        errbuf := 'Error';
        retcode := 2;
        RETURN;
      ELSIF l_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
        RAISE Fnd_Api.g_exc_unexpected_error;
      END IF;

      IF G_DEBUG THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG,'Insert Execution Processes');
      END IF;

      InsertExecutionProcesses(
                p_api_version        => l_api_version
            ,   p_init_msg_list      => l_init_msg_list
            ,   p_commit             => l_commit
            ,   p_validation_level   => l_validation_level
            ,   x_return_status      => l_return_status
            ,   x_msg_count          => l_msg_count
            ,   x_msg_data           => l_msg_data
      ) ;

      IF G_DEBUG THEN
        fnd_file.put_line(fnd_file.log, ' Insert Execution Processes. Return Status: ' || l_return_status || ' Error Msg: ' || l_msg_data);
      END IF;

      IF l_return_status = Fnd_Api.g_ret_sts_error THEN
        RAISE Fnd_Api.g_exc_error;
      ELSIF l_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
        RAISE Fnd_Api.g_exc_unexpected_error;
      END IF;

      IF G_DEBUG THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG,'Clear all the approvals in both Price Protection and AME');
      END IF;

      clearAllApprovals(
                p_api_version        => l_api_version
            ,   p_init_msg_list      => l_init_msg_list
            ,   p_commit             => l_commit
            ,   p_validation_level   => l_validation_level
            ,   x_return_status      => l_return_status
            ,   x_msg_count          => l_msg_count
            ,   x_msg_data           => l_msg_data
      ) ;

      IF G_DEBUG THEN
        fnd_file.put_line(fnd_file.log, ' Clear All Approvals. Return Status: ' || l_return_status || ' Error Msg: ' || l_msg_data);
      END IF;

      IF l_return_status = Fnd_Api.g_ret_sts_error THEN
        RAISE Fnd_Api.g_exc_error;
      ELSIF l_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
        RAISE Fnd_Api.g_exc_unexpected_error;
      END IF;

      IF G_DEBUG THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG,'Update status');
      END IF;

      update_status(
                p_api_version        => l_api_version
            ,   p_init_msg_list      => l_init_msg_list
            ,   p_commit             => l_commit
            ,   p_validation_level   => l_validation_level
            ,   x_return_status      => l_return_status
            ,   x_msg_count          => l_msg_count
            ,   x_msg_data           => l_msg_data
      ) ;

      IF G_DEBUG THEN
        fnd_file.put_line(fnd_file.log, ' Update status. Return Status: ' || l_return_status || ' Error Msg: ' || l_msg_data);
      END IF;

      IF l_return_status = Fnd_Api.g_ret_sts_error THEN
        RAISE Fnd_Api.g_exc_error;
      ELSIF l_return_status = Fnd_Api.g_ret_sts_unexp_error THEN
        RAISE Fnd_Api.g_exc_unexpected_error;
      END IF;

      COMMIT;

      fnd_file.put_line(fnd_file.log,('-----------------------------------------------------------'));
      fnd_file.put_line(fnd_file.log,('    Migration completed at ' || to_char(sysdate,'dd-mon-yyyy hh24:mi:ss')));
      fnd_file.put_line(fnd_file.log,('-----------------------------------------------------------'));

    EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO update_transaction_status;
        errbuf :='Error';
        retcode  := 2;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => l_msg_count,
            p_data    => l_msg_data
        );
        IF l_msg_count > 1 THEN
            FOR I IN 1..l_msg_count LOOP
               l_msg_data := SUBSTR((l_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
            END LOOP;
        END IF;

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO update_transaction_status;
        errbuf :='Error';
        retcode  := 2;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => l_msg_count,
            p_data  => l_msg_data
        );
        IF l_msg_count > 1 THEN
            FOR I IN 1..l_msg_count LOOP
               l_msg_data := SUBSTR((l_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
            END LOOP;
        END IF;

      WHEN OTHERS THEN
        ROLLBACK TO update_transaction_status;
        errbuf :='Error';
        retcode  := 2;
        fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
        fnd_message.set_token('ROUTINE', 'DPP_MIG_ADJ_PARA_APPROVAL_PVT.update_transaction_status');
        fnd_message.set_token('ERRNO', sqlcode);
        fnd_message.set_token('REASON', sqlerrm);
        FND_MSG_PUB.add;

        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => l_msg_count,
            p_data  => l_msg_data
        );
        IF l_msg_count > 1 THEN
            FOR I IN 1..l_msg_count LOOP
               l_msg_data := SUBSTR((l_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
            END LOOP;
        END IF;

    END update_transaction_status;

END DPP_MIG_ADJ_PARA_APPROVAL_PVT;

/
