--------------------------------------------------------
--  DDL for Package Body INV_TABLE_LOCK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_TABLE_LOCK_PVT" AS
/* $Header: INVLOCKB.pls 120.6.12010000.2 2009/05/15 22:35:43 musinha ship $ */

 FUNCTION lock_onhand_records (
          p_organization_id   IN NUMBER
        , p_inventory_item_id IN NUMBER
        , p_revision          IN VARCHAR2
        , p_lot               IN VARCHAR2
        , p_subinventory      IN VARCHAR2
        , p_locator           IN VARCHAR2
	      , p_issue_receipt     IN NUMBER
        , p_header_id         IN NUMBER) RETURN BOOLEAN IS
   l_lock_handle VARCHAR2(128);
   l_lock_name   VARCHAR2(2000);
   l_status NUMBER;
   l_neg_exists NUMBER;
   l_sessionid NUMBER;
   l_debug     NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
 BEGIN
   l_status := 9;
   l_lock_name := 'INV_MOQ_' || p_organization_id   || '_' ||
                                p_inventory_item_id || '_' ||
                                p_revision          || '_' ||
                                p_lot               || '_' ||
				p_subinventory      || '_' ||
                                p_locator;
   if (p_issue_receipt = 0) then
      -- Receipt 0 Issue 1
      SELECT count(1) into l_neg_exists
      FROM mtl_onhand_quantities_detail
     WHERE organization_id = p_organization_id
       AND inventory_item_id = p_inventory_item_id
       AND subinventory_code like p_subinventory
       AND nvl(lot_number,'@@@') like nvl(p_lot,'@@@')
       AND nvl(revision,'@@@') like nvl(p_revision,'@@@')
       AND nvl(locator_id,-999) = nvl(p_locator,-999)
       AND primary_transaction_quantity < 0
       AND rownum < 2;
   end if; -- Receipt part

   if ((p_issue_receipt = 0 AND l_neg_exists > 0)
      OR p_issue_receipt = 1) then
         get_lock_handle(p_header_id,l_lock_name,l_lock_handle);

/*	 select USERENV('SESSIONID') into l_sessionid from dual;
	 inv_log_util.trace('Session is.. ' ||l_sessionid , 'INV_TABLE_LOCK_PVT', 9);  */

         IF (l_debug = 1 ) THEN /* Bug#5401181*/
	   inv_log_util.trace('Lock Name is...:' ||l_lock_name , 'INV_TABLE_LOCK_PVT', 9);
	   inv_log_util.trace('Lock Handle is...:' ||l_lock_handle , 'INV_TABLE_LOCK_PVT', 9);
         END IF;

         l_status := dbms_lock.request(
         lockhandle        => l_lock_handle
        ,lockmode          => dbms_lock.x_mode
        ,timeout           => dbms_lock.maxwait
        ,release_on_commit => TRUE);
   end if;
   -- l_status = 4.No need to insert into temp table when lock is already
   -- owned by this session.it will become duplicate entry if we insert
   -- and release lock may fail in this case for the second time.

   -- moving the insert stmt to the below procedure.So that we can keep the
   -- lock handle till the end.Otherewise any commit or rollback will remove
   -- the data in temp table.
