--------------------------------------------------------
--  DDL for Package Body OPI_DBI_BOUNDS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OPI_DBI_BOUNDS_PKG" AS
--$Header: OPIINVBNDB.pls 120.10 2006/03/20 00:33:16 srayadur noship $

--Global variables
g_pkg_name VARCHAR2(40)  := 'OPI_DBI_BOUNDS_PKG';

C_ERRBUF_SIZE CONSTANT NUMBER := 300;  -- length of formatted error message

-- User Defined Exceptions
INITIALIZATION_ERROR    EXCEPTION;
INIT_LOAD_NOT_RUN       EXCEPTION;
INV_LOAD_NOT_RUN        EXCEPTION;

-- return codes
g_ERROR     CONSTANT NUMBER := -1;
g_WARNING   CONSTANT NUMBER := 1;
g_ok        CONSTANT NUMBER := 0;

-- ETLs stop reason codes
STOP_UNCOSTED   CONSTANT VARCHAR2(30) := 'STOP_UNCOSTED';
STOP_ALL_COSTED CONSTANT VARCHAR2(30) := 'STOP_ALL_COSTED';

PROCEDURE maintain_opi_dbi_logs(p_etl_type  IN  VARCHAR2,
                                p_load_type IN VARCHAR2)
IS
     l_count                NUMBER :=0 ;
     l_init_count           NUMBER :=0 ;
     l_stmt_no              NUMBER :=0 ;
     l_completion_status    VARCHAR2(30);
     l_proc_name            VARCHAR2(40);
     l_debug_msg            VARCHAR2(32767);
     l_debug_mode           VARCHAR2(1);
     l_user_id              NUMBER  := NVL(fnd_global.USER_ID, -1);
     l_login_id             NUMBER  := NVL(fnd_global.LOGIN_ID, -1);
     l_module_name          VARCHAR2(40);
     l_program_id             NUMBER ;
     l_program_login_id       NUMBER ;
     l_program_application_id NUMBER ;
     l_request_id             NUMBER ;

BEGIN
     l_debug_mode              :=  NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
     l_module_name             :=  FND_PROFILE.value('AFLOG_MODULE');
     l_proc_name               :=  'maintain_opi_dbi_logs';

     l_program_id              := NVL(fnd_global.CONC_PROGRAM_ID,-1);
     l_program_login_id        := NVL(fnd_global.CONC_LOGIN_ID,-1);
     l_program_application_id  := NVL(fnd_global.PROG_APPL_ID,-1);
     l_request_id              := NVL(fnd_global.CONC_REQUEST_ID,-1);

     IF (p_load_type = 'INIT') THEN          /* running initial load */

        IF l_debug_mode = 'Y' AND upper(l_module_name) like 'BIS%' THEN
            l_debug_msg := 'Running initial load for '||p_etl_type ;
            opi_dbi_bounds_pkg.write(g_pkg_name, l_proc_name, l_stmt_no, l_debug_msg);
        END IF;

        l_stmt_no := 10;
        DELETE FROM OPI_DBI_CONC_PROG_RUN_LOG
        WHERE etl_type = p_etl_type;

        IF l_debug_mode = 'Y' AND upper(l_module_name) like 'BIS%' THEN
            l_debug_msg := 'Deleted '||to_char(sql%rowcount)||' rows from OPI_DBI_CONC_PROG_RUN_LOG' ;
            opi_dbi_bounds_pkg.write(g_pkg_name, l_proc_name, l_stmt_no, l_debug_msg);
        END IF;

        OPI_DBI_BOUNDS_PKG.CALL_ETL_SPECIFIC_BOUND(p_etl_type,p_load_type);

        IF l_debug_mode = 'Y' AND upper(l_module_name) like 'BIS%' THEN
            l_debug_msg := 'After Calling Call ETL specific bounds' ;
            opi_dbi_bounds_pkg.write(g_pkg_name, l_proc_name, l_stmt_no, l_debug_msg);
        END IF;

     ELSIF (p_load_type = 'INCR') THEN           /* running  incremental Load */

        IF l_debug_mode = 'Y' AND upper(l_module_name) like 'BIS%' THEN
            l_debug_msg := 'Running Incremental Load for '||p_etl_type ;
            opi_dbi_bounds_pkg.write(g_pkg_name, l_proc_name, l_stmt_no, l_debug_msg);
        END IF;

        BEGIN
            l_count             := -1;
            l_completion_status := null;

            /* check whether its the first time incremental load */
            SELECT 1,nvl(completion_status_code,'N') INTO l_count,l_completion_status
            FROM OPI_DBI_CONC_PROG_RUN_LOG
            WHERE etl_type = p_etl_type
            AND  load_type = p_load_type
            AND  rownum <= 1;
        EXCEPTION
               WHEN NO_DATA_FOUND THEN
               l_count := 0;
        END;


        if (l_count = 0) then
            /* No incr load has been run before so check for the previous initial load run
               and status */

            IF l_debug_mode = 'Y' AND upper(l_module_name) like 'BIS%' THEN
                l_debug_msg := 'First Time Incremental Load for '||p_etl_type ;
                opi_dbi_bounds_pkg.write(g_pkg_name, l_proc_name, l_stmt_no, l_debug_msg);
            END IF;

            BEGIN
               l_init_count := -1;

               /* As completion_status_code is updated based on etl_type and load_type success
               of one record implies success of all the records for that etl_type and load_type */

               SELECT 1,nvl(completion_status_code,'N') into l_init_count,l_completion_status
               FROM OPI_DBI_CONC_PROG_RUN_LOG
               WHERE etl_type = p_etl_type
               AND  load_type = 'INIT'
               AND  rownum <= 1;

            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    l_init_count := 0;
            END;

            if (l_init_count = 1 AND l_completion_status = 'S') then
                /* if prev INIT record exists and successful then create new INCR record and
                copy to bounds of previous INIT record to from bounds of the new INCR record*/

                IF l_debug_mode = 'Y' AND upper(l_module_name) like 'BIS%' THEN
                    l_debug_msg := 'Init Load successful for '||p_etl_type;
                    opi_dbi_bounds_pkg.write(g_pkg_name, l_proc_name, l_stmt_no, l_debug_msg);
                END IF;

                l_stmt_no := 30;
                INSERT INTO OPI_DBI_CONC_PROG_RUN_LOG(
                    driving_table_code      ,
                    etl_type                ,
                    load_type               ,
                    bound_type              ,
                    bound_level_entity_code ,
                    bound_level_entity_id   ,
                    from_bound_date         ,
                    from_bound_id           ,
                    to_bound_date           ,
                    to_bound_id             ,
                    completion_status_code  ,
                    stop_reason_code        ,
                    created_by              ,
                    creation_date           ,
                    last_run_date           ,
                    last_update_date        ,
                    last_updated_by         ,
                    last_update_login       ,
                    program_id              ,
                    program_login_id        ,
                    program_application_id  ,
                    request_id
                    )
                SELECT
                    driving_table_code       ,
                    etl_type                 ,
                    'INCR'                   ,
                    bound_type               ,
                    bound_level_entity_code  ,
                    bound_level_entity_id    ,
                    to_bound_date            ,
                    to_bound_id              ,
                    null                     ,
                    null                     ,
                    null                     ,
                    null                     ,
                    l_user_id                ,
                    sysdate                  ,
                    sysdate                  ,
                    sysdate                  ,
                    l_user_id                ,
                    l_login_id               ,
                    l_program_id             ,
                    l_program_login_id       ,
                    l_program_application_id ,
                    l_request_id
                FROM OPI_DBI_CONC_PROG_RUN_LOG
                WHERE etl_type = p_etl_type
                AND load_type = 'INIT';

                IF l_debug_mode = 'Y' AND upper(l_module_name) like 'BIS%' THEN
                    l_debug_msg := 'Inserted '||to_char(sql%rowcount)||' rows into OPI_DBI_CONC_PROG_RUN_LOG' ;
                    opi_dbi_bounds_pkg.write(g_pkg_name, l_proc_name, l_stmt_no, l_debug_msg);
                END IF;

                -- set to bounds by calling call etl specific bound
                OPI_DBI_BOUNDS_PKG.CALL_ETL_SPECIFIC_BOUND(p_etl_type,p_load_type);

                IF l_debug_mode = 'Y' AND upper(l_module_name) like 'BIS%' THEN
                    l_debug_msg := 'After Calling call_etl_specific_bound for '||p_etl_type||' '||p_load_type||' load' ;
                    opi_dbi_bounds_pkg.write(g_pkg_name, l_proc_name, l_stmt_no, l_debug_msg);
                END IF;

             else    /* Initial Load is not run prior to Incr Load failed */
                FND_MESSAGE.SET_NAME('INV','OPI_DBI_INIT_LOAD_NOT_RUN');
                RAISE INIT_LOAD_NOT_RUN;
             end if;

        else            /* This is not the first time incremental load */

             -- check completion_status_code = 'S' for previous INCR record for
             -- that etl_type and load_type

             if (l_completion_status = 'S') then
             /* last INCR run successful for all driving tables*/

                IF l_debug_mode = 'Y' AND upper(l_module_name) like 'BIS%' THEN
                    l_debug_msg := 'Last INCR Load successful . Updating to bounds...';
                    opi_dbi_bounds_pkg.write(g_pkg_name, l_proc_name, l_stmt_no, l_debug_msg);
                END IF;

                /* update from_bound_id and from_bound_date as previous to_bound_id and
                   to_bound_date */
                l_stmt_no :=40;
                UPDATE OPI_DBI_CONC_PROG_RUN_LOG prlout
                SET ( from_bound_id         ,
                      from_bound_date       ,
                      to_bound_date         ,
                      to_bound_id           ,
                      completion_status_code,
                      stop_reason_code      ,
                      last_run_date         ,
                      last_update_date      ,
                      last_updated_by       ,
                      last_update_login     ,
                      program_id            ,
                      program_login_id      ,
                      program_application_id,
                      request_id
                      ) =
                (SELECT
                      to_bound_id           ,
                      to_bound_date         ,
                      null                  ,
                      null                  ,
                      null                  ,
                      null                  ,
                      sysdate               ,
                      sysdate               ,
                      l_user_id             ,
                      l_login_id            ,
                      l_program_id          ,
                      l_program_login_id    ,
                      l_program_application_id,
                      l_request_id
                FROM OPI_DBI_CONC_PROG_RUN_LOG prlin
                WHERE prlin.etl_type = prlout.etl_type
                AND prlin.load_type = prlout.load_type
                AND prlin.driving_table_code = prlout.driving_table_code
                AND nvl(prlin.bound_level_entity_id,-1) = nvl(prlout.bound_level_entity_id,-1))
                WHERE prlout.etl_type = p_etl_type
                AND prlout.load_type = p_load_type;

                IF l_debug_mode = 'Y' AND upper(l_module_name) like 'BIS%' THEN
                    l_debug_msg := 'Updated '||to_char(sql%rowcount)||' rows in OPI_DBI_CONC_PROG_RUN_LOG' ;
                    opi_dbi_bounds_pkg.write(g_pkg_name, l_proc_name, l_stmt_no, l_debug_msg);
                END IF;

            else
                /* if last INCR run was unsuccessful set to bounds to NULL*/

		IF l_debug_mode = 'Y' AND upper(l_module_name) like 'BIS%' THEN
                    l_debug_msg := 'Last INCR Load failed for '||p_etl_type;
                    opi_dbi_bounds_pkg.write(g_pkg_name, l_proc_name, l_stmt_no, l_debug_msg);
                END IF;

                                l_stmt_no := 50;
                UPDATE OPI_DBI_CONC_PROG_RUN_LOG
                SET     to_bound_id             = null,
                        to_bound_date           = null,
                        completion_status_code  = null,
                        stop_reason_code        = null,
                        last_run_date           = null , -- last run date should be null at this point
                        last_update_date       = sysdate ,
                        last_updated_by        = l_user_id ,
                        last_update_login      = l_login_id,
                        program_id             = l_program_id            ,
                        program_login_id       = l_program_login_id      ,
                        program_application_id = l_program_application_id,
                        request_id             = l_request_id
                WHERE etl_type = p_etl_type
                AND load_type = p_load_type;

                IF l_debug_mode = 'Y' AND upper(l_module_name) like 'BIS%' THEN
                    l_debug_msg := 'Updated '||to_char(sql%rowcount)||' rows in OPI_DBI_CONC_PROG_RUN_LOG' ;
                    opi_dbi_bounds_pkg.write(g_pkg_name, l_proc_name, l_stmt_no, l_debug_msg);
                END IF;

            end if;             /* end INCR load updation*/

            OPI_DBI_BOUNDS_PKG.CALL_ETL_SPECIFIC_BOUND(p_etl_type,p_load_type);

            IF l_debug_mode = 'Y' AND upper(l_module_name) like 'BIS%' THEN
                l_debug_msg := 'After Calling call_etl_specific_bound for '||p_etl_type||' '||p_load_type||' load' ;
                opi_dbi_bounds_pkg.write(g_pkg_name, l_proc_name, l_stmt_no, l_debug_msg);
            END IF;

        end if ;  /* end INCR load count check */
    end if;             /* end running INIT/INCR load */

