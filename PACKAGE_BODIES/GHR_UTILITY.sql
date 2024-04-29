--------------------------------------------------------
--  DDL for Package Body GHR_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_UTILITY" AS
/* $Header: ghutils.pkb 120.20 2005/12/09 04:37:37 sumarimu noship $ */
--
-- Figure out whether GHR is installed or not.
-- if GHR_US_ORG_INFORMATION is defined for current business group
-- it is assumed that GHR is installed.
--
  g_package      VARCHAR2(30) := 'ghr_utility.';
  v_current_bg NUMBER;
  CURSOR c_fed_bg (p_current_bg  NUMBER) IS
       SELECT hoi.org_information_context
            , hoi.org_information1
       FROM hr_organization_information hoi
       WHERE hoi.org_information_context = 'GHR_US_ORG_INFORMATION'
         AND hoi.organization_id = p_current_bg;

  CURSOR c_fed_nfc (p_current_bg  NUMBER) IS
       SELECT hoi.org_information_context
            , hoi.org_information6
       FROM hr_organization_information hoi
       WHERE hoi.org_information_context = 'GHR_US_ORG_INFORMATION'
         AND hoi.organization_id = p_current_bg
         AND hoi.org_information6 = 'Y';

  CURSOR c_ben_pgm (p_current_bg  NUMBER) IS
       SELECT 1
       FROM ben_pgm_f
       WHERE name = 'Federal Employees Health Benefits' and business_group_id = p_current_bg;

  CURSOR c_ben_pgm_fehb (p_current_bg  NUMBER) IS
       SELECT 1
       FROM ben_pgm_f
       WHERE name = 'Federal Employees Health Benefits'
       and   business_group_id = p_current_bg
       and   pgm_stat_cd = 'A';

  CURSOR c_ben_pgm_tsp (p_current_bg  NUMBER) IS
       SELECT 1
       FROM ben_pgm_f
       WHERE name = 'Federal Thrift Savings Plan (TSP)'
       and   business_group_id = p_current_bg
       and   pgm_stat_cd = 'A';

    r_fed_bg        c_fed_bg%ROWTYPE;
    v_is_ghr        VARCHAR2(10);
    r_ben_pgm       c_ben_pgm%ROWTYPE;
    r_ben_pgm_fehb  c_ben_pgm%ROWTYPE;
    r_ben_pgm_tsp   c_ben_pgm%ROWTYPE;
    v_is_ghr_ben    VARCHAR2(10);
    v_is_ghr_ben_fehb   VARCHAR2(10);
    v_is_ghr_ben_tsp    VARCHAR2(10);
    r_ben_nfc       c_fed_nfc%ROWTYPE;
    v_is_ghr_nfc    VARCHAR2(10);


--############### Function to get Flex Number #############################################

	FUNCTION get_flex_num(p_flex_code fnd_id_flex_structures_tl.id_flex_code%TYPE,
			       p_struct_name fnd_id_flex_structures_tl.id_flex_structure_name%TYPE) RETURN NUMBER IS

		CURSOR c_flex_num(c_flex_code fnd_id_flex_structures_tl.id_flex_code%TYPE,
				  c_struct_name fnd_id_flex_structures_tl.id_flex_structure_name%TYPE) IS
		  select    flx.id_flex_num
		  from      fnd_id_flex_structures_tl flx
		  where     flx.id_flex_code           =  c_flex_code -- 'POS'
		  and       flx.application_id         =  800   --
		  and       flx.id_flex_structure_name =  c_struct_name -- 'US Federal Position'
		  and	    flx.language	       = 'US';
		l_flex_num fnd_id_flex_structures_tl.id_flex_num%type;

		BEGIN
		-- Get Flex ID Number
		FOR l_cur_flex_num IN c_flex_num(p_flex_code,p_struct_name) LOOP
			l_flex_num := l_cur_flex_num.id_flex_num;
		END LOOP;
		RETURN l_flex_num;
	END get_flex_num;


