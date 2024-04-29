--------------------------------------------------------
--  DDL for Package Body PQH_FR_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_FR_UTILITY" AS
/* $Header: pqfrutil.pkb 120.8 2008/06/27 06:06:11 rbabla noship $ */

-- This procedure is used to check is there any duplicate records, while
-- retrieving the records in mass update of employee assignment form
--
PROCEDURE DELETE_DUPLICATE_ASG_RECORDS (P_COPY_ENTITY_RESULT_ID in NUMBER
,P_COPY_ENTITY_TXN_ID IN NUMBER
,P_RESULT_TYPE_CD in VARCHAR2
,P_INFORMATION2 IN VARCHAR2
,P_INFORMATION67 IN VARCHAR2)
IS
-- Cursors
CURSOR CSR_CHK_DUP_REC IS
SELECT COUNT(*)
  FROM PQH_COPY_ENTITY_RESULTS
 WHERE COPY_ENTITY_TXN_ID = P_COPY_ENTITY_TXN_ID
   AND INFORMATION2 =  P_INFORMATION2
   AND COPY_ENTITY_RESULT_ID <> P_COPY_ENTITY_RESULT_ID
   AND RESULT_TYPE_CD = P_RESULT_TYPE_CD;

-- Mofied for Bug 6031763
--CURSOR CSR_GET_LEGISLATION IS
CURSOR CSR_GET_LEGISLATION(CSR_L_INFORMATION67 VARCHAR2) IS
SELECT ORG_INFORMATION9
  FROM HR_ORGANIZATION_INFORMATION HOI,
       PER_ALL_ASSIGNMENTS_F PAF
 WHERE PAF.ASSIGNMENT_ID = P_INFORMATION2
   AND FND_DATE.CANONICAL_TO_DATE(CSR_L_INFORMATION67) BETWEEN PAF.EFFECTIVE_START_DATE
                                                       AND PAF.EFFECTIVE_END_DATE

   AND HOI.ORGANIZATION_ID = PAF.BUSINESS_GROUP_ID
   AND UPPER(HOI.ORG_INFORMATION_CONTEXT) = 'BUSINESS GROUP INFORMATION';
 --

CURSOR CSR_GET_CONTEXT IS
SELECT CONTEXT
  FROM PQH_COPY_ENTITY_TXNS
 WHERE COPY_ENTITY_TXN_ID = P_COPY_ENTITY_TXN_ID;

-- Local Variables
l_duplicate          number;

l_legislation        hr_organization_information.org_information9%type;

l_context            pqh_copy_entity_txns.context%type;

-- Added for Bug 6031763
l_information67      varchar2(100);
--

BEGIN
--
/* Added for GSI Bug 5472781 */
IF NOT hr_utility.chk_product_install('Oracle Human Resources', 'FR') THEN
   hr_utility.set_location('Leaving : pqh_fr_utility.delete_duplicate_asg_records' , 5);
   return;
END IF;
--
HR_UTILITY.SET_LOCATION('P_COPY_ENTITY_RESULT_ID'||P_COPY_ENTITY_RESULT_ID, 5);
HR_UTILITY.SET_LOCATION('P_COPY_ENTITY_TXN_ID'||P_COPY_ENTITY_TXN_ID, 5);
HR_UTILITY.SET_LOCATION('P_INFORMATION2'||P_INFORMATION2, 5);
HR_UTILITY.SET_LOCATION('P_INFORMATION67'||P_INFORMATION67, 5);
HR_UTILITY.SET_LOCATION('P_RESULT_TYPE_CD'||P_RESULT_TYPE_CD, 5);

open csr_get_context;
fetch csr_get_context into l_context;
if l_context = 'PQH_ASSIGNMENT_UPDATE' then

      HR_UTILITY.SET_LOCATION('In pqh_assignment_update context', 20);
      -- Added for Bug 6031763
      if NOT(length(p_information67) > 11) then
	 l_information67 := fnd_date.date_to_canonical(fnd_date.string_to_date(p_information67,NVL(fnd_profile.value_specific('ICX_DATE_FORMAT_MASK'),'DD-MON-YYYY')));
      else
      	 l_information67 := p_information67;
      end If;
      --
      -- Modified for Bug 6031763
      --open csr_get_legislation;
      open csr_get_legislation(l_information67);
      --
      fetch csr_get_legislation into l_legislation;
      if csr_get_legislation%found then

         HR_UTILITY.SET_LOCATION('In Legislation', 10);
         if l_legislation = 'FR' then

            HR_UTILITY.SET_LOCATION('In France Legislation', 15);
            open csr_chk_dup_rec;
            fetch csr_chk_dup_rec into l_duplicate;
            if l_duplicate > 0 then

	       hr_utility.set_location('Has Duplicate Records', 25);
	       fnd_message.set_name('PER', 'HR_FR_DUP_ORG_MASS_UPD');
	       fnd_message.raise_error;
            end if;
         close csr_chk_dup_rec;
         end if; -- no FR legislation
      end if; -- legislation doesn't exists
close csr_get_legislation;
end if; -- context different
close csr_get_context;

HR_UTILITY.SET_LOCATION('l_duplicate'||l_duplicate, 25);

END DELETE_DUPLICATE_ASG_RECORDS;

FUNCTION get_kf_id_flex_num(p_id_flex_code  Varchar2,
                            p_structure_code VARCHAR2) RETURN NUMBER IS
    Cursor C_Id_Flex IS
      SELECT id_flex_num
      FROM   fnd_id_flex_structures
      WHERE  id_flex_code  = p_id_flex_code
      AND    id_flex_structure_code = p_structure_code;

      l_id_flex_num fnd_id_flex_structures.id_flex_num%TYPE;
BEGIN
     OPEN C_Id_Flex;
     FETCH C_Id_Flex INTO l_id_flex_num;
     IF C_Id_Flex%NOTFOUND THEN
        l_id_flex_num := TO_NUMBER(NULL);
     END IF;
     CLOSE C_Id_Flex;

     RETURN l_id_flex_num;

END get_kf_id_flex_num;

FUNCTION  Get_Award_Type(p_person_id   Number,
                         p_award_category  Varchar2,
                         p_award_type      Varchar2)
RETURN VARCHAR2  IS

    l_id_flex_num    NUMBER(15);

    Cursor C_national_award_date IS
      SELECT  MAX(fnd_date.canonical_to_date(pea.segment5))
      FROM    per_analysis_criteria pea,
              per_person_analyses  ppa
      WHERE   ppa.person_id  =  p_person_id
      AND     pea.id_flex_num = l_id_flex_num
      AND     pea.segment1 = p_award_type
      AND     pea.analysis_criteria_id = ppa.analysis_criteria_id;

    Cursor C_ministry_award_date IS
      SELECT  MAX(fnd_date.canonical_to_date(pea.segment7))
      FROM    per_analysis_criteria pea,
              per_person_analyses  ppa
      WHERE   ppa.person_id  = p_person_id
      AND     pea.id_flex_num = l_id_flex_num
      AND     pea.segment1 = p_award_type
      AND     pea.analysis_criteria_id = ppa.analysis_criteria_id;

     l_max_date    DATE;


-- Selects the most recent award (award type) for a given person, for National award
    CURSOR C_national_award_type IS
    SELECT  pea.segment1
    FROM    per_analysis_criteria pea,
            per_person_analyses ppa
    WHERE   ppa.person_id = p_person_id
      AND   pea.id_flex_num = l_id_flex_num
      AND   pea.analysis_criteria_id = ppa.analysis_criteria_id
      AND   pea.segment1 = p_award_type
      AND   fnd_date.canonical_to_date(pea.segment5) = l_max_date;

-- Selects the most recent award (award type) for a given person, for Ministry award
    CURSOR C_ministry_award_type IS
    SELECT pea.segment1
    FROM   per_analysis_criteria pea,
           per_person_analyses ppa
    WHERE  ppa.person_id   = p_person_id
      AND  pea.id_flex_num = l_id_flex_num
      AND  pea.analysis_criteria_id = ppa.analysis_criteria_id
      AND  pea.segment1 = p_award_type
      AND  fnd_date.canonical_to_date(pea.segment7) = l_max_date;

    l_award_type  hr_lookups.lookup_code%TYPE;

BEGIN
       IF p_award_category = 'NATIONAL' THEN
          l_id_flex_num := get_kf_id_flex_num('PEA','FR_PQH_NATIONAL_AWARD');
          IF l_id_flex_num IS NULL THEN
              RETURN TO_CHAR(NULL);
          END IF;
          OPEN C_national_award_date;
          FETCH C_national_award_date INTO l_max_date;
          CLOSE C_national_award_date;
          IF l_max_date IS NULL THEN
             RETURN TO_CHAR(NULL);
          ELSE
             OPEN C_national_award_type;
             FETCH C_national_award_type INTO l_award_type;
             CLOSE C_national_award_type;
             RETURN l_award_type;
          END IF;
       ELSIF p_award_category = 'MINISTRY' THEN
          l_id_flex_num := get_kf_id_flex_num('PEA','FR_PQH_MINISTRY_AWARDS');
          IF l_id_flex_num IS NULL THEN
              RETURN TO_CHAR(NULL);
          END IF;
          OPEN C_ministry_award_date;
          FETCH C_ministry_award_date INTO l_max_date;
          CLOSE C_ministry_award_date;
          IF l_max_date IS NULL THEN
             RETURN TO_CHAR(NULL);
          ELSE
             OPEN C_ministry_award_type;
             FETCH C_ministry_award_type INTO l_award_type;
             CLOSE C_ministry_award_type;
             RETURN l_award_type;
          END IF;
       END IF;

END Get_Award_Type;

FUNCTION  Get_Award_Grade_Level(p_person_id   Number,
                                p_award_category  Varchar2,
                                p_award_type      Varchar2)
RETURN VARCHAR2  IS

    l_id_flex_num    NUMBER(15);

    Cursor C_national_award_date IS
      SELECT  MAX(fnd_date.canonical_to_date(pea.segment5))
      FROM    per_analysis_criteria pea,
              per_person_analyses  ppa
      WHERE   ppa.person_id  =  p_person_id
      AND     pea.id_flex_num = l_id_flex_num
      AND     pea.segment1 = p_award_type
      AND     pea.analysis_criteria_id = ppa.analysis_criteria_id;

    Cursor C_ministry_award_date IS
      SELECT  MAX(fnd_date.canonical_to_date(pea.segment7))
      FROM    per_analysis_criteria pea,
              per_person_analyses  ppa
      WHERE   ppa.person_id  = p_person_id
      AND     pea.id_flex_num = l_id_flex_num
      AND     pea.segment1 = p_award_type
      AND     pea.analysis_criteria_id = ppa.analysis_criteria_id;

     l_max_date    DATE;


-- Selects the most recent award (award Grade) for a given person, for National award
    CURSOR C_national_award_grade IS
    SELECT  pea.segment2
    FROM    per_analysis_criteria pea,
            per_person_analyses ppa
    WHERE   ppa.person_id = p_person_id
      AND   pea.id_flex_num = l_id_flex_num
      AND   pea.analysis_criteria_id = ppa.analysis_criteria_id
      AND   pea.segment1 = p_award_type
      AND   fnd_date.canonical_to_date(pea.segment5) = l_max_date;

