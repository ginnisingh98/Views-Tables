--------------------------------------------------------
--  DDL for Package MSC_ST_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_ST_UTIL" AUTHID CURRENT_USER AS
/* $Header: MSCSUTLS.pls 120.5.12010000.3 2010/03/19 13:10:29 vsiyer ship $ */
  -- ================== CONSTANTS =====================
  SYS_YES                      CONSTANT NUMBER := 1;
  SYS_NO                       CONSTANT NUMBER := 2;
  v_instance_type              NUMBER;
  v_instance_id                NUMBER;

  G_NEW                    CONSTANT NUMBER := 1;
  G_IN_PROCESS             CONSTANT NUMBER := 2;
  G_ERROR                  CONSTANT NUMBER := 3;
  G_PROPAGATION            CONSTANT NUMBER := 4;
  G_VALID                  CONSTANT NUMBER := 5;
  G_WARNING                CONSTANT NUMBER := 2;
  G_SEV_ERROR              CONSTANT NUMBER := 1;
  G_SCE                    CONSTANT NUMBER := 5;
  G_SEV3_ERROR             CONSTANT NUMBER := 3;
  G_MULTI_TIER_ENABLE      CONSTANT BOOLEAN:= TRUE;
  -- multi tier is enabled for bug 2939695

  G_INS_DISCRETE                          CONSTANT NUMBER := 1;
  G_INS_PROCESS                           CONSTANT NUMBER := 2;
  G_INS_OTHER                             CONSTANT NUMBER := 3;
  G_INS_MIXED                             CONSTANT NUMBER := 4;

  G_VENDOR                        CONSTANT NUMBER :=  1;
  G_CUSTOMER                      CONSTANT NUMBER :=  2;
  G_ORGANIZATION                  CONSTANT NUMBER :=  3;
  G_CARRIER                       CONSTANT NUMBER :=  4;


  NULL_DATE             CONSTANT DATE:=   SYSDATE-36500;
  NULL_VALUE            CONSTANT NUMBER:= -23453;   -- null value for positive number
  NULL_CHAR             CONSTANT VARCHAR2(6):= '-23453';

  --  =========== Procedures and fUNCTIONS=================
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
  RETURN NUMBER;

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
  RETURN NUMBER;

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
  RETURN NUMBER;

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
            p_where_str            VARCHAR2 DEFAULT NULL,
            p_company_name_col     BOOLEAN   DEFAULT TRUE )
  RETURN NUMBER;

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
            p_where_str             VARCHAR2  DEFAULT NULL)
  RETURN NUMBER;

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
  RETURN NUMBER;

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
  RETURN NUMBER;

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
  RETURN NUMBER ;

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
  RETURN NUMBER;

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
  RETURN NUMBER;

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
  RETURN NUMBER;

  FUNCTION SET_PROCESS_FLAG
           (p_table_name       VARCHAR2,
            p_instance_id      NUMBER,
            p_instance_code    VARCHAR2,
            p_process_flag     NUMBER,
            p_error_text OUT   NOCOPY VARCHAR2,
            p_where_str        VARCHAR2  DEFAULT NULL,
            p_debug            BOOLEAN   DEFAULT FALSE,
            p_batch_id         NUMBER   DEFAULT NULL_VALUE,
            p_instance_id_col  VARCHAR2 DEFAULT 'SR_INSTANCE_ID')
  RETURN NUMBER;


  --  =========== DP Procedures and fUNCTIONS=================

  FUNCTION DERIVE_LEVEL_ID
           (p_table_name          VARCHAR2,
            p_level_name_col      VARCHAR2, --level_name
            p_level_id_col        VARCHAR2, --level_id
            p_severity            NUMBER    DEFAULT G_SEV_ERROR,
            p_message_text        VARCHAR2  DEFAULT NULL,
            p_instance_code       VARCHAR2,
            p_batch_id            NUMBER    DEFAULT NULL_VALUE,
            p_error_text  OUT     NOCOPY VARCHAR2)

  RETURN NUMBER;

  FUNCTION DERIVE_SR_LEVEL_PK
           (p_table_name          VARCHAR2,
            p_level_val_col      VARCHAR2, --level value col name
            p_level_pk_col        VARCHAR2, --level_pk column name
            p_level_id_col        VARCHAR2, --level_id col name
            p_instance_code       VARCHAR2,
            p_message_text        VARCHAR2  DEFAULT NULL,
            p_batch_id            NUMBER    DEFAULT NULL_VALUE,
            p_error_text  OUT     NOCOPY VARCHAR2)
  RETURN NUMBER;

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
  RETURN NUMBER;


  FUNCTION DERIVE_LEVEL_PK
           (p_table_name          VARCHAR2,
            p_level_val_col       VARCHAR2, --level value col name
            p_level_name_col      VARCHAR2, --level_name column name
            p_level_pk_col        VARCHAR2, --level_val col name
            p_severity            VARCHAR2 DEFAULT G_SEV3_ERROR,
            p_instance_code       VARCHAR2,
            p_instance_id         NUMBER,
            p_message_text        VARCHAR2,
            p_batch_id            NUMBER    DEFAULT NULL_VALUE,
            p_error_text  OUT     NOCOPY VARCHAR2)
  RETURN NUMBER;

  PROCEDURE LOG_MESSAGE
            (p_error_text IN  VARCHAR2);

  FUNCTION  GET_INSTANCE_CODE
            (p_trading_partner_id number)
  RETURN VARCHAR2;

  PROCEDURE retn_delete_flag
           (p_syncind       IN   VARCHAR2,
            p_return        OUT  NOCOPY NUMBER);

  PROCEDURE retn_schedule_id
           (p_schedule_type IN   VARCHAR2,
            p_schid         OUT  NOCOPY NUMBER);

  PROCEDURE Explode_Composite_Dates
           (errbuf                  OUT NOCOPY VARCHAR2,
            retcode                 OUT NOCOPY VARCHAR2,
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
            p_week_end_date         IN  DATE);


  FUNCTION ret_code
           (p_entity_name   IN   VARCHAR2,
            p_id            IN   NUMBER)
  RETURN VARCHAR2;

  FUNCTION ret_org_code
           (p_sr_instance_id    IN NUMBER,
            p_organization_id   IN NUMBER)
  RETURN VARCHAR2;

  FUNCTION ret_partner_name
           (p_partner_id        IN NUMBER)
  RETURN VARCHAR2;

  FUNCTION ret_partner_name
           (p_instance_id    IN    NUMBER,
            p_sr_tp_id       IN    NUMBER,
            p_partner_type   IN    NUMBER)
  RETURN VARCHAR2;

  FUNCTION ret_partner_site
           (p_partner_site_id  IN   NUMBER)
  RETURN VARCHAR2;

  FUNCTION ret_partner_site
           (p_instance_id      IN   NUMBER,
            p_sr_tp_site_id    IN   NUMBER,
            p_partner_type     IN   NUMBER)
  RETURN VARCHAR2;

  FUNCTION ret_desig
           (p_designator_id    IN   NUMBER)
  RETURN VARCHAR2;

  FUNCTION ret_sr_instance_code
           (p_sr_instance_id   IN   NUMBER)
  RETURN VARCHAR2;

  FUNCTION ret_project_number
           (p_project_id       IN     NUMBER ,
            p_sr_instance_id   IN     NUMBER ,
            p_organization_id  IN     NUMBER,
            p_plan_id          IN     NUMBER)
  RETURN VARCHAR2;

  FUNCTION ret_task_number
           (p_project_id        IN     NUMBER,
            p_task_id           IN     NUMBER,
            p_sr_instance_id    IN     NUMBER,
            p_organization_id   IN     NUMBER,
            p_plan_id           IN     NUMBER)
  RETURN VARCHAR2;

  FUNCTION ret_wip_entity_name
           (p_wip_entity_id       IN    NUMBER,
            p_sr_instance_id      IN    NUMBER,
            p_organization_id     IN    NUMBER,
            p_plan_id             IN    NUMBER)
  RETURN VARCHAR2;

  FUNCTION ret_item_name
           (p_item_id          IN      NUMBER,
            p_sr_instance_id   IN      NUMBER,
            p_organization_id  IN      NUMBER,
            p_plan_id          IN      NUMBER)
  RETURN VARCHAR2;

  PROCEDURE retn_yes_no_value
           (p_yes_no_code  IN   VARCHAR2,
            p_yes_no_value OUT  NOCOPY NUMBER);

  -- For MSC_GROUPS and MSC_GROUP_COMPANIES aeroexhange
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
  RETURN NUMBER;

  -- For evaluating the user logged in for Operator resp.
  FUNCTION IS_OPERATOR (p_user_id     NUMBER)
  RETURN BOOLEAN ;

  -- Moved the function from pre-processor.
  FUNCTION GET_MY_COMPANY
  RETURN VARCHAR2;

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
  RETURN NUMBER;


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
  RETURN NUMBER ;

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
  RETURN NUMBER ;

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
  RETURN NUMBER ;

  /*S_OP */
  FUNCTION CHECK_DP_ENABLED_FLAG
  (
   p_MRP_PLANNING_CODE NUMBER,
   p_PICK_COMPONENT_FLAG VARCHAR2,
   p_MSD_PLANING_PERCENTAGE NUMBER,
   p_ATO_FORECAST_CONTROL NUMBER
  )
  RETURN NUMBER ;
  /*S_OP */

  FUNCTION get_stream_name (x varchar2) return varchar2;

END MSC_ST_UTIL;

/
