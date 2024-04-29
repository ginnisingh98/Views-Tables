--------------------------------------------------------
--  DDL for Package Body PQH_CORPS_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_CORPS_UTILITY" as
/* $Header: pqcpdutl.pkb 120.1 2006/03/17 07:04:02 ggnanagu noship $ */

FUNCTION get_step_name(p_step_id  Number, p_effective_date Date)  RETURN varchar2 IS

Cursor csr_step_dtls (p_step_id number, p_eff_date Date) IS
SELECT  --steps.sequence||'('|| point.spinal_point||')' "SEQUENCE",
        point.spinal_point,
        steps.spinal_point_id,
        steps.grade_spine_id
FROM    per_spinal_point_steps_f steps,
        per_spinal_points point
WHERE   steps.step_id = p_step_id
AND     steps.spinal_point_id = point.spinal_point_id
AND     p_eff_date BETWEEN steps.effective_start_date AND steps.effective_end_date;

l_step_name Varchar2(240);
l_spinal_point     varchar2(240);
l_spinal_point_id  number;
l_grade_spine_id   number;
l_seq              number;
BEGIN
   OPEN csr_step_dtls(p_step_id,p_effective_date);
   FETCH csr_step_dtls INTO l_spinal_point, l_spinal_point_id, l_grade_spine_id;
   CLOSE csr_step_dtls;
   PER_SPINAL_POINT_STEPS_PKG.pop_flds(l_seq,p_effective_date,l_spinal_point_id,l_grade_spine_id);
   IF l_seq IS NULL AND l_spinal_point IS NULL THEN
      l_step_name := NULL;
   ELSE
      l_step_name := l_seq||'('||l_spinal_point||')';
   END IF;
   RETURN l_step_name;
END get_step_name;

Function get_increased_index(p_gross_index IN NUMBER, p_effective_date IN date) Return Number IS

CURSOR csr_increased_index IS
 SELECT  increased_index
 FROM    pqh_fr_global_indices_f
 WHERE   gross_index = p_gross_index
 AND     type_of_record = 'IND' -- for indices
 AND     p_effective_date BETWEEN effective_start_date and effective_end_date;

 l_increased_index   pqh_fr_global_indices_f.increased_index%TYPE;
BEGIN
  OPEN  csr_increased_index;
  FETCH csr_increased_index INTO l_increased_index;
  CLOSE csr_increased_index;

  RETURN l_increased_index;

END get_increased_index;

Function get_salary_rate(p_gross_index IN NUMBER,
                         p_effective_date IN DATE,
                         p_copy_entity_txn_id IN NUMBER default null,
                         p_currency_code  IN VARCHAR2 DEFAULT NULL) RETURN NUMBER IS

Cursor csr_sal_rate IS
  SELECT NVL(basic_salary_rate,0), currency_code
  FROM   pqh_fr_global_indices_f
  WHERE  type_of_record = 'INM'
  AND    p_effective_date BETWEEN effective_start_date AND effective_end_date;

  CURSOR csr_gl_currency (p_cet_id IN NUMBER) IS
      SELECT information50
      FROM   ben_copy_entity_results
      WHERE  copy_entity_txn_id = p_cet_id
      AND    table_alias = 'PGM';

  CURSOR csr_get_precision
  IS
  select Precision
  from Fnd_Currencies
  where currency_code =p_currency_code;

 l_gl_currency     pqh_fr_global_indices_f.currency_code%TYPE;
 l_barame_currency     pqh_fr_global_indices_f.currency_code%TYPE;
 l_increased_index  pqh_fr_global_indices_f.increased_index%TYPE;
 l_basic_sal_rate   pqh_fr_global_indices_f.basic_salary_rate%TYPE;
 l_salary_value     NUMBER := 0;
 l_conv_factor      NUMBER := 1;
 l_precision  NUMBER;

