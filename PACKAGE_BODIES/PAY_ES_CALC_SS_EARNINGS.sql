--------------------------------------------------------
--  DDL for Package Body PAY_ES_CALC_SS_EARNINGS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_ES_CALC_SS_EARNINGS" AS
/* $Header: pyesssec.pkb 120.11 2006/04/20 00:04:37 kseth noship $ */
--
    START_OF_TIME CONSTANT DATE := TO_DATE('01/01/0001','DD/MM/YYYY');
    END_OF_TIME   CONSTANT DATE := TO_DATE('31/12/4712','DD/MM/YYYY');
--
--------------------------------------------------------------------------------
-- GET_DEFINED_BAL_ID
--------------------------------------------------------------------------------
FUNCTION get_defined_bal_id(p_bal_name         IN  VARCHAR2
                           ,p_db_item_suffix   IN  VARCHAR2) RETURN NUMBER
IS
    --
    CURSOR get_def_bal_id IS
    SELECT pdb.defined_balance_id
    FROM   pay_balance_types        pbt
          ,pay_balance_dimensions   pbd
          ,pay_defined_balances     pdb
    WHERE  pdb.balance_type_id      = pbt.balance_type_id
    AND    pdb.balance_dimension_id = pbd.balance_dimension_id
    AND    pbt.balance_name         = p_bal_name
    AND    pbd.database_item_suffix = p_db_item_suffix;
    --
    l_def_bal_id NUMBER;
    --
BEGIN
    --
    OPEN get_def_bal_id;
    FETCH get_def_bal_id INTO l_def_bal_id;
    CLOSE get_def_bal_id;
    RETURN l_def_bal_id;
    --
END get_defined_bal_id;
--
--------------------------------------------------------------------------------
-- Get_Absence_Details
--------------------------------------------------------------------------------
FUNCTION Get_Absence_Details(p_absence_attendance_id IN NUMBER
                            ,p_sickness_reason       OUT NOCOPY VARCHAR2
                            ,p_sickness_category     OUT NOCOPY VARCHAR2
                            ,p_temp_dis_start_date   OUT NOCOPY DATE
                            ,p_sickness_end          OUT NOCOPY DATE
                            ,p_info_1                OUT NOCOPY VARCHAR2
                            ,p_info_2                OUT NOCOPY VARCHAR2
                            ,p_info_3                OUT NOCOPY VARCHAR2
                            ,p_info_4                OUT NOCOPY VARCHAR2
                            ,p_info_5                OUT NOCOPY VARCHAR2
                            ,p_info_6                OUT NOCOPY VARCHAR2
                            ,p_info_7                OUT NOCOPY VARCHAR2
                            ,p_info_8                OUT NOCOPY VARCHAR2) RETURN VARCHAR2 IS
    --
    CURSOR csr_abs_details(p_absence_attendance_id    NUMBER) IS
    SELECT paa.date_start               start_date
          ,NVL(paa.date_end,to_date('31-12-4712','dd-mm-yyyy')) end_date
          ,paar.name                    Reason
          ,paat.absence_category        Reason_Category
          ,paa.abs_information1
          ,paa.abs_information2
          ,paa.abs_information3
          ,paa.abs_information4
          ,paa.abs_information5
          ,paa.abs_information6
          ,paa.abs_information7
          ,paa.abs_information8
    FROM  per_abs_attendance_reasons        paar
         ,per_absence_attendances           paa
         ,per_absence_attendance_types      paat
    WHERE paa.absence_attendance_id         = p_absence_attendance_id
    AND   paa.absence_attendance_type_id    = paat.absence_attendance_type_id
    AND   paa.abs_attendance_reason_id      = paar.abs_attendance_reason_id (+);
--
BEGIN
--
	OPEN csr_abs_details(p_absence_attendance_id);
    FETCH csr_abs_details INTO p_temp_dis_start_date ,p_sickness_end
                              ,p_sickness_reason ,p_sickness_category
                              ,p_info_1 ,p_info_2 ,p_info_3 ,p_info_4
                              ,p_info_5 ,p_info_6 ,p_info_7 ,p_info_8 ;
    CLOSE csr_abs_details;
    RETURN p_Sickness_Reason;
--
END Get_Absence_Details;
--
--------------------------------------------------------------------------------
-- GET_CONTRIBUTION_DAYS
--------------------------------------------------------------------------------
FUNCTION Get_Contribution_Days(p_date_earned       IN DATE
                              ,p_no_of_months      IN NUMBER) RETURN NUMBER IS
--
    l_ctr      NUMBER  :=  0  ;
--
BEGIN
--
    l_ctr := last_day(Add_months(p_date_earned, -1)) - last_day(Add_months(p_date_earned, -1 -p_no_of_months));
    --
    RETURN l_ctr ;
    --
END Get_Contribution_Days;
--
--------------------------------------------------------------------------------
-- GET_PERSON_GENDER
--------------------------------------------------------------------------------
FUNCTION get_person_gender(p_assignment_id   IN NUMBER
                          ,p_date_earned     IN DATE) RETURN VARCHAR2 IS
--
    CURSOR csr_get_emp_gender IS
    SELECT papf.sex
    FROM   per_all_people_f       papf
          ,per_all_assignments_f  paaf
    WHERE  paaf.assignment_id = p_assignment_id
    AND    papf.person_id = paaf.person_id
    AND    p_date_earned BETWEEN paaf.effective_start_date
                        AND      paaf.effective_end_date
    AND    p_date_earned BETWEEN papf.effective_start_date
                        AND      papf.effective_end_date;

--
l_Gender per_all_people_f.sex%TYPE;
--
BEGIN
--
    OPEN csr_get_emp_gender;
    FETCH csr_get_emp_gender INTO l_Gender;
    CLOSE csr_get_emp_gender;
    --
    RETURN l_Gender ;
    --
END get_person_gender;
--
--------------------------------------------------------------------------------
-- GET_DAYS_PREV_YEAR
--------------------------------------------------------------------------------
FUNCTION get_days_prev_year(p_date_earned     IN DATE) RETURN NUMBER IS
--
    l_Days NUMBER;
BEGIN
--
    SELECT (to_date('01-01-'||to_char(p_date_earned,'yyyy'),'dd-mm-yyyy')
            -to_date('01-01-'||to_char(to_number(to_char(p_date_earned,'yyyy'))-1),'dd-mm-yyyy'))
    INTO   l_Days
    FROM   dual;
    --
    RETURN l_Days;
    --
END get_days_prev_year;
--
--------------------------------------------------------------------------------
-- GET_SS_CONTRIBUTION_DAYS
--------------------------------------------------------------------------------
FUNCTION get_ss_contribution_days(p_assignment_id          IN NUMBER
                                 ,p_balance_name           IN VARCHAR2
                                 ,p_database_item_suffix   IN VARCHAR2
                                 ,p_virtal_date            IN DATE
                                 ,p_span_years             IN NUMBER)RETURN NUMBER IS
    --
    l_Days            NUMBER;
    l_span_days       NUMBER;
    l_def_bal_id      NUMBER;
    l_span_back_date  DATE;
    l_ne_span         NUMBER;
    --
BEGIN
    l_def_bal_id := get_defined_bal_id(p_balance_name, p_database_item_suffix);
    BEGIN
    l_Days       := pay_balance_pkg.get_value(l_def_bal_id,p_assignment_id,p_virtal_date);
        EXCEPTION
        WHEN no_data_found THEN
            l_Days := 0;
    END;
    --
    l_ne_span := p_span_years * 12;
    l_span_back_date := ADD_MONTHS(p_virtal_date, -1 * FLOOR(l_ne_span)) - ( l_ne_span - FLOOR(l_ne_span)) * 30 + 1;
    --
    BEGIN
    l_span_days  := pay_balance_pkg.get_value(l_def_bal_id,p_assignment_id,l_span_back_date);
    EXCEPTION
        WHEN no_data_found THEN
            l_span_days := 0;
    END;
    --
    RETURN (l_Days - l_span_days);
    --
