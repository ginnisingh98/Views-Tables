--------------------------------------------------------
--  DDL for Package Body PQH_FR_STAT_SIT_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_FR_STAT_SIT_UTIL" As
/* $Header: pqstsutl.pkb 120.0 2005/05/29 02:43 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pqh_fr_stat_sit_util.';  -- Global package name.
g_debug boolean := hr_utility.debug_enabled;
--
-- ----------------------------------------------------------------------------
FUNCTION  Is_input_is_valid(p_txn_category_attribute_id NUMBER, p_from_value varchar2 ) return varchar2
IS
-- Declare Cursors
--
l_proc  varchar2(72) := g_package||'get_txn_catg_attr_meaning';
l_txn_category_attribute_id number := null;
l_from_value varchar2(1000) := null;
l_query varchar2(3000) := null;
l_Addl_where_clause varchar2(1000) := null;
l_result varchar2(1000) := null;
l_to_value varchar2(1000) := null;
l_value varchar2(1000) := null;
--
begin
       -- Get the Query out of Tranasaction Category Id
       l_query := get_txn_value_query(p_txn_category_attribute_id);
       if (l_query = 'select null Id, null Val,null Att_Name from dual Where 1 = 2' ) then
         return 'Y';
       End if;
       l_Addl_where_clause := ' Where Id = :1';
       l_value := p_from_value;
       l_query := 'Select Val From ('|| l_query ||' ) '|| l_Addl_where_clause;
        begin
             Execute Immediate l_query into l_result using l_value;
        exception
             when no_data_found then
              l_result := null;
        end ;
        if (l_result is null) then
         return 'N';
        else
         return 'Y';
        end if;
end ;
--
Function get_txn_catg_attr_meaning(p_stat_situation_rule_id NUMBER, p_value_for VARCHAR2 DEFAULT 'FROM')
RETURN VARCHAR2
IS
--
-- Declare Cursors
--
Cursor csr_get_situation_rule IS
Select txn_category_attribute_id, from_value , to_value
from pqh_fr_stat_situation_rules
where stat_situation_rule_id = p_stat_situation_rule_id;
--
-- Declare Local Variables
--
l_proc  varchar2(72) := g_package||'get_txn_catg_attr_meaning';
l_txn_category_attribute_id number := null;
l_from_value varchar2(1000) := null;
l_query varchar2(3000) := null;
l_Addl_where_clause varchar2(1000) := null;
l_result varchar2(1000) := null;
l_to_value varchar2(1000) := null;
l_value varchar2(1000) := null;
--
begin
    g_debug := hr_utility.debug_enabled;
     if g_debug then
     --
     hr_utility.set_location(' Entering:'||l_proc, 1);
     --
     End if;
      -- Get the current row from situation rules
      -- Get the txn_vlue_query out of txn id
      -- Attach where clause for Id column in result query with from value
      -- If query results none , return from_value
       Open csr_get_situation_rule ;
       --
       Fetch csr_get_situation_rule into l_txn_category_attribute_id, l_from_value,l_to_value;
       --
       Close csr_get_situation_rule;
       -- Get the Query out of Tranasaction Category Id
       l_query := get_txn_value_query(l_txn_category_attribute_id);
       if (p_value_for = 'TO') then
        --
         l_Addl_where_clause := ' Where Id = :1 ';
         l_value := l_to_value;
        --
       else
         --
         l_Addl_where_clause := ' Where Id = :1';
         l_value := l_from_value;
         --
       end if;
       l_query := 'Select Val From ('|| l_query ||' ) '|| l_Addl_where_clause;
        begin
             Execute Immediate l_query into l_result using l_value;
        exception
             when no_data_found then
              l_result := null;
        end ;
         If (l_result is null) Then
        --
        -- Its a RANGE Style Attribute
        --
          if (p_value_for ='TO') then
             l_result := l_to_value;
          else
             l_result := l_from_value;
          end if;
        --
        End if;
     If g_debug then
     --
     hr_utility.set_location(' Leaving:'||l_proc, 1);
     --
     End if;
return l_result;
end get_txn_catg_attr_meaning;
--
FUNCTION GET_TXN_VALUE_QUERY (p_txn_category_attribute_id NUMBER)
RETURN VARCHAR2
IS
--
--
Cursor csr_get_txn_record IS
Select value_style_cd, value_set_id
from pqh_txn_category_attributes
where txn_category_attribute_id = p_txn_category_attribute_id;
--
--
l_query varchar2(5000) := 'select null Id, null Val,null Att_Name from dual Where 1 = 2';
l_value_style_cd pqh_txn_category_attributes.value_style_cd%type;
l_value_set_id   pqh_txn_category_attributes.value_set_id%type;
l_ret varchar2(10);
l_validation_type varchar2(10);
--
begin
       -- Open the cursor and get value_set_id
         Open csr_get_txn_record ;
           --
             Fetch csr_get_txn_record into l_value_style_cd, l_value_set_id;
            --
         Close csr_get_txn_record;
         -- Check value style CD is EXACT / RANGE
           If (l_value_style_cd = 'EXACT') Then
            --
              pqh_utility.get_valueset_sql
                    (p_value_set_id     => l_value_set_id,
                        p_validation_type => l_validation_type,
                        p_sql_stmt     => l_query,
                        p_error_status    => l_ret) ;
             --
           End if;
return l_query;
--
end GET_TXN_VALUE_QUERY;
--
--
FUNCTION RULES_EXIST(p_stat_situation_id NUMBER)
RETURN VARCHAR2
IS
--
--
Cursor csr_rules_list IS
Select null
from pqh_fr_stat_situation_rules
where statutory_situation_id = p_stat_situation_id;
--
l_value varchar2(1);
l_return varchar2(10) := 'Y';
Begin
         Open csr_rules_list;
          ---
           Fetch csr_rules_list into l_value;
           if csr_rules_list%NOTFOUND then
               l_return := 'N';
           end if;
          ---
          close csr_rules_list;
   return l_return;
End  rules_exist;
--
   /* following functions are added for transaction attributes processing   */

    Function get_los_in_ps  ( p_person_id IN    NUMBER default NULL,
                              p_determination_date  IN    DATE default NULL)
                              return number
    IS
       cursor csr_person_info is
       select business_group_id
       from per_all_people_f where
       person_id = p_person_id
       and p_determination_date between effective_start_date and effective_end_date;

       l_bg_id number;

    begin
           open csr_person_info;
           fetch csr_person_info into l_bg_id;
           close csr_person_info;

         	return pqh_length_of_service_pkg.get_length_of_service(l_bg_id, p_person_id,
                                 NULL, '20', 'M', p_determination_date);
     end;

    Function get_general_los (p_person_id IN    NUMBER default NULL,
                              p_determination_date  IN    DATE default NULL)
                              return number
    IS
       cursor csr_person_info is
       select business_group_id
       from per_all_people_f where
       person_id = p_person_id
       and p_determination_date between effective_start_date and effective_end_date;

       l_bg_id number;
    begin
           open csr_person_info;
           fetch csr_person_info into l_bg_id;
           close csr_person_info;

           	return pqh_length_of_service_pkg.get_length_of_service(l_bg_id, p_person_id,
                                 NULL, '10', 'M', p_determination_date);

    end;

    Function get_employee_type (p_person_id  IN per_all_people_f.person_id%TYPE,
                            p_determination_date IN DATE) return varchar2
    IS
    Cursor csr_emp_type is
    SELECT scl.segment10 emp_type
    FROM   per_all_assignments_f asg,
           hr_soft_coding_keyflex scl
    WHERE asg.soft_coding_keyflex_id = scl.soft_coding_keyflex_id
    AND   person_id = p_person_id
    AND p_determination_date between effective_start_date and effective_end_date
    AND primary_flag = 'Y';

    l_emp_type varchar2(2);
    begin
        open csr_emp_type;
        fetch csr_emp_type into l_emp_type;
        close csr_emp_type;

        return l_emp_type;

    end;

    Function get_situation_type (p_person_id  IN per_all_people_f.person_id%TYPE,
                            p_determination_date IN DATE) return varchar2
    IS
    cursor csr_situation_info is
    select ss.situation_type, ss.situation_name, ss.situation_type_name
    from PQH_FR_EMP_STAT_SITUATIONS ess, PQH_FR_STAT_SITUATIONS_V   ss
    where ess.Statutory_situation_id = ss.Statutory_situation_id
    and   ess.person_id = p_person_id
    and   p_determination_date between ess.actual_start_date and nvl(ess.actual_end_date, ess.provisional_end_date);

    l_situation_type pqh_fr_stat_situations_v.situation_type%TYPE ;
    l_situation_name pqh_fr_stat_situations_v.situation_name%TYPE ;
    l_situation_type_name pqh_fr_stat_situations_v.situation_type_name%TYPE ;

    begin
              open csr_situation_info;
              fetch csr_situation_info into l_situation_type, l_situation_name, l_situation_type_name;
              close csr_situation_info;

              return l_situation_type;
    end;

    Function get_relationship_type (p_person_id  IN per_all_people_f.person_id%TYPE,
                            p_determination_date IN DATE) return varchar2
    IS
    begin
        	return null;
    end;

    Function get_dependent_age (p_person_id  IN per_all_people_f.person_id%TYPE,
                            p_determination_date IN DATE) return number
    IS
    l_dependent_cnt number;
    l_dependent_dob date;
    l_dependent_age number;

    begin
       select count(1) into l_dependent_cnt
       from per_contact_relationships
       where person_id = p_person_id
       and p_determination_date between date_start and nvl(date_end,hr_general.end_of_time);
       if l_dependent_cnt = 0 then
           return null;
       else
          select max(date_of_birth) into l_dependent_dob
          from per_all_people_f
          where person_id in (select contact_person_id
                              from per_contact_relationships
                              where person_id = p_person_id
                              and p_determination_date between date_start and nvl(date_end,hr_general.end_of_time));
          l_dependent_age := Months_Between(p_determination_date,l_dependent_dob)/12;
          return l_dependent_age;
       end if;
    end;