--############### Function to get Position Flex Number #############################################

	FUNCTION get_pos_flex_num(p_bus_org_id hr_all_organization_units.business_group_id%type) RETURN NUMBER IS
		CURSOR c_pos_flex_num(c_bus_org_id hr_all_organization_units.business_group_id%type) IS
		  select org_information8
		  from hr_organization_information oi
		  where org_information_context = 'Business Group Information'
		  and organization_id = c_bus_org_id;

		l_flex_num fnd_id_flex_structures_tl.id_flex_num%type;

		BEGIN
		-- Get Flex ID Number
		FOR l_cur_flex_num IN c_pos_flex_num(p_bus_org_id) LOOP
			l_flex_num := l_cur_flex_num.org_information8;
		END LOOP;
		RETURN l_flex_num;
	END get_pos_flex_num;

	--############### Function to get Flex field segment values #############################################
	FUNCTION get_segments(p_flex_num fnd_id_flex_structures_tl.id_flex_num%type,
                      p_flex_code fnd_id_flex_segments_vl.id_flex_code%type)
		RETURN t_flex_recs IS

		CURSOR c_get_segment_rec(c_flex_num fnd_id_flex_structures_tl.id_flex_num%type,
			c_flex_code fnd_id_flex_segments_vl.id_flex_code%type) 	IS
			SELECT
			  SEGMENT_NAME,
			  DESCRIPTION,
			  ENABLED_FLAG,
			  APPLICATION_COLUMN_NAME,
			  SEGMENT_NUM,
			  DISPLAY_FLAG,
			  APPLICATION_COLUMN_INDEX_FLAG,
			  DEFAULT_VALUE,
			  RUNTIME_PROPERTY_FUNCTION,
			  ADDITIONAL_WHERE_CLAUSE,
			  REQUIRED_FLAG,
			  SECURITY_ENABLED_FLAG,
			  DISPLAY_SIZE,
			  MAXIMUM_DESCRIPTION_LEN,
			  CONCATENATION_DESCRIPTION_LEN,
			  FORM_ABOVE_PROMPT,
			  FORM_LEFT_PROMPT,
			  RANGE_CODE,
			  FLEX_VALUE_SET_ID,
			  DEFAULT_TYPE,
			  ID_FLEX_NUM,
			  ID_FLEX_CODE,
			  APPLICATION_ID,
			  ROW_ID
			FROM
			  FND_ID_FLEX_SEGMENTS_VL
			WHERE
			  (ID_FLEX_NUM= c_flex_num) and -- 50520
			  (ID_FLEX_CODE= c_flex_code) and -- 'POS'
			  (APPLICATION_ID= 800)
			  order by segment_num;
		 l_index NUMBER;
		BEGIN
			l_index := 1;
			FOR l_cur_get_segs IN c_get_segment_rec(p_flex_num,p_flex_code) LOOP
				l_flex_recs(l_index).SEGMENT_NAME := l_cur_get_segs.SEGMENT_NAME;
				l_flex_recs(l_index).SEGMENT_NUM := l_cur_get_segs.SEGMENT_NUM;
				l_index := l_index + 1;
			END LOOP;
			RETURN l_flex_recs;
		END get_segments;

	--############### Function to get Flex field delimiter #############################################
	FUNCTION get_flex_delimiter(p_flex_code fnd_id_flex_segments_vl.id_flex_code%type,
			    p_flex_num fnd_id_flex_structures_vl.id_flex_num%type) RETURN VARCHAR2 IS
		CURSOR c_get_delimiter(c_flex_code fnd_id_flex_segments_vl.id_flex_code%type,
					c_flex_num fnd_id_flex_structures_vl.id_flex_num%type) IS

		SELECT concatenated_segment_delimiter delimiter
		FROM fnd_id_flex_structures_vl
		WHERE (APPLICATION_ID=800) AND
		(ID_FLEX_CODE= c_flex_code) AND
		id_flex_num =  c_flex_num; --
		l_flex_delimiter fnd_id_flex_structures_vl.concatenated_segment_delimiter%type;
	BEGIN
		FOR l_get_delimiter IN c_get_delimiter(p_flex_code,p_flex_num) LOOP
			l_flex_delimiter := l_get_delimiter.delimiter;
		END LOOP;
		RETURN l_flex_delimiter;

	END get_flex_delimiter;


	--############### Function to get concatenated Position name #############################################
	FUNCTION return_pos_name(l_pos_title per_position_definitions.segment1%type,
			 l_pos_desc per_position_definitions.segment1%type,
			 l_seq_no per_position_definitions.segment1%type,
			 l_agency_code per_position_definitions.segment1%type,
			 l_po_id per_position_definitions.segment1%type,
			 l_grade per_position_definitions.segment1%type,
			 l_nfc_agency_code  per_position_definitions.segment1%type,
			 l_full_title hr_positions_f.name%type)
	RETURN VARCHAR2 IS
		l_flex_num NUMBER;
		l_flex_recs t_flex_recs;
		TYPE t_pos_rec IS RECORD
		(seq_no NUMBER,
		 segment_name VARCHAR2(200));
		 TYPE lt_pos_rec IS TABLE OF t_pos_rec INDEX BY BINARY_INTEGER;
		 l_pos_rec lt_pos_rec;
		 l_pos_indiv_rec t_pos_rec;
		 l_index NUMBER;
		 l_final VARCHAR2(2000);
		 l_seg_value VARCHAR2(2000);
		 l_pos_title_index NUMBER;
		 l_pos_desc_index NUMBER;
		 l_delimiter VARCHAR2(10);
		 l_temp varchar2(2000);
		 l_rem varchar2(2000);
		 TYPE t_pos_name_arr IS TABLE OF VARCHAR2(250) INDEX BY BINARY_INTEGER;
		 l_pos_name_arr t_pos_name_arr;
		 l_delimiter_index NUMBER;
		 l_ctr NUMBER;
		 l_bus_group_id per_business_groups.business_group_id%TYPE;

	BEGIN
	  l_index := 1;
	  fnd_profile.get('PER_BUSINESS_GROUP_ID',l_bus_group_id);

  	  l_flex_num := get_pos_flex_num(p_bus_org_id=>l_bus_group_id) ;

	  l_flex_recs := get_segments(p_flex_num => l_flex_num,
				      p_flex_code => 'POS');
	  l_delimiter :=  ghr_utility.get_flex_delimiter(p_flex_code => 'POS',
	                                                 p_flex_num => l_flex_num);

	  ------------------------------------------------
	  -- Storing Position segment details in a rec.
	  ------------------------------------------------

	  FOR lt_flex_recs IN l_flex_recs.FIRST .. l_flex_recs.LAST LOOP
		l_pos_rec(l_index).seq_no := l_index;
		l_pos_rec(l_index).segment_name := l_flex_recs(lt_flex_recs).SEGMENT_NAME;
		l_index := l_index + 1;
	  END LOOP;

	  ------------------------------------------------
	  -- Extracting Segment values from Position Name
	  ------------------------------------------------
	  l_temp := l_full_title;
	  l_rem := l_full_title;
	  l_ctr := 1;

	  IF l_rem IS NOT NULL THEN
		  WHILE INSTR(l_rem,l_delimiter) > 0 LOOP
			l_delimiter_index := INSTR(l_rem,l_delimiter);
			l_temp := SUBSTR(l_rem,1,l_delimiter_index-1);
			l_rem := SUBSTR(l_rem,l_delimiter_index+1);
			l_pos_name_arr(l_ctr) := l_temp;
			l_ctr := l_ctr + 1;
		  END LOOP;
		  l_pos_name_arr(l_ctr) := l_rem;
	  END IF;
	  ------------------------------------------------
	  -- Concatenate Position segment values
	  ------------------------------------------------

	  -- To concatenate flex field string values
	  FOR l_rec IN l_pos_rec.FIRST .. l_pos_rec.LAST LOOP
		IF l_pos_rec(l_rec).segment_name = 'Position Title' THEN
			IF ltrim(l_full_title) IS NOT NULL THEN
				l_seg_value := l_pos_name_arr(l_pos_rec(l_rec).seq_no);
			ELSE
				l_seg_value := l_pos_title;
			END IF;
		END IF;

		IF l_pos_rec(l_rec).segment_name = 'Position Description' THEN
			IF ltrim(l_full_title) IS NOT NULL THEN
				l_seg_value := l_pos_name_arr(l_pos_rec(l_rec).seq_no);
			ELSE
				l_seg_value := l_pos_desc;
			END IF;
		END IF;
		IF l_pos_rec(l_rec).segment_name = 'Sequence Number' THEN
			l_seg_value := l_seq_no;
		END IF;
		IF l_pos_rec(l_rec).segment_name = 'Agency/Subelement Code' THEN
			l_seg_value := l_agency_code;
		END IF;
		IF l_pos_rec(l_rec).segment_name = 'Personnel Office Identifier' THEN
			l_seg_value := l_po_id;
		END IF;
		IF l_pos_rec(l_rec).segment_name = 'Grade' THEN
			l_seg_value := l_grade;
		END IF;
		IF l_pos_rec(l_rec).segment_name = 'NFC Agency Code' THEN
			l_seg_value := l_nfc_agency_code;
		END IF;

		IF l_rec = l_pos_rec.LAST THEN
			l_final := l_final || l_seg_value;
		ELSE
			l_final := l_final || l_seg_value || l_delimiter;
		END IF;
	  END LOOP;

	RETURN l_final;

	END return_pos_name;