BEGIN

	IF p_currency_code IS NULL THEN
		l_precision :=2;
	ELSE
	 OPEN csr_get_precision;
	 FETCH  csr_get_precision INTO l_precision;
	  if l_precision IS NULL THEN
		   l_precision := 2;
	  END IF;
	 CLOSE csr_get_precision;
	END IF;

  l_increased_index := get_increased_index(p_gross_index => p_gross_index,p_effective_date => p_effective_date);
  IF l_increased_index IS NOT NULL THEN
    OPEN csr_sal_rate;
    FETCH csr_sal_rate INTO l_basic_sal_rate,l_barame_currency;
    CLOSE csr_sal_rate;
    l_salary_value := l_increased_index * l_basic_sal_rate;
  END IF;
  IF p_currency_code IS NOT NULL THEN
   l_gl_currency := p_currency_code;
  ELSIF p_copy_entity_txn_id IS NOT NULL THEN
   OPEN csr_gl_currency(p_copy_entity_txn_id);
   FETCH csr_gl_currency INTO l_gl_currency;
   CLOSE csr_gl_currency;
  END IF;
   IF l_gl_currency IS NOT NULL AND l_barame_currency IS NOT NULL AND l_gl_currency <> l_barame_currency THEN
    BEGIN
     l_conv_factor := hr_currency_pkg.get_rate(p_from_currency => l_barame_currency,
                                                  p_to_currency => l_gl_currency,
                                                  p_conversion_date => p_effective_date,
                                                  p_rate_type => 'Corporate');
   Exception
     When Others Then
       l_conv_factor := 1;
   END;
   END IF;
  l_salary_value := l_salary_value*NVL(l_conv_factor,1);

  l_salary_value := round(l_salary_value,l_precision);

  RETURN l_salary_value;

END get_salary_rate;

Function get_increased_index(p_gross_index IN NUMBER, p_copy_entity_txn_id IN NUMBER) RETURN NUMBER IS

CURSOR csr_eff_date IS
  SELECT action_date
  FROM   pqh_copy_entity_txns
  WHERE  copy_entity_txn_id = p_copy_entity_txn_id;
  /* For Bug Fix 3532356: Retrieving the Effective Date value from pqh_copy_entity_txns.action_date
  			  instead from ben_copy_entity_results.
   */

l_effective_date DATE;
l_increased_index NUMBER;
BEGIN
   OPEN csr_eff_date;
   FETCH csr_eff_date INTO l_effective_date;
   CLOSE csr_eff_date;
   l_increased_index := get_increased_index(p_gross_index => p_gross_index,p_effective_date => l_effective_date);

   RETURN  l_increased_index;



END get_increased_index;

Procedure review_submit_valid_corps(p_copy_entity_txn_id IN NUMBER,
                                    p_effective_date IN DATE,
                                    p_business_group_id IN NUMBER,
                                    p_status OUT NOCOPY Varchar2) IS

l_status  varchar2(1) := 'S';

CURSOR csr_corps_dflt_plcmt IS
  SELECT information162, information169
  FROM   ben_copy_entity_results
  WHERE  copy_entity_txn_id = p_copy_entity_txn_id
  AND    information4 = p_business_group_id
  AND    table_alias = 'CPD';
l_plip_cer_id  number(15);
l_oipl_cer_id  number(15);

CURSOR csr_dflt_grd_in_grdldr(p_plip_cer_id Number) IS
SELECT 'Y'
FROM   ben_copy_entity_results
WHERE  copy_entity_txn_id = p_copy_entity_txn_id
AND    table_alias = 'CPP'
AND    copy_entity_result_id = p_plip_cer_id
AND    result_type_cd = 'DISPLAY'
AND    nvl(information104,'LINK') <> 'UNLINK';
l_grd_exists Varchar2(1);

CURSOR csr_dflt_step_in_grdldr(p_oipl_cer_id Number, p_plip_cer_id Number) IS
SELECT 'Y'
FROM   ben_copy_entity_results
WHERE  copy_entity_txn_id = p_copy_entity_txn_id
AND    table_alias = 'COP'
AND    copy_entity_result_id = p_oipl_cer_id
AND    gs_parent_entity_result_id = p_plip_cer_id
AND    result_type_cd = 'DISPLAY'
AND    nvl(information104,'LINK') <> 'UNLINK';
l_step_exists Varchar2(1);

