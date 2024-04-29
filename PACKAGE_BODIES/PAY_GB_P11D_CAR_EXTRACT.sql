--------------------------------------------------------
--  DDL for Package Body PAY_GB_P11D_CAR_EXTRACT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_GB_P11D_CAR_EXTRACT" AS
/* $Header: pygb11ce.pkb 120.3.12010000.4 2009/01/08 05:19:14 smeduri ship $ */

   -- Declare global variables:
   g_veh_rcd_id  NUMBER;
   g_ext_rslt_id NUMBER;
   g_person_id   NUMBER;
   g_bg_id       NUMBER;
---------------------------------------------------------------------------
--  Function:    GET_BUS_GROUP_ID
--  Desctiption: This function gets business group_id
---------------------------------------------------------------------------
FUNCTION get_bus_group_id (p_asg_id IN NUMBER) RETURN NUMBER IS
   --
   CURSOR get_bus_group_id IS
      SELECT  business_group_id
      FROM    per_all_assignments_f
      WHERE   assignment_id = p_asg_id;
   --
   l_bus_group_id NUMBER;
BEGIN
   -- Get Business Group ID
   OPEN get_bus_group_id;
   FETCH get_bus_group_id INTO l_bus_group_id;
   CLOSE get_bus_group_id;
   --
   RETURN l_bus_group_id;
   --
END get_bus_group_id;

---------------------------------------------------------------------------
--  Function:    GET_PARAM_EXT_START_DATE
--  Desctiption: This function gets value of extract start date parameter
---------------------------------------------------------------------------
FUNCTION get_param_ext_start_date(p_bus_group_id IN NUMBER) RETURN DATE IS
   --
   l_ext_start_date DATE;
   --
BEGIN
   BEGIN
      l_ext_start_date := fnd_date.displaydate_to_date(hruserdt.get_table_value(p_bus_group_id,
                                          'PAY GB P11D Car Extract',
                                          'Parameter Value',
                                          'Extract Start Date (DD-MON-YYYY)',
                                          ben_ext_person.g_effective_date ));
   EXCEPTION
      WHEN others THEN
         -- extract date parameter not set or wrong format
         -- default to start of fiscal year
         IF ben_ext_person.g_effective_date BETWEEN fnd_date.displaydate_to_date('01-JAN-'||to_char(ben_ext_person.g_effective_date,'YYYY'))
                  AND fnd_date.displaydate_to_date('05-APR-'||to_char(ben_ext_person.g_effective_date,'YYYY')) THEN
            l_ext_start_date := fnd_date.displaydate_to_date('06-APR-'||to_char(ben_ext_person.g_effective_date - 365, 'YYYY'));
         ELSE
            l_ext_start_date := fnd_date.displaydate_to_date('06-APR-'||to_char(ben_ext_person.g_effective_date,'YYYY'));
         END IF;
   END;
   --
   RETURN l_ext_start_date;
END get_param_ext_start_date;

---------------------------------------------------------------------------
--  Function:    GET_PARAM_EXT_END_DATE
--  Desctiption: This function gets value of extract end date parameter
---------------------------------------------------------------------------
FUNCTION get_param_ext_end_date(p_bus_group_id IN NUMBER) RETURN DATE IS
   --
   l_ext_end_date DATE;
   --
BEGIN
   BEGIN
      l_ext_end_date := fnd_date.displaydate_to_date(hruserdt.get_table_value(p_bus_group_id,
                                          'PAY GB P11D Car Extract',
                                          'Parameter Value',
                                          'Extract End Date (DD-MON-YYYY)',
                                          ben_ext_person.g_effective_date ));
   EXCEPTION
      WHEN others THEN
         -- extract date parameter not set or wrong format
         -- default to end of fiscal year
         IF ben_ext_person.g_effective_date BETWEEN fnd_date.displaydate_to_date('01-JAN-'||to_char(ben_ext_person.g_effective_date,'YYYY'))
                  AND fnd_date.displaydate_to_date('05-APR-'||to_char(ben_ext_person.g_effective_date,'YYYY')) THEN
            l_ext_end_date := fnd_date.displaydate_to_date('05-APR-'||to_char(ben_ext_person.g_effective_date,'YYYY'));
         ELSE
            l_ext_end_date := fnd_date.displaydate_to_date('05-APR-'||to_char(ben_ext_person.g_effective_date + 365, 'YYYY'));
         END IF;
   END;
   --
   RETURN l_ext_end_date;
END get_param_ext_end_date;

---------------------------------------------------------------------------
--  Function:    GET_PARAM_PAYROLL_ID
--  Desctiption: This function gets id of payroll name parameter
---------------------------------------------------------------------------
FUNCTION get_param_payroll_id(p_bus_group_id IN NUMBER) RETURN NUMBER IS
   --
   l_payroll_name pay_all_payrolls_f.payroll_name%TYPE;
   l_payroll_id   pay_all_payrolls_f.payroll_id%TYPE;
   --
   CURSOR get_payroll_id IS
   SELECT payroll_id
   FROM   pay_all_payrolls_f
   WHERE  payroll_name = l_payroll_name
   AND    nvl(business_group_id, p_bus_group_id) = p_bus_group_id
   AND    ben_ext_person.g_effective_Date BETWEEN effective_start_date AND effective_end_Date;
   --
BEGIN
   -- Get user Table Value
   BEGIN
      -- Get Payroll Name Parameter Value
      l_payroll_name := hruserdt.get_table_value(p_bus_group_id,
                                          'PAY GB P11D Car Extract',
                                          'Parameter Value',
                                          'Payroll Name',
                                          ben_ext_person.g_effective_date );
      --
      -- Get Payroll_id
      OPEN  get_payroll_id;
      FETCH get_payroll_id INTO l_payroll_id;
      CLOSE get_payroll_id;
      --
   EXCEPTION
      WHEN others THEN
         l_payroll_name := NULL;
         l_payroll_id := NULL;
   END;
   --
   RETURN l_payroll_id;
   --
END get_param_payroll_id;

---------------------------------------------------------------------------
--  Function:    GET_PARAM_PERSON_ID
--  Desctiption: This function gets person id based on employee number
--               parameter
---------------------------------------------------------------------------
FUNCTION get_param_person_id(p_bus_group_id IN NUMBER) RETURN NUMBER IS
   --
   l_employee_number per_all_people_f.employee_number%TYPE;
   l_person_id       per_all_people_f.person_id%TYPE;
   --
   CURSOR get_person_id IS
   SELECT person_id
   FROM   per_all_people_f
   WHERE  employee_number = l_employee_number
   AND    nvl(business_group_id, p_bus_group_id) = p_bus_group_id
   AND    ben_ext_person.g_effective_Date BETWEEN effective_start_date AND effective_end_Date;
   --
BEGIN
   BEGIN
      -- Get Employee Number Parameter Value
      l_employee_number := hruserdt.get_table_value(p_bus_group_id,
                                          'PAY GB P11D Car Extract',
                                          'Parameter Value',
                                          'Employee Number',
                                          ben_ext_person.g_effective_date );
      --
      -- Get Person Id
      OPEN  get_person_id;
      FETCH get_person_id INTO l_person_id;
      CLOSE get_person_id;
      --
   EXCEPTION
      WHEN others THEN
         l_employee_number := NULL;
         l_person_id := NULL;
   END;
   --
   RETURN l_person_id;
   --
END get_param_person_id;

---------------------------------------------------------------------------
--  Function:    GET_PARAM_TAX_DIST
--  Desctiption: This function gets value of Tax District Reference
--               parameter
---------------------------------------------------------------------------
FUNCTION get_param_tax_dist(p_bus_group_id IN NUMBER) RETURN VARCHAR2 IS
   --
   l_tax_dist hr_organization_information.org_information1%TYPE;
   --
BEGIN
   BEGIN
      -- Get Tax District Reference Parameter Value
      l_tax_dist := hruserdt.get_table_value(p_bus_group_id,
                                          'PAY GB P11D Car Extract',
                                          'Parameter Value',
                                          'Tax DIstrict Reference',
                                          ben_ext_person.g_effective_date );
      --
   EXCEPTION
      WHEN others THEN
         l_tax_dist  := NULL;
   END;
   --
   RETURN l_tax_dist;
   --
END get_param_tax_dist;

---------------------------------------------------------------------------
--  Function:    GET_PARAM_CONSOLIDATION_SET_ID
--  Desctiption: This function gets consolidation set id based on
--               consolidation set parameter
---------------------------------------------------------------------------
FUNCTION get_param_consolidation_set_id(p_bus_group_id IN NUMBER) RETURN NUMBER IS
   --
   l_consolidation_set    pay_consolidation_sets.consolidation_set_name%TYPE;
   l_consolidation_set_id pay_consolidation_sets.consolidation_set_id%TYPE;
   --
   CURSOR get_consolidation_set_id IS
   SELECT consolidation_set_id
   FROM   pay_consolidation_sets
   WHERE  consolidation_Set_name = l_consolidation_set
   AND    nvl(business_group_id, p_bus_group_id) = p_bus_group_id;
   --
BEGIN
   BEGIN
      -- Get Consolidation Set Parameter Value
      l_consolidation_set := hruserdt.get_table_value(p_bus_group_id,
                                          'PAY GB P11D Car Extract',
                                          'Parameter Value',
                                          'Consolidation Set',
                                          ben_ext_person.g_effective_date );
      --
      -- Get Consolidation Set Id
      OPEN  get_consolidation_set_id;
      FETCH get_consolidation_set_id INTO l_consolidation_set_id;
      CLOSE  get_consolidation_set_id;
      --
   EXCEPTION
      WHEN others THEN
         l_consolidation_set    := NULL;
         l_consolidation_set_id := NULL;
   END;
   --
   RETURN l_consolidation_set_id;
   --
END get_param_consolidation_set_id;

---------------------------------------------------------------------------
--  Function:    GET_PARAM_ASSIGNMENT_SET_ID
--  Desctiption: This function gets assignment set id based on
--               assignment set parameter
---------------------------------------------------------------------------
FUNCTION get_param_assignment_set_id(p_bus_group_id IN NUMBER) RETURN NUMBER IS
   --
   l_assignment_set    hr_assignment_sets.assignment_set_name%TYPE;
   l_assignment_set_id hr_assignment_sets.assignment_set_id%TYPE;
   --
   CURSOR get_assignment_set_id IS
   SELECT assignment_set_id
   FROM   hr_assignment_sets
   WHERE  assignment_set_name = l_assignment_set
   AND    nvl(business_group_id, p_bus_group_id) = p_bus_group_id;
   --
BEGIN
   BEGIN
      -- Get Assignment Set Parameter Value
      l_assignment_set := hruserdt.get_table_value(p_bus_group_id,
                                          'PAY GB P11D Car Extract',
                                          'Parameter Value',
                                          'Assignment Set',
                                          ben_ext_person.g_effective_date );
      --
      -- Get Assignment Set Id
      OPEN  get_assignment_set_id;
      FETCH get_assignment_set_id INTO l_assignment_set_id;
      CLOSE  get_assignment_set_id;
      --
   EXCEPTION
      WHEN others THEN
         l_assignment_set    := NULL;
         l_assignment_set_id := NULL;
   END;
   --
   RETURN l_assignment_set_id;
   --
END get_param_assignment_set_id;

---------------------------------------------------------------------------
-- Function:    GET_PRIM_ASG_START_DATE
-- Desctiption: This function gets effective start date of the assignment
---------------------------------------------------------------------------
FUNCTION get_prim_asg_start_date(p_assignment_id IN NUMBER)
RETURN VARCHAR2 IS
   --
   l_bus_group_id NUMBER;

   l_asg_start_date DATE;
   l_ext_start_date DATE;

   CURSOR csr_asg_start_date IS
    SELECT greatest(min(paf.effective_start_date),l_ext_start_date)
    FROM per_all_assignments_f paf
    WHERE paf.assignment_id = p_assignment_id;
BEGIN
   hr_utility.set_location('get_prim_asg_start_date',1);
   --
   l_bus_group_id := get_bus_group_id(p_assignment_id);
   l_ext_start_date := get_param_ext_start_date(l_bus_group_id);
   --
   hr_utility.set_location('get_prim_asg_start_date',2);
   --
   OPEN csr_asg_start_date;
   FETCH csr_asg_start_date INTO l_asg_start_date;
   CLOSE csr_asg_start_date;
   --
   hr_utility.trace('GET_PRIM_ASG_START_DATE: '||to_char(l_asg_start_date,'DD-MON-YYYY'));
   hr_utility.set_location('get_prim_asg_start_date',99);
   --
   RETURN to_char(l_asg_start_date,'DD-MON-YYYY');
    --
END get_prim_asg_start_date;

---------------------------------------------------------------------------
-- Function:    GET_PRIM_ASG_END_DATE
-- Desctiption: This function gets effective end date of the assignment
---------------------------------------------------------------------------
FUNCTION get_prim_asg_end_date(p_assignment_id IN NUMBER)
RETURN VARCHAR2 IS
   --
   l_bus_group_id NUMBER;

   l_asg_end_date DATE;
   l_ext_end_date DATE;

   CURSOR csr_asg_end_date IS
    select least(max(paf.effective_end_date),l_ext_end_date)
    from per_all_assignments_f paf,
         per_assignment_status_types past
    where paf.assignment_id = p_assignment_id
    and   past.per_system_status = 'ACTIVE_ASSIGN'
    and   paf.assignment_status_type_id = past.assignment_status_type_id;
BEGIN
   hr_utility.set_location('get_prim_asg_end_date',1);
   --
   l_bus_group_id := get_bus_group_id(p_assignment_id);
   l_ext_end_date := get_param_ext_end_date(l_bus_group_id);
   --
   hr_utility.set_location('get_prim_asg_end_date',2);
   --
   OPEN csr_asg_end_date;
   FETCH csr_asg_end_date INTO l_asg_end_date;
   CLOSE csr_asg_end_date;
   --
   hr_utility.trace('GET_PRIM_ASG_END_DATE: '||to_char(l_asg_end_date,'DD-MON-YYYY'));
   hr_utility.set_location('get_prim_asg_end_date',99);
   --
   RETURN to_char(l_asg_end_date,'DD-MON-YYYY');
    --
END get_prim_asg_end_date;

---------------------------------------------------------------------------
-- Function:    GET_PRIM_BEN_START_DATE
-- Desctiption: This function gets start date of primary car benefit from
--              effective start date of the assignment attributes table.
---------------------------------------------------------------------------
FUNCTION get_prim_ben_start_date(p_assignment_id IN NUMBER)
RETURN VARCHAR2 IS
   --
   l_ben_start_date DATE := NULL;
   l_ext_start_date DATE := NULL;
   l_ext_end_date   DATE := NULL;
   --
   CURSOR get_eff_start_date IS
   SELECT greatest(effective_start_date, l_ext_start_date) effective_start_date
   FROM   pqp_assignment_attributes_f
   WHERE  assignment_id = p_assignment_id
   AND    effective_start_date <= l_ext_end_date
   AND    effective_end_date >= l_ext_start_date
   AND    primary_company_car is NOT NULL
   ORDER BY effective_start_date ;
   --
BEGIN
   hr_utility.trace('Entering get_prim_ben_start_date, p_assignment_id='||p_assignment_id);
   -- Get extract start date parameter value
   l_ext_start_date := get_param_ext_start_date(get_bus_group_id(p_assignment_id));
   l_ext_end_date   := get_param_ext_end_date(get_bus_group_id(p_assignment_id));
   --
   -- Get effective start date
   OPEN  get_eff_start_date;
   FETCH get_eff_start_date INTO l_ben_start_date;
   CLOSE get_eff_start_date;
   --
   hr_utility.trace('Leaving get_prim_ben_start_date, l_ben_start_date='
                         ||to_char(l_ben_start_date, 'DD-MON-YYYY'));
   RETURN to_char(l_ben_start_date, 'DD-MON-YYYY');
   --
END get_prim_ben_start_date;

---------------------------------------------------------------------------
-- Function:    GET_PRIM_BEN_END_DATE
-- Desctiption: This function gets end date of primary car benefit from
--              effective end date of the assignment attributes table.
---------------------------------------------------------------------------
FUNCTION get_prim_ben_end_date(p_assignment_id IN NUMBER)
RETURN VARCHAR2 IS
   --
   l_ext_start_date DATE := NULL;
   l_ext_end_date   DATE := NULL;
   --
   CURSOR get_ben_details IS
   SELECT effective_start_date, effective_end_date,
          primary_car_fuel_benefit, primary_company_car
   FROM   pqp_assignment_attributes_f
   WHERE  assignment_id = p_assignment_id
   AND    effective_start_date <= l_ext_end_date
   AND    effective_end_date >= l_ext_start_date
   AND    primary_company_car is NOT NULL
   ORDER BY effective_start_date ;
   --
   ben_details_rec get_ben_details%ROWTYPE;
   --
   l_prev_eff_end_date DATE := NULL;
   l_prev_prim_car_fuel_ben VARCHAR2(30) := NULL;
   l_prev_prim_comp_car NUMBER := NULL;
   --
BEGIN
   hr_utility.trace('Entering get_prim_ben_end_date, p_assignment_id='||p_assignment_id);
   --
   l_ext_start_date := get_param_ext_start_date(get_bus_group_id(p_assignment_id));
   l_ext_end_date   := get_param_ext_end_date(get_bus_group_id(p_assignment_id));
   --
   -- Get benefit details
   OPEN  get_ben_details;
   FETCH get_ben_details INTO ben_details_rec;
   l_prev_eff_end_date := ben_details_rec.effective_end_date;
   l_prev_prim_car_fuel_ben := ben_details_rec.primary_car_fuel_benefit;
   l_prev_prim_comp_car := ben_details_rec.primary_company_car;
   --
   LOOP
      --
      FETCH get_ben_details INTO ben_details_rec;
      EXIT WHEN NOT (l_prev_eff_end_date +1 = ben_details_rec.effective_start_date
         AND nvl(l_prev_prim_car_fuel_ben, 'ZZ') = nvl(ben_details_rec.primary_car_fuel_benefit, 'ZZ')
         AND nvl(l_prev_prim_comp_car, -999) = nvl(ben_details_rec.primary_company_car, -999)
         AND get_ben_details%FOUND);
      --
      hr_utility.trace('GET_PRIM_BEN_END_DATE: In Loop, effective_start_date='
                        ||to_char(ben_details_rec.effective_start_date, 'DD-MON-YYYY'));
      hr_utility.trace('GET_PRIM_BEN_END_DATE: In Loop, effective_end_date='
                        ||to_char(ben_details_rec.effective_end_date, 'DD-MON-YYYY'));
      --
      l_prev_eff_end_date := ben_details_rec.effective_end_date;
      l_prev_prim_car_fuel_ben := ben_details_rec.primary_car_fuel_benefit;
      l_prev_prim_comp_car := ben_details_rec.primary_company_car;
      --
   END LOOP;
   --
   CLOSE get_ben_details;
   --
   hr_utility.trace('Leaving get_prim_ben_end_date, l_prev_eff_end_date='
                         ||to_char(l_prev_eff_end_date, 'DD-MON-YYYY'));
   RETURN to_char(least(l_prev_eff_end_date, l_ext_end_date), 'DD-MON-YYYY');
   --
END get_prim_ben_end_date;

---------------------------------------------------------------------------
-- Function:    GET_PRIM_VIN
-- Desctiption: This function gets Vehicle Identification Number of primary
--              car as of the benefit start date.
---------------------------------------------------------------------------
FUNCTION get_prim_vin(p_assignment_id IN NUMBER)
RETURN VARCHAR2 IS
   --
   l_vin    VARCHAR2(50) := NULL;
   l_ben_start_date DATE := NULL;
   --
   CURSOR get_vin IS
   SELECT pvd.vehicle_identification_number
   FROM   pqp_assignment_attributes_f paaf,
          pqp_vehicle_details pvd
   WHERE  l_ben_start_date BETWEEN paaf.effective_start_date
          AND  paaf.effective_end_date
   AND paaf.assignment_id = p_assignment_id -- comes from context
   AND pvd.vehicle_details_id = paaf.primary_company_car;
   --