END get_ss_contribution_days;
--
--------------------------------------------------------------------------------
-- GET_LINKED_ABSENCE_DETAILS
--------------------------------------------------------------------------------
FUNCTION get_linked_absence_details(p_absence_attendance_id       IN NUMBER
                                   ,p_disability_start_date       IN DATE) RETURN NUMBER IS
    --
    CURSOR csr_abs_details(l_absence_attendance_id    NUMBER
                          ,p_disability_start_date    DATE) IS
    SELECT paa.date_start        start_date
          ,paa.date_end          end_date
          ,paa.abs_information1  linked_absence
    FROM   per_absence_attendances      paa
    WHERE  paa.absence_attendance_id    = l_absence_attendance_id
    AND    paa.date_start               > ADD_MONTHS(p_disability_start_date,-6);
    --
    l_Days                    NUMBER;
    l_Start_Date              DATE;
    l_End_Date                DATE;
    l_Linked_Absence          per_absence_attendances.abs_information1%TYPE;
    l_absence_attendance_id   per_absence_attendances.absence_attendance_id%TYPE;
    --
BEGIN
--
    l_Days := 0;
    l_absence_attendance_id := p_absence_attendance_id;
    --
    WHILE (l_absence_attendance_id IS NOT NULL) LOOP
        OPEN csr_abs_details(l_absence_attendance_id, p_disability_start_date);
        FETCH csr_abs_details INTO l_Start_Date, l_End_Date, l_Linked_Absence;
        CLOSE csr_abs_details;
        --
        IF l_absence_attendance_id = to_number(l_Linked_Absence) OR l_Start_Date IS NULL THEN
            EXIT;
        ELSIF l_End_Date IS NULL THEN
            l_End_Date := p_disability_start_date - 1;
        END IF;
        --
        l_Days := l_Days + (l_End_Date - l_Start_Date) + 1;
        l_absence_attendance_id := to_number(l_Linked_Absence);
    END LOOP;
    --
    RETURN l_Days;
--
END get_linked_absence_details;
--
--------------------------------------------------------------------------------
-- GET_NO_CHILDREN
--------------------------------------------------------------------------------
--
FUNCTION get_no_children(passignment_id   IN NUMBER
                        ,pbusiness_gr_id  IN NUMBER
                        ,peffective_date  IN DATE)RETURN NUMBER IS
    --
    CURSOR c_contact_info IS
    SELECT COUNT(pcr.contact_type)
    FROM   per_contact_relationships pcr
          ,per_all_assignments_f paaf
     WHERE paaf.assignment_id              = passignment_id
     AND   pcr.person_id                   = paaf.person_id
     AND   pcr.rltd_per_rsds_w_dsgntr_flag = 'Y'
     AND   pcr.cont_information_category   = 'ES'
     AND   (pcr.cont_information1          = 'Y'
     AND   pcr.contact_type                IN ('C','A'))
     AND   peffective_date                 BETWEEN paaf.effective_start_date
                                           AND     paaf.effective_end_date
     AND   peffective_date                 BETWEEN nvl(pcr.date_start,START_OF_TIME)
                                           AND     nvl(pcr.date_end,END_OF_TIME);
    --
    l_Children_no       NUMBER;
    --
BEGIN
    --
    l_Children_no := 0;
    --
    OPEN c_contact_info;
    FETCH c_contact_info INTO l_Children_no;
    CLOSE c_contact_info;
    --
    RETURN l_Children_no;
    --
END get_no_children;
--
--------------------------------------------------------------------------------
-- GET_BENEFIT_SLABS
--------------------------------------------------------------------------------
--
FUNCTION get_benefit_slabs(p_assignment_id          IN  NUMBER
                          ,p_business_group_id      IN  NUMBER
                          ,p_absence_attendance_id  IN  NUMBER
                          ,p_disability_start_date  IN  DATE
                          ,p_Start_Date             IN  DATE
                          ,p_End_Date               IN  DATE
                          ,p_Work_Pattern           IN  VARCHAR2
                          ,p_Slab_1_high            IN  NUMBER
                          ,p_Slab_2_high            IN  NUMBER
                          ,p_Slab_SSA_high          IN  NUMBER
                          ,p_Days_Passed_By         IN  NUMBER
                          ,p_Disability_in_current  IN  VARCHAR2
                          ,p_Link_Days              OUT NOCOPY NUMBER
                          ,p_Withheld_Days          OUT NOCOPY NUMBER
                          ,p_Lower_Days             OUT NOCOPY NUMBER
                          ,p_Higher_Days            OUT NOCOPY NUMBER
                          ,p_Lower_BR_Days          OUT NOCOPY NUMBER
                          ,p_Higher_BR_Days         OUT NOCOPY NUMBER ) RETURN NUMBER  IS
    --
    Link_Days       NUMBER := 0 ;
    l_Link_Days     NUMBER;
    Temp            NUMBER;
    l_Start_Date    DATE;
    l_End_Date      DATE;
    l_working_hrs   NUMBER;
    p_High_Low_Days NUMBER;
    --
