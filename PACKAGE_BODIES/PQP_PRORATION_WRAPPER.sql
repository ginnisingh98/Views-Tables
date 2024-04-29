--------------------------------------------------------
--  DDL for Package Body PQP_PRORATION_WRAPPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_PRORATION_WRAPPER" AS
/* $Header: pqprowiz.pkb 115.15 2002/03/17 10:51:15 pkm ship        $ */

CURSOR c_biz_group(p_business_group_name IN VARCHAR2) IS
   SELECT business_group_id
   FROM   per_business_groups
   WHERE UPPER(name) = UPPER(p_business_group_name);

CURSOR c_dated_pay_table(p_table_name IN VARCHAR2) IS
   SELECT dated_table_id
   FROM  pay_dated_tables
   WHERE UPPER(table_name) = UPPER(p_table_name);

CURSOR c_primary_classification(p_primary_class IN VARCHAR2) IS
    SELECT default_priority
    FROM   pay_element_classifications
    WHERE  NVL(legislation_code, 'GB') = 'GB'
    AND    UPPER(classification_name)  = UPPER(p_primary_class);

CURSOR c_element_id(p_ele_name IN VARCHAR2) IS
    SELECT element_type_id
    FROM   pay_element_types_f
    WHERE  UPPER(element_name) = UPPER(LTRIM(RTRIM(p_ele_name)));

CURSOR c_input_value(p_element_type_id  IN NUMBER   ,
                     p_input_value_name IN VARCHAR2 ) IS
    SELECT input_value_id
    FROM   pay_input_values_f
    WHERE  element_type_id = p_element_type_id
    AND    name            = LTRIM(RTRIM(p_input_value_name));

CURSOR c_formula_id(p_formula_name IN VARCHAR2) IS
    SELECT formula_id
    FROM   ff_formulas_f
    WHERE  formula_name  = UPPER(p_formula_name);

CURSOR c_element_extra_info_cnt(p_ele_id IN NUMBER) IS
    SELECT COUNT(*) count
    FROM   pay_element_type_extra_info
    WHERE  element_type_id          = p_ele_id
    AND    information_type         = 'PQP_UK_ELEMENT_ATTRIBUTION'
    AND    eei_information_category = 'PQP_UK_ELEMENT_ATTRIBUTION';

CURSOR c_element_extra_info_id(p_ele_id IN NUMBER) IS
    SELECT element_type_extra_info_id,
           object_version_number
    FROM   pay_element_type_extra_info
    WHERE  element_type_id          = p_ele_id
    AND    information_type         = 'PQP_UK_ELEMENT_ATTRIBUTION'
    AND    eei_information_category = 'PQP_UK_ELEMENT_ATTRIBUTION';

CURSOR c_event_group_id(p_pg_name IN VARCHAR) IS
        SELECT event_group_id
        FROM   pay_event_groups
        WHERE  UPPER(event_group_name) = UPPER(p_pg_name);

CURSOR c_formula_text(p_formula_name IN VARCHAR) IS
        SELECT formula_text
        FROM   ff_formulas_f ff
        WHERE  ff.formula_name       = p_formula_name
        AND    ff.legislation_code   = 'GB'
        AND    ff.business_group_id IS NULL;

CURSOR c_fast_formula_id(p_formula_name      IN VARCHAR,
                         p_business_group_id IN NUMBER) IS
        SELECT formula_id
        FROM   ff_formulas_f ff
        WHERE  RTRIM(LTRIM(UPPER(ff.formula_name)))
                                     = RTRIM(LTRIM(UPPER(p_formula_name)))
        AND    ff.legislation_code   IS NULL
        AND    ff.business_group_id  = p_business_group_id;

gv_package    varchar2(100) := 'pqp_proration_wrapper';
--*************************************************************************
--  Procedure : Valid business group
--*************************************************************************

PROCEDURE valid_business_group(p_business_group_name IN per_business_groups.name%TYPE)
AS
l_exists varchar2(2) := 'N';
lv_procedure_name VArchar2(80) := '.valid_business_group';
BEGIN
    hr_utility.set_location('Entering {' || gv_package || lv_procedure_name, 10);
begin
   SELECT 'Y'
   INTO l_exists
   FROM dual
   WHERE EXISTS
     (SELECT null
      FROM PER_BUSINESS_GROUPS
      WHERE name = p_business_group_name
);
   EXCEPTION
   WHEN NO_DATA_FOUND THEN
     hr_utility.set_message(800, 'HR_7208_API_BUS_GRP_INVALID');
     hr_utility.raise_error;
  END;
  hr_utility.set_location('Exiting }' || gv_package ||
                                          lv_procedure_name, 50);
--
--
END;
--*************************************************************************
--  Procedure : Enable_Dynamic_Triggers
--*************************************************************************

PROCEDURE enable_dynamic_triggers
(
    p_business_group_id IN NUMBER   ,
    p_salary_flag       IN VARCHAR2 ,
    p_grade_flag        IN VARCHAR2 ,
    p_spinal_flag       IN VARCHAR2 ,
    p_address_flag      IN VARCHAR2 ,
    p_location_flag     IN VARCHAR2
)
AS
    l_area_id            NUMBER                 ;
    l_business_group_id  NUMBER                 ;
    l_count              NUMBER                 ;
    l_row_id             ROWID                  ;
    l_usage_id           NUMBER                 ;
    l_select_statement   VARCHAR2(1000)         ;
    l_select_flag        VARCHAR2(6)            ;
    l_salary_flag        VARCHAR2(6) := 'FALSE' ;
    l_grade_flag         VARCHAR2(6) := 'FALSE' ;
    l_spinal_flag        VARCHAR2(6) := 'FALSE' ;
    l_address_flag       VARCHAR2(6) := 'FALSE' ;
    l_location_flag      VARCHAR2(6) := 'FALSE' ;
    l_short_name         VARCHAR2(80)           ;
    lv_procedure_name    VARCHAR2(50) := '.enable_dynamic_triggers';
    l_event_id           NUMBER                 ;
    l_dummy              NUMBER                 ;

    l_cursor_num         NUMBER                 ;

    TYPE c_dt_cursor IS REF CURSOR              ;

    c_dtc c_dt_cursor;

    CURSOR c_functional_areas IS
        SELECT area_id
        FROM   pay_functional_areas
        WHERE  short_name = 'INCIDENT REGISTER';

    CURSOR c_functional_usages(p_area_id           IN NUMBER ,
                               p_business_group_Id IN NUMBER ) IS
        SELECT COUNT(*) count
        FROM   pay_functional_usages
        WHERE  area_id           = p_area_id
        AND    business_group_id = p_business_group_id;
BEGIN
    hr_utility.set_location('Entering {' || gv_package ||
                                          lv_procedure_name, 10);

    l_business_group_id := p_business_group_id;
    l_salary_flag       := p_salary_flag  ;
    l_grade_flag        := p_grade_flag   ;
    l_spinal_flag       := p_spinal_flag  ;
    l_address_flag      := p_address_flag ;
    l_location_flag     := p_location_flag ;

    l_select_statement := 'SELECT pte.short_name,
                                  pte.event_id
                           FROM   pay_functional_areas    pfa,
                                  pay_functional_triggers pft,
                                  pay_trigger_events      pte
                           WHERE  pte.event_id   = pft.event_id
                           AND    pft.area_id    = pfa.area_id
                           AND    pfa.short_name = ''INCIDENT REGISTER''
                           AND    pte.short_name IN (';

    l_select_flag  := 'FALSE';

    IF (l_salary_flag = 'TRUE') THEN

        l_select_flag  := 'TRUE';

        l_select_statement := l_select_statement ||
                                      '''PAY_ELEMENT_ENTRIES_F_ARD'',
                                       ''PAY_ELEMENT_ENTRIES_F_ARI'',
                                       ''PAY_ELEMENT_ENTRIES_F_ARU'',
                                       ''PAY_ELEMENT_ENTRY_VALUES_F_ARU''';
    END IF;

    IF (l_grade_flag = 'TRUE') THEN


        IF (l_select_flag = 'TRUE') THEN
            l_select_statement := l_select_statement ||
                   ', ''PAY_GRADE_RULES_F_ARU'',
                      ''PER_ALL_ASSIGNMENTS_F_ARU''';
        ELSE
            l_select_statement := l_select_statement ||
                   '''PAY_GRADE_RULES_F_ARU'',
                    ''PER_ALL_ASSIGNMENTS_F_ARU''';
        END IF;
        l_select_flag  := 'TRUE';
    END IF;

    IF (l_spinal_flag = 'TRUE') THEN


        IF (l_select_flag = 'TRUE') THEN
            l_select_statement := l_select_statement ||
                ',''PER_SPINAL_POINT_PLACEMENTS_F_ARU'',
                  ''PER_ALL_ASSIGNMENTS_F_ARU''';
        ELSE
            l_select_statement := l_select_statement ||
                 '''PER_SPINAL_POINT_PLACEMENTS_F_ARU'',
                  ''PER_ALL_ASSIGNMENTS_F_ARU''';
        END IF;
        l_select_flag  := 'TRUE';
    END IF;

    IF (l_address_flag = 'TRUE') THEN

        IF (l_select_flag = 'TRUE') THEN
            l_select_statement := l_select_statement ||
                ',''PER_ADDRESSES_ARU''';
        ELSE
            l_select_statement := l_select_statement ||
                 '''PER_ADDRESSES_ARU''';
        END IF;
        l_select_flag  := 'TRUE';
    END IF;

    IF (l_location_flag = 'TRUE') THEN

        IF (l_select_flag = 'TRUE') THEN
            l_select_statement := l_select_statement ||
                ',''PER_ALL_ASSIGNMENTS_F_ARU''';
        ELSE
            l_select_statement := l_select_statement ||
                 '''PER_ALL_ASSIGNMENTS_F_ARU''';
        END IF;
        l_select_flag  := 'TRUE';
    END IF;

    IF (l_select_flag = 'FALSE') THEN
        l_select_statement := l_select_statement || 'NULL)';
    ELSE
        l_select_statement := l_select_statement || ')';

        l_cursor_num := DBMS_SQL.OPEN_CURSOR;

        DBMS_SQL.PARSE(l_cursor_num, l_select_statement, DBMS_SQL.V7);
        DBMS_SQL.DEFINE_COLUMN(l_cursor_num, 1, l_short_name, 80);
        DBMS_SQL.DEFINE_COLUMN(l_cursor_num, 2, l_event_id);

        l_dummy := DBMS_SQL.EXECUTE(l_cursor_num);

    END IF;

    LOOP
        IF DBMS_SQL.FETCH_ROWS(l_cursor_num) = 0 THEN
            EXIT;
        END IF;

        DBMS_SQL.COLUMN_VALUE(l_cursor_num, 1, l_short_name );
        DBMS_SQL.COLUMN_VALUE(l_cursor_num, 2, l_event_id   );

        UPDATE pay_trigger_components
        SET    enabled_flag = 'Y'
        WHERE  event_id     = l_event_id;

        UPDATE pay_trigger_events
        SET    generated_flag = 'Y',
               enabled_flag   = 'Y'
        WHERE  event_id       = l_event_id;

        pay_dyn_triggers.generate_trigger_event(l_short_name);
        hr_utility.trace('Generate Trigger Event');

    END LOOP;

    FOR c1 IN c_functional_areas
    LOOP
        l_area_id := c1.area_id;
    END LOOP;

    FOR c2 IN c_functional_usages (l_area_id,
                                   l_business_Group_id) LOOP
        l_count := c2.count;
    END LOOP;

--************************************************************************
-- The following code inserts a row in pay_functional_usages table for the
-- respective Business Group.
--************************************************************************
    IF (l_count = 0) THEN
        hr_utility.trace('The count is ' || TO_CHAR(l_count));
        pay_functional_usages_pkg.insert_row(
              p_row_id             =>   l_row_id            ,
              p_usage_id           =>   l_usage_id          ,
              p_area_id            =>   l_area_id           ,
              p_legislation_code   =>   NULL                ,
              p_business_group_id  =>   l_business_group_id ,
              p_payroll_id         =>   NULL                );
    END IF;
    hr_utility.set_location('Leaving }' || gv_package || lv_procedure_name, 20);
END enable_dynamic_triggers;

--*************************************************************************
--  Procedure : Standard Procedure
--*************************************************************************

PROCEDURE standard_proc
(
    business_group     IN VARCHAR2 DEFAULT NULL ,
    pay_mode_grade     IN VARCHAR2 DEFAULT NULL ,
    pay_mode_scale     IN VARCHAR2 DEFAULT NULL ,
    pay_mode_salary    IN VARCHAR2 DEFAULT NULL ,
    teacher_england    IN VARCHAR2 DEFAULT NULL ,
    teacher_scotland   IN VARCHAR2 DEFAULT NULL ,
    startdate          IN VARCHAR2 DEFAULT NULL ,
    basename           IN VARCHAR2 DEFAULT NULL ,
    sal_rep_name       IN VARCHAR2 DEFAULT NULL ,
    grade_rep_name     IN VARCHAR2 DEFAULT NULL ,
    ps_rep_name        IN VARCHAR2 DEFAULT NULL ,
    p_ele_gr_name      IN VARCHAR2 DEFAULT NULL ,
    p_ele_psr_name     IN VARCHAR2 DEFAULT NULL
)
AS
    l_ele_id                NUMBER                             ;
    l_formula_id            NUMBER                             ;
    l_status_proc_rule_id   NUMBER                             ;
    l_event_group_id        NUMBER                             ;
    l_ovn                   NUMBER                             ;
    l_dt_event_id           NUMBER                             ;
    l_ipv_pv                NUMBER                             ;
    l_ipv_as                NUMBER                             ;
    l_for_res_id            NUMBER                             ;
    l_formula_type_id       NUMBER                             ;
    l_formula_text          LONG                               ;
    l_business_group_name   VARCHAR2(50)                       ;
    l_business              VARCHAR2(50)                       ;
    l_formula_name          VARCHAR2(50)                       ;
    l_description           VARCHAR2(50)                       ;
    l_date                  VARCHAR2(50)                       ;
    l_base                  VARCHAR2(50)                       ;
    l_upper_base            VARCHAR2(50)                       ;
    l_modified_base_pg      VARCHAR2(50)                       ;
    l_modified_base_ele     VARCHAR2(50)                       ;
    l_modified_base_formula VARCHAR2(50)                       ;
    l_salary_flag           VARCHAR2(6)        := 'FALSE'      ;
    l_grade_flag            VARCHAR2(6)        := 'FALSE'      ;
    l_pscale_flag           VARCHAR2(6)        := 'FALSE'      ;
    l_string                VARCHAR2(500)                      ;
    lv_procedure_name       VARCHAR2(50) := '.standard_proc'   ;
    l_england_flag          BOOLEAN := FALSE                   ;
    l_scotland_flag         BOOLEAN := FALSE                   ;
    l_count                 NUMBER                             ;
    l_business_group_id     NUMBER                             ;
    l_dated_table_id        NUMBER                             ;
    l_ele_id_scot           NUMBER                             ;
    l_ipv_pv_scot           NUMBER                             ;
    l_req_id                NUMBER                             ;
    l_etei_ovn              NUMBER                             ;
    l_etei_id               NUMBER                             ;
BEGIN
    hr_utility.set_location('Entering {'|| gv_package || lv_procedure_name, 10);
    l_business_group_name    := UPPER(business_group)          ;
    l_business               := business_group                 ;
    l_upper_base             := UPPER(basename)                ;
    l_base                   := basename                       ;
    l_modified_base_pg       := l_base                         ;
    l_modified_base_ele      := l_base                         ;
    l_modified_base_formula  := REPLACE(l_upper_base, ' ', '_');
    l_date                   := startdate                      ;

    valid_business_group(p_business_group_name => business_group);
    FOR c1 IN c_biz_group (l_business_group_name)
    LOOP
        l_business_group_id := c1.business_group_id;
    END LOOP;

    IF (pay_mode_grade = 'YES') THEN
        l_grade_flag            := 'TRUE';
    END IF;
    IF (pay_mode_salary = 'YES') THEN
        l_salary_flag           := 'TRUE';
    END IF;
    IF (pay_mode_scale = 'YES') THEN
        l_pscale_flag           := 'TRUE';
    END IF;

--*********** SALARY ********************

    IF (l_salary_flag = 'TRUE') THEN
        hr_utility.trace('Salary Flag is true');

-- We should basically
-- a) Create a Pro ration Group with the events enabled for SALARY.
-- b) Create an Element.
-- c) Link the formula to the element.
-- d) Enable the dynamic triggers and Functional Specifications.

