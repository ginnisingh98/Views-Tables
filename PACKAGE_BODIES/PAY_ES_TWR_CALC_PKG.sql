--------------------------------------------------------
--  DDL for Package Body PAY_ES_TWR_CALC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_ES_TWR_CALC_PKG" AS
/* $Header: pyestwrc.pkb 120.9 2006/01/09 23:28:59 kseth noship $ */
--
    START_OF_TIME CONSTANT DATE := TO_DATE('01/01/0001','DD/MM/YYYY');
    END_OF_TIME   CONSTANT DATE := TO_DATE('31/12/4712','DD/MM/YYYY');
--
--------------------------------------------------------------------------------
-- get_payment_key
--------------------------------------------------------------------------------
FUNCTION get_payment_key(passignment_id    NUMBER
                        ,peffective_date   DATE ) RETURN VARCHAR2 IS
    --
    CURSOR c_payment_key(c_element_name VARCHAR2
                        ,c_input_value_name VARCHAR2) IS
     SELECT  eev.screen_entry_value payment_key
      FROM   pay_element_types_f         pet
            ,pay_input_values_f          piv
            ,pay_element_entry_values_f  eev
            ,pay_element_entries_f       pee
      WHERE  pee.assignment_id      = passignment_id
      AND    pee.element_type_id    = pet.element_type_id
      AND    pet.element_name       = c_element_name
      AND    pet.legislation_code   = 'ES'
      AND    peffective_date        BETWEEN pet.effective_start_date
                                    AND     pet.effective_end_date
      AND    piv.name               = c_input_value_name
      AND    piv.legislation_code   = 'ES'
      AND    peffective_date        BETWEEN piv.effective_start_date
                                    AND     piv.effective_end_date
      AND    piv.element_type_id    = pee.element_type_id
      AND    eev.input_value_id + 0 = piv.input_value_id
      AND    peffective_date        BETWEEN eev.effective_start_date
                                    AND     eev.effective_end_date
      AND    pee.element_entry_id   = eev.element_entry_id
      AND    peffective_date        BETWEEN pee.effective_start_date
                                    AND     pee.effective_end_date ;
    --
    lpayment_key pay_element_entry_values_f.screen_entry_value%TYPE;
    --
BEGIN
    --
    OPEN c_payment_key('Tax Details','Payment Key');
    FETCH c_payment_key INTO lpayment_key;
        IF  c_payment_key%NOTFOUND THEN
            CLOSE c_payment_key;
            RETURN NULL;
        END IF;
    CLOSE c_payment_key;
    --
    RETURN lpayment_key;
    --
END get_payment_key;
--
--------------------------------------------------------------------------------
-- get_no_contacts
--------------------------------------------------------------------------------
FUNCTION get_no_contacts(passignment_id                   IN NUMBER
                        ,pbusiness_gr_id                  IN NUMBER
                        ,peffective_date                  IN DATE
                        ,pno_descendant                   OUT NOCOPY NUMBER
                        ,pno_descendant_less_3            OUT NOCOPY NUMBER
                        ,pno_descendant_bet_3_25          OUT NOCOPY NUMBER
                        ,pno_desc_disability_33_64        OUT NOCOPY NUMBER
                        ,pno_desc_disability_gr_65        OUT NOCOPY NUMBER
                        ,pno_desc_reduced_mobility        OUT NOCOPY NUMBER
                        ,pno_desc_single_parent           OUT NOCOPY NUMBER
                        ,pno_ascendant                    OUT NOCOPY NUMBER
                        ,pno_ascendant_gr_75              OUT NOCOPY NUMBER
                        ,pno_asc_disability_33_64         OUT NOCOPY NUMBER
                        ,pno_asc_disability_gr_65         OUT NOCOPY NUMBER
                        ,pno_asc_reduced_mobility         OUT NOCOPY NUMBER
                        ,pno_asc_single_descendant        OUT NOCOPY NUMBER
                        ,pdescendant_dis_amt              OUT NOCOPY NUMBER
                        ,pdescendant_sp_assistance_amt    OUT NOCOPY NUMBER
                        ,pascendant_dis_amt               OUT NOCOPY NUMBER
                        ,pascendant_sp_assistance_amt     OUT NOCOPY NUMBER
                        ,pascendant_age_deduction_amt     OUT NOCOPY NUMBER
                        ,pno_independent_siblings         OUT NOCOPY NUMBER
                        ,psingle_parent                   OUT NOCOPY VARCHAR2
                        ,pno_descendant_adopt_less_3      OUT NOCOPY NUMBER)
                         RETURN NUMBER IS
    --
    CURSOR c_contact_info IS
    SELECT pap.date_of_birth     date_of_birth
          ,pcr.contact_person_id contact_person_id
          ,pcr.contact_type
          ,NVL(pcr.cont_information1,'N') fiscal_dependent
          ,NVL(pcr.cont_information2,'N') single_parent
          ,pcr.date_start date_start
    FROM   per_contact_relationships pcr
          ,per_all_people_f pap
          ,per_All_assignments_f paaf
    WHERE  paaf.assignment_id              = passignment_id
    AND    pcr.person_id                   = paaf.person_id
    AND    pap.person_id                   = pcr.contact_person_id
    AND    pcr.rltd_per_rsds_w_dsgntr_flag = 'Y'
    AND    pcr.cont_information_category   = 'ES'
    AND    ((pcr.contact_type in ('C','JP_GC','NEPHEW','NIECE','A') AND  NVL(pap.marital_status,'S') <> 'M')
             OR (pcr.contact_type in ('P','GP','UNCLE','AUNT','BROTHER','SISTER')))
    AND    ((pcr.cont_information1           = 'Y'
            AND    pcr.contact_type in ('C','JP_GC','NEPHEW','NIECE','A','P','GP','UNCLE','AUNT'))
            OR(pcr.cont_information1           = 'N'
            AND    pcr.contact_type in ('BROTHER','SISTER')))
    AND    peffective_date                 BETWEEN pap.effective_start_date
                                           AND     pap.effective_end_date
    AND    peffective_date                 BETWEEN paaf.effective_start_date
                                           AND     paaf.effective_end_date
    AND    peffective_date BETWEEN nvl(pcr.date_start,START_OF_TIME)
                           AND     nvl(pcr.date_end,END_OF_TIME);
    --
    lage                NUMBER;
    ldegree             per_disabilities_f.degree%TYPE;
    lspecial_care_flag  per_disabilities_f.dis_information1%TYPE;
    ldisablity_amt      NUMBER;
    lspl_care_amt       NUMBER;
    l_asc_age_deduction NUMBER;
    --
BEGIN
    --
    pno_descendant                  := 0;
    pno_ascendant                   := 0;
    pno_descendant_less_3           := 0;
    pno_descendant_bet_3_25         := 0;
    pno_desc_disability_33_64       := 0;
    pno_desc_disability_gr_65       := 0;
    pno_desc_reduced_mobility       := 0;
    pno_desc_single_parent          := 0;
    pno_ascendant_gr_75             := 0;
    pno_asc_disability_33_64        := 0;
    pno_asc_disability_gr_65        := 0;
    pno_asc_reduced_mobility        := 0;
    pdescendant_dis_amt             := 0;
    pdescendant_sp_assistance_amt   := 0;
    pascendant_dis_amt              := 0;
    pascendant_sp_assistance_amt    := 0;
    pno_independent_siblings        := 0;
    pno_asc_single_descendant       := 0;
    pascendant_age_deduction_amt    := 0;
    pno_descendant_adopt_less_3     := 0;

    --
    FOR i in c_contact_info LOOP
        IF  i.single_parent = 'Y' THEN
            psingle_parent := 'Y';
        END IF;
        ldegree := 0;
        lspecial_care_flag := 'N';
        lspl_care_amt := 0;
        ldisablity_amt := 0;
        l_asc_age_deduction := 0;
        IF  i.fiscal_dependent = 'Y' THEN
            lage :=  MONTHS_BETWEEN(peffective_date,i.date_of_birth)/12;
            IF  lage <= 25 AND
                i.contact_type in ('C','JP_GC','NEPHEW','NIECE','A') THEN
                --
                pno_descendant := pno_descendant + 1;
                --
                IF  i.contact_type = 'A' AND
                    months_between(peffective_date,nvl(i.date_start,START_OF_TIME)) < 36 THEN
                    --
                    pno_descendant_adopt_less_3 := pno_descendant_adopt_less_3 + 1;
                    --
                END IF;
                IF  lage <=3 THEN
                    pno_descendant_less_3 := pno_descendant_less_3 + 1;
                ELSE
                    pno_descendant_bet_3_25 := pno_descendant_bet_3_25 + 1;
                END IF;
                IF  NVL(i.single_parent,'N') = 'Y' THEN
                    pno_desc_single_parent := pno_desc_single_parent + 1;
                END IF;
                IF  get_disability_detail(i.contact_person_id
                                         ,peffective_date
                                         ,ldegree
                                         ,lspecial_care_flag) = 'Y' THEN
                    --
                    IF  ldegree >= 33 and ldegree <65 THEN
                        pno_desc_disability_33_64 := pno_desc_disability_33_64 + 1;
                    ELSIF ldegree >= 65 THEN
                        pno_desc_disability_gr_65 := pno_desc_disability_gr_65 + 1;
                    END IF;
                    ldisablity_amt :=get_table_value(
                                         bus_group_id =>  pbusiness_gr_id
                                        ,ptab_name     => 'ES_DISABILITY_ALLOWANCE'
                                        ,pcol_name     => 'DESCENDANT'
                                        ,prow_value    =>  ldegree
                                        ,peffective_date => peffective_date);
                    IF  i.single_parent = 'N' THEN
                        ldisablity_amt := ldisablity_amt / 2;
                    END IF;
                    --
                    pdescendant_dis_amt := pdescendant_dis_amt + ldisablity_amt;
                    --
                    IF  ldegree >= 65 AND lspecial_care_flag = 'Y' THEN
                        IF  lspecial_care_flag = 'Y' THEN
                            pno_desc_reduced_mobility := pno_desc_reduced_mobility + 1;
                        END IF;
                        lspl_care_amt := get_table_value(
                                             bus_group_id =>  pbusiness_gr_id
                                            ,ptab_name     => 'ES_DISABILITY_ASSISTANCE_ALLOWANCE'
                                            ,pcol_name     => 'DISABILITY_ALLOWANCE'
                                            ,prow_value    => 'DESCENDANT'
                                            ,peffective_date => peffective_date);
                        IF  i.single_parent = 'N' THEN
                            lspl_care_amt := lspl_care_amt / 2;
                        END IF;
                        pdescendant_sp_assistance_amt := pdescendant_sp_assistance_amt + lspl_care_amt;
                    END IF;
                END IF;
            ELSIF lage >= 75 AND i.contact_type IN ('P','GP','UNCLE','AUNT') THEN
                pno_ascendant := pno_ascendant + 1;
                pno_ascendant_gr_75 := pno_ascendant_gr_75 + 1;
                l_asc_age_deduction:= get_table_value(
                                          bus_group_id    =>  pbusiness_gr_id
                                         ,ptab_name       => 'ES_AGE_ALLOWANCE'
                                         ,pcol_name       => 'AGE_ALLOWANCE'
                                         ,prow_value      => 'ASCENDANT'
                                         ,peffective_date => peffective_Date);
                --
                pascendant_age_deduction_amt := pascendant_age_deduction_amt + l_asc_age_deduction;
                --
                IF  get_disability_detail(i.contact_person_id
                                         ,peffective_date
                                         ,ldegree
                                         ,lspecial_care_flag) = 'Y' THEN
                    --
                    IF  ldegree >= 33 AND ldegree <65 THEN
                        pno_asc_disability_33_64 := pno_asc_disability_33_64 + 1;
                    ELSIF ldegree >= 65 THEN
                        pno_asc_disability_gr_65 := pno_asc_disability_gr_65 + 1;
                    END IF;
                    ldisablity_amt :=get_table_value(
                                         bus_group_id =>  pbusiness_gr_id
                                        ,ptab_name     => 'ES_DISABILITY_ALLOWANCE'
                                        ,pcol_name     => 'ASCENDANT'
                                        ,prow_value    =>  ldegree
                                        ,peffective_date => peffective_date);
                    --
                    pascendant_dis_amt := pascendant_dis_amt + ldisablity_amt;
                    --
                    IF ldegree >= 65 AND lspecial_care_flag = 'Y' THEN
                        IF lspecial_care_flag = 'Y' THEN
                            pno_asc_reduced_mobility := pno_asc_reduced_mobility + 1;
                        END IF;
                        lspl_care_amt := get_table_value(
                                             bus_group_id    =>  pbusiness_gr_id
                                            ,ptab_name       => 'ES_DISABILITY_ASSISTANCE_ALLOWANCE'
                                            ,pcol_name       => 'DISABILITY_ALLOWANCE'
                                            ,prow_value      => 'ASCENDANT'
                                            ,peffective_date => peffective_date);
                        --
                        pascendant_sp_assistance_amt := pascendant_sp_assistance_amt + lspl_care_amt;
                        --
                    END IF;
                END IF;
            ELSIF get_disability_detail(i.contact_person_id
                                       ,peffective_date
                                       ,ldegree
                                       ,lspecial_care_flag) = 'Y' THEN
                --
                IF  i.contact_type IN ('C','JP_GC','NEPHEW','NIECE','A') THEN
                    IF  i.contact_type = 'A' AND
                        MONTHS_BETWEEN(peffective_date,nvl(i.date_start,START_OF_TIME)) < 36 THEN
                        --
                        pno_descendant_adopt_less_3 := pno_descendant_adopt_less_3 + 1;
                        --
                    END IF;
                    IF  i.single_parent = 'Y' THEN
                        pno_desc_single_parent := pno_desc_single_parent + 1;
                    END IF;
                    IF  ldegree >= 33 AND ldegree <65 THEN
                        pno_desc_disability_33_64 := pno_desc_disability_33_64 + 1;
                    ELSIF ldegree >= 65 THEN
                        pno_desc_disability_gr_65 := pno_desc_disability_gr_65 + 1;
                    END IF;
                    pno_descendant := pno_descendant + 1;
                    ldisablity_amt :=get_table_value(
                                         bus_group_id =>  pbusiness_gr_id
                                        ,ptab_name     => 'ES_DISABILITY_ALLOWANCE'
                                        ,pcol_name     => 'DESCENDANT'
                                        ,prow_value    =>  ldegree
                                        ,peffective_date => peffective_date);
                    --
                    IF  i.single_parent = 'N' THEN
                        ldisablity_amt := ldisablity_amt / 2;
                    END IF;
                    pdescendant_dis_amt := pdescendant_dis_amt + ldisablity_amt;
                    IF  ldegree >= 65 AND lspecial_care_flag = 'Y' THEN
                        IF  lspecial_care_flag = 'Y' THEN
                            pno_desc_reduced_mobility := pno_desc_reduced_mobility + 1;
                        END IF;
                        lspl_care_amt := get_table_value(
                                             bus_group_id =>  pbusiness_gr_id
                                            ,ptab_name     => 'ES_DISABILITY_ASSISTANCE_ALLOWANCE'
                                            ,pcol_name     => 'DISABILITY_ALLOWANCE'
                                            ,prow_value    => 'DESCENDANT'
                                            ,peffective_date => peffective_date);
                        IF  i.single_parent = 'N' THEN
                            lspl_care_amt := lspl_care_amt / 2;
                        END IF;
                        pdescendant_sp_assistance_amt := pdescendant_sp_assistance_amt + lspl_care_amt;
                    END IF;
                ELSIF i.contact_type IN ('P','GP','UNCLE','AUNT') THEN
                    IF  ldegree >= 33 AND ldegree <65 THEN
                        pno_asc_disability_33_64 := pno_asc_disability_33_64 + 1;
                    ELSIF ldegree >= 65 THEN
                        pno_asc_disability_gr_65 := pno_asc_disability_gr_65 + 1;
                    END IF;
                    pno_ascendant := pno_ascendant + 1;
                    ldisablity_amt :=get_table_value(bus_group_id =>  pbusiness_gr_id
                                                    ,ptab_name     => 'ES_DISABILITY_ALLOWANCE'
                                                    ,pcol_name     => 'ASCENDANT'
                                                    ,prow_value    =>  ldegree
                                                    ,peffective_date => peffective_date);
                    pascendant_dis_amt := pascendant_dis_amt + ldisablity_amt;
                    IF ldegree >= 33 OR lage > 65 THEN
                        l_asc_age_deduction:= get_table_value(
                                                  bus_group_id    =>  pbusiness_gr_id
                                                 ,ptab_name       => 'ES_AGE_ALLOWANCE'
                                                 ,pcol_name       => 'AGE_ALLOWANCE'
                                                 ,prow_value      => 'ASCENDANT'
                                                 ,peffective_date => peffective_Date);
                        pascendant_age_deduction_amt := pascendant_age_deduction_amt + l_asc_age_deduction;
                    END IF;
                    IF  ldegree >= 65 AND lspecial_care_flag = 'Y' THEN
                        IF  lspecial_care_flag = 'Y' THEN
                            pno_asc_reduced_mobility := pno_asc_reduced_mobility + 1;
                        END IF;
                        lspl_care_amt := get_table_value(
                                             bus_group_id =>  pbusiness_gr_id
                                            ,ptab_name     => 'ES_DISABILITY_ASSISTANCE_ALLOWANCE'
                                            ,pcol_name     => 'DISABILITY_ALLOWANCE'
                                            ,prow_value    => 'ASCENDANT'
                                            ,peffective_date => peffective_date);
                        pascendant_sp_assistance_amt := pascendant_sp_assistance_amt + lspl_care_amt;
                    END IF;
                END IF;
            END IF;
        ELSE
            pno_independent_siblings := pno_independent_siblings + 1;
        END IF;
    END LOOP;
    psingle_parent := nvl(psingle_parent,'N');
    RETURN 0;
    --
