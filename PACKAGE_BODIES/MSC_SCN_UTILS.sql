--------------------------------------------------------
--  DDL for Package Body MSC_SCN_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_SCN_UTILS" AS
    /* $Header: MSCSCNUB.pls 120.51.12010000.6 2010/03/31 12:59:13 wexia ship $*/

    p_version constant number := 7;


    Procedure insert_seed_data is
        Cursor tcur is
        select count(*)
        from msc_activity_parameters
        where param_version >= p_version;

        ln_count number := 0;
    begin
    /*    if g_refresh = 0 then
            return;
        end if;
        g_refresh := 0;*/






        /************
          select lookup_code, meaning
          from mfg_lookups
          where lookup_type='MSC_PROCESS_ACTIVITY_TYPES'

        LOOKUP_CODE MEANING
        ----------- -----------------------------------
                  1 Run Supply Chain Plan
                 10 Run Demantra Collections and Download
                 11 Run ASCP Collections
                 12 Generate Forecast
                 13 Review Forecast
                 14 Review Supply Chain Plan
                 15 Review Financial Plan
                 16 Review Marketing Plan
                 17 Review Demand Plan
                 18 Review Sales Plan
                 19 Upload Forecast
                 20 Review Supply Network Plan
                 21 Approve Consensus Demand
                 22 Executive Review
                  4 Run Inventory Plan
                  6 Run Supply Network Plan


        msc_activity_parameters
          ACTIVITY_TYPE                             NOT NULL NUMBER
          NAME                                      NOT NULL VARCHAR2(30)
          DATA_TYPE                                          VARCHAR2(30)
          DEFAULT_VALUE                                      VARCHAR2(30)
          SEQUENCE                                           NUMBER
          SQL                                                VARCHAR2(2000)
          CREATED_BY                                         NUMBER
          CREATION_DATE                                      DATE
          LAST_UPDATE_DATE                                   DATE
          LAST_UPDATED_BY                                    NUMBER
          LAST_UPDATE_LOGIN                                  NUMBER
          LOOKUP_TYPE                                        VARCHAR2(30)
          REQUIRED                                           VARCHAR2(10)
          DISPLAYED                                          VARCHAR2(10)
          DISPLAY_NAME,  PARAM_VERSION                                       VARCHAR2(64)
          ENABLED                                            NUMBER -- 1, YES, 2/NULL - NO
          COMPONENT_STYLE                                    NUMBER -- 1- Message text input
                                                                    -- 2- LOV
                                                                    -- 3- Date
      PARAM_VERSION                           NUMBER

*********************************************************/
    open tcur;
    fetch tcur into ln_count;
    close tcur;
    if nvl(ln_count,0) < 1 then

delete from msc_activity_parameters;
commit;

        INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(1,'PLAN_ID','NUMBER',NULL,1,
               '',
               1,SYSDATE,'Y','N','Plan Name',p_version);

        INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(1,'LAUNCH_SNAPSHOT','NUMBER','FULL',2,
               'select decode(lookup_code, 1, ''FULL'',2,''NO'',3,''DP_ONLY'') hidden, meaning display '||
               'from mfg_lookups '||
               'where lookup_type = ''MSC_LAUNCH_SNAPSHOT''',
               1,SYSDATE,'Y','Y','Launch Snapshot',p_version);

        INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(1,'LAUNCH_PLANNER','NUMBER','Y',3,
               'select decode(lookup_code, 1, ''Y'',2,''N'') hidden, meaning display '||
               'from mfg_lookups '||
               'where lookup_type = ''SYS_YES_NO''',
               1,SYSDATE,'Y','Y','Launch Planner',p_version);


        INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(1,'ANCHOR_DATE','DATE',SYSDATE,4,
               '',
               1,SYSDATE,'Y','Y','Anchor Date',p_version);

INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(1,'ARCHIVE_FLAG','VARCHAR2','N',5,
                'select decode(lookup_code, 1, ''Y'',2,''N'')  hidden, meaning display  from mfg_lookups where lookup_type = ''SYS_YES_NO''',
                1,sysdate,'Y','Y','Archive Plan Summary',p_version);


        INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(1,'ENABLE_24X7ATP','NUMBER',NULL,6,
               'select decode(lookup_code, 1, ''YES_PURGE'',2,''NO'',3,''YES_NO_PURGE'') hidden, meaning display '||
               'from mfg_lookups '||
               'where lookup_type = ''MSC_24X7_PURGE''',
               1,SYSDATE,'Y','Y','Enable 24x7ATP',p_version);


        INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(1,'RELEASE_RESCHEDULES','NUMBER','N',7,
               'select decode(lookup_code, 1, ''Y'',2,''N'') hidden, meaning display '||
               'from mfg_lookups '||
               'where lookup_type = ''SYS_YES_NO''',
               1,SYSDATE,'Y','Y','Release Reschedules',p_version);

        INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(1,'SNAP_STATIC_ENTITIES','NUMBER','Y',8,
               'select decode(lookup_code, 1, ''Y'',2,''N'') hidden, meaning display '||
               'from mfg_lookups '||
               'where lookup_type = ''SYS_YES_NO''',
               1,SYSDATE,'Y','Y','Snapshot Static Entities',p_version);

        INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(6,'PLAN_ID','VARCHAR2',NULL,1,
               ' SELECT plans.compile_designator hidden,'||
               '        plans.compile_designator display'||
               ' FROM msc_plans plans, msc_designators desig'||
               ' WHERE plans.organization_id = NVL(fnd_profile.value(''SCENARIO_PLANNING_ORG''),plans.organization_id)'||
               ' AND   plans.sr_instance_id = NVL(fnd_profile.value(''SCENARIO_PLANNING_INST''),plans.sr_instance_id)'||
               ' AND   plans.curr_plan_type = 6               '||
               ' AND   plans.organization_id = desig.organization_id'||
               ' AND   plans.sr_instance_id = desig.sr_instance_id'||
               ' AND   plans.compile_designator = desig.designator'||
        ' AND NVL(desig.disable_date, TRUNC(SYSDATE)+1) > TRUNC(SYSDATE)'||
        ' AND plans.organization_selection <> 1'||
               ' AND   NVL(plans.copy_plan_id,-1) = -1'||
               ' AND   NVL(desig.copy_designator_id, -1) = -1',
               1,SYSDATE,'Y','N','Plan Name',p_version);

        INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(6,'SOLVE_IN_SERVER','VARCHAR2','Y',2,
               'select decode(lookup_code, 1, ''Y'',2,''N'') hidden, meaning display '||
               'from mfg_lookups '||
               'where lookup_type = ''SYS_YES_NO''',
               1,SYSDATE,'Y','Y','Solve in Server',p_version);

          INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(6,'appProfile','VARCHAR2',NULL,3,
               'select decode(lookup_code, 1, ''SOP'',2,''SCRM'',3,''SNO'') hidden, meaning display from mfg_lookups where lookup_type=''MSC_SCN_SOP_PROFILE''',
               1,SYSDATE,'Y','Y','AppProfile',p_version);




        INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(4,'PLAN_ID','NUMBER',NULL,1,
               '',
               1,SYSDATE,'Y','N','Plan Name',p_version);

        INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(4,'ANCHOR_DATE','DATE',SYSDATE,2,
               '',
               1,SYSDATE,'Y','Y','Anchor Date',p_version);



INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(4,'ARCHIVE_FLAG','VARCHAR2','N',3,
                'select decode(lookup_code, 1, ''Y'',2,''N'')  hidden, meaning display  from mfg_lookups where lookup_type = ''SYS_YES_NO''',
                1,sysdate,'Y','Y','Archive Plan Summary',p_version);


        INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(11,'INSTANCE_ID','NUMBER',NULL,1,
               'select INSTANCE_ID hidden, INSTANCE_CODE Display '||
               'FROM MSC_APPS_INSTANCES '||
               'where instance_type IN (1,2,4) and enable_flag = 1',
               1,SYSDATE,'Y','Y','Instance',p_version);

        INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(11,'COLLECTION_GROUP','VARCHAR2',NULL,2,
               'select CODE hidden, ORG_GROUP Display FROM MSC_ORG_GROUPS_V ' ,
               1,SYSDATE,'Y','Y','Collections Group',p_version);

        INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(11,'TOTAL_WORKER_NUM','NUMBER',3,3,NULL,1,SYSDATE,'Y','Y','Number of workers',p_version);

        INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(11,'TIME_OUT','NUMBER',180,4,NULL,1,SYSDATE,'Y','Y','Timeout (Minutes)',p_version);

        INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(11,'ODS_PURGE_OPTION','VARCHAR2','Y',5,
               'select decode(lookup_code, 1, ''Y'',2,''N'')  hidden, meaning display  from mfg_lookups where lookup_type = ''SYS_YES_NO''',
               1,SYSDATE,'Y','Y','Purge Previously Collected Data',p_version);

        INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(11,'COLLECTION_METHOD','VARCHAR2','COMPLETE_REFRESH',6,
        'select  decode(lookup_code, 1, ''COMPLETE_REFRESH'',2,''NET_CHANGE_REFRESH'',3,''TARGETED_REFRESH'') hidden, meaning display ' ||
          'from mfg_lookups WHERE lookup_type = ''PARTIAL_YES_NO''',
                1,SYSDATE,'Y','Y','Collection Method',p_version);

        INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(11,'ANALYZE_TABLES_ENABLED','VARCHAR2','N',7,
                'select decode(lookup_code, 1, ''Y'',2,''N'')  hidden, meaning display  from mfg_lookups where lookup_type = ''SYS_YES_NO''',
                1,SYSDATE,'Y','Y','Analyze Staging Tables',p_version);

        INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(11,'APPROVED_SUPPLIER_LIST','VARCHAR2','YES_REPLACE',8,
                ' select decode(lookup_code, 1, ''YES_REPLACE'',2,''NO'',3,''YES_BUT_RETAIN_CP'') hidden, meaning display '||
                'from mfg_lookups where lookup_type=''MSC_X_ASL_SYS_YES_NO''',
                1,SYSDATE,'Y','Y','Collect Approved Supplier Lists (Supplier Capacities)',p_version);

        INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(11,'ATP_RULES_ENABLED','VARCHAR2','Y',9,
                'select decode(lookup_code, 1, ''Y'',2,''N'')hidden, meaning display from mfg_lookups where lookup_type = ''SYS_YES_NO''',
                1,SYSDATE,'Y','Y','Collect ATP Rules',p_version);

        INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(11,'BOM_ENABLED','VARCHAR2','Y',10,
                'select decode(lookup_code, 1, ''Y'',2,''N'')hidden, meaning display from mfg_lookups where lookup_type = ''SYS_YES_NO''',
                1,SYSDATE,'Y','Y','Collect Bill of Materials/Routings/Resources',p_version);

        INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(11,'BOR_ENABLED','VARCHAR2','Y',11,
                'select decode(lookup_code, 1, ''Y'',2,''N'')hidden, meaning display from mfg_lookups where lookup_type = ''SYS_YES_NO''',
                1,SYSDATE,'Y','Y','Collect Bills of Resources',p_version);

        INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(11,'CALENDAR_ENABLED','VARCHAR2','Y',12,
                'select decode(lookup_code, 1, ''Y'',2,''N'')hidden, meaning display from mfg_lookups where lookup_type = ''SYS_YES_NO''',
                1,SYSDATE,'Y','Y','Collect Calendars',p_version);

        INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(11,'DEMAND_CLASS_ENABLED','VARCHAR2','Y',13,
                'select decode(lookup_code, 1, ''Y'',2,''N'')hidden, meaning display from mfg_lookups where lookup_type = ''SYS_YES_NO''',
                1,SYSDATE,'Y','Y','Collect Demand Classes',p_version);

        INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(11,'ITEM_SUBST_ENABLED','VARCHAR2','Y',14,
                'select decode(lookup_code, 1, ''Y'',2,''N'')hidden, meaning display from mfg_lookups where lookup_type = ''SYS_YES_NO''',
                1,SYSDATE,'Y','Y','Collect End Item Substitutions',p_version);

        INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(11,'FORECAST_ENABLED','VARCHAR2','Y',15,
                'select decode(lookup_code, 1, ''Y'',2,''N'')hidden, meaning display from mfg_lookups where lookup_type = ''SYS_YES_NO''',
                1,SYSDATE,'Y','Y','Collect Forecasts',p_version);

        INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(11,'ITEM_ENABLED','VARCHAR2','Y',16,
                'select decode(lookup_code, 1, ''Y'',2,''N'')hidden, meaning display from mfg_lookups where lookup_type = ''SYS_YES_NO''',
                1,SYSDATE,'Y','Y','Collect Items',p_version);

        INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(11,'KPI_BIS_ENABLED','VARCHAR2','Y',17,
                'select decode(lookup_code, 1, ''Y'',2,''N'')hidden, meaning display from mfg_lookups where lookup_type = ''SYS_YES_NO''',
                1,SYSDATE,'Y','Y','Collect Key Performance Indicator Targets',p_version);

        INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(11,'MDS_ENABLED','VARCHAR2','Y',18,
                'select decode(lookup_code, 1, ''Y'',2,''N'')hidden, meaning display from mfg_lookups where lookup_type = ''SYS_YES_NO''',
                1,SYSDATE,'Y','Y','Collect Master Demand Schedules',p_version);

        INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(11,'MPS_ENABLED','VARCHAR2','Y',19,
                'select decode(lookup_code, 1, ''Y'',2,''N'')hidden, meaning display from mfg_lookups where lookup_type = ''SYS_YES_NO''',
                1,SYSDATE,'Y','Y','Collect Master Production Schedules',p_version);

        INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(11,'ON_HAND_ENABLED','VARCHAR2','Y',20,
                'select decode(lookup_code, 1, ''Y'',2,''N'')hidden, meaning display from mfg_lookups where lookup_type = ''SYS_YES_NO''',
                1,SYSDATE,'Y','Y','Collect On Hand',p_version);

        INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(11,'PARAMETER_ENABLED','VARCHAR2','Y',21,
                'select decode(lookup_code, 1, ''Y'',2,''N'')hidden, meaning display from mfg_lookups where lookup_type = ''SYS_YES_NO''',
                1,SYSDATE,'Y','Y','Collect Planning Parameters',p_version);

        INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(11,'PLANNER_ENABLED','VARCHAR2','Y',22,
                'select decode(lookup_code, 1, ''Y'',2,''N'')hidden, meaning display from mfg_lookups where lookup_type = ''SYS_YES_NO''',
                1,SYSDATE,'Y','Y','Planner',p_version);

        INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(11,'PO_RECEIPTS_ENABLED','VARCHAR2','Y',23,
                'select decode(lookup_code, 1, ''Y'',2,''N'')hidden, meaning display from mfg_lookups where lookup_type = ''SYS_YES_NO''',
                1,SYSDATE,'Y','Y','Collect PO Receipts',p_version);

        INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(11,'PROJECT_ENABLED','VARCHAR2','Y',24,
                'select decode(lookup_code, 1, ''Y'',2,''N'')hidden, meaning display from mfg_lookups where lookup_type = ''SYS_YES_NO''',
                1,SYSDATE,'Y','Y','Collect Projects / Tasks',p_version);

        INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(11,'PUR_REQ_PO_ENABLED','VARCHAR2','Y',25,
                'select decode(lookup_code, 1, ''Y'',2,''N'')hidden, meaning display from mfg_lookups where lookup_type = ''SYS_YES_NO''',
                1,SYSDATE,'Y','Y','Collect Purchase Orders / Purchase Requisitions',p_version);

        INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(11,'RESERVES_HARD_ENABLED','VARCHAR2','Y',26,
                'select decode(lookup_code, 1, ''Y'',2,''N'')hidden, meaning display from mfg_lookups where lookup_type = ''SYS_YES_NO''',
                1,SYSDATE,'Y','Y','Reservations',p_version);

        INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(11,'RESOURCE_AVAILABILITY','VARCHAR2','COLLECT_DATA',27,
                'select decode(lookup_code, 1, ''COLLECT_DATA'', 2, ''DO_NOT_COLLECT_DATA'', 3, ''REGENERATE_DATA'') hidden, meaning display from MFG_LOOKUPS where lookup_type=''MSC_NRA_ENABLED''',
                1,SYSDATE,'Y','Y','Collect Resources Availability',p_version);

        INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(11,'SAFE_STOCK_ENABLED','VARCHAR2','Y',28,
                ' select decode(lookup_code, 1, ''Y'',2,''N'')  hidden, meaning display  from mfg_lookups where lookup_type = ''SYS_YES_NO''',
                1,SYSDATE,'Y','Y','Collect Safety Stock',p_version);

        INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(11,'SALES_ORDER_RTYPE','VARCHAR2','N',29,
                'select  decode(lookup_code, 1, ''Y'', 2, ''N'')  hidden, meaning display  from mfg_lookups WHERE lookup_type = ''SYS_YES_NO''',
                1,SYSDATE,'Y','Y','Collect Sales Orders',p_version);

        INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(11,'SOURCING_HISTORY_ENABLED','VARCHAR2','N',30,
                ' select  decode(lookup_code, 1, ''Y'',2,''N'')  hidden, meaning display  from mfg_lookups where lookup_type = ''SYS_YES_NO''',
                1,SYSDATE,'Y','Y','Collect Sourcing History',p_version);

        INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(11,'SOURCING_ENABLED','VARCHAR2','Y',31,
                ' select  decode(lookup_code, 1, ''Y'',2,''N'')  hidden, meaning display  from mfg_lookups where lookup_type = ''SYS_YES_NO''',
                1,SYSDATE,'Y','Y','Collect Sourcing Rules',p_version);

        INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(11,'SUB_INV_ENABLED','VARCHAR2','Y',32,
                ' select  decode(lookup_code, 1, ''Y'',2,''N'')  hidden, meaning display  from mfg_lookups where lookup_type = ''SYS_YES_NO''',
                1,SYSDATE,'Y','Y','Collect Subinventories',p_version);

        INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(11,'SUPPLIER_RESPONSE_ENABLED','VARCHAR2','Y',33,
                ' select  decode(lookup_code, 1, ''Y'',2,''N'')  hidden, meaning display  from mfg_lookups where lookup_type = ''SYS_YES_NO''',
                1,SYSDATE,'Y','Y','Collect Supplier Responses',p_version);

        INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(11,'TP_CUSTOMER_ENABLED','VARCHAR2','Y',34,
                ' select  decode(lookup_code, 1, ''Y'',2,''N'')  hidden, meaning display  from mfg_lookups where lookup_type = ''SYS_YES_NO''',
                1,SYSDATE,'Y','Y','Collect Suppliers/Customers/Orgs',p_version);

        INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(11,'TRIP_ENABLED','VARCHAR2','Y',35,
                ' select  decode(lookup_code, 1, ''Y'',2,''N'')  hidden, meaning display  from mfg_lookups where lookup_type = ''SYS_YES_NO''',
                1,SYSDATE,'Y','Y','Collect Transportation Details',p_version);

        INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(11,'UNIT_NO_ENABLED','VARCHAR2','Y',36,
                ' select  decode(lookup_code, 1, ''Y'',2,''N'')  hidden, meaning display  from mfg_lookups where lookup_type = ''SYS_YES_NO''',
                1,SYSDATE,'Y','Y','Collect Unit Numbers',p_version);

        INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(11,'UOM_ENABLED','VARCHAR2','Y',37,
                ' select  decode(lookup_code, 1, ''Y'',2,''N'')  hidden, meaning display from mfg_lookups where lookup_type = ''SYS_YES_NO''',
                1,SYSDATE,'Y','Y','Collect Units Of Measure',p_version);

        INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(11,'USER_COMPANY_ENABLED','VARCHAR2','NO',38,
                'select  decode(lookup_code, 1, ''NO'', 2, ''ENABLE_UCA'', 3, ''CREATE_USERS_ENABLE_UCA'')  hidden, meaning display ' ||
                'from fnd_lookups where lookup_type = ''MSC_X_USER_COMPANY''',
                1,SYSDATE,'Y','Y','Collect User company Association',p_version);

        INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(11,'USER_SUPPLY_DEMAND','VARCHAR2','Y',39,
                ' select  decode(lookup_code, 1, ''Y'',2,''N'')  hidden, meaning display from mfg_lookups where lookup_type = ''SYS_YES_NO''',
                1,SYSDATE,'Y','Y','Collect User Supplies and Demands',p_version);

                INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(11,'WIP_ENABLED','VARCHAR2','Y',40,
                ' select  decode(lookup_code, 1, ''Y'',2,''N'')  hidden, meaning display from mfg_lookups where lookup_type = ''SYS_YES_NO''',
                1,SYSDATE,'Y','Y','Collect Work in Process',p_version);

                INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(11,'SALES_CHANNEL_ENABLED','VARCHAR2','N',41,
                ' select  decode(lookup_code, 1, ''Y'',2,''N'')  hidden, meaning display from mfg_lookups where lookup_type = ''SYS_YES_NO''',
                1,SYSDATE,'Y','Y','Collect Sales Channel',p_version);

        INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(11,'FISCAL_CALENDAR_ENABLED','VARCHAR2','N',42,
                ' select  decode(lookup_code, 1, ''Y'',2,''N'')  hidden, meaning display from mfg_lookups where lookup_type = ''SYS_YES_NO''',
                1,SYSDATE,'Y','Y','Collect Fiscal Calendar',p_version);

        INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(11,'ITERNAL_REPAIR_ENABLED','VARCHAR2','N',43,
                ' select  decode(lookup_code, 1, ''Y'',2,''N'')  hidden, meaning display from mfg_lookups where lookup_type = ''SYS_YES_NO''',
                1,SYSDATE,'Y','Y','Collect Internal Repair Orders',p_version);

        INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(11,'ETERNAL_REPAIR_ENABLED','VARCHAR2','N',44,
                ' select  decode(lookup_code, 1, ''Y'',2,''N'')  hidden, meaning display  from mfg_lookups where lookup_type = ''SYS_YES_NO''',
                1,SYSDATE,'Y','Y','Collect External Repair Orders',p_version);

        INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(11,'PAYBACK_DEMAND_SUPPLY_ENABLED','VARCHAR2','N',45,
        ' select  decode(lookup_code, 1, ''Y'',2,''N'')  hidden, meaning display  from mfg_lookups where lookup_type = ''SYS_YES_NO''',
                1,SYSDATE,'Y','Y','Enable Pay Back Demand Supply',p_version);

        INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(11,'CURRENCY_CONVERSION_ENABLED','VARCHAR2','N',46,
         ' select  decode(lookup_code, 1, ''Y'',2,''N'')  hidden, meaning display  from mfg_lookups where lookup_type = ''SYS_YES_NO''',
                1,SYSDATE,'Y','Y','Enable Currency Conversion',p_version);

        INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(11,'DELIVERY_DETAILS_ENABLED','VARCHAR2','N',47,
        ' select  decode(lookup_code, 1, ''Y'',2,''N'')  hidden, meaning display  from mfg_lookups where lookup_type = ''SYS_YES_NO''',
                1,SYSDATE,'Y','Y','Enable Delivery Details',p_version);



        INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(11,'ODSTOTALWORKERNUM','NUMBER','3',48,NULL,
                1,SYSDATE,'Y','Y','Number of workers',p_version);


        INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(11,'RECALC_RES_AVAILABILITY','VARCHAR2','Y',49,
                ' select  decode(lookup_code, 1, ''Y'',2,''N'')  hidden, meaning display from mfg_lookups where lookup_type = ''SYS_YES_NO''',
                1,SYSDATE,'Y','Y','Recalculate Sourcing History',p_version);

        INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(11,'PURGE_SOURCING_HISTORY','VARCHAR2','N',50,
                ' select  decode(lookup_code, 1, ''Y'',2,''N'') hidden, meaning display  from mfg_lookups where lookup_type = ''SYS_YES_NO''',
                1,SYSDATE,'Y','Y','Purge Sourcing History',p_version);





        INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(10,'INSTANCE_ID','NUMBER',NULL,1,'select INSTANCE_ID hidden, INSTANCE_CODE Display '||
               'FROM MSC_APPS_INSTANCES '||
               'where instance_type IN (1,2,4) and enable_flag = 1',
               1,SYSDATE,'Y','Y','Instance',p_version);

        INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(10,'COLLECTION_GROUP','VARCHAR','-999',2,
               'select CODE hidden, ORG_GROUP Display FROM MSD_DEM_ORG_GROUPS_V ',
               1,SYSDATE,'Y','Y','Shipment and Booking History -Collection Group',p_version);

        INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(10,'COLLECTION_METHOD','NUMBER',NULL,3,NULL,
         1,SYSDATE,'Y','Y','Shipment and Booking History -Collection Method',p_version);

        INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(10,'DATE_RANGE_TYPE','NUMBER',NULL,4,NULL,
               1,SYSDATE,'Y','Y','Data Range Type',p_version);

        INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(10,'HISTORY_COLLECTION_WINDOW','NUMBER',NULL,5,NULL,
               1,SYSDATE,'N','Y','Shipment and Booking History - History Collection Window',p_version);

        INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(10,'DATE_FROM','DATE',NULL,6,NULL,
                1,SYSDATE,'N','Y','Shipment and Booking History - Date From',p_version);

        INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(10,'DATE_TO','DATE',NULL,7,NULL,
                1,SYSDATE,'N','Y','Shipment and Booking History - Date To',p_version);

        INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(10,'BH_BOOKED_ITEMS_BOOKED_DATE','VARCHAR','N',8,
         'select  decode(lookup_code, 1, ''Y'',2,''N'') hidden, meaning display  from mfg_lookups where lookup_type = ''SYS_YES_NO''',
                1,SYSDATE,'Y','Y','Booking History - Booked Items - Booked Date',p_version);

        INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(10,'BH_BOOKED_ITEMS_REQUESTED_DATE','VARCHAR','N',9,
         'select  decode(lookup_code, 1, ''Y'',2,''N'')  hidden, meaning display from mfg_lookups where lookup_type = ''SYS_YES_NO''',
                1,SYSDATE,'Y','Y','Booking History - Booked Items - Requested  Date',p_version);

        INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(10,'BH_REQUESTED_ITEMS_BOOKED_DATE','VARCHAR','N',10,
         'select  decode(lookup_code, 1, ''Y'',2,''N'')  hidden, meaning display  from mfg_lookups where lookup_type = ''SYS_YES_NO''',
                1,SYSDATE,'Y','Y','Booking History - Requested Items - Booked  Date',p_version);

        INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(10,'BH_REQUESTED_ITEMS_REQUESTED_DATE','VARCHAR','N',11,
         'select  decode(lookup_code, 1, ''Y'',2,''N'')  hidden, meaning display  from mfg_lookups where lookup_type = ''SYS_YES_NO''',
                1,SYSDATE,'Y','Y','Booking History - Requested Items - Requested  Date',p_version);

        INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(10,'SH_SHIPPED_ITEMS_SHIPPED_DATE','VARCHAR','N',12,
         'select  decode(lookup_code, 1, ''Y'',2,''N'')  hidden, meaning display from mfg_lookups where lookup_type = ''SYS_YES_NO''',
                1,SYSDATE,'Y','Y','ShipmentHistory  - Shipped Items - Shipped Date',p_version);

        INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(10,'SH_SHIPPED_ITEMS_REQUESTED_DATE','VARCHAR','N',13,
         'select  decode(lookup_code, 1, ''Y'',2,''N'')  hidden, meaning display from mfg_lookups where lookup_type = ''SYS_YES_NO''',
                1,SYSDATE,'Y','Y','ShipmentHistory  - Shipped Items - Requested Date',p_version);

        INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(10,'SH_REQUESTED_ITEMS_SHIPPED_DATE','VARCHAR','N',14,
         'select  decode(lookup_code, 1, ''Y'',2,''N'')  hidden, meaning display from mfg_lookups where lookup_type = ''SYS_YES_NO''',
                1,SYSDATE,'Y','Y','ShipmentHistory  - Requested Items - Shipped Date',p_version);

        INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(10,'SH_REQUESTED_ITEMS_REQUESTED_DATE','VARCHAR','N',15,
         'select  decode(lookup_code, 1, ''Y'',2,''N'')  hidden, meaning display from mfg_lookups where lookup_type = ''SYS_YES_NO''',
                1,SYSDATE,'Y','Y','ShipmentHistory  - Requested Items - Requested Date',p_version);

        INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(10,'COLLECT_ISO','VARCHAR','N',16,
         'select  decode(lookup_code, 1, ''Y'',2,''N'')  hidden, meaning display  from mfg_lookups where lookup_type = ''SYS_YES_NO''',
                1,SYSDATE,'Y','Y','Collect Internal Sales Orders',p_version);

        INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(10,'COLLECT_ALL_ORDER_TYPES','VARCHAR','Y',17,
         'select  decode(lookup_code, 1, ''Y'',2,''N'')  hidden, meaning display from mfg_lookups where lookup_type = ''SYS_YES_NO''',
                1,SYSDATE,'Y','Y','Collect All Order Types',p_version);

        INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(10,'INCLUDE_ORDER_TYPES','VARCHAR','N',18,NULL,1,SYSDATE,'N','Y','Include Order types',p_version);

        INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(10,'EXCLUDE_ORDER_TYPES','VARCHAR','N',19,NULL,1,SYSDATE,'N','Y','Exclude Order types',p_version);


        INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(10,'LAUNCH_DOWNLOAD','VARCHAR','N',20,
         'select  decode(lookup_code, 1, ''Y'',2,''N'') hidden, meaning display  from mfg_lookups where lookup_type = ''SYS_YES_NO''',
                1,SYSDATE,'Y','Y','Launch Download',p_version);


INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(10,'DATE_FROM3','DATE',NULL,21,NULL,
                1,SYSDATE,'N','Y','Currency Conversions - Date From',p_version);

        INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(10,'DATE_TO3','DATE',NULL,22,NULL,
                1,SYSDATE,'N','Y','Currency Conversions - Date To',p_version);

INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(10,'COLLECT_ALL_CURRENCIES','VARCHAR','N',23,
         'select  decode(lookup_code, 1, ''Y'',2,''N'')  hidden, meaning display from mfg_lookups where lookup_type = ''SYS_YES_NO''',
                1,SYSDATE,'Y','Y','Collect All Currency Conversions',p_version);

        INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(10,'INCLUDE_CURRENCY_LIST','VARCHAR',NULL,24,NULL,
                1,SYSDATE,'N','Y','Include Currency List',p_version);

        INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(10,'EXCLUDE_CURRENCY_LIST','VARCHAR',NULL,25,NULL,
                1,SYSDATE,'N','Y','Exclude Currency List',p_version);

        INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(10,'INCLUDE_ALL','VARCHAR','N',26,
         'select  decode(lookup_code, 1, ''Y'',2,''N'')  hidden, meaning display from mfg_lookups where lookup_type = ''SYS_YES_NO''',
                1,SYSDATE,'Y','Y','Collect All Unit of Measures',p_version);

        INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(10,'INCLUDE_UOM_LIST','VARCHAR',NULL,27,NULL,
                1,SYSDATE,'N','Y','Include Unit of Measures',p_version);

        INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(10,'EXCLUDE_UOM_LIST','VARCHAR',NULL,28,NULL,
                1,SYSDATE,'N','Y','Exclude Unit of Measures',p_version);

        INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(10,'START_DATE','DATE',NULL,29,NULL,
                1,SYSDATE,'Y','Y','Pricing Data - Date From',p_version);

        INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(10,'END_DATE','DATE',NULL,30,NULL,
                1,SYSDATE,'Y','Y','Pricing Data - Date To',p_version);

        INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(10,'INCLUDE_ALL1','VARCHAR','N',31,
         'select  decode(lookup_code, 1, ''Y'',2,''N'')  hidden, meaning display from mfg_lookups where lookup_type = ''SYS_YES_NO''',
                1,SYSDATE,'Y','Y','Collect all Price Lists',p_version);


        INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(10,'INCLUDE_PRICE_LIST','VARCHAR',NULL,32,NULL,
                1,SYSDATE,'N','Y','Include Price Lists',p_version);

        INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(10,'EXCLUDE_PRICE_LIST','VARCHAR',NULL,33,NULL,
                1,SYSDATE,'N','Y','Exclude Price Lists',p_version);

 INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(10,'COLLECTION_GROUP1','VARCHAR','-999',34,
               'select CODE hidden, ORG_GROUP Display FROM MSD_DEM_ORG_GROUPS_V ',
               1,SYSDATE,'Y','Y','Supply Chain Intelligence Data - Collection Group',p_version);

INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(10,'COLLECTION_METHOD1','NUMBER',NULL,35,NULL,
         1,SYSDATE,'Y','Y','Supply Chain Intelligence Data - Collection Method',p_version);

  INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                             PARAM_VERSION)
        VALUES(10,'DATE_RANGE_TYPE1','NUMBER',NULL,36,NULL,
               1,SYSDATE,'Y','Y','Data Range Type',p_version);


        INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(10,'HISTORY_COLLECTION_WINDOW1','NUMBER',NULL,37,NULL,
               1,SYSDATE,'N','Y','Supply Chain Intelligence Data - History Collection Window',p_version);



        INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(10,'DATE_FROM1','DATE',NULL,38,NULL,
                1,SYSDATE,'N','Y','Supply Chain Intelligence Data - Date From',p_version);


        INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                             PARAM_VERSION)
        VALUES(10,'DATE_TO1','DATE',NULL,39,NULL,
                1,SYSDATE,'N','Y','Shipment and Booking History - Date To',p_version);


        INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(13,'NEW_PLAN_NAME','VARCHAR2',NULL,1,NULL,
                1,SYSDATE,'Y','Y','New Plan Name',p_version);

INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(13,'DATA_PROFILE_NAME','VARCHAR2',NULL,2,
         'SELECT SUBSTR(tq.query_name, 1, 50) hidden, SUBSTR(tq.query_name, 1, 50) display '||
    'FROM msd_dem_transfer_list tl, msd_dem_transfer_query tq  ' ||
    'WHERE tl.id = tq.transfer_id AND tq.integration_type <> 1 AND tq.export_type = 1  '||
    'AND tq.presentation_type = 1 AND msd_dem_upload_forecast.is_valid_scenario(tq.id) = 1  ',
                1,SYSDATE,'Y','Y','Data Profile name of the Forecast',p_version);

        INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(13,'ARCHIVE_FLAG','NUMBER',2,3,
                'select lookup_code hidden, meaning display  from mfg_lookups where lookup_type = ''SYS_YES_NO''',
                1,sysdate,'Y','Y','Archive Forecast',p_version);

        INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(19,'NEW_PLAN_NAME','VARCHAR2',NULL,1,NULL,
                1,SYSDATE,'Y','Y','New Plan Name',p_version);

        INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(19,'DATA_PROFILE_NAME','VARCHAR2',NULL,2,
         'SELECT SUBSTR(tq.query_name, 1, 50) hidden, SUBSTR(tq.query_name, 1, 50) display '||
           'FROM msd_dem_transfer_list tl, msd_dem_transfer_query tq  ' ||
           'WHERE tl.id = tq.transfer_id AND tq.integration_type <> 1 AND tq.export_type = 1  '||
           'AND tq.presentation_type = 1 AND msd_dem_upload_forecast.is_valid_scenario(tq.id) = 1  ',
         1,SYSDATE,'Y','Y','Data Profile name of the Forecast',p_version);

        INSERT INTO msc_activity_parameters(ACTIVITY_TYPE,
                                            NAME,
                                            DATA_TYPE,
                                            DEFAULT_VALUE,
                                            SEQUENCE,
                                            SQL,
                                            CREATED_BY,
                                            CREATION_DATE,
                                            REQUIRED,
                                            DISPLAYED,
                                            DISPLAY_NAME,
                                            PARAM_VERSION)
        VALUES(19,'ARCHIVE_FLAG','NUMBER',2,3,
                'select lookup_code hidden, meaning display  from mfg_lookups where lookup_type = ''SYS_YES_NO''',
                1,sysdate,'Y','Y','Archive Forecast',p_version);

commit;

