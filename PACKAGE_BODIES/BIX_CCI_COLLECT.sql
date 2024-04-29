--------------------------------------------------------
--  DDL for Package Body BIX_CCI_COLLECT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIX_CCI_COLLECT" AS
/* $Header: BIXCCIVB.pls 115.30 2003/01/10 00:31:33 achanda noship $ */
PROCEDURE WRITE_LOG(p_msg IN VARCHAR2, p_proc_name IN VARCHAR2);

PROCEDURE COLLATE_CALLS(p_start_date IN DATE,
                                   p_end_date   IN DATE)
AS
  l_wrap_time NUMBER;
  l_queue_segment CHAR := NULL;

  CURSOR all_calls IS
  SELECT media_id,
         media_item_type,
         media_item_ref,
         media_data,
         DECODE(media_item_type,'Telephony, Inbound','INBOUND',NULL) direction,
         start_date_time,
         end_date_time,
         source_id,
         DECODE(media_abandon_flag,'Y','ABANDON',
			 DECODE(media_transferred_flag,'Y','TRANSFER',NULL)) interaction_subtype
  FROM   jtf_ih_media_items
  WHERE  start_date_time  between p_start_date and p_end_date
  and active = 'N';

  CURSOR c_milcs (cv_ih_mi_id NUMBER) IS
  SELECT
      ih_milcs.DURATION,
      ih_milcs_ty.MILCS_CODE,
	 ih_milcs.HANDLER_ID,
	 ih_milcs.RESOURCE_ID,
	 DECODE(ih_milcs_ty.MILCS_CODE,'IN_QUEUE',1,'WITH_AGENT',2) segment_order
  FROM
      JTF_IH_MEDIA_ITEMS           ih_mitem,
      JTF_IH_MEDIA_ITEM_LC_SEGS    ih_milcs,
      JTF_IH_MEDIA_ITM_LC_SEG_TYS  ih_milcs_ty
    WHERE
      (ih_mitem.MEDIA_ID = cv_ih_mi_id) and
      (ih_mitem.MEDIA_ID = ih_milcs.MEDIA_ID) and
      (ih_milcs.MILCS_TYPE_ID = ih_milcs_ty.MILCS_TYPE_ID)
	 order by segment_order;
/*
  CURSOR get_wrap_time(p_media_id NUMBER) IS
  SELECT sum((act.end_date_time - act.start_date_time) * 24 * 3600) wrap_time
  FROM   jtf_ih_activities act, jtf_ih_action_items_vl actitems
  WHERE  act.media_id = p_media_id
  AND    act.action_item_id = actitems.action_item_id
  AND    actitems.action_item = 'Wrapup';
*/

  CURSOR get_wrap_time(p_media_id NUMBER,p_resource_id NUMBER) IS
  SELECT sum((int.end_date_time - seg.end_date_time) * 24 * 3600) wrap_time
  FROM   jtf_ih_interactions int, jtf_ih_media_item_lc_segs seg, jtf_ih_media_itm_lc_seg_tys tys
  WHERE  int.productive_time_amount = p_media_id
  AND    int.resource_id = p_resource_id
  AND    seg.media_id = p_media_id
  AND    seg.resource_id = p_resource_id
  AND    tys.milcs_type_id = seg.milcs_type_id
  AND    tys.milcs_code = 'WITH_AGENT'
  AND    int.end_date_time > seg.end_date_time;