-- a) Step a

-- PAY_DATETRACKED_EVENTS_API. CREATE_DATETRACKED_EVENT
-- PAY_EVENT_GROUPS_API.CREATE_EVENT_GROUP

        l_count := 0;

        SELECT COUNT(*)
        INTO   l_count
        FROM   pay_event_groups
        WHERE  event_group_name = UPPER(l_modified_base_pg || ' sal pg');

        hr_utility.trace('The count 15 is ' || TO_CHAR(l_count));

        IF (l_count = 0) THEN
            hr_utility.trace('If condition ... Creating Even Group');

            pay_event_groups_api.create_event_group
            (
              p_effective_date         => TO_DATE(l_date,'dd/mm/yyyy')
             ,p_event_group_name       => UPPER(l_modified_base_pg || ' sal pg')
             ,p_event_group_type       => 'P'
             ,p_proration_type         => 'P'
             ,p_business_group_id      => l_business_group_id
             ,p_legislation_code       => NULL
             ,p_event_group_id         => l_event_group_id
             ,p_object_version_number  => l_ovn
            );
        ELSE
            hr_utility.trace('Else condition ');
            l_event_group_id := NULL;

--            SELECT event_group_id
--            INTO   l_event_group_id
--            FROM   pay_event_groups
--            WHERE  event_group_name = UPPER(l_modified_base_pg || ' sal pg');

            FOR cegi IN c_event_group_id(l_modified_base_pg || ' sal pg')
            LOOP
                l_event_group_id := cegi.event_group_id;
            END LOOP;
        END IF;

        FOR c2 IN c_dated_pay_table ('PAY_ELEMENT_ENTRIES_F')
        LOOP
            l_dated_table_id := c2.dated_table_id;
        END LOOP;

        l_count := 0;

        SELECT COUNT(*)
        INTO   l_count
        FROM   pay_datetracked_events
        WHERE  column_name            = 'EFFECTIVE_START_DATE'
        AND    event_group_id         = l_event_group_id
        AND    dated_table_id         = l_dated_table_id ;

        hr_utility.trace('The count 20 is ' || TO_CHAR(l_count));

        IF (l_count = 0) THEN
            hr_utility.trace('If condition ... Creating Date Tracked Events');
            pay_datetracked_events_api.create_datetracked_event
            (
              p_validate               => FALSE
             ,p_effective_date         => TO_DATE(l_date,'dd/mm/yyyy')
             ,p_event_group_id         => l_event_group_id
             ,p_dated_table_id         => l_dated_table_id
                                            /* of pay_element_entries_f */
             ,p_update_type            => 'U'
             ,p_column_name            => 'EFFECTIVE_START_DATE'
             ,p_business_group_id      => l_business_group_id
             ,p_legislation_code       => NULL
             ,p_datetracked_event_id   => l_dt_event_id
             ,p_object_version_number  => l_ovn
            ) ;
        END IF;

        l_count := 0;

        SELECT COUNT(*)
        INTO   l_count
        FROM   pay_datetracked_events
        WHERE  column_name            = 'EFFECTIVE_END_DATE'
        AND    event_group_id         = l_event_group_id
        AND    dated_table_id         = l_dated_table_id ;

        hr_utility.trace('The count 25 is ' || TO_CHAR(l_count));

        IF (l_count = 0) THEN
            hr_utility.trace('If condition ... Creating Date Tracked Events');
            pay_datetracked_events_api.create_datetracked_event
            (
                p_validate                => FALSE
               ,p_effective_date          => TO_DATE(l_date,'dd/mm/yyyy')
               ,p_event_group_id          => l_event_group_id
               ,p_dated_table_id          => l_dated_table_id
                                            /* of pay_element_entries_f */
               ,p_update_type             => 'U'
               ,p_column_name             => 'EFFECTIVE_END_DATE'
               ,p_business_group_id       => l_business_group_id
               ,p_legislation_code        => NULL
               ,p_datetracked_event_id    => l_dt_event_id
               ,p_object_version_number   => l_ovn );
        END IF;
--b) Step b

        IF (teacher_england = 'YES') THEN
            hr_utility.trace('If condition for English Teachers');

            l_count := 0;

            SELECT COUNT(*)
            INTO   l_count
            FROM   pay_element_types_f
            WHERE  UPPER(element_name) =
                         UPPER(l_modified_base_ele || ' sal ele');

            IF (l_count = 0) THEN
                hr_utility.trace('If condition ... Creating Element');

                l_ele_id := pay_db_pay_setup.create_element(
                    p_element_name          => l_modified_base_ele || ' sal ele'
                   ,p_description           => 'Element to prorate the salary'
                   ,p_reporting_name        => SUBSTR(sal_rep_name, 1, 80)
                   ,p_classification_name   => 'Earnings'
                   ,p_post_termination_rule => 'Actual Termination'
                   ,p_processing_type       => 'R'
                   ,p_processing_priority   => 2500
                   ,p_standard_link_flag    => 'N'
                   ,p_business_group_name   => l_business
                   ,p_legislation_code      => NULL
                   ,p_effective_start_date  => TO_DATE(l_date,'dd/mm/yyyy')
                   ,p_effective_end_date   => TO_DATE('31/12/4712','dd/mm/yyyy')
                   ,p_proration_group_id    => l_event_group_id);
      --
      -- create input values
      --
                l_ipv_pv := NULL;

                FOR c_iv IN c_input_value(l_ele_id, 'Pay Value')
                LOOP
                    l_ipv_pv := c_iv.input_value_id;
                END LOOP;

                l_ipv_as := NULL;

                FOR c_iv IN c_input_value(l_ele_id, 'Amount')
                LOOP
                    l_ipv_as := c_iv.input_value_id;
                END LOOP;

                IF (l_ipv_as IS NULL) THEN
                    hr_utility.trace('If condition ... Creating Input Value');
                    l_ipv_as := pay_db_pay_setup.create_input_value(
                    p_element_name         => l_modified_base_ele || ' sal ele'
                   ,p_name                 => 'Amount'
                   ,p_uom_code             => 'M'
                   ,p_mandatory_flag       => 'X'
                   ,p_display_sequence     => 2
                   ,p_business_group_name  => l_business
                   ,p_effective_start_date => TO_DATE(l_date,'dd/mm/yyyy')
                   ,p_effective_end_date   => TO_DATE('31/12/4712','DD/MM/YYYY')
                   ,p_legislation_code     => NULL);
                END IF;
      --
            ELSE
                hr_utility.trace(l_modified_base_ele ||
                                           '_sal_ele already exists.');
            END IF;
        END IF;
        IF (teacher_scotland = 'YES' OR
                  (teacher_england = 'NO' AND teacher_scotland = 'NO')) THEN
            hr_utility.trace('If condition ... Teacher Scotland ');
            l_count := 0;

            SELECT COUNT(*)
            INTO   l_count
            FROM   pay_element_types_f
            WHERE  UPPER(element_name) =
                        UPPER(l_modified_base_ele || ' sal ele1');

            IF (l_count = 0) THEN
                hr_utility.trace('If condition ... create element');

                l_ele_id_scot := pay_db_pay_setup.create_element(
                    p_element_name         => l_modified_base_ele || ' sal ele1'
                   ,p_description           => 'Element to prorate the salary'
                   ,p_reporting_name        => SUBSTR(sal_rep_name, 1, 80)
                   ,p_classification_name   => 'Earnings'
                   ,p_post_termination_rule => 'Actual Termination'
                   ,p_processing_type       => 'R'
                   ,p_processing_priority   => 2500
                   ,p_standard_link_flag    => 'N'
                   ,p_business_group_name   => l_business
                   ,p_legislation_code      => NULL
                   ,p_effective_start_date  => TO_DATE(l_date,'dd/mm/yyyy')
                   ,p_effective_end_date   => TO_DATE('31/12/4712','dd/mm/yyyy')
                   ,p_proration_group_id    => l_event_group_id);
      --
      -- create input values
      --
                FOR c_iv1 IN c_input_value(l_ele_id_scot, 'Pay Value')
                LOOP
                    l_ipv_pv_scot := c_iv1.input_value_id;
                END LOOP;

                l_ipv_as := NULL;

                FOR c_iv IN c_input_value(l_ele_id_scot, 'Amount')
                LOOP
                    l_ipv_as := c_iv.input_value_id;
                END LOOP;

                IF (l_ipv_as IS NULL) THEN
                    hr_utility.trace('If condition ... create input value');
                    l_ipv_as := pay_db_pay_setup.create_input_value(
                    p_element_name        => l_modified_base_ele || ' sal ele1'
                   ,p_name                 => 'Amount'
                   ,p_uom_code             => 'M'
                   ,p_mandatory_flag       => 'X'
                   ,p_display_sequence     => 2
                   ,p_business_group_name  => l_business
                   ,p_effective_start_date => TO_DATE(l_date,'dd/mm/yyyy')
                   ,p_effective_end_date   => TO_DATE('31/12/4712','DD/MM/YYYY')
                   ,p_legislation_code     => NULL);
                END IF;
            ELSE
                hr_utility.trace(l_modified_base_ele ||
                                            ' sal ele1 already exists.');
            END IF;
        END IF;