-- Selects the most recent award (award level) for a given person, for Ministry award
    CURSOR C_ministry_award_level IS
    SELECT pea.segment4
    FROM   per_analysis_criteria pea,
           per_person_analyses ppa
    WHERE  ppa.person_id   = p_person_id
      AND  pea.id_flex_num = l_id_flex_num
      AND  pea.segment1 = p_award_type
      AND  pea.analysis_criteria_id = ppa.analysis_criteria_id
      AND  fnd_date.canonical_to_date(pea.segment7) = l_max_date;

    l_award_type  hr_lookups.lookup_code%TYPE;

BEGIN
       IF p_award_category = 'NATIONAL' THEN
          l_id_flex_num := get_kf_id_flex_num('PEA','FR_PQH_NATIONAL_AWARD');
          IF l_id_flex_num IS NULL THEN
              RETURN TO_CHAR(NULL);
          END IF;
          OPEN C_national_award_date;
          FETCH C_national_award_date INTO l_max_date;
          CLOSE C_national_award_date;
          IF l_max_date IS NULL THEN
             RETURN TO_CHAR(NULL);
          ELSE
             OPEN C_national_award_grade;
             FETCH C_national_award_grade INTO l_award_type;
             CLOSE C_national_award_grade;
             RETURN l_award_type;
          END IF;
       ELSIF p_award_category = 'MINISTRY' THEN
          l_id_flex_num := get_kf_id_flex_num('PEA','FR_PQH_MINISTRY_AWARDS');
          IF l_id_flex_num IS NULL THEN
              RETURN TO_CHAR(NULL);
          END IF;
          OPEN C_ministry_award_date;
          FETCH C_ministry_award_date INTO l_max_date;
          CLOSE C_ministry_award_date;
          IF l_max_date IS NULL THEN
             RETURN TO_CHAR(NULL);
          ELSE
             OPEN C_ministry_award_level;
             FETCH C_ministry_award_level INTO l_award_type;
             CLOSE C_ministry_award_level;
             RETURN l_award_type;
          END IF;
       END IF;

END Get_Award_Grade_Level;

FUNCTION Get_Entitlement_Item(p_business_group_id NUMBER,
                              p_item_type Varchar2) RETURN NUMBER IS

CURSOR C_Acco_Item IS
    SELECT information2
    FROM   per_shared_types
    WHERE  lookup_type = 'FR_PQH_ENTITLEMENT_SETUP'
    AND    system_type_cd = 'ACCOMMODATION'
    AND    (business_group_id = p_business_group_id OR business_group_id IS NULL);

CURSOR C_Ministry_Item IS
    SELECT information2
    FROM   per_shared_types
    WHERE  lookup_type = 'FR_PQH_ENTITLEMENT_SETUP'
    AND    system_type_cd = 'MINISTRY_AWARD'
    AND    (business_group_id = p_business_group_id OR business_group_id IS NULL);

CURSOR C_National_Item IS
    SELECT information2
    FROM   per_shared_types
    WHERE  lookup_type = 'FR_PQH_ENTITLEMENT_SETUP'
    AND    system_type_cd = 'NATIONAL_AWARD'
    AND    (business_group_id = p_business_group_id OR business_group_id IS NULL);
l_entitlement_item   NUMBER(15);
BEGIN
     IF p_item_type = 'ACCOMMODATION' THEN
        OPEN C_Acco_Item;
        FETCH C_Acco_Item INTO l_entitlement_item;
        CLOSE C_Acco_Item;
     ELSIF p_item_type = 'MINISTRY_AWARD' THEN
        OPEN C_Ministry_Item;
        FETCH C_Ministry_Item INTO l_entitlement_item;
        CLOSE C_Ministry_Item;
     ELSIF p_item_type = 'NATIONAL_AWARD' THEN
        OPEN C_National_Item;
        FETCH C_National_Item INTO l_entitlement_item;
        CLOSE C_National_Item;
     END IF;

     Return l_entitlement_item;

END Get_Entitlement_Item;

FUNCTION Check_PS_Installed (p_business_group_id NUMBER)
RETURN VARCHAR2 IS
BEGIN
    IF pqh_utility.is_pqh_installed(p_business_group_id) = TRUE THEN
        RETURN 'Y';
    ELSE
        RETURN 'N';
    END IF;
END Check_PS_Installed;

PROCEDURE Get_DateTrack_Mode(p_effective_date IN DATE,
                            p_base_table_name IN Varchar2,
                            p_base_key_column IN Varchar2,
                            p_base_key_value  IN Number,
                            p_datetrack_mode  OUT NOCOPY VARCHAR2) IS
    l_correction    BOOLEAN;
    l_update        BOOLEAN;
    l_update_override BOOLEAN;
    l_update_change_insert BOOLEAN;

BEGIN
     DT_API.FIND_DT_UPD_MODES(p_effective_date => TRUNC(p_effective_date),
                              p_base_table_name => p_base_table_name,
                              p_base_key_column => p_base_key_column,
                              p_base_key_value => p_base_key_value,
                              p_correction => l_correction,
                              p_update   => l_update,
                              p_update_override => l_update_override,
                              p_update_change_insert =>l_update_change_insert);

    IF l_update_change_insert = TRUE THEN
       p_datetrack_mode := 'UPDATE_CHANGE_INSERT';
    ELSIF l_update = TRUE THEN
       p_datetrack_mode := 'UPDATE';
    ELSE
       p_datetrack_mode := 'CORRECTION';
    END IF;
END Get_DateTrack_Mode;
--
FUNCTION  Get_Accommodation_status (p_accommodation_id IN NUMBER,
                                    p_effective_date IN DATE) RETURN VARCHAR2
IS
Cursor csr_assignment_exist_for_acco IS
SELECT 'Y'
FROM DUAL
WHERE EXISTS( Select NULL
from pqh_assign_accommodations_f
where accommodation_id = p_accommodation_id
and trunc(p_effective_date) between effective_start_date and effective_end_date
and accommodation_given ='Y');

--
l_var varchar2(10) := 'N';
Begin
--
 Open csr_assignment_exist_for_acco;

  Fetch csr_assignment_exist_for_acco into l_var;

 Close csr_assignment_exist_for_acco;

 If l_var ='Y'  then -- Accommodation is Occupied
      return  hr_general.decode_lookup('PQH_ACCO_STATUS','03') ;
 else               -- Accommodation is Available
     return hr_general.decode_lookup('PQH_ACCO_STATUS','02');
 End If;
--
End Get_Accommodation_status;
--
FUNCTION get_lookup_shared_type( p_lookup_type VARCHAR2, p_lookup_code VARCHAR2,
                                     p_business_group_id NUMBER, p_return_value VARCHAR2) RETURN VARCHAR2
is

Cursor csr_glb_shared_types Is
Select shared_type_id, shared_type_name
From per_shared_types_vl
Where lookup_type = p_lookup_type
And system_type_cd = p_lookup_code
And business_group_id is null;

Cursor csr_bg_shared_types is
Select shared_type_id, shared_type_name
From per_shared_types_vl
Where lookup_type = p_lookup_type
And system_type_cd = p_lookup_code
And business_group_id = p_business_group_id;

l_bg_return csr_bg_shared_types%ROWTYPE;
l_glb_return csr_glb_shared_types%ROWTYPE;

Begin
  Open csr_bg_shared_types;
   Fetch csr_bg_shared_types into l_bg_return;
   IF csr_bg_shared_types%FOUND THEN
    Close csr_bg_shared_types;
      If (p_return_value = 'ID') then
  		Return l_bg_return.shared_type_id;
	Else
		Return l_bg_return.shared_type_name;
	End if;
   END IF;

Open csr_glb_shared_types;
Fetch csr_glb_shared_types into l_glb_return;
Close csr_glb_shared_types;
     If (p_return_value = 'ID') then
  		Return l_glb_return.shared_type_id;
	Else
		Return l_glb_return.shared_type_name;
	End if;
END get_lookup_shared_type;
--
-- Admin Career Validations


procedure admin_effective_warning( p_person_id in number ,p_effective_date in varchar2,p_return_status out NOCOPY varchar) IS

Cursor csr_suggest_eff_dt Is
Select max(effective_start_date)
from per_all_assignments_f
where person_id = p_person_id
and primary_flag ='Y';
--
l_date date;
Begin

        hr_multi_message.enable_message_list;

        Open csr_suggest_eff_dt;
         Fetch csr_suggest_eff_dt into l_date;
        Close csr_suggest_eff_dt;


        fnd_message.set_name('PQH','PQH_FR_DATE_SUGGESTION');
        fnd_message.set_token('DATE',l_date);

        hr_multi_message.add(p_message_type=>HR_MULTI_MESSAGE.G_INFORMATION_MSG);

        HR_MULTI_MESSAGE.end_validation_set;


End admin_effective_warning;
---
procedure employment_terms_validations (p_person_id in number, p_effective_date in varchar2)
IS
Cursor csr_chk_person IS
Select PER_INFORMATION15
from per_all_people_f
where person_id = p_person_id
and to_date(p_effective_date,'RRRR-MM-DD') between effective_start_date and effective_end_date;
--
Cursor csr_chk_career IS
Select grade_ladder_pgm_id
from per_all_assignments_f
where person_id = p_person_id
and  primary_flag ='Y'
and to_date(p_effective_date, 'RRRR-MM-DD') between effective_start_date and effective_end_date;




l_temp varchar2(10);
Begin

   Open csr_chk_person;
    Fetch  csr_chk_person into l_temp;

    If csr_chk_person%notfound then
    --
    -- There is no record as of effective date
    --
       fnd_message.set_name('PQH','PQH_FR_NO_PERSON_EXIST');
       fnd_message.set_token('DATE',to_date(p_effective_date,'RRRR-MM-DD'));
       hr_multi_message.add(p_message_type=>HR_MULTI_MESSAGE.G_ERROR_MSG);
    --
    End if;
  Close csr_chk_person;

  If ( l_temp = '01') then  -- Fonctionnaire
  --
     Open csr_chk_career;
      Fetch csr_chk_career into l_temp;
      If (l_temp is null) then -- Career is Not definied
      -- No Career Exist as on DATE
      --
       fnd_message.set_name('PQH','PQH_FR_NO_CAREER');
     fnd_message.set_token('DATE',to_date(p_effective_date,'RRRR-MM-DD'));
       hr_multi_message.add(p_message_type=>HR_MULTI_MESSAGE.G_ERROR_MSG);
      --
     End if;
     Close csr_chk_career;
 --
 End if;




End employment_terms_validations;
--

procedure admin_career_validations(p_person_id in number, p_effective_date in varchar2)
IS

Cursor csr_chk_person IS
Select null
from per_all_people_f
where person_id = p_person_id
and to_date(p_effective_date,'RRRR-MM-DD') between effective_start_date and effective_end_date;

