--------------------------------------------------------
--  DDL for Package Body GMP_APS_OUTPUT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMP_APS_OUTPUT_PKG" as
/* $Header: GMPOUTIB.pls 120.6.12010000.2 2009/04/02 12:58:22 vpedarla ship $ */

/*=========================================================================
| PROCEDURE NAME                                                           |
|    insert_gmp_iterface                                                   |
|                                                                          |
| TYPE                                                                     |
|    public                                                                |
|                                                                          |
| DESCRIPTION                                                              |
|    The following procedure inserts into gmp_aps_output_tbl table,        |
|    Pull out the Information from wip_job_schedule_interface.             |
| Input Parameters                                                         |
|    p_group_id    - Group Id                                              |
|                                                                          |
| Output Parameters                                                        |
|    None                                                                  |
|                                                                          |
| HISTORY     Rajesh Patangya    on 10/08/99                               |
|             Rajesh Patangya    on 11/02/99  Item_id from fm_form_eff     |
| 11/23/99 -  Sridhar added errbuf,retcode to the insert_gmp_interface     |
|          -  Procedure                                                    |
| 02/24/00 -  Sridhar added Cancel flag to the insert_gmp_interface        |
|          -  Procedure                                                    |
|          -  Added insert statement for Cancelled Orders and modified     |
|          -  insert statement for Re-Scheduled Orders - Bug# 1210500      |
|  14-AUG-01 Sridhar Changed per the discussion in the bug : 1880303       |
|            Status_type APS feedback program updates this as following    |
|            NULL - For Reschduled_job                                     |
|            1    - For New job                                            |
|            7 For cancelled Job                                           |
|  21-JAN-02 - Sridhar Modified the Insert statement with new GMD Tables   |
|                                                                          |
|  05-JAN-05 - Sowmya, B4084230. New column Firm_flag also populated in the|
|              gmp_aps_output_dtl table from WIP_JOB_SCHEDULE_INTERFACE    |
|  08-21-06 - Rajesh B5454215 Added parameter of value '0' (Batch Type)    |
|             when calling GMPRELAP                                        |
|  12-07-07 - Kaushek B6167305 Added new profile option for implementing   |
|             suggestions as 'FPO' whereby default it is set to'BATCH'     |
 ==========================================================================*/

PROCEDURE insert_gmp_interface( errbuf       out NOCOPY varchar2,
                                retcode      out NOCOPY number,
                                p_group_id   IN NUMBER) IS

    delete_new_flag    NUMBER;  /* Delete flag for new batch */
    delete_rsch_flag   NUMBER;  /* Delete flag for rescheduled batch */
    delete_cancel_flag NUMBER;  /* Delete flag for Cancel batch */

    G_log_text         VARCHAR2(1000);
    X_conc_id          NUMBER;
    l_profile          NUMBER;  /* Hold Profile value for Implement APS Suggestions */
    l_cons             NUMBER;
    lv_result          BOOLEAN;
    ERROR_SUBMITTING_REQUEST    EXCEPTION;
    firm_batch_profile NUMBER; /* B5897392 Implement Suggestions as firm */
    batch_fpo_profile  NUMBER; /* B6167305 Profile-Implement Suggestions as BATCH or FPO */

BEGIN

/* 1. Select only OPM rows from WIP_INTERFACE TABLE
   2. Join those rows to GMP_APS_FORM_EFF to get OPM eff id
   3. We are using group id as process id in sync with WIP tables . (Abhay)
   4. Processed_ind from sequence. (matt)
   5. Change alternate_bom_designator to bom_reference_id. (matt)
*/

    delete_new_flag    := 0;
    delete_rsch_flag   := 0;
    delete_cancel_flag := 0;
    l_profile          := 0;
    firm_batch_profile        := NVL(FND_PROFILE.VALUE('GMP_IMPLEMENT_FIRM_BATCH'),1);
    batch_fpo_profile         := 0;  /* B6167305 By default Batch */

