--------------------------------------------------------
--  DDL for Package Body PQP_VEHICLE_REPOSITORY_MAPPING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_VEHICLE_REPOSITORY_MAPPING" AS
--$Header: pqpvhdmp.pkb 115.2 2003/03/13 02:18:06 sshetty noship $
---------------------------------------------------------------------------+
-- GET_VEHICLE_REPOSITORY_ID --
---------------------------------------------------------------------------+
FUNCTION get_vehicle_repository_id
( p_vehicle_repository_user_key IN VARCHAR2)
    RETURN NUMBER IS

l_vehicle_repository_id PQP_VEHICLE_REPOSITORY_F.vehicle_repository_id%TYPE;

CURSOR veh_cur IS
SELECT unique_key_id
  FROM hr_pump_batch_line_user_keys
 WHERE user_key_value = p_vehicle_repository_user_key;
BEGIN
    OPEN  veh_cur;
       FETCH veh_cur INTO l_vehicle_repository_id;
    CLOSE veh_cur;

 RETURN(l_vehicle_repository_id);

EXCEPTION
WHEN OTHERS THEN
    hr_data_pump.fail('get_vehicle_repository_id'  ,
                      SQLERRM                 ,
                      p_vehicle_repository_user_key);
   RAISE;
END get_vehicle_repository_id;

---------------------------------------------------------------------------+
-- GET_VEHICLE_REPOSITORY_OVN
---------------------------------------------------------------------------+

FUNCTION get_vehicle_repository_ovn
( p_vehicle_repository_user_key IN VARCHAR2)
    RETURN NUMBER IS

l_vehicle_repository_ovn PQP_VEHICLE_REPOSITORY_F.object_version_number%TYPE;
CURSOR ovn_cur(p_user_key_value IN VARCHAR2) IS
SELECT object_version_number
  FROM pqp_vehicle_repository_f  pvd,
       hr_pump_batch_line_user_keys key
 WHERE key.user_key_value     = p_user_key_value
   AND pvd.vehicle_repository_id = key.unique_key_id ;
BEGIN
    OPEN  ovn_cur(p_vehicle_repository_user_key);
       FETCH ovn_cur INTO l_vehicle_repository_ovn;
    CLOSE ovn_cur;
    RETURN l_vehicle_repository_ovn;
EXCEPTION
WHEN OTHERS THEN
    hr_data_pump.fail('get_vehicle_repository_ovn' ,
                      SQLERRM                 ,
                      p_vehicle_repository_user_key);
    RAISE;
END get_vehicle_repository_ovn;

END pqp_vehicle_repository_mapping;

/
