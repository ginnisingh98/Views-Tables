--------------------------------------------------------
--  DDL for Package Body XDP_PURGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XDP_PURGE" AS
/* $Header: XDPPRGB.pls 120.2 2006/08/09 13:47:15 dputhiye noship $ */

g_debug_level 		NUMBER := 4;

bAudit 			VARCHAR2(8)  := 'FALSE';
g_purge_method 	VARCHAR2(8) := 'CM';

-- number of exceptions will be allowed before jumping out a loop.
g_max_exceptions	NUMBER := 5;
-- commit every P_MSG_NAME g_max_rows_before_commit deletions
g_max_rows_before_commit NUMBER := 5000;

G_Total_WK_TIME 	NUMBER := 0;
G_PURGE_WORK_FLOW 	VARCHAR2(8) := 'FALSE';

PROCEDURE RECORDS_PURGED_MSGS(
		p_no_records IN number DEFAULT 0,
		p_table_name IN VARCHAR2 DEFAULT NULL,
		p_msg_name IN VARCHAR2 DEFAULT 'XDP_PURGE_REC',
		p_debug_level IN NUMBER DEFAULT 0 -- DEFAULT TO CONSICE MESSAGES
	)
IS
l_error_msg VARCHAR2(2000);
BEGIN
	IF p_debug_level >= g_debug_level THEN
		RETURN;
	END IF;
	IF p_no_records > 1 THEN
            FND_MESSAGE.SET_NAME('XDP',p_msg_name||'S');
            FND_MESSAGE.SET_TOKEN('RECORDS',p_no_records);
            FND_MESSAGE.SET_TOKEN('TABLE_NAME',p_table_name);
	ELSIF (p_no_records = 0) THEN
			RETURN; -- do not log anythig
		    FND_MESSAGE.SET_NAME('XDP',p_msg_name||'S');
            FND_MESSAGE.SET_TOKEN('RECORDS','No');
            FND_MESSAGE.SET_TOKEN('TABLE_NAME',p_table_name);
	ELSE
            FND_MESSAGE.SET_NAME('XDP',p_msg_name);
            FND_MESSAGE.SET_TOKEN('TABLE_NAME',p_table_name);
	END IF;
	l_error_msg := SUBSTR(FND_MESSAGE.GET,0,1999);

	-- IF CALLER IS CONCURRENT MANAGER, USE FND_FILE
	-- OR ELSE USE DBMS_OUTPUT

	IF g_purge_method = 'CM' THEN
		FND_FILE.PUT_LINE(FND_FILE.LOG,l_error_msg);
	ELSE
		-- DBMS_OUTPUT.PUT_LINE(l_error_msg);
		null;
	END IF;
END;

--
-- Internal procedure for handling messages
-- Name     PURGE_ERRORS
--

PROCEDURE PURGE_ERRORS(
		p_msg			IN VARCHAR2 DEFAULT NULL,
		p_commit		IN BOOLEAN DEFAULT FALSE,
		p_abort			IN BOOLEAN DEFAULT FALSE,
		p_debug_level IN NUMBER DEFAULT 0 -- DEFAULT TO CONSICE MESSAGES
)
IS
BEGIN

	IF g_purge_method = 'CM' THEN
		FND_FILE.PUT_LINE(FND_FILE.LOG,P_MSG);
	ELSE
		-- DBMS_OUTPUT.PUT_LINE(P_MSG);
		null;
	END IF;

	IF p_commit THEN
       		COMMIT;
    	END IF;

	IF p_abort THEN
       		APP_EXCEPTION.RAISE_EXCEPTION;
    	END IF;
END PURGE_ERRORS;

FUNCTION USER_ROLLBACK_CTRL(p_rollback_segment VARCHAR2) RETURN BOOLEAN IS
	l_result BOOLEAN := FALSE;
	l_stmt VARCHAR2(200);
BEGIN
--
--	Rollback segment controlled by customers. No incremental commit will be performed
--	for such cases. It is user's responsibility to make sure the rollback
--	segment is big enough to handle the transaction
--	However, if fails to transaction rollback segment, then default rollback segment
--	will still be used with incremental commits.
--

	IF (p_rollback_segment IS NOT NULL) THEN
                PURGE_ERRORS('Setting rollback segment to '||p_rollback_segment);
		-- IF FAILS, ON EXCEPTION, FLAG WLLL BE SET FALSE
		COMMIT; -- we have to clean up the current transaction.
		l_stmt := 'SET TRANSACTION USE ROLLBACK SEGMENT '||p_rollback_segment;
		EXECUTE IMMEDIATE l_STMT;

--		SET TRANSACTION USE ROLLBACK SEGMENT :p_rollback_segment;
        	PURGE_ERRORS(p_rollback_segment || ' rollback segment will be used!');
		l_result := TRUE;
	ELSE
	        PURGE_ERRORS('Default rollback segment will be used');
	END IF;
	RETURN(l_result);
EXCEPTION
	WHEN OTHERS THEN
		PURGE_ERRORS('Default rollback segment will be used');
                PURGE_ERRORS(SUBSTR(SQLERRM, 1, 512));
		RETURN(FALSE);
END USER_ROLLBACK_CTRL;

PROCEDURE XDP_CHECK_ORDER(
	p_order_id	IN 	VARCHAR2 DEFAULT NULL
) IS

l_no_records NUMBER := 0;
l_counter NUMBER := 0;
l_temp NUMBER := 0;
l_order_exist BOOLEAN := FALSE;
l_wi_type WF_ITEMS.ITEM_TYPE%TYPE;
l_wi_key WF_ITEMS.ITEM_KEY%TYPE;