l_temp varchar2(10);

Begin
--

   Open csr_chk_person;
    Fetch  csr_chk_person into l_temp;

    If csr_chk_person%notfound then
    --
    -- There is no record as of effective date
    --
       fnd_message.set_name('PQH','PQH_FR_NO_PERSON_EXIST');
       fnd_message.set_token('DATE',to_date(p_effective_date,'RRRR-MM-DD'));
       hr_multi_message.add(p_message_type=>HR_MULTI_MESSAGE.G_ERROR_MSG);
    --
    End if;
  Close csr_chk_person;


---
End admin_career_validations;
--
procedure affectations_validations(p_person_id in number,p_effective_date in varchar2)
IS
Cursor csr_normal_hours IS
Select normal_hours
from per_all_assignments_f
where to_date(p_effective_date,'RRRR-MM-DD') between effective_start_date and effective_end_date
and person_id = p_person_id
and primary_flag ='Y';

l_normal_hours per_all_assignments_f.normal_hours%type;

Begin
--
admin_career_validations(p_person_id,p_effective_date);
    /*
     Check the Normal Hours are defined for the Person or Not ...
     */
     Open csr_normal_hours;
      Fetch csr_normal_hours into l_normal_hours;
      If (l_normal_hours is null ) then
      ---
       fnd_message.set_name('PQH','PQH_FR_NO_NORMAL_HOURS');
       hr_multi_message.add(p_message_type=>HR_MULTI_MESSAGE.G_ERROR_MSG);
       --
     End if;

     Close csr_normal_hours;

employment_terms_validations(p_person_id,p_effective_date);
--
End affectations_validations;
--
procedure hr_actions_validate_person (p_person_id in number, p_return_status out NOCOPY varchar2,
                            p_effective_date in varchar2, p_function_name in Varchar2)
IS

Begin

        hr_multi_message.enable_message_list;

        -- Administratvie Career Check
        If (p_function_name = 'PQH_FR_HR_ADMIN_CAREER') Then
        --
        admin_career_validations(p_person_id, p_effective_date);
        --
        ElsIf (p_function_name = 'PQH_FR_HR_ADMIN_EMPL_TERMS') then
        --
        employment_terms_validations(p_person_id, p_effective_date);
        --
        ElsIf (p_function_name = 'PQH_FR_HR_ADMIN_AFFECTATIONS_H') Then
        --
             affectations_validations(p_person_id,p_effective_date);
        --
        End if;

        HR_MULTI_MESSAGE.end_validation_set;
EXCEPTION
when hr_multi_message.error_message_exist then
-- P_RETURN_STATUS := hr_multi_message.get_return_status;
null;
End;


-- Get_DateTrack_Mode Function
Function Get_DateTrack_Mode ( p_effective_date IN DATE,
                                 p_base_table_name IN VARCHAR2,
                                 p_base_key_column IN VARCHAR2,
                                 p_base_key_value  IN NUMBER) Return varchar2
Is
l_DateTrack_Mode varchar2(100);
begin
          Get_DateTrack_mode(p_effective_date => p_effective_date
                            ,p_base_table_name => p_base_table_name
                            ,p_base_key_column => p_base_key_column
                            ,p_base_key_value  => p_base_key_value
                            ,p_datetrack_mode  => l_dateTrack_mode);

Return l_dateTrack_Mode;

End get_DateTrack_mode; --Function

--
Function Get_available_hours(p_person_id IN NUMBER, p_effective_date in date) return number
IS
Cursor csr_available_hours(p_flag varchar2) IS
Select sum(normal_hours)
from per_all_assignments_f
where person_id = p_person_id
and p_effective_date between effective_start_date and effective_end_date
and assignment_status_type_id = 1
and primary_flag = p_flag;

--
l_normal_hours per_all_assignments_f.normal_hours%type;
l_consumed_hours per_all_assignments_f.normal_hours%type;
--
Begin
--
  Open csr_available_hours('N');
    Fetch csr_available_hours into l_consumed_hours;
  Close csr_available_hours;

  Open csr_available_hours('Y');
    Fetch csr_available_hours into l_normal_hours;
  Close csr_available_hours;

  Return l_normal_hours - nvl(l_consumed_hours,0);
--
End Get_available_hours;

--
FUNCTION get_salary_share (p_shard_type_cd IN VARCHAR2)
   RETURN VARCHAR2
IS
   CURSOR cur_bg_salary_share
   IS
      SELECT information1
        FROM per_shared_types
       WHERE lookup_type = 'FR_PQH_PHYSICAL_SHARE'
         AND business_group_id = hr_general.get_business_group_id
         AND system_type_cd = p_shard_type_cd;

   CURSOR global_salary_share
   IS
      SELECT information1
        FROM per_shared_types
       WHERE lookup_type = 'FR_PQH_PHYSICAL_SHARE'
         AND business_group_id IS NULL
         AND system_type_cd = p_shard_type_cd;

   l_salary_share   per_shared_types.information1%TYPE;
BEGIN
   OPEN cur_bg_salary_share;

   FETCH cur_bg_salary_share
    INTO l_salary_share;

   IF cur_bg_salary_share%FOUND
   THEN
      CLOSE cur_bg_salary_share;

      RETURN l_salary_share;
   END IF;

   CLOSE cur_bg_salary_share;

   OPEN global_salary_share;

   FETCH global_salary_share
    INTO l_salary_share;

   CLOSE global_salary_share;

   RETURN l_salary_share;
END get_salary_share;
--
Function Get_contract_reference(p_contract_id in Number, p_effective_date in Date) return varchar2
IS
Cursor csr_contract_ref IS
Select Reference
from per_contracts_f
where contract_id = p_contract_id
and p_effective_date between effective_start_date and effective_end_date;
--
l_contract_reference varchar2(240) := null;
Begin

 Open csr_contract_ref;
   Fetch csr_contract_ref into l_contract_reference;
 Close Csr_contract_ref;

 Return l_contract_reference;

End;
--
Function is_worker_employee(p_person_id in number, p_effective_date in date) return boolean
IS

Begin

return hr_person_type_usage_info.is_person_of_type
                (p_effective_date      => p_effective_date
                ,p_person_id           => p_person_id
                ,p_system_person_type  => 'EMP');

End is_worker_employee;

Function is_worker_CWK(p_person_id in number, p_effective_date in date) return boolean
IS
Begin

return hr_person_type_usage_info.is_person_of_type
                (p_effective_date      => p_effective_date
                ,p_person_id           => p_person_id
                ,p_system_person_type  => 'CWK');

End is_worker_CWK;
--
PROCEDURE Default_Employment_Terms(p_person_id IN NUMBER,
                                   p_emp_type IN VARCHAR2) IS
       l_agent_type   Varchar2(30);
       l_emp_type     Varchar2(30);
       CURSOR csr_primary_asg(p_person_id IN NUMBER) IS
	 SELECT assignment_id, object_version_number
	 FROM   per_all_assignments_f
	 WHERE  person_id = p_person_id
	 AND    hr_general.effective_date between effective_start_date and effective_end_date
	 AND    primary_flag = 'Y';
      l_asg_id   NUMBER(15);
      l_asg_ovn  NUMBER(9);
      l_scl_id   NUMBER(15);
       CURSOR csr_bg_hours(p_bg_id IN NUMBER) IS
	 SELECT working_hours, frequency
	 FROM   per_business_groups
	 WHERE  business_group_id = p_bg_id;
      l_bg_hours csr_bg_hours%ROWTYPE;
      l_cagr_grade_def_id NUMBER(15);
      l_cagr_grade_segments Varchar2(2000);
      l_conc_segments  varchar2(2000);
      l_comment_id NUMBER(15);
      l_esd   DATE;
      l_eed   DATE;
      l_no_mgrs boolean;
      l_other_mgrs BOOLEAN;
      l_hourly BOOLEAN;
      l_gsp_warn varchar2(2000);
--
--
Cursor csr_situation_details IS
	Select statutory_situation_id
	from pqh_fr_stat_situations_v sit , per_shared_types_vl sh
	where sh.shared_type_id = type_of_ps
	and   sh.system_type_cd = nvl(pqh_fr_utility.GET_BG_TYPE_OF_PS,sh.system_type_cd)
	and   sit.business_group_id =   hr_general.get_business_group_id
	and   sit.default_flag = 'Y'
        and   sit.situation_type = 'IA'
       	and   sit.sub_type = 'IA_N'
        and trunc(sysdate) between date_from and nvl(date_to,hr_general.end_of_time);
--
Cursor csr_person_details IS
   Select per.per_information15,  pps.orig_hire_dt
   from per_all_people_f per,
         (SELECT min(PPS1.DATE_START) orig_hire_dt
          FROM PER_PERIODS_OF_SERVICE PPS1
         WHERE pps1.person_id = p_person_id) pps
  where per.person_id =p_person_id
    and trunc(sysdate) between per.effective_start_date and per.effective_end_date;

/* --commented by deenath and replaced by above cursor
Cursor csr_person_details IS
   Select per_information15,original_date_of_hire
   from per_all_people_f
   where person_id =p_person_id
   and trunc(sysdate) between effective_start_date and effective_end_date;
*/


l_object_version_number number(9);
l_emp_stat_situation_id number(15);
l_statutory_situation_id number(15);
l_date_of_hire date;

BEGIN
    OPEN csr_primary_asg(p_person_id);
	   FETCH csr_primary_asg INTO l_asg_id, l_asg_ovn;
	   CLOSE csr_primary_asg;

	   OPEN csr_bg_hours(hr_general.get_business_group_id);
	   FETCH csr_bg_hours INTO l_bg_hours.working_hours, l_bg_hours.frequency;
	   CLOSE csr_bg_hours;

	   HR_ASSIGNMENT_API.update_emp_asg(
		       p_effective_date => hr_general.effective_date
		      ,p_datetrack_update_mode => 'CORRECTION'
		      ,p_assignment_id => l_asg_id
		      ,p_object_version_number => l_asg_ovn
		      ,p_normal_hours => fnd_number.canonical_to_number(l_bg_hours.working_hours)
		      ,p_frequency   => l_bg_hours.frequency
		      ,p_segment9 => '100'
		      ,p_segment2 => p_emp_type
		      ,p_soft_coding_keyflex_id => l_scl_id
		      ,p_cagr_grade_def_id =>  l_cagr_grade_def_id
		      ,p_cagr_concatenated_segments  => l_cagr_grade_segments
		      ,p_concatenated_segments =>   l_conc_segments
		      ,p_comment_id      => l_comment_id
		      ,p_effective_start_date  => l_esd
		      ,p_effective_end_date    => l_eed
		      ,p_no_managers_warning   => l_no_mgrs
		      ,p_other_manager_warning => l_other_mgrs
		      ,p_hourly_salaried_warning  => l_hourly
		      ,p_gsp_post_process_warning => l_gsp_warn);

    Open csr_person_details;
      Fetch csr_person_details into l_agent_type,l_date_of_hire;
     Close csr_person_details;

     If (l_agent_type = '01') Then
     --- Only For Fonctionnaire
     Open csr_situation_details;
       Fetch csr_situation_details into l_statutory_situation_id;
               --
       If csr_situation_details%NOTFOUND then
        --
        fnd_message.set_name('PQH','PQH_FR_NO_DEFAULT_SITUATION');
        hr_multi_message.add(p_message_type=>HR_MULTI_MESSAGE.G_ERROR_MSG);
        --
        End if;

     Close csr_situation_details;


         pqh_psu_ins.ins
         (
           p_effective_date                => trunc(sysdate)
           ,P_STATUTORY_SITUATION_ID        => l_statutory_situation_id
           ,P_PERSON_ID                     => p_person_id
           ,P_PROVISIONAL_START_DATE        => l_date_of_hire
           ,P_PROVISIONAL_END_DATE          => hr_general.end_of_time
           ,P_APPROVAL_FLAG                 => 'Y'
           ,P_ACTUAL_START_DATE             => l_date_of_hire
          ,P_EMP_STAT_SITUATION_ID         => l_emp_stat_situation_id
          ,P_OBJECT_VERSION_NUMBER         => l_object_version_number
         );


   ---
   End If;