-- c) Step c)

        IF (teacher_england = 'YES') THEN
            hr_utility.trace('If condition ... teacher england');
            l_count := 0;

            SELECT COUNT(*)
            INTO   l_count
            FROM   ff_formulas_f
            WHERE  formula_name  = UPPER(l_modified_base_formula || '_sal_ff');

            IF (l_count = 0) THEN
                hr_utility.trace('If condition ... count = 0');

                SELECT formula_type_id
                INTO   l_formula_type_id
                FROM   ff_formula_types
                WHERE  formula_type_name = 'Oracle Payroll';

--                SELECT formula_text
--                INTO   l_formula_text
--                FROM   ff_formulas_f ff
--                WHERE  ff.formula_name       = 'UK_PRORATION_SAL_MANAGEMENT'
--                AND    ff.legislation_code   = 'GB'
--                AND    ff.business_group_id IS NULL;

                FOR cft IN c_formula_text('UK_PRORATION_SAL_MANAGEMENT')
                LOOP
                    l_formula_text := cft.formula_text;
                END LOOP;

                l_formula_name := UPPER(l_modified_base_formula || '_sal_ff');
                l_formula_text :=
                          REPLACE(l_formula_text, 'annual_salary', 'Amount');
                l_formula_text :=
                          REPLACE(l_formula_text,
                                        'UK_PRORATION_SAL_MANAGEMENT',
                                        l_formula_name);
                l_description  := 'Formula for Salary Management';

                INSERT INTO ff_formulas_f
                    (formula_id           ,
                     effective_start_date ,
                     effective_end_date   ,
                     business_group_id    ,
                     legislation_code     ,
                     formula_type_id      ,
                     formula_name         ,
                     description          ,
                     formula_text         ,
                     last_update_date     ,
                     last_updated_by      ,
                     last_update_login    ,
                     created_by           ,
                     creation_date        )
                VALUES
                  (ff_formulas_s.NEXTVAL               , --  formula_id
                  TO_DATE(l_date,'dd/mm/yyyy')       , --  effective_start_date
                  TO_DATE('31/12/4712', 'DD/MM/YYYY') , --  effective_end_date
                  l_business_group_id                 , --  business_group_id
                  NULL                                , --  legislation_code
                  l_formula_type_id                   , --  formula_type_id
                  l_formula_name                      , --  formula_name
                  l_description                       , --  description
                  l_formula_text                      , --  formula_text
                  SYSDATE                             , --  last_update_date
                  -1                                  , --  last_updated_by
                  -1                                  , --  last_update_login
                  -1                                  , --  created_by
                  SYSDATE                            ); --  creation_date

--                SELECT formula_id
--                INTO   l_formula_id
--                FROM   ff_formulas_f ff
--                WHERE  ff.formula_name       = l_formula_name
--                AND    ff.legislation_code   IS NULL
--                AND    ff.business_group_id  = l_business_group_id;

                FOR cffi IN c_fast_formula_id(l_formula_name      ,
                                        l_business_group_id )
                LOOP
                    l_formula_id := cffi.formula_id;
                END LOOP;

                l_req_id := fnd_request.submit_request(
                            application    => 'FF'              ,
                            program        => 'BULKCOMPILE'     ,
                            argument1      => 'Oracle Payroll'  ,
                            argument2      => l_formula_name    );

                l_status_proc_rule_id := pay_formula_results.ins_stat_proc_rule
                      (
                        p_business_group_id    =>l_business_group_id
                       ,p_legislation_code     => NULL
                       ,p_effective_start_date => TO_DATE(l_date,'dd/mm/yyyy')
                       ,p_element_type_id      => l_ele_id
                       ,p_formula_id           => l_formula_id
                       ,p_processing_rule      => 'P'
                      );

                l_for_res_id := pay_formula_results.ins_form_res_rule
                       (
                          p_business_group_id         => l_business_group_id
                         ,p_legislation_code          => NULL
                         ,p_status_processing_rule_id => l_status_proc_rule_id
                         ,p_result_name               => 'RESULT1'
                         ,p_element_type_id           => l_ele_id
                         ,p_result_rule_type          => 'D'
                      ,p_effective_start_date   => TO_DATE(l_date,'dd/mm/yyyy')
                       );
            ELSE
                hr_utility.trace(l_modified_base_formula  ||
                                      '_sal_ff already exists.');
            END IF;
        END IF;

        IF (teacher_scotland = 'YES' OR
                  (teacher_england = 'NO' AND teacher_scotland = 'NO')) THEN
            hr_utility.trace('If condition ... teacher scotland');
            l_count := 0;

            SELECT COUNT(*)
            INTO   l_count
            FROM   ff_formulas_f
            WHERE  formula_name  = UPPER(l_modified_base_formula || '_sal_ff1');

            IF (l_count = 0) THEN
                hr_utility.trace('If condition ... count = 0');

                SELECT formula_type_id
                INTO   l_formula_type_id
                FROM   ff_formula_types
                WHERE  formula_type_name = 'Oracle Payroll';

--                SELECT formula_text
--                INTO   l_formula_text
--                FROM   ff_formulas_f ff
--                WHERE  ff.formula_name       = 'UK_PRORATION_ALLOWANCE'
--                AND    ff.legislation_code   = 'GB'
--                AND    ff.business_group_id IS NULL;

                FOR cft1 IN c_formula_text('UK_PRORATION_ALLOWANCE')
                LOOP
                    l_formula_text := cft1.formula_text;
                END LOOP;

                l_formula_name := UPPER(l_modified_base_formula || '_sal_ff1');

                l_formula_text :=
                          REPLACE(l_formula_text, 'annual_allowance', 'Amount');
                l_formula_text :=
                          REPLACE(l_formula_text,
                                        'UK_PRORATION_ALLOWANCE',
                                        l_formula_name);
                l_description  := 'Formula for Salary Management';

                INSERT INTO ff_formulas_f
                    (formula_id           ,
                     effective_start_date ,
                     effective_end_date   ,
                     business_group_id    ,
                     legislation_code     ,
                     formula_type_id      ,
                     formula_name         ,
                     description          ,
                     formula_text         ,
                     last_update_date     ,
                     last_updated_by      ,
                     last_update_login    ,
                     created_by           ,
                     creation_date        )
                VALUES
                  (ff_formulas_s.NEXTVAL               , --  formula_id
                  TO_DATE(l_date,'dd/mm/yyyy')       , --  effective_start_date
                  TO_DATE('31/12/4712', 'DD/MM/YYYY') , --  effective_end_date
                  l_business_group_id                 , --  business_group_id
                  NULL                                , --  legislation_code
                  l_formula_type_id                   , --  formula_type_id
                  l_formula_name                      , --  formula_name
                  l_description                       , --  description
                  l_formula_text                      , --  formula_text
                  SYSDATE                             , --  last_update_date
                  -1                                  , --  last_updated_by
                  -1                                  , --  last_update_login
                  -1                                  , --  created_by
                  SYSDATE                            ); --  creation_date

--                SELECT formula_id
--                INTO   l_formula_id
--                FROM   ff_formulas_f ff
--                WHERE  ff.formula_name       = l_formula_name
--                AND    ff.legislation_code   IS NULL
--                AND    ff.business_group_id  = l_business_group_id;

                FOR cffi1 IN c_fast_formula_id(l_formula_name      ,
                                        l_business_group_id )
                LOOP
                    l_formula_id := cffi1.formula_id;
                END LOOP;
                l_req_id := fnd_request.submit_request(
                            application    => 'FF'              ,
                            program        => 'BULKCOMPILE'     ,
                            argument1      => 'Oracle Payroll'  ,
                            argument2      => l_formula_name    );

                l_status_proc_rule_id := pay_formula_results.ins_stat_proc_rule
                      (
                        p_business_group_id    =>l_business_group_id
                       ,p_legislation_code     => NULL
                       ,p_effective_start_date => TO_DATE(l_date,'dd/mm/yyyy')
                       ,p_element_type_id      => l_ele_id_scot
                       ,p_formula_id           => l_formula_id
                       ,p_processing_rule      => 'P'
                      );

                l_for_res_id := pay_formula_results.ins_form_res_rule
                       (
                          p_business_group_id         => l_business_group_id
                         ,p_legislation_code          => NULL
                         ,p_status_processing_rule_id => l_status_proc_rule_id
                         ,p_result_name               => 'L_AMOUNT'
                         ,p_element_type_id           => l_ele_id_scot
                         ,p_result_rule_type          => 'D'
                      ,p_effective_start_date   => TO_DATE(l_date,'dd/mm/yyyy')
                       );
            ELSE
                hr_utility.trace(l_modified_base_formula  ||
                                      '_sal_ff1 already exists.');
            END IF;
        END IF;
    END IF;

--****************   GRADES ******************************

    IF (l_grade_flag = 'TRUE') THEN
        hr_utility.trace('If condition ... grade flag is true');

-- We should basically
-- a) Create a Pro ration Group with the events enabled for SALARY.
-- b) Create an Element.
-- c) Link the formula to the element.
-- d) Enable the dynamic triggers and Functional Specifications.

-- a) Step a

-- PAY_DATETRACKED_EVENTS_API. CREATE_DATETRACKED_EVENT
-- PAY_EVENT_GROUPS_API.CREATE_EVENT_GROUP

        l_count := 0;

        SELECT COUNT(*)
        INTO   l_count
        FROM   pay_event_groups
        WHERE  event_group_name = UPPER(l_modified_base_pg || ' GRADE pg');

        IF (l_count = 0 ) THEN
            hr_utility.trace('If condition ... creating event group');
            pay_event_groups_api.create_event_group
            (
            p_effective_date         => TO_DATE(l_date,'dd/mm/yyyy')
           ,p_event_group_name       => UPPER(l_modified_base_pg || ' grade pg')
           ,p_event_group_type       => 'P'
           ,p_proration_type         => 'P'
           ,p_business_group_id      => l_business_group_id
           ,p_legislation_code       => NULL
           ,p_event_group_id         => l_event_group_id
           ,p_object_version_number  => l_ovn
             );
        ELSE
            hr_utility.trace('Else condition ...');
            l_event_group_id := NULL;

