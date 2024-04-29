--------------------------------------------------------
--  DDL for Package BOM_COMMON_DEFINITIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_COMMON_DEFINITIONS" AUTHID CURRENT_USER as
/* $Header: BOMCONSS.pls 120.1 2005/08/15 17:58:22 snelloli noship $ */
/*==========================================================================+
|   Copyright (c) 1993 Oracle Corporation Belmont, California, USA          |
|                          All rights reserved.                             |
+===========================================================================+
|                                                                           |
| File Name    : BOMCONSS.pls                                               |
| Revision                                                                  |
| 09/05/96      seradhak    Initial Creation.                               |
+==========================================================================*/

G_Bom_SortCode_Width constant number := 7; -- 1 to 999,9999 components per level
SUBTYPE G_Bom_SortCode_Type  IS BOM_EXPLOSIONS.SORT_ORDER%TYPE ;
G_Bom_Init_SortCode constant VARCHAR2(2000) := '0000001';

G_BOM_PDH_SRCSYS_ID NUMBER  := 7;

FUNCTION get_initial_sort_code RETURN VARCHAR2;

FUNCTION Get_Pdh_Srcsys_Code RETURN NUMBER;

END Bom_Common_Definitions;

 

/
