--------------------------------------------------------
--  DDL for Package Body PQP_GB_MILEAGE_CLAIM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_GB_MILEAGE_CLAIM_PKG" AS
/* $Header: pqgbmgcm.pkb 120.0.12010000.3 2009/10/14 11:27:42 nchinnam ship $ */
g_package  varchar2(33):='pqp_gb_insert_mileage_claim.';

FUNCTION get_dflt_input_value (p_input_value_id    NUMBER
                              ,p_element_type_id   NUMBER
                              ,p_business_group_id NUMBER
                              ,p_effective_date    DATE
                              )
RETURN VARCHAR2 IS

CURSOR c_get_dflt_val
IS
SELECT piv.default_value default_value
  FROM pay_input_values_f piv
 WHERE piv.input_value_id = p_input_value_id
   AND piv.element_type_id = p_element_type_id
   AND piv.business_group_id = p_business_group_id
   AND p_effective_date BETWEEN piv.effective_start_date
                            AND piv.effective_end_date;


l_get_dflt_val   c_get_dflt_val%ROWTYPE;
BEGIN

 OPEN c_get_dflt_val;
  FETCH c_get_dflt_val INTO l_get_dflt_val;
 CLOSE c_get_dflt_val;

 RETURN NVL(l_get_dflt_val.default_value, 'NONE');


END;
--This procedure gets all required info on element,rates
--when the condition is SS or config is yes and PUI.
--the info is fetched from user defined table
PROCEDURE get_purpose_details (p_business_group_id  IN NUMBER
                              ,p_assignment_id      IN NUMBER
                              ,p_effective_date     IN DATE
                              ,p_purpose            IN VARCHAR2
                              ,p_ownership          IN VARCHAR2
                              ,p_vehicle_type       IN VARCHAR2
                              ,p_rate_type          IN  VARCHAR2
                              ,p_element_id         OUT NOCOPY NUMBER
                              ,p_element_name       OUT NOCOPY VARCHAR2
                              ,p_rate_table_id      OUT NOCOPY VARCHAR2
                              ,p_rate_table         OUT NOCOPY VARCHAR2
                              ,p_taxable            OUT NOCOPY VARCHAR2
                             )
IS


CURSOR c_get_column_info (cp_business_group_id NUMBER
                     ,cp_legislation_code VARCHAR2
                     ,cp_table_id  NUMBER
                     ,cp_column_name VARCHAR2
                     )
IS
SELECT puc.user_column_id column_id
  FROM pay_user_columns puc
  WHERE puc.user_table_id    =cp_table_id
    AND puc.user_column_name =cp_column_name
    AND puc.legislation_code = cp_legislation_code;

CURSOR c_get_row_info (cp_business_group_id NUMBER
                      ,cp_legislation_code VARCHAR2
                      ,cp_row_name   VARCHAR2
                      ,cp_effective_date DATE
                       )
IS
SELECT pur.user_row_id,pur.row_low_range_or_name,put.user_table_id
  FROM pay_user_tables put
      ,pay_user_rows_f pur
 WHERE put.range_or_match = 'M'
   AND put.user_table_name ='PQP_TRAVEL_PURPOSE'
   AND put.user_table_id = pur.user_table_id
   AND cp_effective_date BETWEEN pur.effective_start_date
                             AND pur.effective_end_date
   AND pur.row_low_range_or_name = cp_row_name ;

CURSOR c_get_value (cp_business_group_id NUMBER
                   ,cp_legislation_code VARCHAR2
                   ,cp_row_id            NUMBER
                   ,cp_column_id         NUMBER
                   ,cp_effective_date DATE
                    )
IS
SELECT puci.value
  from pay_user_column_instances_f puci
 WHERE puci.user_row_id = cp_row_id
   AND puci.user_column_id = cp_column_id
   AND ( puci.legislation_code= cp_legislation_code OR
         puci.business_group_id= cp_business_group_id)
   AND cp_effective_date between puci.effective_start_date
   AND puci.effective_end_date;

CURSOR c_get_element_id ( cp_business_group_id  NUMBER
                         ,cp_legislation_code   VARCHAR2
                         ,cp_element_name       VARCHAR2
                         ,cp_effective_date     DATE
                        )
IS
SELECT pet.element_type_id
  FROM pay_element_types_f pet
 WHERE pet.element_name = cp_element_name
   AND pet.business_group_id = cp_business_group_id
   AND cp_effective_date BETWEEN pet.effective_start_date
                             AND pet.effective_end_date;

CURSOR c_get_rate_id ( cp_business_group_id  NUMBER
                      ,cp_legislation_code   VARCHAR2
                      ,cp_rate_table_name   VARCHAR2
                      ,cp_effective_date     DATE
                      )
IS
SELECT put.user_table_id
  FROM pay_user_tables put
 WHERE put.user_table_name = cp_rate_table_name
   AND put.business_group_id = cp_business_group_id;

l_get_column_info  c_get_column_info%ROWTYPE;
l_get_row_info     c_get_row_info%ROWTYPE;
l_get_value        c_get_value%ROWTYPE;
l_get_element_id   c_get_element_id%ROWTYPE;
l_get_rate_id      c_get_rate_id%ROWTYPE;
l_legislation_code pqp_configuration_values.legislation_code%TYPE;
l_column_name      pay_user_columns.user_column_name%TYPE;
l_vehicle          VARCHAR2(30) ;
l_ownership        VARCHAR2(30);
l_rates            VARCHAR2(30) := 'Rates Table' ;
l_element          VARCHAR2(30) := 'Claim Element';
l_Tax              VARCHAr2(30) := 'Taxable';

BEGIN
 l_legislation_code := pqp_car_mileage_functions.
                       get_legislation_code (p_business_group_id);
 OPEN c_get_row_info (p_business_group_id
                     ,l_legislation_code
                     ,p_purpose
                     ,p_effective_date
                     );
  FETCH c_get_row_info INTO l_get_row_info;
 CLOSE c_get_row_info ;

 IF p_vehicle_type = 'C' AND
    p_ownership='P'  THEN
  l_ownership :='Private' ;
  l_vehicle   :='Car';

 ELSIF p_vehicle_type ='C'
    AND p_ownership='C'  THEN

  l_ownership :='Company' ;
  l_vehicle   :='Car';
 ELSIF p_vehicle_type ='M' AND
        p_ownership='P'  THEN

  l_ownership :='Private' ;
  l_vehicle   :='Motorcycle';
 ELSIF p_vehicle_type ='P'
   AND     p_ownership='P'  THEN

  l_ownership :='Private' ;
  l_vehicle   :='Pedalcycle';
 ELSIF p_vehicle_type ='M'
    AND p_ownership='C'  THEN
  l_ownership :='Company' ;
  l_vehicle   :='Motorcycle';

 ELSIF p_vehicle_type ='P'
    AND p_ownership='C'  THEN

  l_ownership :='Company' ;
  l_vehicle   :='Pedalcycle';
 END IF;
 FOR i in 1..3
  LOOP
   IF i= 1 THEN
    l_column_name := l_ownership||' '||l_vehicle||' '||l_element;
   ELSIF i=2 THEN
     l_column_name := l_ownership||' '||l_vehicle||' '||l_rates;
   ELSIF i=3 THEN
     l_column_name := l_ownership||' '||l_tax;
   END IF;
   OPEN c_get_column_info (p_business_group_id
                          ,l_legislation_code
                          ,l_get_row_info.user_table_id
                          ,l_column_name
                          );
   FETCH c_get_column_info INTO l_get_column_info;
  CLOSE c_get_column_info;


  OPEN  c_get_value (p_business_group_id
                    ,l_legislation_code
                    ,l_get_row_info.user_row_id
                    ,l_get_column_info.column_id
                    ,p_effective_date
                    );
   FETCH c_get_value INTO l_get_value;
  CLOSE c_get_value;

  IF i= 1 THEN
   p_element_name := l_get_value.value ;
   OPEN c_get_element_id ( p_business_group_id
                     ,l_legislation_code
                     ,p_element_name
                     ,p_effective_date
                     );
    FETCH c_get_element_id INTO l_get_element_id;
   CLOSE c_get_element_id;

   p_element_id:=l_get_element_id.element_type_id;
   l_get_value.value:=null;
  ELSIF i=2 THEN
   p_rate_table :=l_get_value.value ;
   IF p_rate_type='N' THEN
    OPEN c_get_rate_id ( p_business_group_id
                       ,l_legislation_code
                       ,p_rate_table
                       ,p_effective_date
                      );
     FETCH c_get_rate_id INTO l_get_rate_id;
    CLOSE c_get_rate_id;
    p_rate_table_id :=l_get_rate_id.user_table_id;
   END IF;
   l_get_value.value:=null;
  ELSIF i=3 THEN
   p_taxable := SUBSTR(l_get_value.value,0,1) ;
   l_get_value.value:=null;
  END IF;
 END LOOP;

END;


FUNCTION get_payroll_id ( p_assignment_id      IN NUMBER
                         ,p_business_group_id  IN NUMBER
                         ,p_effective_date     IN DATE
                         ,p_payroll_id         OUT NOCOPY NUMBER
                         )
RETURN NUMBER
IS
--Get payroll_id
CURSOR c_get_asg_det ( cp_assignment_id     NUMBER
                      ,cp_business_group_id NUMBER
                      ,cp_effective_date    DATE
                     )
 IS
SELECT payroll_id
  FROM per_all_assignments_f paaf
 WHERE paaf.assignment_id=cp_assignment_id
   AND cp_effective_date BETWEEN paaf.effective_start_date
                           AND  paaf.effective_end_date
   AND paaf.business_group_id =cp_business_group_id
   AND paaf.payroll_id IS NOT NULL;

l_get_asg_det                 c_get_asg_det%ROWTYPE;
l_proc    varchar2(72) := g_package ||'get_payroll_id';
BEGIN

 hr_utility.set_location('Enter get payroll id',10);
   OPEN c_get_asg_det ( p_assignment_id
                     ,p_business_group_id
                     ,p_effective_date
                    );
     FETCH c_get_asg_det INTO l_get_asg_det;
     hr_utility.set_location('Inside the Loop',15);
     IF c_get_asg_det%NOTFOUND THEN
      RETURN(-1);
     ELSE
      p_payroll_id:=l_get_asg_det.payroll_id;

      RETURN(0);
     END IF;
   CLOSE c_get_asg_det;


 hr_utility.set_location(' Leaving get payroll id',20);

END;
--Decides effective date to create an element entry
FUNCTION get_effective_date (p_assignment_id     IN NUMBER
                            ,p_business_group_id IN NUMBER
                            ,p_payroll_id        IN NUMBER
                            ,p_effective_date    IN DATE
                             )
RETURN DATE
IS

--Get next payroll date
CURSOR c_get_payroll_det (cp_assignment_id     NUMBER
                         ,cp_business_group_id NUMBER
                         ,cp_payroll_id        NUMBER
                         ,cp_effective_date    DATE
                         )
IS
SELECT ptp.start_date,ptp.end_date
  FROM per_time_periods ptp
 WHERE (ptp.end_date > ( SELECT MAX(effective_date)
                      FROM pay_payroll_actions     ppa
                          ,pay_assignment_actions  paa
                     WHERE ppa.action_status='C'
                       AND ppa.action_type in ('R','Q')
                       AND ppa.business_group_id=cp_business_group_id
                       AND ppa.payroll_id=cp_payroll_id
                       AND ppa.payroll_id=ptp.payroll_id
                       AND ppa.payroll_action_id=paa.payroll_action_id
                       AND paa.assignment_id=cp_assignment_id
                       AND paa.action_status='C' ))
  AND ptp.payroll_id=cp_payroll_id
  AND ROWNUM=1 ;

--If the above cursor fails to fetch data
--when conditions like new employees claim
--is processed then this cursor is used.

CURSOR c_get_alt_payroll_det (cp_payroll_id        NUMBER
                             ,cp_effective_date    DATE
                              )
IS
SELECT ptp.start_date,ptp.end_date
  FROM per_time_periods ptp
 WHERE ptp.end_date >= cp_effective_date
  AND ptp.payroll_id=cp_payroll_id
  AND ROWNUM=1 ;


l_get_payroll_det             c_get_payroll_det%ROWTYPE;
l_get_alt_payroll_det         c_get_alt_payroll_det%ROWTYPE;
l_effective_date              DATE;
l_proc    varchar2(72) := g_package ||'get_effective_date';
BEGIN
 hr_utility.set_location(l_proc,10);
  OPEN c_get_payroll_det ( p_assignment_id
                          ,p_business_group_id
                          ,p_payroll_id
                          ,p_effective_date
                         );
    FETCH c_get_payroll_det INTO l_get_payroll_det;
    IF c_get_payroll_det%NOTFOUND THEN
     OPEN c_get_alt_payroll_det (p_payroll_id
                                ,p_effective_date
                                 );
      FETCH c_get_alt_payroll_det INTO l_get_payroll_det;

     CLOSE c_get_alt_payroll_det;
    END IF;
 hr_utility.set_location(l_proc,20);
  CLOSE c_get_payroll_det;
  IF p_effective_date BETWEEN l_get_payroll_det.start_date
                         AND l_get_payroll_det.end_date
     OR  p_effective_date >  l_get_payroll_det.end_date THEN
      l_effective_date :=p_effective_date;
  ELSE
   l_effective_date :=l_get_payroll_det.start_date;
  END IF;

  RETURN(l_effective_date);
 hr_utility.set_location(l_proc,30);
END;

FUNCTION get_asg_element (p_assignment_id        IN NUMBER,
                          p_business_group_id    IN NUMBER,
                          p_effective_date       IN DATE,
                          p_ownership_type       IN VARCHAR2,
                          p_registration_number  IN VARCHAR2,
                          p_usage_type           IN VARCHAR2,
                          p_check_type           IN VARCHAR2,
                          p_sl_rates_type        IN VARCHAR2
                          )
RETURN VARCHAR2
IS
--If mileage element is null then fetch element and rates from
-- assignment level
CURSOR c_get_asg_element (cp_assignment_id         NUMBER,
                          cp_business_group_id     NUMBER,
                          cp_effective_date        DATE,
                          cp_ownership_type        VARCHAR2,
                          cp_registration_number   VARCHAR2
                          )
IS
SELECT pvaf.element_type_id
      ,pvaf.rates_table_id
      ,pvaf.sliding_rates_info sliding_rates
  FROM pqp_vehicle_allocations_f pvaf,
       pqp_vehicle_repository_f  pvrf
  WHERE pvaf.assignment_id=cp_assignment_id
    AND pvaf.business_group_id=cp_business_group_id
    AND pvrf.vehicle_ownership=cp_ownership_type
    AND (p_registration_number IS NULL or
         pvrf.registration_number=cp_registration_number)
    AND pvaf.usage_type=p_usage_type
    AND cp_effective_date BETWEEN pvaf.effective_start_date
                                   AND pvaf.effective_end_date
    AND pvaf.vehicle_repository_id=pvrf.vehicle_repository_id
    AND pvaf.business_group_id=pvrf.business_group_id
    AND cp_effective_date BETWEEN pvrf.effective_start_date
                                   AND pvrf.effective_end_date;

CURSOR  c_ele_type (cp_element_type_id   NUMBER)
 IS
 SELECT NVL(pete.eei_information2 ,'N') ele_type
  FROM  pay_element_type_extra_info pete
 WHERE  pete.information_type='PQP_VEHICLE_MILEAGE_INFO'
   AND  pete.element_type_id= cp_element_type_id;

l_proc    varchar2(72) := g_package ||'get_asg_element';
l_get_asg_element         c_get_asg_element%ROWTYPE;
l_ele_type                c_ele_type%ROWTYPE;
BEGIN
 hr_utility.set_location('Inside get asg element'||l_proc,10);
  OPEN c_get_asg_element (
                          p_assignment_id
                         ,p_business_group_id
                         ,p_effective_date
                         ,p_ownership_type
                         ,p_registration_number
                          );
   FETCH c_get_asg_element INTO l_get_asg_element;
  CLOSE c_get_asg_element;

  OPEN c_ele_type (l_get_asg_element.element_type_id);
   FETCH c_ele_type INTO l_ele_type;
  CLOSE c_ele_type;
 hr_utility.set_location(l_proc,20);

 IF p_check_type='E' AND (l_ele_type.ele_type=p_sl_rates_type) THEN
  RETURN(NVL(l_get_asg_element.element_type_id,-1));
 ELSE
   RETURN (-1);
 END IF;
 IF p_check_type='R' AND p_sl_rates_type ='N' THEN

  RETURN(NVL(l_get_asg_element.rates_table_id,-1));
 ELSIF  p_check_type='R' AND p_sl_rates_type ='Y' THEN

  RETURN(NVL(l_get_asg_element.sliding_rates,-1));
 END IF;
 hr_utility.set_location('leaving get asg element'||l_proc,30);
END;

--Get default rates if entered
FUNCTION get_default_value(p_business_group_id IN NUMBER
                          ,p_element_type_id   IN NUMBER
                          ,p_effective_date    IN DATE
                          ,p_search_type       IN VARCHAR2
                          )
RETURN NUMBER
IS
CURSOR c_get_default_value
IS
SELECT piv.default_value
 FROM pay_input_values_f piv
WHERE piv.element_type_id= p_element_type_id
  AND piv.name           =p_search_type
  AND p_effective_date BETWEEN piv.effective_start_date
                           AND piv.effective_end_date;

CURSOR c_get_rate_id(cp_user_table_name VARCHAR2)
IS
SELECT user_table_id
  from pay_user_tables put
 WHERE user_table_name=cp_user_table_name
   AND put.business_group_id =p_business_group_id;

l_get_default_value c_get_default_value%ROWTYPE;
l_get_rate_id       c_get_rate_id%ROWTYPE;
l_proc    varchar2(72) := g_package ||'get_default_value';

