--------------------------------------------------------
--  DDL for Package Body MSC_CL_RPO_PRE_PROCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_CL_RPO_PRE_PROCESS" AS
/* $Header: MSCRPOLB.pls 120.4.12010000.2 2010/04/15 09:21:37 vsiyer ship $ */

PROCEDURE LOAD_IRO_SUPPLY IS
  TYPE RowidTab IS TABLE OF ROWID INDEX BY BINARY_INTEGER;
  lb_rowid           RowidTab;
  lv_return          NUMBER;
  lv_error_text      VARCHAR2(250);
  lv_where_str       VARCHAR2(5000);
  lv_sql_stmt        VARCHAR2(5000);
  lv_column_names    VARCHAR2(5000);
  lv_batch_id        msc_st_supplies.batch_id%TYPE;
  lv_message_text    msc_errors.error_text%TYPE;

  ex_logging_err     EXCEPTION;

  CURSOR    c1(p_batch_id NUMBER) IS
    SELECT  rowid
    FROM    msc_st_supplies
    WHERE   process_flag     IN (MSC_CL_PRE_PROCESS.G_IN_PROCESS)
    AND     batch_id         = p_batch_id
    AND     sr_instance_code = MSC_CL_PRE_PROCESS.v_instance_code;

   CURSOR c2(p_batch_id NUMBER) IS
    SELECT rowid
    FROM   msc_st_supplies
    WHERE  NVL(disposition_id,MSC_CL_PRE_PROCESS.NULL_VALUE)   = MSC_CL_PRE_PROCESS.NULL_VALUE
    AND    order_type          =75
    AND    deleted_flag                     = MSC_CL_PRE_PROCESS.SYS_NO
    AND    process_flag                     = MSC_CL_PRE_PROCESS.G_IN_PROCESS
    AND    NVL(batch_id,MSC_CL_PRE_PROCESS.NULL_VALUE)         =p_batch_id
    AND    sr_instance_code                 = MSC_CL_PRE_PROCESS.v_instance_code;

 BEGIN


    lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                 (p_app_short_name    => 'MSC',
                  p_error_code        => 'MSC_PP_DUP_REC_FOR_XML',
                  p_message_text      => lv_message_text,
                  p_error_text        => lv_error_text);

    IF lv_return <> 0 THEN
      RAISE ex_logging_err;
    END IF;


    --Duplicate records check for the records whose source is XML
    MSC_CL_PRE_PROCESS.v_sql_stmt := 01;
    lv_sql_stmt :=
    ' UPDATE   msc_st_supplies mss1'
    ||' SET    process_flag = '||MSC_CL_PRE_PROCESS.G_ERROR_FLG||','
    ||'        error_text   = '||''''||lv_message_text||''''
    ||' WHERE  message_id <  (SELECT MAX(message_id)'
    ||'        FROM  msc_st_supplies mss2'
    ||'        WHERE mss2.sr_instance_code  = mss1.sr_instance_code'
    ||'        AND     mss2.repair_number = mss1.repair_number '
    ||'        AND    mss2.order_type    = mss1.order_type'
    ||'        AND    mss2.organization_code = mss1.organization_code'
    ||'        AND   mss2.process_flag = '||MSC_CL_PRE_PROCESS.G_IN_PROCESS
    ||'        AND   NVL(mss2.message_id,'||MSC_CL_PRE_PROCESS.NULL_VALUE||') ='||MSC_CL_PRE_PROCESS.NULL_VALUE||')'
    ||' AND     mss1.order_type    IN (75)'
    ||' AND     mss1.process_flag     = '||MSC_CL_PRE_PROCESS.G_IN_PROCESS
    ||' AND     mss1.sr_instance_code = :v_instance_code'
    ||' AND     NVL(mss1.message_id,'||MSC_CL_PRE_PROCESS.NULL_VALUE||') = '||MSC_CL_PRE_PROCESS.NULL_VALUE;




    IF MSC_CL_PRE_PROCESS.V_DEBUG THEN
      msc_st_util.log_message(lv_sql_stmt);
    END IF;

    EXECUTE IMMEDIATE lv_sql_stmt
            USING     MSC_CL_PRE_PROCESS.v_instance_code;

   lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                 (p_app_short_name    => 'MSC',
                  p_error_code        => 'MSC_PP_DUP_REC_FOR_BATCH_LOAD',
                  p_message_text      => lv_message_text,
                  p_error_text        => lv_error_text);

    IF lv_return <> 0 THEN
      RAISE ex_logging_err;
    END IF;

    --Duplicate records check for the records whose source is other than XML
    --Different SQL is used because in XML we can identify the latest records
    --whereas in batch load we cannot.
    MSC_CL_PRE_PROCESS.v_sql_stmt := 02;
    lv_sql_stmt :=
    'UPDATE  msc_st_supplies mss1 '
    ||' SET     process_flag  = '||MSC_CL_PRE_PROCESS.G_ERROR_FLG||','
    ||'         error_text   = '||''''||lv_message_text||''''
    ||' WHERE   EXISTS( SELECT 1 '
    ||'         FROM   msc_st_supplies mss2'
    ||'         WHERE  mss2.sr_instance_code  = mss1.sr_instance_code'
    ||'         AND    mss2.repair_number     = mss1.repair_number '
    ||'         AND    mss2.order_type        = mss1.order_type'
    ||'         AND    mss2.process_flag      = '||MSC_CL_PRE_PROCESS.G_IN_PROCESS
    ||'         AND    mss2.organization_code = mss1.organization_code'
    ||'         AND    NVL(mss2.message_id,'||MSC_CL_PRE_PROCESS.NULL_VALUE||') = '||MSC_CL_PRE_PROCESS.NULL_VALUE
    ||'         GROUP BY sr_instance_code,repair_number,organization_code, order_type '
    ||'         HAVING COUNT(*) > 1)'
    ||' AND     mss1.order_type    IN (75)'
    ||' AND     mss1.process_flag     = '||MSC_CL_PRE_PROCESS.G_IN_PROCESS
    ||' AND     mss1.sr_instance_code = :v_instance_code'
    ||' AND     NVL(mss1.message_id,'||MSC_CL_PRE_PROCESS.NULL_VALUE||') = '||MSC_CL_PRE_PROCESS.NULL_VALUE;

    IF MSC_CL_PRE_PROCESS.V_DEBUG THEN
      msc_st_util.log_message(lv_sql_stmt);
    END IF;

    EXECUTE IMMEDIATE lv_sql_stmt
            USING     MSC_CL_PRE_PROCESS.v_instance_code;

    lv_column_names :=
    'ITEM_NAME                ||''~''||'
    ||'ORGANIZATION_CODE      ||''~''||'
    ||'NEW_SCHEDULE_DATE      ||''~''||'
    ||'SR_INSTANCE_CODE       ||''~''||'
    ||'REVISION               ||''~''||'
    ||'NEW_ORDER_QUANTITY     ||''~''||'
    ||'PROJECT_NUMBER         ||''~''||'
    ||'TASK_NUMBER            ||''~''||'
    ||'DELETED_FLAG           ||''~''||'
    ||'UOM_CODE               ||''~''||'
    ||'CUSTOMER_PRODUCT_ID    ||''~''||'
    ||'SR_REPAIR_TYPE_ID      ||''~''||'
    ||'RO_STATUS_CODE         ||''~''||'
    ||'ASSET_SERIAL_NUMBER    ||''~''||'
    ||'SR_REPAIR_GROUP_ID     ||''~''||'
    ||'SCHEDULE_PRIORITY      ||''~''||'
    ||'RO_CREATION_DATE       ||''~''||'
    ||'REPAIR_LEAD_TIME';


    LOOP
      MSC_CL_PRE_PROCESS.v_sql_stmt := 03;
      SELECT msc_st_batch_id_s.NEXTVAL
      INTO   lv_batch_id
      FROM   dual;

      MSC_CL_PRE_PROCESS.v_sql_stmt := 04;
      lv_sql_stmt :=
      ' UPDATE   msc_st_supplies '
      ||' SET    batch_id  = :lv_batch_id'
      ||' WHERE  process_flag  IN ('||MSC_CL_PRE_PROCESS.G_IN_PROCESS||')'
      ||' AND    order_type IN (75)'
      ||' AND    sr_instance_code               = :v_instance_code'
      ||' AND    NVL(batch_id,'||MSC_CL_PRE_PROCESS.NULL_VALUE||') = '||MSC_CL_PRE_PROCESS.NULL_VALUE
      ||' AND    rownum                        <= '||MSC_CL_PRE_PROCESS.v_batch_size;


      IF MSC_CL_PRE_PROCESS.V_DEBUG THEN
        msc_st_util.log_message(lv_sql_stmt);
      END IF;

      EXECUTE IMMEDIATE lv_sql_stmt
              USING     lv_batch_id,
                        MSC_CL_PRE_PROCESS.v_instance_code;

      EXIT WHEN SQL%NOTFOUND;

      OPEN c1(lv_batch_id);
      FETCH c1 BULK COLLECT INTO lb_rowid;
      CLOSE c1;

      MSC_CL_PRE_PROCESS.v_sql_stmt := 05;
      FORALL j IN lb_rowid.FIRST..lb_rowid.LAST
      UPDATE msc_st_supplies
      SET    st_transaction_id   = msc_st_supplies_s.NEXTVAL,
             refresh_id          = MSC_CL_PRE_PROCESS.v_refresh_id,
             last_update_date    = MSC_CL_PRE_PROCESS.v_current_date,
             last_updated_by     = MSC_CL_PRE_PROCESS.v_current_user,
             creation_date       = MSC_CL_PRE_PROCESS.v_current_date,
             created_by          = MSC_CL_PRE_PROCESS.v_current_user
      WHERE  rowid           = lb_rowid(j);

      -- set the error message

      lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_INVALID_COL_VALUE',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'DELETED_FLAG',
                      p_token2            => 'DEFAULT_VALUE',
                      p_token_value2      => MSC_CL_PRE_PROCESS.SYS_NO);

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

      lv_where_str :=
      ' AND NVL(deleted_flag,'||MSC_CL_PRE_PROCESS.NULL_VALUE||') '
      ||' NOT IN(1,2)';
      --Log a warning for those records where the deleted_flag has a value other
      --than SYS_NO
      lv_return := MSC_ST_UTIL.LOG_ERROR
                     (p_table_name        => 'MSC_ST_SUPPLIES',
                      p_instance_code     => MSC_CL_PRE_PROCESS.v_instance_code,
                      p_row               => lv_column_names,
                      p_severity          => MSC_CL_PRE_PROCESS.G_SEV_WARNING,
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_batch_id          => lv_batch_id,
                      p_where_str         => lv_where_str,
                      p_col_name          => 'DELETED_FLAG',
                      p_debug             => MSC_CL_PRE_PROCESS.v_debug,
                      p_default_value     => MSC_CL_PRE_PROCESS.SYS_NO);

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

      lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_INVALID_VALUE',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'ORGANIZATION_CODE');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

            --Derive Organization_id
      lv_return := MSC_ST_UTIL.DERIVE_PARTNER_ORG_ID
                     (p_table_name       => 'MSC_ST_SUPPLIES',
                      p_org_partner_name => 'ORGANIZATION_CODE',
                      p_org_partner_id   => 'ORGANIZATION_ID',
                      p_instance_code    => MSC_CL_PRE_PROCESS.v_instance_code,
                      p_partner_type     => MSC_CL_PRE_PROCESS.G_ORGANIZATION,
                      p_error_text       => lv_error_text,
                      p_batch_id         => lv_batch_id,
                      p_severity         => MSC_CL_PRE_PROCESS.G_SEV_ERROR,
                      p_message_text     => lv_message_text,
                      p_debug            => MSC_CL_PRE_PROCESS.v_debug,
                      p_row              => lv_column_names);

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

      lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_INVALID_VALUE',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'ITEM_NAME');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

      --Derive Inventory_item_id
      lv_return := MSC_ST_UTIL.DERIVE_ITEM_ID
                     (p_table_name       => 'MSC_ST_SUPPLIES',
                      p_item_col_name    => 'ITEM_NAME',
                      p_item_col_id      => 'INVENTORY_ITEM_ID',
                      p_instance_id      => MSC_CL_PRE_PROCESS.v_instance_id,
                      p_instance_code    => MSC_CL_PRE_PROCESS.v_instance_code,
                      p_error_text       => lv_error_text,
                      p_batch_id         => lv_batch_id,
                      p_severity         => MSC_CL_PRE_PROCESS.G_SEV_ERROR,
                      p_message_text     => lv_message_text,
                      p_debug            => MSC_CL_PRE_PROCESS.v_debug,
                      p_row              => lv_column_names);

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

---	error out the record if new_order_quantity is null
      lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_COL_VAL_NULL',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'NEW_ORDER_QUANTITY');

      IF lv_return <> 0 THEN
       	 RAISE ex_logging_err;
     	      END IF;

      MSC_CL_PRE_PROCESS.v_sql_stmt := 06;
      lv_sql_stmt :=
      'UPDATE msc_st_supplies '
      ||' SET   error_text   = '||''''||lv_message_text||''''||','
      ||'     process_flag = '||MSC_CL_PRE_PROCESS.G_ERROR_FLG
      ||' WHERE new_order_quantity is null '
      ||' AND   deleted_flag                   = '||MSC_CL_PRE_PROCESS.SYS_NO
      ||' AND   process_flag                   = '||MSC_CL_PRE_PROCESS.G_IN_PROCESS
      ||' AND   NVL(batch_id,'||MSC_CL_PRE_PROCESS.NULL_VALUE||') = :lv_batch_id'
      ||' AND   sr_instance_code               = :v_instance_code';

      IF MSC_CL_PRE_PROCESS.V_DEBUG THEN
        msc_st_util.log_message(lv_sql_stmt);
      END IF;

      EXECUTE IMMEDIATE lv_sql_stmt
              USING     lv_batch_id,
                        MSC_CL_PRE_PROCESS.v_instance_code;

---	error out record which has new_schedule_date and ro_creation_date both as null
      lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_COL_VAL_NULL',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'NEW_SCHEDULE_DATE AND RO_CREATION_DATE');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

      MSC_CL_PRE_PROCESS.v_sql_stmt := 07;
      lv_sql_stmt :=
      'UPDATE msc_st_supplies '
      ||' SET   error_text   = '||''''||lv_message_text||''''||','
      ||'     process_flag = '||MSC_CL_PRE_PROCESS.G_ERROR_FLG
      ||' WHERE new_schedule_date is null'
      ||' AND   ro_creation_date is null'
      ||' AND   deleted_flag                   = '||MSC_CL_PRE_PROCESS.SYS_NO
      ||' AND   process_flag                   = '||MSC_CL_PRE_PROCESS.G_IN_PROCESS
      ||' AND   NVL(batch_id,'||MSC_CL_PRE_PROCESS.NULL_VALUE||') = :lv_batch_id'
      ||' AND   sr_instance_code               = :v_instance_code';

      IF MSC_CL_PRE_PROCESS.V_DEBUG THEN
        msc_st_util.log_message(lv_sql_stmt);
      END IF;

      EXECUTE IMMEDIATE lv_sql_stmt
              USING     lv_batch_id,
                        MSC_CL_PRE_PROCESS.v_instance_code;

---	error out record if  repair_number is null:
      lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_COL_VAL_NULL',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'REPAIR_NUMBER');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

      MSC_CL_PRE_PROCESS.v_sql_stmt := 08;
      lv_sql_stmt :=
      'UPDATE   msc_st_supplies '
      ||' SET   error_text   = '||''''||lv_message_text||''''||','
      ||'       process_flag = '||MSC_CL_PRE_PROCESS.G_ERROR_FLG
      ||' WHERE repair_number is NULL'
      ||' AND   process_flag                  = '||MSC_CL_PRE_PROCESS.G_IN_PROCESS
      ||' AND   NVL(batch_id,'||MSC_CL_PRE_PROCESS.NULL_VALUE||')= :lv_batch_id'
      ||' AND   sr_instance_code              = :v_instance_code';

      IF MSC_CL_PRE_PROCESS.V_DEBUG THEN
        msc_st_util.log_message(lv_sql_stmt);
      END IF;

      EXECUTE IMMEDIATE lv_sql_stmt
              USING     lv_batch_id,
                        MSC_CL_PRE_PROCESS.v_instance_code;

---	derive repair line id

      MSC_CL_PRE_PROCESS.v_sql_stmt := 09;
      lv_sql_stmt :=
      'UPDATE msc_st_supplies mss'
      ||' SET disposition_id     = (SELECT local_id'
      ||'       FROM   msc_local_id_supply mls'
      ||'       WHERE  mls.char4 = mss.repair_number'
      ||'       AND    mls.char3 = mss.organization_code'
      ||'       AND    mls.char1 = mss.sr_instance_code'
      ||'       AND    mls.entity_name = ''REPAIR_NUMBER'' )'
      ||' WHERE  process_flag                   = '||MSC_CL_PRE_PROCESS.G_IN_PROCESS
      ||' AND    NVL(batch_id,'||MSC_CL_PRE_PROCESS.NULL_VALUE||') = :lv_batch_id'
      ||' AND    sr_instance_code               = :v_instance_code';

      IF MSC_CL_PRE_PROCESS.V_DEBUG THEN
        msc_st_util.log_message(lv_sql_stmt);
      END IF;

      EXECUTE IMMEDIATE lv_sql_stmt
              USING     lv_batch_id,
                        MSC_CL_PRE_PROCESS.v_instance_code;


---error out the record where repair line is null and deleted flag is SYS_YES

      lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_DELETE_FAIL',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text);

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;
      MSC_CL_PRE_PROCESS.v_sql_stmt := 11;

      lv_sql_stmt :=
      'UPDATE   msc_st_supplies '
      ||' SET   process_flag        = '||MSC_CL_PRE_PROCESS.G_ERROR_FLG||','
      ||'         error_text   = '||''''||lv_message_text||''''
      ||' WHERE disposition_id is null '
      ||' AND   deleted_flag        ='||MSC_CL_PRE_PROCESS.SYS_YES
      ||' AND   process_flag        = '||MSC_CL_PRE_PROCESS.G_IN_PROCESS
      ||' AND   NVL(batch_id,'||MSC_CL_PRE_PROCESS.NULL_VALUE||')= :lv_batch_id '
      ||' AND   sr_instance_code    =:v_instance_code';

      IF MSC_CL_PRE_PROCESS.V_DEBUG THEN
        msc_st_util.log_message(lv_sql_stmt);
      END IF;

      EXECUTE IMMEDIATE lv_sql_stmt
              USING     lv_batch_id,
                        MSC_CL_PRE_PROCESS.v_instance_code;