BEGIN
IF nvl(get_cet_business_area(p_copy_entity_txn_id),'PQH_GSP_TASK_LIST') = 'PQH_CORPS_TASK_LIST' THEN
	OPEN csr_corps_dflt_plcmt;
	FETCH csr_corps_dflt_plcmt INTO l_plip_cer_id, l_oipl_cer_id;
	CLOSE csr_corps_dflt_plcmt;
	IF l_plip_cer_id IS NOT NULL THEN
	  OPEN csr_dflt_grd_in_grdldr(l_plip_cer_id);
	  FETCH csr_dflt_grd_in_grdldr INTO l_grd_exists;
	  IF csr_dflt_grd_in_grdldr%NOTFOUND THEN
	    fnd_message.set_name('PQH','PQH_CORPS_DFLT_GRD_NOTLINKED');
	    hr_multi_message.add;
	    l_status := 'E';
	  ELSE
            IF l_oipl_cer_id IS NOT NULL THEN
	     OPEN csr_dflt_step_in_grdldr(l_oipl_cer_id,l_plip_cer_id);
	     FETCH csr_dflt_step_in_grdldr INTO l_step_exists;
	     IF csr_dflt_step_in_grdldr%NOTFOUND THEN
		 fnd_message.set_name('PQH','PQH_CORPS_DFLT_STEP_NOTLINKED');
		 hr_multi_message.add;
		 l_status := 'E';
	     END IF;
	     CLOSE csr_dflt_step_in_grdldr;
            END IF;
	  END IF;
	  Close csr_dflt_grd_in_grdldr;
	END IF;
     p_status := l_status;
END IF;
END review_submit_valid_corps;

Function get_global_basic_sal_rate(p_effective_date in DATE) RETURN NUMBER IS
 CURSOR  csr_sal_rate IS
 SELECT basic_salary_rate
 FROM   pqh_fr_global_indices_f
 WHERE  type_of_record = 'INM'
 AND    p_effective_date BETWEEN effective_start_date AND effective_end_date;

 l_sal_rate  NUMBER := 0;
 BEGIN

 OPEN csr_sal_rate;
 FETCH csr_sal_rate INTO l_sal_rate;
 CLOSE csr_sal_rate;

 RETURN l_sal_rate;

END get_global_basic_sal_rate;

Function get_cet_business_area(p_copy_entity_txn_id IN Number) return Varchar2 IS
 CURSOR csr_bus_area IS
  SELECT NVL(cea.information9,'PQH_GSP_TASK_LIST')
  FROM   pqh_copy_entity_attribs cea
  WHERE  cea.copy_entity_txn_id = p_copy_entity_txn_id;
  l_bus_area  varchar2(30);
BEGIN
  OPEN  csr_bus_area;
  FETCH csr_bus_area INTO l_bus_area;
  CLOSE Csr_bus_area;
  RETURN l_bus_area;
END get_cet_business_area;

Function get_step_name_for_hgrid(p_step_id IN Number,
                                 p_effective_date IN DATE) RETURN VARCHAR2 IS

Cursor csr_stp_name IS
SELECT  steps.sequence,
        point.spinal_point,
        steps.spinal_point_id,
        steps.grade_spine_id,
        point.information1 "IB",
        get_increased_index(point.information1,p_effective_date) "INM"
FROM    per_spinal_point_steps_f steps,
        per_spinal_points point
WHERE   steps.step_id = p_step_id
AND     steps.spinal_point_id = point.spinal_point_id
AND     p_effective_date BETWEEN steps.effective_start_date AND steps.effective_end_date;

l_name  varchar2(240);
l_stp_name_rec csr_stp_name%ROWTYPE;
l_seq              number;
BEGIN
 OPEN csr_stp_name;
 FETCH csr_stp_name INTO l_stp_name_rec.sequence,
                         l_stp_name_rec.spinal_point,
                         l_stp_name_rec.spinal_point_id,
                         l_stp_name_rec.grade_spine_id,
                         l_stp_name_rec.ib,
                         l_stp_name_rec.inm;
 CLOSE csr_stp_name;
 PER_SPINAL_POINT_STEPS_PKG.pop_flds(l_seq,p_effective_date,l_stp_name_rec.spinal_point_id,l_stp_name_rec.grade_spine_id);
 l_name := l_seq||'('||l_stp_name_rec.spinal_point;
 IF l_stp_name_rec.ib IS NOT NULL AND l_stp_name_rec.INM IS NOT NULL THEN
   l_name := l_name||'| IB: '||l_stp_name_rec.ib||'| INM: '||l_stp_name_rec.inm;
 END IF;
 l_name := l_name||')';

 RETURN l_name;
