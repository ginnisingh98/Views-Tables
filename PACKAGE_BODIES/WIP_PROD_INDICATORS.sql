--------------------------------------------------------
--  DDL for Package Body WIP_PROD_INDICATORS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_PROD_INDICATORS" AS
/* $Header: wippindb.pls 120.1 2006/06/09 08:38:34 srayadur noship $ */


    g_userid    NUMBER;
    g_applicationid NUMBER;
    g_debug     NUMBER;  -- turning on debug mode
    g_date_from DATE ;
    g_date_to   DATE;
    g_uom_code  mtl_units_of_measure.uom_code%type;
    g_uom_class mtl_units_of_measure.uom_class%type;

    /* Constants for session - including schema name for truncating and
       collecting stats */
    g_wip_schema      VARCHAR2(30);
    g_status          VARCHAR2(30);
    g_industry        VARCHAR2(30);
    WIP_CALL_LOG      INTEGER; -- Bug 3624837
    /* Wip Contants for identifying the type */
    WIP_EFFICIENCY      CONSTANT INTEGER := 1 ;
    WIP_UTILIZATION     CONSTANT INTEGER := 2 ;
    WIP_YIELD       CONSTANT INTEGER := 3 ;
    WIP_PRODUCTIVITY    CONSTANT INTEGER := 4 ;
    WIP_RESOURCE_LOAD   CONSTANT INTEGER := 5 ;


    /*Wip Process Phase Constants */
    WIP_DEPT_YIELD      CONSTANT INTEGER := 2 ;
    WIP_RES_YIELD       CONSTANT INTEGER := 3 ;
    WIP_UTZ_PHASE_ONE   CONSTANT INTEGER := 1 ;
    WIP_UTZ_PHASE_TWO   CONSTANT INTEGER := 2 ;
    WIP_EFF_PHASE_ONE   CONSTANT INTEGER := 1 ;
    WIP_EFF_PHASE_TWO   CONSTANT INTEGER := 2 ;
    WIP_EFF_PHASE_THREE CONSTANT INTEGER := 3 ;
    WIP_EFF_PHASE_FOUR  CONSTANT INTEGER := 4 ; -- bug 3280647
    WIP_PROD_PHASE_ONE  CONSTANT INTEGER := 1 ;
    WIP_PROD_PHASE_TWO  CONSTANT INTEGER := 2 ;
    WIP_PROD_PHASE_THREE    CONSTANT INTEGER := 3 ;
    WIP_PROD_PHASE_FOUR CONSTANT INTEGER := 4 ;
    WIP_RL_PHASE_ONE    CONSTANT INTEGER := 1 ;
    WIP_RL_PHASE_TWO    CONSTANT INTEGER := 2 ;
    WIP_RL_PHASE_THREE  CONSTANT INTEGER := 3 ;



    /* Private Procedures */
    PROCEDURE Misc_Applied_Units(
            p_group_id    IN  NUMBER,
            p_organization_id IN  NUMBER,
            p_date_from   IN  DATE,
            p_date_to     IN  DATE,
            p_department_id   IN  NUMBER,
            p_resource_id     IN  NUMBER,
            p_errnum      OUT NOCOPY NUMBER,
            p_errmesg     OUT NOCOPY VARCHAR2);


    PROCEDURE Resource_Yield(
            p_group_id  IN  NUMBER,
            p_errnum    OUT NOCOPY NUMBER,
            p_errmesg   OUT NOCOPY VARCHAR2);

    PROCEDURE Move_Info_Into_Summary(
            p_group_id  IN  NUMBER,
            p_errnum    OUT NOCOPY NUMBER,
            p_errmesg   OUT NOCOPY VARCHAR2);

    PROCEDURE Move_Yield_Info(
            p_group_id  IN  NUMBER,
            p_errnum    OUT NOCOPY NUMBER,
            p_errmesg   OUT NOCOPY VARCHAR2);

    PROCEDURE Move_Utz_Info(
            p_group_id  IN NUMBER,
            p_errnum    OUT NOCOPY NUMBER,
            p_errmesg   OUT NOCOPY VARCHAR2);

    PROCEDURE Post_Move_CleanUp(
            p_group_id  IN  NUMBER,
            p_errnum    OUT NOCOPY NUMBER,
            p_errmesg   OUT NOCOPY VARCHAR2);

    PROCEDURE Pre_Program_CleanUp(
            p_errnum    OUT NOCOPY NUMBER,
            p_errmesg   OUT NOCOPY VARCHAR2);

    PROCEDURE Move_SFCB_Utz_Info(
            p_group_id          IN  NUMBER,
            p_organization_id   IN  NUMBER,
            p_date_from         IN  DATE,
            p_date_to           IN  DATE,
            p_department_id     IN  NUMBER,
            p_resource_id       IN  NUMBER,
            p_userid            IN  NUMBER,
            p_applicationid     IN  NUMBER,
            p_errnum            OUT NOCOPY NUMBER,
            p_errmesg           OUT NOCOPY VARCHAR2);

    FUNCTION check_backup_needed
        RETURN BOOLEAN;

    PROCEDURE backup_summary_tables (
            p_max_backup_date IN DATE,
            p_errnum            OUT NOCOPY NUMBER,
            p_errmesg           OUT NOCOPY VARCHAR2);


    PROCEDURE update_existing_flag (
            p_errnum            OUT NOCOPY NUMBER,
            p_errmesg           OUT NOCOPY VARCHAR2);

    PROCEDURE merge_previous_run_data (
            p_errnum            OUT NOCOPY NUMBER,
            p_errmesg           OUT NOCOPY VARCHAR2);


    PROCEDURE clear_temp_summary_tables (
            p_errnum            OUT NOCOPY NUMBER,
            p_errmesg           OUT NOCOPY VARCHAR2);


    PROCEDURE populate_temp_table (
            p_table_name        IN VARCHAR2,
            p_indicator         IN NUMBER,
            p_group_id          IN NUMBER);
    --Added for Bug 3280647
    PROCEDURE populate_eff_temp_table (
            p_table_name        IN VARCHAR2,
            p_indicator         IN NUMBER,
            p_group_id          IN NUMBER);

    /* Exceptions to be used in this file
    */
    -- for some stage failure
    collection_stage_failed EXCEPTION;
    PRAGMA EXCEPTION_INIT (collection_stage_failed, -20000);


    /* Load_Summary_Info
    This is the encapsulation that gets called from
    the concurrent program. Main wrapper for capture production indicators
    program.
    */

    PROCEDURE Load_Summary_Info(
                errbuf          OUT NOCOPY  VARCHAR2,
                retcode         OUT NOCOPY VARCHAR2,
                p_date_from     IN  VARCHAR2,
                p_date_to       IN  VARCHAR2) IS

            x_errnum    NUMBER;
            x_errmesg   VARCHAR2(240);
            p_from_date     DATE;
            p_to_date     DATE;
    BEGIN
        g_debug  := 1;
        WIP_CALL_LOG:=1; -- To differentiate b/w call of Capture production indicator and discrete workstation
        p_from_date := FND_DATE.canonical_to_date(p_date_from);
        p_to_date := FND_DATE.canonical_to_date(p_date_to);

        Populate_Summary_Table(
            p_group_id => null,
            p_organization_id => null,
            p_date_from => p_from_date,
            p_date_to => p_to_date,
            p_department_id => null,
            p_resource_id => null,
            p_userid => null,
            p_applicationid => null,
            p_errnum => x_errnum,
            p_errmesg => x_errmesg ) ;

        errbuf := x_errmesg ;
        retcode := to_char(x_errnum);

    EXCEPTION
        WHEN OTHERS THEN
            FND_FILE.PUT_LINE (fnd_file.log, 'Capture Production Indicators has terminated with an exception');
            FND_FILE.PUT_LINE (fnd_file.log, SQLERRM);
            rollback;
            errbuf := SQLERRM;
            retcode := to_char (-1);

    END Load_Summary_Info ;


    /*
        Main wrapper for all the routines and logic in this file.
    */
    PROCEDURE Populate_Summary_Table (
            p_group_id          IN  NUMBER,
            p_organization_id   IN  NUMBER,
            p_date_from         IN  DATE,
            p_date_to           IN  DATE,
            p_department_id     IN  NUMBER,
            p_resource_id       IN  NUMBER,
            p_userid            IN  NUMBER,
            p_applicationid     IN  NUMBER,
            p_errnum            OUT NOCOPY NUMBER,
            p_errmesg           OUT NOCOPY VARCHAR2)

    IS
    x_group_id NUMBER;
    x_userid NUMBER;
    x_appl_id NUMBER;
    x_date_from DATE;
    x_date_to DATE;
    x_mrp_debug VARCHAR2(2);
    x_mrp_trace VARCHAR2(2);

    -- Boolean flag to determine if old data needs to be backed up
    l_backup_old_data BOOLEAN ;

    -- exception in case some stage fails. This is now important because
    -- of the backing up and merging at the end. If some stage after
    -- the back  up fails, empty out the summary tables, and restore
    -- backup.

    BEGIN
    l_backup_old_data := TRUE;
        /* get global session parameters */
        IF NOT (fnd_installation.get_app_info(
            'WIP', g_status, g_industry, g_wip_schema)) THEN

            RAISE_APPLICATION_ERROR (-20000,
                                     'Unable to get session information.');

        END IF;


        if p_userid is null then
            -- This is an Error Condition
            x_userid :=  fnd_global.user_id ;
        else
            x_userid := p_userid ;
        end if;

        IF p_group_id IS NULL THEN
            select wip_indicators_temp_s.nextval into x_group_id
            from sys.dual ;
        ELSE
            x_group_id := p_group_id ;
        END IF;


        if p_applicationid is null then
            x_appl_id := fnd_global.prog_appl_id ;
        else
            x_appl_id := p_applicationid ;
        end if;


        g_userid := x_userid ;
        g_applicationid := x_appl_id ;
        p_errnum := 0;
        p_errmesg := '';


        IF p_date_from IS NULL THEN
            begin

                select trunc(min(calendar_date))
                into g_date_from
                from bom_calendar_dates ;

            exception
                when no_data_found then
                g_date_from := sysdate ;
            end ;

        ELSE
            g_date_from := p_date_from;

        END IF;

        IF p_date_to IS NULL THEN
            begin

                select trunc(max(calendar_date))
                into g_date_to
                from bom_calendar_dates ;

            exception
                when no_data_found then
                g_date_to := sysdate ;
            end ;

        ELSE
            g_date_to := p_date_to;
        END IF;

        x_date_from := g_date_from ;
        x_date_to := g_date_to ;

        -- always print debug messages to log.
        g_debug := 1;

        fnd_file.put_line (fnd_file.log,
                           to_char (sysdate, 'DD-MON-YYYY HH24:MI:SS'));
        fnd_file.put_line(fnd_file.log,'Commencing WIP Capture Production Indicators.');

        -- Step 0: Determine if old data needs to be backed up
        l_backup_old_data := check_backup_needed ();

        -- Step 5: Backup of old data
        if g_debug = 1 then
            fnd_file.put_line (fnd_file.log,
                               to_char (sysdate, 'DD-MON-YYYY HH24:MI:SS'));
            fnd_file.put_line(fnd_file.log,'Previous Data Backup - Stage 5');
        end if ;

        -- Previously, the this program used to throw away all the existing
        -- data in the tables:
        -- WIP_BIS_PROD_INDICATORS
        -- WIP_BIS_PROD_DEPT_YIELD
        -- WIP_BIS_PROD_ASSY_YIELD
        -- This has to be avoided now. So we are doing the following:
        -- Each of these tables will be backed up into a temp table
        -- The original tables will be truncated as before.
        -- When the program is done, then the data in the temp tables
        -- prior to the start date of this run will be merged with the
        -- data in this run. Data in the backed up temp tables beyond the
        -- start date of this run will be thrown away.
        -- This data has already been denormalized.
        IF (l_backup_old_data) THEN
            backup_summary_tables (x_date_from, p_errnum, p_errmesg);
        END IF;

	-- RS: If backup fails then , don't raise collection_stage_failed as this
	-- would truncate the summary tables completely. There might be a reason
	-- for this to fail due to unforeseen database issues like tablespace
	-- insufficiency, etc at the customer site. These issues are external and
	-- can be handled separately.Once, they are corrected the collection we
	-- should be able to re-run the request for the last request range alone
	-- and no data should be lost in such cases. So, this wouldn't be handled
	-- here but in the exception block of this procedure. Commented below.

        --if(p_errnum <0 )then
        --    raise collection_stage_failed;
        --end if ;
        commit;

        ----dbms_output.put_line('Remove the Inconsitent Data - Preface');


        -- Step 1: Clean up of work tables
        if g_debug = 1 then
            fnd_file.put_line (fnd_file.log,
                               to_char (sysdate, 'DD-MON-YYYY HH24:MI:SS'));
            fnd_file.put_line(fnd_file.log,'Initial Clean up - Stage 1');
        end if ;
        --dbms_output.put_line (to_char (sysdate, 'DD-MON-YYYY HH24:MI:SS'));
        --dbms_output.put_line('Initial Clean Up - Stage 1');

        -- Clear the main temp table, wip_indicators_temp
        Delete_Temp_Info(p_group_id => x_group_id);
        commit ;

        -- Clean up all temp/working/base tables.
        Pre_Program_CleanUp(p_errnum => p_errnum,
                            p_errmesg => p_errmesg);

        commit ;

        if(p_errnum <0 )then
            raise collection_stage_failed;
        end if ;

        -- Step 2: Collection of efficiency data into temp table
        if g_debug = 1 then
            fnd_file.put_line (fnd_file.log,
                               to_char (sysdate, 'DD-MON-YYYY HH24:MI:SS'));
            fnd_file.put_line(fnd_file.log, 'Before Stage 2');
        end if ;
        --dbms_output.put_line (to_char (sysdate, 'DD-MON-YYYY HH24:MI:SS'));
        --dbms_output.put_line('Before Stage 2');

        -- Populate Efficiency data into wip_indicators_temp
        Populate_Efficiency(
            p_group_id => x_group_id,
            p_organization_id => p_organization_id,
            p_date_from => x_date_from,
            p_date_to => x_date_to,
            p_department_id => p_department_id,
            p_resource_id => p_resource_id,
            p_userid => x_userid,
            p_applicationid => x_appl_id,
            p_errnum => p_errnum,
            p_errmesg => p_errmesg );
        commit;

        if(p_errnum <0 )then
            raise collection_stage_failed;
        end if ;

        -- Step 3: collection of utilization data into temp table
        if g_debug = 1 then
            fnd_file.put_line (fnd_file.log,
                               to_char (sysdate, 'DD-MON-YYYY HH24:MI:SS'));
            fnd_file.put_line(fnd_file.log, 'Before Stage 3');
        end if ;
        --dbms_output.put_line (to_char (sysdate, 'DD-MON-YYYY HH24:MI:SS'));
        --dbms_output.put_line('Before Stage 3');

        -- Populate Utilization data into wip_indicators_temp
        Populate_Utilization(
            p_group_id => x_group_id,
            p_organization_id => p_organization_id,
            p_date_from => x_date_from,
            p_date_to => x_date_to,
            p_department_id => p_department_id,
            p_resource_id => p_resource_id,
            p_userid => x_userid,
            p_applicationid => x_appl_id,
            p_errnum => p_errnum,
            p_errmesg => p_errmesg );
        commit;

        if(p_errnum <0 )then
            raise collection_stage_failed;
        end if ;


        -- Step 4: Collection of Yield data into temp table
        if g_debug = 1 then
            fnd_file.put_line (fnd_file.log,
                               to_char (sysdate, 'DD-MON-YYYY HH24:MI:SS'));
            fnd_file.put_line(fnd_file.log, 'Before Stage 4');
        end if ;
        --dbms_output.put_line (to_char (sysdate, 'DD-MON-YYYY HH24:MI:SS'));
        --dbms_output.put_line('Before Stage 4');

        -- Populate Yield data into wip_indicators_temp
        Populate_Yield(
            p_group_id => x_group_id,
            p_organization_id => p_organization_id,
            p_date_from => x_date_from,
            p_date_to => x_date_to,
            p_department_id => p_department_id,
            p_resource_id => p_resource_id,
            p_userid => x_userid,
            p_applicationid => x_appl_id,
            p_errnum => p_errnum,
            p_errmesg => p_errmesg );
        commit;

        if(p_errnum <0 )then
            raise collection_stage_failed;
        end if ;

        -- Step 5: Populate efficiency, resource, utilization data into
        -- summary table
        if g_debug = 1 then
            fnd_file.put_line (fnd_file.log,
                               to_char (sysdate, 'DD-MON-YYYY HH24:MI:SS'));
            fnd_file.put_line(fnd_file.log, 'Before Stage 5');
        end if ;
        --dbms_output.put_line (to_char (sysdate, 'DD-MON-YYYY HH24:MI:SS'));
        --dbms_output.put_line('Before Stage 5');

        -- Move the collected efficiency, utilization and yield data into
        -- the summary table wip_bis_prod_indicators
        Move_Info_Into_Summary(
            p_group_id => x_group_id,
            p_errnum => p_errnum,
            p_errmesg => p_errmesg );
        commit;

        if(p_errnum <0 )then
            raise collection_stage_failed;
        end if ;

        -- Step 6: Move the resource yield information into its
        -- summary table.
        if g_debug = 1 then
            fnd_file.put_line (fnd_file.log,
                               to_char (sysdate, 'DD-MON-YYYY HH24:MI:SS'));
            fnd_file.put_line(fnd_file.log, 'Before Stage 6');
        end if ;
        --dbms_output.put_line (to_char (sysdate, 'DD-MON-YYYY HH24:MI:SS'));
        --dbms_output.put_line('Before Stage 6');

        -- Move the yield information for each department into the
        -- the summary table wip_bis_prod_dept_yield
        Move_Yield_Info(
            p_group_id => x_group_id,
            p_errnum => p_errnum,
            p_errmesg => p_errmesg );
        commit;

        if(p_errnum <0 )then
            raise collection_stage_failed;
        end if ;

        -- Stage 7: MIA

        -- Stage 8: Collect and populate the assembly yield data into
        -- summary table
        if g_debug = 1 then
            fnd_file.put_line (fnd_file.log,
                               to_char (sysdate, 'DD-MON-YYYY HH24:MI:SS'));
            fnd_file.put_line(fnd_file.log, 'Before Stage 8');
        end if ;
        --dbms_output.put_line (to_char (sysdate, 'DD-MON-YYYY HH24:MI:SS'));
        --dbms_output.put_line('Before Stage 8');

        -- Populate Assembly yield data directly into WIP_BIS_PROD_ASSY_YIELD.
        -- No staging table required in this step.
        Populate_Assy_Yield(
            p_organization_id => p_organization_id,
            p_date_from => x_date_from,
            p_date_to => x_date_to,
            p_userid => x_userid,
            p_applicationid => x_appl_id,
            p_errnum => p_errnum,
            p_errmesg => p_errmesg );
        commit;

        if(p_errnum <0 )then
            raise collection_stage_failed;
        end if ;

        -- Stage 9: Clean up all temp tables since all data has been
        -- transferred to summary tables.
        if g_debug = 1 then
            fnd_file.put_line (fnd_file.log,
                               to_char (sysdate, 'DD-MON-YYYY HH24:MI:SS'));
            fnd_file.put_line(fnd_file.log, 'Before Stage 9');
        end if ;
        --dbms_output.put_line (to_char (sysdate, 'DD-MON-YYYY HH24:MI:SS'));
        --dbms_output.put_line('Before Stage 9');

        -- Clean up all the work tables. Simply truncate them all.
        Post_Move_CleanUp(p_group_id => x_group_id,
                          p_errnum => p_errnum,
                          p_errmesg => p_errmesg );
        commit;

        if(p_errnum <0 )then
            raise collection_stage_failed;
        end if ;


        -- Stage 10: Denormalize the organization, item, time and
        -- geographical location info in the summary tables.
        if g_debug = 1 then
            fnd_file.put_line (fnd_file.log,
                               to_char (sysdate, 'DD-MON-YYYY HH24:MI:SS'));
            fnd_file.put_line(fnd_file.log, 'Before Stage 10');
        end if ;
        --dbms_output.put_line (to_char (sysdate, 'DD-MON-YYYY HH24:MI:SS'));
        --dbms_output.put_line('Before Stage 10');

        -- Populate the denormalized information into the summary tables:
        -- 1. WIP_BIS_PROD_INDICATORS
        -- 2. WIP_BIS_PROD_ASSY_YIELD
        -- 3. WIP_BIS_PROD_DEPT_YIELD
        Populate_Denormalize_Data(p_errnum => p_errnum,
                                  p_errmesg => p_errmesg );
        commit;

        if(p_errnum <0 )then
            raise collection_stage_failed;
        end if ;

        -- Stage: 10.5
        -- Update existing flag to 1 for all new rows because
        -- that is the filtering criterion for wip_bis_prod_assy_yield_v
        -- and wip_bis_prod_dept_yield_v.
        -- Bugfix 3387800.

        if g_debug = 1 then
            fnd_file.put_line (fnd_file.log,
                               to_char (sysdate, 'DD-MON-YYYY HH24:MI:SS'));
            fnd_file.put_line(fnd_file.log, 'Before Stage 10.5');
        end if ;

        update_existing_flag (p_errnum => p_errnum,
                              p_errmesg => p_errmesg);

        commit;

        if(p_errnum <0 )then
            raise collection_stage_failed;
        end if ;

        -- Stage 11: Merge back data from previous runs that was not
        -- recollected. This was not part of the original functionality
        -- of the program, but was added later.
        if g_debug = 1 then
            fnd_file.put_line (fnd_file.log,
                               to_char (sysdate, 'DD-MON-YYYY HH24:MI:SS'));
            fnd_file.put_line(fnd_file.log, 'Before Stage 11');
        end if ;
        --dbms_output.put_line (to_char (sysdate, 'DD-MON-YYYY HH24:MI:SS'));
        --dbms_output.put_line('Before Stage 11');

        -- Merge already collected data that was backed up in temp tables,
        -- for dates that did not lie in the specified date range for
        -- this run. Only merge if old data has been backed up
        IF (l_backup_old_data) THEN
            merge_previous_run_data (p_errnum, p_errmesg);
        END IF;

	-- RS: If merge fails then , we would truncate the summary tables which
	-- would have data for the present collection range and terminate the request.
	-- The user may run the collection again after fixing the issue.
	-- if(p_errnum <0 )then
        --    raise collection_stage_failed;
        -- end if ;
        commit;

        -- Stage 12: Delete the temp staging table, wip_indicators_temp.
        if g_debug = 1 then
            fnd_file.put_line(fnd_file.log, 'Before Stage 12');
            fnd_file.put_line (fnd_file.log,
                               to_char (sysdate, 'DD-MON-YYYY HH24:MI:SS'));
        end if ;
        --dbms_output.put_line (to_char (sysdate, 'DD-MON-YYYY HH24:MI:SS'));
        --dbms_output.put_line('Before Stage 12');

        -- Delete any existing data with this group ID
        Delete_Temp_Info(p_group_id => x_group_id);
        commit ;

        fnd_file.put_line (fnd_file.log,
                           to_char (sysdate, 'DD-MON-YYYY HH24:MI:SS'));
        fnd_file.put_line (fnd_file.log,
                           'Capture Production indicators has terminated successfully.');
        fnd_file.put_line (fnd_file.log,
                           'Dates collected: ' ||
                            to_char (x_date_from, 'DD-MON-YYYY') || ' to ' ||
                            to_char (x_date_to, 'DD-MON-YYYY'));
        p_errnum := 0;
        p_errmesg := '';

        --dbms_output.put_line (to_char (sysdate, 'DD-MON-YYYY HH24:MI:SS'));
        --dbms_output.put_line ('Done');
        return ;

    Exception

        when collection_stage_failed then

            if g_debug = 1 then
                fnd_file.put_line(fnd_file.log, SQLCODE);
                fnd_file.put_line(fnd_file.log,SQLERRM);
                fnd_file.put_line (fnd_file.log,
                                   'A collection stage has failed. ' ||
                                   'All data starting from ' || x_date_from ||
                                   ' is being purged and must be recollected.'
                                  );
            end if ;

            -- truncate the 3 summary tables
            execute immediate 'truncate table ' || g_wip_schema ||
                              '.WIP_BIS_PROD_INDICATORS';

            execute immediate 'truncate table ' || g_wip_schema ||
                              '.WIP_BIS_PROD_DEPT_YIELD';

            execute immediate 'truncate table ' || g_wip_schema ||
                              '.WIP_BIS_PROD_ASSY_YIELD';
            -- keep data that is not part if this collection's date range
            merge_previous_run_data (p_errnum, p_errmesg);
            commit ;

            -- clean up all the collected/staged data
            Delete_Temp_Info(p_group_id =>x_group_id);
            Post_Move_CleanUp(p_group_id => x_group_id,
                              p_errnum => p_errnum,
                              p_errmesg => p_errmesg );
            commit ;


            p_errnum := -1 ;
            p_errmesg := substr(SQLERRM,1,150);

            return ;

        when others then

            if g_debug = 1 then
                fnd_file.put_line(fnd_file.log, SQLCODE);
                fnd_file.put_line(fnd_file.log, SQLERRM);
		fnd_file.put_line(fnd_file.log,'Clean up of collected/staged data');
            end if ;
            --dbms_output.put_line(SQLCODE);
            --dbms_output.put_line(SQLERRM);


            -- clean up all the collected/staged data
            Delete_Temp_Info(p_group_id =>x_group_id);
            Post_Move_CleanUp(p_group_id => x_group_id,
                              p_errnum => p_errnum,
                              p_errmesg => p_errmesg );
	    commit;

            p_errnum := -1;
            p_errmesg := substr(SQLERRM,1,150);

            return ;

    End Populate_Summary_Table ;



    /* Populate_Efficiency
    Procedure that populates the efficiency information into
    the temp table wip_indicators_temp
    */

    PROCEDURE Populate_Efficiency(
            p_group_id          IN  NUMBER,
            p_organization_id   IN  NUMBER,
            p_date_from         IN  DATE,
            p_date_to           IN  DATE,
            p_department_id     IN  NUMBER,
            p_resource_id       IN  NUMBER,
            p_userid            IN  NUMBER,
            p_applicationid     IN  NUMBER,
            p_errnum            OUT NOCOPY NUMBER,
            p_errmesg           OUT NOCOPY VARCHAR2)

    IS
        x_group_id  NUMBER;
        x_phase     VARCHAR2(10) ;
        x_date_from     DATE;
        x_date_to   DATE;
        x_userid    NUMBER;
        x_appl_id   NUMBER;
    BEGIN

        /* As the entry point for this more than a single
           point we have to do the validation in here as
           well. Ex :
            Concurrent Program
            SFCB
        */
        IF NOT (fnd_installation.get_app_info(
            'WIP', g_status, g_industry, g_wip_schema)) THEN

            RAISE_APPLICATION_ERROR (-20000,
                                     'Unable to get session information.');

        END IF;
        if p_userid is null then
            -- This is an Error Condition
            x_userid :=  fnd_global.user_id ;
        else
            x_userid := p_userid ;
        end if;


        IF p_group_id IS NULL THEN
            select wip_indicators_temp_s.nextval into x_group_id
            from sys.dual ;
        ELSE
            x_group_id := p_group_id ;
        END IF;

        if p_applicationid is null then
            -- This is an Error Condition
            x_appl_id :=  fnd_global.prog_appl_id ;
        else
            x_appl_id := p_applicationid ;
        end if;


        g_userid := x_userid ;
        g_applicationid := x_appl_id ;


        IF p_date_from IS NULL THEN
            begin

                select trunc(min(calendar_date))
                into g_date_from
                  from bom_calendar_dates ;

            exception
                when no_data_found then
                    g_date_from := sysdate ;
            end ;

        ELSE
            g_date_from := p_date_from;

        END IF;

        IF p_date_to IS NULL THEN
            begin

                select trunc(max(calendar_date))
                into g_date_to
                  from bom_calendar_dates ;

            exception
                when no_data_found then
                    g_date_to := sysdate ;
            end ;

        ELSE
            g_date_to := p_date_to;
        END IF;

        x_date_from := g_date_from ;
        x_date_to := g_date_to ;

        -- Phase I: Calculate Standard Quantities
        x_phase := 'I';
        if g_debug = 1 then
            fnd_file.put_line(fnd_file.log, 'Before Stage 2 Phase I');
        end if ;
        ----dbms_output.put_line('Before Stage 2 Phase I');

        -- Calculate the Standard Quantities for the various departments
        Calculate_Std_Quantity(
            p_group_id => x_group_id,
            p_organization_id  => p_organization_id ,
            p_date_from => x_date_from,
            p_date_to => x_date_to ,
            p_department_id => p_department_id,
            p_indicator => WIP_EFFICIENCY);
        commit ;

        -- Phase II: Calculate Std Units
        x_phase := 'II' ;
        if g_debug = 1 then
            fnd_file.put_line(fnd_file.log, 'Before Stage 2 Phase II');
        end if ;
        ----dbms_output.put_line('Before Stage 2 Phase II');

        -- Calculate the standard units for the various resources in the
        -- departments
        Calculate_Std_Units(
            p_group_id => x_group_id,
            p_resource_id => p_resource_id,
            p_errnum => p_errnum,
            p_errmesg => p_errmesg,
            p_indicator => WIP_EFFICIENCY);
        commit;

        -- Phase III: Calculate efficiency applied units
        x_phase := 'III';
        if g_debug = 1 then
            fnd_file.put_line(fnd_file.log, 'Before Stage 2 Phase III');
        end if ;

        -- Calculate the Efficiency applied units.
        -- Technically this function should not being doing anything
        -- right now, because there are no rows in WIT with
        -- WIP_EFF_PHASE_THREE (see function for details).
        calc_Eff_Applied_Units(
            p_group_id => x_group_id,
            p_errnum => p_errnum,
            p_errmesg => p_errmesg);
        commit ;

        -- Phase IV: Calculate miscellaneous applied units.
        x_phase := 'IV';
        if g_debug = 1 then
            fnd_file.put_line(fnd_file.log, 'Before Stage 2 Phase IV');
        end if ;
        ----dbms_output.put_line('Before Stage 2 Phase IV');

        /*
        Richard's insight - the bug with efficiency
        calculation */

        -- Take into account the miscellaneous organizations
        Misc_Applied_Units(
            p_group_id => x_group_id,
            p_organization_id => p_organization_id,
            p_date_from => x_date_from,
            p_date_to => x_date_to,
            p_department_id => p_department_id,
            p_resource_id => p_resource_id,
            p_errnum => p_errnum,
            p_errmesg => p_errmesg );
        commit ;

        -- gather stats on table to allow index access
        If nvl(WIP_CALL_LOG,-1)  =1 then
        fnd_stats.gather_table_stats (g_wip_schema, 'WIP_INDICATORS_TEMP',
                                      cascade => true);
        End If;
        -- all successful
        p_errnum := 0 ;
        p_errmesg := '';
        return ;

    Exception

        WHEN OTHERS THEN

            if g_debug = 1 then
                fnd_file.put_line(fnd_file.log,'Failed in Stage 2 phase : '||x_phase);
                fnd_file.put_line(fnd_file.log, to_char(SQLCODE));
                fnd_file.put_line(fnd_file.log,SQLERRM);
            end if ;

            -- to make sure there is no garbage returned to SFCB,
            -- truncate wip_indicators_temp
            Delete_Temp_Info (p_group_id => x_group_id);

            ----dbms_output.put_line('Failed in Stage 2 phase : '||x_phase);
            ----dbms_output.put_line(SQLCODE);
            ----dbms_output.put_line(SQLERRM);
            p_errnum := -1 ;
            p_errmesg := 'Failed in Stage 2 Phase : '||x_phase||substr(SQLERRM,1,125);

            -- returns to populate_summary_table, so don't raise exception.

            commit ;
            return ;

    END Populate_Efficiency;


    /* Populate_Utilization
       Procedure to populate utilization information into the
       temp table, wip_indicators_temp
    */
    PROCEDURE Populate_Utilization (
            p_group_id          IN  NUMBER,
            p_organization_id   IN  NUMBER,
            p_date_from         IN  DATE,
            p_date_to           IN  DATE,
            p_department_id     IN  NUMBER,
            p_resource_id       IN  NUMBER,
            p_userid            IN  NUMBER,
            p_applicationid     IN  NUMBER,
            p_errnum            OUT NOCOPY NUMBER,
            p_errmesg           OUT NOCOPY VARCHAR2,
            p_sfcb              IN  NUMBER DEFAULT NULL )
    IS

        -- Cursor to get all
        CURSOR All_Orgs IS
        SELECT DISTINCT organization_id
          FROM mtl_parameters
	  WHERE process_enabled_flag <> 'Y';  -- Added to exclude process orgs after R12 uptake


        x_date_from   DATE;
        x_date_to     DATE;
        x_group_id    NUMBER;
        x_phase       VARCHAR2(10);
        x_userid  NUMBER;
        x_appl_id NUMBER;
        x_org_id  NUMBER  ;

    BEGIN
        x_org_id  := 0 ;
        /* As the entry point for this more than a single
           point we have to do the validation in here as
           well. Ex :
            Concurrent Program
            SFCB
        */
        IF NOT (fnd_installation.get_app_info(
            'WIP', g_status, g_industry, g_wip_schema)) THEN

            RAISE_APPLICATION_ERROR (-20000,
                                     'Unable to get session information.');

        END IF;
        if p_userid is null then
            -- This is an Error Condition
            x_userid :=  fnd_global.user_id ;
        else
            x_userid := p_userid ;
        end if;

        IF p_group_id IS NULL THEN
            select wip_indicators_temp_s.nextval into x_group_id
              from sys.dual ;
        ELSE
            x_group_id := p_group_id ;
        END IF;

        if p_applicationid is null then
            -- This is an Error Condition
            x_appl_id :=  fnd_global.prog_appl_id ;
        else
            x_appl_id := p_applicationid ;
        end if;


        g_userid := x_userid ;
        g_applicationid := x_appl_id ;

        -- Get the UOM code from the profile

        g_uom_code := fnd_profile.value('BOM:HOUR_UOM_CODE');
        select uom_class
        into g_uom_class
          from mtl_units_of_measure
          where uom_code = g_uom_code;

        --dbms_output.put_line(g_uom_code);

        -- Set up the date ranges if needed
        /* For performance reasons should be just use the
          minimum and maximum date from efficiency */

        IF p_date_from IS NULL THEN
            begin

                select trunc(min(calendar_date))
                into g_date_from
                  from bom_calendar_dates ;

            exception
                when no_data_found then
                    g_date_from := sysdate ;
            end ;

        ELSE
            g_date_from := p_date_from;
        END IF;

        IF p_date_to IS NULL THEN
            begin

                select trunc(max(calendar_date))
                into g_date_to
                  from bom_calendar_dates ;

            exception
                when no_data_found then
                    g_date_to := sysdate ;
            end ;

        ELSE
            g_date_to := p_date_to;
        END IF;

        x_date_from := g_date_from ;
        x_date_to := g_date_to ;

        --dbms_output.put_line(x_date_from);
        --dbms_output.put_line(x_date_to);

        --   For each one of the organizations

        -- Phase I: calculate the resource availability for each org
        x_phase := 'I';
        if g_debug = 1 then
            fnd_file.put_line(fnd_file.log, 'Before Stage 3 Phase I');
        end if ;
        --dbms_output.put_line('Before Stage 3 Phase I');

        -- Populate the fresh resource availability data into the
        -- mrp_net_resource_avail table.
        -- Calculate_Resource_Avail will call an MRP API to do this job
        -- per org.
        -- Note that in calc_resource_avail, we pass in NULL as the
        -- argument to the arg_simulation_set paramter to the MRP API.
        -- This is important because in the various joins to MNRA in this
        -- program, it seems the simulation_set = NULL filter is placed in
        -- some and not in others. However, the simulation set will be the
        -- same as the value of the arg_simulation_set passed into the MRP
        -- API (which is NULL). Therefore, the simulation_set = NULL filter
        -- is relevant across the board in all queries of this program.
        --
        -- This is not required for all the organizations,
        -- if just one organization is passed.

        IF (p_organization_id is null ) THEN

            FOR Org_Rec IN All_Orgs LOOP

                x_org_id := Org_Rec.organization_id ;

                Calculate_Resource_Avail(
                            p_organization_id => x_org_id,
                            p_date_from         => trunc (x_date_from),
                            p_date_to           => trunc (x_date_to),
                            p_department_id     => p_department_id,
                            p_resource_id       => p_resource_id,
                            p_errnum            => p_errnum,
                            p_errmesg           => p_errmesg);

            END LOOP ;

        ELSE
                Calculate_Resource_Avail(
                            p_organization_id => p_organization_id,
                            p_date_from         => trunc (x_date_from),
                            p_date_to           => trunc (x_date_to),
                            p_department_id     => p_department_id,
                            p_resource_id       => p_resource_id,
                            p_errnum            => p_errnum,
                            p_errmesg           => p_errmesg);
        END IF ;

        -- Phase II: Pre-aggregate resource availability info
        -- for quick access in later SQLs since MNRA is a big table.
        x_phase := 'II';
        if g_debug = 1 then
            fnd_file.put_line(fnd_file.log, 'Before Stage 3 Phase II');
        end if ;
        --dbms_output.put_line('Before Stage 3 Phase II');

        -- Pre-aggregate all the information needed from
        -- mrp_net_resource_avail and group the data by the attributes
        -- needed by the rest of the program. MNRA is a large table, so
        -- do this once, and then use this temp table to get values from.
        -- We want to pick only the rows that are referenced by the
        -- simulation_set = NULL condition, because this is what we specified
        -- the simulation_set to be when calling the MRP API.
        -- What this also means is that (shift_date, resource_id,
        -- department_id, organization_id, simulation_set) form a primary
        -- key for wip_bis_mnra_temp.
      if nvl(WIP_CALL_LOG,-1) =1 then -- Bug 3624837 If clause is added as Else code alone can hit performace for Capture Request
        INSERT INTO wip_bis_mnra_temp (
            shift_date,
            resource_id,
            department_id,
            organization_id,
            --simulation_set,
            available_hours
        )
        SELECT
            trunc (shift_date),
            resource_id,
            department_id,
            organization_id,
            --simulation_set, -- Not used after that --3779182
            --sum(((to_time-from_time)/3600)*capacity_units) --BUG - 3581581
            -- sum(((decode(sign(to_time - from_time),
            --                               -1, ( 86400 - from_time ) + to_time,
            --                                1, ( to_time - from_time ) ,
            --                                0 ))/3600)*capacity_units)
            decode(sum(shift_num),
                         0, nvl(sum(capacity_units)*24,0),
			          nvl(sum(((decode(sign(to_time - from_time),
                                           -1, ( 86400 - from_time ) + to_time,
                                            1, ( to_time - from_time ) ,
                                            0 ))/3600)*capacity_units),0))
          FROM mrp_net_resource_avail
          WHERE simulation_set IS NULL
          and  shift_date BETWEEN x_date_from AND (x_date_to + 0.99999)
          GROUP BY
            trunc (shift_date),
            resource_id,
            department_id,
            organization_id;--,
            --simulation_set

        commit;
      Else -- This code will work only for discrete Workstation
                INSERT INTO wip_bis_mnra_temp (
                    shift_date,
                    resource_id,
                    department_id,
                    organization_id,
                  --  simulation_set,
                    available_hours
                )
                SELECT
                    trunc (shift_date),
                    resource_id,
                    department_id,
                    organization_id,
                  --  simulation_set,
                    --sum(((to_time-from_time)/3600)*capacity_units) --BUG - 3581581
                    -- sum(((decode(sign(to_time - from_time),
                    --                               -1, ( 86400 - from_time ) + to_time,
                    --                                1, ( to_time - from_time ) ,
                    --                                0 ))/3600)*capacity_units)
                    decode(sum(shift_num),
                                 0, nvl(sum(capacity_units)*24,0),
                                          nvl(sum(((decode(sign(to_time - from_time),
                                                   -1, ( 86400 - from_time ) + to_time,
                                                    1, ( to_time - from_time ) ,
                                                    0 ))/3600)*capacity_units),0))
                  FROM mrp_net_resource_avail mrp_outer
                  WHERE simulation_set IS NULL
                   and mrp_outer.shift_date BETWEEN x_date_from AND (x_date_to + 0.99999) --3779182
                   AND mrp_outer.resource_id = nvl(p_resource_id, mrp_outer.resource_id)
                   AND mrp_outer.department_id = nvl(p_department_id, mrp_outer.department_id)
                   AND mrp_outer.organization_id = nvl(p_organization_id, mrp_outer.organization_id)
                  and not exists
                               ( select null
                                 from wip_bis_mnra_temp mrp_inner
                                  where mrp_outer.shift_date between trunc (mrp_inner.shift_date) and( trunc (mrp_inner.shift_date)+ 0.99999)
                                     and mrp_outer.resource_id= mrp_inner.resource_id
                                     and mrp_outer.department_id= mrp_inner.department_id
                                     and mrp_outer.organization_id = mrp_inner.organization_id
                                )
                  GROUP BY
                    trunc (shift_date),
                    resource_id,
                    department_id,
                    organization_id; --,
                  --  simulation_set

                commit;
      end if;
        -- Phase III: Insert all the utilization data into the temp table.
        x_phase := 'III';
        if g_debug = 1 then
            fnd_file.put_line(fnd_file.log, 'Before Stage 3 Phase III');
        end if ;
        --dbms_output.put_line('Before Stage 3 Phase III');

        -- Insert all the data into the wip_indicators_temp table.
        -- This requires finding all the relevant records in
        -- in the OLTP tables and the available_units from the
        -- wip_bis_mnra_temp table. Null available_units are set to 0 in
        -- tune with the previous logic of the program.
        --
        -- This SQL now merges two old SQLs. The first used to insert to
        -- wip_indicators_temp and the second used to update EVERY row
        -- to have a process_phase of WIP_UTZ_PHASE_TWO and available_units
        -- from MNRA. Because of the merging, the reference to
        -- WIP_UTZ_PHASE_ONE in the insert step is now gone.
        --
        -- Note the that the inner group by makes org, dept, resource and
        -- and transaction_date a primary key for the UTILIZATION data.
        -- This is impt. when considering the logic in Move_Utz_info.
        INSERT INTO wip_indicators_temp(
            group_id,
            organization_id,
            department_id,
            department_code,
            resource_id,
            resource_code,
            wip_entity_id,-- added for bug 3604065
            operation_seq_num, -- bug 3662056
            applied_units_utz,
            available_units,
            transaction_date,
            indicator_type,
            process_phase,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by,
            program_application_id)
        SELECT
            x_group_id group_id,
            utz_rows.organization_id,
            utz_rows.department_id,
            utz_rows.department_code,
            utz_rows.resource_id,
            utz_rows.resource_code,
            utz_rows.wip_entity_id, -- Bug 3604065
            utz_rows.operation_seq_num, --bug 3662056
            utz_rows.applied_units_utz,
            nvl (mnra_temp.available_hours, 0) available_units,
            utz_rows.transaction_date,
            WIP_UTILIZATION indicator_type,
            WIP_UTZ_PHASE_TWO process_phase,
            sysdate last_update_date,
            g_userid last_updated_by,
            SYSDATE creation_date,
            g_userid created_by,
            g_applicationid program_application_id
        FROM wip_bis_mnra_temp mnra_temp,
            (SELECT
                wt.organization_id organization_id,
                bd.department_id department_id,
                bd.department_code department_code,
                wt.resource_id resource_id,
                br.resource_code resource_code,
                wt.wip_entity_id wip_entity_id, -- Bug 3604065
                wt.operation_seq_num operation_seq_num, --bug 3662056
                trunc(wt.transaction_date) transaction_date,
                sum(inv_convert.inv_um_convert(0,NULL,wt.primary_quantity,
                                               wt.primary_uom,g_uom_code,
                                               NULL,NULL)) applied_units_utz
              FROM
                bom_resources br,
                bom_departments bd,
                bom_department_resources bdr,
                wip_transactions wt,
                mtl_units_of_measure muom
              WHERE
                    wt.transaction_date BETWEEN x_date_from AND
                                                (x_date_to + 0.99999)
                AND wt.resource_id = nvl(p_resource_id, wt.resource_id)
                AND wt.department_id = nvl(p_department_id, wt.department_id)
                AND wt.organization_id = nvl(p_organization_id,
                                             wt.organization_id)
                AND wt.transaction_type in (1, 3)
                AND bdr.resource_id = wt.resource_id
                AND bdr.department_id = wt.department_id
                AND bd.department_id = nvl(bdr.share_from_dept_id,
                                           bdr.department_id)
                AND bd.organization_id = wt.organization_id
                AND br.resource_id = wt.resource_id
                AND br.unit_of_measure  = muom.uom_code
                AND muom.uom_class = g_uom_class
                AND br.organization_id = wt.organization_id
                GROUP BY
                   wt.organization_id,
                   bd.department_id,
                   bd.department_code,
                   wt.resource_id,
                   br.resource_code,
                   wt.wip_entity_id,-- Bug 3604065
                   wt.operation_seq_num, --bug 3662056
                   trunc(wt.transaction_date)) utz_rows
            WHERE mnra_temp.organization_id (+) = utz_rows.organization_id
              AND mnra_temp.department_id (+) = utz_rows.department_id
              AND mnra_temp.resource_id (+) = utz_rows.resource_id
              AND mnra_temp.shift_date (+) = utz_rows.transaction_date;

        COMMIT ;

        -- gather stats on table to allow index access
        If nvl(WIP_CALL_LOG,-1) =1 then
        fnd_stats.gather_table_stats (g_wip_schema, 'WIP_INDICATORS_TEMP',
                                      cascade => true);
        End If;
        -- Phase IV: SFCB
        x_phase := 'IV';
        if g_debug = 1 then
            fnd_file.put_line(fnd_file.log, 'Before Stage 3 Phase IV');
        end if ;
        --dbms_output.put_line('Before Stage 3 Phase IV');
       IF (p_sfcb IS NOT NULL) THEN

           Move_SFCB_Utz_Info(
                        p_group_id => x_group_id,
                        p_organization_id => p_organization_id,
                        p_date_from =>x_date_from,
                        p_date_to => x_date_to,
                        p_department_id => p_department_id,
                        p_resource_id => p_resource_id,
                        p_userid  => x_userid,  -- this parameter is not really needed
                        p_applicationid => x_appl_id,  -- this parameter is not really needed
                        p_errnum => p_errnum,
                        p_errmesg => p_errmesg ) ;

            IF (p_errnum <0) THEN
                raise collection_stage_failed;
            END IF ;

        END IF ;

        If nvl(WIP_CALL_LOG,-1) <> 1 then
        -- Due to performance reason . this code will work for only discrete workstation .
        --For Capture Production Indicator Request we already have these fix.
         -- Addtion to remove available hours from other than min(wip_entity_id)  on same day    bug -3624837
        update wip_indicators_temp wbpi
        set  wbpi.available_units = 0
        where wbpi.available_units is not null
        and   wbpi.indicator_type=WIP_UTILIZATION
        and   wbpi.process_phase= WIP_UTZ_PHASE_TWO
        and   wbpi.group_id=x_group_id
        and  wbpi.wip_entity_id <>
                (select min(wit.wip_entity_id)
                        from wip_indicators_temp wit
                        where   trunc(wit.transaction_date)  =trunc(wbpi.transaction_date)
                        and 	wbpi.resource_id = wit.resource_id
                        and	wbpi.department_id = wit.department_id
                        and 	wbpi.organization_id = wit.organization_id
                         and     wbpi.group_id=wit.group_id
                        and     wit.indicator_type=WIP_UTILIZATION
                        and     wit.process_phase= WIP_UTZ_PHASE_TWO);

          --- Fix when same resource is used for more than one step    bug -3624837
        update wip_indicators_temp wbpi
        set   wbpi.available_units = 0
        where wbpi.available_units is not null
        and   wbpi.indicator_type=WIP_UTILIZATION
        and   wbpi.process_phase= WIP_UTZ_PHASE_TWO
        and   wbpi.group_id=x_group_id
        and  wbpi.operation_seq_num <>
                (select min(wit.operation_seq_num)
                        from wip_indicators_temp wit
                        where   trunc(wit.transaction_date)  =trunc(wbpi.transaction_date)
                        and 	wbpi.resource_id = wit.resource_id
                        and	wbpi.department_id = wit.department_id
                        and 	wbpi.organization_id = wit.organization_id
                        and 	wbpi.wip_entity_id = wit.wip_entity_id
                        and     wbpi.group_id=wit.group_id
                        and     wit.indicator_type=WIP_UTILIZATION
                        and     wit.process_phase= WIP_UTZ_PHASE_TWO);

        Commit;
      end if;
        p_errnum := 0;
        p_errmesg := '';
        RETURN ;


    EXCEPTION
        WHEN OTHERS THEN

            if g_debug = 1 then
                if x_org_id <> 0 then
                    fnd_file.put_line(fnd_file.log,
                                      'Failed in Stage 3 phase : '||x_phase ||
                                      ' for Organization Id : ' ||
                                      to_char(x_org_id) );

                    --dbms_output.put_line('Failed in Stage 3 phase : '||
                    --                     x_phase ||
                    --                     ' for Organization Id : ' ||
                    --                     to_char(x_org_id) );
                else
                    fnd_file.put_line(fnd_file.log,
                                      'Failed in Stage 3 phase : '||x_phase);
                end if;
                fnd_file.put_line(fnd_file.log, SQLCODE);
                fnd_file.put_line(fnd_file.log,SQLERRM);
            end if ;

            --dbms_output.put_line('Failed in Stage 3 phase : '||x_phase);
            --dbms_output.put_line(SQLCODE);
            --dbms_output.put_line(SQLERRM);

            p_errnum := -1 ;

            if x_org_id <> 0 then
                p_errmesg := 'Failed in Stage 3 Phase : '||x_phase||
                             ' for Organization : '
                             || to_char(x_org_id) || substr(SQLERRM,1,105);
            else
                p_errmesg := 'Failed in Stage 3 Phase : '||x_phase||
                             substr(SQLERRM,1,125);
            end if ;

            -- to make sure there is no garbage returned to SFCB,
            -- truncate wip_indicators_temp
            Delete_Temp_Info (p_group_id => x_group_id);

            -- returns to populate_summary_table, so don't raise exception.

            commit ;
            return ;

    END Populate_Utilization;


    /*Populate_Yield

        Calculates the Yield for the report.
        We have included the resource_id as a new paramater - just for future
        use, if we decided to get the yield for the resource as well
    */
    PROCEDURE Populate_Yield(
                p_group_id          IN  NUMBER,
                p_organization_id   IN  NUMBER,
                p_date_from         IN  DATE,
                p_date_to           IN  DATE,
                p_department_id     IN  NUMBER,
                p_resource_id       IN  NUMBER,
                p_userid            IN  NUMBER,
                p_applicationid     IN  NUMBER,
                p_errnum            OUT NOCOPY NUMBER,
                p_errmesg           OUT NOCOPY VARCHAR2)

    IS
        x_group_id NUMBER;
        x_phase VARCHAR2(10);
        x_date_from DATE;
        x_date_to   DATE;
        x_userid    NUMBER;
        x_appl_id   NUMBER;
    BEGIN

        /* As the entry point for this more than a single
           point we have to do the validation in here as
           well. Ex :
                Concurrent Program
                SFCB
        */
        IF NOT (fnd_installation.get_app_info(
            'WIP', g_status, g_industry, g_wip_schema)) THEN

            RAISE_APPLICATION_ERROR (-20000,
                                     'Unable to get session information.');

        END IF;
        if p_userid is null then
            -- This is an Error Condition
            x_userid :=  fnd_global.user_id ;
        else
            x_userid := p_userid ;
        end if;


        IF p_group_id IS NULL THEN
            select wip_indicators_temp_s.nextval into x_group_id
            from sys.dual ;
        ELSE
            x_group_id := p_group_id ;
        END IF;

        if p_applicationid is null then
            -- This is an Error Condition
            x_appl_id :=  fnd_global.prog_appl_id ;
        else
            x_appl_id := p_applicationid ;
        end if;

        g_userid := x_userid ;
        g_applicationid := x_appl_id ;

        IF p_date_from IS NULL THEN
            begin

                select trunc(min(calendar_date))
                into g_date_from
                from bom_calendar_dates ;

           exception
                when no_data_found then
                g_date_from := sysdate ;
        end ;

        ELSE
            g_date_from := p_date_from;

        END IF;

        IF p_date_to IS NULL THEN
            begin

                select trunc(max(calendar_date))
                into g_date_to
                from bom_calendar_dates ;

            exception
                when no_data_found then
                g_date_to := sysdate ;
            end ;

        ELSE
            g_date_to := p_date_to;
        END IF;

        x_date_from := g_date_from ;
        x_date_to := g_date_to ;


        -- Phase I: Calculate the Total Quantities Produced
        -- by the various departments
        x_phase := 'I';
        if g_debug = 1 then
            fnd_file.put_line(fnd_file.log, 'Before Stage 4 Phase I');
        end if ;
        ----dbms_output.put_line('Before Stage 4 Phase I');

        Calculate_Total_Quantity(
            p_group_id => x_group_id,
            p_organization_id  => p_organization_id ,
            p_date_from => trunc (x_date_from),
            p_date_to => trunc (x_date_to) ,
            p_department_id => p_department_id);

        commit ;

        -- Phase II: Calculate the Scrap Quantity by the various departments
        x_phase := 'II';
        if g_debug = 1 then
            fnd_file.put_line(fnd_file.log, 'Before Stage 4 Phase II');
        end if ;
        ----dbms_output.put_line('Before Stage 4 Phase II');

        Calculate_Scrap_Quantity(
            p_group_id => x_group_id,
            p_organization_id => p_organization_id,
            p_date_from => trunc (x_date_from),
            p_date_to => trunc (x_date_to),
            p_errnum => p_errnum,
            p_errmesg => p_errmesg);
        commit ;

        -- Error in the called program
        if(p_errnum <0 )then
            return ;
        end if ;

        -- Phase III: Incorporate the resource information for the yield
        x_phase := 'III';
        if g_debug = 1 then
            fnd_file.put_line(fnd_file.log, 'Before Stage 4 Phase III');
        end if ;
        ----dbms_output.put_line('Before Stage 4 Phase III');

        Resource_Yield( p_group_id => x_group_id,
            p_errnum => p_errnum,
            p_errmesg => p_errmesg );
        commit ;

        -- gather stats on table to allow index access
        If nvl(WIP_CALL_LOG,-1) =1 then
        fnd_stats.gather_table_stats (g_wip_schema, 'WIP_INDICATORS_TEMP',
                                      cascade => true);
        End If;
        p_errnum := 0;
        p_errmesg := 0;
        return ;

    Exception

        when others then

            if g_debug = 1 then
                fnd_file.put_line(fnd_file.log,'Failed in Stage 4 phase : '||x_phase);
                fnd_file.put_line(fnd_file.log, SQLCODE);
                fnd_file.put_line(fnd_file.log,SQLERRM);
            end if ;
            ----dbms_output.put_line('Failed in Stage 4 phase : '||x_phase);
            ----dbms_output.put_line(SQLCODE);
            ----dbms_output.put_line(SQLERRM);
            p_errnum := -1 ;
            p_errmesg := 'Failed in Stage 4 Phase : '||x_phase||substr(SQLERRM,1,125);

            -- to make sure there is no garbage returned to SFCB,
            -- truncate wip_indicators_temp
            Delete_Temp_Info (p_group_id => x_group_id);

            -- returns to populate_summary_table, so don't raise exception.

            commit ;
            return ;


    END Populate_Yield;

    /* Calculate_Std_Quantity

    Calculate the Standard Quantities used by the various departments
    in the organization within the date range that is specified.
    However if the date range is not specified then we consider the
    whole time horizon. If no department is specified then we get all
    the departments in the organization. However if the department is
    specified then we get only corresponding department information
    */

    PROCEDURE Calculate_Std_Quantity(
                p_group_id          IN  NUMBER,
                p_organization_id   IN  NUMBER,
                p_date_from         IN  DATE,
                p_date_to           IN  DATE,
                p_department_id     IN  NUMBER,
                p_indicator         IN  NUMBER )
    IS

        proc_name VARCHAR2 (40);

    BEGIN
        proc_name := 'Calculate_Std_Quantity';
        insert into wip_indicators_temp(
            group_id,
            organization_id,
            department_id,
            department_code,
            wip_entity_id,
            operation_seq_num,
            indicator_type,
            process_phase,
            transaction_date,
            applied_units_prd,
            standard_units,
            standard_quantity,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by,
            program_application_id)
        select
            p_group_id,
            wmt.organization_id,
            wo.department_id,
            bd.department_code,
            wmt.wip_entity_id,
            wo.operation_seq_num,
            p_indicator,
            WIP_EFF_PHASE_ONE,   /* First Process Phase */
            trunc(wmt.transaction_date),
            null,
            null,
            sum( decode ( sign(wmt.FM_OPERATION_SEQ_NUM-wmt.TO_OPERATION_SEQ_NUM),
            0, -- Within the same operation
            decode( wmt.FM_INTRAOPERATION_STEP_TYPE,
                   1,                   -- From Queue
                   decode(  wmt.TO_INTRAOPERATION_STEP_TYPE,
                        2 , 0,
                        1, 0, -- this is not possible but still
                        (wmt.primary_quantity)
                     ),
                   2,               -- From Run
                   decode(  wmt.TO_INTRAOPERATION_STEP_TYPE,
                        1, 0,
                        2, 0, -- this is not possible but still
                        (wmt.primary_quantity)
                      ),
                   decode(  wmt.TO_INTRAOPERATION_STEP_TYPE,
                        3, 0,
                        4, 0,
                        5, 0,
                        (-1*wmt.primary_quantity)
                      )
                   ),
                -1, -- Move in the positive direction
                decode(  wo.operation_seq_num,
                     wmt.FM_OPERATION_SEQ_NUM, -- Starting Operation
                     decode( wmt.FM_INTRAOPERATION_STEP_TYPE,
                         3, 0,
                         4, 0,
                         5, 0,
                         (wmt.primary_quantity)
                        ),
                     wmt.TO_OPERATION_SEQ_NUM, -- Final Operation
                     decode( wmt.TO_INTRAOPERATION_STEP_TYPE,
                         1, 0,
                         2, 0,
                         decode( wo.count_point_type,
                             3, 0,
                                 wmt.primary_quantity)
                       ),
                     decode( wo.count_point_type,
                         3, 0,
                         (wmt.primary_quantity)
                        )
                   ),
                 1, -- Move in the negative direction
                 decode(  wo.operation_seq_num,
                      wmt.FM_OPERATION_SEQ_NUM, -- Starting Operation
                      decode( wmt.FM_INTRAOPERATION_STEP_TYPE,
                          1, 0,
                          2, 0,
                          3, 0,
                          (-1*wmt.primary_quantity)
                         ),
                      wmt.TO_OPERATION_SEQ_NUM, -- Final Operation
                      decode( wmt.TO_INTRAOPERATION_STEP_TYPE,
                          3, 0,
                          4, 0,
                          5, 0,
                          decode( wo.count_point_type,
                              3, 0,
                              -1*wmt.primary_quantity)
                         ),
                      decode( wo.count_point_type,
                          3, 0,
                         (-1*wmt.primary_quantity)
                        )
                     )
               ) ) "Quantity",
            sysdate,
            g_userid,
            SYSDATE,
            g_userid,
            g_applicationid
        from
            wip_move_transactions wmt,
            wip_operations wo,
            bom_departments bd
        where
            trunc(wmt.transaction_date) between trunc(nvl(p_date_from,wmt.transaction_date))
        and trunc(nvl(p_date_to,wmt.transaction_date))
        and wo.operation_seq_num <= decode(sign(wmt.FM_OPERATION_SEQ_NUM-wmt.TO_OPERATION_SEQ_NUM),
                        -1,wmt.TO_OPERATION_SEQ_NUM, 1, wmt.FM_OPERATION_SEQ_NUM,
                        wmt.FM_OPERATION_SEQ_NUM)
        and wo.operation_seq_num >= decode(sign(wmt.FM_OPERATION_SEQ_NUM-wmt.TO_OPERATION_SEQ_NUM),
                        -1,wmt.FM_OPERATION_SEQ_NUM, 1, wmt.TO_OPERATION_SEQ_NUM,
                        wmt.FM_OPERATION_SEQ_NUM)
        and wmt.organization_id = wo.organization_id
        and wo.department_id = bd.department_id
        and wo.wip_entity_id = wmt.wip_entity_id
        and wo.organization_id = bd.organization_id
        and wo.department_id = nvl(p_department_id, wo.department_id)
        and bd.organization_id = nvl(p_organization_id, bd.organization_id)
        group by
               wmt.organization_id,
               wo.department_id,
               bd.department_code,
               wmt.wip_entity_id,
               wo.operation_seq_num,
               p_indicator,
               1,
               trunc(wmt.transaction_date),
               null,
               null,
               sysdate,
               g_userid,
               SYSDATE,
               g_userid,
               g_applicationid
        having sum( decode ( sign(wmt.FM_OPERATION_SEQ_NUM-wmt.TO_OPERATION_SEQ_NUM),
               0, -- Within the same operation
               decode( wmt.FM_INTRAOPERATION_STEP_TYPE,
                   1,                   -- From Queue
                   decode(  wmt.TO_INTRAOPERATION_STEP_TYPE,
                        2 , 0,
                        1, 0, -- this is not possible but still
                        (wmt.primary_quantity)
                     ),
                   2,               -- From Run
                   decode(  wmt.TO_INTRAOPERATION_STEP_TYPE,
                        1, 0,
                        2, 0, -- this is not possible but still
                        (wmt.primary_quantity)
                      ),
                   decode(  wmt.TO_INTRAOPERATION_STEP_TYPE,
                        3, 0,
                        4, 0,
                        5, 0,
                        (-1*wmt.primary_quantity)
                      )
                   ),
                -1, -- Move in the positive direction
                decode(  wo.operation_seq_num,
                     wmt.FM_OPERATION_SEQ_NUM, -- Starting Operation
                     decode( wmt.FM_INTRAOPERATION_STEP_TYPE,
                         3, 0,
                         4, 0,
                         5, 0,
                         (wmt.primary_quantity)
                        ),
                     wmt.TO_OPERATION_SEQ_NUM, -- Final Operation
                     decode( wmt.TO_INTRAOPERATION_STEP_TYPE,
                         1, 0,
                         2, 0,
                         decode( wo.count_point_type,
                             3, 0,
                             wmt.primary_quantity)
                       ),
                     decode( wo.count_point_type,
                         3, 0,
                         (wmt.primary_quantity)
                        )
                   ),
                 1, -- Move in the negative direction
                 decode(  wo.operation_seq_num,
                      wmt.FM_OPERATION_SEQ_NUM, -- Starting Operation
                      decode( wmt.FM_INTRAOPERATION_STEP_TYPE,
                          1, 0,
                          2, 0,
                          3, 0,
                          (-1*wmt.primary_quantity)
                         ),
                      wmt.TO_OPERATION_SEQ_NUM, -- Final Operation
                      decode( wmt.TO_INTRAOPERATION_STEP_TYPE,
                          3, 0,
                          4, 0,
                          5, 0,
                          decode( wo.count_point_type,
                              3, 0,
                              -1*wmt.primary_quantity)
                         ),
                      decode( wo.count_point_type,
                          3, 0,
                         (-1*wmt.primary_quantity)
                        )
                     )
               ) ) <> 0 ;

        commit;

    EXCEPTION

        WHEN OTHERS
        THEN
            FND_FILE.PUT_LINE (fnd_file.log, proc_name || ':' || sqlerrm);
            RAISE; -- propagate to calling function

    END Calculate_Std_Quantity;



    /* This gets the information regarding the resource in a
       a particular department - however if a particular resource
       is specified then we get the information regarding only that
       resource.

        - This has been modified to take into consideration for both
          lot/Item based resources - fixed for Oabis 11.1 - required
          introducing a new column basis_type. The sequence of steps
          are :

            1. Calculate the Standard_Quantities for each
               wip_entity_id, operation_seq_num, department,
               resource, transaction_date.

            2. Delete the original rows + lot based resource
               transactions except for the first transaction
               information.

            The summarization and steps across the various combinations
            have been commented out long back and are being removed from the
            file. (digupta 10/02/03).

    */

    PROCEDURE Calculate_Std_Units(
                p_group_id      IN  NUMBER,
                p_resource_id   IN  NUMBER,
                p_errnum        OUT NOCOPY NUMBER,
                p_errmesg       OUT NOCOPY VARCHAR2,
                p_indicator     IN NUMBER )
    IS
        x_step NUMBER ;
        proc_name VARCHAR2 (40) ;

    BEGIN
        x_step := 0 ;
        proc_name  := 'Calculate_Std_Units';
        -- Get the default UOM Class
        g_uom_code := fnd_profile.value('BOM:HOUR_UOM_CODE');
        select uom_class
        into g_uom_class
        from mtl_units_of_measure
        where uom_code = g_uom_code;

        -- Step 1 :  Calculate the Std. Qty for each
        -- wip_entity_id, OP Seq, Dept, Res, Txn Date
        -- and insert into WIT
        x_step := 1;
        if g_debug = 1 then
            fnd_file.put_line(fnd_file.log,
                              'Before Stage 2 Phase II Step : ' || x_step);
        end if ;
        ----dbms_output.put_line('Before Stage 2 Phase II Step : ' || x_step);

        /* Modify this to include the changes required for
        the calculation for the owning department
        */
        /*???? has this already been done? digupta - 10/14/03*/
        insert into wip_indicators_temp(
            group_id,
            organization_id,
            department_id,
            department_code,
            standard_quantity,
            resource_id,
            resource_code,
            wip_entity_id,
            operation_seq_num,
            resource_basis,
            indicator_type,
            process_phase,
            transaction_date,
            standard_units,
            applied_units_prd,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by,
            program_application_id )
       select
            wit.group_id,
            wit.organization_id,
            decode(wit.indicator_type,
                WIP_EFFICIENCY, wit.department_id,
                WIP_PRODUCTIVITY,
                nvl(bdr.share_from_dept_id,wit.department_id)
                  ),
            decode(wit.indicator_type,
                WIP_EFFICIENCY, wit.department_code,
                WIP_PRODUCTIVITY,
                nvl(bd.department_code, wit.department_code)),
            wit.standard_quantity,
            wor.resource_id,
            br.resource_code,
            wit.wip_entity_id,
            wit.operation_seq_num,
            wor.basis_type,
            wit.indicator_type,
            WIP_EFF_PHASE_TWO,  /* This is second stage */
            transaction_date,  -- already trunc'ed
            inv_convert.inv_um_convert(0,
                                       NULL,
                                       decode(wor.basis_type,
                                       1, (wit.standard_quantity*
                                           wor.usage_rate_or_amount),
                                       2, (wit.standard_quantity)),
                                       wor.uom_code,
                                       g_uom_code,
                                       NULL,
                                       NULL),
            null,
            wit.last_update_date,
            wit.last_updated_by,
            wit.creation_date,
            wit.created_by,
            wit.program_application_id
        from wip_indicators_temp wit,
            bom_resources br,
            bom_departments bd,
            bom_department_resources bdr,
            wip_operation_resources wor,
            mtl_units_of_measure muom
        where
             wor.wip_entity_id = wit.wip_entity_id
        and  wor.operation_seq_num = wit.operation_seq_num
        and  wit.indicator_type = p_indicator
        and  wor.resource_id = nvl(p_resource_id, wor.resource_id)
        and  br.organization_id = wor.organization_id
        and  br.resource_id = wor.resource_id
        and  bdr.resource_id = br.resource_id
        and  bdr.department_id = wit.department_id
        and  bd.department_id (+) = bdr.share_from_dept_id
        and  wor.uom_code = muom.uom_code
        and  muom.uom_class = g_uom_class;

        commit ;

        -- gather stats on table to allow index access
        If nvl(WIP_CALL_LOG,-1) =1 then
        fnd_stats.gather_table_stats (g_wip_schema, 'WIP_INDICATORS_TEMP',
                                      cascade => true);
        End If;
        --  Step2 :   Delete all the original rows (i.e. the ones
        --        without the resource information that were
        --        generated in the WIP_EFF_PHASE_ONE)
        --        and the lot-based information for a job except
        --        for the first transaction across this particular
        --        resource.
        x_step := 2;
        if g_debug = 1 then
            fnd_file.put_line(fnd_file.log, 'Before Stage 2 Phase II Step : ' || x_step);
        end if ;
        ----dbms_output.put_line('Before Stage 2 Phase II Step : ' || x_step);

        delete from wip_indicators_temp wit
            where wit.indicator_type = p_indicator
            and  (       (  wit.process_phase = WIP_EFF_PHASE_ONE )
                    or   (  wit.process_phase = WIP_EFF_PHASE_TWO
                    and wit.resource_basis = 2
                    and wit.transaction_date >
                    (
                        select min(transaction_date)
                        from wip_indicators_temp wit2
                        where wit2.wip_entity_id = wit.wip_entity_id
                        and   wit2.indicator_type = wit.indicator_type
                        and   wit2.operation_seq_num = wit.operation_seq_num
                        and   wit2.resource_id = wit.resource_id
                        and   wit2.resource_basis = 2)
                   )
          );
        commit ;

        p_errnum := 0;
        p_errmesg := '';

        return ;

    EXCEPTION

        WHEN OTHERS
        THEN
            FND_FILE.PUT_LINE (fnd_file.log, proc_name || ':' || sqlerrm);
            p_errnum := -1;
            p_errmesg := (proc_name || ':' || sqlerrm);
            RAISE; -- propagate to calling function


    End Calculate_Std_Units;


    /* Calculate the efficiency applied units.
       As far as we can tell, this function now does nothing because
       when it is called, there is no row in WIT with
       WIP_EFF_PHASE_THREE
    */

    PROCEDURE Calc_Eff_Applied_Units (
                 p_errmesg  OUT NOCOPY VARCHAR2,
                 p_errnum   OUT NOCOPY NUMBER,
                 p_group_id IN  NUMBER)
    IS
        proc_name VARCHAR2 (40);

    BEGIN
        proc_name := 'Calc_Eff_Applied_Units';
        g_uom_code  := fnd_profile.value('BOM:HOUR_UOM_CODE');
        select uom_class
        into g_uom_class
        from mtl_units_of_measure
        where uom_code = g_uom_code;

        --- ??? Can this ever happen? The SQL that set the process phase
        --- to WIP_EFF_PHASE_THREE in calculate_std_units
        --- was stubbed out back in version 115.32. Please check. ???

        -- Go to wip_transactions to get the actual units applied
        -- consider only resource and oustide processing charges
      /*  update wip_indicators_temp wit
        set APPLIED_UNITS_PRD = (
            select nvl(wt.primary_quantity,0)
            from    wip_transactions wt
            where   wt.organization_id = wit.organization_id
            and wt.transaction_date BETWEEN trunc(wit.transaction_date)
            and trunc (wit.transaction_date) + 0.999999
            and wt.transaction_type in (1, 3)
            and wt.operation_seq_num = wit.operation_seq_num
            AND wt.wip_entity_id = wit.wip_entity_id
            and wt.department_id = wit.department_id
            and wt.resource_id = wit.resource_id
            )
        where wit.indicator_type = WIP_EFFICIENCY
        AND wit.process_phase = WIP_EFF_PHASE_THREE  ;
    */
        p_errnum := 0;
        p_errmesg := '';
        return;

    EXCEPTION

        WHEN OTHERS
        THEN
            FND_FILE.PUT_LINE (fnd_file.log, proc_name || ':' || sqlerrm);
            p_errnum := -1;
            p_errmesg := (proc_name || ':' || sqlerrm);
            RAISE; -- propagate to calling function

    END Calc_Eff_Applied_Units;


    /* Misc_Applied_Units

    */
    PROCEDURE Misc_Applied_Units(
            p_group_id          IN  NUMBER,
            p_organization_id   IN  NUMBER,
            p_date_from         IN  DATE,
            p_date_to           IN  DATE,
            p_department_id     IN  NUMBER,
            p_resource_id       IN  NUMBER,
            p_errnum            OUT NOCOPY NUMBER,
            p_errmesg           OUT NOCOPY VARCHAR2)
    IS
        proc_name VARCHAR2 (40) ;

    BEGIN
        proc_name := 'Misc_Applied_Units';
        g_uom_code := fnd_profile.value('BOM:HOUR_UOM_CODE');
        select uom_class
        into g_uom_class
          from mtl_units_of_measure
          where uom_code = g_uom_code;

        -- ??? What is this SQL doing?
        insert into wip_indicators_temp(
            group_id,
            organization_id,
            wip_entity_id,
            operation_seq_num,
            department_id,
            department_code,
            resource_id,
            resource_code,
            standard_quantity,
            standard_units,
            applied_units_prd,
            transaction_date,
            indicator_type,
            process_phase,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by,
            program_application_id)
        select
            p_group_id,
            wt.organization_id,
            wt.wip_entity_id,
            wt.operation_seq_num,
            bd.department_id,
            bd.department_code,
            wt.resource_id,
            br.resource_code,
            0,
            0,
            sum(inv_convert.inv_um_convert(0,NULL,wt.primary_quantity,
                wt.primary_uom,g_uom_code,NULL,NULL)),
            trunc(wt.transaction_date),
            WIP_EFFICIENCY,
            WIP_EFF_PHASE_THREE, -- this is the third and final phase
            sysdate,
            g_userid,
            SYSDATE,
            g_userid,
            g_applicationid
        from
            bom_resources br,
            bom_departments bd,
            bom_department_resources bdr,
            wip_transactions wt,
            mtl_units_of_measure muom
        where
            wt.transaction_date between trunc(p_date_from)
                and trunc(p_date_to) + 0.999999
        and wt.resource_id = nvl(p_resource_id, wt.resource_id)
        and wt.department_id = nvl(p_department_id, wt.department_id)
        and wt.organization_id = nvl(p_organization_id, wt.organization_id)
        and wt.transaction_type in (1, 3)
        and bdr.resource_id = wt.resource_id
        and bdr.department_id = wt.department_id
        and bd.department_id = nvl(bdr.share_from_dept_id, bdr.department_id)
        and bd.organization_id = wt.organization_id
        and br.resource_id = wt.resource_id
        and br.unit_of_measure = muom.uom_code
        and muom.uom_class = g_uom_class
        and br.organization_id = wt.organization_id
        group by
               wt.organization_id,
               wt.wip_entity_id,
               wt.operation_seq_num,
               bd.department_id,
               bd.department_code,
               wt.resource_id,
               br.resource_code,
               trunc(wt.transaction_date);

        commit ;

        p_errnum := 0;
        p_errmesg := '';

        return ;

    EXCEPTION

        WHEN OTHERS
        THEN
            FND_FILE.PUT_LINE (fnd_file.log, proc_name || ':' || sqlerrm);
            p_errnum := -1;
            p_errmesg := (proc_name || ':' || sqlerrm);
            RAISE; -- propagate to calling function

    END Misc_Applied_Units ;

    /* Calculate_Total_Quantity

    Calculate the Total Quantities produced by the various departments
    in the organization within the date range that is specified.
    However if the date range is not specified then we consider the
    whole time horizon. If no department is specified then we get all
    the departments in the organization. However if the department is
    specified then we get only corresponding department information
    */

    PROCEDURE Calculate_Total_Quantity(
            p_group_id          IN  NUMBER,
            p_organization_id   IN  NUMBER,
            p_date_from         IN  DATE,
            p_date_to           IN  DATE,
            p_department_id     IN  NUMBER)
    IS

        proc_name VARCHAR2 (40);

    -- ??? The truncs in this SQL on the dates can be better written because
    -- the arguments are already trunc'ed and WHERE transaction_date BETWEEN
    -- transaction_date and transaction_date always returns true.

    BEGIN
        proc_name  := 'Calculate_Total_Quantity';
        insert into wip_indicators_temp(
            group_id,
            organization_id,
            department_id,
            department_code,
            wip_entity_id,
            operation_seq_num,
            indicator_type,
            process_phase,
            transaction_date,
            total_quantity,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by,
            program_application_id)
    select
        p_group_id,
        wmt.organization_id,
        wo.department_id,
        bd.department_code,
        wmt.wip_entity_id,
        wo.operation_seq_num,
        WIP_YIELD,
        1, /* this is the first step */
        trunc(wmt.transaction_date),
        sum( decode ( sign(wmt.FM_OPERATION_SEQ_NUM-wmt.TO_OPERATION_SEQ_NUM),
               0, -- Within the same operation
               decode( wmt.FM_INTRAOPERATION_STEP_TYPE,
                       1,                                   -- From Queue
                       decode(  wmt.TO_INTRAOPERATION_STEP_TYPE,
                                2 , 0,
                                1, 0, -- this is not possible but still
                                (wmt.primary_quantity)
                             ),
                       2,                           -- From Run
                       decode(  wmt.TO_INTRAOPERATION_STEP_TYPE,
                                1, 0,
                                2, 0, -- this is not possible but still
                                (wmt.primary_quantity)
                              ),
                       decode(  wmt.TO_INTRAOPERATION_STEP_TYPE,
                                3, 0,
                                4, 0,
                                5, 0,
                                (-1*wmt.primary_quantity)
                              )
                       ),
                -1, -- Move in the positive direction
                decode(  wo.operation_seq_num,
                         wmt.FM_OPERATION_SEQ_NUM, -- Starting Operation
                         decode( wmt.FM_INTRAOPERATION_STEP_TYPE,
                                 3, 0,
                                 4, 0,
                                 5, 0,
                                 (wmt.primary_quantity)
                                ),
                         wmt.TO_OPERATION_SEQ_NUM, -- Final Operation
                         decode( wmt.TO_INTRAOPERATION_STEP_TYPE,
                                 1, 0,
                                 2, 0,
                                 (wmt.primary_quantity)
                               ),
                         (wmt.primary_quantity)
                       ),
                 1, -- Move in the negative direction
                 decode(  wo.operation_seq_num,
                          wmt.FM_OPERATION_SEQ_NUM, -- Starting Operation
                          decode( wmt.FM_INTRAOPERATION_STEP_TYPE,
                                  1, 0,
                                  2, 0,
                                  (-1*wmt.primary_quantity)
                                 ),
                          wmt.TO_OPERATION_SEQ_NUM, -- Final Operation
                          decode( wmt.TO_INTRAOPERATION_STEP_TYPE,
                                  3, 0,
                                  4, 0,
                                  5, 0,
                                  (-1*wmt.primary_quantity)
                                 ),
                          (-1*wmt.primary_quantity)
                         )
               ) ) "Quantity",
            sysdate,
            g_userid,
            SYSDATE,
            g_userid,
            g_applicationid
        from
            wip_move_transactions wmt,
            wip_operations wo,
            bom_departments bd
        where  trunc(wmt.transaction_date) between trunc(nvl(p_date_from,wmt.transaction_date))
                and trunc(nvl(p_date_to,wmt.transaction_date))
        --      below statement is equavivalent to between only. Dont know why such a complex condition.
        --      and wo.operation_seq_num between wmt.FM_OPERATION_SEQ_NUM and wmt.TO_OPERATION_SEQ_NUM
        and wo.operation_seq_num <= decode(sign(wmt.FM_OPERATION_SEQ_NUM-wmt.TO_OPERATION_SEQ_NUM),
                           -1,wmt.TO_OPERATION_SEQ_NUM, 1, wmt.FM_OPERATION_SEQ_NUM,
                            wmt.FM_OPERATION_SEQ_NUM)
        and wo.operation_seq_num >= decode(sign(wmt.FM_OPERATION_SEQ_NUM-wmt.TO_OPERATION_SEQ_NUM),
                            -1,wmt.FM_OPERATION_SEQ_NUM, 1, wmt.TO_OPERATION_SEQ_NUM,
                            wmt.FM_OPERATION_SEQ_NUM)
        and wmt.organization_id = wo.organization_id
        and wo.wip_entity_id = wmt.wip_entity_id
        and wo.organization_id = bd.organization_id
        and wo.department_id = bd.department_id
        and wo.department_id = nvl(p_department_id, wo.department_id)
        and bd.organization_id = nvl(p_organization_id,bd.organization_id)
        group by
            wmt.organization_id,
            wo.department_id,
            bd.department_code,
            wmt.wip_entity_id,
            wo.operation_seq_num,
            trunc(wmt.transaction_date),
            WIP_YIELD,
            sysdate,
            g_userid,
            SYSDATE,
            g_userid,
            g_applicationid
        having sum( decode ( sign(wmt.FM_OPERATION_SEQ_NUM-wmt.TO_OPERATION_SEQ_NUM),
                   0, -- Within the same operation
                   decode( wmt.FM_INTRAOPERATION_STEP_TYPE,
                           1,                                   -- From Queue
                           decode(  wmt.TO_INTRAOPERATION_STEP_TYPE,
                                    2 , 0,
                                    1, 0, -- this is not possible but still
                                    (wmt.primary_quantity)
                                 ),
                           2,                           -- From Run
                           decode(  wmt.TO_INTRAOPERATION_STEP_TYPE,
                                    1, 0,
                                    2, 0, -- this is not possible but still
                                    (wmt.primary_quantity)
                                  ),
                           decode(  wmt.TO_INTRAOPERATION_STEP_TYPE,
                                    3, 0,
                                    4, 0,
                                    5, .99,--instead of 0 it is made .99 for bug 3280671
                                    (-1*wmt.primary_quantity)
                                  )
                           ),
                    -1, -- Move in the positive direction
                    decode(  wo.operation_seq_num,
                             wmt.FM_OPERATION_SEQ_NUM, -- Starting Operation
                             decode( wmt.FM_INTRAOPERATION_STEP_TYPE,
                                     3, 0,
                                     4, 0,
                                     5, 0,
                                     (wmt.primary_quantity)
                                    ),
                             wmt.TO_OPERATION_SEQ_NUM, -- Final Operation
                             decode( wmt.TO_INTRAOPERATION_STEP_TYPE,
                                     1, 0,
                                     2, 0,
                                     (wmt.primary_quantity)
                                   ),
                             (wmt.primary_quantity)
                           ),
                     1, -- Move in the negative direction
                     decode(  wo.operation_seq_num,
                              wmt.FM_OPERATION_SEQ_NUM, -- Starting Operation
                              decode( wmt.FM_INTRAOPERATION_STEP_TYPE,
                                      1, 0,
                                      2, 0,
                                      (-1*wmt.primary_quantity)
                                     ),
                              wmt.TO_OPERATION_SEQ_NUM, -- Final Operation
                              decode( wmt.TO_INTRAOPERATION_STEP_TYPE,
                                      3, 0,
                                      4, 0,
                                      5, 0,
                                      (-1*wmt.primary_quantity)
                                     ),
                              (-1*wmt.primary_quantity)
                             )
                   ) ) <> 0 ;