EXCEPTION
  WHEN Others Then
   Raise;
END;
--
Function is_action_valid(p_function_name IN varchar2, p_person_id in Number,p_effective_date in Date)
return varchar2
IS
l_return_value varchar2(10) := 'Y';
Begin
--
    /* Its is a custom function, will be used in hrAdminActions/server/ActionsVO
     and this function in default return Y, and input parameters are function_name (Menu function
     name and person_id . Using this function developer can restrict any menu function to be restricted
     As per the FR requirments, for Agent Type = Fonctionnaire and Person Type is CWK worker then
     he/she will not have career definition.
   */
   If p_function_name = 'PQH_FR_HR_ADMIN_CAREER' Then
   --
     If is_worker_CWK(p_person_id,p_effective_date) Then
      --
       l_return_value := 'N';
       --
     End if;
   --
   End if;

   return l_return_value;
--
End is_action_valid;
---
Function get_position_name (p_admin_career_id in Varchar2, p_effective_date in Date) return varchar2
IS

Begin

return hr_general.decode_position_latest_name(get_position_id(p_admin_career_id,p_effective_date));

End get_position_name;

Function get_position_id (p_admin_career_id in Varchar2, p_effective_date in Date) return number
IS
Cursor csr_position_id IS
Select position_id
from per_all_assignments_f
where assignment_id = p_admin_career_id
and p_effective_date between effective_start_date and effective_end_date;
--
l_position_id Number;

Begin

   Open csr_position_id;
     Fetch csr_position_id into l_position_id;
   Close csr_position_id;

   Return l_position_id;
End get_position_id;



FUNCTION GET_STEP_RATE (p_step_id IN NUMBER, p_effective_date IN DATE, p_gl_currency IN VARCHAR2) RETURN NUMBER IS
Cursor csr_step_dtls(p_assignment_id IN NUMBER, p_effective_date IN DATE) IS
     SELECT psp.information1 "SCALE_TYPE",
            ssp.information1 "GROSS_INDEX",
            ssp.information2 "SALARY_RATE"
     FROM   per_spinal_point_steps_f sps,
            per_parent_spines psp,
            per_spinal_points ssp
     WHERE  sps.step_id  = p_step_id
     AND    p_effective_date BETWEEN sps.effective_start_date AND sps.effective_end_date
     AND    sps.spinal_point_id  = ssp.spinal_point_id
     AND    psp.parent_spine_id = ssp.parent_spine_id;

  l_step_dtls csr_step_dtls%ROWTYPE;

  l_inm   number(15);


  l_conv_factor number(22,5) := 1.0;

  l_step_rate Number(33,5) := 0;

  CURSOR  csr_sal_rate IS
   SELECT basic_salary_rate,
          currency_code
   FROM   pqh_fr_global_indices_f
   WHERE  type_of_record = 'INM'
   AND    p_effective_date BETWEEN effective_start_date AND effective_end_date;
  l_bareme_currency varchar2(30);
  l_bareme_salary_rate number(22,5);
BEGIN

  OPEN csr_step_dtls(p_step_id,p_effective_date);
  FETCH csr_step_dtls INTO l_step_dtls;
  CLOSE csr_step_dtls;

  IF l_step_dtls.scale_type = 'L' THEN -- for legislative scale
     l_inm := pqh_corps_utility.get_increased_index(l_step_dtls.gross_index,p_effective_date);
     OPEN csr_sal_rate;
     FETCH csr_sal_rate INTO l_bareme_salary_rate,l_bareme_currency;
     CLOSE csr_sal_rate;
     IF l_bareme_currency <> p_gl_currency THEN
       l_conv_factor := hr_currency_pkg.get_rate(p_from_currency => l_bareme_currency,
                                                  p_to_currency => p_gl_currency,
                                                  p_conversion_date => p_effective_date,
                                                  p_rate_type => 'Corporate');
     END IF;
     l_step_rate  := (l_inm*l_bareme_salary_rate)*l_conv_factor;
  ELSIF l_step_dtls.scale_type = 'E' THEN -- for exception scale
     l_step_rate := l_step_dtls.salary_rate;
  END IF;

    RETURN NVL(l_step_rate,0);

END get_step_rate;
--
--
--
  FUNCTION get_salary_rate(p_assignment_id NUMBER, p_effective_date DATE) RETURN NUMBER IS

  Cursor Csr_asg_dtls (p_assignment_id IN NUMBER, p_effective_date IN DATE) IS
   SELECT asg.person_id,
          asg.grade_ladder_pgm_id "GRADE_LADDER_PGM_ID",
          scl.segment9 "PHYSICAL_SHARE",
          pqh_fr_utility.Get_Salary_Share(scl.segment9) "SALARY_SHARE",
          scl.segment8 "EMP_STAT_SITUATION_ID",
          sps.step_id "STEP_ID",
          sps.information4 "PGI"
   FROM   per_all_assignments_f asg,
          hr_soft_coding_keyflex scl,
          per_spinal_point_placements_f sps
   WHERE  asg.assignment_id = p_assignment_id
   AND    p_effective_date BETWEEN asg.effective_start_date and asg.effective_end_date
   AND    asg.soft_coding_keyflex_id = scl.soft_coding_keyflex_id
   AND    asg.assignment_id = sps.assignment_id
   AND    p_effective_date BETWEEN sps.effective_start_date AND sps.effective_end_date;

   l_asg_dtls csr_asg_dtls%ROWTYPE;
  Cursor csr_agent_type(p_person_id IN Number, p_effective_date IN DATE) IS
    SELECT per_information15
    FROM   per_all_people_F
    WHERE  person_id = p_person_id
    AND    p_effective_date BETWEEN effective_start_date and effective_end_date;

    l_agent_type VARCHAR2(30);

 Cursor csr_sts_dtls (p_emp_stat_situation_id IN NUMBER) IS
  SELECT sts.situation_type,
         sts.sub_type,
         sts.remuneration_paid,
         sts.pay_share
  FROM   pqh_fr_stat_situations sts,
         pqh_fr_emp_stat_situations ess
  WHERE  ess.emp_stat_situation_id = p_emp_stat_situation_id
  AND    ess.statutory_situation_id = sts.statutory_situation_id;
  l_sts_dtls csr_sts_dtls%ROWTYPE;


  Cursor csr_gl_currency(p_gl_id IN NUMBER, p_effective_date IN DATE) IS
   SELECT pgm_uom
   FROM   ben_pgm_f
   WHERE  pgm_id = p_gl_id
   AND    p_effective_date BETWEEN effective_start_date AND effective_end_date;

   l_gl_currency ben_pgm_f.pgm_uom%TYPE;
   l_step_rate NUMBER(30,5);

   l_asg_salary NUMBER(30,5);
 BEGIN
  OPEN csr_asg_dtls(p_assignment_id, p_effective_date);
  FETCH csr_asg_dtls INTO l_asg_dtls;
  CLOSE csr_asg_dtls;
  OPEN csr_agent_type(l_asg_dtls.person_id,p_effective_date);
  FETCH csr_agent_type INTO l_agent_type;
  CLOSE csr_agent_type;
  IF l_asg_dtls.grade_ladder_pgm_id IS NOT NULL THEN
    OPEN csr_gl_currency(l_asg_dtls.grade_ladder_pgm_id,p_effective_date);
    FETCH csr_gl_currency INTO l_gl_currency;
    CLOSE csr_gl_currency;
  END IF;
  IF l_asg_dtls.pgi IS NOT NULL THEN
    l_step_rate := pqh_corps_utility.get_salary_rate(fnd_number.canonical_to_number(l_asg_dtls.pgi),p_effective_Date,null,l_gl_currency);
  ELSE
    l_step_rate := get_step_rate(l_asg_dtls.step_id, p_effective_date,l_gl_currency);
  END IF;

  IF l_agent_type = '01' THEN -- for fonctionnaires check for the current stat. sit.

   IF l_asg_dtls.emp_stat_situation_id IS NOT NULL   THEN
     OPEN csr_sts_dtls(l_asg_dtls.emp_stat_situation_id);
     FETCH csr_sts_dtls INTO l_sts_dtls;
     CLOSE csr_sts_dtls;
   END IF;

   IF NVL(l_sts_dtls.situation_type,'IA') = 'IA' AND NVL(l_sts_dtls.sub_type,'IA_N') = 'IA_N' THEN -- for inactivity-normal situation pay fully
     l_asg_salary := l_step_rate*nvl(fnd_number.canonical_to_number(l_asg_dtls.salary_share),100);
   ELSE

     IF NVL(l_sts_dtls.remuneration_paid,'Y') = 'N' THEN  -- if the situation doesn't entitle the civil servant for pay
       l_asg_salary := 0;
     ELSE -- situation allows the civil servant for pay
       l_asg_salary := l_step_rate*nvl(fnd_number.canonical_to_number(l_asg_dtls.salary_share),100)*nvl(l_sts_dtls.pay_share,0);
     END IF;

   END IF;

  ELSIF l_agent_type = '02' THEN -- for non-titulaires, no stat.sit.. so pay by salary share.
     l_asg_salary := l_step_rate*nvl(fnd_number.canonical_to_number(l_asg_dtls.salary_share),100);
  END IF;
  RETURN NVL(l_asg_salary,0);
 END get_salary_rate;
--
FUNCTION GET_DT_DIFF_FOR_DISPLAY(p_start_date IN DATE, p_end_date IN DATE) Return VARCHAR2
IS
l_return_value varchar2(100) :=null;

l_months number;
l_days number;

Begin

   l_months := trunc(months_between (p_end_date,p_start_date),0);
   l_days := p_end_date - add_months(p_start_date,l_months);

   l_return_value := l_months ||' '||hr_general.decode_lookup('QUALIFYING_UNITS','M')||
                     ' '||l_days ||' '||hr_general.decode_lookup('QUALIFYING_UNITS','D');

Return l_return_value;

