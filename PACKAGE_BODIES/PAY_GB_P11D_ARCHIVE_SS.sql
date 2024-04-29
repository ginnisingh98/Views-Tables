--------------------------------------------------------
--  DDL for Package Body PAY_GB_P11D_ARCHIVE_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_GB_P11D_ARCHIVE_SS" as
/* $Header: pygbpdss.pkb 120.41.12010000.8 2009/10/22 12:54:52 namgoyal ship $ */

   g_package            CONSTANT VARCHAR2(33) := 'PAY_GB_P11D_ARCHIVE_SS.';
   g_pactid                      NUMBER;
   g_application_id     CONSTANT NUMBER := 801;
   g_set_warning                 BOOLEAN := FALSE;
   g_param_payroll_id            NUMBER;
   g_param_person_id             NUMBER;
   g_param_consolidation_set_id  NUMBER;
   g_param_tax_reference         VARCHAR2(200);
   g_param_assignment_set_id     NUMBER;
   g_param_benefit_end_date      VARCHAR2(20);
   g_param_benefit_start_date    VARCHAR2(20);
   g_param_business_group_id     NUMBER;
   g_param_rep_run               varchar2(10);

   TYPE g_rec_val_ff IS RECORD(
      l_row_name                    VARCHAR2(80),
      l_row_effective_start_date    DATE,
      l_row_effective_end_date      DATE,
      l_val_effective_start_date    DATE,
      l_val_effective_end_date      DATE,
      l_value                       VARCHAR2(80),
      l_ff_formula_id               NUMBER(9),
      l_ff_effective_start_date     DATE,
      l_ff_effective_end_date       DATE);

   TYPE g_typ_val_ff_table IS TABLE OF g_rec_val_ff
      INDEX BY BINARY_INTEGER;

   g_val_ff_tab                  g_typ_val_ff_table;

   TYPE g_typ_rec_benefit_detail IS RECORD(
      assignment_action_id          NUMBER(15),
      element_type_id               NUMBER(9),
      element_entry_id              NUMBER(15),
      element_name                  VARCHAR2(80),
      effective_start_date          DATE,
      person_id                     NUMBER(10),
      assignment_id                 NUMBER(10),
      classification_name           VARCHAR2(83) );

   TYPE g_typ_tab_ben_detail IS TABLE OF g_typ_rec_benefit_detail
      INDEX BY BINARY_INTEGER;
/*
   TYPE g_typ_tab_ben_detail_tab IS TABLE OF g_typ_tab_ben_detail
      INDEX BY BINARY_INTEGER;
*/

   TYPE g_typ_non_iv_act_info_rec IS RECORD
       (element_type_id               NUMBER(9),
        input_value_name              varchar2(50) );

   TYPE g_typ_non_iv_act_info_items IS TABLE OF g_typ_non_iv_act_info_rec
      INDEX BY BINARY_INTEGER;

   TYPE g_typ_non_iv_index IS TABLE OF Number
      INDEX BY BINARY_INTEGER;

/*
   TYPE g_typ_ele_extra_act_info_items IS TABLE OF g_typ_non_iv_act_info_items
      INDEX BY BINARY_INTEGER;
*/

   l_non_iv_act_info_items      g_typ_non_iv_act_info_items;
   l_non_iv_index               g_typ_non_iv_index;

--   l_extra_act_info_items       g_typ_ele_extra_act_info_items;

   g_tab_ben_detail              g_typ_tab_ben_detail;
   c_tab_ben_detail              g_typ_tab_ben_detail; -- this is the null table
--   g_tab_ben_detail_tab          g_typ_tab_ben_detail_tab;
   g_ben_asg_count               NUMBER := 0;


--   l_ben_asg_det_table l_typ_ben_asg_det_table;

   TYPE g_typ_assign_sum_info_rec IS RECORD(
      a_desc                        VARCHAR2(150),
      a_cost                        NUMBER,
      a_amg                         NUMBER,
      a_ce                          NUMBER,
      b_desc                        VARCHAR2(150),
      b_ce                          NUMBER,
      b_tnp                         NUMBER,
      c_cost                        NUMBER,
      c_amg                         NUMBER,
      c_ce                          NUMBER,
      d_ce                          NUMBER,
      e_ce                          NUMBER,
      f_tcce                        NUMBER,
      f_tfce                        NUMBER,
      g_ce                          NUMBER,
      g_fce                         NUMBER,
      i_cost                        NUMBER,
      i_amg                         NUMBER,
      i_ce                          NUMBER,
      j_ce                          NUMBER,
      k_cost                        NUMBER,
      k_amg                         NUMBER,
      k_ce                          NUMBER,
      l_desc                        VARCHAR2(150),
      l_cost                        NUMBER,
      l_amg                         NUMBER,
      l_ce                          NUMBER,
      m_shares                      VARCHAR2(150),
      h_ce1                         NUMBER,
      h_count                       NUMBER,
      f_count                       NUMBER,
      n_desc                        VARCHAR2(150),
      n_cost                        NUMBER,
      n_amg                         NUMBER,
      n_ce                          NUMBER,
      na_desc                       VARCHAR2(150),
      na_cost                       NUMBER,
      na_amg                        NUMBER,
      na_ce                         NUMBER,
      n_taxpaid                     NUMBER,
      o1_cost                       NUMBER,
      o1_amg                        NUMBER,
      o1_ce                         NUMBER,
      o2_cost                       NUMBER,
      o2_amg                        NUMBER,
      o2_ce                         NUMBER,
      o_toi                         VARCHAR2(150),
      o3_cost                       NUMBER,
      o3_amg                        NUMBER,
      o3_ce                         NUMBER,
      o4_cost                       NUMBER,
      o4_amg                        NUMBER,
      o4_ce                         NUMBER,
      o5_cost                       NUMBER,
      o5_amg                        NUMBER,
      o5_ce                         NUMBER,
      o6_desc                       VARCHAR2(150),
      o6_cost                       NUMBER,
      o6_amg                        NUMBER,
      o6_ce                         NUMBER);

   g_assign_sum_info_rec         g_typ_assign_sum_info_rec;
   c_assign_sum_info_null_rec    g_typ_assign_sum_info_rec;

   CURSOR csr_payroll_info(v_benefit_end_date VARCHAR2, v_payroll_id NUMBER)
   IS
      SELECT org.org_information1 employers_ref_no, org.org_information2 tax_office_name,
             org.org_information8 tax_office_phone_no, org.org_information3 employer_name,
             org.org_information4 employer_address
        FROM pay_payrolls_f ppf, hr_soft_coding_keyflex flex, hr_organization_information org
       WHERE ppf.soft_coding_keyflex_id = flex.soft_coding_keyflex_id
             AND fnd_date.canonical_to_date(v_benefit_end_date)
                    BETWEEN NVL(flex.start_date_active, fnd_date.canonical_to_date(v_benefit_end_date) )
                        AND NVL(flex.end_date_active, fnd_date.canonical_to_date(v_benefit_end_date) )
             AND fnd_date.canonical_to_date(v_benefit_end_date)
                    BETWEEN NVL(ppf.effective_start_date, fnd_date.canonical_to_date(v_benefit_end_date) )
                        AND NVL(ppf.effective_end_date, fnd_date.canonical_to_date(v_benefit_end_date) )
             AND ppf.business_group_id = org.organization_id AND org.org_information1 = flex.segment1
             AND org.org_information_context = 'Tax Details References' AND ppf.payroll_id = v_payroll_id;

   PROCEDURE get_parameters(p_payroll_action_id IN NUMBER, p_token_name IN VARCHAR2, p_token_value OUT NOCOPY VARCHAR2)
   IS
      CURSOR csr_parameter_info(p_pact_id NUMBER, p_token CHAR)
      IS
         SELECT SUBSTR(
                   legislative_parameters,
                   INSTR(legislative_parameters, p_token) + (LENGTH(p_token) + 1),
                   (DECODE(
                       INSTR(legislative_parameters, ' ', INSTR(legislative_parameters, p_token) ),
                       0, DECODE(INSTR(legislative_parameters, p_token), 0, .5, LENGTH(legislative_parameters) ),
                       INSTR(legislative_parameters, ' ', INSTR(legislative_parameters, p_token) )
                       - (INSTR(legislative_parameters, p_token) + (LENGTH(p_token) + 1) ) ) ) ),
                business_group_id, start_date, effective_date -- this will be the benefit end date
           FROM pay_payroll_actions
          WHERE payroll_action_id = p_pact_id;

      l_business_group_id           VARCHAR2(20);
      l_benefit_start_date          VARCHAR2(20);
      l_benefit_end_date            VARCHAR2(20);
      l_token_value                 VARCHAR2(50);
      l_proc                        VARCHAR2(50) := g_package || 'get_parameters';
   BEGIN
      hr_utility.set_location('Entering '|| l_proc, 10);
      hr_utility.set_location('Step '|| l_proc, 20);
      hr_utility.set_location('p_token_name = '|| p_token_name, 20);
      OPEN csr_parameter_info(p_payroll_action_id, p_token_name);
      FETCH csr_parameter_info INTO l_token_value, l_business_group_id, l_benefit_start_date, l_benefit_end_date;
      CLOSE csr_parameter_info;

      IF p_token_name = 'BG_ID'
      THEN
         p_token_value := l_business_group_id;
      ELSIF p_token_name = 'BENEFIT_START_DATE'
      THEN
         p_token_value := fnd_date.date_to_canonical(l_benefit_start_date);
      ELSIF p_token_name = 'BENEFIT_END_DATE'
      THEN
         p_token_value := fnd_date.date_to_canonical(l_benefit_end_date);
      ELSE
         p_token_value := l_token_value;
      END IF;

      hr_utility.set_location('p_token_value = '|| p_token_value, 60);
      hr_utility.set_location('Leaving         '|| l_proc, 70);
   END get_parameters;

   FUNCTION check_assignment_tax_ref(p_assignment_id number,
                                     p_tax_ref       varchar2,
                                     p_end_date      varchar2) return boolean is
        l_ret boolean;
        l_check number;
        cursor csr_check_asg is
        select 1
        from   per_all_assignments_f asg,
               pay_all_payrolls_f    pay,
               hr_soft_coding_keyflex flex
        where  asg.assignment_id = p_assignment_id
        and    asg.payroll_id = pay.payroll_id
        and    pay.soft_coding_keyflex_id + 0 = flex.soft_coding_keyflex_id
        and    (p_tax_ref is null
                 or
                flex.segment1 = p_tax_ref)
        and    (fnd_date.canonical_to_date(p_end_date) between asg.effective_start_date and asg.effective_end_date
                or
                  (    asg.effective_end_date = (select max(paa2.effective_end_date)
                                                 from per_assignments_f paa2
                                                 where paa2.assignment_id = p_assignment_id)
                   and asg.effective_end_date < fnd_date.canonical_to_date(p_end_date)));
   BEGIN
        l_ret := false;
        open csr_check_asg;
        fetch csr_check_asg into l_check;
        if csr_check_asg%FOUND then
           l_ret := true;
        end if;
        close csr_check_asg;
        return l_ret;
   END;

   FUNCTION find_exec_formula(
      p_element_name                      VARCHAR2,
      p_effective_date                    DATE,
      p_formula_effective_start_date OUT NOCOPY DATE)
      RETURN NUMBER
   IS
      l_counter                     INTEGER := 0;
      l_search_from                 INTEGER := 0;

      FUNCTION find_first_entry
         RETURN INTEGER
      IS
         l_lower                       INTEGER;
         l_upper                       INTEGER;
         l_check_item                  INTEGER;
         l_first_matching_item         INTEGER := 0;
         l_match                       BOOLEAN := FALSE;
      BEGIN
         l_lower := 1;
         l_upper := g_val_ff_tab.COUNT;

         FOR counter IN l_lower .. l_upper
         LOOP
            l_check_item := FLOOR( (l_lower + l_upper) / 2);

            IF g_val_ff_tab(l_check_item).l_row_name = p_element_name
            THEN
               l_match := TRUE;
               hr_utility.TRACE('.. MATCHED..');
               EXIT;
            ELSIF p_element_name < g_val_ff_tab(l_check_item).l_row_name
            THEN
               -- search below this
               l_upper := l_check_item - 1;
            ELSE
               l_lower := l_check_item + 1;
            END IF;
         END LOOP;

         IF l_match
         THEN
            -- it returned the first match, due ti dat effective rows
            -- there could be rows for same name before the matched row
            -- we need to find them
            IF l_check_item = 1
            THEN
               l_first_matching_item := l_check_item;
            ELSE
               FOR counter IN REVERSE 1 .. l_check_item
               LOOP
                  IF g_val_ff_tab(counter).l_row_name = p_element_name
                  THEN
                     -- item matches and counter is 1 menaing the first item
                     IF counter = 1
                     THEN
                        l_first_matching_item := counter;
                     END IF;
                  ELSE -- item does not match meaning the match first is counter +1
                     l_first_matching_item := counter + 1;
                     EXIT;
                  END IF;
               END LOOP;
            END IF;
         END IF;

         hr_utility.TRACE(' Returning l_first_matching_item '|| l_first_matching_item);
         RETURN l_first_matching_item;
      END;
   BEGIN
      hr_utility.TRACE('inside find_exec_formula');
      hr_utility.TRACE('g_val_ff_tab.count '|| g_val_ff_tab.COUNT);
      hr_utility.TRACE('p_element_name '|| p_element_name);
      hr_utility.TRACE('p_element_name '|| p_element_name);
      hr_utility.TRACE('p_effective_date '|| TO_DATE(p_effective_date, 'DD/MM/YYYY') );
      l_search_from := find_first_entry;

      IF l_search_from <> 0
      THEN
         hr_utility.TRACE('l_search_from '|| l_search_from);

         FOR l_counter IN l_search_from .. g_val_ff_tab.COUNT
         LOOP
            hr_utility.TRACE(
               'g_val_ff_tab(l_counter).l_row_effective_start_date '
               || TO_DATE(g_val_ff_tab(l_counter).l_row_effective_start_date, 'DD/MM/YYYY') );
            hr_utility.TRACE(
               'g_val_ff_tab(l_counter).l_row_effective_end_date '
               || TO_DATE(g_val_ff_tab(l_counter).l_row_effective_end_date, 'DD/MM/YYYY') );
            hr_utility.TRACE(
               'l_val_effective_start_date '|| TO_DATE(
                                                  g_val_ff_tab(l_counter).l_val_effective_start_date,
                                                  'DD/MM/YYYY') );
            hr_utility.TRACE(
               'g_val_ff_tab(l_counter).l_val_effective_end_date '
               || TO_DATE(g_val_ff_tab(l_counter).l_val_effective_end_date, 'DD/MM/YYYY') );
            hr_utility.TRACE(
               'l_ff_effective_start_date '|| TO_DATE(g_val_ff_tab(l_counter).l_ff_effective_start_date, 'DD/MM/YYYY') );
            hr_utility.TRACE(
               'l_ff_effective_end_date '|| TO_DATE(g_val_ff_tab(l_counter).l_ff_effective_end_date, 'DD/MM/YYYY') );

            IF  g_val_ff_tab(l_counter).l_row_name = p_element_name
                AND p_effective_date BETWEEN g_val_ff_tab(l_counter).l_row_effective_start_date
                                         AND g_val_ff_tab(l_counter).l_row_effective_end_date
                AND p_effective_date BETWEEN g_val_ff_tab(l_counter).l_val_effective_start_date
                                         AND g_val_ff_tab(l_counter).l_val_effective_end_date
                AND p_effective_date BETWEEN g_val_ff_tab(l_counter).l_ff_effective_start_date
                                         AND g_val_ff_tab(l_counter).l_ff_effective_end_date
            THEN
               p_formula_effective_start_date := g_val_ff_tab(l_counter).l_ff_effective_start_date;
               RETURN g_val_ff_tab(l_counter).l_ff_formula_id;
            END IF;
         END LOOP;
      ELSE
         RETURN NULL;
      END IF;
   END;

   PROCEDURE archinit(p_payroll_action_id IN NUMBER)
   IS
      l_proc               CONSTANT VARCHAR2(50) := g_package || ' archinit';
      l_table_id                    pay_user_tables.user_table_id%TYPE;

      FUNCTION fetch_validation_table_id(p_table_name VARCHAR2)
         RETURN NUMBER
      IS
         l_table_id                    pay_user_tables.user_table_id%TYPE;
      BEGIN
         SELECT user_table_id
           INTO l_table_id
           FROM pay_user_tables
          WHERE UPPER(user_table_name) = UPPER(p_table_name) AND business_group_id IS NULL AND legislation_code = 'GB';

         RETURN l_table_id;
      END;

      PROCEDURE populate_table_value(p_bus_group_id NUMBER, p_table_id NUMBER, p_col_name VARCHAR2)
      IS
         CURSOR populate_user_table
         IS
            SELECT   r.row_low_range_or_name NAME, r.effective_start_date row_start_date,
                     r.effective_end_date row_end_date, cinst.effective_start_date col_inst_start_date,
                     cinst.effective_end_date col_inst_end_date, cinst.VALUE VALUE, ff.formula_id formula_id,
                     ff.effective_start_date ff_start_date, ff.effective_end_date ff_end_date
                FROM pay_user_column_instances_f cinst,
                     pay_user_columns c,
                     pay_user_rows_f r,
                     pay_user_tables tab,
                     ff_formulas_f ff
               WHERE tab.user_table_id = p_table_id AND c.user_table_id = tab.user_table_id
                     AND NVL(c.business_group_id, p_bus_group_id) = p_bus_group_id AND NVL(c.legislation_code, 'GB') =
                                                                                                                   'GB'
                     AND UPPER(c.user_column_name) = UPPER(p_col_name) AND cinst.user_column_id = c.user_column_id
                     AND r.user_table_id = tab.user_table_id

--        and     l_effective_date           between R.effective_start_date        and     R.effective_end_date
                     AND NVL(r.business_group_id, p_bus_group_id) = p_bus_group_id AND NVL(r.legislation_code, 'GB') =
                                                                                                                   'GB'
                     AND cinst.user_row_id = r.user_row_id

--        and     l_effective_date           between CINST.effective_start_date        and     CINST.effective_end_date
                     AND NVL(cinst.business_group_id, p_bus_group_id) = p_bus_group_id
                     AND NVL(cinst.legislation_code, 'GB') = 'GB' AND formula_name = cinst.VALUE
            ORDER BY r.row_low_range_or_name,
                     r.effective_start_date,
                     r.effective_end_date,
                     cinst.effective_start_date,
                     cinst.effective_end_date,
                     ff.effective_start_date,
                     ff.effective_end_date;

         l_count                       INTEGER := 0;
      BEGIN
         FOR get_all_ffs IN populate_user_table
         LOOP
            l_count := l_count + 1;
            g_val_ff_tab(l_count).l_row_name := get_all_ffs.NAME;
            g_val_ff_tab(l_count).l_row_effective_start_date := get_all_ffs.row_start_date;
            g_val_ff_tab(l_count).l_row_effective_end_date := get_all_ffs.row_end_date;
            g_val_ff_tab(l_count).l_val_effective_start_date := get_all_ffs.col_inst_start_date;
            g_val_ff_tab(l_count).l_val_effective_end_date := get_all_ffs.col_inst_end_date;
            g_val_ff_tab(l_count).l_value := get_all_ffs.VALUE;
            g_val_ff_tab(l_count).l_ff_formula_id := get_all_ffs.formula_id;
            g_val_ff_tab(l_count).l_ff_effective_start_date := get_all_ffs.ff_start_date;
            g_val_ff_tab(l_count).l_ff_effective_end_date := get_all_ffs.ff_end_date;
         END LOOP;
      END;
   BEGIN

--       --  hr_utility.trace_on(null,'ARCH');
      hr_utility.set_location('Entering '|| l_proc, 10);
      g_pactid := p_payroll_action_id;
      PAY_GB_P11D_ARCHIVE_SS.get_parameters(
         p_payroll_action_id           => p_payroll_action_id,
         p_token_name                  => 'PAYROLL',
         p_token_value                 => g_param_payroll_id);
      PAY_GB_P11D_ARCHIVE_SS.get_parameters(
         p_payroll_action_id           => p_payroll_action_id,
         p_token_name                  => 'PERSON',
         p_token_value                 => g_param_person_id);
      PAY_GB_P11D_ARCHIVE_SS.get_parameters(
         p_payroll_action_id           => p_payroll_action_id,
         p_token_name                  => 'CONSOLIDATION_SET',
         p_token_value                 => g_param_consolidation_set_id);
      PAY_GB_P11D_ARCHIVE_SS.get_parameters(
         p_payroll_action_id           => p_payroll_action_id,
         p_token_name                  => 'TAX_REFERENCE',
         p_token_value                 => g_param_tax_reference);
      PAY_GB_P11D_ARCHIVE_SS.get_parameters(
         p_payroll_action_id           => p_payroll_action_id,
         p_token_name                  => 'ASSIGNMENT_SET_ID',
         p_token_value                 => g_param_assignment_set_id);
      PAY_GB_P11D_ARCHIVE_SS.get_parameters(
         p_payroll_action_id           => p_payroll_action_id,
         p_token_name                  => 'BG_ID',
         p_token_value                 => g_param_business_group_id);
      PAY_GB_P11D_ARCHIVE_SS.get_parameters(
         p_payroll_action_id           => p_payroll_action_id,
         p_token_name                  => 'BENEFIT_START_DATE',
         p_token_value                 => g_param_benefit_start_date);
      PAY_GB_P11D_ARCHIVE_SS.get_parameters(
         p_payroll_action_id           => p_payroll_action_id,
         p_token_name                  => 'BENEFIT_END_DATE',
         p_token_value                 => g_param_benefit_end_date);

      PAY_GB_P11D_ARCHIVE_SS.get_parameters(
         p_payroll_action_id           => p_payroll_action_id,
         p_token_name                  => 'Rep_Run',
         p_token_value                 => g_param_rep_run);

      l_table_id := fetch_validation_table_id('VALIDATION_FORMULA_NAME');
      populate_table_value(g_param_business_group_id, l_table_id, 'FORMULA_NAME');
      hr_utility.set_location('Leaving '|| l_proc, 10);
   END archinit;

   PROCEDURE range_cursor(pactid IN NUMBER, sqlstr OUT NOCOPY VARCHAR2)
   IS
      l_proc       CONSTANT VARCHAR2(50) := g_package || ' range_cursor';
      l_person_id  number;
   BEGIN

   -- hr_utility.trace_on(null,'ARCH');

      PAY_GB_P11D_ARCHIVE_SS.get_parameters(
         p_payroll_action_id           => pactid,
         p_token_name                  => 'PERSON',
         p_token_value                 => l_person_id);

      hr_utility.set_location('Entering '|| l_proc, 10);

      if l_person_id is not null then
         sqlstr :=
            'SELECT DISTINCT person_id
             FROM   per_people_f ppf,
                    pay_payroll_actions ppa
             WHERE  ppa.payroll_action_id = :payroll_action_id
             AND    ppa.business_group_id +0= ppf.business_group_id
             AND    ppf.person_id = ' || l_person_id || ' ORDER BY ppf.person_id';
      else
         sqlstr :=
            'SELECT DISTINCT person_id
             FROM   per_people_f ppf,
                    pay_payroll_actions ppa
             WHERE  ppa.payroll_action_id = :payroll_action_id
             AND    ppa.business_group_id +0= ppf.business_group_id
             ORDER BY ppf.person_id';
      end if;
      hr_utility.set_location('Leaving '|| l_proc, 20);
   END range_cursor;

   PROCEDURE action_creation(pactid IN NUMBER, stperson IN NUMBER, endperson IN NUMBER, CHUNK IN NUMBER)
   IS
      l_actid                       NUMBER;
      l_benefit_end_date            VARCHAR2(20);
      l_benefit_start_date          VARCHAR2(20);
      l_payroll_id                  NUMBER;
      l_person_id                   NUMBER;
      l_rep_run                     varchar2(10);
      l_consolidation_set_id        NUMBER;
      l_tax_reference               VARCHAR2(200);
      l_business_group_id           NUMBER;
      l_assignment_set_id           NUMBER;
      l_flex_id                     NUMBER;
      l_proc               CONSTANT VARCHAR2(50) := g_package || 'action_creation';
      l_prev_assignment_id          NUMBER(10) := NULL;
      l_leg_param pay_payroll_actions.legislative_parameters%type;
      l_count                       NUMBER;
      l_set_payroll_id              NUMBER;
      l_archive                     BOOLEAN;
      l_set_type                    VARCHAR2(2);
--bug 6278134 removed parameter l_tax_reference from cursor csr_flex_id
-- bug 7122883 removed the below cursor
/*       cursor csr_flex_id is
       select distinct flex.soft_coding_keyflex_id flex_id
      from   hr_soft_coding_keyflex flex,
      --bug 6278134 added join conditions with ppf
             pay_all_payrolls_f    ppf
      where  flex.segment1 = nvl(l_tax_reference,flex.segment1)
             AND ppf.soft_coding_keyflex_id + 0 = flex.soft_coding_keyflex_id
             and ppf.payroll_id = nvl(l_payroll_id,ppf.payroll_id)
	     -- bug 7122883 added join condition with business_group_id
	     and ppf.business_group_id=l_business_group_id
             -- Bug 6278134: Added effective date condition
             and fnd_date.canonical_to_date(l_benefit_end_date) between ppf.effective_start_date and ppf.effective_end_date; */

      cursor csr_check_asg_set(p_asg_set_id number) is
      select count(*)
      from   hr_assignment_set_amendments
      where  assignment_set_id = p_asg_set_id;

      cursor csr_check_payroll(p_asg_set_id number) is
      select payroll_id
      from   hr_assignment_sets
      where  assignment_set_id = p_asg_set_id;

      -- assuming that set can contains 1 type of Amendment
      cursor csr_set_type(p_asg_set_id number) is
      select distinct include_or_exclude
      from   hr_assignment_set_amendments
      where  assignment_set_id = p_asg_set_id;
--bug 6278134  passed parameter to the csr_assign_set_X  and csr_noassign_set

      cursor csr_assign_set_X is
      select
             distinct
             paa.assignment_id,
             paa.person_id,
             UPPER('GB_'|| pec.classification_name) classification_name,
             pet.element_name element_name,
             pet.element_type_id element_type_id,
             peev.element_entry_id element_entry_id,
             peev.effective_start_date effective_start_date
      from   per_all_assignments_f paa,
             pay_all_payrolls_f    ppf,
             pay_element_classifications pec,
             pay_element_types_f   pet,
             pay_input_values_f    piv,
             pay_element_entries_f pee,
             pay_element_entry_values_f peev
      where  paa.person_id between stperson AND endperson
      and    (fnd_date.canonical_to_date(l_benefit_end_date)
                between paa.effective_start_date AND paa.effective_end_date
              or
              paa.effective_end_date > fnd_date.canonical_to_date(l_benefit_start_date))
      and    paa.payroll_id = ppf.payroll_id
      -- bug 7122883 added join condition with business_group_id
      and ppf.business_group_id=l_business_group_id
      and    least(fnd_date.canonical_to_date(l_benefit_end_date),paa.effective_end_date)
                between ppf.effective_start_date and ppf.effective_end_date
      and    (l_payroll_id is null or ppf.payroll_id = l_payroll_id)
      and    (l_consolidation_set_id is null or ppf.consolidation_set_id = l_consolidation_set_id)
     --  bug 7122883 removed the below join
   -- and    ppf.soft_coding_keyflex_id + 0 = p_flex_id
   --bug 7122883 added the below join so as to fetch all the records in that tax refernce
      and    (l_tax_reference is null or
              ppf.soft_coding_keyflex_id + 0 in (select distinct flex.soft_coding_keyflex_id flex_id
              from hr_soft_coding_keyflex flex where  flex.segment1 = l_tax_reference))
      and    pec.legislation_code = 'GB'
      and    pec.classification_name like 'EXTERNAL REPORTING%'
      and    pet.classification_id = pec.classification_id
      and    pet.element_type_id = piv.element_type_id
      and    (piv.name = 'Benefit Start Date' or piv.name = 'Benefit End Date')
      and    pee.assignment_id = paa.assignment_id
      and    pee.element_type_id = pet.element_type_id
      and    pee.element_entry_id = peev.element_entry_id
      and    peev.input_value_id = piv.input_value_id
      and    peev.screen_entry_value between l_benefit_start_date and l_benefit_end_date
      and    exists (select 1
                     from   hr_assignment_sets has,
                            hr_assignment_set_amendments hasa
                     where  has.assignment_set_id = l_assignment_set_id
                     and    has.business_group_id = paa.business_group_id
                     and    nvl(has.payroll_id, paa.payroll_id) = paa.payroll_id
                     and    hasa.assignment_set_id = has.assignment_set_id
                     and    hasa.assignment_id = paa.assignment_id
                     and    hasa.include_or_exclude = 'I')
      --bug 6278134  removed exclude assignment set conditon
      /*and    not exists (select 1
                         from   hr_assignment_sets has,
                                hr_assignment_set_amendments hasa
                         where  has.assignment_set_id = l_assignment_set_id
                         and    has.business_group_id = paa.business_group_id
                         and    nvl(has.payroll_id, paa.payroll_id) = paa.payroll_id
                         and    hasa.assignment_set_id = has.assignment_set_id
                         and    hasa.assignment_id = paa.assignment_id
                         and    hasa.include_or_exclude = 'E')*/
      order by paa.assignment_id;

