--------------------------------------------------------
--  DDL for Package Body MSC_ST_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_ST_UTIL" AS
/* $Header: MSCSUTLB.pls 120.10.12010000.4 2010/03/19 13:06:42 vsiyer ship $ */

v_sql_stmt PLS_INTEGER;--Holds the DML statement no used for error logging.
v_debug	   BOOLEAN;
v_my_company VARCHAR(1000) := NULL;
v_seq_num NUMBER := 0 ;

/*=================================================================================+
| DESCRIPTION  : This function returns the debug mode set for the profile          |
|                'MRP: Debug Mode'.                                                |
+==================================================================================*/
  Function retn_debug_mode
  RETURN BOOLEAN IS
  BEGIN
    IF v_debug IS NULL THEN
      v_debug := FND_PROFILE.VALUE('MRP_DEBUG') = 'Y';
    END IF;
    RETURN v_debug;
  END retn_debug_mode;

/*==========================================================================+
| DESCRIPTION  : This function is called for inserting the errored records  |
|                into the error table for the severities warning and error. |
+==========================================================================*/
  FUNCTION LOG_ERROR
           (p_table_name             VARCHAR2,
            p_instance_code          VARCHAR2,
            p_row                    LONG,
            p_severity               NUMBER    DEFAULT G_SEV_ERROR,
            p_error_text OUT         NOCOPY VARCHAR2,
            p_message_text           VARCHAR2  DEFAULT NULL,
            p_batch_id               NUMBER    DEFAULT NULL,
            p_where_str              VARCHAR2  DEFAULT NULL,
            p_col_name               VARCHAR2  DEFAULT NULL,
            p_default_value          VARCHAR2  DEFAULT NULL,
            p_debug                  BOOLEAN   DEFAULT FALSE,
            p_propagated             VARCHAR2  DEFAULT 'N')
  RETURN NUMBER IS
  lv_sql_stmt     VARCHAR2(5000);
  lv_where_str    VARCHAR2(5000);
  lv_message_text msc_errors.error_text%TYPE;
  BEGIN

    --For the severity warning, the error text will be taken from the
    --parameter and for the severity error, error text will be picked from
    --the corresponding BO tables.

    IF p_severity = G_WARNING THEN
      lv_message_text := ''''||p_message_text||'''';
    ELSE
      lv_message_text := 'error_text';
    END IF;

    IF p_batch_id IS NOT NULL THEN
      lv_where_str :=
      ' AND batch_id    = :p_batch_id '||p_where_str;
    ELSE
      lv_where_str      :=p_where_str;
    END IF;

    v_sql_stmt  := 01;
    lv_sql_stmt :=
    'INSERT INTO msc_errors'
    ||'( error_id,'
    ||'  transaction_id,'
    ||'  message_id,'
    ||'  instance_code,'
    ||'  table_name,'
    ||'  propagated,'
    ||'  source,'
    ||'  rrow,'
    ||'  severity,'
    ||'  message_sent,'
    ||'  last_update_date,'
    ||'  last_updated_by,'
    ||'  creation_date,'
    ||'  created_by,'
    ||'  last_update_login,'
    ||'  request_id,'
    ||'  program_application_id,'
    ||'  program_id,'
    ||'  program_update_date,'
    ||'  error_text)'
    ||'  SELECT'
    ||'  msc_errors_s.NEXTVAL,'
    ||'  st_transaction_id,'
    ||'  message_id,'
    ||   ''''||p_instance_code||''''||','
    ||   ''''||p_table_name||''''||','
    ||   ''''||p_propagated||''''||','
    ||'  data_source_type,'
    ||   p_row||','
    ||   p_severity||','
    ||   SYS_NO||','
    ||'  last_update_date,'
    ||'  last_updated_by,'
    ||'  creation_date,'
    ||'  created_by,'
    ||'  last_update_login,'
    ||'  request_id,'
    ||'  program_application_id,'
    ||'  program_id,'
    ||'  program_update_date,'
    ||   lv_message_text
    ||'  FROM '
    ||   p_table_name
    ||'  WHERE sr_instance_code = :p_instance_code'
    ||'  AND (('||p_severity||'='||G_WARNING
    ||'  AND process_flag =     '||G_IN_PROCESS||')'
    ||'  OR ('||p_severity  ||'='||G_SEV_ERROR
    ||'  AND process_flag =     '||G_ERROR||'))'
    ||   lv_where_str;


      MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,lv_sql_stmt);

    IF p_batch_id IS NOT NULL THEN
      EXECUTE IMMEDIATE lv_sql_stmt
              USING     p_instance_code,
                        p_batch_id;
    ELSE
      EXECUTE IMMEDIATE lv_sql_stmt
              USING     p_instance_code;
    END IF;

    IF p_default_value IS NOT NULL THEN
      v_sql_stmt  := 02;
      lv_sql_stmt :=
      'UPDATE '||p_table_name
      ||' SET '||p_col_name|| '  = '||p_default_value
      ||' WHERE sr_instance_code = :p_instance_code'
      ||' AND   process_flag     = '||G_IN_PROCESS
      ||  lv_where_str;


        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,lv_sql_stmt);

      IF p_batch_id IS NOT NULL THEN
        EXECUTE IMMEDIATE lv_sql_stmt
                USING     p_instance_code,
                          p_batch_id;
      ELSE
        EXECUTE IMMEDIATE lv_sql_stmt
                USING     p_instance_code;
      END IF;
    END IF;
    RETURN(0);
  EXCEPTION
    WHEN OTHERS THEN
      p_error_text := substr('MSC_ST_UTIL.LOG_ERROR'||'('||v_sql_stmt||')'
                               || SQLERRM, 1, 240);
      return(SQLCODE);
  END LOG_ERROR;

/*===========================================================================+
| DESCRIPTION  : This function is called for deriving the company_id         |
|                and it is based on the instance_type. If the Instance type  |
|                is 4, then, the company_id is derived from the hz_parties   |
|                else the company_id is updated with -1.                     |
|                                                                            |
| p_table_name         - Name of the table for whose column the id derived.  |
|                        (eg., msc_st_supplies).                             |
| p_company_name       - Name of the column whose id is derived.             |
|                        (eg., company_name)                                 |
| p_company_id         - Name of the column which stores the id.             |
|                        (eg., company_id)                                   |
| p_instance_code      - Instance_code column name                           |
| p_default_value      - default value(-1) will be used if the instance_type |
|                        is other than 5(ie.,SCE)                            |
| p_instance_type      - Type of the instance                                |
|                        (eg., 4 - SCE )                                     |
| p_message_text       - Pre-defined message text.                           |
| p_severity           - Severity fo the error(1.Warning and 2. Error        |
| p_error_text         - This communicates the error message to the calling  |
|                        function, if any.                                   |
| p_row                - Concatenated column names of the table. This is     |
|                        used for error logging in case of child tables.     |
+==========================================================================*/
  FUNCTION DERIVE_COMPANY_ID
           (p_table_name             VARCHAR2,
            p_company_name           VARCHAR2,
            p_company_id             VARCHAR2,
            p_instance_code          VARCHAR2,
            p_error_text     OUT     NOCOPY VARCHAR2,
            p_default_value          NUMBER    DEFAULT -1,
            p_instance_type          NUMBER    DEFAULT 3 ,
            p_batch_id               NUMBER    DEFAULT NULL_VALUE,
            p_severity               NUMBER    DEFAULT 0 ,
            p_message_text           VARCHAR2  DEFAULT NULL,
            p_debug                  BOOLEAN   DEFAULT FALSE,
            p_row                    LONG      DEFAULT NULL)
  RETURN NUMBER IS
  lv_sql_stmt          VARCHAR2(5000);
  lv_where_str         VARCHAR2(100);
  lv_status            NUMBER := 0;
  lv_my_company        VARCHAR2(1000);
  BEGIN
    lv_my_company := GET_MY_COMPANY;
    v_sql_stmt  := 03;
    lv_sql_stmt :=
      'UPDATE  '||  p_table_name  ||' t1 '
      ||' SET    '||p_company_id ||'= -1 '
      ||' WHERE  exists( SELECT 1 '
      ||' FROM   msc_companies mc '
      ||' WHERE  mc.company_name                = nvl(t1.'||p_company_name ||' ,:lv_my_company) '
      ||' AND    mc.company_id                  = 1 '
      ||' AND    NVL(mc.disable_date,sysdate+1) > sysdate) '
      ||' AND    t1.process_flag      ='|| G_IN_PROCESS
      ||' AND    t1.sr_instance_code  = :p_instance_code'
      ||' AND    NVL(t1.batch_id,'||''''||NULL_CHAR||''''||')          = NVL(:p_batch_id,'||''''||NULL_VALUE||''''||')';


        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,lv_sql_stmt);


    EXECUTE IMMEDIATE lv_sql_stmt
    USING    lv_my_company,
             p_instance_code,
             p_batch_id;

    IF G_MULTI_TIER_ENABLE OR TRIM(UPPER(p_table_name)) ='MSC_ST_COMPANY_USERS' THEN
             v_sql_stmt  := 04;
             lv_sql_stmt :=
                 'UPDATE '||  p_table_name  ||' t1 '
                 ||' SET    '||p_company_id  ||'= (SELECT local_id from MSC_LOCAL_ID_SETUP'
                 ||' WHERE char1           = t1.sr_instance_code'
                 ||' and   NVL(char3,'||''''||NULL_CHAR||''''||') = NVL(t1.'||p_company_name||','||''''||NULL_CHAR||''''||')'
                 ||' and   entity_name     = '||''''||'SR_TP_ID'||''''
                 ||' and   number1 in (1,2) '
                 ||' and   rownum          = 1) '                                                     -- we need the first occurence of sr_tp_id
                 ||' WHERE    t1.'||p_company_id ||'        IS NULL'
                 ||' AND    t1.process_flag      ='|| G_IN_PROCESS
                 ||' AND    t1.sr_instance_code  = :p_instance_code'
                 ||' AND    NVL(t1.batch_id ,'||''''||NULL_CHAR||''''||')         =  NVL(:p_batch_id,'||''''||NULL_CHAR||''''||')';



                 MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,lv_sql_stmt);


             EXECUTE IMMEDIATE lv_sql_stmt
             USING    p_instance_code,
                      p_batch_id;

    ELSIF  TRIM(UPPER(p_table_name))='MSC_ST_TRADING_PARTNERS' THEN

             v_sql_stmt  := 04;
             lv_sql_stmt :=
                 'UPDATE '||  p_table_name  ||' t1 '
                 ||' SET    '||p_company_id  ||'= (SELECT local_id from MSC_LOCAL_ID_SETUP'
                 ||' WHERE char1           = t1.sr_instance_code'
                 ||' and   NVL(char3,'||''''||NULL_CHAR||''''||') = NVL(t1.'||p_company_name||','||''''||NULL_CHAR||''''||')'
                 ||' and   entity_name     = '||''''||'SR_TP_ID'||''''
                 ||' and   number1 in (1,2) '
                 ||' and   rownum          = 1) '                                                     -- we need the first occurence of sr_tp_id
                 ||' WHERE    t1.'||p_company_id ||'        IS NULL'
                 ||' AND    t1.process_flag      ='|| G_IN_PROCESS
                 ||' AND    t1.sr_instance_code  = :p_instance_code'
                 ||' AND    NVL(t1.batch_id ,'||''''||NULL_CHAR||''''||')         =  NVL(:p_batch_id,'||''''||NULL_CHAR||''''||')'
                 ||' AND    t1.partner_type =3';

                 MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,lv_sql_stmt);


             EXECUTE IMMEDIATE lv_sql_stmt
             USING    p_instance_code,
                      p_batch_id;

    END IF;

    v_sql_stmt  := 05;
    lv_sql_stmt :=
        'UPDATE '||p_table_name ||' t1 '
        ||' SET   error_text ='||''''||p_message_text||''''||','
        ||'      process_flag = '||g_error
        ||' WHERE NVL(t1.'||p_company_id||','||NULL_VALUE||') = '||NULL_VALUE
        ||' AND   sr_instance_code       = :p_instance_code'
        ||' AND   NVL(batch_id,'||NULL_VALUE||') = :p_batch_id'
        ||' AND   process_flag           = ' ||G_IN_PROCESS;


    MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,lv_sql_stmt);


    EXECUTE IMMEDIATE lv_sql_stmt
    USING    p_instance_code,

             p_batch_id;


    RETURN(lv_status);

  EXCEPTION
    WHEN too_many_rows THEN
	p_error_text := substr('MSC_ST_UTIL.DERIVE_COMPANY_ID'||'('
                        ||v_sql_stmt||')'|| SQLERRM, 1, 240);
	return(SQLCODE);

    WHEN others THEN
	p_error_text := substr('MSC_ST_UTIL.DERIVE_COMPANY_ID'||'('
                        ||v_sql_stmt||')'|| SQLERRM, 1, 240);
	return(SQLCODE);

  END DERIVE_COMPANY_ID;


/*==========================================================================+
| DESCRIPTION  : This function returns the Operator's name                  |
|                Default is 'My Company'                                    |
+==========================================================================*/
  FUNCTION GET_MY_COMPANY return VARCHAR2 IS
            p_my_company    VARCHAR2(1000);
  BEGIN

      /* Get the name of the own Company */
      /* This name is seeded with company_is = 1 in msc_companies */
      BEGIN
        IF v_my_company IS NULL THEN
         select company_name into p_my_company
         from msc_companies
         where company_id = 1;
         v_my_company := p_my_company;
        ELSE
         p_my_company := v_my_company;
        END IF;
      EXCEPTION
         WHEN OTHERS THEN
         return 'My Company';
      END;

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_STATUS,'The name in GET_MY_COMPANY :'||p_my_company);
      return p_my_company;

   END GET_MY_COMPANY;



/*==========================================================================+
| DESCRIPTION  : This function is called for deriving the item_id's based on|
|                the values in msc_local_id_item. For the tables other      |
|                than msc_st_system_items, if the derivation fails then the |
|                record will be errored out.                                |
|                Severity - 1 - Error                                       |
|                           2 - Warning                                     |
|                           3 - Error if value for item name exists         |
+==========================================================================*/
  FUNCTION DERIVE_ITEM_ID
           (p_table_name         VARCHAR2,
            p_item_col_name      VARCHAR2, --item_name
            p_item_col_id        VARCHAR2, --inventory_item_id
            p_instance_id        NUMBER,
            p_instance_code      VARCHAR2,
            p_error_text OUT     NOCOPY VARCHAR2,
            p_batch_id           NUMBER    DEFAULT NULL_VALUE,
            p_severity           NUMBER    DEFAULT 0,
            p_message_text       VARCHAR2  DEFAULT NULL,
            p_debug              BOOLEAN   DEFAULT FALSE,
            p_row                LONG      DEFAULT NULL,
            p_check_org          BOOLEAN   DEFAULT TRUE)
  RETURN NUMBER IS
  lv_sql_stmt          VARCHAR2(5000);
  lv_where_str         VARCHAR2(100);
  lv_status            NUMBER := 0;
  BEGIN
    v_sql_stmt  := 06;

  IF v_instance_type = G_INS_OTHER THEN
    IF p_check_org THEN
      lv_sql_stmt :=
      'UPDATE '||p_table_name ||' t1'
      ||' SET '||p_item_col_id
      ||' = (SELECT  distinct local_id'
      ||' FROM msc_local_id_item t2'
      ||' WHERE  t2.char1         = t1.sr_instance_code '
      ||' AND    NVL(t2.char2,       '||''''||NULL_CHAR||''''||')='
      ||'        NVL(t1.company_name,'||''''||NULL_CHAR||''''||')'
      ||' AND    t2.char3         = t1.organization_code'
      ||' AND    t2.char4         = t1.'||p_item_col_name
      ||' AND    t2.entity_name   = ''SR_INVENTORY_ITEM_ID'' '
      ||' AND    t2.instance_id   = :p_instance_id)'
      ||' WHERE  sr_instance_code = :p_instance_code'
      ||' AND    NVL(batch_id,'||NULL_VALUE||') = :p_batch_id'
      ||' AND    process_flag     = '||G_IN_PROCESS;
    ELSE
      lv_sql_stmt :=
      'UPDATE '||p_table_name ||' t1'
      ||' SET '||p_item_col_id
      ||' = (SELECT  distinct local_id'
      ||' FROM msc_local_id_item t2'
      ||' WHERE  t2.char1         = t1.sr_instance_code '
      ||' AND    NVL(t2.char2,       '||''''||NULL_CHAR||''''||')='
      ||'        NVL(t1.company_name,'||''''||NULL_CHAR||''''||')'
      ||' AND    t2.char4         = t1.'||p_item_col_name
      ||' AND    t2.entity_name   = ''SR_INVENTORY_ITEM_ID'' '
      ||' AND    t2.instance_id   = :p_instance_id)'
      ||' WHERE  sr_instance_code = :p_instance_code'
      ||' AND    NVL(batch_id,'||NULL_VALUE||') = :p_batch_id'
      ||' AND    process_flag     = '||G_IN_PROCESS;
    END IF;

  ELSE

      lv_sql_stmt :=
      'UPDATE '||p_table_name ||' t1'
      ||' SET '||p_item_col_id
      ||' = (SELECT  distinct mil.sr_inventory_item_id'
      ||' FROM   msc_item_id_lid mil, msc_system_items t2'
      ||' WHERE  mil.sr_instance_id = t2.sr_instance_id'
      ||' AND    mil.inventory_item_id = t2.inventory_item_id'
      ||' AND    t2.item_name     =  t1.'||p_item_col_name
      ||' AND    t2.sr_instance_id = :p_instance_id'
      ||' AND    t2.organization_id  = t1.organization_id'
      ||' AND    t2.plan_id         = -1)'
      ||' WHERE  sr_instance_code = :p_instance_code'
      ||' AND    NVL(batch_id,'||NULL_VALUE||') = :p_batch_id'
      ||' AND    process_flag     = '||G_IN_PROCESS;

  END IF;


    MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,lv_sql_stmt);

    EXECUTE IMMEDIATE lv_sql_stmt
            USING     p_instance_id,
                      p_instance_code,
                      p_batch_id;

    IF p_message_text IS NOT NULL and p_severity = 1 THEN
      v_sql_stmt  := 07;
      lv_sql_stmt :=
      'UPDATE '||p_table_name   ||' t1'
      ||' SET   error_text   = '||''''||p_message_text||''''||','
      ||'       process_flag = '||g_error
      ||' WHERE NVL(t1.'||p_item_col_id||','||NULL_VALUE||') = '||NULL_VALUE
      ||' AND   sr_instance_code       = :p_instance_code'
      ||' AND   NVL(batch_id,'||NULL_VALUE||') = :p_batch_id'
      ||' AND   process_flag           = ' ||G_IN_PROCESS;


        MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,lv_sql_stmt);

      EXECUTE IMMEDIATE lv_sql_stmt
              USING     p_instance_code,
                        p_batch_id;

    ELSIF p_message_text IS NOT NULL and  p_severity = 2 THEN
      lv_where_str :=
      ' AND NVL('||p_item_col_id||','||NULL_VALUE||') = '||NULL_VALUE;

      lv_status := LOG_ERROR(p_table_name       => p_table_name,
                             p_instance_code    => p_instance_code,
                             p_row              => p_row,
                             p_severity         => p_severity,
                             p_propagated       => 'N',
                             p_where_str        => lv_where_str,
                             p_message_text     => p_message_text,
                             p_error_text       => p_error_text,
                             p_batch_id         => p_batch_id);

    ELSIF p_message_text IS NOT NULL and  p_severity = 3 THEN
      v_sql_stmt  := 08;
      lv_sql_stmt :=
      'UPDATE '||p_table_name   ||' t1'
      ||' SET   error_text   = '||''''||p_message_text||''''||','
      ||'       process_flag = '||g_error
      ||' WHERE NVL(t1.'||p_item_col_id||','||NULL_VALUE||') = '||NULL_VALUE
      ||' AND   NVL(t1.'||p_item_col_name||','||''''||NULL_CHAR||''''||') '
      ||'          <> '||''''||NULL_CHAR||''''
      ||' AND   sr_instance_code       = :p_instance_code'
      ||' AND   NVL(batch_id,'||NULL_VALUE||')= :p_batch_id'
      ||' AND   process_flag           = ' ||G_IN_PROCESS;


      MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,lv_sql_stmt);

      EXECUTE IMMEDIATE lv_sql_stmt
              USING     p_instance_code,
                        p_batch_id;

    END IF;
    RETURN(lv_status);

  EXCEPTION
    WHEN too_many_rows THEN
      p_error_text := substr('MSC_ST_UTIL.DERIVE_ITEM_ID'||'('
                        ||v_sql_stmt||')'|| SQLERRM, 1, 240);
      return(SQLCODE);

    WHEN OTHERS THEN
      p_error_text := substr('MSC_ST_UTIL.DERIVE_ITEM_ID'||'('
                        ||v_sql_stmt||')'|| SQLERRM, 1, 240);
      return(SQLCODE);
  END DERIVE_ITEM_ID;


