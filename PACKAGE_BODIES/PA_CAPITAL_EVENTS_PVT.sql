--------------------------------------------------------
--  DDL for Package Body PA_CAPITAL_EVENTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_CAPITAL_EVENTS_PVT" AS
/* $Header: PACACCBB.pls 120.1 2005/06/10 03:22:22 avajain noship $ */


 PROCEDURE CREATE_PERIODIC_EVENTS
   (errbuf                  OUT NOCOPY VARCHAR2,
    retcode                 OUT NOCOPY VARCHAR2,
    p_event_period_name     IN      VARCHAR2,
    p_asset_date_through_arg    IN      VARCHAR2,
    p_ei_date_through_arg       IN      VARCHAR2 DEFAULT NULL,
    p_project_id 	    IN	    NUMBER DEFAULT NULL) IS


    p_asset_date_through    DATE;
    p_ei_date_through       DATE;

    CURSOR ac_projects_cur IS
    SELECT  p.project_id,
            p.segment1 project_number,
            p.name project_name,
            p.asset_allocation_method
    FROM    pa_projects p,
            pa_project_types pt
    WHERE   p.project_type = pt.project_type
    AND     pt.project_type_class_code = 'CAPITAL'
    AND     NVL(p.capital_event_processing,'N') = 'P'
    AND     p.project_id = NVL(p_project_id, p.project_id)
    AND     p.template_flag = 'N'
    ORDER BY p.segment1;

    ac_projects_rec          ac_projects_cur%ROWTYPE;

    v_user_id                   NUMBER := FND_GLOBAL.user_id;
    v_login_id                  NUMBER := FND_GLOBAL.login_id;
    v_request_id                NUMBER := FND_GLOBAL.conc_request_id;
    v_program_application_id    NUMBER := FND_GLOBAL.prog_appl_id;
    v_program_id                NUMBER := FND_GLOBAL.conc_program_id;
    v_null_rowid                ROWID  := NULL;
    -- v_org_id                    NUMBER := TO_NUMBER(FND_PROFILE.value('ORG_ID'));
    v_org_id                    NUMBER := PA_MOAC_UTILS.get_current_org_id  ;

    v_project_number            pa_projects_all.segment1%TYPE;
    v_ret_assets_count          NUMBER := 0;
    v_ret_tasks_count           NUMBER := 0;
    v_return_status             VARCHAR2(1);
    v_msg_data                  VARCHAR2(2000);

    PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

    p_event_period_name_missing     EXCEPTION;
    p_asset_date_through_missing    EXCEPTION;
    unexp_error_in_client_extn      EXCEPTION;
    error_in_client_extn            EXCEPTION;

    --This local procedure is used to print the control report and associated
    --messages regarding the creation of periodic events for each project processed.
    PROCEDURE print_report IS

        CURSOR report_cur (x_conc_request_id  NUMBER) IS
        SELECT  pe.project_number,
                pe.project_id,
                p.name project_name,
                pe.capital_type,
                pl2.meaning capital_type_desc,
                pe.context,
                pe.sub_context,
                pe.capital_event_id,
                DECODE(sub_context,'A',UPPER(asset_name)||' ',
                           'AT',UPPER(asset_name)||' ',
                           NULL)||
                    pl.meaning||' '||
                    DECODE(sub_context,'E',capital_event_number||' '||event_name,
                                   'AE',capital_event_number||' '||event_name,
                                   'CE',capital_event_number||' '||event_name,
                                   'P',project_number,
                                   'T',task_number,
                                   'AT',task_number) formatted_message
        FROM    pa_cap_event_creation_v pe,
                pa_lookups pl,
                pa_lookups pl2,
                pa_projects p
        WHERE   pe.request_id = x_conc_request_id
        AND     pl.lookup_type = 'PERIODIC_EVENT_CREATION'
        AND     pl.lookup_code = pe.message_code
        AND     pl2.lookup_type = 'CAPITAL_TYPE'
        AND     pl2.lookup_code = pe.capital_type
        AND     pe.project_id = p.project_id (+)
        ORDER BY pe.project_id,
                pe.capital_type,
                pe.context;

        report_rec               report_cur%ROWTYPE;


        CURSOR assets_added_cur (x_project_id  NUMBER, x_capital_event_id  NUMBER) IS
        SELECT  asset_name,
                asset_description
        FROM    pa_project_assets_all
        WHERE   project_id = x_project_id
        AND     capital_event_id = x_capital_event_id
        AND     request_id = v_request_id;

        assets_added_rec         assets_added_cur%ROWTYPE;


        CURSOR costs_added_cur (x_project_id  NUMBER, x_capital_event_id  NUMBER, x_cost_type  VARCHAR2) IS
        SELECT  SUM(DECODE(x_cost_type,'R',NVL(raw_cost,0),NVL(burden_cost,0))) total_cost
        FROM    pa_expenditure_items_all
        WHERE   project_id = x_project_id
        AND     capital_event_id = x_capital_event_id
        AND     request_id = v_request_id;

        costs_added_rec         costs_added_cur%ROWTYPE;


        CURSOR current_costs_cur (x_project_id  NUMBER, x_capital_event_id  NUMBER, x_cost_type  VARCHAR2) IS
        SELECT  SUM(DECODE(x_cost_type,'R',NVL(raw_cost,0),NVL(burden_cost,0))) total_cost
        FROM    pa_expenditure_items_all
        WHERE   project_id = x_project_id
        AND     capital_event_id = x_capital_event_id;

        current_costs_rec         current_costs_cur%ROWTYPE;


        curr_project_id         NUMBER;
        curr_capital_type       PA_REPORTING_EXCEPTIONS.record_type%TYPE;
        curr_context            PA_REPORTING_EXCEPTIONS.context%TYPE;
        v_cost_type             PA_PROJECT_TYPES.capital_cost_type_code%TYPE;
        v_report_title          PA_LOOKUPS.meaning%TYPE;
        v_proj_heading1         PA_LOOKUPS.meaning%TYPE;
        v_proj_heading2         PA_LOOKUPS.meaning%TYPE;
        v_event_information     PA_LOOKUPS.meaning%TYPE;
        v_assets_included       PA_LOOKUPS.meaning%TYPE;
        v_cost_included         PA_LOOKUPS.meaning%TYPE;
        v_assets_added          PA_LOOKUPS.meaning%TYPE;
        v_cost_added            PA_LOOKUPS.meaning%TYPE;
        v_total_cost            PA_LOOKUPS.meaning%TYPE;

    BEGIN

        --Get translated Report Title
        SELECT  meaning
        INTO    v_report_title
        FROM    pa_lookups
        WHERE   lookup_type = 'PERIODIC_EVENT_CREATION'
        AND     lookup_code = 'REPORT_TITLE';

        --Get translated Report Heading 1
        SELECT  meaning
        INTO    v_proj_heading1
        FROM    pa_lookups
        WHERE   lookup_type = 'PERIODIC_EVENT_CREATION'
        AND     lookup_code = 'PROJ_HEADING_1';

        --Get translated Report Heading 2
        SELECT  meaning
        INTO    v_proj_heading2
        FROM    pa_lookups
        WHERE   lookup_type = 'PERIODIC_EVENT_CREATION'
        AND     lookup_code = 'PROJ_HEADING_2';


        --Get translated "Event Information" literal
        SELECT  meaning
        INTO    v_event_information
        FROM    pa_lookups
        WHERE   lookup_type = 'PERIODIC_EVENT_CREATION'
        AND     lookup_code = 'EVENT_INFO';

        --Get translated "Assets Included" heading
        SELECT  meaning
        INTO    v_assets_included
        FROM    pa_lookups
        WHERE   lookup_type = 'PERIODIC_EVENT_CREATION'
        AND     lookup_code = 'ASSETS_INCLUDED';

        --Get translated "Cost Included" heading
        SELECT  meaning
        INTO    v_cost_included
        FROM    pa_lookups
        WHERE   lookup_type = 'PERIODIC_EVENT_CREATION'
        AND     lookup_code = 'COST_INCLUDED';

        --Get translated "Assets Added" heading
        SELECT  meaning
        INTO    v_assets_added
        FROM    pa_lookups
        WHERE   lookup_type = 'PERIODIC_EVENT_CREATION'
        AND     lookup_code = 'ASSETS_ADDED';

        --Get translated "Cost Added" heading
        SELECT  meaning
        INTO    v_cost_added
        FROM    pa_lookups
        WHERE   lookup_type = 'PERIODIC_EVENT_CREATION'
        AND     lookup_code = 'COST_ADDED';

        --Get translated "Total Cost" heading
        SELECT  meaning
        INTO    v_total_cost
        FROM    pa_lookups
        WHERE   lookup_type = 'PERIODIC_EVENT_CREATION'
        AND     lookup_code = 'TOTAL_COST';


        --Print Report Title
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,TO_CHAR(sysdate,'DD-MON-YYYY')||
                                '                         '||v_report_title);
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,fnd_global.local_chr(10));



        FOR report_rec IN report_cur(v_request_id) LOOP

            IF NVL(curr_project_id,-1) <> report_rec.project_id THEN

                --Print Project Header

                FND_FILE.PUT_LINE(FND_FILE.OUTPUT,fnd_global.local_chr(10));
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT,fnd_global.local_chr(10));
-- Replaced with translated lookup values for headings
--                FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD('Project Number',25,' ')||RPAD('Project Name',30,' '));
--                FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD('==============',25,' ')||RPAD('============',30,' '));
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT,v_proj_heading1);
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT,v_proj_heading2);
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD(report_rec.project_number,25,' ')||RPAD(report_rec.project_name,30,' '));

                curr_project_id := report_rec.project_id;
                curr_capital_type := 'X';
                curr_context := report_rec.context;

                --Get Cost Type
                SELECT  pt.capital_cost_type_code
                INTO    v_cost_type
                FROM    pa_projects p,
                        pa_project_types pt
                WHERE   p.project_type = pt.project_type
                AND     p.project_id = report_rec.project_id;

            END IF;



            IF NVL(curr_capital_type,'X') <> report_rec.capital_type THEN

                --Print Project Header
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT,fnd_global.local_chr(10));
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT,report_rec.capital_type_desc||' '||v_event_information);
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'----------------------------------------');

                curr_capital_type := report_rec.capital_type;
                curr_context := report_rec.context;
            END IF;


            --Print blank line for report formatting during control break
            IF report_rec.context = '3' THEN

                --Print Blank Line
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT,fnd_global.local_chr(10));

            END IF;


            --Print blank line for report formatting during control break
            IF NVL(curr_context,report_rec.context) <> report_rec.context
                AND NVL(curr_context,'X') = '1' THEN

                --Print Blank Line
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT,fnd_global.local_chr(10));

                curr_context := report_rec.context;
            END IF;


            --Print message line
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT,report_rec.formatted_message);


            --Print listing of Assets Added to New Events along with Event Cost Total
            IF report_rec.sub_context = 'E' THEN

                 FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'     '||v_assets_included);

                 FOR assets_added_rec IN assets_added_cur(report_rec.project_id, report_rec.capital_event_id) LOOP
                      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'          '||assets_added_rec.asset_name||' - '||assets_added_rec.asset_description);
                 END LOOP;

                 FOR costs_added_rec IN costs_added_cur(report_rec.project_id, report_rec.capital_event_id, v_cost_type) LOOP
                      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,fnd_global.local_chr(10));
                      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'     '||v_cost_included||' '||TO_CHAR(costs_added_rec.total_cost,pa_currency.currency_fmt_mask(15)));
                 END LOOP;

            END IF;


            --Print listing of Assets Added to Existing Event
            IF report_rec.sub_context = 'AE' THEN

                 FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'     '||v_assets_added);

                 FOR assets_added_rec IN assets_added_cur(report_rec.project_id, report_rec.capital_event_id) LOOP
                      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'          '||assets_added_rec.asset_name||' - '||assets_added_rec.asset_description);
                 END LOOP;

            END IF;


            --Print Total of Costs Added to Existing Event
            IF report_rec.sub_context = 'CE' THEN

                 FOR costs_added_rec IN costs_added_cur(report_rec.project_id, report_rec.capital_event_id, v_cost_type) LOOP
                      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'     '||v_cost_added||' '||TO_CHAR(costs_added_rec.total_cost,pa_currency.currency_fmt_mask(15)));
                 END LOOP;


                --Print current Cost Total for Existing Event

                 FOR current_costs_rec IN current_costs_cur(report_rec.project_id, report_rec.capital_event_id, v_cost_type) LOOP
                      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,fnd_global.local_chr(10));
                      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'     '||v_total_cost||' '||TO_CHAR(current_costs_rec.total_cost,pa_currency.currency_fmt_mask(15)));
                 END LOOP;

            END IF;

        END LOOP;

    END;



 BEGIN
    --Initialize variables
    retcode := 0;
    errbuf := NULL;
    PA_DEBUG.SET_PROCESS(x_process    => 'PLSQL',
                         x_debug_mode => PG_DEBUG);

    PA_DEBUG.WRITE_FILE('LOG', TO_CHAR(SYSDATE,'HH:MI:SS')||': PA_DEBUG_MODE: '||PG_DEBUG);

    --CHANGING date arguments from VARCHAR2 TO DATE
    p_asset_date_through := fnd_date.canonical_to_date(p_asset_date_through_arg);
    p_ei_date_through    := fnd_date.canonical_to_date(p_ei_date_through_arg);

    --Validate the required parameters
    IF  p_event_period_name IS NULL THEN
        RAISE p_event_period_name_missing;
    END IF;

    IF  p_asset_date_through IS NULL THEN
        RAISE p_asset_date_through_missing;
    END IF;


   	IF PG_DEBUG = 'Y' THEN
       PA_DEBUG.WRITE_FILE('LOG',TO_CHAR(SYSDATE,'HH:MI:SS')||': '||'Opening ac_projects_cur');
    END IF;


    --Verify that project(s) exist to process
    OPEN ac_projects_cur;
    FETCH ac_projects_cur INTO ac_projects_rec;

    IF (ac_projects_cur%NOTFOUND) THEN

        IF p_project_id IS NOT NULL THEN

            SELECT  segment1
            INTO    v_project_number
            FROM    pa_projects_all
            WHERE   project_id = p_project_id;


            INSERT INTO pa_cap_event_creation_v
                (request_id,
                 module,
                 context,
	             sub_context,
                 capital_type,
                 project_id,
                 project_number,
                 project_asset_id,
                 asset_name,
                 task_id,
                 task_number,
                 capital_event_id,
                 capital_event_number,
                 event_name,
                 event_type,
                 message_code,
                 created_by,
                 creation_date,
                 org_id
                 )
            VALUES
                (v_request_id,
                 'PERIODIC_EVENT_CREATION', --module
                 '1', --context (1 = Message)
	             'N', --sub_context
                 'C', --capital_type,
                 p_project_id, --project_id,
                 v_project_number, --project_number,
                 NULL, --project_asset_id,
                 NULL, --asset_name,
                 NULL, --task_id,
                 NULL, --task_number,
                 NULL, --capital_event_id,
                 NULL, --capital_event_number,
                 NULL, --event_name,
                 NULL, --event_type,
                 'PROJECT_NOT_FOUND',
                 v_user_id, --created_by,
                 SYSDATE, --creation_date,
                 v_org_id --org_id
                 );

        ELSE
            INSERT INTO pa_cap_event_creation_v
                (request_id,
                 module,
                 context,
	             sub_context,
                 capital_type,
                 project_id,
                 project_number,
                 project_asset_id,
                 asset_name,
                 task_id,
                 task_number,
                 capital_event_id,
                 capital_event_number,
                 event_name,
                 event_type,
                 message_code,
                 created_by,
                 creation_date,
                 org_id
                 )
            VALUES
                (v_request_id,
                 'PERIODIC_EVENT_CREATION', --module
                 '1', --context (1 = Message)
	             'N', --sub_context
                 'C', --capital_type,
                 NULL, --project_id,
                 NULL, --project_number,
                 NULL, --project_asset_id,
                 NULL, --asset_name,
                 NULL, --task_id,
                 NULL, --task_number,
                 NULL, --capital_event_id,
                 NULL, --capital_event_number,
                 NULL, --event_name,
                 NULL, --event_type,
                 'NO_PROJECTS_FOUND',
                 v_user_id, --created_by,
                 SYSDATE, --creation_date,
                 v_org_id --org_id
                 );
        END IF;
    END IF;
    CLOSE ac_projects_cur;


    --Loop through all "Periodic Event Creation" projects
    FOR ac_projects_rec IN ac_projects_cur LOOP

   	    IF PG_DEBUG = 'Y' THEN
            PA_DEBUG.WRITE_FILE('LOG',TO_CHAR(SYSDATE,'HH:MI:SS')||': '||'Calling pre_capital_event client extension for project id: '||ac_projects_rec.project_id);
        END IF;

        --Call the PRE_CAPITAL_EVENT client extension
        PA_CLIENT_EXTN_PRE_CAP_EVENT.PRE_CAPITAL_EVENT
                (p_project_id              => ac_projects_rec.project_id,
                 p_event_period_name       => p_event_period_name,
                 p_asset_date_through      => p_asset_date_through,
                 p_ei_date_through         => p_ei_date_through,
                 x_return_status           => v_return_status,
                 x_msg_data                => v_msg_data);

        IF v_return_status = 'E' THEN
       	    IF PG_DEBUG = 'Y' THEN
                PA_DEBUG.WRITE_FILE('LOG',TO_CHAR(SYSDATE,'HH:MI:SS')||': '||'Error in pre_capital_event client extension for project id: '||ac_projects_rec.project_id);
            END IF;

            RAISE error_in_client_extn;
        ELSIF v_return_status = 'U' THEN
            IF PG_DEBUG = 'Y' THEN
                PA_DEBUG.WRITE_FILE('LOG',TO_CHAR(SYSDATE,'HH:MI:SS')||': '||'Unexpected Error in pre_capital_event client extension for project id: '||ac_projects_rec.project_id);
            END IF;

            RAISE unexp_error_in_client_extn;
        END IF;



        PA_CAPITAL_EVENTS_PVT.CREATE_EVENT_FOR_PROJECT
	       (errbuf                    => errbuf,
            retcode                   => retcode,
            p_event_period_name       => p_event_period_name,
            p_asset_date_through      => p_asset_date_through,
            p_ei_date_through         => p_ei_date_through,
            p_project_id 	          => ac_projects_rec.project_id,
            p_event_type              => 'C',
            p_project_number          => ac_projects_rec.project_number,
            p_asset_allocation_method => ac_projects_rec.asset_allocation_method);


        --Determine if any Retirement Cost Tasks exist for the current project
        SELECT  COUNT(*)
        INTO    v_ret_tasks_count
        FROM    pa_tasks
        WHERE   project_id = ac_projects_rec.project_id
        AND     NVL(retirement_cost_flag,'N') = 'Y';

        --Determine if any Retirement Adjustment Assets assets exist for the current project
        SELECT  COUNT(*)
        INTO    v_ret_assets_count
        FROM    pa_project_assets
        WHERE   project_id = ac_projects_rec.project_id
        AND     project_asset_type = 'RETIREMENT_ADJUSTMENT';


        IF (v_ret_tasks_count > 0) OR (v_ret_assets_count > 0) THEN

            PA_CAPITAL_EVENTS_PVT.CREATE_EVENT_FOR_PROJECT
	           (errbuf                    => errbuf,
                retcode                   => retcode,
                p_event_period_name       => p_event_period_name,
                p_asset_date_through      => p_asset_date_through,
                p_ei_date_through         => p_ei_date_through,
                p_project_id 	          => ac_projects_rec.project_id,
                p_event_type              => 'R',
                p_project_number          => ac_projects_rec.project_number,
                p_asset_allocation_method => ac_projects_rec.asset_allocation_method);

        END IF;

        COMMIT;

    END LOOP;  --Periodic Event Creation projects