-------------------------------------BUG 3280671-----------------------------------------------------
/*This Having Clause is stopping row with total_quantity 0. This need when we have scrap transaction
on a different date then to_move transcations for that step 5 ,0->.99*/
-----------------------------------------------------------------------------------------------------
        commit;

        -- gather stats on table to allow index access
        If nvl(WIP_CALL_LOG,-1) =1 then
        fnd_stats.gather_table_stats (g_wip_schema, 'WIP_INDICATORS_TEMP',
                                      cascade => true);
        End If;

    EXCEPTION

        WHEN OTHERS
        THEN
            FND_FILE.PUT_LINE (fnd_file.log, proc_name || ':' || sqlerrm);
            RAISE; -- propagate to calling function

    END Calculate_Total_Quantity;




    /*  Calculate_Scrap_Quantity
        This gets the Quantity scrapped over every department
        however if the scrapped quantity was moved from one department
        to the other, this takes that into account
    */

    PROCEDURE Calculate_Scrap_Quantity(
            p_group_id          IN  NUMBER,
            p_organization_id   IN  NUMBER,
            p_date_from         IN  DATE,
            p_date_to           IN  DATE,
            p_errnum            OUT NOCOPY NUMBER,
            p_errmesg           OUT NOCOPY VARCHAR2 )
    IS

        proc_name VARCHAR2 (40);

    -- ??? The truncs in this SQL on the dates can be better written because
    -- the arguments are already trunc'ed and WHERE transaction_date BETWEEN
    -- transaction_date and transaction_date always returns true.
    -- What the hell is this join condition on date anyway? It excludes
    -- all dates that lie between from and to, when the from is greater
    -- than the to. That should not be the intent, should it?


        -- Cursor to get all departments scrap to scrap transaction
        CURSOR Scrap_Adjustment (
                p_group_id number,
                p_org_id number,
                p_date_from date,
                p_date_to date ) IS
            SELECT /* WIP_MOVE_TRANSACTIONS_N2 */
              organization_id,
              wip_entity_id,
              fm_operation_seq_num,
              to_operation_seq_num,
              fm_intraoperation_step_type,
              to_intraoperation_step_type,
              primary_quantity,
              trunc(transaction_date) transaction_date
              FROM   wip_move_transactions
              WHERE  ( trunc(transaction_date) >= trunc(nvl(p_date_from,transaction_date))
                       AND trunc(transaction_date) <= trunc(nvl(p_date_to,transaction_date)) )-- Or is replace AND Bug 3280671
                        --( trunc(transaction_date) >= trunc(nvl(p_date_from,transaction_date))
                       --OR trunc(transaction_date) <= trunc(nvl(p_date_to,transaction_date)) )
                AND    organization_id = nvl(p_org_id,organization_id)
                AND    fm_intraoperation_step_type = 5 ;

        x_step  NUMBER ;
    BEGIN
        x_step  := 0;
        proc_name  := 'Calculate_Scrap_Quantity';
        -- Step 1: <see comment below>
        x_step := 1;
        if g_debug = 1 then
            fnd_file.put_line(fnd_file.log, 'Before Stage 4 Phase II Step : ' || x_step);
        end if ;
        ----dbms_output.put_line('Before Stage 4 Phase II Step : ' || x_step);

        -- Update the Scrap Quantitied for the various departments.
        -- This does an update only for that particular txn_date
        -- was already existing.
        -- Note: we don't have to worry about making an insert for
        -- those transactions on a day which has got nothing
        -- but scrap transactions for that day (because
        -- it is not possible in this logic not to have a record
        -- for that day when all the transactions were scrap transactions).

        UPDATE wip_indicators_temp wit
        SET wit.scrap_quantity = (
                SELECT nvl(sum(wmt.primary_quantity),0)
                  FROM wip_move_transactions wmt
                  WHERE     wmt.wip_entity_id = wit.wip_entity_id
                    AND     wmt.to_operation_seq_num = wit.operation_seq_num
                    AND     wmt.organization_id = wit.organization_id
                    AND     wmt.to_intraoperation_step_type = 5
                    AND     wmt.fm_intraoperation_step_type <> 5
                    AND     wmt.transaction_date BETWEEN
                            nvl(p_date_from, wmt.transaction_date)
                            AND nvl(p_date_to + 0.99999,
                                    wmt.transaction_date)
                    AND     wmt.transaction_date BETWEEN wit.transaction_date
                            AND wit.transaction_date + 0.99999
                ),
            wit.process_phase = WIP_DEPT_YIELD    /* process phase 2 */
        WHERE wit.indicator_type = WIP_YIELD;

        COMMIT;


        -- Step 2:
        -- Take into account the scrap quantities that are moved from one
        -- department to the other
        x_step := 2;
        if g_debug = 1 then
            fnd_file.put_line(fnd_file.log, 'Before Stage 4 Phase II Step : '
                              || x_step);
        end if ;
        ----dbms_output.put_line('Before Stage 4 Phase II Step : ' || x_step);
        FOR Adj_Rec IN Scrap_Adjustment(
                p_group_id,
                p_organization_id,
                p_date_from,
                p_date_to) LOOP

            -- ??? what does this next comment mean
            -- This is to let it compile without a problem
            IF (Adj_Rec.to_intraoperation_step_type = 5) then

                update wip_indicators_temp
                set    scrap_quantity = (scrap_quantity -
                                         Adj_Rec.Primary_Quantity)
                where  indicator_type = WIP_YIELD
                and    process_phase = WIP_DEPT_YIELD
                and    organization_id = Adj_Rec.organization_id
                and    wip_entity_id = Adj_Rec.Wip_Entity_id
                and    operation_seq_num = Adj_Rec.fm_operation_seq_num
                and    transaction_date = Adj_Rec.transaction_date ;


                update wip_indicators_temp
                set    scrap_quantity = (scrap_quantity +
                                         Adj_Rec.Primary_Quantity)
                where  indicator_type = WIP_YIELD
                and    process_phase = WIP_DEPT_YIELD
                and    organization_id = Adj_Rec.organization_id
                and    wip_entity_id = Adj_Rec.Wip_Entity_id
                and    operation_seq_num = Adj_Rec.to_operation_seq_num
                and    transaction_date = Adj_Rec.transaction_date ;

                /*  I had not considered this initially - I have handled
                    this movement from the scrap intraoperation step
                    as a negative scrap transaction */

            ELSIF (Adj_Rec.to_intraoperation_step_type <>5 ) then

                update wip_indicators_temp
                set    scrap_quantity = (scrap_quantity -
                                         Adj_Rec.Primary_Quantity)
                where  indicator_type = WIP_YIELD
                and    process_phase = WIP_DEPT_YIELD
                and    organization_id = Adj_Rec.organization_id
                and    wip_entity_id = Adj_Rec.Wip_Entity_id
                and    operation_seq_num = Adj_Rec.fm_operation_seq_num
                and    transaction_date = Adj_Rec.transaction_date ;

            END IF ;

        END LOOP ;

        COMMIT ;

        p_errnum := 0;
        p_errmesg := '';

        RETURN ;

    EXCEPTION

        WHEN OTHERS
        THEN
            FND_FILE.PUT_LINE (fnd_file.log, proc_name || ':' || sqlerrm);
            p_errnum := -1;
            p_errmesg := (proc_name || ':' || sqlerrm);
            RAISE; -- propagate to calling function

        -- The exceptions in this will be handled by the calling function

    END Calculate_Scrap_Quantity;



    /* Resource_Yield
       This incorporates the yield for the resource
       associated with the departments
    */

    PROCEDURE Resource_Yield(
            p_group_id      IN  NUMBER,
            p_errnum        OUT NOCOPY NUMBER,
            p_errmesg       OUT NOCOPY VARCHAR2 )
    IS

        proc_name VARCHAR2 (40);

    BEGIN
        proc_name := 'Resource_Yield';
        -- Incorporate the resource information
        -- Note : We should probably summarize across the
        --        Operation Sequences for a Department
        ----dbms_output.put_line('Inside the Resource Yield');

        insert into wip_indicators_temp(
            group_id,
            organization_id,
            wip_entity_id,
            operation_seq_num,
            department_id,
            department_code,
            resource_id,
            resource_code,
            total_quantity,
            scrap_quantity,
            transaction_date,
            indicator_type,
            process_phase,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by,
            program_application_id )
        select
            wit.group_id,
            wit.organization_id,
            wit.wip_entity_id,
            wit.operation_seq_num,
            wit.department_id,
            wit.department_code,
            wor.resource_id,
            br.resource_code,
            sum(wit.total_quantity),
            sum(wit.scrap_quantity),
            wit.transaction_date,  -- already trunc'ed
            wit.indicator_type,
            WIP_RES_YIELD,          /* This is the resource phase */
            wit.last_update_date,
            wit.last_updated_by,
            wit.creation_date,
            wit.created_by,
            wit.program_application_id
          from  wip_indicators_temp wit,
                bom_resources br,
                wip_operation_resources wor
          where  wor.wip_entity_id = wit.wip_entity_id
            and  wor.operation_seq_num = wit.operation_seq_num
            and  wit.indicator_type = WIP_YIELD
            and  wit.process_phase = WIP_DEPT_YIELD
            and  br.organization_id = wor.organization_id
            and  br.resource_id = wor.resource_id
            group by
                wit.group_id,
                wit.organization_id,
                wit.wip_entity_id,
                wit.operation_seq_num,
                wit.department_id,
                wit.department_code,
                wor.resource_id,
                br.resource_code,
                wit.transaction_date,
                wit.indicator_type,
                WIP_RES_YIELD,
                wit.last_update_date,
                wit.last_updated_by,
                wit.creation_date,
                wit.created_by,
                wit.program_application_id ;

        commit ;

        -- clean up the tables
        delete from wip_indicators_temp
        where indicator_type = WIP_YIELD
        and   process_phase = 1  ;

        commit ;

        p_errnum := 0;
        p_errmesg := '';

        RETURN ;

    EXCEPTION

        WHEN OTHERS
        THEN
            FND_FILE.PUT_LINE (fnd_file.log, proc_name || ':' || sqlerrm);
            p_errnum := -1;
            p_errmesg := (proc_name || ':' || sqlerrm);
            RAISE; -- propagate to calling function

    END Resource_Yield;

    /* Move_info_into_summary
        Move the utilization, efficiency, yield data into the
        summary table, wip_bis_prod_indicators.
    */
    PROCEDURE Move_Info_Into_Summary (
            p_group_id  IN NUMBER,
            p_errnum    OUT NOCOPY NUMBER,
            p_errmesg   OUT NOCOPY VARCHAR2
            )
    is
        x_phase VARCHAR2(10);
    begin

        -- Split wip_indicators_temp into three temp tables with
        -- efficiency, yield and utilization info for faster data
        -- manipulation. Now we don't need to join to the
        -- entire WIT, but only the specialized temp tables.

        -- efficiency table -- indicator = WIP_EFFICIENCY = 1
        populate_eff_temp_table ('WIP_BIS_EFF_TEMP', 1, p_group_id);-- for bug 3280647
        --populate_temp_table ('WIP_BIS_EFF_TEMP', 1, p_group_id);
        Commit;
        -- utilization tabe - indicator = WIP_UTILIZATION = 2
        populate_temp_table ('WIP_BIS_UTZ_TEMP', 2, p_group_id);
        commit;
        -- yield table - indicator = WIP_YIELD = 3
        populate_temp_table ('WIP_BIS_YLD_TEMP', 3, p_group_id);

        commit;

        -- Phase I: Move records that have utilization, yield and
        -- efficiency info into summary table.
        x_phase := 'I';
        if g_debug = 1 then
            fnd_file.put_line (fnd_file.log,
                               to_char (sysdate, 'DD-MON-YYYY HH24:MI:SS'));
            fnd_file.put_line(fnd_file.log, 'Before Stage 5 Phase I');
        end if ;
        --dbms_output.put_line (to_char (sysdate, 'DD-MON-YYYY HH24:MI:SS'));
        --dbms_output.put_line('Before Stage 5 Phase I');

        -- The new version of this query.
        -- A simple decomposition done in the simple_decomp function
        simple_decomp (p_group_id);
        commit;

        -- Phase II:
        -- Insert Efficiency information into the summary table
        -- for all the org_id, wip_id, op_seq, dept_id, res_id,
        -- txn_date that did not get moved in Phase I
        x_phase := 'II';
        if g_debug = 1 then
            fnd_file.put_line (fnd_file.log,
                               to_char (sysdate, 'DD-MON-YYYY HH24:MI:SS'));
            fnd_file.put_line(fnd_file.log, 'Before Stage 5 Phase II');
        end if ;
        --dbms_output.put_line (to_char (sysdate, 'DD-MON-YYYY HH24:MI:SS'));
        --dbms_output.put_line('Before Stage 5 Phase II');

        insert into wip_bis_prod_indicators (
                ORGANIZATION_ID,
                WIP_ENTITY_ID,
                INVENTORY_ITEM_ID,
                TRANSACTION_DATE,
                OPERATION_SEQ_NUM,
                DEPARTMENT_ID,
                DEPARTMENT_CODE,
                RESOURCE_ID,
                RESOURCE_CODE,
                STANDARD_HOURS,
                APPLIED_HOURS_PRD,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                CREATION_DATE,
                CREATED_BY,
                LAST_UPDATE_LOGIN,
                REQUEST_ID,
                PROGRAM_APPLICATION_ID,
                PROGRAM_UPDATE_DATE)
        select  wit.organization_id,
                wit.wip_entity_id,
                we.primary_item_id,
                trunc(wit.transaction_date),
                wit.operation_seq_num,
                wit.department_id,
                wit.department_code,
                wit.resource_id,
                wit.resource_code,
                wit.standard_units,
                wit.applied_units_prd,
                wit.last_update_date,
                wit.last_updated_by,
                wit.creation_date,
                wit.created_by,
                wit.last_update_login,
                wit.request_id,
                wit.program_application_id,
                sysdate
        from    wip_entities we,
                wip_bis_eff_temp wit
        where   we.wip_entity_id = wit.wip_entity_id
        and     we.organization_id = wit.organization_id
        and     wit.indicator_type = WIP_EFFICIENCY
        and     not exists (
                        select  null
                        from    wip_bis_prod_indicators wbpi
                        where   wit.organization_id = wbpi.organization_id
                        and     wit.wip_entity_id = wbpi.wip_entity_id
                        and     wit.operation_seq_num = wbpi.operation_seq_num
                        and     wit.department_id = wbpi.department_id
                        and     wit.resource_id = wbpi.resource_id
                        and     wbpi.transaction_date between
                                    trunc(wit.transaction_date)
                                    and trunc(wit.transaction_date) + 0.99999
                ) ;

        commit ;

        -- gather stats on table to allow index access
        If nvl(WIP_CALL_LOG,-1) =1 then
        fnd_stats.gather_table_stats (g_wip_schema, 'WIP_BIS_PROD_INDICATORS',
                                      cascade => true);
        End If;

        -- Phase III:
        -- Update Utilization information into
        -- the summary table for the new efficiency records added.

        x_phase := 'III';
        if g_debug = 1 then
            fnd_file.put_line (fnd_file.log,
                               to_char (sysdate, 'DD-MON-YYYY HH24:MI:SS'));
            fnd_file.put_line(fnd_file.log, 'Before Stage 5 Phase III');
        end if ;
        --dbms_output.put_line (to_char (sysdate, 'DD-MON-YYYY HH24:MI:SS'));
        --dbms_output.put_line('Before Stage 5 Phase III');

        update/*+ PARALLEL*/ wip_bis_prod_indicators wbpi
        set (wbpi.APPLIED_HOURS_UTZ, wbpi.AVAILABLE_HOURS) =
                ( select wit.applied_units_utz, wit.available_units
                  from wip_bis_utz_temp wit
                  where wit.organization_id = wbpi.organization_id
                  and   wit.wip_entity_id = wbpi.wip_entity_id
                  and   wit.operation_seq_num = wbpi.operation_seq_num
                  and   wit.department_id = wbpi.department_id
                  and   wit.resource_id = wbpi.resource_id
                  and   wit.transaction_date BETWEEN
                        trunc(wbpi.transaction_date)
                        AND trunc (wbpi.transaction_date) + 0.99999
                  and   wit.indicator_type = WIP_UTILIZATION
            )
        where wbpi.APPLIED_HOURS_UTZ is null
        and   wbpi.AVAILABLE_HOURS is null ;
        commit;
  -- Addtion to remove available hours from other than min(wip_entity_id)  on same day    bug -3662056
        update  /*+ INDEX(wbpi WIP_BIS_PROD_INDICATORS_N8) */  wip_bis_prod_indicators wbpi
        set  wbpi.AVAILABLE_HOURS = 0
        where wbpi.AVAILABLE_HOURS is not null
        and  wbpi.wip_entity_id <>
                (select /*+ INDEX(wit WIP_BIS_PROD_INDICATORS_N8) INDEX_FFS(wit WIP_BIS_PROD_INDICATORS_N8)*/ min(wit.wip_entity_id)
                        from wip_bis_prod_indicators wit
                        where   trunc(wit.transaction_date)  =trunc(wbpi.transaction_date)
                        and 	wbpi.resource_id = wit.resource_id
                        and	wbpi.department_id = wit.department_id
                        and 	wbpi.organization_id = wit.organization_id );

 --- Fix when same resource is used for more than one step    bug -3662056
        update  /*+ INDEX(wbpi WIP_BIS_PROD_INDICATORS_N8) */  wip_bis_prod_indicators wbpi
        set  wbpi.AVAILABLE_HOURS = 0
        where wbpi.AVAILABLE_HOURS is not null
        and  wbpi.operation_seq_num <>
                (select /*+ INDEX(wit WIP_BIS_PROD_INDICATORS_N8) INDEX_FFS(wit WIP_BIS_PROD_INDICATORS_N8)*/  min(wit.operation_seq_num)
                        from wip_bis_prod_indicators wit
                        where   trunc(wit.transaction_date)  =trunc(wbpi.transaction_date)
                        and 	wbpi.resource_id = wit.resource_id
                        and	wbpi.department_id = wit.department_id
                        and 	wbpi.organization_id = wit.organization_id
                        and 	wbpi.wip_entity_id = wip_entity_id);

        commit;
        -- Phase IV:
        -- Update Yield/Scrap information into
        -- the summary table for the new efficiency records added
        x_phase := 'IV';
        if g_debug = 1 then
            fnd_file.put_line (fnd_file.log,
                               to_char (sysdate, 'DD-MON-YYYY HH24:MI:SS'));
            fnd_file.put_line(fnd_file.log, 'Before Stage 5 Phase IV');
        end if ;
        --dbms_output.put_line (to_char (sysdate, 'DD-MON-YYYY HH24:MI:SS'));
        --dbms_output.put_line('Before Stage 5 Phase IV');

        update wip_bis_prod_indicators wbpi
        set (wbpi.TOTAL_QUANTITY, wbpi.SCRAp_QUANTITY) =
                ( select wit.total_quantity, wit.scrap_quantity
              from wip_bis_yld_temp wit
              where wit.organization_id = wbpi.organization_id
              and   wit.wip_entity_id = wbpi.wip_entity_id
              and   wit.operation_seq_num = wbpi.operation_seq_num
              and   wit.department_id = wbpi.department_id
              and   wit.resource_id = wbpi.resource_id
              and   wit.transaction_date BETWEEN trunc(wbpi.transaction_date)
                        and trunc (wbpi.transaction_date) + 0.99999
              and   wit.indicator_type = WIP_YIELD
              and   wit.process_phase = WIP_RES_YIELD
            )
        where wbpi.TOTAL_QUANTITY is null
        and   wbpi.SCRAP_QUANTITY is null ;

        commit;

        -- Phase V:
        -- Insert all utilization records that have not been inserted yet.
        x_phase := 'V';
        if g_debug = 1 then
            fnd_file.put_line (fnd_file.log,
                               to_char (sysdate, 'DD-MON-YYYY HH24:MI:SS'));
            fnd_file.put_line(fnd_file.log, 'Before Stage 5 Phase V');
        end if ;
        --dbms_output.put_line (to_char (sysdate, 'DD-MON-YYYY HH24:MI:SS'));
        --dbms_output.put_line('Before Stage 5 Phase V');

        insert into wip_bis_prod_indicators (
            ORGANIZATION_ID,
            WIP_ENTITY_ID,
            INVENTORY_ITEM_ID,
            TRANSACTION_DATE,
            OPERATION_SEQ_NUM,
            DEPARTMENT_ID,
            DEPARTMENT_CODE,
            RESOURCE_ID,
            RESOURCE_CODE,
            APPLIED_HOURS_UTZ,
            AVAILABLE_HOURS,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            CREATION_DATE,
            CREATED_BY,
            LAST_UPDATE_LOGIN,
            REQUEST_ID,
            PROGRAM_APPLICATION_ID,
            PROGRAM_UPDATE_DATE)
        select  wit.organization_id,
                wit.wip_entity_id,
                we.primary_item_id,
            trunc(wit.transaction_date),
            wit.operation_seq_num,
            wit.department_id,
            wit.department_code,
            wit.resource_id,
            wit.resource_code,
            wit.applied_units_utz,
            wit.available_units,
            wit.last_update_date,
            wit.last_updated_by,
            wit.creation_date,
            wit.created_by,
            wit.last_update_login,
            wit.request_id,
            wit.program_application_id,
            sysdate
        from    wip_entities we,
            wip_bis_utz_temp wit
        where we.wip_entity_id = wit.wip_entity_id
        and we.organization_id = wit.organization_id
        and wit.indicator_type = WIP_UTILIZATION
        and not exists (
                select  null
                from    wip_bis_prod_indicators wbpi
                where   wit.organization_id = wbpi.organization_id
                and     wit.wip_entity_id = wbpi.wip_entity_id
                and     wit.operation_seq_num = wbpi.operation_seq_num
                and     wit.department_id = wbpi.department_id
                and     wit.resource_id = wbpi.resource_id
                and     wbpi.transaction_date between
                        trunc(wit.transaction_date)
                        and trunc(wit.transaction_date) + 0.99999);

        commit ;

        -- gather stats on table to allow index access
        If nvl(WIP_CALL_LOG,-1) =1 then
        fnd_stats.gather_table_stats (g_wip_schema, 'WIP_BIS_PROD_INDICATORS',
                                      cascade => true);
        End If;
        -- Phase VI:
        -- Update Yield information into
        -- the summary table for the new utilization records added

        x_phase := 'VI';
        if g_debug = 1 then
            fnd_file.put_line (fnd_file.log,
                               to_char (sysdate, 'DD-MON-YYYY HH24:MI:SS'));
            fnd_file.put_line(fnd_file.log, 'Before Stage 5 Phase VI');
        end if ;
        --dbms_output.put_line (to_char (sysdate, 'DD-MON-YYYY HH24:MI:SS'));
        --dbms_output.put_line('Before Stage 5 Phase VI');

        update wip_bis_prod_indicators wbpi
        set (wbpi.total_quantity, wbpi.scrap_quantity) =
            ( select wit.total_quantity, wit.scrap_quantity
              from wip_bis_yld_temp wit
              where wit.organization_id = wbpi.organization_id
              and   wit.wip_entity_id = wbpi.wip_entity_id
              and   wit.operation_seq_num = wbpi.operation_seq_num
              and   wit.department_id = wbpi.department_id
              and   wit.resource_id = wbpi.resource_id
              and   wit.transaction_date BETWEEN trunc(wbpi.transaction_date)
                        and trunc (wbpi.transaction_date) + 0.99999
              and   wit.indicator_type = WIP_YIELD
              and   wit.process_phase = WIP_RES_YIELD
            )
        where wbpi.total_quantity is null
        and   wbpi.scrap_quantity is null ;

        commit;

        -- Phase VII:
        -- Insert all the yield info not already inserted/updated
        -- into the summary table.

        x_phase := 'VII';
        if g_debug = 1 then
            fnd_file.put_line(fnd_file.log, 'Before Stage 5 Phase VII');
            fnd_file.put_line (fnd_file.log,
                               to_char (sysdate, 'DD-MON-YYYY HH24:MI:SS'));
        end if ;
        --dbms_output.put_line (to_char (sysdate, 'DD-MON-YYYY HH24:MI:SS'));
        --dbms_output.put_line('Before Stage 5 Phase VII');

        insert into wip_bis_prod_indicators (
            ORGANIZATION_ID,
            WIP_ENTITY_ID,
            INVENTORY_ITEM_ID,
            TRANSACTION_DATE,
            OPERATION_SEQ_NUM,
            DEPARTMENT_ID,
            DEPARTMENT_CODE,
            RESOURCE_ID,
            RESOURCE_CODE,
            TOTAL_QUANTITY,
            SCRAP_QUANTITY,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            CREATION_DATE,
            CREATED_BY,
            LAST_UPDATE_LOGIN,
            REQUEST_ID,
            PROGRAM_APPLICATION_ID,
            PROGRAM_UPDATE_DATE)
        select  wit.organization_id,
                wit.wip_entity_id,
                we.primary_item_id,
            trunc(wit.transaction_date),
            wit.operation_seq_num,
            wit.department_id,
            wit.department_code,
            wit.resource_id,
            wit.resource_code,
            wit.total_quantity,
            wit.scrap_quantity,
            wit.last_update_date,
            wit.last_updated_by,
            wit.creation_date,
            wit.created_by,
            wit.last_update_login,
            wit.request_id,
            wit.program_application_id,
            sysdate
        from    wip_entities we,
            wip_bis_yld_temp wit
        where we.wip_entity_id = wit.wip_entity_id
        and we.organization_id = wit.organization_id
        and wit.indicator_type = WIP_YIELD
        and wit.process_phase = WIP_RES_YIELD
        and not exists
             (select null
              from wip_bis_prod_indicators wbpi
              where wit.organization_id = wbpi.organization_id
                and wit.wip_entity_id = wbpi.wip_entity_id
                and wit.operation_seq_num =  wbpi.operation_seq_num
                and wit.department_id = wbpi.department_id
                and wit.resource_id = wbpi.resource_id
                and wbpi.transaction_date between trunc(wit.transaction_date)
                and trunc(wit.transaction_date) + 0.99999);

        commit ;

        -- gather stats on table to allow index access
        If nvl(WIP_CALL_LOG,-1) =1 then
        fnd_stats.gather_table_stats (g_wip_schema, 'WIP_BIS_PROD_INDICATORS',
                                      cascade => true);
        End if;

        -- Phase VIII:
        -- Move the Utilization Information for the
        -- resources with zero utilization into the
        -- the Summary table wip_bis_prod_indicators

        x_phase := 'VIII';
        if g_debug = 1 then
            fnd_file.put_line(fnd_file.log, 'Before Stage 5 Phase VIII');
            fnd_file.put_line (fnd_file.log,
                               to_char (sysdate, 'DD-MON-YYYY HH24:MI:SS'));
        end if ;
        --dbms_output.put_line (to_char (sysdate, 'DD-MON-YYYY HH24:MI:SS'));
        --dbms_output.put_line('Before Stage 5 Phase VIII');

        Move_Utz_Info(
                p_group_id => p_group_id,
                p_errnum => p_errnum,
                p_errmesg => p_errmesg );


        p_errnum := 0;
        p_errmesg := '';
        return ;


    -- The exceptions in this will be handled by the calling function
    exception

        when others then

            if g_debug = 1 then
                fnd_file.put_line(fnd_file.log,
                                  'Failed in Move_Info_Into_Summary in Stage 5 phase : '
                                  ||x_phase);
                fnd_file.put_line(fnd_file.log, SQLCODE);
                fnd_file.put_line(fnd_file.log,SQLERRM);
            end if ;

            -- dbms_output.put_line('Failed in Stage 5 phase : '||x_phase);
            -- dbms_output.put_line(SQLCODE);
            -- dbms_output.put_line(SQLERRM);

            p_errnum := -1 ;
            p_errmesg := 'Failed in Stage 5 Phase : '|| x_phase||
                         substr(SQLERRM,1,125);

            -- returns to populate_summary_table, so don't raise exception.

            commit ;
            return ;

    End Move_Info_Into_Summary;


    /* Move_Yield_Info
       Move the yield information for every department into the
       summary table wip_bis_prod_dept_yield.
    */
    PROCEDURE Move_Yield_Info (
            p_group_id  IN NUMBER,
            p_errnum    OUT NOCOPY NUMBER,
            p_errmesg   OUT NOCOPY VARCHAR2) IS

        x_phase     VARCHAR2(10);

        proc_name VARCHAR2 (40);

    BEGIN
        proc_name  := 'Move_Yield_Info';

        x_phase := 'I';
        IF g_debug = 1 THEN
            fnd_file.put_line(fnd_file.log, 'Before Stage 6 Phase I');
        END IF ;
        ----dbms_output.put_line('Before Stage 6 Phase I');

        -- insert efficiency into the summary table
        INSERT INTO wip_bis_prod_dept_yield (
            ORGANIZATION_ID,
            WIP_ENTITY_ID,
            INVENTORY_ITEM_ID,
            TRANSACTION_DATE,
            OPERATION_SEQ_NUM,
            DEPARTMENT_ID,
            DEPARTMENT_CODE,
            TOTAL_QUANTITY,
            SCRAP_QUANTITY,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            CREATION_DATE,
            CREATED_BY,
            LAST_UPDATE_LOGIN,
            REQUEST_ID,
            PROGRAM_APPLICATION_ID,
            PROGRAM_UPDATE_DATE)
        SELECT  wit.organization_id,
                wit.wip_entity_id,
                we.primary_item_id,
                wit.transaction_date,
                wit.operation_seq_num,
                wit.department_id,
                wit.department_code,
                wit.total_quantity,
                wit.scrap_quantity,
                wit.last_update_date,
                wit.last_updated_by,
                wit.creation_date,
                wit.created_by,
                wit.last_update_login,
                wit.request_id,
                wit.program_application_id,
                sysdate
          FROM    wip_entities we,
                  wip_bis_yld_temp wit
          WHERE we.wip_entity_id = wit.wip_entity_id
            AND we.organization_id = wit.organization_id
            AND wit.indicator_type = WIP_YIELD
            AND wit.process_phase = WIP_DEPT_YIELD;

        COMMIT ;

        p_errnum := 0;
        p_errmesg := '';

        RETURN ;


    EXCEPTION

        WHEN OTHERS THEN

            IF g_debug = 1 THEN
                fnd_file.put_line(fnd_file.log,
                                 'Failed in Move_Yield_Info in Stage 6 phase : '||
                                  x_phase);
                fnd_file.put_line(fnd_file.log, SQLCODE);
                fnd_file.put_line(fnd_file.log,SQLERRM);
            END IF ;
            ----dbms_output.put_line('Failed in Stage 6 phase : '||x_phase);
            ----dbms_output.put_line(SQLCODE);
            ----dbms_output.put_line(SQLERRM);
            p_errnum := -1 ;
            p_errmesg := 'Failed in Stage 6 Phase : '|| x_phase ||
                          substr(SQLERRM,1,125);

            -- returns to populate_summary_table, so don't raise exception.

            COMMIT ;
            RETURN ;

    END Move_Yield_Info;



    /*  Move_Utz_Info
        Move the utilization information that doesnot have
        job and op seq reference from mrp_net_resource_avail
        into wip_bis_prod_indicators
    */
 /*   PROCEDURE Move_Utz_Info(  --comment for bug 3662056
            p_group_id  IN NUMBER,
            p_errnum    OUT NOCOPY NUMBER,
            p_errmesg   OUT NOCOPY VARCHAR2) IS

        x_phase       VARCHAR2(10);
        x_org_id  NUMBER;

        l_all_available_hours NUMBER;
        l_wit_utz_size NUMBER ;

        proc_name VARCHAR2 (40) ;

    BEGIN
       l_all_available_hours := 0;
       l_wit_utz_size := 0;
       proc_name  := 'Move_Utz_Info';

        -- The original insert into wip_bis_prod_indicators was using
        -- wip_indicators_temp's UTILIZATION rows and computing the
        -- measure available_hours as:
        -- sum (((mnra.to_time-mnra.from_time)/3600)*mnra.capacity_units)
        -- for 4 attributes:
        -- 1. organization_id
        -- 2. department_id
        -- 3. resource_id
        -- 4. transaction_date
        -- Where any one of these 4 fields in WIT did not
        -- match those in MNRA. In other words, we had a
        -- nested loop sum on MNRA that was performing badly. Instead,
        -- we have now summed up the above measure by these 4 attributes
        -- (actually, there is also a simulation_set field which is always
        -- NULL for us and can be ignored) in a temp table called
        -- wip_bis_mnra_temp. Therefore, the same sum as before
        -- can be computed by summing across the table, and subtracting
        -- each record's value from the full sum over the table.
        -- WIP_BIS_MNRA_TEMP stores exactly one row per distinct set of
        -- the 4 attributes.
        SELECT sum (available_hours)
        INTO l_all_available_hours
          FROM wip_bis_mnra_temp;


        -- Based on the old join conditions, every combination of
        -- org, dept, res, date in MNRA was added up for every row
        -- in WIT that it did not match.
        SELECT count (*)
        INTO l_wit_utz_size
          FROM (SELECT distinct organization_id,
                                resource_id,
                                department_id,
                                transaction_date
                  FROM wip_bis_utz_temp
                  WHERE process_phase = WIP_UTZ_PHASE_TWO
                    AND indicator_type = WIP_UTILIZATION) wit_distinct;

        -- Note that from Populate_Utilization, we know that
        -- org, dept, resource and transaction_date make a primary
        -- key for the UTILIZATION data, and the same is true of
        -- wip_bis_mnra_temp. Hence the join here need not do
        -- any group by etc.
        insert into wip_bis_prod_indicators(
            organization_id,
            wip_entity_id,
            operation_seq_num,
            department_id,
            department_code,
            resource_id,
            resource_code,
            applied_hours_utz,
            AVAILABLE_HOURS,
            transaction_date,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by,
            program_application_id)
        select
            mnra.organization_id,
            null,
            null,
            mnra.department_id,
            bd.department_code,
            mnra.resource_id,
            br.resource_code,
            null,
            decode (wit.net_occurances,
                    NULL, l_wit_utz_size * mnra.available_hours,
                    (l_wit_utz_size - net_occurances) * mnra.available_hours),
            mnra.shift_date,  -- already trunc'ed
            sysdate,
            g_userid,
            SYSDATE,
            g_userid,
            g_applicationid
          FROM
            (SELECT organization_id,
                    department_id,
                    resource_id,
                    transaction_date,
                    count (*) net_occurances
              FROM wip_bis_utz_temp
              WHERE indicator_type = WIP_UTILIZATION
                AND process_phase = WIP_UTZ_PHASE_TWO
              GROUP BY  organization_id,
                        department_id,
                        resource_id,
                        transaction_date) wit,
            bom_resources br,
            bom_departments bd,
            wip_bis_mnra_temp mnra,
            mtl_units_of_measure muom
          where mnra.shift_date BETWEEN trunc(g_date_from)
                                AND trunc (g_date_to) + 0.99999
            and br.resource_id = mnra.resource_id
            and br.unit_of_measure = muom.uom_code
            and muom.uom_class = g_uom_class
            and br.organization_id = mnra.organization_id
            and bd.department_id = mnra.department_id
            and bd.organization_id = mnra.organization_id
            and mnra.shift_date = wit.transaction_date(+) -- both are trunc'ed
            and mnra.resource_id = wit.resource_id(+)
            and mnra.department_id = wit.department_id(+)
            and mnra.organization_id = wit.organization_id(+);

        commit ;


        -- gather stats on table to allow index access
        fnd_stats.gather_table_stats (g_wip_schema, 'WIP_BIS_PROD_INDICATORS',
                                      cascade => true);

        p_errnum := 0;
        p_errmesg := '';

        RETURN;

    EXCEPTION

        WHEN OTHERS
        THEN
            FND_FILE.PUT_LINE (fnd_file.log, proc_name || ':' || sqlerrm);
            p_errnum := -1;
            p_errmesg := (proc_name || ':' || sqlerrm);
            RAISE; -- propagate to calling function

    End Move_Utz_Info ;*/

    /*
        Clean up all the temp tables other than WIP_INDICATORS_TEMP
        that have been used to stage data for better SQL performance.
    */
