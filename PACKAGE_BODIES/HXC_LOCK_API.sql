--------------------------------------------------------
--  DDL for Package Body HXC_LOCK_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_LOCK_API" AS
/* $Header: hxclockapi.pkb 120.4.12010000.2 2009/06/07 06:56:30 asrajago ship $ */

g_debug boolean := hr_utility.debug_enabled;

-- ----------------------------------------------------------------------------
-- |---------------------------< request_lock          > ----------------------|
-- ----------------------------------------------------------------------------
-- this request lock is going to be used in SS
-- locked success is in varchar.
PROCEDURE request_lock
         (p_process_locker_type        	IN VARCHAR2
         ,p_resource_id			IN NUMBER DEFAULT NULL
         ,p_start_time			IN DATE DEFAULT NULL
         ,p_stop_time 			IN DATE DEFAULT NULL
         ,p_time_building_block_id 	IN NUMBER
         ,p_time_building_block_ovn 	IN NUMBER
         ,p_transaction_lock_id		IN NUMBER DEFAULT NULL
         ,p_expiration_time		IN NUMBER DEFAULT hxc_lock_util.c_ss_expiration_time
         ,p_messages			IN OUT NOCOPY HXC_MESSAGE_TABLE_TYPE
         ,p_row_lock_id			IN OUT NOCOPY ROWID
         ,p_locked_success		OUT NOCOPY VARCHAR2
         ) IS

l_locked_success BOOLEAN := FALSE;

BEGIN

request_lock
         (p_process_locker_type        	=> p_process_locker_type
         ,p_resource_id			=> p_resource_id
         ,p_start_time			=> p_start_time
         ,p_stop_time			=> p_stop_time
         ,p_time_building_block_id	=> p_time_building_block_id
         ,p_time_building_block_ovn	=> p_time_building_block_ovn
         ,p_expiration_time		=> p_expiration_time
         ,p_row_lock_id			=> p_row_lock_id
         ,p_transaction_lock_id         => p_transaction_lock_id
         ,p_messages			=> p_messages
         ,p_locked_success		=> l_locked_success
         );
IF l_locked_success THEN
   p_locked_success := 'Y';
ELSE
   p_locked_success := 'N';
END IF;


END request_lock;

-- ----------------------------------------------------------------------------
-- |---------------------------< request_lock          > ----------------------|
-- ----------------------------------------------------------------------------
-- this request lock is going to be used in timekeeper
-- forms since we cannot passed the HXC_MESSAGE_TABLE_TYPE
-- as a type


PROCEDURE request_lock
         (p_process_locker_type        	IN VARCHAR2
         ,p_resource_id			IN NUMBER DEFAULT NULL
         ,p_start_time			IN DATE DEFAULT NULL
         ,p_stop_time 			IN DATE DEFAULT NULL
         ,p_time_building_block_id 	IN NUMBER
         ,p_time_building_block_ovn 	IN NUMBER
         ,p_transaction_lock_id		IN NUMBER DEFAULT NULL
         ,p_expiration_time		IN NUMBER DEFAULT hxc_lock_util.c_ss_expiration_time
         ,p_messages			IN OUT NOCOPY hxc_self_service_time_deposit.message_table
         ,p_row_lock_id			IN OUT NOCOPY ROWID
         ,p_locked_success		OUT NOCOPY BOOLEAN
         )IS

l_messages HXC_MESSAGE_TABLE_TYPE;

BEGIN

l_messages := hxc_message_table_type ();


request_lock
         (p_process_locker_type        	=> p_process_locker_type
         ,p_resource_id			=> p_resource_id
         ,p_start_time			=> p_start_time
         ,p_stop_time			=> p_stop_time
         ,p_time_building_block_id	=> p_time_building_block_id
         ,p_time_building_block_ovn	=> p_time_building_block_ovn
         ,p_expiration_time		=> p_expiration_time
         ,p_row_lock_id			=> p_row_lock_id
         ,p_transaction_lock_id         => p_transaction_lock_id
         ,p_messages			=> l_messages
         ,p_locked_success		=> p_locked_success
         );

-- convert the table to the right type
hxc_timekeeper_utilities.convert_type_to_message_table (
      l_messages,
      p_messages
    );


END request_lock;
-- ----------------------------------------------------------------------------
-- |---------------------------< request_lock          > ----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE request_lock
         (p_process_locker_type        	IN VARCHAR2
         ,p_resource_id			IN NUMBER DEFAULT NULL
         ,p_start_time			IN DATE DEFAULT NULL
         ,p_stop_time 			IN DATE DEFAULT NULL
         ,p_time_building_block_id 	IN NUMBER
         ,p_time_building_block_ovn 	IN NUMBER
         ,p_transaction_lock_id		IN NUMBER DEFAULT NULL
         ,p_expiration_time		IN NUMBER DEFAULT hxc_lock_util.c_ss_expiration_time
         ,p_messages			IN OUT NOCOPY HXC_MESSAGE_TABLE_TYPE
         ,p_row_lock_id			IN OUT NOCOPY ROWID
         ,p_locked_success		OUT NOCOPY BOOLEAN
         ) IS

cursor c_timecard_info (p_tbb_id number, p_tbb_ovn number) is
select scope, resource_id, stop_time, start_time, parent_building_Block_id,
       parent_building_block_ovn
from hxc_time_building_blocks
where time_building_block_id = p_tbb_id
and   object_version_number  = p_tbb_ovn;
--and   date_to = hr_general.end_of_time;

