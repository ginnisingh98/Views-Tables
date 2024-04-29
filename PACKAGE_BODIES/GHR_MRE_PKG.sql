--------------------------------------------------------
--  DDL for Package Body GHR_MRE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_MRE_PKG" AS
/* $Header: ghmreexe.pkb 120.8.12010000.2 2008/08/05 15:07:22 ubhat ship $ */

--
-- Global Declaration
--

g_no        NUMBER         := 0;
g_package   VARCHAR2(32)   := 'GHR_MRE_PKG';
g_proc      VARCHAR2(32)   := null;
g_business_group_id NUMBER := null;
l_log_text  VARCHAR2(2000) := null;
l_mslerrbuf VARCHAR2(2000) := null;

Procedure UPDATE_position_info
     (p_position_data_rec ghr_sf52_pos_UPDATE.position_data_rec_type);

--
-- End Global declaration
--

procedure execute_mre (p_errbuf  out NOCOPY VARCHAR2,
                       p_retcode out NOCOPY NUMBER,
                       p_mass_realignment_id in NUMBER,
                       p_action in VARCHAR2,
                       p_show_vacant_pos in VARCHAR2 default 'NO') is

    cursor child_orgs (cp_org_pos_id   NUMBER,
                       child_fl   VARCHAR2,
                       org_pos_fl VARCHAR2,
                       org_str_id NUMBER) is
        SELECT a.organization_id_child  org_pos_id
        from   per_org_structure_elements a,
               per_org_structure_versions b
        WHERE  a.org_structure_version_id = b.org_structure_version_id
        and    a.org_structure_version_id = org_str_id
        and    child_fl                   = 'Y'
        and    org_pos_fl                 = 'O'
        and    a.org_structure_element_id in
        (
        SELECT org_structure_element_id
        from   per_org_structure_elements
        start  with organization_id_parent     = cp_org_pos_id
        connect by prior organization_id_child = organization_id_parent
        )
        union
        SELECT b.ORGANIZATION_ID  org_pos_id
        from   per_organization_units b
        -- VSM added nvl( .. to the start... clause
        -- enhancement in SELECTion criteria as org_id can be be null [Masscrit.doc]
        WHERE  b.organization_id = nvl(cp_org_pos_id, b.organization_id)
        and    b.business_group_id  = g_business_group_id
        and    org_pos_fl        = 'O'
        union
        SELECT a.subordinate_position_id  org_pos_id
        from   per_pos_structure_elements a,
               per_pos_structure_versions b
        WHERE  a.pos_structure_version_id = b.pos_structure_version_id
        and    a.pos_structure_version_id = org_str_id
        and    child_fl                   = 'Y'
        and    org_pos_fl                 = 'P'
        and    a.pos_structure_element_id in
        (
        SELECT pos_structure_element_id
        from   per_pos_structure_elements
        start  with parent_position_id     = cp_org_pos_id
        connect by prior subordinate_position_id = parent_position_id
        )
        union
        SELECT b.position_id  org_pos_id
        from   hr_positions_f b
        WHERE  b.position_id = cp_org_pos_id
        and    b.business_group_id = g_business_group_id
        and    org_pos_fl        = 'P';

        /*  and child_fl = 'N';*/
     -- Bug 4377361 included EMP_APL for person type condition

    cursor cur_people     (p_org_pos_id       NUMBER,
                           org_pos_fl     VARCHAR2,
                           effective_DATE DATE) is
        SELECT ppf.person_id    PERSON_ID,
               ppf.first_name   FIRST_NAME,
               ppf.last_name    LAST_NAME,
               ppf.middle_names MIDDLE_NAMES,
               ppf.full_name    FULL_NAME,
               ppf.DATE_of_birth DATE_OF_BIRTH,
               ppf.national_identifier NATIONAL_IDENTIFIER,
               paf.position_id  POSITION_ID,
               paf.assignment_id ASSIGNMENT_ID,
               paf.grade_id     GRADE_ID,
               paf.job_id       JOB_ID,
               paf.location_id  LOCATION_ID,
               paf.organization_id ORGANIZATION_ID,
               paf.business_group_id BUSINESS_GROUP_ID,
               punits.name        ORGANIZATION_NAME
        from   per_assignments_f   paf,
               per_people_f        ppf,
               per_person_types    ppt,
               per_organization_units punits
        -- VSM added nvl( .. to the start... clause
        -- enhancement in SELECTion criteria as org_id can be be null [Masscrit.doc]
        WHERE  (paf.organization_id = nvl(p_org_pos_id, paf.organization_id)
               and
               org_pos_fl           = 'O')
        and    ppf.person_id       = paf.person_id
        and    trunc(effective_DATE) between paf.effective_start_DATE
                                  and paf.effective_END_DATE
        and    paf.primary_flag          = 'Y'
        and    paf.assignment_type      <> 'B'
        and    ppf.current_employee_flag = 'Y'
        and    trunc(effective_DATE) between ppf.effective_start_DATE
                                         and ppf.effective_END_DATE
        and    ppf.person_type_id     = ppt.person_type_id
        and    ppt.system_person_type IN ('EMP','EMP_APL')
        and    paf.organization_id    = punits.organization_id
        and    paf.business_group_id  = g_business_group_id
        and    paf.position_id is not null
        union
        SELECT ppf.person_id    PERSON_ID,
               ppf.first_name   FIRST_NAME,
               ppf.last_name    LAST_NAME,
               ppf.middle_names MIDDLE_NAMES,
               ppf.full_name    FULL_NAME,
               ppf.DATE_of_birth DATE_OF_BIRTH,
               ppf.national_identifier NATIONAL_IDENTIFIER,
               paf.position_id  POSITION_ID,
               paf.assignment_id ASSIGNMENT_ID,
               paf.grade_id     GRADE_ID,
               paf.job_id       JOB_ID,
               paf.location_id  LOCATION_ID,
               paf.organization_id ORGANIZATION_ID,
               paf.business_group_id BUSINESS_GROUP_ID,
               punits.name        ORGANIZATION_NAME
        from   per_assignments_f      paf,
               per_people_f           ppf,
               per_person_types       ppt,
               per_organization_units punits
        WHERE  (paf.position_id  = nvl(p_org_pos_id,paf.position_id)
                and
                org_pos_fl       = 'P')
        and    ppf.person_id     = paf.person_id
        and    trunc(effective_DATE) between paf.effective_start_DATE
                                  and paf.effective_END_DATE
        and    paf.primary_flag          = 'Y'
        and    paf.assignment_type      <> 'B'
        and    ppf.current_employee_flag = 'Y'
        and    trunc(effective_DATE) between ppf.effective_start_DATE
                                         and ppf.effective_END_DATE
        and    ppf.person_type_id     = ppt.person_type_id
        and    ppt.system_person_type IN ('EMP','EMP_APL')
        and    paf.organization_id    = punits.organization_id
        and    paf.business_group_id  = g_business_group_id
        and    paf.position_id is not null;

    -- Modified this cursor to unSELECT the eliminated positions
    -- using hr_genral call for bug 3215722
    cursor unassigned_pos (p_org_pos_id       NUMBER,
                           org_pos_fl     VARCHAR2,
                           effective_DATE DATE) is
       SELECT   null PERSON_ID,
               'VACANT' FIRST_NAME,
               'VACANT' LAST_NAME,
               'VACANT' FULL_NAME,
               null     MIDDLE_NAMES,
               null     DATE_OF_BIRTH,
               null     NATIONAL_IDENTIFIER,
               position_id POSITION_ID,
               null     ASSIGNMENT_ID,
               to_NUMBER(null)     GRADE_ID,
               JOB_ID,
               pop.LOCATION_ID,
               pop.ORGANIZATION_ID,
               pop.BUSINESS_GROUP_ID,
               punits.name        ORGANIZATION_NAME,
               pop.availability_status_id
        from   hr_positions_f     pop,
               per_organization_units punits
        WHERE  pop.business_group_id = g_business_group_id
        and  trunc(effective_DATE) between pop.effective_start_DATE and pop.effective_END_DATE
        and  pop.organization_id = punits.organization_id
        and  (pop.organization_id = nvl(p_org_pos_id,pop.organization_id) and org_pos_fl = 'O'
              or
              pop.position_id     = nvl(p_org_pos_id,pop.position_id)     and org_pos_fl = 'P')
        and   not exists
        (
         SELECT 'X'
         FROM   per_people_f p, per_assignments_f a
         WHERE  trunc(effective_DATE) between a.effective_start_DATE and a.effective_END_DATE
           AND    a.primary_flag          = 'Y'
           AND    a.assignment_type      <> 'B'
           AND    p.current_employee_flag = 'Y'
           AND    a.business_group_id = g_business_group_id
           AND    a.person_id         = p.person_id
           AND    a.position_id           = pop.position_id
           AND    trunc(effective_DATE) between p.effective_start_DATE and p.effective_end_DATE
        );

/**** Commented as on 09-DEC_2004 and tuned the sql as above.
        SELECT null PERSON_ID,
               'VACANT' FIRST_NAME,
               'VACANT' LAST_NAME,
               'VACANT' FULL_NAME,
               null     MIDDLE_NAMES,
               null     DATE_OF_BIRTH,
               null     NATIONAL_IDENTIFIER,
               position_id POSITION_ID,
               null     ASSIGNMENT_ID,
               to_NUMBER(null)     GRADE_ID,
               JOB_ID,
               pop.LOCATION_ID,
               pop.ORGANIZATION_ID,
               pop.BUSINESS_GROUP_ID,
               punits.name        ORGANIZATION_NAME,
               pop.availability_status_id
        from   hr_positions_f     pop,
               per_organization_units punits
        WHERE  pop.business_group_id = g_business_group_id
        and  pop.position_id in
        (
            SELECT position_id POSITION_ID
            from   hr_positions_f
            WHERE  (organization_id = nvl(p_org_pos_id,organization_id) and org_pos_fl = 'O'
                or
                    position_id     = nvl(p_org_pos_id,position_id) and org_pos_fl = 'P')
            and    trunc(effective_DATE)
                   between effective_start_DATE and effective_END_DATE
            and    business_group_id = g_business_group_id
              MINUS
            SELECT a.position_id
            from   per_people_f p, per_assignments_f a
            WHERE  (a.organization_id = nvl(p_org_pos_id,organization_id) and org_pos_fl = 'O'
                or
                    a.position_id     = nvl(p_org_pos_id,a.position_id) and org_pos_fl = 'P')
            and    trunc(effective_DATE) between a.effective_start_DATE
                                         and a.effective_END_DATE
            and    a.primary_flag          = 'Y'
            and    a.assignment_type      <> 'B'
            and    p.current_employee_flag = 'Y'
            and    a.business_group_id = g_business_group_id
            and    a.person_id         = p.person_id
            and    a.position_id	   = pop.position_id
            and    trunc(effective_DATE) between p.effective_start_DATE
                                         and p.effective_END_DATE
        )
        and    trunc(effective_DATE)
               between pop.effective_start_DATE and pop.effective_END_DATE
        and    pop.organization_id = punits.organization_id;
******************** Commented as of 09-DEC-2004 ***/
    -- added Join for tables a,p. a.person_id=p.person_id and a.position_id=pop.position_id
    -- Bug 3677516
    cursor c_grade_kff (grd_id NUMBER) is
        SELECT gdf.segment1
              ,gdf.segment2
        from per_grades grd, per_grade_definitions gdf
        WHERE grd.grade_id = grd_id
        and grd.grade_definition_id = gdf.grade_definition_id;

    cursor ghr_mre (p_mass_realignment_id NUMBER) is
        SELECT name,
               effective_DATE,
               old_organization_id,
               new_organization_id,
               status,
               reason,
               org_structure_id,
               office_symbol,
               agency_code_subelement agency_sub_elem_code,
               personnel_office_id,
               -- added this for 3191704
               target_personnel_office_id,
               old_org_structure_version_id  old_organization_structure_id,
               old_position_id,
               old_pos_structure_version_id  old_position_structure_id,
               PA_REQUEST_ID,
               business_group_id
        from   ghr_mass_realignment
        WHERE  mass_realignment_id = p_mass_realignment_id
        for    UPDATE of status nowait;

    -- added this for 3191704
    target_personnel_office_id      ghr_mass_realignment.personnel_office_id%type;

    -- Bug#2651909 Cursor to get OPM Organizational Component of Target Organization
    cursor c_opm_org_component(p_organization_id IN NUMBER) is
        Select org_information4
           from   HR_ORGANIZATION_INFORMATION
           WHERE  organization_id = p_organization_id
             and  ORG_INFORMATION_CONTEXT = 'GHR_US_ORG_REPORTING_INFO';

    l_assignment_id             per_assignments_f.assignment_id%type;
    l_position_id               per_assignments_f.position_id%type;
    l_grade_id                  per_assignments_f.grade_id%type;
    l_asg_extra_info_rec        per_assignment_extra_info%rowtype;
    l_business_group_id         per_assignments_f.business_group_id%type;

    l_position_title            VARCHAR2(300);
    l_position_NUMBER           VARCHAR2(20);
    l_position_seq_no           VARCHAR2(20);

    l_mass_cnt                  NUMBER := 0;
    l_recs_failed               NUMBER := 0;

    l_tenure                    VARCHAR2(35);
    l_annuitant_indicator       VARCHAR2(35);
    l_pay_rate_determinant      VARCHAR2(35);
    l_work_schedule             VARCHAR2(35);
    l_part_time_hour            VARCHAR2(35);
    l_pay_table_id              NUMBER;
    l_pay_plan                  VARCHAR2(30);
    l_grade_or_level            VARCHAR2(30);
    l_step_or_rate              VARCHAR2(30);
    l_pay_basis                 VARCHAR2(30);
    l_location_id               NUMBER;
    l_duty_station_id           NUMBER;
    l_duty_station_desc         ghr_pa_requests.duty_station_desc%type;
    l_duty_station_code         ghr_pa_requests.duty_station_code%type;

    l_check_child               VARCHAR2(2);
    l_check_org_pos             VARCHAR2(2);
    l_avail_status_id           NUMBER;
    -- 3215722
    l_org_pos_id                NUMBER;
    l_org_pos_str_id            NUMBER;

    l_effective_DATE            DATE;
    r_effective_DATE            DATE;

    p_mass_realignment_name     VARCHAR2(80);
    p_old_organization_id       NUMBER;
    p_old_org_structure_id      NUMBER;
    p_old_position_id           NUMBER;
    p_old_pos_structure_id      NUMBER;
    p_new_organization_id       NUMBER;
    p_status                    VARCHAR2(1);
    p_reason                    VARCHAR2(240);
    p_org_structure_id          VARCHAR2(30);
    p_new_org_structure_id      VARCHAR2(30);
    p_office_symbol             VARCHAR2(30);
    p_agency_sub_elem_code      VARCHAR2(30);
    p_personnel_office_id       VARCHAR2(30);
    p_duty_station_id           NUMBER(15);
    p_position_title            VARCHAR2(240);
    p_pay_plan	            VARCHAR2(2);
    p_occ_code                  VARCHAR2(9);
    l_pa_request_id             NUMBER;

    l_personnel_office_id       VARCHAR2(300);
    l_org_structure_id          VARCHAR2(300);
    l_office_symbol             VARCHAR2(30);
    l_occ_series                VARCHAR2(30);
    l_sub_element_code          VARCHAR2(30);

    l_payroll_office_id         VARCHAR2(30);
    l_org_func_code             VARCHAR2(30);
    l_appropriation_code1       VARCHAR2(30);
    l_appropriation_code2       VARCHAR2(30);
    l_position_organization     VARCHAR2(240);

    t_personnel_office_id       VARCHAR2(300);
    t_sub_element_code          VARCHAR2(300);
    t_duty_station_id           NUMBER(15);
    t_duty_station_desc         ghr_pa_requests.duty_station_desc%type;
    t_duty_station_code         ghr_pa_requests.duty_station_code%type;
    t_duty_station_locn_id      NUMBER(15);
    t_office_symbol             VARCHAR2(30);
    t_payroll_office_id         VARCHAR2(30);
    t_org_func_code             VARCHAR2(30);
    t_appropriation_code1       VARCHAR2(30);
    t_appropriation_code2       VARCHAR2(30);
    t_position_organization     VARCHAR2(240);

    l_auo_premium_pay_indicator VARCHAR2(30);
    l_ap_premium_pay_indicator  VARCHAR2(30);
    l_retention_allowance       NUMBER;
    l_supervisory_differential  NUMBER;
    l_staffing_differential     NUMBER;

    l_out_step_or_rate          VARCHAR2(30);
    l_out_pay_rate_determinant  VARCHAR2(30);
    l_PT_eff_start_DATE         DATE;
    l_open_pay_fields           BOOLEAN;
    l_message_set               BOOLEAN;
    l_calculated                BOOLEAN;

    l_old_basic_pay        NUMBER;
    l_old_avail_pay        NUMBER;
    l_old_loc_diff         NUMBER;
    l_tot_old_sal          NUMBER;
    l_old_auo_pay          NUMBER;
    l_old_ADJ_basic_pay    NUMBER;
    l_other_pay            NUMBER;


    l_retention_allow_perc          NUMBER;     ---AVR
    l_new_retention_allowance       NUMBER;     ---AVR
    l_supervisory_diff_perc         NUMBER;     ---AVR
    l_new_supervisory_differential  NUMBER;     ---AVR


    l_new_avail_pay             NUMBER;
    l_new_loc_diff              NUMBER;
    l_tot_new_sal               NUMBER;
    l_new_auo_pay               NUMBER;

    l_new_basic_pay             NUMBER;
    l_new_locality_adj          NUMBER;
    l_new_adj_basic_pay         NUMBER;
    l_new_total_salary          NUMBER;
    l_new_other_pay_amount      NUMBER;
    l_new_au_overtime           NUMBER;
    l_new_availability_pay      NUMBER;

    l_user_table_id             NUMBER;
    l_executive_order_no        VARCHAR2(30);
    l_executive_order_DATE      DATE;

    l_row_cnt                   NUMBER := 0;

    l_sf52_rec                  ghr_pa_requests%rowtype;
    l_lac_sf52_rec              ghr_pa_requests%rowtype;
    l_errbuf                    VARCHAR2(2000);

    l_retcode                   NUMBER;

    l_pos_ei_data               per_position_extra_info%rowtype;
    l_pos_valid_grade_ei_data   per_position_extra_info%rowtype;
    l_pos_grp1_rec              per_position_extra_info%rowtype;
    --l_pos_grp2_rec              per_position_extra_info%rowtype;

    l_pay_calc_in_data          ghr_pay_calc.pay_calc_in_rec_type;
    l_pay_calc_out_data         ghr_pay_calc.pay_calc_out_rec_type;
    l_sel_flg                   VARCHAR2(2);
    l_sel_status                VARCHAR2(32);

    l_first_action_la_code1     VARCHAR2(30);
    l_first_action_la_code2     VARCHAR2(30);

    l_remark_code1              VARCHAR2(30);
    l_remark_code2              VARCHAR2(30);

    ----Pay cap variables
    l_entitled_other_pay        NUMBER;
    l_capped_other_pay          NUMBER;
    l_adj_basic_message         BOOLEAN  := FALSE;
    l_pay_cap_message           BOOLEAN  := FALSE;
    l_temp_retention_allowance  NUMBER;
    l_open_pay_fields_caps      BOOLEAN;
    l_message_set_caps          BOOLEAN;
    l_total_pay_check           VARCHAR2(1);
    l_comment                   VARCHAR2(100);
    l_pay_sel                   VARCHAR2(1) := NULL;


    REC_BUSY                    EXCEPTION;
    pragma EXCEPTION_init(REC_BUSY,-54);

    l_proc                      VARCHAR2(72) :=  g_package || '.execute_mre';
    l_ind                       NUMBER := 0;
    l_dummy                     NUMBER;
    l_break                     VARCHAR2(1) := 'N';
	l_appl_id                   VARCHAR2(20);-- Bug#4114068

    -- Bug 3663808 Variable to store retained grade details
    p_retained_grade    ghr_pay_calc.retained_grade_rec_type;

    CURSOR c_pay_tab_type(p_user_table_id    pay_user_tables.user_table_id%type)
    IS
    SELECT range_or_match
    FROM   pay_user_tables
    WHERE  user_table_id = p_user_table_id;

    l_table_type	VARCHAR2(2);
BEGIN
    p_retcode  := 0;
    pr('Inside execute mre');
    pr('Mass Realignment id is '||p_mass_realignment_id,' Action is '|| p_action);

    g_proc := 'execute_mre';

    hr_utility.set_location('Entering    ' || l_proc,5);
    l_ind := 10;

    BEGIN
        FOR mre IN ghr_mre (p_mass_realignment_id)
        LOOP
            p_mass_realignment_name := mre.name;
            l_effective_DATE        := mre.effective_DATE;
            p_old_organization_id   := mre.old_organization_id;
            p_old_org_structure_id  := mre.old_organization_structure_id;
            p_new_organization_id   := mre.new_organization_id;
            p_status                := mre.status;
            p_reason                := mre.reason;
            p_org_structure_id      := mre.org_structure_id;
            p_office_symbol         := mre.office_symbol;
            p_agency_sub_elem_code  := mre.agency_sub_elem_code;
            p_personnel_office_id   := mre.personnel_office_id;
            -- bug 3191704
            target_personnel_office_id := mre.target_personnel_office_id;
            p_old_position_id       := mre.old_position_id;
            p_old_pos_structure_id  := mre.old_position_structure_id;
            l_pa_request_id         := mre.pa_request_id;
            g_business_group_id     := mre.business_group_id;
            exit;
        END LOOP;
    EXCEPTION
        when REC_BUSY then
            hr_utility.set_location('Mass Realignment is in use',1);
            l_mslerrbuf := 'Error in '||l_proc||'  Sql Err is '|| sqlerrm(sqlcode);
            hr_utility.set_message(8301, 'GHR_38477_LOCK_ON_MRE');
            hr_utility.raise_error;
        when others then
            hr_utility.set_location
            ('Error in '||l_proc||' Sql err is '||sqlerrm(sqlcode),1);
            l_mslerrbuf := 'Error in '||l_proc||'  Sql Err is '|| sqlerrm(sqlcode);
            raise mass_error;
    END;

    IF UPPER(p_action) = 'CREATE' then
        ghr_mto_int.set_log_program_name('GHR_MRE_PKG');
    ELSE
        ghr_mto_int.set_log_program_name('MRE_'||p_mass_realignment_name);
    END IF;

l_ind := 20;
    IF UPPER(p_action) = 'CREATE' then
        if l_pa_request_id is null then
            hr_utility.set_message(8301, 'GHR_38567_SELECT_LAC_REMARKS');
            hr_utility.raise_error;
        END IF;
    END IF;

    ghr_msl_pkg.get_lac_dtls(l_pa_request_id,
                             l_lac_sf52_rec);

    --purge_old_data(p_mass_realignment_id);

l_ind := 30;

    hr_utility.set_location('After fetch mre '||to_char(l_effective_DATE),1);

    if p_old_organization_id is not null then
        l_check_org_pos  := 'O';
        l_org_pos_id     := p_old_organization_id;
        l_org_pos_str_id := p_old_org_structure_id;
        if p_old_org_structure_id is null then
            l_check_child := 'N';
        ELSE
            l_check_child := 'Y';
        END IF;
    END IF;
    if p_old_position_id is not null then
            l_check_org_pos  := 'P';
            l_org_pos_id     := p_old_position_id;
            l_org_pos_str_id := p_old_pos_structure_id;
        if p_old_pos_structure_id is null then
            l_check_child := 'N';
        ELSE
            l_check_child := 'Y';
        END IF;
    END IF;

    -- VSM [Masscrit.doc]
    if p_old_organization_id is null and
       p_old_position_id is null     then
        -- if neither org nor position is entered then employees from
        -- all the organizations will be fetched.
        l_break := 'Y';
        l_org_pos_id := null;
        l_org_pos_str_id := null;
        l_check_org_pos := 'O';
        l_check_child := 'N';
    END IF;

    /****
    FOR per_count_rec IN CUr_people_cnt (null,
                                         l_check_org_pos,
                                         l_effective_DATE)
    LOOP
       l_mass_cnt := per_count_rec.COUNT;
       exit;
    END LOOP;
    ***/


    FOR org in child_orgs (l_org_pos_id,
                           l_check_child,
                           l_check_org_pos,
                           l_org_pos_str_id)
    LOOP
    BEGIN
        if UPPER(p_action) = 'REPORT' and p_status = 'P' THEN
            r_effective_DATE := l_effective_DATE - 1;
        ELSE
            r_effective_DATE := l_effective_DATE;
        END IF;

        if l_break = 'Y' then
           org.org_pos_id := null;
        END IF;

        FOR per IN cur_people (org.org_pos_id,
                               l_check_org_pos,
                               r_effective_DATE)
        LOOP
	  --Bug #5416994 Validating External User Person Type
	  IF instr(upper(hr_person_type_usage_info.get_user_person_type(nvl(r_effective_date,trunc(sysdate)),per.person_id)),
	           upper('external')) = 0 THEN
            BEGIN

                pr('AFTER FET PEOPLE');

                SAVEPOINT EXECUTE_MRE_SP;

l_ind := 40;
                l_assignment_id     := per.assignment_id;
                l_position_id       := per.position_id;
                l_grade_id          := per.grade_id;
                l_business_group_id := per.business_group_iD;
                l_location_id       := per.location_id;

                pr(' Assign Id/Pos ',to_char(per.assignment_id),to_char(per.position_id));
                pr(' Grade/Bus grp ',to_char(per.grade_id),to_char(per.business_group_id));
                pr(' Location/Eff dt ',to_char(per.location_id),to_char(l_effective_DATE));
                pr('Person_id', to_char(per.person_id));

l_ind := 50;
                if UPPER(p_action) = 'REPORT' AND p_status = 'P' THEN
                    pop_dtls_from_pa_req(per.person_id,l_effective_DATE,
                            p_mass_realignment_id);
                ELSE
                    if check_SELECT_flg(per.position_id,UPPER(p_action),
                                   l_effective_DATE,
                                   p_mass_realignment_id,
                                   l_sel_flg) then
                        pr('After check sel flg value is '||l_sel_flg);

                        get_pos_grp1_ddf(l_position_id,
                           l_effective_DATE,
                           l_personnel_office_id,
                           l_org_structure_id,
                           l_office_symbol,
                           l_position_organization,
                           l_pos_grp1_rec);

                        ghr_msl_pkg.get_sub_element_code_pos_title(l_position_id,
                               per.person_id,
                               l_business_group_id,
                               l_assignment_id,
                               l_effective_DATE,
                               l_sub_element_code,
                               l_position_title,
                               l_position_NUMBER,
                               l_position_seq_no);

                        IF check_eligibility(
                                   p_org_structure_id,
                                   p_office_symbol,
                                   p_personnel_office_id,
                                   p_agency_sub_elem_code,

                                   l_org_structure_id,
                                   l_office_symbol,
                                   l_personnel_office_id,
                                   l_sub_element_code,
                                   per.person_id,
                                   l_effective_DATE,
                                   UPPER(p_action)) THEN

 l_occ_series := ghr_api.get_job_occ_series_job
                                     (p_job_id              => per.job_id
                                     ,p_business_group_id   => per.business_group_id
                                         );
l_ind := 60;
                        BEGIN
                            ghr_pa_requests_pkg.get_sf52_asg_ddf_details
                              (l_assignment_id,
                               l_effective_DATE,
                               l_tenure,
                               l_annuitant_indicator,
                               l_pay_rate_determinant,
                               l_work_schedule,
                               l_part_time_hour);
                        EXCEPTION
                            when others then
                                pr('Error in Ghr_pa_requests_pkg.get_sf52_asg_ddf_details');
                                hr_utility.set_location('Error in Ghr_pa_requests_pkg.get_sf52_asg_ddf_details'||
                                  'Err is '||sqlerrm(sqlcode),20);
                                l_mslerrbuf := 'Error in get_sf52_asgddf_details Sql Err is '||
                                               sqlerrm(sqlcode);
                                raise mass_error;
                        END;

l_ind := 65;
                        BEGIN
                            ghr_msl_pkg.get_pay_plan_and_table_id(l_pay_rate_determinant,
                                   per.person_id,
                                   l_position_id,l_effective_DATE,
                                   l_grade_id, l_assignment_id,'SHOW',l_pay_plan,
                                   l_pay_table_id,l_grade_or_level, l_step_or_rate,
                                   l_pay_basis);
                        EXCEPTION
			    --Bug#4179270,4126137,4086677 Added the get_message call.
                            when ghr_msl_pkg.msl_error then
                                 l_mslerrbuf := hr_utility.get_message;
				 raise mass_error;
                        END;
l_ind := 70;
                        BEGIN
                            ghr_pa_requests_pkg.get_SF52_loc_ddf_details
                            (p_location_id      => l_location_id
                            ,p_duty_station_id  => l_duty_station_id);
                        EXCEPTION
                            when others then
                                pr('Error in Ghr_pa_requests_pkg.get_sf52_asg_ddf_details');
                                hr_utility.set_location('Error in Ghr_pa_requests_pkg.get_sf52_loc_ddf_details'||
                                      'Err is '||sqlerrm(sqlcode),20);
                                -- Bug 3718167 Added Person,SSN in the message instead of person_id
                                l_mslerrbuf := 'Error in get_sf52_loc_ddf_details Sql Err is '||
                                                sqlerrm(sqlcode);
                                raise mass_error;
                        END;
l_ind := 80;

get_pos_grp2_ddf(l_position_id,
                           l_effective_DATE,
                           l_org_func_code,
                           l_appropriation_code1,
                           l_appropriation_code2);
                           --l_pos_grp2_rec);
l_ind := 90;
                            BEGIN
                                ghr_pa_requests_pkg.get_duty_station_details
                                (p_duty_station_id        => l_duty_station_id
                                ,p_effective_DATE        => l_effective_DATE
                                ,p_duty_station_code        => l_duty_station_code
                                ,p_duty_station_desc        => l_duty_station_desc);
                            EXCEPTION
                                when others then
                                    pr('Error in Ghr_pa_requests_pkg.get_duty_station_details');
                                    hr_utility.set_location('Error in Ghr_pa_requests_pkg.get_duty_station_details'||
                                          'Err is '||sqlerrm(sqlcode),20);
                                    l_mslerrbuf := 'Error in get_duty_station_details Sql Err is '||
                                                   sqlerrm(sqlcode);
                                    raise mass_error;
                            END;

                            --added for bug 3191704
                            if (target_personnel_office_id is not null) then
                                t_personnel_office_id := target_personnel_office_id;
                            ELSE
                                t_personnel_office_id := l_personnel_office_id;
                            END IF;
                            --t_personnel_office_id := l_personnel_office_id;
                            t_sub_element_code    := l_sub_element_code;
                            t_duty_station_id     := l_duty_station_id;
                            t_duty_station_locn_id:= null;
                            t_duty_station_code   := l_duty_station_code;
                            t_duty_station_desc   := l_duty_station_desc;
                            t_office_symbol       := l_office_symbol;

                            -- Developer forgot to get the payroll office id. Changed by Dinkar

                            t_payroll_office_id   := l_pos_grp1_rec.poei_information18;
                            t_org_func_code       := l_org_func_code;
                            t_appropriation_code1 := l_appropriation_code1;
                            t_appropriation_code2 := l_appropriation_code2;
                            t_position_organization :=  l_position_organization;

                            pr('Bef get new org dtls pos org is',l_position_organization,t_position_organization);

                            get_new_org_dtls(
                                   p_mass_realignment_id,
                                   l_position_id,
                                   l_effective_DATE,
                                   t_personnel_office_id,
                                   t_sub_element_code,
                                   t_duty_station_id,
                                   t_duty_station_code,
                                   t_duty_station_desc,
                                   t_duty_station_locn_id,
                                   t_office_symbol,
                                   t_payroll_office_id,
                                   t_org_func_code,
                                   t_appropriation_code1,
                                   t_appropriation_code2,
                                   t_position_organization);
                            pr('after get new org dtls pos t_org is',t_position_organization);
                            pr('Duty station is '||to_char(t_duty_station_id),
                            'Code '||t_duty_station_code||
                            'Desc '||t_duty_station_desc,
                            'Locn id '||to_char(t_duty_station_locn_id));
l_ind := 130;
                            --Start of Bug 3944729
                            IF ( l_duty_station_id <> t_duty_station_id )
                             AND ( ghr_pay_calc.get_lpa_percentage(l_duty_station_id,l_effective_date) <>
                                   ghr_pay_calc.get_lpa_percentage(t_duty_station_id,l_effective_date) )

                             THEN
                               -- Bug#4388288
                               g_proc     := 'Invalid_Duty_Station';
                               l_mslerrbuf := 'The duty station entered results in a change in Locality Percentage.'||
                                              'This change is not permitted with NOA 790 Realignment. '||
                                              'Refer to OPM GPPA chapter 17 for the appropriate transaction.';
                               raise mass_error;

                            END IF;
--End of Bug 3944729
                            IF UPPER(p_action) IN ('SHOW','REPORT') THEN
                                pr('Bef create ghr cpdf temp');
                                create_mass_act_prev (
                                     l_effective_DATE,
                                     per.DATE_of_birth,
                                     per.full_name,
                                     per.national_identifier,
                                     l_duty_station_code,
                                     l_duty_station_desc,
                                     l_personnel_office_id,
                                     l_position_id,
                                     l_position_title,
                                     l_position_NUMBER,
                                     l_position_seq_no,
                                     l_org_structure_id,
                                     l_sub_element_code,
                                     per.person_id,
                                     p_mass_realignment_id,
                                     l_sel_flg,
                                     l_grade_or_level,
                                     l_step_or_rate,
                                     l_pay_plan,
                                     l_occ_series,
                                     l_office_symbol,
                                     per.organization_id,
                                     per.organization_name,
                                     l_position_organization,
                                     t_personnel_office_id,
                                     t_sub_element_code,
                                     t_duty_station_id,
                                     t_duty_station_code,
                                     t_duty_station_desc,
                                     t_office_symbol,
                                     t_payroll_office_id,
                                     t_org_func_code,
                                     t_appropriation_code1,
                                     t_appropriation_code2,
                                     t_position_organization,
                                     p_action,
                                     l_assignment_id,
                                     l_pay_rate_determinant);

l_ind := 180;
                            ELSIF UPPER(p_action) = 'CREATE' then  ---- Not in Show, Report
                                pr('Bef get pay plan and table id');
l_ind := 190;
                                BEGIN
                                    ghr_msl_pkg.get_pay_plan_and_table_id
                                    (l_pay_rate_determinant,per.person_id,
                                    l_position_id,l_effective_DATE,
                                    l_grade_id, l_assignment_id,'CREATE',
                                    l_pay_plan,l_pay_table_id,
                                    l_grade_or_level, l_step_or_rate,
                                    l_pay_basis);
                                EXCEPTION
			           --Bug#4179270,4126137,4086677 Added the get_message call.
                                    when ghr_msl_pkg.msl_error then
                                        l_mslerrbuf := hr_utility.get_message;
					raise mass_error;
                                END;
l_ind := 200;
                                pr('Bef assign to sf52 rec');
                                -- assign_to_sf52_rec assigns all the following elements to a 52 record type.

                                assign_to_sf52_rec(
                                per.person_id,
                                per.first_name,
                                per.last_name,
                                per.middle_names,
                                per.national_identifier,
                                per.DATE_of_birth,
                                l_effective_DATE,
                                l_assignment_id,
                                l_tenure,
                                l_step_or_rate,
                                l_annuitant_indicator,
                                l_pay_rate_determinant,
                                l_work_schedule,
                                l_part_time_hour,
                                l_pos_ei_data.poei_information7, --FLSA Category
                                l_pos_ei_data.poei_information8, --Bargaining Unit Status
                                l_pos_ei_data.poei_information11,--Functional Class
                                l_pos_ei_data.poei_information16,--Supervisory Status,
                                l_personnel_office_id,
                                l_sub_element_code,
                                t_duty_station_id,
                                t_duty_station_locn_id,
                                t_duty_station_code,
                                t_duty_station_desc,
                                l_office_symbol,
                                l_payroll_office_id,
                                l_org_func_code,
                                t_appropriation_code1,
                                t_appropriation_code2,
                                l_position_organization,
                                l_lac_sf52_rec,
                                l_sf52_rec);

                                -- PAY CALCULATION Bug#2850747
                                ghr_msl_pkg.get_from_sf52_data_elements(l_assignment_id,  l_effective_DATE,
                                                             l_old_basic_pay, l_old_avail_pay,
                                                             l_old_loc_diff, l_tot_old_sal,
                                                             l_old_auo_pay, l_old_adj_basic_pay,
                                                             l_other_pay, l_auo_premium_pay_indicator,
                                                             l_ap_premium_pay_indicator,
                                                             l_retention_allowance,
                                                             l_retention_allow_perc,
                                                             l_supervisory_differential,
                                                             l_supervisory_diff_perc,
                                                             l_staffing_differential);

                                l_pay_calc_in_data.person_id          := per.person_id;
                                l_pay_calc_in_data.position_id              := l_position_id;
                                l_pay_calc_in_data.noa_family_code          := 'REALIGNMENT';
                                l_pay_calc_in_data.noa_code                 := '790';
                                l_pay_calc_in_data.second_noa_code          := null;
                                l_pay_calc_in_data.effective_DATE           := l_effective_DATE;
                                l_pay_calc_in_data.pay_rate_determinant     := l_pay_rate_determinant;
                                l_pay_calc_in_data.pay_plan                 := l_pay_plan;
                                l_pay_calc_in_data.grade_or_level           := l_grade_or_level;
                                l_pay_calc_in_data.step_or_rate             := l_step_or_rate;
                                l_pay_calc_in_data.pay_basis                := l_pay_basis;
                                l_pay_calc_in_data.user_table_id            := l_pay_table_id;
                                l_pay_calc_in_data.duty_station_id          := t_duty_station_id;
                                l_pay_calc_in_data.auo_premium_pay_indicator := l_auo_premium_pay_indicator;
                                l_pay_calc_in_data.ap_premium_pay_indicator  := l_ap_premium_pay_indicator;
                                l_pay_calc_in_data.retention_allowance       := l_retention_allowance;
                                l_pay_calc_in_data.to_ret_allow_percentage   := l_retention_allow_perc;
                                l_pay_calc_in_data.supervisory_differential  := l_supervisory_differential;
                                l_pay_calc_in_data.staffing_differential    := l_staffing_differential;
                                l_pay_calc_in_data.current_basic_pay        := l_old_basic_pay;
                                l_pay_calc_in_data.current_adj_basic_pay    := l_old_adj_basic_pay;
                                l_pay_calc_in_data.current_step_or_rate     := l_step_or_rate;
                                l_pay_calc_in_data.pa_request_id            := null;

				  --BUG# 3719226 - JAN 05
				 -- IF the table is of type R then populate the basic into open_pay_basic
				 FOR pay_tab_type IN c_pay_tab_type(l_pay_table_id)
				 LOOP
					l_table_type   := pay_tab_type.range_or_match;
				 END LOOP;

				  IF ( l_table_type = 'R') THEN
					l_pay_calc_in_data.open_range_out_basic_pay := l_old_basic_pay;
				  -- Bug#3968005 Added Else Condition. Setting open_range_out_basic_pay to NULL
				  -- because pay calculation will calculate values depending on this value.
				  -- See pay calculation for further details.
				  ELSE
				     l_pay_calc_in_data.open_range_out_basic_pay := NULL;
				  END IF;
				  --
				  --BUG# 3719226 - JAN 05
                                -- Bug 3663808 Need to assign retained grade pay basis for Retained grade employees
                                IF nvl(l_pay_rate_determinant,'X') in ('A','B','E','F') THEN
                                    BEGIN
                                        p_retained_grade :=
                                        ghr_pc_basic_pay.get_retained_grade_details
                                                              ( per.person_id,
                                                                l_effective_DATE);
                                        l_pay_calc_in_data.pay_basis := p_retained_grade.pay_basis;
                                        hr_utility.set_location('l_pay_calc_in_data.pay_basis ' || l_pay_calc_in_data.pay_basis,1000);
                                    EXCEPTION
                                        WHEN OTHERS THEN
                                            l_mslerrbuf := 'Preview -  Others error in Get retained grade '||
                                                     'Error is '||' Sql Err is '|| sqlerrm(sqlcode);
                                            ghr_mre_pkg.pr('Person ID '||to_char(per.person_id),'ERROR 2',l_mslerrbuf);
                                            RAISE mass_error;
                                    END;
                                END IF;

                                BEGIN
                                    ghr_pay_calc.sql_main_pay_calc (l_pay_calc_in_data
                                              ,l_pay_calc_out_data
                                                  ,l_message_set
                                          ,l_calculated);

                                    IF l_message_set THEN
                                        hr_utility.set_location( l_proc, 40);
                                        l_calculated     := FALSE;
										--Begin Bug#4114068
										hr_utility.get_message_details(l_mslerrbuf,l_appl_id);
										IF l_mslerrbuf = 'GHR_38254_NO_CALC_PRD' THEN
											raise ghr_pay_calc.unable_to_calculate;
										ELSE
											raise mass_error;
										END IF;
									ELSE
										-- FWFA Changes Bug#4444609 Setting Calc Pay Table ID, PRD
										l_sf52_rec.input_pay_rate_determinant := l_pay_rate_determinant;
										l_sf52_rec.from_pay_table_identifier  := l_pay_calc_out_data.pay_table_id;
										l_sf52_rec.to_pay_table_identifier    := l_pay_calc_out_data.calculation_pay_table_id;
										-- FWFA Changes
										l_new_basic_pay        := l_pay_calc_out_data.basic_pay;
										l_new_locality_adj     := l_pay_calc_out_data.locality_adj;
										l_new_adj_basic_pay    := l_pay_calc_out_data.adj_basic_pay;
										l_new_au_overtime      := l_pay_calc_out_data.au_overtime;
										l_new_availability_pay := l_pay_calc_out_data.availability_pay;
										l_out_pay_rate_determinant := l_pay_calc_out_data.out_pay_rate_determinant;
										l_new_retention_allowance :=  l_pay_calc_out_data.retention_allowance;
										l_new_supervisory_differential := l_supervisory_differential;
										l_new_other_pay_amount         := l_pay_calc_out_data.other_pay_amount;
										l_entitled_other_pay           := l_new_other_pay_amount;

										if l_new_other_pay_amount = 0 then
											l_new_other_pay_amount := null;
										END IF;
										l_new_total_salary        := l_pay_calc_out_data.total_salary;
									END IF;
                                EXCEPTION
                                    when mass_error then
                                        raise;
									when ghr_pay_calc.unable_to_calculate THEN
										l_new_basic_pay        := l_pay_calc_in_data.current_basic_pay;
										l_new_locality_adj     := l_pay_calc_in_data.current_adj_basic_pay - 	 						  l_pay_calc_in_data.current_basic_pay ;
										l_new_adj_basic_pay    := l_pay_calc_in_data.current_adj_basic_pay ;
										l_new_au_overtime := ghr_pay_calc.get_ppi_amount (l_pay_calc_in_data.auo_premium_pay_indicator
                                                      ,l_pay_calc_in_data.current_adj_basic_pay
                                                      ,l_pay_calc_in_data.pay_basis);
										l_new_availability_pay := ghr_pay_calc.get_ppi_amount (l_pay_calc_in_data.ap_premium_pay_indicator
                                                           ,l_pay_calc_in_data.current_adj_basic_pay
                                                           ,l_pay_calc_in_data.pay_basis);

										l_out_pay_rate_determinant := l_pay_calc_in_data.pay_rate_determinant;
										l_new_retention_allowance := l_pay_calc_in_data.retention_allowance;
										l_new_supervisory_differential := l_supervisory_differential;
										l_new_other_pay_amount         := NVL(l_new_au_overtime,0) +
																		  NVL(l_new_availability_pay,0) +
																		  NVL(l_new_retention_allowance,0) +
																		  NVL(l_new_supervisory_differential,0);
										l_entitled_other_pay           := l_new_other_pay_amount;
										l_new_total_salary        := NVL(l_new_adj_basic_pay,0) +
										                             NVL(l_new_other_pay_amount,0);
										if l_new_other_pay_amount = 0 then
											l_new_other_pay_amount := null;
										END IF;
										--end Bug#4114068
                                    when others then
                                        hr_utility.set_location('Error in Ghr_pay_calc.sql_main_pay_calc '||
                                                'Err is '||sqlerrm(sqlcode),20);
                                        l_mslerrbuf := 'Error in ghr_pay_calc  Sql Err is '||
                                                       sqlerrm(sqlcode);
                                        raise mass_error;
                                END;

                                --Call Pay cap Procedure
                                BEGIN
                                    l_capped_other_pay := ghr_pa_requests_pkg2.get_cop( p_assignment_id  => l_assignment_id
                                                                                      ,p_effective_DATE => l_effective_DATE);
                                    ghr_pay_caps.do_pay_caps_main
                                    (p_pa_request_id        =>    null
                                    ,p_effective_DATE       =>    l_effective_DATE
                                    ,p_pay_rate_determinant =>    nvl(l_out_pay_rate_determinant,l_pay_rate_determinant)
                                    ,p_pay_plan             =>    l_pay_plan
                                    ,p_to_position_id       =>    l_position_id
                                    ,p_pay_basis            =>    l_pay_basis
                                    ,p_person_id            =>    per.person_id
                                    ,p_noa_code             =>    '790'
                                    ,p_basic_pay            =>    l_new_basic_pay
                                    ,p_locality_adj         =>    l_new_locality_adj
                                    ,p_adj_basic_pay        =>    l_new_adj_basic_pay
                                    ,p_total_salary         =>    l_new_total_salary
                                    ,p_other_pay_amount     =>    l_entitled_other_pay
                                    ,p_capped_other_pay     =>    l_capped_other_pay
                                    ,p_retention_allowance  =>    l_new_retention_allowance
                                    ,p_retention_allow_percentage => l_retention_allow_perc
                                    ,p_supervisory_allowance =>   l_new_supervisory_differential
                                    ,p_staffing_differential =>   l_staffing_differential
                                    ,p_au_overtime          =>    l_new_au_overtime
                                    ,p_availability_pay     =>    l_new_availability_pay
                                    ,p_adj_basic_message    =>    l_adj_basic_message
                                    ,p_pay_cap_message      =>    l_pay_cap_message
                                    ,p_pay_cap_adj          =>    l_temp_retention_allowance
                                    ,p_open_pay_fields      =>    l_open_pay_fields_caps
                                    ,p_message_set          =>    l_message_set_caps
                                    ,p_total_pay_check      =>    l_total_pay_check);

                                    l_new_other_pay_amount := nvl(l_capped_other_pay,l_entitled_other_pay);

                                    if l_pay_cap_message then
                                        if nvl(l_temp_retention_allowance,0) > 0 then
                                            l_comment := 'Exceeded Total Salary cap - reduce Retention Allowance to '
                                                                   || to_char(l_temp_retention_allowance);
                                            l_pay_sel := 'N';
                                        ELSE
                                            l_comment := 'Exceeded Total Salary cap - please review';
                                        END IF;
                                    ELSIF l_adj_basic_message then
                                        l_comment := 'Exceeded Adjusted Basic Pay cap - Locality Pay has been reduced';
                                    END IF;

                                    if l_pay_cap_message or l_adj_basic_message then
                                        --Bug#3225758
                                        /* Commented the below call as MRE comments needs to be stored
                                        in position extra info not in Person Extra Info.
                                        */
                                        /*
                                        ghr_msl_pkg.ins_upd_per_extra_info
                                            (per.person_id,l_effective_DATE, l_pay_sel, l_comment,p_mass_realignment_id);
                                        */
                                        ins_upd_pos_extra_info(l_position_id,l_effective_DATE,'Y', l_comment, p_mass_realignment_id );
                                        l_comment := null;
                                    END IF;

                                EXCEPTION
                                    when mass_error then
                                        raise;
                                    when others then
                                        hr_utility.set_location('Error in ghr_pay_caps.do_pay_caps_main ' ||
                                                  'Err is '||sqlerrm(sqlcode),23);
                                        l_mslerrbuf := 'Error in do_pay_caps_main  Sql Err is '|| sqlerrm(sqlcode);
                                        raise mass_error;
                                END;

                                l_sf52_rec.to_basic_pay     :=  l_new_basic_pay;
                                l_sf52_rec.to_locality_adj  := l_new_locality_adj;
                                l_sf52_rec.to_adj_basic_pay := l_new_adj_basic_pay;
                                l_sf52_rec.to_au_overtime   := l_new_au_overtime;
                                l_sf52_rec.to_availability_pay := l_new_availability_pay;
                                l_sf52_rec.pay_rate_determinant := NVL(l_out_pay_rate_determinant,l_pay_rate_determinant);
                                l_sf52_rec.to_retention_allowance := l_new_retention_allowance;
                                l_sf52_rec.to_supervisory_differential := l_new_supervisory_differential;
                                l_sf52_rec.to_other_pay_amount  := l_new_other_pay_amount;
                                l_sf52_rec.to_total_salary      := l_new_total_salary;


                                -- Bug#2850747 End of PAY CALCULATIONPAY CALCULATION

                                pr('Bef create sf52 for mass chgs');

                                -- This procedure will create 52s for doing a NOA 790 for realignment.
                                -- The record will accept a IN/OUT p_pa_request_rec variable.
                                -- Once the 52 is created, it returns the PA request id and
                                -- we create the PA request extra INFO for GHR_PAR_REALIGNMENT which
                                -- is necessary process method for UPDATE HR. Pay calc is not run
                                -- as no values except for organization will change for the position.

                                BEGIN
                                    if l_sf52_rec.person_id is null then
                                        l_mslerrbuf := 'Error before create sf52 : PERSON ID is NULL';
                                        raise mass_error;
                                    END IF;
                                    -- Adding the following code to keep track of the RPA type and Mass action id
				    --
				    l_sf52_rec.rpa_type            := 'MRE';
				    l_sf52_rec.mass_action_id      := p_mass_realignment_id;
				    --
				    --

				    ghr_mass_changes.create_sf52_for_mass_changes
                                    (p_mass_action_type => 'MASS_REALIGNMENT',
                                     p_pa_request_rec  => l_sf52_rec,
                                     p_errbuf           => l_errbuf,
                                     p_retcode          => l_retcode);

                                    pr('Create sf52 success');

                                    if l_errbuf is null then
                                        pr('No error in create sf52 sel flg is '||l_sel_flg);
                                        hr_utility.set_location('Before COMMITing',2);

                                        ghr_mto_int.log_message(
                                        p_procedure => 'Successful Completion',
                                        p_message   => 'Name: '||per.full_name ||
                                        ' SSN: '|| per.national_identifier||
                                        ' Mass realignment : '||
                                        p_mass_realignment_name ||' SF52 Successfully completed');

                                        ghr_msl_pkg.create_lac_remarks(l_pa_request_id,
                                                       l_sf52_rec.pa_request_id);
                                        upd_ext_info_to_null(per.position_id,l_effective_DATE);
                                        COMMIT;
                                    ELSE
                                        pr('Error in create sf52',l_errbuf);
                                        hr_utility.set_location('Error in '||to_char(per.position_id),20);
                                        l_mslerrbuf := 'Error in create sf52 '|| l_errbuf;
                                        --l_recs_failed := l_recs_failed + 1;
                                        raise mass_error;
                                    END IF;
                                EXCEPTION
                                    when mass_error then
                                        raise;
                                    when others then
                                        null;
                                        l_mslerrbuf := 'Error in ghr_mass_chg.create_sf52 '||
                                           ' Sql Err is '|| sqlerrm(sqlcode);
                                        pr('Error ---> create sf52   Err is '||
                                        l_errbuf||' '||to_char(l_retcode));
                                        pr('Err is '||sqlerrm(sqlcode));
                                        raise mass_error;
                                END;

                                -------------Added by Dinkar for creation of 52s-----------------------

                                pr('Bef hist fetch');
                                BEGIN
                                    ghr_history_fetch.fetch_asgei
                                    ( p_assignment_id     => l_assignment_id,
                                    p_information_type  => 'GHR_US_ASG_NON_SF52',
                                    p_DATE_effective    => l_effective_DATE,
                                    p_asg_ei_data       => l_asg_extra_info_rec
                                    );
                                EXCEPTION
                                    when others then
                                        null;
                                        pr('Error in create sf52  3- Err is '||
                                        l_errbuf||' '||to_char(l_retcode));
                                        pr('Err is '||sqlerrm(sqlcode));
                                        l_mslerrbuf := 'Error after fetch asgei'||
                                        ' Sql Err is '|| sqlerrm(sqlcode);
                                        raise mass_error;
                                END;

                                pr('Bef create pa req ext info');
                                BEGIN
                                    -- Bug#2651909 Getting target organization's OPM Organizational Component
                                    for  c_opm_org_rec in c_opm_org_component(p_new_organization_id)
                                    loop
                                        p_new_org_structure_id := c_opm_org_rec.org_information4;
                                    END loop;
                                    -- Bug#2651909

                                    ghr_par_extra_info_api.create_pa_request_extra_info
                                    (p_valiDATE                    => false,
                                     p_pa_request_id               => l_sf52_rec.pa_request_id,
                                     p_information_type            => 'GHR_US_PAR_REALIGNMENT',
                                     p_rei_information_category    => 'GHR_US_PAR_REALIGNMENT',
                                     p_rei_information3 => l_asg_extra_info_rec.aei_information3,
                                     p_rei_information4            => t_payroll_office_id,
                                     p_rei_information5            => t_personnel_office_id,
                                     p_rei_information6            => t_office_symbol,
                                     p_rei_information7            => t_org_func_code,
                                     p_rei_information8            => t_position_organization,
                                     p_rei_information9            => p_new_organization_id,
                                     p_rei_information10           => t_sub_element_code,
                                     p_rei_information11           => p_new_org_structure_id,
                                     p_pa_request_extra_info_id    => l_dummy,
                                     p_object_version_NUMBER       => l_dummy
                                    );
                                EXCEPTION
                                    when others then
                                        null;
                                        pr('Error in create sf52  2- Err is '||
                                        l_errbuf||' '||to_char(l_retcode));
                                        pr('Err is '||sqlerrm(sqlcode));
                                        l_mslerrbuf := 'Error in creating PAR DDF '||
                                        ' Sql Err is '|| sqlerrm(sqlcode);
                                        raise mass_error;
                                END;
                                ---------------------------End of Dinkar's addition-----------------------

                                -- We call the package that Sue Grant has written for checking the
                                -- org id in the GHR_PAR_REALIGNMENT DDF and if there is one it returns
                                -- the 6 lines of address, and I would UPDATE the PA request with it.

                                DECLARE
                                    l_organization_id  VARCHAR2(15);
                                    l_position_org_line1   VARCHAR2(40);
                                    l_position_org_line2   VARCHAR2(40);
                                    l_position_org_line3   VARCHAR2(40);
                                    l_position_org_line4   VARCHAR2(40);
                                    l_position_org_line5   VARCHAR2(40);
                                    l_position_org_line6   VARCHAR2(40);
                                    l_par_object_version_NUMBER NUMBER := l_sf52_rec.object_version_NUMBER;
                                    l_dummy    NUMBER;
                                    l_personnel_officer_name      per_people_f.full_name%type;
                                    l_approving_off_work_title    ghr_pa_requests.APPROVING_OFFICIAL_WORK_TITLE%type;
                                BEGIN
                                    ghr_pa_requests_pkg.get_rei_org_lines(
                                                    p_pa_request_id => l_sf52_rec.pa_request_id,
                                                    p_organization_id => l_organization_id,
                                                    p_position_org_line1 => l_position_org_line1,
                                                    p_position_org_line2 => l_position_org_line2,
                                                    p_position_org_line3 => l_position_org_line3,
                                                    p_position_org_line4 => l_position_org_line4,
                                                    p_position_org_line5 => l_position_org_line5,
                                                    p_position_org_line6 => l_position_org_line6
                                                    );
                                    -- Combined 6 lines of Org thing with Electronic to just do only one
                                    -- UpDATE.
                                    -- This addition is for Electronic Signature while doing a realignment
                                    -- and there is a change in the POI

                                    ghr_mass_actions_pkg.get_personnel_officer_name
                                    (p_personnel_office_id => t_personnel_office_id,
                                    p_person_full_name    => l_personnel_officer_name,
                                    p_approving_off_work_title => l_approving_off_work_title);

                                    -- If the organization id is not null then we UPDATE the PA Request record
                                    -- to position org line1 to line 6 with the address information
                                    -- returned by the above function.
                                    -- If the Organization id is Null then there is some problem.

                                    IF l_organization_id is NOT NULL THEN
                                        ghr_par_upd.upd(
                                        p_pa_request_id         => l_sf52_rec.pa_request_id
                                        ,p_to_position_org_line1 => l_position_org_line1
                                        ,p_to_position_org_line2 => l_position_org_line2
                                        ,p_to_position_org_line3 => l_position_org_line3
                                        ,p_to_position_org_line4 => l_position_org_line4
                                        ,p_to_position_org_line5 => l_position_org_line5
                                        ,p_to_position_org_line6 => l_position_org_line6
                                        ,p_approving_official_full_name  => l_personnel_officer_name
                                        ,p_approving_official_work_titl  => l_approving_off_work_title
                                        ,p_object_version_NUMBER => l_par_object_version_NUMBER);
                                    END IF;

                                    -- Added by Dinkar for reports
                                    declare
                                        l_pa_request_NUMBER ghr_pa_requests.request_NUMBER%TYPE;
					--
                                    BEGIN
                                        l_pa_request_NUMBER   :=
                                                l_sf52_rec.request_NUMBER||'-'||p_mass_realignment_id;

                                        ghr_par_upd.upd
                                        (p_pa_request_id             => l_sf52_rec.pa_request_id,
                                        p_object_version_NUMBER     => l_par_object_version_NUMBER,
                                        p_request_NUMBER            => l_pa_request_NUMBER
                                        );
                                    END;
                                EXCEPTION
                                    WHEN OTHERS THEN
                                        null;
                                        pr('Error in fetch/UPDATE of 6 lines of pos org'||
                                        l_errbuf||' '||to_char(l_retcode));
                                        pr('Err is '||sqlerrm(sqlcode));
                                        l_mslerrbuf := 'Error while fetching/updating 6 lines of
                                        org info and/or Elec. Authentication'||
                                        ' Sql Err is '|| sqlerrm(sqlcode);
                                        raise mass_error;
                                END; -- End of Sub block of 6 lines of positions org UPDATE.

l_ind := 230;
                            END IF;  ---- End if for p_action = 'CREATE' ----
                        END IF; --- End if for Check Eligibility ----
                    ELSE   ------ Else for Check Select flag ----
l_ind := 260;
                        --UPDATE_SEL_FLG(PER.PERSON_ID,l_effective_DATE);
                        null; ---Commented needs to check
                    END IF; ---- End if for check SELECT flag ----
                END IF; ---- End if for p_action
l_ind := 270;
                L_row_cnt := L_row_cnt + 1;
                l_mass_cnt := l_mass_cnt +1;
                if UPPER(p_action) <> 'CREATE' THEN
                    if L_row_cnt > 50 then
                        COMMIT;
                        L_row_cnt := 0;
                    END IF;
                END IF;
            EXCEPTION
                WHEN mass_ERROR THEN
                    HR_UTILITY.SET_LOCATION('Error occurred in  '||l_proc||' Sql error '||sqlerrm(sqlcode),10);

                    BEGIN
                        ROLLBACK TO EXECUTE_MRE_SP;
                    EXCEPTION
                        WHEN OTHERS THEN NULL;
                    END;

                    p_retcode  := 2;
                    l_log_text  := 'Error in '||l_proc||' '||
                    ' For Mass Realignment Name : '||p_mass_realignment_name||
                    ' for Name : '||per.full_name ||
                    ' SSN: ' ||per.national_identifier||
                    l_mslerrbuf;
                    hr_utility.set_location('before creating entry in log file',10);
                    l_recs_failed := l_recs_failed + 1;

                    BEGIN
                        ghr_mto_int.log_message(
                        p_procedure => g_proc,
                        p_message   => l_log_text);
                        COMMIT;
                    EXCEPTION
                        when others then
                            hr_utility.set_message(8301, 'GHR_38475_ERROR_LOG_FAILURE');
                            hr_utility.raise_error;
                    END;

		    --6997689
                    BEGIN
                      l_comment := NULL;
                      if UPPER(p_action) <> 'CREATE' THEN
                          ins_upd_pos_extra_info(l_position_id,l_effective_DATE,'N', l_comment, p_mass_realignment_id );
			  COMMIT;
                      end if;
                    EXCEPTION
                      when others then
                             null;
                    END;
                   --6997689
                WHEN others then
                    hr_utility.set_location('Error (Others) occurred in  '||l_proc||
                    ' Sql error '||sqlerrm(sqlcode),20);

                    BEGIN
                        ROLLBACK TO EXECUTE_MRE_SP;
                    EXCEPTION
                        WHEN OTHERS THEN NULL;
                    END;

                    l_log_text  := 'Error (others) in '||l_proc||
                    'Line is '|| to_char(l_ind)||
                    ' For Mass Realignment Name : '||p_mass_realignment_name||
                    ' for Name : '||per.full_name ||
                    ' SSN: ' ||per.national_identifier||
                    ' Sql Err is '||sqlerrm(sqlcode);
                    hr_utility.set_location('before creating entry in log file',20);
                    l_recs_failed := l_recs_failed + 1;
                    p_retcode  := 2;
                    p_errbuf   := 'Error in '||l_proc || ' Details in GHR_PROCESS_LOG';

                    BEGIN
                        ghr_mto_int.log_message(
                        p_procedure => g_proc,
                        p_message   => l_log_text);
                        COMMIT;
                    EXCEPTION
                        when others then
                            hr_utility.set_message(8301, 'Create Error Log failed');
                            hr_utility.raise_error;
                    END;
                END;
              END IF;
            END LOOP;

            if UPPER(p_action) = 'SHOW'
            or (UPPER(p_action) = 'REPORT' and p_show_vacant_pos = 'YES' ) THEN
                FOR per IN unassigned_pos (org.org_pos_id,
                                       l_check_org_pos,
                                       l_effective_DATE)
                LOOP
                    l_avail_status_id := per.availability_status_id;

                    IF ( HR_GENERAL.DECODE_AVAILABILITY_STATUS(l_avail_status_id)
                    not in ('Eliminated','Frozen','Deleted') ) THEN

                        l_position_id       := per.position_id;
                        ghr_history_fetch.fetch_positionei
                        (p_position_id      => l_position_id
                        ,p_information_type => 'GHR_US_POS_VALID_GRADE'
                        ,p_DATE_effective   => l_effective_DATE
                        ,p_pos_ei_data      => l_pos_valid_grade_ei_data
                        );
                        l_grade_id          := l_pos_valid_grade_ei_data.poei_information3;
                        l_business_group_id := per.business_group_iD;
                        l_location_id       := per.location_id;

                        if check_SELECT_flg(per.position_id,UPPER(p_action),
                        l_effective_DATE,
                        p_mass_realignment_id,
                        l_sel_flg) then
                            pr('After check sel flg value is ',l_sel_flg,l_sel_status);
                            null;
                        END IF;
                        l_position_title := ghr_api.get_position_title_pos
                        (p_position_id            => l_position_id
                        ,p_business_group_id      => l_business_group_id ) ;

                        l_sub_element_code := ghr_api.get_position_agency_code_pos
                        (l_position_id,l_business_group_id);

                        l_occ_series := ghr_api.get_job_occ_series_job
                        (p_job_id              => per.job_id
                        ,p_business_group_id   => per.business_group_id
                        );

                        l_position_NUMBER := ghr_api.get_position_desc_no_pos
                        (p_position_id         => l_position_id
                        ,p_business_group_id   => per.business_group_id
                        );

                        l_position_seq_no := ghr_api.get_position_sequence_no_pos
                        (p_position_id         => l_position_id
                        ,p_business_group_id   => per.business_group_id
                        );

                        FOR c_grade_kff_rec IN c_grade_kff (l_grade_id)
                        LOOP
                            l_pay_plan          := c_grade_kff_rec.segment1;
                            l_grade_or_level    := c_grade_kff_rec.segment2;
                            exit;
                        END loop;

                        get_pos_grp1_ddf(l_position_id,
                        l_effective_DATE,
                        l_personnel_office_id,
                        l_org_structure_id,
                        l_office_symbol,
                        l_position_organization,
                        l_pos_grp1_rec);

                        get_pos_grp2_ddf(l_position_id,
                        l_effective_DATE,
                        l_org_func_code,
                        l_appropriation_code1,
                        l_appropriation_code2);

                        BEGIN
                            ghr_pa_requests_pkg.get_SF52_loc_ddf_details
                            (p_location_id      => l_location_id
                            ,p_duty_station_id  => l_duty_station_id);
                        END;

                        BEGIN
                            ghr_pa_requests_pkg.get_duty_station_details
                            (p_duty_station_id   => l_duty_station_id
                            ,p_effective_DATE    => l_effective_DATE
                            ,p_duty_station_code => l_duty_station_code
                            ,p_duty_station_desc => l_duty_station_desc);
                        END;

                        IF check_eligibility(
                        p_org_structure_id,
                        p_office_symbol,
                        p_personnel_office_id,
                        p_agency_sub_elem_code,

                        l_org_structure_id,
                        l_office_symbol,
                        l_personnel_office_id,
                        l_sub_element_code,
                        null,
                        l_effective_DATE,
                        UPPER(p_action)) THEN

                            t_personnel_office_id := l_personnel_office_id;
                            t_sub_element_code    := l_sub_element_code;
                            t_duty_station_id     := l_duty_station_id;
                            t_duty_station_locn_id:= null;
                            t_duty_station_code   := l_duty_station_code;
                            t_duty_station_desc   := l_duty_station_desc;
                            t_office_symbol       := l_office_symbol;
                            --t_payroll_office_id   := l_payroll_office_id;
                            t_payroll_office_id   := l_pos_grp1_rec.poei_information18;
                            t_org_func_code       := l_org_func_code;
                            t_appropriation_code1 := l_appropriation_code1;
                            t_appropriation_code2 := l_appropriation_code2;
                            t_position_organization :=  l_position_organization;

                            pr('Bef get new org dtls pos org is',l_position_organization,t_position_organization);

                            get_new_org_dtls(
                            p_mass_realignment_id,
                            l_position_id,
                            l_effective_DATE,
                            t_personnel_office_id,
                            t_sub_element_code,
                            t_duty_station_id,
                            t_duty_station_code,
                            t_duty_station_desc,
                            t_duty_station_locn_id,
                            t_office_symbol,
                            t_payroll_office_id,
                            t_org_func_code,
                            t_appropriation_code1,
                            t_appropriation_code2,
                            t_position_organization);

                            --Start of Bug 3944729
                            IF ( l_duty_station_id <> t_duty_station_id )
                             AND ( ghr_pay_calc.get_lpa_percentage(l_duty_station_id,l_effective_date) <>
                                   ghr_pay_calc.get_lpa_percentage(t_duty_station_id,l_effective_date) )

                             THEN
                                l_log_text := 'Error in MRE: '||p_mass_realignment_name||
                                              ' for Vacant Position : '||l_position_title||'.'||l_position_NUMBER
							                              ||'.'||l_position_seq_no||'.'||l_sub_element_code||'. Error: ';
                                l_log_text := l_log_text||'The duty station entered results in a change in Locality Percentage.'||
                                              'This change is not permitted with NOA 790 Realignment. '||
                                              'Refer to OPM GPPA chapter 17 for the appropriate transaction.';
                                BEGIN
                                    ghr_mto_int.log_message(
                                    p_procedure => 'Invalid_Duty_Station',
                                    p_message   => l_log_text);
                                EXCEPTION
                                    when others then
                                        hr_utility.set_message(8301, 'GHR_38475_ERROR_LOG_FAILURE');
                                        hr_utility.raise_error;
                                END;
                                l_log_text := NULL;
                                l_recs_failed := l_recs_failed + 1;
                            ELSE
                                pr(' Assign Id/Pos ',null, to_char(per.position_id));
                                create_mass_act_prev (
                                l_effective_DATE,
                                per.DATE_of_birth,
                                per.full_name,
                                per.national_identifier,
                                l_duty_station_code,
                                l_duty_station_desc,
                                l_personnel_office_id,
                                l_position_id,
                                l_position_title,
                                l_position_NUMBER,
                                l_position_seq_no,
                                l_org_structure_id,
                                l_sub_element_code,
                                per.person_id,
                                p_mass_realignment_id,
                                l_sel_flg,
                                l_grade_or_level,
                                null, ---l_step_or_rate,
                                l_pay_plan,
                                l_occ_series,
                                l_office_symbol,
                                per.organization_id,
                                per.organization_name,
                                l_position_organization,

                                t_personnel_office_id,
                                t_sub_element_code,
                                t_duty_station_id,
                                t_duty_station_code,
                                t_duty_station_desc,
                                t_office_symbol,
                                t_payroll_office_id,
                                t_org_func_code,
                                t_appropriation_code1,
                                t_appropriation_code2,
                                t_position_organization,
                                p_action,
                                null,null);
                            END IF;
                            --End of Bug 3944729
                        END IF;   ---- Check eligibility
                        l_mass_cnt := l_mass_cnt +1;
                    END IF; -- End of If which checks for Availability Status
                END LOOP;
            END IF; --- End for unass - p_action = show/report

            ----------------------------
            if  UPPER(p_action) = 'CREATE' then
                --- For all the vacant positions. Once this program is called with
                --  CREATE Option. The positions will be realigned. No 52s will be created
                --  and it is agreed in the design review meeting by MACROSS and JMACGOY.

                DECLARE

                    l_new_position_id   hr_positions_f.position_id%TYPE;
                    l_position_data_rec ghr_sf52_pos_UPDATE.position_data_rec_type;

                    l_pos_ei_data_rec   per_position_extra_info%rowtype;
                    l_new_pos_grp1_rec  per_position_extra_info%rowtype;

                    l_target_personnel_office_id    per_position_extra_info.poei_information1%TYPE;
                    l_target_agency_code            per_position_extra_info.poei_information1%TYPE;
                    l_target_office_symbol          per_position_extra_info.poei_information1%TYPE;
                    l_target_payroll_office_id      per_position_extra_info.poei_information1%TYPE;
                    l_target_org_func_code          per_position_extra_info.poei_information1%TYPE;
                    l_target_appropriation_code1    per_position_extra_info.poei_information1%TYPE;
                    l_target_appropriation_code2    per_position_extra_info.poei_information1%TYPE;
                    l_target_position_organization  per_position_extra_info.poei_information1%TYPE;
                    -- We don't need Duty Station for vacant positions
                    l_target_dummy1  per_position_extra_info.poei_information1%TYPE;
                    l_target_dummy2  per_position_extra_info.poei_information1%TYPE;
					--Begin Bug# 4648802
					l_target_dummy3  per_position_extra_info.poei_information1%TYPE;
					--End Bug# 4648802
                    l_pos_business_group_id NUMBER;
                    l_target_duty_station_locn_id   NUMBER(15);                        -- Bug 3490826
                BEGIN

                    FOR per_vacant IN unassigned_pos (org.org_pos_id,
                    l_check_org_pos,
                    l_effective_DATE)
                    LOOP
                        l_avail_status_id := per_vacant.availability_status_id;
                        IF ( HR_GENERAL.DECODE_AVAILABILITY_STATUS(l_avail_status_id)
                        not in ('Eliminated','Frozen','Deleted') ) THEN

                            IF check_SELECT_flg(per_vacant.position_id,UPPER(p_action),
                            l_effective_DATE,
                            p_mass_realignment_id,
                            l_sel_flg) then

                                l_new_position_id       := per_vacant.position_id;
                                l_position_data_rec.position_id := l_new_position_id;
                                l_position_data_rec.effective_DATE    := l_effective_DATE;
                                l_position_data_rec.organization_id := p_new_organization_id;
                                l_pos_business_group_id := per_vacant.business_group_id;

                                l_target_agency_code := ghr_api.get_position_agency_code_pos
                                                    (l_new_position_id,l_pos_business_group_id);

                                l_position_title := ghr_api.get_position_title_pos
                                (p_position_id            => l_new_position_id
                                ,p_business_group_id      => l_pos_business_group_id ) ;

                                -----Added by AVR for checking the eligibility of Vacant Position
                                get_pos_grp1_ddf(l_new_position_id,
                                           l_effective_DATE,
                                           l_personnel_office_id,
                                           l_org_structure_id,
                                           l_office_symbol,
                                           l_position_organization,
                                           l_pos_grp1_rec);

                                l_sub_element_code := ghr_api.get_position_agency_code_pos
                                   (l_new_position_id,l_pos_business_group_id);

                                 -- Bug#4388288 Added the following..
                                l_position_NUMBER := ghr_api.get_position_desc_no_pos
                                (p_position_id         => l_new_position_id
                                ,p_business_group_id   => l_pos_business_group_id
                                );

                                l_position_seq_no := ghr_api.get_position_sequence_no_pos
                                (p_position_id         => l_new_position_id
                                ,p_business_group_id   => l_pos_business_group_id
                                );

                                 l_location_id := per_vacant.location_id;
                                 BEGIN
                                    ghr_pa_requests_pkg.get_SF52_loc_ddf_details
                                    (p_location_id      => l_location_id
                                    ,p_duty_station_id  => l_duty_station_id);
                                END;

                                BEGIN
                                    ghr_pa_requests_pkg.get_duty_station_details
                                    (p_duty_station_id   => l_duty_station_id
                                    ,p_effective_DATE    => l_effective_DATE
                                    ,p_duty_station_code => l_duty_station_code
                                    ,p_duty_station_desc => l_duty_station_desc);
                                END;
                                -- Bug#4388288

                                hr_utility.set_location('Vac.POS-l_position_title '      || l_position_title,5);
                                hr_utility.set_location('Vac.POS-l_personnel_office_id ' || l_personnel_office_id,5);
                                hr_utility.set_location('Vac.POS-l_org_structure_id '    || l_org_structure_id,5);
                                hr_utility.set_location('Vac.POS-l_office_symbol '       || l_office_symbol,5);
                                hr_utility.set_location('Vac.POS-l_sub_element_code '    || l_sub_element_code,5);

                                IF check_eligibility(
                                p_org_structure_id,
                                p_office_symbol,
                                p_personnel_office_id,
                                p_agency_sub_elem_code,

                                l_org_structure_id,
                                l_office_symbol,
                                l_personnel_office_id,
                                l_sub_element_code,
                                null,
                                l_effective_DATE,
                                null) THEN
                                    -----AVR
                                    hr_utility.set_location('Vac Pos Selected         '      || l_position_title,5);
                                    ---dbms_output.put_line('After assigning agency code');

                                    -- Added by Dinkar for Updating Position details for vacant positions

                                    -- Getting Pos group2 data.

                                    ghr_history_fetch.fetch_positionei
                                            (p_position_id           => l_new_position_id
                                            ,p_information_type      => 'GHR_US_POS_GRP2'
                                            ,p_DATE_effective        => l_effective_DATE
                                            ,p_pos_ei_data           => l_pos_ei_data_rec);

                                    l_target_org_func_code    := l_pos_ei_data_rec.poei_information4;
                                    l_target_appropriation_code1
                                        := l_pos_ei_data_rec.poei_information13;
                                    l_target_appropriation_code2
                                        := l_pos_ei_data_rec.poei_information14;

                                    get_pos_grp1_ddf(l_new_position_id,
                                                   l_effective_DATE,
                                                   l_target_personnel_office_id,
                                                   l_target_dummy1,
                                                   l_target_office_symbol,
                                                   l_target_position_organization,
                                                   l_new_pos_grp1_rec);

                                    l_target_payroll_office_id   := l_new_pos_grp1_rec.poei_information18;
				    -- Bug#4388288 Added the following assignment statement.
				    t_duty_station_id := l_duty_station_id;
                                    get_new_org_dtls(
                                    p_mass_realignment_id => p_mass_realignment_id,
                                    p_position_id         => l_new_position_id,
                                    p_effective_DATE      => l_effective_DATE,
                                    p_personnel_office_id => l_target_personnel_office_id,
                                    p_sub_element_code    => l_target_agency_code,
                                    p_duty_station_id     => t_duty_station_id, -- Bug 4388288
                                    p_duty_station_code   => l_target_dummy2, -- Bug 4388288
                                    p_duty_station_desc   => l_target_dummy3, -- Bug 4648802
                                    -- p_duty_station_locn_id  => l_target_dummy2,               -- Bug 3490826
                                    p_duty_station_locn_id =>l_target_duty_station_locn_id ,  -- Bug 3490826
                                    p_office_symbol       => l_target_office_symbol,
                                    p_payroll_office_id   => l_target_payroll_office_id,
                                    p_org_func_code       => l_target_org_func_code,
                                    p_appropriation_code1 => l_target_appropriation_code1,
                                    p_appropriation_code2 => l_target_appropriation_code2,
                                    p_position_organization => l_target_position_organization);

                                    l_position_data_rec.agency_code_subelement :=
                                                               l_target_agency_code;

                                    l_position_data_rec.location_id  := l_target_duty_station_locn_id ;    -- Bug 3490826

                                    -- Bug# 4388288
                                    IF ( l_duty_station_id <> t_duty_station_id )
                                         AND ( ghr_pay_calc.get_lpa_percentage(l_duty_station_id,l_effective_date) <>
                                               ghr_pay_calc.get_lpa_percentage(t_duty_station_id,l_effective_date) )

                                         THEN
                                            l_log_text := 'Error in MRE: '||p_mass_realignment_name||
                                                          ' for Vacant Position : '||l_position_title||'.'||l_position_NUMBER
							                              ||'.'||l_position_seq_no||'.'||l_sub_element_code||'. Error: ';
                                            l_log_text := l_log_text||'The duty station entered results in a change in Locality Percentage.'||
                                                          'This change is not permitted with NOA 790 Realignment. '||
                                                          'Refer to OPM GPPA chapter 17 for the appropriate transaction.';
                                            BEGIN
                                                ghr_mto_int.log_message(
                                                p_procedure => 'Invalid_Duty_Station',
                                                p_message   => l_log_text);
                                            EXCEPTION
                                                when others then
                                                    hr_utility.set_message(8301, 'GHR_38475_ERROR_LOG_FAILURE');
                                                    hr_utility.raise_error;
                                            END;
                                            l_log_text := NULL;
                                            l_recs_failed := l_recs_failed + 1;
                                    ELSE
                                        -- Updating Position Extra Information for Position GRP1
                                        g_proc := 'UpDATE Vacant Position';

                                        if l_new_pos_grp1_rec.position_extra_info_id is Not NULL THEN
                                            ----- Set the global variable not to fire the trigger
                                            ghr_api.g_api_dml       := TRUE;
                                            ghr_position_extra_info_api.UPDATE_position_extra_info
                                            (p_position_extra_info_id   => l_new_pos_grp1_rec.position_extra_info_id
                                            ,p_effective_DATE           => l_effective_DATE
                                            ,p_object_version_NUMBER    => l_new_pos_grp1_rec.object_version_NUMBER
                                            ,p_poei_information3        => l_target_personnel_office_id
                                            ,p_poei_information4        => l_target_office_symbol
                                            ,p_poei_information18       => l_target_payroll_office_id
                                            ,p_poei_information21       => l_target_position_organization
                                            ,p_poei_information_category  => 'GHR_US_POS_GRP1');
                                            ----- Reset the global variable
                                            ghr_api.g_api_dml       := FALSE;
                                        END IF;

                                        if l_pos_ei_data_rec.position_extra_info_id is Not NULL THEN
                                            ----- Set the global variable not to fire the trigger
                                            ghr_api.g_api_dml       := TRUE;
                                            ghr_position_extra_info_api.UPDATE_position_extra_info
                                            (p_position_extra_info_id   => l_pos_ei_data_rec.position_extra_info_id
                                            ,p_effective_DATE           => l_effective_DATE
                                            ,p_object_version_NUMBER    => l_pos_ei_data_rec.object_version_NUMBER
                                            ,p_poei_information4        => l_target_org_func_code
                                            ,p_poei_information13       => l_target_appropriation_code1
                                            ,p_poei_information14       => l_target_appropriation_code2
                                            ,p_poei_information_category  => 'GHR_US_POS_GRP2');
                                            ----- Reset the global variable
                                            ghr_api.g_api_dml       := FALSE;
                                        END IF;

                                        ghr_mto_int.log_message(
                                        p_procedure => 'Successful Completion',
                                        p_message   =>
                                        'Vacant Position : '||l_position_title ||
                                        ' Mass realignment : '||
                                        p_mass_realignment_name ||' Vacant pos Successfully completed');

                                        upd_ext_info_to_null(l_new_position_id,l_effective_DATE);

                                        -- There is a trigger on Position extra Info. Whenever UPDATEd/created the
                                        -- main position associated with it becomes invalid.
                                        -- We shall call valiDATE_perwsdpo procedure to set the status = VALID.
                                        -- Actually there should be a global flag called fire_trigger in session_var
                                        -- but it doesn't seem to be functional right now.

                                        --- Commented the following two lines to remove Validation functionality on Position.
                                        -- ghr_valiDATE_perwsdpo.valiDATE_perwsdpo(l_new_position_id);
                                        -- ghr_valiDATE_perwsdpo.UPDATE_posn_status(l_new_position_id);
                                        g_proc := 'ghr_sf52.UPDATE_position_info';
                                        pr('Position id /org id'||to_char(l_new_position_id),
                                                            to_char(p_new_organization_id));
                                        -- This Position UpDATE procedure will UPDATE both Organization
                                        -- and agency_code Subelement.

                                        -- VSM-  Bug # 758441
                                        -- Position history not created for Date END and org id
                                        -- Created wrapper procedure UPDATE_position_info for
                                        --  ghr_sf52_pos_UPDATE.UPDATE_position_info
                                        -- #### ghr_sf52_pos_UPDATE.UPDATE_position_info

                                        UPDATE_position_info (l_position_data_rec);

                                        ------ghr_sf52_pos_UPDATE.UPDATE_position_info
                                        ------                    ( p_pos_data_rec => l_position_data_rec);
                                    END IF; -- Bug#4388288 End.
                                END IF;  --- Eligibility
                            END IF;  --- Select flag
                        END IF; -- Check of availability status id ENDs here
                    END LOOP;
                EXCEPTION
                    WHEN OTHERS THEN
                        l_mslerrbuf := 'Error in ghr_sf52_pos_UPDATE.UPDATE_position_info'||' Sql Err is '|| sqlerrm(sqlcode);
                        raise mass_error;
                END;
            END IF; --- End for unass - p_action = CREATE
        END;
        if l_break = 'Y' then
            exit;
        END IF;
    END LOOP;

    /*
    if (l_recs_failed  < (l_mass_cnt  * (1/3))) then
    */
    if (l_recs_failed = 0) then
        IF UPPER(p_action) = 'CREATE' THEN
            BEGIN
                UPDATE ghr_mass_realignment
                set status = 'P'
                WHERE mass_realignment_id = p_mass_realignment_id;
            EXCEPTION
                when others then
                    HR_UTILITY.SET_LOCATION('Error in UpDATE ghr_mre  Sql error '||sqlerrm(sqlcode),30);
                    hr_utility.set_message(8301, 'GHR_38570_UPD_GHR_MRE_FAILURE');
                    hr_utility.raise_error;
            END;
        END IF;
    END IF;
    COMMIT;
    pr(' Recs failed '||to_char(l_recs_failed)||
    'msl cnt is '||to_char(l_mass_cnt));
    /*
    if (l_recs_failed  > (l_mass_cnt  * (1/3))) then
    */
    if (l_recs_failed <> 0) then
        p_errbuf   := 'Error in '||l_proc || ' Details in GHR_PROCESS_LOG';
        p_retcode  := 2;
        IF UPPER(p_action) = 'CREATE' THEN
            UPDATE ghr_mass_realignment
            set status = 'E'
            WHERE mass_realignment_id = p_mass_realignment_id;
            COMMIT;
        END IF;
    END IF;
EXCEPTION
    WHEN mass_ERROR THEN
        HR_UTILITY.SET_LOCATION('Error occurred in  '||l_proc||' Sql error '||sqlerrm(sqlcode),10);
        BEGIN
            ROLLBACK TO EXECUTE_MRE_SP;
        EXCEPTION
            WHEN OTHERS THEN NULL;
        END;
        IF UPPER(p_action) = 'CREATE' THEN
            UPDATE ghr_mass_realignment
            set status = 'E'
            WHERE mass_realignment_id = p_mass_realignment_id;
            COMMIT;
        END IF;
        l_log_text  := 'Error in '||l_proc||' '||
        ' For Mass Realignment Name : '||p_mass_realignment_name||
        l_mslerrbuf;
        hr_utility.set_location('before creating entry in log file',10);
        l_recs_failed := l_recs_failed + 1;
        p_retcode  := 2;
        p_errbuf   := 'Error in '||l_proc || ' Details in GHR_PROCESS_LOG';

        BEGIN
            ghr_mto_int.log_message(
                      p_procedure => g_proc,
                      p_message   => l_log_text);
        EXCEPTION
            when others then
                hr_utility.set_message(8301, 'GHR_38475_ERROR_LOG_FAILURE');
                hr_utility.raise_error;
        END;


    WHEN OTHERS THEN
        HR_UTILITY.SET_LOCATION('Error (Others2) occurred in  '||l_proc||' Sql error '||sqlerrm(sqlcode),30);
        BEGIN
            ROLLBACK TO EXECUTE_MRE_SP;
        EXCEPTION
            WHEN OTHERS THEN NULL;
        END;
        l_log_text  := 'Error in '||l_proc||
        ' For Mass Realignment Name : '||p_mass_realignment_name||
        ' Sql Err is '||sqlerrm(sqlcode);
        l_recs_failed := l_recs_failed + 1;
        hr_utility.set_location('before creating entry in log file',30);

        p_errbuf   := 'Error in '||l_proc || ' Details in GHR_PROCESS_LOG';
        p_retcode  := 2;
        IF UPPER(p_action) = 'CREATE' THEN
            UPDATE ghr_mass_realignment
            set status = 'E'
            WHERE mass_realignment_id = p_mass_realignment_id;
            COMMIT;
        END IF;

        BEGIN
            ghr_mto_int.log_message(
            p_procedure => g_proc,
            p_message   => l_log_text);
        EXCEPTION
            when others then
                hr_utility.set_message(8301, 'Create Error Log failed');
                hr_utility.raise_error;
        END;
END EXECUTE_MRE;

--
--
--
-- Procedure Deletes all records processed by the report
--

procedure purge_processed_recs(p_session_id in NUMBER,
                               p_err_buf    out NOCOPY VARCHAR2) is
BEGIN
   p_err_buf := null;
   delete from ghr_mass_actions_preview
         WHERE mass_action_type = 'REALIGNMENT'
           and session_id  = p_session_id;
   COMMIT;

EXCEPTION
   when others then
     p_err_buf := 'Sql err '|| sqlerrm(sqlcode);
END;

--
--
--

procedure pop_dtls_from_pa_req(p_person_id in NUMBER,p_effective_DATE in DATE,
         p_mass_realignment_id in NUMBER) is

cursor ghr_pa_req_cur is
SELECT EMPLOYEE_DATE_OF_BIRTH,
       substr(EMPLOYEE_LAST_NAME||', '||EMPLOYEE_FIRST_NAME||' '||
              EMPLOYEE_MIDDLE_NAMES,1,240)  FULL_NAME,
       EMPLOYEE_NATIONAL_IDENTIFIER,
       DUTY_STATION_CODE,
       DUTY_STATION_DESC,
       PERSONNEL_OFFICE_ID,
       TO_POSITION_ID POSITION_ID,
       TO_POSITION_TITLE POSITION_TITLE,
       TO_POSITION_NUMBER POSITION_NUMBER,
       TO_POSITION_SEQ_NO POSITION_SEQ_NO,
       null org_structure_id,
       FROM_AGENCY_CODE,
       PERSON_ID,
       'Y'  Sel_flag,
       first_action_la_code1,
       first_action_la_code2,
       NULL REMARK_CODE1,
       NULL REMARK_CODE2,
       from_grade_or_level,
       from_step_or_rate,
       FROM_OFFICE_SYMBOL,
       from_pay_plan,
       FROM_OCC_CODE,
       TO_ORGANIZATION_ID ORGANIZATION_ID,
/*
       B.NAME             ORGANIZATION_NAME,
*/
       EMPLOYEE_ASSIGNMENT_ID,
       PAY_RATE_DETERMINANT
  from ghr_pa_requests /*, per_organization_units B*/
 WHERE person_id = p_person_id
   and effective_DATE = p_effective_DATE
-- Added by Dinkar for reports
  and substr(request_NUMBER,(instr(request_NUMBER,'-')+1)) = to_char(p_mass_realignment_id)
   and first_noa_code = '790';
/*
   and TO_organization_id = B.organization_id;
*/

l_proc                      VARCHAR2(72)
          :=  g_package || '.pop_dtls_from_pa_req';
BEGIN
  g_proc := 'pop_dtls_from_pa_req';

    hr_utility.set_location('Entering    ' || l_proc,5);
    for pa_req_rec in ghr_pa_req_cur
    loop
     create_mass_act_prev (p_effective_DATE,
                           pa_req_rec.employee_DATE_of_birth,
                           pa_req_rec.full_name,
                           pa_req_rec.employee_national_identifier,
                           pa_req_rec.duty_station_code,
                           pa_req_rec.duty_station_desc,
                           pa_req_rec.personnel_office_id,
                           pa_req_rec.position_id,
                           pa_req_rec.position_title,
                           pa_req_rec.position_NUMBER,
                           pa_req_rec.position_seq_no,
                           pa_req_rec.org_structure_id,
                           pa_req_rec.from_agency_code,
                           pa_req_rec.person_id,
                           p_mass_realignment_id,
                           'Y', --- Sel flag
                           pa_req_rec.from_grade_or_level,
                           pa_req_rec.from_step_or_rate,
                           pa_req_rec.from_pay_plan,
                           pa_req_rec.from_occ_code,
                           pa_req_rec.from_office_symbol,
                           pa_req_rec.organization_id,
                           null,---pa_req_rec.organization_name,
                           null,
                           null, null, null, null, null,
                           null, null, null, null, null, null,
                           'REPORT',
                           pa_req_rec.EMPLOYEE_ASSIGNMENT_ID,
                           pa_req_rec.PAY_RATE_DETERMINANT);
       exit;
     END LOOP;
     hr_utility.set_location('Exiting    ' || l_proc,10);
EXCEPTION
  when mass_error then raise;
  when others then
     pr('Error in '||l_proc);
     hr_utility.set_location('Error in '||l_proc||' Err is '||sqlerrm(sqlcode),20);
     l_mslerrbuf := 'Error in '||l_proc||'  Sql Err is '|| sqlerrm(sqlcode);
     raise mass_error;
END pop_dtls_from_pa_req;

--
--
--
--

function check_SELECT_flg(p_position_id    in NUMBER,
                          p_action         in VARCHAR2,
                          p_effective_DATE in DATE,
                          p_mre_id         in NUMBER,
                          p_sel_flg        in out NOCOPY VARCHAR2)
return BOOLEAN IS
   l_comments   VARCHAR2(150);
   l_mre_id     NUMBER;
   l_sel_flg    VARCHAR2(10);
   l_line       NUMBER := 0;

l_proc  VARCHAR2(72) :=  g_package || '.check_SELECT_flg';

BEGIN
  g_proc := 'check_SELECT_flg';

  --Initilization for NOCOPY Changes
  --
  l_sel_flg := p_sel_flg;
  --
   hr_utility.set_location('Entering    ' || l_proc,5);
   pr('in '||l_proc);
l_line := 5;
   get_extra_info_comments(p_position_id,p_effective_DATE,l_sel_flg,
                               l_comments,l_mre_id);
   pr('After get ext ');
   pr('Sel flg ',l_sel_flg,'Mre id '||to_char(l_mre_id));

   pr('After pr sel fl');

   p_sel_flg := l_sel_flg;

l_line := 10;
   if l_sel_flg is null then
      p_sel_flg := 'Y';
l_line := 15;
     --Bug#4126137 Commented ins_upd_pos_extra_info as this is invalidating all the positions.
     -- ins_upd_pos_extra_info(p_position_id,p_effective_DATE,'Y', null, p_mre_id);
   ELSIF l_sel_flg = 'Y' then
         if nvl(l_mre_id,0) <> nvl(p_mre_id,0) then
            p_sel_flg := 'N';
            --ins_upd_pos_extra_info(p_position_id,p_effective_DATE,'N', l_comments,
             --          p_mre_name);
         END IF;
   ELSIF l_sel_flg = 'N' then
         if nvl(l_mre_id,0) <> nvl(p_mre_id,0) then
            p_sel_flg := 'Y';
l_line := 20;
     --Bug#4126137 Commented ins_upd_pos_extra_info as this is invalidating all the positions.
     -- ins_upd_pos_extra_info(p_position_id,p_effective_DATE,'Y', null, p_mre_id);
         END IF;
   END IF;

l_line := 25;
   pr('Sel fl '||p_sel_flg,'Mre id '||to_char(l_mre_id));
     if p_action IN ('SHOW','REPORT') THEN
         return TRUE;
     ELSIF p_action = 'CREATE' THEN
         if p_sel_flg = 'Y' THEN
            return TRUE;
         ELSE
            return FALSE;
         END IF;
     END IF;
EXCEPTION
  when mass_error then raise;
  when others then
     -- NOCOPY Changes
     -- Reset IN OUT params and Set OUT params to null
     p_sel_flg := l_sel_flg;
     --
     pr('Error in '||l_proc);
     hr_utility.set_location('Error in '||l_proc||' Err is '||sqlerrm(sqlcode),20);
     l_mslerrbuf := 'Error in '||l_proc||' @'||to_char(l_line)||' Sql Err is '|| sqlerrm(sqlcode);

     raise mass_error;
END;

--
--
--

procedure ins_upd_pos_extra_info
               (p_position_id    in NUMBER,
	        p_effective_DATE in DATE,
                p_sel_flag       in VARCHAR2,
		p_comment        in VARCHAR2,
                p_mre_id         in NUMBER) is

   l_position_extra_info_id NUMBER;
   l_object_version_NUMBER NUMBER;
   l_pos_ei_data         per_position_extra_info%rowtype;

   CURSOR position_ext_cur (position NUMBER) is
   SELECT position_extra_info_id, object_version_NUMBER
     FROM PER_POSITION_EXTRA_INFO
    WHERE POSITION_ID = position
      and information_type = 'GHR_US_POS_MASS_ACTIONS';

l_proc    VARCHAR2(72) :=  g_package || '.ins_upd_pos_extra_info';
    l_eff_DATE DATE;

BEGIN
  hr_utility.set_location('Entering    ' || l_proc,5);
  g_proc := 'ins_upd_pos_extra_info';

  if p_effective_DATE > sysDATE then
       l_eff_DATE := sysDATE;
  ELSE
       l_eff_DATE := p_effective_DATE;
  END IF;

   ghr_history_fetch.fetch_positionei
                  (p_position_id           => p_position_id
                  ,p_information_type      => 'GHR_US_POS_MASS_ACTIONS'
                  ,p_DATE_effective        => l_eff_DATE
                  ,p_pos_ei_data           => l_pos_ei_data);

   l_position_extra_info_id  := l_pos_ei_data.position_extra_info_id;
   l_object_version_NUMBER := l_pos_ei_data.object_version_NUMBER;

   if l_position_extra_info_id is null then
      for pos_ext_rec in position_ext_cur(p_position_id)
      loop
         l_position_extra_info_id  := pos_ext_rec.position_extra_info_id;
         l_object_version_NUMBER := pos_ext_rec.object_version_NUMBER;
      END loop;
   END IF;

   if l_position_extra_info_id is not null then

----- Set the global variable not to fire the trigger
        ghr_api.g_api_dml       := TRUE;

      BEGIN
        ghr_position_extra_info_api.UPDATE_position_extra_info
                       (P_POSITION_EXTRA_INFO_ID   => l_position_extra_info_id
                       ,P_EFFECTIVE_DATE           => trunc(l_eff_DATE)
                       ,P_OBJECT_VERSION_NUMBER    => l_object_version_NUMBER
                       ,p_poei_INFORMATION3        => p_sel_flag
                       ,p_poei_INFORMATION4        => p_comment
                       ,p_poei_INFORMATION14       => to_char(p_mre_id)
                       ,P_POEI_INFORMATION_CATEGORY  => 'GHR_US_POS_MASS_ACTIONS');
      EXCEPTION when others then
                hr_utility.set_location('UPDATE posei error 1' || l_proc,10);
                hr_utility.set_location('Error in '||l_proc||' Err is '||sqlerrm(sqlcode),20);
      END;
----- Reset the global variable
        ghr_api.g_api_dml       := FALSE;

   ELSE
        -- Bug#4215231 Set the global variable not to fire the trigger
        ghr_api.g_api_dml       := TRUE;
        ghr_position_extra_info_api.create_position_extra_info
                       (P_POSITION_ID             => p_position_id
                       ,P_INFORMATION_TYPE        => 'GHR_US_POS_MASS_ACTIONS'
                       ,P_EFFECTIVE_DATE          => trunc(l_eff_DATE)
                       ,p_poei_INFORMATION3       => p_sel_flag
                       ,p_poei_INFORMATION4       => p_comment
                       ,p_poei_INFORMATION14       => to_char(p_mre_id)
                       ,P_POEI_INFORMATION_CATEGORY  => 'GHR_US_POS_MASS_ACTIONS'
                       ,P_POSITION_EXTRA_INFO_ID  => l_position_extra_info_id
                       ,P_OBJECT_VERSION_NUMBER   => l_object_version_NUMBER);

        --Bug#4215231 Reset the global variable
        ghr_api.g_api_dml       := FALSE;

   END IF;
     hr_utility.set_location('Exiting    ' || l_proc,30);

-- There is a trigger on Position extra Info. Whenever UPDATEd/created the
-- main position associated with it becomes invalid.
-- We shall call valiDATE_perwsdpo procedure to set the status = VALID.
-- Actually there should be a global flag called fire_trigger in session_var
-- but it doesn't seem to be functional right now.

--- Commented the following two lines to remove Validation functionality on Position.
-- ghr_valiDATE_perwsdpo.valiDATE_perwsdpo(p_position_id);
-- ghr_valiDATE_perwsdpo.UPDATE_posn_status(p_position_id);


EXCEPTION
  when mass_error then raise;
  when others then
     pr('Error in '||l_proc);
     hr_utility.set_location('Error in '||l_proc||' Err is '||sqlerrm(sqlcode),20);
     l_mslerrbuf := 'Error in '||l_proc||'  Sql Err is '|| sqlerrm(sqlcode);
     raise mass_error;
END ins_upd_pos_extra_info;

--
--
--

function get_mre_name(p_mre_id in NUMBER) return VARCHAR2 is

   CURSOR mre_cur is
   SELECT NAME
     FROM GHR_MASS_REALIGNMENT
    WHERE MASS_REALIGNMENT_ID = p_mre_id;

  l_mre_name VARCHAR2(150);
  l_proc  VARCHAR2(72) :=  g_package || '.get_mre_name';
BEGIN
  g_proc := 'get_mre_name';
  hr_utility.set_location('Entering    ' || l_proc,5);
  FOR mre_REC IN mre_cur
  LOOP
     l_mre_name := mre_rec.name;
     exit;
  END LOOP;
  return (l_mre_name);
END;

--
--
--

procedure purge_old_data (p_mass_session_id in NUMBER) is
l_proc                      VARCHAR2(72)
          :=  g_package || '.purge_old_data';
BEGIN
  g_proc := 'purge_old_data';

   hr_utility.set_location('Entering    ' || l_proc,5);
   delete from ghr_mass_actions_preview
    WHERE mass_action_type = 'REALIGNMENT'
      and session_id  = userenv('sessionid');
   COMMIT;
   hr_utility.set_location('Exiting    ' || l_proc,10);
EXCEPTION
  when mass_error then raise;
  when others then
     pr('Error in '||l_proc);
     hr_utility.set_location('Error in '||l_proc||' Err is '||sqlerrm(sqlcode),20);
     l_mslerrbuf := 'Error in '||l_proc||'  Sql Err is '|| sqlerrm(sqlcode);
     raise mass_error;
END;

--
--
--

procedure UPDATE_sel_flg (p_position_id in NUMBER,p_effective_DATE in DATE) is

   l_position_extra_info_id NUMBER;
   l_object_version_NUMBER NUMBER;
   l_pos_ei_data         per_position_extra_info%rowtype;
   l_proc      VARCHAR2(72) :=  g_package || '.UPDATE_sel_flg';
   l_eff_DATE DATE;
BEGIN
  g_proc := 'UPDATE_sel_flg';

  hr_utility.set_location('Entering    ' || l_proc,5);
  if p_effective_DATE > sysDATE then
       l_eff_DATE := sysDATE;
  ELSE
       l_eff_DATE := p_effective_DATE;
  END IF;

   ghr_history_fetch.fetch_positionei
                  (p_position_id           => p_position_id
                  ,p_information_type      => 'GHR_US_POS_MASS_ACTIONS'
                  ,p_DATE_effective        => l_eff_DATE
                  ,p_pos_ei_data           => l_pos_ei_data);

   l_position_extra_info_id  := l_pos_ei_data.position_extra_info_id;
   l_object_version_NUMBER := l_pos_ei_data.object_version_NUMBER;

   if l_position_extra_info_id is not null then

----- Set the global variable not to fire the trigger
        ghr_api.g_api_dml       := TRUE;

      BEGIN
        ghr_position_extra_info_api.UPDATE_position_extra_info
                       (P_POSITION_EXTRA_INFO_ID   => l_position_extra_info_id
                       ,P_EFFECTIVE_DATE         => trunc(l_eff_DATE)
                       ,P_OBJECT_VERSION_NUMBER  => l_object_version_NUMBER
                       ,p_poei_INFORMATION5       => NULL
                       ,p_poei_INFORMATION6       => NULL
                       ,P_POEI_INFORMATION_CATEGORY  => 'GHR_US_POS_MASS_ACTIONS');
      EXCEPTION when others then
                hr_utility.set_location('UPDATE posei error 2' || l_proc,10);
                hr_utility.set_location('Error in '||l_proc||' Err is '||sqlerrm(sqlcode),20);
      END;

----- Reset the global variable
        ghr_api.g_api_dml       := FALSE;


--- Commented the following two lines to remove Validation functionality on Position.
----    ghr_valiDATE_perwsdpo.valiDATE_perwsdpo(p_position_id);
----    ghr_valiDATE_perwsdpo.UPDATE_posn_status(p_position_id);

   END IF;
   hr_utility.set_location('Exiting    ' || l_proc,30);
EXCEPTION
  when mass_error then raise;
  when others then
     hr_utility.set_location('Error in '||l_proc||' Err is '||sqlerrm(sqlcode),20);
     l_mslerrbuf := 'Error in '||l_proc||'  Sql Err is '|| sqlerrm(sqlcode);
     raise mass_error;
END UPDATE_sel_flg;

--
--
--

FUNCTION check_eligibility(p_org_structure_id        in VARCHAR2,
                           p_office_symbol           in VARCHAR2,
                           p_personnel_office_id     in VARCHAR2,
                           p_agency_sub_element_code in VARCHAR2,
                           p_l_org_structure_id      in VARCHAR2,
                           p_l_office_symbol         in VARCHAR2,
                           p_l_personnel_office_id   in VARCHAR2,
                           p_l_agency_sub_element_code in VARCHAR2,
                           p_person_id               in NUMBER,
                           p_effective_DATE          in DATE,
                           p_action                  in VARCHAR2)
return BOOLEAN is

   l_row_cnt      NUMBER := 0;
l_proc            VARCHAR2(72) :=  g_package || '.check_eligibility';
BEGIN
  g_proc := 'check_eligibility';
  hr_utility.set_location('Entering    ' || l_proc,5);

  if p_org_structure_id is not null then
      if p_org_structure_id <> nvl(p_l_org_structure_id,'NULL!~') then
         return false;
      END IF;
  END IF;

  if p_office_symbol is not null then
      if p_office_symbol <> nvl(p_l_office_symbol,'NULL!~') then
         return false;
      END IF;
  END IF;

  if p_personnel_office_id is not null then
      if p_personnel_office_id <> nvl(p_l_personnel_office_id,'NULL!~') then
         return false;
      END IF;
  END IF;

-- VSM - p_agency_sub_element_code can have 2 or 4 chars.
-- 2 char - Check for agency code only
-- 4 char - Check for agency code and subelement
  if p_agency_sub_element_code is not null then
      if substr(p_agency_sub_element_code, 1, 2) <>
           nvl(substr(p_l_agency_sub_element_code, 1, 2), 'NULL!~') then
         return false;
      END IF;
  END IF;

  if substr(p_agency_sub_element_code, 3, 2) is not null then
      if substr(p_agency_sub_element_code, 3, 2) <>
             nvl(substr(p_l_agency_sub_element_code, 3, 2), 'NULL!~') then
         return false;
      END IF;
  END IF;
--
-- VSM END enhancement
--

  if p_action = 'CREATE' THEN
    if person_in_pa_req_1noa
          (p_person_id      => p_person_id,
           p_effective_DATE => p_effective_DATE,
           p_first_noa_code => '790'
           ) then
       return false;
    END IF;
/*************
    if person_in_pa_req_2noa
          (p_person_id      => p_person_id,
           p_effective_DATE => p_effective_DATE,
           p_second_noa_code => '790'
           ) then
       return false;
    END IF;
*************/
  END IF;

  pr('Eligible');
  return true;

EXCEPTION
  when mass_error then raise;
  when others then
     pr('Error in '||l_proc);
     hr_utility.set_location('Error in '||l_proc||' Err is '||sqlerrm(sqlcode),20);
     l_mslerrbuf := 'Error in '||l_proc||'  Sql Err is '|| sqlerrm(sqlcode);
     raise mass_error;
END check_eligibility;

--
--
--

function person_in_pa_req_1noa
          (p_person_id      in NUMBER,
           p_effective_DATE in DATE,
           p_first_noa_code in VARCHAR2
           )
  return BOOLEAN is
--
  l_name            per_people_f.full_name%type;
  -- Bug#3718167  Added l_ssn
  l_ssn             per_people_f.national_identifier%TYPE;
  l_code_action     VARCHAR2(65);
  l_pa_request_id   ghr_pa_requests.pa_request_id%TYPE;

  cursor csr_action_taken is
      SELECT pr.pa_request_id, max(pa_routing_history_id) pa_routing_history_id
        from ghr_pa_requests pr, ghr_pa_routing_history prh
      WHERE pr.pa_request_id = prh.pa_request_id
      and   person_id = p_person_id
      and   first_noa_code = p_first_noa_code
      and   effective_DATE = p_effective_DATE
      and nvl(pr.first_noa_cancel_or_correct,'X') <> ghr_history_api.g_cancel
--Bug 657439
--      and nvl(pr.first_noa_cancel_or_correct,'X') <> 'CANCELED'
      group by pr.pa_request_id;

    -- Bug#3718167 Added SSN in the cursor
    cursor csr_name is
    SELECT substr(pr.employee_last_name || ', ' || pr.employee_first_name,1,240) fname,
           pr.employee_national_identifier SSN
    from ghr_pa_requests pr
    WHERE pr.pa_request_id = l_pa_request_id;

    cursor pa_hist_cur (p_r_hist_id NUMBER) is
      SELECT nvl(action_taken,' ') action_taken
        from ghr_pa_routing_history
      WHERE pa_routing_history_id = p_r_hist_id;

  l_action_taken    ghr_pa_routing_history.action_taken%TYPE;

BEGIN
  g_proc := 'person_in_pa_req_1noa';

     if p_first_noa_code = '790' then
        l_code_action   := ' - Realignment ';
  ELSIF p_first_noa_code = '352' then
        l_code_action   := ' - Transfer Out ';
  ELSIF p_first_noa_code = '132' then
        l_code_action   := ' - Transfer In ';
  END IF;

   for v_action_taken in csr_action_taken
    loop
       l_pa_request_id := v_action_taken.pa_request_id;
       for v_name in csr_name
       loop
           l_name := v_name.fname;
	   -- Bug#3718167 Added l_ssn statement
	   l_ssn  := v_name.ssn;
       exit;
       END loop;
       for pa_hist_rec in pa_hist_cur (v_action_taken.pa_routing_history_id)
       loop
           l_action_taken := pa_hist_rec.action_taken;
           exit;
       END loop;
       if l_action_taken <> 'CANCELED' then
          -- Bug#3718167 Added SSN in the following message
          ghr_mto_int.log_message(
          p_procedure => 'RPA Exists Already',
          p_message   => 'Name: '|| l_name || '; SSN: '||l_ssn||
	                 l_code_action ||
                         ' RPA Exists for the given effective DATE ' );
          return true;
       END IF;
   END loop;
   return false;
END person_in_pa_req_1noa;

--
--
--

function person_in_pa_req_2noa
          (p_person_id       in NUMBER,
           p_effective_DATE  in DATE,
           p_second_noa_code in VARCHAR2
           )
  return BOOLEAN is
--
  cursor csr_action_taken is
      SELECT pr.pa_request_id, max(pa_routing_history_id) pa_routing_history_id
        from ghr_pa_requests pr, ghr_pa_routing_history prh
      WHERE pr.pa_request_id = prh.pa_request_id
      and   nvl(person_id,0) = p_person_id
      and   nvl(second_noa_code,0) = p_second_noa_code
      and   trunc(nvl(effective_DATE,sysDATE)) = trunc(p_effective_DATE)
      and nvl(pr.second_noa_cancel_or_correct,'X') <> ghr_history_api.g_cancel
--Bug 657439
--      and nvl(pr.first_noa_cancel_or_correct,'X') <> 'CANCELED'
      group by pr.pa_request_id;

    cursor pa_hist_cur (p_r_hist_id NUMBER) is
      SELECT nvl(action_taken,' ') action_taken
        from ghr_pa_routing_history
      WHERE pa_routing_history_id = p_r_hist_id;

  l_action_taken    ghr_pa_routing_history.action_taken%TYPE;
BEGIN
  g_proc := 'person_in_pa_req_2noa';
   for v_action_taken in csr_action_taken
    loop
       for pa_hist_rec in pa_hist_cur (v_action_taken.pa_routing_history_id)
       loop
           l_action_taken := pa_hist_rec.action_taken;
           exit;
       END loop;
       if l_action_taken <> 'CANCELED' then
          return true;
       END IF;
   END loop;
   return false;
END person_in_pa_req_2noa;

--
--
--

procedure get_pos_grp1_ddf (p_position_id           in
                                   per_assignments_f.position_id%type,
                            p_effective_DATE        in DATE,
                            p_personnel_office_id   out NOCOPY VARCHAR2,
                            p_org_structure_id      out NOCOPY VARCHAR2,
                            p_office_symbol         out NOCOPY VARCHAR2,
                            p_position_organization out NOCOPY VARCHAR2,
                            p_pos_ei_data           OUT NOCOPY
			                per_position_extra_info%rowtype)
IS

l_proc                      VARCHAR2(72)
          :=  g_package || '.get_pos_grp1_ddf';
--l_pos_ei_data         per_position_extra_info%type;

BEGIN
  g_proc := 'get_pos_grp1_ddf';

  hr_utility.set_location('Entering    ' || l_proc,5);
     ghr_history_fetch.fetch_positionei
                  (p_position_id           => p_position_id
                  ,p_information_type      => 'GHR_US_POS_GRP1'
                  ,p_DATE_effective        => p_effective_DATE
                  ,p_pos_ei_data           => p_pos_ei_data
                                        );
     p_personnel_office_id           :=  p_pos_ei_data.poei_information3;
     p_office_symbol                 :=  p_pos_ei_data.poei_information4;
     p_org_structure_id              :=  p_pos_ei_data.poei_information5;
     p_position_organization         :=  p_pos_ei_data.poei_information21;

     hr_utility.set_location('Exiting    ' || l_proc,10);
EXCEPTION
  when mass_error then raise;
  when others then
     -- NOCOPY changes
     -- Reset IN OUT params and set OUT params
     p_personnel_office_id           := NULL;
     p_office_symbol                 := NULL;
     p_org_structure_id              := NULL;
     p_position_organization         := NULL;
     p_pos_ei_data                   := NULL;

     pr('Error in '||l_proc);
     hr_utility.set_location('Error in '||l_proc||' Err is '||sqlerrm(sqlcode),20);
     l_mslerrbuf := 'Error in '||l_proc||'  Sql Err is '|| sqlerrm(sqlcode);
     raise mass_error;
END get_pos_grp1_ddf;

--
--
--

procedure get_pos_grp2_ddf (p_position_id         in
                                   per_assignments_f.position_id%type,
                            p_effective_DATE      in DATE,
                            p_org_func_code       out NOCOPY VARCHAR2,
                            p_appropriation_code1 out NOCOPY VARCHAR2,
                            p_appropriation_code2 out NOCOPY VARCHAR2)
          ---                  p_pos_ei_data     OUT per_position_extra_info%rowtype)