BEGIN
   hr_utility.trace('Entering GET_PRIM_VIN, p_assignment_id='||p_assignment_id);
   --
   l_ben_start_date := fnd_date.displaydate_to_date(get_prim_ben_start_date(p_assignment_id));
   --
   -- Get Vehicle Identification Number
   OPEN  get_vin;
   FETCH get_vin INTO l_vin;
   CLOSE get_vin;
   --
   hr_utility.trace('Leaving GET_PRIM_VIN, l_vin='||l_vin);
   RETURN l_vin;
   --
END get_prim_vin;

---------------------------------------------------------------------------
-- Function:    GET_PRIM_MAKE
-- Desctiption: This function gets Make of primary
--              car as of the benefit start date.
---------------------------------------------------------------------------
FUNCTION get_prim_make(p_assignment_id IN NUMBER)
RETURN VARCHAR2 IS
   --
   l_make   VARCHAR2(30) := NULL;
   l_ben_start_date DATE := NULL;
   --
   CURSOR get_make IS
   SELECT pvd.make
   FROM   pqp_assignment_attributes_f paaf,
          pqp_vehicle_details pvd
   WHERE  l_ben_start_date BETWEEN paaf.effective_start_date
          AND  paaf.effective_end_date
   AND paaf.assignment_id = p_assignment_id -- comes from context
   AND pvd.vehicle_details_id = paaf.primary_company_car;
   --
BEGIN
   hr_utility.trace('Entering GET_PRIM_MAKE, p_assignment_id='||p_assignment_id);
   --
   l_ben_start_date := fnd_date.displaydate_to_date(get_prim_ben_start_date(p_assignment_id));
   --
   -- Get make
   OPEN  get_make;
   FETCH get_make INTO l_make;
   CLOSE get_make;
   --
   hr_utility.trace('Leaving GET_PRIM_MAKE, l_make='||l_make);
   RETURN l_make;
   --
END get_prim_make;

---------------------------------------------------------------------------
-- Function:    GET_PRIM_MODEL
-- Desctiption: This function gets Model of primary
--              car as of the benefit start date.
---------------------------------------------------------------------------
FUNCTION get_prim_model(p_assignment_id IN NUMBER) RETURN VARCHAR2 IS
   --
   l_model  VARCHAR2(30) := NULL;
   l_ben_start_date DATE := NULL;
   --
   CURSOR get_model IS
   SELECT pvd.model
   FROM   pqp_assignment_attributes_f paaf,
          pqp_vehicle_details pvd
   WHERE  l_ben_start_date BETWEEN paaf.effective_start_date
          AND  paaf.effective_end_date
   AND paaf.assignment_id = p_assignment_id -- comes from context
   AND pvd.vehicle_details_id = paaf.primary_company_car;
   --
BEGIN
   hr_utility.trace('Entering GET_PRIM_MODEL, p_assignment_id='||p_assignment_id);
   --
   l_ben_start_date := fnd_date.displaydate_to_date(get_prim_ben_start_date(p_assignment_id));
   --
   -- Get model
   OPEN  get_model;
   FETCH get_model INTO l_model;
   CLOSE get_model;
   --
   hr_utility.trace('Leaving GET_PRIM_MODEL, l_model='||l_model);
   RETURN l_model;
   --
END get_prim_model;

---------------------------------------------------------------------------
-- Function:    GET_PRIM_DFR
-- Desctiption: This function gets date of first registration of primary
--              car as of the benefit start date.
---------------------------------------------------------------------------
FUNCTION get_prim_dfr(p_assignment_id IN NUMBER) RETURN VARCHAR2 IS
   --
   l_dfr            DATE := NULL;
   l_ben_start_date DATE := NULL;
   --
   CURSOR get_dfr IS
   SELECT pvd.date_first_registered
   FROM   pqp_assignment_attributes_f paaf,
          pqp_vehicle_details pvd
   WHERE  l_ben_start_date BETWEEN paaf.effective_start_date
          AND  paaf.effective_end_date
   AND paaf.assignment_id = p_assignment_id -- comes from context
   AND pvd.vehicle_details_id = paaf.primary_company_car;
   --
BEGIN
   hr_utility.trace('Entering GET_PRIM_DFR, p_assignment_id='||p_assignment_id);
   --
   l_ben_start_date := fnd_date.displaydate_to_date(get_prim_ben_start_date(p_assignment_id));
   --
   -- Get date first registered
   OPEN  get_dfr;
   FETCH get_dfr INTO l_dfr;
   CLOSE get_dfr;
   --
   hr_utility.trace('Leaving GET_PRIM_DFR, l_dfr='||to_char(l_dfr, 'DD-MON-YYYY'));
   RETURN to_char(l_dfr, 'DD-MON-YYYY');
   --
END get_prim_dfr;

---------------------------------------------------------------------------
-- Function:    GET_PRIM_PRICE
-- Desctiption: This function gets price of primary
--              car as of the benefit start date.
---------------------------------------------------------------------------
FUNCTION get_prim_price(p_assignment_id IN NUMBER) RETURN VARCHAR2 IS
   --
   l_price        NUMBER := NULL;
   l_ben_start_date DATE := NULL;
   --
   CURSOR get_price IS
   SELECT decode(nvl(pvd.market_value_classic_car,0), 0, list_price, pvd.market_value_classic_car)
   FROM   pqp_assignment_attributes_f paaf,
          pqp_vehicle_details pvd
   WHERE  l_ben_start_date BETWEEN paaf.effective_start_date
          AND  paaf.effective_end_date
   AND paaf.assignment_id = p_assignment_id -- comes from context
   AND pvd.vehicle_details_id = paaf.primary_company_car;
   --
BEGIN
   hr_utility.trace('Entering GET_PRIM_PRICE, p_assignment_id='||p_assignment_id);
   --
   l_ben_start_date := fnd_date.displaydate_to_date(get_prim_ben_start_date(p_assignment_id));
   --
   -- Get price
   OPEN  get_price;
   FETCH get_price INTO l_price;
   CLOSE get_price;
   --
   hr_utility.trace('Leaving GET_PRIM_PRICE, l_price='||to_char(l_price));
   RETURN to_char(l_price);
   --
END get_prim_price;


---------------------------------------------------------------------------
-- Function:    GET_PRIM_FUEL_TYPE
-- Desctiption: This function gets fuel type of primary
--              car as of the benefit start date and then translates it
--              to GB_FUEL_TYPE lookup meaning.
---------------------------------------------------------------------------
FUNCTION get_prim_fuel_type(p_assignment_id IN NUMBER) RETURN VARCHAR2 IS
   --
   l_fuel_type      VARCHAR2(30) := NULL;
   l_fuel_meaning   VARCHAR2(80) := NULL;
   l_ben_start_date DATE := NULL;
   --
   CURSOR get_fuel_type IS
   SELECT hl.description --pvd.fuel_type -- Bug 5017957
   FROM   pqp_assignment_attributes_f paaf,
          pqp_vehicle_details pvd,
          hr_lookups  hl
   WHERE  l_ben_start_date BETWEEN paaf.effective_start_date AND  paaf.effective_end_date
   AND    paaf.assignment_id = p_assignment_id -- comes from context
   AND    pvd.vehicle_details_id = paaf.primary_company_car
   AND    hl.lookup_type = 'PQP_FUEL_TYPE'
   AND    hl.enabled_flag = 'Y'
   AND    hl.lookup_code = pvd.fuel_type
   AND    trunc(sysdate)  BETWEEN trunc(nvl(hl.start_date_active, sysdate-1)) AND trunc(nvl(hl.end_date_active, sysdate+1));
   --
   CURSOR get_translation IS
   SELECT Meaning
   FROM   hr_lookups -- Bug fix 3799560
   WHERE  lookup_type = 'GB_FUEL_TYPE'
   AND    trunc(sysdate)  BETWEEN trunc(nvl(start_date_active, sysdate-1)) AND trunc(nvl(end_date_active, sysdate+1))
   AND    enabled_flag = 'Y'
   AND    description = l_fuel_type
   ORDER BY lookup_code;
BEGIN
   hr_utility.trace('Entering GET_PRIM_FUEL_TYPE, p_assignment_id='||p_assignment_id);
   --
   l_ben_start_date := fnd_date.displaydate_to_date(get_prim_ben_start_date(p_assignment_id));
   --
   -- Get fuel type
   OPEN  get_fuel_type;
   FETCH get_fuel_type INTO l_fuel_type;
   CLOSE get_fuel_type;
   --
   hr_utility.trace('GET_PRIM_FUEL_TYPE: l_fuel_type='||l_fuel_type);
   --
   -- Get Translated Meaning
   OPEN  get_translation;
   FETCH get_translation INTO l_fuel_meaning;
   CLOSE get_translation;
   hr_utility.trace('Leaving GET_PRIM_FUEL_TYPE, l_fuel_meaning='||l_fuel_meaning);
   RETURN l_fuel_meaning;
   --
END get_prim_fuel_type;

---------------------------------------------------------------------------
-- Function:    GET_PRIM_CO2_EMI
-- Desctiption: This function gets CO2 Emission of primary
--              car as of the benefit start date.
---------------------------------------------------------------------------
FUNCTION get_prim_co2_emi(p_assignment_id IN NUMBER) RETURN VARCHAR2 IS
   --
   l_co2_emi      NUMBER := NULL;
   l_ben_start_date DATE := NULL;
   --
   CURSOR get_co2_emi IS
   SELECT pvd.co2_emissions
   FROM   pqp_assignment_attributes_f paaf,
          pqp_vehicle_details pvd
   WHERE  l_ben_start_date BETWEEN paaf.effective_start_date
          AND  paaf.effective_end_date
   AND paaf.assignment_id = p_assignment_id -- comes from context
   AND pvd.vehicle_details_id = paaf.primary_company_car;
   --
BEGIN
   hr_utility.trace('Entering GET_PRIM_CO2_EMI, p_assignment_id='||p_assignment_id);
   --
   l_ben_start_date := fnd_date.displaydate_to_date(get_prim_ben_start_date(p_assignment_id));
   --
   -- Get CO2 Emissions
   OPEN  get_co2_emi;
   FETCH get_co2_emi INTO l_co2_emi;
   CLOSE get_co2_emi;
   --
   hr_utility.trace('Leaving GET_PRIM_CO2_EMI, l_co2_emi='||to_char(l_co2_emi));
   RETURN to_char(l_co2_emi);
   --
END get_prim_co2_emi;


---------------------------------------------------------------------------
-- Function:    GET_PRIM_OPTIONAL_ACC
-- Desctiption: This function gets optional accessory value of primary
--              car as of the benefit start date.
---------------------------------------------------------------------------
FUNCTION get_prim_optional_acc(p_assignment_id IN NUMBER) RETURN VARCHAR2 IS
   --
   l_opt_acc      NUMBER := NULL;
   l_ben_start_date DATE := NULL;
   --
   CURSOR get_opt_acc IS
   SELECT decode(nvl(pvd.market_value_classic_car,0), 0, pvd.accessory_value_at_startdate, 0)
   FROM   pqp_assignment_attributes_f paaf,
          pqp_vehicle_details pvd
   WHERE  l_ben_start_date BETWEEN paaf.effective_start_date
          AND  paaf.effective_end_date
   AND paaf.assignment_id = p_assignment_id -- comes from context
   AND pvd.vehicle_details_id = paaf.primary_company_car;
   --
BEGIN
   hr_utility.trace('Entering GET_PRIM_OPTIONAL_ACC, p_assignment_id='||p_assignment_id);
   --
   l_ben_start_date := fnd_date.displaydate_to_date(get_prim_ben_start_date(p_assignment_id));
   --
   -- Get accessory value
   OPEN  get_opt_acc;
   FETCH get_opt_acc INTO l_opt_acc;
   CLOSE get_opt_acc;
   --
   hr_utility.trace('Leaving GET_PRIM_OPTIONAL_ACC, l_opt_acc='||to_char(l_opt_acc));
   RETURN to_char(l_opt_acc);
   --
END get_prim_optional_acc;

---------------------------------------------------------------------------
-- Function:    GET_PRIM_ACC_ADDED_AFTER
-- Desctiption: This function gets value of accessories added later to primary
--              car as of the benefit start date.
---------------------------------------------------------------------------
FUNCTION get_prim_acc_added_after(p_assignment_id IN NUMBER) RETURN VARCHAR2 IS
   --
   l_acc_added    NUMBER := NULL;
   l_ben_start_date DATE := NULL;
   --
   CURSOR get_acc_added IS
   SELECT pvd.accessory_value_added_later
   FROM   pqp_assignment_attributes_f paaf,
          pqp_vehicle_details pvd
   WHERE  l_ben_start_date BETWEEN paaf.effective_start_date
          AND  paaf.effective_end_date
   AND paaf.assignment_id = p_assignment_id -- comes from context
   AND pvd.vehicle_details_id = paaf.primary_company_car;
   --
BEGIN
   hr_utility.trace('Entering GET_PRIM_ACC_ADDED_AFTER, p_assignment_id='||p_assignment_id);
   --
   l_ben_start_date := fnd_date.displaydate_to_date(get_prim_ben_start_date(p_assignment_id));
   --
   -- Get accessory value added later
   OPEN  get_acc_added;
   FETCH get_acc_added INTO l_acc_added;
   CLOSE get_acc_added;
   --
   hr_utility.trace('Leaving GET_PRIM_ACC_ADDED_AFTER, l_acc_added='||to_char(l_acc_added));
   RETURN to_char(l_acc_added);
   --
END get_prim_acc_added_after;

---------------------------------------------------------------------------
-- Function:    GET_PRIM_CAPITAL_CONTRIB
-- Desctiption: This function gets value of capital contribution to primary
--              car as of the benefit start date.
---------------------------------------------------------------------------
FUNCTION get_prim_capital_contrib(p_assignment_id IN NUMBER) RETURN VARCHAR2 IS
   --
   l_cap_contrib    NUMBER := NULL;
   l_ben_start_date DATE := NULL;
   --
   CURSOR get_cap_contrib IS
   SELECT primary_capital_contribution
   FROM   pqp_assignment_attributes_f
   WHERE  l_ben_start_date BETWEEN effective_start_date
          AND effective_end_date
   AND assignment_id = p_assignment_id; -- comes from context
   --
BEGIN
   hr_utility.trace('Entering GET_PRIM_CAPITAL_CONTRIB, p_assignment_id='||p_assignment_id);
   --
   l_ben_start_date := fnd_date.displaydate_to_date(get_prim_ben_start_date(p_assignment_id));
   --
   -- Get Capital Contribution
   OPEN  get_cap_contrib;
   FETCH get_cap_contrib INTO l_cap_contrib;
   CLOSE get_cap_contrib;
   --
   hr_utility.trace('Leaving GET_PRIM_CAPITAL_CONTRIB, l_cap_contrib='||to_char(l_cap_contrib));
   RETURN to_char(l_cap_contrib);
   --
END get_prim_capital_contrib;


---------------------------------------------------------------------------
-- Function:    GET_PRIM_PRIVATE_CONTRIB
-- Desctiption: This function gets value of private contribution to primary
--              car as of the benefit start date.
---------------------------------------------------------------------------
FUNCTION get_prim_private_contrib(p_assignment_id IN NUMBER) RETURN VARCHAR2 IS
   --
   l_pri_contrib    NUMBER := NULL;
   l_ben_start_date DATE := NULL;
   --
   CURSOR get_pri_contrib IS
   SELECT primary_private_contribution
   FROM   pqp_assignment_attributes_f
   WHERE  l_ben_start_date BETWEEN effective_start_date
          AND effective_end_date
   AND assignment_id = p_assignment_id; -- comes from context
   --
BEGIN
   hr_utility.trace('Entering GET_PRIM_PRIVATE_CONTRIB, p_assignment_id='||p_assignment_id);
   --
   l_ben_start_date := fnd_date.displaydate_to_date(get_prim_ben_start_date(p_assignment_id));
   --
   -- Get Private Contribution
   OPEN  get_pri_contrib;
   FETCH get_pri_contrib INTO l_pri_contrib;
   CLOSE get_pri_contrib;
   --
   hr_utility.trace('Leaving GET_PRIM_PRIVATE_CONTRIB, l_pri_contrib='||to_char(l_pri_contrib));
   RETURN to_char(l_pri_contrib);
   --
END get_prim_private_contrib;


---------------------------------------------------------------------------
-- Function:    GET_PRIM_ENGINE_CAPACITY
-- Desctiption: This function gets engine capacity in cc of primary
--              car as of the benefit start date.
---------------------------------------------------------------------------
FUNCTION get_prim_engine_capacity(p_assignment_id IN NUMBER) RETURN VARCHAR2 IS
   --
   l_engine_cap   NUMBER := NULL;
   l_ben_start_date DATE := NULL;
   --
   CURSOR get_engine_cap IS
   SELECT pvd.engine_capacity_in_cc
   FROM   pqp_assignment_attributes_f paaf,
          pqp_vehicle_details pvd
   WHERE  l_ben_start_date BETWEEN paaf.effective_start_date
          AND  paaf.effective_end_date
   AND paaf.assignment_id = p_assignment_id -- comes from context
   AND pvd.vehicle_details_id = paaf.primary_company_car;
   --
BEGIN
   hr_utility.trace('Entering GET_PRIM_ENGINE_CAPACITY, p_assignment_id='||p_assignment_id);
   --
   l_ben_start_date := fnd_date.displaydate_to_date(get_prim_ben_start_date(p_assignment_id));
   --
   -- Get Engine Capacity
   OPEN  get_engine_cap;
   FETCH get_engine_cap INTO l_engine_cap;
   CLOSE get_engine_cap;
   --
   hr_utility.trace('Leaving GET_PRIM_ENGINE_CAPACITY, l_engine_cap='||to_char(l_engine_cap));
   RETURN to_char(l_engine_cap);
   --
END get_prim_engine_capacity;


---------------------------------------------------------------------------
-- Function:    GET_PRIM_FUEL_BENEFIT
-- Desctiption: This function gets value of fuel benefit flag for  primary
--              car as of the benefit start date.
---------------------------------------------------------------------------
FUNCTION get_prim_fuel_benefit(p_assignment_id IN NUMBER) RETURN VARCHAR2 IS
   --
   l_fuel_benefit   VARCHAR2(30) := NULL;
   l_ben_start_date DATE := NULL;
   --
   CURSOR get_fuel_benefit IS
   SELECT substr(primary_car_fuel_benefit, 1, 1)
   FROM   pqp_assignment_attributes_f
   WHERE  l_ben_start_date BETWEEN effective_start_date
          AND effective_end_date
   AND assignment_id = p_assignment_id; -- comes from context
   --
BEGIN
   hr_utility.trace('Entering GET_PRIM_FUEL_BENEFIT, p_assignment_id='||p_assignment_id);
   --
   l_ben_start_date := fnd_date.displaydate_to_date(get_prim_ben_start_date(p_assignment_id));
   --
   -- Get Fuel Benefit Flag
   OPEN  get_fuel_benefit;
   FETCH get_fuel_benefit INTO l_fuel_benefit;
   CLOSE get_fuel_benefit;
   --
   hr_utility.trace('Leaving GET_PRIM_FUEL_BENEFIT, l_fuel_benefit='||l_fuel_benefit);
   RETURN l_fuel_benefit;
   --
END get_prim_fuel_benefit;