END get_step_name_for_hgrid;

Function get_bg_type_of_ps(p_business_group_id IN NUMBER) RETURN VARCHAR2

IS
CURSOR csr_bg_type_of_ps IS
SELECT  org_information1
FROM    hr_organization_information
WHERE   organization_id = p_business_group_id
AND     org_information_context = 'FR_PQH_GROUPING_UNIT_INFO';
l_type_of_ps varchar2(30);
BEGIN
OPEN csr_bg_type_of_ps;
FETCH csr_bg_type_of_ps INTO l_type_of_ps;
CLOSE csr_bg_type_of_ps;
RETURN l_type_of_ps;
END get_bg_type_of_ps;

Function get_cpd_status(p_node_number IN varchar2,
                        p_copy_entity_txn_id IN NUMBER) RETURN VARCHAR2 IS

st_icon Varchar2(10) := 'Y';

CURSOR csr_cpd_control_rec IS
  SELECT bcer.information100,
         bcer.information101,
         bcer.information102,
         bcer.information103,
         bcer.information104,
         bcer.information105,
         bcer.information106,
         bcer.information107,
         bcer.information108
  FROM   ben_copy_entity_results bcer
  WHERE  bcer.copy_entity_txn_id = p_copy_entity_txn_id
  AND    bcer.table_alias = 'PQH_CORPS_TASK_LIST';
 l_cpd_control_rec csr_cpd_control_rec%ROWTYPE;
BEGIN
  OPEN csr_cpd_control_rec;
  FETCH csr_cpd_control_rec INTO l_cpd_control_rec.information100,
                                 l_cpd_control_rec.information101,
                                 l_cpd_control_rec.information102,
                                 l_cpd_control_rec.information103,
                                 l_cpd_control_rec.information104,
                                 l_cpd_control_rec.information105,
                                 l_cpd_control_rec.information106,
                                 l_cpd_control_rec.information107,
                                 l_cpd_control_rec.information108;
  CLOSE csr_cpd_control_rec;
if p_node_number = '1' then
--Status for Grade Ladder
   st_icon := l_cpd_control_rec.information100;
elsif p_node_number = '2' then
--Status for Corps
   st_icon := l_cpd_control_rec.information107;
elsif p_node_number = '3' then
--Status for Sal. Info.
   st_icon := l_cpd_control_rec.information101;
elsif p_node_number = '4'then
--Status for Grades
   st_icon := l_cpd_control_rec.information102;
elsif p_node_number = '5' then
--Status for Steps
   st_icon := l_cpd_control_rec.information103;
elsif p_node_number = '6' then
--Status for Rates
   st_icon := l_cpd_control_rec.information104;
elsif p_node_number = '7' then
--Status for Progression Rules
   st_icon := l_cpd_control_rec.information105;
elsif p_node_number = '8' then
--Status for Corps Documents
   st_icon := l_cpd_control_rec.information108;
elsif p_node_number = '9' then
--Status for Review and Submit
   st_icon := l_cpd_control_rec.information106;
else
        st_icon := 'N';
end if;
    RETURN st_icon;
EXCEPTION
   WHEN others THEN
    return 'N';
END get_cpd_status;

Function chk_steps_exist_for_index(p_gross_index IN NUMBER) RETURN VARCHAR2 IS

CURSOR csr_steps_exist_for_index IS
  SELECT 'Y'
  FROM   dual
  WHERE EXISTS (SELECT '1'
                FROM   per_parent_spines pps,
                       per_spinal_points psp
                WHERE  psp.information1 = p_gross_index
                AND    psp.information_category = 'FR_PQH'
                AND    psp.parent_spine_id = pps.parent_spine_id
                AND    pps.information_category = 'FR_PQH'
                AND    pps.information1 = 'L');

l_status VARCHAR2(30) := 'N';
BEGIN
OPEN csr_steps_exist_for_index;
FETCH csr_steps_exist_for_index INTO l_status;
CLOSE csr_steps_exist_for_index;

RETURN l_status;

END chk_steps_exist_for_index;
FUNCTION  bus_area_pgm_entity_exist(p_bus_area_cd IN Varchar2,
                                    P_pgm_id IN NUMBER)
RETURN varchar2
IS