IS

l_proc                      VARCHAR2(72)
          :=  g_package || '.get_pos_grp2_ddf';
l_pos_ei_data         per_position_extra_info%rowtype;

BEGIN
  g_proc := 'get_pos_grp2_ddf';
  hr_utility.set_location('Entering    ' || l_proc,5);
     ghr_history_fetch.fetch_positionei
                  (p_position_id           => p_position_id
                  ,p_information_type      => 'GHR_US_POS_GRP2'
                  ,p_DATE_effective        => p_effective_DATE
                  ,p_pos_ei_data           => l_pos_ei_data
                                        );
     p_org_func_code           :=  l_pos_ei_data.poei_information4;
     p_appropriation_code1     :=  l_pos_ei_data.poei_information13;
     p_appropriation_code2     :=  l_pos_ei_data.poei_information14;

     hr_utility.set_location('Exiting    ' || l_proc,10);
EXCEPTION
  when mass_error then raise;
  when others then
     -- NOCOPY changes
     -- Reset IN OUT params and set OUT params
     p_org_func_code           :=  NULL;
     p_appropriation_code1     :=  NULL;
     p_appropriation_code2     :=  NULL;
     --
     pr('Error in '||l_proc);
     hr_utility.set_location('Error in '||l_proc||' Err is '||sqlerrm(sqlcode),20);
     l_mslerrbuf := 'Error in '||l_proc||'  Sql Err is '|| sqlerrm(sqlcode);
     raise mass_error;
