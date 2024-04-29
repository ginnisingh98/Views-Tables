--------------------------------------------------------
--  DDL for Package Body PA_FA_TIEBACK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_FA_TIEBACK_PVT" AS
/* $Header: PACFATBB.pls 115.5 2003/08/18 14:31:28 ajdas noship $ */


 PROCEDURE ASSETS_TIEBACK
	(errbuf                  OUT NOCOPY VARCHAR2,
    retcode                  OUT NOCOPY VARCHAR2) IS


    CURSOR project_assets_cur IS
    SELECT  pa.project_asset_id,
            pa.asset_number
    FROM    pa_project_assets pa
    WHERE   pa.project_asset_type = 'AS-BUILT'
    AND     pa.capitalized_flag = 'Y'
    AND     pa.fa_period_name IS NULL;

    project_assets_rec          project_assets_cur%ROWTYPE;


    CURSOR earliest_asset_period_cur(x_project_asset_id  NUMBER) IS
    SELECT  fdp.period_name, MIN(fit.date_effective)
    FROM    fa_deprn_periods fdp,
            fa_asset_invoices fai,
            fa_invoice_transactions fit,
            pa_project_asset_lines_all pal
    WHERE   fai.project_asset_line_id = pal.project_asset_line_id
    AND		pal.project_asset_id = x_project_asset_id
    AND     fai.invoice_transaction_id_in = fit.invoice_transaction_id
    AND     fit.transaction_type = 'MASS ADDITION'
    AND     fit.book_type_code = fdp.book_type_code
    AND     fit.date_effective BETWEEN fdp.period_open_date
               AND NVL(fdp.period_close_date,fit.date_effective)
    GROUP BY fdp.period_name
    ORDER BY MIN(fit.date_effective);

    earliest_asset_period_rec       earliest_asset_period_cur%ROWTYPE;


    CURSOR asset_lines_cur IS
    SELECT  pal.project_asset_line_id,
            pal.current_asset_cost
    FROM    pa_project_assets pa,
            pa_project_asset_lines_all pal
    WHERE   pa.project_asset_id = pal.project_asset_id
    AND     pa.project_asset_type = 'AS-BUILT'
    AND     pal.transfer_status_code = 'T'
    AND     pal.line_type = 'C'
    AND     pal.fa_period_name IS NULL;

    asset_lines_rec          asset_lines_cur%ROWTYPE;


    CURSOR asset_line_period_cur(x_project_asset_line_id  NUMBER) IS
    SELECT  fdp.period_name,
	        SUM(payables_cost) payables_cost
    FROM    fa_deprn_periods fdp,
            fa_asset_invoices fai,
            fa_invoice_transactions fit
    WHERE   fai.project_asset_line_id = x_project_asset_line_id
    AND     fai.invoice_transaction_id_in = fit.invoice_transaction_id
    AND     fit.transaction_type = 'MASS ADDITION'
    AND     fit.book_type_code = fdp.book_type_code
    AND     fit.date_effective BETWEEN fdp.period_open_date
               AND NVL(fdp.period_close_date,fit.date_effective)
    GROUP BY fdp.period_name;

    asset_line_period_rec       asset_line_period_cur%ROWTYPE;


    CURSOR fa_assets_cur(x_project_asset_id  NUMBER) IS
    SELECT 	fa.asset_id, fa.asset_number
    FROM   	fa_additions fa,
   			fa_asset_invoices fai,
    		pa_project_asset_lines_all pal
    WHERE   fai.project_asset_line_id = pal.project_asset_line_id
    AND		pal.project_asset_id = x_project_asset_id
    AND		fai.asset_id = fa.asset_id
    GROUP BY fa.asset_id, fa.asset_number;

    fa_assets_rec       fa_assets_cur%ROWTYPE;

    v_user                      NUMBER := FND_GLOBAL.user_id;
    v_login                     NUMBER := FND_GLOBAL.login_id;
    v_request_id                NUMBER := FND_GLOBAL.conc_request_id;
    v_program_application_id    NUMBER := FND_GLOBAL.prog_appl_id;
    v_program_id                NUMBER := FND_GLOBAL.conc_program_id;

    v_asset_count               NUMBER := 0;
    v_asset_number_count        NUMBER := 0;
    v_asset_number              fa_additions.asset_number%TYPE;
    v_asset_id                  fa_additions.asset_id%TYPE;
    v_fa_period_name            fa_deprn_periods.period_name%TYPE;
    v_asset_line_count          NUMBER := 0;

    PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

    l_commit_count              NUMBER := 0;


 BEGIN
    --Initialize variables
    retcode := 0;
    errbuf := NULL;

    PA_DEBUG.SET_PROCESS(x_process    => 'PLSQL',
                         x_debug_mode => PG_DEBUG);

    PA_DEBUG.WRITE_FILE('LOG', TO_CHAR(SYSDATE,'HH:MI:SS')||': PA_DEBUG_MODE: '||PG_DEBUG);



    --Print report heading
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,TO_CHAR(sysdate,'DD-MON-YYYY')||
                                '                                   '||
                                'PACFATBP - Tieback Asset Lines from Oracle Assets');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,fnd_global.local_chr(10));


    IF PG_DEBUG = 'Y' THEN
       PA_DEBUG.WRITE_FILE('LOG',TO_CHAR(SYSDATE,'HH:MI:SS')||': '||'Opening project_assets_cur');
    END IF;

    --Tieback all Project Assets that have not yet been Tied back
    FOR project_assets_rec IN project_assets_cur LOOP

        v_asset_number := NULL;
        v_asset_id := NULL;
        v_asset_number_count := 0;

        IF PG_DEBUG = 'Y' THEN
            PA_DEBUG.WRITE_FILE('LOG',TO_CHAR(SYSDATE,'HH:MI:SS')||': '||'Processing project asset id: '||project_assets_rec.project_asset_id);
            PA_DEBUG.WRITE_FILE('LOG',TO_CHAR(SYSDATE,'HH:MI:SS')||': '||'Opening earliest_asset_period_cur');
        END IF;

        --Get the earliest period posted into for any line related to the project asset
        OPEN earliest_asset_period_cur(project_assets_rec.project_asset_id);
        FETCH earliest_asset_period_cur INTO earliest_asset_period_rec;
        IF (earliest_asset_period_cur%NOTFOUND) THEN
            v_fa_period_name := NULL;
            IF PG_DEBUG = 'Y' THEN
                PA_DEBUG.WRITE_FILE('LOG',TO_CHAR(SYSDATE,'HH:MI:SS')||': '||'earliest_asset_period_cur NOTFOUND');
            END IF;
        ELSE
            v_fa_period_name := earliest_asset_period_rec.period_name;
            IF PG_DEBUG = 'Y' THEN
                PA_DEBUG.WRITE_FILE('LOG',TO_CHAR(SYSDATE,'HH:MI:SS')||': '||'Earliest asset period: '||v_fa_period_name);
            END IF;
        END IF;
        CLOSE earliest_asset_period_cur;


        IF PG_DEBUG = 'Y' THEN
            PA_DEBUG.WRITE_FILE('LOG',TO_CHAR(SYSDATE,'HH:MI:SS')||': '||'Opening fa_assets_cur');
        END IF;

        --Determine if all asset lines are associated with a single asset id
        FOR fa_assets_rec IN fa_assets_cur(project_assets_rec.project_asset_id) LOOP

            IF NVL(v_asset_id,-1) <> fa_assets_rec.asset_id THEN
            	v_asset_number_count := v_asset_number_count + 1;
                v_asset_number := fa_assets_rec.asset_number;
                v_asset_id := fa_assets_rec.asset_id;
            END IF;

        END LOOP;


        IF v_asset_number_count = 1 THEN --If this is zero, the asset has not yet been posted.
            --If it is > 1, an asset line has been split and the asset cannot be tied back


       	    IF PG_DEBUG = 'Y' THEN
                PA_DEBUG.WRITE_FILE('LOG',TO_CHAR(SYSDATE,'HH:MI:SS')||': '||'Single asset id: '||v_asset_id);
            END IF;


            IF  v_fa_period_name IS NOT NULL THEN

                IF  v_asset_number <> NVL(project_assets_rec.asset_number,'X') OR
                    project_assets_rec.asset_number IS NULL THEN

               	    IF PG_DEBUG = 'Y' THEN
                        PA_DEBUG.WRITE_FILE('LOG',TO_CHAR(SYSDATE,'HH:MI:SS')||': '||'Tieback project asset with asset number, fa_asset_id and fa period');
                    END IF;

                    --Update project asset with asset number and FA period name
                    UPDATE  pa_project_assets_all
                    SET     asset_number = v_asset_number,
                            fa_asset_id = v_asset_id,
                            fa_period_name = v_fa_period_name,
                            last_update_date = SYSDATE,
                            last_updated_by = v_user,
                            last_update_login = v_login,
                            request_id = v_request_id,
                            program_application_id = v_program_application_id,
                            program_id = v_program_id
                    WHERE   project_asset_id = project_assets_rec.project_asset_id;

                    v_asset_count := v_asset_count + 1;
                    l_commit_count := l_commit_count + 1;

                ELSE
               	    IF PG_DEBUG = 'Y' THEN
                        PA_DEBUG.WRITE_FILE('LOG',TO_CHAR(SYSDATE,'HH:MI:SS')||': '||'Tieback project asset with fa_asset_id and fa period');
                    END IF;

                    --Just update the FA Period Name and FA Asset ID
                    UPDATE  pa_project_assets_all
                    SET     fa_period_name = v_fa_period_name,
                            fa_asset_id = v_asset_id,
                            last_update_date = SYSDATE,
                            last_updated_by = v_user,
                            last_update_login = v_login,
                            request_id = v_request_id,
                            program_application_id = v_program_application_id,
                            program_id = v_program_id
                    WHERE   project_asset_id = project_assets_rec.project_asset_id;

                    v_asset_count := v_asset_count + 1;
                    l_commit_count := l_commit_count + 1;

                END IF; --v_asset_number differs from current asset number (or current asset number IS NULL)

            END IF; --v_fa_period_name IS NOT NULL

        END IF; --v_asset_number_count = 1

        If l_commit_count > 1000 Then
           COMMIT;
           l_commit_count := 0;
        End If;

    END LOOP; --Project Assets

    IF PG_DEBUG = 'Y' THEN
       PA_DEBUG.WRITE_FILE('LOG',TO_CHAR(SYSDATE,'HH:MI:SS')||': '||'l_commit_count = '||l_commit_count);
    END IF;

    Commit;
    l_commit_count := 0;

    IF PG_DEBUG = 'Y' THEN
       PA_DEBUG.WRITE_FILE('LOG',TO_CHAR(SYSDATE,'HH:MI:SS')||': '||'Opening asset_lines_cur');
    END IF;

    --Tieback all Project Asset Lines that have not yet been tied back
    FOR asset_lines_rec IN asset_lines_cur LOOP

        IF PG_DEBUG = 'Y' THEN
            PA_DEBUG.WRITE_FILE('LOG',TO_CHAR(SYSDATE,'HH:MI:SS')||': '||'Processing asset line id: '||asset_lines_rec.project_asset_line_id);
            PA_DEBUG.WRITE_FILE('LOG',TO_CHAR(SYSDATE,'HH:MI:SS')||': '||'Opening asset_line_period_cur');
        END IF;

        --Loop through FA periods posted, checking if the entire line was posted into a single period
        FOR asset_line_period_rec IN asset_line_period_cur(asset_lines_rec.project_asset_line_id) LOOP

            --Check if entire line posted into single period.  Will also avoid "header" lines where payables_cost = 0
            IF  asset_lines_rec.current_asset_cost = asset_line_period_rec.payables_cost THEN

                IF PG_DEBUG = 'Y' THEN
                    PA_DEBUG.WRITE_FILE('LOG',TO_CHAR(SYSDATE,'HH:MI:SS')||': '||'Tieback project asset line with fa period: '||asset_line_period_rec.period_name);
                END IF;

                --Update asset line with FA Period Name
                UPDATE  pa_project_asset_lines_all
                SET     fa_period_name = asset_line_period_rec.period_name,
                        last_update_date = SYSDATE,
                        last_updated_by = v_user,
                        last_update_login = v_login,
                        request_id = v_request_id,
                        program_application_id = v_program_application_id,
                        program_id = v_program_id
                WHERE   project_asset_line_id = asset_lines_rec.project_asset_line_id;

                v_asset_line_count := v_asset_line_count + 1;
                l_commit_count := l_commit_count + 1;

            END IF; --Entire asset line has been posted into a single period

        END LOOP; --Asset line periods

        If l_commit_count > 1000 Then
           COMMIT;
           l_commit_count := 0;
        End If;

    END LOOP; --Asset Lines

    IF PG_DEBUG = 'Y' THEN
       PA_DEBUG.WRITE_FILE('LOG',TO_CHAR(SYSDATE,'HH:MI:SS')||': '||'l_commit_count = '||l_commit_count);
    END IF;
    Commit;

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'Tieback completed successfully.');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,fnd_global.local_chr(10));


    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,v_asset_count||' project assets were tied back.');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,v_asset_line_count||' project asset lines were tied back.');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,fnd_global.local_chr(10));


 EXCEPTION

    WHEN OTHERS THEN
        Rollback;
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'Unexpected error: '||SQLCODE||' '||SQLERRM);
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,fnd_global.local_chr(10));

        FND_FILE.PUT_LINE(FND_FILE.LOG,'Unexpected error: '||SQLCODE||' '||SQLERRM);
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,fnd_global.local_chr(10));

        retcode := SQLCODE;
        errbuf := SQLERRM;
        RAISE;

 END ASSETS_TIEBACK;

END PA_FA_TIEBACK_PVT;

/