BEGIN
 hr_utility.set_location(l_proc,10);
 OPEN c_get_default_value;
  FETCH c_get_default_value INTO l_get_default_value;
  IF c_get_default_value%FOUND THEN
   OPEN c_get_rate_id(l_get_default_value.default_value);
    FETCH c_get_rate_id INTO l_get_rate_id;
     RETURN(NVL(l_get_rate_id.user_table_id,-1));

   CLOSE c_get_rate_id;
  ELSE
   RETURN(-1);
  END IF;
 CLOSE c_get_default_value;

 hr_utility.set_location(l_proc,20);
END;


--Validate Mileage Element.
FUNCTION validate_mileage_element ( p_assignment_id     IN NUMBER
                                   ,p_business_group_id IN NUMBER
                                   ,p_effective_date    IN DATE
                                   ,p_vehicle_type      IN VARCHAR2
                                   ,p_ownership         IN VARCHAR2
                                   ,p_element_type_id   IN NUMBER
                                   ,p_sl_rate_type      IN VARCHAR2
                                   ,p_element_link_id   OUT NOCOPY NUMBER
                                   )
RETURN NUMBER
IS

--Validate mileage element
CURSOR c_validate_mileage_element( cp_assignment_id     NUMBER
                                  ,cp_business_group_id NUMBER
                                  ,cp_effective_date    DATE
                                  ,cp_vehicle_type      VARCHAR2
                                  ,cp_ownership         VARCHAR2
                                  ,cp_element_type_id   NUMBER
                                  ,cp_sl_rate_type      VARCHAR2
                                )
IS
SELECT element.element_type_id
      , elementtl.element_name
      ,link.element_link_id
 FROM  pay_element_types_f_tl       elementtl,
       pay_element_types_f          element,
       pay_element_links_f          link,
       per_all_assignments_f        asgt ,
       pay_element_type_extra_info  pete,
       per_periods_of_service       service_period
 WHERE element.element_type_id = elementtl.element_type_id
   AND elementtl.language = USERENV('LANG')
   AND asgt.business_group_id = link.business_group_id
   AND asgt.business_group_id = element.business_group_id
   AND element.business_group_id =link.business_group_id
  AND asgt.business_group_id =service_period.business_group_id
   AND element.element_type_id = link.element_type_id
   AND service_period.period_of_service_id = asgt.period_of_service_id
   AND cp_effective_date
       between element.effective_start_date and element.effective_end_date
   AND cp_effective_date
        between asgt.effective_start_date and asgt.effective_end_date
   AND cp_effective_date
        between link.effective_start_date and link.effective_end_date
   AND element.indirect_only_flag = 'N'
   AND ((link.payroll_id is NOT NULL AND
           link.payroll_id = asgt.payroll_id)
   OR (link.link_to_all_payrolls_flag = 'Y'
   AND asgt.payroll_id IS NOT NULL)
   OR (link.payroll_id IS NULL AND link.link_to_all_payrolls_flag = 'N'))
   AND (link.organization_id = asgt.organization_id
   OR link.organization_id IS NULL)
   AND (link.position_id = asgt.position_id OR link.position_id IS NULL)
   AND (link.job_id = asgt.job_id OR link.job_id IS NULL)
   AND (link.grade_id = asgt.grade_id OR link.grade_id IS NULL)
   AND (link.location_id = asgt.location_id OR link.location_id IS NULL)
   AND (link.pay_basis_id = asgt.pay_basis_id OR link.pay_basis_id IS NULL)
   AND (link.employment_category = asgt.employment_category
   OR link.employment_category IS NULL)
   AND (link.people_group_id IS NULL
   OR EXISTS
           ( SELECT 1 FROM pay_assignment_link_usages_f usage
             WHERE usage.assignment_id = asgt.assignment_id
               AND usage.element_link_id = link.element_link_id
               AND cp_effective_date BETWEEN usage.effective_start_date
               AND usage.effective_end_date))
   AND (service_period.actual_termination_date
       IS NULL OR (service_period.actual_termination_date IS NOT NULL
   AND cp_effective_date <= DECODE(element.post_termination_rule, 'L',
      service_period.last_standard_process_date, 'F',
      NVL(service_period.final_process_date,hr_api.g_eot),
      service_period.actual_termination_date) ))
   AND element.element_type_id = pete.element_type_id
   AND pete.information_type='PQP_VEHICLE_MILEAGE_INFO'
   AND pete.eei_information_category='PQP_VEHICLE_MILEAGE_INFO'
   AND pete.eei_information1<>'L'
   AND NVL(pete.eei_information2,'N')=cp_sl_rate_type
   AND asgt.assignment_id=cp_assignment_id
   AND asgt.business_group_id=cp_business_group_id
   AND pete.eei_information1=DECODE(cp_vehicle_type,'C',cp_ownership,
                                      cp_ownership||cp_vehicle_type)
   AND element.element_type_id=cp_element_type_id;


l_proc    varchar2(72) := g_package ||'validate_mileage_element';
l_validate_mileage_element    c_validate_mileage_element%ROWTYPE;
BEGIN

   hr_utility.set_location(l_proc,10);

        OPEN c_validate_mileage_element( p_assignment_id
                                        ,p_business_group_id
                                        ,p_effective_date
                                        ,p_vehicle_type
                                        ,p_ownership
                                        ,p_element_type_id
                                        ,p_sl_rate_type
                                        );
        LOOP
          FETCH c_validate_mileage_element INTO
                                  l_validate_mileage_element;
          EXIT WHEN c_validate_mileage_element%NOTFOUND;
          hr_utility.set_location(l_proc,20);
          IF l_validate_mileage_element.element_type_id IS NOT NULL THEN
            p_element_link_id := l_validate_mileage_element.element_link_id;
            RETURN(l_validate_mileage_element.element_type_id);
            EXIT;
          END IF;
        END LOOP;
        CLOSE c_validate_mileage_element;
 IF l_validate_mileage_element.element_type_id IS NULL THEN
  p_element_link_id :=-1;
  RETURN(-1);
 END IF;

 hr_utility.set_location(l_proc,30);
EXCEPTION
--------
WHEN OTHERS THEN
RETURN(-1);
 hr_utility.set_location(l_proc,40);
END;

--Get eligible mileage element if no element is entered at
--all levels.
FUNCTION get_elig_mileage_element( p_assignment_id       IN NUMBER
                                  ,p_business_group_id   IN NUMBER
                                  ,p_effective_date      IN DATE
                                  ,p_vehicle_type        IN VARCHAR2
                                  ,p_ownership           IN VARCHAR2
                                  ,p_sl_rate_type        IN VARCHAR2
                                  ,p_element_link_id     OUT NOCOPY NUMBER
                                )

RETURN NUMBER
IS

CURSOR c_get_elig_mileage_element( cp_assignment_id     NUMBER
                                  ,cp_business_group_id NUMBER
                                  ,cp_effective_date    DATE
                                  ,cp_vehicle_type      VARCHAR2
                                  ,cp_ownership         VARCHAR2
                                  ,cp_sl_rate_type      VARCHAR2
                                )
IS
SELECT element.element_type_id , elementtl.element_name
 FROM  pay_element_types_f_tl       elementtl,
       pay_element_types_f          element,
       pay_element_links_f          link,
       per_all_assignments_f        asgt ,
       pay_element_type_extra_info  pete,
       per_periods_of_service       service_period
 WHERE element.element_type_id = elementtl.element_type_id
   AND elementtl.language = USERENV('LANG')
   AND asgt.business_group_id = link.business_group_id
   AND asgt.business_group_id = element.business_group_id
   AND element.business_group_id =link.business_group_id
  AND asgt.business_group_id =service_period.business_group_id
   AND element.element_type_id = link.element_type_id
   AND service_period.period_of_service_id = asgt.period_of_service_id
   AND cp_effective_date
       between element.effective_start_date and element.effective_end_date
   AND cp_effective_date
        between asgt.effective_start_date and asgt.effective_end_date
   AND cp_effective_date
        between link.effective_start_date and link.effective_end_date
   AND element.indirect_only_flag = 'N'
   AND ((link.payroll_id is NOT NULL AND
           link.payroll_id = asgt.payroll_id)
           OR (link.link_to_all_payrolls_flag = 'Y'
           AND asgt.payroll_id IS NOT NULL)
           OR (link.payroll_id IS NULL
           AND link.link_to_all_payrolls_flag = 'N'))
           AND (link.organization_id = asgt.organization_id
           OR link.organization_id IS NULL)
           AND (link.position_id = asgt.position_id
           OR link.position_id IS NULL)
           AND (link.job_id = asgt.job_id OR link.job_id IS NULL)
           AND (link.grade_id = asgt.grade_id OR link.grade_id IS NULL)
           AND (link.location_id = asgt.location_id
           OR link.location_id IS NULL)
           AND (link.pay_basis_id = asgt.pay_basis_id
           OR link.pay_basis_id IS NULL)
           AND (link.employment_category = asgt.employment_category
           OR link.employment_category IS NULL)
           AND (link.people_group_id IS NULL OR EXISTS
                 ( SELECT 1 FROM pay_assignment_link_usages_f usage
                    WHERE usage.assignment_id = asgt.assignment_id
                      AND usage.element_link_id = link.element_link_id
                      AND cp_effective_date BETWEEN usage.effective_start_date
                                              AND usage.effective_end_date))
          AND (service_period.actual_termination_date
                IS NULL OR (service_period.actual_termination_date IS NOT NULL
                 AND cp_effective_date <=
                 DECODE(element.post_termination_rule, 'L',
                 service_period.last_standard_process_date, 'F',
                 NVL(service_period.final_process_date,hr_api.g_eot),
                 service_period.actual_termination_date) ))
          AND element.element_type_id = pete.element_type_id
          AND pete.information_type='PQP_VEHICLE_MILEAGE_INFO'
          AND pete.eei_information_category='PQP_VEHICLE_MILEAGE_INFO'
          AND pete.eei_information1<>'L'
          AND NVL(pete.eei_information2,'N')= cp_sl_rate_type
          AND asgt.assignment_id=cp_assignment_id
          AND asgt.business_group_id=cp_business_group_id
          AND pete.eei_information1=DECODE(cp_vehicle_type,'C',cp_ownership,
                                           cp_ownership||cp_vehicle_type)
          ORDER BY element.effective_start_date DESC;




l_proc    varchar2(72) := g_package ||'get_elig_mileage_element';
l_get_elig_mileage_element    c_get_elig_mileage_element%ROWTYPE;
l_validate_mileage_element    pay_element_types_f.element_type_id%TYPE;
BEGIN

 hr_utility.set_location(l_proc,10);
      OPEN c_get_elig_mileage_element( p_assignment_id
                                  ,p_business_group_id
                                  ,p_effective_date
                                  ,p_vehicle_type
                                  ,p_ownership
                                  ,p_sl_rate_type
                                );
      LOOP
        FETCH c_get_elig_mileage_element INTO
                                 l_get_elig_mileage_element;
        EXIT WHEN c_get_elig_mileage_element%NOTFOUND;
         hr_utility.set_location(' Enter validate element:' || l_proc,100);
          l_validate_mileage_element:= validate_mileage_element(
                                        p_assignment_id     =>p_assignment_id
                                       ,p_business_group_id =>p_business_group_id
                                       ,p_effective_date    =>p_effective_date
                                       ,p_vehicle_type      =>p_vehicle_type
                                       ,p_ownership         =>p_ownership
                                       ,p_element_type_id
                                            =>l_get_elig_mileage_element.element_type_id
                                       ,p_sl_rate_type      =>p_sl_rate_type
                                       ,p_element_link_id   =>p_element_link_id
                                       );
 hr_utility.set_location(l_proc,20);
       IF l_validate_mileage_element <> -1 THEN
        RETURN(l_get_elig_mileage_element.element_type_id);
        EXIT;
       END IF;
      END LOOP;
    CLOSE c_get_elig_mileage_element;

 hr_utility.set_location(l_proc,30);
 IF l_get_elig_mileage_element.element_type_id IS NULL
                                OR l_validate_mileage_element =-1 THEN
  RETURN(-1);
 END IF;

 hr_utility.set_location(l_proc,40);
EXCEPTION
--------
WHEN OTHERS THEN
RETURN(-1);
 hr_utility.set_location(l_proc,50);
END;

--Check if CC is available in the repository
FUNCTION get_cc (p_effective_date             IN DATE,
                 p_business_group_id          IN NUMBER,
                 p_registration_number        IN VARCHAR2,
                 p_engine_capacity            OUT NOCOPY  VARCHAR2
                 )
RETURN VARCHAR2
IS
CURSOR c_get_cc
IS
SELECT pvr.engine_capacity_in_cc engine_capacity
 FROM  pqp_vehicle_repository_f pvr
WHERE  pvr.business_group_id   =p_business_group_id
  AND  pvr.registration_number =p_registration_number
  AND  p_effective_date BETWEEN pvr.effective_start_date
                            AND pvr.effective_end_date
  AND pvr.engine_capacity_in_cc IS NOT NULL;
l_get_cc        c_get_cc%ROWTYPE;
l_proc    varchar2(72) := g_package ||'get_cc';
BEGIN

 hr_utility.set_location(l_proc,10);
 OPEN c_get_cc;
  FETCH c_get_cc INTO l_get_cc;
  IF c_get_cc%FOUND THEN
   p_engine_capacity :=l_get_cc.engine_capacity;
   RETURN ('Y');
    hr_utility.set_location(l_proc,20);
  ELSE
   RETURN ('N');
   hr_utility.set_location(l_proc,30);
  END IF;
 CLOSE c_get_cc;

 hr_utility.set_location(l_proc,40);
EXCEPTION
--------
WHEN OTHERS THEN
 hr_utility.set_location(l_proc,50);
RETURN ('N');

END;

--Main Insert Procedure
--here the process works in following order
--If mileage element is entered in the UI then
--the element is created directly by just checking the
--link . If the element is not entered at UI level then
--the allocation level is checked for any elements
--if not then the config level is checked, finally the link
--is checked and if any element is found that can be created for
--the employee.The rates work the same way.
PROCEDURE insert_mileage_claim
        ( p_effective_date             IN DATE,
          p_web_adi_identifier         IN VARCHAR2  ,
          p_info_id                    IN VARCHAR2  ,
          p_time_stamp                 IN VARCHAR2  ,
          p_assignment_id              IN NUMBER,
          p_business_group_id          IN NUMBER,
          p_ownership                  IN VARCHAR2  ,
          p_usage_type                 IN VARCHAR2  ,
          p_vehicle_type               IN VARCHAR2,
          p_start_date                 IN VARCHAR2  ,
          p_end_date                   IN VARCHAR2  ,
          p_claimed_mileage            IN VARCHAR2  ,
          p_actual_mileage             IN VARCHAR2  ,
          p_registration_number        IN VARCHAR2  ,
          p_engine_capacity            IN VARCHAR2  ,
          p_fuel_type                  IN VARCHAR2  ,
          p_calculation_method         IN VARCHAR2  ,
          p_user_rates_table           IN VARCHAR2  ,
          p_fiscal_ratings             IN VARCHAR2  ,
          p_PAYE_taxable               IN VARCHAR2  ,
          p_no_of_passengers           IN VARCHAR2  ,
          p_purpose                    IN VARCHAR2  ,
          p_data_source                IN VARCHAR2  ,
          p_user_type                  IN VARCHAR2  ,
          p_mileage_claim_element      IN OUT NOCOPY NUMBER  ,
          p_element_entry_id           IN OUT NOCOPY NUMBER  ,
          p_element_entry_date         IN OUT NOCOPY DATE
 )

IS


--If Mileage element is not found at assignment level
--then fetch from configuration value table.
CURSOR c_get_config_element(cp_business_group_id NUMBER)
IS
select TO_NUMBER(pcv.pcv_information6) element_type_id
       ,TO_NUMBER(pcv.pcv_information5) Rates_table_id
  from pqp_configuration_values pcv
 WHERE pcv.pcv_information_category='PQP_MILEAGE CALC_INFO'
   AND pcv.business_group_id=cp_business_group_id;



--Validate mileage element
--Get element link details
CURSOR c_get_ele_link ( cp_element_type_id   NUMBER
                       ,cp_effective_date    DATE
                       ,cp_business_group_id NUMBER
                       )
IS
SELECT pelf.element_link_id
  FROM pay_element_links_f pelf
 WHERE pelf.element_type_id=cp_element_type_id
   AND cp_effective_date BETWEEN pelf.effective_start_date
                             AND pelf.effective_end_date
   AND pelf.business_group_id=cp_business_group_id;


--Variables
l_proc    varchar2(72) := g_package ||'insert_mileage_claim';
l_get_pay_det                 per_all_assignments_f.payroll_id%TYPE;
--l_get_payroll_det             c_get_payroll_det%ROWTYPE;
--l_get_alt_payroll_det         c_get_alt_payroll_det%ROWTYPE;
l_get_asg_element_id          pay_element_types_f.element_type_id%TYPE;
l_get_purp_element_id         pay_element_types_f.element_type_id%TYPE;
l_get_asg_rate_id             VARCHAR2(80);
l_get_config_element          c_get_config_element%ROWTYPE;
l_valid_mileage_element_id    pay_element_types_f.element_type_id%TYPE;
l_elig_mileage_element_id     pay_element_types_f.element_type_id%TYPE;
l_get_ele_link                c_get_ele_link%ROWTYPE;
l_effective_date              DATE;
l_element_type_id             pay_element_types_f.element_type_id%TYPE;
l_element_link_id             pay_element_links_f.element_link_id%TYPE;
l_rates_table_id              VARCHAR2(80); --pay_user_tables.user_table_id%TYPE;
l_get_element_type_id         pqp_configuration_values.pcv_information5%TYPE;
l_get_rate_id                 pqp_configuration_values.pcv_information6%TYPE;
l_chk_eligibility             VARCHAR2(1);
l_chk_mndtry                  VARCHAR2(1);
l_message                     VARCHAR2(100);
l_session_id                  pay_us_rpt_totals.GRE_NAME%TYPE;
l_businesss_group_id          pay_us_rpt_totals.BUSINESS_GROUP_ID%TYPE;
l_assignment_id               pay_us_rpt_totals.LOCATION_ID%TYPE;
l_string                      VARCHAR2(3):='___';
l_ret_mesg                    NUMBER(2);
l_ret_cc                      VARCHAR2(1);
l_engine_capacity             VARCHAR2(9);
l_canonical_st_dt             VARCHAR2(24);
l_canonical_ed_dt             VARCHAR2(24);
l_st_dt                       DATE;
l_ed_dt                       DATE;
l_user_type                   VARCHAR2(3);
l_purp_element_name           pay_element_types_f.element_name%TYPE;
l_purp_rates_table_id         pay_user_tables.user_table_id%TYPE;
l_purp_rates_table            pay_user_tables.user_table_name%TYPE;
l_purp_taxable                VARCHAR2(3);
l_sliding_rates               VARCHAR2(1);
l_paye_taxable                VARCHAR2(3);
BEGIN
 l_paye_taxable :=p_paye_taxable;
 hr_utility.set_location(' Enter:' || l_proc,10);

 IF p_user_type='PUI' THEN
  l_user_type := pqp_car_mileage_functions.get_config_info
                 (p_business_group_id => p_business_group_id
                 ,p_info_type         => 'Professional User'
                          );
 END IF;

 l_sliding_rates :=pqp_car_mileage_functions.get_config_info
                 (p_business_group_id => p_business_group_id
                 ,p_info_type         => 'Rates'
                          );