BEGIN
    --
    p_Link_Days := 0;
    p_Higher_Days := 0;
    p_Lower_Days := 0;
    p_Withheld_Days := 0;
    p_Lower_BR_Days := 0;
    p_Higher_BR_Days := 0;
    --
    IF  p_absence_attendance_id <> -1 THEN
        Link_Days := pay_es_calc_ss_earnings.get_linked_absence_details(p_absence_attendance_id
                                                                       ,p_disability_start_date);
    END IF;
    Link_Days := Link_Days + p_Days_Passed_By;
    --
    l_Start_Date := p_Start_Date;
    --
    IF Link_Days < p_Slab_1_high THEN
        --
        IF p_End_Date > p_Start_Date + p_Slab_1_high - Link_Days - 1 THEN
            l_End_Date := p_Start_Date + p_Slab_1_high - Link_Days - 1;
        ELSE
            l_End_Date := p_End_Date;
        END IF;
        --
        IF p_Work_Pattern = 'Y' THEN
            Temp := pay_es_ss_calculation.get_working_time(p_assignment_id
                                                          ,p_business_group_id
                                                          ,l_Start_Date
                                                          ,l_End_Date
                                                          ,p_Withheld_Days
                                                          ,l_working_hrs);
        ELSIF  p_Work_Pattern = 'N' THEN
            p_Withheld_Days := l_End_Date - l_Start_Date + 1;
        END IF;
        l_Start_Date := l_End_Date + 1;
        --
    END IF;
    --
    IF  p_End_Date >= p_Start_Date + p_Slab_1_high - Link_Days -1 AND Link_Days < p_Slab_2_high THEN
        --
        IF p_End_Date > p_Start_Date + p_Slab_2_high - Link_Days -1 THEN
            l_End_Date := p_Start_Date + p_Slab_2_high - Link_Days - 1;
        ELSE
            l_End_Date := p_End_Date;
        END IF;
        --
        IF l_Start_Date <= l_End_Date THEN
            --
            IF p_Work_Pattern = 'Y' THEN
                Temp := pay_es_ss_calculation.get_working_time(p_assignment_id
                                                              ,p_business_group_id
                                                              ,l_Start_Date
                                                              ,l_End_Date
                                                              ,p_Lower_Days
                                                              ,l_working_hrs);
            ELSIF  p_Work_Pattern = 'N' THEN
                p_Lower_Days := l_End_Date - l_Start_Date + 1;
            END IF;
             --
            l_Start_Date := l_End_Date + 1;
        END IF;
        --
    END IF;
    --
    IF p_End_Date >= p_Start_Date + p_Slab_2_high - Link_Days -1 OR p_Slab_2_high = -1 THEN
        l_End_Date := p_End_Date;
        --
        IF p_Work_Pattern = 'Y' THEN
            Temp := pay_es_ss_calculation.get_working_time(p_assignment_id
                                                          ,p_business_group_id
                                                          ,l_Start_Date
                                                          ,l_End_Date
                                                          ,p_Higher_Days
                                                          ,l_working_hrs);
        ELSIF  p_Work_Pattern = 'N' THEN
                p_Higher_Days := l_End_Date - l_Start_Date + 1;
        END IF;
        --
    END IF;
    --
    IF Link_Days IS NOT NULL THEN
        p_Link_Days := Link_Days;
    END IF;
    --
    -- BENEFIT RECLAIM CALC ----------------------------------------------------
    --
    l_Start_Date := p_Start_Date;
    l_Link_Days := Link_Days;
    --
    IF Link_Days + p_End_Date - p_Start_Date + 1 >= p_Slab_SSA_high THEN
        --
        IF l_Link_Days < p_Slab_SSA_high THEN
            l_Start_Date := p_Start_Date + p_Slab_SSA_high - l_Link_Days - 1;
            l_Link_Days := p_Slab_SSA_high - 1;
        END IF;
        --
        WHILE l_Start_Date <= p_End_Date LOOP
            --
            IF p_Work_Pattern = 'Y' THEN
                p_High_Low_Days := 0;
                Temp := pay_es_ss_calculation.get_working_time(p_assignment_id
                                                              ,p_business_group_id
                                                              ,l_Start_Date
                                                              ,l_Start_Date
                                                              ,p_High_Low_Days
                                                              ,l_working_hrs);
            ELSIF p_Work_Pattern = 'N' THEN
                p_High_Low_Days := 1;
            END IF;
            --
            IF l_Link_Days < p_Slab_2_high AND p_Slab_2_high <> -1 THEN
                p_Lower_BR_Days := p_Lower_BR_Days + p_High_Low_Days;
            ELSE
                p_Higher_BR_Days := p_Higher_BR_Days + p_High_Low_Days;
            END IF;
            --
            l_Start_Date := l_Start_Date + 1;
            l_Link_Days := l_Link_Days + 1;
            --
        END LOOP;
        --
    END IF;
    --
return 0;
--
END get_benefit_slabs;
--
--------------------------------------------------------------------------------
-- GET_CONTRACT_WORKING_HOURS
--------------------------------------------------------------------------------
--
FUNCTION get_contract_working_hours(p_assignment_id       IN  NUMBER
                                   ,p_business_group_id   IN  NUMBER
                                   ,p_Start_Date          IN  DATE) RETURN NUMBER
IS
--
l_working_hrs  NUMBER := 0;
l_End_Date     DATE;
l_Days         NUMBER;
Temp           NUMBER;
--
BEGIN
    l_End_Date := to_date((to_char(p_Start_Date,'dd-mm-')||
            to_char(to_number(to_char(p_Start_Date,'YYYY'))-1)),'dd-mm-yyyy')-1;
    Temp := pay_es_ss_calculation.get_working_time(p_assignment_id
                                                  ,p_business_group_id
                                                  ,p_Start_Date
                                                  ,l_End_Date
                                                  ,l_Days
                                                  ,l_working_hrs);
    return l_working_hrs;
END get_contract_working_hours;
--
--------------------------------------------------------------------------------
-- MATERNITY_VALIDATIONS
--------------------------------------------------------------------------------
FUNCTION Maternity_Validations(p_absence_attendance_id IN  NUMBER
                              ,p_benefit_days          OUT NOCOPY NUMBER) RETURN VARCHAR2 IS
--
   CURSOR csr_abs_details(p_absence_attendance_id    NUMBER) IS
   SELECT NVL(PAA1.date_end,to_date('31-12-4712','dd-mm-yyyy'))-PAA1.date_start+1
         ,PAAT1.absence_category       Reason_Category_prev
         ,PAAT2.absence_category       Reason_Category
   FROM   per_absence_attendances      PAA1
         ,per_absence_attendances      PAA2
         ,per_absence_attendance_types PAAT1
         ,per_absence_attendance_types PAAT2
   WHERE PAA2.absence_attendance_id         = p_absence_attendance_id
   AND   PAA2.date_start                    = PAA1.date_end + 1
   AND   PAA1.person_id                     = PAA2.person_id
   AND   PAA1.absence_attendance_type_id     = PAAT1.absence_attendance_type_id
   AND   PAA2.absence_attendance_type_id     = PAAT2.absence_attendance_type_id;
    --
    l_category       per_absence_attendance_types.absence_category%TYPE;
    l_category_prev  per_absence_attendance_types.absence_category%TYPE;
    --
BEGIN
    --
    l_category       := 'x';
    l_category_prev  := 'x';
    --
    BEGIN
        OPEN csr_abs_details(p_absence_attendance_id);
        FETCH csr_abs_details into p_benefit_days, l_category_prev ,l_category ;
        CLOSE csr_abs_details;
        --
    EXCEPTION
        WHEN no_data_found THEN
            RETURN 'N';
    END;
    --
    IF (l_category_prev = 'M' AND l_category = 'PTM') OR
       (l_category_prev = 'PAR' AND l_category = 'M') THEN
            RETURN 'Y';
    ELSE
            RETURN 'N';
    END IF;
  --
END Maternity_Validations;
--
--------------------------------------------------------------------------------
-- GET_WC_ND_SD_PU_INFO
--------------------------------------------------------------------------------
--
FUNCTION get_wc_nd_sd_pu_info(p_work_center      IN  NUMBER
                             ,p_date_between     IN  DATE
                             ,p_PU               IN  VARCHAR2
                             ,p_end_date         OUT NOCOPY DATE
                             ,p_part_unemp_perc  OUT NOCOPY NUMBER
                             ,p_start_date       OUT NOCOPY DATE
                             ,p_Cal_method       OUT NOCOPY VARCHAR2
                             ,p_Rate_formula     OUT NOCOPY VARCHAR2
                             ,p_Duration_Formula OUT NOCOPY VARCHAR2) RETURN VARCHAR2 IS
--
   CURSOR csr_wc_eit_nd_sd IS
   SELECT  nvl(fnd_date.canonical_to_date(hoi.org_information2),to_date('31-12-4712','dd-mm-yyyy')) end_date
          ,0 PU_perc
          ,fnd_date.canonical_to_date(hoi.org_information1) start_date
   FROM    hr_organization_information hoi
   WHERE   hoi.organization_id          =  p_work_center
   AND     hoi.org_information_context IN ('ES_WC_NATURAL_DISASTER','ES_WC_SHUTDOWN')
   AND     p_date_between BETWEEN fnd_date.canonical_to_date(hoi.org_information1)
           AND nvl(fnd_date.canonical_to_date(hoi.org_information2),to_date('31-12-4712','dd-mm-yyyy'));
--
   CURSOR  csr_wc_eit_pu IS
   SELECT  nvl(fnd_date.canonical_to_date(hoi.org_information2),to_date('31-12-4712','dd-mm-yyyy')) end_date
          ,fnd_number.canonical_to_number(hoi.org_information3) PU_perc
          ,fnd_date.canonical_to_date(hoi.org_information1) start_date
          ,hoi.org_information5 Cal_metod
          ,hoi.org_information6 Rate_formula
          ,hoi.org_information7 Duration_Formula
   FROM    hr_organization_information hoi
   WHERE   hoi.organization_id          =  p_work_center
   AND     hoi.org_information_context IN ('ES_WC_PARTIAL_UNEMPLOYMENT')
   AND     p_date_between BETWEEN fnd_date.canonical_to_date(hoi.org_information1)
           AND nvl(fnd_date.canonical_to_date(hoi.org_information2),to_date('31-12-4712','dd-mm-yyyy'));