---	uom code  validated
  lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_COL_REF_NOT_EXIST',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAMES',
                      p_token_value1      => 'SR_INSTANCE_CODE ,UOM_CODE',
                      p_token2            => 'MASTER_TABLE',
                      p_token_value2      => 'MSC_ST_UNITS_OF_MEASURE',
                      p_token3            => 'CHILD_TABLE',
                      p_token_value3      => 'MSC_ST_SUPPLIES');
      IF lv_return <> 0 THEN
          RAISE ex_logging_err;
      END IF;

       MSC_CL_PRE_PROCESS.v_sql_stmt := 12;
      lv_sql_stmt :=
      '   UPDATE      MSC_ST_SUPPLIES mic'
      ||' SET         process_flag = '||MSC_CL_PRE_PROCESS.G_ERROR_FLG||','
      ||'             error_text   = '||''''||lv_message_text||''''
      ||' WHERE       NOT EXISTS (SELECT 1 '
      ||'             FROM msc_units_of_measure muom'
      ||'             WHERE muom.uom_code       = mic.uom_code'
      ||'             UNION'
      ||'             SELECT 1 FROM msc_st_units_of_measure msuom'
      ||'             WHERE msuom.uom_code       = mic.uom_code'
      ||'             AND   msuom.sr_instance_id = :v_instance_id'
      ||'             AND   msuom.process_flag   = '||MSC_CL_PRE_PROCESS.G_VALID||')'
      ||' AND mic.sr_instance_code   = :v_instance_code'
      ||' AND mic.batch_id           = :lv_batch_id'
      ||' AND mic.process_flag       = '||MSC_CL_PRE_PROCESS.G_IN_PROCESS ;

      IF MSC_CL_PRE_PROCESS.v_debug THEN
           msc_st_util.log_message(lv_sql_stmt);
      END IF;

      EXECUTE IMMEDIATE lv_sql_stmt
            USING     MSC_CL_PRE_PROCESS.v_instance_id,
                      MSC_CL_PRE_PROCESS.v_instance_code,
                      lv_batch_id;

/* for all the row in given batch_id with process_flag =2 and repair_line_id as null populate repair line id
msc_st_iro_supply_s is the new sequence that needs to be created. */
   OPEN c2(lv_batch_id);
    FETCH c2 BULK COLLECT INTO lb_rowid ;
    if c2%ROWCOUNT >0 THEN
     FORALL j IN lb_rowid.FIRST..lb_rowid.LAST
        UPDATE  msc_st_supplies
        SET     disposition_id = msc_st_iro_supply_s.NEXTVAL
        WHERE rowid   = lb_rowid(j);

        MSC_CL_PRE_PROCESS.v_sql_stmt := 13;
        FORALL j IN lb_rowid.FIRST..lb_rowid.LAST
        INSERT INTO msc_local_id_supply
          (local_id,
           st_transaction_id,
           instance_id,
           entity_name,
           data_source_type,
           char1,
           char3,
           char4,
           SOURCE_ORG_ID,
           SOURCE_INVENTORY_ITEM_ID,
           SOURCE_BILL_SEQUENCE_ID,
           SOURCE_ROUTING_SEQUENCE_ID,
           SOURCE_SCHEDULE_GROUP_ID,
           SOURCE_WIP_ENTITY_ID,
           last_update_date,
           last_updated_by,
           creation_date,
           created_by)
        SELECT
            disposition_id,
            st_transaction_id,
            MSC_CL_PRE_PROCESS.v_instance_id,
            'REPAIR_NUMBER',
            data_source_type,
            MSC_CL_PRE_PROCESS.v_instance_code,
            organization_code ,
            REPAIR_NUMBER,
            SOURCE_ORG_ID,
            SOURCE_INVENTORY_ITEM_ID,
            SOURCE_BILL_SEQUENCE_ID,
            SOURCE_ROUTING_SEQUENCE_ID,
            SOURCE_SCHEDULE_GROUP_ID,
            SOURCE_WIP_ENTITY_ID,
            MSC_CL_PRE_PROCESS.v_current_date,
            MSC_CL_PRE_PROCESS.v_current_user,
            MSC_CL_PRE_PROCESS.v_current_date,
            MSC_CL_PRE_PROCESS.v_current_user
        FROM msc_st_supplies
        WHERE  rowid  = lb_rowid(j);
      END IF ;
      close c2;
----	validating project and task :
       lv_return := MSC_ST_UTIL.DERIVE_PROJ_TASK_ID
                             (p_table_name          => 'MSC_ST_SUPPLIES',
                              p_proj_col_name       => 'PROJECT_NUMBER',
                              p_proj_task_col_id    => 'PROJECT_ID',
                              p_instance_code       => MSC_CL_PRE_PROCESS.v_instance_code,
                              p_entity_name         => 'PROJECT_ID',
                              p_error_text          => lv_error_text,
                              p_batch_id            => lv_batch_id,
                              p_severity            => MSC_CL_PRE_PROCESS.G_SEV_WARNING,
                              p_message_text        => lv_message_text,
                              p_debug               => MSC_CL_PRE_PROCESS.v_debug,
                              p_row                 => lv_column_names);
      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

      lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_FK_REF_NOT_EXIST',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAMES',
                      p_token_value1      => '  SR_INSTANCE_CODE,'
                                             ||' ORGANIZATION_CODE, PROJECT_NUMBER,'
                                             ||' TASK_NUMBER',
                      p_token2            => 'MASTER_TABLE',
                      p_token_value2      => 'MSC_ST_PROJECT_TASKS');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

      --Derive Task Id.
      lv_return := MSC_ST_UTIL.DERIVE_PROJ_TASK_ID
                             (p_table_name          => 'MSC_ST_SUPPLIES',
                              p_proj_col_name       => 'PROJECT_NUMBER',
                              p_proj_task_col_id    => 'TASK_ID',
                              p_instance_code       => MSC_CL_PRE_PROCESS.v_instance_code,
                              p_entity_name         => 'TASK_ID',
                              p_error_text          => lv_error_text,
                              p_task_col_name       => 'TASK_NUMBER',
                              p_batch_id            => lv_batch_id,
                              p_severity            => MSC_CL_PRE_PROCESS.G_SEV_WARNING,
                              p_message_text        => lv_message_text,
                              p_debug               => MSC_CL_PRE_PROCESS.v_debug,
                              p_row                 => lv_column_names);

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;


      --Call to customised validation.
      MSC_CL_PRE_PROCESS_HOOK.ENTITY_VALIDATION
        (ERRBUF         => lv_error_text,
         RETCODE        => lv_return,
         pBatchID       => lv_batch_id,
         pInstanceCode  => MSC_CL_PRE_PROCESS.v_instance_code,
         pEntityName    => 'MSC_ST_SUPPLIES',
         pInstanceID    => MSC_CL_PRE_PROCESS.v_instance_id);

      IF NVL(lv_return,0) <> 0 THEN
        RAISE ex_logging_err;
      END IF;

      lv_return := MSC_ST_UTIL.SET_PROCESS_FLAG
                  (p_table_name     => 'MSC_ST_SUPPLIES',
                   p_instance_id    => MSC_CL_PRE_PROCESS.v_instance_id,
                   p_instance_code  => MSC_CL_PRE_PROCESS.v_instance_code,
                   p_process_flag   => MSC_CL_PRE_PROCESS.G_VALID,
                   p_error_text     => lv_error_text,
                   p_debug          => MSC_CL_PRE_PROCESS.v_debug,
                   p_batch_id       => lv_batch_id);

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

      lv_return := MSC_ST_UTIL.LOG_ERROR
                   (p_table_name        => 'MSC_ST_SUPPLIES',
                    p_instance_code     => MSC_CL_PRE_PROCESS.v_instance_code,
                    p_row               => lv_column_names,
                    p_severity          => MSC_CL_PRE_PROCESS.G_SEV_ERROR,
                    p_message_text      => NULL,
                    p_error_text        => lv_error_text,
                    p_debug             => MSC_CL_PRE_PROCESS.v_debug,
                    p_batch_id          => lv_batch_id);

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;
      COMMIT;
    END LOOP;

   EXCEPTION

    WHEN too_many_rows THEN
      lv_error_text := substr('MSC_CL_PRE_PROCESS.MSC_ST_SUPPLIES'||'('
                       ||MSC_CL_PRE_PROCESS.v_sql_stmt||')'|| SQLERRM, 1, 240);
      ROLLBACK ;

    WHEN ex_logging_err THEN
      msc_st_util.log_message(lv_error_text);
      ROLLBACK;

    WHEN OTHERS THEN
      lv_error_text    := substr('MSC_CL_PRE_PROCESS.MSC_ST_SUPPLIES '||'('
                       ||MSC_CL_PRE_PROCESS.v_sql_stmt||')'|| SQLERRM, 1, 240);
      msc_st_util.log_message(lv_error_text);
      ROLLBACK;

  END LOAD_IRO_SUPPLY;

PROCEDURE LOAD_IRO_DEMAND IS
  TYPE RowidTab IS TABLE OF ROWID INDEX BY BINARY_INTEGER;
  lb_rowid           RowidTab;
  lv_return          NUMBER;
  lv_error_text      VARCHAR2(250);
  lv_where_str       VARCHAR2(5000);
  lv_sql_stmt        VARCHAR2(5000);
  lv_column_names    VARCHAR2(5000);
  lv_batch_id        msc_st_demands.batch_id%TYPE;
  lv_message_text    msc_errors.error_text%TYPE;

  ex_logging_err     EXCEPTION;

  CURSOR    c1(p_batch_id NUMBER) IS
    SELECT  rowid
    FROM    msc_st_demands
    WHERE   process_flag     IN (MSC_CL_PRE_PROCESS.G_IN_PROCESS)
    AND     batch_id         = p_batch_id
    AND     sr_instance_code = MSC_CL_PRE_PROCESS.v_instance_code;

 BEGIN

   lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                 (p_app_short_name    => 'MSC',
                  p_error_code        => 'MSC_PP_DUP_REC_FOR_BATCH_LOAD',
                  p_message_text      => lv_message_text,
                  p_error_text        => lv_error_text);

    IF lv_return <> 0 THEN
      RAISE ex_logging_err;
    END IF;

    --Duplicate records check for the records whose source is other than XML
    --Different SQL is used because in XML we can identify the latest records
    --whereas in batch load we cannot.
    MSC_CL_PRE_PROCESS.v_sql_stmt := 02;
    lv_sql_stmt :=
    'UPDATE  msc_st_demands msd1 '
    ||' SET     process_flag  = '||MSC_CL_PRE_PROCESS.G_ERROR_FLG||','
    ||'         error_text   = '||''''||lv_message_text||''''
    ||' WHERE   EXISTS( SELECT 1 '
    ||'         FROM   msc_st_demands msd2'
    ||'         WHERE  msd2.sr_instance_code  = msd1.sr_instance_code'
    ||'         AND    msd2.organization_code = msd1.organization_code'
    ||'         AND    msd2.wip_entity_name = msd1.wip_entity_name'
    ||'         AND    msd2.repair_number = msd1.repair_number'
    ||'         AND    msd2.operation_seq_num = msd1.operation_seq_num '
    ||'         AND    msd2.item_name   = msd1.item_name '
    ||'         AND    msd2.process_flag      = '||MSC_CL_PRE_PROCESS.G_IN_PROCESS
    ||'         AND NVL(msd2.message_id,'||MSC_CL_PRE_PROCESS.NULL_VALUE||') = '||MSC_CL_PRE_PROCESS.NULL_VALUE
    ||'         GROUP BY  sr_instance_code,organization_code,wip_entity_name,'
    ||'                        operation_seq_num,item_name,repair_number'
    ||'       HAVING COUNT(*) > 1)'
    ||'       AND   msd1.process_flag  = '||MSC_CL_PRE_PROCESS.G_IN_PROCESS
    ||' AND   msd1.origination_type =77'
    ||' AND   msd1.ENTITY =''IRO'''
    ||' AND   msd1.sr_instance_code = :v_instance_code'
    ||' AND   msd1.message_id IS NULL';


    IF MSC_CL_PRE_PROCESS.V_DEBUG THEN
      msc_st_util.log_message(lv_sql_stmt);
    END IF;

    EXECUTE IMMEDIATE lv_sql_stmt
            USING     MSC_CL_PRE_PROCESS.v_instance_code;

  lv_column_names :=
  'ITEM_NAME                        ||''~''||'
  ||' ORGANIZATION_CODE             ||''~''||'
  ||' USING_REQUIREMENT_QUANTITY    ||''~''||'
  ||' REPAIR_NUMBER                 ||''~''||'
  ||' WIP_ENTITY_NAME               ||''~''||'
  ||' OPERATION_SEQ_NUM             ||''~''||'
  ||' USING_ASSEMBLY_DEMAND_DATE    ||''~''||'
  ||' SR_INSTANCE_CODE              ||''~''||'
  ||' USING_ASSEMBLY_ITEM_NAME      ||''~''||'
  ||' PROJECT_NUMBER                ||''~''||'
  ||' TASK_NUMBER                   ||''~''||'
  ||' DEMAND_CLASS                  ||''~''||'
  ||' DELETED_FLAG                  ||''~''||'
  ||' RO_STATUS_CODE                ||''~''||'
  ||' QUANTITY_ISSUED               ||''~''||'
  ||' COMPONENT_SCALING_TYPE        ||''~''||'
  ||' COMPONENT_YIELD_FACTOR        ||''~''||'
  ||' ITEM_TYPE_VALUE  ' ;

    LOOP
      MSC_CL_PRE_PROCESS.v_sql_stmt := 03;
      SELECT msc_st_batch_id_s.NEXTVAL
      INTO   lv_batch_id
      FROM   dual;

      MSC_CL_PRE_PROCESS.v_sql_stmt := 04;
      lv_sql_stmt :=
      ' UPDATE   msc_st_demands '
      ||' SET    batch_id  = :lv_batch_id'
      ||' WHERE  process_flag  IN ('||MSC_CL_PRE_PROCESS.G_IN_PROCESS||','||MSC_CL_PRE_PROCESS.G_ERROR_FLG||')'
      ||' AND    sr_instance_code  = :v_instance_code'
      ||' AND    origination_type IN (77) '
      ||' AND    ENTITY = ''IRO'' '
      ||' AND    NVL(batch_id,'||MSC_CL_PRE_PROCESS.NULL_VALUE||') = '||MSC_CL_PRE_PROCESS.NULL_VALUE
      ||' AND    rownum                        <= '||MSC_CL_PRE_PROCESS.v_batch_size;


      IF MSC_CL_PRE_PROCESS.V_DEBUG THEN
        msc_st_util.log_message(lv_sql_stmt);
      END IF;

      EXECUTE IMMEDIATE lv_sql_stmt
              USING     lv_batch_id,
                        MSC_CL_PRE_PROCESS.v_instance_code;

      EXIT WHEN SQL%NOTFOUND;

      OPEN c1(lv_batch_id);
      FETCH c1 BULK COLLECT INTO lb_rowid;
      CLOSE c1;

      MSC_CL_PRE_PROCESS.v_sql_stmt := 05;
      FORALL j IN lb_rowid.FIRST..lb_rowid.LAST
      UPDATE msc_st_demands
      SET    st_transaction_id   = msc_st_demands_s.NEXTVAL,
             refresh_id          = MSC_CL_PRE_PROCESS.v_refresh_id,
             last_update_date    = MSC_CL_PRE_PROCESS.v_current_date,
             last_updated_by     = MSC_CL_PRE_PROCESS.v_current_user,
             creation_date       = MSC_CL_PRE_PROCESS.v_current_date,
             created_by          = MSC_CL_PRE_PROCESS.v_current_user
      WHERE  rowid           = lb_rowid(j);

      -- set the error message

      lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_INVALID_COL_VALUE',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'DELETED_FLAG',
                      p_token2            => 'DEFAULT_VALUE',
                      p_token_value2      => MSC_CL_PRE_PROCESS.SYS_NO);

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

      lv_where_str :=
      ' AND NVL(deleted_flag,'||MSC_CL_PRE_PROCESS.NULL_VALUE||') '
      ||' NOT IN(1,2)';
      --Log a warning for those records where the deleted_flag has a value other
      --than SYS_NO
      lv_return := MSC_ST_UTIL.LOG_ERROR
                     (p_table_name        => 'MSC_ST_DEMANDS',
                      p_instance_code     => MSC_CL_PRE_PROCESS.v_instance_code,
                      p_row               => lv_column_names,
                      p_severity          => MSC_CL_PRE_PROCESS.G_SEV_WARNING,
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_batch_id          => lv_batch_id,
                      p_where_str         => lv_where_str,
                      p_col_name          => 'DELETED_FLAG',
                      p_debug             => MSC_CL_PRE_PROCESS.v_debug,
                      p_default_value     => MSC_CL_PRE_PROCESS.SYS_NO);

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

      lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_INVALID_VALUE',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'ORGANIZATION_CODE');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

            --Derive Organization_id
      lv_return := MSC_ST_UTIL.DERIVE_PARTNER_ORG_ID
                     (p_table_name       => 'MSC_ST_DEMANDS',
                      p_org_partner_name => 'ORGANIZATION_CODE',
                      p_org_partner_id   => 'ORGANIZATION_ID',
                      p_instance_code    => MSC_CL_PRE_PROCESS.v_instance_code,
                      p_partner_type     => MSC_CL_PRE_PROCESS.G_ORGANIZATION,
                      p_error_text       => lv_error_text,
                      p_batch_id         => lv_batch_id,
                      p_severity         => MSC_CL_PRE_PROCESS.G_SEV_ERROR,
                      p_message_text     => lv_message_text,
                      p_debug            => MSC_CL_PRE_PROCESS.v_debug,
                      p_row              => lv_column_names);

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

      lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_INVALID_VALUE',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'ITEM_NAME');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

      --Derive Inventory_item_id
      lv_return := MSC_ST_UTIL.DERIVE_ITEM_ID
                     (p_table_name       => 'MSC_ST_DEMANDS',
                      p_item_col_name    => 'ITEM_NAME',
                      p_item_col_id      => 'INVENTORY_ITEM_ID',
                      p_instance_id      => MSC_CL_PRE_PROCESS.v_instance_id,
                      p_instance_code    => MSC_CL_PRE_PROCESS.v_instance_code,
                      p_error_text       => lv_error_text,
                      p_batch_id         => lv_batch_id,
                      p_severity         => MSC_CL_PRE_PROCESS.G_SEV_ERROR,
                      p_message_text     => lv_message_text,
                      p_debug            => MSC_CL_PRE_PROCESS.v_debug,
                      p_row              => lv_column_names);

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
                      p_token_value1      => 'USING_ASSEMBLY_ITEM_NAME');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

    --Derive Inventory_item_id
    lv_return := MSC_ST_UTIL.DERIVE_ITEM_ID
                   (p_table_name       => 'MSC_ST_DEMANDS',
                    p_item_col_name    => 'USING_ASSEMBLY_ITEM_NAME',
                    p_item_col_id      => 'USING_ASSEMBLY_ITEM_ID',
                    p_instance_id      => MSC_CL_PRE_PROCESS.v_instance_id,
                    p_instance_code    => MSC_CL_PRE_PROCESS.v_instance_code,
                    p_error_text       => lv_error_text,
                    p_batch_id         => lv_batch_id,
                    p_severity         => MSC_CL_PRE_PROCESS.G_SEV3_ERROR,
                    p_message_text     => lv_message_text,
                    p_debug            => MSC_CL_PRE_PROCESS.v_debug,
                    p_row              => lv_column_names);

    IF lv_return <> 0 THEN
        RAISE ex_logging_err;
    END IF;

