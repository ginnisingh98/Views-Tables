--------------------------------------------------------
--  DDL for Package Body PAY_ES_SS_CALCULATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_ES_SS_CALCULATION" as
/* $Header: pyesssdc.pkb 120.14 2006/04/28 02:04:23 grchandr noship $ */
--
TYPE cac_epigraph_change_rec is RECORD
(cac                      VARCHAR2(15),
 epigraph                 VARCHAR2(5),
 epigraph_114             VARCHAR2(1),
 epigraph_126             VARCHAR2(1),
 days                     NUMBER,
 start_date               DATE,
 end_date                 DATE,
 no_ptm_days              NUMBER,
 no_ptm_hours             NUMBER,
 no_partial_strike_days   NUMBER,
 no_partial_strike_hours  NUMBER,
 active_without_pay_days  NUMBER,
 active_without_pay_hours NUMBER,
 days_worked              NUMBER,
 no_td_days               NUMBER,
 Tot_Days                 NUMBER,
 PU_Days                  NUMBER);
--
TYPE cac_epigraph_change_tab is TABLE of cac_epigraph_change_rec INDEX by BINARY_INTEGER;
cac_epigraph_change cac_epigraph_change_tab;
--
GIndex NUMBER;
--------------------------------------------------------------------------------
-- GET_ASSIGNMENT_INFO
--------------------------------------------------------------------------------
FUNCTION get_assignment_info(p_assignment_id       IN  NUMBER
                            ,p_effective_date      IN  DATE
                            ,p_contribution_grp    OUT NOCOPY VARCHAR2
                            ,p_work_center         OUT NOCOPY NUMBER
                            ,p_35_yrs_ss           OUT NOCOPY VARCHAR2
                            ,p_seniority_yrs       OUT NOCOPY NUMBER
                            ,p_date                IN  DATE) RETURN NUMBER
IS
--
    CURSOR csr_get_per_info(c_assignment_id  NUMBER
                           ,c_effective_date DATE) IS
    SELECT pap.per_information5
          ,pps.adjusted_svc_date
    FROM   per_all_people_f pap
          ,per_all_assignments_f  paaf
          ,per_periods_of_service pps
    WHERE  paaf.assignment_id = c_assignment_id
    AND    paaf.person_id = pap.person_id
    AND    pap.person_id  = pps.person_id
    AND    paaf.period_of_service_id = pps.period_of_service_id
    AND    c_effective_date between paaf.effective_start_date and paaf.effective_end_date
    AND    c_effective_date between pap.effective_start_date and pap.effective_end_date;
    --
    CURSOR csr_get_assign_info(c_assignment_id  NUMBER
                              ,c_effective_date DATE) IS
    SELECT segment5
          ,segment2
    FROM   per_all_assignments_f paaf
          ,hr_soft_coding_keyflex scl
    WHERE  paaf.assignment_id = c_assignment_id
    AND    paaf.soft_coding_keyflex_id = scl.soft_coding_keyflex_id
    AND    c_effective_date between paaf.effective_start_date and paaf.effective_end_date;
    --
    l_date DATE;
--
BEGIN
    --
    hr_utility.trace('get_assignment_info ');
    OPEN  csr_get_per_info(p_assignment_id,p_date);
        FETCH csr_get_per_info into p_35_yrs_ss, l_date;
    CLOSE csr_get_per_info;
    --
    hr_utility.trace('p_35_yrs_ss '||p_35_yrs_ss);
    --
    p_seniority_yrs := FLOOR(MONTHS_BETWEEN(p_date,l_date)/12);
    hr_utility.trace('p_seniority_yrs '||p_seniority_yrs);
    --
    OPEN  csr_get_assign_info(p_assignment_id,p_date);
        FETCH csr_get_assign_info into p_Contribution_grp,p_work_center;
    CLOSE csr_get_assign_info;
    --
    hr_utility.trace('leaving get_assignment_info ');
    --
    return 0;
END get_assignment_info;
--
--------------------------------------------------------------------------------
-- GET_ABSENCE_DAYS
--------------------------------------------------------------------------------
FUNCTION get_absence_days(p_assignment_id     IN NUMBER
                         ,p_business_group_id IN NUMBER
                         ,p_effective_date    IN DATE
                         ,p_period_start_date IN DATE
                         ,p_period_end_date   IN DATE
                         ,p_leave_type        IN VARCHAR2
                         ,p_work_pattern      IN VARCHAR2) RETURN NUMBER
IS
    --
    CURSOR csr_get_no_absence(c_assignment_id     NUMBER
                             ,c_business_group_id NUMBER
                             ,c_effective_date    DATE
                             ,c_period_start_date DATE
                             ,c_period_end_date   DATE
                             ,c_leave_type        VARCHAR2) IS
    SELECT  GREATEST (paa.DATE_START,c_period_start_date) start_date
           ,LEAST(c_period_end_date,nvl(paa.date_end,to_date('31/12/4712','dd/mm/yyyy'))) end_date
           ,paa.abs_information3 ptm_perc
    FROM    per_absence_attendances paa
           ,per_absence_attendance_types paat
           ,per_all_people_f pap
           ,per_all_assignments_f  paaf
    WHERE   paaf.assignment_id          = c_assignment_id
    AND     paaf.business_group_id      = c_business_group_id
    AND     paaf.person_id              = pap.person_id
    AND     pap.person_id               = paa.person_id
    AND     paat.absence_category       = c_leave_type
    AND     paat.absence_attendance_type_id = paa.absence_attendance_type_id
    AND     NVL(paa.date_end,c_period_end_date) >= c_period_start_date
    AND     paa.date_start  <= c_period_end_date
    AND     c_effective_date BETWEEN paaf.effective_start_date AND paaf.effective_end_date
    AND     c_effective_date BETWEEN pap.effective_start_date AND Pap.effective_end_date;
    --
    l_no_days NUMBER;
    l_days NUMBER;
    l_date DATE;
    l_is_wrking_day VARCHAR2(1);
    l_error_code    NUMBER;
    l_error_msg     fnd_new_messages.message_text%TYPE;
    l_ptm_perc NUMBER;
    --
BEGIN
    --
    l_no_days := 0;
    l_ptm_perc := 0;
    --
    hr_utility.trace('~~ Type '||p_leave_type);
    FOR i IN csr_get_no_absence(p_assignment_id
                               ,p_business_group_id
                               ,p_effective_date
                               ,p_period_start_date
                               ,p_period_end_date
                               ,p_leave_type) LOOP
        l_date := i.start_date;
        IF  p_leave_type = 'PTM' THEN
            l_ptm_perc := i.ptm_perc;
        END IF;
        l_days := 0;
        IF p_work_pattern = 'Y' THEN
            LOOP
                EXIT WHEN l_date > i.end_date;
                l_is_wrking_day := pqp_schedule_calculation_pkg.is_working_day
                    (p_assignment_id      =>  p_assignment_id
                    ,p_business_group_id  =>  p_business_group_id
                    ,p_date               =>  l_date
                    ,p_error_code         =>  l_error_code
                    ,p_error_message      =>  l_error_msg
                    ,p_default_wp         =>  null
                    );
                IF l_is_wrking_day = 'Y' THEN
                    l_days := l_days + 1;
                END IF;
                l_date := l_date +1;
            END LOOP;
            IF p_leave_type = 'PTM' THEN
                l_no_days := l_no_days + l_days*(100-l_ptm_perc)/100;
            ELSE
                l_no_days := l_no_days + l_days;
            END IF;
        ELSE
            IF p_leave_type = 'PTM' THEN
                l_no_days := l_no_days + ((i.end_date - i.start_date) + 1)*(100-l_ptm_perc)/100;
            ELSE
                l_no_days := l_no_days + (i.end_date - i.start_date) + 1;
            END IF;
        END IF;
    END LOOP;
    hr_utility.trace('~~ l_no_days '||l_no_days);
    --
    RETURN nvl(l_no_days,0);
    --
END get_absence_days;
--
--------------------------------------------------------------------------------
-- GET_ABSENCE_HOURS
--------------------------------------------------------------------------------
FUNCTION get_absence_hours(p_assignment_id     IN NUMBER
                          ,p_business_group_id IN NUMBER
                          ,p_effective_date    IN DATE
                          ,p_period_start_date IN DATE
                          ,p_period_end_date   IN DATE
                          ,p_leave_type        IN VARCHAR2) RETURN NUMBER
IS
    --
    CURSOR csr_get_no_absence(c_assignment_id     NUMBER
                             ,c_business_group_id NUMBER
                             ,c_effective_date    DATE
                             ,c_period_start_date DATE
                             ,c_period_end_date   DATE
                             ,c_leave_type        VARCHAR2) IS
    SELECT  GREATEST(paa.date_start,c_period_start_date) start_date
           ,LEAST(c_period_end_date,nvl(paa.date_end,to_date('31/12/4712','dd/mm/yyyy'))) end_date
           ,time_start
           ,time_end
    FROM    per_absence_attendances paa
           ,per_absence_attendance_types paat
           ,per_all_people_f pap
           ,per_all_assignments_f  paaf
    WHERE   paaf.assignment_id          = c_assignment_id
    AND     paaf.business_group_id      = c_business_group_id
    AND     paaf.person_id              = pap.person_id
    AND     pap.person_id               = paa.person_id
    AND     paat.absence_category       = c_leave_type
    AND     paat.absence_attendance_type_id = paa.absence_attendance_type_id
    AND     NVL(paa.date_end,c_period_end_date) >= c_period_start_date
    AND     paa.DATE_start <= c_period_end_date
    AND     c_effective_date between paaf.effective_start_date and paaf.effective_end_date
    AND     c_effective_date between pap.effective_start_date and pap.effective_end_date;
    --
    l_no_hours NUMBER;
    l_date DATE;
    l_is_wrking_day VARCHAR2(1);
    l_error_code    NUMBER;
    l_error_msg     fnd_new_messages.message_text%TYPE;
    l_hrs_wrked NUMBER;
    --