End GET_DT_DIFF_FOR_DISPLAY;
--
Function GET_BG_TYPE_OF_PS RETURN VARCHAR2
IS
--
Cursor csr_get_bg_typ_of_ps IS
Select System_type_cd
from per_shared_types_vl sh , hr_organization_information O
where O.org_information_context = 'FR_PQH_GROUPING_UNIT_INFO'
and O.organization_id = hr_general.get_business_group_id
and sh.shared_type_id = o.org_information1;
--
l_return_value varchar2(10) := null;
Begin
--
   Open csr_get_bg_typ_of_ps;
     Fetch csr_get_bg_typ_of_ps into l_return_value;
   Close csr_get_bg_typ_of_ps;

Return l_return_value;

--
End GET_BG_TYPE_OF_PS;

function view_start_date(p_assignment_id in number,
                         p_start_date    in date,
                         p_action        in varchar2) return date is
   l_start_date date := p_start_date - 1;
   cursor csr_asg_affect is
          SELECT nvl(scl.segment23,'-999') Identifier,
                 scl.segment24  Type,
                 scl.segment27  seg27,
                 scl.segment26 seg26,
                 assign.position_id Position,
                 scl.segment25 PercentAffected,
                 assign.normal_hours WorkingHours,
                 assign.frequency    Frequency,
                 nvl(assign.supervisor_id,-999) Supervisor,
                 assign.effective_start_date,
                 assign.assignment_status_type_id
           from per_all_assignments_f assign, hr_soft_coding_keyflex scl
          WHERE assign.person_id = p_assignment_id
            AND  assign.soft_coding_keyflex_id = scl.soft_coding_keyflex_id
            AND  assign.primary_flag ='N'
            AND  assign.assignment_status_type_id <> 3
            and (assign.effective_start_date = p_start_date
                 or l_start_date between assign.effective_start_date and assign.effective_end_date)
          ORDER by assign.effective_start_date;

   cursor csr_asg_employ is
          SELECT asg.effective_start_date effective_start_date,
                 nvl(asg.establishment_id,-999)     establishment_id,
                 nvl(asg.employment_category, '-999')  category,
                 nvl(asg.normal_hours,-999)         normal_hours,
                 nvl(asg.frequency,'-999')            frequency,
                 nvl(scl.segment19,'-999')  reason,
                 nvl(scl.segment9,'-999')             share_part
           FROM per_all_assignments_f  asg,
                hr_soft_coding_keyflex scl,
                per_shared_types       pst
          WHERE asg.assignment_id          = p_assignment_id
            AND pst.shared_type_id(+)      = scl.segment9
            AND asg.soft_coding_keyflex_id = scl.soft_coding_keyflex_id(+)
            and (effective_start_date = p_start_date
                 or l_start_date between effective_start_date and effective_end_date)
          ORDER by effective_start_date;
 --
   CURSOR csr_asg_career IS
   SELECT asg.effective_start_date        effective_start_date
         ,scl.segment10                   employment_category
         ,NVL(asg.grade_ladder_pgm_id,-1) grade_ladder_pgm_id
         ,NVL(asg.grade_id,-1)            grade_id
     FROM per_all_assignments_f  asg
         ,hr_soft_coding_keyflex scl
    WHERE asg.assignment_id          = p_assignment_id
      AND asg.soft_coding_keyflex_id = scl.soft_coding_keyflex_id(+)
      AND(asg.effective_start_date   = p_start_date
       OR l_start_date BETWEEN asg.effective_start_date AND asg.effective_end_date)
    ORDER BY asg.effective_start_date;
 --

   l_old_start_date date;

   l_normal_hours per_all_assignments_f.normal_hours%type;
   l_supervisor_id per_all_assignments_f.supervisor_id%type;
   l_position per_all_assignments_f.position_id%type;
   l_frequency per_all_assignments_f.frequency%type;
   l_establish per_all_assignments_f.establishment_id%type;
   l_reason hr_soft_coding_keyflex.segment19%type;
   l_share hr_soft_coding_keyflex.segment9%type;
   l_seg26 hr_soft_coding_keyflex.segment26%type;
   l_seg27 hr_soft_coding_keyflex.segment27%type;
   l_identifier hr_soft_coding_keyflex.segment9%type;
   l_type hr_soft_coding_keyflex.segment9%type;
   l_percent number;
   l_category per_all_assignments_f.employment_category%type;
   l_assignment_status_type_id per_all_assignments_f.assignment_status_type_id%type;
   l_emp_catg       hr_soft_coding_keyflex.segment10%type;
   l_grd_ldr_pgm_id per_all_assignments_f.grade_ladder_pgm_id%type;
   l_grd_id         per_all_assignments_f.grade_id%type;

   l_old_normal_hours per_all_assignments_f.normal_hours%type;
   l_old_supervisor_id per_all_assignments_f.supervisor_id%type;
   l_old_position per_all_assignments_f.position_id%type;
   l_old_frequency per_all_assignments_f.frequency%type;
   l_old_establish per_all_assignments_f.establishment_id%type;
   l_old_reason hr_soft_coding_keyflex.segment19%type;
   l_old_share hr_soft_coding_keyflex.segment9%type;
   l_old_seg26 hr_soft_coding_keyflex.segment26%type;
   l_old_seg27 hr_soft_coding_keyflex.segment27%type;
   l_old_identifier hr_soft_coding_keyflex.segment9%type;
   l_old_type hr_soft_coding_keyflex.segment9%type;
   l_old_percent number;
   l_old_category per_all_assignments_f.employment_category%type;
   l_old_assign_status_type_id per_all_assignments_f.assignment_status_type_id%type;
   l_old_emp_catg       hr_soft_coding_keyflex.segment10%type;
   l_old_grd_ldr_pgm_id per_all_assignments_f.grade_ladder_pgm_id%type;
   l_old_grd_id         per_all_assignments_f.grade_id%type;

begin
-- this function is to be called from the view pages query to get the rows which are to be displayed
-- logic of this routine will be check the value change as of earlier date, if there is a change
-- then report true for this row otherwise return false
-- data to be compared is dependent on action code passed
-- cursor will return max 2 rows, we have to compare both the values

   if p_action = 'CAREER' then
    --
      FOR i IN csr_asg_career LOOP
          hr_utility.set_location('inside the career loop',10);
          hr_utility.set_location('start date is '||to_char(p_start_date,'ddmmyyyy'),10);
          hr_utility.set_location('asg start date is '||to_char(i.effective_start_date,'ddmmyyyy'),10);
          IF i.effective_start_date = p_start_date THEN
             hr_utility.set_location('current record',10);
             l_emp_catg       := i.employment_category;
             l_grd_ldr_pgm_id := i.grade_ladder_pgm_id;
             l_grd_id         := i.grade_id;
          ELSE
             hr_utility.set_location('previous record',10);
             l_old_start_date     := i.effective_start_date;
             l_old_emp_catg       := i.employment_category;
             l_old_grd_ldr_pgm_id := i.grade_ladder_pgm_id;
             l_old_grd_id         := i.grade_id;
          END IF;
      END LOOP;
      IF l_old_start_date IS NULL THEN
         hr_utility.set_location('1st exit',10);
         RETURN HR_GENERAL.end_of_time; --Returning end of time because we dont want to match it to asg.effective_start_date
      ELSE
         IF l_emp_catg <> l_old_emp_catg AND (l_grd_ldr_pgm_id = l_old_grd_ldr_pgm_id AND l_grd_id = l_old_grd_id) THEN
            hr_utility.set_location('3rd exit',10);
            RETURN p_start_date;
         ELSE
            hr_utility.set_location('2nd exit',10);
            RETURN HR_GENERAL.end_of_time; --Returning end of time because we dont want to match it to asg.effective_start_date
         END IF;
      END IF;
    --
   elsif p_action = 'EMPLOY' then
      for i in csr_asg_employ loop
          hr_utility.set_location('inside the employ loop',10);
          hr_utility.set_location('start date is '||to_char(p_start_date,'ddmmyyyy'),10);
          hr_utility.set_location('asg start date is '||to_char(i.effective_start_date,'ddmmyyyy'),10);
          if i.effective_start_date = p_start_date then
             hr_utility.set_location('current record',10);
             l_normal_hours := i.normal_hours;
             l_frequency := i.frequency;
             l_establish := i.establishment_id;
             l_category := i.category;
             l_reason := i.reason;
             l_share := i.share_part;
          else
             hr_utility.set_location('previous record',10);
             l_old_start_date := i.effective_start_date;
             l_old_normal_hours := i.normal_hours;
             l_old_frequency := i.frequency;
             l_old_establish := i.establishment_id;
             l_old_category := i.category;
             l_old_reason := i.reason;
             l_old_share := i.share_part;
          end if;
      end loop;
      if l_old_start_date is null then
         hr_utility.set_location('1st exit',10);
         return p_start_date;
      else
         if l_normal_hours = l_old_normal_hours
            and l_frequency = l_old_frequency
            and l_establish = l_old_establish
            and l_category = l_old_category
            and l_reason = l_old_reason
            and l_share = l_old_share then
         hr_utility.set_location('2nd exit',10);
           return l_old_start_date;
        else
         hr_utility.set_location('3rd exit',10);
           return p_start_date;
        end if;
      end if;
   elsif p_action = 'AFFECT' then
      for i in csr_asg_affect loop
          hr_utility.set_location('inside the affect loop',10);
          hr_utility.set_location('start date is '||to_char(p_start_date,'ddmmyyyy'),10);
          hr_utility.set_location('asg start date is '||to_char(i.effective_start_date,'ddmmyyyy'),10);
          if i.effective_start_date = p_start_date then
             hr_utility.set_location('current record',10);
             l_identifier := i.identifier;
             l_type := i.type;
             l_seg27 := i.seg27;
             l_seg26 := i.seg26;
             l_position := i.position;
             l_percent := i.percentaffected;
             l_normal_hours := i.workinghours;
             l_frequency := i.frequency;
             l_supervisor_id := i.supervisor;
             l_assignment_status_type_id := i.assignment_status_type_id;
          else
             hr_utility.set_location('previous record',10);
             l_old_identifier := i.identifier;
             l_old_type := i.type;
             l_old_seg27 := i.seg27;
             l_old_seg26 := i.seg26;
             l_old_position := i.position;
             l_old_percent := i.percentaffected;
             l_old_normal_hours := i.workinghours;
             l_old_frequency := i.frequency;
             l_old_supervisor_id := i.supervisor;
             l_old_start_date := i.effective_start_date;
             l_old_assign_status_type_id := i.assignment_status_type_id;
          end if;
      end loop;
      if l_old_start_date is null then
         hr_utility.set_location('1st exit',10);
         return p_start_date;
      else
         if l_old_identifier = l_identifier
            and l_old_type = l_type
            and l_old_seg27 = l_seg27
            and l_old_seg26 = l_seg26
            and l_old_position = l_position
            and l_old_percent = l_percent
            and l_old_normal_hours = l_normal_hours
            and l_old_frequency = l_frequency
            and l_old_supervisor_id = l_supervisor_id
            and l_old_assign_status_type_id = l_assignment_status_type_id then
         hr_utility.set_location('2nd exit',10);
           return l_old_start_date;
        else
         hr_utility.set_location('3rd exit',10);
           return p_start_date;
        end if;
      end if;
   else
      hr_utility.set_location('invalid action passed'||p_action,10);
   end if;