---------------------------------------------------------------------------
-- Function:    GET_PRIM_VEHICLE_DETAILS_ID
-- Desctiption: This function gets Vehicle Details ID of primary
--              car as of the benefit start date.
---------------------------------------------------------------------------
FUNCTION get_prim_vehicle_details_id(p_assignment_id IN NUMBER) RETURN VARCHAR2 IS
   --
   l_Vehicle_details_id  NUMBER := NULL;
   l_ben_start_date DATE := NULL;
   --
   CURSOR get_vehicle_details_id IS
   SELECT primary_company_car
   FROM   pqp_assignment_attributes_f
   WHERE  l_ben_start_date BETWEEN effective_start_date
          AND effective_end_date
   AND assignment_id = p_assignment_id; -- comes from context
   --
BEGIN
   hr_utility.trace('Entering GET_PRIM_VEHICLE_DETAILS_ID, p_assignment_id='||p_assignment_id);
   --
   l_ben_start_date := fnd_date.displaydate_to_date(get_prim_ben_start_date(p_assignment_id));
   --
   hr_utility.trace('GET_PRIM_VEHICLE_DETAILS_ID: l_ben_start_date='||to_char(l_ben_start_date, 'DD-MON-YYYY'));
   --
   -- Get Vehicle Details Id
   OPEN  get_vehicle_details_id;
   FETCH get_vehicle_details_id INTO l_vehicle_details_id;
   CLOSE get_vehicle_details_id;
   --
   hr_utility.trace('Leaving GET_PRIM_VEHICLE_DETAILS_ID, l_vehicle_details_id='||to_char(l_vehicle_details_id));
   RETURN to_char(l_vehicle_details_id);
   --
END get_prim_vehicle_details_id;

---------------------------------------------------------------------------
-- Function:    CHECK_ASG_INCLUSION
-- Desctiption: This function checks whether given assignment satisfies
--              input criteria and vehicle exists within input date range
---------------------------------------------------------------------------
FUNCTION check_asg_inclusion(p_assignment_id IN NUMBER) RETURN VARCHAR2 IS
   --
   l_bus_group_id    NUMBER;
   l_ext_start_date  DATE;
   l_ext_end_Date    DATE;
   l_ext_payroll_id  NUMBER;
   l_ext_person_id   NUMBER;
   l_ext_tax_dist    VARCHAR2(150);
   l_ext_con_set_id  NUMBER;
   l_ext_asg_set_id  NUMBER;
   --
   l_asg_set_include VARCHAR2(1) := 'N';
   --
   l_asg_include VARCHAR2(1) := 'N';
   --
   CURSOR get_asg_eff_dates(p_asg_id IN NUMBER) IS
   SELECT min(effective_start_date) min_start_date, max(effective_end_date) max_end_Date
   FROM   per_all_assignments_f
   WHERE  assignment_id = p_asg_id;
   --
   l_min_start_date DATE;
   l_max_end_date   DATE;
   --
   CURSOR get_asg_details(p_asg_id IN NUMBER) IS
   SELECT pp.payroll_id, asg.person_id, pp.consolidation_set_id, flex.segment1 tax_dist
   FROM   pay_all_payrolls_f pp,
          per_all_assignments_f asg,
          hr_soft_coding_keyflex flex
   WHERE  asg.assignment_id = p_asg_id
   AND    asg.payroll_id = pp.payroll_id
   AND    ben_ext_person.g_effective_date BETWEEN pp.effective_start_date AND pp.effective_end_date
   AND    pp.soft_coding_keyflex_id = flex.soft_coding_keyflex_id
   AND    asg.effective_start_date < l_ext_end_date
   AND    asg.effective_end_Date > l_ext_start_date;
   --
   CURSOR check_asg_set_include(p_asg_id IN NUMBER) IS
   SELECT 'Y' include_flag
   FROM   hr_assignment_set_amendments hasa,
          hr_assignment_sets has,
          per_all_assignments_f paaf
   WHERE  has.assignment_set_id = l_ext_asg_set_id
   AND    paaf.assignment_id = p_asg_id
--   AND    ben_ext_person.g_effective_date BETWEEN paaf.effective_start_date AND paaf.effective_end_date
   AND    has.assignment_set_id = hasa.assignment_set_id (+)
   AND    NVL (hasa.assignment_id, paaf.assignment_id) = paaf.assignment_id
   AND    NVL (hasa.include_or_exclude, 'I') = 'I'
   AND    NVL (has.payroll_id, paaf.payroll_id) = paaf.payroll_id;
   --
   CURSOR check_vehicle_details(p_asg_id IN NUMBER) IS
   SELECT 'Y' vehicle_exist_flag
   FROM   pqp_assignment_attributes_f paa
   WHERE  paa.assignment_id = p_asg_id
   AND    paa.effective_start_date <= l_ext_end_date
   AND    paa.effective_end_date   >= l_ext_start_date
   AND    (paa.primary_company_car IS NOT NULL OR paa.secondary_company_car IS NOT NULL)
   AND    l_ext_start_date < fnd_date.canonical_to_date('2003/04/06')    -- BUG 3431106 Using canonical_to_date function
   UNION
   SELECT 'Y' vehicle_exist_flag
   FROM   pqp_vehicle_allocations_f paaf,
          pqp_vehicle_repository_f pvd
   WHERE  paaf.assignment_id = p_asg_id
   AND    paaf.effective_start_date <= l_ext_end_date
   AND    paaf.effective_end_date   >= l_ext_start_date
   AND    paaf.vehicle_repository_id IS NOT NULL
   AND    pvd.vehicle_repository_id = paaf.vehicle_repository_id
   AND    pvd.vehicle_type = 'C'
   AND    pvd.vehicle_ownership = 'C'
   AND    l_ext_start_date >= fnd_date.canonical_to_date('2003/04/06');   -- BUG 3431106 Using canonical_to_date function
BEGIN
   hr_utility.trace('Entering CHECK_ASG_INCLUSION, p_assignment_id='||p_assignment_id);
   -- Get Business Group Id
   l_bus_group_id := get_bus_group_id(p_assignment_id);
   -- Get Input Parameter Values
   l_ext_start_date := get_param_ext_start_date(l_bus_group_id);
   l_ext_end_date   := get_param_ext_end_date(l_bus_group_id);
   l_ext_payroll_id := get_param_payroll_id(l_bus_group_id);
   l_ext_person_id  := get_param_person_id(l_bus_group_id);
   l_ext_tax_dist   := get_param_tax_dist(l_bus_group_id);
   l_ext_con_set_id := get_param_consolidation_set_id(l_bus_group_id);
   l_ext_asg_set_id := get_param_assignment_set_id(l_bus_group_id);
   --
   hr_utility.trace('CHECK_ASG_INCLUSION: l_ext_start_date='||to_char(l_ext_start_date, 'DD-MON-YYYY'));
   hr_utility.trace('CHECK_ASG_INCLUSION: l_ext_end_date='||to_char(l_ext_end_date, 'DD-MON-YYYY'));
   hr_utility.trace('CHECK_ASG_INCLUSION: l_ext_payroll_id='||to_char(l_ext_payroll_id));
   hr_utility.trace('CHECK_ASG_INCLUSION: l_ext_tax_dist='||l_ext_tax_dist);
   hr_utility.trace('CHECK_ASG_INCLUSION: l_ext_con_set_id='||to_char(l_ext_con_set_id));
   hr_utility.trace('CHECK_ASG_INCLUSION: l_ext_asg_set_id='||to_char(l_ext_asg_set_id));
   --
   -- Get details of primary assignment
   -- Start with effective dates
   OPEN  get_asg_eff_dates(p_assignment_id);
   FETCH get_asg_eff_dates INTO l_min_start_date, l_max_end_date;
   CLOSE get_asg_eff_dates;
   --
   hr_utility.trace('CHECK_ASG_INCLUSION: l_min_start_date='||to_char(l_min_start_date, 'DD-MON-YYYY'));
   hr_utility.trace('CHECK_ASG_INCLUSION: l_max_end_date='||to_char(l_max_end_date, 'DD-MON-YYYY'));
   --
   IF l_min_start_date > l_ext_end_date OR l_max_end_date < l_ext_start_date THEN
      -- Person not active within input date range therefore exclude
      RETURN 'N';
   END IF;
   -- Check if assignment is included in the input assignment set
   IF l_ext_asg_set_id IS NOT NULL THEN
      -- Get asg set include flag
      OPEN  check_asg_set_include(p_assignment_id);
      FETCH check_asg_set_include INTO l_asg_set_include;
      CLOSE check_asg_set_include;
      --
   ELSE
      l_asg_set_include := 'Y';  -- no input asg set specified
   END IF;
   --
   hr_utility.trace('CHECK_ASG_INCLUSION: l_asg_set_include='||l_asg_set_include);
   -- Loop through all changes in the assignment during the input date range
   FOR asg_det_rec IN get_asg_details(p_assignment_id) LOOP
      --
      hr_utility.trace('CHECK_ASG_INCLUSION: asg_det_rec.payroll_id='||asg_det_rec.payroll_id);
      hr_utility.trace('CHECK_ASG_INCLUSION: asg_det_rec.person_id='||asg_det_rec.person_id);
      hr_utility.trace('CHECK_ASG_INCLUSION: asg_det_rec.tax_dist='||asg_det_rec.tax_dist);
      hr_utility.trace('CHECK_ASG_INCLUSION: asg_det_rec.consolidation_set_id='||asg_det_rec.consolidation_set_id);
      --
      IF (nvl(l_ext_payroll_id, nvl(asg_det_rec.payroll_id, -999)) = nvl(asg_det_rec.payroll_id, -999)
      AND nvl(l_ext_person_id, nvl(asg_det_rec.person_id, -999)) = nvl(asg_det_rec.person_id, -999)
      AND nvl(l_ext_tax_dist, nvl(asg_det_rec.tax_dist, 'ZZZ')) = nvl(asg_det_rec.tax_dist, 'ZZZ')
      AND nvl(l_ext_con_set_id, nvl(asg_det_rec.consolidation_set_id, -999)) = nvl(asg_det_rec.consolidation_set_id, -999)
      AND l_asg_set_include = 'Y') THEN
         -- Assignment satisfies input criteria,
         -- now check whether any vehicles exist during the input date range
         OPEN  check_vehicle_details(p_assignment_id);
         FETCH check_vehicle_details INTO l_asg_include;
         CLOSE check_vehicle_details;
         --
         hr_utility.trace('CHECK_ASG_INCLUSION: In Loop, l_asg_include='||l_asg_include);
      END IF;
   END LOOP;
   --
   hr_utility.trace('Leaving CHECK_ASG_INCLUSION, l_asg_include='||l_asg_include);
   RETURN l_asg_include;
   --
END check_asg_inclusion;

---------------------------------------------------------------------------
-- Function:    CHECK_PERSON_INCLUSION
-- Desctiption: This function checks all priamry and secondary assignments
--              for inclusion and returns Y is either of them should be
--              included.
---------------------------------------------------------------------------
FUNCTION check_person_inclusion(p_assignment_id IN NUMBER) RETURN VARCHAR2 IS
   --
   l_person_include VARCHAR2(1);
   --
   CURSOR get_all_asg IS
   SELECT distinct paa1.assignment_id
   FROM   per_all_assignments_f paa1, per_all_assignments_f paa2
   WHERE  paa2.assignment_id = p_assignment_id
   AND    paa2.person_id = paa1.person_id
   ORDER BY paa1.assignment_id;
   --
   l_asg_id NUMBER;
BEGIN
   hr_utility.trace('Entering CHECK_PERSON_INCLUSION, p_assignment_id='||p_assignment_id);
   --  check whether any assignment qualifies
   OPEN get_all_asg;
   LOOP
      FETCH get_all_asg INTO l_asg_id;
      IF get_all_asg%FOUND THEN
         l_person_include := check_asg_inclusion(l_asg_id);
      END IF;
      EXIT WHEN (get_all_asg%NOTFOUND OR l_person_include = 'Y');
   END LOOP;
   --
   hr_utility.trace('Leaving CHECK_PERSON_INCLUSION, l_person_include='||l_person_include);
   RETURN l_person_include;
   --
END check_person_inclusion;

---------------------------------------------------------------------------
-- Procedure:   CREATE_EXT_RSLT_DTL
-- Desctiption: This procedure will call BEN API to create an
--              extract result detail record
---------------------------------------------------------------------------
PROCEDURE create_ext_rslt_dtl( p_asg_id             IN NUMBER,
                              p_asg_start_date     IN DATE,
                              p_asg_end_date       IN DATE,
                              p_benefit_start_date IN DATE,
                              p_benefit_end_date   IN DATE,
                              p_car_fuel_benefit   IN VARCHAR2,
                              p_vehicle_details_id IN NUMBER) IS
   --
   CURSOR get_vehicle_details IS
   SELECT pvd.vehicle_identification_number,
          pvd.make,
          pvd.model,
          pvd.date_first_registered,
          decode(nvl(pvd.market_value_classic_car,0), 0, list_price, pvd.market_value_classic_car) price,
          h1.meaning trans_fuel_type,
          pvd.co2_emissions,
          decode(nvl(pvd.market_value_classic_car,0), 0, pvd.accessory_value_at_startdate, 0) optional_accessory,
          pvd.accessory_value_added_later,
          pvd.engine_capacity_in_cc
   FROM   pqp_vehicle_details pvd,
          hr_lookups  h1,  -- Bug fix 3799560
          hr_lookups  h2
   WHERE  pvd.vehicle_details_id = p_vehicle_details_id
   AND    pvd.fuel_type = h2.lookup_code
   AND    h2.lookup_type = 'PQP_FUEL_TYPE'
   AND    h2.enabled_flag = 'Y'
   AND    trunc(sysdate) BETWEEN trunc(nvl(h2.start_date_active, sysdate-1)) AND trunc(nvl(h2.end_date_active,sysdate+1))
   AND    h2.description = h1.description
   AND    h1.lookup_type = 'GB_FUEL_TYPE'
   AND    trunc(sysdate) BETWEEN trunc(nvl(h1.start_date_active, sysdate-1)) AND trunc(nvl(h1.end_date_active,sysdate+1))
   AND    h1.enabled_flag = 'Y';
   --
   CURSOR get_asg_attributes IS
   SELECT primary_capital_contribution,
          primary_private_contribution
   FROM   pqp_assignment_attributes_f
   WHERE  assignment_id = p_asg_id
   AND    p_benefit_start_date BETWEEN effective_start_date AND effective_end_date;
   --
   l_vehicle_rec get_vehicle_details%ROWTYPE;
   l_attribute_rec get_asg_attributes%ROWTYPE;
   --
   l_ext_rslt_dtl_id NUMBER;
   l_object_version_no NUMBER;
   --
   CURSOR chk_exists IS
   SELECT ext_rslt_dtl_id
   FROM   ben_ext_rslt_dtl
   WHERE  ext_rslt_id = g_ext_rslt_id
   AND    person_id = g_person_id
   AND    ext_rcd_id = g_veh_rcd_id
   AND    val_02 = to_char(p_asg_id)
   AND    val_04 = to_char(p_benefit_end_date, 'DD-MON-YYYY')
   AND    val_09 = to_char(p_benefit_start_Date, 'DD-MON-YYYY')
   AND    val_10 = to_char(p_benefit_end_date, 'DD-MON-YYYY')
   AND    val_29 = to_char(p_vehicle_details_id);
   --
   l_chk_exists chk_exists%ROWTYPE;
BEGIN
   hr_utility.trace('Entering CREATE_EXT_RSLT_DTL: p_asg_id='|| p_asg_id);
   hr_utility.trace('CREATE_EXT_RSLT_DTL: p_asg_start_date='||to_char(p_asg_start_date, 'DD-MON-YYYY'));
   hr_utility.trace('CREATE_EXT_RSLT_DTL: p_asg_end_date='||to_char(p_asg_end_date, 'DD-MON-YYYY'));
   hr_utility.trace('CREATE_EXT_RSLT_DTL: p_benefit_start_date='||to_char(p_benefit_start_date, 'DD-MON-YYYY'));
   hr_utility.trace('CREATE_EXT_RSLT_DTL: p_benefit_end_date='||to_char(p_benefit_end_date, 'DD-MON-YYYY'));
   hr_utility.trace('CREATE_EXT_RSLT_DTL: p_car_fuel_benefit='||p_car_fuel_benefit);
   hr_utility.trace('CREATE_EXT_RSLT_DTL: p_vehicle_details_id='||p_vehicle_details_id);
   hr_utility.trace('CREATE_EXT_RSLT_DTL: g_ext_rslt_id='||g_ext_rslt_id);
   hr_utility.trace('CREATE_EXT_RSLT_DTL: g_person_id='||g_person_id);
   hr_utility.trace('CREATE_EXT_RSLT_DTL: g_veh_rcd_id='||g_veh_rcd_id);
   -- Get Vehicle Details
   OPEN  get_vehicle_details;
   FETCH get_vehicle_details INTO l_vehicle_rec;
   CLOSE get_vehicle_details;
   -- Get Assignment Attributes
   OPEN  get_asg_attributes;
   FETCH get_asg_attributes INTO l_attribute_rec;
   CLOSE get_asg_attributes;
   --
   -- CHeck if record already exists
   OPEN chk_exists;
   FETCH chk_exists INTO l_chk_exists;
   --
   IF chk_exists%NOTFOUND THEN
      -- Record does not exist
      -- Call API to create extract details record
      BEGIN
         hr_utility.trace('CREATE_EXT_RSLT_DTL: Insert result details.');
         ben_ext_rslt_dtl_api.create_ext_rslt_dtl( p_ext_rslt_dtl_id   => l_ext_rslt_dtl_id
                                               ,p_ext_rslt_id       => g_ext_rslt_id
                                               ,p_ext_rcd_id        => g_veh_rcd_id
                                               ,p_person_id         => g_person_id
                                               ,p_business_group_id => g_bg_id
                                               ,p_val_01            => 'A'
                                               ,p_val_02            => to_char(p_asg_id)
                                               ,p_val_03            => '~~~~~~~~~~~~~~~~~~~~~~~~~'
                                               ,p_val_04            => to_char(p_benefit_end_Date, 'DD-MON-YYYY')
                                               ,p_val_05            => to_char(p_asg_start_date, 'DD-MON-YYYY')
                                               ,p_val_06            => to_char(p_asg_end_date, 'DD-MON-YYYY')
                                               ,p_val_07            => 'Car and Car Fuel'
                                               ,p_val_08            => '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
                                               ,p_val_09            => to_char(p_benefit_start_Date, 'DD-MON-YYYY')
                                               ,p_val_10            => to_char(p_benefit_end_date, 'DD-MON-YYYY')
                                               ,p_val_11            => l_vehicle_rec.vehicle_identification_number
                                               ,p_val_12            => l_vehicle_rec.make
                                               ,p_val_13            => l_vehicle_rec.model
                                               ,p_val_14            => to_char(l_vehicle_rec.date_first_registered, 'DD-MON-YYYY')
                                               ,p_val_15            => to_char(l_vehicle_rec.price)
                                               ,p_val_16            => '~'
                                               ,p_val_17            => l_vehicle_rec.trans_fuel_type
                                               ,p_val_18            => to_char(l_vehicle_rec.co2_emissions)
                                               ,p_val_19            => '~~~'
                                               ,p_val_20            => 'GB_EXTERNAL_REPORTING_CAR_2003'
                                               ,p_val_21            => to_char(l_vehicle_rec.optional_accessory)
                                               ,p_val_22            => to_char(l_vehicle_rec.accessory_value_added_later)
                                               ,p_val_23            => to_char(l_attribute_rec.primary_capital_contribution)
                                               ,p_val_24            => to_char(l_attribute_rec.primary_private_contribution)
                                               ,p_val_25            => to_char(l_vehicle_rec.engine_capacity_in_cc)
                                               ,p_val_26            => '~~~~'
                                               ,p_val_27            => p_car_fuel_benefit
                                               ,p_val_28            => '~~~~~~~~~~~~~~~~~~~'
                                               ,p_val_29            => to_char(p_vehicle_details_id)
                                               ,p_object_version_number => l_object_version_no);
      EXCEPTION WHEN others THEN
         hr_utility.trace('CREATE_EXT_RSLT_DTL: '||substr(sqlerrm, 1, 100));
         hr_utility.trace('CREATE_EXT_RSLT_DTL: '||substr(sqlerrm, 101, 100));
         hr_utility.trace('CREATE_EXT_RSLT_DTL: '||substr(sqlerrm, 201, 100));
         hr_utility.trace('CREATE_EXT_RSLT_DTL: '||substr(sqlerrm, 301, 100));
         RAISE;
      END;
   END IF;
   --
   CLOSE chk_exists;
   --