cursor c_app_period_detail (p_app_period_id number) is
select time_building_block_id, time_building_block_ovn
from   hxc_ap_detail_links
where  application_period_id = p_app_period_id;


--l_tc_resource_id	NUMBER;
--l_tc_start_time		DATE;
--l_tc_stop_time		DATE;

l_resource_id		NUMBER;
l_start_time		DATE;
l_tc_scope		VARCHAR2(80);
l_stop_time		DATE;

l_dummy			NUMBER;

l_row_lock_id		ROWID;

l_locker_type_req_id	NUMBER;
l_timecard_locked	BOOLEAN := FALSE;

l_expiration_time	NUMBER;

l_tbb_id		NUMBER;
l_tbb_ovn		NUMBER;

l_parent_tbb_id		NUMBER;
l_parent_tbb_ovn	NUMBER;


BEGIN

g_debug := hr_utility.debug_enabled;

-- quick check to denormilize the data and make
-- sure the passed data are correct

p_locked_success := FALSE;

l_resource_id	:= p_resource_id;
l_start_time	:= p_start_time;
l_stop_time	:= p_stop_time;
l_expiration_time := p_expiration_time;

--IF (p_resource_id = 7976) THEN
/*

if g_debug then
	hr_utility.trace('JOEL - ----------------------------------');
	hr_utility.trace('JOEL - request_lock 1 :'||p_resource_id);
	hr_utility.trace('JOEL - request_lock 1 :'||p_process_locker_type);
	hr_utility.trace('JOEL - request_lock 1: '||p_start_time);
	hr_utility.trace('JOEL - request_lock 1: '||p_stop_time);
	hr_utility.trace('JOEL - request_lock 1: '||p_time_building_block_id);
	hr_utility.trace('JOEL - request_lock 1: '||p_time_building_block_ovn);
	hr_utility.trace('JOEL - request_lock 1: '||p_expiration_time);
	hr_utility.trace('JOEL - request_lock 1: '||p_row_lock_id);
end if;

*/

--END IF;

IF l_expiration_time is null THEN
   l_expiration_time := hxc_lock_util.c_ss_expiration_time;
END IF;

--dbms_output.put_line('JOEL - request_lock 1');

-- for ss we need to check first if the lock exist for this row_id
-- we return the same rowid if it does.
IF p_process_locker_type = hxc_lock_util.c_ss_timecard_action
OR
  p_process_locker_type =  hxc_lock_util.c_ss_timecard_view
OR
  p_process_locker_type =  hxc_lock_util.c_ss_approval_action
THEN

--dbms_output.put_line('JOEL - request_lock 2'||p_row_lock_id);
   IF p_row_lock_id is not null THEN

     p_locked_success :=
        check_lock
         (p_row_lock_id			=> p_row_lock_id
         ,p_resource_id			=> p_resource_id
         ,p_start_time			=> p_start_time
         ,p_stop_time 			=> p_stop_time);

     IF p_locked_success THEN
--dbms_output.put_line('JOEL - request_lock 3');
       RETURN;
     ELSE
       -- in this case 2 meaning:
       -- 1 the timecard is not valid anymore so let's
       -- delete it
       --
       -- 2 the row id and the resource_id and
       -- start_time and stop_time does not match
       -- then we are releasing the lock and we are
       -- requesting a new one)
if g_debug then
	hr_utility.trace('JOEL - request_lock 11: ');
end if;
       release_lock (p_row_lock_id => p_row_lock_id);
       --
       p_row_lock_id := null;

     END IF;


   END IF;


END IF;

-- In the case of Day scope we will lock the timecard.
OPEN  c_timecard_info (p_time_building_block_id,p_time_building_block_ovn);
FETCH c_timecard_info INTO l_tc_scope,l_resource_id,l_stop_time, l_start_time, l_parent_tbb_id, l_parent_tbb_ovn;
CLOSE c_timecard_info;

IF l_tc_scope = 'DAY' THEN
   -- we take the timecard id
   l_tbb_id  := l_parent_tbb_id;
   l_tbb_ovn := l_parent_tbb_ovn;
ELSE
   l_tbb_id  := p_time_building_block_id;
   l_tbb_ovn := p_time_building_block_ovn;
END IF;



if g_debug then
	hr_utility.trace('JOEL - request_lock 4');
end if;


-- check if there is not a check already.
check_lock
         (p_process_locker_type        	=> p_process_locker_type
         ,p_resource_id			=> l_resource_id
         ,p_start_time			=> l_start_time
         ,p_stop_time 			=> l_stop_time
         ,p_time_building_block_id 	=> l_tbb_id
         ,p_time_building_block_ovn 	=> l_tbb_ovn
         ,p_messages			=> p_messages
         ,p_timecard_locked		=> l_timecard_locked
         ,p_time_building_block_scope   => l_tc_scope
         ,p_process_locker_type_id      => l_locker_type_req_id);

if g_debug then
	hr_utility.trace('JOEL - request_lock 2');
end if;

--if locked then stop the request_lock process
IF l_timecard_locked THEN
   RETURN;
END IF;

if g_debug then
	hr_utility.trace('JOEL - request_lock 2-1');
end if;



IF l_locker_type_req_id is null THEN
   l_locker_type_req_id := hxc_lock_util.get_locker_type_req_id
                     (p_process_locker_type    => p_process_locker_type
                     ,p_messages               => p_messages);
