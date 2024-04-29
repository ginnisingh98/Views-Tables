--------------------------------------------------------
--  DDL for Package Body WMS_TASK_SKIPPED
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_TASK_SKIPPED" AS
--/* $Header: WMSSKIPB.pls 120.2 2006/10/06 19:55:27 mchemban noship $ */


PROCEDURE mydebug(msg in varchar2)
  IS
     l_msg VARCHAR2(5100);
     l_ts VARCHAR2(30);
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   select to_char(sysdate,'MM/DD/YYYY HH:MM:SS') INTO l_ts from dual;
   l_msg:=l_ts||'  '||msg;


   inv_mobile_helper_functions.tracelog
     (p_err_msg => l_msg,
      p_module => 'wms_skip_task',
      p_level => 4);

   -- dbms_output.put_line(l_msg);

   null;
END;



PROCEDURE skip_task_adjustments
  (x_return_status       OUT   NOCOPY VARCHAR2,
   x_msg_count           OUT   NOCOPY NUMBER,
   x_msg_data            OUT   NOCOPY VARCHAR2,
   p_sign_on_emp_id      IN NUMBER,
   p_sign_on_org_id      IN NUMBER,
   p_task_id             IN NUMBER,
   p_wms_task_type       IN NUMBER)



  IS
     PRAGMA AUTONOMOUS_TRANSACTION;
     l_emp_id                 NUMBER;
     l_org_id                 NUMBER;
     l_task_id                NUMBER;
     l_sequence               NUMBER;
     l_inventory_item_id      NUMBER;
     l_last_updated_by   wms_dispatched_tasks.last_updated_by%TYPE;
     l_created_by    wms_dispatched_tasks.created_by%TYPE;
     l_progress               VARCHAR2(10);

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   l_progress := '10';
   SAVEPOINT  sp_skip_task_adjustments;
   l_emp_id := p_sign_on_emp_id ;
   l_org_id := p_sign_on_org_id;
   l_task_id := p_task_id;
   l_last_updated_by := FND_GLOBAL.user_id; ---*************** AFSCGBLS.pls

   IF (l_debug = 1) THEN
      mydebug('WMSSKIPB: value of EMP_ID '|| l_emp_id  );
      mydebug('WMSSKIPB: value of ORG_ID '|| l_org_id  );
      mydebug('WMSSKIPB: value of Transaction_temp_id '||  l_task_id );
      mydebug('WMSSKIPB: value of last_ypdated_by '||  l_last_updated_by );
   END IF;

   l_progress := '20';

   SELECT wms_exceptions_s.NEXTVAL INTO l_sequence from dual;

   IF (l_debug = 1) THEN
      mydebug('l_sequence: ' || l_sequence);
   END IF;

   BEGIN
    /* Bug#5563901.Replaced wms_dispatchable_tasks_v by a query from MMTT and MCCE */
        SELECT t.inventory_item_id, w.created_by
	INTO l_inventory_item_id, l_created_by
	FROM wms_dispatched_tasks w ,
           (SELECT mmtt.transaction_temp_id task_id,  mmtt.wms_task_type wms_task_type_id,
	           mmtt.inventory_item_id
	    FROM mtl_material_transactions_temp mmtt
            WHERE mmtt.transaction_temp_id =  l_task_id
	    AND mmtt.wms_task_type IS NOT NULL AND mmtt.transaction_status = 2
            UNION ALL
            SELECT mcce.cycle_count_entry_id task_id, 3 wms_task_type_id,mcce.inventory_item_id
            FROM mtl_cycle_count_entries mcce
	    WHERE mcce.cycle_count_entry_id=l_task_id
	    AND entry_status_code IN (1,3)  AND NVL(export_flag, 2) = 2 ) t
	WHERE t.task_id =  l_task_id
	AND t.wms_task_type_id = p_wms_task_type
	AND t.task_id = w.transaction_temp_id
	AND t.wms_task_type_id = w.task_type;

   EXCEPTION
      WHEN no_data_found THEN
      IF (l_debug = 1) THEN
        mydebug('No WDT line for that MMTT/MCCE');
      END IF;
      RAISE FND_API.g_exc_error;
   END;
   l_progress := '30';
   IF (l_debug = 1) THEN
      mydebug('WMSSKIPB: value of  l_inventory_item_id ' || l_inventory_item_id);
      mydebug('Before inserting into WMS_exception');
   END IF;

   INSERT INTO wms_exceptions(
         TASK_ID,
         SEQUENCE_NUMBER,
         ORGANIZATION_ID,
         INVENTORY_ITEM_ID,
         PERSON_ID,
         EFFECTIVE_START_DATE,
         EFFECTIVE_END_DATE  ,
         DISCREPANCY_TYPE,
         LOT_NUMBER,
         LAST_UPDATE_DATE,
         LAST_UPDATED_BY,
         CREATION_DATE,
         created_by,
         wms_task_type
         )
     VALUES( l_task_id,
      l_sequence,
      l_org_id,
      l_inventory_item_id,
      l_emp_id,
      Sysdate,
      Sysdate,
      1,
      -999,
      Sysdate,
      l_last_updated_by,
      Sysdate,
      l_created_by,
      p_wms_task_type
      );

   IF (l_debug = 1) THEN
      mydebug('After inserting into WMS_exception');
   END IF;
   l_progress := '40';

   IF (l_debug = 1) THEN
      mydebug('Before  inserting into WMS_skip_task_exceptions');
   END IF;

   INSERT INTO wms_skip_task_exceptions(
     TASK_ID,
     SEQUENCE_NUMBER,
     ORGANIZATION_ID,
     INVENTORY_ITEM_ID,
     PERSON_ID,
     EFFECTIVE_START_DATE,
     EFFECTIVE_END_DATE  ,
     DISCREPANCY_TYPE,
     LOT_NUMBER,
     LAST_UPDATE_DATE,
     LAST_UPDATED_BY,
     CREATION_DATE,
     created_by,
     wms_task_type
     )
     VALUES( l_task_id,
      l_sequence,
      l_org_id,
      l_inventory_item_id,
      l_emp_id,
      Sysdate,
      Sysdate,
      3,
      -999,
      Sysdate,
      l_last_updated_by,
      Sysdate,
      l_created_by,
      p_wms_task_type
      );

   IF (l_debug = 1) THEN
      mydebug('After  inserting into WMS_skip_task_exceptions');
      mydebug('Before  Deleting from wms_dispatched_task');
   END IF;
   l_progress := '50';

   DELETE FROM wms_dispatched_tasks
     WHERE transaction_temp_id = l_task_id AND
     task_type = p_wms_task_type;
   IF (l_debug = 1) THEN
      mydebug('After  Deleting from  wms_dispatched_task');
   END IF;
   l_progress := '60';

   x_return_status:=FND_API.g_ret_sts_success;

   COMMIT;
   IF (l_debug = 1) THEN
      mydebug(x_return_status);
   END IF;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO  sp_skip_task_adjustments;
      x_return_status:=FND_API.G_RET_STS_ERROR;
       fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
      );

   WHEN OTHERS THEN
      ROLLBACK TO  sp_skip_task_adjustments;
      x_return_status:=FND_API.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get
 (  p_count  => x_msg_count,
           p_data   => x_msg_data
    );

      IF SQLCODE IS NOT NULL THEN
  FND_MESSAGE.set_name('WMS', 'WMS_SKIP_TASK_ERROR');
  fnd_message.set_token ('SQL_CODE',SQLCODE);
  fnd_msg_pub.ADD;
      END IF;


END skip_task_adjustments;




END wms_task_skipped;

/