BEGIN
	IF p_order_id IS NULL THEN
	-- CHECK IF THERE ARE ANY RECORDS IN ANY TABLE THAT HAVE
	-- ORDER_IDS THAT DO NOT EXSIT IN XDP_ORDER_HEADER TABLE

		RETURN;
	END IF;

	SELECT COUNT(*) INTO l_no_records FROM XDP_ORDER_HEADERS
		WHERE ORDER_ID = p_order_id;

	RECORDS_PURGED_MSGS(l_no_records,'XDP_ORDER_HEADERS WHERE ORDER_ID = '||p_order_id,
		'XDP_FOUND_REC',0);

	IF l_no_records > 0 THEN
		l_order_exist := TRUE;
	END IF;

	SELECT COUNT(*) INTO l_no_records FROM XDP_ORDER_RELATIONSHIPS
		WHERE ORDER_ID = p_order_id;

	RECORDS_PURGED_MSGS(l_no_records ,'XDP_ORDER_RELATIONSHIPS WHERE ORDER_ID = '||p_order_id,
		'XDP_FOUND_REC',0);

	SELECT COUNT(*) INTO l_no_records FROM XNP_MSGS
		WHERE ORDER_ID = p_order_id;

	RECORDS_PURGED_MSGS(l_no_records,'XNP_MSGS WHERE ORDER_ID = '||p_order_id,
		'XDP_FOUND_REC',0);

	SELECT COUNT(*) INTO l_no_records FROM XDP_ORDER_PARAMETERS
		WHERE ORDER_ID = p_order_id;

	RECORDS_PURGED_MSGS(l_no_records,'XDP_ORDER_PARAMETERS WHERE ORDER_ID = '||p_order_id,
		'XDP_FOUND_REC',0);

	SELECT COUNT(*) INTO l_no_records FROM XDP_ORDER_BUNDLES
		WHERE ORDER_ID = p_order_id;

	RECORDS_PURGED_MSGS(l_no_records,'XDP_ORDER_BUNDLES WHERE ORDER_ID = '||p_order_id,
		'XDP_FOUND_REC',0);

	SELECT COUNT(*) INTO l_no_records FROM XNP_CALLBACK_EVENTS
		WHERE ORDER_ID = p_order_id;
	RECORDS_PURGED_MSGS(l_no_records,'XNP_CALLBACK_EVENTS WHERE ORDER_ID = '||p_order_id,
		'XDP_FOUND_REC',0);

	SELECT COUNT(*) INTO l_no_records FROM XNP_TIMER_REGISTRY
		WHERE ORDER_ID = p_order_id;
	RECORDS_PURGED_MSGS(l_no_records,'XNP_TIMER_REGISTRY WHERE ORDER_ID = '||p_order_id,
		'XDP_FOUND_REC',0);

	SELECT COUNT(*) INTO l_no_records FROM XNP_SYNC_REGISTRATION
		WHERE ORDER_ID = p_order_id;
	RECORDS_PURGED_MSGS(l_no_records,'XNP_SYNC_REGISTRATION WHERE ORDER_ID = '||p_order_id,
		'XDP_FOUND_REC',0);

	IF l_order_exist THEN
		SELECT wf_item_type,wf_item_key INTO l_wi_type,l_wi_key
			FROM XDP_ORDER_HEADERS
			WHERE ORDER_ID = p_order_id;

		SELECT count(*) INTO l_no_records
		FROM WF_ITEMS
		START WITH item_type = l_wi_type AND item_key = l_wi_key
    		CONNECT BY PRIOR item_key = parent_item_key
		AND PRIOR item_type = parent_item_type;
		RECORDS_PURGED_MSGS(l_no_records,'WF_ITEMS WHERE ORDER_ID = '||p_order_id,
			'XDP_FOUND_REC',0);
	END IF;

	SELECT COUNT(*) INTO l_no_records FROM XDP_ORDER_LINE_ITEMS
		WHERE ORDER_ID = p_order_id;

	RECORDS_PURGED_MSGS(l_no_records,'XDP_ORDER_LINE_ITEMS WHERE ORDER_ID = '||p_order_id,
		'XDP_FOUND_REC',0);

	IF l_no_records <> 0 THEN
		FOR c_item IN (SELECT LINE_ITEM_ID FROM XDP_ORDER_LINE_ITEMS
			WHERE ORDER_ID = p_order_id)
		LOOP
			SELECT COUNT(*) INTO l_no_records FROM XDP_ORDER_LINEITEM_DETS
				WHERE LINE_ITEM_ID = c_item.LINE_ITEM_ID;

			RECORDS_PURGED_MSGS(l_no_records,'XDP_ORDER_LINEITEM_DETS WHERE LINE_ITEM_ID = '
				||c_item.LINE_ITEM_ID,'XDP_FOUND_REC',1);

			SELECT COUNT(*) INTO l_no_records FROM XDP_LINE_RELATIONSHIPS
				WHERE LINE_ITEM_ID = c_item.LINE_ITEM_ID;

			RECORDS_PURGED_MSGS(l_counter,'XDP_LINE_RELATIONSHIPS WHERE LINE_ITEM_ID = '
				||c_item.LINE_ITEM_ID,'XDP_FOUND_REC',1);

			SELECT COUNT(*) INTO l_no_records FROM XDP_FULFILL_WORKLIST
				WHERE LINE_ITEM_ID = c_item.LINE_ITEM_ID;

			RECORDS_PURGED_MSGS(l_counter,'XDP_FULFILL_WORKLIST WHERE LINE_ITEM_ID = '
				||c_item.LINE_ITEM_ID,'XDP_FOUND_REC',1);

			IF l_no_records <> 0 THEN
				FOR c_fw IN (SELECT WORKITEM_INSTANCE_ID FROM XDP_FULFILL_WORKLIST
						WHERE LINE_ITEM_ID = C_ITEM.LINE_ITEM_ID)
				LOOP
					SELECT COUNT(*) INTO l_temp FROM XDP_WI_RELATIONSHIPS
						WHERE WORKITEM_INSTANCE_ID = c_fw.WORKITEM_INSTANCE_ID;

					RECORDS_PURGED_MSGS(l_counter,'XDP_WI_RELATIONSHIPS '||
						'WHERE WORKITEM_INSTANCE_ID = '
						||c_fw.WORKITEM_INSTANCE_ID,'XDP_FOUND_REC',2);

					SELECT COUNT(*) INTO l_temp FROM XDP_WORKLIST_DETAILS
						WHERE WORKITEM_INSTANCE_ID = c_fw.WORKITEM_INSTANCE_ID;

					RECORDS_PURGED_MSGS(l_counter,'XDP_WORKLIST_DETAILS '||
						'WHERE WORKITEM_INSTANCE_ID = '
						||c_fw.WORKITEM_INSTANCE_ID,'XDP_FOUND_REC',2);

					SELECT COUNT(*) INTO l_temp FROM XDP_FA_RUNTIME_LIST
						WHERE WORKITEM_INSTANCE_ID = c_fw.WORKITEM_INSTANCE_ID;

					RECORDS_PURGED_MSGS(l_counter,'XDP_FA_RUNTIME_LIST '||
						'WHERE WORKITEM_INSTANCE_ID = '
						||c_fw.WORKITEM_INSTANCE_ID,'XDP_FOUND_REC',2);

					IF l_temp <> 0 THEN
						FOR c_fa IN (SELECT FA_INSTANCE_ID FROM XDP_FA_RUNTIME_LIST
							WHERE WORKITEM_INSTANCE_ID = c_fw.WORKITEM_INSTANCE_ID)
						LOOP
							SELECT COUNT(*) INTO l_temp FROM XDP_FA_DETAILS WHERE
								FA_INSTANCE_ID = c_fa.FA_INSTANCE_ID;

							RECORDS_PURGED_MSGS(l_counter,'XDP_FA_DETAILS WHERE FA_INSTANCE_ID = '
								||c_fa.FA_INSTANCE_ID,'XDP_FOUND_REC',3);
							SELECT COUNT(*) INTO l_temp FROM XDP_FE_CMD_AUD_TRAILS
								WHERE FA_INSTANCE_ID = c_fa.FA_INSTANCE_ID;

							RECORDS_PURGED_MSGS(l_counter,'XDP_FE_CMD_AUD_TRAILS WHERE FA_INSTANCE_ID = '
								||c_fa.FA_INSTANCE_ID,'XDP_FOUND_REC',3);
						END LOOP;
					END IF;

					SELECT COUNT(*) INTO l_temp FROM XDP_FMC_AUDIT_TRAILS
						WHERE WORKITEM_INSTANCE_ID = c_fw.WORKITEM_INSTANCE_ID;

					RECORDS_PURGED_MSGS(l_counter,'XDP_FMC_AUDIT_TRAILS '||
						'WHERE WORKITEM_INSTANCE_ID = '
						||c_fw.WORKITEM_INSTANCE_ID,'XDP_FOUND_REC',2);

					IF l_temp <> 0 THEN
						SELECT COUNT(*) INTO l_temp FROM XDP_FMC_AUD_TRAIL_DETS WHERE FMC_ID IN
							(SELECT FMC_ID FROM XDP_FMC_AUDIT_TRAILS
							WHERE WORKITEM_INSTANCE_ID = c_fw.WORKITEM_INSTANCE_ID);

						RECORDS_PURGED_MSGS(l_counter,'XDP_FMC_AUD_TRAIL_DETS '||
							'WHERE WORKITEM_INSTANCE_ID = '
							||c_fw.WORKITEM_INSTANCE_ID,'XDP_FOUND_REC',3);
					END IF;
				END LOOP;
			END IF;
		END LOOP;
	END IF;
END XDP_CHECK_ORDER;

PROCEDURE XDP_CHECK_SOA
(
	p_sv_soa_id	IN VARCHAR2 DEFAULT NULL,
	p_time_from	IN DATE DEFAULT NULL,
	p_time_to	IN DATE DEFAULT NULL
) IS

l_no_records NUMBER :=0;

BEGIN

	IF p_sv_soa_id IS NULL THEN
		IF (p_time_from IS NULL) OR (p_time_to IS NULL) THEN
		       	FND_MESSAGE.SET_NAME('XDP','XDP_PURGE_ERROR');
			FND_MESSAGE.SET_TOKEN('OBJECT','SOA');
			FND_MESSAGE.SET_TOKEN('CONDITION','XDP_CHECK_SOA');
			PURGE_ERRORS(FND_MESSAGE.GET);
		END IF;

		FOR l_sv_soa IN (SELECT SV_SOA_ID FROM XNP_SV_SOA A, XNP_SV_STATUS_TYPES_B B
       					WHERE a.STATUS_TYPE_CODE = b.STATUS_TYPE_CODE
					AND b.PHASE_INDICATOR ='OLD'
					AND a.MODIFIED_DATE < p_time_to
					AND a.MODIFIED_DATE > p_time_from)
		LOOP
			SELECT COUNT(*) INTO l_no_records FROM XNP_SV_SOA_JN
				WHERE SV_SOA_ID = l_sv_soa.SV_SOA_ID;

			RECORDS_PURGED_MSGS(l_no_records,'XNP_SV_SOA_JN WHERE SV_SOA_ID ='
				||l_sv_soa.SV_SOA_ID,'XDP_FOUND_REC',1);

			SELECT COUNT(*) INTO l_no_records FROM XNP_SV_FAILURES
				WHERE SV_SOA_ID = l_sv_soa.SV_SOA_ID;

			RECORDS_PURGED_MSGS(l_no_records,'XNP_SV_FAILURES WHERE SV_SOA_ID ='
				||l_sv_soa.SV_SOA_ID,'XDP_FOUND_REC',1);

			SELECT COUNT(*) INTO l_no_records FROM XNP_SV_EVENT_HISTORY
				WHERE SV_SOA_ID = l_sv_soa.SV_SOA_ID;

			RECORDS_PURGED_MSGS(l_no_records,'XNP_SV_EVENT_HISTORY WHERE SV_SOA_ID ='
				||l_sv_soa.SV_SOA_ID,'XDP_FOUND_REC',1);
		END LOOP;
		RETURN;
	END IF;

	SELECT COUNT(*) INTO l_no_records FROM XNP_SV_SOA WHERE SV_SOA_ID = p_sv_soa_id;
	RECORDS_PURGED_MSGS(l_no_records,'XNP_SV_SOA WHERE SV_SOA_ID ='
		||p_sv_soa_id,'XDP_FOUND_REC',0);

	SELECT COUNT(*) INTO l_no_records FROM XNP_SV_EVENT_HISTORY
       		WHERE SV_SOA_ID = p_sv_soa_id;
	RECORDS_PURGED_MSGS(l_no_records,'XNP_SV_EVENT_HISTORY WHERE SV_SOA_ID ='
		||p_sv_soa_id,'XDP_FOUND_REC',0);
	SELECT COUNT(*) INTO l_no_records FROM XNP_SV_FAILURES
               	WHERE SV_SOA_ID = p_sv_soa_id;
	RECORDS_PURGED_MSGS(l_no_records,'XNP_SV_FAILURES WHERE SV_SOA_ID ='
		||p_sv_soa_id,'XDP_FOUND_REC',0);
	SELECT COUNT(*) INTO l_no_records FROM XNP_SV_SOA_JN
       		WHERE SV_SOA_ID = p_sv_soa_id;
	RECORDS_PURGED_MSGS(l_no_records,'XNP_SV_SOA_JN WHERE SV_SOA_ID ='
		||p_sv_soa_id,'XDP_FOUND_REC',0);
    	COMMIT;
EXCEPTION
	WHEN OTHERS THEN
	       	FND_MESSAGE.SET_NAME('XDP','XDP_PURGE_ERROR');
		FND_MESSAGE.SET_TOKEN('OBJECT','SOA');
		FND_MESSAGE.SET_TOKEN('CONDITION','XDP_CHECK_SOA');
		PURGE_ERRORS(FND_MESSAGE.GET);
END XDP_CHECK_SOA;

-- Internal procedure for verifying if an order is deletable
-- Name 	IS_ORDER_DELETABLE
--

PROCEDURE IS_ORDER_DELETABLE(
	p_order_id	IN XDP_ORDER_HEADERS.ORDER_ID%TYPE,
    	p_date_from IN DATE,
    	p_date_to   IN DATE,
    	p_order_deletable OUT NOCOPY VARCHAR2
) IS
--
--The following cursor is to find all related orders in the heirachy
-- rooted from the order with id of p_order_id.
-- If any one of this related orders do not satisfy the given
-- purging conditions, then the current order is not deletable.
--
CURSOR c_order_relation(p_order_id VARCHAR2) IS
    SELECT RELATED_ORDER_ID
    FROM XDP_ORDER_RELATIONSHIPS
    START WITH ORDER_ID = p_order_id
    CONNECT BY PRIOR RELATED_ORDER_ID = ORDER_ID;