--############### Function to get concatenated Position name #############################################
	FUNCTION return_nfc_pos_name(l_pos_title per_position_definitions.segment1%type,
			 l_pos_desc per_position_definitions.segment1%type,
			 l_seq_no per_position_definitions.segment1%type,
			 l_agency_code per_position_definitions.segment1%type,
			 l_po_id per_position_definitions.segment1%type,
			 l_grade per_position_definitions.segment1%type,
			 l_nfc_agency_code  per_position_definitions.segment1%type,
			 l_full_title hr_positions_f.name%type)
	RETURN VARCHAR2 IS
		 l_final VARCHAR2(2000);
		 l_delimiter VARCHAR2(10);
		 l_temp varchar2(2000);
		 l_rem varchar2(2000);
		 TYPE t_pos_name_arr IS TABLE OF VARCHAR2(250) INDEX BY BINARY_INTEGER;
		 l_pos_name_arr t_pos_name_arr;
		 l_delimiter_index NUMBER;
		 l_pos_new_title per_position_definitions.segment1%type;
		 l_pos_new_desc  per_position_definitions.segment1%type;
		 l_ctr NUMBER;
		 l_flex_num NUMBER;
		 l_bus_group_id per_business_groups.business_group_id%TYPE;

	BEGIN
	  fnd_profile.get('PER_BUSINESS_GROUP_ID',l_bus_group_id);

  	  l_flex_num := get_pos_flex_num(p_bus_org_id=>l_bus_group_id) ;

	  l_delimiter := ghr_utility.get_flex_delimiter(p_flex_code => 'POS',
	                                                 p_flex_num => l_flex_num);
	  ------------------------------------------------
	  -- Extracting Segment values from Position Name
	  ------------------------------------------------
	  l_temp := l_full_title;
	  l_rem := l_full_title;
	  l_ctr := 1;

	  IF l_rem IS NOT NULL THEN
		  WHILE INSTR(l_rem,l_delimiter) > 0 LOOP
			l_delimiter_index := INSTR(l_rem,l_delimiter);
			l_temp := SUBSTR(l_rem,1,l_delimiter_index-1);
			l_rem := SUBSTR(l_rem,l_delimiter_index+1);
			l_pos_name_arr(l_ctr) := l_temp;
			l_ctr := l_ctr + 1;
		  END LOOP;
		  l_pos_name_arr(l_ctr) := l_rem;
	  END IF;

	  IF ltrim(l_full_title) IS NOT NULL THEN
		l_pos_new_title := l_pos_name_arr(1);
		l_pos_new_desc := l_pos_name_arr(5);
	  ELSE
		l_pos_new_title := l_pos_title;
		l_pos_new_desc := l_pos_desc;
	  END IF;


	  ------------------------------------------------
	  -- Concatenate Position segment values
	  ------------------------------------------------
	  -- Hard coded for GPO
	  l_final := l_pos_new_title || l_delimiter || l_agency_code || l_delimiter || l_nfc_agency_code || l_delimiter ||
			 l_po_id || l_delimiter || l_pos_new_desc || l_delimiter  || l_grade;

-- || l_delimiter || l_grade;

	RETURN l_final;

	END return_nfc_pos_name;