--bug 6278134  Cursor to fetch assignments for exclude assignment set
      cursor csr_assign_set_EX is
      select

             distinct
             paa.assignment_id,
             paa.person_id,
             UPPER('GB_'|| pec.classification_name) classification_name,
             pet.element_name element_name,
             pet.element_type_id element_type_id,
             peev.element_entry_id element_entry_id,
             peev.effective_start_date effective_start_date
      from   per_all_assignments_f paa,
             pay_all_payrolls_f    ppf,
             pay_element_classifications pec,
             pay_element_types_f   pet,
             pay_input_values_f    piv,
             pay_element_entries_f pee,
             pay_element_entry_values_f peev
      where  paa.person_id between stperson AND endperson
      and    (fnd_date.canonical_to_date(l_benefit_end_date)
                between paa.effective_start_date AND paa.effective_end_date
              or
              paa.effective_end_date > fnd_date.canonical_to_date(l_benefit_start_date))
      and    paa.payroll_id = ppf.payroll_id
      -- bug 7122883 added join condition with business_group_id
      and ppf.business_group_id=l_business_group_id
      and    least(fnd_date.canonical_to_date(l_benefit_end_date),paa.effective_end_date)
                between ppf.effective_start_date and ppf.effective_end_date
      and    (l_payroll_id is null or ppf.payroll_id = l_payroll_id)
      and    (l_consolidation_set_id is null or ppf.consolidation_set_id = l_consolidation_set_id)
      --  bug 7122883 removed the below join
   -- and    ppf.soft_coding_keyflex_id + 0 = p_flex_id
   --bug 7122883 added the below join so as to fetch all the records in that tax refernce
      and (l_tax_reference is null or
           ppf.soft_coding_keyflex_id + 0 in (select distinct flex.soft_coding_keyflex_id flex_id
           from hr_soft_coding_keyflex flex where  flex.segment1 = l_tax_reference))
      and    pec.legislation_code = 'GB'
      and    pec.classification_name like 'EXTERNAL REPORTING%'
      and    pet.classification_id = pec.classification_id
      and    pet.element_type_id = piv.element_type_id
      and    (piv.name = 'Benefit Start Date' or piv.name = 'Benefit End Date')
      and    pee.assignment_id = paa.assignment_id
      and    pee.element_type_id = pet.element_type_id
      and    pee.element_entry_id = peev.element_entry_id
      and    peev.input_value_id = piv.input_value_id
      and    peev.screen_entry_value between l_benefit_start_date and l_benefit_end_date
      and    not exists (select 1
                         from   hr_assignment_sets has,
                                hr_assignment_set_amendments hasa
                         where  has.assignment_set_id = l_assignment_set_id
                         and    has.business_group_id = paa.business_group_id
                         and    nvl(has.payroll_id, paa.payroll_id) = paa.payroll_id
                         and    hasa.assignment_set_id = has.assignment_set_id
                         and    hasa.assignment_id = paa.assignment_id
                         and    hasa.include_or_exclude = 'E')
      order by paa.assignment_id;

      cursor csr_noassign_set is
      select /*+ ORDERED INDEX(paa PER_ASSIGNMENTS_F_N12,
                               ppf PAY_PAYROLLS_F_PK)
                 USE_NL(paa,ppf,pec,pet,piv,pee,peev) */
             distinct
             paa.assignment_id,
             paa.person_id,
             UPPER('GB_'|| pec.classification_name) classification_name,
             pet.element_name element_name,
             pet.element_type_id element_type_id,
             peev.element_entry_id element_entry_id,
             peev.effective_start_date effective_start_date
      from   per_all_assignments_f paa,
             pay_all_payrolls_f    ppf,
             pay_element_classifications pec,
             pay_element_types_f   pet,
             pay_input_values_f    piv,
             pay_element_entries_f pee,
             pay_element_entry_values_f peev
      where  paa.person_id between stperson AND endperson
      and    (fnd_date.canonical_to_date(l_benefit_end_date)
                between paa.effective_start_date AND paa.effective_end_date
              or
              paa.effective_end_date > fnd_date.canonical_to_date(l_benefit_start_date))
      and    paa.payroll_id = ppf.payroll_id
      -- bug 7122883 added join condition with business_group_id
      and ppf.business_group_id=l_business_group_id
      and    least(fnd_date.canonical_to_date(l_benefit_end_date),paa.effective_end_date)
                between ppf.effective_start_date and ppf.effective_end_date
      and    (l_payroll_id is null or ppf.payroll_id = l_payroll_id)
      and    (l_consolidation_set_id is null or ppf.consolidation_set_id = l_consolidation_set_id)
      --  bug 7122883 removed the below join
   -- and    ppf.soft_coding_keyflex_id + 0 = p_flex_id
   --bug 7122883 added the below join so as to fetch all the records in that tax refernce
     and (l_tax_reference is null or
          ppf.soft_coding_keyflex_id + 0 in (select distinct flex.soft_coding_keyflex_id flex_id
          from hr_soft_coding_keyflex flex where  flex.segment1 = l_tax_reference))
      and    pec.legislation_code = 'GB'
      and    pec.classification_name like 'EXTERNAL REPORTING%'
      and    pet.classification_id = pec.classification_id
      and    pet.element_type_id = piv.element_type_id
      and    (piv.name = 'Benefit Start Date' or piv.name = 'Benefit End Date')
      and    pee.assignment_id = paa.assignment_id
      and    pee.element_type_id = pet.element_type_id
      and    pee.element_entry_id = peev.element_entry_id
      and    peev.input_value_id = piv.input_value_id
      and    peev.screen_entry_value between l_benefit_start_date and l_benefit_end_date
      order by paa.assignment_id;

      function get_param_value(p_token varchar2) return varchar2
      is
        --l_ret varchar2(255);
        x     number;
        y     number;
        z     number;
      begin
           /*
           select SUBSTR(l_leg_param,INSTR(l_leg_param, p_token) + (LENGTH(p_token) + 1),
                 (DECODE(INSTR(l_leg_param, ' ', INSTR(l_leg_param, p_token)),
                  0, DECODE(INSTR(l_leg_param, p_token), 0, .5, LENGTH(l_leg_param)),
                       INSTR(l_leg_param, ' ', INSTR(l_leg_param, p_token))
                       - (INSTR(l_leg_param, p_token) + (LENGTH(p_token) + 1)))))
           into l_ret
           from dual;
           return l_ret; */
           x := instr(l_leg_param,p_token);
           y := length(p_token);
           if instr(l_leg_param, ' ', x) <> 0 then
              Z := INSTR(l_leg_param, ' ', INSTR(l_leg_param, p_token)) -
                   (INSTR(l_leg_param, p_token) + (LENGTH(p_token) + 1));
           else
              z := 0;
              if instr(l_leg_param, p_token) <> 0 then
                 z := length(l_leg_param);
              end if;
           end if;
           return SUBSTR(l_leg_param, X + Y + 1, Z);
      end;

   BEGIN
      -- hr_utility.trace_on(null,'ARCH');
      hr_utility.set_location('Entering '|| l_proc, 10);

      -- could not use the param parameters initialised in init procedure
      -- as the action creation does not get called at all if i use them
      select legislative_parameters,
             business_group_id,
             fnd_date.date_to_canonical(start_date),
             fnd_date.date_to_canonical(effective_date)
      into  l_leg_param, l_business_group_id, l_benefit_start_date, l_benefit_end_date
      from  pay_payroll_actions
      where payroll_action_id = pactid;

      l_payroll_id := get_param_value('PAYROLL');
      l_person_id := get_param_value('PERSON');
      l_consolidation_set_id := get_param_value('CONSOLIDATION_SET');
      l_tax_reference := get_param_value('TAX_REFERENCE');
      l_assignment_set_id := get_param_value('ASSIGNMENT_SET_ID');
      l_rep_run := get_param_value('Rep_Run');
      l_archive := TRUE;
      -- Check to see if the conc program parameters are
      -- correctly selected
      If fnd_date.canonical_to_date(l_benefit_start_date) <
         to_date('06-04-' ||to_char(to_number(l_rep_run)-1),'dd-mm-yyyy') or
         fnd_date.canonical_to_date(l_benefit_start_date) >
         to_date('05-04-' ||l_rep_run,'dd-mm-yyyy')
      Then
         pay_core_utils.push_message(800, 'HR_78076_P11D_DATE_PARAM_ERR', 'F');
         pay_core_utils.push_token('NAME', 'Benefit Start Date');
         pay_core_utils.push_token('VAl1','06-04-' ||to_char(to_number(l_rep_run)-1));
         pay_core_utils.push_token('VAl2', '05-04-' ||l_rep_run);

         fnd_message.set_name('PER', 'HR_78076_P11D_DATE_PARAM_ERR');
         fnd_message.set_token('NAME', 'Benefit Start Date');
         fnd_message.set_token('VAL1', '06-04-' ||to_char(to_number(l_rep_run)-1));
         fnd_message.set_token('VAL2', '05-04-' ||l_rep_run);
         fnd_file.put_line(fnd_file.LOG,fnd_message.get);
         hr_utility.raise_error;
      End if;

      If fnd_date.canonical_to_date(l_benefit_end_date) <
         to_date('06-04-' ||to_char(to_number(l_rep_run)-1),'dd-mm-yyyy') or
         fnd_date.canonical_to_date(l_benefit_end_date) >
         to_date('05-04-' ||l_rep_run,'dd-mm-yyyy')
      then
         pay_core_utils.push_message(800, 'HR_78076_P11D_DATE_PARAM_ERR', 'F');
         pay_core_utils.push_token('NAME', 'Benefit End Date');
         pay_core_utils.push_token('VAl1','06-04-' ||to_char(to_number(l_rep_run)-1));
         pay_core_utils.push_token('VAl2', '05-04-' ||l_rep_run);

         fnd_message.set_name('PER', 'HR_78076_P11D_DATE_PARAM_ERR');
         fnd_message.set_token('NAME', 'Benefit End Date');
         fnd_message.set_token('VAL1', '06-04-' ||to_char(to_number(l_rep_run)-1));
         fnd_message.set_token('VAL2', '05-04-' ||l_rep_run);
         fnd_file.put_line(fnd_file.LOG,fnd_message.get);
         hr_utility.raise_error;
      End if;
      hr_utility.set_location('Step '|| l_proc, 20);
      hr_utility.set_location('l_benefit_start_date = '|| l_benefit_start_date, 20);
      hr_utility.set_location('l_benefit_end_date   = '|| l_benefit_end_date, 20);
      hr_utility.set_location('l_business_group_id = '|| l_business_group_id, 20);
      hr_utility.set_location('l_tax_reference = '|| l_tax_reference, 20);
      hr_utility.set_location('l_consolidation_set_id = '|| l_consolidation_set_id, 20);
      hr_utility.set_location('l_payroll_id = '|| l_payroll_id, 20);
      hr_utility.set_location('l_person_id = '|| l_person_id, 20);
      hr_utility.set_location('l_assignment_set_id = '|| l_assignment_set_id, 20);
      hr_utility.set_location('Before the cursor assignment id ', 30);
 -- removed for bug 6278134
    /*   open csr_flex_id(l_tax_reference);
      fetch csr_flex_id into l_flex_id;
      close csr_flex_id;   */

      open csr_check_asg_set(l_assignment_set_id);
      fetch csr_check_asg_set into l_count;
      close csr_check_asg_set;

      open csr_check_payroll(l_assignment_set_id);
      fetch csr_check_payroll into l_set_payroll_id;
      close csr_check_payroll;
      -- if it is empty assignment set contains no amendments,
      -- check if the payroll is defined on the assignment set or not
      -- if no payroll, then treated this as normal case run
      if l_count < 1 then
          if l_set_payroll_id is null then
             l_assignment_set_id := null;
          else
             -- set payroll id is not null, check if it matches the param payroll id
             -- if payroll id = set payroll id, then run as a normal payroll
             if nvl(l_payroll_id,l_set_payroll_id) = l_set_payroll_id then
                l_assignment_set_id := null;
                l_payroll_id := l_set_payroll_id;
             else -- incoming payroll <> to set payroll, don't do archive
                l_archive := false;
             end if;
          end if;
      else
          -- incoming payroll <> to set payroll, don't do archive
          if l_set_payroll_id is not null and
             nvl(l_payroll_id, l_set_payroll_id) <> l_set_payroll_id then
             l_archive := false;
          end if;
      end if;
      --
      if l_archive then
      --bug 7122883 removed below for loop
     -- for r_flex_id in csr_flex_id
      -- loop
          if l_assignment_set_id is not null then
	     -- bug 6278134 fetching assignment set type for assignment set id
	     OPEN csr_set_type(l_assignment_set_id);
	     FETCH csr_set_type into l_set_type;
	     CLOSE csr_set_type;
             --bug 6278134 added check for Include and Exclude conditions
	     IF l_set_type = 'I' then
	  FOR csr_rec IN csr_assign_set_X
	       LOOP
                 hr_utility.TRACE(' l_prev_assignment_id '|| l_prev_assignment_id);
                 hr_utility.TRACE(' csr_rec.assignment_id '|| csr_rec.assignment_id);
                 if check_assignment_tax_ref(csr_rec.assignment_id,l_tax_reference,l_benefit_end_date) then
                    if l_prev_assignment_id IS NULL OR l_prev_assignment_id <> csr_rec.assignment_id
                    THEN
                        -- CREATE THE ARCHIVE ASSIGNMENT ACTION FOR THE MASTER ASSIGNMENT ACTION
                        SELECT pay_assignment_actions_s.NEXTVAL
                          INTO l_actid
                          FROM DUAL;

                        hr_utility.set_location('Archive assignment Action ', 30);
                        hr_nonrun_asact.insact(l_actid, csr_rec.assignment_id, pactid, CHUNK, NULL);
                        l_prev_assignment_id := csr_rec.assignment_id;
                        hr_utility.TRACE(' Created Assignment action ');
                        hr_utility.TRACE(' csr_rec.assignment_id '|| csr_rec.assignment_id);
                    END IF;

                    g_ben_asg_count := g_ben_asg_count + 1;
                    hr_utility.set_location('Inside the cursor assignment id ', 30);
                    g_tab_ben_detail(g_ben_asg_count).assignment_action_id := l_actid;
                    g_tab_ben_detail(g_ben_asg_count).element_type_id := csr_rec.element_type_id;
                    g_tab_ben_detail(g_ben_asg_count).element_entry_id := csr_rec.element_entry_id;
                    g_tab_ben_detail(g_ben_asg_count).element_name := csr_rec.element_name;
                    g_tab_ben_detail(g_ben_asg_count).effective_start_date := csr_rec.effective_start_date;
                    g_tab_ben_detail(g_ben_asg_count).person_id := csr_rec.person_id;
                    g_tab_ben_detail(g_ben_asg_count).assignment_id := csr_rec.assignment_id;
                    g_tab_ben_detail(g_ben_asg_count).classification_name := csr_rec.classification_name;
                 end if;
             END LOOP;
	     ELSIF l_set_type = 'E' then
             FOR csr_rec IN csr_assign_set_EX
             LOOP
                 hr_utility.TRACE(' l_prev_assignment_id '|| l_prev_assignment_id);
                 hr_utility.TRACE(' csr_rec.assignment_id '|| csr_rec.assignment_id);
                 if check_assignment_tax_ref(csr_rec.assignment_id,l_tax_reference,l_benefit_end_date) then
                    if l_prev_assignment_id IS NULL OR l_prev_assignment_id <> csr_rec.assignment_id
                    THEN
                        -- CREATE THE ARCHIVE ASSIGNMENT ACTION FOR THE MASTER ASSIGNMENT ACTION
                        SELECT pay_assignment_actions_s.NEXTVAL
                          INTO l_actid
                          FROM DUAL;

                        hr_utility.set_location('Archive assignment Action ', 30);
                        hr_nonrun_asact.insact(l_actid, csr_rec.assignment_id, pactid, CHUNK, NULL);
                        l_prev_assignment_id := csr_rec.assignment_id;
                        hr_utility.TRACE(' Created Assignment action ');
                        hr_utility.TRACE(' csr_rec.assignment_id '|| csr_rec.assignment_id);
                    END IF;

                    g_ben_asg_count := g_ben_asg_count + 1;
                    hr_utility.set_location('Inside the cursor assignment id ', 30);
                    g_tab_ben_detail(g_ben_asg_count).assignment_action_id := l_actid;
                    g_tab_ben_detail(g_ben_asg_count).element_type_id := csr_rec.element_type_id;
                    g_tab_ben_detail(g_ben_asg_count).element_entry_id := csr_rec.element_entry_id;
                    g_tab_ben_detail(g_ben_asg_count).element_name := csr_rec.element_name;
                    g_tab_ben_detail(g_ben_asg_count).effective_start_date := csr_rec.effective_start_date;
                    g_tab_ben_detail(g_ben_asg_count).person_id := csr_rec.person_id;
                    g_tab_ben_detail(g_ben_asg_count).assignment_id := csr_rec.assignment_id;
                    g_tab_ben_detail(g_ben_asg_count).classification_name := csr_rec.classification_name;
                 end if;
             END LOOP;
             END IF;
          else
             FOR csr_rec in csr_noassign_set
             LOOP
                 hr_utility.TRACE(' l_prev_assignment_id '|| l_prev_assignment_id);
                 hr_utility.TRACE(' csr_rec.assignment_id '|| csr_rec.assignment_id);
                 if check_assignment_tax_ref(csr_rec.assignment_id,l_tax_reference,l_benefit_end_date) then
                    IF l_prev_assignment_id IS NULL OR l_prev_assignment_id <> csr_rec.assignment_id
                    THEN
                        -- CREATE THE ARCHIVE ASSIGNMENT ACTION FOR THE MASTER ASSIGNMENT ACTION
                        SELECT pay_assignment_actions_s.NEXTVAL
                          INTO l_actid
                          FROM DUAL;
                        hr_utility.set_location('Archive assignment Action ', 30);
                        hr_nonrun_asact.insact(l_actid, csr_rec.assignment_id, pactid, CHUNK, NULL);
                        l_prev_assignment_id := csr_rec.assignment_id;
                        hr_utility.TRACE(' Created Assignment action ');
                        hr_utility.TRACE(' csr_rec.assignment_id '|| csr_rec.assignment_id);
                    END IF;

                    g_ben_asg_count := g_ben_asg_count + 1;
                    hr_utility.set_location('Inside the cursor assignment id ', 30);
                    g_tab_ben_detail(g_ben_asg_count).assignment_action_id := l_actid;
                    g_tab_ben_detail(g_ben_asg_count).element_type_id := csr_rec.element_type_id;
                    g_tab_ben_detail(g_ben_asg_count).element_entry_id := csr_rec.element_entry_id;
                    g_tab_ben_detail(g_ben_asg_count).element_name := csr_rec.element_name;
                    g_tab_ben_detail(g_ben_asg_count).effective_start_date := csr_rec.effective_start_date;
                    g_tab_ben_detail(g_ben_asg_count).person_id := csr_rec.person_id;
                    g_tab_ben_detail(g_ben_asg_count).assignment_id := csr_rec.assignment_id;
                    g_tab_ben_detail(g_ben_asg_count).classification_name := csr_rec.classification_name;
                 end if;
             END LOOP;
          end if;
       --   END LOOP;
	  --end of bug 6278134
       end if; -- end l_archive
      hr_utility.set_location('Leaving '|| l_proc, 20);
   END action_creation;

   PROCEDURE archive_code(p_assactid IN NUMBER, p_effective_date IN DATE)
   IS
      l_actual_termination_date date;

      CURSOR csr_assignment_det(p_assignment_id NUMBER, p_tax_ref VARCHAR2)
      IS
      SELECT pap.last_name || ' ' || pap.first_name,
             paa.payroll_id,
             NVL(pap.per_information2, 'N'),
             pap.first_name,
             pap.middle_names,
             pap.last_name,
             nvl(paa.ASSIGNMENT_NUMBER,pap.employee_number),
             pap.person_id,
             pap.national_identifier,
             pap.sex,
             pap.date_of_birth
        FROM per_all_assignments_f paa,
             per_all_people_f pap,
             per_periods_of_service pps,
             pay_all_payrolls_f pay,
             hr_soft_coding_keyflex flex
       WHERE paa.person_id = pap.person_id
         AND pps.PERIOD_OF_SERVICE_ID(+) = paa.PERIOD_OF_SERVICE_ID
         AND least(nvl(pps.ACTUAL_TERMINATION_DATE,fnd_date.canonical_to_date(g_param_benefit_end_date)),
                fnd_date.canonical_to_date(g_param_benefit_end_date))
                    BETWEEN pap.effective_start_date AND pap.effective_end_date
         AND paa.assignment_id = p_assignment_id
         AND paa.payroll_id = pay.payroll_id
         AND least(fnd_date.canonical_to_date(g_param_benefit_end_date), paa.effective_end_date)
                   between pay.effective_start_date and pay.effective_end_date
         AND pay.soft_coding_keyflex_id + 0 = flex.soft_coding_keyflex_id
         AND (p_tax_ref is null
              OR
              flex.segment1 = p_tax_ref)
         AND (fnd_date.canonical_to_date(g_param_benefit_end_date) between paa.effective_start_date AND paa.effective_end_date
                     OR
              (
                 paa.effective_end_date = (select max(paa2.effective_end_date)
                                             from per_assignments_f paa2
                                            where paa2.assignment_id = p_assignment_id)
                 and paa.effective_end_date < fnd_date.canonical_to_date(g_param_benefit_end_date))
             );

      CURSOR assignments_to_sum(p_person_id NUMBER, p_emp_ref VARCHAR2, p_emp_name VARCHAR2)
      IS
         SELECT paa.assignment_action_id, pai_person.action_information1, pai_comp.action_information6,
                pai_comp.action_information7
           FROM pay_action_information pai_comp,
                pay_action_information pai_person,
                pay_assignment_actions paa,
                pay_payroll_actions ppa
          WHERE ppa.payroll_action_id = g_pactid
                AND paa.payroll_action_id = ppa.payroll_action_id
                AND pai_comp.action_context_id = paa.assignment_action_id
                AND pai_comp.action_information_category = 'EMEA PAYROLL INFO'
                AND pai_person.action_context_id = paa.assignment_action_id
                AND pai_person.action_information_category = 'ADDRESS DETAILS'
                AND pai_person.action_information14 = 'Employee Address'
                AND pai_person.action_information1 =   p_person_id
                AND pai_comp.action_information6 = p_emp_ref
                AND pai_comp.action_information7 = p_emp_name;

      CURSOR csr_val_element_entry_id(v_assactid           pay_assignment_actions.assignment_action_id%TYPE,
                                      v_benefit_start_date VARCHAR2,
                                      v_benefit_end_date   VARCHAR2)
      IS
         SELECT DISTINCT pet.element_type_id element_type_id, peev.element_entry_id element_entry_id,
                         pet.element_name element_name, peev.effective_start_date effective_start_date, paa.person_id,
                         paa.assignment_id, UPPER('GB_'|| pec.classification_name) classification_name
                    FROM pay_element_types_f pet,
                         pay_element_classifications pec,
                         pay_input_values_f piv,
                         pay_element_entry_values_f peev,
                         pay_element_entries_f pee,
                         per_assignments_f paa,
                         pay_assignment_actions paac
                   WHERE pet.classification_id = pec.classification_id AND
                         pet.element_type_id = piv.element_type_id AND
                         piv.input_value_id = peev.input_value_id AND
                         pee.element_entry_id = peev.element_entry_id AND
                         pee.assignment_id = paac.assignment_id AND
                         paa.assignment_id = paac.assignment_id AND
                         paac.assignment_action_id = v_assactid AND
                         pec.classification_name LIKE 'EXTERNAL REPORTING%' AND
                         (piv.NAME = 'Benefit Start Date' OR piv.NAME = 'Benefit End Date') AND
                         pee.assignment_id = paa.assignment_id AND
                         peev.screen_entry_value BETWEEN v_benefit_start_date AND v_benefit_end_date
                ORDER BY pet.element_type_id, peev.element_entry_id, peev.effective_start_date;


      CURSOR csr_element_entry_values(v_element_entry_id     pay_element_entry_values_f.element_entry_id%TYPE,
                                      v_element_type_id      pay_element_types_f.element_type_id%TYPE,
                                      v_effective_start_date DATE)
      IS
         SELECT peev.screen_entry_value, UPPER(TRANSLATE(piv.NAME, ' ', '_') ) NAME
           FROM pay_input_values_f piv, pay_element_entry_values_f peev
          WHERE piv.input_value_id = peev.input_value_id AND
                piv.element_type_id = v_element_type_id  AND
                peev.element_entry_id = v_element_entry_id AND
                peev.effective_start_date = v_effective_start_date;


      CURSOR csr_element_entry_flex_values(v_classification_name VARCHAR2)
      IS
         SELECT application_column_name, UPPER(TRANSLATE(end_user_column_name, ' ', '_') ) NAME
           FROM fnd_descr_flex_col_usage_vl
          WHERE application_id = g_application_id AND
                descriptive_flexfield_name = 'Element Entry Developer DF'AND
                descriptive_flex_context_code = v_classification_name AND
                (enabled_flag IS NULL OR enabled_flag ='Y');

      CURSOR csr_action_info_flex_fields(v_element_name VARCHAR2)
      IS
         SELECT application_column_name application_column_name, UPPER(TRANSLATE(end_user_column_name, ' ', '_') ) NAME
           FROM fnd_descr_flex_col_usage_vl
          WHERE application_id = g_application_id AND
                descriptive_flexfield_name = 'Action Information DF'  AND
                descriptive_flex_context_code = v_element_name AND
                (enabled_flag IS NULL OR enabled_flag = 'Y');

      Cursor csr_non_iv_action_info_items(v_element_entry_id     pay_element_entry_values_f.element_entry_id%TYPE,
                                          v_element_type_id      pay_element_types_f.element_type_id%TYPE,
                                          v_effective_start_date DATE,
                                          v_element_name         VARCHAR2,
                                          v_classification_name  VARCHAR2)
      is
         SELECT UPPER(TRANSLATE(flex_act.end_user_column_name, ' ', '_') ) NAME
           FROM fnd_descr_flex_col_usage_vl flex_act
          WHERE flex_act.application_id = g_application_id AND
                flex_act.descriptive_flexfield_name = 'Action Information DF' AND
                flex_act.descriptive_flex_context_code = v_element_name  AND
                (flex_act.enabled_flag IS NULL OR flex_act.enabled_flag = 'Y') and
                not exists ( select /*+ no_unnest */ 1
                                from
                                fnd_descr_flex_col_usage_vl flex_ele
                                where
                                flex_ele.application_id = g_application_id AND
                                flex_ele.descriptive_flexfield_name = 'Element Entry Developer DF' AND
                                flex_ele.descriptive_flex_context_code = v_classification_name AND
                                (flex_ele.enabled_flag IS NULL OR flex_ele.enabled_flag ='Y') AND
                                flex_ele.end_user_column_name = flex_act.end_user_column_name ) AND
                not Exists (
                      SELECT /*+ no_unnest */ 1
           FROM pay_input_values_f piv,
                pay_element_entry_values_f peev
          WHERE piv.input_value_id = peev.input_value_id AND
                piv.element_type_id = v_element_type_id  AND
                peev.element_entry_id = v_element_entry_id AND
                peev.effective_start_date = v_effective_start_date AND
                UPPER(TRANSLATE(substr(piv.NAME,1,30),' ', '_') ) =
                          UPPER(TRANSLATE(flex_act.end_user_column_name, ' ', '_')));

    cursor csr_get_global(p_name varchar2,
                          p_date date)
    is
      select to_number(global_value)
      from   ff_globals_f
      where  global_name = p_name
      and    legislation_code = 'GB'
      and    p_date between effective_start_date and effective_end_date;

    cursor csr_get_term_date (p_assignment_id Number)
    is
      select ACTUAL_TERMINATION_DATE
      from per_periods_of_service pps,
           per_assignments_f paf
      where paf.PERIOD_OF_SERVICE_ID = pps.PERIOD_OF_SERVICE_ID
      and paf.assignment_id =p_assignment_id;

    cursor csr_get_asg_end_date(p_assignment_id number)
    is
      select max(effective_end_date)
      from   per_all_assignments_f
      where  assignment_id = p_assignment_id;

      l_element_name                pay_element_types_f.element_name%TYPE;
      l_formula_id                  ff_formulas_f.formula_id%TYPE;
      l_formula_effective_start_date DATE;
      l_inputs                      ff_exec.inputs_t;
      l_user_inputs                 ff_exec.inputs_t;
      l_outputs                     ff_exec.outputs_t;
      l_counter                     NUMBER;
      l_assignment_id               NUMBER;
      l_loan_threshold              NUMBER;
      l_asg_max_end_date            DATE;
      l_benefit_end_date            VARCHAR2(20);
      l_benefit_start_date          VARCHAR2(20); -- this used ot store the
                                                  -- values of the p11d elements
      l_payroll_id                  NUMBER;
      l_pactid                      NUMBER;
      l_action_context_id           NUMBER;
      l_action_info_id              NUMBER(15);
      l_ovn                         NUMBER;
      error_found                   EXCEPTION;
      l_error                       VARCHAR2(10);
      l_sqlstr                      VARCHAR2(28000);
      l_sql_stmt                    VARCHAR2(1000);
      l_assignment_name             VARCHAR2(100);
      l_assignment_number           VARCHAR2(30);
      l_director_flag               VARCHAR2(150);
      l_first_name                  VARCHAR2(150);
      l_middle_name                 VARCHAR2(150);
      l_last_name                   VARCHAR2(150);
      l_date_of_birth               DATE;
      l_sex                         VARCHAR2(10);
      l_person_id                   NUMBER;
      l_ni_number                   VARCHAR2(12);
      l_proc                        VARCHAR2(50) := g_package || 'archive_code';
      l_edi_validation              VARCHAR2(10);
      l_error_assignment            BOOLEAN;
      l_index                       NUMBER(15);

      TYPE t_error_rec IS RECORD(
         error_text                    VARCHAR2(2000),
         error_assignment_id           NUMBER,
         error_assignment_number       varchar2(30),
         error_assignment_name         VARCHAR2(100),
         error_element_name            VARCHAR2(100),
         error_element_entry_id        NUMBER,
         error_ben_st_date             VARCHAR2(20),
         error_ben_end_date            VARCHAR2(20),
         error_type                    VARCHAR2(2)
         );


      TYPE t_error_msgs IS TABLE OF t_error_rec
         INDEX BY BINARY_INTEGER;

      l_val_errors                  t_error_msgs;
      l_val_error_count             INTEGER DEFAULT 0;

      TYPE l_rec_pay_info IS RECORD(
         l_employers_ref_no            VARCHAR2(150),
         l_tax_office_name             VARCHAR2(150),
         l_tax_office_phone_no         VARCHAR2(150),
         l_employer_name               VARCHAR2(150),
         l_employer_address            VARCHAR2(150) );

      TYPE l_typ_pay_info_table IS TABLE OF l_rec_pay_info
         INDEX BY BINARY_INTEGER;

      l_pay_info_tab                l_typ_pay_info_table;

      payroll_not_found             EXCEPTION;
      tax_office_name_error         EXCEPTION;
      employer_address_error        EXCEPTION;
      employers_ref_no_error        EXCEPTION;
      employer_name_error           EXCEPTION;
      -- defining variables to use in dyn sql
      l_col1_val                    VARCHAR2(240);
      l_col2_val                    VARCHAR2(240);
      l_col3_val                    VARCHAR2(240);
      l_col4_val                    VARCHAR2(240);
      l_col5_val                    VARCHAR2(240);
      l_col6_val                    VARCHAR2(240);
      l_col7_val                    VARCHAR2(240);
      l_col8_val                    VARCHAR2(240);
      l_col9_val                    VARCHAR2(240);
      l_col10_val                   VARCHAR2(240);
      l_col11_val                   VARCHAR2(240);
      l_col12_val                   VARCHAR2(240);
      l_col13_val                   VARCHAR2(240);
      l_col14_val                   VARCHAR2(240);
      l_col15_val                   VARCHAR2(240);
      l_col16_val                   VARCHAR2(240);
      l_col17_val                   VARCHAR2(240);
      l_col18_val                   VARCHAR2(240);
      l_col19_val                   VARCHAR2(240);
      l_col20_val                   VARCHAR2(240);
      l_col21_val                   VARCHAR2(240);
      l_col22_val                   VARCHAR2(240);
      l_col23_val                   VARCHAR2(240);
      l_col24_val                   VARCHAR2(240);
      l_col25_val                   VARCHAR2(240);
      l_col26_val                   VARCHAR2(240);
      l_col27_val                   VARCHAR2(240);
      l_col28_val                   VARCHAR2(240);
      l_col29_val                   VARCHAR2(240);
      l_col30_val                   VARCHAR2(240);
      l_dyn_sql_ele_name_param      VARCHAR2(30);
      l_ret                         INTEGER;
      l_warn number;

      l_first_index Number;
      l_first_index_set Boolean;

      --
      TYPE l_typ_processed_assign_actions IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

      l_processed_assign_actions    l_typ_processed_assign_actions;
      c_proc_assign_actions_null    l_typ_processed_assign_actions;
      l_tab_counter                 NUMBER;
      l_extra_items_count           Number :=0;

      --
      FUNCTION find_lowest_matching_index RETURN INTEGER
      IS
           l_lower               INTEGER;
           l_upper               INTEGER;
           l_check_item          INTEGER;
           l_first_matching_item INTEGER := 0;
           l_match               BOOLEAN := FALSE;
      BEGIN
         hr_utility.trace('Inside find_lowest_matching_index ');

         l_lower := 1;
         l_upper := g_tab_ben_detail.COUNT;

         FOR counter IN l_lower .. l_upper
         LOOP
            l_check_item := FLOOR( (l_lower + l_upper) / 2);

            IF g_tab_ben_detail(l_check_item).assignment_action_id = p_assactid
            THEN
               l_match := TRUE;
               hr_utility.TRACE('.. MATCHED..');
               EXIT;
            ELSIF p_assactid < g_tab_ben_detail(l_check_item).assignment_action_id
            THEN
               -- search below this
               l_upper := l_check_item - 1;
            ELSE
               l_lower := l_check_item + 1;
            END IF;
         END LOOP;

         IF l_match
         THEN
            -- it returned the match, due to multiple emtries
            -- there could be rows for same p_assactid before the matched row
            -- we need to find them
            IF l_check_item = 1
            THEN
               l_first_matching_item := l_check_item;
            ELSE
               FOR counter IN REVERSE 1 .. l_check_item
               LOOP
                  IF g_tab_ben_detail(counter).assignment_action_id = p_assactid
                  THEN
                     -- item matches and counter is 1 menaing the first item
                     IF counter = 1
                     THEN
                        l_first_matching_item := counter;
                     END IF;
                  ELSE -- item does not match meaning the match first is counter +1
                     l_first_matching_item := counter + 1;
                     EXIT;
                  END IF;
               END LOOP;
            END IF; -- end of l_check_item = 1
         END IF;-- end of l_match
         hr_utility.TRACE(' Returning l_first_matching_item '|| l_first_matching_item);
         RETURN l_first_matching_item;
      Exception
        when others then
                l_first_matching_item := 0;
                RETURN l_first_matching_item;
      END;

      --
      PROCEDURE populate_payroll_info(p_end_date VARCHAR2, p_payroll_id NUMBER)
      AS
      BEGIN
         hr_utility.TRACE('InsidePopulate_Payroll_info');
         hr_utility.TRACE('p_payroll_id '|| p_payroll_id);
         hr_utility.TRACE('p_end_date '|| p_end_date);
         -- end date is constant in the Archiver run
         -- hence we do nt need to worry about
         -- multiple recrds for a payroll id as date is fixed!

         -- check if it exists in table
         -- if not fetch it and add to table
         OPEN csr_payroll_info(p_end_date, p_payroll_id);
         FETCH csr_payroll_info INTO l_pay_info_tab(p_payroll_id).l_employers_ref_no,
                                     l_pay_info_tab(p_payroll_id).l_tax_office_name,
                                     l_pay_info_tab(p_payroll_id).l_tax_office_phone_no,
                                     l_pay_info_tab(p_payroll_id).l_employer_name,
                                     l_pay_info_tab(p_payroll_id).l_employer_address;

         IF csr_payroll_info%NOTFOUND
         THEN
            hr_utility.set_location('payroll info not found: ', 30);
            CLOSE csr_payroll_info;
            RAISE payroll_not_found;
         ELSE
            CLOSE csr_payroll_info;
            hr_utility.set_location('Archiving Payroll info', 35);
            hr_utility.TRACE(' Found InsidePopulate_Payroll_info');

            IF pay_gb_eoy_magtape.validate_input(UPPER(l_pay_info_tab(p_payroll_id).l_tax_office_name) ) > 0
            THEN
               --            fnd_file.put_line(fnd_file.output,'Tax Office Name contains illegal character(s) :' || l_tax_office_name );
               RAISE tax_office_name_error;
            END IF;

            IF pay_gb_eoy_magtape.validate_input(UPPER(l_pay_info_tab(p_payroll_id).l_employer_address),'P11D_EDI' ) > 0
            THEN
               --            fnd_file.put_line(fnd_file.output,'Employers Address contains illegal character(s) :' || l_employer_address );
               RAISE employer_address_error;
            END IF;

            IF pay_gb_eoy_magtape.validate_input(UPPER(l_pay_info_tab(p_payroll_id).l_employers_ref_no) ) > 0
            THEN
               --            fnd_file.put_line(fnd_file.output,'Employers Reference Number contains illegal character(s) :' || l_employers_ref_no);
               RAISE employers_ref_no_error;
            END IF;

            IF pay_gb_eoy_magtape.validate_input(to_number(substr(l_pay_info_tab(p_payroll_id).l_employers_ref_no,1,3)),'NUMBER') > 0
            THEN
               RAISE employers_ref_no_error;
            END IF;

            IF pay_gb_eoy_magtape.validate_input(UPPER(l_pay_info_tab(p_payroll_id).l_employer_name),'P11D_EDI' ) > 0
            THEN
               --            fnd_file.put_line(fnd_file.output,'Employers Name contains illegal character(s) :' || l_employer_name );
               RAISE employer_name_error;
            END IF;
         END IF;
      END;

      Function calculate_amap_ce
      return number
      is
           l_C_BUS_MILES                      Number;
           l_M_BUS_MILES                      Number;
           l_B_BUS_MILES                      Number;
           l_C_RATE1                          Number;
           l_C_RATE2                          Number;
           l_M_RATE1                          Number;
           l_M_RATE2                          Number;
           l_B_RATE1                          Number;
           l_B_RATE2                          Number;
           l_C_MILEAGE_PAYMENTS               Number;
           l_B_MILEAGE_PAYMENTS               Number;
           l_M_MILEAGE_PAYMENTS               Number;
           l_C_TAX_DEDUCTED                   Number;
           l_B_TAX_DEDUCTED                   Number;
           l_M_TAX_DEDUCTED                   Number;
           l_PASSENGER_PAYMENTS               Number;
           l_PASSENGER_BUS_MILES              Number;
           l_PASSENGER_BUS_MILE_AMT           Number;

           l_c_net_allowance Number;
           l_c_tot_approved_payments Number;
           l_c_taxable_payment Number;
           l_b_net_allowance Number;
           l_b_tot_approved_payments Number;
           l_b_taxable_payment Number;
           l_m_net_allowance Number;
           l_m_tot_approved_payments Number;
           l_m_taxable_payment Number;
           l_taxable_pass_payment Number;
           l_ce Number;
      begin
