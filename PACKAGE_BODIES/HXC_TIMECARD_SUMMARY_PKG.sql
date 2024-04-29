--------------------------------------------------------
--  DDL for Package Body HXC_TIMECARD_SUMMARY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_TIMECARD_SUMMARY_PKG" as
/* $Header: hxctcsum.pkb 120.4.12010000.8 2010/01/08 08:14:14 bbayragi ship $ */

g_debug boolean := hr_utility.debug_enabled;
g_check_for_reasons varchar2(1) := null;

function get_migration_apr_status
           (p_timecard_id  in hxc_time_building_blocks.time_building_block_id%type
           ,p_timecard_ovn in hxc_time_building_blocks.object_version_number%type
           ) return varchar2 is

begin

return hxc_timecard_search_pkg.get_timecard_status_code(p_timecard_id,p_timecard_ovn,c_migration_mode);

end get_migration_apr_status;

procedure get_recorded_hours
           (p_timecard_id  in            hxc_time_building_blocks.time_building_block_id%type
           ,p_timecard_ovn in            hxc_time_building_blocks.object_version_number%type
           ,p_hours           out nocopy number
           ,p_details         out nocopy details
           ) is

cursor c_detail_info(p_id in hxc_time_building_blocks.time_building_block_id%type
                    ,p_ovn in hxc_time_building_blocks.object_version_number%type
                    ) is
  select details.time_building_block_id
        ,details.object_version_number
        ,details.start_time
        ,details.stop_time
        ,details.measure
        ,details.type
        ,details.creation_date
    from hxc_time_building_blocks days, hxc_time_building_blocks details
   where days.parent_building_block_id = p_id
     and days.parent_building_block_ovn = p_ovn
     and details.parent_building_block_id = days.time_building_block_id
     and details.parent_building_block_ovn = days.object_version_number
     and days.date_to = hr_general.end_of_time
     and details.date_to = hr_general.end_of_time;

CURSOR c_tc_resource_id(
          p_timecard_id hxc_time_building_blocks.time_building_block_id%TYPE,
	  p_timecard_ovn hxc_time_building_blocks.object_version_number%TYPE
        ) IS
SELECT tbb.resource_id
FROM   hxc_time_building_blocks tbb
WHERE  tbb.time_building_block_id = p_timecard_id
AND    tbb.object_version_number = p_timecard_ovn;

/* Bug fix for 5526281 */
CURSOR get_timecard_start_date(p_timecard_id hxc_time_building_blocks.time_building_block_id%TYPE,
			       p_timecard_ovn hxc_time_building_blocks.object_version_number%TYPE
			      ) IS
SELECT tbb.start_time,tbb.stop_time
FROM   hxc_time_building_blocks tbb
WHERE  tbb.time_building_block_id = p_timecard_id
AND    tbb.object_version_number = p_timecard_ovn;

cursor emp_hire_info(p_resource_id hxc_time_building_blocks.resource_id%TYPE) IS
select date_start from per_periods_of_service where person_id=p_resource_id order by date_start desc;
/* end of bug fix for 5526281 */

l_index                 number :=1;
l_precision             varchar2(4);
l_resource_id           number;
l_rounding_rule         varchar2(80);
l_tc_start_date         date;

/* Bug fix for 5526281 */
l_tc_end_date           date;
l_pref_eval_date	date;
l_emp_hire_date		date;
/* end of bug fix for 5526281 */

begin

open c_tc_resource_id(p_timecard_id, p_timecard_ovn);
fetch c_tc_resource_id into l_resource_id;
close c_tc_resource_id;

/* Bug fix for 5526281 */
OPEN  get_timecard_start_date (p_timecard_id, p_timecard_ovn);
FETCH get_timecard_start_date into l_tc_start_date,l_tc_end_date;
CLOSE get_timecard_start_date;

OPEN  emp_hire_info (l_resource_id);
FETCH emp_hire_info into l_emp_hire_date;
CLOSE emp_hire_info;

if trunc(l_emp_hire_date) >= trunc(l_tc_start_date) and trunc(l_emp_hire_date) <= trunc(l_tc_end_date) then
	l_pref_eval_date := trunc(l_emp_hire_date);
else
	l_pref_eval_date := trunc(l_tc_start_date);
end if;

l_precision := hxc_preference_evaluation.resource_preferences
                                              (l_resource_id,
                                               'TC_W_TCRD_UOM',
                                               3,
                                               l_pref_eval_date);


