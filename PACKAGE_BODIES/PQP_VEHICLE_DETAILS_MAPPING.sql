--------------------------------------------------------
--  DDL for Package Body PQP_VEHICLE_DETAILS_MAPPING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_VEHICLE_DETAILS_MAPPING" AS
--$Header: pqpvhdmp.pkb 115.1 2001/04/04 11:10:25 pkm ship       $
---------------------------------------------------------------------------
-- GET_VEHICLE_DETAILS_ID --
---------------------------------------------------------------------------
FUNCTION get_vehicle_details_id
( p_vehicle_details_user_key IN VARCHAR2)
    RETURN NUMBER IS

l_vehicle_details_id PQP_VEHICLE_DETAILS.vehicle_details_id%TYPE;

CURSOR veh_cur IS
SELECT unique_key_id
  FROM hr_pump_batch_line_user_keys
 WHERE user_key_value = p_vehicle_details_user_key;
BEGIN
    OPEN  veh_cur;
       FETCH veh_cur INTO l_vehicle_details_id;
    CLOSE veh_cur;

 RETURN(l_vehicle_details_id);

EXCEPTION
WHEN OTHERS THEN
    hr_data_pump.fail('get_vehicle_details_id'  ,
                      SQLERRM                 ,
                      p_vehicle_details_user_key);
   RAISE;
END get_vehicle_details_id;

---------------------------------------------------------------------------
-- GET_VEHICLE_DETAILS_OVN
---------------------------------------------------------------------------

FUNCTION get_vehicle_details_ovn
( p_vehicle_details_user_key IN VARCHAR2)
    RETURN NUMBER IS

l_vehicle_details_ovn PQP_VEHICLE_DETAILS.object_version_number%TYPE;
CURSOR ovn_cur(p_user_key_value IN VARCHAR2) IS
SELECT object_version_number
  FROM pqp_vehicle_details  pvd,
       hr_pump_batch_line_user_keys key
 WHERE key.user_key_value     = p_user_key_value
   AND pvd.vehicle_details_id = key.unique_key_id ;
BEGIN
    OPEN  ovn_cur(p_vehicle_details_user_key);
       FETCH ovn_cur INTO l_vehicle_details_ovn;
    CLOSE ovn_cur;
    RETURN l_vehicle_details_ovn;
EXCEPTION
WHEN OTHERS THEN
    hr_data_pump.fail('get_vehicle_details_ovn' ,
                      SQLERRM                 ,
                      p_vehicle_details_user_key);
    RAISE;
END get_vehicle_details_ovn;

END pqp_vehicle_details_mapping;

/