EXCEPTION
    WHEN INIT_LOAD_NOT_RUN THEN
        IF l_debug_mode = 'Y' AND upper(l_module_name) like 'BIS%' THEN
            l_debug_msg := FND_MESSAGE.GET;
            opi_dbi_bounds_pkg.write(g_pkg_name, l_proc_name, l_stmt_no, l_debug_msg);
        END IF;
        RAISE;

     WHEN OTHERS THEN
        IF l_debug_mode = 'Y' AND upper(l_module_name) like 'BIS%' THEN
            l_debug_msg := SQLERRM ;
            opi_dbi_bounds_pkg.write(g_pkg_name, l_proc_name, l_stmt_no, l_debug_msg);
        END IF;
        RAISE;
END maintain_opi_dbi_logs;



PROCEDURE call_etl_specific_bound(p_etl_type  IN  VARCHAR2,
                                  p_load_type IN VARCHAR2)
IS
    l_debug_msg               VARCHAR2(32767);
    l_debug_mode              VARCHAR2(1);
    l_stmt_no                 NUMBER :=0;
    l_proc_name               VARCHAR2(40);
    l_module_name             VARCHAR2(40);
BEGIN
    l_debug_mode              :=  NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
    l_module_name             :=  FND_PROFILE.value('AFLOG_MODULE');
    l_proc_name               :=  'call_etl_specific_bound';

    IF l_debug_mode = 'Y' AND upper(l_module_name) like 'BIS%' THEN
        l_debug_msg := 'inside call_etl_specific_bound. '||p_load_type||' load' ;
        opi_dbi_bounds_pkg.write(g_pkg_name, l_proc_name, l_stmt_no, l_debug_msg);
    END IF;

    if (p_etl_type = 'INVENTORY') then

        l_stmt_no := 10;
        OPI_DBI_BOUNDS_PKG.setup_inv_mmt_bounds(p_load_type);

        IF l_debug_mode = 'Y' AND upper(l_module_name) like 'BIS%' THEN
            l_debug_msg := 'After Calling setup_inv_mmt_bounds for INVENTORY '||p_load_type||' load' ;
            opi_dbi_bounds_pkg.write(g_pkg_name, l_proc_name, l_stmt_no, l_debug_msg);
        END IF;

        l_stmt_no := 20;
        OPI_DBI_BOUNDS_PKG.setup_inv_wta_bounds(p_load_type);

        IF l_debug_mode = 'Y' AND upper(l_module_name) like 'BIS%' THEN
            l_debug_msg := 'After Calling setup_inv_wta_bounds for INVENTORY '||p_load_type||' load' ;
            opi_dbi_bounds_pkg.write(g_pkg_name, l_proc_name, l_stmt_no, l_debug_msg);
        END IF;

        l_stmt_no := 30;
        OPI_DBI_BOUNDS_PKG.set_sysdate_bounds(p_load_type,p_etl_type,'GTV');

        IF l_debug_mode = 'Y' AND upper(l_module_name) like 'BIS%' THEN
            l_debug_msg := 'After Calling set_sysdate_bounds for INVENTORY '||p_load_type||' load' ;
            opi_dbi_bounds_pkg.write(g_pkg_name, l_proc_name, l_stmt_no, l_debug_msg);
        END IF;

    elsif (p_etl_type = 'CYCLE_COUNT') then
        IF l_debug_mode = 'Y' AND upper(l_module_name) like 'BIS%' THEN
            l_debug_msg := 'Before Calling setup_cc_mmt_bounds for CYCLE_COUNT '||p_load_type||' load' ;
            opi_dbi_bounds_pkg.write(g_pkg_name, l_proc_name, l_stmt_no, l_debug_msg);
        END IF;

        l_stmt_no := 40;
        OPI_DBI_BOUNDS_PKG.setup_cc_mmt_bounds(p_load_type) ;

        IF l_debug_mode = 'Y' AND upper(l_module_name) like 'BIS%' THEN
            l_debug_msg := 'After Calling setup_cc_mmt_bounds for CYCLE_COUNT '||p_load_type||' load' ;
            opi_dbi_bounds_pkg.write(g_pkg_name, l_proc_name, l_stmt_no, l_debug_msg);
        END IF;

        l_stmt_no := 50;
        OPI_DBI_BOUNDS_PKG.set_sysdate_bounds(p_load_type, p_etl_type, 'CCE') ;

        IF l_debug_mode = 'Y' AND upper(l_module_name) like 'BIS%' THEN
            l_debug_msg := 'After Calling set_sysdate_bounds for CCE table for CYCLE_COUNT'||p_load_type||' load' ;
            opi_dbi_bounds_pkg.write(g_pkg_name, l_proc_name, l_stmt_no, l_debug_msg);
        END IF;

        l_stmt_no := 60;
        OPI_DBI_BOUNDS_PKG.set_sysdate_bounds(p_load_type, p_etl_type, 'GTV') ;

        IF l_debug_mode = 'Y' AND upper(l_module_name) like 'BIS%' THEN
            l_debug_msg := 'After Calling set_sysdate_bounds for GTV table for CYCLE_COUNT'||p_load_type||' load' ;
            opi_dbi_bounds_pkg.write(g_pkg_name, l_proc_name, l_stmt_no, l_debug_msg);
        END IF;

    elsif(p_etl_type = 'COGS') then
        IF l_debug_mode = 'Y' AND upper(l_module_name) like 'BIS%' THEN
            l_debug_msg := 'Before Calling setup_cogs_mmt_bounds for COGS '||p_load_type||' load' ;
            opi_dbi_bounds_pkg.write(g_pkg_name, l_proc_name, l_stmt_no, l_debug_msg);
        END IF;

        l_stmt_no := 40;
        OPI_DBI_BOUNDS_PKG.setup_cogs_mmt_bounds(p_load_type);

        IF l_debug_mode = 'Y' AND upper(l_module_name) like 'BIS%' THEN
            l_debug_msg := 'After Calling setup_cogs_mmt_bounds for COGS '||p_load_type||' load' ;
            opi_dbi_bounds_pkg.write(g_pkg_name, l_proc_name, l_stmt_no, l_debug_msg);
        END IF;

        l_stmt_no := 50;
        OPI_DBI_BOUNDS_PKG.set_sysdate_bounds(p_load_type, p_etl_type, 'GTV');

        IF l_debug_mode = 'Y' AND upper(l_module_name) like 'BIS%' THEN
            l_debug_msg := 'After Calling set_sysdate_bounds for GTV table for COGS '||p_load_type||' load' ;
            opi_dbi_bounds_pkg.write(g_pkg_name, l_proc_name, l_stmt_no, l_debug_msg);
        END IF;

    end if;