---	error out records where USING_REQUIREMENT_QUANTITY is NULL and using_assembly_demand_date is NULL

      lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_COL_VAL_NULL',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'USING_REQUIREMENT_QUANTITY' || ' OR USING_ASSEMBLY_DEMAND_DATE');

      IF lv_return <> 0 THEN
       	 RAISE ex_logging_err;
     	      END IF;

      MSC_CL_PRE_PROCESS.v_sql_stmt := 06;
      lv_sql_stmt :=
      'UPDATE msc_st_demands '
      ||' SET   error_text   = '||''''||lv_message_text||''''||','
      ||'     process_flag = '||MSC_CL_PRE_PROCESS.G_ERROR_FLG
      ||' WHERE (using_requirement_quantity IS NULL ' ||'  OR  using_assembly_demand_date IS NULL)'
      ||' AND   process_flag                   = '||MSC_CL_PRE_PROCESS.G_IN_PROCESS
      ||' AND   origination_type  IN (77)'
      ||' AND   ENTITY    = ''IRO'''
      ||' AND   deleted_flag   = '||MSC_CL_PRE_PROCESS.SYS_NO
      ||' AND   NVL(batch_id,'||MSC_CL_PRE_PROCESS.NULL_VALUE||') = :lv_batch_id'
      ||' AND   sr_instance_code = :v_instance_code';

      IF MSC_CL_PRE_PROCESS.V_DEBUG THEN
        msc_st_util.log_message(lv_sql_stmt);
      END IF;

      EXECUTE IMMEDIATE lv_sql_stmt
              USING     lv_batch_id,
                        MSC_CL_PRE_PROCESS.v_instance_code;

---	error out record if  repair_number is null:
      lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_COL_VAL_NULL',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'REPAIR_NUMBER');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

      MSC_CL_PRE_PROCESS.v_sql_stmt := 07;
      lv_sql_stmt :=
      'UPDATE   msc_st_demands '
      ||' SET   error_text   = '||''''||lv_message_text||''''||','
      ||'       process_flag = '||MSC_CL_PRE_PROCESS.G_ERROR_FLG
      ||' WHERE repair_number is NULL'
      ||' AND   process_flag     = '||MSC_CL_PRE_PROCESS.G_IN_PROCESS
      ||' AND   NVL(batch_id,'||MSC_CL_PRE_PROCESS.NULL_VALUE||')= :lv_batch_id'
      ||' AND   sr_instance_code = :v_instance_code';

      IF MSC_CL_PRE_PROCESS.V_DEBUG THEN
        msc_st_util.log_message(lv_sql_stmt);
      END IF;

      EXECUTE IMMEDIATE lv_sql_stmt
              USING     lv_batch_id,
                        MSC_CL_PRE_PROCESS.v_instance_code;

---	derive repair line id

      MSC_CL_PRE_PROCESS.v_sql_stmt := 08;
      lv_sql_stmt :=
      'UPDATE msc_st_demands msd'
      ||' SET repair_line_id     = (SELECT local_id'
      ||'       FROM   msc_local_id_supply mls'
      ||'       WHERE  mls.char4 = msd.wip_entity_name'
      ||'       AND    mls.char3 = msd.organization_code'
      ||'       AND    mls.char1 = msd.sr_instance_code'
      ||'       AND    mls.entity_name = ''REPAIR_NUMBER'' )'
      ||' WHERE  process_flag                   = '||MSC_CL_PRE_PROCESS.G_IN_PROCESS
      ||' AND    NVL(batch_id,'||MSC_CL_PRE_PROCESS.NULL_VALUE||') = :lv_batch_id'
      ||' AND    sr_instance_code               = :v_instance_code';

      IF MSC_CL_PRE_PROCESS.V_DEBUG THEN
        msc_st_util.log_message(lv_sql_stmt);
      END IF;

      EXECUTE IMMEDIATE lv_sql_stmt
              USING     lv_batch_id,
                        MSC_CL_PRE_PROCESS.v_instance_code;


---error out the record where repair line is null and deleted flag is SYS_YES

      lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_DELETE_FAIL',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text);

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;
      MSC_CL_PRE_PROCESS.v_sql_stmt := 09;

      lv_sql_stmt :=
      'UPDATE   msc_st_demands '
      ||' SET   process_flag        = '||MSC_CL_PRE_PROCESS.G_ERROR_FLG||','
      ||'         error_text   = '||''''||lv_message_text||''''
      ||' WHERE repair_line_id is null '
      ||' AND   deleted_flag        ='||MSC_CL_PRE_PROCESS.SYS_YES
      ||' AND   process_flag        = '||MSC_CL_PRE_PROCESS.G_IN_PROCESS
      ||' AND   NVL(batch_id,'||MSC_CL_PRE_PROCESS.NULL_VALUE||')= :lv_batch_id '
      ||' AND   sr_instance_code    =:v_instance_code';

      IF MSC_CL_PRE_PROCESS.V_DEBUG THEN
        msc_st_util.log_message(lv_sql_stmt);
      END IF;

      EXECUTE IMMEDIATE lv_sql_stmt
              USING     lv_batch_id,
                        MSC_CL_PRE_PROCESS.v_instance_code;

---	error out record if  ITEM_TYPE_VALUE is null:
      lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_INVALID_VALUE',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'ITEM_TYPE_VALUE');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

      MSC_CL_PRE_PROCESS.v_sql_stmt := 10;
      lv_sql_stmt :=
      'UPDATE   msc_st_demands '
      ||' SET   error_text   = '||''''||lv_message_text||''''||','
      ||'       process_flag = '||MSC_CL_PRE_PROCESS.G_ERROR_FLG
      ||' WHERE nvl(ITEM_TYPE_VALUE,-1) not in (1,2)'
      ||' AND   process_flag     = '||MSC_CL_PRE_PROCESS.G_IN_PROCESS
      ||' AND   NVL(batch_id,'||MSC_CL_PRE_PROCESS.NULL_VALUE||')= :lv_batch_id'
      ||' AND   sr_instance_code = :v_instance_code';

      IF MSC_CL_PRE_PROCESS.V_DEBUG THEN
        msc_st_util.log_message(lv_sql_stmt);
      END IF;

      EXECUTE IMMEDIATE lv_sql_stmt
              USING     lv_batch_id,
                        MSC_CL_PRE_PROCESS.v_instance_code;