--           hr_utility.trace_on(null,'AMAP');
           l_C_BUS_MILES                      := nvl(per_formula_functions.get_number('C_BUS_MILES'),0);
           l_M_BUS_MILES                      := nvl(per_formula_functions.get_number('M_BUS_MILES'),0);
           l_B_BUS_MILES                      := nvl(per_formula_functions.get_number('B_BUS_MILES'),0);
           l_C_RATE1                          := nvl(per_formula_functions.get_number('C_RATE1'),0);
           l_C_RATE2                          := nvl(per_formula_functions.get_number('C_RATE2'),0);
           l_M_RATE1                          := nvl(per_formula_functions.get_number('M_RATE1'),0);
           l_M_RATE2                          := nvl(per_formula_functions.get_number('M_RATE2'),0);
           l_B_RATE1                          := nvl(per_formula_functions.get_number('B_RATE1'),0);
           l_B_RATE2                          := nvl(per_formula_functions.get_number('B_RATE2'),0);
           l_C_MILEAGE_PAYMENTS               := nvl(per_formula_functions.get_number('C_MILEAGE_PAYMENTS'),0);
           l_B_MILEAGE_PAYMENTS               := nvl(per_formula_functions.get_number('B_MILEAGE_PAYMENTS'),0);
           l_M_MILEAGE_PAYMENTS               := nvl(per_formula_functions.get_number('M_MILEAGE_PAYMENTS'),0);
           l_C_TAX_DEDUCTED                   := nvl(per_formula_functions.get_number('C_TAX_DEDUCTED'),0);
           l_B_TAX_DEDUCTED                   := nvl(per_formula_functions.get_number('B_TAX_DEDUCTED'),0);
           l_M_TAX_DEDUCTED                   := nvl(per_formula_functions.get_number('M_TAX_DEDUCTED'),0);
           l_PASSENGER_PAYMENTS               := nvl(per_formula_functions.get_number('PASSENGER_PAYMENTS'),0);
           l_PASSENGER_BUS_MILES              := nvl(per_formula_functions.get_number('PASSENGER_BUS_MILES'),0);
           l_PASSENGER_BUS_MILE_AMT           := nvl(per_formula_functions.get_number('PASSENGER_BUS_MILE_AMT'),0);

           l_c_net_allowance :=   l_C_MILEAGE_PAYMENTS -  l_C_TAX_DEDUCTED;
           if l_c_net_allowance < 0
           then
               l_c_net_allowance := 0;
           end if;
           hr_utility.trace(' l_c_net_allowance ' || l_c_net_allowance);

           if l_C_BUS_MILES > 10000 then
               l_c_tot_approved_payments := (10000 * l_C_RATE1) +
                                          (
                                           (l_C_BUS_MILES - 10000) * l_C_RATE2
                                          );
           else
               l_c_tot_approved_payments := l_C_BUS_MILES * l_C_RATE1;
           end if;
           l_c_taxable_payment := l_c_net_allowance - l_c_tot_approved_payments;
           if l_c_taxable_payment < 0 then
               l_c_taxable_payment := 0;
           end if;

           hr_utility.trace(' l_c_taxable_payment ' || l_c_taxable_payment);

           l_b_net_allowance :=   l_B_MILEAGE_PAYMENTS -  l_B_TAX_DEDUCTED;
           if l_b_net_allowance < 0
           then
               l_b_net_allowance := 0;
           end if;
           if l_B_BUS_MILES > 10000 then
               l_b_tot_approved_payments := (10000 * l_B_RATE1) +
                                          (
                                           (l_B_BUS_MILES - 10000) * l_B_RATE2
                                          );
           else
               l_b_tot_approved_payments := l_B_BUS_MILES * l_B_RATE1;
           end if;
           l_b_taxable_payment := l_b_net_allowance - l_b_tot_approved_payments;
           if l_b_taxable_payment < 0 then
               l_b_taxable_payment := 0;
           end if;
--
           l_m_net_allowance :=   l_M_MILEAGE_PAYMENTS -  l_M_TAX_DEDUCTED;
           if l_m_net_allowance < 0
           then
               l_m_net_allowance := 0;
           end if;
           if l_M_BUS_MILES > 10000 then
               l_m_tot_approved_payments := (10000 * l_M_RATE1) +
                                          (
                                           (l_M_BUS_MILES - 10000) * l_M_RATE2
                                          );
           else
               l_m_tot_approved_payments := l_M_BUS_MILES * l_M_RATE1;
           end if;
           l_m_taxable_payment := l_m_net_allowance - l_m_tot_approved_payments;
           if l_m_taxable_payment < 0 then
               l_m_taxable_payment := 0;
           end if;

           l_taxable_pass_payment := l_PASSENGER_PAYMENTS - l_PASSENGER_BUS_MILE_AMT;
           if l_taxable_pass_payment < 0 then
               l_taxable_pass_payment := 0;
           end if;
	   /* bug 7201761 rounded to 2 decimals to avoid HRMC rejection  */
           l_ce := round(l_taxable_pass_payment +  l_c_taxable_payment +
                   l_b_taxable_payment    +  l_m_taxable_payment,2);
--
          hr_utility.trace(' *************l_ce ************' || l_ce);
--          hr_utility.trace_off;

          return l_ce;
      end;

      PROCEDURE insert_sum_records(p_assactid NUMBER)
      IS
      BEGIN
      if to_number(g_param_rep_run) < 2005
      then
         pay_action_information_api.create_action_information(
            p_action_information_id       => l_action_info_id,
            p_action_context_id           => p_assactid,
            p_action_context_type         => 'AAP',
            p_object_version_number       => l_ovn,
            p_effective_date              => fnd_date.canonical_to_date(g_param_benefit_end_date),
            p_source_id                   => NULL,
            p_source_text                 => NULL,
            p_action_information_category => 'GB P11D ASSIGNMENT RESULTA',
            p_action_information1         => per_formula_functions.get_text('A_DESC'),
            p_action_information2         => per_formula_functions.get_number('A_COST'),
            p_action_information3         => per_formula_functions.get_number('A_AMG'),
            p_action_information4         => per_formula_functions.get_number('A_CE'),
            p_action_information5         => per_formula_functions.get_text('B_DESC'),
            p_action_information6         => per_formula_functions.get_number('B_CE'),
            p_action_information7         => per_formula_functions.get_number('B_TNP'),
            p_action_information8         => per_formula_functions.get_number('C_COST'),
            p_action_information9         => per_formula_functions.get_number('C_AMG'),
            p_action_information10        => per_formula_functions.get_number('C_CE'),
            p_action_information11        => per_formula_functions.get_number('D_CE'),
            p_action_information12        => calculate_amap_ce ,
            p_action_information13        => per_formula_functions.get_number('F_TCCE'),
            p_action_information14        => per_formula_functions.get_number('F_TFCE'),
            p_action_information15        => per_formula_functions.get_number('G_CE'),
            p_action_information16        => per_formula_functions.get_number('I_COST'),
            p_action_information17        => per_formula_functions.get_number('I_AMG'),
            p_action_information18        => per_formula_functions.get_number('I_CE'),
            p_action_information19        => per_formula_functions.get_number('J_CE'),
            p_action_information20        => per_formula_functions.get_number('K_COST'),
            p_action_information21        => per_formula_functions.get_number('K_AMG'),
            p_action_information22        => per_formula_functions.get_number('K_CE'),
            p_action_information23        => per_formula_functions.get_text('L_DESC'),
            p_action_information24        => per_formula_functions.get_number('L_COST'),
            p_action_information25        => per_formula_functions.get_number('L_AMG'),
            p_action_information26        => per_formula_functions.get_number('L_CE'),
            p_action_information27        => per_formula_functions.get_text('M_SHARES'),
            p_action_information28        => per_formula_functions.get_number('H_CE1'),
            p_action_information29        => per_formula_functions.get_number('H_COUNT'),
            p_action_information30        => per_formula_functions.get_number('F_COUNT') );

--
         pay_action_information_api.create_action_information(
            p_action_information_id       => l_action_info_id,
            p_action_context_id           => p_assactid,
            p_action_context_type         => 'AAP',
            p_object_version_number       => l_ovn,
            p_effective_date              => fnd_date.canonical_to_date(g_param_benefit_end_date),
            p_source_id                   => NULL,
            p_source_text                 => NULL,
            p_action_information_category => 'GB P11D ASSIGNMENT RESULTB',
            p_action_information1         => per_formula_functions.get_text('N_DESC'),
            p_action_information2         => per_formula_functions.get_number('N_COST'),
            p_action_information3         => per_formula_functions.get_number('N_AMG'),
            p_action_information4         => per_formula_functions.get_number('N_CE'),
            p_action_information5         => per_formula_functions.get_text('NA_DESC'),
            p_action_information6         => per_formula_functions.get_number('NA_COST'),
            p_action_information7         => per_formula_functions.get_number('NA_AMG'),
            p_action_information8         => per_formula_functions.get_number('NA_CE'),
            p_action_information9         => per_formula_functions.get_number('N_TAXPAID'),
            p_action_information10        => per_formula_functions.get_number('O1_COST'),
            p_action_information11        => per_formula_functions.get_number('O1_AMG'),
            p_action_information12        => per_formula_functions.get_number('O1_CE'),
            p_action_information13        => per_formula_functions.get_number('O2_COST'),
            p_action_information14        => per_formula_functions.get_number('O2_AMG'),
            p_action_information15        => per_formula_functions.get_number('O2_CE'),
            p_action_information16        => per_formula_functions.get_text('O_TOI'),
            p_action_information17        => per_formula_functions.get_number('O3_COST'),
            p_action_information18        => per_formula_functions.get_number('O3_AMG'),
            p_action_information19        => per_formula_functions.get_number('O3_CE'),
            p_action_information20        => per_formula_functions.get_number('O4_COST'),
            p_action_information21        => per_formula_functions.get_number('O4_AMG'),
            p_action_information22        => per_formula_functions.get_number('O4_CE'),
            p_action_information23        => per_formula_functions.get_number('O5_COST'),
            p_action_information24        => per_formula_functions.get_number('O5_AMG'),
            p_action_information25        => per_formula_functions.get_number('O5_CE'),
            p_action_information26        => per_formula_functions.get_text('O6_DESC'),
            p_action_information27        => per_formula_functions.get_number('O6_COST'),
            p_action_information28        => per_formula_functions.get_number('O6_AMG'),
            p_action_information29        => per_formula_functions.get_number('O6_CE') );

--
         pay_action_information_api.create_action_information(
            p_action_information_id       => l_action_info_id,
            p_action_context_id           => p_assactid,
            p_action_context_type         => 'AAP',
            p_object_version_number       => l_ovn,
            p_effective_date              => fnd_date.canonical_to_date(g_param_benefit_end_date),
            p_source_id                   => NULL,
            p_source_text                 => NULL,
            p_action_information_category => 'GB P11D ASSIGNMENT RESULTC',
            p_action_information1         => per_formula_functions.get_number('C_BUS_MILES'),
            p_action_information2         => per_formula_functions.get_number('M_BUS_MILES'),
            p_action_information3         => per_formula_functions.get_number('B_BUS_MILES'),
            p_action_information4         => per_formula_functions.get_number('C_RATE1'),
            p_action_information5         => per_formula_functions.get_number('C_RATE2'),
            p_action_information6         => per_formula_functions.get_number('M_RATE1'),
            p_action_information7         => per_formula_functions.get_number('M_RATE2'),
            p_action_information8         => per_formula_functions.get_number('B_RATE1'),
            p_action_information9         => per_formula_functions.get_number('B_RATE2'),
            p_action_information10        => per_formula_functions.get_text('DT_FREE_FUEL_WITHDRAWN'),
            p_action_information11        => per_formula_functions.get_text('FREE_FUEL_REINSTATED'),
            p_action_information12        => per_formula_functions.get_number('C_MILEAGE_PAYMENTS'),
            p_action_information13        => per_formula_functions.get_number('B_MILEAGE_PAYMENTS'),
            p_action_information14        => per_formula_functions.get_number('M_MILEAGE_PAYMENTS'),
            p_action_information15        => per_formula_functions.get_number('MARORS_COUNT'),
            p_action_information16        => per_formula_functions.get_number('C_TAX_DEDUCTED'),
            p_action_information17        => per_formula_functions.get_number('B_TAX_DEDUCTED'),
            p_action_information18        => per_formula_functions.get_number('M_TAX_DEDUCTED'),
            p_action_information19        => per_formula_functions.get_number('PASSENGER_PAYMENTS'),
            p_action_information20        => per_formula_functions.get_number('PASSENGER_BUS_MILES'),
            p_action_information21        => per_formula_functions.get_number('PASSENGER_BUS_MILE_AMT'),
            p_action_information22        => per_formula_functions.get_number('MILEAGE_ALLOWANCE_RELIEF'),
            p_action_information23        => per_formula_functions.get_number('INT_MAX_AMT_OUTSTANDING')
            );
       else
          /* Code for year 04/05 onward */
          pay_action_information_api.create_action_information(
            p_action_information_id       => l_action_info_id,
            p_action_context_id           => p_assactid,
            p_action_context_type         => 'AAP',
            p_object_version_number       => l_ovn,
            p_effective_date              => fnd_date.canonical_to_date(g_param_benefit_end_date),
            p_source_id                   => NULL,
            p_source_text                 => NULL,
            p_action_information_category => 'GB P11D ASSIGNMENT RESULTA',
            p_action_information1         => per_formula_functions.get_text('A_DESC'),
            p_action_information2         => per_formula_functions.get_number('A_COST'),
            p_action_information3         => per_formula_functions.get_number('A_AMG'),
            p_action_information4         => per_formula_functions.get_number('A_CE'),
            p_action_information5         => per_formula_functions.get_text('B_DESC'),
            p_action_information6         => per_formula_functions.get_number('B_CE'),
            p_action_information7         => per_formula_functions.get_number('B_TNP'),
            p_action_information8         => per_formula_functions.get_number('C_COST'),
            p_action_information9         => per_formula_functions.get_number('C_AMG'),
            p_action_information10        => per_formula_functions.get_number('C_CE'),
            p_action_information11        => per_formula_functions.get_number('D_CE'),
            p_action_information12        => calculate_amap_ce ,
            p_action_information13        => per_formula_functions.get_number('F_TCCE'),
            p_action_information14        => per_formula_functions.get_number('F_TFCE'),
            p_action_information15        => per_formula_functions.get_number('G_CE'),
            p_action_information16        => per_formula_functions.get_number('I_COST'),
            p_action_information17        => per_formula_functions.get_number('I_AMG'),
            p_action_information18        => per_formula_functions.get_number('I_CE'),
            p_action_information19        => per_formula_functions.get_number('J_CE'),
            p_action_information20        => per_formula_functions.get_number('K_COST'),
            p_action_information21        => per_formula_functions.get_number('K_AMG'),
            p_action_information22        => per_formula_functions.get_number('K_CE'),
            p_action_information23        => per_formula_functions.get_text('L_DESC'),
            p_action_information24        => per_formula_functions.get_number('L_COST'),
            p_action_information25        => per_formula_functions.get_number('L_AMG'),
            p_action_information26        => per_formula_functions.get_number('L_CE'),
            p_action_information27        => null,
            p_action_information28        => per_formula_functions.get_number('H_CE1'),
            p_action_information29        => per_formula_functions.get_number('H_COUNT'),
            p_action_information30        => per_formula_functions.get_number('F_COUNT') );

            hr_utility.trace('FFFFFF Count : ' || per_formula_functions.get_number('F_COUNT'));
