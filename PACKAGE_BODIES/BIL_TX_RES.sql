--------------------------------------------------------
--  DDL for Package Body BIL_TX_RES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIL_TX_RES" AS
/* $Header: biltxrsb.pls 120.0 2005/10/12 13:29 sgharago noship $ */


FUNCTION rid RETURN NUMBER
IS
l_resource_id NUMBER;
l_group_id NUMBER;
l_manager VARCHAR2(1);
l_exception  VARCHAR2(1);


BEGIN

l_resource_id := BIL_TX_UTIL_RPT_PKG.GET_RESOURCE_ID;
l_group_id :=  BIL_TX_UTIL_RPT_PKG.get_sales_group_id;
l_exception := NULL;
BEGIN
	SELECT 'Y'
 	INTO l_manager
        FROM JTF_RS_GROUP_MBR_ROLE_VL
        WHERE resource_id = l_resource_id
        AND group_id = l_group_id
        AND (admin_flag = 'Y' OR
             manager_flag='Y')
        AND rownum < 2;

        EXCEPTION
	WHEN OTHERS THEN
		l_exception := 'Y';
	END;

IF l_manager = 'Y' THEN
	RETURN NULL;
ELSIF l_exception = 'Y' THEN
        RETURN l_resource_id;
ELSE
	RETURN l_resource_id;
END IF;

END rid;

FUNCTION IM RETURN VARCHAR2
IS
l_dummy varchar2(1);
l_resource_id NUMBER;
l_group_id  NUMBER;

BEGIN
l_resource_id := BIL_TX_UTIL_RPT_PKG.GET_RESOURCE_ID;
l_group_id :=  BIL_TX_UTIL_RPT_PKG.get_sales_group_id;

	BEGIN
	SELECT 'x'
	INTO l_dummy
        FROM  JTF_RS_GROUP_MBR_ROLE_VL
        WHERE resource_id = l_resource_id
        AND group_id = l_group_id
        AND (admin_flag = 'Y' OR
            	manager_flag='Y')
       	AND  rownum < 2;
	RETURN 'N';
EXCEPTION
WHEN OTHERS THEN
	RETURN 'Y';
END;
END IM;
END BIL_TX_RES;

/