--This call for claim Insert
IF  p_info_id IS NULL   THEN

--Check if CC is correct

  l_ret_cc      :=get_cc
                 (
                 p_effective_date        =>p_effective_date,
                 p_business_group_id      =>p_business_group_id,
                 p_registration_number    =>p_registration_number,
                 p_engine_capacity        =>l_engine_capacity
                 );

  IF l_ret_cc ='N' AND p_engine_capacity IS NOT NULL THEN

  l_engine_capacity :=p_engine_capacity;
 ELSIF  p_engine_capacity IS NULL AND l_ret_cc ='N'AND p_vehicle_type<>'P' THEN
  fnd_message.set_name('PQP','PQP_230736_CC_MNDTRY');
  fnd_message.raise_error;
  hr_multi_message.end_validation_set;
 ELSIF p_vehicle_type ='P' THEN

  l_engine_capacity:='0';
 END IF;

 hr_utility.set_location(' Enter payroll check cursor:' || l_proc,20);

   ---Get assignemnt payroll info.
    l_ret_mesg:=get_payroll_id
                     (p_assignment_id    =>p_assignment_id
                     ,p_business_group_id=>p_business_group_id
                     ,p_effective_date   =>p_effective_date
                     ,p_payroll_id       =>l_get_pay_det
                    );
     IF l_ret_mesg<>0  THEN
      fnd_message.set_name('PQP','PQP_230857_PAYROLL_NOT_EXST');
      fnd_message.raise_error;
      hr_multi_message.end_validation_set;
     END IF;

 hr_utility.set_location(' Enter payroll details cursor:' || l_proc,30);
  --get next unprocessed payroll date for that asg.
  --If the effective date is in between or less then
  --payroll run date then the date the element
  --entry created will be effective date or the start date
  --if the effective date is lesser then the start date.
  --If greated than the payroll dates even then the effective
  --date is considered.
     l_effective_date:=get_effective_date
                       ( p_assignment_id     =>p_assignment_id
                        ,p_business_group_id =>p_business_group_id
                        ,p_payroll_id        =>l_get_pay_det
                        ,p_effective_date     =>p_effective_date
                        );

 hr_utility.set_location(' Enter check eligibility:' || l_proc,40);
  --Check for claim eligibility
  l_chk_eligibility:=pqp_gb_mileage_claim_pkg.
                   chk_eligibility (
                            p_effective_date      =>l_effective_date
                           ,p_assignment_id       =>p_assignment_id
                           ,p_business_group_id   =>p_business_group_id
                           ,p_ownership           =>p_ownership
                           ,p_usage_type          =>p_usage_type
                           ,p_vehicle_type        =>p_vehicle_type
                           ,p_start_date          =>p_start_date
                           ,p_end_date            =>p_end_date
                           ,p_claimed_mileage     =>p_claimed_mileage
                           ,p_actual_mileage      =>p_actual_mileage
                           ,p_registration_number =>p_registration_number
                           ,p_data_source         =>p_data_source
                           ,p_message             =>l_message
                          );

  IF l_chk_eligibility = 'N' THEN
     fnd_message.raise_error;
     hr_multi_message.end_validation_set;
  END IF;
 hr_utility.set_location(' Enter Assignment level Element search:' || l_proc,50);
  --Find if element is present at the assignment level

  IF p_mileage_claim_element IS NULL  THEN
   IF  p_user_type='SS' OR ( p_user_type='PUI' AND  l_user_type='Y') THEN
    get_purpose_details (p_business_group_id  =>p_business_group_id
                        ,p_assignment_id      =>p_assignment_id
                        ,p_effective_date     =>l_effective_date
                        ,p_purpose            =>p_purpose
                        ,p_ownership          =>p_ownership
                        ,p_vehicle_type       =>p_vehicle_type
                        ,p_rate_type          =>l_user_type
                        ,p_element_id         =>l_get_purp_element_id
                        ,p_element_name       =>l_purp_element_name
                        ,p_rate_table_id      =>l_purp_rates_table_id
                        ,p_rate_table         =>l_purp_rates_table
                        ,p_taxable            =>l_purp_taxable
                        );
     l_paye_taxable:=l_purp_taxable;
   END IF;
   IF l_get_purp_element_id IS NULL THEN
   l_get_asg_element_id:= get_asg_element (
                          p_assignment_id       =>p_assignment_id
                         ,p_business_group_id   =>p_business_group_id
                         ,p_effective_date      =>p_effective_date
                         ,p_ownership_type      =>p_ownership
                         ,p_registration_number =>p_registration_number
                         ,p_usage_type          =>p_usage_type
                         ,p_check_type          =>'E'
                         ,p_sl_rates_type       =>l_sliding_rates
                          );

   END IF;
 hr_utility.set_location(' Enter config level Element search:' || l_proc,60);
    --if element is not present at assignment level then fetch from conf table
    IF (l_get_asg_element_id IS NULL OR l_get_asg_element_id=-1 )
         AND  l_get_purp_element_id IS NULL  THEN
       pqp_gb_mileage_claim_pkg.get_config_info (
                            p_business_group_id  =>p_business_group_id
                           ,p_ownership          =>p_ownership
                           ,p_usage_type         =>p_usage_type
                           ,p_vehicle_type       =>p_vehicle_type
                           ,p_fuel_type          =>p_fuel_type
                           ,p_sl_rates_type      =>l_sliding_rates
                           ,p_rates              =>l_get_rate_id
                           ,p_element_id         =>l_get_element_type_id
                          );

       l_element_type_id :=to_number(l_get_element_type_id);
    ELSE
       l_element_type_id :=NVL(l_get_purp_element_id,l_get_asg_element_id);
    END IF;
  ELSE
     l_element_type_id :=to_number(p_mileage_claim_element);
  END IF;


 hr_utility.set_location(' Enter db level element search:' || l_proc,90);
  --If no element is entered in all levels then
  --it must be searched in the database and validated.
   IF l_element_type_id IS NULL THEN
      l_elig_mileage_element_id:=get_elig_mileage_element
                                  (p_assignment_id     => p_assignment_id
                                  ,p_business_group_id =>p_business_group_id
                                  ,p_effective_date    =>l_effective_date
                                  ,p_vehicle_type      =>p_vehicle_type
                                  ,p_ownership         =>p_ownership
                                  ,p_sl_rate_type      =>l_sliding_rates
                                   ,p_element_link_id   =>l_element_link_id
                                );
    IF l_elig_mileage_element_id <> -1 THEN
     l_element_type_id :=l_elig_mileage_element_id;
    END IF;
   ELSE
       l_valid_mileage_element_id:=validate_mileage_element
                                   (p_assignment_id     => p_assignment_id
                                   ,p_business_group_id =>p_business_group_id
                                   ,p_effective_date    =>p_effective_date
                                   ,p_vehicle_type      =>p_vehicle_type
                                   ,p_ownership         =>p_ownership
                                   ,p_element_type_id   =>to_number(l_element_type_id)
                                   ,p_sl_rate_type      =>l_sliding_rates
                                   ,p_element_link_id   =>l_element_link_id
                                  );
    IF l_valid_mileage_element_id IS NULL OR l_valid_mileage_element_id=-1 THEN

      l_elig_mileage_element_id:=get_elig_mileage_element
                                  (p_assignment_id     => p_assignment_id
                                  ,p_business_group_id =>p_business_group_id
                                  ,p_effective_date    =>l_effective_date
                                  ,p_vehicle_type      =>p_vehicle_type
                                  ,p_ownership         =>p_ownership
                                  ,p_sl_rate_type      =>l_sliding_rates
                                   ,p_element_link_id   =>l_element_link_id
                                );
     IF l_elig_mileage_element_id <> -1 THEN
      l_element_type_id :=l_elig_mileage_element_id;

     END IF;
    ELSE
      l_element_type_id :=l_valid_mileage_element_id;
    END IF;
 END IF;

 IF l_element_type_id IS NULL THEN
  fnd_message.set_name('PQP','PQP_230732_VLD_MLG_ELE_FAIL');
  fnd_message.raise_error;
  hr_multi_message.end_validation_set;
 END IF;

 hr_utility.set_location(' Enter element link search:' || l_proc,110);
/*  OPEN c_get_ele_link (l_element_type_id
                       ,l_effective_date
                       ,p_business_group_id
                       );
   LOOP
    FETCH c_get_ele_link INTO l_get_ele_link;
    EXIT WHEN c_get_ele_link%NOTFOUND;
    l_element_link_id:=l_get_ele_link.element_link_id;
   END LOOP;
  CLOSE c_get_ele_link;*/

 hr_utility.set_location(' Enter Assignment level rates search:' || l_proc,70);
  --If Rates is Null ,then fetch from assignment level
  IF p_user_rates_table IS NULL THEN
   IF  p_user_type='SS' OR ( p_user_type='PUI' AND  l_user_type='Y') THEN
 hr_utility.set_location(' Enter Assignment If condition:' || l_proc,80);
    l_rates_table_id:=l_purp_rates_table;
   END IF;
    IF l_rates_table_id IS NULL THEN
 hr_utility.set_location(' Enter Assignment Second If condition:' || l_proc,80);
     l_get_asg_rate_id:= get_asg_element
                        (p_assignment_id       =>p_assignment_id
                        ,p_business_group_id   =>p_business_group_id
                        ,p_effective_date      =>p_effective_date
                        ,p_ownership_type      =>p_ownership
                        ,p_registration_number =>p_registration_number
                        ,p_usage_type          =>p_usage_type
                        ,p_check_type          =>'R'
                        ,p_sl_rates_type       =>l_sliding_rates
                         );
    END IF;
     --if rates table is not present at assignment level
     --then fetch from conf table
 hr_utility.set_location(' Enter conf level rates search:' || l_proc,80);
     IF  (l_get_asg_rate_id IS NULL OR l_get_asg_rate_id=-1 ) AND
      l_rates_table_id IS NULL THEN
      l_get_element_type_id := l_element_type_id;
      pqp_gb_mileage_claim_pkg.get_config_info (
                            p_business_group_id  =>p_business_group_id
                           ,p_ownership          =>p_ownership
                           ,p_usage_type         =>p_usage_type
                           ,p_vehicle_type       =>p_vehicle_type
                           ,p_fuel_type          =>p_fuel_type
                           ,p_sl_rates_type       =>l_sliding_rates
                           ,p_rates              =>l_get_rate_id
                           ,p_element_id         =>l_get_element_type_id
                          );

      l_rates_table_id :=to_number(l_get_rate_id);
      l_get_asg_rate_id:=to_number(l_get_rate_id);
      IF l_get_asg_rate_id IS NULL OR l_get_asg_rate_id=-1 THEN
       l_get_asg_rate_id := get_default_value
                          (p_business_group_id =>p_business_group_id
                          ,p_element_type_id   =>l_element_type_id
                          ,p_effective_date    =>p_effective_date
                          ,p_search_type       =>'User Rates Table'
                          );

       --l_rates_table_id :=to_number(l_get_rate_id);
       l_rates_table_id :=to_number(l_get_asg_rate_id);
      ELSE
       l_rates_table_id :=l_get_asg_rate_id;
      END IF;
     ELSE
      l_rates_table_id :=NVL(l_get_asg_rate_id,l_rates_table_id);
    END IF;
   ELSE
    l_rates_table_id :=(p_user_rates_table);
  END IF;


  hr_utility.set_location(' Enter mndtry field chk:' || l_proc,120);
  --All mandatory field validations
  l_chk_mndtry:= chk_mndtry_fields (
                            p_effective_date       =>p_effective_date
                           ,p_assignment_id        =>p_assignment_id
                           ,p_business_group_id    =>p_business_group_id
                           ,p_ownership            =>p_ownership
                           ,p_usage_type           =>p_usage_type
                           ,p_vehicle_type         =>p_vehicle_type
                           ,p_start_date           =>p_start_date
                           ,p_end_date             =>p_end_date
                           ,p_claimed_mileage      =>p_claimed_mileage
                           ,p_actual_mileage       =>p_actual_mileage
                           ,p_registration_number  =>p_registration_number
                           ,p_engine_capacity      =>l_engine_capacity
                           ,p_fuel_type            =>p_fuel_type
                           ,p_element_type_id      =>l_element_type_id
                           ,p_data_source          =>p_data_source
                           ,p_message              =>l_message
                          );


  IF l_chk_mndtry = 'N' THEN
     fnd_message.raise_error;
     hr_multi_message.end_validation_set;
   END IF;

 --Input values are vary from Private to Company vehicles
 --So inserting the values besed on ownership
 IF p_ownership='C' THEN
  hr_utility.set_location(' Enter company mileage:' || l_proc,130);
  insert_company_mileage_claim
        ( p_effective_date        =>l_effective_date
         ,p_assignment_id         =>p_assignment_id
         ,p_business_group_id     =>p_business_group_id
         ,p_ownership             =>p_ownership
         ,p_usage_type            =>p_usage_type
         ,p_vehicle_type          =>p_vehicle_type
         ,p_start_date            =>p_start_date
         ,p_end_date              =>p_end_date
         ,p_claimed_mileage       =>p_claimed_mileage
         ,p_actual_mileage        =>p_actual_mileage
         ,p_registration_number   =>p_registration_number
         ,p_engine_capacity       =>l_engine_capacity
         ,p_fuel_type             =>p_fuel_type
         ,p_calculation_method    =>p_calculation_method
         ,p_user_rates_table      =>l_rates_table_id --p_user_rates_table
         ,p_fiscal_ratings        =>p_fiscal_ratings
         ,p_PAYE_taxable          =>l_PAYE_taxable
         ,p_no_of_passengers      =>p_no_of_passengers
         ,p_purpose               =>p_purpose
         ,p_payroll_id            =>l_get_pay_det
         ,p_mileage_claim_element =>l_element_type_id
         ,p_element_entry_id      =>p_element_entry_id
         ,p_element_entry_date    =>p_element_entry_date
         ,p_element_link_id       =>l_element_link_id
       );

  ELSIF p_ownership='P' THEN
  hr_utility.set_location(' Enter private mileage:' || l_proc,140);
   insert_private_mileage_claim
        ( p_effective_date        =>l_effective_date
         ,p_assignment_id         =>p_assignment_id
         ,p_business_group_id     =>p_business_group_id
         ,p_ownership             =>p_ownership
         ,p_usage_type            =>p_usage_type
         ,p_vehicle_type          =>p_vehicle_type
         ,p_start_date            =>p_start_date
         ,p_end_date              =>p_end_date
         ,p_claimed_mileage       =>p_claimed_mileage
         ,p_actual_mileage        =>p_actual_mileage
         ,p_registration_number   =>p_registration_number
         ,p_engine_capacity       =>l_engine_capacity
         ,p_fuel_type             =>p_fuel_type
         ,p_calculation_method    =>p_calculation_method
         ,p_user_rates_table      =>l_rates_table_id --p_user_rates_table
         ,p_fiscal_ratings        =>p_fiscal_ratings
         ,p_PAYE_taxable          =>l_PAYE_taxable
         ,p_no_of_passengers      =>p_no_of_passengers
         ,p_purpose               =>p_purpose
         ,p_payroll_id            =>l_get_pay_det
         ,p_mileage_claim_element =>l_element_type_id
         ,p_element_entry_id      =>p_element_entry_id
         ,p_element_entry_date    =>p_element_entry_date
         ,p_element_link_id       =>l_element_link_id
         );
  END IF;
--This call is for webADI related stuff
ELSIF p_info_id IS NOT NULL THEN
  hr_utility.set_location(' Enter WEBADI:' || l_proc,150);
   l_assignment_id     := substr(p_info_id,1,instr(p_info_id,l_string)-1);
--   l_businesss_group_id:=substr(p_info_id,instr(p_info_id,l_string)+LENGTH(l_string),
 --                      instr(p_info_id,l_string,1,2)-instr(p_info_id,l_string)-LENGTH(l_string));