-- Modified Move_Utz_Info bug -3662056
Procedure Move_Utz_Info(
			p_group_id 	in number,
			p_errnum OUT NOCOPY NUMBER,
			p_errmesg OUT NOCOPY VARCHAR2
			) is
/* ************************************************************
        Cursor to get all the inventory organizations
   ******************************************************** */
   CURSOR All_Orgs is
   SELECT distinct
	  organization_id
   FROM   mtl_parameters
   WHERE  process_enabled_flag <> 'Y'; -- Added to exclude process orgs after R12 uptake

  x_phase   	VARCHAR2(10);
  x_org_id	NUMBER;

begin


   /*
      We do a commit per organization to avoid
      rollback segment problems. Else it is not
      required.
   */

    x_phase := 'I';
	if g_debug = 1 then
		fnd_file.put_line(fnd_file.log, 'Before Stage 7 Phase I');
	end if ;


   FOR Org_Rec IN All_Orgs LOOP

	x_org_id := Org_Rec.organization_id ;

/* Bug 3589936 - Below insert does not take care of shift times when to_time is less
   than from_time for available_units. If the shift starts late night today and ends
   tomorrow morning, then to_time will be less than the from_time. Now added decode
   and sign to take care of the same */

insert into wip_bis_prod_indicators(
	    organization_id,
	    wip_entity_id,
	    operation_seq_num,
	    department_id,
	    department_code,
	    resource_id,
	    resource_code,
	    applied_hours_utz,
	    available_hours,
	    transaction_date,
	    last_update_date,
	    last_updated_by,
	    creation_date,
	    created_by,
	    program_application_id)
	select
	    mnra1.organization_id,
	    null,
	    null,
	    mnra1.department_id,
	    mnra1.department_code,
	    mnra1.resource_id,
	    mnra1.resource_code,
	    null,
            mnra1.available_hours,
	    mnra1.shift_date,
	    sysdate,
 	    g_userid,
	    SYSDATE,
	    g_userid,
	    g_applicationid
	from
	        (select
                   mnra.organization_id organization_id,
	           mnra.department_id department_id,
	           bd.department_code department_code,
	           mnra.resource_id resource_id,
	           br.resource_code resource_code,
                  decode(sum(mnra.shift_num),
                        0, sum(capacity_units)*24,
                        sum(((decode(sign(mnra.to_time - mnra.from_time),
                                  -1, ( 86400 - mnra.from_time ) + mnra.to_time,
                                   1, ( mnra.to_time - mnra.from_time ) , 0 ))/3600)*mnra.capacity_units)) available_hours,
	        trunc(mnra.shift_date) shift_date
                FROM
                        bom_resources br,
                        bom_departments bd,
                        mrp_net_resource_avail mnra,
                        mtl_units_of_measure muom
                where
		        trunc(mnra.shift_date) between trunc(g_date_from) and trunc(g_date_to)
                and     trunc(mnra.shift_date) >= trunc(br.creation_date)
                and 	br.resource_id = mnra.resource_id
                and     br.unit_of_measure = muom.uom_code
                and     muom.uom_class = g_uom_class
                and	br.organization_id = mnra.organization_id
                and 	bd.department_id = mnra.department_id
                and 	bd.organization_id = mnra.organization_id
                and	mnra.organization_id = x_org_id
                group by mnra.organization_id,
		   mnra.department_id,
		   mnra.resource_id,
                   mnra.shift_date,
		   bd.department_code,
                   br.resource_code   )    mnra1
        where not exists
                (select null
                        from wip_indicators_temp wit
                        where   wit.group_id = p_group_id
                        and     wit.indicator_type = WIP_UTILIZATION
                        and	wit.process_phase = WIP_UTZ_PHASE_TWO
                        and     mnra1.shift_date = trunc(wit.transaction_date)
                        and 	mnra1.resource_id = wit.resource_id
                        and	mnra1.department_id = wit.department_id
                        and 	mnra1.organization_id = wit.organization_id );

     -- to avoid large rollback segments
     commit ;

    END LOOP ;


  exception

	when others then
		if g_debug = 1 then
			fnd_file.put_line(fnd_file.log,'Failed in Stage 7 phase : '||x_phase ||
					   ' for Organization_id : '|| to_char(x_org_id) );
			fnd_file.put_line(fnd_file.log, SQLCODE);
			fnd_file.put_line(fnd_file.log,SQLERRM);
		end if ;
		----dbms_output.put_line('Failed in Stage 7 phase : '||x_phase ||
		--			' for Organization_id : ' || to_char(x_org_id));
		----dbms_output.put_line(SQLCODE);
		----dbms_output.put_line(SQLERRM);
		p_errnum := -1 ;
		p_errmesg := 'Failed in Stage 5 Phase : '||x_phase|| ' for Organization_id : ' ||
				to_char(x_org_id) || ' ' || substr(SQLERRM,1,105);
		Delete_Temp_Info(p_group_id=>p_group_Id);
		delete from wip_bis_prod_indicators
		where existing_flag is null ;
		delete from wip_bis_prod_dept_yield
		where existing_flag is null ;
		commit ;
		return ;


