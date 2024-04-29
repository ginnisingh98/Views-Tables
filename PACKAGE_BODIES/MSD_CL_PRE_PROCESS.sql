--------------------------------------------------------
--  DDL for Package Body MSD_CL_PRE_PROCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSD_CL_PRE_PROCESS" AS -- Package Body
/* $Header: MSDCLPPB.pls 120.13.12010000.1 2008/05/01 18:19:41 appldev ship $ */


v_sql_stmt            PLS_INTEGER;--Holds the DML statement no used for error logging.
v_plan_per_profile    NUMBER:=nvl(fnd_profile.value('MSD_PLANNING_PERCENTAGE'), G_NO_PLAN_PERCENTAGE);
v_null_pk             NUMBER := msd_sr_util.get_null_pk; --Use this variable to assign SR_LEVEL_PK for the level value 'Others' in ALL DIMENSIONS.


  --========================PROCEDURES/FUNCTION=================

 /*==========================================================================+
  | DESCRIPTION  : This function accepts the concurrent program request id as|
  |                input parameter and returns the status of the request.    |
  |                SYS_NO  - Request Completed                               |
  |                SYS_YES - Request in Running/Pending status               |
  |                                                                          |
  |                Added to fix the bug#2402527                              |
  +==========================================================================*/

   FUNCTION is_request_status_valid( p_request_id      IN Number)
     RETURN NUMBER
   IS
      l_call_status      boolean;
      l_phase            varchar2(80);
      l_status           varchar2(80);
      l_dev_phase        varchar2(80);
      l_dev_status       varchar2(80);
      l_message          varchar2(2048);
      l_request_id        Number;
   BEGIN
     l_request_id :=  p_request_id;
     l_call_status:= FND_CONCURRENT.GET_REQUEST_STATUS
                              ( l_request_id,
                                NULL,
                                NULL,
                                l_phase,
                                l_status,
                                l_dev_phase,
                                l_dev_status,
                                l_message);

     IF l_call_status=FALSE THEN
       msc_St_util.log_message( l_message);
       RETURN SYS_NO;
     END IF;

     IF l_dev_phase NOT IN ( 'PENDING','RUNNING') THEN
       RETURN SYS_NO;
     END IF;

     RETURN SYS_YES;
   END is_request_status_valid;

 /*==========================================================================+
  | DESCRIPTION  : This function returns OEM's company name                  |
  +==========================================================================*/

   FUNCTION GET_MY_COMPANY return VARCHAR2 IS
       p_my_company    msc_companies.company_name%TYPE;
   BEGIN

      /* Get the name of the own Company */
      /* This name is seeded with company_is = 1 in msc_companies */
      BEGIN
         select company_name into p_my_company
         from msc_companies
         where company_id = 1;
      EXCEPTION
         WHEN OTHERS THEN
         return 'My Company';
      END;

      return p_my_company;

   END GET_MY_COMPANY;

 /*==========================================================================+
  | DESCRIPTION  : This function performs the validation and loads the data   |
  |                for business object organization and customer              |
  +==========================================================================*/

  PROCEDURE  LOAD_ORG_CUST  (ERRBUF          OUT NOCOPY VARCHAR,
                             RETCODE         OUT NOCOPY NUMBER,
                             p_instance_id  IN NUMBER,
                             p_batch_id     IN NUMBER)
  IS
  lv_sql_stmt VARCHAR2(4000);
  lv_error_text VARCHAR2(250);
  lv_debug BOOLEAN := msc_cl_pre_process.v_debug;

  BEGIN

    v_sql_stmt := 01;
    lv_sql_stmt :=
       ' INSERT INTO MSD_ST_LEVEL_VALUES '
       ||' (INSTANCE , '
       ||'  LEVEL_ID, '
       ||'  LEVEL_VALUE, '
       ||'  SR_LEVEL_PK, '
       ||'  LEVEL_VALUE_DESC, '
       ||'  ATTRIBUTE1, '
       ||'  ATTRIBUTE2, '
       ||'  ATTRIBUTE3, '
       ||'  ATTRIBUTE4, '
       ||'  ATTRIBUTE5, '
       ||'  LAST_UPDATE_DATE, '
       ||'  LAST_UPDATED_BY, '
       ||'  CREATION_DATE, '
       ||'  CREATED_BY, '
       ||'  LAST_UPDATE_LOGIN, '
       ||'  REQUEST_ID, '
       ||'  PROGRAM_APPLICATION_ID, '
       ||'  PROGRAM_ID, '
       ||'  PROGRAM_UPDATE_DATE ) '
       ||'  SELECT DISTINCT'
       ||'  sr_instance_id,'
       ||'  DECODE(partner_type,3,7,2,15),'
       ||'  partner_name, '
       ||'  sr_tp_id, '
       ||'  DECODE(partner_type,3,substr(organization_code,instr(organization_code,'':'')+1,length(organization_code))||'''||':'||'''||substr(partner_name,instr(partner_name,'':'')+1,length(partner_name)),2,'''',''''), '
       ||'  NULL,'
       ||'  NULL,'
       ||'  NULL,'
       ||'  NULL,'
       ||'  NULL,'
       ||'  last_update_date,'
       ||'  last_updated_by,'
       ||'  creation_date,'
       ||'  created_by, '
       ||'  last_update_login, '
       ||'  request_id , '
       ||'  program_application_id, '
       ||'  program_id , '
       ||'  program_update_date '
       ||'  FROM    msc_st_trading_partners'
       ||'  WHERE   sr_instance_id = :p_instance_id'
       ||'  AND     process_flag          = '||G_VALID
       ||'  AND     batch_id       = :p_batch_id'
       ||'  AND     partner_type IN (2,3)';

      IF lv_debug THEN
        msc_st_util.log_message(lv_sql_stmt);
      END IF;

      EXECUTE IMMEDIATE lv_sql_stmt
              USING     p_instance_id,
                        p_batch_id;

    v_sql_stmt := 02;

   lv_sql_stmt :=
         ' INSERT INTO MSD_ST_ORG_CALENDARS '
       ||' (INSTANCE , '
       ||'  SR_ORG_PK, '
       ||'  CALENDAR_TYPE, '
       ||'  CALENDAR_CODE, '
       ||'  CREATION_DATE, '
       ||'  CREATED_BY, '
       ||'  LAST_UPDATE_DATE, '
       ||'  LAST_UPDATED_BY, '
       ||'  LAST_UPDATE_LOGIN, '
       ||'  REQUEST_ID, '
       ||'  PROGRAM_APPLICATION_ID, '
       ||'  PROGRAM_ID, '
       ||'  PROGRAM_UPDATE_DATE ) '
       ||'  SELECT DISTINCT'
       ||'  sr_instance_id,'
       ||'  sr_tp_id,'
       ||   G_MFG_CAL||','
       ||'  calendar_code, '
       ||'  creation_date,'
       ||'  created_by, '
       ||'  last_update_date,'
       ||'  last_updated_by,'
       ||'  last_update_login, '
       ||'  request_id , '
       ||'  program_application_id, '
       ||'  program_id , '
       ||'  program_update_date '
       ||'  FROM    msc_st_trading_partners mstp'
       ||'  WHERE  EXISTS (  SELECT  1'
       ||'                   FROM msd_st_time mst '
       ||'                   WHERE mstp.calendar_code=mst.calendar_code '
       ||'                   AND mst.calendar_type='||G_MFG_CAL
       ||'                   AND mstp.sr_instance_code=mst.sr_instance_code'
       ||'                   UNION '
       ||'                   SELECT 1'
       ||'                   FROM msd_time mt'
       ||'                   WHERE mstp.calendar_code=mt.calendar_code'
       ||'                   AND mt.calendar_type='||G_MFG_CAL
       ||'                   AND mstp.sr_instance_id=mt.instance)'
       ||'  AND     mstp.sr_instance_id = :p_instance_id'
       ||'  AND     mstp.process_flag          = '||G_VALID
       ||'  AND     mstp.batch_id       = :p_batch_id'
       ||'  AND     mstp.partner_type=3 ';


      IF lv_debug THEN
        msc_st_util.log_message(lv_sql_stmt);
      END IF;

      EXECUTE IMMEDIATE lv_sql_stmt
              USING     p_instance_id,
                        p_batch_id;


  --RETURN(lv_status);

   EXCEPTION
    WHEN OTHERS THEN
    ROLLBACK;

    lv_error_text    := substr('MSD_CL_PRE_PROCESS.LOAD_ORG_CUST '||'('
                       ||v_sql_stmt||')'|| SQLERRM, 1, 240);
      msc_st_util.log_message(lv_error_text);
      ERRBUF := lv_error_text;
      RETCODE := G_WARNING;

  END LOAD_ORG_CUST;

  /*==========================================================================+
  | DESCRIPTION  : This function performs the validation and loads the data   |
  |                for business object items.                                 |
  +==========================================================================*/
  PROCEDURE LOAD_ITEMS (ERRBUF          OUT NOCOPY VARCHAR,
                       RETCODE         OUT NOCOPY NUMBER,
                       p_instance_id  IN NUMBER,
                       p_batch_id     IN NUMBER)
  IS
  lv_sql_stmt VARCHAR2(6000);
  lv_error_text VARCHAR2(250);
  lv_debug BOOLEAN := msc_cl_pre_process.v_debug;

  cursor c1 (p_instance varchar2) is
  select count(*) from MSD_LEVEL_VALUES
  where LEVEL_ID = 2
  and   instance = p_instance
  and   SR_LEVEL_PK = to_char(v_null_pk); --Using global variable v_null_pk insteda of hardcoding -777 at multiple places.

  cursor c2 (p_instance_code varchar2) is
  select local_id from msd_local_id_setup
  where char1    = p_instance_code
  -- and   char2    = 'All Products'
  and   level_id = 28;

  cursor c3 (p_instance_id number) is
  select instance_code
  from msc_apps_instances
  where instance_id=p_instance_id;

  lv_other_exist     PLS_INTEGER   := 0;
  lv_instance_code   VARCHAR2(5)   :='';
  lv_all_prd_pk      NUMBER        := 0;  --Renamed 'lv_sr_level_pk' to 'lv_all_prd_pk'.Also initialized this to 0 instead of -1.

  lv_other_desc   varchar2(240) := NULL;  --Adding this to insert level value - 'Others'
  lv_all_prd_desc varchar2(240) := NULL;  --Adding this to insert level value - 'All Products'

  BEGIN

    v_sql_stmt := 01;
    lv_sql_stmt :=
       ' INSERT INTO MSD_ST_LEVEL_VALUES '
       ||' (INSTANCE , '
       ||'  LEVEL_ID, '
       ||'  LEVEL_VALUE, '
       ||'  SR_LEVEL_PK, '
       ||'  LEVEL_VALUE_DESC, '
       ||'  ATTRIBUTE1, '
       ||'  ATTRIBUTE2, '
       ||'  ATTRIBUTE3, '
       ||'  ATTRIBUTE4, '
       ||'  ATTRIBUTE5, '
       ||'  LAST_UPDATE_DATE, '
       ||'  LAST_UPDATED_BY, '
       ||'  CREATION_DATE, '
       ||'  CREATED_BY, '
       ||'  LAST_UPDATE_LOGIN, '
       ||'  REQUEST_ID, '
       ||'  PROGRAM_APPLICATION_ID, '
       ||'  PROGRAM_ID, '
       ||'  PROGRAM_UPDATE_DATE ) '
       ||'  SELECT '
       ||'  sr_instance_id,'
       ||'  DECODE(bom_item_type,5,3,1,1,1),'
       ||'  item_name, '
       ||'  sr_inventory_item_id, '
       ||'  mssi.DESCRIPTION, '
       ||'  NULL,'
       ||'  NULL,'
       ||'  NULL,'
       ||'  NULL,'
       ||'  NULL,'
       ||'  mssi.last_update_date,'
       ||'  mssi.last_updated_by,'
       ||'  mssi.creation_date,'
       ||'  mssi.created_by ,'
       ||'  mssi.last_update_login, '
       ||'  mssi.request_id , '
       ||'  mssi.program_application_id, '
       ||'  mssi.program_id , '
       ||'  mssi.program_update_date '
       ||'  FROM    msc_st_system_items mssi'
       ||'  WHERE mssi.rowid                          = ( select max(mssi1.rowid) '
       ||'              		 from msc_st_system_items mssi1,msc_local_id_item lid '
       ||'                   WHERE    mssi1.sr_instance_code          = lid.char1'
       ||'                   AND NVL(mssi1.company_name, '||''''||-1||''''||') = '
       ||'                    NVL(lid.char2,'||''''||-1||''''||') '
       ||'                    AND     mssi1.organization_code          = lid.char3'
       ||'                    AND     mssi1.item_name                  = lid.char4'
       ||'   									AND     mssi1.process_flag               = '||G_VALID
       ||'                  AND     ((mssi1.mrp_planning_code          <> 6) OR (mssi1.pick_components_flag =''Y'')) '
       ||'                  AND    (('||v_plan_per_profile||'= 4) OR (mssi1.ato_forecast_control <> 3))'
       ||'                  AND     mssi1.sr_instance_id 	    = :p_instance_id'
       ||'                   AND     lid.entity_name    		    = ''SR_INVENTORY_ITEM_ID'''
       ||'                   AND     mssi.item_name                  = mssi1.item_name '
       ||'                   group by mssi1.item_name )'
       ||' AND mssi.process_flag                      = '||G_VALID
       ||' AND mssi.batch_id                          = :p_batch_id'
       ||' AND mssi.sr_instance_id                    = :p_instance_id';

      IF lv_debug THEN
        msc_st_util.log_message(lv_sql_stmt);
      END IF;

      EXECUTE IMMEDIATE lv_sql_stmt
              USING     p_instance_id,
                        p_batch_id,
                        p_instance_id;


    v_sql_stmt := 02;
    lv_sql_stmt :=
       ' INSERT INTO MSD_ST_LEVEL_ORG_ASSCNS '
       ||' (INSTANCE , '
       ||'  LEVEL_ID, '
       ||'  LEVEL_VALUE, '
       ||'  SR_LEVEL_PK, '
       ||'  ORG_LEVEL_ID, '
       ||'  ORG_LEVEL_VALUE, '
       ||'  ORG_SR_LEVEL_PK, '
       ||'  LAST_UPDATE_DATE, '
       ||'  LAST_UPDATED_BY, '
       ||'  CREATION_DATE, '
       ||'  CREATED_BY, '
       ||'  LAST_UPDATE_LOGIN, '
       ||'  REQUEST_ID, '
       ||'  PROGRAM_APPLICATION_ID, '
       ||'  PROGRAM_ID, '
       ||'  PROGRAM_UPDATE_DATE ) '
       ||'  SELECT '
       ||'  mssi.sr_instance_id,'
       ||'  1,'
       ||'  mssi.item_name, '
       ||'  mssi.sr_inventory_item_id, '
       ||'  7,'
       ||'  NULL,'
       ||'  mssi.organization_id,'
       ||'  mssi.last_update_date,'
       ||'  mssi.last_updated_by,'
       ||'  mssi.creation_date,'
       ||'  mssi.created_by ,'
       ||'  mssi.last_update_login, '
       ||'  mssi.request_id , '
       ||'  mssi.program_application_id, '
       ||'  mssi.program_id , '
       ||'  mssi.program_update_date '
       ||'  FROM    msc_st_system_items mssi'
       ||'  WHERE  mssi.bom_item_type                     <> 5 ' -- excluding the Product Families
       ||'  AND    mssi.process_flag                      = '||G_VALID
       ||'  AND    mssi.batch_id                          = :p_batch_id'
       ||'  AND    mssi.sr_instance_id                    = :p_instance_id';


      IF lv_debug THEN
         msc_st_util.log_message(lv_sql_stmt);
      END IF;


      EXECUTE IMMEDIATE lv_sql_stmt
              USING     p_batch_id,
                        p_instance_id;


    v_sql_stmt := 03;
    lv_sql_stmt :=
       'INSERT INTO MSD_ST_ITEM_LIST_PRICE '
       ||' (INSTANCE ,'
       ||'  ITEM ,'
       ||'  LIST_PRICE ,'
       ||'  AVG_DISCOUNT ,'
       ||'  BASE_UOM ,'
       ||'  SR_ITEM_PK ,'
       ||'  ITEM_TYPE_ID ,'
       ||'  FORECAST_TYPE_ID ,'
       ||'  SR_INSTANCE_CODE, '
       ||'  LAST_UPDATE_DATE, '
       ||'  LAST_UPDATED_BY, '
       ||'  CREATION_DATE, '
       ||'  CREATED_BY, '
       ||'  LAST_UPDATE_LOGIN, '
       ||'  REQUEST_ID, '
       ||'  PROGRAM_APPLICATION_ID, '
       ||'  PROGRAM_ID, '
       ||'  PROGRAM_UPDATE_DATE ) '
       ||'  Select '
       ||'  SR_INSTANCE_ID ,'
       ||'  ITEM_NAME ,'
       ||'  LIST_PRICE ,'
       ||'  AVERAGE_DISCOUNT ,'
       ||'  UOM_CODE ,'
       ||'  SR_INVENTORY_ITEM_ID ,'
       ||'  BOM_ITEM_TYPE ,'
       ||'  ATO_FORECAST_CONTROL ,'
       ||'  SR_INSTANCE_CODE,'
       ||'  mssi.last_update_date,'
       ||'  mssi.last_updated_by,'
       ||'  mssi.creation_date,'
       ||'  mssi.created_by ,'
       ||'  mssi.last_update_login, '
       ||'  mssi.request_id , '
       ||'  mssi.program_application_id, '
       ||'  mssi.program_id , '
       ||'  mssi.program_update_date '
       ||'  FROM    msc_st_system_items mssi'
       ||'  WHERE mssi.rowid                          = ( select max(mssi1.rowid) '
       ||'                           FROM msc_st_system_items mssi1,msc_local_id_item lid '
       ||'                           WHERE    mssi1.sr_instance_code          = lid.char1'
       ||'                           AND NVL(mssi1.company_name, '||''''||-1||''''||') = '
       ||'                           NVL(lid.char2,'||''''||-1||''''||') '
       ||'                           AND     mssi1.organization_code          = lid.char3'
       ||'                           AND     mssi1.item_name                  = lid.char4'
       ||'                           AND     mssi1.process_flag               = '||G_VALID
       ||'                            AND     ((mssi1.mrp_planning_code          <> 6) OR (mssi1.pick_components_flag =''Y'')) '
       ||'                            AND    (('||v_plan_per_profile||'= 4) OR (mssi1.ato_forecast_control <> 3))'
       ||'                            AND     mssi1.sr_instance_id 	    = :p_instance_id'
       ||'                            AND     lid.entity_name    		    = ''SR_INVENTORY_ITEM_ID'''
       ||'                            AND     mssi.item_name                  = mssi1.item_name '
       ||'                            group by mssi1.item_name )'
       ||' AND mssi.process_flag                      = '||G_VALID
       ||' AND mssi.batch_id                          = :p_batch_id'
       ||' AND mssi.sr_instance_id                    = :p_instance_id';

      IF lv_debug THEN
        msc_st_util.log_message(lv_sql_stmt);
      END IF;

      EXECUTE IMMEDIATE lv_sql_stmt
              USING     p_instance_id,
                        p_batch_id,
                        p_instance_id;


    OPEN c1(p_instance_id);
       FETCH c1 into lv_other_exist;
    CLOSE c1;

    IF  lv_other_exist = 0 THEN

        lv_other_desc    := msd_sr_util.get_null_desc;       --Calling fuction - msd_sr_util.get_null_desc, to fetch the level value 'Others'
        lv_all_prd_desc  := msd_sr_util.get_all_prd_desc;    --Calling fuction - msd_sr_util.get_all_prd_desc, to fetch the level value 'All Products'

        INSERT INTO MSD_ST_LEVEL_VALUES
        (INSTANCE   ,
        LEVEL_ID,
        LEVEL_VALUE,
        SR_LEVEL_PK,
        ATTRIBUTE1,
        ATTRIBUTE2,
        ATTRIBUTE3,
        ATTRIBUTE4,
        ATTRIBUTE5,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN,
        REQUEST_ID,
        PROGRAM_APPLICATION_ID,
        PROGRAM_ID,
        PROGRAM_UPDATE_DATE )
        VALUES
        (p_instance_id,
        2,
        lv_other_desc, --Using the value fetched from function - msd_sr_util.get_null_desc
        to_char(v_null_pk),   --Using global variable v_null_pk insteda of hardcoding -777 at multiple places.
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        sysdate,
        -1,
        sysdate,
        -1,
        -1,
        -1,
        -1,
        -1,
        sysdate);

   END IF;

  OPEN c3(p_instance_id);
    FETCH c3 into lv_instance_code;
  CLOSE c3;

  OPEN c2(lv_instance_code);
     FETCH c2 into lv_all_prd_pk;  --Renamed 'lv_sr_level_pk' to 'lv_all_prd_pk'.
  CLOSE c2;

     IF lv_all_prd_pk = 0  THEN  --Renamed 'lv_sr_level_pk' to 'lv_all_prd_pk'.

         lv_all_prd_pk := msd_sr_util.get_all_prd_pk;  -- Inserting 'All Products' records with sr_level_pk using function msd_sr_util.get_all_prd_pk(lv_all_prd_pk= -1)

  --  insert into msd_local_id_setup

      INSERT INTO  msd_local_id_setup
          (local_id,
           instance_id,
           level_id,
           char1,
           char2,
           last_update_date,
           last_updated_by,
           creation_date,
           created_by  )
           VALUES
           (lv_all_prd_pk,  --Using the value lv_all_prd_pk fetched above.
            p_instance_id,
            28,
            lv_instance_code,
            lv_all_prd_desc,   --Using the value fetched from function - msd_sr_util.get_all_prd_desc
            sysdate,
            -1,
            sysdate,
            -1);


      --Inserting into MSD_ST_LEVEL_VALUES

     INSERT INTO MSD_ST_LEVEL_VALUES
       (INSTANCE   ,
        LEVEL_ID,
        LEVEL_VALUE,
        SR_LEVEL_PK,
        ATTRIBUTE1,
        ATTRIBUTE2,
        ATTRIBUTE3,
        ATTRIBUTE4,
        ATTRIBUTE5,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN,
        REQUEST_ID,
        PROGRAM_APPLICATION_ID,
        PROGRAM_ID,
        PROGRAM_UPDATE_DATE )
        VALUES
        (p_instance_id,
        28,
        lv_all_prd_desc, --Using the value fetched from function - msd_sr_util.get_all_prd_desc
        lv_all_prd_pk,   --Inserting lv_all_prd_pk(-1) as sr_level_pk instead of '-7771'.
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        sysdate,
        -1,
        sysdate,
        -1,
        -1,
        -1,
        -1,
        -1,
        sysdate);


     --   Insert into msd_st_level_associations.

      INSERT INTO MSD_ST_LEVEL_ASSOCIATIONS
        (INSTANCE   ,
        LEVEL_ID,
        SR_LEVEL_PK,
        PARENT_LEVEL_ID,
        SR_PARENT_LEVEL_PK,
        ATTRIBUTE1,
        ATTRIBUTE2,
        ATTRIBUTE3,
        ATTRIBUTE4,
        ATTRIBUTE5,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN,
        REQUEST_ID,
        PROGRAM_APPLICATION_ID,
        PROGRAM_ID,
        PROGRAM_UPDATE_DATE )
        VALUES
        (p_instance_id,
        2,
        to_char(v_null_pk),  --Using global variable v_null_pk insteda of hardcoding -777 at multiple places.
        28,
        lv_all_prd_pk,  --Renamed 'lv_sr_level_pk' to 'lv_all_prd_pk'.
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        sysdate,
        -1,
        sysdate,
        -1,
        -1,
        -1,
        -1,
        -1,
        sysdate);


     END IF;



