--------------------------------------------------------
--  DDL for Package Body BIM_PRODUCT_CATEG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIM_PRODUCT_CATEG_PKG" AS
/* $Header: bimprodb.pls 115.0 2000/01/07 16:15:18 pkm ship  $ */

FUNCTION GET_INTEREST_CODE_ID(
           p_interest_type_id  IN NUMBER,
           p_interest_code     IN VARCHAR2,
           p_code_type         IN VARCHAR2 )
RETURN NUMBER IS

cursor c_get_pcode
IS
SELECT interest_code_id
  FROM bim_dimv_interest_codes
 WHERE interest_code = p_interest_code
   AND parent_interest_code_id is NULL
   AND interest_type_id = p_interest_type_id ;


cursor c_get_scode
IS
SELECT interest_code_id
  FROM bim_dimv_interest_codes
 WHERE interest_code = p_interest_code
   AND parent_interest_code_id is NOT NULL
   AND interest_type_id = p_interest_type_id ;

v_code_id  NUMBER;

BEGIN
      IF p_code_type = 'P'  THEN
         OPEN c_get_pcode;
         FETCH c_get_pcode INTO v_code_id;
         CLOSE c_get_pcode;
      ELSIF p_code_type = 'S'  THEN
         OPEN c_get_scode;
         FETCH c_get_scode INTO v_code_id;
         CLOSE c_get_scode;
      END IF;

      return v_code_id;
EXCEPTION
    WHEN OTHERS THEN
         raise;
END GET_INTEREST_CODE_ID;

END BIM_PRODUCT_CATEG_PKG;

/
