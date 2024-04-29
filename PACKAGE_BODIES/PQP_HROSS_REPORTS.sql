--------------------------------------------------------
--  DDL for Package Body PQP_HROSS_REPORTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_HROSS_REPORTS" AS
 /* $Header: pqphrossrpt.pkb 120.6 2006/01/05 04:14 nkkrishn noship $ */

-- =============================================================================
-- ~ Package Body Global variables:
-- =============================================================================
  g_debug                       BOOLEAN;
  g_pkg                CONSTANT VARCHAR2(150) := 'pqp_hross_reports.';

-- =============================================================================
-- ~ Compare_Values: Function to determine whether two strings are the same or
-- ~ different
-- =============================================================================
FUNCTION Compare_Values
         (p_parameter1     IN VARCHAR2
         ,p_parameter2    IN VARCHAR2
          ) RETURN Varchar2 IS
  l_parameter1             VARCHAR2(100);
  l_parameter2             VARCHAR2(100);
  l_return_status             VARCHAR2(5);
  l_proc_name      CONSTANT   VARCHAR2(150) := g_pkg||'Compare_Values';

BEGIN
  Hr_utility.set_location('Entering:' || l_proc_name, 10);

  IF p_parameter1 IS NOT NULL OR p_parameter2 IS NOT NULL THEN

    --remove blank spaces from in between
    SELECT REPLACE(p_parameter1, ' ') INTO l_parameter1 FROM DUAL;
    SELECT REPLACE(p_parameter2, ' ') INTO l_parameter2 FROM DUAL;

    IF l_parameter1 = l_parameter2 THEN
      l_return_status := '=';
    ELSE
      l_return_status := '<>';
      P_DATA_MISMATCH_FLAG := TRUE;
    END IF;
  END IF;
  RETURN l_return_status;

EXCEPTION
  WHEN OTHERS THEN
   Hr_Utility.set_location('Leaving:' || l_proc_name, 90);
   RETURN l_return_status;

END Compare_Values;

-- =============================================================================
-- ~ Before_Report_Trigger:
-- =============================================================================
PROCEDURE Before_Report_Trigger IS

   l_proc_name  CONSTANT    VARCHAR2(150):= g_pkg ||
                                           'Before_Report_Trigger';
   l_date_format            VARCHAR2(20);
   l_date_value             VARCHAR2(20);
