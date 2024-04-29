--------------------------------------------------------
--  DDL for Package Body INV_RESERVATION_LOCK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_RESERVATION_LOCK_PVT" AS
/* $Header: INVLRSVB.pls 120.1 2005/07/20 16:19:56 lplam noship $ */

PROCEDURE lock_supply_demand_record
  (p_organization_id   IN NUMBER
   ,p_inventory_item_id IN NUMBER
   ,p_source_type_id IN NUMBER
   ,p_source_header_id IN NUMBER
   ,p_source_line_id IN NUMBER
   ,p_source_line_detail IN NUMBER
   ,x_lock_handle OUT NOCOPY VARCHAR2
   ,x_lock_status OUT NOCOPY NUMBER) IS

   l_lock_handle VARCHAR2(128);
   l_lock_name   VARCHAR2(2000);
   l_status NUMBER;
   l_sessionid NUMBER;
   l_lock_status NUMBER;

   l_source_header_id   NUMBER := p_source_header_id;
   l_source_line_id     NUMBER := p_source_line_id;
   l_source_line_detail NUMBER := p_source_line_detail;

BEGIN
   l_status := 9;

   IF (l_source_header_id = fnd_api.g_miss_num) THEN
       l_source_header_id := NULL;
   END IF;

   IF (l_source_line_id = fnd_api.g_miss_num) THEN
       l_source_line_id := NULL;
   END IF;

   IF (l_source_line_detail = fnd_api.g_miss_num) THEN
       l_source_line_detail := NULL;
   END IF;

   l_lock_name := 'INV_RSV_' ||
     p_organization_id   || '_' ||
     p_inventory_item_id || '_' ||
     p_source_type_id    || '_' ||
     Nvl(l_source_header_id,-99)  || '_' ||
     Nvl(l_source_line_id, -99)    || '_' ||
     Nvl(l_source_line_detail, -99);

   get_lock_handle(l_lock_name,l_lock_handle);

   /*	 select USERENV('SESSIONID') into l_sessionid from dual;
   inv_log_util.trace('Session is.. ' ||l_sessionid , 'INV_RESERVATION_LOCK_PVT', 9);  */

     inv_log_util.trace('Lock Name is...:' ||l_lock_name , 'INV_RESERVATION_LOCK_PVT', 9);
   inv_log_util.trace('Lock Handle is...:' ||l_lock_handle , 'INV_RESERVATION_LOCK_PVT', 9);

   l_status := dbms_lock.request
     (
      lockhandle        => l_lock_handle
      ,lockmode          => dbms_lock.x_mode
      ,timeout           => dbms_lock.maxwait
      ,release_on_commit => TRUE);
   -- l_status = 4.No need to insert into temp table when lock is already
   -- owned by this session.it will become duplicate entry if we insert
   -- and release lock may fail in this case for the second time.

   inv_log_util.trace('l_status returns from dbms_lock.request = ' || l_status, 'INV_RESERVATION_LOCK_PVT', 9);

   if (l_status <> 0 AND l_status <> 4) then
      if (l_status = 1 OR l_status = 2) then
         l_lock_status := 0;
      end if;
   ELSE
      l_lock_status := 1;
   END IF;

   inv_log_util.trace('l_lock_status = ' || l_lock_status,  'INV_RESERVATION_LOCK_PVT', 9);
   x_lock_status := l_lock_status;
   x_lock_handle := l_lock_handle;
EXCEPTION
   WHEN OTHERS THEN
      inv_log_util.trace('Exception: ' || SQLERRM,  'INV_RESERVATION_LOCK_PVT', 9);
      x_lock_status := 0;
END;

PROCEDURE get_lock_handle
  (p_lock_name IN VARCHAR2,
   x_lock_handle OUT NOCOPY VARCHAR2) IS

      PRAGMA AUTONOMOUS_TRANSACTION;
begin
   inv_log_util.trace('p_lock_name = ' || p_lock_name, 'INV_RESERVATION_LOCK_PVT', 9);
   dbms_lock.allocate_unique
     (lockname       => p_lock_name
      ,lockhandle     => x_lock_handle);
   commit;
end;

PROCEDURE release_lock(p_lock_handle IN VARCHAR2)
  IS
     l_ret_status NUMBER;
BEGIN
   inv_log_util.trace('Begin release locks.. ' , 'INV_RESERVATION_LOCK_PVT', 9);

   l_ret_status := dbms_lock.release(p_lock_handle);
   if l_ret_status = 0 then
      inv_log_util.trace('Lock released successfully' , 'INV_RESERVATION_LOCK_PVT', 9);
    else
      inv_log_util.trace('Error in releasing the lock'||l_ret_status, 'INV_RESERVATION_LOCK_PVT', 9);
   end if;

END;

END INV_RESERVATION_LOCK_PVT;

/