BEGIN  -- For New Orders

  /* B2104059 GMP-APS ENHANCEMENT FOR GMD FORMULA SECURITY FUNCTIONALITY  */
  /* Disable the security  */

  BEGIN
     gmd_p_fs_context.set_additional_attr ;
  END;

  SELECT gmp_process_upd_id_s.nextval INTO l_cons from dual;

        INSERT INTO gmp_aps_output_tbl (
            PROCESS_ID,
            INVENTORY_ITEM_ID,    -- for R12.0
            ORGANIZATION_CODE,
            ORGANIZATION_ID,
            BATCH_ID,
            WAREHOUSE_CODE,
            EFFECTIVITY_ID,
            PLAN_QUANTITY,
            PLAN_START_DATE,
            PLAN_END_DATE,
            ACTION_TYPE,
            PROCESSED_IND,
            HEADER_ID,
            SCHEDULING_METHOD,
            FIRM_FLAG , /*B4084230*/
            LAST_UPDATE_LOGIN,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            CREATION_DATE,
            CREATED_BY ,
            REQUIRED_COMPLETION_DATE ,     /* B3710615 12.0 */
            ORDER_PRIORITY                 /* B3710615 12.0 */
            )
        SELECT
            p_group_id ,
            grv.inventory_item_id,         -- For R12.0
            w.organization_code,              /* B2164593 */
            w.organization_id,
            to_number(NULL),
            gfe.whse_code,
            grv.recipe_validity_rule_id,   /* new GMD Column 1992371 */
            w.start_quantity,
            w.first_unit_start_date,
            w.last_unit_completion_date,
            w.load_type,
            l_cons,    /* PENDING - B2874323 */
            w.header_id,
            DECODE(gfe.routing_id,null,2,w.scheduling_method), /* B3119256 */
            -- B4664966 implement as firm only if ASCP and Profile says firm
            DECODE(w.firm_planned_flag,1,firm_batch_profile,w.firm_planned_flag),  /*B4084230*/
            w.last_update_login,
            w.last_updated_by,
            w.last_update_date,
            w.creation_date,
            w.created_by  ,
            w.due_date    ,                /* B3710615 12.0 */
            w.priority            /* B4039225 for 12.0 */
            FROM
                wip_job_schedule_interface w,
                gmp_form_eff gfe,
                gmd_recipe_validity_rules grv  /* B1992371 */
            WHERE
                  w.group_id = p_group_id
              AND w.load_type = 1
              AND w.process_status = 1 /* Unreleased  */
              AND nvl(w.status_type,0 ) = 1 /* New Batch */
              AND gfe.aps_fmeff_id = w.bom_reference_id
              AND gfe.fmeff_id = grv.recipe_validity_rule_id (+) /*1992371 */
              AND gfe.ORGANIZATION_ID = w.organization_id  -- For R12.0
          UNION ALL   /* B2874323 */
          SELECT
            p_group_id ,
            mtl.inventory_item_id,   -- for R12.0
            w.organization_code,
            w.organization_id,
            to_number(NULL),
            to_char(NULL),
            to_number(NULL),  -- BOM reference_id is NULL
            w.start_quantity,
            w.first_unit_start_date,
            w.last_unit_completion_date,
            w.load_type,
            l_cons,
            w.header_id,
            2,   /* Scheduling method is taken as NULL here */
            -- B4664966 implement as firm only if ASCP and Profile says firm
            DECODE(w.firm_planned_flag,1,firm_batch_profile,w.firm_planned_flag),  /*B4084230*/
            w.last_update_login,
            w.last_updated_by,
            sysdate,
            sysdate,
            w.created_by  ,
            w.due_date    ,        /* B3710615 12.0 */
            w.priority            /* B4039225 */
            FROM
                wip_job_schedule_interface w,
                mtl_system_items mtl
            WHERE
                  w.group_id = p_group_id
              AND w.load_type = 1
              AND w.process_status = 1
              AND nvl(w.status_type,0 ) = 1
              AND w.bom_reference_id IS NULL
              AND w.primary_item_id = mtl.inventory_item_id
              AND w.organization_id = mtl.organization_id ;

    delete_new_flag := 1 ;

EXCEPTION
    WHEN no_data_found THEN
    errbuf := 'No Data Found Sql Error:' ||to_char(sqlcode);
    retcode := 1;  /* Warning */
    delete_new_flag := 1 ;

    WHEN others THEN
    errbuf := 'Insert Failed Sql Error:' ||to_char(sqlcode);
    retcode := 1;  /* Warning */
    NULL ;
