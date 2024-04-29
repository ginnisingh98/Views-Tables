--------------------------------------------------------
--  DDL for Package Body HXC_LOCK_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_LOCK_UTIL" AS
/* $Header: hxclockutil.pkb 120.3 2005/09/23 05:19:29 nissharm noship $ */

g_debug boolean := hr_utility.debug_enabled;

-- ----------------------------------------------------------------------------
-- |---------------------------< check_parameters          > ----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE check_parameters
         (p_process_locker_type        	IN VARCHAR2
         ,p_resource_id			IN OUT NOCOPY NUMBER
         ,p_start_time			IN OUT NOCOPY DATE
         ,p_stop_time 			IN OUT NOCOPY DATE
         ,p_time_building_block_id 	IN NUMBER
         ,p_time_building_block_ovn 	IN NUMBER
         ,p_time_scope			IN OUT NOCOPY VARCHAR2
         ,p_messages			IN OUT NOCOPY HXC_MESSAGE_TABLE_TYPE
         ,p_passed_check                OUT NOCOPY BOOLEAN
         ) IS

cursor c_timecard_info is
select scope, resource_id, stop_time, start_time
from hxc_time_building_blocks
where time_building_block_id = p_time_building_block_id
and   object_version_number  = p_time_building_block_ovn;
--and   date_to                = hr_general.end_of_time;

l_tc_scope		VARCHAR2(80);
l_tc_resource_id	NUMBER;
l_tc_start_time		DATE;
l_tc_stop_time		DATE;


BEGIN

p_passed_check := FALSE;

--dbms_output.put_line('JOEL check_parameters 1 ');


-- check_process_locker_type
IF p_process_locker_type is null THEN