End Move_Utz_Info ;


    PROCEDURE Post_Move_CleanUp(
        p_group_id  IN  NUMBER,
        p_errnum    OUT NOCOPY NUMBER,
        p_errmesg   OUT NOCOPY VARCHAR2 )
    IS

        x_phase  VARCHAR2(10);

    BEGIN


        x_phase := 'I';
        IF g_debug = 1 THEN
            fnd_file.put_line(fnd_file.log, 'Before Stage 9 Phase I');
        END IF ;

        -- clean out all the temp tables.
        EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || g_wip_schema ||
                          '.WIP_BIS_MNRA_TEMP';

        EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || g_wip_schema ||
                          '.WIP_BIS_EFF_TEMP';

        EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || g_wip_schema ||
                          '.WIP_BIS_UTZ_TEMP';

        EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || g_wip_schema ||
                          '.WIP_BIS_YLD_TEMP';

	IF g_debug = 1 THEN
            fnd_file.put_line(fnd_file.log, 'After Stage 9 Phase I');
        END IF ;

        p_errnum := 0;
        p_errmesg := '';

        RETURN ;

    EXCEPTION

        WHEN OTHERS THEN

            IF g_debug = 1 THEN
                fnd_file.put_line(fnd_file.log,
                                  'Failed in Post_Move_Cleanup in Stage 9 phase : '||x_phase);
                fnd_file.put_line(fnd_file.log, SQLCODE);
                fnd_file.put_line(fnd_file.log,SQLERRM);
            END IF ;
            ----dbms_output.put_line('Failed in Stage 9 phase : '||x_phase);
            ----dbms_output.put_line(SQLCODE);
            ----dbms_output.put_line(SQLERRM);

            p_errnum := -1 ;
            p_errmesg := 'Failed in Stage 9 Phase : '||x_phase||substr(SQLERRM,1,125);

            -- returns to populate_summary_table, so don't raise exception.

    END Post_Move_CleanUp ;


    /*
        Truncate all the indicator data collected in this run of the
        program.
    */
    PROCEDURE Delete_Temp_Info (p_group_id in number)
    IS

    BEGIN
        IF NOT (fnd_installation.get_app_info(
            'WIP', g_status, g_industry, g_wip_schema)) THEN

            RAISE_APPLICATION_ERROR (-20000,
                                     'Unable to get session information.');

        END IF;

       EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || g_wip_schema ||
                         '.WIP_INDICATORS_TEMP';

    EXCEPTION
        WHEN OTHERS THEN
            fnd_file.put_line(fnd_file.log,'Failed in Delete_Temp_Info.');
            fnd_file.put_line(fnd_file.log, SQLCODE);
            fnd_file.put_line(fnd_file.log,SQLERRM);
            ----dbms_output.put_line('Failed in Delete_Temp_Info. ');
            ----dbms_output.put_line(SQLCODE);
            ----dbms_output.put_line(SQLERRM);

            RAISE; -- send to wrapper

    END Delete_Temp_Info;

    /*
        Clean up all staging tables and base tables. Assuming that any backing
        up of base tables has already been performed.
    */
    PROCEDURE Pre_Program_CleanUp(
        p_errnum    OUT NOCOPY NUMBER,
        p_errmesg   OUT NOCOPY VARCHAR2 )
    IS

    BEGIN

        -- clean out the fact tables after they have been backed up

        EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || g_wip_schema ||
                          '.WIP_BIS_PROD_INDICATORS';

        EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || g_wip_schema ||
                          '.WIP_BIS_PROD_DEPT_YIELD';

        EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || g_wip_schema ||
                          '.WIP_BIS_PROD_ASSY_YIELD';


        -- clean up the temp tables used for staging etc.
        EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || g_wip_schema ||
                          '.WIP_INDICATORS_TEMP';

        EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || g_wip_schema ||
                          '.WIP_BIS_MNRA_TEMP';

        EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || g_wip_schema ||
                          '.WIP_BIS_EFF_TEMP';

        EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || g_wip_schema ||
                          '.WIP_BIS_UTZ_TEMP';

        EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || g_wip_schema ||
                          '.WIP_BIS_YLD_TEMP';


        p_errnum := 0;
        p_errmesg := '';

        RETURN ;

    EXCEPTION

        WHEN OTHERS THEN

            IF g_debug = 1 THEN
                fnd_file.put_line(fnd_file.log,'Failed in pre-program Clean Up');
                fnd_file.put_line(fnd_file.log, SQLCODE);
                fnd_file.put_line(fnd_file.log,SQLERRM);
            END IF;

            ----dbms_output.put_line('Failed in pre-program Clean Up');
            ----dbms_output.put_line(SQLCODE);
            ----dbms_output.put_line(SQLERRM);
            p_errnum := -1 ;
            p_errmesg := 'Failed in pre-program clean up '||substr(SQLERRM,1,125);
            -- returns to populate_summary_table, so don't raise exception.


    END Pre_Program_CleanUp ;



    /* Populate_Assy_Yield
    Calculates the Assembly Yield for the
    organization - It does not make sense
    to calculate the assembly yield from
    a department or resource dimension
    hence no resource or department
    parameters.
    */
    PROCEDURE Populate_Assy_Yield(
            p_organization_id   IN  NUMBER,
            p_date_from         IN  DATE,
            p_date_to           IN  DATE,
            p_userid            IN  NUMBER,
            p_applicationid     IN  NUMBER,
            p_errnum            OUT NOCOPY NUMBER,
            p_errmesg           OUT NOCOPY VARCHAR2)

    IS
        x_group_id  NUMBER;
        x_phase     VARCHAR2(10);
        x_userid    NUMBER;
        x_appl_id   NUMBER;

    BEGIN


        /* As the entry point for this more than a single
           point we have to do the validation in here as
           well. Ex :
            Concurrent Program
            SFCB
        */

        if p_userid is null then
            -- This is an Error Condition
            x_userid :=  fnd_global.user_id ;
        else
            x_userid := p_userid ;
        end if;


        if p_applicationid is null then
            -- This is an Error Condition
            x_appl_id :=  fnd_global.prog_appl_id ;
        else
            x_appl_id := p_applicationid ;
        end if;

        g_userid := x_userid ;
        g_applicationid := x_appl_id ;

        x_phase := 'I';
        if g_debug = 1 then
            fnd_file.put_line(fnd_file.log, 'Before Stage 8 Phase I');
        end if ;
        ----dbms_output.put_line('Before Stage 8 Phase I');


        INSERT INTO wip_bis_prod_assy_yield (
            organization_id,
            wip_entity_id,
            inventory_item_id,
            transaction_date,
            completed_quantity,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by,
            program_application_id)
        SELECT
            organization_id,
            transaction_source_id,
            inventory_item_id,
            trunc (transaction_date),
            sum (primary_quantity),
            sysdate,
            g_userid,
            sysdate,
            g_userid,
            g_applicationid
          FROM
            mtl_material_transactions
          WHERE transaction_source_type_id = 5
            AND transaction_action_id IN  (31,32)
            AND organization_id = nvl(p_organization_id, organization_id)
            AND transaction_date between
                trunc(nvl(p_date_from,transaction_date))
                and trunc(nvl(p_date_to,transaction_date)) + 0.99999
          GROUP BY
            organization_id,
            transaction_source_id,
            inventory_item_id,
            trunc(transaction_date),
            sysdate,
            g_userid,
            sysdate,
            g_userid,
            g_applicationid ;


        x_phase := 'II';
        IF g_debug = 1 THEN
            fnd_file.put_line(fnd_file.log, 'Before Stage 8 Phase II');
        END IF ;
        ----dbms_output.put_line('Before Stage 8 Phase II');

        /* We will not be interested in a movement transaction between
           two scrap transactions for a Job as it evauluates to the
           same amount of assemblies being scrapped for that particular
           job - dsoosai */
        UPDATE  wip_bis_prod_assy_yield wbpay
        SET wbpay.scrap_quantity = (
            SELECT    Nvl(sum(decode(wmt.fm_intraoperation_step_type,
                                 5, -1*(primary_quantity),
                                 decode(wmt.to_intraoperation_step_type,
                                 5, primary_quantity,
                             0 ))),0)
              FROM wip_move_transactions wmt
              WHERE wmt.wip_entity_id = wbpay.wip_entity_id
                AND wmt.organization_id = wbpay.organization_id
                AND trunc(wmt.transaction_date)= trunc(wbpay.transaction_date)
                AND (wmt.fm_intraoperation_step_type = 5
                    OR   wmt.to_intraoperation_step_type = 5
                    AND (wmt.fm_intraoperation_step_type <> wmt.to_intraoperation_step_type))); --3280671
                   -- AND (wmt.fm_intraoperation_step_type <> 5
                     --   AND wmt.to_intraoperation_step_type <> 5 )));

        x_phase := 'III';
        IF g_debug = 1 THEN
            fnd_file.put_line(fnd_file.log, 'Before Stage 8 Phase III');
        END IF ;
        ----dbms_output.put_line('Before Stage 8 Phase III');

        /* This SQL has a full table scan on wip_bis_prod_assy_yield
           because of the trunc operator on the join - if we know a
           way out then we should use it as that will reduce the
           full table scan to be a range scan
        */
        INSERT INTO wip_bis_prod_assy_yield(
            organization_id,
            wip_entity_id,
            inventory_item_id,
            transaction_date,
            completed_quantity,
            scrap_quantity,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by,
            program_application_id )
          SELECT
            wmt.organization_id,
            wmt.wip_entity_id,
            we.primary_item_id,
            trunc(wmt.transaction_date),
            0,
            sum(decode(wmt.fm_intraoperation_step_type,
                   5, -1*(primary_quantity),
                   decode(wmt.to_intraoperation_step_type,
                          5, primary_quantity,
                   0 ))),
            sysdate,
            g_userid,
            sysdate,
            g_userid,
            g_applicationid
          FROM
            wip_entities we,
            wip_move_transactions wmt
          WHERE we.wip_entity_id = wmt.wip_entity_id
            AND we.organization_id = wmt.organization_id
            AND wmt.organization_id = nvl(p_organization_id,
                                          wmt.organization_id)
            AND wmt.transaction_date BETWEEN
                trunc(nvl(p_date_from,wmt.transaction_date))
                AND trunc(nvl(p_date_to,wmt.transaction_date)) + 0.99999
            AND (wmt.fm_intraoperation_step_type = 5
                OR wmt.to_intraoperation_step_type = 5
                AND (wmt.fm_intraoperation_step_type <> wmt.to_intraoperation_step_type)) --3280671
                -- AND (wmt.fm_intraoperation_step_type <> 5
                --AND wmt.to_intraoperation_step_type <> 5))
            AND NOT exists (
              SELECT 'X'
                FROM  wip_bis_prod_assy_yield wbpay1
                WHERE wbpay1.wip_entity_id = wmt.wip_entity_id
                  AND wbpay1.organization_id = wmt.organization_id
                  AND wbpay1.transaction_date BETWEEN
                      trunc(wmt.transaction_date) AND
                      trunc (wmt.transaction_date) + 0.99999)
          GROUP BY
            wmt.organization_id,
            wmt.wip_entity_id,
            we.primary_item_id,
            trunc(wmt.transaction_date),
            0,
            sysdate,
            g_userid,
            sysdate,
            g_userid,
            g_applicationid ;

        COMMIT ;

        x_phase := 'IV';
        IF g_debug = 1 THEN
            fnd_file.put_line(fnd_file.log, 'Before Stage 8 Phase IV');
        END IF ;
        ----dbms_output.put_line('Before Stage 8 Phase IV');

        COMMIT ;

        p_errnum := 0;
        p_errmesg := '';

        RETURN;

    EXCEPTION

        WHEN OTHERS THEN

            IF g_debug = 1 THEN
                fnd_file.put_line(fnd_file.log,
                                  'Failed in Populate_Assy_Yield in Stage 8 phase : '||x_phase);
                fnd_file.put_line(fnd_file.log, SQLCODE);
                fnd_file.put_line(fnd_file.log,SQLERRM);
            END IF ;
            ----dbms_output.put_line('Failed in Stage 8 phase : '||x_phase);
            ----dbms_output.put_line(SQLCODE);
            ----dbms_output.put_line(SQLERRM);
            p_errnum := -1 ;
            p_errmesg := 'Failed in Stage 8 Phase : '||x_phase||
                         substr(SQLERRM,1,125);

            -- to make sure there is no garbage returned to SFCB,
            -- truncate wip_indicators_temp
            Delete_Temp_Info (p_group_id => x_group_id);

            -- returns to populate_summary_table, so don't raise exception.

    END Populate_Assy_Yield;


    /* Calculate_Resource_Avail

    */

    PROCEDURE Calculate_Resource_Avail (
            p_organization_id   IN  NUMBER,
            p_date_from         IN  DATE,
            p_date_to           IN  DATE,
            p_department_id     IN  NUMBER,
            p_resource_id       IN  NUMBER,
            p_errnum            OUT NOCOPY NUMBER,
            p_errmesg           OUT NOCOPY VARCHAR2)
    IS

        x_from_count   NUMBER;
        x_to_count     NUMBER;

    BEGIN

        BEGIN

            SELECT count(*)
            INTO x_from_count
              FROM mrp_net_resource_avail
              WHERE organization_id = p_organization_id
                AND shift_date BETWEEN p_date_from AND p_date_from + 0.99999
                AND simulation_set is null ;

        EXCEPTION

            WHEN NO_DATA_FOUND THEN
                x_from_count := 0 ;
        END;

        BEGIN
            SELECT count(*)
            INTO x_to_count
              FROM mrp_net_resource_avail
              WHERE organization_id = p_organization_id
              AND shift_date BETWEEN p_date_to AND p_date_to +0.99999
              AND simulation_set is null ;

        EXCEPTION

            WHEN NO_DATA_FOUND THEN
                x_to_count := 0 ;
        END;


        IF (x_to_count = 0 ) OR (x_from_count = 0) THEN
            IF g_debug = 1 THEN
                fnd_file.put_line(fnd_file.log,
                                 'Before the MRP calling Phase for Org Id : '
                                  || p_organization_id );
            END IF ;

            /* Because of the MRP limitation we have to get the
               information for the whole Org as such -
               I will ask nsriniva to provide a wrapper function or
               we have to call calc_res_avail ourself to solve this
               issue */

            MRP_RHX_RESOURCE_AVAILABILITY.populate_avail_resources(
                                arg_simulation_set => null,
                                arg_organization_id =>p_organization_id,
                                arg_start_date => p_date_from,
                                arg_cutoff_date  => p_date_to );

        END IF ;

        COMMIT ;

        p_errnum := 0;
        p_errmesg := '';

        RETURN ;

    END Calculate_Resource_Avail;