END;
   COMMIT;

/* For Rescheduled Orders
   Load_type incidcates whether to create new or update a job
  (also what type of job)
   Status_type APS feedback program updates this as following
   NULL - For Reschduled_job
   1    - For New job
   7 For cancelled Job
   Therefore the check for quantity is being removed
   (earlier 0 quantity indicated cancellation of the job
*/

BEGIN
        INSERT INTO gmp_aps_output_tbl (
           PROCESS_ID,
           INVENTORY_ITEM_ID,   -- For R12.0
           ORGANIZATION_CODE,
           ORGANIZATION_ID,
           BATCH_ID,
           WAREHOUSE_CODE,
           EFFECTIVITY_ID,
           PLAN_QUANTITY,
           PLAN_START_DATE,
           PLAN_END_DATE,
           ACTION_TYPE,
           PROCESSED_IND,
           HEADER_ID,
           SCHEDULING_METHOD,
           FIRM_FLAG,  /*B4084230*/
           LAST_UPDATE_LOGIN,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           CREATION_DATE,
           CREATED_BY ,
           REQUIRED_COMPLETION_DATE ,     /* B3710615 12.0 */
           ORDER_PRIORITY                 /* B3710615 12.0 */
           )
        SELECT
           p_group_id ,
           to_number(NULL),       -- For R12.0
           w.organization_code,
           w.organization_id,
           w.wip_entity_id,
           to_char(NULL) ,
           to_number(NULL) ,
           w.start_quantity,
           w.first_unit_start_date,
           w.last_unit_completion_date,
           w.load_type,
           gmp_process_upd_id_s.nextval,    /* PENDING */
           w.header_id,
           w.scheduling_method,
            -- B4664966 implement as firm only if ASCP and Profile says firm
            DECODE(w.firm_planned_flag,1,firm_batch_profile,w.firm_planned_flag),  /*B4084230*/
           w.last_update_login,
           w.last_updated_by,
           w.last_update_date,
           w.creation_date,
           w.created_by  ,
           w.due_date    ,                /* B3710615 12.0 */
           w.priority            /* B4039225 */
           FROM
              wip_job_schedule_interface w,
              gme_batch_header gbh  /* 1992371 */
           WHERE
                 w.group_id = p_group_id
             AND w.load_type = 3  /*  Update Discrete Job */
             AND nvl(w.status_type,0 ) <> 7  /* Rescheduled Batch */
             AND ((w.net_quantity is NULL) or (w.net_quantity <> 0 ))
             AND w.process_status = 1
             AND w.wip_entity_id = gbh.batch_id
             AND w.organization_id = gbh.organization_id ;  -- For 12.0

             delete_rsch_flag := 1 ;
EXCEPTION
    WHEN no_data_found THEN
    errbuf := ' No Data Found Sql Error:' ||to_char(sqlcode);
    retcode := 1;  /* Warning */
    delete_rsch_flag := -1 ;

    WHEN others THEN
    errbuf := 'Insert failed Sql Error:' ||to_char(sqlcode);
    retcode := 1;  /* Warning */
    NULL ;
END;
   COMMIT;

