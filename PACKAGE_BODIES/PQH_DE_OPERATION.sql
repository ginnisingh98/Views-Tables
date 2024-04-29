--------------------------------------------------------
--  DDL for Package Body PQH_DE_OPERATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_DE_OPERATION" As
/* $Header: pqoprpln.pkb 115.9 2002/12/12 05:23:23 vevenkat noship $ */
Procedure Insert_Rec
(p_BUSINESS_GROUP_ID              IN  NUMBER
,p_effective_Date                 IN  Date
,p_ENTITY_ID                      IN  Varchar2
,P_Parent_Entity_Id               IN  Number    Default NULL
,p_Operation_Group                IN  Number
,p_TRN_TYPE                       IN  Varchar2
,p_HIERARCHY_NODE_ID              Out NOCOPY NUMBER
,p_Status                         Out NOCOPY Varchar2
,p_Object_Version_Number          Out NOCOPY Number) Is

l_Hierarchy_Version_Id         Per_gen_Hierarchy_Versions.Hierarchy_Version_Id%TYPE;
l_Hierarchy_Node_Id            Per_gen_Hierarchy_Nodes.Hierarchy_Node_Id%TYPE;
l_Parent_Hierarchy_Node_Id     Per_gen_Hierarchy_Nodes.Parent_Hierarchy_Node_Id%TYPE;
l_Node_type                    Per_gen_Hierarchy_Nodes.Node_Type%TYPE;
l_seq                          Per_gen_Hierarchy_Nodes.Seq%TYPE;
l_proc                         Varchar2(100) := 'Pqh_De_Operation.Insert_Rec';

 Cursor Entity is
 Select Hierarchy_Node_id
   from Per_gen_Hierarchy_Nodes a, Pqh_de_operations b
  Where Parent_hierarchy_Node_id = p_Operation_Group
    and Node_type                = 'OPR_OPTS'
        and Entity_Id            = b.Operation_Number
    and b.Operation_Id           = P_Parent_Entity_Id;

 Cursor Versions is
  Select Hierarchy_version_Id
    from Per_gen_hierarchy_Nodes
   where Hierarchy_Node_Id = p_Operation_Group;

Begin
p_Status := 'Y';

Open Versions;
Fetch Versions into l_Hierarchy_version_id;
Close Versions;

If p_Trn_Type   = 'O' then
   l_Node_type := 'OPR_OPTS';
   l_Parent_Hierarchy_Node_Id := P_Operation_group;
Else
   l_Node_type := 'OPR_JOB_DTLS';
   Open Entity;
   Fetch Entity into l_Parent_Hierarchy_Node_Id;
   If Entity%NOTFOUND Then
      p_Status := 'N';
      Close Entity;
      Return;
   End If;
   Close Entity;
End If;

Select Nvl(Max(Seq),0) + 1
  Into l_seq
  From Per_gen_Hierarchy_Nodes
 Where Hierarchy_Version_Id = l_Hierarchy_Version_Id
   and Node_type            = l_Node_Type;

Select Per_Gen_Hierarchy_Nodes_s.nextval
  into l_Hierarchy_Node_Id from Dual;

Insert into
Per_Gen_Hierarchy_Nodes
(HIERARCHY_NODE_ID, BUSINESS_GROUP_ID, ENTITY_ID, HIERARCHY_VERSION_ID,
 NODE_TYPE, PARENT_HIERARCHY_NODE_ID, SEQ, Object_Version_Number)
Values
(l_Hierarchy_Node_Id, p_BUSINESS_GROUP_ID, p_ENTITY_ID,l_Hierarchy_version_Id,
 l_Node_type, l_Parent_Hierarchy_Node_Id,l_seq, 1);

Exception
when app_exception.application_exception then
    if hr_multi_message.exception_add
       (p_associated_column1 => 'PER_GEN_HIERARCHY_NODES.HIERARCHY_VERSION_ID') then
       hr_utility.set_location(' Leaving:'||l_proc,60);
       raise;
    end if;
    hr_utility.set_location(' Leaving:'||l_proc,70);
End;

Procedure Populate_Operations
(p_Business_group_Id             IN Number
,p_Vldtn_Ver_Op_Id               IN Number
,p_Hierarchy_Node_Id  		 IN Number
,p_Trn_Type                      IN Varchar2
,p_Operation_Job_Number          IN Varchar2
,p_Operation_Job_Id              IN Number) is