/*   v_sql_stmt := 04; -- bug 5586170

      lv_sql_stmt :=
       ' INSERT INTO MSD_ST_LEVEL_ASSOCIATIONS'
       ||' (INSTANCE , '
       ||'  LEVEL_ID, '
       ||'  SR_LEVEL_PK, '
       ||'  PARENT_LEVEL_ID,'
       ||'  SR_PARENT_LEVEL_PK,'
       ||'  ATTRIBUTE1, '
       ||'  ATTRIBUTE2, '
       ||'  ATTRIBUTE3, '
       ||'  ATTRIBUTE4, '
       ||'  ATTRIBUTE5, '
       ||'  LAST_UPDATE_DATE, '
       ||'  LAST_UPDATED_BY, '
       ||'  CREATION_DATE, '
       ||'  CREATED_BY, '
       ||'  LAST_UPDATE_LOGIN, '
       ||'  REQUEST_ID, '
       ||'  PROGRAM_APPLICATION_ID, '
       ||'  PROGRAM_ID, '
       ||'  PROGRAM_UPDATE_DATE ) '
       ||'  SELECT DISTINCT'
       ||'  mssi.sr_instance_id,'
       ||'  1 ,'
       ||'  mssi.sr_inventory_item_id, '
       ||'  2 ,'
       ||   to_char(v_null_pk)||','  --Using global variable v_null_pk insteda of hardcoding -777 at multiple places.
       ||'  NULL,'
       ||'  NULL,'
       ||'  NULL,'
       ||'  NULL,'
       ||'  NULL,'
       ||'  mssi.last_update_date,'
       ||'  mssi.last_updated_by,'
       ||'  mssi.creation_date,'
       ||'  mssi.created_by, '
       ||'  mssi.last_update_login, '
       ||'  mssi.request_id , '
       ||'  mssi.program_application_id, '
       ||'  mssi.program_id , '
       ||'  mssi.program_update_date '
       ||'  FROM    msc_st_system_items mssi'
       ||'  WHERE mssi.rowid                          = ( select max(mssi1.rowid) '
       ||'                   from msc_st_system_items mssi1,msc_local_id_item lid '
       ||'                    WHERE    mssi1.sr_instance_code          = lid.char1'
       ||'                   AND NVL(mssi1.company_name, '||''''||-1||''''||') = '
       ||'                    NVL(lid.char2,'||''''||-1||''''||') '
       ||'                    AND     mssi1.organization_code          = lid.char3'
       ||'                    AND     mssi1.item_name                  = lid.char4'
       ||'                    AND     mssi1.process_flag               = '||G_VALID
       ||'                    AND    ((mssi1.mrp_planning_code          <> 6) OR (mssi1.pick_components_flag =''Y'')) '
       ||'                    AND    (('||v_plan_per_profile||'= 4) OR (mssi1.ato_forecast_control <> 3))'
       ||'                    AND     mssi1.sr_instance_id 	    = :p_instance_id'
       ||'                    AND     lid.entity_name    		    = ''SR_INVENTORY_ITEM_ID'''
       ||'                     AND     mssi.item_name                  = mssi1.item_name '
       ||'                    group by mssi1.item_name )'
       ||' AND mssi.process_flag                      = '||G_VALID
       ||' AND mssi.batch_id                          = :p_batch_id'
       ||' AND mssi.sr_instance_id                    = :p_instance_id'
       ||' AND NOT EXISTS ( select 1'
       ||'                  from msc_st_system_items mssi2, msd_setup_parameters par'
       ||'                  where mssi.item_name =mssi2.item_name'
       ||'                  and mssi2.organization_code = par.PARAMETER_VALUE'
       ||'                  and ((mssi2.mrp_planning_code          <> 6) OR (mssi2.pick_components_flag =''Y''))'
       ||'                  and (('||v_plan_per_profile||'= 4) OR (mssi2.ato_forecast_control <> 3))'
       ||'                  and     mssi2.process_flag    = '||G_VALID
       ||'                  and     mssi2.sr_instance_id  = :p_instance_id'
       ||'                  and     par.parameter_name  = ''MSD_MASTER_ORG_LEGACY'''
       ||'                  and     par.instance_id     =  mssi2.sr_instance_id'
       ||'                  UNION'
       ||'                  select 1'
       ||'                  from msc_system_items msi, msd_setup_parameters par'
       ||'                  where mssi.item_name = msi.item_name'
       ||'                  and msi.organization_code = par.PARAMETER_VALUE'
       ||'                  and ((msi.mrp_planning_code          <> 6) OR (msi.pick_components_flag =''Y''))'
       ||'                  and (('||v_plan_per_profile||'= 4) OR (msi.ato_forecast_control <> 3))'
       ||'                  and msi.sr_instance_id     = :p_instance_id'
       ||'                  and msi.plan_id            = -1'
       ||'                  and par.parameter_name     = ''MSD_MASTER_ORG_LEGACY'''
       ||'                  and par.instance_id        =  msi.sr_instance_id ) ';


      IF lv_debug THEN
        msc_st_util.log_message(lv_sql_stmt);
       END IF;

      EXECUTE IMMEDIATE lv_sql_stmt
              USING     p_instance_id,
                        p_batch_id,
                        p_instance_id,
                        p_instance_id,
                        p_instance_id;
   */

  EXCEPTION
   WHEN OTHERS THEN
    ROLLBACK;

   lv_error_text    := substr('MSD_CL_PRE_PROCESS.LOAD_ITEMS '||'('
                       ||v_sql_stmt||')'|| SQLERRM, 1, 240);
      msc_st_util.log_message(SQLERRM);
      msc_st_util.log_message(lv_error_text);
      ERRBUF := lv_error_text;
      RETCODE := G_WARNING;

  END LOAD_ITEMS;

 /*==========================================================================+
  | DESCRIPTION  : This function performs the validation and loads the data   |
  |                for business object category                               |
  +==========================================================================*/
  PROCEDURE LOAD_CATEGORY (ERRBUF          OUT NOCOPY VARCHAR,
                          RETCODE         OUT NOCOPY NUMBER,
                          p_instance_id  IN NUMBER,
                          p_batch_id     IN NUMBER,
                          p_link         IN NUMBER)
  IS
  lv_sql_stmt VARCHAR2(4000);
  lv_error_text VARCHAR2(250);
  lv_debug BOOLEAN := msc_cl_pre_process.v_debug;

  BEGIN



      v_sql_stmt := 01;

      lv_sql_stmt :=
       ' INSERT INTO MSD_ST_LEVEL_VALUES '
       ||' (INSTANCE , '
       ||'  LEVEL_ID, '
       ||'  LEVEL_VALUE, '
       ||'  SR_LEVEL_PK, '
       ||'  LEVEL_VALUE_DESC, '
       ||'  ATTRIBUTE1, '
       ||'  ATTRIBUTE2, '
       ||'  ATTRIBUTE3, '
       ||'  ATTRIBUTE4, '
       ||'  ATTRIBUTE5, '
       ||'  LAST_UPDATE_DATE, '
       ||'  LAST_UPDATED_BY, '
       ||'  CREATION_DATE, '
       ||'  CREATED_BY, '
       ||'  LAST_UPDATE_LOGIN, '
       ||'  REQUEST_ID, '
       ||'  PROGRAM_APPLICATION_ID, '
       ||'  PROGRAM_ID, '
       ||'  PROGRAM_UPDATE_DATE ) '
       ||'  SELECT DISTINCT'
       ||'  mic.sr_instance_id,'
       ||'  2 ,'
       ||'  mic.category_name, '
       ||'  mic.sr_category_id, '
       ||'  mic.DESCRIPTION, '
       ||'  NULL,'
       ||'  NULL,'
       ||'  NULL,'
       ||'  NULL,'
       ||'  NULL,'
       ||'  mic.last_update_date,'
       ||'  mic.last_updated_by,'
       ||'  mic.creation_date,'
       ||'  mic.created_by, '
       ||'  mic.last_update_login, '
       ||'  mic.request_id , '
       ||'  mic.program_application_id, '
       ||'  mic.program_id , '
       ||'  mic.program_update_date '
       ||'  FROM    msc_st_item_categories mic,msc_st_system_items mssi'
       ||'  WHERE   mic.sr_instance_id = :p_instance_id'
       ||'  AND     mic.process_flag          = '||G_VALID
       ||'  AND     mic.batch_id       = :p_batch_id'
       ||'  AND     mic.organization_code = ( SELECT '
       ||'      parameter_value from  msd_setup_parameters'
       ||'      WHERE parameter_name = ''MSD_MASTER_ORG_LEGACY'''
       ||'      AND   instance_id  = mic.sr_instance_id)'
       ||'  AND     mic.category_set_name = ( SELECT '
       ||'      parameter_value from  msd_setup_parameters'
       ||'      WHERE parameter_name = ''MSD_CATEGORY_SET_NAME_LEGACY'' '
       ||'      AND   instance_id  = mic.sr_instance_id)'
       ||'  AND  (('||v_plan_per_profile||'= 4) OR (mssi.ato_forecast_control <> 3))'
       ||'  AND mssi.mrp_planning_code <> 6'
       ||'  AND mic.sr_instance_id =mssi.sr_instance_id'
       ||'  AND mic.organization_id= mssi.organization_id'
       ||'  AND mic.item_name = mssi.item_name'
       ||'  UNION '
       ||'  SELECT DISTINCT'
       ||'  mic.sr_instance_id,'
       ||'  2 ,'
       ||'  mic.category_name, '
       ||'  mic.sr_category_id, '
       ||'  mic.DESCRIPTION, '
       ||'  NULL,'
       ||'  NULL,'
       ||'  NULL,'
       ||'  NULL,'
       ||'  NULL,'
       ||'  mic.last_update_date,'
       ||'  mic.last_updated_by,'
       ||'  mic.creation_date,'
       ||'  mic.created_by, '
       ||'  mic.last_update_login, '
       ||'  mic.request_id , '
       ||'  mic.program_application_id, '
       ||'  mic.program_id , '
       ||'  mic.program_update_date '
       ||'  FROM    msc_st_item_categories mic,msc_system_items msi'
       ||'  WHERE   mic.sr_instance_id = :p_instance_id'
       ||'  AND     mic.process_flag          = '||G_VALID
       ||'  AND     mic.batch_id       = :p_batch_id'
       ||'  AND     mic.organization_code = ( SELECT '
       ||'      parameter_value from  msd_setup_parameters'
       ||'      WHERE parameter_name = ''MSD_MASTER_ORG_LEGACY'''
       ||'      AND   instance_id  = mic.sr_instance_id)'
       ||'  AND     mic.category_set_name = ( SELECT '
       ||'      parameter_value from  msd_setup_parameters'
       ||'      WHERE parameter_name = ''MSD_CATEGORY_SET_NAME_LEGACY'' '
       ||'      AND   instance_id  = mic.sr_instance_id)'
       ||'  AND  (('||v_plan_per_profile||'= 4) OR (msi.ato_forecast_control <> 3))'
       ||'  AND msi.mrp_planning_code <> 6'
       ||'  AND mic.sr_instance_id =msi.sr_instance_id'
       ||'  AND mic.organization_id= msi.organization_id'
       ||'  AND mic.item_name = msi.item_name'
       ||'  AND msi.plan_id   = -1';


      IF lv_debug THEN
        msc_st_util.log_message(lv_sql_stmt);
      END IF;
      EXECUTE IMMEDIATE lv_sql_stmt
              USING     p_instance_id,
                        p_batch_id,
                        p_instance_id,
                        p_batch_id;


   IF (p_link = 1) THEN

   v_sql_stmt := 02;

      lv_sql_stmt :=
       ' INSERT INTO MSD_ST_LEVEL_ASSOCIATIONS'
       ||' (INSTANCE , '
       ||'  LEVEL_ID, '
       ||'  SR_LEVEL_PK, '
       ||'  PARENT_LEVEL_ID,'
       ||'  SR_PARENT_LEVEL_PK,'
       ||'  ATTRIBUTE1, '
       ||'  ATTRIBUTE2, '
       ||'  ATTRIBUTE3, '
       ||'  ATTRIBUTE4, '
       ||'  ATTRIBUTE5, '
       ||'  LAST_UPDATE_DATE, '
       ||'  LAST_UPDATED_BY, '
       ||'  CREATION_DATE, '
       ||'  CREATED_BY, '
       ||'  LAST_UPDATE_LOGIN, '
       ||'  REQUEST_ID, '
       ||'  PROGRAM_APPLICATION_ID, '
       ||'  PROGRAM_ID, '
       ||'  PROGRAM_UPDATE_DATE ) '
       ||'  SELECT DISTINCT'
       ||'  mic.sr_instance_id,'
       ||'  1 ,'
       ||'  mic.inventory_item_id, '
       ||'  2 ,'
       ||'  mic.sr_category_id,'
       ||'  NULL,'
       ||'  NULL,'
       ||'  NULL,'
       ||'  NULL,'
       ||'  NULL,'
       ||'  mic.last_update_date,'
       ||'  mic.last_updated_by,'
       ||'  mic.creation_date,'
       ||'  mic.created_by, '
       ||'  mic.last_update_login, '
       ||'  mic.request_id , '
       ||'  mic.program_application_id, '
       ||'  mic.program_id , '
       ||'  mic.program_update_date '
       ||'  FROM    msc_st_item_categories mic,msc_st_system_items mssi'
       ||'  WHERE   mic.sr_instance_id = :p_instance_id'
       ||'  AND     mic.process_flag          = '||G_VALID
       ||'  AND     mic.batch_id       = :p_batch_id'
       ||'  AND     mic.organization_code = ( SELECT '
       ||'      parameter_value from  msd_setup_parameters'
       ||'      WHERE parameter_name = ''MSD_MASTER_ORG_LEGACY'''
       ||'      AND   instance_id  = mic.sr_instance_id)'
       ||'  AND     mic.category_set_name = ( SELECT '
       ||'      parameter_value from  msd_setup_parameters'
       ||'      WHERE parameter_name = ''MSD_CATEGORY_SET_NAME_LEGACY'' '
       ||'      AND   instance_id  = mic.sr_instance_id)'
       ||'  AND  (('||v_plan_per_profile||'= 4) OR (mssi.ato_forecast_control <> 3))'
       ||'  AND mssi.mrp_planning_code <> 6'
       ||'  AND mic.sr_instance_id =mssi.sr_instance_id'
       ||'  AND mic.organization_id= mssi.organization_id'
       ||'  AND mic.item_name = mssi.item_name'
       ||'  UNION '
       ||'  SELECT DISTINCT'
       ||'  mic.sr_instance_id,'
       ||'  1 ,'
       ||'  mic.inventory_item_id, '
       ||'  2 ,'
       ||'  mic.sr_category_id,'
       ||'  NULL,'
       ||'  NULL,'
       ||'  NULL,'
       ||'  NULL,'
       ||'  NULL,'
       ||'  mic.last_update_date,'
       ||'  mic.last_updated_by,'
       ||'  mic.creation_date,'
       ||'  mic.created_by, '
       ||'  mic.last_update_login, '
       ||'  mic.request_id , '
       ||'  mic.program_application_id, '
       ||'  mic.program_id , '
       ||'  mic.program_update_date '
       ||'  FROM    msc_st_item_categories mic,msc_system_items msi'
       ||'  WHERE   mic.sr_instance_id = :p_instance_id'
       ||'  AND     mic.process_flag          = '||G_VALID
       ||'  AND     mic.batch_id       = :p_batch_id'
       ||'  AND     mic.organization_code = ( SELECT '
       ||'      parameter_value from  msd_setup_parameters'
       ||'      WHERE parameter_name = ''MSD_MASTER_ORG_LEGACY'''
       ||'      AND   instance_id  = mic.sr_instance_id)'
       ||'  AND     mic.category_set_name = ( SELECT '
       ||'      parameter_value from  msd_setup_parameters'
       ||'      WHERE parameter_name = ''MSD_CATEGORY_SET_NAME_LEGACY'' '
       ||'      AND   instance_id  = mic.sr_instance_id)'
       ||'  AND  (('||v_plan_per_profile||'= 4) OR (msi.ato_forecast_control <> 3))'
       ||'  AND msi.mrp_planning_code <> 6'
       ||'  AND mic.sr_instance_id =msi.sr_instance_id'
       ||'  AND mic.organization_id= msi.organization_id'
       ||'  AND mic.item_name = msi.item_name'
       ||'  AND msi.plan_id   = -1';


      IF lv_debug THEN
        msc_st_util.log_message(lv_sql_stmt);
      END IF;

      EXECUTE IMMEDIATE lv_sql_stmt
              USING     p_instance_id,
                        p_batch_id,
                        p_instance_id,
                        p_batch_id;

    END IF ; --p_link

  EXCEPTION
    WHEN OTHERS THEN
     ROLLBACK;

    lv_error_text    := substr('MSD_CL_PRE_PROCESS.LOAD_CATEGORY '||'('
                       ||v_sql_stmt||')'|| SQLERRM, 1, 240);
      msc_st_util.log_message(lv_error_text);
      ERRBUF := lv_error_text;
      RETCODE := G_WARNING;

  END LOAD_CATEGORY;
 /*==========================================================================+
  | DESCRIPTION  : This function performs the validation and loads the data   |
  |                for business object ship to location of customer           |
  +==========================================================================*/

  PROCEDURE LOAD_SITE (ERRBUF          OUT NOCOPY VARCHAR,
                       RETCODE         OUT NOCOPY NUMBER,
                       p_instance_id  IN NUMBER,
                       p_batch_id     IN NUMBER)
  IS
  lv_sql_stmt VARCHAR2(4000);
  lv_error_text VARCHAR2(250);
  lv_debug BOOLEAN := msc_cl_pre_process.v_debug;
  cursor c1 is select count(*) from MSD_HIERARCHY_LEVELS
  where LEVEL_ID = 11
  AND PARENT_LEVEL_ID = 15 ;

  lv_other_exist   PLS_INTEGER := 0;

  BEGIN
    v_sql_stmt := 01;
   lv_sql_stmt :=
       ' INSERT INTO MSD_ST_LEVEL_VALUES '
       ||' (INSTANCE , '
       ||'  LEVEL_ID, '
       ||'  LEVEL_VALUE, '
       ||'  SR_LEVEL_PK, '
       ||'  ATTRIBUTE1, '
       ||'  ATTRIBUTE2, '
       ||'  ATTRIBUTE3, '
       ||'  ATTRIBUTE4, '
       ||'  ATTRIBUTE5, '
       ||'  LAST_UPDATE_DATE, '
       ||'  LAST_UPDATED_BY, '
       ||'  CREATION_DATE, '
       ||'  CREATED_BY, '
       ||'  LAST_UPDATE_LOGIN, '
       ||'  REQUEST_ID, '
       ||'  PROGRAM_APPLICATION_ID, '
       ||'  PROGRAM_ID, '
       ||'  PROGRAM_UPDATE_DATE ) '
       ||'  SELECT DISTINCT'
       ||'  sr_instance_id,'
       ||'  11 ,'
       ||'  tp_site_code, '
       ||'  sr_tp_site_id, '
       ||'  NULL,'
       ||'  NULL,'
       ||'  NULL,'
       ||'  NULL,'
       ||'  NULL,'
       ||'  last_update_date,'
       ||'  last_updated_by,'
       ||'  creation_date,'
       ||'  created_by , '
       ||'  last_update_login, '
       ||'  request_id , '
       ||'  program_application_id, '
       ||'  program_id , '
       ||'  program_update_date '
       ||'  FROM    msc_st_trading_partner_sites'
       ||'  WHERE   partner_type   = 2' -- customer site
       ||'  AND     process_flag          = '||G_VALID
       ||'  AND     sr_instance_id = :p_instance_id'
       ||'  AND     batch_id       = :p_batch_id';

      IF lv_debug THEN
        msc_st_util.log_message(lv_sql_stmt);
      END IF;
     EXECUTE IMMEDIATE lv_sql_stmt
              USING     p_instance_id,
                        p_batch_id;


    OPEN c1;
    FETCH c1 into lv_other_exist;
    CLOSE c1;

    IF  lv_other_exist >= 1 THEN

    v_sql_stmt := 02;
      lv_sql_stmt :=
       ' INSERT INTO MSD_ST_LEVEL_ASSOCIATIONS'
       ||' (INSTANCE , '
       ||'  LEVEL_ID, '
       ||'  SR_LEVEL_PK, '
       ||'  PARENT_LEVEL_ID,'
       ||'  SR_PARENT_LEVEL_PK,'
       ||'  ATTRIBUTE1, '
       ||'  ATTRIBUTE2, '
       ||'  ATTRIBUTE3, '
       ||'  ATTRIBUTE4, '
       ||'  ATTRIBUTE5, '
       ||'  LAST_UPDATE_DATE, '
       ||'  LAST_UPDATED_BY, '
       ||'  CREATION_DATE, '
       ||'  CREATED_BY, '
       ||'  LAST_UPDATE_LOGIN, '
       ||'  REQUEST_ID, '
       ||'  PROGRAM_APPLICATION_ID, '
       ||'  PROGRAM_ID, '
       ||'  PROGRAM_UPDATE_DATE ) '
       ||'  SELECT DISTINCT'
       ||'  sr_instance_id,'
       ||'  11 ,'
       ||'  sr_tp_site_id,'
       ||'  15 ,'
       ||'  sr_tp_id, '
       ||'  NULL,'
       ||'  NULL,'
       ||'  NULL,'
       ||'  NULL,'
       ||'  NULL,'
       ||'  last_update_date,'
       ||'  last_updated_by,'
       ||'  creation_date,'
       ||'  created_by, '
       ||'  last_update_login, '
       ||'  request_id , '
       ||'  program_application_id, '
       ||'  program_id , '
       ||'  program_update_date '
       ||'  FROM    msc_st_trading_partner_sites tps'
       ||'  WHERE   sr_instance_id = :p_instance_id'
       ||'  AND     partner_type = 2'
       ||'  AND     process_flag          = '||G_VALID
       ||'  AND     batch_id       = :p_batch_id';

      IF lv_debug THEN
        msc_st_util.log_message(lv_sql_stmt);
      END IF;

      EXECUTE IMMEDIATE lv_sql_stmt
              USING     p_instance_id,
                        p_batch_id;

  END IF;

  EXCEPTION
   WHEN OTHERS THEN
    ROLLBACK;

    lv_error_text    := substr('MSD_CL_PRE_PROCESS.LOAD_SITE '||'('
                       ||v_sql_stmt||')'|| SQLERRM, 1, 240);
      msc_st_util.log_message(lv_error_text);
      ERRBUF := lv_error_text;
      RETCODE := G_WARNING;

  END LOAD_SITE;

  /*==========================================================================+
  | DESCRIPTION  : This function performs the validation and loads the data   |
  |                for business object demand_classes                         |
  +==========================================================================*/
  PROCEDURE LOAD_DEMAND_CLASS  ( ERRBUF          OUT NOCOPY VARCHAR,
                                 RETCODE         OUT NOCOPY NUMBER,
                                 p_instance_code IN VARCHAR,
                                 p_instance_id  IN NUMBER,
                                 p_batch_id     IN NUMBER)
  IS

  lv_sql_stmt VARCHAR2(4000);
  lv_error_text VARCHAR2(250);
  lv_debug BOOLEAN := msc_cl_pre_process.v_debug;

  cursor c1 (p_instance_code varchar2) is
    select local_id from msd_local_id_setup
    where char1    = p_instance_code
    -- and   char2    = 'All Demand Classes'
    and   level_id = 40;

  lv_all_dcs_pk NUMBER :=0;   --Renamed 'lv_sr_level_pk' to 'lv_all_dcs_pk'.

  lv_all_dcs_desc varchar2(240) := NULL; --Adding this to insert level value - 'All Demand Classes'

  BEGIN

      v_sql_stmt := 01;

      lv_sql_stmt :=
       ' INSERT INTO MSD_ST_LEVEL_VALUES '
       ||' (INSTANCE , '
       ||'  LEVEL_ID, '
       ||'  LEVEL_VALUE, '
       ||'  SR_LEVEL_PK, '
       ||'  LEVEL_VALUE_DESC, '
       ||'  ATTRIBUTE1, '
       ||'  ATTRIBUTE2, '
       ||'  ATTRIBUTE3, '
       ||'  ATTRIBUTE4, '
       ||'  ATTRIBUTE5, '
       ||'  LAST_UPDATE_DATE, '
       ||'  LAST_UPDATED_BY, '
       ||'  CREATION_DATE, '
       ||'  CREATED_BY, '
       ||'  LAST_UPDATE_LOGIN, '
       ||'  REQUEST_ID, '
       ||'  PROGRAM_APPLICATION_ID, '
       ||'  PROGRAM_ID, '
       ||'  PROGRAM_UPDATE_DATE ) '
       ||'  SELECT '
       ||'  sr_instance_id,'
       ||'  34 ,'
       ||'  meaning, '
       ||'  demand_class, '
       ||'  DESCRIPTION, '
       ||'  NULL,'
       ||'  NULL,'
       ||'  NULL,'
       ||'  NULL,'
       ||'  NULL,'
       ||'  last_update_date,'
       ||'  last_updated_by,'
       ||'  creation_date,'
       ||'  created_by, '
       ||'  last_update_login, '
       ||'  request_id , '
       ||'  program_application_id, '
       ||'  program_id , '
       ||'  program_update_date '
       ||'  FROM  msc_st_demand_classes '
       ||'  WHERE sr_instance_id  = :p_instance_id'
       ||'  AND   process_flag    = '||G_VALID
       ||'  AND   batch_id        = :p_batch_id';


      IF lv_debug THEN
        msc_st_util.log_message(lv_sql_stmt);
      END IF;

      EXECUTE IMMEDIATE lv_sql_stmt
              USING     p_instance_id,
                        p_batch_id;


    OPEN c1(p_instance_code);
       FETCH c1 into lv_all_dcs_pk;  --Renamed 'lv_sr_level_pk' to 'lv_all_dcs_pk'.
    CLOSE c1;

     IF lv_all_dcs_pk = 0  THEN  --Renamed 'lv_sr_level_pk' to 'lv_all_dcs_pk'.

        lv_all_dcs_pk    := msd_sr_util.get_all_dcs_pk;     -- Insert 'All Demand Classes' records with sr_level_pk as -6
        lv_all_dcs_desc  := msd_sr_util.get_all_dcs_desc;   -- Calling fuction - msd_sr_util.get_all_dcs_desc, to fetch the level value 'All Demand Classes'

        INSERT INTO  msd_local_id_setup   --  insert into msd_local_id_setup
          (local_id,
           instance_id,
           level_id,
           char1,
           char2,
           last_update_date,
           last_updated_by,
           creation_date,
           created_by  )
           VALUES
           (lv_all_dcs_pk,    --Renamed 'lv_sr_level_pk' to 'lv_all_dcs_pk'.
            p_instance_id,
            40,
            p_instance_code,
            lv_all_dcs_desc,    --Using the value fetched from function - msd_sr_util.get_all_dcs_desc
            sysdate,
            -1,
            sysdate,
            -1);

        INSERT INTO MSD_ST_LEVEL_VALUES   --insert into msd_st_level_values
          (INSTANCE   ,
           LEVEL_ID,
           LEVEL_VALUE,
           SR_LEVEL_PK,
           ATTRIBUTE1,
           ATTRIBUTE2,
           ATTRIBUTE3,
           ATTRIBUTE4,
           ATTRIBUTE5,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY,
           CREATION_DATE,
           CREATED_BY,
           LAST_UPDATE_LOGIN,
           REQUEST_ID,
           PROGRAM_APPLICATION_ID,
           PROGRAM_ID,
           PROGRAM_UPDATE_DATE )
           VALUES
           (p_instance_id,
            40,
            lv_all_dcs_desc,       --Using the value fetched from function - msd_sr_util.get_all_dcs_desc
            lv_all_dcs_pk,         --Renamed 'lv_sr_level_pk' to 'lv_all_dcs_pk'.
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            sysdate,
            -1,
            sysdate,
            -1,
            -1,
            -1,
            -1,
            -1,
            sysdate);

   END IF;

   v_sql_stmt := 02;

      lv_sql_stmt :=
       ' INSERT INTO MSD_ST_LEVEL_ASSOCIATIONS'
       ||' (INSTANCE , '
       ||'  LEVEL_ID, '
       ||'  SR_LEVEL_PK, '
       ||'  PARENT_LEVEL_ID,'
       ||'  SR_PARENT_LEVEL_PK,'
       ||'  ATTRIBUTE1, '
       ||'  ATTRIBUTE2, '
       ||'  ATTRIBUTE3, '
       ||'  ATTRIBUTE4, '
       ||'  ATTRIBUTE5, '
       ||'  LAST_UPDATE_DATE, '
       ||'  LAST_UPDATED_BY, '
       ||'  CREATION_DATE, '
       ||'  CREATED_BY, '
       ||'  LAST_UPDATE_LOGIN, '
       ||'  REQUEST_ID, '
       ||'  PROGRAM_APPLICATION_ID, '
       ||'  PROGRAM_ID, '
       ||'  PROGRAM_UPDATE_DATE ) '
       ||'  SELECT DISTINCT'
       ||'  sr_instance_id,'
       ||'  34 ,'
       ||'  demand_class, '
       ||'  40 ,'
       ||'  :lv_all_dcs_pk, '   --Renamed 'lv_sr_level_pk' to 'lv_all_dcs_pk'.
       ||'  NULL,'
       ||'  NULL,'
       ||'  NULL,'
       ||'  NULL,'
       ||'  NULL,'
       ||'  last_update_date,'
       ||'  last_updated_by,'
       ||'  creation_date,'
       ||'  created_by, '
       ||'  last_update_login, '
       ||'  request_id , '
       ||'  program_application_id, '
       ||'  program_id , '
       ||'  program_update_date '
       ||'  FROM  msc_st_demand_classes '
       ||'  WHERE sr_instance_id  = :p_instance_id'
       ||'  AND   process_flag    = '||G_VALID
       ||'  AND   batch_id        = :p_batch_id';

      IF lv_debug THEN
        msc_st_util.log_message(lv_sql_stmt);
      END IF;

      EXECUTE IMMEDIATE lv_sql_stmt
              USING     lv_all_dcs_pk,   --Renamed 'lv_sr_level_pk' to 'lv_all_dcs_pk'.
                        p_instance_id,
                        p_batch_id;

  EXCEPTION
    WHEN OTHERS THEN
     ROLLBACK;

    lv_error_text    := substr('MSD_CL_PRE_PROCESS.LOAD_DEMAND_CLASS '||'('
                       ||v_sql_stmt||')'|| SQLERRM, 1, 240);
      msc_st_util.log_message(lv_error_text);
      ERRBUF := lv_error_text;
      RETCODE := G_WARNING;

  END LOAD_DEMAND_CLASS;

  /*==========================================================================+
  | DESCRIPTION  : This function performs the validation and loads the data   |
  |                for business object level_values                           |
  +==========================================================================*/
  PROCEDURE LOAD_LEVEL_VALUE(ERRBUF          OUT NOCOPY VARCHAR,
                           RETCODE         OUT NOCOPY NUMBER,
                           p_instance_code IN VARCHAR,
                           p_instance_id   IN NUMBER,
                           p_batch_id      IN NUMBER)
  IS
  TYPE RowidTab IS TABLE OF ROWID INDEX BY BINARY_INTEGER;
  TYPE LevelValueTab IS TABLE OF VARCHAR2(255) INDEX BY BINARY_INTEGER;
  TYPE SrLevelPk IS TABLE OF VARCHAR2(255) INDEX BY BINARY_INTEGER;
  v_index           NUMBER  :=0;
  lb_rowid          RowidTab;
  lb_level_value    LevelValueTab;
  lb_sr_level_pk    SrLevelPk;
  lv_sql_stmt       VARCHAR2(4000);
  lv_batch_id       msd_st_level_values.batch_id%TYPE;
  lv_message_text   msc_errors.error_text%TYPE;
  lv_error_text     VARCHAR2(250);
  lv_debug          BOOLEAN   := msc_cl_pre_process.v_debug;
  lv_batch_size     NUMBER    := msc_cl_pre_process.v_batch_size;
  lv_current_user   NUMBER    := msc_cl_pre_process.v_current_user;
  lv_current_date   DATE      := msc_cl_pre_process.v_current_date;
  lv_return         NUMBER := 0;
/*  lv_master_org_id  NUMBER := 0; */
  lv_column_names   VARCHAR2(5000);
  ex_logging_err    EXCEPTION;

  CURSOR c1(p_batch_id NUMBER)IS
    SELECT rowid
    FROM   msd_st_level_values
    WHERE  process_flag      IN (G_IN_PROCESS,G_ERROR_FLG)
    AND    sr_instance_code = p_instance_code
    AND    batch_id         = p_batch_id;

  CURSOR c2(p_batch_id NUMBER) IS
    SELECT rowid
    FROM   msd_st_level_values
    WHERE  process_flag                  = G_IN_PROCESS
    AND    sr_instance_code              = p_instance_code
    AND    batch_id                      = p_batch_id
    AND    NVL(sr_level_pk,NULL_CHAR)    = NULL_CHAR ;

    lv_instance_type  msc_apps_instances.instance_type%TYPE;

  CURSOR instance_type IS
   SELECT instance_type
   FROM msc_apps_instances
   WHERE instance_id=p_instance_id;
/*
  CURSOR master_org(p_instance_id NUMBER) IS
   SELECT parameter_value
   FROM   msd_setup_parameters
   WHERE  parameter_name = 'MSD_MASTER_ORG'
   AND    instance_id = p_instance_id;
*/
 CURSOR c3(p_batch_id NUMBER)IS
    SELECT level_value
    FROM   msd_st_level_values
    WHERE  process_flag      IN (G_IN_PROCESS,G_ERROR_FLG)
    AND    sr_instance_code = p_instance_code
    AND    level_id         = 1
    AND    batch_id         = p_batch_id;

  BEGIN

      lv_batch_id := p_batch_id;

      lv_column_names :=

        'SR_INSTANCE_CODE||''~''||'
	||'LEVEL_NAME||''~''||'
	||'LEVEL_VALUE||''~''||'
	||'LEVEL_VALUE_DESC||''~''||'
	||'ATTRIBUTE1||''~''||'
	||'ATTRIBUTE2||''~''||'
	||'ATTRIBUTE3||''~''||'
	||'ATTRIBUTE4||''~''||'
	||'ATTRIBUTE5 ';

      OPEN  c1(lv_batch_id);
      FETCH c1 BULK COLLECT INTO lb_rowid;
      CLOSE c1;

      v_sql_stmt := 01;

      FORALL j IN 1..lb_rowid.COUNT
      UPDATE msd_st_level_values
      SET  st_transaction_id = msd_st_level_values_s.NEXTVAL,
           last_update_date  = lv_current_date,
           last_updated_by   = lv_current_user,
           creation_date     = lv_current_date,
           created_by        = lv_current_user
      WHERE  rowid           = lb_rowid(j);


      -- Error out the records where level_name is invalid
        lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_INVALID_VALUE',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'LEVEL_NAME');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

     -- Derive LEVEL_ID from msd_levels
       lv_return := MSC_ST_UTIL.DERIVE_LEVEL_ID
                    (p_table_name     => 'MSD_ST_LEVEL_VALUES',
                     p_level_name_col => 'LEVEL_NAME',
                     p_level_id_col   => 'LEVEL_ID',
                     p_severity      => G_SEV_ERROR,
                     p_message_text   => lv_message_text,
                     p_instance_code  => p_instance_code,
                     p_batch_id       => lv_batch_id,
                     p_error_text     => lv_error_text);


      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;



     OPEN instance_type;
      FETCH instance_type into lv_instance_type;
     CLOSE instance_type;




   IF (lv_instance_type = G_INS_OTHER) THEN

       -- Error out the records where level_name is invalid
        lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_INVALID_VALUE',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'LEVEL_NAME');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

    -- Error out the records if Level_id is IN (1,2,3,7,11,15,34) ASCP/DP common
    -- level values to be collected via MSC flat file

      lv_sql_stmt :=
      'UPDATE    msd_st_level_values'
      ||' SET    process_flag            = '||G_ERROR_FLG||','
      ||'        error_text   =   '||''''||lv_message_text||''''
      ||' WHERE  level_id IN (1,2,3,7,11,15,34)'
      ||' AND    process_flag            = '||G_IN_PROCESS
      ||' AND    batch_id                = :lv_batch_id'
      ||' AND    sr_instance_code        = :p_instance_code';

      IF lv_debug THEN
        msc_st_util.log_message(lv_sql_stmt);
      END IF;
      EXECUTE IMMEDIATE lv_sql_stmt
              USING     lv_batch_id,
                        p_instance_code;

   END IF;

     -- Error out the record if level value is NULL
      lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_COL_VAL_NULL',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'LEVEL_VALUE');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

      v_sql_stmt := 03;
      lv_sql_stmt :=
      'UPDATE    msd_st_level_values'
      ||' SET    process_flag            = '||G_ERROR_FLG||','
      ||'        error_text      = '||''''||lv_message_text||''''
      ||' WHERE  NVL(level_value, '||''''||NULL_CHAR||''''||') '
      ||'        =                 '||''''||NULL_CHAR||''''
      ||' AND    batch_id                = :lv_batch_id'
      ||' AND    process_flag            = '||G_IN_PROCESS
      ||' AND    sr_instance_code        = :p_instance_code';

      IF lv_debug THEN
        msc_st_util.log_message(lv_sql_stmt);
      END IF;
      EXECUTE IMMEDIATE lv_sql_stmt
              USING     lv_batch_id,
                        p_instance_code;




   IF (lv_instance_type <> G_INS_OTHER) THEN

      -- Now derive sr_level_pk from the ASCP tables if Level Values are loaded forERP data.
       v_sql_stmt := 05;
       lv_return := MSC_ST_UTIL.DERIVE_SETUP_SR_LEVEL_PK
                    (p_table_name        => 'MSD_ST_LEVEL_VALUES',
                     p_level_val_col     => 'LEVEL_VALUE',
                     p_level_pk_col      => 'SR_LEVEL_PK',
                     p_level_id_col      => 'LEVEL_ID',
                     p_instance_code     => p_instance_code,
                     p_instance_id       => p_instance_id,
                     p_error_text        => lv_error_text,
                     p_batch_id          => lv_batch_id);

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;



     v_sql_stmt := 06;
     OPEN  c3(lv_batch_id);
      FETCH c3 BULK COLLECT INTO lb_level_value ;

      IF c3%ROWCOUNT > 0  THEN
        -- Insert into the Item List Price table the UOM for the Master orgs
/*
        OPEN master_org(p_instance_id);
           FETCH master_org into lv_master_org_id;
        CLOSE master_org;
*/
        v_sql_stmt := 07;
        FORALL j IN 1..lb_level_value.COUNT
        INSERT INTO  MSD_ST_ITEM_LIST_PRICE
         (INSTANCE ,
          ITEM ,
          LIST_PRICE ,
          AVG_DISCOUNT ,
          BASE_UOM ,
          SR_ITEM_PK ,
          ITEM_TYPE_ID ,
          FORECAST_TYPE_ID ,
          SR_INSTANCE_CODE,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          CREATION_DATE,
          CREATED_BY,
          LAST_UPDATE_LOGIN,
          REQUEST_ID,
          PROGRAM_APPLICATION_ID,
          PROGRAM_ID,
          PROGRAM_UPDATE_DATE )
          SELECT
           SR_INSTANCE_ID ,
           ITEM_NAME ,
           LIST_PRICE ,
           AVERAGE_DISCOUNT ,
           UOM_CODE ,
           SR_INVENTORY_ITEM_ID ,
           BOM_ITEM_TYPE ,
           ATO_FORECAST_CONTROL ,
           p_instance_code,
           last_update_date,
           last_updated_by,
           creation_date,
           created_by ,
           last_update_login,
           request_id ,
           program_application_id,
           program_id ,
           program_update_date
           FROM    MSC_SYSTEM_ITEMS
           WHERE item_name       = lb_level_value(j)
           AND   sr_instance_id  = p_instance_id
           AND   plan_id         = -1
           AND   organization_id =   (select mtp.sr_tp_id
	                              from msc_trading_partners mtp,msd_setup_parameters msp
	                              where msp.parameter_name     ='MSD_MASTER_ORG_LEGACY'
	                              and   msp.instance_id        = p_instance_id
	                              and   msp.parameter_value    = substr(mtp.organization_code,instr(mtp.organization_code,':')+1,length(mtp.organization_code))
	                              and   nvl(mtp.company_id,-1) = -1
	                              and   mtp.sr_instance_id     = msp.instance_id);
/*           AND   organization_id    = lv_master_org_id; */


      END IF ;  --IF c3%ROWCOUNT > 0  THEN
     CLOSE c3;

   END IF;   --IF (lv_instance_type <> G_INS_OTHER) THEN

      -- Now derive sr_level_pk from the msd_local_id_setup
     v_sql_stmt := 08;
     lv_return := MSC_ST_UTIL.DERIVE_SR_LEVEL_PK
                    (p_table_name        => 'MSD_ST_LEVEL_VALUES',
                     p_level_val_col     => 'LEVEL_VALUE',
                     p_level_pk_col      => 'SR_LEVEL_PK',
                     p_level_id_col      => 'LEVEL_ID',
                     p_instance_code     => p_instance_code,
                     p_error_text        => lv_error_text,
                     p_batch_id          => lv_batch_id);

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

      --Call to customised validation.
      MSC_CL_PRE_PROCESS_HOOK.ENTITY_VALIDATION
        (ERRBUF         => lv_error_text,
         RETCODE        => lv_return,
         pBatchID       => lv_batch_id,
         pInstanceCode  => p_instance_code,
         pEntityName    => 'MSD_ST_LEVEL_VALUES',
         pInstanceID    => p_instance_id);

      IF NVL(lv_return,0) <> 0 THEN
        RAISE ex_logging_err;
      END IF;

   -- Generate the sr_level_pk

    OPEN  c2(lv_batch_id);
    FETCH c2 BULK COLLECT INTO lb_rowid ;

      IF c2%ROWCOUNT > 0  THEN

/*      FORALL j IN 1..lb_rowid.COUNT
        UPDATE msd_st_level_values
        SET    sr_level_pk  =  msd_common_utilities.get_sr_level_pk(p_instance_id,p_instance_code)
        WHERE  rowid        =  lb_rowid(j);
*/

       LOOP
         v_index :=v_index + 1;
            lb_sr_level_pk(v_index) := msd_common_utilities.get_sr_level_pk(p_instance_id,p_instance_code);
            EXIT WHEN v_index = lb_rowid.COUNT;
       END LOOP;

        FORALL j IN 1..lb_rowid.COUNT
        UPDATE msd_st_level_values
        SET    sr_level_pk  =  lb_sr_level_pk(j)
        WHERE  rowid        =  lb_rowid(j);


        -- Insert into the LID table this new level_value

        FORALL j IN lb_rowid.FIRST..lb_rowid.LAST
        INSERT INTO  msd_local_id_setup
          (local_id,
           instance_id,
           level_id,
           data_source_type,
           char1,
           char2,
           last_update_date,
           last_updated_by,
           creation_date,
           created_by  )
        SELECT
           TO_NUMBER(sr_level_pk),
           p_instance_id,
           level_id,
           data_source_type,
           p_instance_code,
           level_value,
           last_update_date,
           last_updated_by,
           creation_date,
           created_by
         FROM msd_st_level_values
         WHERE rowid = lb_rowid(j);

      END IF ;

    CLOSE c2;

     -- Set the process flag as Valid and populate instance_id
      lv_return := MSC_ST_UTIL.SET_PROCESS_FLAG
                        (p_table_name     => 'MSD_ST_LEVEL_VALUES',
                         p_instance_id    => p_instance_id,
                         p_instance_code  => p_instance_code,
                         p_process_flag   => G_VALID,
                         p_error_text     => lv_error_text,
                         p_batch_id       => lv_batch_id,
                         p_instance_id_col=> 'INSTANCE');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

  -- Inserting all the errored out records into MSC_ERRORS

      lv_return := MSC_ST_UTIL.LOG_ERROR
                   (p_table_name        => 'MSD_ST_LEVEL_VALUES',
                    p_instance_code     => p_instance_code,
                    p_row               => lv_column_names,
                    p_severity          => G_SEV_ERROR,
                    p_error_text        => lv_error_text,
                    p_message_text      => NULL,
                    p_batch_id          => lv_batch_id);

  IF(lv_return <> 0) THEN
      msc_st_util.log_message(lv_error_text);
  END IF;


     LOAD_LEVEL_ORG_ASSCNS ( p_instance_code,
                             p_instance_id );

     LOAD_ITEM_RELATIONSHIP ( p_instance_code,
                              p_instance_id);


   COMMIT;

    EXCEPTION
      WHEN ex_logging_err THEN
        ROLLBACK;

        ERRBUF := lv_error_text;
        RETCODE := G_WARNING;
        msc_st_util.log_message(lv_error_text);

     WHEN OTHERS THEN
      ROLLBACK;

      lv_error_text    := substr('MSD_CL_PRE_PROCESS.LOAD_LEVEL_VALUE '||'('
                       ||v_sql_stmt||')'|| SQLERRM, 1, 240);
      msc_st_util.log_message(lv_error_text);
      ERRBUF := lv_error_text;
      RETCODE := G_WARNING;

  END LOAD_LEVEL_VALUE ;

  /*==========================================================================+
  | DESCRIPTION  : This function performs the validation and loads the data   |
  |                for business object level_value_associations               |
  +==========================================================================*/
  PROCEDURE LOAD_LEVEL_ASSOC( ERRBUF          OUT NOCOPY VARCHAR,
                              RETCODE         OUT NOCOPY VARCHAR,
                              p_instance_code IN VARCHAR,
                              p_instance_id   IN NUMBER,
                              p_batch_id      IN NUMBER)
  IS
  TYPE RowidTab IS TABLE OF ROWID INDEX BY BINARY_INTEGER;
  lb_rowid          RowidTab;
  lv_sql_stmt       VARCHAR2(4000);
  lv_batch_id       msd_st_level_associations.batch_id%TYPE;
  lv_message_text   msc_errors.error_text%TYPE;
  lv_error_text     VARCHAR2(250);
  lv_debug          BOOLEAN   := msc_cl_pre_process.v_debug;
  lv_batch_size     NUMBER    := msc_cl_pre_process.v_batch_size;
  lv_current_user   NUMBER    := msc_cl_pre_process.v_current_user;
  lv_current_date   DATE      := msc_cl_pre_process.v_current_date;
  lv_return         NUMBER := 0;
  ex_logging_err    EXCEPTION;
  lv_column_names   VARCHAR2(5000);

  CURSOR c1(p_batch_id NUMBER)IS
    SELECT rowid
    FROM   msd_st_level_associations
    WHERE  process_flag      IN (G_IN_PROCESS,G_ERROR_FLG)
    AND    sr_instance_code = p_instance_code
    AND    batch_id         = p_batch_id;

   BEGIN

      lv_batch_id := p_batch_id;

      lv_column_names :=

      '	SR_INSTANCE_CODE		||''~''||'
    ||'	LEVEL_NAME		||''~''||'
    ||'	SR_LEVEL_VALUE		||''~''||'
    ||'	PARENT_LEVEL_NAME	||''~''||'
    ||'	SR_PARENT_LEVEL_VALUE	||''~''||'
    ||'	ATTRIBUTE1		||''~''||'
    ||'	ATTRIBUTE2		||''~''||'
    ||'	ATTRIBUTE3		||''~''||'
    ||'	ATTRIBUTE4		||''~''||'
    ||'	ATTRIBUTE5';


      OPEN  c1(lv_batch_id);
      FETCH c1 BULK COLLECT INTO lb_rowid;
      CLOSE c1;

      v_sql_stmt := 04;
      FORALL j IN lb_rowid.FIRST..lb_rowid.LAST
      UPDATE msd_st_level_associations
      SET  st_transaction_id = msd_st_level_associations_s.NEXTVAL,
           last_update_date  = lv_current_date,
           last_updated_by   = lv_current_user,
           creation_date     = lv_current_date,
           created_by        = lv_current_user
      WHERE  rowid           = lb_rowid(j);


      -- Error out the records where level_name is invalid
        lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_INVALID_VALUE',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'LEVEL_NAME');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

     -- Derive LEVEL_ID from msd_levels
       lv_return := MSC_ST_UTIL.DERIVE_LEVEL_ID
                    (p_table_name     => 'MSD_ST_LEVEL_ASSOCIATIONS',
                     p_level_name_col => 'LEVEL_NAME',
                     p_level_id_col   => 'LEVEL_ID',
                     p_severity      => G_SEV_ERROR,
                     p_message_text   => lv_message_text,
                     p_instance_code  => p_instance_code,
                     p_batch_id       => lv_batch_id,
                     p_error_text     => lv_error_text);

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

      -- Error out the records where parent_level_name is invalid
        lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_INVALID_VALUE',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'PARENT_LEVEL_NAME');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

     -- Derive PARENT_LEVEL_ID from msd_levels
       lv_return := MSC_ST_UTIL.DERIVE_LEVEL_ID
                    (p_table_name     => 'MSD_ST_LEVEL_ASSOCIATIONS',
                     p_level_name_col => 'PARENT_LEVEL_NAME',
                     p_level_id_col   => 'PARENT_LEVEL_ID',
                     p_severity      => G_SEV_ERROR,
                     p_message_text   => lv_message_text,
                     p_instance_code  => p_instance_code,
                     p_batch_id       => lv_batch_id,
                     p_error_text     => lv_error_text);

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

      -- set the message, sr_level_value  is invalid

        lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_INVALID_VALUE',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'SR_LEVEL_VALUE');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

     -- Derive SR_LEVEL_PK from msd_level_value or msd_st_level_values

       lv_return := MSC_ST_UTIL.DERIVE_LEVEL_PK
                    (p_table_name      => 'MSD_ST_LEVEL_ASSOCIATIONS',
                     p_level_val_col   => 'SR_LEVEL_VALUE',
                     p_level_name_col    => 'LEVEL_NAME',
                     p_level_pk_col => 'SR_LEVEL_PK',
                     p_instance_code   => p_instance_code,
                     p_instance_id     => p_instance_id,
                     p_message_text    => lv_message_text,
                     p_batch_id        => lv_batch_id,
                     p_error_text      => lv_error_text);

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

      -- set the message, sr_parent_level_value  is invalid

        lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_INVALID_VALUE',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'SR_PARENT_LEVEL_VALUE');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

     -- Derive SR_PARENT_LEVEL_PK from msd_level_values or msd_st_level_values

       lv_return := MSC_ST_UTIL.DERIVE_LEVEL_PK
                    (p_table_name      => 'MSD_ST_LEVEL_ASSOCIATIONS',
                     p_level_val_col   => 'SR_PARENT_LEVEL_VALUE',
                     p_level_name_col    => 'PARENT_LEVEL_NAME',
                     p_level_pk_col => 'SR_PARENT_LEVEL_PK',
                     p_instance_code   => p_instance_code,
                     p_instance_id     => p_instance_id,
                     p_message_text    => lv_message_text,
                     p_batch_id        => lv_batch_id,
                     p_error_text      => lv_error_text);
      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

     -- Validate whether the child and parent level exist in msd_level_hierarchies
     -- This can exist under any hierarhcy
     -- Set the message,

      lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSD_PP_ASSOC_INVALID',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'LEVEL_NAME',
                      p_token2            => 'COLUMN_NAME',
                      p_token_value2      => 'PARENT_LEVEL_NAME');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

     --Error out if parent child-association not there in any hierarchy
    v_sql_stmt := 07;

    lv_sql_Stmt:=
    'UPDATE     msd_st_level_associations mla'
    ||' SET     process_flag              ='||G_ERROR_FLG||','
    ||'         error_text   = '||''''||lv_message_text||''''
    ||' WHERE   NOT EXISTS ( SELECT 1'
    ||'         FROM   msd_hierarchy_levels mhl'
    ||'         WHERE  mla.level_id          = mhl.level_id'
    ||'         AND    mla.parent_level_id   = mhl.parent_level_id)'
    ||' AND     process_flag              ='|| G_IN_PROCESS
    ||' AND     batch_id                  = :lv_batch_id'
    ||' AND     sr_instance_code          = :p_instance_code';

    IF lv_debug THEN
           msc_st_util.log_message(lv_sql_stmt);
    END IF;

   EXECUTE IMMEDIATE lv_sql_stmt
               USING lv_batch_id,
                     p_instance_code ;


      --Call to customised validation.
      MSC_CL_PRE_PROCESS_HOOK.ENTITY_VALIDATION
        (ERRBUF         => lv_error_text,
         RETCODE        => lv_return,
         pBatchID       => null,
         pInstanceCode  => p_instance_code,
         pEntityName    => 'MSD_ST_LEVEL_ASSOCIATIONS',
         pInstanceID    => p_instance_id);

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

     -- Set the process flag as Valid and populate instance_id
      lv_return := MSC_ST_UTIL.SET_PROCESS_FLAG
                        (p_table_name     => 'MSD_ST_LEVEL_ASSOCIATIONS',
                         p_instance_id    => p_instance_id,
                         p_instance_code  => p_instance_code,
                         p_process_flag   => G_VALID,
                         p_error_text     => lv_error_text,
                         p_batch_id       => lv_batch_id,
                         p_instance_id_col=> 'INSTANCE');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

    -- Inserting all the errored out records into MSC_ERRORS:

      lv_return := MSC_ST_UTIL.LOG_ERROR
                   (p_table_name        => 'MSD_ST_LEVEL_ASSOCIATIONS',
                    p_instance_code     => p_instance_code,
                    p_row               => lv_column_names,
                    p_severity          => G_SEV_ERROR,
                    p_error_text        => lv_error_text,
                    p_message_text      => NULL,
                    p_batch_id          => lv_batch_id);

      IF(lv_return <> 0) THEN
        msc_st_util.log_message(lv_error_text);
      END IF;
      COMMIT;

    EXCEPTION
      WHEN ex_logging_err THEN
        ROLLBACK;

        ERRBUF := lv_error_text;
        RETCODE := G_WARNING;
        msc_st_util.log_message(lv_error_text);

     WHEN OTHERS THEN
      ROLLBACK;

      lv_error_text    := substr('MSD_CL_PRE_PROCESS.LOAD_LEVEL_ASSOC'||'('
                       ||v_sql_stmt||')'|| SQLERRM, 1, 240);
      msc_st_util.log_message(lv_error_text);
      ERRBUF := lv_error_text;
      RETCODE := G_WARNING;

  END LOAD_LEVEL_ASSOC ;

  /*==========================================================================+
  | DESCRIPTION  : This function performs the validation and loads the data   |
  |                for business object booking data                           |
  +==========================================================================*/

  PROCEDURE LOAD_BOOKING_DATA(ERRBUF          OUT NOCOPY VARCHAR,
                              RETCODE         OUT NOCOPY NUMBER,
                              p_instance_code IN VARCHAR,
                              p_instance_id   IN NUMBER,
                              p_batch_id      IN NUMBER)
  IS
  TYPE RowidTab IS TABLE OF ROWID INDEX BY BINARY_INTEGER;
  lb_rowid          RowidTab;