--
BEGIN
    --
    IF p_PU = 'Y' THEN
        OPEN  csr_wc_eit_pu;
        FETCH csr_wc_eit_pu into p_end_date, p_part_unemp_perc, p_start_date,p_Cal_method ,p_Rate_formula,p_Duration_Formula  ;
        IF csr_wc_eit_pu%NOTFOUND THEN
            CLOSE csr_wc_eit_pu;
            RETURN 'N';
        END IF;
        CLOSE csr_wc_eit_pu;
    ELSIF p_PU = 'N' THEN
        OPEN  csr_wc_eit_nd_sd;
        FETCH csr_wc_eit_nd_sd into p_end_date, p_part_unemp_perc, p_start_date;
        IF csr_wc_eit_nd_sd%NOTFOUND THEN
            CLOSE csr_wc_eit_nd_sd;
            RETURN 'N';
        END IF;
        CLOSE csr_wc_eit_nd_sd;
    END IF;
        --
    --
    RETURN 'Y';
--
END get_wc_nd_sd_pu_info;
--
--------------------------------------------------------------------------------
-- GET_WC_PU_INFO
--------------------------------------------------------------------------------
--
FUNCTION get_wc_pu_info(p_work_center         IN  NUMBER
                       ,p_period_start_date   IN  DATE
                       ,p_period_end_date     IN  DATE
                       ,p_end_date            OUT NOCOPY DATE
                       ,p_part_unemp_perc     OUT NOCOPY NUMBER
                       ,p_start_date          OUT NOCOPY DATE
                       ,p_Cal_method          OUT NOCOPY VARCHAR2
                       ,p_Rate_formula        OUT NOCOPY VARCHAR2
                       ,p_Duration_Formula    OUT NOCOPY VARCHAR2) RETURN VARCHAR2
IS
--
   CURSOR csr_wc_pu_details IS
   SELECT  nvl(fnd_date.canonical_to_date(hoi.org_information2),to_date('31-12-4712','dd-mm-yyyy')) end_date
          ,fnd_number.canonical_to_number(hoi.org_information3) PU_perc
          ,fnd_date.canonical_to_date(hoi.org_information1) start_date
          ,hoi.org_information5 Cal_metod
          ,hoi.org_information6 Rate_formula
          ,hoi.org_information7 Duration_Formula
   FROM    hr_organization_information hoi
   WHERE   hoi.organization_id          =  p_work_center
   AND     hoi.org_information_context IN ('ES_WC_PARTIAL_UNEMPLOYMENT')
   AND     fnd_date.canonical_to_date(hoi.org_information1) BETWEEN  p_period_start_date
                                                            AND      p_period_end_date;
--
BEGIN
    --
    OPEN  csr_wc_pu_details;
    FETCH csr_wc_pu_details into p_end_date, p_part_unemp_perc, p_start_date, p_Cal_method ,p_Rate_formula,p_Duration_Formula ;
    IF  csr_wc_pu_details%NOTFOUND THEN
        CLOSE csr_wc_pu_details;
        RETURN 'N';
    END IF;
    CLOSE csr_wc_pu_details;
    --
    Return 'Y';
--
END get_wc_pu_info;
--
--------------------------------------------------------------------------------
-- GET_BU_INFO
--------------------------------------------------------------------------------
--
FUNCTION get_bu_info(p_assignment_id        IN  NUMBER
                    ,p_business_gr_id       IN  NUMBER
                    ,p_date_earned          IN  DATE
                    ,p_abs_cat              IN  VARCHAR2
                    ,p_Total_Days           IN  NUMBER
                    ,p_bu_calc_method_e     IN  VARCHAR2
                    ,p_bu_daily_rate_e      IN  VARCHAR2
                    ,p_bu_duration_e        IN  VARCHAR2
                    ,p_start_date           IN  DATE
                    ,p_end_date             IN  DATE
                    ,p_Daily_Value_Base     IN  NUMBER
                    ,p_Link_Duration_Days   IN  NUMBER
                    ,p_Days_Passed_By       OUT  NOCOPY NUMBER
                    ,p_Benefit_Uplift       OUT  NOCOPY NUMBER
                    ,p_Gross_Pay_Per_Days   OUT  NOCOPY NUMBER
                    ,p_rate1                OUT  NOCOPY NUMBER
                    ,p_value1               OUT  NOCOPY NUMBER
                    ,p_rate2                OUT  NOCOPY NUMBER
                    ,p_value2               OUT  NOCOPY NUMBER
                    ,p_rate3                OUT  NOCOPY NUMBER
                    ,p_value3               OUT  NOCOPY NUMBER
                    ,p_rate4                OUT  NOCOPY NUMBER
                    ,p_value4               OUT  NOCOPY NUMBER
                    ,p_rate5                OUT  NOCOPY NUMBER
                    ,p_value5               OUT  NOCOPY NUMBER
                    ,p_rate6                OUT  NOCOPY NUMBER
                    ,p_value6               OUT  NOCOPY NUMBER
                    ,p_rate7                OUT  NOCOPY NUMBER
                    ,p_value7               OUT  NOCOPY NUMBER
                    ,p_rate8                OUT  NOCOPY NUMBER
                    ,p_value8               OUT  NOCOPY NUMBER
                    ,p_rate9                OUT  NOCOPY NUMBER
                    ,p_value9               OUT  NOCOPY NUMBER
                    ,p_rate10               OUT  NOCOPY NUMBER
                    ,p_value10              OUT  NOCOPY NUMBER
                    ,p_work_center          IN   NUMBER
                    ,p_pattern              IN   VARCHAR2
                    ,p_percentage           IN   NUMBER) RETURN VARCHAR2 IS
--
    CURSOR csr_legal_employer_info(l_legal_emp_id IN NUMBER) IS
    SELECT org_information2                                                     l_bu_calc_method
          ,org_information3                                                     l_bu_daily_rate_ff
          ,org_information4                                                     l_bu_duration_ff
          ,GREATEST(fnd_date.canonical_to_date(org_information5), p_start_date) l_bu_start_date
          ,LEAST(nvl(fnd_date.canonical_to_date(org_information6),to_date('31-12-4712','dd-mm-yyyy')),p_end_date)  l_bu_end_date
    FROM  hr_organization_information
    WHERE organization_id = l_legal_emp_id
    AND   org_information_context = 'ES_BENEFIT_UPLIFT'
    AND   org_information1 = p_abs_cat
    AND   ((p_start_date BETWEEN fnd_date.canonical_to_date(ORG_INFORMATION5)
                       AND NVL(fnd_date.canonical_to_date(ORG_INFORMATION6),to_date('31-12-4712','DD-MM-YYYY')))
    OR    (fnd_date.canonical_to_date(ORG_INFORMATION5) BETWEEN p_start_date
                                                       AND p_end_date))
    ORDER BY org_information5 ;
    --
    CURSOR csr_get_le_details (p_wc_organization_id NUMBER) IS
    SELECT hoi.organization_id          le_id
    FROM   hr_organization_information  hoi
    WHERE  hoi.org_information1         = p_wc_organization_id
    AND    hoi.org_information_context  = 'ES_WORK_CENTER_REF';


    l_Benefit_Days NUMBER;
    l_BU_Calculation      hr_organization_information.org_information2%TYPE;
    l_BU_Rate_Formula     hr_organization_information.org_information2%TYPE;
    l_BU_Duration_Formula hr_organization_information.org_information2%TYPE;
    l_Day_Amount NUMBER;
    l_Days_in_Value1 NUMBER := 0;
    l_Days_in_Value2 NUMBER := 0;
    l_Days_in_Value3 NUMBER := 0;
    l_Days_in_Value4 NUMBER := 0;
    l_Days_in_Value5 NUMBER := 0;
    l_Days_in_Value6 NUMBER := 0;
    l_Days_in_Value7 NUMBER := 0;
    l_Days_in_Value8 NUMBER := 0;
    l_Days_in_Value9 NUMBER := 0;
    l_Days_in_Value10 NUMBER := 0;
    L_BENEFIT_UPLIFT NUMBER := 0;
    l_Benefit_Days_w NUMBER := 0;
    l_temp VARCHAR2(10);
    l_legal_emp_id NUMBER;
    temp NUMBER := 0;
    l_working_hrs NUMBER := 0;
    bu_start_date DATE;
    bu_end_date   DATE;
    --
