--------------------------------------------------------
--  DDL for Package Body PQP_US_FF_FUNCTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_US_FF_FUNCTIONS" AS
/* $Header: pqusfffn.pkb 115.19 2002/12/02 23:42:36 rpinjala ship $ */
----------------------------------------------------------------------------+
-- FUNCTION GET_COL_VAL
----------------------------------------------------------------------------+
FUNCTION  get_col_val(p_assignment_id     IN NUMBER
                     ,p_payroll_action_id IN NUMBER
                     ,p_column_name       IN VARCHAR2
                     ,p_income_code       IN VARCHAR2 )
   RETURN varchar2 IS
   --+
   l_col_val        varchar2(60);
   l_string         varchar2(1000);
   --+
   l_effective_date date;
BEGIN
   l_effective_date := TRUNC(pqp_car_mileage_functions.pqp_get_date_paid
                                     (p_payroll_action_id));

   IF upper(p_column_name) IN ('CURRENT_RESIDENCY_STATUS',
                               'DATE_8233_SIGNED')  THEN
      l_string := 'SELECT pad.'||p_column_name ;
   ELSE
      l_string := 'SELECT NVL(pdd.'||p_column_name||', ''0'') ';
   END IF;
   l_string :=  l_string||
                ' FROM  pqp_analyzed_alien_data    pad,
                        pqp_analyzed_alien_details pdd
                 WHERE  pad.assignment_id     = :b1
                   AND  to_char(:b2,''yyyy'') = pad.tax_year
                   AND  pad.analyzed_data_id  = pdd.analyzed_data_id
                   AND  pdd.income_code       = :b3
                   AND  rownum < 2';
   --+
   BEGIN
      EXECUTE IMMEDIATE l_string INTO l_col_val
         USING p_assignment_id, l_effective_date, p_income_code;
      --+
      IF l_col_val IS NULL THEN
         l_col_val := '0';
      END IF;
      --+
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
         RETURN '0';
   END;
   --+
   RETURN l_col_val;
END get_col_val;

----------------------------------------------------------------------------+
-- FUNCTION STATE_HONORS_TREATY
----------------------------------------------------------------------------+
FUNCTION state_honors_treaty ( p_payroll_action_id IN NUMBER
                             ,p_ele_iv_jur_code    IN VARCHAR2
                             ,p_override_loc_state IN VARCHAR2 )
   RETURN varchar2 IS
   --+
   l_honor           pqp_alien_state_treaties_f.treaty_honored_flag%TYPE := 'N';
   l_state_code      pay_state_rules.state_code%TYPE;
   l_effective_date  date;
   --+
   CURSOR c_state_honor (l_state_code varchar2) IS
   SELECT pas.treaty_honored_flag
   FROM   pqp_alien_state_treaties_f pas
   WHERE  l_effective_date BETWEEN
          pas.effective_start_date AND pas.effective_end_date
     AND  pas.state_code = l_state_code;
   --+
   CURSOR c_jurisdiction IS
   SELECT state_code
   FROM   pay_state_rules
   WHERE  substr(jurisdiction_code,1,2) = substr(p_ele_iv_jur_code,1,2);
   --+
BEGIN
   l_effective_date := TRUNC(pqp_car_mileage_functions.pqp_get_date_paid
                                     (p_payroll_action_id));
   IF p_ele_iv_jur_code = 'NOT ENTERED' THEN
      l_state_code := p_override_loc_state;
   ELSE
      --+ get state-code for the user entered jurisdiction code
      FOR c_rec IN c_jurisdiction LOOP
         l_state_code := c_rec.state_code;
      END LOOP;
   END IF;
   --+
   --+ find out if the state honors the treaty
   --+
   FOR c_rec in c_state_honor (l_state_code) LOOP
      l_honor := c_rec.treaty_honored_flag;
   END LOOP;
   --+
   RETURN l_honor;
   --+