BEGIN
    --
    l_no_hours := 0;
    FOR i in csr_get_no_absence(p_assignment_id
                               ,p_business_group_id
                               ,p_effective_date
                               ,p_period_start_date
                               ,p_period_end_date
                               ,p_leave_type) LOOP
        l_date := i.start_date;
        IF i.start_date = i.end_date THEN
            l_is_wrking_day := PQP_SCHEDULE_CALCULATION_PKG.is_working_day
				(p_assignment_id      =>  p_assignment_id
				,p_business_group_id  =>  p_business_group_id
				,p_date               =>  l_date
				,p_error_code         =>  l_error_code
				,p_error_message      =>  l_error_msg
				,p_default_wp         =>  null
				);
            IF l_is_wrking_day = 'Y' THEN
                l_hrs_wrked:=pqp_schedule_calculation_pkg.get_hours_worked
                    (p_assignment_id       =>  p_assignment_id
                    ,p_business_group_id   =>  p_business_group_id
                    ,p_date_start          =>  l_date
                    ,p_date_end            =>  l_date
                    ,p_error_code          =>  l_error_code
                    ,p_error_message       =>  l_error_msg
                    ,p_default_wp          =>  NULL
                    );
               IF i.time_start IS NOT NULL AND
                  i.time_end   IS NOT NULL THEN
                    l_no_hours := l_no_hours + greatest((to_date('0001/01/01 '||i.time_end,'yyyy/mm/dd hh24:mi') - to_date('0001/01/01 '||i.time_start,'yyyy/mm/dd hh24:mi'))*24,l_hrs_wrked);
               ELSE
                    l_no_hours := l_no_hours + l_hrs_wrked;
               END IF;
           END IF;
        ELSE
            l_hrs_wrked:=pqp_schedule_calculation_pkg.get_hours_worked
                (p_assignment_id       =>  p_assignment_id
                ,p_business_group_id   =>  p_business_group_id
                ,p_date_start          =>  i.start_date
                ,p_date_end            =>  i.end_date
                ,p_error_code          =>  l_error_code
                ,p_error_message       =>  l_error_msg
                ,p_default_wp          =>  NULL
                );
            l_no_hours := l_no_hours + l_hrs_wrked;
        END IF;
    END LOOP;
    --
    RETURN l_no_hours;
    --
END get_absence_hours;
--
--------------------------------------------------------------------------------
-- GET_WORKING_TIME
--------------------------------------------------------------------------------
FUNCTION get_working_time(p_assignment_id     IN  NUMBER
                         ,p_business_group_id IN  NUMBER
                         ,p_period_start_date IN  DATE
                         ,p_period_end_date   IN  DATE
                         ,p_working_days      OUT NOCOPY NUMBER
                         ,p_working_hours     OUT NOCOPY NUMBER) RETURN NUMBER
IS
    l_date DATE;
    l_no_days NUMBER;
    l_is_wrking_day VARCHAR2(1);
    l_error_code    NUMBER;
    l_error_msg     fnd_new_messages.message_text%TYPE;
    --
BEGIN
    --
    l_date := p_period_start_date;
    l_no_days := 0;
    LOOP
        EXIT WHEN l_date > p_period_end_date;
        l_is_wrking_day := PQP_SCHEDULE_CALCULATION_PKG.is_working_day
				(p_assignment_id      =>  p_assignment_id
				,p_business_group_id  =>  p_business_group_id
				,p_date               =>  l_date
				,p_error_code         =>  l_error_code
				,p_error_message      =>  l_error_msg
				,p_default_wp         =>  null
				);
        IF l_is_wrking_day = 'Y' THEN
            l_no_days := l_no_days + 1;
        END IF;
        l_date := l_date + 1;
    END LOOP;
    p_working_hours := pqp_schedule_calculation_pkg.get_hours_worked
                            (p_assignment_id       =>  p_assignment_id
                            ,p_business_group_id   =>  p_business_group_id
                            ,p_date_start          =>  p_period_start_date
                            ,p_date_end            =>  p_period_end_date
                            ,p_error_code          =>  l_error_code
                            ,p_error_message       =>  l_error_msg
                            ,p_default_wp          =>  NULL
                            );
    p_working_days := l_no_days;
    hr_utility.trace('**************** p_working_days '||p_working_days);
    hr_utility.trace('**************** p_working_hours '||p_working_hours);
    RETURN l_no_days;
END;
--
--------------------------------------------------------------------------------
-- GET_WORK_CENTER_INFO
--------------------------------------------------------------------------------
FUNCTION get_work_center_info(p_business_gr_id      IN  NUMBER
                             ,p_work_center         IN  NUMBER
                             ,p_info1               OUT NOCOPY VARCHAR2
                             ,p_info2               OUT NOCOPY VARCHAR2
                             ,p_info3               OUT NOCOPY VARCHAR2
                             ,p_info4               OUT NOCOPY VARCHAR2
                             ,p_info5               OUT NOCOPY VARCHAR2
                             ,p_info6               OUT NOCOPY VARCHAR2
                             ,p_info7               OUT NOCOPY VARCHAR2
                             ,p_info8               OUT NOCOPY VARCHAR2
                             ,p_info9               OUT NOCOPY VARCHAR2
                             ,p_info10              OUT NOCOPY VARCHAR2) RETURN NUMBER
IS
--
    CURSOR csr_work_center(c_business_group_id NUMBER, c_work_center NUMBER)IS
    SELECT  hoi.org_information3
           ,hoi.org_information4
           ,hoi.org_information5
           ,hoi.org_information6
           ,hoi.org_information7
           ,hoi.org_information8
           ,hoi.org_information9
           ,hoi.org_information10
           ,hoi.org_information11
           ,hoi.org_information12
    FROM    hr_organization_information hoi
    WHERE   hoi.organization_id          = c_work_center
    AND     hoi.org_information_context = 'ES_WORK_CENTER_DETAILS';
--
BEGIN
    --
    OPEN  csr_work_center(p_business_gr_id,p_work_center);
    FETCH csr_work_center INTO p_info1
                              ,p_info2
                              ,p_info3
                              ,p_info4
                              ,p_info5
                              ,p_info6
                              ,p_info7
                              ,p_info8
                              ,p_info9
                              ,p_info10;
    CLOSE csr_work_center;
    --
    RETURN 0;
END get_work_center_info;
--
--------------------------------------------------------------------------------
-- GET_LEGAL_EMPLOYER_INFO
--------------------------------------------------------------------------------
FUNCTION get_legal_employer_info(p_business_gr_id       IN  NUMBER
                                ,p_effective_date       IN  DATE
                                ,p_assignment_id        IN  NUMBER
                                ,p_work_center          IN  NUMBER
                                ,p_period_start_date    IN  DATE
                                ,p_period_end_date      IN  DATE
                                ,p_ss_type              IN  VARCHAR2
                                ,p_td_flag              OUT NOCOPY VARCHAR2
                                ,p_td_rebate_days       OUT NOCOPY NUMBER
                                ,p_le_td_perc           OUT NOCOPY NUMBER
                                ,p_ss_td_perc           OUT NOCOPY NUMBER
                                ,p_exempt_flag          OUT NOCOPY VARCHAR2
                                ,p_exempt_days          OUT NOCOPY NUMBER
                                ,p_le_exempt_perc       OUT NOCOPY NUMBER
                                ,p_emp_exempt_perc      OUT NOCOPY NUMBER
                                ,p_tot_days             IN  NUMBER
                                ,p_contract_type        IN  VARCHAR2) RETURN NUMBER
IS
--
    CURSOR csr_legal_employer_info(c_business_group_id  NUMBER
                                  ,c_work_center        NUMBER
                                  ,c_type               VARCHAR2
                                  ,c_period_start_date  DATE
                                  ,c_period_end_date    DATE)IS
    SELECT  hoi2.org_information1 situation
           ,fnd_date.canonical_to_date(hoi2.org_information2) start_date
           ,nvl(fnd_date.canonical_to_date(hoi2.org_information3),c_period_end_date) end_date
    FROM    hr_organization_information hoi
           ,hr_organization_information hoi1
           ,hr_all_organization_units hou
           ,hr_organization_information hoi2
    WHERE   hou.business_group_id        = p_business_gr_id
    AND     hoi.org_information1         = c_work_center
    AND     hoi.org_information_context  = 'ES_WORK_CENTER_REF'
    AND     hoi1.organization_id         = hou.organization_id
    AND     hoi2.organization_id         = hou.organization_id
    AND     hou.organization_id          = hoi.organization_id
    AND     hoi1.org_information_context = 'CLASS'
    AND     hoi1.org_information1        = 'HR_LEGAL_EMPLOYER'
    AND     hoi2.org_information_context = c_type
    AND     fnd_date.canonical_to_date(hoi2.org_information2) <= c_period_end_date
    and     nvl(fnd_date.canonical_to_date(hoi2.org_information3),c_period_end_date) >= c_period_start_date
    ORDER BY hoi1.organization_id ;
    --
    l_ret pay_user_column_instances_f.value%type;
    l_tot_days  NUMBER;
    l_days      NUMBER;
    l_act_days  NUMBER;
    l_tmp_days  NUMBER;
    l_tmp_hours NUMBER;
    --