BEGIN
   hr_utility.set_location('Entering: ' || l_proc_name, 10);

   --Set the value of person id where clause
   fnd_profile.get('ICX_DATE_FORMAT_MASK', l_date_format);

   GENERIC_WHERE :=  ' AND 1=1 ' ||
                     ' AND ppf.business_group_id LIKE (''' ||
                             P_BUSINESS_GROUP_ID || ''') ';

   IF P_PERSON_TYPE IS NOT NULL AND P_PERSON_TYPE <> ' ' THEN
      PERSON_TYPE_WHERE := ' AND ppt.person_type_id LIKE (''' ||
                           P_PERSON_TYPE || ''') ';
   END IF;
   IF P_ORGANIZATION_ID IS NOT NULL AND P_ORGANIZATION_ID <> ' ' THEN
      ORGANNIZATION_NAME_WHERE := ' AND paf.organization_id LIKE (''' ||
                                  P_ORGANIZATION_ID || ''') ';
   END IF;
   IF P_PAYROLL_ID IS NOT NULL AND P_PAYROLL_ID <> ' ' THEN
      PAYROLL_NAME_WHERE := ' AND paf.payroll_id LIKE (''' ||
                            P_PAYROLL_ID || ''') ';
   END IF;
   IF P_LOCATION_ID IS NOT NULL AND P_LOCATION_ID <> ' ' THEN
      LOCATION_NAME_WHERE := ' AND paf.location_id LIKE (''' ||
                             P_LOCATION_ID || ''') ';
   END IF;
   IF P_LAST_NAME IS NOT NULL AND P_LAST_NAME <> ' ' THEN
      LAST_NAME_WHERE := ' AND lower(ppf.last_name) LIKE LOWER(''' ||
                         P_LAST_NAME || ''') ';
   END IF;

   IF P_FIRST_NAME IS NOT NULL AND P_FIRST_NAME <> ' '  THEN
      FIRST_NAME_WHERE := ' AND lower(ppf.first_name) LIKE LOWER(''' ||
                          P_FIRST_NAME || ''') ';
   END IF;

   IF P_NATIONAL_IDENTIFIER IS NOT NULL AND P_NATIONAL_IDENTIFIER <> ' ' THEN
      NATIONAL_IDENTIFIER_WHERE := ' AND ppf.national_identifier ' ||
                          ' LIKE (''' || P_NATIONAL_IDENTIFIER || ''') ';
   END IF;

   IF P_STUDENT_NUMBER IS NOT NULL AND P_STUDENT_NUMBER <> ' ' THEN
      STUDENT_NUMBER_WHERE := ' AND ipe.person_number LIKE (''' ||
                              P_STUDENT_NUMBER || ''') ';
   END IF;
   IF P_PERSON_ID_GROUP_QUERY IS NOT NULL AND
                                          P_PERSON_ID_GROUP_QUERY <> ' ' THEN
      PERSON_ID_GROUP_QUERY_WHERE := ' AND ppf.party_id IN ' ||
                                     P_PERSON_ID_GROUP_QUERY ;
   END IF;
   PERSON_ID_LIST_WHERE :=  GENERIC_WHERE || PERSON_TYPE_WHERE ||
                            ORGANNIZATION_NAME_WHERE || PAYROLL_NAME_WHERE ||
                            LOCATION_NAME_WHERE || LAST_NAME_WHERE ||
			    FIRST_NAME_WHERE || NATIONAL_IDENTIFIER_WHERE ||
			    STUDENT_NUMBER_WHERE || PERSON_ID_GROUP_QUERY_WHERE;

   --Set the value of end date check where clause
   PERSON_END_DATE_WHERE := ' AND ppf.effective_end_date = (SELECT max(ppf1.effective_end_date) ' ||
                                                              ' FROM per_people_f ppf1, per_person_types ppt1 ' ||
                                                             ' WHERE (to_date(''' || P_EFFECTIVE_START_DATE || ''', ''' || l_date_format || ''') between paf.effective_start_date and paf.effective_end_date ' ||
                                                                 ' OR to_date(''' || P_EFFECTIVE_END_DATE || ''', ''' || l_date_format || ''') between paf.effective_start_date and paf.effective_end_date ) ' ||
                                                               ' AND ppf1.person_id = ppf.person_id ' ||
							       ' AND ppf1.person_type_id = ppt1.person_type_id ' ||
                                                               ' AND ppt1.system_person_type in (''EMP'', ''EMP_APL'') ' ||
     							       ' AND ppt1.active_flag = ''Y'') ';

--   PERSON_END_DATE_WHERE2 := ' AND to_date(''' || P_EFFECTIVE_END_DATE || ''', ''' || l_date_format || ''') between ppf.effective_start_date and ppf.effective_end_date ';
   ASSIGNMENT_END_DATE_WHERE := ' AND (to_date(''' || P_EFFECTIVE_START_DATE || ''', ''' || l_date_format || ''') between paf.effective_start_date and paf.effective_end_date ' ||
                                     ' OR to_date(''' || P_EFFECTIVE_END_DATE || ''', ''' || l_date_format || ''') between paf.effective_start_date and paf.effective_end_date )';
   ADDRESS_END_DATE_WHERE := ' AND to_date(''' || P_EFFECTIVE_END_DATE || ''', ''' || l_date_format || ''') between  per.date_from(+) and nvl(per.date_to(+), to_date(''' || P_EFFECTIVE_END_DATE || ''', ''' || l_date_format || ''')) ';

   --Set the value of order by clause
   ORDER_BY_CLAUSE := 'ORDER BY MismatchIndicatorFlag DESC, UPPER(LastName), UPPER(FirstName), NationalIdentifier';
   IF P_SORT_BY = 'STU_LNM' THEN
      ORDER_BY_CLAUSE := 'ORDER BY UPPER(LastName), UPPER(FirstName), NationalIdentifier';
   END IF;
   IF P_SORT_BY = 'STU_NID' THEN
      ORDER_BY_CLAUSE := 'ORDER BY NationalIdentifier'; --Should be unique, so no need of secondary sort column
   END IF;
   IF P_SORT_BY = 'STU_NUM' THEN
      ORDER_BY_CLAUSE := 'ORDER BY StudentNumber'; --Should be unique, so no need of secondary sort column
   END IF;

   --Set the value of data mismatch flag to false
   P_DATA_MISMATCH_FLAG := FALSE;
   MATCHING_RECORDS_COUNTER := 0;
   MISMATCH_RECORDS_COUNTER := 0;

   hr_utility.set_location('Leaving: ' || l_proc_name, 20);

END Before_Report_Trigger;

-- =============================================================================
-- ~ Before_Report_Trigger:
-- =============================================================================
FUNCTION Before_Report_Trigger RETURN BOOLEAN IS

   l_proc_name  CONSTANT    VARCHAR2(150):= g_pkg ||
                                           'Before_Report_Trigger';
   l_date_format            VARCHAR2(20);
   l_date_value             VARCHAR2(20);
BEGIN
   hr_utility.set_location('Entering: ' || l_proc_name, 10);

   --Set the value of person id where clause
   fnd_profile.get('ICX_DATE_FORMAT_MASK', l_date_format);

   GENERIC_WHERE :=  ' AND 1=1 ';

   IF P_PERSON_TYPE IS NOT NULL AND P_PERSON_TYPE <> ' ' THEN
      PERSON_TYPE_WHERE := ' AND ppt.person_type_id LIKE (''' ||
                           P_PERSON_TYPE || ''') ';
   END IF;
   IF P_ORGANIZATION_ID IS NOT NULL AND P_ORGANIZATION_ID <> ' ' THEN
      ORGANNIZATION_NAME_WHERE := ' AND paf.organization_id LIKE (''' ||
                                  P_ORGANIZATION_ID || ''') ';
   END IF;
   IF P_PAYROLL_ID IS NOT NULL AND P_PAYROLL_ID <> ' ' THEN
      PAYROLL_NAME_WHERE := ' AND paf.payroll_id LIKE (''' ||
                            P_PAYROLL_ID || ''') ';
   END IF;
   IF P_LOCATION_ID IS NOT NULL AND P_LOCATION_ID <> ' ' THEN
      LOCATION_NAME_WHERE := ' AND paf.location_id LIKE (''' ||
                             P_LOCATION_ID || ''') ';
   END IF;
   IF P_LAST_NAME IS NOT NULL AND P_LAST_NAME <> ' ' THEN
      LAST_NAME_WHERE := ' AND lower(ppf.last_name) LIKE LOWER(''' ||
                         P_LAST_NAME || ''') ';
   END IF;

   IF P_FIRST_NAME IS NOT NULL AND P_FIRST_NAME <> ' '  THEN
      FIRST_NAME_WHERE := ' AND lower(ppf.first_name) LIKE LOWER(''' ||
                          P_FIRST_NAME || ''') ';
   END IF;

   IF P_NATIONAL_IDENTIFIER IS NOT NULL AND P_NATIONAL_IDENTIFIER <> ' ' THEN
      NATIONAL_IDENTIFIER_WHERE := ' AND ppf.national_identifier ' ||
                          ' LIKE (''' || P_NATIONAL_IDENTIFIER || ''') ';
   END IF;

   IF P_STUDENT_NUMBER IS NOT NULL AND P_STUDENT_NUMBER <> ' ' THEN
      STUDENT_NUMBER_WHERE := ' AND ipe.person_number LIKE (''' ||
                              P_STUDENT_NUMBER || ''') ';
   END IF;
   IF P_PERSON_ID_GROUP_QUERY IS NOT NULL AND
                                          P_PERSON_ID_GROUP_QUERY <> ' ' THEN
      PERSON_ID_GROUP_QUERY_WHERE := ' AND ppf.party_id IN ' ||
                                     P_PERSON_ID_GROUP_QUERY ;
   END IF;
   PERSON_ID_LIST_WHERE :=  GENERIC_WHERE || PERSON_TYPE_WHERE ||
                            ORGANNIZATION_NAME_WHERE || PAYROLL_NAME_WHERE ||
                            LOCATION_NAME_WHERE || LAST_NAME_WHERE ||
			    FIRST_NAME_WHERE || NATIONAL_IDENTIFIER_WHERE ||
			    STUDENT_NUMBER_WHERE || PERSON_ID_GROUP_QUERY_WHERE;

   --Set the value of end date check where clause
   PERSON_END_DATE_WHERE := ' AND ppf.effective_end_date = (SELECT max(ppf1.effective_end_date) ' ||
                                                              ' FROM per_people_f ppf1, per_person_types ppt1 ' ||
                                                             ' WHERE (to_date(''' || P_EFFECTIVE_START_DATE || ''', ''' || l_date_format || ''') between paf.effective_start_date and paf.effective_end_date ' ||
                                                                 ' OR to_date(''' || P_EFFECTIVE_END_DATE || ''', ''' || l_date_format || ''') between paf.effective_start_date and paf.effective_end_date ) ' ||
                                                               ' AND ppf1.person_id = ppf.person_id ' ||
							       ' AND ppf1.person_type_id = ppt1.person_type_id ' ||
                                                               ' AND ppt1.system_person_type in (''EMP'', ''EMP_APL'') ' ||
     							       ' AND ppt1.active_flag = ''Y'') ';


--   PERSON_END_DATE_WHERE2 := ' AND to_date(''' || P_EFFECTIVE_END_DATE || ''', ''' || l_date_format || ''') between ppf.effective_start_date and ppf.effective_end_date ';
   ASSIGNMENT_END_DATE_WHERE := ' AND (to_date(''' || P_EFFECTIVE_END_DATE || ''', ''' || l_date_format || ''') between paf.effective_start_date and paf.effective_end_date ' ||
                                 ' OR  to_date(''' || P_EFFECTIVE_START_DATE || ''', ''' || l_date_format || ''') between paf.effective_start_date and paf.effective_end_date) ';
   ADDRESS_END_DATE_WHERE := ' AND to_date(''' || P_EFFECTIVE_END_DATE || ''', ''' || l_date_format || ''') between  per.date_from(+) and nvl(per.date_to(+), to_date(''' || P_EFFECTIVE_END_DATE || ''', ''' || l_date_format || ''')) ';

   --Set the value of order by clause
   ORDER_BY_CLAUSE := 'ORDER BY MismatchIndicatorFlag DESC, UPPER(LastName), UPPER(FirstName), NationalIdentifier';
   IF P_SORT_BY = 'STU_LNM' THEN
      ORDER_BY_CLAUSE := 'ORDER BY UPPER(LastName), UPPER(FirstName), NationalIdentifier';
   END IF;
   IF P_SORT_BY = 'STU_NID' THEN
      ORDER_BY_CLAUSE := 'ORDER BY NationalIdentifier'; --Should be unique, so no need of secondary sort column
   END IF;
   IF P_SORT_BY = 'STU_NUM' THEN
      ORDER_BY_CLAUSE := 'ORDER BY StudentNumber'; --Should be unique, so no need of secondary sort column
   END IF;

   --Set the value of data mismatch flag to false
   P_DATA_MISMATCH_FLAG := FALSE;
   MATCHING_RECORDS_COUNTER := 0;
   MISMATCH_RECORDS_COUNTER := 0;

   hr_utility.set_location('Leaving: ' || l_proc_name, 20);
   RETURN TRUE;
END Before_Report_Trigger;

-- =============================================================================
-- ~ Generate_Report:
-- =============================================================================
PROCEDURE Generate_Report
         (p_person_id_group_query  IN VARCHAR2
         ,p_business_group_name    IN VARCHAR2
         ,p_business_group_id      IN VARCHAR2
         ,p_effective_start_date   IN VARCHAR2
         ,p_effective_end_date     IN VARCHAR2
         ,p_person_type            IN VARCHAR2
         ,p_person_type_desc       IN VARCHAR2
         ,p_organization_name      IN VARCHAR2
         ,p_organization_id        IN VARCHAR2
         ,p_payroll_name           IN VARCHAR2
         ,p_payroll_id             IN VARCHAR2
         ,p_location_value         IN VARCHAR2
         ,p_location_id            IN VARCHAR2
         ,p_person_id_group        IN VARCHAR2
         ,p_last_name              IN VARCHAR2
         ,p_first_name             IN VARCHAR2
         ,p_national_identifier    IN VARCHAR2
         ,p_student_number         IN VARCHAR2
         ,p_template_code          IN VARCHAR2
         ,p_template_lang          IN VARCHAR2
         ,p_template_ter           IN VARCHAR2
         ,p_output_format          IN VARCHAR2
         ,p_report_name            IN VARCHAR2
         ,p_data_match_filter      IN VARCHAR2
         ,p_report_run_date        IN VARCHAR2
         ,p_data_match_filter_desc IN VARCHAR2
         ,p_sort_by                IN VARCHAR2
         ,p_sort_by_desc           IN VARCHAR2
         ,p_return_status          IN OUT NOCOPY VARCHAR2) AS
   l_proc_name  CONSTANT    VARCHAR2(150):= g_pkg ||
                                           'Generate_Report';
   l_request_id             NUMBER;
   l_layout_flag            BOOLEAN;
BEGIN
   hr_utility.set_location('Entering: ' || l_proc_name, 10);

   l_layout_flag := fnd_request.add_layout(template_appl_name => 'PQP'
                                          ,template_code      => p_template_code
                                          ,template_language  => p_template_lang
                                          ,template_territory => p_template_ter
                                          ,output_format      => p_output_format);

   l_request_id := fnd_request.submit_request(application => 'PQP'
                                             ,program     => 'PQPCMPRPT'
					     ,description => p_report_name
                                             ,argument1   => p_person_id_group_query
                                             ,argument2   => p_business_group_name
                                             ,argument3   => p_business_group_id
                                             ,argument4   => p_effective_start_date
                                             ,argument5   => p_effective_end_date
                                             ,argument6   => p_person_type
                                             ,argument7   => p_person_type_desc
					     ,argument8   => p_organization_name
					     ,argument9   => p_organization_id
					     ,argument10  => p_payroll_name
					     ,argument11  => p_payroll_id
					     ,argument12  => p_location_value
					     ,argument13  => p_location_id
					     ,argument14  => p_person_id_group
					     ,argument15  => p_last_name
					     ,argument16  => p_first_name
					     ,argument17  => p_national_identifier
					     ,argument18  => p_student_number
					     ,argument19  => p_report_name
					     ,argument20  => p_data_match_filter
					     ,argument21  => p_report_run_date
					     ,argument22  => p_data_match_filter_desc
					     ,argument23  => p_sort_by
					     ,argument24  => p_sort_by_desc);

   COMMIT;
   p_return_status := l_request_id;

   hr_utility.set_location ('Request Id:' || l_request_id ,20);
   hr_utility.set_location('Leaving: ' || l_proc_name, 30);

END Generate_Report;

-- =============================================================================
-- ~ Get_Date: Get Date field in session format
-- =============================================================================
FUNCTION Get_Date(p_date IN DATE) RETURN VARCHAR2 IS
  l_return_value             VARCHAR2(20);
  l_date_format              VARCHAR2(20);
BEGIN
  fnd_profile.get('ICX_DATE_FORMAT_MASK', l_date_format);
  SELECT to_char(fnd_date.canonical_to_date(fnd_date.date_to_canonical(p_date)), l_date_format) into l_return_value FROM dual;
  RETURN l_return_value;
END Get_Date;

-- =============================================================================
-- ~ Get_Count: Function to return the count of matching and mismatching records
-- =============================================================================
Function Get_Count(p_parameter  IN VARCHAR2) RETURN VARCHAR2 IS
  l_return_value             VARCHAR2(20);
BEGIN
  IF p_parameter = 'MATCH_COUNT' THEN
    l_return_value := MATCHING_RECORDS_COUNTER;
  END IF;
  IF p_parameter = 'MISMATCH_COUNT' THEN
    l_return_value := MISMATCH_RECORDS_COUNTER;
  END IF;
  IF p_parameter = 'TOTAL_COUNT' THEN
    l_return_value := MATCHING_RECORDS_COUNTER + MISMATCH_RECORDS_COUNTER;
  END IF;
  RETURN l_return_value;
END Get_Count;


-- =============================================================================
-- ~ Get_Mismatch_Indicator_Flag: Function to return Mismatch Indicator Flag
-- =============================================================================
FUNCTION Get_Mismatch_Indicator_Flag RETURN VARCHAR2 IS
  l_return_value             VARCHAR2(1);
BEGIN
  IF P_DATA_MISMATCH_FLAG THEN
     l_return_value := 'Y';
     MISMATCH_RECORDS_COUNTER := MISMATCH_RECORDS_COUNTER + 1;
  ELSE
     l_return_value := 'N';
     MATCHING_RECORDS_COUNTER := MATCHING_RECORDS_COUNTER + 1;
  END IF;
  P_DATA_MISMATCH_FLAG := FALSE;
  RETURN l_return_value;
END Get_Mismatch_Indicator_Flag;

-- =============================================================================
-- ~ Record_Filter: Function to return Mismatch Indicator Flag
-- =============================================================================
FUNCTION Record_Filter(p_mismatch_indicator_flag  IN VARCHAR2
                      ,p_full_name  IN VARCHAR2) RETURN BOOLEAN IS
  l_return_value             BOOLEAN;
BEGIN

  IF P_DATA_MATCH_FILTER = 'ALL_RECORDS' THEN
     RETURN TRUE;
  END IF;
  IF P_DATA_MATCH_FILTER = 'MATCHING_RECORDS' THEN
     IF p_mismatch_indicator_flag = 'Y' THEN
        RETURN FALSE;
     ELSE
        RETURN TRUE;
     END IF;
  END IF;

  IF P_DATA_MATCH_FILTER = 'MISMATCH_RECORDS' THEN
     IF p_mismatch_indicator_flag = 'Y' THEN
        RETURN TRUE;
     ELSE
        RETURN FALSE;
     END IF;
  END IF;
END Record_Filter;

-- =============================================================================
-- ~ Get_Primary_Telephone_Number: Returns the primary telephone number
-- =============================================================================
Function Get_Primary_Telephone_Number(p_owner_table_id IN VARCHAR2) RETURN VARCHAR2 IS

   -- Cursor to get the primary telephone number
  CURSOR csr_pri_telephone_num (c_owner_table_id IN VARCHAR2) IS
  SELECT phone_country_code, phone_area_code, phone_number, phone_extension
    FROM hz_contact_points
   WHERE owner_table_id = c_owner_table_id
     AND phone_line_type = 'GEN'
     AND primary_flag = 'Y';

  l_primary_return_value             VARCHAR2(50);
  l_primary_country_code             hz_contact_points.phone_country_code%TYPE;
  l_primary_area_code                hz_contact_points.phone_area_code%TYPE;
  l_primary_phone_number             hz_contact_points.phone_number%TYPE;
  l_primary_phone_extn               hz_contact_points.phone_extension%TYPE;
BEGIN

  IF (csr_pri_telephone_num%ISOPEN) THEN
    CLOSE csr_pri_telephone_num;
  END IF;

  OPEN  csr_pri_telephone_num (c_owner_table_id => p_owner_table_id);
  FETCH csr_pri_telephone_num
    INTO l_primary_country_code, l_primary_area_code, l_primary_phone_number, l_primary_phone_extn;
  --Return blank if no primary telephone number found
  IF csr_pri_telephone_num%NOTFOUND THEN
     CLOSE csr_pri_telephone_num;
     RETURN ' ';
  END IF;
  CLOSE csr_pri_telephone_num;


  --Else, return the telephone number in correct format
  l_primary_return_value := ' ';
  IF l_primary_country_code IS NOT NULL THEN
--    l_primary_return_value := '+' || l_primary_country_code;
    l_primary_return_value := l_primary_country_code;
  END IF;
  IF l_primary_area_code IS NOT NULL THEN
--    l_primary_return_value := l_primary_return_value || ' (' || l_primary_area_code || ')';
    l_primary_return_value := l_primary_return_value || ' ' || l_primary_area_code;
  END IF;
  IF l_primary_phone_number IS NOT NULL THEN
    l_primary_return_value := l_primary_return_value || ' ' || l_primary_phone_number;
  END IF;
  IF l_primary_phone_extn IS NOT NULL THEN
--    l_primary_return_value := l_primary_return_value || ' x ' || l_primary_phone_extn;
    l_primary_return_value := l_primary_return_value || ' ' || l_primary_phone_extn;
  END IF;

  RETURN l_primary_return_value;

END Get_Primary_Telephone_Number;


-- =============================================================================
-- ~ Get_Secondary_Telephone_Number: Returns the secondary telephone number
-- =============================================================================
Function Get_Secondary_Telephone_Number(p_owner_table_id IN VARCHAR2) RETURN VARCHAR2 IS

   -- Cursor to get the secondary telephone number
  CURSOR csr_sec_telephone_num (c_owner_table_id IN VARCHAR2) IS
  SELECT phone_country_code, phone_area_code, phone_number, phone_extension
    FROM hz_contact_points
   WHERE owner_table_id = c_owner_table_id
     AND phone_line_type = 'GEN'
     AND primary_flag <> 'Y'
     AND creation_date = (SELECT MAX(creation_date)
                           FROM hz_contact_points
                          WHERE owner_table_id = c_owner_table_id
		            AND phone_line_type = 'GEN'
			    AND primary_flag <> 'Y');

  l_secondary_return_value             VARCHAR2(50);
  l_secondary_country_code             hz_contact_points.phone_country_code%TYPE;
  l_secondary_area_code                hz_contact_points.phone_area_code%TYPE;
  l_secondary_phone_number             hz_contact_points.phone_number%TYPE;
  l_secondary_phone_extn               hz_contact_points.phone_extension%TYPE;
BEGIN

  IF (csr_sec_telephone_num%ISOPEN) THEN
    CLOSE csr_sec_telephone_num;
  END IF;

  OPEN  csr_sec_telephone_num (c_owner_table_id => p_owner_table_id);
  FETCH csr_sec_telephone_num
     INTO l_secondary_country_code, l_secondary_area_code, l_secondary_phone_number, l_secondary_phone_extn;
  --Return blank if no secondary telephone number found
  IF csr_sec_telephone_num%NOTFOUND THEN
     CLOSE csr_sec_telephone_num;
     RETURN ' ';
  END IF;
  CLOSE csr_sec_telephone_num;

  --Else, return the telephone number in correct format
  l_secondary_return_value := ' ';
  IF l_secondary_country_code IS NOT NULL THEN
--    l_secondary_return_value := '+' || l_secondary_country_code;
    l_secondary_return_value := l_secondary_country_code;
  END IF;
  IF l_secondary_area_code IS NOT NULL THEN
--    l_secondary_return_value := l_secondary_return_value || ' (' || l_secondary_area_code || ')';
    l_secondary_return_value := l_secondary_return_value || ' ' || l_secondary_area_code;
  END IF;
  IF l_secondary_phone_number IS NOT NULL THEN
    l_secondary_return_value := l_secondary_return_value || ' ' || l_secondary_phone_number;
  END IF;
  IF l_secondary_phone_extn IS NOT NULL THEN
--    l_secondary_return_value := l_secondary_return_value || ' x ' || l_secondary_phone_extn;
    l_secondary_return_value := l_secondary_return_value || ' ' || l_secondary_phone_extn;
  END IF;

  RETURN l_secondary_return_value;

END Get_Secondary_Telephone_Number;

END pqp_hross_reports;

/
