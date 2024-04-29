--------------------------------------------------------
--  DDL for Package Body OPI_EDW_JOB_RSRC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OPI_EDW_JOB_RSRC_PVT" as
/* $Header: OPIMJRPB.pls 115.4 2003/03/28 02:09:51 ltong noship $ */

-- dbdrv: sql ~PROD ~PATH ~FILE none none none package &phase=plb \
-- dbdrv: checkfile:~PROD:~PATH:~FILE


--------------------------------------------------------------------
-- FUNCTION GET_ACT_STRT_DATE
-- Returns the Actual start date of an operation
--------------------------------------------------------------------
   FUNCTION GET_ACT_STRT_DATE(
		p_organization_id NUMBER,
		p_wip_entity_id NUMBER,
		p_repetitive_schedule_id NUMBER,
		p_operation_seq_num NUMBER
		) RETURN DATE IS
	l_transaction_date DATE := to_date(NULL) ;
	l_operation_seq_num NUMBER := 0;
	l_strt_date DATE  := to_date(NULL);
   BEGIN


	SELECT min(operation_seq_num)
	INTO l_operation_seq_num
	FROM WIP_OPERATIONS
	WHERE organization_id = p_organization_id
	AND wip_entity_id = p_wip_entity_id
	AND nvl(repetitive_schedule_id ,-99)= nvl(p_repetitive_schedule_id,-99) ;

	if p_repetitive_schedule_id is NOT NULL THEN

	IF l_operation_seq_num = p_operation_seq_num THEN
	/* First Operation */
		SELECT min(wmt.transaction_date)
		INTO l_strt_date
		FROM WIP_MOVE_TRANSACTIONS wmt, WIP_MOVE_TXN_ALLOCATIONS wmta
		WHERE wmt.organization_id = p_organization_id
		AND wmt.wip_entity_id = p_wip_entity_id
		AND wmt.transaction_id = wmta.transaction_id
		AND wmta.repetitive_schedule_id = p_repetitive_schedule_id
		AND wmt.fm_operation_seq_num = p_operation_seq_num ;
	ELSE
		SELECT min(wmt.transaction_date)
		INTO l_strt_date
		FROM WIP_MOVE_TRANSACTIONS wmt, WIP_MOVE_TXN_ALLOCATIONS wmta
		WHERE wmt.organization_id = p_organization_id
		AND wmt.wip_entity_id = p_wip_entity_id
		AND wmt.transaction_id = wmta.transaction_id
		AND wmta.repetitive_schedule_id = p_repetitive_schedule_id
		AND wmt.to_operation_seq_num = p_operation_seq_num ;
	END IF ;

	ELSE /* p_repetitive_schedule_id is NULL */

	IF l_operation_seq_num = p_operation_seq_num THEN
	/* First Operation */
		SELECT min(transaction_date)
		INTO l_strt_date
		FROM WIP_MOVE_TRANSACTIONS
		WHERE organization_id = p_organization_id
		AND wip_entity_id = p_wip_entity_id
		AND fm_operation_seq_num = p_operation_seq_num ;
	ELSE

		SELECT min(transaction_date)
		INTO l_strt_date
		FROM WIP_MOVE_TRANSACTIONS
		WHERE organization_id = p_organization_id
		AND wip_entity_id = p_wip_entity_id
		AND to_operation_seq_num = p_operation_seq_num ;

	END IF ;

	END IF ;

	return l_strt_date ;

   END GET_ACT_STRT_DATE ;

--------------------------------------------------------------------
-- FUNCTION GET_ACT_CMPL_DATE
-- Returns the Actual completion date of an operation
--------------------------------------------------------------------
   FUNCTION GET_ACT_CMPL_DATE(
		p_organization_id NUMBER,
		p_wip_entity_id NUMBER,
		p_repetitive_schedule_id NUMBER,
		p_operation_seq_num NUMBER
		) RETURN DATE IS
	l_transaction_date DATE := to_date(NULL) ;
	l_operation_seq_num NUMBER := 0;
	l_cmpl_date DATE  := to_date(NULL);
   BEGIN
	SELECT max(operation_seq_num)
	INTO l_operation_seq_num
	FROM WIP_OPERATIONS
	WHERE organization_id = p_organization_id
	AND wip_entity_id = p_wip_entity_id
	AND nvl(repetitive_schedule_id,-99) = nvl(p_repetitive_schedule_id,-99) ;


	IF  p_repetitive_schedule_id is NOT NULL THEN

	   IF l_operation_seq_num = p_operation_seq_num THEN
	      /* Last Operation */
	      SELECT max(wmt.transaction_date)
		INTO l_cmpl_date
		FROM WIP_MOVE_TRANSACTIONS wmt, WIP_MOVE_TXN_ALLOCATIONS wmta
		WHERE wmt.organization_id = p_organization_id
		AND wmt.wip_entity_id = p_wip_entity_id
		AND wmt.transaction_id = wmta.transaction_id
		AND wmta.repetitive_schedule_id = p_repetitive_schedule_id
		AND wmt.to_operation_seq_num = p_operation_seq_num ;
	    ELSE
	      SELECT max(wmt.transaction_date)
		INTO l_cmpl_date
		FROM WIP_MOVE_TRANSACTIONS wmt, WIP_MOVE_TXN_ALLOCATIONS wmta
		WHERE wmt.organization_id = p_organization_id
		AND wmt.wip_entity_id = p_wip_entity_id
		AND wmt.transaction_id = wmta.transaction_id
		AND wmta.repetitive_schedule_id = p_repetitive_schedule_id
		AND wmt.fm_operation_seq_num = p_operation_seq_num ;
	   END IF ;

	   /* fix for bug 2839182 */
	   IF l_cmpl_date IS NULL THEN
	      SELECT Decode( status_type,12, date_closed, last_update_date)
		INTO l_cmpl_date
		FROM wip_repetitive_schedules
		WHERE status_type IN (4,5,7,12)
		AND repetitive_schedule_id = p_repetitive_schedule_id;
	   END IF;

	 ELSE /* p_repetitive_schedule_id is NULL */

	   IF l_operation_seq_num = p_operation_seq_num THEN
	      /* Last Operation */
	      SELECT max(wmt.transaction_date)
		INTO l_cmpl_date
		FROM WIP_MOVE_TRANSACTIONS wmt
		WHERE wmt.organization_id = p_organization_id
		AND wmt.wip_entity_id = p_wip_entity_id
		AND wmt.to_operation_seq_num = p_operation_seq_num ;
	    ELSE
	      SELECT max(wmt.transaction_date)
		INTO l_cmpl_date
		FROM WIP_MOVE_TRANSACTIONS wmt
		WHERE wmt.organization_id = p_organization_id
		AND wmt.wip_entity_id = p_wip_entity_id
		AND wmt.fm_operation_seq_num = p_operation_seq_num ;
	   END IF ;

	   /* fix for bug 2839182 */
	   IF l_cmpl_date IS NULL THEN
	      SELECT Decode( status_type,12, date_closed,
			     4, date_completed,
			     5, date_completed,
			     last_update_date)
		INTO l_cmpl_date
		FROM wip_discrete_jobs
		WHERE status_type IN (4,5,7,12)
		AND wip_entity_id = p_wip_entity_id;
	   END IF;
	END IF ;

	return l_cmpl_date ;

   END GET_ACT_CMPL_DATE ;

end OPI_EDW_JOB_RSRC_PVT ;

/
