--------------------------------------------------------
--  DDL for Package Body PAY_HXC_DEPOSIT_INTERFACE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_HXC_DEPOSIT_INTERFACE" AS
/* $Header: pyhxcdpi.pkb 120.5.12010000.4 2009/08/20 16:29:35 asrajago ship $ */

--
--
TYPE t_field_name IS TABLE OF VARCHAR2(80) INDEX BY BINARY_INTEGER;
TYPE t_value IS TABLE OF VARCHAR2(150) INDEX BY BINARY_INTEGER;
TYPE t_attribute IS TABLE OF NUMBER(15) INDEX BY BINARY_INTEGER;
--
--
--
TYPE t_segment IS TABLE OF varchar2(60) INDEX BY BINARY_INTEGER;

TYPE r_input_value IS RECORD (
        name    pay_input_values_f.name%TYPE
,       id      pay_input_values_f.input_value_id%TYPE
,       value   VARCHAR2(80));
TYPE t_input_value IS TABLE OF r_input_value INDEX BY BINARY_INTEGER;


TYPE pto_assignment_info_rec IS RECORD (
     effective_start_date DATE
,    effective_end_date   DATE
,    bg_id                NUMBER(15) );

TYPE pto_assignment_info_tab IS TABLE OF pto_assignment_info_rec INDEX BY BINARY_INTEGER;

g_pto_assignment_info pto_assignment_info_tab;

TYPE pto_element_rec IS RECORD (
      is_pto              VARCHAR2(1),
      att_num             NUMBER(2),
      iv_id               NUMBER(15) );

TYPE pto_element_tab IS TABLE OF pto_element_rec INDEX BY BINARY_INTEGER;

g_pto_element pto_element_tab;

e_continue EXCEPTION;

-----------------------------------------------------------------------
PROCEDURE get_input_value_name (p_element_type_id IN number,
                                p_field_name    IN VARCHAR2,
                                p_ipv_name      OUT NOCOPY PAY_INPUT_VALUES_F.NAME%TYPE
                               )
IS
	l_ivn_cached BOOLEAN := false;
	l_iter BINARY_INTEGER;

cursor c_input_value_name
         (p_ele_type_id in number
         ,p_ipv_segment in VARCHAR2) is
  select end_user_column_name
    from fnd_descr_flex_column_usages c, hxc_mapping_components mpc
   where c.application_id = 809
     and c.descriptive_flexfield_name = 'OTC Information Types'
     and c.descriptive_flex_context_code = 'ELEMENT - '||to_char(p_ele_type_id)
     and c.application_column_name = mpc.segment
     and upper(mpc.field_name) = p_ipv_segment;

BEGIN
	l_iter := g_ivn_ct.first;
	WHILE l_iter is not null LOOP
		if  (g_ivn_ct(l_iter).element_type_id = p_element_type_id) and
			(g_ivn_ct(l_iter).field_name = p_field_name)
		then
			p_ipv_name := g_ivn_ct(l_iter).ipv_name;
			l_ivn_cached := true;
			exit;
		end if;
		l_iter := g_ivn_ct.next(l_iter);
	END LOOP;

	if (not l_ivn_cached) then

        open c_input_value_name(p_element_type_id,upper(p_field_name));
        fetch c_input_value_name into p_ipv_name;
		close c_input_value_name;
			--let us cache
			l_iter := nvl(g_ivn_ct.last,0)+1;
			g_ivn_ct(l_iter).element_type_id := p_element_type_id;
			g_ivn_ct(l_iter).field_name := p_field_name;
			g_ivn_ct(l_iter).ipv_name := p_ipv_name;
	end if;

END get_input_value_name;

--
PROCEDURE populate_iv_map(p_element_type_id IN NUMBER,
                 p_effective_date IN DATE)
IS
l_cnt            NUMBER(15);
l_input_value_id NUMBER(9);
l_name           VARCHAR2(80);
l_seq            NUMBER(5);
l_uom            VARCHAR2(30);


-- Bug 6943339
-- Added one more column in the selected columns
-- list to pick up the UOM of the given input value
-- for format conversions later.

cursor csr_get_iv (p_element_type_id in number,
                   p_effective_date in date) IS
   select piv.name, piv.input_value_id, piv.display_sequence,
          piv.effective_start_date, piv.effective_end_date,
          piv.uom
     from pay_input_values_f piv
    where piv.element_type_id = p_element_type_id
      and p_effective_date between piv.effective_start_date
                               and piv.effective_end_date
      order by piv.display_sequence
      ,        piv.name;


BEGIN

if ((not g_iv_map_ct.exists(p_element_type_id)) or
    (p_effective_date not between g_iv_map_ct(p_element_type_id).effective_start_date
                              and g_iv_map_ct(p_element_type_id).effective_end_date )
   ) then
	l_cnt := nvl(g_iv_mapping_ct.last,0)+1;
	g_iv_map_ct(p_element_type_id).start_index := l_cnt;
	open csr_get_iv(p_element_type_id, p_effective_date);
	LOOP
	   -- Bug 6943339
           -- Fetching UOM also after it was added in the selected columns.
           -- UOM is assigned to iv_uom of the global table for IV mapping.
	   fetch csr_get_iv into l_name, l_input_value_id, l_seq,
			 g_iv_map_ct(p_element_type_id).effective_start_date,
			 g_iv_map_ct(p_element_type_id).effective_end_date,
			 l_uom  ;
	   exit when csr_get_iv%notfound;
	   g_iv_mapping_ct(l_cnt).iv_name := l_name;
	   g_iv_mapping_ct(l_cnt).iv_id   := l_input_value_id;
	   g_iv_mapping_ct(l_cnt).iv_seq  := l_cnt;
	   g_iv_mapping_ct(l_cnt).iv_uom  := l_uom;
	   --g_iv_mapping_ct(l_cnt).iv_seq  := l_seq;
	   l_cnt := l_cnt + 1;
	END LOOP;
	close csr_get_iv;
	g_iv_map_ct(p_element_type_id).stop_index := l_cnt-1;

end if;

END populate_iv_map;
--------------------------------------------------------------------------
PROCEDURE get_iv_map(p_ipv_name IN PAY_INPUT_VALUES_F.NAME%TYPE,
                     p_cnt IN NUMBER,
                     p_seq OUT NOCOPY NUMBER,
                     p_iv_id OUT NOCOPY pay_input_values_f.input_value_id%TYPE,
                     p_is_hour OUT NOCOPY BOOLEAN)
IS

l_iter BINARY_INTEGER;
l_iv_map_cached BOOLEAN := false;
lcode 			 HR_LOOKUPS.lookup_code%TYPE;
BEGIN
	p_is_hour := false;
	l_iter := g_iv_lk_map_ct.first;
	WHILE l_iter is not null LOOP
	    if (g_iv_lk_map_ct(l_iter).iv_name = p_ipv_name) then
	    -- cached value available
		-- OTL - ABS Integration
		if (g_iv_lk_map_ct(l_iter).lcode IN ( 'HOURS','DAYS') )
		then

		   p_is_hour := true;

		   IF p_cnt is not null then
		  	p_seq := g_iv_mapping_ct(p_cnt).iv_seq;
		   	p_iv_id := g_iv_mapping_ct(p_cnt).iv_id;
		   END IF;
		end if;
	        l_iv_map_cached := true;
 	        exit;
	   end if;
	   l_iter := g_iv_lk_map_ct.next(l_iter);
	END LOOP;

	if (not l_iv_map_cached) then

	    lcode := hxt_batch_process.get_lookup_code(p_ipv_name,sysdate);
	    --let us cache this data
	    l_iter := nvl(g_iv_lk_map_ct.last,0)+1;
	    g_iv_lk_map_ct(l_iter).iv_name := p_ipv_name;
	    g_iv_lk_map_ct(l_iter).lcode := lcode;

	    -- OTL - ABS Integration
	    IF (lcode IN ( 'HOURS','DAYS') ) THEN
		IF p_cnt is not null then
		   p_seq := g_iv_mapping_ct(p_cnt).iv_seq;
		   p_iv_id := g_iv_mapping_ct(p_cnt).iv_id;
		END IF;

	        p_is_hour := true;
	    END IF;
	end if;

END get_iv_map;

--------------------------- get_input_values -----------------------------
--
PROCEDURE get_input_values (p_element_name      IN varchar2,
                            p_element_type_id   IN number,
                            p_type              IN varchar2,
                            p_measure           IN number,
                            p_start_time        IN date,
                            p_stop_time         IN date,
                            p_effective_date    IN date,
                            p_bb_id		IN number,
                            p_bb_ovn		IN number,
                            p_time_attribute_id IN number,
                            p_messages 		IN OUT NOCOPY hxc_self_service_time_deposit.message_table,
                            p_input_value          OUT NOCOPY t_input_value,
                            p_field_name        IN OUT NOCOPY t_field_name,
                            p_value             IN OUT NOCOPY t_value,
                            p_segment              OUT NOCOPY t_segment)
IS
--

l_ipv_name PAY_INPUT_VALUES_F.NAME%TYPE;
l_ipv_count NUMBER := 0;
--
--
l_seq            NUMBER(5);
l_seq1           NUMBER(5);
l_iv             NUMBER(5);
l_seg            NUMBER(5);
l_cnt            NUMBER(15);
l_input_value_id NUMBER(9);
l_name           VARCHAR2(80);
l_iv_map_cached  BOOLEAN;
l_iter           BINARY_INTEGER;
l_index_input_value BINARY_INTEGER;
lcode 		    HR_LOOKUPS.lookup_code%TYPE;
l_iv_id_1	    pay_input_values_f.input_value_id%TYPE;