l_Hierarchy_Node_Id      Per_Gen_Hierarchy_nodes.Hierarchy_node_Id%TYPE;
l_desc                   Pqh_De_Operations.Description%TYPE;
l_Job_Id                 Pqh_de_Tatigkeit_details.TATIGKEIT_DETAIL_ID%TYPE;
l_Wrkplc_Vldtn_Op_Id     Pqh_de_Wrkplc_Vldtn_ops.Wrkplc_Vldtn_Op_Id%TYPE;
l_WRKPLC_VLDTN_JObFTR_ID Pqh_de_Wrkplc_Vldtn_JobFtrs.WRKPLC_VLDTN_JObFTR_ID%TYPE;
l_Object_Version_Number  Pqh_de_Wrkplc_Vldtn_ops.Object_Version_Number%TYPE;
l_Wrkplc_Vldtn_Job_Id    Pqh_de_Wrkplc_Vldtn_Jobs.Wrkplc_Vldtn_Job_Id%TYPE;


/* Cursor Operations is
Select Decode(Node_Type,'OPR_OPTS','O','OPR_JOB_DTLS','J','OPR_JOB_FTR','F'), Entity_Id
  From Per_Gen_Hierarchy_Nodes
 Where Hierarchy_Version_Id   = l_Hierarchy_version_Id
 Start With Hierarchy_node_id = p_Hierarchy_Node_id
 Connect By Parent_Hierarchy_Node_Id = Prior Hierarchy_Node_Id; */

Cursor op_desc Is
Select Description
  From Pqh_De_Operations
 Where OPERATION_NUMBER = p_Operation_Job_Number;

Cursor Job_desc(p_Job_Number In Varchar2) is
Select TATIGKEIT_DETAIL_ID, Description
  From Pqh_de_Tatigkeit_details
 Where TATIGKEIT_NUMBER = p_Job_Number;

Cursor Operations(p_Hierarchy_Node_Id In Number) is
Select Entity_Id, Node_Type, Hierarchy_Node_Id
  from Per_Gen_Hierarchy_Nodes
 Where Parent_Hierarchy_Node_id = p_Hierarchy_Node_Id;


Cursor Jobs(p_Hierarchy_Node_Id In Number) is
Select Entity_Id, Node_Type, Hierarchy_Node_Id
  from Per_Gen_Hierarchy_Nodes
 Where Parent_Hierarchy_Node_id = p_Hierarchy_Node_Id;

Begin
If p_Trn_TYpe = 'O' Then
   Open  op_desc;
   Fetch op_desc into l_desc;
                                                        -- BUG FIX 2281356
                   -- if op_desc do not exist it means you havent selected operation so raise exception
   If op_desc%NOTFOUND then
      Close op_Desc;
      hr_utility.set_message(8302, 'PQH_DE_INVALD_OP_SELECT');
   hr_utility.raise_error;
   end if;

   Close op_Desc;
   -- Operations API

   PQH_DE_VLDOPR_API.Insert_Vldtn_Oprn
   (p_effective_date         => Trunc(Sysdate)
   ,p_business_group_id      => P_Business_Group_Id
   ,p_WRKPLC_VLDTN_VER_ID    => p_Vldtn_Ver_Op_Id
   ,P_WRKPLC_OPERATION_ID    => p_Operation_Job_Id
   ,P_DESCRIPTION            => l_Desc
   ,P_UNIT_PERCENTAGE        => NULL
   ,P_WRKPLC_VLDTN_OP_ID     => l_Wrkplc_Vldtn_Op_Id
   ,p_object_version_number  => l_Object_Version_Number);

  For Oprrec in OPerations(p_Hierarchy_Node_Id)
  Loop

  If Oprrec.Node_Type = 'OPR_JOB_FTR' Then

     PQH_DE_VLDJOBFTR_API.Insert_Vldtn_JObftr
     (p_effective_date            => Trunc(Sysdate)
     ,p_business_group_id         => p_Business_Group_Id
     ,p_WRKPLC_VLDTN_OPR_JOB_ID   => l_Wrkplc_Vldtn_Op_Id
     ,P_JOB_FEATURE_CODE          => Oprrec.Entity_Id
     ,P_Wrkplc_Vldtn_Opr_job_Type => 'O'
     ,P_WRKPLC_VLDTN_JObFTR_ID    => l_WRKPLC_VLDTN_JObFTR_ID
     ,p_object_version_number     => l_Object_Version_Number);

  Elsif Oprrec.Node_Type = 'OPR_JOB_DTLS' Then


      Open  Job_desc(Oprrec.Entity_Id);
      Fetch Job_desc into l_Job_Id, l_desc;
      Close Job_Desc;

      PQH_DE_VLDJOB_API.Insert_Vldtn_JOb
      (p_effective_date           => Trunc(Sysdate)
      ,p_business_group_id        => p_Business_Group_Id
      ,p_WRKPLC_VLDTN_OP_ID       => l_Wrkplc_Vldtn_Op_Id
      ,P_WRKPLC_JOB_ID            => l_Job_Id
      ,P_DESCRIPTION              => l_desc
      ,P_WRKPLC_VLDTN_JOb_ID      => l_Wrkplc_Vldtn_Job_Id
      ,p_object_version_number    => l_Object_Version_Number);



      For Jobrec in Jobs(Oprrec.Hierarchy_Node_id)
      Loop
          PQH_DE_VLDJOBFTR_API.Insert_Vldtn_JObftr
          (p_effective_date            => Trunc(Sysdate)
          ,p_business_group_id         => p_Business_Group_Id
          ,p_WRKPLC_VLDTN_OPR_JOB_ID   => l_Wrkplc_Vldtn_Job_Id
          ,P_JOB_FEATURE_CODE          => Jobrec.Entity_Id
          ,P_Wrkplc_Vldtn_Opr_job_Type => 'J'
          ,P_WRKPLC_VLDTN_JObFTR_ID    => l_WRKPLC_VLDTN_JObFTR_ID
          ,p_object_version_number     => l_Object_Version_Number);
      End Loop;

  End If;
  End Loop;