/* Print control report */

    print_report;




 EXCEPTION
    WHEN p_event_period_name_missing THEN
        retcode := -10;
        errbuf := 'Parameter p_event_period_name is required.';
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,errbuf);
        FND_FILE.PUT_LINE(FND_FILE.LOG,errbuf);
        fnd_msg_pub.add_exc_msg(p_pkg_name     => 'PA_CAPITAL_EVENTS_PVT',
                                p_procedure_name => 'CREATE_PERIODIC_EVENT',
                                p_error_text => SUBSTRB(errbuf,1,240));
        ROLLBACK;
        RAISE;


    WHEN p_asset_date_through_missing THEN
        retcode := -20;
        errbuf := 'Parameter p_asset_through_date is required.';
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,errbuf);
        FND_FILE.PUT_LINE(FND_FILE.LOG,errbuf);
        fnd_msg_pub.add_exc_msg(p_pkg_name     => 'PA_CAPITAL_EVENTS_PVT',
                                p_procedure_name => 'CREATE_PERIODIC_EVENT',
                                p_error_text => SUBSTRB(errbuf,1,240));
        ROLLBACK;
        RAISE;


    WHEN error_in_client_extn THEN
        retcode := -40;
        errbuf := 'Error in PRE_CAPITAL_EVENT client extension for project id '||ac_projects_rec.project_id||' '||v_msg_data;
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,errbuf);
        FND_FILE.PUT_LINE(FND_FILE.LOG,errbuf);
        fnd_msg_pub.add_exc_msg(p_pkg_name     => 'PA_CLIENT_EXTN_PRE_CAP_EVENT',
                                p_procedure_name => 'PRE_CAPITAL_EVENT',
                                p_error_text => SUBSTRB(v_msg_data,1,240));
        ROLLBACK;
        RAISE;


    WHEN unexp_error_in_client_extn THEN
        retcode := -50;
        errbuf := 'Unexpected error in PRE_CAPITAL_EVENT client extn for project id '||ac_projects_rec.project_id||' '||v_msg_data;
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,errbuf);
        FND_FILE.PUT_LINE(FND_FILE.LOG,errbuf);
        fnd_msg_pub.add_exc_msg(p_pkg_name     => 'PA_CLIENT_EXTN_PRE_CAP_EVENT',
                                p_procedure_name => 'PRE_CAPITAL_EVENT',
                                p_error_text => SUBSTRB(v_msg_data,1,240));
        ROLLBACK;
        RAISE;

    WHEN OTHERS THEN
        retcode := SQLCODE;
        errbuf := 'Unexpected error for project id '||
                        ac_projects_rec.project_id||': '||SQLCODE||' '||SQLERRM;
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,errbuf);
        FND_FILE.PUT_LINE(FND_FILE.LOG,errbuf);
        fnd_msg_pub.add_exc_msg(p_pkg_name     => 'PA_CAPITAL_EVENTS_PVT',
                                p_procedure_name => 'CREATE_PERIODIC_EVENT',
                                p_error_text => SUBSTRB(errbuf,1,240));
        ROLLBACK;
        RAISE;


 END CREATE_PERIODIC_EVENTS;



 PROCEDURE CREATE_EVENT_FOR_PROJECT
	(errbuf                  OUT NOCOPY VARCHAR2,
    retcode                  OUT NOCOPY VARCHAR2,
    p_event_period_name     IN      VARCHAR2,
    p_asset_date_through    IN      DATE,
    p_ei_date_through       IN      DATE,
    p_project_id 	        IN	    NUMBER,
    p_event_type            IN      VARCHAR2,
    p_project_number        IN      VARCHAR2,
    p_asset_allocation_method IN    VARCHAR2) IS



    CURSOR capital_event_cur(x_project_id  NUMBER,
                             x_event_type  VARCHAR2) IS
    SELECT  capital_event_id,
            capital_event_number,
            event_name
    FROM    pa_capital_events
    WHERE   project_id = x_project_id
    AND     event_period = p_event_period_name
    AND     event_type = x_event_type
    ORDER BY capital_event_id;

    capital_event_rec          capital_event_cur%ROWTYPE;


    CURSOR add_ei_tasks_cur(x_project_id  NUMBER,
                            x_event_type  VARCHAR2) IS
    SELECT  task_id
    FROM    pa_tasks
    WHERE   project_id = x_project_id
    AND     NVL(retirement_cost_flag,'N') = DECODE(x_event_type,'R','Y','N')
    ORDER BY task_id;

    add_ei_tasks_rec          add_ei_tasks_cur%ROWTYPE;


    CURSOR new_assets_cur(x_project_id  NUMBER,
                          x_event_type  VARCHAR2) IS
    SELECT  pa.project_asset_id,
            paa.task_id, --Grouping Level: If = 0, asset is assigned to project
            t.retirement_cost_flag task_retirement_cost_flag  --Will be NULL if Task ID = 0
    FROM    pa_project_assets_all pa,
            pa_project_asset_assignments paa,
            pa_tasks t
    WHERE   pa.project_id = x_project_id
    AND     pa.project_asset_id = paa.project_asset_id
    AND     pa.capital_event_id IS NULL
    AND     pa.project_asset_type = DECODE(x_event_type,'C','AS-BUILT','RETIREMENT_ADJUSTMENT')
    AND     pa.date_placed_in_service IS NOT NULL
    AND     pa.date_placed_in_service <= p_asset_date_through
    AND     paa.task_id = t.task_id (+)
    ORDER BY pa.project_asset_id, paa.task_id;

    new_assets_rec             new_assets_cur%ROWTYPE;


    CURSOR common_tasks_cur(x_project_id  NUMBER,
                            x_event_type  VARCHAR2) IS
    SELECT  t.task_id,
            paa.task_id assignment_task_id,
            t.top_task_id,
            t.parent_task_id
    FROM    pa_project_asset_assignments paa,
            pa_tasks t
    WHERE   paa.project_id = x_project_id
    AND     NVL(t.retirement_cost_flag,'N') = DECODE(x_event_type,'R','Y','N')
    AND     paa.project_asset_id = 0
    AND     (paa.task_id = t.task_id
            OR paa.task_id = t.top_task_id);

    common_tasks_rec           common_tasks_cur%ROWTYPE;


    CURSOR remaining_costs_cur(x_project_id  NUMBER,
                               x_event_type  VARCHAR2) IS
    SELECT  peia.task_id
    FROM    pa_expenditure_items_all peia,
            pa_tasks t
    WHERE   peia.project_id = x_project_id
    AND     peia.task_id = t.task_id
    AND     t.project_id = x_project_id
    AND     NVL(t.retirement_cost_flag,'N') = DECODE(x_event_type,'R','Y','N')
    AND     peia.billable_flag = DECODE(x_event_type,'C','Y','N')
    AND     peia.capital_event_id IS NULL
    AND     peia.expenditure_item_date <= NVL(p_ei_date_through, peia.expenditure_item_date)
    AND     peia.revenue_distributed_flag = 'N'
    AND     peia.cost_distributed_flag = 'Y'
    GROUP BY peia.task_id;

    remaining_costs_rec         remaining_costs_cur%ROWTYPE;


    CURSOR remaining_assets_cur(x_project_id  NUMBER,
                                x_event_type  VARCHAR2) IS
    SELECT  pa.project_asset_id,
            pa.asset_name,
            paa.task_id --Grouping Level: If = 0, asset is assigned to project
    FROM    pa_project_assets_all pa,
            pa_project_asset_assignments paa
    WHERE   pa.project_id = x_project_id
    AND     pa.project_asset_id = paa.project_asset_id (+)
    AND     pa.capital_event_id IS NULL
    AND     pa.project_asset_type = DECODE(x_event_type,'C','AS-BUILT','RETIREMENT_ADJUSTMENT')
    AND     pa.date_placed_in_service IS NOT NULL
    AND     pa.date_placed_in_service <= p_asset_date_through
    ORDER BY pa.project_asset_id, paa.task_id;

    remaining_assets_rec             remaining_assets_cur%ROWTYPE;


    CURSOR print_events_cur(x_request_id  NUMBER,
                            x_project_id  NUMBER,
                            x_event_type  VARCHAR2) IS
    SELECT  p.segment1 project_number,
            p.name project_name,
            c.capital_event_id,
            c.capital_event_number,
            c.event_name,
            c.event_type
    FROM    pa_capital_events c,
            pa_projects p
    WHERE   c.project_id = x_project_id
    AND     c.event_type = x_event_type
    AND     c.request_id = x_request_id
    AND     p.project_id = x_project_id
    ORDER BY p.segment1, c.capital_event_number;

    print_events_rec          print_events_cur%ROWTYPE;


    CURSOR existing_events_cur(x_request_id  NUMBER,
                               x_project_id  NUMBER,
                               x_event_type  VARCHAR2) IS
    SELECT  p.segment1 project_number,
            p.name project_name,
            c.project_id,
            c.capital_event_id,
            c.capital_event_number,
            c.event_name,
            c.event_type
    FROM    pa_capital_events c,
            pa_projects p
    WHERE   c.project_id = p.project_id
    AND     c.project_id = x_project_id
    AND     c.event_period = p_event_period_name
    AND     c.event_type = x_event_type
    AND     c.request_id <> x_request_id
    ORDER BY p.segment1, c.capital_event_number;

    existing_events_rec          existing_events_cur%ROWTYPE;


    CURSOR addtl_costs_cur( x_project_id NUMBER,
                            x_capital_event_id NUMBER,
                            x_request_id NUMBER) IS
    SELECT  'Additional Costs Added'
    FROM    SYS.DUAL
    WHERE   EXISTS
        (SELECT 'X'
        FROM    pa_expenditure_items_all
        WHERE   project_id = x_project_id
        AND     capital_event_id = x_capital_event_id
        AND     request_id = x_request_id);

    addtl_costs_rec          addtl_costs_cur%ROWTYPE;


    CURSOR addtl_assets_cur( x_project_id NUMBER,
                             x_capital_event_id NUMBER,
                             x_request_id NUMBER) IS
    SELECT  'Additional Assets Added'
    FROM    SYS.DUAL
    WHERE   EXISTS
        (SELECT 'X'
        FROM    pa_project_assets_all
        WHERE   project_id = x_project_id
        AND     capital_event_id = x_capital_event_id
        AND     request_id = x_request_id);

    addtl_assets_rec          addtl_assets_cur%ROWTYPE;


    CURSOR wbs_branch_tasks_cur(x_parent_task_id  NUMBER,
                                x_current_task_id  NUMBER,
                                x_event_type  VARCHAR2) IS
    SELECT  task_id,
            task_number
    FROM    pa_tasks
    WHERE   task_id <> x_parent_task_id
    AND     task_id <> x_current_task_id
    AND     NVL(retirement_cost_flag,'N') = DECODE(x_event_type,'R','Y','N')
    CONNECT BY parent_task_id = PRIOR task_id
    START WITH task_id = x_parent_task_id;

    wbs_branch_tasks_rec    wbs_branch_tasks_cur%ROWTYPE;


    CURSOR task_asgn_assets_cur(x_project_id NUMBER,
                                x_capital_event_id NUMBER,
                                x_task_id  NUMBER,
                                x_event_type  VARCHAR2) IS
    SELECT  paa.project_asset_id
    FROM    pa_project_assets_all pa,
            pa_project_asset_assignments paa
    WHERE   pa.project_asset_id = paa.project_asset_id
    AND     pa.project_id = x_project_id
    AND     paa.project_id = x_project_id
    AND     pa.capital_event_id = x_capital_event_id
    AND     paa.task_id = x_task_id
    AND     pa.project_asset_type = DECODE(x_event_type,'C','AS-BUILT','R','RETIREMENT_ADJUSTMENT','AS-BUILT');

    task_asgn_assets_rec    task_asgn_assets_cur%ROWTYPE;


    v_user_id                   NUMBER := FND_GLOBAL.user_id;
    v_login_id                  NUMBER := FND_GLOBAL.login_id;
    v_request_id                NUMBER := FND_GLOBAL.conc_request_id;
    v_program_application_id    NUMBER := FND_GLOBAL.prog_appl_id;
    v_program_id                NUMBER := FND_GLOBAL.conc_program_id;
    v_null_rowid                ROWID  := NULL;
    -- v_org_id                    NUMBER := TO_NUMBER(FND_PROFILE.value('ORG_ID'));
    v_org_id                    NUMBER := PA_MOAC_UTILS.get_current_org_id  ;

    v_common_project            VARCHAR2(1);
    v_project_number            pa_projects_all.segment1%TYPE;
    v_print_project_number      pa_projects_all.segment1%TYPE;
    v_addtl_costs_or_assets     VARCHAR2(1);
    v_first_addtl               VARCHAR2(1);
    v_event_number              pa_capital_events.capital_event_number%TYPE;
    v_new_event_id              pa_capital_events.capital_event_id%TYPE := NULL;
    v_task_number               pa_tasks.task_number%TYPE;
    v_event_exists              VARCHAR2(1);
    v_asset_count               NUMBER := 0;
    v_ei_count                  NUMBER := 0;
    v_top_task_id               NUMBER := 0;
    v_return_status             VARCHAR2(1);
    v_msg_count                 NUMBER := 0;
    v_msg_data                  VARCHAR2(2000);
    v_capital_type              pa_lookups.meaning%TYPE;
    v_wbs_branch_assets_exist   VARCHAR2(1) := 'N';


    PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

    empty_cursor_error              EXCEPTION;

 BEGIN
    --Initialize variables
    retcode := 0;
    errbuf := NULL;


    --Determine if entire project has a 'Common' Asset Assignment
    SELECT  DECODE(COUNT(*),0,'N','Y')
    INTO    v_common_project
    FROM    pa_project_asset_assignments
    WHERE   project_id = p_project_id
    AND     task_id = 0
    AND     project_asset_id = 0;


    --Process events for Common Asset Assignment projects
    IF v_common_project = 'Y' THEN

        IF PG_DEBUG = 'Y' THEN
            PA_DEBUG.WRITE_FILE('LOG',TO_CHAR(SYSDATE,'HH:MI:SS')||': '||'Project has a project-level Common Assignment');
        END IF;

        --Determine if a event exists for the event period specified
        OPEN capital_event_cur(p_project_id, p_event_type);
        FETCH capital_event_cur INTO capital_event_rec;
        IF (capital_event_cur%NOTFOUND) THEN
            v_event_exists := 'N';
        ELSE
            v_event_exists := 'Y';
        END IF;
        CLOSE capital_event_cur;

        --Process projects where the event exists for the event period specified
        IF v_event_exists = 'Y' THEN

            IF PG_DEBUG = 'Y' THEN
                PA_DEBUG.WRITE_FILE('LOG',TO_CHAR(SYSDATE,'HH:MI:SS')||': '||'An Event already exists for the period specified, Event ID: '||capital_event_rec.capital_event_id);
            END IF;


            --Assign all new assets to the existing event
            UPDATE  pa_project_assets_all
            SET     capital_event_id = capital_event_rec.capital_event_id,
                    last_update_date = SYSDATE,
    		        last_updated_by = v_user_id,
			        request_id = v_request_id,
                    program_application_id = v_program_application_id,
                    program_id = v_program_id,
                    program_update_date = SYSDATE
            WHERE   project_id = p_project_id
            AND     capital_event_id IS NULL
            AND     project_asset_type = DECODE(p_event_type,'C','AS-BUILT','RETIREMENT_ADJUSTMENT')
            AND     date_placed_in_service <= p_asset_date_through;


            --Assign all new costs to the existing event
            FOR add_ei_tasks_rec IN add_ei_tasks_cur(p_project_id, p_event_type) LOOP

                --Assign all eligible EIs for that Task to the event
                UPDATE  pa_expenditure_items_all
                SET     capital_event_id = capital_event_rec.capital_event_id,
                        last_update_date = SYSDATE,
    		            last_updated_by = v_user_id,
			            request_id = v_request_id,
                        program_application_id = v_program_application_id,
                        program_id = v_program_id,
                        program_update_date = SYSDATE
                WHERE   project_id = p_project_id
                AND     billable_flag = DECODE(p_event_type,'C','Y','N')
                AND     capital_event_id IS NULL
                AND     expenditure_item_date <= NVL(p_ei_date_through, expenditure_item_date)
                AND     revenue_distributed_flag = 'N'
                AND     cost_distributed_flag = 'Y'
                AND     task_id = add_ei_tasks_rec.task_id;

            END LOOP;


        ELSE --No event exists for the current event period

            IF PG_DEBUG = 'Y' THEN
                PA_DEBUG.WRITE_FILE('LOG',TO_CHAR(SYSDATE,'HH:MI:SS')||': '||'No Event currently exists for the period specified');
            END IF;

            --Possibly create a new event, if both new assets and new costs exist

            --Count the number of new assets
            SELECT  COUNT(*)
            INTO    v_asset_count
            FROM    pa_project_assets_all
            WHERE   project_id = p_project_id
            AND     capital_event_id IS NULL
            AND     project_asset_type = DECODE(p_event_type,'C','AS-BUILT','RETIREMENT_ADJUSTMENT')
            AND     date_placed_in_service <= p_asset_date_through;

            --Count the number of new costs (expenditure items)

			/* Commented for the bug 3961059 :
            SELECT  COUNT(*)
            INTO    v_ei_count
            FROM    pa_expenditure_items_all ei,
                    pa_tasks t
            WHERE   ei.project_id = p_project_id
            AND     t.task_id = ei.task_id
            AND     NVL(t.retirement_cost_flag,'N') = DECODE(p_event_type,'R','Y','N')
            AND     ei.billable_flag = DECODE(p_event_type,'C','Y','N')
            AND     ei.capital_event_id IS NULL
            AND     ei.expenditure_item_date <= NVL(p_ei_date_through, ei.expenditure_item_date)
            AND     ei.revenue_distributed_flag = 'N'
            AND     ei.cost_distributed_flag = 'Y';
			*/


			/* Added below for bug 3961059 : Use of Exists clause */

			SELECT  COUNT(*)
            INTO    v_ei_count
			From Dual Where Exists
			(Select 1
            FROM    pa_expenditure_items_all ei,
                    pa_tasks t
            WHERE   ei.project_id = p_project_id
            AND     t.task_id = ei.task_id
            AND     NVL(t.retirement_cost_flag,'N') = DECODE(p_event_type,'R','Y','N')
            AND     ei.billable_flag = DECODE(p_event_type,'C','Y','N')
            AND     ei.capital_event_id IS NULL
            AND     ei.expenditure_item_date <= NVL(p_ei_date_through, ei.expenditure_item_date)
            AND     ei.revenue_distributed_flag = 'N'
            AND     ei.cost_distributed_flag = 'Y'
			);




            IF (v_asset_count > 0) AND (v_ei_count > 0) THEN

                --Create a new event, and assign the new costs and assets to it

                IF PG_DEBUG = 'Y' THEN
                    PA_DEBUG.WRITE_FILE('LOG',TO_CHAR(SYSDATE,'HH:MI:SS')||': '||v_ei_count||' costs and '||v_asset_count||' assets exist, a new event will be created');
                END IF;

                --Determine the highest existing event number
                SELECT  NVL(MAX(capital_event_number),0)
                INTO    v_event_number
                FROM    pa_capital_events
                WHERE   project_id = p_project_id;

                --Get the Capital Type meaning
                SELECT  meaning
                INTO    v_capital_type
                FROM    pa_lookups
                WHERE   lookup_type = 'CAPITAL_TYPE'
                AND     lookup_code = p_event_type;

                --Add one to get the next event number
                v_event_number := v_event_number + 1;

                --Initialize new event id
                v_new_event_id := NULL;

                PA_CAPITAL_EVENTS_PKG.INSERT_ROW
                            (x_rowid                => v_null_rowid,
                            x_capital_event_id      => v_new_event_id,
                            x_project_id            => p_project_id,
                            x_capital_event_number  => v_event_number,
                            x_event_type            => p_event_type,
                            x_event_name            => p_event_period_name||' '||v_capital_type,
                            x_asset_allocation_method => p_asset_allocation_method,
                            x_event_period          => p_event_period_name,
                            x_last_update_date      => SYSDATE,
				            x_last_updated_by		=> v_user_id,
				            x_creation_date			=> SYSDATE,
				            x_created_by		    => v_user_id,
				            x_last_update_login		=> v_login_id,
                            x_request_id            => v_request_id,
                            x_program_application_id => v_program_application_id,
                            x_program_id            => v_program_id,
                            x_program_update_date   => SYSDATE);


                --Retrieve the newly created capital event id
                OPEN capital_event_cur(p_project_id, p_event_type);
                FETCH capital_event_cur INTO capital_event_rec;
                IF (capital_event_cur%NOTFOUND) THEN
                    CLOSE capital_event_cur;
                    RAISE empty_cursor_error;
                END IF;
                CLOSE capital_event_cur;

                --Assign all new assets to the existing event
                UPDATE  pa_project_assets_all
                SET     capital_event_id = capital_event_rec.capital_event_id,
                        last_update_date = SYSDATE,
    		            last_updated_by	= v_user_id,
			            request_id = v_request_id,
                        program_application_id = v_program_application_id,
                        program_id = v_program_id,
                        program_update_date = SYSDATE
                WHERE   project_id = p_project_id
                AND     capital_event_id IS NULL
                AND     project_asset_type = DECODE(p_event_type,'C','AS-BUILT','RETIREMENT_ADJUSTMENT')
                AND     date_placed_in_service <= p_asset_date_through;

                --Assign all new costs to the existing event
                FOR add_ei_tasks_rec IN add_ei_tasks_cur(p_project_id, p_event_type) LOOP

                    --Assign all eligible EIs for that Task to the event
                    UPDATE  pa_expenditure_items_all
                    SET     capital_event_id = capital_event_rec.capital_event_id,
                            last_update_date = SYSDATE,
	       	                last_updated_by	= v_user_id,
			                request_id = v_request_id,
                            program_application_id = v_program_application_id,
                            program_id = v_program_id,
                            program_update_date = SYSDATE
                    WHERE   project_id = p_project_id
                    AND     billable_flag = DECODE(p_event_type,'C','Y','N')
                    AND     capital_event_id IS NULL
                    AND     expenditure_item_date <= NVL(p_ei_date_through, expenditure_item_date)
                    AND     revenue_distributed_flag = 'N'
                    AND     cost_distributed_flag = 'Y'
                    AND     task_id = add_ei_tasks_rec.task_id;

                END LOOP;

                IF PG_DEBUG = 'Y' THEN
                    PA_DEBUG.WRITE_FILE('LOG',TO_CHAR(SYSDATE,'HH:MI:SS')||': '||'Event number '||v_event_number||' successfully created for Project: '||p_project_number);
                END IF;


            ELSIF (v_asset_count = 0) AND (v_ei_count = 0) THEN

                --Print warning message
                INSERT INTO pa_cap_event_creation_v
                    (request_id,
                    module,
                    context,
	                sub_context,
                    capital_type,
                    project_id,
                    project_number,
                    project_asset_id,
                    asset_name,
                    task_id,
                    task_number,
                    capital_event_id,
                    capital_event_number,
                    event_name,
                    event_type,
                    message_code,
                    created_by,
                    creation_date,
                    org_id
                    )
                VALUES
                    (v_request_id,
                    'PERIODIC_EVENT_CREATION', --module
                    '1', --context (1 = Message)
	                'P', --sub_context
                    p_event_type, --capital_type,
                    p_project_id, --project_id,
                    p_project_number, --project_number,
                    NULL, --project_asset_id,
                    NULL, --asset_name,
                    NULL, --task_id,
                    NULL, --task_number,
                    NULL, --capital_event_id,
                    NULL, --capital_event_number,
                    NULL, --event_name,
                    NULL, --event_type,
                    'NO_ASSETS_OR_COSTS_PROJ',
                    v_user_id, --created_by,
                    SYSDATE, --creation_date,
                    v_org_id --org_id
                    );


                IF PG_DEBUG = 'Y' THEN
                    PA_DEBUG.WRITE_FILE('LOG',TO_CHAR(SYSDATE,'HH:MI:SS')||': '||v_ei_count||' costs and '||v_asset_count||' assets exist, no new event will be created');
                END IF;

            ELSIF (v_asset_count > 0) AND (v_ei_count = 0) THEN

                --Print warning message
                INSERT INTO pa_cap_event_creation_v
                    (request_id,
                    module,
                    context,
	                sub_context,
                    capital_type,
                    project_id,
                    project_number,
                    project_asset_id,
                    asset_name,
                    task_id,
                    task_number,
                    capital_event_id,
                    capital_event_number,
                    event_name,
                    event_type,
                    message_code,
                    created_by,
                    creation_date,
                    org_id
                    )
                VALUES
                    (v_request_id,
                    'PERIODIC_EVENT_CREATION', --module
                    '1', --context (1 = Message)
	                'P', --sub_context
                    p_event_type, --capital_type,
                    p_project_id, --project_id,
                    p_project_number, --project_number,
                    NULL, --project_asset_id,
                    NULL, --asset_name,
                    NULL, --task_id,
                    NULL, --task_number,
                    NULL, --capital_event_id,
                    NULL, --capital_event_number,
                    NULL, --event_name,
                    NULL, --event_type,
                    'ASSETS_BUT_NO_COSTS_PROJ',
                    v_user_id, --created_by,
                    SYSDATE, --creation_date,
                    v_org_id --org_id
                    );

                IF PG_DEBUG = 'Y' THEN
                    PA_DEBUG.WRITE_FILE('LOG',TO_CHAR(SYSDATE,'HH:MI:SS')||': '||v_ei_count||' costs and '||v_asset_count||' assets exist, no new event will be created');
                END IF;

            ELSIF (v_asset_count = 0) AND (v_ei_count > 0) THEN

                --Print warning message
                INSERT INTO pa_cap_event_creation_v
                    (request_id,
                    module,
                    context,
	                sub_context,
                    capital_type,
                    project_id,
                    project_number,
                    project_asset_id,
                    asset_name,
                    task_id,
                    task_number,
                    capital_event_id,
                    capital_event_number,
                    event_name,
                    event_type,
                    message_code,
                    created_by,
                    creation_date,
                    org_id
                    )
                VALUES
                    (v_request_id,
                    'PERIODIC_EVENT_CREATION', --module
                    '1', --context (1 = Message)
	                'P', --sub_context
                    p_event_type, --capital_type,
                    p_project_id, --project_id,
                    p_project_number, --project_number,
                    NULL, --project_asset_id,
                    NULL, --asset_name,
                    NULL, --task_id,
                    NULL, --task_number,
                    NULL, --capital_event_id,
                    NULL, --capital_event_number,
                    NULL, --event_name,
                    NULL, --event_type,
                    'COSTS_BUT_NO_ASSETS_PROJ',
                    v_user_id, --created_by,
                    SYSDATE, --creation_date,
                    v_org_id --org_id
                    );


                IF PG_DEBUG = 'Y' THEN
                    PA_DEBUG.WRITE_FILE('LOG',TO_CHAR(SYSDATE,'HH:MI:SS')||': '||v_ei_count||' costs and '||v_asset_count||' assets exist, no new event will be created');
                END IF;

            END IF; --Processing based on asset and cost item counts

        END IF; --Event existence test for 'Common' projects

    ELSE --Process events for projects that do not have 'Common' Asset Assignments


        IF PG_DEBUG = 'Y' THEN
            PA_DEBUG.WRITE_FILE('LOG',TO_CHAR(SYSDATE,'HH:MI:SS')||': '||'Project does not have a project-level Common Assignment');
        END IF;

        --Loop through all new assets and their asset assignments for the project
        FOR new_assets_rec IN new_assets_cur(p_project_id, p_event_type) LOOP

            --Determine if a event exists for the event period specified
            OPEN capital_event_cur(p_project_id, p_event_type);
            FETCH capital_event_cur INTO capital_event_rec;
            IF (capital_event_cur%NOTFOUND) THEN
                v_event_exists := 'N';
            ELSE
                v_event_exists := 'Y';
            END IF;
            CLOSE capital_event_cur;

            --Process projects where the event exists for the event period specified
            IF v_event_exists = 'Y' THEN

                IF PG_DEBUG = 'Y' THEN
                    PA_DEBUG.WRITE_FILE('LOG',TO_CHAR(SYSDATE,'HH:MI:SS')||': '||'An Event already exists for the period specified, Event ID: '||capital_event_rec.capital_event_id);
                END IF;

                --Look for costs in the event at the asset grouping level
                IF new_assets_rec.task_id = 0 THEN

                    --Look for costs in the event at the PROJECT grouping level (i.e., ANY expenditure items)
                    /* Commented for bug 3961059
					SELECT  COUNT(*)
                    INTO    v_ei_count
                    FROM    pa_expenditure_items_all
                    WHERE   capital_event_id = capital_event_rec.capital_event_id
                    AND     project_id = p_project_id;
					*/

					/* Added below for bug 3961059 : Use of Exists clause */

					SELECT  COUNT(*)
                    INTO    v_ei_count
					From Dual Where Exists
					(Select 1
                    FROM    pa_expenditure_items_all
                    WHERE   capital_event_id = capital_event_rec.capital_event_id
                    AND     project_id = p_project_id
					);



                ELSE --new_assets_rec.task_id <> 0

                    --Look for costs in the event at the TASK or TOP TASK grouping level
                    /* Commented for bug 3961059
					SELECT  COUNT(*)
                    INTO    v_ei_count
                    FROM    pa_expenditure_items_all peia,
                            pa_tasks t
                    WHERE   peia.task_id = t.task_id
                    AND     peia.capital_event_id = capital_event_rec.capital_event_id
                    AND     peia.project_id = p_project_id
                    AND     (new_assets_rec.task_id = t.task_id
                            OR new_assets_rec.task_id = t.top_task_id);
					*/

					/* Added Below for bug 3961059 : Use of Exists clause */

					SELECT  COUNT(*)
                    INTO    v_ei_count
					From Dual Where Exists
					( Select 1
                    FROM    pa_expenditure_items_all peia,
                            pa_tasks t
                    WHERE   peia.task_id = t.task_id
                    AND     peia.capital_event_id = capital_event_rec.capital_event_id
                    AND     peia.project_id = p_project_id
                    AND     (new_assets_rec.task_id = t.task_id
                            OR new_assets_rec.task_id = t.top_task_id)
					);


                END IF;

                IF v_ei_count > 0 THEN  --costs already exist on the event

                    IF PG_DEBUG = 'Y' THEN
                        PA_DEBUG.WRITE_FILE('LOG',TO_CHAR(SYSDATE,'HH:MI:SS')||': '||'Costs already exists on the Event, add asset id: '||new_assets_rec.project_asset_id);
                    END IF;

                    --Add the asset to the event
                    UPDATE  pa_project_assets_all
                    SET     capital_event_id = capital_event_rec.capital_event_id,
                            last_update_date = SYSDATE,
    		                last_updated_by = v_user_id,
			                request_id = v_request_id,
                            program_application_id = v_program_application_id,
                            program_id = v_program_id,
                            program_update_date = SYSDATE
                    WHERE   project_asset_id = new_assets_rec.project_asset_id
                    AND     capital_event_id IS NULL;

                ELSE
                    --Look for NEW costs at the asset assignment grouping level
                    IF new_assets_rec.task_id = 0 THEN

                        --Look for new costs at the PROJECT grouping level (i.e., ANY expenditure items)
                        SELECT  COUNT(*)
                        INTO    v_ei_count
                        FROM    pa_expenditure_items_all peia,
                                pa_tasks t
                        WHERE   peia.project_id = p_project_id
                        AND     peia.task_id = t.task_id
                        AND     NVL(t.retirement_cost_flag,'N') = DECODE(p_event_type,'R','Y','N')
                        AND     peia.billable_flag = DECODE(p_event_type,'C','Y','N')
                        AND     peia.capital_event_id IS NULL
                        AND     peia.expenditure_item_date <= NVL(p_ei_date_through, peia.expenditure_item_date)
                        AND     peia.revenue_distributed_flag = 'N'
                        AND     peia.cost_distributed_flag = 'Y';

                    ELSE --new_assets_rec.task_id <> 0

                        --Look for new costs at the TASK or TOP TASK grouping level
                        SELECT  COUNT(*)
                        INTO    v_ei_count
                        FROM    pa_expenditure_items_all peia,
                                pa_tasks t
                        WHERE   peia.task_id = t.task_id
                        AND     NVL(t.retirement_cost_flag,'N') = DECODE(p_event_type,'R','Y','N')
                        AND     peia.project_id = p_project_id
                        AND     peia.billable_flag = DECODE(p_event_type,'C','Y','N')
                        AND     peia.capital_event_id IS NULL
                        AND     peia.expenditure_item_date <= NVL(p_ei_date_through, expenditure_item_date)
                        AND     peia.revenue_distributed_flag = 'N'
                        AND     peia.cost_distributed_flag = 'Y'
                        AND     (new_assets_rec.task_id = t.task_id
                                OR new_assets_rec.task_id = t.top_task_id);
                    END IF;


                    IF v_ei_count > 0 THEN

                        IF PG_DEBUG = 'Y' THEN
                            PA_DEBUG.WRITE_FILE('LOG',TO_CHAR(SYSDATE,'HH:MI:SS')||': '||'New costs and assets exist for the Event, add asset id: '||new_assets_rec.project_asset_id);
                        END IF;


                        --Add the asset to the event
                        UPDATE  pa_project_assets_all
                        SET     capital_event_id = capital_event_rec.capital_event_id,
                                last_update_date = SYSDATE,
    		                    last_updated_by = v_user_id,
			                    request_id = v_request_id,
                                program_application_id = v_program_application_id,
                                program_id = v_program_id,
                                program_update_date = SYSDATE
                        WHERE   project_asset_id = new_assets_rec.project_asset_id
                        AND     capital_event_id IS NULL;

                        --Add the new costs to the event
                        UPDATE  pa_expenditure_items_all
                        SET     capital_event_id = capital_event_rec.capital_event_id,
                                last_update_date = SYSDATE,
    		                    last_updated_by = v_user_id,
			                    request_id = v_request_id,
                                program_application_id = v_program_application_id,
                                program_id = v_program_id,
                                program_update_date = SYSDATE
                        WHERE   project_id = p_project_id
                        AND     capital_event_id IS NULL
                        AND     billable_flag = DECODE(p_event_type,'C','Y','N')
                        AND     expenditure_item_date <= NVL(p_ei_date_through, expenditure_item_date)
                        AND     revenue_distributed_flag = 'N'
                        AND     cost_distributed_flag = 'Y'
                        AND     (
                                ((new_assets_rec.task_id = 0) AND task_id IN
                                    (SELECT task_id
                                     FROM    pa_tasks
                                     WHERE   project_id = p_project_id
                                     AND     NVL(retirement_cost_flag,'N') = DECODE(p_event_type,'R','Y','N')))
                                OR (task_id = new_assets_rec.task_id
                                    AND NVL(new_assets_rec.task_retirement_cost_flag,'N') = DECODE(p_event_type,'R','Y','N'))
                                OR task_id IN
                                    (SELECT task_id
                                     FROM    pa_tasks
                                     WHERE   top_task_id = new_assets_rec.task_id
                                     AND     NVL(retirement_cost_flag,'N') = DECODE(p_event_type,'R','Y','N'))
                                );
                    END IF; --New costs exist

                END IF; --Processing for when the event already exists

            ELSE --No event exists as yet

                IF PG_DEBUG = 'Y' THEN
                    PA_DEBUG.WRITE_FILE('LOG',TO_CHAR(SYSDATE,'HH:MI:SS')||': '||'No Event currently exists for period specified');
                END IF;


                --Look for new costs at the asset assignment grouping level
                IF new_assets_rec.task_id = 0 THEN

                    --Look for new costs at the PROJECT grouping level (i.e., ANY expenditure items)
                    SELECT  COUNT(*)
                    INTO    v_ei_count
                    FROM    pa_expenditure_items_all peia,
                            pa_tasks t
                    WHERE   peia.project_id = p_project_id
                    AND     peia.task_id = t.task_id
                    AND     NVL(t.retirement_cost_flag,'N') = DECODE(p_event_type,'R','Y','N')
                    AND     peia.billable_flag = DECODE(p_event_type,'C','Y','N')
                    AND     peia.capital_event_id IS NULL
                    AND     peia.expenditure_item_date <= NVL(p_ei_date_through, peia.expenditure_item_date)
                    AND     peia.revenue_distributed_flag = 'N'
                    AND     peia.cost_distributed_flag = 'Y';

                ELSE --new_assets_rec.task_id <> 0

                    --Look for new costs at the TASK or TOP TASK grouping level
                    SELECT  COUNT(*)
                    INTO    v_ei_count
                    FROM    pa_expenditure_items_all peia,
                            pa_tasks t
                    WHERE   peia.task_id = t.task_id
                    AND     NVL(t.retirement_cost_flag,'N') = DECODE(p_event_type,'R','Y','N')
                    AND     peia.project_id = p_project_id
                    AND     peia.billable_flag = DECODE(p_event_type,'C','Y','N')
                    AND     peia.capital_event_id IS NULL
                    AND     peia.expenditure_item_date <= NVL(p_ei_date_through, expenditure_item_date)
                    AND     peia.revenue_distributed_flag = 'N'
                    AND     peia.cost_distributed_flag = 'Y'
                    AND     (new_assets_rec.task_id = t.task_id
                            OR new_assets_rec.task_id = t.top_task_id);
                END IF;


                IF v_ei_count > 0 THEN

                    --Create a new event, and assign the new costs and assets to it
                    IF PG_DEBUG = 'Y' THEN
                        PA_DEBUG.WRITE_FILE('LOG',TO_CHAR(SYSDATE,'HH:MI:SS')||': '||'New costs and assets exist, create a new Event');
                    END IF;


                    --Determine the highest existing event number
                    SELECT  NVL(MAX(capital_event_number),0)
                    INTO    v_event_number
                    FROM    pa_capital_events
                    WHERE   project_id = p_project_id;

                    --Get the Capital Type meaning
                    SELECT  meaning
                    INTO    v_capital_type
                    FROM    pa_lookups
                    WHERE   lookup_type = 'CAPITAL_TYPE'
                    AND     lookup_code = p_event_type;

                    --Add one to get the next event number
                    v_event_number := v_event_number + 1;

                    --Initialize new event id
                    v_new_event_id := NULL;

                    PA_CAPITAL_EVENTS_PKG.INSERT_ROW
                            (x_rowid                => v_null_rowid,
                            x_capital_event_id      => v_new_event_id,
                            x_project_id            => p_project_id,
                            x_capital_event_number  => v_event_number,
                            x_event_type            => p_event_type,
                            x_event_name            => p_event_period_name||' '||v_capital_type,
                            x_asset_allocation_method => p_asset_allocation_method,
                            x_event_period          => p_event_period_name,
                            x_last_update_date      => SYSDATE,
				            x_last_updated_by		=> v_user_id,
				            x_creation_date			=> SYSDATE,
				            x_created_by		    => v_user_id,
				            x_last_update_login		=> v_login_id,
                            x_request_id            => v_request_id,
                            x_program_application_id => v_program_application_id,
                            x_program_id            => v_program_id,
                            x_program_update_date   => SYSDATE);


                    --Retrieve the newly created capital event id
                    OPEN capital_event_cur(p_project_id, p_event_type);
                    FETCH capital_event_cur INTO capital_event_rec;
                    IF (capital_event_cur%NOTFOUND) THEN
                        CLOSE capital_event_cur;
                        RAISE empty_cursor_error;
                    END IF;
                    CLOSE capital_event_cur;


                    --Add the asset to the event
                    UPDATE  pa_project_assets_all
                    SET     capital_event_id = capital_event_rec.capital_event_id,
                            last_update_date = SYSDATE,
			                last_updated_by = v_user_id,
			                request_id = v_request_id,
                            program_application_id = v_program_application_id,
                            program_id = v_program_id,
                            program_update_date = SYSDATE
                    WHERE   project_asset_id = new_assets_rec.project_asset_id
                    AND     capital_event_id IS NULL;


                    --Add the new costs to the event
                    UPDATE  pa_expenditure_items_all
                    SET     capital_event_id = capital_event_rec.capital_event_id,
                            last_update_date = SYSDATE,
        	                last_updated_by = v_user_id,
			                request_id = v_request_id,
                            program_application_id = v_program_application_id,
                            program_id = v_program_id,
                            program_update_date = SYSDATE
                    WHERE   project_id = p_project_id
                    AND     capital_event_id IS NULL
                    AND     billable_flag = DECODE(p_event_type,'C','Y','N')
                    AND     expenditure_item_date <= NVL(p_ei_date_through, expenditure_item_date)
                    AND     revenue_distributed_flag = 'N'
                    AND     cost_distributed_flag = 'Y'
                    AND     (
                            ((new_assets_rec.task_id = 0) AND task_id IN
                                (SELECT task_id
                                 FROM    pa_tasks
                                 WHERE   project_id = p_project_id
                                 AND     NVL(retirement_cost_flag,'N') = DECODE(p_event_type,'R','Y','N')))
                            OR (task_id = new_assets_rec.task_id
                                 AND NVL(new_assets_rec.task_retirement_cost_flag,'N') = DECODE(p_event_type,'R','Y','N'))
                            OR task_id IN
                                (SELECT task_id
                                 FROM    pa_tasks
                                 WHERE   top_task_id = new_assets_rec.task_id
                                 AND     NVL(retirement_cost_flag,'N') = DECODE(p_event_type,'R','Y','N'))
                            );

                    IF PG_DEBUG = 'Y' THEN
                        PA_DEBUG.WRITE_FILE('LOG',TO_CHAR(SYSDATE,'HH:MI:SS')||': '||'Event number '||v_event_number||' successfully created for Project: '||p_project_number);
                    END IF;

                END IF; --New costs existed for the asset and event was created

            END IF; --No event existed for the asset

        END LOOP;  --New Assets


        --Check to see if a event now exists, and add appropriate new costs to it
        OPEN capital_event_cur(p_project_id, p_event_type);
        FETCH capital_event_cur INTO capital_event_rec;
        IF (capital_event_cur%NOTFOUND) THEN
            v_event_exists := 'N';
        ELSE
            v_event_exists := 'Y';
        END IF;
        CLOSE capital_event_cur;


        IF v_event_exists = 'Y' THEN

            --Any Top Task Level Common Assignment costs can be added to the event
            --Lowest Level Common Assignment costs can be added to the event only if at
            --least one asset exists in the event that is assigned to a task beneath the
            --same parent task as the common assignment (i.e., assigned within the same
            --branch of the WBS).  For instance, if a common assignment is made to task 2.1,
            --then the costs can be included if there is an asset assigned to task 2.2, 2.3,
            --2.4.1, 2.4.2, 2.5, and so on.  But not if there are only assets assigned to task 3.0,
            --4.1, 4.2, since those reside outside of the WBS branch of the common assignment,
            --since they are not beneath the parent task of task 2.1, which is 2.0.
            FOR common_tasks_rec IN common_tasks_cur(p_project_id, p_event_type) LOOP

                --Test if the Common Assignment is made at the Top Task Level
                IF common_tasks_rec.assignment_task_id = common_tasks_rec.top_task_id THEN

                    IF PG_DEBUG = 'Y' THEN
	                   PA_DEBUG.DEBUG('Common Task assignment made at Top Task Level for Task ID '||common_tasks_rec.task_id);
	                END IF;

                    --Attach all common costs to the event associated with a Top Task Assignment
                    UPDATE  pa_expenditure_items_all
                    SET     capital_event_id = capital_event_rec.capital_event_id,
                            last_update_date = SYSDATE,
    		                last_updated_by = v_user_id,
	       	                request_id = v_request_id,
                            program_application_id = v_program_application_id,
                            program_id = v_program_id,
                            program_update_date = SYSDATE
                    WHERE   project_id = p_project_id
                    AND     capital_event_id IS NULL
                    AND     billable_flag = DECODE(p_event_type,'C','Y','N')
                    AND     expenditure_item_date <= NVL(p_ei_date_through, expenditure_item_date)
                    AND     revenue_distributed_flag = 'N'
                    AND     cost_distributed_flag = 'Y'
                    AND     task_id = common_tasks_rec.task_id;

                    IF SQL%ROWCOUNT > 0 THEN
                        IF PG_DEBUG = 'Y' THEN
                            PA_DEBUG.WRITE_FILE('LOG',TO_CHAR(SYSDATE,'HH:MI:SS')||': '||'New common costs added to Event number '||v_event_number);
                        END IF;
                    END IF;
                ELSE --Common Task is assigned at the Lowest Level

                    IF PG_DEBUG = 'Y' THEN
	                   PA_DEBUG.DEBUG('Common Task assignment made at Lowest Task Level for Task ID '||common_tasks_rec.task_id
                                                ||' under Parent Task ID '||common_tasks_rec.parent_task_id);
	                END IF;

                    v_wbs_branch_assets_exist := 'N';

                    --Attach all costs where asset assignment(s) exist at or beneath the Parent (not Top) Task
                    FOR wbs_branch_tasks_rec IN wbs_branch_tasks_cur(common_tasks_rec.parent_task_id,
                                                                     common_tasks_rec.task_id,
                                                                     p_event_type) LOOP

                        IF PG_DEBUG = 'Y' THEN
	                       PA_DEBUG.DEBUG('Task Number '||wbs_branch_tasks_rec.task_number||' exists beneath Parent Task ID '||common_tasks_rec.parent_task_id);
	                    END IF;

                        --Check for existence of asset assignments in current event on current task
                        OPEN task_asgn_assets_cur(p_project_id,
                                                  capital_event_rec.capital_event_id,
                                                  wbs_branch_tasks_rec.task_id,
                                                  p_event_type);
                        FETCH task_asgn_assets_cur INTO task_asgn_assets_rec;
                        IF task_asgn_assets_cur%NOTFOUND THEN
                            IF PG_DEBUG = 'Y' THEN
	                           PA_DEBUG.DEBUG('No assignments exist for current event for Task Number '||wbs_branch_tasks_rec.task_number);
	                        END IF;
                        ELSE
                            v_wbs_branch_assets_exist := 'Y';
                            IF PG_DEBUG = 'Y' THEN
	                           PA_DEBUG.DEBUG('Assignments exist for current event for Task Number '||wbs_branch_tasks_rec.task_number);
	                        END IF;
                        END IF;

                        CLOSE task_asgn_assets_cur;

                    END LOOP; --WBS Branch Tasks

                    IF v_wbs_branch_assets_exist = 'Y' THEN

                        --Attach all common costs to the event for the current task
                        UPDATE  pa_expenditure_items_all
                        SET     capital_event_id = capital_event_rec.capital_event_id,
                                last_update_date = SYSDATE,
  		                        last_updated_by = v_user_id,
       	                        request_id = v_request_id,
                                program_application_id = v_program_application_id,
                                program_id = v_program_id,
                                program_update_date = SYSDATE
                        WHERE   project_id = p_project_id
                        AND     capital_event_id IS NULL
                        AND     billable_flag = DECODE(p_event_type,'C','Y','N')
                        AND     expenditure_item_date <= NVL(p_ei_date_through, expenditure_item_date)
                        AND     revenue_distributed_flag = 'N'
                        AND     cost_distributed_flag = 'Y'
                        AND     task_id = common_tasks_rec.task_id; --NOTE: We are attaching the costs under the original task,
                                        --based on the existence of asset assignments on OTHER tasks beneath the same parent (within
                                        --the same WBS branch)
                    END IF; --WBS Branch Asset Assignments exist for Task in current Event

                END IF; --Test for Top or Lowest Task Assignment

            END LOOP; --Common Tasks


            --Any new costs that match any existing asset grouping levels can be added to the event
            FOR remaining_costs_rec IN remaining_costs_cur(p_project_id, p_event_type) LOOP

                --Get the Top Task ID
                SELECT  top_task_id
                INTO    v_top_task_id
                FROM    pa_tasks
                WHERE   task_id = remaining_costs_rec.task_id;

                --Look for assets in the event at the grouping level of the new costs

				/* Commented for bug 3961059 */
                SELECT  COUNT(*)
                INTO    v_asset_count
                FROM    pa_project_assets_all pa,
                        pa_project_asset_assignments paa
                WHERE   pa.project_asset_id = paa.project_asset_id
                AND     pa.capital_event_id = capital_event_rec.capital_event_id
                AND     (paa.task_id = remaining_costs_rec.task_id
                        OR paa.task_id = v_top_task_id
                        OR paa.task_id = 0);

				/* Added below for bug 3961059 :Use of Exists clause */

				SELECT  COUNT(*)
                INTO    v_asset_count
				From Dual Where Exists
				(Select 1
                FROM    pa_project_assets_all pa,
                        pa_project_asset_assignments paa
                WHERE   pa.project_asset_id = paa.project_asset_id
                AND     pa.capital_event_id = capital_event_rec.capital_event_id
                AND     (paa.task_id = remaining_costs_rec.task_id
                        OR paa.task_id = v_top_task_id
                        OR paa.task_id = 0)
				);

                IF v_asset_count > 0 THEN

                    --Add new costs to the event for the current task
                    UPDATE  pa_expenditure_items_all
                    SET     capital_event_id = capital_event_rec.capital_event_id,
                            last_update_date = SYSDATE,
    		                last_updated_by = v_user_id,
	       	                request_id = v_request_id,
                            program_application_id = v_program_application_id,
                            program_id = v_program_id,
                            program_update_date = SYSDATE
                    WHERE   project_id = p_project_id
                    AND     capital_event_id IS NULL
                    AND     billable_flag = DECODE(p_event_type,'C','Y','N')
                    AND     expenditure_item_date <= NVL(p_ei_date_through, expenditure_item_date)
                    AND     revenue_distributed_flag = 'N'
                    AND     cost_distributed_flag = 'Y'
                    AND     task_id = remaining_costs_rec.task_id;

                    IF PG_DEBUG = 'Y' THEN
                        PA_DEBUG.WRITE_FILE('LOG',TO_CHAR(SYSDATE,'HH:MI:SS')||': '||'New costs added to Event number '||v_event_number||' from task id '||remaining_costs_rec.task_id);
                    END IF;

                END IF; --Remaining costs match an existing asset grouping level for the event

            END LOOP; --Remaining Costs Tasks


        END IF; --Event now exists for project


        --Loop through any tasks that still have new costs, and print a warning message for each task
        FOR remaining_costs_rec IN remaining_costs_cur(p_project_id, p_event_type) LOOP

            --Get the task number
            SELECT  task_number
            INTO    v_task_number
            FROM    pa_tasks
            WHERE   task_id = remaining_costs_rec.task_id;

            --Print warning message
            INSERT INTO pa_cap_event_creation_v
                    (request_id,
                    module,
                    context,
	                sub_context,
                    capital_type,
                    project_id,
                    project_number,
                    project_asset_id,
                    asset_name,
                    task_id,
                    task_number,
                    capital_event_id,
                    capital_event_number,
                    event_name,
                    event_type,
                    message_code,
                    created_by,
                    creation_date,
                    org_id
                    )
            VALUES
                    (v_request_id,
                    'PERIODIC_EVENT_CREATION', --module
                    '1', --context (1 = Message)
	                'T', --sub_context
                    p_event_type, --capital_type,
                    p_project_id, --project_id,
                    p_project_number, --project_number,
                    NULL, --project_asset_id,
                    NULL, --asset_name,
                    remaining_costs_rec.task_id, --task_id,
                    v_task_number, --task_number,
                    NULL, --capital_event_id,
                    NULL, --capital_event_number,
                    NULL, --event_name,
                    NULL, --event_type,
                    'TASK_COSTS_BUT_NO_ASSETS',
                    v_user_id, --created_by,
                    SYSDATE, --creation_date,
                    v_org_id --org_id
                    );

            IF PG_DEBUG = 'Y' THEN
                 PA_DEBUG.WRITE_FILE('LOG',TO_CHAR(SYSDATE,'HH:MI:SS')||': '||'Costs but no corresponding assets exist on Task Number '||v_task_number
                                                ||' for Project: '||p_project_number);
            END IF;

        END LOOP; --Remaining Costs Tasks


        --Loop through any new assets that remain for the project, and print a warning message for each asset
        FOR remaining_assets_rec IN remaining_assets_cur(p_project_id, p_event_type) LOOP

            IF remaining_assets_rec.task_id IS NULL THEN

                --Print warning message
                INSERT INTO pa_cap_event_creation_v
                    (request_id,
                    module,
                    context,
	                sub_context,
                    capital_type,
                    project_id,
                    project_number,
                    project_asset_id,
                    asset_name,
                    task_id,
                    task_number,
                    capital_event_id,
                    capital_event_number,
                    event_name,
                    event_type,
                    message_code,
                    created_by,
                    creation_date,
                    org_id
                    )
                VALUES
                    (v_request_id,
                    'PERIODIC_EVENT_CREATION', --module
                    '1', --context (1 = Message)
	                'A', --sub_context
                    p_event_type, --capital_type,
                    p_project_id, --project_id,
                    p_project_number, --project_number,
                    remaining_assets_rec.project_asset_id, --project_asset_id,
                    remaining_assets_rec.asset_name, --asset_name,
                    NULL, --task_id,
                    NULL, --task_number,
                    NULL, --capital_event_id,
                    NULL, --capital_event_number,
                    NULL, --event_name,
                    NULL, --event_type,
                    'ASSET_WITH_NO_ASSIGNMENT',
                    v_user_id, --created_by,
                    SYSDATE, --creation_date,
                    v_org_id --org_id
                    );

                IF PG_DEBUG = 'Y' THEN
                    PA_DEBUG.WRITE_FILE('LOG',TO_CHAR(SYSDATE,'HH:MI:SS')||': Asset '||remaining_assets_rec.asset_name
                                ||' found with no asset assignment(s) on Project: '||p_project_number);
                END IF;

            ELSIF remaining_assets_rec.task_id = 0 THEN

                --Print warning message
                INSERT INTO pa_cap_event_creation_v
                    (request_id,
                    module,
                    context,
	                sub_context,
                    capital_type,
                    project_id,
                    project_number,
                    project_asset_id,
                    asset_name,
                    task_id,
                    task_number,
                    capital_event_id,
                    capital_event_number,
                    event_name,
                    event_type,
                    message_code,
                    created_by,
                    creation_date,
                    org_id
                    )
                VALUES
                    (v_request_id,
                    'PERIODIC_EVENT_CREATION', --module
                    '1', --context (1 = Message)
	                'A', --sub_context
                    p_event_type, --capital_type,
                    p_project_id, --project_id,
                    p_project_number, --project_number,
                    remaining_assets_rec.project_asset_id, --project_asset_id,
                    remaining_assets_rec.asset_name, --asset_name,
                    NULL, --task_id,
                    NULL, --task_number,
                    NULL, --capital_event_id,
                    NULL, --capital_event_number,
                    NULL, --event_name,
                    NULL, --event_type,
                    'ASSET_WITH_NO_COSTS',
                    v_user_id, --created_by,
                    SYSDATE, --creation_date,
                    v_org_id --org_id
                    );

                IF PG_DEBUG = 'Y' THEN
                    PA_DEBUG.WRITE_FILE('LOG',TO_CHAR(SYSDATE,'HH:MI:SS')||': Asset '||remaining_assets_rec.asset_name
                                ||' found but no costs exist on Project: '||p_project_number);
                END IF;

            ELSIF remaining_assets_rec.task_id <> 0 THEN

                --Get the task number
                SELECT  task_number
                INTO    v_task_number
                FROM    pa_tasks
                WHERE   task_id = remaining_assets_rec.task_id;

                --Print warning message
                INSERT INTO pa_cap_event_creation_v
                    (request_id,
                    module,
                    context,
	                sub_context,
                    capital_type,
                    project_id,
                    project_number,
                    project_asset_id,
                    asset_name,
                    task_id,
                    task_number,
                    capital_event_id,
                    capital_event_number,
                    event_name,
                    event_type,
                    message_code,
                    created_by,
                    creation_date,
                    org_id
                    )
                VALUES
                    (v_request_id,
                    'PERIODIC_EVENT_CREATION', --module
                    '1', --context (1 = Message)
	                'AT', --sub_context
                    p_event_type, --capital_type,
                    p_project_id, --project_id,
                    p_project_number, --project_number,
                    remaining_assets_rec.project_asset_id, --project_asset_id,
                    remaining_assets_rec.asset_name, --asset_name,
                    remaining_assets_rec.task_id, --task_id,
                    v_task_number, --task_number,
                    NULL, --capital_event_id,
                    NULL, --capital_event_number,
                    NULL, --event_name,
                    NULL, --event_type,
                    'ASSET_WITH_NO_COSTS_FOR_TASK',
                    v_user_id, --created_by,
                    SYSDATE, --creation_date,
                    v_org_id --org_id
                    );

                IF PG_DEBUG = 'Y' THEN
                    PA_DEBUG.WRITE_FILE('LOG',TO_CHAR(SYSDATE,'HH:MI:SS')||': Asset '||remaining_assets_rec.asset_name
                                                ||' found but no costs exist beneath Task Number '||v_task_number
                                                ||' for Project: '||p_project_number);
                END IF;

            END IF; --Remaining asset task assignments

        END LOOP; --Remaining Assets


    END IF;  --Projects with Common vs. not Common project-level asset assignments



    --Print results in control report

    --Check to see if any new events were created
    OPEN print_events_cur(v_request_id, p_project_id, p_event_type);
    FETCH print_events_cur INTO print_events_rec;
    IF (print_events_cur%NOTFOUND) THEN

        --No new events were created
        INSERT INTO pa_cap_event_creation_v
                (request_id,
                module,
                context,
                sub_context,
                capital_type,
                project_id,
                project_number,
                project_asset_id,
                asset_name,
                task_id,
                task_number,
                capital_event_id,
                capital_event_number,
                event_name,
                event_type,
                message_code,
                created_by,
                creation_date,
                org_id
                )
        VALUES
                (v_request_id,
                'PERIODIC_EVENT_CREATION', --module
                '2', --context (2 = New Event Creation)
                'NE', --sub_context
                p_event_type, --capital_type,
                p_project_id, --project_id,
                p_project_number, --project_number,
                NULL, --project_asset_id,
                NULL, --asset_name,
                NULL, --task_id,
                NULL, --task_number,
                NULL, --capital_event_id,
                NULL, --capital_event_number,
                NULL, --event_name,
                NULL, --event_type,
                'NO_EVENTS_CREATED',
                v_user_id, --created_by,
                SYSDATE, --creation_date,
                v_org_id --org_id
                );

    END IF;
    CLOSE print_events_cur;


    --Print successful event cost totals and asset listings
    FOR print_events_rec IN print_events_cur(v_request_id, p_project_id, p_event_type) LOOP

        --Print Event info
        INSERT INTO pa_cap_event_creation_v
                (request_id,
                module,
                context,
                sub_context,
                capital_type,
                project_id,
                project_number,
                project_asset_id,
                asset_name,
                task_id,
                task_number,
                capital_event_id,
                capital_event_number,
                event_name,
                event_type,
                message_code,
                created_by,
                creation_date,
                org_id
                )
        VALUES
                (v_request_id,
                'PERIODIC_EVENT_CREATION', --module
                '2', --context (2 = New Event Creation)
                'E', --sub_context
                p_event_type, --capital_type,
                p_project_id, --project_id,
                p_project_number, --project_number,
                NULL, --project_asset_id,
                NULL, --asset_name,
                NULL, --task_id,
                NULL, --task_number,
                print_events_rec.capital_event_id, --capital_event_id,
                print_events_rec.capital_event_number, --capital_event_number,
                print_events_rec.event_name, --event_name,
                print_events_rec.event_type, --event_type,
                'EVENT_CREATED',
                v_user_id, --created_by,
                SYSDATE, --creation_date,
                v_org_id --org_id
                );

    END LOOP;


    v_addtl_costs_or_assets := 'N';
    v_first_addtl := 'Y';

    --Check to see if any existing events may have had costs or assets added
    OPEN existing_events_cur(v_request_id, p_project_id, p_event_type);
    FETCH existing_events_cur INTO existing_events_rec;
    IF (existing_events_cur%NOTFOUND) THEN

        --No existing events could have had costs or assets added
        INSERT INTO pa_cap_event_creation_v
                (request_id,
                module,
                context,
                sub_context,
                capital_type,
                project_id,
                project_number,
                project_asset_id,
                asset_name,
                task_id,
                task_number,
                capital_event_id,
                capital_event_number,
                event_name,
                event_type,
                message_code,
                created_by,
                creation_date,
                org_id
                )
        VALUES
                (v_request_id,
                'PERIODIC_EVENT_CREATION', --module
                '3', --context (2 = Additions to Existing Events)
                'NE', --sub_context
                p_event_type, --capital_type,
                p_project_id, --project_id,
                p_project_number, --project_number,
                NULL, --project_asset_id,
                NULL, --asset_name,
                NULL, --task_id,
                NULL, --task_number,
                NULL, --capital_event_id,
                NULL, --capital_event_number,
                NULL, --event_name,
                NULL, --event_type,
                'NO_EVENT_ITEMS_ADDED',
                v_user_id, --created_by,
                SYSDATE, --creation_date,
                v_org_id --org_id
                );

        CLOSE existing_events_cur;
    ELSE

        CLOSE existing_events_cur;

        FOR existing_events_rec IN existing_events_cur(v_request_id, p_project_id, p_event_type) LOOP

            --Check for additional assets
            OPEN addtl_assets_cur(existing_events_rec.project_id,
                                  existing_events_rec.capital_event_id,
                                  v_request_id);
            FETCH addtl_assets_cur INTO addtl_assets_rec;
            IF (addtl_assets_cur%FOUND) THEN

                v_addtl_costs_or_assets := 'Y';

                --Print Assets added to Event info
                INSERT INTO pa_cap_event_creation_v
                    (request_id,
                     module,
                     context,
                     sub_context,
                     capital_type,
                     project_id,
                     project_number,
                     project_asset_id,
                     asset_name,
                     task_id,
                     task_number,
                     capital_event_id,
                     capital_event_number,
                     event_name,
                     event_type,
                     message_code,
                     created_by,
                     creation_date,
                     org_id
                     )
                VALUES
                    (v_request_id,
                    'PERIODIC_EVENT_CREATION', --module
                    '3', --context (3 = Additions to Existing Events)
                    'AE', --sub_context
                    p_event_type, --capital_type,
                    p_project_id, --project_id,
                    p_project_number, --project_number,
                    NULL, --project_asset_id,
                    NULL, --asset_name,
                    NULL, --task_id,
                    NULL, --task_number,
                    existing_events_rec.capital_event_id, --capital_event_id,
                    existing_events_rec.capital_event_number, --capital_event_number,
                    existing_events_rec.event_name, --event_name,
                    existing_events_rec.event_type, --event_type,
                    'EVENT_ASSETS_ADDED',
                    v_user_id, --created_by,
                    SYSDATE, --creation_date,
                    v_org_id --org_id
                    );

            END IF; --Additional assets added
            CLOSE addtl_assets_cur;


            --Check for additional costs
            OPEN addtl_costs_cur(existing_events_rec.project_id,
                                 existing_events_rec.capital_event_id,
                                 v_request_id);
            FETCH addtl_costs_cur INTO addtl_costs_rec;
            IF (addtl_costs_cur%FOUND) THEN

                v_addtl_costs_or_assets := 'Y';

                --Print Costs added to Event info
                INSERT INTO pa_cap_event_creation_v
                    (request_id,
                     module,
                     context,
                     sub_context,
                     capital_type,
                     project_id,
                     project_number,
                     project_asset_id,
                     asset_name,
                     task_id,
                     task_number,
                     capital_event_id,
                     capital_event_number,
                     event_name,
                     event_type,
                     message_code,
                     created_by,
                     creation_date,
                     org_id
                     )
                VALUES
                    (v_request_id,
                    'PERIODIC_EVENT_CREATION', --module
                    '3', --context (3 = Additions to Existing Events)
                    'CE', --sub_context
                    p_event_type, --capital_type,
                    p_project_id, --project_id,
                    p_project_number, --project_number,
                    NULL, --project_asset_id,
                    NULL, --asset_name,
                    NULL, --task_id,
                    NULL, --task_number,
                    existing_events_rec.capital_event_id, --capital_event_id,
                    existing_events_rec.capital_event_number, --capital_event_number,
                    existing_events_rec.event_name, --event_name,
                    existing_events_rec.event_type, --event_type,
                    'EVENT_COSTS_ADDED',
                    v_user_id, --created_by,
                    SYSDATE, --creation_date,
                    v_org_id --org_id
                    );


            END IF; --Additional costs added
            CLOSE addtl_costs_cur;

        END LOOP; --Look for additional costs and assets in existing events


        IF v_addtl_costs_or_assets = 'N' THEN

            --No existing events have had costs or assets added
            INSERT INTO pa_cap_event_creation_v
                (request_id,
                module,
                context,
                sub_context,
                capital_type,
                project_id,
                project_number,
                project_asset_id,
                asset_name,
                task_id,
                task_number,
                capital_event_id,
                capital_event_number,
                event_name,
                event_type,
                message_code,
                created_by,
                creation_date,
                org_id
                )
            VALUES
                (v_request_id,
                'PERIODIC_EVENT_CREATION', --module
                '3', --context (3 = Additions to Existing Events)
                'NE', --sub_context
                p_event_type, --capital_type,
                p_project_id, --project_id,
                p_project_number, --project_number,
                NULL, --project_asset_id,
                NULL, --asset_name,
                NULL, --task_id,
                NULL, --task_number,
                NULL, --capital_event_id,
                NULL, --capital_event_number,
                NULL, --event_name,
                NULL, --event_type,
                'NO_EVENT_ITEMS_ADDED',
                v_user_id, --created_by,
                SYSDATE, --creation_date,
                v_org_id --org_id
                );
        END IF;

    END IF; --Check for existing events


 EXCEPTION

    WHEN empty_cursor_error THEN
        retcode := -30;
        errbuf := 'Cannot find newly created Capital Event for project id '||p_project_id;
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,errbuf);
        FND_FILE.PUT_LINE(FND_FILE.LOG,errbuf);
        fnd_msg_pub.add_exc_msg(p_pkg_name     => 'PA_CAPITAL_EVENTS_PVT',
                                p_procedure_name => 'CREATE_EVENT_FOR_PROJECT',
                                p_error_text => SUBSTRB(errbuf,1,240));
        ROLLBACK;
        RAISE;



    WHEN OTHERS THEN
        retcode := SQLCODE;
        errbuf := 'Unexpected error for project id '||
                        p_project_id||': '||SQLCODE||' '||SQLERRM;
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,errbuf);
        FND_FILE.PUT_LINE(FND_FILE.LOG,errbuf);
        fnd_msg_pub.add_exc_msg(p_pkg_name     => 'PA_CAPITAL_EVENTS_PVT',
                                p_procedure_name => 'CREATE_EVENT_FOR_PROJECT',
                                p_error_text => SUBSTRB(errbuf,1,240));
        ROLLBACK;
        RAISE;


 END CREATE_EVENT_FOR_PROJECT;