BEGIN
    --
    l_Benefit_Days := 0;
    l_Day_Amount := 0;
    p_Gross_Pay_Per_Days := 0;
    p_Benefit_Uplift := 0;
    l_temp := 'x';
    --
     p_rate1 := 0;
     p_value1 := 0;
     p_rate2 := 0;
     p_value2 := 0;
     p_rate3 := 0;
     p_value3 := 0;
     p_rate4 := 0;
     p_value4 := 0;
     p_rate5 := 0;
     p_value5 := 0;
     p_rate6 := 0;
     p_value6 := 0;
     p_rate7 := 0;
     p_value7 := 0;
     p_rate8 := 0;
     p_value8 := 0;
     p_rate9 := 0;
     p_value9 := 0;
     p_rate10 := 0;
     p_value10 := 0;
     p_Days_Passed_By := 0;

    --
    OPEN csr_get_le_details(p_work_center);
    FETCH csr_get_le_details INTO l_legal_emp_id;
    CLOSE csr_get_le_details;
        --
    FOR recd_le_info IN csr_legal_employer_info(l_legal_emp_id) LOOP
    --
        l_BU_Calculation := p_bu_calc_method_e ;
        l_BU_Rate_Formula := p_bu_daily_rate_e ;
        l_BU_Duration_Formula := p_bu_duration_e ;
        IF l_BU_Calculation IS NULL THEN
        --
            IF l_BU_Duration_Formula IS NULL THEN
            --
                l_BU_Calculation := recd_le_info.l_bu_calc_method ;
                l_BU_Rate_Formula := recd_le_info.l_bu_daily_rate_ff ;
                l_BU_Duration_Formula := recd_le_info.l_bu_duration_ff ;
            ELSE
            --
                l_BU_Calculation := recd_le_info.l_bu_calc_method ;
                l_BU_Rate_Formula := recd_le_info.l_bu_daily_rate_ff ;
            END IF;
        --
        ELSIF l_BU_Duration_Formula IS NULL THEN
            --
            l_BU_Duration_Formula := recd_le_info.l_bu_duration_ff ;
        END IF;
        --
        --
        IF l_BU_Calculation = 'GROSS_PAY' AND l_BU_Rate_Formula IS NOT NULL AND l_BU_Duration_Formula IS NOT NULL THEN
        --

            l_Day_Amount := pay_es_benefit_uplift_calc.get_gross_per_day(p_assignment_id
                                                                        ,p_business_gr_id
                                                                        ,p_date_earned
                                                                        ,l_BU_Rate_Formula); -- Gross_Pay_Per_Days
            --
            IF l_Day_Amount IS NULL OR l_Day_Amount < 0 THEN
                l_Day_Amount := 0 ;
            END IF;
            --
            p_Gross_Pay_Per_Days := l_Day_Amount ;
            l_Day_Amount := l_Day_Amount * p_percentage / 100;
            --
        ELSIF l_BU_Calculation = 'STATUTORY_EARNINGS' AND l_BU_Duration_Formula IS NOT NULL THEN
        --
            l_Day_Amount := p_Daily_Value_Base ;
        ELSE
        --
            l_Day_Amount := 0 ;
        --
        END IF;

        p_value1:= 0;
        p_rate1 := 0;
        p_value2:= 0;
        p_rate2 := 0;
        p_value3:= 0;
        p_rate3:= 0;
        p_value4:= 0;
        p_rate4:= 0;
        p_value5:= 0;
        p_rate5:= 0;
        p_value6:= 0;
        p_rate6:= 0;
        p_value7:= 0;
        p_rate7:= 0;
        p_value8:= 0;
        p_rate8:= 0;
        p_value9:= 0;
        p_rate9:= 0;
        p_value10:= 0;
        p_rate10:= 0;

        l_temp := pay_es_benefit_uplift_calc.get_duration(p_assignment_id,p_business_gr_id,p_date_earned,l_BU_Duration_Formula,
                 p_rate1, p_value1 ,p_rate2, p_value2, p_rate3, p_value3,p_rate4, p_value4, p_rate5, p_value5,p_rate6, p_value6
                ,p_rate7, p_value7, p_rate8, p_value8, p_rate9, p_value9, p_rate10, p_value10);
        p_Days_Passed_By := p_Link_Duration_Days  ;  --Benefit_Days initialize to 0 at top
        l_Benefit_Days := recd_le_info.l_bu_end_date - recd_le_info.l_bu_start_date + 1 ;  --Benefit_Days should never be initialized after this
        IF p_pattern = 'P' THEN
            temp := pay_es_ss_calculation.get_working_time(p_assignment_id
                                                          ,p_business_gr_id
                                                          ,recd_le_info.l_bu_start_date
                                                          ,recd_le_info.l_bu_end_date
                                                          ,l_Benefit_Days_w
                                                          ,l_working_hrs);
        ELSE
            l_Benefit_Days_w := l_Benefit_Days ;
        END IF;
        --
        bu_start_date := recd_le_info.l_bu_start_date;
        bu_end_date := recd_le_info.l_bu_end_date;
        --
        l_Days_in_Value1 := p_value1 ;
        l_Days_in_Value2 := p_value2 ;
        l_Days_in_Value3 := p_value3 ;
        l_Days_in_Value4 := p_value4 ;
        l_Days_in_Value5 := p_value5 ;
        l_Days_in_Value6 := p_value6 ;
        l_Days_in_Value7 := p_value7 ;
        l_Days_in_Value8 := p_value8 ;
        l_Days_in_Value9 := p_value9 ;
        l_Days_in_Value10 := p_value10 ;
        --
        IF p_Days_Passed_By < p_value1 THEN
            l_Days_in_Value1 := p_value1 - p_Days_Passed_By ;
        ELSIF p_Days_Passed_By < p_value1 + p_value2 THEN
            l_Days_in_Value1 := 0 ;
            l_Days_in_Value2 := p_value1 + p_value2 - p_Days_Passed_By ;
        ELSIF p_Days_Passed_By < p_value1 + p_value2 + p_value3 THEN
            l_Days_in_Value1 := 0 ;
            l_Days_in_Value2 := 0 ;
            l_Days_in_Value3 := p_value1 + p_value2 + p_value3 - p_Days_Passed_By ;
        ELSIF p_Days_Passed_By < p_value1 + p_value2 + p_value3 + p_value4 THEN
            l_Days_in_Value1 := 0 ;
            l_Days_in_Value2 := 0 ;
            l_Days_in_Value3 := 0 ;
            l_Days_in_Value4 := p_value1 + p_value2 + p_value3 + p_value4 - p_Days_Passed_By ;
        ELSIF p_Days_Passed_By < p_value1 + p_value2 + p_value3 + p_value4 + p_value5 THEN
            l_Days_in_Value1 := 0 ;
            l_Days_in_Value2 := 0 ;
            l_Days_in_Value3 := 0 ;
            l_Days_in_Value4 := 0 ;
            l_Days_in_Value5 := p_value1 + p_value2 + p_value3 + p_value4 + p_value5 - p_Days_Passed_By ;
        ELSIF p_Days_Passed_By < p_value1 + p_value2 + p_value3 + p_value4 + p_value5 + p_value6 THEN
            l_Days_in_Value1 := 0 ;
            l_Days_in_Value2 := 0 ;
            l_Days_in_Value3 := 0 ;
            l_Days_in_Value4 := 0 ;
            l_Days_in_Value5 := 0 ;
            l_Days_in_Value6 := p_value1 + p_value2 + p_value3 + p_value4 + p_value5 + p_value6 - p_Days_Passed_By ;
        ELSIF p_Days_Passed_By < p_value1 + p_value2 + p_value3 + p_value4 + p_value5 + p_value6 + p_value7 THEN
            l_Days_in_Value1 := 0 ;
            l_Days_in_Value2 := 0 ;
            l_Days_in_Value3 := 0 ;
            l_Days_in_Value4 := 0 ;
            l_Days_in_Value5 := 0 ;
            l_Days_in_Value6 := 0 ;
            l_Days_in_Value7 := p_value1 + p_value2 + p_value3 + p_value4 + p_value5 + p_value6 + p_value7 - p_Days_Passed_By ;
        ELSIF p_Days_Passed_By < p_value1 + p_value2 + p_value3 + p_value4 + p_value5 + p_value6 + p_value7 + p_value8 THEN
            l_Days_in_Value1 := 0 ;
            l_Days_in_Value2 := 0 ;
            l_Days_in_Value3 := 0 ;
            l_Days_in_Value4 := 0 ;
            l_Days_in_Value5 := 0 ;
            l_Days_in_Value6 := 0 ;
            l_Days_in_Value7 := 0 ;
            l_Days_in_Value8 := p_value1 + p_value2 + p_value3 + p_value4 + p_value5 + p_value6 + p_value7 + p_value8 - p_Days_Passed_By ;
        ELSIF p_Days_Passed_By < p_value1 + p_value2 + p_value3 + p_value4 + p_value5 + p_value6 + p_value7 + p_value8 + p_value9 THEN
            l_Days_in_Value1 := 0 ;
            l_Days_in_Value2 := 0 ;
            l_Days_in_Value3 := 0 ;
            l_Days_in_Value4 := 0 ;
            l_Days_in_Value5 := 0 ;
            l_Days_in_Value6 := 0 ;
            l_Days_in_Value7 := 0 ;
            l_Days_in_Value8 := 0 ;
            l_Days_in_Value9 := p_value1 + p_value2 + p_value3 + p_value4 + p_value5 + p_value6 + p_value7 + p_value8 + p_value9 - p_Days_Passed_By ;
        ELSE
            l_Days_in_Value1 := 0 ;
            l_Days_in_Value2 := 0 ;
            l_Days_in_Value3 := 0 ;
            l_Days_in_Value4 := 0 ;
            l_Days_in_Value5 := 0 ;
            l_Days_in_Value6 := 0 ;
            l_Days_in_Value7 := 0 ;
            l_Days_in_Value8 := 0 ;
            l_Days_in_Value9 := 0 ;
            l_Days_in_Value10 := p_value1 + p_value2 + p_value3 + p_value4 + p_value5 + p_value6 + p_value7 + p_value8 + p_value9 + p_value10 - p_Days_Passed_By ;
        END IF;
        --
        IF p_pattern = 'P' THEN
            IF l_Days_in_Value1 > 0 THEN
               bu_end_date := bu_start_date + l_Days_in_Value1 - 1;
               temp := pay_es_ss_calculation.get_working_time( p_assignment_id
                                                              ,p_business_gr_id
                                                              ,bu_start_date
                                                              ,bu_end_date
                                                              ,l_Days_in_Value1
                                                              ,l_working_hrs);
                bu_start_date := bu_end_date + 1;
            END IF;
            IF l_Days_in_Value2 > 0 THEN
               bu_end_date := bu_start_date + l_Days_in_Value2 - 1;
               temp := pay_es_ss_calculation.get_working_time( p_assignment_id
                                                              ,p_business_gr_id
                                                              ,bu_start_date
                                                              ,bu_end_date
                                                              ,l_Days_in_Value2
                                                              ,l_working_hrs);
                bu_start_date := bu_end_date + 1;
            END IF;
            IF l_Days_in_Value3 > 0 THEN
               bu_end_date := bu_start_date + l_Days_in_Value3 - 1;
               temp := pay_es_ss_calculation.get_working_time( p_assignment_id
                                                              ,p_business_gr_id
                                                              ,bu_start_date
                                                              ,bu_end_date
                                                              ,l_Days_in_Value3
                                                              ,l_working_hrs);
                bu_start_date := bu_end_date + 1;
            END IF;
            IF l_Days_in_Value4 > 0 THEN
               bu_end_date := bu_start_date + l_Days_in_Value4 - 1;
               temp := pay_es_ss_calculation.get_working_time( p_assignment_id
                                                              ,p_business_gr_id
                                                              ,bu_start_date
                                                              ,bu_end_date
                                                              ,l_Days_in_Value4
                                                              ,l_working_hrs);
                bu_start_date := bu_end_date + 1;
            END IF;
            IF l_Days_in_Value5 > 0 THEN
               bu_end_date := bu_start_date + l_Days_in_Value5 - 1;
               temp := pay_es_ss_calculation.get_working_time( p_assignment_id
                                                              ,p_business_gr_id
                                                              ,bu_start_date
                                                              ,bu_end_date
                                                              ,l_Days_in_Value5
                                                              ,l_working_hrs);
                bu_start_date := bu_end_date + 1;
            END IF;
            IF l_Days_in_Value6 > 0 THEN
               bu_end_date := bu_start_date + l_Days_in_Value6 - 1;
               temp := pay_es_ss_calculation.get_working_time( p_assignment_id
                                                              ,p_business_gr_id
                                                              ,bu_start_date
                                                              ,bu_end_date
                                                              ,l_Days_in_Value6
                                                              ,l_working_hrs);
                bu_start_date := bu_end_date + 1;
            END IF;
            IF l_Days_in_Value7 > 0 THEN
               bu_end_date := bu_start_date + l_Days_in_Value7 - 1;
               temp := pay_es_ss_calculation.get_working_time( p_assignment_id
                                                              ,p_business_gr_id
                                                              ,bu_start_date
                                                              ,bu_end_date
                                                              ,l_Days_in_Value7
                                                              ,l_working_hrs);
                bu_start_date := bu_end_date + 1;
            END IF;
            IF l_Days_in_Value8 > 0 THEN
               bu_end_date := bu_start_date + l_Days_in_Value8 - 1;
               temp := pay_es_ss_calculation.get_working_time( p_assignment_id
                                                              ,p_business_gr_id
                                                              ,bu_start_date
                                                              ,bu_end_date
                                                              ,l_Days_in_Value8
                                                              ,l_working_hrs);
                bu_start_date := bu_end_date + 1;
            END IF;
            IF l_Days_in_Value9 > 0 THEN
               bu_end_date := bu_start_date + l_Days_in_Value9 - 1;
               temp := pay_es_ss_calculation.get_working_time( p_assignment_id
                                                              ,p_business_gr_id
                                                              ,bu_start_date
                                                              ,bu_end_date
                                                              ,l_Days_in_Value9
                                                              ,l_working_hrs);
                bu_start_date := bu_end_date + 1;
            END IF;
            IF l_Days_in_Value10 > 0 THEN
               bu_end_date := bu_start_date + l_Days_in_Value10 - 1;
               temp := pay_es_ss_calculation.get_working_time( p_assignment_id
                                                              ,p_business_gr_id
                                                              ,bu_start_date
                                                              ,bu_end_date
                                                              ,l_Days_in_Value10
                                                              ,l_working_hrs);
                bu_start_date := bu_end_date + 1;
            END IF;
        END IF;
        --
        IF l_Benefit_Days_w < l_Days_in_Value1 THEN
            l_Benefit_Uplift := (l_Day_Amount * l_Benefit_Days_w * p_rate1 / 100) ;
        ELSIF l_Benefit_Days_w < l_Days_in_Value1 + l_Days_in_Value2 THEN
            l_Benefit_Uplift := (l_Day_Amount * (l_Days_in_Value1 * p_rate1 + (l_Benefit_Days_w - l_Days_in_Value1) * p_rate2) / 100) ;
        ELSIF l_Benefit_Days_w < l_Days_in_Value1 + l_Days_in_Value2 + l_Days_in_Value3 THEN
            l_Benefit_Uplift := (l_Day_Amount *
                             (l_Days_in_Value1 * p_rate1 + l_Days_in_Value2 * p_rate2 +
                             (l_Benefit_Days_w - l_Days_in_Value1 - l_Days_in_Value2) * p_rate3) / 100) ;
        ELSIF l_Benefit_Days_w < l_Days_in_Value1 + l_Days_in_Value2 + l_Days_in_Value3 + l_Days_in_Value4 THEN
            l_Benefit_Uplift := (l_Day_Amount *
                             (l_Days_in_Value1 * p_rate1 + l_Days_in_Value2 * p_rate2 + l_Days_in_Value3 * p_rate3 +
                             (l_Benefit_Days_w - l_Days_in_Value1 - l_Days_in_Value2 - l_Days_in_Value3) * p_rate4) / 100) ;
        ELSIF l_Benefit_Days_w < l_Days_in_Value1 + l_Days_in_Value2 + l_Days_in_Value3 + l_Days_in_Value4 + l_Days_in_Value5 THEN
            l_Benefit_Uplift := (l_Day_Amount *
                             (l_Days_in_Value1 * p_rate1 + l_Days_in_Value2 * p_rate2 + l_Days_in_Value3 * p_rate3 + l_Days_in_Value4 * p_rate4 +
                             (l_Benefit_Days_w - l_Days_in_Value1 - l_Days_in_Value2 - l_Days_in_Value3 - l_Days_in_Value4) * p_rate5) / 100) ;
        ELSIF l_Benefit_Days_w < l_Days_in_Value1 + l_Days_in_Value2 + l_Days_in_Value3 + l_Days_in_Value4 + l_Days_in_Value5 + l_Days_in_Value6 THEN
            l_Benefit_Uplift := (l_Day_Amount *
                             (l_Days_in_Value1 * p_rate1 + l_Days_in_Value2 * p_rate2 + l_Days_in_Value3 * p_rate3 + l_Days_in_Value4 * p_rate4 +
                             l_Days_in_Value5 * p_rate5 +
                             (l_Benefit_Days_w - l_Days_in_Value1 - l_Days_in_Value2 - l_Days_in_Value3 - l_Days_in_Value4 - l_Days_in_Value5)
                             * p_rate6) / 100) ;
        ELSIF l_Benefit_Days_w < l_Days_in_Value1 + l_Days_in_Value2 + l_Days_in_Value3 + l_Days_in_Value4 + l_Days_in_Value5 + l_Days_in_Value6 + l_Days_in_Value7 THEN
            l_Benefit_Uplift := (l_Day_Amount *
                             (l_Days_in_Value1 * p_rate1 + l_Days_in_Value2 * p_rate2 + l_Days_in_Value3 * p_rate3 + l_Days_in_Value4 * p_rate4 +
                             l_Days_in_Value5 * p_rate5 + l_Days_in_Value6 * p_rate6 +
                             (l_Benefit_Days_w - l_Days_in_Value1 - l_Days_in_Value2 - l_Days_in_Value3 - l_Days_in_Value4 - l_Days_in_Value5 - l_Days_in_Value6 )
                             * p_rate7) / 100) ;
        ELSIF l_Benefit_Days_w < l_Days_in_Value1 + l_Days_in_Value2 + l_Days_in_Value3 + l_Days_in_Value4 + l_Days_in_Value5 + l_Days_in_Value6
                + l_Days_in_Value7 + l_Days_in_Value8 THEN
            l_Benefit_Uplift := (l_Day_Amount *
                             (l_Days_in_Value1 * p_rate1 + l_Days_in_Value2 * p_rate2 + l_Days_in_Value3 * p_rate3 + l_Days_in_Value4 * p_rate4 +
                             l_Days_in_Value5 * p_rate5 + l_Days_in_Value6 * p_rate6 + l_Days_in_Value7 * p_rate7 +
                             (l_Benefit_Days_w - l_Days_in_Value1 - l_Days_in_Value2 - l_Days_in_Value3 - l_Days_in_Value4 - l_Days_in_Value5 - l_Days_in_Value6 -
                             l_Days_in_Value7 ) * p_rate8) / 100) ;
        ELSIF l_Benefit_Days_w < l_Days_in_Value1 + l_Days_in_Value2 + l_Days_in_Value3 + l_Days_in_Value4 + l_Days_in_Value5 + l_Days_in_Value6
                + l_Days_in_Value7 + l_Days_in_Value8 + l_Days_in_Value9 THEN
            l_Benefit_Uplift := (l_Day_Amount *
                             (l_Days_in_Value1 * p_rate1 + l_Days_in_Value2 * p_rate2 + l_Days_in_Value3 * p_rate3 + l_Days_in_Value4 * p_rate4 +
                             l_Days_in_Value5 * p_rate5 + l_Days_in_Value6 * p_rate6 + l_Days_in_Value7 * p_rate7 + l_Days_in_Value8 * p_rate8 +
                             (l_Benefit_Days_w - l_Days_in_Value1 - l_Days_in_Value2 - l_Days_in_Value3 - l_Days_in_Value4 - l_Days_in_Value5 - l_Days_in_Value6 -
                             l_Days_in_Value7 - l_Days_in_Value8 ) * p_rate9) / 100) ;
        ELSIF l_Benefit_Days_w < l_Days_in_Value1 + l_Days_in_Value2 + l_Days_in_Value3 + l_Days_in_Value4 + l_Days_in_Value5 + l_Days_in_Value6
                + l_Days_in_Value7 + l_Days_in_Value8 + l_Days_in_Value9 + l_Days_in_Value10 THEN
            l_Benefit_Uplift := (l_Day_Amount *
                             (l_Days_in_Value1 * p_rate1 + l_Days_in_Value2 * p_rate2 + l_Days_in_Value3 * p_rate3 + l_Days_in_Value4 * p_rate4 +
                             l_Days_in_Value5 * p_rate5 + l_Days_in_Value6 * p_rate6 + l_Days_in_Value7 * p_rate7 + l_Days_in_Value8 * p_rate8 +
                             l_Days_in_Value9 * p_rate9 +
                             (l_Benefit_Days_w - l_Days_in_Value1 - l_Days_in_Value2 - l_Days_in_Value3 - l_Days_in_Value4 - l_Days_in_Value5 - l_Days_in_Value6 -
                             l_Days_in_Value7 - l_Days_in_Value8 - l_Days_in_Value9 ) * p_rate10) / 100) ;
        ELSE
            l_Benefit_Uplift := (l_Day_Amount *
                             (l_Days_in_Value1 * p_rate1 + l_Days_in_Value2 * p_rate2 + l_Days_in_Value3 * p_rate3 + l_Days_in_Value4 * p_rate4 +
                             l_Days_in_Value5 * p_rate5 + l_Days_in_Value6 * p_rate6 + l_Days_in_Value7 * p_rate7 + l_Days_in_Value8 * p_rate8 +
                             l_Days_in_Value9 * p_rate9 + l_Days_in_Value10 * p_rate10) / 100) ;
        END IF;
        --
        p_Benefit_Uplift := p_Benefit_Uplift + l_Benefit_Uplift;
        l_BU_Calculation := p_bu_calc_method_e ;
        l_BU_Rate_Formula := p_bu_daily_rate_e ;
        l_BU_Duration_Formula := p_bu_duration_e ;
    --

    END LOOP;
    --
    RETURN 'Y';