--            SELECT event_group_id
--            INTO   l_event_group_id
--            FROM   pay_event_groups
--            WHERE  event_group_name = UPPER(l_modified_base_pg || ' GRADE pg');
            FOR cegi1 IN c_event_group_id(l_modified_base_pg || ' GRADE pg')
            LOOP
                l_event_group_id := cegi1.event_group_id;
            END LOOP;
        END IF;

        FOR c2 IN c_dated_pay_table ('PAY_GRADE_RULES_F')
        LOOP
            l_dated_table_id := c2.dated_table_id;
        END LOOP;

        l_count := 0;

        SELECT COUNT(*)
        INTO   l_count
        FROM   pay_datetracked_events
        WHERE  column_name            = 'VALUE'
        AND    event_group_id         = l_event_group_id
        AND    dated_table_id         = l_dated_table_id;

        IF (l_count = 0) THEN
            hr_utility.trace('If condition ... creating datetracked events');

            pay_datetracked_events_api.create_datetracked_event
            (
                p_validate               => FALSE
               ,p_effective_date         => TO_DATE(l_date,'dd/mm/yyyy')
               ,p_event_group_id         => l_event_group_id
               ,p_dated_table_id         => l_dated_table_id
                                                 -- of pay_grade_rules_f
               ,p_update_type            => 'U'
               ,p_column_name            => 'VALUE'
               ,p_business_group_id      => l_business_group_id
               ,p_legislation_code       => NULL
               ,p_datetracked_event_id   => l_dt_event_id
               ,p_object_version_number  => l_ovn
            ) ;
        END IF;

        FOR c2 IN c_dated_pay_table ('PER_ALL_ASSIGNMENTS_F')
        LOOP
            l_dated_table_id := c2.dated_table_id;
        END LOOP;

        l_count := 0;

        SELECT COUNT(*)
        INTO   l_count
        FROM   pay_datetracked_events
        WHERE  column_name            = 'GRADE_ID'
        AND    event_group_id         = l_event_group_id
        AND    dated_table_id         = l_dated_table_id ;

        IF (l_count = 0) THEN
            hr_utility.trace('If condition ... creating datetracked events');

            pay_datetracked_events_api.create_datetracked_event
            (
                p_validate                => FALSE
               ,p_effective_date          => TO_DATE(l_date,'dd/mm/yyyy')
               ,p_event_group_id          => l_event_group_id
               ,p_dated_table_id          => l_dated_table_id
                                     -- of per_all_assignments_f
               ,p_update_type             => 'U'
               ,p_column_name             => 'GRADE_ID'
               ,p_business_group_id       => l_business_group_id
               ,p_legislation_code        => NULL
               ,p_datetracked_event_id    => l_dt_event_id
               ,p_object_version_number   => l_ovn );

        END IF;

--b) Step b

        l_count := 0;

        SELECT COUNT(*)
        INTO   l_count
        FROM   pay_element_types_f
        WHERE  UPPER(element_name) = UPPER(l_modified_base_ele || ' grade ele');

        IF (l_count = 0) THEN
            hr_utility.trace('If condition ... creating elements');

            l_ele_id := pay_db_pay_setup.create_element(
                p_element_name          => l_modified_base_ele || ' grade ele'
               ,p_description           => 'Element to prorate the Grades'
               ,p_reporting_name        => grade_rep_name
               ,p_classification_name   => 'Earnings'
               ,p_post_termination_rule => 'Actual Termination'
               ,p_processing_type       => 'R'
               ,p_processing_priority   => 2500
               ,p_standard_link_flag    => 'N'
               ,p_business_group_name   => l_business
               ,p_legislation_code      => NULL
               ,p_effective_start_date  => to_date(l_date,'dd/mm/yyyy')
               ,p_effective_end_date    => to_date('31/12/4712','dd/mm/yyyy')
               ,p_proration_group_id    => l_event_group_id);

      --
      -- create input values
      --
--            SELECT input_value_id
--            INTO   l_ipv_pv
--            FROM   pay_input_values_f
--            WHERE  element_type_id = l_ele_id
--            AND    name            = 'Pay Value'
--            AND    rownum          < 2;

            l_ipv_pv := NULL;

            FOR c_iv IN c_input_value(l_ele_id, 'Pay Value')
            LOOP
                l_ipv_pv := c_iv.input_value_id;
            END LOOP;
      --
        ELSE
          hr_utility.trace(l_modified_base_ele || '_grade_ele already exists.');
        END IF;

        IF (p_ele_gr_name IS NOT NULL) THEN
            IF (l_count <> 0) THEN
                FOR ceti IN c_element_id(l_modified_base_ele || ' grade ele')
                LOOP
                    l_ele_id := ceti.element_type_id;
                END LOOP;
            END IF;

            l_count := 0;

            FOR cetei IN c_element_extra_info_cnt(l_ele_id)
            LOOP
                l_count := cetei.count;
            END LOOP;
            IF (l_count = 0 ) THEN
                hr_utility.trace('If condition ...creating element extra info');
                pay_db_pay_setup.set_session_date(trunc(sysdate));
                l_etei_id  := NULL;
                l_etei_ovn := NULL;
                pay_element_extra_info_api.create_element_extra_info
                   ( p_element_type_id           => l_ele_id
                    ,p_information_type          => 'PQP_UK_ELEMENT_ATTRIBUTION'
                    ,p_eei_information_category  => 'PQP_UK_ELEMENT_ATTRIBUTION'
                    ,p_eei_information1          => 'H'
                                        -- For Hourly Time Dimension
                    ,p_eei_information2          => 'GR'
                                        -- Spinal Points Pay Source Value
                    ,p_eei_information3          =>  p_ele_gr_name
                    ,p_eei_information4          => 'N'
                                        -- No FTE
                    ,p_eei_information5          => 'N'
                    ,p_element_type_extra_info_id => l_etei_id
                    ,p_object_version_number      => l_etei_ovn
                                    -- 'No' Service History
                    );
            ELSE
                hr_utility.trace('Else condition..updating element extra info');
                pay_db_pay_setup.set_session_date(trunc(sysdate));
                l_etei_id  := NULL;
                l_etei_ovn := NULL;
                FOR cetei1 IN c_element_extra_info_id(l_ele_id)
                LOOP
                    l_etei_id  := cetei1.element_type_extra_info_id;
                    l_etei_ovn := cetei1.object_version_number;
                END LOOP;

                pay_element_extra_info_api.update_element_extra_info
                    (p_element_type_extra_info_id => l_etei_id
                    ,p_object_version_number      => l_etei_ovn
                    ,p_eei_information_category  => 'PQP_UK_ELEMENT_ATTRIBUTION'
                    ,p_eei_information1          => 'H'
                                        -- For Hourly Time Dimension
                    ,p_eei_information2          => 'GR'
                                        -- Spinal Points Pay Source Value
                    ,p_eei_information3          =>  p_ele_gr_name
                    ,p_eei_information4          => 'N'
                                        -- No FTE
                    ,p_eei_information5          => 'N'
                                    -- 'No' Service History
                    );
            END IF;
        END IF;

-- c) Step c)

        l_count := 0;

        SELECT COUNT(*)
        INTO   l_count
        FROM   ff_formulas_f
        WHERE  formula_name  = UPPER(l_modified_base_formula || '_grade_ff');

        IF (l_count = 0) THEN
            hr_utility.trace('If condition ...creating formula');
            SELECT formula_type_id
            INTO   l_formula_type_id
            FROM   ff_formula_types
            WHERE  formula_type_name = 'Oracle Payroll';

--            SELECT formula_text
--            INTO   l_formula_text
--            FROM   ff_formulas_f ff
--            WHERE  ff.formula_name       = 'UK_PRORATION_GRADE_RATE'
--            AND    ff.legislation_code   = 'GB'
--            AND    ff.business_group_id  IS NULL;

            FOR cft2 IN c_formula_text('UK_PRORATION_GRADE_RATE')
            LOOP
                l_formula_text := cft2.formula_text;
            END LOOP;

        l_formula_name := UPPER(l_modified_base_formula || '_grade_ff');
        l_description  := 'Formula for Grades Proration';

        l_formula_text := REPLACE(l_formula_text, 'UK_PRORATION_GRADE_RATE',
                                        l_formula_name);

        l_formula_text := REPLACE(l_formula_text, 'UK Grade Rate',
                         l_modified_base_ele || ' grade ele' );

        INSERT INTO ff_formulas_f
            (formula_id            ,
             effective_start_date  ,
             effective_end_date    ,
             business_group_id    ,
             legislation_code      ,
             formula_type_id       ,
             formula_name          ,
             description           ,
             formula_text          ,
             last_update_date      ,
             last_updated_by       ,
             last_update_login     ,
             created_by            ,
             creation_date         )
        VALUES
             (ff_formulas_s.NEXTVAL                 , --  formula_id
              TO_DATE(l_date,'dd/mm/yyyy')          , --  effective_start_date
              TO_DATE('31/12/4712', 'DD/MM/YYYY')   , --  effective_end_date
              l_business_group_id                   , --  business_group_id
              NULL                                  , --  legislation_code
              l_formula_type_id                     , --  formula_type_id
              l_formula_name                        , --  formula_name
              l_description                         , --  description
              l_formula_text                        , --  formula_text
              SYSDATE                               , --  last_update_date
              -1                                    , --  last_updated_by
              -1                                    , --  last_update_login
              -1                                    , --  created_by
              SYSDATE                               ); --  creation_date

--        SELECT formula_id
--        INTO   l_formula_id
--        FROM   ff_formulas_f ff
--        WHERE  ff.formula_name       = l_formula_name
--        AND    ff.legislation_code   IS NULL
--        AND    ff.business_group_id  = l_business_group_id;

        FOR cffi2 IN c_fast_formula_id(l_formula_name,
                                       l_business_group_id)
        LOOP
            l_formula_id := cffi2.formula_id;
        END LOOP;

        l_req_id := fnd_request.submit_request(
                            application    => 'FF'              ,
                            program        => 'BULKCOMPILE'     ,
                            argument1      => 'Oracle Payroll'  ,
                            argument2      => l_formula_name    );

        l_status_proc_rule_id := pay_formula_results.ins_stat_proc_rule
          (
            p_business_group_id    =>l_business_group_id
           ,p_legislation_code     => NULL
           ,p_effective_start_date => TO_DATE(l_date,'dd/mm/yyyy')
           ,p_element_type_id      => l_ele_id
           ,p_formula_id           => l_formula_id
           ,p_processing_rule      => 'P'
          );

        l_for_res_id := pay_formula_results.ins_form_res_rule
           (
              p_business_group_id         => l_business_group_id
             ,p_legislation_code          => NULL
             ,p_status_processing_rule_id => l_status_proc_rule_id
             ,p_input_value_id            => l_ipv_pv
             ,p_result_name               => 'L_AMOUNT'
             ,p_element_type_id           => l_ele_id
             ,p_result_rule_type          => 'D'
             ,p_effective_start_date      => TO_DATE(l_date,'dd/mm/yyyy')
           );
        ELSE
      hr_utility.trace(l_modified_base_formula  || '_grade_ff already exists.');
        END IF;
    END IF;
--***************  PROGRESSION POINTS (Pay Scale) **************************

    IF (l_pscale_flag = 'TRUE') THEN
        hr_utility.trace('If condition ...pay scale flag is true');
-- We should basically
-- a) Create a Pro ration Group with the events enabled for SALARY.
-- b) Create an Element.
-- c) Link the formula to the element.
-- d) Enable the dynamic triggers and Functional Specifications.

        l_grade_flag            := 'TRUE';
-- a) Step a

-- PAY_DATETRACKED_EVENTS_API. CREATE_DATETRACKED_EVENT
-- PAY_EVENT_GROUPS_API.CREATE_EVENT_GROUP

        l_count := 0;

        SELECT COUNT(*)
        INTO   l_count
        FROM   pay_event_groups
        WHERE  event_group_name = UPPER(l_modified_base_pg || ' PAYSCALE pg');

        IF (l_count = 0) THEN
            hr_utility.trace('If condition ...creating event group');
            pay_event_groups_api.create_event_group
            (
            p_effective_date         => TO_DATE(l_date,'dd/mm/yyyy')
           ,p_event_group_name   => UPPER(l_modified_base_pg || ' payscale pg' )
           ,p_event_group_type       => 'P'
           ,p_proration_type         => 'P'
           ,p_business_group_id      => l_business_group_id
           ,p_legislation_code       => NULL
           ,p_event_group_id         => l_event_group_id
           ,p_object_version_number  => l_ovn
            );
        ELSE
            hr_utility.trace('else condition ...selecting from event group');
            l_event_group_id := NULL;