END IF;
-- if it is not locked then now
-- we need to insert row in hxc_locks
IF l_tbb_id is not null THEN

if g_debug then
	hr_utility.trace('JOEL - request_lock 3 :'||l_tc_scope);
	hr_utility.trace('JOEL - request_lock 3: '||l_start_time);
	hr_utility.trace('JOEL - request_lock 3: '||l_stop_time);
	hr_utility.trace('JOEL - request_lock 3: '||l_resource_id);
	hr_utility.trace('JOEL - request_lock 3: '||l_expiration_time);

end if;

  IF (l_tc_scope is null or l_resource_id is null
      or l_start_time is null or l_stop_time is null) THEN
     OPEN  c_timecard_info (l_tbb_id, l_tbb_ovn);
     FETCH c_timecard_info INTO l_tc_scope,l_resource_id,l_stop_time, l_start_time,l_parent_tbb_id, l_parent_tbb_ovn;
     CLOSE c_timecard_info;
  END IF;

  IF l_tc_scope = 'TIMECARD' or
     l_tc_scope = 'TIMECARD_TEMPLATE' or
     l_tc_scope = 'DETAIL' THEN

if g_debug then
	hr_utility.trace('JOEL - request_lock 3-1: ' || p_time_building_block_id);
	hr_utility.trace('JOEL - request_lock 3: '||l_start_time);
	hr_utility.trace('JOEL - request_lock 3: '||l_stop_time);
end if;

      hxc_lock_util.insert_lock
                   (p_locker_type_id      => l_locker_type_req_id
         	   ,p_resource_id         => l_resource_id
                   ,p_start_time          => l_start_time
         	   ,p_stop_time           => l_stop_time
         	   ,p_time_building_block_id  => l_tbb_id
                   ,p_time_building_block_ovn => l_tbb_ovn
                   ,p_transaction_lock_id     => p_transaction_lock_id
                   ,p_expiration_time	      => l_expiration_time
                   ,p_row_lock_id	      => p_row_lock_id
                   );
if g_debug then
	hr_utility.trace('JOEL - request_lock 3-1: ' || p_row_lock_id);
end if;

      p_locked_success := TRUE;

  ELSIF l_tc_scope = 'APPLICATION_PERIOD' THEN

if g_debug then
	hr_utility.trace('JOEL - request_lock 4: ' || p_time_building_block_id);
end if;
    -- we need to lock all the details for this application period
     FOR crs_app_period_detail in c_app_period_detail(l_tbb_id)
     LOOP
if g_debug then
	hr_utility.trace('JOEL - request_lock 3: '||l_start_time);
	hr_utility.trace('JOEL - request_lock 3: '||l_stop_time);
	hr_utility.trace('JOEL - p_time_building_block_id 3: '||p_time_building_block_id);
end if;

       -- if we arrive here that means we did not find a detail
       -- locked and then we can insert a new lock
       hxc_lock_util.insert_lock
                   (p_locker_type_id          => l_locker_type_req_id
         	   ,p_resource_id             => l_resource_id
                   ,p_start_time              => l_start_time
         	   ,p_stop_time               => l_stop_time
         	   ,p_time_building_block_id  => crs_app_period_detail.time_building_block_id
                   ,p_time_building_block_ovn => crs_app_period_detail.time_building_block_ovn
                   ,p_transaction_lock_id     => p_transaction_lock_id
                   ,p_expiration_time	      => l_expiration_time
                   ,p_row_lock_id	      => p_row_lock_id);


     END LOOP;

     -- we lock the application period
     hxc_lock_util.insert_lock
                   (p_locker_type_id          => l_locker_type_req_id
         	   ,p_resource_id             => l_resource_id
                   ,p_start_time              => l_start_time
         	   ,p_stop_time               => l_stop_time
         	   ,p_time_building_block_id  => l_tbb_id
                   ,p_time_building_block_ovn => l_tbb_ovn
                   ,p_transaction_lock_id     => p_transaction_lock_id
                   ,p_expiration_time	      => l_expiration_time
                   ,p_row_lock_id	      => p_row_lock_id);

     p_locked_success := TRUE;


   END IF;

ELSE

if g_debug then
	hr_utility.trace('JOEL - request_lock 5');
end if;

  -- we need to lock a period
  hxc_lock_util.insert_lock
                   (p_locker_type_id          => l_locker_type_req_id
         	   ,p_resource_id             => p_resource_id
                   ,p_start_time              => p_start_time
         	   ,p_stop_time               => p_stop_time
         	   ,p_time_building_block_id  => l_dummy
                   ,p_time_building_block_ovn => l_dummy
                   ,p_transaction_lock_id     => p_transaction_lock_id
                   ,p_expiration_time	      => l_expiration_time
                   ,p_row_lock_id	      => p_row_lock_id
                   );
  p_locked_success := TRUE;


END IF;

if g_debug then
	hr_utility.trace('messages :');
end if;


--l_dummy := p_messages.first;
--LOOP
 --EXIT WHEN
--    (NOT p_messages.exists(l_dummy));

--if g_debug then
--	hr_utility.trace('message_name :'||p_messages(l_dummy).message_name);
--	hr_utility.trace('message_level :'||p_messages(l_dummy).message_level);
--end if;

--l_dummy := p_messages.next(l_dummy);

--END LOOP;




END request_lock;