l_order_state XDP_ORDER_HEADERS.STATUS_CODE%TYPE;
--l_order_state XDP_ORDER_HEADERS.ORDER_ID%TYPE;
l_completion_date DATE;

BEGIN
    	p_order_deletable :='FALSE';
		FOR l_order_relation IN c_order_relation(p_order_id) LOOP
	            --Date: 09 AUG 2006   Author: DPUTHIYE         Bug #:5446335
                    --This SQL should consider CANCEL_PROVISIONING_DATE for cancelled orders as well.
                    --Dependencies: None.
        	    /* SELECT status_code,
                           completion_date
                      INTO l_order_state,
                           l_completion_date
        	      FROM XDP_ORDER_HEADERS
                     WHERE order_id = l_order_relation.related_order_id; */

		SELECT status_code,
                    NVL(completion_date, CANCEL_PROVISIONING_DATE)
                INTO l_order_state,
                    l_completion_date
        	FROM XDP_ORDER_HEADERS
                WHERE order_id = l_order_relation.related_order_id;

	        IF (l_completion_date < p_date_from) OR
        	   	(l_completion_date > p_date_to) OR
           		(l_order_state <> 'SUCCESS') OR
           		(l_order_state <> 'SUCCESS_WITH_OVERRIDE') OR
           		(l_order_state <> 'CANCELED') OR
           		(l_order_state <> 'ABORTED')
        	THEN
            		RETURN; --return false
        	END IF;
		END LOOP;
    	p_order_deletable :='TRUE';
EXCEPTION
	WHEN OTHERS THEN
		PURGE_ERRORS(SUBSTR(SQLERRM, 1, 512));
		--SILENCE THE EXCEPTION, WILL NOT BE HANDLED
END IS_ORDER_DELETABLE;

-- Internal procedure for deleting fulfile worklist for a given line item
-- Name 	DELETE_FULFILL_WORKLIST

PROCEDURE DELETE_FULFILL_WORKLIST(
	p_line_item_id	IN XDP_ORDER_LINE_ITEMS.LINE_ITEM_ID%TYPE,
	p_run_mode	IN VARCHAR2
) IS
CURSOR c_fulfill_worklist IS
	SELECT WORKITEM_INSTANCE_ID FROM XDP_FULFILL_WORKLIST WHERE
	line_item_id = p_line_item_id
	FOR UPDATE NOWAIT;

CURSOR c_fulfill_action(p_workitem_instance_id XDP_FULFILL_WORKLIST.WORKITEM_INSTANCE_ID%TYPE) IS
	SELECT FA_INSTANCE_ID FROM XDP_FA_RUNTIME_LIST
	WHERE WORKITEM_INSTANCE_ID = p_workitem_instance_id
	FOR UPDATE NOWAIT;

l_temp NUMBER := 0;
l_wi_counter NUMBER :=0;
l_rec_name VARCHAR2(16) := 'XDP_FOUND_REC';
BEGIN
	IF(p_run_mode = 'PURGE') THEN
		l_rec_name := 'XDP_PURGE_REC';
	END IF;

	FOR l_worklist IN c_fulfill_worklist LOOP
	-- LOG PURGING INFORMATION
		FOR l_fa IN c_fulfill_action(l_worklist.WORKITEM_INSTANCE_ID) LOOP
			IF ((bAudit = 'TRUE') AND (p_run_mode = 'PURGE')) or (p_run_mode = 'VERIFY') THEN
				SELECT COUNT(*) INTO l_temp FROM XDP_FA_DETAILS
					WHERE FA_INSTANCE_ID = l_fa.FA_INSTANCE_ID;
				RECORDS_PURGED_MSGS(l_temp,'XDP_FA_DETAILS WHERE FA_INSTANCE_ID = '
					||l_fa.FA_INSTANCE_ID,l_rec_name,1);

				SELECT COUNT(*) INTO l_temp FROM XDP_FE_CMD_AUD_TRAILS
					WHERE FA_INSTANCE_ID = l_fa.FA_INSTANCE_ID;
				RECORDS_PURGED_MSGS(l_temp,'XDP_FE_CMD_AUD_TRAILS WHERE FA_INSTANCE_ID = '
				||l_fa.FA_INSTANCE_ID,l_rec_name,1);
			END IF;

			IF p_run_mode = 'PURGE' THEN
				DELETE FROM XDP_FA_DETAILS WHERE FA_INSTANCE_ID = l_fa.FA_INSTANCE_ID;
				DELETE FROM XDP_FE_CMD_AUD_TRAILS WHERE FA_INSTANCE_ID = l_fa.FA_INSTANCE_ID;
			END IF;
		END LOOP;

		IF ((bAudit = 'TRUE') AND (p_run_mode = 'PURGE')) or (p_run_mode = 'VERIFY') THEN
			SELECT COUNT(*) INTO l_temp FROM XDP_FMC_AUD_TRAIL_DETS
				WHERE FMC_ID IN
					(SELECT FMC_ID FROM XDP_FMC_AUDIT_TRAILS
						WHERE WORKITEM_INSTANCE_ID
						= l_worklist.WORKITEM_INSTANCE_ID);
				RECORDS_PURGED_MSGS(l_temp ,'XDP_FE_CMD_AUD_TRAILS WHERE WORKITEM_INSTANCE_ID = '
					||l_worklist.WORKITEM_INSTANCE_ID,l_rec_name,1);

				SELECT COUNT(*) INTO l_temp FROM XDP_FA_RUNTIME_LIST
					WHERE WORKITEM_INSTANCE_ID = l_worklist.WORKITEM_INSTANCE_ID;
				RECORDS_PURGED_MSGS(l_temp, 'XDP_FA_RUNTIME_LIST WHERE WORKITEM_INSTANCE_ID = '
					||l_worklist.WORKITEM_INSTANCE_ID,l_rec_name,1);

				SELECT COUNT(*) INTO l_temp FROM XDP_FMC_AUDIT_TRAILS
					WHERE WORKITEM_INSTANCE_ID = l_worklist.WORKITEM_INSTANCE_ID;
				RECORDS_PURGED_MSGS(l_temp,'XDP_FMC_AUDIT_TRAILS WHERE WORKITEM_INSTANCE_ID = '
					||l_worklist.WORKITEM_INSTANCE_ID,l_rec_name,1);

				SELECT COUNT(*) INTO l_temp FROM XDP_WI_RELATIONSHIPS
					WHERE WORKITEM_INSTANCE_ID = l_worklist.WORKITEM_INSTANCE_ID;
				RECORDS_PURGED_MSGS(l_temp,'XDP_WI_RELATIONSHIPS WHERE WORKITEM_INSTANCE_ID = '
					||l_worklist.WORKITEM_INSTANCE_ID,l_rec_name,1);

				SELECT COUNT(*) INTO l_temp FROM XDP_WORKLIST_DETAILS
					WHERE WORKITEM_INSTANCE_ID = l_worklist.WORKITEM_INSTANCE_ID;
				RECORDS_PURGED_MSGS(l_temp,'XDP_WORKLIST_DETAILS WHERE WORKITEM_INSTANCE_ID = '
					||l_worklist.WORKITEM_INSTANCE_ID,l_rec_name,1);
		END IF;
	-- Purging if it is in run mode
		IF p_run_mode = 'PURGE' THEN
			DELETE FROM XDP_FMC_AUD_TRAIL_DETS
				WHERE FMC_ID IN
					(SELECT FMC_ID FROM XDP_FMC_AUDIT_TRAILS
						WHERE WORKITEM_INSTANCE_ID
	                	    		= l_worklist.WORKITEM_INSTANCE_ID);

			DELETE FROM XDP_FA_RUNTIME_LIST
				WHERE WORKITEM_INSTANCE_ID = l_worklist.WORKITEM_INSTANCE_ID;

			DELETE FROM XDP_FMC_AUDIT_TRAILS
				WHERE WORKITEM_INSTANCE_ID = l_worklist.WORKITEM_INSTANCE_ID;

			DELETE FROM XDP_WI_RELATIONSHIPS
				WHERE WORKITEM_INSTANCE_ID = l_worklist.WORKITEM_INSTANCE_ID;

			DELETE FROM XDP_WORKLIST_DETAILS
				WHERE WORKITEM_INSTANCE_ID = l_worklist.WORKITEM_INSTANCE_ID;

			DELETE FROM XDP_FULFILL_WORKLIST
				WHERE WORKITEM_INSTANCE_ID = l_worklist.WORKITEM_INSTANCE_ID;
		END IF;

		l_wi_counter := l_wi_counter+1;

	END LOOP;
	RECORDS_PURGED_MSGS(l_wi_counter,'XDP_FULFILL_WORKLIST WHERE LINE_ITEM_ID = '
			||p_line_item_id,l_rec_name,0);
EXCEPTION
	WHEN OTHERS THEN
		PURGE_ERRORS(SUBSTR(SQLERRM, 1, 512),P_ABORT => TRUE);

END DELETE_FULFILL_WORKLIST;

-- Internal procedure for deleting line items for an order
-- Name DELETE_LINE_ITEMS
--

PROCEDURE DELETE_LINE_ITEMS
(
	p_order_id			IN XDP_ORDER_HEADERS.ORDER_ID%TYPE,
	p_run_mode			IN VARCHAR2
) IS

CURSOR c_line_item IS
	SELECT LINE_ITEM_ID
          FROM XDP_ORDER_LINE_ITEMS
         WHERE order_id = p_order_id
	   FOR UPDATE OF LINE_ITEM_ID NOWAIT;

l_temp NUMBER := 0;
l_li_number NUMBER := 0;
l_rec_name VARCHAR2(16) := 'XDP_FOUND_REC';