--dbms_output.put_line('JOEL check_parameters 1');

  hxc_timecard_message_helper.addErrorToCollection
           (p_messages 		=> p_messages
           ,p_message_name      => 'HXC_LOCK_PARAM_RULE_1'
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
  p_passed_check := FALSE;
  RETURN;

ELSE
-- if it is not null then check that p_process_locker_type
-- is a valid value
   IF p_process_locker_type <> c_ss_timecard_action
   AND
      p_process_locker_type <> c_ss_timecard_view
   AND
      p_process_locker_type <> c_ss_approval_action
   AND
      p_process_locker_type <> c_pui_timekeeper_action
   AND
      p_process_locker_type <> c_plsql_pay_retrieval_action
   AND
      p_process_locker_type <> c_plsql_pa_retrieval_action
   AND
      p_process_locker_type <> c_plsql_eam_retrieval_action
   AND
     p_process_locker_type <> c_plsql_po_retrieval_action
   AND
      p_process_locker_type <> c_plsql_deposit_action
   AND
      p_process_locker_type <> c_plsql_coa_action
   AND
      p_process_locker_type <> c_plsql_ar_action
   THEN

--dbms_output.put_line('JOEL check_parameters 2'||p_process_locker_type);

   hxc_timecard_message_helper.addErrorToCollection
           (p_messages 		=> p_messages
           ,p_message_name      => 'HXC_LOCK_PARAM_RULE_2'
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
     p_passed_check := FALSE;
     RETURN;

   END IF;
END IF;

--dbms_output.put_line('JOEL check_parameters 2 p_resource_id '||p_resource_id);
--dbms_output.put_line('JOEL check_parameters 2 p_start_time '||p_start_time);
--dbms_output.put_line('JOEL check_parameters 2 p_stop_time '||p_stop_time);
--dbms_output.put_line('JOEL check_parameters 2 p_time_building_block_id '||p_time_building_block_id);
--dbms_output.put_line('JOEL check_parameters 2 p_time_building_block_ovn '||p_time_building_block_ovn);


-- if all the parameters are null then throw an error
IF p_resource_id is null and
   p_start_time  is null and
   p_stop_time   is null and
   p_time_building_block_id is null and
   p_time_building_block_ovn is null
THEN

--dbms_output.put_line('JOEL check_parameters 3');

  hxc_timecard_message_helper.addErrorToCollection
           (p_messages 		=> p_messages
           ,p_message_name      => 'HXC_LOCK_PARAM_RULE_3'
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
   p_passed_check := FALSE;
   RETURN;

ELSE

--dbms_output.put_line('JOEL check_parameters 3');

   -- if time is not null or the resource is not null
   -- then we are finding the timecard info in the
   -- case the tbb is not null
   -- we are checking also that the resource in param
   -- and the timecard info are compatible
   IF (p_time_building_block_id is not null
   and p_time_building_block_ovn is not null)
   OR
      (p_resource_id is not null
   and p_start_time is not null
   and p_stop_time is not null)
   THEN


       IF (p_time_building_block_id is not null)
       --and p_time_building_block_ovn is not null)
       THEN
          -- find the start_time, stop_time
          -- resource_id and scope attached to
          -- the timecard

--dbms_output.put_line('JOEL check_parameters 4: '||p_time_building_block_id);
--dbms_output.put_line('JOEL check_parameters 4: '||p_time_building_block_ovn);

          OPEN c_timecard_info;
          FETCH c_timecard_info INTO p_time_scope, l_tc_resource_id, l_tc_stop_time, l_tc_start_time;

          IF c_timecard_info%FOUND THEN
            CLOSE c_timecard_info;
            IF (p_resource_id is not null and
                l_tc_resource_id <> p_resource_id)
            THEN
              hxc_timecard_message_helper.addErrorToCollection
             (p_messages          => p_messages
             ,p_message_name      => 'HXC_LOCK_PARAM_RULE_4'
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
             p_passed_check := FALSE;
             RETURN;
            END IF;

            -- we are making sure that the scope
            -- of the tbb that we are trying to lock
            -- is supported.
            IF l_tc_scope <> 'TIMECARD' and
               l_tc_scope <> 'TIMECARD_TEMPLATE' and
               l_tc_scope <> 'DETAIL' and
               l_tc_scope <> 'APPLICATION_PERIOD' THEN

--dbms_output.put_line('JOEL check_parameters 5: '||l_tc_scope);

                hxc_timecard_message_helper.addErrorToCollection
                (p_messages          => p_messages
                ,p_message_name      => 'HXC_LOCK_PARAM_RULE_5'
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
                p_passed_check := FALSE;
                RETURN;
            END IF;

            -- return the right information
            p_resource_id := l_tc_resource_id;
            p_start_time  := l_tc_start_time;
            p_stop_time   := l_tc_stop_time;

         ELSE

--dbms_output.put_line('JOEL check_parameters 6 ');

           CLOSE c_timecard_info;
           /*
           hxc_timecard_message_helper.addErrorToCollection
             (p_messages          => p_messages
             ,p_message_name      => 'HXC_LOCK_PARAM_RULE_6'
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
             p_passed_check := FALSE;
             RETURN;
            */
         END IF;
       ELSIF (p_resource_id is not null
          and p_start_time is not null
          and p_stop_time is not null) THEN

          IF p_start_time > p_stop_time THEN
           hxc_timecard_message_helper.addErrorToCollection
             (p_messages          => p_messages
             ,p_message_name      => 'HXC_LOCK_PARAM_RULE_9'
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
             p_passed_check := FALSE;
             RETURN;

          END IF;

       END IF;

   ELSE

--dbms_output.put_line('JOEL check_parameters 7');

      -- in the other case we raise an error.
      hxc_timecard_message_helper.addErrorToCollection
           (p_messages 		=> p_messages
           ,p_message_name      => 'HXC_LOCK_PARAM_RULE_10'
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
      p_passed_check := FALSE;
      RETURN;

   END IF;

END IF;

p_passed_check := TRUE;

END check_parameters;

-- ----------------------------------------------------------------------------
-- |---------------------------< check_grant	       > ----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE check_grant(p_locker_type_owner_id 	 IN NUMBER
                     ,p_locker_type_requestor_id IN NUMBER
                     ,p_messages  	         IN OUT NOCOPY HXC_MESSAGE_TABLE_TYPE
                     ,p_grant_lock               OUT NOCOPY VARCHAR2)
                     IS

cursor c_grant_lock (p_locker_type_owner_id NUMBER,
                     p_locker_type_requestor_id NUMBER) is
select grant_lock
from   hxc_locking_rules
where  locker_type_owner_id = p_locker_type_owner_id
and    locker_type_requestor_id = p_locker_type_requestor_id;



BEGIN


OPEN  c_grant_lock(p_locker_type_owner_id,p_locker_type_requestor_id);
FETCH c_grant_lock into p_grant_lock;
CLOSE c_grant_lock;


END check_grant;


-- ----------------------------------------------------------------------------
-- |---------------------------< check_session	       > ----------------------|
-- ----------------------------------------------------------------------------
FUNCTION  check_session
                     (p_current_session_id 	 IN NUMBER
                     ,p_current_user_id          IN NUMBER
                     ,p_current_resource_id      IN NUMBER
                     ,p_lock_session_id		 IN NUMBER
                     ,p_lock_user_id		 IN NUMBER
                     ,p_lock_resource_id	 IN NUMBER)
                     RETURN BOOLEAN IS

l_result	BOOLEAN := FALSE;

BEGIN
/*
g_debug := hr_utility.debug_enabled;

if g_debug then

	hr_utility.trace('p_lock_session_id '||p_lock_session_id);
	hr_utility.trace('p_current_session_id '||p_current_session_id);
	hr_utility.trace('p_current_user_id '||p_current_user_id);
	hr_utility.trace('p_lock_user_id '||p_lock_user_id);
end if;
*/
IF (p_current_resource_id = p_lock_resource_id and
    p_current_user_id = p_lock_user_id) THEN
     l_result := TRUE;

ELSIF (p_current_session_id = p_lock_session_id and
    p_current_user_id = p_lock_user_id) THEN
     l_result := TRUE;

ELSIF (p_current_session_id <> p_lock_session_id and
       p_current_user_id = p_lock_user_id) THEN
     l_result := TRUE;
END IF;

RETURN l_result;

END check_session;


/*
-- ----------------------------------------------------------------------------
-- |---------------------------< validate_lock	       > ----------------------|
-- ----------------------------------------------------------------------------

PROCEDURE validate_lock
          (p_locker_type_owner_id     IN OUT NOCOPY NUMBER
          ,p_locker_type_requestor_id IN OUT NOCOPY NUMBER
          ,p_lock_date                IN OUT NOCOPY DATE
          ,p_messages  	              IN OUT NOCOPY HXC_MESSAGE_TABLE_TYPE
          ,p_valid_lock               IN OUT NOCOPY BOOLEAN) IS

l_grant  VARCHAR2(1);

BEGIN

p_valid_lock := FALSE;

-- first we need to check that the lock is not expire
-- 10 min

--dbms_output.put_line('JOEL - validate_lock 1 '||p_lock_date);
--dbms_output.put_line('JOEL - validate_lock 1 '||(sysdate-(1/24/60)*10));

IF p_lock_date > (sysdate-(1/24/60)*10) THEN
     -- now we need to check following who is locking
     -- if we can still grant a lock
     check_grant (p_locker_type_owner_id     => p_locker_type_owner_id
                 ,p_locker_type_requestor_id => p_locker_type_requestor_id
                 ,p_messages                 => p_messages
                 ,p_grant_lock               => l_grant
                 );

--dbms_output.put_line('JOEL - validate_lock 2 '||l_grant);

     IF l_grant = 'N' THEN
       p_valid_lock := TRUE;
     END IF;

END IF;

END validate_lock;
*/

-- ----------------------------------------------------------------------------
-- |---------------------------< insert_lock	       > ----------------------|
-- ----------------------------------------------------------------------------

PROCEDURE insert_lock (p_locker_type_id IN NUMBER
         	      ,p_resource_id	IN NUMBER
         	      ,p_start_time	IN DATE
         	      ,p_stop_time	IN DATE
         	      ,p_time_building_block_id  IN NUMBER
         	      ,p_time_building_block_ovn IN NUMBER
         	      ,p_transaction_lock_id	 IN NUMBER
                      ,p_expiration_time	 IN NUMBER
         	      ,p_row_lock_id             IN OUT NOCOPY ROWID) IS

PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN

g_debug := hr_utility.debug_enabled;

--dbms_output.put_line('JOEL - insert_lock 1 p_start_time '||p_start_time);
--dbms_output.put_line('JOEL - insert_lock 1 p_stop_time '||p_stop_time);

if g_debug then
	hr_utility.trace('JOEL - insert_lock 1 p_start_time '||p_start_time);
end if;

  insert into hxc_locks
  (LOCKER_TYPE_ID
  ,RESOURCE_ID
  ,START_TIME
  ,STOP_TIME
  ,TIME_BUILDING_BLOCK_ID
  ,TIME_BUILDING_BLOCK_OVN
  ,LOCK_DATE
  ,PROCESS_ID
  ,ATTRIBUTE1
  ,ATTRIBUTE2
  ,TRANSACTION_LOCK_ID)
  values
  (p_locker_type_id
  ,p_resource_id
  ,p_start_time
  ,p_stop_time
  ,p_time_building_block_id
  ,p_time_building_block_ovn
  ,sysdate + (1/24/60)*p_expiration_time
  ,fnd_global.user_id
  ,to_char(fnd_global.employee_id)
  ,to_char(fnd_global.session_id)
  ,p_transaction_lock_id
  ) RETURNING ROWID into p_row_lock_id;

  COMMIT;


END insert_lock;

-- ----------------------------------------------------------------------------
-- |---------------------------< delete_lock	       > ----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_lock(p_rowid               IN ROWID
                     ,p_locker_type_id      IN NUMBER
                     ,p_process_locker_type IN VARCHAR2
                     ,p_messages            IN OUT NOCOPY HXC_MESSAGE_TABLE_TYPE) IS

PRAGMA AUTONOMOUS_TRANSACTION;

cursor c_rowid_info is
select scope , b.time_building_block_id, a.locker_type_id
from   hxc_locks a ,hxc_time_building_blocks b
where  a.rowid = p_rowid
and    b.time_building_block_id  = a.time_building_block_id
and    b.object_version_number = a.time_building_block_ovn ;


cursor c_app_period_detail (p_app_period_id number) is
select time_building_block_id, time_building_block_ovn
from   hxc_ap_detail_links
where  application_period_id = p_app_period_id;

l_scope	VARCHAR2(80);
l_app_period_id NUMBER;
l_locker_type_id	NUMBER;

BEGIN

g_debug := hr_utility.debug_enabled;

-- we need to check what is the scope of the rowid
-- and following the scope then we might need
-- to delete some parents



if g_debug then
	hr_utility.trace('JOEL - delete_lock 0 ');
end if;


OPEN c_rowid_info;
FETCH c_rowid_info INTO l_scope,l_app_period_id,l_locker_type_id;
CLOSE c_rowid_info;

if g_debug then
	hr_utility.trace('JOEL - delete_lock 1 '||l_app_period_id);
	hr_utility.trace('JOEL - delete_lock 1 '||l_scope);

	hr_utility.trace('JOEL - delete_lock 1 '||l_app_period_id);
end if;

IF l_scope = 'APPLICATION_PERIOD' THEN
   -- we need to delete the childs
   -- we need to lock all the details for this application period
   IF l_locker_type_id is null THEN
     IF p_locker_type_id is null THEN
       l_locker_type_id := hxc_lock_util.get_locker_type_req_id
                     (p_process_locker_type    => p_process_locker_type
                     ,p_messages               => p_messages);
     ELSE
      l_locker_type_id := p_locker_type_id;
     END IF;
   END IF;

if g_debug then
	hr_utility.trace('JOEL - delete_lock 2 '||l_locker_type_id);
end if;

   FOR crs_app_period_detail in c_app_period_detail(l_app_period_id)
   LOOP

if g_debug then
	hr_utility.trace('JOEL - delete_lock 3 '||crs_app_period_detail.time_building_block_id);
	hr_utility.trace('JOEL - delete_lock 3 '||crs_app_period_detail.time_building_block_ovn);
end if;

       -- if we arrive here that means we did not find a detail
       -- locked and then we can insert a new lock
       hxc_lock_util.delete_tbb_lock
                   (p_locker_type_id          => l_locker_type_id
         	   ,p_time_building_block_id  => crs_app_period_detail.time_building_block_id
                   ,p_time_building_block_ovn => crs_app_period_detail.time_building_block_ovn);
   END LOOP;

END IF;


delete from hxc_locks
where rowid = p_rowid;

COMMIT;

END delete_lock;

-- ----------------------------------------------------------------------------
-- |------------------------< delete_transaction_lock >  ----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_transaction_lock
                     (p_transaction_lock_id IN NUMBER
                     ,p_process_locker_type IN VARCHAR2
                     ,p_messages            IN OUT NOCOPY HXC_MESSAGE_TABLE_TYPE)
                     IS

PRAGMA AUTONOMOUS_TRANSACTION;

l_locker_type_id	NUMBER;

BEGIN

l_locker_type_id := hxc_lock_util.get_locker_type_req_id
                     (p_process_locker_type    => p_process_locker_type
                     ,p_messages               => p_messages);


delete from hxc_locks
where transaction_lock_id = p_transaction_lock_id
and   locker_type_id = l_locker_type_id;

COMMIT;

END delete_transaction_lock;


-- ----------------------------------------------------------------------------
-- |---------------------------< get_locker_type_req_id > ----------------------|
-- ----------------------------------------------------------------------------
FUNCTION get_locker_type_req_id
                     (p_process_locker_type      IN VARCHAR
                     ,p_messages  	         IN OUT NOCOPY HXC_MESSAGE_TABLE_TYPE)
                     RETURN NUMBER IS


cursor c_locker_type_requestor (p_locker_type  VARCHAR2
                               ,p_process_type VARCHAR2) is
select locker_type_id
from   hxc_locker_types
where  locker_type  = p_locker_type
and    process_type = p_process_type;

l_locker_type_requestor_id  NUMBER := NULL;

BEGIN

IF p_process_locker_type = c_ss_timecard_action THEN

    OPEN  c_locker_type_requestor (c_self_service,c_timecard_action);
    FETCH c_locker_type_requestor into l_locker_type_requestor_id;
    CLOSE c_locker_type_requestor;

ELSIF p_process_locker_type = c_ss_timecard_view THEN

    OPEN  c_locker_type_requestor (c_self_service,c_timecard_view);
    FETCH c_locker_type_requestor into l_locker_type_requestor_id;
    CLOSE c_locker_type_requestor;

ELSIF p_process_locker_type = c_ss_approval_action THEN

   OPEN  c_locker_type_requestor (c_self_service,c_approval_action);
   FETCH c_locker_type_requestor into l_locker_type_requestor_id;
   CLOSE c_locker_type_requestor;

ELSIF p_process_locker_type = c_pui_timekeeper_action THEN

   OPEN  c_locker_type_requestor (c_pui,c_timekeeper_action);
   FETCH c_locker_type_requestor into l_locker_type_requestor_id;
   CLOSE c_locker_type_requestor;

ELSIF p_process_locker_type = c_plsql_pay_retrieval_action THEN

   OPEN  c_locker_type_requestor (c_plsql,c_pay_retrieval_action);
   FETCH c_locker_type_requestor into l_locker_type_requestor_id;
   CLOSE c_locker_type_requestor;

ELSIF p_process_locker_type = c_plsql_pa_retrieval_action THEN

   OPEN  c_locker_type_requestor (c_plsql,c_pa_retrieval_action);
   FETCH c_locker_type_requestor into l_locker_type_requestor_id;
   CLOSE c_locker_type_requestor;

ELSIF p_process_locker_type = c_plsql_eam_retrieval_action THEN

   OPEN  c_locker_type_requestor (c_plsql,c_eam_retrieval_action);
   FETCH c_locker_type_requestor into l_locker_type_requestor_id;
   CLOSE c_locker_type_requestor;

ELSIF p_process_locker_type = c_plsql_deposit_action THEN

   OPEN  c_locker_type_requestor (c_plsql,c_deposit_action);
   FETCH c_locker_type_requestor into l_locker_type_requestor_id;
   CLOSE c_locker_type_requestor;

ELSIF p_process_locker_type = c_plsql_po_retrieval_action THEN

   OPEN  c_locker_type_requestor (c_plsql,c_po_retrieval_action);
   FETCH c_locker_type_requestor into l_locker_type_requestor_id;
   CLOSE c_locker_type_requestor;

ELSIF p_process_locker_type = c_plsql_coa_action THEN

   OPEN  c_locker_type_requestor (c_plsql,c_coa_action);
   FETCH c_locker_type_requestor into l_locker_type_requestor_id;
   CLOSE c_locker_type_requestor;

ELSIF p_process_locker_type = c_plsql_ar_action THEN

   OPEN  c_locker_type_requestor (c_plsql,c_ar_action);
   FETCH c_locker_type_requestor into l_locker_type_requestor_id;
   CLOSE c_locker_type_requestor;

ELSE
   -- in the other case we raise an error.
   hxc_timecard_message_helper.addErrorToCollection
           (p_messages 		=> p_messages
           ,p_message_name      => 'HXC_LOCK_PARAM_RULE'
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
   RETURN NULL;

END IF;

RETURN l_locker_type_requestor_id;

END get_locker_type_req_id;

-- ----------------------------------------------------------------------------
-- |---------------------------< checking_lock         > ----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE check_row_lock
         (p_locker_type_requestor_id    IN NUMBER
         ,p_process_locker_type        	IN VARCHAR2
         ,p_resource_id			IN NUMBER
         ,p_time_building_block_id 	IN NUMBER
         ,p_time_building_block_ovn 	IN NUMBER
         ,p_messages			IN OUT NOCOPY HXC_MESSAGE_TABLE_TYPE
         ,p_row_locked                  OUT NOCOPY BOOLEAN)
         IS

cursor c_lock (p_tbb_id number, p_tbb_ovn number) is
select locker_type_id, lock_date, rowid, resource_id, process_id,attribute2
from   hxc_locks
where  time_building_block_id  = p_tbb_id
and    time_building_block_ovn = p_tbb_ovn;

cursor c_full_name (p_resource_id in number) is
select full_name
from  per_all_people_f
where person_id = p_resource_id
and sysdate between effective_start_date and effective_end_date;


--l_valid_lock		BOOLEAN := FALSE;
l_grant			VARCHAR2(1);

l_full_name 		VARCHAR2(240);

l_locked_same_user_session	BOOLEAN := FALSE;

BEGIN

g_debug := hr_utility.debug_enabled;

--dbms_output.put_line('JOEL - check_row_lock 0: '||p_time_building_block_id);
--dbms_output.put_line('JOEL - check_row_lock 0: '||p_time_building_block_ovn);

if g_debug then
	hr_utility.trace('JOEL - check_row_lock 0: '||p_time_building_block_id);
end if;

FOR csr_lock in c_lock(p_time_building_block_id,p_time_building_block_ovn) LOOP

--dbms_output.put_line('JOEL - check_row_lock 1: l_locker_type_owner_id '||csr_lock.locker_type_id);
--dbms_output.put_line('JOEL - check_row_lock 1: l_lock_date '||csr_lock.lock_date);
--dbms_output.put_line('JOEL - check_row_lock 1: l_lock_rowid '||csr_lock.rowid);
-- we found the lock
if g_debug then
	hr_utility.trace('JOEL - check_row_lock 0: '||p_time_building_block_id);
	hr_utility.trace('JOEL - check_row_lock 0: '||p_time_building_block_ovn);
end if;

--dbms_output.put_line('JOEL - check_row_lock 2 ');

   -- this procedure check if the lock is not expire
   -- and look in the locking_rules table if the lock
   -- can be overruled
   IF csr_lock.lock_date > (sysdate-(1/24/60)*10) THEN

    -- in the case that the lock is a different session
    -- for the same user_id that would mean
    -- we have a new browser, therefore we should allowed
    -- the lock and no check for the grant.
    l_locked_same_user_session := FALSE;

    IF p_process_locker_type = c_ss_timecard_action
    --OR p_process_locker_type = c_ss_timecard_view
    THEN
       l_locked_same_user_session
                 := check_session
                     (p_current_session_id 	 => fnd_global.session_id
                     ,p_current_user_id          => fnd_global.user_id
                     ,p_current_resource_id      => p_resource_id
                     ,p_lock_session_id          => to_number(csr_lock.attribute2)
                     ,p_lock_user_id             => csr_lock.process_id
                     ,p_lock_resource_id	 => csr_lock.resource_id);
    ELSE
       l_locked_same_user_session := FALSE;
    END IF;
/*

if g_debug then
	hr_utility.trace('p_current_session_id '||fnd_global.session_id);
	hr_utility.trace('p_current_user_id '||fnd_global.user_id);
	hr_utility.trace('p_lock_session_id '||to_number(csr_lock.attribute2));
	hr_utility.trace('p_lock_user_id '||csr_lock.process_id);
end if;

IF (l_locked_same_user_session) THEN
  if g_debug then
  	hr_utility.trace('l_locked_same_user_session is true');
  end if;
END IF;


*/

    IF not(l_locked_same_user_session) THEN

      -- now we need to check following who is locking
      -- if we can still grant a lock
      check_grant (p_locker_type_owner_id     => csr_lock.locker_type_id
                 ,p_locker_type_requestor_id => p_locker_type_requestor_id
                 ,p_messages                 => p_messages
                 ,p_grant_lock               => l_grant
                 );

if g_debug then
	hr_utility.trace('JOEL - check_row_lock 3 '||l_grant);
end if;

     IF l_grant = 'N' THEN

--dbms_output.put_line('JOEL - check_row_lock 4 ');

       p_row_locked  := TRUE;

       OPEN c_full_name (csr_lock.resource_id);
       FETCH c_full_name into l_full_name;
       CLOSE c_full_name;

       hxc_timecard_message_helper.addErrorToCollection
           (p_messages 		=> p_messages
           ,p_message_name      => 'HXC_TIMECARD_LOCKED'
           ,p_message_level     => 'ERROR'
           ,p_message_field     => null
           ,p_message_tokens    => 'FULL_NAME&'||nvl(l_full_name,'unknown')
           ,p_application_short_name  => 'HXC'
           ,p_time_building_block_id  => p_time_building_block_id
           ,p_time_building_block_ovn => p_time_building_block_ovn
           ,p_time_attribute_id       => null
           ,p_time_attribute_ovn      => null
           ,p_message_extent          => 'BLK_AND_CHILDREN'
           );

       RETURN;
     END IF;
    ELSE
       -- we need to remove the row just found
       -- and insert the new lock
if g_debug then
	hr_utility.trace('JOEL - check_row_lock 4 ');
	hr_utility.trace('JOEL - delete_lock 1 ');
end if;

       hxc_lock_util.delete_lock
                (p_rowid               => csr_lock.rowid
                ,p_locker_type_id      => csr_lock.locker_type_id
                ,p_process_locker_type => null
                ,p_messages	       => p_messages);

    END IF;
   ELSE

if g_debug then
	hr_utility.trace('JOEL - check_row_lock 5 ');
end if;

       -- we need to remove the row just found
       -- and insert the new lock
if g_debug then
	hr_utility.trace('JOEL - delete_lock 2 ');
end if;
       hxc_lock_util.delete_lock
                (p_rowid               => csr_lock.rowid
                ,p_locker_type_id      => csr_lock.locker_type_id
                ,p_process_locker_type => null
                ,p_messages	       => p_messages);

    END IF;

END LOOP;



END check_row_lock;


-- ----------------------------------------------------------------------------
-- |---------------------------< check_date_lock         > ----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE check_date_lock
         (p_locker_type_requestor_id    IN NUMBER
         ,p_locker_type_owner_id	IN NUMBER
         ,p_process_locker_type        	IN VARCHAR2
         ,p_lock_date		 	IN DATE
         ,p_lock_start_time             IN DATE
         ,p_lock_stop_time              IN DATE
         ,p_start_time			IN DATE
         ,p_stop_time			IN DATE
         ,p_time_building_block_id 	IN NUMBER
         ,p_time_building_block_ovn     IN NUMBER
         ,p_resource_id			IN NUMBER
         ,p_process_id			IN NUMBER
         ,p_attribute2			IN VARCHAR2
         ,p_rowid			IN ROWID
         ,p_messages			IN OUT NOCOPY HXC_MESSAGE_TABLE_TYPE
         ,p_row_locked                  OUT NOCOPY BOOLEAN)
         IS

cursor c_full_name is
select full_name
from  per_all_people_f
where person_id = p_resource_id
and sysdate between effective_start_date and effective_end_date;

--l_valid_lock		BOOLEAN := FALSE;
l_grant			VARCHAR2(1);

l_full_name 		VARCHAR2(240);

l_locked_same_user_session	BOOLEAN := FALSE;

BEGIN

g_debug := hr_utility.debug_enabled;

if g_debug then
	hr_utility.trace('JOEL - check_date_lock 1: p_locker_type_requestor_id '||p_locker_type_requestor_id);
	hr_utility.trace('JOEL - check_date_lock 1: p_locker_type_owner_id '||p_locker_type_owner_id);
	hr_utility.trace('JOEL - check_date_lock 1: p_lock_date '||p_lock_date);
end if;
-- we found the lock

-- this procedure check if the lock is not expire
-- and look in the locking_rules table if the lock
-- can be overruled
IF p_lock_date > (sysdate-(1/24/60)*10) THEN

    -- in the case that the lock is a different session
    -- for the same user_id that would mean
    -- we have a new browser, therefore we should allowed
    -- the lock and no check for the grant.
    IF p_process_locker_type = c_ss_timecard_action
    OR p_process_locker_type = c_ss_timecard_view
    THEN
       l_locked_same_user_session
                 := check_session
                     (p_current_session_id 	 => fnd_global.session_id
                     ,p_current_user_id          => fnd_global.user_id
                     ,p_current_resource_id      => p_resource_id
                     ,p_lock_session_id          => to_number(p_attribute2)
                     ,p_lock_user_id             => p_process_id
                     ,p_lock_resource_id         => null);

    ELSE
       l_locked_same_user_session := FALSE;
    END IF;
/*

if g_debug then
	hr_utility.trace('p_current_session_id '||fnd_global.session_id);
	hr_utility.trace('p_current_user_id '||fnd_global.user_id);
	hr_utility.trace('p_lock_session_id '||to_number(p_attribute2));
	hr_utility.trace('p_lock_user_id '||p_process_id);
end if;

IF (l_locked_same_user_session) THEN
  if g_debug then
  	hr_utility.trace('l_locked_same_user_session is true');
  end if;
END IF;
*/



    IF not(l_locked_same_user_session) THEN

     -- now we need to check following who is locking
     -- if we can still grant a lock
     check_grant (p_locker_type_owner_id     => p_locker_type_owner_id
                 ,p_locker_type_requestor_id => p_locker_type_requestor_id
                 ,p_messages                 => p_messages
                 ,p_grant_lock               => l_grant
                 );

if g_debug then
	hr_utility.trace('JOEL - check_date_lock 3 '||l_grant);
end if;


     IF l_grant = 'N' THEN

if g_debug then
	hr_utility.trace('JOEL - check_date_lock 4 ');

	hr_utility.trace('JOEL - check_date_lock 5: p_lock_start_time '||p_lock_start_time);
	hr_utility.trace('JOEL - check_date_lock 5: p_lock_stop_time '||p_lock_stop_time);
	hr_utility.trace('JOEL - check_date_lock 5: p_start_time '||p_start_time);
	hr_utility.trace('JOEL - check_date_lock 5: p_stop_time '||p_stop_time);
end if;

  -- bug 3097592.

/*        IF  (p_lock_start_time between p_start_time and p_stop_time)
        OR  (p_lock_stop_time  between p_start_time and p_stop_time)
        THEN
*/
        IF  (trunc(p_lock_start_time) between  p_start_time      and p_stop_time)
        OR  (trunc(p_lock_stop_time)  between  p_start_time      and p_stop_time)
	OR  (trunc(p_start_time)      between  p_lock_start_time and p_lock_stop_time)
	OR  (trunc(p_stop_time)       between  p_lock_start_time and p_lock_stop_time)
        THEN
  -- bug 3097592.

if g_debug then
	hr_utility.trace('JOEL - check_date_lock 6 ');
end if;

           p_row_locked := TRUE;

           OPEN c_full_name;
           FETCH c_full_name into l_full_name;
           CLOSE c_full_name;

           hxc_timecard_message_helper.addErrorToCollection
           (p_messages 		=> p_messages
           ,p_message_name      => 'HXC_TIMECARD_LOCKED'
           ,p_message_level     => 'ERROR'
           ,p_message_field     => null
           ,p_message_tokens    => 'FULL_NAME&'||nvl(l_full_name,'unknown')
           ,p_application_short_name  => 'HXC'
           ,p_time_building_block_id  => p_time_building_block_id
           ,p_time_building_block_ovn => p_time_building_block_ovn
           ,p_time_attribute_id       => null
           ,p_time_attribute_ovn      => null
           ,p_message_extent          => 'BLK_AND_CHILDREN'
           );

          RETURN;
        END IF;

     END IF;
   ELSE
       -- we need to remove the row just found
       -- and insert the new lock
if g_debug then
	hr_utility.trace('JOEL - delete_lock 4 ');
end if;
       hxc_lock_util.delete_lock
                (p_rowid               => p_rowid
                ,p_locker_type_id      => p_locker_type_owner_id
                ,p_process_locker_type => null
                ,p_messages	       => p_messages);

    END IF;


ELSE

--dbms_output.put_line('JOEL - check_date_lock 7 ');

       -- we need to remove the row just found
       -- and insert the new lock
if g_debug then
	hr_utility.trace('JOEL - delete_lock 5 ');
end if;
       hxc_lock_util.delete_lock
                (p_rowid               => p_rowid
                ,p_locker_type_id      => p_locker_type_owner_id
                ,p_process_locker_type => null
                ,p_messages	       => p_messages);

END IF;


END check_date_lock;



-- ----------------------------------------------------------------------------
-- |---------------------------< delete_tbb_lock      > ----------------------|
-- ----------------------------------------------------------------------------

PROCEDURE delete_tbb_lock (p_locker_type_id   IN NUMBER
          	          ,p_time_building_block_id  IN NUMBER
         	          ,p_time_building_block_ovn IN NUMBER) IS

PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN

delete from hxc_locks
where time_building_block_id = p_time_building_block_id
and   time_building_block_ovn = p_time_building_block_ovn
and   locker_type_id = p_locker_type_id;

COMMIT;

END delete_tbb_lock;

-- ----------------------------------------------------------------------------
-- |---------------------------< delete_period_lock    > ----------------------|
-- ----------------------------------------------------------------------------

PROCEDURE delete_period_lock
                      (p_locker_type_id   IN NUMBER
         	      ,p_resource_id	IN NUMBER
         	      ,p_start_time	IN DATE
         	      ,p_stop_time	IN DATE) IS

PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN

--dbms_output.put_line('JOEL - delete_period_lock 1 '||p_locker_type_id);
--dbms_output.put_line('JOEL - delete_period_lock 1 '||p_resource_id);
--dbms_output.put_line('JOEL - delete_period_lock 1 '||p_start_time);
--dbms_output.put_line('JOEL - delete_period_lock 1 '||p_stop_time);

delete from hxc_locks
where resource_id = p_resource_id
and   locker_type_id = p_locker_type_id
and   start_time = p_start_time
and   stop_time  = p_stop_time;

COMMIT;

END delete_period_lock;

END HXC_LOCK_UTIL;

/