END get_pos_grp2_ddf;

--
--
--

PROCEDURE GET_FIELD_DESC (p_agency_code     in VARCHAR2,
                          p_to_agency_code  in VARCHAR2,
                          p_approp_code1    in VARCHAR2,
                          p_approp_code2    in VARCHAR2,
                          p_pay_plan        in VARCHAR2,
                          p_poi_code        in VARCHAR2,
                          p_to_poi_code     in VARCHAR2,
                          p_org_id          in NUMBER,
                          p_to_org_id       in NUMBER,

                          p_agency_desc       out NOCOPY VARCHAR2,
                          p_to_agency_desc    out NOCOPY VARCHAR2,
                          p_approp_code1_desc out NOCOPY VARCHAR2,
                          p_approp_code2_desc out NOCOPY VARCHAR2,
                          p_pay_plan_desc     out NOCOPY VARCHAR2,
                          p_poi_name          out NOCOPY VARCHAR2,
                          p_to_poi_name       out NOCOPY VARCHAR2,
                          p_org_name          out NOCOPY VARCHAR2,
                          p_to_org_name       out NOCOPY VARCHAR2)
IS
  l_proc  VARCHAR2(72)
          :=  g_package || '.get_field_desc';
BEGIN
  g_proc := 'GET_FIELD_DESC';

   hr_utility.set_location('Entering    ' || l_proc,5);
   p_agency_desc := GET_FND_COMMON_LOOKUP (p_agency_code,'GHR_US_AGENCY_CODE');
   p_to_agency_desc := GET_FND_COMMON_LOOKUP (p_to_agency_code,
                                'GHR_US_AGENCY_CODE');
   p_approp_code1_desc := GET_FND_COMMON_LOOKUP (p_approp_code1,
                       'GHR_US_APPROPRIATION_CODE1');
   p_approp_code2_desc := GET_FND_COMMON_LOOKUP (p_approp_code2,
                       'GHR_US_APPROPRIATION_CODE2');
   p_poi_name := GET_POI_NAME (p_poi_code);
   p_to_poi_name := GET_POI_NAME (p_to_poi_code);
   p_pay_plan_desc := GET_PP_NAME (p_pay_plan);
