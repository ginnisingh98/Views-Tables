--------------------------------------------------------
--  DDL for Package Body ENG_VAL_CAT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENG_VAL_CAT" AS
/* $Header: ENGVCATB.pls 115.0.1159.2 2003/06/09 08:45:16 rbehal ship $ */

FUNCTION Has_Change_objects (p_change_mgmt_type_code IN VARCHAR2, p_called IN NUMBER) RETURN VARCHAR2
IS
Cursor c_has_obj_cur( p_mgmt_code IN VARCHAR2)
IS
Select 'X'
from  ENG_CHANGE_MGMT_TYPES_VL ecmt,
      ENG_ENGINEERING_CHANGES echg,
      ENG_CHANGE_ORDER_TYPES eco
where
      ecmt.CHANGE_MGMT_TYPE_CODE = eco.change_mgmt_type_code
and
      eco.change_order_type_id = echg.change_order_type_id
and
      ecmt.CHANGE_MGMT_TYPE_CODE = p_mgmt_code;

lv_exist VARCHAR2(20) := NULL;

BEGIN

OPEN c_has_obj_cur(p_change_mgmt_type_code);
FETCH c_has_obj_cur INTO lv_exist;
IF c_has_obj_cur%notfound THEN
  IF p_called =1 then
   lv_exist :='NoCoR';
  ELSE
   lv_exist :='NoCoL';
  END IF;
ELSE
  IF p_called =1 then
   lv_exist :='HasCoR';
  ELSE
   lv_exist :='HasCoL';
  END IF;
END IF;
CLOSE c_has_obj_cur;
return(lv_exist);

EXCEPTION
  WHEN OTHERS THEN
	CLOSE c_has_obj_cur;
	return('NoCO');

END Has_Change_objects;

-- Returns HasCoR if some Change objects with status other than Cancelled and implemented exists
-- for given Change Category
-- Else returns NoCoR
-- p_mgmt_code IN parameter for Change Category


FUNCTION Has_Active_Change_objects (p_change_mgmt_type_code IN VARCHAR2) RETURN VARCHAR2
IS
Cursor c_has_obj_cur( p_mgmt_code IN VARCHAR2)
IS
Select 'X'
from  ENG_CHANGE_MGMT_TYPES_VL ecmt,
      ENG_ENGINEERING_CHANGES echg,
      ENG_CHANGE_ORDER_TYPES eco
where
      ecmt.CHANGE_MGMT_TYPE_CODE = eco.change_mgmt_type_code
and
      eco.change_order_type_id = echg.change_order_type_id
and
      echg.STATUS_TYPE <> 6 -- Implemented
and
      echg.STATUS_TYPE <> 5 -- Cancelled
and
      ecmt.CHANGE_MGMT_TYPE_CODE = p_mgmt_code;

lv_exist VARCHAR2(20) := NULL;

BEGIN

OPEN c_has_obj_cur(p_change_mgmt_type_code);
FETCH c_has_obj_cur INTO lv_exist;
IF c_has_obj_cur%notfound THEN
   lv_exist :='NoCoR';
ELSE
   lv_exist :='HasCoR';
END IF;
CLOSE c_has_obj_cur;
return(lv_exist);

EXCEPTION
  WHEN OTHERS THEN
	CLOSE c_has_obj_cur;
	return('NoCOR');

END Has_Active_Change_objects;


END ENG_VAL_CAT;

/
