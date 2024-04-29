--------------------------------------------------------
--  DDL for Package Body HXC_TIMECARD_HOURS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_TIMECARD_HOURS_PKG" as
/* $Header: hxchours.pkb 115.11 2002/06/10 00:37:12 pkm ship    $ */
--
--
-- procedure
--  get_hours
--
-- description
--  Gets the sum for a particular type of Hours as defined by
--  the lookup type
--
-- parameters
--       p_timecard_id    - timecard id
--       p_timecard_ovn   - timecard ovn
--       p_lookup_type    - hours type lookup
--

TYPE t_element_ids IS TABLE OF
NUMBER
INDEX BY BINARY_INTEGER;


FUNCTION get_hours( p_timecard_id  NUMBER,
                    p_timecard_ovn NUMBER,
                    p_lookup_type  VARCHAR2) RETURN NUMBER
IS


-- Might want to run the following cursor off an effective date
-- which would require a date to be passed to this routine.

CURSOR csr_element_ids(p_lookup_type VARCHAR2) IS
select
     petf.element_type_id element_type_id
from
     hr_lookups hl,
     pay_element_types_f petf
where
     upper(petf.element_name) = hl.lookup_code
and  hl.lookup_type = p_lookup_type
and  petf.effective_end_date = hr_general.end_of_time;

CURSOR csr_element_details(p_timecard_id NUMBER,
                               p_timecard_ovn NUMBER,
                               p_element_segment VARCHAR2,
                               p_element_context VARCHAR2,
                               p_element_category VARCHAR2)
IS
SELECT
       DECODE(p_element_segment,
              'ATTRIBUTE1' , ta_det.attribute1,
              'ATTRIBUTE2' , ta_det.attribute2,
              'ATTRIBUTE3' , ta_det.attribute3,
              'ATTRIBUTE4' , ta_det.attribute4,
              'ATTRIBUTE5' , ta_det.attribute5,
              'ATTRIBUTE6' , ta_det.attribute6,
              'ATTRIBUTE7' , ta_det.attribute7,
              'ATTRIBUTE8' , ta_det.attribute8,
              'ATTRIBUTE9' , ta_det.attribute9,
              'ATTRIBUTE10' , ta_det.attribute10,
              'ATTRIBUTE11' , ta_det.attribute11,
              'ATTRIBUTE12' , ta_det.attribute12,
              'ATTRIBUTE13' , ta_det.attribute13,
              'ATTRIBUTE14' , ta_det.attribute14,
              'ATTRIBUTE15' , ta_det.attribute15,
              'ATTRIBUTE16' , ta_det.attribute16,
              'ATTRIBUTE17' , ta_det.attribute17,
              'ATTRIBUTE18' , ta_det.attribute18,
              'ATTRIBUTE19' , ta_det.attribute19,
              'ATTRIBUTE20' , ta_det.attribute20,
              'ATTRIBUTE21' , ta_det.attribute21,
              'ATTRIBUTE22' , ta_det.attribute22,
              'ATTRIBUTE23' , ta_det.attribute23,
              'ATTRIBUTE24' , ta_det.attribute24,
              'ATTRIBUTE25' , ta_det.attribute25,
              'ATTRIBUTE26' , ta_det.attribute26,
              'ATTRIBUTE27' , ta_det.attribute27,
              'ATTRIBUTE28' , ta_det.attribute28,
              'ATTRIBUTE29' , ta_det.attribute29,
              'ATTRIBUTE30' , ta_det.attribute30,
              'ATTRIBUTE_CATEGORY', ta_det.attribute_category) element_id,
       tbb_det.measure,
       tbb_det.unit_of_measure,
       tbb_det.start_time,
       tbb_det.stop_time,
       tbb_det.type,
       tbb_det.scope
  FROM hxc_time_building_blocks tbb_day,
       hxc_time_building_blocks tbb_det,
       hxc_time_attribute_usages tau_det,
       hxc_time_attributes ta_det
 WHERE tbb_det.scope = 'DETAIL'
   and tbb_day.scope = 'DAY'
   and tbb_det.date_to = hr_general.end_of_time
   and tbb_det.parent_building_block_ovn = tbb_day.object_version_number
   and tbb_det.parent_building_block_id = tbb_day.time_building_block_id
   and tbb_day.parent_building_block_id = p_timecard_id
   and tbb_day.parent_building_block_ovn = p_timecard_ovn
   and tau_det.time_building_block_id = tbb_det.time_building_block_id
   and tau_det.time_building_block_ovn = tbb_det.object_version_number
   and tau_det.time_attribute_id = ta_det.time_attribute_id
   and ta_det.attribute_category = nvl(p_element_context,ta_det.attribute_category)
   and ta_det.BLD_BLK_INFO_TYPE_ID in
       (select BLD_BLK_INFO_TYPE_ID from HXC_BLD_BLK_INFO_TYPE_USAGES
         where BUILDING_BLOCK_CATEGORY=p_element_category);