END get_no_contacts;
--------------------------------------------------------------------------------
-- get_marital_status
--------------------------------------------------------------------------------
FUNCTION get_marital_status (passignment_id         IN  NUMBER
                            ,peffective_date        IN  DATE
                            ,passignment_number     OUT NOCOPY VARCHAR2
                            ,pmarital_status_code   OUT NOCOPY VARCHAR2) RETURN VARCHAR2 IS
    --
    CURSOR c_marital_status IS
    SELECT pap.marital_status
          ,pap.person_id
          ,paaf.assignment_number
    FROM   per_all_people_f pap
          ,per_all_assignments_f paaf
    WHERE  paaf.assignment_id = passignment_id
    AND    pap.person_id      = paaf.person_id
    AND    peffective_date    BETWEEN pap.effective_start_date
                              AND     pap.effective_end_date
    AND    peffective_date    BETWEEN paaf.effective_start_date
                              AND     paaf.effective_end_date;
    --
    l_marital_status      per_all_people_f.marital_status%TYPE;
    l_person_id           per_all_people_f.person_id%TYPE;
    l_fiscal_dependent    per_contact_relationships.cont_information1%TYPE;
    l_marital_status_desc VARCHAR2(80);
    --
BEGIN
    --
    OPEN  c_marital_status;
    FETCH c_marital_status INTO l_marital_status,l_person_id, passignment_number;
    CLOSE c_marital_status;
    --
    pmarital_status_code := NVL(l_marital_status,' ');
    --
    l_fiscal_dependent := get_spouse_info(l_person_id, peffective_date);
    --
    IF  l_marital_status = 'S' THEN
        l_marital_status_desc := 'SINGLE';
    ELSIF l_marital_status = 'M' AND l_fiscal_dependent = 'Y' THEN
        l_marital_status_desc := 'MARRIED_TO_FISCAL_DEPENDENT';
    ELSIF l_marital_status = 'L' THEN
        l_marital_status_desc := 'LEGALLY_SEPARATED';
    ELSIF l_marital_status = 'D' THEN
        l_marital_status_desc := 'DIVORCED';
    ELSIF l_marital_status = 'W' THEN
        l_marital_status_desc := 'WIDOWED';
    ELSIF l_marital_status IS NULL THEN
        l_marital_status_desc := 'SINGLE';
    ELSE
        l_marital_status_desc := 'OTHERS';
    END IF;
    --
    RETURN l_marital_status_desc;
    --
END get_marital_status;
--
--------------------------------------------------------------------------------
-- get_marital_status
--------------------------------------------------------------------------------
FUNCTION get_spouse_info(pperson_id       NUMBER
                        ,peffective_date  DATE ) RETURN VARCHAR2 IS
    --
    CURSOR c_spouse_info IS
    SELECT cont_information1
    FROM   per_contact_relationships pcr
    WHERE  pcr.person_id                 = pperson_id
    AND    pcr.contact_type              = 'S'  --Spouse
    AND    pcr.cont_information_category = 'ES'
    AND    peffective_date  BETWEEN nvl(pcr.date_start,START_OF_TIME)
                            AND     nvl(pcr.date_end,END_OF_TIME);
    --
    l_fiscal_dependent per_contact_relationships.cont_information1%TYPE;
    --
BEGIN
    OPEN  c_spouse_info;
    FETCH c_spouse_info INTO l_fiscal_dependent;
    CLOSE c_spouse_info;
    --
    RETURN l_fiscal_dependent;
    --
END get_spouse_info;
--
--------------------------------------------------------------------------------
-- get_disability_info
--------------------------------------------------------------------------------
--
FUNCTION get_disability_info(passignment_id     IN NUMBER
                            ,peffective_date    IN DATE
                            ,pdegree            OUT NOCOPY NUMBER
                            ,pspecial_care_flag OUT NOCOPY VARCHAR2)
                             RETURN VARCHAR2 IS
    --
    CURSOR c_get_person_id IS
    SELECT person_id
    FROM   per_all_assignments_f paaf
    WHERE  paaf.assignment_id           = passignment_id
    AND    peffective_date              BETWEEN paaf.effective_start_date
                                        AND     paaf.effective_end_date;
    --
    lperson_id per_all_people_f.person_id%TYPE;
    ldisabled VARCHAR2(1);
BEGIN
    --
    OPEN  c_get_person_id;
    FETCH c_get_person_id INTO lperson_id;
    CLOSE c_get_person_id;

    ldisabled := get_disability_detail(lperson_id
                                      ,peffective_date
                                      ,pdegree
                                      ,pspecial_care_flag);
    --
    RETURN ldisabled;
    --
END get_disability_info;
--------------------------------------------------------------------------------
-- get_disability_detail
--------------------------------------------------------------------------------
--
FUNCTION get_disability_detail(pperson_id         IN NUMBER
                              ,peffective_date    IN DATE
                              ,pdegree            OUT NOCOPY NUMBER
                              ,pspecial_care_flag OUT NOCOPY VARCHAR2)
                               RETURN VARCHAR2 IS
    --
    CURSOR c_disability_info IS
    SELECT pdf.dis_information1
          ,pdf.degree
    FROM   per_disabilities_f           pdf
    WHERE  pdf.person_id                = pperson_id
    AND    pdf.dis_information_category = 'ES'
    AND    peffective_date              BETWEEN pdf.effective_start_date
                                        AND     pdf.effective_end_date;
    --
BEGIN
    OPEN  c_disability_info;
    FETCH c_disability_info INTO pspecial_care_flag,pdegree;
    IF  c_disability_info%NOTFOUND THEN
        CLOSE c_disability_info;
        RETURN 'N';
    END IF;
    CLOSE c_disability_info;
    --
    RETURN 'Y';
    --
END get_disability_detail;
--
--------------------------------------------------------------------------------
-- get_table_value
--------------------------------------------------------------------------------
FUNCTION get_table_value(bus_group_id    IN NUMBER
			                  ,ptab_name       IN VARCHAR2
			                  ,pcol_name       IN VARCHAR2
			                  ,prow_value      IN VARCHAR2
                        ,peffective_date IN DATE )RETURN NUMBER IS
    --
    l_ret pay_user_column_instances_f.value%type;
    --
BEGIN
    --
	  BEGIN
        --
		    l_ret:= hruserdt.get_table_value(bus_group_id
					            	                ,ptab_name
						                            ,pcol_name
						                            ,prow_value
                                        ,peffective_date);
        --
	  EXCEPTION
		    WHEN NO_DATA_FOUND THEN
		    l_ret:='0';
	  END;
    --
    RETURN to_number(l_ret);
    --
END get_table_value;
--
--------------------------------------------------------------------------------
-- get_user_table_upper_value
--------------------------------------------------------------------------------
FUNCTION get_user_table_upper_value(pvalue IN NUMBER
                                   ,peffective_date IN DATE) RETURN NUMBER IS
    --
    CURSOR csr_get_table_range(c_value NUMBER
                              ,c_effective_date DATE) IS
    SELECT  to_number(pur.ROW_LOW_RANGE_OR_NAME) Low_value
           ,to_number(pur.ROW_HIGH_RANGE) High_value
    FROM    PAY_USER_ROWS_F pur
           ,PAY_USER_TABLES put
    WHERE   put.USER_TABLE_NAME = 'ES_WORK_RELATED_EARNINGS_DEDUCTION'
    AND     put.USER_TABLE_ID = pur.USER_TABLE_ID
    AND     c_value between to_number(pur.ROW_LOW_RANGE_OR_NAME) AND to_number(pur.ROW_HIGH_RANGE)
    AND     c_effective_date between pur.effective_start_date AND pur.effective_end_date;
    --
    l_table_values csr_get_table_range%ROWTYPE;
    l_table_upper_values csr_get_table_range%ROWTYPE;
    l_val number;