end if;

    exception
        when others then
          commit;
    end insert_seed_data;

    FUNCTION get_plan_name(p_plan_type in number,p_plan_id in number, p_plan_run_id in number) return varchar2 is

        cursor c_plan_name is
        select compile_designator as plan_name
        from msc_plans
        where plan_type = nvl(p_plan_type,plan_type) and plan_id = p_plan_id
        union
        select distinct scenario_name as plan_name
        from msd_dp_ascp_scenarios_v
        where scenario_id=p_plan_id and p_plan_type=10;

        cursor c_plan_name_arch is
        select plan_run_name
        from msc_plan_runs
        where plan_id=p_plan_id and
        plan_run_id = p_plan_run_id;

        cursor c_end_date is
        select end_date
        from msc_plan_runs
        where plan_run_id = p_plan_run_id;

        l_plan_name varchar2(80);
        l_plan_name_arch varchar2(80);
        l_end_date date;
        begin
            if p_plan_run_id is null then
                open c_plan_name;
                fetch c_plan_name into l_plan_name;
                close c_plan_name;
            else
                open c_plan_name_arch;
                fetch c_plan_name_arch into l_plan_name_arch;
                close c_plan_name_arch;
            end if;

            open c_end_date;
            fetch c_end_date into l_end_date;
            close c_end_date;

        --    l_plan_name := l_plan_name||to_char(l_end_date);

            if p_plan_run_id is not null and l_plan_name_arch is not null then
                return l_plan_name_arch;
            else
                return l_plan_name;
            end if;
        end;

    FUNCTION get_owner_name(p_owner_id in number) return varchar2 is
        cursor c_owner_name is
        select user_name
        from fnd_user
        where user_id = p_owner_id;

        l_user_name varchar2(80);
        begin
            open c_owner_name;
            fetch c_owner_name into l_user_name;
            close c_owner_name;

            return l_user_name;
        end;

    FUNCTION get_scn_version(p_version date) return varchar2 is
        l_scn_version varchar2(30);
        begin
            if p_version is null then
                l_scn_version := 'Current';
            else
                l_scn_version := to_char(p_version);
            end if;

            return l_scn_version;
        end;

    FUNCTION get_plan_version(p_plan_run_id in number) return varchar2 is
        cursor c_end_date is
        select end_date
        from msc_plan_runs
        where plan_run_id = p_plan_run_id;

        l_pln_version varchar2(30);
        l_end_date date;
        begin
            if p_plan_run_id is null or p_plan_run_id = -1 then
                l_pln_version := 'Current';
            else
                open c_end_date;
                fetch c_end_date into l_end_date;
                close c_end_date;
                l_pln_version := to_char(l_end_date);
            end if;

            return l_pln_version;
        end;

    FUNCTION get_scenario_name(p_scenario_id in number) return varchar2 is
        cursor c_scn_name is
    select scenario_name
    from msc_scenarios
    where scenario_id = p_scenario_id;

        l_scn_name varchar2(100);
          begin
            open c_scn_name;
            fetch c_scn_name into l_scn_name;
            close c_scn_name;

            return l_scn_name;
        end;

    FUNCTION get_proc_act_name(p_activity_type in number) return varchar2 is
        cursor c_act_name is
            select meaning from mfg_lookups
            where lookup_type = 'MSC_PROCESS_ACTIVITY_TYPES'
            and lookup_code = p_activity_type;

            l_act_name varchar2(100);
                begin
                    open c_act_name;
                    fetch c_act_name into l_act_name;
                    close c_act_name;

                    return l_act_name;
            end;

    procedure copy_scn_plans(p_src_scnId in number, p_dest_scnId in number) is
        l_user_id number;
        l_login_id number;
    begin
        l_user_id := fnd_profile.value ('USER_ID');
        l_login_id := FND_PROFILE.VALUE('LOGIN_ID');
        if(p_src_scnId is not null and p_dest_scnId is not null) then

             insert into msc_scenario_plans (scenario_id,
                                        plan_type,
                                        plan_id,
                                        created_by,
                                        creation_Date  ,
                                        last_update_date,
                                        last_updated_by,
                                        last_update_login,
                                        status,
                                        run_date,
                                        plan_horizon,
                                        plan_run_id)
                               (select  p_dest_scnId,
                                        plan_type,
                                        plan_id,
                                        l_user_id,
                                        sysdate,
                                        sysdate,
                                        l_user_id,
                                        l_login_id,
                                        status,
                                        run_date,
                                        plan_horizon,
                                        plan_run_id from msc_scenario_plans where scenario_id = p_src_scnId);
        end if;
    end copy_scn_plans;

    FUNCTION get_scn_users (p_scn_id in number) return varchar2 is
        cursor c_scn_users is
        select msc_scn_utils.get_owner_name(user_id)
        from msc_scenario_users
        where scenario_id = p_scn_id;

        l_scn_users varchar2(2000) := '';
        l_scn_user varchar2(100);

        begin
            open c_scn_users;
            loop
                fetch c_scn_users into l_scn_user;
                EXIT WHEN c_scn_users%NOTFOUND;
                l_scn_users := l_scn_users||l_scn_user||',';
            end loop;
            close c_scn_users;
            l_scn_users := l_scn_users||l_scn_user;

            return l_scn_users;
        end;

   /* count of scenarios that has this plan*/
    function plan_scns_count(p_plan_id in number, p_scn_id in number, p_plan_run_id in number) return number is
    l_count number := 0;

    cursor c_plans is
    select count(*) from msc_scenario_plans
    where scenario_id <> p_scn_id and plan_id = p_plan_id and plan_run_id = p_plan_run_id;

    begin
        open c_plans;
        fetch c_plans into l_count;
        close c_plans;

        return l_count;
    end;

/* This procedure is called to archive a scenario.
    Logic
    Archive_Scn_Conc looks at all the plans to be archived (Archive_flag in msc_scenario_plans) and
            for every plan_id,
             generate plan_run_id and update plan_run_id field for it.
             call populate_Details api
            end for;
            insert new record into msc_scenarios for current version of the scenario
            update scenario_name,version for this scenario_id by appending sysdate to it
*/


    procedure archive_scn_conc( errbuf out nocopy varchar2, retcode out nocopy varchar2 , p_scn_id in number) is

    cursor c_scn_plans is
    select plan_type,plan_id,run_date
    from msc_scenario_plans
    where scenario_id = p_scn_id and archive_flag = 'Y';

    l_plan_type number;
    l_plan_id number;
    l_run_date date;

    l_plan_run_id number;
    l_scn_name varchar2(50);
    l_err_buf varchar2(240);
    l_user_id number;
    l_login_id number;
    l_new_scn_id number;
    l_scn_count number :=0;

    exc_error_plan_arch EXCEPTION;
    begin
        if p_scn_id is null then
            return;
        end if;

      l_scn_name := msc_scn_utils.get_scenario_name(p_scn_id);
        select count(*) into l_scn_count from msc_scenarios where scenario_name like l_scn_name||' ('||sysdate||')%';
        l_scn_count := l_scn_count+1;
        msc_util.msc_debug('New Scenario Name:'||l_scn_name||' ('||sysdate||')('||l_scn_count||')');
        update msc_scenarios set scn_version = sysdate,scenario_name = scenario_name||' ('||sysdate||')('||l_scn_count||')' where scenario_id = p_scn_id;

        l_user_id := fnd_profile.value ('USER_ID');
        l_login_id := FND_PROFILE.VALUE('LOGIN_ID');

        select msc_scn_scenarios_s.nextval into l_new_scn_id from dual;

      -- Insert rows into msc_scenarios,msc_scenario_plans,msc_scenario_users;

        insert into msc_scenarios(scenario_id,
                                  scenario_name,
                                  created_by,
                                  creation_date,
                                  last_update_date,
                                  last_updated_by,
                                  last_update_login,
                                  parent_scn_id,
                                  description,
                                  owner,
                                  scn_access,
                                  scn_comment,
                                  valid_from,
                                  valid_to,
                                  scn_version,
                                  wc_flag,
                                  gs_name,
                                  gs_name_orig)
                          (select l_new_scn_id,
                                  l_scn_name,
                                  l_user_id,
                                  sysdate,
                                  sysdate,
                                  l_user_id,
                                  l_login_id,
                                  parent_scn_id,
                                  description,
                                  owner,
                                  scn_access,
                                  scn_comment,
                                  valid_from,
                                  valid_to,
                                  null,
                                  wc_flag,
                                  gs_name,
                                  gs_name_orig
                            from msc_scenarios where scenario_id = p_scn_id);

        insert into msc_scenario_plans (scenario_id,
                                        plan_type,
                                        plan_id,
                                        created_by,
                                        creation_Date  ,
                                        last_update_date,
                                        last_updated_by,
                                        last_update_login,
                                        status,
                                        run_date,
                                        plan_horizon,
                                        plan_run_id)
                               (select  l_new_scn_id,
                                        plan_type,
                                        plan_id,
                                        l_user_id,
                                        sysdate,
                                        sysdate,
                                        l_user_id,
                                        l_login_id,
                                        status,
                                        run_date,
                                        plan_horizon,
                                        plan_run_id from msc_scenario_plans where scenario_id = p_scn_id);

        insert into msc_scenario_users  (scenario_id,
                                         user_id,
                                         created_by,
                                         creation_Date,
                                         last_update_date,
                                         last_updated_by,
                                         last_update_login)
                                (select  l_new_scn_id,
                                         user_id,
                                         l_user_id,
                                         sysdate,
                                         sysdate,
                                         l_user_id,
                                         l_login_id from msc_scenario_users where scenario_id = p_scn_id);
        commit;

        open c_scn_plans;
        loop
            fetch c_scn_plans into l_plan_type,l_plan_id,l_run_date;
            exit when c_scn_plans%NOTFOUND;
            l_plan_run_id := msc_phub_pkg.populate_plan_run_info(l_plan_id,l_plan_type);
            msc_phub_pkg.populate_details(errbuf,retcode,l_plan_id,l_plan_run_id);

            if retcode <> 0 then
                --null; -- errored out
                msc_util.msc_debug('Archive Plan Failed for Plan:'||get_plan_name(l_plan_type,l_plan_id,l_plan_run_id));
                raise exc_error_plan_arch;
            end if;
            update msc_scenario_plans set plan_run_id = l_plan_run_id where
            scenario_id = p_scn_id and plan_id = l_plan_id and plan_type = l_plan_type;

            commit;

        end loop;
        close c_scn_plans;