/*  lb_rowid1         RowidTab;  Bug3749959 */
  lv_sql_stmt       VARCHAR2(4000);
  lv_batch_id       msd_st_booking_data.batch_id%TYPE;
  lv_message_text   msc_errors.error_text%TYPE;
  lv_my_company     msc_companies.company_name%TYPE := GET_MY_COMPANY;
  lv_error_text     VARCHAR2(250);
  lv_debug          BOOLEAN   := msc_cl_pre_process.v_debug;
  lv_batch_size     NUMBER    := msc_cl_pre_process.v_batch_size;
  lv_current_user   NUMBER    := msc_cl_pre_process.v_current_user;
  lv_current_date   DATE      := msc_cl_pre_process.v_current_date;
  lv_return         NUMBER := 0;
  ex_logging_err    EXCEPTION;
  lv_column_names   VARCHAR2(5000);
/*
  lv_other_desc   varchar2(240) := NULL;  --Adding this to insert level value - 'Others'
  lv_all_dcs_desc varchar2(240) := NULL;  --Adding this to insert level value - 'All Demand Classes'
Bug3749959 */

  lv_instance_type  msc_apps_instances.instance_type%TYPE;
/*  lv_other_exist NUMBER :=0;
    lv_all_dcs_pk  NUMBER :=0;  --Renamed 'lv_sr_level_pk' to 'lv_all_dcs_pk'.
Bug3749959 */

  CURSOR instance_type IS
   SELECT instance_type
   FROM msc_apps_instances
   WHERE instance_id=p_instance_id;

  CURSOR c1(p_batch_id NUMBER)IS
    SELECT rowid
    FROM   msd_st_booking_data
    WHERE  process_flag      IN (G_IN_PROCESS,G_ERROR_FLG)
    AND    sr_instance_code = p_instance_code
    AND    batch_id         = p_batch_id;
/*
   CURSOR c2(p_batch_id NUMBER)IS
    SELECT rowid
    FROM   msd_st_booking_data
    WHERE  process_flag      IN (G_IN_PROCESS,G_ERROR_FLG)
    AND    nvl(DEMAND_CLASS_LVL_VAL,'-1') = '-1'
    AND    sr_instance_code = p_instance_code
    AND    batch_id         = p_batch_id;

   cursor c3 (p_instance varchar2) is
    select count(*) from MSD_LEVEL_VALUES
    where LEVEL_ID = 34
    and   instance = p_instance
    and   SR_LEVEL_PK = to_char(v_null_pk);  --Using global variable v_null_pk insteda of hardcoding -777 at multiple places.

   cursor c4 (p_instance_code varchar2) is
    select local_id from msd_local_id_setup
    where char1    = p_instance_code
    -- and   char2    = 'All Demand Classes'
    and   level_id = 40;
Bug3749959 */


   BEGIN

     lv_batch_id := p_batch_id;
     lv_column_names :=
	'	SR_INSTANCE_CODE	||''~''||'
	||'	INV_ORG			||''~''||'
	||'	ITEM			||''~''||'
	||'	CUSTOMER		||''~''||'
	||'	SALES_CHANNEL		||''~''||'
	||'	SALES_REP		||''~''||'
	||'	SHIP_TO_LOC		||''~''||'
	||'	PARENT_ITEM		||''~''||'
	||'	USER_DEFINED_LEVEL1	||''~''||'
	||'	USER_DEFINED1		||''~''||'
	||'	USER_DEFINED_LEVEL2	||''~''||'
	||'	USER_DEFINED2		||''~''||'
	||'	BOOKED_DATE		||''~''||'
	||'	REQUESTED_DATE		||''~''||'
	||'	PROMISED_DATE		||''~''||'
	||'	SCHEDULED_DATE		||''~''||'
	||'	AMOUNT			||''~''||'
	||'	QTY_ORDERED		||''~''||'
	||'	ORIGINAL_ITEM ';

      OPEN  c1(lv_batch_id);
      FETCH c1 BULK COLLECT INTO lb_rowid;
      CLOSE c1;

      v_sql_stmt := 04;
      FORALL j IN lb_rowid.FIRST..lb_rowid.LAST
      UPDATE msd_st_booking_data
      SET  st_transaction_id = msd_st_booking_data_s.NEXTVAL,
           last_update_date  = lv_current_date,
           last_updated_by   = lv_current_user,
           creation_date     = lv_current_date,
           created_by        = lv_current_user
      WHERE  rowid           = lb_rowid(j);

/*
      OPEN  c2(lv_batch_id);
       FETCH c2 BULK COLLECT INTO lb_rowid1;
      CLOSE c2;

   IF ( lb_rowid1.COUNT <> 0 ) THEN

     lv_other_desc    := msd_sr_util.get_null_desc;      --Calling fuction - msd_sr_util.get_null_desc, to fetch the level value 'Others'
     lv_all_dcs_desc  := msd_sr_util.get_all_dcs_desc;   --Calling fuction - msd_sr_util.get_all_dcs_desc, to fetch the level value 'All Demand Classes'

      v_sql_stmt := 05;
      FORALL j IN lb_rowid1.FIRST..lb_rowid1.LAST
      UPDATE msd_st_booking_data
      SET  DEMAND_CLASS_LVL_VAL  = lv_other_desc  --Using the value fetched from function - msd_sr_util.get_null_desc
      WHERE  rowid               = lb_rowid1(j);


      OPEN c3(p_instance_id);
       FETCH c3 into lv_other_exist;
      CLOSE c3;

      IF  lv_other_exist = 0 THEN
        INSERT INTO MSD_ST_LEVEL_VALUES
        (INSTANCE   ,
        LEVEL_ID,
        LEVEL_VALUE,
        SR_LEVEL_PK,
        ATTRIBUTE1,
        ATTRIBUTE2,
        ATTRIBUTE3,
        ATTRIBUTE4,
        ATTRIBUTE5,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN,
        REQUEST_ID,
        PROGRAM_APPLICATION_ID,
        PROGRAM_ID,
        PROGRAM_UPDATE_DATE )
        VALUES
        (p_instance_id,
        34,
        lv_other_desc,   --Using the value fetched from function - msd_sr_util.get_null_desc
        to_char(v_null_pk),   --Using global variable v_null_pk insteda of hardcoding -777 at multiple places.
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        sysdate,
        -1,
        sysdate,
        -1,
        -1,
        -1,
        -1,
        -1,
        sysdate);

      END IF;

    OPEN c4(p_instance_code);
     FETCH c4 into lv_all_dcs_pk;  --Renamed 'lv_sr_level_pk' to 'lv_all_dcs_pk'.
    CLOSE c4;

     IF lv_all_dcs_pk = 0  THEN  --Renamed 'lv_sr_level_pk' to 'lv_all_dcs_pk'.

        lv_all_dcs_pk := msd_sr_util.get_all_dcs_pk; -- Fetching the SR_LEVEL_PK for 'ALL Demand Classes' level value from function - msd_sr_util.get_all_dcs_pk

        INSERT INTO  msd_local_id_setup   --  insert into msd_local_id_setup
          (local_id,
           instance_id,
           level_id,
           char1,
           char2,
           last_update_date,
           last_updated_by,
           creation_date,
           created_by  )
           VALUES
           (lv_all_dcs_pk,  --Renamed 'lv_sr_level_pk' to 'lv_all_dcs_pk'.
            p_instance_id,
            40,
            p_instance_code,
            lv_all_dcs_desc,   --Using the value fetched from function - msd_sr_util.get_all_dcs_desc
            sysdate,
            -1,
            sysdate,
            -1);

 --    lv_sr_level_pk := -6;     -- Inserting 'All Demand Classes' records with sr_level_pk as -6


     INSERT INTO MSD_ST_LEVEL_VALUES   --Inserting into MSD_ST_LEVEL_VALUES
       (INSTANCE   ,
        LEVEL_ID,
        LEVEL_VALUE,
        SR_LEVEL_PK,
        ATTRIBUTE1,
        ATTRIBUTE2,
        ATTRIBUTE3,
        ATTRIBUTE4,
        ATTRIBUTE5,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN,
        REQUEST_ID,
        PROGRAM_APPLICATION_ID,
        PROGRAM_ID,
        PROGRAM_UPDATE_DATE )
        VALUES
        (p_instance_id,
        40,
        lv_all_dcs_desc,       --Using the value fetched from function - msd_sr_util.get_all_dcs_desc
        lv_all_dcs_pk,         --Renamed 'lv_sr_level_pk' to 'lv_all_dcs_pk'.
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        sysdate,
        -1,
        sysdate,
        -1,
        -1,
        -1,
        -1,
        -1,
        sysdate);


          --   Insert into msd_st_level_associations.

      INSERT INTO MSD_ST_LEVEL_ASSOCIATIONS
        (INSTANCE   ,
        LEVEL_ID,
        SR_LEVEL_PK,
        PARENT_LEVEL_ID,
        SR_PARENT_LEVEL_PK,
        ATTRIBUTE1,
        ATTRIBUTE2,
        ATTRIBUTE3,
        ATTRIBUTE4,
        ATTRIBUTE5,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN,
        REQUEST_ID,
        PROGRAM_APPLICATION_ID,
        PROGRAM_ID,
        PROGRAM_UPDATE_DATE )
        VALUES
        (p_instance_id,
        34,
        to_char(v_null_pk),  --Using global variable v_null_pk insteda of hardcoding -777 at multiple places.
        40,
        lv_all_dcs_pk,   --Renamed 'lv_sr_level_pk' to 'lv_all_dcs_pk'.
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        sysdate,
        -1,
        sysdate,
        -1,
        -1,
        -1,
        -1,
        -1,
        sysdate);


     END IF;

  END IF;
Bug3749959 */

     OPEN instance_type;
      FETCH instance_type into lv_instance_type;
     CLOSE instance_type;

    IF (lv_instance_type = G_INS_OTHER) THEN

       -- Set the message to validate customer-ship to location combination
      lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_COL_REF_NOT_EXIST',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAMES',
                      p_token_value1      => 'SR_INSTANCE_CODE AND'
                                             ||' CUSTOMER AND SHIP_TO_LOC',
                      p_token2            => 'MASTER_TABLE',
                      p_token_value2      => 'MSC_TRADING_PARTNER_SITES',
                      p_token3            => 'CHILD_TABLE',
                      p_token_value3      => 'MSD_ST_BOOKING_DATA');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

      -- Validate customer-ship to location combination
      v_sql_stmt := 06;
      UPDATE msd_st_booking_data mbd
      SET    process_flag = G_ERROR_FLG,
             error_text   = lv_message_text
      WHERE NOT EXISTS(SELECT 1
                       FROM   msc_local_id_setup mls
                       WHERE  mls.char1                   =  mbd.sr_instance_code
                       AND    nvl(mls.char2,lv_my_company) = lv_my_company
                       AND    mls.char3                   = mbd.customer
                       AND    mls.char4                   = mbd.ship_to_loc
                       AND    mls.number1                 = 2                --customer
                       AND    mls.entity_name             = 'SR_TP_SITE_ID')
      AND    mbd.process_flag               = G_IN_PROCESS
      AND    mbd.sr_instance_code           = p_instance_code
      AND    mbd.batch_id                   = p_batch_id;

   END IF;

        -- Set the message
        lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_INVALID_VALUE',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'ITEM');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

     -- Derive sr_item_pk from msd_st_level_values and msd_level_values

       lv_return :=  MSC_ST_UTIL.DERIVE_SR_PK
                       (p_table_name         => 'MSD_ST_BOOKING_DATA',
                        p_column_name        => 'ITEM',
                        p_pk_col_name        => 'SR_ITEM_PK',
                        p_level_id           => 1,
                        p_instance_code      => p_instance_code,
                        p_instance_id        => p_instance_id,
                        p_message_text       => lv_message_text,
                        p_batch_id           => lv_batch_id,
                        p_severity           => G_SEV_ERROR,	-- Against Bug#2415379
                        p_error_text         => lv_error_text);

        IF lv_return <> 0 THEN
            RAISE ex_logging_err;
        END IF;

      -- Code generated against the bug number : 2357511
      v_sql_stmt := 07;

      lv_sql_Stmt:=
      'UPDATE     msd_st_booking_data '
      ||' SET     ORIGINAL_ITEM      =ITEM '
      ||' WHERE   ORIGINAL_ITEM IS NULL '
      ||' AND     process_flag              ='|| G_IN_PROCESS
      ||' AND     batch_id                  = :lv_batch_id'
      ||' AND     sr_instance_code          = :p_instance_code';

      IF lv_debug THEN
          msc_st_util.log_message(lv_sql_stmt);
      END IF;

     EXECUTE IMMEDIATE lv_sql_stmt
               USING lv_batch_id,
                     p_instance_code ;

        -- Set the message
        lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_INVALID_VALUE',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'ORIGINAL_ITEM');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

     -- Derive SR_ORIGINAL_ITEM_PK from msd_st_level_values and msd_level_values

       lv_return :=  MSC_ST_UTIL.DERIVE_SR_PK
                       (p_table_name         => 'MSD_ST_BOOKING_DATA',
                        p_column_name        => 'ORIGINAL_ITEM',
                        p_pk_col_name        => 'SR_ORIGINAL_ITEM_PK',
                        p_level_id           => 1,
                        p_instance_code      => p_instance_code,
                        p_instance_id        => p_instance_id,
                        p_message_text       => lv_message_text,
                        p_batch_id           => lv_batch_id,
                        p_severity           => G_SEV_ERROR,	-- Against Bug#2415379
                        p_error_text         => lv_error_text);

        IF lv_return <> 0 THEN
            RAISE ex_logging_err;
        END IF;

         -- Set the message
        lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_INVALID_VALUE',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'INV_ORG');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

     -- Derive sr_inv_org_pk from msd_st_level_values and msd_level_values

       lv_return :=  MSC_ST_UTIL.DERIVE_SR_PK
                       (p_table_name         => 'MSD_ST_BOOKING_DATA',
                        p_column_name        => 'INV_ORG',
                        p_pk_col_name        => 'SR_INV_ORG_PK',
                        p_level_id           => 7,
                        p_instance_code      => p_instance_code,
                        p_instance_id        => p_instance_id,
                        p_message_text       => lv_message_text,
                        p_batch_id           => lv_batch_id,
                        p_severity           => G_SEV_ERROR,	-- Against Bug#2415379
                        p_error_text         => lv_error_text);

        IF lv_return <> 0 THEN
            RAISE ex_logging_err;
        END IF;

  IF (lv_instance_type = G_INS_OTHER) THEN

        lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_COL_REF_NOT_EXIST',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAMES',
                      p_token_value1      => 'SR_INSTANCE_CODE AND'
                                             ||' INV_ORG AND ITEM AND ITEM.ATO_FORECAST_CONTROL'
                                             ||' AND ITEM.MRP_PLANNING_CODE',
                      p_token2            => 'MASTER_TABLE',
                      p_token_value2      => 'MSC_SYSTEM_ITEMS',
                      p_token3            => 'CHILD_TABLE',
                      p_token_value3      => 'MSD_ST_BOOKING_DATA');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

      -- Validate item-org combination
      v_sql_stmt := 15;

      UPDATE msd_st_booking_data mbd
      SET    process_flag = G_ERROR_FLG,
             error_text   = lv_message_text
      WHERE NOT EXISTS(SELECT 1
                       FROM   msc_st_system_items msi
                       WHERE  msi.sr_instance_id                  = p_instance_id
                       AND    nvl(msi.company_name,lv_my_company) = lv_my_company
                       AND    msi.organization_id                 = mbd.sr_inv_org_pk
                       AND    msi.item_name                       = mbd.item
                       AND   ((v_plan_per_profile = 4) OR (msi.ato_forecast_control <> 3))        --forecast control - none
                       AND   ((msi.mrp_planning_code                <> 6 ) OR (msi.pick_components_flag='Y' ))                          --Not planned item
                       UNION
                       SELECT 1
                       FROM   msc_system_items mls
                       WHERE  mls.sr_instance_id                  = p_instance_id
                       AND    mls.organization_id                 = mbd.sr_inv_org_pk
                       AND    mls.item_name                       = mbd.item
                       AND    mls.plan_id                         = -1
                       AND   ((v_plan_per_profile = 4) OR (mls.ato_forecast_control <> 3))          --forecast control - none
                       AND   ((mls.mrp_planning_code                <> 6 ) OR (mls.pick_components_flag='Y' )))                           --Not planned item
      AND    mbd.process_flag           = G_IN_PROCESS
      AND    mbd.sr_instance_code       = p_instance_code
      AND    mbd.batch_id               = p_batch_id;

  END IF;


        -- Set the message
        lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_INVALID_VALUE',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'CUSTOMER');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

     -- Derive sr_customer_pk from msd_st_level_values and msd_level_values

       lv_return :=  MSC_ST_UTIL.DERIVE_SR_PK
                       (p_table_name         => 'MSD_ST_BOOKING_DATA',
                        p_column_name        => 'CUSTOMER',
                        p_pk_col_name        => 'SR_CUSTOMER_PK',
                        p_level_id           => 15,
                        p_instance_code      => p_instance_code,
                        p_instance_id        => p_instance_id,
                        p_message_text       => lv_message_text,
                        p_batch_id           => lv_batch_id,
                        p_error_text         => lv_error_text);

        IF lv_return <> 0 THEN
            RAISE ex_logging_err;
        END IF;

        -- Set the message
        lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_INVALID_VALUE',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'SHIP_TO_LOC');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;
     -- Derive sr_ship_to_loc_pk from msd_st_level_values and msd_level_values

       lv_return :=  MSC_ST_UTIL.DERIVE_SR_PK
                       (p_table_name         => 'MSD_ST_BOOKING_DATA',
                        p_column_name        => 'SHIP_TO_LOC',
                        p_pk_col_name        => 'SR_SHIP_TO_LOC_PK',
                        p_level_id           =>  11,
                        p_instance_code      => p_instance_code,
                        p_instance_id        => p_instance_id,
                        p_message_text       => lv_message_text,
                        p_batch_id           => lv_batch_id,
                        p_severity           => G_SEV_ERROR,	-- Against Bug#2415379
                        p_error_text         => lv_error_text);

        IF lv_return <> 0 THEN
            RAISE ex_logging_err;
        END IF;

   IF (lv_instance_type <> G_INS_OTHER) THEN

       -- Set the message to validate customer-ship to location combination for ERP Data
      lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_COL_REF_NOT_EXIST',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAMES',
                      p_token_value1      => 'SR_INSTANCE_CODE AND'
                                             ||' CUSTOMER AND SHIP_TO_LOC',
                      p_token2            => 'MASTER_TABLE',
                      p_token_value2      => 'MSD_LEVEL_ASSOCIATIONS',
                      p_token3            => 'CHILD_TABLE',
                      p_token_value3      => 'MSD_ST_BOOKING_DATA');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;


      -- Validate customer-ship to location combination for ERP Data
      UPDATE msd_st_booking_data mbd
      SET    process_flag = G_ERROR_FLG,
             error_text   = lv_message_text
      WHERE NOT EXISTS(SELECT 1
                       FROM   msd_st_level_associations msla
                       WHERE  msla.level_id         = 11
                       AND    msla.parent_level_id  = 15
                       AND    mbd.sr_customer_pk    = msla.sr_parent_level_pk
                       AND    mbd.sr_ship_to_loc_pk = msla.sr_level_pk
                       AND    msla.instance      = p_instance_id
                       UNION ALL
                       SELECT 1
                       FROM   msd_level_associations mla
                       WHERE  mla.level_id          = 11
                       AND    mla.parent_level_id   = 15
                       AND    mbd.sr_customer_pk    = mla.sr_parent_level_pk
                       AND    mbd.sr_ship_to_loc_pk = mla.sr_level_pk
                       AND    mla.instance       = p_instance_id)
      AND    mbd.process_flag                    = G_IN_PROCESS
      AND    mbd.sr_instance_code                = p_instance_code
      AND    mbd.batch_id                        = p_batch_id;


   END IF;


        -- Set the message
        lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_INVALID_VALUE',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'SALES_CHANNEL');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

     -- Derive sr_sales_channel_pk from msd_st_level_values and msd_level_values

       lv_return :=  MSC_ST_UTIL.DERIVE_SR_PK
                       (p_table_name         => 'MSD_ST_BOOKING_DATA',
                        p_column_name        => 'SALES_CHANNEL',
                        p_pk_col_name        => 'SR_SALES_CHANNEL_PK',
                        p_level_id           =>  27,
                        p_instance_code      => p_instance_code,
                        p_instance_id        => p_instance_id,
                        p_message_text       => lv_message_text,
                        p_batch_id           => lv_batch_id,
                        p_severity           => G_SEV_ERROR,	-- Against Bug#2415379
                        p_error_text         => lv_error_text);

        IF lv_return <> 0 THEN
            RAISE ex_logging_err;
        END IF;

        -- Set the message
        lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_INVALID_VALUE',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'SALES_REP');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;
     -- Derive sr_sales_rep_pk from msd_st_level_values and msd_level_values

       lv_return :=  MSC_ST_UTIL.DERIVE_SR_PK
                       (p_table_name         => 'MSD_ST_BOOKING_DATA',
                        p_column_name        => 'SALES_REP',
                        p_pk_col_name        => 'SR_SALES_REP_PK',
                        p_level_id           =>  18,
                        p_instance_code      =>  p_instance_code,
                        p_instance_id        =>  p_instance_id,
                        p_message_text       => lv_message_text,
                        p_batch_id           => lv_batch_id,
                        p_severity           => G_SEV_ERROR,	-- Against Bug#2415379
                        p_error_text         => lv_error_text);

        IF lv_return <> 0 THEN
            RAISE ex_logging_err;
        END IF;

-- Demand Class changes for Booking Data starts
      -- Set the message
        lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_INVALID_VALUE',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'DEMAND_CLASS_LVL_VAL');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

     -- Derive sr_sales_channel_pk from msd_st_level_values and msd_level_values

       lv_return :=  MSC_ST_UTIL.DERIVE_SR_PK
                       (p_table_name         => 'MSD_ST_BOOKING_DATA',
                        p_column_name        => 'DEMAND_CLASS_LVL_VAL',
                        p_pk_col_name        => 'SR_DEMAND_CLASS_PK',
                        p_level_id           =>  34,
                        p_instance_code      => p_instance_code,
                        p_instance_id        => p_instance_id,
                        p_message_text       => lv_message_text,
                        p_batch_id           => lv_batch_id,
                        p_severity           => G_SEV3_ERROR,	-- Against Bug#2415379
                        p_error_text         => lv_error_text);

        IF lv_return <> 0 THEN
            RAISE ex_logging_err;
        END IF;

 -- Demand Class changes for Booking Data ends

          -- Set the message
        lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_INVALID_VALUE',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'PARENT_ITEM');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

     -- Derive sr_parent_item_pk from msd_st_level_values and msd_level_values

       lv_return :=  MSC_ST_UTIL.DERIVE_SR_PK
                       (p_table_name         => 'MSD_ST_BOOKING_DATA',
                        p_column_name        => 'PARENT_ITEM',
                        p_pk_col_name        => 'SR_PARENT_ITEM_PK',
                        p_level_id           =>  1,
                        p_instance_code      =>  p_instance_code,
                        p_instance_id        =>  p_instance_id,
                        p_message_text       => lv_message_text,
                        p_batch_id           => lv_batch_id,
                        p_severity           => G_SEV3_ERROR,    -- Against Bug#2415379
                        p_error_text         => lv_error_text);

        IF lv_return <> 0 THEN
            RAISE ex_logging_err;
        END IF;


      -- set the message, USER_DEFINED1 is invalid

        lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_INVALID_VALUE',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'USER_DEFINED1');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

     -- Derive SR_USER_DEFINED1_LVL_PK

       lv_return := MSC_ST_UTIL.DERIVE_LEVEL_PK
                    (p_table_name      => 'MSD_ST_BOOKING_DATA',
                     p_level_val_col   => 'USER_DEFINED1',
                     p_level_name_col  => 'USER_DEFINED_LEVEL1',
                     p_level_pk_col    => 'SR_USER_DEFINED1_PK',
                     p_instance_code   => p_instance_code,
                     p_instance_id     => p_instance_id,
                     p_message_text    => lv_message_text,
                     p_batch_id        => lv_batch_id,
                     p_error_text      => lv_error_text);

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

      -- set the message, USER_DEFINED2 is invalid

        lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_INVALID_VALUE',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'USER_DEFINED2');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

     -- Derive SR_USER_DEFINED2_LVL_PK

       lv_return := MSC_ST_UTIL.DERIVE_LEVEL_PK
                    (p_table_name      => 'MSD_ST_BOOKING_DATA',
                     p_level_val_col   => 'USER_DEFINED2',
                     p_level_name_col  => 'USER_DEFINED_LEVEL2',
                     p_level_pk_col    => 'SR_USER_DEFINED2_PK',
                     p_instance_code   => p_instance_code,
                     p_instance_id     => p_instance_id,
                     p_message_text    => lv_message_text,
                     p_batch_id        => lv_batch_id,
                     p_error_text      => lv_error_text);

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

     -- Set the message
        lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_COL_VAL_NULL',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'BOOKED_DATE');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

       --booked_date cannot be null.
      v_sql_stmt := 07;

    lv_sql_Stmt:=
    'UPDATE     msd_st_booking_data '
    ||' SET     process_flag              ='||G_ERROR_FLG||','
    ||'         error_text   = '||''''||lv_message_text||''''
    ||' WHERE   NVL(booked_date,(sysdate-36500))  = (sysdate-36500)'
    ||' AND     process_flag              ='|| G_IN_PROCESS
    ||' AND     batch_id                  = :lv_batch_id'
    ||' AND     sr_instance_code          = :p_instance_code';

    IF lv_debug THEN
           msc_st_util.log_message(lv_sql_stmt);
    END IF;

   EXECUTE IMMEDIATE lv_sql_stmt
               USING lv_batch_id,
                     p_instance_code ;

      --Call to customised validation.
      MSC_CL_PRE_PROCESS_HOOK.ENTITY_VALIDATION
        (ERRBUF         => lv_error_text,
         RETCODE        => lv_return,
         pBatchID       => null,
         pInstanceCode  => p_instance_code,
         pEntityName    => 'MSD_ST_BOOKING_DATA',
         pInstanceID    => p_instance_id);

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

     -- Set the process flag as Valid and populate instance_id
      lv_return := MSC_ST_UTIL.SET_PROCESS_FLAG
                        (p_table_name     => 'MSD_ST_BOOKING_DATA',
                         p_instance_id    => p_instance_id,
                         p_instance_code  => p_instance_code,
                         p_process_flag   => G_VALID,
                         p_error_text     => lv_error_text,
                         p_batch_id       => lv_batch_id,
                         p_instance_id_col=> 'INSTANCE');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

    -- Inserting all the errored out records into MSC_ERRORS:

      lv_return := MSC_ST_UTIL.LOG_ERROR
                   (p_table_name        => 'MSD_ST_BOOKING_DATA',
                    p_instance_code     => p_instance_code,
                    p_row               => lv_column_names,
                    p_severity          => G_SEV_ERROR,
                    p_error_text        => lv_error_text,
                    p_message_text      => NULL,
                    p_batch_id          => lv_batch_id);

      IF(lv_return <> 0) THEN
        msc_st_util.log_message(lv_error_text);
      END IF;
      COMMIT;

    EXCEPTION
     WHEN ex_logging_err THEN
        ROLLBACK;

        ERRBUF := lv_error_text;
        RETCODE := G_WARNING;
        msc_st_util.log_message(lv_error_text);

    WHEN OTHERS THEN
      ROLLBACK;

      lv_error_text    := substr('MSD_CL_PRE_PROCESS.LOAD_BOOKING_DATA '||'('
                       ||v_sql_stmt||')'|| SQLERRM, 1, 240);
      msc_st_util.log_message(lv_error_text);
      ERRBUF := lv_error_text;
      RETCODE := G_WARNING;

  END LOAD_BOOKING_DATA ;

  /*==========================================================================+
  | DESCRIPTION  : This function performs the validation and loads the data   |
  |                for business object shipment  data                         |
  +==========================================================================*/

  PROCEDURE LOAD_SHIPMENT_DATA(ERRBUF          OUT NOCOPY VARCHAR,
                               RETCODE         OUT NOCOPY NUMBER,
                               p_instance_code IN VARCHAR,
                               p_instance_id   IN NUMBER,
                               p_batch_id      IN NUMBER)
  IS
  TYPE RowidTab IS TABLE OF ROWID INDEX BY BINARY_INTEGER;
  lb_rowid          RowidTab;
/*  lb_rowid1         RowidTab;  Bug3749959 */
  lv_sql_stmt       VARCHAR2(4000);
  lv_batch_id       msd_st_shipment_data.batch_id%TYPE;
  lv_message_text   msc_errors.error_text%TYPE;
  lv_my_company     msc_companies.company_name%TYPE := GET_MY_COMPANY;
  lv_error_text     VARCHAR2(250);
  lv_debug          BOOLEAN   := msc_cl_pre_process.v_debug;
  lv_batch_size     NUMBER    := msc_cl_pre_process.v_batch_size;
  lv_current_user   NUMBER    := msc_cl_pre_process.v_current_user;
  lv_current_date   DATE      := msc_cl_pre_process.v_current_date;
  lv_return         NUMBER := 0;
  ex_logging_err    EXCEPTION;
  lv_column_names   VARCHAR2(5000);
/*
  lv_other_desc   varchar2(240) := NULL;   --Adding this to insert level value - 'Others'
  lv_all_dcs_desc varchar2(240) := NULL;   --Adding this to insert level value - 'All Demand Classes'
Bug3749959 */
  lv_instance_type  msc_apps_instances.instance_type%TYPE;

/*  lv_other_exist NUMBER :=0;
  lv_all_dcs_pk NUMBER :=0;    --Renamed 'lv_sr_level_pk' to 'lv_all_dcs_pk'.
Bug3749959 */

  CURSOR instance_type IS
   SELECT instance_type
   FROM msc_apps_instances
   WHERE instance_id=p_instance_id;

  CURSOR c1(p_batch_id NUMBER)IS
    SELECT rowid
    FROM   msd_st_shipment_data
    WHERE  process_flag      IN (G_IN_PROCESS,G_ERROR_FLG)
    AND    sr_instance_code = p_instance_code
    AND    batch_id         = p_batch_id;
/*
  CURSOR c2(p_batch_id NUMBER)IS
    SELECT rowid
    FROM   msd_st_shipment_data
    WHERE  process_flag      IN (G_IN_PROCESS,G_ERROR_FLG)
    AND    nvl(DEMAND_CLASS_LVL_VAL,'-1') = '-1'
    AND    sr_instance_code = p_instance_code
    AND    batch_id         = p_batch_id;

   cursor c3 (p_instance varchar2) is
    select count(*) from MSD_LEVEL_VALUES
    where LEVEL_ID = 34
    and   instance = p_instance
    and   SR_LEVEL_PK = to_char(v_null_pk);  --Using global variable v_null_pk insteda of hardcoding -777 at multiple places.

   cursor c4 (p_instance_code varchar2) is
    select local_id from msd_local_id_setup
    where char1    = p_instance_code
    -- and   char2    = 'All Demand Classes'
    and   level_id = 40;
Bug3749959 */

   BEGIN

      lv_batch_id := p_batch_id;

      lv_column_names :=

		'       SR_INSTANCE_CODE	||''~''||'
		||'	INV_ORG			||''~''||'
		||'	ITEM			||''~''||'
		||'	CUSTOMER		||''~''||'
		||'	SALES_CHANNEL		||''~''||'
		||'	SALES_REP		||''~''||'
		||'	SHIP_TO_LOC		||''~''||'
		||'	PARENT_ITEM		||''~''||'
		||'	USER_DEFINED_LEVEL1	||''~''||'
		||'	USER_DEFINED1		||''~''||'
		||'	USER_DEFINED_LEVEL2	||''~''||'
		||'	USER_DEFINED2		||''~''||'
		||'	BOOKED_DATE		||''~''||'
		||'	REQUESTED_DATE		||''~''||'
		||'	PROMISED_DATE		||''~''||'
		||'	SHIPPED_DATE		||''~''||'
		||'	AMOUNT			||''~''||'
		||'	QTY_SHIPPED		||''~''||'
		||'	ORIGINAL_ITEM';

      OPEN  c1(lv_batch_id);
      FETCH c1 BULK COLLECT INTO lb_rowid;
      CLOSE c1;

      v_sql_stmt := 04;
      FORALL j IN lb_rowid.FIRST..lb_rowid.LAST
      UPDATE msd_st_shipment_data
      SET  st_transaction_id = msd_st_shipment_data_s.NEXTVAL,
           last_update_date  = lv_current_date,
           last_updated_by   = lv_current_user,
           creation_date     = lv_current_date,
           created_by        = lv_current_user
      WHERE  rowid           = lb_rowid(j);