/*===========================================================================+
| DESCRIPTION  : This function is called for deriving the organization/      |
|                supplier/customer id's based on the organization code/      |
|                partner name from the trading partner's table.              |
|                sr_instance_code (and Task number for task_id's)from the    |
|                local_id table.                                             |
| p_table_name         - Name of the table for whose column the id derived.  |
|                        (eg., msc_st_supplies).                             |
| p_org_partner_name   - Name of the column whose id is derived.             |
|                        (eg., supplier_name/organization_code)              |
| p_org_partner_id     - Name of the column which stores the id.             |
|                        (eg., supplier_id/organization_id)                  |
| p_instance_code      - Instance_code column name                           |
| p_partner_type       - Partner Type as stored in the msc_trading_partners  |
|                        1-customer, 2-Supplier and 3-Organization           |
| p_message_text       - Pre-defined error text.                             |
| p_severity           - Severity fo the error(1.Warning and 2. Error        |
| p_error_text         - This communicates the error message to the calling  |
|                        function, if any.                                   |
| p_row                - Concatenated column names of the table. This is     |
|                        used for error logging in case of child tables.     |
+==========================================================================*/
  FUNCTION DERIVE_PARTNER_ORG_ID
           (p_table_name           VARCHAR2,
            p_org_partner_name     VARCHAR2,
            p_cust_account_number  VARCHAR2 DEFAULT 0,
            p_org_partner_id       VARCHAR2,
            p_instance_code        VARCHAR2,
            p_partner_type         NUMBER,
            p_error_text       OUT NOCOPY VARCHAR2,
            p_batch_id             NUMBER   DEFAULT NULL_VALUE,
            p_severity             NUMBER   DEFAULT 0,
            p_message_text         VARCHAR2 DEFAULT NULL,
            p_debug                BOOLEAN  DEFAULT FALSE,
            p_row                  LONG     DEFAULT NULL,
            p_where_str            VARCHAR2  DEFAULT NULL,
            p_company_name_col     BOOLEAN   DEFAULT TRUE 	)
  RETURN NUMBER IS

  lv_sql_stmt          VARCHAR2(5000);
  lv_where_str         VARCHAR2(100) ;
  lv_where_str1         VARCHAR2(100) := NULL;
  lv_where_str2         VARCHAR2(100) := NULL;
  lv_status    NUMBER := 0;
  BEGIN
    v_sql_stmt  := 09;
    IF (p_table_name IN ('MSC_ST_TRADING_PARTNERS','MSC_ST_TRADING_PARTNER_SITES',
        'MSC_ST_LOCATION_ASSOCIATIONS','MSC_ST_PARTNER_CONTACTS')) THEN
      lv_where_str1 := ' AND PARTNER_TYPE = '||p_partner_type || p_where_str;
    ELSIF (p_table_name = 'MSC_ST_CALENDAR_ASSIGNMENTS' and  p_partner_type in (G_VENDOR, G_CUSTOMER)) THEN
      lv_where_str1 := ' AND PARTNER_TYPE = '||p_partner_type || p_where_str;
    END IF ;

    IF (p_table_name IN ('MSC_ST_ITEM_SUBSTITUTES')) THEN
      lv_where_str1 := lv_where_str1 || p_where_str;
    END IF;

    IF p_partner_type = 2 THEN -- customer
      IF p_table_name IN ('MSC_ST_TRADING_PARTNERS','MSC_ST_TRADING_PARTNER_SITES') then
        lv_where_str2:= ' AND    char4            = '||p_cust_account_number;
      ELSE
        lv_where_str2:= ' AND    ROWNUM            = 1 ';
      END IF;
    END IF;

 IF v_instance_type = G_INS_OTHER THEN
  IF p_company_name_col THEN
    lv_sql_stmt :=
    'UPDATE '||p_table_name
    ||' SET '||p_org_partner_id
    ||' = (SELECT local_id'
    ||' FROM msc_local_id_setup '
    ||' WHERE  char1            = sr_instance_code'
    ||' AND    NVL(char2,       '||''''||NULL_CHAR||''''||')='
    ||'        NVL(company_name,'||''''||NULL_CHAR||''''||')'
    ||' AND    char3            = '||p_org_partner_name
    ||' AND    number1          = '||p_partner_type
    ||lv_where_str2
    ||' AND    entity_name      = ''SR_TP_ID'' )'
    ||' WHERE  sr_instance_code = :p_instance_code'
    ||' AND    NVL('||p_org_partner_id||','||NULL_VALUE||') = '||NULL_VALUE
    ||' AND    NVL(batch_id,'||NULL_VALUE||')= :p_batch_id'
    ||' AND    process_flag     = '||G_IN_PROCESS
    ||  lv_where_str1;
  ELSE
      lv_sql_stmt :=
    'UPDATE '||p_table_name
    ||' SET '||p_org_partner_id
    ||' = (SELECT local_id'
    ||' FROM msc_local_id_setup '
    ||' WHERE  char1            = sr_instance_code'
    ||' AND    char3            = '||p_org_partner_name
    ||' AND    number1          = '||p_partner_type
    ||lv_where_str2
    ||' AND    entity_name      = ''SR_TP_ID'' )'
    ||' WHERE  sr_instance_code = :p_instance_code'
    ||' AND    NVL('||p_org_partner_id||','||NULL_VALUE||') = '||NULL_VALUE
    ||' AND    NVL(batch_id,'||NULL_VALUE||')= :p_batch_id'
    ||' AND    process_flag     = '||G_IN_PROCESS
    ||  lv_where_str1;
  END IF;

 ELSE

   IF  p_partner_type = G_ORGANIZATION THEN
   lv_sql_stmt :=
    'UPDATE '||p_table_name ||' t1'
    ||' SET '||p_org_partner_id
    ||' = (SELECT sr_tp_id'
    ||' FROM   msc_trading_partners mtp'
    ||' WHERE  mtp.partner_type     = '||p_partner_type
    ||' AND    mtp.organization_code = '||''''||p_instance_code||''''||'||'':''||'||'t1.'||p_org_partner_name
    ||' AND    mtp.sr_instance_id  = '||v_instance_id||')'
    ||' WHERE  sr_instance_code = :p_instance_code'
    ||' AND    NVL('||p_org_partner_id||','||NULL_VALUE||') = '||NULL_VALUE
    ||' AND    NVL(batch_id,'||NULL_VALUE||')= :p_batch_id'
    ||' AND    process_flag     = '||G_IN_PROCESS
    ||  lv_where_str1;

   ELSE
     lv_sql_stmt :=
      'UPDATE '||p_table_name ||' t1'
      ||' SET '||p_org_partner_id
      ||' = (SELECT max(mtil.sr_tp_id)'
      ||' FROM msc_tp_id_lid mtil, msc_trading_partners mtp'
      ||' WHERE mtil.partner_type = '||p_partner_type
      ||' AND   mtil.sr_instance_id = '||v_instance_id
      ||' AND   mtil.tp_id = mtp.partner_id'
      ||' AND   mtp.partner_name = t1.'||p_org_partner_name
      ||' AND   mtp.partner_type = '||p_partner_type||')'
      ||' WHERE  sr_instance_code = :p_instance_code'
      ||' AND    NVL('||p_org_partner_id||','||NULL_VALUE||') = '||NULL_VALUE
      ||' AND    NVL(batch_id,'||NULL_VALUE||')= :p_batch_id'
      ||' AND    process_flag     = '||G_IN_PROCESS
      ||  lv_where_str1;

   END IF;
 END IF;


MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,lv_sql_stmt);

    EXECUTE IMMEDIATE lv_sql_stmt
            USING     p_instance_code,
                      p_batch_id;


    IF p_message_text IS NOT NULL and p_severity = 1 THEN
      v_sql_stmt  := 10;
      lv_sql_stmt :=
      'UPDATE '||p_table_name
      ||' SET error_text   = '||''''||p_message_text||''''||','
      ||'     process_flag = '||g_error
      ||' WHERE NVL('||p_org_partner_id||','||NULL_VALUE||') = '||NULL_VALUE
      ||' AND   sr_instance_code       = :p_instance_code'
      ||' AND   NVL(batch_id,'||NULL_VALUE||')= :p_batch_id'
      ||' AND   process_flag           = '||G_IN_PROCESS
      ||  lv_where_str1;


      MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,lv_sql_stmt);

      EXECUTE IMMEDIATE lv_sql_stmt
              USING     p_instance_code,
                        p_batch_id;

    ELSIF p_message_text IS NOT NULL and p_severity = 2 THEN

      lv_where_str :=
      ' AND NVL('||p_org_partner_id||','||NULL_VALUE||') = '||NULL_VALUE
      || lv_where_str1;

      lv_status :=
      LOG_ERROR(p_table_name       => p_table_name,
                p_instance_code    => p_instance_code,
                p_row              => p_row,
                p_severity         => p_severity,
                p_propagated       => 'N',
                p_where_str        => lv_where_str,
                p_message_text     => p_message_text,
                p_error_text       => p_error_text,
                p_batch_id         => p_batch_id);

    ELSIF p_message_text IS NOT NULL and  p_severity = 3 THEN

      v_sql_stmt  := 11;
      lv_sql_stmt :=
      'UPDATE '||p_table_name
      ||' SET   error_text   = '||''''||p_message_text||''''||','
      ||'       process_flag = '||G_ERROR
      ||' WHERE NVL('||p_org_partner_id||','||NULL_VALUE||') = '||NULL_VALUE
      ||' AND   NVL('||p_org_partner_name||','||''''||NULL_CHAR||''''||')'
      ||'       <> '||''''||NULL_CHAR||''''
      ||' AND   sr_instance_code    = :p_instance_code'
      ||' AND   NVL(batch_id,'||NULL_VALUE||') = :p_batch_id'
      ||' AND   process_flag        = '||G_IN_PROCESS
      ||  lv_where_str1;


      MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,lv_sql_stmt);

      EXECUTE IMMEDIATE lv_sql_stmt
              USING     p_instance_code,
                        p_batch_id;

    END IF;
    RETURN(lv_status);
  EXCEPTION
    WHEN too_many_rows THEN
	p_error_text := substr('MSC_ST_UTIL.DERIVE_PARTNER_ORG_ID'||'('
                        ||v_sql_stmt||')'|| SQLERRM, 1, 240);
	return(SQLCODE);

    WHEN OTHERS THEN
	p_error_text := substr('MSC_ST_UTIL.DERIVE_PARTNER_ORG_ID'||'('
                        ||v_sql_stmt||')'|| SQLERRM, 1, 240);
	return(SQLCODE);

  END DERIVE_PARTNER_ORG_ID;

/*==========================================================================+
| DESCRIPTION  : This function derives the value of the partner location id |
|                from the trading partner sites table.                      |
+==========================================================================*/
  FUNCTION DERIVE_PARTNER_SITE_ID
           (p_table_name            VARCHAR2,
            p_partner_name          VARCHAR2,
            p_partner_site_code     VARCHAR2,
            p_CUST_ACCOUNT_NUMBER   VARCHAR2 DEFAULT '0',
            p_partner_site_id       VARCHAR2,
            p_instance_code         VARCHAR2,
            p_partner_type          VARCHAR2,
            p_error_text        OUT NOCOPY VARCHAR2,
            p_batch_id              NUMBER    DEFAULT NULL_VALUE,
            p_severity              NUMBER    DEFAULT 0,
            p_message_text          VARCHAR2  DEFAULT NULL,
            p_debug                 BOOLEAN   DEFAULT FALSE,
            p_row                   LONG      DEFAULT NULL,
            p_where_str              VARCHAR2  DEFAULT NULL)
  RETURN NUMBER IS
  lv_sql_stmt          VARCHAR2(5000);
  lv_where_str         VARCHAR2(100);
  lv_where_str1        VARCHAR2(100) := NULL ;
  lv_where_str2        VARCHAR2(100) := NULL ;
  lv_where_str3        VARCHAR2(100) := NULL ;
  lv_status    NUMBER := 0;
  BEGIN

    IF (p_table_name IN ('MSC_ST_TRADING_PARTNER_SITES','MSC_ST_LOCATION_ASSOCIATIONS',
                         'MSC_ST_PARTNER_CONTACTS', 'MSC_ST_CALENDAR_ASSIGNMENTS')) THEN
      lv_where_str1 := ' AND PARTNER_TYPE = '||p_partner_type;
    END IF ;
    IF (p_table_name IN ('MSC_ST_ITEM_SUBSTITUTES')) THEN
      lv_where_str1 := lv_where_str1 ||p_where_str;
    END IF ;

    IF p_table_name in ('MSC_ST_SALES_ORDERS', 'MSC_ST_DESIGNATORS','MSC_ST_DEMANDS') THEN
       IF (p_partner_site_code = 'SHIP_TO_SITE_CODE' AND p_partner_type = 2) THEN
           lv_where_str2 :=  ' AND mtps.tp_site_code = ''SHIP_TO'' AND rownum =1)' ;
       ELSIF (p_partner_site_code IN ('BILL_TO_SITE_CODE', 'BILL_CODE') AND p_partner_type = 2) THEN
           lv_where_str2 :=  ' AND mtps.tp_site_code = ''BILL_TO'' AND rownum =1)';
       ELSE
           lv_where_str2 :=  ' AND rownum =1)';
       END IF;
    ELSE
       lv_where_str2 :=  ' AND rownum =1)';
    END IF;

    v_sql_stmt  := 12;

    IF p_partner_type = 2 THEN -- customer
      IF p_table_name IN ('MSC_ST_TRADING_PARTNER_SITES') THEN
        lv_where_str3:=     ' AND    char5          = '||p_CUST_ACCOUNT_NUMBER;
      ELSE
        lv_where_str3:=     ' AND ROWNUM =1 ';  -- location is not considered.
      END IF;
    END IF;

  IF v_instance_type = G_INS_OTHER THEN
    lv_sql_stmt :=
    'UPDATE '||p_table_name
    ||' SET '||p_partner_site_id
    ||' = (SELECT local_id'
    ||' FROM msc_local_id_setup '
    ||' WHERE  char1            = sr_instance_code'
    ||' AND    NVL(char2,       '||''''||NULL_CHAR||''''||')='
    ||'        NVL(company_name,'||''''||NULL_CHAR||''''||')'
    ||' AND    char3            = '||p_partner_name
    ||' AND    char4            = '||p_partner_site_code
    ||' AND    number1          = '||p_partner_type
    ||lv_where_str3
    ||' AND    entity_name      = ''SR_TP_SITE_ID'' )'
    ||' WHERE  sr_instance_code = :p_instance_code'
    ||' AND    NVL('||p_partner_site_id||','||NULL_VALUE||') = '||NULL_VALUE
    ||' AND    NVL(batch_id,'||NULL_VALUE||') = :p_batch_id'
    ||' AND    process_flag     = '||G_IN_PROCESS
    ||  lv_where_str1;

 ELSE
   lv_sql_stmt :=
   'UPDATE '||p_table_name ||' t1'
    ||' SET '||p_partner_site_id
    ||' = (SELECT mtsil.sr_tp_site_id'
    ||' FROM   msc_tp_site_id_lid mtsil, msc_trading_partner_sites mtps, msc_trading_partners mtp'
    ||' WHERE  mtsil.partner_type = '||p_partner_type
    ||' AND    mtsil.sr_instance_id = '||v_instance_id
    ||' AND    mtsil.tp_site_id = mtps.partner_site_id'
    ||' AND    mtps.partner_id = mtp.partner_id'
    ||' AND    mtp.partner_type = '||p_partner_type
    ||' AND    mtp.partner_name = t1.'||p_partner_name
    ||' AND    mtps.partner_type = '||p_partner_type;

    IF p_partner_type = 2 THEN
       lv_sql_stmt := lv_sql_stmt
       ||' AND mtps.location = t1.'||p_partner_site_code
       ||  lv_where_str2
       ||' WHERE  sr_instance_code = :p_instance_code'
       ||' AND    NVL('||p_partner_site_id||','||NULL_VALUE||') = '||NULL_VALUE
       ||' AND    NVL(batch_id,'||NULL_VALUE||') = :p_batch_id'
       ||' AND    process_flag     = '||G_IN_PROCESS
       ||  lv_where_str1;

    ELSE
       lv_sql_stmt := lv_sql_stmt
       ||' AND mtps.tp_site_code = t1.'||p_partner_site_code
       ||' AND rownum =1)'
       ||' WHERE  sr_instance_code = :p_instance_code'
       ||' AND    NVL('||p_partner_site_id||','||NULL_VALUE||') = '||NULL_VALUE
       ||' AND    NVL(batch_id,'||NULL_VALUE||') = :p_batch_id'
       ||' AND    process_flag     = '||G_IN_PROCESS
       ||  lv_where_str1;
    END IF;

  END IF;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,lv_sql_stmt);
    EXECUTE IMMEDIATE lv_sql_stmt
            USING     p_instance_code,
                      p_batch_id;


    IF p_message_text IS NOT NULL and p_severity = 1 THEN
      v_sql_stmt  := 13;
      lv_sql_stmt :=
      'UPDATE '||p_table_name
      ||' SET error_text   = '||''''||p_message_text||''''||','
      ||'     process_flag = '||g_error
      ||' WHERE NVL('||p_partner_site_id||','||NULL_VALUE||') = '||NULL_VALUE
      ||' AND   sr_instance_code       = :p_instance_code'
      ||' AND   NVL(batch_id,'||NULL_VALUE||')= :p_batch_id'
      ||' AND   process_flag           = '||G_IN_PROCESS
      ||  lv_where_str1 ;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,lv_sql_stmt);
      EXECUTE IMMEDIATE lv_sql_stmt
              USING     p_instance_code,
                        p_batch_id;

    ELSIF p_message_text IS NOT NULL and  p_severity = 2 THEN

      lv_where_str :=
      ' AND NVL('||p_partner_site_id||','||NULL_VALUE||') = '||NULL_VALUE
      || lv_where_str1 ;

      lv_status :=
      LOG_ERROR(p_table_name       => p_table_name,
                p_instance_code    => p_instance_code,
                p_row              => p_row,
                p_severity         => p_severity,
                p_propagated       => 'N',
                p_where_str        => lv_where_str,
                p_message_text     => p_message_text,
                p_error_text       => p_error_text,
                p_batch_id         => p_batch_id);

    ELSIF p_message_text IS NOT NULL and  p_severity = 3 THEN

      v_sql_stmt  := 14;
      lv_sql_stmt :=
      'UPDATE '||p_table_name
      ||' SET   error_text   = '||''''||p_message_text||''''||','
      ||'       process_flag = '||G_ERROR
      ||' WHERE NVL('||p_partner_site_id||','||NULL_VALUE||') = '||NULL_VALUE
      ||' AND   NVL('||p_partner_site_code||','||''''||NULL_CHAR||''''||') '
      ||'       <> '||''''||NULL_CHAR||''''
      ||' AND   sr_instance_code    = :p_instance_code'
      ||' AND   NVL(batch_id,'||NULL_VALUE||')= :p_batch_id'
      ||' AND   process_flag        = '||G_IN_PROCESS
      ||  lv_where_str1;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,lv_sql_stmt);
      EXECUTE IMMEDIATE lv_sql_stmt
              USING     p_instance_code,
                        p_batch_id;
    END IF;
    RETURN(lv_status);

  EXCEPTION
    WHEN too_many_rows THEN
	p_error_text := substr('MSC_ST_UTIL.DERIVE_PARTNER_SITE_ID'||'('
                        ||v_sql_stmt||')'|| SQLERRM, 1, 240);
	return(SQLCODE);

    WHEN OTHERS THEN
	p_error_text := substr('MSC_ST_UTIL.DERIVE_PARTNER_SITE_ID'||'('
                        ||v_sql_stmt||')'|| SQLERRM, 1, 240);
	return(SQLCODE);

  END DERIVE_PARTNER_SITE_ID;

