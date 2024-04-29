--------------------------------------------------------
--  DDL for Package Body PN_ATG_IS_INSTL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PN_ATG_IS_INSTL_PKG" AS
  -- $Header: PNATGCKB.pls 120.1 2005/07/25 05:47:41 appldev noship $

FUNCTION IS_ATG_INSTALLED RETURN BOOLEAN
IS
  l_atg_flag   NUMBER;
  -- Check for ATG Calendar JTF Object.
  CURSOR c_chk_atg_cal IS
    SELECT 1
    FROM   dual
    WHERE  EXISTS(SELECT null
                  FROM   jtf_objects_vl
                  WHERE  object_code = 'PN_LOCATION');
BEGIN

  OPEN c_chk_atg_cal;
  FETCH c_chk_atg_cal INTO l_atg_flag;

  IF c_chk_atg_cal%NOTFOUND THEN
    CLOSE c_chk_atg_cal;
    RETURN FALSE;
  END IF;

  CLOSE c_chk_atg_cal;
  RETURN TRUE;

END IS_ATG_INSTALLED;

END PN_ATG_IS_INSTL_PKG;

/