Else
  Open  Job_desc(p_Operation_Job_Number);
  Fetch Job_desc into l_Job_Id, l_desc;
                                                       -- BUG FIX 2281356
                     -- if job_desc do not exist it means you havent selected job so raise exception
     If Job_desc%NOTFOUND then
        Close Job_Desc;
        hr_utility.set_message(8302, 'PQH_DE_INVALD_JOB_SELECT');
   hr_utility.raise_error;
   end if;
  Close Job_Desc;

  PQH_DE_VLDJOB_API.Insert_Vldtn_JOb
  (p_effective_date           => Trunc(Sysdate)
  ,p_business_group_id        => p_Business_Group_Id
  ,p_WRKPLC_VLDTN_OP_ID       => p_Vldtn_Ver_Op_Id
  ,P_WRKPLC_JOB_ID            => p_Operation_Job_Id
  ,P_DESCRIPTION              => l_desc
  ,P_WRKPLC_VLDTN_JOb_ID      => l_Wrkplc_Vldtn_Job_Id
  ,p_object_version_number    => l_Object_Version_Number);

   For Jobrec in Jobs(p_Hierarchy_node_id)
   Loop
       PQH_DE_VLDJOBFTR_API.Insert_Vldtn_JObftr
       (p_effective_date            => Trunc(Sysdate)
       ,p_business_group_id         => p_Business_Group_Id
       ,p_WRKPLC_VLDTN_OPR_JOB_ID   => l_Wrkplc_Vldtn_Job_Id
       ,P_JOB_FEATURE_CODE          => Jobrec.Entity_Id
       ,P_Wrkplc_Vldtn_Opr_job_Type => 'J'
       ,P_WRKPLC_VLDTN_JObFTR_ID    => l_WRKPLC_VLDTN_JObFTR_ID
       ,p_object_version_number     => l_Object_Version_Number);
   End Loop;

End If;
End;

Procedure Populate_Operation_PLan
(p_WRKPLC_VLDTN_VER_ID           IN Number
,p_Business_group_Id             IN Number
,p_Effective_Date                IN Date) is

l_Hierarchy_Node_Id              Per_gen_Hierarchy_Nodes.Hierarchy_Node_Id%TYPE;
l_JHierarchy_Node_Id             Per_gen_Hierarchy_Nodes.Hierarchy_Node_Id%TYPE;
l_Hierarchy_Version_Id           Per_Gen_Hierarchy_Nodes.Hierarchy_Version_Id%TYPE;
l_Parent_Hierarchy_Node_Id       Per_Gen_Hierarchy_nodes.Parent_Hierarchy_Node_Id%TYPE;
l_Node_type                      Per_Gen_Hierarchy_nodes.Node_Type%TYPE;
l_oprHierarchy_Node_Id           Per_gen_Hierarchy_Nodes.Hierarchy_Node_Id%TYPE;
l_oprHierarchy_Version_Id        Per_Gen_Hierarchy_Nodes.Hierarchy_Version_Id%TYPE;
l_oprParent_Hierarchy_Node_Id    Per_Gen_Hierarchy_nodes.Parent_Hierarchy_Node_Id%TYPE;
l_oprNode_type                   Per_Gen_Hierarchy_nodes.Node_Type%TYPE;
l_seq                            Per_Gen_Hierarchy_nodes.Seq%TYPE;