Cursor csr_corps_pgm_exists IS
SELECT 'Y'
FROM    pqh_corps_definitions
WHERE   ben_pgm_id = p_pgm_id;


l_exist  Varchar2(1) := 'N';
BEGIN

    IF p_bus_area_cd = 'PQH_GSP_TASK_LIST' THEN
       l_exist := 'Y';
    ELSIF p_bus_area_cd = 'PQH_CORPS_TASK_LIST' THEN
       OPEN csr_corps_pgm_exists;
       FETCH csr_corps_pgm_exists INTO l_exist;
       CLOSE csr_corps_pgm_exists;
    END IF;
    RETURN l_exist;
END bus_area_pgm_entity_exist;

FUNCTION chk_primary_prof_field(p_corps_definition_id IN NUMBER
                               ,p_field_of_prof_activity_id IN NUMBER)
RETURN VARCHAR2 IS
  CURSOR  csr_if_prim_prof_field IS
     SELECT 'Y'
     FROM   dual
     WHERE  EXISTS (SELECT 1
                    FROM   pqh_corps_definitions
                    WHERE  corps_definition_id = p_corps_definition_id
                    AND    nvl(primary_prof_field_id,-1) = p_field_of_prof_activity_id);
  l_primary varchar2(10) := 'N';
BEGIN
  OPEN csr_if_prim_prof_field;
  FETCH csr_if_prim_prof_field INTO l_primary;
  CLOSE csr_if_prim_prof_field;
  RETURN l_primary;
END chk_primary_prof_field;

FUNCTION chk_corps_info_exists(p_corps_definition_id IN NUMBER
                              ,p_information_type IN VARCHAR2)
RETURN VARCHAR2 IS
  CURSOR csr_corps_info_exists(p_corps_definition_id IN NUMBER, p_information_type IN varchar2) IS
    SELECT 'Y'
    FROM   dual
    WHERE EXISTS (SELECT 1
                  FROM   pqh_corps_extra_info
                  WHERE  corps_definition_id = p_corps_definition_id
                  AND    information_type    = p_information_type);
  l_info_type varchar2(30);
  l_info_exist VARCHAR2(10) := 'N';
BEGIN
   IF p_information_type = 'PQH_CORPS_ADDL_ADMIN_OVERVIEW' THEN
     l_info_type := 'ORGANIZATION';
   ELSIF  p_information_type = 'PQH_CORPS_ADDL_EXAM_OVERVIEW' THEN
     l_info_type := 'EXAM';
   ELSIF  p_information_type = 'PQH_CORPS_ADDL_FOP_OVERVIEW' THEN
     l_info_type := 'FILERE';
   ELSIF  p_information_type = 'PQH_CORPS_ADDL_TRNG_OVERVIEW' THEN
     l_info_type := 'TRAINING';
   END IF;
   OPEN csr_corps_info_exists(p_corps_definition_id,l_info_type);
   FETCH csr_corps_info_exists INTO l_info_exist;
   CLOSE csr_corps_info_exists;
   RETURN l_info_exist;
END chk_corps_info_exists;

------------------------- get_corps_name ------------------------------
/*
Author  :  mvankada
Purpose :  Returns Corps Name for a given Corps  Definition Id.
*/

FUNCTION get_corps_name(p_corps_definition_id IN VARCHAR2) Return Varchar2
IS

Cursor csr_corps_name
IS
Select Name
From   pqh_corps_definitions
Where  Corps_Definition_Id = p_corps_definition_id ;
l_corps_name Varchar2(240) := null;

BEGIN
    If p_corps_definition_id IS NOT NULL Then
        Open csr_corps_name;
        Fetch csr_corps_name into l_corps_name;
        Close csr_corps_name;
    End If;
    return l_corps_name;
END get_corps_name;

------------------------- los_in_months ------------------------------
/*
Author  :  mvankada
Purpose :  Returns Lenth of Service (LOS) in months.
*/


FUNCTION los_in_months(p_los_years IN Number,
                       p_los_months IN Number,
                       p_los_days   IN Number) Return Number IS
l_los_in_months Number := 0;
BEGIN

   l_los_in_months := Nvl(p_los_years,0)*12  + Nvl(p_los_months,0) + Nvl(p_los_days,0)/(365/12);
   l_los_in_months := round(nvl(l_los_in_months,0),2);
   return l_los_in_months;