-- ----------------------------------------------------------------------------
-- |---------------------------< check_lock          > ----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE check_lock
         (p_process_locker_type        	IN VARCHAR2
         ,p_resource_id			IN OUT NOCOPY NUMBER
         ,p_start_time			IN OUT NOCOPY DATE
         ,p_stop_time 			IN OUT NOCOPY DATE
         ,p_time_building_block_id 	IN NUMBER
         ,p_time_building_block_ovn 	IN NUMBER
         ,p_messages			IN OUT NOCOPY HXC_MESSAGE_TABLE_TYPE
         ,p_timecard_locked		OUT NOCOPY BOOLEAN
         ,p_time_building_block_scope   OUT NOCOPY VARCHAR2
         ,p_process_locker_type_id      OUT NOCOPY NUMBER
         )IS

-- Bug 8579449
-- Forced hints in the below queries to pick up the right path.

cursor c_timecard_detail (p_tbb_id number, p_tbb_ovn number,p_resource_id number) is
select /*+ LEADING(day)
           INDEX(day HXC_TIME_BUILDING_BLOCKS_FK3) */
       detail.time_building_block_id, detail.object_version_number
from   hxc_time_building_blocks detail,hxc_time_building_blocks day
where  day.parent_building_block_id  = p_tbb_id
and    day.parent_building_block_ovn = p_tbb_ovn
and    day.scope = 'DAY'
and    day.resource_id = p_resource_id
and    day.time_building_block_id   = detail.parent_building_block_id
and    detail.parent_building_block_ovn =
(select max(day2.object_version_number)
from  hxc_time_building_blocks day2
where day2.time_building_block_id = day.time_building_block_id)
and  detail.scope = 'DETAIL'
and  detail.resource_id = p_resource_id
and  detail.object_version_number =
(select max(detail2.object_version_number)
from  hxc_time_building_blocks detail2
where detail2.time_building_block_id = detail.time_building_block_id)
UNION
select /*+ INDEX(day HXC_TIME_BUILDING_BLOCKS_FK3)*/
       day.time_building_block_id, day.object_version_number
from   hxc_time_building_blocks day
where  day.parent_building_block_id  = p_tbb_id
and    day.parent_building_block_ovn = p_tbb_ovn
and    day.scope = 'DAY'
and    day.resource_id = p_resource_id;


cursor c_detail_timecard (p_tbb_id number, p_tbb_ovn number,p_resource_id number) is
select /*+ LEADING(detail)
           INDEX(detail HXC_TIME_BUILDING_BLOCKS_PK)*/
       day.parent_building_block_id, day.parent_building_block_ovn
from   hxc_time_building_blocks detail, hxc_time_building_blocks day
where  detail.time_building_block_id  = p_tbb_id
and    detail.object_version_number = p_tbb_ovn
and    detail.scope = 'DETAIL'
and    detail.resource_id = p_resource_id
--and    detail.date_to = hr_general.end_of_time
and    day.scope = 'DAY'
--and    day.date_to = hr_general.end_of_time
and    day.resource_id = p_resource_id
and    day.time_building_block_id   = detail.parent_building_block_id
and    day.object_version_number = detail.parent_building_block_ovn
UNION
select /*+ INDEX(detail HXC_TIME_BUILDING_BLOCKS_PK) */
       detail.parent_building_block_id, detail.parent_building_block_ovn
from   hxc_time_building_blocks detail
where  detail.time_building_block_id  = p_tbb_id
and    detail.object_version_number = p_tbb_ovn
and    detail.scope = 'DETAIL'
and    detail.resource_id = p_resource_id;


cursor c_app_period_detail (p_app_period_id number) is
select time_building_block_id, time_building_block_ovn
from   hxc_ap_detail_links
where  application_period_id = p_app_period_id;

cursor c_resource_period_lock (p_resource_id number) is
select rowid, start_time, stop_time, lock_date, locker_type_id, process_id, attribute2
from   hxc_locks
where  resource_id = p_resource_id;

cursor c_period_lock (p_resource_id number) is
select rowid, start_time, stop_time, lock_date, locker_type_id, process_id, attribute2
from   hxc_locks
where  resource_id = p_resource_id
and    time_building_block_id is null
and    time_building_block_ovn is null;


--l_time_scope		VARCHAR2(80);
--l_resource_id		NUMBER;
--l_start_time		DATE;
--l_stop_time		DATE;

--l_locker_type_req_id	NUMBER;

l_timecard_id		NUMBER;
l_timecard_ovn		NUMBER;

l_passed_check		BOOLEAN := FALSE;

l_grant			VARCHAR2(1);

BEGIN

g_debug := hr_utility.debug_enabled;

p_timecard_locked := FALSE;

--l_resource_id	:= p_resource_id;
--l_start_time	:= p_start_time;
--l_stop_time	:= p_stop_time;

--dbms_output.put_line('JOEL - check_lock 1');

-- check the parameteres
hxc_lock_util.check_parameters
         (p_process_locker_type        	=> p_process_locker_type
         ,p_resource_id			=> p_resource_id
         ,p_start_time			=> p_start_time
         ,p_stop_time 			=> p_stop_time
         ,p_time_building_block_id 	=> p_time_building_block_id
         ,p_time_building_block_ovn     => p_time_building_block_ovn
         ,p_time_scope			=> p_time_building_block_scope
         ,p_messages			=> p_messages
         ,p_passed_check                => l_passed_check);

--dbms_output.put_line('JOEL - check_lock 2 :'||p_time_building_block_scope);