/*==========================================================================+
| DESCRIPTION  : This function is called for deriving the project/Task ids  |
|                based on the organization name, project number/name,       |
|                sr_instance_code (and Task number for task_id's)from the   |
|                local_id table.                                            |
| p_table_name         - Name of the table for whose column the id derived. |
|                        (eg., msc_st_supplies).                            |
| p_proj_col_name      - Name of the column whose id is derived.            |
|                        (eg., project name)                                |
| p_task_col_name      - Name of the column whose id is derived.            |
|                        (eg., task number)                                 |
| p_proj_task_col_id   - Name of the column which stores the id.            |
|                        (eg., project_id/task_id)                          |
| p_instance_code      - Current instance_code                              |
| p_entity_name        - Name of the entity as stored in the msc_local_id   |
|                        table.(eg., "PROJECT_ID")                          |
| p_message_text       - Pre-defined error text.                            |
| p_error_text         - This communicates the error message to the calling |
|                        function, if any.                                  |
| p_row                - Concatenated column names of the table. This is    |
|                        used for error logging in case of child tables.    |
+==========================================================================*/
  FUNCTION DERIVE_PROJ_TASK_ID
           (p_table_name             VARCHAR2,
            p_proj_col_name          VARCHAR2,
            p_proj_task_col_id       VARCHAR2,
            p_instance_code          VARCHAR2,
            p_entity_name            VARCHAR2,
            p_error_text         OUT NOCOPY VARCHAR2,
            p_task_col_name          VARCHAR2  DEFAULT NULL,
            p_batch_id               NUMBER    DEFAULT NULL_VALUE,
            p_severity               NUMBER    DEFAULT 0,
            p_message_text           VARCHAR2  DEFAULT NULL,
            p_debug                  BOOLEAN   DEFAULT FALSE,
            p_row                    LONG      DEFAULT NULL)
  RETURN NUMBER IS

  lv_sql_stmt  VARCHAR2(5000);
  lv_where_str VARCHAR2(100);
  lv_status    NUMBER:=0;
  BEGIN
    v_sql_stmt  := 15;

 IF v_instance_type = G_INS_OTHER THEN
    lv_sql_stmt :=
    'UPDATE '||p_table_name ||' t1'
    ||' SET '||p_proj_task_col_id
    ||' = (SELECT local_id'
    ||' FROM msc_local_id_misc t2'
    ||' WHERE  t2.char1           = t1.sr_instance_code '
    ||' AND    NVL(t2.char2,       '||''''||NULL_CHAR||''''||')='
    ||'        NVL(t1.company_name,'||''''||NULL_CHAR||''''||')'
/*    ||' AND    t2.char3           = t1.organization_code '*/
    ||' AND    t2.char4           = t1.'||p_proj_col_name;

    IF p_task_col_name IS NULL THEN
      lv_sql_stmt := lv_sql_stmt
      ||' AND    t2.entity_name     = '||''''||p_entity_name||''''||')'
      ||' WHERE  sr_instance_code   = :p_instance_code'
      ||' AND    NVL(batch_id,'||NULL_VALUE||')= :p_batch_id'
      ||' AND    process_flag       = '||G_IN_PROCESS;
    ELSE
      lv_sql_stmt := lv_sql_stmt
      ||' AND    t2.char5           = t1.'||p_task_col_name
      ||' AND    t2.entity_name     = '||''''||p_entity_name||''''||')'
      ||' WHERE  sr_instance_code   = :p_instance_code'
      ||' AND    NVL(batch_id,'||NULL_VALUE||')= :p_batch_id'
      ||' AND    process_flag       = '||G_IN_PROCESS;
    END IF;

 ELSE

   IF p_task_col_name IS NULL THEN
    lv_sql_stmt :=
    'UPDATE '||p_table_name ||' t1'
    ||' SET '||p_proj_task_col_id
    ||' = (SELECT project_id'
    ||' FROM msc_projects t2'
    ||' WHERE  t2.project_number  = t1.'||p_proj_col_name
    ||' AND    t2.sr_instance_id  ='||v_instance_id
    ||' AND    t2.plan_id         = -1 '
    ||' AND    t2.organization_id = t1.organization_id)'
    ||' WHERE  sr_instance_code   = :p_instance_code'
    ||' AND    NVL(batch_id,'||NULL_VALUE||')= :p_batch_id'
    ||' AND    process_flag       = '||G_IN_PROCESS;

  ELSE
    lv_sql_stmt :=
    'UPDATE '||p_table_name ||' t1'
    ||' SET '||p_proj_task_col_id
    ||' = (SELECT task_id'
    ||' FROM msc_project_tasks t2'
    ||' WHERE  t2.project_id  = t1.project_id '
    ||' AND    t2.sr_instance_id  = '||v_instance_id
    ||' AND    t2.plan_id         = -1 '
    ||' AND    t2.task_number     = t1.'||p_task_col_name
    ||' AND    t2.organization_id = t1.organization_id)'
    ||' WHERE  sr_instance_code   = :p_instance_code'
    ||' AND    NVL(batch_id,'||NULL_VALUE||')= :p_batch_id'
    ||' AND    process_flag       = '||G_IN_PROCESS;

  END IF;

 END IF;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,lv_sql_stmt);
    EXECUTE IMMEDIATE lv_sql_stmt
            USING     p_instance_code,
                      p_batch_id;

    IF p_message_text IS NOT NULL AND p_severity = 1 THEN
      v_sql_stmt  := 16;
      lv_sql_stmt :=
      'UPDATE '||p_table_name
      ||' SET error_text   = '||''''||p_message_text||''''||','
      ||'     process_flag = '||G_ERROR
      ||' WHERE NVL('||p_proj_task_col_id||','||NULL_VALUE||') = '||NULL_VALUE
      ||' AND   sr_instance_code       = :p_instance_code'
      ||' AND   NVL(batch_id,'||NULL_VALUE||') = :p_batch_id'
      ||' AND   process_flag           = '||G_IN_PROCESS;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,lv_sql_stmt);
      EXECUTE IMMEDIATE lv_sql_stmt
              USING     p_instance_code,
                        p_batch_id;

    ELSIF p_message_text IS NOT NULL AND p_severity = 2 THEN
    --Log a warning for those records where the project name/task name
    --exists and the derivation has failed.

      IF p_proj_col_name IS NULL THEN
        lv_where_str :=
        ' AND NVL('||p_proj_task_col_id||','||NULL_VALUE||') = '||NULL_VALUE
         ||' AND NVL('||p_task_col_name||','||''''||NULL_CHAR||''''||')'
         ||' <>'||''''||NULL_CHAR||'''';
      ELSE
        lv_where_str :=
        ' AND NVL('||p_proj_task_col_id||','||NULL_VALUE||') = '||NULL_VALUE
        ||' AND NVL('||p_proj_col_name||','||''''||NULL_CHAR||''''||')'
        ||' <>'||''''||NULL_CHAR||'''';
      END IF;

      lv_status := LOG_ERROR(p_table_name       => p_table_name,
                             p_instance_code    => p_instance_code,
                             p_row              => p_row,
                             p_severity         => p_severity,
                             p_propagated       => 'N',
                             p_where_str        => lv_where_str,
                             p_message_text     => p_message_text,
                             p_error_text       => p_error_text,
                             p_batch_id         => p_batch_id);

    END IF;
    RETURN(lv_status);
  EXCEPTION
    WHEN too_many_rows THEN
	p_error_text := substr('MSC_ST_UTIL.DERIVE_PROJ_TASK_ID'||'('
                        ||v_sql_stmt||')'|| SQLERRM, 1, 240);
	return(SQLCODE);

    WHEN OTHERS THEN
	p_error_text := substr('MSC_ST_UTIL.DERIVE_PROJ_TASK_ID'||'('
                        ||v_sql_stmt||')'|| SQLERRM, 1, 240);
	return(SQLCODE);

  END DERIVE_PROJ_TASK_ID;

/*==========================================================================+
| DESCRIPTION  : This function is called for validating UOMs based on       |
|                the values in ODS/Staging                                  |
|                Severity - 1 - Error                                       |
|                           3 - Error if value for UOM code exists          |
+==========================================================================*/
  FUNCTION VALIDATE_UOM
           (p_table_name         VARCHAR2,
            p_uom_col_name       VARCHAR2, --uom_code
            p_instance_id        NUMBER,
            p_instance_code      VARCHAR2,
            p_error_text OUT     NOCOPY VARCHAR2,
            p_batch_id           NUMBER    DEFAULT NULL_VALUE,
            p_severity           NUMBER    DEFAULT 0,
            p_message_text       VARCHAR2  DEFAULT NULL,
            p_debug              BOOLEAN   DEFAULT FALSE,
            p_row                LONG      DEFAULT NULL)
  RETURN NUMBER IS
  lv_sql_stmt  VARCHAR2(5000);
  lv_where_str VARCHAR2(100);
  lv_status    NUMBER:=0;

  BEGIN

   IF p_message_text IS NOT NULL and p_severity = 1 THEN

    NULL;

      v_sql_stmt  := 17;
      lv_sql_stmt :=
      'UPDATE '||p_table_name   ||' t1'
      ||' SET   error_text   = '||''''||p_message_text||''''||','
      ||'       process_flag = '||g_error
      ||' WHERE NOT EXISTS (SELECT 1'
      ||'            FROM msc_units_of_measure muom'
      ||'            WHERE muom.uom_code  = t1.'||p_uom_col_name
      ||'            UNION'
      ||'            SELECT 1 FROM msc_st_units_of_measure msuom'
      ||'            WHERE msuom.uom_code   =   t1.'||p_uom_col_name
      ||'       AND   msuom.sr_instance_id     = :v_instance_id'
      ||'       AND   msuom.process_flag       = '||G_VALID||' )'
      ||' AND   sr_instance_code       = :p_instance_code'
      ||' AND   NVL(batch_id,'||NULL_VALUE||') = :p_batch_id'
      ||' AND   process_flag           = ' ||G_IN_PROCESS;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,lv_sql_stmt);
      EXECUTE IMMEDIATE lv_sql_stmt
              USING     p_instance_id,
                        p_instance_code,
                        p_batch_id;


    ELSIF p_message_text IS NOT NULL and p_severity = 3 THEN

      v_sql_stmt  := 18;
      lv_sql_stmt :=
      'UPDATE '||p_table_name   ||' t1'
      ||' SET   error_text   = '||''''||p_message_text||''''||','
      ||'       process_flag = '||g_error
      ||' WHERE NOT EXISTS (SELECT 1'
      ||'            FROM msc_units_of_measure muom'
      ||'            WHERE muom.uom_code  = t1.'||p_uom_col_name
      ||'            UNION'
      ||'            SELECT 1 FROM msc_st_units_of_measure msuom'
      ||'            WHERE msuom.uom_code   =   t1.'||p_uom_col_name
      ||'       AND   msuom.sr_instance_id     = :v_instance_id'
      ||'       AND   msuom.process_flag       = '||G_VALID||' )'
      ||' AND   NVL(t1.'||p_uom_col_name||','||''''||NULL_CHAR||''''||') '
      ||'          <> '||''''||NULL_CHAR||''''
      ||' AND   sr_instance_code       = :p_instance_code'
      ||' AND   NVL(batch_id,'||NULL_VALUE||') = :p_batch_id'
      ||' AND   process_flag           = ' ||G_IN_PROCESS;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,lv_sql_stmt);
      EXECUTE IMMEDIATE lv_sql_stmt
              USING     p_instance_id,
                        p_instance_code,
                        p_batch_id;

   END IF;
    RETURN(lv_status);

  EXCEPTION
    WHEN too_many_rows THEN
      p_error_text := substr('MSC_ST_UTIL.VALIDATE_UOM'||'('
                        ||v_sql_stmt||')'|| SQLERRM, 1, 240);
      return(SQLCODE);

    WHEN OTHERS THEN
      p_error_text := substr('MSC_ST_UTIL.VALIDATE_UOM'||'('
                        ||v_sql_stmt||')'|| SQLERRM, 1, 240);
      return(SQLCODE);
  END VALIDATE_UOM ;

/*==========================================================================+
| DESCRIPTION  : This function is called for validating Demand classbased on|
|                the values in ODS/Staging                                  |
|                Severity - 1 - Error                                       |
|                           3 - Error if value for demand class exists      |
+==========================================================================*/
  FUNCTION VALIDATE_DMD_CLASS
           (p_table_name         VARCHAR2,
            p_dmd_class_column   VARCHAR2, -- demand class column name
            p_instance_id        NUMBER,
            p_instance_code      VARCHAR2,
            p_error_text OUT     NOCOPY VARCHAR2,
            p_batch_id           NUMBER    DEFAULT NULL_VALUE,
            p_severity           NUMBER    DEFAULT 0,
            p_message_text       VARCHAR2  DEFAULT NULL,
            p_debug              BOOLEAN   DEFAULT FALSE,
            p_row                LONG      DEFAULT NULL)
  RETURN NUMBER IS
  lv_sql_stmt  VARCHAR2(5000);
  lv_where_str VARCHAR2(100);
  lv_status    NUMBER:=0;

  BEGIN

   IF p_message_text IS NOT NULL and p_severity = 1 THEN

      v_sql_stmt  :=01;
      lv_sql_stmt :=
      'UPDATE '||p_table_name   ||' t1'
      ||' SET   error_text   = '||''''||p_message_text||''''||','
      ||'       process_flag = '||g_error
      ||' WHERE NOT EXISTS (SELECT 1'
      ||'            FROM msc_demand_classes  mdc'
      ||'            WHERE mdc.demand_class  = t1.'||p_dmd_class_column
      ||'            AND   mdc.sr_instance_id     = :v_instance_id'
      ||'            UNION'
      ||'            SELECT 1 FROM msc_st_demand_classes mstd'
      ||'            WHERE mstd.demand_class  =   t1.'||p_dmd_class_column
      ||'       AND   mstd.sr_instance_id     = :v_instance_id'
      ||'       AND   mstd.process_flag       = '||G_VALID||' )'
      ||' AND   sr_instance_code       = :p_instance_code'
      ||' AND   NVL(batch_id,'||NULL_VALUE||') = :p_batch_id'
      ||' AND   process_flag           = ' ||G_IN_PROCESS;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,lv_sql_stmt);
      EXECUTE IMMEDIATE lv_sql_stmt
              USING     p_instance_id,
                        p_instance_id,
                        p_instance_code,
                        p_batch_id;


    ELSIF p_message_text IS NOT NULL and p_severity = 3 THEN

      v_sql_stmt  := 02;
      lv_sql_stmt :=
      'UPDATE '||p_table_name   ||' t1'
      ||' SET   error_text   = '||''''||p_message_text||''''||','
      ||'       process_flag = '||g_error
      ||' WHERE NOT EXISTS (SELECT 1'
      ||'            FROM msc_demand_classes  mdc'
      ||'            WHERE mdc.demand_class  = t1.'||p_dmd_class_column
      ||'            AND   mdc.sr_instance_id     = :v_instance_id'
      ||'            UNION'
      ||'            SELECT 1 FROM msc_st_demand_classes mstd'
      ||'            WHERE mstd.demand_class  =   t1.'||p_dmd_class_column
      ||'       AND   mstd.sr_instance_id     = :v_instance_id'
      ||'       AND   mstd.process_flag       = '||G_VALID||' )'
      ||' AND   NVL(t1.'||p_dmd_class_column||','||''''||NULL_CHAR||''''||') '
      ||'          <> '||''''||NULL_CHAR||''''
      ||' AND   sr_instance_code       = :p_instance_code'
      ||' AND   NVL(batch_id,'||NULL_VALUE||') = :p_batch_id'
      ||' AND   process_flag           = ' ||G_IN_PROCESS;

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,lv_sql_stmt);
      EXECUTE IMMEDIATE lv_sql_stmt
              USING     p_instance_id,
                        p_instance_id,
                        p_instance_code,
                        p_batch_id;
   END IF;
    RETURN(lv_status);
  EXCEPTION
    WHEN OTHERS THEN
      p_error_text := substr('MSC_ST_UTIL.VALIDATE_DMD_CLASS'||'('
                        ||v_sql_stmt||')'|| SQLERRM, 1, 240);
      return(SQLCODE);
  END VALIDATE_DMD_CLASS ;