--
--Changes for Employee Statutory Situation Placement
  FUNCTION is_situation_renewable(p_emp_stat_situation_id  NUMBER,
                                  p_statutory_situation_id NUMBER) RETURN VARCHAR2 IS
  --
    CURSOR csr_renewable(p_statutory_situation_id NUMBER) IS
    SELECT NVL(renewable_allowed,'N'),NVL(max_no_of_renewals,0)
      FROM pqh_fr_stat_situations
     WHERE statutory_situation_id = p_statutory_situation_id;
  --
    l_renewable Varchar2(10);
    l_max_renewals NUMBER(10) := 0;
    l_no_of_renewals NUMBER(10) := 0;
  BEGIN
  --
    OPEN csr_renewable(p_statutory_situation_id);
    FETCH csr_renewable INTO l_renewable,l_max_renewals;
    CLOSE csr_renewable;
  --
    IF l_renewable = 'N' OR l_max_renewals = '0' THEN
       RETURN 'NO';
    END IF;
  --
    l_no_of_renewals := get_number_of_renewals(p_emp_stat_situation_id);
  --
    IF l_no_of_renewals >= l_max_renewals THEN
       RETURN 'NO';
    END IF;
  --
    RETURN 'YES';
  --Below lines commented by deenath, since base situation may not be current.
  /*
    IF (is_current_situation(p_emp_stat_situation_id) = 'Y') THEN
       RETURN 'YES';
    ELSE
       RETURN 'NO';
    END IF;
  */
  END is_situation_renewable;