BEGIN

	   DELETE from BIX_INTERACTIONS;
       --WHERE  start_ts between p_start_date and p_end_date;


   FOR act IN all_calls LOOP

   l_queue_segment := NULL;

         INSERT INTO BIX_INTERACTIONS
   		(
       	INTERACTIONS_ID,
      	START_TS,
         	COMPLETED_TS,
         	MEDIA_ITEM_TYPE,
         	MEDIA_ITEM_REF,
         	INTERACTION_TYPE,
         	INTERACTION_SUBTYPE,
	    	RESOURCE_ID,
	    	INTERACTION_CENTER_ID
        	)
       	VALUES
      	(
      	act.media_id,
          act.START_DATE_TIME,
     	act.END_DATE_TIME,
          act.MEDIA_ITEM_TYPE,
      	act.MEDIA_ITEM_REF,
      	act.DIRECTION,
      	act.INTERACTION_SUBTYPE,
      	'-1',
 	act.source_id
      	);

     IF ( act.MEDIA_ID IS NOT NULL )
     THEN

      FOR milcs IN c_milcs( act.MEDIA_ID ) LOOP

          IF (milcs.MILCS_CODE = 'IVR') THEN

            UPDATE BIX_INTERACTIONS
            SET IVR_TIME = milcs.DURATION
            WHERE INTERACTIONS_ID = act.media_id
		  AND resource_id = -1;

          ELSIF (UPPER(milcs.MILCS_CODE) = 'ROUTING') THEN

            UPDATE BIX_INTERACTIONS
            SET ROUTE_TIME = milcs.DURATION
            WHERE INTERACTIONS_ID = act.media_id
		  AND resource_id = -1;

          ELSIF (milcs.MILCS_CODE = 'IN_QUEUE') THEN

		  l_queue_segment := 'T';

            UPDATE BIX_INTERACTIONS
            SET PARTY_WAIT_TIME = milcs.DURATION,USER_ATTRIBUTE1 = 'T'
            WHERE INTERACTIONS_ID = act.media_id
		  AND  resource_id = -1;

          ELSIF (milcs.MILCS_CODE = 'WITH_AGENT') THEN

          IF ( l_queue_segment = 'T') THEN

           l_wrap_time := 0;

           FOR wrapdata in get_wrap_time(act.MEDIA_ID,milcs.resource_id) LOOP
              l_wrap_time := wrapdata.wrap_time;
           END LOOP;

     	 -- if wrap time is undefined or null set it to 0

     	 IF l_wrap_time is NULL THEN
     	    l_wrap_time := 0;
           END IF;

    -- multiple agents can be involved in same call. Insert separate row for each agent in the interface
    -- table

         INSERT INTO BIX_INTERACTIONS
         (
         INTERACTIONS_ID,
         START_TS,
         COMPLETED_TS,
         MEDIA_ITEM_TYPE,
         MEDIA_ITEM_REF,
         INTERACTION_TYPE,
	 RESOURCE_ID,
	 HANDLER_ID,
	 INTERACTION_CENTER_ID,
	 WRAP_TIME,
	 TALK_TIME,
	 USER_ATTRIBUTE2
         )
         VALUES
         (
      	act.media_id,
      	act.START_DATE_TIME,
      	act.END_DATE_TIME,
      	act.MEDIA_ITEM_TYPE,
      	act.MEDIA_ITEM_REF,
      	act.DIRECTION,
      	milcs.resource_id,
 	milcs.HANDLER_ID,
 	act.source_id,
 	l_wrap_time,
 	milcs.duration,
	DECODE(l_queue_segment,'T','T')
          );
        END IF;

     END IF;  -- End of life cycle segment IF statement.

    END LOOP; -- end of life cycle segment loop

  END IF; -- end of IF act.media_id is NOT NULL

 END LOOP; -- End of media loop

 EXCEPTION
  WHEN OTHERS THEN
    write_log('Error: '||sqlerrm,' POPULATE_BIX_SUM_GRP_CLS');
    ROLLBACK;
    RAISE;
END COLLATE_CALLS;

PROCEDURE COLLECT_CCI_DATA( errbuf out nocopy varchar2,
					   retcode out nocopy varchar2,
					   p_start_date IN varchar2,
					   p_end_date   IN varchar2)
  AS

  no_messages exception;
  pragma exception_init (no_messages, -25228);
  l_start_date     DATE;
  l_end_date       DATE;

  l_ih_interaction_id  NUMBER(15,0);
  l_num_interactions NUMBER;

  l_b_remove  BOOLEAN;

  l_num_processed  PLS_INTEGER   := 0;
  l_num_skipped    PLS_INTEGER := 0;
  l_num_missing    PLS_INTEGER := 0;

  l_start_secs  NUMBER;
BEGIN
	 l_start_date := to_date(p_start_date, 'YYYY/MM/DD HH24:MI:SS');
      l_end_date := to_date(p_end_date, 'YYYY/MM/DD HH24:MI:SS');
	 -- defaults for request set program
	-- 	default start date to end date -1 if the dates are equal
	 IF (l_start_date = l_end_date) THEN
		l_start_date := l_end_date - 1;
      END IF;

	 COLLATE_CALLS(l_start_date, l_end_date);

	 COMMIT;
   EXCEPTION
	 WHEN OTHERS THEN
	    ROLLBACK;
	    write_log('Error:' || sqlerrm, 'BIX_CCI_COLLECT.COLLECT_CCI_DATA');
         RAISE;
END COLLECT_CCI_DATA;

PROCEDURE COLLECT_CCI_DATA(p_start_date IN VARCHAR2,
					  p_end_date   IN VARCHAR2)
AS
  l_ih_interaction_id  NUMBER(15,0);
  l_num_interactions NUMBER;
  l_start_date     DATE;
  l_end_date       DATE;
BEGIN
      l_start_date := to_date(p_start_date, 'YYYY/MM/DD HH24:MI:SS');
      l_end_date := to_date(p_end_date, 'YYYY/MM/DD HH24:MI:SS');

	 COLLATE_CALLS(l_start_date, l_end_date);

	 COMMIT;
   EXCEPTION
	 WHEN OTHERS THEN
	    ROLLBACK;
	    write_log('Error:' || sqlerrm, 'BIX_CCI_COLLECT.COLLECT_CCI_DATA');
         RAISE;
END COLLECT_CCI_DATA;

PROCEDURE WRITE_LOG(p_msg VARCHAR2, p_proc_name VARCHAR2) IS
BEGIN
    FND_FILE.PUT_LINE(fnd_file.log,'Load Interactions Log - ' || p_msg || ': '|| p_proc_name);
EXCEPTION
WHEN OTHERS THEN
RAISE;
END WRITE_LOG;

END BIX_CCI_COLLECT;

/