/*==========================================================================+
| DESCRIPTION  : This function sets the token value and returns the error   |
|                message text.                                              |
+==========================================================================*/
  FUNCTION GET_ERROR_MESSAGE
           (p_app_short_name       VARCHAR2,
            p_error_code           VARCHAR2,
            p_message_text   OUT   NOCOPY VARCHAR2,
            p_error_text     OUT   NOCOPY VARCHAR2,
            p_token1               VARCHAR2 DEFAULT NULL,
            p_token_value1         VARCHAR2 DEFAULT NULL,
            p_token2               VARCHAR2 DEFAULT NULL,
            p_token_value2         VARCHAR2 DEFAULT NULL,
            p_token3               VARCHAR2 DEFAULT NULL,
            p_token_value3         VARCHAR2 DEFAULT NULL,
            p_token4               VARCHAR2 DEFAULT NULL,
            p_token_value4         VARCHAR2 DEFAULT NULL,
            p_token5               VARCHAR2 DEFAULT NULL,
            p_token_value5         VARCHAR2 DEFAULT NULL)
  RETURN NUMBER IS
  BEGIN

    FND_MESSAGE.SET_NAME(p_app_short_name,p_error_code);

    IF    p_token1 IS NOT NULL THEN
      FND_MESSAGE.SET_TOKEN(p_token1,p_token_value1);
    END IF;

    IF p_token2 IS NOT NULL THEN
      FND_MESSAGE.SET_TOKEN(p_token2,p_token_value2);
    END IF;

    IF p_token3 IS NOT NULL THEN
      FND_MESSAGE.SET_TOKEN(p_token3,p_token_value3);
    END IF;

    IF p_token4 IS NOT NULL THEN
      FND_MESSAGE.SET_TOKEN(p_token4,p_token_value4);
    END IF;

    IF p_token5 IS NOT NULL THEN
      FND_MESSAGE.SET_TOKEN(p_token5,p_token_value5);
    END IF;

    p_message_text := FND_MESSAGE.GET;

    RETURN(0);
  EXCEPTION
    WHEN OTHERS THEN
      p_error_text := substr('MSC_ST_UTIL.GET_ERROR_MESSAGE'
                               || SQLERRM, 1, 240);
      return(SQLCODE);

  END GET_ERROR_MESSAGE;

  /*==========================================================================+
  | DESCRIPTION  : This function is called for deriving the bill_sequence_id  |
  | based on the values in msc_local_id_setup.     For the tables other       |
  |                than msc_st_boms,         if the derivation fails then the |
  |                record will be errored out.                                |
  |                Severity - 1 - Error                                       |
  |                           2 - Warning                                     |
  |                           3 - Error if value for bom name exists          |
  +==========================================================================*/
  FUNCTION DERIVE_BILL_SEQUENCE_ID
           (p_table_name          VARCHAR2,
            p_bom_col_name        VARCHAR2, --bom_name
            p_bom_col_id          VARCHAR2, --bill_sequence_id
            p_instance_code       VARCHAR2,
            p_error_text OUT      NOCOPY VARCHAR2,
            p_batch_id            NUMBER    DEFAULT NULL_VALUE,
            p_severity            NUMBER    DEFAULT 0,
            p_message_text        VARCHAR2  DEFAULT NULL,
            p_debug               BOOLEAN   DEFAULT FALSE,
            p_row                 LONG      DEFAULT NULL)
  RETURN NUMBER IS
  lv_sql_stmt          VARCHAR2(5000);
  lv_where_str         VARCHAR2(100);
  lv_status            NUMBER := 0;
  BEGIN
    v_sql_stmt  := 01;

  IF v_instance_type = G_INS_OTHER THEN
    lv_sql_stmt :=
    'UPDATE '||p_table_name ||' t1'
    ||' SET '||p_bom_col_id
    ||' = (SELECT local_id'
    ||' FROM msc_local_id_setup t2'
    ||' WHERE  t2.char1         = t1.sr_instance_code'
    ||' AND   NVL(t2.char2,'||''''||NULL_CHAR||''''||') '
    ||'      =    NVL(t1.company_name,'||''''||NULL_CHAR||''''||') '
    ||' AND    t2.char3         = t1.organization_code'
    ||' AND    NVL(t2.char6,'||''''||NULL_CHAR||''''||') '
    ||'         = NVL( t1.alternate_bom_designator,'||''''||NULL_CHAR||''''||') '
    ||' AND    t2.char4         = t1.'||p_bom_col_name
    ||' AND    t2.entity_name   = ''BILL_SEQUENCE_ID'')'
    ||' WHERE  sr_instance_code = :p_instance_code'
    ||' AND    batch_id         = :p_batch_id'
    ||' AND    process_flag     = '||G_IN_PROCESS;

  ELSE

   lv_sql_stmt :=
    'UPDATE '||p_table_name ||' t1'
    ||' SET '||p_bom_col_id
    ||' = (SELECT bill_sequence_id'
    ||' FROM msc_boms t2, msc_item_id_lid mil'
    ||' WHERE  t2.plan_id         = -1'
    ||' AND    t2.organization_id = t1.organization_id'
    ||' AND    t2.sr_instance_id  = '||v_instance_id
    ||' AND    t2.assembly_item_id = mil.inventory_item_id'
    ||' AND    mil.sr_inventory_item_id = t1.inventory_item_id'
    ||' AND    mil.sr_instance_id  = '||v_instance_id
    ||' AND    NVL(t2.alternate_bom_designator,'||''''||NULL_CHAR||''''||') '
    ||'         = NVL( t1.alternate_bom_designator,'||''''||NULL_CHAR||''''||')) '
    ||' WHERE  sr_instance_code = :p_instance_code'
    ||' AND    batch_id         = :p_batch_id'
    ||' AND    process_flag     = '||G_IN_PROCESS;

 END IF;

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,lv_sql_stmt);
    EXECUTE IMMEDIATE lv_sql_stmt
            USING     p_instance_code,
                      p_batch_id;


    IF p_message_text IS NOT NULL and p_severity = 1 THEN
      v_sql_stmt  := 02;
      lv_sql_stmt :=
      'UPDATE '||p_table_name   ||' t1'
      ||' SET   error_text   = '||''''||p_message_text||''''||','
      ||'       process_flag = '||G_ERROR
      ||' WHERE NVL(t1.'||p_bom_col_id||','||NULL_VALUE||') = '||NULL_VALUE
      ||' AND   sr_instance_code       = :p_instance_code'
      ||' AND   batch_id               = :p_batch_id'
      ||' AND   process_flag           = ' ||G_IN_PROCESS;

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,lv_sql_stmt);
      EXECUTE IMMEDIATE lv_sql_stmt
              USING     p_instance_code,
                        p_batch_id;

    ELSIF p_message_text IS NOT NULL and  p_severity = 2 THEN

    lv_where_str :=
      ' AND NVL('||p_bom_col_id||','||NULL_VALUE||') = '||NULL_VALUE;

      lv_status := LOG_ERROR(p_table_name    => p_table_name,
                             p_instance_code    => p_instance_code,
                             p_row              => p_row,
                             p_severity         => p_severity,
                             p_propagated       => 'N',
                             p_where_str        => lv_where_str,
                             p_error_text       => p_error_text,
                             p_message_text     => p_message_text,
                             p_batch_id         => p_batch_id);

    ELSIF p_message_text IS NOT NULL and  p_severity = 3 THEN
      v_sql_stmt  := 03;
      lv_sql_stmt :=
      'UPDATE '||p_table_name   ||' t1'
      ||' SET   error_text  = '||''''||p_message_text||''''||','
      ||'       process_flag = '||G_ERROR
      ||' WHERE NVL(t1.'||p_bom_col_id||','||NULL_VALUE||') = '||NULL_VALUE
      ||' AND   NVL(t1.'||p_bom_col_name||','||''''||NULL_CHAR||''''||')'
      ||'       <> '||''''||NULL_CHAR||''''
      ||' AND   sr_instance_code       = :p_instance_code'
      ||' AND   batch_id               = :p_batch_id'
      ||' AND   process_flag           = ' ||G_IN_PROCESS;

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,lv_sql_stmt);
      EXECUTE IMMEDIATE lv_sql_stmt
              USING     p_instance_code,
                        p_batch_id;

    END IF;
    RETURN(lv_status);

  EXCEPTION
    WHEN too_many_rows THEN
      p_error_text := substr('MSC_ST_UTIL.DERIVE_BILL_SEQUENCE_ID'||'('
                      ||v_sql_stmt||')'|| SQLERRM, 1, 240);
      return(SQLCODE);

    WHEN OTHERS THEN
      p_error_text := substr('MSC_ST_UTIL.DERIVE_BILL_SEQUENCE_ID'||'('
                      ||v_sql_stmt||')'|| SQLERRM, 1, 240);
      return(SQLCODE);

  END DERIVE_BILL_SEQUENCE_ID;

  /*==========================================================================+
  | DESCRIPTION  : This function is called for deriving therouting_sequence_id|
  |                the values in msc_local_id_setup.  For the tables otherthan|
  |                than msc_st_routings,     if the derivation fails then the |
  |                record will be errored out.                                |
  |                Severity - 1 - Error                                       |
  |                           2 - Warning                                     |
  |                           3 - Error if value for bom name exists          |
  +==========================================================================*/
  FUNCTION DERIVE_ROUTING_SEQUENCE_ID
           (p_table_name          VARCHAR2,
            p_rtg_col_name        VARCHAR2, --routing_name
            p_rtg_col_id          VARCHAR2, --routing_sequence_id
            p_instance_code       VARCHAR2,
            p_error_text OUT      NOCOPY VARCHAR2,
            p_batch_id            NUMBER    DEFAULT NULL_VALUE,
            p_severity            NUMBER    DEFAULT 0,
            p_message_text        VARCHAR2  DEFAULT NULL,
            p_debug               BOOLEAN   DEFAULT FALSE,
            p_row                 LONG      DEFAULT NULL,
            p_where_str           VARCHAR2  DEFAULT NULL,
            p_item_id              VARCHAR2 DEFAULT 'inventory_item_id')
  RETURN NUMBER IS

  lv_sql_stmt          VARCHAR2(5000);
  lv_where_str         VARCHAR2(100);
  lv_status            NUMBER := 0;
  BEGIN
    v_sql_stmt  := 01;

 IF v_instance_type = G_INS_OTHER THEN
    lv_sql_stmt :=
    'UPDATE '||p_table_name ||' t1'
    ||' SET '||p_rtg_col_id
    ||' = (SELECT local_id'
    ||' FROM   msc_local_id_setup t2'
    ||' WHERE  t2.char1         = t1.sr_instance_code'
    ||' AND    NVL(t2.char2,'||''''||NULL_CHAR||''''||') '
    ||'        =    NVL(t1.company_name,'||''''||NULL_CHAR||''''||') '
    ||' AND    t2.char3         = t1.organization_code'
    ||' AND    NVL(t2.char6,'||''''||NULL_CHAR||''''||') '
    ||'         = NVL( t1.alternate_routing_designator,'||''''||NULL_CHAR||''''||') '
    ||' AND    t2.char4         = t1.'||p_rtg_col_name
    ||' AND    t2.entity_name   = ''ROUTING_SEQUENCE_ID'')'
    ||' WHERE  sr_instance_code = :p_instance_code'
    ||' AND    batch_id         = :p_batch_id'
    ||' AND    process_flag     = '||G_IN_PROCESS
    || p_where_str;

 ELSE

   lv_sql_stmt :=
    'UPDATE '||p_table_name ||' t1'
    ||' SET '||p_rtg_col_id
    ||' = (SELECT routing_sequence_id'
    ||' FROM   msc_routings t2, msc_item_id_lid mil'
    ||' WHERE  t2.plan_id         = -1'
    ||' AND    t2.organization_id = t1.organization_id'
    ||' AND    t2.sr_instance_id  = '||v_instance_id
    ||' AND    t2.assembly_item_id = mil.inventory_item_id'
    ||' AND    mil.sr_inventory_item_id = t1.'||p_item_id
    ||' AND    mil.sr_instance_id  = '||v_instance_id
    ||' AND    NVL(t2.alternate_routing_designator,'||''''||NULL_CHAR||''''||') '
    ||'         = NVL( t1.alternate_routing_designator,'||''''||NULL_CHAR||''''||')) '
    ||' WHERE  sr_instance_code = :p_instance_code'
    ||' AND    batch_id         = :p_batch_id'
    ||' AND    process_flag     = '||G_IN_PROCESS
    || p_where_str;

 END IF;

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,lv_sql_stmt);
    EXECUTE IMMEDIATE lv_sql_stmt
            USING     p_instance_code,
                      p_batch_id;


    IF p_message_text IS NOT NULL and p_severity = 1 THEN
      v_sql_stmt  := 02;
      lv_sql_stmt :=
      'UPDATE '||p_table_name   ||' t1'
      ||' SET   error_text   = '||''''||p_message_text||''''||','
      ||'       process_flag = '||G_ERROR
      ||' WHERE NVL(t1.'||p_rtg_col_id||','||NULL_VALUE||') = '||NULL_VALUE
      ||' AND   sr_instance_code       = :p_instance_code'
      ||' AND   batch_id               = :p_batch_id'
      ||' AND   process_flag           = ' ||G_IN_PROCESS;

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,lv_sql_stmt);
      EXECUTE IMMEDIATE lv_sql_stmt
              USING     p_instance_code,
                        p_batch_id;

    ELSIF p_message_text IS NOT NULL and  p_severity = 2 THEN

      lv_where_str :=
      ' AND NVL('||p_rtg_col_id||','||NULL_VALUE||') = '||NULL_VALUE;

      lv_status := LOG_ERROR(p_table_name       => p_table_name,
                             p_instance_code    => p_instance_code,
                             p_row              => p_row,
                             p_severity         => p_severity,
                             p_propagated       => 'N',
                             p_where_str        => lv_where_str,
                             p_message_text     => p_message_text,
                             p_error_text       => p_error_text,
                             p_batch_id         => p_batch_id);

    ELSIF p_message_text IS NOT NULL and  p_severity = 3 THEN
      v_sql_stmt  := 03;
      lv_sql_stmt :=
      'UPDATE '||p_table_name   ||' t1'
      ||' SET   p_message_text  = '||''''||p_message_text||''''||','
      ||'       process_flag = '||g_error
      ||' WHERE NVL(t1.'||p_rtg_col_id||','||NULL_VALUE||') = '||NULL_VALUE
      ||' AND   NVL(t1.'||p_rtg_col_name||', '||''''||NULL_CHAR||''''||')'
      ||'       <> '||''''||NULL_CHAR||''''
      ||' AND   sr_instance_code       = :p_instance_code'
      ||' AND   batch_id               = :p_batch_id'
      ||' AND   process_flag           = ' ||G_IN_PROCESS;

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,lv_sql_stmt);
      EXECUTE IMMEDIATE lv_sql_stmt
              USING     p_instance_code,
                        p_batch_id;
    END IF;
    RETURN(lv_status);

  EXCEPTION
    WHEN too_many_rows THEN
      p_error_text := substr('MSC_ST_UTIL.DERIVE_ROUTING_SEQUENCE_ID'||'('
                      ||v_sql_stmt||')'|| SQLERRM, 1, 240);
      return(SQLCODE);


    WHEN OTHERS THEN
      p_error_text := substr('MSC_ST_UTIL.DERIVE_ROUTING_SEQUENCE_ID'||'('
                      ||v_sql_stmt||')'|| SQLERRM, 1, 240);
      return(SQLCODE);

  END DERIVE_ROUTING_SEQUENCE_ID;

/*==========================================================================+
| DESCRIPTION  : This function sets the process flag vlaue to the valid/    |
|                In process status and the instnce_id value for these       |
|                records.                                                   |
+==========================================================================*/
  FUNCTION SET_PROCESS_FLAG
           (p_table_name       VARCHAR2,
            p_instance_id      NUMBER,
            p_instance_code    VARCHAR2,
            p_process_flag     NUMBER,
            p_error_text OUT   NOCOPY VARCHAR2,
            p_where_str        VARCHAR2 DEFAULT NULL,
            p_debug            BOOLEAN   DEFAULT FALSE,
            p_batch_id         NUMBER   DEFAULT NULL_VALUE,
            p_instance_id_col  VARCHAR2 DEFAULT 'SR_INSTANCE_ID')
  RETURN NUMBER IS
  lv_sql_stmt     VARCHAR2(5000);
  lv_where_str    VARCHAR2(5000):=' ';

  BEGIN
    --To handle calendar which does'nt have the batch_id column.
    IF p_batch_id <> NULL_VALUE THEN
      lv_where_str :=
      ' AND NVL(batch_id,'||NULL_VALUE||') = :p_batch_id'||p_where_str;
    ELSE
      lv_where_str      :=p_where_str;
    END IF;

    IF p_process_flag = G_VALID THEN
      v_sql_stmt  := 17;
      lv_sql_stmt :=
      'UPDATE '||p_table_name
      ||' SET    process_flag     = '||G_VALID||','
      ||  p_instance_id_col||'    = :p_instance_id'
      ||' WHERE  process_flag     = '||G_IN_PROCESS
      ||' AND    sr_instance_code = :p_instance_code'
      ||  lv_where_str;

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,lv_sql_stmt);
      IF p_batch_id = NULL_VALUE THEN
        EXECUTE IMMEDIATE lv_sql_stmt
                USING     p_instance_id,
                          p_instance_code;
      ELSE
        EXECUTE IMMEDIATE lv_sql_stmt
                USING     p_instance_id,
                          p_instance_code,
                          p_batch_id;
      END IF;

    ELSE
      v_sql_stmt  := 18;
      lv_sql_stmt :=
      'UPDATE '||p_table_name
      ||' SET    process_flag      = ' ||G_IN_PROCESS  ||','
      ||  p_instance_id_col||'     = 0'                ||','
      ||' WHERE  nvl(process_flag,'||G_NEW ||') = '||G_NEW
      ||' AND    sr_instance_code = :p_instance_code'
      ||  lv_where_str;

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,lv_sql_stmt);
      IF p_batch_id = NULL_VALUE THEN
        EXECUTE IMMEDIATE lv_sql_stmt
                USING     p_instance_id,
                          p_instance_code;
      ELSE
        EXECUTE IMMEDIATE lv_sql_stmt
                USING     p_instance_id,
                          p_instance_code,
                          p_batch_id;
      END IF;

    END IF;

    RETURN(0);
  EXCEPTION
    WHEN OTHERS THEN
	p_error_text := substr('MSC_ST_UTIL.SET_PROCESS_FLAG'||'('||v_sql_stmt||')'
                              || SQLERRM, 1, 240);
	return(SQLCODE);

  END SET_PROCESS_FLAG;

  -- DP specific Function and Procedure
/*==========================================================================+
| DESCRIPTION  : This function is called for deriving level_id              |
|                from the msd_levels table.                                 |
+==========================================================================*/
  FUNCTION DERIVE_LEVEL_ID
           (p_table_name          VARCHAR2,
            p_level_name_col      VARCHAR2, --level_name
            p_level_id_col        VARCHAR2, --level_id
            p_severity            NUMBER    DEFAULT G_SEV_ERROR,
            p_message_text        VARCHAR2  DEFAULT NULL,
            p_instance_code       VARCHAR2,
            p_batch_id            NUMBER    DEFAULT NULL_VALUE,
            p_error_text  OUT     NOCOPY VARCHAR2)
  RETURN NUMBER IS
  lv_sql_stmt          VARCHAR2(5000);
  lv_where_str         VARCHAR2(100);
  lv_status            NUMBER := 0;
  --lv_debug BOOLEAN := retn_debug_mode;

  BEGIN
    v_sql_stmt := 01;

    lv_sql_stmt :=
    ' UPDATE '||p_table_name||' t1'
    ||' SET '||p_level_id_col
    ||' =  NVL((SELECT level_id'
    ||' FROM  msd_levels t2'
    ||' WHERE t2.level_name = t1.'||p_level_name_col
    ||' AND t2.PLAN_TYPE IS  NULL ),' --bug 4443782
    ||  NULL_VALUE ||')'
    ||' WHERE  sr_instance_code = :p_instance_code'
    ||' AND    NVL(batch_id,'||NULL_VALUE||') = :p_batch_id'
    ||' AND   NVL(t1.'||p_level_name_col||','||''''||NULL_CHAR||''''||') '
    ||'          <> '||''''||NULL_CHAR||''''
    ||' AND    process_flag     = '||G_IN_PROCESS ;

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,lv_sql_stmt);

    EXECUTE IMMEDIATE lv_sql_stmt
            USING     p_instance_code,
                      p_batch_id;

     IF  p_severity = 1 THEN

      v_sql_stmt := 02;
      lv_sql_stmt :=
      'UPDATE '||p_table_name   ||' t1'
      ||' SET   error_text   = '||''''||p_message_text||''''||','
      ||'       process_flag = '||G_ERROR
      ||' WHERE NVL(t1.'||p_level_id_col||','||''''||NULL_CHAR||''''||')  '
      ||'          = '||''''||NULL_CHAR||''''
      ||' AND   sr_instance_code       = :p_instance_code'
      ||' AND   NVL(batch_id,'||NULL_VALUE||') = :p_batch_id'
      ||' AND   process_flag           = ' ||G_IN_PROCESS;

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,lv_sql_stmt);
      EXECUTE IMMEDIATE lv_sql_stmt
              USING     p_instance_code,
                        p_batch_id;

     ELSIF p_severity =   3     THEN
      v_sql_stmt  := 03;

      lv_sql_stmt :=
      'UPDATE '||p_table_name   ||' t1'
      ||' SET   error_text   = '||''''||p_message_text||''''||','
      ||'       process_flag = '||g_error
      ||' WHERE NVL(t1.'||p_level_id_col||','||''''||NULL_CHAR||''''||')  '
      ||'          = '||''''||NULL_CHAR||''''
      ||' AND   NVL(t1.'||p_level_name_col||','||''''||NULL_CHAR||''''||') '
      ||'          <> '||''''||NULL_CHAR||''''
      ||' AND   sr_instance_code       = :p_instance_code'
      ||' AND   NVL(batch_id,'||NULL_VALUE||')= :p_batch_id'
      ||' AND   process_flag           = ' ||G_IN_PROCESS;

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,lv_sql_stmt);
      EXECUTE IMMEDIATE lv_sql_stmt
              USING     p_instance_code,
                        p_batch_id;
    END IF;
    RETURN(lv_status);

  EXCEPTION

    WHEN too_many_rows THEN
      p_error_text := substr('MSC_ST_UTIL.DERIVE_LEVEL_ID'||'('
                        ||v_sql_stmt||')'|| SQLERRM, 1, 240);
      return(SQLCODE);

    WHEN OTHERS THEN
      p_error_text := substr('MSC_ST_UTIL.DERIVE_LEVEL_ID'||'('
                        ||v_sql_stmt||')'|| SQLERRM, 1, 240);
      return(SQLCODE);

  END DERIVE_LEVEL_ID;

