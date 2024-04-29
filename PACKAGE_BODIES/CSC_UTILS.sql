--------------------------------------------------------
--  DDL for Package Body CSC_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSC_UTILS" AS
/* $Header: cscutilb.pls 120.1 2005/08/24 01:51 tpalaniv noship $ */

FUNCTION Isvalid_dashboard_group_id(p_group_id IN csc_prof_groups_b.group_id%TYPE)
RETURN BOOLEAN IS

l_dbgroup_flag VARCHAR2(1) := 'N';

BEGIN
       SELECT use_in_customer_dashboard
         INTO l_dbgroup_flag
	 FROM csc_prof_groups_b
        WHERE group_id = p_group_id;

	IF l_dbgroup_flag = 'Y' THEN
	RETURN TRUE;
	ELSE
	RETURN FALSE;
	END IF;

EXCEPTION
WHEN OTHERS THEN
RETURN FALSE;

END Isvalid_dashboard_group_id;


END CSC_UTILS;

/