--            SELECT event_group_id
--            INTO   l_event_group_id
--            FROM   pay_event_groups
--            WHERE  event_group_name = UPPER(l_modified_base_pg ||
--                                                              ' payscale pg');
            FOR cegi3 IN c_event_group_id(UPPER(l_modified_base_pg || ' payscale pg'))
            LOOP
                l_event_group_id := cegi3.event_group_id;
            END LOOP;
        END IF;

        FOR c2 IN c_dated_pay_table ('PER_SPINAL_POINT_PLACEMENTS_F')
        LOOP
            l_dated_table_id := c2.dated_table_id;
        END LOOP;

        l_count := 0;

        SELECT COUNT(*)
        INTO   l_count
        FROM   pay_datetracked_events
        WHERE  column_name            = 'STEP_ID'
        AND    event_group_id         = l_event_group_id
        AND    dated_table_id         = l_dated_table_id ;

        IF (l_count = 0) THEN
            hr_utility.trace('If condition ...creating datetracked events');
            pay_datetracked_events_api.create_datetracked_event
            (
                p_validate               => FALSE
               ,p_effective_date         => TO_DATE(l_date,'dd/mm/yyyy')
               ,p_event_group_id         => l_event_group_id
               ,p_dated_table_id         => l_dated_table_id
--                                 PER_SPINAL_POINT_PLACEMENTS_F
               ,p_update_type            => 'U'
               ,p_column_name            => 'STEP_ID'
               ,p_business_group_id      => l_business_group_id
               ,p_legislation_code       => NULL
               ,p_datetracked_event_id   => l_dt_event_id
               ,p_object_version_number  => l_ovn
            ) ;
        END IF;

        FOR c2 IN c_dated_pay_table ('PAY_GRADE_RULES_F')
        LOOP
            l_dated_table_id := c2.dated_table_id;
        END LOOP;
        l_count := 0;
        SELECT COUNT(*)
        INTO   l_count
        FROM   pay_datetracked_events
        WHERE  column_name            = 'VALUE'
        AND    event_group_id         = l_event_group_id
        AND    dated_table_id         = l_dated_table_id;

        IF (l_count = 0) THEN
            hr_utility.trace('If condition ...creating datetracked events');

            pay_datetracked_events_api.create_datetracked_event
            (
                p_validate               => FALSE
               ,p_effective_date         => TO_DATE(l_date,'dd/mm/yyyy')
               ,p_event_group_id         => l_event_group_id
               ,p_dated_table_id         => l_dated_table_id
                                      -- of pay_grade_rules_f
               ,p_update_type            => 'U'
               ,p_column_name            => 'VALUE'
               ,p_business_group_id      => l_business_group_id
               ,p_legislation_code       => NULL
               ,p_datetracked_event_id   => l_dt_event_id
               ,p_object_version_number  => l_ovn
            ) ;
        END IF;

        FOR c2 IN c_dated_pay_table ('PER_ALL_ASSIGNMENTS_F')
        LOOP
            l_dated_table_id := c2.dated_table_id;
        END LOOP;

        l_count := 0;

        SELECT COUNT(*)
        INTO   l_count
        FROM   pay_datetracked_events
        WHERE  column_name            = 'GRADE_ID'
        AND    event_group_id         = l_event_group_id
        AND    dated_table_id         = l_dated_table_id ;

        IF (l_count = 0) THEN
            hr_utility.trace('If condition ...creating datetracked events');

            pay_datetracked_events_api.create_datetracked_event
            (
                p_validate                => FALSE
               ,p_effective_date          => TO_DATE(l_date,'dd/mm/yyyy')
               ,p_event_group_id          => l_event_group_id
               ,p_dated_table_id          => l_dated_table_id
                                     -- of per_all_assignments_f
               ,p_update_type             => 'U'
               ,p_column_name             => 'GRADE_ID'
               ,p_business_group_id       => l_business_group_id
               ,p_legislation_code        => NULL
               ,p_datetracked_event_id    => l_dt_event_id
               ,p_object_version_number   => l_ovn );

        END IF;

--b) Step b

        l_count := 0;

        SELECT COUNT(*)
        INTO   l_count
        FROM   pay_element_types_f
        WHERE  UPPER(element_name) =
                         UPPER(l_modified_base_ele || ' payscale ele');
hr_utility.trace('The count is ' || TO_CHAR(l_count));

        IF (l_count = 0) THEN
            hr_utility.trace('If condition ...creating element');

            l_ele_id := pay_db_pay_setup.create_element(
                p_element_name         => l_modified_base_ele || ' payscale ele'
               ,p_description           => 'Element to prorate the Pay Scale'
               ,p_reporting_name        => ps_rep_name
               ,p_classification_name   => 'Earnings'
               ,p_post_termination_rule => 'Actual Termination'
               ,p_processing_type       => 'R'
               ,p_processing_priority   => 2500
               ,p_standard_link_flag    => 'N'
               ,p_business_group_name   => l_business
               ,p_legislation_code      => NULL
               ,p_effective_start_date  => to_date(l_date,'dd/mm/yyyy')
               ,p_effective_end_date    => to_date('31/12/4712','dd/mm/yyyy')
               ,p_proration_group_id    => l_event_group_id);

hr_utility.trace('The element type id is ' || TO_CHAR(l_ele_id));

      --
      -- create input values
      --
--            SELECT input_value_id
--            INTO   l_ipv_pv
--            FROM   pay_input_values_f
--            WHERE  element_type_id = l_ele_id
--            AND    name            = 'Pay Value'
--            AND    rownum  < 2                  ;

            l_ipv_pv := NULL;

            FOR c_iv IN c_input_value(l_ele_id, 'Pay Value')
            LOOP
                l_ipv_pv := c_iv.input_value_id;
            END LOOP;
        ELSE
            hr_utility.trace(l_modified_base_ele ||
                                             ' payscale ele already exists.');
        END IF;
        IF (p_ele_psr_name IS NOT NULL) THEN
hr_utility.trace('Pay Scale qualifier is not null');
            IF (l_count <> 0) THEN
hr_utility.trace('Second iteration');
                FOR ceti IN c_element_id(l_modified_base_ele || ' payscale ele')
                LOOP
                    l_ele_id := ceti.element_type_id;
                END LOOP;
hr_utility.trace('The element id is ' || TO_CHAR(l_ele_id));
            END IF;

            l_count := 0;

            FOR cetei IN c_element_extra_info_cnt(l_ele_id)
            LOOP
                l_count := cetei.count;
            END LOOP;
hr_utility.trace('The count is ' || TO_CHAR(l_count));

            IF (l_count = 0) THEN
                hr_utility.trace('If condition ...creating element extra info');
                l_etei_id  := NULL;
                l_etei_ovn := NULL;
                pay_db_pay_setup.set_session_date(trunc(sysdate));
                pay_element_extra_info_api.create_element_extra_info
                   ( p_element_type_id           => l_ele_id
                    ,p_information_type          => 'PQP_UK_ELEMENT_ATTRIBUTION'
                    ,p_eei_information_category  => 'PQP_UK_ELEMENT_ATTRIBUTION'
                    ,p_eei_information1          => 'H'
                                            -- For Hourly Time Dimension
                    ,p_eei_information2          => 'SP'
                                            -- Spinal Points Pay Source Value
                    ,p_eei_information3          =>  p_ele_psr_name
                    ,p_eei_information4          => 'N'
                                            --  No FTE
                    ,p_eei_information5          => 'N'
                    ,p_element_type_extra_info_id => l_etei_id
                    ,p_object_version_number      => l_etei_ovn
                             -- 'No' Service History
                   );
hr_utility.trace('The extra info id is '|| TO_CHAR(l_etei_id));
            ELSE
                hr_utility.trace('Else condition..updating element extra info');
                pay_db_pay_setup.set_session_date(trunc(sysdate));
                l_etei_id  := NULL;
                l_etei_ovn := NULL;
                FOR cetei1 IN c_element_extra_info_id(l_ele_id)
                LOOP
                    l_etei_id  := cetei1.element_type_extra_info_id;
                    l_etei_ovn := cetei1.object_version_number;
                END LOOP;

                pay_element_extra_info_api.update_element_extra_info
                    (p_element_type_extra_info_id => l_etei_id
                    ,p_object_version_number      => l_etei_ovn
                    ,p_eei_information_category  => 'PQP_UK_ELEMENT_ATTRIBUTION'
                    ,p_eei_information1          => 'H'
                                        -- For Hourly Time Dimension
                    ,p_eei_information2          => 'SP'
                                            -- Spinal Points Pay Source Value
                    ,p_eei_information3          =>  p_ele_psr_name
                    ,p_eei_information4          => 'N'
                                        -- No FTE
                    ,p_eei_information5          => 'N'
                                    -- 'No' Service History
                    );
             END IF;
        END IF;

-- c) Step c)

        l_count := 0;

        SELECT COUNT(*)
        INTO   l_count
        FROM   ff_formulas_f
        WHERE  formula_name  = UPPER(l_modified_base_ele || '_payscale_ff');

        IF (l_count = 0) THEN
            SELECT formula_type_id
            INTO   l_formula_type_id
            FROM   ff_formula_types
            WHERE  formula_type_name = 'Oracle Payroll';

--            SELECT formula_text
--            INTO   l_formula_text
--            FROM   ff_formulas_f ff
--            WHERE  ff.formula_name       = 'UK_PRORATION_SPINAL_POINT'
--            AND    ff.legislation_code   = 'GB'
--            AND    ff.business_group_id  IS NULL;

            FOR cft4 IN c_formula_text('UK_PRORATION_SPINAL_POINT')
            LOOP
                 l_formula_text := cft4.formula_text;
            END LOOP;

            l_formula_name := UPPER(l_modified_base_formula || '_payscale_ff');
            l_description  := 'Formula for Progression Point Proration';

            l_formula_text := REPLACE(l_formula_text,
                                  'UK_PRORATION_SPINAL_POINT', l_formula_name);

            l_formula_text := REPLACE(l_formula_text, 'UK Spinal Point',
                                      l_modified_base_ele || ' payscale ele');

            INSERT INTO ff_formulas_f
            (    formula_id            ,
                 effective_start_date  ,
                 effective_end_date    ,
                 business_group_id    ,
                 legislation_code      ,
                 formula_type_id       ,
                 formula_name          ,
                 description           ,
                 formula_text          ,
                 last_update_date      ,
                 last_updated_by       ,
                 last_update_login     ,
                 created_by            ,
                 creation_date         )
            VALUES
             (    ff_formulas_s.NEXTVAL                 , --  formula_id
                  TO_DATE(l_date,'dd/mm/yyyy')       , --  effective_start_date
                  TO_DATE('31/12/4712', 'DD/MM/YYYY')   , --  effective_end_date
                  l_business_group_id                   , --  business_group_id
                  NULL                                  , --  legislation_code
                  l_formula_type_id                     , --  formula_type_id
                  l_formula_name                        , --  formula_name
                  l_description                         , --  description
                  l_formula_text                        , --  formula_text
                  SYSDATE                               , --  last_update_date
                  -1                                    , --  last_updated_by
                  -1                                    , --  last_update_login
                  -1                                    , --  created_by
                  SYSDATE                               ); --  creation_date