PROCEDURE validate_nfc(
P_POSITION_ID in NUMBER
,P_SEGMENT1 in VARCHAR2
,P_SEGMENT2 in VARCHAR2
,P_SEGMENT3 in VARCHAR2
,P_SEGMENT4 in VARCHAR2
,P_SEGMENT5 in VARCHAR2
,P_SEGMENT6 in VARCHAR2
,P_SEGMENT7 in VARCHAR2
,P_SEGMENT8 in VARCHAR2
,P_SEGMENT9 in VARCHAR2
,P_SEGMENT10 in VARCHAR2
,P_SEGMENT11 in VARCHAR2
,P_SEGMENT12 in VARCHAR2
,P_SEGMENT13 in VARCHAR2
,P_SEGMENT14 in VARCHAR2
,P_SEGMENT15 in VARCHAR2
,P_SEGMENT16 in VARCHAR2
,P_SEGMENT17 in VARCHAR2
,P_SEGMENT18 in VARCHAR2
,P_SEGMENT19 in VARCHAR2
,P_SEGMENT20 in VARCHAR2
,P_SEGMENT21 in VARCHAR2
,P_SEGMENT22 in VARCHAR2
,P_SEGMENT23 in VARCHAR2
,P_SEGMENT24 in VARCHAR2
,P_SEGMENT25 in VARCHAR2
,P_SEGMENT26 in VARCHAR2
,P_SEGMENT27 in VARCHAR2
,P_SEGMENT28 in VARCHAR2
,P_SEGMENT29 in VARCHAR2
,P_SEGMENT30 in VARCHAR2
,P_INFORMATION6 in VARCHAR2
,P_EFFECTIVE_DATE in DATE
,P_LANGUAGE_CODE in VARCHAR2 ) IS
	cursor c_old_pos_segments(c_position_id hr_all_positions_f.position_id%type,
                c_effective_date date) is
	select information6,segment1,segment2,segment3,segment4,
		segment5,segment6,segment7
	from per_position_definitions pdf, hr_all_positions_f pos
	where pos.position_definition_id = pdf.position_definition_id
	and pos.position_id = c_position_id
        and c_effective_date between pos.effective_start_date and
         pos.effective_end_date;

	CURSOR c_check_child(c_position_id hr_positions_f.position_id%type) IS
	SELECT 1 FROM hr_positions_f
	WHERE information6 = to_char(c_position_id); -- Bug 4576746

	l_child_exists BOOLEAN;
        l_pos_cre_extra_info_id per_position_extra_info.position_extra_info_id%type;
        l_extra_info_id per_position_extra_info.position_extra_info_id%type;
        l_pos_cre_ovn per_position_extra_info.object_version_number%type;
        l_ovn per_position_extra_info.object_version_number%type;
        l_information_type per_position_extra_info.information_type%type;
 l_session_date fnd_sessions.effective_date%type;
cursor c_get_session_date is
    select trunc(effective_date) session_date
      from fnd_sessions
      where session_id = (select userenv('sessionid') from dual);

BEGIN
  IF ghr_utility.is_ghr_nfc = 'TRUE' THEN
	l_child_exists := FALSE;
	hr_utility.set_location('Entering: Validate_NFC ',10);
 -- Get Session Date
     l_session_date := trunc(sysdate);
   for ses_rec in c_get_session_date loop
     l_session_date := ses_rec.session_date;
   end loop;
	hr_utility.set_location(' Validate_NFC ',20);
	-- Check for the change in the segments
--	for c_old_rec in c_old_pos_segments(p_position_id) loop
	IF p_information6 IS NOT NULL and p_information6  <> hr_api.g_varchar2
  THEN
	hr_utility.set_location(' Validate_NFC '||p_information6,30);
	   FOR c_old_rec in c_old_pos_segments(p_information6,l_session_date) LOOP
	hr_utility.set_location(' Validate_NFC '||p_information6,31);
		 IF NVL(c_old_rec.segment2,hr_api.g_varchar2) <> NVL(p_segment2,hr_api.g_varchar2) OR
		    NVL(c_old_rec.segment3,hr_api.g_varchar2) <> NVL(p_segment3,hr_api.g_varchar2) OR
		    NVL(c_old_rec.segment4,hr_api.g_varchar2) <> NVL(p_segment4,hr_api.g_varchar2) OR
		   -- NVL(c_old_rec.segment6,hr_api.g_varchar2) <> NVL(p_segment6,hr_api.g_varchar2) OR
		    NVL(c_old_rec.segment7,hr_api.g_varchar2) <> NVL(p_segment7,hr_api.g_varchar2) THEN
		    hr_utility.set_message(8301,'GHR_38948_NFC_ERROR4');
		    hr_utility.raise_error;
		  END IF;
	   END LOOP;
	END IF;

	-- Raise error when master position segments are changed
	-- when they're having child individual positions attached to it
	IF p_information6 IS NULL or p_information6 = hr_api.g_varchar2 THEN
	hr_utility.set_location(' Validate_NFC ',40);
		 -- Check if the segment values have changed.
		 FOR c_old_rec in c_old_pos_segments(P_POSITION_ID,l_session_date) LOOP
			 IF NVL(c_old_rec.segment2,hr_api.g_varchar2) <> NVL(p_segment2,hr_api.g_varchar2) OR
			    NVL(c_old_rec.segment3,hr_api.g_varchar2) <> NVL(p_segment3,hr_api.g_varchar2) OR
			    NVL(c_old_rec.segment4,hr_api.g_varchar2) <> NVL(p_segment4,hr_api.g_varchar2) OR
			  --  NVL(c_old_rec.segment6,hr_api.g_varchar2) <> NVL(p_segment6,hr_api.g_varchar2) OR
			    NVL(c_old_rec.segment7,hr_api.g_varchar2) <> NVL(p_segment7,hr_api.g_varchar2) THEN
				hr_utility.set_location(' Validate_NFC ',50);
			    -- Raise error if child exists
				    FOR l_check_child IN c_check_child(P_POSITION_ID) LOOP
					l_child_exists := TRUE;
					EXIT;
				    END LOOP;
					hr_utility.set_location(' Validate_NFC ',60);
				    IF l_child_exists = TRUE THEN
					    hr_utility.set_message(8301,'GHR_38949_NFC_ERROR5');
					    hr_utility.raise_error;
				    END IF;
			  END IF;
		END LOOP;
	END IF;
--
END IF; -- is_ghr_nfc check

END validate_nfc;