END los_in_months;
------------------------ get_from_step_name------------------------------
/*
Author  :  mvankada
Purpose :  Returns Step Name for a Step Cer Id.
*/


FUNCTION get_from_step_name( p_step_cer_id        IN  Number,
                             p_copy_entity_txn_id IN  Number) Return Varchar2 IS
Cursor csr_seq_no
IS
Select Information263 -- Sequence Number
From   Ben_Copy_Entity_Results
Where  Copy_Entity_Result_Id = p_step_cer_id
And    Table_Alias = 'COP'
And    Copy_Entity_Txn_Id = p_copy_entity_txn_id;

Cursor csr_point_name
IS
Select Information98   -- Point Name
From   Ben_Copy_Entity_Results
Where  Copy_Entity_Txn_Id = p_copy_entity_txn_id
And    Table_Alias = 'OPT'
And    Copy_Entity_Result_id = ( select Information262    -- POINT Cer Id
                                 From   Ben_Copy_Entity_results
                                 Where  Copy_Entity_Result_id = p_step_cer_id);


l_point_name  Varchar2(2000);
l_step_name   Varchar2(2000) := null;
l_seq_no      Number;

BEGIN
   Open csr_seq_no;
   Fetch csr_seq_no into l_seq_no;
   Close csr_seq_no;

   Open csr_point_name;
   Fetch csr_point_name into l_point_name;
   Close csr_point_name;

 if l_point_name IS NOT NULL Then
     l_step_name  := l_seq_no || '(' || l_point_name || ')';
  end if;
   return  l_step_name;
END get_from_step_name;

------------------------ update_or_delete_crpath ------------------------------
/*
Author  :  mvankada
Purpose :  Purge CRPATH Rec if Record is in Staging Area else UNLINK Record.
*/


Procedure update_or_delete_crpath ( p_crpath_cer_id        IN  Number,
                                p_effective_date       IN  Date,
                                p_dml_operation        IN Varchar2) IS

Cursor Csr_Ovn  IS
Select Object_Version_Number
From Ben_Copy_Entity_Results
Where Copy_Entity_Result_Id = p_crpath_cer_id;
l_ovn  Number;

Begin
        Open  Csr_Ovn;
        Fetch  Csr_Ovn  into l_ovn;
        Close  Csr_Ovn;

     If p_dml_operation = 'INSERT' Then
      -- Purge record
          ben_copy_entity_results_api.delete_copy_entity_results
                   ( p_copy_entity_result_id => p_crpath_cer_id,
                     p_effective_date        => p_effective_date,
                     p_object_version_number => l_ovn);


     Else
      -- UNLINK  record
         ben_copy_entity_results_api.update_copy_entity_results
                         ( p_copy_entity_result_id    => p_crpath_cer_id,
                           p_effective_date           => p_effective_date,
                           p_information104           => 'UNLINK',
                           p_object_version_number    => l_ovn,
                           p_information323           => null);

     End If;
END update_or_delete_crpath;

Function decode_stage_entity(p_copy_entity_txn_id IN NUMBER,
                             p_table_alias        IN VARCHAR2,
                             p_copy_entity_result_id IN NUMBER) RETURN VARCHAR2 IS
 Cursor csr_decode_stage_entity(p_cet_id IN NUMBER,
                                p_table_alias IN varchar2,
                                p_cer_id IN NUMBER) IS
 SELECT information5
 FROM   ben_copy_entity_results
 WHERE  copy_entity_txn_id = p_cet_id
 AND    table_alias = p_table_alias
 AND    copy_entity_result_id = p_cer_id;
 l_name  varchar2(240);
BEGIN
  OPEN csr_decode_stage_entity(p_copy_entity_txn_id,p_table_alias,p_copy_entity_result_id);
  FETCH csr_decode_stage_entity INTO l_name;
  CLOSE csr_decode_stage_entity;
  RETURN l_name;
END decode_stage_entity;
 ----------
--ggnanagu
FUNCTION get_pgm_id (p_corps_definition_id IN NUMBER)
   RETURN NUMBER
IS
   /*
    * Returs the Pgm Id for the corps_definition_id
    */
   l_pgm_id   NUMBER;