/*
   This is primarily called from the SFCB - hence we summarize it to
   the resource level as the lowest granularity that you can get for
   availability is the resource level.
   Further this will always entered from an organization hence we would
   never use the All_orgs cursor, but if this is going to be called
   from a concurrent program for OABIS then we might have to open the
   cursor.

   This is currently built so that we can get the resource productivity
   as well as department productivity - but it doesnot have the organization
   productivity - to insert that we need to insert a simple cursor to go
   through all the departments in an organization in bd
*/


Procedure Populate_Productivity(
                        p_group_id          IN  NUMBER,
                        p_organization_id   IN  NUMBER,
                        p_date_from         IN  DATE,
                        p_date_to           IN  DATE,
                        p_department_id     IN  NUMBER,
                        p_resource_id       IN  NUMBER,
                        p_userid            IN  NUMBER,
                        p_applicationid     IN  NUMBER,
            p_errnum        OUT NOCOPY NUMBER,
                        p_errmesg           OUT NOCOPY VARCHAR2)
IS
/**************************************************************
    Cursor to get all valid inventory organizations
**************************************************************/
CURSOR All_Orgs is
SELECT distinct organization_id
FROM   mtl_parameters
WHERE  organization_id = nvl(p_organization_id, organization_id)
AND    process_enabled_flag <> 'Y';	-- Added to exclude process orgs after R12 uptake

  x_date_from   DATE;
  x_date_to     DATE;
  x_group_id    NUMBER;
  x_phase       VARCHAR2(10);
  x_userid      NUMBER;
  x_appl_id     NUMBER;