--   l_session_id :=substr(p_info_id,instr(p_info_id,l_string,1,2)+LENGTH(l_string)) ;
 /*This is changed now as the url contains -1,-1 for both values below
   now these values are derived from the profile value*/
   l_businesss_group_id:= fnd_profile.value('PER_BUSINESS_GROUP_ID');
   l_session_id := fnd_profile.value('USER_ID');


    l_st_dt           :=FND_DATE.CHARDATE_TO_DATE(p_start_date);
    l_ed_dt           :=FND_DATE.CHARDATE_TO_DATE(p_end_date);
    l_canonical_st_dt  :=fnd_date.date_to_canonical(l_st_dt);
    l_canonical_ed_dt  :=fnd_date.date_to_canonical(l_ed_dt);
  --  l_canonical_st_dt  :=fnd_date.date_to_displaydt(p_start_date);
  --  l_canonical_ed_dt  :=fnd_date.date_to_displaydt(p_end_date);

      INSERT INTO pay_us_rpt_totals
         (gre_name  , -- Stores session id
          state_name,  -- Stores timestamp
          state_abbrev, -- Stores info that tells
                        --the date is for Web ADI. A string ADI
          attribute1,  --  Stores Reg #
          attribute2,  --  Stores Claimed Mileage
          attribute3,  --  Stores Vehicle Type
          attribute4,  --  Stores start Date
          attribute5,   --   Stores end date
          attribute6,   --   Stores actual mileage
          attribute7,   --   Stores usage type
          attribute8 ,  --   Stores ownership
	  bUsiness_group_id ,
	  location_id   --Stores assignmentId
         )
        VALUES
         (
          l_session_id                 ,
          p_time_stamp                 ,
          'ADI'                        ,
          p_registration_number        ,
          p_claimed_mileage            ,
          p_vehicle_type               ,
          l_canonical_st_dt            ,
          l_canonical_ed_dt            ,
          p_actual_mileage             ,
          p_usage_type                 ,
          p_ownership                  ,
	  l_businesss_group_id         ,
          l_assignment_id
          );
END IF;
END;


 -------------------------------------------------------------------------
 ------------ --Procedure for deleteting the claim import ----------------
 --------------------------------------------------------------------------
 --Used to delete the imported claims from UI
PROCEDURE delete_claim_import
                 ( p_info_id        IN  VARCHAR2
                  ,p_assignment_id     IN  NUMBER
		  ,p_business_group_id IN  NUMBER
		  ,p_effective_date    IN  DATE
                  ,p_return_status     OUT NOCOPY VARCHAR2
                 )  AS
l_proc    varchar2(72) := g_package ||'delete_claim_import';
BEGIN
  hr_utility.set_location(' Enter delete claim import:' || l_proc,160);
    DELETE
      FROM  pay_us_rpt_totals
     WHERE  GRE_NAME = p_info_id
      AND   business_group_id = p_business_group_id
      AND   location_id = p_assignment_id
      AND   STATE_ABBREV ='ADI';
 --Deleting all rows which are older than a day
   DELETE
     FROM  pay_us_rpt_totals
    WHERE  STATE_ABBREV ='ADI'
      AND  (p_effective_date-fnd_date.canonical_to_date(state_name))>1;

      COMMIT;
      p_return_status := 'S';
  hr_utility.set_location('Leaving delete mileage:' || l_proc,170);
exception
when others then
     p_return_status := 'E';
END;

 --------------------------------------------------------------------------
--Call for updating the mileage claim
PROCEDURE update_mileage_claim
         (
          p_effective_date             IN DATE,
          p_assignment_id              IN NUMBER,
          p_business_group_id          IN NUMBER,
          p_ownership                  IN VARCHAR2  ,
          p_usage_type                 IN VARCHAR2  ,
          p_vehicle_type               IN VARCHAR2,
          p_start_date_o               IN VARCHAR2  ,
          p_start_date                 IN VARCHAR2  ,
          p_end_date_o                 IN VARCHAR2  ,
          p_end_date                   IN VARCHAR2  ,
          p_claimed_mileage_o          IN  VARCHAR2  ,
          p_claimed_mileage            IN VARCHAR2  ,
          p_actual_mileage_o           IN  VARCHAR2  ,
          p_actual_mileage             IN VARCHAR2  ,
          p_registration_number        IN VARCHAR2  ,
          p_engine_capacity            IN VARCHAR2  ,
          p_fuel_type                  IN VARCHAR2  ,
          p_calculation_method         IN VARCHAR2  ,
          p_user_rates_table           IN VARCHAR2  ,
          p_fiscal_ratings_o           IN VARCHAR2  ,
          p_fiscal_ratings             IN VARCHAR2  ,
          p_PAYE_taxable               IN VARCHAR2  ,
          p_no_of_passengers_o         IN VARCHAR2  ,
          p_no_of_passengers           IN VARCHAR2  ,
          p_purpose                    IN VARCHAR2 ,
          p_data_source                IN VARCHAR2  ,
          p_mileage_claim_element      IN OUT NOCOPY NUMBER  ,
          p_element_entry_id           IN OUT NOCOPY NUMBER  ,
          p_element_entry_date         IN OUT NOCOPY DATE
         ) IS

CURSOR c_get_input_value
IS
SELECT DISTINCT piv.input_value_id
       ,piv.name
       ,piv.lookup_type
       ,piv.default_value
  FROM pay_input_values_f piv
 WHERE piv.name IN ('Claimed Mileage'
                    ,'Actual Mileage'
                    ,'Claim Start Date'
                    ,'Claim End Date'
                    ,'No of Passengers'
                    ,'CO2 Emissions'
                    ,'User Rates Table'
                    ,'Vehicle Type'
                    ,'Rate Type'
                    ,'PAYE Taxable'
                    ,'Calculation Method'
                    ,'Purpose'
                    )
   AND piv.element_type_id=p_mileage_claim_element
   AND piv.business_group_id=p_business_group_id
   AND p_effective_date BETWEEN piv.effective_start_date
                             AND piv.effective_end_date;

CURSOR c_get_table_name ( cp_user_rates_table  VARCHAR2
                         ,cp_business_group_id NUMBER
                         )
IS
SELECT put.user_table_name
  FROM pay_user_tables put
 WHERE user_table_id =cp_user_rates_table
   AND put.business_group_id=cp_business_group_id;


CURSOR c_get_end_date
IS
SELECT MAX(pee.effective_end_date) effective_end_date
  FROM pay_element_entries_f pee
 WHERE pee.element_entry_id=p_element_entry_id
  AND pee.assignment_id=p_assignment_id;

l_get_table_name             c_get_table_name%ROWTYPE;
l_delete_mode                VARCHAR2(30) :='FUTURE_CHANGE';
l_update_mode                VARCHAR2(30) :='CORRECTION';
l_input_value_id_tbl         hr_entry.number_table;
l_entry_value_tbl            hr_entry.varchar2_table;
l_num_entry_values           NUMBER;
l_get_input_value            c_get_input_value%ROWTYPE;
l_get_end_date               c_get_end_date%ROWTYPE;
l_proc    varchar2(72) := g_package ||'update_mileage_claim';
BEGIN

  hr_utility.set_location('Enter update Claim:' || l_proc,10);
OPEN c_get_end_date;
 LOOP
  FETCH c_get_end_date INTO l_get_end_date;
  EXIT WHEN c_get_end_date%NOTFOUND;

 END LOOP;
CLOSE c_get_end_date;
  hr_utility.set_location(l_proc,20);
OPEN c_get_input_value;
 LOOP
  FETCH c_get_input_value INTO l_get_input_value;
  EXIT WHEN c_get_input_value%NOTFOUND;
  hr_utility.set_location('Enter set input values:' || l_proc,30);
   IF l_get_input_value.name='Vehicle Type'OR
              l_get_input_value.name='Rate Type' THEN
    l_input_value_id_tbl(l_input_value_id_tbl.count +1)
                    :=l_get_input_value.input_value_id;
    l_entry_value_tbl(l_entry_value_tbl.count+1)
                     :=get_lkp_meaning(p_usage_type
                   ,l_get_input_value.lookup_type);
   ELSIF l_get_input_value.name='Claimed Mileage' THEN
   hr_utility.set_location(l_proc,40);
    l_input_value_id_tbl(l_input_value_id_tbl.count +1)
                    :=l_get_input_value.input_value_id;
    l_entry_value_tbl(l_entry_value_tbl.count+1)
                    :=p_claimed_mileage;
   ELSIF l_get_input_value.name='Actual Mileage' THEN
   hr_utility.set_location(l_proc,50);
    l_input_value_id_tbl(l_input_value_id_tbl.count +1)
                    :=l_get_input_value.input_value_id;

    l_entry_value_tbl(l_entry_value_tbl.count+1)
                    :=p_actual_mileage;
   ELSIF l_get_input_value.name='Claim Start Date' THEN
   hr_utility.set_location(l_proc,60);
    l_input_value_id_tbl(l_input_value_id_tbl.count +1)
                    :=l_get_input_value.input_value_id;

    l_entry_value_tbl(l_entry_value_tbl.count+1)
                    :=p_start_date;
   ELSIF l_get_input_value.name='Claim End Date' THEN
   hr_utility.set_location(l_proc,70);
    l_input_value_id_tbl(l_input_value_id_tbl.count +1)
                    :=l_get_input_value.input_value_id;

    l_entry_value_tbl(l_entry_value_tbl.count+1)
                    :=p_end_date;
   ELSIF l_get_input_value.name='User Rates Table' THEN
   hr_utility.set_location(l_proc,80);
    l_input_value_id_tbl(l_input_value_id_tbl.count +1)
                    :=l_get_input_value.input_value_id;



    OPEN c_get_table_name (p_user_rates_table
                          ,p_business_group_id
                           );
    FETCH c_get_table_name INTO l_get_table_name;

    CLOSE c_get_table_name;

    IF l_get_table_name.user_table_name IS NULL THEN

    hr_utility.set_location(l_proc,90);
      l_entry_value_tbl(l_entry_value_tbl.count+1)
                    :=l_get_input_value.default_value;
    ELSE

    hr_utility.set_location(l_proc,100);
      l_entry_value_tbl(l_entry_value_tbl.count+1)
                    :=l_get_table_name.user_table_name;

    END IF;
   ELSIF l_get_input_value.name='No of Passengers' THEN
    hr_utility.set_location(l_proc,110);
    l_input_value_id_tbl(l_input_value_id_tbl.count +1)
                    :=l_get_input_value.input_value_id;

    l_entry_value_tbl(l_entry_value_tbl.count+1)
                    :=p_no_of_passengers;
   ELSIF l_get_input_value.name='CO2 Emissions' THEN
    hr_utility.set_location(l_proc,120);
    l_input_value_id_tbl(l_input_value_id_tbl.count +1)
                    :=l_get_input_value.input_value_id;

    l_entry_value_tbl(l_entry_value_tbl.count+1)
                    :=p_fiscal_ratings;
   ELSIF l_get_input_value.name='Calculation Method' THEN
    hr_utility.set_location(l_proc,130);
    l_input_value_id_tbl(l_input_value_id_tbl.count +1)
                    :=l_get_input_value.input_value_id;

    /*IF p_calculation_method IS  NULL THEN
    l_entry_value_tbl(l_entry_value_tbl.count+1)
                    :=p_calculation_method;
    ELSE
     l_entry_value_tbl(l_entry_value_tbl.count+1)
                    :=get_lkp_meaning(p_calculation_method
                   ,l_get_input_value.lookup_type);

    END IF;*/
    IF l_get_input_value.lookup_type IS NOT NULL THEN
    l_entry_value_tbl(l_entry_value_tbl.count+1)
                    :=get_lkp_meaning(NVL(p_calculation_method
                           ,l_get_input_value.default_value)
                           ,l_get_input_value.lookup_type);
    ELSE
    l_entry_value_tbl(l_entry_value_tbl.count+1)
                    :=NVL(p_calculation_method,
                          l_get_input_value.default_value);
    END IF;
   ELSIF l_get_input_value.name='PAYE Taxable' THEN
    hr_utility.set_location(l_proc,140);
    l_input_value_id_tbl(l_input_value_id_tbl.count +1)
                    :=l_get_input_value.input_value_id;

    IF l_get_input_value.lookup_type IS NOT NULL THEN
     l_entry_value_tbl(l_entry_value_tbl.count+1)
                     :=get_lkp_meaning(p_PAYE_Taxable
                   ,l_get_input_value.lookup_type);
    ELSE
     l_entry_value_tbl(l_entry_value_tbl.count+1):= p_PAYE_Taxable;
    END IF;

   ELSIF l_get_input_value.name='Purpose' THEN
   hr_utility.set_location(l_proc,70);
    l_input_value_id_tbl(l_input_value_id_tbl.count +1)
                    :=l_get_input_value.input_value_id;

    l_entry_value_tbl(l_entry_value_tbl.count+1)
                    :=p_purpose;

   END IF;

  l_num_entry_values :=l_input_value_id_tbl.count;

 END LOOP;
CLOSE c_get_input_value;

IF l_get_end_date.effective_end_date <> hr_api.g_eot
                                         THEN
    hr_utility.set_location(l_proc,150);
 IF p_claimed_mileage_o <> p_claimed_mileage OR
    p_actual_mileage_o <> p_actual_mileage THEN
    hr_utility.set_location(l_proc,160);
  hr_utility.set_location('Enter delete api:' || l_proc,200);
  hr_entry_api.delete_element_entry
  (
   p_dt_delete_mode             =>l_delete_mode,
   p_session_date               =>p_effective_date,
   p_element_entry_id           =>p_element_entry_id
   );
  END IF;

END IF;

    hr_utility.set_location(l_proc,170);
  hr_utility.set_location('Enter correction:' || l_proc,210);
hr_entry_api.update_element_entry
 (
  p_dt_update_mode             =>l_update_mode,
  p_session_date               =>p_effective_date,
  p_element_entry_id           =>p_element_entry_id,
  p_num_entry_values           =>l_num_entry_values,
  p_input_value_id_tbl         =>l_input_value_id_tbl,
  p_entry_value_tbl            =>l_entry_value_tbl
 );

exception
--------
When others then
    hr_utility.set_location(l_proc,180);
 fnd_message.raise_error;
 hr_multi_message.end_validation_set;

END;

--Call for deleting the mileage claim
PROCEDURE delete_mileage_claim
        ( p_effective_date             IN DATE,
          p_assignment_id              IN NUMBER,
          p_mileage_claim_element      IN NUMBER ,
          p_element_entry_id           IN NUMBER  ,
          p_element_entry_date         IN DATE
     ) IS

CURSOR c_get_end_date(cp_element_entry_id NUMBER
                     ,cp_assignment_id  NUMBER)
IS
SELECT MAX(pee.effective_end_date) effective_end_date
  FROM pay_element_entries_f pee
 WHERE pee.element_entry_id=cp_element_entry_id
   AND pee.assignment_id  =cp_assignment_id;

CURSOR c_get_process_status (cp_assignment_id NUMBER
                             ,cp_element_type_id NUMBER
                             ,cp_element_entry_id NUMBER
                             )
IS
SELECT prr.assignment_action_id
  FROM pay_run_results prr
 WHERE
   --prr.assignment_id =cp_assignment_id
   --AND
    prr.element_type_id=cp_element_type_id
   AND prr.source_id=cp_element_entry_id;

l_get_end_date c_get_end_date%ROWTYPE;
l_get_process_status c_get_process_status%ROWTYPE;

l_proc    varchar2(72) := g_package ||'delete_mileage_claim';
BEGIN

hr_utility.set_location(l_proc,10);
OPEN c_get_end_date (p_element_entry_id
                     ,p_assignment_id
                     );
 LOOP
  FETCH c_get_end_date INTO l_get_end_date;
  EXIT WHEN c_get_end_date%NOTFOUND;
  hr_utility.set_location(l_proc,20);
  IF l_get_end_date.effective_end_date =hr_api.g_eot THEN

    OPEN c_get_process_status ( p_assignment_id
                               ,p_mileage_claim_element
                               ,p_element_entry_id
                               );
     LOOP
      FETCH c_get_process_status INTO l_get_process_status;
      EXIT WHEN c_get_process_status%NOTFOUND;
     END LOOP;
    CLOSE c_get_process_status;

    IF l_get_process_status.assignment_action_id IS  NULL THEN

    hr_utility.set_location(l_proc,30);
     hr_entry_api.delete_element_entry
      (
       p_dt_delete_mode             =>'ZAP'
       ,p_session_date               =>p_effective_date
       ,p_element_entry_id           =>p_element_entry_id
      );
    ELSE
    hr_utility.set_location(l_proc,40);
     fnd_message.set_name('PQP','PQP_230718_CLM_PROC_DEL');
     fnd_message.raise_error;
      hr_multi_message.end_validation_set;
    END IF;

  ELSE

     hr_utility.set_location(l_proc,50);
     fnd_message.set_name('PQP','PQP_230718_CLM_PROC_DEL');
     fnd_message.raise_error;
      hr_multi_message.end_validation_set;
  END IF;
 END LOOP;
exception
--------
When others then
 hr_utility.set_location(l_proc,60);
 fnd_message.raise_error;
 hr_multi_message.end_validation_set;
END;

--get element or rates from configuration
PROCEDURE get_config_info ( p_business_group_id   IN  NUMBER
                           ,p_ownership           IN  VARCHAR2
                           ,p_usage_type          IN  VARCHAR2
                           ,p_vehicle_type        IN  VARCHAR2
                           ,p_fuel_type           IN  VARCHAR2
                           ,p_sl_rates_type       IN  VARCHAR2
                           ,p_rates               OUT NOCOPY NUMBER
                           ,p_element_id          IN OUT NOCOPY NUMBER
                          )
IS
CURSOR c_get_config_rates_info
IS
SELECT  pcv.pcv_information_category
       ,pcv.pcv_information1 Ownership
       ,pcv.pcv_information2 Usage_type
       ,pcv.pcv_information3 Vehicle_type
       ,pcv.pcv_information4 Fuel_type
       ,pcv.pcv_information5 rates_type
  FROM pqp_configuration_values pcv
 WHERE business_group_id=p_business_group_id
   AND pcv.pcv_information_category='GB_VEHICLE_CALC_INFO'
   AND pcv_information1=p_ownership
   AND (pcv_information2=p_usage_type
        OR pcv_information2 IS NULL)
   AND (pcv_information3=p_vehicle_type
         OR pcv_information3 IS NULL)
   AND (pcv_information4=p_fuel_type
         OR pcv_information4 IS NULL)
   AND (pcv_information6=p_element_id
         OR pcv_information6 IS NULL)
   AND pcv.pcv_information5 IS NOT NULL
   ORDER BY 1,2,3,4;