l_ivn_cached	BOOLEAN;
l_is_hour 		BOOLEAN;
-- e_continue                        exception;


--
c_proc VARCHAR2(100) := 'pay_hxc_deposit_interface.get_input_values';

l_internal_value VARCHAR2(80);
l_display_value  VARCHAR2(80);
--

BEGIN -- begin get_input_values

--
--FOR iv in 1 .. 15 LOOP
--    g_iv_mapping_ct(iv) := NULL;
--END LOOP;
--

--

populate_iv_map(p_element_type_id,p_effective_date);


--
-- Reset l_seq
l_seq := NULL;

IF g_iv_map_ct(p_element_type_id).start_index > g_iv_map_ct(p_element_type_id).stop_index
then
   hxc_time_entry_rules_utils_pkg.add_error_to_table(
              p_message_table          => p_messages
             ,p_message_name           => 'HXC_HRPAY_RET_NO_IVS'
             ,p_message_token          => 'ELE_NAME&'||p_element_name
             ,p_message_level          => 'ERROR'
             ,p_message_field          => NULL
             ,p_application_short_name => 'HXC'
             ,p_timecard_bb_id         => p_bb_id
             ,p_time_attribute_id      => p_time_attribute_id
             ,p_timecard_bb_ovn        => p_bb_ovn
             ,p_time_attribute_ovn     => NULL);
   --
   raise e_continue;                --Bug#3004714

-- Start 2887210, i.e. Comment the raise error
--                     Instead let the errors consolidate in the message table.
--   raise e_error;
--  End  2887210
   --
END IF;
--
-- Initialize 15 input values to NULL
--
FOR iv in 1 .. 15 LOOP
    p_input_value(iv) := NULL;
END LOOP;
--
-- Initialize 30 costing segments to NULL
--
FOR seg in 1 .. 30 LOOP
    p_segment(seg) := NULL;
END LOOP;
--
-- Map Hours Input Value
--
--3675914
l_cnt := null;

FOR l_cnt in g_iv_map_ct(p_element_type_id).start_index .. g_iv_map_ct(p_element_type_id).stop_index LOOP

   --let us check for cached value first. only if we dont find it in cached plsql table,
   --are we going to check the db

   get_iv_map(p_ipv_name  => g_iv_mapping_ct(l_cnt).iv_name,
	      p_cnt       => l_cnt,
	      p_seq       => l_seq,
	      p_iv_id     => l_iv_id_1,
              p_is_hour   => l_is_hour);

   if l_is_hour then
      -- 3675914
      --p_input_value(l_seq).id := l_iv_id_1;
      p_input_value(1).id := l_iv_id_1;
      exit;
   end if;

END LOOP;
--
IF l_seq IS NULL THEN
   hxc_time_entry_rules_utils_pkg.add_error_to_table(
              p_message_table          => p_messages
             ,p_message_name           => 'HXC_HRPAY_RET_IV_NOT_FOUND'
             ,p_message_token  	       => 'ELE_NAME&'||p_element_name||'&IV_NAME&Hours/Days'
             ,p_message_level          => 'ERROR'
             ,p_message_field          => NULL
             ,p_application_short_name => 'HXC'
             ,p_timecard_bb_id         => p_bb_id
             ,p_time_attribute_id      => p_time_attribute_id
             ,p_timecard_bb_ovn        => p_bb_ovn
             ,p_time_attribute_ovn     => NULL);
   --
   raise e_continue;                --Bug#3004714

-- Start 2887210, i.e. Comment the raise error
--                     Instead let the errors consolidate in the message table.
--   raise e_error;
--  End  2887210
   --
   RETURN;
END IF;
--
hr_utility.set_location(c_proc, 10);
--
-- If the detail block is of type duration, then the number
-- of hours is in l_measure.
--
IF p_type = 'MEASURE' THEN

   -- 3675914
   --p_input_value(l_seq).value := to_char(p_measure);
   p_input_value(1).value := to_char(p_measure);
   --2223669
   -- p_input_value(l_seq).name := 'Hours';
   --p_input_value(l_seq).name := g_iv_mapping_ct(l_seq).iv_name;
   p_input_value(1).name := g_iv_mapping_ct(l_seq).iv_name;
   hr_utility.set_location(c_proc, 20);
   --
END IF;
--
hr_utility.set_location(c_proc, 30);
--
-- If the detail block is of type range, then the number
-- of hours is derived from the difference between
-- p_start_time and p_stop_time.
--
IF p_type = 'RANGE' THEN

   -- 3675914
   --p_input_value(l_seq).value := (p_stop_time - p_start_time) * 24;
   p_input_value(1).value := (p_stop_time - p_start_time) * 24;
   -- 2223669
   --p_input_value(l_seq).name := 'Hours';
   --p_input_value(l_seq).name := g_iv_mapping_ct(l_seq).iv_name;
   p_input_value(1).name := g_iv_mapping_ct(l_seq).iv_name;
   --
   hr_utility.set_location(c_proc, 40);
   --
END IF;
--
-- Print out the Hours value
--
--hr_utility.trace('Input Value name is ' || p_input_value(l_seq).name);
--
--hr_utility.trace('Input Value value is ' || p_input_value(l_seq).value);
--
hr_utility.set_location(c_proc, 50);
--
hr_utility.trace('p_effective_date is ' ||
                 to_char(p_effective_date, 'DD-MON-YYYY'));
--
hr_utility.trace('p_start_time is ' || to_char(p_start_time, 'DD-MON-YYYY'));
--
-- Map all other input values
--
IF p_field_name.count <> 0 THEN
--
-- 3675914
l_index_input_value := 2;

FOR iv_cnt in p_field_name.first .. p_field_name.last LOOP

hr_utility.trace('p field name is '||p_field_name(iv_cnt));

    IF upper(p_field_name(iv_cnt)) like 'INPUTVALUE%'  THEN
       --
       hr_utility.set_location(c_proc, 60);
       --
       hr_utility.trace('---- In Input Value Loop ----');
       --
       -- Find IPV name corresponding to this mapping
       -- component
       --
       --let us check if cached value exists

       get_input_value_name(p_element_type_id, p_field_name(iv_cnt),l_ipv_name);

       if (l_ipv_name is not null) then

        --get the lookup code value
	--let us look at the cached value.

	get_iv_map(p_ipv_name  => l_ipv_name,
	           p_cnt       => null,
	           p_seq       => l_seq1,
	           p_iv_id     => l_iv_id_1,
	           p_is_hour   => l_is_hour);

	if (not l_is_hour) then

            --
            -- Next find the sequence for the input value
            -- In this case, since there is no column on the
            -- input values table, we have to count how many we get back
            -- before we hit the input value name, and then set the
            -- value as that value.

            l_ipv_count := g_iv_map_ct(p_element_type_id).start_index;
            LOOP
              EXIT WHEN (NOT g_iv_mapping_ct.exists(l_ipv_count)); --OR
                         --l_ipv_count = g_iv_map_ct(p_element_type_id).stop_index);

hr_utility.trace('iv name is '||g_iv_mapping_ct(l_ipv_count).iv_name);
hr_utility.trace('iv id   is '||to_char(g_iv_mapping_ct(l_ipv_count).iv_id));
hr_utility.trace('Field Name is '||p_field_name(iv_cnt));
hr_utility.trace('Value is '||p_value(iv_cnt));
hr_utility.trace('Value passed in is '||p_input_value(l_index_input_value).value);

              if(g_iv_mapping_ct(l_ipv_count).iv_name = l_ipv_name) then
                --
                -- We can set the value since we have a match
                --

		-- WWB 4144047
		-- Added check to see if the input value we are passing was set to a canonical date

		-- Bug 6943339
		-- Added extra OR condition to the IF below, and a new ELSIF construct.
		-- The format change has to be done for not only the PTO entry effective dates
		-- but also any input value which is captured and which has to be of date format.
		-- The date value would be stored in attributes table in canonical format, and
		-- has to be changed to a display format.
		-- ELSIF added for a number datatype.  Since there could be preference differences
		-- b/w timekeeper and the HR user, the number format might be different. Eg. a
		-- comma instead of a period is used for decimal by some customers.
		-- OTL stores the NUMBER input values in attributes table after a conversion to
		-- canonical format, hence while creation of BEE entries, there has to be a conversion
		-- to number format.

		IF (    pay_hxc_deposit_interface.g_canonical_iv_id_tab.EXISTS(g_iv_mapping_ct(l_ipv_count).iv_id)
		     OR g_iv_mapping_ct(l_ipv_count).iv_uom = 'D'
		   )
		THEN

                        hr_utility.trace('setting date to display');

			-- change the date from canonical to user

			l_internal_value  := p_value(iv_cnt);
			l_display_value   := NULL;

			hr_utility.trace('internal format BEFORE is '||l_internal_value);
			hr_utility.trace('display  format BEFORE is '||l_display_value);

		      hr_chkfmt.changeformat (
		         l_internal_value,         /* the value to be formatted (out - display) */
		         l_display_value,          /* the formatted value on output (out - canonical) */
		         'D',
		         NULL );

			hr_utility.trace('internal format BEFORE is '||l_internal_value);
			hr_utility.trace('display  format BEFORE is '||l_display_value);

	                p_input_value(l_index_input_value).value := l_display_value;

                ELSIF g_iv_mapping_ct(l_ipv_count).iv_uom = 'N'
                THEN
                        p_input_value(l_index_input_value).value := FND_NUMBER.CANONICAL_TO_NUMBER(p_value(iv_cnt));
		ELSE

                        hr_utility.trace('not setting date to display');

	                p_input_value(l_index_input_value).value := p_value(iv_cnt);

		END IF;