BEGIN    -- For Cancelled Orders
        INSERT INTO gmp_aps_output_tbl (
           PROCESS_ID,
           INVENTORY_ITEM_ID,   -- For R12.0
           ORGANIZATION_CODE,
           ORGANIZATION_ID,
           BATCH_ID,
           WAREHOUSE_CODE,
           EFFECTIVITY_ID,
           PLAN_QUANTITY,
           PLAN_START_DATE,
           PLAN_END_DATE,
           ACTION_TYPE,
           PROCESSED_IND,
           HEADER_ID,
           SCHEDULING_METHOD,
           FIRM_FLAG,  /*B4084230*/
           LAST_UPDATE_LOGIN,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           CREATION_DATE,
           CREATED_BY ,
           REQUIRED_COMPLETION_DATE ,     /* B3710615 12.0 */
           ORDER_PRIORITY                 /* B3710615 12.0 */
           )
        SELECT
           p_group_id ,
           to_number(NULL),    -- For R12.0
           w.organization_code,
           w.organization_id,
           w.wip_entity_id,
           to_char(NULL) ,
           to_number(NULL) ,
           w.start_quantity,
           w.first_unit_start_date,
           w.last_unit_completion_date,
           -1,  /* Inserting -1 into action_type to identify Cancellation */
           gmp_process_upd_id_s.nextval,    /* PENDING */
           w.header_id,
           w.scheduling_method,
            -- B4664966 implement as firm only if ASCP and Profile says firm
            DECODE(w.firm_planned_flag,1,firm_batch_profile,w.firm_planned_flag),  /*B4084230*/
           w.last_update_login,
           w.last_updated_by,
           w.last_update_date,
           w.creation_date,
           w.created_by  ,
           w.due_date    ,                /* B3710615 12.0 */
           w.priority            /* B4039225 */
           FROM
               wip_job_schedule_interface w,
               gme_batch_header gbh  /* 1992371 */
           WHERE
                 w.group_id = p_group_id
             AND w.load_type = 3  /*  Update Discrete job */
             AND nvl(w.status_type,0 ) = 7  /* Cancelled Batch */
             AND w.process_status = 1
             AND w.wip_entity_id = gbh.batch_id
             AND w.organization_id = gbh.organization_id ;  -- For 12.0

             delete_cancel_flag := 1 ;


EXCEPTION
    WHEN no_data_found THEN
    errbuf := ' No Data Found Sql Error:' ||to_char(sqlcode);
    retcode := 1;  /* Warning */
    delete_cancel_flag := 1 ;

    WHEN others THEN
    errbuf := 'Insert failed Sql Error:' ||to_char(sqlcode);
    retcode := 1;  /* Warning */
    NULL ;
END;
   COMMIT;

   -- Available details in wip