/*
   p_org_name := get_organization_name (to_NUMBER(p_org_id));
   p_to_org_name := get_organization_name (to_NUMBER(p_to_org_id));
*/
   p_org_name := get_organization_name (to_NUMBER(p_org_id));
   p_to_org_name := get_organization_name (to_NUMBER(p_to_org_id));

-- NOCOPY Changes
-- reset IN OUT Params and set OUT Params
EXCEPTION
when others then
     p_agency_desc       := NULL;
     p_to_agency_desc    := NULL;
     p_approp_code1_desc := NULL;
     p_approp_code2_desc := NULL;
     p_pay_plan_desc     := NULL;
     p_poi_name          := NULL;
     p_to_poi_name       := NULL;
     p_org_name          := NULL;
     p_to_org_name       := NULL;
END;


FUNCTION GET_FND_COMMON_LOOKUP
                (p_lookup_code in VARCHAR2,
                 p_type        in VARCHAR2)
RETURN VARCHAR2 IS
 CURSOR CUR_lookup IS
 SELECT LOOKUP_CODE,MEANING
   FROM HR_LOOKUPS
  WHERE LOOKUP_TYPE = p_type
    AND ENABLED_FLAG = 'Y'
    AND trunc(sysDATE)
        BETWEEN NVL(START_DATE_ACTIVE,trunc(sysDATE))
            AND NVL(END_DATE_ACTIVE,trunc(sysDATE))
    AND LOOKUP_CODE = p_lookup_code;

  l_meaning VARCHAR2(150);
  l_proc  VARCHAR2(72) :=  g_package || '.get_fnd_common_lookup';