end view_start_date;
  --
  ------------------------------------------------------------------------------
  --------------------------< get_proposed_end_date >---------------------------
  ------------------------------------------------------------------------------
  FUNCTION get_proposed_end_date(p_contract_id      IN NUMBER,
                                 p_effective_date   IN DATE)
  RETURN DATE IS
  --
  --Cursor to fetch duration and extension details for the Contract
    CURSOR csr_contract_dtls IS
    SELECT status, duration, duration_units,
           extension_period, extension_period_units, number_of_extensions
      FROM per_contracts_f
     WHERE contract_id            = NVL(p_contract_id,-1)
       AND p_effective_date BETWEEN effective_start_date AND effective_end_date;

  --Variable Declaration.
    l_status            PER_CONTRACTS_F.status%TYPE;
    l_duration          PER_CONTRACTS_F.duration%TYPE;
    l_duration_units    PER_CONTRACTS_F.duration_units%TYPE;
    l_extension         PER_CONTRACTS_F.extension_period%TYPE;
    l_extension_units   PER_CONTRACTS_F.extension_period_units%TYPE;
    l_no_of_extensions  PER_CONTRACTS_F.number_of_extensions%TYPE;
    l_start_date        DATE;
    l_proposed_end_date DATE;
  --
  BEGIN
  --
    OPEN csr_contract_dtls;
    FETCH csr_contract_dtls INTO l_status,l_duration,l_duration_units,
                                 l_extension,l_extension_units,l_no_of_extensions;
    IF csr_contract_dtls%NOTFOUND THEN
       CLOSE csr_contract_dtls;
       RETURN NULL;
    END IF;
    IF csr_contract_dtls%ISOPEN THEN
       CLOSE csr_contract_dtls;
    END IF;
  --
    l_start_date := HR_CONTRACT_API.get_active_start_date(p_contract_id,p_effective_date,l_status);
  --
    IF l_duration_units = 'Y' THEN
       l_proposed_end_date := ADD_MONTHS(l_start_date,NVL(l_duration,0)*12);
    ELSIF l_duration_units = 'M' THEN
       l_proposed_end_date := ADD_MONTHS(l_start_date,NVL(l_duration,0));
    ELSIF l_duration_units = 'W' THEN
       l_proposed_end_date := l_start_date+(NVL(l_duration,0)*7);
    ELSIF l_duration_units = 'H' THEN
       l_proposed_end_date := l_start_date+(NVL(l_duration,0)/24);
    ELSE
       l_proposed_end_date := l_start_date;
    END IF;
  --
    FOR i IN 1..NVL(l_no_of_extensions,0)
    LOOP
        IF l_extension_units = 'Y' THEN
           l_proposed_end_date := ADD_MONTHS(l_proposed_end_date,NVL(l_extension,0)*12);
        ELSIF l_extension_units = 'M' THEN
           l_proposed_end_date := ADD_MONTHS(l_proposed_end_date,NVL(l_extension,0));
        ELSIF l_extension_units = 'W' THEN
           l_proposed_end_date := l_proposed_end_date+(NVL(l_extension,0)*7);
        ELSIF l_extension_units = 'H' THEN
           l_proposed_end_date := l_proposed_end_date+(NVL(l_extension,0)/24);
        ELSE
           l_proposed_end_date := l_proposed_end_date;
        END IF;
    END LOOP;
  --
    RETURN TRUNC(l_proposed_end_date);
  --
  END get_proposed_end_date;
  --
  ------------------------------------------------------------------------------
  --------------------------< diff_corps_attributes >---------------------------
  ------------------------------------------------------------------------------
  FUNCTION diff_corps_attributes(p_old_ben_pgm_id    IN VARCHAR2,
                                 p_new_ben_pgm_id    IN VARCHAR2,
                                 p_primary_assign_id IN NUMBER,
                                 p_effective_date    IN DATE)
  RETURN VARCHAR2 IS
  --
  --Cursor to check whether different Corp Affectations exist
    CURSOR csr_diff_corps_asg IS
    SELECT 'Y'
      FROM per_all_assignments_f       asg,
           hr_soft_coding_keyflex      scl,
           per_assignment_status_types ast
     WHERE scl.segment26                 = to_char(p_primary_assign_id)  --changed for bug 7211180
       AND asg.soft_coding_keyflex_id    = scl.soft_coding_keyflex_id
       AND ast.per_system_status         = 'ACTIVE_ASSIGN'
       AND asg.assignment_status_type_id = ast.assignment_status_type_id
       AND asg.primary_flag              = 'N'
       AND p_effective_date BETWEEN asg.effective_start_date AND NVL(asg.effective_end_date,HR_GENERAL.end_of_time)
       AND asg.position_id  NOT IN(SELECT position_id
                                     FROM hr_all_positions_f
                                    WHERE information_category = 'FR_PQH'
                                      AND information10 =(SELECT TO_CHAR(corps_definition_id)
                                                            FROM pqh_corps_definitions
                                                           WHERE ben_pgm_id             = TO_NUMBER(p_new_ben_pgm_id)
                                                             AND p_effective_date BETWEEN date_from
                                                                                      AND NVL(date_to,HR_GENERAL.end_of_time))
                                      AND p_effective_date BETWEEN effective_start_date
                                                               AND NVL(effective_end_date,HR_GENERAL.end_of_time));
  --
  --Cursor to fetch working hours.
    CURSOR csr_working_hours(p_ben_pgm_id NUMBER) IS
    SELECT NVL(normal_hours,0), NVL(normal_hours_frequency,'X')
      FROM pqh_corps_definitions
     WHERE ben_pgm_id             = p_ben_pgm_id
       AND p_effective_date BETWEEN date_from AND NVL(date_to,HR_GENERAL.end_of_time);
  --
  --Variable Declarations.
    l_old_hours         NUMBER;
    l_old_frequency     VARCHAR2(01);
    l_new_hours         NUMBER;
    l_new_frequency     VARCHAR2(01);
    l_diff_corps_affect VARCHAR2(01);
    l_diff_work_hours   VARCHAR2(01);
    l_return_status     VARCHAR2(01);
  --
  BEGIN
  --
  --Check if Affectations exist outside new corp.
    IF p_new_ben_pgm_id IS NOT NULL THEN
       OPEN csr_diff_corps_asg;
       FETCH csr_diff_corps_asg INTO l_diff_corps_affect;
       IF csr_diff_corps_asg%NOTFOUND THEN
          l_diff_corps_affect := 'N';
       END IF;
       IF csr_diff_corps_asg%ISOPEN THEN
          CLOSE csr_diff_corps_asg;
       END IF;
    ELSE
       l_diff_corps_affect := 'N';
    END IF;
  --
  --Get Old Corp working hours.
    IF p_old_ben_pgm_id IS NOT NULL AND UPPER(p_old_ben_pgm_id) <> 'NULL' THEN
       OPEN csr_working_hours(TO_NUMBER(p_old_ben_pgm_id));
       FETCH csr_working_hours INTO l_old_hours,l_old_frequency;
       IF csr_working_hours%NOTFOUND THEN
          l_old_hours := 0;
          l_old_frequency := 'X';
       END IF;
       IF csr_working_hours%ISOPEN THEN
          CLOSE csr_working_hours;
       END IF;
    ELSE
       l_old_hours := 0;
       l_old_frequency := 'X';
    END IF;
  --
  --Get New Corp working hours.
    IF p_new_ben_pgm_id IS NOT NULL THEN
       OPEN csr_working_hours(TO_NUMBER(p_new_ben_pgm_id));
       FETCH csr_working_hours INTO l_new_hours,l_new_frequency;
       IF csr_working_hours%NOTFOUND THEN
          l_new_hours := 0;
          l_new_frequency := 'X';
       END IF;
       IF csr_working_hours%ISOPEN THEN
          CLOSE csr_working_hours;
       END IF;
    ELSE
       l_new_hours := 0;
       l_new_frequency := 'X';
    END IF;
  --
  --Check whether old and new hours are different.
   IF p_old_ben_pgm_id IS NOT NULL AND UPPER(p_old_ben_pgm_id) <> 'NULL' THEN
    IF ((l_old_hours = l_new_hours) AND (l_old_frequency = l_new_frequency)) THEN
       l_diff_work_hours := 'N';
    ELSE
       l_diff_work_hours := 'Y';
    END IF;
   ELSE
       l_diff_work_hours := 'N';
   END IF;

  --
  --Set Return Status.
    IF l_diff_corps_affect = 'Y' AND l_diff_work_hours = 'Y' THEN
       l_return_status := 'B'; --Both are different
    ELSIF l_diff_corps_affect = 'Y' AND l_diff_work_hours = 'N' THEN
       l_return_status := 'A'; --Affectations exist outside new Corps but Working Hours didnt change
    ELSIF l_diff_corps_affect = 'N' AND l_diff_work_hours = 'Y' THEN
       l_return_status := 'H'; --Affectations dont exist outside new Corps but Working Hours have changed
    ELSIF l_diff_corps_affect = 'N' AND l_diff_work_hours = 'N' THEN
       l_return_status := 'N'; --No Affectations outside new Corp and no change in Working Hours
    ELSE
       l_return_status := 'E';
    END IF;
  --
    RETURN l_return_status;
  --
  END diff_corps_attributes;
  --
  ------------------------------------------------------------------------------
  ------------------------------< check_work_hrs >------------------------------
  ------------------------------------------------------------------------------
  FUNCTION check_work_hrs(p_old_estab_id   IN VARCHAR2,
                          p_new_estab_id   IN VARCHAR2,
                          p_effective_date IN DATE)
  RETURN VARCHAR2 IS
  --
    CURSOR csr_working_hours(p_estab_id NUMBER) IS
    SELECT FND_NUMBER.canonical_to_number(org_information4) hours, 'M' frequency
      FROM hr_organization_information_v
     WHERE org_information_context = 'FR_ESTAB_INFO'
       AND organization_id = p_estab_id;
  --
  --Variable Declarations.
    l_old_hours         NUMBER;
    l_old_frequency     VARCHAR2(01);
    l_new_hours         NUMBER;
    l_new_frequency     VARCHAR2(01);
    l_diff_work_hours   VARCHAR2(01);
  --
  BEGIN
  --
    l_diff_work_hours := 'N';
  --
  --Get Old Estab working hours.
    IF p_old_estab_id IS NOT NULL AND UPPER(p_old_estab_id) <> 'NULL' THEN
       OPEN csr_working_hours(TO_NUMBER(p_old_estab_id));
       FETCH csr_working_hours INTO l_old_hours,l_old_frequency;
       IF csr_working_hours%NOTFOUND THEN
          l_old_hours := 0;
          l_old_frequency := 'X';
       END IF;
       IF csr_working_hours%ISOPEN THEN
          CLOSE csr_working_hours;
       END IF;
    ELSE
       l_old_hours := 0;
       l_old_frequency := 'X';
    END IF;
  --
  --Get New Estab working hours.
    IF p_new_estab_id IS NOT NULL THEN
       OPEN csr_working_hours(TO_NUMBER(p_new_estab_id));
       FETCH csr_working_hours INTO l_new_hours,l_new_frequency;
       IF csr_working_hours%NOTFOUND THEN
          l_new_hours := 0;
          l_new_frequency := 'X';
       END IF;
       IF csr_working_hours%ISOPEN THEN
          CLOSE csr_working_hours;
       END IF;
    ELSE
       l_new_hours := 0;
       l_new_frequency := 'X';
    END IF;
  --
  --Check whether old and new hours are different.
  IF p_old_estab_id IS NOT NULL AND UPPER(p_old_estab_id) <> 'NULL' THEN
    IF ((l_old_hours = l_new_hours) AND (l_old_frequency = l_new_frequency)) THEN
       l_diff_work_hours := 'N';
    ELSE
       l_diff_work_hours := 'Y';
    END IF;
  ELSE
       l_diff_work_hours := 'N';
  END IF;
  --
    RETURN l_diff_work_hours;
  --
  END check_work_hrs;
  --

