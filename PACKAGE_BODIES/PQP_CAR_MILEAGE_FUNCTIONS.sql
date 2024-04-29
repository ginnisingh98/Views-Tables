--------------------------------------------------------
--  DDL for Package Body PQP_CAR_MILEAGE_FUNCTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_CAR_MILEAGE_FUNCTIONS" AS
--REM $Header: pqgbcmfn.pkb 120.5.12010000.1 2008/07/28 11:10:54 appldev ship $

----------------------------------------------------------------------
--Function get_legislation_code
----------------------------------------------------------------------------

FUNCTION get_legislation_code (p_business_group_id IN NUMBER)
RETURN VARCHAR2
IS

 l_legislation_code_l  per_business_groups.legislation_code%TYPE;
BEGIN
 hr_utility.trace('Enter Legislation code');
  SELECT legislation_code
    INTO l_legislation_code_l
   FROM per_business_groups
   WHERE business_group_id      =p_business_group_id;

   RETURN (l_legislation_code_l);
 hr_utility.trace('Leaving Legislation code' );

 EXCEPTION
 ---------
 WHEN OTHERS THEN
 RETURN(NULL);

 END;





-----------------------------------------------------------------------------
-- FUNCTION CHECK_NUMERIC
-----------------------------------------------------------------------------
FUNCTION  check_numeric(p_value_to_check    IN VARCHAR2)
RETURN BOOLEAN IS

l_temp NUMBER;

BEGIN

  l_temp := to_number(p_value_to_check);
RETURN(TRUE);

EXCEPTION

WHEN VALUE_ERROR THEN
   RETURN(FALSE);

END check_numeric;
--------------------------------------------------------------------------------
--FUNCTION GET FUEL TYPE
---------------------------------------------------------------------------------
 FUNCTION get_fuel_type (p_veh_id IN NUMBER)
 RETURN CHAR
 IS
 l_fuel_type  pqp_vehicle_details.fuel_type%TYPE;
 l_fuel     VARCHAR2(50);
BEGIN
  SELECT fuel_type
    INTO l_fuel_type
    FROM pqp_vehicle_details
    WHERE vehicle_details_id=p_veh_id;

   IF l_fuel_type='P' THEN
     l_fuel:='Petrol';
     RETURN(l_fuel);

   ELSIF l_fuel_type='D' THEN
     l_fuel:='Diesel';
     RETURN(l_fuel);

   ELSIF l_fuel_type='L' THEN
     l_fuel:='Liquid Petroleum Gas';
     RETURN(l_fuel);

   ELSIF l_fuel_type='H' THEN
     l_fuel:='Hybrid Electric';
     RETURN(l_fuel);

   ELSIF l_fuel_type='E' THEN
     l_fuel:='Electricity Only';
     RETURN(l_fuel);


   ELSIF l_fuel_type='C' THEN
    l_fuel:='Conversion';
    RETURN(l_fuel);

   ELSIF l_fuel_type='B' THEN
    l_fuel:='Bi-Fuel';
    RETURN(l_fuel);

   END IF;

  EXCEPTION
  --------
   WHEN OTHERS THEN
   RETURN('NONE');

END get_fuel_type;

-----------------------------------------------------------------------------
-- FUNCTION PQP_GET_RANGE
-----------------------------------------------------------------------------
FUNCTION  pqp_get_range(       p_assignment_id       IN  NUMBER
                              ,p_business_group_id   IN  NUMBER
                              ,p_payroll_action_id   IN  NUMBER
                              ,p_table_name          IN  VARCHAR2
                              ,p_row_or_column       IN  VARCHAR2
                              ,p_value               IN  NUMBER
                              ,p_claim_date          IN  DATE
                              ,p_low_value           OUT NOCOPY NUMBER
                              ,p_high_value          OUT NOCOPY NUMBER)
RETURN NUMBER IS

CURSOR row_cur (in_claim_date IN DATE) IS
SELECT pur.row_low_range_or_name
  FROM pay_user_rows_f pur,pay_user_tables put
 WHERE pur.user_table_id      = put.user_table_id
   AND put.user_table_name    = p_table_name
   AND (put.business_group_id = p_business_group_id
         OR put.legislation_code IS NOT NULL)
   AND in_claim_date BETWEEN NVL(pur.effective_start_date,in_claim_date)
   AND NVL(pur.effective_end_date,in_claim_date)
ORDER BY pur.row_low_range_or_name;

CURSOR col_cur (in_claim_date IN DATE)IS
SELECT puc.user_column_name
  FROM pay_user_columns puc
       ,pay_user_tables put
       ,pay_user_column_instances_f puci
 WHERE puc.user_table_id       = put.user_table_id
   AND put.user_table_name     = p_table_name
   AND puc.user_column_id      = puci.user_column_id
   AND (put.business_group_id  = p_business_group_id
         OR put.legislation_code  IS NOT NULL)
   AND (puci.business_group_id = p_business_group_id
         OR puci.legislation_code IS NOT NULL)
   AND puci.value IS NOT NULL
   AND in_claim_date BETWEEN NVL(puci.effective_start_date,in_claim_date)
   AND NVL(puci.effective_end_date,in_claim_date)
ORDER BY puc.user_column_name;


TYPE t_value IS TABLE OF NUMBER
INDEX BY BINARY_INTEGER;

l_value           t_value;
l_temp            NUMBER;
l_row             pay_user_rows.ROW_LOW_RANGE_OR_NAME%TYPE ;
l_col             pay_user_columns.USER_COLUMN_NAME%TYPE ;
l_val_to_return   NUMBER;
l_temp_num        NUMBER;
l_counter         NUMBER := 0;
l_effective_date  DATE;
l_val_count       NUMBER:=0;
BEGIN

-- This was done because Formula Functions do not accept NULL
-- for input. If the date is 01/01/1900 then effective_date = date earned
IF TO_CHAR(TRUNC(p_claim_date),'DD/MM/YYYY') = '01/01/1900' THEN
  l_effective_date := TRUNC(pqp_car_mileage_functions.pqp_get_date_paid
                                     (p_payroll_action_id));
ELSE
  l_effective_date := p_claim_date;
END IF;

IF p_row_or_column NOT IN ('ROW','COL') THEN
   --hr_utility.RAISE;
     return -1;
ELSIF p_row_or_column = 'ROW' THEN
   OPEN row_cur(l_effective_date);
     LOOP
       FETCH row_cur INTO l_row;
       IF row_cur%ROWCOUNT > 0 THEN
       -- Check if the value fetched is numeric
       IF CHECK_NUMERIC(l_row) THEN
         l_counter := l_counter + 1;
            -- First time assign first value as high and low.
            --*****************************************--
            /* IF l_counter = 1 THEN
                 p_low_value  := l_row;
                 p_high_value := l_row;
             ELSIF l_counter > 1 THEN
                 IF p_value > p_high_value THEN
                    p_high_value := l_row;
                 ELSIF l_row < p_high_value AND l_row >= p_value THEN
                    p_high_value := l_row;
                 ELSIF l_row < p_low_value and l_row < p_value THEN
                    p_low_value := l_row;
                 ELSIF p_low_value = p_high_value
                 OR    p_low_value > p_high_value THEN
                    p_low_value := 0;
                 END IF;
             END IF;*/
            --*****************************************--

        l_value(l_counter):=to_number(l_row);
         END IF;
       ELSIF row_cur%ROWCOUNT = 0 THEN
          close row_cur;
          return -1;
       END IF;
     EXIT WHEN row_cur%NOTFOUND;
    END LOOP;
      l_value(l_value.count+1):=p_value;
   IF l_counter=0 THEN
     RETURN(-1);
   END if;

/*IF p_value > p_high_value THEN
 p_high_value := 0;
 p_low_value  := 0;
END IF;*/

  CLOSE row_cur;

FOR i IN 1..l_value.count-1
 LOOP
  FOR j IN i+1..l_value.count
   LOOP
     IF l_value(i)>=l_value(j) THEN
        l_temp:=l_value(i);
        l_value(i):=l_value(j);
        l_value(j):=l_temp;
     END IF;
   END LOOP;
 END LOOP;


FOR i IN 1..l_value.count
 LOOP

  IF p_value=l_value(i) THEN
     l_val_count:=i;
     EXIT;
  END IF;
 END LOOP;

IF l_val_count=l_value.count AND l_val_count<>1 THEN
   p_high_value:=0 ;---l_value(l_value.count-1);
   p_low_value :=0; --l_value(l_value.count-1);
ELSIF
   l_val_count=1 AND p_value=l_value(1) THEN
   p_high_value:=l_value(2);
   p_low_value:=0;
ELSIF l_val_count=1 AND l_value.count=1 THEN
   p_high_value:=0;
   p_low_value:=0;

ELSE

   p_high_value:=l_value(l_val_count+1);
   p_low_value :=l_value(l_val_count-1);



END IF;


RETURN(l_val_to_return);

ELSIF p_row_or_column = 'COL' THEN
   OPEN col_cur(l_effective_date);
     LOOP
       FETCH col_cur INTO l_col;
       IF col_cur%ROWCOUNT > 0 THEN
       -- Check if the value fetched is numeric
       IF CHECK_NUMERIC(l_col) THEN
         l_counter := l_counter + 1;
             -- First time assign first value as high and low.
             IF l_counter = 1 THEN
                 p_low_value  := l_col;
                 p_high_value := l_col;
             ELSIF l_counter > 1 THEN
                 IF p_value > p_high_value THEN
                    p_high_value := l_col;
                 ELSIF l_col < p_high_value AND l_col >= p_value THEN
                    p_high_value := l_col;
                 ELSIF l_col < p_low_value and l_col < p_value THEN
                    p_low_value := l_col;
                 ELSIF p_low_value = p_high_value
                 OR    p_low_value > p_high_value THEN
                    p_low_value := 0;
                 END IF;
             END IF;
         END IF;
       ELSIF col_cur%ROWCOUNT = 0 THEN
          close col_cur;
          return -1;
       END IF;
     EXIT WHEN col_cur%NOTFOUND;
    END LOOP;

IF p_value > p_high_value THEN
 p_high_value := 0;
 p_low_value  := 0;
END IF;

  CLOSE col_cur;

RETURN(l_val_to_return);

-- OLD CODE
   /*  LOOP
       FETCH col_cur INTO l_col;
          EXIT WHEN col_cur%NOTFOUND;
          -- Check if the value fetched is numeric
          IF CHECK_NUMERIC(l_col) THEN
          -- Check if it is less than or equal to the input ( p_value)
          IF p_value <= l_col THEN
            -- Assign value to temp variable
            l_temp_num := to_number(l_col);
              IF l_col <= NVL(l_val_to_return,l_temp_num) THEN
                l_val_to_return := to_number(l_col);
              END IF ;
          END IF;
       END IF;
    END LOOP;
  CLOSE col_cur;

RETURN(l_val_to_return);
*/
-- OLD CODE

END IF;

EXCEPTION
-- Code exception here
 WHEN OTHERS THEN
   p_low_value  := 0;
   p_high_value := 0;
   raise;

END pqp_get_range;

----------------------------------------------------------------------------
--FUNCTION get_config_info
---------------------------------------------------------------------------
FUNCTION get_config_info (p_business_group_id IN NUMBER
                         ,p_info_type        IN VARCHAR2
                          )
RETURN VARCHAR2
IS

 CURSOR c_get_config_value_rates (cp_leg_code VARCHAR2)
     IS
 SELECT PCV_INFORMATION13 info
   FROM pqp_configuration_values pcv
  WHERE pcv_information_category='PQP_VEHICLE_MILEAGE'
    AND (pcv.business_group_id=p_business_group_id OR
        ( legislation_code = 'GB'  AND
  NOT EXISTS
  (SELECT 'X' from pqp_configuration_values pcv
    WHERE pcv_information_category='PQP_VEHICLE_MILEAGE'
      AND pcv.business_group_id=p_business_group_id ))) ;


 CURSOR c_get_config_value_taxinf (cp_leg_code VARCHAR2)
     IS
 SELECT PCV_INFORMATION14 info
   FROM pqp_configuration_values pcv
  WHERE pcv_information_category='PQP_VEHICLE_MILEAGE'
    AND (pcv.business_group_id=p_business_group_id OR
        ( legislation_code = 'GB'  AND
  NOT EXISTS
  (SELECT 'X' from pqp_configuration_values pcv
    WHERE pcv_information_category='PQP_VEHICLE_MILEAGE'
      AND pcv.business_group_id=p_business_group_id ))) ;


CURSOR c_get_config_value_puiinf (cp_leg_code VARCHAR2)
     IS
 SELECT PCV_INFORMATION15 info
   FROM pqp_configuration_values pcv
  WHERE pcv_information_category='PQP_VEHICLE_MILEAGE'
    AND (pcv.business_group_id=p_business_group_id OR
        ( legislation_code = 'GB'  AND
  NOT EXISTS
  (SELECT 'X' from pqp_configuration_values pcv
    WHERE pcv_information_category='PQP_VEHICLE_MILEAGE'
      AND pcv.business_group_id=p_business_group_id ))) ;