--
END get_bu_info;
--
--------------------------------------------------------------------------------
-- GET_PU_CONTRIBUTION_VALUE
--------------------------------------------------------------------------------
--
FUNCTION get_pu_contribution_value(p_assignment_id          IN NUMBER
                                  ,p_assignment_action_id   IN NUMBER
                                  ,p_balance_SS             IN VARCHAR2
                                  ,p_database_item_SS       IN VARCHAR2
                                  ,p_balance_PU             IN VARCHAR2
                                  ,p_database_item_PU       IN VARCHAR2
                                  ,p_PU_start_date          IN DATE
                                  ,p_span_days              IN NUMBER
                                  ,p_ss_days                OUT NOCOPY NUMBER)RETURN NUMBER IS
    --
    l_Contri_Base_PU  NUMBER;
    l_Contri_Base_180 NUMBER;
    l_def_bal_id_SS   NUMBER;
    l_def_bal_id_PU   NUMBER;
    l_ctr             NUMBER;
    l_prev_date       DATE;
    l_num             NUMBER;
    l_amt             NUMBER;
    --
    CURSOR get_prev_periods_dates (c_assignment_action_id NUMBER
                                  ,c_period_start_date    DATE) IS
    SELECT  ptp.start_date             start_date
           ,ptp.end_date               end_date
           ,ppa.action_type            action_type
           ,paa2.assignment_action_id  assignment_action_id
    FROM    pay_assignment_actions paa1
           ,pay_assignment_actions paa2
           ,per_all_assignments_f paaf1
           ,per_all_assignments_f paaf2
           ,pay_payroll_actions ppa
           ,pay_payroll_actions ppa1
           ,per_time_period_types ptpt
           ,per_time_periods ptp
    WHERE   paa1.assignment_action_id     = c_assignment_action_id
    AND     ppa1.payroll_action_id        = paa1.payroll_action_id
    AND     ppa1.business_group_id        = paaf1.business_group_id
    AND     paaf1.assignment_id           = paa1.assignment_id
    AND     paaf2.person_id               = paaf1.person_id
    AND     paaf2.business_group_id       = paaf1.business_group_id
    AND     paa2.assignment_id            = paaf2.assignment_id
    AND     paa2.tax_unit_id              = paa1.tax_unit_id
    AND     ppa.payroll_action_id         = paa2.payroll_action_id
    AND     ppa.business_group_id         = paaf1.business_group_id
    AND     paa2.source_action_id         IS NULL
    AND     ptp.period_type               = ptpt.period_type
    AND     ptp.start_date                < c_period_start_date
    AND     ptp.payroll_id                = ppa.payroll_id
    AND     ppa.action_type               IN ('R','Q','I','B')
    AND     ppa.action_status             IN('C','U')
    AND     ppa.date_earned  BETWEEN ptp.start_date              AND ptp.end_date
    AND     ptp.end_date     BETWEEN paaf1.effective_start_date  AND paaf1.effective_end_date
    AND     ptp.end_date     BETWEEN paaf2.effective_start_date  AND paaf2.effective_end_date
   ORDER BY ptp.start_date DESC,paa2.assignment_action_id DESC;
 --