function view_end_date(p_assignment_id in number,
                         p_person_id in number,
                         p_start_date    in date,
                         p_action        in varchar2) return date is
   l_end_date date := null;
   l_assignment_id number;

   cursor csr_asg_affect is
          SELECT nvl(scl.segment23,'-999') Identifier,
                 scl.segment24  Type,
                 nvl(scl.segment27,'-999')  seg27,
                 nvl(scl.segment26,'-999') seg26,
                 nvl(assign.position_id,-999) Position,
                 nvl(scl.segment25,-999) PercentAffected,
                 nvl(assign.normal_hours,-999) WorkingHours,
                 nvl(assign.frequency, '-999')    Frequency,
                 nvl(assign.supervisor_id,-999) Supervisor,
                 assign.effective_start_date,
                 assign.assignment_status_type_id,
                 assign.effective_end_date
           from per_all_assignments_f assign, hr_soft_coding_keyflex scl
          WHERE assign.person_id = p_person_id
	    AND  assign.assignment_id = l_assignment_id
            AND  assign.soft_coding_keyflex_id = scl.soft_coding_keyflex_id
            AND  assign.primary_flag ='N'
            AND  assign.assignment_status_type_id <> 3
            and (assign.effective_start_date = p_start_date
                 or effective_start_date > l_end_date)
          ORDER by assign.effective_start_date;

   cursor csr_end_date is
   SELECT asg.effective_end_date effective_end_date
           FROM per_all_assignments_f  asg
           WHERE asg.assignment_id   = l_assignment_id
            and effective_start_date = p_start_date;

   cursor csr_asg_employ is
          SELECT asg.effective_start_date effective_start_date,
                 nvl(asg.establishment_id,-999)     establishment_id,
                 nvl(asg.employment_category, '-999')  category,
                 nvl(asg.normal_hours,-999)         normal_hours,
                 nvl(asg.frequency,'-999')            frequency,
                 nvl(scl.segment19,'-999')  reason,
                 nvl(scl.segment9,'-999')             share_part,
                 asg.effective_end_date effective_end_date
           FROM per_all_assignments_f  asg,
                hr_soft_coding_keyflex scl,
                per_shared_types       pst
          WHERE asg.assignment_id          = p_assignment_id
            AND pst.shared_type_id(+)      = scl.segment9
            AND asg.soft_coding_keyflex_id = scl.soft_coding_keyflex_id(+)
            and (effective_start_date = p_start_date
                 or effective_start_date > l_end_date )
          ORDER by effective_start_date;
  --
    CURSOR csr_asg_career IS
    SELECT asg.effective_start_date        effective_start_date
          ,scl.segment10                   employment_category
          ,NVL(asg.grade_ladder_pgm_id,-1) grade_ladder_pgm_id
          ,NVL(asg.grade_id,-1)            grade_id
          ,asg.effective_end_date          effective_end_date
      FROM per_all_assignments_f  asg
          ,hr_soft_coding_keyflex scl
     WHERE asg.assignment_id          = p_assignment_id
       AND asg.soft_coding_keyflex_id = scl.soft_coding_keyflex_id(+)
       AND(asg.effective_start_date   = p_start_date
        OR asg.effective_start_date   > l_end_date)
     ORDER BY asg.effective_start_date;
  --
   l_fut_start_date date;
   l_fut_end_date date;

--   l_end_date date;

   l_normal_hours per_all_assignments_f.normal_hours%type;
   l_supervisor_id per_all_assignments_f.supervisor_id%type;
   l_position per_all_assignments_f.position_id%type;
   l_frequency per_all_assignments_f.frequency%type;
   l_establish per_all_assignments_f.establishment_id%type;
   l_reason hr_soft_coding_keyflex.segment19%type;
   l_share hr_soft_coding_keyflex.segment9%type;
   l_seg26 hr_soft_coding_keyflex.segment26%type;
   l_seg27 hr_soft_coding_keyflex.segment27%type;
   l_identifier hr_soft_coding_keyflex.segment9%type;
   l_type hr_soft_coding_keyflex.segment9%type;
   l_percent number;
   l_category per_all_assignments_f.employment_category%type;
   l_assignment_status_type_id per_all_assignments_f.assignment_status_type_id%type;
   l_grd_ldr_pgm_id per_all_assignments_f.grade_ladder_pgm_id%type;
   l_grade_id       per_all_assignments_f.grade_id%type;
   l_emp_cat        per_all_assignments_f.employment_category%type;

   l_fut_normal_hours per_all_assignments_f.normal_hours%type;
   l_fut_supervisor_id per_all_assignments_f.supervisor_id%type;
   l_fut_position per_all_assignments_f.position_id%type;
   l_fut_frequency per_all_assignments_f.frequency%type;
   l_fut_establish per_all_assignments_f.establishment_id%type;
   l_fut_reason hr_soft_coding_keyflex.segment19%type;
   l_fut_share hr_soft_coding_keyflex.segment9%type;
   l_fut_seg26 hr_soft_coding_keyflex.segment26%type;
   l_fut_seg27 hr_soft_coding_keyflex.segment27%type;
   l_fut_identifier hr_soft_coding_keyflex.segment9%type;
   l_fut_type hr_soft_coding_keyflex.segment9%type;
   l_fut_percent number;
   l_fut_category per_all_assignments_f.employment_category%type;
   l_fut_assign_status_type_id per_all_assignments_f.assignment_status_type_id%type;
   l_fut_grd_ldr_pgm_id per_all_assignments_f.grade_ladder_pgm_id%type;
   l_fut_grade_id       per_all_assignments_f.grade_id%type;
   l_fut_emp_cat        per_all_assignments_f.employment_category%type;

   l_return_end_date date;
begin
-- this function is to be called from the view pages query to get the rows which are to be displayed
-- logic of this routine will be check the value change as of earlier date, if there is a change
-- then report true for this row otherwise return false
-- data to be compared is dependent on action code passed
-- cursor will return max 2 rows, we have to compare both the values

   if p_action = 'CAREER' then
    --
      l_assignment_id := p_assignment_id;
      FOR i IN csr_end_date LOOP
          l_end_date := i.effective_end_date;
      END LOOP;
      FOR i IN csr_asg_career LOOP
          hr_utility.set_location('inside the career loop',10);
          hr_utility.set_location('start date is '||to_char(p_start_date,'ddmmyyyy'),10);
          hr_utility.set_location('asg start date is '||to_char(i.effective_start_date,'ddmmyyyy'),10);
          IF i.effective_start_date = p_start_date THEN
             hr_utility.set_location('current record',10);
             l_grd_ldr_pgm_id := i.grade_ladder_pgm_id;
             l_grade_id       := i.grade_id;
             l_emp_cat        := i.employment_category;
             l_end_date       := i.effective_end_date;
          ELSE
             hr_utility.set_location('future record',10);
             l_fut_start_date     := i.effective_start_date;
             l_fut_grd_ldr_pgm_id := i.grade_ladder_pgm_id;
             l_fut_grade_id       := i.grade_id;
             l_fut_emp_cat        := i.employment_category;
             l_fut_end_date       := i.effective_end_date;
          END IF;
          IF l_fut_start_date IS NULL THEN
             hr_utility.set_location('first time in loop',10);
             l_return_end_date := l_end_date;
          ELSE
             IF l_grd_ldr_pgm_id=l_fut_grd_ldr_pgm_id AND l_grade_id=l_fut_grade_id AND l_emp_cat=l_fut_emp_cat THEN
                hr_utility.set_location('equality condition satisfied',10);
                l_return_end_date := l_fut_end_date;
             ELSE
                hr_utility.set_location('Equality condition not satisfied',10);
                EXIT;
             END IF;
          END IF;
      END LOOP;
      hr_utility.set_location('Out of loop',10);
      RETURN l_return_end_date;
    --
   elsif p_action = 'EMPLOY' then

      l_assignment_id := p_assignment_id;
      for i in csr_end_date loop
         l_end_date := i.effective_end_date;
      end loop;
      for i in csr_asg_employ loop
          hr_utility.set_location('inside the employ loop',10);
          hr_utility.set_location('start date is '||to_char(p_start_date,'ddmmyyyy'),10);
          hr_utility.set_location('asg start date is '||to_char(i.effective_start_date,'ddmmyyyy'),10);
          if i.effective_start_date = p_start_date then
             hr_utility.set_location('current record',10);
             l_normal_hours := i.normal_hours;
             l_frequency := i.frequency;
             l_establish := i.establishment_id;
             l_category := i.category;
             l_reason := i.reason;
             l_share := i.share_part;
             l_end_date := i.effective_end_date;
          else
             hr_utility.set_location('previous record',10);
             l_fut_start_date := i.effective_start_date;
             l_fut_normal_hours := i.normal_hours;
             l_fut_frequency := i.frequency;
             l_fut_establish := i.establishment_id;
             l_fut_category := i.category;
             l_fut_reason := i.reason;
             l_fut_share := i.share_part;
             l_fut_end_date := i.effective_end_date;
          end if;
          if l_fut_start_date is null then
                hr_utility.set_location('first time in loop',10);
                l_return_end_date := l_end_date;
          else
               if l_normal_hours = l_fut_normal_hours
               and l_frequency = l_fut_frequency
               and l_establish = l_fut_establish
               and l_category = l_fut_category
               and l_reason = l_fut_reason
               and l_share = l_fut_share then
                 hr_utility.set_location('equality condition satisfied',10);
                 l_return_end_date := l_fut_end_date;
               else
                 hr_utility.set_location('Equality condition not satisfied',10);
                 exit;
              end if;
         end if;
      end loop;
          hr_utility.set_location('Out of loop',10);
         return l_return_end_date;
    elsif p_action = 'AFFECT' then
         l_assignment_id := p_assignment_id;
         for i in csr_end_date loop
           l_end_date := i.effective_end_date;
         end loop;
         for i in csr_asg_affect loop
            hr_utility.set_location('inside the affect loop',10);
            hr_utility.set_location('start date is '||to_char(p_start_date,'ddmmyyyy'),10);
            hr_utility.set_location('asg start date is '||to_char(i.effective_start_date,'ddmmyyyy'),10);
            if i.effective_start_date = p_start_date then
              hr_utility.set_location('current record',10);
              l_identifier := i.identifier;
              l_type := i.type;
              l_seg27 := i.seg27;
              l_seg26 := i.seg26;
              l_position := i.position;
              l_percent := i.percentaffected;
              l_normal_hours := i.workinghours;
              l_frequency := i.frequency;
              l_supervisor_id := i.supervisor;
              l_assignment_status_type_id := i.assignment_status_type_id;
              l_end_date := i.effective_end_date;
            else
              hr_utility.set_location('previous record',10);
              l_fut_identifier := i.identifier;
              l_fut_type := i.type;
              l_fut_seg27 := i.seg27;
              l_fut_seg26 := i.seg26;
              l_fut_position := i.position;
              l_fut_percent := i.percentaffected;
              l_fut_normal_hours := i.workinghours;
              l_fut_frequency := i.frequency;
              l_fut_supervisor_id := i.supervisor;
              l_fut_start_date := i.effective_start_date;
              l_fut_assign_status_type_id := i.assignment_status_type_id;
              l_fut_end_date := i.effective_end_date;
          end if;
          if l_fut_start_date is null then
                hr_utility.set_location('first time in loop',10);
                l_return_end_date := l_end_date;
          else
            if l_fut_identifier = l_identifier
               and l_fut_type = l_type
               and l_fut_seg27 = l_seg27
               and l_fut_seg26 = l_seg26
               and l_fut_position = l_position
               and l_fut_percent = l_percent
               and l_fut_normal_hours = l_normal_hours
               and l_fut_frequency = l_frequency
               and l_fut_supervisor_id = l_supervisor_id
               and l_fut_assign_status_type_id = l_assignment_status_type_id then
               hr_utility.set_location('equality condition satisfied',10);
                 l_return_end_date := l_fut_end_date;
            else
                 hr_utility.set_location('Equality condition not satisfied',10);
                 exit;
            end if;
          end if;
      end loop;
      hr_utility.set_location('Out of loop',10);
      return l_return_end_date;
   else
      hr_utility.set_location('invalid action passed'||p_action,10);
      return null;
   end if;