END state_honors_treaty;
--+
----------------------------------------------------------------------------+
-- FUNCTION ALIEN_TREATY_VALID
----------------------------------------------------------------------------+
FUNCTION alien_treaty_valid (p_assignment_id     IN NUMBER
                            ,p_payroll_action_id IN NUMBER
                            ,p_income_code       IN VARCHAR2 )
   RETURN varchar2 IS
   l_effective_date date;
   l_col_val        number;
   l_string         varchar2(1000);
   --+
BEGIN
   l_effective_date := TRUNC(pqp_car_mileage_functions.pqp_get_date_paid
                                     (p_payroll_action_id));
   l_string := 'SELECT 1
                FROM   pqp_analyzed_alien_data    pad,
                       pqp_analyzed_alien_details pdd
                WHERE  pad.assignment_id     = :b1
                  AND  to_char(:b2,''yyyy'') = pad.tax_year
                  AND  pad.analyzed_data_id  = pdd.analyzed_data_id
                  AND  :b2 BETWEEN NVL(treaty_benefits_start_date,:b2)
                               AND NVL(date_benefit_ends, :b2)
                  AND  pdd.income_code       = :b3
                  AND  rownum < 2';
   BEGIN
      EXECUTE IMMEDIATE l_string INTO l_col_val
         USING p_assignment_id,  l_effective_date, l_effective_date,
               l_effective_date, l_effective_date, p_income_code;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
         RETURN 'N';
   END;
   --+
   RETURN 'Y';
END alien_treaty_valid;
----------------------------------------------------------------------------+
-- FUNCTION GET_ALIEN_BAL
----------------------------------------------------------------------------+
--Note : IF the p_fit_wh_bal_flag = 'P' then this returns
--       the FIT pre tax balances. This has been done to
--       avoid adding another parameter to this pkg.

FUNCTION get_alien_bal(p_assignment_id     IN NUMBER
                      ,p_effective_date    IN DATE
                      ,p_payroll_action_id IN NUMBER   DEFAULT NULL
                      ,p_tax_unit_id       IN NUMBER   DEFAULT NULL
                      ,p_income_code       IN VARCHAR2 DEFAULT NULL
                      ,p_balance_name      IN VARCHAR2 DEFAULT NULL
                      ,p_dimension_name    IN VARCHAR2 DEFAULT NULL
                      ,p_state_code        IN VARCHAR2 DEFAULT NULL
                      ,p_fit_wh_bal_flag   IN VARCHAR2 DEFAULT 'N' )
   RETURN NUMBER IS
   --+
   l_bal_name     pay_balance_types.balance_name%type;
   l_dim_name     pay_balance_dimensions.dimension_name%type;
   l_def_bal_id   number;
   l_amt          number;
   l_tax_unit_id  varchar2(30);
   l_boolean      boolean := TRUE;
   l_jd_code      varchar2(30);
   l_effective_date date;
   --+
   CURSOR c_bal_name IS
   SELECT meaning
   FROM   hr_lookups
   WHERE  lookup_code = p_income_code
     AND  lookup_type = 'PQP_US_ALIEN_INCOME_BALANCE';
   --+
   CURSOR c_defined_bal IS
   SELECT pdb.defined_balance_id
   FROM   pay_balance_types      pbt,
          pay_defined_balances   pdb,
          pay_balance_dimensions pbd
   WHERE  pbt.balance_name         = l_bal_name
     AND  pbt.balance_type_id      = pdb.balance_type_id
     AND  pbd.balance_dimension_id = pdb.balance_dimension_id
     AND  pbd.dimension_name       = l_dim_name
     AND  NVL(pbd.legislation_code,'US')  = 'US';
   --+
   CURSOR c_tax_unit IS
   SELECT SFT.segment1
   FROM   hr_soft_coding_keyflex SFT,
          per_assignments_f      ASG
   WHERE  SFT.soft_coding_keyflex_id = ASG.soft_coding_keyflex_id
     AND  ASG.assignment_id          = p_assignment_id;
   --+
   CURSOR c_jurisdiction IS
   SELECT jurisdiction_code
   FROM   pay_state_rules
   WHERE  state_code = p_state_code;
   --+