BEGIN
          INSERT INTO gmp_aps_output_dtl (
            GROUP_ID                   ,
            WIP_ENTITY_ID              ,
            ORGANIZATION_ID            ,
            OPERATION_SEQ_NUM          ,
            RESOURCE_SEQ_NUM           ,
            RESOURCE_ID_OLD            ,
            RESOURCE_ID_NEW            ,
            USAGE_RATE_OR_AMOUNT       ,
            SCHEDULED_FLAG             ,
            ASSIGNED_UNITS             ,
            UOM_CODE                   ,
            START_DATE                 ,
            COMPLETION_DATE            ,
            INVENTORY_ITEM_ID_OLD      ,
            INVENTORY_ITEM_ID_NEW      ,
            QUANTITY_PER_ASSEMBLY      ,
            WIP_SUPPLY_TYPE            ,
            DATE_REQUIRED              ,
            REQUIRED_QUANTITY          ,
            QUANTITY_ISSUED            ,
            LOAD_TYPE                  ,
            SUBSTITUTION_TYPE          ,
            LAST_UPDATE_DATE           ,
            LAST_UPDATED_BY            ,
            CREATION_DATE              ,
            CREATED_BY                 ,
            LAST_UPDATE_LOGIN          ,
            PARENT_HEADER_ID           ,
            FIRST_UNIT_START_DATE      ,
            LAST_UNIT_COMPLETION_DATE  ,
            MINIMUM_TRANSFER_QUANTITY  ,
            ATTRIBUTE_CATEGORY         ,
            ATTRIBUTE1                 ,
            ATTRIBUTE2                 ,
            ATTRIBUTE3                 ,
            ATTRIBUTE4                 ,
            ATTRIBUTE5                 ,
            ATTRIBUTE6                 ,
            ATTRIBUTE7                 ,
            ATTRIBUTE8                 ,
            ATTRIBUTE9                 ,
            ATTRIBUTE10                ,
            SCHEDULE_SEQ_NUM           ,
            SUBSTITUTE_GROUP_NUM       ,
            REPLACEMENT_GROUP_NUM      ,
            SETUP_ID                   ,  -- B3710615 12.0
            GROUP_SEQUENCE_ID          ,  -- B3710615 12.0
            GROUP_SEQUENCE_NUMBER      ,  -- B3710615 12.0
            CHARGE_NUMBER              ,  -- B3710615 12.0
            RESOURCE_INSTANCE_NUMBER   ,  -- B3710615 12.0
            FIRM_FLAG                  ,  -- B3710615 12.0
            PARENT_SEQ_NUM             ,  -- B3710615 12.0
            RESOURCE_INSTANCE_ID          -- B3710615 12.0
            )
            SELECT
            wdi.GROUP_ID                   ,
            wdi.WIP_ENTITY_ID              ,
            wdi.ORGANIZATION_ID            ,
            wdi.OPERATION_SEQ_NUM          ,
            wdi.RESOURCE_SEQ_NUM           ,
            wdi.RESOURCE_ID_OLD            ,
            wdi.RESOURCE_ID_NEW            ,
            wdi.USAGE_RATE_OR_AMOUNT       ,
            wdi.SCHEDULED_FLAG             ,
            wdi.ASSIGNED_UNITS             ,
            wdi.UOM_CODE                   ,
            wdi.START_DATE                 ,
            wdi.COMPLETION_DATE            ,
            wdi.INVENTORY_ITEM_ID_OLD      ,
            wdi.INVENTORY_ITEM_ID_NEW      ,
            wdi.QUANTITY_PER_ASSEMBLY      ,
            wdi.WIP_SUPPLY_TYPE            ,
            wdi.DATE_REQUIRED              ,
            wdi.REQUIRED_QUANTITY          ,
            wdi.QUANTITY_ISSUED            ,
            wdi.LOAD_TYPE                  ,
            wdi.SUBSTITUTION_TYPE          ,
            wdi.LAST_UPDATE_DATE           ,
            wdi.LAST_UPDATED_BY            ,
            wdi.CREATION_DATE              ,
            wdi.CREATED_BY                 ,
            wdi.LAST_UPDATE_LOGIN          ,
            wdi.PARENT_HEADER_ID           ,
            wdi.FIRST_UNIT_START_DATE      ,
            wdi.LAST_UNIT_COMPLETION_DATE  ,
            wdi.MINIMUM_TRANSFER_QUANTITY  ,
            wdi.ATTRIBUTE_CATEGORY         ,
            wdi.ATTRIBUTE1                 ,
            wdi.ATTRIBUTE2                 ,
            wdi.ATTRIBUTE3                 ,
            wdi.ATTRIBUTE4                 ,
            wdi.ATTRIBUTE5                 ,
            wdi.ATTRIBUTE6                 ,
            wdi.ATTRIBUTE7                 ,
            wdi.ATTRIBUTE8                 ,
            wdi.ATTRIBUTE9                 ,
            wdi.ATTRIBUTE10                ,
            wdi.SCHEDULE_SEQ_NUM           ,
            wdi.SUBSTITUTE_GROUP_NUM       ,
            wdi.REPLACEMENT_GROUP_NUM      ,
            -- B3710615 12.0
            wdi.SETUP_ID                   ,
            wdi.GROUP_SEQUENCE_ID          ,
            wdi.GROUP_SEQUENCE_NUMBER      ,
            wdi.CHARGE_NUMBER              ,
            gri.INSTANCE_NUMBER            ,
            wdi.FIRM_FLAG                  ,
            wdi.PARENT_SEQ_NUM             ,
            wdi.RESOURCE_INSTANCE_ID
            FROM WIP_JOB_DTLS_INTERFACE wdi ,
                 GMP_RESOURCE_INSTANCES gri
            WHERE
                  wdi.group_id = p_group_id
              AND wdi.resource_id_new = gri.resource_id (+)
              AND wdi.resource_instance_id = gri.instance_id (+)
              AND wdi.process_status = 1
              AND wdi.load_type in ('1','2','3','4','9','10') ;

EXCEPTION
    WHEN no_data_found THEN
    errbuf := ' No Data Found (detail): ' ||to_char(sqlcode);
    retcode := 1;  /* Warning */
    delete_cancel_flag := 1 ;
    delete_rsch_flag := 1   ;
    delete_new_flag := 1    ;

    WHEN others THEN
    errbuf := 'Detail Insert failed: ' ||to_char(sqlcode);
    retcode := 1;  /* Warning */
    NULL ;
END;

   /* Following Lines delete the rows wip_job_schedule_interface after the rows are
      inserted in gmp_aps_output_tbl */
