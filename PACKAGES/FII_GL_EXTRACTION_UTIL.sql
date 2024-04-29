--------------------------------------------------------
--  DDL for Package FII_GL_EXTRACTION_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_GL_EXTRACTION_UTIL" AUTHID CURRENT_USER AS
/* $Header: FIIGLXUS.pls 120.1 2005/10/30 05:13:07 appldev noship $ */

----------------------------------------
-- procedure load_ccc_mgr
--
-- Load global temporary table FII_CCC_MGR_GT if it is empty.
-- Set p_retcode to 0 for normal termination.
-- Set p_retcode to -1 for any exception.
----------------------------------------
PROCEDURE LOAD_CCC_MGR(
	p_retcode	out nocopy varchar2
);

----------------------------------------
-- function check_missing_ccc_mgr
--
-- Call procedure load_ccc_mgr.
-- Return the number of ccc_org_id(s) in global temporary table
-- FII_CCC_MGR_GT with missing current manager.
-- If there is no such ccc_org_id, return 0.
-- If there are such ccc_org_id(s), return the number, and print
-- details to the concurrent program output file.
----------------------------------------
FUNCTION CHECK_MISSING_CCC_MGR RETURN NUMBER;

----------------------------------------
-- procedure Get_UNASSIGNED_ID
-- Return the Unassigned node id
-- and the value set id
-- Set p_retcode to -1 for any exception.
----------------------------------------
PROCEDURE Get_UNASSIGNED_ID(p_UNASSIGNED_ID out nocopy number, p_UNASSIGNED_VSET_ID out nocopy number,
    p_retcode out nocopy varchar2
);

END FII_GL_EXTRACTION_UTIL;

 

/