--
   Function is_current_situation(p_emp_stat_situation_id NUMBER) RETURN varchar2 IS
      Cursor Csr_current_situation(p_emp_statutory_situation_id NUMBER) IS
         SELECT NVL(actual_start_date,provisional_start_date),NVL(NVL(actual_end_date,provisional_end_date),TRUNC(SYSDATE)),NVL(approval_flag,'N')
         FROM   pqh_fr_emp_stat_situations
         WHERE  emp_stat_situation_id = p_emp_stat_situation_id;
      l_start_date DATE;
      l_end_date   DATE;
      l_approved   varchar2(10);
   BEGIN
      OPEN csr_current_situation(p_emp_stat_situation_id);
      FETCH csr_current_situation INTO l_start_date, l_end_date,l_approved;
      CLOSE csr_current_situation;
      IF (TRUNC(SYSDATE) <= l_end_date AND TRUNC(SYSDATE) >= l_start_date ) AND l_approved = 'Y' THEN
         RETURN 'Y';
      END IF;
      RETURN 'N';
   END is_current_situation;
--
  FUNCTION get_number_of_renewals(p_emp_stat_situation_id NUMBER) RETURN NUMBER  IS
    CURSOR csr_no_of_renewals(p_emp_stat_situation_id IN NUMBER) IS
    SELECT NVL(count(emp_stat_situation_id),0)
      FROM pqh_fr_emp_stat_situations
     WHERE renewal_flag = 'Y'
       AND renew_stat_situation_id = p_emp_stat_situation_id;
    l_no_of_renewals NUMBER(10) := 0;
  BEGIN
    OPEN csr_no_of_renewals(p_emp_stat_situation_id);
    FETCH csr_no_of_renewals INTO l_no_of_renewals;
    CLOSE csr_no_of_renewals;
    RETURN l_no_of_renewals;
  END get_number_of_renewals;
  --
  --deenath - New function to get number of renewals created since in Update Renewal Situation,
  --we dont want to count the situation being updated as a renewal. Invoked from PQH_PSU_BUS.
  FUNCTION get_num_renewals(p_emp_stat_situation_id   IN NUMBER,
                            p_renew_stat_situation_id IN NUMBER) RETURN NUMBER IS
  --
  --Cursor to fetch total number of renewals.
    CURSOR csr_no_of_renewals IS
    SELECT NVL(COUNT(emp_stat_situation_id),0)
      FROM pqh_fr_emp_stat_situations
     WHERE emp_stat_situation_id  <> NVL(p_emp_stat_situation_id,-1)
       AND renewal_flag            = 'Y'
       AND renew_stat_situation_id = p_renew_stat_situation_id;
  --
  --Variable Declaration.
    l_no_of_renewals NUMBER(10) := 0;
  --
  BEGIN
  --
    OPEN csr_no_of_renewals;
    FETCH csr_no_of_renewals INTO l_no_of_renewals;
    CLOSE csr_no_of_renewals;
  --
    RETURN l_no_of_renewals;
  --
  END get_num_renewals;