BEGIN
    --
    p_td_flag           := 'N';
    p_le_td_perc        := 0;
    p_ss_td_perc        := 0;
    p_exempt_flag       := 'N';
    p_le_exempt_perc    := 0;
    p_emp_exempt_perc   := 0;
    p_td_rebate_days    := 0;
    p_exempt_days       := 0;
    --
    l_tot_days          := p_tot_days;
    l_days              := 0;
    l_act_days          := 0;
    l_tmp_days          := 0;
    l_tmp_hours         := 0;
    --
    FOR I IN csr_legal_employer_info(p_business_gr_id
                                    ,p_work_center
                                    ,'ES_TEMP_DISABILITY_MGT'
                                    ,p_period_start_date
                                    ,p_period_end_date) LOOP
        l_act_days := p_period_end_date - p_period_start_date + 1;
        l_days := (LEAST(p_period_end_date,i.end_date) - GREATEST(p_period_start_date,i.start_date) + 1);
        IF p_contract_type = 'PART_TIME' THEN
            l_days := get_working_time(p_assignment_id
                                      ,p_business_gr_id
                                      ,p_period_start_date
                                      ,p_period_end_date
                                      ,l_tmp_days
                                      ,l_tmp_hours);
        END IF;
        -- If calculated days are more then the no of days employee is supposed to work
        -- to handle 31 days
        IF l_days > p_tot_days THEN
            l_days := p_tot_days;
        END IF;
        -- If calculated days are for entire period
        -- to handle 28 days
        IF l_days = l_act_days THEN
            l_days := p_tot_days;
        END IF;
        hr_utility.trace('~~~~~~~~ Exempt days   '||l_days||p_ss_type|| i.situation);
        --
        IF p_ss_type = 'NON_IA_ID' AND i.situation IN ('EXP_LE_NON_IA_ID','EXP_SS') THEN
            p_td_flag := 'Y';
            p_td_rebate_days :=  p_td_rebate_days + l_days;
            l_ret:= get_table_value(p_business_gr_id
                                    ,'ES_CONTRIBUTION_RATES_FOR_NON_IA/ID_TEMPORARY_DISABILITY_MANAGEMENT'
                                    ,'TEMPORARY_DISABILITY'
                                    ,i.situation
                                    ,p_effective_date);
            IF i.situation = 'EXP_LE_NON_IA_ID' THEN
                p_le_td_perc := p_le_td_perc + (to_number(l_ret) * (l_days/l_tot_days));
            ELSIF i.situation = 'EXP_SS' THEN
                p_ss_td_perc := p_ss_td_perc + (to_number(l_ret) * (l_days/l_tot_days));
            END IF;
        ELSIF p_ss_type = 'IA_ID' AND i.situation = 'EXP_LE_IA_ID' THEN
            p_td_flag := 'Y';
            p_td_rebate_days :=  p_td_rebate_days + l_days;
            l_ret:= get_table_value(p_business_gr_id
                                    ,'ES_CONTRIBUTION_RATES_FOR_IA/ID_TEMPORARY_DISABILITY_MANAGEMENT'
                                    ,'TEMPORARY_DISABILITY'
                                    ,i.situation
                                    ,p_effective_date);
            p_le_td_perc := p_le_td_perc + (to_number(l_ret) * (l_days/l_tot_days));
        END IF;
    END LOOP;
    --
    IF p_ss_type = 'NON_IA_ID' THEN
        FOR I IN csr_legal_employer_info(p_business_gr_id
                                        ,p_work_center
                                        ,'ES_CONTRIB_EXEMPT'
                                        ,p_period_start_date
                                        ,p_period_end_date) LOOP
            p_exempt_flag := 'Y';
            l_act_days := p_period_end_date - p_period_start_date + 1;
            l_days := (LEAST(p_period_end_date,i.end_date) - GREATEST(p_period_start_date,i.start_date) + 1);
            IF p_contract_type = 'PART_TIME' THEN
                l_days := get_working_time(p_assignment_id
                                          ,p_business_gr_id
                                          ,p_period_start_date
                                          ,p_period_end_date
                                          ,l_tmp_days
                                          ,l_tmp_hours);
            END IF;
            -- If calculated days are more then the no of days employee is supposed to work
            -- to handle 31 days
            IF l_days > p_tot_days THEN
                l_days := p_tot_days;
            END IF;
            -- If calculated days are for entire period
            -- to handle 28 days
            IF l_days = l_act_days THEN
                l_days := p_tot_days;
            END IF;
            hr_utility.trace('l_days :'||l_days ||' l_tot_days : '||l_tot_days);
            p_exempt_days :=  p_exempt_days + l_days;
            l_ret:= get_table_value(p_business_gr_id
                                            ,'ES_CONTRIBUTION_RATES_FOR_EXEMPT_SITUATIONS'
                                            ,'EMPLOYERS_PERC'
                                            ,i.situation
                                            ,p_effective_date);

            p_le_exempt_perc := p_le_exempt_perc + (to_number(l_ret) * (l_days/l_tot_days));
            hr_utility.trace('p_le_exempt_perc :'||p_le_exempt_perc ||' l_ret : '||l_ret);
            --
            l_ret:= get_table_value(p_business_gr_id
                                            ,'ES_CONTRIBUTION_RATES_FOR_EXEMPT_SITUATIONS'
                                            ,'EMPLOYEES_PERC'
                                            ,i.situation
                                            ,p_effective_date);
            p_emp_exempt_perc := p_emp_exempt_perc + (to_number(l_ret) * (l_days/l_tot_days));
            hr_utility.trace('p_emp_exempt_perc :'||p_emp_exempt_perc ||' l_ret : '||l_ret);
        END LOOP;
    END IF;
    p_td_rebate_days    := LEAST(p_td_rebate_days,30);
    p_exempt_days       := LEAST(p_exempt_days,30);
    --
    hr_utility.trace('~~Rebate- LE - CE - TD ');
    hr_utility.trace('~~--p_td_flag          ' ||  p_td_flag          );
    hr_utility.trace('~~--p_td_rebate_days   ' || p_td_rebate_days    );
    hr_utility.trace('~~--p_le_td_perc       ' ||  p_le_td_perc       );
    hr_utility.trace('~~--p_ss_td_perc       ' ||  p_ss_td_perc       );
    hr_utility.trace('~~--p_exempt_flag      ' ||  p_exempt_flag      );
    hr_utility.trace('~~--p_exempt_days      ' ||  p_exempt_days      );
    hr_utility.trace('~~--p_le_exempt_perc   ' ||  p_le_exempt_perc   );
    hr_utility.trace('~~--p_emp_exempt_perc  ' ||  p_emp_exempt_perc  );
    --
    RETURN 0;
END get_legal_employer_info;
--
--------------------------------------------------------------------------------
-- GET_TRNG_HOURS
--------------------------------------------------------------------------------
FUNCTION get_trng_hours(p_business_gr_id       IN  NUMBER
                       ,p_assignment_id        IN  NUMBER
                       ,p_effective_date       IN  DATE
                       ,p_in_class_trng_hours  OUT NOCOPY NUMBER
                       ,p_remote_trng_hours    OUT NOCOPY NUMBER) RETURN NUMBER
IS
    CURSOR csr_get_trng_hours(c_business_gr_id       NUMBER
                             ,c_assignment_id        NUMBER
                             ,c_effective_date       DATE) IS
    SELECT sum(CTR_INFORMATION2) In_Class_trng_hours
          ,sum(CTR_INFORMATION3) Remote_trng_hours
    FROM   PER_CONTRACTS_f pcf
          ,per_all_assignments_f paaf
    WHERE  paaf.assignment_id           = c_assignment_id
    AND    paaf.business_group_id       = c_business_gr_id
    AND    paaf.contract_id             = pcf.contract_id
    AND    pcf.ctr_information_category = 'ES'
    AND    pcf.ctr_information1         = 'ES_TRAINING'
    AND    c_effective_date BETWEEN paaf.effective_start_date
                                AND paaf.effective_end_date
    AND    c_effective_date BETWEEN pcf.effective_start_date
                                AND pcf.effective_end_date ;
    --
BEGIN
    --
    OPEN  csr_get_trng_hours(p_business_gr_id
                            ,p_assignment_id
                            ,p_effective_date);
    FETCH csr_get_trng_hours INTO p_in_class_trng_hours,p_remote_trng_hours;
    CLOSE csr_get_trng_hours;
    --
    p_in_class_trng_hours := nvl(p_in_class_trng_hours,0);
    p_remote_trng_hours := nvl(p_remote_trng_hours,0);

    RETURN 0;
END get_trng_hours;
--
--------------------------------------------------------------------------------
-- GET_DEFINED_BAL_ID
--------------------------------------------------------------------------------
FUNCTION get_defined_bal_id(p_bal_name         IN  VARCHAR2
                           ,p_db_item_suffix   IN  VARCHAR2) RETURN NUMBER
IS
    --
    CURSOR get_def_bal_id is
    SELECT pdb.defined_balance_id
    FROM   pay_balance_types pbt
          ,pay_balance_dimensions pbd
          ,pay_defined_balances pdb
    WHERE  pdb.balance_type_id = pbt.balance_type_id
    AND    pdb.balance_dimension_id = pbd.balance_dimension_id
    AND    pbt.balance_name = p_bal_name
    AND    pbd.database_item_suffix = p_db_item_suffix;
    --
    l_def_bal_id NUMBER;
    --
BEGIN
    --
    OPEN get_def_bal_id;
    FETCH get_def_bal_id into l_def_bal_id;
    CLOSE get_def_bal_id;
    RETURN l_def_bal_id;
    --
END get_defined_bal_id;
--
--------------------------------------------------------------------------------
-- GET_PREV_SALARY
--------------------------------------------------------------------------------
FUNCTION get_prev_salary(p_assignment_action_id   IN NUMBER
                        ,p_balance_name           IN VARCHAR2
                        ,p_database_item_suffix   IN VARCHAR2
                        ,p_period_start_date      IN DATE
                        ,p_no_month               IN NUMBER
                        ,p_flag                   IN VARCHAR2
                        ,p_context                IN VARCHAR2
                        ,p_context_val            IN VARCHAR2
                        ,p_days                   IN OUT NOCOPY NUMBER) RETURN NUMBER
IS
    --
    CURSOR get_prev_periods_dates (c_assignment_action_id NUMBER
                                  ,c_period_start_date    DATE) IS
    SELECT  ptp.start_date  start_date
           ,ptp.end_date    end_date
           ,ppa.action_type
           ,MAX(paa2.assignment_action_id) assignment_action_id
     FROM   pay_assignment_actions paa1
           ,pay_assignment_actions paa2
           ,per_all_assignments_f  paaf1
           ,per_all_assignments_f  paaf2
           ,pay_payroll_actions    ppa
           ,pay_payroll_actions    ppa1
           ,per_time_periods       ptp
           ,per_time_period_types  ptpt
     WHERE  paa1.assignment_action_id     = c_assignment_action_id
     AND    ppa1.payroll_action_id        = paa1.payroll_action_id
     AND    ppa1.business_group_id        = paaf1.business_group_id
     AND    paa1.assignment_id            = paaf1.assignment_id
     AND    paaf1.person_id               = paaf2.person_id
     AND    paaf2.business_group_id       = paaf1.business_group_id
     AND    paaf2.assignment_id           = paa2.assignment_id
     AND    paa1.tax_unit_id              = paa2.tax_unit_id
     AND    paa2.payroll_action_id        = ppa.payroll_action_id
     AND    paa2.source_action_id         IS NULL
     AND    ptp.start_date                < c_period_start_date
     AND    ppa.payroll_id                = ptp.payroll_id
     AND    ppa.business_group_id          = paaf2.business_group_id
     AND    ptp.period_type                = ptpt.period_type
     AND    ppa.action_type               IN ('R','Q','I','B')
     AND    ppa.action_status             IN('C','U')
     AND    ppa.date_earned  BETWEEN ptp.start_date              AND ptp.end_date
     AND    ptp.end_date     BETWEEN paaf1.effective_start_date  AND paaf1.effective_end_date
     AND    ptp.end_date     BETWEEN paaf2.effective_start_date  AND paaf2.effective_end_date
     GROUP BY ptp.start_date, ptp.end_date, ppa.action_type
     ORDER BY 1 desc;

