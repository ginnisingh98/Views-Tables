--------------------------------------------------------
--  DDL for Package Body CS_KB_SETS_AUDIT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_KB_SETS_AUDIT_PKG" AS
/* $Header: cskbsab.pls 115.60 2003/08/28 21:21:26 mkettle noship $ */
/*======================================================================+
 |                Copyright (c) 1999 Oracle Corporation                 |
 |                   Redwood Shores, California, USA                    |
 |                        All rights reserved.                          |
 +======================================================================+
 | History                                                              |
 |  28-FEB-2001 Bate Yu  created                                        |
 |  14-AUG-2002 KLOU  (SEDATE)                                          |
 |              1. Add logic in create_set and update_set to validate   |
 |                 solution_type.                                       |
 |  24-Jan-2003 MKETTLE   added Submit_Solution and Update_Solution     |
 |  17-Mar-2003 MKETTLE  Performance fix on Is_Status_Valid Bug 2852868 |
 |  18-Jul-2003 MKETTLE  Added new 11.5.10 Secuirty columns             |
 |  12-Aug-2003 MKETTLE  Added Get_User_Soln_Access                     |
 |  13-Aug-2003 MKETTLE  Added CheckOut_Solution                        |
 |  28-Aug-2003 MKETTLE   11.5.10 Code Cleanup -> Private Solution apis |
 |                        moved to CS_KB_SOLUTION_PVT. Table Handlers   |
 |                        moved to CS_KB_SETS_PKG                       |
 +======================================================================*/


 FUNCTION Get_Published_Set_Id(
   P_SET_NUMBER IN VARCHAR2 )
 RETURN NUMBER
 IS
   l_count NUMBER;
   l_published_set_id NUMBER;
 BEGIN

  SELECT MAX(set_id)
  INTO l_published_set_id
  FROM CS_KB_SETS_B
  WHERE set_number = p_set_number
  AND status = 'PUB';

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;

  RETURN l_published_set_id;

 EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN ERROR_STATUS;
 END Get_Published_Set_Id;

END CS_KB_SETS_AUDIT_PKG;

/