--            SELECT formula_id
--            INTO   l_formula_id
--            FROM   ff_formulas_f ff
--            WHERE  ff.formula_name       = l_formula_name
--            AND    ff.legislation_code   IS NULL
--            AND    ff.business_group_id  = l_business_group_id;

            FOR cffi4 IN c_fast_formula_id (l_formula_name,
                                            l_business_group_id)
            LOOP
                l_formula_id := cffi4.formula_id;
            END LOOP;

            l_req_id := fnd_request.submit_request(
                            application    => 'FF'              ,
                            program        => 'BULKCOMPILE'     ,
                            argument1      => 'Oracle Payroll'  ,
                            argument2      => l_formula_name    );
    --
            l_status_proc_rule_id := pay_formula_results.ins_stat_proc_rule
              (
                p_business_group_id    => l_business_group_id
               ,p_legislation_code     => NULL
               ,p_effective_start_date => TO_DATE(l_date,'dd/mm/yyyy')
               ,p_element_type_id      => l_ele_id
               ,p_formula_id           => l_formula_id
               ,p_processing_rule      => 'P'
              );

            l_for_res_id := pay_formula_results.ins_form_res_rule
               (
                  p_business_group_id         => l_business_group_id
                 ,p_legislation_code          => NULL
                 ,p_status_processing_rule_id => l_status_proc_rule_id
                 ,p_input_value_id            => l_ipv_pv
                 ,p_result_name               => 'L_AMOUNT'
                 ,p_element_type_id           => l_ele_id
                 ,p_result_rule_type          => 'D'
                 ,p_effective_start_date      => TO_DATE(l_date,'dd/mm/yyyy')
               );
        ELSE
            hr_utility.trace(l_modified_base_formula  ||
                                               '_payscale_ff already exists.');
        END IF;
    END IF;

    hr_utility.trace('Enabling dynamic trigger ');
    enable_dynamic_triggers
    (
        p_business_group_id => l_business_group_id ,
        p_salary_flag       => l_salary_flag       ,
        p_grade_flag        => l_grade_flag        ,
        p_spinal_flag       => l_pscale_flag       ,
        p_address_flag      => 'FALSE'             ,
        p_location_flag     => 'FALSE'
    );
    hr_utility.set_location('Leaving }'|| gv_package || lv_procedure_name, 250);

END standard_proc;
-- ***************************************************************************
--    proration_group_proc
-- ***************************************************************************
PROCEDURE proration_group_proc
(
    p_pgname             IN VARCHAR2   DEFAULT NULL ,
    p_pg_startdate       IN VARCHAR2   DEFAULT NULL ,
    p_pggrd              IN VARCHAR2   DEFAULT NULL ,
    p_pggrdrt            IN VARCHAR2   DEFAULT NULL ,
    p_pgchgpysc          IN VARCHAR2   DEFAULT NULL ,
    p_pgchrtpysc         IN VARCHAR2   DEFAULT NULL ,
    p_pgchgsal           IN VARCHAR2   DEFAULT NULL ,
    p_pgtermemp          IN VARCHAR2   DEFAULT NULL ,
    p_pgnewhre           IN VARCHAR2   DEFAULT NULL ,
    p_pgstchenea         IN VARCHAR2   DEFAULT NULL ,
    p_pgstchended        IN VARCHAR2   DEFAULT NULL ,
    p_pgchgloc           IN VARCHAR2   DEFAULT NULL ,
    p_business_group_pg  IN VARCHAR2   DEFAULT NULL
)
AS
   l_business_group_id    NUMBER ;
   l_count                NUMBER ;
   l_event_group_id       NUMBER ;
   l_dt_event_id          NUMBER ;
   l_dated_table_id       NUMBER ;
   l_ovn                  NUMBER ;
   l_pg_name              VARCHAR2(40);
   l_business_group_name  VARCHAR2(80);
   lv_procedure_name      VARCHAR2(80) := '.proration_group_proc' ;

   l_salary_flag          VARCHAR2(40) := 'FALSE';
   l_grade_flag           VARCHAR2(40) := 'FALSE';
   l_payscale_flag        VARCHAR2(40) := 'FALSE';
   l_address_flag         VARCHAR2(40) := 'FALSE';
   l_location_flag        VARCHAR2(40) := 'FALSE';
BEGIN
    hr_utility.set_location('Entering {'|| gv_package || lv_procedure_name, 250);
    valid_business_group(p_business_group_name => p_business_group_pg);
    l_business_group_name := p_business_group_pg;
    FOR c1 IN c_biz_group (l_business_group_name)
    LOOP
        l_business_group_id := c1.business_group_id;
    END LOOP;

    l_pg_name := UPPER(SUBSTR(REPLACE(p_pgname, ' ',' '), 1, 40));

-- a) Step a

-- PAY_DATETRACKED_EVENTS_API. CREATE_DATETRACKED_EVENT
-- PAY_EVENT_GROUPS_API.CREATE_EVENT_GROUP

    l_count := 0;

    SELECT COUNT(*)
    INTO   l_count
    FROM   pay_event_groups
    WHERE  event_group_name = l_pg_name;

    IF (l_count = 0) THEN
        hr_utility.trace('If condition ... Creating event groups');
        pay_event_groups_api.create_event_group
        (
           p_effective_date        => TO_DATE(p_pg_startdate,'dd/mm/yyyy')
          ,p_event_group_name      => l_pg_name
          ,p_event_group_type      => 'P'
          ,p_proration_type        => 'P'
          ,p_business_group_id     => l_business_group_id
          ,p_legislation_code      => NULL
          ,p_event_group_id        => l_event_group_id
          ,p_object_version_number => l_ovn
        );
    ELSE
        hr_utility.trace('Else condition ...');
        l_event_group_id := NULL;

--        SELECT event_group_id
--        INTO   l_event_group_id
--        FROM   pay_event_groups
--        WHERE  event_group_name = l_pg_name;

        FOR cegid IN c_event_group_id (l_pg_name)
        LOOP
            l_event_group_id := cegid.event_group_id;
        END LOOP;
    END IF;

-- Change in Grade

    IF (UPPER(p_pggrd) = 'YES') THEN
        hr_utility.trace('If condition ... p_pggrd');
        FOR c2 IN c_dated_pay_table ('PER_ALL_ASSIGNMENTS_F')
        LOOP
            l_dated_table_id := c2.dated_table_id;
        END LOOP;
        l_count := 0;

        SELECT COUNT(*)
        INTO   l_count
        FROM   pay_datetracked_events
        WHERE  column_name            = 'GRADE_ID'
        AND    event_group_id         = l_event_group_id
        AND    dated_table_id         = l_dated_table_id ;

        IF (l_count = 0) THEN
            hr_utility.trace('If condition ... creating datetracked event');

            pay_datetracked_events_api.create_datetracked_event
            (
            p_validate                => FALSE
           ,p_effective_date          => TO_DATE(p_pg_startdate,'dd/mm/yyyy')
           ,p_event_group_id          => l_event_group_id
           ,p_dated_table_id          => l_dated_table_id
                                          -- of per_all_assignments_f
           ,p_update_type             => 'U'
           ,p_column_name             => 'GRADE_ID'
           ,p_business_group_id       => l_business_group_id
           ,p_legislation_code        => NULL
           ,p_datetracked_event_id    => l_dt_event_id
           ,p_object_version_number   => l_ovn );
        END IF;
    END IF;

--  Change in Pay Scale

    IF (UPPER(p_pgchgpysc) = 'YES') THEN
        hr_utility.trace('If condition ... p_pgchgpysc');

        l_payscale_flag := 'TRUE';

        FOR c2 IN c_dated_pay_table ('PER_SPINAL_POINT_PLACEMENTS_F')
        LOOP
            l_dated_table_id := c2.dated_table_id;
        END LOOP;
        l_count := 0;

        SELECT COUNT(*)
        INTO   l_count
        FROM   pay_datetracked_events
        WHERE  column_name            = 'STEP_ID'
        AND    event_group_id         = l_event_group_id
        AND    dated_table_id         = l_dated_table_id ;

        IF (l_count = 0) THEN
            hr_utility.trace('If condition ... creating datetracked event');

            pay_datetracked_events_api.create_datetracked_event
        (
            p_validate               => FALSE
           ,p_effective_date         => TO_DATE(p_pg_startdate,'dd/mm/yyyy')
           ,p_event_group_id         => l_event_group_id
           ,p_dated_table_id         => l_dated_table_id
                                        --   PER_SPINAL_POINT_PLACEMENTS_F
           ,p_update_type            => 'U'
           ,p_column_name            => 'STEP_ID'
           ,p_business_group_id      => l_business_group_id
           ,p_legislation_code       => NULL
           ,p_datetracked_event_id   => l_dt_event_id
           ,p_object_version_number  => l_ovn
        ) ;
        END IF;
    END IF;

-- Change in Grade Rate or Change in Rate associated with Payscale

    IF (UPPER(p_pggrdrt) = 'YES' OR UPPER(p_pgchrtpysc) = 'YES') THEN
        hr_utility.trace('If condition ... p_pggrdrt p_pgchrtpysc');

        l_grade_flag := 'TRUE';

        FOR c2 IN c_dated_pay_table ('PAY_GRADE_RULES_F')
        LOOP
            l_dated_table_id := c2.dated_table_id;
        END LOOP;
        l_count := 0;

        SELECT COUNT(*)
        INTO   l_count
        FROM   pay_datetracked_events
        WHERE  column_name            = 'VALUE'
        AND    event_group_id         = l_event_group_id
        AND    dated_table_id         = l_dated_table_id ;

        IF (l_count = 0) THEN
            hr_utility.trace('If condition ... creating datetracked event');

            pay_datetracked_events_api.create_datetracked_event
            (
            p_validate               => FALSE
           ,p_effective_date         => TO_DATE(p_pg_startdate,'dd/mm/yyyy')
           ,p_event_group_id         => l_event_group_id
           ,p_dated_table_id         => l_dated_table_id
           ,p_update_type            => 'U'
           ,p_column_name            => 'VALUE'
           ,p_business_group_id      => l_business_group_id
           ,p_legislation_code       => NULL
           ,p_datetracked_event_id   => l_dt_event_id
           ,p_object_version_number  => l_ovn
            ) ;
        END IF;
    END IF;
--*********************************************************
-- Change in Salary
-- Termination of an employee
-- New Hire
-- Start/Change/End of earning
-- Start/Change/End of deduction
--********************************************************

    IF (UPPER(p_pgchgsal )   = 'YES' OR
        UPPER(p_pgtermemp)   = 'YES' OR
        UPPER(p_pgnewhre )   = 'YES' OR
        UPPER(p_pgstchenea)  = 'YES' OR
        UPPER(p_pgstchended) = 'YES'   ) THEN
        hr_utility.trace('If condition ... p_pgchgsal p_pgtermemp p_pgnewhre p_pgstchenea p_pgstchended');

        l_salary_flag := 'TRUE';

        FOR c2 IN c_dated_pay_table ('PAY_ELEMENT_ENTRIES_F')
        LOOP
            l_dated_table_id := c2.dated_table_id;
        END LOOP;

        l_count := 0;

        SELECT COUNT(*)
        INTO   l_count
        FROM   pay_datetracked_events
        WHERE  column_name            = 'EFFECTIVE_START_DATE'
        AND    event_group_id         = l_event_group_id
        AND    dated_table_id         = l_dated_table_id ;

        IF (l_count = 0) THEN
            hr_utility.trace('If condition ... creating datetracked event');
            pay_datetracked_events_api.create_datetracked_event
            (
              p_validate               => FALSE
             ,p_effective_date         => TO_DATE(p_pg_startdate,'dd/mm/yyyy')
             ,p_event_group_id         => l_event_group_id
             ,p_dated_table_id         => l_dated_table_id
                                               -- of pay_element_entries_f
             ,p_update_type            => 'U'
             ,p_column_name            => 'EFFECTIVE_START_DATE'
             ,p_business_group_id      => l_business_group_id
             ,p_legislation_code       => NULL
             ,p_datetracked_event_id   => l_dt_event_id
             ,p_object_version_number  => l_ovn
            ) ;
        END IF;

        l_count := 0;

        SELECT COUNT(*)
        INTO   l_count
        FROM   pay_datetracked_events
        WHERE  column_name            = 'EFFECTIVE_END_DATE'
        AND    event_group_id         = l_event_group_id
        AND    dated_table_id         = l_dated_table_id;

        IF (l_count = 0) THEN
            hr_utility.trace('If condition ... creating datetracked event');
            pay_datetracked_events_api.create_datetracked_event
            (
                p_validate                => FALSE
               ,p_effective_date          =>
                                           TO_DATE(p_pg_startdate,'dd/mm/yyyy')
               ,p_event_group_id          => l_event_group_id
               ,p_dated_table_id          => l_dated_table_id
                                              --  of pay_element_entries_f
               ,p_update_type             => 'U'
               ,p_column_name             => 'EFFECTIVE_END_DATE'
               ,p_business_group_id       => l_business_group_id
               ,p_legislation_code        => NULL
               ,p_datetracked_event_id    => l_dt_event_id
               ,p_object_version_number   => l_ovn );
        END IF;
    END IF;