l_get_config_value  c_get_config_value_rates%ROWTYPE;
l_legislation_code  pqp_configuration_values.legislation_code%TYPE;
BEGIN
 l_legislation_code := pqp_car_mileage_functions.
                       get_legislation_code (p_business_group_id);
 IF p_info_type = 'Rates' THEN
  OPEN c_get_config_value_rates (l_legislation_code);
   FETCH c_get_config_value_rates INTO l_get_config_value;
  CLOSE c_get_config_value_rates;

 ELSIF p_info_type = 'Combined Limit' OR p_info_type = 'Combined Limit Co'
       OR p_info_type = 'Combined Limit Pvt'  THEN
  OPEN c_get_config_value_taxinf (l_legislation_code);
   FETCH c_get_config_value_taxinf INTO l_get_config_value;
  CLOSE c_get_config_value_taxinf;

 ELSIF p_info_type = 'Professional User' THEN
  OPEN c_get_config_value_puiinf (l_legislation_code);
   FETCH c_get_config_value_puiinf INTO l_get_config_value;
  CLOSE c_get_config_value_puiinf;
 END IF;

 RETURN (NVL(l_get_config_value.info,'N'));

EXCEPTION
---------
 WHEN OTHERS THEN
  RETURN ('N');


END  get_config_info;

-----------------------------------------------------------------------------
-- FUNCTION PQP_GET_ATTR_VAL
-----------------------------------------------------------------------------
FUNCTION  pqp_get_attr_val(    p_assignment_id      IN  NUMBER
                              ,p_business_group_id  IN  NUMBER
                              ,p_payroll_action_id  IN  NUMBER
                              ,p_car_type           IN  VARCHAR2
                              ,p_cc                 OUT NOCOPY NUMBER
                              ,p_rates_table        OUT NOCOPY VARCHAR2
                              ,p_calc_method        OUT NOCOPY VARCHAR2
                              ,p_error_msg          OUT NOCOPY VARCHAR2
                              ,p_claim_date         IN  DATE
                              ,p_fuel_type          OUT NOCOPY VARCHAR2
			      ,p_veh_reg           IN  VARCHAR2 DEFAULT NULL)
RETURN NUMBER IS

l_effective_date         DATE;
l_car_type               VARCHAR2(3);

/*CURSOR c_get_config_rt (cp_usage_type VARCHAR2
                       ,cp_vehicle_type VARCHAR2
                       ,cp_fuel_type VARCHAR2
                        )
IS
SELECT  pcv.pcv_information5 rates_type
  FROM pqp_configuration_values pcv
 WHERE business_group_id=p_business_group_id
   AND pcv.pcv_information_category='GB_VEHICLE_CALC_INFO'
   AND (pcv_information2=cp_usage_type
        OR pcv_information2 IS NULL)
   AND (pcv_information3=cp_vehicle_type
         OR pcv_information3 IS NULL)
   AND (pcv_information4=cp_fuel_type
         OR pcv_information4 IS NULL)
   AND pcv.pcv_information5 IS NOT NULL ;    */

---just to create a temp var for the dyn
---curor.
CURSOR c_get_config_rt_temp
IS
SELECT  pcv.aat_information5 rates_type
  FROM  pqp_assignment_attributes_f pcv
 WHERE rownum=1;

CURSOR c_get_attr_val_temp
IS
SELECT  pva.company_car_calc_method calculation_method
       ,pva.private_car rates_table_id
       ,pvr.engine_capacity_in_cc engine_capacity_in_cc
       ,pvr.fuel_type fuel_type
       ,pvr.vehicle_type default_vehicle
       ,pvr.vehicle_type vehicle_type
 FROM  pqp_vehicle_details pvr
      ,pqp_assignment_attributes_f pva
 WHERE rownum=1;

CURSOR c_get_config_info_temp
IS
SELECT  pcv.aat_information1 calculation_method
  FROM  pqp_assignment_attributes_f pcv
 WHERE rownum=1;

/*CURSOR c_get_attr_val
IS
SELECT pva.calculation_method
       ,pva.rates_table_id
       ,pvr.engine_capacity_in_cc
       ,pvr.fuel_type
       ,pva.default_vehicle
       ,pvr.vehicle_type
  FROM pqp_vehicle_repository_f pvr
       ,pqp_vehicle_allocations_f pva
 WHERE pvr.vehicle_repository_id=pva.vehicle_repository_id
   AND pva.assignment_id=p_assignment_id
   AND pva.business_group_id=p_business_group_id
   AND pva.business_group_id=pvr.business_group_id
   AND pva.usage_type=p_car_type
   AND pva.usage_type IN ('P','S')
   AND p_claim_date BETWEEN pva.effective_start_date
                        AND pva.effective_end_date
   AND p_claim_date BETWEEN pvr.effective_start_date
                        AND pvr.effective_end_date
  UNION
 SELECT pva.calculation_method
       ,pva.rates_table_id
       ,pvr.engine_capacity_in_cc
       ,pvr.fuel_type
       ,pva.default_vehicle
       ,pvr.vehicle_type
   FROM pqp_vehicle_repository_f pvr
       ,pqp_vehicle_allocations_f pva
 WHERE pvr.vehicle_repository_id=pva.vehicle_repository_id
   AND pva.assignment_id=p_assignment_id
   AND pva.business_group_id=p_business_group_id
   AND pva.business_group_id=pvr.business_group_id
   AND pvr.vehicle_ownership='P'
   AND p_car_type in ('C','E')
  -- AND decode(p_car_type,'E',pva.usage_type,'C',pva.usage_type,NULL) IS NULL
   AND ( default_vehicle='Y' or  default_vehicle IS NULL or default_vehicle='N')
   AND p_claim_date BETWEEN pva.effective_start_date
                        AND pva.effective_end_date
   AND p_claim_date BETWEEN pvr.effective_start_date
                        AND pvr.effective_end_date
   ;*/
/*CURSOR c_get_config_info
IS
SELECT pcv_information1 calculation_method
  FROM pqp_configuration_values pcv
 WHERE pcv_information_category='PQP_VEHICLE_MILEAGE'
   AND pcv.legislation_code='GB'
   AND NOT EXISTS (SELECT 'X'
                     FROM pqp_configuration_values pcv1
                    WHERE pcv1.business_group_id=p_business_group_id)
UNION
SELECT pcv_information1 calculation_method
  FROM pqp_configuration_values pcv
 WHERE pcv_information_category='PQP_VEHICLE_MILEAGE'
   AND pcv.business_group_id=p_business_group_id;*/

CURSOR c_get_veh_typ (cp_vehicle_id NUMBER)
IS
SELECT pvd.vehicle_type
 FROM  pqp_vehicle_details pvd
WHERE pvd.vehicle_details_id =cp_vehicle_id
  AND pvd.business_group_id=p_business_group_id;

CURSOR ATTR_CUR IS
SELECT  primary_company_car
       ,secondary_company_car
       ,private_car
       ,company_car_rates_table_id
       ,company_car_secondary_table_id
       ,private_car_rates_table_id
       ,private_car_essential_table_id
       ,company_car_calc_method
       ,private_car_calc_method
FROM   PQP_ASSIGNMENT_ATTRIBUTES_F
WHERE assignment_id = p_assignment_id
  AND decode(TO_CHAR(TRUNC(p_claim_date),'DD/MM/YYYY'),
                '01/01/1900',l_effective_date,p_claim_date)
BETWEEN effective_start_date AND effective_end_date;

CURSOR c_get_table_name (c_rates_table VARCHAR2)
IS
   SELECT distinct user_table_name
     FROM pay_user_tables
    WHERE user_table_id = c_rates_table
      AND business_group_id=p_business_group_id;

CURSOR c_exst
IS
 SELECT 'X'
   FROM fnd_tables ft
   WHERE ft.application_id=8303
     AND ft.table_name='PQP_VEHICLE_ALLOCATIONS_F'
   AND rownum=1;

CURSOR c_get_attr_val(p_veh_reg VARCHAR2, p_assignment_id NUMBER, p_business_group_id NUMBER, l_car_type VARCHAR2, l_temp_effective_date DATE) IS

SELECT pva.calculation_method
                    ,pva.rates_table_id
                    ,pvr.engine_capacity_in_cc
                    ,pvr.fuel_type
                    ,pva.default_vehicle
                    ,pvr.vehicle_type
                FROM pqp_vehicle_repository_f pvr
                    ,pqp_vehicle_allocations_f pva
               WHERE pvr.vehicle_repository_id=pva.vehicle_repository_id
	         AND pvr.registration_number=decode(p_veh_reg,'NE',pvr.registration_number,p_veh_reg)
                 AND pva.assignment_id=p_assignment_id
                 AND pva.business_group_id=p_business_group_id
                 AND pva.business_group_id=pvr.business_group_id
                 AND pva.usage_type=l_car_type
                  AND pva.usage_type IN ('P','S')
                 AND l_temp_effective_date BETWEEN pva.effective_start_date
                                  AND pva.effective_end_date
                 AND l_temp_effective_date BETWEEN pvr.effective_start_date
                                  AND pvr.effective_end_date
               UNION
               SELECT pva.calculation_method
                      ,pva.rates_table_id
                      ,pvr.engine_capacity_in_cc
                      ,pvr.fuel_type
                      ,pva.default_vehicle
                      ,pvr.vehicle_type
                  FROM pqp_vehicle_repository_f pvr
                      ,pqp_vehicle_allocations_f pva
                 WHERE pvr.vehicle_repository_id=pva.vehicle_repository_id
	           AND pvr.registration_number=decode(p_veh_reg,'NE',pvr.registration_number,p_veh_reg)
                   AND pva.assignment_id=p_assignment_id
                   AND pva.business_group_id=p_business_group_id
                   AND pva.business_group_id=pvr.business_group_id
                   AND pvr.vehicle_ownership='P'
                   AND l_car_type in ('C','E')
                   AND ( default_vehicle='Y' or  default_vehicle IS NULL
                       OR default_vehicle='N')
                   AND l_temp_effective_date BETWEEN pva.effective_start_date
                        AND pva.effective_end_date
                   AND l_temp_effective_date BETWEEN pvr.effective_start_date
                        AND pvr.effective_end_date;


l_get_veh_typ            c_get_veh_typ%ROWTYPE;
l_get_config_info        c_get_config_info_temp%ROWTYPE;
l_get_attr_val           c_get_attr_val_temp%ROWTYPE;
l_vehicle_details_id     PQP_VEHICLE_DETAILS.vehicle_details_id%TYPE;
l_rates_table_id         NUMBER(9);
l_exst                   VARCHAR2(1);
l_rates_table_name       pay_user_tables.user_table_name%TYPE;
l_get_config_rates       c_get_config_rt_temp%ROWTYPE;
l_str                    VARCHAR2(2300);
l_str_val                VARCHAR2(2300);
l_str_info               VARCHAR2(2300);
TYPE ref_csr IS   REF CURSOR;
--c_get_attr_val           ref_csr;
c_get_config_rt          ref_csr;
c_get_config_info        ref_csr;
l_vehicle_type           VARCHAR2(2);
l_err_num                NUMBER:=0;
l_veh_typ                VARCHAR2(3):=NULL;
l_temp_effective_date    DATE;
BEGIN
l_effective_date :=TRUNC(pqp_car_mileage_functions.
                       pqp_get_date_paid(p_payroll_action_id));
l_vehicle_type := NVL(SUBSTR(p_car_type,2),'C');
l_car_type:=SUBSTR(p_car_type,0,1);
 IF l_vehicle_type='CM' or l_vehicle_type='PM' THEN
  l_vehicle_type:='M';
 ELSIF l_vehicle_type ='NE' THEN

  l_vehicle_type:='C';
 END IF;

 OPEN c_exst;
 FETCH c_exst INTO l_exst;
 CLOSE c_exst;