/*==========================================================================+
| DESCRIPTION  : This function is called for deriving sr_level_pk           |
|                from the msd_local_id_setup table.                         |
+==========================================================================*/
  FUNCTION DERIVE_SR_LEVEL_PK
           (p_table_name          VARCHAR2,
            p_level_val_col       VARCHAR2, --level value col name
            p_level_pk_col        VARCHAR2, --level_pk column name
            p_level_id_col        VARCHAR2, --level_id col name
            p_instance_code       VARCHAR2,
            p_message_text        VARCHAR2  DEFAULT NULL,
            p_batch_id            NUMBER    DEFAULT NULL_VALUE,
            p_error_text  OUT     NOCOPY VARCHAR2)
  RETURN NUMBER  IS
  lv_sql_stmt          VARCHAR2(5000);
  lv_where_str         VARCHAR2(100);
  lv_status            NUMBER := 0;
  --lv_debug BOOLEAN := retn_debug_mode;

  BEGIN
    v_sql_stmt := 01;
    lv_sql_stmt :=
    'UPDATE '||p_table_name ||' t1'
    ||' SET '||p_level_pk_col
    ||' = (SELECT local_id'
    ||' FROM msd_local_id_setup t2'
    ||' WHERE t2.char1      = t1.sr_instance_code'
    ||' AND   t2.char2      = t1.'||p_level_val_col
    ||' AND   t2.level_id   = t1.'||p_level_id_col||')'
    ||' WHERE  sr_instance_code = :p_instance_code'
    ||' AND    NVL(batch_id,'||NULL_VALUE||') = :p_batch_id'
    ||' AND   NVL(t1.'||p_level_pk_col||','||''''||NULL_CHAR||''''||') '
    ||'        =                '||''''||NULL_CHAR||''''
    ||' AND    process_flag     = '||G_IN_PROCESS ;

       MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,lv_sql_stmt);

    EXECUTE IMMEDIATE lv_sql_stmt
            USING     p_instance_code,
                      p_batch_id;
    RETURN(lv_status);

  EXCEPTION
    WHEN too_many_rows THEN
      p_error_text := substr('MSC_ST_UTIL.DERIVE_SR_LEVEL_PK'||'('
                        ||v_sql_stmt||')'|| SQLERRM, 1, 240);
      return(SQLCODE);

    WHEN OTHERS THEN
      p_error_text := substr('MSC_ST_UTIL.DERIVE_SR_LEVEL_PK'||'('
                        ||v_sql_stmt||')'|| SQLERRM, 1, 240);
      return(SQLCODE);

  END DERIVE_SR_LEVEL_PK;

/*==========================================================================+
| DESCRIPTION  : This function is called for deriving sr_xxx_pk             |
|                from the msd_st_level_values and msd_level_values          |
|                Should be used when level_id value to be passed as         |
|                a parameter and same is not stored in any column.          |
+==========================================================================*/

  FUNCTION DERIVE_SR_PK
           (p_table_name          VARCHAR2,
            p_column_name         VARCHAR2, --level value col name
            p_pk_col_name         VARCHAR2, --level_pk column name
            p_level_id            VARCHAR2, --level_id
            p_severity            VARCHAR2  DEFAULT G_SEV3_ERROR,
            p_instance_id         NUMBER,
            p_instance_code       VARCHAR2,
            p_message_text        VARCHAR2  DEFAULT NULL,
            p_batch_id            NUMBER    DEFAULT NULL_VALUE,
            p_error_text  OUT     NOCOPY VARCHAR2)
  RETURN NUMBER
  IS
  lv_sql_stmt          VARCHAR2(5000);
  lv_where_str         VARCHAR2(100);
  lv_status            NUMBER := 0;
  --lv_debug BOOLEAN := retn_debug_mode;


  BEGIN

    v_sql_stmt := 01;
    lv_sql_stmt :=
    'UPDATE '||p_table_name ||' t1'
    ||' SET '||p_pk_col_name
    ||' = NVL((SELECT sr_level_pk '
    ||' FROM msd_level_values t2'
    ||' WHERE t2.level_value '
    ||' =  t1.'||p_column_name
    ||' AND t2.level_id = :p_level_id '
    ||' AND t2.instance = :p_instance_id'
    ||' AND rownum      = 1'
    ||' UNION'
    ||' SELECT sr_level_pk'
    ||' FROM msd_st_level_values t3'
    ||' WHERE t3.level_value '
    ||' = t1.'||p_column_name
    ||' AND t3.level_id  = :p_level_id '
    ||' AND t3.instance  = :p_instance_id '
    ||' AND NOT EXISTS (SELECT sr_level_pk '
    ||' FROM msd_level_values t4'
    ||' WHERE t4.level_value '
    ||' = t1.'||p_column_name
    ||' AND t4.level_id = :p_level_id '
    ||' AND t4.instance = :p_instance_id)'
    ||' AND rownum = 1),'
    ||  p_pk_col_name||')' --This change is made to ensure that - not updating the sr_level_pk with any dummy value (like '-23453') when the value for the level value is not provided.
    ||' WHERE  sr_instance_code = :p_instance_code'
    ||' AND    NVL(batch_id,'||NULL_VALUE||') = :p_batch_id'
    ||' AND    process_flag     = '||G_IN_PROCESS ;

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,lv_sql_stmt);

    EXECUTE IMMEDIATE lv_sql_stmt
            USING     p_level_id,
                      p_instance_id,
                      p_level_id,
                      p_instance_id,
                      p_level_id,
                      p_instance_id,
                      p_instance_code,
                      p_batch_id;


    IF  p_severity = 1 THEN

      v_sql_stmt := 03;
      lv_sql_stmt :=
      'UPDATE '||p_table_name   ||' t1'
      ||' SET   error_text   = '||''''||p_message_text||''''||','
      ||'       process_flag = '||G_ERROR
      ||' WHERE  NVL(t1.'||p_pk_col_name||','||''''||NULL_CHAR||''''||') '
      ||'        =                '||''''||NULL_CHAR||''''
      ||' AND   sr_instance_code       = :p_instance_code'
      ||' AND   NVL(batch_id,'||NULL_VALUE||') = :p_batch_id'
      ||' AND   process_flag           = ' ||G_IN_PROCESS;

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,lv_sql_stmt);
      EXECUTE IMMEDIATE lv_sql_stmt
              USING     p_instance_code,
                        p_batch_id;

    ELSIF  p_severity = 3 THEN

      v_sql_stmt := 04;
      lv_sql_stmt :=
      'UPDATE '||p_table_name   ||' t1'
      ||' SET   error_text   = '||''''||p_message_text||''''||','
      ||'       process_flag = '||G_ERROR
      ||' WHERE  NVL(t1.'||p_pk_col_name||','||''''||NULL_CHAR||''''||') '
      ||'        =                '||''''||NULL_CHAR||''''
      ||' AND   NVL(t1.'||p_column_name||','||''''||NULL_CHAR||''''||') '
      ||'          <> '||''''||NULL_CHAR||''''
      ||' AND   sr_instance_code       = :p_instance_code'
      ||' AND   NVL(batch_id,'||NULL_VALUE||') = :p_batch_id'
      ||' AND   process_flag           = ' ||G_IN_PROCESS;

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,lv_sql_stmt);
      EXECUTE IMMEDIATE lv_sql_stmt
              USING     p_instance_code,
                        p_batch_id;

    END IF;
    RETURN(lv_status);

  EXCEPTION

    WHEN too_many_rows THEN
      p_error_text := substr('MSC_ST_UTIL.DERIVE_SR_PK'||'('
                        ||v_sql_stmt||')'|| SQLERRM, 1, 240);
      return(SQLCODE);

    WHEN OTHERS THEN
      p_error_text := substr('MSC_ST_UTIL.DERIVE_SR_PK'||'('
                        ||v_sql_stmt||')'|| SQLERRM, 1, 240);
      return(SQLCODE);

  END DERIVE_SR_PK ;

/*==========================================================================+
| DESCRIPTION  : This function is called for deriving level_pk              |
|                from the msd_st_level_values and msd_level_values          |
|                Should be used when level_name is stored in one of column  |
|                pass column as a parameter                                 |
+==========================================================================*/

  FUNCTION DERIVE_LEVEL_PK
           (p_table_name          VARCHAR2,
            p_level_val_col       VARCHAR2, --level value col name
            p_level_name_col      VARCHAR2, --level_name column
            p_level_pk_col        VARCHAR2, --level_val col name
            p_severity            VARCHAR2 DEFAULT G_SEV3_ERROR,
            p_instance_code       VARCHAR2,
            p_instance_id         NUMBER,
            p_message_text        VARCHAR2,
            p_batch_id            NUMBER    DEFAULT NULL_VALUE,
            p_error_text  OUT     NOCOPY VARCHAR2)
  RETURN NUMBER
  IS
  lv_sql_stmt          VARCHAR2(5000);
  lv_where_str         VARCHAR2(100);
  lv_status            NUMBER := 0;
  --lv_debug BOOLEAN := retn_debug_mode;

  BEGIN
    v_sql_stmt := 01;
    lv_sql_stmt :=
    'UPDATE '||p_table_name ||' t1'
    ||' SET '||p_level_pk_col
    ||' = NVL((SELECT sr_level_pk '
    ||' FROM msd_level_values t2'
    ||' WHERE t2.level_value '
    ||' =  t1.'||p_level_val_col
    ||' AND t2.level_id = (SELECT level_id'
    ||' FROM msd_levels t5 '
    ||' WHERE t5.level_name '
    ||' =  t1.'||p_level_name_col
    ||' AND t5.PLAN_TYPE IS  NULL )'--bug 4443782
    ||' AND t2.instance = :p_instance_id'
    ||' AND rownum  = 1'
    ||' UNION'
    ||' SELECT sr_level_pk'
    ||' FROM msd_st_level_values t3'
    ||' WHERE t3.level_value '
    ||' = t1.'||p_level_val_col
    ||' AND t3.level_id = (SELECT level_id'
    ||' FROM msd_levels t4'
    ||' WHERE t4.level_name  '
    ||' = t1.'||p_level_name_col
    ||' AND t4.PLAN_TYPE IS  NULL )'--bug 4443782
    ||' AND t3.instance  = :p_instance_id'
    ||' AND NOT EXISTS ( SELECT sr_level_pk'
    ||' FROM msd_level_values t2'
    ||' WHERE t2.level_value '
    ||' =  t1.'||p_level_val_col
    ||' AND t2.level_id = (SELECT level_id'
    ||' FROM msd_levels t5 '
    ||' WHERE t5.level_name '
    ||' =  t1.'||p_level_name_col
    ||' AND t5.PLAN_TYPE IS  NULL )'--bug 4443782
    ||' AND t2.instance = :p_instance_id )'
    ||' AND rownum=1 ),'
    ||  NULL_VALUE||')'
    ||' WHERE  sr_instance_code = :p_instance_code'
    ||' AND    NVL(batch_id,'||NULL_VALUE||') = :p_batch_id'
    ||' AND   NVL(t1.'||p_level_val_col||','||''''||NULL_CHAR||''''||') '
    ||'          <> '||''''||NULL_CHAR||''''
    ||' AND    process_flag     = '||G_IN_PROCESS ;

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,lv_sql_stmt);

    EXECUTE IMMEDIATE lv_sql_stmt
            USING     p_instance_id,
                      p_instance_id,
                      p_instance_id,
                      p_instance_code,
                      p_batch_id;


    IF  p_severity = 1 THEN

      v_sql_stmt := 03;
      lv_sql_stmt :=
      'UPDATE '||p_table_name   ||' t1'
      ||' SET   error_text   = '||''''||p_message_text||''''||','
      ||'       process_flag = '||G_ERROR
      ||' WHERE  NVL(t1.'||p_level_pk_col||','||''''||NULL_CHAR||''''||') '
      ||'        =                '||''''||NULL_CHAR||''''
      ||' AND   sr_instance_code       = :p_instance_code'
      ||' AND   NVL(batch_id,'||NULL_VALUE||') = :p_batch_id'
      ||' AND   process_flag           = ' ||G_IN_PROCESS;

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,lv_sql_stmt);
      EXECUTE IMMEDIATE lv_sql_stmt
              USING     p_instance_code,
                        p_batch_id;

    ELSIF  p_severity = 3 THEN

      v_sql_stmt := 04;
      lv_sql_stmt :=
      'UPDATE '||p_table_name   ||' t1'
      ||' SET   error_text   = '||''''||p_message_text||''''||','
      ||'       process_flag = '||G_ERROR
      ||' WHERE  NVL(t1.'||p_level_pk_col||','||''''||NULL_CHAR||''''||') '
      ||'        =                '||''''||NULL_CHAR||''''
      ||' AND   NVL(t1.'||p_level_val_col||','||''''||NULL_CHAR||''''||') '
      ||'          <> '||''''||NULL_CHAR||''''
      ||' AND   sr_instance_code       = :p_instance_code'
      ||' AND   NVL(batch_id,'||NULL_VALUE||') = :p_batch_id'
      ||' AND   process_flag           = ' ||G_IN_PROCESS;

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,lv_sql_stmt);
      EXECUTE IMMEDIATE lv_sql_stmt
              USING     p_instance_code,
                        p_batch_id;

    END IF;
    RETURN(lv_status);

  EXCEPTION

    WHEN too_many_rows THEN
      p_error_text := substr('MSC_ST_UTIL.DERIVE_LEVEL_PK'||'('
                        ||v_sql_stmt||')'|| SQLERRM, 1, 240);
      return(SQLCODE);

    WHEN OTHERS THEN
      p_error_text := substr('MSC_ST_UTIL.DERIVE_LEVEL_PK'||'('
                        ||v_sql_stmt||')'|| SQLERRM, 1, 240);
      return(SQLCODE);

 END DERIVE_LEVEL_PK ;

  PROCEDURE LOG_MESSAGE(p_error_text IN  VARCHAR2)
   IS
  BEGIN
    IF fnd_global.conc_request_id > 0  THEN
    FND_FILE.PUT_LINE( FND_FILE.LOG, p_error_text);
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      RETURN;

  END LOG_MESSAGE;

/*==========================================================================+
| Returns the default instance code based on the trading partner code.      |
| This function would be called from XML Gateway to get the default instance|
| code in case the XML message does not contain the instance code           |
+==========================================================================*/
  FUNCTION  GET_INSTANCE_CODE (p_trading_partner_id number)  RETURN VARCHAR2
  IS
  lv_instance_code msc_apps_instances.instance_code%TYPE;
/*
  CURSOR c_inst(p_trading_partner_id number) IS
    SELECT  instance_code
    FROM    msc_apps_instances mai
    WHERE   mai.default_flag = 'Y'
    AND     company_id = (SELECT company_id
                          FROM   msc_trading_partners mtp
                          WHERE  mtp.partner_id = p_trading_partner_id);
*/

  BEGIN
/*
    OPEN c_inst(p_trading_partner_id);
    FETCH c_inst INTO lv_instance_code ;
    CLOSE c_inst;

    RETURN lv_instance_code;
*/
    RETURN null;

  EXCEPTION
    WHEN no_data_found THEN
      lv_instance_code := 'ERROR';
      RETURN lv_instance_code;

    WHEN too_many_rows THEN
      lv_instance_code := 'ERROR';
      RETURN lv_instance_code;

    WHEN OTHERS THEN
      lv_instance_code := 'ERROR';
      RETURN lv_instance_code;

  END GET_INSTANCE_CODE;

/*==========================================================================+
| DESCRIPTION  : This procedure  takes the SYNCIND value from the XML       |
|                message in character and convert it into numeric records.  |
+==========================================================================*/
  PROCEDURE retn_delete_flag
           (p_syncind   IN   VARCHAR2,
            p_return    OUT  NOCOPY NUMBER) IS
  lv_return	number;
  BEGIN
    SELECT DECODE(NVL(UPPER(p_syncind),'A'),'D',1,2)
    INTO   p_return
    FROM dual;
  EXCEPTION
    WHEN others THEN
      p_return := -1;
  END retn_delete_flag ;

/*==========================================================================+
| DESCRIPTION  : This procedure  takes the Schedule Type value from the XML |
|                message in character and convert it into numeric records.  |
+==========================================================================*/
  PROCEDURE retn_schedule_id
           (p_schedule_type IN   VARCHAR2,
            p_schid         OUT  NOCOPY NUMBER) IS
  BEGIN
    SELECT DECODE(NVL(UPPER(p_schedule_type),'MDS'),'MDS',1,'MPS',2,'FORECAST',6,
         'SUPPLY FORECAST',2,'DEMAND_FORECAST',6,1)
    INTO   p_schid
    FROM   dual;
  EXCEPTION
    WHEN others THEN
      p_schid := -1;
  END retn_schedule_id;

/*=====================================================================+
| DESCRIPTION  : This function  provides the user friendly name of the |
|                entity whose local_id is provided, by looking into the|
|                corresponding MSC_LOCAL_ID_XXX table                  |
+======================================================================*/
  FUNCTION ret_code
           (p_entity_name IN   VARCHAR2,
            p_id          IN   NUMBER)
  RETURN VARCHAR2 IS
  TYPE c_cur_type IS REF CURSOR;
  c_cur			c_cur_type;
  lv_return_val 	VARCHAR2(240):='';
  lv_sql_stmt		VARCHAR2(1000):='';
  BEGIN
    -- LINE_CODE
    IF p_entity_name = 'LINE_ID' THEN
      lv_sql_stmt:=
      'SELECT  CHAR4 '
      ||' FROM MSC_LOCAL_ID_SETUP '
      ||' WHERE entity_name = :entity_id'
      ||' AND local_id = :local_id';

    --ITEM_NAME
    ELSIF p_entity_name = 'SR_INVENTORY_ITEM_ID' THEN
      lv_sql_stmt:=
      'SELECT CHAR4 '
      ||' FROM MSC_LOCAL_ID_ITEM '
      ||' WHERE entity_name = :entity_id'
      ||' AND local_id = :local_id';

    -- PROJECT_NUMBER
    ELSIF p_entity_name = 'PROJECT_ID' THEN
      lv_sql_stmt:=
      'SELECT CHAR4 '
      ||' FROM MSC_LOCAL_ID_MISC'
      ||' WHERE entity_name = :entity_id'
      ||' AND local_id = :local_id';

    -- TASK_NUMBER
     ELSIF p_entity_name = 'TASK_ID' THEN
      lv_sql_stmt:=
      'SELECT CHAR5 '
      ||' FROM MSC_LOCAL_ID_MISC'
      ||' WHERE entity_name = :entity_id'
      ||' AND local_id = :local_id';

    -- BOM_NAME
    ELSIF p_entity_name = 'BILL_SEQUENCE_ID' THEN
      lv_sql_stmt:=
      'SELECT CHAR4 '
      ||' FROM MSC_LOCAL_ID_SETUP '
      ||' WHERE entity_name = :entity_id'
      ||' AND local_id = :local_id';

    -- ROUTING_NAME
    ELSIF p_entity_name = 'ROUTING_SEQUENCE_ID' THEN
      lv_sql_stmt:=
      'SELECT CHAR4 '
      ||' FROM MSC_LOCAL_ID_SETUP '
      ||' WHERE entity_name = :entity_id'
      ||' AND local_id = :local_id';

    -- DEPARTMENT_CODE
    ELSIF p_entity_name = 'DEPARTMENT_ID' THEN
      lv_sql_stmt:=
      'SELECT CHAR4 '
      ||' FROM MSC_LOCAL_ID_SETUP '
      ||' WHERE entity_name = :entity_id'
      ||' AND local_id = :local_id';

    -- OPERATION_SEQ_CODE
    ELSIF p_entity_name = 'OPERATION_SEQUENCE_ID' THEN
      lv_sql_stmt:=
      'SELECT CHAR5 '
      ||' FROM MSC_LOCAL_ID_SETUP '
      ||' WHERE entity_name = :entity_id'
      ||' AND local_id = :local_id';

    -- RESOURCE_SEQ_CODE
    ELSIF p_entity_name = 'RESOURCE_SEQ_NUM' THEN
      lv_sql_stmt:=
      'SELECT CHAR6 '
      ||' FROM MSC_LOCAL_ID_SETUP '
      ||' WHERE entity_name = :entity_id'
      ||' AND local_id = :local_id';

    -- RESOURCE_CODE
    ELSIF p_entity_name = 'RESOURCE_ID' THEN
      lv_sql_stmt:=
      'SELECT CHAR4 '
      ||' FROM MSC_LOCAL_ID_SETUP '
      ||' WHERE entity_name = :entity_id'
      ||' AND local_id = :local_id';

    -- PURCH_LINE_NUM
    ELSIF p_entity_name = 'PO_LINE_ID' THEN
      lv_sql_stmt:=
      'SELECT NUMBER1 '
      ||'FROM MSC_LOCAL_ID_SUPPLY '
      ||'WHERE entity_name = :entity_id '
      ||'AND local_id = :local_id ';

    -- SCHEDULE_LINE_NUM
    ELSIF p_entity_name = 'DISPOSITION_ID_MPS' THEN
      lv_sql_stmt:=
      'SELECT CHAR5 '
      ||'FROM MSC_LOCAL_ID_SUPPLY '
      ||'WHERE entity_name = :entity_id '
      ||'AND local_id = :local_id ';

    -- WIP_ENTITY_NAME
    ELSIF p_entity_name = 'WIP_ENTITY_ID' THEN
      lv_sql_stmt:=
      'SELECT CHAR4 '
      ||'FROM MSC_LOCAL_ID_SUPPLY '
      ||'WHERE entity_name = :entity_id '
      ||'AND local_id = :local_id ';

    END IF;

    OPEN c_cur FOR lv_sql_stmt USING p_entity_name,p_id;
    FETCH c_cur into lv_return_val;
    CLOSE c_cur;
    RETURN (lv_return_val );
  END ret_code ;