BEGIN
    --
    OPEN csr_get_table_range(pvalue, peffective_date);
    FETCH csr_get_table_range INTO l_table_values;
    CLOSE csr_get_table_range;

    l_val := l_table_values.low_value - 1;

    OPEN csr_get_table_range(l_val, peffective_date);
    FETCH csr_get_table_range INTO l_table_upper_values;
    CLOSE csr_get_table_range;

    RETURN l_table_upper_values.high_value;
    --
END get_user_table_upper_value;
--
--------------------------------------------------------------------------------
-- get_parameter_value
--------------------------------------------------------------------------------
FUNCTION get_parameter_value(p_payroll_action_id IN  NUMBER
                            ,p_token_name        IN  VARCHAR2) RETURN VARCHAR2 IS
    --
    CURSOR csr_parameter_info IS
    SELECT SUBSTR(legislative_parameters,
            INSTR(legislative_parameters,p_token_name)+(LENGTH(p_token_name)+1),
            INSTR(legislative_parameters,' ',
            INSTR(legislative_parameters,p_token_name)))
    FROM   pay_payroll_actions
    WHERE  payroll_action_id = p_payroll_action_id;
    --
    l_token_value                     VARCHAR2(50);
    --
BEGIN
    --
    OPEN csr_parameter_info;
    FETCH csr_parameter_info INTO l_token_value;
    CLOSE csr_parameter_info;
    --
    RETURN(l_token_value);
    --
END get_parameter_value;
--
--------------------------------------------------------------------------------
-- Emp_Address_chk
--------------------------------------------------------------------------------
FUNCTION Emp_address_chk(passignment_id   IN  NUMBER
                        ,peffective_date  IN DATE) RETURN VARCHAR2 IS
    --
    CURSOR cur_emp_address_chk IS
    SELECT pa.Region_2
    FROM   per_addresses pa
          ,per_All_assignments_f paaf
    WHERE  paaf.assignment_id = passignment_id
    AND    paaf.person_id     = pa.person_id
    AND    pa.style           IN('ES','ES_GLB')
    AND    pa.primary_flag    = 'Y'
    AND    pa.Region_2        IN (51,52)
    AND    peffective_date    BETWEEN pa.date_from
                              AND     NVL(pa.date_to,END_OF_TIME)
    AND    peffective_date    BETWEEN paaf.effective_start_date
                              AND     paaf.effective_end_date;
    --
    CURSOR cur_emp_loc_chk IS
    SELECT pa.Region_2
    FROM   hr_locations           pa
          ,per_All_assignments_f  paaf
    WHERE  paaf.assignment_id     = passignment_id
    AND    paaf.location_id       = pa.location_id
    AND    pa.style               IN ('ES','ES_GLB')
    AND    peffective_date        BETWEEN paaf.effective_start_date
                                  AND     paaf.effective_end_date
    AND    pa.Region_2 IN (51,52);
    --
    l_region per_addresses.Region_2%type;
    l_region1 hr_locations.Region_2%type;
    --
BEGIN
    --
    OPEN cur_emp_address_chk;
    FETCH cur_emp_address_chk INTO l_region;
        IF  cur_emp_address_chk%NOTFOUND THEN
            CLOSE cur_emp_address_chk;
            RETURN 'N';
        END IF;
    CLOSE cur_emp_address_chk;

    OPEN cur_emp_loc_chk;
    FETCH cur_emp_loc_chk INTO l_region1;
    IF  cur_emp_loc_chk%NOTFOUND THEN
        CLOSE cur_emp_loc_chk;
        RETURN 'N';
    END IF;
    CLOSE cur_emp_loc_chk;
    --
    RETURN 'Y';
    --
END Emp_Address_chk;
--
--------------------------------------------------------------------------------
-- get_effective_date
--------------------------------------------------------------------------------
FUNCTION get_effective_date(p_payroll_action_id IN  NUMBER
                           ,p_assignment_id     IN  NUMBER
                           ,p_date_earned       IN  DATE
                           ,p_run_type          OUT NOCOPY VARCHAR2
                           ,p_process_twr_flag  OUT NOCOPY VARCHAR2)
RETURN DATE IS
    --
    CURSOR csr_get_effective_date IS
    SELECT ppa.effective_date
          ,prt.shortname
    FROM   pay_payroll_actions ppa
          ,pay_run_types_f     prt
    WHERE  ppa.payroll_action_id = p_payroll_action_id
    AND    ppa.run_type_id       = prt.run_type_id
    AND    ppa.effective_date    BETWEEN prt.effective_start_date
                                 AND     prt.effective_end_date;
    --
    CURSOR csr_chk_twr_process(c_assignment_id  NUMBER
                              ,c_effective_date DATE) IS
    SELECT 'Y'
    FROM   DUAL
    WHERE  EXISTS(SELECT 1
                  FROM   pay_element_entries_f pee
                        ,pay_element_types_f   pet
                  WHERE  pee.assignment_id   = c_assignment_id
                  AND    pee.element_type_id = pet.element_type_id
                  AND    pet.element_name    = 'Tax Withholding Rate'
                  AND    pet.legislation_code= 'ES'
                  AND    c_effective_date BETWEEN pee.effective_start_date
                                              AND pee.effective_end_date
                  AND    c_effective_date BETWEEN pet.effective_start_date
                                              AND pet.effective_end_date);
    --
    l_eff_date      DATE;
    --
BEGIN
    --
    p_process_twr_flag := 'N';
    --
    OPEN  csr_get_effective_date;
    FETCH csr_get_effective_date INTO l_eff_date,p_run_type;
    CLOSE csr_get_effective_date;
    --
    IF p_run_type <> 'TAX_WITHHOLDING_RATE'
       OR p_run_type IS NULL THEN
        l_eff_date := p_date_earned;
    END IF;
    --
    OPEN  csr_chk_twr_process(p_assignment_id,l_eff_date);
    FETCH csr_chk_twr_process INTO p_process_twr_flag;
    CLOSE csr_chk_twr_process;
    --
    p_run_type := NVL(p_run_type,'STANDARD');
    RETURN(l_eff_date);
    --
END get_effective_date;
--
--------------------------------------------------------------------------------
-- get_pay_period_number
--------------------------------------------------------------------------------
FUNCTION get_pay_period_number(payroll_id        IN NUMBER
                              ,peffective_date   IN DATE) RETURN NUMBER IS
    --
    CURSOR csr_get_period_num(c_payroll_id NUMBER,c_effective_date DATE) IS
    SELECT ptp.period_num
    FROM   per_time_periods ptp
    WHERE  ptp.payroll_id   = c_payroll_id
    AND    c_effective_date BETWEEN ptp.start_date
                            AND     ptp.end_date;
    --
    l_no_period per_time_periods.period_num%TYPE;
    --
BEGIN
    --
    OPEN  csr_get_period_num(payroll_id,peffective_date);
    FETCH csr_get_period_num INTO l_no_period;
        IF  csr_get_period_num%NOTFOUND THEN
            CLOSE csr_get_period_num;
            RETURN 0;
        END IF;
    CLOSE csr_get_period_num;
    --
    RETURN (l_no_period);
    --
END get_pay_period_number;
--
--------------------------------------------------------------------------------
-- get_proration_factor
--------------------------------------------------------------------------------
FUNCTION get_proration_factor(passignment_id            IN NUMBER
                             ,payroll_id                IN NUMBER
                             ,peffective_date           IN DATE
                             ,phire_date                IN DATE
                             ,ptermination_date         IN DATE
                             ,ppay_periods_per_year     IN NUMBER
                             ,ppay_proc_period_number   IN NUMBER
                             ,pchk_new_emp              IN VARCHAR2
                             ,p_run_type                IN VARCHAR2)
                             RETURN NUMBER IS
    --
    CURSOR  csr_assignment_start_date(c_assignment_id NUMBER
                                     ,c_payroll_id    NUMBER) IS
    SELECT  MIN(effective_start_date)
    FROM    per_all_assignments_f
    WHERE   assignment_id = c_assignment_id
    AND     payroll_id    = c_payroll_id;

    CURSOR  csr_payroll_end_date(c_payroll_id     NUMBER
                                ,c_effective_date DATE) IS
    SELECT  max(period_num)
    FROM    pay_payrolls_f ppf
           ,per_time_periods ptp
    WHERE   ppf.payroll_id    = c_payroll_id
    AND     ppf.period_type   = ptp.period_type
    AND     ppf.payroll_id    = ptp.payroll_id
    AND     c_effective_date  BETWEEN effective_start_date AND effective_end_date;
    --
    l_start_period NUMBER;
    l_end_period   NUMBER;
    l_start_financial_year NUMBER;
    l_assignment_start_date DATE;
    l_payroll_end NUMBER;
    l_proration_factor NUMBER;
    --
BEGIN
    hr_utility.trace('~~ppay_periods_per_year'||ppay_periods_per_year);
    hr_utility.trace('~~ppay_proc_period_number'||ppay_proc_period_number);
    hr_utility.trace('~~pchk_new_emp'||pchk_new_emp);
    IF  pchk_new_emp <> 'Y' and to_char(ptermination_date,'YYYY') <> to_char(peffective_date,'YYYY') THEN
        IF p_run_type = 'TAX_WITHHOLDING_RATE' THEN
            l_proration_factor := (ppay_periods_per_year - ppay_proc_period_number + 1)/ppay_periods_per_year;
        ELSE
            l_proration_factor := (ppay_periods_per_year - ppay_proc_period_number)/ppay_periods_per_year;
        END IF;
        RETURN (l_proration_factor);
    ELSE
        OPEN  csr_assignment_start_date(passignment_id,payroll_id);
        FETCH csr_assignment_start_date INTO l_assignment_start_date;
        CLOSE csr_assignment_start_date;
        --
        OPEN  csr_payroll_end_date(payroll_id,peffective_date);
        FETCH csr_payroll_end_date INTO l_payroll_end;
        CLOSE csr_payroll_end_date;
        l_start_financial_year := get_pay_period_number(
                                      payroll_id
                                     ,to_date('0101'||to_char(peffective_date,'yyyy'),'ddmmyyyy'));
        IF l_assignment_start_date < to_date('0101'||to_char(peffective_date,'yyyy'),'ddmmyyyy') THEN
            l_assignment_start_date := to_date('0101'||to_char(peffective_date,'yyyy'),'ddmmyyyy');
        END IF;
        --
        IF  pchk_new_emp = 'Y' THEN
            l_start_period := get_pay_period_number(payroll_id,peffective_date);
            IF  TO_CHAR(ptermination_date,'YYYY') = TO_CHAR(peffective_date,'YYYY') THEN
                l_end_period := get_pay_period_number(payroll_id,ptermination_date);
                IF  l_end_period = 0 THEN
                    l_end_period := l_payroll_end;
                END IF;
                IF p_run_type = 'TAX_WITHHOLDING_RATE' THEN
                    l_proration_factor := (l_end_period - l_start_period + 1)/ppay_periods_per_year;
                ELSE
                    l_proration_factor := (l_end_period - l_start_period)/ppay_periods_per_year;
                END IF;
            ELSE
                l_end_period := ppay_periods_per_year;
                IF p_run_type = 'TAX_WITHHOLDING_RATE' THEN
                    l_proration_factor := (l_end_period - (l_start_period- l_start_financial_year + 1) + 1)/ppay_periods_per_year;
                ELSE
                    l_proration_factor := (l_end_period - (l_start_period- l_start_financial_year + 1))/ppay_periods_per_year;
                END IF;
            END IF;
            RETURN (l_proration_factor);
        ELSIF to_char(ptermination_date,'YYYY') = to_char(peffective_date,'YYYY') THEN
            l_end_period := get_pay_period_number(payroll_id,ptermination_date);
            --
            IF  l_end_period = 0 THEN
                l_end_period := l_payroll_end;
            END IF;
            IF p_run_type = 'TAX_WITHHOLDING_RATE' THEN
                l_proration_factor := ((l_end_period - l_start_financial_year + 1)- ppay_proc_period_number + 1)/ppay_periods_per_year;
            ELSE
                l_proration_factor := ((l_end_period - l_start_financial_year + 1)- ppay_proc_period_number)/ppay_periods_per_year;
            END IF;
            RETURN (l_proration_factor);
        END IF;
    END IF;
    RETURN 0;