END create_ext_rslt_dtl;
---------------------------------------------------------------------------
-- Procedure:   PROCESS_PRIM_VEH
-- Desctiption: This procedure will create an extract result detail record
--              for the primary vehicle benefit
---------------------------------------------------------------------------
PROCEDURE process_prim_veh(p_asg_id IN NUMBER) IS
   --
   l_ext_start_date DATE := NULL;
   l_ext_end_date   DATE := NULL;
   --
   l_asg_start_date DATE := NULL;
   l_asg_end_date   DATE := NULL;
   --
   CURSOR get_veh_id IS
   SELECT greatest(effective_start_date, l_ext_start_date) effective_start_date,
          least(effective_end_date, l_ext_end_date) effective_end_date,
          primary_car_fuel_benefit, primary_company_car
   FROM   pqp_assignment_attributes_f
   WHERE  assignment_id = p_asg_id
   AND    effective_start_date <= l_ext_end_date
   AND    effective_end_date >= l_ext_start_date
   AND    primary_company_car is NOT NULL
   ORDER BY effective_start_date ;
   --
   l_veh_id_rec get_veh_id%ROWTYPE;
   l_prev_veh_id_rec get_veh_id%ROWTYPE;
   --
   l_new_rec BOOLEAN := TRUE;
BEGIN
   hr_utility.trace('Entering PROCESS_PRIM_VEH, p_asg_id='||p_asg_id);
   -- Get extract date parameter values
   l_ext_start_date := get_param_ext_start_date(get_bus_group_id(p_asg_id));
   l_ext_end_date   := get_param_ext_end_date(get_bus_group_id(p_asg_id));
   -- Get Assignment Start and End Dates
   l_asg_start_date := fnd_date.displaydate_to_date(get_prim_asg_start_date(p_asg_id));
   l_asg_end_date   := fnd_date.displaydate_to_date(get_prim_asg_end_date(p_asg_id));
   --
   OPEN get_veh_id;
   -- Loop through all vehicle records and create extract result detail
   -- record if there is a change in primary_car_fuel_benifit or vehicle id
   LOOP
      FETCH get_veh_id INTO l_veh_id_rec;
      hr_utility.trace('PROCESS_PRIM_VEH, After Fetch.');
      hr_utility.trace('PROCESS_PRIM_VEH, effective_start_date='||to_char(l_veh_id_rec.effective_start_date, 'DD-MON-YYYY'));
      hr_utility.trace('PROCESS_PRIM_VEH, effective_end_date='||to_char(l_veh_id_rec.effective_end_date, 'DD-MON-YYYY'));
      hr_utility.trace('PROCESS_PRIM_VEH, primary_car_fuel_benefit='||l_veh_id_rec.primary_car_fuel_benefit);
      hr_utility.trace('PROCESS_PRIM_VEH, primary_company_car='||l_veh_id_rec.primary_company_car);
      IF l_new_rec THEN
         hr_utility.trace('PROCESS_PRIM_VEH, l_new_rec=TRUE');
      ELSE
         hr_utility.trace('PROCESS_PRIM_VEH, l_new_rec=FALSE');
      END IF;
      --
      IF get_veh_id%FOUND THEN
         IF l_new_rec THEN
            l_prev_veh_id_rec.effective_start_date := l_veh_id_rec.effective_start_date;
            l_prev_veh_id_rec.effective_end_date := l_veh_id_rec.effective_end_date;
            l_prev_veh_id_rec.primary_car_fuel_benefit := l_veh_id_rec.primary_car_fuel_benefit;
            l_prev_veh_id_rec.primary_company_car := l_veh_id_rec.primary_company_car;
            l_new_rec := FALSE;
         ELSE
            IF nvl(l_prev_veh_id_rec.primary_car_fuel_benefit, 'N') = nvl(l_veh_id_rec.primary_car_fuel_benefit, 'N')
               AND nvl(l_prev_veh_id_rec.primary_company_car, -999) = nvl(l_veh_id_rec.primary_company_car, -999) THEN
               -- vehicle benefits did not change therefore continue looping
               l_prev_veh_id_rec.effective_end_date := l_veh_id_rec.effective_end_date;
            ELSE
               -- Vehicle Details have changed therefore create reslt dtl record
               hr_utility.trace('PROCESS_PRIM_VEH: Creating Vehicle Record for this assignment.');
               create_ext_rslt_dtl(p_asg_id, l_asg_start_date, l_asg_end_date,
                                   l_prev_veh_id_rec.effective_start_date,
                                   l_prev_veh_id_rec.effective_end_date,
                                   l_prev_veh_id_rec.primary_car_fuel_benefit,
                                   l_prev_veh_id_rec.primary_company_car);
               --
               l_prev_veh_id_rec.effective_start_date := l_veh_id_rec.effective_start_date;
               l_prev_veh_id_rec.effective_end_date := l_veh_id_rec.effective_end_date;
               l_prev_veh_id_rec.primary_car_fuel_benefit := l_veh_id_rec.primary_car_fuel_benefit;
               l_prev_veh_id_rec.primary_company_car := l_veh_id_rec.primary_company_car;
            END IF;
         END IF;
      ELSE
         -- Last record reched, create ext rslt dtl record
         IF l_prev_veh_id_rec.primary_company_car IS NOT NULL THEN
            hr_utility.trace('PROCESS_PRIM_VEH: Creating Last Vehicle Record for this assignment.');
            create_ext_rslt_dtl(p_asg_id, l_asg_start_date, l_asg_end_date,
                               l_prev_veh_id_rec.effective_start_date,
                               l_prev_veh_id_rec.effective_end_date,
                               l_prev_veh_id_rec.primary_car_fuel_benefit,
                               l_prev_veh_id_rec.primary_company_car);
         END IF;
         --
         EXIT;
      END IF;
   END LOOP;
   --
   hr_utility.trace('Leaving PROCESS_PRIM_VEH.');
   --
END process_prim_veh;

---------------------------------------------------------------------------
-- Procedure:   PROCESS_SEC_VEH
-- Desctiption: This procedure will create an extract result detail record
--              for the secondary vehicle benefit
---------------------------------------------------------------------------
PROCEDURE process_sec_veh(p_asg_id IN NUMBER) IS
   --
   l_ext_start_date DATE := NULL;
   l_ext_end_date   DATE := NULL;
   --
   l_asg_start_date DATE := NULL;
   l_asg_end_date   DATE := NULL;
   --
   CURSOR get_veh_id IS
   SELECT greatest(effective_start_date, l_ext_start_date) effective_start_date,
          least(effective_end_date, l_ext_end_date) effective_end_date,
          secondary_car_fuel_benefit, secondary_company_car
   FROM   pqp_assignment_attributes_f
   WHERE  assignment_id = p_asg_id
   AND    effective_start_date <= l_ext_end_date
   AND    effective_end_date >= l_ext_start_date
   AND    secondary_company_car is NOT NULL
   ORDER BY effective_start_date ;
   --
   l_veh_id_rec get_veh_id%ROWTYPE;
   l_prev_veh_id_rec get_veh_id%ROWTYPE;
   --
   l_new_rec BOOLEAN := TRUE;
BEGIN
   hr_utility.trace('Entering PROCESS_SEC_VEH, p_asg_id='||p_asg_id);
   -- Get extract date parameter values
   l_ext_start_date := get_param_ext_start_date(get_bus_group_id(p_asg_id));
   l_ext_end_date   := get_param_ext_end_date(get_bus_group_id(p_asg_id));
   -- Get Assignment Start and End Dates
   l_asg_start_date := fnd_date.displaydate_to_date(get_prim_asg_start_date(p_asg_id));
   l_asg_end_date   := fnd_date.displaydate_to_date(get_prim_asg_end_date(p_asg_id));
   --
   OPEN get_veh_id;
   -- Loop through all vehicle records and create extract result detail
   -- record if there is a change in secondary_car_fuel_benefit or vehicle id
   LOOP
      FETCH get_veh_id INTO l_veh_id_rec;
      hr_utility.trace('PROCESS_SEC_VEH, After Fetch.');
      hr_utility.trace('PROCESS_SEC_VEH, effective_start_date='||to_char(l_veh_id_rec.effective_start_date, 'DD-MON-YYYY'));
      hr_utility.trace('PROCESS_SEC_VEH, effective_end_date='||to_char(l_veh_id_rec.effective_end_date, 'DD-MON-YYYY'));
      hr_utility.trace('PROCESS_SEC_VEH, secondary_car_fuel_benefit='||l_veh_id_rec.secondary_car_fuel_benefit);
      hr_utility.trace('PROCESS_SEC_VEH, secondary_company_car='||l_veh_id_rec.secondary_company_car);
      IF l_new_rec THEN
         hr_utility.trace('PROCESS_SEC_VEH, l_new_rec=TRUE');
      ELSE
         hr_utility.trace('PROCESS_SEC_VEH, l_new_rec=FALSE');
      END IF;
      --
      IF get_veh_id%FOUND THEN
         IF l_new_rec THEN
            l_prev_veh_id_rec.effective_start_date := l_veh_id_rec.effective_start_date;
            l_prev_veh_id_rec.effective_end_date := l_veh_id_rec.effective_end_date;
            l_prev_veh_id_rec.secondary_car_fuel_benefit := l_veh_id_rec.secondary_car_fuel_benefit;
            l_prev_veh_id_rec.secondary_company_car := l_veh_id_rec.secondary_company_car;
            l_new_rec := FALSE;
         ELSE
            IF nvl(l_prev_veh_id_rec.secondary_car_fuel_benefit, 'N') = nvl(l_veh_id_rec.secondary_car_fuel_benefit, 'N')
               AND nvl(l_prev_veh_id_rec.secondary_company_car, -999) = nvl(l_veh_id_rec.secondary_company_car, -999) THEN
               -- vehicle benefits did not change therefore continue looping
               l_prev_veh_id_rec.effective_end_date := l_veh_id_rec.effective_end_date;
            ELSE
               -- Vehicle Details have changed therefore create reslt dtl record
               create_ext_rslt_dtl(p_asg_id, l_asg_start_date, l_asg_end_date,
                                   l_prev_veh_id_rec.effective_start_date,
                                   l_prev_veh_id_rec.effective_end_date,
                                   l_prev_veh_id_rec.secondary_car_fuel_benefit,
                                   l_prev_veh_id_rec.secondary_company_car);
               --
               l_prev_veh_id_rec.effective_start_date := l_veh_id_rec.effective_start_date;
               l_prev_veh_id_rec.effective_end_date := l_veh_id_rec.effective_end_date;
               l_prev_veh_id_rec.secondary_car_fuel_benefit := l_veh_id_rec.secondary_car_fuel_benefit;
               l_prev_veh_id_rec.secondary_company_car := l_veh_id_rec.secondary_company_car;
            END IF;
         END IF;
      ELSE
         -- Last record reched, create ext rslt dtl record
         IF l_prev_veh_id_rec.secondary_company_car IS NOT NULL THEN
            create_ext_rslt_dtl(p_asg_id, l_asg_start_date, l_asg_end_date,
                                l_prev_veh_id_rec.effective_start_date,
                                l_prev_veh_id_rec.effective_end_date,
                                l_prev_veh_id_rec.secondary_car_fuel_benefit,
                                l_prev_veh_id_rec.secondary_company_car);
         END IF;
         --
         EXIT;
      END IF;
   END LOOP;
   --
   hr_utility.trace('Leaving PROCESS_SEC_VEH.');
   --
END process_sec_veh;

---------------------------------------------------------------------------
-- Procedure:   PROCESS_SEC_ASG
-- Desctiption: This procedure will process all secondary assignments
--              and extract any primary or secondary vehicle details
--              according to the input criteria
---------------------------------------------------------------------------
PROCEDURE process_sec_asg(p_asg_id IN NUMBER) IS
   --
   CURSOR get_sec_asg IS
   SELECT distinct paa1.assignment_id
   FROM   per_all_assignments_f paa1, per_all_assignments_f paa2
   WHERE  paa2.assignment_id = p_asg_id
   AND    paa2.person_id = paa1.person_id
   AND    nvl(paa1.primary_flag, 'N') = 'N';
   --
   l_asg_include VARCHAR2(1) := 'N';
   --
BEGIN
   hr_utility.trace('Entering PROCESS_SEC_ASG, p_asg_id='||p_asg_id);
   --
   -- Loop through all secondary assignments
   FOR sec_asg_rec IN get_sec_asg LOOP
      --
      l_asg_include := 'N';
      l_asg_include := check_asg_inclusion(sec_asg_rec.assignment_id);
      --
      IF l_asg_include = 'Y' THEN
         process_prim_veh(sec_asg_rec.assignment_id);
         process_sec_veh(sec_asg_rec.assignment_id);
      END IF;
   END LOOP;
   --
   hr_utility.trace('Leaving PROCESS_SEC_ASG.');
END process_sec_asg;

---------------------------------------------------------------------------
-- Procedure:   PROCESS_TERM_PRIMARY_ASG
-- Desctiption: This procedure will process all primary assignments
--              the person that have been terminated before given
--              primary assignment
---------------------------------------------------------------------------
PROCEDURE process_term_primary_asg(p_asg_id IN NUMBER) IS
   --
   CURSOR get_term_primary_asg IS
   SELECT distinct paa1.assignment_id
   FROM   per_all_assignments_f paa1, per_all_assignments_f paa2
   WHERE  paa2.assignment_id = p_asg_id
   AND    paa2.person_id = paa1.person_id
   AND    paa1.effective_end_date < paa2.effective_start_date
   AND    nvl(paa1.primary_flag, 'Y') = 'Y';
   --
   l_asg_include VARCHAR2(1) := 'N';
   --
BEGIN
   hr_utility.trace('Entering PROCESS_TERM_PRIMARY_ASG, p_asg_id='||p_asg_id);
   --
   -- Loop through all previous primary assignments
   FOR term_primary_asg_rec IN get_term_primary_asg LOOP
      --
      l_asg_include := 'N';
      l_asg_include := check_asg_inclusion(term_primary_asg_rec.assignment_id);
      --
      IF l_asg_include = 'Y' THEN
         process_prim_veh(term_primary_asg_rec.assignment_id);
         process_sec_veh(term_primary_asg_rec.assignment_id);
      END IF;
   END LOOP;
   --
   hr_utility.trace('Leaving PROCESS_TERM_PRIMARY_ASG.');
END process_term_primary_asg;

---------------------------------------------------------------------------
-- Function:    POST_PROCESS_RULE
-- Desctiption: This function processes all extracted primary assignments to
--              further extract their secondary vehicle details and
--              all vehicle details of corresponding secondary assignments.
---------------------------------------------------------------------------
FUNCTION post_process_rule(p_ext_rslt_id IN NUMBER) RETURN VARCHAR2 IS
   --
   CURSOR get_asg_rcd_id IS
   SELECT rcd.ext_rcd_id
   FROM   ben_ext_rcd rcd,
          ben_ext_rcd_in_file rif,
          ben_ext_dfn dfn,
          ben_ext_rslt rslt
   WHERE  rslt.ext_rslt_id = p_ext_rslt_id
   AND    rslt.ext_dfn_id = dfn.ext_dfn_id
   AND    dfn.ext_file_id = rif.ext_file_id
   AND    rif.ext_rcd_id = rcd.ext_rcd_id
   AND    rcd.name like '%PAY GB P11D Car Extract 2003 - Assignment Details Record';
   --
   l_asg_rcd_id NUMBER;
   --
   CURSOR get_veh_rcd_id IS
   SELECT rcd.ext_rcd_id
   FROM   ben_ext_rcd rcd,
          ben_ext_rcd_in_file rif,
          ben_ext_dfn dfn,
          ben_ext_rslt rslt
   WHERE  rslt.ext_rslt_id = p_ext_rslt_id
   AND    rslt.ext_dfn_id = dfn.ext_dfn_id
   AND    dfn.ext_file_id = rif.ext_file_id
   AND    rif.ext_rcd_id = rcd.ext_rcd_id
   AND    rcd.name like '%PAY GB P11D Car Extract 2003 - Vehicle Details Record';
   --
   --
   CURSOR get_ext_asg IS
   SELECT person_id, val_01 asg_id, ext_rslt_dtl_id, object_version_number
   FROM   ben_ext_rslt_dtl
   WHERE  ext_rslt_id = p_ext_rslt_id
   AND    ext_rcd_id = l_asg_rcd_id;
   --
   l_obj_no NUMBER := NULL;
   --
   CURSOR get_prim_veh_dtl(p_person_id IN NUMBER) IS
   SELECT *
   FROM   ben_ext_rslt_dtl
   WHERE  ext_rslt_id = p_ext_rslt_id
   AND    ext_rcd_id = g_veh_rcd_id
   AND    person_id = p_person_id;
   --
   l_prim_veh_dtl get_prim_veh_dtl%ROWTYPE;
   --
   l_asg_include VARCHAR2(1);
   --
BEGIN
   hr_utility.trace('Entering POST_PROCESS_RULE, p_ext_rslt_id='||p_ext_rslt_id);

   g_ext_rslt_id := p_ext_rslt_id;
   -- Get assignment details record id
   OPEN get_asg_rcd_id;
   FETCH get_asg_rcd_id INTO l_asg_rcd_id;
   CLOSE get_asg_rcd_id;
   --
   hr_utility.trace('POST_PROCESS_RULE: l_asg_rcd_id='||l_asg_rcd_id);
   -- Get Vehicle Details Record Id
   OPEN  get_veh_rcd_id;
   FETCH get_veh_rcd_id INTO g_veh_rcd_id;
   CLOSE get_veh_rcd_id;
   --
   hr_utility.trace('POST_PROCESS_RULE: g_veh_rcd_id='||g_veh_rcd_id);
   -- Loop through all people extracted
   FOR ext_asg_rec IN get_ext_asg LOOP
      g_person_id := ext_asg_rec.person_id;
      g_bg_id := get_bus_group_id(ext_asg_rec.asg_id);
      l_prim_veh_dtl := NULL;
      --
      hr_utility.trace('POST_PROCESS_RULE: ext_asg_rec.asg_id='||ext_asg_rec.asg_id);
      hr_utility.trace('POST_PROCESS_RULE: g_person_id='||g_person_id);
      -- Delete extract result detail if primary vehicle details id is null
      OPEN get_prim_veh_dtl(ext_asg_rec.person_id);
      FETCH get_prim_veh_dtl INTO l_prim_veh_dtl;
      CLOSE get_prim_veh_dtl;
      --
      l_asg_include := check_asg_inclusion(ext_asg_rec.asg_id);
      hr_utility.trace('POST_PROCESS_RULE: l_prim_veh_dtl.ext_rslt_dtl_id='||l_prim_veh_dtl.ext_rslt_dtl_id);
      hr_utility.trace('POST_PROCESS_RULE: l_prim_veh_dtl.val_29='||l_prim_veh_dtl.val_29);
      IF l_prim_veh_dtl.ext_rslt_dtl_id IS NOT NULL AND l_prim_veh_dtl.val_29 IS NULL THEN
         -- Delete this extract rslt details because primary vehicle details
         -- do not exist for this assignment as of the start date parameter
         ben_ext_rslt_dtl_api.delete_ext_rslt_dtl(p_ext_rslt_dtl_id => l_prim_veh_dtl.ext_rslt_dtl_id,
                                                  p_object_version_number => l_prim_veh_dtl.object_version_number);
         --
      ELSIF l_prim_veh_dtl.ext_rslt_dtl_id IS NOT NULL AND l_asg_include = 'N' THEN
         -- Primary assignment does not qualify for extract
         -- Delete this extract rslt details
         ben_ext_rslt_dtl_api.delete_ext_rslt_dtl(p_ext_rslt_dtl_id => l_prim_veh_dtl.ext_rslt_dtl_id,
                                                  p_object_version_number => l_prim_veh_dtl.object_version_number);
         --
      ELSIF l_asg_include = 'Y' THEN
         -- Include this Assignment
         process_prim_veh(ext_asg_rec.asg_id);
         process_sec_veh(ext_asg_rec.asg_id);
      END IF;
      --
      process_term_primary_asg(ext_asg_rec.asg_id);
      process_sec_asg(ext_asg_rec.asg_id);
      --
      hr_utility.trace('POST_PROCESS_RULE: Assignment processed, remove it from the extract details table.');
      l_obj_no := ext_asg_rec.object_version_number;
      -- Delete this assignment details record
      ben_ext_rslt_dtl_api.delete_ext_rslt_dtl(p_ext_rslt_dtl_id => ext_asg_rec.ext_rslt_dtl_id,
                                               p_object_version_number => l_obj_no);
      --
   END LOOP;
   --
   hr_utility.trace('Leaving Post_process_rule.');
   RETURN 'Y';
   --
