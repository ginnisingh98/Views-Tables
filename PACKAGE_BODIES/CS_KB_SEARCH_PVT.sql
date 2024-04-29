--------------------------------------------------------
--  DDL for Package Body CS_KB_SEARCH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_KB_SEARCH_PVT" AS
/* $Header: cskbschb.pls 120.0 2005/06/01 15:35:50 appldev noship $ */

FUNCTION Get_Set_Usage_Count( p_set_id  IN NUMBER ) RETURN NUMBER
IS
   l_total NUMBER := 0;
   Cursor Gt_usage_count_csr(p_set_id in NUMBER) IS
    select nvl(cs_kb_set_used_sums.used_count, 0)
    from cs_kb_set_used_sums, cs_kb_used_sum_defs_b
    where cs_kb_set_used_sums.def_id = cs_kb_used_sum_defs_b.def_id
    and cs_kb_used_sum_defs_b.default_flag = 'Y'
    and cs_kb_set_used_sums.set_id = p_set_id;
BEGIN

  If p_set_id Is Not Null  Then
    Open Gt_usage_count_csr(p_set_id);
    Fetch Gt_usage_count_csr Into l_total;
    Close Gt_usage_count_csr;
  End If;

  Return l_total;
EXCEPTION
  WHEN OTHERS THEN
   Return 0;
END;


END CS_KB_SEARCH_PVT;

/