-- end the process
IF not(l_passed_check) THEN
   p_timecard_locked := TRUE;
   RETURN;
END IF;

p_process_locker_type_id := hxc_lock_util.get_locker_type_req_id
                     (p_process_locker_type    => p_process_locker_type
                     ,p_messages               => p_messages);


--dbms_output.put_line('JOEL - check_lock 3');

if g_debug then
	hr_utility.trace('JOEL - check_lock 3');
end if;

IF p_time_building_block_id is not null THEN
 -- following the scope we need to do different thing.
 -- but first we need to check if this

--dbms_output.put_line('JOEL - check_lock 4');

 hxc_lock_util.check_row_lock
         (p_locker_type_requestor_id    => p_process_locker_type_id
         ,p_process_locker_type        	=> p_process_locker_type
         ,p_resource_id			=> p_resource_id
         ,p_time_building_block_id 	=> p_time_building_block_id
         ,p_time_building_block_ovn 	=> p_time_building_block_ovn
         ,p_messages			=> p_messages
         ,p_row_locked                  => p_timecard_locked);

 -- check if we can stop the process
 IF p_timecard_locked THEN
    RETURN;
 END IF;

 -- check if there is not a period locked for a resource
 FOR crs_period_lock in c_period_lock(p_resource_id) LOOP

    hxc_lock_util.check_date_lock
         (p_locker_type_requestor_id    => p_process_locker_type_id
         ,p_locker_type_owner_id	=> crs_period_lock.locker_type_id
         ,p_process_locker_type		=> p_process_locker_type
         ,p_lock_date		 	=> crs_period_lock.lock_date
         ,p_lock_start_time             => crs_period_lock.start_time
         ,p_lock_stop_time              => crs_period_lock.stop_time
         ,p_start_time			=> p_start_time
         ,p_stop_time			=> p_stop_time
         ,p_time_building_block_id 	=> p_time_building_block_id
         ,p_time_building_block_ovn     => p_time_building_block_ovn
	 ,p_process_id			=> crs_period_lock.process_id
	 ,p_attribute2			=> crs_period_lock.attribute2
         ,p_resource_id			=> p_resource_id
         ,p_rowid			=> crs_period_lock.rowid
         ,p_messages			=> p_messages
         ,p_row_locked                  => p_timecard_locked);
    -- check if we can stop the process
    IF p_timecard_locked THEN
      RETURN;
    END IF;

 END LOOP;


--dbms_output.put_line('JOEL - check_lock 5');

  -- following the scope of the timecard we might need
  -- to search more
  IF p_time_building_block_scope= 'TIMECARD' or
     p_time_building_block_scope = 'TIMECARD_TEMPLATE' THEN

--dbms_output.put_line('JOEL - check_lock 6');

     -- we need to look if there is not a detail locked
     FOR crs_timecard_detail in c_timecard_detail(p_time_building_block_id,
                                                  p_time_building_block_ovn,
                                                  p_resource_id)
     LOOP

--dbms_output.put_line('JOEL - check_lock 7: '||crs_timecard_detail.time_building_block_id);

        hxc_lock_util.check_row_lock
         (p_locker_type_requestor_id    => p_process_locker_type_id
         ,p_process_locker_type        	=> p_process_locker_type
         ,p_resource_id			=> p_resource_id
         ,p_time_building_block_id 	=> crs_timecard_detail.time_building_block_id
         ,p_time_building_block_ovn 	=> crs_timecard_detail.object_version_number
         ,p_messages			=> p_messages
         ,p_row_locked                  => p_timecard_locked);

        -- check if we can stop the process
        IF p_timecard_locked THEN

--dbms_output.put_line('JOEL - check_lock 8');

          RETURN;
        END IF;
     END LOOP;

   -- if the tbb is a detail we need to check if the timecard is not locked
   ELSIF p_time_building_block_scope = 'DETAIL' THEN

--dbms_output.put_line('JOEL - check_lock 9 :'||p_time_building_block_id);
--dbms_output.put_line('JOEL - check_lock 9 :'||p_time_building_block_ovn);
--dbms_output.put_line('JOEL - check_lock 9 :'||l_resource_id);

     OPEN c_detail_timecard
                     (p_time_building_block_id,
                      p_time_building_block_ovn,
                      p_resource_id);
     FETCH  c_detail_timecard into l_timecard_id, l_timecard_ovn;

     IF c_detail_timecard%FOUND THEN
       CLOSE  c_detail_timecard;

--dbms_output.put_line('JOEL - check_lock 9 :'||l_timecard_id);
--dbms_output.put_line('JOEL - check_lock 9 :'||l_timecard_ovn);

     -- try to find the lock
        hxc_lock_util.check_row_lock
         (p_locker_type_requestor_id    => p_process_locker_type_id
         ,p_process_locker_type        	=> p_process_locker_type
         ,p_resource_id			=> p_resource_id
         ,p_time_building_block_id 	=> l_timecard_id
         ,p_time_building_block_ovn 	=> l_timecard_ovn
         ,p_messages			=> p_messages
         ,p_row_locked                  => p_timecard_locked);

        -- check if we can stop the process
        IF p_timecard_locked THEN
          RETURN;
        END IF;
     ELSE
        hxc_timecard_message_helper.addErrorToCollection
             (p_messages          => p_messages
             ,p_message_name      => 'HXC_LOCK_PARAM_RULE_8'
             ,p_message_level     => 'ERROR'
             ,p_message_field     => null
             ,p_message_tokens    => null
             ,p_application_short_name  => 'HXC'
             ,p_time_building_block_id  => null
             ,p_time_building_block_ovn => null
             ,p_time_attribute_id       => null
             ,p_time_attribute_ovn      => null
             ,p_message_extent          => null
             );
        p_timecard_locked := TRUE;
        RETURN;
      END IF;


   ELSIF p_time_building_block_scope = 'APPLICATION_PERIOD' THEN

     FOR crs_app_period_detail in c_app_period_detail(p_time_building_block_id)
     LOOP