END get_proration_factor;
--
--------------------------------------------------------------------------------
-- chk_new_employee
--------------------------------------------------------------------------------
FUNCTION chk_new_employee(passignment_id  IN NUMBER
                         ,peffective_date IN DATE) RETURN VARCHAR2 IS
    --
    CURSOR csr_chk_new_emp (c_assignment_id number)IS
    SELECT 'N'
    FROM   dual
    WHERE  EXISTS(SELECT NULL
                  FROM  pay_assignment_actions paa
                       ,pay_payroll_actions    ppa
                       ,pay_run_results        prr
                       ,pay_run_result_values  prv
                       ,pay_element_types_f    petf
                       ,pay_input_values_f     pivf
                  WHERE paa.assignment_id      = c_assignment_id
                  AND   paa.ACTION_STATUS      IN ('C' ,'U')
                  AND   ppa.payroll_action_id  = paa.payroll_action_id
                  and   ppa.action_status      IN ('C' ,'U')
                  AND   to_char(ppa.effective_date,'YYYY') = to_char(peffective_date,'YYYY')
                  AND   petf.legislation_code  = 'ES'
                  AND   ((petf.element_name      = 'Tax Withholding Rate'
                         AND pivf.name          = ('Rate'))
                         OR (petf.element_name      = 'Tax'
                         AND pivf.name          = ('Tax Withholding Rate')))
                  AND   petf.element_type_id   = pivf.element_type_id
                  AND   pivf.legislation_code  = 'ES'
                  AND   prr.assignment_action_id = paa.assignment_action_id
                  AND   paa.source_action_id     IS NOT NULL
                  AND   prr.element_type_id      = petf.element_type_id
                  AND   prv.run_result_id        = prr.run_result_id
                  AND   prv.input_value_id       = pivf.input_value_id
                  AND   prv.result_value         IS NOT NULL
                  AND   peffective_date BETWEEN petf.effective_start_date
                                        AND     petf.effective_end_date
                  AND   peffective_date BETWEEN pivf.effective_start_date
                                        AND     pivf.effective_end_date);

    l_chk varchar2(1);
    --
BEGIN
    OPEN csr_chk_new_emp(passignment_id);
    FETCH csr_chk_new_emp INTO l_chk;
    IF  csr_chk_new_emp%NOTFOUND THEN
        CLOSE csr_chk_new_emp;
        RETURN 'Y';
    END IF;
    CLOSE csr_chk_new_emp;
    --
    RETURN l_chk;
    --
END chk_new_employee;
--
--------------------------------------------------------------------------------
-- get_previous_twr_run_values
--------------------------------------------------------------------------------
FUNCTION get_previous_twr_run_values(passignment_id   IN  NUMBER
                                    ,peffective_date  IN  DATE
                                    ,ptax_base        OUT NOCOPY NUMBER
                                    ,pcont_earnings   OUT NOCOPY NUMBER)
                                    RETURN NUMBER IS
    --
    CURSOR csr_get_run_result_values(c_assignment_action_id NUMBER
                                    ,c_effective_date       DATE
                                    ,c_element_name         VARCHAR2
                                    ,c_input_value_name     VARCHAR2) IS
    SELECT   NVL(prrv.result_value,0) Result_Value
    FROM     pay_run_results prr
            ,pay_run_result_values prrv
            ,pay_element_types_f pet
            ,pay_input_values_f   piv
    where    pet.element_name        = c_element_name
    AND      pet.legislation_code    = 'ES'
    AND      piv.element_type_id     = pet.element_type_id
    AND      piv.name                = c_input_value_name
    AND      pet.element_type_id     = prr.element_type_id
    AND      prr.assignment_action_id= c_assignment_action_id
    AND      prrv.run_result_id      = prr.run_result_id
    AND      piv.input_value_id      = prrv.input_value_id
    AND      c_effective_date        BETWEEN pet.effective_start_date
                                     AND     pet.effective_end_date
    AND      c_effective_date        BETWEEN piv.effective_start_date
                                     AND     piv.effective_end_date;
    --
    CURSOR csr_get_assignment_action(c_assignment_id NUMBER
                                    ,c_effective_date DATE) IS
     SELECT paa.assignment_action_id
     FROM   pay_assignment_actions paa
           ,pay_payroll_actions    ppa
           ,pay_run_results        prr
           ,pay_run_result_values  prv
           ,pay_element_types_f    petf
           ,pay_input_values_f     pivf
     WHERE  paa.assignment_id            = c_assignment_id
     AND    paa.action_status            IN ('C' ,'U')
     AND    ppa.payroll_action_id        = paa.payroll_action_id
     AND    ppa.action_type              IN ('Q' ,'R')
     AND    ppa.effective_date           < c_effective_date
     AND    petf.legislation_code        = 'ES'
     AND    ((petf.element_name = 'TWR Employee Information' AND pivf.name = 'Payment Key')
            OR (petf.element_name = 'Tax'  AND pivf.name = 'Tax Withholding Rate'))
     AND    petf.element_type_id         = pivf.element_type_id
     AND    pivf.legislation_code        = 'ES'
     AND    prr.assignment_action_id     = paa.assignment_action_id
     AND    paa.source_action_id         IS NOT NULL
     AND    prr.element_type_id          = petf.element_type_id
     AND    prv.run_result_id            = prr.run_result_id
     AND    prv.input_value_id           = pivf.input_value_id
     AND    prv.result_value             IS NOT NULL
     AND    c_effective_date             BETWEEN petf.effective_start_date
                                         AND     petf.effective_end_date
     AND    c_effective_date             BETWEEN pivf.effective_start_date
                                         AND     pivf.effective_end_date
     ORDER BY ppa.effective_date DESC;
    --
    l_assignment_action_id pay_assignment_actions.assignment_action_id%TYPE;
    l_result_value pay_run_result_values.result_value%TYPE;
    --
BEGIN
    --
    ptax_base := 0;
    pcont_earnings  := 0;
    --
    OPEN csr_get_assignment_action(passignment_id,peffective_date);
    FETCH csr_get_assignment_action into l_assignment_action_id;
    IF  csr_get_assignment_action%NOTFOUND THEN
        CLOSE csr_get_assignment_action;
        RETURN 0;
    END IF;
    CLOSE csr_get_assignment_action;

    OPEN  csr_get_run_result_values(l_assignment_action_id
                                   ,peffective_date
                                   ,'TWR Deduction Information'
                                   ,'Tax Base');
    FETCH csr_get_run_result_values INTO l_result_value;
    CLOSE csr_get_run_result_values;
    --
    ptax_base := l_result_value;
    --
    OPEN  csr_get_run_result_values(l_assignment_action_id
                                   ,peffective_date
                                   ,'TWR Deduction Information'
                                   ,'Override Contractual Earnings');
    FETCH csr_get_run_result_values INTO l_result_value;
    IF csr_get_run_result_values%NOTFOUND THEN
        OPEN  csr_get_run_result_values(l_assignment_action_id
                                       ,peffective_date
                                       ,'TWR Employee Information'
                                       ,'Contractual Earnings');
        FETCH csr_get_run_result_values INTO l_result_value;
        CLOSE csr_get_run_result_values;
    END IF;
    CLOSE csr_get_run_result_values;
    --
    pcont_earnings := l_result_value;
    --
    RETURN 1;
    --
END get_previous_twr_run_values;
--
--------------------------------------------------------------------------------
-- FETCH_PDF_BLOB
--------------------------------------------------------------------------------
FUNCTION get_name(p_payroll_action_id IN NUMBER
                              ,p_action_type       IN VARCHAR2
                              ,p_effective_date    IN DATE) RETURN VARCHAR2
IS
--
    CURSOR csr_get_emp_name(C_payroll_action_id NUMBER
                           ,c_effective_date    DATE) IS
    SELECT pap.full_name
    FROM   per_all_people_f pap
          ,per_All_assignments_f paaf
          ,pay_assignment_actions paa
    WHERE  paa.payroll_action_id = c_payroll_action_id
    AND    paa.assignment_id     = paaf.assignment_id
    AND    paaf.person_id        = pap.person_id
    AND    paa.source_action_id IS NULL
    AND    c_effective_date BETWEEN pap.effective_start_date
                            AND     pap.effective_end_date
    AND    c_effective_date BETWEEN paaf.effective_start_date
                            AND     paaf.effective_end_date;
--
    l_name per_all_people_f.full_name%TYPE;
BEGIN
    --
    l_name := ' ';
    IF p_action_type = 'Q' THEN
        OPEN  csr_get_emp_name(p_payroll_action_id
                                       ,p_effective_date);
        FETCH csr_get_emp_name INTO l_name;
        IF csr_get_emp_name%NOTFOUND THEN
            l_name := ' ';
        END IF;
        CLOSE csr_get_emp_name;
    END IF;
    --
    RETURN l_name;
END get_name;
--
--------------------------------------------------------------------------------
-- FETCH_PDF_BLOB
--------------------------------------------------------------------------------
PROCEDURE fetch_pdf_blob(p_pdf_blob OUT NOCOPY BLOB) IS
    --
BEGIN
    --
    SELECT file_data INTO p_pdf_blob
    FROM   fnd_lobs
	  WHERE  file_id = (SELECT MAX(file_id) FROM per_gb_xdo_templates
                      WHERE file_name like '%PAY_TWR_e_ES.pdf%');
EXCEPTION
    WHEN no_data_found THEN
  	     NULL;

END fetch_pdf_blob;
--
--------------------------------------------------------------------------------
-- POPULATE_TWR_REPORT
--------------------------------------------------------------------------------
PROCEDURE populate_TWR_Report (p_request_id IN      NUMBER
                              ,p_payroll_action_id  NUMBER
                              ,p_legal_employer     NUMBER
                              ,p_person_id          NUMBER
                              ,p_xfdf_blob          OUT NOCOPY BLOB)IS
    --
    p_xfdf_string clob;
    --
BEGIN
    --
    populate_plsql_table( p_request_id
                         ,p_payroll_action_id
                         ,p_legal_employer
                         ,p_person_id);
    --
    WritetoCLOB (p_xfdf_blob,p_xfdf_string);
    --
END populate_TWR_Report;
--
--------------------------------------------------------------------------------
-- POPULATE_PLSQL_TABLE
--------------------------------------------------------------------------------
PROCEDURE populate_plsql_table
  (p_request_id IN      NUMBER
  ,p_payroll_action_id  NUMBER
  ,p_legal_employer     NUMBER
  ,p_person_id          NUMBER
  )