hr_utility.trace('iv name is '||g_iv_mapping_ct(l_ipv_count).iv_name);
hr_utility.trace('iv id   is '||to_char(g_iv_mapping_ct(l_ipv_count).iv_id));
hr_utility.trace('Field Name is '||p_field_name(iv_cnt));
hr_utility.trace('Value is '||p_value(iv_cnt));
hr_utility.trace('Value passed in is '||p_input_value(l_index_input_value).value);

                p_input_value(l_index_input_value).name  := g_iv_mapping_ct(l_ipv_count).iv_name;
                p_input_value(l_index_input_value).id    := g_iv_mapping_ct(l_ipv_count).iv_id;
                p_field_name(iv_cnt) := NULL;
                p_value(iv_cnt) := NULL;

                l_index_input_value := l_index_input_value + 1;

              end if;

              exit when (l_ipv_count = g_iv_map_ct(p_element_type_id).stop_index);

              l_ipv_count := g_iv_mapping_ct.next(l_ipv_count);
            END LOOP;

          end if;

       end if;

       --
       ELSIF upper(p_field_name(iv_cnt)) like 'COSTSEGMENT%' THEN
          l_seg := to_number(replace(
                      upper(p_field_name(iv_cnt)), 'COSTSEGMENT'));
          IF l_seg <= 30 THEN
             p_segment(l_seg) := p_value(iv_cnt);
             p_field_name(iv_cnt) := NULL;
             p_value(iv_cnt) := NULL;
       END IF;
   END IF;
END LOOP;
END IF;

-- before we return the input value structure we must insure that
-- all ids are NULL where the corresponding value is also NULL
-- WWB 3403628

FOR iv in 1 .. 15
LOOP

    IF ( p_input_value(iv).value IS NULL )
    THEN

	hr_utility.trace('setting NAME to null '||p_input_value(iv).name);
	hr_utility.trace('id is '||p_input_value(iv).id);

         p_input_value(iv).id := NULL;

    END IF;

END LOOP;

hr_utility.set_location(c_proc, 90);
--
END get_input_values;

--------------------------- get_input_values over-------------------------

PROCEDURE get_full_name(p_person_id in number,
                        p_effective_date in date,
                        p_bb_id IN NUMBER,
                        p_bb_ovn IN NUMBER,
                        p_messages IN OUT NOCOPY hxc_self_service_time_deposit.message_table,
                        p_full_name OUT NOCOPY varchar2)
IS
l_cached boolean := false;
l_iter BINARY_INTEGER;
-- e_continue                        exception;

cursor c_get_full_name(p_person_id number,p_effective_date date) is
SELECT full_name,effective_start_date,effective_end_date
FROM per_people_f
WHERE person_id = p_person_id
  AND p_effective_date BETWEEN effective_start_date AND effective_end_date;


BEGIN
		l_iter := g_full_name_ct.first;
		WHILE l_iter is not null LOOP
			if ((g_full_name_ct(l_iter).person_id = p_person_id) and
				(p_effective_date between g_full_name_ct(l_iter).effective_start_date
									 and g_full_name_ct(l_iter).effective_end_date  )
				)then
				l_cached := true;
				p_full_name := g_full_name_ct(l_iter).full_name;
				exit;
			end if;
			l_iter := g_full_name_ct.next(l_iter);
		END LOOP;


		if (not l_cached)
		then

			l_iter := nvl(g_full_name_ct.last,0)+1;


			OPEN c_get_full_name(p_person_id,p_effective_date);
			FETCH c_get_full_name into g_full_name_ct(l_iter).full_name,
									 g_full_name_ct(l_iter).effective_start_date,
									 g_full_name_ct(l_iter).effective_end_date;

			IF c_get_full_name%NOTFOUND then

						hxc_time_entry_rules_utils_pkg.add_error_to_table(
								p_message_table          => p_messages
							   ,p_message_name           => 'HR_52365_PTU_NO_PERSON_EXISTS'
							   ,p_message_token          => NULL
							   ,p_message_level          => 'ERROR'
							   ,p_message_field          => NULL
							   ,p_application_short_name => 'PER'
							   ,p_timecard_bb_id         => p_bb_id
							   ,p_time_attribute_id      => NULL
							   ,p_timecard_bb_ovn         => p_bb_ovn
							   ,p_time_attribute_ovn      => NULL);

						raise e_continue;
						--
			END IF;

			g_full_name_ct(l_iter).person_id := p_person_id;
			p_full_name := g_full_name_ct(l_iter).full_name;

			CLOSE c_get_full_name;

		end if;

END get_full_name;


------------------------------------------------------
PROCEDURE get_assignment(p_person_id IN NUMBER,
                         p_effective_date IN DATE,
                         p_full_name IN VARCHAR2,
                         p_bb_id IN NUMBER,
                         p_bb_ovn IN NUMBER,
                         p_messages IN OUT NOCOPY hxc_self_service_time_deposit.message_table,
                         p_assignment_id OUT NOCOPY NUMBER,
                         p_business_group_id OUT NOCOPY NUMBER,
                         p_cost_allocation_structure OUT NOCOPY VARCHAR2)
IS

-- e_continue                        exception;

CURSOR c_assignment(p_person_id number,p_effective_date date) is
SELECT paf.assignment_id,
       paf.business_group_id,
       fnd_number.canonical_to_number (bsg.cost_allocation_structure),
       paf.effective_start_date,
       paf.effective_end_date
 FROM per_all_assignments_f paf, per_business_groups bsg
 WHERE paf.person_id = p_person_id
   AND p_effective_date BETWEEN paf.effective_start_date AND paf.effective_end_date
   AND paf.assignment_type = 'E'
   AND paf.primary_flag = 'Y'
   AND bsg.enabled_flag = 'Y'
   AND paf.business_group_id = bsg.business_group_id;


BEGIN
		--check the cached value
		if ((not g_asg_ct.exists(p_person_id)) or
			(p_effective_date not between g_asg_ct(p_person_id).effective_start_date
									  and g_asg_ct(p_person_id).effective_end_date)
		   )
		then

			--get the assignment id

			OPEN c_assignment(p_person_id,p_effective_date);
			FETCH c_assignment into p_assignment_id,p_business_group_id,p_cost_allocation_structure,
				  g_asg_ct(p_person_id).effective_start_date, g_asg_ct(p_person_id).effective_end_date;

			IF c_assignment%NOTFOUND
			THEN

				  hxc_time_entry_rules_utils_pkg.add_error_to_table(
						  p_message_table          => p_messages
						 ,p_message_name           => 'HXC_HRPAY_RET_NO_ASSIGN'
						 ,p_message_token          => 'PERSON_NAME&'||p_full_name
						 ,p_message_level          => 'ERROR'
						 ,p_message_field          => NULL
						 ,p_application_short_name => 'HXC'
						 ,p_timecard_bb_id         => p_bb_id
						 ,p_time_attribute_id      => NULL
						 ,p_timecard_bb_ovn        => p_bb_ovn
						 ,p_time_attribute_ovn     => NULL);
				  --
				  raise e_continue;

			END IF;

			CLOSE c_assignment;

			--let us get the data from g_full_name_ct table

			g_asg_ct(p_person_id).assignment_id := p_assignment_id;
			g_asg_ct(p_person_id).business_group_id := p_business_group_id;
			g_asg_ct(p_person_id).cost_allocation_structure := p_cost_allocation_structure;

		else

			p_assignment_id := g_asg_ct(p_person_id).assignment_id ;
			p_business_group_id:= g_asg_ct(p_person_id).business_group_id;
			p_cost_allocation_structure := g_asg_ct(p_person_id).cost_allocation_structure;

		end if;


END get_assignment;
------------------------------------------------------
PROCEDURE get_element_name(p_element_type_id IN NUMBER,
                           p_effective_date IN DATE,
                           p_time_attribute_id IN NUMBER,
                           p_bb_id IN NUMBER,
                           p_bb_ovn IN NUMBER,
                           p_messages IN OUT NOCOPY hxc_self_service_time_deposit.message_table,
                           p_element_name OUT NOCOPY VARCHAR2)

IS

-- e_continue                        exception;

cursor c_get_element_name(p_element_type_id number,
                          p_user_language varchar2,
                          p_effective_date date) is
select petl.element_name,
	   pet.effective_start_date,
	   pet.effective_end_date
from pay_element_types_f pet,
       pay_element_types_f_tl petl
 where pet.element_type_id = p_element_type_id
   and petl.element_type_id = pet.element_type_id
   and p_user_language = petl.language
   and p_effective_date between pet.effective_start_date
                            and pet.effective_end_date;

CURSOR c_chk_otc_information_type ( p_element_type_id NUMBER ) IS
select  'Y'
from fnd_descr_flex_column_usages c
where c.application_id = 809
and c.descriptive_flexfield_name = 'OTC Information Types'
and c.descriptive_flex_context_code = 'ELEMENT - '||p_element_type_id;

l_dummy VARCHAR2(1);