-- Change of location

    IF ( UPPER(p_pgchgloc) = 'YES' ) THEN
        hr_utility.trace('If condition ... p_pgchgloc');
        l_location_flag := 'TRUE';

        FOR c2 IN c_dated_pay_table ('PER_ALL_ASSIGNMENTS_F')
        LOOP
            l_dated_table_id := c2.dated_table_id;
        END LOOP;
        l_count := 0;

        SELECT COUNT(*)
        INTO   l_count
        FROM   pay_datetracked_events
        WHERE  column_name            = 'LOCATION_ID'
        AND    event_group_id         = l_event_group_id
        AND    dated_table_id         = l_dated_table_id ;

        IF (l_count = 0) THEN
            hr_utility.trace('If condition ... creating datetracked event');

            pay_datetracked_events_api.create_datetracked_event
        (
            p_validate               => FALSE
           ,p_effective_date         => TO_DATE(p_pg_startdate,'dd/mm/yyyy')
           ,p_event_group_id         => l_event_group_id
           ,p_dated_table_id         => l_dated_table_id
                                          -- PER_ALL_ASSIGNMENTS_F
           ,p_update_type            => 'U'
           ,p_column_name            => 'LOCATION_ID'
           ,p_business_group_id      => l_business_group_id
           ,p_legislation_code       => NULL
           ,p_datetracked_event_id   => l_dt_event_id
           ,p_object_version_number  => l_ovn
        ) ;
        END IF;
    END IF;
    hr_utility.trace('Enable Dynamic Trigger');

    enable_dynamic_triggers
    (
        p_business_group_id => l_business_group_id ,
        p_salary_flag       => l_salary_flag       ,
        p_grade_flag        => l_grade_flag        ,
        p_spinal_flag       => l_payscale_flag     ,
        p_address_flag      => l_address_flag      ,
        p_location_flag     => l_location_flag
    );
    hr_utility.set_location('Leaving }'|| gv_package || lv_procedure_name, 250);
END proration_group_proc;
--*************************************************************************
--Procedure : Element_proc
--*************************************************************************
PROCEDURE element_proc
(
    p_ele_startdate       IN VARCHAR2   DEFAULT NULL,
    p_business_group      IN VARCHAR2   DEFAULT NULL,
    p_ele_name            IN VARCHAR2   DEFAULT NULL,
    p_ele_desc            IN VARCHAR2   DEFAULT NULL,
    p_ele_terminate       IN VARCHAR2   DEFAULT NULL,
    p_ele_uenterable      IN VARCHAR2   DEFAULT NULL,
    p_ele_addentry        IN VARCHAR2   DEFAULT NULL,
    p_ele_payment         IN VARCHAR2   DEFAULT NULL,
    p_ele_recur           IN VARCHAR2   DEFAULT NULL,
    p_ele_priclass        IN VARCHAR2   DEFAULT NULL,
    p_ele_multientry      IN VARCHAR2   DEFAULT NULL,
    p_ele_repname         IN VARCHAR2   DEFAULT NULL,
    p_ele_pg              IN VARCHAR2   DEFAULT NULL,
    p_ele_teach_eng       IN VARCHAR2   DEFAULT NULL,
    p_ele_teach_scot      IN VARCHAR2   DEFAULT NULL,
    p_ele_extra_td        IN VARCHAR2   DEFAULT NULL,
    p_ele_extra_psv       IN VARCHAR2   DEFAULT NULL,
    p_ele_extra_qualifier IN VARCHAR2   DEFAULT NULL,
    p_ele_extra_fte       IN VARCHAR2   DEFAULT NULL,
    p_ele_extra_sh        IN VARCHAR2   DEFAULT NULL
)
AS
    l_count               NUMBER;
    l_pg_id               NUMBER;
    l_ele_id              NUMBER;
    l_ipv_as              NUMBER;
    l_primary_class_name  pay_element_classifications.classification_name%TYPE;
    l_default_priority    NUMBER;
    l_etei_id             NUMBER;
    l_etei_ovn            NUMBER;

    l_pg_name             VARCHAR2(40);
    l_business_group_name VARCHAR2(80);
    lv_procedure_name     VARCHAR2(250) := '.element_proc';
BEGIN
    hr_utility.set_location('Entering {'|| gv_package || lv_procedure_name, 10);
    l_count := 0;

    l_business_group_name := p_business_group;

    SELECT COUNT(*)
    INTO   l_count
    FROM   pay_element_types_f
    WHERE  UPPER(element_name) = UPPER(LTRIM(RTRIM(p_ele_name)));

    hr_utility.trace('The count is ' || TO_CHAR(l_count) );

    IF (l_count = 0) THEN
        hr_utility.trace('If condition ' );

        l_pg_name := UPPER(SUBSTR(REPLACE(p_ele_pg, ' ',' '), 1, 40));

--        SELECT event_group_id
--        INTO   l_pg_id
--        FROM   pay_event_groups
--        WHERE  UPPER(event_group_name) = l_pg_name;

        FOR cegid IN c_event_group_id (l_pg_name)
        LOOP
            l_pg_id := cegid.event_group_id;
        END LOOP;
        l_primary_class_name  := p_ele_priclass;

        IF (l_primary_class_name = 'Pre-tax Deductions') THEN
            l_primary_class_name := 'Pre Tax Deductions' ;
        END IF;
        FOR c_pc IN c_primary_classification(l_primary_class_name)
        LOOP
            l_default_priority := c_pc.default_priority;
        END LOOP;

        hr_utility.trace('Creating element ' );

        l_ele_id := pay_db_pay_setup.create_element(
            p_element_name           => LTRIM(RTRIM(p_ele_name))
           ,p_description            => p_ele_desc
           ,p_reporting_name         => p_ele_repname
           ,p_classification_name    => l_primary_class_name
           ,p_post_termination_rule  => p_ele_terminate
           ,p_processing_type        => p_ele_recur
           ,p_processing_priority    => l_default_priority
           ,p_standard_link_flag     => 'N'
           ,p_business_group_name    => p_business_group
           ,p_legislation_code       => NULL
           ,p_effective_start_date   =>
                                 TO_DATE(p_ele_startdate,'dd/mm/yyyy')
           ,p_effective_end_date     => TO_DATE('31/12/4712','dd/mm/yyyy')
           ,p_mult_entries_allowed   => p_ele_multientry
           ,p_add_entry_allowed_flag => p_ele_addentry
           ,p_proration_group_id     => l_pg_id);


        IF (p_ele_teach_eng = 'YES' AND p_ele_payment = 'S') THEN
                l_ipv_as := NULL;

            hr_utility.trace('If condition ... before creating input value ' );

            FOR c_iv IN c_input_value(l_ele_id, 'Amount')
            LOOP
                l_ipv_as := c_iv.input_value_id;
            END LOOP;

            IF (l_ipv_as IS NULL) THEN

                hr_utility.trace('If condition ... Creating input value ');

                l_ipv_as := pay_db_pay_setup.create_input_value(
                p_element_name         => p_ele_name
                ,p_name                 => 'Amount'
                ,p_uom_code             => 'M'
                ,p_mandatory_flag       => 'X'
                ,p_display_sequence     => 2
                ,p_business_group_name  => l_business_group_name
                ,p_effective_start_date =>
                                        TO_DATE(p_ele_startdate,'dd/mm/yyyy')
                ,p_effective_end_date   => TO_DATE('31/12/4712','DD/MM/YYYY')
                ,p_legislation_code     => NULL);
            END IF;
        END IF;
    ELSE
        hr_utility.trace('Element ' || p_ele_name || ' already exists.');
    END IF;

    IF (p_ele_extra_qualifier IS NOT NULL) THEN
        IF (l_count <> 0) THEN
            FOR ceti IN c_element_id(p_ele_name)
            LOOP
                l_ele_id := ceti.element_type_id;
            END LOOP;
        END IF;
        l_count := 0;

        FOR cetei IN c_element_extra_info_cnt(l_ele_id)
        LOOP
            l_count := cetei.count;
        END LOOP;
        IF (l_count = 0) THEN

            hr_utility.trace('If condition ... Creating element extra info' );

            pay_db_pay_setup.set_session_date(trunc(sysdate));
            pay_element_extra_info_api.create_element_extra_info
                ( p_element_type_id           => l_ele_id
                 ,p_information_type          => 'PQP_UK_ELEMENT_ATTRIBUTION'
                 ,p_eei_information_category  => 'PQP_UK_ELEMENT_ATTRIBUTION'
                 ,p_eei_information1          => NVL(p_ele_extra_td, 'H')
                                         -- For Hourly Time Dimension
                 ,p_eei_information2          => p_ele_extra_psv
                                         -- Spinal Points Pay Source Value
                 ,p_eei_information3          =>  p_ele_extra_qualifier
                 ,p_eei_information4          => NVL(p_ele_extra_fte, 'N')
                                         -- No FTE
                 ,p_eei_information5          => NVL(p_ele_extra_sh, 'N')
                 ,p_element_type_extra_info_id => l_etei_id
                 ,p_object_version_number      => l_etei_ovn
                                         -- 'No' Service History */
                );
        ELSE
            hr_utility.trace('Else condition..updating element extra info');
            pay_db_pay_setup.set_session_date(trunc(sysdate));
            l_etei_id  := NULL;
            l_etei_ovn := NULL;
            FOR cetei1 IN c_element_extra_info_id(l_ele_id)
            LOOP
                l_etei_id  := cetei1.element_type_extra_info_id;
                l_etei_ovn := cetei1.object_version_number;
            END LOOP;

            pay_element_extra_info_api.update_element_extra_info
                (p_element_type_extra_info_id => l_etei_id
                 ,p_object_version_number      => l_etei_ovn
                 ,p_eei_information_category  => 'PQP_UK_ELEMENT_ATTRIBUTION'
                 ,p_eei_information1          => NVL(p_ele_extra_td, 'H')
                                         -- For Hourly Time Dimension
                 ,p_eei_information2          => p_ele_extra_psv
                                         -- Spinal Points Pay Source Value
                 ,p_eei_information3          =>  p_ele_extra_qualifier
                 ,p_eei_information4          => NVL(p_ele_extra_fte, 'N')
                                         -- No FTE
                 ,p_eei_information5          => NVL(p_ele_extra_sh, 'N')
                                -- 'No' Service History
                );
        END IF;
    END IF;
    hr_utility.set_location('Leaving }'|| gv_package || lv_procedure_name, 200);
END element_proc;
-- *************************************************************************
-- Procedure : Input_Value_proc
-- ***************************************************************************
PROCEDURE input_value_proc
(
    p_ipvalue_name        IN VARCHAR2   DEFAULT NULL,
    p_ipvalue_uom         IN VARCHAR2   DEFAULT NULL,
    p_ipvalue_required    IN VARCHAR2   DEFAULT NULL,
    p_ipvalue_uenterble   IN VARCHAR2   DEFAULT NULL,
    p_ipvalue_dfltval     IN VARCHAR2   DEFAULT NULL,
    p_ipvalue_lkpval      IN VARCHAR2   DEFAULT NULL,
    p_ipvalue_hotdflt     IN VARCHAR2   DEFAULT NULL,
    p_ipvalue_formula     IN VARCHAR2   DEFAULT NULL,
    p_ipvalue_minimum     IN VARCHAR2   DEFAULT NULL,
    p_ipvalue_maximum     IN VARCHAR2   DEFAULT NULL,
    p_ipvalue_error       IN VARCHAR2   DEFAULT NULL,
    p_ipvalue_dispseq     IN VARCHAR2   DEFAULT NULL,
    p_ipvalue_dbitem      IN VARCHAR2   DEFAULT NULL,
    p_business_group_ipv  IN VARCHAR2   DEFAULT NULL,
    p_ipvalue_startdate   IN VARCHAR2   DEFAULT NULL,
    p_ele_name_ipv        IN VARCHAR2   DEFAULT NULL
)
IS
    l_ele_id     NUMBER;
    l_ipv_as     NUMBER;
    l_formula_id NUMBER;
    l_business_group_name VARCHAR2(80);
    lv_procedure_name     VARCHAR2(80) := '.input_value_proc';