END  call_etl_specific_bound;


PROCEDURE setup_inv_mmt_bounds(p_load_type IN VARCHAR2)
IS
    l_debug_msg               VARCHAR2(32767);
    l_debug_mode              VARCHAR2(1);
    l_stmt_no                 NUMBER :=0;
    l_proc_name               VARCHAR2(40);
    l_module_name             VARCHAR2(40);
BEGIN
    l_module_name             :=  FND_PROFILE.value('AFLOG_MODULE');
    l_proc_name               :=  'setup_inv_mmt_bounds';
    l_debug_mode              :=  NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

    IF l_debug_mode = 'Y' AND upper(l_module_name) like 'BIS%' THEN
        l_debug_msg := 'inside setup inv mmt bounds '||p_load_type||' load' ;
        opi_dbi_bounds_pkg.write(g_pkg_name, l_proc_name, l_stmt_no, l_debug_msg);
    END IF;

    if (p_load_type = 'INIT') then

        l_stmt_no :=10;
        OPI_DBI_BOUNDS_PKG.create_first_mmt_bounds('INVENTORY');

        IF l_debug_mode = 'Y' AND upper(l_module_name) like 'BIS%' THEN
            l_debug_msg := 'After Calling create_first_mmt_bounds for INVENTORY '||p_load_type||' load' ;
            opi_dbi_bounds_pkg.write(g_pkg_name, l_proc_name, l_stmt_no, l_debug_msg);
        END IF;
    else
        IF l_debug_mode = 'Y' AND upper(l_module_name) like 'BIS%' THEN
            l_debug_msg := 'Before Calling set_mmt_new_bounds for INVENTORY '||p_load_type||' load' ;
            opi_dbi_bounds_pkg.write(g_pkg_name, l_proc_name, l_stmt_no, l_debug_msg);
        END IF;

        l_stmt_no :=20;
        OPI_DBI_BOUNDS_PKG.set_mmt_new_bounds('INVENTORY','INCR');

        IF l_debug_mode = 'Y' AND upper(l_module_name) like 'BIS%' THEN
            l_debug_msg := 'After Calling set_mmt_new_bounds for INVENTORY '||p_load_type||' load' ;
            opi_dbi_bounds_pkg.write(g_pkg_name, l_proc_name, l_stmt_no, l_debug_msg);
        END IF;
    end if;
END setup_inv_mmt_bounds;

PROCEDURE setup_cogs_mmt_bounds(p_load_type IN VARCHAR2)
IS
    l_debug_msg               VARCHAR2(32767);
    l_debug_mode              VARCHAR2(1);
    l_stmt_no                 NUMBER := 0;
    l_proc_name               VARCHAR2(40);
    l_module_name             VARCHAR2(40);
BEGIN
    l_debug_mode              :=  NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
    l_proc_name               :=  'setup_cogs_mmt_bounds';


    if (p_load_type = 'INIT') then
        IF l_debug_mode = 'Y' AND upper(l_module_name) like 'BIS%' THEN
            l_debug_msg := 'Before Calling create_first_mmt_bounds for COGS '||p_load_type||' load' ;
            opi_dbi_bounds_pkg.write(g_pkg_name, l_proc_name, l_stmt_no, l_debug_msg);
        END IF;
        l_stmt_no := 10;
        OPI_DBI_BOUNDS_PKG.create_first_mmt_bounds('COGS');

    else
        IF l_debug_mode = 'Y' AND upper(l_module_name) like 'BIS%' THEN
            l_debug_msg := 'Before Calling set_mmt_new_bounds for COGS '||p_load_type||' load' ;
            opi_dbi_bounds_pkg.write(g_pkg_name, l_proc_name, l_stmt_no, l_debug_msg);
        END IF;
        l_stmt_no :=20;
        OPI_DBI_BOUNDS_PKG.set_mmt_new_bounds('COGS','INCR');
    end if;

    IF l_debug_mode = 'Y' AND upper(l_module_name) like 'BIS%' THEN
 	  l_debug_msg := 'end of setup cogs mmt bounds '||p_load_type||' load' ;
	  opi_dbi_bounds_pkg.write(g_pkg_name, l_proc_name, l_stmt_no, l_debug_msg);
    END IF;

END setup_cogs_mmt_bounds;

PROCEDURE setup_cc_mmt_bounds(p_load_type IN VARCHAR2)
IS
    l_proc_name               VARCHAR2(40);
    l_debug_msg               VARCHAR2(32767);
    l_debug_mode              VARCHAR2(1);
    l_stmt_no                 NUMBER := 0;
    l_module_name             VARCHAR2(40);
BEGIN
    l_module_name             :=  FND_PROFILE.value('AFLOG_MODULE');
    l_proc_name               :=  'setup_cogs_mmt_bounds';
    l_debug_mode              :=  NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

    IF l_debug_mode = 'Y' AND upper(l_module_name) like 'BIS%' THEN
        l_debug_msg := 'inside setup_cc_mmt_bounds '||p_load_type||' load' ;
        opi_dbi_bounds_pkg.write(g_pkg_name, l_proc_name, l_stmt_no, l_debug_msg);
    END IF;

    if (p_load_type = 'INIT') then

        IF l_debug_mode = 'Y' AND upper(l_module_name) like 'BIS%' THEN
            l_debug_msg := 'Before Calling create_first_mmt_bounds for CYCLE_COUNT '||p_load_type||' load' ;
            opi_dbi_bounds_pkg.write(g_pkg_name, l_proc_name, l_stmt_no, l_debug_msg);
        END IF;

        l_stmt_no := 10;
        OPI_DBI_BOUNDS_PKG.create_first_mmt_bounds('CYCLE_COUNT');


    elsif (p_load_type = 'INCR') then

        IF l_debug_mode = 'Y' AND upper(l_module_name) like 'BIS%' THEN
            l_debug_msg := 'Before Calling set_mmt_new_bounds for CYCLE_COUNT '||p_load_type||' load' ;
            opi_dbi_bounds_pkg.write(g_pkg_name, l_proc_name, l_stmt_no, l_debug_msg);
        END IF;

        l_stmt_no := 20;
        OPI_DBI_BOUNDS_PKG.set_mmt_new_bounds('CYCLE_COUNT',p_load_type);

    end if;

	IF l_debug_mode = 'Y' AND upper(l_module_name) like 'BIS%' THEN
         l_debug_msg := 'end of setup_cc_mmt_bounds '||p_load_type||' load' ;
         opi_dbi_bounds_pkg.write(g_pkg_name, l_proc_name, l_stmt_no, l_debug_msg);
     END IF;

