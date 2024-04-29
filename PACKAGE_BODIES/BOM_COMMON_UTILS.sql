--------------------------------------------------------
--  DDL for Package Body BOM_COMMON_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_COMMON_UTILS" AS
/* $Header: BOMCUTLB.pls 120.1 2005/08/12 12:13:04 seradhak noship $ */
/*==========================================================================+
|   Copyright (c) 1995 Oracle Corporation, California, USA                  |
|                          All rights reserved.                             |
+===========================================================================+
|                                                                           |
| File Name    : BOMCUTLB.pls                                               |
| Description  : Bom Util Package 					    |
| Created By   : Selvakumaran Radhakrishnan                                 |
|                                                                           |
+==========================================================================*/

 FUNCTION CST_ROLLUP (
 	       X_Cost_Type_Id      IN NUMBER,
 	       X_Inventory_Item_Id IN NUMBER,
 	       X_Effective_Date    IN DATE,
 	       X_Include_Unimp_ECO IN  NUMBER,
 	       X_Alternate_Bill    IN VARCHAR2,
 	       X_Alternate_Routing IN VARCHAR2,
 	       X_Eng_Bill          IN NUMBER,
 	       X_Org_Id            IN NUMBER) Return NUMBER IS
 PRAGMA autonomous_transaction;


  L_Lock_Flag          VARCHAR2(10);
  L_default_org        number;
  L_Default_Cost_Type  NUMBER;
  L_Quantity_Precision VARCHAR2(2);
  L_Trace_Mode         VARCHAR2(1);
  l_req_id             NUMBER;

  Cursor Default_Cost_Type_Id
  (X_Cost_Type_Id IN NUMBER) IS
  Select default_cost_type_id
  From CST_COST_TYPES CCT
  Where CCT.cost_type_id = X_Cost_Type_Id;

  BEGIN
      /* Getting all the parameters set for Rollup. */
      FND_PROFILE.Get('CST_RU_WAIT_FOR_LOCKS', L_Lock_Flag);
      Open Default_Cost_Type_Id(X_Cost_Type_Id);
      Fetch Default_Cost_Type_Id into L_Default_Cost_Type;
      Close Default_Cost_Type_Id;

      FND_PROFILE.Get('REPORT_QUANTITY_PRECISION',L_Quantity_Precision);
      FND_PROFILE.Get('MRP_TRACE', L_Trace_Mode);
      FND_PROFILE.GET('MFG_ORGANIZATION_ID',L_default_org);


      --dbms_output.put_line('date is '|| X_Effective_Date);
      --dbms_output.put_line('defaul cost_type is '|| L_Default_Cost_Type);
      --dbms_output.put_line('defaul L_Quantity_Precision is '|| L_Quantity_Precision);
      --dbms_output.put_line('defaul L_Lock_Flag is '|| L_Lock_Flag);
      --dbms_output.put_line('defaul L_default_org is '|| L_default_org);
      --dbms_output.put_line('defaul L_Trace_Mode is '|| L_Trace_Mode);
      --dbms_output.put_line('X_Cost_Type_Id is '|| X_Cost_Type_Id);
      --dbms_output.put_line('X_Inventory_Item_Id  is '|| X_Inventory_Item_Id);
      --dbms_output.put_line('X_Include_Unimp_ECO  is '|| X_Include_Unimp_ECO);
      --dbms_output.put_line('X_Alternate_Bill  is '|| X_Alternate_Bill);
      --dbms_output.put_line('X_Eng_Bill  is '|| X_Eng_Bill);
      --dbms_output.put_line('X_Org_Id  is '|| X_Org_Id);



      /*
      ** YEAR 2000 NOTE:  There is a "YY" here.  I know that.  The
      **   reason is this.  First of all, the PL/SQL (version 1.0)
      **   embedded within Forms 4.5.6 is *NOT* aware of how to
      **   resolve the "RR" date mask.  Secondly, using "YY" and
      **   "RR" in a call to to_char (as we're doing here) is
      **   functionally the same.  So, to hit the database just to
      **   remove the reference to "YY" is not worth it.  We'll
      **   live.  (BTW, Eric said this is OK.)
      */
    l_req_id := FND_REQUEST.SUBMIT_REQUEST('BOM', 'CSTRSCCRP',
        NULL, NULL, NULL, L_Lock_Flag,L_default_org,
        NULL,To_Char(X_Cost_Type_Id),To_Char(X_Org_Id),NULL,NULL,NULL,'Corporate',
        To_Char(L_Default_Cost_Type), '1','2','1',
        '1', '1', '1', '1', '1',
        To_Char(X_Effective_Date,'YYYY/MM/DD HH24:MI'),
        To_Char(X_Include_Unimp_ECO), X_Alternate_Bill, X_Alternate_Routing,
        To_Char(X_Eng_Bill), '1',NULL, '1',NULL, To_Char(X_Inventory_Item_Id),
        NULL, NULL, NULL,
        NULL, NULL, NULL,'1','FORM',
        L_Quantity_Precision, L_Trace_Mode, chr(0),
        NULL, NULL, NULL, NULL,NULL, NULL,NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        NULL, NULL, NULL,NULL);
    --dbms_output.put_line('defaul l_req_id is '|| l_req_id);
    COMMIT;
    RETURN l_req_id;
  EXCEPTION
    WHEN OTHERS THEN
    --dbms_output.put_line('EXCEPTION OCCURRED in PL/sql'||SQLERRM);
    ROLLBACK;
    RETURN 0;
  END CST_ROLLUP;

END BOM_Common_Utils;

/