/*  SELECT ptp.start_date start_date
          ,ptp.end_date end_date
          ,ppa.action_type
          ,MAX(paa2.assignment_action_id) assignment_action_id
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
    AND   ppa.action_status             IN('C','U')
    AND   ptp.end_date BETWEEN paaf1.effective_start_date
                                        AND paaf1.effective_end_date
    AND   ptp.end_date BETWEEN paaf2.effective_start_date
                                        AND paaf2.effective_end_date
    GROUP BY ptp.start_date, ptp.end_date, ppa.action_type
    ORDER BY 1 desc;
*/
    --
    CURSOR get_legal_employer_id(c_work_center_id NUMBER) IS
    SELECT  hoi.organization_id
    FROM    hr_organization_information hoi
    WHERE   hoi.org_information1         = c_work_center_id
    AND     hoi.org_information_context  = 'ES_WORK_CENTER_REF';
    --
    l_def_bal_id          NUMBER;
    l_amount              NUMBER;
    l_amt                 NUMBER;
    l_ctr                 NUMBER;
    l_cnt                 NUMBER;
    l_start_date          DATE;
    l_date                DATE;
    l_legal_employer_id   hr_All_organization_units.organization_id%TYPE;
    --
BEGIN
    --
    hr_utility.trace('~~Entering pay_es_ss_calculation.get_prev_salary');
    l_def_bal_id := get_defined_bal_id(p_balance_name, p_database_item_suffix);
    hr_utility.trace('~~~~ p_balance_name'||p_balance_name);
    hr_utility.trace('~~~~ p_database_item_suffix'||p_database_item_suffix);
    hr_utility.trace('~~~~ l_def_bal_id'||l_def_bal_id);
    l_amount := 0;
    l_amt := 0;
    l_ctr := 0;
    l_cnt := 0;
    p_days := 0;
    l_date := to_date('01-01-0001','dd-mm-yyyy');
    --
    IF p_context = 'TAX_UNIT_ID' THEN
        OPEN  get_legal_employer_id(to_number(p_context_val));
        FETCH get_legal_employer_id INTO l_legal_employer_id;
        CLOSE get_legal_employer_id;
        pay_balance_pkg.set_context('TAX_UNIT_ID', l_legal_employer_id);
        hr_utility.trace('~~~~ Setting TAX_UNIT_ID Context '||l_legal_employer_id);
    END IF;
    --
    hr_utility.trace('~~~~ Start loop  p_period_start_date '||p_period_start_date);
    hr_utility.trace('~~~~ p_assignment_action_id '||p_assignment_action_id);
    FOR i IN get_prev_periods_dates( p_assignment_action_id, p_period_start_date) LOOP
        --
        IF l_date = i.start_date AND l_amt <> 0 THEN
            NULL;
        ELSE
            l_amt := 0;
            IF l_date <> i.start_date THEN
                l_ctr := l_ctr + 1;
            END IF;
            l_amt := pay_balance_pkg.get_value (l_def_bal_id, i.assignment_action_id);
            IF l_amt <> 0 THEN
                l_cnt := l_cnt + 1;
            END IF;
            l_amount := l_amount + l_amt;
            hr_utility.trace('~~~~ Inside loop  start_date '||i.start_date);
            hr_utility.trace('~~~~ assignment_action_id '||i.assignment_action_id);
            hr_utility.trace('~~~~ l_ctr '||l_ctr);
            hr_utility.trace('~~~~ l_cnt '||l_cnt);
            hr_utility.trace('~~~~ l_amt '||l_amt);
            hr_utility.trace('~~~~ l_amount '||l_amount);
            hr_utility.trace('~~~~ p_no_month '||p_no_month);
            IF l_amt <> 0 OR p_flag = 'N' THEN
                p_days := p_days + last_day(i.start_date) - last_day(add_months(i.start_date,-1));
            END IF;
            IF l_ctr >= p_no_month THEN
                IF l_cnt = p_no_month OR p_flag = 'N' THEN
                    RETURN l_amount;
                /*ELSE
                    l_ctr := p_no_month - 1;*/
                END IF;
            END IF;
            l_date := i.start_date;
        END IF;
    END LOOP;
    hr_utility.trace('~~Exiting pay_es_ss_calculation.get_prev_salary');
    RETURN l_amount;
    --
END get_prev_salary;
--
--------------------------------------------------------------------------------
-- GET_ROW_VALUE
--------------------------------------------------------------------------------
FUNCTION get_row_value(p_effective_date IN DATE
                      ,p_reduction_id   IN VARCHAR2
                      ,p_duration       IN NUMBER) RETURN VARCHAR2
IS
    --
    CURSOR csr_get_row_value(c_reduction_id  VARCHAR2
                            ,c_efective_date DATE ) IS
    SELECT  pur.row_low_range_or_name row_val
           ,puci2.value Offset
           ,puci3.value Duration
     FROM   pay_user_columns puc1
           ,pay_user_columns puc2
           ,pay_user_columns puc3
           ,pay_user_rows_f  pur
           ,pay_user_tables  put
           ,pay_user_column_instances_f puci1
           ,pay_user_column_instances_f puci2
           ,pay_user_column_instances_f puci3
     WHERE  put.legislation_code = 'ES'
     AND    pur.user_table_id = put.user_table_id
     AND    puc1.user_table_id = put.user_table_id
     AND    puc1.user_column_name='REBATE_REDUCTION_ID'
     AND    puc2.user_table_id = put.user_table_id
     AND    puc2.user_column_name='OFFSET'
     AND    puc3.user_table_id = put.user_table_id
     AND    puc3.user_column_name='DURATION'
     AND    puci1.user_row_id = pur.user_row_id
     AND    puci1.user_column_id = puc1.user_column_id
     AND    puci1.value = c_reduction_id
     AND    puci2.user_row_id = pur.user_row_id
     AND    puci2.user_column_id = puc2.user_column_id
     AND    puci3.user_row_id = pur.user_row_id
     AND    puci3.user_column_id = puc3.user_column_id
     AND    put.user_table_name  like 'ES_REBATE_OR_REDUCTION_RATES'
     AND    c_efective_date BETWEEN puci1.effective_start_date AND puci1.effective_end_date
     AND    c_efective_date BETWEEN puci2.effective_start_date AND puci2.effective_end_date
     AND    c_efective_date BETWEEN puci3.effective_start_date AND puci3.effective_end_date
     AND    c_efective_date BETWEEN pur.effective_start_date AND pur.effective_end_date
     ORDER BY 1;
     --
     l_row VARCHAR2(4);
     --
BEGIN
    --
    l_row := 0;
    FOR i in csr_get_row_value(p_reduction_id, p_effective_date) LOOP
        IF p_duration >= i.Offset AND p_duration <= (i.Offset + i.Duration) THEN
            l_row := i.row_val;
        END IF;
    END LOOP;
    --
    RETURN l_row;
END get_row_value;
--
--------------------------------------------------------------------------------
-- GET_INPUT_VALUE
--------------------------------------------------------------------------------
FUNCTION get_input_value(p_assignment_id            IN  NUMBER
                        ,p_effective_date           IN  DATE
                        ,p_no_ptm_days              OUT NOCOPY NUMBER
                        ,p_no_ptm_hours             OUT NOCOPY NUMBER
                        ,p_no_partial_strike_days   OUT NOCOPY NUMBER
                        ,p_no_partial_strike_hours  OUT NOCOPY NUMBER
                        ,p_active_without_pay_days  OUT NOCOPY NUMBER
                        ,p_active_without_pay_hours OUT NOCOPY NUMBER
                        ,p_rec_start_date           IN  DATE
                        ,p_rec_end_date             IN  DATE
                        ,p_cac                      IN  VARCHAR2
                        ,p_epigraph_code            IN  VARCHAR2
                        ,p_period_end_date          IN  DATE) RETURN NUMBER
IS
    CURSOR csr_get_value(c_assignment_id    NUMBER
                        ,c_effective_date   DATE
                        ,c_element_name     VARCHAR2
                        ,c_input_value_name VARCHAR2
                        ,c_type             VARCHAR2
                        ,c_rec_start_date   DATE
                        ,c_rec_end_date     DATE
                        ,c_period_end_date  DATE) IS
    SELECT  Sum(decode(piv2.name, c_input_value_name, nvl(peev2.screen_entry_value,0), null)) adjusted_period
           ,min(decode(piv2.name, 'Epigraph Code', nvl(peev2.screen_entry_value,'x'), null)) epigraph_code
           ,min(decode(piv2.name, 'Secondary CAC', nvl(peev2.screen_entry_value,'x'), null)) Secondary_CAC
    FROM    pay_element_entries_f peef1
           ,pay_element_entry_values_f peev1
           ,pay_element_entry_values_f peev2
           ,pay_input_values_f piv1
           ,pay_input_values_f piv2
           ,pay_element_types_f pet
    WHERE   pet.element_name =  c_element_name
    AND     piv1.element_type_id = pet.element_type_id
    AND     piv2.element_type_id = pet.element_type_id
    AND     pet.legislation_code = 'ES'
    AND     piv1.name  ='Reason'
    AND     peev1.screen_entry_value = c_type
    AND     peef1.element_type_id = pet.element_type_id
    AND     peef1.assignment_id = c_assignment_id
    AND     peev1.element_entry_id = peef1.element_entry_id
    AND     peev2.element_entry_id = peef1.element_entry_id
    AND     peev1.input_value_id   = piv1.input_value_id
    AND     peev2.input_value_id   = piv2.input_value_id
    AND     NVL(peef1.date_earned, c_period_end_date) BETWEEN c_rec_start_date
                                 AND c_rec_end_date
    AND     c_effective_date BETWEEN pet.effective_start_date
                                 AND pet.effective_end_date
    AND     c_effective_date BETWEEN peef1.effective_start_date
                                 AND peef1.effective_end_date
    AND     c_effective_date BETWEEN peev1.effective_start_date
                                 AND peev1.effective_end_date
    AND     c_effective_date BETWEEN piv1.effective_start_date
                                 AND piv1.effective_end_date
    AND     c_effective_date BETWEEN peev2.effective_start_date
                                 AND peev2.effective_end_date
    AND     c_effective_date BETWEEN  piv2.effective_start_date
                                 AND piv2.effective_end_date;
    --
    l_period   NUMBER;
    l_cac      VARCHAR2(15);
    l_epigraph VARCHAR2(5);
    --