END setup_cc_mmt_bounds ;

PROCEDURE create_first_mmt_bounds(p_etl_type IN VARCHAR2)
IS
    l_inv_count             NUMBER;
    l_max_trx_id            NUMBER;
    l_global_start_date     DATE;
    l_stmt_no        NUMBER :=0;
    l_proc_name      VARCHAR2(40);
    l_user_id        NUMBER  := NVL(fnd_global.USER_ID, -1);
    l_login_id       NUMBER  := NVL(fnd_global.LOGIN_ID, -1);
    l_debug_msg               VARCHAR2(32767);
    l_debug_mode              VARCHAR2(1);
    l_module_name             VARCHAR2(40);

    l_program_id             NUMBER ;
    l_program_login_id       NUMBER ;
    l_program_application_id NUMBER ;
    l_request_id             NUMBER ;

BEGIN
    l_module_name             :=  FND_PROFILE.value('AFLOG_MODULE');
    l_debug_mode              :=  NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
    l_proc_name               :=  'create_first_mmt_bounds';

    l_program_id              := NVL(fnd_global.CONC_PROGRAM_ID,-1);
    l_program_login_id        := NVL(fnd_global.CONC_LOGIN_ID,-1);
    l_program_application_id  := NVL(fnd_global.PROG_APPL_ID,-1);
    l_request_id              := NVL(fnd_global.CONC_REQUEST_ID,-1);

    l_stmt_no :=10;
    select BIS_COMMON_PARAMETERS.GET_GLOBAL_START_DATE into l_global_start_date from DUAL;

    if (l_global_start_date is NULL) then
        RAISE INITIALIZATION_ERROR ;
    end if;

    /* check for INV INIT record to reuse bounds for COGS and CYCLE_COUNT loads*/

    if (p_etl_type = 'COGS' or p_etl_type = 'CYCLE_COUNT') then

        BEGIN

        l_inv_count := -1;

        SELECT count(1) INTO l_inv_count FROM OPI_DBI_CONC_PROG_RUN_LOG
        WHERE etl_type  = 'INVENTORY'
        AND       load_type = 'INIT'
        AND       rownum <=1 ;

        EXCEPTION
                WHEN NO_DATA_FOUND THEN
                l_inv_count := 0;
        END;

    end if;

    /* if etl_type is cycle count and inv load is not run  then error out */

    if (p_etl_type = 'CYCLE_COUNT' and l_inv_count = 0) then
        /* Error msg for init load not run prior to incr load */
        FND_MESSAGE.SET_NAME('INV','OPI_DBI_INV_LOAD_NOT_RUN');
        RAISE INV_LOAD_NOT_RUN;
    end if;

    -- cycle count uses the same bounds as Inventory hence for cycle count get
    -- from and to bounds from inventory record.
    -- it is not possible that cycle count incr is being run without running incr
    -- or inventory.
    if (l_inv_count = 1 and p_etl_type = 'CYCLE_COUNT') then
        l_stmt_no :=20;
        INSERT INTO OPI_DBI_CONC_PROG_RUN_LOG(
             driving_table_code      ,
             etl_type                ,
             load_type               ,
             bound_type              ,
             bound_level_entity_code ,
             bound_level_entity_id   ,
             from_bound_date         ,
             from_bound_id           ,
             to_bound_date           ,
             to_bound_id             ,
             completion_status_code  ,
             stop_reason_code        ,
             created_by              ,
             creation_date           ,
             last_run_date           ,
             last_update_date        ,
             last_updated_by         ,
             last_update_login       ,
             program_id              ,
             program_login_id        ,
             program_application_id  ,
             request_id)
        SELECT
             'MMT'                   ,
             p_etl_type              ,
             'INIT'                  ,
             bound_type              ,
             bound_level_entity_code ,
             bound_level_entity_id   ,     /* org frm INV INIT record */
             null                    ,
             from_bound_id           ,     /* from_bound_id from INV record */
             null                    ,
             to_bound_id             ,     /* to_bound_id from INV record */
             null                    ,
             stop_reason_code	     ,    /* stop_reason_code copied from INVENTORY record */
             l_user_id               ,
             sysdate                 ,
             sysdate                 ,
             sysdate                 ,
             l_user_id               ,
             l_login_id              ,
             l_program_id            ,
             l_program_login_id      ,
             l_program_application_id,
             l_request_id
        FROM  OPI_DBI_CONC_PROG_RUN_LOG
        WHERE etl_type = 'INVENTORY'
        AND driving_table_code = 'MMT'
        AND load_type = 'INIT';

        IF l_debug_mode = 'Y' AND upper(l_module_name) like 'BIS%' THEN
            l_debug_msg := 'Inserted '||to_char(sql%rowcount)||' rows into OPI_DBI_CONC_PROG_RUN_LOG' ;
            opi_dbi_bounds_pkg.write(g_pkg_name, l_proc_name, l_stmt_no, l_debug_msg);
        END IF;

    -- for COGS we only copy the from bounds from inventory. to bounds are recalculated.
    -- in case GSD is modified Inventory load should be run prior to COGS else change of GSD
    -- will not take effect in COGS etl
    elsif(l_inv_count = 1 and p_etl_type = 'COGS' ) then
        l_stmt_no :=30;
        INSERT INTO OPI_DBI_CONC_PROG_RUN_LOG(
             driving_table_code      ,
             etl_type                ,
             load_type               ,
             bound_type              ,
             bound_level_entity_code ,
             bound_level_entity_id   ,
             from_bound_date         ,
             from_bound_id           ,
             to_bound_date           ,
             to_bound_id             ,
             completion_status_code  ,
             stop_reason_code        ,
             created_by              ,
             creation_date           ,
             last_run_date           ,
             last_update_date        ,
             last_updated_by         ,
             last_update_login       ,
             program_id              ,
             program_login_id        ,
             program_application_id  ,
             request_id
             )
        SELECT
             'MMT'                   ,
             p_etl_type              ,
             'INIT'                  ,
             bound_type              ,
             bound_level_entity_code ,
             bound_level_entity_id   ,  /* org frm INV INIT record */
             null                    ,
             from_bound_id           ,  /* min (from_bound_id) from all INV records */
             null                    ,
             null                    ,  /* set to null for now updated in set_mmt_new_bounds */
             null                    ,
             stop_reason_code        ,
             l_user_id               ,
             sysdate                 ,
             sysdate                 ,
             sysdate                 ,
             l_user_id               ,
             l_login_id              ,
             l_program_id            ,
             l_program_login_id      ,
             l_program_application_id,
             l_request_id
        FROM  OPI_DBI_CONC_PROG_RUN_LOG
        WHERE etl_type = 'INVENTORY'
        AND driving_table_code = 'MMT'
        AND load_type = 'INIT';

        IF l_debug_mode = 'Y' AND upper(l_module_name) like 'BIS%' THEN
            l_debug_msg := 'Inserted '||to_char(sql%rowcount)||' rows into OPI_DBI_CONC_PROG_RUN_LOG' ;
            opi_dbi_bounds_pkg.write(g_pkg_name, l_proc_name, l_stmt_no, l_debug_msg);
        END IF;

        IF l_debug_mode = 'Y' AND upper(l_module_name) like 'BIS%' THEN
            l_debug_msg := 'Before Calling set_mmt_new_bounds for '||p_etl_type||' INIT load' ;
            opi_dbi_bounds_pkg.write(g_pkg_name, l_proc_name, l_stmt_no, l_debug_msg);
        END IF;

        -- set the to_bounds.
        OPI_DBI_BOUNDS_PKG.set_mmt_new_bounds('COGS','INIT');

        IF l_debug_mode = 'Y' AND upper(l_module_name) like 'BIS%' THEN
            l_debug_msg := 'After Calling set_mmt_new_bounds for '||p_etl_type||' INIT load' ;
            opi_dbi_bounds_pkg.write(g_pkg_name, l_proc_name, l_stmt_no, l_debug_msg);
        END IF;

    -- there are two cases handled in this else.
    -- 1. COGS etl when INVENTORY is not run
    -- 2. p_etl_type = INVENTORY.
    -- in both the cases we compute the start bound from MMT and then set the to_bound
    else
        l_max_trx_id := -1;
        l_stmt_no :=40;
        SELECT max(transaction_id)+1  INTO l_max_trx_id
        FROM mtl_material_transactions mmt;

        IF l_debug_mode = 'Y' AND upper(l_module_name) like 'BIS%' THEN
            l_debug_msg := 'Max transaction_id from MMT is '||to_char(l_max_trx_id)
                           ||' as on '||to_char(sysdate);
            opi_dbi_bounds_pkg.write(g_pkg_name, l_proc_name, l_stmt_no, l_debug_msg);
        END IF;

        l_stmt_no :=50;

        INSERT INTO OPI_DBI_CONC_PROG_RUN_LOG(
            driving_table_code      ,
            etl_type                ,
            load_type               ,
            bound_type              ,
            bound_level_entity_code ,
            bound_level_entity_id   ,
            from_bound_date         ,
            from_bound_id           ,
            to_bound_date           ,
            to_bound_id             ,
            completion_status_code  ,
            stop_reason_code        ,
            created_by              ,
            creation_date           ,
            last_run_date           ,
            last_update_date        ,
            last_updated_by         ,
            last_update_login       ,
            program_id              ,
            program_login_id        ,
            program_application_id  ,
            request_id)
        SELECT
            'MMT'                   ,
            p_etl_type              ,
            'INIT'                  ,
            'ID'                    ,
            'ORGANIZATION'          ,
            mp.organization_id      ,
            null                    ,
            /* FIRST TXN ID FOR THE ORGANIZATION AFTER GSD .IF There are no records for
            the org after GSD then incr record wouldn't be created*/
            min_trx.transaction_id  ,
            null                    ,
            /* FIRST UNCOSTED TXN ID FOR THE ORGANIZATION. MAX TRANSACTION OF MMT
            IN CASE THERE NO UNCOSTED TXN. */
            nvl(uncosted_trx.transaction_id,l_max_trx_id)   ,
            null                    ,
            /* stop reason code */
            decode (uncosted_trx.transaction_id,NULL, 'STOP_ALL_COSTED','STOP_UNCOSTED'),
            l_user_id              ,
            sysdate                ,
            sysdate                ,
            sysdate                ,
            l_user_id              ,
            l_login_id             ,
            l_program_id           ,
            l_program_login_id     ,
            l_program_application_id,
            l_request_id
        FROM mtl_parameters mp ,
             (
              SELECT /*+ no_merge parallel(mmt) */ organization_id,min(transaction_id) transaction_id
              FROM mtl_material_transactions mmt
              WHERE  transaction_date >= l_global_start_date
              GROUP BY organization_id
             )min_trx ,
             (
              SELECT /*+ no_merge parallel(mmt) */ organization_id,min(transaction_id) transaction_id
              FROM mtl_material_transactions mmt
              WHERE costed_flag in('N','E')
              AND transaction_date >= l_global_start_date  --Bug 5096963
              GROUP BY organization_id
             )uncosted_trx
        WHERE mp.organization_id = min_trx.organization_id
        AND  min_trx.organization_id = uncosted_trx.organization_id(+)
	AND mp.process_enabled_flag <> 'Y';

        IF l_debug_mode = 'Y' AND upper(l_module_name) like 'BIS%' THEN
            l_debug_msg := 'Inserted '||to_char(sql%rowcount)||' rows into OPI_DBI_CONC_PROG_RUN_LOG' ;
            opi_dbi_bounds_pkg.write(g_pkg_name, l_proc_name, l_stmt_no, l_debug_msg);
        END IF;
    end if;