/*
      OPEN  c2(lv_batch_id);
       FETCH c2 BULK COLLECT INTO lb_rowid1;
      CLOSE c2;

   IF ( lb_rowid1.COUNT <> 0 ) THEN

      lv_other_desc    := msd_sr_util.get_null_desc;    --Calling fuction - msd_sr_util.get_null_desc, to fetch the level value 'Others'
      lv_all_dcs_desc  := msd_sr_util.get_all_dcs_desc; --Calling fuction - msd_sr_util.get_all_dcs_desc, to fetch the level value 'All Demand Classes'

      v_sql_stmt := 05;
      FORALL j IN lb_rowid1.FIRST..lb_rowid1.LAST
      UPDATE msd_st_shipment_data
      SET  DEMAND_CLASS_LVL_VAL  = lv_other_desc  --Using the value fetched from function - msd_sr_util.get_null_desc
      WHERE  rowid               = lb_rowid1(j);



      OPEN c3(p_instance_id);
       FETCH c3 into lv_other_exist;
      CLOSE c3;

      IF  lv_other_exist = 0 THEN
        INSERT INTO MSD_ST_LEVEL_VALUES
        (INSTANCE   ,
        LEVEL_ID,
        LEVEL_VALUE,
        SR_LEVEL_PK,
        ATTRIBUTE1,
        ATTRIBUTE2,
        ATTRIBUTE3,
        ATTRIBUTE4,
        ATTRIBUTE5,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN,
        REQUEST_ID,
        PROGRAM_APPLICATION_ID,
        PROGRAM_ID,
        PROGRAM_UPDATE_DATE )
        VALUES
        (p_instance_id,
        34,
        lv_other_desc,   --Using the value fetched from function - msd_sr_util.get_null_desc
        to_char(v_null_pk), --Using global variable v_null_pk insteda of hardcoding -777 at multiple places.
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        sysdate,
        -1,
        sysdate,
        -1,
        -1,
        -1,
        -1,
        -1,
        sysdate);

      END IF;

    OPEN c4(p_instance_code);
     FETCH c4 into lv_all_dcs_pk;  --Renamed 'lv_sr_level_pk' to 'lv_all_dcs_pk'.
    CLOSE c4;

     IF lv_all_dcs_pk = 0  THEN  --Renamed 'lv_sr_level_pk' to 'lv_all_dcs_pk'.

        lv_all_dcs_pk := msd_sr_util.get_all_dcs_pk; -- Fetching the SR_LEVEL_PK for 'ALL Demand Classes' level value from function - msd_sr_util.get_all_dcs_pk

        INSERT INTO  msd_local_id_setup   --  insert into msd_local_id_setup
          (local_id,
           instance_id,
           level_id,
           char1,
           char2,
           last_update_date,
           last_updated_by,
           creation_date,
           created_by  )
           VALUES
           (lv_all_dcs_pk,  --Renamed 'lv_sr_level_pk' to 'lv_all_dcs_pk'.
            p_instance_id,
            40,
            p_instance_code,
            lv_all_dcs_desc,   --Using the value fetched from function - msd_sr_util.get_all_dcs_desc
            sysdate,
            -1,
            sysdate,
            -1);

    -- lv_sr_level_pk := -6;     -- Inserting 'All Demand Classes' records with sr_level_pk as -6


     INSERT INTO MSD_ST_LEVEL_VALUES   --Inserting into MSD_ST_LEVEL_VALUES
       (INSTANCE   ,
        LEVEL_ID,
        LEVEL_VALUE,
        SR_LEVEL_PK,
        ATTRIBUTE1,
        ATTRIBUTE2,
        ATTRIBUTE3,
        ATTRIBUTE4,
        ATTRIBUTE5,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN,
        REQUEST_ID,
        PROGRAM_APPLICATION_ID,
        PROGRAM_ID,
        PROGRAM_UPDATE_DATE )
        VALUES
        (p_instance_id,
        40,
        lv_all_dcs_desc,   --Using the value fetched from function - msd_sr_util.get_all_dcs_desc
        lv_all_dcs_pk,     --Renamed 'lv_sr_level_pk' to 'lv_all_dcs_pk'.
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        sysdate,
        -1,
        sysdate,
        -1,
        -1,
        -1,
        -1,
        -1,
        sysdate);


          --   Insert into msd_st_level_associations.

      INSERT INTO MSD_ST_LEVEL_ASSOCIATIONS
        (INSTANCE   ,
        LEVEL_ID,
        SR_LEVEL_PK,
        PARENT_LEVEL_ID,
        SR_PARENT_LEVEL_PK,
        ATTRIBUTE1,
        ATTRIBUTE2,
        ATTRIBUTE3,
        ATTRIBUTE4,
        ATTRIBUTE5,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN,
        REQUEST_ID,
        PROGRAM_APPLICATION_ID,
        PROGRAM_ID,
        PROGRAM_UPDATE_DATE )
        VALUES
        (p_instance_id,
        34,
        to_char(v_null_pk),  --Using global variable v_null_pk insteda of hardcoding -777 at multiple places.
        40,
        lv_all_dcs_pk,   --Renamed 'lv_sr_level_pk' to 'lv_all_dcs_pk'.
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        sysdate,
        -1,
        sysdate,
        -1,
        -1,
        -1,
        -1,
        -1,
        sysdate);

     END IF;

  END IF;
Bug3749959 */

      OPEN instance_type;
        FETCH instance_type into lv_instance_type;
      CLOSE instance_type;

    IF (lv_instance_type = G_INS_OTHER) THEN

      -- Set the message to validate customer-ship to location combination
      lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_COL_REF_NOT_EXIST',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAMES',
                      p_token_value1      => 'SR_INSTANCE_CODE AND'
                                             ||' CUSTOMER AND SHIP_TO_LOC',
                      p_token2            => 'MASTER_TABLE',
                      p_token_value2      => 'MSC_TRADING_PARTNER_SITES',
                      p_token3            => 'CHILD_TABLE',
                      p_token_value3      => 'MSD_ST_SHIPMENT_DATA');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

      -- Validate customer-ship to location combination
      v_sql_stmt := 15;
      UPDATE msd_st_shipment_data msd
      SET    process_flag = G_ERROR_FLG,
             error_text   = lv_message_text
      WHERE NOT EXISTS(SELECT 1
                       FROM   msc_local_id_setup mls
                       WHERE  mls.char1                   =  msd.sr_instance_code
                       AND    nvl(mls.char2,lv_my_company) = lv_my_company
                       AND    mls.char3                   = msd.customer
                       AND    mls.char4                   = msd.ship_to_loc
                       AND    mls.number1                 = 2                --customer
                       AND    mls.entity_name             = 'SR_TP_SITE_ID')
      AND    msd.process_flag               = G_IN_PROCESS
      AND    msd.sr_instance_code           = p_instance_code
      AND    msd.batch_id                   = p_batch_id;

   END IF;


        -- Set the message
        lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_INVALID_VALUE',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'ITEM');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

     -- Derive sr_item_pk from msd_st_level_values and msd_level_values

       lv_return :=  MSC_ST_UTIL.DERIVE_SR_PK
                       (p_table_name         => 'MSD_ST_SHIPMENT_DATA',
                        p_column_name        => 'ITEM',
                        p_pk_col_name        => 'SR_ITEM_PK',
                        p_level_id           => 1,
                        p_instance_code      => p_instance_code,
                        p_instance_id        => p_instance_id,
                        p_message_text       => lv_message_text,
                        p_batch_id           => lv_batch_id,
                        p_severity           => G_SEV_ERROR,	-- Against Bug#2415379
                        p_error_text         => lv_error_text);

        IF lv_return <> 0 THEN
            RAISE ex_logging_err;
        END IF;

      -- Code generated against the bug number : 2357511

      v_sql_stmt := 07;

      lv_sql_Stmt:=
      'UPDATE     MSD_ST_SHIPMENT_DATA '
      ||' SET     ORIGINAL_ITEM      =ITEM '
      ||' WHERE   ORIGINAL_ITEM IS NULL '
      ||' AND     process_flag              ='|| G_IN_PROCESS
      ||' AND     batch_id                  = :lv_batch_id'
      ||' AND     sr_instance_code          = :p_instance_code';

      IF lv_debug THEN
          msc_st_util.log_message(lv_sql_stmt);
      END IF;

     EXECUTE IMMEDIATE lv_sql_stmt
               USING lv_batch_id,
                     p_instance_code ;


        -- Set the message
        lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_INVALID_VALUE',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'ORIGINAL_ITEM');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

     -- Derive sr_original_item_pk from msd_st_level_values and msd_level_values

       lv_return :=  MSC_ST_UTIL.DERIVE_SR_PK
                       (p_table_name         => 'MSD_ST_SHIPMENT_DATA',
                        p_column_name        => 'ORIGINAL_ITEM',
                        p_pk_col_name        => 'SR_ORIGINAL_ITEM_PK',
                        p_level_id           => 1,
                        p_instance_code      => p_instance_code,
                        p_instance_id        => p_instance_id,
                        p_message_text       => lv_message_text,
                        p_batch_id           => lv_batch_id,
                        p_severity           => G_SEV_ERROR,	-- Against Bug#2415379
                        p_error_text         => lv_error_text);

        IF lv_return <> 0 THEN
            RAISE ex_logging_err;
        END IF;

         -- Set the message
        lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_INVALID_VALUE',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'INV_ORG');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

     -- Derive sr_inv_org_pk from msd_st_level_values and msd_level_values

       lv_return :=  MSC_ST_UTIL.DERIVE_SR_PK
                       (p_table_name         => 'MSD_ST_SHIPMENT_DATA',
                        p_column_name        => 'INV_ORG',
                        p_pk_col_name        => 'SR_INV_ORG_PK',
                        p_level_id           => 7,
                        p_instance_code      => p_instance_code,
                        p_instance_id        =>  p_instance_id,
                        p_message_text       => lv_message_text,
                        p_batch_id           => lv_batch_id,
                        p_severity           => G_SEV_ERROR,	-- Against Bug#2415379
                        p_error_text         => lv_error_text);

        IF lv_return <> 0 THEN
            RAISE ex_logging_err;
        END IF;

  IF (lv_instance_type = G_INS_OTHER) THEN

      lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_COL_REF_NOT_EXIST',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAMES',
                      p_token_value1      => 'SR_INSTANCE_CODE AND'
                                             ||' INV_ORG AND ITEM AND ITEM.ATO_FORECAST_CONTROL'
                                             ||' AND ITEM.MRP_PLANNING_CODE',
                      p_token2            => 'MASTER_TABLE',
                      p_token_value2      => 'MSC_SYSTEM_ITEMS',
                      p_token3            => 'CHILD_TABLE',
                      p_token_value3      => 'MSD_ST_SHIPMENT_DATA');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

      -- Validate item-org combination
      v_sql_stmt := 15;

      UPDATE msd_st_shipment_data msd
      SET    process_flag = G_ERROR_FLG,
             error_text   = lv_message_text
      WHERE NOT EXISTS(SELECT 1
                       FROM   msc_st_system_items msi
                       WHERE  msi.sr_instance_id                  = p_instance_id
                       AND    nvl(msi.company_name,lv_my_company) = lv_my_company
                       AND    msi.organization_id                 = msd.sr_inv_org_pk
                       AND    msi.item_name                       = msd.item
                       AND   ((v_plan_per_profile = 4) OR (msi.ato_forecast_control <> 3))        --forecast control - none
                       AND   ((msi.mrp_planning_code                <> 6 ) OR (msi.pick_components_flag='Y' ))                         --Not planned item
                       UNION
                       SELECT 1
                       FROM   msc_system_items mls
                       WHERE  mls.sr_instance_id                  = p_instance_id
                       AND    mls.organization_id                 = msd.sr_inv_org_pk
                       AND    mls.item_name                       = msd.item
                       AND    mls.plan_id                         = -1
                       AND   ((v_plan_per_profile = 4) OR (mls.ato_forecast_control <> 3))        --forecast control - none
                       AND   ((mls.mrp_planning_code                <> 6 ) OR (mls.pick_components_flag='Y' )) )                        --Not planned item
      AND    msd.process_flag            = G_IN_PROCESS
      AND    msd.sr_instance_code        = p_instance_code
      AND    msd.batch_id                = p_batch_id;

   END IF;

        -- Set the message
        lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_INVALID_VALUE',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'CUSTOMER');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

     -- Derive sr_customer_pk from msd_st_level_values and msd_level_values

       lv_return :=  MSC_ST_UTIL.DERIVE_SR_PK
                       (p_table_name         => 'MSD_ST_SHIPMENT_DATA',
                        p_column_name        => 'CUSTOMER',
                        p_pk_col_name        => 'SR_CUSTOMER_PK',
                        p_level_id           =>  15,
                        p_instance_code      => p_instance_code,
                        p_instance_id        => p_instance_id,
                        p_message_text       => lv_message_text,
                        p_batch_id           => lv_batch_id,
                        p_error_text         => lv_error_text);

        IF lv_return <> 0 THEN
            RAISE ex_logging_err;
        END IF;

        -- Set the message
        lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_INVALID_VALUE',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'SHIP_TO_LOC');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

     -- Derive sr_ship_to_loc_pk from msd_st_level_values and msd_level_values

       lv_return :=  MSC_ST_UTIL.DERIVE_SR_PK
                       (p_table_name         => 'MSD_ST_SHIPMENT_DATA',
                        p_column_name        => 'SHIP_TO_LOC',
                        p_pk_col_name        => 'SR_SHIP_TO_LOC_PK',
                        p_level_id           =>  11,
                        p_instance_code      => p_instance_code,
                        p_instance_id        => p_instance_id,
                        p_message_text       => lv_message_text,
                        p_batch_id           => lv_batch_id,
                        p_severity           => G_SEV_ERROR,	-- Against Bug#2415379
                        p_error_text         => lv_error_text);

        IF lv_return <> 0 THEN
            RAISE ex_logging_err;
        END IF;

    IF (lv_instance_type <> G_INS_OTHER) THEN

       -- Set the message to validate customer-ship to location combination for ERP data
      lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_COL_REF_NOT_EXIST',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAMES',
                      p_token_value1      => 'SR_INSTANCE_CODE AND'
                                             ||' CUSTOMER AND SHIP_TO_LOC',
                      p_token2            => 'MASTER_TABLE',
                      p_token_value2      => 'MSD_LEVEL_ASSOCIATIONS',
                      p_token3            => 'CHILD_TABLE',
                      p_token_value3      => 'MSD_ST_SHIPMENT_DATA');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

     -- Validate customer-ship to location combination for ERP data
      UPDATE msd_st_shipment_data msd
      SET    process_flag = G_ERROR_FLG,
             error_text   = lv_message_text
      WHERE NOT EXISTS(SELECT 1
                       FROM   msd_st_level_associations msla
                       WHERE  msla.level_id         = 11
                       AND    msla.parent_level_id  = 15
                       AND    msd.sr_customer_pk    = msla.sr_parent_level_pk
                       AND    msd.sr_ship_to_loc_pk = msla.sr_level_pk
                       AND    msla.instance         = p_instance_id
                       UNION ALL
                       SELECT 1
                       FROM   msd_level_associations mla
                       WHERE  mla.level_id          = 11
                       AND    mla.parent_level_id   = 15
                       AND    msd.sr_customer_pk    = mla.sr_parent_level_pk
                       AND    msd.sr_ship_to_loc_pk = mla.sr_level_pk
                       AND    mla.instance          = p_instance_id)
      AND    msd.process_flag                    = G_IN_PROCESS
      AND    msd.sr_instance_code                = p_instance_code
      AND    msd.batch_id                        = p_batch_id;

   END IF;

        -- Set the message
        lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_INVALID_VALUE',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'SALES_CHANNEL');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

     -- Derive sr_sales_channel_pk from msd_st_level_values and msd_level_values

       lv_return :=  MSC_ST_UTIL.DERIVE_SR_PK
                       (p_table_name         => 'MSD_ST_SHIPMENT_DATA',
                        p_column_name        => 'SALES_CHANNEL',
                        p_pk_col_name        => 'SR_SALES_CHANNEL_PK',
                        p_level_id           =>  27,
                        p_instance_code      => p_instance_code,
                        p_instance_id        =>  p_instance_id,
                        p_message_text       => lv_message_text,
                        p_batch_id           => lv_batch_id,
                        p_severity           => G_SEV_ERROR,	-- Against Bug#2415379
                        p_error_text         => lv_error_text);

        IF lv_return <> 0 THEN
            RAISE ex_logging_err;
        END IF;

        -- Set the message
        lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_INVALID_VALUE',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'SALES_REP');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;
     -- Derive sr_sales_rep_pk from msd_st_level_values and msd_level_values

       lv_return :=  MSC_ST_UTIL.DERIVE_SR_PK
                       (p_table_name         => 'MSD_ST_SHIPMENT_DATA',
                        p_column_name        => 'SALES_REP',
                        p_pk_col_name        => 'SR_SALES_REP_PK',
                        p_level_id           =>  18,
                        p_instance_code      => p_instance_code,
                        p_instance_id        =>  p_instance_id,
                        p_message_text       => lv_message_text,
                        p_batch_id           => lv_batch_id,
                        p_severity           => G_SEV_ERROR,	-- Against Bug#2415379
                        p_error_text         => lv_error_text);

        IF lv_return <> 0 THEN
            RAISE ex_logging_err;
        END IF;

  -- Demand Class changes for Shipment Data starts
   -- Set the message
        lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_INVALID_VALUE',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'DEMAND_CLASS_LVL_VAL');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;
     -- Derive sr_sales_rep_pk from msd_st_level_values and msd_level_values

       lv_return :=  MSC_ST_UTIL.DERIVE_SR_PK
                       (p_table_name         => 'MSD_ST_SHIPMENT_DATA',
                        p_column_name        => 'DEMAND_CLASS_LVL_VAL',
                        p_pk_col_name        => 'SR_DEMAND_CLASS_PK',
                        p_level_id           =>  34,
                        p_instance_code      => p_instance_code,
                        p_instance_id        =>  p_instance_id,
                        p_message_text       => lv_message_text,
                        p_batch_id           => lv_batch_id,
                        p_severity           => G_SEV3_ERROR,	-- Against Bug#2415379
                        p_error_text         => lv_error_text);

        IF lv_return <> 0 THEN
            RAISE ex_logging_err;
        END IF;

  -- Demand Class changes for Shipment Data ends
                   -- Set the message
        lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_INVALID_VALUE',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'PARENT_ITEM');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;
     -- Derive sr_sales_rep_pk from msd_st_level_values and msd_level_values

       lv_return :=  MSC_ST_UTIL.DERIVE_SR_PK
                       (p_table_name         => 'MSD_ST_SHIPMENT_DATA',
                        p_column_name        => 'PARENT_ITEM',
                        p_pk_col_name        => 'SR_PARENT_ITEM_PK',
                        p_level_id           =>  1,
                        p_instance_code      => p_instance_code,
                        p_instance_id        =>  p_instance_id,
                        p_message_text       => lv_message_text,
                        p_batch_id           => lv_batch_id,
                        p_severity           => G_SEV3_ERROR,    -- Against Bug#2415379
                        p_error_text         => lv_error_text);

        IF lv_return <> 0 THEN
            RAISE ex_logging_err;
        END IF;




      -- set the message, USER_DEFINED1 is invalid

        lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_INVALID_VALUE',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'USER_DEFINED1');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

     -- Derive SR_USER_DEFINED1_LVL_PK

       lv_return := MSC_ST_UTIL.DERIVE_LEVEL_PK
                    (p_table_name      => 'MSD_ST_SHIPMENT_DATA',
                     p_level_val_col   => 'USER_DEFINED1',
                     p_level_name_col  => 'USER_DEFINED_LEVEL1',
                     p_level_pk_col    => 'SR_USER_DEFINED1_PK',
                     p_instance_code   => p_instance_code,
                     p_instance_id     => p_instance_id,
                     p_message_text    => lv_message_text,
                     p_batch_id        => lv_batch_id,
                     p_error_text      => lv_error_text);

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

      -- set the message, USER_DEFINED2 is invalid

        lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_INVALID_VALUE',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'USER_DEFINED2');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

     -- Derive SR_USER_DEFINED2_LVL_PK

       lv_return := MSC_ST_UTIL.DERIVE_LEVEL_PK
                    (p_table_name      => 'MSD_ST_SHIPMENT_DATA',
                     p_level_val_col   => 'USER_DEFINED2',
                     p_level_name_col  => 'USER_DEFINED_LEVEL2',
                     p_level_pk_col    => 'SR_USER_DEFINED2_PK',
                     p_instance_code   => p_instance_code,
                     p_instance_id     => p_instance_id,
                     p_message_text    => lv_message_text,
                     p_batch_id        => lv_batch_id,
                     p_error_text      => lv_error_text);

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;
     -- Set the message
        lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_COL_VAL_NULL',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'SHIPPED_DATE');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

     --shipped_date cannot be null.
      v_sql_stmt := 07;

    lv_sql_Stmt:=
    'UPDATE     msd_st_shipment_data '
    ||' SET     process_flag              ='||G_ERROR_FLG||','
    ||'         error_text   = '||''''||lv_message_text||''''
    ||' WHERE   NVL(shipped_date,(sysdate-36500))  = (sysdate-36500)'
    ||' AND     process_flag              ='|| G_IN_PROCESS
    ||' AND     batch_id                  = :lv_batch_id'
    ||' AND     sr_instance_code          = :p_instance_code';

    IF lv_debug THEN
           msc_st_util.log_message(lv_sql_stmt);
    END IF;

   EXECUTE IMMEDIATE lv_sql_stmt
               USING lv_batch_id,
                     p_instance_code ;


      --Call to customised validation.
      MSC_CL_PRE_PROCESS_HOOK.ENTITY_VALIDATION
        (ERRBUF         => lv_error_text,
         RETCODE        => lv_return,
         pBatchID       => lv_batch_id,
         pInstanceCode  => p_instance_code,
         pEntityName    => 'MSD_ST_SHIPMENT_DATA',
         pInstanceID    => p_instance_id);

      IF NVL(lv_return,0) <> 0 THEN
        RAISE ex_logging_err;
      END IF;

     -- Set the process flag as Valid and populate instance_id
      lv_return := MSC_ST_UTIL.SET_PROCESS_FLAG
                        (p_table_name     => 'MSD_ST_SHIPMENT_DATA',
                         p_instance_id    => p_instance_id,
                         p_instance_code  => p_instance_code,
                         p_process_flag   => G_VALID,
                         p_error_text     => lv_error_text,
                         p_batch_id       => lv_batch_id,
                         p_instance_id_col=> 'INSTANCE');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

    -- Inserting all the errored out records into MSC_ERRORS:

      lv_return := MSC_ST_UTIL.LOG_ERROR
                   (p_table_name        => 'MSD_ST_SHIPMENT_DATA',
                    p_instance_code     => p_instance_code,
                    p_row               => lv_column_names,
                    p_severity          => G_SEV_ERROR,
                    p_error_text        => lv_error_text,
                    p_message_text      => NULL,
                    p_batch_id          => lv_batch_id);

      IF(lv_return <> 0) THEN
        msc_st_util.log_message(lv_error_text);
      END IF;
      COMMIT;

    EXCEPTION
      WHEN ex_logging_err THEN
          ROLLBACK;

        ERRBUF := lv_error_text;
        RETCODE := G_WARNING;
        msc_st_util.log_message(lv_error_text);

      WHEN OTHERS THEN
        ROLLBACK;

      lv_error_text    := substr('MSD_CL_PRE_PROCESS.LOAD_SHIPMENT_DATA '||'('
                       ||v_sql_stmt||')'|| SQLERRM, 1, 240);
      msc_st_util.log_message(lv_error_text);
      ERRBUF := lv_error_text;
      RETCODE := G_WARNING;

  END LOAD_SHIPMENT_DATA ;

  /*==========================================================================+
  | DESCRIPTION  : This function performs the validation and loads the data   |
  |                for business object mfg forecast                           |
  +==========================================================================*/
  PROCEDURE LOAD_MFG_FORECAST(ERRBUF          OUT NOCOPY VARCHAR,
                              RETCODE         OUT NOCOPY NUMBER,
                              p_instance_code IN VARCHAR,
                              p_instance_id   IN NUMBER,
                              p_batch_id      IN NUMBER)

  IS
  TYPE RowidTab IS TABLE OF ROWID INDEX BY BINARY_INTEGER;
  lb_rowid          RowidTab;
/*  lb_rowid1         RowidTab;          Bug3749959 */
  lv_sql_stmt       VARCHAR2(4000);
  lv_batch_id       msd_st_mfg_forecast.batch_id%TYPE;
  lv_my_company     msc_companies.company_name%TYPE := GET_MY_COMPANY;
  lv_message_text   msc_errors.error_text%TYPE;
  lv_error_text     VARCHAR2(250);
  lv_debug          BOOLEAN   := msc_cl_pre_process.v_debug;
  lv_batch_size     NUMBER    := msc_cl_pre_process.v_batch_size;
  lv_current_user   NUMBER    := msc_cl_pre_process.v_current_user;
  lv_current_date   DATE      := msc_cl_pre_process.v_current_date;
  lv_return         NUMBER := 0;
  ex_logging_err    EXCEPTION;
  lv_column_names   VARCHAR2(5000);

  CURSOR c1(p_batch_id NUMBER)IS
    SELECT rowid
    FROM   msd_st_mfg_forecast
    WHERE  process_flag      IN (G_IN_PROCESS,G_ERROR_FLG)
    AND    sr_instance_code = p_instance_code
    AND    batch_id         = p_batch_id;

  CURSOR instance_type IS
   SELECT instance_type
   FROM msc_apps_instances
   WHERE instance_id=p_instance_id;
/*
   lv_other_desc   varchar2(240) := NULL;   --Adding this to insert level value - 'Others' -Bug 3749959
   lv_all_dcs_desc varchar2(240) := NULL;   --Adding this to insert level value - 'All Demand Classes' -Bug 3749959
Bug3749959 */

   lv_instance_type  msc_apps_instances.instance_type%TYPE;

/*   lv_other_exist NUMBER :=0;  --Bug 3749959
     lv_all_dcs_pk NUMBER :=0;   --Bug 3749959

   CURSOR c2(p_batch_id NUMBER)IS --This cursor is used to fetch all records which doesn't have any level value for demand class dimension. --Bug 3749959
    SELECT rowid
    FROM   msd_st_mfg_forecast
    WHERE  process_flag      IN (G_IN_PROCESS,G_ERROR_FLG)
    AND    nvl(DEMAND_CLASS_LVL_VAL,'-1') = '-1'
    AND    sr_instance_code = p_instance_code
    AND    batch_id         = p_batch_id;

   cursor c3 (p_instance varchar2) is  -- This cursor is added to find whether the level value 'Others' exist at 'Demand Class' Level. --Bug 3749959
    select count(*) from MSD_LEVEL_VALUES
    where LEVEL_ID = 34
    and   instance = p_instance
    and   SR_LEVEL_PK = to_char(v_null_pk);

   cursor c4 (p_instance_code varchar2) is  -- This cursor is added to find whether the level value 'All Demand Classes' exist alreday or not. --Bug 3749959
    select local_id from msd_local_id_setup
    where char1    = p_instance_code
    -- and   char2    = 'All Demand Classes'
    and   level_id = 40;
Bug3749959 */

   BEGIN

      lv_batch_id := p_batch_id;
      lv_column_names :=
	'	SR_INSTANCE_CODE	||''~''||'
	||'	FORECAST_SET		||''~''||'
	||'	FORECAST_DESIGNATOR	||''~''||'
	||'	CUSTOMER		||''~''||'
	||'	ITEM			||''~''||'
	||'	INV_ORG			||''~''||'
	||'	SALES_CHANNEL		||''~''||'
	||'	SHIP_TO_LOC		||''~''||'
	||'	USER_DEFINED_LEVEL1	||''~''||'
	||'	USER_DEFINED1		||''~''||'
	||'	USER_DEFINED_LEVEL2	||''~''||'
	||'	USER_DEFINED2		||''~''||'
	||'	BUCKET_TYPE		||''~''||'
	||'	FORECAST_DATE		||''~''||'
	||'	RATE_END_DATE		||''~''||'
	||'	ORIGINAL_QUANTITY	||''~''||'
	||'	CURRENT_QUANTITY ';

      OPEN  c1(lv_batch_id);
      FETCH c1 BULK COLLECT INTO lb_rowid;
      CLOSE c1;

      v_sql_stmt := 04;
      FORALL j IN lb_rowid.FIRST..lb_rowid.LAST
      UPDATE msd_st_mfg_forecast
      SET  st_transaction_id = msd_st_mfg_forecast_s.NEXTVAL,
           last_update_date  = lv_current_date,
           last_updated_by   = lv_current_user,
           creation_date     = lv_current_date,
           created_by        = lv_current_user
      WHERE  rowid           = lb_rowid(j);

  -- Changes for Bug 3749959, STARTS.
/*
      OPEN  c2(lv_batch_id);
       FETCH c2 BULK COLLECT INTO lb_rowid1;
      CLOSE c2;

   IF ( lb_rowid1.COUNT <> 0 ) THEN  -- If records exist for which, demand class level values is not provided.

      lv_other_desc    := msd_sr_util.get_null_desc;      --Calling fuction - msd_sr_util.get_null_desc, to fetch the level value 'Others'
      lv_all_dcs_desc  := msd_sr_util.get_all_dcs_desc;   --Calling fuction - msd_sr_util.get_all_dcs_desc, to fetch the level value 'All Demand Classes'

      v_sql_stmt := 05;
      FORALL j IN lb_rowid1.FIRST..lb_rowid1.LAST     -- Update the demand class level value column with 'Other' as Demand Class Level Value.
      UPDATE msd_st_mfg_forecast
      SET  DEMAND_CLASS_LVL_VAL  = lv_other_desc   --Using the value fetched from function - msd_sr_util.get_null_desc
      WHERE  rowid               = lb_rowid1(j);


      OPEN c3(p_instance_id);
       FETCH c3 into lv_other_exist;
      CLOSE c3;

      IF  lv_other_exist = 0 THEN

        INSERT INTO MSD_ST_LEVEL_VALUES --Inserting the level value 'Others' at 'Demand Class' level in MSD_ST_LEVEL_VALUES.
        (INSTANCE   ,
        LEVEL_ID,
        LEVEL_VALUE,
        SR_LEVEL_PK,
        ATTRIBUTE1,
        ATTRIBUTE2,
        ATTRIBUTE3,
        ATTRIBUTE4,
        ATTRIBUTE5,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN,
        REQUEST_ID,
        PROGRAM_APPLICATION_ID,
        PROGRAM_ID,
        PROGRAM_UPDATE_DATE )
        VALUES
        (p_instance_id,
        34,
        lv_other_desc,  --Using the value fetched from function - msd_sr_util.get_null_desc
        to_char(v_null_pk),
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        sysdate,
        -1,
        sysdate,
        -1,
        -1,
        -1,
        -1,
        -1,
        sysdate);

      END IF;

    OPEN c4(p_instance_code);
     FETCH c4 into lv_all_dcs_pk;
    CLOSE c4;

     IF lv_all_dcs_pk = 0  THEN

        lv_all_dcs_pk := msd_sr_util.get_all_dcs_pk; -- Fetching the SR_LEVEL_PK for 'ALL Demand Classes' level value from function - msd_sr_util.get_all_dcs_pk

        INSERT INTO  msd_local_id_setup   --Inserting the level value 'All Demand Classes' in MSD_LOCAL_ID_SETUP.
          (local_id,
           instance_id,
           level_id,
           char1,
           char2,
           last_update_date,
           last_updated_by,
           creation_date,
           created_by  )
           VALUES
           (lv_all_dcs_pk,
            p_instance_id,
            40,
            p_instance_code,
            lv_all_dcs_desc,    --Using the value fetched from function - msd_sr_util.get_all_dcs_desc
            sysdate,
            -1,
            sysdate,
            -1);

   --  lv_sr_level_pk := -6;     -- Inserting 'All Demand Classes' records with sr_level_pk as -6


     INSERT INTO MSD_ST_LEVEL_VALUES   --Inserting the level value 'All Demand Classes' in MSD_ST_LEVEL_VALUES.
       (INSTANCE   ,
        LEVEL_ID,
        LEVEL_VALUE,
        SR_LEVEL_PK,
        ATTRIBUTE1,
        ATTRIBUTE2,
        ATTRIBUTE3,
        ATTRIBUTE4,
        ATTRIBUTE5,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN,
        REQUEST_ID,
        PROGRAM_APPLICATION_ID,
        PROGRAM_ID,
        PROGRAM_UPDATE_DATE )
        VALUES
        (p_instance_id,
        40,
        lv_all_dcs_desc,   --Using the value fetched from function - msd_sr_util.get_all_dcs_desc
        lv_all_dcs_pk,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        sysdate,
        -1,
        sysdate,
        -1,
        -1,
        -1,
        -1,
        -1,
        sysdate);


          --Inserting the level value 'Others' rolling to 'All Demand Classes' in MSD_ST_LEVEL_ASSOCIATIONS

      INSERT INTO MSD_ST_LEVEL_ASSOCIATIONS
        (INSTANCE   ,
        LEVEL_ID,
        SR_LEVEL_PK,
        PARENT_LEVEL_ID,
        SR_PARENT_LEVEL_PK,
        ATTRIBUTE1,
        ATTRIBUTE2,
        ATTRIBUTE3,
        ATTRIBUTE4,
        ATTRIBUTE5,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN,
        REQUEST_ID,
        PROGRAM_APPLICATION_ID,
        PROGRAM_ID,
        PROGRAM_UPDATE_DATE )
        VALUES
        (p_instance_id,
        34,
        to_char(v_null_pk),
        40,
        lv_all_dcs_pk,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        sysdate,
        -1,
        sysdate,
        -1,
        -1,
        -1,
        -1,
        -1,
        sysdate);


     END IF;

  END IF;
Bug3749959 */
 -- Changes for Bug 3749959, ENDS.

        -- Set the message
        lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_INVALID_VALUE',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'ITEM');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

     -- Derive sr_item_pk from msd_st_level_values and msd_level_values

       lv_return :=  MSC_ST_UTIL.DERIVE_SR_PK
                       (p_table_name         => 'MSD_ST_MFG_FORECAST',
                        p_column_name        => 'ITEM',
                        p_pk_col_name        => 'SR_ITEM_PK',
                        p_level_id           => 1,
                        p_instance_code      => p_instance_code,
                        p_instance_id        =>  p_instance_id,
                        p_message_text       => lv_message_text,
                        p_batch_id           => lv_batch_id,
                        p_error_text         => lv_error_text);

        IF lv_return <> 0 THEN
            RAISE ex_logging_err;
        END IF;
         -- Set the message
        lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_INVALID_VALUE',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'INV_ORG');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

     -- Derive sr_inv_org_pk from msd_st_level_values and msd_level_values

       lv_return :=  MSC_ST_UTIL.DERIVE_SR_PK
                       (p_table_name         => 'MSD_ST_MFG_FORECAST',
                        p_column_name        => 'INV_ORG',
                        p_pk_col_name        => 'SR_INV_ORG_PK',
                        p_level_id           => 7,
                        p_instance_code      => p_instance_code,
                        p_instance_id        =>  p_instance_id,
                        p_message_text       => lv_message_text,
                        p_batch_id           => lv_batch_id,
                        p_error_text         => lv_error_text);

        IF lv_return <> 0 THEN
            RAISE ex_logging_err;
        END IF;

        -- Set the message
        lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_INVALID_VALUE',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'CUSTOMER');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

     -- Derive sr_customer_pk from msd_st_level_values and msd_level_values

       lv_return :=  MSC_ST_UTIL.DERIVE_SR_PK
                       (p_table_name         => 'MSD_ST_MFG_FORECAST',
                        p_column_name        => 'CUSTOMER',
                        p_pk_col_name        => 'SR_CUSTOMER_PK',
                        p_level_id           =>  15,
                        p_instance_code      => p_instance_code,
                        p_instance_id        =>  p_instance_id,
                        p_message_text       => lv_message_text,
                        p_batch_id           => lv_batch_id,
                        p_error_text         => lv_error_text);

        IF lv_return <> 0 THEN
            RAISE ex_logging_err;
        END IF;

        -- Set the message
        lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_INVALID_VALUE',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'SHIP_TO_LOC');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;
     -- Derive sr_ship_to_loc_pk from msd_st_level_values and msd_level_values

       lv_return :=  MSC_ST_UTIL.DERIVE_SR_PK
                       (p_table_name         => 'MSD_ST_MFG_FORECAST',
                        p_column_name        => 'SHIP_TO_LOC',
                        p_pk_col_name        => 'SR_SHIP_TO_LOC_PK',
                        p_level_id           =>  11,
                        p_instance_code      =>  p_instance_code,
                        p_instance_id        =>  p_instance_id,
                        p_message_text       => lv_message_text,
                        p_batch_id           => lv_batch_id,
                        p_error_text         => lv_error_text);

        IF lv_return <> 0 THEN
            RAISE ex_logging_err;
        END IF;

        -- Set the message
        lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_INVALID_VALUE',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'SALES_CHANNEL');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

     -- Derive sr_sales_channel_pk from msd_st_level_values and msd_level_values

       lv_return :=  MSC_ST_UTIL.DERIVE_SR_PK
                       (p_table_name         => 'MSD_ST_MFG_FORECAST',
                        p_column_name        => 'SALES_CHANNEL',
                        p_pk_col_name        => 'SR_SALES_CHANNEL_PK',
                        p_level_id           =>  27,
                        p_instance_code      => p_instance_code,
                        p_instance_id        =>  p_instance_id,
                        p_message_text       => lv_message_text,
                        p_batch_id           => lv_batch_id,
                        p_error_text         => lv_error_text);

        IF lv_return <> 0 THEN
            RAISE ex_logging_err;
        END IF;

-- Demand Class Changes for Mfg Forecast starts
       -- Set the message
        lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_INVALID_VALUE',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'DEMAND_CLASS_LVL_VAL');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

     -- Derive sr_sales_channel_pk from msd_st_level_values and msd_level_values

       lv_return :=  MSC_ST_UTIL.DERIVE_SR_PK
                       (p_table_name         => 'MSD_ST_MFG_FORECAST',
                        p_column_name        => 'DEMAND_CLASS_LVL_VAL',
                        p_pk_col_name        => 'SR_DEMAND_CLASS_PK',
                        p_level_id           =>  34,
                        p_instance_code      => p_instance_code,
                        p_instance_id        =>  p_instance_id,
                        p_message_text       => lv_message_text,
                        p_batch_id           => lv_batch_id,
                        p_error_text         => lv_error_text);

        IF lv_return <> 0 THEN
            RAISE ex_logging_err;
        END IF;