BEGIN
  g_proc := 'GET_FND_COMMON_LOOKUP';

  hr_utility.set_location('Entering    ' || l_proc,5);
  FOR lookup_rec IN CUR_lookup
  LOOP
     l_meaning := lookup_rec.meaning;
     exit;
  END LOOP;
  return (l_meaning);
END;

--
--
--

FUNCTION GET_PP_NAME (PP IN VARCHAR2) RETURN VARCHAR2 IS

 CURSOR CUR_PP IS
 SELECT pay_plan,description
   from ghr_pay_plans
  WHERE PAY_PLAN = PP;

  l_pp_desc VARCHAR2(150);
  l_proc  VARCHAR2(72) :=  g_package || '.get_pp_name';
BEGIN
  g_proc := 'GET_PP_NAME';
  hr_utility.set_location('Entering    ' || l_proc,5);
  FOR PP_REC IN CUR_PP
  LOOP
     l_pp_desc := pp_rec.description;
     exit;
  END LOOP;
  return (l_pp_desc);
END;

--
--
--

FUNCTION GET_POI_NAME (P_POI IN VARCHAR2) RETURN VARCHAR2 IS

 CURSOR CUR_POI IS
 SELECT description
   from ghr_pois
  WHERE PERSONNEL_OFFICE_ID = p_poi;

  l_poi_desc VARCHAR2(150);
  l_proc  VARCHAR2(72) :=  g_package || '.get_poi_name';