PROCEDURE ATTACH_ASSETS
	(p_project_id 	        IN	    NUMBER,
    p_capital_event_id      IN	    NUMBER,
    p_book_type_code        IN      VARCHAR2 DEFAULT NULL,
    p_asset_name            IN      VARCHAR2 DEFAULT NULL,
    p_asset_category_id     IN      NUMBER DEFAULT NULL,
    p_location_id           IN      NUMBER DEFAULT NULL,
    p_asset_date_from       IN      DATE DEFAULT NULL,
    p_asset_date_to         IN      DATE DEFAULT NULL,
    p_task_number_from      IN      VARCHAR2 DEFAULT NULL,
    p_task_number_to        IN      VARCHAR2 DEFAULT NULL,
    p_ret_target_asset_id   IN      NUMBER DEFAULT NULL,
    x_assets_attached_count    OUT NOCOPY NUMBER,
    x_return_status            OUT NOCOPY VARCHAR2,
    x_msg_data                 OUT NOCOPY VARCHAR2) IS


    CURSOR  assets_cur (x_event_type VARCHAR2) IS
    SELECT  ppa.project_asset_id
    FROM    pa_project_assets_all ppa
    WHERE   ppa.project_id = p_project_id
    AND     ppa.capital_event_id IS NULL
    AND     ppa.project_asset_type = DECODE(x_event_type,'C','AS-BUILT','R','RETIREMENT_ADJUSTMENT','X')
    AND     ppa.date_placed_in_service IS NOT NULL
    AND     ppa.date_placed_in_service
        BETWEEN NVL(p_asset_date_from, ppa.date_placed_in_service)
            AND NVL(p_asset_date_to, ppa.date_placed_in_service)
    AND     NVL(ppa.book_type_code,'X') = NVL(p_book_type_code,NVL(ppa.book_type_code,'X'))
    AND     ppa.asset_name = NVL(p_asset_name,ppa.asset_name)
    AND     NVL(ppa.asset_category_id,-99) = NVL(p_asset_category_id,NVL(ppa.asset_category_id,-99))
    AND     NVL(ppa.location_id,-99) = NVL(p_location_id,NVL(ppa.location_id,-99))
    AND     NVL(ppa.ret_target_asset_id,-99) = NVL(p_ret_target_asset_id,NVL(ppa.ret_target_asset_id,-99))
    AND EXISTS
        (SELECT 'Assignment Exists'
        FROM    pa_project_asset_assignments paa
        WHERE   paa.project_id = p_project_id
        AND     (
                (paa.project_asset_id = ppa.project_asset_id) --Asset is specifically assigned to project or task(s)
                OR
                (paa.project_asset_id = 0 AND paa.task_id = 0) --There is a Project-Level Common Assignment
                )
        );

    assets_rec      assets_cur%ROWTYPE;


    CURSOR  task_assignments_cur (x_project_asset_id  NUMBER) IS
    SELECT  paa.project_asset_id,
            paa.task_id
    FROM    pa_project_asset_assignments paa,
            pa_tasks pt
    WHERE   pt.project_id = p_project_id
    AND     paa.project_id = p_project_id
    AND     paa.project_asset_id = x_project_asset_id
    AND     pt.task_id = paa.task_id
    AND     pt.task_number
        BETWEEN NVL(p_task_number_from, pt.task_number)
            AND NVL(p_task_number_to, pt.task_number);

    task_assignments_rec      task_assignments_cur%ROWTYPE;



    v_event_type        PA_CAPITAL_EVENTS.event_type%TYPE;
    v_user_id           NUMBER  := FND_GLOBAL.user_id;
    v_login_id          NUMBER  := FND_GLOBAL.login_id;