l_rounding_rule := hxc_preference_evaluation.resource_preferences
                                              (l_resource_id,
                                               'TC_W_TCRD_UOM',
                                               4,
                                               l_pref_eval_date);
/* end of bug fix for 5526281 */
if l_precision is null
then
l_precision := '2';
end if;

if l_rounding_rule is null
then
l_rounding_rule := 'ROUND_TO_NEAREST';
end if;
p_hours := 0;

  for det_rec in c_detail_info(p_timecard_id,p_timecard_ovn) loop

    p_details(l_index).time_building_block_id := det_rec.time_building_block_id;
    p_details(l_index).time_building_block_ovn := det_rec.object_version_number;
    p_details(l_index).creation_date := det_rec.creation_date;
    if(det_rec.type=hxc_timecard.c_range_type) then
      p_hours := p_hours + hxc_find_notify_aprs_pkg.apply_round_rule(
                                            l_rounding_rule,
					    l_precision,
                                            nvl((det_rec.stop_time - det_rec.start_time)*24,0)
					    );
    else
      -- in case of null measure we need to make sure this piece of code does not fail
      -- and do not return null
      -- 2029550 Implementation
      p_hours := p_hours + hxc_find_notify_aprs_pkg.apply_round_rule(
                                            l_rounding_rule,
					    l_precision,
                                            nvl(det_rec.measure,0)
					    );
    end if;

    l_index := l_index +1;
  end loop;

if(p_hours is null) then
  p_hours := 0;
end if;

end get_recorded_hours;

function get_has_reasons(p_details in details) return varchar2 is

cursor c_reasons
        (p_id in hxc_time_building_blocks.time_building_block_id%type
        ) is
  select 'Y'
    from hxc_time_attribute_usages tau, hxc_time_attributes ta
   where tau.time_building_block_id = p_id
     and tau.time_Attribute_id = ta.time_attribute_Id
     and ta.attribute_category = hxc_timecard.c_reason_attribute;

l_index  number;
l_found  boolean := false;
l_result varchar2(1) := 'N';

begin

l_index := p_details.first;

loop
  exit when ((not p_details.exists(l_index)) or (l_found));

  open c_reasons(p_details(l_index).time_building_block_id);
  fetch c_reasons into l_result;
  if(c_reasons%found) then
    l_found := true;
  end if;
  close c_reasons;

  l_index := p_details.next(l_index);

end loop;

return l_result;

end get_has_reasons;

function get_submission_date(p_details in details
                            ,p_tc_date in date)
                            return date is
l_submission_date date := p_tc_date;
l_index           number;
begin

l_index := p_details.first;
loop
  exit when not p_details.exists(l_index);
    if(l_submission_date < p_details(l_index).creation_date) then
      l_submission_date := p_details(l_index).creation_date;
    end if;
  l_index := p_details.next(l_index);
end loop;

return l_submission_date;

end get_submission_date;

procedure insert_summary_row(p_timecard_id           in hxc_time_building_blocks.time_building_block_id%type
                            ,p_mode                  in varchar2 default 'NORMAL'
                            ,p_attribute_category    in varchar2 default null
                            ,p_attribute1            in varchar2 default null
                            ,p_attribute2            in varchar2 default null
                            ,p_attribute3            in varchar2 default null
                            ,p_attribute4            in varchar2 default null
                            ,p_attribute5            in varchar2 default null
                            ,p_attribute6            in varchar2 default null
                            ,p_attribute7            in varchar2 default null
                            ,p_attribute8            in varchar2 default null
                            ,p_attribute9            in varchar2 default null
                            ,p_attribute10           in varchar2 default null
                            ,p_attribute11           in varchar2 default null
                            ,p_attribute12           in varchar2 default null
                            ,p_attribute13           in varchar2 default null
                            ,p_attribute14           in varchar2 default null
                            ,p_attribute15           in varchar2 default null
                            ,p_attribute16           in varchar2 default null
                            ,p_attribute17           in varchar2 default null
                            ,p_attribute18           in varchar2 default null
                            ,p_attribute19           in varchar2 default null
                            ,p_attribute20           in varchar2 default null
                            ,p_attribute21           in varchar2 default null
                            ,p_attribute22           in varchar2 default null
                            ,p_attribute23           in varchar2 default null
                            ,p_attribute24           in varchar2 default null
                            ,p_attribute25           in varchar2 default null
                            ,p_attribute26           in varchar2 default null
                            ,p_attribute27           in varchar2 default null
                            ,p_attribute28           in varchar2 default null
                            ,p_attribute29           in varchar2 default null
                            ,p_attribute30           in varchar2 default null
			    ,p_approval_item_type    in varchar2
			    ,p_approval_process_name in varchar2
			    ,p_approval_item_key     in varchar2
		   	    ,p_tk_audit_item_type    in varchar2
			    ,p_tk_audit_process_name in varchar2
			    ,p_tk_audit_item_key     in varchar2
			    ) is

