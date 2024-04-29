--------------------------------------------------------
--  DDL for Package Body GL_AUTO_ALLOC_VW_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_AUTO_ALLOC_VW_PKG" AS
/* $Header: glalvwfb.pls 120.3 2005/05/05 02:01:27 kvora ship $ */

FUNCTION Get_Batch_Name(BATCH_TYPE_CODE IN VARCHAR2,
                        BATCH_ID        IN NUMBER ) RETURN VARCHAR2 IS
  Cursor Allocation_Batch Is
  Select Name
  From gl_alloc_batches
  Where Allocation_Batch_Id = BATCH_ID
  And Actual_flag = BATCH_TYPE_CODE ;

  Cursor Recurring_Batch Is
  Select Name
  From Gl_Recurring_Batches
  Where Recurring_Batch_Id =  BATCH_ID
  And Budget_Flag = 'N';

  Cursor Project_Batch Is
  Select rule_name
  From pa_alloc_rules_all
  Where rule_id = BATCH_ID;

 l_batch_name Varchar2(60) := NULL;

Begin
  If BATCH_TYPE_CODE In ('A','B','E') then
     Open Allocation_Batch;
     Fetch Allocation_Batch into l_batch_name;
     if l_batch_name is NOT NULL Then
        Return(l_batch_name);
     End If;
     Close Allocation_Batch;
  ElsIf BATCH_TYPE_CODE = 'R' Then
     Open Recurring_Batch;
     Fetch Recurring_Batch into l_batch_name;
     if l_batch_name is NOT NULL Then
        Return(l_batch_name);
     End If;
     Close Recurring_Batch;
  Elsif BATCH_TYPE_CODE = 'P' Then
    Open Project_Batch;
    Fetch Project_Batch into l_batch_name;
     if l_batch_name is NOT NULL Then
        Return(l_batch_name);
     End If;
     Close Project_Batch;

  End If;
End;


FUNCTION Get_Owner_Dsp (OWNER IN VARCHAR2) RETURN VARCHAR2  IS
Cursor dsp_name Is
       Select Display_Name
       From GL_WF_ROLES_V
       Where Name = OWNER;
l_dsp_name VARCHAR2(240);
Begin
 If OWNER Is NULL Then
   Return Null;
 Else
   Open dsp_name;
   Fetch dsp_name into l_dsp_name;
   Close dsp_name;
   Return l_dsp_name;
 End if;
End Get_Owner_Dsp;


END gl_auto_alloc_vw_pkg;

/