BEGIN
  g_proc := 'GET_POI_NAME';
  hr_utility.set_location('Entering    ' || l_proc,5);
  FOR POI_REC IN CUR_POI
  LOOP
     l_poi_desc := poi_rec.description;
     exit;
  END LOOP;
  return (l_poi_desc);
END;

--
--
--

FUNCTION get_organization_name (p_org_id in NUMBER) RETURN VARCHAR2 IS

  CURSOR MRE_ORG_CUR (ORG_id IN NUMBER) IS
  SELECT name, organization_id
    from per_organization_units
   WHERE internal_external_flag = 'INT'
     and trunc(sysDATE) between DATE_from and nvl(DATE_to,trunc(sysDATE+1))
     and organization_id = org_id;

/* business_group_id + 0 = :ctl_globals.business_group_id*/

l_org_name        hr_organization_units.name%type;
l_org_id          NUMBER;

l_proc  VARCHAR2(72)
          :=  g_package || '.get_organization_name';
BEGIN
  g_proc := 'get_organization_name';
    hr_utility.set_location('Entering    ' || l_proc,5);
    for mre_rec in mre_org_cur (p_org_id)
    LOOP
      l_org_name := mre_rec.name;
      l_org_id   := mre_rec.organization_id;
      exit;
    END loop;
    return(l_org_name);
END;

--
--
--

PROCEDURE get_extra_info_comments
                (p_position_id     in NUMBER,
                 p_effective_DATE  in DATE,
                 p_sel_flag        in out NOCOPY VARCHAR2,
                 p_comments        in out NOCOPY VARCHAR2,
                 p_mre_id          in out NOCOPY NUMBER) IS

  l_sel_flag           VARCHAR2(30);
  l_comments           VARCHAR2(4000);
  l_mre_id             NUMBER;
  l_pos_ei_data        per_position_extra_info%rowtype;
  l_proc  VARCHAR2(72) := g_package || '.get_extra_info_comments';
  l_eff_DATE DATE;
  l_char_mre_id VARCHAR2(30);

BEGIN
  g_proc := 'get_extra_info_comments';
    hr_utility.set_location('Entering    ' || l_proc,5);
    pr('In '||l_proc);

    -- Initialization for NOCOPY Changes
    l_sel_flag     := p_sel_flag;
    l_comments     := p_comments;
    l_mre_id       := p_mre_id;
    --
/*
  if p_effective_DATE > sysDATE then
       l_eff_DATE := sysDATE;
  ELSE
       l_eff_DATE := p_effective_DATE;
  END IF;
*/
    l_eff_DATE := p_effective_DATE;

   pr(l_proc||'---> before fetch pos ei');

     ghr_history_fetch.fetch_positionei
                  (p_position_id             => p_position_id
                  ,p_information_type      => 'GHR_US_POS_MASS_ACTIONS'
                  ,p_DATE_effective        => l_eff_DATE
                  ,p_pos_ei_data           => l_pos_ei_data);

   pr(l_proc||'---> after fetch pos ei');

    l_sel_flag := l_pos_ei_data.poei_information3;

   pr(l_proc||'---> after sel_flg assignment');
    l_comments := l_pos_ei_data.poei_information4;
   pr(l_proc||'---> after comments  assignment');
    l_char_mre_id := l_pos_ei_data.poei_information14;
   pr(l_proc||'---> after l_mre_id  assignment');
    l_mre_id := to_NUMBER(l_char_mre_id);
   pr(l_proc||'---> after p_mre_id  assignment');

    p_sel_flag     := l_sel_flag;
    p_comments     := l_comments;
    p_mre_id       := l_mre_id;

    pr('position ext id',to_char(l_pos_ei_data.position_extra_info_id),
                  to_char(l_pos_ei_data.object_version_NUMBER));