BEGIN

    IF delete_new_flag = 1 THEN
        DELETE wip_job_schedule_interface
        WHERE group_id = p_group_id
          AND process_status = 1
          AND load_type = 1  ;
        DELETE wip_job_dtls_interface
        WHERE group_id = p_group_id
          AND process_status = 1  ;
    END IF;

    IF delete_rsch_flag = 1 THEN
        DELETE wip_job_schedule_interface
        WHERE group_id = p_group_id
          AND process_status = 1
          AND nvl(status_type,0 ) <> 7  /* Rescheduled Batch */
          AND load_type = 3  ;
        DELETE wip_job_dtls_interface
        WHERE group_id = p_group_id
          AND process_status = 1  ;
    END IF;

    IF delete_cancel_flag = 1 THEN
        DELETE wip_job_schedule_interface
        WHERE group_id = p_group_id
          AND process_status = 1
          AND nvl(status_type,0 ) = 7  /* Cancelled Batch */
          AND load_type = 3  ;

        DELETE wip_job_dtls_interface
        WHERE group_id = p_group_id
          AND process_status = 1  ;
    END IF;

EXCEPTION
    WHEN no_data_found THEN
    errbuf := ' No Data Found (detail): ' ||to_char(sqlcode);
    retcode := 1;  /* Warning */

    WHEN others THEN
    errbuf := 'WIP deletion failed: ' ||to_char(sqlcode);
    retcode := 1;  /* Warning */
    NULL ;
END;
    COMMIT;

 /*  B3191962 - Start Calling the Package for Implementing the Auto Planning
     Suggestions.  This Package gets called only when the user sets the
     GMP_AUTO_IMPLEMENT_APS_SUGG Profile to Yes
     The Parameters to the GMPARELP Package plant_code,fitem_no,titem_no,
     fdate, and tdate are all passed as NULL .. when automatic
 */
    BEGIN
      l_profile := FND_PROFILE.VALUE('GMP_AUTO_IMPLEMENT_APS_SUGG');
       IF l_profile = 1 THEN
        /* B6167305 Start */
          batch_fpo_profile := NVL(FND_PROFILE.VALUE('GMP_IMPLEMENT_SUGG_FPO_BATCH'),0);
          /* B6167305 End */
          lv_result := FND_REQUEST.SET_MODE(TRUE);
          FND_FILE.PUT_LINE ( FND_FILE.LOG,' Submitting the Req ');

-- RDP B5454215 - Added 0 when calling the reqauest.
-- Make Batch as defult value since there is no user input
--  Vpedarla bug: 7902184 Modified fnd submit request for GMPRELAP
          X_conc_id := FND_REQUEST.SUBMIT_REQUEST
                         ('GMP',      -- Application
                          'GMPRELAP', -- Conc Pgm Short Name
                          NULL,       -- Description
                          sysdate,    -- Start Time
                          FALSE,      -- Subrequest
                          NULL,       -- Plant Code
                          p_group_id, -- group_id   Bug: 7041514 Vpedarla
                          NULL,       -- FItem Number
                          NULL,       -- To Item Number
                          NULL,       -- From Date
                          NULL,       -- To Date
                          batch_fpo_profile  -- Order Type Batch/FPO /* B6167305 */
                         );

          FND_FILE.PUT_LINE(FND_FILE.LOG,' Submitted the Req X_conc_id -> '||X_conc_id);
--
          IF X_conc_id = 0 THEN
             RAISE ERROR_SUBMITTING_REQUEST;
          ELSE
      	     FND_MESSAGE.SET_NAME('GMP','MR_REQ_SUBMITTED');
      	     FND_MESSAGE.SET_TOKEN('CONC_ID', X_conc_id);
             FND_FILE.PUT_LINE ( FND_FILE.LOG,'-'||FND_MESSAGE.GET);
             COMMIT ;
          END IF;
       ELSE
         FND_FILE.PUT_LINE(FND_FILE.LOG,'Profile implement APS Suggestions is NOT turned ON, Use concurrent program or Use the GMP forms to implement APS suggestions ');
       END IF;

EXCEPTION
   WHEN ERROR_SUBMITTING_REQUEST THEN
     G_log_text := FND_MESSAGE.GET;
     FND_FILE.PUT_LINE ( FND_FILE.LOG,'Error submitting concurrent Request '||G_log_text);
     retcode:=2;  /* Error */
   WHEN others THEN
     errbuf := 'Call to Perform Auto release failed: ' ||sqlerrm;
     retcode := 1;  /* Warning */