BEGIN
   IF p_payroll_action_id IS NOT NULL THEN
   l_effective_date := TRUNC(pqp_car_mileage_functions.pqp_get_date_paid
                                     (p_payroll_action_id));
   ELSE
   l_effective_date :=p_effective_date;
   END IF;
   --+
   --+ If the dimension name is not passed default it
   --+
   IF p_dimension_name IS NULL OR p_dimension_name = 'NULL' THEN
      l_dim_name := 'Person within Government Reporting Entity Year to Date';
   ELSE
      l_dim_name := p_dimension_name;
   END IF;
   --+
   --+ If the income code is passed fetch the balance name
   --+
   IF p_income_code IS NOT NULL THEN
      FOR c_rec IN c_bal_name LOOP
        l_bal_name := c_rec.meaning;
      END LOOP;
   ELSE
      l_bal_name := p_balance_name;
   END IF;
   --+
   --+ If the requested balance is a withheld balance
   --+
   IF p_fit_wh_bal_flag = 'Y' THEN
      l_bal_name := l_bal_name||' FIT WH';
   END IF;
   --+
   --+ If the requested balance is a Pre-Tax balance
   --+
   IF p_fit_wh_bal_flag = 'P' THEN
      l_bal_name := l_bal_name||' FIT PT';
   END IF;
   --+
   --+
   --+ If the tax unit id is not passed then fetch it
   --+
   IF p_tax_unit_id IS NULL THEN
      FOR c_rec IN c_tax_unit LOOP
         l_tax_unit_id := c_rec.segment1;
      END LOOP;
   ELSE
      l_tax_unit_id := p_tax_unit_id;
   END IF;
   --+
   --+ set the tax unit id context
   --+
   pay_balance_pkg.set_context('tax_unit_id',  l_tax_unit_id);
   --+
   --+ fetch the defined balance it
   --+
   FOR c_rec IN c_defined_bal LOOP
     l_def_bal_id := c_rec.defined_balance_id;
   END LOOP;
   --+
   --+ Get the jurisdiction code and set the JD context
   --+
   IF NVL(p_state_code, 'NULL') <> 'NULL' THEN
      FOR c_rec IN c_jurisdiction LOOP
        l_jd_code := c_rec.jurisdiction_code;
      END LOOP;
      pay_balance_pkg.set_context('jurisdiction_code', l_jd_code);
   END IF;
   --+
   --+ Finally get the actual balance
   --+
   l_amt := pay_balance_pkg.get_value(l_def_bal_id,
                                      p_assignment_id,
                                      l_effective_date);
   --+
   RETURN l_amt;
   --+
END get_alien_bal;
----------------------------------------------------------------------------+
-- FUNCTION IS_WINDSTAR
----------------------------------------------------------------------------+
FUNCTION is_windstar(p_person_id        IN NUMBER  DEFAULT NULL
                    ,p_assignment_id    IN NUMBER  DEFAULT NULL)
   --+
   --+ Function to return TRUE/FALSE value if the assignment was/is being
   --+ processed by windstar
   --+
   RETURN VARCHAR2 IS
   --+
   l_result    VARCHAR2(30) := 'FALSE';
   --+
   CURSOR c_person IS
   SELECT 'x'
   FROM   per_people_extra_info   PEI
   WHERE  PEI.information_type  = 'PER_US_ADDITIONAL_DETAILS'
     AND  PEI.pei_information12 = 'WINDSTAR'
     AND  PEI.person_id         = p_person_id;
   --+
   CURSOR c_assignment IS
   SELECT 'x'
   FROM   per_people_extra_info   PEI,
          per_all_assignments_f   PAA
   WHERE  PEI.information_type  = 'PER_US_ADDITIONAL_DETAILS'
     AND  PEI.pei_information12 = 'WINDSTAR'
     AND  PEI.person_id         = PAA.person_id
     AND  PAA.assignment_id     = p_assignment_id;
   --+
BEGIN
   IF p_person_id IS NOT NULL THEN
      FOR c_rec in c_person LOOP
         l_result := 'TRUE';
         exit;
      END LOOP;
   ELSIF p_assignment_id IS NOT NULL THEN
      FOR c_rec IN c_assignment LOOP
         l_result := 'TRUE';
         exit;
      END LOOP;
   END IF;
   --+
   RETURN l_result;
   --+