--
         pay_action_information_api.create_action_information(
            p_action_information_id       => l_action_info_id,
            p_action_context_id           => p_assactid,
            p_action_context_type         => 'AAP',
            p_object_version_number       => l_ovn,
            p_effective_date              => fnd_date.canonical_to_date(g_param_benefit_end_date),
            p_source_id                   => NULL,
            p_source_text                 => NULL,
            p_action_information_category => 'GB P11D ASSIGNMENT RESULTB',
            p_action_information1         => per_formula_functions.get_text('M_DESC'),
            p_action_information2         => per_formula_functions.get_number('M_COST'),
            p_action_information3         => per_formula_functions.get_number('M_AMG'),
            p_action_information4         => per_formula_functions.get_number('M_CE'),
            p_action_information5         => per_formula_functions.get_text('MA_DESC'),
            p_action_information6         => per_formula_functions.get_number('MA_COST'),
            p_action_information7         => per_formula_functions.get_number('MA_AMG'),
            p_action_information8         => per_formula_functions.get_number('MA_CE'),
            p_action_information9         => per_formula_functions.get_number('M_TAXPAID'),
            p_action_information10        => per_formula_functions.get_number('N1_COST'),
            p_action_information11        => per_formula_functions.get_number('N1_AMG'),
            p_action_information12        => per_formula_functions.get_number('N1_CE'),
            p_action_information13        => per_formula_functions.get_number('N2_COST'),
            p_action_information14        => per_formula_functions.get_number('N2_AMG'),
            p_action_information15        => per_formula_functions.get_number('N2_CE'),
            p_action_information16        => per_formula_functions.get_text('N_TOI'),
            p_action_information17        => per_formula_functions.get_number('N3_COST'),
            p_action_information18        => per_formula_functions.get_number('N3_AMG'),
            p_action_information19        => per_formula_functions.get_number('N3_CE'),
            p_action_information20        => per_formula_functions.get_number('N4_COST'),
            p_action_information21        => per_formula_functions.get_number('N4_AMG'),
            p_action_information22        => per_formula_functions.get_number('N4_CE'),
            p_action_information23        => per_formula_functions.get_number('N5_COST'),
            p_action_information24        => per_formula_functions.get_number('N5_AMG'),
            p_action_information25        => per_formula_functions.get_number('N5_CE'),
            p_action_information26        => per_formula_functions.get_text('N6_DESC'),
            p_action_information27        => per_formula_functions.get_number('N6_COST'),
            p_action_information28        => per_formula_functions.get_number('N6_AMG'),
            p_action_information29        => per_formula_functions.get_number('N6_CE')
	   ,p_action_information30        => per_formula_functions.get_number('G_FCE'));


          pay_action_information_api.create_action_information(
            p_action_information_id       => l_action_info_id,
            p_action_context_id           => p_assactid,
            p_action_context_type         => 'AAP',
            p_object_version_number       => l_ovn,
            p_effective_date              => fnd_date.canonical_to_date(g_param_benefit_end_date),
            p_source_id                   => NULL,
            p_source_text                 => NULL,
            p_action_information_category => 'GB P11D ASSIGNMENT RESULTC',
            p_action_information1         => per_formula_functions.get_number('C_BUS_MILES'),
            p_action_information2         => per_formula_functions.get_number('M_BUS_MILES'),
            p_action_information3         => per_formula_functions.get_number('B_BUS_MILES'),
            p_action_information4         => per_formula_functions.get_number('C_RATE1'),
            p_action_information5         => per_formula_functions.get_number('C_RATE2'),
            p_action_information6         => per_formula_functions.get_number('M_RATE1'),
            p_action_information7         => per_formula_functions.get_number('M_RATE2'),
            p_action_information8         => per_formula_functions.get_number('B_RATE1'),
            p_action_information9         => per_formula_functions.get_number('B_RATE2'),
            p_action_information10        => null,
            p_action_information11        => null,
            p_action_information12        => per_formula_functions.get_number('C_MILEAGE_PAYMENTS'),
            p_action_information13        => per_formula_functions.get_number('B_MILEAGE_PAYMENTS'),
            p_action_information14        => per_formula_functions.get_number('M_MILEAGE_PAYMENTS'),
            p_action_information15        => per_formula_functions.get_number('MARORS_COUNT'),
            p_action_information16        => per_formula_functions.get_number('C_TAX_DEDUCTED'),
            p_action_information17        => per_formula_functions.get_number('B_TAX_DEDUCTED'),
            p_action_information18        => per_formula_functions.get_number('M_TAX_DEDUCTED'),
            p_action_information19        => per_formula_functions.get_number('PASSENGER_PAYMENTS'),
            p_action_information20        => per_formula_functions.get_number('PASSENGER_BUS_MILES'),
            p_action_information21        => per_formula_functions.get_number('PASSENGER_BUS_MILE_AMT'),
            p_action_information22        => per_formula_functions.get_number('MILEAGE_ALLOWANCE_RELIEF'),
            p_action_information23        => per_formula_functions.get_number('INT_MAX_AMT_OUTSTANDING')
          );
       end if;

      END;
--
      PROCEDURE fetch_values_and_set_globals(p_assignment_action_id NUMBER)
      IS
         l_col1_val                    VARCHAR2(240);
         l_col2_val                    VARCHAR2(240);
         l_col3_val                    VARCHAR2(240);
         l_col4_val                    VARCHAR2(240);
         l_col5_val                    VARCHAR2(240);
         l_col6_val                    VARCHAR2(240);
         l_col7_val                    VARCHAR2(240);
         l_col8_val                    VARCHAR2(240);
         l_col9_val                    VARCHAR2(240);
         l_col10_val                   VARCHAR2(240);
         l_col11_val                   VARCHAR2(240);
         l_col12_val                   VARCHAR2(240);
         l_col13_val                   VARCHAR2(240);
         l_col14_val                   VARCHAR2(240);
         l_col15_val                   VARCHAR2(240);
         l_col16_val                   VARCHAR2(240);
         l_col17_val                   VARCHAR2(240);
         l_col18_val                   VARCHAR2(240);
         l_col19_val                   VARCHAR2(240);
         l_col20_val                   VARCHAR2(240);
         l_col21_val                   VARCHAR2(240);
         l_col22_val                   VARCHAR2(240);
         l_col23_val                   VARCHAR2(240);
         l_col24_val                   VARCHAR2(240);
         l_col25_val                   VARCHAR2(240);
         l_col26_val                   VARCHAR2(240);
         l_col27_val                   VARCHAR2(240);
         l_col28_val                   VARCHAR2(240);
         l_col29_val                   VARCHAR2(240);
         l_col30_val                   VARCHAR2(240);
         l_ret_text                    VARCHAR2(240);