cursor c_timecard_info(p_id in hxc_time_building_blocks.time_building_block_id%type) is
  select resource_id
        ,start_time
        ,stop_time
        ,object_version_number
        ,approval_status
        ,creation_date
        ,data_set_id
    from hxc_time_building_blocks
   where time_building_block_id = p_id
     and date_to = hr_general.end_of_time
     and scope = 'TIMECARD';

cursor c_check_for_reasons is
  select 'Y'
    from hxc_time_attributes
   where attribute_category = hxc_timecard.c_reason_attribute;

l_approval_status hxc_time_building_blocks.approval_status%type;
l_resource_id     hxc_time_building_blocks.resource_id%type;
l_start_time      hxc_time_building_blocks.start_time%type;
l_stop_time       hxc_time_building_blocks.stop_time%type;
l_submission_date hxc_time_building_blocks.creation_date%type;
l_creation_date   hxc_time_building_blocks.creation_date%type;
l_ovn             hxc_time_building_blocks.object_version_number%type;
l_has_reasons     varchar2(1);
l_recorded_hours  hxc_timecard_summary.recorded_hours%type :=0;
l_details         details;
l_data_set_id     hxc_time_building_blocks.data_set_id%type;

l_approval_item_type    hxc_timecard_summary.approval_item_type%TYPE;
l_approval_process_name hxc_timecard_summary.approval_process_name%TYPE;
l_approval_item_key     hxc_timecard_summary.approval_item_key%TYPE;

l_abs_days    NUMBER := 0; -- Added as part of OTL ABS Integration
l_abs_hours   NUMBER := 0; -- Added as part of OTL ABS Integration

Begin

if(g_check_for_reasons is null) then
  open c_check_for_reasons;
  fetch c_check_for_reasons into g_check_for_reasons;
  if(c_check_for_reasons%notfound) then
    g_check_for_reasons := 'N';
  end if;
  close c_check_for_reasons;
end if;

open c_timecard_info(p_timecard_id);
fetch c_timecard_info
 into l_resource_id,
      l_start_time,
      l_stop_time,
      l_ovn,
      l_approval_status,
      l_creation_date,
      l_data_set_id;

if(c_timecard_info%found) then

  --
  -- 1. Find the approval status
  --

  if(p_mode = c_migration_mode) then
     l_approval_status := get_migration_apr_status(p_timecard_id,l_ovn);
  else
     null;
  end if;

  --
  -- 2. Recorded Hours
  --
     get_recorded_hours(p_timecard_id,l_ovn,l_recorded_hours,l_details);
  --
  -- 3. Has Reasons
  --
     if(g_check_for_reasons = 'Y') then
       l_has_reasons := get_has_reasons(l_details);
     else
       l_has_reasons := 'N';
     end if;
  --
  -- 4. Submission Date
  --
     l_submission_date := sysdate;
  --
  -- Insert Summary Row
  --

     if(l_approval_status = hxc_timecard.c_working_status OR
        l_approval_status = hxc_timecard.c_error) then
	  l_approval_item_type :=NULL;
	  l_approval_process_name  :=NULL;
	  l_approval_item_key  :=NULL;
     Else
	  l_approval_item_type     := p_approval_item_type;
	  l_approval_process_name  := p_approval_process_name;
	  l_approval_item_key      := p_approval_item_key;
     END IF;