EXCEPTION
        when exc_error_plan_arch then
            if c_scn_plans%isopen then
                    Close c_scn_plans;
            end if;

            retcode := 2;

        when OTHERS THEN
            retcode := 2;
            errbuf := sqlerrm;

    end archive_scn_conc;

    procedure purge_scn_conc( errbuf out nocopy varchar2, retcode out nocopy varchar2 , p_scn_id in number) is

        cursor c_scn_plans is
        select plan_type,plan_id,plan_run_id
        from msc_scenario_plans
        where scenario_id = p_scn_id and purge_flag = 'Y' and plan_run_id is not null;

        cursor c_scn_version is
        select scn_version
        from msc_scenarios
        where scenario_id = p_scn_id;

        l_scn_version date;
        l_plan_type number;
        l_plan_id number;
        l_plan_run_id number;
        exc_error_purge_scn_pln EXCEPTION;
    begin
        open c_scn_version;
        fetch c_scn_version into l_scn_version;
        close c_scn_version;

        if l_scn_version is not null then
            open c_scn_plans;

         loop
            fetch c_scn_plans into l_plan_type,l_plan_id,l_plan_run_id;
            exit when c_scn_plans%NOTFOUND;

            msc_phub_pkg.purge_details(errbuf,retcode,l_plan_id,l_plan_run_id);
            if retcode <> 0 then
                msc_util.msc_debug('Purge Plan Failed for Plan:'||get_plan_name(l_plan_type,l_plan_id,l_plan_run_id));
                raise exc_error_purge_scn_pln;
            end if;

         end loop;
         close c_scn_plans;

        end if;
        delete msc_scenarios where scenario_id = p_scn_id;

        delete msc_scenario_plans where scenario_id = p_scn_id;

        delete msc_Scenario_users where scenario_id = p_scn_id;

        delete msc_Scenario_set_details where scenario_id = p_scn_id;

        commit;
EXCEPTION
        when exc_error_purge_scn_pln then
            if c_scn_plans%isopen then
                    Close c_scn_plans;
            end if;
            retcode := 2;

        when OTHERS THEN
            retcode := 2;
            errbuf := sqlerrm;

    end purge_scn_conc;

    procedure purge_plan_conc( errbuf out nocopy varchar2, retcode out nocopy varchar2 , p_plan_id in number, p_plan_type in number) is
    exc_error_purge_plan EXCEPTION;
    begin
        msc_phub_pkg.purge_details(errbuf,retcode,p_plan_id);
        if retcode <> 0 then
            --null; -- errored out
            raise exc_error_purge_plan;
        end if;

        delete from msc_scenario_plans where plan_id = p_plan_id and plan_type = p_plan_type;
        commit;
EXCEPTION
      when exc_error_purge_plan then
            retcode := 2;

        when OTHERS THEN
            retcode := 2;
            errbuf := sqlerrm;

    end purge_plan_conc;



/*==================================
    query_id --> Activity_type
    char1    --> param_name
    char2   ---> hidden value
    char3   ---> display_value

====================================*/
    procedure populate_act_params_for_lov(p_activity_type in number) is

    cursor c_activity_params is
    select name,sql
    from msc_activity_parameters
    where activity_type = p_activity_type and sql is not null;

    l_count number :=0;
    l_param_name varchar2(80);
    l_sql varchar2(2000);
    l_substr varchar2(2000);
    l_insert varchar2(2000);
    l_select varchar2(2000);
    l_sql_stmnt  varchar2(3000);
    begin
        IF p_activity_type = -99 THEN
            insert_seed_data;
            RETURN;
        END IF;

        select count(*) into l_count from msc_form_query where query_id = p_activity_type;

        if nvl(l_count,0) >0 then
            return;
        end if;

        open c_activity_params;
        loop
            fetch c_activity_params into l_param_name,l_sql;
            exit when c_activity_params%NOTFOUND;

            l_substr := substr(l_sql,instr(upper(l_sql),'SELECT ')+7);
            l_insert := 'insert into msc_form_query (query_id,
                                                     char1,
                                                     last_update_date,
                                                     last_updated_by,
                                                     last_update_login,
                                                     creation_date,
                                                     created_by,
                                                     char2,
                                                     char3)';
            l_select := ' select '||p_activity_type||','||''''||l_param_name||''''||','||'sysdate,1,1,sysdate,1,'||l_substr;

            l_sql_stmnt := l_insert||l_select;

            commit;
            msc_get_name.execute_dsql(l_sql_stmnt);

            commit;
         end loop;
         close c_activity_params;
    end populate_act_params_for_lov;

    FUNCTION Scenario_Status(p_Scenario_id in number) return varchar2 is
    begin
/*
This function returns the status of a scenario based on both
manual activities and plans in that scenario.

We will look into two tables i.e
MSC_SCENARIO_ACTIVITIES
MSC_SCENARIO_PLANS
Logic for deriving Status is as follows:

Scenario status When this condition is satisfied
--------------- --------------------------------
Not started     When all activities (user and system) are not started
In Progress     When atleast 1 activity (user or system) is in progress
Completed       When all activities (user and system) are complete
Error           When atleast 1 activity (user or system) is in error state
Warning         When atleast 1 activity (user or system) is in warning state


MSC_SCN_PLAN_STATUS 1   Completed
MSC_SCN_PLAN_STATUS 2   Error
MSC_SCN_PLAN_STATUS 3   Warning
MSC_SCN_PLAN_STATUS 4   In Progress
*/
        return to_char(null);
    end Scenario_Status;

    FUNCTION plan_Status(p_Plan_id in number) return varchar2 is
        cursor c_plan_status(c_plan_id number) is
            Select
            msc_Get_name.lookup_meaning(
                'MSC_SCN_PLAN_STATUS',
                decode(upper(fcr.status_code),'C',4,'E',3)
                ) plan_status_display
            from  msc_plans mp,
                  msc_plan_runs mpr,
                  fnd_concurrent_requests fcr
            where mp.plan_type is not null and
                mp.plan_id = mpr.plan_id  and
                mpr.end_date is not null and
                mp.plan_completion_date is not null and
                mp.request_id = fcr.request_id
                and mp.plan_id = c_plan_id;
         l_status varchar2(100) :=null;

        begin
            if p_plan_id is null then
                return to_char(null);
            end if;
            open c_plan_Status(p_plan_id);
            fetch c_plan_status into l_status;
            close c_plan_status;
            return to_char(l_status);
        end;


    FUNCTION get_scenario_set_name(p_scenario_set_id in number) return varchar2 is
        cursor c_scn_set_name is
    select scenario_set_name
    from msc_scenario_sets
    where scenario_set_id = p_scenario_set_id;

        l_scn_set_name varchar2(100);
          begin
            open c_scn_set_name;
            fetch c_scn_set_name into l_scn_set_name;
            close c_scn_set_name;

            return l_scn_set_name;
        end;

procedure get_Activity_Summary(where_clause IN OUT NOCOPY varchar2, activity_summary In out NOCOPY varchar2) is
        TYPE DynaCurTyp IS REF CURSOR;
        act_cv   DynaCurTyp;
        sql_stmt VARCHAR2(32000) := null;
        select_query varchar2(32000) := null;
        from_query varchar2(32000) := null;
        l_where_clause varchar2(32000) := null;
        group_by varchar2(32000) :=null;

        source_table varchar2(1000);
        activity_status varchar2(1000);
        ppf varchar2(1000);
        status number;
        summ number;

        act1  number :=0;
        act2  number :=0;
        act3  number :=0;
        act4  number :=0;
        act5  number :=0;
        act6  number :=0;
        act7  number :=0;
        act8  number :=0;
        act9  number :=0;
        act10 number :=0;
        act11 number :=0;
        act12 number :=0;
        act13 number :=0;
        act14 number :=0;
        act15 number :=0;
        act16 number :=0;
        act17 number :=0;
        act18 number :=0;
        act19 number :=0;
        act20 number :=0;
        act21 number :=0;
        act22 number :=0;
        act23 number :=0;
        act24 number :=0;
        act25 number :=0;
        act26 number :=0;
        act27 number :=0;
        act28 number :=0;
        act29 number :=0;
        act30 number :=0;
        act31 number :=0;
        act32 number :=0;
        act33 number :=0;
        act34 number :=0;
        act35 number :=0;
        act36 number :=0;
        tm_not_started number :=0;
        sm_not_started number :=0;
        tm_in_progress number :=0;
        sm_in_progress number :=0;
        tm_error       number :=0;
        sm_error       number :=0;
        act_summary varchar2(32000):=null;

begin
act_summary := act1||','||act2||','||act3||','||act4||','||act5||','||act6||','||act7||','||act8||','||act9||','||act10
||','||act11||','||act12||','||act13||','||act14||','||act15||','||act16||','||act17||','||act18
||','||act19||','||act20||','||act21||','||act22||','||act23||','||act24||','||act25||','||act26
||','||act27||','||act28||','||act29||','||act30||','||act31||','||act32||','||act33||','||act34
||','||act35||','||act36;
        -- select all columns in vo as required