BEGIN
    --
    p_no_ptm_days := 0;
    p_no_partial_strike_days := 0;
    p_active_without_pay_days := 0;
    --
    OPEN  csr_get_value(p_assignment_id
                       ,p_effective_date
                       ,'Social Security Days Adjustment'
                       ,'Days Adjustment'
                       ,'PTM'
                       ,p_rec_start_date
                       ,p_rec_end_date
                       ,p_period_end_date);
    FETCH csr_get_value INTO l_period,l_epigraph,l_cac;
    hr_utility.trace(' l_epigraph '||l_epigraph||' '||p_epigraph_code||' l_cac '||l_cac||' '||p_cac);
    IF csr_get_value%NOTFOUND THEN
        p_no_ptm_days := 0;
    ELSE
        IF l_epigraph = p_epigraph_code AND l_cac = p_cac THEN
            p_no_ptm_days := l_period;
        END IF;
    END IF;
    CLOSE csr_get_value;
    --
    OPEN  csr_get_value(p_assignment_id
                       ,p_effective_date
                       ,'Social Security Hours Adjustment'
                       ,'Hours Adjustment'
                       ,'PTM'
                       ,p_rec_start_date
                       ,p_rec_end_date
                       ,p_period_end_date);
    FETCH csr_get_value INTO l_period,l_epigraph,l_cac;
    IF csr_get_value%NOTFOUND THEN
        p_no_ptm_days := 0;
    ELSE
        IF l_epigraph = p_epigraph_code AND l_cac = p_cac THEN
            p_no_ptm_days := l_period;
        END IF;
    END IF;
    CLOSE csr_get_value;
    --
    OPEN  csr_get_value(p_assignment_id
                       ,p_effective_date
                       ,'Social Security Days Adjustment'
                       ,'Days Adjustment'
                       ,'PS'
                       ,p_rec_start_date
                       ,p_rec_end_date
                       ,p_period_end_date);
    FETCH csr_get_value INTO l_period,l_epigraph,l_cac;
    IF csr_get_value%NOTFOUND THEN
        p_no_partial_strike_days := 0;
    ELSE
        IF l_epigraph = p_epigraph_code AND l_cac = p_cac THEN
            p_no_partial_strike_days := l_period;
        END IF;
    END IF;
    CLOSE csr_get_value;
    --
    OPEN  csr_get_value(p_assignment_id
                       ,p_effective_date
                       ,'Social Security Hours Adjustment'
                       ,'Hours Adjustment'
                       ,'PS'
                       ,p_rec_start_date
                       ,p_rec_end_date
                       ,p_period_end_date);
    FETCH csr_get_value INTO l_period,l_epigraph,l_cac;
    IF csr_get_value%NOTFOUND THEN
        p_no_partial_strike_hours := 0;
    ELSE
        IF l_epigraph = p_epigraph_code AND l_cac = p_cac THEN
            p_no_partial_strike_hours := l_period;
        END IF;
    END IF;
    CLOSE csr_get_value;
    --
    OPEN  csr_get_value(p_assignment_id
                       ,p_effective_date
                       ,'Social Security Days Adjustment'
                       ,'Days Adjustment'
                       ,'AWP'
                       ,p_rec_start_date
                       ,p_rec_end_date
                       ,p_period_end_date);
    FETCH csr_get_value INTO l_period,l_epigraph,l_cac;
    IF csr_get_value%NOTFOUND THEN
        p_active_without_pay_days := 0;
    ELSE
        IF l_epigraph = p_epigraph_code AND l_cac = p_cac THEN
            p_active_without_pay_days := l_period;
        END IF;
    END IF;
    CLOSE csr_get_value;
    --
    OPEN  csr_get_value(p_assignment_id
                       ,p_effective_date
                       ,'Social Security Hours Adjustment'
                       ,'Hours Adjustment'
                       ,'AWP'
                       ,p_rec_start_date
                       ,p_rec_end_date
                       ,p_period_end_date);
    FETCH csr_get_value INTO l_period,l_epigraph,l_cac;
    IF csr_get_value%NOTFOUND THEN
        p_active_without_pay_hours := 0;
    ELSE
        IF l_epigraph = p_epigraph_code AND l_cac = p_cac THEN
            p_active_without_pay_hours := l_period;
        END IF;
    END IF;
    CLOSE csr_get_value;
    --
    p_no_ptm_days := nvl(p_no_ptm_days,0);
    p_no_partial_strike_days := nvl(p_no_partial_strike_days,0);
    p_active_without_pay_days := nvl(p_active_without_pay_days,0);
    hr_utility.trace(' p_no_ptm_days '||p_no_ptm_days);
    hr_utility.trace(' p_no_partial_strike_days '||p_no_partial_strike_days);
    hr_utility.trace(' p_active_without_pay_days '||p_active_without_pay_days);
    hr_utility.trace(' p_no_ptm_hours '||p_no_ptm_hours);
    hr_utility.trace(' p_no_partial_strike_hours '||p_no_partial_strike_hours);
    hr_utility.trace(' p_active_without_pay_hours '||p_active_without_pay_hours);
    --
    RETURN 0;
    --
END get_input_value;
--
--------------------------------------------------------------------------------
-- GET_TABLE_VALUE
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
        hr_utility.trace('l_ret '||l_ret);
    RETURN to_number(l_ret);
    --
END get_table_value;
--
--------------------------------------------------------------------------------
-- GET_ORG_CONTEXT_INFO
--------------------------------------------------------------------------------
FUNCTION get_org_context_info(p_assignment_id       IN  NUMBER
                             ,p_business_group_id   IN  NUMBER
                             ,p_work_center         IN  NUMBER
                             ,p_context             IN  VARCHAR2
                             ,p_period_start_date   IN  DATE
                             ,p_period_end_date     IN  DATE
                             ,p_tot_days            IN  NUMBER
                             ,p_contract_type       IN  VARCHAR2) RETURN NUMBER
IS
    CURSOR csr_get_context_info(c_work_center        NUMBER
                               ,c_context            VARCHAR2
                               ,c_period_start_date  DATE
                               ,c_period_end_date    DATE) IS
    SELECT  fnd_date.canonical_to_date(hoi.org_information1) Information_1
           ,nvl(fnd_date.canonical_to_date(hoi.org_information2),c_period_end_date) Information_2
           ,hoi.org_information3 Information_3
    FROM    hr_organization_information hoi
    WHERE   hoi.organization_id         = c_work_center
    AND     hoi.org_information_context = c_context  --'ES_WC_PARTIAL_UNEMPLOYMENT'~~'ES_WC_NATURAL_DISASTER'
    ORDER BY 1;
    --
    l_days NUMBER;
    l_total_days NUMBER;
    l_end_date DATE;
    l_tmp_days  NUMBER;
    l_tmp_hours NUMBER;
    l_act_days  NUMBER;
    --
BEGIN
    --
    hr_utility.trace('~~WC - '|| p_context);
    l_total_days := 0;
    l_act_days   := 0;
    l_tmp_days   := 0;
    l_tmp_hours  := 0;
    FOR i IN csr_get_context_info(p_work_center,p_context,p_period_start_date,p_period_end_date) LOOP
        l_days := 0;
        hr_utility.trace('~~--Start Loop '|| i.Information_1);
        hr_utility.trace('~~----Start Date '|| i.Information_1);
        hr_utility.trace('~~----End Date'|| i.Information_2);
        IF i.Information_1 > p_period_end_date THEN
            hr_utility.trace('~~Total Days '|| l_total_days);
            RETURN ROUND(l_total_days);
        END IF;
        IF i.Information_2 >= p_period_start_date THEN
            --l_act_days := LEAST(p_period_end_date,i.Information_2)-GREATEST(p_period_start_date,i.Information_1) + 1;
            l_act_days := p_period_end_date - p_period_start_date + 1;
            l_days := LEAST(p_period_end_date,i.Information_2)-GREATEST(p_period_start_date,i.Information_1) + 1;
            IF p_contract_type = 'PART_TIME' THEN
                l_days := get_working_time(p_assignment_id
                                          ,p_business_group_id
                                          ,p_period_start_date
                                          ,p_period_end_date
                                          ,l_tmp_days
                                          ,l_tmp_hours);
            END IF;
            -- If calculated days are more then the no of days employee is supposed to work
            -- to handle 31 days
            IF l_days > p_tot_days THEN
                l_days := p_tot_days;
            END IF;
            -- If calculated days are for entire period
            -- to handle 28 days
            IF l_days = l_act_days THEN
                l_days := p_tot_days;
            END IF;
            hr_utility.trace('~~----l_days '|| l_days);
            IF p_context = 'ES_WC_PARTIAL_UNEMPLOYMENT' THEN
                hr_utility.trace('~~----PU Percentage '|| i.Information_3);
                l_days := l_days * fnd_number.canonical_to_number(i.Information_3)/100;
            END IF;
        END IF;
        l_total_days := l_total_days + l_days;
    END LOOP;
    hr_utility.trace('~~Total Days '|| l_total_days);
    RETURN l_total_days;
    --
END get_org_context_info;
--
--------------------------------------------------------------------------------
-- WRITE_CAC_EPIGRAPH_CHANGE_TABLE
--------------------------------------------------------------------------------
FUNCTION write_cac_epigraph_chg_table(p_assignment_id       NUMBER
                                     ,p_effective_date      DATE
                                     ,p_business_group_id  NUMBER
                                     ,p_period_start_date   DATE
                                     ,p_period_end_date     DATE
                                     ,p_contract_type       VARCHAR2
                                     ,p_hire_date           DATE
                                     ,p_end_date            DATE) RETURN NUMBER IS
