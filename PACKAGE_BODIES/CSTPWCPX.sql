--------------------------------------------------------
--  DDL for Package Body CSTPWCPX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSTPWCPX" AS
/* $Header: CSTPCPXB.pls 120.0 2005/05/25 05:13:56 appldev noship $ */

FUNCTION CMLCPX (
    i_group_id          IN    NUMBER,
    i_org_id            IN    NUMBER,
    i_transaction_type  IN    NUMBER,
    i_user_id           IN    NUMBER,
    i_login_id          IN    NUMBER,
    i_prg_appl_id       IN    NUMBER,
    i_prg_id            IN    NUMBER,
    i_req_id            IN    NUMBER,
    err_buf             OUT NOCOPY   VARCHAR2)
RETURN INTEGER
IS

    where_num          NUMBER;
    l_cost_type_id     NUMBER;

BEGIN

    err_buf   := ' ';

    /*---------------------------------------------------------------+
    | Get the Cost Type associated with the organization             |
    +----------------------------------------------------------------*/
    where_num := 50;

    SELECT DECODE(PRIMARY_COST_METHOD, 1, 1,
                 NVL(AVG_RATES_COST_TYPE_ID,-1))
    INTO   l_cost_type_id
    FROM   MTL_PARAMETERS
    WHERE  ORGANIZATION_ID = i_org_id;

    /*--------------------------------------------------------------+
    | Copy rows from wip_cost_txn_interface to wip_transactions.    |
    | Copy NULL transaction quantity for IPV transfer transactions. |
    | Copy the values charge_dept_id and instance_id for EAM support|
    +---------------------------------------------------------------*/
    where_num := 100;
    INSERT INTO WIP_TRANSACTIONS
        (TRANSACTION_ID,                LAST_UPDATE_DATE,
        LAST_UPDATED_BY,                CREATION_DATE,
        CREATED_BY,                     LAST_UPDATE_LOGIN,
        ORGANIZATION_ID,                WIP_ENTITY_ID,
        ACCT_PERIOD_ID,                 DEPARTMENT_ID,
        TRANSACTION_TYPE,               TRANSACTION_DATE,
        LINE_ID,                        SOURCE_CODE,
        SOURCE_LINE_ID,                 OPERATION_SEQ_NUM,
        RESOURCE_SEQ_NUM,               EMPLOYEE_ID,
        RESOURCE_ID,                    AUTOCHARGE_TYPE,
        STANDARD_RATE_FLAG,             USAGE_RATE_OR_AMOUNT,
        BASIS_TYPE,                     TRANSACTION_QUANTITY,
        TRANSACTION_UOM,                PRIMARY_QUANTITY,
        PRIMARY_UOM,                    ACTUAL_RESOURCE_RATE,
        STANDARD_RESOURCE_RATE,         CURRENCY_CODE,
	CURRENCY_CONVERSION_DATE,	CURRENCY_CONVERSION_TYPE,
        CURRENCY_CONVERSION_RATE, 	CURRENCY_ACTUAL_RESOURCE_RATE,
	ACTIVITY_ID,			REASON_ID,
        REFERENCE,			MOVE_TRANSACTION_ID,
        PO_HEADER_ID,	 		PO_LINE_ID,
	RCV_TRANSACTION_ID,		PRIMARY_ITEM_ID,
        ATTRIBUTE_CATEGORY,
        ATTRIBUTE1,ATTRIBUTE2,ATTRIBUTE3,ATTRIBUTE4,
        ATTRIBUTE5,ATTRIBUTE6,ATTRIBUTE7,ATTRIBUTE8,
        ATTRIBUTE9,ATTRIBUTE10,ATTRIBUTE11,ATTRIBUTE12,
        ATTRIBUTE13,ATTRIBUTE14,ATTRIBUTE15,
        REQUEST_ID,PROGRAM_APPLICATION_ID,PROGRAM_ID,PROGRAM_UPDATE_DATE,
        GROUP_ID,
        PROJECT_ID,			TASK_ID,
        PM_COST_COLLECTED,		COMPLETION_TRANSACTION_ID,
        CHARGE_DEPARTMENT_ID,		INSTANCE_ID)
    SELECT
        wcti.TRANSACTION_ID,             SYSDATE,
        i_user_id,                        wcti.CREATION_DATE,
        wcti.CREATED_BY,                 i_login_id,
        wcti.ORGANIZATION_ID,            wcti.WIP_ENTITY_ID,
        wcti.ACCT_PERIOD_ID,             wcti.DEPARTMENT_ID,
        wcti.TRANSACTION_TYPE,           wcti.TRANSACTION_DATE,
        wcti.LINE_ID,                    wcti.SOURCE_CODE,
        wcti.SOURCE_LINE_ID,             wcti.OPERATION_SEQ_NUM,
        wcti.RESOURCE_SEQ_NUM,           wcti.EMPLOYEE_ID,
        wcti.RESOURCE_ID,                wcti.AUTOCHARGE_TYPE,
        wcti.STANDARD_RATE_FLAG,         wcti.USAGE_RATE_OR_AMOUNT,
        wcti.BASIS_TYPE,
        DECODE(wcti.SOURCE_CODE, 'IPV', NULL,
               wcti.TRANSACTION_QUANTITY ),
        wcti.TRANSACTION_UOM,
        DECODE(wcti.SOURCE_CODE, 'IPV', NULL,
               wcti.PRIMARY_QUANTITY ),
        wcti.PRIMARY_UOM,                wcti.ACTUAL_RESOURCE_RATE,
        decode(i_transaction_type,
          1, decode(br.functional_currency_flag,
                1, 1,
                nvl(crc.resource_rate,0)),
          NULL),
                                         wcti.CURRENCY_CODE,
        wcti.CURRENCY_CONVERSION_DATE,   wcti.CURRENCY_CONVERSION_TYPE,
        wcti.CURRENCY_CONVERSION_RATE,   wcti.CURRENCY_ACTUAL_RESOURCE_RATE,
        wcti.ACTIVITY_ID,                wcti.REASON_ID,
        wcti.REFERENCE,                  wcti.MOVE_TRANSACTION_ID,
        wcti.PO_HEADER_ID,               wcti.PO_LINE_ID,
        wcti.RCV_TRANSACTION_ID,         wcti.PRIMARY_ITEM_ID,
        wcti.ATTRIBUTE_CATEGORY,
        wcti.ATTRIBUTE1,wcti.ATTRIBUTE2, wcti.ATTRIBUTE3,wcti.ATTRIBUTE4,
        wcti.ATTRIBUTE5, wcti.ATTRIBUTE6, wcti.ATTRIBUTE7,wcti.ATTRIBUTE8,
        wcti.ATTRIBUTE9,wcti.ATTRIBUTE10, wcti.ATTRIBUTE11,wcti.ATTRIBUTE12,
        wcti.ATTRIBUTE13,wcti.ATTRIBUTE14,wcti.ATTRIBUTE15,
        DECODE(i_req_id, -1, NULL, i_req_id),
        DECODE(i_prg_appl_id, -1, NULL, i_prg_appl_id),
        DECODE(i_prg_id, NULL, i_prg_id),
        DECODE(i_req_id, -1, NULL, SYSDATE),
        wcti.GROUP_ID,
        wcti.PROJECT_ID,                 wcti.TASK_ID,
        'N',                             wcti.COMPLETION_TRANSACTION_ID,
        wcti.CHARGE_DEPARTMENT_ID,       wcti.INSTANCE_ID
    FROM wip_cost_txn_interface wcti,
         bom_resources br,
         cst_resource_costs crc
    WHERE wcti.group_id = i_group_id
    AND   wcti.process_status = 2
    AND   (  (i_transaction_type = 1
             AND wcti.transaction_type IN (1,3))
           OR
             (i_transaction_type <> 1
             AND wcti.transaction_type = i_transaction_type)
          )
    AND   wcti.resource_id = br.resource_id (+)
    AND   wcti.resource_id = crc.resource_id (+)
    AND   crc.cost_type_id (+) = l_cost_type_id;

    /*---------------------------------------------------------------+
    | Delete rows from wip_cost_txn_interface
    +---------------------------------------------------------------*/
    where_num := 200;
    DELETE FROM wip_cost_txn_interface
    WHERE group_id = i_group_id
    AND   (  (i_transaction_type = 1
              AND transaction_type IN (1,3))
           OR
             (i_transaction_type <> 1
              AND transaction_type = i_transaction_type)
          )
    AND   process_status = 2;

    RETURN(0);


EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        err_buf := 'CSTPWCPX:' || to_char(where_num) || substr(SQLERRM,1,150);
        RETURN(SQLCODE);

END CMLCPX;

END CSTPWCPX; /* end package body */

/