/*     if (l_status = 0) then
        insert into mtl_onhand_lock_temp(LOCK_HANDLE) values(l_lock_handle);
     end if; */
    if (l_status <> 0 AND l_status <> 4) then
      --Bug 6520517, changed AND to OR to avoid deadlock
      if (l_status = 1 OR l_status = 2) then
         RETURN FALSE;
      end if;
    end if;
  return TRUE;
  EXCEPTION
     WHEN OTHERS THEN
       return FALSE;
 END;

 PROCEDURE get_lock_handle (
          p_header_id   IN         NUMBER
        , p_lock_name   IN         VARCHAR2
        , x_lock_handle OUT NOCOPY VARCHAR2) IS
   PRAGMA AUTONOMOUS_TRANSACTION;
 BEGIN
   dbms_lock.allocate_unique(
         lockname       => p_lock_name
       , lockhandle     => x_lock_handle);
   INSERT INTO mtl_onhand_lock_temp(
         lock_handle
       , header_id)
   VALUES (
         x_lock_handle
       , p_header_id);
   COMMIT;
 END get_lock_handle;

 -- Bug 6636261: Acquiring lock for a row in MLN
 PROCEDURE lock_lot_record ( p_organization_id   IN NUMBER
                            ,p_inventory_item_id IN NUMBER
                            ,p_lot               IN VARCHAR2 ) IS

    x_lock_handle VARCHAR2(128);
    l_lock_name   VARCHAR2(2000);
    l_status      NUMBER;
 BEGIN
     l_lock_name := 'INV_MLN_' || p_organization_id || '_' || p_inventory_item_id || '_' || p_lot;

     get_lot_lock_handle( l_lock_name, x_lock_handle);

     l_status := dbms_lock.request(
         lockhandle        => x_lock_handle
        ,lockmode          => dbms_lock.x_mode
        ,timeout           => dbms_lock.maxwait
        ,release_on_commit => TRUE);
 END;

 -- Bug 6636261: Acquiring lock handle for a row in MLN
 PROCEDURE get_lot_lock_handle ( p_lock_name IN VARCHAR2
                                ,x_lock_handle OUT NOCOPY VARCHAR2 ) IS
 PRAGMA AUTONOMOUS_TRANSACTION;

 BEGIN

     dbms_lock.allocate_unique(
              lockname       => p_lock_name
             ,lockhandle     => x_lock_handle);

 END;



  PROCEDURE release_locks IS
  TYPE CHAR_TABLE is TABLE OF VARCHAR2(200);
  table_handle CHAR_TABLE;
  l_ret_status NUMBER;
   l_debug     NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    IF (l_debug = 1 ) THEN /* Bug#5401181*/
      inv_log_util.trace('Begin release locks.. ' , 'INV_TABLE_LOCK_PVT', 9);
    END IF;
    select lock_handle bulk collect into table_handle from mtl_onhand_lock_temp;
    if (table_handle IS NULL OR table_handle.COUNT = 0) THEN
         IF (l_debug = 1 ) THEN/* Bug#5401181*/
           inv_log_util.trace('No user locks to Release' , 'INV_TABLE_LOCK_PVT', 9);
	 END IF;
    else
        for i in table_handle.FIRST .. table_handle.LAST loop
          l_ret_status := dbms_lock.release(table_handle(i));
	  if l_ret_status = 0 then
	    IF (l_debug = 1 ) THEN /* Bug#5401181*/
	      inv_log_util.trace('Lock released successfully' , 'INV_TABLE_LOCK_PVT', 9);
	    END IF;
          else
	    IF (l_debug = 1 ) THEN/* Bug#5401181*/
	      inv_log_util.trace('Error in releasing the lock'||l_ret_status, 'INV_TABLE_LOCK_PVT', 9);
	    END IF;
	  end if;
        end loop;
	DELETE MTL_ONHAND_LOCK_TEMP;
    end if;
  END release_locks;

  --Bug #4338316
  --If p_commit is 0 (true) then commit, delete the records and user locks
  --of p_commit 1 (false) then only delete the records.
  PROCEDURE release_locks(
             p_header_id IN NUMBER
           , p_commit    IN NUMBER DEFAULT 0) IS
    TYPE char_table IS TABLE OF VARCHAR2(200);
    table_handle char_table;
    l_ret_status NUMBER;
    l_debug       NUMBER := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
  BEGIN
    IF (l_debug = 1 ) THEN /* Bug#5401181*/
      inv_log_util.TRACE('Begin release locks for header id.. ' || p_header_id, 'INV_TABLE_LOCK_PVT', 9);
    END IF;

    IF (p_commit = 1) THEN
      -- should not delete the temp rows for wip move trx's are this will
      -- be done BY wip move worker when they call the release_locks api.
      IF (wip_constants.wip_move_worker <> 'Y') THEN
        IF (l_debug = 1) /* Bug#5401181*/ THEN
          inv_log_util.TRACE('In rel locks,wip_move= .. ' || wip_constants.wip_move_worker, 'INV_TABLE_LOCK_PVT', 9);
	END IF;

        DELETE mtl_onhand_lock_temp
        WHERE header_id = p_header_id;
      END IF;
    ELSE
      SELECT lock_handle
      BULK COLLECT INTO table_handle
      FROM mtl_onhand_lock_temp
      WHERE header_id = p_header_id;

      IF (table_handle IS NULL OR table_handle.COUNT = 0) THEN
        IF (l_debug = 1 ) THEN/* Bug#5401181*/
          inv_log_util.TRACE('No user locks to Release', 'INV_TABLE_LOCK_PVT', 9);
	END IF;
      ELSE
        FOR i IN table_handle.FIRST .. table_handle.LAST LOOP
          l_ret_status  := DBMS_LOCK.release(table_handle(i));

          IF l_ret_status = 0 THEN
	    IF (l_debug = 1 ) THEN/* Bug#5401181*/
              inv_log_util.TRACE('Lock released successfully', 'INV_TABLE_LOCK_PVT', 9);
	    END IF;
          ELSE
	    IF (l_debug = 1 ) THEN /* Bug#5401181*/
              inv_log_util.TRACE('Error in releasing the lock' || l_ret_status, 'INV_TABLE_LOCK_PVT', 9);
	    END IF;
          END IF;
        END LOOP;

        DELETE mtl_onhand_lock_temp
        WHERE header_id = p_header_id;
      END IF;
    END IF;
  END release_locks;


END INV_TABLE_LOCK_PVT;

/