/*=====================================================================+
| DESCRIPTION  : This function provides the organization code          |
+======================================================================*/
  FUNCTION ret_org_code
           (p_sr_instance_id    IN NUMBER,
            p_organization_id   IN NUMBER)
  RETURN VARCHAR2 IS
  TYPE c_cur_type IS REF CURSOR;
  c_cur			c_cur_type;
  lv_return_val 	VARCHAR2(240):='';
  lv_sql_stmt		VARCHAR2(1000):='';
  BEGIN

    lv_sql_stmt:=
    'SELECT organization_code '
    ||'FROM msc_trading_partners  mtp '
    ||'WHERE mtp.sr_instance_id = :instance_id '
    ||'AND mtp.sr_tp_id = :org_id '
    ||'AND mtp.partner_type = 3 ';

    OPEN c_cur FOR   lv_sql_stmt
               USING p_sr_instance_id ,
                     p_organization_id;

    FETCH c_cur INTO lv_return_val;
    CLOSE c_cur;

    lv_return_val := substr(lv_return_val, instr(lv_return_val,':') + 1);

    RETURN (lv_return_val );
  END ret_org_code;

/*=============================================================================+
| DESCRIPTION  : This function provides the partner name given the partner_id  |
+=============================================================================*/
  FUNCTION ret_partner_name
           (p_partner_id        IN NUMBER)
  RETURN VARCHAR2 IS
  TYPE c_cur_type IS REF CURSOR;
  c_cur			c_cur_type;
  lv_return_val 	VARCHAR2(240):='';
  lv_sql_stmt		VARCHAR2(1000):='';
  BEGIN

    lv_sql_stmt:=
    'SELECT   partner_name '
    ||' FROM  msc_trading_partners  mtp '
    ||' WHERE mtp.partner_id =  :partner_id ';

    OPEN c_cur FOR   lv_sql_stmt
               USING p_partner_id;
    FETCH c_cur INTO lv_return_val;
    CLOSE c_cur;

    RETURN (lv_return_val );
  END ret_partner_name ;


/*=============================================================================+
| DESCRIPTION  : This function provides the partner name given the sr_tp_id    |
+=============================================================================*/
  FUNCTION ret_partner_name
           (p_instance_id    IN    NUMBER,
            p_sr_tp_id       IN    NUMBER,
            p_partner_type   IN    NUMBER)
  RETURN VARCHAR2 IS
  TYPE c_cur_type IS REF CURSOR;
  c_cur			c_cur_type;
  lv_return_val 	VARCHAR2(240):='';
  lv_sql_stmt		VARCHAR2(1000):='';

  BEGIN
    lv_sql_stmt:=
    'SELECT   mtp.partner_name '
    ||' FROM  msc_trading_partners  mtp, '
    ||' msc_tp_id_lid mtp_lid '
    ||' WHERE mtp.partner_id = mtp_lid.tp_id'
    ||' AND   mtp_lid.sr_instance_id    = :instance_id'
    ||' AND   mtp_lid.sr_tp_id          = :sr_tp_id '
    ||' AND   mtp_lid.partner_type      = :partner_type ';

    OPEN c_cur FOR    lv_sql_stmt
               USING  p_instance_id,
                      p_sr_tp_id,
                      p_partner_type;

    FETCH c_cur INTO lv_return_val;
    CLOSE c_cur;
    RETURN (lv_return_val );

  END ret_partner_name ;

/*=================================================================================+
| DESCRIPTION  : This function provides the partner site given the partner_site_id |
+==================================================================================*/
  FUNCTION ret_partner_site
           (p_partner_site_id  IN   NUMBER)
  RETURN VARCHAR2 IS
  TYPE c_cur_type IS REF CURSOR;
  c_cur			c_cur_type;
  lv_return_val 	VARCHAR2(240):='';
  lv_sql_stmt		VARCHAR2(1000):='';

  BEGIN
    lv_sql_stmt:=
    'SELECT  tp_site_code '
    ||'FROM  MSC_TRADING_PARTNER_SITES mtps '
    ||'WHERE mtps.partner_site_id = :partner_site ';

    OPEN  c_cur FOR    lv_sql_stmt
               USING  p_partner_site_id;
    FETCH c_cur INTO lv_return_val;
    CLOSE c_cur;

    RETURN (lv_return_val );

  END ret_partner_site ;


/*=================================================================================+
| DESCRIPTION  : This function provides the partner site given the sr_tp_site_id   |
+==================================================================================*/
  FUNCTION ret_partner_site
           (p_instance_id      IN   NUMBER,
            p_sr_tp_site_id    IN   NUMBER,
            p_partner_type     IN   NUMBER)
  RETURN VARCHAR2 IS
  TYPE c_cur_type IS REF CURSOR;
  c_cur			c_cur_type;
  lv_return_val 	VARCHAR2(240):='';
  lv_sql_stmt		VARCHAR2(1000):='';

  BEGIN
    lv_sql_stmt:=
    ' SELECT mtps.tp_site_code '
    ||' FROM MSC_TRADING_PARTNER_SITES mtps,'
    ||' MSC_TP_SITE_ID_LID mtps_lid'
    ||' WHERE mtps.partner_site_id = mtps_lid.sr_tp_site_id'
    ||' AND mtps_lid.sr_instance_id = :instance_id '
    ||' AND mtps_lid.sr_tp_site_id = :partner_site '
    ||' AND mtps_lid.partner_type = :partner_type ';

    OPEN c_cur  FOR   lv_sql_stmt
                USING p_instance_id,
                      p_sr_tp_site_id,
                      p_partner_type;
    FETCH c_cur INTO  lv_return_val;
    CLOSE c_cur;

    RETURN (lv_return_val );

  END ret_partner_site ;

/*=================================================================================+
| DESCRIPTION  : This function provides the designator name given the designator_id|
+==================================================================================*/
  FUNCTION ret_desig
           (p_designator_id    IN   NUMBER)
  RETURN VARCHAR2 IS
  TYPE c_cur_type IS REF CURSOR;
  c_cur			c_cur_type;
  lv_return_val 	VARCHAR2(240):='';
  lv_sql_stmt		VARCHAR2(1000):='';

  BEGIN
    lv_sql_stmt:=
    'SELECT  designator '
    ||'FROM  msc_designators '
    ||'WHERE designator_id  = :designator_id ';

    OPEN c_cur  FOR    lv_sql_stmt
                USING  p_designator_id;
    FETCH c_cur INTO   lv_return_val;
    CLOSE c_cur;

    RETURN (lv_return_val );

  END ret_desig ;

/*=================================================================================+
| DESCRIPTION  : This function provides the instance code given the instance_id    |
+==================================================================================*/
  FUNCTION ret_sr_instance_code
           (p_sr_instance_id   IN   NUMBER)
  RETURN VARCHAR2 IS
  TYPE c_cur_type IS REF CURSOR;
  c_cur			c_cur_type;
  lv_return_val 	VARCHAR2(240):='';
  lv_sql_stmt		VARCHAR2(1000):='';
  BEGIN

    lv_sql_stmt:=
    'SELECT   instance_code '
    ||'FROM   msc_apps_instances  '
    ||'WHERE  instance_id = :instance_id ';

    OPEN c_cur  FOR    lv_sql_stmt
                USING  p_sr_instance_id;
    FETCH c_cur INTO   lv_return_val;
    CLOSE c_cur;

    RETURN (lv_return_val );

  END ret_sr_instance_code ;

/*=================================================================================+
| DESCRIPTION  : This function provides the project number                         |
+==================================================================================*/
  FUNCTION ret_project_number
           (p_project_id       IN     NUMBER ,
            p_sr_instance_id   IN     NUMBER ,
            p_organization_id  IN     NUMBER,
            p_plan_id          IN     NUMBER)
  RETURN VARCHAR2 IS
  TYPE c_cur_type IS REF CURSOR;
  c_cur			c_cur_type;
  lv_return_val 	VARCHAR2(240):='';
  lv_sql_stmt		VARCHAR2(1000):='';

  BEGIN
    lv_sql_stmt:=
    'SELECT  project_number '
    ||'FROM  msc_projects '
    ||'WHERE sr_instance_id  = :instance_id '
    ||'AND   organization_id = :org_id '
    ||'AND   project_id      = :project_id '
    ||'AND   plan_id         = :plan_id ';

    OPEN c_cur  FOR    lv_sql_stmt
                USING  p_sr_instance_id,
                       p_organization_id,
                       p_project_id,
                       p_plan_id  ;
    FETCH c_cur INTO  lv_return_val;
    CLOSE c_cur;

    RETURN (lv_return_val );
  END ret_project_number ;

/*=================================================================================+
| DESCRIPTION  : This function provides the task number                            |
+==================================================================================*/
  FUNCTION ret_task_number
           (p_project_id        IN     NUMBER,
            p_task_id           IN     NUMBER,
            p_sr_instance_id    IN     NUMBER,
            p_organization_id   IN     NUMBER,
            p_plan_id           IN     NUMBER)
  RETURN VARCHAR2 IS
  TYPE c_cur_type IS REF CURSOR;
  c_cur	            c_cur_type;
  lv_return_val     VARCHAR2(240):='';
  lv_sql_stmt	    VARCHAR2(1000):='';

  BEGIN
    lv_sql_stmt:=
    'SELECT   task_number '
    ||' FROM  msc_project_tasks '
    ||' WHERE sr_instance_id  = :instance_id '
    ||' AND   organization_id = :org_id '
    ||' AND   project_id      = :project_id '
    ||' AND   task_id         = :task_id '
    ||' AND   plan_id         = :plan_id ';

    OPEN c_cur FOR    lv_sql_stmt
               USING  p_sr_instance_id,
                      p_organization_id,
                      p_project_id,
                      p_task_id,
                      p_plan_id  ;
    FETCH c_cur INTO  lv_return_val;
    CLOSE c_cur;
    RETURN (lv_return_val );

  END ret_task_number ;

/*=================================================================================+
| DESCRIPTION  : This function provides the wip entity name                        |
+==================================================================================*/
  FUNCTION ret_wip_entity_name
           (p_wip_entity_id       IN    NUMBER,
            p_sr_instance_id      IN    NUMBER,
            p_organization_id     IN    NUMBER,
            p_plan_id             IN    NUMBER)
  RETURN VARCHAR2 IS
  TYPE c_cur_type IS REF CURSOR;
  c_cur	             c_cur_type;
  lv_return_val      VARCHAR2(240):='';
  lv_sql_stmt	     VARCHAR2(1000):='';
  BEGIN

    lv_sql_stmt:=
    'SELECT   wip_entity_name '
    ||'FROM   msc_supplies '
    ||'WHERE  sr_instance_id  = :instance_id '
    ||'AND    organization_id = :org_id '
    ||'AND    disposition_id  =  :wip_entity_id '
    ||'AND    order_type      IN (3,7) '
    ||'AND    plan_id         = :plan_id ';

    OPEN c_cur FOR    lv_sql_stmt
               USING  p_sr_instance_id,
                      p_organization_id,
                      p_wip_entity_id ,
                      p_plan_id  ;

    FETCH c_cur INTO lv_return_val;
    CLOSE c_cur;
    RETURN (lv_return_val );

END ret_wip_entity_name ;

/*=======================================================================================================+
| DESCRIPTION  : This function provides the group_id for MSC_FROUPS and MSC_GROUP_COMPANIES aeroexhange    |
+========================================================================================================*/
FUNCTION DERIVE_GROUP_ID
           (p_table_name         VARCHAR2,
            p_grp_col_name      VARCHAR2,
            p_grp_col_id        VARCHAR2,
            p_instance_id        NUMBER,
            p_instance_code      VARCHAR2,
            p_error_text OUT     NOCOPY VARCHAR2,
            p_batch_id           NUMBER    DEFAULT NULL_VALUE,
            p_severity           NUMBER    DEFAULT 0,
            p_message_text       VARCHAR2  DEFAULT NULL,
            p_debug              BOOLEAN   DEFAULT FALSE,
            p_row                LONG      DEFAULT NULL)
  RETURN NUMBER IS
  lv_sql_stmt          VARCHAR2(5000);
  lv_where_str         VARCHAR2(100);
  lv_status            NUMBER := 0;
  BEGIN

    v_sql_stmt  := 01;
    lv_sql_stmt :=
    'UPDATE '||p_table_name ||' t1'
    ||' SET '||p_grp_col_id
    ||' = (SELECT local_id'
    ||' FROM msc_local_id_setup t2'
    ||' WHERE  t2.char1         = t1.'||p_grp_col_name
    ||' AND    t2.entity_name   = ''GROUP_ID'' )'
    ||' WHERE  sr_instance_code = :p_instance_code'
    ||' AND    NVL(batch_id,'||NULL_VALUE||') = :p_batch_id'
    ||' AND    process_flag     = '||G_IN_PROCESS;

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,lv_sql_stmt);

    EXECUTE IMMEDIATE lv_sql_stmt
            USING     p_instance_code,
                      p_batch_id;

    IF p_message_text IS NOT NULL and p_severity = 1 THEN
      v_sql_stmt  := 07;
      lv_sql_stmt :=
      'UPDATE '||p_table_name   ||' t1'
      ||' SET   error_text   = '||''''||p_message_text||''''||','
      ||'       process_flag = '||g_error
      ||' WHERE NVL(t1.'||p_grp_col_id||','||NULL_VALUE||') = '||NULL_VALUE
      ||' AND   sr_instance_code       = :p_instance_code'
      ||' AND   NVL(batch_id,'||NULL_VALUE||') = :p_batch_id'
      ||' AND   process_flag           = ' ||G_IN_PROCESS;

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,lv_sql_stmt);
      EXECUTE IMMEDIATE lv_sql_stmt
              USING     p_instance_code,
                        p_batch_id;

    ELSIF p_message_text IS NOT NULL and  p_severity = 2 THEN
      lv_where_str :=
      ' AND NVL('||p_grp_col_id||','||NULL_VALUE||') = '||NULL_VALUE;

      lv_status := LOG_ERROR(p_table_name       => p_table_name,
                             p_instance_code    => p_instance_code,
                             p_row              => p_row,
                             p_severity         => p_severity,
                             p_propagated       => 'N',
                             p_where_str        => lv_where_str,
                             p_message_text     => p_message_text,
                             p_error_text       => p_error_text,
                             p_batch_id         => p_batch_id);

    ELSIF p_message_text IS NOT NULL and  p_severity = 3 THEN
      v_sql_stmt  := 08;
      lv_sql_stmt :=
      'UPDATE '||p_table_name   ||' t1'
      ||' SET   error_text   = '||''''||p_message_text||''''||','
      ||'       process_flag = '||g_error
      ||' WHERE NVL(t1.'||p_grp_col_id||','||NULL_VALUE||') = '||NULL_VALUE
      ||' AND   NVL(t1.'||p_grp_col_name||','||''''||NULL_CHAR||''''||') '
      ||'          <> '||''''||NULL_CHAR||''''
      ||' AND   sr_instance_code       = :p_instance_code'
      ||' AND   NVL(batch_id,'||NULL_VALUE||')= :p_batch_id'
      ||' AND   process_flag           = ' ||G_IN_PROCESS;
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,lv_sql_stmt);
      EXECUTE IMMEDIATE lv_sql_stmt
              USING     p_instance_code,
                        p_batch_id;

    END IF;
    RETURN(lv_status);

  EXCEPTION
    WHEN too_many_rows THEN
      p_error_text := substr('MSC_ST_UTIL.DERIVE_GROUP_ID'||'('
                        ||v_sql_stmt||')'|| SQLERRM, 1, 240);
      return(SQLCODE);

    WHEN OTHERS THEN
      p_error_text := substr('MSC_ST_UTIL.DERIVE_GROUP_ID'||'('
                        ||v_sql_stmt||')'|| SQLERRM, 1, 240);
      return(SQLCODE);

 END DERIVE_GROUP_ID;


/*===================================================================================+
| DESCRIPTION  : This function provides the item name given the sr_inventory_item_id |
+====================================================================================*/
  FUNCTION ret_item_name
           (p_item_id          IN      NUMBER,
            p_sr_instance_id   IN      NUMBER,
            p_organization_id  IN      NUMBER,
            p_plan_id          IN      NUMBER)
  RETURN VARCHAR2 IS
  TYPE c_cur_type IS REF CURSOR;
  c_cur	            c_cur_type;
  lv_return_val     VARCHAR2(240):='';
  lv_sql_stmt	      VARCHAR2(1000):='';

  BEGIN
    lv_sql_stmt:=
    'SELECT  ITEM_NAME '
    ||'FROM  MSC_SYSTEM_ITEMS '
    ||'WHERE sr_instance_id       = :instance_id '
    ||'AND   organization_id      = :org_id '
    ||'AND   sr_inventory_item_id =  :item_id '
    ||'AND   plan_id              = :plan_id ';

    OPEN c_cur  FOR   lv_sql_stmt
                USING p_sr_instance_id,
                      p_organization_id,
                      p_item_id ,
                      p_plan_id  ;
    FETCH c_cur INTO  lv_return_val;
    CLOSE c_cur;

    RETURN (lv_return_val );

  END ret_item_name ;

/*=================================================================================+
| DESCRIPTION  : This function accepts Yes/No and returns the corresponding numeric|
|                value.                                                            |
|                1-Yes                                                             |
|                2-No                                                              |
+==================================================================================*/
  PROCEDURE retn_yes_no_value
           (p_yes_no_code  IN   VARCHAR2,
            p_yes_no_value OUT  NOCOPY NUMBER) IS
  TYPE c_cur_type IS REF CURSOR;
  c_cur			c_cur_type;
  lv_sql_stmt		VARCHAR2(1000):='';
  BEGIN

    lv_sql_stmt:=
    'SELECT DECODE(SUBSTR(UPPER(NVL(:p_yes_no_code,''N'')),1,1),''Y'',1,2)'
    ||' FROM dual';

    OPEN c_cur  FOR    lv_sql_stmt
                USING  p_yes_no_code;
    FETCH c_cur INTO   p_yes_no_value;
    CLOSE c_cur;

  END retn_yes_no_value;


  /*=================================================================================+
| DESCRIPTION  : This function accepts user_id and returns the corresponding boolean |
|                value, stating that whether the user is an operator or not.         |
+===================================================================================*/
  FUNCTION IS_OPERATOR (p_user_id  IN   NUMBER)
  RETURN BOOLEAN IS
  lv_cnt  NUMBER;

  BEGIN

  	select COUNT(*) into lv_cnt
  	FROM FND_USER_RESP_GROUPS
  	WHERE user_id IN (select USER_ID from MSC_COMPANY_USERS where user_id = p_user_id AND company_id = 1)
  	AND responsibility_id = (SELECT responsibility_id FROM FND_RESPONSIBILITY WHERE responsibility_key = 'MSCX_SC_ADMIN_FULL')
  	AND  SYSDATE between  start_date and decode(end_date,NULL,SYSDATE)  ;

	    IF lv_cnt > 0 THEN
	    	RETURN TRUE;
	    ELSE
	    	RETURN FALSE;
	    END IF;

  END IS_OPERATOR;

