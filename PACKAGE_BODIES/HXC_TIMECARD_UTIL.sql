--------------------------------------------------------
--  DDL for Package Body HXC_TIMECARD_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_TIMECARD_UTIL" AS
/* $Header: hxcutiltc.pkb 120.0.12010000.2 2009/12/31 10:02:51 amakrish ship $ */

--
-- ----------------------------------------------------------------------------
-- |---------------------< get_period_end >------------------------------------|
-- ----------------------------------------------------------------------------
/* This function return the end period for
   a start period given
*/
FUNCTION get_end_period
         (p_start_date             in date,
	  p_number_per_fiscal_year in number,
	  p_duration_in_days       in number)
	  return date is

 l_period_end         date;

BEGIN

    IF p_number_per_fiscal_year = 1 THEN
      l_period_end := (add_months(p_start_date,12) - 1);
    ELSIF p_number_per_fiscal_year = 2 THEN
      l_period_end := (add_months(p_start_date,6) - 1);
    ELSIF p_number_per_fiscal_year = 4 THEN
      l_period_end := (add_months(p_start_date,3) - 1);
    ELSIF p_number_per_fiscal_year = 6 THEN
      l_period_end := (add_months(p_start_date,2) - 1);
    ELSIF p_number_per_fiscal_year = 12 THEN
      l_period_end := (add_months(p_start_date,1) - 1);
    ELSIF p_number_per_fiscal_year = 13 THEN
      l_period_end := p_start_date + 27;
    ELSIF p_number_per_fiscal_year = 24 THEN
      l_period_end := p_start_date + 14;
    ELSIF p_number_per_fiscal_year = 26 THEN
      l_period_end := p_start_date + 13;
    ELSIF p_number_per_fiscal_year = 52 THEN
      l_period_end := p_start_date + 6;
    ELSE
      l_period_end := p_start_date + p_duration_in_days - 1;
    END IF;

   return(l_period_end);

END get_end_period;



--
-- ----------------------------------------------------------------------------
-- |-----------------------------< get_first_empty_period >--------------------|
-- ----------------------------------------------------------------------------
/* This function return the first empty period (no timecard)
   after the start_date given in parameter
*/

FUNCTION get_first_empty_period
  (p_resource_id            in number,
   p_start_date             in date,
   p_period_type            in varchar2,
   p_number_per_fiscal_year in number,
   p_duration_in_days       in number
   ) return varchar2 is

   l_period_end                date;
   l_period_start              date;
   l_found_first_empty_period  boolean     := false;
   lv_exists                   varchar2(6) := NULL;
   l_dummy		       varchar2(1);

   Cursor c_period_exists(cp_resource_id in number,
                          cp_period_start in date) is
    Select 'exists'
    From   sys.dual
    Where  EXISTS (
             Select 'x'
              From hxc_time_building_blocks htb
              Where htb.scope         = 'TIMECARD'
              And   htb.type          = 'RANGE'
              And   htb.date_to       = hr_general.end_of_time
              And   htb.resource_type = 'PERSON'
              And   htb.resource_id   = cp_resource_id
              And   htb.start_time    = l_period_start);

    CURSOR c_person_valid(p_resource_id in number)
    IS
    select 1 from per_all_people_f where person_id=p_resource_id;


BEGIN

    open c_person_valid(p_resource_id);
    fetch c_person_valid into l_dummy;

    if(c_person_valid%NOTFOUND) then
    -- Raise an error as the resource_id isnt valid

      fnd_message.set_name('HXC', 'HXC_INVALID_RESOURCE_ID');
      fnd_message.set_token('RES_ID',p_resource_id);
      hr_utility.raise_error;
    END IF;


    --
    -- set the first existing period for the person
    --
    l_period_start := p_start_date;
    l_period_end   := get_end_period(l_period_start,
    				     p_number_per_fiscal_year,
    				     p_duration_in_days);
    --
    -- Open the loop still
    -- find the first empty period
    -- or the the end of period > end_of_time
    --
    LOOP
       --
       -- try to
       -- find the first empty period
       --
         open c_period_exists(p_resource_id,
                              l_period_start);
         fetch c_period_exists into lv_exists;
         close c_period_exists;

         IF lv_exists is null THEN
           l_found_first_empty_period := true;
         ELSE
           lv_exists := NULL;
         END IF;
       --
       -- if not found then jump to the next period
       --
       IF (l_found_first_empty_period = false) THEN
           l_period_start := l_period_end + 1;
           l_period_end := get_end_period(l_period_start,
    				          p_number_per_fiscal_year,
    				          p_duration_in_days);
       END IF;
      EXIT WHEN (l_found_first_empty_period = true);
      EXIT WHEN (l_period_start > hr_general.end_of_time);
    END LOOP;


 return (to_char(l_period_start,'YYYY/MM/DD')||'|'||to_char(l_period_end,'YYYY/MM/DD'));

END get_first_empty_period;
--
-- ----------------------------------------------------------------------------
-- |---------------------< get_submission_date >------------------------------|
-- ----------------------------------------------------------------------------
/* This function return the end period for
   a start period given
*/
FUNCTION get_submission_date
  (p_timecard_id            in number,
   p_timecard_ovn           in number)
   return date is

    CURSOR c_timecard_day_sub_date
             (p_timecard_id in number,
              p_timecard_ovn in number)
    IS
    select max(ht.transaction_date)
    from  hxc_dep_transactions ht,
          hxc_dep_transaction_details htd,
          hxc_time_building_blocks htb
    where htb.parent_building_block_id  = p_timecard_id
    and   htb.parent_building_block_ovn = p_timecard_ovn
    and   htb.scope = 'DAY'
    and   htd.time_building_block_id    = htb.time_building_block_id
    and   htd.time_building_block_ovn   = htb.object_version_number
    and   htd.status='SUCCESS'
    and   ht.transaction_id=htd.transaction_id
    and   ht.type='DEPOSIT'
    and   ht.status='SUCCESS' ;

    CURSOR c_timecard_detail_sub_date
             (p_timecard_id in number,
              p_timecard_ovn in number)
    IS
    select max(ht.transaction_date)
    from  hxc_dep_transactions ht,
          hxc_dep_transaction_details htd,
          hxc_time_building_blocks htb_day,
          hxc_time_building_blocks htb_detail
    where htb_day.parent_building_block_id  = p_timecard_id
    and   htb_day.parent_building_block_ovn = p_timecard_ovn
    and   htb_day.scope = 'DAY'
    and   htb_detail.parent_building_block_id    = htb_day.time_building_block_id
    and   htb_detail.parent_building_block_ovn   = htb_day.object_version_number
    and   htb_detail.scope = 'DETAIL'
    and   htd.time_building_block_id    = htb_detail.time_building_block_id
    and   htd.time_building_block_ovn   = htb_detail.object_version_number
    and   htd.status='SUCCESS'
    and   ht.transaction_id=htd.transaction_id
    and   ht.type='DEPOSIT'
    and   ht.status='SUCCESS' ;

   l_return_date                 date := null;

BEGIN

    open c_timecard_detail_sub_date(p_timecard_id,p_timecard_ovn);
    fetch c_timecard_detail_sub_date into l_return_date;
    close c_timecard_detail_sub_date;

    if (l_return_date is null) then

      open c_timecard_day_sub_date(p_timecard_id,p_timecard_ovn);
      fetch c_timecard_day_sub_date into l_return_date;
      close c_timecard_day_sub_date;

    end if;


 return l_return_date;

END get_submission_date;
END hxc_timecard_util;

/