PROCEDURE validate_delete_nfc(
P_POSITION_ID in NUMBER
,P_EFFECTIVE_DATE in DATE
 ) IS

	CURSOR c_check_child(c_position_id hr_positions_f.position_id%type) IS
	SELECT 1 FROM hr_positions_f
	WHERE information6 = to_char(c_position_id); -- Bug 4576746

	l_child_exists BOOLEAN;

BEGIN
  IF ghr_utility.is_ghr_nfc = 'TRUE' THEN
	l_child_exists := FALSE;
	hr_utility.set_location('Entering: Validate_Delete_NFC ',10);
	-- Raise error if child exists
	FOR l_check_child IN c_check_child(P_POSITION_ID) LOOP
	l_child_exists := TRUE;
	EXIT;
	END LOOP;

	hr_utility.set_location(' Validate_Delete_NFC ',60);
	IF l_child_exists = TRUE THEN
		hr_utility.set_message(8301,'GHR_38949_NFC_ERROR5');
		hr_utility.raise_error;
	END IF;
--
END IF; -- is_ghr_nfc check

END validate_delete_nfc;

PROCEDURE validate_create_nfc(
 P_SEGMENT1 in VARCHAR2
,P_SEGMENT2 in VARCHAR2
,P_SEGMENT3 in VARCHAR2
,P_SEGMENT4 in VARCHAR2
,P_SEGMENT5 in VARCHAR2
,P_SEGMENT6 in VARCHAR2
,P_SEGMENT7 in VARCHAR2
,P_SEGMENT8 in VARCHAR2
,P_SEGMENT9 in VARCHAR2
,P_SEGMENT10 in VARCHAR2
,P_SEGMENT11 in VARCHAR2
,P_SEGMENT12 in VARCHAR2
,P_SEGMENT13 in VARCHAR2
,P_SEGMENT14 in VARCHAR2
,P_SEGMENT15 in VARCHAR2
,P_SEGMENT16 in VARCHAR2
,P_SEGMENT17 in VARCHAR2
,P_SEGMENT18 in VARCHAR2
,P_SEGMENT19 in VARCHAR2
,P_SEGMENT20 in VARCHAR2
,P_SEGMENT21 in VARCHAR2
,P_SEGMENT22 in VARCHAR2
,P_SEGMENT23 in VARCHAR2
,P_SEGMENT24 in VARCHAR2
,P_SEGMENT25 in VARCHAR2
,P_SEGMENT26 in VARCHAR2
,P_SEGMENT27 in VARCHAR2
,P_SEGMENT28 in VARCHAR2
,P_SEGMENT29 in VARCHAR2
,P_SEGMENT30 in VARCHAR2
,P_INFORMATION6 in VARCHAR2
,P_EFFECTIVE_DATE in DATE
,P_LANGUAGE_CODE in VARCHAR2 ) IS
	cursor c_old_pos_segments(c_position_id hr_all_positions_f.position_id%type,
                c_effective_date date) is
	select information6,segment1,segment2,segment3,segment4,
		segment5,segment6,segment7
	from per_position_definitions pdf, hr_all_positions_f pos
	where pos.position_definition_id = pdf.position_definition_id
	and pos.position_id = c_position_id
        and c_effective_date between pos.effective_start_date and
         pos.effective_end_date;

        l_pos_cre_extra_info_id per_position_extra_info.position_extra_info_id%type;
        l_extra_info_id per_position_extra_info.position_extra_info_id%type;
        l_pos_cre_ovn per_position_extra_info.object_version_number%type;
        l_ovn per_position_extra_info.object_version_number%type;
        l_information_type per_position_extra_info.information_type%type;
 l_session_date fnd_sessions.effective_date%type;
cursor c_get_session_date is
    select trunc(effective_date) session_date
      from fnd_sessions
      where session_id = (select userenv('sessionid') from dual);

BEGIN
  IF ghr_utility.is_ghr_nfc = 'TRUE' THEN
	hr_utility.set_location('Entering: HR_POSITION_BK1.CREATE_POSITION_B', 10);
	-- Check for the change in the segments
--	for c_old_rec in c_old_pos_segments(p_position_id) loop
 -- Get Session Date
     l_session_date := trunc(sysdate);
   for ses_rec in c_get_session_date loop
     l_session_date := ses_rec.session_date;
   end loop;
	IF p_information6 IS NOT NULL THEN
	   for c_old_rec in c_old_pos_segments(p_information6,l_session_date) loop
		 IF NVL(c_old_rec.segment2,hr_api.g_varchar2) <> NVL(p_segment2,hr_api.g_varchar2) OR
		    NVL(c_old_rec.segment3,hr_api.g_varchar2) <> NVL(p_segment3,hr_api.g_varchar2) OR
		    NVL(c_old_rec.segment4,hr_api.g_varchar2) <> NVL(p_segment4,hr_api.g_varchar2) or
              --    NVL(c_old_rec.segment6,hr_api.g_varchar2) <> NVL(p_segment6,hr_api.g_varchar2) or
		    NVL(c_old_rec.segment7,hr_api.g_varchar2) <> NVL(p_segment7,hr_api.g_varchar2) then
		    hr_utility.set_message(8301,'GHR_38948_NFC_ERROR4');
		    hr_utility.raise_error;
		  END IF;
	   end loop;
	END IF;
--
END IF; -- is_ghr_nfc check

END validate_create_nfc;