BEGIN

			if ((not g_ele_type_ct.exists(p_element_type_id)) or
				(p_effective_date not between g_ele_type_ct(p_element_type_id).effective_start_date and
											  g_ele_type_ct(p_element_type_id).effective_end_date)
			   ) then

				OPEN c_get_element_name(p_element_type_id,user_language,p_effective_date);
				FETCH c_get_element_name INTO p_element_name,
											  g_ele_type_ct(p_element_type_id).effective_start_date,
											  g_ele_type_ct(p_element_type_id).effective_end_date;

				IF c_get_element_name%NOTFOUND then

								  hxc_time_entry_rules_utils_pkg.add_error_to_table(
								  p_message_table          => p_messages
								 ,p_message_name           => 'HXC_HRPAY_RET_NO_ELE_NAME'
								 ,p_message_token  => 'ELE_TYPE_ID&'||to_char(p_element_type_id)
								 ,p_message_level          => 'ERROR'
								 ,p_message_field          => NULL
								 ,p_application_short_name => 'HXC'
								 ,p_timecard_bb_id         => p_bb_id
								 ,p_time_attribute_id      => p_time_attribute_id
								 ,p_timecard_bb_ovn         => p_bb_ovn
								 ,p_time_attribute_ovn      => NULL);
								  --
								  raise e_continue;                --Bug#3004714
				END IF;
				g_ele_type_ct(p_element_type_id).element_name := p_element_name;
				CLOSE c_get_element_name;

				-- now check tha that generate flexfield and mapping process has been
				-- run for this element

				OPEN  c_chk_otc_information_type ( p_element_type_id );
				FETCH c_chk_otc_information_type INTO l_dummy;

				IF c_chk_otc_information_type%FOUND
				THEN

					p_element_name := g_ele_type_ct(p_element_type_id).element_name;

				ELSE

                                           -- clear out global element table for this element since it failed
                                           -- the validation

                                           g_ele_type_ct.DELETE(p_element_type_id);

					   hxc_time_entry_rules_utils_pkg.add_error_to_table(
					              p_message_table          => p_messages
					             ,p_message_name           => 'HXC_GENERATE_FLEXFIELD_MAPPING'
					             ,p_message_token          => 'ELEMENT_NAME&'||p_element_name
					             ,p_message_level          => 'ERROR'
					             ,p_message_field          => NULL
						     ,p_application_short_name => 'HXC'
						     ,p_timecard_bb_id         => p_bb_id
						     ,p_time_attribute_id      => p_time_attribute_id
						     ,p_timecard_bb_ovn        => p_bb_ovn
					             ,p_time_attribute_ovn     => NULL);

				END IF;

				CLOSE c_chk_otc_information_type;


			else
				p_element_name := g_ele_type_ct(p_element_type_id).element_name;

			end if;



END get_element_name;

-------------------------------------------------------

PROCEDURE get_link(p_assignment_id in number ,
                        p_element_type_id in number,
                        p_effective_date in date,
                        p_element_link_id OUT NOCOPY number)

IS
l_cached BOOLEAN := false;
l_iter BINARY_INTEGER;
-- e_continue                        exception;
BEGIN

		l_iter := g_link_ct.first;

		 -- get the start and end index and search through g_link_ct to find a matching record
		WHILE l_iter is not null
		LOOP
			if ((p_assignment_id = g_link_ct(l_iter).assignment_id) and
			   (p_element_type_id = g_link_ct(l_iter).element_type_id) and
			   (p_effective_date = g_link_ct(l_iter).effective_date))
			then
			   l_cached := true;
			   p_element_link_id := g_link_ct(l_iter).element_link_id;
			   exit;
			end if;

		 l_iter := g_link_ct.next(l_iter);

		END LOOP;


		if (not l_cached) then
				 p_element_link_id := hr_entry_api.get_link(p_assignment_id,
															p_element_type_id,
															p_effective_date);

				-- we have queried to get the link. let us cache it

				l_iter := nvl(g_link_ct.last,0)+1;
				g_link_ct(l_iter).assignment_id := p_assignment_id;
				g_link_ct(l_iter).element_type_id := p_element_type_id;
				g_link_ct(l_iter).effective_date := p_effective_date;
				g_link_ct(l_iter).element_link_id := p_element_link_id;


		end if;


END get_link;


--
--------------------------- pay_retrieval_process ---------------------------
--
FUNCTION pay_retrieval_process RETURN VARCHAR2 IS

l_retrieval_process HXC_TIME_RECIPIENTS.APPLICATION_RETRIEVAL_FUNCTION%TYPE;

BEGIN

  l_retrieval_process := 'BEE Retrieval Process';

  RETURN l_retrieval_process;

END pay_retrieval_process;

--
--------------------------- hr_retrieval_process ---------------------------
--
FUNCTION hr_retrieval_process RETURN VARCHAR2 IS

l_retrieval_process HXC_TIME_RECIPIENTS.APPLICATION_RETRIEVAL_FUNCTION%TYPE;

BEGIN

  l_retrieval_process := 'HR Retrieval Process';

  RETURN l_retrieval_process;

END hr_retrieval_process;


--
--------------------------- pay_update_process ----------------------------
--

PROCEDURE pay_update_process
            (p_operation            IN     VARCHAR2) IS

l_blocks     hxc_self_service_time_deposit.timecard_info;
l_attributes hxc_self_service_time_deposit.app_attributes_info;
l_messages   hxc_self_service_time_deposit.message_table;
l_proc       VARCHAR2(100) := 'pay_hxc_deposit_interface.PAY_UPDATE_PROCESS';

BEGIN
--
hr_utility.set_location(l_proc, 10);
--
hr_utility.set_location(l_proc, 20);
--
hxc_self_service_time_deposit.get_app_hook_params(
                p_building_blocks => l_blocks,
                p_app_attributes => l_attributes,
                p_messages => l_messages);
--
hr_utility.set_location(l_proc, 40);
--

-- reset all the programatically updateble comps to null first

--hxc_layout_utils_pkg.reset_non_updatable_comps ( p_attributes => l_attributes );

pay_update_timecard
(p_attributes   => l_attributes,
 p_blocks       => l_blocks );

hxc_self_service_time_deposit.set_app_hook_params(
                p_building_blocks => l_blocks,
                p_app_attributes => l_attributes,
                p_messages => l_messages);

END pay_update_process;

--
--------------------------- pay_update_timecard ----------------------------
--
PROCEDURE pay_update_timecard
           (p_attributes     IN OUT NOCOPY hxc_self_service_time_deposit.app_attributes_info,
            p_blocks         in    hxc_self_service_time_deposit.timecard_info
	   )
is

l_index  NUMBER;
l_index_gaz  NUMBER;

l_effective_date DATE;
l_day  NUMBER;
l_parent_bb_id NUMBER;
l_resource_id  NUMBER;
l_start_time  DATE;
l_canonical_date VARCHAR2(25);

----------------------------------------------------------------------
---local procedure :set_pto_element_date
---------------------------------------------------------------------
Procedure set_pto_element_date
           (p_attributes     in  out NOCOPY hxc_self_service_time_deposit.app_attributes_info,
	    p_tbb_id         in  NUMBER,
            p_resource_id    in  NUMBER,
	    p_effective_date in  date,
            p_canonical_date in  varchar2
           ) is

l_index              NUMBER;
l_attribute          HXC_ATTRIBUTE_TYPE;
l_old_attribute      HXC_ATTRIBUTE_TYPE;



l_dd_mon_yyyy_date VARCHAR2(11);

l_test boolean;

l_att_num_changed BOOLEAN := FALSE;
l_old_att_num       NUMBER := -1;
l_attribute_num     NUMBER;

l_bg_id             NUMBER;
l_accrual_plan_id   NUMBER;
l_element_type_id   NUMBER;
l_plan_exists       BOOLEAN;
l_input_value_id    NUMBER;
l_iv_name           VARCHAR2(240);

l_found BOOLEAN;
L_ACCRUAL_PLAN_EXISTS VARCHAR2(3);

CURSOR c_assignments(p_resource_id In Number,
		     p_evaluation_date In Date) IS
    SELECT pas.BUSINESS_GROUP_ID
         , pas.effective_start_date
         , pas.effective_end_date
    FROM PER_ALL_ASSIGNMENTS_F pas,
         per_assignment_status_types typ
    WHERE pas.PERSON_ID = p_resource_id
       AND pas.ASSIGNMENT_TYPE in ('E','C')
       AND pas.PRIMARY_FLAG = 'Y'
       AND pas.ASSIGNMENT_STATUS_TYPE_ID = typ.ASSIGNMENT_STATUS_TYPE_ID
       AND typ.PER_SYSTEM_STATUS IN ( 'ACTIVE_ASSIGN','ACTIVE_CWK')
       AND p_evaluation_date BETWEEN EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE;

cursor c_check_pto (p_bg_id NUMBER,p_element_type_id NUMBER,p_effective_date IN DATE)
IS
SELECT pnt.DATE_INPUT_VALUE_id DATE_INPUT_VALUE_id,
       pnt.accrual_plan_id accrual_plan_id
FROM PAY_NET_CALCULATION_RULES pnt,PAY_INPUT_VALUES_F piv
WHERE  piv.business_group_id=p_bg_id
and pnt.DATE_INPUT_VALUE_id=piv.INPUT_VALUE_ID
and piv.element_type_ID=p_element_type_id
AND p_effective_date between piv.effective_start_date and piv.effective_end_date
and piv.business_group_id=pnt.business_group_id;

FUNCTION  get_attribute_from_iv
	   ( p_element_type_id  NUMBER,
	     p_effective_date   DATE,
	     p_iv_id		NUMBER
	   ) RETURN VARCHAR2 IS

cursor c_ipvs(p_element_type_id in number, p_effective_date in date) is
  select display_sequence, name, input_value_id, mandatory_flag
    from pay_input_values_f
   where element_type_id = p_element_type_id
     and p_effective_date between effective_start_date and effective_end_date
order by display_sequence, name;

CURSOR c_get_atttribute_num( p_element_type_id NUMBER,p_iv_seq VARCHAR2)
is
select  'Y'
from fnd_descr_flex_column_usages c, hxc_mapping_components mpc
where c.application_id = 809
and c.descriptive_flexfield_name = 'OTC Information Types'
and c.descriptive_flex_context_code = 'ELEMENT - '||p_element_type_id
and c.application_column_name = mpc.segment
 and mpc.field_name = 'InputValue'||p_iv_seq;

