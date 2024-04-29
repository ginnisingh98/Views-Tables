--------------------------------------------------------
--  DDL for Package Body HXC_TIMECARD_SEARCH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_TIMECARD_SEARCH_PKG" as
/* $Header: hxcserch.pkb 120.1 2006/03/23 02:56:53 gsirigin noship $ */

TYPE search_record IS RECORD(
  search_by        VARCHAR2(100)
 ,search_operator  VARCHAR2(30)
 ,search_value     VARCHAR2(1000)
 ,search_connector VARCHAR2(5)
);

TYPE search_table is TABLE OF
  search_record
  INDEX BY BINARY_INTEGER;

TYPE application_period is RECORD(
  approval_status hxc_time_building_blocks.approval_status%type,
  start_time      hxc_time_building_blocks.start_time%type,
  stop_time       hxc_time_building_blocks.stop_time%type
  );

TYPE app_period_table is TABLE of Application_Period index by binary_integer;

TYPE cur_type is REF CURSOR;

FUNCTION add_value_to_string(
  p_string IN VARCHAR2
 ,p_value  IN VARCHAR2
)
RETURN VARCHAR2
IS
  l_value VARCHAR2(300);

BEGIN
  IF p_value IS NULL
  THEN
    RETURN p_string;
  END IF;

  l_value := replace(p_value, '''', '''''');

  IF p_string IS NOT NULL
  THEN
     RETURN p_string || ', ''' || l_value || '''';
  ELSE
     RETURN '''' || l_value || '''';
  END IF;

END add_value_to_string;

-- get a list of this person's element values so we can eliminate the
-- return values from valueset definition when there is an open query
FUNCTION get_user_value_list(
  p_resource_id  IN  VARCHAR2
 ,p_field_name   IN  VARCHAR2
 ,p_flex_segment IN  VARCHAR2
 ,p_flex_context IN  VARCHAR2
)
RETURN VARCHAR2
IS
  l_prefix            VARCHAR2(15) := NULL;
  l_user_list_sql     VARCHAR2(1000) := NULL;
  l_user_value_list   VARCHAR2(32767) := NULL;
  l_attribute_value   VARCHAR2(100) := NULL;
  l_user_list_cursor  cur_type;
BEGIN

  l_user_list_sql := 'SELECT distinct hta.'
                  ||         p_flex_segment
                  || ' FROM hxc_time_building_blocks htbb_detail, '
                  ||       'hxc_time_attribute_usages htau, '
                  ||       'hxc_time_attributes hta'
                  || ' WHERE htbb_detail.resource_id = '
                  ||         ':p_resource_id'
                  ||   ' AND htbb_detail.date_to = hr_general.end_of_time'
                  ||   ' AND htau.time_building_block_id = htbb_detail.time_building_block_id'
                  ||   ' AND htau.time_building_block_ovn = htbb_detail.object_version_number'
                  ||   ' AND htau.time_attribute_id = hta.time_attribute_id'
                  ||   ' AND hta.attribute_category = '
                  ||   ':p_flex_context';

OPEN l_user_list_cursor FOR l_user_list_sql using p_resource_id,p_flex_context;
  LOOP
    FETCH l_user_list_cursor INTO l_attribute_value;
    EXIT WHEN l_user_list_cursor%NOTFOUND;

      l_user_value_list := add_value_to_string(l_user_value_list, l_attribute_value);

  END LOOP;
  CLOSE l_user_list_cursor;

  IF l_user_value_list IS NULL
  THEN
    RETURN NULL;
  END IF;

  -- process 'DUMMY ELEMENT CONTEXT' and 'DUMMY COST CONTEXT' fields
  IF p_field_name = 'DUMMY ELEMENT CONTEXT'
  THEN
    l_prefix := 'ELEMENT - ';
  ELSIF p_field_name = 'DUMMY COST CONTEXT'
  THEN
    l_prefix := 'COST - ';
  END IF;

  IF l_prefix IS NOT NULL
  THEN
    l_user_value_list := replace(l_user_value_list, l_prefix, '');
  END IF;

  RETURN l_user_value_list;
END get_user_value_list;


--  get_search_attribute
--
-- procedure
--   wrapper package that brings back
--   searchable ids from flex fields for various
--   search criteria
--
-- description
--
-- parameters
--              p_flex_search_value               - to be searched item
--              p_flex_segment                    - segment of flex
--              p_flex_context                    - context of flex
--              p_flex_name                       - name of flex
--              p_application_short_name          - short name of application
--
FUNCTION get_attributes_by_flex(
  p_flex_search_value      IN VARCHAR2
 ,p_flex_segment           IN VARCHAR2
 ,p_flex_context           IN VARCHAR2
 ,p_flex_name              IN VARCHAR2
 ,p_application_short_name IN VARCHAR2
 ,p_operator               IN VARCHAR2
 ,p_resource_id            IN VARCHAR2
 ,p_field_name             IN VARCHAR2
 ,p_user_set               IN VARCHAR2 DEFAULT 'Y'
)
RETURN VARCHAR2
IS
  l_flexfield fnd_dflex.dflex_r;
  l_flexinfo  fnd_dflex.dflex_dr;
  l_contexts  fnd_dflex.contexts_dr;
  i BINARY_INTEGER;
  j BINARY_INTEGER;
  l_segments  fnd_dflex.segments_dr;
  l_vset fnd_vset.valueset_r;
  l_fmt fnd_vset.valueset_dr;
  l_found BOOLEAN;
  l_row NUMBER;
  l_value fnd_vset.value_dr;
  l_select_st varchar2(10000);
  l_meaning_column varchar2(300);
  l_value_column varchar2(300);
  l_id_column varchar2(300);
  l_id_string       VARCHAR2(300);
  l_value_string    VARCHAR2(300);
  l_meaning_string  VARCHAR2(300);
  l_like            VARCHAR2(5);
  l_complete_select_st VARCHAR2(32767) := '';
  l_mapping_code varchar2(1000);
  l_flag number;
  l_valcursor cur_type;
  l_search_value varchar2(100);
  l_user_value_list   VARCHAR2(32767) := NULL;

  l_loop_id number;
  l_search_meaning varchar2(100);
  l_return_string VARCHAR2(32767) := '';

  e_null_flex_name exception;
  e_null_flex_context exception;
  e_null_flex_segment exception;


BEGIN
	fnd_msg_pub.initialize;

  if ( p_flex_name = null or p_flex_name = '' )
  then
    raise e_null_flex_name ;
  end if;

  if ( p_flex_segment = null or p_flex_segment = '' )
  then
    raise e_null_flex_segment;
  end if;

  if ( p_flex_context   = null or p_flex_context  = '') then
    raise e_null_flex_context ;
  end if;


  -- Get the flex field
  fnd_dflex.get_flexfield(
    p_application_short_name,
    p_flex_name,
    l_flexfield,
    l_flexinfo
  );


  -- Get the contexts for the flex field
  fnd_dflex.get_contexts(l_flexfield, l_contexts);

  -- Loop for all contexts
  FOR i IN 1 .. l_contexts.ncontexts LOOP
      fnd_dflex.get_segments(
        fnd_dflex.make_context(
          l_flexfield,
          l_contexts.context_code(i)
        ),
        l_segments,
        TRUE
      );

      -- Check if Context is equal to given context

      IF (l_contexts.context_code(i) = p_flex_context)
      THEN
        -- Loop through all segments
  	FOR j IN 1 .. l_segments.nsegments LOOP

          -- Check if Segment is Equal to given segment
          IF ( l_segments.application_column_name(j) = p_flex_segment )
          THEN
            IF (l_segments.value_set(j) is not null)
            THEN
    	      fnd_vset.get_valueset(l_segments.value_set(j), l_vset, l_fmt);

              -- Get select statement for value set
              fnd_flex_val_api.get_table_vset_select(
                p_value_set_id => l_vset.vsid,
                p_check_enabled_flag => 'N',
                p_check_validation_date => 'N',
                p_inc_addtl_where_clause => 'N',
                x_select => l_select_st,
                x_mapping_code => l_mapping_code,
                x_success =>l_flag
              );

     	      IF (l_select_st is not null)
              THEN
     	        -- Append where clause for meaning
                l_meaning_column := l_vset.table_info.meaning_column_name;
     	        l_value_column :=  l_vset.table_info.value_column_name;
    	        l_id_column    :=  l_vset.table_info.id_column_name;

                -- Add legislation and business_group checks
     	        l_complete_select_st :=
                  l_select_st;

                IF instr(p_operator, 'LIKE') = 0
                THEN
                  l_like := '';
                ELSE
                  l_like := '%';
                END IF;

     	        IF (l_meaning_column is not null)
                THEN
                  l_complete_select_st :=
                    l_complete_select_st ||
                    ' and ('             ||
                    l_value_column       ||
                    ' '                  ||
                    p_operator           ||
                    ''''                 ||
                    l_like               ||
                    p_flex_search_value  ||
                    l_like               ||
                    ''''                 ||
     	            ' OR '               ||
                    l_meaning_column     ||
                    ' '                  ||
                    p_operator           ||
                    ''''                 ||
                    l_like               ||
                    p_flex_search_value  ||
                    l_like               ||
                    ''')';
                ELSE
     	          l_complete_select_st :=
                    l_complete_select_st ||
                    ' and ('             ||
                    l_value_column       ||
                    ' '                  ||
                    p_operator           ||
                    ''''                 ||
                    l_like               ||
                    p_flex_search_value  ||
                    l_like               ||
                    ''')';
                END IF;

                IF p_user_set = 'Y'
                THEN
                l_user_value_list :=
                  get_user_value_list(
                    p_resource_id  => p_resource_id
                   ,p_field_name   => UPPER(p_field_name)
                   ,p_flex_segment => p_flex_segment
                   ,p_flex_context => p_flex_context
                  );
                END IF;

                IF l_user_value_list IS NOT NULL
                THEN
                  IF l_id_column IS NOT NULL
                  THEN
                    l_complete_select_st :=
                      l_complete_select_st ||
                      ' AND '              ||
                      l_id_column          ||
                      ' IN ('              ||
                      l_user_value_list    ||
                      ')';
                  ELSE
                    l_complete_select_st :=
                      l_complete_select_st ||
                      ' AND '              ||
                      l_value_column       ||
                      ' IN ('              ||
                      l_user_value_list    ||
                      ')';
                  END IF;
                END IF;

                IF l_id_column IS NOT NULL
                  AND l_meaning_column IS NOT NULL
                THEN
		  BEGIN
                  OPEN l_valcursor FOR l_complete_select_st;
                  LOOP
                    FETCH l_valcursor INTO l_value_string , l_id_string, l_meaning_string;
                    EXIT WHEN l_valcursor%NOTFOUND;

                    l_return_string := add_value_to_string(l_return_string, l_id_string);

                  END LOOP;
                  --Bug 4259255. Added exception handling for corrupt data in hxc_time_attributes table.
                  --Change for version 115.46
		  exception
                  WHEN INVALID_NUMBER  THEN
                    fnd_message.set_name('HXC', 'HXC_INVALID_PROJECT_ID');
                    FND_MSG_PUB.ADD;

                  END;
                  CLOSE l_valcursor;

                ELSIF l_id_column IS NOT NULL
                  AND l_meaning_column IS NULL
                THEN
                  OPEN l_valcursor FOR l_complete_select_st;
                  LOOP
                    FETCH l_valcursor INTO l_value_string , l_id_string;
                    EXIT WHEN l_valcursor%NOTFOUND;

                    l_return_string := add_value_to_string(l_return_string, l_id_string);

                  END LOOP;

                  CLOSE l_valcursor;

                ELSIF l_id_column IS NULL
                  AND l_meaning_column IS NOT NULL
                THEN
                  OPEN l_valcursor FOR l_complete_select_st;
                  LOOP
                    FETCH l_valcursor INTO l_value_string, l_meaning_string;
                    EXIT WHEN l_valcursor%NOTFOUND;


                    l_return_string := add_value_to_string(l_return_string, l_value_string);

                  END LOOP;
                  CLOSE l_valcursor;

                ELSIF l_id_column IS NULL
                  AND l_meaning_column IS NULL
                THEN
                  open l_valcursor for l_complete_select_st;
                  LOOP
                    FETCH l_valcursor INTO l_value_string;
                    EXIT WHEN l_valcursor%NOTFOUND;

                    l_return_string := add_value_to_string(l_return_string, l_value_string);

                  END LOOP;
                  CLOSE l_valcursor;
                END IF;

                IF l_return_string IS NULL
                THEN
                  l_return_string := ''''||'-1'||'''';  --Fix for Bug#3362876
                END IF;

                RETURN l_return_string;
     	      END IF;

     	    ELSE
     	      RETURN(hxc_timecard_search_pkg.c_no_valueset_attached); --if value set not attached to a segment
   	    END IF;

          END IF;
   	END LOOP;
      END IF;
    END LOOP;

  RETURN (''''||'-1'||'''');      --Fix for Bug#3362876
  exception
    when  e_null_flex_name then
      fnd_message.set_name('HXC', 'HXC_FLEX_NAME_NULL');
      fnd_message.raise_error;


    when  e_null_flex_context then
      fnd_message.set_name('HXC', 'HXC_FLEX_CONTEXT_NULL');
      fnd_message.raise_error;

    when e_null_flex_segment then
      fnd_message.set_name('HXC', 'HXC_FLEX_SEGMENT_NULL');
      fnd_message.raise_error;

    when others then
      --   fnd_message.set_name('HXC', 'HXC_FLEX_CANNOT_BE_SEARCHED');
      --  fnd_message.raise_error;
     raise;

END get_attributes_by_flex;


--
-- function get_timecard_status_meaning
--
--
-- description 	Calculates the status of a timecard after looking
--		into the status of application periods within or
--		surrounding the timecard.
--
-- parameters
--              bb_id		  - Building block id of timecard
--              bb_ovn            - Building block ovn of the timecard
--
-- returns 	Status of timecard
--

FUNCTION get_timecard_status_meaning(bb_id number, bb_ovn number)
return varchar2
is
l_status_code varchar2(100);
l_status_meaning varchar2(100);
begin

l_status_code := get_timecard_status_code(bb_id,bb_ovn);

-- Bug  2486271; Changed hr_general.decode_lookup to hr_bis.bis_decode_lookup.
 select hr_general.decode_lookup('HXC_APPROVAL_STATUS',l_status_code) into l_status_meaning
 from dual;
-- select hr_bis.bis_decode_lookup('HXC_APPROVAL_STATUS',l_status_code) into l_status_meaning
-- from dual;

return l_status_meaning;


end get_timecard_status_meaning;

-- Start Changes 115.35
--
-- function get_timecard_cla_status
--
--
-- description 	Calculates the status of a timecard after looking
--		into the associated attributes to find if any
--		Change or Late Audit reasons are associated with
--              with the timecard.
--
-- parameters
--              bb_id		  - Building block id of timecard
--              bb_ovn            - Building block ovn of the timecard
--
-- returns 	CLA Status of timecard
--

FUNCTION get_timecard_cla_status(bb_id number, bb_ovn number)
return varchar2
is
cursor csr_get_cla_status
         (p_timecard_id in HXC_TIME_BUILDING_BLOCKS.TIME_BUILDING_BLOCK_ID%TYPE
         ,p_timecard_ovn in HXC_TIME_BUILDING_BLOCKS.OBJECT_VERSION_NUMBER%TYPE
         ) is
SELECT 'Yes'
  FROM DUAL
 WHERE EXISTS ( SELECT '1'
                  FROM hxc_time_building_blocks days,
                       hxc_time_building_blocks details,
                       hxc_time_attribute_usages tau,
                       hxc_time_attributes ta
                 WHERE tau.time_building_block_id =
                                                details.time_building_block_id
                   AND tau.time_building_block_ovn =
                                                 details.object_version_number
                   AND tau.time_attribute_id = ta.time_attribute_id
                   AND ta.attribute_category = 'REASON'
                   AND details.scope = 'DETAIL'
     --              AND details.date_to = hr_general.end_of_time
                   AND details.parent_building_block_id =
                                                   days.time_building_block_id
    --               AND details.parent_building_block_ovn =
    --                                                days.object_version_number
                   AND days.scope = 'DAY'
    --               AND days.date_to = hr_general.end_of_time
                   AND days.parent_building_block_id = p_timecard_id
                   AND days.parent_building_block_ovn = p_timecard_ovn);

l_cla_status varchar2(3);

BEGIN

open csr_get_cla_status(bb_id,bb_ovn);
fetch csr_get_cla_status into l_cla_status;

IF csr_get_cla_status%NOTFOUND then
  l_cla_status := 'No';
END IF;

close csr_get_cla_status;


RETURN l_cla_status;
END get_timecard_cla_status;

-- End Changes 115.35



--
-- function get_timecard_status_code
--
--
-- description 	Calculates the status (Menaing) of a timecard after looking
--		into the status of application periods within or
--		surrounding the timecard.
--
-- parameters
--              bb_id		  - Building block id of timecard
--              bb_ovn            - Building block ovn of the timecard
--
-- returns 	Status of timecard
--

FUNCTION get_timecard_status_code(bb_id number, bb_ovn number)
return varchar2
is

   cursor c_timecard_status
             (p_timecard_id in hxc_timecard_summary.timecard_id%type,
	      p_timecard_ovn in hxc_timecard_summary.timecard_ovn%type) is
     select approval_status
       from hxc_timecard_summary
      where timecard_id = p_timecard_id
	and timecard_ovn = p_timecard_ovn;

   cursor c_timecard_no_ovn_status
             (p_timecard_id in hxc_timecard_summary.timecard_id%type) is
     select approval_status
       from hxc_timecard_summary
      where timecard_id = p_timecard_id;

   cursor c_last_timecard_status
            (p_timecard_id in hxc_time_building_blocks.time_building_block_id%type) is
     select approval_status
       from hxc_time_building_blocks tbb1
      where tbb1.time_building_block_id = p_timecard_id
	and tbb1.object_version_number =
	      (select max(tbb2.object_version_number)
		 from hxc_time_building_blocks tbb2
		where tbb2.time_building_block_Id = tbb1.time_building_block_id
		      );

l_tcstatus hxc_timecard_summary.approval_status%type;

BEGIN

   open c_timecard_status(bb_id,bb_ovn);
   fetch c_timecard_status into l_tcstatus;
   if (c_timecard_status%notfound) then
      close c_timecard_status;
      /**
       * If we get here it means the CBO has chosen a plan that is evaluating the
       * status of a timecard, which has a lower OVN than the one currently
       * summarized.  Thus, simply look for the status of the timecard in the
       * summary table, since this will be the valid last status.
       */
      open c_timecard_no_ovn_status(bb_id);
      fetch c_timecard_no_ovn_status into l_tcstatus;
      if(c_timecard_no_ovn_status%notfound) then
	 close c_timecard_no_ovn_status;
	 /**
          * If we get here, it means the CBO has chosen a plan that is evaluating
          * a timecard status for a deleted timecard.  The view will ultimately
          * filter out the timecard, so we can simply return the last status
          * when the timecard was deleted without fear.
          */
	 open c_last_timecard_status(bb_id);
	 fetch c_last_timecard_status into l_tcstatus;
	 if(c_last_timecard_status%notfound) then
	    close c_last_timecard_status;
	    /**
             * If we get here, it means the building block id did not exist
             * in the time building blocks table (partioned?), and we should error.
             */
	    fnd_message.set_name('HXC','HXC_APR_NO_TIMECARD_INFO');
	    fnd_message.set_token('TIMECARD_ID',to_char(bb_id));
	    fnd_message.raise_error;
	 else
	    close c_last_timecard_status;
	end if;
     else
	close c_timecard_no_ovn_status;
     end if;
   else
      close c_timecard_status;
   end if;

return l_tcstatus;

END get_timecard_status_code;



--
-- overloaded function get_timecard_status_code
--
--
-- description 	Calculates the status (Meaning) of a timecard after looking
--		into the status of application periods within or
--		surrounding the timecard.
--
-- parameters
--              bb_id		  - Building block id of timecard
--              bb_ovn            - Building block ovn of the timecard
--              p_mode            - Migration mode or normal mode.
--                                - in case of normal mode, the overloaded version
--                                - given above will be used.
--
-- returns 	Status of timecard
--

FUNCTION get_timecard_status_code(bb_id number, bb_ovn number, p_mode varchar2)
return varchar2
is

cursor c_get_approval_status
         (p_tc_start_time in HXC_TIME_BUILDING_BLOCKS.START_TIME%TYPE
         ,p_tc_stop_time in HXC_TIME_BUILDING_BLOCKS.STOP_TIME%TYPE
         ,p_resource_id in HXC_TIME_BUILDING_BLOCKS.RESOURCE_ID%TYPE
         ,p_approval_after in HXC_TIME_BUILDING_BLOCKS.CREATION_DATE%TYPE) is
  select
        hap.approval_status
       ,hap.start_time
       ,hap.stop_time
   from
        hxc_time_building_blocks hap
   where
        hap.scope = 'APPLICATION_PERIOD'
    and hap.type = 'RANGE'
    and hap.date_to = hr_general.end_of_time
    and hap.resource_type = 'PERSON'
    and hap.start_time <= p_tc_stop_time
    and hap.stop_time >= p_tc_start_time
    and hap.resource_id = p_resource_id
    and hap.creation_date >= p_approval_after;

cursor csr_get_latest_block
         (p_timecard_id in HXC_TIME_BUILDING_BLOCKS.TIME_BUILDING_BLOCK_ID%TYPE
         ,p_timecard_ovn in HXC_TIME_BUILDING_BLOCKS.OBJECT_VERSION_NUMBER%TYPE
         ) is
select max(details.creation_date)
  from hxc_time_building_blocks details
      ,hxc_time_building_blocks days
 where days.parent_building_block_id = p_timecard_id
   and days.parent_building_block_ovn = p_timecard_ovn
   and days.scope = 'DAY'
   and days.date_to = hr_general.end_of_time
   and details.parent_building_block_id = days.time_building_block_id
   and details.parent_building_block_ovn = days.object_version_number
   and details.date_to = hr_general.end_of_time
   and details.scope = 'DETAIL';

cursor csr_get_latest_day
         (p_timecard_id in HXC_TIME_BUILDING_BLOCKS.TIME_BUILDING_BLOCK_ID%TYPE
         ,p_timecard_ovn in HXC_TIME_BUILDING_BLOCKS.OBJECT_VERSION_NUMBER%TYPE
         ) is
select max(creation_date)
  from hxc_time_building_blocks
 where parent_building_block_id = p_timecard_id
   and parent_building_block_ovn = p_timecard_ovn
   and scope = 'DAY'
   and date_to = hr_general.end_of_time;

l_app_periods app_period_table;

l_count number;
l_start_time date;
l_stop_time date;
l_resource_id number;
l_tcstatus varchar2(1000);
l_submitted varchar2(1000);
l_latest_block_date DATE;
l_day_count number;
l_day_number number;
l_day DATE;
l_day_status hxc_time_building_blocks.approval_status%type;
l_day_set BOOLEAN;
l_app_period_count number;

BEGIN

if p_mode = hxc_timecard_summary_pkg.c_normal_mode or p_mode is null then

  return get_timecard_status_code(bb_id, bb_ovn);

elsif p_mode = hxc_timecard_summary_pkg.c_migration_mode  then
	l_submitted := 'false';

	-- Original Timecard Status
	select approval_status, start_time, stop_time, resource_id into l_tcstatus, l_start_time, l_stop_time, l_resource_id
	from hxc_time_building_blocks
	where time_building_block_id = bb_id
	and object_version_number = bb_ovn;

	IF l_tcstatus = 'WORKING' or l_tcstatus = 'ERROR'
	THEN
	  RETURN l_tcstatus;
	END IF;

	open csr_get_latest_block(bb_id,bb_ovn);
	fetch csr_get_latest_block into l_latest_block_date;
	close csr_get_latest_block;

	if(l_latest_block_date is null) then
	  open csr_get_latest_day(bb_id,bb_ovn);
	  fetch csr_get_latest_day into l_latest_block_date;
	  close csr_get_latest_day;
	end if;
	--
	-- Ok, now check the application period building blocks if there
	-- are any
	--

	l_count := 0;

	FOR apr_rec in c_get_approval_status(l_start_time, l_stop_time, l_resource_id, l_latest_block_date) LOOP

	  l_count:= l_count +1;

	  if(apr_rec.approval_status = 'REJECTED') then

	    l_tcstatus := apr_rec.approval_status;

	  elsif (apr_rec.approval_status = 'SUBMITTED') then

	    if(l_tcstatus = 'APPROVED') then

	     l_tcstatus := apr_rec.approval_status;

	    end if;

	  elsif (apr_rec.approval_status = 'APPROVED') then

	    if(l_count=1) then

	     l_tcstatus := apr_rec.approval_status;

	    end if;

	  end if;

	  l_app_periods(l_count).approval_status := apr_rec.approval_status;
	  l_app_periods(l_count).start_time := apr_rec.start_time;
	  l_app_periods(l_count).stop_time := apr_rec.stop_time;

	END LOOP;


	if(l_tcstatus = 'APPROVED') then

	l_day_number := trunc(l_stop_time) - trunc(l_start_time);

	l_day_count := 0;

	while (l_day_count < (l_day_number+1)) LOOP

	  l_day := l_start_time + l_day_count;
	  l_day_status := 'SUBMITTED';
	  l_day_set := FALSE;

	  for l_app_period_count in l_app_periods.first..l_app_periods.last loop

	    if(l_day between l_app_periods(l_app_period_count).start_time
			 and l_app_periods(l_app_period_count).stop_time) then

	      if(NOT l_day_set) then
		l_day_set := TRUE;
		l_day_status := l_app_periods(l_app_period_count).approval_status;
	      else
		if (l_app_periods(l_app_period_count).approval_status = 'REJECTED') then
		  l_day_status := 'REJECTED';
		elsif (l_app_periods(l_app_period_count).approval_status = 'SUBMITTED') then
		  if (l_day_status <> 'REJECTED') then
		     l_day_status := l_app_periods(l_app_period_count).approval_status;
		  end if;
		end if;
	      end if;
	     end if;

	    exit when (l_day_status = 'REJECTED');

	  end loop;

	  exit when (l_day_status <> 'APPROVED');

	  l_day_count := l_day_count +1;

	end loop;

	if(l_day_status <> l_tcstatus) then
	  l_tcstatus := l_day_status;
	end if;

	end if;

	return l_tcstatus;

end if;

exception

  when others then
     fnd_message.set_name('HXC', 'HXC_ERROR_FINDING_TIMECARD_STATUS');
     fnd_message.raise_error;


END get_timecard_status_code;



--helper function
FUNCTION get_value_from_string(
  p_string      IN VARCHAR2
 ,p_value_index IN NUMBER
)
RETURN VARCHAR2
IS
l_separator VARCHAR2(1) := '|';
l_value     VARCHAR2(2000);

BEGIN

IF (INSTR(p_string, l_separator, 1, p_value_index+1) = 0) THEN
   --
   -- We need to send back the very last thing in the string, i.e.
   -- everything from the final g_separator.
   --
   l_value := SUBSTR(p_string,(INSTR(p_string, l_separator,1,p_value_index)+1));
ELSE


   l_value := SUBSTR(p_string
             ,(INSTR(p_string,l_separator,1,p_value_index)+1)
             ,((INSTR(p_string,l_separator,1,(p_value_index+1))-1)
              -INSTR(p_string,l_separator,1,p_value_index))
              );
END IF;

RETURN l_value;

END get_value_from_string;

FUNCTION get_attributes_by_alias(
  p_alias_definition_id IN hxc_alias_values.alias_definition_id%TYPE
 ,p_search_operator     IN VARCHAR2
 ,p_search_value        IN VARCHAR2
)
RETURN VARCHAR2
IS
  l_alias_sql      VARCHAR2(300);
  l_like_string    VARCHAR2(1);
  l_return_string  VARCHAR2(32767) := '';
  l_value_string   VARCHAR2(300);
  type cur_type is REF CURSOR;
  l_cursor         cur_type;
BEGIN
  IF INSTR(p_search_operator, 'LIKE') > 0
  THEN
    l_like_string := '%';
  ELSE
    l_like_string := '';
  END IF;

  l_alias_sql := 'SELECT attribute1'
                || ' FROM  hxc_alias_values_v'
                ||' WHERE  alias_definition_id = :p_alias_definition_id'
                || '  AND alias_value_name '
                || p_search_operator
                || ':l_like_string||:p_search_value||:l_like_string';

  OPEN l_cursor for l_alias_sql using p_alias_definition_id,l_like_string,p_search_value,l_like_string;
  LOOP
    FETCH l_cursor INTO l_value_string;
    EXIT WHEN l_cursor%NOTFOUND;

    l_return_string := add_value_to_string(l_return_string, l_value_string);

  END LOOP;
  CLOSE l_cursor;

  IF l_return_string IS NULL
  THEN
    l_return_string := '-1';
  END IF;

  RETURN  l_return_string;
END get_attributes_by_alias;



FUNCTION get_attributes(
  p_search_by              IN VARCHAR2
 ,p_search_value           IN VARCHAR2
 ,p_flex_segment           IN VARCHAR2
 ,p_flex_context           IN VARCHAR2
 ,p_flex_name              IN VARCHAR2
 ,p_application_short_name IN VARCHAR2
 ,p_operator               IN VARCHAR2
 ,p_resource_id            IN VARCHAR2
 ,p_field_name             IN VARCHAR2
 ,p_user_set               IN VARCHAR2 DEFAULT 'Y'
)
RETURN VARCHAR2
IS
l_alias_definition_id hxc_alias_values.alias_definition_id%TYPE;
l_alias_used          BOOLEAN := FALSE;
l_field_name          hxc_alias_definitions.timecard_field%TYPE;

CURSOR c_field_name(
  p_alias_definition_id hxc_alias_values.alias_definition_id%TYPE
)
IS
  SELECT timecard_field
    FROM hxc_alias_definitions
   WHERE alias_definition_id = p_alias_definition_id;

BEGIN
  IF p_search_by = 'DUMMY ELEMENT CONTEXT'
  THEN
    l_alias_definition_id := hxc_preference_evaluation.resource_preferences(
                                p_resource_id,
                               'TC_W_TCRD_ALIASES',
                                1);

    OPEN c_field_name (
      p_alias_definition_id => l_alias_definition_id
    );

    FETCH c_field_name INTO l_field_name;
    IF c_field_name%NOTFOUND
    THEN
      CLOSE c_field_name;
    ELSE
      CLOSE c_field_name;
      IF l_field_name = 'Hours Type'
      THEN
        l_alias_used := TRUE;
      END IF;
    END IF;
  END IF;

  IF l_alias_used
  THEN

    RETURN get_attributes_by_alias(
             p_alias_definition_id => l_alias_definition_id
            ,p_search_operator     => p_operator
            ,p_search_value        => p_search_value
           );
  ELSE
    RETURN get_attributes_by_flex(
             p_flex_search_value      => p_search_value
            ,p_flex_segment           => p_flex_segment
            ,p_flex_context           => p_flex_context
            ,p_flex_name              => p_flex_name
            ,p_application_short_name => p_application_short_name
            ,p_operator               => p_operator
            ,p_resource_id            => p_resource_id
            ,p_field_name             => p_field_name
            ,p_user_set               => p_user_set
           );
  END IF;

END get_attributes;


-- =========================================================================
-- This procedure builds a complete sql for advanced search.  Java code
-- calls this routine to build the VO.
-- =========================================================================

PROCEDURE get_search_sql(
  p_resource_id           IN  VARCHAR2
 ,p_search_start_time     IN  VARCHAR2
 ,p_search_stop_time      IN  VARCHAR2
 ,p_search_rows           IN  VARCHAR2
 ,p_search_input_string   IN  VARCHAR2
 ,p_result                OUT NOCOPY VARCHAR2
)
IS
  l_search_table      search_table;
  l_table_index       NUMBER:= 1;
  l_value_index       NUMBER:= 1;
  l_search_rows       NUMBER := TO_NUMBER(p_search_rows);
  l_search_by         VARCHAR2(100);
  l_search_operator   VARCHAR2(30);
  l_search_value      VARCHAR2(1000);
  l_search_connector  VARCHAR2(5);
  l_detail_join_flag  BOOLEAN := FALSE;
  l_attribute_flag    BOOLEAN := FALSE;
  l_like_string       VARCHAR2(1);
  l_context           VARCHAR2(100);
  l_segment           VARCHAR2(100);
  l_bld_blk_info_type_id NUMBER;
  l_prefix            VARCHAR2(50);
  l_sql_select        VARCHAR2(1000);
  l_sql_from          VARCHAR2(1000);
  l_flex_search_value VARCHAR2(32767);
  l_sql_where         VARCHAR2(32767);
  l_additional_where  VARCHAR2(32767);
  l_one_where         VARCHAR2(32767);
  l_complete_sql      VARCHAR2(32767);
  l_result            VARCHAR2(32767);
  l_timecard_id       hxc_time_building_blocks.time_building_block_id%TYPE;
  l_timecard_ovn      hxc_time_building_blocks.object_version_number%TYPE;
  l_status_code       VARCHAR(30);
  l_status_meaning    VARCHAR(100);
  l_period_starts     hxc_time_building_blocks.start_time%TYPE;
  l_period_ends       hxc_time_building_blocks.stop_time%TYPE;
  l_hours_worked      NUMBER;
  l_submission_date   DATE;
  c_sql               cur_type;


  CURSOR c_mapping_segment(
    p_field_name VARCHAR2
  )
  IS
    SELECT context, segment, bld_blk_info_type_id
    FROM hxc_mapping_attributes_v
    WHERE map = 'OTL Deposit Process Mapping'
      AND upper(field_name) = upper(p_field_name);

BEGIN

  -- put values in table

  FOR l_table_index IN 1..l_search_rows LOOP
    l_search_table(l_table_index).search_by
      := get_value_from_string(p_search_input_string, l_value_index);
    l_value_index := l_value_index + 1;

    l_search_table(l_table_index).search_operator
      := get_value_from_string(p_search_input_string, l_value_index);
    l_value_index := l_value_index + 1;


    l_search_table(l_table_index).search_value
      := get_value_from_string(p_search_input_string, l_value_index);
    l_value_index := l_value_index + 1;

    l_search_table(l_table_index).search_connector
     := get_value_from_string(p_search_input_string, l_value_index);
    l_value_index := l_value_index + 1;

  END LOOP;


  l_sql_select := 'SELECT distinct hrt.timecard_id'
               || '      ,hrt.timecard_ovn'
               || '      ,hxc_timecard_search_pkg.get_timecard_status_code('
               || '         hrt.timecard_id, '
               || '         hrt.timecard_ovn'
               || '       ) as status_code'
               || '      ,hxc_timecard_search_pkg.get_timecard_status_meaning('
               || '         hrt.timecard_id, '
               || '         hrt.timecard_ovn'
               || '       ) as status_name'
               || '     ,hrt.period_starts'
               || '     ,hrt.period_ends'
               || '     ,hrt.hours_worked'
               || '     ,hrt.submission_date';

  l_sql_from := 'FROM hxc_resource_timecards_v hrt';

  l_sql_where := 'WHERE hrt.resource_id = ' || p_resource_id;

  IF p_search_start_time IS NOT NULL
  THEN
    l_sql_where := l_sql_where
                || ' AND TRUNC(hrt.period_starts) >= TO_DATE('
                || ''''
                || p_search_start_time
                || ''''
                || ', ''RRRR/MM/DD'')';
  END IF;

  IF p_search_stop_time IS NOT NULL
  THEN
    l_sql_where := l_sql_where
                || ' AND TRUNC(hrt.period_ends) <= TO_DATE('
                || ''''
                ||                            p_search_stop_time
                || ''''
                || ', ''RRRR/MM/DD'')';
  END IF;


  l_additional_where := NULL;

  FOR l_index IN 1..l_search_rows LOOP
    l_search_by := l_search_table(l_index).search_by;
    l_search_operator := l_search_table(l_index).search_operator;
    l_search_value := l_search_table(l_index).search_value;
    l_search_connector := l_search_table(l_index).search_connector;

    IF instr(l_search_operator, 'LIKE') <> 0
    THEN
      l_like_string := '%';
    ELSE
      l_like_string := '';
    END IF;

    IF l_search_by = 'SUBMISSION_DATE'
      OR l_search_by = 'PERIOD_ENDS'
      OR l_search_by = 'PERIOD_STARTS'
    THEN
      l_one_where := 'TRUNC(hrt.'
                  || l_search_by
                  || ') '
                  || l_search_operator
                  || ' TO_DATE('
                  || ''''
                  || l_search_value
                  || ''''
                  || ', ''RRRR/MM/DD'')';

    ELSIF l_search_by = 'TIMECARD_COMMENT'
    THEN
       l_one_where := 'NVL(hrt.timecard_comment, '' '') '
                   || l_search_operator
                   || ''''
                   || l_like_string
                   || l_search_value
                   || l_like_string
                   || '''';
    ELSIF l_search_by = 'DETAIL_COMMENT'
    THEN
      IF NOT l_detail_join_flag
      THEN
        l_sql_from := l_sql_from
                   || '    ,hxc_time_building_blocks htbb_day'
                   || '    ,hxc_time_building_blocks htbb_detail';


        l_sql_where := l_sql_where
                    || '  AND htbb_day.parent_building_block_id = hrt.timecard_id'
                    || '  AND htbb_day.parent_building_block_ovn = hrt.timecard_ovn'
                    || '  AND htbb_day.date_to = hr_general.end_of_time'
                    || '  AND htbb_detail.parent_building_block_id = htbb_day.time_building_block_id'
                    || '  AND htbb_detail.parent_building_block_ovn = htbb_day.object_version_number'
                    || '  AND htbb_detail.date_to = hr_general.end_of_time';


        l_detail_join_flag := TRUE;
      END IF;

      l_one_where :=  'NVL(htbb_detail.comment_text, '' '') '
                   || l_search_operator
                   || ' '''
                   || l_like_string
                   || l_search_value
                   || l_like_string
                   || '''';
    ELSIF l_search_by = 'STATUS_CODE'
    THEN
      l_one_where := 'hrt.status_name '          -- should modify hxc_resource_timecards_v
                   || l_search_operator
                   || ' '''
                   || l_like_string
                   || l_search_value
                   || l_like_string
                   || '''';
    ELSIF l_search_by = 'HOURS_WORKED'
    THEN
      l_one_where := 'hrt.'
                  || l_search_by
                  || ' '
                  || l_search_operator
                  || ' '''
                  || l_like_string
                  || l_search_value
                  || l_like_string
                  || '''';
    ELSE
      -- attribute search
      OPEN c_mapping_segment(l_search_by);
      FETCH c_mapping_segment INTO l_context, l_segment, l_bld_blk_info_type_id;

      IF c_mapping_segment%NOTFOUND
      THEN
        CLOSE c_mapping_segment;

        FND_MESSAGE.set_name('HXC','HXC_NO_MAPPING_COMPONENT');
        FND_MESSAGE.RAISE_ERROR;
      END IF;

      CLOSE c_mapping_segment;


      l_flex_search_value :=
        get_attributes(
          p_search_by              => l_search_by
         ,p_search_value           => l_search_value
         ,p_flex_segment           => l_segment
         ,p_flex_context           => l_context
         ,p_flex_name              => 'OTC Information Types'
         ,p_application_short_name => 'HXC'
         ,p_operator               => l_search_operator
         ,p_resource_id            => p_resource_id
         ,p_field_name             => l_search_by
        );

      IF NOT l_attribute_flag
      THEN
        l_sql_from := l_sql_from
                   || '    ,hxc_time_attribute_usages htau'
                   || '    ,hxc_time_attributes hta';

        IF NOT l_detail_join_flag
        THEN
          l_sql_from := l_sql_from
                   || '    ,hxc_time_building_blocks htbb_day'
                   || '    ,hxc_time_building_blocks htbb_detail';


          l_sql_where := l_sql_where
                    || '  AND htbb_day.parent_building_block_id = hrt.timecard_id'
                    || '  AND htbb_day.parent_building_block_ovn = hrt.timecard_ovn'
                    || '  AND htbb_day.date_to = hr_general.end_of_time'
                    || '  AND htbb_detail.parent_building_block_id = htbb_day.time_building_block_id'
                    || '  AND htbb_detail.parent_building_block_ovn = htbb_day.object_version_number'
                    || '  AND htbb_detail.date_to = hr_general.end_of_time';


          l_detail_join_flag := TRUE;
        END IF;

        l_sql_where := l_sql_where
                    || ' AND htau.time_building_block_id = htbb_detail.time_building_block_id'
                    || ' AND htau.time_building_block_ovn = htbb_detail.object_version_number'
                    || ' AND htau.time_attribute_id = hta.time_attribute_id';

        l_attribute_flag := TRUE;
      END IF;

      --for DUMMY ELEMENT CONTEXT, the stored values are 'ELEMENT - id',
      --for DUMMY COST CONTEXT, the stored values are 'COST - id',
      --we should extract the ids from them.

      l_search_by := UPPER(l_search_by);

      IF l_search_by = 'DUMMY ELEMENT CONTEXT'
      THEN
        l_prefix := 'ELEMENT - ';
      ELSIF l_search_by = 'DUMMY COST CONTEXT'
      THEN
        l_prefix := 'COST - ';
      END IF;

      IF l_prefix IS NOT NULL
      THEN
/*
        l_one_where := ' hta.attribute_category = '
                  || ''''
                  || l_context
                  || ''''
                  || ' AND SUBSTR(hta.'
                  || l_segment
                  || ', LENGTH('''
                  || l_prefix
                  || ''') + 1) IN ('
                  || l_flex_search_value
                  || ')';
*/
         l_one_where := ' hta.bld_blk_info_type_id = '
                  || l_bld_blk_info_type_id
                  || ' AND SUBSTR(hta.'
                  || l_segment
                  || ', LENGTH('''
                  || l_prefix
                  || ''') + 1) IN ('
                  || l_flex_search_value
                  || ')';
      ELSE
        l_one_where := ' hta.attribute_category = '
                  || ''''
                  || l_context
                  || ''''
                  || ' AND hta.'
                  || l_segment
                  || ' IN ('
                  || l_flex_search_value
                  || ')';

      END IF;
    END IF;

    l_additional_where := l_additional_where
                       || ' '
                       || l_search_connector
                       || ' '
                       || l_one_where;

  END LOOP;

  IF l_additional_where IS NOT NULL
  THEN
    l_sql_where := l_sql_where
                || ' AND ('
                ||         l_additional_where
                || '     )';
  END IF;

  l_complete_sql := l_sql_select
                 || ' '
                 || l_sql_from
                 || ' '
                 || l_sql_where;


/*
  l_result := NULL;
  OPEN c_sql for l_complete_sql;
  LOOP
    FETCH c_sql INTO l_timecard_id, l_timecard_ovn, l_status_code, l_status_meaning,
                     l_period_starts, l_period_ends, l_hours_worked, l_submission_date;

    EXIT WHEN c_sql%NOTFOUND;

    l_result := l_result || '|'
             || l_timecard_id || '|'
             || l_timecard_ovn || '|'
             || NVL(l_status_code, 'NULL')  || '|'
             || NVL(l_status_meaning, 'NULL') || '|'
             || TO_CHAR(l_period_starts, 'YYYY/MM/DD') || '|'
             || TO_CHAR(l_period_ends, 'YYYY/MM/DD') || '|'
             || l_hours_worked || '|'
             || TO_CHAR(l_submission_date, 'YYYY/MM/DD');
  END LOOP;


  p_result := l_result;
*/
  p_result := l_complete_sql;
END get_search_sql;

-- ==========================================================================================
-- this function returns the where clause for attribute search
-- NOTE: if this is called from timecard search screen, p_resource_id will be the person who
--       is performing the search. If this is called from approval screen, p_resource_id will
--       be the approver who is performing the search.
-- ==========================================================================================
PROCEDURE get_sql_where(
  p_resource_id           IN  VARCHAR2
 ,p_search_rows           IN  VARCHAR2
 ,p_search_input_string   IN  VARCHAR2
 ,p_where                 OUT NOCOPY VARCHAR2

)
IS
  l_search_table      search_table;
  l_table_index       NUMBER:= 1;
  l_value_index       NUMBER:= 1;
  l_search_rows       NUMBER := TO_NUMBER(p_search_rows);
  l_search_by         VARCHAR2(100);
  l_search_operator   VARCHAR2(30);
  l_search_value      VARCHAR2(1000);
  l_search_connector  VARCHAR2(5);
  l_detail_join_flag  BOOLEAN := FALSE;
  l_attribute_flag    BOOLEAN := FALSE;
  l_like_string       VARCHAR2(1);
  l_context           VARCHAR2(100);
  l_segment           VARCHAR2(100);
  l_bld_blk_info_type_id NUMBER;
  l_prefix            VARCHAR2(50);
  l_sql_select        VARCHAR2(1000);
  l_sql_from          VARCHAR2(1000);
  l_flex_search_value VARCHAR2(32767);
  l_sql_where         VARCHAR2(32767);
  l_additional_where  VARCHAR2(32767);
  l_one_where         VARCHAR2(32767);
  l_complete_sql      VARCHAR2(32767);
  l_result            VARCHAR2(32767);
  l_timecard_id       hxc_time_building_blocks.time_building_block_id%TYPE;
  l_timecard_ovn      hxc_time_building_blocks.object_version_number%TYPE;
  l_status_code       VARCHAR(30);
  l_status_meaning    VARCHAR(100);
  l_period_starts     hxc_time_building_blocks.start_time%TYPE;
  l_period_ends       hxc_time_building_blocks.stop_time%TYPE;
  l_hours_worked      NUMBER;
  l_submission_date   DATE;
  c_sql               cur_type;

  --column names
  l_period_starts_column   VARCHAR2(300);
  l_period_ends_column     VARCHAR2(300);
  l_submission_date_column VARCHAR2(300);
  l_comment_column         VARCHAR2(300);
  l_status_column          VARCHAR2(300);
  l_hours_column           VARCHAR2(300);

  l_detail_join_where      VARCHAR2(3000);

  CURSOR c_mapping_segment(
    p_field_name VARCHAR2
  )
  IS
    SELECT context, segment, bld_blk_info_type_id
    FROM hxc_mapping_attributes_v
    WHERE map = 'OTL Deposit Process Mapping'
      AND upper(field_name) = upper(p_field_name);

BEGIN

   -- Bug Fix for 2581640 Start
   -- Initialize the multi-message stack.

   fnd_msg_pub.initialize;

   -- Bug Fix for 2581640 End

  -- put values in table

  FOR l_table_index IN 1..l_search_rows LOOP
    l_search_table(l_table_index).search_by
      := get_value_from_string(p_search_input_string, l_value_index);
    l_value_index := l_value_index + 1;

    l_search_table(l_table_index).search_operator
      := get_value_from_string(p_search_input_string, l_value_index);
    l_value_index := l_value_index + 1;


    l_search_table(l_table_index).search_value
      := get_value_from_string(p_search_input_string, l_value_index);
    l_value_index := l_value_index + 1;

    l_search_table(l_table_index).search_connector
     := get_value_from_string(p_search_input_string, l_value_index);
    l_value_index := l_value_index + 1;

  END LOOP;

  p_where := '';

  FOR l_index IN 1..l_search_rows LOOP
    l_search_by := l_search_table(l_index).search_by;
    l_search_operator := l_search_table(l_index).search_operator;
    l_search_value := l_search_table(l_index).search_value;
    l_search_connector := l_search_table(l_index).search_connector;

    IF instr(l_search_operator, 'LIKE') <> 0
    THEN
      l_like_string := '%';
    ELSE
      l_like_string := '';
    END IF;

      -- attribute search
      OPEN c_mapping_segment(l_search_by);
      FETCH c_mapping_segment INTO l_context, l_segment, l_bld_blk_info_type_id;

      IF c_mapping_segment%NOTFOUND
      THEN
        CLOSE c_mapping_segment;

        FND_MESSAGE.set_name('HXC','HXC_NO_MAPPING_COMPONENT');

   	-- Bug Fix for 2581640 Start
   	-- Add error to the multi-message stack and retreive the error
   	-- message in TimecardSearch.java. No need for RAISE_ERROR.
   	FND_MSG_PUB.ADD;
        -- FND_MESSAGE.RAISE_ERROR;
        -- Bug Fix for 2581640 End

      END IF;

      CLOSE c_mapping_segment;

      l_flex_search_value :=
        get_attributes(
          p_search_by              => l_search_by
         ,p_search_value           => l_search_value
         ,p_flex_segment           => l_segment
         ,p_flex_context           => l_context
         ,p_flex_name              => 'OTC Information Types'
         ,p_application_short_name => 'HXC'
         ,p_operator               => l_search_operator
         ,p_resource_id            => p_resource_id
         ,p_field_name             => l_search_by
        );

      --for DUMMY ELEMENT CONTEXT, the stored values are 'ELEMENT - id',
      --for DUMMY COST CONTEXT, the stored values are 'COST - id',
      --we should extract the ids from them.

      l_search_by := UPPER(l_search_by);

      IF l_search_by = 'DUMMY ELEMENT CONTEXT'
      THEN
        l_prefix := 'ELEMENT - ';
      ELSIF l_search_by = 'DUMMY COST CONTEXT'
      THEN
        l_prefix := 'COST - ';
      END IF;



      IF l_prefix IS NOT NULL
      THEN

         l_one_where := ' hta.bld_blk_info_type_id = '
                  || l_bld_blk_info_type_id
                  || ' AND SUBSTR(hta.'
                  || l_segment
                  || ', LENGTH('''
                  || l_prefix
                  || ''') + 1) IN ('
                  || l_flex_search_value
                  || ')';
      ELSE

       if l_flex_search_value = hxc_timecard_search_pkg.c_no_valueset_attached
       then
         l_one_where := ' hta.bld_blk_info_type_id = '
	                   || l_bld_blk_info_type_id
	                   || ' AND hta.'
	                   || l_segment
	                   || ' '
	                   || l_search_operator
	                   || ' '
	                   || ''''
	                   || l_like_string
	                   || l_search_value
	                   || l_like_string
	                   || '''';

       else
        l_one_where := ' hta.bld_blk_info_type_id = '
                  || l_bld_blk_info_type_id
                  || ' AND hta.'
                  || l_segment
                  || ' IN ('
                  || l_flex_search_value
                  || ')';
      end if;

      END IF;

      -- Bug 3616179

      if (l_index = 1) then
        -- Incase of first attribute search option,l_search_connector might be not-NULL.
        -- So place only the left parenthesis after the connector.

	p_where := l_search_connector
	      	    || ' '
	            || '('
	            || '('
		    || l_one_where
		    || ')';

      else
      	p_where := p_where
	            || ' '
	            || l_search_connector
	            || ' '
	            || '('
	            || l_one_where
                    || ')';
      end if;


  END LOOP;

-- Bug 3616179
-- Finally place the right parenthesis before returning the value.
    p_where := p_where || ')';


END get_sql_where;


END hxc_timecard_search_pkg;

/