CURSOR c_get_config_element_info
IS
SELECT  pcv.pcv_information_category
       ,pcv.pcv_information1 Ownership
       ,pcv.pcv_information2 Usage_type
       ,pcv.pcv_information3 Vehicle_type
       ,pcv.pcv_information4 Fuel_type
       ,pcv.pcv_information6 element_id
  FROM pqp_configuration_values pcv
 WHERE business_group_id=p_business_group_id
   AND pcv.pcv_information_category='GB_VEHICLE_CALC_INFO'
   AND pcv_information1=p_ownership
   AND (pcv_information2=p_usage_type
        OR pcv_information2 IS NULL)
   AND (pcv_information3=p_vehicle_type
         OR pcv_information3 IS NULL)
   AND (pcv_information4=p_fuel_type
         OR pcv_information4 IS NULL)
   AND pcv.pcv_information6 IS NOT NULL
   ORDER BY 1,2,3,4;

CURSOR  c_ele_type (cp_element_type_id   NUMBER)
 IS
 SELECT NVL(pete.eei_information2 ,'N') ele_type
  FROM  pay_element_type_extra_info pete
 WHERE  pete.information_type='PQP_VEHICLE_MILEAGE_INFO'
   AND  pete.element_type_id= cp_element_type_id;

l_ele_type              c_ele_type%ROWTYPE;
l_get_config_rates_info c_get_config_rates_info%ROWTYPE;
l_get_config_element_info c_get_config_element_info%ROWTYPE;
wrong_table              EXCEPTION;
BEGIN

 OPEN c_get_config_rates_info;
  FETCH c_get_config_rates_info INTO l_get_config_rates_info;
 CLOSE c_get_config_rates_info;

 IF p_sl_rates_type='Y' THEN
  BEGIN
   p_rates :=to_number(l_get_config_rates_info.rates_type) ;
   RAISE wrong_table;

  EXCEPTION
  ---------
   WHEN wrong_table THEN
    p_rates:=NULL;
   WHEN OTHERS THEN
    p_rates :=l_get_config_rates_info.rates_type;
   END;
  ELSE
   BEGIN
    p_rates :=to_number(l_get_config_rates_info.rates_type) ;

   EXCEPTION
   ---------
    WHEN OTHERS THEN
     p_rates :=NULL;
   END;
  END IF;

 OPEN c_get_config_element_info;
  FETCH c_get_config_element_info INTO l_get_config_element_info;

  OPEN c_ele_type (l_get_config_element_info.element_id);
   FETCH c_ele_type INTO l_ele_type;
  CLOSE c_ele_type;
  IF p_sl_rates_type=l_ele_type.ele_type THEN
   p_element_id :=l_get_config_element_info.element_id;
  ELSE
   p_element_id :=NULL;
  END IF;
 CLOSE c_get_config_element_info;

END;
--chk if vehicle is active during the claim period
FUNCTION chk_vehicle_active ( p_ownership           IN VARCHAR2
                             ,p_usage_type          IN VARCHAR2
                             ,p_assignment_id       IN NUMBER
                             ,p_business_group_id   IN NUMBER
                             ,p_start_date          IN VARCHAR2
                             ,p_end_date            IN VARCHAR2
                             ,p_registration_number IN VARCHAR2
                             ,p_message             OUT NOCOPY VARCHAR2
                            )
RETURN NUMBER
IS

CURSOR c_get_reg_num
IS
SELECT pvr.registration_number
      ,pva.default_vehicle
  FROM pqp_vehicle_repository_f pvr
       ,pqp_vehicle_allocations_f pva
 WHERE pva.vehicle_repository_id=pvr.vehicle_repository_id
   AND pvr.vehicle_ownership=p_ownership
   AND pva.usage_type=p_usage_type
   AND pva.assignment_id=p_assignment_id
   AND pva.business_group_id=p_business_group_id
   AND pva.business_group_id=pvr.business_group_id
   AND p_start_date BETWEEN pva.effective_start_date
                        AND pva.effective_end_date
   AND p_start_date BETWEEN pvr.effective_start_date
                        AND pvr.effective_end_date ;

CURSOR c_chk_active (cp_registration_number VARCHAR2)
IS
SELECT pvr.vehicle_status,'Start_Date' clm_date
  FROM pqp_vehicle_repository_f pvr
WHERE  pvr.registration_number=cp_registration_number
  AND  pvr.vehicle_status='I'
  AND  p_start_date BETWEEN pvr.effective_start_date
                        AND pvr.effective_end_date
UNION
SELECT pvr.vehicle_status,'End_Date' clm_date
  FROM pqp_vehicle_repository_f pvr
WHERE  pvr.registration_number=cp_registration_number
  AND  pvr.vehicle_status='I'
  AND  p_end_date BETWEEN pvr.effective_start_date
                        AND pvr.effective_end_date;

CURSOR c_chk_alloc (cp_registration_number VARCHAR2)
IS
SELECT 'Start_Valid' valid_date
  FROM pqp_vehicle_allocations_f pva
      ,per_all_assignments_f paa
      ,pqp_vehicle_repository_f pvr
 WHERE pva.assignment_id=p_assignment_id
   AND pvr.registration_number=cp_registration_number
   AND pvr.vehicle_repository_id=pva.vehicle_repository_id
   AND pva.business_group_id=p_business_group_id
   AND pva.assignment_id =paa.assignment_id
   AND pva.business_group_id=paa.business_group_id
   AND pva.business_group_id=pvr.business_group_id
   AND p_start_date BETWEEN pva.effective_start_date
                         AND pva.effective_end_date
   AND p_start_date BETWEEN paa.effective_start_date
                         AND paa.effective_end_date
   AND p_start_date BETWEEN pvr.effective_start_date
                         AND pvr.effective_end_date
UNION
SELECT 'End_Valid' valid_date
  FROM pqp_vehicle_allocations_f pva
      ,per_all_assignments_f paa
      ,pqp_vehicle_repository_f pvr
 WHERE pva.assignment_id=p_assignment_id
   AND pvr.registration_number=cp_registration_number
   AND pvr.vehicle_repository_id=pva.vehicle_repository_id
   AND pva.business_group_id=p_business_group_id
   AND pva.assignment_id =paa.assignment_id
   AND pva.business_group_id=paa.business_group_id
   AND pva.business_group_id=pvr.business_group_id
   AND p_end_date BETWEEN pva.effective_start_date
                         AND pva.effective_end_date
   AND p_end_date BETWEEN paa.effective_start_date
                         AND paa.effective_end_date
   AND p_end_date BETWEEN pvr.effective_start_date
                         AND pvr.effective_end_date;



l_get_reg_num  c_get_reg_num%ROWTYPE;
l_chk_alloc    c_chk_alloc%ROWTYPE;
l_chk_active   c_chk_active%ROWTYPE;
l_st_date      VARCHAR2(10);
l_end_date      VARCHAR2(10);
BEGIN
 IF p_registration_number IS NULL THEN
  OPEN c_get_reg_num;
   LOOP
    FETCH c_get_reg_num INTO l_get_reg_num;
    EXIT WHEN c_get_reg_num%NOTFOUND;
   END LOOP;
  CLOSE c_get_reg_num;

 END IF;
 OPEN  c_chk_active (NVL(p_registration_number,
                         l_get_reg_num.registration_number));
  LOOP
   FETCH c_chk_active INTO l_chk_active;
   EXIT WHEN c_chk_active%NOTFOUND;
   IF l_chk_active.clm_date='Start_Date' THEN
    l_st_date:=l_chk_active.clm_date;
   ELSIF l_chk_active.clm_date='End_Date' THEN

    l_end_date:=l_chk_active.clm_date;

   END IF;

  END LOOP;
 CLOSE c_chk_active;
 IF l_st_date IS NOT NULL AND
    l_end_date IS NOT NULL THEN

  fnd_message.raise_error;

 ELSIF l_st_date IS NOT NULL AND
     l_end_date IS  NULL THEN

  fnd_message.raise_error;
 ELSIF l_st_date IS NULL AND
     l_end_date IS NOT NULL THEN

  fnd_message.raise_error;

 END IF;

END;

--Check for Mandatory columns
FUNCTION chk_mndtry_fields (  p_effective_date      IN  DATE
                           ,p_assignment_id         IN  NUMBER
                           ,p_business_group_id     IN  NUMBER
                           ,p_ownership             IN  VARCHAR2
                           ,p_usage_type            IN  VARCHAR2
                           ,p_vehicle_type          IN  VARCHAR2
                           ,p_start_date            IN  VARCHAR2
                           ,p_end_date              IN  VARCHAR2
                           ,p_claimed_mileage       IN  VARCHAR2
                           ,p_actual_mileage        IN  VARCHAR2
                           ,p_registration_number   IN  VARCHAR2
                           ,p_engine_capacity       IN  VARCHAR2
                           ,p_fuel_type             IN  VARCHAR2
                           ,p_element_type_id       IN  NUMBER
                           ,p_data_source           IN  VARCHAR2
                           ,p_message               OUT NOCOPY VARCHAR2
                          )

RETURN VARCHAR2
AS
 CURSOR c_get_veh_det
 IS
 SELECT pvr.vehicle_type
       ,pvr.vehicle_ownership
       ,pvr.fiscal_ratings
       ,pvr.engine_capacity_in_cc
       ,pvr.fuel_type
 FROM  pqp_vehicle_repository_f pvr
WHERE  pvr.registration_number = p_registration_number
  AND  pvr.business_group_id   = p_business_group_id
  AND  p_effective_date BETWEEN pvr.effective_start_date
                        AND pvr.effective_end_date;

 CURSOR c_validate_comp_veh
 IS
 SELECT pvr.vehicle_type
       ,pvr.vehicle_ownership
       ,pvr.fiscal_ratings
       ,pvr.engine_capacity_in_cc
       ,pvr.fuel_type
 FROM  pqp_vehicle_repository_f pvr
       ,pqp_vehicle_allocations_f pva
WHERE  (pvr.registration_number =p_registration_number
         OR p_registration_number IS NULL)
  AND  pva.assignment_id= p_assignment_id
  AND  pvr.business_group_id   = p_business_group_id
  AND pvr.vehicle_repository_id=pva.vehicle_repository_id
  AND pvr.business_group_id=pva.business_group_id
  AND  FND_DATE.CHARDATE_TO_DATE(p_start_date) BETWEEN pvr.effective_start_date
                        AND pvr.effective_end_date
  AND  pva.usage_type IN ('P','S');

l_validate_comp_veh     c_validate_comp_veh%ROWTYPE;
l_get_veh_det c_get_veh_det%ROWTYPE;
l_retvalue  VARCHAR2(1) :='Y';
l_proc    varchar2(72) := g_package ||'chk_mndtry_fields';
 BEGIN

  hr_utility.set_location('Enter ' || l_proc,10);
  IF p_registration_number IS NOT NULL THEN
   OPEN c_get_veh_det;
    FETCH c_get_veh_det INTO l_get_veh_det;
    IF c_get_veh_det%FOUND THEN
     hr_utility.set_location( l_proc,20);
     IF l_get_veh_det.vehicle_type<>p_vehicle_type THEN
      hr_utility.set_location( l_proc,30);
      fnd_message.set_name('PQP', 'PQP_230859_VEHICLE_TYP_VALIDAT');
      l_retvalue :='N';
     END IF;
     IF l_get_veh_det.engine_capacity_in_cc
                              <>p_engine_capacity THEN
      hr_utility.set_location( l_proc,40);
      fnd_message.set_name('PQP', 'PQP_230860_ENGINE_CAP_VALIDAT');
      l_retvalue :='N';

     END IF;
     IF l_get_veh_det.fuel_type <>p_fuel_type THEN
      hr_utility.set_location( l_proc,50);
      fnd_message.set_name('PQP', 'PQP_230861_FUEL_TYP_VALIDAT');
      l_retvalue :='N';
     END IF;


    END IF;
   CLOSE c_get_veh_det;
  END IF;
 --Check if the an assignemnt has company vehicle
--allocated
  IF  p_ownership='C' THEN

   hr_utility.set_location( l_proc,60);
  OPEN c_validate_comp_veh;
   FETCH c_validate_comp_veh INTO l_validate_comp_veh;
   IF c_validate_comp_veh%NOTFOUND THEN

    hr_utility.set_location( l_proc,70);
    fnd_message.set_name('PQP', 'PQP_230866_COMP_VEH_NOT_ALLOC');
    l_retvalue :='N';
   END IF;

  CLOSE c_validate_comp_veh;

  END IF;
  IF p_ownership IS NULL THEN
   hr_utility.set_location( l_proc,80);
   fnd_message.set_name('PQP', 'PQP_230734_FLD_MANDTRY');
   fnd_message.set_token('TOKEN','Ownership');
   l_retvalue :='N';
  END IF;

--Commented out this now because this condition is no longer
--required as the code handles this during element entry.
  /*IF p_usage_type IS NULL THEN
   hr_utility.set_location( l_proc,90);
   fnd_message.set_name('PQP', 'PQP_230734_FLD_MANDTRY');
   fnd_message.set_token('TOKEN','Usage Type');
   l_retvalue :='N';

  END IF;*/

  IF p_vehicle_type IS NULL THEN
   hr_utility.set_location( l_proc,100);
   fnd_message.set_name('PQP', 'PQP_230734_FLD_MANDTRY');
   fnd_message.set_token('TOKEN','Vehicle Type');
   l_retvalue :='N';

  END IF;


  IF p_start_date IS NULL THEN
   hr_utility.set_location( l_proc,110);
   fnd_message.set_name('PQP', 'PQP_230734_FLD_MANDTRY');
   fnd_message.set_token('TOKEN','Start Date');
   l_retvalue :='N';

  END IF;

  IF p_end_date IS NULL THEN
   hr_utility.set_location( l_proc,120);
   fnd_message.set_name('PQP', 'PQP_230734_FLD_MANDTRY');
   fnd_message.set_token('TOKEN','End Date');

   l_retvalue :='N';
  END IF;
  IF p_claimed_mileage IS NULL THEN
   hr_utility.set_location( l_proc,130);
   fnd_message.set_name('PQP', 'PQP_230734_FLD_MANDTRY');
   fnd_message.set_token('TOKEN','Claimed Mileage');
   l_retvalue :='N';

  END IF;


  IF p_engine_capacity IS NULL THEN
   hr_utility.set_location( l_proc,140);
   fnd_message.set_name('PQP', 'PQP_230734_FLD_MANDTRY');
   fnd_message.set_token('TOKEN','Engine Capacity');
   l_retvalue :='N';
  END IF;

  IF p_element_type_id  IS NULL THEN
   hr_utility.set_location( l_proc,150);

   fnd_message.set_name('PQP', 'PQP_230732_VLD_MLG_ELE_FAIL');
   l_retvalue :='N';
  END IF;

  IF FND_DATE.CHARDT_TO_DATE(p_end_date) <
              FND_DATE.CHARDT_TO_DATE(p_start_date) THEN
    hr_utility.set_location( l_proc,160);
    fnd_message.set_name('PER','HR_289262_ST_DATE_BEFORE_EDATE');
   l_retvalue :='N';
  END IF;

 --RETURN('Y');
  RETURN (l_retvalue);
    hr_utility.set_location( 'Leaving :'||l_proc,170);
 END;

--Check for eligibility
FUNCTION chk_eligibility (  p_effective_date        IN  DATE
                           ,p_assignment_id         IN  NUMBER
                           ,p_business_group_id     IN  NUMBER
                           ,p_ownership             IN  VARCHAR2
                           ,p_usage_type            IN  VARCHAR2
                           ,p_vehicle_type          IN  VARCHAR2
                           ,p_start_date            IN  VARCHAR2
                           ,p_end_date              IN  VARCHAR2
                           ,p_claimed_mileage       IN  VARCHAR2
                           ,p_actual_mileage        IN  VARCHAR2
                           ,p_registration_number   IN  VARCHAR2
                           ,p_data_source           IN  VARCHAR2
                           ,p_message               OUT NOCOPY VARCHAR2
                          )

RETURN VARCHAR2
IS

--get info from config table to chk
--for eligibility.
l_retvalue  VARCHAR2(1) :='Y';
CURSOR c_get_config_info (cp_leg_code VARCHAR2)
IS
SELECT  pcv_information6 prev_tax_yr_valid
       ,pcv_information7 allow_both_veh_clm
       ,pcv_information9 validate_pvt_veh
  FROM pqp_configuration_values pcv
 WHERE pcv.legislation_code=cp_leg_code
   AND pcv.pcv_information_category='PQP_VEHICLE_MILEAGE';

--Check the status of vehicle
CURSOR c_validate_veh ( cp_reg_num           VARCHAR2
                       ,cp_ownership         VARCHAR2
                       ,cp_business_group_id VARCHAR2
                       ,cp_start_date         VARCHAR2
                       )
IS
SELECT 'X' exst
  FROM pqp_vehicle_repository_f pvr
 WHERE pvr.registration_number=cp_reg_num
   AND pvr.business_group_id  =cp_business_group_id
   AND TO_DATE(cp_start_date,'YYYY/MM/DD') BETWEEN
       pvr.effective_start_date AND
       pvr.effective_end_date;

CURSOR c_get_alloc_info ( cp_assignment_id     NUMBER
                       ,cp_ownership         VARCHAR2
                       ,cp_business_group_id VARCHAR2
                       ,cp_start_date         VARCHAR2
                       )
IS
SELECT DISTINCT  pvr.vehicle_ownership ownership
  FROM pqp_vehicle_allocations_f pva,
       pqp_vehicle_repository_f pvr
 WHERE pva.assignment_id  =cp_assignment_id
   AND pva.business_group_id =cp_business_group_id
   AND pva.vehicle_repository_id=pvr.vehicle_repository_id
   AND pva.business_group_id=pvr.business_group_id
   AND fnd_date.CHARDATE_TO_DATE(cp_start_date) BETWEEN
       pva.effective_start_date AND
       pva.effective_end_date
   AND fnd_date.CHARDATE_TO_DATE(cp_start_date) BETWEEN
       pvr.effective_start_date AND
       pvr.effective_end_date
   AND pvr.vehicle_ownership='C';