EXCEPTION
   WHEN INITIALIZATION_ERROR THEN
        IF l_debug_mode = 'Y' AND upper(l_module_name) like 'BIS%' THEN
            l_debug_msg := 'Global Start Date is NULL' ;
            opi_dbi_bounds_pkg.write(g_pkg_name, l_proc_name, l_stmt_no, l_debug_msg);
        END IF;
        RAISE;

   WHEN INV_LOAD_NOT_RUN THEN
        IF l_debug_mode = 'Y' AND upper(l_module_name) like 'BIS%' THEN
            l_debug_msg := FND_MESSAGE.GET;
            opi_dbi_bounds_pkg.write(g_pkg_name, l_proc_name, l_stmt_no, l_debug_msg);
        END IF;
        RAISE;

  WHEN OTHERS THEN
       IF l_debug_mode = 'Y' AND upper(l_module_name) like 'BIS%' THEN
            l_debug_msg := SQLERRM ;
            opi_dbi_bounds_pkg.write(g_pkg_name, l_proc_name, l_stmt_no, l_debug_msg);
        END IF;
        RAISE;

END create_first_mmt_bounds;


PROCEDURE set_mmt_new_bounds(p_etl_type IN VARCHAR2,p_load_type VARCHAR2)
IS
    l_stmt_no        NUMBER :=0;
    l_max_trx_id     NUMBER;
    l_proc_name      VARCHAR2(40);
    l_user_id        NUMBER  := NVL(fnd_global.USER_ID, -1);
    l_login_id       NUMBER  := NVL(fnd_global.LOGIN_ID, -1);
    l_debug_msg      VARCHAR2(32767);
    l_debug_mode     VARCHAR2(1);
    l_module_name    VARCHAR2(40);

    l_program_id             NUMBER ;
    l_program_login_id       NUMBER ;
    l_program_application_id NUMBER ;
    l_request_id             NUMBER ;


    /* open a cursor for holding all new organizations in mtl_parameters after previous INIT-INCR load */
    CURSOR csr_get_new_org IS
    SELECT DISTINCT organization_id
    FROM mtl_parameters
    WHERE process_enabled_flag <> 'Y'
    MINUS
    SELECT DISTINCT bound_level_entity_id
    FROM OPI_DBI_CONC_PROG_RUN_LOG
    WHERE etl_type = p_etl_type
    AND driving_table_code = 'MMT';