BEGIN


        /* As the entry point for this more than a single
           point we have to do the validation in here as
           well. Ex :
                        Concurrent Program
                        SFCB
        */

        IF NOT (fnd_installation.get_app_info(
            'WIP', g_status, g_industry, g_wip_schema)) THEN

            RAISE_APPLICATION_ERROR (-20000,
                                     'Unable to get session information.');

        END IF;
        if p_userid is null then
                -- This is an Error Condition
                x_userid :=  fnd_global.user_id ;
        else
                x_userid := p_userid ;
        end if;


        IF p_group_id IS NULL THEN
                select wip_indicators_temp_s.nextval into x_group_id
                from sys.dual ;
        ELSE
                x_group_id := p_group_id ;
        END IF;


        if p_applicationid is null then
                -- This is an Error Condition
                x_appl_id :=  fnd_global.prog_appl_id ;
        else
                x_appl_id := p_applicationid ;
        end if;

        g_userid := x_userid ;
        g_applicationid := x_appl_id ;

        -- Get the UOM code from the profile
        g_uom_code := fnd_profile.value('BOM:HOUR_UOM_CODE');
        select uom_class
    into g_uom_class
        from mtl_units_of_measure
        where uom_code = g_uom_code;

        -- Set up the date ranges if needed
       /* For performance reasons should be just use the
          minimum and maximum date from efficiency */

        IF p_date_from IS NULL THEN
           begin

                select trunc(sysdate)
                into g_date_from
                from dual ;
            end ;

          ELSE
                g_date_from := p_date_from;

          END IF;

          IF p_date_to IS NULL THEN
           begin

                select trunc(max(calendar_date))
                into g_date_to
                from bom_calendar_dates ;

           exception
                when no_data_found then
                        g_date_to := sysdate ;
           end ;

          ELSE
                  g_date_to := p_date_to;
          END IF;

    x_date_from := g_date_from ;
    x_date_to := g_date_to ;


    x_phase := 'I';
/*  if g_debug = 1 then
        fnd_file.put_line(fnd_file.log, 'Before Stage PROD Phase I');
    end if ;
*/
    --dbms_output.put_line('Before Stage PROD Phase I');


    Calculate_Std_Quantity(
        p_group_id => x_group_id,
        p_organization_id => p_organization_id,
        p_date_from => x_date_from,
        p_date_to => x_date_to,
        p_department_id => p_department_id,
        p_indicator => WIP_PRODUCTIVITY) ;



    x_phase := 'II';
/*  if g_debug = 1 then
        fnd_file.put_line(fnd_file.log, 'Before Stage PROD Phase II');
    end if ;
*/
    --dbms_output.put_line('Before Stage PROD Phase II');

    Calculate_Std_Units(
        p_group_id=> x_group_id,
        p_resource_id => p_resource_id,
        p_errnum=> p_errnum,
        p_errmesg => p_errmesg,
        p_indicator => WIP_PRODUCTIVITY) ;


    x_phase := 'III';
/*  if g_debug = 1 then
        fnd_file.put_line(fnd_file.log, 'Before Stage PROD Phase III');
    end if ;
*/
    --dbms_output.put_line('Before Stage PROD Phase III');

    -- This is the stage where we summarize the information at
    -- the resource level and at the next stage we delete the
        -- the unwanted information.
        -- Is this stage required? This is a question that is to
        -- be answered by Serena, as soon as she replies, I will
        -- proceed with checking in this file.


-- ????????? Is this stage required  ?????????????
/* Yes, this stage is required */

insert into wip_indicators_temp(
                group_id,
        organization_id,
        department_id,
        department_code,
        standard_quantity,
        resource_id,
        resource_code,
        transaction_date,
        standard_units,
        indicator_type,
        process_phase,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by,
            program_application_id )
       select
        group_id,
        organization_id,
        department_id,
        department_code,
        sum(standard_quantity),
        resource_id,
        resource_code,
        transaction_date,  -- already trunc'ed
        sum(standard_units),
        WIP_PRODUCTIVITY,
        WIP_PROD_PHASE_FOUR,
        last_update_date,
            last_updated_by,
        creation_date,
            created_by,
            program_application_id
       from wip_indicators_temp
       where indicator_type = WIP_PRODUCTIVITY
       and   process_phase = WIP_PROD_PHASE_THREE
       group by
            group_id,
            organization_id,
            department_id,
            department_code,
            resource_id,
            resource_code,
            transaction_date,
        WIP_PRODUCTIVITY,
        WIP_PROD_PHASE_THREE,   -- This is the third Phase
            last_update_date,
            last_updated_by,
            creation_date,
            created_by,
            program_application_id ;


    -- gather stats on table to allow index access
    If nvl(WIP_CALL_LOG,-1) =1 then
    fnd_stats.gather_table_stats (g_wip_schema, 'WIP_INDICATORS_TEMP',
                                  cascade => true);
    End If;

    x_phase := 'IV';
/*  if g_debug = 1 then
        fnd_file.put_line(fnd_file.log, 'Before Stage PROD Phase IV');
    end if ;
*/
    --dbms_output.put_line('Before Stage PROD Phase IV');

/* Get rid of unsummarized info */
    delete from wip_indicators_temp
    where indicator_type = WIP_PRODUCTIVITY
        and   process_phase = WIP_PROD_PHASE_THREE ;
    -- gather stats on table to allow index access
    If nvl(WIP_CALL_LOG,-1) =1 then
    fnd_stats.gather_table_stats (g_wip_schema, 'WIP_INDICATORS_TEMP',
                                  cascade => true);
    End If;




    -- If we had to call this function from the Concurrent
    -- program and we didn't have a specific organization
    -- then we had to open the All_Org Cursor out here
    -- and have all the logic in this for loop, for
    -- now we don't worry about, as we will be using it
    -- from SFCB    dsoosai 11/10/98


    x_phase := 'V';
/*  if g_debug = 1 then
        fnd_file.put_line(fnd_file.log, 'Before Stage PROD Phase V');
    end if ;
*/
    --dbms_output.put_line('Before Stage PROD Phase V');


        Calculate_Resource_Avail(
        p_organization_id   => p_organization_id,
                p_date_from         => x_date_from,
                p_date_to           => x_date_to,
                p_department_id     => p_department_id,
                p_resource_id       => p_resource_id,
                p_errnum            => p_errnum,
                p_errmesg           => p_errmesg
        ) ;



    x_phase := 'VI';
/*  if g_debug = 1 then
        fnd_file.put_line(fnd_file.log, 'Before Stage PROD Phase VI');
    end if ;
*/
    --dbms_output.put_line('Before Stage PROD Phase VI');


    UPDATE wip_indicators_temp wit
        SET    wit.available_units = (
            select
                --nvl(sum(((to_time-from_time)/3600)*capacity_units),0)
                --  nvl(sum(((decode(sign(to_time - from_time),
                --                           -1, ( 86400 - from_time ) + to_time,
                --                            1, ( to_time - from_time ) ,
                --                            0 ))/3600)*capacity_units),0)
                decode(sum(shift_num),
                         0, nvl(sum(capacity_units)*24,0),
			          nvl(sum(((decode(sign(to_time - from_time),
                                           -1, ( 86400 - from_time ) + to_time,
                                            1, ( to_time - from_time ) ,
                                            0 ))/3600)*capacity_units),0))
            from
                mrp_net_resource_avail mnra
            where
                mnra.organization_id = wit.organization_id
            and mnra.department_id = wit.department_id
            and mnra.resource_id = wit.resource_id
            and     wit.transaction_date between trunc(mnra.shift_date)
                        and trunc (mnra.shift_date) + 0.99999
            and     simulation_set is null
           )
        where wit.indicator_type = WIP_PRODUCTIVITY
        and process_phase = WIP_PROD_PHASE_FOUR ;


    x_phase := 'VII';
/*  if g_debug = 1 then
        fnd_file.put_line(fnd_file.log, 'Before Stage PROD Phase VII');
    end if ;
*/
    --dbms_output.put_line('Before Stage PROD Phase VII');

    insert into wip_indicators_temp(
        group_id,
        organization_id,
        department_id,
        department_code,
        resource_id,
        resource_code,
        standard_units,
        available_units,
        transaction_date,
        indicator_type,
            process_phase,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        program_application_id)
    select
        x_group_id,
        mnra.organization_id,
        mnra.department_id,
        bd.department_code,
        mnra.resource_id,
        br.resource_code,
        null,
        --sum(((mnra.to_time-mnra.from_time)/3600)*mnra.capacity_units),
        --sum(((decode(sign(mnra.to_time - mnra.from_time),
        --                          -1, ( 86400 - mnra.from_time ) + mnra.to_time,
        --                           1, ( mnra.to_time - mnra.from_time ) , 0 ))/3600)*mnra.capacity_units),
        decode(sum(shift_num),
                 0, sum(capacity_units)*24,
                    sum(((decode(sign(mnra.to_time - mnra.from_time),
                                  -1, ( 86400 - mnra.from_time ) + mnra.to_time,
                                   1, ( mnra.to_time - mnra.from_time ) , 0 ))/3600)*mnra.capacity_units)),
        trunc(mnra.shift_date),
        WIP_PRODUCTIVITY,
        WIP_PROD_PHASE_FOUR,
        sysdate,
        g_userid,
        SYSDATE,
        g_userid,
        g_applicationid
    from
        bom_resources br,
        bom_departments bd,
        mrp_net_resource_avail mnra,
        mtl_units_of_measure muom
    where
            mnra.shift_date between trunc(x_date_from) and
                trunc(x_date_to) + 0.99999
    and     br.resource_id = mnra.resource_id
    and     br.unit_of_measure = muom.uom_code
        and     muom.uom_class = g_uom_class
    and br.organization_id = mnra.organization_id
    and     bd.department_id = mnra.department_id
    and     bd.organization_id = mnra.organization_id
    and mnra.organization_id = p_organization_id
    and mnra.department_id = p_department_id
    and mnra.resource_id = nvl(p_resource_id, mnra.resource_id)
    and     mnra.shift_date not in (
        select  distinct transaction_date
        from    wip_indicators_temp wit
        where wit.resource_id = nvl(p_resource_id, wit.resource_id)
        and wit.department_id = p_department_id
        and     wit.organization_id = p_organization_id
        and wit.indicator_type = WIP_PRODUCTIVITY
        and     wit.process_phase = WIP_PROD_PHASE_FOUR
        and wit.transaction_date between
            trunc(x_date_from) and  trunc(x_date_to) + 0.99999
        )
    group by
           x_group_id,
           mnra.organization_id,
           mnra.department_id,
           bd.department_code,
           mnra.resource_id,
           br.resource_code,
           null,
           trunc(mnra.shift_date),
               WIP_PRODUCTIVITY,
               WIP_PROD_PHASE_FOUR,
           sysdate,
           g_userid,
           SYSDATE,
           g_userid,
           g_applicationid ;

    -- gather stats on table to allow index access
    If nvl(WIP_CALL_LOG,-1) =1 then
    fnd_stats.gather_table_stats (g_wip_schema, 'WIP_INDICATORS_TEMP',
                                  cascade => true);
    End IF;

EXCEPTION
          WHEN OTHERS THEN
/*
                if g_debug = 1 then
                        fnd_file.put_line(fnd_file.log,'Failed in Productivity phase : '||x_phase);
                        fnd_file.put_line(fnd_file.log, SQLCODE);
                        fnd_file.put_line(fnd_file.log,SQLERRM);
                end if ;
*/
                --dbms_output.put_line('Failed in Productivity phase : '||x_phase);
                --dbms_output.put_line(SQLCODE);
                --dbms_output.put_line(SQLERRM);
                p_errnum := -1 ;
                p_errmesg := 'Failed in Productivity Phase : '||x_phase||substr(SQLERRM,1,125);
                Delete_Temp_Info(p_group_id=>x_group_Id);
                commit ;
                return ;

End Populate_Productivity ;





/*
   This is primarily called from the SFCB - hence we summarize it to
   the resource level as the lowest granularity that you can get for
   availability is the resource level.
   Further this will always entered from an organization hence we would
   never use the All_orgs cursor, but if this is going to be called
   from a concurrent program for OABIS then we might have to open the
   cursor.
*/

PROCEDURE Populate_Resource_Load (
                        p_group_id          IN  NUMBER,
                        p_organization_id   IN  NUMBER,
                        p_date_from         IN  DATE,
                        p_date_to           IN  DATE,
                        p_department_id     IN  NUMBER,
                        p_resource_id       IN  NUMBER,
                        p_userid            IN  NUMBER,
                        p_applicationid     IN  NUMBER,
                        p_errnum            OUT NOCOPY NUMBER,
                p_errmesg           OUT NOCOPY VARCHAR2)
IS
/* ***********************************************************************
        Cursor to get all the department, resources within an Organization
   ***********************************************************************/
CURSOR All_Dept_Resources(
    p_organization_id IN NUMBER,
    p_department_id   IN NUMBER,
        p_resource_id     IN NUMBER,
    p_uom_code        IN VARCHAR2
    ) IS
select  distinct organization_id, department_id, resource_id
from    bom_department_resources_v bdrv,
    mtl_units_of_measure muom
where   bdrv.organization_id = nvl(p_organization_id, organization_id)
and bdrv.department_id  = nvl(p_department_id, department_id)
and bdrv.resource_id    = nvl(p_resource_id, resource_id)
AND     bdrv.unit_of_measure = muom.uom_code
and     muom.uom_class  = g_uom_class
AND     bdrv.share_from_dept_id IS null  ;




/**************************************************************
    Cursor to get all valid inventory organizations
**************************************************************/
CURSOR All_Orgs is
SELECT distinct organization_id
FROM   mtl_parameters
WHERE  organization_id = nvl(p_organization_id, organization_id)
AND    process_enabled_flag <> 'Y';  -- Added to exclude process orgs after R12 uptake

  x_date_from   DATE;
  x_date_to     DATE;
  x_sim_date_from DATE;
  x_sim_date_to DATE;
  x_group_id    NUMBER;
  x_phase       VARCHAR2(10);
  x_userid      NUMBER;
  x_appl_id     NUMBER;


BEGIN

        /* As the entry point for this more than a single
           point we have to do the validation in here as
           well. Ex :
                        Concurrent Program
                        SFCB
        */

        IF NOT (fnd_installation.get_app_info(
            'WIP', g_status, g_industry, g_wip_schema)) THEN

            RAISE_APPLICATION_ERROR (-20000,
                                     'Unable to get session information.');

        END IF;
        if p_userid is null then
                -- This is an Error Condition
                x_userid :=  fnd_global.user_id ;
        else
                x_userid := p_userid ;
        end if;


        IF p_group_id IS NULL THEN
                select wip_indicators_temp_s.nextval into x_group_id
                from sys.dual ;
    ELSE

                x_group_id := p_group_id ;
        END IF;


        if p_applicationid is null then
                -- This is an Error Condition
                x_appl_id :=  fnd_global.prog_appl_id ;
        else
                x_appl_id := p_applicationid ;
        end if;

        g_userid := x_userid ;
        g_applicationid := x_appl_id ;

        -- Get the UOM code from the profile
        g_uom_code := fnd_profile.value('BOM:HOUR_UOM_CODE');
        select uom_class
        into g_uom_class
        from mtl_units_of_measure
        where uom_code = g_uom_code;

        -- Set up the date ranges if needed
       /* For performance reasons should be just use the
          minimum and maximum date from efficiency */

        IF p_date_from IS NULL THEN
           begin

                select trunc(sysdate)
                into g_date_from
                from dual ;
            end ;

          ELSE
                g_date_from := p_date_from;

          END IF;

          IF p_date_to IS NULL THEN
           begin

                select trunc(max(calendar_date))
                into g_date_to
                from bom_calendar_dates ;

           exception
                when no_data_found then
                        g_date_to := sysdate ;
           end ;

          ELSE
                  g_date_to := p_date_to;
          END IF;

    x_date_from := g_date_from ;
    x_date_to := g_date_to ;

    begin

        select  trunc(min(start_date)), trunc(max(completion_date))
        into    x_sim_date_from, x_sim_date_to
        from    wip_operation_resources
        where   trunc(start_date) between trunc(x_date_from)
                and trunc(x_date_to)
        or  trunc(completion_date) between trunc(x_date_from)
                and trunc(x_date_to) ;

    exception
      when others then
        x_sim_date_from := x_date_from ;
        x_sim_date_to := x_date_to ;

    end ;

    -- If we had to call this function from the Concurrent
    -- program and we didn't have a specific organization
    -- then we had to open the All_Org Cursor out here
    -- and have all the logic in this for loop, for
    -- now we don't worry about, as we will be using it
    -- from SFCB    dsoosai 11/10/98

    x_phase := 'I';
/*  if g_debug = 1 then
        fnd_file.put_line(fnd_file.log, 'Before Stage  RL Phase I');
    end if ;
*/
    --dbms_output.put_line('Before Stage RL Phase I');

        Calculate_Resource_Avail(
        p_organization_id => p_organization_id,
                p_date_from         => x_sim_date_from,
                p_date_to           => x_sim_date_to,
                p_department_id     => p_department_id,
                p_resource_id       => p_resource_id,
                p_errnum            => p_errnum,
                p_errmesg           => p_errmesg
        ) ;


        FOR Dept_Res_Rec IN All_Dept_Resources(
        p_organization_id => p_organization_id,
        p_department_id   => p_department_id,
        p_resource_id     => p_resource_id,
                p_uom_code        => g_uom_code
        ) LOOP


    x_phase := 'II';
/*
    if g_debug = 1 then
        fnd_file.put_line(fnd_file.log, 'Before Stage  RL Phase II');
    end if ;
*/

    insert into wip_indicators_temp (
           group_id,
           organization_id,
           resource_id,
           resource_code,
           department_id,
           department_code,
           transaction_date,
           available_units,
           required_hours,
           indicator_type,
           process_phase,
           last_update_date,
           last_updated_by,
           creation_date,
           created_by,
           program_application_id )
    select
           x_group_id,
           wor.organization_id,
           wor.resource_id,
           wor.resource_code,
           bdr.department_id,
           bd.department_code,
           mnra.shift_date,
           null,
decode(sign(sum(inv_convert.inv_um_convert(0,NULL,decode(wor.basis_type,
                  1,
                 NVL((wor.usage_rate_or_amount*wo.scheduled_quantity
                     - nvl(wor.applied_resource_units,0)),0)*
                 get_Workday_Ratio(wor.resource_id, wor.organization_id,trunc(wor.start_date), trunc(wor.completion_date), trunc(mnra.shift_date)),
               DECODE(nvl(wor.applied_resource_units,0),
                  0,
                      decode(trunc(wor.start_date),
                     trunc(mnra.shift_date),
                         NVL(wor.usage_rate_or_amount,0),
                         0),
                  0)
                ),wor.uom_code,g_uom_code,NULL,NULL
            ))),1,sum(inv_convert.inv_um_convert(0,NULL,decode(wor.basis_type,
                  1,
                 NVL((wor.usage_rate_or_amount*wo.scheduled_quantity
                     - nvl(wor.applied_resource_units,0)),0)*
                 get_Workday_Ratio(wor.resource_id, wor.organization_id,trunc(wor.start_date), trunc(wor.completion_date), trunc(mnra.shift_date)),
               DECODE(nvl(wor.applied_resource_units,0),
                  0,
                      decode(trunc(wor.start_date),
                     trunc(mnra.shift_date),
                         NVL(wor.usage_rate_or_amount,0),
                         0),
                  0)
                ),wor.uom_code,g_uom_code,NULL,NULL
            )),0)  "Required",
           WIP_RESOURCE_LOAD, -- Indicator Type
           WIP_RL_PHASE_ONE, -- process phase
           sysdate,
           g_userid,
           sysdate,
           g_userid,
           g_applicationid
    from
        mrp_net_resource_avail mnra,
        bom_departments bd,
        bom_department_resources bdr,
            wip_operations_v wo,
        wip_operation_resources_v wor,
        wip_discrete_jobs wdj
    where
        wdj.wip_entity_id = wor.wip_entity_id
    and wdj.organization_id = wor.organization_id
    and     wdj.status_type in (1, 3, 6 ) -- unreleased, released and hold
        and     mnra.simulation_set is null
    and mnra.resource_id = wor.resource_id
    and mnra.organization_id = wor.organization_id
    and wor.organization_id = nvl(Dept_Res_Rec.Organization_id, wor.organization_id)
    and     wor.resource_id = nvl(Dept_Res_Rec.resource_id, wor.resource_id)
    and mnra.shift_date between trunc(wor.start_date) and trunc(wor.completion_date) + 0.99999
    and (   (  wor.start_date between trunc(x_date_from)
                   and trunc(x_date_to) + 0.99999
             )
         or ( wor.completion_date between trunc(x_date_from)
                   and trunc(x_date_to) + 0.99999
            )
         or ( wor.start_date < trunc(x_date_from) + 0.99999 and
              wor.completion_date > trunc(x_date_to) + 0.99999
            )
        )
    and     mnra.shift_date between trunc(x_date_from)
        and trunc(x_date_to) + 0.99999
    and wo.wip_entity_id = wor.wip_entity_id
    and wo.organization_id = wor.organization_id
    and     wo.operation_seq_num = wor.operation_seq_num
    and     nvl(wo.repetitive_schedule_id,-999) = nvl(wor.repetitive_schedule_id, -999)
    and     bdr.resource_id = wor.resource_id
    and     bdr.share_from_dept_id is null
    and bdr.department_id = nvl(Dept_Res_rec.department_id, bdr.department_id)
    and bd.organization_id = wor.organization_id
    and bd.department_id = bdr.department_id
    group by
        x_group_id,
        wor.organization_id,
        wor.resource_id,
        wor.resource_code,
        bdr.department_id,
        bd.department_code,
        mnra.shift_date,
        null,
        WIP_RESOURCE_LOAD,
        WIP_RL_PHASE_ONE,
        sysdate,
        g_userid,
        sysdate,
        g_userid,
        g_applicationid ;


/*
    x_phase := 'III';
    if g_debug = 1 then
        fnd_file.put_line(fnd_file.log, 'Before Stage  RL Phase III');
    end if ;
*/



        UPDATE wip_indicators_temp wit
        SET    wit.available_units = (
            select
              --  nvl(sum(((to_time-from_time)/3600)*capacity_units),0) --BUG - 3565583
              --    nvl(sum(((decode(sign(to_time - from_time),
              --                            -1, ( 86400 - from_time ) + to_time,
              --                             1, ( to_time - from_time ) ,
              --                             0 ))/3600)*capacity_units),0)
              decode(sum(shift_num),
                        0, nvl(sum(capacity_units)*24,0),
				   nvl(sum(((decode(sign(to_time - from_time),
                                          -1, ( 86400 - from_time ) + to_time,
                                           1, ( to_time - from_time ) ,
                                           0 ))/3600)*capacity_units),0))
            from
                mrp_net_resource_avail mnra
            where
                mnra.organization_id = wit.organization_id
            and mnra.department_id = wit.department_id
            and mnra.resource_id = wit.resource_id
            and wit.transaction_date between trunc(mnra.shift_date)
                    and trunc (mnra.shift_date) + 0.99999
            and     simulation_set is null
           )
        where wit.organization_id = Dept_Res_Rec.organization_id
        AND   wit.department_id = Dept_Res_Rec.department_id
        AND   wit.resource_id = Dept_Res_Rec.resource_id
        and   wit.indicator_type = WIP_RESOURCE_LOAD
        and   process_phase = WIP_RL_PHASE_ONE ;


/*
    x_phase := 'IV';
    if g_debug = 1 then
        fnd_file.put_line(fnd_file.log, 'Before Stage  RL Phase IV');
    end if ;
*/


    insert into wip_indicators_temp(
        group_id,
        organization_id,
        department_id,
        department_code,
        resource_id,
        resource_code,
        required_hours,
        available_units,
        transaction_date,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        program_application_id)
    select
        x_group_id,
        mnra.organization_id,
        mnra.department_id,
        bd.department_code,
        mnra.resource_id,
        br.resource_code,
        null,
       -- sum(((mnra.to_time-mnra.from_time)/3600)*mnra.capacity_units), --BUG - 3565583
       -- sum(((decode(sign(mnra.to_time - mnra.from_time),
       --                           -1, ( 86400 - mnra.from_time ) + mnra.to_time,
       --                            1, ( mnra.to_time - mnra.from_time ) , 0 ))/3600)*mnra.capacity_units),
        decode(sum(mnra.shift_num),
                 0, sum(capacity_units)*24,
                    sum(((decode(sign(mnra.to_time - mnra.from_time),
                                  -1, ( 86400 - mnra.from_time ) + mnra.to_time,
                                   1, ( mnra.to_time - mnra.from_time ) , 0 ))/3600)*mnra.capacity_units)),
        trunc(mnra.shift_date),
        sysdate,
        g_userid,
        SYSDATE,
        g_userid,
        g_applicationid
    from
        bom_resources br,
        bom_departments bd,
        mrp_net_resource_avail mnra,
        mtl_units_of_measure muom
    where
            mnra.shift_date between trunc(x_date_from) and
        trunc(x_date_to) + 0.99999
    and     br.resource_id = mnra.resource_id
    and     br.unit_of_measure = muom.uom_code
    and     muom.uom_class  = g_uom_class
    and br.organization_id = mnra.organization_id
    and     bd.department_id = mnra.department_id
    and     bd.organization_id = mnra.organization_id
    and mnra.organization_id = Dept_Res_Rec.organization_id
    and mnra.department_id = Dept_Res_Rec.department_id
    and mnra.resource_id = Dept_Res_Rec.resource_id
    and     mnra.shift_date not in (
        select  distinct transaction_date
        from    wip_indicators_temp wit
        where wit.resource_id = Dept_Res_Rec.resource_id
        and wit.department_id = Dept_Res_Rec.department_id
        and     wit.organization_id = Dept_Res_Rec.organization_id
        and wit.indicator_type = WIP_RESOURCE_LOAD
        and     wit.process_phase = WIP_RL_PHASE_ONE
        and wit.transaction_date between
            trunc(x_date_from) and  trunc(x_date_to) + 0.99999
        )
    group by
           x_group_id,
           mnra.organization_id,
           mnra.department_id,
           bd.department_code,
           mnra.resource_id,
           br.resource_code,
           trunc(mnra.shift_date),
           sysdate,
           g_userid,
           SYSDATE,
           g_userid,
           g_applicationid ;


     END LOOP ;

    -- gather stats on table to allow index access
    If nvl(WIP_CALL_LOG,-1) =1 then
    fnd_stats.gather_table_stats (g_wip_schema, 'WIP_INDICATORS_TEMP',
                                  cascade => true);
    End If;


EXCEPTION
          WHEN OTHERS THEN
/*
                if g_debug = 1 then
                        fnd_file.put_line(fnd_file.log,'Failed in Resource Load phase : '||x_phase);
                        fnd_file.put_line(fnd_file.log, SQLCODE);
                        fnd_file.put_line(fnd_file.log,SQLERRM);
                end if ;
*/
                --dbms_output.put_line('Failed in Resource Load phase : '||x_phase);
                --dbms_output.put_line(SQLCODE);
                --dbms_output.put_line(SQLERRM);
                p_errnum := -1 ;
                p_errmesg := 'Failed in Resource Load Phase : '||x_phase||substr(SQLERRM,1,125);
                Delete_Temp_Info(p_group_id=>x_group_Id);
                commit ;
                return ;

End Populate_Resource_Load ;





Procedure Move_SFCB_Utz_Info(
                        p_group_id          IN  NUMBER,
                        p_organization_id   IN  NUMBER,
                        p_date_from         IN  DATE,
                        p_date_to           IN  DATE,
                        p_department_id     IN  NUMBER,
                        p_resource_id       IN  NUMBER,
                        p_userid            IN  NUMBER,  -- this parameter is not really needed
                        p_applicationid     IN  NUMBER,  -- this parameter is not really needed
            p_errnum        OUT NOCOPY NUMBER,
                        p_errmesg           OUT NOCOPY VARCHAR2)
IS
/* ***********************************************************************
        Cursor to get all the department, resources within an Organization
   ***********************************************************************/
CURSOR All_Dept_Resources(
    p_organization_id IN NUMBER,
    p_department_id   IN NUMBER,
    p_resource_id     IN NUMBER,
        p_date_from   IN DATE,
    p_date_to     IN DATE
    ) IS
select  distinct organization_id, department_id, resource_id
from    mrp_net_resource_avail
where   organization_id = nvl(p_organization_id, organization_id)
and department_id   = nvl(p_department_id, department_id)
and resource_id = nvl(p_resource_id, resource_id)
and     trunc(shift_date) between trunc(p_date_from)
    and trunc(p_date_to)
and simulation_set is null ;