--
    CURSOR c_get_element_entries(c_assignment_id NUMBER
                                ,c_start_date    DATE
                                ,c_end_date      DATE) IS
    SELECT pee.element_entry_id
          ,GREATEST(pee.effective_start_date, c_start_date) start_date
          ,LEAST(pee.effective_end_date, c_end_date) end_date
          ,min(decode(piv.name, 'SS Epigraph 126', nvl(peev.screen_entry_value,'x'), null)) epigraph_126
          ,min(decode(piv.name, 'SS Epigraph 114', nvl(peev.screen_entry_value,'x'), null)) epigraph_114
          ,min(decode(piv.name, 'SS Epigraph Code', nvl(peev.screen_entry_value,'x'), null)) epigraph_code
          ,min(decode(piv2.name, 'Work Center CAC', nvl(peev2.screen_entry_value,0), null)) work_center_cac
    FROM   pay_element_entries_f  pee
          ,pay_element_entries_f  pee2
          ,pay_element_types_f pet
          ,pay_element_types_f pet2
          ,pay_input_values_f piv
          ,pay_input_values_f piv2
          ,pay_element_entry_values_f  peev
          ,pay_element_entry_values_f  peev2
    WHERE  pee.assignment_id = c_assignment_id
    AND    pee2.assignment_id = pee.assignment_id
    AND    pet.element_name = 'Social Security Details'
    AND    pet2.element_name = 'Multiple Employment Details'
    AND    pet.legislation_code = 'ES'
    AND    pet2.legislation_code = 'ES'
    AND    piv.legislation_code = 'ES'
    AND    piv2.legislation_code = 'ES'
    AND    pee.element_type_id = pet.element_type_id
    AND    pee2.element_type_id = pet2.element_type_id
    AND    piv.element_type_id = pet.element_type_id
    AND    piv2.element_type_id = pet2.element_type_id
    AND    peev.input_value_id = piv.input_value_id
    AND    peev2.input_value_id = piv2.input_value_id
    AND    peev.element_entry_id = pee.element_entry_id
    AND    peev2.element_entry_id = pee2.element_entry_id
    AND    pee.effective_start_date = peev.effective_start_date
    AND    pee2.effective_start_date = peev2.effective_start_date
    AND    pee.effective_end_date = peev.effective_end_date
    AND    pee2.effective_end_date = peev2.effective_end_date
    AND    pee2.effective_start_date = pee.effective_start_date
    AND    pee2.effective_end_date = pee.effective_end_date
    AND    (pee.effective_start_date <= c_end_date
            AND pee.effective_end_date >= c_start_date)
    AND    c_start_date BETWEEN pet.effective_start_date AND pet.effective_end_date
    AND    c_start_date BETWEEN piv.effective_start_date AND piv.effective_end_date
    AND    c_start_date BETWEEN pet2.effective_start_date AND pet2.effective_end_date
    AND    c_start_date BETWEEN piv2.effective_start_date AND piv2.effective_end_date
    GROUP BY pee.element_entry_id
          ,pee.effective_start_date
          ,pee.effective_end_date;
    --
    lctr NUMBER;
    l_no_ptm_days NUMBER;
    l_no_ptm_hours NUMBER;
    l_no_partial_strike_days NUMBER;
    l_no_partial_strike_hours NUMBER;
    l_active_without_pay_days NUMBER;
    l_active_without_pay_hours NUMBER;
    l_td_days NUMBER;
    l_tmp NUMBER;
    l_chk_work_pattern VARCHAR2(1);
    l_m_days NUMBER;
    l_tot_rec_days NUMBER;
    l_par_days NUMBER;
    l_ptm_days NUMBER;
    l_adoption_days NUMBER;
    l_tot_days NUMBER;
    l_rec_days NUMBER;
    l_tot_hours NUMBER;
    l_days_worked NUMBER;
    l_rec_hours NUMBER;
    p_Contribution_group VARCHAR2(10);
    p_work_center NUMBER;
    l_pu_days NUMBER;
    l_act_days NUMBER;
    l_tot_leave NUMBER;
    --
    CURSOR csr_get_assign_info(c_assignment_id  NUMBER
                              ,c_effective_date DATE) IS
    SELECT segment5
          ,segment2
    FROM   per_all_assignments_f paaf
          ,hr_soft_coding_keyflex scl
    WHERE  paaf.assignment_id = c_assignment_id
    AND    paaf.soft_coding_keyflex_id = scl.soft_coding_keyflex_id
    AND    c_effective_date between paaf.effective_start_date and paaf.effective_end_date;
    --
BEGIN
    --
    cac_epigraph_change.DELETE;
    lctr := 0;
    GIndex := 1;
    l_tot_rec_days := 0;
    l_act_days := p_period_end_date - p_period_start_date +1;
    --
    FOR i IN c_get_element_entries(p_assignment_id,p_period_start_date,p_period_end_date) LOOP
        --
        l_tmp := get_input_value(p_assignment_id
                                ,p_effective_date
                                ,l_no_ptm_days
                                ,l_no_ptm_hours
                                ,l_no_partial_strike_days
                                ,l_no_partial_strike_hours
                                ,l_active_without_pay_days
                                ,l_active_without_pay_hours
                                ,i.start_date
                                ,i.end_date
                                ,i.work_center_cac
                                ,i.epigraph_code
                                ,p_period_end_date);
        --
        OPEN  csr_get_assign_info(p_assignment_id,i.end_date);
        FETCH csr_get_assign_info into p_Contribution_group,p_work_center;
        CLOSE csr_get_assign_info;
        --
        l_rec_days := i.end_date - i.start_date + 1;
        IF p_contract_type = 'FULL_TIME' THEN
            l_tot_rec_days := i.end_date - p_period_start_date + 1;
            IF TO_NUMBER(p_Contribution_group) >= 1 AND TO_NUMBER(p_Contribution_group) <= 7 THEN
                l_tot_days := 30;
                l_tot_rec_days := i.end_date - p_period_start_date + 1;
                IF (p_hire_date > p_period_start_date AND p_hire_date <= p_period_end_date)
                  OR (p_end_date >= p_period_start_date AND p_end_date < p_period_end_date) THEN
                     l_tot_rec_days := LEAST(i.end_date,p_end_date) - GREATEST(p_period_start_date,p_hire_date) + 1;
                     l_tot_days := LEAST(p_period_end_date,p_end_date) - GREATEST(p_period_start_date,p_hire_date) + 1;
                END IF;
            ELSIF TO_NUMBER(p_Contribution_group) >= 8 AND TO_NUMBER(p_Contribution_group) <= 11 THEN
                l_tot_days := p_period_end_date - p_period_start_date + 1;
            END IF;
            l_chk_work_pattern := 'N';
            IF i.end_date = p_period_end_date THEN
                l_rec_days := l_rec_days - (l_tot_rec_days - l_tot_days);
            END IF;
        ELSE
           /* Calculate the total working days using Work Pattern */
           l_tmp :=  get_working_time(p_assignment_id
                                     ,p_business_group_id
                                     ,p_period_start_date
                                     ,p_period_end_date
                                     ,l_tot_days
                                     ,l_tot_hours);
            l_tmp :=  get_working_time(p_assignment_id
                                     ,p_business_group_id
                                     ,i.start_date
                                     ,i.end_date
                                     ,l_rec_days
                                     ,l_rec_hours);
            l_chk_work_pattern := 'Y';
        END IF;
        --
        l_pu_days := get_org_context_info(p_assignment_id,p_business_group_id,p_work_center,'ES_WC_PARTIAL_UNEMPLOYMENT',i.start_date,i.end_date,l_tot_days,p_contract_type);
        l_td_days := get_absence_days(p_assignment_id,p_business_group_id,i.end_date,i.start_date,i.end_date,'TD',l_chk_work_pattern);
        l_m_days := get_absence_days(p_assignment_id,p_business_group_id,i.end_date,i.start_date,i.end_date,'M',l_chk_work_pattern);
        l_par_days := get_absence_days(p_assignment_id,p_business_group_id,i.end_date,i.start_date,i.end_date,'PAR',l_chk_work_pattern);
        l_ptm_days := get_absence_days(p_assignment_id,p_business_group_id,i.end_date,i.start_date,i.end_date,'PTM',l_chk_work_pattern);
        l_adoption_days := get_absence_days(p_assignment_id,p_business_group_id,i.end_date,i.start_date,i.end_date,'IE_AL',l_chk_work_pattern);
        --
        l_m_days := l_m_days + l_adoption_days;
        --
        l_no_ptm_days := l_no_ptm_days + l_m_days + l_par_days + l_ptm_days ;
        l_tot_leave := nvl(l_td_days,0) + nvl(l_no_ptm_days,0) + nvl(l_no_partial_strike_days,0) + nvl(l_active_without_pay_days,0) + nvl(l_pu_days,0);
        If l_tot_leave = l_act_days THEN
          l_tot_leave := l_rec_days;
        END IF;
        l_days_worked := GREATEST(l_rec_days - l_tot_leave,0);
        --
        --
        IF lctr = 0 THEN
            lctr := lctr + 1;
            cac_epigraph_change(lctr).cac := i.work_center_cac;
            cac_epigraph_change(lctr).epigraph := i.epigraph_code;
            cac_epigraph_change(lctr).epigraph_114 := i.epigraph_114;
            cac_epigraph_change(lctr).epigraph_126 := i.epigraph_126;
            cac_epigraph_change(lctr).days := l_rec_days;
            cac_epigraph_change(lctr).start_date := i.start_date;
            cac_epigraph_change(lctr).end_date := i.end_date;
            cac_epigraph_change(lctr).no_ptm_days := l_no_ptm_days;
            cac_epigraph_change(lctr).no_ptm_hours := l_no_ptm_hours;
            cac_epigraph_change(lctr).no_partial_strike_days := l_no_partial_strike_days;
            cac_epigraph_change(lctr).no_partial_strike_hours := l_no_partial_strike_hours;
            cac_epigraph_change(lctr).active_without_pay_days := l_active_without_pay_days;
            cac_epigraph_change(lctr).active_without_pay_hours := l_active_without_pay_hours;
            cac_epigraph_change(lctr).days_worked := l_days_worked;
            cac_epigraph_change(lctr).no_td_days := l_td_days;
            cac_epigraph_change(lctr).Tot_Days := l_tot_days;
            cac_epigraph_change(lctr).PU_Days := l_pu_days;


            IF i.epigraph_114 = 'Y' THEN
                cac_epigraph_change(lctr).epigraph := '114';
            END IF;
            FND_FILE.NEW_LINE(fnd_file.log, 1);
            FND_FILE.PUT(fnd_file.log,rpad(i.work_center_cac,10));
            FND_FILE.PUT(fnd_file.log,rpad(i.epigraph_code,10));
            FND_FILE.PUT(fnd_file.log,rpad(i.epigraph_114,10));
            FND_FILE.PUT(fnd_file.log,rpad(i.epigraph_126,10));
            FND_FILE.PUT(fnd_file.log,rpad(to_char(l_rec_days),10));
            FND_FILE.PUT(fnd_file.log,rpad(to_char(i.start_date,'dd-mm-yyyy'),10));
            FND_FILE.PUT(fnd_file.log,rpad(to_char(i.end_date,'dd-mm-yyyy'),10));
            FND_FILE.PUT(fnd_file.log,rpad(to_char(l_days_worked),5));
            FND_FILE.PUT(fnd_file.log,rpad(to_char(l_td_days),5));
            FND_FILE.PUT(fnd_file.log,rpad(to_char(l_tot_days),5));
            FND_FILE.PUT(fnd_file.log,rpad(to_char(l_pu_days),5));
        ELSE
            IF NOT cac_epigraph_change.exists(lctr) THEN
                RETURN (-1);
            END IF;
            IF cac_epigraph_change(lctr).cac <> i.work_center_cac
               OR cac_epigraph_change(lctr).epigraph <> i.epigraph_code
               OR cac_epigraph_change(lctr).epigraph_114 <> i.epigraph_114
               OR cac_epigraph_change(lctr).epigraph_126 <> i.epigraph_126 THEN
                lctr := lctr + 1;
                cac_epigraph_change(lctr).cac := i.work_center_cac;
                cac_epigraph_change(lctr).epigraph := i.epigraph_code;
                cac_epigraph_change(lctr).epigraph_114 := i.epigraph_114;
                IF i.epigraph_114 = 'Y' THEN
                    cac_epigraph_change(lctr).epigraph := '114';
                END IF;
                cac_epigraph_change(lctr).epigraph_126 := i.epigraph_126;
                cac_epigraph_change(lctr).days := i.end_date - i.start_date + 1;
                cac_epigraph_change(lctr).start_date := i.start_date;
                cac_epigraph_change(lctr).end_date := i.end_date;
                cac_epigraph_change(lctr).no_ptm_days := l_no_ptm_days;
                cac_epigraph_change(lctr).no_ptm_hours := l_no_ptm_hours;
                cac_epigraph_change(lctr).no_partial_strike_days := l_no_partial_strike_days;
                cac_epigraph_change(lctr).no_partial_strike_hours := l_no_partial_strike_hours;
                cac_epigraph_change(lctr).active_without_pay_days := l_active_without_pay_days;
                cac_epigraph_change(lctr).active_without_pay_hours := l_active_without_pay_hours;
                cac_epigraph_change(lctr).days_worked := l_days_worked;
                cac_epigraph_change(lctr).no_td_days := l_td_days;
                cac_epigraph_change(lctr).Tot_Days := l_tot_days;
                cac_epigraph_change(lctr).PU_Days := l_pu_days;
            ELSE
                cac_epigraph_change(lctr).days := i.end_date - cac_epigraph_change(lctr).start_date + 1;
                cac_epigraph_change(lctr).end_date := i.end_date;
                cac_epigraph_change(lctr).no_ptm_days := cac_epigraph_change(lctr).no_ptm_days + l_no_ptm_days;
                cac_epigraph_change(lctr).no_ptm_hours := cac_epigraph_change(lctr).no_ptm_hours + l_no_ptm_hours;
                cac_epigraph_change(lctr).no_partial_strike_days := cac_epigraph_change(lctr).no_partial_strike_days + l_no_partial_strike_days;
                cac_epigraph_change(lctr).no_partial_strike_hours := cac_epigraph_change(lctr).no_partial_strike_hours + l_no_partial_strike_hours;
                cac_epigraph_change(lctr).active_without_pay_days := cac_epigraph_change(lctr).active_without_pay_days + l_active_without_pay_days;
                cac_epigraph_change(lctr).active_without_pay_hours :=cac_epigraph_change(lctr).active_without_pay_hours +l_active_without_pay_hours;
                cac_epigraph_change(lctr).days_worked := l_days_worked;
                cac_epigraph_change(lctr).no_td_days := l_td_days;
                cac_epigraph_change(lctr).Tot_Days := l_tot_days;
                cac_epigraph_change(lctr).PU_Days := l_pu_days;
            END IF;
            FND_FILE.NEW_LINE(fnd_file.log, 1);
            FND_FILE.PUT(fnd_file.log,rpad(i.work_center_cac,10));
            FND_FILE.PUT(fnd_file.log,rpad(i.epigraph_code,10));
            FND_FILE.PUT(fnd_file.log,rpad(i.epigraph_114,10));
            FND_FILE.PUT(fnd_file.log,rpad(i.epigraph_126,10));
            FND_FILE.PUT(fnd_file.log,rpad(to_char(l_rec_days),10));
            FND_FILE.PUT(fnd_file.log,rpad(to_char(i.start_date,'dd-mm-yyyy'),10));
            FND_FILE.PUT(fnd_file.log,rpad(to_char(i.end_date,'dd-mm-yyyy'),10));
            FND_FILE.PUT(fnd_file.log,rpad(to_char(l_days_worked),5));
            FND_FILE.PUT(fnd_file.log,rpad(to_char(l_td_days),5));
            FND_FILE.PUT(fnd_file.log,rpad(to_char(l_tot_days),5));
            FND_FILE.PUT(fnd_file.log,rpad(to_char(l_pu_days),5));
        END IF;
    END LOOP;
    RETURN lctr;
    --
