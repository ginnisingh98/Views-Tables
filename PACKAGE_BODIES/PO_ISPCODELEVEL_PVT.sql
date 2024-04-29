--------------------------------------------------------
--  DDL for Package Body PO_ISPCODELEVEL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_ISPCODELEVEL_PVT" AS
/* $Header: PO_ISPCODELEVEL_PVT.plb 120.0.12010000.2 2010/02/11 10:36:06 sthoppan noship $ */

--Function helps to obtain the current code level of isp supplier
FUNCTION get_curr_isp_supp_code_level
RETURN NUMBER
IS
l_code_level NUMBER;
BEGIN

  -- Value 10 indicates that the code level is R12 base
	l_code_level := 20;
	return l_code_level;

END get_curr_isp_supp_code_level;

END PO_ISPCODELEVEL_PVT;

/