end view_end_date;

 FUNCTION diff_corps_positions(p_pos_id    IN VARCHAR2,
                                 p_primary_assign_id IN NUMBER,
                                 p_effective_date    IN DATE)
  RETURN VARCHAR2 IS
  --Cursor to get the Corp id for the current Position
  Cursor csr_pos_corp is
  SELECT information10  corps_id
  FROM hr_positions_f
  WHERE  p_effective_date between effective_start_date and effective_end_date
  AND    position_id = p_pos_id;

 --Cursor to get the Corp id for the Career Definition for the person
  Cursor csr_career_corp is
  Select Corps_Definition_Id
  From  Pqh_Corps_Definitions
  where  Ben_Pgm_Id in (select grade_ladder_pgm_id
  from per_all_assignments_f
  where assignment_id = p_primary_assign_id
  and p_effective_date between effective_start_date and effective_end_date
  and primary_flag = 'Y' );

  --Variable Declarations.
    l_pos_corps_id       NUMBER;
    l_career_corps_id    NUMBER;
    l_return_status     VARCHAR2(01);

  BEGIN
    OPEN csr_pos_corp;
       FETCH csr_pos_corp INTO l_pos_corps_id;
    CLOSE csr_pos_corp;

    OPEN csr_career_corp;
       FETCH csr_career_corp INTO l_career_corps_id ;
    CLOSE csr_career_corp;

    if l_career_corps_id <> l_pos_corps_id then
       l_return_status := 'D';
    else
       l_return_status :=  'S';
    end if;

  RETURN l_return_status;
  --
  END diff_corps_positions;
  --
  ------------------------------------------------------------------------------
  ---------------------------< get_ps_org_cat_info >----------------------------
  ------------------------------------------------------------------------------
  FUNCTION get_ps_org_cat_info(p_person_id      NUMBER,
                               p_effective_date DATE) RETURN VARCHAR2 IS
  --
  --Cursor to fetch Type Of PS Information1 for BG Org.
    CURSOR csr_ps_info IS
    SELECT information1
      FROM per_shared_types
     WHERE lookup_type    = 'FR_PQH_ORG_CATEGORY'
       AND shared_type_id =(SELECT org_information1
                              FROM hr_organization_information
                             WHERE org_information_context = 'FR_PQH_GROUPING_UNIT_INFO'
                               AND organization_id         =(SELECT business_group_id
                                                               FROM per_all_people_f
                                                              WHERE person_id = p_person_id
                                                                AND p_effective_date BETWEEN effective_start_date
                                                                                         AND effective_end_date));
  --
  --Variable Declarations.
    l_ps_info VARCHAR2(01);
  --
  BEGIN
  --
    OPEN csr_ps_info;
    FETCH csr_ps_info INTO l_ps_info;
    IF csr_ps_info%NOTFOUND THEN
       l_ps_info := 'N';
    END IF;
    IF csr_ps_info%ISOPEN THEN
       CLOSE csr_ps_info;
    END IF;
  --
    RETURN l_ps_info;
  --
  END get_ps_org_cat_info;
  --
  ------------------------------------------------------------------------------
  ---------------------------------< get_ps >-----------------------------------
  ------------------------------------------------------------------------------
  --This function is same as get_lookup_shared_types but because of Web ADI
  --Integrator Col limitations created this function so as to reduce size of
  --fn call in query to fit Val_Object_Name Column size for Type_Of_PS LOV.
  ------------------------------------------------------------------------------
  FUNCTION get_ps(p_lookup_code  VARCHAR2
                 ,p_return_value VARCHAR2) RETURN VARCHAR2 IS
  --
    CURSOR csr_glb_shared_types IS
    SELECT shared_type_id, shared_type_name
      FROM per_shared_types_vl
     WHERE lookup_type        = 'FR_PQH_ORG_CATEGORY'
       AND system_type_cd     = p_lookup_code
       AND business_group_id IS NULL;
  --
    CURSOR csr_bg_shared_types IS
    SELECT shared_type_id, shared_type_name
      FROM per_shared_types_vl
     WHERE lookup_type       = 'FR_PQH_ORG_CATEGORY'
       AND system_type_cd    = p_lookup_code
       AND business_group_id = HR_GENERAL.get_business_group_id;
  --
    l_bg_return csr_bg_shared_types%ROWTYPE;
    l_glb_return csr_glb_shared_types%ROWTYPE;
  --
  BEGIN
  --
    OPEN csr_bg_shared_types;
    FETCH csr_bg_shared_types INTO l_bg_return;
    IF csr_bg_shared_types%FOUND THEN
       CLOSE csr_bg_shared_types;
       IF p_return_value = 'ID' THEN
          RETURN l_bg_return.shared_type_id;
           ELSE
          RETURN l_bg_return.shared_type_name;
       END IF;
    ELSE
       CLOSE csr_bg_shared_types;
    END IF;
  --
    OPEN csr_glb_shared_types;
    FETCH csr_glb_shared_types INTO l_glb_return;
    CLOSE csr_glb_shared_types;
    IF p_return_value = 'ID' THEN
       RETURN l_glb_return.shared_type_id;
    ELSE
       RETURN l_glb_return.shared_type_name;
    END IF;
  --
  END get_ps;
  --
FUNCTION get_currency_desc(p_currency_code IN VARCHAR2) RETURN VARCHAR2
IS
  CURSOR c_currency_cur IS
  SELECT t.description
    FROM fnd_currencies    a
        ,fnd_currencies_tl t
   WHERE a.currency_code = p_currency_code
     AND t.currency_code = a.currency_code
     AND t.language      = USERENV('LANG');
  v_currency_desc VARCHAR2(240);
BEGIN
  IF p_currency_code IS NOT NULL THEN
    OPEN c_currency_cur;
    FETCH c_currency_cur INTO v_currency_desc;
    CLOSE c_currency_cur;
  END IF;
  RETURN v_currency_desc;
EXCEPTION
  WHEN OTHERS THEN
    IF c_currency_cur%ISOPEN THEN
      CLOSE c_currency_cur;
    END IF;
    RETURN NULL;
END get_currency_desc;
--
FUNCTION get_owner_desc(p_org_id         IN NUMBER
                       ,p_effective_date IN DATE) RETURN VARCHAR2
IS
  CURSOR c_owner_cur IS
  SELECT hru.name
    FROM hr_all_organization_units   hru
        ,hr_organization_information hri
   WHERE hru.organization_id         = p_org_id
     AND hru.organization_id         = hri.organization_id
     AND hri.org_information_context = 'CLASS'
     AND hri.org_information1 IN ('FR_ETABLISSEMENT','FR_SOCIETE','HR_BG')
     AND p_effective_date BETWEEN hru.date_from AND NVL(hru.date_to,p_effective_date);
  v_owner_desc VARCHAR2(240);
BEGIN
  IF p_org_id IS NOT NULL THEN
    OPEN c_owner_cur;
    FETCH c_owner_cur INTO v_owner_desc;
    CLOSE c_owner_cur;
  END IF;
  RETURN v_owner_desc;
EXCEPTION
  WHEN OTHERS THEN
    IF c_owner_cur%ISOPEN THEN
      CLOSE c_owner_cur;
    END IF;
    RETURN NULL;
END get_owner_desc;
--
FUNCTION get_payment_name(p_business_group_id IN NUMBER
                         ,p_payment_code      IN NUMBER) RETURN VARCHAR2
IS
  CURSOR c_payment_cur IS
  SELECT pettl.element_name
    FROM pay_element_classifications pec
        ,pay_element_types_f         pet
        ,pay_element_types_f_tl      pettl
   WHERE(pet.business_group_id = p_business_group_id OR
        (pet.business_group_id IS NULL AND pet.legislation_code = 'FR'))
     AND pet.element_type_id   = p_payment_code
     AND pet.element_type_id   = pettl.element_type_id
     AND pettl.language        = USERENV('LANG')
     AND pec.classification_id = pet.classification_id;
  v_payment_desc VARCHAR2(240);
BEGIN
  IF p_payment_code IS NOT NULL THEN
    OPEN c_payment_cur;
    FETCH c_payment_cur INTO v_payment_desc;
    CLOSE c_payment_cur;
  END IF;
  RETURN v_payment_desc;
EXCEPTION
  WHEN OTHERS THEN
    IF c_payment_cur%ISOPEN THEN
      CLOSE c_payment_cur;
    END IF;
    RETURN NULL;
END get_payment_name;
--
END PQH_FR_UTILITY;

/