select_query := ' SELECT source_table, msc_get_name.lookup_meaning(''MSC_SCN_ACTIVITY_STATES'',   status) activity_status, ' ;
select_query:= select_query || ' decode(SIGN(finish_by -TRUNC(sysdate) + 0),   -1,   ''PAST_DUE'',   0,   ''CURRENT'',   1,   ''FUTURE'') ppf, ';
select_query:= select_query || ' status, COUNT(activity_id) summ ';
from_query := ' from(select Activity_Name, Activity_Description, Activity_Status, Owner_Name, Finish_By, Activity_Type, Activity_Comment, Scenario_Set_Name, Scenario_Set_Description, Scenario_Name, Scenario_Description, ';
from_query := from_query || ' Scenario_Status, Scenario_Owner_Name, Scenario_Comment, Plan_Name, Plan_Status, Priority_Text, Completed_On, Alternate_Owner_Name, Created_By_User, Creation_Date, Row_Id, Activity_Id, Scenario_Id, ';
from_query := from_query || ' Scenario_set_Id, source_table, Owner, Status, created_by, last_update_date, Last_updated_by, last_update_login, Priority, Alternate_Owner, Scenario_owner from ( (select  ';
from_query := from_query || ' msa.Activity_Name Activity_Name, msa.Description Activity_Description, msc_get_name.lookup_meaning(''MSC_SCN_ACTIVITY_STATES'',msa.Status) Activity_Status, msc_pers_queries.get_user(msa.owner) owner_name, ';
from_query := from_query || ' trunc(msa.Finish_By) Finish_By, ''Manual'' activity_type, msa.Act_Comment Activity_Comment,     mss.scenario_set_name Scenario_Set_Name, mss.Description Scenario_Set_Description, ms.scenario_name Scenario_Name, ';
from_query := from_query || ' ms.Description Scenario_Description, msc_scn_utils.Scenario_Status(msa.scenario_id) Scenario_Status, msc_pers_queries.get_user(ms.owner) Scenario_Owner_Name, ms.Scn_Comment Scenario_Comment, to_char(Null) Plan_Name, ';
from_query := from_query || ' to_char(NULL) Plan_Status, msc_get_name.lookup_meaning(''MSC_SCN_PRIORITIES'',msa.Priority) Priority_Text, msa.Completed_On Completed_On,     msc_pers_queries.get_user(msa.alternate_owner) alternate_owner_name, ';
from_query := from_query || ' msc_pers_queries.get_user(msa.created_by) Created_By_User, msa.Creation_date, msa.rowid ROW_ID, msa.Activity_Id, msa.Scenario_Id, msa.Scenario_set_Id, ''MSA'' source_table, ';
from_query := from_query || ' msa.Owner, msa.Status Status, msa.created_by, msa.last_update_date, msa.Last_updated_by, msa.last_update_login, msa.Priority, msa.Alternate_Owner, ms.owner Scenario_Owner FROM  MSC_SCENARIO_ACTIVITIES MSA, ';
from_query := from_query || ' MSC_SCENARIOS MS,  MSC_SCENARIO_SETS MSS WHERE ';
from_query := from_query || ' MSA.SCENARIO_ID=MS.SCENARIO_ID(+) AND MSA.SCENARIO_SET_ID=MSS.SCENARIO_SET_ID(+) and status in (1,2,4)) union ';
from_query := from_query || ' (select concat(concat(mpp.process_name,'' - ''),msc_get_name.lookup_meaning(''MSC_PROCESS_ACTIVITY_TYPES'',MPPA.Activity_Type)) Activity_Name, to_char(NULL) Activity_Description, ';
from_query := from_query || ' msc_get_name.lookup_meaning(''MSC_SCN_ACTIVITY_STATES'',MPPA.Status) Activity_Status, msc_pers_queries.get_user(MPPA.owner) Owner_Name, trunc(mppa.creation_date + nvl(time_out,0))  ';
from_query := from_query || ' Finish_By, to_char(decode(MPPA.activity_type,14,''Manual'',15,''Manual'',16,''Manual'',17,''Manual'',18,''Manual'',20,''Manual'',22,''Manual'',23,''Manual'',''System'' ) )  Activity_Type, ';
from_query := from_query || ' to_char(NULL) Activity_Comment, to_char(NULL) Scenario_Set_Name, to_CHAR(NULL) Scenario_Set_Description, to_char(NULL) Scenario_Name, ';
from_query := from_query || ' to_CHAR(NULL) Scenario_Description, to_char(NULL) Scenario_Status, to_CHAR(NULL) Scenario_Owner_Name, to_CHAR(NULL) Scenario_Comment, msc_scn_utils.get_plan_Name(MPPA.Activity_Type,MPPA.plan_id,null) Plan_Name, ';
from_query := from_query || ' msc_scn_utils.plan_status(MPPA.plan_id) Plan_Status, to_CHAR(NULL) Priority_Text, ';
from_query := from_query || ' to_date(NULL) Completed_On,msc_pers_queries.get_user(MPPA.alternate_owner) Alternate_Owner_Name,msc_pers_queries.get_user(MPPA.created_by) ';
from_query := from_query || ' Created_By_User, MPPA.Creation_date Creation_Date, mppa.rowid ROW_ID, MPPA.Activity_Id Activity_Id, to_number(NULL) Scenario_Id, to_number(NULL) Scenario_Set_Id, ';
from_query := from_query || ' decode (to_char(decode(MPPA.activity_type,14,''Manual'',15,''Manual'',16,''Manual'',17,''Manual'',18,''Manual'',20,''Manual'',22,''Manual'',23,''Manual'',''System'' ) ),''Manual'',''MSA'',''MPPA'') ';
from_query := from_query || ' SOURCE_TABLE, MPPA.Owner Owner,';
from_query := from_query || ' MPPA.Status Status, MPPA.created_by, MPPA.last_update_date, MPPA.Last_updated_by, MPPA.last_update_login, to_number(NULL) Priority, MPPA.Alternate_Owner Alternate_Owner, to_number(NULL) Scenario_Owner ';
from_query := from_query || ' from  msc_planning_proc_activities MPPA, msc_planning_process mpp where MPPA.status  in (1,2,4) and mppa.run_sequence=mpp.curr_run_sequence and mppa.process_id=mpp.process_id ) )) from_query';
l_where_clause := ' where ';
        --dbms_output.put_line(' 1');
        --dbms_output.put_line(' printing from within proc: ' || where_clause);
        --dbms_output.put_line(' 2');
        l_where_clause := l_where_clause || where_clause;

        --l_where_clause := l_where_clause || ' 1=1  AND ( (''MSA'' = SOURCE_TABLE) AND ( scenario_id is null or (1063,scenario_id) in (select user_id,scenario_id from msc_scenario_users) ) ) OR ''MPPA'' = source_table';
        -- create a summary query on top of form_query
        group_by := 'GROUP BY source_table, status, SIGN(finish_by -TRUNC(sysdate) + 0) ORDER BY 1,  3, 2';
        --dbms_output.put_line(' 3');
        sql_stmt := select_query || ' ' || from_query || ' ' || l_where_clause || ' ' || group_by;
        --dbms_output.put_line(' 4');
        --dbms_output.put_line (sql_stmt);
        OPEN act_cv FOR sql_stmt;
        LOOP
          FETCH act_cv INTO source_table, activity_status,ppf,status,summ;
          EXIT WHEN act_cv%NOTFOUND;
          -- process record
          If source_table = 'MSA' then --stuff values for Manual activities
            -- get values for 'PAST_DUE', 'CURRENT', 'FUTURE'
        --dbms_output.put_line(' 5');
            if ppf = 'PAST_DUE' then
                if STATUS = 1 THEN --Not Started
                    tm_not_started := tm_not_started + summ;
                    act1 := summ;
                elsif status=2 then-- In Progress
                    tm_in_progress := tm_in_progress + summ;
                    act5 := summ;
                elsif status = 4 then -- Error
                    tm_error := tm_error + summ;
                    act9 := summ;
                end if;

            elsif ppf= 'CURRENT' then
                if STATUS = 1 THEN --Not Started
                    tm_not_started := tm_not_started + summ;
                    act2 := summ;
                elsif status=2 then -- In Progress
                    tm_in_progress := tm_in_progress + summ;
                    act6 := summ;
                elsif status = 4 then -- Error
                    tm_error := tm_error + summ;
                    act10 := summ;
                end if;

            elsif ppf='FUTURE' then
                if STATUS = 1 THEN --Not Started
                    tm_not_started := tm_not_started + summ;
                    act3 := summ;
                elsif status=2 then -- In Progress
                    tm_in_progress := tm_in_progress + summ;
                    act7 := summ;
                elsif status = 4 then -- Error
                    tm_error := tm_error + summ;
                    act11 := summ;
                end if;
            end if;
          elsif source_table = 'MPPA' then --stuff values for System activities

            -- get values for 'PAST_DUE', 'CURRENT', 'FUTURE'
            if ppf = 'PAST_DUE' then
                if STATUS = 1 THEN --Not Started
                    sm_not_started := sm_not_started + summ;
                    act17 := summ;
                elsif status=2 then -- In Progress
                    sm_in_progress := sm_in_progress + summ;
                    act21 := summ;
                elsif status = 4 then -- Error
                    sm_error := sm_error + summ;
                    act25 := summ;
                end if;

            elsif ppf= 'CURRENT' then
                if STATUS = 1 THEN --Not Started
                    sm_not_started := sm_not_started + summ;
                    act18 := summ;
                elsif status=2 then -- In Progress
                    sm_in_progress := sm_in_progress + summ;
                    act22 := summ;
                elsif status = 4 then -- Error
                    sm_error := sm_error + summ;
                    act26 := summ;
                end if;

            elsif ppf='FUTURE' then
                if STATUS = 1 THEN --Not Started
                    sm_not_started := sm_not_started + summ;
                    act19 := summ;
                elsif status=2 then -- In Progress
                    sm_in_progress := sm_in_progress + summ;
                    act23 := summ;
                elsif status = 4 then -- Error
                    sm_error := sm_error + summ;
                    act27 := summ;
                end if;
            end if;
          end if;
        END LOOP;

        act13 := act1+act5+act9;
        act14 := act2+act6+act10;
        act15 := act3+act7+act11;

        act29 := act17+act21+act25;
        act30 := act18+act22+act26;
        act31 := act19+act23+act27;

        act4:= tm_not_started;
        act8:= tm_in_progress;
        act12:= tm_error;
        act16:= tm_not_started+tm_in_progress+tm_error;

        act20:= sm_not_started;
        act24:= sm_in_progress;
        act28:= sm_error;
        act32:= sm_not_started+sm_in_progress+sm_error;

        act33 :=tm_not_started+sm_not_started;
        act34 :=tm_in_progress+sm_in_progress;
        act35 :=tm_error+sm_error;
        act36 :=act33+act34+act35;
        CLOSE act_cv;

        act_summary := act1||','||act2||','||act3||','||act4||','||act5||','||act6||','||act7||','||act8||','||act9||','||act10
            ||','||act11||','||act12||','||act13||','||act14||','||act15||','||act16||','||act17||','||act18
            ||','||act19||','||act20||','||act21||','||act22||','||act23||','||act24||','||act25||','||act26
            ||','||act27||','||act28||','||act29||','||act30||','||act31||','||act32||','||act33||','||act34
            ||','||act35||','||act36;
    activity_summary:=act_summary;