-- this is not elegant. View hxc_mapping_attributes_v should include building_block_category
-- so this can be tidied up.

cursor csr_element_location is
select ma.context context,
       ma.segment segment,
       bbitu.building_block_category category
from   hxc_mapping_attributes_v ma,
       hxc_deposit_processes dp,
       hxc_mappings mp,
       hxc_bld_blk_info_type_usages bbitu
where  ma.map = mp.name
and    mp.mapping_id = dp.mapping_id
and    dp.name = 'OTL Deposit Process'
and    ma.field_name = 'Dummy Element Context'
and    bbitu.bld_blk_info_type_id=ma.bld_blk_info_type_id;

l_running_total	   number;
l_element_context  hxc_time_attributes.attribute_category%TYPE;
l_element_segment  VARCHAR2(30);
l_element_category hxc_bld_blk_info_type_usages.building_block_category%TYPE;

l_element_ids t_element_ids;
l_element_count number;

BEGIN

l_running_total := 0;

-- build a list of elements that represent the type of hours

l_element_count := 0;

FOR l_element_id in csr_element_ids(p_lookup_type) LOOP

  l_element_ids(l_element_count):=l_element_id.element_type_id;
  l_element_count:=l_element_count+1;

END LOOP;

-- find out where the elements are kept in this instance

open csr_element_location;
fetch csr_element_location into l_element_context,l_element_segment,l_element_category;
close csr_element_location;

-- There are two cases. One case is where element_ids are stored in a specific
-- context/segment combination. Another is where elements are stored in the
-- attribute_category of many contexts - one for each element.

IF(l_element_context='Dummy Element Context') THEN

  l_element_context:=null;

END IF;

 -- get all attributes of the timecard in question
  -- could just get the elements but its not going to
  -- slow things down significantly.

  FOR l_element_detail in
        csr_element_details(p_timecard_id,p_timecard_ovn,
                            l_element_segment,l_element_context,l_element_category) LOOP

    -- its an element. Now simply check this against our list to
    -- see if it needs to be included in the sum

    FOR l_iterator in 0..l_element_count-1 LOOP

      IF(substr(l_element_detail.element_id,11,20) = l_element_ids(l_iterator)) then

        -- add to the total based on whether is a range or measure detail

        if(l_element_detail.type = 'MEASURE' and
          l_element_detail.unit_of_measure = 'HOURS' and
          l_element_detail.measure is not null) then
          l_running_total:=l_running_total + l_element_detail.measure;
        end if;
        if(l_element_detail.type = 'RANGE' and
          l_element_detail.start_time is not null and
          l_element_detail.stop_time is not null ) then
          l_running_total:=l_running_total +
          (l_element_detail.stop_time-l_element_detail.start_time)*24;
        end if;

