--------------------------------------------------------
--  DDL for Package Body PJI_PJP_SUM_CUST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PJI_PJP_SUM_CUST" as
  /* $Header: PJISC01B.pls 120.0.12010000.2 2009/06/11 07:36:07 rmandali ship $ */

  -- -----------------------------------------------------
  -- procedure PJP_CUSTOM_FPR_API
  --
  --   Attention Project Performance customer:
  --
  --   This API should be used to implement custom measures in the
  --   Financial Planning Reporting Lines fact: PJI_FP_XBS_ACCUM_F.
  --
  --   1. Only modify code in the indicated area.
  --   2. Do not issue any statements that result in a "commit" or a "rollback"
  --   3. Only populate PJI_FP_CUST_PJP0.
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- -----------------------------------------------------
  procedure PJP_CUSTOM_FPR_API (p_worker_id in number) is

    l_process         varchar2(30);
    l_batch_id        number;
    l_extraction_type varchar2(15);
    l_pji_schema      varchar2(30);

  begin

    l_process := PJI_PJP_SUM_MAIN.g_process ||
                 to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP
        (l_process,
         'PJI_PJP_SUM_CUST.PJP_CUSTOM_FPR_API(p_worker_id);')) then
      return;
    end if;

    l_batch_id := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                  (l_process, 'CURRENT_BATCH');

    l_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                         (l_process, 'EXTRACTION_TYPE');

    l_pji_schema := PJI_UTILS.GET_PJI_SCHEMA_NAME;

    /**************************************************************
     *                                                            *
     * Insert custom measures code after this box comment         *
     *                                                            *
     *                                                            *
     * IMPORTANT:  DO NOT INCLUDE ANY COMMIT STATEMENTS IN THE    *
     *             CUSTOM CODE.                                   *
     *                                                            *
     *                                                            *
     **************************************************************/

    /**************************************************************************************************************
     *                                                                                                            *
     * Sample code with steps to customize custom measures for FP CUSTOM MEASURE TABLE(i.e.PJI_FP_CUST_PJP0) table*
     *                                                                                                            *
     *                                                                                                            *
     * FP BASIS TABLE ( I.E. PJI_FP_AGGR_PJP0)                                                                    *
     * --------------------------------------                                                                     *
     *  This table is the first aggregation point after the transaction accum tables and provides a basis for     *
     *  custom measures. This table has to be populated to store customized measures. It holds the mandatory      *
     *  keys, which are being used, in custom table (i.e. PJI_FP_CUST_PJP0) to store customized measures.         *
     *  To see the definition of this table and its columns, please refer ETRM.                                   *
     *                                                                                                            *
     * MANDOTORY PREREQUISTE TO DEFINE CUSTOM MEASURE                                                             *
     * ---------------------------------------------                                                              *
     *  1. Basis Table PJI_FP_AGGR_PJP0 should be populated                                                       *
     *   WHAT IF FP BASIS TABLE IS NOT POPULATED                                                                  *
     *   --------------------------------------                                                                   *
     *    If the basis table is not populated then the program will not use and store the customized measures     *
     *    at all.                                                                                                 *
     *                                                                                                            *
     * FP CUSTOM MEASURES TABLE ( I.E. PJI_FP_CUST_PJP0)                                                          *
     * -------------------------------------------------                                                          *
     *  This table is used to derive PJP custom measures only if derived measures are available in context        *
     *  of RESOURCE and TASK. After customizing the custom measures, they are stored in this table.               *
     *  Following is the list of custom measure available:                                                        *
     *  1. WORKER_ID                 Identify the set of data used by a particular process so that                *
     *                               when other process is running should not pickup the same record.             *
     *  2. TXN_ACCUM_HEADER_ID       Identifier for the transaction header                                        *
     *  3. PROJECT_ID                Identifier for the project                                                   *
     *  4. PROJECT_ORG_ID            Identifier of the Project Operating Unit                                     *
     *  5. PROJECT_ORGANIZATION_ID   Identifier of the Project Organization                                       *
     *  6. PROJECT_ELEMENT_ID        This is the WBS element id and consists of projects and tasks.               *
     *  7. TIME_ID                   Numeric identifier for time                                                  *
     *  8. PERIOD_TYPE_ID            Numeric identifier for the period type (period, quarter, year, weeks)        *
     *  9. CALENDAR_TYPE             Specifies the calendar type (PA, GL, Enterprise)                             *
     *  10. RBS_AGGR_LEVEL           Indicates, for the current task, the type of RBS aggregation.                *
     *                               'L' = Lowest (data extracted from the transaction system)                    *
     *                               'R' = Rollup (date rollup up by RBS)'T' = Top (Common amount that is         *
     *                               the sum total of a given RBS structure for the current task.)                *
     *  11. WBS_ROLLUP_FLAG          Indicates, for the given project structure version, whether the amounts      *
     *                               are rolled up by WBS or not.'N' = No (Task self amounts.)                    *
     *                               'Y' = Yes (Task amounts rolled up by WBS.                                    *
     *                               Rolled up amounts do not include self amounts.)                              *
     *  12. PRG_ROLLUP_FLAG          Indicates whether the amounts are rolled up by Project Hierarchy or not.     *
     *                               'N' = No (Amounts within a given project.)                                   *
     *                               'Y' = Yes (Project structure version amounts rolled up by Project            *
     *                               Hierarchy. Rolled up amounts do not include self amounts.)                   *
     *  13. CURR_RECORD_TYPE_ID      Identifier for the Currency record type                                      *
     *  14. CURRENCY_CODE            Currency Code                                                                *
     *  15. RBS_ELEMENT_ID           Identifier for the RBS                                                       *
     *  16. RBS_VERSION_ID           Identifier for the RBS version                                               *
     *  17. PLAN_VERSION_ID          Same as Budget version identifier.                                           *
     *                               >0 = version id, -1 = Actuals, -2 = Progress Actuals,                        *
     *                               -3 = Current Baselined, -4 = Current Original Baselined                      *
     *  18. PLAN_TYPE_ID             Identifier of the Plan Type                                                  *
     *  19. There are 15 custom measures available to store the customized data.                                  *
     *                                                                                                            *
     * PJI LOOKUP TABLE ( I.E. PJI_FP_TXN_ACCUM_HEADER) FOR CUSTOM MEASURES                                       *
     * --------------------------------------------------------------------                                       *
     * This table stores all-important information regarding the transactions used in customizing measures.       *
     * It has 26 attributes/filers, which can be used to customize measure in a very precise manor                *
     * E.g. If user want to use different amount for timecard having expenditure type is 'Airfare'                *
     * and it should belong to a particular expenditure org then EXPENDITURE_TYPE and                             *
     * EXPENDITURE_ORG_ID attribute can be used to filter. Please see example in example section to understand    *
     * more clearly. To see the complete definition of this table and its columns, please refer ETRM              *
     *                                                                                                            *
     * EXAMPLE TO CUSTOMIZE CUSTOM MEASURES                                                                       *
     * ------------------------------------                                                                       *
     *  - Customizing a measure using  EXPENDITURE_TYPE, and EXPENDITURE_ORG_ID                                   *
     *  - Define computation logic for custom measure 1                                                           *
     *  - Remove 1=2 from the SELECT part                                                                         *
     * INSERT INTO PJI_FP_CUST_PJP0 cust_i                                                                        *
     * (                                                                                                          *
     *   WORKER_ID,                                                                                               *
     *   TXN_ACCUM_HEADER_ID,                                                                                     *
     *   PROJECT_ID,                                                                                              *
     *   PROJECT_ORG_ID,                                                                                          *
     *   PROJECT_ORGANIZATION_ID,                                                                                 *
     *   PROJECT_ELEMENT_ID,                                                                                      *
     *   TIME_ID,                                                                                                 *
     *   PERIOD_TYPE_ID,                                                                                          *
     *   CALENDAR_TYPE,                                                                                           *
     *   RBS_AGGR_LEVEL,                                                                                          *
     *   WBS_ROLLUP_FLAG,                                                                                         *
     *   PRG_ROLLUP_FLAG,                                                                                         *
     *   CURR_RECORD_TYPE_ID,                                                                                     *
     *   CURRENCY_CODE,                                                                                           *
     *   RBS_ELEMENT_ID,                                                                                          *
     *   RBS_VERSION_ID,                                                                                          *
     *   PLAN_VERSION_ID,                                                                                         *
     *   PLAN_TYPE_ID,                                                                                            *
     *   CUSTOM1,                                                                                                 *
     *   CUSTOM2,                                                                                                 *
     *   CUSTOM3,                                                                                                 *
     *   CUSTOM4,                                                                                                 *
     *   CUSTOM5,                                                                                                 *
     *   CUSTOM6,                                                                                                 *
     *   CUSTOM7,                                                                                                 *
     *   CUSTOM8,                                                                                                 *
     *   CUSTOM9,                                                                                                 *
     *   CUSTOM10,                                                                                                *
     *   CUSTOM11,                                                                                                *
     *   CUSTOM12,                                                                                                *
     *   CUSTOM13,                                                                                                *
     *   CUSTOM14,                                                                                                *
     *   CUSTOM15                                                                                                 *
     *   )                                                                                                        *
     * SELECT                                                                                                     *
     *   p_worker_id,                                                                                             *
     *   pjp0.TXN_ACCUM_HEADER_ID,                                                                                *
     *   pjp0.PROJECT_ID,                                                                                         *
     *   pjp0.PROJECT_ORG_ID,                                                                                     *
     *   pjp0.PROJECT_ORGANIZATION_ID,                                                                            *
     *   pjp0.PROJECT_ELEMENT_ID,                                                                                 *
     *   pjp0.TIME_ID,                                                                                            *
     *   pjp0.PERIOD_TYPE_ID,                                                                                     *
     *   pjp0.CALENDAR_TYPE,                                                                                      *
     *   pjp0.RBS_AGGR_LEVEL,                                                                                     *
     *   pjp0.WBS_ROLLUP_FLAG,                                                                                    *
     *   pjp0.PRG_ROLLUP_FLAG,                                                                                    *
     *   pjp0.CURR_RECORD_TYPE_ID,                                                                                *
     *   pjp0.CURRENCY_CODE,                                                                                      *
     *   pjp0.RBS_ELEMENT_ID,                                                                                     *
     *   pjp0.RBS_VERSION_ID,                                                                                     *
     *   pjp0.PLAN_VERSION_ID,                                                                                    *
     *   pjp0.PLAN_TYPE_ID,                                                                                       *
     *   -- Custom measure 1                                                                                      *
     *   DECODE(pjilookup.expenditure_type,'Airfare',DECODE(pjilookup.expenditure_org_id,-1,100,50),0) CUSTOM1,   *
     *   -- Custom measure 1                                                                                      *
     *   TO_NUMBER(NULL)                               CUSTOM2,                                                   *
     *   TO_NUMBER(NULL)                               CUSTOM3,                                                   *
     *   TO_NUMBER(NULL)                               CUSTOM4,                                                   *
     *   TO_NUMBER(NULL)                               CUSTOM5,                                                   *
     *   TO_NUMBER(NULL)                               CUSTOM6,                                                   *
     *   TO_NUMBER(NULL)                               CUSTOM7,                                                   *
     *   TO_NUMBER(NULL)                               CUSTOM8,                                                   *
     *   TO_NUMBER(NULL)                               CUSTOM9,                                                   *
     *   TO_NUMBER(NULL)                               CUSTOM10,                                                  *
     *   TO_NUMBER(NULL)                               CUSTOM11,                                                  *
     *   TO_NUMBER(NULL)                               CUSTOM12,                                                  *
     *   TO_NUMBER(NULL)                               CUSTOM13,                                                  *
     *   TO_NUMBER(NULL)                               CUSTOM14,                                                  *
     *   TO_NUMBER(NULL)                               CUSTOM15                                                   *
     * FROM                                                                                                       *
     *   PJI_FP_AGGR_PJP0 pjp0 -- FP basis table,                                                                 *
     *   PJI_FP_TXN_ACCUM_HEADER pjilookup -- PJI Lookup table                                                    *
     * WHERE                                                                                                      *
     *   pjp0.WORKER_ID = p_worker_id                                                                             *
     *   AND  pjp0.TXN_ACCUM_HEADER_ID = pjilookup.TXN_ACCUM_HEADER_ID;                                           *
     *                                                                                                            *
     * LIMITATION TO CUSTOMIZE CUSTOM MEASURES                                                                    *
     * --------------------------------------                                                                     *
     *  1. Currently, User can customize any measure available in Oracle Projects.                                *
     *  2. Only Number data type can be stored in Custom measures.                                                *
     *  3. The summarization always extracts incremental records from the transaction source.  If the custom      *
     *     measures are defined on an amount column from the basis table, then they are always computed on        *
     *     incremental values. However, if the custom measures are derived from other sources then the custom     *
     *     pl/sql logic has to ensure that it derives incremental amounts (ie., change since the last time        *
     *     summarization has been run).                                                                           *
     *  4. Custom 11 to 15 are exclusively for the Commitment related custom measures and thus these columns      *
     *     would be processesed similar to that of Commitments                                                    *
     **************************************************************************************************************/

    INSERT INTO PJI_FP_CUST_PJP0 cust_i
    (
      WORKER_ID,
      TXN_ACCUM_HEADER_ID,
      PROJECT_ID,
      PROJECT_ORG_ID,
      PROJECT_ORGANIZATION_ID,
      PROJECT_ELEMENT_ID,
      TIME_ID,
      PERIOD_TYPE_ID,
      CALENDAR_TYPE,
      RBS_AGGR_LEVEL,
      WBS_ROLLUP_FLAG,
      PRG_ROLLUP_FLAG,
      CURR_RECORD_TYPE_ID,
      CURRENCY_CODE,
      RBS_ELEMENT_ID,
      RBS_VERSION_ID,
      PLAN_VERSION_ID,
      PLAN_TYPE_ID,
      CUSTOM1,
      CUSTOM2,
      CUSTOM3,
      CUSTOM4,
      CUSTOM5,
      CUSTOM6,
      CUSTOM7,
      CUSTOM8,
      CUSTOM9,
      CUSTOM10,
      CUSTOM11,
      CUSTOM12,
      CUSTOM13,
      CUSTOM14,
      CUSTOM15
    )
    SELECT
      p_worker_id,
      pjp0.TXN_ACCUM_HEADER_ID,
      pjp0.PROJECT_ID,
      pjp0.PROJECT_ORG_ID,
      pjp0.PROJECT_ORGANIZATION_ID,
      pjp0.PROJECT_ELEMENT_ID,
      pjp0.TIME_ID,
      pjp0.PERIOD_TYPE_ID,
      pjp0.CALENDAR_TYPE,
      pjp0.RBS_AGGR_LEVEL,
      pjp0.WBS_ROLLUP_FLAG,
      pjp0.PRG_ROLLUP_FLAG,
      pjp0.CURR_RECORD_TYPE_ID,
      pjp0.CURRENCY_CODE,
      pjp0.RBS_ELEMENT_ID,
      pjp0.RBS_VERSION_ID,
      pjp0.PLAN_VERSION_ID,
      pjp0.PLAN_TYPE_ID,
      TO_NUMBER(NULL)                               CUSTOM1,
      TO_NUMBER(NULL)                               CUSTOM2,
      TO_NUMBER(NULL)                               CUSTOM3,
      TO_NUMBER(NULL)                               CUSTOM4,
      TO_NUMBER(NULL)                               CUSTOM5,
      TO_NUMBER(NULL)                               CUSTOM6,
      TO_NUMBER(NULL)                               CUSTOM7,
      TO_NUMBER(NULL)                               CUSTOM8,
      TO_NUMBER(NULL)                               CUSTOM9,
      TO_NUMBER(NULL)                               CUSTOM10,
      TO_NUMBER(NULL)                               CUSTOM11,
      TO_NUMBER(NULL)                               CUSTOM12,
      TO_NUMBER(NULL)                               CUSTOM13,
      TO_NUMBER(NULL)                               CUSTOM14,
      TO_NUMBER(NULL)                               CUSTOM15
    FROM
      PJI_FP_AGGR_PJP0 pjp0
    WHERE
      pjp0.WORKER_ID = p_worker_id AND
      1 = 2;

    /**************************************************************
     *                                                            *
     * Insert custom measures code before this box comment        *
     *                                                            *
     **************************************************************/

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION
    (l_process,
     'PJI_PJP_SUM_CUST.PJP_CUSTOM_FPR_API(p_worker_id);');

    commit;

  end PJP_CUSTOM_FPR_API;


  -- -----------------------------------------------------
  -- procedure PJP_CUSTOM_ACR_API
  --
  --   Attention Project Performance customer:
  --
  --   This API should be used to implement custom measures in the
  --   Activities Reporting Lines fact: PJI_AC_XBS_ACCUM_F.
  --
  --   1. Only modify code in the indicated area.
  --   2. Do not issue any statements that result in a "commit" or a "rollback"
  --   3. Only populate PJI_AC_CUST_PJP0.
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- -----------------------------------------------------
  procedure PJP_CUSTOM_ACR_API (p_worker_id in number) is

    l_process         varchar2(30);
    l_batch_id        number;
    l_extraction_type varchar2(15);
    l_pji_schema      varchar2(30);

  begin

    l_process := PJI_PJP_SUM_MAIN.g_process ||
                 to_char(p_worker_id);

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP
        (l_process,
         'PJI_PJP_SUM_CUST.PJP_CUSTOM_ACR_API(p_worker_id);')) then
      return;
    end if;

    l_batch_id := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                  (l_process, 'CURRENT_BATCH');

    l_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                         (l_process, 'EXTRACTION_TYPE');

    l_pji_schema := PJI_UTILS.GET_PJI_SCHEMA_NAME;

    /**************************************************************
     *                                                            *
     * Insert custom measures code after this box comment         *
     *                                                            *
     *                                                            *
     * IMPORTANT:  DO NOT INCLUDE ANY COMMIT STATEMENTS IN THE    *
     *             CUSTOM CODE.                                   *
     *                                                            *
     *                                                            *
     **************************************************************/


    /**************************************************************************************************************
     * Sample code with steps to customize custom measures for AC CUSTOM MEASURE TABLE(i.e.PJI_AC_CUST_PJP0) table*
     *                                                                                                            *
     *                                                                                                            *
     * AC BASIS TABLE ( I.E. PJI_AC_AGGR_PJP0)                                                                    *
     * --------------------------------------                                                                     *
     *  This table is the first aggregation point after the transaction accum tables and provides a basis for     *
     *  custom measures. This table has to be populated to store customized measures. It holds the mandatory      *
     *  keys, which are being used, in custom table (i.e. PJI_AC_CUST_PJP0) to store customized measures.         *
     *  To see the definition of this table and its columns, please refer ETRM.                                   *
     *                                                                                                            *
     * MANDOTORY PREREQUISTE TO DEFINE CUSTOM MEASURE                                                             *
     * ---------------------------------------------                                                              *
     *  1. Basis Table PJI_AC_AGGR_PJP0 should be populated                                                       *
     *   WHAT IF AC BASIS TABLE IS NOT POPULATED                                                                  *
     *   --------------------------------------                                                                   *
     *    If the basis table is not populated then the program will not use and store the customized measures     *
     *    at all.
     *                                                                                                            *
     * AC CUSTOM MEASURES TABLE ( I.E. PJI_AC_CUST_PJP0)                                                          *
     * -------------------------------------------------                                                          *
     *  This table is used to derive PJP custom measures only if derived measures are available in context        *
     *  of TASK. After customizing the custom measures, they are stored in this table.                            *
     *  Following is the list of custom measure available:                                                        *
     *  1. WORKER_ID                 Identify the set of data used by a particular process so that                *
     *                               when other process is running should not pickup the same record.             *
     *  2. PROJECT_ID                Identifier for the project                                                   *
     *  3. PROJECT_ORG_ID            Identifier of the Project Operating Unit                                     *
     *  4. PROJECT_ORGANIZATION_ID   Identifier of the Project Organization                                       *
     *  5. PROJECT_ELEMENT_ID        This is the WBS element id and consists of projects and tasks.               *
     *  6. TIME_ID                   Numeric identifier for time                                                  *
     *  7. PERIOD_TYPE_ID            Numeric identifier for the period type (period, quarter, year, weeks)        *
     *  8. CALENDAR_TYPE             Specifies the calendar type (PA, GL, Enterprise)                             *
     *  9. WBS_ROLLUP_FLAG          Indicates, for the given project structure version, whether the amounts       *
     *                               are rolled up by WBS or not.'N' = No (Task self amounts.)                    *
     *                               'Y' = Yes (Task amounts rolled up by WBS.                                    *
     *                               Rolled up amounts do not include self amounts.)                              *
     *  10. PRG_ROLLUP_FLAG          Indicates whether the amounts are rolled up by Project Hierarchy or not.     *
     *                               'N' = No (Amounts within a given project.)                                   *
     *                               'Y' = Yes (Project structure version amounts rolled up by Project            *
     *                               Hierarchy. Rolled up amounts do not include self amounts.)                   *
     *  11. CURR_RECORD_TYPE_ID      Identifier for the Currency record type                                      *
     *  12. CURRENCY_CODE            Currency Code                                                                *
     *  13. There are 15 custom measures available to store the customized data.                                  *
     *                                                                                                            *
     * USING AC BASIS TABLE FOR LOOKUP AND CUSTOMIZING MEASURE                                                    *
     * ----------------------------------------------------------                                                 *
     * As mentioned  above any table in Oracle Projects can be used to derive customized measures. In this section      *
     * basis table is being used                                                                                  *
     * E.g. If user wants to calculate certain amount of tax percentage base on Revenue for PA calendar ,USD      *
     * currency then CURRENCY_CODE, and CALENDAR_TYPE attribute can be used to filter.                            *
     * Please see example in example section to understand more clearly.                                          *
     *                                                                                                            *
     * EXAMPLE TO CUSTOMIZE CUSTOM MEASURES                                                                       *
     * ------------------------------------                                                                       *
     *  - Customizing a measure using  CALENDAR_TYPE,CURRENCY_CODE,REVENUE                                        *
     *  - Define computation logic for custom measure 1                                                           *
     *  - Remove 1=2 from the SELECT part                                                                         *
     * INSERT INTO PJI_AC_CUST_PJP0 cust_i                                                                        *
     * (                                                                                                          *
     *   WORKER_ID,                                                                                               *
     *   PROJECT_ID,                                                                                              *
     *   PROJECT_ORG_ID,                                                                                          *
     *   PROJECT_ORGANIZATION_ID,                                                                                 *
     *   PROJECT_ELEMENT_ID,                                                                                      *
     *   TIME_ID,                                                                                                 *
     *   PERIOD_TYPE_ID,                                                                                          *
     *   CALENDAR_TYPE,                                                                                           *
     *   WBS_ROLLUP_FLAG,                                                                                         *
     *   PRG_ROLLUP_FLAG,                                                                                         *
     *   CURR_RECORD_TYPE_ID,                                                                                     *
     *   CURRENCY_CODE,                                                                                           *
     *   CUSTOM1,                                                                                                 *
     *   CUSTOM2,                                                                                                 *
     *   CUSTOM3,                                                                                                 *
     *   CUSTOM4,                                                                                                 *
     *   CUSTOM5,                                                                                                 *
     *   CUSTOM6,                                                                                                 *
     *   CUSTOM7,                                                                                                 *
     *   CUSTOM8,                                                                                                 *
     *   CUSTOM9,                                                                                                 *
     *   CUSTOM10,                                                                                                *
     *   CUSTOM11,                                                                                                *
     *   CUSTOM12,                                                                                                *
     *   CUSTOM13,                                                                                                *
     *   CUSTOM14,                                                                                                *
     *   CUSTOM15                                                                                                 *
     *   )                                                                                                        *
     * SELECT                                                                                                     *
     *   p_worker_id,                                                                                             *
     *   pjp0.PROJECT_ID,                                                                                         *
     *   pjp0.PROJECT_ORG_ID,                                                                                     *
     *   pjp0.PROJECT_ORGANIZATION_ID,                                                                            *
     *   pjp0.PROJECT_ELEMENT_ID,                                                                                 *
     *   pjp0.TIME_ID,                                                                                            *
     *   pjp0.PERIOD_TYPE_ID,                                                                                     *
     *   pjp0.CALENDAR_TYPE,                                                                                      *
     *   pjp0.WBS_ROLLUP_FLAG,                                                                                    *
     *   pjp0.PRG_ROLLUP_FLAG,                                                                                    *
     *   pjp0.CURR_RECORD_TYPE_ID,                                                                                *
     *   pjp0.CURRENCY_CODE,                                                                                      *
     *   -- Custom measure 1                                                                                      *
     *   (0.15*pjp0.REVENUE) CUSTOM1,                                                                             *
     *   -- Custom measure 1                                                                                      *
     *   TO_NUMBER(NULL)                               CUSTOM2,                                                   *
     *   TO_NUMBER(NULL)                               CUSTOM3,                                                   *
     *   TO_NUMBER(NULL)                               CUSTOM4,                                                   *
     *   TO_NUMBER(NULL)                               CUSTOM5,                                                   *
     *   TO_NUMBER(NULL)                               CUSTOM6,                                                   *
     *   TO_NUMBER(NULL)                               CUSTOM7,                                                   *
     *   TO_NUMBER(NULL)                               CUSTOM8,                                                   *
     *   TO_NUMBER(NULL)                               CUSTOM9,                                                   *
     *   TO_NUMBER(NULL)                               CUSTOM10,                                                  *
     *   TO_NUMBER(NULL)                               CUSTOM11,                                                  *
     *   TO_NUMBER(NULL)                               CUSTOM12,                                                  *
     *   TO_NUMBER(NULL)                               CUSTOM13,                                                  *
     *   TO_NUMBER(NULL)                               CUSTOM14,                                                  *
     *   TO_NUMBER(NULL)                               CUSTOM15                                                   *
     * FROM                                                                                                       *
     *   PJI_AC_AGGR_PJP0 pjp0 -- AC basis table,                                                                 *
     * WHERE                                                                                                      *
     *   pjp0.WORKER_ID = p_worker_id AND                                                                         *
     *   pjp0.CURRENCY_CODE = 'USD' AND                                                                           *
     *   pjp0.CALENDAR_TYPE = 'PA;                                                                                *
     *                                                                                                            *
     * LIMITATION TO CUSTOMIZE CUSTOM MEASURES                                                                    *
     * --------------------------------------                                                                     *
     *  1. Currently, User can customize any measure available in Oracle Projects.                                *
     *  2. Only Number data type can be stored in Custom measures.                                                *
     *  3. The summarization always extracts incremental records from the transaction source.  If the custom      *
     *     measures are defined on an amount column from the basis table, then they are always computed on        *
     *     incremental values. However, if the custom measures are derived from other sources then the custom     *
     *     pl/sql logic has to ensure that it derives incremental amounts (ie., change since the last time        *
     *     summarization has been run).
     **************************************************************************************************************/

    INSERT INTO PJI_AC_CUST_PJP0 cust_i
    (
      WORKER_ID,
      PROJECT_ID,
      PROJECT_ORG_ID,
      PROJECT_ORGANIZATION_ID,
      PROJECT_ELEMENT_ID,
      TIME_ID,
      PERIOD_TYPE_ID,
      CALENDAR_TYPE,
      WBS_ROLLUP_FLAG,
      PRG_ROLLUP_FLAG,
      CURR_RECORD_TYPE_ID,
      CURRENCY_CODE,
      CUSTOM1,
      CUSTOM2,
      CUSTOM3,
      CUSTOM4,
      CUSTOM5,
      CUSTOM6,
      CUSTOM7,
      CUSTOM8,
      CUSTOM9,
      CUSTOM10,
      CUSTOM11,
      CUSTOM12,
      CUSTOM13,
      CUSTOM14,
      CUSTOM15
    )
    SELECT
      p_worker_id,
      pjp0.PROJECT_ID,
      pjp0.PROJECT_ORG_ID,
      pjp0.PROJECT_ORGANIZATION_ID,
      pjp0.PROJECT_ELEMENT_ID,
      pjp0.TIME_ID,
      pjp0.PERIOD_TYPE_ID,
      pjp0.CALENDAR_TYPE,
      pjp0.WBS_ROLLUP_FLAG,
      pjp0.PRG_ROLLUP_FLAG,
      pjp0.CURR_RECORD_TYPE_ID,
      pjp0.CURRENCY_CODE,
      TO_NUMBER(NULL)                               CUSTOM1,
      TO_NUMBER(NULL)                               CUSTOM2,
      TO_NUMBER(NULL)                               CUSTOM3,
      TO_NUMBER(NULL)                               CUSTOM4,
      TO_NUMBER(NULL)                               CUSTOM5,
      TO_NUMBER(NULL)                               CUSTOM6,
      TO_NUMBER(NULL)                               CUSTOM7,
      TO_NUMBER(NULL)                               CUSTOM8,
      TO_NUMBER(NULL)                               CUSTOM9,
      TO_NUMBER(NULL)                               CUSTOM10,
      TO_NUMBER(NULL)                               CUSTOM11,
      TO_NUMBER(NULL)                               CUSTOM12,
      TO_NUMBER(NULL)                               CUSTOM13,
      TO_NUMBER(NULL)                               CUSTOM14,
      TO_NUMBER(NULL)                               CUSTOM15
    FROM
      PJI_AC_AGGR_PJP0 pjp0
    WHERE
      pjp0.WORKER_ID = p_worker_id AND
      1 = 2;

    /**************************************************************
     *                                                            *
     * Insert custom measures code before this box comment        *
     *                                                            *
     **************************************************************/

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION
    (l_process,
     'PJI_PJP_SUM_CUST.PJP_CUSTOM_ACR_API(p_worker_id);');

    commit;

  end PJP_CUSTOM_ACR_API;

end PJI_PJP_SUM_CUST;

/