BEGIN
	IF(p_run_mode = 'PURGE') THEN
		l_rec_name := 'XDP_PURGE_REC';
	END IF;

	FOR l_line_item IN c_line_item LOOP
		Delete_Fulfill_Worklist(l_line_item.line_item_id,p_run_mode);
		IF ((bAudit = 'TRUE') AND (p_run_mode = 'PURGE')) or (p_run_mode = 'VERIFY') THEN

				SELECT COUNT(*)
                                  INTO l_temp
                                  FROM XDP_ORDER_LINEITEM_DETS
				 WHERE line_item_id = l_line_item.line_item_id;

				RECORDS_PURGED_MSGS(l_temp, 'XDP_ORDER_LINEITEM_DETS WHERE LINE_ITEM_ID = '
					||l_line_item.line_item_id,l_rec_name,1);

				SELECT COUNT(*)
                                  INTO l_temp
                                  FROM XDP_LINE_RELATIONSHIPS
				 WHERE line_item_id = l_line_item.line_item_id;

				RECORDS_PURGED_MSGS(l_temp,'XDP_LINE_RELATIONSHIPS WHERE LINE_ITEM_ID = '
					||l_line_item.line_item_id,l_rec_name,1);
		END IF;

		IF p_run_mode = 'PURGE' THEN

			DELETE FROM XDP_ORDER_LINEITEM_DETS
				WHERE line_item_id = l_line_item.line_item_id;

			DELETE FROM XDP_LINE_RELATIONSHIPS
				WHERE line_item_id = l_line_item.line_item_id;

			DELETE FROM XDP_ORDER_LINE_ITEMS WHERE CURRENT OF c_line_item;
		END IF;
	    l_li_number := l_li_number+1;
	END LOOP;
    	RECORDS_PURGED_MSGS(l_li_number,'XDP_ORDER_LINE_ITEMS WHERE ORDER_ID = '
			||p_order_id,l_rec_name,0);
EXCEPTION
	WHEN OTHERS THEN
		PURGE_ERRORS(SUBSTR(SQLERRM, 1, 512),P_ABORT => TRUE);
END DELETE_LINE_ITEMS;

--
-- Internal procedure for deleting workflow items for an order
-- Name  DELETE_WF_ITEMS
--
-- This procedure will purge all workflow items that are connected to
-- the work item defined by the
--	WF_ITEM_TYPE AND WF_ITEM_KEY
-- in XDP_ORDER_HEADER table where order_id = p_order_id
--
-- A cursor is defined against WF_ITEMS table using connect by statement
--
-- Code reviewers:
-- 	would this risk of purging work items that are not belong to XDP????
--
PROCEDURE DELETE_WF_ITEMS
(
	p_order_id			IN VARCHAR2,
	p_run_mode			IN VARCHAR2
) IS
CURSOR c_wi(p_wi_type IN VARCHAR2,p_wi_key IN VARCHAR2) IS
	SELECT level,item_type,item_key
	  FROM WF_ITEMS
	 START WITH item_type = p_wi_type
           AND item_key = p_wi_key
    	CONNECT BY PRIOR item_key = parent_item_key
  	AND PRIOR item_type = parent_item_type;

l_wi_type	XDP_ORDER_HEADERS.WF_ITEM_TYPE%TYPE;
l_wi_key 	XDP_ORDER_HEADERS.WF_ITEM_KEY%TYPE;
l_counter	NUMBER := 0;
l_rec_name VARCHAR2(16) := 'XDP_FOUND_REC';
l_wi_name VARCHAR2(16) := 'XDP_FOUND_WI';

l_PType VARCHAR2(8);

l_mini_secs NUMBER := 0;

BEGIN
-- DO NOTHING IS FLAG IS FALSE
	IF (G_PURGE_WORK_FLOW = 'FALSE') THEN
		RETURN;
	END IF;

	IF(p_run_mode = 'PURGE') THEN
		l_rec_name := 'XDP_PURGE_REC';
		l_wi_name := 'XDP_PURGE_WI';
	END IF;

	IF p_order_id IS NULL THEN
		RETURN;
	END IF;

	l_mini_secs := DBMS_UTILITY.get_time;

	SELECT wf_item_type,
               wf_item_key
          INTO l_wi_type,l_wi_key
	  FROM XDP_ORDER_HEADERS
         WHERE ORDER_ID = p_order_id;

	IF SQL%NOTFOUND THEN
		RETURN;
	END IF;

    -- Purge all work items assocaited with an order
   	FOR l_wi in c_wi(l_wi_type,l_wi_key) LOOP

		IF ((bAudit = 'TRUE') AND (p_run_mode = 'PURGE')) or (p_run_mode = 'VERIFY') THEN
			RECORDS_PURGED_MSGS(1, 'WORKFLOW ITEM = '
					||l_wi.item_type || l_wi.item_key,1);
		END IF;

		IF (p_run_mode = 'PURGE') AND (l_wi.item_key IS NOT NULL) THEN
			SELECT persistence_type INTO l_PType
				FROM wf_item_types
				WHERE NAME = l_wi.item_type;

			IF SQL%NOTFOUND THEN
				RETURN;  -- DO NOTHING
			END IF;

			wf_purge.persistence_type := l_PType;
 			WF_PURGE.TOTAL(l_wi.item_type, l_wi.item_key, SYSDATE,FALSE);
			NULL;
		END IF;
		l_counter := l_counter + 1;
	END LOOP;
	RECORDS_PURGED_MSGS(l_counter, 'WF_ITEMS WHERE ORDER_ID = '
			||p_order_id,l_rec_name,0);
	G_Total_WK_TIME := G_Total_WK_TIME + DBMS_UTILITY.get_time - l_mini_secs;
EXCEPTION
	WHEN OTHERS THEN
		PURGE_ERRORS(P_MSG=>SUBSTR(SQLERRM, 1, 512),P_ABORT => TRUE);
END DELETE_WF_ITEMS;

-- Procedure XDP_PURGE_ORDER
--	Purge order for a given id
--
-- IN:
--   p_order_id   	- order id to be purged
--   p_time_from         - date from which data is purged
--   p_time_to           - date to which data is purged
--   p_run_mode	         - specify run mode when this API is called.--
--			 -	'PURGE', to purge data
--			 -	'VERIFY', to verify setting and print out data will be purged
--			 -	'CHECK', to check transactional data in the database
--   p_order_purge_mode  - indicate if messages whose orders still exist
--                       - in the database should be purged or not
--   x_purge_status	 - indicate if purge is success or not,
--			 - 	SUCCESS 	the order is or to be purged
--			 - 	FAIL		the order is not , or not to be purged
--			 -      EXCEPTION	Exception occured while purge this order
--			 -

PROCEDURE XDP_PURGE_ORDER
(
	p_order_id	     	IN  	NUMBER,
	p_time_from     	IN  	DATE,
	p_time_to       	IN  	DATE,
	p_run_mode		IN	VARCHAR2 DEFAULT 'VERIFY',
	p_purge_msg		IN 	BOOLEAN DEFAULT FALSE,
	x_purge_status		OUT NOCOPY     VARCHAR2
) IS
-- it might be a good idea to make this autonomous
-- so that it will share no rollback segment with the main
-- transaction context, hence, no persistent view
-- PRAGMA AUTONOMOUS_TRANSACTION
l_temp		NUMBER := 0;
l_order_deletable	VARCHAR2(6);
l_exception_counter	NUMBER := 0;
l_user_rollback		BOOLEAN := FALSE;
l_rec_name VARCHAR2(16) := 'XDP_FOUND_REC';
l_dummy number;

BEGIN
	SavePoint Order_Rollback;
	--
	-- to be sure that the order can be deleted
    	-- On exceptions, FALSE will be returned, a message will be logged
    	-- and committed to database
    	--
	IS_ORDER_DELETABLE(p_order_id,p_time_from,p_time_to,l_order_deletable);

	IF p_run_mode ='CHECK' THEN
		IF l_order_deletable = 'TRUE' THEN
			XDP_CHECK_ORDER(p_order_id);
		END IF;
   	ELSE

        --
    	-- To delete the order
        -- On exceptions, a message will be logged and committed to database
        -- carries on to next order
        --
		IF l_order_deletable = 'TRUE' THEN
			BEGIN

				-- Lock the record for update

	      		FND_MESSAGE.SET_NAME('XDP','XDP_PURGE_ORD');
        			FND_MESSAGE.SET_TOKEN('ORDER_ID',p_order_id);
				PURGE_ERRORS(FND_MESSAGE.GET);

       			SELECT 1 INTO l_dummy FROM XDP_ORDER_HEADERS
	              		WHERE order_id = p_order_id for update nowait;

				DELETE_LINE_ITEMS(p_order_id,p_run_mode);
	            	DELETE_WF_ITEMS(p_order_id,p_run_mode);

				IF ((bAudit = 'TRUE') AND (p_run_mode = 'PURGE')) or (p_run_mode = 'VERIFY') THEN
		        		SELECT COUNT(*) INTO l_temp FROM XDP_ORDER_BUNDLES
                       			WHERE order_id = p_order_id;

		        		RECORDS_PURGED_MSGS(l_temp,'XDP_ORDER_BUNDLES WHERE ORDER_ID = '
					||p_order_id,l_rec_name,0);
	        			SELECT COUNT(*) INTO l_temp FROM XDP_ORDER_RELATIONSHIPS
                       			WHERE order_id = p_order_id;
		        		RECORDS_PURGED_MSGS(l_temp,'XDP_ORDER_RELATIONSHIPS WHERE ORDER_ID = '
					||p_order_id,l_rec_name,0);
	        			SELECT COUNT(*) INTO l_temp FROM XDP_ORDER_PARAMETERS
                       			WHERE order_id = p_order_id;
		        		RECORDS_PURGED_MSGS(l_temp,'XDP_ORDER_PARAMETERS WHERE ORDER_ID = '
					||p_order_id,l_rec_name,0);

				-- If p_purge_msg is true, purge both internal and external
				-- messages associated with the order
				-- else, only purge internal messages which are identified
				-- the the protected flag in xnp_msg_type_b

					IF p_purge_msg THEN
   	                		SELECT COUNT(*) INTO l_temp FROM XNP_MSGS
           		       		WHERE order_id = p_order_id;
           			ELSE
                  			SELECT COUNT(*) INTO l_temp FROM XNP_MSGS
        	                		WHERE order_id = p_order_id
						AND msg_code IN
							(SELECT MSG_CODE FROM XNP_MSG_TYPES_B
								WHERE PROTECTED_FLAG='Y');
					END IF;

		        		RECORDS_PURGED_MSGS(l_temp,'XNP_MSGS WHERE ORDER_ID = '||p_order_id
					,l_rec_name,0);
		        		SELECT COUNT(*) INTO l_temp FROM XNP_CALLBACK_EVENTS
       		                	WHERE order_id = p_order_id;
		        		RECORDS_PURGED_MSGS(l_temp,'XNP_CALLBACK_EVENTS WHERE ORDER_ID = '
					||p_order_id ,l_rec_name,0);
	        			SELECT COUNT(*) INTO l_temp FROM XNP_TIMER_REGISTRY
	                        	WHERE order_id = p_order_id;
		        		RECORDS_PURGED_MSGS(l_temp,'XNP_TIMER_REGISTRY WHERE ORDER_ID = '
					||p_order_id ,l_rec_name,0);
					SELECT COUNT(*) INTO l_temp FROM XNP_SYNC_REGISTRATION
                       			WHERE order_id = p_order_id;
		        		RECORDS_PURGED_MSGS(l_temp,'XNP_SYNC_REGISTRATION WHERE ORDER_ID = '
					||p_order_id ,l_rec_name,0);
				END IF;

	        		IF p_run_mode = 'PURGE' THEN
		        		DELETE FROM XDP_ORDER_BUNDLES
                        		WHERE order_id = p_order_id;
		        		DELETE FROM XDP_ORDER_RELATIONSHIPS
               	        		WHERE order_id = p_order_id;
		        		DELETE FROM XDP_ORDER_PARAMETERS
                       			WHERE order_id = p_order_id;