l_segment_count NUMBER:=0;
l_segment_choice NUMBER:=0;

flex_entry_found  VARCHAR2(3);

BEGIN

  l_segment_count := 0;

  FOR ipv_rec in c_ipvs(p_element_type_id, p_effective_date) LOOP
    l_segment_count := l_segment_count +1;
    if (ipv_rec.mandatory_flag <> 'X') then
      if((ipv_rec.display_sequence > 11) AND (ipv_rec.display_sequence < 16)) then
       l_segment_choice := ipv_rec.display_sequence;
      else
	l_segment_choice := l_segment_count;
      end if;

      IF ipv_rec.input_value_id=p_iv_id THEN

        -- confirm that the entry for this Input Vaue exists ion OTL Information DFF.
	--Andy We can remove this if you thik it is not required.

	 flex_entry_found :=NULL;
	 OPEN  c_get_atttribute_num(p_element_type_id,l_segment_choice);
	 FETCH c_get_atttribute_num into flex_entry_found;
	 CLOSE c_get_atttribute_num;

	  IF flex_entry_found ='Y' then
	   return l_segment_choice;
	  END IF;

      END IF;
    END IF; -- is this a user enterable segment
  end LOOP; -- Input value loop
   return null;
END;

FUNCTION get_assignment_info ( p_resource_id  NUMBER
                              , p_evaluation_date DATE ) RETURN NUMBER IS

BEGIN

hr_utility.trace('In get ass info : '||to_char(p_resource_id)||' : '||to_char(p_evaluation_date));

IF ( g_pto_assignment_info.EXISTS ( p_resource_id ) )
THEN

	IF (   ( p_evaluation_date <= g_pto_assignment_info( p_resource_id ).effective_end_date )
           AND ( p_evaluation_date >= g_pto_assignment_info( p_resource_id ).effective_start_date ) )
	THEN

		hr_utility.trace('Using Cache : bg id is '||to_char(g_pto_assignment_info(p_Resource_id).bg_id));

		RETURN g_pto_assignment_info(p_Resource_id).bg_id;

	ELSE

		hr_utility.trace('date changed - clearing cahce');

		-- new assignment record bg id could potentially change invalidating
		-- assignment cache and pto element cache

		g_pto_assignment_info.DELETE;
		g_pto_element.DELETE;

	END IF;

END IF;

hr_utility.trace('not using cache');

open c_assignments(p_resource_id,p_evaluation_date);
fetch c_assignments into g_pto_assignment_info(p_Resource_id).bg_id
                       , g_pto_assignment_info(p_resource_id).effective_start_date
                       , g_pto_assignment_info(p_resource_id).effective_end_date;
close c_assignments;
/*
hr_utility.trace('cache is ');
hr_utility.trace('bg id is '||to_char(g_pto_assignment_info(p_Resource_id).bg_id));
hr_utility.trace('start date is '||to_char(g_pto_assignment_info(p_Resource_id).effective_start_Date));
hr_utility.trace('end date is '||to_char(g_pto_assignment_info(p_Resource_id).effective_end_Date));
*/

RETURN g_pto_assignment_info(p_Resource_id).bg_id;


EXCEPTION
  WHEN OTHERS THEN

      return null;

END get_assignment_info;


PROCEDURE create_pto_iv_row ( p_attributes in  out NOCOPY hxc_self_service_time_deposit.app_attributes_info
                             ,p_current_att_index NUMBER
                             ,p_att_num NUMBER
                             ,p_iv_id   NUMBER ) IS

l_next_ind   PLS_INTEGER := p_attributes.LAST+1;
l_new_iv_row hxc_self_service_time_deposit.app_attributes;

BEGIN

hr_utility.trace('In create pto iv row');
hr_utility.trace('next ind is '||to_char(l_next_ind));

-- use current Dummy Element Context row as starting point

l_new_iv_row := p_attributes(p_current_att_index);

l_new_iv_row.attribute_name  := 'InputValue'||p_att_num;
l_new_iv_row.segment         := 'ATTRIBUTE' ||p_att_num;
l_new_iv_row.attribute_value := p_canonical_date;
l_new_iv_row.updated         := 'N';
l_new_iv_row.changed         := 'N';

p_attributes(l_next_ind) := l_new_iv_row;

pay_hxc_deposit_interface.g_canonical_iv_id_tab(p_iv_id) := 'Y';

hr_utility.trace('att name is '||l_new_iv_row.attribute_name);
hr_utility.trace('att value is '||l_new_iv_row.attribute_value);
hr_utility.trace('iv id for global is '||to_char(p_iv_id));


END create_pto_iv_row;

Begin -- set_pto_element_date

--get the assignment_id

l_bg_id := get_assignment_info ( p_resource_id, p_effective_date );

--Now loop through the attributes table and get the element type id from
--ELEMENT -<element type id> record

l_index := p_attributes.first;

l_plan_exists :=FALSE;
l_found :=FALSE;

LOOP
EXIT WHEN NOT p_attributes.exists(l_index);

       IF  p_attributes(l_index).attribute_name ='Dummy Element Context'  and
	   substr(p_attributes(l_index).attribute_value, 1, 10) = 'ELEMENT - ' and  --Bug 4560586
	   p_attributes(l_index).building_block_id =p_tbb_id
       THEN

	   l_element_type_id := to_number(replace(p_attributes(l_index).attribute_value,'ELEMENT - '));

	     hr_utility.trace('l_element_type_id'||l_element_type_id);

		IF ( g_pto_element.EXISTS( l_element_type_id ) )
		THEN

			hr_utility.trace('Element exists in cache');

			IF  ( g_pto_element(l_element_type_id).is_pto = 'Y' )
			THEN

				hr_utility.trace('Element is PTO');

				l_attribute_num  := g_pto_element(l_element_type_id).att_num;
                                l_input_value_id := g_pto_element(l_element_type_id).iv_id;

				create_pto_iv_row ( p_attributes, l_index, l_attribute_num,
                                                    l_input_value_id );

			END IF;

		ELSE

			hr_utility.trace('Element not in Cache');

		     l_input_value_id :=NULL;
		     l_accrual_plan_id :=NULL;

			-- get all the accrual plan which have this element in net calculation rule

			-- ( pretty sure we do not need to loop here since we should never have
			--   the same element on different accrual plans with more than one
			--   date iv. If we do then we will simply not maintain the cache )

			g_pto_element( l_element_type_id ).is_pto := 'N';

	             OPEN c_check_pto(l_bg_id,l_element_type_id,p_effective_date);
		     LOOP
		      FETCH c_check_pto into l_input_value_id,l_accrual_plan_id;
		      EXIT WHEN c_check_pto%NOTFOUND;

			hr_utility.trace('ELement is a PTO element');

			g_pto_element( l_element_type_id ).is_pto := 'Y';

			   hr_utility.trace('l_input_value_id'||l_input_value_id);

				-- if accrual plan is valid ..then set the value in correct attribute

	 		     l_attribute_num :=get_attribute_from_iv
			                     (p_element_type_id => l_element_type_id,
					      p_effective_date  => p_effective_date,
					      p_iv_id		=> l_input_value_id);

			IF (     ( l_old_att_num <> l_attribute_num )
                             AND ( l_old_att_num <> -1 ) )
			THEN
				l_att_num_changed := TRUE;
			ELSE
				l_old_att_num := l_attribute_num;
			END IF;


			hr_utility.trace('attribute num is '||l_attribute_num);
			hr_utility.trace('p bb id is '||to_char(p_tbb_id));

				create_pto_iv_row ( p_attributes, l_index, l_attribute_num,
                                                    l_input_value_id );


		      END LOOP;
		      CLOSE  c_check_pto;

			IF ( NOT l_att_num_changed AND g_pto_element( l_element_type_id ).is_pto = 'Y')
			THEN

				-- maintain cache

				g_pto_element(l_element_type_id).is_pto  := 'Y';
				g_pto_element(l_element_type_id).att_num := l_attribute_num;
				g_pto_element(l_element_type_id).iv_id   := l_input_value_id;

			ELSIF ( l_att_num_changed AND g_pto_element( l_element_type_id ).is_pto = 'Y' )
			THEN

				g_pto_element.DELETE( l_element_type_id );


			END IF; -- NOT ll_att_num_changed

                END IF; -- IF ( g_pto_element.EXISTS( l_element_type_id ) )

      END IF; -- Dummy Element Context

 l_index := p_attributes.next(l_index);

END LOOP;

End set_pto_element_date;



BEGIN --pay_update_timecard

l_index  :=p_blocks.first;
LOOP EXIT WHEN NOT p_blocks.exists(l_index);

-- NOTE: This only loops round non deleted blocks
-- If at a later date more than setting the PTO date is done
-- from within this loop the logic may have to change.
-- Meanwhile, there is no need to set the PTO date for deleted
-- entries since the date does not change.

IF ( ( p_blocks(l_index).SCOPE='DETAIL' ) AND
     ( p_blocks(l_index).date_to = hr_general.end_of_time ) )