----	validating project and task :
       lv_return := MSC_ST_UTIL.DERIVE_PROJ_TASK_ID
                             (p_table_name          => 'MSC_ST_DEMANDS',
                              p_proj_col_name       => 'PROJECT_NUMBER',
                              p_proj_task_col_id    => 'PROJECT_ID',
                              p_instance_code       => MSC_CL_PRE_PROCESS.v_instance_code,
                              p_entity_name         => 'PROJECT_ID',
                              p_error_text          => lv_error_text,
                              p_batch_id            => lv_batch_id,
                              p_severity            => MSC_CL_PRE_PROCESS.G_SEV_WARNING,
                              p_message_text        => lv_message_text,
                              p_debug               => MSC_CL_PRE_PROCESS.v_debug,
                              p_row                 => lv_column_names);
      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

      lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_FK_REF_NOT_EXIST',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAMES',
                      p_token_value1      => '  SR_INSTANCE_CODE,'
                                             ||' ORGANIZATION_CODE, PROJECT_NUMBER,'
                                             ||' TASK_NUMBER',
                      p_token2            => 'MASTER_TABLE',
                      p_token_value2      => 'MSC_ST_PROJECT_TASKS');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

      --Derive Task Id.
      lv_return := MSC_ST_UTIL.DERIVE_PROJ_TASK_ID
                             (p_table_name          => 'MSC_ST_DEMANDS',
                              p_proj_col_name       => 'PROJECT_NUMBER',
                              p_proj_task_col_id    => 'TASK_ID',
                              p_instance_code       => MSC_CL_PRE_PROCESS.v_instance_code,
                              p_entity_name         => 'TASK_ID',
                              p_error_text          => lv_error_text,
                              p_task_col_name       => 'TASK_NUMBER',
                              p_batch_id            => lv_batch_id,
                              p_severity            => MSC_CL_PRE_PROCESS.G_SEV_WARNING,
                              p_message_text        => lv_message_text,
                              p_debug               => MSC_CL_PRE_PROCESS.v_debug,
                              p_row                 => lv_column_names);

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

      --Call to customised validation.
      MSC_CL_PRE_PROCESS_HOOK.ENTITY_VALIDATION
        (ERRBUF         => lv_error_text,
         RETCODE        => lv_return,
         pBatchID       => lv_batch_id,
         pInstanceCode  => MSC_CL_PRE_PROCESS.v_instance_code,
         pEntityName    => 'MSC_ST_DEMANDS',
         pInstanceID    => MSC_CL_PRE_PROCESS.v_instance_id);

      IF NVL(lv_return,0) <> 0 THEN
        RAISE ex_logging_err;
      END IF;

      lv_return := MSC_ST_UTIL.SET_PROCESS_FLAG
                  (p_table_name     => 'MSC_ST_DEMANDS',
                   p_instance_id    => MSC_CL_PRE_PROCESS.v_instance_id,
                   p_instance_code  => MSC_CL_PRE_PROCESS.v_instance_code,
                   p_process_flag   => MSC_CL_PRE_PROCESS.G_VALID,
                   p_error_text     => lv_error_text,
                   p_debug          => MSC_CL_PRE_PROCESS.v_debug,
                   p_batch_id       => lv_batch_id);

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

      lv_return := MSC_ST_UTIL.LOG_ERROR
                   (p_table_name        => 'MSC_ST_DEMANDS',
                    p_instance_code     => MSC_CL_PRE_PROCESS.v_instance_code,
                    p_row               => lv_column_names,
                    p_severity          => MSC_CL_PRE_PROCESS.G_SEV_ERROR,
                    p_message_text      => NULL,
                    p_error_text        => lv_error_text,
                    p_debug             => MSC_CL_PRE_PROCESS.v_debug,
                    p_batch_id          => lv_batch_id);

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;
      COMMIT;
    END LOOP;

   EXCEPTION

    WHEN too_many_rows THEN
      lv_error_text := substr('MSC_CL_PRE_PROCESS.MSC_ST_DEMANDS'||'('
                       ||MSC_CL_PRE_PROCESS.v_sql_stmt||')'|| SQLERRM, 1, 240);
      ROLLBACK ;

    WHEN ex_logging_err THEN
      msc_st_util.log_message(lv_error_text);
      ROLLBACK;

    WHEN OTHERS THEN
      lv_error_text    := substr('MSC_CL_PRE_PROCESS.MSC_ST_DEMANDS '||'('
                       ||MSC_CL_PRE_PROCESS.v_sql_stmt||')'|| SQLERRM, 1, 240);
      msc_st_util.log_message(lv_error_text);
      ROLLBACK;

  END LOAD_IRO_DEMAND;

 PROCEDURE LOAD_ERO_SUPPLY IS
  TYPE RowidTab IS TABLE OF ROWID INDEX BY BINARY_INTEGER;
  lb_rowid               RowidTab;
  lv_return              NUMBER;
  lv_error_text          VARCHAR2(250);
  lv_where_str           VARCHAR2(5000);
  lv_sql_stmt            VARCHAR2(5000);
  lv_column_names        VARCHAR2(5000);                   --stores concatenated column names
  lv_message_text        msc_errors.error_text%TYPE;
  lv_batch_id            msc_st_supplies.batch_id%TYPE;
  ex_logging_err         EXCEPTION;

  CURSOR c1(p_batch_id NUMBER) IS
    SELECT rowid
    FROM   msc_st_supplies
    WHERE  order_type              =86
    AND    process_flag            IN (MSC_CL_PRE_PROCESS.G_IN_PROCESS,MSC_CL_PRE_PROCESS.G_ERROR_FLG)
    AND    NVL(batch_id,MSC_CL_PRE_PROCESS.NULL_VALUE)=p_batch_id
    AND    sr_instance_code        = MSC_CL_PRE_PROCESS.v_instance_code;

  CURSOR c2(p_batch_id NUMBER) IS
    SELECT rowid
    FROM   msc_st_supplies
    WHERE  NVL(wip_entity_id,MSC_CL_PRE_PROCESS.NULL_VALUE) = MSC_CL_PRE_PROCESS.NULL_VALUE
    AND    process_flag                  = MSC_CL_PRE_PROCESS.G_IN_PROCESS
    AND    NVL(batch_id,MSC_CL_PRE_PROCESS.NULL_VALUE)      =p_batch_id
    AND    sr_instance_code              = MSC_CL_PRE_PROCESS.v_instance_code;

  CURSOR c3(p_batch_id NUMBER) IS
    SELECT max(rowid)
    FROM   msc_st_supplies
    WHERE  NVL(schedule_group_id,MSC_CL_PRE_PROCESS.NULL_VALUE) = MSC_CL_PRE_PROCESS.NULL_VALUE
    AND    deleted_flag                      = MSC_CL_PRE_PROCESS.SYS_NO
    AND    process_flag                      = MSC_CL_PRE_PROCESS.G_IN_PROCESS
    AND    NVL(batch_id,MSC_CL_PRE_PROCESS.NULL_VALUE)          = p_batch_id
    AND    sr_instance_code                  = MSC_CL_PRE_PROCESS.v_instance_code
    GROUP BY sr_instance_code,company_name,organization_code,schedule_group_name;

  CURSOR c4(p_batch_id NUMBER) IS
    SELECT rowid
    FROM   msc_st_supplies
    WHERE  process_flag     = MSC_CL_PRE_PROCESS.G_IN_PROCESS
    AND    sr_instance_code = MSC_CL_PRE_PROCESS.v_instance_code
    AND    batch_id         = p_batch_id
    AND    NVL(JOB_OP_SEQ_NUM, MSC_CL_PRE_PROCESS.NULL_VALUE) = MSC_CL_PRE_PROCESS.NULL_VALUE
    AND    NVL(JOB_OP_SEQ_CODE, MSC_CL_PRE_PROCESS.NULL_CHAR) <> MSC_CL_PRE_PROCESS.NULL_CHAR
    AND    order_type   = 86
    AND    deleted_flag     = MSC_CL_PRE_PROCESS.SYS_NO;

  BEGIN

    lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                 (p_app_short_name    => 'MSC',
                  p_error_code        => 'MSC_PP_DUP_REC_FOR_XML',
                  p_message_text      => lv_message_text,
                  p_error_text        => lv_error_text);

    IF lv_return <> 0 THEN
      RAISE ex_logging_err;
    END IF;

    --Duplicate records check for the records whose source is XML for
    --WO supplies
    MSC_CL_PRE_PROCESS.v_sql_stmt := 01;
    lv_sql_stmt :=
    'UPDATE  msc_st_supplies mss1'
    ||' SET     process_flag = '||MSC_CL_PRE_PROCESS.G_ERROR_FLG||','
    ||'         error_text   = '||''''||lv_message_text||''''
    ||' WHERE   message_id <  (SELECT MAX(message_id)'
    ||'         FROM   msc_st_supplies mss2'
    ||'         WHERE  mss2.sr_instance_code'
    ||'                = mss1.sr_instance_code'
    ||'         AND    NVL(mss2.company_name,'||''''||MSC_CL_PRE_PROCESS.NULL_CHAR||''''||') = '
    ||'                NVL(mss1.company_name,'||''''||MSC_CL_PRE_PROCESS.NULL_CHAR||''''||')'
    ||'         AND    mss2.wip_entity_name = mss1.wip_entity_name '
    ||'         AND    mss2.order_type    = mss1.order_type'
    ||'         AND    mss2.process_flag      = '||MSC_CL_PRE_PROCESS.G_IN_PROCESS
    ||'         AND    mss2.organization_code  = mss1.organization_code'
    ||'         AND    NVL(mss2.message_id,'||MSC_CL_PRE_PROCESS.NULL_VALUE||')<>'||MSC_CL_PRE_PROCESS.NULL_VALUE||')'
    ||' AND    mss1.order_type       =86'
    ||' AND    mss1.process_flag       = '||MSC_CL_PRE_PROCESS.G_IN_PROCESS
    ||' AND    mss1.sr_instance_code   = :v_instance_code'
    ||' AND    NVL(mss1.message_id,'||MSC_CL_PRE_PROCESS.NULL_VALUE||') <> '||MSC_CL_PRE_PROCESS.NULL_VALUE;

    IF MSC_CL_PRE_PROCESS.V_DEBUG THEN
      msc_st_util.log_message(lv_sql_stmt);
    END IF;

    EXECUTE IMMEDIATE lv_sql_stmt
            USING     MSC_CL_PRE_PROCESS.v_instance_code;


    lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                 (p_app_short_name    => 'MSC',
                  p_error_code        => 'MSC_PP_DUP_REC_FOR_BATCH_LOAD',
                  p_message_text      => lv_message_text,
                  p_error_text        => lv_error_text);

    IF lv_return <> 0 THEN
      RAISE ex_logging_err;
    END IF;

    --Duplicate records check for the records whose source is other than XML
    --Different SQL is used because in XML we can identify the latest records
    --whereas in batch load we cannot.
    MSC_CL_PRE_PROCESS.v_sql_stmt := 02;
    lv_sql_stmt :=
    'UPDATE  msc_st_supplies mss1 '
    ||' SET     process_flag  = '||MSC_CL_PRE_PROCESS.G_ERROR_FLG||','
    ||'         error_text   = '||''''||lv_message_text||''''
    ||' WHERE   EXISTS( SELECT 1 '
    ||'         FROM   msc_st_supplies mss2'
    ||'         WHERE  mss2.sr_instance_code'
    ||'                = mss1.sr_instance_code'
    ||'         AND    NVL(mss2.company_name,   '||''''||MSC_CL_PRE_PROCESS.NULL_CHAR||''''||')= '
    ||'                NVL(mss1.company_name,   '||''''||MSC_CL_PRE_PROCESS.NULL_CHAR||''''||')'
    ||'         AND    mss2.wip_entity_name = mss1.wip_entity_name '
    ||'         AND    mss2.order_type    = mss1.order_type'
    ||'         AND    mss2.process_flag  = '||MSC_CL_PRE_PROCESS.G_IN_PROCESS
    ||'         AND    mss2.organization_code = mss1.organization_code'
    ||'         AND    NVL(mss2.message_id,'||MSC_CL_PRE_PROCESS.NULL_VALUE||') = '||MSC_CL_PRE_PROCESS.NULL_VALUE
    ||'         GROUP BY sr_instance_code,wip_entity_name,organization_code,company_name,'
    ||'                order_type'
    ||'         HAVING COUNT(*) > 1)'
    ||' AND     mss1.order_type =86'
    ||' AND     mss1.process_flag     = '||MSC_CL_PRE_PROCESS.G_IN_PROCESS
    ||' AND     mss1.sr_instance_code = :v_instance_code'
    ||' AND     NVL(mss1.message_id,'||MSC_CL_PRE_PROCESS.NULL_VALUE||') = '||MSC_CL_PRE_PROCESS.NULL_VALUE;

    IF MSC_CL_PRE_PROCESS.V_DEBUG THEN
      msc_st_util.log_message(lv_sql_stmt);
    END IF;

    EXECUTE IMMEDIATE lv_sql_stmt USING MSC_CL_PRE_PROCESS.v_instance_code;

    lv_column_names :=
    'ITEM_NAME                      ||''~''||'
    ||'ORGANIZATION_CODE            ||''~''||'
    ||'NEW_SCHEDULE_DATE            ||''~''||'
    ||'FIRM_PLANNED_TYPE            ||''~''||'
    ||'WIP_ENTITY_NAME              ||''~''||'
    ||'SR_INSTANCE_CODE             ||''~''||'
    ||'REVISION                     ||''~''||'
    ||'UNIT_NUMBER                  ||''~''||'
    ||'NEW_WIP_START_DATE           ||''~''||'
    ||'NEW_ORDER_QUANTITY           ||''~''||'
    ||'ALTERNATE_BOM_DESIGNATOR     ||''~''||'
    ||'ALTERNATE_ROUTING_DESIGNATOR ||''~''||'
    ||'LINE_CODE                    ||''~''||'
    ||'PROJECT_NUMBER               ||''~''||'
    ||'TASK_NUMBER                  ||''~''||'
    ||'PLANNING_GROUP               ||''~''||'
    ||'SCHEDULE_GROUP_NAME          ||''~''||'
    ||'BUILD_SEQUENCE               ||''~''||'
    ||'WO_LATENESS_COST             ||''~''||'
    ||'IMPLEMENT_PROCESSING_DAYS    ||''~''||'
    ||'LATE_SUPPLY_DATE             ||''~''||'
    ||'LATE_SUPPLY_QTY              ||''~''||'
    ||'QTY_SCRAPPED                 ||''~''||'
    ||'QTY_COMPLETED                ||''~''||'
    ||'WIP_STATUS_CODE              ||''~''||'
    ||'BILL_NAME                    ||''~''||'
    ||'ROUTING_NAME                 ||''~''||'
    ||'DELETED_FLAG                 ||''~''||'
    ||'COMPANY_NAME                 ||''~''||'
    ||'ORDER_TYPE                   ||''~''||'
    ||'ORDER_NUMBER';

    LOOP
      MSC_CL_PRE_PROCESS.v_sql_stmt := 03;
      SELECT msc_st_batch_id_s.NEXTVAL
      INTO   lv_batch_id
      FROM   dual;

      MSC_CL_PRE_PROCESS.v_sql_stmt := 04;
      lv_sql_stmt :=
      ' UPDATE   msc_st_supplies '
      ||' SET    batch_id  = :lv_batch_id'
      ||' WHERE  process_flag  IN ('||MSC_CL_PRE_PROCESS.G_IN_PROCESS||','||MSC_CL_PRE_PROCESS.G_ERROR_FLG||')'
      ||' AND    order_type =86'
      ||' AND    sr_instance_code               = :v_instance_code'
      ||' AND    NVL(batch_id,'||MSC_CL_PRE_PROCESS.NULL_VALUE||') = '||MSC_CL_PRE_PROCESS.NULL_VALUE
      ||' AND    rownum                        <= '||MSC_CL_PRE_PROCESS.v_batch_size;

      IF MSC_CL_PRE_PROCESS.V_DEBUG THEN
        msc_st_util.log_message(lv_sql_stmt);
      END IF;

      EXECUTE IMMEDIATE lv_sql_stmt
              USING     lv_batch_id,
                        MSC_CL_PRE_PROCESS.v_instance_code;

      EXIT WHEN SQL%NOTFOUND;

      OPEN c1(lv_batch_id);
      FETCH c1 BULK COLLECT INTO lb_rowid;
      CLOSE c1;

      MSC_CL_PRE_PROCESS.v_sql_stmt := 03;
      FORALL j IN lb_rowid.FIRST..lb_rowid.LAST
      UPDATE msc_st_supplies
      SET    st_transaction_id   = msc_st_supplies_s.NEXTVAL,
             refresh_id          = MSC_CL_PRE_PROCESS.v_refresh_id,
             last_update_date    = MSC_CL_PRE_PROCESS.v_current_date,
             last_updated_by     = MSC_CL_PRE_PROCESS.v_current_user,
             creation_date       = MSC_CL_PRE_PROCESS.v_current_date,
             created_by          = MSC_CL_PRE_PROCESS.v_current_user
      WHERE  rowid               = lb_rowid(j);

      lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_INVALID_COL_VALUE',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'DELETED_FLAG',
                      p_token2            => 'DEFAULT_VALUE',
                      p_token_value2      => MSC_CL_PRE_PROCESS.SYS_NO);

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

      lv_where_str :=
      ' AND NVL(deleted_flag,'||MSC_CL_PRE_PROCESS.NULL_VALUE||') NOT IN(1,2)';
      --Log a warning for those records where the deleted_flag has a value other
      --SYS_NO
      lv_return := MSC_ST_UTIL.LOG_ERROR
                     (p_table_name        => 'MSC_ST_SUPPLIES',
                      p_instance_code     => MSC_CL_PRE_PROCESS.v_instance_code,
                      p_row               => lv_column_names,
                      p_severity          => MSC_CL_PRE_PROCESS.G_SEV_WARNING,
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_batch_id          => lv_batch_id,
                      p_where_str         => lv_where_str,
                      p_col_name          => 'DELETED_FLAG',
                      p_debug             => MSC_CL_PRE_PROCESS.v_debug,
                      p_default_value     => MSC_CL_PRE_PROCESS.SYS_NO);

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

      lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_INVALID_VALUE',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'ORGANIZATION_CODE');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

      --Derive Organization_id
      lv_return := MSC_ST_UTIL.DERIVE_PARTNER_ORG_ID
                     (p_table_name       => 'MSC_ST_SUPPLIES',
                      p_org_partner_name => 'ORGANIZATION_CODE',
                      p_org_partner_id   => 'ORGANIZATION_ID',
                      p_instance_code    => MSC_CL_PRE_PROCESS.v_instance_code,
                      p_partner_type     => MSC_CL_PRE_PROCESS.G_ORGANIZATION,
                      p_error_text       => lv_error_text,
                      p_batch_id         => lv_batch_id,
                      p_severity         => MSC_CL_PRE_PROCESS.G_SEV_ERROR,
                      p_message_text     => lv_message_text,
                      p_debug            => MSC_CL_PRE_PROCESS.v_debug,
                      p_row              => lv_column_names);

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

      lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_INVALID_VALUE',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'ITEM_NAME');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

      --Derive Inventory_item_id
      lv_return := MSC_ST_UTIL.DERIVE_ITEM_ID
                     (p_table_name       => 'MSC_ST_SUPPLIES',
                      p_item_col_name    => 'ITEM_NAME',
                      p_item_col_id      => 'INVENTORY_ITEM_ID',
                      p_instance_id      => MSC_CL_PRE_PROCESS.v_instance_id,
                      p_instance_code    => MSC_CL_PRE_PROCESS.v_instance_code,
                      p_error_text       => lv_error_text,
                      p_batch_id         => lv_batch_id,
                      p_severity         => MSC_CL_PRE_PROCESS.G_SEV_ERROR,
                      p_message_text     => lv_message_text,
                      p_debug            => MSC_CL_PRE_PROCESS.v_debug,
                      p_row              => lv_column_names);

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

      lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_COL_VAL_NULL',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'NEW_SCHEDULE_DATE OR NEW_ORDER_QUANTITY');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

      MSC_CL_PRE_PROCESS.v_sql_stmt := 04;
      lv_sql_stmt :=
      'UPDATE msc_st_supplies '
      ||' SET   error_text   = '||''''||lv_message_text||''''||','
      ||'     process_flag = '||MSC_CL_PRE_PROCESS.G_ERROR_FLG
      ||' WHERE (NVL(new_schedule_date,sysdate-36500) = sysdate-36500'
      ||' OR    NVL(new_order_quantity,'||MSC_CL_PRE_PROCESS.NULL_VALUE|| ')= '||MSC_CL_PRE_PROCESS.NULL_VALUE||')'
      ||' AND   deleted_flag                   = '||MSC_CL_PRE_PROCESS.SYS_NO
      ||' AND   process_flag                   = '||MSC_CL_PRE_PROCESS.G_IN_PROCESS
      ||' AND   NVL(batch_id,'||MSC_CL_PRE_PROCESS.NULL_VALUE||') = :lv_batch_id'
      ||' AND   sr_instance_code               = :v_instance_code';

      IF MSC_CL_PRE_PROCESS.V_DEBUG THEN
        msc_st_util.log_message(lv_sql_stmt);
      END IF;

      EXECUTE IMMEDIATE lv_sql_stmt
              USING     lv_batch_id,
                        MSC_CL_PRE_PROCESS.v_instance_code;

      lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_COL_VAL_NULL',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'WIP_ENTITY_NAME');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

      MSC_CL_PRE_PROCESS.v_sql_stmt := 05;
      lv_sql_stmt :=
      'UPDATE   msc_st_supplies '
      ||' SET   error_text   = '||''''||lv_message_text||''''||','
      ||'       process_flag = '||MSC_CL_PRE_PROCESS.G_ERROR_FLG
      ||' WHERE NVL(wip_entity_name,'||''''||MSC_CL_PRE_PROCESS.NULL_CHAR||''''||') '
      ||'       =                   '||''''||MSC_CL_PRE_PROCESS.NULL_CHAR||''''
      ||' AND   process_flag                  = '||MSC_CL_PRE_PROCESS.G_IN_PROCESS
      ||' AND   NVL(batch_id,'||MSC_CL_PRE_PROCESS.NULL_VALUE||')= :lv_batch_id'
      ||' AND   sr_instance_code              = :v_instance_code';

      IF MSC_CL_PRE_PROCESS.V_DEBUG THEN
        msc_st_util.log_message(lv_sql_stmt);
      END IF;

      EXECUTE IMMEDIATE lv_sql_stmt
              USING     lv_batch_id,
                        MSC_CL_PRE_PROCESS.v_instance_code;

      lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_INVALID_COL_VALUE',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'FIRM_PLANNED_TYPE',
                      p_token2            => 'DEFAULT_VALUE',
                      p_token_value2      => MSC_CL_PRE_PROCESS.SYS_NO);

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

      lv_where_str :=
      ' AND NVL(firm_planned_type,'||MSC_CL_PRE_PROCESS.NULL_VALUE||') NOT IN(1,2)'
      ||' AND deleted_flag = '||MSC_CL_PRE_PROCESS.SYS_NO;

      --Log a warning for those records where the firm_planned_type has a value
      --other than 1 and 2

      lv_return := MSC_ST_UTIL.LOG_ERROR
                     (p_table_name        => 'MSC_ST_SUPPLIES',
                      p_instance_code     => MSC_CL_PRE_PROCESS.v_instance_code,
                      p_row               => lv_column_names,
                      p_severity          => MSC_CL_PRE_PROCESS.G_SEV_WARNING,
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_batch_id          => lv_batch_id,
                      p_where_str         => lv_where_str,
                      p_col_name          => 'FIRM_PLANNED_TYPE',
                      p_debug             => MSC_CL_PRE_PROCESS.v_debug,
                      p_default_value     => MSC_CL_PRE_PROCESS.SYS_NO);

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

      lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_INVALID_COL_VALUE',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'WIP_STATUS_CODE',
                      p_token2            => 'DEFAULT_VALUE',
                      p_token_value2      => 1);

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

      lv_where_str := '   AND wip_status_code   <= 1'
                      ||' AND wip_status_code   >= 15'
                      ||' AND deleted_flag       = '||MSC_CL_PRE_PROCESS.SYS_NO;

      --Log a warning for those records where the wip_status_code has a value other
      --than SYS_NO

      lv_return := MSC_ST_UTIL.LOG_ERROR
                     (p_table_name        => 'MSC_ST_SUPPLIES',
                      p_instance_code     => MSC_CL_PRE_PROCESS.v_instance_code,
                      p_row               => lv_column_names,
                      p_severity          => MSC_CL_PRE_PROCESS.G_SEV_WARNING,
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_batch_id          => lv_batch_id,
                      p_where_str         => lv_where_str,
                      p_col_name          => 'WIP_STATUS_CODE',
                      p_debug             => MSC_CL_PRE_PROCESS.v_debug,
                      p_default_value     => 1);

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

      lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_INVALID_COL_VALUE',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'DISPOSITION_STATUS_TYPE',
                      p_token2            => 'DEFAULT_VALUE',
                      p_token_value2      => 1);

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

      lv_where_str :=
      ' AND NVL(disposition_status_type,'||MSC_CL_PRE_PROCESS.NULL_VALUE||') NOT IN(1,2)'
      ||' AND deleted_flag       = '||MSC_CL_PRE_PROCESS.SYS_NO;

      --Log a warning for those records where the firm_planned_type has a value other
      --than SYS_NO

      lv_return := MSC_ST_UTIL.LOG_ERROR
                     (p_table_name        => 'MSC_ST_SUPPLIES',
                      p_instance_code     => MSC_CL_PRE_PROCESS.v_instance_code,
                      p_row               => lv_column_names,
                      p_severity          => MSC_CL_PRE_PROCESS.G_SEV_WARNING,
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_batch_id          => lv_batch_id,
                      p_where_str         => lv_where_str,
                      p_col_name          => 'DISPOSITION_STATUS_TYPE',
                      p_debug             => MSC_CL_PRE_PROCESS.v_debug,
                      p_default_value     => 1);

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

      lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_INVALID_COL_VALUE',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'WIP_SUPPLY_TYPE',
                      p_token2            => 'DEFAULT_VALUE',
                      p_token_value2      => 1);

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

      lv_where_str := '   AND wip_supply_type <= 1'
                      ||' AND wip_supply_type >= 7'
                      ||' AND deleted_flag     = '||MSC_CL_PRE_PROCESS.SYS_NO;

      --Log a warning for those records where the wip_supply_type has a value other
      --than SYS_NO

      lv_return := MSC_ST_UTIL.LOG_ERROR
                     (p_table_name        => 'MSC_ST_SUPPLIES',
                      p_instance_code     => MSC_CL_PRE_PROCESS.v_instance_code,
                      p_row               => lv_column_names,
                      p_severity          => MSC_CL_PRE_PROCESS.G_SEV_WARNING,
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_batch_id          => lv_batch_id,
                      p_where_str         => lv_where_str,
                      p_col_name          => 'WIP_SUPPLY_TYPE',
                      p_debug             =>MSC_CL_PRE_PROCESS.v_debug,
                      p_default_value     => 1);

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

      MSC_CL_PRE_PROCESS.v_sql_stmt := 06;
      lv_sql_stmt :=
      'UPDATE   msc_st_supplies'
      ||' SET   order_number = wip_entity_name'
      ||' WHERE NVL(order_number,'||''''||MSC_CL_PRE_PROCESS.NULL_CHAR||''''||')'
      ||'       =                '||''''||MSC_CL_PRE_PROCESS.NULL_CHAR||''''
      ||' AND   deleted_flag                   = '||MSC_CL_PRE_PROCESS.SYS_NO
      ||' AND   process_flag                   = '||MSC_CL_PRE_PROCESS.G_IN_PROCESS
      ||' AND   NVL(batch_id,'||MSC_CL_PRE_PROCESS.NULL_VALUE||') = :lv_batch_id'
      ||' AND   sr_instance_code               = :v_instance_code';

      IF MSC_CL_PRE_PROCESS.V_DEBUG THEN
        msc_st_util.log_message(lv_sql_stmt);
      END IF;

      EXECUTE IMMEDIATE lv_sql_stmt
              USING     lv_batch_id,
                        MSC_CL_PRE_PROCESS.v_instance_code;

      -- Now we will check whether BOM Name is NULL , if it is NULL we will populate the
      -- ASSEMBLY NAME in BOM NAME column for all such records

      MSC_CL_PRE_PROCESS.v_sql_stmt := 07;
      lv_sql_stmt :=
      'UPDATE msc_st_supplies '
      ||' SET    bill_name           = item_name'
      ||' WHERE  sr_instance_code    = :v_instance_code'
      ||' AND    order_type =86'
      ||' AND    process_flag        ='||MSC_CL_PRE_PROCESS.G_IN_PROCESS
      ||' AND    NVL(bill_name,'||''''||MSC_CL_PRE_PROCESS.NULL_CHAR||''''||') '
      ||'         =            '||''''||MSC_CL_PRE_PROCESS.NULL_CHAR||''''
      ||' AND    NVL(item_name,'||''''||MSC_CL_PRE_PROCESS.NULL_CHAR||''''||') '
      ||'         <>           '||''''||MSC_CL_PRE_PROCESS.NULL_CHAR||''''
      ||' AND    batch_id            = :lv_batch_id';

      IF MSC_CL_PRE_PROCESS.V_DEBUG THEN
        msc_st_util.log_message(lv_sql_stmt);
      END IF;

      EXECUTE IMMEDIATE lv_sql_stmt USING MSC_CL_PRE_PROCESS.v_instance_code,lv_batch_id;

      -- Now check whether Routing  Name is NULL , if it is NULL we will populate
      -- Assembly  Name in Routing Name column for all such records

      MSC_CL_PRE_PROCESS.v_sql_stmt := 08;

      lv_sql_stmt :=
      'UPDATE msc_st_supplies '
      ||' SET    routing_name             = item_name'
      ||' WHERE  sr_instance_code         = :v_instance_code'
      ||' AND    order_type =86'
      ||' AND    process_flag             ='|| MSC_CL_PRE_PROCESS.G_IN_PROCESS
      ||' AND    NVL(routing_name,'||''''||MSC_CL_PRE_PROCESS.NULL_CHAR||''''||') '
      ||'         =               '||''''||MSC_CL_PRE_PROCESS.NULL_CHAR||''''
      ||' AND    NVL(item_name,   '||''''||MSC_CL_PRE_PROCESS.NULL_CHAR||''''||') '
      ||'         <>              '||''''||MSC_CL_PRE_PROCESS.NULL_CHAR||''''
      ||' AND    batch_id                 = :lv_batch_id ';

      IF MSC_CL_PRE_PROCESS.V_DEBUG THEN
        msc_st_util.log_message(lv_sql_stmt);
      END IF;

      EXECUTE IMMEDIATE lv_sql_stmt USING MSC_CL_PRE_PROCESS.v_instance_code,lv_batch_id;

      lv_return := MSC_ST_UTIL.DERIVE_BILL_SEQUENCE_ID
                   (p_table_name     => 'MSC_ST_SUPPLIES',
                    p_bom_col_name   => 'BILL_NAME',
                    p_bom_col_id     => 'BILL_SEQUENCE_ID',
                    p_instance_code  => MSC_CL_PRE_PROCESS.v_instance_code,
                    p_batch_id       => lv_batch_id,
                    p_debug          => MSC_CL_PRE_PROCESS.v_debug,
                    p_error_text     => lv_error_text);


     IF (lv_return <> 0 ) THEN
           RAISE ex_logging_err;
     END IF;

     lv_return := MSC_ST_UTIL.DERIVE_ROUTING_SEQUENCE_ID
                      (p_table_name     => 'MSC_ST_SUPPLIES',
                       p_rtg_col_name   => 'ROUTING_NAME',
                       p_rtg_col_id     => 'ROUTING_SEQUENCE_ID',
                       p_instance_code  => MSC_CL_PRE_PROCESS.v_instance_code,
                       p_batch_id       => lv_batch_id,
                       p_debug          => MSC_CL_PRE_PROCESS.v_debug,
                       p_error_text     => lv_error_text);

    if (lv_return <> 0 )then
       RAISE ex_logging_err;
    end if;




      MSC_CL_PRE_PROCESS.v_sql_stmt := 09;
      lv_sql_stmt :=
      'UPDATE msc_st_supplies mss'
      ||' SET   schedule_group_id   = (SELECT local_id'
      ||'       FROM   msc_local_id_supply mls'
      ||'       WHERE  mls.char4 = mss.schedule_group_name'
      ||'       AND    mls.char3 = mss.organization_code'
      ||'       AND    NVL(mls.char2,       '||''''||MSC_CL_PRE_PROCESS.NULL_CHAR||''''||') = '
      ||'              NVL(mss.company_name,'||''''||MSC_CL_PRE_PROCESS.NULL_CHAR||''''||') '
      ||'       AND    mls.char1 = mss.sr_instance_code'
      ||'       AND    mls.entity_name = ''SCHEDULE_GROUP_ID'' ),'
      ||'     line_id             = (SELECT local_id'
      ||'       FROM   msc_local_id_setup mls'
      ||'       WHERE  mls.char4 = mss.line_code'
      ||'       AND    mls.char3 = mss.organization_code'
      ||'       AND    NVL(mls.char2,       '||''''||MSC_CL_PRE_PROCESS.NULL_CHAR||''''||') = '
      ||'              NVL(mss.company_name,'||''''||MSC_CL_PRE_PROCESS.NULL_CHAR||''''||') '
      ||'       AND    mls.char1 = mss.sr_instance_code'
      ||'       AND    mls.entity_name = ''LINE_ID''),'
      ||'     operation_seq_num   = (SELECT number1'
      ||'       FROM   msc_local_id_setup mls'
      ||'       WHERE  mls.char5 = mss.operation_seq_code'
      ||'       AND    mls.char4 = mss.routing_name'
      ||'       AND    NVL(mls.char6, '||''''||MSC_CL_PRE_PROCESS.NULL_CHAR||''''||') = '
      ||'              NVL(mss.alternate_routing_designator,'||''''||MSC_CL_PRE_PROCESS.NULL_CHAR||''''||') '
      ||'       AND    mls.char3 = mss.organization_code'
      ||'       AND    mls.date1 = mss.effectivity_date'
      ||'       AND    NVL(mls.char2,       '||''''||MSC_CL_PRE_PROCESS.NULL_CHAR||''''||') = '
      ||'              NVL(mss.company_name,'||''''||MSC_CL_PRE_PROCESS.NULL_CHAR||''''||') '
      ||'       AND    mls.char1 = mss.sr_instance_code'
      ||'       AND    mls.entity_name = ''OPERATION_SEQUENCE_ID'' )'
      ||' WHERE  deleted_flag               = '||MSC_CL_PRE_PROCESS.SYS_NO
      ||' AND    process_flag               = '||MSC_CL_PRE_PROCESS.G_IN_PROCESS
      ||' AND NVL(batch_id,'||MSC_CL_PRE_PROCESS.NULL_VALUE||')= :lv_batch_id'
      ||' AND    sr_instance_code           = :v_instance_code';

      IF MSC_CL_PRE_PROCESS.V_DEBUG THEN
        msc_st_util.log_message(lv_sql_stmt);
      END IF;

      EXECUTE IMMEDIATE lv_sql_stmt
              USING     lv_batch_id,
                        MSC_CL_PRE_PROCESS.v_instance_code;


      lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_INVALID_COL_VALUE',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'BILL_SEQUENCE_ID OR ROUTING_SEQUENCE_ID',
                      p_token2            => 'DEFAULT_VALUE',
                      p_token_value2      => MSC_CL_PRE_PROCESS.SYS_NO);

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

      lv_where_str :=
      '   AND (NVL(bill_sequence_id,  '||MSC_CL_PRE_PROCESS.NULL_VALUE||') = '||MSC_CL_PRE_PROCESS.NULL_VALUE
      ||' OR  NVL(routing_sequence_id,'||MSC_CL_PRE_PROCESS.NULL_VALUE||') = '||MSC_CL_PRE_PROCESS.NULL_VALUE||')'
      ||' AND deleted_flag = '||MSC_CL_PRE_PROCESS.SYS_NO;

      --Log a warning for those records where the bill_sequence_id or
      --routing_sequence_id has null values

      lv_return := MSC_ST_UTIL.LOG_ERROR
                     (p_table_name        => 'MSC_ST_SUPPLIES',
                      p_instance_code     => MSC_CL_PRE_PROCESS.v_instance_code,
                      p_row               => lv_column_names,
                      p_severity          => MSC_CL_PRE_PROCESS.G_SEV_WARNING,
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_batch_id          => lv_batch_id,
                      p_debug             => MSC_CL_PRE_PROCESS.v_debug,
                      p_where_str         => lv_where_str);

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

      --Deriving wip_entity_id
      MSC_CL_PRE_PROCESS.v_sql_stmt := 10;
      lv_sql_stmt :=
      'UPDATE msc_st_supplies mss'
      ||' SET wip_entity_id     = (SELECT local_id'
      ||'       FROM   msc_local_id_supply mls'
      ||'       WHERE  mls.char4 = mss.wip_entity_name'
      ||'       AND    mls.char3 = mss.organization_code'
      ||'       AND    NVL(mls.char2,       '||''''||MSC_CL_PRE_PROCESS.NULL_CHAR||''''||') = '
      ||'              NVL(mss.company_name,'||''''||MSC_CL_PRE_PROCESS.NULL_CHAR||''''||') '
      ||'       AND    mls.char1 = mss.sr_instance_code'
      ||'       AND    mls.entity_name = ''WIP_ENTITY_ID'' )'
      ||' WHERE  process_flag                   = '||MSC_CL_PRE_PROCESS.G_IN_PROCESS
      ||' AND    NVL(batch_id,'||MSC_CL_PRE_PROCESS.NULL_VALUE||') = :lv_batch_id'
      ||' AND    sr_instance_code               = :v_instance_code';

      IF MSC_CL_PRE_PROCESS.V_DEBUG THEN
        msc_st_util.log_message(lv_sql_stmt);
      END IF;

      EXECUTE IMMEDIATE lv_sql_stmt
              USING     lv_batch_id,
                        MSC_CL_PRE_PROCESS.v_instance_code;


      lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_DELETE_FAIL',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text);

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

      MSC_CL_PRE_PROCESS.v_sql_stmt := 11;

      lv_sql_stmt :=
      'UPDATE   msc_st_supplies '
      ||' SET   process_flag        = '||MSC_CL_PRE_PROCESS.G_ERROR_FLG||','
      ||'         error_text   = '||''''||lv_message_text||''''
      ||' WHERE NVL(wip_entity_id,'||MSC_CL_PRE_PROCESS.NULL_VALUE||') = '||MSC_CL_PRE_PROCESS.NULL_VALUE
      ||' AND   deleted_flag        ='||MSC_CL_PRE_PROCESS.SYS_YES
      ||' AND   process_flag        = '||MSC_CL_PRE_PROCESS.G_IN_PROCESS
      ||' AND   NVL(batch_id,'||MSC_CL_PRE_PROCESS.NULL_VALUE||')= :lv_batch_id '
      ||' AND   sr_instance_code    =:v_instance_code';

      IF MSC_CL_PRE_PROCESS.V_DEBUG THEN
        msc_st_util.log_message(lv_sql_stmt);
      END IF;

      EXECUTE IMMEDIATE lv_sql_stmt
              USING     lv_batch_id,
                        MSC_CL_PRE_PROCESS.v_instance_code;


     -- update the jump_op_seq_num for lot based jobs for the operations jumped outside the network

      lv_sql_stmt :=
      'UPDATE   msc_st_supplies '
      ||' SET jump_op_seq_num = 50000'
      ||' WHERE NVL(jump_op_seq_code,'||''''||MSC_CL_PRE_PROCESS.NULL_CHAR||''''||') '
      ||'         = '||''''||50000||''''
      ||' AND   process_flag        = '||MSC_CL_PRE_PROCESS.G_IN_PROCESS
      ||' AND   NVL(batch_id,'||MSC_CL_PRE_PROCESS.NULL_VALUE||')= :lv_batch_id '
      ||' AND   order_type    =86'
      ||' AND   sr_instance_code    =:v_instance_code';

      IF MSC_CL_PRE_PROCESS.V_DEBUG THEN
        msc_st_util.log_message(lv_sql_stmt);
      END IF;

      EXECUTE IMMEDIATE lv_sql_stmt
              USING     lv_batch_id,
                        MSC_CL_PRE_PROCESS.v_instance_code;


      lv_sql_stmt :=
      'UPDATE msc_st_supplies mss'
      ||' SET  jump_op_seq_num   = (SELECT number1'
      ||'       FROM   msc_local_id_setup mls'
      ||'       WHERE  NVL(mls.char5,'||''''||MSC_CL_PRE_PROCESS.NULL_CHAR||''''||') = '
      ||'              NVL(mss.jump_op_seq_code,'||''''||MSC_CL_PRE_PROCESS.NULL_CHAR||''''||') '
      ||'       AND    mls.char4 = mss.routing_name'
      ||'       AND    NVL(mls.char6, '||''''||MSC_CL_PRE_PROCESS.NULL_CHAR||''''||') = '
      ||'              NVL(mss.alternate_routing_designator,'||''''||MSC_CL_PRE_PROCESS.NULL_CHAR||''''||') '
      ||'       AND    mls.char3 = mss.organization_code'
      ||'       AND    mls.date1 = mss.jump_op_effectivity_date'
      ||'       AND    NVL(mls.char2,       '||''''||MSC_CL_PRE_PROCESS.NULL_CHAR||''''||') = '
      ||'              NVL(mss.company_name,'||''''||MSC_CL_PRE_PROCESS.NULL_CHAR||''''||') '
      ||'       AND    mls.char1 = mss.sr_instance_code'
      ||'       AND    mls.entity_name = ''OPERATION_SEQUENCE_ID'' )'
      ||' WHERE  deleted_flag               = '||MSC_CL_PRE_PROCESS.SYS_NO
      ||' AND    process_flag               = '||MSC_CL_PRE_PROCESS.G_IN_PROCESS
      ||' AND    jump_op_seq_num            <> 50000 '
      ||' AND NVL(batch_id,'||MSC_CL_PRE_PROCESS.NULL_VALUE||')= :lv_batch_id'
      ||' AND    sr_instance_code           = :v_instance_code';


      IF MSC_CL_PRE_PROCESS.V_DEBUG THEN
        msc_st_util.log_message(lv_sql_stmt);
      END IF;

      EXECUTE IMMEDIATE lv_sql_stmt
              USING     lv_batch_id,
                        MSC_CL_PRE_PROCESS.v_instance_code;


      --Call to customised validation.
      MSC_CL_PRE_PROCESS_HOOK.ENTITY_VALIDATION
        (ERRBUF         => lv_error_text,
         RETCODE        => lv_return,
         pBatchID       => lv_batch_id,
         pInstanceCode  => MSC_CL_PRE_PROCESS.v_instance_code,
         pEntityName    => 'MSC_ST_SUPPLIES_ERO',
         pInstanceID    => MSC_CL_PRE_PROCESS.v_instance_id);

      IF NVL(lv_return,0) <> 0 THEN
        RAISE ex_logging_err;
      END IF;

      --Generation of wip_entity_id
      OPEN  c2(lv_batch_id);
      FETCH c2 BULK COLLECT INTO lb_rowid ;

      IF c2%ROWCOUNT > 0  THEN
        MSC_CL_PRE_PROCESS.v_sql_stmt := 12;
        FORALL j IN lb_rowid.FIRST..lb_rowid.LAST
        UPDATE  msc_st_supplies
        SET     wip_entity_id = msc_st_wip_entity_id_s.NEXTVAL
        WHERE rowid           = lb_rowid(j);

        MSC_CL_PRE_PROCESS.v_sql_stmt := 13;
        FORALL j IN lb_rowid.FIRST..lb_rowid.LAST
        INSERT INTO msc_local_id_supply
          (local_id,
           st_transaction_id,
           instance_id,
           entity_name,
           data_source_type,
           char1,
           char2,
           char3,
           char4,
           SOURCE_ORG_ID,
           SOURCE_INVENTORY_ITEM_ID,
           SOURCE_BILL_SEQUENCE_ID,
           SOURCE_ROUTING_SEQUENCE_ID,
           SOURCE_SCHEDULE_GROUP_ID,
           SOURCE_WIP_ENTITY_ID,
           last_update_date,
           last_updated_by,
           creation_date,
           created_by)
        SELECT
            wip_entity_id,
            st_transaction_id,
            MSC_CL_PRE_PROCESS.v_instance_id,
            'WIP_ENTITY_ID',
            data_source_type,
            MSC_CL_PRE_PROCESS.v_instance_code,
            company_name,
            organization_code ,
            wip_entity_name,
            SOURCE_ORG_ID,
            SOURCE_INVENTORY_ITEM_ID,
            SOURCE_BILL_SEQUENCE_ID,
            SOURCE_ROUTING_SEQUENCE_ID,
            SOURCE_SCHEDULE_GROUP_ID,
            SOURCE_WIP_ENTITY_ID,
            MSC_CL_PRE_PROCESS.v_current_date,
            MSC_CL_PRE_PROCESS.v_current_user,
            MSC_CL_PRE_PROCESS.v_current_date,
            MSC_CL_PRE_PROCESS.v_current_user
        FROM msc_st_supplies
        WHERE  rowid            = lb_rowid(j);

      END IF;
      CLOSE c2 ;

      --Generation of schedule_group_id
      OPEN c3(lv_batch_id);
      FETCH c3 BULK COLLECT INTO lb_rowid ;

      IF c3%ROWCOUNT > 0  THEN
        MSC_CL_PRE_PROCESS.v_sql_stmt := 14;
        FORALL j IN lb_rowid.FIRST..lb_rowid.LAST
        UPDATE  msc_st_supplies
        SET     schedule_group_id = msc_st_schedule_group_id_s.NEXTVAL
        WHERE rowid               = lb_rowid(j);

        MSC_CL_PRE_PROCESS.v_sql_stmt := 15;
        FORALL j IN lb_rowid.FIRST..lb_rowid.LAST
        INSERT INTO msc_local_id_supply
          (local_id,
           st_transaction_id,
           instance_id,
           entity_name,
           data_source_type,
           char1,
           char2,
           char3,
           char4,
           SOURCE_ORG_ID,
           SOURCE_INVENTORY_ITEM_ID,
           SOURCE_BILL_SEQUENCE_ID,
           SOURCE_ROUTING_SEQUENCE_ID,
           SOURCE_SCHEDULE_GROUP_ID,
           SOURCE_WIP_ENTITY_ID,
           last_update_date,
           last_updated_by,
           creation_date,
           created_by)
        SELECT
            schedule_group_id,
            st_transaction_id,
            MSC_CL_PRE_PROCESS.v_instance_id,
           'SCHEDULE_GROUP_ID',
            data_source_type,
            MSC_CL_PRE_PROCESS.v_instance_code,
            company_name,
            organization_code ,
            schedule_group_name,
            SOURCE_ORG_ID,
            SOURCE_INVENTORY_ITEM_ID,
            SOURCE_BILL_SEQUENCE_ID,
            SOURCE_ROUTING_SEQUENCE_ID,
            SOURCE_SCHEDULE_GROUP_ID,
            SOURCE_WIP_ENTITY_ID,
            MSC_CL_PRE_PROCESS.v_current_date,
            MSC_CL_PRE_PROCESS.v_current_user,
            MSC_CL_PRE_PROCESS.v_current_date,
            MSC_CL_PRE_PROCESS.v_current_user
        FROM msc_st_supplies
        WHERE  rowid            = lb_rowid(j);

      END IF;
      CLOSE c3;

      --Update disposition_id with the wip_entity_id.
      MSC_CL_PRE_PROCESS.v_sql_stmt := 16;
      UPDATE msc_st_supplies
      SET    disposition_id    = wip_entity_id
      WHERE  process_flag      = MSC_CL_PRE_PROCESS.G_IN_PROCESS
      AND    batch_id          = lv_batch_id
      AND    sr_instance_code  = MSC_CL_PRE_PROCESS.v_instance_code;

      lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_FK_REF_NOT_EXIST',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAMES',
                      p_token_value1      => '  SR_INSTANCE_CODE, COMPANY_NAME,'
                                             ||' ORGANIZATION_CODE AND PROJECT_NUMBER',
                      p_token2            => 'MASTER_TABLE',
                      p_token_value2      => 'MSC_ST_PROJECT_TASKS');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

     --Derive Project Id.
      lv_return := MSC_ST_UTIL.DERIVE_PROJ_TASK_ID
                             (p_table_name          => 'MSC_ST_SUPPLIES',
                              p_proj_col_name       => 'PROJECT_NUMBER',
                              p_proj_task_col_id    => 'PROJECT_ID',
                              p_instance_code       => MSC_CL_PRE_PROCESS.v_instance_code,
                              p_entity_name         => 'PROJECT_ID',
                              p_error_text          => lv_error_text,
                              p_batch_id            => lv_batch_id,
                              p_severity            => MSC_CL_PRE_PROCESS.G_SEV_WARNING,
                              p_message_text        => lv_message_text,
                              p_debug               => MSC_CL_PRE_PROCESS.v_debug,
                              p_row                 => lv_column_names);
      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

      lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_FK_REF_NOT_EXIST',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAMES',
                      p_token_value1      => '  SR_INSTANCE_CODE, COMPANY_NAME,'
                                             ||' ORGANIZATION_CODE, PROJECT_NUMBER,'
                                             ||' TASK_NUMBER',
                      p_token2            => 'MASTER_TABLE',
                      p_token_value2      => 'MSC_ST_PROJECT_TASKS');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

      --Derive Task Id.
      lv_return := MSC_ST_UTIL.DERIVE_PROJ_TASK_ID
                             (p_table_name          => 'MSC_ST_SUPPLIES',
                              p_proj_col_name       => 'PROJECT_NUMBER',
                              p_proj_task_col_id    => 'TASK_ID',
                              p_instance_code       => MSC_CL_PRE_PROCESS.v_instance_code,
                              p_entity_name         => 'TASK_ID',
                              p_error_text          => lv_error_text,
                              p_task_col_name       => 'TASK_NUMBER',
                              p_batch_id            => lv_batch_id,
                              p_severity            => MSC_CL_PRE_PROCESS.G_SEV_WARNING,
                              p_message_text        => lv_message_text,
                              p_debug               => MSC_CL_PRE_PROCESS.v_debug,
                              p_row                 => lv_column_names);

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;


      MSC_CL_PRE_PROCESS.v_sql_stmt := 17;
      lv_sql_stmt :=
      'UPDATE msc_st_supplies mss '
      ||' SET  schedule_group_id   = (SELECT local_id'
      ||'       FROM   msc_local_id_supply mls'
      ||'       WHERE  mls.char4 = mss.schedule_group_name'
      ||'       AND    mls.char3 = mss.organization_code'
      ||'       AND    NVL(mls.char2,       '||''''||MSC_CL_PRE_PROCESS.NULL_CHAR||''''||') = '
      ||'              NVL(mss.company_name,'||''''||MSC_CL_PRE_PROCESS.NULL_CHAR||''''||') '
      ||'       AND    mls.char1 = mss.sr_instance_code'
      ||'       AND    mls.entity_name = ''SCHEDULE_GROUP_ID'' )'
      ||' WHERE  deleted_flag                      = '||MSC_CL_PRE_PROCESS.SYS_NO
      ||' AND    process_flag                      = '||MSC_CL_PRE_PROCESS.G_IN_PROCESS
      ||' AND    NVL(schedule_group_id,'||MSC_CL_PRE_PROCESS.NULL_VALUE||') = '||MSC_CL_PRE_PROCESS.NULL_VALUE
      ||' AND NVL(batch_id,'||MSC_CL_PRE_PROCESS.NULL_VALUE||')= :lv_batch_id'
      ||' AND    sr_instance_code           = :v_instance_code';

      IF MSC_CL_PRE_PROCESS.V_DEBUG THEN
        msc_st_util.log_message(lv_sql_stmt);
      END IF;

      EXECUTE IMMEDIATE lv_sql_stmt
              USING     lv_batch_id,
                        MSC_CL_PRE_PROCESS.v_instance_code;

     OPEN c4(lv_batch_id);
     FETCH c4 BULK COLLECT INTO lb_rowid ;

     IF c4%ROWCOUNT > 0  THEN

     FORALL j IN lb_rowid.FIRST..lb_rowid.LAST

        UPDATE msc_st_supplies
        SET    job_op_seq_num      =
               to_number(decode(length(rtrim(job_op_seq_code,'0123456789')),
                         NULL,job_op_seq_code,'1'))
        WHERE  rowid     = lb_rowid(j);
     END IF;
     CLOSE c4;

      lv_return := MSC_ST_UTIL.SET_PROCESS_FLAG
                  (p_table_name     => 'MSC_ST_SUPPLIES',
                   p_instance_id    => MSC_CL_PRE_PROCESS.v_instance_id,
                   p_instance_code  => MSC_CL_PRE_PROCESS.v_instance_code,
                   p_process_flag   => MSC_CL_PRE_PROCESS.G_VALID,
                   p_error_text     => lv_error_text,
                   p_debug          => MSC_CL_PRE_PROCESS.v_debug,
                   p_batch_id       => lv_batch_id);
      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

      lv_return := MSC_ST_UTIL.LOG_ERROR
                   (p_table_name        => 'MSC_ST_SUPPLIES',
                    p_instance_code     => MSC_CL_PRE_PROCESS.v_instance_code,
                    p_row               => lv_column_names,
                    p_severity          => MSC_CL_PRE_PROCESS.G_SEV_ERROR,
                    p_message_text      => NULL,
                    p_error_text        => lv_error_text,
                    p_debug             => MSC_CL_PRE_PROCESS.v_debug,
                    p_batch_id          => lv_batch_id);

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

      COMMIT;
    END LOOP;
  EXCEPTION
    WHEN too_many_rows THEN
      lv_error_text  := substr('MSC_CL_PRE_PROCESS.LOAD_ERO_SUPPLY'||'('
                      ||MSC_CL_PRE_PROCESS.v_sql_stmt||')'|| SQLERRM, 1, 240);
      msc_st_util.log_message(lv_error_text);
      ROLLBACK;

    WHEN ex_logging_err THEN
      msc_st_util.log_message(lv_error_text);
      ROLLBACK;

    WHEN OTHERS THEN
      lv_error_text    := substr('MSC_CL_PRE_PROCESS.LOAD_WO_SUPPLY'||'('
                       ||MSC_CL_PRE_PROCESS.v_sql_stmt||')'|| SQLERRM, 1, 240);
      msc_st_util.log_message(lv_error_text);
      ROLLBACK;

  END LOAD_ERO_SUPPLY;

   PROCEDURE  LOAD_ERO_DEMAND  IS

  TYPE RowidTab IS TABLE OF ROWID INDEX BY BINARY_INTEGER;

  lb_rowid          RowidTab;

  lv_local_id       NUMBER;
  lv_sequence       NUMBER;
  lv_column_names   VARCHAR2(5000);     -- Stores cocatenated column names
  lv_return         NUMBER;
  lv_error_text     VARCHAR2(250);
  lv_where_str      VARCHAR2(5000);
  lv_sql_stmt       VARCHAR2(5000);
  lv_cursor_stmt    VARCHAR2(5000);
  lv_batch_id       msc_st_demands.batch_id%TYPE;
  lv_message_text   msc_errors.error_text%TYPE;

  ex_logging_err    EXCEPTION;

  CURSOR c1(p_batch_id NUMBER) IS
    SELECT rowid
    FROM   msc_st_demands
    WHERE  process_flag      IN (MSC_CL_PRE_PROCESS.G_IN_PROCESS,MSC_CL_PRE_PROCESS.G_ERROR_FLG)
    AND    origination_type  =77
    AND    batch_id          = p_batch_id
    AND    sr_instance_code  = MSC_CL_PRE_PROCESS.v_instance_code
    AND    ENTITY='ERO';

   CURSOR c2(p_batch_id NUMBER) IS
    SELECT max(rowid)
    FROM   msc_st_demands
    WHERE  process_flag     = MSC_CL_PRE_PROCESS.G_IN_PROCESS
    AND    sr_instance_code = MSC_CL_PRE_PROCESS.v_instance_code
    AND    batch_id         = p_batch_id
    AND    origination_type =77  -- Not for flow schedule
    AND    NVL(operation_seq_num,MSC_CL_PRE_PROCESS.NULL_VALUE) = MSC_CL_PRE_PROCESS.NULL_VALUE
    AND    deleted_flag     = MSC_CL_PRE_PROCESS.SYS_NO
    AND    ENTITY='ERO'
    GROUP BY sr_instance_code,company_name,organization_code,routing_name,
    operation_seq_code,alternate_routing_designator,operation_effectivity_date;


  BEGIN

  -- Before we start processing the record by group id( batch size ) we are going
  -- to check whether that there
  -- is any duplicates for user defined unique keys (UDKs,)

   --For WIP component demand

   --Duplicate records check for the records whose source is XML
    lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                 (p_app_short_name    => 'MSC',
                  p_error_code        => 'MSC_PP_DUP_REC_FOR_XML',
                  p_message_text      => lv_message_text,
                  p_error_text        => lv_error_text);

    IF lv_return <> 0 THEN
      RAISE ex_logging_err;
    END IF;

  MSC_CL_PRE_PROCESS.v_sql_stmt := 01;

  lv_sql_stmt :=
  'UPDATE   msc_st_demands msd1'
  ||' SET     process_flag  = '||MSC_CL_PRE_PROCESS.G_ERROR_FLG||','
  ||'         error_text   = '||''''||lv_message_text||''''
  ||' WHERE   message_id <  (SELECT MAX(message_id)'
  ||'         FROM msc_st_demands msd2'
  ||'         WHERE  msd2.sr_instance_code '
  ||'                = msd1.sr_instance_code '
  ||'         AND   msd2.organization_code '
  ||'                = msd1.organization_code '
  ||'         AND   NVL(msd2.company_name,'||''''||MSC_CL_PRE_PROCESS.NULL_CHAR||''''||') '
  ||'                 =    NVL(msd1.company_name,'||''''||MSC_CL_PRE_PROCESS.NULL_CHAR||''''||') '
  ||'         AND msd2.wip_entity_name = msd1.wip_entity_name'
  ||'         AND NVL(msd2.operation_seq_code,'||''''||MSC_CL_PRE_PROCESS.NULL_CHAR||''''||') '
  ||'                = NVL(msd1.operation_seq_code,'||''''||MSC_CL_PRE_PROCESS.NULL_CHAR||''''||') '
  ||'         AND    msd2.item_name '
  ||'                = msd1.item_name '
  ||'         AND  msd2.origination_type '
  ||'               = msd1.origination_type'
  ||'         AND   msd2.process_flag = '||MSC_CL_PRE_PROCESS.G_IN_PROCESS
  ||'         AND    NVL(msd2.message_id,'||MSC_CL_PRE_PROCESS.NULL_VALUE||')<> '||MSC_CL_PRE_PROCESS.NULL_VALUE||')'
  ||' AND     msd1.process_flag ='|| MSC_CL_PRE_PROCESS.G_IN_PROCESS
  ||' AND     msd1.origination_type =77 '
  ||' AND     msd1.ENTITY =''ERO'''
  ||' AND     msd1.sr_instance_code = :v_instance_code '
  ||' AND     NVL(msd1.message_id,'||MSC_CL_PRE_PROCESS.NULL_VALUE||')<> '||MSC_CL_PRE_PROCESS.NULL_VALUE;

  IF MSC_CL_PRE_PROCESS.V_DEBUG THEN
         msc_st_util.log_message(lv_sql_stmt);
  END IF;

  EXECUTE IMMEDIATE lv_sql_stmt USING MSC_CL_PRE_PROCESS.v_instance_code;

  --Duplicate records check for the records whose source is batch load

    lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                 (p_app_short_name    => 'MSC',
                  p_error_code        => 'MSC_PP_DUP_REC_FOR_BATCH_LOAD',
                  p_message_text      => lv_message_text,
                  p_error_text        => lv_error_text);

    IF lv_return <> 0 THEN
      RAISE ex_logging_err;
    END IF;

  MSC_CL_PRE_PROCESS.v_sql_stmt := 02;

  lv_sql_stmt :=
  'UPDATE msc_st_demands   msd1'
  ||' SET     process_flag  = '||MSC_CL_PRE_PROCESS.G_ERROR_FLG||','
  ||'         error_text   = '||''''||lv_message_text||''''
  ||' WHERE   EXISTS( SELECT 1 '
  ||'         FROM msc_st_demands msd2'
  ||'         WHERE  msd2.sr_instance_code '
  ||'                = msd1.sr_instance_code '
  ||'          AND   msd2.organization_code '
  ||'                = msd1.organization_code '
  ||'          AND   NVL(msd2.company_name,'||''''||MSC_CL_PRE_PROCESS.NULL_CHAR||''''||') '
  ||'                 =    NVL(msd1.company_name,'||''''||MSC_CL_PRE_PROCESS.NULL_CHAR||''''||') '
  ||'          AND   msd2.wip_entity_name = msd1.wip_entity_name'
  ||'          AND   NVL(msd2.operation_seq_code,'||''''||MSC_CL_PRE_PROCESS.NULL_CHAR||''''||') '
  ||'                = NVL(msd1.operation_seq_code,'||''''||MSC_CL_PRE_PROCESS.NULL_CHAR||''''||') '
  ||'          AND   msd2.item_name '
  ||'                = msd1.item_name '
  ||'          AND   msd2.origination_type '
  ||'                = msd1.origination_type'
  ||'          AND   msd2.process_flag = '||MSC_CL_PRE_PROCESS.G_IN_PROCESS
  ||'          AND NVL(msd2.message_id,'||MSC_CL_PRE_PROCESS.NULL_VALUE||') = '||MSC_CL_PRE_PROCESS.NULL_VALUE
  ||'       GROUP BY  sr_instance_code,organization_code,wip_entity_name,'
  ||'       company_name,operation_seq_code,item_name,origination_type'
  ||'       HAVING COUNT(*) > 1)'
  ||' AND   msd1.process_flag  = '||MSC_CL_PRE_PROCESS.G_IN_PROCESS
  ||' AND   msd1.origination_type =77'
  ||' AND     msd1.ENTITY =''ERO'''
  ||' AND   msd1.sr_instance_code = :v_instance_code'
  ||' AND   NVL(msd1.message_id,'||MSC_CL_PRE_PROCESS.NULL_VALUE||') = '||MSC_CL_PRE_PROCESS.NULL_VALUE;

  IF MSC_CL_PRE_PROCESS.V_DEBUG THEN
         msc_st_util.log_message(lv_sql_stmt);
  END IF;

  EXECUTE IMMEDIATE lv_sql_stmt USING MSC_CL_PRE_PROCESS.v_instance_code;

  lv_column_names :=
  'ITEM_NAME                          ||''~''||'
  ||' ORGANIZATION_CODE               ||''~''||'
  ||' USING_REQUIREMENT_QUANTITY      ||''~''||'
  ||' WIP_ENTITY_NAME                 ||''~''||'
  ||' USING_ASSEMBLY_DEMAND_DATE      ||''~''||'
  ||' SR_INSTANCE_CODE                ||''~''||'
  ||' USING_ASSEMBLY_ITEM_NAME        ||''~''||'
  ||' OPERATION_SEQ_CODE              ||''~''||'
  ||' ORIGINATION_TYPE                ||''~''||'
  ||' PROJECT_NUMBER                  ||''~''||'
  ||' TASK_NUMBER                     ||''~''||'
  ||' PLANNING_GROUP                  ||''~''||'
  ||' END_ITEM_UNIT_NUMBER            ||''~''||'
  ||' DEMAND_CLASS                    ||''~''||'
  ||' WIP_STATUS_CODE                 ||''~''||'
  ||' WIP_SUPPLY_TYPE                 ||''~''||'
  ||' DELETED_FLAG                    ||''~''||'
  ||' COMPANY_NAME                    ||''~''||'
  ||' DEMAND_TYPE' ;


    LOOP
      MSC_CL_PRE_PROCESS.v_sql_stmt := 03;
      SELECT       msc_st_batch_id_s.NEXTVAL
      INTO         lv_batch_id
      FROM         DUAL;

      MSC_CL_PRE_PROCESS.v_sql_stmt := 04;
      lv_sql_stmt :=
      ' UPDATE    msc_st_demands '
      ||' SET     batch_id  = :lv_batch_id'
      ||' WHERE   process_flag  IN ('||MSC_CL_PRE_PROCESS.G_IN_PROCESS||','||MSC_CL_PRE_PROCESS.G_ERROR_FLG||')'
      ||' AND     sr_instance_code               = :v_instance_code'
      ||' AND     origination_type =77'
      ||' AND     ENTITY =''ERO'''
      ||' AND     NVL(batch_id,'||MSC_CL_PRE_PROCESS.NULL_VALUE||') = '||MSC_CL_PRE_PROCESS.NULL_VALUE
      ||' AND     rownum                        <= '||MSC_CL_PRE_PROCESS.v_batch_size;


      IF MSC_CL_PRE_PROCESS.V_DEBUG THEN
        msc_st_util.log_message(lv_sql_stmt);
      END IF;

      EXECUTE IMMEDIATE lv_sql_stmt
              USING     lv_batch_id,
                        MSC_CL_PRE_PROCESS.v_instance_code;

      EXIT WHEN SQL%NOTFOUND ;

    OPEN c1(lv_batch_id);
    FETCH c1 BULK COLLECT INTO lb_rowid;
    CLOSE c1;

    MSC_CL_PRE_PROCESS.v_sql_stmt := 03;
    FORALL j IN lb_rowid.FIRST..lb_rowid.LAST
    UPDATE msc_st_demands
    SET    st_transaction_id   = msc_st_demands_s.NEXTVAL,
           refresh_id          = MSC_CL_PRE_PROCESS.v_refresh_id,
           last_update_date    = MSC_CL_PRE_PROCESS.v_current_date,
           last_updated_by     = MSC_CL_PRE_PROCESS.v_current_user,
           creation_date       = MSC_CL_PRE_PROCESS.v_current_date,
           created_by          = MSC_CL_PRE_PROCESS.v_current_user
    WHERE  rowid               = lb_rowid(j);

    -- Set the error message
    lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_INVALID_COL_VALUE',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'DELETED_FLAG',
                      p_token2            => 'DEFAULT_VALUE',
                      p_token_value2      =>  MSC_CL_PRE_PROCESS.SYS_NO  );

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;
    --Log a warning for those records where the deleted_flag has a value other
    --SYS_NO

    lv_where_str :=
     ' AND NVL(deleted_flag,'||MSC_CL_PRE_PROCESS.NULL_VALUE||') NOT IN(1,2)';

    lv_return := MSC_ST_UTIL.LOG_ERROR
                   (p_table_name        => 'MSC_ST_DEMANDS',
                    p_instance_code     => MSC_CL_PRE_PROCESS.v_instance_code,
                    p_row               => lv_column_names,
                    p_severity          => MSC_CL_PRE_PROCESS.G_SEV_WARNING,
                    p_message_text      => lv_message_text,
                    p_error_text        => lv_error_text,
                    p_batch_id          => lv_batch_id,
                    p_where_str         => lv_where_str,
                    p_col_name          => 'DELETED_FLAG',
                    p_debug             => MSC_CL_PRE_PROCESS.v_debug,
                    p_default_value     => MSC_CL_PRE_PROCESS.SYS_NO);

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
                      p_token_value1      => 'ORGANIZATION_CODE');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

     --Derive Organization_id
    lv_return := MSC_ST_UTIL.DERIVE_PARTNER_ORG_ID
                   (p_table_name       => 'MSC_ST_DEMANDS',
                    p_org_partner_name => 'ORGANIZATION_CODE',
                    p_org_partner_id   => 'ORGANIZATION_ID',
                    p_instance_code    => MSC_CL_PRE_PROCESS.v_instance_code,
                    p_partner_type     => MSC_CL_PRE_PROCESS.G_ORGANIZATION,
                    p_error_text       => lv_error_text,
                    p_batch_id         => lv_batch_id,
                    p_severity         => MSC_CL_PRE_PROCESS.G_SEV_ERROR,
                    p_message_text     => lv_message_text,
                    p_debug            => MSC_CL_PRE_PROCESS.v_debug,
                    p_row              => lv_column_names);

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
                      p_token_value1      => 'ITEM_NAME');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

    --Derive Inventory_item_id
    lv_return := MSC_ST_UTIL.DERIVE_ITEM_ID
                   (p_table_name       => 'MSC_ST_DEMANDS',
                    p_item_col_name    => 'ITEM_NAME',
                    p_item_col_id      => 'INVENTORY_ITEM_ID',
                    p_instance_id      => MSC_CL_PRE_PROCESS.v_instance_id,
                    p_instance_code    => MSC_CL_PRE_PROCESS.v_instance_code,
                    p_message_text     => lv_message_text,
                    p_error_text       => lv_error_text,
                    p_batch_id         => lv_batch_id,
                    p_severity         => MSC_CL_PRE_PROCESS.G_SEV_ERROR,
                    p_debug            => MSC_CL_PRE_PROCESS.v_debug,
                    p_row              => lv_column_names);

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
                      p_token_value1      => 'USING_ASSEMBLY_ITEM_NAME');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

    --Derive Using_assembly_item_id
    lv_return := MSC_ST_UTIL.DERIVE_ITEM_ID
                   (p_table_name       => 'MSC_ST_DEMANDS',
                    p_item_col_name    => 'USING_ASSEMBLY_ITEM_NAME',
                    p_item_col_id      => 'USING_ASSEMBLY_ITEM_ID',
                    p_instance_id      => MSC_CL_PRE_PROCESS.v_instance_id,
                    p_instance_code    => MSC_CL_PRE_PROCESS.v_instance_code,
                    p_message_text     => lv_message_text,
                    p_error_text       => lv_error_text,
                    p_batch_id         => lv_batch_id,
                    p_severity         => MSC_CL_PRE_PROCESS.G_SEV3_ERROR,
                    p_debug            => MSC_CL_PRE_PROCESS.v_debug,
                    p_row              => lv_column_names);

    IF lv_return <> 0 THEN
        RAISE ex_logging_err;
    END IF;

  -- Derive WIP_ENTITY_ID
   MSC_CL_PRE_PROCESS.v_sql_stmt := 04;

   lv_sql_stmt :=
    'UPDATE   msc_st_demands  msd'
    ||' SET   wip_entity_id = ( SELECT local_id '
    ||'       FROM   msc_local_id_supply mlid'
    ||'       WHERE  mlid.char1    = msd.sr_instance_code'
    ||'       AND   NVL(mlid.char2,'||''''||MSC_CL_PRE_PROCESS.NULL_CHAR||''''||') '
    ||'       =    NVL(msd.company_name,'||''''||MSC_CL_PRE_PROCESS.NULL_CHAR||''''||') '
    ||'       AND    mlid.char3    = msd.organization_code'
    ||'       AND    mlid.char4    = msd.wip_entity_name'
    ||'       AND    mlid.entity_name = ''WIP_ENTITY_ID'' )'
    ||'  WHERE origination_type =77 '
    ||'  AND ENTITY=''ERO'''
    ||'  AND   process_flag     ='||MSC_CL_PRE_PROCESS.G_IN_PROCESS
    ||'  AND   batch_id       = :lv_batch_id'
    ||'  AND   sr_instance_code  =:v_instance_code';

    IF MSC_CL_PRE_PROCESS.V_DEBUG THEN
      msc_st_util.log_message(lv_sql_stmt);
    END IF;

    EXECUTE IMMEDIATE lv_sql_stmt USING lv_batch_id,MSC_CL_PRE_PROCESS.v_instance_code;

    -- Set the error message
    lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_COL_REF_NOT_EXIST',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAMES',
                      p_token_value1      => 'SR_INSTANCE_CODE,COMPANY_NAME,'
                                             ||' ORGANIZATION_CODE,WIP_ENTITY_NAME',
                      p_token2            => 'MASTER_TABLE',
                      p_token_value2      =>  'MSC_ST_SUPPLIES',
                      p_token3            =>  'CHILD_TABLE' ,
                      p_token_value3      =>  'MSC_ST_DEMANDS' );

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

  -- Error out records where WIP_ENTITY_ID is  NULL;

  MSC_CL_PRE_PROCESS.v_sql_stmt := 05;
  lv_sql_stmt :=
  'UPDATE     msc_st_demands '
  ||' SET     process_flag    =  '||MSC_CL_PRE_PROCESS.G_ERROR_FLG||','
  ||'         error_text   = '||''''||lv_message_text||''''
  ||' WHERE   NVL(wip_entity_id,'||MSC_CL_PRE_PROCESS.NULL_VALUE||') ='||MSC_CL_PRE_PROCESS.NULL_VALUE
  ||' AND     process_flag      = '||MSC_CL_PRE_PROCESS.G_IN_PROCESS
  ||' AND     origination_type  =77'
  ||' AND      ENTITY=''ERO'''
  ||' AND     batch_id           = :lv_batch_id'
  ||' AND     sr_instance_code  = :v_instance_code';

  IF MSC_CL_PRE_PROCESS.V_DEBUG THEN
      msc_st_util.log_message(lv_sql_stmt);
  END IF;

  EXECUTE IMMEDIATE lv_sql_stmt USING lv_batch_id,MSC_CL_PRE_PROCESS.v_instance_code;


  -- Set the  message
   lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_COL_VAL_NULL',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'USING_REQUIREMENT_QUANTITY'
                                             || ' OR USING_ASSEMBLY_DEMAND_DATE');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;


  -- Error out records where USING_REQUIREMENT_QUANTITY is NULL;
  -- Error out records where using_assembly_demand_date is NULL

  MSC_CL_PRE_PROCESS.v_sql_stmt := 06;
  lv_sql_stmt :=
  'UPDATE     msc_st_demands '
  ||' SET     process_flag    =  '||MSC_CL_PRE_PROCESS.G_ERROR_FLG||','
  ||'         error_text   = '||''''||lv_message_text||''''
  ||' WHERE (NVL(using_requirement_quantity,'||MSC_CL_PRE_PROCESS.NULL_VALUE||')='||MSC_CL_PRE_PROCESS.NULL_VALUE
  ||'  OR  NVL(using_assembly_demand_date,SYSDATE-36500) = SYSDATE-36500 )'
  ||' AND    process_flag      = '||MSC_CL_PRE_PROCESS.G_IN_PROCESS
  ||' AND    origination_type  =77'
  ||' AND    ENTITY=''ERO'''
  ||' AND    deleted_flag      = '||MSC_CL_PRE_PROCESS.SYS_NO
  ||' AND    batch_id          = :lv_batch_id'
  ||' AND    sr_instance_code  = :v_instance_code';

  IF MSC_CL_PRE_PROCESS.V_DEBUG THEN
      msc_st_util.log_message(lv_sql_stmt);
  END IF;

  EXECUTE IMMEDIATE lv_sql_stmt USING lv_batch_id,MSC_CL_PRE_PROCESS.v_instance_code;


  -- Update using_assembly_item_id = inventory_item_id

  MSC_CL_PRE_PROCESS.v_sql_stmt := 07;
  lv_sql_stmt :=
  ' UPDATE      msc_st_demands'
  ||' SET    using_assembly_item_id  =  inventory_item_id'
  ||' WHERE  process_flag            = '||MSC_CL_PRE_PROCESS.G_IN_PROCESS
  ||' AND    NVL(using_assembly_item_id,'||MSC_CL_PRE_PROCESS.NULL_VALUE||') = '||MSC_CL_PRE_PROCESS.NULL_VALUE
  ||' AND    deleted_flag   = '||MSC_CL_PRE_PROCESS.SYS_NO
  ||' AND   process_flag    = '||MSC_CL_PRE_PROCESS.G_IN_PROCESS
  ||' AND   origination_type =77'
  ||' AND   ENTITY=''ERO'''
  ||' AND   batch_id        = :lv_batch_id'
  ||' AND   deleted_flag    = '||MSC_CL_PRE_PROCESS.SYS_NO
  ||' AND   sr_instance_code = :v_instance_code';

  IF MSC_CL_PRE_PROCESS.V_DEBUG THEN
      msc_st_util.log_message(lv_sql_stmt);
  END IF;

  EXECUTE IMMEDIATE lv_sql_stmt USING lv_batch_id,MSC_CL_PRE_PROCESS.v_instance_code;

  -- Update order_number = wip_entity_name

  MSC_CL_PRE_PROCESS.v_sql_stmt := 08;
  lv_sql_stmt :=
  ' UPDATE   msc_st_demands'
  ||' SET    order_number   = wip_entity_name'
  ||' WHERE  process_flag   = '||MSC_CL_PRE_PROCESS.G_IN_PROCESS
  ||' AND    deleted_flag   = '||MSC_CL_PRE_PROCESS.SYS_NO
  ||' AND    process_flag   = '||MSC_CL_PRE_PROCESS.G_IN_PROCESS
  ||' AND    origination_type =77'
  ||'  AND ENTITY=''ERO'''
  ||' AND    deleted_flag   = '||MSC_CL_PRE_PROCESS.SYS_NO
  ||' AND    batch_id       = :lv_batch_id'
  ||' AND    sr_instance_code  = :v_instance_code';

  IF MSC_CL_PRE_PROCESS.V_DEBUG THEN
      msc_st_util.log_message(lv_sql_stmt);
  END IF;

  EXECUTE IMMEDIATE lv_sql_stmt USING lv_batch_id,MSC_CL_PRE_PROCESS.v_instance_code;

  -- Update disposition_id = wip_entity_id

  MSC_CL_PRE_PROCESS.v_sql_stmt := 09;
  lv_sql_stmt :=
  ' UPDATE       msc_st_demands'
  ||' SET        disposition_id = wip_entity_id'
  ||' WHERE      process_flag  = '||MSC_CL_PRE_PROCESS.G_IN_PROCESS
  ||' AND        NVL(wip_entity_id,'||MSC_CL_PRE_PROCESS.NULL_VALUE||') = '||MSC_CL_PRE_PROCESS.NULL_VALUE
  ||' AND        deleted_flag   = '||MSC_CL_PRE_PROCESS.SYS_NO
  ||' AND        process_flag  = '||MSC_CL_PRE_PROCESS.G_IN_PROCESS
  ||' AND        origination_type =77'
  ||' AND         ENTITY=''ERO'''
  ||' AND        batch_id          = :lv_batch_id'
  ||' AND   sr_instance_code  = :v_instance_code';

  IF MSC_CL_PRE_PROCESS.V_DEBUG THEN
      msc_st_util.log_message(lv_sql_stmt);
  END IF;

  EXECUTE IMMEDIATE lv_sql_stmt USING lv_batch_id,MSC_CL_PRE_PROCESS.v_instance_code;



 -- UPdate MPS_DATE_REQUIRED as using_assembly_demand_date if NULL
 -- This is not reqd for flow schedule

  MSC_CL_PRE_PROCESS.v_sql_stmt := 10;
  lv_sql_stmt :=
  ' UPDATE     msc_st_demands'
  ||' SET      mps_date_required =  using_assembly_demand_date'
  ||' WHERE    process_flag  = '||MSC_CL_PRE_PROCESS.G_IN_PROCESS
  ||' AND      NVL(mps_date_required,SYSDATE-36500) = SYSDATE-36500'
  ||' AND      process_flag  = '||MSC_CL_PRE_PROCESS.G_IN_PROCESS
  ||' AND      origination_type =77'
  ||'  AND     ENTITY=''ERO'''
  ||' AND      deleted_flag   = '||MSC_CL_PRE_PROCESS.SYS_NO
  ||' AND      batch_id          = :lv_batch_id'
  ||' AND      sr_instance_code  = :v_instance_code';

  IF MSC_CL_PRE_PROCESS.V_DEBUG THEN
      msc_st_util.log_message(lv_sql_stmt);
  END IF;

  EXECUTE IMMEDIATE lv_sql_stmt USING lv_batch_id,MSC_CL_PRE_PROCESS.v_instance_code;


    -- Set the error message
    lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_INVALID_COL_VALUE',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'OPERATION_SEQ_CODE',
                      p_token2            => 'DEFAULT_VALUE',
                      p_token_value2      =>  MSC_CL_PRE_PROCESS.G_OPERATION_SEQ_CODE  );

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

     -- Default operation_seq_code as 1 if NULL
     lv_where_str :=
     '    AND NVL(operation_seq_code,'||''''||MSC_CL_PRE_PROCESS.NULL_CHAR||''''||') '
     ||'         = '||''''||MSC_CL_PRE_PROCESS.NULL_CHAR||''''
     ||'  AND origination_type =77'
     ||'  AND ENTITY=''ERO''';

     lv_return := MSC_ST_UTIL.LOG_ERROR
                    (p_table_name        => 'MSC_ST_DEMANDS',
                     p_instance_code     => MSC_CL_PRE_PROCESS.v_instance_code,
                     p_row               => lv_column_names,
                     p_severity          => MSC_CL_PRE_PROCESS.G_SEV_WARNING,
                     p_message_text      => lv_message_text,
                     p_error_text        => lv_error_text,
                     p_batch_id          => lv_batch_id,
                     p_where_str         => lv_where_str,
                     p_col_name          => 'OPERATION_SEQ_CODE',
                     p_debug             => MSC_CL_PRE_PROCESS.v_debug,
                     p_default_value     => MSC_CL_PRE_PROCESS.G_OPERATION_SEQ_CODE);

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

    -- Set the error message
    lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_COL_VAL_NULL_DEFAULT',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'OPERATION_EFFECTIVITY_DATE',
                      p_token2            => 'DEFAULT_VALUE',
                      p_token_value2      =>  SYSDATE  );

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

    -- Default operation_effectivity date as SYSDATE if NULL

     lv_where_str :=
     '   AND NVL(operation_effectivity_date,SYSDATE-36500 ) = SYSDATE-36500 '
     ||' AND origination_type =77'
     ||'  AND ENTITY=''ERO''' ;

     lv_return := MSC_ST_UTIL.LOG_ERROR
                    (p_table_name        => 'MSC_ST_DEMANDS',
                     p_instance_code     => MSC_CL_PRE_PROCESS.v_instance_code,
                     p_row               => lv_column_names,
                     p_severity          => MSC_CL_PRE_PROCESS.G_SEV_WARNING,
                     p_message_text      => lv_message_text,
                     p_error_text        => lv_error_text,
                     p_batch_id          => lv_batch_id,
                     p_where_str         => lv_where_str,
                     p_col_name          => 'OPERATION_EFFECTIVITY_DATE',
                     p_debug             => MSC_CL_PRE_PROCESS.v_debug,
                     p_default_value     => 'SYSDATE');

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

  -- If routing_name is is NULL populate the item_name in routing name

  MSC_CL_PRE_PROCESS.v_sql_stmt := 11;
  lv_sql_stmt :=
  ' UPDATE   msc_st_demands'
  ||' SET    routing_name            =  nvl(USING_ASSEMBLY_ITEM_NAME,item_name)'  /* bug 3768813 */
  ||' WHERE  process_flag            = '||MSC_CL_PRE_PROCESS.G_IN_PROCESS
  ||' AND    NVL(routing_name,'||''''||MSC_CL_PRE_PROCESS.NULL_CHAR||''''||')'
  ||'       = '||''''||MSC_CL_PRE_PROCESS.NULL_CHAR||''''
  ||' AND   process_flag    = '||MSC_CL_PRE_PROCESS.G_IN_PROCESS
  ||' AND   origination_type =77'
  ||' AND   ENTITY=''ERO'''
  ||' AND   batch_id        = :lv_batch_id'
  ||' AND   sr_instance_code = :v_instance_code';

  IF MSC_CL_PRE_PROCESS.V_DEBUG THEN
      msc_st_util.log_message(lv_sql_stmt);
  END IF;

  EXECUTE IMMEDIATE lv_sql_stmt USING lv_batch_id,MSC_CL_PRE_PROCESS.v_instance_code;