--
--
   FUNCTION chk_rule_condition(p_emp_stat_situation_id   IN NUMBER,
                               p_statutory_situation_id  IN NUMBER,
                               p_txn_category_attribute_id IN NUMBER,
                               p_from_value              IN VARCHAR2,
                               p_to_value                IN VARCHAR2,
                               p_negate                  IN VARCHAR2) RETURN BOOLEAN IS
   l_rule_valid BOOLEAN := FALSE;
   CURSOR csr_attr_dtls (p_txn_catg_attribute_id IN NUMBER) IS
   SELECT tca.value_style_cd,
          tr.from_clause,
          tr.where_clause,
          a.column_name,
          a.column_type
   FROM   pqh_txn_category_attributes tca,
          pqh_table_route tr,
          pqh_attributes a
   WHERE  tca.txn_category_attribute_id = p_txn_catg_attribute_id
   AND    tca.attribute_id = a.attribute_id
   AND    a.master_table_route_id = tr.table_route_id;
   l_attr_dtls  csr_attr_dtls%ROWTYPE;
   l_where_clause_out  varchar2(2000);
   l_sql_stmt          varchar2(2000);
   l_txn_value_v       varchar2(100);
   l_txn_value_n        NUMBER;
   BEGIN
    OPEN csr_attr_dtls(p_txn_category_attribute_id);
    FETCH csr_attr_dtls INTO l_attr_dtls.value_style_cd,
                             l_attr_dtls.from_clause,
                             l_attr_dtls.where_clause,
                             l_attr_dtls.column_name,
                             l_attr_dtls.column_type;
    IF csr_attr_dtls%NOTFOUND THEN
      hr_utility.set_location('Invalid Rule Attribute',10);
    END IF;
    CLOSE csr_attr_dtls;
    pqh_refresh_data.replace_where_params(
      p_where_clause_in  => l_attr_dtls.where_clause,
      p_txn_tab_flag     => 'Y',
      p_txn_id           => p_emp_stat_situation_id,
      p_where_clause_out => l_where_clause_out);
   --dbms_output.put_line('Out Where'||l_where_clause_out);
   l_sql_stmt := 'SELECT '||l_attr_dtls.column_name
                                ||'  FROM  '|| l_attr_dtls.from_clause
                                ||'  WHERE '||l_where_clause_out;
   --dbms_output.put_line('SQL 1 - '||substr(l_sql_stmt,1,150));
   --dbms_output.put_line('SQL 1 - '||substr(l_sql_stmt,151,150));
   --dbms_output.put_line('SQL 1 - '||substr(l_sql_stmt,301,150)) ;
   IF l_attr_dtls.column_type = 'V' THEN
	   BEGIN
	     EXECUTE IMMEDIATE l_sql_stmt  INTO l_txn_value_v;
	   EXCEPTION
	      When Others THEN
	        RAISE;
		--dbms_output.put_line('Error in Dyn Sql - Varchar2');
		--dbms_output.put_line(SqlErrm);
	   END;
	   --dbms_output.put_line('txn Value - '||l_txn_value_v);
	   IF l_attr_dtls.value_style_cd = 'EXACT' THEN
	      IF l_txn_value_v = p_from_value THEN
	       IF p_negate = 'Y' THEN
	          RETURN FALSE;
	       ELSE
	         RETURN TRUE;
	       END IF;
	      END IF;
	   ELSIF l_attr_dtls.value_style_cd = 'RANGE' THEN
	      IF l_txn_value_v >= p_from_value
	        AND l_txn_value_v <= NVL(p_to_value,l_txn_value_v) THEN
	       IF p_negate = 'Y' THEN
	          RETURN FALSE;
	       ELSE
	         RETURN TRUE;
	       END IF;
	      END IF;
	   END IF;
    ELSIF l_attr_dtls.column_type = 'N' THEN
	   BEGIN
	     EXECUTE IMMEDIATE l_sql_stmt  INTO l_txn_value_n;
	   EXCEPTION
	      When Others THEN
	        RAISE;
		--dbms_output.put_line('Error in Dyn Sql - NUMBER');
		--dbms_output.put_line(SqlErrm);
	   END;
	   --dbms_output.put_line('txn Value - '||l_txn_value_n);
	   IF l_attr_dtls.value_style_cd = 'EXACT' THEN
	      IF l_txn_value_n = fnd_number.canonical_to_number(p_from_value) THEN
	       IF p_negate = 'Y' THEN
	          RETURN FALSE;
	       ELSE
	         RETURN TRUE;
	       END IF;
	      END IF;
	   ELSIF l_attr_dtls.value_style_cd = 'RANGE' THEN
	      IF l_txn_value_n >= fnd_number.canonical_to_number(p_from_value)
	        AND l_txn_value_n <= NVL(fnd_number.canonical_to_number(p_to_value),l_txn_value_n) THEN
	       IF p_negate = 'Y' THEN
	          RETURN FALSE;
	       ELSE
	         RETURN TRUE;
	       END IF;
	      END IF;
	   END IF;
     END IF;
     RETURN FALSE;
 END chk_rule_condition;
   Function Check_Situation_rules(p_emp_stat_situation_id IN NUMBER,
                                  p_statutory_situation_id IN NUMBER,
                                  p_rule_type              IN VARCHAR2 DEFAULT 'REQUIRED')
                                  RETURN VARCHAR2 IS
   CURSOR csr_rule_conditions(p_stat_sit_id NUMBER,
                              p_required_flag VARCHAR2) IS
   SELECT   txn_category_attribute_id,
            from_value,
            to_value,
            exclude_flag
   FROM     pqh_fr_stat_situation_rules
   WHERE    statutory_situation_id = p_stat_sit_id
   AND      NVL(enabled_flag,'N') = 'Y'
   AND      NVL(required_flag,'N') = p_required_flag
   ORDER BY processing_sequence;
   l_required varchar2(10);
   lr_rule  csr_rule_conditions%ROWTYPE;
   l_all_valid_rules VARCHAR2(30) := 'NO_RULES_DEFINED';
   l_rule_result BOOLEAN := FALSE;
   BEGIN
     IF p_rule_type = 'REQUIRED' THEN
        l_required := 'Y';
     ELSE
        l_required := 'N';
     END IF;
     OPEN csr_rule_conditions(p_statutory_situation_id,l_required);
     LOOP
         FETCH csr_rule_conditions INTO lr_rule.txn_category_attribute_id,
                                        lr_rule.from_value,
                                        lr_rule.to_value,
                                        lr_rule.exclude_flag;
         EXIT WHEN Csr_rule_conditions%NOTFOUND;
         l_rule_result := chk_rule_condition(p_emp_stat_situation_id,
                                            p_statutory_situation_id,
                                            lr_rule.txn_category_attribute_id,
                                            lr_rule.from_value,
                                            lr_rule.to_value,
                                            lr_rule.exclude_flag);
	 IF l_rule_result THEN
	    l_all_valid_rules := 'TRUE';
	    IF p_rule_type = 'OPTIONAL' THEN
	       EXIT;
	    END IF;
	 ELSE
	    l_all_valid_rules := 'FALSE';
	    IF p_rule_type = 'REQUIRED' THEN
	       EXIT;
	    END IF;
	 END IF;
     END LOOP;
     CLOSE csr_rule_conditions;
     RETURN l_all_valid_rules;
   END Check_Situation_rules;
 Function is_situation_valid(p_person_id NUMBER,
                               p_emp_stat_situation_id NUMBER,
                               p_statutory_situation_id NUMBER) RETURN VARCHAR2 IS
   l_passed_all_reqd VARCHAR2(30);
   l_passed VARCHAR2(30);
   l_return_status VARCHAR2(10) := 'N';
   l_rule_valid  BOOLEAN := FALSE;
   BEGIN