IS

    CURSOR   csr_get_assignment_ids IS
    SELECT   paa.assignment_id
            ,paa.assignment_action_id
            ,ppa.effective_date
            ,paa.action_status
            ,prtf.shortname
    FROM     pay_payroll_actions ppa
            ,pay_assignment_actions paa
            ,per_all_assignments_f paaf
            ,pay_run_types_f prtf
    WHERE    ppa.payroll_action_id = p_payroll_action_id
    AND      ppa.payroll_action_id = paa.payroll_action_id
    AND      ppa.run_type_id       = prtf.run_type_id
    AND      paaf.assignment_id    = paa.assignment_id
    AND      ((paa.source_action_id IS NULL and paa.action_status = 'E')
             or (paa.source_action_id IS NOT NULL
                 AND exists (select 1
                             FROM   pay_run_results r
                                   ,pay_element_types_f pet
                             WHERE  paa.assignment_action_id = r.assignment_action_id
                             AND    pet.element_type_id    = r.element_type_id
                             AND    pet.legislation_code   = 'ES'
                             AND    pet.element_name in ('Tax Withholding Rate','Tax'))))
    AND      paaf.person_id        = nvl(p_person_id,paaf.person_id)
    AND      ppa.effective_date    BETWEEN paaf.effective_start_date AND paaf.effective_end_date
    AND      ppa.effective_date    BETWEEN prtf.effective_start_date AND prtf.effective_end_date;
    --
    CURSOR  csr_chk_emp_err(c_assignment_action_id number, c_effective_date DATE) IS
    SELECT  'N'
    FROM  PAY_RUN_RESULTs prr
         ,pay_element_types_f pet
    WHERE prr.assignment_action_id = c_assignment_action_id
    AND   prr.element_type_id = pet.element_type_id
    AND   pet.element_name = 'TWR Employee Information'
    AND   c_effective_date    BETWEEN pet.effective_start_date AND pet.effective_end_date;
    --
    CURSOR   csr_get_emp_detail(c_assignment_id number, c_effective_date DATE) IS
    SELECT   pap.full_name name
            ,pap.person_id
            ,paaf.assignment_number
            ,hr_general.decode_lookup('MAR_STATUS',pap.marital_status) marital_status
            ,floor(months_between(c_effective_date,pap.date_of_birth)/12) Age
    FROM     per_all_people_f pap
            ,per_all_assignments_f paaf
    WHERE    pap.person_id = paaf.person_id
    AND      paaf.assignment_id = c_assignment_id
    AND      c_effective_date    BETWEEN pap.effective_start_date AND pap.effective_end_date
    AND      c_effective_date    BETWEEN paaf.effective_start_date AND paaf.effective_end_date;

    CURSOR   csr_get_twr_emp_values(c_assignment_action_id number, c_effective_date DATE) IS
    SELECT   prr.assignment_action_id
            ,prr.run_result_id
            ,min(decode(piv.name, 'Assignment Number', prrv.RESULT_VALUE , null)) Assignment_Number
            ,min(decode(piv.name, 'Name', prrv.RESULT_VALUE , null)) Name
            ,min(decode(piv.name, 'Age', prrv.RESULT_VALUE , null)) Age
            ,min(decode(piv.name, 'Payment Key',prrv.RESULT_VALUE||' - '||hr_general.decode_lookup('ES_PAYMENT_KEY',prrv.RESULT_VALUE), null)) Payment_Key
            ,min(decode(piv.name, 'Length of Contract', prrv.RESULT_VALUE , null)) Length_Of_Contract
            ,min(decode(piv.name, 'Change in Residency', hr_general.decode_lookup('YES_NO',prrv.RESULT_VALUE), null)) Change_in_Residency
            ,min(decode(piv.name, 'Contract Type', prrv.RESULT_VALUE, null)) Contract_Type
            ,min(decode(piv.name, 'Degree of Disability', prrv.RESULT_VALUE , null)) Emp_DOD
            ,min(decode(piv.name, 'Disabled', hr_general.decode_lookup('YES_NO',prrv.RESULT_VALUE), null)) Disabled
            ,min(decode(piv.name, 'Marital Status', hr_general.decode_lookup('MAR_STATUS',prrv.RESULT_VALUE), null)) Marital_Status
            ,min(decode(piv.name, 'Work Status', substr(prrv.RESULT_VALUE||' - '||hr_general.decode_lookup('ES_WORKER_STATUS',prrv.RESULT_VALUE),1,10) , null)) Work_Status
            ,min(decode(piv.name, 'Location Benefit', hr_general.decode_lookup('YES_NO',prrv.RESULT_VALUE), null)) Resident_Ceuta_Melila
            ,min(decode(piv.name, 'Contractual Earnings', prrv.RESULT_VALUE , null)) Calc_Cont_Earnings
            ,min(decode(piv.name, 'America Cup', hr_general.decode_lookup('YES_NO',prrv.RESULT_VALUE), null)) America_Cup_Flag
    FROM     pay_run_results prr
            ,pay_run_result_values prrv
            ,pay_element_types_f pet
            ,pay_input_values_f   piv
    WHERE    pet.element_name        = 'TWR Employee Information'
    AND      pet.legislation_code    = 'ES'
    AND      piv.element_type_id     =pet.element_type_id
    AND      pet.element_type_id     = prr.element_type_id
    AND      prr.assignment_action_id= c_assignment_action_id
    AND      prrv.run_result_id      = prr.run_result_id
    AND      piv.input_value_id      = prrv.input_value_id
    AND      c_effective_date        BETWEEN pet.effective_start_date AND pet.effective_end_date
    AND      c_effective_date        BETWEEN piv.effective_start_date AND piv.effective_end_date
    group    BY prr.assignment_action_id , prr.run_result_id;
    --
    CURSOR csr_get_twr_asc_values(c_assignment_action_id number, c_effective_date DATE)IS
    SELECT   prr.assignment_action_id
            ,prr.run_result_id
            ,min(decode(piv.name, 'Number of Ascendants', prrv.RESULT_VALUE, null)) No_of_Asc
            ,min(decode(piv.name, 'Ascendants Greater than 75', prrv.RESULT_VALUE, null)) No_of_Asc_Gr_75
            ,min(decode(piv.name, 'Disability between 33 and 64', prrv.RESULT_VALUE, null)) No_Asc_disablity_bet_33_65
            ,min(decode(piv.name, 'Disability greater than 64', prrv.RESULT_VALUE, null)) No_Asc_disablity_gr_65
            ,min(decode(piv.name, 'Single Descendant', prrv.RESULT_VALUE, null)) No_Asc_Single_Descendent
            ,min(decode(piv.name, 'Reduced Mobility', prrv.RESULT_VALUE, null)) No_Asc_Reduced_Mobility
            ,min(decode(piv.name, 'Disability Amount', prrv.RESULT_VALUE, null)) Asc_Disability_Amt
            ,min(decode(piv.name, 'Special Assistance', prrv.RESULT_VALUE, null)) Asc_Special_Assistance
            ,min(decode(piv.name, 'Special Allowance', prrv.RESULT_VALUE, null)) Asc_Special_Allowance
            ,min(decode(piv.name, 'Age Deduction', prrv.RESULT_VALUE, null)) Asc_Age_Deduction
    FROM    pay_run_results prr
            ,pay_run_result_values prrv
            ,pay_element_types_f pet
            ,pay_input_values_f   piv
    WHERE    pet.element_name        = 'TWR Employee Ascendants Information'
    AND      pet.legislation_code    = 'ES'
    AND      piv.element_type_id     =pet.element_type_id
    AND      pet.element_type_id     = prr.element_type_id
    AND      prr.assignment_action_id= c_assignment_action_id
    AND      prrv.run_result_id      = prr.run_result_id
    AND      piv.input_value_id      = prrv.input_value_id
    AND      c_effective_date        BETWEEN pet.effective_start_date AND pet.effective_end_date
    AND      c_effective_date        BETWEEN piv.effective_start_date AND piv.effective_end_date
    group    BY prr.assignment_action_id , prr.run_result_id;
    --
    CURSOR csr_get_twr_desc_values(c_assignment_action_id number, c_effective_date DATE)IS
    SELECT   prr.assignment_action_id
            ,prr.run_result_id
            ,min(decode(piv.name, 'Number of Descendants', prrv.RESULT_VALUE, null)) No_of_Desc
            ,min(decode(piv.name, 'Age less than 3', prrv.RESULT_VALUE, null)) No_of_Desc_less_3
            ,min(decode(piv.name, 'Age between 3 and 25', prrv.RESULT_VALUE, null)) No_Desc_bet_3_25
            ,min(decode(piv.name, 'Disability between 33 and 64', prrv.RESULT_VALUE, null)) No_Desc_disablity_bet_33_65
            ,min(decode(piv.name, 'Disability greater than 64', prrv.RESULT_VALUE, null)) No_Desc_disablity_gr_65
            ,min(decode(piv.name, 'Reduced Mobility', prrv.RESULT_VALUE, null)) No_Desc_Reduced_Mobility
            ,min(decode(piv.name, 'Single Parent', prrv.RESULT_VALUE, null)) No_Desc_Single_Parent
            ,min(decode(piv.name, 'Adopted less than 3 years ago', prrv.RESULT_VALUE, null)) No_Desc_Adopted_less_3
            ,min(decode(piv.name, 'Special Assistance', prrv.RESULT_VALUE, null)) Desc_Disability_Amt
            ,min(decode(piv.name, 'Disability Amount', prrv.RESULT_VALUE, null)) Desc_Special_Assistance
    FROM    pay_run_results prr
            ,pay_run_result_values prrv
            ,pay_element_types_f pet
            ,pay_input_values_f   piv
    WHERE    pet.element_name        = 'TWR Employee Descendants Information'
    AND      pet.legislation_code    = 'ES'
    AND      piv.element_type_id     =pet.element_type_id
    AND      pet.element_type_id     = prr.element_type_id
    AND      prr.assignment_action_id= c_assignment_action_id
    AND      prrv.run_result_id      = prr.run_result_id
    AND      piv.input_value_id      = prrv.input_value_id
    AND      c_effective_date        BETWEEN pet.effective_start_date AND pet.effective_end_date
    AND      c_effective_date        BETWEEN piv.effective_start_date AND piv.effective_end_date
    group    BY prr.assignment_action_id , prr.run_result_id;
    --
    CURSOR csr_get_twr_amount_values(c_assignment_action_id number, c_effective_date DATE)IS
    SELECT   prr.assignment_action_id
            ,prr.run_result_id
            ,min(decode(piv.name, 'Employee Special Assistance', prrv.RESULT_VALUE, null)) Emp_Special_Assistance
            ,min(decode(piv.name, 'Employee Disability Assistance', prrv.RESULT_VALUE, null)) Emp_Disability_Assistance
            ,min(decode(piv.name, 'Employee Special Allowance', prrv.RESULT_VALUE, null)) Employee_Special_Allowance
            ,min(decode(piv.name, 'Employee Age Deduction', prrv.RESULT_VALUE, null)) Emp_Age_Deduction
            ,min(decode(piv.name, 'Child Support', prrv.RESULT_VALUE, null)) Child_Support
            ,min(decode(piv.name, 'Deductible Expenses', prrv.RESULT_VALUE, null)) Deductible_Expences
            ,min(decode(piv.name, 'Irregular Earnings', prrv.RESULT_VALUE, null)) Irregular_Earnings
            ,min(decode(piv.name, 'Spouse Alimony', prrv.RESULT_VALUE, null)) Spouse_Alimony
            ,min(decode(piv.name, 'Tax Base', prrv.RESULT_VALUE, null)) Tax_Base
            ,min(decode(piv.name, 'Override Tax Rate', prrv.RESULT_VALUE, null)) Override_TWR
            ,min(decode(piv.name, 'Override Contractual Earnings', prrv.RESULT_VALUE, null)) Override_Cont_Earnings
    FROM    pay_run_results prr
            ,pay_run_result_values prrv
            ,pay_element_types_f pet
            ,pay_input_values_f   piv
    WHERE    pet.element_name        = 'TWR Deduction Information'
    AND      pet.legislation_code    = 'ES'
    AND      piv.element_type_id     =pet.element_type_id
    AND      pet.element_type_id     = prr.element_type_id
    AND      prr.assignment_action_id= c_assignment_action_id
    AND      prrv.run_result_id      = prr.run_result_id
    AND      piv.input_value_id      = prrv.input_value_id
    AND      c_effective_date        BETWEEN pet.effective_start_date AND pet.effective_end_date
    AND      c_effective_date        BETWEEN piv.effective_start_date AND piv.effective_end_date
    group    BY prr.assignment_action_id , prr.run_result_id;
    --
    CURSOR csr_get_twr_rate(c_assignment_action_id number, c_effective_date DATE)IS
    SELECT   prr.assignment_action_id
            ,prr.run_result_id
            ,min(decode(piv.name, 'Rate', prrv.RESULT_VALUE, null)) Rate
    FROM    pay_run_results prr
            ,pay_run_result_values prrv
            ,pay_element_types_f pet
            ,pay_input_values_f   piv
    WHERE    pet.element_name        = 'Tax Withholding Rate'
    AND      pet.legislation_code    = 'ES'
    AND      piv.element_type_id     =pet.element_type_id
    AND      pet.element_type_id     = prr.element_type_id
    AND      prr.assignment_action_id= c_assignment_action_id
    AND      prrv.run_result_id      = prr.run_result_id
    AND      piv.input_value_id      = prrv.input_value_id
    AND      c_effective_date        BETWEEN pet.effective_start_date AND pet.effective_end_date
    AND      c_effective_date        BETWEEN piv.effective_start_date AND piv.effective_end_date
    GROUP    BY prr.assignment_action_id , prr.run_result_id;
    --
    CURSOR csr_get_tax_rate(c_assignment_action_id number, c_effective_date DATE)IS
    SELECT   prr.assignment_action_id
            ,prr.run_result_id
            ,min(decode(piv.name, 'Tax Withholding Rate', prrv.RESULT_VALUE, null)) Rate
    FROM    pay_run_results prr
            ,pay_run_result_values prrv
            ,pay_element_types_f pet
            ,pay_input_values_f   piv
    WHERE    pet.element_name        = 'Tax'
    AND      pet.legislation_code    = 'ES'
    AND      piv.element_type_id     =pet.element_type_id
    AND      pet.element_type_id     = prr.element_type_id
    AND      prr.assignment_action_id= c_assignment_action_id
    AND      prrv.run_result_id      = prr.run_result_id
    AND      piv.input_value_id      = prrv.input_value_id
    AND      c_effective_date        BETWEEN pet.effective_start_date AND pet.effective_end_date
    AND      c_effective_date        BETWEEN piv.effective_start_date AND piv.effective_end_date
    GROUP    BY prr.assignment_action_id , prr.run_result_id;
    --
    CURSOR  csr_get_message(c_assignment_action_id NUMBER) IS
    SELECT  line_text  Msg
    FROM    pay_message_lines
    WHERE   source_id  = c_assignment_action_id
    ORDER BY line_sequence DESC;
    --
    l_emp_rec csr_get_twr_emp_values%ROWTYPE;
    l_asc_rec csr_get_twr_asc_values%ROWTYPE;
    l_desc_rec csr_get_twr_desc_values%ROWTYPE;
    l_amt_rec csr_get_twr_amount_values%ROWTYPE;
    l_twr_rec csr_get_twr_rate%ROWTYPE;
    --l_otwr_rec csr_get_twr_override_values%ROWTYPE;
    l_emp_detail_rec csr_get_emp_detail%ROWTYPE;
    l_msg_rec csr_get_message%ROWTYPE;
    l_chk_emp_err VARCHAR2(1);
    l_no NUMBER;
    l_header VARCHAR2(255);
    l_underline VARCHAR2(255);
    l_print_emp_info VARCHAR2(255);
    l_working_past_retirement VARCHAR2(10);
    l_twr_rate NUMBER;
    l_total_earnings NUMBER;
    --