END post_process_rule;
/* Following code has been added as part of PllD Car Extract 2004 */
---------------------------------------------------------------------------
-- Function:    PRIM_BEN_START_DATE
-- Desctiption: This function gets start date of primary car benefit from
--              effective start date of the assignment attributes table.
---------------------------------------------------------------------------
FUNCTION prim_ben_start_date(p_assignment_id IN NUMBER)
RETURN VARCHAR2 IS
   --
   l_ben_start_date DATE := NULL;
   l_ext_start_date DATE := NULL;
   l_ext_end_date   DATE := NULL;
   --
   CURSOR get_eff_start_date IS
   SELECT greatest(paaf.effective_start_date, l_ext_start_date) effective_start_date
   FROM   pqp_vehicle_allocations_f paaf,
          pqp_vehicle_repository_f pvd
   WHERE  paaf.assignment_id = p_assignment_id
   AND    paaf.effective_start_date <= l_ext_end_date
   AND    paaf.effective_end_date >= l_ext_start_date
   AND    paaf.vehicle_repository_id is NOT NULL
   AND    paaf.usage_type = 'P'
   AND    pvd.vehicle_repository_id = paaf.vehicle_repository_id
   AND    pvd.vehicle_type = 'C'
   AND    pvd.vehicle_ownership = 'C'
   ORDER BY paaf.effective_start_date ;
   --
BEGIN
   hr_utility.trace('Entering get_prim_ben_start_date, p_assignment_id='||p_assignment_id);
   -- Get extract start date parameter value
   l_ext_start_date := get_param_ext_start_date(get_bus_group_id(p_assignment_id));
   l_ext_end_date   := get_param_ext_end_date(get_bus_group_id(p_assignment_id));
   --
   -- Get effective start date
   OPEN  get_eff_start_date;
   FETCH get_eff_start_date INTO l_ben_start_date;
   CLOSE get_eff_start_date;
   --
   hr_utility.trace('Leaving prim_ben_start_date, l_ben_start_date='
                         ||to_char(l_ben_start_date, 'DD-MON-YYYY'));
   RETURN to_char(l_ben_start_date, 'DD-MON-YYYY');
   --
END prim_ben_start_date;

---------------------------------------------------------------------------
-- Function:    PRIM_BEN_END_DATE
-- Desctiption: This function gets end date of primary car benefit from
--              effective end date of the assignment attributes table.
---------------------------------------------------------------------------
FUNCTION prim_ben_end_date(p_assignment_id IN NUMBER)
RETURN VARCHAR2 IS
   --
   l_ext_start_date DATE := NULL;
   l_ext_end_date   DATE := NULL;
   l_ben_end_date DATE := NULL;
   l_ben_start_date DATE := NULL;
   --
   CURSOR get_ben_details IS
   SELECT paaf.effective_end_date effective_end_date
   FROM   pqp_vehicle_allocations_f paaf,
          pqp_vehicle_repository_f pvd
   WHERE  paaf.assignment_id = p_assignment_id
   AND    paaf.effective_start_date <= l_ext_end_date
   AND    paaf.effective_end_date >= l_ext_start_date
   AND    paaf.vehicle_repository_id is NOT NULL
   AND    paaf.usage_type = 'P'
   AND    pvd.vehicle_repository_id = paaf.vehicle_repository_id
   AND    pvd.vehicle_type = 'C'
   AND    pvd.vehicle_ownership = 'C'
   ORDER BY paaf.effective_end_date desc;
   --
BEGIN
   hr_utility.trace('Entering get_prim_ben_end_date, p_assignment_id='||p_assignment_id);
   --
   l_ben_start_date := fnd_date.displaydate_to_date(prim_ben_start_date(p_assignment_id));
   l_ext_start_date := get_param_ext_start_date(get_bus_group_id(p_assignment_id));
   l_ext_end_date   := get_param_ext_end_date(get_bus_group_id(p_assignment_id));
   --
   -- Get benefit details
   OPEN  get_ben_details;
   FETCH get_ben_details INTO l_ben_end_date ;
   CLOSE get_ben_details;
   --
   hr_utility.trace('Leaving prim_ben_end_date, l_ben_end_date='
                         ||to_char(l_ben_end_date, 'DD-MON-YYYY'));
  -- RETURN to_char(l_ext_end_date, 'DD-MON-YYYY');
   RETURN to_char(least(l_ben_end_date, l_ext_end_date), 'DD-MON-YYYY');
   --
END prim_ben_end_date;

---------------------------------------------------------------------------
-- Function:    PRIM_VIN
-- Desctiption: This function gets Vehicle Identification Number of primary
--              car as of the benefit start date.
---------------------------------------------------------------------------
FUNCTION prim_vin(p_assignment_id IN NUMBER)
RETURN VARCHAR2 IS
   --
   l_vin    VARCHAR2(50) := NULL;
   l_ben_start_date DATE := NULL;
   l_ext_end_date   DATE := NULL;
   l_ext_start_date   DATE := NULL;
   --
   CURSOR get_vin IS
   SELECT pvd.registration_number
   FROM   pqp_vehicle_allocations_f paaf,
          pqp_vehicle_repository_f pvd
   WHERE paaf.assignment_id = p_assignment_id -- comes from context
   AND pvd.vehicle_repository_id = paaf.vehicle_repository_id
   AND pvd.vehicle_type = 'C'
   AND pvd.vehicle_ownership = 'C'
   AND paaf.usage_type = 'P'
   AND pvd.effective_start_date <= l_ext_end_date
   AND pvd.effective_end_date >= l_ext_start_date
   ORDER BY pvd.effective_end_date desc;
   --
BEGIN
   hr_utility.trace('Entering GET_PRIM_VIN, p_assignment_id='||p_assignment_id);
   --
   l_ben_start_date := fnd_date.displaydate_to_date(prim_ben_start_date(p_assignment_id));
   l_ext_start_date := get_param_ext_start_date(get_bus_group_id(p_assignment_id));
   l_ext_end_date   := get_param_ext_end_date(get_bus_group_id(p_assignment_id));
   --
   -- Get Vehicle Identification Number
   OPEN  get_vin;
   FETCH get_vin INTO l_vin;
   CLOSE get_vin;
   --
   hr_utility.trace('Leaving PRIM_VIN, l_vin='||l_vin);
   RETURN l_vin;
   --
END prim_vin;

---------------------------------------------------------------------------
-- Function:    PRIM_MAKE
-- Desctiption: This function gets Make of primary
--              car as of the benefit start date.
---------------------------------------------------------------------------
FUNCTION prim_make(p_assignment_id IN NUMBER)
RETURN VARCHAR2 IS
   --
   l_make   VARCHAR2(30) := NULL;
   l_ben_start_date DATE := NULL;
   l_ext_end_date   DATE := NULL;
   l_ext_start_date DATE   := NULL;
   --
   CURSOR get_make IS
   SELECT pvd.make
   FROM   pqp_vehicle_allocations_f paaf,
          pqp_vehicle_repository_f pvd
   WHERE paaf.assignment_id = p_assignment_id -- comes from context
   AND pvd.vehicle_repository_id = paaf.vehicle_repository_id
   AND pvd.vehicle_type = 'C'
   AND pvd.vehicle_ownership = 'C'
   AND paaf.usage_type = 'P'
   AND pvd.effective_start_date <= l_ext_end_date
   AND pvd.effective_end_date >= l_ext_start_date
   ORDER BY pvd.effective_end_date desc;
   --
BEGIN
   hr_utility.trace('Entering PRIM_MAKE, p_assignment_id='||p_assignment_id);
   --
   l_ben_start_date := fnd_date.displaydate_to_date(prim_ben_start_date(p_assignment_id));
   l_ext_start_date := get_param_ext_start_date(get_bus_group_id(p_assignment_id));
   l_ext_end_date   := get_param_ext_end_date(get_bus_group_id(p_assignment_id));
   --
   -- Get make
   OPEN  get_make;
   FETCH get_make INTO l_make;
   CLOSE get_make;
   --
   hr_utility.trace('Leaving PRIM_MAKE, l_make='||l_make);
   RETURN l_make;
   --
END prim_make;

---------------------------------------------------------------------------
-- Function:    PRIM_MODEL
-- Desctiption: This function gets Model of primary
--              car as of the benefit start date.
---------------------------------------------------------------------------
FUNCTION prim_model(p_assignment_id IN NUMBER) RETURN VARCHAR2 IS
   --
   l_model  VARCHAR2(30) := NULL;
   l_ben_start_date DATE := NULL;
   l_ext_end_date   DATE := NULL;
   l_ext_start_date DATE := NULL;
   --
   CURSOR get_model IS
   SELECT pvd.model
   FROM   pqp_vehicle_allocations_f paaf,
          pqp_vehicle_repository_f pvd
   WHERE paaf.assignment_id = p_assignment_id -- comes from context
   AND pvd.vehicle_repository_id = paaf.vehicle_repository_id
   AND pvd.vehicle_type = 'C'
   AND pvd.vehicle_ownership = 'C'
   AND paaf.usage_type = 'P'
   AND pvd.effective_start_date <= l_ext_end_date
   AND pvd.effective_end_date >= l_ext_start_date
   ORDER BY pvd.effective_end_date desc;
   --
BEGIN
   hr_utility.trace('Entering PRIM_MODEL, p_assignment_id='||p_assignment_id);
   --
   l_ben_start_date := fnd_date.displaydate_to_date(prim_ben_start_date(p_assignment_id));
   l_ext_start_date := get_param_ext_start_date(get_bus_group_id(p_assignment_id));
   l_ext_end_date   := get_param_ext_end_date(get_bus_group_id(p_assignment_id));
   --
   -- Get model
   OPEN  get_model;
   FETCH get_model INTO l_model;
   CLOSE get_model;
   --
   hr_utility.trace('Leaving PRIM_MODEL, l_model='||l_model);
   RETURN l_model;
   --
END prim_model;

---------------------------------------------------------------------------
-- Function:    PRIM_DFR
-- Desctiption: This function gets date of first registration of primary
--              car as of the benefit start date.
---------------------------------------------------------------------------
FUNCTION prim_dfr(p_assignment_id IN NUMBER) RETURN VARCHAR2 IS
   --
   l_dfr            DATE := NULL;
   l_ben_start_date DATE := NULL;
   l_ext_end_date   DATE := NULL;
   l_ext_start_date DATE := NULL;
   --
   CURSOR get_dfr IS
   SELECT pvd.initial_registration
   FROM   pqp_vehicle_allocations_f paaf,
          pqp_vehicle_repository_f pvd
   WHERE paaf.assignment_id = p_assignment_id -- comes from context
   AND pvd.vehicle_repository_id = paaf.vehicle_repository_id
   AND pvd.vehicle_type = 'C'
   AND pvd.vehicle_ownership = 'C'
   AND paaf.usage_type = 'P'
   AND pvd.effective_start_date <= l_ext_end_date
   AND pvd.effective_end_date >= l_ext_start_date
   ORDER BY pvd.effective_end_date desc;
   --
BEGIN
   hr_utility.trace('Entering PRIM_DFR, p_assignment_id='||p_assignment_id);
   --
   l_ben_start_date := fnd_date.displaydate_to_date(prim_ben_start_date(p_assignment_id));
   l_ext_start_date := get_param_ext_start_date(get_bus_group_id(p_assignment_id));
   l_ext_end_date   := get_param_ext_end_date(get_bus_group_id(p_assignment_id));
   --
   -- Get date first registered
   OPEN  get_dfr;
   FETCH get_dfr INTO l_dfr;
   CLOSE get_dfr;
   --
   hr_utility.trace('Leaving PRIM_DFR, l_dfr='||to_char(l_dfr, 'DD-MON-YYYY'));
   RETURN to_char(l_dfr, 'DD-MON-YYYY');
   --
END prim_dfr;

---------------------------------------------------------------------------
-- Function:    PRIM_PRICE
-- Desctiption: This function gets price of primary
--              car as of the benefit start date.
---------------------------------------------------------------------------
FUNCTION prim_price(p_assignment_id IN NUMBER) RETURN VARCHAR2 IS
   --
   l_price        NUMBER := NULL;
   l_ben_start_date DATE := NULL;
   l_ext_end_date   DATE := NULL;
   l_ext_start_date   DATE := NULL;
   --
   CURSOR get_price IS
   SELECT decode(nvl(pvd.market_value_classic_car,0), 0, list_price, pvd.market_value_classic_car)+ nvl(pvd.accessory_value_at_startdate,0)
   FROM   pqp_vehicle_allocations_f paaf,
          pqp_vehicle_repository_f pvd
   WHERE paaf.assignment_id = p_assignment_id -- comes from context
   AND pvd.vehicle_repository_id = paaf.vehicle_repository_id
   AND pvd.vehicle_type = 'C'
   AND pvd.vehicle_ownership = 'C'
   AND paaf.usage_type = 'P'
   AND pvd.effective_start_date <= l_ext_end_date
   AND pvd.effective_end_date >= l_ext_start_date
   ORDER BY pvd.effective_end_date desc;
   --
BEGIN
   hr_utility.trace('Entering PRIM_PRICE, p_assignment_id='||p_assignment_id);
   --
   l_ben_start_date := fnd_date.displaydate_to_date(prim_ben_start_date(p_assignment_id));
   l_ext_start_date := get_param_ext_start_date(get_bus_group_id(p_assignment_id));
   l_ext_end_date   := get_param_ext_end_date(get_bus_group_id(p_assignment_id));
   --
   -- Get price
   OPEN  get_price;
   FETCH get_price INTO l_price;
   CLOSE get_price;
   --
   hr_utility.trace('Leaving PRIM_PRICE, l_price='||to_char(l_price));
   RETURN to_char(l_price);
   --
END prim_price;


---------------------------------------------------------------------------
-- Function:    PRIM_FUEL_TYPE
-- Desctiption: This function gets fuel type of primary
--              car as of the benefit start date and then translates it
--              to GB_FUEL_TYPE lookup meaning.
---------------------------------------------------------------------------
FUNCTION prim_fuel_type(p_assignment_id IN NUMBER) RETURN VARCHAR2 IS
   --
   l_fuel_type      VARCHAR2(30) := NULL;
   l_fuel_meaning   VARCHAR2(80) := NULL;
   l_ben_start_date DATE := NULL;
   l_ext_end_date   DATE := NULL;
   l_ext_start_date   DATE := NULL;
   --
   CURSOR get_fuel_type IS
   SELECT hl.description -- pvd.fuel_type
   FROM   pqp_vehicle_allocations_f paaf,
          pqp_vehicle_repository_f pvd,
          hr_lookups  hl
   WHERE paaf.assignment_id = p_assignment_id -- comes from context
   AND pvd.vehicle_repository_id = paaf.vehicle_repository_id
   AND pvd.vehicle_type = 'C'
   AND pvd.vehicle_ownership = 'C'
   AND paaf.usage_type = 'P'
   AND pvd.effective_start_date <= l_ext_end_date
   AND pvd.effective_end_date >= l_ext_start_date
   AND hl.lookup_type = 'PQP_FUEL_TYPE'
   AND hl.enabled_flag = 'Y'
   AND hl.lookup_code = pvd.fuel_type
   AND trunc(sysdate)  BETWEEN trunc(nvl(hl.start_date_active, sysdate-1)) AND trunc(nvl(hl.end_date_active, sysdate+1))
   ORDER BY pvd.effective_end_date desc;
   --
   CURSOR get_translation IS
   SELECT Meaning
   FROM   hr_lookups --Bug fix 3799560
   WHERE  lookup_type = 'GB_FUEL_TYPE'
   AND    trunc(sysdate)  BETWEEN trunc(nvl(start_date_active, sysdate-1)) AND trunc(nvl(end_date_active, sysdate+1))
   AND    enabled_flag = 'Y'
   AND    description = l_fuel_type
   ORDER BY lookup_code;
BEGIN
   hr_utility.trace('Entering PRIM_FUEL_TYPE, p_assignment_id='||p_assignment_id);
   --
   l_ben_start_date := fnd_date.displaydate_to_date(prim_ben_start_date(p_assignment_id));
   l_ext_start_date := get_param_ext_start_date(get_bus_group_id(p_assignment_id));
   l_ext_end_date   := get_param_ext_end_date(get_bus_group_id(p_assignment_id));
   --
   -- Get fuel type
   OPEN  get_fuel_type;
   FETCH get_fuel_type INTO l_fuel_type;
   CLOSE get_fuel_type;
   --
   hr_utility.trace('PRIM_FUEL_TYPE: l_fuel_type='||l_fuel_type);
   --
   -- Get Translated Meaning
   OPEN  get_translation;
   FETCH get_translation INTO l_fuel_meaning;
   CLOSE get_translation;
   hr_utility.trace('Leaving PRIM_FUEL_TYPE, l_fuel_meaning='||l_fuel_meaning);
   RETURN l_fuel_meaning;
   --
END prim_fuel_type;

---------------------------------------------------------------------------
-- Function:    PRIM_CO2_EMI
-- Desctiption: This function gets CO2 Emission of primary
--              car as of the benefit start date.
---------------------------------------------------------------------------
FUNCTION prim_co2_emi(p_assignment_id IN NUMBER) RETURN VARCHAR2 IS
   --
   l_co2_emi      NUMBER := NULL;
   l_ben_start_date DATE := NULL;
   l_ext_end_date   DATE := NULL;
   l_ext_start_date   DATE := NULL;
   --
   CURSOR get_co2_emi IS
   SELECT pvd.fiscal_ratings
   FROM   pqp_vehicle_allocations_f paaf,
          pqp_vehicle_repository_f pvd
   WHERE paaf.assignment_id = p_assignment_id -- comes from context
   AND pvd.vehicle_repository_id = paaf.vehicle_repository_id
   AND pvd.vehicle_type = 'C'
   AND pvd.vehicle_ownership = 'C'
   AND paaf.usage_type = 'P'
   AND pvd.effective_start_date <= l_ext_end_date
   AND pvd.effective_end_date >= l_ext_start_date
   ORDER BY pvd.effective_end_date desc;
   --
