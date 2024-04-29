--------------------------------------------------------
--  DDL for Package Body HXC_ABS_INTG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_ABS_INTG_PKG" as
/* $Header: hxcabsint.pkb 120.1.12010000.8 2009/10/15 06:23:37 sabvenug noship $ */

g_debug boolean := hr_utility.debug_enabled;

PROCEDURE HXC_TC_CHECK	(p_resource_id		IN	VARCHAR2,
			 p_start_time		IN	DATE,
			 p_stop_time		IN	DATE,
			 p_tc_sum_exists	OUT NOCOPY	BOOLEAN,
			 p_tc_lock_exists	OUT NOCOPY	BOOLEAN)

IS

l_sum_check	VARCHAR2(1):='0';
l_lock_check	VARCHAR2(1):='0';

CURSOR tc_sum_check(p_resource_id	IN 	NUMBER,
		    p_start_time	IN	DATE,
		    p_stop_time		IN	DATE)
	IS

select '1'
from	hxc_timecard_summary
where	resource_id = p_resource_id
  and   start_time <= p_stop_time
  and	stop_time >= p_start_time;
  --and   approval_status <> 'ERROR';  -- Added Error TC check Bug 9014012


CURSOR tc_lock_check(p_resource_id	IN 	NUMBER,
		     p_start_time	IN	DATE,
		     p_stop_time	IN	DATE)
	IS

select '1'
from	hxc_locks
where	resource_id = p_resource_id
  and	start_time <= p_stop_time
  and	stop_time >= p_start_time
  and   (sysdate - lock_date) < (20/(24*60)); -- Added 20 min max locking period Bug 9014012




BEGIN

-- Timecard Summary check
if g_debug then
	hr_utility.trace('Entered HXC_TC_CHECK');
end if;


open tc_sum_check(p_resource_id,
                  p_start_time,
                  p_stop_time);

Fetch tc_sum_check into l_sum_check;

IF (tc_sum_check%FOUND) then

	p_tc_sum_exists := TRUE;

        if g_debug then
		hr_utility.trace('p_tc_sum_exists is TRUE');
	end if;

ELSE

	p_tc_sum_exists := FALSE;

        if g_debug then
		hr_utility.trace('p_tc_sum_exists is FALSE');
	end if;

END IF;

CLOSE tc_sum_check;




-- Hxc Locks Check

open tc_lock_check(p_resource_id,
                  p_start_time,
                  p_stop_time + g_one_day);

Fetch tc_lock_check into l_sum_check;

IF (tc_lock_check%FOUND) then

	p_tc_lock_exists := TRUE;

	if g_debug then
		hr_utility.trace('p_tc_sum_exists is TRUE');
	end if;

ELSE

	p_tc_lock_exists := FALSE;

	if g_debug then
		hr_utility.trace('p_tc_sum_exists is FALSE');
	end if;

END IF;

CLOSE tc_lock_check;

        if g_debug then
		hr_utility.trace('Leaving HXC_TC_CHECK');
	end if;

END; -- hxc_tc_check








--------------------------------------------------------------------------------------------


PROCEDURE otl_timecard_chk(p_person_id		IN 	NUMBER,
			   p_start_time		IN	DATE,
			   p_stop_time		IN	DATE,
			   p_error_code		OUT NOCOPY     VARCHAR2,
			   p_error_level	OUT NOCOPY	NUMBER,
			    p_abs_att_id		IN	NUMBER	DEFAULT -1)
IS

l_tc_sum_exists 	BOOLEAN:=FALSE;
l_tc_lock_exists	BOOLEAN:=FALSE;

l_pref_set		VARCHAR2(1):='N';
l_profile_set		VARCHAR2(1):='N';

l_pref_table   	    hxc_preference_evaluation.t_pref_table;
l_pref_index			NUMBER;

l_abs_att_id_count	NUMBER:=0;

