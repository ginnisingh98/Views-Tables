--------------------------------------------------------
--  DDL for Package BOM_COMMON_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_COMMON_UTILS" AUTHID CURRENT_USER AS
/* $Header: BOMCUTLS.pls 120.0 2005/08/11 17:03:01 seradhak noship $ */
/*==========================================================================+
|   Copyright (c) 1995 Oracle Corporation, California, USA                  |
|                          All rights reserved.                             |
+===========================================================================+
|                                                                           |
| File Name    : BOMCUTLS.pls                                               |
| Description  : Bom Util Package 					    |
| Created By   : Selvakumaran Radhakrishnan                                 |
|                                                                           |
+==========================================================================*/

 FUNCTION CST_ROLLUP (
        X_Cost_Type_Id         IN NUMBER,
        X_Inventory_Item_Id    IN NUMBER,
        X_Effective_Date       IN DATE,
        X_Include_Unimp_ECO    IN NUMBER,
        X_Alternate_Bill       IN VARCHAR2,
        X_Alternate_Routing    IN VARCHAR2,
        X_Eng_Bill   	       IN NUMBER,
        X_Org_Id               IN NUMBER) RETURN NUMBER;

END BOM_Common_Utils;

 

/