BEGIN
    hr_utility.set_location('Entering {'|| gv_package || lv_procedure_name, 10);
    FOR ceti IN c_element_id(p_ele_name_ipv)
    LOOP
        l_ele_id := ceti.element_type_id;
    END LOOP;

    l_business_group_name := p_business_group_ipv;

    FOR civ1 IN c_input_value(l_ele_id      ,
                              p_ipvalue_name)
    LOOP
        l_ipv_as := civ1.input_value_id;
    END LOOP;

    IF (l_ipv_as IS NULL) THEN
        hr_utility.trace('If condition...');
        FOR cfi IN c_formula_id (p_ipvalue_formula)
        LOOP
            l_formula_id  := cfi.formula_id;
        END LOOP;
        hr_utility.trace('Creating input value');
        l_ipv_as := pay_db_pay_setup.create_input_value(
              p_element_name          => LTRIM(RTRIM(p_ele_name_ipv))
              ,p_name                 => SUBSTR(LTRIM(RTRIM(p_ipvalue_name)),
                                                                         1, 80)
              ,p_uom_code              => p_ipvalue_uom
              ,p_mandatory_flag        => p_ipvalue_required
              ,p_display_sequence      => p_ipvalue_dispseq
              ,p_business_group_name   => l_business_group_name
              ,p_effective_start_date  =>
                                      TO_DATE(p_ipvalue_startdate,'dd/mm/yyyy')
              ,p_effective_end_date    => TO_DATE('31/12/4712','DD/MM/YYYY')
              ,p_legislation_code      => NULL
              ,p_min_value             => p_ipvalue_minimum
              ,p_max_value             => p_ipvalue_maximum
              ,p_default_value         => p_ipvalue_dfltval
              ,p_lookup_type           => p_ipvalue_lkpval
              ,p_formula_id            => l_formula_id
              ,p_hot_default_flag      => p_ipvalue_hotdflt
              ,p_generate_db_item_flag => p_ipvalue_dbitem );
    ELSE
        hr_utility.trace('Input Value ' || p_ele_name_ipv ||' already exists.');
    END IF;
    hr_utility.set_location('Leaving }'|| gv_package || lv_procedure_name, 10);
END input_value_proc;
--*************************************************************************
--Procedure  Formula_proc
--****************************************************************************/
PROCEDURE formula_proc
(
    p_business_group_fr  IN VARCHAR2   DEFAULT NULL,
    p_ele_name_fr        IN VARCHAR2   DEFAULT NULL,
    p_ele_payment_fr     IN VARCHAR2   DEFAULT NULL,
    p_ele_startdate_fr   IN VARCHAR2   DEFAULT NULL,
    p_ele_teach_eng_fr   IN VARCHAR2   DEFAULT NULL,
    p_ele_teach_scot_fr  IN VARCHAR2   DEFAULT NULL,
    p_ele_priclass_fr    IN VARCHAR2   DEFAULT NULL
)
AS
   l_count                 NUMBER       ;
   l_formula_name          VARCHAR2(80) ;
   l_new_formula_name      VARCHAR2(80) ;
   l_formula_type_id       NUMBER       ;
   l_business_group_id     NUMBER       ;
   l_ele_id                NUMBER       ;
   l_status_proc_rule_id   NUMBER       ;
   l_for_res_id            NUMBER       ;
   l_formula_id            NUMBER       ;
   l_req_id                NUMBER       ;
   l_formula_text          LONG         ;
   l_description           VARCHAR2(50) ;
   l_business_group_name   VARCHAR2(80) ;
   l_result                VARCHAR2(80) ;
   lv_procedure_name       VARCHAR2(80) ;
BEGIN
    hr_utility.set_location('Entering {'|| gv_package || lv_procedure_name, 10);
    l_count := 0;
    l_business_group_name := p_business_group_fr;

    IF (UPPER(p_ele_priclass_fr) LIKE '%DEDUCTION%') THEN
        l_formula_name := 'UK_PRORATION_DEDUCTION';
        l_result       := 'L_AMOUNT';
    ELSIF  (p_ele_payment_fr = 'P') THEN
        l_formula_name := 'UK_PRORATION_SPINAL_POINT';
        l_result       := 'L_AMOUNT';
    ELSIF (p_ele_payment_fr = 'G') THEN
        l_formula_name := 'UK_PRORATION_GRADE_RATE';
        l_result       := 'L_AMOUNT';
    ELSIF (p_ele_teach_eng_fr = 'YES') THEN
        l_formula_name := 'UK_PRORATION_SAL_MANAGEMENT';
        l_result       := 'RESULT1';
    ELSIF (p_ele_payment_fr = 'S' OR p_ele_teach_scot_fr = 'YES') THEN
        l_formula_name := 'UK_PRORATION_ALLOWANCE';
        l_result       := 'L_AMOUNT';
    ELSE
        RETURN;
    END IF;

    l_new_formula_name :=
             SUBSTR(UPPER(REPLACE(p_ele_name_fr, ' ', '_') || '_FF'), 1, 80);

    SELECT COUNT(*)
    INTO   l_count
    FROM   ff_formulas_f
    WHERE  formula_name  = l_new_formula_name ;

    IF (l_count = 0) THEN

        SELECT formula_type_id
        INTO   l_formula_type_id
        FROM   ff_formula_types
        WHERE  formula_type_name = 'Oracle Payroll';

--        SELECT formula_text
--        INTO   l_formula_text
--        FROM   ff_formulas_f ff
--        WHERE  ff.formula_name       = l_formula_name
--        AND    ff.legislation_code   = 'GB'
--        AND    ff.business_group_id IS NULL;

        FOR cft IN c_formula_text (l_formula_name)
        LOOP
            l_formula_text := cft.formula_text;
        END LOOP;

        IF (l_formula_name = 'UK_PRORATION_SAL_MANAGEMENT') THEN
            l_formula_text :=REPLACE(l_formula_text, 'annual_salary', 'Amount');
            l_formula_text :=
                          REPLACE(l_formula_text, 'UK_PRORATION_SAL_MANAGEMENT',
                                        l_new_formula_name);
        END IF;
        IF (l_formula_name = 'UK_PRORATION_ALLOWANCE') THEN
                l_formula_text :=
                          REPLACE(l_formula_text, 'annual_allowance', 'Amount');
                l_formula_text :=
                          REPLACE(l_formula_text                 ,
                                        'UK_PRORATION_ALLOWANCE' ,
                                        l_new_formula_name       );
        END IF;
        IF (l_formula_name = 'UK_PRORATION_DEDUCTION') THEN
                l_formula_text :=
                          REPLACE(l_formula_text                 ,
                                        'UK_PRORATION_DEDUCTION' ,
                                        l_new_formula_name       );
        END IF;
        IF (l_formula_name = 'UK_PRORATION_SPINAL_POINT') THEN
                l_formula_text :=
                          REPLACE(l_formula_text                    ,
                                        'UK_PRORATION_SPINAL_POINT' ,
                                        l_new_formula_name          );
                l_formula_text := REPLACE(l_formula_text, 'UK Spinal Point',
                                      p_ele_name_fr );
        END IF;
        IF (l_formula_name = 'UK_PRORATION_GRADE_RATE') THEN
                l_formula_text :=
                          REPLACE(l_formula_text                  ,
                                        'UK_PRORATION_GRADE_RATE' ,
                                        l_new_formula_name        );
                l_formula_text := REPLACE(l_formula_text, 'UK Grade Rate',
                                         p_ele_name_fr );
        END IF;

        FOR c1 IN c_biz_group (l_business_group_name)
        LOOP
            l_business_group_id := c1.business_group_id;
        END LOOP;

        l_description  := 'Formula created for ' || p_ele_name_fr;

        INSERT INTO ff_formulas_f
            (formula_id            ,
             effective_start_date  ,
             effective_end_date    ,
             business_group_id    ,
             legislation_code      ,
             formula_type_id       ,
             formula_name          ,
             description           ,
             formula_text          ,
             last_update_date      ,
             last_updated_by       ,
             last_update_login     ,
             created_by            ,
             creation_date         )
        VALUES
             (ff_formulas_s.NEXTVAL                    , --  formula_id
              TO_DATE(p_ele_startdate_fr,'dd/mm/yyyy')  ,
                                                       --  effective_start_date
              TO_DATE('31/12/4712', 'DD/MM/YYYY')   , --  effective_end_date
              l_business_group_id                   , --  business_group_id
              NULL                                  , --  legislation_code
              l_formula_type_id                     , --  formula_type_id
              l_new_formula_name                        , --  formula_name
              l_description                         , --  description
              l_formula_text                        , --  formula_text
              SYSDATE                               , --  last_update_date
              -1                                    , --  last_updated_by
              -1                                    , --  last_update_login
              -1                                    , --  created_by
              SYSDATE                               ); --  creation_date

--        SELECT formula_id
--        INTO   l_formula_id
--        FROM   ff_formulas_f ff
--        WHERE  ff.formula_name       = l_new_formula_name
--        AND    ff.legislation_code   IS NULL
--        AND    ff.business_group_id  = l_business_group_id;
        FOR cffi IN c_fast_formula_id(l_new_formula_name,
                                      l_business_group_id)
        LOOP
            l_formula_id := cffi.formula_id;
        END LOOP;

        l_req_id := fnd_request.submit_request(
                            application    => 'FF'              ,
                            program        => 'BULKCOMPILE'     ,
                            argument1      => 'Oracle Payroll'  ,
                            argument2      => l_new_formula_name    );

--        SELECT element_type_id
--        INTO   l_ele_id
--        FROM   pay_element_types_f
--        WHERE  UPPER(element_name) = UPPER(LTRIM(RTRIM(p_ele_name_fr)));

        FOR ceti IN c_element_id(p_ele_name_fr)
        LOOP
            l_ele_id := ceti.element_type_id;
        END LOOP;

        l_status_proc_rule_id := pay_formula_results.ins_stat_proc_rule
           (
             p_business_group_id    => l_business_group_id
            ,p_legislation_code     => NULL
            ,p_effective_start_date => TO_DATE(p_ele_startdate_fr,'dd/mm/yyyy')
            ,p_element_type_id      => l_ele_id
            ,p_formula_id           => l_formula_id
            ,p_processing_rule      => 'P'
           );

        l_for_res_id := pay_formula_results.ins_form_res_rule
          (
            p_business_group_id         => l_business_group_id
           ,p_legislation_code          => NULL
           ,p_status_processing_rule_id => l_status_proc_rule_id
           ,p_result_name               => l_result
           ,p_element_type_id           => l_ele_id
           ,p_result_rule_type          => 'D'
           ,p_effective_start_date      =>
                              TO_DATE(p_ele_startdate_fr,'dd/mm/yyyy')
          );
    ELSE
        hr_utility.trace('Formula ' || l_new_formula_name ||' already exists.');
    END IF;
    hr_utility.set_location('Leaving }'|| gv_package || lv_procedure_name, 200);
END formula_proc;
--************************************************************************
--**************************************************************************
FUNCTION get_contract_type(p_assignment_id  IN NUMBER ,
                           p_effective_date IN DATE   ) RETURN VARCHAR
AS
CURSOR c_assignment_details(p_assignment_id  IN NUMBER ,
                            p_effective_date IN DATE   )  IS
    SELECT aat.contract_type
    FROM   pqp_assignment_attributes_f aat
    WHERE  aat.assignment_id = p_assignment_id
    AND    p_effective_date between aat.effective_start_date
                     AND aat.effective_end_date;
    l_contract_type VARCHAR2(100);
BEGIN
    FOR cad IN c_assignment_details(p_assignment_id,
                                    p_effective_date)
    LOOP
        l_contract_type := cad.contract_type;
    END LOOP;
    RETURN l_contract_type;
END;
END pqp_proration_wrapper;

/