x_phase       VARCHAR2(10);
BEGIN


    -- If we had to call this function from the Concurrent
    -- program and we didn't have a specific organization
    -- then we had to open the All_Org Cursor out here
    -- and have all the logic in this for loop, for
    -- now we don't worry about, as we will be using it
    -- from SFCB    dsoosai 11/10/98

    FOR Dept_Res_Rec IN All_Dept_Resources(
        p_organization_id => p_organization_id,
        p_department_id   => p_department_id,
        p_resource_id     => p_resource_id,
            p_date_from   => p_date_from,
        p_date_to     => p_date_to
    ) LOOP


    x_phase := 'I';
    if g_debug = 1 then
        fnd_file.put_line(fnd_file.log, 'Before Stage MSUI Phase IN I');
    end if ;


    --dbms_output.put_line('Before Stage MSUI Phase I');

    insert into wip_indicators_temp(
        group_id,
        organization_id,
        department_id,
        department_code,
        resource_id,
        resource_code,
        applied_units_utz,
        available_units,
        transaction_date,
        indicator_type,
        process_phase,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        program_application_id)
    select
        p_group_id,
        mnra.organization_id,
        mnra.department_id,
        bd.department_code,
        mnra.resource_id,
        br.resource_code,
        null,
        --sum(((mnra.to_time-mnra.from_time)/3600)*mnra.capacity_units), --BUG - 3581581
        --  sum(((decode(sign(mnra.to_time - mnra.from_time),
        --                          -1, ( 86400 - mnra.from_time ) + mnra.to_time,
        --                           1, ( mnra.to_time - mnra.from_time ) , 0 ))/3600)*mnra.capacity_units),
        decode(sum(mnra.shift_num),
                 0, sum(capacity_units)*24,
	              sum(((decode(sign(mnra.to_time - mnra.from_time),
                                  -1, ( 86400 - mnra.from_time ) + mnra.to_time,
                                   1, ( mnra.to_time - mnra.from_time ) , 0 ))/3600)*mnra.capacity_units)),
        trunc(mnra.shift_date),
        WIP_UTILIZATION,
        WIP_UTZ_PHASE_TWO,
        sysdate,
        g_userid,
        SYSDATE,
        g_userid,
        g_applicationid
    from
        bom_resources br,
        bom_departments bd,
        mrp_net_resource_avail mnra,
        mtl_units_of_measure muom
    where
            mnra.shift_date between trunc(p_date_from) and
        trunc(p_date_to) + 0.99999
    and     br.resource_id = mnra.resource_id
    and     br.unit_of_measure = muom.uom_code
    and     muom.uom_class = g_uom_class
    and br.organization_id = mnra.organization_id
    and     bd.department_id = mnra.department_id
    and     bd.organization_id = mnra.organization_id
    and mnra.organization_id = Dept_Res_Rec.organization_id
    and mnra.department_id = Dept_Res_Rec.department_id
    and mnra.resource_id = Dept_Res_Rec.resource_id
    and     mnra.shift_date not in (
        select  distinct transaction_date
        from    wip_indicators_temp wit
        where wit.resource_id = Dept_Res_Rec.resource_id
        and wit.department_id = Dept_Res_Rec.department_id
        and     wit.organization_id = Dept_Res_Rec.organization_id
        and wit.indicator_type = WIP_UTILIZATION
        and     wit.process_phase = WIP_UTZ_PHASE_TWO
        and wit.transaction_date between
            trunc(p_date_from) and  trunc(p_date_to) + 0.99999
        )
    group by
           p_group_id,
           mnra.organization_id,
           mnra.department_id,
           bd.department_code,
           mnra.resource_id,
           br.resource_code,
           trunc(mnra.shift_date),
           sysdate,
           g_userid,
           SYSDATE,
           g_userid,
           g_applicationid ;

    END LOOP ;

    commit ;

    -- gather stats on table to allow index access
    If nvl(WIP_CALL_LOG,-1) =1 then
    fnd_stats.gather_table_stats (g_wip_schema, 'WIP_INDICATORS_TEMP',
                                  cascade => true);
    End If;

    p_errnum := 0;
    p_errmesg := '';

    return ;

EXCEPTION

          WHEN OTHERS THEN
                 if g_debug = 1 then
                        fnd_file.put_line(fnd_file.log,'Failed in MSUI phase : '||x_phase);
                        fnd_file.put_line(fnd_file.log, SQLCODE);
                        fnd_file.put_line(fnd_file.log,SQLERRM);
                end if ;

                --dbms_output.put_line('Failed in MSUI phase : '||x_phase);
                --dbms_output.put_line(SQLCODE);
                --dbms_output.put_line(SQLERRM);
                p_errnum := -1 ;
                p_errmesg := 'Failed in MSUI Phase : '||x_phase||substr(SQLERRM,1,125);
                Delete_Temp_Info(p_group_id=>p_group_Id);
                commit ;
                return ;

End Move_SFCB_Utz_Info ;



function get_Workday_Ratio
                       (p_resource_id      IN  NUMBER,
                        p_organization_id  IN  NUMBER,
                        p_start_date       IN  DATE,
                        p_completion_date  IN  DATE,
            p_transaction_date IN  DATE )
return NUMBER IS
   x_no_of_day_shifts NUMBER;
   x_total_days NUMBER ;
   x_workday_ratio    NUMBER ;
BEGIN



        begin

                select
                        nvl(count(*),0)
                into
                        x_no_of_day_shifts
                from
                        mrp_net_resource_avail
                where resource_id = p_resource_id
                and   organization_id = p_organization_id
                and   simulation_set is null
                and   shift_date = p_transaction_date ;

        exception
           when others then
                x_no_of_day_shifts := 1 ;

        end ;

        begin

                select
                        nvl(count(distinct shift_date),0)
                into
                        x_total_days
                from
                        mrp_net_resource_avail
                where resource_id = p_resource_id
                and   organization_id = p_organization_id
                and   simulation_set is null
                and   shift_date between p_start_date and p_completion_date ;

        exception
           when others then
                x_total_days := 0 ;

        end ;


     /********************************************************
     *   We have to use the number of Day shifts as we have the
     *   same day information will be called in multiple times
     *********************************************************/

     x_workday_ratio := ((1/x_total_days)/x_no_of_day_shifts);

     return x_workday_ratio ;

End get_Workday_Ratio ;



    /* Populate_Denormalize_Data

    This populates the denormalized data into the the following
    tables of the following types:

        1. Wip_bis_prod_indicators
            -- organization
            -- item
            -- time
            -- geographical location
        2. Wip_bis_prod_dept_yield
            -- organization
            -- time
            -- geographical location
            (Note item is not denormalized here)
        3. Wip_bis_prod_assy_yield
            -- organization
            -- item
            -- time
            -- geographical location

    */

    PROCEDURE Populate_Denormalize_Data(
            p_errnum    IN OUT NOCOPY NUMBER,
            p_errmesg   IN OUT NOCOPY VARCHAR2)
    IS
        x_phase VARCHAR2(10);
    BEGIN


        /**********************
        WIP_BIS_PROD_INDICATORS
        **********************/
        x_phase := 'I';

        if g_debug = 1 then
            fnd_file.put_line(fnd_file.log, 'Before Stage 10 Phase IN I');
        end if ;

        denormalize_item_dimension(
                p_table_name => 'wip_bis_prod_indicators',
                p_errnum => p_errnum,
                p_errmesg => p_errmesg );
        commit;

        x_phase := 'II';

        if g_debug = 1 then
            fnd_file.put_line(fnd_file.log, 'Before Stage 10 Phase IN II');
        end if ;

        denormalize_org_dimension(
                p_table_name => 'wip_bis_prod_indicators',
                p_errnum => p_errnum,
                p_errmesg => p_errmesg );
     /*   denormalize_time_dimension(
                p_table_name => 'wip_bis_prod_indicators',
                p_errnum => p_errnum,
                p_errmesg => p_errmesg );*/
        commit;

        x_phase := 'III';

        if g_debug = 1 then
            fnd_file.put_line(fnd_file.log, 'Before Stage 10 Phase IN III');
        end if ;
        denormalize_time_dimension(
                p_table_name => 'wip_bis_prod_indicators',
                p_errnum => p_errnum,
                p_errmesg => p_errmesg );
      /*  denormalize_org_dimension(
                p_table_name => 'wip_bis_prod_indicators',
                p_errnum => p_errnum,
                p_errmesg => p_errmesg );*/
        commit;

        x_phase := 'IV';

        if g_debug = 1 then
            fnd_file.put_line(fnd_file.log, 'Before Stage 10 Phase IN IV');
        end if ;

        denormalize_geo_dimension(
                p_table_name => 'wip_bis_prod_indicators',
                p_errnum => p_errnum,
                p_errmesg => p_errmesg );
        commit;

        /**********************
        WIP_BIS_PROD_DEPT_YIELD
        **********************/
        -- do not denormalize the item information for departmentyYield

        x_phase := 'V';

        if g_debug = 1 then
            fnd_file.put_line(fnd_file.log, 'Before Stage 10 Phase IN V');
        end if ;
         denormalize_org_dimension(
                p_table_name => 'wip_bis_prod_dept_yield',
                p_errnum => p_errnum,
                p_errmesg => p_errmesg );
      /*  denormalize_time_dimension(
                p_table_name => 'wip_bis_prod_dept_yield',
                p_errnum => p_errnum,
                p_errmesg => p_errmesg );*/
        commit;

        x_phase := 'VI';

        if g_debug = 1 then
            fnd_file.put_line(fnd_file.log, 'Before Stage 10 Phase IN VI');
        end if ;
        denormalize_time_dimension(
                p_table_name => 'wip_bis_prod_dept_yield',
                p_errnum => p_errnum,
                p_errmesg => p_errmesg );
       /* denormalize_org_dimension(
                p_table_name => 'wip_bis_prod_dept_yield',
                p_errnum => p_errnum,
                p_errmesg => p_errmesg );*/
        commit;

        x_phase := 'VII';

        if g_debug = 1 then
            fnd_file.put_line(fnd_file.log, 'Before Stage 10 Phase IN VII');
        end if ;

        denormalize_geo_dimension(
                p_table_name => 'wip_bis_prod_dept_yield',
                p_errnum => p_errnum,
                p_errmesg => p_errmesg );
        commit;


        /**********************
        WIP_BIS_PROD_ASSY_YIELD
        **********************/

        x_phase := 'VIII';

        if g_debug = 1 then
            fnd_file.put_line(fnd_file.log, 'Before Stage 10 Phase IN VIII');
        end if ;

        denormalize_item_dimension(
                p_table_name => 'wip_bis_prod_assy_yield',
                p_errnum => p_errnum,
                p_errmesg => p_errmesg );
        commit;

        x_phase := 'IX';

        if g_debug = 1 then
            fnd_file.put_line(fnd_file.log, 'Before Stage 10 Phase IN IX');
        end if ;
        denormalize_org_dimension(
                p_table_name => 'wip_bis_prod_assy_yield',
                p_errnum => p_errnum,
                p_errmesg => p_errmesg );
       /* denormalize_time_dimension(
                p_table_name => 'wip_bis_prod_assy_yield',
                p_errnum => p_errnum,
                p_errmesg => p_errmesg );*/
        commit;

        x_phase := 'X';

        if g_debug = 1 then
            fnd_file.put_line(fnd_file.log, 'Before Stage 10 Phase IN X');
        end if ;
        denormalize_time_dimension(
                p_table_name => 'wip_bis_prod_assy_yield',
                p_errnum => p_errnum,
                p_errmesg => p_errmesg );
        /*denormalize_org_dimension(
                p_table_name => 'wip_bis_prod_assy_yield',
                p_errnum => p_errnum,
                p_errmesg => p_errmesg );*/
        commit;

        x_phase := 'XI';

        if g_debug = 1 then
            fnd_file.put_line(fnd_file.log, 'Before Stage 10 Phase IN XI');
        end if ;

        denormalize_geo_dimension(
                p_table_name => 'wip_bis_prod_assy_yield',
                p_errnum => p_errnum,
                p_errmesg => p_errmesg );
        commit;

        p_errnum := 0;
        p_errmesg := '';

        return;

    EXCEPTION

        WHEN OTHERS THEN
            if g_debug = 1 then
                fnd_file.put_line(fnd_file.log,'Failed in PDD phase : '||
                                  x_phase);
                fnd_file.put_line(fnd_file.log, SQLCODE);
                fnd_file.put_line(fnd_file.log,SQLERRM);
            end if ;
            p_errnum := -1 ;
            p_errmesg := 'Failed in PDD Phase : '||x_phase||substr(SQLERRM,1,125);

            -- returns to populate_summary_table, so don't raise exception.

    END populate_denormalize_data ;

    /**************************************************************
    * This procedure will denormalize the item dimension for a given
    * table - the table name is given as an input parameter. It
    * makes the following assumptions about the columns that needs
    * to be updated :
    *   1. Inventory_Item_Id  -- The Id of the inventory item.
    *   2. Inventory_Item_Name -- The name of the inventory item.
    *   3. Category_Id -- The Id of the category to which the item
    *                     belongs
    *   4. Category_Name -- The name of the category
    *************************************************************/

    PROCEDURE denormalize_item_dimension(
            p_table_name    IN VARCHAR2,
            p_errnum        IN OUT NOCOPY NUMBER,
            p_errmesg       IN OUT NOCOPY VARCHAR2)
    AS
        x_cursor_id INTEGER ;
        x_sql_statement VARCHAR2(32767);
        x_ignore INTEGER ;

        proc_name VARCHAR2 (40) ;

    BEGIN
        proc_name := 'denormalize_item_dimension';

        x_cursor_id := DBMS_SQL.OPEN_CURSOR;

        x_sql_statement :=
                'UPDATE ' || p_table_name || ' xtable ' ||
                ' SET ( ' ||
                    'inventory_item_name, ' ||
                    'category_id, ' ||
                    'category_name ' || ')  = ' ||
                '( SELECT ' ||
                    ' mif.item_number, ' ||
                    ' mic.category_id, ' ||
                    ' mckfv.concatenated_segments ' ||
                '  FROM  ' ||
                    ' mtl_item_flexfields mif, ' ||
                    ' mtl_categories_kfv mckfv, ' ||
                    ' mtl_item_categories mic, ' ||
                    ' mtl_default_category_sets mdcs  ' ||
                 ' WHERE mif.organization_id  = xtable.organization_id ' ||
                   ' AND mif.inventory_item_id = xtable.inventory_item_id ' ||
                   ' AND mic.inventory_item_id (+) = xtable.inventory_item_id ' ||
                   ' AND mic.organization_id (+) = xtable.organization_id ' ||
                   ' AND mdcs.category_set_id (+) = mic.category_set_id ' ||
                   ' AND mdcs.functional_area_id = 7 ' ||
                   ' AND mckfv.category_id = mic.category_id ' ||
                ' ) '  ;


        DBMS_SQL.PARSE( x_cursor_id, x_sql_statement, DBMS_SQL.V7 );

        x_ignore := DBMS_SQL.EXECUTE( x_cursor_id );
        DBMS_SQL.CLOSE_CURSOR (x_cursor_id);

        p_errnum := 0;
        p_errmesg := '';

    EXCEPTION

        WHEN OTHERS
        THEN
            FND_FILE.PUT_LINE (fnd_file.log, proc_name || ':' || sqlerrm);
            p_errnum := -1;
            p_errmesg := (proc_name || ':' || sqlerrm);
            RAISE;

    END denormalize_item_dimension ;


    /**************************************************************
    * This procedure will denormalize the time dimension for a given
    * table - the table name is given as an input parameter. It
    * makes the following assumptions about the columns that needs
    * to be updated :
    *   1. Transaction_Date  -- The date of the transaction
    *   2. Period_Set_Name  -- The GL Periods, period_set_name
    *   3. Year -- The Year in the GL Periods
    *   4. Quarter -- The Quarter in the GL Periods
    *   5. Month   -- The Month in the GL periods
    *************************************************************/

    PROCEDURE denormalize_time_dimension(
            p_table_name    IN VARCHAR2,
            p_errnum        IN OUT NOCOPY NUMBER,
            p_errmesg       IN OUT NOCOPY VARCHAR2)
    AS
        x_cursor_id INTEGER ;
        x_sql_statement VARCHAR2(32767);
        x_ignore INTEGER ;
        proc_name VARCHAR2 (40);
    BEGIN
        proc_name := 'denormalize_time_dimension';
        x_cursor_id := DBMS_SQL.OPEN_CURSOR;

        x_sql_statement :=
            'UPDATE ' || p_table_name || ' xtable ' ||
            ' SET ( ' ||
                'period_set_name ' || ',' ||
                'year ' || ',' ||
                'quarter ' || ',' ||
                'month ' || ')  = ' ||
            '( SELECT /*+ ORDERED */ ' ||
                ' yr.period_set_name, '||
                ' yr.period_name, ' ||
                ' qt.period_name, ' ||
                ' mo.period_name ' ||
            '  FROM  ' ||