--Validate the Mandatory Conditions first. If it meets all the conditions, then situation is valid.
      l_passed_all_reqd := Check_Situation_Rules(p_emp_stat_situation_id,
                                                 p_statutory_situation_id,
                                                 'REQUIRED');
      IF l_passed_all_reqd = 'YES' THEN
         l_return_status := 'Y';
      ELSIF l_passed_all_reqd = 'NO' THEN
         l_return_status := 'N';
      ELSIF l_passed_all_reqd = 'NO_RULES_DEFINED' THEN
--No Required rules defined. See if meets atleast one optional rule.
         l_passed  := Check_Situation_Rules(p_emp_stat_situation_id,
                                            p_statutory_situation_id,
                                            'OPTIONAL');
         IF l_passed = 'YES' OR l_passed = 'NO_RULES_DEFINED' THEN
	       l_return_status := 'Y';
	 ELSE
	       l_return_status := 'N';
         END IF;
      END IF;
      RETURN l_return_status;
   END is_situation_valid;
  --
  FUNCTION get_dflt_situation(p_business_group_id IN NUMBER,
                              p_situation_type    IN VARCHAR2,
                              p_sub_type          IN VARCHAR2,
                              p_effective_date    IN DATE)
  RETURN NUMBER IS
    CURSOR csr_dflt_inactivity(p_business_group_id IN NUMBER,
                               p_situation_type    IN VARCHAR2,
                               p_sub_type          IN VARCHAR2,
                               p_eff_date          IN DATE) IS
    SELECT statutory_situation_id
      FROM pqh_fr_stat_situations_v sit
          ,per_shared_types_vl      sh
     WHERE sh.shared_type_id      = type_of_ps
       AND sh.system_type_cd      = NVL(PQH_FR_UTILITY.get_bg_type_of_ps,sh.system_type_cd)
       AND sit.business_group_id  = p_business_group_id
       AND sit.situation_type     = p_situation_type
       AND sit.sub_type           = NVL(p_sub_type,sub_type)
       AND sit.default_flag       = 'Y'
       AND TRUNC(p_eff_date) BETWEEN sit.date_from AND NVL(sit.date_to,HR_GENERAL.end_of_time);