BEGIN
   hr_utility.trace('Entering PRIM_CO2_EMI, p_assignment_id='||p_assignment_id);
   --
   l_ben_start_date := fnd_date.displaydate_to_date(prim_ben_start_date(p_assignment_id));
   l_ext_start_date := get_param_ext_start_date(get_bus_group_id(p_assignment_id));
   l_ext_end_date   := get_param_ext_end_date(get_bus_group_id(p_assignment_id));
   --
   -- Get CO2 Emissions
   OPEN  get_co2_emi;
   FETCH get_co2_emi INTO l_co2_emi;
   CLOSE get_co2_emi;
   --
   hr_utility.trace('Leaving PRIM_CO2_EMI, l_co2_emi='||to_char(l_co2_emi));
   RETURN to_char(l_co2_emi);
   --
END prim_co2_emi;


---------------------------------------------------------------------------
-- Function:    PRIM_OPTIONAL_ACC
-- Desctiption: This function gets optional accessory value of primary
--              car as of the benefit start date.
---------------------------------------------------------------------------
FUNCTION prim_optional_acc(p_assignment_id IN NUMBER) RETURN VARCHAR2 IS
   --
   l_opt_acc      NUMBER := NULL;
   l_ben_start_date DATE := NULL;
   l_ext_end_date   DATE := NULL;
   l_ext_start_date   DATE := NULL;
   --
   CURSOR get_opt_acc IS
   --bug 7306948 begin
   --old line    SELECT decode(nvl(pvd.market_value_classic_car,0), 0, pvd.accessory_value_at_startdate, 0)
   SELECT decode(nvl(pvd.market_value_classic_car,0), 0, pvd.accessory_value_added_later, 0)
   --bug 7306948 end
   FROM   pqp_vehicle_allocations_f paaf,
          pqp_vehicle_repository_f pvd
   WHERE paaf.assignment_id = p_assignment_id -- comes from context
   AND pvd.vehicle_repository_id = paaf.vehicle_repository_id
   AND pvd.vehicle_type = 'C'
   AND pvd.vehicle_ownership = 'C'
   AND paaf.usage_type = 'P'
   AND pvd.effective_start_date <= l_ext_end_date
   AND pvd.effective_end_date >= l_ext_start_date
   ORDER BY pvd.effective_end_date desc;
   --
BEGIN
   hr_utility.trace('Entering PRIM_OPTIONAL_ACC, p_assignment_id='||p_assignment_id);
   --
   l_ben_start_date := fnd_date.displaydate_to_date(prim_ben_start_date(p_assignment_id));
   l_ext_start_date := get_param_ext_start_date(get_bus_group_id(p_assignment_id));
   l_ext_end_date   := get_param_ext_end_date(get_bus_group_id(p_assignment_id));
   --
   -- Get accessory value
   OPEN  get_opt_acc;
   FETCH get_opt_acc INTO l_opt_acc;
   CLOSE get_opt_acc;
   --
   hr_utility.trace('Leaving PRIM_OPTIONAL_ACC, l_opt_acc='||to_char(l_opt_acc));
   RETURN to_char(l_opt_acc);
   --
END prim_optional_acc;

---------------------------------------------------------------------------
-- Function:    PRIM_CAPITAL_CONTRIB
-- Desctiption: This function gets value of capital contribution to primary
--              car as of the benefit start date.
---------------------------------------------------------------------------
FUNCTION prim_capital_contrib(p_assignment_id IN NUMBER) RETURN VARCHAR2 IS
   --
   l_cap_contrib    NUMBER := NULL;
   l_ben_start_date DATE := NULL;
   l_ext_end_date   DATE := NULL;
   l_ext_start_date   DATE := NULL;
   --
   CURSOR get_cap_contrib IS
   SELECT paaf.capital_contribution
   FROM   pqp_vehicle_allocations_f paaf,
          pqp_vehicle_repository_f pvd
   WHERE paaf.assignment_id = p_assignment_id -- comes from context
   AND paaf.usage_type = 'P'
   AND pvd.vehicle_repository_id = paaf.vehicle_repository_id
   AND pvd.vehicle_type = 'C'
   AND pvd.vehicle_ownership = 'C'
   AND paaf.effective_start_date <= l_ext_end_date
   AND paaf.effective_end_date >= l_ext_start_date
   order by paaf.effective_end_date desc;
   --
BEGIN
   hr_utility.trace('Entering PRIM_CAPITAL_CONTRIB, p_assignment_id='||p_assignment_id);
   --
   l_ben_start_date := fnd_date.displaydate_to_date(prim_ben_start_date(p_assignment_id));
   l_ext_start_date := get_param_ext_start_date(get_bus_group_id(p_assignment_id));
   l_ext_end_date   := get_param_ext_end_date(get_bus_group_id(p_assignment_id));
   --
   -- Get Capital Contribution
   OPEN  get_cap_contrib;
   FETCH get_cap_contrib INTO l_cap_contrib;
   CLOSE get_cap_contrib;
   --
   hr_utility.trace('Leaving PRIM_CAPITAL_CONTRIB, l_cap_contrib='||to_char(l_cap_contrib));
   RETURN to_char(l_cap_contrib);
   --
END prim_capital_contrib;


---------------------------------------------------------------------------
-- Function:    PRIM_PRIVATE_CONTRIB
-- Desctiption: This function gets value of private contribution to primary
--              car as of the benefit start date.
---------------------------------------------------------------------------
FUNCTION prim_private_contrib(p_assignment_id IN NUMBER) RETURN VARCHAR2 IS
   --
   l_pri_contrib    NUMBER := NULL;
   l_ben_start_date DATE := NULL;
   l_ext_end_date   DATE := NULL;
   l_ext_start_date   DATE := NULL;
   --
   CURSOR get_pri_contrib IS
   SELECT paaf.private_contribution
   FROM   pqp_vehicle_allocations_f paaf,
          pqp_vehicle_repository_f pvd
   WHERE paaf.assignment_id = p_assignment_id -- comes from context
   AND paaf.usage_type = 'P'
   AND pvd.vehicle_repository_id = paaf.vehicle_repository_id
   AND pvd.vehicle_type = 'C'
   AND pvd.vehicle_ownership = 'C'
   AND paaf.effective_start_date <= l_ext_end_date
   AND paaf.effective_end_date >= l_ext_start_date
   ORDER BY paaf.effective_end_date desc;
   --
BEGIN
   hr_utility.trace('Entering PRIM_PRIVATE_CONTRIB, p_assignment_id='||p_assignment_id);
   --
   l_ben_start_date := fnd_date.displaydate_to_date(prim_ben_start_date(p_assignment_id));
   l_ext_start_date := get_param_ext_start_date(get_bus_group_id(p_assignment_id));
   l_ext_end_date   := get_param_ext_end_date(get_bus_group_id(p_assignment_id));
   --
   -- Get Private Contribution
   OPEN  get_pri_contrib;
   FETCH get_pri_contrib INTO l_pri_contrib;
   CLOSE get_pri_contrib;
   --
   hr_utility.trace('Leaving PRIM_PRIVATE_CONTRIB, l_pri_contrib='||to_char(l_pri_contrib));
   RETURN to_char(l_pri_contrib);
   --
END prim_private_contrib;

---------------------------------------------------------------------------
-- Function:    PRIM_ENGINE_CAPACITY
-- Desctiption: This function gets engine capacity in cc of primary
--              car as of the benefit start date.
---------------------------------------------------------------------------
FUNCTION prim_engine_capacity(p_assignment_id IN NUMBER) RETURN VARCHAR2 IS
   --
   l_engine_cap   NUMBER := NULL;
   l_ben_start_date DATE := NULL;
   l_ext_end_date   DATE := NULL;
   l_ext_start_date   DATE := NULL;
   --
   CURSOR get_engine_cap IS
   SELECT pvd.engine_capacity_in_cc
   FROM   pqp_vehicle_allocations_f paaf,
          pqp_vehicle_repository_f pvd
   WHERE paaf.assignment_id = p_assignment_id -- comes from context
   AND pvd.vehicle_repository_id = paaf.vehicle_repository_id
   AND pvd.vehicle_type = 'C'
   AND pvd.vehicle_ownership = 'C'
   AND paaf.usage_type = 'P'
   AND pvd.effective_start_date <= l_ext_end_date
   AND pvd.effective_end_date >= l_ext_start_date
   ORDER BY pvd.effective_end_date desc;
   --
BEGIN
   hr_utility.trace('Entering PRIM_ENGINE_CAPACITY, p_assignment_id='||p_assignment_id);
   --
   l_ben_start_date := fnd_date.displaydate_to_date(prim_ben_start_date(p_assignment_id));
   l_ext_start_date := get_param_ext_start_date(get_bus_group_id(p_assignment_id));
   l_ext_end_date   := get_param_ext_end_date(get_bus_group_id(p_assignment_id));
   --
   -- Get Engine Capacity
   OPEN  get_engine_cap;
   FETCH get_engine_cap INTO l_engine_cap;
   CLOSE get_engine_cap;
   --
   hr_utility.trace('Leaving PRIM_ENGINE_CAPACITY, l_engine_cap='||to_char(l_engine_cap));
   RETURN to_char(l_engine_cap);
   --
END prim_engine_capacity;

---------------------------------------------------------------------------
-- Function:    PRIM_FUEL_BENEFIT
-- Desctiption: This function gets value of fuel benefit flag for  primary
--              car as of the benefit start date.
---------------------------------------------------------------------------
FUNCTION prim_fuel_benefit(p_assignment_id IN NUMBER) RETURN VARCHAR2 IS
   --
   l_fuel_benefit   VARCHAR2(30) := NULL;
   l_ben_start_date DATE := NULL;
   l_ext_end_date   DATE := NULL;
   l_ext_start_date   DATE := NULL;
   --
   CURSOR get_fuel_benefit IS
   SELECT substr(paaf.fuel_benefit, 1, 1)
   FROM   pqp_vehicle_allocations_f paaf,
          pqp_vehicle_repository_f pvd
   WHERE paaf.assignment_id = p_assignment_id  -- comes from context
   AND paaf.usage_type = 'P'
   AND pvd.vehicle_repository_id = paaf.vehicle_repository_id
   AND pvd.vehicle_type = 'C'
   AND pvd.vehicle_ownership = 'C'
   AND paaf.effective_start_date <= l_ext_end_date
   AND paaf.effective_end_date >= l_ext_start_date
   ORDER BY paaf.effective_end_date desc;
   --
BEGIN
   hr_utility.trace('Entering PRIM_FUEL_BENEFIT, p_assignment_id='||p_assignment_id);
   --
   l_ben_start_date := fnd_date.displaydate_to_date(prim_ben_start_date(p_assignment_id));
   l_ext_start_date := get_param_ext_start_date(get_bus_group_id(p_assignment_id));
   l_ext_end_date   := get_param_ext_end_date(get_bus_group_id(p_assignment_id));
   --
   -- Get Fuel Benefit Flag
   OPEN  get_fuel_benefit;
   FETCH get_fuel_benefit INTO l_fuel_benefit;
   CLOSE get_fuel_benefit;
   --
   hr_utility.trace('Leaving PRIM_FUEL_BENEFIT, l_fuel_benefit='||l_fuel_benefit);
   RETURN l_fuel_benefit;
   --
END prim_fuel_benefit;
---------------------------------------------------------------------------
-- Function:    PRIM_FUEL_REINSTATED
-- Desctiption: This function gets the fuel benefit.
---------------------------------------------------------------------------
FUNCTION prim_fuel_reinstated(p_assignment_id IN NUMBER)
RETURN VARCHAR2 IS
   --
   l_fuel   VARCHAR2(30) := NULL;
   l_ext_end_date   DATE := NULL;
   l_ext_start_date DATE := NULL;
   l_ben_start_date DATE := NULL;
   --
   CURSOR get_fuel_reinstated IS
      SELECT substr(paaf.fuel_benefit,1,1) fuel_benefit
      FROM   pqp_vehicle_allocations_f paaf,
             pqp_vehicle_repository_f pvd
      WHERE  paaf.assignment_id = p_assignment_id -- comes from context
      AND    paaf.usage_type = 'P'
      AND    pvd.vehicle_repository_id = paaf.vehicle_repository_id
      AND    pvd.vehicle_type = 'C'
      AND    pvd.vehicle_ownership = 'C'
      AND    paaf.effective_start_date <= l_ext_end_date
      AND    paaf.effective_end_date >= l_ext_start_date
      ORDER BY paaf.effective_end_date desc;
   --
BEGIN
   hr_utility.trace('Entering PRIM_FUEL_REINSTATED, p_assignment_id='||p_assignment_id);
   --
   l_ext_start_date := get_param_ext_start_date(get_bus_group_id(p_assignment_id));
   l_ext_end_date   := get_param_ext_end_date(get_bus_group_id(p_assignment_id));
   l_ben_start_date := fnd_date.displaydate_to_date(prim_ben_start_date(p_assignment_id));
   --
   -- Get make
   OPEN  get_fuel_reinstated;
   FETCH get_fuel_reinstated INTO l_fuel;
   CLOSE get_fuel_reinstated;
   --
   IF l_fuel ='Y' then
         FOR l_date_free IN get_fuel_reinstated LOOP
             if l_date_free.fuel_benefit = 'N' THEN
                l_fuel :='Y';
             end if;
             EXIT WHEN (l_date_free.fuel_benefit = 'N');
             l_fuel := null;
         end loop;
   END IF;
   hr_utility.trace('Leaving PRIM_FUEL_REINSTATED, l_fuel='||l_fuel);
   RETURN l_fuel;
   --
END prim_fuel_reinstated;
--
---------------------------------------------------------------------------
-- Function:    PRIM_FREE_FUEL_WITHDRAWN
-- Desctiption: This function gets the date when free fuel was withdrawn.
---------------------------------------------------------------------------
FUNCTION prim_free_fuel_withdrawn(p_assignment_id IN NUMBER)
RETURN VARCHAR2 IS
   --
   l_fuel   VARCHAR2(30) := NULL;
   l_ben_start_date DATE := NULL;
   l_start_date     DATE := NULL;
   l_ext_end_date   DATE := NULL;
   l_ext_start_date DATE := NULL;
   --
   CURSOR get_date_free_fuel_withdrawn IS
      SELECT substr(paaf.fuel_benefit,1,1)fuel_benefit,paaf.effective_end_date effective_end_date
      FROM   pqp_vehicle_allocations_f paaf,
             pqp_vehicle_repository_f pvd
      WHERE  paaf.assignment_id = p_assignment_id -- comes from context
      AND    paaf.usage_type = 'P'
      AND    pvd.vehicle_repository_id = paaf.vehicle_repository_id
      AND    pvd.vehicle_type = 'C'
      AND    pvd.vehicle_ownership = 'C'
      AND    paaf.effective_start_date <= l_ext_end_date
      AND    paaf.effective_end_date >= l_ext_start_date
      ORDER BY paaf.effective_end_date desc;
   --
BEGIN
   hr_utility.trace('Entering PRIM_FREE_FUEL_WITHDRAWN, p_assignment_id='||p_assignment_id);
   --
   l_ben_start_date := fnd_date.displaydate_to_date(prim_ben_start_date(p_assignment_id));
   l_ext_start_date := get_param_ext_start_date(get_bus_group_id(p_assignment_id));
   l_ext_end_date   := get_param_ext_end_date(get_bus_group_id(p_assignment_id));
   --
   -- Get make
   OPEN  get_date_free_fuel_withdrawn;
   FETCH get_date_free_fuel_withdrawn INTO l_fuel,l_start_date;
   CLOSE get_date_free_fuel_withdrawn;
   --
   IF l_fuel ='Y' then
      l_start_date := NULL;
   ELSE
      FOR l_date_free IN get_date_free_fuel_withdrawn  LOOP
          if l_date_free.fuel_benefit = 'Y' THEN
             l_start_date := (l_date_free.effective_end_date +1);
          end if;
          EXIT WHEN (l_date_free.fuel_benefit = 'Y');
          l_start_date := null;
      end loop;
   END IF;
   hr_utility.trace('Leaving PRIM_DATE_FREE_FUEL_WITHDRAWN, l_start_date='||l_start_date);
   RETURN to_char(l_start_date, 'DD-MON-YYYY');
   --
END prim_free_fuel_withdrawn;
---------------------------------------------------------------------------
-- Function:    PRIM_ADDITIONAL_FUEL_DAYS
-- Desctiption: This function gets the additional withdrawn fuel days.
---------------------------------------------------------------------------
FUNCTION prim_additional_fuel_days(p_assignment_id IN NUMBER)
RETURN VARCHAR2 IS
   --
   l_days           NUMBER := NULL;
   l_start_date     DATE := NULL;
   l_ben_start_date DATE := NULL;
   l_ext_end_date   DATE := NULL;
   l_ext_start_date DATE := NULL;
   l_flag   VARCHAR2(30) := 'T';
   --
   CURSOR get_date_free_fuel IS
         SELECT paaf.fuel_benefit
         FROM   pqp_vehicle_allocations_f paaf,
                pqp_vehicle_repository_f pvd
         WHERE  paaf.assignment_id = p_assignment_id -- comes from context
         AND    paaf.usage_type = 'P'
         AND    pvd.vehicle_repository_id = paaf.vehicle_repository_id
         AND    pvd.vehicle_type = 'C'
         AND    pvd.vehicle_ownership = 'C'
         AND    paaf.effective_end_date <=l_start_date
         AND    paaf.effective_end_date >= l_ext_start_date
         AND    paaf.effective_start_date <= l_ext_end_date
         order by paaf.effective_start_date desc ;

BEGIN
   hr_utility.trace('Entering PRIM_ADDITIONAL_FUEL_DAYS , p_assignment_id='||p_assignment_id);
   --
   l_ben_start_date := fnd_date.displaydate_to_date(prim_ben_start_date(p_assignment_id));
   --
   l_ext_start_date := get_param_ext_start_date(get_bus_group_id(p_assignment_id));
   l_ext_end_date   := get_param_ext_end_date(get_bus_group_id(p_assignment_id));
   l_start_date     := fnd_date.displaydate_to_date(prim_free_fuel_withdrawn(p_assignment_id));
   --
   if l_start_date is null then
      l_days := null;
   ELSE
      for l_date_free in get_date_free_fuel loop
          if l_date_free.fuel_benefit = 'N' THEN
             l_flag:='F';
          end if;
          EXIT WHEN (l_date_free.fuel_benefit='N');
      end loop;
      if l_flag = 'F' then
      l_days := null;
      else
      l_days := trunc(l_ext_end_date - l_start_date);
      end if;
   END IF;
   hr_utility.trace('Leaving PRIM_ADDITIONAL_FUEL_DAYS, l_days='||l_days);
   RETURN to_char(l_days);
   --
END prim_additional_fuel_days;
--
---------------------------------------------------------------------------
-- Function:    PRIM_FUEL_REINSTATED
-- Desctiption: This function gets the fuel benefit.
---------------------------------------------------------------------------
FUNCTION prim_fuel_reinstated(p_assignment_id IN NUMBER,
                              p_vehicle_allocation_id IN NUMBER)
RETURN VARCHAR2 IS
   --
   l_fuel   VARCHAR2(30) := NULL;
   l_ext_end_date   DATE := NULL;
   l_ext_start_date DATE := NULL;
   l_ben_start_date DATE := NULL;
   --
   CURSOR get_fuel_reinstated IS
      SELECT substr(paaf.fuel_benefit,1,1) fuel_benefit
      FROM   pqp_vehicle_allocations_f paaf,
             pqp_vehicle_repository_f pvd
      WHERE  paaf.assignment_id = p_assignment_id -- comes from context
      AND    paaf.usage_type = 'P'
      AND    pvd.vehicle_repository_id = paaf.vehicle_repository_id
      AND    pvd.vehicle_type = 'C'
      AND    pvd.vehicle_ownership = 'C'
      AND    paaf.effective_start_date <= l_ext_end_date
      AND    paaf.effective_end_date >= l_ext_start_date
      AND    paaf.vehicle_allocation_id = p_vehicle_allocation_id
      ORDER BY paaf.effective_end_date desc;
   --
