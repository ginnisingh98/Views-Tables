--------------------------------------------------------
--  DDL for Package Body PQH_DE_GRADE_COMPUTE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_DE_GRADE_COMPUTE" As
/* $Header: pqhgrdco.pkb 115.10 2002/12/10 06:10:00 vevenkat noship $ */

 Procedure PQH_DE_WC_COMPUTE
 (p_Wrkplc_Vldtn_Ver_Id In  Number,
  P_Business_Group_Id   In  Number,
  P_WC_Grade	        Out NOCOPY Varchar2,
  P_Wc_Case_group       Out NOCOPY Varchar2) is

 Cursor Jobftr_Unitperc is
 Select Sum(Nvl(Unit_Percentage,0)) Untperc , Job_Feature_Code
   from PQH_DE_WRKPLC_VLDTN_OPS a, PQH_DE_WRKPLC_VLDTN_Jobftrs b Where
        WRKPLC_VLDTN_VER_ID  = p_Wrkplc_Vldtn_Ver_Id   and
        a.Business_group_Id  = p_Business_Group_Id     and
        a.WRKPLC_VLDTN_OP_ID = WRKPLC_VLDTN_OPR_JOB_ID and
        WRKPLC_VLDTN_OPR_JOB_TYPE = 'O'                and
        a.Business_group_Id  = b.Business_Group_Id
        Group By Job_Feature_Code
        Order By To_Number(Job_Feature_Code) Desc;

 Cursor Case_group_Algor(p_Entity_Id In Varchar2) is
 Select Entity_Id, PARENT_HIERARCHY_NODE_ID, Nvl(Information2,0) Perc, Hierarchy_Version_Id
   from Per_gen_Hierarchy_Nodes
  Where Node_type = 'JOB_FTR'   and
        Entity_Id = p_Entity_Id and
        Hierarchy_Version_Id  in
        (Select HIERARCHY_VERSION_ID  from
                Per_gen_Hierarchy_Versions
          where Trunc(Sysdate) between Date_From and Nvl(date_To,Sysdate)
            and Hierarchy_Id in
           (Select Hierarchy_Id from
                   Per_Gen_Hierarchy
             Where type = 'REMUNERATION_REGULATION' and Business_Group_id=p_Business_Group_id))
             Order By Perc Desc;

 Cursor Grade(p_Hierarchy_Node_id In Varchar2, p_Hierarchy_Version_Id In Number) is
 Select a.Entity_Id, b.Entity_Id  from
        Per_gen_Hierarchy_Nodes b, Per_gen_Hierarchy_Nodes a
  Where a.Node_type             = 'CASE_GROUP'
    and a.Hierarchy_Node_id     = p_Hierarchy_Node_id
    and a.Hierarchy_Version_Id  = p_Hierarchy_Version_Id
    and b.HIERARCHY_NODE_ID     = a.PARENT_HIERARCHY_NODE_ID
    and b.Hierarchy_Version_Id  = a.Hierarchy_Version_Id;

 l_Grade_Status Varchar2(1) := 'N';
 l_UntPerct     Pqh_de_wrkplc_Vldtn_Ops.Unit_Percentage%TYPE;
 Begin
  P_WC_Grade := -4;
  Select Nvl(Sum(Unit_Percentage),0) into l_UntPerct
   From Pqh_de_wrkplc_Vldtn_Ops
   Where Wrkplc_Vldtn_Ver_Id = p_Wrkplc_Vldtn_Ver_Id;
   If l_UntPerct <> 100 Then
      P_WC_Grade := -1;
      Return;
   End If;
   For JobFtrrec in Jobftr_Unitperc
   Loop
     For Percrec in Case_group_Algor(JobFtrrec.Job_Feature_Code)
     Loop
       If Percrec.Perc <= JobFtrrec.Untperc Then
          Open Grade(Percrec.PARENT_HIERARCHY_NODE_ID, Percrec.Hierarchy_Version_Id);
          Fetch Grade into P_Wc_Case_group, P_WC_Grade;
          If Grade%ROWCOUNT > 1 then
             Close Grade;
             P_WC_Grade := -3;
             Return;
          End If;
          If Grade%FOUND Then
             Close Grade;
             Return;
          Else
             Close Grade;
             P_WC_Grade := -2;
             Return;
          End If;
          Return;
       End If;
     End Loop;
   End Loop;
Exception
When Others Then
  Hr_utility.Set_message(8302,sqlerrm);
  Hr_utility.raise_Error;
End;

 Procedure PQH_DE_CS_COMPUTE
 (P_GVNumber             In  Number,
  P_CS_Grade	         Out NOCOPY Number  ,
  p_cs_Grdnam            Out NOCOPY Varchar2) is

 Cursor Derive_Grad Is
 Select GRADE_ID
   From PQH_DE_RESULT_SETS
  Where P_GVNumber
Between GRADUAL_VALUE_NUMBER_FROM
   and  GRADUAL_VALUE_NUMBER_To;
 Begin

 hr_multi_message.enable_message_list;

 Open Derive_Grad;
 Fetch Derive_Grad into P_CS_Grade;
 If Derive_Grad%NOTFOUND Then
    Close Derive_Grad;
    Hr_utility.Set_message(8302,'PQH_DE_GRADE');
    Hr_utility.raise_Error;
 End If;
 If Derive_Grad%ROWCOUNT > 1 then
    Close Derive_Grad;
    Hr_utility.Set_message(8302,'PQH_DE_GRADE');
    Hr_utility.raise_Error;
 End If;
 p_cs_Grdnam := hr_general.Decode_grade(P_CS_Grade);
 Close Derive_Grad;
 Exception
 when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1 => 'PQH_DE_WRKPLC_VLDTN_VERS.GRADE'
       ) then
      -- raise;
           NULL;
    end if;
 End;

 Function Lookup_Meaning
 (P_Lookup_Type In Varchar2,
  P_Lookup_Code In Varchar2)
  Return Varchar2 Is
  Cursor C1 is
  Select Meaning
  from Hr_lookups
  where Lookup_Type  = p_lookup_Type and
        Lookup_Code  = P_Lookup_Code and
        Enabled_Flag = 'Y';
  l_Meaning Varchar2(80);
 Begin
  Open C1;
  Fetch C1 into l_Meaning;
  Close C1;
  Return L_Meaning;
 End;

 Function UNFreeze(P_Wrkplc_Vldtn_vern_Id In Number)
  Return Varchar2 is
   c_Frz varchar2(1);
   c_Frz_Enab_Dis number:=0;
  cursor c1(Vald_id number) is
   select count(*)  from
     Hr_all_Positions_F
     where INFORMATION_CATEGORY           = 'DE_PQH_WP'
       and Nvl(Information5,Information9) = To_Char(Vald_id);
  cursor c2(Vald_id number) is
   select     FREEZE
   from       pqh_de_wrkplc_vldtn_vers
   where      WRKPLC_VLDTN_VER_ID = Vald_id;
 Begin
 OPEN c2(P_Wrkplc_Vldtn_vern_Id);
 fetch c2 into c_Frz;
 CLOSE c2;
 if c_Frz = 'U' then
  return 'U';
 elsif c_Frz = 'F'
 then
  OPEN c1(P_Wrkplc_Vldtn_vern_Id);
  fetch c1 into c_Frz_Enab_Dis;
  CLOSE c1;
   if c_Frz_Enab_Dis > 0
     then
            Return 'D';
    else
         Return 'F';
   end if;
 end if;
 END;
End;

/