EXCEPTION
  when mass_error then raise;
  when others then
  -- NOCOPY Changes
  -- Reset INOUT Params and set OUT params
  --
    p_sel_flag     := l_sel_flag;
    p_comments     := l_comments;
    p_mre_id       := l_mre_id;
  --
     pr('Error in '||l_proc);
     hr_utility.set_location('Error in '||l_proc||' Err is '||sqlerrm(sqlcode),20);
     l_mslerrbuf := 'Error in '||l_proc||' Sql Err is '|| sqlerrm(sqlcode);
     raise mass_error;
END;

--
--
--

procedure create_mass_act_prev (
 p_effective_DATE          in DATE,
 p_DATE_of_birth           in DATE,
 p_full_name               in VARCHAR2,
 p_national_identifier     in VARCHAR2,
 p_duty_station_code       in VARCHAR2,
 p_duty_station_desc       in VARCHAR2,
 p_personnel_office_id     in VARCHAR2,
 p_position_id             in per_assignments_f.position_id%type,
 p_position_title          in VARCHAR2,
 p_position_NUMBER         in VARCHAR2,
 p_position_seq_no         in VARCHAR2,
 p_org_structure_id        in VARCHAR2,
 p_agency_sub_element_code in VARCHAR2,
 p_person_id               in NUMBER,
 p_mass_realignment_id     in NUMBER,
 p_sel_flg                 in VARCHAR2,
 p_grade_or_level          in VARCHAR2,
 p_step_or_rate            in VARCHAR2,
 p_pay_plan                in VARCHAR2,
 p_occ_series              in VARCHAR2,
 p_office_symbol           in VARCHAR2,
 p_organization_id         in NUMBER,
 p_organization_name       in VARCHAR2,
 p_positions_organization  in VARCHAR2,
 t_personnel_office_id     in VARCHAR2,
 t_sub_element_code        in VARCHAR2,
 t_duty_station_id         in NUMBER,
 t_duty_station_code       in VARCHAR2,
 t_duty_station_desc       in VARCHAR2,
 t_office_symbol           in VARCHAR2,
 t_payroll_office_id       in VARCHAR2,
 t_org_func_code           in VARCHAR2,
 t_appropriation_code1     in VARCHAR2,
 t_appropriation_code2     in VARCHAR2,
 t_position_organization   in VARCHAR2,
 p_action                  in VARCHAR2,
 p_assignment_id           in NUMBER,
 p_pay_rate_determinant    in VARCHAR2)
is

 l_comb_rem VARCHAR2(30);
l_proc                      VARCHAR2(72)
          :=  g_package || '.create_mass_act_prev';

l_agency_sub_elem_desc       VARCHAR2(80);
t_sub_element_desc           VARCHAR2(80);
t_appropriation_code1_desc   VARCHAR2(80);
t_appropriation_code2_desc   VARCHAR2(80);
l_pay_plan_desc              VARCHAR2(80);
l_position_organization_name VARCHAR2(240);
l_poi_desc                   VARCHAR2(80);
t_poi_desc                   VARCHAR2(80);
t_position_organization_name VARCHAR2(240);

 l_cust_rec     ghr_mass_act_custom.ghr_mass_custom_out_rec_type;
 l_cust_in_rec  ghr_mass_act_custom.ghr_mass_custom_in_rec_type;
----Temp Promo Changes.
 l_step_or_rate  VARCHAR2(30);
 l_retained_grade_rec  ghr_pay_calc.retained_grade_rec_type;

BEGIN
  g_proc := 'create_mass_act_prev';

  hr_utility.set_location('Entering    ' || l_proc,5);

pr('Inside ghr_cpdf_temp insert realign id ',to_char(p_mass_realignment_id),null);
pr('t_pos_org is',t_position_organization);

      GET_FIELD_DESC (p_agency_sub_element_code,
                      t_sub_element_code,
                      t_appropriation_code1,
                      t_appropriation_code2,
                      p_pay_plan,
                      p_personnel_office_id,
                      t_personnel_office_id,
                      p_positions_organization,
                      t_position_organization,

                      l_agency_sub_elem_desc,
                      t_sub_element_desc,
                      t_appropriation_code1_desc,
                      t_appropriation_code2_desc,
                      l_pay_plan_desc,
                      l_poi_desc,
                      t_poi_desc,
                      l_position_organization_name,
                      t_position_organization_name);

  BEGIN
     l_cust_in_rec.person_id := p_person_id;
     l_cust_in_rec.position_id := p_position_id;
     l_cust_in_rec.assignment_id := p_assignment_id;
     l_cust_in_rec.national_identifier := p_national_identifier;
     l_cust_in_rec.mass_action_type := 'REALIGNMENT';
     l_cust_in_rec.mass_action_id := p_mass_realignment_id;
     l_cust_in_rec.effective_DATE := p_effective_DATE;

     GHR_MASS_ACT_CUSTOM.pre_insert (
                       p_cust_in_rec => l_cust_in_rec,
                       p_cust_rec => l_cust_rec);

  EXCEPTION
     when others then
     hr_utility.set_location('Error in Mass Act Custom '||
              'Err is '||sqlerrm(sqlcode),20);
     l_mslerrbuf := 'Error in Mass Act Custom '||
              'Err is '|| sqlerrm(sqlcode);
     raise mass_error;
  END;

  l_step_or_rate := p_step_or_rate;

  IF nvl(p_pay_rate_determinant,'X') in ('A','B','E','F') AND
     ghr_msl_pkg.check_grade_retention(p_pay_rate_determinant
                                ,p_person_id,p_effective_DATE) = 'REGULAR' THEN
     BEGIN
          l_retained_grade_rec :=
            ghr_pc_basic_pay.get_retained_grade_details
                                      ( p_person_id,
                                        p_effective_DATE);
            if l_retained_grade_rec.temp_step is not null then
               l_step_or_rate := l_retained_grade_rec.temp_step;
            END IF;
     EXCEPTION
        when others then
                l_mslerrbuf := 'Preview -  Others error in Get retained grade '||
                         'Error is '||' Sql Err is '|| sqlerrm(sqlcode);
                ghr_mre_pkg.pr('Person ID '||to_char(p_person_id),'ERROR 2',l_mslerrbuf);
                raise mass_error;
     END;
  END IF;


insert into GHR_MASS_ACTIONS_PREVIEW
(
 mass_action_type,
 --report_type,
 ui_type,
 session_id,
 effective_DATE,
 employee_DATE_of_birth,
 full_name,
 national_identifier,
 duty_station_code,
 duty_station_desc,
 personnel_office_id,
 position_id,
 position_title,
 position_NUMBER,
 position_seq_no,
 org_structure_id,
 agency_code,
 person_id,
 SELECT_flag,
 first_noa_code,
 grade_or_level,
 step_or_rate,
 pay_plan,
 office_symbol,
 organization_id,
 organization_name,
 occ_code,
 positions_organization,
 to_personnel_office_id,
 to_agency_code,
 to_duty_station_id,
 to_duty_station_code,
 to_duty_station_desc,
 to_office_symbol,
 to_payroll_office_id,
 to_org_func_code,
 to_appropriation_code1,
 to_appropriation_code2,
 to_positions_organization,

 AGENCY_DESC,
 TO_AGENCY_DESC,
 TO_APPROPRIATION_CODE1_DESC,
 TO_APPROPRIATION_CODE2_DESC,
 PAY_PLAN_DESC,
 POI_DESC,
 TO_POI_DESC,
 POSITIONS_ORGANIZATION_NAME,
 TO_POSITIONS_ORG_NAME,
 USER_ATTRIBUTE1,
 USER_ATTRIBUTE2,
 USER_ATTRIBUTE3,
 USER_ATTRIBUTE4,
 USER_ATTRIBUTE5,
 USER_ATTRIBUTE6,
 USER_ATTRIBUTE7,
 USER_ATTRIBUTE8,
 USER_ATTRIBUTE9,
 USER_ATTRIBUTE10,
 USER_ATTRIBUTE11,
 USER_ATTRIBUTE12,
 USER_ATTRIBUTE13,
 USER_ATTRIBUTE14,
 USER_ATTRIBUTE15,
 USER_ATTRIBUTE16,
 USER_ATTRIBUTE17,
 USER_ATTRIBUTE18,
 USER_ATTRIBUTE19,
 USER_ATTRIBUTE20,
 USER_ATTRIBUTE21,
 USER_ATTRIBUTE22,
 USER_ATTRIBUTE23,
 USER_ATTRIBUTE24,
 USER_ATTRIBUTE25,
 USER_ATTRIBUTE26,
 USER_ATTRIBUTE27,
 USER_ATTRIBUTE28,
 USER_ATTRIBUTE29,
 USER_ATTRIBUTE30
)
values
(
 'REALIGNMENT',
 /*--decode(p_action,'REPORT',userenv('SESSIONID'),p_mass_realignment_id),*/
 decode(p_action,'SHOW','FORM','REPORT'),
 userenv('SESSIONID'),
 p_effective_DATE,
 p_DATE_of_birth,
 p_full_name,
 p_national_identifier,
 p_duty_station_code,
 p_duty_station_desc,
 p_personnel_office_id,
 p_position_id,
 p_position_title,
 p_position_NUMBER,
 to_NUMBER(p_position_seq_no),
 p_org_structure_id,
 p_agency_sub_element_code,
 p_person_id,
 p_sel_flg,
 '790',
 p_grade_or_level,
 l_step_or_rate,
 p_pay_plan,
 p_office_symbol,
 p_organization_id,
 p_organization_name,
 p_occ_series,
 p_positions_organization,
 decode(p_sel_flg,'N',NULL,t_personnel_office_id),
 decode(p_sel_flg,'N',NULL,t_sub_element_code),
 decode(p_sel_flg,'N',NULL,t_duty_station_id),
 decode(p_sel_flg,'N',NULL,t_duty_station_code),
 decode(p_sel_flg,'N',NULL,t_duty_station_desc),
 decode(p_sel_flg,'N',NULL,t_office_symbol),
 decode(p_sel_flg,'N',NULL,t_payroll_office_id),
 decode(p_sel_flg,'N',NULL,t_org_func_code),
 decode(p_sel_flg,'N',NULL,t_appropriation_code1),
 decode(p_sel_flg,'N',NULL,t_appropriation_code2),

 decode(p_sel_flg,'N',NULL,t_position_organization),
 l_agency_sub_elem_desc,
 decode(p_sel_flg,'N',NULL,t_sub_element_desc),
 decode(p_sel_flg,'N',NULL,t_appropriation_code1_desc),
 decode(p_sel_flg,'N',NULL,t_appropriation_code2_desc),
 l_pay_plan_desc,
 l_poi_desc,
 decode(p_sel_flg,'N',NULL,t_poi_desc),
 l_position_organization_name,
 decode(p_sel_flg,'N',NULL,t_position_organization_name),
 l_cust_rec.user_attribute1,
 l_cust_rec.user_attribute2,
 l_cust_rec.user_attribute3,
 l_cust_rec.user_attribute4,
 l_cust_rec.user_attribute5,
 l_cust_rec.user_attribute6,
 l_cust_rec.user_attribute7,
 l_cust_rec.user_attribute8,
 l_cust_rec.user_attribute9,
 l_cust_rec.user_attribute10,
 l_cust_rec.user_attribute11,
 l_cust_rec.user_attribute12,
 l_cust_rec.user_attribute13,
 l_cust_rec.user_attribute14,
 l_cust_rec.user_attribute15,
 l_cust_rec.user_attribute16,
 l_cust_rec.user_attribute17,
 l_cust_rec.user_attribute18,
 l_cust_rec.user_attribute19,
 l_cust_rec.user_attribute20,
 l_cust_rec.user_attribute21,
 l_cust_rec.user_attribute22,
 l_cust_rec.user_attribute23,
 l_cust_rec.user_attribute24,
 l_cust_rec.user_attribute25,
 l_cust_rec.user_attribute26,
 l_cust_rec.user_attribute27,
 l_cust_rec.user_attribute28,
 l_cust_rec.user_attribute29,
 l_cust_rec.user_attribute30
);

     hr_utility.set_location('Exiting    ' || l_proc,10);
EXCEPTION
  when mass_error then raise;
  when others then
     pr('Error in '||l_proc);
     pr('Position title is '||p_position_title||' Length is '||to_char(length(p_position_title)));
     hr_utility.set_location('Error in '||l_proc||' Err is '||sqlerrm(sqlcode),20);
     l_mslerrbuf := 'Error in '||l_proc||'  Sql Err is '|| sqlerrm(sqlcode);
     raise mass_error;
END create_mass_act_prev;

--
--
--

procedure get_new_org_dtls( p_mass_realignment_id in NUMBER,
                            p_position_id         in NUMBER,
                            p_effective_DATE      in DATE,
                            p_personnel_office_id in out NOCOPY VARCHAR2,
                            p_sub_element_code    in out NOCOPY VARCHAR2,
                            p_duty_station_id     in out NOCOPY NUMBER,
                            p_duty_station_code   in out NOCOPY VARCHAR2,
                            p_duty_station_desc   in out NOCOPY VARCHAR2,
                            p_duty_station_locn_id in out NOCOPY NUMBER,
                            p_office_symbol       in out NOCOPY VARCHAR2,
                            p_payroll_office_id   in out NOCOPY VARCHAR2,
                            p_org_func_code       in out NOCOPY VARCHAR2,
                            p_appropriation_code1 in out NOCOPY VARCHAR2,
                            p_appropriation_code2 in out NOCOPY VARCHAR2,
                            p_position_organization in out NOCOPY VARCHAR2) is

   cursor cur_realign_pos_info is
   SELECT personnel_office_id,
          agency_code_subelement,
          duty_station_code,
          duty_station_id target_duty_station_id,
          LOCATION_ID target_duty_stn_locn_id,
          office_symbol,
          payroll_office_id,
          org_function_code,
          appropriation_code1,
          appropriation_code2,
          position_organization_id
     from ghr_mass_real_pos_info_v
    WHERE mass_realignment_id = p_mass_realignment_id;

/*
   CURSOR POS_EXTRA_CUR (position NUMBER) IS
   SELECT position_extra_info_id,
          POEI_INFORMATION5,
          POEI_INFORMATION6,
          POEI_INFORMATION7,
          POEI_INFORMATION8,
          POEI_INFORMATION9,
          POEI_INFORMATION10,
          POEI_INFORMATION11,
          POEI_INFORMATION12,
          POEI_INFORMATION13
          POEI_INFORMATION18
     from per_position_extra_info
    WHERE position_id = (position)
      and INFORMATION_TYPE = 'GHR_US_POS_MASS_ACTIONS';
*/

   l_get_position_extra_info_id  NUMBER;

   o_poi               VARCHAR2(30) := null;
   o_agency_code       VARCHAR2(30) := null;
   o_duty_station_id   VARCHAR2(30) := null;
   o_duty_stn_locn_id   VARCHAR2(30) := null;
   o_duty_station_code VARCHAR2(30) := null;
   o_office_symbol     VARCHAR2(30) := null;
   o_payroll_office_id VARCHAR2(30) := null;
   o_org_func_code     VARCHAR2(30) := null;
   o_appropriation_code1 VARCHAR2(30) := null;
   o_appropriation_code2 VARCHAR2(30) := null;
   o_position_org        VARCHAR2(240) := null;

   l_poi               VARCHAR2(30) := null;
   l_agency_code       VARCHAR2(30) := null;
   l_duty_station_id   VARCHAR2(30) := null;
   l_duty_stn_locn_id   VARCHAR2(30) := null;
   l_duty_station_code VARCHAR2(30) := null;
   l_duty_station_desc VARCHAR2(150) := null; --Changed the size for Bug# 4648802
   l_office_symbol     VARCHAR2(30) := null;
   l_payroll_office_id VARCHAR2(30) := null;
   l_org_func_code     VARCHAR2(30) := null;
   l_appropriation_code1 VARCHAR2(30) := null;
   l_appropriation_code2 VARCHAR2(30) := null;
   l_position_org        VARCHAR2(240) := null;

   ll_poi               VARCHAR2(30);
   ll_agency_code       VARCHAR2(30);
   ll_duty_station_id   VARCHAR2(30);
   ll_duty_stn_locn_id   VARCHAR2(30);
   ll_duty_station_code VARCHAR2(30);
   ll_duty_station_desc VARCHAR2(150); --Changed the size for Bug# 4648802
   ll_office_symbol     VARCHAR2(30);
   ll_payroll_office_id VARCHAR2(30);
   ll_org_func_code     VARCHAR2(30);
   ll_appropriation_code1 VARCHAR2(30);
   ll_appropriation_code2 VARCHAR2(30);
   ll_position_org        VARCHAR2(240);

   l_pos_ei_data        per_position_extra_info%rowtype;
   l_eff_DATE           DATE;

BEGIN
  g_proc := 'get_new_org_dtls';

  -- Initialization for NOCOPY Changes
  --
  ll_poi                  := p_personnel_office_id;
  ll_agency_code          := p_sub_element_code;
  ll_duty_station_id      := p_duty_station_id;
  ll_duty_stn_locn_id     := p_duty_station_locn_id;
  ll_duty_station_code    := p_duty_station_code;
  ll_duty_station_desc    := p_duty_station_desc;
  ll_office_symbol        := p_office_symbol;
  ll_payroll_office_id    := p_payroll_office_id;
  ll_org_func_code        := p_org_func_code;
  ll_appropriation_code1  := p_appropriation_code1;
  ll_appropriation_code2  := p_appropriation_code2;
  ll_position_org         := p_position_organization;
  --

  if p_effective_DATE > sysDATE then
      l_eff_DATE := sysDATE;
  ELSE
      l_eff_DATE := p_effective_DATE;
  END IF;

  for r_pos_rec in cur_realign_pos_info
  loop
     o_poi                 := r_pos_rec.personnel_office_id;
     o_agency_code         := r_pos_rec.agency_code_subelement;
     o_duty_station_code   := r_pos_rec.duty_station_code;
     o_duty_station_id     := r_pos_rec.target_duty_station_id;
     o_duty_stn_locn_id    := r_pos_rec.target_duty_stn_locn_id;
/*
     get_duty_station_id (o_duty_station_code
                         ,l_eff_DATE
                         ,o_duty_station_id);
*/
     o_office_symbol       := r_pos_rec.office_symbol;
     o_payroll_office_id   := r_pos_rec.payroll_office_id;
     o_org_func_code       := r_pos_rec.org_function_code;
     o_appropriation_code1 := r_pos_rec.appropriation_code1;
     o_appropriation_code2 := r_pos_rec.appropriation_code2;
     o_position_org        := r_pos_rec.position_organization_id;

     exit;
   END loop;

   ghr_history_fetch.fetch_positionei
                  (p_position_id             => p_position_id
                  ,p_information_type      => 'GHR_US_POS_MASS_ACTIONS'
                  ,p_DATE_effective        => l_eff_DATE
                  ,p_pos_ei_data           => l_pos_ei_data);

     l_poi                 := l_pos_ei_data.poei_information5;
     l_agency_code         := l_pos_ei_data.poei_information6;
     l_duty_station_id     := l_pos_ei_data.poei_information7;
     l_office_symbol       := l_pos_ei_data.poei_information8;
     l_payroll_office_id   := l_pos_ei_data.poei_information9;
     l_org_func_code       := l_pos_ei_data.poei_information10;
     l_appropriation_code1 := l_pos_ei_data.poei_information11;
     l_appropriation_code2 := l_pos_ei_data.poei_information12;
     l_position_org        := l_pos_ei_data.poei_information13;
     l_duty_stn_locn_id    := l_pos_ei_data.poei_information18;

