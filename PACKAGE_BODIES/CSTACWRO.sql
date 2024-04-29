--------------------------------------------------------
--  DDL for Package Body CSTACWRO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSTACWRO" AS
/* $Header: CSTPACOB.pls 115.8 2004/07/19 22:09:59 rzhu ship $ */

FUNCTION overhead (
           I_OVHD_TYPE                  IN      NUMBER,
           I_COST_TYPE_ID               IN      NUMBER,
           I_ORG_ID                     IN      NUMBER,
	   I_GROUP_ID			IN	NUMBER,
           ERR_NUM                      OUT NOCOPY     NUMBER,
           ERR_CODE                     OUT NOCOPY     VARCHAR2,
           ERR_MSG                      OUT NOCOPY     VARCHAR2)
RETURN integer
is

	   stmt_num			NUMBER;
	   wsm_enabled_org		NUMBER;

 BEGIN

	SELECT decode(wsm_enabled_flag,'Y',1,0)
	INTO wsm_enabled_org
	FROM mtl_parameters
	WHERE organization_id = i_org_id;


	/*----------------------------------------------------+
	* This can be called by the functions that earn the   +
	* resource based and dept based ovhd costs. The fun-  +
	* ction that costs the res based ovhds calls this pro-+
	* cedure with an ovhd_type == 1 and the Move based    +
	* ovhd routine calls this with an ovhd_type == 2. So  +
	* branch accordingly ...			      +
	*-----------------------------------------------------*/

	IF (I_OVHD_TYPE = 1) THEN


	/**************************************************
	* Insert any rows for new  Res based ovhd's ...   *
	* 1. We do not collect costs for schedules -- so  *
	*    check that the sch_id is NULL;		  *
	* 2. If an old ovhd exists but with a new basis,  *
	*    we maintain the old row as is, and also cre- *
	*    ate a new row with the new basis.		  *
	**************************************************/

	stmt_num := 10;

	INSERT INTO WIP_OPERATION_OVERHEADS
	(WIP_ENTITY_ID,
	 OPERATION_SEQ_NUM,
	 RESOURCE_SEQ_NUM,
	 ORGANIZATION_ID,
	 OVERHEAD_ID,
	 BASIS_TYPE,
	 APPLIED_OVHD_UNITS,
	 APPLIED_OVHD_VALUE,
	 RELIEVED_OVHD_COMPLETION_UNITS,
	 RELIEVED_OVHD_SCRAP_UNITS,
	 RELIEVED_OVHD_COMPLETION_VALUE,
	 RELIEVED_OVHD_SCRAP_VALUE,
	 TEMP_RELIEVED_VALUE,
	 LAST_UPDATED_BY,
	 CREATION_DATE,
	 CREATED_BY,
	 LAST_UPDATE_LOGIN,
	 REQUEST_ID,
	 PROGRAM_APPLICATION_ID,
	 PROGRAM_ID,
	 PROGRAM_UPDATE_DATE,
	 LAST_UPDATE_DATE)
	SELECT
	 WCTI.WIP_ENTITY_ID,
	 WCTI.OPERATION_SEQ_NUM,
	 WCTI.RESOURCE_SEQ_NUM,
	 WCTI.ORGANIZATION_ID,
	 WTA.RESOURCE_ID,
	 WTA.BASIS_TYPE,
	 0,
	 0,
	 0,
	 0,
	 0,
	 0,
	 0,
	 -1,
	 SYSDATE,
	 -1,
	 -1,
	 -1,
	 -1,
	 -1,
	 SYSDATE,
	 SYSDATE
	FROM
	WIP_TRANSACTION_ACCOUNTS WTA,
	WIP_COST_TXN_INTERFACE	WCTI,
	WIP_ENTITIES WE
	WHERE
	WCTI.WIP_ENTITY_ID		=	WE.WIP_ENTITY_ID	AND
	WE.ENTITY_TYPE			<>	4			AND
	WE.ENTITY_TYPE  		=       DECODE(wsm_enabled_org, 1, 5,WE.ENTITY_TYPE) AND
	WCTI.TRANSACTION_ID		=	WTA.TRANSACTION_ID	AND
	WCTI.WIP_ENTITY_ID		=	WTA.WIP_ENTITY_ID	AND
	WCTI.RESOURCE_ID		=	WTA.BASIS_RESOURCE_ID	AND
	WCTI.TRANSACTION_TYPE		IN	(1,3)			AND
	WTA.BASIS_TYPE			IN	(3,4)			AND
	WTA.ACCOUNTING_LINE_TYPE	=	7			AND
	WCTI.GROUP_ID			=	I_GROUP_ID		AND
	WCTI.PROCESS_STATUS		= 	2			AND
	WTA.REPETITIVE_SCHEDULE_ID	IS	NULL			AND
	WTA.COST_ELEMENT_ID		= 	5			AND
	NOT EXISTS
	(SELECT 'X'
	 FROM
	 WIP_OPERATION_OVERHEADS W2
	 WHERE
	 W2.WIP_ENTITY_ID		=	WCTI.WIP_ENTITY_ID	AND
	 W2.ORGANIZATION_ID		=	WCTI.ORGANIZATION_ID	AND
	 W2.OPERATION_SEQ_NUM		=	WCTI.OPERATION_SEQ_NUM	AND
	 W2.RESOURCE_SEQ_NUM		=	WCTI.RESOURCE_SEQ_NUM	AND
	 W2.OVERHEAD_ID			=	WTA.RESOURCE_ID		AND
	 W2.BASIS_TYPE			=	WTA.BASIS_TYPE)
        GROUP BY
         WCTI.WIP_ENTITY_ID,WCTI.ORGANIZATION_ID,WCTI.OPERATION_SEQ_NUM,
         WCTI.RESOURCE_SEQ_NUM,WTA.RESOURCE_ID,WTA.BASIS_TYPE;



	/***************************************************
	* Update any Res based ovhds that may exist ...	   *
	* We do not collect any costs related to overheads *
	* and so we explicitly check for schedule_id = NULL*
	* Besides, if we had to take schedules into acct   *
	* we need to sum base_transaction_value from wta   *
	* since we could have allocations across multiple  *
	* schedules ...					   *
	***************************************************/

	stmt_num := 30;

	UPDATE WIP_OPERATION_OVERHEADS W1
	SET
	 (APPLIED_OVHD_UNITS,
	  APPLIED_OVHD_VALUE) =
	(SELECT
	  nvl(w1.applied_ovhd_units,0) +
	  nvl(sum(wta.primary_quantity),0),
	  nvl(w1.applied_ovhd_value,0) +
	  nvl(sum(wta.base_transaction_value),0)
	FROM
	WIP_TRANSACTION_ACCOUNTS WTA,
	WIP_COST_TXN_INTERFACE WCTI
	WHERE
	W1.WIP_ENTITY_ID 	=	WCTI.WIP_ENTITY_ID	AND
	W1.OPERATION_SEQ_NUM	=	WCTI.OPERATION_SEQ_NUM	AND
	W1.ORGANIZATION_ID	=	WCTI.ORGANIZATION_ID	AND
	W1.RESOURCE_SEQ_NUM	=	WCTI.RESOURCE_SEQ_NUM	AND
	W1.OVERHEAD_ID		=	WTA.RESOURCE_ID		AND
	W1.BASIS_TYPE		=	WTA.BASIS_TYPE		AND
	WCTI.TRANSACTION_ID	=	WTA.TRANSACTION_ID	AND
	WCTI.RESOURCE_ID	=	WTA.BASIS_RESOURCE_ID	AND
	WCTI.TRANSACTION_TYPE 	IN	(1,3)			AND
	WTA.BASIS_TYPE		IN	(3,4)			AND
	WTA.ACCOUNTING_LINE_TYPE=	7			AND
	WCTI.GROUP_ID		=	i_group_id		AND
	WCTI.PROCESS_STATUS	= 	2			AND
	WTA.REPETITIVE_SCHEDULE_ID	IS NULL			AND
	WTA.COST_ELEMENT_ID	=	5			AND
	EXISTS
	(SELECT 'X'
	 FROM
	 WIP_OPERATION_RESOURCES WOR
	 WHERE
	 WOR.WIP_ENTITY_ID	=	WCTI.WIP_ENTITY_ID	AND
	 WOR.ORGANIZATION_ID	=	WCTI.ORGANIZATION_ID	AND
	 WOR.OPERATION_SEQ_NUM	=	WCTI.OPERATION_SEQ_NUM  AND
	 WOR.RESOURCE_SEQ_NUM	=	WCTI.RESOURCE_SEQ_NUM	AND
	 WOR.RESOURCE_ID	=	WCTI.RESOURCE_ID)
	 GROUP BY WTA.WIP_ENTITY_ID,WCTI.OPERATION_SEQ_NUM,
	          WCTI.RESOURCE_SEQ_NUM,WTA.RESOURCE_ID,WTA.BASIS_TYPE)
	 WHERE
	(W1.WIP_ENTITY_ID,W1.ORGANIZATION_ID,W1.OPERATION_SEQ_NUM,
	 W1.RESOURCE_SEQ_NUM, W1.OVERHEAD_ID, W1.BASIS_TYPE) IN      /* Bug 3646550: added w1.overhead_id, w1.basis_type */
	(SELECT
	 WCTI2.WIP_ENTITY_ID,WCTI2.ORGANIZATION_ID,WCTI2.OPERATION_SEQ_NUM,
	 WCTI2.RESOURCE_SEQ_NUM, WTA2.RESOURCE_ID, WTA2.BASIS_TYPE
	 FROM
	 WIP_COST_TXN_INTERFACE WCTI2,
         WIP_TRANSACTION_ACCOUNTS WTA2
	 WHERE
         /* Added for bug 3646550 */
         WTA2.TRANSACTION_ID    =       WCTI2.TRANSACTION_ID    AND
         WTA2.WIP_ENTITY_ID     =       WCTI2.WIP_ENTITY_ID     AND
         WTA2.BASIS_TYPE        IN      (3,4)                   AND
         WTA2.ACCOUNTING_LINE_TYPE=     7                       AND
         WTA2.COST_ELEMENT_ID   =       5                       AND
         WTA2.REPETITIVE_SCHEDULE_ID    IS NULL                 AND
         WTA2.BASIS_RESOURCE_ID =       WCTI2.RESOURCE_ID       AND
         WCTI2.TRANSACTION_TYPE IN      (1,3)                   AND
         /* End of bug 3646550 */
	 WCTI2.GROUP_ID		=	i_group_id		AND
	 WCTI2.PROCESS_STATUS	=	2                       AND
	 WCTI2.ENTITY_TYPE = DECODE(wsm_enabled_org,1,5,WCTI2.ENTITY_TYPE));


	ELSIF (I_OVHD_TYPE = 2) THEN

	stmt_num := 40;

	/*-----------------------------------------------------------+
	* Insert any rows for new department based ovhds ...	     *
	*------------------------------------------------------------*/


        INSERT INTO WIP_OPERATION_OVERHEADS
        (WIP_ENTITY_ID,
         OPERATION_SEQ_NUM,
         RESOURCE_SEQ_NUM,
         ORGANIZATION_ID,
         OVERHEAD_ID,
         BASIS_TYPE,
         APPLIED_OVHD_UNITS,
         APPLIED_OVHD_VALUE,
         RELIEVED_OVHD_COMPLETION_UNITS,
         RELIEVED_OVHD_SCRAP_UNITS,
         RELIEVED_OVHD_COMPLETION_VALUE,
         RELIEVED_OVHD_SCRAP_VALUE,
         TEMP_RELIEVED_VALUE,
         LAST_UPDATED_BY,
         CREATION_DATE,
         CREATED_BY,
         LAST_UPDATE_LOGIN,
         REQUEST_ID,
         PROGRAM_APPLICATION_ID,
         PROGRAM_ID,
         PROGRAM_UPDATE_DATE,
	 LAST_UPDATE_DATE)
	SELECT
	 WCTI.WIP_ENTITY_ID,
	 WCTI.OPERATION_SEQ_NUM,
	 -1,
	 WCTI.ORGANIZATION_ID,
	 WTA.RESOURCE_ID,
	 WTA.BASIS_TYPE,
         0,
         0,
         0,
         0,
         0,
         0,
         0,
         -1,
         SYSDATE,
         -1,
         -1,
         -1,
         -1,
         -1,
         SYSDATE,
	 SYSDATE
	FROM
	WIP_TRANSACTION_ACCOUNTS	WTA,
	WIP_COST_TXN_INTERFACE 		WCTI,
	WIP_ENTITIES			WE
	WHERE
        WCTI.WIP_ENTITY_ID              =       WE.WIP_ENTITY_ID        AND
        WE.ENTITY_TYPE                  <>      4                       AND
	WE.ENTITY_TYPE  		=       DECODE(wsm_enabled_org, 1, 5,WE.ENTITY_TYPE) AND
	WCTI.WIP_ENTITY_ID		=	WTA.WIP_ENTITY_ID	AND
	WCTI.TRANSACTION_ID		=	WTA.TRANSACTION_ID	AND
	WCTI.TRANSACTION_TYPE		=	2			AND
	WCTI.PROCESS_STATUS		=	2			AND
	WCTI.GROUP_ID			=	I_GROUP_ID		AND
	WTA.ACCOUNTING_LINE_TYPE	=	7			AND
	WTA.COST_ELEMENT_ID		=	5			AND
	WTA.BASIS_TYPE			IN	(1,2)			AND
	WTA.REPETITIVE_SCHEDULE_ID 	IS	NULL			AND
	NOT EXISTS
	(SELECT 'X' FROM
	 WIP_OPERATION_OVERHEADS W2
	 WHERE
	 W2.WIP_ENTITY_ID		=	WCTI.WIP_ENTITY_ID	AND
	 W2.ORGANIZATION_ID		=	WCTI.ORGANIZATION_ID	AND
	 W2.OPERATION_SEQ_NUM		=	WCTI.OPERATION_SEQ_NUM	AND
	 W2.OVERHEAD_ID			=	WTA.RESOURCE_ID		AND
	 W2.RESOURCE_SEQ_NUM		=	-1			AND
	 W2.BASIS_TYPE			=	WTA.BASIS_TYPE)
        GROUP BY WCTI.WIP_ENTITY_ID,WCTI.ORGANIZATION_ID,
        WCTI.OPERATION_SEQ_NUM,WTA.RESOURCE_ID,WTA.BASIS_TYPE;


	/************************************************************
	* Update any existing rows for Item/Lot based ovhds ...	    *
	*************************************************************/

	stmt_num := 60;

	UPDATE
	WIP_OPERATION_OVERHEADS W1
	SET
	 (APPLIED_OVHD_UNITS,
	  APPLIED_OVHD_VALUE) =
	(SELECT
	  NVL(w1.applied_ovhd_units,0) + NVL(SUM(wta.primary_quantity),0),
 	  NVL(w1.applied_ovhd_value,0) + NVL(SUM(wta.base_transaction_value),0)
	FROM
	wip_cost_txn_interface wcti,
	wip_transaction_accounts wta,
	wip_operations wo
	WHERE
	w1.wip_entity_id		=	wcti.wip_entity_id	AND
	w1.organization_id		=	wcti.organization_id	and
	w1.resource_seq_num		=	-1			and
	w1.overhead_id			=	wta.resource_id		and
	w1.basis_type			=	wta.basis_type		and
	w1.operation_seq_num		=	wo.operation_seq_num	and
        --
        -- joined operation_seq_num of wcti and wo bug 607023
    	wcti.operation_seq_num		=	wo.operation_seq_num	and
	wcti.wip_entity_id		=	wo.wip_entity_id	and
	wcti.organization_id		=	wo.organization_id	and
        /* Bug #2835325 */
	/* wcti.department_id		=	wo.department_id	and*/
	wcti.wip_entity_id		=	wta.wip_entity_id	and
	wcti.transaction_id		=	wta.transaction_id	and
	wcti.transaction_type		=	2			and
	wcti.group_id			=	i_group_id		and
	wcti.process_status		=	2			and
	wta.basis_type                  in      (1,2)                   and
	wta.repetitive_schedule_id	is	null			and
	wta.cost_element_id		=	5			and
	wta.accounting_line_type	=	7
  	group by wta.wip_entity_id,wo.operation_seq_num,wta.resource_id,
                 wta.basis_type)
	WHERE
	(w1.wip_entity_id,
         w1.organization_id,
         w1.operation_seq_num,
	 w1.resource_seq_num,
         w1.basis_type,
         w1.overhead_id)  /* Bug 3646550: added w1.overhead_id in the conditions */
	in
	(
	 SELECT
	 wo2.wip_entity_id,
         wo2.organization_id,
         wo2.operation_seq_num,
         -1,
         wta2.basis_type,
         wta2.resource_id
	 FROM
	 wip_operations wo2,
	 wip_cost_txn_interface wcti2,
         wip_transaction_accounts wta2
	 WHERE
         wta2.wip_entity_id             =       wcti2.wip_entity_id     and
         wta2.transaction_id            =       wcti2.transaction_id    and
         wta2.basis_type in (1,2) and
         wta2.repetitive_schedule_id is null and
         wta2.cost_element_id           = 5  and
         wta2.accounting_line_type      = 7  and
	 wcti2.wip_entity_id		=	wo2.wip_entity_id	and
	 wcti2.organization_id		=	wo2.organization_id	and
	 /* Bug #2835325 */
	 /* wcti2.department_id		=	wo2.department_id	and*/
         --
         -- joined operation_seq_num of wcti and wo bug 607023
 	 wcti2.operation_seq_num   	= 	wo2.operation_seq_num	and
	 wcti2.process_status		= 	2			and
	 wcti2.group_id			=	i_group_id		and
	 wcti2.transaction_type		=	2                       and
	 WCTI2.ENTITY_TYPE = DECODE(wsm_enabled_org,1,5,WCTI2.ENTITY_TYPE));


	END IF;

 return(0);


 EXCEPTION

 WHEN OTHERS THEN
 err_num := SQLCODE;
 err_msg := 'CSTACWRO:overhead' || to_char(stmt_num) || substr(SQLERRM,1,150);
 return(-999);



 END overhead;

 END CSTACWRO;

/