/*=================================================================================+
| DESCRIPTION  : This procedure is used to explode the composite calendar from week |
|                level to the day level.                                            |
+===================================================================================*/

 procedure Explode_Composite_Dates(
              errbuf                  OUT NOCOPY  VARCHAR2,
              retcode                 OUT NOCOPY  VARCHAR2,
              p_dest_table            IN  VARCHAR2,
              p_instance_id           IN  NUMBER,
              p_calendar_type_id      IN  NUMBER,
              p_calendar_code         IN  VARCHAR2,
              p_seq_num               IN  NUMBER,
              p_year                  IN  VARCHAR2,
              p_year_description      IN  VARCHAR2,
              p_year_start_date       IN  DATE,
              p_year_end_date         IN  DATE,
              p_quarter               IN  VARCHAR2,
              p_quarter_description   IN  VARCHAR2,
              p_quarter_start_date    IN  DATE,
              p_quarter_end_date      IN  DATE,
              p_month                 IN  VARCHAR2,
              p_month_description     IN  VARCHAR2,
              p_month_start_date      IN  DATE,
              p_month_end_date        IN  DATE,
              p_week                  IN  VARCHAR2,
              p_week_description      IN  VARCHAR2,
              p_week_start_date       IN  DATE,
              p_week_end_date         IN  DATE ) IS

lv_num_of_days   NUMBER;
lv_current_date  DATE ;
lv_count         NUMBER;

Begin

	lv_count := p_week_end_date - p_week_start_date ;

	if (p_dest_table = MSD_COMMON_UTILITIES.TIME_FACT_TABLE) then

          For lv_num_of_days in 0..(p_week_end_date - p_week_start_date) LOOP

	    v_seq_num := v_seq_num + 1 ;

            insert into msd_time  (
                        instance,
                        calendar_type,
                        calendar_code,
                        seq_num,
                        YEAR,
                        YEAR_DESCRIPTION,
                        YEAR_START_DATE,
                        YEAR_END_DATE,
                        QUARTER,
                        QUARTER_DESCRIPTION,
                        QUARTER_START_DATE,
                        QUARTER_END_DATE,
                        MONTH,
                        MONTH_DESCRIPTION,
                        MONTH_START_DATE,
                        MONTH_END_DATE,
                        WEEK,
                        WEEK_DESCRIPTION,
                        WEEK_START_DATE,
                        WEEK_END_DATE,
                        DAY,
                        DAY_DESCRIPTION,
                        LAST_UPDATE_DATE,
                        last_updated_by,
                        creation_date,
                        created_by,
                        LAST_UPDATE_LOGIN )
            values(
              		p_instance_id,
              		p_calendar_type_id,
              		p_calendar_code,
              		v_seq_num,
              		p_year,
              		p_year_description,
              		p_year_start_date,
              		p_year_end_date,
              		p_quarter,
              		p_quarter_description,
              		p_quarter_start_date,
              		p_quarter_end_date,
              		p_month,
              		p_month_description,
              		p_month_start_date,
              		p_month_end_date,
			p_week,
			p_week_description,
			p_week_start_date,
			p_week_end_date,
		        p_week_start_date + lv_num_of_days,
			p_week_start_date + lv_num_of_days,
			sysdate,
			FND_GLOBAL.USER_ID ,
			sysdate,
			FND_GLOBAL.USER_ID ,
			FND_GLOBAL.USER_ID
		 ) ;


	    End Loop ;

        elsif (p_dest_table = MSD_COMMON_UTILITIES.TIME_STAGING_TABLE) then

          For lv_num_of_days in 0..(p_week_end_date - p_week_start_date) LOOP

	    v_seq_num := v_seq_num + 1 ;

            insert into msd_st_time  (
                        instance,
                        calendar_type,
                        calendar_code,
                        seq_num,
                        YEAR,
                        YEAR_DESCRIPTION,
                        YEAR_START_DATE,
                        YEAR_END_DATE,
                        QUARTER,
                        QUARTER_DESCRIPTION,
                        QUARTER_START_DATE,
                        QUARTER_END_DATE,
                        MONTH,
                        MONTH_DESCRIPTION,
                        MONTH_START_DATE,
                        MONTH_END_DATE,
                        WEEK,
                        WEEK_DESCRIPTION,
                        WEEK_START_DATE,
                        WEEK_END_DATE,
                        DAY,
                        DAY_DESCRIPTION,
                        LAST_UPDATE_DATE,
                        last_updated_by,
                        creation_date,
                        created_by,
                        LAST_UPDATE_LOGIN )
            values(
                        p_instance_id,
                        p_calendar_type_id,
                        p_calendar_code,
                        v_seq_num,
                        p_year,
                        p_year_description,
                        p_year_start_date,
                        p_year_end_date,
                        p_quarter,
                        p_quarter_description,
                        p_quarter_start_date,
                        p_quarter_end_date,
                        p_month,
                        p_month_description,
                        p_month_start_date,
                        p_month_end_date,
                        p_week,
			p_week_description,
			p_week_start_date,
			p_week_end_date,
                        p_week_start_date + lv_num_of_days,
                        p_week_start_date + lv_num_of_days,
                        sysdate,
			FND_GLOBAL.USER_ID ,
			sysdate,
			FND_GLOBAL.USER_ID ,
			FND_GLOBAL.USER_ID
		 ) ;

            End Loop ;

	End if ;


        exception

          when others then
                MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_WARNING,substr(SQLERRM,1,1000));
                errbuf := substr(SQLERRM,1,150);
                retcode := -1 ;


End Explode_Composite_Dates ;

FUNCTION DERIVE_SETUP_SR_LEVEL_PK
           (p_table_name          VARCHAR2,
            p_level_val_col       VARCHAR2, --level value col name
            p_level_pk_col        VARCHAR2, --level_pk column name
            p_level_id_col        VARCHAR2, --level_id col name
            p_instance_code       VARCHAR2,
            p_instance_id         NUMBER,
            p_message_text        VARCHAR2  DEFAULT NULL,
            p_batch_id            NUMBER    DEFAULT NULL_VALUE,
            p_error_text  OUT     NOCOPY VARCHAR2)
  RETURN NUMBER  IS
  lv_sql_stmt          VARCHAR2(5000);
  lv_where_str         VARCHAR2(100);
  lv_status            NUMBER := 0;
  --lv_debug BOOLEAN := retn_debug_mode;

  BEGIN
    v_sql_stmt := 01; --Items and Product Family

    lv_sql_stmt :=
    'UPDATE '||p_table_name ||' t1'
    ||' SET '||p_level_pk_col
    ||' = (SELECT sr_inventory_item_id '
    ||' FROM msc_system_items t2'
    ||' WHERE t2.sr_instance_id = :p_instance_id'
    ||' AND   t2.item_name      = t1.'||p_level_val_col
    ||' AND   t2.plan_id        = -1 '
    ||' AND   t2.bom_item_type  <> 5 '
    ||' AND   rownum = 1 )'
    ||' WHERE  sr_instance_code = :p_instance_code'
    ||' AND    NVL(batch_id,'||NULL_VALUE||') = :p_batch_id'
    ||' AND   NVL(t1.'||p_level_pk_col||','||''''||NULL_CHAR||''''||') '
    ||'        =                '||''''||NULL_CHAR||''''
    ||' AND    level_id         = 1 '
    ||' AND    process_flag     = '||G_IN_PROCESS;


      MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,lv_sql_stmt);

    EXECUTE IMMEDIATE lv_sql_stmt
            USING     p_instance_id,
                      p_instance_code,
                      p_batch_id;

    v_sql_stmt := 02; --Product Family

    lv_sql_stmt :=
    'UPDATE '||p_table_name ||' t1'
    ||' SET '||p_level_pk_col
    ||' = (SELECT sr_inventory_item_id '
    ||' FROM msc_system_items t2'
    ||' WHERE t2.sr_instance_id = :p_instance_id'
    ||' AND   t2.item_name      = t1.'||p_level_val_col
    ||' AND   t2.plan_id        = -1 '
    ||' AND   t2.bom_item_type  = 5 '
    ||' AND   rownum = 1 )'
    ||' WHERE  sr_instance_code = :p_instance_code'
    ||' AND    NVL(batch_id,'||NULL_VALUE||') = :p_batch_id'
    ||' AND   NVL(t1.'||p_level_pk_col||','||''''||NULL_CHAR||''''||') '
    ||'        =                '||''''||NULL_CHAR||''''
    ||' AND    level_id         = 3 '
    ||' AND    process_flag     = '||G_IN_PROCESS ;


      MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,lv_sql_stmt);

    EXECUTE IMMEDIATE lv_sql_stmt
            USING     p_instance_id,
                      p_instance_code,
                      p_batch_id;

   v_sql_stmt := 03; --Product Category

    lv_sql_stmt :=
    'UPDATE '||p_table_name ||' t1'
    ||' SET '||p_level_pk_col
    ||' = (SELECT sr_category_id '
    ||' FROM msc_item_categories t2'
    ||' WHERE t2.sr_instance_id = :p_instance_id'
    ||' AND   t2.category_name      = t1.'||p_level_val_col
    ||' AND   t2.category_set_id   = ( select mcs.category_set_id '
    ||'                                from msc_category_sets mcs, msd_setup_parameters msp '
    ||'                                where msp.parameter_name  = ''MSD_CATEGORY_SET_NAME_LEGACY'' '
    ||'                                and   msp.instance_id     = :p_instance_id '
    ||'                                and   msp.parameter_value = mcs.category_set_name ) '
/*  ||' AND   t2.category_set_id   = ( select parameter_value '
    ||'                                from msd_setup_parameters '
    ||'                                where instance_id  = :p_instance_id '
    ||'                                and parameter_name     = ''MSD_CATEGORY_SET_NAME'' )'   */
    ||' AND   rownum = 1 )'
    ||' WHERE  sr_instance_code = :p_instance_code'
    ||' AND    NVL(batch_id,'||NULL_VALUE||') = :p_batch_id'
    ||' AND   NVL(t1.'||p_level_pk_col||','||''''||NULL_CHAR||''''||') '
    ||'        =                '||''''||NULL_CHAR||''''
    ||' AND    level_id         = 2 '
    ||' AND    process_flag     = '||G_IN_PROCESS ;

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,lv_sql_stmt);

    EXECUTE IMMEDIATE lv_sql_stmt
            USING     p_instance_id,
                      p_instance_id,
                      p_instance_code,
                      p_batch_id;

  v_sql_stmt := 04; --Organization

    lv_sql_stmt :=
    'UPDATE '||p_table_name ||' t1'
    ||' SET '||p_level_pk_col
    ||' = (SELECT sr_tp_id '
    ||' FROM msc_trading_partners t2 '
    ||' WHERE t2.sr_instance_id      = :p_instance_id '
    ||' AND   substr(t2.partner_name,instr(t2.partner_name,'':'')+1,length(t2.partner_name)) = t1.'||p_level_val_col
    ||' AND   t2.partner_type        = 3 '
    ||' AND   nvl(t2.company_id,-1)  = -1 '
    ||' AND   rownum = 1 ) '
    ||' WHERE  sr_instance_code = :p_instance_code '
    ||' AND    NVL(batch_id,'||NULL_VALUE||') = :p_batch_id'
    ||' AND   NVL(t1.'||p_level_pk_col||','||''''||NULL_CHAR||''''||') '
    ||'        =                '||''''||NULL_CHAR||''''
    ||' AND    level_id         = 7 '
    ||' AND    process_flag     = '||G_IN_PROCESS ;

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,lv_sql_stmt);

    EXECUTE IMMEDIATE lv_sql_stmt
            USING     p_instance_id,
                      p_instance_code,
                      p_batch_id;

   v_sql_stmt := 05; --Ship To Location

    lv_sql_stmt :=
    'UPDATE '||p_table_name ||' t1'
    ||' SET '||p_level_pk_col
    ||' = (SELECT t2.sr_tp_site_id '
    ||' FROM msc_tp_site_id_lid t2,msc_trading_partner_sites t3,msc_trading_partners t4 '
    ||' WHERE t4.partner_type       = 2 '
    ||' AND   t4.partner_name       = substr(t1.'||p_level_val_col||',1,instr(t1.'||p_level_val_col||','':'')-1) '
    ||' AND   nvl(t4.company_id,-1) = -1 '
    ||' AND   t3.partner_id     = t4.partner_id '
    ||' AND   t3.location       = substr(t1.'||p_level_val_col||',instr(t1.'||p_level_val_col||','':'')+1,length(t1.'||p_level_val_col||')) '
    ||' AND   t3.tp_site_code   = ''SHIP_TO'' '
    ||' AND   t2.tp_site_id     = t3.partner_site_id '
    ||' AND   t2.partner_type   = 2 '
    ||' AND   t2.sr_instance_id = :p_instance_id'
    ||' AND   nvl(t2.sr_company_id,-1) = -1 '
    ||' AND   rownum = 1 )'
    ||' WHERE  sr_instance_code = :p_instance_code'
    ||' AND    NVL(batch_id,'||NULL_VALUE||') = :p_batch_id'
    ||' AND   NVL(t1.'||p_level_pk_col||','||''''||NULL_CHAR||''''||') '
    ||'        =                '||''''||NULL_CHAR||''''
    ||' AND    level_id         = 11 '
    ||' AND    process_flag     = '||G_IN_PROCESS;


      MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,lv_sql_stmt);

    EXECUTE IMMEDIATE lv_sql_stmt
            USING     p_instance_id,
                      p_instance_code,
                      p_batch_id;

    v_sql_stmt := 06; --Customer

    lv_sql_stmt :=
    'UPDATE '||p_table_name ||' t1'
    ||' SET '||p_level_pk_col
    ||' = (SELECT t2.sr_tp_id '
    ||' FROM msc_tp_id_lid t2,msc_trading_partners t3'
    ||' WHERE t2.sr_instance_id        = :p_instance_id'
    ||' AND   t3.partner_name          = t1.'||p_level_val_col
    ||' AND   t3.partner_type          = 2 '
    ||' AND   nvl(t3.company_id,-1)    = -1 '
    ||' AND   t2.partner_type          = 2  '
    ||' AND   t2.tp_id                 = t3.partner_id '
    ||' AND   nvl(t2.sr_company_id,-1) = -1 '
    ||' AND   rownum = 1 )'
    ||' WHERE  sr_instance_code = :p_instance_code'
    ||' AND    NVL(batch_id,'||NULL_VALUE||') = :p_batch_id'
    ||' AND   NVL(t1.'||p_level_pk_col||','||''''||NULL_CHAR||''''||') '
    ||'        =                '||''''||NULL_CHAR||''''
    ||' AND    level_id         = 15 '
    ||' AND    process_flag     = '||G_IN_PROCESS ;



      MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,lv_sql_stmt);

    EXECUTE IMMEDIATE lv_sql_stmt
            USING     p_instance_id,
                      p_instance_code,
                      p_batch_id;

   v_sql_stmt := 07; --Demand Class

    lv_sql_stmt :=
    'UPDATE '||p_table_name ||' t1'
    ||' SET '||p_level_pk_col
    ||' = (SELECT demand_class '
    ||' FROM msc_demand_classes t2'
    ||' WHERE t2.sr_instance_id    = :p_instance_id'
    ||' AND   t2.meaning      = t1.'||p_level_val_col
    ||' AND   rownum = 1 )'
    ||' WHERE  sr_instance_code = :p_instance_code'
    ||' AND    NVL(batch_id,'||NULL_VALUE||') = :p_batch_id'
    ||' AND   NVL(t1.'||p_level_pk_col||','||''''||NULL_CHAR||''''||') '
    ||'        =                '||''''||NULL_CHAR||''''
    ||' AND    level_id         = 34 '
    ||' AND    process_flag     = '||G_IN_PROCESS ;

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,lv_sql_stmt);

    EXECUTE IMMEDIATE lv_sql_stmt
            USING     p_instance_id,
                      p_instance_code,
                      p_batch_id;

   v_sql_stmt := 08; --Zone

    lv_sql_stmt :=
    'UPDATE '||p_table_name ||' t1'
    ||' SET '||p_level_pk_col
    ||' = (SELECT  t2.region_id '
    ||' FROM msc_regions t2'
    ||' WHERE t2.sr_instance_id    = :p_instance_id'
    ||' AND   t2.zone              = t1.'||p_level_val_col
    ||' AND   t2.region_type       = 10'
    ||' AND   rownum = 1 )'
    ||' WHERE  sr_instance_code = :p_instance_code'
    ||' AND    NVL(batch_id,'||NULL_VALUE||') = :p_batch_id'
    ||' AND   NVL(t1.'||p_level_pk_col||','||''''||NULL_CHAR||''''||') '
    ||'        =                '||''''||NULL_CHAR||''''
    ||' AND    level_id         = 42 '
    ||' AND    process_flag     = '||G_IN_PROCESS ;

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,lv_sql_stmt);

    EXECUTE IMMEDIATE lv_sql_stmt
            USING     p_instance_id,
                      p_instance_code,
                      p_batch_id;



    RETURN(lv_status);

  EXCEPTION
    WHEN too_many_rows THEN
      p_error_text := substr('MSC_ST_UTIL.DERIVE_SETUP_SR_LEVEL_PK'||'('
                        ||v_sql_stmt||')'|| SQLERRM, 1, 240);
      return(SQLCODE);

    WHEN OTHERS THEN
      p_error_text := substr('MSC_ST_UTIL.DERIVE_SETUP_SR_LEVEL_PK'||'('
                        ||v_sql_stmt||')'|| SQLERRM, 1, 240);
      return(SQLCODE);

  END DERIVE_SETUP_SR_LEVEL_PK;