PROCEDURE update_nfc_eit(
P_POSITION_ID in NUMBER
,P_SEGMENT1 in VARCHAR2
,P_SEGMENT2 in VARCHAR2
,P_SEGMENT3 in VARCHAR2
,P_SEGMENT4 in VARCHAR2
,P_SEGMENT5 in VARCHAR2
,P_SEGMENT6 in VARCHAR2
,P_SEGMENT7 in VARCHAR2
,P_SEGMENT8 in VARCHAR2
,P_SEGMENT9 in VARCHAR2
,P_SEGMENT10 in VARCHAR2
,P_SEGMENT11 in VARCHAR2
,P_SEGMENT12 in VARCHAR2
,P_SEGMENT13 in VARCHAR2
,P_SEGMENT14 in VARCHAR2
,P_SEGMENT15 in VARCHAR2
,P_SEGMENT16 in VARCHAR2
,P_SEGMENT17 in VARCHAR2
,P_SEGMENT18 in VARCHAR2
,P_SEGMENT19 in VARCHAR2
,P_SEGMENT20 in VARCHAR2
,P_SEGMENT21 in VARCHAR2
,P_SEGMENT22 in VARCHAR2
,P_SEGMENT23 in VARCHAR2
,P_SEGMENT24 in VARCHAR2
,P_SEGMENT25 in VARCHAR2
,P_SEGMENT26 in VARCHAR2
,P_SEGMENT27 in VARCHAR2
,P_SEGMENT28 in VARCHAR2
,P_SEGMENT29 in VARCHAR2
,P_SEGMENT30 in VARCHAR2
,P_INFORMATION6 in VARCHAR2
,P_EFFECTIVE_DATE in DATE
,P_LANGUAGE_CODE in VARCHAR2 ) IS
 Cursor c_pos_ei(p_position_id in NUMBER,
      p_information_type in VARCHAR2)  is
     select position_extra_info_id,
            object_version_number
     from   per_position_extra_info
     where  position_id      = p_position_id
     and    information_type = p_information_type;
 l_pos_cre_extra_info_id per_position_extra_info.position_extra_info_id%type;
 l_extra_info_id per_position_extra_info.position_extra_info_id%type;
 l_pos_cre_ovn per_position_extra_info.object_version_number%type;
 l_ovn per_position_extra_info.object_version_number%type;
 l_information_type per_position_extra_info.information_type%type;
BEGIN
-- Update/Create Position group1 Extra Info
--
-- EIT GHR_US_POS_GRP1
 IF ghr_utility.is_ghr_nfc = 'TRUE' THEN
  l_information_type := 'GHR_US_POS_GRP1';
  for pos_ei in c_pos_ei(p_position_id,l_information_type)
  LOOP
      l_extra_info_id := pos_ei.position_extra_info_id;
      l_ovn           := pos_ei.object_version_number;
      IF l_extra_info_id is NOT NULL THEN
	   hr_position_extra_info_api.update_position_extra_info
	  ( p_position_extra_info_id    =>    l_Extra_Info_Id
	  , p_object_version_number     =>    l_ovn
	  , p_poei_information3         =>    p_segment4);
      END IF;
  END LOOP;

--
-- EIT GHR_US_POS_VALID_GRADE
  l_information_type := 'GHR_US_POS_VALID_GRADE';
  for pos_ei in c_pos_ei(p_position_id,l_information_type)
  LOOP
      l_extra_info_id := pos_ei.position_extra_info_id;
      l_ovn           := pos_ei.object_version_number;
        IF l_extra_info_id is NOT NULL THEN
	   hr_position_extra_info_api.update_position_extra_info
	  ( p_position_extra_info_id    =>    l_Extra_Info_Id
	  , p_object_version_number     =>    l_ovn
	  , p_poei_information3         =>    p_segment7);
	 END IF;
  END LOOP;

--
-- EIT GHR_US_POS_GRP3;
  l_information_type := 'GHR_US_POS_GRP3';
  for pos_ei in c_pos_ei(p_position_id,l_information_type)
  LOOP
      l_extra_info_id := pos_ei.position_extra_info_id;
      l_ovn           := pos_ei.object_version_number;
       IF l_extra_info_id is NOT NULL THEN
	   hr_position_extra_info_api.update_position_extra_info
	  ( p_position_extra_info_id    =>    l_Extra_Info_Id
	  , p_object_version_number     =>    l_ovn
	  , p_poei_information21         =>    p_segment3);
	 END IF;
  END LOOP;


END IF; --  IF ghr_utility.is_ghr_nfc = 'TRUE' THEN

END update_nfc_eit;



  FUNCTION is_ghr RETURN VARCHAR2
  IS
    BEGIN
    -- DK 2002-11-08 PLSQLSTD
    -- hr_utility.set_location('Inside is_ghr' ,1);
    RETURN v_is_ghr;
  END;


  FUNCTION is_ghr_ben RETURN VARCHAR2
  IS
    BEGIN
    -- hr_utility.set_location('Inside is_ghr_ben' ,1);
    RETURN v_is_ghr_ben;
  END;


  FUNCTION is_ghr_ben_fehb RETURN VARCHAR2
  IS
    BEGIN
    -- hr_utility.set_location('Inside is_ghr_ben_fehb' ,1);
    RETURN v_is_ghr_ben_fehb;
  END;

  FUNCTION is_ghr_ben_tsp RETURN VARCHAR2
  IS
    BEGIN
    -- hr_utility.set_location('Inside is_ghr_ben_tsp' ,1);
    RETURN v_is_ghr_ben_tsp;
  END;

  FUNCTION is_ghr_nfc RETURN VARCHAR2
  IS
    BEGIN
    -- hr_utility.set_location('Inside is_ghr_ben' ,1);
    RETURN v_is_ghr_nfc;
  END;

PROCEDURE set_client_info
( p_person_id  in per_all_people_f.person_id%type default null,
  p_position_id in hr_all_positions_f.position_id%type default null,
  p_assignment_id in per_all_assignments_f.assignment_id%type default null)
is
cursor c_per_bus_group_id(p_person_id in per_all_people_f.person_id%TYPE) is
  select ppf.business_group_id
  from per_all_people_f ppf
  where ppf.person_id = p_person_id
  and trunc(sysdate) between ppf.effective_start_date
  and ppf.effective_end_date;