-- If the detail was not understood then just ignore it.
-- Might want to raise an error here in the future.

-- Note that details with more than one element attribute attached may
-- be double counted. This sort of data is not expected.

      END IF;

    END LOOP;

  END LOOP; -- end attribute loop

RETURN l_running_total;

END get_hours;

------------------------------------------------------------------------
-- overload the above one so that we won't possibly break existing code
------------------------------------------------------------------------

-- aioannou - this should be merged asap.

FUNCTION get_hours(
  p_period_start_time  IN DATE,
  p_period_stop_time   IN DATE,
  p_resource_id        IN NUMBER,
  p_lookup_type        IN VARCHAR2
)
RETURN NUMBER
IS


-- Might want to run the following cursor off an effective date
-- which would require a date to be passed to this routine.

CURSOR csr_element_ids(p_lookup_type VARCHAR2) IS
select
     petf.element_type_id element_type_id
from
     hr_lookups hl,
     pay_element_types_f petf
where
     upper(petf.element_name) = hl.lookup_code
and  hl.lookup_type = p_lookup_type
and  petf.effective_end_date = hr_general.end_of_time;

CURSOR csr_element_details(p_period_start_time DATE,
                           p_period_stop_time DATE,
                           p_resource_id NUMBER,
                           p_element_segment VARCHAR2,
                           p_element_context VARCHAR2,
                           p_element_category VARCHAR2)

IS
SELECT
       DECODE(p_element_segment,
              'ATTRIBUTE1' , ta_det.attribute1,
              'ATTRIBUTE2' , ta_det.attribute2,
              'ATTRIBUTE3' , ta_det.attribute3,
              'ATTRIBUTE4' , ta_det.attribute4,
              'ATTRIBUTE5' , ta_det.attribute5,
              'ATTRIBUTE6' , ta_det.attribute6,
              'ATTRIBUTE7' , ta_det.attribute7,
              'ATTRIBUTE8' , ta_det.attribute8,
              'ATTRIBUTE9' , ta_det.attribute9,
              'ATTRIBUTE10' , ta_det.attribute10,
              'ATTRIBUTE11' , ta_det.attribute11,
              'ATTRIBUTE12' , ta_det.attribute12,
              'ATTRIBUTE13' , ta_det.attribute13,
              'ATTRIBUTE14' , ta_det.attribute14,
              'ATTRIBUTE15' , ta_det.attribute15,
              'ATTRIBUTE16' , ta_det.attribute16,
              'ATTRIBUTE17' , ta_det.attribute17,
              'ATTRIBUTE18' , ta_det.attribute18,
              'ATTRIBUTE19' , ta_det.attribute19,
              'ATTRIBUTE20' , ta_det.attribute20,
              'ATTRIBUTE21' , ta_det.attribute21,
              'ATTRIBUTE22' , ta_det.attribute22,
              'ATTRIBUTE23' , ta_det.attribute23,
              'ATTRIBUTE24' , ta_det.attribute24,
              'ATTRIBUTE25' , ta_det.attribute25,
              'ATTRIBUTE26' , ta_det.attribute26,
              'ATTRIBUTE27' , ta_det.attribute27,
              'ATTRIBUTE28' , ta_det.attribute28,
              'ATTRIBUTE29' , ta_det.attribute29,
              'ATTRIBUTE30' , ta_det.attribute30,
              'ATTRIBUTE_CATEGORY', ta_det.attribute_category) element_id,
       tbb_det.measure,
       tbb_det.unit_of_measure,
       tbb_det.start_time,
       tbb_det.stop_time,
       tbb_det.type,
       tbb_det.scope
  FROM hxc_time_building_blocks tbb_day,
       hxc_time_building_blocks tbb_det,
       hxc_time_attribute_usages tau_det,
       hxc_time_attributes ta_det
 WHERE tbb_det.scope = 'DETAIL'
   and tbb_day.scope = 'DAY'
   and tbb_day.date_to = hr_general.end_of_time
   and tbb_det.date_to = hr_general.end_of_time
   and tbb_det.parent_building_block_ovn = tbb_day.object_version_number
   and tbb_det.parent_building_block_id = tbb_day.time_building_block_id
   and tbb_day.start_time >= p_period_start_time
   and tbb_day.stop_time <= p_period_stop_time
   and tbb_det.resource_id = p_resource_id
   and tau_det.time_building_block_id = tbb_det.time_building_block_id
   and tau_det.time_building_block_ovn = tbb_det.object_version_number
   and tau_det.time_attribute_id = ta_det.time_attribute_id
   and ta_det.attribute_category = nvl(p_element_context,ta_det.attribute_category)
   and ta_det.BLD_BLK_INFO_TYPE_ID in
       (select BLD_BLK_INFO_TYPE_ID from HXC_BLD_BLK_INFO_TYPE_USAGES
         where BUILDING_BLOCK_CATEGORY=p_element_category);


