--------------------------------------------------------
--  DDL for Package Body BOM_COMMON_DEFINITIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_COMMON_DEFINITIONS" as
/* $Header: BOMCONSB.pls 120.1 2005/08/15 17:58:45 snelloli noship $ */
/*==========================================================================+
|   Copyright (c) 1993 Oracle Corporation Belmont, California, USA          |
|                          All rights reserved.                             |
+===========================================================================+
|                                                                           |
| File Name    : BOMCONSS.pls                                               |
| Revision                                                                  |
| 09/05/96      seradhak    Initial Creation.                               |
+==========================================================================*/

 FUNCTION get_initial_sort_code
 RETURN VARCHAR2
 IS
 BEGIN
  return G_Bom_Init_SortCode;
 END get_initial_sort_code;

 FUNCTION Get_Pdh_Srcsys_Code
  RETURN NUMBER
  IS
  BEGIN
  return G_BOM_PDH_SRCSYS_ID;
 END Get_Pdh_Srcsys_Code;

END Bom_Common_Definitions;

/