BEGIN
   SELECT ben_pgm_id
     INTO l_pgm_id
     FROM pqh_corps_definitions
    WHERE corps_definition_id = p_corps_definition_id;
    Return l_pgm_id;
END;

---
FUNCTION is_career_def_exist(p_Copy_Entity_txn_Id IN NUMBER,
                             p_mirror_src_entity_rslt_id IN Number,
                             p_from_step_id IN NUMBER,
                             p_to_corps_id IN Number,
                             p_to_grade_id In Number,
                             p_to_step_id In Number ,
                             p_copy_entity_result_id In Number) RETURN VARCHAR2
IS
Cursor csr_career_info IS
Select 'Y'
FROM     BEN_COPY_ENTITY_RESULTS
Where  Copy_Entity_txn_Id   = p_Copy_Entity_txn_Id
AND   Gs_Mirror_Src_Entity_Result_Id = p_mirror_src_entity_rslt_id
AND   Information234 = p_from_step_id -- p_from_step_id
AND   Information227 = p_to_corps_id -- to_corps_id
AND   Information228 = p_to_grade_id -- to_grade_id
AND   nvl(Information229,1) = nvl(p_to_step_id,1)
AND   copy_entity_result_id <> p_copy_entity_result_id; -- to_step_id

l_result varchar2(10) := 'N';
BEGIN
    Open csr_career_info;
         Fetch csr_career_info into l_result;
     Close csr_career_info;

 return l_result;

END  is_career_def_exist;
---
function get_date_of_placement(p_career_level in varchar2, p_assignment_id in number,
                               p_career_level_id in number)
    return date
IS
Cursor csr_corps_date IS
Select min(asg.effective_start_date)
from per_all_assignments_f asg
where asg.grade_ladder_pgm_id = p_career_level_id
and assignment_id = p_assignment_id;


Cursor csr_grade_date IS
Select min(asg.effective_start_date)
from per_all_assignments_f asg
where asg.grade_id  = p_career_level_id
and assignment_id = p_assignment_id;

Cursor csr_step_date is
Select min(spp.effective_start_date)
from per_spinal_point_placements_f spp
where assignment_id =p_assignment_id
and  step_id = p_career_level_id;

--
l_date date;

begin

l_date := null;

      If (p_career_level ='CORPS') then
       --
         Open csr_corps_date;
           Fetch csr_corps_date into l_date;
         Close csr_corps_date;

      ElsIf (p_career_level = 'GRADE') then
       --
         Open csr_grade_date;
           Fetch csr_grade_date into l_date;
          Close csr_grade_date;
       --
      ElsIf (p_career_level ='STEP') THEN
        --
          Open Csr_step_date;
           Fetch csr_step_date into L_date;
          Close csr_step_date;
     End if;

return l_date;

end get_date_of_placement;
--
FUNCTION get_gross_index (p_step_id IN NUMBER, p_effective_date IN DATE)
   RETURN NUMBER
IS
   CURSOR csr_gross_index
   IS
      SELECT psp.information1
        FROM per_spinal_point_placements_f spp,
             per_spinal_point_steps_f sps,
             per_spinal_points psp
       WHERE spp.step_id = p_step_id
         AND p_effective_date BETWEEN spp.effective_start_date
                                  AND spp.effective_end_date
         AND spp.step_id = sps.step_id
         AND p_effective_date BETWEEN sps.effective_start_date
                                  AND sps.effective_end_date
         AND sps.spinal_point_id = psp.spinal_point_id;

   l_gross_index  VARCHAR2 (240);
BEGIN
   OPEN csr_gross_index;

   FETCH csr_gross_index
    INTO l_gross_index;

   CLOSE csr_gross_index;

   return fnd_number.canonical_to_number (l_gross_index);

END get_gross_index;
--
Function get_postStyle_of_grdldr(p_txn_id in varchar2) return varchar2 is

l_postStyle varchar2(2);

Cursor csr_postStyle is
Select information52 post_style
from ben_copy_entity_results
where table_alias = 'PGM'
and copy_entity_txn_id = to_number(p_txn_id);

Begin

  open csr_postStyle;
  fetch csr_postStyle into l_postStyle;
  close csr_postStyle;
  return l_poststyle;

END get_postStyle_of_grdldr;

END pqh_corps_utility;

/