BEGIN
    x_return_status := 'S';
    x_assets_attached_count := 0;

    --Get capital event type
    SELECT  event_type
    INTO    v_event_type
    FROM    pa_capital_events
    WHERE   capital_event_id = p_capital_event_id;


    --Verify that assets exist to be attached
    OPEN assets_cur(v_event_type);
    FETCH assets_cur INTO assets_rec;
	IF assets_cur%NOTFOUND THEN
        CLOSE assets_cur;
        x_assets_attached_count := 0;
		RETURN;
	END IF;
	CLOSE assets_cur;


    --Attach assets to capital event
    FOR assets_rec IN assets_cur(v_event_type) LOOP

        --Test for Task Assignments, if Task Number From or To parameters have been specified
        IF p_task_number_from IS NOT NULL OR p_task_number_to IS NOT NULL THEN

            OPEN task_assignments_cur(assets_rec.project_asset_id);
            FETCH task_assignments_cur INTO task_assignments_rec;
           	IF task_assignments_cur%FOUND THEN

                --Update NULL capital_event_id with parameter value
                UPDATE  pa_project_assets_all
                SET     capital_event_id = p_capital_event_id,
                        last_update_date = SYSDATE,
				        last_updated_by = v_user_id,
                        last_update_login = v_login_id
                WHERE   project_asset_id = assets_rec.project_asset_id
                AND     capital_event_id IS NULL;

                x_assets_attached_count := x_assets_attached_count + 1;

            END IF;
	        CLOSE task_assignments_cur;

        ELSE

            --Update NULL capital_event_id with parameter value
            UPDATE  pa_project_assets_all
            SET     capital_event_id = p_capital_event_id,
                    last_update_date = SYSDATE,
				    last_updated_by = v_user_id,
                    last_update_login = v_login_id
            WHERE   project_asset_id = assets_rec.project_asset_id
            AND     capital_event_id IS NULL;

            x_assets_attached_count := x_assets_attached_count + 1;

        END IF;

    END LOOP; --Attach Assets