/* --Commented by deenath and replaced by above cursor sql.
	  SELECT statutory_situation_id
	  FROM   pqh_fr_stat_situations
	  WHERE  business_group_id = p_business_group_id
	  AND    situation_type    = p_situation_type
	  AND    sub_type = NVL(p_sub_type,sub_type)
	  AND    default_flag = 'Y'
	  AND    trunc(p_eff_date) BETWEEN date_from and NVL(date_to,hr_general.end_of_time);
*/
    l_reinstate_situation NUMBER(15);
  BEGIN
    OPEN csr_dflt_inactivity(p_business_group_id,p_situation_type,p_sub_type,p_effective_date);
    FETCH csr_dflt_inactivity INTO l_reinstate_situation;
    CLOSE csr_dflt_inactivity;
    RETURN NVL(l_reinstate_situation,-1);
  END get_dflt_situation;
  --
  FUNCTION get_time_line(p_provisional_start_date IN DATE,
                         p_provisional_end_date   IN DATE,
                         p_effective_date         IN DATE)
  RETURN VARCHAR2 IS
  BEGIN
/*  --Commented by deenath to display Timeline even for End Of Time Situations.
    If p_provisional_end_date = hr_general.end_of_time then
      Return null;
    End if;
*/
    IF p_effective_date BETWEEN p_provisional_start_date AND p_provisional_end_date THEN
       RETURN HR_GENERAL.decode_lookup('PQH_FR_SIT_TIME_LINES','PRESENT');
    ELSIF p_effective_date > p_provisional_end_date THEN
       RETURN HR_GENERAL.decode_lookup('PQH_FR_SIT_TIME_LINES','PAST');
    ELSIF p_provisional_start_date > p_effective_date Then
       RETURN HR_GENERAL.decode_lookup('PQH_FR_SIT_TIME_LINES','FUTURE');
    END IF;
    RETURN NULL;  --added by deenath
  END get_time_line;
  --
  FUNCTION get_time_line_code(p_provisional_start_date IN DATE,
                              p_actual_end_date        IN DATE,
                              p_provisional_end_date   IN DATE,
                              p_effective_date         IN DATE) RETURN VARCHAR2
  IS
  BEGIN
  --
    IF p_provisional_end_date = HR_GENERAL.end_of_time OR p_actual_end_date = HR_GENERAL.end_of_time THEN
       RETURN NULL;
    END IF;
  --
    IF p_actual_end_date IS NOT NULL THEN
       RETURN NULL;
    END IF;
  --
    IF p_effective_date BETWEEN p_provisional_start_date AND NVL(p_actual_end_date,p_provisional_end_date) THEN
       RETURN 'PRESENT';
    ELSIF p_effective_date > NVL(p_actual_end_date,p_provisional_end_date) Then
       RETURN 'PAST';
    ELSIF p_provisional_start_date > p_effective_date Then
       RETURN 'FUTURE';
    END IF;
  --
  END get_time_line_code;
  --
  FUNCTION get_update_time_line_code(p_provisional_start_date IN DATE,
                                     p_provisional_end_date   IN DATE,
                                     p_effective_date         IN DATE,
                                     p_approval_flag          IN VARCHAR2,
                                     p_renew_flag             IN VARCHAR2,
                                     p_situation_type         IN VARCHAR2,
                                     p_sub_type               IN VARCHAR2,
                                     p_default_flag           IN VARCHAR2)
  RETURN VARCHAR2 IS
    l_return_value VARCHAR2(10) := 'NO';
  BEGIN
    IF p_effective_date BETWEEN p_provisional_start_date AND p_provisional_end_date THEN
       l_return_value := 'PRESENT';
    ELSIF p_effective_date > p_provisional_end_date THEN
       l_return_value := 'PAST';
    ELSIF p_provisional_start_date > p_effective_date THEN
       l_return_value := 'FUTURE';
    END IF;
    IF(l_return_value = 'FUTURE') THEN
       l_return_value := 'SHOW';
    ELSE
       l_return_value := 'NO';
    END IF;
  --Added by deenath
    IF (p_situation_type = 'IA' AND p_sub_type = 'IA_N' AND p_default_flag = 'Y') THEN
       l_return_value := 'NO';
    END IF;
    IF NVL(p_renew_flag,'N') = 'Y' THEN
       l_return_value := 'NO';
    END IF;
