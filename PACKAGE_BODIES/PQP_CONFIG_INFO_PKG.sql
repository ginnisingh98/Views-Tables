--------------------------------------------------------
--  DDL for Package Body PQP_CONFIG_INFO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_CONFIG_INFO_PKG" AS
/* $Header: pqcfigcp.pkb 115.1 2003/03/06 23:41:51 sshetty noship $ */

FUNCTION get_user_table_name ( p_table_id          IN NUMBER
                         ,p_business_group_id IN NUMBER
                         )
RETURN VARCHAR2
IS

CURSOR c_get_user_table_name
IS
SELECT put.user_table_name
  FROM pay_user_tables put
 WHERE put.business_group_id=p_business_group_id
   AND put.user_table_id    =p_table_id;

l_get_user_table_name c_get_user_table_name%ROWTYPE;

BEGIN

 OPEN c_get_user_table_name;
  FETCH c_get_user_table_name INTO l_get_user_table_name;

 CLOSE c_get_user_table_name;

 RETURN (NVL(l_get_user_table_name.user_table_name,'NONE'));

END;



FUNCTION get_element_name ( p_element_id          IN NUMBER
                           ,p_business_group_id   IN NUMBER
                         )
RETURN VARCHAR2
IS

CURSOR c_get_ele_name
IS
SELECT pet.element_name
  FROM pay_element_types_f pet
 WHERE pet.element_type_id =p_element_id
   AND pet.business_group_id=p_business_group_id
   AND sysdate BETWEEN pet.effective_start_date
                   AND pet.effective_end_date;

l_get_ele_name c_get_ele_name%ROWTYPE;




BEGIN
 OPEN c_get_ele_name;
  FETCH c_get_ele_name INTO l_get_ele_name;
 CLOSE c_get_ele_name;

 RETURN (NVL(l_get_ele_name.element_name,'NONE'));

END;

PROCEDURE pqp_veh_calc_info
        ( errbuf                       OUT NOCOPY VARCHAR2,
          retcode                      OUT NOCOPY NUMBER,
          p_effective_date             IN DATE    default trunc(sysdate),
          p_business_group_id          IN NUMBER,
          p_legislation_code           IN VARCHAR2 default null,
          p_ownership                  IN VARCHAR2  ,
          p_usage_type                 IN VARCHAR2 default null ,
          p_vehicle_type               IN VARCHAR2 default null,
          p_fuel_type                  IN VARCHAR2  default null,
          p_user_rates_table           IN VARCHAR2  default null,
          p_element_entry_id           IN VARCHAR2  default null,
          p_mode                       IN VARCHAR2
 )

IS

CURSOR c_get_info
IS
SELECT  pcv.pcv_information_category
       , pqp_gb_mileage_claim_pkg.get_lkp_meaning
         (pcv.pcv_information1,'PQP_VEHICLE_OWNERSHIP_TYPE')
          Ownership
       ,RPAD(DECODE (pcv.pcv_information1,'C',
         pqp_gb_mileage_claim_pkg.get_lkp_meaning
          (pcv.pcv_information2,'PQP_COMPANY_VEHICLE_USER'),
          'P',pqp_gb_mileage_claim_pkg.get_lkp_meaning
          (pcv.pcv_information2,'PQP_PRIVATE_VEHICLE_USER')
           ),10) Usage_type
       , RPAD(pqp_gb_mileage_claim_pkg.get_lkp_meaning
          (pcv.pcv_information3 ,'PQP_VEHICLE_TYPE'),10)
        Vehicle_type
       ,RPAD(pqp_gb_mileage_claim_pkg.get_lkp_meaning
         (pcv.pcv_information4,'PQP_FUEL_TYPE'),21)
         Fuel_type
       ,RPAD(get_user_table_name(
         TO_NUMBER(pcv.pcv_information5),
                   p_business_group_id),35) rates_type
       ,RPAD(get_element_name(
         TO_NUMBER(pcv.pcv_information6),
             p_business_group_id),60) element_name
  FROM pqp_configuration_values pcv
 WHERE business_group_id=p_business_group_id;