END;

END insert_gmp_interface;

 /*=========================================================================
| PROCEDURE NAME                                                           |
|    retrieve_item_cost                                                    |
|                                                                          |
| TYPE                                                                     |
|    public                                                                |
|                                                                          |
| DESCRIPTION                                                              |
|                                                                          |
|   This function calls the costing function to get the item cost          |
|                                                                          |
| Input Parameters                                                         |
|                                                                          |
| Output Parameters                                                        |
|                                                                          |
| HISTORY                                                                  |
|  M Craig 12-Nov- 99                                                      |
|  01-Apr-2005 Rajesh Patangya Modifed the item cost call for Release 12.0 |
|  25-Oct-2005 Abhay B4638839 No need to pass cost method etc , also widen |
|    cost method size.                                                     |
 ==========================================================================*/
FUNCTION retrieve_item_cost(
  pitem_id   IN NUMBER,
  porgn_id   IN NUMBER)
  RETURN NUMBER
IS

  item_cost       NUMBER ;
  ret_var         NUMBER ;
  v_item_cost     NUMBER ;
  cmpntcls_id     NUMBER ;
  analysis_code   VARCHAR2(4) ;
  gl_cost_method   VARCHAR2(10) ;
  num_rows        NUMBER ;
  v_init_msg_list VARCHAR2(2000) ;
  v_return_status VARCHAR2(50) ;
  v_msg_count     NUMBER ;
  v_msg_data      VARCHAR2(2000);

  v_item_id mtl_system_items.inventory_item_id%TYPE;
  v_orgn_id mtl_system_items.organization_id%TYPE;

  /* cursor to get the company(operating units) and the cost method */
/* Per the inventory convergence inputs from costing team
Sukarna and Uday - there is no need to pass cost method */

-- HW B4905324 - Removed the commented code so it will not be flagged
-- again as a performance issue

BEGIN

  item_cost     := 0;
  ret_var       := 0;
  v_item_cost   := 0;
  cmpntcls_id   := NULL;
  analysis_code := NULL;
  gl_cost_method := NULL;
  num_rows      := 0;
  v_item_id     := pitem_id;
  v_orgn_id     := porgn_id;
  v_init_msg_list := FND_API.G_FALSE ;
  v_return_status := NULL ;
  v_msg_count     := 0 ;
  v_msg_data      := NULL ;

    /* call the costing function  */
    ret_var := gmf_cmcommon.Get_Process_Item_Cost(
               1.0               ,               /* p_api_version */
               v_init_msg_list ,
               v_return_status ,
               v_msg_count     ,
               v_msg_data      ,
		v_item_id ,
		v_orgn_id ,
               sysdate,                        /* Cost as on date */
               1,                              /* 1 = total cost */
		gl_cost_method ,
               cmpntcls_id,                    /* cost_component_class_id */
               analysis_code,                  /* cost_analysis_code   */
               item_cost,                      /* total cost */
               num_rows);                      /* no of detail rows return */
dbms_output.put_line ('Cost I got was '|| item_cost ||'***') ;
    IF item_cost > 0 THEN
       v_item_cost := item_cost;
    END IF;

  RETURN v_item_cost;

  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;

END retrieve_item_cost;

/* ==========================================================================
 * | PROCEDURE NAME                                                           |
 * |    retrieve_price_list                                                   |
 * |                                                                          |
 * | TYPE                                                                     |
 * |    public                                                                |
 * |                                                                          |
 * | DESCRIPTION                                                              |
 * |                                                                          |
 * |   This function locates the price list for the item at the specified org |
 * |                                                                          |
 * | Input Parameters                                                         |
 * |                                                                          |
 * | Output Parameters                                                        |
 * |                                                                          |
 * | HISTORY                                                                  |
 * |  M Craig 08-Feb-2000 B1200400                                            |
 * |                                                                          |
 *  ==========================================================================*/
FUNCTION retrieve_price_list(
  pitem_id   IN NUMBER,
  porgn_id   IN NUMBER)
  RETURN NUMBER
IS

BEGIN

  RETURN 0 ;

EXCEPTION
  WHEN OTHERS THEN
  RETURN 0;

END retrieve_price_list;

END gmp_aps_output_pkg;

/