--                 ' org_organization_definitions ood , ' ||
                 ' gl_sets_of_books gsob, ' ||
                ' gl_periods mo, ' ||
                ' gl_periods qt, ' ||
                ' gl_periods yr ' ||
        --    ' WHERE ood.organization_id = xtable.organization_id ' ||
       --    ' AND   gsob.set_of_books_id = ood.set_of_books_id ' ||
            ' WHERE   gsob.set_of_books_id = xtable.set_of_books_id ' ||
            ' AND   yr.period_set_name = gsob.period_set_name ' ||
            ' AND   yr.period_type = ''Year'' '  ||
            ' AND   xtable.transaction_date between yr.start_date and yr.end_date ' ||
            ' AND   yr.adjustment_period_flag = ''N'' ' ||
            ' AND   qt.period_set_name = gsob.period_set_name ' ||
            ' AND   qt.period_type = ''Quarter'' ' ||
            ' AND   xtable.transaction_date between qt.start_date and qt.end_date ' ||
            ' AND   qt.adjustment_period_flag = ''N'' ' ||
            ' AND   mo.period_set_name = gsob.period_set_name ' ||
            ' AND   mo.period_type = gsob.ACCOUNTED_PERIOD_TYPE ' ||
            ' AND   xtable.transaction_date between mo.start_date and mo.end_date ' ||
            ' AND   mo.adjustment_period_flag = ''N'' ' ||
        ' ) '  ;


        DBMS_SQL.PARSE( x_cursor_id, x_sql_statement, DBMS_SQL.V7 );

        x_ignore := DBMS_SQL.EXECUTE( x_cursor_id );
        DBMS_SQL.CLOSE_CURSOR (x_cursor_id);

        p_errnum := 0;
        p_errmesg := '';

    EXCEPTION

        WHEN OTHERS
        THEN
            FND_FILE.PUT_LINE (fnd_file.log, proc_name || ':' || sqlerrm);
            p_errnum := -1;
            p_errmesg := (proc_name || ':' || sqlerrm);
            RAISE;

    END denormalize_time_dimension ;


    /**************************************************************
    * This procedure will denormalize the org dimension for a given
    * table - the table name is given as an input parameter. It
    * makes the following assumptions about the columns that needs
    * to be updated :
    *   1. Organization_ID  -- The Organization Id
    *   2. Organization_Name  -- The Organization Name
    *   3. Legal_Entity_ID  -- The Legal Entity Id
    *   4. Legal_Entity_Name -- The Legal Entity Name
    *   5. Operating_Unit_ID -- The operating unit ID
    *   6. Operating_Unit_Name -- The operating unit name
    *   7. set_of_books_id    -- The set of books id
    *   8. set_of_books_name  -- The set of books name
    *************************************************************/

    PROCEDURE denormalize_org_dimension(
             p_table_name   IN VARCHAR2,
             p_errnum       IN OUT NOCOPY NUMBER,
             p_errmesg      IN OUT NOCOPY VARCHAR2)
    AS

        x_cursor_id INTEGER ;
        x_sql_statement VARCHAR2(32767);
        x_ignore INTEGER ;
        x_mapping VARCHAR2(240);

        proc_name VARCHAR2 (40);

    BEGIN
        proc_name  := 'denormalize_org_dimension';
        x_cursor_id := DBMS_SQL.OPEN_CURSOR;



  x_sql_statement :=
            'UPDATE ' || p_table_name || ' xtable ' ||
            ' SET ( ' ||
                'organization_name ' || ',' ||
                'legal_entity_id ' || ',' ||
                'legal_entity_name ' || ',' ||
                'operating_unit_id ' || ',' ||
                'operating_unit_name ' || ',' ||
                'set_of_books_id ' || ',' ||
                'set_of_books_name ' || ' )  = ' ||
            '( SELECT /*+ ORDERED  USE_HASH (ood) USE_HASH (hle) USE_HASH (gsob) USE_HASH (hou) PARALLEL*/ ' ||
                ' ood.organization_name, ' ||
                ' hle.organization_id , ' ||
                ' hle.name, '||
                ' hou.organization_id, ' ||
                ' hou.name, ' ||
                ' ood.set_of_books_id, ' ||
                ' gsob.name ' ||
            ' FROM  ' ||
                ' org_organization_definitions ood, ' ||
                ' hr_legal_entities hle, ' ||
                ' gl_sets_of_books gsob ,' ||
                ' hr_operating_units hou  ' ||
            ' WHERE ood.organization_id = xtable.organization_id ' ||
            ' AND   hle.organization_id = ood.legal_entity ' ||
      --      ' AND   hle.set_of_books_id = ood.set_of_books_id ' ||
            ' AND   gsob.set_of_books_id = ood.set_of_books_id ' ||
            ' AND   hou.organization_id = ood.operating_unit ' ||
            ' AND   hou.default_legal_context_id = to_char(ood.legal_entity) ' ||
        ' ) ' ;
	-- hou.legal_entity_id changed to hou.default_legal_context_id as part of R12 uptake

        DBMS_SQL.PARSE( x_cursor_id, x_sql_statement, DBMS_SQL.V7 );

        x_ignore := DBMS_SQL.EXECUTE( x_cursor_id );
        DBMS_SQL.CLOSE_CURSOR (x_cursor_id);

        p_errnum := 0;
        p_errmesg := '';

    EXCEPTION

        WHEN OTHERS
        THEN
            FND_FILE.PUT_LINE (fnd_file.log, proc_name || ':' || sqlerrm);
            p_errnum := -1;
            p_errmesg := (proc_name || ':' || sqlerrm);
            RAISE;

    END denormalize_org_dimension ;



    /**************************************************************
    * This procedure will denormalize the geo dimension for a given
    * table - the table name is given as an input parameter. It
    * makes the following assumptions about the columns that needs
    * to be updated :
    *   1. Organization_ID  -- The Organization Id
    *   2. location_id      -- The Location ID
    *   3. country_code  -- The Country Code
    *   4. country_Name -- The Country Name
    *   5. Area_Code -- The Area Code
    *   6. Area_Name -- The Area Name
    *   7. region_code -- The region Code
    *   8. region_name -- The Region Name
    *************************************************************/

    PROCEDURE denormalize_geo_dimension(
             p_table_name   IN VARCHAR2,
             p_errnum       IN OUT NOCOPY NUMBER,
             p_errmesg      IN OUT NOCOPY VARCHAR2)
    AS
        x_cursor_id INTEGER ;
        x_sql_statement VARCHAR2(32767);
        x_sql_statement1 VARCHAR2(32767);
        x_ignore INTEGER ;
        x_mapping VARCHAR2(240);

        proc_name VARCHAR2 (40);

    BEGIN
        proc_name  := 'denormalize_geo_dimension';

        -- The region mapping from the bis_flex_mappings column

        begin

            select application_column_name
            into x_mapping
            from bis_flex_mappings_v
            where id_flex_code = 'HR_LOCATIONS'
            and   flex_field_type = 'D'
            and   level_short_name = 'REGION' ;

        exception

             when others then
                x_mapping := null ;
        end ;


        x_cursor_id := DBMS_SQL.OPEN_CURSOR;

           x_sql_statement :=
            'UPDATE ' || p_table_name || ' xtable ' ||
            ' SET ( ' ||
                'location_id ' || ',' ||
                'country_code ' || ',' ||
                'country_name ' || ',' ||
                'area_code ' || ',' ||
                'area_name ' || ',' ||
                'region_code ' || ')  = ' ||
            '( SELECT/*+ ORDERED PARALLEL */ ' ||
                ' horgu.location_id, ' ||
                ' hl.country, ' ||
                ' bthv.child_territory_name, ' ||
                ' bthv.parent_territory_code, ' ||
                ' bthv.parent_territory_name,  ' ;

        if (x_mapping is not null ) then
            x_sql_statement := x_sql_statement ||
            ' hl.' || x_mapping || ' ' ;
        elsif (x_mapping is null ) then
            x_sql_statement := x_sql_statement ||
            ' null '  ;
        end if ;

        x_sql_statement := x_sql_statement ||
            ' FROM  ' ||
                ' org_organization_definitions ood, ' ||
                ' hr_organization_units horgu, ' ||
                ' hr_locations hl, ' ||
                ' bis_territory_hierarchies_v bthv  ' ||
            ' WHERE ood.organization_id = xtable.organization_id ' ||
            ' AND   horgu.organization_id = ood.organization_id ' ||
            ' AND   horgu.business_group_id = ood.business_group_id ' ||
            ' AND   hl.location_id  = horgu.location_id ' ||
            ' AND   bthv.child_territory_code = hl.country ' ||
            ' AND   bthv.child_territory_type = ''COUNTRY'' ' ||
            ' AND   bthv.parent_territory_type = ''AREA'' ' ||
        ' ) ' ;

        DBMS_SQL.PARSE( x_cursor_id, x_sql_statement, DBMS_SQL.V7 );

        x_ignore := DBMS_SQL.EXECUTE( x_cursor_id );


        x_sql_statement1 :=
            'UPDATE ' || p_table_name || ' xtable ' ||
            ' SET ( ' ||
                'region_name ' || ')  = ' ||
            '( SELECT ' ||
                ' bthv.child_territory_name ' ||
                ' FROM  ' ||
                    ' bis_territory_hierarchies_v bthv ' ||
                ' WHERE bthv.child_territory_code = xtable.region_code ' ||
                ' AND   bthv.child_territory_type = ''REGION'' ' ||
                ' AND   bthv.parent_territory_type = ''COUNTRY'' ' ||
            ' AND   bthv.parent_territory_code = xtable.country_code ' ||
            ' ) ' ;


        DBMS_SQL.PARSE( x_cursor_id, x_sql_statement1, DBMS_SQL.V7 );

        x_ignore := DBMS_SQL.EXECUTE( x_cursor_id );
        DBMS_SQL.CLOSE_CURSOR (x_cursor_id);

        p_errnum := 0;
        p_errmesg := '';

    EXCEPTION

        WHEN OTHERS
        THEN
            FND_FILE.PUT_LINE (fnd_file.log, proc_name || ':' || sqlerrm);
            p_errnum := -1;
            p_errmesg := (proc_name || ':' || sqlerrm);
            RAISE;

    END denormalize_geo_dimension ;


    /* Populate_temp_table
    */
    -- Since the three temporary tables only differ in which
    -- indicator type they are selected on, we will make the
    -- table name and indicator type parameters to the
    -- populating function.
    --
    -- Since the tables might not exist in the first run,
    -- we must pass the table name as an argument, and the
    -- the function has to be written as an execute immediate.
    PROCEDURE populate_temp_table (
            p_table_name    IN VARCHAR2,
            p_indicator     IN NUMBER,
            p_group_id      IN NUMBER)
    IS
        -- procedure name
        proc_name VARCHAR2(20) ;

    BEGIN
        proc_name := 'populate_temp_table';
        EXECUTE IMMEDIATE ('
        INSERT INTO ' ||p_table_name || ' (' ||
                  ' group_id,
                    organization_id,
                    wip_entity_id,
                    operation_seq_num,
                    department_id,
                    department_code,
                    resource_id,
                    resource_code,
                    transaction_date,
                    shift_num,
                    standard_quantity,
                    total_quantity,
                    scrap_quantity,
                    standard_units,
                    applied_units_prd,
                    applied_units_utz,
                    available_units,
                    resource_cost,
                    resource_basis,
                    indicator_type,
                    process_phase,
                    creation_date,
                    created_by,
                    last_updated_by,
                    last_update_date,
                    last_update_login,
                    request_id,
                    program_application_id,
                    program_id,
                    program_update_date,
                    line_id,
                    available_quantity,
                    required_quantity,
                    required_hours,
                    share_from_dept_id' || ' ) ' ||
           'SELECT  group_id,
                    organization_id,
                    wip_entity_id,
                    operation_seq_num,
                    department_id,
                    department_code,
                    resource_id,
                    resource_code,
                    transaction_date,
                    shift_num,
                    standard_quantity,
                    total_quantity,
                    scrap_quantity,
                    standard_units,
                    applied_units_prd,
                    applied_units_utz,
                    available_units,
                    resource_cost,
                    resource_basis,
                    indicator_type,
                    process_phase,
                    creation_date,
                    created_by,
                    last_updated_by,
                    last_update_date,
                    last_update_login,
                    request_id,
                    program_application_id,
                    program_id,
                    program_update_date,
                    line_id,
                    available_quantity,
                    required_quantity,
                    required_hours,
                    share_from_dept_id
              FROM  wip_indicators_temp wit
              WHERE wit.indicator_type = ' || p_indicator);
    EXCEPTION
        WHEN OTHERS
        THEN
            FND_FILE.PUT_LINE (fnd_file.log, proc_name || ':' || sqlerrm);
            RAISE;

    END populate_temp_table;
---------------------------------BUG 3280647 -----------------------------------------
-- PROCEDURE populate_eff_temp_table  is added to group data of WIP_EFFICIENCY, Which
-- is necessary to avoid more than one rows of the data created due to deletion of insert
-- statement Calculate_Std_Units(115.19). This Insert satement insert data for WIP_EFF_PHASE_THREE
-- and later on updated with APPLIED_UNITS_PRD in PROCEDURE Calc_Eff_Applied_Units.
-- Now statement in PROCEDURE Calc_Eff_Applied_Units is not working. And Procedure
-- Misc_Applied_Units inserts extra rows for APPLIED_UNITS_PRD.
-- Grouping is done here to avoid duplication
--------------------------------------------------------------------------------------
PROCEDURE populate_eff_temp_table (
            p_table_name    IN VARCHAR2,
            p_indicator     IN NUMBER,
            p_group_id      IN NUMBER)
    IS
        -- procedure name
        proc_name VARCHAR2(20) ;

    BEGIN
        proc_name := 'populate_temp_table';
        insert into WIP_BIS_EFF_TEMP(
                    group_id,
                    organization_id,
                    wip_entity_id,
                    operation_seq_num,
                    department_id,
                    department_code,
                    resource_id,
                    resource_code,
                    transaction_date,
                    shift_num,
                    standard_quantity,
                    total_quantity,
                    scrap_quantity,
                    standard_units,
                    applied_units_prd,
                    applied_units_utz,
                    available_units,
                    resource_cost,
                    resource_basis,
                    indicator_type,
                    process_phase,
                    creation_date,
                    created_by,
                    last_updated_by,
                    last_update_date,
                    last_update_login,
                    request_id,
                    program_application_id,
                    program_id,
                    program_update_date,
                    line_id,
                    available_quantity,
                    required_quantity,
                    required_hours,
                    share_from_dept_id)
                select
                    p_group_id,
                    organization_id,
                    wip_entity_id,
                    operation_seq_num,
                    department_id,
                    department_code,
                    resource_id,
                    resource_code,
                    trunc(transaction_date),
                    NULL,
                    SUM(standard_quantity),
                    sum(total_quantity),
                    sum(scrap_quantity),
                    SUM(standard_units),
                    sum(applied_units_prd),
                    sum(applied_units_utz),
                    sum(available_units),
                    sum(resource_cost),
                    NULL,
                    WIP_EFFICIENCY,
                    WIP_EFF_PHASE_FOUR, -- this is the fourth and final phase
                    sysdate,
                    g_userid,
                    g_userid,
                    sysdate,
                    NULL,
                    NULL,
                    g_applicationid ,
                    NULL,
                    sysdate,
                    NULL,
                    sum(available_quantity),
                    sum(required_quantity),
                    sum(required_hours),
                    NULL
                from
                    wip_indicators_temp
                where indicator_type =WIP_EFFICIENCY
                and process_phase in(WIP_EFF_PHASE_ONE, WIP_EFF_PHASE_TWO,WIP_EFF_PHASE_THREE)
                group by
                       organization_id,
                       wip_entity_id,
                       operation_seq_num,
                       department_id,
                       department_code,
                       resource_id,
                       resource_code,
                       trunc(transaction_date);



    EXCEPTION
        WHEN OTHERS
        THEN
            FND_FILE.PUT_LINE (fnd_file.log, proc_name || ':' || sqlerrm);
            RAISE;

    END populate_eff_temp_table;



    /* Simple_decomp
    */
    -- First query rewrite.
    -- All we do here is decompose the wip_indicators_temp table
    -- into 3 separate tables based on whether the records have
    -- indicator_type = WIP_EFFICIENCY, WIP_UTILIZATION, WIP_YIELD.
    -- Then we do a cartesian join on the three tables to pick the
    -- records we need. Since the tables have already been filtered
    -- using the group_id and the indicator types, the cartesian
    -- join will be on smaller tables and should be faster.
    PROCEDURE simple_decomp (p_group_id IN NUMBER)
    IS
        -- procedure name
        proc_name VARCHAR2(20);

    BEGIN
        proc_name  := 'simple_decomp';

        INSERT INTO /*+ NOAPPEND */ wip_bis_prod_indicators (
            organization_id,
            wip_entity_id,
            inventory_item_id,
            transaction_date,
            operation_seq_num,
            department_id,
            department_code,
            resource_id,
            resource_code,
            standard_hours,
            applied_hours_prd,
            available_hours,
            applied_hours_utz,
            total_quantity,
            scrap_quantity,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by,
            last_update_login,
            request_id,
            program_application_id,
            program_update_date)
          SELECT   /*+ leading(wit2)*/   wit.organization_id,
                    wit.wip_entity_id,
                    we.primary_item_id,
                    wit.transaction_date,   -- already trunc'ed
                    wit.operation_seq_num,
                    wit.department_id,
                    wit.department_code,
                    wit.resource_id,
                    wit.resource_code,
                    wit.standard_units,
                    wit.applied_units_prd,
                    wit2.available_units,
                    wit2.applied_units_utz,
                    wit3.total_quantity,
                    wit3.scrap_quantity,
                    wit.last_update_date,
                    wit.last_updated_by,
                    wit.creation_date,
                    wit.created_by,
                    wit.last_update_login,
                    wit.request_id,
                    wit.program_application_id,
                    sysdate
            FROM    wip_entities we,
                    wip_bis_yld_temp wit3,
                    wip_bis_utz_temp wit2,
                    wip_bis_eff_temp wit
            WHERE
                    wit2.organization_id = wit.organization_id
            AND     wit2.department_id = wit.department_id
            AND     wit2.resource_id = wit.resource_id
            AND     wit2.wip_entity_id = wit.wip_entity_id --Bug 3604065
            AND     wit2.operation_seq_num = wit.operation_seq_num --Bug 3604065
            AND     wit2.transaction_date = wit.transaction_date -- trunc'ed
            AND     wit3.organization_id = wit.organization_id
            AND     wit3.wip_entity_id = wit.wip_entity_id
            AND     wit3.operation_seq_num = wit.operation_seq_num
            AND     wit3.department_id = wit.department_id
            AND     wit3.resource_id = wit.resource_id
            AND     wit3.transaction_date = wit.transaction_date -- trunc'ed
            AND     wit3.process_phase = 3
            AND     we.wip_entity_id = wit.wip_entity_id
            AND     we.organization_id = wit.organization_id;

        commit;

        return;

    EXCEPTION
        WHEN OTHERS
        THEN
            FND_FILE.PUT_LINE (fnd_file.log, proc_name || ':' || sqlerrm);
            RAISE;      -- exceptions handled in calling routine.

    END simple_decomp;

    -- Following bug 3387800, check for the existing flag not being
    -- equal to 1 for any row in the wip_bis_prod_indicators,
    -- wip_bis_prod_assy_yield or wip_bis_prod_dept_yield tables.
    -- If it is not equal to 1, all existing data data should not
    -- be backed up.
    --
    -- Note that since the old program used to set the existing_flag to
    -- 0 for old rows, but not delete them, this condition will take care
    -- of removing all old data.
    FUNCTION check_backup_needed
        RETURN BOOLEAN
    IS

        l_csr_rec NUMBER;

        -- by default, believe that backup is needed
        l_backup_needed BOOLEAN ;

        CURSOR bad_existing_flag_wbpi_csr IS
            SELECT 1
              FROM wip_bis_prod_indicators
              WHERE nvl (existing_flag, -1) <> 1
                AND rownum < 2;

        CURSOR bad_existing_flag_wbpay_csr IS
            SELECT 1
              FROM wip_bis_prod_assy_yield
              WHERE nvl (existing_flag, -1) <> 1
                AND rownum < 2;

        CURSOR bad_existing_flag_wbpdy_csr IS
            SELECT 1
              FROM wip_bis_prod_dept_yield
              WHERE nvl (existing_flag, -1) <> 1
                AND rownum < 2;


    BEGIN
        l_backup_needed := TRUE;
        OPEN bad_existing_flag_wbpdy_csr;
        OPEN bad_existing_flag_wbpay_csr;
        OPEN bad_existing_flag_wbpi_csr;

        FETCH bad_existing_flag_wbpdy_csr INTO l_csr_rec;
        FETCH bad_existing_flag_wbpay_csr INTO l_csr_rec;
        FETCH bad_existing_flag_wbpi_csr INTO l_csr_rec;

	-- RS: These would return NOTFOUND when there is no bad data
	-- and also when there are no rows at all in the
	-- summary tables. In a case, when data is present in the
	-- temp tables but not in the summary, it would be better
	-- to return backup_needed = TRUE as we would have to merge
	-- data on completion of the run.

        IF (bad_existing_flag_wbpdy_csr%NOTFOUND AND
            bad_existing_flag_wbpay_csr%NOTFOUND AND
            bad_existing_flag_wbpi_csr%NOTFOUND) THEN

	    -- The new program has run at least once
            -- and there is no need to truncate existing data. ? -> RS: can't be confirmed that this is the second run
            l_backup_needed := true;

        ELSE
            -- Bad data present in summary tables. Collect entire data again.
            l_backup_needed := false;
        END IF;

        CLOSE bad_existing_flag_wbpi_csr;
        CLOSE bad_existing_flag_wbpay_csr;
        CLOSE bad_existing_flag_wbpdy_csr;

        return l_backup_needed;

    END check_backup_needed;



    -- Create the 3 backup tables
    -- WIP_BIS_PROD_INDICATORS
    -- WIP_BIS_PROD_ASSY_YIELD
    -- WIP_BIS_PROD_DEPT_YIELD
    -- into three temp tables
    -- The three tables are backed up with data less than the specified
    -- date. This will take care of the fact that the present collection
    -- might overlap with the data already collected. In that case, we
    -- want to keep the data collected this time, and throw away
    -- whatever was collected previously.

    PROCEDURE backup_summary_tables (
            p_max_backup_date   IN DATE,
            p_errnum            OUT NOCOPY NUMBER,
            p_errmesg           OUT NOCOPY VARCHAR2)
    IS
        -- procedure name
        proc_name VARCHAR2(20);

	l_wip_bis_prod_indicators NUMBER := 0;
	l_wip_bis_prod_assy_yield NUMBER := 0;
	l_wip_bis_prod_dept_yield NUMBER := 0;

    BEGIN
        proc_name  := 'backup_summary_table';
        -- clear garbage out of the tables.
	-- RS: BUG 5132779: Check whether the summary tables are empty or have data in them.
	-- There would be a case when the previous collection would have errored
	-- out abnormally due to database issues. In such cases, the exception handling
	-- purges the data collected in the present run in the summary tables and tries
	-- to merge data from temp tables. But, this may also fail resulting in a state where
	-- the temp summary tables have data and actual summary tables are empty. In such
	-- cases, the clean up of temp tables in the following run should be avoided as
	-- the entire data would be lost if the temp summary tables are truncated.

	SELECT count(1) INTO l_wip_bis_prod_indicators FROM wip_bis_prod_indicators;

	SELECT count(1) INTO l_wip_bis_prod_assy_yield FROM wip_bis_prod_assy_yield;

	SELECT count(1) INTO l_wip_bis_prod_dept_yield FROM wip_bis_prod_dept_yield;

	-- RS: If summary tables don't have any data, it is assumed that the previous run failed at merge
	-- and data is present in temp tables. So, don't truncate or back up them in this run.
	-- Though this is an unusual case, its a difficult situation to get out as these temp tables
	-- would be truncated in the next run, and customer will have to collect entire data again.

	IF (l_wip_bis_prod_indicators <> 0 AND l_wip_bis_prod_assy_yield <> 0 AND l_wip_bis_prod_dept_yield <> 0) THEN

	        IF g_debug = 1 THEN
	 		fnd_file.put_line(fnd_file.log,'Backing up old data (if any)...');
                END IF ;
		clear_temp_summary_tables (p_errnum, p_errmesg);
	        IF (p_errnum < 0) THEN
		   return;
	        END IF;

		-- simply back up the entire summary tables

		INSERT INTO wip_bis_prod_indicators_temp (
		    organization_id,
		    wip_entity_id,
		    inventory_item_id,
		    operation_seq_num,
		    department_id,
		    department_code,
		    resource_id,
		    resource_code,
		    transaction_date,
		    total_quantity,
		    scrap_quantity,
		    standard_hours,
		    applied_hours_prd,
		    applied_hours_utz,
		    available_hours,
		    existing_flag,
		    last_update_date,
		    last_updated_by,
		    creation_date,
		    created_by,
		    last_update_login,
		    request_id,
		    program_application_id,
		    program_id,
		    program_update_date,
		    set_of_books_id,
		    set_of_books_name,
		    legal_entity_id,
		    legal_entity_name,
		    operating_unit_id,
		    operating_unit_name,
		    organization_name,
		    location_id,
		    area_code,
		    area_name,
		    country_code,
		    country_name,
		    region_code,
		    region_name,
		    category_id,
		    category_name,
		    inventory_item_name,
		    period_set_name,
		    year,
		    quarter,
		    month,
		    indicator_type,
		    share_from_dept_id)
		SELECT
		    organization_id,
		    wip_entity_id,
		    inventory_item_id,
		    operation_seq_num,
		    department_id,
		    department_code,
		    resource_id,
		    resource_code,
		    transaction_date,
		    total_quantity,
		    scrap_quantity,
		    standard_hours,
		    applied_hours_prd,
		    applied_hours_utz,
		    available_hours,
		    existing_flag,
		    last_update_date,
		    last_updated_by,
		    creation_date,
		    created_by,
		    last_update_login,
		    request_id,
		    program_application_id,
		    program_id,
		    program_update_date,
		    set_of_books_id,
		    set_of_books_name,
		    legal_entity_id,
		    legal_entity_name,
		    operating_unit_id,
		    operating_unit_name,
		    organization_name,
		    location_id,
		    area_code,
		    area_name,
		    country_code,
		    country_name,
		    region_code,
		    region_name,
		    category_id,
		    category_name,
		    inventory_item_name,
		    period_set_name,
		    year,
		    quarter,
		    month,
		    indicator_type,
		    share_from_dept_id
		      FROM wip_bis_prod_indicators
		      WHERE transaction_date < trunc (p_max_backup_date);


		INSERT INTO wip_bis_prod_assy_yield_temp (
		    organization_id,
		    wip_entity_id,
		    inventory_item_id,
		    transaction_date,
		    completed_quantity,
		    scrap_quantity,
		    existing_flag,
		    last_update_date,
		    last_updated_by,
		    creation_date,
		    created_by,
		    last_update_login,
		    request_id,
		    program_application_id,
		    program_id,
		    program_update_date,
		    set_of_books_id,
		    set_of_books_name,
		    legal_entity_id,
		    legal_entity_name,
		    operating_unit_id,
		    operating_unit_name,
		    organization_name,
		    category_id,
		    category_name,
		    inventory_item_name,
		    location_id,
		    area_code,
		    area_name,
		    country_code,
		    country_name,
		    region_code,
		    region_name,
		    period_set_name,
		    year,
		    quarter,
		    month
		)
		SELECT
		    organization_id,
		    wip_entity_id,
		    inventory_item_id,
		    transaction_date,
		    completed_quantity,
		    scrap_quantity,
		    existing_flag,
		    last_update_date,
		    last_updated_by,
		    creation_date,
		    created_by,
		    last_update_login,
		    request_id,
		    program_application_id,
		    program_id,
		    program_update_date,
		    set_of_books_id,
		    set_of_books_name,
		    legal_entity_id,
		    legal_entity_name,
		    operating_unit_id,
		    operating_unit_name,
		    organization_name,
		    category_id,
		    category_name,
		    inventory_item_name,
		    location_id,
		    area_code,
		    area_name,
		    country_code,
		    country_name,
		    region_code,
		    region_name,
		    period_set_name,
		    year,
		    quarter,
		    month
		      FROM wip_bis_prod_assy_yield
		      WHERE transaction_date < trunc (p_max_backup_date);


		INSERT INTO wip_bis_prod_dept_yield_temp (
		    organization_id,
		    wip_entity_id,
		    inventory_item_id,
		    operation_seq_num,
		    department_id,
		    department_code,
		    transaction_date,
		    total_quantity,
		    scrap_quantity,
		    existing_flag,
		    last_update_date,
		    last_updated_by,
		    creation_date,
		    created_by,
		    last_update_login,
		    request_id,
		    program_application_id,
		    program_id,
		    program_update_date,
		    set_of_books_id,
		    set_of_books_name,
		    legal_entity_id,
		    legal_entity_name,
		    operating_unit_id,
		    operating_unit_name,
		    organization_name,
		    location_id,
		    area_code,
		    area_name,
		    country_code,
		    country_name,
		    region_code,
		    region_name,
		    period_set_name,
		    year,
		    quarter,
		    month
		)
		    SELECT
		    organization_id,
		    wip_entity_id,
		    inventory_item_id,
		    operation_seq_num,
		    department_id,
		    department_code,
		    transaction_date,
		    total_quantity,
		    scrap_quantity,
		    existing_flag,
		    last_update_date,
		    last_updated_by,
		    creation_date,
		    created_by,
		    last_update_login,
		    request_id,
		    program_application_id,
		    program_id,
		    program_update_date,
		    set_of_books_id,
		    set_of_books_name,
		    legal_entity_id,
		    legal_entity_name,
		    operating_unit_id,
		    operating_unit_name,
		    organization_name,
		    location_id,
		    area_code,
		    area_name,
		    country_code,
		    country_name,
		    region_code,
		    region_name,
		    period_set_name,
		    year,
		    quarter,
		    month
		      FROM wip_bis_prod_dept_yield
		      WHERE transaction_date < trunc (p_max_backup_date);

	END IF;

        p_errnum := 0;
        p_errmesg := '';

        return;

    EXCEPTION

        WHEN OTHERS
        THEN
            FND_FILE.PUT_LINE (fnd_file.log, proc_name || ':' || sqlerrm);
            p_errnum := -1;
            p_errmesg := (proc_name || ':' || sqlerrm);
	    if g_debug = 1 then
		fnd_file.put_line(fnd_file.log,'Failed in Backup of old data. Please run the collection after fixing the issue.');
            end if ;
	    raise ;  -- Added by Suhasini for Bug 5132779

	    -- RS: This used to return to populate_summary_table and not raise
	    -- prior to bug fix 5132779, Now  don't return to populate_summary_table
	    -- as this would raise collection stage failed and truncate summary tables
	    -- that are not yet backed up. This would result in loss of complete data
	    -- in summary tables. Instead raise, so that it is handled in exception
	    -- of populate_summary_table and collection is terminated normally.

    END backup_summary_tables;


    /* Update the existing flag off all rows in
       in:
       wip_bis_prod_indicators
       wip_bis_prod_assy_yield
       wip_bis_prod_dept_yield

       This is for fixing bug 3387800 which causes various views
       on these tables to turn up empty.

       Do not commit here.

    */
    PROCEDURE update_existing_flag (
            p_errnum            OUT NOCOPY NUMBER,
            p_errmesg           OUT NOCOPY VARCHAR2)
    IS
        proc_name VARCHAR2 (40);
    BEGIN
        proc_name  := 'update_existing_flag';
        UPDATE wip_bis_prod_indicators
          SET existing_flag = 1;

        UPDATE wip_bis_prod_assy_yield
          SET existing_flag = 1;

        UPDATE wip_bis_prod_dept_yield
          SET existing_flag = 1;

        p_errnum := 0;
        p_errmesg := '';

        return;

    EXCEPTION

        WHEN OTHERS
        THEN
            FND_FILE.PUT_LINE (fnd_file.log, proc_name || ':' || sqlerrm);
            p_errnum := -1;
            p_errmesg := (proc_name || ':' || sqlerrm);

            -- returns to populate_summary_table, so don't raise exception.


    END update_existing_flag;


    /* Merge the old data in the temp tables into the actual tables.
       The temp data is denormalized by item, org, time, and geo, and
       it is assumed that the data collected in this run has been
       denormalized by these dimensions before the merge.
       The merge can be done blindly, since we only backed up data
       prior to the start date of this run (i.e. data that is not
       overlapping with that collected this time).
    */
    PROCEDURE merge_previous_run_data (
            p_errnum            OUT NOCOPY NUMBER,
            p_errmesg           OUT NOCOPY VARCHAR2)
    IS
        proc_name VARCHAR2 (40) ;
    BEGIN
         proc_name  := 'merge_previous_run_data';
        -- simply back up the entire temp counterparts of summary tables

        INSERT INTO wip_bis_prod_indicators (
            organization_id,
            wip_entity_id,
            inventory_item_id,
            operation_seq_num,
            department_id,
            department_code,
            resource_id,
            resource_code,
            transaction_date,
            total_quantity,
            scrap_quantity,
            standard_hours,
            applied_hours_prd,
            applied_hours_utz,
            available_hours,
            existing_flag,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by,
            last_update_login,
            request_id,
            program_application_id,
            program_id,
            program_update_date,
            set_of_books_id,
            set_of_books_name,
            legal_entity_id,
            legal_entity_name,
            operating_unit_id,
            operating_unit_name,
            organization_name,
            location_id,
            area_code,
            area_name,
            country_code,
            country_name,
            region_code,
            region_name,
            category_id,
            category_name,
            inventory_item_name,
            period_set_name,
            year,
            quarter,
            month,
            indicator_type,
            share_from_dept_id)
        SELECT
            organization_id,
            wip_entity_id,
            inventory_item_id,
            operation_seq_num,
            department_id,
            department_code,
            resource_id,
            resource_code,
            transaction_date,
            total_quantity,
            scrap_quantity,
            standard_hours,
            applied_hours_prd,
            applied_hours_utz,
            available_hours,
            existing_flag,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by,
            last_update_login,
            request_id,
            program_application_id,
            program_id,
            program_update_date,
            set_of_books_id,
            set_of_books_name,
            legal_entity_id,
            legal_entity_name,
            operating_unit_id,
            operating_unit_name,
            organization_name,
            location_id,
            area_code,
            area_name,
            country_code,
            country_name,
            region_code,
            region_name,
            category_id,
            category_name,
            inventory_item_name,
            period_set_name,
            year,
            quarter,
            month,
            indicator_type,
            share_from_dept_id
              FROM wip_bis_prod_indicators_temp;

        INSERT INTO wip_bis_prod_assy_yield (
            organization_id,
            wip_entity_id,
            inventory_item_id,
            transaction_date,
            completed_quantity,
            scrap_quantity,
            existing_flag,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by,
            last_update_login,
            request_id,
            program_application_id,
            program_id,
            program_update_date,
            set_of_books_id,
            set_of_books_name,
            legal_entity_id,
            legal_entity_name,
            operating_unit_id,
            operating_unit_name,
            organization_name,
            category_id,
            category_name,
            inventory_item_name,
            location_id,
            area_code,
            area_name,
            country_code,
            country_name,
            region_code,
            region_name,
            period_set_name,
            year,
            quarter,
            month
        )
        SELECT
            organization_id,
            wip_entity_id,
            inventory_item_id,
            transaction_date,
            completed_quantity,
            scrap_quantity,
            existing_flag,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by,
            last_update_login,
            request_id,
            program_application_id,
            program_id,
            program_update_date,
            set_of_books_id,
            set_of_books_name,
            legal_entity_id,
            legal_entity_name,
            operating_unit_id,
            operating_unit_name,
            organization_name,
            category_id,
            category_name,
            inventory_item_name,
            location_id,
            area_code,
            area_name,
            country_code,
            country_name,
            region_code,
            region_name,
            period_set_name,
            year,
            quarter,
            month
              FROM wip_bis_prod_assy_yield_temp;

        INSERT INTO wip_bis_prod_dept_yield (
            organization_id,
            wip_entity_id,
            inventory_item_id,
            operation_seq_num,
            department_id,
            department_code,
            transaction_date,
            total_quantity,
            scrap_quantity,
            existing_flag,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by,
            last_update_login,
            request_id,
            program_application_id,
            program_id,
            program_update_date,
            set_of_books_id,
            set_of_books_name,
            legal_entity_id,
            legal_entity_name,
            operating_unit_id,
            operating_unit_name,
            organization_name,
            location_id,
            area_code,
            area_name,
            country_code,
            country_name,
            region_code,
            region_name,
            period_set_name,
            year,
            quarter,
            month
        )
        SELECT
            organization_id,
            wip_entity_id,
            inventory_item_id,
            operation_seq_num,
            department_id,
            department_code,
            transaction_date,
            total_quantity,
            scrap_quantity,
            existing_flag,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by,
            last_update_login,
            request_id,
            program_application_id,
            program_id,
            program_update_date,
            set_of_books_id,
            set_of_books_name,
            legal_entity_id,
            legal_entity_name,
            operating_unit_id,
            operating_unit_name,
            organization_name,
            location_id,
            area_code,
            area_name,
            country_code,
            country_name,
            region_code,
            region_name,
            period_set_name,
            year,
            quarter,
            month
              FROM wip_bis_prod_dept_yield_temp;

        p_errnum := 0;
        p_errmesg := '';

        RETURN;

    EXCEPTION

        WHEN OTHERS
        THEN
            FND_FILE.PUT_LINE (fnd_file.log, proc_name || ':' || sqlerrm);
            p_errnum := -1;
            p_errmesg := (proc_name || ':' || sqlerrm);
   	    if g_debug = 1 then
		fnd_file.put_line(fnd_file.log,'Failed during merging old data. Data for the present collection range is being truncated.');
		fnd_file.put_line(fnd_file.log,'Please run the collection after fixing the issue.');
            end if ;

	     -- truncate the 3 summary tables
            execute immediate 'truncate table ' || g_wip_schema ||
                              '.WIP_BIS_PROD_INDICATORS';

            execute immediate 'truncate table ' || g_wip_schema ||
                              '.WIP_BIS_PROD_DEPT_YIELD';

            execute immediate 'truncate table ' || g_wip_schema ||
                              '.WIP_BIS_PROD_ASSY_YIELD';
	    raise; -- Added by Suhasini for bug 5132779
            -- RS: Do not return to populate_summary as it would raise collection_stage_failed exception
	    -- and try to merge data again. This may result in an inconsistent state of the three
	    -- summary tables as data is committed after that.

    END merge_previous_run_data;

    /* clean out the temp summary tables that were used to
       preserve data from previous runs
    */
    PROCEDURE clear_temp_summary_tables (
            p_errnum            OUT NOCOPY NUMBER,
            p_errmesg           OUT NOCOPY VARCHAR2)
    IS
        proc_name VARCHAR2 (40);

    BEGIN
        proc_name := 'clear_temp_summary_tables';
        execute immediate 'truncate table ' || g_wip_schema ||
                          '.WIP_BIS_PROD_INDICATORS_TEMP';
        execute immediate 'truncate table ' || g_wip_schema ||
                          '.WIP_BIS_PROD_DEPT_YIELD_TEMP';
        execute immediate 'truncate table ' || g_wip_schema ||
                          '.WIP_BIS_PROD_ASSY_YIELD_TEMP';

        p_errnum := 0;
        p_errmesg := '';

        return;

    EXCEPTION

        WHEN OTHERS
        THEN
            FND_FILE.PUT_LINE (fnd_file.log, proc_name || ':' || sqlerrm);
            p_errnum := -1;
            p_errmesg := (proc_name || ':' || sqlerrm);
            RAISE;

    END clear_temp_summary_tables;


END WIP_PROD_INDICATORS;

/