/*==========================================================================+
| DESCRIPTION  : This function is called for deriving the resource id's     |
|                based on                                                   |
|                the values in msc_local_id_setup. For the tables other     |
|                than msc_st_resource_requirements,                         |
|                if the derivation fails then the                           |
|                record will be errored out.                                |
|                Severity - 1 - Error                                       |
|                           2 - Warning                                     |
|                           3 - Error if value for item name exists         |
+==========================================================================*/
  FUNCTION DERIVE_RESOURCE_ID
           (p_table_name         VARCHAR2,
            p_resource_col_name      VARCHAR2, --resource code
            p_department_col_name      VARCHAR2, --department code
            p_resource_col_id        VARCHAR2, --resource id
            p_instance_code      VARCHAR2,
            p_error_text OUT     NOCOPY VARCHAR2,
            p_batch_id           NUMBER    DEFAULT NULL_VALUE,
            p_severity           NUMBER    DEFAULT 0,
            p_message_text       VARCHAR2  DEFAULT NULL,
            p_debug              BOOLEAN   DEFAULT FALSE,
            p_row                LONG      DEFAULT NULL,
            p_where_str          VARCHAR2  DEFAULT NULL)
  RETURN NUMBER IS
  lv_sql_stmt          VARCHAR2(5000);
  lv_where_str         VARCHAR2(100);
  lv_status            NUMBER := 0;
  BEGIN
    v_sql_stmt := 10;

    IF v_instance_type = G_INS_OTHER THEN

    lv_sql_stmt :=
    'UPDATE  '|| p_table_name ||' msrr'
    ||' SET  '||p_resource_col_id || '=   (SELECT local_id '
    ||'                 FROM msc_local_id_setup mlis'
    ||'                 WHERE  mlis.char1 = msrr.sr_instance_code'
    ||'                 AND   NVL(mlis.char2,'||''''||NULL_CHAR||''''||') '
    ||'                 =    NVL(msrr.company_name,'||''''||NULL_CHAR||''''||') '
    ||'                 AND    mlis.char3 = msrr.organization_code'
    ||'                 AND    mlis.char4 = msrr.'||p_resource_col_name
    ||'                 AND    mlis.entity_name = ''RESOURCE_ID'''
    ||'                 AND    mlis.instance_id ='||v_instance_id||' )'
    ||' WHERE      msrr.sr_instance_code = :p_instance_code'
    ||' AND        msrr.deleted_flag     = '||SYS_NO
    ||' AND        msrr.process_flag     ='|| G_IN_PROCESS
    ||' AND        msrr.batch_id         = :p_batch_id'
    ||  p_where_str;

    ELSE

      lv_sql_stmt :=
      'update '|| p_table_name ||' msrr'
      ||' set '||p_resource_col_id || '= (select RESOURCE_ID '
      ||'                 from msc_department_resources mdr '
      ||'                 where mdr.ORGANIZATION_ID = msrr.ORGANIZATION_ID and '
      ||'                 mdr.SR_INSTANCE_ID = '||v_instance_id||'  and '
      ||'                 mdr.department_code = msrr.'||p_department_col_name||' and '
      ||'                 mdr.RESOURCE_CODE =  msrr.'||p_resource_col_name||' and mdr.plan_id = -1 and rownum = 1 )'
      ||' WHERE      msrr.sr_instance_code = :p_instance_code'
      ||' AND        msrr.deleted_flag     = '||SYS_NO
      ||' AND        msrr.process_flag     ='|| G_IN_PROCESS
      ||' AND        msrr.batch_id         = :p_batch_id'
      ||  p_where_str;
    END IF;

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,lv_sql_stmt);
    EXECUTE IMMEDIATE lv_sql_stmt
            USING     p_instance_code,
                      p_batch_id;

    IF p_message_text IS NOT NULL and p_severity = 1 THEN
      v_sql_stmt  := 07;
      lv_sql_stmt :=
      'UPDATE '||p_table_name   ||' t1'
      ||' SET   error_text   = '||''''||p_message_text||''''||','
      ||'       process_flag = '||g_error
      ||' WHERE NVL(t1.'||p_resource_col_id||','||NULL_VALUE||') = '||NULL_VALUE
      ||' AND   sr_instance_code       = :p_instance_code'
      ||' AND   NVL(batch_id,'||NULL_VALUE||') = :p_batch_id'
      ||' AND   process_flag           = ' ||G_IN_PROCESS;

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,lv_sql_stmt);
      EXECUTE IMMEDIATE lv_sql_stmt
              USING     p_instance_code,
                        p_batch_id;

    ELSIF p_message_text IS NOT NULL and  p_severity = 2 THEN
      lv_where_str :=
      ' AND NVL('||p_resource_col_id||','||NULL_VALUE||') = '||NULL_VALUE;

      lv_status := LOG_ERROR(p_table_name       => p_table_name,
                             p_instance_code    => p_instance_code,
                             p_row              => p_row,
                             p_severity         => p_severity,
                             p_propagated       => 'N',
                             p_where_str        => lv_where_str,
                             p_message_text     => p_message_text,
                             p_error_text       => p_error_text,
                             p_batch_id         => p_batch_id);

    ELSIF p_message_text IS NOT NULL and  p_severity = 3 THEN
      v_sql_stmt  := 08;
      lv_sql_stmt :=
      'UPDATE '||p_table_name   ||' t1'
      ||' SET   error_text   = '||''''||p_message_text||''''||','
      ||'       process_flag = '||g_error
      ||' WHERE NVL(t1.'||p_resource_col_id||','||NULL_VALUE||') = '||NULL_VALUE
      ||' AND   NVL(t1.'||p_resource_col_name||','||''''||NULL_CHAR||''''||') '
      ||'          <> '||''''||NULL_CHAR||''''
      ||' AND   sr_instance_code       = :p_instance_code'
      ||' AND   NVL(batch_id,'||NULL_VALUE||')= :p_batch_id'
      ||' AND   process_flag           = ' ||G_IN_PROCESS;

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,lv_sql_stmt);
      EXECUTE IMMEDIATE lv_sql_stmt
              USING     p_instance_code,
                        p_batch_id;

    END IF;
    RETURN(lv_status);

  EXCEPTION
    WHEN too_many_rows THEN
      p_error_text := substr('MSC_ST_UTIL.DERIVE_RESOURCE_ID'||'('
                        ||v_sql_stmt||')'|| SQLERRM, 1, 240);
      return(SQLCODE);

    WHEN OTHERS THEN
      p_error_text := substr('MSC_ST_UTIL.DERIVE_RESOURCE_ID'||'('
                        ||v_sql_stmt||')'|| SQLERRM, 1, 240);
      return(SQLCODE);
  END DERIVE_RESOURCE_ID;

/*==========================================================================+
| DESCRIPTION  : This function is called for deriving the departmet id's    |
|                based on                                                   |
|                the values in msc_local_id_setup. For the tables other     |
|                than msc_st_resource_requirements,                         |
|                if the derivation fails then the                           |
|                record will be errored out.                                |
|                Severity - 1 - Error                                       |
|                           2 - Warning                                     |
|                           3 - Error if value for item name exists         |
+==========================================================================*/
  FUNCTION DERIVE_DEPARTMENT_ID
           (p_table_name         VARCHAR2,
            p_resource_col_name      VARCHAR2, --resource code
            p_department_col_name      VARCHAR2, --department code
            p_department_col_id        VARCHAR2, --department id
            p_instance_code      VARCHAR2,
            p_error_text OUT     NOCOPY VARCHAR2,
            p_batch_id           NUMBER    DEFAULT NULL_VALUE,
            p_severity           NUMBER    DEFAULT 0,
            p_message_text       VARCHAR2  DEFAULT NULL,
            p_debug              BOOLEAN   DEFAULT FALSE,
            p_row                LONG      DEFAULT NULL)
  RETURN NUMBER IS
  lv_sql_stmt          VARCHAR2(5000);
  lv_where_str         VARCHAR2(100);
  lv_status            NUMBER := 0;
  BEGIN
    v_sql_stmt := 12;

    IF v_instance_type = G_INS_OTHER THEN

    lv_sql_stmt :=
    'UPDATE  '|| p_table_name ||' msrr'
    ||' SET  '||p_department_col_id || '=   (SELECT local_id '
    ||'                 FROM msc_local_id_setup mlis'
    ||'                 WHERE  mlis.char1 = msrr.sr_instance_code'
    ||'                 AND   NVL(mlis.char2,'||''''||NULL_CHAR||''''||') '
    ||'                 =    NVL(msrr.company_name,'||''''||NULL_CHAR||''''||') '
    ||'                 AND    mlis.char3 = msrr.organization_code'
    ||'                 AND    mlis.char4 = msrr.'||p_department_col_name
    ||'                 AND    mlis.entity_name = ''DEPARTMENT_ID'''
    ||'                 AND    mlis.instance_id ='||v_instance_id||' )'
    ||' WHERE      msrr.sr_instance_code = :p_instance_code'
    ||' AND        msrr.process_flag     ='|| G_IN_PROCESS
    ||' AND        NVL(msrr.'||p_department_col_id||','||NULL_VALUE||') <> -1'
    ||' AND        msrr.batch_id         = :p_batch_id';

    ELSE

      lv_sql_stmt :=
      'update '|| p_table_name ||' msrr'
      ||' set '||p_department_col_id || '= (select department_ID '
      ||'                 from msc_department_resources mdr '
      ||'                 where mdr.ORGANIZATION_ID = msrr.ORGANIZATION_ID and '
      ||'                 mdr.SR_INSTANCE_ID = '||v_instance_id||'  and '
      ||'                 mdr.department_code = msrr.'||p_department_col_name||' and '
      ||'                 mdr.RESOURCE_CODE =  msrr.'||p_resource_col_name||' and mdr.plan_id = -1 and rownum = 1 )'
      ||' WHERE      msrr.sr_instance_code = :p_instance_code'
      ||' AND        msrr.process_flag     ='|| G_IN_PROCESS
      ||' AND        NVL(msrr.'||p_department_col_id||','||NULL_VALUE||') <> -1'
      ||' AND        msrr.batch_id         = :p_batch_id';
    END IF;
      MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,lv_sql_stmt);
    EXECUTE IMMEDIATE lv_sql_stmt
            USING     p_instance_code,
                      p_batch_id;

    IF p_message_text IS NOT NULL and p_severity = 1 THEN
      v_sql_stmt  := 07;
      lv_sql_stmt :=
      'UPDATE '||p_table_name   ||' t1'
      ||' SET   error_text   = '||''''||p_message_text||''''||','
      ||'       process_flag = '||g_error
      ||' WHERE NVL(t1.'||p_department_col_id||','||NULL_VALUE||') = '||NULL_VALUE
      ||' AND   sr_instance_code       = :p_instance_code'
      ||' AND   NVL(batch_id,'||NULL_VALUE||') = :p_batch_id'
      ||' AND   process_flag           = ' ||G_IN_PROCESS;

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,lv_sql_stmt);
      EXECUTE IMMEDIATE lv_sql_stmt
              USING     p_instance_code,
                        p_batch_id;

    ELSIF p_message_text IS NOT NULL and  p_severity = 2 THEN
      lv_where_str :=
      ' AND NVL('||p_department_col_id||','||NULL_VALUE||') = '||NULL_VALUE;

      lv_status := LOG_ERROR(p_table_name       => p_table_name,
                             p_instance_code    => p_instance_code,
                             p_row              => p_row,
                             p_severity         => p_severity,
                             p_propagated       => 'N',
                             p_where_str        => lv_where_str,
                             p_message_text     => p_message_text,
                             p_error_text       => p_error_text,
                             p_batch_id         => p_batch_id);

    ELSIF p_message_text IS NOT NULL and  p_severity = 3 THEN
      v_sql_stmt  := 08;
      lv_sql_stmt :=
      'UPDATE '||p_table_name   ||' t1'
      ||' SET   error_text   = '||''''||p_message_text||''''||','
      ||'       process_flag = '||g_error
      ||' WHERE NVL(t1.'||p_department_col_id||','||NULL_VALUE||') = '||NULL_VALUE
      ||' AND   NVL(t1.'||p_department_col_name||','||''''||NULL_CHAR||''''||') '
      ||'          <> '||''''||NULL_CHAR||''''
      ||' AND   sr_instance_code       = :p_instance_code'
      ||' AND   NVL(batch_id,'||NULL_VALUE||')= :p_batch_id'
      ||' AND   process_flag           = ' ||G_IN_PROCESS;

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,lv_sql_stmt);
      EXECUTE IMMEDIATE lv_sql_stmt
              USING     p_instance_code,
                        p_batch_id;

    END IF;
    RETURN(lv_status);

  EXCEPTION
    WHEN too_many_rows THEN
      p_error_text := substr('MSC_ST_UTIL.DERIVE_DEPARTMENT_ID'||'('
                        ||v_sql_stmt||')'|| SQLERRM, 1, 240);
      return(SQLCODE);

    WHEN OTHERS THEN
      p_error_text := substr('MSC_ST_UTIL.DERIVE_DEPARTMENT_ID'||'('
                        ||v_sql_stmt||')'|| SQLERRM, 1, 240);
      return(SQLCODE);
  END DERIVE_DEPARTMENT_ID;

/*==========================================================================+
| DESCRIPTION  : This function is called for deriving the                   |
|                operatin sequence id's                                     |
|                based on                                                   |
|                the values in msc_local_id_setup. For the tables other     |
|                than msc_st_resource_requirements,                         |
|                if the derivation fails then the                           |
|                record will be errored out.                                |
|                Severity - 1 - Error                                       |
|                           2 - Warning                                     |
|                           3 - Error if value for item name exists         |
+==========================================================================*/
  FUNCTION DERIVE_OPERATION_SEQUENCE_ID
           (p_table_name             VARCHAR2,
            p_operation_seq_num     VARCHAR2, --OPERATION_SEQ_NUM
            p_routing_col_name      VARCHAR2, --ROUTING_NAME
            p_sequence_col_id        VARCHAR2, --OPERATION_SEQUENCE_ID
            p_op_effectivity_date    VARCHAR2, --operation_effectivity_date
            p_operation_seq_code      VARCHAR2, --operation_seq_code
            p_routing_sequence_id    VARCHAR2, --routing_sequence_id
            p_instance_code          VARCHAR2,
            p_error_text OUT         NOCOPY VARCHAR2,
            p_batch_id               NUMBER    DEFAULT NULL_VALUE,
            p_severity               NUMBER    DEFAULT 0,
            p_message_text           VARCHAR2  DEFAULT NULL,
            p_debug                  BOOLEAN   DEFAULT FALSE,
            p_row                    LONG      DEFAULT NULL)
  RETURN NUMBER IS
  lv_sql_stmt          VARCHAR2(5000);
  lv_where_str         VARCHAR2(100);
  lv_status            NUMBER := 0;
  BEGIN

    IF v_instance_type <> G_INS_OTHER THEN
      v_sql_stmt := 15;
      lv_sql_Stmt :=
      'update '||p_table_name||' msrr'
      ||' set ' ||p_operation_seq_num||' = to_number(decode(length(rtrim('||p_operation_seq_code||',''0123456789'')),'
      ||'                   NULL,'||p_operation_seq_code||',''1'')),'
      ||p_sequence_col_id||' = (select operation_sequence_id '
      ||'      from msc_routing_operations mro '
      ||'      where mro.routing_sequence_id = msrr.'||p_routing_sequence_id||' and '
      ||'      mro.effectivity_date = msrr.'||p_op_effectivity_date||' and '
      ||'      mro.operation_seq_num = to_number(decode(length(rtrim(msrr.'||p_operation_seq_code||',''0123456789'')),'
      ||'                   NULL,msrr.'||p_operation_seq_code||',''1'')) and'
      ||'      mro.SR_INSTANCE_ID = '||v_instance_id ||' and mro.plan_id = -1 and mro.operation_type = 1)'
      ||'  WHERE      sr_instance_code = :p_instance_code'
      ||'  AND        process_flag     ='||G_IN_PROCESS
      ||'  AND        batch_id         = :p_batch_id'
      ||' AND msrr.'||p_sequence_col_id||' IS NULL';

   ELSE

    v_sql_stmt := 16;
    lv_sql_Stmt :=
    'UPDATE  '||p_table_name||' msrr'
    ||' SET  '||p_sequence_col_id||'=  (SELECT local_id'
    ||'         FROM msc_local_id_setup mlis'
    ||'         WHERE  mlis.char1 = msrr.sr_instance_code'
    ||'         AND     NVL(mlis.char2,'||''''||NULL_CHAR||''''||') '
    ||'          =    NVL(msrr.company_name,'||''''||NULL_CHAR||''''||') '
    ||'         AND    mlis.char3 = msrr.organization_code'
    ||'         AND    mlis.char4 = msrr.'||p_routing_col_name
    ||'         AND    mlis.char5 = msrr.'||p_operation_seq_code
    ||'         AND   NVL(mlis.char6,'||''''||NULL_CHAR||''''||') '
    ||'           =   NVL(msrr.alternate_routing_designator,'||''''||NULL_CHAR||''''||')'
    ||'         AND    mlis.date1 = msrr.'||p_op_effectivity_date
    ||'         AND    mlis.entity_name = ''OPERATION_SEQUENCE_ID'' '
    ||'         AND    mlis.instance_id = '||v_instance_id||')'
    ||'  WHERE      sr_instance_code = :p_instance_code'
    ||'  AND        process_flag     ='||G_IN_PROCESS
    ||'  AND        batch_id         = :lp_batch_id';

  END IF;

MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,lv_sql_stmt);


   EXECUTE IMMEDIATE lv_sql_stmt USING p_instance_code,p_batch_id;


    IF p_message_text IS NOT NULL and p_severity = 1 THEN
      v_sql_stmt  := 07;
      lv_sql_stmt :=
      'UPDATE '||p_table_name   ||' t1'
      ||' SET   error_text   = '||''''||p_message_text||''''||','
      ||'       process_flag = '||g_error
      ||' WHERE NVL(t1.'||p_sequence_col_id||','||NULL_VALUE||') = '||NULL_VALUE
      ||' AND   sr_instance_code       = :p_instance_code'
      ||' AND   NVL(batch_id,'||NULL_VALUE||') = :p_batch_id'
      ||' AND   process_flag           = ' ||G_IN_PROCESS;

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,lv_sql_stmt);
      EXECUTE IMMEDIATE lv_sql_stmt
              USING     p_instance_code,
                        p_batch_id;

    ELSIF p_message_text IS NOT NULL and  p_severity = 2 THEN
      lv_where_str :=
      ' AND NVL('||p_sequence_col_id||','||NULL_VALUE||') = '||NULL_VALUE;

      lv_status := LOG_ERROR(p_table_name       => p_table_name,
                             p_instance_code    => p_instance_code,
                             p_row              => p_row,
                             p_severity         => p_severity,
                             p_propagated       => 'N',
                             p_where_str        => lv_where_str,
                             p_message_text     => p_message_text,
                             p_error_text       => p_error_text,
                             p_batch_id         => p_batch_id);

    ELSIF p_message_text IS NOT NULL and  p_severity = 3 THEN
      v_sql_stmt  := 08;
      lv_sql_stmt :=
      'UPDATE '||p_table_name   ||' t1'
      ||' SET   error_text   = '||''''||p_message_text||''''||','
      ||'       process_flag = '||g_error
      ||' WHERE NVL(t1.'||p_sequence_col_id||','||NULL_VALUE||') = '||NULL_VALUE
      ||' AND   NVL(t1.'||p_operation_seq_code||','||''''||NULL_CHAR||''''||') '
      ||'          <> '||''''||NULL_CHAR||''''
      ||' AND   sr_instance_code       = :p_instance_code'
      ||' AND   NVL(batch_id,'||NULL_VALUE||')= :p_batch_id'
      ||' AND   process_flag           = ' ||G_IN_PROCESS;

      MSC_UTIL.LOG_MSG(MSC_UTIL.G_LVL_DEBUG_1,lv_sql_stmt);
      EXECUTE IMMEDIATE lv_sql_stmt
              USING     p_instance_code,
                        p_batch_id;

    END IF;
    RETURN(lv_status);

  EXCEPTION
    WHEN too_many_rows THEN
      p_error_text := substr('MSC_ST_UTIL.DERIVE_OPERATION_SEQUENCE_ID'||'('
                        ||v_sql_stmt||')'|| SQLERRM, 1, 240);
      return(SQLCODE);

    WHEN OTHERS THEN
      p_error_text := substr('MSC_ST_UTIL.DERIVE_OPERATION_SEQUENCE_ID'||'('
                        ||v_sql_stmt||')'|| SQLERRM, 1, 240);
      return(SQLCODE);
  END DERIVE_OPERATION_SEQUENCE_ID;

  /*S_OP */
  FUNCTION CHECK_DP_ENABLED_FLAG
  (
   p_MRP_PLANNING_CODE NUMBER,
   p_PICK_COMPONENT_FLAG VARCHAR2,
   p_MSD_PLANING_PERCENTAGE NUMBER,
   p_ATO_FORECAST_CONTROL NUMBER
  )
  RETURN NUMBER
  IS
  lv_dp_enabled_flag NUMBER ;
  BEGIN

  	           If  ((nvl(p_MRP_PLANNING_CODE,0)<> 6 OR nvl(p_PICK_COMPONENT_FLAG,'N') ='Y') AND (nvl(p_MSD_PLANING_PERCENTAGE,0)= 4 OR  nvl(p_ATO_FORECAST_CONTROL,0) <> 3))
  						Then
	 						lv_dp_enabled_flag:=1;
							Else
              lv_dp_enabled_flag:=2;
							End IF;

	   return lv_dp_enabled_flag;
  END CHECK_DP_ENABLED_FLAG;
  /*S_OP */

  FUNCTION get_stream_name (x varchar2) return varchar2
  IS
		stream_name varchar2(100);
	begin
		select decode(upper(x),'TOTAL_BACKLOG','MSD_TOTAL_BACKLOG','PASTDUE_BACKLOG','MSD_PASTDUE_BACKLOG'
		,'PRODUCTION_PLAN','MSD_PRODUCTION_PLAN','ACTUAL_PRODUCTION','MSD_ACTUAL_PRODUCTION','ONHAND_INVENTORY','MSD_ONHAND_INVENTORY'
		,'SUPPLY_PLANS','MSD_SUPPLY_PLANS','CONSTRAINED_FORECAST','MSD_CONSTRAINED_FORECAST','SAFETY_STOCKS','MSD_SAFETY_STOCKS'
		,'AVAIL_RESOURCE_CAPACITY','MSD_AVAIL_RESOURCE_CAPACITY','AVAIL_SUPPLIER_CAPACITY','MSD_AVAIL_SUPPLIER_CAPACITY'
		,'WORK_IN_PROCESS','MSD_WORK_IN_PROCESS',x) into stream_name from dual;

		return stream_name;
	end get_stream_name;


END MSC_ST_UTIL;

/