--
--	if this flag is true, we will delete all messages associated with this order
--	else we will only delete internal messages that are associated with this order
--	This operation will not delete any messages whose order id field is null.
--
					IF p_purge_msg THEN
               					DELETE FROM XNP_MSGS
   		        			WHERE order_id = p_order_id;
       					ELSE
           					DELETE FROM XNP_MSGS
               					WHERE order_id = p_order_id
						AND msg_code IN
							(SELECT MSG_CODE FROM XNP_MSG_TYPES_B
							WHERE PROTECTED_FLAG='Y');
					END IF;

        				DELETE FROM XNP_CALLBACK_EVENTS
               				WHERE order_id = p_order_id;

	        			DELETE FROM XNP_TIMER_REGISTRY
	                		WHERE order_id = p_order_id;
					DELETE FROM XNP_SYNC_REGISTRATION
                  			WHERE order_id = p_order_id ;
	       				DELETE FROM XDP_ORDER_HEADERS
	               			WHERE order_id = p_order_id ;
--					COMMIT;
				END IF;
       	    		EXCEPTION
	           		WHEN OTHERS THEN
        	       			ROLLBACK TO Order_Rollback;
					x_purge_status := 'EXCEPTION';
	        	END;
		END IF;
	END IF ;

	IF l_order_deletable = 'TRUE' THEN
		x_purge_status := 'SUCCESS';
	ELSE
		x_purge_status := 'FAIL';
	END IF;

EXCEPTION
    WHEN OTHERS THEN
		ROLLBACK TO Order_Rollback;
		x_purge_status := 'EXCEPTION';
		x_purge_status := 'FAIL';
       	FND_MESSAGE.SET_NAME('XDP','XDP_PURGE_ERROR');
		FND_MESSAGE.SET_TOKEN('OBJECT','ORDER');
		FND_MESSAGE.SET_TOKEN('CONDITION','');
		PURGE_ERRORS(FND_MESSAGE.GET);
		PURGE_ERRORS(SUBSTR(SQLERRM, 1, 512));
END XDP_PURGE_ORDER;

PROCEDURE XDP_PURGE_ORDERS
(
	p_time_from     	IN  	DATE,
	p_time_to       	IN  	DATE,
	p_run_mode		IN	VARCHAR2 DEFAULT 'VERIFY',
	p_purge_msg		IN 	BOOLEAN DEFAULT FALSE,
     p_rollback_segment	IN 	VARCHAR2 DEFAULT NULL,
     x_orders_purged         OUT NOCOPY     NUMBER
) IS

--Date: 09 AUG 2006   Author: DPUTHIYE         Bug #:5446335
--This SQL should consider CANCEL_PROVISIONING_DATE for cancelled orders as well.
--Dependencies: None.
/* CURSOR c_order(p_time_from IN DATE,p_time_to IN DATE) IS
	SELECT ORDER_ID FROM XDP_ORDER_HEADERS
        WHERE STATUS_CODE IN ('SUCCESS','SUCCESS_WITH_OVERRIDE','ABORTED','CANCELED')
	   AND COMPLETION_DATE < p_time_to
	   AND COMPLETION_DATE > p_time_from; */

 CURSOR c_order(p_time_from IN DATE,p_time_to IN DATE) IS
	SELECT ORDER_ID FROM XDP_ORDER_HEADERS
        WHERE STATUS_CODE IN ('SUCCESS','SUCCESS_WITH_OVERRIDE','ABORTED','CANCELED')
	   AND NVL(COMPLETION_DATE, CANCEL_PROVISIONING_DATE) < p_time_to
	   AND NVL(COMPLETION_DATE, CANCEL_PROVISIONING_DATE) > p_time_from;

l_temp		NUMBER := 0;

l_order_id XDP_ORDER_HEADERS.ORDER_ID%TYPE;

l_order_deletable	VARCHAR2(6);
l_exception_counter	NUMBER := 0;
l_user_rollback	BOOLEAN := FALSE;
l_rec_name 		VARCHAR2(16) := 'XDP_FOUND_REC';

l_purge_status 	VARCHAR2(20);
l_counter 		NUMBER := 0;
--l_dummy 			NUMBER;
l_mini_secs 		NUMBER :=0;
BEGIN
   	PURGE_ERRORS('==== '||p_run_mode|| ' ORDERS ' ||' ===================');
	IF(p_run_mode = 'PURGE') THEN
		l_rec_name := 'XDP_PURGE_REC';
	END IF;

	IF p_run_mode ='CHECK' THEN
	        --Date: 09 AUG 2006   Author: DPUTHIYE         Bug #:5446335
		--This SQL should consider CANCEL_PROVISIONING_DATE for cancelled orders as well.
                --Dependencies: None.
		/* SELECT COUNT(*) INTO l_temp FROM XDP_ORDER_HEADERS
			WHERE STATUS_CODE IN ('SUCCESS','SUCCESS_WITH_OVERRIDE','ABORTED','CANCELED')
			AND COMPLETION_DATE < p_time_to
			AND COMPLETION_DATE > p_time_from; */

		SELECT COUNT(*) INTO l_temp FROM XDP_ORDER_HEADERS
		WHERE STATUS_CODE IN ('SUCCESS','SUCCESS_WITH_OVERRIDE','ABORTED','CANCELED')
		AND NVL(COMPLETION_DATE, CANCEL_PROVISIONING_DATE) < p_time_to
		AND NVL(COMPLETION_DATE, CANCEL_PROVISIONING_DATE) > p_time_from;

		IF l_temp = 0 THEN
	   		XDP_CHECK_ORDER(NULL);
		END IF;
	END IF;

--	l_user_rollback := USER_ROLLBACK_CTRL(p_rollback_segment);

	l_mini_secs := DBMS_UTILITY.get_time;
	G_Total_WK_TIME := 0;
	x_orders_purged :=0;
--
-- This loop is introduced so that when it is to purge orders,
-- we will close the select cursor after certain number of
-- deletions. The purpose of this method is to minize the impact of
-- the size of a rollback segment. Although c_order cursor is read only,
-- in order to maintain a persistent view, Oracle reads from rollback segment
-- if a block has been changed as the cursor is open.
--
	<<OUTER_LOOP>>
	LOOP
		-- REOPEN IT AFTER COMMIT
		l_counter := 0;

		OPEN c_order(p_time_from,p_time_to);
		<<INNER_LOOP>>
		LOOP
			-- open/reopen the cursor
			FETCH c_order INTO l_order_id;

	    		IF c_order%notfound THEN
				EXIT OUTER_LOOP;
		    	END IF;

			XDP_PURGE_ORDER(
				l_order_id,
				p_time_from,
				p_time_to,
				p_run_mode,
				p_purge_msg,
				l_purge_status
			);

			IF l_purge_status = 'SUCCESS' THEN
				x_orders_purged := x_orders_purged + 1;
				-- Reset exception counter
				l_exception_counter := 0;
			ELSIF l_purge_status = 'EXCEPTION' THEN
				l_exception_counter := l_exception_counter + 1;
				FND_MESSAGE.SET_NAME('XDP','XDP_PURGE_ERROR');
				FND_MESSAGE.SET_TOKEN('OBJECT','ORDER');
				FND_MESSAGE.SET_TOKEN('CONDITION','order_id ='|| l_order_id);
				PURGE_ERRORS(FND_MESSAGE.GET);
				PURGE_ERRORS(SUBSTR(SQLERRM, 1, 512));

			-- if exceptions continusly occurred for more than gl_max_exception
			-- then bubble up the exception and get out
				IF (l_exception_counter > g_max_exceptions) THEN
					PURGE_ERRORS(FND_MESSAGE.GET,p_abort=>TRUE);
				END IF;
			END IF;

--	This only applies when it is to purge, where deletions have occured
			IF (l_counter > g_max_rows_before_commit) AND (p_run_mode = 'PURGE') THEN
				PURGE_ERRORS(l_counter || ' orders purged, will reopen the order cursor');
				-- Reset counter and jump out the inner loop
				l_counter := 0;
				COMMIT;
				EXIT INNER_LOOP;
			END IF;
			l_counter := l_counter+1;
		END LOOP INNER_LOOP;

		-- if the cursor is open at this pointer, close it
		IF (c_order%ISOPEN) THEN
			CLOSE c_order;
		END IF;
	END LOOP OUTER_LOOP;
	RECORDS_PURGED_MSGS(x_orders_purged,'XDP_ORDER_HEADERS',l_rec_name,-1);
	l_mini_secs := DBMS_UTILITY.get_time - l_mini_secs;
	PURGE_ERRORS('Total '||l_mini_secs/100 || ' seconds used to purge orders');
	PURGE_ERRORS((G_Total_WK_TIME/100) || ' seconds used to purge workflow items for these orders');
	COMMIT;
EXCEPTION
	WHEN OTHERS THEN
       	FND_MESSAGE.SET_NAME('XDP','XDP_PURGE_ERROR');
		FND_MESSAGE.SET_TOKEN('OBJECT','ORDER');
		FND_MESSAGE.SET_TOKEN('CONDITION','');

		PURGE_ERRORS(FND_MESSAGE.GET,P_COMMIT => TRUE);
		PURGE_ERRORS(SUBSTR(SQLERRM, 1, 512));
		RAISE;