BEGIN
    l_module_name             :=  FND_PROFILE.value('AFLOG_MODULE');
    l_debug_mode              :=  NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
    l_proc_name               :=  'set_mmt_new_bounds';

    l_program_id              := NVL(fnd_global.CONC_PROGRAM_ID,-1);
    l_program_login_id        := NVL(fnd_global.CONC_LOGIN_ID,-1);
    l_program_application_id  := NVL(fnd_global.PROG_APPL_ID,-1);
    l_request_id              := NVL(fnd_global.CONC_REQUEST_ID,-1);

    /* copy from bound as max of existing to bound for the new organizations and insert records */
    /* this code inserts all new organizations from MMT without checking the existence of a
       transaction for them after global_start_date */
    /* find new organizations only on INCR load */
    if (p_load_type = 'INCR') then

        l_stmt_no := 10;
        FOR c_new_org IN csr_get_new_org LOOP
            INSERT INTO OPI_DBI_CONC_PROG_RUN_LOG(
                driving_table_code      ,
                etl_type                ,
                load_type               ,
                bound_type              ,
                bound_level_entity_code ,
                bound_level_entity_id   ,
                from_bound_date         ,
                from_bound_id           ,
                to_bound_date           ,
                to_bound_id             ,
                completion_status_code  ,
                stop_reason_code        ,
                created_by              ,
                creation_date           ,
                last_run_date           ,
                last_update_date        ,
                last_updated_by         ,
                last_update_login       ,
                program_id              ,
                program_login_id        ,
                program_application_id  ,
                request_id
                )
            SELECT
                'MMT'                   ,
                p_etl_type              ,
                'INCR'                  ,
                'ID'                    ,
                'ORGANIZATION'          ,
                c_new_org.organization_id ,
                null                    ,
                max(to_bound_id)        ,
                null                    ,
                null                    ,
                null                    ,
                null                    ,
                l_user_id               ,
                sysdate                 ,
                sysdate                 ,
                sysdate                 ,
                l_user_id               ,
                l_login_id              ,
                l_program_id           ,
                l_program_login_id     ,
                l_program_application_id,
                l_request_id
            FROM OPI_DBI_CONC_PROG_RUN_LOG
            WHERE etl_type  = p_etl_type
            AND   driving_table_code = 'MMT';
        END LOOP;

        IF l_debug_mode = 'Y' AND upper(l_module_name) like 'BIS%' THEN
             l_debug_msg := 'Inserted '||to_char(sql%rowcount)||' rows into OPI_DBI_CONC_PROG_RUN_LOG' ;
             opi_dbi_bounds_pkg.write(g_pkg_name, l_proc_name, l_stmt_no, l_debug_msg);
        END IF;

    end if;    /* end insert new org */

    l_max_trx_id := -1;
    l_stmt_no :=20;
    SELECT max(transaction_id)+1  INTO l_max_trx_id
    FROM mtl_material_transactions mmt;

    IF l_debug_mode = 'Y' AND upper(l_module_name) like 'BIS%' THEN
        l_debug_msg := 'Max transaction_id from MMT is '||to_char(l_max_trx_id)||' as on '||to_char(sysdate);
        opi_dbi_bounds_pkg.write(g_pkg_name, l_proc_name, l_stmt_no, l_debug_msg);
    END IF;

    l_stmt_no := 30;
        /* update to bounds for all records as first uncosted transaction */
    UPDATE OPI_DBI_CONC_PROG_RUN_LOG prlout
    SET   ( to_bound_id             ,
            stop_reason_code        ,
            completion_status_code  ,
            last_run_date           ,
            last_update_date        ,
            last_updated_by         ,
            last_update_login       ,
            program_id              ,
            program_login_id        ,
            program_application_id  ,
            request_id
            ) =
                (select
                 /* FIRST UNCOSTED TXN ID FOR THE ORGANIZATION.
                    MAX TRANSACTION OF MMT IN CASE THERE NO UNCOSTED TXN. */
                 nvl(uncosted_trx.transaction_id,l_max_trx_id),
                  /* stop reason code */
                 decode(uncosted_trx.transaction_id,NULL,'STOP_ALL_COSTED','STOP_UNCOSTED'),
                 null               ,
                 sysdate            ,
                 sysdate            ,
                 l_user_id          ,
                 l_login_id		 ,
                 l_program_id       ,
                 l_program_login_id ,
                 l_program_application_id,
                 l_request_id
                 from
                 (SELECT /*+ no_merge parallel(mmt) */ organization_id,min(transaction_id) transaction_id
                  FROM mtl_material_transactions mmt
                  WHERE costed_flag in('N','E')
		  AND transaction_id >= (SELECT from_bound_id FROM opi_dbi_conc_prog_run_log plog
					 WHERE plog.etl_type = p_etl_type
					 AND   plog.load_type = p_load_type
					 AND   plog.driving_table_code = 'MMT'
					 AND   plog.bound_level_entity_code = 'ORGANIZATION'
					 AND   mmt.organization_id = plog.bound_level_entity_id) --Bug 5096963
                  GROUP BY organization_id
                 ) uncosted_trx
			  , mtl_parameters mp
                where prlout.bound_level_entity_id  = mp.organization_id
			   and mp.organization_id = uncosted_trx.organization_id(+))
    WHERE prlout.driving_table_code = 'MMT'
    AND   prlout.etl_type           = p_etl_type
    AND   prlout.load_type          = p_load_type
    AND   prlout.bound_level_entity_code = 'ORGANIZATION';

    IF l_debug_mode = 'Y' AND upper(l_module_name) like 'BIS%' THEN
        l_debug_msg := 'Updated '||to_char(sql%rowcount)||' rows in OPI_DBI_CONC_PROG_RUN_LOG' ;
        opi_dbi_bounds_pkg.write(g_pkg_name, l_proc_name, l_stmt_no, l_debug_msg);
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        IF l_debug_mode = 'Y' AND upper(l_module_name) like 'BIS%' THEN
            l_debug_msg := SQLERRM ;
            opi_dbi_bounds_pkg.write(g_pkg_name, l_proc_name, l_stmt_no, l_debug_msg);
        END IF;
        RAISE;
END set_mmt_new_bounds;

PROCEDURE setup_inv_wta_bounds(p_load_type IN VARCHAR2)
IS
    l_user_id        NUMBER  := NVL(fnd_global.USER_ID, -1);
    l_login_id       NUMBER  := NVL(fnd_global.LOGIN_ID, -1);
    l_stmt_no        NUMBER :=0;
    l_proc_name             VARCHAR2(40);
    l_global_start_date     DATE;
    l_debug_msg               VARCHAR2(32767);
    l_debug_mode              VARCHAR2(1);
    l_module_name             VARCHAR2(40);

    l_program_id             NUMBER ;
    l_program_login_id       NUMBER ;
    l_program_application_id NUMBER ;
    l_request_id             NUMBER ;

BEGIN
    l_module_name             :=  FND_PROFILE.value('AFLOG_MODULE');
    l_debug_mode              :=  NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
    l_proc_name               :=  'setup_inv_wta_bounds';

    l_program_id              := NVL(fnd_global.CONC_PROGRAM_ID,-1);
    l_program_login_id        := NVL(fnd_global.CONC_LOGIN_ID,-1);
    l_program_application_id  := NVL(fnd_global.PROG_APPL_ID,-1);
    l_request_id              := NVL(fnd_global.CONC_REQUEST_ID,-1);


    l_stmt_no := 10;
    select BIS_COMMON_PARAMETERS.GET_GLOBAL_START_DATE into l_global_start_date from DUAL;

    if (l_global_start_date is NULL) then
        RAISE INITIALIZATION_ERROR ;
    end if;

    IF (p_load_type = 'INIT') THEN
    /* insert records with from_bound_id as first transaction after GSD and to_bound_id as max of
       transaction_id as of setting bounds from WTA */

            l_stmt_no := 20;
            INSERT into OPI_DBI_CONC_PROG_RUN_LOG(
                driving_table_code      ,
                etl_type                ,
                load_type               ,
                bound_type              ,
                bound_level_entity_code ,
                bound_level_entity_id   ,
                from_bound_date         ,
                from_bound_id           ,
                to_bound_date           ,
                to_bound_id             ,
                completion_status_code  ,
                stop_reason_code        ,
                created_by              ,
                creation_date           ,
                last_run_date           ,
                last_update_date        ,
                last_updated_by         ,
                last_update_login       ,
                program_id              ,
                program_login_id        ,
                program_application_id  ,
                request_id
			 )
            SELECT
                'WTA'               ,
                'INVENTORY'         ,
                'INIT'              ,
                'ID'                ,
                null                ,
                null                ,
                null                ,
                min(transaction_id) ,
                null                ,
                max(transaction_id)+1 ,
                null                ,
                null                ,
                l_user_id           ,
                sysdate             ,
                sysdate             ,
                sysdate             ,
                l_user_id           ,
                l_login_id		 ,
                l_program_id        ,
                l_program_login_id  ,
                l_program_application_id,
                l_request_id
            FROM wip_transaction_accounts
            WHERE transaction_date >= l_global_start_date;

		  IF l_debug_mode = 'Y' AND upper(l_module_name) like 'BIS%' THEN
                l_debug_msg := 'Inserted '||to_char(sql%rowcount)||' rows into OPI_DBI_CONC_PROG_RUN_LOG' ;
                opi_dbi_bounds_pkg.write(g_pkg_name, l_proc_name, l_stmt_no, l_debug_msg);
            END IF;

    ELSIF (p_load_type = 'INCR') then
    /* Update to_bound as max of transaction_id as of setting the bounds */
        l_stmt_no := 30;
        UPDATE OPI_DBI_CONC_PROG_RUN_LOG
        SET (to_bound_id                 ,
             completion_status_code      ,
             last_update_date            ,
             last_updated_by             ,
             last_update_login           ,
             program_id              ,
             program_login_id        ,
             program_application_id  ,
             request_id			  ) =
             (SELECT max(transaction_id)+1 ,
		                 null                ,
                     sysdate             ,
                     l_user_id           ,
                     l_login_id          ,
           		       l_program_id        ,
                     l_program_login_id  ,
                     l_program_application_id,
                     l_request_id
              FROM wip_transaction_accounts)
              WHERE   driving_table_code = 'WTA'
              AND     etl_type    = 'INVENTORY'
              AND     load_type   = p_load_type;

        IF l_debug_mode = 'Y' AND upper(l_module_name) like 'BIS%' THEN
            l_debug_msg := 'Updated '||to_char(sql%rowcount)||' rows in OPI_DBI_CONC_PROG_RUN_LOG' ;
            opi_dbi_bounds_pkg.write(g_pkg_name, l_proc_name, l_stmt_no, l_debug_msg);
        END IF;

    END IF;