IF l_exst IS NULL THEN
 IF l_car_type NOT IN ('P','S','C','E') THEN
  p_error_msg := 'Error - Car Type Invalid';
  RETURN -1;
 ELSE
  FOR attr_rec IN attr_cur
     LOOP
        IF l_car_type = 'C' THEN
           l_vehicle_details_id := attr_rec.private_car;
           l_rates_table_id     := attr_rec.private_car_rates_table_id;
           p_calc_method        := NVL(attr_rec.private_car_calc_method,'NE');
           p_fuel_type          :=get_fuel_type(attr_rec.private_car);
           OPEN c_get_veh_typ (l_vehicle_details_id);
            FETCH c_get_veh_typ INTO l_get_veh_typ;
           CLOSE c_get_veh_typ;
           IF l_get_veh_typ.vehicle_type<>l_vehicle_type THEN
           -- l_err_num:=-1;
            null;
           END IF;
           EXIT;
        ELSIF l_car_type = 'E' THEN
           l_vehicle_details_id := attr_rec.private_car;
           l_rates_table_id     := attr_rec.private_car_essential_table_id;
           p_calc_method        := NVL(attr_rec.private_car_calc_method,'NE');
           p_fuel_type          :=get_fuel_type(attr_rec.private_car);
           OPEN c_get_veh_typ (l_vehicle_details_id);
            FETCH c_get_veh_typ INTO l_get_veh_typ;
           CLOSE c_get_veh_typ;
           IF l_get_veh_typ.vehicle_type<>l_vehicle_type THEN
            --l_err_num:=-1;
             null;
           END IF;
           EXIT;
        ELSIF l_car_type = 'P' THEN
           l_vehicle_details_id := attr_rec.primary_company_car;
           l_rates_table_id     := attr_rec.company_car_rates_table_id;
           p_calc_method        := NVL(attr_rec.company_car_calc_method,'NE');
           p_fuel_type          :=get_fuel_type(attr_rec.primary_company_car);
           OPEN c_get_veh_typ (l_vehicle_details_id);
            FETCH c_get_veh_typ INTO l_get_veh_typ;
           CLOSE c_get_veh_typ;
           IF l_get_veh_typ.vehicle_type<>l_vehicle_type THEN
            l_err_num:=-1;

           END IF;
           EXIT;
        ELSIF l_car_type ='S' THEN
           l_vehicle_details_id := attr_rec.secondary_company_car;
           l_rates_table_id     := attr_rec.company_car_secondary_table_id;
           p_calc_method        := NVL(attr_rec.company_car_calc_method,'NE');
           p_fuel_type          := get_fuel_type(attr_rec.secondary_company_car);
           OPEN c_get_veh_typ (l_vehicle_details_id);
            FETCH c_get_veh_typ INTO l_get_veh_typ;
           CLOSE c_get_veh_typ;
           IF l_get_veh_typ.vehicle_type<>l_vehicle_type THEN
            --l_err_num:=-1;
             null;
           END IF;
           EXIT;
        END IF;
    END LOOP;
 END IF;

 IF l_vehicle_details_id IS NOT NULL THEN
  SELECT engine_capacity_in_cc
    INTO p_cc
    FROM PQP_VEHICLE_DETAILS
   WHERE vehicle_details_id = l_vehicle_details_id;
 END IF;

 IF l_rates_table_id IS NOT NULL THEN
  OPEN c_get_table_name (l_rates_table_id);
   FETCH c_get_table_name INTO p_rates_table;
  CLOSE c_get_table_name;
 END IF;
 IF l_err_num <>-1 THEN
  IF l_car_type IN ('E','C') THEN
   p_error_msg := 'SUCCESS';
   RETURN 0;
  ELSIF l_car_type IN ('P','S') AND p_cc IS NOT NULL
      AND p_rates_table IS NOT NULL THEN
   p_error_msg := 'SUCCESS';
   RETURN 0;
  ELSE
   p_error_msg := 'Error - Unable to find Table or Vehicle ';
   RETURN -1;
  END IF;
 ELSE
  p_error_msg := 'TYPERR';
  RETURN -1;
 END IF;