END XDP_PURGE_ORDERS;
--
-- Procedure XDP_PRUGE_TIMER
--	Purge runtime timers for a given message
--		timers associated with orders are purged with orders
--
PROCEDURE XDP_PRUGE_TIMER(p_msg_id IN NUMBER) IS
BEGIN
	DELETE FROM xnp_timer_registry WHERE timer_id = p_msg_id;
END XDP_PRUGE_TIMER;

-- Procedure XDP_PURGE_MESSAGES
--	Purge runtime messages from SFM
--
-- IN:
--   p_time_from         - date from which data is purged
--   p_time_to           - date to which data is purged
--   p_run_mode	         - specify run mode when this API is called.--
--			 -	'PURGE', to purge data
--			 -	'VERIFY', to verify setting and print out data will be purged
--			 -	'CHECK', to check transactional data in the database
--   p_order_purge_mode  - indicate if messages whose orders still exist
--                       - in the database should be purged or not

-- The assumption here is that
PROCEDURE XDP_PURGE_MESSAGES
(
     p_time_from         IN  	DATE,
     p_time_to           IN  	DATE,
     p_run_mode	         IN	VARCHAR2 DEFAULT 'PURGE',
     p_order_purge_mode  IN	BOOLEAN DEFAULT FALSE,
     p_rollback_segment	 IN 	VARCHAR2 DEFAULT NULL
) IS

-- delete all messages that are not associated with an order
-- 03/30/2001. Modified. Replaced CREATION_DATE with MSG_CREATION_DATE. rnyberg
CURSOR c_xnp_msgs_1 IS
	SELECT MSG_ID FROM XNP_MSGS M
    WHERE
        (M.MSG_STATUS IN ('PROCESSED','TIME_OUT'))
        AND MSG_CREATION_DATE < p_time_to
    	AND MSG_CREATION_DATE > p_time_from
    	FOR UPDATE OF MSG_ID NOWAIT;

-- 03/30/2001. Modified. Replaced CREATION_DATE with MSG_CREATION_DATE. rnyberg
CURSOR c_xnp_msgs_2 IS
	SELECT MSG_ID FROM XNP_MSGS M
    WHERE
        (M.MSG_STATUS IN ('PROCESSED','TIME_OUT'))
        AND MSG_CREATION_DATE < p_time_to
    	AND MSG_CREATION_DATE > p_time_from
        AND NOT Exists (SELECT ORDER_ID from xdp_order_headers where (order_id=m.order_id))
    	FOR UPDATE OF MSG_ID NOWAIT;

l_xnp_msg XNP_MSGS.MSG_ID%TYPE;

l_counter NUMBER := 0;
l_no_msgs NUMBER := 0;
l_temp NUMBER := 0;
l_user_rollback BOOLEAN := TRUE;

l_rec_name VARCHAR2(16) := 'XDP_FOUND_REC';

BEGIN
   	PURGE_ERRORS('==== '||p_run_mode|| ' Messages ' ||' ===================');
	IF(p_run_mode = 'CHECK') THEN
		IF(P_ORDER_PURGE_MODE) THEN
                -- 03/30/2001. Modified. Replaced CREATION_DATE with MSG_CREATION_DATE. rnyberg
        	SELECT COUNT(*) INTO l_no_msgs FROM XNP_MSGS
            WHERE
                MSG_STATUS IN ('PROCESSED','TIME_OUT')
                AND MSG_CREATION_DATE < p_time_to
            	AND MSG_CREATION_DATE > p_time_from;
        ELSE
        	SELECT COUNT(*) INTO l_no_msgs FROM XNP_MSGS M
            WHERE
                -- 03/30/2001. Modified. Replaced CREATION_DATE with MSG_CREATION_DATE. rnyberg
                MSG_STATUS IN ('PROCESSED','TIME_OUT')
                AND MSG_CREATION_DATE < p_time_to
            	AND MSG_CREATION_DATE > p_time_from
                AND NOT Exists (SELECT ORDER_ID from xdp_order_headers where (order_id=m.order_id));
        END IF;
		RECORDS_PURGED_MSGS(l_no_msgs,'XNP_MSGS',l_rec_name,-1);
		RETURN;
	END IF;

	IF(p_run_mode = 'PURGE') THEN
		l_rec_name := 'XDP_PURGE_REC';
	END IF;

	l_user_rollback := USER_ROLLBACK_CTRL(p_rollback_segment);
	-- purge messages that are not associated with an order
	l_counter := 0;
	<<OUTER_XNP_MSG>>
	LOOP
		SAVEPOINT MSG_RLBK;
		-- REOPEN IT AFTER COMMIT
		IF(P_ORDER_PURGE_MODE) THEN
	    		OPEN c_xnp_msgs_1;
        	ELSE
    			OPEN c_xnp_msgs_2;
	        END IF;
		<<INNER_XNP_MSG>>
		LOOP
	    		IF(P_ORDER_PURGE_MODE) THEN
				FETCH c_xnp_msgs_1 INTO l_xnp_msg;
	       		IF c_xnp_msgs_1%notfound THEN
    				EXIT OUTER_XNP_MSG; -- we are done
		      	END IF;

		      	IF p_run_mode = 'PURGE' THEN
                        XDP_PRUGE_TIMER(l_xnp_msg);

			     	DELETE FROM XNP_MSGS WHERE CURRENT OF c_xnp_msgs_1;
       			END IF;
		   	ELSE
	       		FETCH c_xnp_msgs_2 INTO l_xnp_msg;
	       		IF c_xnp_msgs_2%notfound THEN
					EXIT OUTER_XNP_MSG; -- we are done
		      	END IF;

				IF p_run_mode = 'PURGE' THEN
					XDP_PRUGE_TIMER(l_xnp_msg);
                    --
					DELETE FROM XNP_MSGS WHERE CURRENT OF c_xnp_msgs_2;
	       		END IF;
			END IF;

			l_no_msgs := l_no_msgs + 1;
			l_counter := l_counter+1;

			IF (l_counter > g_max_rows_before_commit) AND (NOT l_user_rollback) AND (p_run_mode = 'PURGE') THEN
				l_counter := 0;
				COMMIT;
				EXIT INNER_XNP_MSG; -- commit and reopen the cursor
			END IF;

		END LOOP INNER_XNP_MSG;

   		IF(P_ORDER_PURGE_MODE) THEN
    			IF (c_xnp_msgs_1%ISOPEN) THEN
	       		CLOSE c_xnp_msgs_1;
    		END IF;
        ELSE
    		IF (c_xnp_msgs_2%ISOPEN) THEN
	       		CLOSE c_xnp_msgs_2;
    		END IF;
        END IF;
	END LOOP OUTER_XNP_MSG;

	COMMIT;
	RECORDS_PURGED_MSGS(l_no_msgs,'XNP_MSGS',l_rec_name,-1);
EXCEPTION
	WHEN OTHERS THEN
		ROLLBACK TO MSG_RLBK;
	    	FND_MESSAGE.SET_NAME('XDP','XDP_PURGE_ERROR');
		FND_MESSAGE.SET_TOKEN('OBJECT','MESSAGES');
		FND_MESSAGE.SET_TOKEN('CONDITION',SQLERRM);
		PURGE_ERRORS(FND_MESSAGE.GET,P_COMMIT => TRUE);
		RAISE;
END XDP_PURGE_MESSAGES;

-- Procedure XDP_PURGE_SOA
--   Purge soa data from SFM
--
-- IN:
--   p_time_from         - date from which data is purged
--   p_time_to           - date to which data is purged
--   p_run_mode	         - specify run mode when this API is called.--
--			 -	'PURGE', to purge data
--			 -	'VERIFY', to verify setting and print out data will be purged
--			 -	'CHECK', to check transactional data in the database

PROCEDURE XDP_PURGE_SOA
(
	p_time_from     IN	DATE,
	p_time_to       IN	DATE,
	p_run_mode	IN	VARCHAR2 DEFAULT 'VERIFY',
     	p_rollback_segment		IN 	VARCHAR2 DEFAULT NULL
) IS
CURSOR c_xnp_soa(p_time_from IN DATE,p_time_to IN DATE) IS
	SELECT SV_SOA_ID FROM XNP_SV_SOA A, XNP_SV_STATUS_TYPES_B B
       		WHERE a.STATUS_TYPE_CODE = b.STATUS_TYPE_CODE
		AND b.PHASE_INDICATOR ='OLD'
		AND a.MODIFIED_DATE < p_time_to
		AND a.MODIFIED_DATE > p_time_from FOR UPDATE OF A.SV_SOA_ID NOWAIT;