THEN

  l_start_time     := TRUNC(p_blocks(l_index).start_time);
  l_canonical_date := fnd_date.date_to_canonical(l_start_time);
  l_parent_bb_id := p_blocks(l_index).PARENT_BUILDING_BLOCK_ID;
  l_resource_id  := p_blocks(l_index).resource_id;

      IF p_blocks(l_index).TYPE = 'MEASURE' THEN
 	  l_day := p_blocks.first;
	   LOOP	EXIT WHEN (NOT p_blocks.exists(l_day));
		IF (p_blocks(l_day).TIME_BUILDING_BLOCK_ID = l_parent_bb_id) AND
				   (p_blocks(l_day).SCOPE = 'DAY') THEN
				   --
                                   l_start_time     := p_blocks(l_day).start_time;
                                   l_canonical_date := fnd_date.date_to_canonical(p_blocks(l_day).start_time);

				   EXIT;
		END IF;
   	  l_day := p_blocks.next(l_day);
	 END LOOP;
     END IF;

     l_effective_date :=trunc(l_start_time);

     if(l_canonical_date is not null) then
        set_pto_element_date
           (p_attributes     => p_attributes,
            p_tbb_id         => p_blocks(l_index).time_building_block_id,
            p_resource_id    => l_resource_id,
            p_effective_date => l_effective_date,
            p_canonical_date => l_canonical_date
            );
     end if;

 END IF;

l_index:=p_blocks.next(l_index);

END LOOP;

END pay_update_timecard;
--
--------------------------- pay_validate_process ----------------------------
--
PROCEDURE pay_validate_process
            (p_operation            IN     VARCHAR2) IS

l_blocks     hxc_self_service_time_deposit.timecard_info;
l_attributes hxc_self_service_time_deposit.app_attributes_info;
l_messages   hxc_self_service_time_deposit.message_table;
l_proc       VARCHAR2(100) := 'pay_hxc_deposit_interface.PAY_VALIDATE_PROCESS';

BEGIN
--
hr_utility.set_location(l_proc, 10);
--
hr_utility.set_location(l_proc, 20);
--
hxc_self_service_time_deposit.get_app_hook_params(
                p_building_blocks => l_blocks,
                p_app_attributes => l_attributes,
                p_messages => l_messages);
--
hr_utility.set_location(l_proc, 40);
--
pay_validate_timecard
  (p_operation            => p_operation
  ,p_time_building_blocks => l_blocks
  ,p_time_attributes      => l_attributes
  ,p_messages             => l_messages
  );

hxc_self_service_time_deposit.set_app_hook_params(
                p_building_blocks => l_blocks,
                p_app_attributes => l_attributes,
                p_messages => l_messages);

END pay_validate_process;
--
------------------------- pay_validate_timecard ------------------------------
--
PROCEDURE pay_validate_timecard
   (p_operation        IN     VARCHAR2
   ,p_time_building_blocks IN OUT NOCOPY hxc_self_service_time_deposit.timecard_info
   ,p_time_attributes  IN OUT NOCOPY hxc_self_service_time_deposit.app_attributes_info
   ,p_messages         IN OUT NOCOPY hxc_self_service_time_deposit.message_table) IS
--
cursor get_debug is
   SELECT 'X'
   FROM hxc_debug
   WHERE process = 'pay_validate_timecard'
   AND   trunc(debug_date) <= sysdate;

--payroll perf fixes

l_full_name VARCHAR2(240);
lcode HR_LOOKUPS.lookup_code%TYPE;

--local tables for caching

--
-- local tables
--
l_field_name                      t_field_name;
l_value                           t_value;
l_segment                         t_segment;
l_input_value                     t_input_value;
l_attribute_ids                   t_attribute;
l_time_attribute_id               NUMBER(15);
--
l_bb_id                           NUMBER(15);
l_bb_ovn                          NUMBER(15);
l_type                            VARCHAR2(30);

--Changed by smummini for bug # 2791955
--l_measure                         NUMBER(15);
l_measure	                  hxc_time_building_blocks.measure%TYPE;

l_start_time                      DATE;
l_stop_time                       DATE;
l_parent_bb_id                    NUMBER(15);
l_scope                           VARCHAR2(30);
l_resource_id                     NUMBER(15);
l_resource_type                   VARCHAR2(30);
l_comment_text                    VARCHAR2(2000);
l_date_to			  DATE;
--
l_person_id                       NUMBER(9);
l_effective_date                  DATE;
l_assignment_id                   NUMBER(9);
l_business_group_id               NUMBER(9);
l_element_type_id                 NUMBER(9);
l_element_link_id                 NUMBER(9);
l_element_name                    VARCHAR2(80);
l_cost_allocation_structure       VARCHAR2(150);
l_cost_allocation_keyflex_id      NUMBER(9);
--
l_effective_start_date            DATE;
l_effective_end_date              DATE;
l_element_entry_id                NUMBER(9);
l_object_version_number           NUMBER(9);
l_create_warning                  BOOLEAN;
l_cnt            NUMBER(15);
l_day		 NUMBER(15);
l_cnt_att	 NUMBER(15);
--
l_cost                            VARCHAR2(1) := 'N';
l_valid                           VARCHAR2(1) := 'N';
l_att                             NUMBER := 0;
e_error                           exception;
-- e_continue                        exception;
l_debug                 VARCHAR2(1);
--
l_proc      VARCHAR2(100):= 'pay_hxc_deposit_interface.PAY_VALIDATE_TIMECARD';

l_name_cached	 BOOLEAN;
l_link_cached BOOLEAN;
l_iter BINARY_INTEGER;

l_index_gaz pls_integer;

--
-- MAIN  --begin pay_validate_timecard
--
BEGIN
--
/*

Commented out for enabling validation on save
preference - bug 3480070, no longer need
to issue this return in this case, since
we can remove the validation by setting
the preference to no.

IF p_operation <> 'SUBMIT' THEN
   return;
END IF;

*/
--
open get_debug;
fetch get_debug into l_debug;
IF get_debug%FOUND THEN
   hr_utility.trace_on(null, 'PAYVAL');
END IF;
close get_debug;

--get user language
user_language := userenv('LANG');