/* --Commented by deenath. Replaced with above if condition.
     Do not show for Present timeline irrespective of Approval Flag.
   if (l_return_value ='PRESENT') and (p_approval_flag = 'N') then
      l_return_value  := 'SHOW';
   elsif (l_return_value = 'FUTURE') then
      l_return_value := 'SHOW';
   else
      l_return_value := 'NO';
   end if;
*/
    RETURN l_return_value;
  END get_update_time_line_code;
  --
  FUNCTION get_delete_time_line_code(p_person_id              IN NUMBER,
                                     p_provisional_start_date IN DATE,
                                     p_provisional_end_date   IN DATE,
                                     p_effective_date         IN DATE)
  RETURN VARCHAR2 IS
    l_return_value VARCHAR2(10) := NULL;
  BEGIN
    IF p_provisional_end_date = hr_general.end_of_time THEN
       RETURN NULL;
    END IF;
    IF p_effective_date BETWEEN p_provisional_start_date AND p_provisional_end_date THEN
       RETURN NULL;
    ELSIF p_effective_date > p_provisional_end_date THEN
       RETURN NULL;
    ELSIF p_provisional_start_date > p_effective_date THEN
    --added by deenath
      SELECT DECODE(TRUNC(MAX(provisional_start_date)),TRUNC(p_provisional_start_date),'DEL-TRUE',NULL)
        INTO l_return_value
        FROM pqh_fr_emp_stat_situations
       WHERE person_id = p_person_id
         AND statutory_situation_id NOT IN (SELECT statutory_situation_id
                                              FROM pqh_fr_stat_situations_v sit
                                                  ,per_shared_types_vl      sh
                                             WHERE sh.shared_type_id    = type_of_ps
                                               AND sh.system_type_cd    = NVL(PQH_FR_UTILITY.get_bg_type_of_ps,sh.system_type_cd)
                                               AND sit.business_group_id= HR_GENERAL.get_business_group_id
                                               AND sit.default_flag     = 'Y'
                                               AND sit.situation_type   = 'IA'
                                               AND sit.sub_type         = 'IA_N'
                                               AND TRUNC(SYSDATE) BETWEEN sit.date_from AND NVL(sit.date_to,HR_GENERAL.end_of_time));
    END IF;
    RETURN l_return_value;
  END get_delete_time_line_code;
  --
END pqh_fr_stat_sit_util;

/