Cursor Operations is
Select WRKPLC_VLDTN_OP_ID, OPERATION_NUMBER, WRKPLC_OPERATION_ID
  From Pqh_de_operations a, Pqh_De_Wrkplc_Vldtn_Ops b
 Where WRKPLC_VLDTN_VER_ID = p_WRKPLC_VLDTN_VER_ID
   and a.Operation_Id = WRKPLC_OPERATION_ID;

Cursor Jobs(p_WRKPLC_VLDTN_OP_ID in Number) is
Select WRKPLC_VLDTN_JOB_ID, b.DESCRIPTION,
       WRKPLC_JOB_ID, TATIGKEIT_NUMBER
  From PQH_DE_TATIGKEIT_DETAILS a, Pqh_De_Wrkplc_Vldtn_JObs b
 Where WRKPLC_VLDTN_OP_ID    = p_WRKPLC_VLDTN_OP_ID
   and a.TATIGKEIT_DETAIL_ID = WRKPLC_JOB_ID;

Cursor JobFtrs(p_WRKPLC_VLDTN_OPR_JOB_ID In Number, Type In Varchar2) Is
Select WRKPLC_VLDTN_JOBFTR_ID, WRKPLC_VLDTN_OPR_JOB_ID
             JOB_FEATURE_CODE, WRKPLC_VLDTN_OPR_JOB_TYPE
  From Pqh_De_Wrkplc_Vldtn_Jobftrs
 Where WRKPLC_VLDTN_OPR_JOB_ID   = p_WRKPLC_VLDTN_OPR_JOB_ID
   and WRKPLC_VLDTN_OPR_JOB_TYPE = Type;

Cursor Hierarchy_Data(p_Entity_Id In VARCHAR2, P_Node_Type in Varchar2) is
Select Hierarchy_Node_Id, a.Hierarchy_Version_Id, Parent_Hierarchy_Node_Id, Node_type
  From Per_Gen_Hierarchy_Nodes a, Per_gen_hierarchy_Versions b
 Where Node_Type = P_Node_Type
   and Entity_Id = p_Entity_Id
   and b.Hierarchy_Version_Id = a.Hierarchy_Version_Id
   and trunc(P_effective_Date) between date_From and nvl(Date_To,trunc(P_effective_Date));

cursor Seq(p_OprHierarchy_Node_Id In Number, p_Node_Type in Varchar2) Is
Select Nvl(Max(Seq),0) + 1
  From Per_Gen_Hierarchy_Nodes
 Where Node_type = p_Node_type
   and Parent_Hierarchy_Node_id = p_OprHierarchy_Node_Id;