--
-- Loop through all the building blocks and validate the details.
--
l_cnt := p_time_building_blocks.first;
LOOP
 EXIT WHEN
   (NOT p_time_building_blocks.exists(l_cnt));

   --
   hr_utility.set_location(l_proc, 10);
   hr_utility.trace('***********  NEW TIME BUILDING BLOCK  ************');
   --
   l_bb_id := p_time_building_blocks(l_cnt).TIME_BUILDING_BLOCK_ID;
   l_bb_ovn := p_time_building_blocks(l_cnt).OBJECT_VERSION_NUMBER;
   l_type := p_time_building_blocks(l_cnt).TYPE;
   l_measure := p_time_building_blocks(l_cnt).MEASURE;
   l_start_time := p_time_building_blocks(l_cnt).START_TIME;
   l_stop_time := p_time_building_blocks(l_cnt).STOP_TIME;
   l_parent_bb_id := p_time_building_blocks(l_cnt).PARENT_BUILDING_BLOCK_ID;
   l_scope := p_time_building_blocks(l_cnt).SCOPE;
   l_resource_id := p_time_building_blocks(l_cnt).RESOURCE_ID;
   l_resource_type := p_time_building_blocks(l_cnt).RESOURCE_TYPE;
   l_comment_text := p_time_building_blocks(l_cnt).COMMENT_TEXT;
   l_date_to := p_time_building_blocks(l_cnt).DATE_TO;
   --
   hr_utility.trace('Time BB ID is : ' || to_char(l_bb_id));
   hr_utility.trace('Type is : ' || l_type);
   hr_utility.trace('Measure is : ' || to_char(l_measure));
   hr_utility.trace('l_start_time is ' ||
                     to_char(l_start_time, 'DD-MON-YYYY HH:MI:SS'));
   hr_utility.trace('l_stop_time is ' ||
                     to_char(l_stop_time, 'DD-MON-YYYY HH:MI:SS'));
   hr_utility.trace('l_scope is '||l_scope);
   hr_utility.trace('l_resource_id is '||to_char(l_resource_id));
   hr_utility.trace('l_resource_type is '||l_resource_type);
   --
   hr_utility.trace('UOM is : ' ||
                     p_time_building_blocks(l_cnt).UNIT_OF_MEASURE);
   hr_utility.trace('Parent BB ID is : ' ||
            to_char(p_time_building_blocks(l_cnt).PARENT_BUILDING_BLOCK_ID));
   hr_utility.trace('PARENT_IS_NEW is : ' ||
                    p_time_building_blocks(l_cnt).PARENT_IS_NEW);
  -- hr_utility.trace('OVN is : ' ||
  --            to_char(p_time_building_blocks(l_cnt).OBJECT_VERSION_NUMBER));
   hr_utility.trace('APPROVAL_STATUS is : ' ||
                    p_time_building_blocks(l_cnt).APPROVAL_STATUS);
 --  hr_utility.trace('APPROVAL_STYLE_ID is : ' ||
 --             to_char(p_time_building_blocks(l_cnt).APPROVAL_STYLE_ID));
  -- hr_utility.trace('DATE_FROM is : ' ||
   --           to_char(p_time_building_blocks(l_cnt).DATE_FROM, 'DD-MON-YYYY'));
  -- hr_utility.trace('DATE_TO is : ' ||
  --            to_char(p_time_building_blocks(l_cnt).DATE_TO, 'DD-MON-YYYY'));
   hr_utility.trace('COMMENT_TEXT is : ' ||
                    p_time_building_blocks(l_cnt).COMMENT_TEXT);
  -- hr_utility.trace('Parent OVN is : ' ||
  --          to_char(p_time_building_blocks(l_cnt).PARENT_BUILDING_BLOCK_OVN));
   hr_utility.trace('NEW is : ' || p_time_building_blocks(l_cnt).NEW);
   --
   hr_utility.set_location(l_proc, 20);
   --

   IF ( (l_type = 'MEASURE' AND  l_measure IS NOT NULL) OR
       (l_type = 'RANGE'   AND l_start_time IS NOT NULL AND
                               l_stop_time  IS NOT NULL)) AND
       (l_date_to = hr_general.end_of_time) THEN
      l_valid := 'Y';
   ELSE
      l_valid := 'N';
   END IF;

   --
   -- Only care about valid DETAIL Blocks.
   --
   IF l_scope = 'DETAIL' AND l_valid = 'Y' THEN
      --
      -- Get the start and stop times from the parent DAY block if DETAIL is
      -- a measure.
      --
      IF l_type = 'MEASURE' THEN
         --
		l_day := p_time_building_blocks.first;
		LOOP
		EXIT WHEN
			(NOT p_time_building_blocks.exists(l_day));
				--
				hr_utility.set_location(l_proc, 30);
				--
				IF (p_time_building_blocks(l_day).TIME_BUILDING_BLOCK_ID =
					l_parent_bb_id) AND
				   (p_time_building_blocks(l_day).SCOPE = 'DAY') THEN
				   --
				   l_start_time := p_time_building_blocks(l_day).START_TIME;
				   l_stop_time  := p_time_building_blocks(l_day).STOP_TIME;
				   --
				   hr_utility.trace('l_start_time is ' ||
									 to_char(l_start_time, 'DD-MON-YYYY HH:MI:SS'));
				   hr_utility.trace('l_stop_time is ' ||
									 to_char(l_stop_time, 'DD-MON-YYYY HH:MI:SS'));
				   --
				   EXIT;
				   --
				END IF;
		 		l_day := p_time_building_blocks.next(l_day);

		 END LOOP;
      END IF;
      --

      BEGIN


      l_person_id := NULL;
      --
      IF l_resource_type = 'PERSON' THEN
         --
         l_person_id := l_resource_id;
         --
         hr_utility.trace('l_person_id is '||to_char(l_person_id));
         --
      END IF;
      --
      l_effective_date := trunc(l_start_time);
      hr_utility.trace('l_effective_date is :'||
                        to_char(l_effective_date, 'DD-MON-YYYY'));
      --
      get_full_name( p_person_id 	  => l_person_id,
	  	     p_effective_date     => l_effective_date,
	  	     p_bb_id 		  => l_bb_id,
	  	     p_bb_ovn 		  => l_bb_ovn,
  		     p_messages 	  => p_messages,
	  	    p_full_name 	  => l_full_name);

      --
      -- Get Assignment ID and Business Group ID.
      --
      l_business_group_id := NULL;
      l_assignment_id     := NULL;
      --

      get_assignment(p_person_id		     =>l_person_id,
	                 p_effective_date 	     =>l_effective_date,
	                 p_full_name                 =>l_full_name,
	                 p_bb_id 		     =>l_bb_id,
	                 p_bb_ovn                    =>l_bb_ovn,
	                 p_messages 		     =>p_messages,
	                 p_assignment_id             => l_assignment_id,
	                 p_business_group_id 	     =>l_business_group_id,
	                 p_cost_allocation_structure =>l_cost_allocation_structure);

      --
      l_field_name.delete;
      l_value.delete;
      l_attribute_ids.delete;
      --
      hr_utility.set_location(l_proc, 50);
      --
      -- Get the attributes for this detail building block.
      --
      IF p_time_attributes.count <> 0 THEN
         --
	   l_att := 0;
         --
	l_cnt_att := p_time_attributes.first;
	LOOP
 	EXIT WHEN
   		(NOT p_time_attributes.exists(l_cnt_att));

       --  FOR l_cnt_att in p_time_attributes.first .. p_time_attributes.last LOOP
            --
            IF l_bb_id = p_time_attributes(l_cnt_att).BUILDING_BLOCK_ID THEN
               --
               hr_utility.trace('------ In Attribute Loop ------');
               --
               l_attribute_ids(l_att) :=
                                 p_time_attributes(l_cnt_att).time_attribute_id;
               --
               l_field_name(l_att) :=
                                   p_time_attributes(l_cnt_att).attribute_name;
               --
               --hr_utility.trace('l_field_name(l_att) is '||l_field_name(l_att));
               --
               l_value(l_att) := p_time_attributes(l_cnt_att).attribute_value;
               --
               --hr_utility.trace('l_value(l_att) is '||l_value(l_att));
               --
               l_att := l_att + 1;
               --
            END IF;
            --
         l_cnt_att := p_time_attributes.next(l_cnt_att);

         END LOOP;
         --
      ELSE
         --
         hr_utility.set_location(l_proc, 100);
         --
         hxc_time_entry_rules_utils_pkg.add_error_to_table(
              p_message_table          => p_messages
             ,p_message_name           => 'HXC_DEP_VAL_NO_ATTR'
             ,p_message_token          => NULL
             ,p_message_level          => 'ERROR'
             ,p_message_field          => NULL
             ,p_application_short_name => 'HXC'
             ,p_timecard_bb_id         => l_bb_id
             ,p_time_attribute_id      => NULL
             ,p_timecard_bb_ovn         => l_bb_ovn
             ,p_time_attribute_ovn      => NULL);
         --
         raise e_continue;                --Bug#3004714

-- Start 2887210, i.e. Comment the raise error
--                     Instead let the errors consolidate in the message table.
--         raise e_error;
--  End  2887210
         --
      END IF; -- p_time_attributes.count is greater than 0
      --
      hr_utility.trace('l_att is ' || to_char(l_att));
      --
      IF l_att > 0 THEN
         --
         hr_utility.set_location(l_proc, 52);
         --
         -- Get the Element Type ID
         --
         l_element_type_id := NULL;
         l_time_attribute_id := NULL;
         --
         IF l_field_name.count <> 0 THEN
            FOR fld_cnt in l_field_name.first .. l_field_name.last LOOP
                IF upper(l_field_name(fld_cnt)) = 'DUMMY ELEMENT CONTEXT' THEN
	                  BEGIN
	                   l_element_type_id := to_number(replace(
	                                      upper(l_value(fld_cnt)), 'ELEMENT - '));
	                   l_time_attribute_id := l_attribute_ids(fld_cnt);
	                  EXCEPTION
	                   WHEN OTHERS THEN
	                      hxc_time_entry_rules_utils_pkg.add_error_to_table(
	                      p_message_table          => p_messages
	                     ,p_message_name           => 'HXC_DEP_VAL_NO_ATTR'
	                     ,p_message_token          => NULL
	                     ,p_message_level          => 'ERROR'
		             ,p_message_field          => NULL
		             ,p_application_short_name => 'HXC'
		             ,p_timecard_bb_id         => l_bb_id
		             ,p_time_attribute_id      => NULL
		             ,p_timecard_bb_ovn         => l_bb_ovn
		             ,p_time_attribute_ovn      => NULL);
		             --
		             raise e_continue;
		           END;
                   EXIT;
                END IF;
            END LOOP;
         END IF;
         --
         hr_utility.trace('l_element_type_id is ' ||
                           to_char(l_element_type_id));
         --
         hr_utility.set_location(l_proc, 53);
         --
         IF l_element_type_id IS NOT NULL THEN
            --
  	    get_element_name(l_element_type_id,
		             l_effective_date ,
		             l_time_attribute_id,
		             l_bb_id,
		             l_bb_ovn,
		             p_messages,
		             l_element_name );


         ELSE
            --
	    hxc_time_entry_rules_utils_pkg.add_error_to_table(
				  p_message_table          => p_messages
				 ,p_message_name           => 'HXC_DEP_VAL_NO_ATTR'
				 ,p_message_token          => NULL
				 ,p_message_level          => 'ERROR'
				 ,p_message_field          => NULL
				 ,p_application_short_name => 'HXC'
				 ,p_timecard_bb_id         => l_bb_id
				 ,p_time_attribute_id      => NULL
				 ,p_timecard_bb_ovn         => l_bb_ovn
				 ,p_time_attribute_ovn      => NULL);
				 --
				 raise e_continue;

            --
         END IF;
         --
         hr_utility.trace('l_element_name is ' || l_element_name);
         --
         hr_utility.set_location(l_proc, 55);
         --
         l_input_value.delete;
         l_segment.delete;
         --
         get_input_values(p_element_name     => l_element_name,
                          p_element_type_id  => l_element_type_id,
                          p_type             => l_type,
                          p_measure          => l_measure,
                          p_start_time       => l_start_time,
                          p_stop_time        => l_stop_time,
                          p_effective_date   => l_effective_date,
                          p_bb_id			 => l_bb_id,
                          p_bb_ovn			 => l_bb_ovn,
                          p_time_attribute_id => l_time_attribute_id,
                          p_messages		 => p_messages,
                          p_input_value      => l_input_value,
                          p_field_name       => l_field_name,
                          p_value            => l_value,
                          p_segment          => l_segment);


         hr_utility.set_location(l_proc, 60);
         --
         -- Get Element Link ID.
         --

		-- we can cache this
		-- check if we have already retrieved this record.

		get_link(p_assignment_id   => l_assignment_id,
		         p_element_type_id => l_element_type_id,
		         p_effective_date  => l_effective_date,
         		 p_element_link_id => l_element_link_id);

         --
         hr_utility.trace('l_element_link_id is ' ||
                           to_char(l_element_link_id));
         --
         hr_utility.set_location(l_proc, 65);
         --
         --
         hr_utility.set_location(l_proc, 70);
         --
         savepoint val_timecard;
         --
         l_cost := 'N';
         --
         FOR i in 1 .. 30 LOOP
             IF l_segment(i) IS NOT NULL THEN
                l_cost := 'Y';
                EXIT;
             END IF;
         END LOOP;
         --
         IF l_cost = 'Y' THEN
            BEGIN
            l_cost_allocation_keyflex_id := hr_entry.maintain_cost_keyflex(
                  p_cost_keyflex_structure     => l_cost_allocation_structure,
                  p_cost_allocation_keyflex_id => -1,
                  p_concatenated_segments      => NULL,
                  p_summary_flag               => 'N',
                  p_start_date_active          => NULL,
                  p_end_date_active            => NULL,
                  p_segment1                   => l_segment(1),
                  p_segment2                   => l_segment(2),
                  p_segment3                   => l_segment(3),
                  p_segment4                   => l_segment(4),
                  p_segment5                   => l_segment(5),
                  p_segment6                   => l_segment(6),
                  p_segment7                   => l_segment(7),
                  p_segment8                   => l_segment(8),
                  p_segment9                   => l_segment(9),
                  p_segment10                  => l_segment(10),
                  p_segment11                  => l_segment(11),
                  p_segment12                  => l_segment(12),
                  p_segment13                  => l_segment(13),
                  p_segment14                  => l_segment(14),
                  p_segment15                  => l_segment(15),
                  p_segment16                  => l_segment(16),
                  p_segment17                  => l_segment(17),
                  p_segment18                  => l_segment(18),
                  p_segment19                  => l_segment(19),
                  p_segment20                  => l_segment(20),
                  p_segment21                  => l_segment(21),
                  p_segment22                  => l_segment(22),
                  p_segment23                  => l_segment(23),
                  p_segment24                  => l_segment(24),
                  p_segment25                  => l_segment(25),
                  p_segment26                  => l_segment(26),
                  p_segment27                  => l_segment(27),
                  p_segment28                  => l_segment(28),
                  p_segment29                  => l_segment(29),
                  p_segment30                  => l_segment(30));
            --
            hr_utility.set_location(l_proc, 80);
            --
            EXCEPTION
               WHEN OTHERS THEN
                  --
                  hr_message.provide_error;
                  --
                  hxc_time_entry_rules_utils_pkg.add_error_to_table(
                    p_message_table          => p_messages
                   ,p_message_name           => hr_message.last_message_name
                   ,p_message_token          => NULL
                   ,p_message_level          => 'ERROR'
                   ,p_message_field          => NULL
                   ,p_application_short_name => hr_message.last_message_app
                   ,p_timecard_bb_id         => l_bb_id
                   ,p_time_attribute_id      => l_time_attribute_id
                   ,p_timecard_bb_ovn        => l_bb_ovn
                   ,p_time_attribute_ovn     => NULL);
                  --
                  -- p_messages(g_error_count).MESSAGE_NAME :=
                  --                          hr_message.last_message_name;
                  -- p_messages(g_error_count).APPLICATION_SHORT_NAME :=
                  --                          hr_message.last_message_app;
                  --
                  --raise e_error;        115.27 Change
                  raise e_continue;
                  --
            END;
            --
         ELSE
            --
            l_cost_allocation_keyflex_id := NULL;
            --
            hr_utility.set_location(l_proc, 85);
            --
         END IF;
         --
         hr_utility.set_location(l_proc, 88);