cursor csr_element_location is
select ma.context context,
       ma.segment segment,
       bbitu.building_block_category category
from   hxc_mapping_attributes_v ma,
       hxc_deposit_processes dp,
       hxc_mappings mp,
       hxc_bld_blk_info_type_usages bbitu
where  ma.map = mp.name
and    mp.mapping_id = dp.mapping_id
and    dp.name = 'OTL Deposit Process'
and    ma.field_name = 'Dummy Element Context'
and    bbitu.bld_blk_info_type_id=ma.bld_blk_info_type_id;

l_running_total	number;
l_element_context hxc_time_attributes.attribute_category%TYPE;
l_element_segment VARCHAR2(30);
l_element_category hxc_bld_blk_info_type_usages.building_block_category%TYPE;

l_element_ids t_element_ids;
l_element_count number;

BEGIN

l_running_total:=0;

-- build a list of elements that represent the type of hours

l_element_count:=0;

FOR l_element_id in csr_element_ids(p_lookup_type) LOOP

  l_element_ids(l_element_count):=l_element_id.element_type_id;
  l_element_count:=l_element_count+1;
END LOOP;

-- find out where the elements are kept in this instance

open csr_element_location;
fetch csr_element_location into l_element_context,l_element_segment,l_element_category;
close csr_element_location;

IF(l_element_context='Dummy Element Context') THEN
  l_element_context:=null;
END IF;

-- get all attributes of the timecard in question
-- could just get the elements but its not going to
-- slow things down significantly.

FOR l_element_detail in
        csr_element_details(p_period_start_time,p_period_stop_time,
                            p_resource_id,
                            l_element_segment,l_element_context,l_element_category) LOOP

-- its an element. Now simply check this against our list to
-- see if it needs to be included in the sum

FOR l_iterator in 0..l_element_count-1 LOOP

  IF(substr(l_element_detail.element_id,11,20) = l_element_ids(l_iterator)) then

-- add to the total based on whether is a range or measure detail

    if(l_element_detail.type = 'MEASURE' and
       l_element_detail.unit_of_measure = 'HOURS' and
       l_element_detail.measure is not null) then
       l_running_total:=l_running_total + l_element_detail.measure;
    end if;
    if(l_element_detail.type = 'RANGE' and
       l_element_detail.start_time is not null and
       l_element_detail.stop_time is not null ) then
    l_running_total:=l_running_total +
       (l_element_detail.stop_time-l_element_detail.start_time)*24;
    end if;

-- If the detail was not understood then just ignore it.
-- Might want to raise an error here in the future.

-- Note that details with more than one element attribute attached may
-- be double counted. This sort of data is not expected.

  END IF;

END LOOP;

END LOOP; -- end attribute loop

RETURN l_running_total;

END get_hours;