Begin
For Oprrec in OPerations
Loop
 l_oprHierarchy_Node_Id        := NULL;
 l_OprHierarchy_Version_Id     := NULL;
 l_OprParent_Hierarchy_Node_Id := NULL;
 l_OprNode_type                := NULL;
 if( Hierarchy_Data%ISOPEN) THEN
 close Hierarchy_Data;
 END IF;
 Open Hierarchy_Data(Oprrec.OPERATION_NUMBER, 'OPR_OPTS');
 Fetch Hierarchy_Data into l_OprHierarchy_Node_Id, l_OprHierarchy_Version_Id, l_OprParent_Hierarchy_Node_Id, l_OprNode_type;

 If Hierarchy_Data%FOUND Then
  close Hierarchy_Data;
    For Jobrec in Jobs(Oprrec.WRKPLC_VLDTN_OP_ID)
    Loop
        l_Hierarchy_Node_Id        := NULL;
        l_Hierarchy_Version_Id     := NULL;
        l_Parent_Hierarchy_Node_Id := NULL;
        l_Node_type                := NULL;

        Open Hierarchy_Data(Jobrec.TATIGKEIT_NUMBER, 'OPR_JOB_DTLS');
        Fetch Hierarchy_Data into l_Hierarchy_Node_Id, l_Hierarchy_Version_Id, l_Parent_Hierarchy_Node_Id, l_Node_type;
        If Hierarchy_Data%NotFound Then
           Close Hierarchy_Data;
           Select Per_gen_Hierarchy_Nodes_s.Nextval into l_JHierarchy_Node_Id from Dual;
           l_Seq := Null;
           Open Seq(l_OprParent_Hierarchy_Node_Id,'OPR_JOB_DTLS');
           Fetch Seq into l_Seq;
           Close Seq;
           Insert into
           Per_Gen_Hierarchy_Nodes
           (HIERARCHY_NODE_ID, BUSINESS_GROUP_ID, ENTITY_ID, HIERARCHY_VERSION_ID,
            NODE_TYPE, PARENT_HIERARCHY_NODE_ID, SEQ, Object_Version_Number)
           Values
            (l_JHierarchy_Node_Id, p_BUSINESS_GROUP_ID, Jobrec.TATIGKEIT_NUMBER, l_OprHierarchy_Version_Id,
            'OPR_JOB_DTLS', l_OprParent_Hierarchy_Node_Id,l_seq, 1);

           For jobftrrec in JobFtrs(Jobrec.WRKPLC_VLDTN_JOB_ID,'J')
           Loop
           l_Hierarchy_Node_Id        := NULL;
           l_Hierarchy_Version_Id     := NULL;
           l_Parent_Hierarchy_Node_Id := NULL;
           l_Node_type                := NULL;

           Open Hierarchy_Data(Jobftrrec.JOB_FEATURE_CODE, 'OPR_JOB_FTR');
           Fetch Hierarchy_Data into l_Hierarchy_Node_Id, l_Hierarchy_Version_Id, l_Parent_Hierarchy_Node_Id, l_Node_type;
           If Hierarchy_Data%NotFound Then
              Close HIerarchy_data;
              Select Per_gen_Hierarchy_Nodes_s.Nextval into l_Hierarchy_Node_Id from Dual;
              Open Seq(l_OprParent_Hierarchy_Node_Id,'OPR_JOB_DTLS');
              Fetch Seq into l_Seq;
              Close Seq;
              Insert into
              Per_Gen_Hierarchy_Nodes
              (HIERARCHY_NODE_ID, BUSINESS_GROUP_ID, ENTITY_ID, HIERARCHY_VERSION_ID,
               NODE_TYPE, PARENT_HIERARCHY_NODE_ID, SEQ, Object_Version_Number)
              Values
               (l_Hierarchy_Node_Id, p_BUSINESS_GROUP_ID, Jobftrrec.JOB_FEATURE_CODE, l_OprHierarchy_Version_Id,
               'OPR_JOB_FTR', l_JHierarchy_Node_Id, l_seq, 1);
           Else
             Close Hierarchy_Data;
           End If;
           End Loop;
         Else
           Close Hierarchy_Data;
         End If;
    End Loop;
    For jobftrrec in JobFtrs(Oprrec.Wrkplc_Vldtn_op_Id,'O')
    Loop
        l_Hierarchy_Node_Id        := NULL;
        l_Hierarchy_Version_Id     := NULL;
        l_Parent_Hierarchy_Node_Id := NULL;
        l_Node_type                := NULL;

        Open Hierarchy_Data(Jobftrrec.JOB_FEATURE_CODE, 'OPR_JOB_FTR');
        Fetch Hierarchy_Data into l_Hierarchy_Node_Id, l_Hierarchy_Version_Id, l_Parent_Hierarchy_Node_Id, l_Node_type;
        If Hierarchy_Data%NotFound Then
           Close HIerarchy_data;
           Select Per_gen_Hierarchy_Nodes_s.Nextval into l_Hierarchy_Node_Id from Dual;
           Open Seq(l_OprParent_Hierarchy_Node_Id,'OPR_JOB_DTLS');
           Fetch Seq into l_Seq;
           Close Seq;
           Insert Into
           Per_Gen_Hierarchy_Nodes
           (HIERARCHY_NODE_ID, BUSINESS_GROUP_ID, ENTITY_ID, HIERARCHY_VERSION_ID,
            NODE_TYPE, PARENT_HIERARCHY_NODE_ID, SEQ, Object_Version_Number)
           Values
            (l_Hierarchy_Node_Id, p_BUSINESS_GROUP_ID, Jobftrrec.JOB_FEATURE_CODE, l_OprHierarchy_Version_Id,
            'OPR_JOB_FTR', l_OprParent_Hierarchy_Node_Id, l_seq, 1);
        Else
          Close Hierarchy_Data;
        End If;
    End Loop;
 End If;
End Loop;
End;
End;

/