hr_utility.trace('iv 2 is '||l_input_value(2).value);
         --
         BEGIN
         py_element_entry_api.create_element_entry
           (p_validate                      => true
           ,p_effective_date                => l_effective_date
           ,p_business_group_id             => l_business_group_id
           -- ,p_original_entry_id          =>
           ,p_assignment_id                 => l_assignment_id
           ,p_element_link_id               => l_element_link_id
           ,p_entry_type                    => 'E'
           ,p_cost_allocation_keyflex_id    => l_cost_allocation_keyflex_id
           -- ,p_updating_action_id         =>
           -- ,p_comment_id                 =>
           -- ,p_reason                     =>
           -- ,p_target_entry_id            =>
           -- ,p_subpriority                =>
           ,p_date_earned                   => l_effective_date
           -- ,p_personal_payment_method_id =>
           -- ,p_attribute_category         =>
           -- ,p_attribute1                 =>
           -- ,p_attribute2                 =>
           -- ,p_attribute3                 =>
           -- ,p_attribute4                 =>
           -- ,p_attribute5                 =>
           -- ,p_attribute6                 =>
           -- ,p_attribute7                 =>
           -- ,p_attribute8                 =>
           -- ,p_attribute9                 =>
           -- ,p_attribute10                =>
           -- ,p_attribute11                =>
           -- ,p_attribute12                =>
           -- ,p_attribute13                =>
           -- ,p_attribute14                =>
           -- ,p_attribute15                =>
           -- ,p_attribute16                =>
           -- ,p_attribute17                =>
           -- ,p_attribute18                =>
           -- ,p_attribute19                =>
           -- ,p_attribute20                =>
           ,p_input_value_id1               => l_input_value(1).id
           ,p_input_value_id2               => l_input_value(2).id
           ,p_input_value_id3               => l_input_value(3).id
           ,p_input_value_id4               => l_input_value(4).id
           ,p_input_value_id5               => l_input_value(5).id
           ,p_input_value_id6               => l_input_value(6).id
           ,p_input_value_id7               => l_input_value(7).id
           ,p_input_value_id8               => l_input_value(8).id
           ,p_input_value_id9               => l_input_value(9).id
           ,p_input_value_id10              => l_input_value(10).id
           ,p_input_value_id11              => l_input_value(11).id
           ,p_input_value_id12              => l_input_value(12).id
           ,p_input_value_id13              => l_input_value(13).id
           ,p_input_value_id14              => l_input_value(14).id
           ,p_input_value_id15              => l_input_value(15).id
           ,p_entry_value1                  => l_input_value(1).value
           ,p_entry_value2                  => l_input_value(2).value
           ,p_entry_value3                  => l_input_value(3).value
           ,p_entry_value4                  => l_input_value(4).value
           ,p_entry_value5                  => l_input_value(5).value
           ,p_entry_value6                  => l_input_value(6).value
           ,p_entry_value7                  => l_input_value(7).value
           ,p_entry_value8                  => l_input_value(8).value
           ,p_entry_value9                  => l_input_value(9).value
           ,p_entry_value10                 => l_input_value(10).value
           ,p_entry_value11                 => l_input_value(11).value
           ,p_entry_value12                 => l_input_value(12).value
           ,p_entry_value13                 => l_input_value(13).value
           ,p_entry_value14                 => l_input_value(14).value
           ,p_entry_value15                 => l_input_value(15).value
           ,p_effective_start_date          => l_effective_start_date
           ,p_effective_end_date            => l_effective_end_date
           ,p_element_entry_id              => l_element_entry_id
           ,p_object_version_number         => l_object_version_number
           ,p_create_warning                => l_create_warning
           );
         --
         hr_utility.set_location(l_proc, 90);
         --
         EXCEPTION
            WHEN OTHERS THEN
               --
               hr_message.provide_error;
               --
               IF hr_message.last_message_name = 'HR_ELE_ENTRY_FORMULA_HINT' THEN
		       hxc_time_entry_rules_utils_pkg.add_error_to_table(
			    p_message_table          => p_messages
			   ,p_message_name           => hr_message.last_message_name
			   ,p_message_token          => 'FORMULA_TEXT&'||hr_message.get_message_text
			   ,p_message_level          => 'ERROR'
			   ,p_message_field          => NULL
			   ,p_application_short_name => hr_message.last_message_app
			   ,p_timecard_bb_id         => l_bb_id
			   ,p_time_attribute_id      => l_time_attribute_id
			   ,p_timecard_bb_ovn        => l_bb_ovn
			   ,p_time_attribute_ovn     => NULL);
               ELSE
		       hxc_time_entry_rules_utils_pkg.add_error_to_table(
					   p_message_table          => p_messages
					  ,p_message_name           => hr_message.last_message_name
					  ,p_message_token          => NULL
					  ,p_message_level          => 'ERROR'
					  ,p_message_field          => NULL
					  ,p_application_short_name => hr_message.last_message_app
					  ,p_timecard_bb_id         => l_bb_id
					  ,p_time_attribute_id      => l_time_attribute_id
					  ,p_timecard_bb_ovn        => l_bb_ovn
			   ,p_time_attribute_ovn     => NULL);

               END IF;
               --
               -- p_messages(g_error_count).MESSAGE_NAME :=
               --                           hr_message.last_message_name;
               -- p_messages(g_error_count).APPLICATION_SHORT_NAME :=
               --                           hr_message.last_message_app;
               --
               --raise e_error;    115.27 change
               raise e_continue;
               --
         END;
         --
         rollback to val_timecard;
         --
      ELSE
         --
         hr_utility.set_location(l_proc, 100);
         --
         hxc_time_entry_rules_utils_pkg.add_error_to_table(
              p_message_table          => p_messages
             ,p_message_name           => 'HXC_DEP_VAL_NO_ATTR'
             ,p_message_token          => NULL
             ,p_message_level          => 'ERROR'
             ,p_message_field          => NULL
             ,p_application_short_name => 'HXC'
             ,p_timecard_bb_id         => l_bb_id
             ,p_time_attribute_id      => l_time_attribute_id
             ,p_timecard_bb_ovn        => l_bb_ovn
             ,p_time_attribute_ovn     => NULL);
         --
          raise e_continue;                --Bug#3004714

-- Start 2887210, i.e. Comment the raise error
--                     Instead let the errors consolidate in the message table.
--         raise e_error;
--  End  2887210
         --
      END IF; -- l_att is greater than 0
      --
   EXCEPTION           --Bug#3004714
      WHEN e_continue THEN
        null;
   END;                --Bug#3004714


   END IF; -- l_valid = Y and l_scope = DETAIL
   --
l_cnt := p_time_building_blocks.next(l_cnt);


END LOOP;
--
hr_utility.set_location(l_proc, 110);
--
EXCEPTION
   WHEN e_error THEN
      RETURN;
--
-- hr_utility.trace_off;
--
END pay_validate_timecard;
--
--
END pay_hxc_deposit_interface;

/