l_get_alloc_info  c_get_alloc_info%ROWTYPE;
l_validate_veh    c_validate_veh%ROWTYPE;
l_get_config_info c_get_config_info%ROWTYPE;

l_proc    varchar2(72) := g_package ||'check_eligibility';
BEGIN
  hr_utility.set_location('Enter chk eligibility:' || l_proc,220);
 OPEN c_get_config_info('GB'
                       );
  LOOP
   FETCH c_get_config_info INTO l_get_config_info;
   EXIT WHEN c_get_config_info%NOTFOUND;

  END LOOP;
 CLOSE c_get_config_info;

--Check if the claim is made for last tax
--year after the cut off date.
 IF l_get_config_info.prev_tax_yr_valid IS NOT NULL THEN
  IF fnd_date.CHARDATE_TO_DATE(p_start_date) <
                             TO_DATE(TO_CHAR
                             (p_effective_date, 'YYYY')||'04/06','YYYY/MM/DD')
                            THEN
   --checking the effective date is greater than previous tax year sumit
   --valid untill date,so user cannot sumit claim after previous tax year
    IF p_effective_date > fnd_date.CHARDATE_TO_DATE
                         (l_get_config_info.prev_tax_yr_valid||
                          TO_CHAR(p_effective_date,'YYYY'))
                            THEN
--Error handling missing
    fnd_message.set_name('PQP', 'PQP_230715_CLM_CUT_OFF_DT');
    p_message :='Violated Valid Tax Year';

   l_retvalue :='N';
   END IF;
  END IF;
 END IF;

  hr_utility.set_location('leave chk eligibility:' || l_proc,230);

--Check if pvt vehicle need to be validated against
--repository.
 IF l_get_config_info.validate_pvt_veh ='Y' THEN

  OPEN c_validate_veh (p_registration_number
                       ,p_ownership
                       ,p_business_group_id
                       ,p_start_date
                       );
   LOOP
    FETCH c_validate_veh INTO l_validate_veh;
    EXIT WHEN c_validate_veh%NOTFOUND;
   END LOOP;
  CLOSE c_validate_veh;

  IF l_validate_veh.exst IS NULL THEN
   fnd_message.set_name('PQP', 'PQP_230735_REGNUM_FRM_REP');
   p_message:='Enter Only Vehicle in Repository';

   l_retvalue :='N';
  END IF;
 END IF;

--Check if the claim can be entered for both.
 IF l_get_config_info.allow_both_veh_clm ='N' THEN
   OPEN c_get_alloc_info ( p_assignment_id
                          ,p_ownership
                          ,p_business_group_id
                          ,p_start_date
                       );
    LOOP
     FETCH c_get_alloc_info INTO l_get_alloc_info;
     EXIT WHEN c_get_alloc_info%NOTFOUND;

    END LOOP;
   CLOSE c_get_alloc_info;
  IF l_get_alloc_info.ownership<>p_ownership THEN
   fnd_message.set_name('PQP', 'PQP_230740_ONE_OWNRSHP_RSTRICT');
   p_message :='Enter Only one type of Claim';
   l_retvalue :='N';
  END IF;
 END IF;
--RETURN('Y');
  RETURN( l_retvalue);
END;



--Check for same record
FUNCTION chk_record_exist ( p_effective_date        IN DATE
                           ,p_assignment_id         IN NUMBER
                           ,p_business_group_id     IN NUMBER
                           ,p_ownership             IN VARCHAR2
                           ,p_usage_type            IN VARCHAR2
                           ,p_vehicle_type          IN VARCHAR2
                           ,p_start_date            IN VARCHAR2
                           ,p_end_date              IN VARCHAR2
                           ,p_claimed_mileage       IN VARCHAR2
                           ,p_actual_mileage        IN VARCHAR2
                           ,p_registration_number   IN VARCHAR2
                           ,p_data_source           IN VARCHAR2
                           )
RETURN VARCHAR2
IS

CURSOR c_get_ele_details ( cp_vehicle_type     VARCHAR2
                          ,cp_business_group_id  NUMBER
                          )

IS
SELECT  pet.element_type_id
       ,pel.element_link_id
  FROM  pay_element_types_f pet
       ,pay_element_type_extra_info pete
       ,pay_element_links_f pel
 WHERE  pete.eei_information_category='PQP_VEHICLE_MILEAGE_INFO'
   AND  pet.element_type_id=pete.element_type_id
   AND  pete.element_type_id=pel.element_type_id
   AND pete.eei_information1=cp_vehicle_type
   AND pet.business_group_id=pel.business_group_id
   AND pet.business_group_id=cp_business_group_id
   AND pet.element_type_id=pel.element_type_id;


CURSOR c_get_input_val (cp_element_type_id     NUMBER
                        ,cp_business_group_id  NUMBER
                        )
IS
SELECT  piv.element_type_id
       ,piv.input_value_id
       ,piv.name
 FROM   pay_input_values_f piv
WHERE   piv.name in ('Claim Start Date','Claim End Date')
  AND   piv.element_type_id=cp_element_type_id
  and   piv.business_group_id=cp_business_group_id;




CURSOR c_get_date_exist ( cp_assignment_id NUMBER
                         ,cp_start_date    DATE
                         ,cp_end_date      DATE
                         ,cp_ipvalue1      NUMBER
                         ,cp_ipvalue2      NUMBER
                         )
IS
SELECT pee.assignment_id
      ,pev1.screen_entry_value scr1
      ,pev2.screen_entry_value scr2
      ,pev1.element_entry_id
 FROM  pay_element_entries_f pee
      ,pay_element_entry_values_f pev1
      ,pay_element_entry_values_f pev2
WHERE  pee.assignment_id=cp_assignment_id
  AND  pee.element_entry_id=pev1.element_entry_id
  AND  pee.element_entry_id=pev2.element_entry_id
  AND  pev1.element_entry_id=pev2.element_entry_id
  AND  pev1.input_value_id  =cp_ipvalue1
  AND  pev2.input_value_id=cp_ipvalue2
  AND  pev1.screen_entry_value =
             fnd_date.DATE_TO_CANONICAL(cp_start_date)
  AND  pev2.SCREEN_ENTRY_VALUE =
             fnd_date.DATE_TO_CANONICAL(cp_end_date);


l_get_ele_details c_get_ele_details%ROWTYPE;
l_get_input_val   c_get_input_val%ROWTYPE;
l_get_date_exist  c_get_date_exist%ROWTYPE;
l_input_val1      NUMBER;
l_input_val2      NUMBER;
l_exist           VARCHAR2(1):='N';
l_start_date      DATE;
l_end_date        DATE;
BEGIN
l_start_date:= fnd_date.chardt_to_date (p_start_date);
l_end_date  :=fnd_date.chardt_to_date(p_end_date);
 OPEN c_get_ele_details( p_vehicle_type
                        ,p_business_group_id
                        );
  LOOP
   FETCH c_get_ele_details INTO l_get_ele_details;
   EXIT WHEN c_get_ele_details%NOTFOUND;
   OPEN c_get_input_val (l_get_ele_details.element_type_id
                        ,p_business_group_id
                        );
    LOOP
     FETCH c_get_input_val INTO l_get_input_val;
     EXIT WHEN c_get_input_val%NOTFOUND;

     IF l_get_input_val.NAME='Claim Start Date' THEN
      l_input_val1:=l_get_input_val.input_value_id;
     ELSIF  l_get_input_val.NAME='Claim End Date' THEN
      l_input_val1:=l_get_input_val.input_value_id;
     END IF;
    END LOOP;
   CLOSE  c_get_input_val;
   OPEN c_get_date_exist ( p_assignment_id
                         ,l_start_date
                         ,l_end_date
                         ,l_input_val1
                         ,l_input_val2
                         );
    LOOP
     FETCH c_get_date_exist INTO l_get_date_exist;
     EXIT WHEN c_get_date_exist%NOTFOUND;

      l_exist :='Y';
    END LOOP;
   CLOSE c_get_date_exist;
  END LOOP;
 CLOSE c_get_ele_details;

 RETURN(l_exist);

END;

---Called from JDEV ----
--
-- Function get_code returns the code of the meaning passed
--
-- The Code depends on the value of the p_option parameter
-- p_option = 'R' -> p_field has the rates table name
--and it Returns the Rates table id
--
FUNCTION get_code
(p_option         IN VARCHAR2
,p_field          IN VARCHAR2
) RETURN VARCHAR2
IS

  --
  -- Cursor to fetch the Rate Table id given the rates table name
  --
  CURSOR c_get_rates_table_id
  IS
  select user_table_id
    from pay_user_tables
   where range_or_match = 'M'
     and user_table_name = p_field;

l_field varchar2(100);
BEGIN

  IF (p_field IS NULL) THEN
    RETURN null;
  END IF;
  IF (p_option = 'R') THEN
    OPEN c_get_rates_table_id;
    FETCH c_get_rates_table_id INTO l_field;
    CLOSE c_get_rates_table_id;
  END IF;
  RETURN l_field;
END get_code;

--
-- Function get_meaning returns the meaning string of the id passed
--
-- The Meaning depends on the value of the p_option parameter
-- p_option = 'R' -> p_field_id has the rates table id
--and it Returns the Rates table Name
-- p_option = 'E' -> p_field_id has the element type id
--and it Returns the Element Name
--
FUNCTION get_meaning
(p_option            IN VARCHAR2
,p_field_id          IN NUMBER
) RETURN VARCHAR2
IS

  --
  -- Cursor to fetch the Element Name given the element type id
  --
  CURSOR c_get_element_name
  IS
  select element_name
    from pay_element_types_f_tl
   where element_type_id = p_field_id;

  --
  -- Cursor to fetch the Rates Table Name given the rates table id
  --
  CURSOR c_get_rates_table_name
  IS
  select user_table_name
    from pay_user_tables
   where user_table_id = p_field_id;

  CURSOR c_get_purpose_name
  IS
  SELECT pur.row_low_range_or_name
    FROM pay_user_tables put
      ,pay_user_rows_f pur
   WHERE put.range_or_match = 'M'
     AND put.user_table_name ='PQP_TRAVEL_PURPOSE'
     AND put.user_table_id = pur.user_table_id
     AND pur.user_row_id= p_field_id;

l_field_meaning varchar2(100);
l_sliding_rates VARCHAR2(10);
l_get_purpose_name c_get_purpose_name%ROWTYPE;
BEGIN
  IF (p_field_id IS NULL) THEN
    RETURN NULL;
  END IF;
  IF (p_option = 'R')  THEN
   OPEN c_get_rates_table_name;
    FETCH c_get_rates_table_name INTO l_field_meaning;
   CLOSE c_get_rates_table_name;
  ELSIF (p_option = 'E') THEN
    OPEN c_get_element_name;
   FETCH c_get_element_name INTO l_field_meaning;
   CLOSE c_get_element_name;
  END IF;
  RETURN l_field_meaning;
END get_meaning;
----------------------------------

----------Generic Procedures

FUNCTION get_lkp_meaning (p_lookup_code IN VARCHAR2,
                          p_lookup_type IN VARCHAR2
                          )
RETURN VARCHAR2
AS

CURSOR c_get_lkp_meaning
IS
SELECT hl.meaning
  FROM hr_lookups hl
 WHERE hl.lookup_type=p_lookup_type
   AND hl.lookup_code=p_lookup_code;


l_get_lkp_meaning c_get_lkp_meaning%ROWTYPE;

BEGIN

 OPEN c_get_lkp_meaning;
  LOOP
   FETCH c_get_lkp_meaning INTO l_get_lkp_meaning;
   EXIT WHEN c_get_lkp_meaning%NOTFOUND;
  END LOOP;
 CLOSE c_get_lkp_meaning;

 RETURN (l_get_lkp_meaning.meaning);

END;
--Get lookup meaning
FUNCTION get_meaning ( p_inp_type VARCHAR2
                      ,p_code     VARCHAR2
                      )
RETURN VARCHAR2
AS

CURSOR c_get_meaning_u
IS
SELECT lkp.lookup_code
       ,lkp.meaning
  FROM hr_lookups lkp
 WHERE lkp.lookup_type IN ('PQP_PRIVATE_VEHICLE_USER'
                      ,'PQP_COMPANY_VEHICLE_USER')
   AND lkp.lookup_code=p_code;
 --AND lkp.application_id=8303


CURSOR c_get_meaning_o
IS
SELECT lkp.lookup_code
       ,lkp.meaning
  FROM hr_lookups lkp
 WHERE lookup_type in ('PQP_VEHICLE_OWNERSHIP_TYPE')
   AND lkp.lookup_code=p_code;
 --AND lkp.application_id=8303

CURSOR c_get_meaning_f
IS
select meaning
from hr_lookups
where lookup_type = 'PQP_FUEL_TYPE'
and enabled_flag = 'Y'
and lookup_code = p_code;

CURSOR c_get_meaning_cm
IS
select meaning
from hr_lookups
where lookup_type = 'PQP_VEHICLE_CALC_METHOD'
and enabled_flag='Y'
and lookup_code = p_code;

CURSOR c_get_meaning_vt
IS
select hl.meaning
from pqp_vehicle_repository_f pvr,
hr_lookups hl
where pvr.registration_number = p_code
and hl.lookup_type = 'PQP_VEHICLE_TYPE'
and hl.enabled_flag = 'Y'
and hl.lookup_code = pvr.vehicle_type;

CURSOR c_get_meaning_vehtype
IS
select hl.meaning
from hr_lookups hl
where hl.lookup_type = 'PQP_VEHICLE_TYPE'
and hl.enabled_flag = 'Y'
and hl.lookup_code = p_code;


CURSOR c_get_purpose_name
IS
SELECT pur.row_low_range_or_name
 FROM pay_user_tables put
     ,pay_user_rows_f pur
WHERE put.range_or_match = 'M'
  AND put.user_table_name ='PQP_TRAVEL_PURPOSE'
  AND put.user_table_id = pur.user_table_id
  AND pur.user_row_id= p_code;


l_get_meaning_u c_get_meaning_u%ROWTYPE;
l_get_meaning_o c_get_meaning_o%ROWTYPE;
l_meaning hr_lookups.meaning%TYPE;

l_proc    varchar2(72) := g_package ||'get_meaning';
BEGIN

  hr_utility.set_location('enter get meaning:' || l_proc,240);
IF p_inp_type =  'EI' THEN
  OPEN c_get_meaning_o;
  LOOP
    FETCH c_get_meaning_o INTO l_get_meaning_o;
    EXIT WHEN c_get_meaning_o%NOTFOUND;
    RETURN(l_get_meaning_o.meaning);
  END LOOP;
  CLOSE c_get_meaning_o;

  IF l_get_meaning_o.meaning IS NULL THEN
    RETURN(p_code);
  END IF;
ELSIF p_inp_type = 'Rate Type' THEN
 OPEN c_get_meaning_u;
  LOOP
   FETCH c_get_meaning_u INTO l_get_meaning_u;
   EXIT WHEN c_get_meaning_u%NOTFOUND;
    RETURN (l_get_meaning_u.meaning);
  END LOOP;
 CLOSE c_get_meaning_u;


 IF l_get_meaning_u.meaning IS NULL THEN
    RETURN(p_code);
 END IF;
--RETURN('NONE');

-- Gets the Vehicle Type for the given Reg. No.
ELSIF p_inp_type = 'VT' THEN
 OPEN c_get_meaning_vt;
 FETCH c_get_meaning_vt INTO l_meaning;
 CLOSE c_get_meaning_vt;
    RETURN(l_meaning);
-- Gets the Vehicle Type for the given VehType Code
ELSIF p_inp_type = 'V' THEN
 OPEN c_get_meaning_vehtype;
 FETCH c_get_meaning_vehtype INTO l_meaning;
 CLOSE c_get_meaning_vehtype;
    RETURN(l_meaning);
-- Gets the Fuel Type meaning given the code
ELSIF p_inp_type = 'Fuel Type' THEN
 OPEN c_get_meaning_f;
 FETCH c_get_meaning_f INTO l_meaning;
 CLOSE c_get_meaning_f;
 RETURN(l_meaning);

-- Gets the Calculation Method meaning given the code
ELSIF p_inp_type = 'CM' THEN
 OPEN c_get_meaning_cm;
 FETCH c_get_meaning_cm INTO l_meaning;
 CLOSE c_get_meaning_cm;
 RETURN(l_meaning);

ELSIF p_inp_type='Purpose' THEN
 OPEN c_get_purpose_name;
  FETCH c_get_purpose_name INTO l_meaning;
 CLOSE c_get_purpose_name;
 RETURN(l_meaning);
END IF;
  hr_utility.set_location('Leaving get meaning:' || l_proc,250);
exception
when others then
return(p_code);
END;


--This func is temporary
FUNCTION get_total ( p_element_name          IN VARCHAR2
                    ,p_assignment_action_id  IN NUMBER
                    ,p_element_entry_id      IN NUMBER
                    ,p_business_group_id     IN NUMBER
                    )
return NUMBER
IS
CURSOR c_get_balance_name
IS
SELECT balance_type_id ,pbd.balance_dimension_id
  FROM pay_balance_types pbt
       ,pay_balance_dimensions pbd
 WHERE balance_name = p_element_name||' Processed Amt'
   AND pbd.legislation_code='GB'
   AND pbd.dimension_name='_ELEMENT_ITD';

--This cursor fetches the balance when the option
--is PAYE Taxable is YES.
CURSOR c_get_tax_element_type_id
IS
SELECT DISTINCT pet.element_type_id
  FROM pay_element_types_f pet
 WHERE pet.element_name = p_element_name||' Taxable'
   AND pet.business_group_id=p_business_group_id ;

CURSOR c_get_gross_pay_bal_name
IS
SELECT balance_type_id
  FROM pay_balance_types pbt
 WHERE balance_name = 'Gross Pay'
   AND pbt.legislation_code='GB' ;


CURSOR c_get_def_balance ( cp_balance_typ_id NUMBER
                          ,cp_balance_dim_id NUMBER
                         )
IS
SELECT pdb.defined_balance_id
 from pay_defined_balances pdb