END write_cac_epigraph_chg_table;
--
--------------------------------------------------------------------------------
-- READ_CAC_EPIGRAPH_CHG_TABLE
--------------------------------------------------------------------------------
FUNCTION read_cac_epigraph_chg_table(p_assignment_id            IN NUMBER
                                    ,p_cac                      IN OUT NOCOPY VARCHAR2
                                    ,p_epigraph                 IN OUT NOCOPY VARCHAR2
                                    ,p_epigraph_114             IN OUT NOCOPY VARCHAR2
                                    ,p_epigraph_126             IN OUT NOCOPY VARCHAR2
                                    ,p_days                     IN OUT NOCOPY NUMBER
                                    ,p_start_date               IN OUT NOCOPY DATE
                                    ,p_end_date                 IN OUT NOCOPY DATE
                                    ,p_no_ptm_days              IN OUT NOCOPY NUMBER
                                    ,p_no_ptm_hours             IN OUT NOCOPY NUMBER
                                    ,p_no_partial_strike_days   IN OUT NOCOPY NUMBER
                                    ,p_no_partial_strike_hours  IN OUT NOCOPY NUMBER
                                    ,p_active_without_pay_days  IN OUT NOCOPY NUMBER
                                    ,p_active_without_pay_hours IN OUT NOCOPY NUMBER
                                    ,p_curr_index               IN OUT NOCOPY NUMBER
                                    ,p_next_epigraph            IN OUT NOCOPY VARCHAR2
                                    ,p_next_cac                 IN OUT NOCOPY VARCHAR2
                                    ,p_days_worked              IN OUT NOCOPY NUMBER
                                    ,p_td_days                  IN OUT NOCOPY NUMBER
                                    ,p_tot_days                 IN OUT NOCOPY NUMBER
                                    ,p_pu_days                  IN OUT NOCOPY NUMBER) RETURN NUMBER
IS
--
BEGIN
    --
    IF GIndex = 0 and cac_epigraph_change.LAST <> 0 THEN
       GIndex := 1;
    END IF;
    IF NOT cac_epigraph_change.exists(GIndex) THEN
       hr_utility.trace('~~RETRUN GIndex'||GIndex);
        RETURN -1;
    END IF;

    p_epigraph                 := cac_epigraph_change(GIndex).epigraph;
    p_epigraph_114             := cac_epigraph_change(GIndex).epigraph_114;
    p_epigraph_126             := cac_epigraph_change(GIndex).epigraph_126;
    p_days                     := cac_epigraph_change(GIndex).days;
    p_start_date               := cac_epigraph_change(GIndex).start_date;
    p_end_date                 := cac_epigraph_change(GIndex).end_date;
    p_no_ptm_days              := nvl(cac_epigraph_change(GIndex).no_ptm_days,0);
    p_no_ptm_hours             := nvl(cac_epigraph_change(GIndex).no_ptm_hours,0);
    p_no_partial_strike_days   := nvl(cac_epigraph_change(GIndex).no_partial_strike_days,0);
    p_no_partial_strike_hours  := nvl(cac_epigraph_change(GIndex).no_partial_strike_hours,0);
    p_active_without_pay_days  := nvl(cac_epigraph_change(GIndex).active_without_pay_days,0);
    p_active_without_pay_hours := nvl(cac_epigraph_change(GIndex).active_without_pay_hours,0);
    p_days_worked              := cac_epigraph_change(GIndex).days_worked;
    p_td_days                  := cac_epigraph_change(GIndex).no_td_days;
    p_tot_days                 := cac_epigraph_change(GIndex).Tot_Days;
    p_pu_days                  := cac_epigraph_change(GIndex).PU_Days;
    p_curr_index               := GIndex;

    hr_utility.trace('~~Read PL/SQl Tablep_epigraph '||p_epigraph);
    hr_utility.trace('~~--p_epigraph     '||p_epigraph);
    hr_utility.trace('~~--p_epigraph_114 '||p_epigraph_114);
    hr_utility.trace('~~--p_epigraph_126 '||p_epigraph_126);
    hr_utility.trace('~~--p_start_date   '||p_start_date);
    hr_utility.trace('~~--p_end_date     '||p_end_date);
    hr_utility.trace('~~--p_no_ptm_days  '||p_no_ptm_days);
    IF cac_epigraph_change(GIndex).cac = 0 THEN
      p_cac          := '';
    ELSE
      p_cac          := cac_epigraph_change(GIndex).cac;
    END IF;
    --
    IF GIndex = cac_epigraph_change.LAST THEN
       GIndex  := 0;
       hr_utility.trace('~~RETURN GIndex'||GIndex);
       p_next_epigraph := 'x';
       p_next_cac := 'x';
       RETURN GIndex;
    END IF;
    --
    hr_utility.trace('~~RETURN GIndex'||GIndex);
    GIndex := GIndex + 1;
    p_next_epigraph := cac_epigraph_change(GIndex).epigraph;
    p_next_cac := cac_epigraph_change(GIndex).cac;
    Return GIndex;
    --
END read_cac_epigraph_chg_table;
--------------------------------------------------------------------------------
-- READ_TABLE_INDEX
--------------------------------------------------------------------------------
FUNCTION read_table_index(p_next_epigraph            IN OUT NOCOPY VARCHAR2
                         ,p_next_cac                 IN OUT NOCOPY VARCHAR2)  RETURN NUMBER IS
BEGIN
    --
    IF GIndex <> 0 THEN
      p_next_epigraph := cac_epigraph_change(GIndex).epigraph;
      p_next_cac := cac_epigraph_change(GIndex).cac;
    ELSE
      p_next_epigraph := 'x';
      p_next_cac := 'x';
    END IF;
    RETURN (GIndex);
    --