EXCEPTION
   WHEN INITIALIZATION_ERROR THEN
        IF l_debug_mode = 'Y' AND upper(l_module_name) like 'BIS%' THEN
            l_debug_msg := 'Global Start Date is NULL' ;
            opi_dbi_bounds_pkg.write(g_pkg_name, l_proc_name, l_stmt_no, l_debug_msg);
        END IF;
        RAISE;
    WHEN OTHERS THEN
       IF l_debug_mode = 'Y' AND upper(l_module_name) like 'BIS%' THEN
            l_debug_msg := SQLERRM ;
            opi_dbi_bounds_pkg.write(g_pkg_name, l_proc_name, l_stmt_no, l_debug_msg);
        END IF;
        RAISE;
END setup_inv_wta_bounds ;


PROCEDURE set_sysdate_bounds(p_load_type IN VARCHAR2,
                             p_etl_type IN VARCHAR2,
                             p_driving_table_code IN VARCHAR2)
IS
    l_user_id                   NUMBER :=  NVL(fnd_global.USER_ID, -1);
    l_login_id                  NUMBER :=  NVL(fnd_global.LOGIN_ID, -1);
    l_stmt_no                   NUMBER :=0;
    l_proc_name                 VARCHAR2(40);
    l_global_start_date         DATE;
    l_debug_msg                 VARCHAR2(32767);
    l_debug_mode                VARCHAR2(1);
    l_module_name               VARCHAR2(40);
    l_program_id                NUMBER ;
    l_program_login_id          NUMBER ;
    l_program_application_id    NUMBER ;
    l_request_id                NUMBER ;


BEGIN

    l_module_name             :=  FND_PROFILE.value('AFLOG_MODULE');
    l_debug_mode              :=  NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
    l_proc_name               :=  'set_sysdate_bounds';

    l_program_id              := NVL(fnd_global.CONC_PROGRAM_ID,-1);
    l_program_login_id        := NVL(fnd_global.CONC_LOGIN_ID,-1);
    l_program_application_id  := NVL(fnd_global.PROG_APPL_ID,-1);
    l_request_id              := NVL(fnd_global.CONC_REQUEST_ID,-1);

    l_stmt_no :=10;
    select BIS_COMMON_PARAMETERS.GET_GLOBAL_START_DATE into l_global_start_date from DUAL;

    if (l_global_start_date is NULL) then
        RAISE INITIALIZATION_ERROR ;
    end if;

    if (p_load_type = 'INIT') then
        l_stmt_no := 20;
        INSERT into OPI_DBI_CONC_PROG_RUN_LOG(
            driving_table_code      ,
            etl_type                ,
            load_type               ,
            bound_type              ,
            bound_level_entity_code ,
            bound_level_entity_id   ,
            from_bound_date         ,
            from_bound_id           ,
            to_bound_date           ,
            to_bound_id             ,
            completion_status_code  ,
            stop_reason_code        ,
            created_by              ,
            creation_date           ,
            last_run_date           ,
            last_update_date        ,
            last_updated_by         ,
            last_update_login       ,
	          program_id              ,
            program_login_id        ,
            program_application_id  ,
            request_id		    )
        SELECT
            p_driving_table_code    ,
            p_etl_type              ,
            'INIT'                  ,
            'DATE'                  ,
            null                    ,
            null                    ,
            l_global_start_date     ,
            null                    ,
            sysdate                 ,
            null                    ,
            null                    ,
            null                    ,
            l_user_id               ,
            sysdate                 ,
            sysdate                 ,
            sysdate                 ,
            l_user_id               ,
            l_login_id              ,
            l_program_id            ,
            l_program_login_id      ,
            l_program_application_id,
            l_request_id
        FROM DUAL ;
        IF l_debug_mode = 'Y' AND upper(l_module_name) like 'BIS%' THEN
            l_debug_msg := 'Inserted '||to_char(sql%rowcount)||' rows into OPI_DBI_CONC_PROG_RUN_LOG' ;
            opi_dbi_bounds_pkg.write(g_pkg_name, l_proc_name, l_stmt_no, l_debug_msg);
        END IF;

    elsif (p_load_type = 'INCR') then
            l_stmt_no := 30;
            UPDATE OPI_DBI_CONC_PROG_RUN_LOG
            SET TO_BOUND_DATE           =   sysdate         ,
                completion_status_code  =   null            ,
                LAST_RUN_DATE           =   sysdate         ,
                LAST_UPDATE_DATE        =   sysdate         ,
                LAST_UPDATED_BY         =   l_user_id       ,
                LAST_UPDATE_LOGIN       =   l_login_id       ,
                PROGRAM_ID              =   l_program_id             ,
                PROGRAM_LOGIN_ID        =   l_program_login_id       ,
                PROGRAM_APPLICATION_ID  =   l_program_application_id ,
                REQUEST_ID		=   l_request_id
            WHERE   DRIVING_TABLE_CODE  =   p_driving_table_code
            AND     ETL_TYPE            =   p_etl_type
            AND     LOAD_TYPE           =   'INCR';
            IF l_debug_mode = 'Y' AND upper(l_module_name) like 'BIS%' THEN
                l_debug_msg := 'Updated '||to_char(sql%rowcount)||' rows in OPI_DBI_CONC_PROG_RUN_LOG' ;
                opi_dbi_bounds_pkg.write(g_pkg_name, l_proc_name, l_stmt_no, l_debug_msg);
            END IF;
    end if;

EXCEPTION
    WHEN INITIALIZATION_ERROR THEN
        IF l_debug_mode = 'Y' AND upper(l_module_name) like 'BIS%' THEN
            l_debug_msg := 'Global Start Date is NULL' ;
            opi_dbi_bounds_pkg.write(g_pkg_name, l_proc_name, l_stmt_no, l_debug_msg);
        END IF;
        RAISE;
    WHEN OTHERS THEN
       IF l_debug_mode = 'Y' AND upper(l_module_name) like 'BIS%' THEN
            l_debug_msg := SQLERRM ;
            opi_dbi_bounds_pkg.write(g_pkg_name, l_proc_name, l_stmt_no, l_debug_msg);
        END IF;
        RAISE;
END set_sysdate_bounds ;

PROCEDURE set_load_successful(p_etl_type  IN  VARCHAR2,
                              p_load_type IN VARCHAR2)
IS
    l_stmt_no       NUMBER := 0;
    l_proc_name     VARCHAR2(40);
    l_debug_msg     VARCHAR2(32767);
    l_debug_mode    VARCHAR2(1);
    l_module_name   VARCHAR2(40);

BEGIN
    l_module_name             :=  FND_PROFILE.value('AFLOG_MODULE');
    l_debug_mode              :=  NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
    l_proc_name               :=  'set_load_successful';

    l_stmt_no := 10;
    UPDATE OPI_DBI_CONC_PROG_RUN_LOG
    SET     completion_status_code = 'S'
    WHERE   etl_type  = p_etl_type
    AND     load_type = p_load_type;         /*update log table with status success */

    IF l_debug_mode = 'Y' AND upper(l_module_name) like 'BIS%' THEN
        l_debug_msg := 'Updated status to success for '||to_char(sql%rowcount)||' rows';
        opi_dbi_bounds_pkg.write(g_pkg_name, l_proc_name, l_stmt_no, l_debug_msg);
    END IF;

    IF l_debug_mode = 'Y' AND upper(l_module_name) like 'BIS%' THEN
        l_debug_msg := p_load_type||' load run for '||p_etl_type||' successful.';
        opi_dbi_bounds_pkg.write(g_pkg_name, l_proc_name, l_stmt_no, l_debug_msg);
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        IF l_debug_mode = 'Y' AND upper(l_module_name) like 'BIS%' THEN
            l_debug_msg := SQLERRM;
            opi_dbi_bounds_pkg.write(g_pkg_name, l_proc_name, l_stmt_no, l_debug_msg);
        END IF;
        RAISE;
END set_load_successful;


/*  Generic routine for writing debug messages */

PROCEDURE write (p_pkg_name    IN VARCHAR2,
                 p_proc_name   IN VARCHAR2,
                 p_stmt_no     IN NUMBER  ,
                 p_debug_msg   IN VARCHAR2)
IS
--    l_debug_mode  VARCHAR2(1);
    l_proc_name   VARCHAR2(40);
--    l_module_name VARCHAR2(40);
BEGIN
--    l_debug_mode              := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
--    l_module_name             := FND_PROFILE.value('AFLOG_MODULE');

/*
    insert into mano_log (pkg, proc_name, stmt_no,  msg )
    select p_pkg_name, p_proc_name, p_stmt_no, p_debug_msg from dual;
    commit;
*/
-- This API may be used to print other messages in addition to debug messages.Hence, the check is not done here.
--    IF l_debug_mode = 'Y' AND upper(l_module_name) like 'BIS%' THEN
        BIS_COLLECTION_UTILITIES.PUT_LINE(p_pkg_name ||'.'|| p_proc_name||': At statement '
                                          || p_stmt_no ||'#, '||p_debug_msg);