where pdb.balance_type_id =cp_balance_typ_id
  and pdb.balance_dimension_id=cp_balance_dim_id;

cursor c1(cp_balance_type_id       NUMBER
          ,cp_assignment_action_id NUMBER
          ,cp_element_entry_id     NUMBER)
is
SELECT  nvl(SUM(fnd_number.canonical_to_number(TARGET.result_value)
        * FEED.scale),0) tot
 FROM pay_run_result_values   TARGET
,      pay_balance_feeds_f     FEED
,      pay_run_results         RR
,      pay_assignment_actions  ASSACT
,      pay_assignment_actions  BAL_ASSACT
,      pay_payroll_actions     PACT
WHERE  BAL_ASSACT.assignment_action_id = cp_assignment_action_id
AND    FEED.balance_type_id  = cp_balance_type_id
AND    FEED.input_value_id     = TARGET.input_value_id
AND    TARGET.run_result_id    = RR.run_result_id
AND    RR.assignment_action_id = ASSACT.assignment_action_id
AND    ASSACT.payroll_action_id = PACT.payroll_action_id
AND    PACT.effective_date between FEED.effective_start_date
                               AND FEED.effective_end_date
AND    RR.status in ('P','PA')
AND    ASSACT.action_sequence <= BAL_ASSACT.action_sequence
AND    ASSACT.assignment_id = BAL_ASSACT.assignment_id
AND    (( RR.source_id = cp_element_entry_id and source_type in ( 'E','I'))
 OR    ( rr.source_type in ('R','V') /* reversal */
                AND exists
                ( SELECT null from pay_run_results rr1
                  WHERE rr1.source_id = cp_element_entry_id
                  AND   rr1.run_result_id = rr.source_id
                  AND   rr1.source_type in ( 'E','I'))));


cursor c1_tax(cp_balance_type_id       NUMBER
          ,cp_assignment_action_id     NUMBER
          ,cp_element_entry_id         NUMBER
          ,cp_element_type_id          NUMBER)
IS
SELECT  target.result_value tot
 FROM pay_run_result_values   TARGET
,      pay_balance_feeds_f     FEED
,      pay_run_results         RR
,      pay_assignment_actions  ASSACT
,      pay_assignment_actions  BAL_ASSACT
,      pay_payroll_actions     PACT
WHERE  bal_assact.assignment_action_id = cp_assignment_action_id
AND    FEED.input_value_id     = TARGET.input_value_id
AND    TARGET.run_result_id    = RR.run_result_id
AND    RR.assignment_action_id = ASSACT.assignment_action_id
AND    ASSACT.payroll_action_id = PACT.payroll_action_id
AND    PACT.effective_date between FEED.effective_start_date
                               AND FEED.effective_end_date
AND    RR.status in ('P','PA')
AND    ASSACT.action_sequence <= BAL_ASSACT.action_sequence
AND    ASSACT.assignment_id = BAL_ASSACT.assignment_id
AND    rr.element_type_id=cp_element_type_id
AND    (( RR.source_id = cp_element_entry_id and source_type in ( 'E','I'))
 OR    ( rr.source_type in ('R','V')
                AND exists
                ( SELECT null from pay_run_results rr1
                  WHERE rr1.source_id = cp_element_entry_id
                  AND   rr1.run_result_id = rr.source_id
                  AND   rr1.source_type in ( 'E','I'))))
    and feed.balance_type_id=cp_balance_type_id;




l_get_balance_name        c_get_balance_name%ROWTYPE;
l_get_tax_element_type_id c_get_tax_element_type_id%ROWTYPE;
l_get_gross_pay_bal_name  c_get_gross_pay_bal_name%ROWTYPE;
l_get_def_balance         c_get_def_balance%ROWTYPE;
lc1                       c1%ROWTYPE;
lc1_tax                   c1_tax%ROWTYPE;
BEGIN

 OPEN c_get_balance_name;
 FETCH c_get_balance_name INTO l_get_balance_name;
  OPEN c1(l_get_balance_name.balance_type_id
          ,p_assignment_action_id
          ,p_element_entry_id    );
   FETCH c1 INTO lc1;
     IF lc1.tot = 0 THEN
      OPEN c_get_tax_element_type_id;
       FETCH c_get_tax_element_type_id
              INTO l_get_tax_element_type_id;
      CLOSE c_get_tax_element_type_id;

      OPEN c_get_gross_pay_bal_name;
       FETCH c_get_gross_pay_bal_name INTO
                   l_get_gross_pay_bal_name;
      CLOSE c_get_gross_pay_bal_name;

      OPEN c1_tax (l_get_gross_pay_bal_name.balance_type_id
                   ,p_assignment_action_id
                   ,p_element_entry_id
                   ,l_get_tax_element_type_id.element_type_id
                   );
        FETCH c1_tax INTO lc1_tax;
         RETURN(NVL(lc1_tax.tot,0));
        CLOSE c1_tax;
      ELSE

       return(NVL(lc1.tot,0));
     END IF;

       --return(NVL(lc1.tot,0));
   CLOSE c1;
  CLOSE c_get_balance_name;


return(0);
END;
--Function to get balance for the view.
FUNCTION get_amount ( p_element_name      IN VARCHAR2
                     ,p_element_type_id   IN NUMBER
                     ,p_effective_date    IN DATE
                     ,p_assignment_id     IN NUMBER
                    )

return NUMBER
IS

CURSOR c_get_balance_name
IS
SELECT balance_type_id ,pbd.balance_dimension_id
  FROM pay_balance_types pbt
       ,pay_balance_dimensions pbd
 WHERE balance_name = p_element_name||' Processed Amt'
   AND pbd.legislation_code='GB'
   AND pbd.dimension_name='_ELEMENT_ITD';


CURSOR c_get_def_balance ( cp_balance_typ_id NUMBER
                          ,cp_balance_dim_id NUMBER
                         )
IS
SELECT pdb.DEFINED_BALANCE_ID
 from pay_defined_balances pdb
where pdb.balance_type_id =cp_balance_typ_id
  and pdb.balance_dimension_id=cp_balance_dim_id;



BEGIN

  FOR l_get_balance_name IN c_get_balance_name
   LOOP

   FOR l_get_def_balance IN c_get_def_balance
                              (l_get_balance_name.balance_type_id
                               ,l_get_balance_name.balance_dimension_id
                               )
     LOOP
      return(hr_dirbal.get_balance(p_assignment_id
                                   ,l_get_def_balance.DEFINED_BALANCE_ID
                                  ,p_effective_date));

     END LOOP;
   END LOOP;
return(0);
EXCEPTION
WHEN OTHERS THEN
return(0);

END;

PROCEDURE insert_company_mileage_claim
        ( p_effective_date             IN DATE,
          p_assignment_id              IN NUMBER,
          p_business_group_id          IN NUMBER,
          p_ownership                  IN VARCHAR2  ,
          p_usage_type                 IN VARCHAR2  ,
          p_vehicle_type               IN VARCHAR2,
          p_start_date                 IN VARCHAR2  ,
          p_end_date                   IN VARCHAR2  ,
          p_claimed_mileage            IN VARCHAR2  ,
          p_actual_mileage             IN VARCHAR2  ,
          p_registration_number        IN VARCHAR2  ,
          p_engine_capacity            IN VARCHAR2  ,
          p_fuel_type                  IN VARCHAR2  ,
          p_calculation_method         IN VARCHAR2  ,
          p_user_rates_table           IN VARCHAR2  ,
          p_fiscal_ratings             IN VARCHAR2  ,
          p_PAYE_taxable               IN VARCHAR2  ,
          p_no_of_passengers           IN VARCHAR2  ,
          p_purpose                    IN VARCHAR2  ,
          p_payroll_id                 IN NUMBER,
          p_mileage_claim_element      IN OUT NOCOPY NUMBER  ,
          p_element_entry_id           IN OUT NOCOPY NUMBER  ,
          p_element_entry_date         IN OUT NOCOPY DATE,
          p_element_link_id            IN NUMBER
         )

IS

CURSOR c_get_table_name (cp_user_rates_table   VARCHAR2
                         ,cp_business_group_id NUMBER
                         )
IS
SELECT put.user_table_name
  FROM pay_user_tables put
 WHERE user_table_id =cp_user_rates_table
   AND put.business_group_id=cp_business_group_id;

CURSOR c_get_input_details (cp_element_type_id NUMBER
                       ,cp_effective_date DATE
                       ,cp_business_group_id NUMBER
                       )
IS
SELECT piv.input_value_id,
       piv.name,
       piv.display_sequence,
       piv.lookup_type,
       piv.default_value
  FROM pay_input_values_f piv
 WHERE piv.element_type_id=cp_element_type_id
   AND piv.business_group_id=cp_business_group_id
   AND cp_effective_date BETWEEN piv.effective_start_date
                             AND piv.effective_end_date;


l_effective_start_date    DATE;
l_effective_end_date    DATE;
l_get_input_details c_get_input_details%ROWTYPE;
l_get_table_name    c_get_table_name%ROWTYPE;
l_input_value_id1  pay_input_values_f.input_value_id%TYPE;
l_input_value_id2  pay_input_values_f.input_value_id%TYPE;
l_input_value_id3  pay_input_values_f.input_value_id%TYPE;
l_input_value_id4  pay_input_values_f.input_value_id%TYPE;
l_input_value_id5  pay_input_values_f.input_value_id%TYPE;
l_input_value_id6  pay_input_values_f.input_value_id%TYPE;
l_input_value_id7  pay_input_values_f.input_value_id%TYPE;
l_input_value_id8  pay_input_values_f.input_value_id%TYPE;
l_input_value_id9  pay_input_values_f.input_value_id%TYPE;
l_input_value_id10  pay_input_values_f.input_value_id%TYPE:=NULL;
l_input_value_id11  pay_input_values_f.input_value_id%TYPE:=NULL;
l_input_value_id12  pay_input_values_f.input_value_id%TYPE:=NULL;
l_input_value_id13  pay_input_values_f.input_value_id%TYPE:=NULL;
l_input_value_id14  pay_input_values_f.input_value_id%TYPE:=NULL;
l_input_value_id15  pay_input_values_f.input_value_id%TYPE:=NULL;

l_entry_value1      pay_element_entry_values_f.screen_entry_value%TYPE;
l_entry_value2      pay_element_entry_values_f.screen_entry_value%TYPE;
l_entry_value3      pay_element_entry_values_f.screen_entry_value%TYPE;
l_entry_value4      pay_element_entry_values_f.screen_entry_value%TYPE;
l_entry_value5      pay_element_entry_values_f.screen_entry_value%TYPE;
l_entry_value6      pay_element_entry_values_f.screen_entry_value%TYPE;
l_entry_value7      pay_element_entry_values_f.screen_entry_value%TYPE;
l_entry_value8      pay_element_entry_values_f.screen_entry_value%TYPE;
l_entry_value9      pay_element_entry_values_f.screen_entry_value%TYPE;
l_entry_value10     pay_element_entry_values_f.screen_entry_value%TYPE:=NULL;
l_entry_value11     pay_element_entry_values_f.screen_entry_value%TYPE:=NULL;
l_entry_value12     pay_element_entry_values_f.screen_entry_value%TYPE:=NULL;
l_entry_value13     pay_element_entry_values_f.screen_entry_value%TYPE:=NULL;
l_entry_value14     pay_element_entry_values_f.screen_entry_value%TYPE:=NULL;
l_entry_value15     pay_element_entry_values_f.screen_entry_value%TYPE:=NULL;
 l_element_entry_id number;
l_proc    varchar2(72) := g_package ||'get_meaning';
l_temp_var          NUMBER;
BEGIN
  hr_utility.set_location('Insert_company_mileage_claim:' || l_proc,260);
l_effective_start_date :=p_effective_date;
l_effective_end_date :=hr_api.g_eot;


 BEGIN
  l_temp_var := to_number(p_user_rates_table);



  OPEN c_get_table_name ( p_user_rates_table
                        ,p_business_group_id
                        );
   FETCH c_get_table_name INTO l_get_table_name;
  CLOSE c_get_table_name;
 EXCEPTION
 ---------
 WHEN OTHERS THEN
  l_get_table_name.user_table_name:=p_user_rates_table;
 END;

OPEN c_get_input_details (p_mileage_claim_element
                          ,p_effective_date
                          ,p_business_group_id
                          );
 LOOP
  FETCH c_get_input_details INTO l_get_input_details;
  EXIT WHEN c_get_input_details%NOTFOUND;



  IF l_get_input_details.name='Pay Value' THEN
   l_input_value_id1:=l_get_input_details.input_value_id;
   l_entry_value1   :=NULL;
  ELSIF l_get_input_details.name='Vehicle Type' THEN

   l_input_value_id2:=l_get_input_details.input_value_id;
   IF l_get_input_details.lookup_type IS NOT NULL THEN
    l_entry_value2:=get_lkp_meaning(p_usage_type
                   ,l_get_input_details.lookup_type);
   ELSE
   l_entry_value2   :=p_usage_type;
   END IF;
  ELSIF l_get_input_details.name='Two Wheeler Type' THEN
   l_input_value_id3:=l_get_input_details.input_value_id;
   IF l_get_input_details.lookup_type IS NOT NULL THEN
    l_entry_value3:=get_lkp_meaning(p_start_date
                   ,l_get_input_details.lookup_type);
   ELSE
   l_entry_value3   :=p_start_date;
   END IF;
  ELSIF l_get_input_details.name='Claim Start Date' THEN
   l_input_value_id3:=l_get_input_details.input_value_id;
   IF l_get_input_details.lookup_type IS NOT NULL THEN
    l_entry_value3:=get_lkp_meaning(p_start_date
                   ,l_get_input_details.lookup_type);
   ELSE
   l_entry_value3   :=p_start_date;
   END IF;


  ELSIF l_get_input_details.name='Claim End Date' THEN
   l_input_value_id4:=l_get_input_details.input_value_id;
   IF l_get_input_details.lookup_type IS NOT NULL THEN
    l_entry_value4:=get_lkp_meaning(p_end_date
                   ,l_get_input_details.lookup_type);
   ELSE
    l_entry_value4    :=p_end_date;
   END IF;
  ELSIF l_get_input_details.name='Claimed Mileage' THEN
   l_input_value_id5:=l_get_input_details.input_value_id;
   IF l_get_input_details.lookup_type IS NOT NULL THEN
    l_entry_value5:=get_lkp_meaning(p_claimed_mileage
                   ,l_get_input_details.lookup_type);
   ELSE
   l_entry_value5    :=p_claimed_mileage;
   END IF;
  ELSIF l_get_input_details.name='Actual Mileage' THEN
   l_input_value_id6:=l_get_input_details.input_value_id;
   IF l_get_input_details.lookup_type IS NOT NULL THEN
    l_entry_value6:=get_lkp_meaning(p_actual_mileage
                   ,l_get_input_details.lookup_type);
   ELSE
   l_entry_value6    :=p_actual_mileage;
   END IF;
  ELSIF l_get_input_details.name='User Rates Table'
    OR l_get_input_details.name='Sliding Rates Table' THEN
   l_input_value_id7:=l_get_input_details.input_value_id;
   IF l_get_input_details.lookup_type IS NOT NULL THEN
    l_entry_value7:=get_lkp_meaning(p_user_rates_table
                   ,l_get_input_details.lookup_type);
   ELSE

   l_entry_value7    :=l_get_table_name.user_table_name;
   END IF;
  ELSIF l_get_input_details.name='PAYE Taxable' THEN
   l_input_value_id8:=l_get_input_details.input_value_id;
   IF l_get_input_details.lookup_type IS NOT NULL THEN
    l_entry_value8:=get_lkp_meaning(NVL(p_PAYE_taxable
                        ,l_get_input_details.default_value)
                        ,l_get_input_details.lookup_type);
   ELSE
    l_entry_value8    :=p_PAYE_taxable;
   END IF;
  ELSIF l_get_input_details.name='No of Passengers' THEN
   l_input_value_id9:=l_get_input_details.input_value_id;
   IF l_get_input_details.lookup_type IS NOT NULL THEN
    l_entry_value9:=get_lkp_meaning(p_no_of_Passengers
                   ,l_get_input_details.lookup_type);
   ELSE
    l_entry_value9    :=p_no_of_Passengers;
   END IF;
  ELSIF l_get_input_details.name='Vehicle Reg Number' THEN
   l_input_value_id10:=l_get_input_details.input_value_id;
   IF l_get_input_details.lookup_type IS NOT NULL THEN
    l_entry_value10:=get_lkp_meaning(p_registration_number
                   ,l_get_input_details.lookup_type);
   ELSE
   l_entry_value10    := p_registration_number;
   END IF;
  ELSIF l_get_input_details.name='Engine Capacity' THEN
   l_input_value_id11:=l_get_input_details.input_value_id;
   IF l_get_input_details.lookup_type IS NOT NULL THEN
    l_entry_value11:=get_lkp_meaning(p_engine_capacity
                   ,l_get_input_details.lookup_type);
   ELSE
   l_entry_value11    :=p_engine_capacity;
   END IF;
  ELSIF l_get_input_details.name='Fuel Type' THEN
   l_input_value_id12:=l_get_input_details.input_value_id;
   IF l_get_input_details.lookup_type IS NOT NULL THEN
    l_entry_value12:=get_lkp_meaning(p_fuel_type
                   ,l_get_input_details.lookup_type);
   ELSE
   l_entry_value12    :=p_fuel_type;
   END IF;
  ELSIF l_get_input_details.name='Calculation Method' THEN
   l_input_value_id13:=l_get_input_details.input_value_id;
   IF l_get_input_details.lookup_type IS NOT NULL THEN
    --l_entry_value13:=get_lkp_meaning(p_calculation_method
    --               ,l_get_input_details.lookup_type);
    l_entry_value13:=get_lkp_meaning(NVL(p_calculation_method
                        ,l_get_input_details.default_value)
                        ,l_get_input_details.lookup_type);
   ELSE
   --l_entry_value13    :=p_calculation_method;
   l_entry_value13    :=NVL(p_calculation_method,
                            l_get_input_details.default_value);
   END IF;
  ELSIF l_get_input_details.name='Purpose' THEN
   l_input_value_id14:=l_get_input_details.input_value_id;
   IF l_get_input_details.lookup_type IS NOT NULL THEN
    l_entry_value14:=get_lkp_meaning(p_purpose
                   ,l_get_input_details.lookup_type);
   ELSE
   l_entry_value14    :=p_purpose;
   END IF;
  END IF;


 END LOOP;