EXCEPTION

    WHEN OTHERS THEN
        x_return_status := 'U';
        x_msg_data := 'Unexpected error for capital event id '||
                        p_capital_event_id||': '||SQLCODE||' '||SQLERRM;
        RAISE;

END ATTACH_ASSETS;


PROCEDURE ATTACH_COSTS
	(p_project_id 	        IN	    NUMBER,
    p_capital_event_id      IN	    NUMBER,
    p_task_number_from      IN      VARCHAR2 DEFAULT NULL,
    p_task_number_to        IN      VARCHAR2 DEFAULT NULL,
    p_ei_date_from          IN      DATE DEFAULT NULL,
    p_ei_date_to            IN      DATE DEFAULT NULL,
    p_expenditure_type      IN      VARCHAR2 DEFAULT NULL,
    p_transaction_source    IN      VARCHAR2 DEFAULT NULL,
    x_costs_attached_count     OUT NOCOPY NUMBER,
    x_return_status            OUT NOCOPY VARCHAR2,
    x_msg_data                 OUT NOCOPY VARCHAR2) IS


    CURSOR  costs_cur (x_event_type VARCHAR2) IS
    SELECT  peia.expenditure_item_id,
            peia.task_id,
            t.top_task_id,
            t.parent_task_id
    FROM    pa_expenditure_items_all peia,
            pa_tasks t
    WHERE   t.project_id = p_project_id
    AND     peia.task_id = t.task_id
    AND     t.task_number
            BETWEEN NVL(p_task_number_from, t.task_number)
                AND NVL(p_task_number_to, t.task_number)
    AND     peia.capital_event_id IS NULL
    AND     peia.billable_flag = DECODE(x_event_type,'C','Y','N')
    AND     peia.revenue_distributed_flag = 'N'
    AND     peia.cost_distributed_flag = 'Y'
    AND     NVL(t.retirement_cost_flag,'N') = DECODE(x_event_type,'R','Y','N')
    AND     peia.expenditure_type = NVL(p_expenditure_type, peia.expenditure_type)
    AND     NVL(peia.transaction_source,'X') = NVL(p_transaction_source, NVL(peia.transaction_source,'X'))
    AND     peia.expenditure_item_date
            BETWEEN NVL(p_ei_date_from, peia.expenditure_item_date)
                AND NVL(p_ei_date_to, peia.expenditure_item_date)
    ORDER BY peia.task_id;

    costs_rec      costs_cur%ROWTYPE;


    CURSOR common_task_cur (x_task_id  NUMBER, x_top_task_id  NUMBER) IS
    SELECT  paa.task_id
    FROM    pa_project_asset_assignments paa
    WHERE   paa.project_id = p_project_id
    AND     paa.task_id IN (x_task_id,x_top_task_id)
    AND     paa.project_asset_id = 0;

    common_task_rec     common_task_cur%ROWTYPE;


    CURSOR wbs_branch_tasks_cur(x_parent_task_id  NUMBER,
                                x_current_task_id  NUMBER,
                                x_event_type  VARCHAR2) IS
    SELECT  task_id,
            task_number
    FROM    pa_tasks
    WHERE   task_id <> x_parent_task_id
    AND     task_id <> x_current_task_id
    AND     NVL(retirement_cost_flag,'N') = DECODE(x_event_type,'R','Y','N')
    CONNECT BY parent_task_id = PRIOR task_id
    START WITH task_id = x_parent_task_id;

    wbs_branch_tasks_rec    wbs_branch_tasks_cur%ROWTYPE;


    CURSOR task_asgn_assets_cur(x_project_id NUMBER,
                                x_capital_event_id NUMBER,
                                x_task_id  NUMBER,
                                x_event_type  VARCHAR2) IS
    SELECT  paa.project_asset_id
    FROM    pa_project_assets_all pa,
            pa_project_asset_assignments paa
    WHERE   pa.project_asset_id = paa.project_asset_id
    AND     pa.project_id = x_project_id
    AND     paa.project_id = x_project_id
    AND     pa.capital_event_id = x_capital_event_id
    AND     paa.task_id = x_task_id
    AND     pa.project_asset_type = DECODE(x_event_type,'C','AS-BUILT','R','RETIREMENT_ADJUSTMENT','AS-BUILT');

    task_asgn_assets_rec    task_asgn_assets_cur%ROWTYPE;



    v_event_type            PA_CAPITAL_EVENTS.event_type%TYPE;
    v_user_id               NUMBER  := FND_GLOBAL.user_id;
    v_login_id              NUMBER  := FND_GLOBAL.login_id;
    v_attach_ei             VARCHAR2(1) := 'N';
    v_project_assignment    VARCHAR2(1) := 'N';
    v_task_assignment       VARCHAR2(1) := 'N';
    v_common_asgn_exists    VARCHAR2(1) := 'N';
    v_task_id               NUMBER := 0;



    no_costs_to_attach       EXCEPTION;