-- Demand Class Changes for Mfg Forecast ends

      -- set the message, USER_DEFINED1 is invalid

        lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_INVALID_VALUE',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'USER_DEFINED1');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

     -- Derive SR_USER_DEFINED2_LVL_PK

       lv_return := MSC_ST_UTIL.DERIVE_LEVEL_PK
                    (p_table_name      => 'MSD_ST_MFG_FORECAST',
                     p_level_val_col   => 'USER_DEFINED1',
                     p_level_name_col  => 'USER_DEFINED_LEVEL1',
                     p_level_pk_col    => 'SR_USER_DEFINED1_PK',
                     p_instance_code   => p_instance_code,
                     p_instance_id     => p_instance_id,
                     p_message_text    => lv_message_text,
                     p_batch_id        => lv_batch_id,
                     p_error_text      => lv_error_text);

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

      -- set the message, USER_DEFINED2 is invalid

        lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_INVALID_VALUE',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'USER_DEFINED2');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

     -- Derive SR_USER_DEFINED2_LVL_PK

       lv_return := MSC_ST_UTIL.DERIVE_LEVEL_PK
                    (p_table_name      => 'MSD_ST_MFG_FORECAST',
                     p_level_val_col   => 'USER_DEFINED2',
                     p_level_name_col  => 'USER_DEFINED_LEVEL2',
                     p_level_pk_col    => 'SR_USER_DEFINED2_PK',
                     p_instance_code   => p_instance_code,
                     p_instance_id     => p_instance_id,
                     p_message_text    => lv_message_text,
                     p_batch_id        => lv_batch_id,
                     p_error_text      => lv_error_text);

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

     -- Set the message
        lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_COL_VAL_NULL',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'FORECAST_DESIGNATOR');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

    -- Error out the record if forecast_designator is NULL
      v_sql_stmt := 08;
      lv_sql_stmt :=
      'UPDATE    msd_st_mfg_forecast'
      ||' SET    process_flag            = '||G_ERROR_FLG||','
      ||'        error_text      = '||''''||lv_message_text||''''
      ||' WHERE NVL(forecast_designator, '||''''||NULL_CHAR||''''||') '
      ||'        =                 '||''''||NULL_CHAR||''''
      ||' AND    batch_id                = :lv_batch_id'
      ||' AND    process_flag            = '||G_IN_PROCESS
      ||' AND    sr_instance_code        = :p_instance_code';

      IF lv_debug THEN
        msc_st_util.log_message(lv_sql_stmt);
      END IF;
      EXECUTE IMMEDIATE lv_sql_stmt
              USING     lv_batch_id,
                        p_instance_code;

      -- Set the message
      lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_COL_VAL_NULL',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'FORECAST_DATE');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

    v_sql_stmt := 08;
    lv_sql_Stmt:=
    'UPDATE     msd_st_mfg_forecast '
    ||' SET     process_flag              ='||G_ERROR_FLG||','
    ||'         error_text   = '||''''||lv_message_text||''''
    ||' WHERE   NVL(forecast_date,(sysdate-36500))  = (sysdate-36500)'
    ||' AND     process_flag              ='|| G_IN_PROCESS
    ||' AND     batch_id                  = :lv_batch_id'
    ||' AND     sr_instance_code          = :p_instance_code';

    IF lv_debug THEN
           msc_st_util.log_message(lv_sql_stmt);
    END IF;

   EXECUTE IMMEDIATE lv_sql_stmt
               USING lv_batch_id,
                     p_instance_code ;

      -- Set the message
      lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_COL_VAL_NULL',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'ORIGINAL_QUANTITY');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

     -- Original quantity should not be NULL
      lv_sql_stmt :=
      'UPDATE    msd_st_mfg_forecast'
      ||' SET    process_flag            = '||G_ERROR_FLG||','
      ||'        error_text   =   '||''''||lv_message_text||''''
      ||' WHERE  NVL(original_quantity,'||NULL_VALUE||')= '||NULL_VALUE
      ||' AND    process_flag            = '||G_IN_PROCESS
      ||' AND    batch_id                = :lv_batch_id'
      ||' AND    sr_instance_code        = :p_instance_code';

      IF lv_debug THEN
        msc_st_util.log_message(lv_sql_stmt);
      END IF;
      EXECUTE IMMEDIATE lv_sql_stmt
              USING     lv_batch_id,
                        p_instance_code;

    -- Current quantity should be defaulted to original quantitty of NULL

      v_sql_stmt := 08;
      lv_sql_stmt :=
      ' UPDATE  msd_st_mfg_forecast'
      ||' SET   current_quantity      = original_quantity'
      ||' WHERE  NVL(current_quantity,'||NULL_VALUE||')= '||NULL_VALUE
      ||' AND   process_flag      = '||G_IN_PROCESS
      ||' AND   batch_id          = :lv_batch_id'
      ||' AND   sr_instance_code  = :p_instance_code';

      IF lv_debug THEN
        msc_st_util.log_message(lv_sql_stmt);
      END IF;

      EXECUTE IMMEDIATE lv_sql_stmt
              USING     lv_batch_id,
                        p_instance_code;


    -- BUCKET_TYPE value should be 1,2 or 3 if NULL default it to 1(daily)
       v_sql_stmt := 08;
      lv_sql_stmt :=
      ' UPDATE  msd_st_mfg_forecast'
      ||' SET   bucket_type       = '||G_BUCKET_TYPE
      ||' WHERE NVL(bucket_type,'||NULL_VALUE||') NOT IN(1,2,3)'
      ||' AND   process_flag      = '||G_IN_PROCESS
      ||' AND   batch_id          = :lv_batch_id'
      ||' AND   sr_instance_code  = :p_instance_code';

      IF lv_debug THEN
        msc_st_util.log_message(lv_sql_stmt);
      END IF;

      EXECUTE IMMEDIATE lv_sql_stmt
              USING     lv_batch_id,
                        p_instance_code;

   OPEN instance_type;
      FETCH instance_type into lv_instance_type;
   CLOSE instance_type;


   IF (lv_instance_type = G_INS_OTHER) THEN

    lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_COL_REF_NOT_EXIST',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAMES',
                      p_token_value1      => 'SR_INSTANCE_CODE AND'
                                             ||' INV_ORG AND ITEM AND ITEM.ATO_FORECAST_CONTROL'
                                             ||' AND ITEM.MRP_PLANNING_CODE',
                      p_token2            => 'MASTER_TABLE',
                      p_token_value2      => 'MSC_SYSTEM_ITEMS',
                      p_token3            => 'CHILD_TABLE',
                      p_token_value3      => 'MSD_ST_MFG_FORECAST');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

      -- Validate item-org combination
      v_sql_stmt := 15;

      UPDATE msd_st_mfg_forecast mmf
      SET    process_flag = G_ERROR_FLG,
             error_text   = lv_message_text
      WHERE NOT EXISTS(SELECT 1
                       FROM   msc_st_system_items msi
                       WHERE  msi.sr_instance_id                  = p_instance_id
                       AND    nvl(msi.company_name,lv_my_company) = lv_my_company
                       AND    msi.organization_id                 = mmf.sr_inv_org_pk
                       AND    msi.item_name                       = mmf.item
                       AND   ((v_plan_per_profile = 4) OR (msi.ato_forecast_control <> 3))        --forecast control - none
                       AND   ((msi.mrp_planning_code                <> 6 ) OR (msi.pick_components_flag='Y' ))                         --Not planned item
                       UNION
                       SELECT 1
                       FROM   msc_system_items mls
                       WHERE  mls.sr_instance_id                  = p_instance_id
                       AND    mls.organization_id                 = mmf.sr_inv_org_pk
                       AND    mls.item_name                       = mmf.item
                       AND    mls.plan_id                         = -1
                       AND   ((v_plan_per_profile = 4) OR (mls.ato_forecast_control <> 3))        --forecast control - none
                       AND   ((mls.mrp_planning_code                <> 6 ) OR (mls.pick_components_flag='Y' )) )                        --Not planned item
      AND    mmf.process_flag            = G_IN_PROCESS
      AND    mmf.sr_instance_code        = p_instance_code
      AND    mmf.batch_id                = p_batch_id;

   END IF;

      --Call to customised validation.
      MSC_CL_PRE_PROCESS_HOOK.ENTITY_VALIDATION
        (ERRBUF         => lv_error_text,
         RETCODE        => lv_return,
         pBatchID       => lv_batch_id,
         pInstanceCode  => p_instance_code,
         pEntityName    => 'MSD_ST_MFG_FORECAST',
         pInstanceID    => p_instance_id);

      IF NVL(lv_return,0) <> 0 THEN
        RAISE ex_logging_err;
      END IF;

     -- Set the process flag as Valid and populate instance_id
      lv_return := MSC_ST_UTIL.SET_PROCESS_FLAG
                        (p_table_name     => 'MSD_ST_MFG_FORECAST',
                         p_instance_id    => p_instance_id,
                         p_instance_code  => p_instance_code,
                         p_process_flag   => G_VALID,
                         p_error_text     => lv_error_text,
                         p_batch_id       => lv_batch_id,
                         p_instance_id_col=> 'INSTANCE');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;


    -- Inserting all the errored out records into MSC_ERRORS:

      lv_return := MSC_ST_UTIL.LOG_ERROR
                   (p_table_name        => 'MSD_ST_MFG_FORECAST',
                    p_instance_code     => p_instance_code,
                    p_row               => lv_column_names,
                    p_severity          => G_SEV_ERROR,
                    p_error_text        => lv_error_text,
                    p_message_text      => NULL,
                    p_batch_id          => lv_batch_id);

      IF(lv_return <> 0) THEN
        msc_st_util.log_message(lv_error_text);
      END IF;
      COMMIT;

    EXCEPTION
      WHEN ex_logging_err THEN
        ROLLBACK;

        ERRBUF := lv_error_text;
        RETCODE := G_WARNING;
        msc_st_util.log_message(lv_error_text);

    WHEN OTHERS THEN
      ROLLBACK;

      lv_error_text    := substr('MSD_CL_PRE_PROCESS.LOAD_MFG_FORECAST '||'('
                       ||v_sql_stmt||')'|| SQLERRM, 1, 240);
      msc_st_util.log_message(lv_error_text);
      ERRBUF := lv_error_text;
      RETCODE := G_WARNING;

  END LOAD_MFG_FORECAST ;


 /*==========================================================================+
  | DESCRIPTION  : This function insert records for msd_st_time               |
  |                for manufacturing calendar                                 |
  +==========================================================================*/
  PROCEDURE LOAD_MFG_TIME (ERRBUF            OUT NOCOPY VARCHAR,
                           RETCODE           OUT NOCOPY NUMBER,
                           p_instance_id     IN NUMBER,
                           p_calendar_code   IN VARCHAR)
  IS
  lv_sql_stmt VARCHAR2(4000);
  lv_error_text VARCHAR2(250);
  lv_debug BOOLEAN := msc_cl_pre_process.v_debug;
  lv_return         NUMBER := 0;
  lv_cal_start_date  DATE;
  lv_cal_end_date  DATE;

  Cursor C is
  select max(day),min(day)
  from msd_st_time
  where calendar_code=p_calendar_code
  and instance=p_instance_id;

  BEGIN


    v_sql_stmt := 01;
    lv_sql_stmt :=
       ' INSERT INTO MSD_ST_TIME'
       ||' (INSTANCE , '
       ||'  CALENDAR_TYPE, '
       ||'  CALENDAR_CODE, '
       ||'  SEQ_NUM, '
       ||'  YEAR, '
       ||'  YEAR_DESCRIPTION, '
       ||'  YEAR_START_DATE, '
       ||'  YEAR_END_DATE, '
       ||'  QUARTER, '
       ||'  QUARTER_DESCRIPTION, '
       ||'  QUARTER_START_DATE,'
       ||'  QUARTER_END_DATE,'
       ||'  MONTH,'
       ||'  MONTH_DESCRIPTION,'
       ||'  MONTH_START_DATE,'
       ||'  MONTH_END_DATE,'
       ||'  WEEK ,'
       ||'  WEEK_DESCRIPTION ,'
       ||'  WEEK_START_DATE,'
       ||'  WEEK_END_DATE,'
       ||'  DAY,'
       ||'  DAY_DESCRIPTION,'
       ||'  LAST_UPDATE_DATE, '
       ||'  LAST_UPDATED_BY, '
       ||'  CREATION_DATE, '
       ||'  CREATED_BY, '
       ||'  LAST_UPDATE_LOGIN, '
       ||'  REQUEST_ID, '
       ||'  PROGRAM_APPLICATION_ID, '
       ||'  PROGRAM_ID, '
       ||'  PROGRAM_UPDATE_DATE ) '
       ||'  SELECT'
       ||'  mcd.sr_instance_id,'
       ||   G_MFG_CAL||','
       ||'  mcd.calendar_code, '
       ||'  mcd.seq_num, '
       ||'  NULL,'
       ||'  NULL,'
       ||'  NULL,'
       ||'  NULL,'
       ||'  NULL,'
       ||'  NULL,'
       ||'  NULL,'
       ||'  NULL,'
       ||'  mps.period_name'||'||''-''||'||'to_char(mps.period_start_date,''YYYY''),'
       ||'  mps.period_name'||'||''-''||'||'to_char(mps.period_start_date,''YYYY''),'
       ||'  mps.period_start_date,'
       ||'  DECODE(SIGN(mps.next_date-mps.period_start_date),1,(mps.next_date-1),'||'NULL'||'),'
       ||'  ''Week''||'||'mcws.seq_num ,'
       ||'  ''Week''||'||'mcws.seq_num ,'
       ||'  mcws.week_start_date ,'
       ||'  DECODE(SIGN(mcws.next_date-mcws.week_start_date),1,(mcws.next_date-1),'||'NULL'||'),'
       ||'  mcd.calendar_date,'
       ||'  mcd.calendar_date,'
       ||'  mcd.last_update_date,'
       ||'  mcd.last_updated_by,'
       ||'  mcd.creation_date,'
       ||'  mcd.created_by, '
       ||'  mcd.last_update_login, '
       ||'  mcd.request_id , '
       ||'  mcd.program_application_id, '
       ||'  mcd.program_id , '
       ||'  mcd.program_update_date '
       ||'  FROM    msc_period_start_dates mps,'
       ||'          msc_calendar_dates mcd,'
       ||'          msc_cal_week_start_dates mcws'
       ||'  WHERE   mcd.sr_instance_id = :p_instance_id'
       ||'  AND     mcd.calendar_code  = :p_calendar_code'
       ||'  AND     mcd.seq_num IS NOT NULL'
       ||'  AND     mcd.exception_set_id = -1'
       ||'  AND     mcws.calendar_code = mcd.calendar_code'
       ||'  AND     mcws.sr_instance_id = mcd.sr_instance_id'
       ||'  AND     mcws.exception_set_id = mcd.exception_set_id'
       ||'  AND     mcd.calendar_date BETWEEN mcws.week_start_date '
       ||'          AND  DECODE(SIGN(mcws.next_date- mcws.week_start_date),1,'
       ||'          (mcws.next_date-1),'||'NULL'||')'
       ||'  AND     mps.calendar_code = mcd.calendar_code'
       ||'  AND     mps.sr_instance_id = mcd.sr_instance_id'
       ||'  AND     mps.exception_set_id = mcd.exception_set_id'
       ||'  AND     mcd.calendar_date BETWEEN mps.period_start_date '
       ||'          AND  DECODE(SIGN(mps.next_date- mps.period_start_date),1,'
       ||'          (mps.next_date-1),'||'NULL'||')'   ;

      IF lv_debug THEN
        msc_st_util.log_message(lv_sql_stmt);
      END IF;
      EXECUTE IMMEDIATE lv_sql_stmt
              USING     p_instance_id,
                        p_calendar_code;

      IF lv_debug THEN
       OPEN C;
       FETCH C into lv_cal_end_date,lv_cal_start_date;
       msc_st_util.log_message('The Year Start Date is '||lv_cal_start_date||' and the Year End Date is '||lv_cal_end_date||' for the calendar with calendar code '||p_calendar_code);
       CLOSE C;
      END IF;

  EXCEPTION
   WHEN OTHERS THEN
     ROLLBACK;

    lv_error_text    := substr('MSD_CL_PRE_PROCESS.LOAD_MFG_TIME '||'('
                       ||v_sql_stmt||')'|| SQLERRM, 1, 240);
      msc_st_util.log_message(lv_error_text);
      ERRBUF := lv_error_text;
      RETCODE := G_WARNING;

  END LOAD_MFG_TIME;

  /*==========================================================================+
  | DESCRIPTION  : This function performs the validation and loads the data   |
  |                for business object fiscal calendar                        |
  +==========================================================================*/

  PROCEDURE LOAD_FISCAL_TIME (ERRBUF          OUT NOCOPY VARCHAR,
                              RETCODE         OUT NOCOPY NUMBER,
                              p_instance_code IN VARCHAR,
                              p_instance_id   IN NUMBER)
  IS
  TYPE RowidTab IS TABLE OF ROWID INDEX BY BINARY_INTEGER;
  TYPE Fiscal_Month_Cursor IS REF CURSOR;
  Fiscal_Month_Cur Fiscal_Month_Cursor ;

   lb_rowid          RowidTab;
   lv_sql_stmt       VARCHAR2(4000);
   lv_batch_id       msd_st_time.batch_id%TYPE;
   lv_message_text   msc_errors.error_text%TYPE;
   lv_error_text     VARCHAR2(250);
   lv_from_date      DATE ;
   lv_to_date        DATE ;
   lv_debug          BOOLEAN   := msc_cl_pre_process.v_debug;
   lv_batch_size     NUMBER    := msc_cl_pre_process.v_batch_size;
   lv_current_user   NUMBER    := msc_cl_pre_process.v_current_user;
   lv_current_date   DATE      := msc_cl_pre_process.v_current_date;
   lv_return         NUMBER := 0;
   lv_calendar_code                            varchar2(15);
   lv_SEQ_NUM                                  NUMBER;
   lv_YEAR                                     VARCHAR2(15);
   lv_YEAR_DESCRIPTION                         VARCHAR2(15);
   lv_YEAR_START_DATE                          DATE;
   lv_YEAR_END_DATE                            DATE;
   lv_QUARTER                                  VARCHAR2(15);
   lv_QUARTER_DESCRIPTION                      VARCHAR2(15);
   lv_QUARTER_START_DATE                       DATE;
   lv_QUARTER_END_DATE                         DATE;
   lv_MONTH                                    VARCHAR2(15);
   lv_MONTH_DESCRIPTION                        VARCHAR2(15);
   lv_MONTH_START_DATE                         DATE;
   lv_MONTH_END_DATE                           DATE;
   lv_instance_code			       VARCHAR2(3);

  ex_logging_err    EXCEPTION;
  lv_column_names   VARCHAR2(5000);

   CURSOR c1(p_batch_id NUMBER)IS
    SELECT rowid
    FROM   msd_st_time
    WHERE  process_flag      IN (G_IN_PROCESS,G_ERROR_FLG)
    AND    calendar_type    = G_FISCAL_CAL
    AND    sr_instance_code = p_instance_code
    AND    batch_id         = p_batch_id;

   CURSOR c2 IS
   SELECT  distinct calendar_code FROM  msd_st_time
   WHERE   calendar_type  = G_FISCAL_CAL
   AND     instance       = p_instance_id
   AND     process_flag   = G_VALID;

   BEGIN

     lv_instance_code := p_instance_code;

     lv_column_names :=
	'       SR_INSTANCE_CODE	||''~''||'
	||'	CALENDAR_CODE		||''~''||'
	||'	YEAR			||''~''||'
	||'	YEAR_DESCRIPTION	||''~''||'
	||'	YEAR_START_DATE		||''~''||'
	||'	YEAR_END_DATE		||''~''||'
	||'	QUARTER			||''~''||'
	||'	QUARTER_DESCRIPTION	||''~''||'
	||'	QUARTER_START_DATE	||''~''||'
	||'	QUARTER_END_DATE	||''~''||'
	||'	MONTH			||''~''||'
	||'	MONTH_DESCRIPTION	||''~''||'
	||'	MONTH_START_DATE	||''~''||'
	||'	MONTH_END_DATE ';