EXCEPTION when others THEN
    activity_summary:=act_summary;
raise_application_error(-20000,'Failed to do the due to the following error: ' || sqlcode || sqlerrm);

end get_Activity_Summary;

      function get_plan_run_date(p_plan_type in number,p_plan_id in number) return date is
        cursor c_run_date is
            select plan_completion_date
            from msc_plans
            where plan_type = p_plan_type and
            plan_id = p_plan_id;

        cursor c_dem_run_date is
            select last_update_date
            from msd_dp_scenario_revisions mdr,
                 msd_dp_ascp_scenarios_v mdas
            where mdr.scenario_id=mdas.scenario_id and
                  mdr.revision = mdas.last_revision;

        l_run_date date;
        begin
            if p_plan_type <>10 then
                open c_run_date;
                fetch c_run_date into l_run_date;
                close c_run_date;
            else
                open c_dem_run_date;
                fetch c_dem_run_date into l_run_date;
                close c_dem_run_date;
            end if;

            return l_run_date;
        end get_plan_run_date;

function get_process_status(p_process_id in number,p_curr_run_seq in number) return number is
    cursor c_activity_status is
    select
    nvl(
      decode(s5,0,5,1,5,
            decode(s4,0,4,1,4,
                    decode(s6,0,6,1,6,
                          decode(s2,0,2,1,2,
                                decode(s1,0,1,1,1,3)
                                )
                          )
                    )
          ),3)
          proc_status from
    (select
    sign(sum(decode(status,1,1,0))-1) s1,
    sign(sum(decode(status,2,1,0))-1) s2,
    sign(sum(decode(status,3,1,0))-1) s3,
    sign(sum(decode(status,4,1,0))-1) s4,
    sign(sum(decode(status,5,1,0))-1) s5,
    sign(sum(decode(status,6,1,0))-1) s6
    from msc_planning_proc_activities
    where
            process_id = p_process_id
            and run_sequence = p_curr_run_seq
            and skip=2) a;
    l_process_status number := 3;
    begin
    if(p_curr_run_seq = 0) then
        return 1;
    end if;
        open c_activity_status;
        if c_activity_status%NOTFOUND then
            return 3;
        end if;
        fetch c_activity_status into l_process_status;
        close c_activity_status;
        return l_process_status;
    exception when others then
        return 3;
end get_process_status;

   procedure populate_default_params(p_activity_type IN OUT NOCOPY  number,param_default IN OUT NOCOPY varchar2) is

    cursor c_activity_params is
                SELECT sequence,sql,default_value from msc_activity_parameters
                where activity_type = p_activity_type and sql is not null and
                default_value is not null;

        l_param_sequence NUMBER;
        l_sql varchar2(3000);
        l_default varchar2(300);
        l_sql_stmt varchar2(3000);
        l_hidden varchar2(200);
        l_display varchar2(200);
        l_return varchar2(3000) := '';
begin
        open c_activity_params;
        loop
        fetch c_activity_params into l_param_sequence,l_sql,l_default;
            exit when c_activity_params%NOTFOUND;
            l_sql_stmt := 'select hidden,display from (' || l_sql || ') where hidden = ''' || l_default || '''';

            EXECUTE IMMEDIATE l_sql_stmt INTO l_hidden,l_display;
            l_return := l_return || l_param_sequence || '#' || l_display || '#';
    end loop;
    close c_activity_params;
    param_default := l_return;
   end populate_default_params;

    procedure create_scenario( errbuf out nocopy varchar2, retcode out nocopy
varchar2,
      p_scn_name varchar2, p_description varchar2,
      p_owner number, p_scn_version date,
      p_scn_access number, p_scn_comment varchar2,
      p_valid_from date, p_valid_to date,
      p_plan_id_arr msc_scn_utils.number_arr,
      p_users_arr  msc_scn_utils.number_arr
      ) is
      l_scn_id number;
      l_scn_name varchar2(100);
      l_description varchar2(240);
      l_owner number;
      l_scn_version date;
      l_scn_access number;
      l_scn_comment varchar2(4000);
      l_valid_from date;
      l_valid_to date;
      l_login_id number;
      l_user_id number;

      l_plan_run_id number;
      l_plan_type number;
      l_status number;
      l_run_date date;
      l_plan_horizon date;

      cursor c_scn is
      select scenario_id
      from msc_scenarios
      where scenario_name = p_scn_name;
      l_temp number;

      cursor c_plan_type (ll_plan_id number) is
      select curr_plan_type
      from msc_plans
      where plan_id = ll_plan_id;

      cursor c_scn_plan (p_scn_id number, p_plan_id number) is
      select count(*)
      from msc_scenario_plans
      where scenario_id = p_scn_id
        and plan_id = p_plan_id;

    begin
       --validation begins
        if p_scn_name is null then
      errbuf := 'Scenario Name should not be null';
          retcode := -1;
          return;
    else
          open c_scn;
      fetch c_scn into l_scn_id;
      close c_scn;
        end if;
       --validation ends


        if (l_scn_id is null) then
    --copy all params
        l_scn_name :=  p_scn_name;
        l_description := p_description;
        l_owner := 0;
        l_scn_version := p_scn_version;
        l_scn_access  := p_scn_access;
        l_scn_comment := p_scn_comment;
        l_valid_from := nvl(p_valid_from, sysdate);
        l_valid_to := p_valid_to;
        l_login_id := 0;
        l_user_id := 0;

        select msc_scn_scenarios_s.nextval into l_scn_id from dual;

        --Insert rows into msc_scenarios,msc_scenario_plans,msc_scenario_users;

        insert into msc_scenarios (scenario_id, scenario_name,
          created_by, creation_date, last_update_date, last_updated_by, last_update_login,
          parent_scn_id, description, owner,
          scn_access, scn_comment, valid_from, valid_to, scn_version)
        values
        (l_scn_id, l_scn_name,
         l_user_id, sysdate, sysdate, l_user_id, l_login_id,
         to_number(null), l_description, l_owner,
     l_scn_access, l_scn_comment, l_valid_from, l_valid_to, to_date(null));
        end if;

        for i in 1..p_plan_id_arr.count
    loop
      if (p_plan_id_arr(i) <> 0) then
      l_plan_run_id := null;
          l_plan_type  := null;
          l_status  := null;
          l_run_date  := null;
          l_plan_horizon  := null;

          open c_scn_plan (l_scn_id, p_plan_id_arr(i));
          fetch c_scn_plan into l_temp;
          close c_scn_plan;

          if (l_temp = 0) then
          open c_plan_type(p_plan_id_arr(i));
      fetch c_plan_type into l_plan_type;
      close c_plan_type;

          insert into msc_scenario_plans (scenario_id, plan_type, plan_id,
            created_by, creation_Date, last_update_date, last_updated_by, last_update_login,
            status, run_date, plan_horizon, plan_run_id)
         values
           (l_scn_id, l_plan_type, p_plan_id_arr(i),
        l_user_id, sysdate, sysdate, l_user_id, l_login_id,
            l_status, l_run_date, l_plan_horizon, l_plan_run_id);
         end if;
     end if;
    end loop;

        for i in 1..p_users_arr.count
    loop
          begin
          insert into msc_scenario_users  (scenario_id, user_id,
            created_by, creation_Date, last_update_date, last_updated_by, last_update_login)
          values
        (l_scn_id, p_users_arr(i),
            l_user_id, sysdate, sysdate, l_user_id, l_login_id);
          exception
            when others then
              null;
          end;
    end loop;

        commit;
    errbuf := null;
        retcode := l_scn_id;
        return;
    end create_scenario;


END MSC_SCN_UTILS;

/