BEGIN
   hr_utility.trace('Entering PRIM_FUEL_REINSTATED, p_assignment_id='||p_assignment_id);
   --
   l_ext_start_date := get_param_ext_start_date(get_bus_group_id(p_assignment_id));
   l_ext_end_date   := get_param_ext_end_date(get_bus_group_id(p_assignment_id));
   l_ben_start_date := fnd_date.displaydate_to_date(prim_ben_start_date(p_assignment_id));
   --
   -- Get make
   OPEN  get_fuel_reinstated;
   FETCH get_fuel_reinstated INTO l_fuel;
   CLOSE get_fuel_reinstated;
   --
   IF l_fuel ='Y' then
         FOR l_date_free IN get_fuel_reinstated LOOP
             if l_date_free.fuel_benefit = 'N' THEN
                l_fuel :='Y';
             end if;
             EXIT WHEN (l_date_free.fuel_benefit = 'N');
             l_fuel := null;
         end loop;
   END IF;
   hr_utility.trace('Leaving PRIM_FUEL_REINSTATED, l_fuel='||l_fuel);
   RETURN l_fuel;
   --
END prim_fuel_reinstated;
--
---------------------------------------------------------------------------
-- Function:    PRIM_FREE_FUEL_WITHDRAWN
-- Desctiption: This function gets the date when free fuel was withdrawn.
---------------------------------------------------------------------------
FUNCTION prim_free_fuel_withdrawn(p_assignment_id IN NUMBER,
                                  p_vehicle_allocation_id IN NUMBER)
RETURN VARCHAR2 IS
   --
   l_fuel   VARCHAR2(30) := NULL;
   l_ben_start_date DATE := NULL;
   l_start_date     DATE := NULL;
   l_ext_end_date   DATE := NULL;
   l_ext_start_date DATE := NULL;
   --
   CURSOR get_date_free_fuel_withdrawn IS
      SELECT substr(paaf.fuel_benefit,1,1)fuel_benefit,paaf.effective_end_date effective_end_date
      FROM   pqp_vehicle_allocations_f paaf,
             pqp_vehicle_repository_f pvd
      WHERE  paaf.assignment_id = p_assignment_id -- comes from context
      AND    paaf.usage_type = 'P'
      AND    pvd.vehicle_repository_id = paaf.vehicle_repository_id
      AND    pvd.vehicle_type = 'C'
      AND    pvd.vehicle_ownership = 'C'
      AND    paaf.effective_start_date <= l_ext_end_date
      AND    paaf.effective_end_date >= l_ext_start_date
      AND    paaf.vehicle_allocation_id = p_vehicle_allocation_id
      ORDER BY paaf.effective_end_date desc;
   --
BEGIN
   hr_utility.trace('Entering PRIM_FREE_FUEL_WITHDRAWN, p_assignment_id='||p_assignment_id);
   --
   l_ben_start_date := fnd_date.displaydate_to_date(prim_ben_start_date(p_assignment_id));
   l_ext_start_date := get_param_ext_start_date(get_bus_group_id(p_assignment_id));
   l_ext_end_date   := get_param_ext_end_date(get_bus_group_id(p_assignment_id));
   --
   -- Get make
   OPEN  get_date_free_fuel_withdrawn;
   FETCH get_date_free_fuel_withdrawn INTO l_fuel,l_start_date;
   CLOSE get_date_free_fuel_withdrawn;
   --
   IF l_fuel ='Y' then
      l_start_date := NULL;
   ELSE
      FOR l_date_free IN get_date_free_fuel_withdrawn  LOOP
          if l_date_free.fuel_benefit = 'Y' THEN
             l_start_date := (l_date_free.effective_end_date +1);
          end if;
          EXIT WHEN (l_date_free.fuel_benefit = 'Y');
          l_start_date := null;
      end loop;
   END IF;
   hr_utility.trace('Leaving PRIM_DATE_FREE_FUEL_WITHDRAWN, l_start_date='||l_start_date);
   RETURN to_char(l_start_date, 'DD-MON-YYYY');
   --
END prim_free_fuel_withdrawn;
---------------------------------------------------------------------------
-- Function:    PRIM_ADDITIONAL_FUEL_DAYS
-- Desctiption: This function gets the additional withdrawn fuel days.
---------------------------------------------------------------------------
FUNCTION prim_additional_fuel_days(p_assignment_id IN NUMBER,
                                   p_vehicle_allocation_id IN NUMBER)
RETURN VARCHAR2 IS
   --
   l_days           NUMBER := NULL;
   l_start_date     DATE := NULL;
   l_ben_start_date DATE := NULL;
   l_ext_end_date   DATE := NULL;
   l_ext_start_date DATE := NULL;
   l_flag   VARCHAR2(30) := 'T';
   --
   CURSOR get_date_free_fuel IS
         SELECT paaf.fuel_benefit
         FROM   pqp_vehicle_allocations_f paaf,
                pqp_vehicle_repository_f pvd
         WHERE  paaf.assignment_id = p_assignment_id -- comes from context
         AND    paaf.usage_type = 'P'
         AND    pvd.vehicle_repository_id = paaf.vehicle_repository_id
         AND    pvd.vehicle_type = 'C'
         AND    pvd.vehicle_ownership = 'C'
         AND    paaf.effective_end_date <=l_start_date
         AND    paaf.effective_end_date >= l_ext_start_date
         AND    paaf.effective_start_date <= l_ext_end_date
	 AND    paaf.vehicle_allocation_id = p_vehicle_allocation_id
         order by paaf.effective_start_date desc ;

BEGIN
   hr_utility.trace('Entering PRIM_ADDITIONAL_FUEL_DAYS , p_assignment_id='||p_assignment_id);
   --
   l_ben_start_date := fnd_date.displaydate_to_date(prim_ben_start_date(p_assignment_id));
   --
   l_ext_start_date := get_param_ext_start_date(get_bus_group_id(p_assignment_id));
   l_ext_end_date   := get_param_ext_end_date(get_bus_group_id(p_assignment_id));
   l_start_date     := fnd_date.displaydate_to_date(prim_free_fuel_withdrawn(p_assignment_id));
   --
   if l_start_date is null then
      l_days := null;
   ELSE
      for l_date_free in get_date_free_fuel loop
          if l_date_free.fuel_benefit = 'N' THEN
             l_flag:='F';
          end if;
          EXIT WHEN (l_date_free.fuel_benefit='N');
      end loop;
      if l_flag = 'F' then
      l_days := null;
      else
      l_days := trunc(l_ext_end_date - l_start_date) + 1;
      end if;
   END IF;
   hr_utility.trace('Leaving PRIM_ADDITIONAL_FUEL_DAYS, l_days='||l_days);
   RETURN to_char(l_days);
   --
END prim_additional_fuel_days;
--
---------------------------------------------------------------------------
-- Procedure:   CREATE_EXT_RSLT_DTL_04
-- Desctiption: This procedure will call BEN API to create an
--              extract result detail record
---------------------------------------------------------------------------
PROCEDURE create_ext_rslt_dtl_04( p_asg_id             IN NUMBER,
                              p_asg_start_date     IN DATE,
                              p_asg_end_date       IN DATE,
                              p_benefit_start_date IN DATE,
                              p_benefit_end_date   IN DATE,
                              p_car_fuel_benefit   IN VARCHAR2,
                              p_vehicle_repository_id IN NUMBER,
			      p_vehicle_allocation_id IN NUMBER) IS
   --
   l_ext_end_date   DATE := NULL;
   l_ext_start_date DATE := NULL;

   CURSOR get_vehicle_details IS
   SELECT registration_number,
          make,
          model,
          initial_registration,
          decode(nvl(market_value_classic_car,0), 0, list_price, market_value_classic_car) + nvl(accessory_value_at_startdate, 0) price,
          h2.meaning trans_fuel_type,
          fiscal_ratings,
	  --bug 7306948 begin
          --old line--decode(nvl(market_value_classic_car,0), 0, accessory_value_at_startdate, 0) optional_accessory,
	  decode(nvl(market_value_classic_car,0), 0, accessory_value_added_later, 0) optional_accessory,
	  --bug 7306948 end
          accessory_value_added_later,
          engine_capacity_in_cc
   FROM   pqp_vehicle_repository_f pvd,
          hr_lookups h1, --Bug fix 3799560
          hr_lookups h2
   WHERE  vehicle_repository_id = p_vehicle_repository_id
   AND    fuel_type = h1.lookup_code
   AND    h1.lookup_type = 'PQP_FUEL_TYPE'
   AND    h1.enabled_flag = 'Y'
   AND    trunc(sysdate) BETWEEN trunc(nvl(h1.start_date_active, sysdate-1)) AND trunc(nvl(h1.end_date_active,sysdate+1))
   AND    h1.description = h2.description
   AND    h2.lookup_type = 'GB_FUEL_TYPE'
   AND    trunc(sysdate) BETWEEN trunc(nvl(h2.start_date_active, sysdate-1)) AND trunc(nvl(h2.end_date_active,sysdate+1))
   AND    h2.enabled_flag = 'Y'
   AND    effective_start_date <= p_benefit_end_date
   AND    effective_end_date >=   p_benefit_start_date
   order by effective_end_date desc;
   --
   CURSOR check_fuel_benefit IS
   SELECT substr(fuel_benefit,1,1)fuel_benefit
   FROM   pqp_vehicle_allocations_f
   WHERE  assignment_id = p_asg_id
   AND    effective_start_date <= p_benefit_end_date
   AND    effective_end_date >=  p_benefit_start_date;

   CURSOR get_asg_attributes IS
   SELECT capital_contribution,
          private_contribution,
	  substr(fuel_benefit,1,1)fuel_benefit
   FROM   pqp_vehicle_allocations_f
   WHERE  assignment_id = p_asg_id
   AND    effective_start_date <= p_benefit_end_date
   AND    effective_end_date >=  p_benefit_start_date
   order by effective_end_date desc;
   --
   l_vehicle_rec get_vehicle_details%ROWTYPE;
   l_attribute_rec get_asg_attributes%ROWTYPE;
   --
   l_ext_rslt_dtl_id NUMBER;
   l_object_version_no NUMBER;
   --
   CURSOR chk_exists IS
   SELECT ext_rslt_dtl_id
   FROM   ben_ext_rslt_dtl
   WHERE  ext_rslt_id = g_ext_rslt_id
   AND    person_id = g_person_id
   AND    ext_rcd_id = g_veh_rcd_id
   AND    val_02 = to_char(p_asg_id)
   AND    val_04 = to_char(p_benefit_end_date, 'DD-MON-YYYY')
   AND    val_09 = to_char(p_benefit_start_Date, 'DD-MON-YYYY')
   AND    val_10 = to_char(p_benefit_end_date, 'DD-MON-YYYY')
   AND    val_29 = to_char(p_vehicle_repository_id);
   --
   l_chk_exists chk_exists%ROWTYPE;
   l_fuel_benefit  VARCHAR2(1);
   l_asg_start_date DATE := NULL;
   l_asg_end_date   DATE := NULL;
   l_var VARCHAR2(1) := '~';

BEGIN
   hr_utility.trace('Entering CREATE_EXT_RSLT_DTL_04: p_asg_id='|| p_asg_id);
   hr_utility.trace('CREATE_EXT_RSLT_DTL_04: p_asg_start_date='||to_char(p_asg_start_date, 'DD-MON-YYYY'));
   hr_utility.trace('CREATE_EXT_RSLT_DTL_04: p_asg_end_date='||to_char(p_asg_end_date, 'DD-MON-YYYY'));
   hr_utility.trace('CREATE_EXT_RSLT_DTL_04: p_benefit_start_date='||to_char(p_benefit_start_date, 'DD-MON-YYYY'));
   hr_utility.trace('CREATE_EXT_RSLT_DTL_04: p_benefit_end_date='||to_char(p_benefit_end_date, 'DD-MON-YYYY'));
   hr_utility.trace('CREATE_EXT_RSLT_DTL_04: p_car_fuel_benefit='||p_car_fuel_benefit);
   hr_utility.trace('CREATE_EXT_RSLT_DTL_04: p_vehicle_repository_id='||p_vehicle_repository_id);
   hr_utility.trace('CREATE_EXT_RSLT_DTL_04: g_ext_rslt_id='||g_ext_rslt_id);
   hr_utility.trace('CREATE_EXT_RSLT_DTL_04: g_person_id='||g_person_id);
   hr_utility.trace('CREATE_EXT_RSLT_DTL_04: g_veh_rcd_id='||g_veh_rcd_id);
   --
   l_ext_start_date := get_param_ext_start_date(get_bus_group_id(p_asg_id));
   l_ext_end_date   := get_param_ext_end_date(get_bus_group_id(p_asg_id));
   -- Get Vehicle Details
   OPEN  get_vehicle_details;
   FETCH get_vehicle_details INTO l_vehicle_rec;
   CLOSE get_vehicle_details;
   -- Get Assignment Attributes
   OPEN  get_asg_attributes;
   FETCH get_asg_attributes INTO l_attribute_rec;
   CLOSE get_asg_attributes;
   --
   -- Check fuel benefit
   l_fuel_benefit := 'N';
   FOR l_benefit in check_fuel_benefit
   LOOP
       if l_benefit.fuel_benefit = 'Y' then
          l_fuel_benefit := 'Y';
          exit;
       end if;
   END LOOP;
   l_attribute_rec.fuel_benefit := l_fuel_benefit;
   --
   -- CHeck if record already exists
   OPEN chk_exists;
   FETCH chk_exists INTO l_chk_exists;
   --
   IF chk_exists%NOTFOUND THEN
      -- Record does not exist
      -- Call API to create extract details record
      BEGIN
         hr_utility.trace('CREATE_EXT_RSLT_DTL_04: Insert result details.');
	 /* added below variables for bug 6154257 */
	 l_asg_start_date := fnd_date.displaydate_to_date(get_prim_asg_start_date(p_asg_id));
         l_asg_end_date   := fnd_date.displaydate_to_date(get_prim_asg_end_date(p_asg_id));
         ben_ext_rslt_dtl_api.create_ext_rslt_dtl( p_ext_rslt_dtl_id   => l_ext_rslt_dtl_id
                                               ,p_ext_rslt_id       => g_ext_rslt_id
                                               ,p_ext_rcd_id        => g_veh_rcd_id
                                               ,p_person_id         => g_person_id
                                               ,p_business_group_id => g_bg_id
                                               ,p_val_01            => 'A'
                                               ,p_val_02            => to_char(p_asg_id)
					       /* modified p_val_03 for bug 6154257 */
                                               ,p_val_03            => '~~~~~~~~~~~~~~~~~~~~~~~~~~'||to_char(l_asg_end_date, 'DD-MON-YYYY')||l_var||to_char(l_asg_start_date, 'DD-MON-YYYY')||l_var||to_char(l_asg_end_date, 'DD-MON-YYYY')
                                               ,p_val_04            => 'Car and Car Fuel 2003_04'
                                               ,p_val_05            => '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
                                               ,p_val_06            => to_char(p_benefit_start_Date, 'DD-MON-YYYY')
                                               ,p_val_07            => to_char(p_benefit_end_date, 'DD-MON-YYYY')
                                               ,p_val_08            => l_vehicle_rec.registration_number
                                               ,p_val_09            => l_vehicle_rec.make
                                               ,p_val_10            => l_vehicle_rec.model
                                               ,p_val_11            => to_char(l_vehicle_rec.initial_registration, 'DD-MON-YYYY')
                                               ,p_val_12            => to_char(l_vehicle_rec.price)
                                               ,p_val_13            => '~'
                                               ,p_val_14            => l_vehicle_rec.trans_fuel_type
                                               ,p_val_15            => to_char(l_vehicle_rec.fiscal_ratings)
                                               ,p_val_16            => '~~~'
                                               ,p_val_17            => 'GB_EXTERNAL REPORTING CAR 0304'
                                               ,p_val_18            => to_char(l_vehicle_rec.optional_accessory)
                                               ,p_val_19            => to_char(l_attribute_rec.capital_contribution)
                                               ,p_val_20            => to_char(l_attribute_rec.private_contribution)
                                               ,p_val_21            => to_char(l_vehicle_rec.engine_capacity_in_cc)
                                               ,p_val_22            => '~~~~~'
                                               ,p_val_23            => l_attribute_rec.fuel_benefit
                                               ,p_val_24            => prim_free_fuel_withdrawn(p_asg_id,p_vehicle_allocation_id)
                                               ,p_val_25            => prim_fuel_reinstated(p_asg_id,p_vehicle_allocation_id)
                                               ,p_val_26            => prim_additional_fuel_days(p_asg_id,p_vehicle_allocation_id)
                                               ,p_val_27            => '~~~~~~~~~~~~~~~'
                                               ,p_object_version_number => l_object_version_no);
      EXCEPTION WHEN others THEN
         hr_utility.trace('CREATE_EXT_RSLT_DTL_04: '||substr(sqlerrm, 1, 100));
         hr_utility.trace('CREATE_EXT_RSLT_DTL_04: '||substr(sqlerrm, 101, 100));
         hr_utility.trace('CREATE_EXT_RSLT_DTL_04: '||substr(sqlerrm, 201, 100));
         hr_utility.trace('CREATE_EXT_RSLT_DTL_04: '||substr(sqlerrm, 301, 100));
         RAISE;
      END;
   END IF;
   --
   CLOSE chk_exists;
   --
END create_ext_rslt_dtl_04;
--
---------------------------------------------------------------------------
-- Procedure:   PROCESS_SEC_VEH_04
-- Desctiption: This procedure will create an extract result detail record
--              for the secondary vehicle benefit
---------------------------------------------------------------------------
PROCEDURE process_sec_veh_04(p_asg_id IN NUMBER) IS
   --
   l_ext_start_date DATE := NULL;
   l_ext_end_date   DATE := NULL;
   --
   l_asg_start_date DATE := NULL;
   l_asg_end_date   DATE := NULL;
   --
   l_ben_start_date DATE := NULL;
   --
   CURSOR get_veh_id IS
   SELECT greatest(paaf.effective_start_date, l_ext_start_date) effective_start_date,
          least(paaf.effective_end_date, l_ext_end_date) effective_end_date,
          paaf.fuel_benefit fuel_benefit,paaf.vehicle_repository_id vehicle_repository_id,paaf.vehicle_allocation_id vehicle_allocation_id
   FROM   pqp_vehicle_allocations_f paaf,
          pqp_vehicle_repository_f pvd
   WHERE  paaf.assignment_id = p_asg_id
   AND    paaf.effective_start_date <= l_ext_end_date
   AND    paaf.effective_end_date >= l_ext_start_date
   AND    paaf.vehicle_repository_id is NOT NULL
   AND    pvd.vehicle_repository_id = paaf.vehicle_repository_id
   AND    pvd.vehicle_type = 'C'
   AND    pvd.vehicle_ownership = 'C'
   AND    paaf.usage_type = 'S'
   ORDER BY paaf.effective_start_date ;
   --
   l_veh_id_rec get_veh_id%ROWTYPE;
   l_prev_veh_id_rec get_veh_id%ROWTYPE;
   --
   l_new_rec BOOLEAN := TRUE;
