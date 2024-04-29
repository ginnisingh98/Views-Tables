--------------------------------------------------------
--  DDL for Package Body PER_JP_REPORT_COMMON_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_JP_REPORT_COMMON_PKG" 
-- $Header: pejpcmrp.pkb 120.0.12010000.7 2009/07/20 16:50:06 mdarbha noship $
-- *************************************************************************
-- * Copyright (c) Oracle Corporation Japan,2009       Product Development.
-- * All rights reserved
-- *************************************************************************
-- *
-- * PROGRAM NAME
-- * pejpcmrp.pkb
-- *
-- * DESCRIPTION
-- * This script creates the package body of per_jp_report_common_pkg
-- *
-- * DEPENDENCIES
-- *   None
-- *
-- * CALLED BY
-- *   Concurrent Program
-- *
-- * LAST UPDATE DATE   08-JUN-2009
-- *   Date the program has been modified for the last time
-- *
-- * HISTORY
-- * =======
-- *
-- * DATE        AUTHOR(S)  VERSION           BUG NO     DESCRIPTION
-- * -----------+---------+-----------------+----------+------------------------------------------------------------------------------------------------------------------------------------------
-- * 26-MAY-2009 SPATTEM    120.0.12010000.1  8558615    Creation
-- * 08-JUN-2009 SPATTEM    120.0.12010000.2  8558615    Changes done as per review Comments
-- * 23-JUN-2009 SPATTEM    120.0.12010000.5  8623767    Changed the lcu_org_hierarchy query to get data from all levels.
-- * 12-JUL-2009 MDARBHA   120.0.12010000.6  8667163    Changed the lcu_org_hierarchy query to get all the organizations related to a Business Group
--                                                                                            Added cursor lcu_org_hierarchy query_nn to get the organizations in case the Organization parameter is null.
--* 20-JUL-2009 MDARBHA   120.0.12010000.7  8675479    Changed the lcu_org_hierarchy query to get only the organizations from primary hierarchy
--
-- *********************************************************************************************************************************
AS
--
  gb_debug                BOOLEAN;
--
  FUNCTION get_org_hirerachy(p_business_group_id     IN per_assignments_f.business_group_id%TYPE
                            ,p_organization_id       IN per_assignments_f.organization_id%TYPE
                            ,p_include_org_hierarchy IN VARCHAR2
                            )
  RETURN gt_org_tbl
  AS
--
--  bug # 8623767 - Modified the query to get all levels in hierarchy
-- bug # 8667163 -Modified to get all the organizations related to a Business Group
    CURSOR lcu_org_hierarchy
    IS
    SELECT organization_id
    FROM   hr_all_organization_units
    WHERE  business_group_id=p_business_group_id
	AND    organization_id NOT IN(SELECT business_group_id
	                             FROM hr_organization_units
								 WHERE business_group_id=p_business_group_id);
--
--	bug # 8667163 -Modified to get all the organizations related to a Organization Passed as a parameter.
    CURSOR lcu_org_hierarchy_nn
    IS
    SELECT DISTINCT POSE.organization_id_child organization_id
    FROM   per_org_structure_elements POSE
	      ,per_organization_structures POS
	      ,per_org_structure_versions POSV
    WHERE  POSE.business_group_id                 = p_business_group_id
    AND    p_include_org_hierarchy                = 'Y'
    AND    POSV.org_structure_version_id = POSE.org_structure_version_id
	AND    POS.primary_structure_flag='Y'
	AND    POS.organization_structure_id = POSV.organization_structure_id
    START   WITH POSE.organization_id_parent      = p_organization_id
    CONNECT BY PRIOR POSE.organization_id_child   = POSE.organization_id_parent;
--
    lt_org_id    gt_org_tbl;
    ln_index    NUMBER := 0;
--
  BEGIN
--
  gb_debug := hr_utility.debug_enabled;
--
  IF gb_debug THEN
      hr_utility.set_location ('In Organization Hierarchy Package',10);
  END IF;
--
  IF p_business_group_id = p_organization_id  THEN
--
	IF gb_debug THEN
      hr_utility.set_location ('Business_group_id=Organization_id',10);
    END IF;
--
    FOR lr_org_hierarchy IN lcu_org_hierarchy
      LOOP
        ln_index := ln_index + 1;
        lt_org_id(ln_index)  := lr_org_hierarchy.organization_id;
--
		IF gb_debug THEN
         hr_utility.set_location (lr_org_hierarchy.organization_id,10);
        END IF;
--
    END LOOP;
  ELSE
     FOR lr_org_hierarchy IN lcu_org_hierarchy_nn
       LOOP
         ln_index := ln_index + 1;
         lt_org_id(ln_index)  := lr_org_hierarchy.organization_id;
--
		 IF gb_debug THEN
         hr_utility.set_location (lr_org_hierarchy.organization_id,10);
        END IF;
--
    END LOOP;
  END IF;
--
    ln_index := ln_index + 1;
    lt_org_id(ln_index)  := p_organization_id;
--
	IF gb_debug THEN
         hr_utility.set_location (p_organization_id,10);
    END IF;
--
    RETURN lt_org_id;
--
  END get_org_hirerachy;

END per_jp_report_common_pkg;

/