END is_windstar;

----------------------------------------------------------------------------+
-- FUNCTION PQP_IS_WINDSTAR
----------------------------------------------------------------------------+
FUNCTION pqp_is_windstar( p_assignment_id    IN NUMBER  DEFAULT NULL)

   RETURN VARCHAR2 IS

l_ret_val VARCHAR2(30);
   --+
   --+ Function to return a true/false value if the assignment was/is being
   --+ processed by windstar. Function has been added as person_id
   --+ is not available as a CTX. This calls the function IS_WINDSTAR
   --+
BEGIN

   l_ret_val := is_windstar( NULL,p_assignment_id);
   RETURN l_ret_val;

END pqp_is_windstar;

----------------------------------------------------------------------------+
-- FUNCTION get_nonw2_bal
----------------------------------------------------------------------------+
FUNCTION  get_nonw2_bal (p_balance_name		IN VARCHAR2,
                        p_period	         	IN VARCHAR2,
                        p_assignment_action_id	IN NUMBER,
                        p_jurisdiction_code	IN VARCHAR2 DEFAULT NULL,
                        p_tax_unit_id		IN NUMBER)
RETURN NUMBER IS

  l_balance_amount      NUMBER;
  l_defined_balance_id  NUMBER;
  l_dimension_name      pay_balance_dimensions.dimension_name%type;

CURSOR c1 (c_balance_name varchar2, c_dimension_name varchar2) IS
   SELECT defined_balance_id
     FROM pay_defined_balances pdb,
          pay_balance_types pbt,
          pay_balance_dimensions pbd
    WHERE pdb.balance_type_id = pbt.balance_type_id
      AND pdb.balance_dimension_id = pbd.balance_dimension_id
      AND pbt.balance_name = c_balance_name
      AND pbd.dimension_name = c_dimension_name
      AND nvl(pdb.legislation_code, 'US') = 'US';

BEGIN

  IF p_balance_name = 'Non W2 FIT Withheld' THEN
     SELECT DECODE (upper(p_period),
                   'CURRENT','Assignment-Level Current Run',
                   'RUN','Assignment within Government Reporting Entity Run',
                   'PAY','Assignment within Government Reporting Entity Pay Date',
                   'MONTH','Assignment within Government Reporting Entity Month',
                   'QTD','Assignment within Government Reporting Entity Quarter to Date',
                   'YTD','Assignment within Government Reporting Entity Year to Date',null)
     INTO l_dimension_name
     FROM DUAL;
  ELSIF p_balance_name = 'SIT Alien Withheld' THEN
     SELECT DECODE (upper(p_period),
                   'RUN','Assignment in JD within GRE Run',
                   'MONTH','Assignment in JD within GRE Month',
                   'QTD','Assignment in JD within GRE Quarter to Date',
                   'YTD','Assignment in JD within GRE Year to Date',null)
     INTO l_dimension_name
     FROM DUAL;
  ELSE
     RETURN 0;
  END IF;

 l_balance_amount := 0;

  IF l_dimension_name IS NOT NULL THEN

     FOR c1_rec IN c1 (p_balance_name, l_dimension_name)
     LOOP
      l_defined_balance_id := c1_rec.defined_balance_id;
     END LOOP;

     --+ Set up the GRE and Jurisdicton context

     pay_balance_pkg.set_context('tax_unit_id', p_tax_unit_id);

     IF p_balance_name <> 'Non W2 FIT Withheld' THEN
       pay_balance_pkg.set_context('jurisdiction_code',p_jurisdiction_code);
     END IF;

     l_balance_amount := pay_balance_pkg.get_value(l_defined_balance_id,
                                                p_assignment_action_id);
  END IF;

  RETURN l_balance_amount;

END;

----------------------------------------------------------------------------+
-- FUNCTION GET_PREV_CONTRIB
----------------------------------------------------------------------------+
FUNCTION get_prev_contrib(p_assignment_id     IN NUMBER
                         ,p_payroll_action_id IN NUMBER
                         ,p_income_code       IN VARCHAR2 )
   --+
   --+ Function to return the previous contribution of the employee for the
   --+ income code
   --+