ELSE

 IF TO_CHAR(TRUNC(p_claim_date),'DD/MM/YYYY') = '01/01/1900' THEN
  l_temp_effective_date :=l_effective_date;
 ELSE
  l_temp_effective_date :=p_claim_date;

 END IF;

 /*l_str_val:= 'SELECT pva.calculation_method
                    ,pva.rates_table_id
                    ,pvr.engine_capacity_in_cc
                    ,pvr.fuel_type
                    ,pva.default_vehicle
                    ,pvr.vehicle_type
                FROM pqp_vehicle_repository_f pvr
                    ,pqp_vehicle_allocations_f pva
               WHERE pvr.vehicle_repository_id=pva.vehicle_repository_id
	         AND pvr.registration_number='''||p_veh_reg||'''
                 AND pva.assignment_id='||p_assignment_id||
                 ' AND pva.business_group_id='||p_business_group_id||
                 ' AND pva.business_group_id=pvr.business_group_id
                 AND pva.usage_type='''||l_car_type ||'''
                  AND pva.usage_type IN (''P'''||','||'''S'')
                 AND '''||l_temp_effective_date||''' BETWEEN pva.effective_start_date
                                  AND pva.effective_end_date
                 AND '''|| l_temp_effective_date||''' BETWEEN pvr.effective_start_date
                                  AND pvr.effective_end_date
               UNION
               SELECT pva.calculation_method
                      ,pva.rates_table_id
                      ,pvr.engine_capacity_in_cc
                      ,pvr.fuel_type
                      ,pva.default_vehicle
                      ,pvr.vehicle_type
                  FROM pqp_vehicle_repository_f pvr
                      ,pqp_vehicle_allocations_f pva
                 WHERE pvr.vehicle_repository_id=pva.vehicle_repository_id
	           AND pvr.registration_number='''||p_veh_reg||'''
                   AND pva.assignment_id='||p_assignment_id||
                   ' AND pva.business_group_id='||p_business_group_id||
                   ' AND pva.business_group_id=pvr.business_group_id
                   AND pvr.vehicle_ownership=''P''
                   AND '''||l_car_type ||''' in (''C'',''E'')
                   AND ( default_vehicle=''Y'' or  default_vehicle IS NULL
                       OR default_vehicle=''N'')
                   AND '''|| l_temp_effective_date ||''' BETWEEN pva.effective_start_date
                        AND pva.effective_end_date
                   AND '''|| l_temp_effective_date ||''' BETWEEN pvr.effective_start_date
                        AND pvr.effective_end_date' ;*/

 OPEN c_get_attr_val(p_veh_reg, p_assignment_id, p_business_group_id, l_car_type, l_temp_effective_date);
  LOOP
   FETCH c_get_attr_val INTO l_get_attr_val;
   EXIT WHEN c_get_attr_val%NOTFOUND;
    IF l_get_attr_val.calculation_method IS NULL THEN
     l_str_info :='SELECT pcv_information1 calculation_method
                    FROM pqp_configuration_values pcv
                   WHERE pcv_information_category=''PQP_VEHICLE_MILEAGE''
                     AND pcv.legislation_code=''GB''
                     AND NOT EXISTS (SELECT ''X''
                     FROM pqp_configuration_values pcv1
                    WHERE pcv1.business_group_id='||p_business_group_id ||'
		    -- added to check for this info category only (5632627)
		      AND pcv1.pcv_information_category=''PQP_VEHICLE_MILEAGE'')
                   UNION
                   SELECT pcv_information1 calculation_method
                     FROM pqp_configuration_values pcv
                    WHERE pcv_information_category=''PQP_VEHICLE_MILEAGE''
                      AND pcv.business_group_id='||p_business_group_id;

     OPEN c_get_config_info FOR l_str_info;
      LOOP
       FETCH c_get_config_info INTO l_get_config_info;
       EXIT WHEN c_get_config_info%NOTFOUND;
      END LOOP;
     CLOSE c_get_config_info;
     IF l_car_type <> 'P'OR l_car_type<>'S' THEN
      IF l_get_attr_val.default_vehicle='Y' THEN
       EXIT;
      END IF;
     END IF;
    END IF;
  END LOOP;
 CLOSE c_get_attr_val;
 IF l_get_attr_val.rates_table_id IS NOT NULL THEN
  OPEN c_get_table_name (l_get_attr_val.rates_table_id);
   FETCH c_get_table_name INTO l_rates_table_name;
  CLOSE c_get_table_name;
 ELSE
  l_str :='SELECT  pcv.pcv_information5 rates_type
             FROM pqp_configuration_values pcv
             WHERE business_group_id='||p_business_group_id||
               ' AND pcv.pcv_information_category=''GB_VEHICLE_CALC_INFO''
               AND (pcv_information2='||'''||l_car_type||'''||
               ' OR pcv_information2 IS NULL)
               AND (pcv_information3='||'''||l_get_attr_val.vehicle_type||'''||'
                OR pcv_information3 IS NULL)
               AND (pcv_information4='||'''||l_get_attr_val.fuel_type||'''||
               ' OR pcv_information4 IS NULL)
               AND pcv.pcv_information5 IS NOT NULL';
  OPEN c_get_config_rt FOR l_str;
   FETCH c_get_config_rt INTO l_get_config_rates;
  CLOSE c_get_config_rt;

  OPEN c_get_table_name (to_number(l_get_config_rates.rates_type));
   FETCH c_get_table_name INTO l_rates_table_name;
  CLOSE c_get_table_name;

 END IF;
 p_cc          :=NVL(l_get_attr_val.engine_capacity_in_cc,-1);
 p_calc_method :=NVL(NVL(l_get_attr_val.calculation_method,
                       l_get_config_info.calculation_method),'NE');
 p_fuel_type   :=l_get_attr_val.fuel_type;
 p_rates_table:=l_rates_table_name;
-- IF l_veh_typ<>l_vehicle_type AND l_veh_typ IS NOT NULL THEN
--  l_err_num:=-1;
-- END IF;
 --IF l_err_num=-1 THEN
 -- p_error_msg := 'TYPERR';
-- RETURN -1;
-- ELSE
  p_error_msg :=  'SUCCESS';
 RETURN 0;
-- END IF;

END IF;

EXCEPTION

WHEN NO_DATA_FOUND THEN

  -- added by tmehra for nocopy changes.
  p_cc                 := -1;
  p_rates_table        := NULL;
  p_calc_method        := NULL;
  p_fuel_type          := NULL;

  p_error_msg := 'Error - Unable to find Table or Vehicle';
  RETURN -1;

WHEN OTHERS THEN
  -- added by tmehra for nocopy changes.
  p_cc                 := -1;
  p_rates_table        := NULL;
  p_calc_method        := NULL;
  p_fuel_type          := NULL;

  p_error_msg := 'Error - Unable to find Table or Vehicle';
  RETURN -1;
END pqp_get_attr_val;

-----------------------------------------------------------------------------
-- FUNCTION PQP_GET_PERIOD
-- This function will return the number of pay periods for a given claim date.
-----------------------------------------------------------------------------
FUNCTION  pqp_get_period(      p_assignment_id      IN  NUMBER
                              ,p_business_group_id  IN  NUMBER
                              ,p_payroll_id         IN  NUMBER
                              ,p_payroll_action_id  IN  NUMBER
                              ,p_claim_date         IN  DATE
                              ,p_period_num         OUT NOCOPY NUMBER)
RETURN NUMBER IS

  CURSOR period_type IS
   SELECT  period_type
     FROM per_time_periods
    WHERE payroll_id = p_payroll_id;

  CURSOR period_cur(pdate DATE)  IS
   SELECT period_num, period_type,start_date,end_date
     FROM per_time_periods
    WHERE payroll_id = p_payroll_id
      AND pdate
  BETWEEN start_date AND end_date;

  CURSOR max_period (pdate DATE) IS
  SELECT period_num
   FROM per_time_periods
  WHERE payroll_id=p_payroll_id
    AND end_date >=pdate
  ORDER BY end_date;

 l_period_num           per_time_periods.period_num%TYPE;
 l_period_type          per_time_periods.period_type%TYPE;
 l_multiple             NUMBER;
 l_base_period_type     VARCHAR2(100);
 l_periods              NUMBER;
 l_start_date           DATE;
 l_end_date             DATE;
 l_fiscal_year_begin    DATE;
 l_date                 DATE;
 l_max_period           NUMBER:=0;
 c_max_period           max_period%ROWTYPE;
 l_max_period_num       NUMBER;
 l_periodtype           per_time_periods.period_type%TYPE;
 l_effective_date       DATE;
 BEGIN
 l_effective_date :=TRUNC(pqp_car_mileage_functions.
                        pqp_get_date_paid(p_payroll_action_id));
  OPEN period_type;
   LOOP
    FETCH period_type INTO l_periodtype;
    EXIT WHEN period_type%NOTFOUND;
   END LOOP;
  CLOSE period_type;

 /*Gets the multiple factor to divide period */
 hr_payrolls.get_period_details( p_proc_period_type => l_periodtype
                                   ,p_base_period_type => l_base_period_type
                                   ,p_multiple         => l_multiple);

  IF p_claim_date=to_date('01/01/1900','DD/MM/RRRR') THEN
    l_date:=l_effective_date;
  OPEN period_cur(l_date);
   LOOP
    FETCH period_cur INTO l_period_num,l_period_type,l_start_date,l_end_date;
    EXIT WHEN period_cur%NOTFOUND;
   END LOOP;
  CLOSE period_cur;

    OPEN max_period(l_date);
    LOOP
    FETCH max_period INTO c_max_period;
    EXIT WHEN max_period%NOTFOUND;
     IF l_max_period > c_max_period.period_num THEN
       EXIT;
     ELSE
       l_max_period :=c_max_period.period_num;
     END IF;
    END LOOP;
    CLOSE max_period;

    p_period_num:=l_max_period/l_multiple;
    RETURN(l_period_num/l_multiple);

  ELSIF (p_claim_date >=TO_DATE('01/04/'||TO_CHAR(TRUNC(p_claim_date),'RRRR'),'DD/MM/RRRR')
          AND    p_claim_date < TO_DATE('06/04/'||TO_CHAR(TRUNC(p_claim_date),'RRRR'),'DD/MM/RRRR'))
    AND l_effective_date >=TO_DATE('06/04/'||TO_CHAR(TRUNC(p_claim_date),'RRRR'),'DD/MM/RRRR') THEN

      SELECT MAX(period_num) INTO l_max_period_num
        FROM  per_time_periods
       WHERE payroll_id = p_payroll_id
        AND  end_date >= ADD_MONTHS(to_date('06/04/'||TO_CHAR(TRUNC(p_claim_date),'RRRR'),'DD/MM/RRRR'),-6)
        AND end_date <= to_date('06/04/'||TO_CHAR(TRUNC(p_claim_date),'RRRR'),'DD/MM/RRRR');

       p_period_num:=l_max_period_num/l_multiple;
       RETURN(l_max_period_num)/l_multiple;

  ELSIF  p_claim_date  < TO_DATE('01/04/'||TO_CHAR(TRUNC(p_claim_date),'RRRR'),'DD/MM/RRRR')
    AND l_effective_date >=TO_DATE('6/04/'||TO_CHAR(TRUNC(p_claim_date),'RRRR'),'DD/MM/RRRR')THEN

       OPEN max_period(p_claim_date);
        LOOP
         FETCH max_period INTO c_max_period;
         EXIT WHEN max_period%NOTFOUND;
         IF l_max_period_num > c_max_period.period_num THEN
           EXIT;
         ELSE
           l_max_period_num :=c_max_period.period_num;
         END IF;
        END LOOP;
       CLOSE max_period;
       p_period_num:=l_max_period_num/l_multiple;
       RETURN(l_max_period_num)/l_multiple;
  ELSE
       l_date:=l_effective_date;


  OPEN period_cur(l_date);
   LOOP
    FETCH period_cur INTO l_period_num,l_period_type,l_start_date,l_end_date;
     EXIT WHEN period_cur%NOTFOUND;
    END LOOP;
  CLOSE period_cur;

   OPEN max_period(l_date);
    LOOP
    FETCH max_period INTO c_max_period;
    EXIT WHEN max_period%NOTFOUND;
      IF l_max_period > c_max_period.period_num THEN
       EXIT;
      ELSE
       l_max_period :=c_max_period.period_num;
      END IF;
    END LOOP;
   CLOSE max_period;

   p_period_num:=l_max_period/l_multiple;
   RETURN(l_period_num)/l_multiple;
   END IF;

-- Added by tmehra for nocopy changes Feb'03

EXCEPTION
    WHEN OTHERS THEN
       p_period_num := NULL;
       raise;


END pqp_get_period;
-----------------------------------------------------------------------------
-- FUNCTION PQP_GET_VEH_CC
-----------------------------------------------------------------------------
FUNCTION  pqp_get_veh_cc(      p_assignment_id      IN  NUMBER
                              ,p_business_group_id  IN  NUMBER
                              ,p_reg_num            IN  VARCHAR2)
RETURN NUMBER IS

CURSOR veh_cur IS
SELECT engine_capacity_in_cc
  FROM pqp_vehicle_details
 WHERE registration_number = p_reg_num;

l_veh_cc      NUMBER;

BEGIN

OPEN veh_cur;

   FETCH veh_cur INTO l_veh_cc;

    IF veh_cur%ROWCOUNT = 0 THEN
      -- Message and Exception
       CLOSE veh_cur;
       RETURN -1;
    ELSIF veh_cur%ROWCOUNT > 0 THEN
       CLOSE veh_cur;
       RETURN(l_veh_cc);
    END IF;
EXCEPTION
   WHEN OTHERS THEN
      RETURN -1;
END pqp_get_veh_cc;

-----------------------------------------------------------------------------
-- FUNCTION PQP_GET_YEAR
-----------------------------------------------------------------------------
FUNCTION  pqp_get_year(        p_assignment_id      IN  NUMBER
                              ,p_business_group_id  IN  NUMBER
                              ,p_payroll_action_id  IN  NUMBER
                              ,p_claim_date         IN  DATE)
RETURN VARCHAR2 IS

l_mod_value           NUMBER;
l_fiscal_year_begin   DATE;
l_fiscal_year_end     DATE;
l_cur_year            VARCHAR2(5);
l_year 	              NUMBER;
l_claim_date          DATE;

BEGIN

-- This was done because Formula Functions do not accept NULL
-- for input. If the claim date is 1/01/1900 then claim date = date earned
IF TO_CHAR(TRUNC(p_claim_date),'DD/MM/YYYY') = '01/01/1900' THEN
  l_claim_date := TRUNC(pqp_car_mileage_functions.
                   pqp_get_date_paid(p_payroll_action_id));
ELSE
  l_claim_date := p_claim_date;
END IF;

l_cur_year          := TO_CHAR(TRUNC(l_claim_date),'RRRR');
l_fiscal_year_begin := TO_DATE(('6/04/'||l_cur_year),'DD/MM/RRRR');
l_fiscal_year_end   := TO_DATE(('5/04/'||(TO_NUMBER(l_cur_year)+1)),'DD/MM/RRRR');

IF TRUNC(l_claim_date) BETWEEN l_fiscal_year_begin
                       AND l_fiscal_year_end THEN
     l_year := TO_NUMBER(l_cur_year)+1;
ELSIF l_claim_date < l_fiscal_year_begin THEN
     l_year := TO_NUMBER(l_cur_year);
END IF;

l_mod_value := MOD(l_year,2);

   IF    l_mod_value = 1 THEN
      RETURN('O');
   ELSIF l_mod_value = 0 THEN
      RETURN('E');
   END IF;

EXCEPTION

WHEN VALUE_ERROR THEN
   RETURN('-1');

END pqp_get_year;

-----------------------------------------------------------------------------
-- FUNCTION PQP_MULTIPLE_ASG
-----------------------------------------------------------------------------
FUNCTION  pqp_multiple_asg(    p_assignment_id      IN  NUMBER
                              ,p_business_group_id  IN  NUMBER
                              ,p_payroll_action_id  IN  NUMBER)
RETURN VARCHAR2 IS

l_start_date         DATE;
l_end_date           DATE;
l_fiscal_year_begin  DATE;
l_fiscal_year_end    DATE;
l_cur_year           VARCHAR2(5);
l_asg_year           VARCHAR2(5);
l_person_id	     PER_ASSIGNMENTS_F.person_id%TYPE;
l_dummy              VARCHAR2(1);
l_effective_date     DATE;

BEGIN
l_effective_date :=TRUNC(pqp_car_mileage_functions.
                    pqp_get_date_paid(p_payroll_action_id));
-- Get the current fiscal year
-- Specific only to GB hence the dates are hard coded


RETURN('TRUE');


END pqp_multiple_asg;

-----------------------------------------------------------------------------
-- FUNCTION PQP_GET_TABLE_VALUE
-----------------------------------------------------------------------------
FUNCTION pqp_get_table_value ( p_bus_group_id      IN NUMBER
                              ,p_payroll_action_id IN NUMBER
                              ,p_table_name        IN VARCHAR2
                              ,p_col_name          IN VARCHAR2
                              ,p_row_value         IN VARCHAR2
                              ,p_effective_date    IN DATE  DEFAULT NULL
                              ,p_error_msg         OUT NOCOPY VARCHAR2)
RETURN VARCHAR2 IS

--**********************************************************
-- BEGIN Code from original package HRUSERDT.GET_TABLE_VALUE
-- Added code to handle exceptions and return SUCCESS or ERROR
-- Change made by vjhanak
--**********************************************************

l_effective_date    DATE;
l_range_or_match    PAY_USER_TABLES.range_or_match%TYPE;
l_table_id          PAY_USER_TABLES.user_table_id%TYPE;
l_value             PAY_USER_COLUMN_INSTANCES_F.value%TYPE;
g_leg_code          VARCHAR2(2);
cached              BOOLEAN  := FALSE;
g_effective_date    DATE := NULL;

CURSOR c_fuel_type (cp_lcode VARCHAR2) IS
SELECT hrl.meaning
 FROM  hr_lookups hrl
WHERE  hrl.lookup_code = cp_lcode
  AND  hrl.application_id=800
  AND  lookup_type='PQP_FUEL_TYPE';

l_fuel_type c_fuel_type%ROWTYPE;

BEGIN

-- This is done because in the formula functions NULL
-- is not a valid input.
-- If Effective date is null assign date earned to effective date
 IF TO_CHAR(TRUNC(p_effective_date),'DD/MM/YYYY') = '01/01/1900' THEN
  l_effective_date := trunc(pqp_car_mileage_functions.
                        pqp_get_date_paid(p_payroll_action_id));
 ELSE
  l_effective_date := p_effective_date;
 END IF;





    -- get the legislation code:
    --
    BEGIN
        hr_utility.set_location (' pqp_get_table_value', 2);
        IF cached = FALSE THEN
          SELECT legislation_code
          INTO   g_leg_code
          FROM   per_business_groups
          WHERE  business_group_id = p_bus_group_id;
          cached := TRUE;
        END IF;
    END;
    --
    -- get the type of query to be performed, either range or match
    --
    hr_utility.set_location ('hruserdt.get_table_value', 3);
    SELECT range_or_match, user_table_id
    INTO   l_range_or_match, l_table_id
    FROM   pay_user_tables
    WHERE  upper(user_table_name) = upper(p_table_name)
    AND    nvl (business_group_id,
                p_bus_group_id)   = p_bus_group_id
    AND    nvl(legislation_code, g_leg_code) = g_leg_code;
    --
    IF (l_range_or_match = 'M') THEN       -- matched
      BEGIN
        hr_utility.set_location ('hruserdt.get_table_value', 4);
       SELECT  CINST.value
        INTO    l_value
        FROM    pay_user_column_instances_f        CINST
        ,       pay_user_columns                   C
        ,       pay_user_rows_f                    R
        ,       pay_user_tables                    TAB
        WHERE   TAB.user_table_id                = l_table_id
        AND     C.user_table_id                  = TAB.user_table_id
        AND     nvl (C.business_group_id,
                     p_bus_group_id)            = p_bus_group_id
        AND     nvl (C.legislation_code,
                     g_leg_code)                 = g_leg_code
        AND     upper (C.user_column_name)       = upper (p_col_name)
        AND     CINST.user_column_id             = C.user_column_id
        AND     R.user_table_id                  = TAB.user_table_id
        AND     l_effective_date           between R.effective_start_date
        AND     R.effective_end_date
        AND     nvl (R.business_group_id,
                     p_bus_group_id)             = p_bus_group_id
        AND     nvl (R.legislation_code,
                     g_leg_code)                 = g_leg_code
        AND     decode
                (TAB.user_key_units,
                 'D', to_char(fnd_date.canonical_to_date(p_row_value)),
                 'N',replace(replace( upper(p_row_value),'_',' '),' '),
                 'T', replace(replace(upper (p_row_value),'_',' '),' '),
                 null) =
                decode
                (TAB.user_key_units,
                 'D', to_char(fnd_date.canonical_to_date(R.row_low_range_or_name)),
                 'N', replace(replace(upper(R.row_low_range_or_name),'_',' '),' '),
                 'T', replace(replace(upper (R.row_low_range_or_name),'_',' '),' '),
                 null)
        AND     CINST.user_row_id                = R.user_row_id
        AND     l_effective_date           between CINST.effective_start_date
        AND     CINST.effective_end_date
        AND     nvl (CINST.business_group_id,
                     p_bus_group_id)             = p_bus_group_id
        AND     nvl (CINST.legislation_code,
                     g_leg_code)                 = g_leg_code;
      --
        p_error_msg := 'SUCCESS';
        RETURN l_value;
      EXCEPTION
      WHEN OTHERS THEN
       BEGIN
        OPEN c_fuel_type (p_row_value);
         FETCH c_fuel_type INTO l_fuel_type;
        CLOSE c_fuel_type;

       SELECT  CINST.value
        INTO    l_value
        FROM    pay_user_column_instances_f        CINST
        ,       pay_user_columns                   C
        ,       pay_user_rows_f                    R
        ,       pay_user_tables                    TAB
        WHERE   TAB.user_table_id                = l_table_id
        AND     C.user_table_id                  = TAB.user_table_id
        AND     nvl (C.business_group_id,
                     p_bus_group_id)            = p_bus_group_id
        AND     nvl (C.legislation_code,
                     g_leg_code)                 = g_leg_code
        AND     upper (C.user_column_name)       = upper (p_col_name)
        AND     CINST.user_column_id             = C.user_column_id
        AND     R.user_table_id                  = TAB.user_table_id
        AND     l_effective_date           between R.effective_start_date
        AND     R.effective_end_date
        AND     nvl (R.business_group_id,
                     p_bus_group_id)             = p_bus_group_id
        AND     nvl (R.legislation_code,
                     g_leg_code)                 = g_leg_code
        AND     decode
                (TAB.user_key_units,
                 'D', to_char(fnd_date.canonical_to_date(l_fuel_type.meaning)),
                 'T', replace(replace(upper (l_fuel_type.meaning),'_',' '),' '),
                 null) =
                decode
                (TAB.user_key_units,
                 'D', to_char(fnd_date.canonical_to_date(R.row_low_range_or_name)),
                 'N', replace(replace(upper(R.row_low_range_or_name),'_',' '),' '),
                 'T', replace(replace(upper (R.row_low_range_or_name),'_',' '),' '),
                 null)
        AND     CINST.user_row_id                = R.user_row_id
        AND     l_effective_date           between CINST.effective_start_date
        AND     CINST.effective_end_date
        AND     nvl (CINST.business_group_id,
                     p_bus_group_id)             = p_bus_group_id
        AND     nvl (CINST.legislation_code,
                     g_leg_code)                 = g_leg_code;
        p_error_msg := 'SUCCESS';
        RETURN l_value;
       EXCEPTION
       WHEN OTHERS THEN
         p_error_msg := 'ERROR';
         RETURN('-1');
       END;
      END;
    ELSE                                   -- range
      BEGIN
    hr_utility.set_location ('hruserdt.get_table_value', 5);
        select  CINST.value
        into    l_value
        from    pay_user_column_instances_f        CINST
        ,       pay_user_columns                   C
        ,       pay_user_rows_f                    R
        ,       pay_user_tables                    TAB
        where   TAB.user_table_id                = l_table_id
        and     C.user_table_id                  = TAB.user_table_id
        and     nvl (C.business_group_id,
                     p_bus_group_id)             = p_bus_group_id
        and     nvl (C.legislation_code,
                     g_leg_code)                 = g_leg_code
        and     upper (C.user_column_name)       = upper (p_col_name)
        and     CINST.user_column_id             = C.user_column_id
        and     R.user_table_id                  = TAB.user_table_id
        and     l_effective_date           between R.effective_start_date
        and     R.effective_end_date
        and     nvl (R.business_group_id,
                     p_bus_group_id)             = p_bus_group_id
        and     nvl (R.legislation_code,
                     g_leg_code)                 = g_leg_code
        and     fnd_number.canonical_to_number (p_row_value)
        between fnd_number.canonical_to_number (R.row_low_range_or_name)

        and     fnd_number.canonical_to_number (R.row_high_range)
        and     TAB.user_key_units               = 'N'
        and     CINST.user_row_id                = R.user_row_id
        and     l_effective_date           between CINST.effective_start_date
        and     CINST.effective_end_date
        and     nvl (CINST.business_group_id,
                     p_bus_group_id)             = p_bus_group_id
        and     nvl (CINST.legislation_code,
                     g_leg_code)                 = g_leg_code;
        --
        p_error_msg := 'SUCCESS';
        return l_value;

      EXCEPTION
      WHEN OTHERS THEN
         p_error_msg := 'ERROR';
         RETURN('-1');
      end;
    end if;

      EXCEPTION
      WHEN OTHERS THEN
         p_error_msg := 'ERROR';
         RETURN('-1');
--
--********************************************************--
-- END Code from original package HRUSERDT.GET_TABLE_VALUE
-- Added code to handle exceptions and return SUCCESS or ERROR
-- Change made by vjhanak
--********************************************************--
END pqp_get_table_value;

-----------------------------------------------------------------------------
-- PQP_CHECK_RATES_TABLE
-----------------------------------------------------------------------------
FUNCTION  pqp_check_rates_table(p_business_group_id  IN  NUMBER
                               ,p_table_name         IN  VARCHAR2)
RETURN VARCHAR2 IS

l_dummy      VARCHAR2(1);

BEGIN
SELECT 'x'
  INTO l_dummy
  FROM pay_user_tables
 WHERE user_table_name    = p_table_name
   AND (business_group_id = p_business_group_id OR legislation_code is NOT NULL)
   AND rownum = 1;

RETURN ('S');

EXCEPTION
   WHEN NO_DATA_FOUND THEN
   RETURN ('E');

END pqp_check_rates_table;

-----------------------------------------------------------------------------
-- PQP_VALIDATE_DATE
-----------------------------------------------------------------------------
FUNCTION  pqp_validate_date(p_date_earned          IN  DATE
                           ,p_claim_end_date       IN  DATE)
RETURN VARCHAR2 IS

l_begin_year    NUMBER;
l_begin_date    DATE;

BEGIN

   IF p_date_earned < to_date('06/04/'||to_char(p_date_earned,'YYYY'),'DD/MM/YYYY') THEN
      l_begin_year := to_number(to_char(p_date_earned, 'yyyy')) - 1;
   ELSE
      l_begin_year := to_number(to_char(p_date_earned, 'yyyy'));
   END IF;
   --
   -- Set expired date to the 6th of April next.
   --
   l_begin_date := to_date('06/04/' || to_char(l_begin_year), 'DD/MM/YYYY');
   --
   IF p_date_earned > to_date('05/07/'||to_char(l_begin_date,'yyyy'),'dd/mm/yyyy') AND
      p_claim_end_date < l_begin_date THEN
      RETURN ('E');
   ELSE
      RETURN('S');
   END IF;

END pqp_validate_date;


------------------------------------------------------------------------

--Function  Max_Limit_Calc
/*This function determines whether the element for proration calculation
  needs to be end dated based on max rate reached for that fiscal year*/
------------------------------------------------------------------------
 FUNCTION Max_limit_calc (               p_assignment_id     IN NUMBER
                                        ,p_bg_id             IN NUMBER
                                        ,p_payroll_action_id IN NUMBER
                                        ,p_prorated_mileage  IN NUMBER
                                        ,p_cc                IN NUMBER
                                        ,p_claim_date        IN date
                                        ,p_total_period      IN NUMBER
                                        ,p_cl_period         IN NUMBER
                                        ,p_rates_table       IN VARCHAR2

                                          )

   Return Varchar2 as
   l_ltemp_mileage NUMBER:=0;
   l_htemp_mileage NUMBER:=0;
   l_mile          NUMBER:=0;
   l_pro_mile      NUMBER:=0;
   lband           NUMBER:=0;
   l_hp_mileage    NUMBER:=0;
   hi_hp_mileage   NUMBER:=0;

   l_effective_date DATE;
Begin
l_effective_date :=trunc(pqp_car_mileage_functions.
                   pqp_get_date_paid(p_payroll_action_id));
   IF p_cl_period=p_total_period THEN
    RETURN('Y');
   ELSIF l_effective_date >TO_DATE('05/04/'||to_char(l_effective_date,'RRRR'),'DD/MM/RRRR') AND
         p_claim_date < TO_DATE('06/04/'||to_char(l_effective_date,'RRRR'),'DD/MM/RRRR') THEN
     RETURN('Y');
   END IF;

    l_mile:=(p_prorated_mileage*p_cl_period)/ p_total_period;

    FOR i in p_cl_period..p_total_period
    LOOP
    l_pro_mile:=(l_mile*p_total_period)/i;
    lband := pqp_car_mileage_functions.pqp_get_range( p_assignment_id
                                                      , p_bg_id
                                                      , p_payroll_action_id
                                                      , p_rates_table
                                                      , 'ROW'
                                                      , l_pro_mile
                                                      , p_claim_date
                                                      , l_hp_mileage
                                                      , hi_hp_mileage);


       IF  l_ltemp_mileage =0  AND l_htemp_mileage=0 THEN

         l_ltemp_mileage:=l_hp_mileage;
         l_htemp_mileage:=hi_hp_mileage;

       Else
         IF l_ltemp_mileage<>l_hp_mileage
                   AND l_htemp_mileage<>hi_hp_mileage THEN
           RETURN('N');
           exit;
         END IF;
       END IF;

   END LOOP;
    RETURN('Y');
END;



---------------------------------------------------------------------
--Function PRORATE_CALC Returns prorate calculated Amt
------------------------------------------------------------------------
 FUNCTION pqp_prorate_calc(                 p_assignment_id     IN NUMBER
                                           ,p_bg_id             IN NUMBER
                                           ,p_payroll_action_id IN NUMBER
                                           ,p_prorated_mileage  IN NUMBER
                                           ,p_cc                IN NUMBER
                                           ,p_claim_date        IN date
                                           ,p_total_period      IN NUMBER
                                           ,p_cl_period         IN NUMBER
                                           ,p_rates_table       IN VARCHAR2
                                           ,p_lower_pro_mileage IN NUMBER
                                           ,p_end_date          IN OUT NOCOPY VARCHAR2)
RETURN NUMBER IS

   h_mileage     VARCHAR2(20);
   lh_mileage    VARCHAR2(20);
   err_msg       VARCHAR2(60);
   lband         NUMBER:=0;
   l_mileage     NUMBER:=0;
   hi_mileage    NUMBER:=0;
   tot_rate      NUMBER:=0;
   l_value       NUMBER:=0;
   ll_value      NUMBER:=0;
   l_rate        NUMBER:=0;
   ch_col        VARCHAR2(10);
   e_same_val    EXCEPTION;
   l_hp_mileage  NUMBER:=0;
   hi_hp_mileage NUMBER:=0;
   l_end_date    Varchar2(10):='NONE';
   l_effective_date DATE;

-- nocopy changes
  l_end_date_nc  VARCHAR2(20);

BEGIN
   --
   l_end_date_nc := p_end_date;

 l_effective_date :=TRUNC(pqp_car_mileage_functions.
                    pqp_get_date_paid(p_payroll_action_id));
  IF NVL(p_end_date,'NO') <> 'NONE' THEN

    p_end_date:= Max_limit_calc (          p_assignment_id
                                          ,p_bg_id
                                          ,p_payroll_action_id
                                          ,p_prorated_mileage
                                          ,p_cc
                                          ,p_claim_date
                                          ,p_total_period
                                          ,p_cl_period
                                          ,p_rates_table

                                          );

  END IF;

       lband := pqp_car_mileage_functions.pqp_get_range( p_assignment_id
                                                      , p_bg_id
                                                      ,p_payroll_action_id
                                                      , p_rates_table
                                                      , 'ROW'
                                                      , p_lower_pro_mileage
                                                      , p_claim_date
                                                      , l_mileage
                                                      , hi_mileage);

      lband := pqp_car_mileage_functions.pqp_get_range( p_assignment_id
                                                      , p_bg_id
                                                      ,p_payroll_action_id
                                                      , p_rates_table
                                                      , 'ROW'
                                                      , p_prorated_mileage
                                                      , p_claim_date
                                                      , l_hp_mileage
                                                      , hi_hp_mileage);



   IF l_mileage=hi_mileage AND l_mileage<>0 AND hi_mileage<>0 THEN
      RAISE e_same_val;
   END IF;
   --
   ch_col   :=to_char(p_cc);
/*Positive claim*/
   IF p_prorated_mileage >= p_lower_pro_mileage THEN

      IF hi_mileage=l_hp_mileage or
      (l_mileage=l_hp_mileage and hi_mileage=hi_hp_mileage) THEN
       --
         h_mileage:=to_char(hi_hp_mileage);
         lh_mileage:=to_char(hi_mileage);
         l_value:=pqp_car_mileage_functions.pqp_get_table_value(p_bg_id
                                                       ,p_payroll_action_id
                                                       ,p_rates_table
                                                       ,ch_col
                                                       ,h_mileage
                                                       ,p_claim_date
                                                       ,err_msg);
       ll_value:=pqp_car_mileage_functions.pqp_get_table_value(p_bg_id
                                                       ,p_payroll_action_id
                                                       ,p_rates_table
                                                       ,ch_col
                                                       ,lh_mileage
                                                       ,p_claim_date
                                                       ,err_msg);

       RETURN (((((p_prorated_mileage-l_hp_mileage)*l_value)*p_cl_period)/p_total_period) +
             (((l_hp_mileage-p_lower_pro_mileage)*p_cl_period)/p_total_period)*ll_value);
     ELSE
       h_mileage:=to_char(hi_hp_mileage);
       l_value:=pqp_car_mileage_functions.pqp_get_table_value(p_bg_id
                                                        ,p_payroll_action_id
                                                        ,p_rates_table
                                                        ,ch_col
                                                        ,h_mileage
                                                        ,p_claim_date
                                                        ,err_msg);

       tot_rate:= (((p_prorated_mileage-l_hp_mileage)*l_value)*p_cl_period)/
                     p_total_period;

       l_rate :=  pqp_prorate_calc( p_assignment_id
                                         ,p_bg_id
                                         ,p_payroll_action_id
                                         ,l_hp_mileage
                                         ,p_cc
                                         ,p_claim_date
                                         ,p_total_period
                                         ,p_cl_period
                                         ,p_rates_table
                                          ,p_lower_pro_mileage
                                         , l_end_date);
       return(tot_rate +l_rate);

   END IF;

 END IF;

/*For negative Claim */

   IF p_prorated_mileage < p_lower_pro_mileage THEN



      IF hi_hp_mileage=l_mileage
      OR (l_mileage=l_hp_mileage and hi_mileage=hi_hp_mileage) THEN

       --
       h_mileage:=to_char(hi_mileage);
       lh_mileage:=to_char(hi_hp_mileage);
       l_value:=pqp_car_mileage_functions.pqp_get_table_value(p_bg_id
                                                       ,p_payroll_action_id
                                                       ,p_rates_table
                                                       ,ch_col
                                                       ,h_mileage
                                                       ,p_claim_date
                                                       ,err_msg);
       ll_value:=pqp_car_mileage_functions.pqp_get_table_value(p_bg_id
                                                       ,p_payroll_action_id
                                                       ,p_rates_table
                                                       ,ch_col
                                                       ,lh_mileage
                                                       ,p_claim_date
                                                       ,err_msg);

       RETURN (-1*(((((p_lower_pro_mileage-l_mileage)*l_value)*p_cl_period)/p_total_period) +
             (((l_mileage-p_prorated_mileage)*p_cl_period)/p_total_period)*ll_value));
   ELSE

       h_mileage:=to_char(hi_mileage);
       l_value:=pqp_car_mileage_functions.pqp_get_table_value(p_bg_id
                                                        ,p_payroll_action_id
                                                        ,p_rates_table
                                                        ,ch_col
                                                        ,h_mileage
                                                        ,p_claim_date
                                                        ,err_msg);

       tot_rate:= (((p_lower_pro_mileage-l_mileage)*l_value)*p_cl_period)/
                     p_total_period;

       l_rate :=  pqp_prorate_calc( p_assignment_id
                                         ,p_bg_id
                                         ,p_payroll_action_id
                                         ,p_prorated_mileage
                                         ,p_cc
                                         ,p_claim_date
                                         ,p_total_period
                                         ,p_cl_period
                                         ,p_rates_table
                                          ,l_mileage
                                         , l_end_date);
       return(-1*(tot_rate -l_rate));

   END IF;

  END IF;

   EXCEPTION
   WHEN e_same_val THEN
   p_end_date := l_end_date_nc;
   RETURN(0);

   WHEN OTHERS THEN
   -- Added by tmehra for nocopy changes
   p_end_date := l_end_date_nc;
   RETURN(0);

END;

-------------------------------------------------------------

FUNCTION pqp_get_taxni_rates (  p_assignment_id           IN  NUMBER
                               ,p_business_group_id       IN  NUMBER
                               ,p_payroll_action_id       IN  NUMBER
                               ,p_itd_ac_miles            IN  NUMBER
                               ,p_actual_mileage          IN  NUMBER
                               ,p_total_actual_mileage    IN  NUMBER
                               ,p_ele_iram_itd            IN NUMBER
                               ,p_cc                      IN  NUMBER
                               ,p_claim_end_date          IN  DATE
                               ,p_two_wheeler_type        IN  VARCHAR2
                               ,p_wheeler_type            IN  VARCHAR2
                               ,p_table_name              IN  VARCHAR2
                               ,p_ele_iram_amt            OUT NOCOPY NUMBER
                               ,p_error_mesg              OUT NOCOPY VARCHAR2)
RETURN NUMBER AS
l_veh_cc                                   varchar2(10);
ch_irh_mileage_band                        VARCHAR2(15);
return_result                              NUMBER;
irl_mileage_band                           NUMBER;
irh_mileage_band                           NUMBER;
hi_flag                                    VARCHAR2(1):='N';
irlo_mileage_band                          NUMBER;
irhi_mileage_band                          NUMBER;
ch_irhi_mileage_band                       VARCHAR2(15);
lo_cc                                      number;
hi_cc                                      NUMBER;
chi_cc                                     VARCHAR2(15);
iram_rate                                  NUMBER;
iram_rate_hi                               NUMBER;
tot_iram_amt                               NUMBER:=0;
err_msg                                    VARCHAR2(15);
l_effective_date                          DATE;
l_ret_value                                NUMBER;
l_ele_iram_itd                             NUMBER(11,2);
l_error_mesg                               VARCHAR2(80)    ;
BEGIN
 l_effective_date := TRUNC(pqp_car_mileage_functions.
                       pqp_get_date_paid(p_payroll_action_id));


IF p_itd_ac_miles=0 OR
     ( p_itd_ac_miles<>0 AND p_itd_ac_miles-p_actual_mileage<>0) THEN

      l_veh_cc:=to_char(p_cc);
--This is a new change that was done to handle  the issue for Tax balance which
--did not have an itd amount and to create a new itd balance would affect the
--existing customers so the entire amount is recalculated in case of correction
--and that amount is deducted from the new value.

   IF p_itd_ac_miles<>0 AND p_itd_ac_miles-p_actual_mileage<>0 THEN
    l_ret_value:=pqp_get_taxni_rates
                 ( p_assignment_id           =>p_assignment_id
                  ,p_business_group_id       =>p_business_group_id
                  ,p_payroll_action_id       =>p_payroll_action_id
                  ,p_itd_ac_miles            =>0
                  ,p_actual_mileage          =>p_itd_ac_miles
                  ,p_total_actual_mileage    =>p_total_actual_mileage-p_itd_ac_miles
                  ,p_ele_iram_itd            =>0
                  ,p_cc                      =>p_cc
                  ,p_claim_end_date          =>p_claim_end_date
                  ,p_two_wheeler_type        =>p_two_wheeler_type
                  ,p_wheeler_type            =>p_wheeler_type
                  ,p_table_name              =>p_table_name
                  ,p_ele_iram_amt            =>l_ele_iram_itd
                  ,p_error_mesg              =>l_error_mesg
                  );
   ELSE
    l_ele_iram_itd:=0;

   END IF;

   IF p_Two_wheeler_type <>'PP' AND p_Two_wheeler_type <>'PM' THEN

       return_result:=  pqp_car_mileage_functions.pqp_get_range (
                        p_assignment_id
                       ,p_business_group_id
                       ,p_payroll_action_id
                       ,p_table_name
                       ,'ROW'
                       ,p_total_actual_mileage- p_itd_ac_miles
                       ,p_claim_end_date
                       ,irl_mileage_band
                       ,irh_mileage_band);


      IF irh_mileage_band <
              (p_actual_mileage+(p_total_actual_mileage-p_itd_ac_miles))
                             THEN

         hi_flag:='Y';
        return_result:=  pqp_car_mileage_functions.pqp_get_range (
                         p_assignment_id
                        ,p_business_group_id
                        ,p_payroll_action_id
                        ,p_table_name
                        ,'ROW'
                        ,p_total_actual_mileage+p_actual_mileage
                        ,p_claim_end_date
                        ,irlo_mileage_band
                        ,irhi_mileage_band);

       ch_irhi_mileage_band:=to_char(irhi_mileage_band);
     END IF;
       ch_irh_mileage_band:=to_char(irh_mileage_band);

  ELSE

       ch_irh_mileage_band:=p_wheeler_type;
  END IF;

       return_result:=  pqp_car_mileage_functions.pqp_get_range (
                        p_assignment_id
                       ,p_business_group_id
                       ,p_payroll_action_id
                       ,p_table_name
                       ,'COL'
                       ,p_cc
                       ,p_claim_end_date
                       ,lo_cc
                       ,hi_cc);

     IF return_result=-1 AND
        (p_two_wheeler_type<>'PP' OR p_two_wheeler_type<>'PM' ) THEN

       p_error_mesg:='IRAM Rate Not Found';

     END IF;

     chi_cc:=to_char(hi_cc);

       iram_rate:=to_number( pqp_car_mileage_functions.pqp_get_table_value(
                             p_business_group_id
                            ,p_payroll_action_id
                            ,p_table_name
                            ,chi_cc
                            , ch_irh_mileage_band
                            , p_Claim_end_date,err_msg));
    IF hi_flag='Y' THEN

       iram_rate_hi:=to_number( pqp_car_mileage_functions.pqp_get_table_value(
                                p_business_group_id
                               ,p_payroll_action_id
                               ,p_table_name
                               ,chi_cc
                               , ch_irhi_mileage_band
                               , p_Claim_end_date,err_msg));
    END IF;

     IF err_msg='ERROR' THEN

       p_error_mesg:='No rate found for IRAM rate calculation';

    END IF;

   IF hi_flag='Y' THEN

          tot_iram_amt:=((irh_mileage_band
                      - p_total_actual_mileage)
                          *iram_rate
                  +
                 (p_total_actual_mileage+p_actual_mileage -
                         irh_mileage_band)
                   * iram_rate_hi)-l_ele_iram_itd;


   ELSE

         tot_iram_amt:=(p_actual_mileage) *iram_rate-l_ele_iram_itd;

  END IF;
 END IF;
         p_ele_iram_amt:=NVL(tot_iram_amt,0);
         RETURN(0);

-- Added by tmehra for nocopy changes Feb'03

EXCEPTION
    WHEN OTHERS THEN
       p_ele_iram_amt := NULL;
       p_error_mesg   := SQLERRM;
       raise;

END;



---------------------------
--This function will be used for paye taxable and company vehicles claims
--as we needed to add two more parameters for actual mileage and itd mileage
--for private vehicles.

FUNCTION  pqp_get_addlpasg_rate (  p_business_group_id         IN  NUMBER
                                  ,p_payroll_action_id         IN  NUMBER
                                  ,p_vehicle_type              IN  VARCHAR2
                                  ,p_claimed_mileage           IN  NUMBER
                                  ,p_itd_miles                 IN  NUMBER
                                  ,p_total_passengers          IN  NUMBER
                                  ,p_total_pasg_itd_val        IN  NUMBER
                                  ,p_cc                        IN  NUMBER
                                  ,p_rates_table               IN  VARCHAR2
                                  ,p_claim_end_date            IN  DATE
                                  ,p_tax_free_amt              OUT NOCOPY NUMBER
                                  ,p_ni_amt                    OUT NOCOPY NUMBER
                                  ,p_tax_amt                   OUT NOCOPY NUMBER
                                  ,p_err_msg                   OUT NOCOPY VARCHAR2)

RETURN number
AS
  chi_cc              VARCHAR2(15);
  chi_cc1             VARCHAR2(15);
  chi_cc_iram         VARCHAR2(15);
  addl_rate           NUMBER;
  addl_rate1          NUMBER;
  addl_ni_rate        NUMBER(9,2) :=0;
  addl_tax_rate       NUMBER(9,2) :=0;
  add_pasg_rate       NUMBER(9,2) :=0;
  cal_ni_rate         NUMBER(9,2) :=0;
  cal_tax_rate        NUMBER(9,2) :=0;
  l_low_value         NUMBER :=0;
  l_high_value        NUMBER :=0;
  l_ret_value         NUMBER :=0;
  l_high_val_ur1      NUMBER :=0;
  l_high_val_ur       NUMBER :=0;
  l_low_val_ur1        NUMBER :=0;
  l_low_val_ur        NUMBER :=0;
  l_effective_date    DATE;
  l_rates_table1      VARCHAR2(80);
  l_rates_table2      VARCHAR2(80);
  l_rates_table       VARCHAR2(160);
  l_length            NUMBER(9);
  l_err               VARCHAR2(10) := NULL;
  l_prev_ni_amt       NUMBER(9,2) :=0;
  l_prev_tax_amt      NUMBER(9,2) :=0;
  l_error_msg         VARCHAR2(80);
  l_ret_num           NUMBER :=0;
  l_rates_setting     VARCHAR2(1);
  l_correction        VARCHAR2(1) :='N';

BEGIN
 l_length :=0;
 BEGIN
  SELECT instr (p_rates_table,'+PLUS+',1 )
    INTO l_length
    FROM dual;
  EXCEPTION
  WHEN OTHERS THEN
   l_err :='NONE' ;
 END ;
 IF l_length <> 0 THEN
  l_rates_table2 := SUBSTR (p_rates_table,l_length+6);
  l_rates_table1 := SUBSTR (p_rates_table,0,l_length-1);
  l_rates_table2 := LTRIM(RTRIM(l_rates_table2));
  l_rates_table1 := LTRIM(RTRIM(l_rates_table1));
 ELSE
  l_rates_table1 := p_rates_table;
  l_rates_table2 := 'NONE';
 END IF;
 l_rates_setting :='N' ;
 IF p_total_pasg_itd_val <> 0
  AND ( p_total_pasg_itd_val - p_total_passengers) <> 0  AND l_rates_table2 <> 'NONE'
  AND l_err IS NULL THEN
  l_rates_setting := get_config_info (p_business_group_id,'Rates');
  IF l_rates_setting ='Y' THEN
   l_ret_value:=pqp_car_mileage_functions.pqp_get_range(
                     p_assignment_id     => 0
                    ,p_business_group_id => p_business_group_id
                    ,p_payroll_action_id => p_payroll_action_id
                    ,p_table_name        => l_rates_table2
                    ,p_row_or_column     => 'COL'
                    ,p_value             => p_cc
                    ,p_claim_date        => p_claim_end_date
                    ,p_low_value         => l_low_val_ur1
                    ,p_high_value        => l_high_val_ur1 );
   chi_cc1:=to_char(l_high_val_ur1);
   addl_rate1:=to_number(pqp_car_mileage_functions.pqp_get_table_value
                  (p_bus_group_id      => p_business_group_id
                  ,p_payroll_action_id => p_payroll_action_id
                  ,p_table_name        => l_rates_table2
                  ,p_col_name          => chi_cc1
                  ,p_row_value         => 'ADDITIONAL_PASSENGER'
                  ,p_effective_date    => p_Claim_end_date
                  ,p_error_msg         => p_err_msg));
  l_correction:='Y';
  END IF;
 END IF;

  l_effective_date :=TRUNC(pqp_car_mileage_functions.
                      pqp_get_date_paid(p_payroll_action_id));
  IF p_total_passengers=0 AND p_total_pasg_itd_val=0 THEN

   p_tax_free_amt:=0;
   p_ni_amt:=0;
   p_tax_amt:=0;
   p_err_msg:='SUCCESS';

  ELSE
   l_ret_value:=pqp_car_mileage_functions.pqp_get_range(
                      p_assignment_id     => 0
                     ,p_business_group_id =>p_business_group_id
                     ,p_payroll_action_id =>p_payroll_action_id
                     ,p_table_name        =>l_rates_table1
                     ,p_row_or_column     =>'COL'
                     ,p_value             =>p_cc
                     ,p_claim_date        =>p_claim_end_date
                     ,p_low_value         =>l_low_val_ur
                     ,p_high_value        =>l_high_val_ur        );
   IF (p_Claimed_mileage-p_itd_miles)<>0
    OR (p_total_passengers- p_total_pasg_itd_val) <> 0 THEN
    chi_cc:=to_char(l_high_val_ur);
    chi_cc_iram:=to_char(l_high_value);
    addl_rate:=to_number(pqp_car_mileage_functions.pqp_get_table_value
                   (p_bus_group_id      => p_business_group_id
                   ,p_payroll_action_id =>p_payroll_action_id
                   ,p_table_name        => l_rates_table1
                   ,p_col_name          => chi_cc
                   ,p_row_value         => 'ADDITIONAL_PASSENGER'
                   ,p_effective_date    => p_Claim_end_date
                   ,p_error_msg         => p_err_msg));
    IF l_correction='N' THEN
     addl_rate1:= addl_rate;
    END IF;
    IF p_err_msg='SUCCESS' THEN
     IF p_Claimed_mileage-p_itd_miles <> 0
      AND p_total_passengers-p_total_pasg_itd_val<>0 THEN

  --    Add_pasg_rate:=ABS((p_total_passengers)*(p_Claimed_mileage)*addl_rate)-(p_total_pasg_itd_val)*(p_itd_miles)*addl_rate1;
        Add_pasg_rate:=(p_total_passengers)*(p_Claimed_mileage)*addl_rate
                        -(p_total_pasg_itd_val)*(p_itd_miles)*addl_rate1;


     ELSIF p_Claimed_mileage-p_itd_miles <> 0
                AND p_total_passengers-p_total_pasg_itd_val=0 THEN

      Add_pasg_rate:=(p_total_passengers)
              *(p_Claimed_mileage-p_itd_miles)*addl_rate;
     ELSIF p_Claimed_mileage-p_itd_miles = 0
                AND p_total_passengers-p_total_pasg_itd_val <> 0 THEN

      Add_pasg_rate:=(p_total_passengers-p_total_pasg_itd_val)
              *(p_Claimed_mileage)*addl_rate1;
     END IF;
     p_tax_free_amt:=add_pasg_rate;

    ELSE
     p_tax_free_amt:=0;
     p_ni_amt:=0;
     p_tax_amt:=0;
     /*p_err_msg:=p_err_msg||'ERROR'||'pclm'||p_Claimed_mileage||'p_itd_miles'||p_itd_miles||'p_total_passengers'||p_total_passengers||'p_total_pasg_itd_val'||p_total_pasg_itd_val||'p_rates_table'||p_rates_table;*/
p_err_msg := 'p_rates_table'||p_rates_table;
    END IF;
   ELSE
    p_tax_free_amt:=0;
    p_ni_amt:=0;
    p_tax_amt:=0;
    p_err_msg:='SUCCESS';
   END IF;
  END IF;
return (0);

-- Added by tmehra for nocopy changes Feb'03

EXCEPTION
    WHEN OTHERS THEN

       p_tax_free_amt := NULL;
       p_ni_amt       := NULL;
       p_tax_amt      := NULL;
       p_err_msg      := SQLERRM||'myerror';
       raise;


END;


------------------------------------------------------------------
--Function pqp_get_date_paid
-----------------------------------------------------------------

FUNCTION pqp_get_date_paid (     p_payroll_action_id     IN  NUMBER)
RETURN DATE
AS

CURSOR c_date_paid IS
SELECT effective_date
 FROM  pay_payroll_actions
WHERE  payroll_action_id=  p_payroll_action_id;

l_date_paid c_date_paid%ROWTYPE;
BEGIN
 OPEN c_date_paid;
  LOOP
   FETCH c_date_paid INTO l_date_paid;
   EXIT WHEN c_date_paid%NOTFOUND;

  END LOOP;
 CLOSE c_date_paid;

 RETURN (l_date_paid.effective_date);

EXCEPTION
---------
WHEN OTHERS THEN
RETURN(NULL);


END;


FUNCTION  pqp_get_passenger_rate ( p_business_group_id         IN  NUMBER
                                  ,p_payroll_action_id         IN  NUMBER
                                  ,p_vehicle_type              IN  VARCHAR2
                                  ,p_claimed_mileage           IN  NUMBER
                                  ,p_cl_itd_miles              IN  NUMBER
                                  ,p_actual_mileage            IN  NUMBER
                                  ,p_ac_itd_miles              IN  NUMBER
                                  ,p_total_passengers          IN  NUMBER
                                  ,p_total_pasg_itd_val        IN  NUMBER
                                  ,p_cc                        IN  NUMBER
                                  ,p_rates_table               IN  VARCHAR2
                                  ,p_claim_end_date            IN  DATE
                                  ,p_tax_free_amt              OUT NOCOPY NUMBER
                                  ,p_ni_amt                    OUT NOCOPY NUMBER
                                  ,p_tax_amt                   OUT NOCOPY NUMBER
                                  ,p_err_msg                   OUT NOCOPY VARCHAR2)

RETURN number
AS
  chi_cc              VARCHAR2(15);
  chi_cc1             VARCHAR2(15);
  chi_cc_iram         VARCHAR2(15);
  addl_rate           NUMBER :=0;
  addl_rate1          NUMBER :=0;
  addl_ni_rate        NUMBER :=0;
  addl_ni_rate1       NUMBER :=0;
  addl_tax_rate1      NUMBER :=0;
  addl_tax_rate       NUMBER :=0;
  Add_pasg_rate       NUMBER :=0;
  cal_ni_rate         NUMBER :=0;
  cal_tax_rate        NUMBER :=0;
  l_low_value         NUMBER :=0;
  l_high_value        NUMBER :=0;
  l_ret_value         NUMBER :=0;
  l_high_val_ur       NUMBER :=0;
  l_low_val_ur        NUMBER :=0;
  l_high_val_ur1      NUMBER :=0;
  l_low_val_ur1       NUMBER :=0;
  l_effective_date    DATE;
  l_rates_table1      VARCHAR2(80);
  l_rates_table2      VARCHAR2(80);
  l_rates_table       VARCHAR2(160);
  l_length            NUMBER(9);
  l_err               VARCHAR2(10) := NULL;
  l_prev_tax_free_amt NUMBER(9,2) :=0;
  l_prev_ni_amt       NUMBER(9,2) :=0;
  l_prev_tax_amt      NUMBER(9,2) :=0;
  l_error_msg         VARCHAR2(80);
  l_ret_num           NUMBER :=0;
  l_rates_setting     VARCHAR2(1);
  l_correction        VARCHAR2(1) :='N';

BEGIN
 l_length :=0;
 BEGIN
 /*This section is introduced to handle rates from sliding scale
   for additional passengers. This is mainly used during correction
   of claims where additional passengers have been changed. The rate that
   must be calculated should be based on the old rate table that is used
   to calculte the old value and new rates table will be used to calcualte the
   new changed value for addl passengers. */
  SELECT INSTR (p_rates_table,'+PLUS+',1 )
    INTO l_length
    FROM dual;

  EXCEPTION
  WHEN OTHERS THEN
  l_err :='NONE' ;
 END ;
 IF l_length <> 0 THEN
  l_rates_table2 := SUBSTR (p_rates_table,l_length+6);
  l_rates_table1 := SUBSTR (p_rates_table,0,l_length-1);
  l_rates_table2 := LTRIM(RTRIM(l_rates_table2));
  l_rates_table1 := LTRIM(RTRIM(l_rates_table1));
 ELSE
  l_rates_table1 := p_rates_table;
  l_rates_table2 := 'NONE';
 END IF;
 l_rates_setting :='N' ;
 IF p_total_pasg_itd_val <> 0
  AND ( p_total_pasg_itd_val - p_total_passengers) <> 0
  AND l_rates_table2 <> 'NONE'
  AND l_err IS NULL THEN
  l_rates_setting := get_config_info (p_business_group_id,'Rates');
  IF l_rates_setting ='Y' THEN
    l_ret_value:=pqp_car_mileage_functions.pqp_get_range
                     (p_assignment_id     =>0
                     ,p_business_group_id =>p_business_group_id
                     ,p_payroll_action_id =>p_payroll_action_id
                     ,p_table_name        =>'PQP_INLAND_REV_AUTH_MILEAGE_RATES'
                     ,p_row_or_column     =>'COL'
                     ,p_value             =>p_cc
                     ,p_claim_date        =>p_claim_end_date
                     ,p_low_value         =>l_low_value
                     ,p_high_value        =>l_high_value        );

   l_ret_value:=pqp_car_mileage_functions.pqp_get_range(
                     p_assignment_id     => 0
                    ,p_business_group_id =>p_business_group_id
                    ,p_payroll_action_id =>p_payroll_action_id
                    ,p_table_name        =>l_rates_table2
                    ,p_row_or_column     =>'COL'
                    ,p_value             =>p_cc
                    ,p_claim_date        =>p_claim_end_date
                    ,p_low_value         =>l_low_val_ur1
                    ,p_high_value        =>l_high_val_ur1 );
   chi_cc1:=to_char(l_high_val_ur1);
   chi_cc_iram:=to_char(l_high_value);
   addl_rate1:=to_number(pqp_car_mileage_functions.pqp_get_table_value
                  (p_bus_group_id      => p_business_group_id
                  ,p_payroll_action_id =>p_payroll_action_id
                  ,p_table_name        => l_rates_table2
                  ,p_col_name          =>  chi_cc1
                  ,p_row_value         => 'ADDITIONAL_PASSENGER'
                  ,p_effective_date    => p_Claim_end_date
                  ,p_error_msg         => p_err_msg));
   IF p_err_msg='SUCCESS'
    AND ( p_vehicle_type='E' OR p_vehicle_type='C')THEN
    addl_ni_rate1:=to_number(pqp_car_mileage_functions.pqp_get_table_value
                  (p_bus_group_id      => p_business_group_id
                  ,p_payroll_action_id =>p_payroll_action_id
                  ,p_table_name        => 'PQP_NIC_MILEAGE_RATES'
                  ,p_col_name          => chi_cc_iram
                  ,p_row_value         => 'ADDL PASSENGER'
                  ,p_effective_date    => p_Claim_end_date
                  ,p_error_msg         =>p_err_msg));
   END IF;
   IF p_err_msg='SUCCESS'
    AND ( p_vehicle_type='E' OR p_vehicle_type='C') THEN
    addl_tax_rate1:=to_number(pqp_car_mileage_functions.pqp_get_table_value
                 (p_bus_group_id      => p_business_group_id
                 ,p_payroll_action_id =>p_payroll_action_id
                 ,p_table_name        => 'PQP_INLAND_REV_AUTH_MILEAGE_RATES'
                 ,p_col_name          => chi_cc_iram
                 ,p_row_value         => 'ADDL PASSENGER'
                 ,p_effective_date    => p_Claim_end_date
                 ,p_error_msg         => p_err_msg));
   END IF;
   l_correction:='Y';
  END IF;
 END IF;
 l_effective_date :=TRUNC(pqp_car_mileage_functions.
                     pqp_get_date_paid(p_payroll_action_id));
 IF p_total_passengers=0 AND p_total_pasg_itd_val=0 THEN
  p_tax_free_amt:=0;
  p_ni_amt:=0;
  p_tax_amt:=0;
  p_err_msg:='SUCCESS';

 ELSE
  l_ret_value:=pqp_car_mileage_functions.pqp_get_range
                     (p_assignment_id     =>0
                     ,p_business_group_id =>p_business_group_id
                     ,p_payroll_action_id =>p_payroll_action_id
                     ,p_table_name        =>'PQP_INLAND_REV_AUTH_MILEAGE_RATES'
                     ,p_row_or_column     =>'COL'
                     ,p_value             =>p_cc
                     ,p_claim_date        =>p_claim_end_date
                     ,p_low_value         =>l_low_value
                     ,p_high_value        =>l_high_value        );

  l_ret_value:=pqp_car_mileage_functions.pqp_get_range(
                      p_assignment_id     => 0
                     ,p_business_group_id =>p_business_group_id
                     ,p_payroll_action_id =>p_payroll_action_id
                     ,p_table_name        =>l_rates_table1
                     ,p_row_or_column     =>'COL'
                     ,p_value             =>p_cc
                     ,p_claim_date        =>p_claim_end_date
                     ,p_low_value         =>l_low_val_ur
                     ,p_high_value        =>l_high_val_ur        );
  IF (p_Claimed_mileage-p_cl_itd_miles)<>0
   OR (p_total_passengers- p_total_pasg_itd_val) <> 0
   OR (p_actual_mileage-p_ac_itd_miles)<>0 THEN
   chi_cc:=to_char(l_high_val_ur);
   chi_cc_iram:=to_char(l_high_value);
   addl_rate:=to_number(pqp_car_mileage_functions.pqp_get_table_value
                   (p_bus_group_id      => p_business_group_id
                   ,p_payroll_action_id =>p_payroll_action_id
                   ,p_table_name        => l_rates_table1
                   ,p_col_name          => chi_cc
                   ,p_row_value         => 'ADDITIONAL_PASSENGER'
                   ,p_effective_date    => p_Claim_end_date
                   ,p_error_msg         => p_err_msg));
   IF l_correction='N' THEN
    addl_rate1:= addl_rate;
   END IF;



   IF p_err_msg='SUCCESS'
    AND ( p_vehicle_type='E' OR p_vehicle_type='C')THEN
    addl_ni_rate:=to_number(pqp_car_mileage_functions.pqp_get_table_value
                  (p_bus_group_id      => p_business_group_id
                  ,p_payroll_action_id =>p_payroll_action_id
                  ,p_table_name        => 'PQP_NIC_MILEAGE_RATES'
                  ,p_col_name          => chi_cc_iram
                  ,p_row_value         => 'ADDL PASSENGER'
                  ,p_effective_date    => p_Claim_end_date
                  ,p_error_msg         =>p_err_msg));
   END IF;
   IF p_err_msg='SUCCESS'
    AND ( p_vehicle_type='E' OR p_vehicle_type='C') THEN
    addl_tax_rate:=to_number(pqp_car_mileage_functions.pqp_get_table_value
                 (p_bus_group_id      => p_business_group_id
                 ,p_payroll_action_id =>p_payroll_action_id
                 ,p_table_name        => 'PQP_INLAND_REV_AUTH_MILEAGE_RATES'
                 ,p_col_name          => chi_cc_iram
                 ,p_row_value         => 'ADDL PASSENGER'
                 ,p_effective_date    => p_Claim_end_date
                 ,p_error_msg         => p_err_msg));
   END IF;
   IF p_err_msg='SUCCESS' THEN
    IF (p_claimed_mileage-p_ac_itd_miles <> 0
     AND p_total_passengers-p_total_pasg_itd_val<>0 )
     OR (p_actual_mileage-p_ac_itd_miles <> 0
     AND p_total_passengers-p_total_pasg_itd_val<>0) THEN
     Add_pasg_rate:=ABS((p_total_passengers)*(p_claimed_mileage)*addl_rate)
                        -(p_total_pasg_itd_val)*(p_cl_itd_miles)*addl_rate1;
     IF p_vehicle_type='E' OR p_vehicle_type='C' THEN
      cal_ni_rate:=ABS((p_total_passengers)*(p_actual_mileage)*addl_ni_rate)
                      -(p_total_pasg_itd_val)*(p_ac_itd_miles)*addl_ni_rate1;
      cal_tax_rate:=ABS((p_total_passengers)*(p_actual_mileage)*addl_tax_rate)
                        -(p_total_pasg_itd_val)*(p_ac_itd_miles)*addl_tax_rate1;
     END IF;
     ELSIF (p_claimed_mileage-p_cl_itd_miles <> 0
      AND p_total_passengers-p_total_pasg_itd_val=0 )
      OR (p_actual_mileage-p_ac_itd_miles <> 0
      AND p_total_passengers-p_total_pasg_itd_val=0 ) THEN

      Add_pasg_rate:=(p_total_passengers)
              *(p_claimed_mileage-p_cl_itd_miles)*addl_rate;
      IF p_vehicle_type='E' OR p_vehicle_type='C' THEN
       cal_ni_rate:=((p_total_passengers)
              *(p_actual_mileage-p_ac_itd_miles)*addl_ni_rate);
       cal_tax_rate:=((p_total_passengers)
              *(p_actual_mileage-p_ac_itd_miles)*addl_tax_rate);

      END IF;
     ELSIF (p_claimed_mileage-p_cl_itd_miles = 0
      AND p_total_passengers-p_total_pasg_itd_val <>0 )
      OR (p_actual_mileage-p_ac_itd_miles = 0
      AND p_total_passengers-p_total_pasg_itd_val <>0 ) THEN
      Add_pasg_rate:=(p_total_passengers-p_total_pasg_itd_val)
              *(p_Claimed_mileage)*addl_rate1;
      IF p_vehicle_type='E' OR p_vehicle_type='C' THEN
       cal_ni_rate:=((p_total_passengers-p_total_pasg_itd_val)
              *(p_actual_mileage)*addl_ni_rate1);
       cal_tax_rate:=((p_total_passengers-p_total_pasg_itd_val)
              *(p_actual_mileage)*addl_tax_rate1);

      END IF;
     END IF;
     p_tax_free_amt:=add_pasg_rate ;

     IF p_vehicle_type='E' OR p_vehicle_type='C' THEN
      IF Add_pasg_rate>=0 THEN
       p_ni_amt:= GREATEST ((Add_pasg_rate- cal_ni_rate),0);
       p_tax_amt:=GREATEST ((Add_pasg_rate- cal_tax_rate),0);
      ELSE
       p_ni_amt:= LEAST ((Add_pasg_rate- cal_ni_rate),0);
       p_tax_amt:=LEAST ((Add_pasg_rate- cal_tax_rate),0);
      END IF;
     END IF;
    ELSE
     p_tax_free_amt:=0;
     p_ni_amt:=0;
     p_tax_amt:=0;
     p_err_msg:='ERROR';
    END IF;
   ELSE
    p_tax_free_amt:=0;
    p_ni_amt:=0;
    p_tax_amt:=0;
    p_err_msg:='SUCCESS';
   END IF;
  END IF;
RETURN (0);

-- Added by tmehra for nocopy changes Feb'03

EXCEPTION
    WHEN OTHERS THEN

       p_tax_free_amt := NULL;
       p_ni_amt       := NULL;
       p_tax_amt      := NULL;
       p_err_msg      := SQLERRM;
       raise;


END;

--------------------------------------------------------------

--FUNCTION pqp_get_ele_endate to get the end date of element
--entry id so that the stop entry is over ridden and this would
--enable element to be picked up even when it is end dated in the
--mid pay period.
---------------------------------------------------------------


FUNCTION pqp_get_ele_endate (  p_assignment_id           IN  NUMBER
                              ,p_business_group_id       IN  NUMBER
                              ,p_payroll_action_id       IN  NUMBER
                              ,p_element_entry_id        IN  NUMBER
                             )
RETURN VARCHAR2
AS

CURSOR c_get_payroll_date
IS
SELECT ppa.effective_date
  FROM pay_payroll_actions ppa
 WHERE ppa.payroll_action_id = p_payroll_action_id
   AND ppa.business_group_id = p_business_group_id;

CURSOR c_get_end_date (cp_date DATE)
IS
SELECT pee.effective_end_date
  FROM pay_element_entries_f pee
 WHERE pee.element_entry_id =p_element_entry_id
   AND pee.assignment_id    =p_assignment_id
   AND pee.effective_end_date <=cp_date;
l_get_payroll_date  c_get_payroll_date%ROWTYPE;
l_get_end_date      c_get_end_date%ROWTYPE;
l_end_dated         VARCHAR2(1) :='N';

BEGIN
 OPEN c_get_payroll_date;
  FETCH c_get_payroll_date INTO l_get_payroll_date;
 CLOSE c_get_payroll_date;

 OPEN c_get_end_date (l_get_payroll_date.effective_date);
  FETCH c_get_end_date INTO l_get_end_date;
 CLOSE c_get_end_date;

 IF l_get_end_date.effective_end_date <>
                     to_date('12/31/4712','MM/DD/YYYY') THEN
  l_end_dated :='Y';
 END IF;
 RETURN (l_end_dated);
END;


---------------------------------------------------------------
--FUNCTION pqp_is_emp_term checks if employee is terminated.
---------------------------------------------------------------

FUNCTION pqp_is_emp_term (  p_assignment_id           IN  NUMBER
                           ,p_business_group_id       IN  NUMBER
                           ,p_payroll_action_id       IN  NUMBER
                           ,p_date_earned             IN  DATE
                          )
RETURN VARCHAR2
AS

CURSOR c_get_term_date
IS
SELECT DECODE(NVL(TO_CHAR(pds.actual_termination_date), 'N'), 'N', 'N', 'Y') term_date
  FROM  per_periods_of_service	pds
       ,per_assignments_f	pas
 WHERE	pds.actual_termination_date <= p_date_earned
   AND	pds.period_of_service_id     = pas.period_of_service_id
   AND	p_date_earned BETWEEN pas.effective_start_date
   AND  pas.effective_end_date
   AND	pas.primary_flag  = 'Y'
   AND	pas.assignment_id   =p_assignment_id
   AND  pds.business_group_id =p_business_group_id
   AND  pds.business_group_id=pas.business_group_id;

l_term_date VARCHAR2(1) :='N';
BEGIN

 OPEN c_get_term_date;
  FETCH c_get_term_date INTO l_term_date;
 CLOSE c_get_term_date;

 RETURN (NVL(l_term_date,'N'));
END;


----------------------------------------------------------------------------
--Function get_rates_table
----------------------------------------------------------------------------

FUNCTION get_rates_table (p_business_group_id    IN NUMBER
                         ,p_lookup_type          IN VARCHAR2
                         ,p_additional_passenger IN NUMBER
                         )
RETURN VARCHAR2
IS

 CURSOR c_get_rates_table
 IS
 SELECT flv.meaning
   FROM fnd_lookup_values flv
  WHERE flv.lookup_type=p_lookup_type
    AND flv.lookup_code <= p_additional_passenger
  ORDER BY flv.lookup_code DESC;

 l_get_rates_table c_get_rates_table%ROWTYPE;

BEGIN
 OPEN c_get_rates_table;
  FETCH c_get_rates_table INTO  l_get_rates_table;
 CLOSE c_get_rates_table;


 RETURN (NVL(l_get_rates_table.meaning,p_lookup_type));

EXCEPTION
---------
 WHEN OTHERS THEN
  RETURN p_lookup_type;

END  get_rates_table;


---------------------------------------------------------------------
----FUNCTION get_vehicle_type
--------------------------------------------------------------------
FUNCTION get_vehicle_type (p_business_group_id    IN NUMBER
                          ,p_element_type_id     IN NUMBER
                          ,p_payroll_action_id   IN NUMBER
                           )
RETURN VARCHAR2
IS

CURSOR  c_vehicle_type (cp_business_group_id NUMBER
                       ,cp_element_type_id   NUMBER
                       ,cp_effective_date    DATE )
 IS
 SELECT pete.eei_information1 vehicle_type
  FROM  pay_element_types_f petf
       ,pay_element_type_extra_info pete
 WHERE  pete.information_type='PQP_VEHICLE_MILEAGE_INFO'
   AND  pete.element_type_id=petf.element_type_id
   AND  petf.element_type_id= cp_element_type_id
   AND  petf.business_group_id= cp_business_group_id
   AND  cp_effective_date BETWEEN petf.effective_start_date
                              AND petf.effective_end_date
   AND  pete.eei_information1 in ('P','PP',
                                  'PM','C','CM'
                                  ,'CP');
l_vehicle_type   c_vehicle_type%ROWTYPE;
l_effective_date DATE;


BEGIN
 l_effective_date :=TRUNC(pqp_car_mileage_functions.
                      pqp_get_date_paid(p_payroll_action_id));


 OPEN c_vehicle_type (p_business_group_id
                     ,p_element_type_id
                     ,l_effective_date
                     );
  FETCH c_vehicle_type INTO l_vehicle_type;
 CLOSE c_vehicle_type;

 IF l_vehicle_type.vehicle_type = 'P' OR
    l_vehicle_type.vehicle_type = 'C' THEN
  RETURN ('NE');
 ELSE
  RETURN (l_vehicle_type.vehicle_type);
 END IF;
EXCEPTION
--------
WHEN OTHERS THEN
RETURN ('NE');
END get_vehicle_type;

FUNCTION is_miles_nonreimbursed
                (  p_assignment_id           IN  NUMBER
                  ,p_business_group_id       IN  NUMBER
                  ,p_payroll_action_id       IN  NUMBER
                  ,p_element_type_id         IN NUMBER
                  ,p_date_earned             IN  DATE
                  ,p_to_date                 IN DATE
                )
RETURN VARCHAR2

IS

CURSOR c_is_entry_found (cp_assignment_id           NUMBER
                        ,cp_business_group_id       NUMBER
                        ,cp_element_type_id         NUMBER
                        ,cp_date_earned             DATE
                        ,cp_to_date                 DATE
                        ,cp_eff_dt                  DATE
                        )
IS
SELECT 'Y'
  FROM pay_element_type_extra_info petef
      ,pay_element_types_f pet
      ,pay_element_entries_f pee
      ,pay_element_entry_values_f pev
 WHERE pet.element_type_id =petef.element_type_id
   AND petef.information_type='PQP_VEHICLE_MILEAGE_INFO'
   AND petef.eei_information1 = 'P'
   AND pet.element_type_id =pee.element_type_id
   AND pee.element_entry_id=pev.element_entry_id
   AND pev.input_value_id =(SELECT input_value_id
                              FROM pay_input_values_f
                             WHERE element_type_id=petef.element_type_id
   AND name='Claim Start Date')  and pee.assignment_id=cp_assignment_id
   --AND  FND_DATE.canonical_to_date(screen_entry_value) < cp_to_date
   AND  (screen_entry_value) > FND_DATE.date_to_canonical (cp_to_date)
   AND EXISTS (select  'Y'
        from    pay_run_results         RESULT,
                pay_assignment_actions  ASGT_ACTION,
                pay_payroll_actions     PAY_ACTION,
                per_time_periods        PERIOD
        where   result.source_id        = pev.element_entry_id --nvl (p_original_entry_id, p_element_entry_id)
        and     result.status           <> 'U'
        and     result.source_type = 'E'
        and     result.assignment_action_id     = asgt_action.assignment_action_id
        and     asgt_action.payroll_action_id   = pay_action.payroll_action_id
        and     pay_action.payroll_id = period.payroll_id
        and     pay_action.date_earned between period.start_date and period.end_date
        and     pay_action.effective_date between period.start_date and period.end_date
        and pay_action.effective_date < cp_eff_dt)
   AND rownum=1;


CURSOR c_get_payroll_act_dt (cp_payroll_action_id NUMBER)
IS
SELECT ppa.effective_date
  FROM pay_payroll_actions ppa
 WHERE payroll_action_id=cp_payroll_action_id;


l_eff_dt DATE;

l_is_entry_found VARCHAR2(1);

BEGIN

 l_is_entry_found :='N';

 OPEN  c_get_payroll_act_dt (p_payroll_action_id);
  FETCH c_get_payroll_act_dt INTO l_eff_dt;
 CLOSE c_get_payroll_act_dt;

 OPEN c_is_entry_found (cp_assignment_id        => p_assignment_id
                        ,cp_business_group_id   => p_business_group_id
                        ,cp_element_type_id     => p_element_type_id
                        ,cp_date_earned         => p_date_earned
                        ,cp_to_date             => p_to_date
                        ,cp_eff_dt              =>l_eff_dt
                        );
  FETCH c_is_entry_found INTO l_is_entry_found;
 CLOSE c_is_entry_found;

 RETURN(NVL(l_is_entry_found,'N'));

EXCEPTION
WHEN OTHERS THEN
RETURN('N');
END;


END pqp_car_mileage_functions;

/