if g_debug then
	hr_utility.trace('JOEL - check_lock 10 :');
end if;

     -- try to find the lock
        hxc_lock_util.check_row_lock
         (p_locker_type_requestor_id    => p_process_locker_type_id
         ,p_process_locker_type        	=> p_process_locker_type
         ,p_resource_id			=> p_resource_id
         ,p_time_building_block_id 	=> crs_app_period_detail.time_building_block_id
         ,p_time_building_block_ovn 	=> crs_app_period_detail.time_building_block_ovn
         ,p_messages			=> p_messages
         ,p_row_locked                  => p_timecard_locked);


        -- check if we can stop the process
        IF p_timecard_locked THEN
          RETURN;
if g_debug then
	hr_utility.trace('JOEL - check_lock 11 :');
end if;
        END IF;

        -- for each detail we need to check if the parent is locked
        OPEN c_detail_timecard
                     (crs_app_period_detail.time_building_block_id,
                      crs_app_period_detail.time_building_block_ovn,
                      p_resource_id);
        FETCH  c_detail_timecard into l_timecard_id, l_timecard_ovn;
        CLOSE  c_detail_timecard;

--dbms_output.put_line('JOEL - check_lock 11 :');
 if g_debug then
 	hr_utility.trace('JOEL - check_lock 12 :');
 end if;

        -- try to find the lock
        hxc_lock_util.check_row_lock
         (p_locker_type_requestor_id    => p_process_locker_type_id
         ,p_process_locker_type        	=> p_process_locker_type
         ,p_resource_id			=> p_resource_id
         ,p_time_building_block_id 	=> l_timecard_id
         ,p_time_building_block_ovn 	=> l_timecard_ovn
         ,p_messages			=> p_messages
         ,p_row_locked                  => p_timecard_locked);

        -- check if we can stop the process
        IF p_timecard_locked THEN
if g_debug then
	hr_utility.trace('JOEL - check_lock 13 :');
end if;
          RETURN;
        END IF;

     END LOOP;
   END IF;

ELSE
  -- we are in the case of a checking a lock for a period for a resource
  FOR crs_resource_period_lock in c_resource_period_lock(p_resource_id) LOOP

if g_debug then
	hr_utility.trace('JOEL - check_lock 12 :');
end if;

    hxc_lock_util.check_date_lock
         (p_locker_type_requestor_id    => p_process_locker_type_id
         ,p_locker_type_owner_id	=> crs_resource_period_lock.locker_type_id
         ,p_process_locker_type        	=> p_process_locker_type
         ,p_lock_date		 	=> crs_resource_period_lock.lock_date
         ,p_lock_start_time             => crs_resource_period_lock.start_time
         ,p_lock_stop_time              => crs_resource_period_lock.stop_time
         ,p_start_time			=> p_start_time
         ,p_stop_time			=> p_stop_time
         ,p_time_building_block_id 	=> p_time_building_block_id
         ,p_time_building_block_ovn     => p_time_building_block_ovn
	 ,p_process_id			=> crs_resource_period_lock.process_id
	 ,p_attribute2			=> crs_resource_period_lock.attribute2
         ,p_resource_id			=> p_resource_id
         ,p_rowid			=> crs_resource_period_lock.rowid
         ,p_messages			=> p_messages
         ,p_row_locked                  => p_timecard_locked);


    -- check if we can stop the process
    IF p_timecard_locked THEN
       RETURN;
    END IF;

  END LOOP;
END IF;

END check_lock;

-- ----------------------------------------------------------------------------
-- |---------------------------< check_lock          > ----------------------|
-- ----------------------------------------------------------------------------
FUNCTION check_lock (p_row_lock_id	IN ROWID)
	 RETURN BOOLEAN IS

cursor c_lock is
select lock_date from hxc_locks
where rowid = p_row_lock_id;

l_locked 	BOOLEAN := FALSE;
l_lock_date 	DATE;

BEGIN


IF p_row_lock_id is not null THEN
/*

g_debug := hr_utility.debug_enabled;

if g_debug then
	hr_utility.trace('J a'||trim(p_row_lock_id)||'b');
end if;

*/
 OPEN c_lock;
 FETCH c_lock into l_lock_date;

 IF c_lock%FOUND THEN

   IF l_lock_date > (sysdate-(1/24/60)*10) THEN
      --lock still valid
      l_locked := TRUE;
   END IF;

 END IF;
 CLOSE c_lock;

END IF;

RETURN l_locked;

END check_lock;

-- ----------------------------------------------------------------------------
-- |---------------------------< check_lock          > ----------------------|
-- ----------------------------------------------------------------------------
FUNCTION check_lock
         (p_process_locker_type        	IN VARCHAR2
         ,p_transaction_lock_id         IN NUMBER
         ,p_resource_id			IN NUMBER)
         RETURN ROWID IS