/*****************************************************************
Added the below procedure for the bug fix 8864717.
This procedure updates the global variable g_updated_flag value
to 'Y' if any of the multiple assignments are updated with the
summed up value of all the assignments till now.
*****************************************************************/

     PROCEDURE update_flag_var (p_ass_act_id IN NUMBER)
         IS
            l_payroll_action_id              NUMBER(15);
            l_person_id                      NUMBER(15);
            l_updated                        VARCHAR2(10) := 'N';
            l_count			     NUMBER(15);

        cursor c_get_per_det is
        select paa.payroll_action_id, paaf.person_id
        from pay_assignment_actions paa,
             per_all_assignments_f paaf
        where paa.assignment_action_id = p_ass_act_id
        and paa.assignment_id = paaf.assignment_id;

        cursor c_get_updated_status (c_person_id in number,
                            c_payroll_action_id in number) is
        select 'Y'
        from dual
        where exists (select 'X'
                        from pay_action_information pai,
                        pay_assignment_actions paa,
                        per_all_assignments_f paaf
                        where paaf.person_id = c_person_id
                        and paaf.assignment_id = paa.assignment_id
                        and paa.payroll_action_id = c_payroll_action_id
                        and paa.assignment_action_id = pai.action_context_id
                        and pai.action_information24 = 'Y'
        );

        BEGIN
        hr_utility.TRACE('Entering update_flag_var procedure');
        hr_utility.TRACE('Value of p_ass_act_id: '||p_ass_act_id);
        --l_updated := 'N'
        open c_get_per_det;
        fetch c_get_per_det into l_payroll_action_id, l_person_id;
        hr_utility.TRACE('Value of l_payroll_action_id: '||l_payroll_action_id);
        hr_utility.TRACE('Value of l_person_id: '||l_person_id);
        close c_get_per_det;

        open c_get_updated_status (l_person_id, l_payroll_action_id);
        fetch c_get_updated_status into l_updated;
        hr_utility.TRACE('Value of l_updated: '||l_updated);
        close c_get_updated_status;

        if l_updated =  'Y' then
        hr_utility.TRACE('Inside if condition');
        g_updated_flag := 'Y';
        end if;
        hr_utility.TRACE('Leaving update_flag_var procedure');
      END update_flag_var;

      BEGIN
      /* The code below can be removed when do P11D for year 05/06  */
      if to_number(g_param_rep_run) < 2005
      then
         SELECT action_information1, action_information2, action_information3, action_information4,
                action_information5, action_information6, action_information7, action_information8,
                action_information9, action_information10, action_information11, action_information12,
                action_information13, action_information14, action_information15, action_information16,
                action_information17, action_information18, action_information19, action_information20,
                action_information21, action_information22, action_information23, action_information24,
                action_information25, action_information26, action_information27, action_information28,
                action_information29, action_information30
           INTO l_col1_val, l_col2_val, l_col3_val, l_col4_val,
                l_col5_val, l_col6_val, l_col7_val, l_col8_val,
                l_col9_val, l_col10_val, l_col11_val, l_col12_val,
                l_col13_val, l_col14_val, l_col15_val, l_col16_val,
                l_col17_val, l_col18_val, l_col19_val, l_col20_val,
                l_col21_val, l_col22_val, l_col23_val, l_col24_val,
                l_col25_val, l_col26_val, l_col27_val, l_col28_val,
                l_col29_val, l_col30_val
           FROM pay_action_information
          WHERE action_context_id = p_assignment_action_id AND
          action_information_category = 'GB P11D ASSIGNMENT RESULTA'
          AND   action_context_type = 'AAP';

         l_ret := hr_gb_process_p11d_entries_pkg.check_desc_and_set_global_var('A_DESC', l_col1_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('A_COST', l_col2_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('A_AMG', l_col3_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('A_CE', l_col4_val);
         l_ret := hr_gb_process_p11d_entries_pkg.check_desc_and_set_global_var('B_DESC', l_col5_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('B_CE', l_col6_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('B_TNP', l_col7_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('C_COST', l_col8_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('C_AMG', l_col9_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('C_CE', l_col10_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('D_CE', l_col11_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('E_CE', l_col12_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('F_TCCE', l_col13_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('F_TFCE', l_col14_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('G_CE', l_col15_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('I_COST', l_col16_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('I_AMG', l_col17_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('I_CE', l_col18_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('J_CE', l_col19_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('K_COST', l_col20_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('K_AMG', l_col21_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('K_CE', l_col22_val);
         l_ret := hr_gb_process_p11d_entries_pkg.check_desc_and_set_global_var('L_DESC', l_col23_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('L_COST', l_col24_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('L_AMG', l_col25_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('L_CE', l_col26_val);
         l_ret := hr_gb_process_p11d_entries_pkg.check_desc_and_set_global_var('M_SHARES', l_col27_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('H_CE1', l_col28_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('H_COUNT', l_col29_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('F_COUNT', l_col30_val);

         SELECT action_information1, action_information2, action_information3, action_information4,
                action_information5, action_information6, action_information7, action_information8,
                action_information9, action_information10, action_information11, action_information12,
                action_information13, action_information14, action_information15, action_information16,
                action_information17, action_information18, action_information19, action_information20,
                action_information21, action_information22, action_information23, action_information24,
                action_information25, action_information26, action_information27, action_information28,
                action_information29, action_information30
           INTO l_col1_val, l_col2_val, l_col3_val, l_col4_val,
                l_col5_val, l_col6_val, l_col7_val, l_col8_val,
                l_col9_val, l_col10_val, l_col11_val, l_col12_val,
                l_col13_val, l_col14_val, l_col15_val, l_col16_val,
                l_col17_val, l_col18_val, l_col19_val, l_col20_val,
                l_col21_val, l_col22_val, l_col23_val, l_col24_val,
                l_col25_val, l_col26_val, l_col27_val, l_col28_val,
                l_col29_val, l_col30_val
           FROM pay_action_information
          WHERE action_context_id = p_assignment_action_id AND
                action_information_category ='GB P11D ASSIGNMENT RESULTB'
          AND   action_context_type = 'AAP';

         l_ret := hr_gb_process_p11d_entries_pkg.check_desc_and_set_global_var('N_DESC', l_col1_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('N_COST', l_col2_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('N_AMG', l_col3_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('N_CE', l_col4_val);
         l_ret := hr_gb_process_p11d_entries_pkg.check_desc_and_set_global_var('NA_DESC', l_col5_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('NA_COST', l_col6_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('NA_AMG', l_col7_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('NA_CE', l_col8_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('N_TAXPAID', l_col9_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('O1_COST', l_col10_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('O1_AMG', l_col11_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('O1_CE', l_col12_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('O2_COST', l_col13_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('O2_AMG', l_col14_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('O2_CE', l_col15_val);
         l_ret := hr_gb_process_p11d_entries_pkg.check_desc_and_set_global_var('O_TOI', l_col16_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('O3_COST', l_col17_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('O3_AMG', l_col18_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('O3_CE', l_col19_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('O4_COST', l_col20_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('O4_AMG', l_col21_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('O4_CE', l_col22_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('O5_COST', l_col23_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('O5_AMG', l_col24_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('O5_CE', l_col25_val);
         l_ret := hr_gb_process_p11d_entries_pkg.check_desc_and_set_global_var('O6_DESC', l_col26_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('O6_COST', l_col27_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('O6_AMG', l_col28_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('O6_CE', l_col29_val);

--
         SELECT action_information1, action_information2, action_information3, action_information4,
                action_information5, action_information6, action_information7, action_information8,
                action_information9, action_information10, action_information11, action_information12,
                action_information13, action_information14, action_information15, action_information16,
                action_information17, action_information18, action_information19, action_information20,
                action_information21, action_information22, action_information23, action_information24,
                action_information25, action_information26, action_information27, action_information28,
                action_information29, action_information30
           INTO l_col1_val, l_col2_val, l_col3_val, l_col4_val,
                l_col5_val, l_col6_val, l_col7_val, l_col8_val,
                l_col9_val, l_col10_val, l_col11_val, l_col12_val,
                l_col13_val, l_col14_val, l_col15_val, l_col16_val,
                l_col17_val, l_col18_val, l_col19_val, l_col20_val,
                l_col21_val, l_col22_val, l_col23_val, l_col24_val,
                l_col25_val, l_col26_val, l_col27_val, l_col28_val,
                l_col29_val, l_col30_val
           FROM pay_action_information
          WHERE action_context_id = p_assignment_action_id AND
                action_information_category ='GB P11D ASSIGNMENT RESULTC'
          AND   action_context_type = 'AAP';

         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('C_BUS_MILES', l_col1_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('M_BUS_MILES', l_col2_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('B_BUS_MILES', l_col3_val);
         l_ret_text:= hr_gb_process_p11d_entries_pkg.max_and_set_global_var('C_RATE1','N',l_col4_val);
         l_ret_text:= hr_gb_process_p11d_entries_pkg.max_and_set_global_var('C_RATE2','N',l_col5_val);
         l_ret_text:= hr_gb_process_p11d_entries_pkg.max_and_set_global_var('M_RATE1','N',l_col6_val);
         l_ret_text:= hr_gb_process_p11d_entries_pkg.max_and_set_global_var('M_RATE2','N',l_col7_val);
         l_ret_text:= hr_gb_process_p11d_entries_pkg.max_and_set_global_var('B_RATE1','N',l_col8_val);
         l_ret_text:= hr_gb_process_p11d_entries_pkg.max_and_set_global_var('B_RATE2','N',l_col9_val);

         l_ret_text:= hr_gb_process_p11d_entries_pkg.max_and_set_global_var('DT_FREE_FUEL_WITHDRAWN','D',l_col10_val);
         if l_ret_text = '1'
         then
             l_warn:=1;
             l_val_error_count := l_val_error_count + 1;
             l_val_errors(l_val_error_count).error_text := 'Warning:- Multiple Date Free Fuel Withdrawn Found';
             l_val_errors(l_val_error_count).error_assignment_name := l_assignment_name;
             l_val_errors(l_val_error_count).error_assignment_number := l_assignment_number;
             l_val_errors(l_val_error_count).error_element_name :='Car and Car Fuel 2003-04';
         end if;
         l_ret_text:= hr_gb_process_p11d_entries_pkg.max_and_set_global_var('FREE_FUEL_REINSTATED','T',l_col11_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('C_MILEAGE_PAYMENTS', l_col12_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('B_MILEAGE_PAYMENTS', l_col13_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('M_MILEAGE_PAYMENTS', l_col14_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('MARORS_COUNT', l_col15_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('C_TAX_DEDUCTED', l_col16_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('M_TAX_DEDUCTED', l_col17_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('M_TAX_DEDUCTED', l_col18_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('PASSENGER_PAYMENTS', l_col19_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('PASSENGER_BUS_MILES', l_col20_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('PASSENGER_BUS_MILE_AMT', l_col21_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('MILEAGE_ALLOWANCE_RELIEF', l_col22_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('INT_MAX_AMT_OUTSTANDING', l_col23_val);
       else

--Added the below procedure call for the bug fix 8864717.
update_flag_var(p_assignment_action_id);


        /* Code for year 04/05 onwards */
         SELECT action_information1, action_information2, action_information3, action_information4,
                action_information5, action_information6, action_information7, action_information8,
                action_information9, action_information10, action_information11, action_information12,
                action_information13, action_information14, action_information15, action_information16,
                action_information17, action_information18, action_information19, action_information20,
                action_information21, action_information22, action_information23, action_information24,
                action_information25, action_information26, action_information28, action_information29,
                action_information30
           INTO l_col1_val, l_col2_val, l_col3_val, l_col4_val,
                l_col5_val, l_col6_val, l_col7_val, l_col8_val,
                l_col9_val, l_col10_val, l_col11_val, l_col12_val,
                l_col13_val, l_col14_val, l_col15_val, l_col16_val,
                l_col17_val, l_col18_val, l_col19_val, l_col20_val,
                l_col21_val, l_col22_val, l_col23_val, l_col24_val,
                l_col25_val, l_col26_val, l_col28_val, l_col29_val,
                l_col30_val
           FROM pay_action_information
          WHERE action_context_id = p_assignment_action_id AND
          action_information_category = 'GB P11D ASSIGNMENT RESULTA'
          AND   action_context_type = 'AAP';

         l_ret := hr_gb_process_p11d_entries_pkg.check_desc_and_set_global_var('A_DESC', l_col1_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('A_COST', l_col2_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('A_AMG', l_col3_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('A_CE', l_col4_val);
         l_ret := hr_gb_process_p11d_entries_pkg.check_desc_and_set_global_var('B_DESC', l_col5_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('B_CE', l_col6_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('B_TNP', l_col7_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('C_COST', l_col8_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('C_AMG', l_col9_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('C_CE', l_col10_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('D_CE', l_col11_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('E_CE', l_col12_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('F_TCCE', l_col13_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('F_TFCE', l_col14_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('G_CE', l_col15_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('I_COST', l_col16_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('I_AMG', l_col17_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('I_CE', l_col18_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('J_CE', l_col19_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('K_COST', l_col20_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('K_AMG', l_col21_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('K_CE', l_col22_val);
         l_ret := hr_gb_process_p11d_entries_pkg.check_desc_and_set_global_var('L_DESC', l_col23_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('L_COST', l_col24_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('L_AMG', l_col25_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('L_CE', l_col26_val);
         /* l_ret := hr_gb_process_p11d_entries_pkg.check_desc_and_set_global_var('M_SHARES', l_col27_val); */
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('H_CE1', l_col28_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('H_COUNT', l_col29_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('F_COUNT', l_col30_val);

         SELECT action_information1, action_information2, action_information3, action_information4,
                action_information5, action_information6, action_information7, action_information8,
                action_information9, action_information10, action_information11, action_information12,
                action_information13, action_information14, action_information15, action_information16,
                action_information17, action_information18, action_information19, action_information20,
                action_information21, action_information22, action_information23, action_information24,
                action_information25, action_information26, action_information27, action_information28,
                action_information29, action_information30
           INTO l_col1_val, l_col2_val, l_col3_val, l_col4_val,
                l_col5_val, l_col6_val, l_col7_val, l_col8_val,
                l_col9_val, l_col10_val, l_col11_val, l_col12_val,
                l_col13_val, l_col14_val, l_col15_val, l_col16_val,
                l_col17_val, l_col18_val, l_col19_val, l_col20_val,
                l_col21_val, l_col22_val, l_col23_val, l_col24_val,
                l_col25_val, l_col26_val, l_col27_val, l_col28_val,
                l_col29_val, l_col30_val
           FROM pay_action_information
          WHERE action_context_id = p_assignment_action_id AND
                action_information_category ='GB P11D ASSIGNMENT RESULTB'
          AND   action_context_type = 'AAP';

         l_ret := hr_gb_process_p11d_entries_pkg.check_desc_and_set_global_var('M_DESC', l_col1_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('M_COST', l_col2_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('M_AMG', l_col3_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('M_CE', l_col4_val);
         l_ret := hr_gb_process_p11d_entries_pkg.check_desc_and_set_global_var('MA_DESC', l_col5_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('MA_COST', l_col6_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('MA_AMG', l_col7_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('MA_CE', l_col8_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('M_TAXPAID', l_col9_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('N1_COST', l_col10_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('N1_AMG', l_col11_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('N1_CE', l_col12_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('N2_COST', l_col13_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('N2_AMG', l_col14_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('N2_CE', l_col15_val);
         l_ret := hr_gb_process_p11d_entries_pkg.check_desc_and_set_global_var('N_TOI', l_col16_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('N3_COST', l_col17_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('N3_AMG', l_col18_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('N3_CE', l_col19_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('N4_COST', l_col20_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('N4_AMG', l_col21_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('N4_CE', l_col22_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('N5_COST', l_col23_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('N5_AMG', l_col24_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('N5_CE', l_col25_val);
         l_ret := hr_gb_process_p11d_entries_pkg.check_desc_and_set_global_var('N6_DESC', l_col26_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('N6_COST', l_col27_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('N6_AMG', l_col28_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('N6_CE', l_col29_val);
	 l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('G_FCE', l_col30_val);

--
         SELECT action_information1, action_information2, action_information3, action_information4,
                action_information5, action_information6, action_information7, action_information8,
                action_information9, action_information12,
                action_information13, action_information14, action_information15, action_information16,
                action_information17, action_information18, action_information19, action_information20,
                action_information21, action_information22, action_information23
           INTO l_col1_val, l_col2_val, l_col3_val, l_col4_val,
                l_col5_val, l_col6_val, l_col7_val, l_col8_val,
                l_col9_val, l_col12_val,
                l_col13_val, l_col14_val, l_col15_val, l_col16_val,
                l_col17_val, l_col18_val, l_col19_val, l_col20_val,
                l_col21_val, l_col22_val, l_col23_val
           FROM pay_action_information
          WHERE action_context_id = p_assignment_action_id AND
                action_information_category ='GB P11D ASSIGNMENT RESULTC'
          AND   action_context_type = 'AAP';

         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('C_BUS_MILES', l_col1_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('M_BUS_MILES', l_col2_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('B_BUS_MILES', l_col3_val);
         l_ret_text:= hr_gb_process_p11d_entries_pkg.max_and_set_global_var('C_RATE1','N',l_col4_val);
         l_ret_text:= hr_gb_process_p11d_entries_pkg.max_and_set_global_var('C_RATE2','N',l_col5_val);
         l_ret_text:= hr_gb_process_p11d_entries_pkg.max_and_set_global_var('M_RATE1','N',l_col6_val);
         l_ret_text:= hr_gb_process_p11d_entries_pkg.max_and_set_global_var('M_RATE2','N',l_col7_val);
         l_ret_text:= hr_gb_process_p11d_entries_pkg.max_and_set_global_var('B_RATE1','N',l_col8_val);
         l_ret_text:= hr_gb_process_p11d_entries_pkg.max_and_set_global_var('B_RATE2','N',l_col9_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('C_MILEAGE_PAYMENTS', l_col12_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('B_MILEAGE_PAYMENTS', l_col13_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('M_MILEAGE_PAYMENTS', l_col14_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('MARORS_COUNT', l_col15_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('C_TAX_DEDUCTED', l_col16_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('B_TAX_DEDUCTED', l_col17_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('M_TAX_DEDUCTED', l_col18_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('PASSENGER_PAYMENTS', l_col19_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('PASSENGER_BUS_MILES', l_col20_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('PASSENGER_BUS_MILE_AMT', l_col21_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('MILEAGE_ALLOWANCE_RELIEF', l_col22_val);
         l_ret := hr_gb_process_p11d_entries_pkg.sum_and_set_global_var('INT_MAX_AMT_OUTSTANDING', l_col23_val);
       end if;

      END;

      PROCEDURE update_value_act_info_id(p_action_info_id NUMBER,
                                         p_action_info_category VARCHAR2,
                                         p_ovn IN OUT nocopy NUMBER)
      IS
      BEGIN
       /* The code below can be removed when do P11D for year 05/06  */
       if to_number(g_param_rep_run) < 2005
       then
         IF p_action_info_category = 'GB P11D ASSIGNMENT RESULTA'
         THEN
            pay_action_information_api.update_action_information(
               p_action_information_id       => p_action_info_id,
               p_object_version_number       => p_ovn,
               p_action_information1         => per_formula_functions.get_text('A_DESC'),
               p_action_information2         => per_formula_functions.get_number('A_COST'),
               p_action_information3         => per_formula_functions.get_number('A_AMG'),
               p_action_information4         => per_formula_functions.get_number('A_CE'),
               p_action_information5         => per_formula_functions.get_text('B_DESC'),
               p_action_information6         => per_formula_functions.get_number('B_CE'),
               p_action_information7         => per_formula_functions.get_number('B_TNP'),
               p_action_information8         => per_formula_functions.get_number('C_COST'),
               p_action_information9         => per_formula_functions.get_number('C_AMG'),
               p_action_information10        => per_formula_functions.get_number('C_CE'),
               p_action_information11        => per_formula_functions.get_number('D_CE'),
               p_action_information12        => calculate_amap_ce ,
               p_action_information13        => per_formula_functions.get_number('F_TCCE'),
               p_action_information14        => per_formula_functions.get_number('F_TFCE'),
               p_action_information15        => per_formula_functions.get_number('G_CE'),
               p_action_information16        => per_formula_functions.get_number('I_COST'),
               p_action_information17        => per_formula_functions.get_number('I_AMG'),
               p_action_information18        => per_formula_functions.get_number('I_CE'),
               p_action_information19        => per_formula_functions.get_number('J_CE'),
               p_action_information20        => per_formula_functions.get_number('K_COST'),
               p_action_information21        => per_formula_functions.get_number('K_AMG'),
               p_action_information22        => per_formula_functions.get_number('K_CE'),
               p_action_information23        => per_formula_functions.get_text('L_DESC'),
               p_action_information24        => per_formula_functions.get_number('L_COST'),
               p_action_information25        => per_formula_functions.get_number('L_AMG'),
               p_action_information26        => per_formula_functions.get_number('L_CE'),
               p_action_information27        => per_formula_functions.get_text('M_SHARES'),
               p_action_information28        => per_formula_functions.get_number('H_CE1'),
               p_action_information29        => per_formula_functions.get_number('H_COUNT'),
               p_action_information30        => per_formula_functions.get_number('F_COUNT') );
         END IF;

         IF p_action_info_category = 'GB P11D ASSIGNMENT RESULTB'
         THEN
            pay_action_information_api.update_action_information(
               p_action_information_id       => p_action_info_id,
               p_object_version_number       => p_ovn,
               p_action_information1         => per_formula_functions.get_text('N_DESC'),
               p_action_information2         => per_formula_functions.get_number('N_COST'),
               p_action_information3         => per_formula_functions.get_number('N_AMG'),
               p_action_information4         => per_formula_functions.get_number('N_CE'),
               p_action_information5         => per_formula_functions.get_text('NA_DESC'),
               p_action_information6         => per_formula_functions.get_number('NA_COST'),
               p_action_information7         => per_formula_functions.get_number('NA_AMG'),
               p_action_information8         => per_formula_functions.get_number('NA_CE'),
               p_action_information9         => per_formula_functions.get_number('N_TAXPAID'),
               p_action_information10        => per_formula_functions.get_number('O1_COST'),
               p_action_information11        => per_formula_functions.get_number('O1_AMG'),
               p_action_information12        => per_formula_functions.get_number('O1_CE'),
               p_action_information13        => per_formula_functions.get_number('O2_COST'),
               p_action_information14        => per_formula_functions.get_number('O2_AMG'),
               p_action_information15        => per_formula_functions.get_number('O2_CE'),
               p_action_information16        => per_formula_functions.get_text('O_TOI'),
               p_action_information17        => per_formula_functions.get_number('O3_COST'),
               p_action_information18        => per_formula_functions.get_number('O3_AMG'),
               p_action_information19        => per_formula_functions.get_number('O3_CE'),
               p_action_information20        => per_formula_functions.get_number('O4_COST'),
               p_action_information21        => per_formula_functions.get_number('O4_AMG'),
               p_action_information22        => per_formula_functions.get_number('O4_CE'),
               p_action_information23        => per_formula_functions.get_number('O5_COST'),
               p_action_information24        => per_formula_functions.get_number('O5_AMG'),
               p_action_information25        => per_formula_functions.get_number('O5_CE'),
               p_action_information26        => per_formula_functions.get_text('O6_DESC'),
               p_action_information27        => per_formula_functions.get_number('O6_COST'),
               p_action_information28        => per_formula_functions.get_number('O6_AMG'),
               p_action_information29        => per_formula_functions.get_number('O6_CE') );
         END IF;

         IF p_action_info_category = 'GB P11D ASSIGNMENT RESULTC'
         THEN
            pay_action_information_api.update_action_information(
               p_action_information_id       => p_action_info_id,
               p_object_version_number       => p_ovn,
               p_action_information1         => per_formula_functions.get_number('C_BUS_MILES'),
               p_action_information2         => per_formula_functions.get_number('M_BUS_MILES'),
               p_action_information3         => per_formula_functions.get_number('B_BUS_MILES'),
               p_action_information4         => per_formula_functions.get_number('C_RATE1'),
               p_action_information5         => per_formula_functions.get_number('C_RATE2'),
               p_action_information6         => per_formula_functions.get_number('M_RATE1'),
               p_action_information7         => per_formula_functions.get_number('M_RATE2'),
               p_action_information8         => per_formula_functions.get_number('B_RATE1'),
               p_action_information9         => per_formula_functions.get_number('B_RATE2'),
               p_action_information10        => per_formula_functions.get_text('DT_FREE_FUEL_WITHDRAWN'),
               p_action_information11        => per_formula_functions.get_text('FREE_FUEL_REINSTATED'),
               p_action_information12        => per_formula_functions.get_number('C_MILEAGE_PAYMENTS'),
               p_action_information13        => per_formula_functions.get_number('B_MILEAGE_PAYMENTS'),
               p_action_information14        => per_formula_functions.get_number('M_MILEAGE_PAYMENTS'),
               p_action_information15        => per_formula_functions.get_number('MARORS_COUNT'),
               p_action_information16        => per_formula_functions.get_number('C_TAX_DEDUCTED'),
               p_action_information17        => per_formula_functions.get_number('B_TAX_DEDUCTED'),
               p_action_information18        => per_formula_functions.get_number('M_TAX_DEDUCTED'),
               p_action_information19        => per_formula_functions.get_number('PASSENGER_PAYMENTS'),
               p_action_information20        => per_formula_functions.get_number('PASSENGER_BUS_MILES'),
               p_action_information21        => per_formula_functions.get_number('PASSENGER_BUS_MILE_AMT'),
               p_action_information22        => per_formula_functions.get_number('MILEAGE_ALLOWANCE_RELIEF'),
               p_action_information23        => per_formula_functions.get_number('INT_MAX_AMT_OUTSTANDING')
               );
         END IF;
       else
       /* Code for year 04/05 onwards */
           IF p_action_info_category = 'GB P11D ASSIGNMENT RESULTA'
         THEN
            pay_action_information_api.update_action_information(
               p_action_information_id       => p_action_info_id,
               p_object_version_number       => p_ovn,
               p_action_information1         => per_formula_functions.get_text('A_DESC'),
               p_action_information2         => per_formula_functions.get_number('A_COST'),
               p_action_information3         => per_formula_functions.get_number('A_AMG'),
               p_action_information4         => per_formula_functions.get_number('A_CE'),
               p_action_information5         => per_formula_functions.get_text('B_DESC'),
               p_action_information6         => per_formula_functions.get_number('B_CE'),
               p_action_information7         => per_formula_functions.get_number('B_TNP'),
               p_action_information8         => per_formula_functions.get_number('C_COST'),
               p_action_information9         => per_formula_functions.get_number('C_AMG'),
               p_action_information10        => per_formula_functions.get_number('C_CE'),
               p_action_information11        => per_formula_functions.get_number('D_CE'),
               p_action_information12        => calculate_amap_ce ,
               p_action_information13        => per_formula_functions.get_number('F_TCCE'),
               p_action_information14        => per_formula_functions.get_number('F_TFCE'),
               p_action_information15        => per_formula_functions.get_number('G_CE'),
               p_action_information16        => per_formula_functions.get_number('I_COST'),
               p_action_information17        => per_formula_functions.get_number('I_AMG'),
               p_action_information18        => per_formula_functions.get_number('I_CE'),
               p_action_information19        => per_formula_functions.get_number('J_CE'),
               p_action_information20        => per_formula_functions.get_number('K_COST'),
               p_action_information21        => per_formula_functions.get_number('K_AMG'),
               p_action_information22        => per_formula_functions.get_number('K_CE'),
               p_action_information23        => per_formula_functions.get_text('L_DESC'),
               p_action_information24        => per_formula_functions.get_number('L_COST'),
               p_action_information25        => per_formula_functions.get_number('L_AMG'),
               p_action_information26        => per_formula_functions.get_number('L_CE'),
               p_action_information27        => null,
               p_action_information28        => per_formula_functions.get_number('H_CE1'),
               p_action_information29        => per_formula_functions.get_number('H_COUNT'),
               p_action_information30        => per_formula_functions.get_number('F_COUNT') );
         END IF;

         IF p_action_info_category = 'GB P11D ASSIGNMENT RESULTB'
         THEN
            pay_action_information_api.update_action_information(
               p_action_information_id       => p_action_info_id,
               p_object_version_number       => p_ovn,
               p_action_information1         => per_formula_functions.get_text('M_DESC'),
               p_action_information2         => per_formula_functions.get_number('M_COST'),
               p_action_information3         => per_formula_functions.get_number('M_AMG'),
               p_action_information4         => per_formula_functions.get_number('M_CE'),
               p_action_information5         => per_formula_functions.get_text('MA_DESC'),
               p_action_information6         => per_formula_functions.get_number('MA_COST'),
               p_action_information7         => per_formula_functions.get_number('MA_AMG'),
               p_action_information8         => per_formula_functions.get_number('MA_CE'),
               p_action_information9         => per_formula_functions.get_number('M_TAXPAID'),
               p_action_information10        => per_formula_functions.get_number('N1_COST'),
               p_action_information11        => per_formula_functions.get_number('N1_AMG'),
               p_action_information12        => per_formula_functions.get_number('N1_CE'),
               p_action_information13        => per_formula_functions.get_number('N2_COST'),
               p_action_information14        => per_formula_functions.get_number('N2_AMG'),
               p_action_information15        => per_formula_functions.get_number('N2_CE'),
               p_action_information16        => per_formula_functions.get_text('N_TOI'),
               p_action_information17        => per_formula_functions.get_number('N3_COST'),
               p_action_information18        => per_formula_functions.get_number('N3_AMG'),
               p_action_information19        => per_formula_functions.get_number('N3_CE'),
               p_action_information20        => per_formula_functions.get_number('N4_COST'),
               p_action_information21        => per_formula_functions.get_number('N4_AMG'),
               p_action_information22        => per_formula_functions.get_number('N4_CE'),
               p_action_information23        => per_formula_functions.get_number('N5_COST'),
               p_action_information24        => per_formula_functions.get_number('N5_AMG'),
               p_action_information25        => per_formula_functions.get_number('N5_CE'),
               p_action_information26        => per_formula_functions.get_text('N6_DESC'),
               p_action_information27        => per_formula_functions.get_number('N6_COST'),
               p_action_information28        => per_formula_functions.get_number('N6_AMG'),
               p_action_information29        => per_formula_functions.get_number('N6_CE')
	      ,p_action_information30        => per_formula_functions.get_number('G_FCE'));

         END IF;

         IF p_action_info_category = 'GB P11D ASSIGNMENT RESULTC'
         THEN
            pay_action_information_api.update_action_information(
               p_action_information_id       => p_action_info_id,
               p_object_version_number       => p_ovn,
               p_action_information1         => per_formula_functions.get_number('C_BUS_MILES'),
               p_action_information2         => per_formula_functions.get_number('M_BUS_MILES'),
               p_action_information3         => per_formula_functions.get_number('B_BUS_MILES'),
               p_action_information4         => per_formula_functions.get_number('C_RATE1'),
               p_action_information5         => per_formula_functions.get_number('C_RATE2'),
               p_action_information6         => per_formula_functions.get_number('M_RATE1'),
               p_action_information7         => per_formula_functions.get_number('M_RATE2'),
               p_action_information8         => per_formula_functions.get_number('B_RATE1'),
               p_action_information9         => per_formula_functions.get_number('B_RATE2'),
               p_action_information10        => null,
               p_action_information11        => null,
               p_action_information12        => per_formula_functions.get_number('C_MILEAGE_PAYMENTS'),
               p_action_information13        => per_formula_functions.get_number('B_MILEAGE_PAYMENTS'),
               p_action_information14        => per_formula_functions.get_number('M_MILEAGE_PAYMENTS'),
               p_action_information15        => per_formula_functions.get_number('MARORS_COUNT'),
               p_action_information16        => per_formula_functions.get_number('C_TAX_DEDUCTED'),
               p_action_information17        => per_formula_functions.get_number('B_TAX_DEDUCTED'),
               p_action_information18        => per_formula_functions.get_number('M_TAX_DEDUCTED'),
               p_action_information19        => per_formula_functions.get_number('PASSENGER_PAYMENTS'),
               p_action_information20        => per_formula_functions.get_number('PASSENGER_BUS_MILES'),
               p_action_information21        => per_formula_functions.get_number('PASSENGER_BUS_MILE_AMT'),
               p_action_information22        => per_formula_functions.get_number('MILEAGE_ALLOWANCE_RELIEF'),
               p_action_information23        => per_formula_functions.get_number('INT_MAX_AMT_OUTSTANDING'),
	       p_action_information24        => 'Y'  --Updating the below parameter value for the bug fix 8864717.
               );
         END IF;
       end if;
      END;

      PROCEDURE update_values(p_assignment_action_id NUMBER)
      IS
         l_ovn                         NUMBER;
         l_action_info_id              NUMBER(15);

         FUNCTION get_action_info_id(p_action_info_category VARCHAR2, p_ovn OUT nocopy NUMBER)
            RETURN NUMBER
         IS
            l_action_info_id              NUMBER(15);
         BEGIN
            SELECT action_information_id, object_version_number
              INTO l_action_info_id, p_ovn
              FROM pay_action_information
             WHERE action_context_id = p_assignment_action_id AND
                   action_information_category = p_action_info_category;
            RETURN l_action_info_id;
         END;
      BEGIN
         l_action_info_id := get_action_info_id('GB P11D ASSIGNMENT RESULTA', l_ovn);
         update_value_act_info_id(l_action_info_id, 'GB P11D ASSIGNMENT RESULTA', l_ovn);

         l_action_info_id := get_action_info_id('GB P11D ASSIGNMENT RESULTB', l_ovn);
         update_value_act_info_id(l_action_info_id, 'GB P11D ASSIGNMENT RESULTB', l_ovn);

         l_action_info_id := get_action_info_id('GB P11D ASSIGNMENT RESULTC', l_ovn);
         update_value_act_info_id(l_action_info_id, 'GB P11D ASSIGNMENT RESULTC', l_ovn);
      END;

      PROCEDURE validate_values
      IS
         PROCEDURE read_validate_log_desc(p_var_name VARCHAR2)
         IS
            l_var_value                   VARCHAR2(150);
         BEGIN
            l_var_value := per_formula_functions.get_text(p_var_name);
            IF UPPER(l_var_value) = 'MULTIPLE'
            THEN
              /* The code below can be removed when do P11D for year 05/06  */
              if to_number(g_param_rep_run) < 2005
              then
                 IF p_var_name = 'M_SHARES'
                 THEN
                    pay_core_utils.push_message(800, 'HR_GB_78059_INCONSISTENT_VAL', 'F');
                    fnd_message.set_name('PER', 'HR_GB_78059_INCONSISTENT_VAL');
                    l_val_error_count := l_val_error_count + 1;
                    l_val_errors(l_val_error_count).error_text := fnd_message.get;
                    l_val_errors(l_val_error_count).error_assignment_name := l_assignment_name;
                    l_val_errors(l_val_error_count).error_assignment_number := l_assignment_number;
                    l_val_errors(l_val_error_count).error_element_name :='P11D Shares';
                 END IF;

                 IF p_var_name = 'O_TOI'
                 THEN
                  pay_core_utils.push_message(800, 'HR_GB_78060_TOI_INCONSISTENT', 'F');
                    fnd_message.set_name('PER', 'HR_GB_78060_TOI_INCONSISTENT');
                    l_val_error_count := l_val_error_count + 1;
                    l_val_errors(l_val_error_count).error_text := fnd_message.get;
                    l_val_errors(l_val_error_count).error_assignment_name := l_assignment_name;
                    l_val_errors(l_val_error_count).error_assignment_number := l_assignment_number;
                    l_val_errors(l_val_error_count).error_element_name :='Expenses Payments';
                 END IF;
                 l_error := '1';
                 l_error_assignment := TRUE;
              else  /* code for year 04/05 onwards */
                 IF p_var_name = 'N_TOI'
                 THEN
                    pay_core_utils.push_message(800, 'HR_GB_78060_TOI_INCONSISTENT', 'F');
                 END IF;
                 l_error := '1';
                 l_error_assignment := TRUE;
              end if;
            END IF;
         END;

         PROCEDURE read_validate_log(p_var_name VARCHAR2)
         IS
            l_var_value                   NUMBER;
         BEGIN
            l_var_value := per_formula_functions.get_number(p_var_name);
            IF p_var_name = 'F_COUNT'
            THEN
               IF l_var_value > 50
               THEN
                  pay_core_utils.push_message(800, 'HR_GB_78061_CAR_NUM_ERROR', 'F');
                  l_error := '1';
                  l_error_assignment := TRUE;
               END IF;
               IF l_var_value > 2
               THEN
                  pay_core_utils.push_message(800, 'PER_GB_P11D_78058_ASG_ERR_MSG', 'W');
                  pay_core_utils.push_token('TEXT', 'Car and Car Fuel 2003_04: This employee has more than 2 cars');
                  l_warn := '1';
               END IF;
            END IF;
            IF p_var_name = 'MARORS_COUNT'
            THEN
               IF l_var_value > 1
               THEN
                  pay_core_utils.push_message(800, 'HR_GB_78081_MARORS_NUM_ERROR', 'F');
                  l_error := '1';
                  l_error_assignment := TRUE;
               END IF;
            END IF;
         END;
--
         PROCEDURE read_validate_min_max(p_var_name VARCHAR2,
                                         p_min_value number,
                                         p_max_value number,
                                         p_element_name VARCHAR2)
         IS
            l_var_value                   NUMBER;
         BEGIN
            l_var_value := per_formula_functions.get_number(p_var_name);
            If l_var_value < p_min_value then
                pay_core_utils.push_message(800, 'HR_GB_78083_MIN_VALUE_ERROR', 'F');
                pay_core_utils.push_token('ELEMENT_NAME', p_element_name);
                pay_core_utils.push_token('VALUE', p_min_value);
                l_error := '1';
                l_error_assignment := TRUE;
            elsif l_var_value > p_max_value then
                pay_core_utils.push_message(800, 'HR_GB_78082_MAX_VALUE_ERROR', 'F');
                pay_core_utils.push_token('ELEMENT_NAME', p_element_name);
                pay_core_utils.push_token('VALUE', p_max_value);
                l_error := '1';
                l_error_assignment := TRUE;
            end if;
          END;
--
      BEGIN
         read_validate_log('F_COUNT');
         /* The code below can be removed when do P11D for year 05/06  */
         if to_number(g_param_rep_run) < 2005 then
            read_validate_log_desc('M_SHARES');
            read_validate_log_desc('O_TOI');
         else /* code for year 04/05 onwards */
            read_validate_log_desc('N_TOI');
         end if;
         read_validate_min_max('A_COST',0,999999999.99,'Assets Transferred');
         read_validate_min_max('A_AMG',0,999999999.99,'Assets Transferred');
         read_validate_min_max('A_CE',0,999999999.99,'Assets Transferred');
         read_validate_min_max('B_CE',0,999999999.99,'Payments Made For Emp');
         read_validate_min_max('B_TNP',0,999999999.99,'Payments Made For Emp');
         read_validate_min_max('C_COST',0,999999999.99,'Vouchers or Credit Cards');
         read_validate_min_max('C_AMG',0,999999999.99,'Vouchers or Credit Cards');
         read_validate_min_max('C_CE',0,999999999.99,'Vouchers or Credit Cards');

         read_validate_min_max('D_CE',0,999999999.99,'Living Accommodation');

         read_validate_min_max('E_CE',0,999999.51,'Mileage Allowance and PPayment');

         read_validate_min_max('F_TCCE',0,999999999.99,'Car and Car Fuel 2003_04');
         read_validate_min_max('F_TFCE',0,999999999.99,'Car and Car Fuel 2003_04');

         read_validate_min_max('G_CE',0,999999999.99,'Vans 2002_03');

         read_validate_min_max('I_COST',0,999999999.99,'Pvt Med Treatment or Insurance');
         read_validate_min_max('I_AMG',0,999999999.99,'Pvt Med Treatment or Insurance');
         read_validate_min_max('I_CE',0,999999999.99,'Pvt Med Treatment or Insurance');

         read_validate_min_max('J_CE',0,999999999.99,'Relocation Expenses');

         read_validate_min_max('K_COST',0,999999999.99,'Services Supplied');
         read_validate_min_max('K_AMG',0,999999999.99,'Services Supplied');
         read_validate_min_max('K_CE',0,999999999.99,'Services Supplied');

         read_validate_min_max('L_COST',0,999999999.99,'Assets at Emp Disposal');
         read_validate_min_max('L_AMG',0,999999999.99,'Assets at Emp Disposal');
         read_validate_min_max('L_CE',0,999999999.99,'Assets at Emp Disposal');

       /* The code below can be removed when do P11D for year 05/06  */
       if to_number(g_param_rep_run) < 2005
       then
         read_validate_min_max('N_COST',0,999999999.99,'Other Items Non 1A');
         read_validate_min_max('N_AMG',0,999999999.99,'Other Items Non 1A');
         read_validate_min_max('N_CE',0,999999999.99,'Other Items Non 1A');

         read_validate_min_max('NA_COST',0,999999999.99,'Other Items');
         read_validate_min_max('NA_AMG',0,999999999.99,'Other Items');
         read_validate_min_max('NA_CE',0,999999999.99,'Other Items');
         read_validate_min_max('N_TAXPAID',0,999999999.99,'Other Items Non 1A');

         read_validate_min_max('O1_COST',0,999999999.99,'Expenses Payments');
         read_validate_min_max('O1_AMG',0,999999999.99,'Expenses Payments');
         read_validate_min_max('O1_CE',0,999999999.99,'Expenses Payments');

         read_validate_min_max('O2_COST',0,999999999.99,'Expenses Payments');
         read_validate_min_max('O2_AMG',0,999999999.99,'Expenses Payments');
         read_validate_min_max('O2_CE',0,999999999.99,'Expenses Payments');

         read_validate_min_max('O3_COST',0,999999999.99,'Expenses Payments');
         read_validate_min_max('O3_AMG',0,999999999.99,'Expenses Payments');
         read_validate_min_max('O3_CE',0,999999999.99,'Expenses Payments');

         read_validate_min_max('O4COST',0,999999999.99,'Expenses Payments');
         read_validate_min_max('O4_AMG',0,999999999.99,'Expenses Payments');
         read_validate_min_max('O4_CE',0,999999999.99,'Expenses Payments');

         read_validate_min_max('O5_COST',0,999999999.99,'Expenses Payments');
         read_validate_min_max('O5_AMG',0,999999999.99,'Expenses Payments');
         read_validate_min_max('O5_CE',0,999999999.99,'Expenses Payments');

         read_validate_min_max('O6_COST',0,999999999.99,'Expenses Payments');
         read_validate_min_max('O6_AMG',0,999999999.99,'Expenses Payments');
         read_validate_min_max('O6_CE',0,999999999.99,'Expenses Payments');
       else /* code for year 04/05 onwards */
          read_validate_min_max('M_COST',0,999999999.99,'Other Items Non 1A');
         read_validate_min_max('M_AMG',0,999999999.99,'Other Items Non 1A');
         read_validate_min_max('M_CE',0,999999999.99,'Other Items Non 1A');

         read_validate_min_max('MA_COST',0,999999999.99,'Other Items');
         read_validate_min_max('MA_AMG',0,999999999.99,'Other Items');
         read_validate_min_max('MA_CE',0,999999999.99,'Other Items');
         read_validate_min_max('M_TAXPAID',0,999999999.99,'Other Items Non 1A');

         read_validate_min_max('N1_COST',0,999999999.99,'Expenses Payments');
         read_validate_min_max('N1_AMG',0,999999999.99,'Expenses Payments');
         read_validate_min_max('N1_CE',0,999999999.99,'Expenses Payments');

         read_validate_min_max('N2_COST',0,999999999.99,'Expenses Payments');
         read_validate_min_max('N2_AMG',0,999999999.99,'Expenses Payments');
         read_validate_min_max('N2_CE',0,999999999.99,'Expenses Payments');

         read_validate_min_max('N3_COST',0,999999999.99,'Expenses Payments');
         read_validate_min_max('N3_AMG',0,999999999.99,'Expenses Payments');
         read_validate_min_max('N3_CE',0,999999999.99,'Expenses Payments');

         read_validate_min_max('N4COST',0,999999999.99,'Expenses Payments');
         read_validate_min_max('N4_AMG',0,999999999.99,'Expenses Payments');
         read_validate_min_max('N4_CE',0,999999999.99,'Expenses Payments');

         read_validate_min_max('N5_COST',0,999999999.99,'Expenses Payments');
         read_validate_min_max('N5_AMG',0,999999999.99,'Expenses Payments');
         read_validate_min_max('N5_CE',0,999999999.99,'Expenses Payments');

         read_validate_min_max('N6_COST',0,999999999.99,'Expenses Payments');
         read_validate_min_max('N6_AMG',0,999999999.99,'Expenses Payments');
         read_validate_min_max('N6_CE',0,999999999.99,'Expenses Payments');
       end if;
         read_validate_min_max('MILEAGE_ALLOWANCE_RELIEF',-999999.99,0,'MARORS');
         -- checking max amount outstanding for Int free and low int loans
         -- will rasie just a warning for this
            If per_formula_functions.get_number('INT_MAX_AMT_OUTSTANDING') < l_loan_threshold then
                pay_core_utils.push_message(800, 'HR_GB_78083_MIN_VALUE_ERROR', 'W');
                pay_core_utils.push_token('ELEMENT_NAME', 'Int Free and Low Int Loans');
                pay_core_utils.push_token('VALUE', l_loan_threshold);
                l_warn := '1';
           End if;
      END;
    procedure validate_ni(p_assactid NUMBER,
                          p_assid    NUMBER,
                          p_eff_date DATE)
    is
        l_var_value NUMBER;
        l_nat_number VARCHAR2(100);

        cursor csr_ni is
        select ppf.national_identifier
        from   per_assignments_f      paf,
               per_all_people_f       ppf,
               per_periods_of_service pps
        where  ppf.person_id = paf.person_id
        and    paf.assignment_id = p_assid
        and    paf.period_of_service_id = pps.period_of_service_id(+)
        and    p_eff_date between paf.effective_start_date and paf.effective_end_date
        and    least(nvl(pps.actual_termination_date,
                         fnd_date.canonical_to_date(g_param_benefit_end_date)),
                         fnd_date.canonical_to_date(g_param_benefit_end_date))
               between ppf.effective_start_date and ppf.effective_end_date;
    begin
        open csr_ni;
        fetch csr_ni into l_nat_number;
        close csr_ni;

        select hr_gb_utility.ni_validate(l_nat_number,p_eff_date)
        into   l_var_value
        from   dual;

        if l_var_value <> 0 then
             -- Setup warning message
             l_warn:=1;
             pay_core_utils.push_message(800, 'PER_GB_P11D_78058_ASG_ERR_MSG', 'W');
             pay_core_utils.push_token('TEXT', ': Invalid NI number ' || l_nat_number);

             -- Update the NI Number field to NULL
             update pay_action_information
             set    action_information4 = null
             where  action_information_category = 'EMPLOYEE DETAILS'
             and    action_context_type = 'AAP'
             and    action_context_id = p_assactid
             and    assignment_id = p_assid;
         end if;
    end;

    procedure validate_employee_address(p_assignment_action_id number,
                                        p_assignment_name      varchar2,
                                        p_assignment_number    varchar2)
    is
       l_addr1                 varchar2(255);
       l_addr2                 varchar2(255);
       l_addr3                 varchar2(255);
       l_addr4                 varchar2(255);
       l_addr5                 varchar2(255);

       cursor get_address is
       select NVL(UPPER(pai_person.action_information5), ' '),                    -- addr line 1
              NVL(UPPER(pai_person.action_information6), ' '),                    -- addr line 2
              NVL(UPPER(pai_person.action_information7), ' '),                    -- addr line 3
              NVL(UPPER(pai_person.action_information8), ' '),                    -- addr line 4
              NVL(UPPER(hl.meaning), ' ')                                         -- addr line 5
       from   pay_action_information pai_person,
              hr_lookups hl
       where  pai_person.action_context_id = p_assignment_action_id
       and    pai_person.action_information_category = 'ADDRESS DETAILS'
       and    pai_person.action_information14 = 'Employee Address'
       and    pai_person.action_context_type = 'AAP'
       and    hl.lookup_type(+) = 'GB_COUNTY'
       and    hl.lookup_code(+) = pai_person.action_information9;
    begin
       open get_address;
       fetch get_address into l_addr1,
                              l_addr2,
                              l_addr3,
                              l_addr4,
                              l_addr5;
       close get_address;
       if pay_gb_eoy_magtape.validate_input(l_addr1,'P11D_EDI') > 0 then
          l_error_assignment := TRUE;
          l_error := '1';
          pay_core_utils.push_message(800, 'PER_GB_P11D_78058_ASG_ERR_MSG', 'F');
          pay_core_utils.push_token('TEXT', ': Magtape Character Validation has failed for Address Line 1 value ' || l_addr1);
       end if;
       if pay_gb_eoy_magtape.validate_input(l_addr2,'P11D_EDI') > 0 then
          l_error_assignment := TRUE;
          l_error := '1';
          pay_core_utils.push_message(800, 'PER_GB_P11D_78058_ASG_ERR_MSG', 'F');
          pay_core_utils.push_token('TEXT', ': Magtape Character Validation has failed for Address Line 2 value ' || l_addr2);
       end if;
       if pay_gb_eoy_magtape.validate_input(l_addr3,'P11D_EDI') > 0 then
          l_error_assignment := TRUE;
          l_error := '1';
          pay_core_utils.push_message(800, 'PER_GB_P11D_78058_ASG_ERR_MSG', 'F');
          pay_core_utils.push_token('TEXT', ': Magtape Character Validation has failed for Address Line 3 value ' || l_addr3);
       end if;
       if pay_gb_eoy_magtape.validate_input(l_addr4,'P11D_EDI') > 0 then
          l_error_assignment := TRUE;
          l_error := '1';
          pay_core_utils.push_message(800, 'PER_GB_P11D_78058_ASG_ERR_MSG', 'F');
          pay_core_utils.push_token('TEXT', ': Magtape Character Validation has failed for Address Line 4 value ' || l_addr4);
       end if;
       if pay_gb_eoy_magtape.validate_input(l_addr5,'P11D_EDI') > 0 then
          l_error_assignment := TRUE;
          l_error := '1';
          pay_core_utils.push_message(800, 'PER_GB_P11D_78058_ASG_ERR_MSG', 'F');
          pay_core_utils.push_token('TEXT', ': Magtape Character Validation has failed for Address Line 5 value ' || l_addr5);
       end if;
    end;

    procedure check_assignment_latest_info(p_assignment_id     number,
                                           p_assignment_act_id number,
                                           p_ben_end_date      date,
                                           p_asg_end_date      date)
    is
     cursor row_person_return is
     select p1.full_name,
            p1.first_name,
            p1.last_name,
            p1.middle_names
     from   per_all_assignments_f a,
            per_all_people_f      p,
            per_all_people_f      p1
     where  a.assignment_id = p_assignment_id
     and    p.person_id  = a.person_id
     and    p1.person_id = a.person_id
     and    p_asg_end_date between p.effective_start_date and p.effective_end_date
     and    p_ben_end_date between p1.effective_start_date and p1.effective_end_date
     and    (nvl(p1.first_name,' ')   <> nvl(p.first_name,' ')
             or
             nvl(p1.last_name,' ')    <> nvl(p.last_name,' ')
             or
             nvl(p1.middle_names,' ') <> nvl(p.middle_names,' ') );

     cursor row_address_return is
     select a1.address_line1,
            a1.address_line2,
            a1.address_line3,
            a1.town_or_city,
            a1.region_1,
            a1.region_2,
            a1.region_3,
            a1.postal_code,
            a1.country
     from   pay_action_information a,
            per_addresses          a1,
            per_all_assignments_f per
     where  per.assignment_id = p_assignment_id
     and    p_asg_end_date between per.effective_start_date and per.effective_end_date
     and    a1.person_id      = per.person_id
     /*
     and    a1.date_from = (select max(a2.date_from)
                            from   per_addresses a2
                            where  a2.primary_flag = 'Y'
                            and    a2.person_id = a1.person_id)
     */
     and    sysdate between a1.date_from and nvl(a1.date_to, hr_general.end_of_time)
     and    a1.primary_flag  = 'Y'
     and    per.assignment_id = a.assignment_id
     and    a.action_information_category = 'ADDRESS DETAILS'
     and    a.action_context_type = 'AAP'
     and    a.action_context_id = p_assignment_act_id
     and    (nvl(a.action_information5,' ') <> nvl(a1.address_line1,' ') or
             nvl(a.action_information6,' ') <> nvl(a1.address_line2,' ') or
             nvl(a.action_information7,' ') <> nvl(a1.address_line3,' ') or
             nvl(a.action_information8,' ') <> nvl(a1.town_or_city,' ')  or
             nvl(a.action_information9,' ') <> nvl(a1.region_1,' ')      or
             nvl(a.action_information10,' ')<> nvl(a1.region_2,' ')      or
             nvl(a.action_information11,' ')<> nvl(a1.region_3,' ')      or
             nvl(a.action_information12,' ')<> nvl(a1.postal_code,' ')   or
             nvl(a.action_information13,' ')<> nvl(a1.country,' '));

     l_fu_name      per_all_people_f.full_name%type;
     l_fi_name      per_all_people_f.first_name%type;
     l_l_name       per_all_people_f.last_name%type;
     l_m_names      per_all_people_f.middle_names%type;
     l_addr1        per_addresses.address_line1%type;
     l_addr2        per_addresses.address_line2%type;
     l_addr3        per_addresses.address_line3%type;
     l_toc          per_addresses.town_or_city%type;
     l_reg1         per_addresses.region_1%type;
     l_reg2         per_addresses.region_2%type;
     l_reg3         per_addresses.region_3%type;
     l_poc          per_addresses.postal_code%type;
     l_country      per_addresses.country%type;

    begin
     open row_person_return;
     fetch row_person_return into l_fu_name,
                                  l_fi_name,
                                  l_l_name,
                                  l_m_names;
     if row_person_return%FOUND then
             update pay_action_information
             set    action_information1 = l_fu_name
             where  action_information_category = 'EMPLOYEE DETAILS'
             and    action_context_type = 'AAP'
             and    action_context_id = p_assignment_act_id;

             update pay_action_information
             set    action_information6         = l_fi_name,
                    action_information7         = l_m_names,
                    action_information8         = l_l_name
             where  action_information_category = 'GB EMPLOYEE DETAILS'
             and    action_context_type = 'AAP'
             and    action_context_id = p_assignment_act_id;
     end if;
     close row_person_return;


     open row_address_return;
     fetch row_address_return into l_addr1,
                                   l_addr2,
                                   l_addr3,
                                   l_toc,
                                   l_reg1,
                                   l_reg2,
                                   l_reg3,
                                   l_poc,
                                   l_country;
     if row_address_return%FOUND then
           update pay_action_information
           set    action_information5 = l_addr1,
                  action_information6 = l_addr2,
                  action_information7 = l_addr3,
                  action_information8 = l_toc,
                  action_information9 = l_reg1,
                  action_information10= l_reg2,
                  action_information11= l_reg3,
                  action_information12= l_poc,
                  action_information13= l_country
           where  action_information_category = 'ADDRESS DETAILS'
           and    action_context_type = 'AAP'
           and    action_context_id = p_assignment_act_id
           and    assignment_id = p_assignment_id;
     end if;
     close row_address_return;
    end check_assignment_latest_info;

   BEGIN

      l_warn := 0;
      hr_utility.set_location('Entering   '|| l_proc, 10);
      hr_utility.set_location('step   '|| l_proc, 20);
      hr_utility.set_location('finding assignment id   '|| l_proc, 20);
      PAY_GB_P11D_ARCHIVE_SS.get_parameters(
         p_payroll_action_id           => g_pactid,
         p_token_name                  => 'EDI_VALIDATION',
         p_token_value                 => l_edi_validation);
      -- checking the cached info exists or not
      -- It could be that the action creation and acrhive are fired in
      -- different threads, this may result in
      -- cached info not available in archive code.
      l_first_index := find_lowest_matching_index;
      if l_first_index = 0 then
         -- need to populate the g_tab_ben_detail
         l_first_index_set := FALSE;

         FOR val_elememt_entry_id IN csr_val_element_entry_id(
                                        p_assactid,
                                        g_param_benefit_start_date,
                                        g_param_benefit_end_date)
         LOOP
            IF NOT l_first_index_set then
                l_first_index := g_ben_asg_count + 1;
                l_first_index_set := true;
            end if;

            g_ben_asg_count := g_ben_asg_count + 1;
            hr_utility.set_location('Inside the cursor val_elememt_entry_id ', 30);
            g_tab_ben_detail(g_ben_asg_count).assignment_action_id := p_assactid;
            g_tab_ben_detail(g_ben_asg_count).element_type_id := val_elememt_entry_id.element_type_id;
            g_tab_ben_detail(g_ben_asg_count).element_entry_id := val_elememt_entry_id.element_entry_id;
            g_tab_ben_detail(g_ben_asg_count).element_name := val_elememt_entry_id.element_name;
            g_tab_ben_detail(g_ben_asg_count).effective_start_date := val_elememt_entry_id.effective_start_date;
            g_tab_ben_detail(g_ben_asg_count).person_id := val_elememt_entry_id.person_id;
            g_tab_ben_detail(g_ben_asg_count).assignment_id := val_elememt_entry_id.assignment_id;
            g_tab_ben_detail(g_ben_asg_count).classification_name := val_elememt_entry_id.classification_name;
            -- assign it to the table of table!
--            g_tab_ben_detail_tab(p_assactid) := g_tab_ben_detail;
         END LOOP;
      end if;

--      l_index := g_tab_ben_detail.FIRST;
      l_index :=  l_first_index;
      l_assignment_id := g_tab_ben_detail(l_index).assignment_id;
      l_error_assignment := FALSE;
      l_error := '0';
      -- call generic procedure to retrieve and archive all data for EMPLOYEE DETAILS, ADDRESS DETAILS
      hr_utility.set_location('Calling pay_emp_action_arch', 20);

    open csr_get_term_date(l_assignment_id);
    fetch csr_get_term_date into l_actual_termination_date;
    close csr_get_term_date;

    open csr_get_asg_end_date(l_assignment_id);
    fetch csr_get_asg_end_date into l_asg_max_end_date;
    close csr_get_asg_end_date;

    open csr_get_global('P11D_LOW_INT_LOAN_THRESHOLD', fnd_date.canonical_to_date(g_param_benefit_end_date));
    fetch csr_get_global into l_loan_threshold;
    close csr_get_global;
    -- default the value to 5000 for archive prior to 2006
    if l_loan_threshold is null then
       l_loan_threshold := 5000;
    end if;

    hr_utility.trace('before get_asg_end_date');
    if (l_actual_termination_date is null) or
       (l_actual_termination_date > l_asg_max_end_date) then
        l_actual_termination_date := l_asg_max_end_date;
    end if;
    --if l_actual_termination_date is null then
    --    hr_utility.trace('inside if');
    --    open csr_get_asg_end_date(l_assignment_id);
    --    fetch csr_get_asg_end_date into l_actual_termination_date;
    --    close csr_get_asg_end_date;
    --end if;
    hr_utility.trace('after  get_asg_end_date');

      pay_emp_action_arch.get_personal_information(
         p_payroll_action_id           => g_pactid, -- archive payroll_action_id
         p_assactid                    => p_assactid, -- archive assignment_action_id
         p_assignment_id               => l_assignment_id, -- current assignment_id
         p_curr_pymt_ass_act_id        => NULL, -- prepayment assignment_action_id
         p_curr_eff_date               => least(
                                         nvl(l_actual_termination_date,
                                         fnd_date.canonical_to_date(g_param_benefit_end_date)),
                                         fnd_date.canonical_to_date(g_param_benefit_end_date)
                                         ), -- archive effective_date
         p_date_earned                 => least(
                                         nvl(l_actual_termination_date,
                                         fnd_date.canonical_to_date(g_param_benefit_end_date)),
                                         fnd_date.canonical_to_date(g_param_benefit_end_date)
                                         ), -- payroll date_earned
         p_curr_pymt_eff_date          => least(
                                         nvl(l_actual_termination_date,
                                         fnd_date.canonical_to_date(g_param_benefit_end_date)),
                                         fnd_date.canonical_to_date(g_param_benefit_end_date)
                                         ), -- prepayment effective_date
         p_tax_unit_id                 => NULL, -- only required for US
         p_time_period_id              => NULL, -- payroll time_period_id
         p_ppp_source_action_id        => NULL);
      hr_utility.set_location('Returned from pay_emp_action_arch', 30);

      /* Perform NI Validation */
      validate_ni(
           p_assactid   => p_assactid,
           p_assid      => l_assignment_id,
           p_eff_date   => least(nvl(l_actual_termination_date,
                                     fnd_date.canonical_to_date(g_param_benefit_end_date)),
                                 fnd_date.canonical_to_date(g_param_benefit_end_date)));

      hr_utility.set_location('Returned from NI Validation',30);
      open  csr_assignment_det(l_assignment_id, g_param_tax_reference);
      fetch csr_assignment_det into
             l_assignment_name, l_payroll_id, l_director_flag, l_first_name,
             l_middle_name, l_last_name, l_assignment_number, l_person_id, l_ni_number, l_sex, l_date_of_birth;
      close csr_assignment_det;

      hr_utility.set_location('finding payroll info: ', 25);
      hr_utility.set_location('payroll id: '|| l_payroll_id, 25);
      --set_payroll_info
      Begin
         IF l_pay_info_tab.EXISTS(l_payroll_id)
         THEN
            NULL;
         ELSE
            populate_payroll_info(g_param_benefit_end_date, l_payroll_id);
         END IF;
      EXCEPTION
         WHEN payroll_not_found
         THEN
            l_error_assignment := TRUE;
            pay_core_utils.push_message(800, 'PER_GB_P11D_78058_ASG_ERR_MSG', 'F');
            pay_core_utils.push_token('TEXT',
            ': Oracle HRMS cannot locate any information for ' || l_payroll_id || '. Please check that the Payroll Name is correct.');
            l_error := '1';
         WHEN tax_office_name_error
         THEN
            l_error_assignment := TRUE;
            l_error := '1';
            pay_core_utils.push_message(800, 'PER_GB_P11D_78058_ASG_ERR_MSG', 'F');
            pay_core_utils.push_token('TEXT', ': Magtape Character Validation has failed for Tax Office Name value '
                                              || l_pay_info_tab(l_payroll_id).l_tax_office_name);
         WHEN employer_address_error
         THEN
            l_error_assignment := TRUE;
            l_error := '1';
            pay_core_utils.push_message(800, 'PER_GB_P11D_78058_ASG_ERR_MSG', 'F');
            pay_core_utils.push_token('TEXT', ': Magtape Character Validation has failed for Employers Address value '
                                              || l_pay_info_tab(l_payroll_id).l_employer_address);
         WHEN employers_ref_no_error
         THEN
            l_error_assignment := TRUE;
            l_error := '1';
            pay_core_utils.push_message(800, 'PER_GB_P11D_78058_ASG_ERR_MSG', 'F');
            pay_core_utils.push_token('TEXT', ': Magtape Character Validation has failed for Employers Reference Number value '
                                              || l_pay_info_tab(l_payroll_id).l_employers_ref_no);
         WHEN employer_name_error
         THEN
            l_error_assignment := TRUE;
            l_error := '1';
            pay_core_utils.push_message(800, 'PER_GB_P11D_78058_ASG_ERR_MSG', 'F');
            pay_core_utils.push_token('TEXT', ': Magtape Character Validation has failed for Employers Name value '
                                              || l_pay_info_tab(l_payroll_id).l_employer_name);
      END; -- end for payroll info setup

      IF l_error <> '1'
      THEN
         pay_action_information_api.create_action_information(
            p_action_information_id       => l_action_info_id,
            p_action_context_id           => p_assactid,
            p_action_context_type         => 'AAP',
            p_object_version_number       => l_ovn,
            p_effective_date              => fnd_date.canonical_to_date(g_param_benefit_end_date),
            p_source_id                   => NULL,
            p_source_text                 => NULL,
            p_action_information_category => 'EMEA PAYROLL INFO',
            p_action_information1         => g_pactid,
            p_action_information2         => NULL,
            p_action_information3         => NULL,
            p_action_information4         => l_pay_info_tab(l_payroll_id).l_tax_office_name,
            p_action_information5         => l_pay_info_tab(l_payroll_id).l_tax_office_phone_no,
            p_action_information6         => l_pay_info_tab(l_payroll_id).l_employers_ref_no,
            p_action_information7         => l_pay_info_tab(l_payroll_id).l_employer_name,
            p_action_information8         => l_pay_info_tab(l_payroll_id).l_employer_address);
      END IF;

      hr_utility.set_location('Archiving GB EMPLOYEE DETAILS', 50);

      IF pay_gb_eoy_magtape.validate_input(UPPER(l_first_name), 'P11D_EDI') > 0
      THEN
         l_error_assignment := TRUE;
         l_error := '1';
         pay_core_utils.push_message(800, 'PER_GB_P11D_78058_ASG_ERR_MSG', 'F');
         pay_core_utils.push_token('TEXT', ': Magtape Character Validation has failed for First Name value ' || l_first_name);
      END IF;

      IF pay_gb_eoy_magtape.validate_input(UPPER(l_middle_name), 'P11D_EDI') > 0
      THEN
         l_error_assignment := TRUE;
         l_error := '1';
         pay_core_utils.push_message(800, 'PER_GB_P11D_78058_ASG_ERR_MSG', 'F');
         pay_core_utils.push_token('TEXT', ': Magtape Character Validation has failed for Middle Name value ' || l_middle_name);
      END IF;

      IF pay_gb_eoy_magtape.validate_input(UPPER(l_last_name), 'P11D_EDI') > 0
      THEN
         l_error_assignment := TRUE;
         l_error := '1';
         pay_core_utils.push_message(800, 'PER_GB_P11D_78058_ASG_ERR_MSG', 'F');
         pay_core_utils.push_token('TEXT', ': Magtape Character Validation has failed for Last Name value ' || l_last_name);
      END IF;


      -- EOY 2008
      IF  to_number(g_param_rep_run) = 2008 THEN
          IF l_ni_number is null THEN
             IF l_sex is null THEN
                l_error_assignment := TRUE;
                l_error := '1';
                pay_core_utils.push_message(800, 'PER_GB_P11D_78058_ASG_ERR_MSG', 'F');
                pay_core_utils.push_token('TEXT', ': Magtape Validation has failed for missing gender value ' );
             END IF ;

             IF l_date_of_birth is not null THEN
                IF l_date_of_birth > sysdate THEN
                   l_error_assignment := TRUE;
                   l_error := '1';
                   pay_core_utils.push_message(800, 'PER_GB_P11D_78058_ASG_ERR_MSG', 'F');
                   pay_core_utils.push_token('TEXT', ': Magtape Validation has failed for date of birth. The value must be the current date or an earlier date. ' );
                END IF;
             ELSE
                l_date_of_birth := to_date('19010101','YYYYMMDD') ;
             END IF ;
         END IF ;
      END IF;

      IF l_error <> '1'
      THEN
         pay_action_information_api.create_action_information(
            p_action_information_id       => l_action_info_id,
            p_action_context_id           => p_assactid,
            p_action_context_type         => 'AAP',
            p_object_version_number       => l_ovn,
            p_effective_date              => fnd_date.canonical_to_date(g_param_benefit_end_date),
            p_source_id                   => NULL,
            p_source_text                 => NULL,
            p_action_information_category => 'GB EMPLOYEE DETAILS',
            p_action_information1         => NULL,
            p_action_information2         => NULL,
            p_action_information3         => NULL,
            p_action_information4         => l_director_flag,
            p_action_information5         => l_payroll_id,
            p_action_information6         => l_first_name,
            p_action_information7         => l_middle_name,
            p_action_information8         => l_last_name,
            p_action_information9         => l_pay_info_tab(l_payroll_id).l_employer_name,
            p_action_information10        => l_person_id,
            p_action_information11        => l_assignment_number,
            p_action_information12        => l_ni_number,
            p_action_information13        => l_pay_info_tab(l_payroll_id).l_employers_ref_no,
            p_action_information15        => fnd_date.date_to_canonical(l_date_of_birth),
            p_action_information17        => l_sex);

        check_assignment_latest_info(
            p_assignment_id     => l_assignment_id,
            p_assignment_act_id => p_assactid,
            p_ben_end_date      => fnd_date.canonical_to_date(g_param_benefit_end_date),
            p_asg_end_date      => least(nvl(l_actual_termination_date,
                                             fnd_date.canonical_to_date(g_param_benefit_end_date)),
                                         fnd_date.canonical_to_date(g_param_benefit_end_date)));
        validate_employee_address(p_assignment_action_id => p_assactid,
                                  p_assignment_name      => l_assignment_name,
                                  p_assignment_number    => l_assignment_number);
      END IF;

--      l_index := g_tab_ben_detail.FIRST;
      l_index :=  l_first_index;

      -- loop thru all the benefits
      -- resetting globals as earlier values should not be used!
      l_ret := per_formula_functions.remove_globals;
--      hr_utility.trace_on(null,'ARCH');

      WHILE l_index <= g_tab_ben_detail.LAST
      LOOP

--         hr_utility.TRACE_on(null,'ERR');
         l_element_name := g_tab_ben_detail(l_index).element_name;
         hr_utility.set_location('Element Name '|| l_element_name, 20);
         hr_utility.set_location('Element Entry id :'|| TO_CHAR(g_tab_ben_detail(l_index).element_entry_id), 20);
         hr_utility.TRACE('Inside assignment id '|| g_tab_ben_detail(l_index).assignment_id);
         l_counter := 0;

--       Setting the array l_user_inputs with the input values from
--       element entry value
         hr_utility.set_location('Setting the input values ', 30);


         FOR entry_values IN csr_element_entry_values(
                                g_tab_ben_detail(l_index).element_entry_id,
                                g_tab_ben_detail(l_index).element_type_id,
                                g_tab_ben_detail(l_index).effective_start_date)
         LOOP
            hr_utility.trace('entry_values.NAME ' || entry_values.NAME);
            l_counter := l_counter + 1;
            l_user_inputs(l_counter).NAME := TRIM(entry_values.NAME);
            l_user_inputs(l_counter).VALUE := TRIM(entry_values.screen_entry_value);

            IF l_user_inputs(l_counter).NAME = 'BENEFIT_END_DATE'
            THEN
               l_benefit_end_date := l_user_inputs(l_counter).VALUE;
            END IF;
            IF l_user_inputs(l_counter).NAME = 'BENEFIT_START_DATE'
            THEN
               l_benefit_start_date := l_user_inputs(l_counter).VALUE;
            END IF;
         END LOOP;

        -- check if the ben st and ben end falls within the tax year
        If fnd_date.canonical_to_date(l_benefit_start_date) <
            to_date('06-04-' ||to_char(to_number(g_param_rep_run)-1),'dd-mm-yyyy') or
            fnd_date.canonical_to_date(l_benefit_start_date) >
            to_date('05-04-' ||g_param_rep_run,'dd-mm-yyyy')
        Then
                 l_error_assignment := TRUE;
                 l_error := '1';
                 pay_core_utils.push_message(800, 'HR_78076_P11D_DATE_PARAM_ERR', 'F');
                 pay_core_utils.push_token('ELEMENT_NAME',l_element_name);
                 pay_core_utils.push_token('NAME', 'Benefit Start Date in ' || l_element_name);
                 pay_core_utils.push_token('VAl1','06-APR-' ||to_char(to_number(g_param_rep_run)-1));
                 pay_core_utils.push_token('VAl2', '05-APR-' ||g_param_rep_run);
        End if;

        If fnd_date.canonical_to_date(l_benefit_end_date) <
            to_date('06-04-' ||to_char(to_number(g_param_rep_run)-1),'dd-mm-yyyy') or
            fnd_date.canonical_to_date(l_benefit_end_date) >
            to_date('05-04-' ||g_param_rep_run,'dd-mm-yyyy')
        then
                 l_error_assignment := TRUE;
                 l_error := '1';

                 pay_core_utils.push_message(800, 'HR_78076_P11D_DATE_PARAM_ERR', 'F');
                 pay_core_utils.push_token('ELEMENT_NAME',l_element_name);
                 pay_core_utils.push_token('NAME', 'Benefit End Date in ' || l_element_name);
                 pay_core_utils.push_token('VAl1','06-APR-' ||to_char(to_number(g_param_rep_run)-1));
                 pay_core_utils.push_token('VAl2', '05-APR-' ||g_param_rep_run);
        End if;
--          Setting the array l_user_inputs with the input values from
--          element entry flexfield
           hr_utility.trace(' classification_name ' ||g_tab_ben_detail(l_index).classification_name);
           hr_utility.trace('l_counter b4 entry flex values ' || l_counter);

         FOR entry_flex_values IN csr_element_entry_flex_values(g_tab_ben_detail(l_index).classification_name)
         LOOP
            l_counter := l_counter + 1;
            l_user_inputs(l_counter).NAME := TRIM(entry_flex_values.NAME);
            l_sql_stmt := 'Select  ' || entry_flex_values.application_column_name || ' from ';
            l_sql_stmt := l_sql_stmt || ' pay_element_entries_f WHERE ';
            l_sql_stmt := l_sql_stmt || ' element_entry_id =  :element_entry_id ';
            l_sql_stmt := l_sql_stmt || ' AND EFFECTIVE_START_DATE = :effec_st_date ';
            EXECUTE IMMEDIATE l_sql_stmt
               INTO l_user_inputs(l_counter).VALUE
               USING  IN g_tab_ben_detail(l_index).element_entry_id, g_tab_ben_detail(l_index).effective_start_date;
           hr_utility.trace(' l_counter ' || l_counter);
           hr_utility.trace(' Name --' ||l_user_inputs(l_counter).name || '--');
           hr_utility.trace(' Value ' ||l_user_inputs(l_counter).VALUE);
         END LOOP;

--           hr_utility.trace_on(null,'NONIV');
           hr_utility.trace(' Out of loop');
           hr_utility.trace('l_counter at b4 extra arch items ' || l_counter);

         For extra_archive_items in csr_non_iv_action_info_items (
                                g_tab_ben_detail(l_index).element_entry_id,
                                g_tab_ben_detail(l_index).element_type_id,
                                g_tab_ben_detail(l_index).effective_start_date,
                                UPPER(l_element_name),
                                g_tab_ben_detail(l_index).classification_name
                                )
         loop
            l_counter := l_counter + 1;
            l_user_inputs(l_counter).NAME := TRIM(extra_archive_items.NAME);
            l_user_inputs(l_counter).VALUE := null;
             hr_utility.trace('extra arch NAME ' || extra_archive_items.NAME);
             hr_utility.trace('user NAME ' ||l_user_inputs(l_counter).NAME);
         end loop;

        hr_utility.trace('After Using pl/sql table');

        hr_utility.trace('l_counter after extra arch items ' || l_counter);
--           hr_utility.trace_off;
--          Setting the Business group id as this is needed for Car Validation!
         l_counter := l_counter + 1;
         l_user_inputs(l_counter).NAME := 'BUSINESS_GROUP_ID';
         l_user_inputs(l_counter).VALUE := TO_CHAR(g_param_business_group_id);
        -- fetching the formula id the ff table is cached in memory and is
        -- referenced here
         l_formula_id := find_exec_formula(
                            l_element_name,
                            fnd_date.canonical_to_date(l_benefit_end_date),
                            l_formula_effective_start_date);
         hr_utility.set_location('Formula id '|| l_formula_id, 25);

         IF l_formula_id IS NOT NULL
         THEN
            hr_utility.set_location('Initializing the formula ', 40);
            Begin
                ff_exec.init_formula(l_formula_id, l_formula_effective_start_date, l_inputs, l_outputs);
            Exception
                when OTHERS then
                    l_error_assignment := TRUE;
                    l_error := '1';
                    pay_core_utils.push_message(800, 'HR_78055_GB_P11D_FORMULA_ERR', 'F');
                    pay_core_utils.push_token('ELEMENT_NAME', l_element_name);
                    hr_utility.set_location('Nothing to execute ! '|| ' :' || l_proc, 70);
                     -- Remove ALL GLOBALS
                     l_ret := per_formula_functions.remove_globals;
                     RAISE error_found;
            End;
--          Now passing the l_user_inputs to  the array l_inputs
            IF  l_inputs.COUNT > 0 AND l_user_inputs.COUNT > 0
            THEN
               FOR l_outer IN l_inputs.FIRST .. l_inputs.LAST
               LOOP
                  FOR l_inner IN l_user_inputs.FIRST .. l_user_inputs.LAST
                  LOOP
                     IF  l_inputs(l_outer).NAME = l_user_inputs(l_inner).NAME
                         AND (l_user_inputs(l_inner).NAME IS NOT NULL OR l_user_inputs(l_inner).NAME <> '')
                     THEN
                        hr_utility.TRACE('l_outer ' || l_outer);
                        hr_utility.TRACE('l_inner ' || l_inner);
                        hr_utility.TRACE(' l_inputs(l_outer).NAME --' || l_inputs(l_outer).NAME || '--');
                        hr_utility.TRACE(' l_user_inputs(l_inner).NAME -' || l_user_inputs(l_inner).NAME || '-');
                        hr_utility.TRACE(' l_user_inputs(l_inner).VALUE ' || l_user_inputs(l_inner).VALUE);
                        l_inputs(l_outer).VALUE := l_user_inputs(l_inner).VALUE;
                        hr_utility.TRACE(' Name : '|| l_inputs(l_outer).NAME || ' Value: ' || l_inputs(l_outer).VALUE);
                        EXIT;
                     END IF;
                     if l_inputs(l_outer).NAME = 'EDI_VALIDATION' then
                        l_inputs(l_outer).VALUE := l_edi_validation;
                     end if;
                  END LOOP;
               END LOOP;
            END IF; -- end if for setting user inputs
--            hr_utility.trace_on(null,'CAR');
            hr_utility.set_location('Running  the formula ', 20);
            ff_exec.run_formula(l_inputs, l_outputs);

--          Tapping the output from the formula using the l_outputs array
            hr_utility.set_location('After Running  the formula ', 20);
            FOR l_counter IN l_outputs.FIRST .. l_outputs.LAST
            LOOP
               IF  l_outputs(l_counter).NAME = 'L_ERROR' AND l_outputs(l_counter).VALUE = '1'
               THEN
                  hr_utility.set_location('Error in Element Entry id value '|| TO_CHAR(g_tab_ben_detail(l_index).element_entry_id),65);
                  l_error := '1';
               ELSIF  l_outputs(l_counter).NAME = 'L_WARN' AND l_outputs(l_counter).VALUE = '1'
               THEN
                  hr_utility.set_location('Warning in Element Entry id value '|| TO_CHAR(g_tab_ben_detail(l_index).element_entry_id),66);
                  l_warn := '1';
               ELSIF  (INSTR(UPPER(l_outputs(l_counter).NAME), 'MSG') > 0
                       OR INSTR(UPPER(l_outputs(l_counter).NAME), 'MESSAGE') > 0
                       OR (INSTR(UPPER(l_outputs(l_counter).NAME), 'ERR') > 0
                           AND INSTR(UPPER(l_outputs(l_counter).NAME), 'L_ERROR') = 0) )
                      AND (l_outputs(l_counter).VALUE <> '' OR l_outputs(l_counter).VALUE IS NOT NULL)
               THEN
                  -- this bit needs to be looked for proper error msgs
                  --pay_core_utils.push_message(800, 'PER_GB_P11D_78058_ASG_ERR_MSG', 'A');
                  -- if the message is a warning
                  if ( instr(upper(l_outputs(l_counter).NAME), 'WARN') > 0 ) then
                      pay_core_utils.push_message(800, 'PER_GB_P11D_78058_ASG_ERR_MSG', 'W');
                      pay_core_utils.push_token('TEXT', SUBSTR(l_outputs(l_counter).VALUE, 1, 200) );
                  else
                      l_error := '1';
                  end if;
                  /*
                  else
                      pay_core_utils.push_message(800, 'PER_GB_P11D_78058_ASG_ERR_MSG', 'F');
                      pay_core_utils.push_token('TEXT', l_element_name ||': ' || SUBSTR(l_outputs(l_counter).VALUE, 2, 100) );
                  end if;
                  */
                  hr_utility.TRACE('Error'|| l_outputs(l_counter).VALUE);
               END IF;
               hr_utility.TRACE(l_outputs(l_counter).NAME || ': ' || l_outputs(l_counter).VALUE);
            END LOOP;
--          if the values of input values have changed within the formula
--          then they are passed as items of table l_output

--          this loop checks if the name of l_output is same as that
--          of l_inputs, if they are the same then it means that
--          a new value has been returned from the formula

--            hr_utility.tracE_on(null,'ARCH');
            hr_utility.set_location('Checking input values with that of values returned by ff', 30);

            FOR l_outer IN l_user_inputs.FIRST .. l_user_inputs.LAST
            LOOP
               FOR l_inner IN l_outputs.FIRST .. l_outputs.LAST
               LOOP
--                  hr_utility.trace('l_outputs(l_inner).NAME ' || l_outputs(l_inner).NAME);
--                  hr_utility.trace('l_outputs(l_inner).VALUE ' || l_outputs(l_inner).VALUE);
--                  hr_utility.trace('l_user_inputs(l_outer).NAME ' ||l_user_inputs(l_outer).NAME);
                  IF l_user_inputs(l_outer).NAME = l_outputs(l_inner).NAME
                  THEN
                     l_user_inputs(l_outer).VALUE := l_outputs(l_inner).VALUE;
                     EXIT;
                  END IF;
               END LOOP;
            END LOOP;

            hr_utility.set_location('Checking Magtape Validation', 35);
--            hr_utility.tracE_off;
--            check_magtape_validation;
            FOR l_inner IN l_user_inputs.FIRST .. l_user_inputs.LAST
            LOOP
               IF pay_gb_eoy_magtape.validate_input(UPPER(l_user_inputs(l_inner).VALUE) ) > 0
               THEN
                  IF INSTR(UPPER(l_user_inputs(l_inner).NAME), 'DATE') > 0
                  THEN
                     NULL; -- ignore the failure as the dates validatred by the above process is incrrect
                           -- and since our input values have date defined , the data will be correct.
                  ELSIF UPPER(l_user_inputs(l_inner).NAME) =  'NOTES'
                  THEN
                     NULL; -- ignore the failure as NOTES is info field only
                  ELSIF (l_user_inputs(l_inner).VALUE = 'PRECIOUS_METALS' AND l_user_inputs(l_inner).NAME = 'ASSET_TYPE')
                        OR (l_user_inputs(l_inner).NAME = 'EXPENSE_TYPE'
                            AND (l_user_inputs(l_inner).VALUE = 'PRSN_INCIDENTAL_EXPENSES'
                                 OR l_user_inputs(l_inner).VALUE = 'TELE_CALLS'
                                 OR l_user_inputs(l_inner).VALUE = 'TELE_RENTAL'
                                 OR l_user_inputs(l_inner).VALUE = 'WORK_DONE_AT_HOME') )
                        OR (l_user_inputs(l_inner).NAME = 'FUEL_TYPE'
                            AND (l_user_inputs(l_inner).VALUE = 'BATTERY_ELECTRIC'
                                 OR l_user_inputs(l_inner).VALUE = 'HYBRID_ELECTRIC'
                                 OR l_user_inputs(l_inner).VALUE = 'LPG_CNG'
                                 OR l_user_inputs(l_inner).VALUE = 'LPG_CNG_PETROL'
                                 OR l_user_inputs(l_inner).VALUE = 'EURO_IV_DIESEL'
                                 OR l_user_inputs(l_inner).VALUE = 'LPG_CNG_PETROL_CONV') )
                  -- these are excluded as these are codes which have _ in them and the validation fails
                  -- because of this
                  THEN
                     NULL;
                  ELSE
                     hr_utility.set_location('Magtape Validation failure', 35);
                     l_error_assignment := TRUE;
                     l_error := '1';
                     pay_core_utils.push_message(800, 'PER_GB_P11D_78058_ASG_ERR_MSG', 'F');
                     pay_core_utils.push_token('TEXT', ': Magtape Character Validation has failed for '
                                                        ||l_user_inputs(l_inner).NAME || ' value ' || l_user_inputs(l_inner).VALUE);
                  END IF; -- checking exceptions for mag tape validations
               END IF; -- end if for magtape validation error
            END LOOP; -- loop which runs thru inpout values

            l_action_context_id := p_assactid;

            IF l_error = '0'
            THEN
               hr_utility.set_location('Creating archive = '|| p_assactid, 20);
               hr_utility.set_location('p_assactid = '|| p_assactid, 20);
               l_col1_val := NULL;               l_col2_val := NULL;
               l_col3_val := NULL;               l_col4_val := NULL;
               l_col5_val := NULL;               l_col6_val := NULL;
               l_col7_val := NULL;               l_col8_val := NULL;
               l_col9_val := NULL;               l_col10_val := NULL;
               l_col11_val := NULL;               l_col12_val := NULL;
               l_col13_val := NULL;               l_col14_val := NULL;
               l_col15_val := NULL;               l_col16_val := NULL;
               l_col17_val := NULL;               l_col18_val := NULL;
               l_col19_val := NULL;               l_col20_val := NULL;
               l_col21_val := NULL;               l_col22_val := NULL;
               l_col23_val := NULL;               l_col24_val := NULL;
               l_col25_val := NULL;               l_col26_val := NULL;
               l_col27_val := NULL;               l_col28_val := NULL;
               l_col29_val := NULL;               l_col30_val := NULL;
               FOR action_info IN csr_action_info_flex_fields(UPPER(l_element_name) )
               LOOP
                  FOR l_inner IN l_user_inputs.FIRST .. l_user_inputs.LAST
                  LOOP
                     -- as the END_USER_COLUMN_NAME on table fnd_descr_flex_column_usages
                     -- can be max fo size 30 and we are comapring the END_USER_COLUMN_NAME
                     -- filed with the input value name , we should trim it dowjn to 30
                     -- so that then first 30 will now becoem the matching
                     -- criteria.
                     hr_utility.trace(l_user_inputs(l_inner).NAME || ' : ' || l_user_inputs(l_inner).VALUE);
                     IF action_info.NAME = SUBSTR(l_user_inputs(l_inner).NAME, 1, 30)
                     THEN
                        IF action_info.application_column_name = 'ACTION_INFORMATION3'
                        THEN
                           l_col3_val := l_user_inputs(l_inner).VALUE;
                        END IF;

                        IF action_info.application_column_name = 'ACTION_INFORMATION4'
                        THEN
                           l_col4_val := l_user_inputs(l_inner).VALUE;
                        END IF;

                        IF action_info.application_column_name = 'ACTION_INFORMATION5'
                        THEN
                           l_col5_val := l_user_inputs(l_inner).VALUE;
                        END IF;

                        IF action_info.application_column_name = 'ACTION_INFORMATION6'
                        THEN
                           l_col6_val := l_user_inputs(l_inner).VALUE;
                        END IF;

                        IF action_info.application_column_name = 'ACTION_INFORMATION7'
                        THEN
                           l_col7_val := l_user_inputs(l_inner).VALUE;
                        END IF;

                        IF action_info.application_column_name = 'ACTION_INFORMATION8'
                        THEN
                           l_col8_val := l_user_inputs(l_inner).VALUE;
                        END IF;

                        IF action_info.application_column_name = 'ACTION_INFORMATION9'
                        THEN
                           l_col9_val := l_user_inputs(l_inner).VALUE;
                        END IF;

                        IF action_info.application_column_name = 'ACTION_INFORMATION10'
                        THEN
                           l_col10_val := l_user_inputs(l_inner).VALUE;
                        END IF;

                        IF action_info.application_column_name = 'ACTION_INFORMATION11'
                        THEN
                           l_col11_val := l_user_inputs(l_inner).VALUE;
                        END IF;

                        IF action_info.application_column_name = 'ACTION_INFORMATION12'
                        THEN
                           l_col12_val := l_user_inputs(l_inner).VALUE;
                        END IF;

                        IF action_info.application_column_name = 'ACTION_INFORMATION13'
                        THEN
                           l_col13_val := l_user_inputs(l_inner).VALUE;
                        END IF;

                        IF action_info.application_column_name = 'ACTION_INFORMATION14'
                        THEN
                           l_col14_val := l_user_inputs(l_inner).VALUE;
                        END IF;

                        IF action_info.application_column_name = 'ACTION_INFORMATION15'
                        THEN
                           l_col15_val := l_user_inputs(l_inner).VALUE;
                        END IF;

                        IF action_info.application_column_name = 'ACTION_INFORMATION16'
                        THEN
                           l_col16_val := l_user_inputs(l_inner).VALUE;
                        END IF;

                        IF action_info.application_column_name = 'ACTION_INFORMATION17'
                        THEN
                           l_col17_val := l_user_inputs(l_inner).VALUE;
                        END IF;

                        IF action_info.application_column_name = 'ACTION_INFORMATION18'
                        THEN
                           l_col18_val := l_user_inputs(l_inner).VALUE;
                        END IF;

                        IF action_info.application_column_name = 'ACTION_INFORMATION19'
                        THEN
                           l_col19_val := l_user_inputs(l_inner).VALUE;
                        END IF;

                        IF action_info.application_column_name = 'ACTION_INFORMATION20'
                        THEN
                           l_col20_val := l_user_inputs(l_inner).VALUE;
                        END IF;

                        IF action_info.application_column_name = 'ACTION_INFORMATION21'
                        THEN
                           l_col21_val := l_user_inputs(l_inner).VALUE;
                        END IF;

                        IF action_info.application_column_name = 'ACTION_INFORMATION22'
                        THEN
                           l_col22_val := l_user_inputs(l_inner).VALUE;
                        END IF;

                        IF action_info.application_column_name = 'ACTION_INFORMATION23'
                        THEN
                           l_col23_val := l_user_inputs(l_inner).VALUE;
                        END IF;

                        IF action_info.application_column_name = 'ACTION_INFORMATION24'
                        THEN
                           l_col24_val := l_user_inputs(l_inner).VALUE;
                        END IF;

                        IF action_info.application_column_name = 'ACTION_INFORMATION25'
                        THEN
                           l_col25_val := l_user_inputs(l_inner).VALUE;
                           IF UPPER(l_element_name) = 'CAR AND CAR FUEL 2003_04' THEN
                           -- EOY 2008.
                           -- For the element 'Car and Car Fuel 2003_04', archiving Valid_Benefit_End_Date_flag
                           -- with Fuel_Benefit separated by a delimiter ':', as all the 30 fields against
                           -- context 'CAR AND CAR FUEL 2003_04' in 'Action Information DF' were
                           -- already archived. This flag will be used in EDI, to decide
                           -- if we need to print '5-Apr' as Date_Car_Available_To DTM3 489
                              FOR l_inner_temp IN l_user_inputs.FIRST .. l_user_inputs.LAST
                              LOOP
                                  IF UPPER(l_user_inputs(l_inner_temp).NAME) = 'VALID_BENEFIT_END_DATE' THEN
                                      l_col25_val := l_col25_val || ':' || nvl(l_user_inputs(l_inner_temp).VALUE,'N');
                                      EXIT ;
                                  END IF ;
                              END LOOP ;
                           END IF ;
                        END IF;

                        IF action_info.application_column_name = 'ACTION_INFORMATION26'
                        THEN
                           l_col26_val := l_user_inputs(l_inner).VALUE;
                        END IF;

                        IF action_info.application_column_name = 'ACTION_INFORMATION27'
                        THEN
                           l_col27_val := l_user_inputs(l_inner).VALUE;
                        END IF;

                        IF action_info.application_column_name = 'ACTION_INFORMATION28'
                        THEN
                           l_col28_val := l_user_inputs(l_inner).VALUE;
                        END IF;

                        IF action_info.application_column_name = 'ACTION_INFORMATION29'
                        THEN
                           l_col29_val := l_user_inputs(l_inner).VALUE;
                        END IF;

                        IF action_info.application_column_name = 'ACTION_INFORMATION30'
                        THEN
                           l_col30_val := l_user_inputs(l_inner).VALUE;
                        END IF;

                        EXIT;
                     END IF;
                  END LOOP;
               END LOOP;
               hr_utility.set_location('calling the create api', 20);
                  pay_action_information_api.create_action_information(
                  p_action_information_id       => l_action_info_id,
                  p_action_context_id           => l_action_context_id,
                  p_action_context_type         => 'AAP',
                  p_object_version_number       => l_ovn,
                  p_source_id                   => NULL,
                  p_source_text                 => NULL,
                  p_effective_date              => fnd_date.canonical_to_date(g_param_benefit_end_date),
                  p_action_information_category => SUBSTR(UPPER(l_element_name), 1, 30),
                  p_action_information1         => g_tab_ben_detail(l_index).element_entry_id,
                  p_action_information2         => g_tab_ben_detail(l_index).effective_start_date,
                  p_action_information3         => l_col3_val,
                  p_action_information4         => l_col4_val,
                  p_action_information5         => l_col5_val,
                  p_action_information6         => l_col6_val,
                  p_action_information7         => l_col7_val,
                  p_action_information8         => l_col8_val,
                  p_action_information9         => l_col9_val,
                  p_action_information10        => l_col10_val,
                  p_action_information11        => l_col11_val,
                  p_action_information12        => l_col12_val,
                  p_action_information13        => l_col13_val,
                  p_action_information14        => l_col14_val,
                  p_action_information15        => l_col15_val,
                  p_action_information16        => l_col16_val,
                  p_action_information17        => l_col17_val,
                  p_action_information18        => l_col18_val,
                  p_action_information19        => l_col19_val,
                  p_action_information20        => l_col20_val,
                  p_action_information21        => l_col21_val,
                  p_action_information22        => l_col22_val,
                  p_action_information23        => l_col23_val,
                  p_action_information24        => l_col24_val,
                  p_action_information25        => l_col25_val,
                  p_action_information26        => l_col26_val,
                  p_action_information27        => l_col27_val,
                  p_action_information28        => l_col28_val,
                  p_action_information29        => l_col29_val,
                  p_action_information30        => l_col30_val);
                  hr_utility.trace('After calling Create api');
            ELSE -- error is non 0
               l_error_assignment := TRUE;
            END IF;
         ELSE -- formual id is null
            l_error_assignment := TRUE;
            l_error := '1';
            pay_core_utils.push_message(800, 'HR_78055_GB_P11D_FORMULA_ERR', 'F');
            pay_core_utils.push_token('ELEMENT_NAME', l_element_name);
            hr_utility.set_location('Nothing to execute ! '|| ' :' || l_proc, 70);
         END IF;

         hr_utility.trace('Looking at Next value!');

         l_index := g_tab_ben_detail.NEXT(l_index);

         hr_utility.trace('l_index=' || l_index);

         if g_tab_ben_detail.EXISTS(l_index) then
             hr_utility.trace('Next item exists');
             if g_tab_ben_detail(l_index).assignment_action_id <> p_assactid
             then
                hr_utility.trace('Next item does not match');
                exit; -- come out of the loop
             end if;
         else
             hr_utility.trace('Next item does not exist');
             hr_utility.trace('Coming out loop for all benefits');
            exit;
         end if;
      END LOOP; -- loop for all benefits

      -- this validates the sum within the assignment
      hr_utility.trace('Calling validate_values ');

      validate_values;
      IF l_error_assignment
      THEN
         hr_utility.set_location('Failing Assignment  '|| ' :' || l_proc, 70);
         --log_message;
         -- Remove ALL GLOBALS
         l_ret := per_formula_functions.remove_globals;
         RAISE error_found;
      ELSE
         -- insert rows which are sums for all values in ffs
         hr_utility.trace('Inserting summed records ');
         insert_sum_records(p_assactid);
         -- Remove ALL GLOBALS
         l_ret := per_formula_functions.remove_globals;
        /* bug fix for 3485256
         l_index := g_tab_ben_detail.FIRST;
        */
         l_index :=  l_first_index;
         l_tab_counter := 0;
         l_processed_assign_actions := c_proc_assign_actions_null;
         --check if multiple assignments exist
         hr_utility.trace('Checing if multiple assign exists');
         hr_utility.trace('person_id ' || g_tab_ben_detail(l_index).person_id);
         hr_utility.trace('l_employers_ref_no ' || l_pay_info_tab(l_payroll_id).l_employers_ref_no);
         hr_utility.trace('l_employer_name ' || l_pay_info_tab(l_payroll_id).l_employer_name);

         FOR assignment_list IN assignments_to_sum(
                                   g_tab_ben_detail(l_index).person_id,
                                   l_pay_info_tab(l_payroll_id).l_employers_ref_no,
                                   l_pay_info_tab(l_payroll_id).l_employer_name)
         LOOP
            -- if yes sum them
           hr_utility.trace('multiple assign exists.....');
           hr_utility.trace('Assign act id ' || assignment_list.assignment_action_id );
            fetch_values_and_set_globals(assignment_list.assignment_action_id);
            l_tab_counter := l_tab_counter + 1;
            l_processed_assign_actions(l_tab_counter) := assignment_list.assignment_action_id;
         END LOOP;

         IF l_tab_counter > 1
         THEN
            -- miltiple assignmenst exists validate and update all of them
            -- if validation fails then write log and raise error
           hr_utility.trace('Calling val values for multiple assign ..');
            validate_values;
            IF l_error = '1'
            THEN
               hr_utility.set_location('Failing Assignment  '|| ' :' || l_proc, 90);
               -- Remove ALL GLOBALS
               l_ret := per_formula_functions.remove_globals;
               RAISE error_found;
            ELSE
               l_tab_counter := l_processed_assign_actions.FIRST;
               hr_utility.trace('Calling Update values..');
               WHILE l_tab_counter <= l_processed_assign_actions.LAST
               LOOP
                  hr_utility.trace('Update values ' || l_processed_assign_actions(l_tab_counter) );
                  update_values(l_processed_assign_actions(l_tab_counter) );
                  l_tab_counter := l_processed_assign_actions.NEXT(l_tab_counter);
               END LOOP;
            END IF;
         END IF;
      END IF;
   l_ret := per_formula_functions.remove_globals;
   hr_utility.trace('nearing end');
   EXCEPTION
      WHEN error_found
      THEN
        l_ret := per_formula_functions.remove_globals;
        -- the error will be reported in Deinitialization proc
        -- write_error_to_log;
        g_set_warning := TRUE;
        hr_utility.raise_error;
   END archive_code;

   PROCEDURE write_log(employers_name VARCHAR2, person_name VARCHAR2, employee_num VARCHAR2, err_text VARCHAR2)
   IS
   BEGIN
      fnd_file.put_line(
         fnd_file.output,
         RPAD(NVL(employers_name, ' '), 20) || RPAD(NVL(person_name, ' '), 25) || RPAD(NVL(employee_num, ' '), 15) || err_text);
   END;

   PROCEDURE deinitialization_code(pactid IN NUMBER)
   IS
      l_proc  CONSTANT VARCHAR2(50) := g_package || ' deinitialization_code';
      l_counter number;
       -- 4248907 Perf fix - csr_incorrect_ni_percentage - Broken into 2 separate cursors
      CURSOR csr_incorrect_ni_num IS
      SELECT pai.action_information7 action_information7, COUNT(1) temp_num
      FROM   pay_payroll_actions ppa,
             pay_assignment_actions paa,
             pay_action_information pai,
             pay_action_information pai_emp
      WHERE  ppa.payroll_action_id = pactid
      AND    paa.payroll_action_id = ppa.payroll_action_id
      AND    pai.action_context_id = paa.assignment_action_id
      AND    pai.action_information_category = 'EMEA PAYROLL INFO'
      AND    pai.action_context_type = 'AAP'
      AND    pai_emp.action_context_id = paa.assignment_action_id
      AND    pai_emp.action_information_category = 'EMPLOYEE DETAILS'
      AND    pai_emp.action_context_type = 'AAP'
      AND    (SUBSTR(pai_emp.action_information4, 1, 2) = 'TN'
              OR
              pai_emp.action_information4 IS NULL)
      GROUP BY pai.action_information7;

      CURSOR csr_total_num(p_employer_name varchar2) IS
      SELECT pai.action_information7 action_information7, COUNT(1) tot_num
      FROM   pay_payroll_actions ppa,
             pay_assignment_actions paa,
             pay_action_information pai
      WHERE  ppa.payroll_action_id = pactid
      AND    paa.payroll_action_id = ppa.payroll_action_id
      AND    pai.action_context_id = paa.assignment_action_id
      AND    pai.action_information_category = 'EMEA PAYROLL INFO'
      AND    pai.action_context_type = 'AAP'
      AND    pai.action_information7 = p_employer_name
      GROUP BY pai.action_information7;

      CURSOR csr_expenses_payment_chk
      IS
      SELECT COUNT(DISTINCT pai_ben.action_information10)
      FROM   pay_payroll_actions ppa,
             pay_assignment_actions paa,
             pay_action_information pai_ben
      WHERE  ppa.payroll_action_id = pactid
      AND    ppa.payroll_action_id = paa .payroll_action_id
      AND    pai_ben.action_context_id = paa.assignment_action_id
      AND    pai_ben.action_information_category = 'EXPENSES PAYMENTS'
      AND    pai_ben.action_context_type = 'AAP'
      HAVING COUNT(DISTINCT pai_ben.action_information10) > 1;

      -- 4312909 Perf fix - Removed redundant Car and Vans related categories
      CURSOR csr_p11db_value
      IS
      SELECT pai_comp.action_information7 employers_name,
             SUM(DECODE(
                        pai.action_information_category,
                        'ASSETS TRANSFERRED', pai.action_information9,
                        'LIVING ACCOMMODATION', pai.action_information10,
                        'CAR AND CAR FUEL 2003_04',NVL(pai.action_information10, 0) + NVL(pai.action_information11, 0),
                        'VANS 2002_03', NVL(pai.action_information15, 0),
                        'INT FREE AND LOW INT LOANS', pai.action_information11,
                        'PVT MED TREATMENT OR INSURANCE', pai.action_information7,
                        'RELOCATION EXPENSES', pai.action_information5,
                        'SERVICES SUPPLIED', pai.action_information7,
                        'ASSETS AT EMP DISPOSAL', pai.action_information9,
                        'OTHER ITEMS', pai.action_information9,
                        -- 'EXPENSES PAYMENTS', pai.action_information8,
                        '0') ) p11db_value
       FROM  pay_action_information pai_comp,
             pay_action_information pai,
             pay_assignment_actions paa,
             pay_payroll_actions ppa
       WHERE ppa.payroll_action_id = pactid
       AND    ppa.payroll_action_id = paa .payroll_action_id
       AND    pai_comp.action_context_id = paa.assignment_action_id
       AND    pai_comp.action_information_category = 'EMEA PAYROLL INFO'
       AND    pai.action_context_id = paa.assignment_action_id
       GROUP BY pai_comp.action_information7;

       PROCEDURE check_duplicate
       IS
            type person_details is record(
                 full_name     varchar2(255),
                 employer_name varchar2(255),
                 person_id     number,
                 employee_no   varchar2(70),
                 ni_number     varchar2(12)
            );

            type t_person_table is table of person_details index by binary_integer;

            person_table  t_person_table;
            l_count        number;
            l_prev         number;
            l_curr         number;

            cursor get_details is
            select ppa.action_information6,
                   ppa.action_information7,
                   ppa.action_information8,
                   ppa.action_information9,
                   ppa.action_information10,
                   ppa.action_information11,
                   ppa.action_information12
            from   pay_assignment_actions paa,
                   pay_action_information ppa
            where  paa.payroll_action_id = pactid
            and    paa.assignment_action_id = ppa.action_context_id
            and    ppa.action_information_category = 'GB EMPLOYEE DETAILS'
            and    ppa.action_context_type = 'AAP'
            order  by ppa.action_information12;

       BEGIN
            l_count := 0;
            for x in get_details loop
                l_count := l_count + 1;
                person_table(l_count).full_name     := x.action_information8;
                person_table(l_count).employer_name := x.action_information9;
                person_table(l_count).person_id     := x.action_information10;
                person_table(l_count).employee_no   := x.action_information11;
                person_table(l_count).ni_number     := x.action_information12;
            end loop;
            fnd_file.put_line(fnd_file.output,null);
            fnd_file.put_line(fnd_file.output,'Duplicate NI Number Report');
            fnd_file.put_line(fnd_file.output,rpad('Employer Name',20) ||
                                              rpad(' Employee Name',26) ||
                                              rpad(' Employee Number',16));
            fnd_file.put_line(fnd_file.output,rpad('-',20,'-') || ' ' ||
                                              rpad('-',25,'-') || ' ' ||
                                              rpad('-',16,'-') || ' ' ||
                                              rpad('-',55,'-'));

            if l_count > 0 then
                l_prev := 1;
                l_curr := 1;
                loop
                    if l_curr > 1 then
                       if (person_table(l_curr).ni_number =  person_table(l_prev).ni_number
                           and
                           person_table(l_curr).person_id <> person_table(l_prev).person_id) then
                           fnd_file.put_line(fnd_file.output,
                                          rpad(person_table(l_prev).employer_name,21) ||
                                          rpad(person_table(l_prev).full_name,26)     ||
                                          rpad(person_table(l_prev).employee_no,16)   ||
                                          'This employee has a duplicate NI number '  || person_table(l_prev).ni_number);
                           fnd_file.put_line(fnd_file.output,
                                          rpad(person_table(l_curr).employer_name,21) ||
                                          rpad(person_table(l_curr).full_name,26)     ||
                                          rpad(person_table(l_curr).employee_no,16)   ||
                                          'This employee has a duplicate NI number '  || person_table(l_curr).ni_number);
                       end if;
                    end if;
                    l_prev := l_curr;
                    l_curr := l_curr + 1;
                 exit
                     when(l_curr > l_count);
                 end loop;
            end if;
       END;

       FUNCTION check_classA(p_benefit_code varchar2,
                             p_benefit_name varchar2) return boolean
       IS
          class_a constant varchar2(10) := 'ADFGHIJKLM';
          non_class_a constant varchar2(5) := 'BCEN';
          code varchar2(10);
          ret  boolean;
       BEGIN
          code := translate(p_benefit_code,class_a || non_class_a, class_a);
          if code is not null then
             ret := true;
             if p_benefit_name = 'OTHER ITEMS NON 1A' then
                ret := false;
             end if;
          else
             ret := false;
          end if;
          return ret;
       END check_classA;

       FUNCTION get_input_name(p_benefit_code varchar2) return varchar2
       IS
            l_ret varchar2(30);
       BEGIN
            if p_benefit_code = 'F' then
               l_ret := 'Cash Equivalent for Car';
            elsif p_benefit_code = 'G' then
               l_ret := 'Van Benefit Charge';
            elsif p_benefit_code = 'D' then
               l_ret := 'Cash Equiv + Add Charge';
            else
               l_ret := 'Cash Equivalent';
            end if;
            return l_ret;
       END;

       PROCEDURE write_summary(p_pact_id number) IS

             cursor get_employer(p_pact_id number) is
             select action_information7
             from   pay_assignment_actions paa,
                    pay_action_information pai
             where  paa.payroll_action_id = p_pact_id
             and    pai.action_context_id = paa.assignment_action_id
             and    pai.action_information_category = 'EMEA PAYROLL INFO'
             and    pai.action_context_type = 'AAP'
             group by  action_information7;

             cursor get_total(p_pact_id  number, p_emp_name varchar2) is
             select * from (
             select /*+ ORDERED use_nl(paf,paa,pai,pai_a,pai_person)
	                        use_index(pai_person,pay_action_information_n2)
			        use_index(pai,pay_action_information_n2)
                                use_index(pai_a,pay_action_information_n2)*/
                   pai.action_information_category name,
                   sum(decode(pai.action_information_category,
                         'ASSETS TRANSFERRED', pai.action_information9,
                         'PAYMENTS MADE FOR EMP', pai.action_information7,
                         'VOUCHERS OR CREDIT CARDS', pai.action_information11,
                         'LIVING ACCOMMODATION', pai.action_information10, --Changed for bug 8204969
                         'MILEAGE ALLOWANCE AND PPAYMENT', pai_a.action_information12,
                         'CAR AND CAR FUEL 2003_04', pai.action_information10,
                         'VANS 2002_03',pai.action_information15,
                         'VANS 2005', pai.action_information15,
                         'VANS 2007', pai.action_information14,
                         'INT FREE AND LOW INT LOANS', pai.action_information11,
                         'PVT MED TREATMENT OR INSURANCE', pai.action_information7,
                         'RELOCATION EXPENSES', pai.action_information5,
                         'SERVICES SUPPLIED', pai.action_information7,
                         'ASSETS AT EMP DISPOSAL', pai.action_information9,
                         'OTHER ITEMS', pai.action_information9,
                         'OTHER ITEMS NON 1A', pai.action_information9,
                         'EXPENSES PAYMENTS', pai.action_information8)) total,
                   decode(pai.action_information_category,
                         'ASSETS TRANSFERRED',        'A',
                         'PAYMENTS MADE FOR EMP',     'B',
                         'VOUCHERS OR CREDIT CARDS',  'C',
                         'LIVING ACCOMMODATION',      'D',
                         'MILEAGE ALLOWANCE AND PPAYMENT', 'E',
                         'CAR AND CAR FUEL 2003_04',       'F',
                         'VANS 2005',                      'G',
                         'VANS 2007',                      'O',
                         'VANS 2002_03',                   'G',
                         'INT FREE AND LOW INT LOANS',     'H',
                         'PVT MED TREATMENT OR INSURANCE', 'I',
                         'RELOCATION EXPENSES',            'J',
                         'SERVICES SUPPLIED',              'K',
                         'ASSETS AT EMP DISPOSAL',         'L',
                         'OTHER ITEMS',                    'M',
                         'OTHER ITEMS NON 1A',             'M',
                         'EXPENSES PAYMENTS',              'N') cat,
                    count(*) no_of_entries
             from   pay_assignment_actions  paa,
       		        pay_action_information  pai,
                    pay_action_information  pai_a,
       		        pay_action_information  pai_person
		     where  paa.payroll_action_id = p_pact_id
		     and    pai.action_context_id = paa.assignment_action_id
		     and    pai.action_context_type = 'AAP'
		     and    pai.action_information_category = pai.action_information_category
		     and    pai_person.action_context_id = paa.assignment_action_id
		     and    pai_person.action_information_category = 'GB EMPLOYEE DETAILS'
		     and    pai_person.action_information9 = p_emp_name  --p_employer_name
		     and    pai_person.action_context_type = 'AAP'
             and    pai_a.action_context_id = paa.assignment_action_id
             and    pai_a.action_context_type = 'AAP'
             and    pai_a.action_information_category = 'GB P11D ASSIGNMENT RESULTA'
             group  by pai.action_information_category)
             where cat in ('A','B','C','D','E','F','G','H','I','J','K','L','M','N','O')
             order by cat;

/* Added for the bug 8513401*/
             cursor get_int_free_total(p_pact_id  number, p_emp_name varchar2) is
             select sum(decode(pai.action_information_category,
                         'INT FREE AND LOW INT LOANS', pai.action_information11)) total
             from   pay_assignment_actions  paa,
       		        pay_action_information  pai,
                    pay_action_information  pai_a,
       		        pay_action_information  pai_person
		     where  paa.payroll_action_id = p_pact_id
		     and    pai.action_context_id = paa.assignment_action_id
		     and    pai.action_context_type = 'AAP'
		     and    pai_person.action_context_id = paa.assignment_action_id
		     and    pai_person.action_information_category = 'GB EMPLOYEE DETAILS'
		     and    pai_person.action_information9 = p_emp_name  --p_employer_name
		     and    pai_person.action_context_type = 'AAP'
             and    pai_a.action_context_id = paa.assignment_action_id
             and    pai_a.action_context_type = 'AAP'
             and    pai_a.action_information_category = 'GB P11D ASSIGNMENT RESULTA'
             and not exists (select 1
                             from pay_action_information pai_max
                             where pai_max.action_context_id = paa.assignment_action_id
                               and nvl(pai_max.ACTION_INFORMATION23,0) < 5000
                               and pai_max.action_context_type = 'AAP'
                               and pai_max.action_information_category = 'GB P11D ASSIGNMENT RESULTC');

/* Added for the bug 8513401*/

             cursor get_mileage(p_pact_id  number, p_emp_name varchar2) is
             select /*+ ORDERED use_nl(paf,paa,pai,pai_person)
		            use_index(pai_person,pay_action_information_n2)
				    use_index(pai,pay_action_information_n2) */
                    sum(pai.action_information12)
             from   pay_assignment_actions  paa,
       	     	    pay_action_information  pai,
       	     	    pay_action_information  pai_person
		     where  paa.payroll_action_id = p_pact_id
		     and    pai.action_context_id = paa.assignment_action_id
		     and    pai.action_context_type = 'AAP'
		     and    pai.action_information_category = 'GB P11D ASSIGNMENT RESULTA'
		     and    pai_person.action_context_id = paa.assignment_action_id
		     and    pai_person.action_information_category = 'GB EMPLOYEE DETAILS'
		     and    pai_person.action_information9 = p_emp_name --p_employer_name
		     and    pai_person.action_context_type = 'AAP';

             cursor get_car_fuel(p_pact_id  number, p_emp_name varchar2) is
             select /*+ ORDERED use_nl(paf,paa,pai,pai_person)
		            use_index(pai_person,pay_action_information_n2)
				    use_index(pai,pay_action_information_n2) */
                    sum(pai.action_information11)  -- Cash Equivalent For Fuel
             from   pay_assignment_actions  paa,
       	     	    pay_action_information  pai,
       	     	    pay_action_information  pai_person
		     where  paa.payroll_action_id = p_pact_id
		     and    pai.action_context_id = paa.assignment_action_id
		     and    pai.action_context_type = 'AAP'
		     and    pai.action_information_category = 'CAR AND CAR FUEL 2003_04'
		     and    pai_person.action_context_id = paa.assignment_action_id
		     and    pai_person.action_information_category = 'GB EMPLOYEE DETAILS'
		     and    pai_person.action_information9 = p_emp_name --p_employer_name
		     and    pai_person.action_context_type = 'AAP';

		     cursor get_van_fuel(p_pact_id  number, p_emp_name varchar2) is
             select /*+ ORDERED use_nl(paf,paa,pai,pai_person)
		            use_index(pai_person,pay_action_information_n2)
				    use_index(pai,pay_action_information_n2) */
                    sum(pai.action_information30)  -- Cash Equivalent For Fuel
             from   pay_assignment_actions  paa,
       	     	    pay_action_information  pai,
       	     	    pay_action_information  pai_person
		     where  paa.payroll_action_id = p_pact_id
		     and    pai.action_context_id = paa.assignment_action_id
		     and    pai.action_context_type = 'AAP'
		     and    pai.action_information_category = 'VANS 2007'
		     and    pai_person.action_context_id = paa.assignment_action_id
		     and    pai_person.action_information_category = 'GB EMPLOYEE DETAILS'
		     and    pai_person.action_information9 = p_emp_name --p_employer_name
		     and    pai_person.action_context_type = 'AAP';

             cursor get_person_count(p_pact_id  number,
                                     p_emp_name varchar2,
                                     p_category varchar2) is
             select count(*)
             from (select /*+ ORDERED use_nl(paf,paa,pai,pai_person)
		                      use_index(pai_person,pay_action_information_n2)
				              use_index(pai,pay_action_information_n2) */
                           pai_person.action_information10  -- Person id
                    from   pay_assignment_actions  paa,
       	     	           pay_action_information  pai,
       	     	           pay_action_information  pai_person
		            where  paa.payroll_action_id = p_pact_id
		            and    pai.action_context_id = paa.assignment_action_id
		            and    pai.action_context_type = 'AAP'
		            and    pai.action_information_category = p_category
		            and    pai_person.action_context_id = paa.assignment_action_id
		            and    pai_person.action_information_category = 'GB EMPLOYEE DETAILS'
		            and    pai_person.action_information9 = p_emp_name --p_employer_name
		            and    pai_person.action_context_type = 'AAP'
		            group by pai_person.action_information10);

            l_1a_total     number;
            l_n1a_total    number;
            l_car_fuel     number;
            l_van_fuel     number;
            l_mileage      number;
            l_person_count number;
            l_int_free_total number;

            PROCEDURE write_header(p_employer_name varchar2) IS
            BEGIN
                 fnd_file.put_line(fnd_file.output,'Employer Name : ' || p_employer_name);
                 fnd_file.put_line(fnd_file.output,
                              rpad('Benefit Type Element', 31) || rpad('Input Value', 29) ||
                              rpad('# People', 10) || rpad('# Entries', 10) ||
                              rpad('Class 1A',16) || rpad('Non Class 1A',15));
                 fnd_file.put_line(fnd_file.output,
                              rpad('-',30,'-') || ' ' ||
                              rpad('-',28,'-') || ' ' ||
                              rpad('-',9,'-')  || ' ' ||
                              rpad('-',9,'-')  || ' ' ||
                              rpad('-',15,'-') || ' ' ||
                              rpad('-',15,'-'));
            END write_header;

            PROCEDURE write_body(p_ben_name    varchar2,
                                 p_inp_name    varchar2,
                                 p_nos_entries varchar2,
                                 p_nos_person  varchar2,
                                 p_value       varchar2,
                                 p_class_A     boolean) IS
            BEGIN
                 if p_class_A then
                    fnd_file.put_line(fnd_file.output,
                    rpad(p_ben_name, 31) || rpad(p_inp_name, 29)  ||
                    lpad(p_nos_person,9) || ' ' || lpad(p_nos_entries,9) || ' ' ||
                    rpad(p_value,15) || ' ' || rpad(' ',15));
                 else
                    fnd_file.put_line(fnd_file.output,
                    rpad(p_ben_name,  31) || rpad(p_inp_name, 29)   ||
                    lpad(p_nos_person,9) || ' ' || lpad(p_nos_entries,9) || ' ' ||
                    rpad(' ',15) || ' ' || rpad(p_value,15));
                 end if;
            END write_body;

            PROCEDURE write_footer(p_class_a_value  varchar2,
                                   p_nclass_value   varchar2,
                                   p_total          varchar2) IS
            BEGIN
                 fnd_file.put_line(fnd_file.output,null);
                 fnd_file.put_line(fnd_file.output,rpad('Total',80) || rpad(p_class_a_value,15) || ' ' ||
                                                   rpad(p_nclass_value,15) || rpad(p_total,16));
                 fnd_file.put_line(fnd_file.output,null);
            END write_footer;

       BEGIN
            fnd_file.put_line(fnd_file.output,null);
            fnd_file.put_line(fnd_file.output,'P11D Summary Report');
            FOR employer IN get_employer(p_pact_id)
            LOOP
                l_1a_total := 0;
                l_n1a_total := 0;
                write_header(employer.action_information7);
                FOR benefit IN get_total(p_pact_id,employer.action_information7)
                LOOP
                    l_person_count := 0;
                    open get_person_count(p_pact_id, employer.action_information7, benefit.name);
                    fetch get_person_count into l_person_count;
                    close get_person_count;

                    if benefit.cat = 'E' then -- Mileage Allowance
                        open get_mileage(p_pact_id, employer.action_information7);
                        fetch get_mileage into l_mileage;
                        close get_mileage;
                        write_body(p_ben_name => benefit.name,
                                   p_inp_name => get_input_name(benefit.cat),
                                   p_nos_entries => benefit.no_of_entries,
                                   p_nos_person  => l_person_count,
                                   p_value       => to_char(l_mileage,'999,999,990.99'),
                                   p_class_A     => check_classA(benefit.cat, benefit.name));
                        if check_classA(benefit.cat, benefit.name) then
                           l_1a_total := l_1a_total + l_mileage;
                        else
                           l_n1a_total := l_n1a_total + l_mileage;
                        end if;
/* Added for the bug 8513401*/
                    elsif benefit.cat = 'H' then
                        open get_int_free_total(p_pact_id,employer.action_information7);
                        fetch get_int_free_total into l_int_free_total;
                        close get_int_free_total;
                        write_body(p_ben_name => benefit.name,
                                   p_inp_name => get_input_name(benefit.cat),
                                   p_nos_entries => benefit.no_of_entries,
                                   p_nos_person  => l_person_count,
                                   p_value       => to_char(nvl(l_int_free_total,0),'999,999,990.99'),
                                   p_class_A     => check_classA(benefit.cat, benefit.name));
                        if check_classA(benefit.cat, benefit.name) then
                           l_1a_total := l_1a_total + nvl(l_int_free_total,0);
                        else
                           l_n1a_total := l_n1a_total + nvl(l_int_free_total,0);
                        end if;
/* Added for the bug 8513401*/
                    else
                        write_body(p_ben_name => benefit.name,
                                   p_inp_name => get_input_name(benefit.cat),
                                   p_nos_entries => benefit.no_of_entries,
                                   p_nos_person  => l_person_count,
                                   p_value       => to_char(benefit.total,'999,999,990.99'),
                                   p_class_A     => check_classA(benefit.cat, benefit.name));
                        if check_classA(benefit.cat, benefit.name) then
                           l_1a_total := l_1a_total + benefit.total;
                        else
                           l_n1a_total := l_n1a_total + benefit.total;
                        end if;
                    end if;
                    if benefit.cat = 'F' then -- car
                       open get_car_fuel(p_pact_id, employer.action_information7);
                       fetch get_car_fuel into l_car_fuel;
                       close get_car_fuel;
                       write_body(p_ben_name => ' ',
                               p_inp_name => 'Cash Equivalent for Fuel',
                               p_nos_entries => benefit.no_of_entries,
                               p_nos_person  => ' ',
                               p_value       => to_char(l_car_fuel,'999,999,990.99'),
                               p_class_A     => true);
                       l_1a_total := l_1a_total + l_car_fuel;
                    end if;
                     if benefit.cat = 'O' then -- van
                       open get_van_fuel(p_pact_id, employer.action_information7);
                       fetch get_van_fuel into l_van_fuel;
                       close get_van_fuel;
                       write_body(p_ben_name => ' ',
                               p_inp_name => 'Cash Equivalent for Fuel',
                               p_nos_entries => benefit.no_of_entries,
                               p_nos_person  => ' ',
                               p_value       => to_char(l_van_fuel,'999,999,990.99'),
                               p_class_A     => true);
                       l_1a_total := l_1a_total + l_van_fuel;
                    end if;
                END LOOP;
                write_footer(to_char(l_1a_total,'999,999,990.99'),to_char(l_n1a_total,'999,999,990.99'),
                             to_char(l_1a_total + l_n1a_total,'999,999,990.99'));
            END LOOP;
       END write_summary;

       PROCEDURE write_error_log(p_pact_id  number)
       IS
            l_error_count number;
            l_warn_count  number;
            l_full_name   varchar2(255);
            l_element     varchar2(255);
            cursor get_message(p_pact_id varchar2,
                               p_msg_typ varchar2)
            is
            select distinct
                   pap.full_name,
                   paf.assignment_number,
                   pml.message_level,
                   substr(pml.line_text,instr(pml.line_text,':') + 2) line_text,
                   substr(pml.line_text,6,instr(pml.line_text,':') - 6) element_name,
                   pml.line_sequence
            from   pay_payroll_actions    pay,
                   pay_assignment_actions paa,
                   per_all_assignments_f  paf,
                   per_all_people_f       pap,
                   per_periods_of_service pos,
                   pay_message_lines      pml
            where  pay.payroll_action_id = p_pact_id
            and    paa.payroll_action_id = pay.payroll_action_id
            and    pml.source_id = paa.assignment_action_id
            and    pml.message_level = p_msg_typ
            and    pml.source_type   = 'A'
            and    substr(line_text,1,5) = 'P11D '
            and    substr(line_text,6,5) <> 'Error'
            and    paf.assignment_id = paa.assignment_id
            and    pap.person_id = paf.person_id
            and    pos.period_of_service_id(+) = paf.period_of_service_id
            and    nvl(pos.actual_termination_date, pay.effective_date) between
                   pap.effective_start_date and pap.effective_end_date
            order by paf.assignment_number, element_name, pml.line_sequence;

            PROCEDURE write_header(p_type varchar2) IS
            BEGIN
                 fnd_file.put_line(fnd_file.output,null);
                 if p_type = 'F' then
                    fnd_file.put_line(fnd_file.output,'The following assignments have completed with error');
                    fnd_file.put_line(fnd_file.output,rpad('Employee Name', 26) ||
                                                      rpad('Assignment Number', 18) ||
                                                      rpad('Error Message',87));
                 else
                    fnd_file.put_line(fnd_file.output,'The following assignments have completed with warning');
                    fnd_file.put_line(fnd_file.output,rpad('Employee Name', 26) ||
                                                      rpad('Assignment Number', 18) ||
                                                      rpad('Warning Message',87));
                 end if;
                 fnd_file.put_line(fnd_file.output,rpad('-',25,'-') || ' ' ||
                                                   rpad('-',17,'-') || ' ' ||
                                                   rpad('-',87,'-'));
            END write_header;

            PROCEDURE write_body(p_emp_name    varchar2,
                                 p_emp_no      varchar2,
                                 p_element     varchar2,
                                 p_message     varchar2) IS
                 l_msg varchar2(255) := p_message;
                 l_out varchar2(60);
                 l_first      boolean;
                 l_msg_length number;
                 l_count      number;
                 l_temp       number;
                 l_pos        number;
            BEGIN
                 select length(l_msg) into l_msg_length from dual;
                 l_first := true;
                 while l_msg_length > 57 loop
                    l_count := 1;
                    l_pos   := 0;
                    l_temp  := 1;
                    while l_temp > 0 and l_temp < 56 loop
                       l_pos := l_temp;
                       select instr(l_msg,' ',1,l_count) into l_temp from dual;
                       l_count := l_count + 1;
                    end loop;
                    select substr(l_msg,1,l_pos), substr(l_msg,l_pos + 1) into l_out, l_msg from dual;
                    select length(l_msg) into l_msg_length from dual;
                    if l_first then
                       l_first := false;
                       fnd_file.put_line(fnd_file.output,rpad(p_emp_name, 25) || ' ' ||
                                                         rpad(p_emp_no, 17)   || ' ' ||
                                                         rpad(nvl(p_element,' '),30) || '-' ||
                                                         rpad(l_out,56));
                    else
                       fnd_file.put_line(fnd_file.output,rpad(' ', 25) || ' ' ||
                                                         rpad(' ', 17) || ' ' ||
                                                         rpad(' ', 30) || ' ' ||
                                                         rpad(l_out,56));
                    end if;
                 end loop;
                 if l_first then
                    l_first := false;
                    fnd_file.put_line(fnd_file.output,rpad(p_emp_name, 25) || ' ' ||
                                                      rpad(p_emp_no, 17)   || ' ' ||
                                                      rpad(nvl(p_element,' '),30) || '-' ||
                                                      rpad(l_msg,56));
                 else
                     fnd_file.put_line(fnd_file.output,rpad(' ', 25) || ' ' ||
                                                       rpad(' ', 17) || ' ' ||
                                                       rpad(' ', 30) || ' ' ||
                                                       rpad(l_msg,56));
                 end if;
            END write_body;

            PROCEDURE write_footer(p_type  varchar2,
                                   p_total varchar2) IS
            BEGIN
                 fnd_file.put_line(fnd_file.output,null);
                 if p_type = 'F' then
                    fnd_file.put_line(fnd_file.output,rpad('Total Number of assignments with error :',45) || rpad(p_total,15));
                 else
                    fnd_file.put_line(fnd_file.output,rpad('Total Number of assignments with warning :',45) || rpad(p_total,15));
                 end if;
            END write_footer;

       BEGIN
            l_error_count := 0;
            l_warn_count  := 0;
            l_full_name   := ' ';
            l_element     := ' ';
            write_header('F');
            FOR error_messages in get_message(p_pact_id, 'F')
            LOOP
               if l_full_name <> error_messages.full_name then
                   write_body(error_messages.full_name,
                              error_messages.assignment_number,
                              error_messages.element_name,
                              error_messages.line_text);
                   l_full_name := error_messages.full_name;
                   l_error_count := l_error_count + 1;
                   l_element := error_messages.element_name;
                else
                   if l_element <> error_messages.element_name then
                       write_body(' ', ' ',error_messages.element_name, error_messages.line_text);
                       l_element := error_messages.element_name;
                   else
                       write_body(' ', ' ',' ', error_messages.line_text);
                   end if;
                end if;
            END LOOP;
            write_footer('F',l_error_count);

            write_header('W');
            l_full_name := ' ';
            l_element     := ' ';
            FOR warn_messages in get_message(p_pact_id, 'W')
            LOOP
               if l_full_name <> warn_messages.full_name then
                   write_body(warn_messages.full_name,
                              warn_messages.assignment_number,
                              warn_messages.element_name,
                              warn_messages.line_text);
                   l_full_name := warn_messages.full_name;
                   l_warn_count := l_warn_count + 1;
                   l_element := warn_messages.element_name;
                else
                   if l_element <> warn_messages.element_name then
                       write_body(' ', ' ',warn_messages.element_name, warn_messages.line_text);
                       l_element := warn_messages.element_name;
                   else
                       write_body(' ',' ',' ', warn_messages.line_text);
                   end if;
                end if;
            END LOOP;
            write_footer('W',l_warn_count);
       END write_error_log;

   BEGIN
      hr_utility.set_location('Entering '|| l_proc, 10);
      hr_utility.trace('Checking incorrect NI ');
      FOR incorrect_ni_num IN csr_incorrect_ni_num
      LOOP
        FOR total_num IN csr_total_num(incorrect_ni_num.action_information7)
        LOOP
         write_log(
            incorrect_ni_num.action_information7,
            NULL,
            NULL,
            ROUND(incorrect_ni_num.temp_num/total_num.tot_num * 100, 2)
            || '% of employees have temporary NI numbers or no NI numbers. ');
        END LOOP;
      END LOOP;
     -- FOR dup_ni_num IN csr_dup_ni_num
     -- LOOP
     --    write_log(
     --       dup_ni_num.employers_name,
     --       dup_ni_num.person_name,
     --       dup_ni_num.employee_num,
     --       'This employee has a duplicate NI number ' || dup_ni_num.ni_num);
     -- END LOOP;
      hr_utility.trace('Checking duplicate NI ');
      check_duplicate;

      write_summary(pactid);

      hr_utility.trace('Summing expenses payments ');
      FOR expenses_payment_chk IN csr_expenses_payment_chk
      LOOP
            fnd_file.put_line(fnd_file.output,
            'For Expenses Payments benefit, the Trading Orgainization Indicator has different values for different employees. ');
            fnd_file.put_line(fnd_file.output,
            'All employees in your Business Group must have the same Trading Orgainization Indicator. ');
      END LOOP;

      write_error_log(pactid);
      --hr_utility.trace('Summing P11D value  ');
      --FOR p11db_value IN csr_p11db_value
      --LOOP
      --   write_log(p11db_value.employers_name,
      --      NULL, NULL,
      --      'The figure for you to include in P11D(b) report is ' || ROUND(p11db_value.p11db_value, 2) );
      --END LOOP;

      hr_utility.set_location('Leaving '|| l_proc, 10);
   END;

   Function is_p11d_benefit_allowed
   (p_effective_date date,
    p_person_id Number
    )
    return number
    is
    l_ret Number;
    begin
        if
           hr_person_type_usage_info.is_person_of_type(p_effective_date,p_person_id,'EMP')
        or
           hr_person_type_usage_info.is_person_of_type(p_effective_date,p_person_id,'EMP_APL')
        or
           hr_person_type_usage_info.is_person_of_type(p_effective_date,p_person_id,'EX_EMP')
        or
           hr_person_type_usage_info.is_person_of_type(p_effective_date,p_person_id,'EX_EMP_APL')
        then
            l_ret := 1;
        else
            l_ret := 0;
        end if;
        return l_ret;
    end;

END; -- Package Body PAY_GB_P11D_ARCHIVE_SS

/