l_xnp_soa_id XNP_SV_SOA.SV_SOA_ID%TYPE;
l_counter NUMBER := 0;
l_no_msgs NUMBER := 0;
l_temp NUMBER := 0;
l_user_rollback BOOLEAN := TRUE;
l_rec_name VARCHAR2(16) := 'XDP_FOUND_REC';
BEGIN
	SAVEPOINT SOA_RBKS;

   	PURGE_ERRORS('==== '||p_run_mode|| ' SOA ' ||' ===================');

	IF(p_run_mode = 'PURGE') THEN
		l_rec_name := 'XDP_PURGE_REC';
	END IF;
	IF(p_run_mode = 'PURGE') THEN
		l_rec_name := 'XDP_PURGE_REC';
	END IF;

	IF p_run_mode ='CHECK' THEN
		SELECT COUNT(*) INTO l_temp FROM XNP_SV_SOA A, XNP_SV_STATUS_TYPES_B B
       			WHERE a.STATUS_TYPE_CODE = b.STATUS_TYPE_CODE
			AND b.PHASE_INDICATOR ='OLD'
			AND a.MODIFIED_DATE < p_time_to
			AND a.MODIFIED_DATE > p_time_from;

		IF l_temp = 0 THEN
	   		XDP_CHECK_SOA(NULL,p_time_from,p_time_to);
			RECORDS_PURGED_MSGS(l_temp,'XNP_SV_SOA',l_rec_name,0);
			RETURN;
		END IF;
	END IF;

	l_user_rollback := USER_ROLLBACK_CTRL(p_rollback_segment);

	FOR l_xnp_soa in c_xnp_soa(p_time_from,p_time_to) LOOP
	   	PURGE_ERRORS('==== '||p_run_mode||' SOA '||l_xnp_soa.sv_soa_id  	||' ===================');
	   	IF p_run_mode = 'CHECK' THEN
			XDP_CHECK_SOA(l_xnp_soa.sv_soa_id);
	   	ELSE IF ((bAudit = 'TRUE') AND (p_run_mode = 'PURGE')) or (p_run_mode = 'VERIFY') THEN
       			SELECT COUNT(*) INTO l_temp FROM XNP_SV_EVENT_HISTORY
               		WHERE SV_SOA_ID = l_xnp_soa.sv_soa_id;
       			RECORDS_PURGED_MSGS(l_temp,'XNP_SV_EVENT_HISTORY WHERE SV_SOA_ID ='
				||l_xnp_soa.sv_soa_id,l_rec_name,0);
       			SELECT COUNT(*) INTO l_temp FROM XNP_SV_FAILURES
               		WHERE SV_SOA_ID = l_xnp_soa.sv_soa_id;
       			RECORDS_PURGED_MSGS(l_temp,'XNP_SV_FAILURES WHERE SV_SOA_ID ='
				||l_xnp_soa.sv_soa_id,l_rec_name,0);
			SELECT COUNT(*) INTO l_temp FROM XNP_SV_SOA_JN
               		WHERE SV_SOA_ID = l_xnp_soa.sv_soa_id;
        		RECORDS_PURGED_MSGS(l_temp,'XNP_SV_SOA_JN WHERE SV_SOA_ID ='
				||l_xnp_soa.sv_soa_id,l_rec_name,0);
		END IF;
        END IF;
    	END LOOP;

	l_counter := 0;
	IF p_run_mode = 'PURGE' THEN
		<<OUTER_XNP_SOA>>
		LOOP
			-- REOPEN IT AFTER COMMIT
			SAVEPOINT SOA_RBKS;
			BEGIN
				OPEN c_xnp_soa(p_time_from,p_time_to);
				<<INNER_XNP_SOA>>
				LOOP
					FETCH c_xnp_soa INTO l_xnp_soa_id;
					-- IF NO DATA FOUND, THEN EXIT
					IF c_xnp_soa%notfound THEN
						EXIT OUTER_XNP_SOA; -- we are done
					END IF;

					DELETE FROM XNP_SV_EVENT_HISTORY WHERE
						SV_SOA_ID = l_xnp_soa_id;
    	       				DELETE FROM XNP_SV_FAILURES WHERE
                				SV_SOA_ID = l_xnp_soa_id;
        	   			DELETE FROM XNP_SV_SOA_JN WHERE
                				SV_SOA_ID = l_xnp_soa_id;
					DELETE FROM XNP_SV_SOA WHERE CURRENT OF c_xnp_soa;
                			l_no_msgs := l_no_msgs +1;
                			l_counter := l_counter+1;
					IF (l_counter > g_max_rows_before_commit) AND (NOT l_user_rollback) THEN
						l_counter := 0;
						COMMIT;
						EXIT INNER_XNP_SOA; -- commit and reopen the cursor
					END IF;
				END LOOP INNER_XNP_SOA;
				IF (c_xnp_soa%ISOPEN) THEN
					CLOSE c_xnp_soa;
				END IF;
			EXCEPTION
				WHEN OTHERS THEN
					ROLLBACK TO SOA_RBKS;
			END;
		END LOOP OUTER_XNP_SOA;
	END IF;
	COMMIT;

	RECORDS_PURGED_MSGS(l_no_msgs,'XNP_SV_SOA',l_rec_name,-1);

	COMMIT;
EXCEPTION
	WHEN OTHERS THEN
		ROLLBACK;
		FND_MESSAGE.SET_NAME('XDP','XDP_PURGE_ERROR');
		FND_MESSAGE.SET_TOKEN('OBJECT','SOA');
		FND_MESSAGE.SET_TOKEN('CONDITION','');
		PURGE_ERRORS(FND_MESSAGE.GET,P_COMMIT => TRUE);
  		RAISE;
END XDP_PURGE_SOA;

-- Procedure XDP_PURGE_MISC
--   Purge debug, exception and misc workflow data from SFM
--
-- IN:
--   p_time_from	- date from which data is purged
--   p_time_to		- date to which data is purged
--   p_run_mode		- specify run mode when this API is called.
--			-for 'TRUE', the program will purge data
--			- for any other text, the program will only test
--			- the purge and log affected data into log files.
--			- if not specified, the program will purge data

PROCEDURE XDP_PURGE_MISC
(
	p_time_from     IN	DATE,
	p_time_to       IN	DATE,
	p_run_mode	IN	VARCHAR2 DEFAULT 'VERIFY',
   	p_rollback_segment	IN 	VARCHAR2 DEFAULT NULL
) IS

CURSOR c_xdp_debug(p_time_from IN DATE,p_time_to IN DATE) IS
    SELECT DEBUG_TYPE FROM XDP_DEBUG
    WHERE LAST_UPDATE_DATE < p_time_to
    AND LAST_UPDATE_DATE > p_time_from FOR UPDATE OF DEBUG_TYPE NOWAIT;

CURSOR c_xdp_errors(p_time_from IN DATE,p_time_to IN DATE) IS
    SELECT ERROR_ID FROM XDP_ERROR_LOG
    WHERE LAST_UPDATE_DATE < p_time_to
    AND LAST_UPDATE_DATE > p_time_from FOR UPDATE OF ERROR_ID NOWAIT;


CURSOR c_xnp_debug(p_time_from IN DATE,p_time_to IN DATE) IS
    SELECT DEBUG_ID FROM XNP_DEBUG
    WHERE LAST_UPDATE_DATE < p_time_to
    AND LAST_UPDATE_DATE > p_time_from FOR UPDATE OF DEBUG_ID NOWAIT;

l_xdp_debug_type  XDP_DEBUG.DEBUG_TYPE%TYPE;
l_xdp_error_id  XDP_ERROR_LOG.ERROR_ID%TYPE;
l_xnp_debug_id  XNP_DEBUG.DEBUG_ID%TYPE;

l_counter   NUMBER := 0;
l_no_reords NUMBER := 0;
l_user_rollback BOOLEAN := TRUE;

l_rec_name VARCHAR2(16) := 'XDP_FOUND_REC';

BEGIN
   	PURGE_ERRORS('==== '||p_run_mode|| ' Misc ' ||' ===================');

	IF(p_run_mode = 'PURGE') THEN
		l_rec_name := 'XDP_PURGE_REC';
	END IF;

	SELECT COUNT(*) INTO l_no_reords FROM XDP_DEBUG
		WHERE LAST_UPDATE_DATE < p_time_to
		AND LAST_UPDATE_DATE > p_time_from;

	RECORDS_PURGED_MSGS(l_no_reords,'XDP_DEBUG',l_rec_name,0);
	l_user_rollback := USER_ROLLBACK_CTRL(p_rollback_segment);
	IF p_run_mode = 'PURGE' THEN
		<<OUTER_LOOP>>
		LOOP
			-- REOPEN IT AFTER COMMIT
			OPEN c_xdp_debug(p_time_from,p_time_to);
			<<INNER_LOOP>>
			LOOP
				FETCH c_xdp_debug INTO l_xdp_debug_type;

					-- IF NO DATA FOUND, THEN EXIT
				IF c_xdp_debug%notfound THEN
					EXIT OUTER_LOOP;
				END IF;

        			DELETE FROM XDP_DEBUG WHERE CURRENT OF c_xdp_debug;

				l_counter:=l_counter+1;
				IF (l_counter > g_max_rows_before_commit) AND (NOT l_user_rollback) THEN
					l_counter := 0;
					COMMIT;
					EXIT INNER_LOOP;
				END IF;

			END LOOP INNER_LOOP;

			IF (c_xdp_debug%ISOPEN) THEN
				CLOSE c_xdp_debug;
			END IF;
		END LOOP OUTER_LOOP;
	END IF;

	COMMIT;

	SELECT COUNT(*) INTO l_no_reords FROM XDP_ERROR_LOG
		WHERE LAST_UPDATE_DATE < p_time_to
		AND LAST_UPDATE_DATE > p_time_from;

	RECORDS_PURGED_MSGS(l_no_reords,'XDP_ERROR_LOG',l_rec_name,-1);
	l_user_rollback := USER_ROLLBACK_CTRL(p_rollback_segment);
	l_counter := 0;

	IF p_run_mode = 'PURGE' THEN
		<<OUTER_ERROR>>
		LOOP

			-- REOPEN IT AFTER COMMIT
			OPEN c_xdp_errors(p_time_from,p_time_to);
			<<INNER_ERROR>>
				LOOP
					FETCH c_xdp_errors INTO l_xdp_error_id;
					-- IF NO DATA FOUND, THEN EXIT
					IF c_xdp_errors%notfound THEN
						EXIT OUTER_ERROR;
					END IF;

					DELETE FROM XDP_ERROR_LOG WHERE CURRENT OF c_xdp_errors;
					l_counter:=l_counter+1;
					IF (l_counter > g_max_rows_before_commit) AND (NOT l_user_rollback) THEN
						l_counter := 0;
						COMMIT;
						EXIT INNER_ERROR;
					END IF;
			END LOOP INNER_ERROR;
			IF (c_xdp_errors%ISOPEN) THEN
				CLOSE c_xdp_errors;
			END IF;
		END LOOP OUTER_ERROR;
	END IF;
	COMMIT;

	l_user_rollback := USER_ROLLBACK_CTRL(p_rollback_segment);

	SELECT COUNT(*) INTO l_no_reords FROM XNP_DEBUG
		WHERE LAST_UPDATE_DATE < p_time_to
		AND LAST_UPDATE_DATE > p_time_from;

	RECORDS_PURGED_MSGS(l_no_reords,'XNP_DEBUG',l_rec_name,-1);

	l_counter := 0;
	IF p_run_mode = 'PURGE' THEN
		<<OUTER_XNP_DEBUG>>
		LOOP
			-- REOPEN IT AFTER COMMIT
			OPEN c_xnp_debug(p_time_from,p_time_to);
			<<INNER_XNP_DEBUG>>
			LOOP
				FETCH c_xnp_debug INTO l_xnp_debug_id;
				-- IF NO DATA FOUND, THEN EXIT
				IF c_xnp_debug%notfound THEN
					EXIT OUTER_XNP_DEBUG; -- we are done
				END IF;

        			DELETE FROM XNP_DEBUG WHERE CURRENT OF c_xnp_debug;
					l_counter:=l_counter+1;
					IF (l_counter > g_max_rows_before_commit) AND (NOT l_user_rollback) THEN
						l_counter := 0;
						COMMIT;
						EXIT INNER_XNP_DEBUG; -- commit and reopen the cursor
					END IF;
			END LOOP INNER_XNP_DEBUG;
			IF (c_xnp_debug%ISOPEN) THEN
				CLOSE c_xnp_debug;
			END IF;
		END LOOP OUTER_XNP_DEBUG;
	END IF;
	COMMIT;

	l_user_rollback := USER_ROLLBACK_CTRL(p_rollback_segment);

	SELECT COUNT(*) INTO l_no_reords FROM WF_ITEMS
		WHERE ITEM_TYPE='XDPRECOV' AND END_DATE < p_time_to;

	RECORDS_PURGED_MSGS(l_no_reords,'WF_ITEMS XDPRECOV',l_rec_name,-1);


	IF p_run_mode = 'PURGE' THEN
		IF G_PURGE_WORK_FLOW = 'TRUE' THEN
			SELECT persistence_type INTO WF_PURGE.PERSISTENCE_TYPE
			FROM wf_item_types WHERE NAME = 'XDPRECOV';
			WF_PURGE.TOTAL('XDPRECOV', NULL, p_time_to);
		END IF;
	END IF;

	COMMIT;