cursor c_lock (p_locker_type_req_id number) is
select lock_date, rowid from hxc_locks
where transaction_lock_id = p_transaction_lock_id
and   resource_id  = p_resource_id
and   locker_type_id = p_locker_type_req_id;

l_locker_type_req_id	NUMBER;
l_lock_date 	DATE;
l_locked 	BOOLEAN := FALSE;
l_row_id	ROWID;
l_messages      HXC_MESSAGE_TABLE_TYPE;

BEGIN

l_locker_type_req_id
                   := hxc_lock_util.get_locker_type_req_id
                     (p_process_locker_type    => p_process_locker_type
                     ,p_messages               => l_messages);


OPEN c_lock (l_locker_type_req_id);
FETCH c_lock into l_lock_date,l_row_id;

IF c_lock%FOUND THEN

   IF l_lock_date > (sysdate-(1/24/60)*10) THEN
      --lock still valid
      l_locked := TRUE;
   END IF;

END IF;
CLOSE c_lock;

IF not(l_locked) THEN
  l_row_id := NULL;
END IF;

RETURN l_row_id;

END check_lock;

-- ----------------------------------------------------------------------------
-- |---------------------------< check_lock          > ----------------------|
-- ----------------------------------------------------------------------------
FUNCTION check_lock
         (p_row_lock_id			IN ROWID
         ,p_resource_id			IN NUMBER
         ,p_start_time			IN DATE
         ,p_stop_time 			IN DATE)
         RETURN BOOLEAN IS

cursor c_lock is
select lock_date
from hxc_locks
where rowid = p_row_lock_id
and resource_id = p_resource_id
and start_time = p_start_time
and stop_time = p_stop_time;

l_lock_date 	DATE;
l_locked 	BOOLEAN := FALSE;

BEGIN


OPEN c_lock;
FETCH c_lock into l_lock_date;

IF c_lock%FOUND THEN

   IF l_lock_date > (sysdate-(1/24/60)*10) THEN
      --lock still valid
      l_locked := TRUE;
   END IF;

END IF;
CLOSE c_lock;


RETURN l_locked;

END check_lock;


-- ----------------------------------------------------------------------------
-- |---------------------------< release_lock          > ----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE release_lock
         (p_row_lock_id			IN ROWID)
         IS

l_messages      HXC_MESSAGE_TABLE_TYPE;
l_released_success BOOLEAN;

BEGIN


release_lock
         (p_row_lock_id			=> p_row_lock_id
         ,p_process_locker_type         => hxc_lock_util.c_ss_timecard_action
         ,p_messages			=> l_messages
         ,p_released_success		=> l_released_success
        ) ;


END release_lock;

-- ----------------------------------------------------------------------------
-- |---------------------------< release_lock          > ----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE release_lock
         (p_row_lock_id			IN ROWID
         ,p_process_locker_type        	IN VARCHAR2
         ,p_transaction_lock_id         IN NUMBER DEFAULT NULL
         ,p_released_success		OUT NOCOPY BOOLEAN
        ) IS

l_messages      HXC_MESSAGE_TABLE_TYPE;

BEGIN


release_lock
         (p_row_lock_id			=> p_row_lock_id
         ,p_process_locker_type         => p_process_locker_type
         ,p_transaction_lock_id         => p_transaction_lock_id
         ,p_messages			=> l_messages
         ,p_released_success		=> p_released_success
        ) ;

END release_lock;

-- ----------------------------------------------------------------------------
-- |---------------------------< release_lock          > ----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE release_lock
         (p_row_lock_id			IN ROWID
         ,p_process_locker_type        	IN VARCHAR2
         ,p_transaction_lock_id         IN NUMBER DEFAULT NULL
         ,p_resource_id			IN NUMBER DEFAULT NULL
         ,p_start_time			IN DATE DEFAULT NULL
         ,p_stop_time 			IN DATE DEFAULT NULL
         ,p_time_building_block_id 	IN NUMBER DEFAULT NULL
         ,p_time_building_block_ovn 	IN NUMBER DEFAULT NULL
         ,p_messages			IN OUT NOCOPY HXC_MESSAGE_TABLE_TYPE
         ,p_released_success		OUT NOCOPY BOOLEAN
        ) IS

cursor c_timecard_info(p_tbb_id number, p_tbb_ovn number) is
select scope, resource_id, stop_time, start_time, parent_building_Block_id,
       parent_building_block_ovn
from hxc_time_building_blocks
where time_building_block_id = p_tbb_id
and   object_version_number  = p_tbb_ovn;
--and   date_to = hr_general.end_of_time;

cursor c_app_period_detail (p_app_period_id number) is
select time_building_block_id, time_building_block_ovn
from   hxc_ap_detail_links
where  application_period_id = p_app_period_id;


l_locker_type_req_id	NUMBER;

l_resource_id		NUMBER;
l_start_time		DATE;
l_stop_time		DATE;
l_time_scope		VARCHAR2(80);

l_tc_scope		VARCHAR2(80);
l_tc_resource_id	NUMBER;
l_tc_start_time		DATE;
l_tc_stop_time		DATE;

l_passed_check		BOOLEAN := FALSE;

l_tbb_id		NUMBER;
l_tbb_ovn		NUMBER;

l_parent_tbb_id		NUMBER;
l_parent_tbb_ovn	NUMBER;

BEGIN

g_debug := hr_utility.debug_enabled;

p_released_success := FALSE;