cursor c_pos_bus_group_id(p_position_id in hr_all_positions_f.position_id%TYPE ) is
  select pos.business_group_id
  from hr_all_positions_f pos  -- Venkat -- Position DT
  where pos.position_id = p_position_id
  and trunc(sysdate) between pos.effective_start_date
  and pos.effective_end_date;
cursor c_asg_bus_group_id(
           p_assignment_id in per_all_assignments_f.assignment_id%TYPE) is
  select asg.business_group_id
  from per_all_assignments_f asg
  where asg.assignment_id = p_assignment_id
  and trunc(sysdate) between asg.effective_start_date
  and asg.effective_end_date;
cursor cur_sec_grp(p_business_group_id in
     per_business_groups.business_group_id%TYPE) is
  select pbg.security_group_id
  from per_business_groups pbg
  where pbg.business_group_id =  p_business_group_id;
    v_current_sg NUMBER;
    l_bus_group_id per_business_groups.business_group_id%TYPE;
    l_security_group_id per_business_groups.security_group_id%TYPE;
begin
    v_current_sg := fnd_profile.value('PER_SECURITY_PROFILE_ID');
IF v_current_sg is not null then
  -- We can assume that either:
  --    a) the API is being called from a Form
  -- or b) the call has come from a SQLPlus session where
  --       fnd_global.apps_initialize has been called.
  --
  -- In either of these two cases client_info will have
  -- already been set so nothing extra needs to be done here.
  -- So can use HR_LOOKUPS for validation.
  null;
ELSE
  IF (p_person_id IS NOT NULL) OR
    (p_assignment_id IS NOT NULL) OR
    (p_position_id IS NOT NULL) THEN
    -- Derive the business_group_id from the known ID.
    -- Therefore can derive the security_group_id and
    -- set CLIENT_INFO by calling hr_api.set_security_group_id
    -- So can use HR_LOOKUPS for validation.
--  Getting Business Group Id
    IF p_person_id is not null then
      FOR c_per_bus_rec IN c_per_bus_group_id(p_person_id)
        LOOP
          l_bus_group_id := c_per_bus_rec.business_group_id;
          exit;
        END LOOP;
    ELSIF p_position_id is not null then
      FOR c_pos_bus_rec in c_pos_bus_group_id(p_position_id)
        LOOP
          l_bus_group_id := c_pos_bus_rec.business_group_id;
          exit;
        END LOOP;
    ELSIF p_assignment_id is not null then
      FOR c_asg_bus_rec in c_asg_bus_group_id(p_assignment_id)
        LOOP
          l_bus_group_id := c_asg_bus_rec.business_group_id;
          exit;
        END LOOP;
    END IF;
--  Getting Security_Group_Id
    FOR cur_sec_grp_rec in cur_sec_grp(l_bus_group_id)
      LOOP
        l_security_group_id := cur_sec_grp_rec.security_group_id;
        exit;
      END LOOP;
--  Set the Security Group Id in CLIENT_INFO
    hr_api.set_security_group_id(
      p_security_group_id => l_security_group_id
      );
ELSE
--Cannot derive a business group, so data must be held
-- outside of the context of a business group
-- Set CLIENT_INFO to zero by calling
-- hr_api.set_security_group_id.
-- So can use HR_LOOKUPS for validation.

-- Note1: CLIENT_INFO needs to be explicitly set to
-- zero because the same API may have previously been
-- called for a row where a business_group_id was derived.
-- As that business_group_id does not apply for the current
-- row CLIENT_INFO must be set to zero. This will cause
-- the HR_LOOKUPS view to act in the same way as
-- HR_STANDARD_LOOKUPS.
-- Note2: This should not interfere with any Forms processing
-- because this will only be done when the API call has NOT
-- come from a Form.
--
-- Set the Security Group Id in CLIENT_INFO  to 0
   hr_api.set_security_group_id(
      p_security_group_id => 0
      );
    END IF;
  END IF;
--    v_current_sg := fnd_profile.value('SECURITY_GROUP_ID');
end set_client_info;

FUNCTION get_noa_code (p_nature_of_action_id IN NUMBER)
RETURN VARCHAR2 AS
   l_noa_code  ghr_nature_of_actions.code%type;
   cursor c_noa_code is select code from ghr_nature_of_actions
        where nature_of_action_id= p_nature_of_action_id;
BEGIN
   open c_noa_code ;
   fetch c_noa_code into l_noa_code;
   close c_noa_code;
   RETURN(l_noa_code);
END;

procedure process_nfc_auth_date(
--p_person_id in per_people_f.person_id%type,
                  p_effective_date in ghr_pa_requests.effective_date%type,
                  p_pa_request_id  in ghr_pa_requests.pa_request_id%type)
is
cursor get_next_auth_date is
select nvl(max(fnd_date.canonical_to_date(rei_information3))+1,p_effective_date)
  authentication_date
  from ghr_pa_requests par, ghr_pa_request_extra_info rei
  where par.person_id in ( select  person_id from ghr_pa_requests where
   pa_request_id = p_pa_request_id )
  and par.effective_date = p_effective_date
  and par.pa_notification_id is not null
  and par.pa_request_id = rei.pa_request_id
  and rei.information_type = 'GHR_US_PAR_NFC_INFO';
 l_rei_rec   ghr_pa_request_extra_info%rowtype ;
 l_org_rec   ghr_pa_request_ei_shadow%rowtype;
begin
for c_ad_rec in get_next_auth_date loop
  l_rei_rec.information_type   :=  'GHR_US_PAR_NFC_INFO';
  l_rei_rec.pa_request_id      :=  p_pa_request_id;
  l_rei_rec.rei_information3   := fnd_date.date_to_canonical(c_ad_rec.authentication_date);
 GHR_NON_SF52_EXTRA_INFO.generic_populate_extra_info
                (p_rei_rec    =>  l_rei_rec,
                 p_org_rec    =>  l_org_rec,
                 p_flag       =>  'C'
                );
end loop;
end;