END read_table_index;
--------------------------------------------------------------------------------
-- READ_TABLE_INDEX_VALUES
--------------------------------------------------------------------------------
FUNCTION read_table_index_values(p_assignment_id            IN NUMBER
                                ,p_index                    IN NUMBER
                                ,p_cac                      IN OUT NOCOPY VARCHAR2
                                ,p_epigraph                 IN OUT NOCOPY VARCHAR2
                                ,p_epigraph_114             IN OUT NOCOPY VARCHAR2
                                ,p_epigraph_126             IN OUT NOCOPY VARCHAR2
                                ,p_days                     IN OUT NOCOPY NUMBER
                                ,p_start_date               IN OUT NOCOPY DATE
                                ,p_end_date                 IN OUT NOCOPY DATE
                                ,p_no_ptm_days              IN OUT NOCOPY NUMBER
                                ,p_no_ptm_hours             IN OUT NOCOPY NUMBER
                                ,p_no_partial_strike_days   IN OUT NOCOPY NUMBER
                                ,p_no_partial_strike_hours  IN OUT NOCOPY NUMBER
                                ,p_active_without_pay_days  IN OUT NOCOPY NUMBER
                                ,p_active_without_pay_hours IN OUT NOCOPY NUMBER
                                ,p_days_worked              IN OUT NOCOPY NUMBER
                                ,p_td_days                  IN OUT NOCOPY NUMBER
                                ,p_tot_days                 IN OUT NOCOPY NUMBER
                                ,p_pu_days                  IN OUT NOCOPY NUMBER) RETURN NUMBER
IS
    --
BEGIN
    --
   IF NOT cac_epigraph_change.exists(p_index) THEN
       hr_utility.trace('~~RETRUN GIndex'||GIndex);
        RETURN -1;
    END IF;
    --
    p_epigraph                 := cac_epigraph_change(p_index).epigraph;
    p_epigraph_114             := cac_epigraph_change(p_index).epigraph_114;
    p_epigraph_126             := cac_epigraph_change(p_index).epigraph_126;
    p_days                     := cac_epigraph_change(p_index).days;
    p_start_date               := cac_epigraph_change(p_index).start_date;
    p_end_date                 := cac_epigraph_change(p_index).end_date;
    p_no_ptm_days              := cac_epigraph_change(p_index).no_ptm_days;
    p_no_ptm_hours             := cac_epigraph_change(p_index).no_ptm_hours;
    p_no_partial_strike_days   := cac_epigraph_change(p_index).no_partial_strike_days;
    p_no_partial_strike_hours  := cac_epigraph_change(p_index).no_partial_strike_hours;
    p_active_without_pay_days  := cac_epigraph_change(p_index).active_without_pay_days;
    p_active_without_pay_hours := cac_epigraph_change(p_index).active_without_pay_hours;
    p_days_worked              := cac_epigraph_change(p_index).days_worked;
    p_td_days                  := cac_epigraph_change(p_index).no_td_days;
    p_tot_days                 := cac_epigraph_change(p_index).Tot_Days;
    p_pu_days                  := cac_epigraph_change(p_index).PU_Days;
    IF cac_epigraph_change(p_index).cac = 0 THEN
      p_cac          := '';
    ELSE
      p_cac          := cac_epigraph_change(p_index).cac;
    END IF;
    --
    RETURN 0;
    --
END read_table_index_values;
--
--------------------------------------------------------------------------------
-- GET_PREV_BASE
--------------------------------------------------------------------------------
FUNCTION get_prev_base(p_assignment_action_id   IN NUMBER
                      ,p_balance_name           IN VARCHAR2
                      ,p_database_item_suffix   IN VARCHAR2
                      ,p_period_start_date      IN DATE
                      ,p_no_month               IN NUMBER
                      ,p_flag                   IN VARCHAR2
                      ,p_context                IN VARCHAR2
                      ,p_context_val            IN VARCHAR2
                      ,p_ss_days                IN OUT NOCOPY NUMBER
                      ,p_days                   IN OUT NOCOPY NUMBER) RETURN NUMBER
IS
    --
    CURSOR get_prev_periods_dates (c_assignment_action_id NUMBER
                                  ,c_period_start_date    DATE) IS
     SELECT   ptp.start_date                    start_date
             ,ptp.end_date                      end_date
             ,ppa.action_type
             ,max(paa2.assignment_action_id)    assignment_action_id
     FROM     pay_assignment_actions                   paa1
             ,per_all_assignments_f                    paaf1
             ,per_all_assignments_f                    paaf2
             ,pay_assignment_actions                   paa2
             ,pay_payroll_actions                      ppa
             ,pay_payroll_actions                      ppa1
             ,per_time_periods                         ptp
             ,per_time_period_types                    ptpt
     WHERE    paa1.assignment_action_id      = c_assignment_action_id
     AND      ppa1.payroll_action_id         = paa1.payroll_action_id
     AND      ppa1.business_group_id         = paaf1.business_group_id
     AND      paaf1.assignment_id            = paa1.assignment_id
     AND      paaf2.person_id                = paaf1.person_id
     AND      paaf2.business_group_id        = paaf1.business_group_id
     AND      paa2.assignment_id             = paaf2.assignment_id
     AND      paa2.tax_unit_id               = paa1.tax_unit_id
     AND      paa2.source_action_id          IS NULL
     AND      ppa.payroll_action_id          = paa2.payroll_action_id
     AND      ppa.action_type                IN ('R','Q','I','B')
     AND      ppa.action_status              IN ('C','U')
     AND      ppa.business_group_id          = paaf2.business_group_id
     AND      ptp.payroll_id                 = ppa.payroll_id
     AND      ptp.period_type                = ptpt.period_type
     AND      ptp.start_date                 < c_period_start_date
     AND      ppa.date_earned   BETWEEN ptp.start_date              AND   ptp.end_date
     AND      ptp.end_date      BETWEEN paaf1.effective_start_date  AND   paaf1.effective_end_date
     AND      ptp.end_date      BETWEEN paaf2.effective_start_date  AND   paaf2.effective_end_date
     GROUP BY ptp.start_date, ptp.end_date, ppa.action_type
     ORDER BY 1 desc;
/*  SELECT ptp.start_date start_date
          ,ptp.end_date end_date
          ,ppa.action_type
          ,MAX(paa2.assignment_action_id) assignment_action_id
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
    AND   ppa.action_status             IN('C','U')
    AND   ptp.end_date BETWEEN paaf1.effective_start_date
                                        AND paaf1.effective_end_date
    AND   ptp.end_date BETWEEN paaf2.effective_start_date
                                        AND paaf2.effective_end_date
    GROUP BY ptp.start_date, ptp.end_date, ppa.action_type
    ORDER BY 1 desc;
*/
    --
    CURSOR get_legal_employer_id(c_work_center_id NUMBER) IS
    SELECT  hoi.organization_id
    FROM    hr_organization_information hoi
    WHERE   hoi.org_information1         = c_work_center_id
    AND     hoi.org_information_context  = 'ES_WORK_CENTER_REF';
    --
    l_def_bal_id          NUMBER;
    l_days_def_bal_id     NUMBER;
    l_amount              NUMBER;
    l_ctr                 NUMBER;
    l_cnt                 NUMBER;
    l_start_date          DATE;
    l_legal_employer_id   hr_All_organization_units.organization_id%TYPE;
    l_amt                 NUMBER;
    l_date                DATE;
    l_days                NUMBER;
    --
BEGIN
    --
    hr_utility.trace('~~Entering pay_es_ss_calculation.get_prev_salary');
    l_def_bal_id := get_defined_bal_id(p_balance_name, p_database_item_suffix);
    l_days_def_bal_id := get_defined_bal_id('Social Security Days', p_database_item_suffix);
    hr_utility.trace('~~~~ p_balance_name'||p_balance_name);
    hr_utility.trace('~~~~ p_database_item_suffix'||p_database_item_suffix);
    hr_utility.trace('~~~~ l_def_bal_id'||l_def_bal_id);
    l_amount := 0;
    l_amt := 0;
    l_days := 0;
    l_ctr := 0;
    l_cnt := 0;
    p_days := 0;
    p_ss_days := 0;
    l_date := to_date('01-01-0001','dd-mm-yyyy');
    --
    IF p_context = 'TAX_UNIT_ID' THEN
        OPEN  get_legal_employer_id(to_number(p_context_val));
        FETCH get_legal_employer_id INTO l_legal_employer_id;
        CLOSE get_legal_employer_id;
        pay_balance_pkg.set_context('TAX_UNIT_ID', l_legal_employer_id);
        hr_utility.trace('~~~~ Setting TAX_UNIT_ID Context '||l_legal_employer_id);
    END IF;
    --
    hr_utility.trace('~~~~ Start loop  p_period_start_date '||p_period_start_date);
    hr_utility.trace('~~~~ p_assignment_action_id '||p_assignment_action_id);
    FOR i IN get_prev_periods_dates( p_assignment_action_id, p_period_start_date) LOOP
        --
        IF l_date = i.start_date AND l_days <> 0 AND l_amt <> 0 THEN
            NULL;
        ELSE
            IF l_date <> i.start_date THEN
                l_ctr := l_ctr + 1;
                l_days := 0;
                l_amt := 0;
            END IF;
            hr_utility.trace('~~~~ Inside loop  p_period_start_date '||p_period_start_date);
            hr_utility.trace('~~~~ p_assignment_action_id '||p_assignment_action_id);
            IF l_days = 0 THEN
                l_days := pay_balance_pkg.get_value(l_days_def_bal_id, i.assignment_action_id);
            END IF;
            IF l_days <> 0 THEN
              p_ss_days := p_ss_days + l_days;
              l_amt := pay_balance_pkg.get_value(l_def_bal_id, i.assignment_action_id);
              l_amount := l_amount + l_amt;
              IF l_amt <> 0 THEN
                  l_cnt := l_cnt + 1;
              END IF;
            END IF;
            hr_utility.trace('~~~~ Inside loop  start_date '||i.start_date);
            hr_utility.trace('~~~~ assignment_action_id '||i.assignment_action_id);
            hr_utility.trace('~~~~ l_ctr '||l_ctr);
            hr_utility.trace('~~~~ l_cnt '||l_cnt);
            hr_utility.trace('~~~~ l_amt '||l_amt);
            hr_utility.trace('~~~~ l_days '||l_days);
            hr_utility.trace('~~~~ l_amount '||l_amount);
            hr_utility.trace('~~~~ p_ss_days '||p_ss_days);
            hr_utility.trace('~~~~ p_no_month '||p_no_month);
            IF (l_days <> 0)OR p_flag = 'N' THEN
                p_days := p_days + last_day(i.start_date) - last_day(add_months(i.start_date,-1));
            END IF;
            IF l_ctr >= p_no_month THEN
                IF (l_cnt = p_no_month)OR p_flag = 'N' THEN
                    RETURN l_amount;
                /*ELSE
                    l_ctr := l_ctr - 1;*/
                END IF;
            END IF;
        END IF;
    END LOOP;
    hr_utility.trace('~~Exiting pay_es_ss_calculation.get_prev_salary');
    RETURN l_amount;
    --
END get_prev_base;
--
END pay_es_ss_calculation;

/