/* Bug 9014012 -- Abs Attendance id imported to OTL check */
CURSOR abs_att_id_check (p_abs_att_id	IN NUMBER)
IS
select 1
  from hxc_absence_type_elements
 where absence_attendance_type_id = p_abs_att_id;



BEGIN

if g_debug then
	hr_utility.trace('Entered otl_timecard_chk');
end if;

OPEN abs_att_id_check(p_abs_att_id);
FETCH abs_att_id_check into l_abs_att_id_count;

IF (abs_att_id_check%FOUND OR p_abs_att_id=-1) then

 l_profile_set:= NVL(fnd_profile.value('HR_ABS_OTL_INTEGRATION'),'N');

 if g_debug then
	hr_utility.trace('Profile Value = '|| l_profile_set );
 end if;


 IF l_profile_set<>'Y' then

 p_error_level:=0;
 p_error_code:= 'HR OTL Integration Profile Not set';


 if g_debug then
	hr_utility.trace(' No OTL Intg Profile Set');
 end if;


 ELSE

    if g_debug then
    	hr_utility.trace('Going to call OTL Pref');
    end if;

    hxc_preference_evaluation.resource_preferences
    	                 (p_person_id,
    	    	          p_start_time,
    	    	          p_start_time,
    	                  l_pref_table);

    if g_debug then
    	hr_utility.trace('Came out of OTL Pref');
    end if;

    l_pref_index := l_pref_table.FIRST;
    LOOP
       IF l_pref_table(l_pref_index).preference_code = 'TS_ABS_PREFERENCES'
       THEN
           l_pref_set := NVL(l_pref_table(l_pref_index).attribute1,
                              'N');
           EXIT;
       END IF;
       l_pref_index := l_pref_table.NEXT(l_pref_index);
       EXIT WHEN NOT l_pref_table.EXISTS(l_pref_index);
     END LOOP;

    if g_debug then
    	hr_utility.trace('OTL Pref Setting for this resource = '||l_pref_set);
    end if;

     IF l_pref_set <>'Y' then

       p_error_level:=0;
       p_error_code:= 'No OTL Absence Preferences';

       if g_debug then
        	hr_utility.trace('No OTL Pref');
       end if;

     ELSE

        hxc_tc_check (p_resource_id => p_person_id,
		      p_start_time => p_start_time,
		      p_stop_time => p_stop_time,
		      p_tc_sum_exists    => l_tc_sum_exists,
		      p_tc_lock_exists   => l_tc_lock_exists);

	if g_debug then
        	hr_utility.trace('Came out of hxc_tc_check');
        end if;


	if p_start_time > p_stop_time then

		p_error_level:=-1;
		p_error_code:='Error: Start Date Greater than End Date';

		if g_debug then
			hr_utility.trace('p_error_level1 = '||p_error_level);
		end if;

	elsif (l_tc_lock_exists) then

		p_error_level:=2;
		p_error_code:= 'OTL Timecard is locked';

		if g_debug then
			hr_utility.trace('p_error_level2 = '||p_error_level);
		end if;

	ELSIF (l_tc_sum_exists) then

		p_error_level:=1;
		p_error_code:= 'OTL Timecard Exists';

		if g_debug then
			hr_utility.trace('p_error_level3 = '||p_error_level);
		end if;

	ELSE

		p_error_level:=0;
		p_error_code:='No OTL Timecard Exists';

		if g_debug then
			hr_utility.trace('p_error_level4 = '||p_error_level);
		end if;

	END IF; -- l_tc_lock_exists and l_tc_sum_exists

      END IF; --  l_pref_set

 END IF ; -- l_profile_set

ELSE -- abs_att_id_check%FOUND

 p_error_level:=0;
 p_error_code:='Element Not Imported to OTL';

END IF; -- abs_att_id_check%FOUND


CLOSE abs_att_id_check;



if g_debug then
	hr_utility.trace('Leaving otl_timecard_chk');
end if;

END; --otl_timecard_chk ;

-----------------------------------------------------------------------------------------




end;

/