BEGIN
    vXMLTable.DELETE;
    vCtr := 1;
    hr_utility.trace(' Entering procedure pay_es_twr_calc_pkg.populate_plsql_table ');
    l_no := 0;
    l_header :=   /*rpad(hr_general.decode_lookup('ES_FORM_LABELS','ERR_MSG'),4)||'  '||*/
                      rpad(hr_general.decode_lookup('ES_FORM_LABELS','ANO'),10)||'  '||
                      rpad(hr_general.decode_lookup('ES_FORM_LABELS','ENAME'),30)||'  '||
                      rpad(hr_general.decode_lookup('ES_FORM_LABELS','ERR_MSG'),200);
        --
    l_underline :=--rpad('-',04,'-')||'  '||
                      rpad('-',10,'-')||'  '||
                      rpad('-',30,'-')||'  '||
                      rpad('-',200,'-')||'  ';


    FOR i IN csr_get_assignment_ids LOOP
        hr_utility.trace(' Assignment id :' || i.assignment_id);
        hr_utility.trace(' i.effective_date:' || i.effective_date);

        l_msg_rec.Msg := ' ';

        OPEN  csr_chk_emp_err(i.assignment_action_id, i.effective_date);
        FETCH csr_chk_emp_err into l_chk_emp_err;
        IF csr_chk_emp_err%notfound then
            l_chk_emp_err := 'Y';
        END IF;
        CLOSE csr_chk_emp_err;

        hr_utility.trace(' l_chk_emp_err :' || l_chk_emp_err);
        IF l_chk_emp_err = 'Y' THEN
            IF l_no = 0 THEN
                Fnd_File.New_Line(FND_FILE.LOG,1);
                Fnd_file.put_line(FND_FILE.LOG,hr_general.decode_lookup('ES_FORM_LABELS','EXCEPTION_LIST'));
                Fnd_file.put_line(FND_FILE.LOG,rpad('-',length(hr_general.decode_lookup('ES_FORM_LABELS','EXCEPTION_LIST')),'-'));
                Fnd_File.New_Line(FND_FILE.LOG,1);
                Fnd_file.put_line(FND_FILE.LOG,l_underline);
                Fnd_file.put_line(FND_FILE.LOG,l_header);
                Fnd_file.put_line(FND_FILE.LOG,l_underline);
            END IF;
            l_no := l_no + 1;

            vXMLTable(vCtr).TagName := 'TWR_EFFECTIVE_DATE';
            vXMLTable(vCtr).TagValue := fnd_date.date_to_displaydate(i.effective_date);
            vCtr := vCtr + 1;

            OPEN  csr_get_emp_detail(i.assignment_id, i.effective_date);
            FETCH csr_get_emp_detail INTO l_emp_detail_rec;
            CLOSE csr_get_emp_detail;

            vXMLTable(vCtr).TagName := 'TWR_ASSIGNMENT_NO';
            vXMLTable(vCtr).TagValue := l_emp_detail_rec.Assignment_Number;
            vCtr := vCtr + 1;

            vXMLTable(vCtr).TagName := 'TWR_EMP_NAME';
            vXMLTable(vCtr).TagValue := l_emp_detail_rec.Name;
            vCtr := vCtr + 1;

            vXMLTable(vCtr).TagName := 'TWR_AGE';
            vXMLTable(vCtr).TagValue := l_emp_detail_rec.Age;
            vCtr := vCtr + 1;

            vXMLTable(vCtr).TagName := 'TWR_PAYMENT_KEY';
            vXMLTable(vCtr).TagValue := get_payment_key(i.assignment_id,i.effective_date);
            vCtr := vCtr + 1;

            vXMLTable(vCtr).TagName := 'TWR_MARITAL_STATUS';
            vXMLTable(vCtr).TagValue := l_emp_detail_rec.Marital_Status;
            vCtr := vCtr + 1;


            OPEN  csr_get_message(i.assignment_action_id);
            FETCH csr_get_message into l_msg_rec;
            CLOSE csr_get_message;

            vXMLTable(vCtr).TagName := 'TWR_ERR_MSG1';
            vXMLTable(vCtr).TagValue := l_msg_rec.Msg;
            vCtr := vCtr + 1;
            l_no := l_no + 1;
            l_print_emp_info:=  --rpad((to_char(l_no),' '),4)||'  '||
                     			rpad(nvl(substr(l_emp_detail_rec.Assignment_Number,1,10),' '),10)||'  '||
                                rpad(nvl(substr(l_emp_detail_rec.Name,1,30),' '),30)||'  '||
                                rpad(nvl(substr(l_msg_rec.Msg,1,200),' '),200);

            Fnd_file.put_line(FND_FILE.LOG,l_print_emp_info);

        ELSE
            OPEN csr_get_twr_emp_values(i.assignment_action_id, i.effective_date);
            FETCH csr_get_twr_emp_values into l_emp_rec;
            CLOSE csr_get_twr_emp_values;

            OPEN csr_get_twr_asc_values(i.assignment_action_id, i.effective_date);
            FETCH csr_get_twr_asc_values into l_asc_rec;
            CLOSE csr_get_twr_asc_values;

            OPEN csr_get_twr_desc_values(i.assignment_action_id, i.effective_date);
            FETCH csr_get_twr_desc_values into l_desc_rec;
            CLOSE csr_get_twr_desc_values;

            OPEN csr_get_twr_amount_values(i.assignment_action_id, i.effective_date);
            FETCH csr_get_twr_amount_values into l_amt_rec;
            CLOSE csr_get_twr_amount_values;

            IF i.shortname = 'TAX_WITHHOLDING_RATE' THEN
                OPEN csr_get_twr_rate(i.assignment_action_id, i.effective_date);
                FETCH csr_get_twr_rate into l_twr_rec;
                CLOSE csr_get_twr_rate;
            ELSE
                OPEN csr_get_tax_rate(i.assignment_action_id, i.effective_date);
                FETCH csr_get_tax_rate into l_twr_rec;
                CLOSE csr_get_tax_rate;
            END IF;

            /*OPEN csr_get_twr_override_values(i.assignment_id, i.effective_date);
            FETCH csr_get_twr_override_values into l_otwr_rec;
            CLOSE csr_get_twr_override_values;*/

            vXMLTable(vCtr).TagName := 'TWR_EFFECTIVE_DATE';
            vXMLTable(vCtr).TagValue := fnd_date.date_to_displaydate(i.effective_date);
            vCtr := vCtr + 1;

            vXMLTable(vCtr).TagName := 'TWR_ASSIGNMENT_NO';
            vXMLTable(vCtr).TagValue := l_emp_rec.Assignment_Number;
            vCtr := vCtr + 1;

            vXMLTable(vCtr).TagName := 'TWR_EMP_NAME';
            vXMLTable(vCtr).TagValue := l_emp_rec.Name;
            vCtr := vCtr + 1;

            vXMLTable(vCtr).TagName := 'TWR_AGE';
            vXMLTable(vCtr).TagValue := l_emp_rec.Age;
            vCtr := vCtr + 1;

            vXMLTable(vCtr).TagName := 'TWR_PAYMENT_KEY';
            vXMLTable(vCtr).TagValue := l_emp_rec.Payment_Key;
            vCtr := vCtr + 1;

            vXMLTable(vCtr).TagName := 'TWR_LENGTH_OF_CONTRACT';
            vXMLTable(vCtr).TagValue := fnd_number.canonical_to_number(l_emp_rec.Length_Of_Contract);
            vCtr := vCtr + 1;

            vXMLTable(vCtr).TagName := 'TWR_EMP_MOVED';
            vXMLTable(vCtr).TagValue := l_emp_rec.Change_in_Residency;
            vCtr := vCtr + 1;

            vXMLTable(vCtr).TagName := 'TWR_CONTRACT_TYPE';
            vXMLTable(vCtr).TagValue := l_emp_rec.Contract_Type;
            vCtr := vCtr + 1;

            vXMLTable(vCtr).TagName := 'TWR_EMPLOYEE_DOD';
            vXMLTable(vCtr).TagValue := l_emp_rec.Emp_DOD;
            vCtr := vCtr + 1;

            vXMLTable(vCtr).TagName := 'TWR_EMP_DISABLED';
            vXMLTable(vCtr).TagValue := l_emp_rec.Disabled;
            vCtr := vCtr + 1;

            l_working_past_retirement := ' ';
            IF SUBSTR(l_emp_rec.Payment_Key,1,1) NOT IN ('E', 'F') THEN
                IF l_emp_rec.Age >= 75 THEN
                    l_working_past_retirement := hr_general.decode_lookup('YES_NO','Y');
                ELSE
                    l_working_past_retirement := hr_general.decode_lookup('YES_NO','N');
                END IF;
            END IF;

            vXMLTable(vCtr).TagName := 'TWR_WORK_PAST_RETIREMENT';
            vXMLTable(vCtr).TagValue := l_working_past_retirement;
            vCtr := vCtr + 1;

            vXMLTable(vCtr).TagName := 'TWR_MARITAL_STATUS';
            vXMLTable(vCtr).TagValue := l_emp_rec.Marital_Status;
            vCtr := vCtr + 1;

            vXMLTable(vCtr).TagName := 'TWR_AMERICA_CUP_FLAG';
            vXMLTable(vCtr).TagValue := l_emp_rec.America_Cup_Flag;
            vCtr := vCtr + 1;

            vXMLTable(vCtr).TagName := 'TWR_WORK_STATUS';
            vXMLTable(vCtr).TagValue := l_emp_rec.Work_Status;
            vCtr := vCtr + 1;

            vXMLTable(vCtr).TagName := 'TWR_RESIDENT_C_M';
            vXMLTable(vCtr).TagValue := l_emp_rec.Resident_Ceuta_Melila;
            vCtr := vCtr + 1;

            IF l_amt_rec.Override_Cont_Earnings IS NOT NULL THEN
                l_total_earnings := NULL;
            ELSE
                l_total_earnings := l_emp_rec.Calc_Cont_Earnings;
            END IF;
            vXMLTable(vCtr).TagName := 'TWR_TOTAL_EARNINGS';
            vXMLTable(vCtr).TagValue := fnd_number.canonical_to_number(l_total_earnings);
            vCtr := vCtr + 1;

            vXMLTable(vCtr).TagName := 'TWR_CALC_CONT_EARNINGS';
            vXMLTable(vCtr).TagValue := fnd_number.canonical_to_number(l_emp_rec.Calc_Cont_Earnings);
            vCtr := vCtr + 1;

            vXMLTable(vCtr).TagName := 'TWR_NO_OF_DESC';
            vXMLTable(vCtr).TagValue := fnd_number.canonical_to_number(l_desc_rec.No_of_Desc);
            vCtr := vCtr + 1;

            vXMLTable(vCtr).TagName := 'TWR_NO_OF_DESC_LESS_3';
            vXMLTable(vCtr).TagValue := fnd_number.canonical_to_number(l_desc_rec.No_of_Desc_less_3);
            vCtr := vCtr + 1;

            vXMLTable(vCtr).TagName := 'TWR_NO_OF_DESC_BET_3_25';
            vXMLTable(vCtr).TagValue := fnd_number.canonical_to_number(l_desc_rec.No_Desc_bet_3_25);
            vCtr := vCtr + 1;

            vXMLTable(vCtr).TagName := 'TWR_NO_OF_DESC_ADOPT_LESS_3';
            vXMLTable(vCtr).TagValue := fnd_number.canonical_to_number(l_desc_rec.No_Desc_Adopted_less_3);
            vCtr := vCtr + 1;

            vXMLTable(vCtr).TagName := 'TWR_DESC_DISABILITY_BET_33_65';
            vXMLTable(vCtr).TagValue := fnd_number.canonical_to_number(l_desc_rec.No_Desc_disablity_bet_33_65);
            vCtr := vCtr + 1;

            vXMLTable(vCtr).TagName := 'TWR_DESC_DISABILITY_GR_65';
            vXMLTable(vCtr).TagValue := fnd_number.canonical_to_number(l_desc_rec.No_Desc_disablity_gr_65);
            vCtr := vCtr + 1;

            vXMLTable(vCtr).TagName := 'TWR_DESC_REDUCED_MOBILITY';
            vXMLTable(vCtr).TagValue := fnd_number.canonical_to_number(l_desc_rec.No_Desc_Reduced_Mobility);
            vCtr := vCtr + 1;

            vXMLTable(vCtr).TagName := 'TWR_DESC_SINGLE_PARENT';
            vXMLTable(vCtr).TagValue := fnd_number.canonical_to_number(l_desc_rec.No_Desc_Single_Parent);
            vCtr := vCtr + 1;

            vXMLTable(vCtr).TagName := 'TWR_DESC_DISABILITY_AMT';
            vXMLTable(vCtr).TagValue := fnd_number.canonical_to_number(l_desc_rec.Desc_Disability_Amt);
            vCtr := vCtr + 1;

            vXMLTable(vCtr).TagName := 'TWR_DESC_SPL_ASSISTANCE_AMT';
            vXMLTable(vCtr).TagValue := fnd_number.canonical_to_number(l_desc_rec.DESC_SPECIAL_ASSISTANCE);
            vCtr := vCtr + 1;

            vXMLTable(vCtr).TagName := 'TWR_NO_OF_ASC';
            vXMLTable(vCtr).TagValue := fnd_number.canonical_to_number(l_asc_rec.NO_OF_ASC);
            vCtr := vCtr + 1;

            vXMLTable(vCtr).TagName := 'TWR_NO_OF_ASC_GR_75';
            vXMLTable(vCtr).TagValue := fnd_number.canonical_to_number(l_asc_rec.No_of_Asc_Gr_75);
            vCtr := vCtr + 1;

            vXMLTable(vCtr).TagName := 'TWR_ASC_DISABILITY_BET_33_65';
            vXMLTable(vCtr).TagValue := fnd_number.canonical_to_number(l_asc_rec.No_Asc_disablity_bet_33_65);
            vCtr := vCtr + 1;

            vXMLTable(vCtr).TagName := 'TWR_ASC_DISABILITY_GR_65';
            vXMLTable(vCtr).TagValue := fnd_number.canonical_to_number(l_asc_rec.No_Asc_disablity_gr_65);
            vCtr := vCtr + 1;

            vXMLTable(vCtr).TagName := 'TWR_ASC_REDUCED_MOBILITY';
            vXMLTable(vCtr).TagValue := fnd_number.canonical_to_number(l_asc_rec.No_Asc_Reduced_Mobility);
            vCtr := vCtr + 1;

            vXMLTable(vCtr).TagName := 'TWR_ASC_SNGLE_DESC';
            vXMLTable(vCtr).TagValue := fnd_number.canonical_to_number(l_asc_rec.No_Asc_Single_Descendent);
            vCtr := vCtr + 1;

            vXMLTable(vCtr).TagName := 'TWR_ASC_DISABILITY_AMT';
            vXMLTable(vCtr).TagValue := fnd_number.canonical_to_number(l_asc_rec.Asc_Disability_Amt);
            vCtr := vCtr + 1;

            vXMLTable(vCtr).TagName := 'TWR_ASC_SPECIAL_ALLOWANCE';
            vXMLTable(vCtr).TagValue := fnd_number.canonical_to_number(l_asc_rec.Asc_Special_Allowance);
            vCtr := vCtr + 1;

            vXMLTable(vCtr).TagName := 'TWR_ASC_AGE_DEDUCTION';
            vXMLTable(vCtr).TagValue := fnd_number.canonical_to_number(l_asc_rec.Asc_Age_Deduction);
            vCtr := vCtr + 1;

            vXMLTable(vCtr).TagName := 'TWR_ASC_SPL_ASSISTANCE_AMT';
            vXMLTable(vCtr).TagValue := fnd_number.canonical_to_number(l_asc_rec.Asc_Special_Assistance);
            vCtr := vCtr + 1;

            vXMLTable(vCtr).TagName := 'TWR_EMP_SPECIAL_ASSISTANCE';
            vXMLTable(vCtr).TagValue := fnd_number.canonical_to_number(l_amt_rec.Emp_Special_Assistance);
            vCtr := vCtr + 1;

            vXMLTable(vCtr).TagName := 'TWR_EMP_DISABILITY_ASSISTANCE';
            vXMLTable(vCtr).TagValue := fnd_number.canonical_to_number(l_amt_rec.Emp_Disability_Assistance);
            vCtr := vCtr + 1;

            vXMLTable(vCtr).TagName := 'TWR_EMPLOYEE_SPECIAL_ALLOWANCE';
            vXMLTable(vCtr).TagValue := fnd_number.canonical_to_number(l_amt_rec.Employee_Special_Allowance);
            vCtr := vCtr + 1;

            vXMLTable(vCtr).TagName := 'TWR_EMP_AGE_DEDUCTION';
            vXMLTable(vCtr).TagValue := fnd_number.canonical_to_number(l_amt_rec.Emp_Age_Deduction);
            vCtr := vCtr + 1;

            vXMLTable(vCtr).TagName := 'TWR_SPOUSE_ALIMONY';
            vXMLTable(vCtr).TagValue := fnd_number.canonical_to_number(l_amt_rec.Spouse_Alimony);
            vCtr := vCtr + 1;

            vXMLTable(vCtr).TagName := 'TWR_CHILD_SUPPORT';
            vXMLTable(vCtr).TagValue := fnd_number.canonical_to_number(l_amt_rec.Child_Support);
            vCtr := vCtr + 1;

            vXMLTable(vCtr).TagName := 'TWR_DEDUCTIBLE_EXPENSES';
            vXMLTable(vCtr).TagValue := fnd_number.canonical_to_number(l_amt_rec.Deductible_Expences);
            vCtr := vCtr + 1;

            vXMLTable(vCtr).TagName := 'TWR_IRREGULAR_EARNINGS';
            vXMLTable(vCtr).TagValue := fnd_number.canonical_to_number(l_amt_rec.Irregular_Earnings);
            vCtr := vCtr + 1;

            vXMLTable(vCtr).TagName := 'TWR_TAX_BASE';
            vXMLTable(vCtr).TagValue := fnd_number.canonical_to_number(l_amt_rec.Tax_Base);
            vCtr := vCtr + 1;

            vXMLTable(vCtr).TagName := 'TWR_OVERRIDE_RATE';
            vXMLTable(vCtr).TagValue := fnd_number.canonical_to_number(l_amt_rec.Override_TWR);
            vCtr := vCtr + 1;

            vXMLTable(vCtr).TagName := 'TWR_OVERRIDE_CONT_EARNINGS';
            vXMLTable(vCtr).TagValue := fnd_number.canonical_to_number(l_amt_rec.Override_Cont_Earnings);
            vCtr := vCtr + 1;

            IF l_amt_rec.Override_TWR IS NOT NULL THEN
                l_twr_rate := NULL;
            ELSE
                l_twr_rate := l_twr_rec.Rate;
            END IF;

            vXMLTable(vCtr).TagName := 'TWR_RATE';
            vXMLTable(vCtr).TagValue := fnd_number.canonical_to_number(l_twr_rate);
            vCtr := vCtr + 1;
        END IF;
    --
    END LOOP;
    hr_utility.trace(' Leaving procedure pay_es_twr_calc_pkg.populate_plsql_table ');