EXCEPTION
	WHEN OTHERS THEN
	        ROLLBACK;
	       	FND_MESSAGE.SET_NAME('XDP','XDP_PURGE_ERROR');
		FND_MESSAGE.SET_TOKEN('OBJECT','MISC');
		PURGE_ERRORS(FND_MESSAGE.GET);
	RAISE;
END XDP_PURGE_MISC;

-- Procedure PURGE
--	Purge obsolete data from SFM
--
-- IN:
--   p_number_of_days
--                 	- number of days of data will be retained in SFM.
--   		   	- if not specified, g_min_number_of_days will be
--                 	- used if specified as null, or negative or less
--                 	- than g_min_number_of_days.
--   p_run_mode	   	- specify run mode when this API is called.--
--		   	- 	'PURGE', to purge data
--		   	-	'VERIFY', to verify setting and print out data will be purged
--		   	-	'CHECK', to check transactional data in the database
--   p_purge_data_set
--            	 	- indicate what data to be purged,
--                 	- eg. '[ORDER, SOA, MSGS, MISC]' will purge order, soa
--                 	- , messages and debug/error data
--                 	-    '[ORDER]' will only purge order data
--                 	- Default is null, means will not purge at all
--
--   p_purge_msg_flag
--                 	- indicate if messages whose orders still exist
--                 	- in the database should be purged or not
--
--   p_purge_order_flag
--            	 	- indicate if the external messages related to orders
--                 	- will be purged
--
--   p_max_exceptions	- number of continuous exceptions allowed before terminating a purge
--
--   p_log_mode		- indicate if how you would like to log messages for
--			- purging operation. Available option TERSE and VERBOSE
--			-- any other words will result no message logged
--
--   p_rollback_segment	- indicate what rollback segment should be used. If null, default
--			- rollback segment will be used
-- OUT:
--   ERRBUF	     - as required by concurrent manager
--   RETCODE	     - as required by concurrent manager
--
--
-- Note: for the concurrent manager, exceptions will be silenced
-- with proper messages returned in ERRBUF. RETCODE is 2 for
-- exception errors
--

PROCEDURE PURGE
(
     ERRBUF	            	OUT NOCOPY	VARCHAR2,
     RETCODE	        	OUT NOCOPY	VARCHAR2,
     p_number_of_days		IN	NUMBER   DEFAULT g_min_number_of_days,
     p_run_mode			IN	VARCHAR2 DEFAULT 'VERIFY',
     p_purge_data_set		IN 	VARCHAR2 DEFAULT '[ORDER,SOA,MSGS,MISC]',
     p_purge_msg_flag		IN 	VARCHAR2 DEFAULT 'TRUE',
     p_purge_order_flag		IN 	VARCHAR2 DEFAULT 'TRUE',
     p_max_exceptions		IN 	NUMBER   DEFAULT 10,
     p_log_mode			IN 	VARCHAR2 DEFAULT 'TERSE',
     p_rollback_segment		IN 	VARCHAR2 DEFAULT NULL
) IS

l_time_to  DATE;
l_time_from  DATE;
l_purge_order_with_msg BOOLEAN;
l_purge_msgs_regardless BOOLEAN;
l_orders_purged NUMBER;
l_rollback_segment VARCHAR2(200);
BEGIN
	l_purge_order_with_msg := p_purge_order_flag = 'TRUE';
	l_purge_msgs_regardless := p_purge_msg_flag = 'TRUE';
     g_max_rows_before_commit := FND_PROFILE.VALUE('XDP_THRESHOLD_PURGE_TRANSACTION');
	IF (g_max_rows_before_commit IS NULL) THEN
		g_max_rows_before_commit := 5000;
	END IF;

	IF (g_max_rows_before_commit < 1) THEN
		g_max_rows_before_commit := 10;
	END IF;

	--
	-- In case value is assigned to null
	-- It is not likely that user would have a rollback segment called null
	--
	l_rollback_segment := p_rollback_segment;
	IF l_rollback_segment IS NOT NULL THEN
		IF l_rollback_segment = 'NULL' THEN
			l_rollback_segment := NULL;
		END IF;
	END IF;
--
-- This is a global value for this module. It is used to determine what information
-- will be logged.
--
	IF p_log_mode = 'TERSE' THEN
		g_debug_level := 1;
	ELSIF p_log_mode = 'VERBOSE' THEN
		g_debug_level := 4;
	ELSE
		g_debug_level := 0;  -- Do not log anything
	END IF;

	g_max_exceptions := p_max_exceptions;

--
-- Only CHECK, PURGE or VERIFY are legal values for p_run_mode. If not, return an error
--
	IF (p_run_mode <> 'CHECK') AND (p_run_mode <> 'PURGE') AND
	   (p_run_mode <> 'VERIFY')
	THEN
		FND_MESSAGE.SET_NAME('XDP','XDP_PURGE_ERROR');
		FND_MESSAGE.SET_TOKEN('OBJECT','PURGE');
		FND_MESSAGE.SET_TOKEN('CONDITION','p_run_mode ='||p_run_mode);
        	RETCODE := 2;
        	ERRBUF := FND_MESSAGE.GET;
		PURGE_ERRORS(P_MSG => ERRBUF);
		RETURN;
	END IF;
--
-- For concurrent manager, do not use DBMS_OUTPUT
-- Otherwise, use dbms_ouptut with one meg buffer
-- This option is not available for customers.
--
	IF (g_purge_method <> 'CM') THEN
		-- DBMS_OUTPUT.ENABLE(1000000);
		NULL;
	END IF;

-- set the from time to a very old date
	l_time_from := to_date('01-01-1900','mm-dd-yyyy');

	IF (p_number_of_days IS NULL) OR
            (p_number_of_days < g_min_number_of_days )
	THEN
		l_time_to := SYSDATE - g_min_number_of_days;
	ELSE
		l_time_to := SYSDATE - p_number_of_days;
	END IF;

	FND_MESSAGE.SET_NAME('XDP','XDP_PURGE_PROCESS');

--default time format will be used to convert time string

	FND_MESSAGE.SET_TOKEN('DATE_FROM',TO_CHAR(l_time_from,'MM-DD-YYYY HH:MI:SS'));
	FND_MESSAGE.SET_TOKEN('DATE_TO',TO_CHAR(l_time_to,'MM-DD-YYYY HH:MI:SS'));
	PURGE_ERRORS(P_MSG=>FND_MESSAGE.GET);
--
-- By default, we will not manage workflow runtime data.
-- There is a performance hit if this flag is turned on. It is
-- better for performance to purge workflow using workflow purging
-- utility than through this purge function. However, the option
-- is here if that is required.
--
 	IF INSTR(p_purge_data_set,'ORDER_WITH_WF') <> 0 THEN
		G_PURGE_WORK_FLOW := 'TRUE';
   	END IF;


 	IF INSTR(p_purge_data_set,'ORDER') <> 0 THEN
		XDP_PURGE_ORDERS(l_time_from,l_time_to,p_run_mode,
			l_purge_order_with_msg,
			l_rollback_segment,l_orders_purged);

		RECORDS_PURGED_MSGS(l_orders_purged,'XDP_ORDER_HEADERS','ORDER',-1);
   	END IF;

   	IF INSTR(p_purge_data_set,'SOA') <> 0 THEN
   		XDP_PURGE_SOA(l_time_from,l_time_to,p_run_mode,l_rollback_segment);
   	END IF;

  	IF INSTR(p_purge_data_set,'MSG') <> 0 THEN
       		XDP_PURGE_MESSAGES(
			l_time_from,l_time_to,p_run_mode,
			l_purge_msgs_regardless,
			l_rollback_segment);
   	END IF;

   	IF INSTR(p_purge_data_set,'MISC') <> 0 THEN
       		XDP_PURGE_MISC(l_time_from,l_time_to,p_run_mode,l_rollback_segment);
   	END IF;

   	RETCODE := 0;
   	ERRBUF := 'Success';
   	COMMIT;
EXCEPTION
	WHEN OTHERS THEN
		ROLLBACK;
	RETCODE := 2;
	FND_MESSAGE.SET_NAME('XDP','XDP_PURGE_ERROR');
	FND_MESSAGE.SET_TOKEN('OBJECT','PURGE');
	FND_MESSAGE.SET_TOKEN('CONDITION',SQLERRM);
     ERRBUF := FND_MESSAGE.GET;
--	PURGE_ERRORS(P_MSG => ERRBUF,P_COMMIT => TRUE);
END PURGE;

END XDP_PURGE;


/