l_configuration_value_id number;
l_object_version_number  number;
l_pcv_information_category  varchar2(80) := 'GB_VEHICLE_CALC_INFO';
l_count  NUMBER;
l_mode   VARCHAR2(1);
l_get_info c_get_info%ROWTYPE;
BEGIN

 IF p_mode='I' THEN

  SELECT count(*)
    INTO l_count
    FROM pqp_configuration_values pcv
   WHERE pcv.pcv_information_category ='GB_VEHICLE_CALC_INFO'
     AND pcv.pcv_information1 =p_ownership
     AND pcv.pcv_information2 =p_usage_type
     AND pcv.pcv_information3 =p_vehicle_type
     AND pcv.pcv_information4 =p_fuel_type
     AND pcv.business_group_id=p_business_group_id;

   IF l_count >0 THEN
    l_mode:='U';
   ELSE
    pqp_pcv_ins.ins
    ( p_effective_date                 =>trunc(sysdate)
     ,p_business_group_id              =>p_business_group_id
     ,p_pcv_information_category       =>l_pcv_information_category
     ,p_pcv_information1               =>p_ownership
     ,p_pcv_information2               =>p_usage_type
     ,p_pcv_information3               =>p_vehicle_type
     ,p_pcv_information4               =>p_fuel_type
     ,p_pcv_information5               =>(p_user_rates_table)
     ,p_pcv_information6               =>(p_element_entry_id)
     ,p_configuration_value_id         =>l_configuration_value_id
     ,p_object_version_number          =>l_object_version_number
    );
   END IF;
 END IF;

 IF p_mode='U' or l_mode='U' THEN

  SELECT configuration_value_id
        ,object_version_number
    INTO l_configuration_value_id
        ,l_object_version_number
    FROM pqp_configuration_values pcv
   WHERE pcv.pcv_information_category ='GB_VEHICLE_CALC_INFO'
     AND pcv.pcv_information1 =p_ownership
     AND pcv.pcv_information2 =p_usage_type
     AND pcv.pcv_information3 =p_vehicle_type
     AND pcv.pcv_information4 =p_fuel_type
     AND pcv.business_group_id=p_business_group_id;

  pqp_pcv_upd.upd
  (p_effective_date               =>trunc(sysdate)
  ,p_configuration_value_id       =>l_configuration_value_id
  ,p_object_version_number        =>l_object_version_number
  ,p_business_group_id            =>p_business_group_id
  ,p_legislation_code             =>NULL
  ,p_pcv_information_category     =>l_pcv_information_category
  ,p_pcv_information1             =>p_ownership
  ,p_pcv_information2             =>p_usage_type
  ,p_pcv_information3             =>p_vehicle_type
  ,p_pcv_information4             =>p_fuel_type
  ,p_pcv_information5             =>p_user_rates_table
  ,p_pcv_information6             =>p_element_entry_id
  );


 END IF;

 IF p_mode='D'  THEN

  SELECT configuration_value_id
        ,object_version_number
    INTO l_configuration_value_id
        ,l_object_version_number
    FROM pqp_configuration_values pcv
   WHERE pcv.pcv_information_category ='GB_VEHICLE_CALC_INFO'
     AND pcv.pcv_information1 =p_ownership
     AND pcv.pcv_information2 =p_usage_type
     AND pcv.pcv_information3 =p_vehicle_type
     AND pcv.pcv_information4 =p_fuel_type
     AND pcv.business_group_id=p_business_group_id;


  pqp_pcv_del.del
  (p_configuration_value_id        =>l_configuration_value_id
  ,p_object_version_number         =>l_object_version_number
  );

 END IF;


      fnd_file.put(fnd_file.output,'Ownership   ');
      fnd_file.put(fnd_file.output,'Usage type   ');
      fnd_file.put(fnd_file.output,'Vehicle Type ');
      fnd_file.put(fnd_file.output,'      ' );
      fnd_file.put(fnd_file.output,'Fuel Type  ');
      fnd_file.put(fnd_file.output,'             ' );
      fnd_file.put(fnd_file.output,'Rates');
      fnd_file.put(fnd_file.output,'                               ' );
      fnd_file.put(fnd_file.output,'Element  ');


    fnd_file.put_line(fnd_file.output,' ');

  OPEN c_get_info;
   LOOP
    FETCH c_get_info INTO l_get_info;
    EXIT WHEN c_get_info%NOTFOUND;
    fnd_file.put_line(fnd_file.output,' ');
    fnd_file.put(fnd_file.output,l_get_info.Ownership );
    fnd_file.put(fnd_file.output,'     ' );
    fnd_file.put(fnd_file.output,l_get_info.usage_type );
    fnd_file.put(fnd_file.output,'   ' );
    fnd_file.put(fnd_file.output,l_get_info.vehicle_type );
    fnd_file.put(fnd_file.output,'         ' );
    fnd_file.put(fnd_file.output,l_get_info.fuel_type );
    fnd_file.put(fnd_file.output,'   ' );
    fnd_file.put(fnd_file.output,l_get_info.rates_type );
    fnd_file.put(fnd_file.output,' ' );
    fnd_file.put(fnd_file.output,l_get_info.element_name );


  END LOOP;
 CLOSE c_get_info;
END;

END;

/