--------------------------------------------------------------------------
-- overload get_total_hours
-- mode parameter specifies how to deal with the start/stop times
-- passed in
-- p_mode = 'DAYS_INCLUSIVE' -- ignore time component of dates passed in
--                              consider summation from the start of the
--                              start day to the end of the end day.
-- p_mode = 'DATE_TIME'      -- only count hours if the details lie within
--                              the interval of time as defined by
--                              period_start_time/period_stop_time
--------------------------------------------------------------------------
FUNCTION get_total_hours(
  p_period_start_time  IN DATE,
  p_period_stop_time   IN DATE,
  p_resource_id        IN NUMBER,
  p_mode               IN VARCHAR2 DEFAULT 'DAYS_INCLUSIVE'
)
RETURN NUMBER
IS
l_sum NUMBER := 0;
l_start_time DATE;
l_stop_time DATE;
l_one_sec_as_day_fraction number:=(1/24/60/60);

BEGIN

if(p_mode = 'DAYS_INCLUSIVE') then
  l_start_time := trunc(p_period_start_time);
  l_stop_time := trunc(p_period_stop_time+1)-l_one_sec_as_day_fraction;
elsif (p_mode = 'DATE_TIME') then
  l_start_time := p_period_start_time;
  l_stop_time := p_period_stop_time;
end if;

      select
       sum(decode(tbb_det.type,
                  'MEASURE',nvl(tbb_det.measure,0),
                  'RANGE',  nvl(tbb_det.stop_time-tbb_det.start_time,0)*24)) into l_sum
  FROM hxc_time_building_blocks tbb_day,
       hxc_time_building_blocks tbb_det,
       hxc_time_building_blocks tbb_tim
 WHERE tbb_det.scope = 'DETAIL'
   and tbb_day.scope = 'DAY'
   and tbb_tim.scope = 'TIMECARD'
   and tbb_det.date_to = hr_general.end_of_time
   and tbb_det.parent_building_block_ovn = tbb_day.object_version_number
   and tbb_det.parent_building_block_id = tbb_day.time_building_block_id
   and tbb_day.parent_building_block_ovn = tbb_tim.object_version_number
   and tbb_day.parent_building_block_id = tbb_tim.time_building_block_id
   and tbb_day.start_time >= l_start_time
   and tbb_day.stop_time <= l_stop_time
   and tbb_det.resource_id = p_resource_id;

return l_sum;

END get_total_hours;

--  get_total_hours
--
-- procedure
--  Calculates the total hours for a timecard
--
-- description
--
-- parameters
--       p_timecard_id    - timecard Id
--       p_timecard_ovn   - timecard  Ovn
--

FUNCTION get_total_hours
            (
              p_timecard_id number,
              p_timecard_ovn number
            ) RETURN NUMBER
is

l_sum number;

BEGIN

l_sum 	:= 0;

      select
      sum(decode(tbb_det.type,
                  'MEASURE',nvl(tbb_det.measure,0),
                  'RANGE',  nvl(tbb_det.stop_time-tbb_det.start_time,0)*24)) into l_sum
  FROM hxc_time_building_blocks tbb_day,
       hxc_time_building_blocks tbb_det,
       hxc_time_building_blocks tbb_tim
 WHERE tbb_det.scope = 'DETAIL'
   and tbb_day.scope = 'DAY'
   and tbb_tim.scope = 'TIMECARD'
   and tbb_day.parent_building_block_ovn = tbb_tim.object_version_number
   and tbb_day.parent_building_block_id = tbb_tim.time_building_block_id
   and tbb_det.date_to = hr_general.end_of_time
   and tbb_det.parent_building_block_ovn = tbb_day.object_version_number
   and tbb_det.parent_building_block_id = tbb_day.time_building_block_id
   and tbb_day.parent_building_block_id = p_timecard_id
   and tbb_day.parent_building_block_ovn = p_timecard_ovn;


return l_sum;

END get_total_hours;

END hxc_timecard_hours_pkg;

/