if g_debug then
	hr_utility.trace('--------------------------------------------');
	hr_utility.trace('JOEL - delete_lock 10 '||p_process_locker_type);
	hr_utility.trace('JOEL - delete_lock 10 :'||p_resource_id);
	hr_utility.trace('JOEL - delete_lock 10 :'||p_process_locker_type);
	hr_utility.trace('JOEL - delete_lock 10: '||p_start_time);
	hr_utility.trace('JOEL - delete_lock 10: '||p_stop_time);
	hr_utility.trace('JOEL - delete_lock 10: '||p_time_building_block_id);
	hr_utility.trace('JOEL - delete_lock 10: '||p_time_building_block_ovn);
	hr_utility.trace('JOEL - delete_lock 10: '||p_row_lock_id);

end if;

-- if it is not locked then now
-- we need to insert row in hxc_locks

IF p_row_lock_id is not null THEN
if g_debug then
	hr_utility.trace('JOEL - delete_lock 10 ');
end if;
   hxc_lock_util.delete_lock
           (p_rowid => p_row_lock_id
           ,p_locker_type_id      => null
           ,p_process_locker_type => p_process_locker_type
           ,p_messages => p_messages);

   p_released_success := TRUE;
   RETURN;
END IF;

IF p_transaction_lock_id is not null THEN

   hxc_lock_util.delete_transaction_lock
           (p_transaction_lock_id => p_transaction_lock_id
           ,p_process_locker_type => p_process_locker_type
           ,p_messages => p_messages);

   p_released_success := TRUE;
   RETURN;
END IF;


l_resource_id	:= p_resource_id;
l_start_time	:= p_start_time;
l_stop_time	:= p_stop_time;

-- In the case of Day scope we will lock the timecard.
OPEN  c_timecard_info (p_time_building_block_id,p_time_building_block_ovn);
FETCH c_timecard_info INTO l_tc_scope,l_resource_id,l_stop_time, l_start_time, l_parent_tbb_id, l_parent_tbb_ovn;
CLOSE c_timecard_info;

IF l_tc_scope = 'DAY' THEN
   -- we take the timecard id
   l_tbb_id  := l_parent_tbb_id;
   l_tbb_ovn := l_parent_tbb_ovn;
ELSE
   l_tbb_id  := p_time_building_block_id;
   l_tbb_ovn := p_time_building_block_ovn;
END IF;


--dbms_output.put_line('JOEL - release_lock 2 :');

-- check the parameteres
hxc_lock_util.check_parameters
         (p_process_locker_type        	=> p_process_locker_type
         ,p_resource_id			=> l_resource_id
         ,p_start_time			=> l_start_time
         ,p_stop_time 			=> l_stop_time
         ,p_time_building_block_id 	=> l_tbb_id
         ,p_time_building_block_ovn     => l_tbb_ovn
         ,p_time_scope			=> l_time_scope
         ,p_messages			=> p_messages
         ,p_passed_check                => l_passed_check);

-- end the process
IF not(l_passed_check) THEN
   RETURN;
END IF;

--dbms_output.put_line('JOEL - release_lock 3:');

l_locker_type_req_id
                   := hxc_lock_util.get_locker_type_req_id
                     (p_process_locker_type    => p_process_locker_type
                     ,p_messages               => p_messages);


IF l_tbb_id is not null THEN


--dbms_output.put_line('JOEL - release_lock 4 :');


  OPEN  c_timecard_info(l_tbb_id, l_tbb_ovn);
  FETCH c_timecard_info INTO l_tc_scope,l_tc_resource_id,l_tc_stop_time,l_tc_start_time,l_parent_tbb_id, l_parent_tbb_ovn;
  CLOSE c_timecard_info;

  IF l_tc_scope = 'TIMECARD' or
     l_tc_scope = 'TIMECARD_TEMPLATE' or
     l_tc_scope = 'DETAIL' THEN

--dbms_output.put_line('JOEL - release_lock 5 :');

      hxc_lock_util.delete_tbb_lock
                   (p_locker_type_id          => l_locker_type_req_id
         	   ,p_time_building_block_id  => l_tbb_id
                   ,p_time_building_block_ovn => l_tbb_ovn);


  ELSIF l_tc_scope = 'APPLICATION_PERIOD' THEN

    -- we need to lock all the details for this application period
     FOR crs_app_period_detail in c_app_period_detail(l_tbb_id)
     LOOP

--dbms_output.put_line('JOEL - release_lock 6 :');

       -- if we arrive here that means we did not find a detail
       -- locked and then we can insert a new lock
       hxc_lock_util.delete_tbb_lock
                   (p_locker_type_id          => l_locker_type_req_id
         	   ,p_time_building_block_id  => crs_app_period_detail.time_building_block_id
                   ,p_time_building_block_ovn => crs_app_period_detail.time_building_block_ovn);
     END LOOP;
   END IF;

   hxc_lock_util.delete_tbb_lock
                   (p_locker_type_id          => l_locker_type_req_id
         	   ,p_time_building_block_id  => l_tbb_id
                   ,p_time_building_block_ovn => l_tbb_ovn);



ELSE

--dbms_output.put_line('JOEL - release_lock 7 :');

  -- we need to delete a period
  hxc_lock_util.delete_period_lock
                   (p_locker_type_id          => l_locker_type_req_id
         	   ,p_resource_id             => p_resource_id
                   ,p_start_time              => p_start_time
         	   ,p_stop_time               => p_stop_time);


END IF;

p_released_success := TRUE;

END release_lock;

END HXC_LOCK_API;

/