RETURN NUMBER IS
   --+
   l_result    NUMBER := 0;
   l_effective_date date;
   --+
   CURSOR c_prev_contrib IS
   SELECT pei.pei_information6
   FROM   per_people_extra_info pei
   WHERE  pei.pei_information7 = to_char(l_effective_date,'YYYY')
     AND  pei.pei_information5 = p_income_code
     AND  pei.information_type = 'PER_US_PAYROLL_DETAILS'
     AND  person_id IN
         (SELECT pas.person_id
          FROM   per_all_assignments_f pas
          WHERE  pas.assignment_id = p_assignment_id
            AND  l_effective_date BETWEEN pas.effective_start_date
                                  AND     pas.effective_end_date);
   --+
BEGIN
   l_effective_date := TRUNC(pqp_car_mileage_functions.pqp_get_date_paid
                                     (p_payroll_action_id));
   --+
   FOR c_rec in c_prev_contrib LOOP
      l_result := c_rec.pei_information6;
   END LOOP;
   --+
   RETURN l_result;
   --+
END get_prev_contrib;
--
----------------------------------------------------------------------------+
-- FUNCTION PQP_PROCESS_EVENTS_EXISTS
----------------------------------------------------------------------------+
FUNCTION pqp_process_events_exist(p_assignment_id   IN NUMBER
                                 ,p_income_code     IN VARCHAR2 )
   --+
   --+ Function to check whether there are any changes to the alien data that
   --+ are not analyzed by Windstar
   --+
RETURN VARCHAR2 IS
   --+
   CURSOR c_process_events IS
   SELECT ppe.process_event_id
   FROM   pay_process_events ppe
   WHERE  ppe.assignment_id = p_assignment_id
     AND  ppe.change_type   = 'PQP_US_ALIEN_WINDSTAR'
     AND  ppe.status        IN ('N','D','R'); --+ Not read,Read,Data validation error
   --+
   l_value varchar2(10) := 'N';
   --+
BEGIN
   --+
   FOR c_rec in c_process_events LOOP
      l_value := 'Y';
   END LOOP;
   --+
   RETURN l_value;
   --+
END pqp_process_events_exist;
--
----------------------------------------------------------------------------+
-- FUNCTION PQP_ALIEN_TAX_ELE_EXIST
----------------------------------------------------------------------------+
FUNCTION pqp_alien_tax_ele_exist (p_assignment_id          IN NUMBER
                                 ,p_effective_date         IN DATE
                                  )
   --+
   --+ Function to check whether the ALIEN_TAXATION element is attached if
   --+ there are earnings for classification Alien Earnings.
   --+ If the function returns 'N' then there is an Alien Earnings and the
   --+ ALIEN_TAXATION element is not attached.
   --+
RETURN VARCHAR2 IS
   --+
   CURSOR c_alien_earn_exist IS
   SELECT 'x'
   FROM   pay_element_entries_f       pee
         ,pay_element_links_f         pel
         ,pay_element_types_f         pet
         ,pay_element_classifications pec
   WHERE  pee.assignment_id       = p_assignment_id
     AND  pee.element_link_id     = pel.element_link_id
     AND  pel.element_type_id     = pet.element_type_id
     AND  pet.classification_id   = pec.classification_id
     AND  pec.classification_name = 'Alien/Expat Earnings'
     AND  pec.legislation_code    = 'US'
     AND  p_effective_date BETWEEN pee.effective_start_date
                               AND pee.effective_end_date
     AND  p_effective_date BETWEEN pel.effective_start_date
                               AND pel.effective_end_date
     AND  p_effective_date BETWEEN pet.effective_start_date
                               AND pet.effective_end_date;
   --+
   CURSOR c_alien_taxation IS
   SELECT 'x'
   FROM   pay_element_entries_f   pee
         ,pay_element_links_f     pel
         ,pay_element_types_f     pet
   WHERE  pee.assignment_id       = p_assignment_id
     AND  pee.element_link_id     = pel.element_link_id
     AND  pel.element_type_id     = pet.element_type_id
     AND  pet.element_name        = 'ALIEN_TAXATION'
     AND  p_effective_date BETWEEN pee.effective_start_date
                               AND pee.effective_end_date
     AND  p_effective_date BETWEEN pel.effective_start_date
                               AND pel.effective_end_date
     AND  p_effective_date BETWEEN pet.effective_start_date
                               AND pet.effective_end_date;
   --+
   l_exist   varchar2(1);
   --+