--    END IF;
END write;

/*===============================================================
    This procedure prints the MMT bounds at which the Discrete
    load stopped and the reason for stopping.

    Parameters:
    - p_etl_type: ETL type
    - p_load_type: ETL load type (INIT/INCR)
=================================================================*/

PROCEDURE print_opi_org_bounds (p_etl_type IN VARCHAR2,
                                p_load_type IN VARCHAR2) IS

    l_proc_name CONSTANT VARCHAR2 (60) := 'print_opi_org_bounds';
    l_stmt_id NUMBER;

    -- Cursor for all the org bounds

    CURSOR opi_org_bounds_csr IS
        SELECT  mp.organization_code,
                log.to_bound_id,
                decode (log.stop_reason_code,
                       STOP_ALL_COSTED, 'All Costed',
                       STOP_UNCOSTED, 'Uncosted',
                       'Data Issue?') stop_reason,
                nvl (mmt.transaction_date, sysdate) data_until
        FROM    opi_dbi_conc_prog_run_log log,
                mtl_parameters mp,
                mtl_material_transactions mmt
        WHERE   log.driving_table_code = 'MMT'
        AND     log.to_bound_id = mmt.transaction_id (+)
        AND     log.bound_level_entity_id = mp.organization_id
        AND     log.etl_type = p_etl_type
        AND     log.load_type = p_load_type;

BEGIN

  bis_collection_utilities.put_line('Enter print_opi_org_bounds() '||
                     To_char(Sysdate, 'hh24:mi:ss dd-mon-yyyy'));

    -- initialization block
    l_stmt_id := 0;

    -- print the header
    l_stmt_id := 10;

    bis_collection_utilities.put_line (
            RPAD ('Organization Code', 20) ||
            RPAD ('Last Collected Txn Id', 25) ||
            RPAD ('Data Collected Until', 25) ||
            RPAD ('Reason Stopped', 20));

    bis_collection_utilities.put_line (
            RPAD ('-----------------', 20) ||
            RPAD ('---------------------', 25) ||
            RPAD ('--------------------', 25) ||
            RPAD ('--------------', 20));
     -- just print all the bounds
    l_stmt_id := 20;
    FOR opi_org_bounds_rec IN opi_org_bounds_csr
    LOOP
        bis_collection_utilities.put_line (
                RPAD (opi_org_bounds_rec.organization_code, 20) ||
                RPAD (opi_org_bounds_rec.to_bound_id, 25) ||
                RPAD (opi_org_bounds_rec.data_until, 25) ||
                RPAD (opi_org_bounds_rec.stop_reason, 20));

    END LOOP;


    -- print table end
    l_stmt_id := 30;


        bis_collection_utilities.put_line(LPAD ('', 90, '-'));

    RETURN;

    bis_collection_utilities.put_line('Exit print_opi_org_bounds() '||
                     To_char(Sysdate, 'hh24:mi:ss dd-mon-yyyy'));

EXCEPTION

    WHEN OTHERS THEN
    --{
        rollback;

        bis_collection_utilities.put_line ('Error when printing org bounds.');

        RAISE;    -- propagate exception to wrapper
    --}

END print_opi_org_bounds;


/*========================================================================

    Return true if some rows have bounds that show uncosted transactions.
    This can only happen for OPI sourced Material ETLs.

    Such rows will be distinguished by the fact that their stop reason
    code will be STOP_UNCOSTED. This means that the stop reason code
    must not have been wiped out by the etl_report_success API

    Parameters:
    - p_etl_type: ETL Type

    Date        Author              Action
    04/23/03    Dinkar Gupta        Wrote Function
    07/01/05    Julia Zhang         Modified to refer to new log table
========================================================================*/
FUNCTION bounds_uncosted (p_etl_type IN VARCHAR2,
                          p_load_type IN VARCHAR2) RETURN BOOLEAN IS

    l_proc_name CONSTANT VARCHAR2 (60) := 'bounds_uncosted';
    l_stmt_id NUMBER;
    l_bounds_uncosted BOOLEAN;
    l_warning NUMBER;

BEGIN

    bis_collection_utilities.put_line('Enter bounds_uncosted() '||
                     To_char(Sysdate, 'hh24:mi:ss dd-mon-yyyy'));

    -- initialization block
    l_stmt_id := 0;
    l_bounds_uncosted := false;
    l_warning := g_ok;

    -- check if any row has uncosted transactions
    l_stmt_id := 10;
    BEGIN
        SELECT  g_warning
        INTO    l_warning
        FROM    OPI_DBI_CONC_PROG_RUN_LOG
        WHERE   stop_reason_code = STOP_UNCOSTED
        AND     etl_type = p_etl_type
        AND     load_type = p_load_type
        AND     rownum = 1;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            l_warning := g_ok;
    END;

    -- If there are uncosted transactions, return true
    l_stmt_id := 20;
    IF (l_warning = g_warning) THEN
    --{
        l_bounds_uncosted := true;
    --}
    END IF;

    RETURN l_bounds_uncosted;

    bis_collection_utilities.put_line('Exit bounds_uncosted() '||
                     To_char(Sysdate, 'hh24:mi:ss dd-mon-yyyy'));

END bounds_uncosted;


/*===================================================================================
-- This API would insert the ORGANIZATION_ID, LEDGER_ID, LEGAL_ENTITY_ID,COST_TYPE_ID
-- for all the process orgs. This API would be called from each ETL prior to calling
-- OPM loads. Each ETL query would join to the table OPI_DBI_ORG_LE_TEMP to extract rows
-- from gmf_transaction_valuation for an inventory organization corresponding to a
-- specific legal entity/ledger(primary)/cost type/period.

    Date        Author              Action
    11/29/05    Suhasini            Wrote Procedure
======================================================================================*/

PROCEDURE load_opm_org_ledger_data
IS
	l_stmt_no              NUMBER :=0;
	l_proc_name            VARCHAR2(40);
        l_debug_msg            VARCHAR2(32767);
        l_debug_mode           VARCHAR2(1);
        l_module_name          VARCHAR2(40);
BEGIN
        l_proc_name               :=  'load_opm_org_ledger_data';
        l_debug_mode              :=  NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
        l_module_name             :=  FND_PROFILE.value('AFLOG_MODULE');

	-- Deleting rows from the temp table to avoid any undesirable data.

	l_stmt_no  := 10;
	DELETE FROM OPI_DBI_ORG_LE_TEMP;

        IF l_debug_mode = 'Y' AND upper(l_module_name) like 'BIS%' THEN
            l_debug_msg := 'Deleted '||to_char(sql%rowcount)||' rows from OPI_DBI_ORG_LE_TEMP' ;
            opi_dbi_bounds_pkg.write(g_pkg_name, l_proc_name, l_stmt_no, l_debug_msg);
        END IF;

	-- Inserting rows into the temp table from org_organization_definitions and
	-- gmf_fiscal_policies

	l_stmt_no  := 20;
	INSERT INTO OPI_DBI_ORG_LE_TEMP
	(
	  organization_id	   ,
	  ledger_id	           ,
	  legal_entity_id 	   ,
	  valuation_cost_type_id
	)
	SELECT ood.organization_id ,
	       gfp.ledger_id	   ,
	       gfp.legal_entity_id ,
	       gfp.cost_type_id
	FROM ORG_ORGANIZATION_DEFINITIONS ood,
	      GMF_FISCAL_POLICIES gfp,
	      MTL_PARAMETERS mp
	WHERE mp.process_enabled_flag = 'Y'            --for OPM orgs only
	AND mp.organization_id = ood.organization_id
	AND ood.legal_entity = gfp.legal_entity_id ;

        IF l_debug_mode = 'Y' AND upper(l_module_name) like 'BIS%' THEN
            l_debug_msg := 'Inserted '||to_char(sql%rowcount)||' rows from OPI_DBI_ORG_LE_TEMP' ;
            opi_dbi_bounds_pkg.write(g_pkg_name, l_proc_name, l_stmt_no, l_debug_msg);
        END IF;

EXCEPTION
      WHEN OTHERS THEN
        IF l_debug_mode = 'Y' AND upper(l_module_name) like 'BIS%' THEN
            l_debug_msg := 'Error in deleting/inserting OPM org ledger data into OPI_DBI_ORG_LE_TEMP' ;
            opi_dbi_bounds_pkg.write(g_pkg_name, l_proc_name, l_stmt_no, l_debug_msg);
        END IF;
        RAISE;
END load_opm_org_ledger_data;

END opi_dbi_bounds_pkg;

/