CLOSE c_get_input_details;
hr_utility.set_location('Entering hr_entry_apiinsert_element_entry',270);
hr_entry_api.insert_element_entry
 (
  p_effective_start_date       =>l_effective_start_date,
  p_effective_end_date         =>l_effective_end_date,
  p_element_entry_id           =>p_element_entry_id,
  p_original_entry_id          =>null,
  p_assignment_id              =>p_assignment_id,
  p_element_link_id            =>p_element_link_id,
  p_creator_type               =>'F',
  p_entry_type                 =>'E',
  p_creator_id                 => null,
  p_input_value_id1            =>l_input_value_id1,
  p_input_value_id2            =>l_input_value_id2,
  p_input_value_id3            =>l_input_value_id3,
  p_input_value_id4            =>l_input_value_id4,
  p_input_value_id5            =>l_input_value_id5,
  p_input_value_id6            =>l_input_value_id6,
  p_input_value_id7            =>l_input_value_id7,
  p_input_value_id8            =>l_input_value_id8,
  p_input_value_id9            =>l_input_value_id9,
  p_input_value_id10           =>l_input_value_id10 ,
  p_input_value_id11           =>l_input_value_id11,
  p_input_value_id12           =>l_input_value_id12,
  p_input_value_id13           =>l_input_value_id13,
  p_input_value_id14           =>l_input_value_id14,
  p_input_value_id15           =>l_input_value_id15,
  p_entry_value1               =>l_entry_value1,
  p_entry_value2               =>l_entry_value2 ,
  p_entry_value3               =>l_entry_value3,
  p_entry_value4               =>l_entry_value4,
  p_entry_value5               =>l_entry_value5,
  p_entry_value6               =>l_entry_value6,
  p_entry_value7               =>l_entry_value7,
  p_entry_value8               =>l_entry_value8,
  p_entry_value9               =>l_entry_value9,
  p_entry_value10              =>l_entry_value10,
  p_entry_value11              =>l_entry_value11,
  p_entry_value12              =>l_entry_value12,
  p_entry_value13              =>l_entry_value13,
  p_entry_value14              =>l_entry_value14,
  p_entry_value15              =>l_entry_value15
 );

END;

--Inserts GB specific claim
PROCEDURE insert_private_mileage_claim
        ( p_effective_date             IN DATE,
          p_assignment_id              IN NUMBER,
          p_business_group_id          IN NUMBER,
          p_ownership                  IN VARCHAR2  ,
          p_usage_type                 IN VARCHAR2  ,
          p_vehicle_type               IN VARCHAR2,
          p_start_date                 IN VARCHAR2  ,
          p_end_date                   IN VARCHAR2  ,
          p_claimed_mileage            IN VARCHAR2  ,
          p_actual_mileage             IN VARCHAR2  ,
          p_registration_number        IN VARCHAR2  ,
          p_engine_capacity            IN VARCHAR2  ,
          p_fuel_type                  IN VARCHAR2  ,
          p_calculation_method         IN VARCHAR2  ,
          p_user_rates_table           IN VARCHAR2  ,
          p_fiscal_ratings             IN VARCHAR2  ,
          p_PAYE_taxable               IN VARCHAR2  ,
          p_no_of_passengers           IN VARCHAR2  ,
          p_purpose                    IN VARCHAR2  ,
          p_payroll_id                 IN NUMBER,
          p_mileage_claim_element      IN OUT NOCOPY NUMBER  ,
          p_element_entry_id           IN OUT NOCOPY NUMBER  ,
          p_element_entry_date         IN OUT NOCOPY DATE,
          p_element_link_id            IN NUMBER
         )

IS


CURSOR c_get_input_details (cp_element_type_id NUMBER
                       ,cp_effective_date DATE
                       ,cp_business_group_id NUMBER
                       )
IS
SELECT piv.input_value_id,
       piv.name,
       piv.display_sequence,
       piv.lookup_type,
       piv.default_value
  FROM pay_input_values_f piv
 WHERE piv.element_type_id=cp_element_type_id
   AND piv.business_group_id=cp_business_group_id
   AND cp_effective_date BETWEEN piv.effective_start_date
                             AND piv.effective_end_date;

CURSOR c_get_table_name ( cp_user_rates_table  VARCHAR2
                         ,cp_business_group_id NUMBER
                         )
IS
SELECT put.user_table_name
  FROM pay_user_tables put
 WHERE user_table_id =cp_user_rates_table
   AND put.business_group_id=cp_business_group_id;
l_effective_start_date    DATE;
l_effective_end_date    DATE;
l_get_input_details c_get_input_details%ROWTYPE;
l_get_table_name    c_get_table_name%ROWTYPE;

l_input_value_id1  pay_input_values_f.input_value_id%TYPE;
l_input_value_id2  pay_input_values_f.input_value_id%TYPE;
l_input_value_id3  pay_input_values_f.input_value_id%TYPE;
l_input_value_id4  pay_input_values_f.input_value_id%TYPE;
l_input_value_id5  pay_input_values_f.input_value_id%TYPE;
l_input_value_id6  pay_input_values_f.input_value_id%TYPE;
l_input_value_id7  pay_input_values_f.input_value_id%TYPE;
l_input_value_id8  pay_input_values_f.input_value_id%TYPE;
l_input_value_id9  pay_input_values_f.input_value_id%TYPE;
l_input_value_id10  pay_input_values_f.input_value_id%TYPE:=NULL;
l_input_value_id11  pay_input_values_f.input_value_id%TYPE:=NULL;
l_input_value_id12  pay_input_values_f.input_value_id%TYPE:=NULL;
l_input_value_id13  pay_input_values_f.input_value_id%TYPE:=NULL;
l_input_value_id14  pay_input_values_f.input_value_id%TYPE:=NULL;
l_input_value_id15  pay_input_values_f.input_value_id%TYPE:=NULL;
l_input_value_id16  pay_input_values_f.input_value_id%TYPE:=NULL;

l_entry_value1      pay_element_entry_values_f.screen_entry_value%TYPE;
l_entry_value2      pay_element_entry_values_f.screen_entry_value%TYPE;
l_entry_value3      pay_element_entry_values_f.screen_entry_value%TYPE;
l_entry_value4      pay_element_entry_values_f.screen_entry_value%TYPE;
l_entry_value5      pay_element_entry_values_f.screen_entry_value%TYPE;
l_entry_value6      pay_element_entry_values_f.screen_entry_value%TYPE;
l_entry_value7      pay_element_entry_values_f.screen_entry_value%TYPE;
l_entry_value8      pay_element_entry_values_f.screen_entry_value%TYPE;
l_entry_value9      pay_element_entry_values_f.screen_entry_value%TYPE;
l_entry_value10     pay_element_entry_values_f.screen_entry_value%TYPE:=NULL;
l_entry_value11     pay_element_entry_values_f.screen_entry_value%TYPE:=NULL;
l_entry_value12     pay_element_entry_values_f.screen_entry_value%TYPE:=NULL;
l_entry_value13     pay_element_entry_values_f.screen_entry_value%TYPE:=NULL;
l_entry_value14     pay_element_entry_values_f.screen_entry_value%TYPE:=NULL;
l_entry_value15     pay_element_entry_values_f.screen_entry_value%TYPE:=NULL;
l_entry_value16     pay_element_entry_values_f.screen_entry_value%TYPE:=NULL;
l_temp_var          NUMBER;
BEGIN
hr_utility.set_location('Enter private element entry process',280);
l_effective_start_date :=p_effective_date;
l_effective_end_date :=hr_api.g_eot;

 BEGIN
  l_temp_var := to_number(p_user_rates_table);



  OPEN c_get_table_name ( p_user_rates_table
                        ,p_business_group_id
                        );
   FETCH c_get_table_name INTO l_get_table_name;
  CLOSE c_get_table_name;
 EXCEPTION
 ---------
 WHEN OTHERS THEN
  l_get_table_name.user_table_name:=p_user_rates_table;
 END;

OPEN c_get_input_details (p_mileage_claim_element
                          ,p_effective_date
                          ,p_business_group_id
                          );
 LOOP
  FETCH c_get_input_details INTO l_get_input_details;
  EXIT WHEN c_get_input_details%NOTFOUND;


  IF l_get_input_details.name='Pay Value' THEN
   l_input_value_id1:=l_get_input_details.input_value_id;
   l_entry_value1   :=NULL;
  ELSIF l_get_input_details.name='Rate Type' THEN

   l_input_value_id2:=l_get_input_details.input_value_id;
   IF l_get_input_details.lookup_type IS NOT NULL THEN
    IF p_usage_type IS NULL THEN
     l_entry_value2 :=get_dflt_input_value (l_input_value_id2
                                            ,p_mileage_claim_element
                                            ,p_business_group_id
                                            ,p_effective_date
                                           );
    l_entry_value2:=get_lkp_meaning(l_entry_value2
                   ,l_get_input_details.lookup_type);
    ELSE
     l_entry_value2:=get_lkp_meaning(p_usage_type
                   ,l_get_input_details.lookup_type);
    END IF;
   ELSE
    l_entry_value2   :=p_usage_type;

   END IF;
  ELSIF l_get_input_details.name='Two Wheeler Type' THEN
   l_input_value_id3:=l_get_input_details.input_value_id;
   IF l_get_input_details.lookup_type IS NOT NULL THEN
    l_entry_value3:=get_lkp_meaning(p_start_date
                   ,l_get_input_details.lookup_type);
   ELSE
   l_entry_value3   :=p_start_date;
   END IF;
  ELSIF l_get_input_details.name='Claim Start Date' THEN
   l_input_value_id4:=l_get_input_details.input_value_id;
   IF l_get_input_details.lookup_type IS NOT NULL THEN
    l_entry_value4:=get_lkp_meaning(p_start_date
                   ,l_get_input_details.lookup_type);
   ELSE
   l_entry_value4   :=p_start_date;
   END IF;

  ELSIF l_get_input_details.name='Claim End Date' THEN
   l_input_value_id5:=l_get_input_details.input_value_id;
   IF l_get_input_details.lookup_type IS NOT NULL THEN
    l_entry_value5:=get_lkp_meaning(p_end_date
                   ,l_get_input_details.lookup_type);
   ELSE
   l_entry_value5    :=p_end_date;
   END IF;
  ELSIF l_get_input_details.name='Claimed Mileage' THEN
   l_input_value_id6:=l_get_input_details.input_value_id;
   IF l_get_input_details.lookup_type IS NOT NULL THEN
    l_entry_value6:=get_lkp_meaning(p_claimed_mileage
                   ,l_get_input_details.lookup_type);
   ELSE
   l_entry_value6    :=p_claimed_mileage;
   END IF;
  ELSIF l_get_input_details.name='Actual Mileage' THEN
   l_input_value_id7:=l_get_input_details.input_value_id;
   IF l_get_input_details.lookup_type IS NOT NULL THEN
    l_entry_value7:=get_lkp_meaning(p_actual_mileage
                   ,l_get_input_details.lookup_type);
   ELSE
   l_entry_value7    :=p_actual_mileage;
   END IF;
  ELSIF l_get_input_details.name='Vehicle Reg Number' THEN
   l_input_value_id8:=l_get_input_details.input_value_id;
   IF l_get_input_details.lookup_type IS NOT NULL THEN
    l_entry_value8:=get_lkp_meaning(p_registration_number
                   ,l_get_input_details.lookup_type);
   ELSE
   l_entry_value8    := p_registration_number;
   END IF;
  ELSIF l_get_input_details.name='Engine Capacity' THEN
   l_input_value_id9:=l_get_input_details.input_value_id;
   IF l_get_input_details.lookup_type IS NOT NULL THEN
    l_entry_value9:=get_lkp_meaning(p_engine_capacity
                   ,l_get_input_details.lookup_type);
   ELSE
   l_entry_value9    :=p_engine_capacity;
   END IF;
  ELSIF l_get_input_details.name='Fuel Type' THEN
   l_input_value_id10:=l_get_input_details.input_value_id;
   IF l_get_input_details.lookup_type IS NOT NULL THEN
    l_entry_value10:=get_lkp_meaning(p_fuel_type
                   ,l_get_input_details.lookup_type);
   ELSE
   l_entry_value10    :=p_fuel_type;
   END IF;
  ELSIF l_get_input_details.name='Calculation Method' THEN
   l_input_value_id11:=l_get_input_details.input_value_id;
   IF l_get_input_details.lookup_type IS NOT NULL THEN
    --l_entry_value11:=get_lkp_meaning(p_calculation_method
    --               ,l_get_input_details.lookup_type);
    l_entry_value11:=get_lkp_meaning(NVL(p_calculation_method
                           ,l_get_input_details.default_value)
                           ,l_get_input_details.lookup_type);
   ELSE
   --l_entry_value11    :=p_calculation_method;
   l_entry_value11    :=NVL(p_calculation_method,
                            l_get_input_details.default_value);
   END IF;
  ELSIF l_get_input_details.name='User Rates Table' OR
        l_get_input_details.name='Sliding Rates Table' THEN
   l_input_value_id12:=l_get_input_details.input_value_id;
   IF l_get_input_details.lookup_type IS NOT NULL THEN
    l_entry_value12:=get_lkp_meaning(p_user_rates_table
                   ,l_get_input_details.lookup_type);
   ELSE
    IF p_user_rates_table IS NOT NULL THEN
     l_entry_value12    :=l_get_table_name.user_table_name;
    ELSE

     l_entry_value12    :=l_get_input_details.default_value;

    END IF;
   END IF;
  ELSIF l_get_input_details.name='PAYE Taxable' THEN
   l_input_value_id13:=l_get_input_details.input_value_id;
   IF l_get_input_details.lookup_type IS NOT NULL THEN
    l_entry_value13:=get_lkp_meaning(NVL(p_PAYE_Taxable
                            ,l_get_input_details.default_value)
                            ,l_get_input_details.lookup_type);
   ELSE
   l_entry_value13    :=p_PAYE_Taxable;
   END IF;
  ELSIF l_get_input_details.name='No of Passengers' THEN
   l_input_value_id14:=l_get_input_details.input_value_id;
   IF l_get_input_details.lookup_type IS NOT NULL THEN
    l_entry_value14:=get_lkp_meaning(p_no_of_passengers
                   ,l_get_input_details.lookup_type);
   ELSE
   l_entry_value14    :=p_no_of_passengers;
   END IF;
  ELSIF l_get_input_details.name='CO2 Emissions' THEN
   l_input_value_id15:=l_get_input_details.input_value_id;
   IF l_get_input_details.lookup_type IS NOT NULL THEN
    l_entry_value15:=get_lkp_meaning(p_fiscal_ratings
                   ,l_get_input_details.lookup_type);
   ELSE
   l_entry_value15    :=p_fiscal_ratings;
   END IF;
  ELSIF l_get_input_details.name='Purpose' THEN
   l_input_value_id16:=l_get_input_details.input_value_id;
   IF l_get_input_details.lookup_type IS NOT NULL THEN
    l_entry_value16:=get_lkp_meaning(p_purpose
                   ,l_get_input_details.lookup_type);
   ELSE
   l_entry_value16    :=p_purpose;
   END IF;
  END IF;





 END LOOP;
CLOSE c_get_input_details;

  IF l_input_value_id3 IS NULL THEN
   l_entry_value3 :=l_entry_value16;
   l_input_value_id3 :=l_input_value_id16;


  END IF;
hr_utility.set_location('Enter hr_entry_apiinsert_element_entr',290);
hr_entry_api.insert_element_entry
 (
  --
  -- Common Parameters
  --
  p_effective_start_date       =>l_effective_start_date,
  p_effective_end_date         =>l_effective_end_date,
  p_element_entry_id           =>p_element_entry_id,
  p_original_entry_id          =>null,
  p_assignment_id              =>p_assignment_id,
  p_element_link_id            =>p_element_link_id,
  p_creator_type               =>'F',
  p_entry_type                 =>'E',
  p_creator_id                 => null,
  p_input_value_id1            =>l_input_value_id1,
  p_input_value_id2            =>l_input_value_id2,
  p_input_value_id3            =>l_input_value_id3,
  p_input_value_id4            =>l_input_value_id4,
  p_input_value_id5            =>l_input_value_id5,
  p_input_value_id6            =>l_input_value_id6,
  p_input_value_id7            =>l_input_value_id7,
  p_input_value_id8            =>l_input_value_id8,
  p_input_value_id9            =>l_input_value_id9,
  p_input_value_id10           =>l_input_value_id10 ,
  p_input_value_id11           =>l_input_value_id11,
  p_input_value_id12           =>l_input_value_id12,
  p_input_value_id13           =>l_input_value_id13,
  p_input_value_id14           =>l_input_value_id14,
  p_input_value_id15           =>l_input_value_id15,
  p_entry_value1               =>l_entry_value1,
  p_entry_value2               =>l_entry_value2 ,
  p_entry_value3               =>l_entry_value3,
  p_entry_value4               =>l_entry_value4,
  p_entry_value5               =>l_entry_value5,
  p_entry_value6               =>l_entry_value6,
  p_entry_value7               =>l_entry_value7,
  p_entry_value8               =>l_entry_value8,
  p_entry_value9               =>l_entry_value9,
  p_entry_value10              =>l_entry_value10,
  p_entry_value11              =>l_entry_value11,
  p_entry_value12              =>l_entry_value12,
  p_entry_value13              =>l_entry_value13,
  p_entry_value14              =>l_entry_value14,
  p_entry_value15              =>l_entry_value15
 );
hr_utility.set_location('leaving hr_entry_apiinsert_element_entr',300);
END;
END;

/