/* bug 3768813 */
    IF MSC_CL_PRE_PROCESS.v_instance_type <> MSC_CL_PRE_PROCESS.G_INS_OTHER THEN

    -- Derive the ROUTING_SEQUENCE_ID from LOCAL ID table

      lv_return :=msc_st_util.derive_routing_sequence_id
                (p_table_name     => 'MSC_ST_DEMANDS',
                 p_rtg_col_name   => 'ROUTING_NAME',
                 p_rtg_col_id     =>'ROUTING_SEQUENCE_ID',
                 p_instance_code  => MSC_CL_PRE_PROCESS.v_instance_code,
                 p_batch_id       => lv_batch_id,
                 p_debug          => MSC_CL_PRE_PROCESS.v_debug,
                 p_error_text     => lv_error_text,
                 p_item_id        => 'using_assembly_item_id');

      if (lv_return <> 0 )then
         msc_st_util.log_message(lv_error_text);
      end if;

      MSC_CL_PRE_PROCESS.v_sql_stmt := 11;
      lv_sql_stmt:=
      'update msc_st_demands msd'
      ||' set operation_seq_num = '
      ||'  (select operation_seq_num '
      ||'   from msc_routing_operations mro '
      ||'   where mro.routing_sequence_id = msd.routing_sequence_id and '
      ||'         mro.effectivity_date = msd.operation_effectivity_date and '
      ||'         mro.SR_INSTANCE_ID = '||MSC_CL_PRE_PROCESS.v_instance_id||' and '
      ||'      mro.operation_seq_num = to_number(decode(length(rtrim(msd.operation_seq_code,''0123456789'')),'
      ||'                   NULL,msd.operation_seq_code,''1'')) and'
      ||'         mro.plan_id = -1 and '
      ||'         mro.operation_type = 1)'
      ||' WHERE  sr_instance_code = :v_instance_code'
      ||' AND    process_flag     = '|| MSC_CL_PRE_PROCESS.G_IN_PROCESS
      ||' AND    batch_id         = :lv_batch_id ';

      IF MSC_CL_PRE_PROCESS.V_DEBUG THEN
           msc_st_util.log_message(lv_sql_stmt);
      END IF;

      EXECUTE IMMEDIATE lv_sql_stmt USING MSC_CL_PRE_PROCESS.v_instance_code,lv_batch_id;
    END IF;

    -- Derive operation seq num from local id table

    MSC_CL_PRE_PROCESS.v_sql_stmt := 12;
    lv_sql_stmt:=
    'UPDATE     msc_st_demands msd'
    ||' SET     operation_seq_num=    (SELECT number1'
    ||'                    FROM msc_local_id_setup mlis'
    ||'                    WHERE  mlis.char1 = msd.sr_instance_code'
    ||'                    AND NVL(mlis.char2,'||''''||MSC_CL_PRE_PROCESS.NULL_CHAR||''''||') '
    ||'                    =   NVL(msd.company_name,'||''''||MSC_CL_PRE_PROCESS.NULL_CHAR||''''||') '
    ||'                    AND    mlis.char3 = msd.organization_code'
    ||'                    AND    mlis.char4 = msd.routing_name'
    ||'                    AND    mlis.char5 = msd.operation_seq_code'
    ||'                    AND   NVL(mlis.char6,'||''''||MSC_CL_PRE_PROCESS.NULL_CHAR||''''||') '
    ||'                          = NVL(msd.alternate_routing_designator,'||''''||MSC_CL_PRE_PROCESS.NULL_CHAR||''''||') '
    ||'                    AND    mlis.date1 = msd.operation_effectivity_date'
    ||'                    AND    mlis.entity_name = ''OPERATION_SEQUENCE_ID'') '
    ||' WHERE      sr_instance_code = :v_instance_code'
    ||' AND        process_flag     = '||MSC_CL_PRE_PROCESS.G_IN_PROCESS
    ||' AND        batch_id         = :lv_batch_id'
    ||' AND        operation_seq_num is null'; /* bug 3768813 */


    IF MSC_CL_PRE_PROCESS.V_DEBUG THEN
         msc_st_util.log_message(lv_sql_stmt);
    END IF;

    EXECUTE IMMEDIATE lv_sql_stmt USING MSC_CL_PRE_PROCESS.v_instance_code,lv_batch_id;

   -- Set the message

    lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                 (p_app_short_name    => 'MSC',
                  p_error_code        => 'MSC_PP_DELETE_FAIL',
                  p_message_text      => lv_message_text,
                  p_error_text        => lv_error_text);

    IF lv_return <> 0 THEN
      RAISE ex_logging_err;
    END IF;

   -- Error out the records where operation_seq_num is NULL
   -- And deleted_flag = SYS_YES

  MSC_CL_PRE_PROCESS.v_sql_stmt := 13;

  lv_sql_stmt :=
  'UPDATE     msc_st_demands '
  ||' SET     process_flag    ='||MSC_CL_PRE_PROCESS.G_ERROR_FLG||','
  ||'         error_text   = '||''''||lv_message_text||''''
  ||' WHERE   NVL(operation_seq_num,'||MSC_CL_PRE_PROCESS.NULL_VALUE||') = '||MSC_CL_PRE_PROCESS.NULL_VALUE
  ||' AND     deleted_flag  ='||MSC_CL_PRE_PROCESS.SYS_YES
  ||' AND     origination_type =77'
  ||'  AND ENTITY=''ERO'''
  ||' AND     batch_id       = :lv_batch_id'
  ||' AND     sr_instance_code  =:v_instance_code';

   IF MSC_CL_PRE_PROCESS.V_DEBUG THEN
      msc_st_util.log_message(lv_sql_stmt);
   END IF;

   EXECUTE IMMEDIATE lv_sql_stmt USING lv_batch_id,MSC_CL_PRE_PROCESS.v_instance_code;

  -- Set the error message
    lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                   (p_app_short_name    => 'MSC',
                    p_error_code        => 'MSC_PP_FK_REF_NOT_EXIST',
                    p_message_text      => lv_message_text,
                    p_error_text        => lv_error_text,
                    p_token1            => 'COLUMN_NAMES',
                    p_token_value1      => '  SR_INSTANCE_CODE, COMPANY_NAME,'
                                           ||' ORGANIZATION_CODE AND PROJECT_NUMBER',
                    p_token2            => 'MASTER_TABLE',
                    p_token_value2      => 'MSC_ST_PROJECT_TASKS');

    IF lv_return <> 0 THEN
      RAISE ex_logging_err;
    END IF;

    --Derive Project Id.
    lv_return := MSC_ST_UTIL.DERIVE_PROJ_TASK_ID
                           (p_table_name          => 'MSC_ST_DEMANDS',
                            p_proj_col_name       => 'PROJECT_NUMBER',
                            p_proj_task_col_id    => 'PROJECT_ID',
                            p_instance_code       => MSC_CL_PRE_PROCESS.v_instance_code,
                            p_entity_name         => 'PROJECT_ID',
                            p_error_text          => lv_error_text,
                            p_batch_id            => lv_batch_id,
                            p_severity            => MSC_CL_PRE_PROCESS.G_SEV_WARNING,
                            p_message_text        => lv_message_text,
                            p_debug               => MSC_CL_PRE_PROCESS.v_debug,
                            p_row                 => lv_column_names);
    IF lv_return <> 0 THEN
      RAISE ex_logging_err;
    END IF;

     -- Set the error message
    lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                   (p_app_short_name    => 'MSC',
                    p_error_code        => 'MSC_PP_FK_REF_NOT_EXIST',
                    p_message_text      => lv_message_text,
                    p_error_text        => lv_error_text,
                    p_token1            => 'COLUMN_NAMES',
                    p_token_value1      => '  SR_INSTANCE_CODE, COMPANY_NAME,'
                                           ||' ORGANIZATION_CODE, PROJECT_NUMBER,'
                                           ||' TASK_NUMBER',
                    p_token2            => 'MASTER_TABLE',
                    p_token_value2      => 'MSC_ST_PROJECT_TASKS');

    IF lv_return <> 0 THEN
      RAISE ex_logging_err;
    END IF;

    --Derive Task Id.
    lv_return := MSC_ST_UTIL.DERIVE_PROJ_TASK_ID
                           (p_table_name          => 'MSC_ST_DEMANDS',
                            p_proj_col_name       => 'PROJECT_NUMBER',
                            p_proj_task_col_id    => 'TASK_ID',
                            p_instance_code       => MSC_CL_PRE_PROCESS.v_instance_code,
                            p_entity_name         => 'TASK_ID',
                            p_error_text          => lv_error_text,
                            p_task_col_name       => 'TASK_NUMBER',
                            p_batch_id            => lv_batch_id,
                            p_severity            => MSC_CL_PRE_PROCESS.G_SEV_WARNING,
                            p_message_text        => lv_message_text,
                            p_debug               => MSC_CL_PRE_PROCESS.v_debug,
                            p_row                 => lv_column_names);

    IF lv_return <> 0 THEN
      RAISE ex_logging_err;
    END IF;

    -- Set the error message
    lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_INVALID_COL_VALUE',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'DEMAND_TYPE',
                      p_token2            => 'DEFAULT_VALUE',
                      p_token_value2      =>  MSC_CL_PRE_PROCESS.G_DEMAND_TYPE );

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

    --  Default demand_type to 1 always

    lv_where_str := '   AND NVL(demand_type,'||MSC_CL_PRE_PROCESS.NULL_VALUE||') <> '||MSC_CL_PRE_PROCESS.G_DEMAND_TYPE
                    ||' AND origination_type =77 AND deleted_flag ='||MSC_CL_PRE_PROCESS.SYS_NO
                    ||'  AND ENTITY=''ERO''' ;

    lv_return := MSC_ST_UTIL.LOG_ERROR
                   (p_table_name        => 'MSC_ST_DEMANDS',
                    p_instance_code     => MSC_CL_PRE_PROCESS.v_instance_code,
                    p_row               => lv_column_names,
                    p_severity          => MSC_CL_PRE_PROCESS.G_SEV_WARNING,
                    p_message_text      => lv_message_text,
                    p_error_text        => lv_error_text,
                    p_batch_id          => lv_batch_id,
                    p_where_str         => lv_where_str,
                    p_col_name          => 'DEMAND_TYPE',
                    p_debug             => MSC_CL_PRE_PROCESS.v_debug,
                    p_default_value     => MSC_CL_PRE_PROCESS.G_DEMAND_TYPE);

    IF lv_return <> 0 THEN
        RAISE ex_logging_err;
    END IF;


      -- Set the error message
    lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_INVALID_COL_VALUE',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'WIP_SUPPLY_TYPE',
                      p_token2            => 'DEFAULT_VALUE',
                      p_token_value2      =>  MSC_CL_PRE_PROCESS.G_WIP_SUPPLY_TYPE );

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

    --  Default wip_supply_type as 1

    lv_where_str := ' AND NVL(wip_supply_type,'||MSC_CL_PRE_PROCESS.NULL_VALUE||') NOT IN (1,2,3,4,5,6,7)'
                    ||' AND origination_type =77 AND deleted_flag ='||MSC_CL_PRE_PROCESS.SYS_NO
                    ||'  AND ENTITY=''ERO''' ;

    lv_return := MSC_ST_UTIL.LOG_ERROR
                   (p_table_name        => 'MSC_ST_DEMANDS',
                    p_instance_code     => MSC_CL_PRE_PROCESS.v_instance_code,
                    p_row               => lv_column_names,
                    p_severity          => MSC_CL_PRE_PROCESS.G_SEV_WARNING,
                    p_message_text      => lv_message_text,
                    p_error_text        => lv_error_text,
                    p_batch_id          => lv_batch_id,
                    p_where_str         => lv_where_str,
                    p_col_name          => 'WIP_SUPPLY_TYPE',
                    p_debug             => MSC_CL_PRE_PROCESS.v_debug,
                    p_default_value     => MSC_CL_PRE_PROCESS.G_WIP_SUPPLY_TYPE );

    IF lv_return <> 0 THEN
        RAISE ex_logging_err;
    END IF;


    -- Set the error message
    lv_return := MSC_ST_UTIL.GET_ERROR_MESSAGE
                     (p_app_short_name    => 'MSC',
                      p_error_code        => 'MSC_PP_INVALID_COL_VALUE',
                      p_message_text      => lv_message_text,
                      p_error_text        => lv_error_text,
                      p_token1            => 'COLUMN_NAME',
                      p_token_value1      => 'WIP_STATUS_CODE',
                      p_token2            => 'DEFAULT_VALUE',
                      p_token_value2      =>  MSC_CL_PRE_PROCESS.G_WIP_STATUS_CODE );

      IF lv_return <> 0 THEN
        RAISE ex_logging_err;
      END IF;

    --  Default wip_status_code as 1(unrelased)

    lv_where_str := '   AND NVL(wip_status_code,'||MSC_CL_PRE_PROCESS.NULL_VALUE||') NOT IN (1,3,4,6,7,12)'
                    ||' AND origination_type =77 AND deleted_flag ='||MSC_CL_PRE_PROCESS.SYS_NO
                    ||'  AND ENTITY=''ERO''' ;

    lv_return := MSC_ST_UTIL.LOG_ERROR
                   (p_table_name        => 'MSC_ST_DEMANDS',
                    p_instance_code     => MSC_CL_PRE_PROCESS.v_instance_code,
                    p_row               => lv_column_names,
                    p_severity          => MSC_CL_PRE_PROCESS.G_SEV_WARNING,
                    p_message_text      => lv_message_text,
                    p_error_text        => lv_error_text,
                    p_batch_id          => lv_batch_id,
                    p_where_str         => lv_where_str,
                    p_col_name          => 'WIP_STATUS_CODE',
                    p_debug             => MSC_CL_PRE_PROCESS.v_debug,
                    p_default_value     => MSC_CL_PRE_PROCESS.G_WIP_STATUS_CODE);

    IF lv_return <> 0 THEN
        RAISE ex_logging_err;
    END IF;

    --Call to customised validation.
    MSC_CL_PRE_PROCESS_HOOK.ENTITY_VALIDATION
      (ERRBUF         => lv_error_text,
       RETCODE        => lv_return,
       pBatchID       => lv_batch_id,
       pInstanceCode  => MSC_CL_PRE_PROCESS.v_instance_code,
       pEntityName    => 'MSC_ST_DEMANDS',
       pInstanceID    => MSC_CL_PRE_PROCESS.v_instance_id);

    IF NVL(lv_return,0) <> 0 THEN
      RAISE ex_logging_err;
    END IF;

   -- Generate the operation_seq_num  and populate the LID table

    OPEN c2(lv_batch_id);
    FETCH c2 BULK COLLECT INTO lb_rowid ;


    IF c2%ROWCOUNT > 0  THEN
       FORALL j IN lb_rowid.FIRST..lb_rowid.LAST

     --    SELECT msc_st_operation_sequence_id_s.NEXTVAL
     --    INTO   lv_local_id
     --    FROM   DUAL;

         UPDATE msc_st_demands
          SET  operation_seq_num     =
               to_number(decode(length(rtrim(operation_seq_code,'0123456789')),
                         NULL,operation_seq_code,'1'))
          WHERE  rowid                  = lb_rowid(j);

     FORALL j IN lb_rowid.FIRST..lb_rowid.LAST

     -- Insert into the LID table

      INSERT INTO  msc_local_id_setup
     (local_id,
     st_transaction_id,
     instance_id,
     entity_name,
     data_source_type,
     char1,
     char2,
     char3,
     char4,
     char5,
     char6,
     number1,
     date1,
     SOURCE_ORGANIZATION_ID,
     SOURCE_INVENTORY_ITEM_ID,
     SOURCE_PROJECT_ID,
     SOURCE_TASK_ID,
     SOURCE_WIP_ENTITY_ID,
     SOURCE_OPERATION_SEQ_NUM,
     SOURCE_USING_ASSEMBLY_ID,
     last_update_date,
     last_updated_by,
     creation_date,
     created_by    )
     SELECT
      msc_st_operation_sequence_id_s.NEXTVAL,
      st_transaction_id,
      MSC_CL_PRE_PROCESS.v_instance_id,
      'OPERATION_SEQUENCE_ID',
      data_source_type,
      MSC_CL_PRE_PROCESS.v_instance_code,
      company_name,
      organization_code,
      routing_name,
      operation_seq_code,
      alternate_routing_designator,
      operation_seq_num,
      operation_effectivity_date,
      SOURCE_ORGANIZATION_ID,
      SOURCE_INVENTORY_ITEM_ID,
      SOURCE_PROJECT_ID,
      SOURCE_TASK_ID,
      SOURCE_WIP_ENTITY_ID,
      SOURCE_OPERATION_SEQ_NUM,
      SOURCE_USING_ASSEMBLY_ITEM_ID,
      MSC_CL_PRE_PROCESS.v_current_date,
      MSC_CL_PRE_PROCESS.v_current_user,
      MSC_CL_PRE_PROCESS.v_current_date,
      MSC_CL_PRE_PROCESS.v_current_user
      FROM msc_st_demands
      WHERE rowid = lb_rowid(j) ;

    END IF;
    CLOSE c2;

    -- Update operation seq num from local id table

    MSC_CL_PRE_PROCESS.v_sql_stmt := 12;
    lv_sql_stmt:=
    'UPDATE     msc_st_demands msd'
    ||' SET     operation_seq_num=    (SELECT number1'
    ||'                    FROM msc_local_id_setup mlis'
    ||'                    WHERE  mlis.char1 = msd.sr_instance_code'
    ||'                    AND NVL(mlis.char2,'||''''||MSC_CL_PRE_PROCESS.NULL_CHAR||''''||') '
    ||'                    =   NVL(msd.company_name,'||''''||MSC_CL_PRE_PROCESS.NULL_CHAR||''''||') '
    ||'                    AND    mlis.char3 = msd.organization_code'
    ||'                    AND    mlis.char4 = msd.routing_name'
    ||'                    AND    mlis.char5 = msd.operation_seq_code'
    ||'                    AND   NVL(mlis.char6,'||''''||MSC_CL_PRE_PROCESS.NULL_CHAR||''''||') '
    ||'                          = NVL(msd.alternate_routing_designator,'||''''||MSC_CL_PRE_PROCESS.NULL_CHAR||''''||') '
    ||'                    AND    mlis.date1 = msd.operation_effectivity_date'
    ||'                    AND    mlis.entity_name = ''OPERATION_SEQUENCE_ID'') '
    ||' WHERE      sr_instance_code = :v_instance_code'
    ||' AND        NVL(operation_seq_num,'||MSC_CL_PRE_PROCESS.NULL_VALUE||')= '||MSC_CL_PRE_PROCESS.NULL_VALUE
    ||' AND        process_flag     = '||MSC_CL_PRE_PROCESS.G_IN_PROCESS
    ||' AND        batch_id         = :lv_batch_id';


    IF MSC_CL_PRE_PROCESS.V_DEBUG THEN
         msc_st_util.log_message(lv_sql_stmt);
    END IF;

    EXECUTE IMMEDIATE lv_sql_stmt USING MSC_CL_PRE_PROCESS.v_instance_code,lv_batch_id;


    lv_return := MSC_ST_UTIL.SET_PROCESS_FLAG
                  (p_table_name     => 'MSC_ST_DEMANDS',
                   p_instance_id    => MSC_CL_PRE_PROCESS.v_instance_id,
                   p_instance_code  => MSC_CL_PRE_PROCESS.v_instance_code,
                   p_process_flag   => MSC_CL_PRE_PROCESS.G_VALID,
                   p_error_text     => lv_error_text,
                   p_debug          => MSC_CL_PRE_PROCESS.v_debug,
                   p_batch_id       => lv_batch_id);

    IF lv_return <> 0 THEN
      RAISE ex_logging_err;
    END IF;

    lv_return := MSC_ST_UTIL.LOG_ERROR
                   (p_table_name        => 'MSC_ST_DEMANDS',
                    p_instance_code     => MSC_CL_PRE_PROCESS.v_instance_code,
                    p_row               => lv_column_names,
                    p_severity          => MSC_CL_PRE_PROCESS.G_SEV_ERROR,
                    p_message_text      => NULL,
                    p_error_text        => lv_error_text,
                    p_debug             => MSC_CL_PRE_PROCESS.v_debug,
                    p_batch_id          => lv_batch_id);

    IF lv_return <> 0 THEN
      RAISE ex_logging_err;
    END IF;

    COMMIT;
   END LOOP ;

 EXCEPTION
    WHEN too_many_rows THEN
         lv_error_text := substr('MSC_CL__RPO_PRE_PROCESS.LOAD_ERO_DEMAND'||'('
                        ||MSC_CL_PRE_PROCESS.v_sql_stmt||')'|| SQLERRM, 1, 240);
         msc_st_util.log_message(lv_error_text);
         ROLLBACK ;

    WHEN ex_logging_err THEN
        msc_st_util.log_message(lv_error_text);
        ROLLBACK;

   WHEN OTHERS THEN
       lv_error_text :=  substr('MSC_CL_PRE_PROCESS.LOAD_ERO_DEMAND'||'('
                        ||MSC_CL_PRE_PROCESS.v_sql_stmt||')'|| SQLERRM, 1, 240);
      msc_st_util.log_message(lv_error_text);
      ROLLBACK;

  END LOAD_ERO_DEMAND;




END MSC_CL_RPO_PRE_PROCESS;

/