/*
   for pos_extra_rec in pos_extra_cur(p_position_id)
   loop
     l_poi                 := pos_extra_rec.poei_information5;
     l_agency_code         := pos_extra_rec.poei_information6;
     l_duty_station_id     := to_NUMBER(pos_extra_rec.poei_information7);
     l_office_symbol       := pos_extra_rec.poei_information8;
     l_payroll_office_id   := pos_extra_rec.poei_information9;
     l_org_func_code       := pos_extra_rec.poei_information10;
     l_appropriation_code1 := pos_extra_rec.poei_information11;
     l_appropriation_code2 := pos_extra_rec.poei_information12;
     l_position_org        := pos_extra_rec.poei_information13;

      exit;
   END loop;
*/

     if l_poi is not null then
          ll_poi := l_poi;
     ELSIF o_poi is not null then
          ll_poi := o_poi;
     END IF;

     if l_agency_code is not null then
          ll_agency_code := l_agency_code;
     ELSIF o_agency_code is not null then
          ll_agency_code := o_agency_code;
     END IF;
     if l_duty_station_id is not null then
          ll_duty_station_id := to_NUMBER(l_duty_station_id);
          ll_duty_stn_locn_id := to_NUMBER(l_duty_stn_locn_id);
     ELSIF o_duty_station_id is not null then
          ll_duty_station_id := to_NUMBER(o_duty_station_id);
          ll_duty_stn_locn_id := to_NUMBER(o_duty_stn_locn_id);
     END IF;

     if l_duty_station_id is not null or o_duty_station_id is not null then
----- Duty station is changed
         ghr_pa_requests_pkg.get_duty_station_details
              (p_duty_station_id          => ll_duty_station_id
              ,p_effective_DATE           => p_effective_DATE
              ,p_duty_station_code        => ll_duty_station_code
              ,p_duty_station_desc        => ll_duty_station_desc);

     END IF;

     if l_office_symbol is not null then
          ll_office_symbol := l_office_symbol;
     ELSIF o_office_symbol is not null then
          ll_office_symbol := o_office_symbol;
     END IF;

     if l_payroll_office_id is not null then
          ll_payroll_office_id := l_payroll_office_id;
     ELSIF o_payroll_office_id is not null then
          ll_payroll_office_id := o_payroll_office_id;
     END IF;

     if l_org_func_code is not null then
          ll_org_func_code := l_org_func_code;
     ELSIF o_org_func_code is not null then
          ll_org_func_code := o_org_func_code;
     END IF;

     if l_appropriation_code1 is not null then
          ll_appropriation_code1 := l_appropriation_code1;
     ELSIF o_appropriation_code1 is not null then
          ll_appropriation_code1 := o_appropriation_code1;
     END IF;

     if l_appropriation_code2 is not null then
          ll_appropriation_code2 := l_appropriation_code2;
pr('pos appr is ',l_appropriation_code2);
     ELSIF o_appropriation_code2 is not null then
          ll_appropriation_code2 := o_appropriation_code2;
pr('param  appr is ',o_appropriation_code2);
     ELSE
pr('both are null param  appr is ',o_appropriation_code2,l_appropriation_code2);
     END IF;

---dbms_output.put_line('Just before pos org');

     if l_position_org is not null then
          ll_position_org := l_position_org;
     ELSIF o_position_org is not null then
          ll_position_org := o_position_org;
     END IF;
---dbms_output.put_line('Just after pos org and I am leaving');

      p_personnel_office_id  := ll_poi;
      p_sub_element_code     := ll_agency_code;
      p_duty_station_id      := ll_duty_station_id;
      p_duty_station_code    := ll_duty_station_code;
      p_duty_station_desc    := ll_duty_station_desc;
      p_duty_station_locn_id := ll_duty_stn_locn_id;
      p_office_symbol        := ll_office_symbol;
      p_payroll_office_id    := ll_payroll_office_id;
      p_org_func_code        := ll_org_func_code;
      p_appropriation_code1  := ll_appropriation_code1;
      p_appropriation_code2  := ll_appropriation_code2;
      p_position_organization := ll_position_org;

EXCEPTION
when others then
-- Reset for IN OUT params and set OUT params
-- NOCOPY changes
--
      p_personnel_office_id  := ll_poi;
      p_sub_element_code     := ll_agency_code;
      p_duty_station_id      := ll_duty_station_id;
      p_duty_station_code    := ll_duty_station_code;
      p_duty_station_desc    := ll_duty_station_desc;
      p_duty_station_locn_id := ll_duty_stn_locn_id;
      p_office_symbol        := ll_office_symbol;
      p_payroll_office_id    := ll_payroll_office_id;
      p_org_func_code        := ll_org_func_code;
      p_appropriation_code1  := ll_appropriation_code1;
      p_appropriation_code2  := ll_appropriation_code2;
      p_position_organization := ll_position_org;
--

END get_new_org_dtls;

--
--
--

PROCEDURE assign_to_sf52_rec(
 p_person_id              in NUMBER,
 p_first_name             in VARCHAR2,
 p_last_name              in VARCHAR2,
 p_middle_names           in VARCHAR2,
 p_national_identifier    in VARCHAR2,
 p_DATE_of_birth          in DATE,
 p_effective_DATE         in DATE,
 p_assignment_id          in NUMBER,
 p_tenure                 in VARCHAR2,
 p_step_or_rate           in VARCHAR2,
 p_annuitant_indicator    in VARCHAR2,
 p_pay_rate_determinant   in VARCHAR2,
 p_work_schedule          in VARCHAR2,
 p_part_time_hour         in VARCHAR2,
 p_flsa_category          in VARCHAR2,
 p_bargaining_unit_status in VARCHAR2,
 p_functional_class       in VARCHAR2,
 p_supervisory_status     in VARCHAR2,
 p_personnel_office_id    in VARCHAR2,
 p_sub_element_code       in VARCHAR2,
 p_duty_station_id        in NUMBER,
 p_duty_station_locn_id        in NUMBER,
 p_duty_station_code      in ghr_pa_requests.duty_station_code%type,
 p_duty_station_desc      in ghr_pa_requests.duty_station_desc%type,
 p_office_symbol          in VARCHAR2,
 p_payroll_office_id      in VARCHAR2,
 p_org_func_code          in VARCHAR2,
 p_appropriation_code1    in VARCHAR2,
 p_appropriation_code2    in VARCHAR2,
 p_position_organization  in VARCHAR2,
 p_lac_sf52_rec           in ghr_pa_requests%rowtype,
 p_sf52_rec               out NOCOPY ghr_pa_requests%rowtype) IS

l_proc                      VARCHAR2(72)
          :=  g_package || '.assign_to_sf52_rec';
BEGIN

  g_proc := 'assign_to_sf52_rec';

  hr_utility.set_location('Entering    ' || l_proc,5);
 p_sf52_rec.person_id := p_person_id;
 p_sf52_rec.employee_first_name := p_first_name;
 p_sf52_rec.employee_last_name := p_last_name;
 p_sf52_rec.employee_middle_names := p_middle_names;
 p_sf52_rec.employee_national_identifier := p_national_identifier;
 p_sf52_rec.employee_DATE_of_birth := p_DATE_of_birth;
 p_sf52_rec.effective_DATE := p_effective_DATE;
 p_sf52_rec.employee_assignment_id := p_assignment_id;
 p_sf52_rec.tenure := p_tenure;
 p_sf52_rec.to_step_or_rate := p_step_or_rate;
 p_sf52_rec.annuitant_indicator  := p_annuitant_indicator;
 p_sf52_rec.pay_rate_determinant  := p_pay_rate_determinant;
 p_sf52_rec.work_schedule := p_work_schedule;
 p_sf52_rec.part_time_hours := p_part_time_hour;
 p_sf52_rec.flsa_category := p_flsa_category;
 p_sf52_rec.bargaining_unit_status := p_bargaining_unit_status;
 p_sf52_rec.functional_class := p_functional_class;
 p_sf52_rec.supervisory_status := p_supervisory_status;
 p_sf52_rec.personnel_office_id := p_personnel_office_id;
 p_sf52_rec.agency_code := p_sub_element_code;
 p_sf52_rec.duty_station_id := p_duty_station_id;
 p_sf52_rec.duty_station_location_id := p_duty_station_locn_id;
 p_sf52_rec.duty_station_code := p_duty_station_code;
 p_sf52_rec.duty_station_desc := p_duty_station_desc;
 p_sf52_rec.to_office_symbol := p_office_symbol;
 p_sf52_rec.appropriation_code1 := p_appropriation_code1;
 p_sf52_rec.appropriation_code2 := p_appropriation_code2;

 p_sf52_rec.FIRST_LAC1_INFORMATION1 := p_lac_sf52_rec.FIRST_LAC1_INFORMATION1;
 p_sf52_rec.FIRST_LAC1_INFORMATION2 := p_lac_sf52_rec.FIRST_LAC1_INFORMATION2;
 p_sf52_rec.FIRST_LAC1_INFORMATION3 := p_lac_sf52_rec.FIRST_LAC1_INFORMATION3;
 p_sf52_rec.FIRST_LAC1_INFORMATION4 := p_lac_sf52_rec.FIRST_LAC1_INFORMATION4;
 p_sf52_rec.FIRST_LAC1_INFORMATION5 := p_lac_sf52_rec.FIRST_LAC1_INFORMATION5;
 p_sf52_rec.SECOND_LAC1_INFORMATION1 := p_lac_sf52_rec.SECOND_LAC1_INFORMATION1;
 p_sf52_rec.SECOND_LAC1_INFORMATION2 := p_lac_sf52_rec.SECOND_LAC1_INFORMATION2;
 p_sf52_rec.SECOND_LAC1_INFORMATION3 := p_lac_sf52_rec.SECOND_LAC1_INFORMATION3;
 p_sf52_rec.SECOND_LAC1_INFORMATION4 := p_lac_sf52_rec.SECOND_LAC1_INFORMATION4;
 p_sf52_rec.SECOND_LAC1_INFORMATION5 := p_lac_sf52_rec.SECOND_LAC1_INFORMATION5;
 p_sf52_rec.FIRST_ACTION_LA_CODE1 := p_lac_sf52_rec.FIRST_ACTION_LA_CODE1;
 p_sf52_rec.FIRST_ACTION_LA_CODE2 := p_lac_sf52_rec.FIRST_ACTION_LA_CODE2;
 p_sf52_rec.FIRST_ACTION_LA_DESC1 := p_lac_sf52_rec.FIRST_ACTION_LA_DESC1;
 p_sf52_rec.FIRST_ACTION_LA_DESC2 := p_lac_sf52_rec.FIRST_ACTION_LA_DESC2;

     hr_utility.set_location('Exiting    ' || l_proc,10);

EXCEPTION
  when mass_error then raise;
  when others then
     -- NOCOPY Changes
     -- Reset IN OUT Params and set OUT params
     --
     p_sf52_rec := null;
     --
     pr('Error in '||l_proc);
     hr_utility.set_location('Error in '||l_proc||' Err is '||sqlerrm(sqlcode),20);
     l_mslerrbuf := 'Error in '||l_proc||'  Sql Err is '|| sqlerrm(sqlcode);
     raise mass_error;
END assign_to_sf52_rec;

procedure upd_ext_info_to_null(p_position_id in NUMBER, p_effective_DATE in DATE) is

   CURSOR POSITION_EXT_CUR (p_position NUMBER) IS
   SELECT position_extra_info_id, object_version_NUMBER
     from per_position_extra_info
    WHERE position_id = (p_position)
      and INFORMATION_TYPE = 'GHR_US_POS_MASS_ACTIONS';

   l_Position_EXTRA_INFO_ID         NUMBER;
   l_OBJECT_VERSION_NUMBER        NUMBER;
   l_eff_DATE                     DATE;

   l_pos_ei_data         per_position_extra_info%rowtype;
   l_proc    VARCHAR2(72) :=  g_package || '.upd_ext_info_api';
BEGIN

  g_proc := 'upd_ext_info_to_null';

  if p_effective_DATE > sysDATE then
       l_eff_DATE := sysDATE;
  ELSE
       l_eff_DATE := p_effective_DATE;
  END IF;

-- Bug#2944091 Instead of trunc(sysDATE) , l_eff_DATE is passed.
   ghr_history_fetch.fetch_positionei
                  (p_position_id           => p_position_id
                  ,p_information_type      => 'GHR_US_POS_MASS_ACTIONS'
                  ,p_DATE_effective        => l_eff_DATE
		  ,p_pos_ei_data           => l_pos_ei_data);

   l_position_extra_info_id  := l_pos_ei_data.position_extra_info_id;
   l_object_version_NUMBER := l_pos_ei_data.object_version_NUMBER;

   if l_position_extra_info_id is not null then

----- Set the global variable not to fire the trigger
        ghr_api.g_api_dml       := TRUE;

       BEGIN

    -- Bug#2944091 Instead of trunc(sysDATE) , l_eff_DATE is passed.
          ghr_position_extra_info_api.UPDATE_position_extra_info
                      (P_POSITION_EXTRA_INFO_ID   => l_position_extra_info_id
                      ,P_OBJECT_VERSION_NUMBER  => l_object_version_NUMBER
                      ,P_POEI_INFORMATION_CATEGORY  => 'GHR_US_POS_MASS_ACTIONS'
                      ,P_EFFECTIVE_DATE             => l_eff_DATE
                      ,P_POEI_INFORMATION3        => null
                      ,P_POEI_INFORMATION4        => null
                      ,P_POEI_INFORMATION5        => null
                      ,P_POEI_INFORMATION6        => null
                      ,P_POEI_INFORMATION7        => null
                      ,P_POEI_INFORMATION8        => null
                      ,P_POEI_INFORMATION9        => null
                      ,P_POEI_INFORMATION10        => null
                      ,P_POEI_INFORMATION11        => null
                      ,P_POEI_INFORMATION12        => null
                      ,P_POEI_INFORMATION13        => null
                      ,P_POEI_INFORMATION14        => null
                      ,P_POEI_INFORMATION18        => null);
      EXCEPTION when others then
                hr_utility.set_location('UPDATE posei error 3' || l_proc,10);
                hr_utility.set_location('Error in '||l_proc||' Err is '||sqlerrm(sqlcode),20);
      END;

----- Reset the global variable
        ghr_api.g_api_dml       := FALSE;


--- Commented the following two lines to remove Validation functionality on Position.
----    ghr_valiDATE_perwsdpo.valiDATE_perwsdpo(p_position_id);
----    ghr_valiDATE_perwsdpo.UPDATE_posn_status(p_position_id);
   END IF;
END;

PROCEDURE upd_ext_info_api (p_position_id in NUMBER,
                            info5 in VARCHAR2,
                            info6 in VARCHAR2,
                            info7 in VARCHAR2,
                            info8 in VARCHAR2,
                            info9 in VARCHAR2,
                            info10 in VARCHAR2,
                            info11 in VARCHAR2,
                            info12 in VARCHAR2,
                            info13 in VARCHAR2,
                            info18 in VARCHAR2,
                            p_effective_DATE in DATE) IS
   CURSOR POSITION_EXT_CUR (p_position NUMBER) IS
   SELECT position_extra_info_id, object_version_NUMBER
     from per_position_extra_info
    WHERE position_id = (p_position)
      and INFORMATION_TYPE = 'GHR_US_POS_MASS_ACTIONS';

l_cnt NUMBER;
l_Position_EXTRA_INFO_ID         NUMBER;
l_OBJECT_VERSION_NUMBER        NUMBER;

   l_pos_ei_data         per_position_extra_info%rowtype;
   l_proc    VARCHAR2(72) :=  g_package || '.upd_ext_info_api';
   l_eff_DATE DATE;

BEGIN
  g_proc := 'upd_ext_info_api';
  hr_utility.set_location('Entering    ' || l_proc,5);
  if p_effective_DATE > sysDATE then
       l_eff_DATE := sysDATE;
  ELSE
       l_eff_DATE := p_effective_DATE;
  END IF;

   ghr_history_fetch.fetch_positionei
                  (p_position_id           => p_position_id
                  ,p_information_type      => 'GHR_US_POS_MASS_ACTIONS'
                  ,p_DATE_effective        => l_eff_DATE
                  ,p_pos_ei_data           => l_pos_ei_data);

   l_position_extra_info_id  := l_pos_ei_data.position_extra_info_id;
   l_object_version_NUMBER := l_pos_ei_data.object_version_NUMBER;

   if l_position_extra_info_id is null then
      for pos_ext_rec in position_ext_cur(p_position_id)
      loop
         l_position_extra_info_id  := pos_ext_rec.position_extra_info_id;
         l_object_version_NUMBER := pos_ext_rec.object_version_NUMBER;
      END loop;
   END IF;


  if l_position_extra_info_id is null then
        ghr_position_extra_info_api.create_position_extra_info
                       (p_position_id              => p_position_id
                       ,p_information_type       => 'GHR_US_POS_MASS_ACTIONS'
                       ,P_EFFECTIVE_DATE          => trunc(l_eff_DATE)
                       ,P_POEI_information_category => 'GHR_US_POS_MASS_ACTIONS'
                       ,P_POEI_INFORMATION5        => info5
                       ,P_POEI_INFORMATION6        => info6
                       ,P_POEI_INFORMATION7        => info7
                       ,P_POEI_INFORMATION8        => info8
                       ,P_POEI_INFORMATION9        => info9
                       ,P_POEI_INFORMATION10        => info10
                       ,P_POEI_INFORMATION11        => info11
                       ,P_POEI_INFORMATION12        => info12
                       ,P_POEI_INFORMATION13        => info13
                       ,P_POEI_INFORMATION18        => info18
                       ,p_POSITION_EXTRA_INFO_ID   => l_POSITION_EXTRA_INFO_ID
                       ,P_OBJECT_VERSION_NUMBER  => L_OBJECT_VERSION_NUMBER);
     ELSE

----- Set the global variable not to fire the trigger
        ghr_api.g_api_dml       := TRUE;

       BEGIN
          ghr_position_extra_info_api.UPDATE_position_extra_info
                       (P_POSITION_EXTRA_INFO_ID   => l_position_extra_info_id
                       ,P_OBJECT_VERSION_NUMBER  => l_object_version_NUMBER
                       ,P_POEI_INFORMATION_CATEGORY  => 'GHR_US_POS_MASS_ACTIONS'
                       ,P_EFFECTIVE_DATE          => trunc(l_eff_DATE)
                       ,P_POEI_INFORMATION5        => info5
                       ,P_POEI_INFORMATION6        => info6
                       ,P_POEI_INFORMATION7        => info7
                       ,P_POEI_INFORMATION8        => info8
                       ,P_POEI_INFORMATION9        => info9
                       ,P_POEI_INFORMATION10        => info10
                       ,P_POEI_INFORMATION11        => info11
                       ,P_POEI_INFORMATION12        => info12
                       ,P_POEI_INFORMATION13        => info13
                       ,P_POEI_INFORMATION18        => info18);
      EXCEPTION when others then
                hr_utility.set_location('UPDATE posei error 4' || l_proc,10);
                hr_utility.set_location('Error in '||l_proc||' Err is '||sqlerrm(sqlcode),20);
      END;

----- Reset the global variable
        ghr_api.g_api_dml       := FALSE;

     END IF;

--- Commented the following two lines to remove Validation functionality on Position.
---  ghr_valiDATE_perwsdpo.valiDATE_perwsdpo(p_position_id);
---  ghr_valiDATE_perwsdpo.UPDATE_posn_status(p_position_id);
END;

--
--
--

procedure pr (msg VARCHAR2,par1 in VARCHAR2 default null,
            par2 in VARCHAR2 default null) is
BEGIN
  g_no := g_no +1;
--  insert into l_tmp values (g_no,substr(msg||'-'||par1||' -'||par2||'-',1,199));
  ---DBMS_OUTPUT.PUT_LINE(msg||'-'||par1||' -'||par2||'-');
EXCEPTION
  when others then
     pr('Error in '||'pr');
     hr_utility.set_location('Error in pr '||' Err is '||sqlerrm(sqlcode),20);
     l_mslerrbuf := 'Error in pr  Sql Err is '|| sqlerrm(sqlcode);
     raise mass_error;
END;

Procedure UPDATE_position_info
     (p_position_data_rec ghr_sf52_pos_UPDATE.position_data_rec_type) is
    l_proc    VARCHAR2(30):='UPDATE_position_info';
Begin
    hr_utility.set_location('Entering ' || l_proc, 10);
    hr_utility.set_location('Vacant Position ID  ' || to_char(p_position_data_rec.position_id), 10);
   ghr_session.set_session_var_for_core( p_position_data_rec.effective_END_DATE );
   ghr_sf52_pos_UPDATE.UPDATE_position_info
        ( p_pos_data_rec => p_position_data_rec);
    hr_utility.set_location('Calling Pust_UPDATE_process ' || l_proc, 50);
    ghr_history_api.post_UPDATE_process;
    hr_utility.set_location('Leaving ' || l_proc, 100);

END;


END GHR_MRE_PKG;

/