END populate_plsql_table ;
--
-------------------------------------------------------------------------------
-- WRITETOCLOB
--------------------------------------------------------------------------------
PROCEDURE WritetoCLOB (p_xfdf_blob OUT NOCOPY blob
                      ,p_xfdf_string OUT NOCOPY clob)
IS
  l_str1 varchar2(1000);
  l_str2 varchar2(20);
  l_str3 varchar2(20);
  l_str4 varchar2(20);
  l_str5 varchar2(20);
  l_str6 varchar2(30);
  l_str7 varchar2(1000);
  l_str8 varchar2(240);
  l_str9 varchar2(240);
BEGIN
	l_str1 := '<?xml version="1.0" encoding="UTF-8"?>
	       		 <xfdf xmlns="http://ns.adobe.com/xfdf/" xml:space="preserve">
       			 <fields> ' ;
	l_str2 := '<field name="';
	l_str3 := '">';
	l_str4 := '<value><![CDATA[';
    l_str5 := ']]></value> </field>' ;
	l_str6 := '</fields> </xfdf>';
	l_str7 := '<?xml version="1.0" encoding="UTF-8"?>
		       		 <xfdf xmlns="http://ns.adobe.com/xfdf/" xml:space="preserve">
       			 <fields>
       			 </fields> </xfdf>';
	dbms_lob.createtemporary(p_xfdf_string,FALSE,DBMS_LOB.CALL);
	dbms_lob.open(p_xfdf_string,dbms_lob.lob_readwrite);
	IF vXMLTable.count > 0 THEN
    dbms_lob.writeAppend( p_xfdf_string, length(l_str1), l_str1 );
   	FOR ctr_table IN vXMLTable.FIRST .. vXMLTable.LAST LOOP
   		l_str8 := vXMLTable(ctr_table).TagName;
   		l_str9 := vXMLTable(ctr_table).TagValue;
      --
   		IF (l_str9 is not null) THEN
        dbms_lob.writeAppend( p_xfdf_string, length(l_str2), l_str2 );
				dbms_lob.writeAppend( p_xfdf_string, length(l_str8),l_str8);
				dbms_lob.writeAppend( p_xfdf_string, length(l_str3), l_str3 );
				dbms_lob.writeAppend( p_xfdf_string, length(l_str4), l_str4 );
				dbms_lob.writeAppend( p_xfdf_string, length(l_str9), l_str9);
				dbms_lob.writeAppend( p_xfdf_string, length(l_str5), l_str5 );
			ELSE
  			null;
			END IF;
		END LOOP;
		dbms_lob.writeAppend( p_xfdf_string, length(l_str6), l_str6 );
	ELSE
		dbms_lob.writeAppend( p_xfdf_string, length(l_str7), l_str7 );
  END IF;
	DBMS_LOB.CREATETEMPORARY(p_xfdf_blob,TRUE);
	clob_to_blob(p_xfdf_string,p_xfdf_blob);
	--return p_xfdf_blob;
	EXCEPTION
		WHEN OTHERS then
	    HR_UTILITY.TRACE('sqleerm ' || SQLERRM);
	    HR_UTILITY.RAISE_ERROR;
END WritetoCLOB;
--------------------------------------------------------------------------------
-- CLOB_TO_BLOB
--------------------------------------------------------------------------------
PROCEDURE  clob_to_blob(p_clob CLOB
                       ,p_blob IN OUT NOCOPY BLOB) IS
    --
    l_length_clob NUMBER;
    l_offset pls_integer;
    l_varchar_buffer VARCHAR2(32767);
    l_raw_buffer RAW(32767);
    l_buffer_len NUMBER;
    l_chunk_len  NUMBER;
    l_blob blob;
    g_nls_db_char VARCHAR2(60);
    --
    l_raw_buffer_len pls_integer;
    l_blob_offset pls_integer := 1;
    --
BEGIN
    --
    hr_utility.set_location('Entered Procedure clob to blob',120);
    --
    SELECT userenv('LANGUAGE') INTO g_nls_db_char FROM dual;
    --
    l_buffer_len :=  20000;
    l_length_clob := dbms_lob.getlength(p_clob);
    l_offset := 1;
    --
    while l_length_clob > 0 loop
        --
        IF l_length_clob < l_buffer_len THEN
            l_chunk_len := l_length_clob;
        ELSE
            l_chunk_len := l_buffer_len;
        END IF;
        --
        DBMS_LOB.READ(p_clob,l_chunk_len,l_offset,l_varchar_buffer);
        --
        l_raw_buffer := utl_raw.convert(utl_raw.cast_to_raw(l_varchar_buffer),'American_America.AL32UTF8',g_nls_db_char);
        l_raw_buffer_len := utl_raw.length(utl_raw.convert(utl_raw.cast_to_raw(l_varchar_buffer),'American_America.AL32UTF8',g_nls_db_char));
        dbms_lob.write(p_blob,l_raw_buffer_len, l_blob_offset, l_raw_buffer);
        --
        l_blob_offset := l_blob_offset + l_raw_buffer_len;
        l_offset := l_offset + l_chunk_len;
        l_length_clob := l_length_clob - l_chunk_len;
        --
    END LOOP;
    hr_utility.set_location('Finished Procedure clob to blob ',130);
END;
--
--------------------------------------------------------------------------------
-- GET_CONTRACTUAL_EARNINGS
--------------------------------------------------------------------------------
FUNCTION get_contractual_earnings(p_assignment_id    IN NUMBER
                                 ,p_calculation_date IN DATE
                                 ,p_name             IN VARCHAR2
                                 ,p_rt_element       IN VARCHAR2
                                 ,p_to_time_dim      IN VARCHAR2
                                 ,p_rate             IN OUT NOCOPY NUMBER
                                 ,p_error_message    IN OUT NOCOPY VARCHAR2) RETURN NUMBER