BEGIN
   hr_utility.trace('Entering PROCESS_SEC_VEH_NEW, p_asg_id='||p_asg_id);
   -- Get extract date parameter values
   l_ben_start_date := fnd_date.displaydate_to_date(prim_ben_start_date(p_asg_id));
   l_ext_start_date := get_param_ext_start_date(get_bus_group_id(p_asg_id));
   l_ext_end_date   := get_param_ext_end_date(get_bus_group_id(p_asg_id));
   -- Get Assignment Start and End Dates
   l_asg_start_date := fnd_date.displaydate_to_date(get_prim_asg_start_date(p_asg_id));
   l_asg_end_date   := fnd_date.displaydate_to_date(get_prim_asg_end_date(p_asg_id));
   --
   OPEN get_veh_id;
   -- Loop through all vehicle records and create extract result detail
   -- record if there is a change in secondary_car_fuel_benefit or vehicle id
   LOOP
      FETCH get_veh_id INTO l_veh_id_rec;
      hr_utility.trace('PROCESS_SEC_VEH_04, After Fetch.');
      hr_utility.trace('PROCESS_SEC_VEH_04, effective_start_date='||to_char(l_veh_id_rec.effective_start_date, 'DD-MON-YYYY'));
      hr_utility.trace('PROCESS_SEC_VEH_04, effective_end_date='||to_char(l_veh_id_rec.effective_end_date, 'DD-MON-YYYY'));
      hr_utility.trace('PROCESS_SEC_VEH_04, fuel_benefit='||l_veh_id_rec.fuel_benefit);
      hr_utility.trace('PROCESS_SEC_VEH_04, vehicle_repository_id='||l_veh_id_rec.vehicle_repository_id);
      IF l_new_rec THEN
         hr_utility.trace('PROCESS_SEC_VEH_04, l_new_rec=TRUE');
      ELSE
         hr_utility.trace('PROCESS_SEC_VEH_04, l_new_rec=FALSE');
      END IF;
      --
      IF get_veh_id%FOUND THEN
         IF l_new_rec THEN
            l_prev_veh_id_rec.effective_start_date := l_veh_id_rec.effective_start_date;
            l_prev_veh_id_rec.effective_end_date := l_veh_id_rec.effective_end_date;
            l_prev_veh_id_rec.fuel_benefit := l_veh_id_rec.fuel_benefit;
            l_prev_veh_id_rec.vehicle_repository_id := l_veh_id_rec.vehicle_repository_id;
	    l_prev_veh_id_rec.vehicle_allocation_id := l_veh_id_rec.vehicle_allocation_id;
            l_new_rec := FALSE;
         ELSE
	      IF nvl(l_prev_veh_id_rec.vehicle_allocation_id, -999) = nvl(l_veh_id_rec.vehicle_allocation_id, -999) THEN
               -- vehicle benefits did not change therefore continue looping
               l_prev_veh_id_rec.effective_end_date := l_veh_id_rec.effective_end_date;
            ELSE
               -- Vehicle Details have changed therefore create reslt dtl record
               create_ext_rslt_dtl_04(p_asg_id, l_asg_start_date, l_asg_end_date,
                                       l_prev_veh_id_rec.effective_start_date,
                                       l_prev_veh_id_rec.effective_end_date,
                                       l_prev_veh_id_rec.fuel_benefit,
                                       l_prev_veh_id_rec.vehicle_repository_id,
				       l_prev_veh_id_rec.vehicle_allocation_id);
               --
               l_prev_veh_id_rec.effective_start_date := l_veh_id_rec.effective_start_date;
               l_prev_veh_id_rec.effective_end_date := l_veh_id_rec.effective_end_date;
               l_prev_veh_id_rec.fuel_benefit := l_veh_id_rec.fuel_benefit;
               l_prev_veh_id_rec.vehicle_repository_id := l_veh_id_rec.vehicle_repository_id;
	       l_prev_veh_id_rec.vehicle_allocation_id := l_veh_id_rec.vehicle_allocation_id;
            END IF;
         END IF;
      ELSE
         -- Last record reched, create ext rslt dtl record
         IF l_prev_veh_id_rec.vehicle_repository_id IS NOT NULL THEN
            create_ext_rslt_dtl_04(p_asg_id, l_asg_start_date, l_asg_end_date,
                                    l_prev_veh_id_rec.effective_start_date,
                                    l_prev_veh_id_rec.effective_end_date,
                                    l_prev_veh_id_rec.fuel_benefit,
                                    l_prev_veh_id_rec.vehicle_repository_id,
				    l_prev_veh_id_rec.vehicle_allocation_id);
         END IF;
         --
         EXIT;
      END IF;
   END LOOP;
   --
   hr_utility.trace('Leaving PROCESS_SEC_VEH_04.');
   --
END process_sec_veh_04;
---------------------------------------------------------------------------
-- Procedure:   PROCESS_PRIM_VEH_04
-- Desctiption: This procedure will create an extract result detail record
--              for the primary vehicle benefit
---------------------------------------------------------------------------
PROCEDURE process_prim_veh_04(p_asg_id IN NUMBER) IS
   --
   l_ext_start_date DATE := NULL;
   l_ext_end_date   DATE := NULL;
   --
   l_asg_start_date DATE := NULL;
   l_asg_end_date   DATE := NULL;
   --
   l_ben_start_date DATE := NULL;
   --
   CURSOR get_veh_id IS
   SELECT greatest(paaf.effective_start_date, l_ext_start_date) effective_start_date,
          least(paaf.effective_end_date, l_ext_end_date) effective_end_date,
          paaf.fuel_benefit fuel_benefit,paaf.vehicle_repository_id vehicle_repository_id, paaf.vehicle_allocation_id vehicle_allocation_id
   FROM   pqp_vehicle_allocations_f paaf,
          pqp_vehicle_repository_f pvd
   WHERE  paaf.assignment_id = p_asg_id
   AND    paaf.effective_start_date <= l_ext_end_date
   AND    paaf.effective_end_date >= l_ext_start_date
   AND    paaf.vehicle_repository_id is NOT NULL
   AND    pvd.vehicle_repository_id = paaf.vehicle_repository_id
   AND    pvd.vehicle_type = 'C'
   AND    pvd.vehicle_ownership = 'C'
   AND    paaf.usage_type = 'P'
   ORDER BY paaf.effective_start_date ;
   --
   l_veh_id_rec get_veh_id%ROWTYPE;
   l_prev_veh_id_rec get_veh_id%ROWTYPE;
   --
   l_new_rec BOOLEAN := TRUE;
BEGIN
   hr_utility.trace('Entering PROCESS_PRIM_VEH_04, p_asg_id='||p_asg_id);
   -- Get extract date parameter values
   l_ben_start_date := fnd_date.displaydate_to_date(prim_ben_start_date(p_asg_id));
   l_ext_start_date := get_param_ext_start_date(get_bus_group_id(p_asg_id));
   l_ext_end_date   := get_param_ext_end_date(get_bus_group_id(p_asg_id));
   -- Get Assignment Start and End Dates
   l_asg_start_date := fnd_date.displaydate_to_date(get_prim_asg_start_date(p_asg_id));
   l_asg_end_date   := fnd_date.displaydate_to_date(get_prim_asg_end_date(p_asg_id));
   --
   OPEN get_veh_id;
   -- Loop through all vehicle records and create extract result detail
   -- record if there is a change in primary_car_fuel_benifit or vehicle id
   LOOP
      FETCH get_veh_id INTO l_veh_id_rec;
      hr_utility.trace('PROCESS_PRIM_VEH_04, After Fetch.');
      hr_utility.trace('PROCESS_PRIM_VEH_04, effective_start_date='||to_char(l_veh_id_rec.effective_start_date, 'DD-MON-YYYY'));
      hr_utility.trace('PROCESS_PRIM_VEH_04, effective_end_date='||to_char(l_veh_id_rec.effective_end_date, 'DD-MON-YYYY'));
      hr_utility.trace('PROCESS_PRIM_VEH_04, fuel_benefit='||l_veh_id_rec.fuel_benefit);
      hr_utility.trace('PROCESS_PRIM_VEH_04, vehicle_repository_id='||l_veh_id_rec.vehicle_repository_id);
      IF l_new_rec THEN
         hr_utility.trace('PROCESS_PRIM_VEH_04, l_new_rec=TRUE');
      ELSE
         hr_utility.trace('PROCESS_PRIM_VEH_04, l_new_rec=FALSE');
      END IF;
      --
      IF get_veh_id%FOUND THEN
         IF l_new_rec THEN
            l_prev_veh_id_rec.effective_start_date := l_veh_id_rec.effective_start_date;
            l_prev_veh_id_rec.effective_end_date := l_veh_id_rec.effective_end_date;
            l_prev_veh_id_rec.fuel_benefit := l_veh_id_rec.fuel_benefit;
            l_prev_veh_id_rec.vehicle_repository_id := l_veh_id_rec.vehicle_repository_id;
            l_prev_veh_id_rec.vehicle_allocation_id := l_veh_id_rec.vehicle_allocation_id;
            l_new_rec := FALSE;
         ELSE
	    IF nvl(l_prev_veh_id_rec.vehicle_allocation_id, -999) = nvl(l_veh_id_rec.vehicle_allocation_id, -999) THEN
               -- vehicle benefits did not change therefore continue looping
               l_prev_veh_id_rec.effective_end_date := l_veh_id_rec.effective_end_date;
            ELSE
               -- Vehicle Details have changed therefore create reslt dtl record
               hr_utility.trace('PROCESS_PRIM_VEH_04: Creating Vehicle Record for this assignment.');
               create_ext_rslt_dtl_04(p_asg_id, l_asg_start_date, l_asg_end_date,
                                       l_prev_veh_id_rec.effective_start_date,
                                       l_prev_veh_id_rec.effective_end_date,
                                       l_prev_veh_id_rec.fuel_benefit,
                                       l_prev_veh_id_rec.vehicle_repository_id,
				       l_prev_veh_id_rec.vehicle_allocation_id);
               --
               l_prev_veh_id_rec.effective_start_date := l_veh_id_rec.effective_start_date;
               l_prev_veh_id_rec.effective_end_date := l_veh_id_rec.effective_end_date;
               l_prev_veh_id_rec.fuel_benefit := l_veh_id_rec.fuel_benefit;
               l_prev_veh_id_rec.vehicle_repository_id := l_veh_id_rec.vehicle_repository_id;
	       l_prev_veh_id_rec.vehicle_allocation_id := l_veh_id_rec.vehicle_allocation_id;
            END IF;
         END IF;
      ELSE
         -- Last record reched, create ext rslt dtl record
         IF l_prev_veh_id_rec.vehicle_repository_id IS NOT NULL THEN
            hr_utility.trace('PROCESS_PRIM_VEH_04: Creating Last Vehicle Record for this assignment.');
            create_ext_rslt_dtl_04(p_asg_id, l_asg_start_date, l_asg_end_date,
                                    l_prev_veh_id_rec.effective_start_date,
                                    l_prev_veh_id_rec.effective_end_date,
                                    l_prev_veh_id_rec.fuel_benefit,
                                    l_prev_veh_id_rec.vehicle_repository_id,
				    l_prev_veh_id_rec.vehicle_allocation_id);
         END IF;
         --
         EXIT;
      END IF;
   END LOOP;
   --
   hr_utility.trace('Leaving PROCESS_PRIM_VEH_04.');
   --
END process_prim_veh_04;
---------------------------------------------------------------------------
-- Procedure:   PROCESS_SEC_ASG_04
-- Desctiption: This procedure will process all secondary assignments
--              and extract any primary or secondary vehicle details
--              according to the input criteria
---------------------------------------------------------------------------
PROCEDURE process_sec_asg_04(p_asg_id IN NUMBER) IS
   --
   CURSOR get_sec_asg IS
   SELECT distinct paa1.assignment_id
   FROM   per_all_assignments_f paa1, per_all_assignments_f paa2
   WHERE  paa2.assignment_id = p_asg_id
   AND    paa2.assignment_id <> paa1.assignment_id
   AND    paa2.person_id = paa1.person_id
   AND    nvl(paa1.primary_flag, 'N') = 'N';
   --
   l_asg_include VARCHAR2(1) := 'N';
   --
BEGIN
   hr_utility.trace('Entering PROCESS_SEC_ASG, p_asg_id='||p_asg_id);
   --
   -- Loop through all secondary assignments
   FOR sec_asg_rec IN get_sec_asg LOOP
      --
      l_asg_include := 'N';
      l_asg_include := check_asg_inclusion(sec_asg_rec.assignment_id);
      --
      IF l_asg_include = 'Y' THEN
         process_prim_veh_04(sec_asg_rec.assignment_id);
         process_sec_veh_04(sec_asg_rec.assignment_id);
      END IF;
   END LOOP;
   --
   hr_utility.trace('Leaving PROCESS_SEC_ASG_04.');
END process_sec_asg_04;
---------------------------------------------------------------------------
-- Procedure:   PROCESS_TERM_PRIMARY_ASG_04
-- Desctiption: This procedure will process all primary assignments
--              the person that have been terminated before given
--              primary assignment
---------------------------------------------------------------------------
PROCEDURE process_term_primary_asg_04(p_asg_id IN NUMBER) IS
   --
   CURSOR get_term_primary_asg IS
   SELECT distinct paa1.assignment_id
   FROM   per_all_assignments_f paa1, per_all_assignments_f paa2
   WHERE  paa2.assignment_id = p_asg_id
   AND    paa2.assignment_id <> paa1.assignment_id
   AND    paa2.person_id = paa1.person_id
   AND    paa1.effective_end_date < paa2.effective_start_date
   AND    nvl(paa1.primary_flag, 'Y') = 'Y';
   --
   l_asg_include VARCHAR2(1) := 'N';
   --
BEGIN
   hr_utility.trace('Entering PROCESS_TERM_PRIMARY_ASG_04, p_asg_id='||p_asg_id);
   --
   -- Loop through all previous primary assignments
   FOR term_primary_asg_rec IN get_term_primary_asg LOOP
      --
      l_asg_include := 'N';
      l_asg_include := check_asg_inclusion(term_primary_asg_rec.assignment_id);
      --
      IF l_asg_include = 'Y' THEN
         process_prim_veh_04(term_primary_asg_rec.assignment_id);
         process_sec_veh_04(term_primary_asg_rec.assignment_id);
      END IF;
   END LOOP;
   --
   hr_utility.trace('Leaving PROCESS_TERM_PRIMARY_ASG_04.');
END process_term_primary_asg_04;
---------------------------------------------------------------------------
-- Function:    POST_PROCESS_RULE_04
-- Desctiption: This function processes all extracted primary assignments to
--              further extract their secondary vehicle details and
--              all vehicle details of corresponding secondary assignments.
---------------------------------------------------------------------------
FUNCTION post_process_rule_04(p_ext_rslt_id IN NUMBER) RETURN VARCHAR2 IS
   --
   CURSOR get_asg_rcd_id IS
   SELECT rcd.ext_rcd_id
   FROM   ben_ext_rcd rcd,
          ben_ext_rcd_in_file rif,
          ben_ext_dfn dfn,
          ben_ext_rslt rslt
   WHERE  rslt.ext_rslt_id = p_ext_rslt_id
   AND    rslt.ext_dfn_id = dfn.ext_dfn_id
   AND    dfn.ext_file_id = rif.ext_file_id
   AND    rif.ext_rcd_id = rcd.ext_rcd_id
   AND    rcd.name like '%PAY GB P11D Car Extract - Assignment Details Record';
   --
   l_asg_rcd_id NUMBER;
   --
   CURSOR get_veh_rcd_id IS
   SELECT rcd.ext_rcd_id
   FROM   ben_ext_rcd rcd,
          ben_ext_rcd_in_file rif,
          ben_ext_dfn dfn,
          ben_ext_rslt rslt
   WHERE  rslt.ext_rslt_id = p_ext_rslt_id
   AND    rslt.ext_dfn_id = dfn.ext_dfn_id
   AND    dfn.ext_file_id = rif.ext_file_id
   AND    rif.ext_rcd_id = rcd.ext_rcd_id
   AND    rcd.name like '%PAY GB P11D Car Extract - Vehicle Details Record';
   --
   --
   CURSOR get_ext_asg IS
   SELECT person_id, val_01 asg_id, ext_rslt_dtl_id, object_version_number
   FROM   ben_ext_rslt_dtl
   WHERE  ext_rslt_id = p_ext_rslt_id
   AND    ext_rcd_id = l_asg_rcd_id;
   --
   l_obj_no NUMBER := NULL;
   --
   CURSOR get_prim_veh_dtl(p_person_id IN NUMBER) IS
   SELECT *
   FROM   ben_ext_rslt_dtl
   WHERE  ext_rslt_id = p_ext_rslt_id
   AND    ext_rcd_id = g_veh_rcd_id
   AND    person_id = p_person_id;
   --
   l_prim_veh_dtl get_prim_veh_dtl%ROWTYPE;
   --
   l_asg_include VARCHAR2(1);
   --
BEGIN
   hr_utility.trace('Entering POST_PROCESS_RULE_04, p_ext_rslt_id='||p_ext_rslt_id);

   g_ext_rslt_id := p_ext_rslt_id;
   -- Get assignment details record id
   OPEN get_asg_rcd_id;
   FETCH get_asg_rcd_id INTO l_asg_rcd_id;
   CLOSE get_asg_rcd_id;
   --
   hr_utility.trace('POST_PROCESS_RULE_04: l_asg_rcd_id='||l_asg_rcd_id);
   -- Get Vehicle Details Record Id
   OPEN  get_veh_rcd_id;
   FETCH get_veh_rcd_id INTO g_veh_rcd_id;
   CLOSE get_veh_rcd_id;
   --
   hr_utility.trace('POST_PROCESS_RULE_04: g_veh_rcd_id='||g_veh_rcd_id);
   -- Loop through all people extracted
   FOR ext_asg_rec IN get_ext_asg LOOP
      g_person_id := ext_asg_rec.person_id;
      g_bg_id := get_bus_group_id(ext_asg_rec.asg_id);
      l_prim_veh_dtl := NULL;
      --
      hr_utility.trace('POST_PROCESS_RULE_04: ext_asg_rec.asg_id='||ext_asg_rec.asg_id);
      hr_utility.trace('POST_PROCESS_RULE_04: g_person_id='||g_person_id);
      -- Delete extract result detail if primary vehicle details id is null

      OPEN get_prim_veh_dtl(ext_asg_rec.person_id);
      FETCH get_prim_veh_dtl INTO l_prim_veh_dtl;
      CLOSE get_prim_veh_dtl;
      --
      l_asg_include := check_asg_inclusion(ext_asg_rec.asg_id);
      hr_utility.trace('POST_PROCESS_RULE_04: l_prim_veh_dtl.ext_rslt_dtl_id='||l_prim_veh_dtl.ext_rslt_dtl_id);
      --
      IF l_prim_veh_dtl.ext_rslt_dtl_id IS NOT NULL AND l_asg_include = 'N' THEN
         -- Primary assignment does not qualify for extract
         -- Delete this extract rslt details
         ben_ext_rslt_dtl_api.delete_ext_rslt_dtl(p_ext_rslt_dtl_id => l_prim_veh_dtl.ext_rslt_dtl_id,
                                                  p_object_version_number => l_prim_veh_dtl.object_version_number);
         --
      ELSIF l_asg_include = 'Y' THEN
         -- Include this Assignment
         process_prim_veh_04(ext_asg_rec.asg_id);
         process_sec_veh_04(ext_asg_rec.asg_id);
         ben_ext_rslt_dtl_api.delete_ext_rslt_dtl(p_ext_rslt_dtl_id => l_prim_veh_dtl.ext_rslt_dtl_id,
                                                  p_object_version_number => l_prim_veh_dtl.object_version_number);
      END IF;
      --
      process_term_primary_asg_04(ext_asg_rec.asg_id);
      process_sec_asg_04(ext_asg_rec.asg_id);
      --
      hr_utility.trace('POST_PROCESS_RULE_04: Assignment processed, remove it from the extract details table.');
      l_obj_no := ext_asg_rec.object_version_number;
      -- Delete this assignment details record
      ben_ext_rslt_dtl_api.delete_ext_rslt_dtl(p_ext_rslt_dtl_id => ext_asg_rec.ext_rslt_dtl_id,
                                               p_object_version_number => l_obj_no);
      --
   END LOOP;
   --
   hr_utility.trace('Leaving Post_process_rule_04.');
   RETURN 'Y';
   --
END post_process_rule_04;
---------------------------------------------------------------------------
/* End of code that has been added as part of PllD Car Extract 2004 */
END pay_gb_p11d_car_extract;

/