BEGIN
   FOR c_rec IN c_alien_earn_exist LOOP
      --+
      FOR c_rec_tax IN c_alien_taxation LOOP
         --+
         --+ All fine as ALIEN_TAXATION element is attached to the asg
         --+
         RETURN 'Y';
      END LOOP;
      --+
      --+ Alien earnings exists but ALIEN_TAXATION element is NOT attached to the asg
      --+
      RETURN 'N';
   END LOOP;
   --+
   --+ All fine as there are no Alien earnings and ALIEN_TAXATION
   --+ element is not required
   --+
   RETURN 'Y';
   --+
END pqp_alien_tax_ele_exist;
--
-------------------------------------------------------------------+
--
-- FUNCTION get_trr_nonw2_bal
--
-- ** NOTE ** Removed the Summing of balances for all the Asingments
--            and replaced the dimensions with the new GRE_JD dim.
--            14-JUN-2002 -- tmehra
--
-- Function to return the GRE level balances, Since we do no store
-- GRE level balances, we compute this by adding balances of all the
-- assignments for a given GRE. Function written to compute 'Non W2'
-- balances at the 'GRE' level.
-------------------------------------------------------------------+
FUNCTION get_trr_nonw2_bal (p_gre         IN NUMBER,
                            p_jd          IN VARCHAR2 DEFAULT NULL,
                            p_start_date  IN DATE,
                            p_end_date    IN DATE,
                            p_bal_name    IN VARCHAR2,
                            p_dim         IN VARCHAR2)
RETURN NUMBER IS

--
-- Cursor to get all the processed assignemtns in
-- a given GRE withing a date range
--

l_dimension        pay_balance_dimensions.dimension_name%type;
l_defined_bal_id   NUMBER;
l_def_pre_tax_id   NUMBER;
l_bal_name         pay_balance_types.balance_name%type;
l_bal_amt          NUMBER;
l_asg_action_id    NUMBER;
---------------------------------------+
-- Funtion to get the defined balance Id
-- for a given balance and dimension
---------------------------------------+
FUNCTION get_defined_bal_id (p_bal_name     VARCHAR2
                            ,p_dimension    VARCHAR2) RETURN number IS

l_id   number := 0;

 --+ Cursor to get the defined balance id for a given balance and a dimension

 CURSOR crs_get_defined_bal_id (p_bal_name   VARCHAR2
                               ,p_dimension  VARCHAR2) IS
   SELECT dbl.defined_balance_id
   FROM   pay_defined_balances dbl
   WHERE  dbl.balance_type_id  =
                (SELECT balance_type_id
                 FROM   pay_balance_types blt
                 WHERE  blt.balance_name = p_bal_name
                 AND    blt.legislation_code  = 'US')
                 AND    dbl.balance_dimension_id =
                             (SELECT balance_dimension_id
                              FROM   pay_balance_dimensions bld
                              WHERE  bld.database_item_suffix =
                                                '_'|| p_dimension
                              AND    bld.legislation_code  = 'US')
   AND    dbl.legislation_code  = 'US';

BEGIN
    --+ Get the defined balance id for the passed balance and dimension

   FOR i IN crs_get_defined_bal_id (p_bal_name, p_dimension)
   LOOP
      l_id := i.defined_balance_id;
   END LOOP;

   RETURN l_id;

END;

----------------------------------------+
-- end of the get_defined_bal_id function
----------------------------------------+

BEGIN

l_bal_amt           := 0;
l_asg_action_id     := NULL;

-- Commented out and replaced by the following line
-- on 13-Jun-2002 tmehra
-- pay_us_balance_view_pkg.set_context('TAX_UNIT_ID',p_gre);
-- pay_us_balance_view_pkg.set_context('DATE_EARNED',p_end_date);