IS
--
    CURSOR csr_get_work_center(c_assignment_id  NUMBER
                              ,c_effective_date DATE) IS
    SELECT scl.segment2
          ,paaf.person_id
    FROM   per_all_assignments_f paaf
          ,hr_soft_coding_keyflex scl
    WHERE  paaf.assignment_id = c_assignment_id
    AND    paaf.soft_coding_keyflex_id = scl.soft_coding_keyflex_id
    AND    c_effective_date between paaf.effective_start_date and paaf.effective_end_date;
    --
    CURSOR csr_get_work_centers(c_work_center  NUMBER) IS
    SELECT hoi2.org_information1 work_center
    FROM   hr_organization_information hoi1
          ,hr_organization_information hoi2
    WHERE  hoi1.organization_id = hoi2.organization_id
    AND    hoi1.org_information1  = c_work_center
    AND    hoi1.org_information_context  = 'ES_WORK_CENTER_REF'
    AND    hoi2.org_information_context  = 'ES_WORK_CENTER_REF';
    --
    CURSOR csr_get_assignment_id(c_person_id      NUMBER
                                ,c_effective_date DATE
                                ,c_work_center    NUMBER) IS
    SELECT paaf.assignment_id
    FROM   per_all_assignments_f paaf
          ,hr_soft_coding_keyflex scl
    WHERE  paaf.person_id = c_person_id
    AND    paaf.soft_coding_keyflex_id = scl.soft_coding_keyflex_id
    AND    scl.segment2 = c_work_center
    AND    c_effective_date between paaf.effective_start_date and paaf.effective_end_date;
    --
     l_salary      NUMBER;
     l_tot_salary  NUMBER;
     l_work_center NUMBER;
     l_person_id   NUMBER;
    --
BEGIN
    --
    OPEN  csr_get_work_center(p_assignment_id,p_calculation_date);
    FETCH csr_get_work_center INTO l_work_center,l_person_id;
    CLOSE csr_get_work_center;
    --
    l_tot_salary := 0;
    l_salary := 0;
    --
    FOR i in csr_get_work_centers(l_work_center) LOOP
        hr_utility.trace(' Work Center ID : '||i.work_center);

        FOR l_rec IN csr_get_assignment_id(l_person_id,p_calculation_date,i.work_center) LOOP
        --
             hr_utility.trace(' Assignment ID : '||l_rec.assignment_id);

             l_salary :=   pqp_rates_history_calc.get_historic_rate(
                           p_assignment_id                => l_rec.assignment_id
                          ,p_rate_name                    => p_name
                          ,p_effective_date               => p_calculation_date
                          ,p_time_dimension               => p_to_time_dim
                          ,p_rate_type_or_element         => p_rt_element
                          );
            l_tot_salary := l_tot_salary +  l_salary;
        END LOOP;
    END LOOP;
    p_rate  := l_tot_salary;
    p_error_message := 'No Error';
    RETURN l_tot_salary;
    --
END get_contractual_earnings;
--
--------------------------------------------------------------------------------
-- CALC_WITHHOLDING_QUOTA
--------------------------------------------------------------------------------
FUNCTION calc_withholding_quota(p_business_gr_id IN NUMBER
                               ,p_effective_date IN DATE
                               ,p_tax_base       IN NUMBER)  RETURN NUMBER IS
--
    CURSOR c_get_rows(c_efective_date DATE) IS
    SELECT  to_number(pur.row_low_range_or_name) Low_val
           ,to_number(pur.ROW_HIGH_RANGE) high_val
    FROM   pay_user_rows_f  pur
           ,pay_user_tables  put
    WHERE  put.legislation_code = 'ES'
    AND    pur.user_table_id = put.user_table_id
    AND    put.user_table_name  like 'ES_WITHHOLDING_QUOTAS'
    AND    c_efective_date BETWEEN pur.effective_start_date AND pur.effective_end_date
    ORDER BY 1;
    --
    l_tax_base NUMBER;
    l_withholding_quota NUMBER;
    l_perc NUMBER;
    l_diff NUMBER;
--

BEGIN
    --
    l_tax_base := p_tax_base;
    l_withholding_quota := 0;
    --
    FOR i IN c_get_rows(p_effective_date) LOOP
        --
        l_diff := i.high_val - round(i.low_val);
        l_perc := get_table_value(bus_group_id    =>  p_business_gr_id
                                 ,ptab_name       => 'ES_WITHHOLDING_QUOTAS'
                                 ,pcol_name       => 'WITHHOLDING_QUOTAS'
                                 ,prow_value      =>  i.high_val
                                 ,peffective_date =>  p_effective_date);
        IF l_tax_base <= l_diff THEN
            l_withholding_quota := l_withholding_quota + l_tax_base * l_perc/100;
            RETURN l_withholding_quota;
        ELSE
            l_withholding_quota := l_withholding_quota + (l_diff * l_perc/100);
        END IF;
        l_tax_base := l_tax_base -  l_diff;
    END LOOP;
    RETURN l_withholding_quota;
END calc_withholding_quota;
--
--
--------------------------------------------------------------------------------
-- CALC_WITHHOLDING_QUOTA
--------------------------------------------------------------------------------
FUNCTION get_contract_end_date(p_assignment_id        IN  NUMBER
                              ,p_effective_date       IN  DATE) RETURN DATE
IS
    CURSOR csr_get_contract_end_date(c_assignment_id        NUMBER
                                    ,c_effective_date       DATE) IS
    SELECT NVL(fnd_date.canonical_to_date(CTR_INFORMATION4),to_date('31-12-4712','dd-mm-yyyy')) Contract_End_Date
    FROM   PER_CONTRACTS_f pcf
          ,per_all_assignments_f paaf
    WHERE  paaf.assignment_id           = c_assignment_id
    AND    paaf.contract_id             = pcf.contract_id
    AND    pcf.ctr_information_category = 'ES'
    AND    sysdate BETWEEN paaf.effective_start_date
                       AND paaf.effective_end_date
    AND    sysdate BETWEEN pcf.effective_start_date
                       AND pcf.effective_end_date;
    l_end_date DATE;
    --
BEGIN
    --
    OPEN csr_get_contract_end_date(p_assignment_id,p_effective_date);
    FETCH csr_get_contract_end_date INTO l_end_date;
        IF  csr_get_contract_end_date%NOTFOUND THEN
            CLOSE csr_get_contract_end_date;
            RETURN to_date('31-12-4712','dd-mm-yyyy');
        END IF;
    CLOSE csr_get_contract_end_date;
    --
    RETURN l_end_date;
    --
END get_contract_end_date;
--
--------------------------------------------------------------------------------
-- CALC_WITHHOLDING_QUOTA
--------------------------------------------------------------------------------
FUNCTION get_contractual_deductions(p_assignment_id          IN NUMBER
                                   ,p_calculation_date       IN DATE
                                   ,p_period_start_date      IN DATE
                                   ,p_period_end_date        IN DATE
                                   ,p_pay_periods_per_year   IN NUMBER
                                   ,p_pay_proc_period_number IN NUMBER
                                   ,p_child_support_amt      OUT NOCOPY NUMBER
                                   ,p_spouse_alimony_amt     OUT NOCOPY NUMBER)
                                   RETURN NUMBER IS
--
    CURSOR csr_get_work_center(c_assignment_id  NUMBER
                              ,c_effective_date DATE) IS
    SELECT scl.segment2
          ,paaf.person_id
    FROM   per_all_assignments_f paaf
          ,hr_soft_coding_keyflex scl
    WHERE  paaf.assignment_id = c_assignment_id
    AND    paaf.soft_coding_keyflex_id = scl.soft_coding_keyflex_id
    AND    c_effective_date between paaf.effective_start_date and paaf.effective_end_date;
    --
    CURSOR csr_get_work_centers(c_work_center  NUMBER) IS
    SELECT hoi2.org_information1 work_center
    FROM   hr_organization_information hoi1
          ,hr_organization_information hoi2
    WHERE  hoi1.organization_id = hoi2.organization_id
    AND    hoi1.org_information1  = c_work_center
    AND    hoi1.org_information_context  = 'ES_WORK_CENTER_REF'
    AND    hoi2.org_information_context  = 'ES_WORK_CENTER_REF';
    --
    CURSOR csr_get_assignment_id(c_person_id      NUMBER
                                ,c_effective_date DATE
                                ,c_work_center    NUMBER) IS
    SELECT paaf.assignment_id
          ,paaf.payroll_id
          ,pet.element_name element_name
          ,pee.element_entry_id
          ,pee.effective_start_date rec_start_date
          ,pee.effective_end_date rec_end_date
          ,min(decode(piv.name, 'Amount', peev.screen_entry_value , null)) Amount
          ,min(decode(piv.name, 'Period Type', peev.screen_entry_value , null)) Period_type
          ,min(decode(piv.name, 'Start Date', peev.screen_entry_value , null)) Start_date
          ,min(decode(piv.name, 'End Date', peev.screen_entry_value , null)) End_date
    FROM   per_all_assignments_f paaf
          ,hr_soft_coding_keyflex scl
          ,pay_element_entries_f pee
          ,pay_element_entry_values_f peev
          ,pay_element_types_f pet
          ,pay_input_values_f piv
    WHERE  paaf.person_id = c_person_id
    AND    paaf.soft_coding_keyflex_id = scl.soft_coding_keyflex_id
    AND    scl.segment2 = c_work_center
    AND    pee.assignment_id = paaf.assignment_id
    AND    pee.element_entry_id = peev.element_entry_id
    AND    pet.legislation_code = 'ES'
    AND    pet.element_name in ('Child Support','Spouse Alimony')
    AND    pet.element_type_id = pee.element_type_id
    AND    piv.element_type_id = pet.element_type_id
    AND    piv.input_value_id  = peev.input_value_id
    AND    c_effective_date between paaf.effective_start_date and paaf.effective_end_date
    AND    c_effective_date between pee.effective_start_date  and pee.effective_end_date
    AND    c_effective_date between peev.effective_start_date and peev.effective_end_date
    AND    c_effective_date between piv.effective_start_date  and piv.effective_end_date
    AND    c_effective_date between pet.effective_start_date  and pet.effective_end_date
    group by paaf.assignment_id
            ,paaf.payroll_id
            ,pet.element_name
            ,pee.element_entry_id
            ,pee.effective_start_date
            ,pee.effective_end_date;

    --
     l_salary      NUMBER;
     l_tot_salary  NUMBER;
     l_work_center NUMBER;
     l_person_id   NUMBER;
     l_start_date  DATE;
     l_end_date    DATE;
     l_end_year    DATE;
     l_amt            NUMBER;
     l_end_period_no  NUMBER;
     l_curr_period_no NUMBER;
     l_co_start_date  DATE;
     l_co_end_date  DATE;
    --
BEGIN
    --
    OPEN  csr_get_work_center(p_assignment_id,p_calculation_date);
    FETCH csr_get_work_center INTO l_work_center,l_person_id;
    CLOSE csr_get_work_center;
    --
    p_child_support_amt := 0;
    p_spouse_alimony_amt := 0;
    l_end_year := TO_DATE('3112'||TO_CHAR(p_calculation_date,'YYYY'),'ddmmyyyy');
    --
    FOR l_rec in csr_get_work_centers(l_work_center) LOOP
        hr_utility.trace(' Work Center ID : '||l_rec.work_center);
        FOR i IN csr_get_assignment_id(l_person_id,p_calculation_date,l_rec.work_center) LOOP
            --
            l_co_start_date := fnd_date.canonical_to_date(i.start_date);
            l_co_end_date := fnd_date.canonical_to_date(i.end_date);
            l_amt        := 0;
            l_start_date :=  GREATEST(p_period_start_date,nvl(l_co_start_date,p_period_start_date));
            l_end_date   :=  LEAST(l_end_year,nvl(l_co_end_date,l_end_year));
            IF i.Period_type = 'A' THEN
                IF l_co_end_date IS NULL THEN
                    l_amt := (i.Amount/p_pay_periods_per_year)*(p_pay_periods_per_year - p_pay_proc_period_number + 1);
                ELSE
                    l_end_period_no := get_pay_period_number(i.payroll_id,l_end_date);
                    l_curr_period_no :=  get_pay_period_number(i.payroll_id,l_start_date);
                    l_amt := (i.Amount/p_pay_periods_per_year)*(l_end_period_no - l_curr_period_no + 1);
                END IF;
            ELSE
                l_end_period_no := get_pay_period_number(i.payroll_id,l_end_date);
                l_curr_period_no :=  get_pay_period_number(i.payroll_id,l_start_date);
                l_amt := i.Amount*(l_end_period_no - l_curr_period_no + 1);
            END IF;
            --
            IF i.element_name = 'Child Support' THEN
                p_child_support_amt := p_child_support_amt + l_amt;
            ELSE
                p_spouse_alimony_amt := p_spouse_alimony_amt + l_amt;
            END IF;
        END LOOP;
    END LOOP;
    RETURN 0;
    --
END get_contractual_deductions;
--
END pay_es_twr_calc_pkg;

/