BEGIN
    x_return_status := 'S';
    x_costs_attached_count := 0;

    --Get capital event type
    SELECT  event_type
    INTO    v_event_type
    FROM    pa_capital_events
    WHERE   capital_event_id = p_capital_event_id;


    --Verify that costs exist to be attached
    OPEN costs_cur(v_event_type);
    FETCH costs_cur INTO costs_rec;
	IF costs_cur%NOTFOUND THEN
        CLOSE costs_cur;
        x_costs_attached_count := 0;
        RETURN;
	END IF;
	CLOSE costs_cur;


    --Determine project-level Asset Assignments exist (Specific or Common)
    SELECT  DECODE(COUNT(*),0,'N','Y')
    INTO    v_project_assignment
    FROM    pa_project_asset_assignments
    WHERE   project_id = p_project_id
    AND     task_id = 0;

    --If so, all eligible costs can be attached
    IF v_project_assignment = 'Y' THEN
        v_attach_ei := 'Y';
    END IF;


    --Attach costs to capital event
    FOR costs_rec IN costs_cur(v_event_type) LOOP

        IF v_project_assignment = 'N' THEN

            --Perform logic whenever task break occurs
            IF NVL(v_task_id,0) <> costs_rec.task_id THEN

                v_task_id := costs_rec.task_id;

                --Determine if current task (or its Top Task) has a specific asset assignment
                --for an asset in the current event
                SELECT  DECODE(COUNT(*),0,'N','Y')
                INTO    v_task_assignment
                FROM    pa_project_asset_assignments paa,
                        pa_project_assets_all ppa
                WHERE   paa.project_id = p_project_id
                AND     paa.project_asset_id = ppa.project_asset_id
                AND     ppa.capital_event_id = p_capital_event_id
                AND     paa.task_id IN (costs_rec.task_id,costs_rec.top_task_id);

                --If so, all eligible costs can be attached
                IF v_task_assignment = 'Y' THEN
                    v_attach_ei := 'Y';
                ELSE
                    --Determine if current task (or its Top Task) has a Common assignment
                    OPEN common_task_cur(costs_rec.task_id,costs_rec.top_task_id);
                    FETCH common_task_cur INTO common_task_rec;
	                IF common_task_cur%NOTFOUND THEN
                        --Task has no common or specific assignment, do not attach costs
                        v_common_asgn_exists := 'N';
                        v_attach_ei := 'N';
                    ELSE
                        v_common_asgn_exists := 'Y';
                    END IF;
	                CLOSE common_task_cur;


                    --If the assignment task ID is also the top task, then all eligible costs can be attached
                    IF v_common_asgn_exists = 'Y' AND common_task_rec.task_id = costs_rec.top_task_id THEN

                        v_attach_ei := 'Y';

                    ELSIF v_common_asgn_exists = 'Y' AND common_task_rec.task_id <> costs_rec.top_task_id THEN

                        --Only attach costs if an asset assignment exists at or beneath the parent task
                        v_attach_ei := 'N';

                        --Attach all costs where asset assignment(s) exist at or beneath the Parent (not Top) Task
                        FOR wbs_branch_tasks_rec IN wbs_branch_tasks_cur(costs_rec.parent_task_id,
                                                                         costs_rec.task_id,
                                                                         v_event_type) LOOP

                            --Check for existence of asset assignments in current event on current task
                            OPEN task_asgn_assets_cur(p_project_id,
                                                      p_capital_event_id,
                                                      wbs_branch_tasks_rec.task_id,
                                                      v_event_type);
                            FETCH task_asgn_assets_cur INTO task_asgn_assets_rec;
                            IF task_asgn_assets_cur%FOUND THEN
                                v_attach_ei := 'Y';
                            END IF;
                            CLOSE task_asgn_assets_cur;

                        END LOOP; --WBS Branch Tasks

                    END IF;   --Common Assignment exists
                END IF; --Task Asset Assignment exists
            END IF; --Task ID control break
        END IF; --No Project Assignment exists

        IF v_attach_ei = 'Y' THEN

            --Update NULL capital_event_id with parameter value
            UPDATE  pa_expenditure_items_all
            SET     capital_event_id = p_capital_event_id,
                    last_update_date = SYSDATE,
		      		last_updated_by = v_user_id,
                    last_update_login = v_login_id
            WHERE   expenditure_item_id = costs_rec.expenditure_item_id
            AND     capital_event_id IS NULL;

            x_costs_attached_count := x_costs_attached_count + 1;
        END IF;

    END LOOP; --Attach Costs



EXCEPTION

    WHEN OTHERS THEN
        x_return_status := 'U';
        x_msg_data := 'Unexpected error for capital event id '||
                        p_capital_event_id||': '||SQLCODE||' '||SQLERRM;
        RAISE;

END ATTACH_COSTS;


END PA_CAPITAL_EVENTS_PVT;

/