pay_balance_pkg.set_context('TAX_UNIT_ID',p_gre);
pay_balance_pkg.set_context('DATE_EARNED',fnd_date.date_to_canonical(p_end_date));
pay_balance_pkg.set_context('BALANCE_DATE',fnd_date.date_to_canonical(p_start_date));

IF p_bal_name = 'Non W2 FIT' THEN

  IF p_dim = 'CTD' THEN
     l_dimension := 'GRE_PYDATE';
  ELSIF p_dim = 'MTD' THEN
     l_dimension := 'GRE_MONTH';
  ELSIF p_dim = 'QTD' THEN
     l_dimension := 'GRE_QTD';
  ELSIF p_dim = 'YTD' THEN
     l_dimension := 'GRE_YTD';
  END IF;

  l_defined_bal_id := get_defined_bal_id ('Non W2 FIT Withheld',l_dimension);

  l_bal_amt :=  pay_balance_pkg.get_value(l_defined_bal_id
                                          ,l_asg_action_id);
ELSIF p_bal_name = 'Non W2 SIT' THEN

  IF p_dim = 'CTD' THEN
     l_dimension := 'GRE_JD_PYDATE';
  ELSIF p_dim = 'MTD' THEN
     l_dimension := 'GRE_JD_MONTH';
  ELSIF p_dim = 'QTD' THEN
     l_dimension := 'GRE_JD_QTD';
  ELSIF p_dim = 'YTD' THEN
     l_dimension := 'GRE_JD_YTD';
  END IF;

  l_defined_bal_id := get_defined_bal_id ('SIT Alien Withheld',l_dimension);

  pay_balance_pkg.set_context('JURISDICTION_CODE',p_jd);

  l_bal_amt := pay_balance_pkg.get_value(l_defined_bal_id
                                        ,l_asg_action_id);


ELSIF p_bal_name = 'Non W2 FIT Wages' THEN

  IF p_dim = 'CTD' THEN
     l_dimension := 'GRE_PYDATE';
  ELSIF p_dim = 'MTD' THEN
     l_dimension := 'GRE_MONTH';
  ELSIF p_dim = 'QTD' THEN
     l_dimension := 'GRE_QTD';
  ELSIF p_dim = 'YTD' THEN
     l_dimension := 'GRE_YTD';
  END IF;

  l_defined_bal_id := get_defined_bal_id ('FIT Alien Subj Whable',l_dimension);
  l_def_pre_tax_id := get_defined_bal_id ('FIT Non W2 Pre Tax Dedns',l_dimension);

  l_bal_amt := l_bal_amt
                + pay_balance_pkg.get_value(l_defined_bal_id
                                           ,l_asg_action_id)
                - pay_balance_pkg.get_value(l_def_pre_tax_id
                                           ,l_asg_action_id);

ELSIF p_bal_name = 'Non W2 SIT Wages' THEN

  IF p_dim = 'CTD' THEN
     l_dimension := 'GRE_JD_PYDATE';
  ELSIF p_dim = 'MTD' THEN
     l_dimension := 'GRE_JD_MONTH';
  ELSIF p_dim = 'QTD' THEN
     l_dimension := 'GRE_JD_QTD';
  ELSIF p_dim = 'YTD' THEN
     l_dimension := 'GRE_JD_YTD';
  END IF;

  l_defined_bal_id := get_defined_bal_id ('SIT Alien Subj Whable',l_dimension);
  l_def_pre_tax_id := get_defined_bal_id ('SIT Non W2 Pre Tax Dedns',l_dimension);

  pay_balance_pkg.set_context('JURISDICTION_CODE',p_jd);

      l_bal_amt := l_bal_amt
                   + pay_balance_pkg.get_value(l_defined_bal_id
                                              ,l_asg_action_id)
                   - pay_balance_pkg.get_value(l_def_pre_tax_id
                                              ,l_asg_action_id);
END IF;


RETURN l_bal_amt;
END;
--------------------------------------------------------------------------+


END pqp_us_ff_functions;

/