-- Added for OTL ABS Integration 8888902
-- OTL-ABS START
  IF (NVL(fnd_profile.value('HR_ABS_OTL_INTEGRATION'), 'N') = 'Y')
  THEN

    IF g_debug THEN
      hr_utility.trace('ABS> In hxc_timecard_summary_pkg.insert_summary_row');
      hr_utility.trace('ABS> initial value of recorded hours ::'||l_recorded_hours);
    END IF;

    BEGIN
      IF g_debug THEN
        hr_utility.trace('ABS> initial value of l_abs_days ::'||l_abs_days);
        hr_utility.trace('ABS> initial value of l_abs_hours ::'||l_abs_hours);
      END IF;

      SELECT nvl(absence_days,0),
             nvl(absence_hours,0)
        INTO l_abs_days,
             l_abs_hours
        FROM hxc_absence_summary_temp
       WHERE resource_id = hxc_retrieve_absences.g_person_id
         AND start_time  = hxc_retrieve_absences.g_start_time
         AND stop_time   = hxc_retrieve_absences.g_stop_time;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_abs_days   := 0;
        l_abs_hours  := 0;
    END;

    IF g_debug THEN
      hr_utility.trace('ABS> Before calculation of recorded hours');
      hr_utility.trace('ABS> initial value of recorded hours ::'||l_recorded_hours);
      hr_utility.trace('ABS> initial value of l_abs_days ::'||l_abs_days);
      hr_utility.trace('ABS> initial value of l_abs_hours ::'||l_abs_hours);
    END IF;

    l_recorded_hours := l_recorded_hours - (l_abs_days+l_abs_hours);

    IF g_debug THEN
      hr_utility.trace('ABS> final values before insert into timecard summary');
      hr_utility.trace('ABS> l_abs_days ::'||l_abs_days);
      hr_utility.trace('ABS> l_abs_hours ::'||l_abs_hours);
      hr_utility.trace('ABS> l_recorded_hours ::'||l_recorded_hours);
    END IF;

    -- clear absence summary rows
    IF g_debug THEN
      hr_utility.trace('ABS> In hxc_timecard_summary_pkg.insert_summary_row');
      hr_utility.trace('ABS> clear absence summary rows');
    END IF;

    hxc_retrieve_absences.clear_absence_summary_rows;

  END IF;
-- OTL-ABS END

  insert into hxc_timecard_summary
  (timecard_id
  ,timecard_ovn
  ,approval_status
  ,resource_id
  ,start_time
  ,stop_time
  ,recorded_hours
  ,has_reasons
  ,submission_date
  ,approval_item_type
  ,approval_process_name
  ,approval_item_key
  ,attribute_category
  ,attribute1
  ,attribute2
  ,attribute3
  ,attribute4
  ,attribute5
  ,attribute6
  ,attribute7
  ,attribute8
  ,attribute9
  ,attribute10
  ,attribute11
  ,attribute12
  ,attribute13
  ,attribute14
  ,attribute15
  ,attribute16
  ,attribute17
  ,attribute18
  ,attribute19
  ,attribute20
  ,attribute21
  ,attribute22
  ,attribute23
  ,attribute24
  ,attribute25
  ,attribute26
  ,attribute27
  ,attribute28
  ,attribute29
  ,attribute30
  ,tk_audit_item_type
  ,tk_audit_process_name
  ,tk_audit_item_key
  ,data_set_id
  ,absence_days
  ,absence_hours
  )
  values
  (p_timecard_id
  ,l_ovn
  ,l_approval_status
  ,l_resource_id
  ,l_start_time
  ,l_stop_time
  ,l_recorded_hours
  ,l_has_reasons
  ,l_submission_date
  ,p_approval_item_type
  ,p_approval_process_name
  ,p_approval_item_key
  ,p_attribute_category
  ,p_attribute1
  ,p_attribute2
  ,p_attribute3
  ,p_attribute4
  ,p_attribute5
  ,p_attribute6
  ,p_attribute7
  ,p_attribute8
  ,p_attribute9
  ,p_attribute10
  ,p_attribute11
  ,p_attribute12
  ,p_attribute13
  ,p_attribute14
  ,p_attribute15
  ,p_attribute16
  ,p_attribute17
  ,p_attribute18
  ,p_attribute19
  ,p_attribute20
  ,p_attribute21
  ,p_attribute22
  ,p_attribute23
  ,p_attribute24
  ,p_attribute25
  ,p_attribute26
  ,p_attribute27
  ,p_attribute28
  ,p_attribute29
  ,p_attribute30
  ,p_tk_audit_item_type
  ,p_tk_audit_process_name
  ,p_tk_audit_item_key
  ,l_data_set_id
  ,l_abs_days  -- Added as part of OTL ABS Integration
  ,l_abs_hours --Added as part of OTL ABS Integration
  );

else

  FND_MESSAGE.set_name('HXC','HXC_NO_TIMECARD_ID');
  FND_MESSAGE.set_token('TIMECARD_ID',to_char(p_timecard_id));
  FND_MESSAGE.raise_error;

end if;

End insert_summary_row;