/*    SELECT ptp.start_date start_date
          ,ptp.end_date end_date
          ,paa2.assignment_action_id assignment_action_id
          ,ppa.action_type           action_type
    FROM   pay_assignment_actions paa1
          ,pay_assignment_actions paa2
          ,per_all_assignments_f paaf1
          ,per_all_assignments_f paaf2
          ,pay_payroll_actions ppa
          ,per_time_periods ptp
    WHERE paa1.assignment_action_id     = c_assignment_action_id
    AND   paa1.assignment_id            = paaf1.assignment_id
    AND   paaf1.person_id               = paaf2.person_id
    AND   paaf2.assignment_id           = paa2.assignment_id
    AND   paa1.tax_unit_id              = paa2.tax_unit_id
    AND   paa2.payroll_action_id        = ppa.payroll_action_id
    AND   paa2.source_action_id         IS NULL
    AND   ptp.start_date < c_period_start_date
    AND   ppa.payroll_id                = ptp.payroll_id
    AND   ppa.time_period_id            = ptp.time_period_id
    AND   ppa.action_type IN ('R','Q','I','B')
    AND   ppa.action_status              IN('C','U')
    AND   ptp.start_date BETWEEN paaf1.effective_start_date
                                        AND paaf1.effective_end_date
    AND   ptp.start_date BETWEEN paaf2.effective_start_date
                                        AND paaf2.effective_end_date
    ORDER BY ptp.start_date DESC,paa2.assignment_action_id DESC;
*/    --
BEGIN
    l_def_bal_id_SS := pay_es_calc_ss_earnings.get_defined_bal_id( p_balance_SS, p_database_item_SS);
    l_def_bal_id_PU := pay_es_calc_ss_earnings.get_defined_bal_id( p_balance_PU, p_database_item_PU);
    p_ss_days := 0;
    l_Contri_Base_PU := 0;
    l_Contri_Base_180 := 0;
    l_ctr := 0;
    l_num := 0;
    l_prev_date := to_date('01-01-0001','dd-mm-yyyy');
    l_amt := 0;
    --
    BEGIN
    l_Contri_Base_PU := pay_balance_pkg.get_value(l_def_bal_id_PU, p_assignment_id, p_PU_start_date);
        EXCEPTION
        WHEN no_data_found THEN
            l_Contri_Base_PU := 0;
    END;
    --
    FOR i IN get_prev_periods_dates( p_assignment_action_id, p_PU_start_date) LOOP
     --
     IF l_prev_date <> i.start_date THEN
        --
        l_num := l_num + 1;
        IF l_ctr = 0 THEN
            p_ss_days := p_ss_days + pay_balance_pkg.get_value (l_def_bal_id_SS, i.assignment_action_id);
        END IF;
        --
        IF p_span_days <= p_ss_days THEN
            --
            BEGIN
            l_Contri_Base_180 := pay_balance_pkg.get_value (l_def_bal_id_PU,i.assignment_action_id);-- p_assignment_id, i.start_date);
                EXCEPTION
                WHEN no_data_found THEN
                    l_Contri_Base_180 := 0;
            END;
            --
            IF l_ctr > 0 THEN
               l_amt := 1;
               EXIT;
            END IF;
            l_ctr := l_ctr + 1;
            --
        END IF;
        --
       l_prev_date := i.start_date;
      END IF;
      --
    END LOOP;
    --
    IF l_amt = 0 THEN
        RETURN (l_Contri_Base_PU);
    END IF;
    --
    IF l_num > 1 THEN
       RETURN (l_Contri_Base_PU - l_Contri_Base_180);
    ELSIF l_num = 1 THEN
       RETURN (l_Contri_Base_PU);
    ELSE
       RETURN 0;
    END IF;
    --
END get_pu_contribution_value;
--

--
END pay_es_calc_ss_earnings;

/