-- Check for the valid calendar_type - 3 or 4 (G_FISCAL_CAL or G_COMPOSITE_CAL).

   -- set the message

        lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_INVALID_VALUE',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'CALENDAR_TYPE');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

       v_sql_stmt := 05;
      lv_sql_stmt :=
      'UPDATE    msd_st_time'
      ||' SET    process_flag            = '||G_ERROR_FLG||','
      ||'        error_text      = '||''''||lv_message_text||''''
      ||' WHERE  calendar_type  not in ('||G_COMPOSITE_CAL||','||G_FISCAL_CAL||')'
      ||' AND    process_flag            = '||G_IN_PROCESS
      ||' AND    sr_instance_code        = :p_instance_code';

      IF lv_debug THEN
        msc_st_util.log_message(lv_sql_stmt);
      END IF;
      EXECUTE IMMEDIATE lv_sql_stmt
              USING     p_instance_code;



    -- Dividing records in batches based on batchsize
    LOOP
      v_sql_stmt := 02;
      SELECT       msd_st_batch_id_s.NEXTVAL
      INTO         lv_batch_id
      FROM         DUAL;

      v_sql_stmt := 03;

      lv_sql_stmt :=
      'UPDATE   msd_st_time'
      ||' SET   batch_id                       = :lv_batch_id '
      ||' WHERE process_flag  IN ('||G_IN_PROCESS||','||G_ERROR_FLG||')'
      ||' AND   sr_instance_code               = :lv_instance_code'
      ||' AND   calendar_type                  ='||G_FISCAL_CAL
      ||' AND   NVL(batch_id,'||NULL_VALUE||') = '||NULL_VALUE
      ||' AND   rownum                        <= '||lv_batch_size;

      IF lv_debug THEN
        msc_st_util.log_message(lv_sql_stmt);
      END IF;

      EXECUTE IMMEDIATE  lv_sql_stmt
              USING      lv_batch_id,
                         p_instance_code;

      EXIT WHEN SQL%NOTFOUND ;

      OPEN  c1(lv_batch_id);
      FETCH c1 BULK COLLECT INTO lb_rowid;
      CLOSE c1;

      v_sql_stmt := 04;
      FORALL j IN lb_rowid.FIRST..lb_rowid.LAST
      UPDATE msd_st_time
      SET  st_transaction_id = msd_st_time_s.NEXTVAL,
           last_update_date  = lv_current_date,
           last_updated_by   = lv_current_user,
           creation_date     = lv_current_date,
           created_by        = lv_current_user
      WHERE  rowid           = lb_rowid(j);



       -- set the message

        lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_COL_VAL_NULL',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      =>   'YEAR OR '
                                             ||'YEAR_DESCRIPTION OR '
                                             ||'YEAR_START_DATE OR '
                                             ||'YEAR_END_DATE OR '
                                             ||'QUARTER OR '
                                             ||'QUARTER_DESCRIPTION OR '
                                             ||'QUARTER_START_DATE OR '
                                             ||'QUARTER_END_DATE OR '
                                             ||'MONTH OR '
                                             ||'MONTH_DESCRIPTION OR '
                                             ||'MONTH_ START DATE OR '
                                             ||'MONTH END DATE ');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

      -- Error out the records if any of the details regarding Month, Year or
      -- Date is not provided.

      v_sql_stmt := 06;
      lv_sql_stmt :=
      'UPDATE    msd_st_time'
      ||' SET    process_flag            = '||G_ERROR_FLG||','
      ||'        error_text      = '||''''||lv_message_text||''''
      ||' WHERE  calendar_type   =        '||G_FISCAL_CAL
      ||' AND   ( year IS NULL'
      ||' OR    year_description IS NULL'
      ||' OR    year_start_date IS NULL'
      ||' OR    year_end_date   IS NULL'
      ||' OR    quarter IS NULL'
      ||' OR    quarter_description IS NULL'
      ||' OR    quarter_start_date  IS NULL'
      ||' OR    quarter_end_date   IS NULL'
      ||' OR    month IS NULL'
      ||' OR    month_description IS NULL'
      ||' OR    month_start_date IS NULL'
      ||' OR    month_end_date   IS NULL)'
      ||' AND    process_flag            = '||G_IN_PROCESS
      ||' AND    batch_id                = :lv_batch_id'
      ||' AND    sr_instance_code        = :p_instance_code';

      IF lv_debug THEN
        msc_st_util.log_message(lv_sql_stmt);
      END IF;

      EXECUTE IMMEDIATE lv_sql_stmt
              USING     lv_batch_id,
                        p_instance_code;

     -- set the message

        lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_END_GT_ST_DATE',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text  );


      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

    -- All the start date should be less than end date

      v_sql_stmt := 07;
      lv_sql_stmt :=
      'UPDATE    msd_st_time'
      ||' SET    process_flag            = '||G_ERROR_FLG||','
      ||'        error_text      = '||''''||lv_message_text||''''
      ||' WHERE  calendar_type   =        '||G_FISCAL_CAL
      ||' AND    (year_start_date    >= year_end_date'
      ||' OR      quarter_start_date >= quarter_end_date'
      ||' OR      month_start_date   >= month_end_date)'
      ||' AND    process_flag            = '||G_IN_PROCESS
      ||' AND    batch_id                = :lv_batch_id'
      ||' AND    sr_instance_code        = :p_instance_code';

      IF lv_debug THEN
        msc_st_util.log_message(lv_sql_stmt);
      END IF;
      EXECUTE IMMEDIATE lv_sql_stmt
              USING     lv_batch_id,
                        p_instance_code;

      --Call to customised validation.
      MSC_CL_PRE_PROCESS_HOOK.ENTITY_VALIDATION
        (ERRBUF         => lv_error_text,
         RETCODE        => lv_return,
         pBatchID       => lv_batch_id,
         pInstanceCode  => p_instance_code,
         pEntityName    => 'MSD_ST_TIME',
         pInstanceID    => p_instance_id);

      IF NVL(lv_return,0) <> 0 THEN
        RAISE ex_logging_err;
      END IF;
    -- Set the process flag as Valid and populate instance_id
      lv_return := MSC_ST_UTIL.SET_PROCESS_FLAG
                        (p_table_name     => 'MSD_ST_TIME',
                         p_instance_id    => p_instance_id,
                         p_instance_code  => p_instance_code,
                         p_process_flag   => G_VALID,
                         p_error_text     => lv_error_text,
                         p_batch_id       => lv_batch_id,
                         p_instance_id_col=> 'INSTANCE');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

   	-- Inserting all the errored out records into MSC_ERRORS:

      lv_return := MSC_ST_UTIL.LOG_ERROR
	                   (p_table_name        => 'MSD_ST_TIME',
	                    p_instance_code     => p_instance_code,
	                    p_row               => lv_column_names,
	                    p_severity          => G_SEV_ERROR,
	                    p_error_text        => lv_error_text,
	                    p_message_text      => NULL,
	                    p_batch_id          => lv_batch_id);

      IF(lv_return <> 0) THEN
	RAISE ex_logging_err;
      END IF;
      COMMIT;

   END LOOP;


   FOR rec1 in c2

   LOOP

   v_sql_stmt := 08;
   lv_sql_stmt :=
   '   SELECT min(year_start_date),'
   ||'  max(year_end_date)'
   ||' FROM msd_st_time'
   ||' WHERE calendar_code = :calendar_code'
   ||' AND calendar_type ='||G_FISCAL_CAL
   ||' AND instance = '||p_instance_id ;


   IF lv_debug THEN
          msc_st_util.log_message(lv_sql_stmt);
   END IF;

   EXECUTE IMMEDIATE lv_sql_stmt
   INTO    lv_from_date,
           lv_to_date
   USING   rec1.calendar_code;


  IF lv_debug THEN
   msc_st_util.log_message( 'calendar'||rec1.calendar_code);
   msc_st_util.log_message('FROM DATE'||lv_from_date);
   msc_st_util.log_message('TO DATE '||lv_to_date);
  END IF;


   v_sql_stmt := 08;
   lv_sql_stmt :=      'SELECT  ' ||
                        ' calendar_code, '  ||
                        ' year, ' ||
                        ' year_description, ' ||
                        ' year_start_date, ' ||
                        ' year_end_date, ' ||
                        ' quarter, ' ||
                        ' quarter_description, ' ||
                        ' quarter_start_date, ' ||
                        ' quarter_end_date, ' ||
                        ' month, ' ||
                        ' month_description, ' ||
                        ' month_start_Date, ' ||
                        ' month_end_date  ' ||
                        ' from  msd_st_time' ||
                        ' where calendar_code = NVL(''' ||rec1.calendar_code || ''', calendar_code)'||
                        ' and calendar_type='||G_FISCAL_CAL||
                        ' and instance= '||p_instance_id||
                        ' order by month_start_date';

        IF lv_debug THEN
          msc_st_util.log_message(lv_sql_stmt);
        END IF;

       OPEN Fiscal_Month_Cur FOR lv_sql_stmt ;

		       LOOP
		              FETCH Fiscal_Month_Cur
		              INTO    lv_calendar_code,
		                      lv_YEAR,
		                      lv_YEAR_DESCRIPTION,
		                      lv_YEAR_START_DATE,
		                      lv_YEAR_END_DATE,
		                      lv_QUARTER,
		                      lv_QUARTER_DESCRIPTION,
		                      lv_QUARTER_START_DATE,
		                      lv_QUARTER_END_DATE,
		                      lv_MONTH,
		                      lv_MONTH_DESCRIPTION,
		                      lv_MONTH_START_DATE,
		                      lv_MONTH_END_DATE;

		        EXIT WHEN Fiscal_Month_Cur%NOTFOUND;

		       MSD_TRANSLATE_TIME_DATA.Explode_Fiscal_Dates(    errbuf                  => errbuf,
		                                retcode                 => retcode,
		                                p_dest_table            => 'MSD_ST_TIME',
		                                p_instance_id           => p_instance_id,
		                                p_calendar_type_id      => G_FISCAL_CAL,
		                                p_calendar_code         => lv_calendar_code,
		                                p_seq_num               => null,
		                                p_year                  => lv_year,
		                                p_year_description      => lv_year_description,
		                                p_year_start_date       => lv_year_start_date,
		                                p_year_end_date         => lv_year_end_date,
		                                p_quarter               => lv_quarter,
		                                p_quarter_description   => lv_quarter_description,
		                                p_quarter_start_date    => lv_quarter_start_date,
		                                p_quarter_end_date      => lv_quarter_end_date,
		                                p_month                 => lv_month,
		                                p_month_description     => lv_month_description,
		                                p_month_start_date      => lv_month_start_date,
		                                p_month_end_date        => lv_month_end_date,
		                                p_from_date             => lv_from_date,
		                                p_to_date               => lv_to_date );

		          END LOOP ;
       CLOSE Fiscal_Month_Cur;

        v_sql_stmt := 09;
        lv_sql_stmt:=
        '   DELETE  from MSD_ST_TIME '
        ||' WHERE   calendar_code = :calendar_code'
        ||' AND     process_flag  = '||G_VALID
        ||' AND     calendar_type = '||G_FISCAL_CAL
        ||' AND     sr_instance_code = :lv_instance_code  ';

        IF lv_debug THEN
          msc_st_util.log_message(lv_sql_stmt);
        END IF;
        EXECUTE IMMEDIATE lv_sql_stmt
              USING     rec1.calendar_code,
                        p_instance_code;
     COMMIT;
     END LOOP ;


    EXCEPTION
     WHEN ex_logging_err THEN
        ROLLBACK;

        ERRBUF := lv_error_text;
        RETCODE := G_WARNING;
        msc_st_util.log_message(lv_error_text);

     WHEN OTHERS THEN
      ROLLBACK;

      lv_error_text    := substr('MSD_CL_PRE_PROCESS.LOAD_FISCAL_TIME '||'('
                       ||v_sql_stmt||')'|| SQLERRM, 1, 240);
      msc_st_util.log_message(lv_error_text);
      ERRBUF := lv_error_text;
      RETCODE := G_WARNING;

  END LOAD_FISCAL_TIME ;


  /*==========================================================================+
  | DESCRIPTION  : This function performs the validation and loads the data   |
  |                for business object composite calendar                     |
  +==========================================================================*/

  PROCEDURE LOAD_COMPOSITE_TIME (ERRBUF          OUT NOCOPY VARCHAR,
                                 RETCODE         OUT NOCOPY NUMBER,
                                 p_instance_code IN VARCHAR,
                                 p_instance_id   IN NUMBER   )
  IS

  TYPE RowidTab IS TABLE OF ROWID INDEX BY BINARY_INTEGER;
  TYPE Composite_Week_Cursor IS REF CURSOR;
  Composite_Week_Cur Composite_Week_Cursor ;

   lb_rowid          RowidTab;
   lv_sql_stmt       VARCHAR2(4000);
   lv_batch_id       msd_st_time.batch_id%TYPE;
   lv_message_text   msc_errors.error_text%TYPE;
   lv_error_text     VARCHAR2(250);
   lv_from_date      DATE ;
   lv_to_date        DATE ;
   lv_debug          BOOLEAN   := msc_cl_pre_process.v_debug;
   lv_batch_size     NUMBER    := msc_cl_pre_process.v_batch_size;
   lv_current_user   NUMBER    := msc_cl_pre_process.v_current_user;
   lv_current_date   DATE      := msc_cl_pre_process.v_current_date;
   lv_return         NUMBER := 0;

   lv_calendar_code                            varchar2(15);
   lv_SEQ_NUM                                  NUMBER;
   lv_YEAR                                     VARCHAR2(15);
   lv_YEAR_DESCRIPTION                         VARCHAR2(15);
   lv_YEAR_START_DATE                          DATE;
   lv_YEAR_END_DATE                            DATE;
   lv_QUARTER                                  VARCHAR2(15);
   lv_QUARTER_DESCRIPTION                      VARCHAR2(15);
   lv_QUARTER_START_DATE                       DATE;
   lv_QUARTER_END_DATE                         DATE;
   lv_MONTH                                    VARCHAR2(15);
   lv_MONTH_DESCRIPTION                        VARCHAR2(15);
   lv_MONTH_START_DATE                         DATE;
   lv_MONTH_END_DATE                           DATE;
   lv_WEEK                                     VARCHAR2(15);
   lv_WEEK_DESCRIPTION                         VARCHAR2(15);
   lv_WEEK_START_DATE                          DATE;
   lv_WEEK_END_DATE                            DATE;
   lv_DAY                                      DATE;
   lv_DAY_DESCRIPTION                          VARCHAR2(15);
   lv_instance_code			       VARCHAR2(3);

   ex_logging_err    EXCEPTION;
   lv_column_names   VARCHAR2(5000);

   CURSOR c1(p_batch_id NUMBER)IS
    SELECT rowid
    FROM   msd_st_time
    WHERE  process_flag      IN (G_IN_PROCESS)
    AND    calendar_type    = G_COMPOSITE_CAL
    AND    sr_instance_code = p_instance_code
    AND    batch_id         = p_batch_id;

  CURSOR c2 IS
   SELECT  distinct calendar_code FROM  msd_st_time
   WHERE   calendar_type  = G_COMPOSITE_CAL
   AND     instance       = p_instance_id
   AND     process_flag   = G_VALID;

   BEGIN

     lv_instance_code := p_instance_code;

     lv_column_names :=
	'       INSTANCE	        ||''~''||'
	||'	CALENDAR_CODE		||''~''||'
	||'	YEAR			||''~''||'
	||'	YEAR_DESCRIPTION	||''~''||'
	||'	YEAR_START_DATE		||''~''||'
	||'	YEAR_END_DATE		||''~''||'
	||'	QUARTER			||''~''||'
	||'	QUARTER_DESCRIPTION	||''~''||'
	||'	QUARTER_START_DATE	||''~''||'
	||'	QUARTER_END_DATE	||''~''||'
	||'	MONTH			||''~''||'
	||'	MONTH_DESCRIPTION	||''~''||'
	||'	MONTH_START_DATE	||''~''||'
	||'	MONTH_END_DATE	        ||''~''||'
	||'	WEEK			||''~''||'
	||'	WEEK_DESCRIPTION	||''~''||'
	||'	WEEK_START_DATE		||''~''||'
	||'	WEEK_END_DATE	        ||''~''||'
	||'	DAY	                ||''~''||'
	||'	DAY_DESCRIPTION ';


   -- Check for the valid calendar_type value - 3 or 4 ( G_FISCAL_CAL ,G_COMPOSITE_CAL).

   -- set the message

        lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_INVALID_VALUE',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'CALENDAR_TYPE');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

       v_sql_stmt := 01;
      lv_sql_stmt :=
      'UPDATE    msd_st_time'
      ||' SET    process_flag            = '||G_ERROR_FLG||','
      ||'        error_text      = '||''''||lv_message_text||''''
      ||' WHERE  calendar_type not in ('||G_COMPOSITE_CAL||','||G_FISCAL_CAL||')'
      ||' AND    process_flag            = '||G_IN_PROCESS
      ||' AND    sr_instance_code        = :p_instance_code';

      IF lv_debug THEN
        msc_st_util.log_message(lv_sql_stmt);
      END IF;
      EXECUTE IMMEDIATE lv_sql_stmt
              USING     p_instance_code;


    -- Dividing records in batches based on batchsize
    LOOP
      v_sql_stmt := 02;
      SELECT       msd_st_batch_id_s.NEXTVAL
      INTO         lv_batch_id
      FROM         DUAL;

      v_sql_stmt := 03;

      lv_sql_stmt :=
      'UPDATE   msd_st_time'
      ||' SET   batch_id                       = :lv_batch_id '
      ||' WHERE process_flag  IN ('||G_IN_PROCESS||')'
      ||' AND   sr_instance_code               = :lv_instance_code'
      ||' AND   calendar_type                  ='||G_COMPOSITE_CAL
      ||' AND   NVL(batch_id,'||NULL_VALUE||') = '||NULL_VALUE
      ||' AND   rownum                        <= '||lv_batch_size;

      IF lv_debug THEN
        msc_st_util.log_message(lv_sql_stmt);
      END IF;

      EXECUTE IMMEDIATE  lv_sql_stmt
              USING      lv_batch_id,
                         p_instance_code;

      EXIT WHEN SQL%NOTFOUND ;

      OPEN  c1(lv_batch_id);
      FETCH c1 BULK COLLECT INTO lb_rowid;
      CLOSE c1;

      v_sql_stmt := 04;
      FORALL j IN lb_rowid.FIRST..lb_rowid.LAST
      UPDATE msd_st_time
      SET  st_transaction_id = msd_st_time_s.NEXTVAL,
           last_update_date  = lv_current_date,
           last_updated_by   = lv_current_user,
           creation_date     = lv_current_date,
           created_by        = lv_current_user
      WHERE  rowid           = lb_rowid(j);



       -- set the message

        lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_COL_VAL_NULL',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                       p_token_value1      =>   'YEAR OR '
                                             ||'YEAR_DESCRIPTION OR '
                                             ||'YEAR_START_DATE OR '
                                             ||'YEAR_END_DATE OR '
                                             ||'QUARTER OR '
                                             ||'QUARTER_DESCRIPTION OR '
                                             ||'QUARTER_START_DATE OR '
                                             ||'QUARTER_END_DATE OR '
                                             ||'MONTH OR '
                                             ||'MONTH_DESCRIPTION OR '
                                             ||'MONTH_ START DATE OR '
                                             ||'MONTH END DATE OR '
                                             ||'WEEK OR '
                                             ||'WEEK_DESCRIPTION OR '
                                             ||'WEEK_START_DATE OR '
                                             ||'WEEK_END_DATE ');



      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

      -- Error out the records if any of the details regarding Week, Quarter, Month, Year or
      -- Date is not provided.

      v_sql_stmt := 05;
      lv_sql_stmt :=
      'UPDATE    msd_st_time'
      ||' SET    process_flag            = '||G_ERROR_FLG||','
      ||'        error_text      = '||''''||lv_message_text||''''
      ||' WHERE  calendar_type   =        '||G_COMPOSITE_CAL
      ||' AND   ( year IS NULL'
      ||' OR    year_description IS NULL'
      ||' OR    year_start_date IS NULL'
      ||' OR    year_end_date   IS NULL'
      ||' OR    quarter IS NULL'
      ||' OR    quarter_description IS NULL'
      ||' OR    quarter_start_date  IS NULL'
      ||' OR    quarter_end_date   IS NULL'
      ||' OR    month IS NULL'
      ||' OR    month_description IS NULL'
      ||' OR    month_start_date  IS NULL'
      ||' OR    month_end_date   IS NULL'
      ||' OR    week IS NULL'
      ||' OR    week_description IS NULL'
      ||' OR    week_start_date IS NULL'
      ||' OR    week_end_date   IS NULL )'
      ||' AND    process_flag            = '||G_IN_PROCESS
      ||' AND    batch_id                = :lv_batch_id'
      ||' AND    sr_instance_code        = :p_instance_code';

      IF lv_debug THEN
        msc_st_util.log_message(lv_sql_stmt);
      END IF;

      EXECUTE IMMEDIATE lv_sql_stmt
              USING     lv_batch_id,
                        p_instance_code;





     -- set the message

        lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_END_GT_ST_DATE',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text );


      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

    -- All the start date should be less than end date

      v_sql_stmt := 06;
      lv_sql_stmt :=
      'UPDATE    msd_st_time'
      ||' SET    process_flag            = '||G_ERROR_FLG||','
      ||'        error_text      = '||''''||lv_message_text||''''
      ||' WHERE  calendar_type   =        '||G_COMPOSITE_CAL
      ||' AND    (year_start_date    > year_end_date'
      ||' OR      quarter_start_date > quarter_end_date'
      ||' OR      month_start_date   > month_end_date'
      ||' OR      week_start_date    > week_end_date)'
      ||' AND    process_flag            = '||G_IN_PROCESS
      ||' AND    batch_id                = :lv_batch_id'
      ||' AND    sr_instance_code        = :p_instance_code';

      IF lv_debug THEN
        msc_st_util.log_message(lv_sql_stmt);
      END IF;
      EXECUTE IMMEDIATE lv_sql_stmt
              USING     lv_batch_id,
                        p_instance_code;




      --Call to customised validation.
      MSC_CL_PRE_PROCESS_HOOK.ENTITY_VALIDATION
        (ERRBUF         => lv_error_text,
         RETCODE        => lv_return,
         pBatchID       => lv_batch_id,
         pInstanceCode  => p_instance_code,
         pEntityName    => 'MSD_ST_TIME',
         pInstanceID    => p_instance_id);

      IF NVL(lv_return,0) <> 0 THEN
        RAISE ex_logging_err;
      END IF;



    -- Set the process flag as Valid and populate instance_id
      lv_return := MSC_ST_UTIL.SET_PROCESS_FLAG
                        (p_table_name     => 'MSD_ST_TIME',
                         p_instance_id    => p_instance_id,
                         p_instance_code  => p_instance_code,
                         p_process_flag   => G_VALID,
                         p_error_text     => lv_error_text,
                         p_batch_id       => lv_batch_id,
                         p_instance_id_col=> 'INSTANCE');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;



   	-- Inserting all the errored out records into MSC_ERRORS:

      lv_return := MSC_ST_UTIL.LOG_ERROR
	                   (p_table_name        => 'MSD_ST_TIME',
	                    p_instance_code     => p_instance_code,
	                    p_row               => lv_column_names,
	                    p_severity          => G_SEV_ERROR,
	                    p_error_text        => lv_error_text,
	                    p_message_text      => NULL,
	                    p_batch_id          => lv_batch_id);

      IF(lv_return <> 0) THEN
	RAISE ex_logging_err;
      END IF;
      COMMIT;

   END LOOP;


FOR rec1 in c2

   LOOP

   v_sql_stmt := 08;
   lv_sql_stmt :=
   '   SELECT min(year_start_date),'
   ||'  max(year_end_date)'
   ||' FROM msd_st_time'
   ||' WHERE calendar_code = :calendar_code'
   ||' AND calendar_type ='||G_COMPOSITE_CAL
   ||' AND instance = '||p_instance_id ;


   IF lv_debug THEN
          msc_st_util.log_message(lv_sql_stmt);
   END IF;

   EXECUTE IMMEDIATE lv_sql_stmt
   INTO    lv_from_date,
           lv_to_date
   USING   rec1.calendar_code;


  IF lv_debug THEN
   msc_st_util.log_message( 'calendar'||rec1.calendar_code);
   msc_st_util.log_message('FROM DATE'||lv_from_date);
   msc_st_util.log_message('TO DATE '||lv_to_date);
  END IF;


   v_sql_stmt := 08;
   lv_sql_stmt :=      'SELECT  ' ||
                        ' calendar_code, '  ||
                        ' year, ' ||
                        ' year_description, ' ||
                        ' year_start_date, ' ||
                        ' year_end_date, ' ||
                        ' quarter, ' ||
                        ' quarter_description, ' ||
                        ' quarter_start_date, ' ||
                        ' quarter_end_date, ' ||
                        ' month, ' ||
                        ' month_description, ' ||
                        ' month_start_Date, ' ||
                        ' month_end_date,  ' ||
                        ' week, '||
                        ' week_description, '||
                        ' week_start_date, '||
                        ' week_end_date ' ||
                        ' from  msd_st_time' ||
                        ' where calendar_code = NVL(''' ||rec1.calendar_code || ''', calendar_code)'||
                        ' and calendar_type='||G_COMPOSITE_CAL ||
                        ' and instance= '||p_instance_id||
                        ' order by week_start_date';

        IF lv_debug THEN
          msc_st_util.log_message(lv_sql_stmt);
        END IF;

       OPEN Composite_Week_Cur FOR lv_sql_stmt ;

		       LOOP
		              FETCH Composite_Week_Cur
		              INTO    lv_calendar_code,
		                      lv_YEAR,
		                      lv_YEAR_DESCRIPTION,
		                      lv_YEAR_START_DATE,
		                      lv_YEAR_END_DATE,
		                      lv_QUARTER,
		                      lv_QUARTER_DESCRIPTION,
		                      lv_QUARTER_START_DATE,
		                      lv_QUARTER_END_DATE,
		                      lv_MONTH,
		                      lv_MONTH_DESCRIPTION,
		                      lv_MONTH_START_DATE,
		                      lv_MONTH_END_DATE,
		                      lv_WEEK,
		                      lv_WEEK_DESCRIPTION,
		                      lv_WEEK_START_DATE,
		                      lv_WEEK_END_DATE;

		        EXIT WHEN Composite_Week_Cur%NOTFOUND;

		       MSC_ST_UTIL.Explode_Composite_Dates(    errbuf                  => errbuf,
		                                retcode                 => retcode,
		                                p_dest_table            => 'MSD_ST_TIME',
		                                p_instance_id           => p_instance_id,
		                                p_calendar_type_id      => G_COMPOSITE_CAL,
		                                p_calendar_code         => lv_calendar_code,
		                                p_seq_num               => null,
		                                p_year                  => lv_year,
		                                p_year_description      => lv_year_description,
		                                p_year_start_date       => lv_year_start_date,
		                                p_year_end_date         => lv_year_end_date,
		                                p_quarter               => lv_quarter,
		                                p_quarter_description   => lv_quarter_description,
		                                p_quarter_start_date    => lv_quarter_start_date,
		                                p_quarter_end_date      => lv_quarter_end_date,
		                                p_month                 => lv_month,
		                                p_month_description     => lv_month_description,
		                                p_month_start_date      => lv_month_start_date,
		                                p_month_end_date        => lv_month_end_date,
		                                p_week                  => lv_week,
		                                p_week_description      => lv_week_description,
		                                p_week_start_date       => lv_week_start_date,
		                                p_week_end_date         => lv_week_end_date);


		          END LOOP ;
       CLOSE Composite_Week_Cur;

        v_sql_stmt := 09;
        lv_sql_stmt:=
        '   DELETE  from MSD_ST_TIME '
        ||' WHERE   calendar_code = :calendar_code'
        ||' AND     process_flag  = '||G_VALID
        ||' AND     calendar_type = '||G_COMPOSITE_CAL
        ||' AND     sr_instance_code = :lv_instance_code  ';

        IF lv_debug THEN
          msc_st_util.log_message(lv_sql_stmt);
        END IF;
        EXECUTE IMMEDIATE lv_sql_stmt
              USING     rec1.calendar_code,
                        p_instance_code;
     COMMIT;
     END LOOP ;


EXCEPTION
    WHEN ex_logging_err THEN
        ROLLBACK;

        ERRBUF := lv_error_text;
        RETCODE := G_WARNING;
        msc_st_util.log_message(lv_error_text);

    WHEN OTHERS THEN
      ROLLBACK;

      lv_error_text    := substr('MSD_CL_PRE_PROCESS.LOAD_COMPOSITE_TIME '||'('
                       ||v_sql_stmt||')'|| SQLERRM, 1, 240);
      msc_st_util.log_message(lv_error_text);
      ERRBUF := lv_error_text;
      RETCODE := G_WARNING;

END LOAD_COMPOSITE_TIME ;



  /*==========================================================================+
  | DESCRIPTION  : This function performs the validation and loads the data   |
  |                for business object currency conversion                    |
  +==========================================================================*/

  PROCEDURE LOAD_CURRENCY_CONV (ERRBUF          OUT NOCOPY VARCHAR,
                                RETCODE         OUT NOCOPY NUMBER,
                                p_instance_code IN VARCHAR,
                                p_instance_id   IN NUMBER,
                                p_batch_id      IN NUMBER)

  IS
  TYPE RowidTab IS TABLE OF ROWID INDEX BY BINARY_INTEGER;
  lb_rowid          RowidTab;
  lv_sql_stmt       VARCHAR2(4000);
  lv_batch_id       msd_st_currency_conversions.batch_id%TYPE;
  lv_message_text   msc_errors.error_text%TYPE;
  lv_error_text     VARCHAR2(250);
  lv_debug          BOOLEAN   := msc_cl_pre_process.v_debug;
  lv_batch_size     NUMBER    := msc_cl_pre_process.v_batch_size;
  lv_current_user   NUMBER    := msc_cl_pre_process.v_current_user;
  lv_current_date   DATE      := msc_cl_pre_process.v_current_date;
  lv_return         NUMBER := 0;
  ex_logging_err    EXCEPTION;
  lv_column_names   VARCHAR2(5000);

  CURSOR c1(p_batch_id NUMBER)IS
    SELECT rowid
    FROM   msd_st_currency_conversions
    WHERE  process_flag      IN (G_IN_PROCESS,G_ERROR_FLG)
    AND    sr_instance_code = p_instance_code
    AND    batch_id         = p_batch_id;

   BEGIN

      lv_batch_id := p_batch_id;

      lv_column_names :=
	'       SR_INSTANCE_CODE	||''~''||'
	||'	FROM_CURRENCY		||''~''||'
	||'	TO_CURRENCY		||''~''||'
	||'	CONVERSION_DATE		||''~''||'
	||'	CONVERSION_RATE ';

      OPEN  c1(lv_batch_id);
      FETCH c1 BULK COLLECT INTO lb_rowid;
      CLOSE c1;

      v_sql_stmt := 04;
      FORALL j IN lb_rowid.FIRST..lb_rowid.LAST
      UPDATE msd_st_currency_conversions
      SET  st_transaction_id = msd_st_currency_conversions_s.NEXTVAL,
           last_update_date  = lv_current_date,
           last_updated_by   = lv_current_user,
           creation_date     = lv_current_date,
           created_by        = lv_current_user
      WHERE  rowid           = lb_rowid(j);

     -- set the message

      lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_COL_VAL_NULL',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'FROM_CURRENCY OR'
                                             ||'TO_CURRENCY OR'
                                             ||'CONVERSION_DATE OR'
                                             ||'CONVERSION_RATE');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

      -- error out if conversion rate, conversion dfate, from or to currency is null
      lv_sql_stmt :=
      'UPDATE    msd_st_currency_conversions'
      ||' SET    process_flag            = '||G_ERROR_FLG||','
      ||'        error_text      = '||''''||lv_message_text||''''
      ||' WHERE (NVL(from_currency, '||''''||NULL_CHAR||''''||') '
      ||'          =                 '||''''||NULL_CHAR||''''
      ||' OR   NVL(to_currency, '||''''||NULL_CHAR||''''||') '
      ||'          =                 '||''''||NULL_CHAR||''''
      ||' OR  NVL(conversion_date,(sysdate-36500))  = (sysdate-36500)'
      ||' OR  NVL(conversion_rate,'||NULL_VALUE||') = '||NULL_VALUE||')'
      ||' AND    process_flag            = '||G_IN_PROCESS
      ||' AND    batch_id                = :lv_batch_id'
      ||' AND    sr_instance_code        = :p_instance_code';

      IF lv_debug THEN
        msc_st_util.log_message(lv_sql_stmt);
      END IF;
      EXECUTE IMMEDIATE lv_sql_stmt
              USING     lv_batch_id,
                        p_instance_code;

      --Call to customised validation.
      MSC_CL_PRE_PROCESS_HOOK.ENTITY_VALIDATION
        (ERRBUF         => lv_error_text,
         RETCODE        => lv_return,
         pBatchID       => lv_batch_id,
         pInstanceCode  => p_instance_code,
         pEntityName    => 'MSD_ST_CURRENCY_CONVERSIONS',
         pInstanceID    => p_instance_id);

      IF NVL(lv_return,0) <> 0 THEN
        RAISE ex_logging_err;
      END IF;

     -- Set the process flag as Valid and populate instance_id
      lv_return := MSC_ST_UTIL.SET_PROCESS_FLAG
                        (p_table_name     => 'MSD_ST_CURRENCY_CONVERSIONS',
                         p_instance_id    => p_instance_id,
                         p_instance_code  => p_instance_code,
                         p_process_flag   => G_VALID,
                         p_error_text     => lv_error_text,
                         p_batch_id       => lv_batch_id,
                         p_instance_id_col=> 'INSTANCE');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

    -- Inserting all the errored out records into MSC_ERRORS:

      lv_return := MSC_ST_UTIL.LOG_ERROR
                   (p_table_name        => 'MSD_ST_CURRENCY_CONVERSIONS',
                    p_instance_code     => p_instance_code,
                    p_row               => lv_column_names,
                    p_severity          => G_SEV_ERROR,
                    p_error_text        => lv_error_text,
                    p_message_text      => NULL,
                    p_batch_id          => lv_batch_id);

    IF(lv_return <> 0) THEN
      msc_st_util.log_message(lv_error_text);
    END IF;
    COMMIT;

    EXCEPTION
      WHEN ex_logging_err THEN
        ROLLBACK;

        ERRBUF := lv_error_text;
        RETCODE := G_WARNING;
        msc_st_util.log_message(lv_error_text);

     WHEN OTHERS THEN
      ROLLBACK;

      lv_error_text    := substr('MSD_CL_PRE_PROCESS.LOAD_CURRENCY_CONV '||'('
                       ||v_sql_stmt||')'|| SQLERRM, 1, 240);
      msc_st_util.log_message(lv_error_text);
      ERRBUF := lv_error_text;
      RETCODE := G_WARNING;

  END LOAD_CURRENCY_CONV ;

  /*==========================================================================+
  | DESCRIPTION  : This function performs the validation and loads the data   |
  |                for business object Custom Stream(CS)Data                  |
  +==========================================================================*/

  PROCEDURE LOAD_CS_DATA (ERRBUF          OUT NOCOPY VARCHAR,
                          RETCODE         OUT NOCOPY NUMBER,
                          p_instance_code IN VARCHAR,
                          p_instance_id   IN NUMBER,
                          p_batch_id      IN NUMBER)
  IS
  TYPE RowidTab IS TABLE OF ROWID INDEX BY BINARY_INTEGER;
  lb_rowid          RowidTab;
  lv_sql_stmt       VARCHAR2(4000);
  lv_batch_id       msd_st_cs_data.batch_id%TYPE;
  lv_message_text   msc_errors.error_text%TYPE;
  lv_my_company     msc_companies.company_name%TYPE := GET_MY_COMPANY;
  lv_error_text     VARCHAR2(250);
  lv_debug          BOOLEAN   := msc_cl_pre_process.v_debug;
  lv_batch_size     NUMBER    := msc_cl_pre_process.v_batch_size;
  lv_current_user   NUMBER    := msc_cl_pre_process.v_current_user;
  lv_current_date   DATE      := msc_cl_pre_process.v_current_date;
  lv_return         NUMBER := 0;
  ex_logging_err    EXCEPTION;
   lv_column_names   VARCHAR2(5000);

  CURSOR c1(p_batch_id NUMBER)IS
    SELECT rowid
    FROM   msd_st_cs_data
    WHERE  process_flag      IN (G_IN_PROCESS,G_ERROR_FLG)
    AND    sr_instance_code = p_instance_code
    AND    batch_id         = p_batch_id;

 CURSOR instance_type IS
   SELECT instance_type
   FROM msc_apps_instances
   WHERE instance_id=p_instance_id;

   lv_instance_type  msc_apps_instances.instance_type%TYPE;

   BEGIN

      lv_batch_id := p_batch_id;

      lv_column_names :=
	'	SR_INSTANCE_CODE	||''~''||'
	||'	CS_DEFINITION_NAME	||''~''||'
	||'	CS_NAME	                ||''~''||'
	||'	DELETE_FLAG		||''~''||'
	||'	ATTRIBUTE_2_VAL		||''~''||'
	||'	ATTRIBUTE_4		||''~''||'
	||'	ATTRIBUTE_6_VAL		||''~''||'
	||'	ATTRIBUTE_8		||''~''||'
	||'	ATTRIBUTE_10_VAL	||''~''||'
	||'	ATTRIBUTE_12		||''~''||'
	||'	ATTRIBUTE_14_VAL	||''~''||'
	||'	ATTRIBUTE_16		||''~''||'
	||'	ATTRIBUTE_18_VAL	||''~''||'
	||'	ATTRIBUTE_20		||''~''||'
	||'	ATTRIBUTE_22_VAL	||''~''||'
	||'	ATTRIBUTE_24		||''~''||'
	||'	ATTRIBUTE_26_VAL	||''~''||'
	||'	ATTRIBUTE_28		||''~''||'
	||'	ATTRIBUTE_30_VAL	||''~''||'
	||'	ATTRIBUTE_32		||''~''||'
	||'	ATTRIBUTE_34		||''~''||'
	||'	ATTRIBUTE_41		||''~''||'
	||'	ATTRIBUTE_42		||''~''||'
	||'	ATTRIBUTE_43		||''~''||'
	||'	ATTRIBUTE_44		||''~''||'
	||'	ATTRIBUTE_45 ';

      OPEN  c1(lv_batch_id);
      FETCH c1 BULK COLLECT INTO lb_rowid;
      CLOSE c1;

      v_sql_stmt := 04;
      FORALL j IN lb_rowid.FIRST..lb_rowid.LAST
      UPDATE msd_st_cs_data
      SET  st_transaction_id = cs_st_data_id,
           last_update_date  = lv_current_date,
           last_updated_by   = lv_current_user,
           creation_date     = lv_current_date,
           created_by        = lv_current_user
      WHERE  rowid           = lb_rowid(j);

/*
Earlier sql statement :
UPDATE msd_st_cs_data
      SET  st_transaction_id = msd_st_cs_data_s.NEXTVAL,
           cs_st_data_id     = msd_st_cs_data_s.CURRVAL,  -- SEQUENCE
           last_update_date  = lv_current_date,
           last_updated_by   = lv_current_user,
           creation_date     = lv_current_date,
           created_by        = lv_current_user
      WHERE  rowid           = lb_rowid(j);
*/
     -- Derive the CS_DEFINITION_ID from msd_cs_definitions

    v_sql_stmt := 05;
    lv_sql_stmt :=
    '   UPDATE  msd_st_cs_data  mscd'
    ||' SET     cs_definition_id = NVL(( SELECT cs_definition_id'
    ||'         FROM   msd_cs_definitions mcd'
    ||'         WHERE mscd.cs_definition_name = mcd.name),'||NULL_VALUE||')'
    ||' WHERE  process_flag            = '||G_IN_PROCESS
    ||' AND    batch_id                = :lv_batch_id'
    ||' AND    sr_instance_code        = :p_instance_code';

      IF lv_debug THEN
        msc_st_util.log_message(lv_sql_stmt);
      END IF;
      EXECUTE IMMEDIATE lv_sql_stmt
              USING     lv_batch_id,
                        p_instance_code;


     -- Set the message

      lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_INVALID_VALUE',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'CS_DEFINITION_NAME');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

     -- Error out the records if the cs_definition_id is still null
     -- This indicates that this custom stream has not been defined via UI

      v_sql_stmt := 06;
      lv_sql_stmt :=
      'UPDATE    msd_st_cs_data'
      ||' SET    process_flag            = '||G_ERROR_FLG||','
      ||'        error_text      = '||''''||lv_message_text||''''
      ||' WHERE  NVL(cs_definition_id,'||NULL_VALUE||') = '||NULL_VALUE
      ||' AND    batch_id                = :lv_batch_id'
      ||' AND    process_flag            = '||G_IN_PROCESS
      ||' AND    sr_instance_code        = :p_instance_code';

      IF lv_debug THEN
        msc_st_util.log_message(lv_sql_stmt);
      END IF;
      EXECUTE IMMEDIATE lv_sql_stmt
              USING     lv_batch_id,
                        p_instance_code;


       -- This code is added for fix 3730302.
       -- Updating the two date columns REQUESTED_DATE and SCHEDULED_DATE for the 3 CMRO streams.
       /*
       UPDATE    msd_st_cs_data
       SET attribute_45 = attribute_43
       WHERE cs_definition_name IN ('MSD_CMRO_FIRM_MTL_REQUIREMENT','MSD_CMRO_UNPLANNED_HISTORY','MSD_CMRO_PLANNED_HISTORY')
       AND batch_id         =  lv_batch_id
       AND process_flag     =  G_IN_PROCESS
       AND sr_instance_code = p_instance_code;
*/

      -- Set the message
      lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_COL_VAL_NULL',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'CS_NAME');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

      v_sql_stmt := 07;
      lv_sql_stmt :=
      'UPDATE    msd_st_cs_data'
      ||' SET    process_flag            = '||G_ERROR_FLG||','
      ||'        error_text      = '||''''||lv_message_text||''''
      ||' WHERE  NVL(cs_name, '||''''||NULL_CHAR||''''||') '
      ||'        =               '||''''||NULL_CHAR||''''
      ||' AND    batch_id               = :lv_batch_id'
      ||' AND    process_flag            = '||G_IN_PROCESS
      ||' AND    sr_instance_code       = :p_instance_code';

      IF lv_debug THEN
        msc_st_util.log_message(lv_sql_stmt);
      END IF;
      EXECUTE IMMEDIATE lv_sql_stmt
              USING     lv_batch_id,
                        p_instance_code;




      -- Set the  message

        lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_INVALID_VALUE',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'PRODUCT LEVEL');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

    -- Derive the level_id , error out if invalid level name
    --attribute_2 (prd_level_id)

      lv_return := MSC_ST_UTIL.DERIVE_LEVEL_ID
                    (p_table_name     => 'MSD_ST_CS_DATA',
                     p_level_name_col => 'ATTRIBUTE_2_VAL',
                     p_level_id_col   => 'ATTRIBUTE_2',
                     p_severity      => G_SEV3_ERROR ,
                     p_message_text    => lv_message_text,
                     p_instance_code  => p_instance_code,
                     p_batch_id       => lv_batch_id,
                     p_error_text     => lv_error_text);

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

      -- set the message, attribute_4 is invalid

        lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_INVALID_VALUE',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'PRODUCT LEVEL VALUE');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

     -- Derive SR_LEVEL_PK - attribute_3 from msd_level_values
     -- or msd_st_level_values

       lv_return := MSC_ST_UTIL.DERIVE_LEVEL_PK
                    (p_table_name      => 'MSD_ST_CS_DATA',
                     p_level_val_col   => 'ATTRIBUTE_4',
                     p_level_name_col  => 'ATTRIBUTE_2_VAL',
                     p_level_pk_col    =>  'ATTRIBUTE_3',
                     p_instance_code   => p_instance_code,
                     p_instance_id     => p_instance_id,
                     p_message_text    => lv_message_text,
                     p_batch_id        => lv_batch_id,
                     p_error_text      => lv_error_text);

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

       -- Set the  message

        lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_INVALID_VALUE',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'GEOGRAPHY LEVEL');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

    -- Derive the level_id , error out if invalid level name
    -- Attribute_6 (geo_level_id)

      lv_return := MSC_ST_UTIL.DERIVE_LEVEL_ID
                    (p_table_name     => 'MSD_ST_CS_DATA',
                     p_level_name_col => 'ATTRIBUTE_6_VAL',
                     p_level_id_col   => 'ATTRIBUTE_6',
                     p_severity       => G_SEV3_ERROR ,
                     p_message_text    => lv_message_text,
                     p_instance_code  => p_instance_code,
                     p_batch_id       => lv_batch_id,
                     p_error_text     => lv_error_text);

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

      -- set the message, attribute_8 is invalid

        lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_INVALID_VALUE',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'GEOGRAPHY LEVEL VALUE');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

     -- Derive SR_LEVEL_PK - attribute_7 from msd_level_values
     -- or msd_st_level_values

       lv_return := MSC_ST_UTIL.DERIVE_LEVEL_PK
                    (p_table_name      => 'MSD_ST_CS_DATA',
                     p_level_val_col   => 'ATTRIBUTE_8',
                     p_level_name_col  => 'ATTRIBUTE_6_VAL',
                     p_level_pk_col    => 'ATTRIBUTE_7',
                     p_instance_code   => p_instance_code,
                     p_instance_id     => p_instance_id,
                     p_message_text    => lv_message_text,
                     p_batch_id        => lv_batch_id,
                     p_error_text      => lv_error_text);

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;


      -- Set the  message
        lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_INVALID_VALUE',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'SHIP FROM LOCATION LEVEL');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

    -- Derive the level_id , error out if invalid level name
    -- attribute_10 (org_level_id)

      lv_return := MSC_ST_UTIL.DERIVE_LEVEL_ID
                    (p_table_name     => 'MSD_ST_CS_DATA',
                     p_level_name_col => 'ATTRIBUTE_10_VAL',
                     p_level_id_col   => 'ATTRIBUTE_10',
                     p_severity       => G_SEV3_ERROR ,
                     p_message_text    => lv_message_text,
                     p_instance_code  => p_instance_code,
                     p_batch_id       => lv_batch_id,
                     p_error_text     => lv_error_text);

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

      -- set the message, attribute_12 is invalid

        lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_INVALID_VALUE',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'SHIP FROM LOCATION LEVEL VALUE');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

     -- Derive SR_LEVEL_PK - attribute_11 from msd_level_values
     -- or msd_st_level_values

       lv_return := MSC_ST_UTIL.DERIVE_LEVEL_PK
                    (p_table_name      => 'MSD_ST_CS_DATA',
                     p_level_val_col   => 'ATTRIBUTE_12',
                     p_level_name_col    => 'ATTRIBUTE_10_VAL',
                     p_level_pk_col => 'ATTRIBUTE_11',
                     p_instance_code   => p_instance_code,
                     p_instance_id     => p_instance_id,
                     p_message_text    => lv_message_text,
                     p_batch_id        => lv_batch_id,
                     p_error_text      => lv_error_text);

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

 /*     -- Set the  message
        lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_INVALID_VALUE',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'PARENT ITEM LEVEL');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

    -- Derive the level_id , error out if invalid level name
    --attribute_14 (cus_level_id)

      lv_return := MSC_ST_UTIL.DERIVE_LEVEL_ID
                    (p_table_name     => 'MSD_ST_CS_DATA',
                     p_level_name_col => 'ATTRIBUTE_14_VAL',
                     p_level_id_col   => 'ATTRIBUTE_14',
                     p_severity      => G_SEV3_ERROR ,
                     p_message_text    => lv_message_text,
                     p_instance_code  => p_instance_code,
                     p_batch_id       => lv_batch_id,
                     p_error_text     => lv_error_text);

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;
*/

  v_sql_stmt := 08;
 lv_sql_stmt :=
    '   UPDATE  msd_st_cs_data  mscd'
    ||' SET     attribute_14 = 1'
    ||' WHERE  attribute_16 is not null'
    ||' AND    process_flag            = '||G_IN_PROCESS
    ||' AND    batch_id                = :lv_batch_id'
    ||' AND    sr_instance_code        = :p_instance_code';

      IF lv_debug THEN
        msc_st_util.log_message(lv_sql_stmt);
      END IF;

   EXECUTE IMMEDIATE lv_sql_stmt
              USING     lv_batch_id,
                        p_instance_code;


      -- set the message, attribute_16 is invalid

        lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_INVALID_VALUE',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'PARENT ITEM NAME');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

     -- Derive SR_LEVEL_PK - attribute_15 from msd_level_values
     -- or msd_st_level_values

       lv_return := MSC_ST_UTIL.DERIVE_LEVEL_PK
                    (p_table_name      => 'MSD_ST_CS_DATA',
                     p_level_val_col   => 'ATTRIBUTE_16',
                     p_level_name_col    => 'ATTRIBUTE_14_VAL',
                     p_level_pk_col => 'ATTRIBUTE_15',
                     p_instance_code   => p_instance_code,
                     p_instance_id     => p_instance_id,
                     p_message_text    => lv_message_text,
                     p_batch_id        => lv_batch_id,
                     p_error_text      => lv_error_text);

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;



      -- Set the  message
        lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_INVALID_VALUE',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'SALES REPRESANTATIVE LEVEL');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

    -- Derive the level_id , error out if invalid level name
    --attribute_18 (rep_level_id)

      lv_return := MSC_ST_UTIL.DERIVE_LEVEL_ID
                    (p_table_name     => 'MSD_ST_CS_DATA',
                     p_level_name_col => 'ATTRIBUTE_18_VAL',
                     p_level_id_col   => 'ATTRIBUTE_18',
                     p_severity      => G_SEV3_ERROR ,
                     p_message_text    => lv_message_text,
                     p_instance_code  => p_instance_code,
                     p_batch_id       => lv_batch_id,
                     p_error_text     => lv_error_text);

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;


      -- set the message, attribute_20 is invalid

        lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_INVALID_VALUE',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'SALES REPRESANTATIVE LEVEL VALUE');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

     -- Derive SR_LEVEL_PK - attribute_19 from msd_level_values
     -- or msd_st_level_values

       lv_return := MSC_ST_UTIL.DERIVE_LEVEL_PK
                    (p_table_name      => 'MSD_ST_CS_DATA',
                     p_level_val_col   => 'ATTRIBUTE_20',
                     p_level_name_col    => 'ATTRIBUTE_18_VAL',
                     p_level_pk_col => 'ATTRIBUTE_19',
                     p_instance_code   => p_instance_code,
                     p_instance_id     => p_instance_id,
                     p_message_text    => lv_message_text,
                     p_batch_id        => lv_batch_id,
                     p_error_text      => lv_error_text);

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

      -- Set the  message
        lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_INVALID_VALUE',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'SALES CHANNEL LEVEL');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;


    -- Derive the level_id , error out if invalid level name
    --attribute_22 (chn_level_id)

      lv_return := MSC_ST_UTIL.DERIVE_LEVEL_ID
                    (p_table_name     => 'MSD_ST_CS_DATA',
                     p_level_name_col => 'ATTRIBUTE_22_VAL',
                     p_level_id_col   => 'ATTRIBUTE_22',
                     p_severity      => G_SEV3_ERROR ,
                     p_message_text    => lv_message_text,
                     p_instance_code  => p_instance_code,
                     p_batch_id       => lv_batch_id,
                     p_error_text     => lv_error_text);

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

      -- set the message, attribute_24 is invalid

        lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_INVALID_VALUE',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'SALES CHANNEL LEVEL VALUE');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

     -- Derive SR_LEVEL_PK - attribute_23 from msd_level_values
     -- or msd_st_level_values

       lv_return := MSC_ST_UTIL.DERIVE_LEVEL_PK
                    (p_table_name      => 'MSD_ST_CS_DATA',
                     p_level_val_col   => 'ATTRIBUTE_24',
                     p_level_name_col    => 'ATTRIBUTE_22_VAL',
                     p_level_pk_col => 'ATTRIBUTE_23',
                     p_instance_code   => p_instance_code,
                     p_instance_id     => p_instance_id,
                     p_message_text    => lv_message_text,
                     p_batch_id        => lv_batch_id,
                     p_error_text      => lv_error_text);

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

      -- Set the  message
        lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_INVALID_VALUE',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'USER DEFINED DIMENION 1 LEVEL');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;


    -- Derive the level_id , error out if invalid level name
    --attribute_26 (ud1_level_id)

      lv_return := MSC_ST_UTIL.DERIVE_LEVEL_ID
                    (p_table_name     => 'MSD_ST_CS_DATA',
                     p_level_name_col => 'ATTRIBUTE_26_VAL',
                     p_level_id_col   => 'ATTRIBUTE_26',
                     p_severity      => G_SEV3_ERROR ,
                     p_message_text    => lv_message_text,
                     p_instance_code  => p_instance_code,
                     p_batch_id       => lv_batch_id,
                     p_error_text     => lv_error_text);

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

      -- set the message, attribute_28 is invalid

        lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_INVALID_VALUE',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'USER DEFINED DIMENION 1 LEVEL VALUE');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

     -- Derive SR_LEVEL_PK - attribute_27 from msd_level_values
     -- or msd_st_level_values

       lv_return := MSC_ST_UTIL.DERIVE_LEVEL_PK
                    (p_table_name      => 'MSD_ST_CS_DATA',
                     p_level_val_col   => 'ATTRIBUTE_28',
                     p_level_name_col    => 'ATTRIBUTE_26_VAL',
                     p_level_pk_col => 'ATTRIBUTE_27',
                     p_instance_code   => p_instance_code,
                     p_instance_id     => p_instance_id,
                     p_message_text    => lv_message_text,
                     p_batch_id        => lv_batch_id,
                     p_error_text      => lv_error_text);

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

      -- Set the  message
        lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_INVALID_VALUE',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'USER DEFINED DIMENION 2 LEVEL');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

    -- Derive the level_id , error out if invalid level name
    --attribute_30 (ud2_level_id)

      lv_return := MSC_ST_UTIL.DERIVE_LEVEL_ID
                    (p_table_name     => 'MSD_ST_CS_DATA',
                     p_level_name_col => 'ATTRIBUTE_30_VAL',
                     p_level_id_col   => 'ATTRIBUTE_30',
                     p_severity       => G_SEV3_ERROR,
                     p_message_text   => lv_message_text,
                     p_instance_code  => p_instance_code,
                     p_batch_id       => lv_batch_id,
                     p_error_text     => lv_error_text);

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

      -- set the message, attribute_32 is invalid

        lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_INVALID_VALUE',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'USER DEFINED DIMENION 2 LEVEL VALUE');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

     -- Derive SR_LEVEL_PK - attribute_31 from msd_level_values
     -- or msd_st_level_values

       lv_return := MSC_ST_UTIL.DERIVE_LEVEL_PK
                    (p_table_name      => 'MSD_ST_CS_DATA',
                     p_level_val_col   => 'ATTRIBUTE_32',
                     p_level_name_col    => 'ATTRIBUTE_30_VAL',
                     p_level_pk_col => 'ATTRIBUTE_31',
                     p_instance_code   => p_instance_code,
                     p_instance_id     => p_instance_id,
                     p_message_text    => lv_message_text,
                     p_batch_id        => lv_batch_id,
                     p_error_text      => lv_error_text);

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

-- Demand Class Changes for Custom Stream data starts
       -- Set the  message
        lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_INVALID_VALUE',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'DEMAND CLASS LEVEL');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

    -- Derive the level_id , error out if invalid level name
    -- attribute_50 (demand_class_level_id)

      lv_return := MSC_ST_UTIL.DERIVE_LEVEL_ID
                    (p_table_name     => 'MSD_ST_CS_DATA',
                     p_level_name_col => 'ATTRIBUTE_50_VAL',
                     p_level_id_col   => 'ATTRIBUTE_50',
                     p_severity       => G_SEV3_ERROR ,
                     p_message_text    => lv_message_text,
                     p_instance_code  => p_instance_code,
                     p_batch_id       => lv_batch_id,
                     p_error_text     => lv_error_text);

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

 -- set the message, attribute_52 is invalid

        lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_INVALID_VALUE',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'DEMAND CLASS LEVEL VALUE');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

     -- Derive SR_LEVEL_PK - attribute_51 from msd_level_values
     -- or msd_st_level_values

       lv_return := MSC_ST_UTIL.DERIVE_LEVEL_PK
                    (p_table_name      => 'MSD_ST_CS_DATA',
                     p_level_val_col   => 'ATTRIBUTE_52',
                     p_level_name_col  => 'ATTRIBUTE_50_VAL',
                     p_level_pk_col    => 'ATTRIBUTE_51',
                     p_instance_code   => p_instance_code,
                     p_instance_id     => p_instance_id,
                     p_message_text    => lv_message_text,
                     p_batch_id        => lv_batch_id,
                     p_error_text      => lv_error_text);

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;


 -- Demand Class Changes for Custom Stream data ends

   OPEN instance_type;
      FETCH instance_type into lv_instance_type;
   CLOSE instance_type;


   IF (lv_instance_type = G_INS_OTHER) THEN

     lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_COL_REF_NOT_EXIST',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAMES',
                      p_token_value1      => 'SR_INSTANCE_CODE AND'
                                             ||' INV_ORG AND ITEM AND ITEM.ATO_FORECAST_CONTROL'
                                             ||' AND ITEM.MRP_PLANNING_CODE',
                      p_token2            => 'MASTER_TABLE',
                      p_token_value2      => 'MSC_SYSTEM_ITEMS',
                      p_token3            => 'CHILD_TABLE',
                      p_token_value3      => 'MSD_ST_CS_DATA');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

      -- Validate item-org combination
      v_sql_stmt := 15;

      UPDATE msd_st_cs_data mcd
      SET    process_flag = G_ERROR_FLG,
             error_text   = lv_message_text
      WHERE NOT EXISTS(SELECT 1
                       FROM   msc_st_system_items msi
                       WHERE  msi.sr_instance_id                  = p_instance_id
                       AND    nvl(msi.company_name,lv_my_company) = lv_my_company
                       AND    msi.organization_id                 = mcd.attribute_11
                       AND    msi.item_name                       = mcd.attribute_4
                       AND   ((v_plan_per_profile = 4) OR (msi.ato_forecast_control <> 3))        --forecast control - none
                       AND   ((msi.mrp_planning_code  <> 6 ) OR (msi.pick_components_flag='Y' ))  --Not planned item
                       UNION
                       SELECT 1
                       FROM   msc_system_items mls
                       WHERE  mls.sr_instance_id                  = p_instance_id
                       AND    mls.organization_id                 = mcd.attribute_11
                       AND    mls.item_name                       = mcd.attribute_4
                       AND    mls.plan_id                         = -1
                       AND   ((v_plan_per_profile = 4) OR (mls.ato_forecast_control <> 3))        --forecast control - none
                       AND   ((mls.mrp_planning_code <> 6 ) OR (mls.pick_components_flag='Y' )) ) --Not planned item
      AND    mcd.attribute_2             = 1
      AND    mcd.attribute_10            = 7
      AND    mcd.process_flag            = G_IN_PROCESS
      AND    mcd.sr_instance_code        = p_instance_code
      AND    mcd.batch_id                = p_batch_id;

  END IF;

      --Call to customised validation.
      MSC_CL_PRE_PROCESS_HOOK.ENTITY_VALIDATION
        (ERRBUF         => lv_error_text,
         RETCODE        => lv_return,
         pBatchID       => null,
         pInstanceCode  => p_instance_code,
         pEntityName    => 'MSD_ST_CS_DATA',
         pInstanceID    => p_instance_id);

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

      --Call to customised validation.
      MSC_CL_PRE_PROCESS_HOOK.ENTITY_VALIDATION
        (ERRBUF         => lv_error_text,
         RETCODE        => lv_return,
         pBatchID       => lv_batch_id,
         pInstanceCode  => p_instance_code,
         pEntityName    => 'MSD_ST_CS_DATA',
         pInstanceID    => p_instance_id);

      IF NVL(lv_return,0) <> 0 THEN
        RAISE ex_logging_err;
      END IF;

     -- Set the process flag as Valid and populate instance_id
      lv_return := MSC_ST_UTIL.SET_PROCESS_FLAG
                        (p_table_name     => 'MSD_ST_CS_DATA',
                         p_instance_id    => p_instance_id,
                         p_instance_code  => p_instance_code,
                         p_process_flag   => G_VALID,
                         p_error_text     => lv_error_text,
                         p_batch_id       => lv_batch_id,
                         p_instance_id_col=> 'ATTRIBUTE_1');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

      -- Inserting all the errored out records into MSC_ERRORS:

      lv_return := MSC_ST_UTIL.LOG_ERROR
                   (p_table_name        => 'MSD_ST_CS_DATA',
                    p_instance_code     => p_instance_code,
                    p_row               => lv_column_names,
                    p_severity          => G_SEV_ERROR,
                    p_error_text        => lv_error_text,
                    p_message_text      => NULL,
                    p_batch_id          => lv_batch_id);

    IF(lv_return <> 0) THEN
      msc_st_util.log_message(lv_error_text);
    END IF;
    COMMIT;

    EXCEPTION
     WHEN ex_logging_err THEN
        ROLLBACK;

        ERRBUF := lv_error_text;
        RETCODE := G_WARNING;
        msc_st_util.log_message(lv_error_text);

    WHEN OTHERS THEN
      ROLLBACK;

      lv_error_text    := substr('MSD_CL_PRE_PROCESS.LOAD_CS_DATA'||'('
                       ||v_sql_stmt||')'|| SQLERRM, 1, 240);
      msc_st_util.log_message(lv_error_text);
      ERRBUF := lv_error_text;
      RETCODE := G_WARNING;

  END LOAD_CS_DATA;

  /*==========================================================================+
  | DESCRIPTION  : This function performs the validation and loads the data   |
  |                for business object Price List                             |
  +==========================================================================*/

  PROCEDURE LOAD_PRICE_LIST (ERRBUF          OUT NOCOPY VARCHAR,
                             RETCODE         OUT NOCOPY NUMBER,
                             p_instance_code IN VARCHAR,
                             p_instance_id   IN NUMBER,
                             p_batch_id      IN NUMBER)

  IS
  TYPE RowidTab IS TABLE OF ROWID INDEX BY BINARY_INTEGER;
  lb_rowid          RowidTab;
  lv_sql_stmt       VARCHAR2(4000);
  lv_batch_id       msd_st_price_list.batch_id%TYPE;
  lv_message_text   msc_errors.error_text%TYPE;
  lv_my_company     msc_companies.company_name%TYPE := GET_MY_COMPANY;
  lv_error_text     VARCHAR2(250);
  lv_debug          BOOLEAN   := msc_cl_pre_process.v_debug;
  lv_batch_size     NUMBER    := msc_cl_pre_process.v_batch_size;
  lv_current_user   NUMBER    := msc_cl_pre_process.v_current_user;
  lv_current_date   DATE      := msc_cl_pre_process.v_current_date;
  lv_return         NUMBER := 0;
  ex_logging_err    EXCEPTION;
  lv_column_names   VARCHAR2(5000);

  CURSOR c1(p_batch_id NUMBER)IS
    SELECT rowid
    FROM   msd_st_price_list
    WHERE  process_flag      IN (G_IN_PROCESS,G_ERROR_FLG)
    AND    sr_instance_code = p_instance_code
    AND    batch_id         = p_batch_id;

  CURSOR instance_type IS
   SELECT instance_type
   FROM msc_apps_instances
   WHERE instance_id=p_instance_id;

   lv_instance_type  msc_apps_instances.instance_type%TYPE;

   BEGIN

      lv_batch_id := p_batch_id;

	lv_column_names :=
	  '	SR_INSTANCE_CODE	||''~''||'
	||'	ORGANIZATION_LVL	||''~''||'
	||'	SR_ORGANIZATION_LVL_VAL	||''~''||'
	||'	PRODUCT_LVL		||''~''||'
	||'	SR_PRODUCT_LVL_VAL	||''~''||'
	||'	SALESCHANNEL_LVL	||''~''||'
	||'	SR_SALESCHANNEL_LVL_VAL	||''~''||'
	||'	SALES_REP_LVL		||''~''||'
	||'	SR_SALES_REP_LVL_VAL	||''~''||'
	||'	GEOGRAPHY_LVL		||''~''||'
	||'	SR_GEOGRAPHY_LVL_VAL	||''~''||'
	||'	USER_DEFINED1_LVL	||''~''||'
	||'	SR_USER_DEFINED1_LVL_VAL||''~''||'
	||'	USER_DEFINED2_LVL	||''~''||'
	||'	SR_USER_DEFINED2_LVL_VAL||''~''||'
	||'	PRICE_LIST_NAME		||''~''||'
	||'	START_DATE		||''~''||'
	||'	END_DATE		||''~''||'
	||'	PRICE			||''~''||'
	||'	PRIORITY';

      OPEN  c1(lv_batch_id);
      FETCH c1 BULK COLLECT INTO lb_rowid;
      CLOSE c1;

      v_sql_stmt := 04;
      FORALL j IN lb_rowid.FIRST..lb_rowid.LAST
      UPDATE msd_st_price_list
      SET  st_transaction_id = msd_st_price_list_s.NEXTVAL,
           last_update_date  = lv_current_date,
           last_updated_by   = lv_current_user,
           creation_date     = lv_current_date,
           created_by        = lv_current_user
      WHERE  rowid           = lb_rowid(j);


      -- Set the  message

        lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_INVALID_VALUE',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'ORGANIZATION_LVL');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

    -- Derive the org_level_id , error out if invalid level name


      lv_return := MSC_ST_UTIL.DERIVE_LEVEL_ID
                    (p_table_name     => 'MSD_ST_PRICE_LIST',
                     p_level_name_col => 'ORGANIZATION_LVL',
                     p_level_id_col   => 'ORGANIZATION_LVL_ID',
                     p_severity       => G_SEV_ERROR,	-- Against Bug#2413920
                     p_message_text    => lv_message_text,
                     p_instance_code  => p_instance_code,
                     p_batch_id       => lv_batch_id,
                     p_error_text     => lv_error_text);

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

      -- set the message, ORGANIZATION_LVL is invalid

        lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_INVALID_VALUE',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'SR_ORGANIZATION_LVL_VAL');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

     -- Derive SR_ORGANIZATION_LVL_PK

       lv_return := MSC_ST_UTIL.DERIVE_LEVEL_PK
                    (p_table_name      => 'MSD_ST_PRICE_LIST',
                     p_level_val_col   => 'SR_ORGANIZATION_LVL_VAL',
                     p_level_name_col  => 'ORGANIZATION_LVL',
                     p_level_pk_col    => 'SR_ORGANIZATION_LVL_PK',
                     p_instance_code   => p_instance_code,
                     p_instance_id     => p_instance_id,
                     p_message_text    => lv_message_text,
                     p_batch_id        => lv_batch_id,
                     p_severity        => G_SEV_ERROR,	-- Against Bug#2413920
                     p_error_text      => lv_error_text);

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;


      -- Set the  message

        lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_INVALID_VALUE',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'PRODUCT_LVL');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

    -- Derive the PRODUCT_LVL_ID, error out if invalid level name


      lv_return := MSC_ST_UTIL.DERIVE_LEVEL_ID
                    (p_table_name     => 'MSD_ST_PRICE_LIST',
                     p_level_name_col => 'PRODUCT_LVL',
                     p_level_id_col   => 'PRODUCT_LVL_ID',
                     p_severity       => G_SEV_ERROR,	-- Against Bug#2413920
                     p_message_text    => lv_message_text,
                     p_instance_code  => p_instance_code,
                     p_batch_id       => lv_batch_id,
                     p_error_text     => lv_error_text);

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

      -- set the message, PRODUCT_LVL is invalid

        lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_INVALID_VALUE',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'SR_PRODUCT_LVL_VAL');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

     -- Derive SR_PRODUCT_LVL_PK

       lv_return := MSC_ST_UTIL.DERIVE_LEVEL_PK
                    (p_table_name      => 'MSD_ST_PRICE_LIST',
                     p_level_val_col   => 'SR_PRODUCT_LVL_VAL',
                     p_level_name_col  => 'PRODUCT_LVL',
                     p_level_pk_col    => 'SR_PRODUCT_LVL_PK',
                     p_instance_code   => p_instance_code,
                     p_instance_id     => p_instance_id,
                     p_message_text    => lv_message_text,
                     p_batch_id        => lv_batch_id,
                     p_severity        => G_SEV_ERROR,	-- Against Bug#2413920
                     p_error_text      => lv_error_text);

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;


      -- Set the  message

        lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_INVALID_VALUE',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'SALESCHANNEL_LVL');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

    -- Derive the SALESCHANNEL_LVL_ID, error out if invalid level name


      lv_return := MSC_ST_UTIL.DERIVE_LEVEL_ID
                    (p_table_name     => 'MSD_ST_PRICE_LIST',
                     p_level_name_col => 'SALESCHANNEL_LVL',
                     p_level_id_col   => 'SALESCHANNEL_LVL_ID',
                     p_severity       => G_SEV_ERROR,	-- Against Bug#2413920
                     p_message_text    => lv_message_text,
                     p_instance_code  => p_instance_code,
                     p_batch_id       => lv_batch_id,
                     p_error_text     => lv_error_text);

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

      -- set the message, SALESCHANNEL_LVL is invalid

        lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_INVALID_VALUE',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'SR_SALESCHANNEL_LVL_VAL');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

     -- Derive SR_SALESCHANNEL_LVL_PK

       lv_return := MSC_ST_UTIL.DERIVE_LEVEL_PK
                    (p_table_name      => 'MSD_ST_PRICE_LIST',
                     p_level_val_col   => 'SR_SALESCHANNEL_LVL_VAL',
                     p_level_name_col  => 'SALESCHANNEL_LVL',
                     p_level_pk_col    => 'SR_SALESCHANNEL_LVL_PK',
                     p_instance_code   => p_instance_code,
                     p_instance_id     => p_instance_id,
                     p_message_text    => lv_message_text,
                     p_batch_id        => lv_batch_id,
                     p_severity        => G_SEV_ERROR,	-- Against Bug#2413920
                     p_error_text      => lv_error_text);

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

      -- Set the  message

        lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_INVALID_VALUE',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'SALES_REP_LVL');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

    -- Derive the SALESREP_LVL_ID, error out if invalid level name


      lv_return := MSC_ST_UTIL.DERIVE_LEVEL_ID
                    (p_table_name     => 'MSD_ST_PRICE_LIST',
                     p_level_name_col => 'SALES_REP_LVL',
                     p_level_id_col   => 'SALES_REP_LVL_ID',
                     p_severity       => G_SEV_ERROR,	-- Against Bug#2413920
                     p_message_text    => lv_message_text,
                     p_instance_code  => p_instance_code,
                     p_batch_id       => lv_batch_id,
                     p_error_text     => lv_error_text);

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

      -- set the message, SALESREP_LVL is invalid

        lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_INVALID_VALUE',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'SR_SALES_REP_LVL_VAL');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

     -- Derive SR_SALESREP_LVL_PK

       lv_return := MSC_ST_UTIL.DERIVE_LEVEL_PK
                    (p_table_name      => 'MSD_ST_PRICE_LIST',
                     p_level_val_col   => 'SR_SALES_REP_LVL_VAL',
                     p_level_name_col  => 'SALES_REP_LVL',
                     p_level_pk_col    => 'SR_SALES_REP_LVL_PK',
                     p_instance_code   => p_instance_code,
                     p_instance_id     => p_instance_id,
                     p_message_text    => lv_message_text,
                     p_batch_id        => lv_batch_id,
                     p_severity        => G_SEV_ERROR,	-- Against Bug#2413920
                     p_error_text      => lv_error_text);

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

      -- Set the  message

        lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_INVALID_VALUE',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'GEOGRAPHY_LVL');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

    -- Derive the GEOGRAPHY_LVL_ID, error out if invalid level name

      lv_return := MSC_ST_UTIL.DERIVE_LEVEL_ID
                    (p_table_name     => 'MSD_ST_PRICE_LIST',
                     p_level_name_col => 'GEOGRAPHY_LVL',
                     p_level_id_col   => 'GEOGRAPHY_LVL_ID',
                     p_severity       => G_SEV_ERROR,	-- Against Bug#2413920
                     p_message_text    => lv_message_text,
                     p_instance_code  => p_instance_code,
                     p_batch_id       => lv_batch_id,
                     p_error_text     => lv_error_text);

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

      -- set the message, GEOGRAPHY_LVL is invalid

        lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_INVALID_VALUE',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'SR_GEOGRAPHY_LVL_VAL');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

     -- Derive SR_GEOGRAPHY_LVL_PK

       lv_return := MSC_ST_UTIL.DERIVE_LEVEL_PK
                    (p_table_name      => 'MSD_ST_PRICE_LIST',
                     p_level_val_col   => 'SR_GEOGRAPHY_LVL_VAL',
                     p_level_name_col  => 'GEOGRAPHY_LVL',
                     p_level_pk_col    => 'SR_GEOGRAPHY_LVL_PK',
                     p_instance_code   => p_instance_code,
                     p_instance_id     => p_instance_id,
                     p_message_text    => lv_message_text,
                     p_batch_id        => lv_batch_id,
                     p_severity        => G_SEV_ERROR,	-- Against Bug#2413920
                     p_error_text      => lv_error_text);

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

      -- Set the  message

        lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_INVALID_VALUE',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'USER_DEFINED1_LVL');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

    -- Derive the USER_DEFINED1_LVL_ID, error out if invalid level name

      lv_return := MSC_ST_UTIL.DERIVE_LEVEL_ID
                    (p_table_name     => 'MSD_ST_PRICE_LIST',
                     p_level_name_col => 'USER_DEFINED1_LVL',
                     p_level_id_col   => 'USER_DEFINED1_LVL_ID',
                     p_severity       => G_SEV3_ERROR ,
                     p_message_text    => lv_message_text,
                     p_instance_code  => p_instance_code,
                     p_batch_id       => lv_batch_id,
                     p_error_text     => lv_error_text);

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;


      -- set the message, USER_DEFINED1_LVL is invalid

        lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_INVALID_VALUE',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'SR_USER_DEFINED1_LVL_VAL');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

     -- Derive SR_USER_DEFINED1_LVL_PK

       lv_return := MSC_ST_UTIL.DERIVE_LEVEL_PK
                    (p_table_name      => 'MSD_ST_PRICE_LIST',
                     p_level_val_col   => 'SR_USER_DEFINED1_LVL_VAL',
                     p_level_name_col  => 'USER_DEFINED1_LVL',
                     p_level_pk_col    => 'SR_USER_DEFINED1_LVL_PK',
                     p_instance_code   => p_instance_code,
                     p_instance_id     => p_instance_id,
                     p_message_text    => lv_message_text,
                     p_batch_id        => lv_batch_id,
                     p_error_text      => lv_error_text);

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

      -- Set the  message

        lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_INVALID_VALUE',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'USER_DEFINED2_LVL');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

    -- Derive the USER_DEFINED2_LVL_ID, error out if invalid level name

      lv_return := MSC_ST_UTIL.DERIVE_LEVEL_ID
                    (p_table_name     => 'MSD_ST_PRICE_LIST',
                     p_level_name_col => 'USER_DEFINED2_LVL',
                     p_level_id_col   => 'USER_DEFINED2_LVL_ID',
                     p_severity       => G_SEV3_ERROR ,
                     p_message_text    => lv_message_text,
                     p_instance_code  => p_instance_code,
                     p_batch_id       => lv_batch_id,
                     p_error_text     => lv_error_text);

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;


      -- set the message, USER_DEFINED2_LVL is invalid

        lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_INVALID_VALUE',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'SR_USER_DEFINED2_LVL_VAL');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

     -- Derive SR_USER_DEFINED2_LVL_PK

       lv_return := MSC_ST_UTIL.DERIVE_LEVEL_PK
                    (p_table_name      => 'MSD_ST_PRICE_LIST',
                     p_level_val_col   => 'SR_USER_DEFINED2_LVL_VAL',
                     p_level_name_col  => 'USER_DEFINED2_LVL',
                     p_level_pk_col    => 'SR_USER_DEFINED2_LVL_PK',
                     p_instance_code   => p_instance_code,
                     p_instance_id     => p_instance_id,
                     p_message_text    => lv_message_text,
                     p_batch_id        => lv_batch_id,
                     p_error_text      => lv_error_text);

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;


  -- Set the  message

        lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_INVALID_VALUE',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'DEMAND_CLASS_LVL');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

    -- Derive the DEMAND_CLASS_LVL_ID, error out if invalid level name

      lv_return := MSC_ST_UTIL.DERIVE_LEVEL_ID
                    (p_table_name     => 'MSD_ST_PRICE_LIST',
                     p_level_name_col => 'DEMAND_CLASS_LVL',
                     p_level_id_col   => 'DEMAND_CLASS_LVL_ID',
                     p_severity       => G_SEV3_ERROR,	-- Against Bug#2413920
                     p_message_text    => lv_message_text,
                     p_instance_code  => p_instance_code,
                     p_batch_id       => lv_batch_id,
                     p_error_text     => lv_error_text);

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

      -- set the message, DEMAND_CLASS_LVL is invalid

        lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_INVALID_VALUE',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'SR_DEMAND_CLASS_LVL_VAL');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

     -- Derive SR_DEMAND_CLASS_LVL_PK

       lv_return := MSC_ST_UTIL.DERIVE_LEVEL_PK
                    (p_table_name      => 'MSD_ST_PRICE_LIST',
                     p_level_val_col   => 'SR_DEMAND_CLASS_LVL_VAL',
                     p_level_name_col  => 'DEMAND_CLASS_LVL',
                     p_level_pk_col    => 'SR_DEMAND_CLASS_LVL_PK',
                     p_instance_code   => p_instance_code,
                     p_instance_id     => p_instance_id,
                     p_message_text    => lv_message_text,
                     p_batch_id        => lv_batch_id,
                     p_severity        => G_SEV3_ERROR,	-- Against Bug#2413920
                     p_error_text      => lv_error_text);

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

-- Price List UOM Change starts
-- Set the  message
  /* Comment Start :The code below  has been commented against Bug# 3796659 */
   /*     lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_INVALID_VALUE',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'PRICE_LIST_UOM');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;



      UPDATE msd_st_price_list mspl
      SET    process_flag = G_ERROR_FLG,
             error_text   = lv_message_text
      WHERE NOT EXISTS(SELECT 1
                       FROM   msc_st_units_of_measure msum
                       --WHERE  msum.sr_instance_id                  = p_instance_id
                       WHERE msum.sr_instance_code                 = p_instance_code
                       AND   msum.process_flag                     = G_VALID
                       AND    msum.uom_code                        = mspl.price_list_uom
                       UNION
                       SELECT 1
                       FROM   msc_units_of_measure mum
                       WHERE  mum.sr_instance_id                  = p_instance_id
                       AND    mum.uom_code                        = mspl.price_list_uom )
      AND    mspl.process_flag           = G_IN_PROCESS
      AND    mspl.sr_instance_code       = p_instance_code
      AND    mspl.batch_id               = p_batch_id;
      */
 /* Comment END :The code above  has been commented against Bug# 3796659 */
-- Price List UOM Change ends

   OPEN instance_type;
      FETCH instance_type into lv_instance_type;
   CLOSE instance_type;

   IF (lv_instance_type = G_INS_OTHER) THEN

     lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_COL_REF_NOT_EXIST',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAMES',
                      p_token_value1      => 'SR_INSTANCE_CODE AND'
                                             ||' INV_ORG AND ITEM AND ITEM.ATO_FORECAST_CONTROL'
                                             ||' AND ITEM.MRP_PLANNING_CODE',
                      p_token2            => 'MASTER_TABLE',
                      p_token_value2      => 'MSC_SYSTEM_ITEMS',
                      p_token3            => 'CHILD_TABLE',
                      p_token_value3      => 'MSD_ST_PRICE_LIST');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

      -- Validate item-org combination
      v_sql_stmt := 15;

      UPDATE msd_st_price_list mpl
      SET    process_flag = G_ERROR_FLG,
             error_text   = lv_message_text
      WHERE NOT EXISTS(SELECT 1
                       FROM   msc_st_system_items msi
                       WHERE  msi.sr_instance_id                  = p_instance_id
                       AND    nvl(msi.company_name,lv_my_company) = lv_my_company
                       AND    msi.organization_id                 = mpl.sr_organization_lvl_pk
                       AND    msi.item_name                       = mpl.sr_product_lvl_val
                       AND   ((v_plan_per_profile = 4) OR (msi.ato_forecast_control <> 3))        --forecast control - none
                       AND   ((msi.mrp_planning_code  <> 6 ) OR (msi.pick_components_flag='Y' ))  --Not planned item
                       UNION
                       SELECT 1
                       FROM   msc_system_items mls
                       WHERE  mls.sr_instance_id                  = p_instance_id
                       AND    mls.organization_id                 = mpl.sr_organization_lvl_pk
                       AND    mls.item_name                       = mpl.sr_product_lvl_val
                       AND    mls.plan_id                         = -1
                       AND   ((v_plan_per_profile = 4) OR (mls.ato_forecast_control <> 3))        --forecast control - none
                       AND   ((mls.mrp_planning_code <> 6 ) OR (mls.pick_components_flag='Y' )) ) --Not planned item
      AND    mpl.product_lvl_id          = 1
      AND    mpl.organization_lvl_id     = 7
      AND    mpl.process_flag            = G_IN_PROCESS
      AND    mpl.sr_instance_code        = p_instance_code
      AND    mpl.batch_id                = p_batch_id;

   END IF;

      --Call to customised validation.
      MSC_CL_PRE_PROCESS_HOOK.ENTITY_VALIDATION
        (ERRBUF         => lv_error_text,
         RETCODE        => lv_return,
         pBatchID       => null,
         pInstanceCode  => p_instance_code,
         pEntityName    => 'MSD_ST_PRICE_LIST',
         pInstanceID    => p_instance_id);

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

     -- Set the process flag as Valid and populate instance_id
      lv_return := MSC_ST_UTIL.SET_PROCESS_FLAG
                        (p_table_name     => 'MSD_ST_PRICE_LIST',
                         p_instance_id    => p_instance_id,
                         p_instance_code  => p_instance_code,
                         p_process_flag   => G_VALID,
                         p_error_text     => lv_error_text,
                         p_batch_id       => lv_batch_id,
                         p_instance_id_col=> 'INSTANCE');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

     -- Inserting all the errored out records into MSC_ERRORS:

      lv_return := MSC_ST_UTIL.LOG_ERROR
                   (p_table_name        => 'MSD_ST_PRICE_LIST',
                    p_instance_code     => p_instance_code,
                    p_row               => lv_column_names,
                    p_severity          => G_SEV_ERROR,
                    p_error_text        => lv_error_text,
                    p_message_text      => NULL,
                    p_batch_id          => lv_batch_id);

    IF(lv_return <> 0) THEN
      msc_st_util.log_message(lv_error_text);
    END IF;
    COMMIT;

    EXCEPTION
      WHEN ex_logging_err THEN
        ROLLBACK;

        ERRBUF := lv_error_text;
        RETCODE := G_WARNING;
        msc_st_util.log_message(lv_error_text);

    WHEN OTHERS THEN
      ROLLBACK;

      lv_error_text    := substr('MSD_CL_PRE_PROCESS.LOAD_PRICE_LIST'||'('
                       ||v_sql_stmt||')'|| SQLERRM, 1, 240);
      msc_st_util.log_message(lv_error_text);
      ERRBUF := lv_error_text;
      RETCODE := G_WARNING;

  END LOAD_PRICE_LIST;

   /*==========================================================================+
  | DESCRIPTION  : This function performs the validation and loads the data   |
  |                for business object UOM conversion                         |
  +==========================================================================*/

  PROCEDURE LOAD_UOM_CONV (ERRBUF          OUT NOCOPY VARCHAR,
                           RETCODE         OUT NOCOPY NUMBER,
                           p_instance_code IN VARCHAR,
                           p_instance_id   IN NUMBER,
                           p_batch_id      IN NUMBER)

  IS
  TYPE RowidTab IS TABLE OF ROWID INDEX BY BINARY_INTEGER;
  lb_rowid          RowidTab;
  lv_sql_stmt       VARCHAR2(4000);
  lv_batch_id       msd_st_uom_conversions.batch_id%TYPE;
  lv_message_text   msc_errors.error_text%TYPE;
  lv_error_text     VARCHAR2(250);
  lv_debug          BOOLEAN   := msc_cl_pre_process.v_debug;
  lv_batch_size     NUMBER    := msc_cl_pre_process.v_batch_size;
  lv_current_user   NUMBER    := msc_cl_pre_process.v_current_user;
  lv_current_date   DATE      := msc_cl_pre_process.v_current_date;
  lv_return         NUMBER := 0;
  ex_logging_err    EXCEPTION;
  lv_column_names   VARCHAR2(5000);

  CURSOR c1(p_batch_id NUMBER)IS
    SELECT rowid
    FROM   msd_st_uom_conversions
    WHERE  process_flag      IN (G_IN_PROCESS,G_ERROR_FLG)
    AND    sr_instance_code = p_instance_code
    AND    batch_id         = p_batch_id;

   BEGIN

      lv_batch_id := p_batch_id;

      lv_column_names :=
	'	SR_INSTANCE_CODE	||''~''||'
	||'	FROM_UOM_CLASS		||''~''||'
	||'	TO_UOM_CLASS		||''~''||'
	||'	FROM_UOM_CODE		||''~''||'
	||'	TO_UOM_CODE		||''~''||'
	||'	BASE_UOM_FLAG		||''~''||'
	||'	CONVERSION_RATE		||''~''||'
	||'	ITEM ';


      OPEN  c1(lv_batch_id);
      FETCH c1 BULK COLLECT INTO lb_rowid;
      CLOSE c1;

      v_sql_stmt := 04;
      FORALL j IN lb_rowid.FIRST..lb_rowid.LAST
      UPDATE msd_st_uom_conversions
      SET  st_transaction_id = msd_st_uom_conversions_s.NEXTVAL,
           last_update_date  = lv_current_date,
           last_updated_by   = lv_current_user,
           creation_date     = lv_current_date,
           created_by        = lv_current_user
      WHERE  rowid           = lb_rowid(j);

     -- set the message

      lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_COL_VAL_NULL',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'FROM_UOM_CLASS OR'
                                             ||' TO_UOM_CLASS OR'
                                             ||' FROM_UOM_CODE OR'
                                             ||' TO _UOM_CODE'
                                             ||' CONVERSION_RATE');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

      -- error out if  from or to uom class is null
      -- error out if  from or to uom code is null
      -- error out if conversion rate is null

      v_sql_stmt := 05;

      lv_sql_stmt :=
      'UPDATE    msd_st_uom_conversions'
      ||' SET    process_flag            = '||G_ERROR_FLG||','
      ||'        error_text      = '||''''||lv_message_text||''''
      ||' WHERE (NVL(from_uom_class, '||''''||NULL_CHAR||''''||') '
      ||'          =                 '||''''||NULL_CHAR||''''
      ||' OR   NVL(to_uom_class, '||''''||NULL_CHAR||''''||') '
      ||'          =             '||''''||NULL_CHAR||''''
      ||' OR   NVL(from_uom_code, '||''''||NULL_CHAR||''''||') '
      ||'          =              '||''''||NULL_CHAR||''''
      ||' OR   NVL(to_uom_code, '||''''||NULL_CHAR||''''||') '
      ||'          =            '||''''||NULL_CHAR||''''
      ||' OR  NVL(conversion_rate,'||NULL_VALUE||') = '||NULL_VALUE||')'
      ||' AND    process_flag            = '||G_IN_PROCESS
      ||' AND    batch_id                = :lv_batch_id'
      ||' AND    sr_instance_code        = :p_instance_code';

      IF lv_debug THEN
        msc_st_util.log_message(lv_sql_stmt);
      END IF;
      EXECUTE IMMEDIATE lv_sql_stmt
              USING     lv_batch_id,
                        p_instance_code;


        -- Set the message
        lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_INVALID_VALUE',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'ITEM');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

     -- Derive sr_item_pk from msd_st_level_values and msd_level_values

       lv_return :=  MSC_ST_UTIL.DERIVE_SR_PK
                       (p_table_name         => 'MSD_ST_UOM_CONVERSIONS',
                        p_column_name        => 'ITEM',
                        p_pk_col_name        => 'SR_ITEM_PK',
                        p_instance_code      => p_instance_code,
                        p_level_id           => 1,
                        p_instance_id        =>  p_instance_id,
                        p_message_text       => lv_message_text,
                        p_batch_id           => lv_batch_id,
                        p_error_text         => lv_error_text);

        IF lv_return <> 0 THEN
            RAISE ex_logging_err;
        END IF;



      --Call to customised validation.
      MSC_CL_PRE_PROCESS_HOOK.ENTITY_VALIDATION
        (ERRBUF         => lv_error_text,
         RETCODE        => lv_return,
         pBatchID       => lv_batch_id,
         pInstanceCode  => p_instance_code,
         pEntityName    => 'MSD_ST_UOM_CONVERSIONS',
         pInstanceID    => p_instance_id);

      IF NVL(lv_return,0) <> 0 THEN
        RAISE ex_logging_err;
      END IF;

     -- Set the process flag as Valid and populate instance_id
      lv_return := MSC_ST_UTIL.SET_PROCESS_FLAG
                        (p_table_name     => 'MSD_ST_UOM_CONVERSIONS',
                         p_instance_id    => p_instance_id,
                         p_instance_code  => p_instance_code,
                         p_process_flag   => G_VALID,
                         p_error_text     => lv_error_text,
                         p_batch_id       => lv_batch_id,
                         p_instance_id_col=> 'INSTANCE');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

      -- Inserting all the errored out records into MSC_ERRORS:

      lv_return := MSC_ST_UTIL.LOG_ERROR
                   (p_table_name        => 'MSD_ST_UOM_CONVERSIONS',
                    p_instance_code     => p_instance_code,
                    p_row               => lv_column_names,
                    p_severity          => G_SEV_ERROR,
                    p_error_text        => lv_error_text,
                    p_message_text      => NULL,
                    p_batch_id          => lv_batch_id);

      IF(lv_return <> 0) THEN
        msc_st_util.log_message(lv_error_text);
      END IF;
      COMMIT;

    EXCEPTION
      WHEN ex_logging_err THEN
        ROLLBACK;

        ERRBUF := lv_error_text;
        RETCODE := G_WARNING;
        msc_st_util.log_message(lv_error_text);

    WHEN OTHERS THEN
      ROLLBACK;

      lv_error_text    := substr('MSD_CL_PRE_PROCESS.LOAD_UOM_CONV '||'('
                       ||v_sql_stmt||')'|| SQLERRM, 1, 240);
      msc_st_util.log_message(lv_error_text);
      ERRBUF := lv_error_text;
      RETCODE := G_WARNING;

  END LOAD_UOM_CONV ;

 /*==========================================================================+
  | DESCRIPTION  : This function performs the validation and loads the data   |
  |                for setup parameters                                       |
  +==========================================================================*/

   PROCEDURE LOAD_SETUP_PARAMETER(ERRBUF          OUT NOCOPY VARCHAR,
                                 RETCODE         OUT NOCOPY NUMBER,
                                 p_instance_code IN VARCHAR,
                                 p_instance_id   IN NUMBER)
   IS
   TYPE RowidTab IS TABLE OF ROWID INDEX BY BINARY_INTEGER;
   lb_rowid          RowidTab;
   lv_sql_stmt       VARCHAR2(4000);
   lv_message_text   msc_errors.error_text%TYPE;
   lv_error_text     VARCHAR2(250);
   lv_return         NUMBER := 0;
   lv_current_user   NUMBER    := msc_cl_pre_process.v_current_user;
   lv_current_date   DATE      := msc_cl_pre_process.v_current_date;
   lv_debug          BOOLEAN   := msc_cl_pre_process.v_debug;
   ex_logging_err    EXCEPTION;
   lv_column_names   VARCHAR2(5000);



  CURSOR c1 IS
    SELECT rowid
    FROM   msd_st_setup_parameters
    WHERE  process_flag      IN (G_IN_PROCESS,G_ERROR_FLG)
    AND    sr_instance_code = p_instance_code ;


   CURSOR c2 IS
    SELECT  instance,
            parameter_name,
            parameter_value
    FROM    msd_st_setup_parameters
    WHERE   instance = p_instance_id ;

  BEGIN

   lv_column_names :=
	'	SR_INSTANCE_CODE	||''~''||'
	||'	PARAMETER_NAME		||''~''||'
	||'	PARAMETER_VALUE	';

      OPEN  c1;
      FETCH c1 BULK COLLECT INTO lb_rowid;
      CLOSE c1;

      v_sql_stmt := 04;
      FORALL j IN lb_rowid.FIRST..lb_rowid.LAST
      UPDATE msd_st_setup_parameters
      SET  st_transaction_id = msd_st_setup_parameters_s.NEXTVAL,
           last_update_date  = lv_current_date,
           last_updated_by   = lv_current_user,
           creation_date     = lv_current_date,
           created_by        = lv_current_user
      WHERE  rowid           = lb_rowid(j);

     -- set the message

      lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_COL_VAL_NULL',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'PARAMETER_NAME OR'
                                             ||' PARAMETER_VALUE');


    -- Parameter value and parameter_name should not be null

      v_sql_stmt := 01;
      lv_sql_stmt :=
      ' UPDATE    msd_st_setup_parameters'
      ||' SET    process_flag            = '||G_ERROR_FLG||','
      ||'        error_text      = '||''''||lv_message_text||''''
      ||' WHERE (NVL(parameter_name, '||''''||NULL_CHAR||''''||') '
      ||'          =                 '||''''||NULL_CHAR||''''
      ||' OR   NVL(parameter_value, '||''''||NULL_CHAR||''''||') '
      ||'          =             '||''''||NULL_CHAR||''''||')'
      ||' AND    process_flag            = '||G_IN_PROCESS
      ||' AND    sr_instance_code        = :p_instance_code';

      IF lv_debug THEN
        msc_st_util.log_message(lv_sql_stmt);
      END IF;
      EXECUTE IMMEDIATE lv_sql_stmt
              USING     p_instance_code;

     -- Set the process flag as Valid and populate instance_id
      lv_return := MSC_ST_UTIL.SET_PROCESS_FLAG
                        (p_table_name     => 'MSD_ST_SETUP_PARAMETERS',
                         p_instance_id    => p_instance_id,
                         p_instance_code  => p_instance_code,
                         p_process_flag   => G_VALID,
                         p_error_text     => lv_error_text,
                         p_instance_id_col=> 'INSTANCE');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;


     -- Update the msd_setup_parameters
    FOR c_rec IN c2 LOOP

    BEGIN

     UPDATE msd_setup_parameters
     SET parameter_value   = c_rec.parameter_value
     WHERE parameter_name  = c_rec.parameter_name
     AND   instance_id     = c_rec.instance ;

   IF  SQL%NOTFOUND THEN

    DELETE FROM msd_setup_parameters
    WHERE PARAMETER_NAME = c_rec.parameter_name;

     INSERT INTO MSD_SETUP_PARAMETERS
       ( INSTANCE_ID,
         PARAMETER_NAME,
         PARAMETER_VALUE )
     VALUES
       ( c_rec.instance,
         c_rec.parameter_name,
         c_rec.parameter_value );
     END IF ;

     DELETE FROM MSD_ST_SETUP_PARAMETERS
     WHERE instance = c_rec.instance
     AND  parameter_name = c_rec.parameter_name
     AND  parameter_value = c_rec.parameter_value;

    EXCEPTION
      WHEN OTHERS THEN
       msc_st_util.log_message(SQLERRM);
     END ;
    END LOOP;

    -- Inserting all the errored out records into MSC_ERRORS:

      lv_return := MSC_ST_UTIL.LOG_ERROR
                   (p_table_name        => 'MSD_ST_SETUP_PARAMETERS',
                    p_instance_code     => p_instance_code,
                    p_row               => lv_column_names,
                    p_severity          => G_SEV_ERROR,
                    p_error_text        => lv_error_text,
                    p_message_text      => NULL);

      IF(lv_return <> 0) THEN
        msc_st_util.log_message(lv_error_text);
      END IF;
      COMMIT;

    EXCEPTION
      WHEN ex_logging_err THEN
        ROLLBACK;

        ERRBUF := lv_error_text;
        RETCODE := G_WARNING;
        msc_st_util.log_message(lv_error_text);

    WHEN OTHERS THEN
      ROLLBACK;

      lv_error_text    := substr('MSD_CL_PRE_PROCESS.LOAD_SETUP_PARAMETER '||'('
                       ||v_sql_stmt||')'|| SQLERRM, 1, 240);
      msc_st_util.log_message(lv_error_text);
      ERRBUF := lv_error_text;
      RETCODE := G_WARNING;

  END LOAD_SETUP_PARAMETER ;

  /*==========================================================================+
  | DESCRIPTION  : This function performs the validation and loads the data   |
  |                for item relationships.                                    |
  +==========================================================================*/
  PROCEDURE LOAD_ITEM_RELATIONSHIP ( p_instance_code IN VARCHAR,
                                     p_instance_id   IN NUMBER )
 IS

 TYPE RowidTab IS TABLE OF ROWID INDEX BY BINARY_INTEGER;

  lb_rowid          RowidTab;
  lv_sql_stmt       VARCHAR2(4000);
  lv_batch_id       msd_st_item_relationships.batch_id%TYPE;
  lv_message_text   msc_errors.error_text%TYPE;
  lv_debug          BOOLEAN   := msc_cl_pre_process.v_debug;
  lv_current_user   NUMBER    := msc_cl_pre_process.v_current_user;
  lv_current_date   DATE      := msc_cl_pre_process.v_current_date;
  lv_batch_size     NUMBER    := msc_cl_pre_process.v_batch_size;
  lv_return         NUMBER := 0;
  lv_error_text     VARCHAR2(250);
  lv_instance_code  VARCHAR2(3);

  ex_logging_err    EXCEPTION;
  lv_column_names   VARCHAR2(5000);



 CURSOR c1(p_batch_id NUMBER)IS
  SELECT rowid
  FROM   msd_st_item_relationships
  WHERE  process_flag      IN (G_IN_PROCESS,G_ERROR_FLG)
  AND    sr_instance_code = p_instance_code
  AND    batch_id         = p_batch_id;

BEGIN
     lv_instance_code := p_instance_code;

     lv_column_names :=
	'       SR_INSTANCE_CODE	||''~''||'
	||'	INVENTORY_ITEM		||''~''||'
	||'	RELATED_ITEM		||''~''||'
	||'	RELATIONSHIP_TYPE ';

    LOOP
      v_sql_stmt := 01;
      SELECT       msd_st_batch_id_s.NEXTVAL
      INTO         lv_batch_id
      FROM         DUAL;

      v_sql_stmt := 02;

      lv_sql_stmt :=
      'UPDATE   msd_st_item_relationships'
      ||' SET   batch_id                       = :lv_batch_id '
      ||' WHERE process_flag  IN ('||G_IN_PROCESS||','||G_ERROR_FLG||')'
      ||' AND   sr_instance_code               = :lv_instance_code'
      ||' AND   NVL(batch_id,'||NULL_VALUE||') = '||NULL_VALUE
      ||' AND   rownum                        <= '||lv_batch_size;

      IF lv_debug THEN
        msc_st_util.log_message(lv_sql_stmt);
      END IF;

      EXECUTE IMMEDIATE  lv_sql_stmt
              USING      lv_batch_id,
                         p_instance_code;

      EXIT WHEN SQL%NOTFOUND ;

      OPEN  c1(lv_batch_id);
      FETCH c1 BULK COLLECT INTO lb_rowid;
      CLOSE c1;

      v_sql_stmt := 03;
      FORALL j IN 1..lb_rowid.COUNT
      UPDATE msd_st_item_relationships
      SET  st_transaction_id = msd_st_item_relationships_s.NEXTVAL,
           last_update_date  = lv_current_date,
           last_updated_by   = lv_current_user,
           creation_date     = lv_current_date,
           created_by        = lv_current_user
      WHERE  rowid           = lb_rowid(j);


       -- Set the message
        lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_INVALID_VALUE',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'INVENTORY_ITEM');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

     -- Derive INVENTORY_ITEM_ID from msd_st_level_values and msd_level_values

       lv_return :=  MSC_ST_UTIL.DERIVE_SR_PK
                       (p_table_name         => 'MSD_ST_ITEM_RELATIONSHIPS',
                        p_column_name        => 'INVENTORY_ITEM',
                        p_pk_col_name        => 'INVENTORY_ITEM_ID',
                        p_level_id           => 1,
                        p_instance_code      => p_instance_code,
                        p_instance_id        => p_instance_id,
                        p_message_text       => lv_message_text,
                        p_batch_id           => lv_batch_id,
                        p_severity           => G_SEV_ERROR,	-- Against Bug#2415379
                        p_error_text         => lv_error_text);

        IF lv_return <> 0 THEN
            RAISE ex_logging_err;
        END IF;

         -- Set the message
        lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_INVALID_VALUE',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'RELATED_ITEM');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

     -- Derive RELATED_ITEM_ID from msd_st_level_values and msd_level_values

       lv_return :=  MSC_ST_UTIL.DERIVE_SR_PK
                       (p_table_name         => 'MSD_ST_ITEM_RELATIONSHIPS',
                        p_column_name        => 'RELATED_ITEM',
                        p_pk_col_name        => 'RELATED_ITEM_ID',
                        p_level_id           => 1,
                        p_instance_code      => p_instance_code,
                        p_instance_id        => p_instance_id,
                        p_message_text       => lv_message_text,
                        p_batch_id           => lv_batch_id,
                        p_severity           => G_SEV_ERROR,	-- Against Bug#2415379
                        p_error_text         => lv_error_text);

        IF lv_return <> 0 THEN
            RAISE ex_logging_err;
        END IF;

    v_sql_stmt := 04;
    lv_sql_Stmt:=
    'UPDATE     msd_st_item_relationships t1'
    ||' SET     t1.relationship_type_id = 8 '                    -- Relationship Type  - Superseded
    ||' WHERE   t1.process_flag              ='|| G_IN_PROCESS
    ||' AND     t1.batch_id                  = :lv_batch_id'
    ||' AND     t1.sr_instance_code          = :p_instance_code';

    IF lv_debug THEN
           msc_st_util.log_message(lv_sql_stmt);
    END IF;

   EXECUTE IMMEDIATE lv_sql_stmt
               USING lv_batch_id,
                     p_instance_code ;


  --Commented the below piece of code, as User will not be entering the Relationship Type via Flat File.
  -- It is assumed that only Relation that exists, is of type - Superseded.

/*
    v_sql_stmt := 04;
    lv_sql_Stmt:=
    'UPDATE     msd_st_item_relationships t1'
    ||' SET     t1.relationship_type_id = ( select lookup_code '
    ||'                                     from mfg_lookups t2 '
    ||'                                     where t1.relationship_type = t2.meaning '
    ||'                                     and t2.lookup_type =''MTL_RELATIONSHIP_TYPES'' )'
    ||' WHERE   t1.process_flag              ='|| G_IN_PROCESS
    ||' AND     t1.batch_id                  = :lv_batch_id'
    ||' AND     t1.sr_instance_code          = :p_instance_code';

    IF lv_debug THEN
           msc_st_util.log_message(lv_sql_stmt);
    END IF;

   EXECUTE IMMEDIATE lv_sql_stmt
               USING lv_batch_id,
                     p_instance_code ;

    -- Set the message
    lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_COL_VAL_NULL',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'RELATIONSHIP_TYPE');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

       --error out records if relationship_type is not valid.
      v_sql_stmt := 05;

    lv_sql_Stmt:=
    'UPDATE     msd_st_item_relationships '
    ||' SET     process_flag              ='||G_ERROR_FLG||','
    ||'         error_text   = '||''''||lv_message_text||''''
    ||' WHERE   NVL(RELATIONSHIP_TYPE_ID,'||NULL_VALUE||')  = '||NULL_VALUE
    ||' AND     process_flag              ='|| G_IN_PROCESS
    ||' AND     batch_id                  = :lv_batch_id'
    ||' AND     sr_instance_code          = :p_instance_code';

    IF lv_debug THEN
           msc_st_util.log_message(lv_sql_stmt);
    END IF;

   EXECUTE IMMEDIATE lv_sql_stmt
               USING lv_batch_id,
                     p_instance_code ;
*/


      --Call to customised validation.
      MSC_CL_PRE_PROCESS_HOOK.ENTITY_VALIDATION
        (ERRBUF         => lv_error_text,
         RETCODE        => lv_return,
         pBatchID       => lv_batch_id,
         pInstanceCode  => p_instance_code,
         pEntityName    => 'MSD_ST_ITEM_RELATIONSHIPS',
         pInstanceID    => p_instance_id);

      IF NVL(lv_return,0) <> 0 THEN
        RAISE ex_logging_err;
      END IF;

       -- Set the process flag as Valid and populate instance_id
      lv_return := MSC_ST_UTIL.SET_PROCESS_FLAG
                        (p_table_name     => 'MSD_ST_ITEM_RELATIONSHIPS',
                         p_instance_id    => p_instance_id,
                         p_instance_code  => p_instance_code,
                         p_process_flag   => G_VALID,
                         p_error_text     => lv_error_text,
                         p_batch_id       => lv_batch_id,
                         p_instance_id_col=> 'INSTANCE_ID');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

   	-- Inserting all the errored out records into MSC_ERRORS:

      lv_return := MSC_ST_UTIL.LOG_ERROR
	                   (p_table_name        => 'MSD_ST_ITEM_RELATIONSHIPS',
	                    p_instance_code     => p_instance_code,
	                    p_row               => lv_column_names,
	                    p_severity          => G_SEV_ERROR,
	                    p_error_text        => lv_error_text,
	                    p_message_text      => NULL,
	                    p_batch_id          => lv_batch_id);

      IF(lv_return <> 0) THEN
	RAISE ex_logging_err;
      END IF;
      COMMIT;

   END LOOP;

EXCEPTION
  WHEN ex_logging_err THEN
        ROLLBACK;

        msc_st_util.log_message(lv_error_text);

     WHEN OTHERS THEN
      ROLLBACK;

      lv_error_text    := substr('LOAD_ITEM_RELATIONSHIP '||'('
                       ||v_sql_stmt||')'|| SQLERRM, 1, 240);
      msc_st_util.log_message(lv_error_text);

END LOAD_ITEM_RELATIONSHIP;

  /*==========================================================================+
  | DESCRIPTION  : This function performs the validation and loads the data   |
  |                for level org associations.                                |
  +==========================================================================*/
  PROCEDURE LOAD_LEVEL_ORG_ASSCNS ( p_instance_code IN VARCHAR,
                                    p_instance_id   IN NUMBER )
  IS

  TYPE RowidTab IS TABLE OF ROWID INDEX BY BINARY_INTEGER;

  lb_rowid          RowidTab;
  lv_sql_stmt       VARCHAR2(4000);
  lv_batch_id       msd_st_level_org_asscns.batch_id%TYPE;
  lv_message_text   msc_errors.error_text%TYPE;
  lv_debug          BOOLEAN   := msc_cl_pre_process.v_debug;
  lv_current_user   NUMBER    := msc_cl_pre_process.v_current_user;
  lv_current_date   DATE      := msc_cl_pre_process.v_current_date;
  lv_batch_size     NUMBER    := msc_cl_pre_process.v_batch_size;
  lv_return         NUMBER := 0;
  lv_error_text     VARCHAR2(250);
  lv_instance_code  VARCHAR2(3);

  ex_logging_err    EXCEPTION;
  lv_column_names   VARCHAR2(5000);

  lv_instance_type  msc_apps_instances.instance_type%TYPE;

  CURSOR instance_type IS
   SELECT instance_type
   FROM msc_apps_instances
   WHERE instance_id=p_instance_id;

 CURSOR c1(p_batch_id NUMBER)IS
  SELECT rowid
  FROM   msd_st_level_org_asscns
  WHERE  process_flag      IN (G_IN_PROCESS,G_ERROR_FLG)
  AND    sr_instance_code = p_instance_code
  AND    batch_id         = p_batch_id;

BEGIN

   lv_instance_code := p_instance_code;

   lv_column_names :=
	'       SR_INSTANCE_CODE	||''~''||'
	||'	LEVEL_NAME		||''~''||'
	||'	LEVEL_VALUE		||''~''||'
	||'	ORG_LEVEL_NAME	        ||''~''||'
	||'	ORG_LEVEL_VALUE ';

  LOOP
      v_sql_stmt := 01;
      SELECT       msd_st_batch_id_s.NEXTVAL
      INTO         lv_batch_id
      FROM         DUAL;

      v_sql_stmt := 02;

      lv_sql_stmt :=
      'UPDATE   msd_st_level_org_asscns'
      ||' SET   batch_id                       = :lv_batch_id '
      ||' WHERE process_flag  IN ('||G_IN_PROCESS||','||G_ERROR_FLG||')'
      ||' AND   sr_instance_code               = :lv_instance_code'
      ||' AND   NVL(batch_id,'||NULL_VALUE||') = '||NULL_VALUE
      ||' AND   rownum                        <= '||lv_batch_size;

      IF lv_debug THEN
        msc_st_util.log_message(lv_sql_stmt);
      END IF;

      EXECUTE IMMEDIATE  lv_sql_stmt
              USING      lv_batch_id,
                         p_instance_code;

      EXIT WHEN SQL%NOTFOUND ;

      OPEN  c1(lv_batch_id);
      FETCH c1 BULK COLLECT INTO lb_rowid;
      CLOSE c1;

      v_sql_stmt := 03;
      FORALL j IN 1..lb_rowid.COUNT
      UPDATE msd_st_level_org_asscns
      SET  st_transaction_id = msd_st_level_org_asscns_s.NEXTVAL,
           last_update_date  = lv_current_date,
           last_updated_by   = lv_current_user,
           creation_date     = lv_current_date,
           created_by        = lv_current_user
      WHERE  rowid           = lb_rowid(j);


      -- Set the  message LEVEL_NAME is invalid
      lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_INVALID_VALUE',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'LEVEL_NAME');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

    -- Derive the level_id , error out if invalid level name
      lv_return := MSC_ST_UTIL.DERIVE_LEVEL_ID
                    (p_table_name     => 'MSD_ST_LEVEL_ORG_ASSCNS',
                     p_level_name_col => 'LEVEL_NAME',
                     p_level_id_col   => 'LEVEL_ID',
                     p_severity      => G_SEV_ERROR ,
                     p_message_text    => lv_message_text,
                     p_instance_code  => p_instance_code,
                     p_batch_id       => lv_batch_id,
                     p_error_text     => lv_error_text);


     -- Set the  message ORG_LEVEL_NAME is invalid
      lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_INVALID_VALUE',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'ORG_LEVEL_NAME');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

    -- Derive the level_id , error out if invalid org level name
      lv_return := MSC_ST_UTIL.DERIVE_LEVEL_ID
                    (p_table_name     => 'MSD_ST_LEVEL_ORG_ASSCNS',
                     p_level_name_col => 'ORG_LEVEL_NAME',
                     p_level_id_col   => 'ORG_LEVEL_ID',
                     p_severity      => G_SEV_ERROR ,
                     p_message_text    => lv_message_text,
                     p_instance_code  => p_instance_code,
                     p_batch_id       => lv_batch_id,
                     p_error_text     => lv_error_text);


      -- Set the message
        lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_INVALID_VALUE',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'LEVEL_NAME AND ORG_LEVEL_NAME');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

      OPEN instance_type;
       FETCH instance_type into lv_instance_type;
      CLOSE instance_type;

      IF (lv_instance_type = G_INS_OTHER) THEN

       --Combinations for Level-Org other than the (Sales rep - OU) and (Ship to Loc - OU) is not valid.
           UPDATE msd_st_level_org_asscns mloa
           SET    process_flag = G_ERROR_FLG,
                  error_text   = lv_message_text
           WHERE  mloa.process_flag               = G_IN_PROCESS
           AND    mloa.sr_instance_code           = p_instance_code
           AND    mloa.batch_id                   = lv_batch_id
           AND  ( mloa.org_level_id <> 8 OR mloa.level_id not in (18,11) );

      ELSE

       --Combinations for Level-Org other than the (Sales rep - OU) , (Ship to Loc - OU) and (Item - Org )is not valid.
           UPDATE msd_st_level_org_asscns mloa
           SET    process_flag = G_ERROR_FLG,
                  error_text   = lv_message_text
           WHERE  mloa.process_flag               = G_IN_PROCESS
           AND    mloa.sr_instance_code           = p_instance_code
           AND    mloa.batch_id                   = lv_batch_id
           AND  ( mloa.org_level_id <> 8 OR mloa.level_id not in (18,11) )
           AND  ( mloa.org_level_id <> 7 OR mloa.level_id <> 1 );


      END IF;

      -- set the message, LEVEL_VALUE is invalid
        lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_INVALID_VALUE',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'LEVEL_VALUE');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

     -- Derive SR_LEVEL_PK from msd_level_values or msd_st_level_values

       lv_return := MSC_ST_UTIL.DERIVE_LEVEL_PK
                    (p_table_name      => 'MSD_ST_LEVEL_ORG_ASSCNS',
                     p_level_val_col   => 'LEVEL_VALUE',
                     p_level_name_col  => 'LEVEL_NAME',
                     p_level_pk_col    =>  'SR_LEVEL_PK',
                     p_instance_code   => p_instance_code,
                     p_instance_id     => p_instance_id,
                     p_message_text    => lv_message_text,
                     p_batch_id        => lv_batch_id,
                     p_error_text      => lv_error_text);

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

      -- set the message, ORG_LEVEL_VALUE is invalid
        lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_INVALID_VALUE',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'ORG_LEVEL_VALUE');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

     -- Derive ORG_SR_LEVEL_PK from msd_level_values or msd_st_level_values

       lv_return := MSC_ST_UTIL.DERIVE_LEVEL_PK
                    (p_table_name      => 'MSD_ST_LEVEL_ORG_ASSCNS',
                     p_level_val_col   => 'ORG_LEVEL_VALUE',
                     p_level_name_col  => 'ORG_LEVEL_NAME',
                     p_level_pk_col    =>  'ORG_SR_LEVEL_PK',
                     p_instance_code   => p_instance_code,
                     p_instance_id     => p_instance_id,
                     p_message_text    => lv_message_text,
                     p_batch_id        => lv_batch_id,
                     p_error_text      => lv_error_text);

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

    --Call to customised validation.
      MSC_CL_PRE_PROCESS_HOOK.ENTITY_VALIDATION
        (ERRBUF         => lv_error_text,
         RETCODE        => lv_return,
         pBatchID       => lv_batch_id,
         pInstanceCode  => p_instance_code,
         pEntityName    => 'MSD_ST_LEVEL_ORG_ASSCNS',
         pInstanceID    => p_instance_id);

      IF NVL(lv_return,0) <> 0 THEN
        RAISE ex_logging_err;
      END IF;

     -- Set the process flag as Valid and populate instance_id
      lv_return := MSC_ST_UTIL.SET_PROCESS_FLAG
                        (p_table_name     => 'MSD_ST_LEVEL_ORG_ASSCNS',
                         p_instance_id    => p_instance_id,
                         p_instance_code  => p_instance_code,
                         p_process_flag   => G_VALID,
                         p_error_text     => lv_error_text,
                         p_batch_id       => lv_batch_id,
                         p_instance_id_col=> 'INSTANCE');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

   	-- Inserting all the errored out records into MSC_ERRORS:

      lv_return := MSC_ST_UTIL.LOG_ERROR
	                   (p_table_name        => 'MSD_ST_LEVEL_ORG_ASSCNS',
	                    p_instance_code     => p_instance_code,
	                    p_row               => lv_column_names,
	                    p_severity          => G_SEV_ERROR,
	                    p_error_text        => lv_error_text,
	                    p_message_text      => NULL,
	                    p_batch_id          => lv_batch_id);

      IF(lv_return <> 0) THEN
	RAISE ex_logging_err;
      END IF;

      COMMIT;

   END LOOP;


  EXCEPTION
    WHEN ex_logging_err THEN
        ROLLBACK;

        msc_st_util.log_message(lv_error_text);

     WHEN OTHERS THEN
      ROLLBACK;

      lv_error_text    := substr('LOAD_LEVEL_ORG_ASSCNS '||'('
                       ||v_sql_stmt||')'|| SQLERRM, 1, 240);
      msc_st_util.log_message(lv_error_text);

  END LOAD_LEVEL_ORG_ASSCNS;

  PROCEDURE LAUNCH_DELETE_DUPLICATES (ERRBUF   OUT NOCOPY VARCHAR2,
                                         RETCODE  OUT NOCOPY NUMBER,
                                         p_instance_id  IN NUMBER)
  IS
  lv_error_text     VARCHAR2(250);
  BEGIN
        v_sql_stmt := 01;
    delete from msd_st_level_values m1
    where rowid<>(select max(rowid)     from msd_st_level_values m2
     where m2.level_id= m1.level_id  and m2.instance = m1.instance
     and m2.sr_level_pk = m1.sr_level_pk    )
        and m1.instance=p_instance_id ;

      msc_st_util.log_message('****no of row deleted*****' || SQL%ROWCOUNT);

      commit ;

    v_sql_stmt := 02;

          delete from msd_st_level_associations m1
          where rowid<> (select max(rowid)
                        from msd_st_level_associations m2
                        where m2.level_id= m1.level_id
                        and m2.instance = m1.instance
                        and m2.sr_level_pk = m1.sr_level_pk
                        and m2.PARENT_LEVEL_ID=m1.PARENT_LEVEL_ID
                        and m2.SR_PARENT_LEVEL_PK = m1.SR_PARENT_LEVEL_PK
                          )
                      and m1.instance=p_instance_id ;

          msc_st_util.log_message('****no of row deleted*****' || SQL%ROWCOUNT);

          commit ;
  EXCEPTION
      WHEN OTHERS THEN
         ROLLBACK;

         lv_error_text    := substr('LAUNCH_DELETE_DUPLICATES '||'('||v_sql_stmt||')'|| SQLERRM, 1, 240);
          msc_st_util.log_message(lv_error_text);
  END LAUNCH_DELETE_DUPLICATES;



 /*==========================================================================+
  | DESCRIPTION  : This procedure launches the Pull Program of DP             |
  +==========================================================================*/

   PROCEDURE  LAUNCH_PULL_PROGRAM(ERRBUF  OUT  NOCOPY VARCHAR2,
                       RETCODE            OUT  NOCOPY NUMBER,
                       p_instance_id      IN   NUMBER,
                       p_request_id       IN   NUMBER,
                       p_launch_lvalue    IN   NUMBER DEFAULT SYS_NO,
                       p_launch_booking   IN   NUMBER DEFAULT SYS_NO,
                       p_launch_shipment  IN   NUMBER DEFAULT SYS_NO,
                       p_launch_forecast  IN   NUMBER DEFAULT SYS_NO,
                       p_launch_time      IN   NUMBER DEFAULT SYS_NO,
                       p_launch_pricing   IN   NUMBER DEFAULT SYS_NO,
                       p_launch_curr_conv IN   NUMBER DEFAULT SYS_NO,
                       p_launch_uom_conv  IN   NUMBER DEFAULT SYS_NO,
                       p_launch_cs_data   IN   NUMBER DEFAULT SYS_NO,
                       p_cs_refresh       IN   NUMBER DEFAULT SYS_NO)
  IS

   CURSOR c1 IS
   SELECT   distinct cs_name,cs_definition_id
   FROM     msd_st_cs_data
   WHERE    attribute_1  = to_char(p_instance_id)
   AND      request_id   = p_request_id; --Bug 3002566

  lv_request_id        NUMBER;
  lv_lval_request_id   NUMBER:= 0;
  lv_cs_refresh        VARCHAR2(10) := 'N';
  ex_launch_fail       EXCEPTION ;
  lv_req_data          VARCHAR2(10);

  BEGIN

   lv_req_data := nvl(fnd_conc_global.request_data,G_NEW_REQUEST);

   -- If "Level Values' is already submitted as a sub-request then concurrent request
   -- would have been submitted for all the entities within this if clause.

  IF lv_req_data <> G_DP_LV_REQ_DATA THEN
   IF (p_launch_lvalue = SYS_YES ) THEN

      lv_request_id := fnd_request.submit_request('MSD', 'MSDPLV', NULL, NULL,TRUE,SYS_NO);

      IF lv_request_id = 0 THEN
        RAISE ex_launch_fail;
      END IF;
      fnd_conc_global.set_req_globals(conc_status => 'PAUSED',
                                      request_data => to_char(G_DP_LV_REQ_DATA));
      lv_req_data := 2;
    END IF;

   IF (p_launch_booking = SYS_YES ) THEN

      lv_request_id := fnd_request.submit_request('MSD', 'MSDPBD', NULL, NULL,FALSE);
      IF lv_request_id = 0 THEN
        RAISE ex_launch_fail;
      END IF;
      commit;
   END IF;

   IF (p_launch_shipment = SYS_YES ) THEN

      lv_request_id := fnd_request.submit_request('MSD', 'MSDPSD', NULL, NULL,FALSE);
      IF lv_request_id = 0 THEN
        RAISE ex_launch_fail;
      END IF;
      commit;
   END IF;


   IF (p_launch_forecast = SYS_YES ) THEN

      lv_request_id := fnd_request.submit_request('MSD', 'MSDPMF', NULL, NULL,FALSE);
      IF lv_request_id = 0 THEN
        RAISE ex_launch_fail;
      END IF;
      commit;
   END IF;

   IF (p_launch_time = SYS_YES ) THEN

      lv_request_id := fnd_request.submit_request('MSD', 'MSDPTD', NULL, NULL,FALSE);
      IF lv_request_id = 0 THEN
        RAISE ex_launch_fail;
      END IF;
      commit;
   END IF;

   IF (p_launch_pricing = SYS_YES ) THEN

      lv_request_id := fnd_request.submit_request('MSD', 'MSDPPD', NULL, NULL,FALSE);
      IF lv_request_id = 0 THEN
        RAISE ex_launch_fail;
      END IF;
      commit;
   END IF;

   IF (p_launch_curr_conv = SYS_YES ) THEN

      lv_request_id := fnd_request.submit_request('MSD', 'MSDPCC', NULL, NULL,FALSE);
      IF lv_request_id = 0 THEN
        RAISE ex_launch_fail;
      END IF;
      commit;
   END IF;

   IF (p_launch_uom_conv = SYS_YES ) THEN

      lv_request_id := fnd_request.submit_request('MSD', 'MSDPUC', NULL, NULL,FALSE);
      IF lv_request_id = 0 THEN
        RAISE ex_launch_fail;
      END IF;
    END IF;

  IF lv_req_data = G_DP_LV_REQ_DATA THEN
   RETURN;
  END IF;
 END IF;

   IF (p_launch_cs_data = SYS_YES) THEN

       IF nvl(p_request_id,-1) < 1 THEN  -- If launched via Flat File Load, check the supplied parameter for CSData Refresh
           IF(p_cs_refresh = 1) THEN
             lv_cs_refresh := 'Y';
           END IF;
       ELSE
             lv_cs_refresh := 'Y';  -- If Launching CS data Pull Program via Self Service in legacy, Launching it with Complete Refresh.(Bug 3419291)
       END IF;

      FOR c_rec IN c1 LOOP

            lv_request_id :=
            fnd_request.submit_request('MSD', 'MSDCSCL', NULL, NULL,FALSE,
                                       'P', 'Y',
                                        c_rec.cs_definition_id,
                                        c_rec.cs_name,
                                        lv_cs_refresh,
                                        p_instance_id,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL );


      END LOOP ;

   END IF;

  -- Only for level values sub-request, monitor needs to wait till the processing of
  -- level values. If the request data value is already set to 'DP Level Values   -- sub-request', it is modified to 'DP custom stream sub-request', so that monitor   -- continues with the processing.

     IF lv_req_data = G_DP_LV_REQ_DATA THEN
        fnd_conc_global.set_req_globals(conc_status => 'RUNNING',
                                        request_data => to_char(G_DP_CS_REQ_DATA));
     END IF;
   EXCEPTION
       WHEN  ex_launch_fail THEN
       FND_MESSAGE.SET_NAME('MSD', 'MSD_PP_LAUNCH_PULL_FAIL');
       ERRBUF := FND_MESSAGE.GET ;
       RETCODE := G_WARNING ;

       WHEN OTHERS THEN
       FND_MESSAGE.SET_NAME('MSD', 'MSD_PP_LAUNCH_PULL_FAIL');
       ERRBUF := FND_MESSAGE.GET;
       RETCODE := G_WARNING ;

  END LAUNCH_PULL_PROGRAM ;


 /*======================================================================================+
  | DESCRIPTION  :  This procedure is just a wrapper procedure for pre-processor monitor |
  ++=====================================================================================*/
     PROCEDURE LAUNCH_MONITOR( ERRBUF                OUT NOCOPY VARCHAR2,
                             RETCODE               OUT NOCOPY NUMBER,
                             p_instance_id         IN  NUMBER,
                             p_timeout             IN  NUMBER DEFAULT 1440,
                             p_batch_size          IN  NUMBER DEFAULT 1000,
                             p_total_worker_num    IN  NUMBER DEFAULT 3,
                             p_ascp_ins_dummy      IN  VARCHAR2 DEFAULT NULL,
                             p_dummy1              IN  VARCHAR2 DEFAULT NULL,
                             p_dummy2              IN  VARCHAR2 DEFAULT NULL,
                             p_cal_enabled         IN  NUMBER DEFAULT SYS_NO,
                             p_dmd_class_enabled   IN  NUMBER DEFAULT SYS_YES,
                             p_tp_enabled          IN  NUMBER DEFAULT SYS_YES,
                             p_list_price_enabled  IN  NUMBER DEFAULT SYS_NO,
                             p_ctg_enabled         IN  NUMBER DEFAULT SYS_YES,
                             p_item_enabled        IN  NUMBER DEFAULT SYS_YES,
                             p_item_cat_enabled    IN  NUMBER DEFAULT SYS_YES,
                             p_rollup_dummy        IN  VARCHAR2 DEFAULT NULL,
                             p_item_rollup         IN  NUMBER DEFAULT SYS_YES,
                             p_bom_enabled         IN  NUMBER DEFAULT SYS_YES,
                             p_uom_enabled         IN  NUMBER DEFAULT SYS_YES,
                             p_uom_conv_enabled    IN  NUMBER DEFAULT SYS_NO ,
                             p_curr_conv_enabled   IN  NUMBER DEFAULT SYS_NO,
                             p_setup_enabled       IN  NUMBER DEFAULT SYS_NO,
                             p_fiscal_cal_enabled  IN  NUMBER DEFAULT SYS_NO,
                             p_comp_cal_enabled    IN  NUMBER DEFAULT SYS_NO,
                             p_level_value_enabled IN  NUMBER DEFAULT SYS_NO,
                             p_level_assoc_enabled IN  NUMBER DEFAULT SYS_NO,
                             p_booking_enabled     IN  NUMBER DEFAULT SYS_NO,
                             p_shipment_enabled    IN  NUMBER DEFAULT SYS_NO,
                             p_mfg_fct_enabled     IN  NUMBER DEFAULT SYS_NO,
                             p_cs_data_enabled     IN  NUMBER DEFAULT SYS_NO,
                             p_cs_dummy            IN  VARCHAR2 DEFAULT NULL,
                             p_cs_refresh          IN  NUMBER DEFAULT SYS_NO,
                             p_parent_request_id   IN  NUMBER DEFAULT -1,
                             p_calling_module      IN  NUMBER DEFAULT G_DP)

    IS
        lv_errbuf                   varchar2(4000):='';
        lv_retcode                  number;



    BEGIN

         MSC_CL_PRE_PROCESS.LAUNCH_MONITOR(
                             ERRBUF                =>    lv_errbuf,
                             RETCODE               =>    lv_retcode,
                             p_instance_id         =>    p_instance_id ,
                             p_timeout             =>    p_timeout ,
                             p_batch_size          =>    p_batch_size ,
                             p_total_worker_num    =>    p_total_worker_num ,
                             p_cal_enabled         =>    p_cal_enabled ,
                             p_dmd_class_enabled   =>    p_dmd_class_enabled ,
                             p_tp_enabled          =>    p_tp_enabled ,
                             p_ctg_enabled         =>    p_ctg_enabled ,
                             p_item_enabled        =>    p_item_enabled ,
                             p_item_cat_enabled    =>    p_item_cat_enabled ,
                             p_item_rollup         =>    p_item_rollup ,
                             p_bom_enabled         =>    p_bom_enabled ,
                             p_uom_enabled         =>    p_uom_enabled ,
                             p_uom_conv_enabled    =>    p_uom_conv_enabled ,
                             p_curr_conv_enabled   =>    p_curr_conv_enabled ,
                             p_setup_enabled       =>    p_setup_enabled ,
                             p_fiscal_cal_enabled  =>    p_fiscal_cal_enabled ,
                             p_comp_cal_enabled  =>    p_comp_cal_enabled ,
                             p_level_value_enabled =>    p_level_value_enabled ,
                             p_level_assoc_enabled =>    p_level_assoc_enabled ,
                             p_booking_enabled     =>    p_booking_enabled ,
                             p_shipment_enabled    =>    p_shipment_enabled ,
                             p_mfg_fct_enabled     =>    p_mfg_fct_enabled ,
                             p_list_price_enabled  =>    p_list_price_enabled ,
                             p_cs_data_enabled     =>    p_cs_data_enabled ,
                             p_cs_refresh          =>    p_cs_refresh ,
                             p_parent_request_id   =>    p_parent_request_id ,
                             p_calling_module      =>    p_calling_module);



       ERRBUF  := lv_errbuf;
       RETCODE := lv_retcode;



    END;

 END MSD_CL_PRE_PROCESS;

/