procedure update_summary_row(p_timecard_id in hxc_time_building_blocks.time_building_block_id%type
			    ,p_approval_item_type     in hxc_timecard_summary.approval_item_type%type
			    ,p_approval_process_name  in hxc_timecard_summary.approval_process_name%type
			    ,p_approval_item_key      in hxc_timecard_summary.approval_item_key%type
) is

l_item_key hxc_timecard_summary.approval_item_key%type;
l_dummy varchar2(1);

cursor c_is_wf_deferred(p_item_key in hxc_timecard_summary.approval_item_key%type)
is
select 'Y'
from wf_item_activity_statuses wias
where item_type = 'HXCEMP'
and item_key = l_item_key
and activity_status = 'DEFERRED';

cursor c_get_item_key(p_timecard_id in number)
is
select approval_item_key
from hxc_timecard_summary
where timecard_id = p_timecard_id;

Begin

open c_get_item_key(p_timecard_id);
fetch c_get_item_key into l_item_key;
close c_get_item_key;


If l_item_key is not null then

	open c_is_wf_deferred(l_item_key);
	fetch c_is_wf_deferred into l_dummy;
	close c_is_wf_deferred;

	If l_dummy = 'Y' then

	 wf_engine.AbortProcess(itemkey => l_item_key,
    				itemtype => 'HXCEMP');
        end if;
end if;


UPDATE hxc_timecard_summary
SET    approval_item_type = p_approval_item_type,
       approval_process_name = p_approval_process_name,
       approval_item_key =p_approval_item_key
WHERE   TIMECARD_ID=       p_timecard_id;


End update_summary_row;

procedure delete_summary_row(p_timecard_id in hxc_time_building_blocks.time_building_block_id%type) is

Begin

delete from hxc_timecard_summary where timecard_id = p_timecard_id;

Exception
  When others then
    FND_MESSAGE.set_name('HXC','HXC_NO_TIMECARD_ID');
    FND_MESSAGE.raise_error;

End delete_summary_row;

procedure reject_timecard(p_timecard_id in hxc_time_building_blocks.time_building_block_id%type) is

Begin

update hxc_timecard_summary
   set approval_status = hxc_timecard.c_rejected_status
 where timecard_id = p_timecard_id;

End reject_timecard;

Procedure approve_timecard(p_timecard_id in hxc_time_building_blocks.time_building_block_id%type) is

CURSOR c_timecard_details (c_timecard_id NUMBER)
IS
SELECT resource_id,
       start_time,
       stop_time,
       approval_status
  FROM hxc_timecard_summary
 WHERE timecard_id =  c_timecard_id;

l_messages   hxc_message_table_type   := hxc_message_table_type();

l_resource_id  NUMBER;
l_start_time   DATE;
l_stop_time    DATE;
l_approval_status VARCHAR2(20);

Begin

update hxc_timecard_summary
   set approval_status = hxc_timecard.c_approved_status
 where timecard_id = p_timecard_id;

-- OTL-Absences Integration (Bug 8779478)
IF (nvl(fnd_profile.value('HR_ABS_OTL_INTEGRATION'), 'N') = 'Y') THEN
        IF g_debug THEN
          hr_utility.trace('Initiated Online Retrieval from HXC_TIMECARD_SUMMARY_PKG.APPROVE_TIMECARD');
	END IF;

                           OPEN c_timecard_details(p_timecard_id);
	FETCH c_timecard_details INTO l_resource_id,
			      l_start_time,
			      l_stop_time,
			      l_approval_status;
	CLOSE c_timecard_details;

	HXC_ABS_RETRIEVAL_PKG.POST_ABSENCES(l_resource_id,
	  				    l_start_time,
	       				    l_stop_time,
	       				    l_approval_status,
       					    l_messages);

	IF g_debug THEN
	  hr_utility.trace('Completed Online Retrieval from HXC_TIMECARD_SUMMARY_PKG.APPROVE_TIMECARD');
	END IF;

	IF (l_messages.COUNT > 0) THEN
	        IF g_debug THEN
	          hr_utility.trace('ABS:EXCEPTION - retrieval_error during approval');
	        END IF;
  		hr_utility.set_message(809, l_messages(l_messages.FIRST).message_name);
  		hr_utility.raise_error;
	END IF;

END IF;


End approve_timecard;

Procedure submit_timecard(p_timecard_id in hxc_time_building_blocks.time_building_block_id%type) is

Begin

update hxc_timecard_summary
   set approval_status = hxc_timecard.c_submitted_status
 where timecard_id = p_timecard_id;

End submit_timecard;

end hxc_timecard_summary_pkg;


/