function  get_nfc_prev_noa(
p_person_id       in per_people_f.person_id%type,
p_pa_notification_id in ghr_pa_requests.pa_notification_id%type,
p_effective_date  in ghr_pa_requests.effective_date%type)
RETURN VARCHAR2
IS
CURSOR c_get_prev_details
is
select effective_date,first_noa_code,
           second_noa_code,pa_notification_id,pa_request_id
    from ghr_pa_requests
    where pa_notification_id is not null
    and person_id = p_person_id
    and pa_notification_id < p_pa_notification_id
    and effective_date <= p_effective_date
    and first_noa_code not in ('001') 	-- Exclude all cancellations
    and pa_request_id not in ( select altered_pa_request_id
       from ghr_pa_requests where
    pa_notification_id = p_pa_notification_id) -- Excludes original action
    order by pa_notification_id desc;
BEGIN
  FOR c_prev_rec in c_get_prev_details LOOP
    IF c_prev_rec.first_noa_code = '002' THEN
      RETURN c_prev_rec.second_noa_code;
    ELSE
      RETURN c_prev_rec.first_noa_code;
    END IF;
  END LOOP;
  RETURN NULL;
END;

procedure get_nfc_auth_codes(
p_person_id       in per_people_f.person_id%type,
p_pa_notification_id in ghr_pa_requests.pa_notification_id%type,
p_effective_date  in ghr_pa_requests.effective_date%type,
p_first_auth_code out nocopy  ghr_pa_requests.FIRST_ACTION_LA_CODE1%type,
p_second_auth_code out nocopy  ghr_pa_requests.FIRST_ACTION_LA_CODE1%type)
IS
cursor c_get_prev_details is
select effective_date,first_noa_code,
 first_action_la_code1,first_action_la_code2,
 second_action_la_code1,second_action_la_code2
    from ghr_pa_requests
    where pa_notification_id is not null
    and person_id = p_person_id
    and pa_notification_id < p_pa_notification_id
    and effective_date <= p_effective_date
    and first_noa_code not in ('001') 	-- Exclude all cancellations
    and pa_request_id not in ( select altered_pa_request_id
       from ghr_pa_requests where
    pa_notification_id = p_pa_notification_id) -- Excludes original action
    order by pa_notification_id desc;
BEGIN
  FOR c_prev_rec in c_get_prev_details LOOP
    IF nvl(c_prev_rec.first_noa_code,hr_api.g_varchar2) = '002' THEN
     p_first_auth_code := c_prev_rec.second_action_la_code1;
     p_second_auth_code := c_prev_rec.second_action_la_code2;
    ELSE
     p_first_auth_code := c_prev_rec.first_action_la_code1;
     p_second_auth_code := c_prev_rec.first_action_la_code2;
    END IF;
    EXIT;
  END LOOP;
EXCEPTION
  when others then
     -- NOCOPY changes
     -- Reset IN OUT params and set OUT params
    p_first_auth_code := null;
    p_second_auth_code := null;
    raise;
END;
function get_nfc_conv_action_code(
p_pa_request_id   in ghr_pa_requests.pa_request_id%type)
RETURN NUMBER
IS
cursor c_ex_emp is
select 'X'
from per_people_f per, per_person_types ppt, ghr_pa_requests par
where par.pa_request_id = p_pa_request_id
and per.person_id = par.person_id
and ppt.person_type_id = per.person_type_id
and ppt.system_person_type = 'EX_EMP'
and (par.effective_date - 1) between per.effective_start_date
and per.effective_end_date
and par.first_noa_code like '5%';

BEGIN
  FOR c_ex_emp_rec in c_ex_emp LOOP
    RETURN 1;
  END LOOP;
  RETURN 2;
END;


BEGIN
    v_is_ghr := 'TRUE';
    v_current_bg := fnd_profile.value('PER_BUSINESS_GROUP_ID');

    -- DK 2002-11-08 PLSQLSTD
    --hr_utility.set_location('Inside Main Begin' ,1);

    OPEN c_fed_bg(v_current_bg);
    FETCH c_fed_bg INTO r_fed_bg;
    IF c_fed_bg%NOTFOUND THEN
      v_is_ghr := 'FALSE';
    END IF;
    CLOSE c_fed_bg;

    v_is_ghr_ben := 'TRUE';

    OPEN c_ben_pgm(v_current_bg);
    FETCH c_ben_pgm INTO r_ben_pgm;
    IF c_ben_pgm%NOTFOUND THEN
      v_is_ghr_ben := 'FALSE';
    END IF;
    CLOSE c_ben_pgm;


    v_is_ghr_ben_fehb := 'TRUE';
    OPEN c_ben_pgm_fehb(v_current_bg);
    FETCH c_ben_pgm_fehb INTO r_ben_pgm_fehb;
    IF c_ben_pgm_fehb%NOTFOUND THEN
      v_is_ghr_ben_fehb := 'FALSE';
    END IF;
    CLOSE c_ben_pgm_fehb;


    v_is_ghr_ben_tsp := 'TRUE';
    OPEN c_ben_pgm_tsp(v_current_bg);
    FETCH c_ben_pgm_tsp INTO r_ben_pgm_tsp;
    IF c_ben_pgm_tsp%NOTFOUND THEN
      v_is_ghr_ben_tsp := 'FALSE';
    END IF;
    CLOSE c_ben_pgm_tsp;

    v_is_ghr_nfc := 'TRUE';

    OPEN c_fed_nfc(v_current_bg);
    FETCH c_fed_nfc INTO r_ben_nfc;
    IF c_fed_nfc%NOTFOUND THEN
      v_is_ghr_nfc := 'FALSE';
    END IF;
    CLOSE c_fed_nfc;

    -- DK 2002-11-08 PLSQLSTD
    --hr_utility.set_location('Leaving  Main Begin' ,1);

end ghr_utility;

/
