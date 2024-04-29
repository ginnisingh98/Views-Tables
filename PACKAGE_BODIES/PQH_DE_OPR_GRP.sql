--------------------------------------------------------
--  DDL for Package Body PQH_DE_OPR_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_DE_OPR_GRP" As
/* $Header: pqtskpln.pkb 120.0 2005/05/29 02:50:49 appldev noship $ */


Function Node_Sequence(P_Hierarchy_version_id  IN Number,
                       P_Parent_Hierarchy_Id   IN Number)
                       Return Number is
Cursor Seq is
Select Nvl(max(SEQ),0) + 1
  From Per_gen_Hierarchy_Nodes
 Where Hierarchy_Version_Id     = p_Hierarchy_Version_id
   and Parent_Hierarchy_Node_Id = P_Parent_Hierarchy_Id;

l_Seq Per_Gen_hierarchy_nodes.Seq%TYPE;

Begin
 open Seq;
 Fetch Seq into l_seq;
 Close Seq;
 Return l_Seq;
End;


Procedure copy_Hierarchy
(P_Hierarchy_version_id             IN Number,
 P_Parent_Hierarchy_id              IN Number,
 P_Hierarchy_Id                     IN Number,
 p_Business_group_Id                IN Number,
 p_Effective_Date                   IN Date) Is

 Cursor C1 IS
 Select Node_Type     , Entity_Id    , Hierarchy_Node_id           , Parent_Hierarchy_Node_Id    , Hierarchy_Version_Id        , ATTRIBUTE_CATEGORY,
        ATTRIBUTE1    , ATTRIBUTE2   , ATTRIBUTE3   , ATTRIBUTE4   , ATTRIBUTE5   , ATTRIBUTE6   , ATTRIBUTE7   , ATTRIBUTE8   ,
        ATTRIBUTE9    , ATTRIBUTE10  , ATTRIBUTE11  , ATTRIBUTE12  , ATTRIBUTE13  , ATTRIBUTE14  , ATTRIBUTE15  , ATTRIBUTE16  , ATTRIBUTE17  , ATTRIBUTE18  ,
        ATTRIBUTE19   , ATTRIBUTE20  , ATTRIBUTE21  , ATTRIBUTE22  , ATTRIBUTE23  , ATTRIBUTE24  , ATTRIBUTE25  , ATTRIBUTE26  , ATTRIBUTE27  , ATTRIBUTE28  ,
        ATTRIBUTE29   , ATTRIBUTE30  , INFORMATION1 , INFORMATION2 , INFORMATION3 , INFORMATION4 , INFORMATION5 , INFORMATION6 , INFORMATION7 , INFORMATION8 ,
        INFORMATION9  , INFORMATION10, INFORMATION11, INFORMATION12, INFORMATION13, INFORMATION14, INFORMATION15, INFORMATION16, INFORMATION17, INFORMATION18,
        INFORMATION19 , INFORMATION20, INFORMATION21, INFORMATION22, INFORMATION23, INFORMATION24, INFORMATION25, INFORMATION26, INFORMATION27, INFORMATION28,
        INFORMATION29 , INFORMATION30, INFORMATION_CATEGORY
   From Per_gen_Hierarchy_Nodes a
Start with Hierarchy_Node_Id        = P_Hierarchy_Id
Connect by Parent_Hierarchy_Node_Id = Prior Hierarchy_Node_id;

 Cursor C2 (P_Parent_Hierarchy_Node_id IN Number) is
 Select Node_Type, Entity_id
   from Per_Gen_hierarchy_Nodes
  Where Hierarchy_Node_Id    = P_Parent_Hierarchy_Node_id;

 Cursor c3(P_Node_type IN Varchar2,
           P_Entity_Id    Varchar2) Is
 Select hierarchy_Node_Id
   from Per_Gen_Hierarchy_Nodes
  Where Hierarchy_version_Id = p_Hierarchy_version_id
    and Node_type            = P_Node_Type
    and Entity_Id            = P_Entity_Id
    and Request_Id           = -999;

l_Hierarchy_Node_id         Per_Gen_Hierarchy_Nodes.Hierarchy_Node_Id%TYPE;
l_Parent_hierarchy_Node_id  Per_Gen_Hierarchy_Nodes.Parent_Hierarchy_Node_Id%TYPE;
l_Object_version_Number     Per_Gen_Hierarchy.Object_version_Number%TYPE;
l_Node_type                 Per_Gen_Hierarchy_Nodes.Node_type%TYPE;
l_Entity_Id                 Per_Gen_Hierarchy_Nodes.Entity_Id%TYPE;

Begin
l_Parent_hierarchy_Node_Id := NULL;
For C1rec in C1
Loop
If l_Parent_hierarchy_Node_Id Is NULL Then
    Per_Hierarchy_Nodes_Api.create_hierarchy_nodes
    (P_HIERARCHY_NODE_ID          => l_Hierarchy_Node_id,
     P_BUSINESS_GROUP_ID          => P_BUSINESS_GROUP_ID,
     P_ENTITY_ID                  => C1rec.Entity_id,
     P_HIERARCHY_VERSION_ID       => P_Hierarchy_version_id,
     P_NODE_TYPE                  => C1rec.Node_type,
     P_SEQ                        => Node_Sequence(P_Hierarchy_version_id,P_Parent_hierarchy_Id),
     P_PARENT_HIERARCHY_NODE_ID   => P_Parent_hierarchy_Id,
     P_OBJECT_VERSION_NUMBER      => l_Object_version_Number,
     P_REQUEST_ID                 => -999,
     P_ATTRIBUTE_CATEGORY         => C1rec.Attribute_Category,
     P_ATTRIBUTE1                 => C1rec.Attribute1,
     P_ATTRIBUTE2                 => C1rec.Attribute2,
     P_ATTRIBUTE3                 => C1rec.Attribute3,
     P_ATTRIBUTE4                 => C1rec.Attribute4,
     P_ATTRIBUTE5                 => C1rec.Attribute5,
     P_ATTRIBUTE6                 => C1rec.Attribute6,
     P_ATTRIBUTE7                 => C1rec.Attribute7,
     P_ATTRIBUTE8                 => C1rec.Attribute8,
     P_ATTRIBUTE9                 => C1rec.Attribute9,
     P_ATTRIBUTE10                => C1rec.Attribute10,
     P_ATTRIBUTE11                => C1rec.Attribute11,
     P_ATTRIBUTE12                => C1rec.Attribute12,
     P_ATTRIBUTE13                => C1rec.Attribute13,
     P_ATTRIBUTE14                => C1rec.Attribute14,
     P_ATTRIBUTE15                => C1rec.Attribute15,
     P_ATTRIBUTE16                => C1rec.Attribute16,
     P_ATTRIBUTE17                => C1rec.Attribute17,
     P_ATTRIBUTE18                => C1rec.Attribute18,
     P_ATTRIBUTE19                => C1rec.Attribute19,
     P_ATTRIBUTE20                => C1rec.Attribute20,
     P_ATTRIBUTE21                => C1rec.Attribute21,
     P_ATTRIBUTE22                => C1rec.Attribute22,
     P_ATTRIBUTE23                => C1rec.Attribute23,
     P_ATTRIBUTE24                => C1rec.Attribute24,
     P_ATTRIBUTE25                => C1rec.Attribute25,
     P_ATTRIBUTE26                => C1rec.Attribute26,
     P_ATTRIBUTE27                => C1rec.Attribute27,
     P_ATTRIBUTE28                => C1rec.Attribute28,
     P_ATTRIBUTE29                => C1rec.Attribute29,
     P_ATTRIBUTE30                => C1rec.Attribute30,
     P_INFORMATION_CATEGORY       => C1rec.Information_Category,
     P_INFORMATION1               => C1rec.Information1,
     P_INFORMATION2               => C1rec.Information2,
     P_INFORMATION3               => C1rec.Information3,
     P_INFORMATION4               => C1rec.Information4,
     P_INFORMATION5               => C1rec.Information5,
     P_INFORMATION6               => C1rec.Information6,
     P_INFORMATION7               => C1rec.Information7,
     P_INFORMATION8               => C1rec.Information8,
     P_INFORMATION9               => C1rec.Information9,
     P_INFORMATION10              => C1rec.Information10,
     P_INFORMATION11              => C1rec.Information11,
     P_INFORMATION12              => C1rec.Information12,
     P_INFORMATION13              => C1rec.Information13,
     P_INFORMATION14              => C1rec.Information14,
     P_INFORMATION15              => C1rec.Information15,
     P_INFORMATION16              => C1rec.Information16,
     P_INFORMATION17              => C1rec.Information17,
     P_INFORMATION18              => C1rec.Information18,
     P_INFORMATION19              => C1rec.Information19,
     P_INFORMATION20              => C1rec.Information20,
     P_INFORMATION21              => C1rec.Information21,
     P_INFORMATION22              => C1rec.Information22,
     P_INFORMATION23              => C1rec.Information23,
     P_INFORMATION24              => C1rec.Information24,
     P_INFORMATION25              => C1rec.Information25,
     P_INFORMATION26              => C1rec.Information26,
     P_INFORMATION27              => C1rec.Information27,
     P_INFORMATION28              => C1rec.Information28,
     P_INFORMATION29              => C1rec.Information29,
     P_INFORMATION30              => C1rec.Information30,
     P_EFFECTIVE_DATE             => p_Effective_Date);
     l_Parent_hierarchy_Node_Id := Nvl(P_Parent_hierarchy_Id, 0);
Else
    Open C2(C1rec.Parent_hierarchy_node_Id);
    Fetch C2 into L_Node_Type, l_Entity_Id;
    Close C2;
    Open C3(l_Node_type, l_Entity_Id);
    Fetch C3 into l_Parent_Hierarchy_Node_id;
    Close C3;
    Per_Hierarchy_Nodes_Api.create_hierarchy_nodes
    (P_HIERARCHY_NODE_ID          => l_Hierarchy_Node_id,
     P_BUSINESS_GROUP_ID          => P_BUSINESS_GROUP_ID,
     P_ENTITY_ID                  => C1rec.Entity_id,
     P_HIERARCHY_VERSION_ID       => P_Hierarchy_version_id,
     P_NODE_TYPE                  => C1rec.Node_type,
     P_SEQ                        => Node_Sequence(P_Hierarchy_version_id,l_Parent_Hierarchy_Node_Id),
     P_PARENT_HIERARCHY_NODE_ID   => l_Parent_hierarchy_Node_id,
     P_OBJECT_VERSION_NUMBER      => l_Object_version_Number,
     P_REQUEST_ID                 => -999,
     P_ATTRIBUTE_CATEGORY         => C1rec.Attribute_Category,
     P_ATTRIBUTE1                 => C1rec.Attribute1,
     P_ATTRIBUTE2                 => C1rec.Attribute2,
     P_ATTRIBUTE3                 => C1rec.Attribute3,
     P_ATTRIBUTE4                 => C1rec.Attribute4,
     P_ATTRIBUTE5                 => C1rec.Attribute5,
     P_ATTRIBUTE6                 => C1rec.Attribute6,
     P_ATTRIBUTE7                 => C1rec.Attribute7,
     P_ATTRIBUTE8                 => C1rec.Attribute8,
     P_ATTRIBUTE9                 => C1rec.Attribute9,
     P_ATTRIBUTE10                => C1rec.Attribute10,
     P_ATTRIBUTE11                => C1rec.Attribute11,
     P_ATTRIBUTE12                => C1rec.Attribute12,
     P_ATTRIBUTE13                => C1rec.Attribute13,
     P_ATTRIBUTE14                => C1rec.Attribute14,
     P_ATTRIBUTE15                => C1rec.Attribute15,
     P_ATTRIBUTE16                => C1rec.Attribute16,
     P_ATTRIBUTE17                => C1rec.Attribute17,
     P_ATTRIBUTE18                => C1rec.Attribute18,
     P_ATTRIBUTE19                => C1rec.Attribute19,
     P_ATTRIBUTE20                => C1rec.Attribute20,
     P_ATTRIBUTE21                => C1rec.Attribute21,
     P_ATTRIBUTE22                => C1rec.Attribute22,
     P_ATTRIBUTE23                => C1rec.Attribute23,
     P_ATTRIBUTE24                => C1rec.Attribute24,
     P_ATTRIBUTE25                => C1rec.Attribute25,
     P_ATTRIBUTE26                => C1rec.Attribute26,
     P_ATTRIBUTE27                => C1rec.Attribute27,
     P_ATTRIBUTE28                => C1rec.Attribute28,
     P_ATTRIBUTE29                => C1rec.Attribute29,
     P_ATTRIBUTE30                => C1rec.Attribute30,
     P_INFORMATION_CATEGORY       => C1rec.Information_Category,
     P_INFORMATION1               => C1rec.Information1,
     P_INFORMATION2               => C1rec.Information2,
     P_INFORMATION3               => C1rec.Information3,
     P_INFORMATION4               => C1rec.Information4,
     P_INFORMATION5               => C1rec.Information5,
     P_INFORMATION6               => C1rec.Information6,
     P_INFORMATION7               => C1rec.Information7,
     P_INFORMATION8               => C1rec.Information8,
     P_INFORMATION9               => C1rec.Information9,
     P_INFORMATION10              => C1rec.Information10,
     P_INFORMATION11              => C1rec.Information11,
     P_INFORMATION12              => C1rec.Information12,
     P_INFORMATION13              => C1rec.Information13,
     P_INFORMATION14              => C1rec.Information14,
     P_INFORMATION15              => C1rec.Information15,
     P_INFORMATION16              => C1rec.Information16,
     P_INFORMATION17              => C1rec.Information17,
     P_INFORMATION18              => C1rec.Information18,
     P_INFORMATION19              => C1rec.Information19,
     P_INFORMATION20              => C1rec.Information20,
     P_INFORMATION21              => C1rec.Information21,
     P_INFORMATION22              => C1rec.Information22,
     P_INFORMATION23              => C1rec.Information23,
     P_INFORMATION24              => C1rec.Information24,
     P_INFORMATION25              => C1rec.Information25,
     P_INFORMATION26              => C1rec.Information26,
     P_INFORMATION27              => C1rec.Information27,
     P_INFORMATION28              => C1rec.Information28,
     P_INFORMATION29              => C1rec.Information29,
     P_INFORMATION30              => C1rec.Information30,
     P_EFFECTIVE_DATE             => p_Effective_Date);
End If;

End Loop;
Update Per_Gen_Hierarchy_Nodes
   Set REQUEST_ID = 0
 Where REQUEST_ID = -999;
End;

Procedure Main
(P_Type                             IN Varchar2,
 P_Trntype                          IN Varchar2,
 P_Code                             IN Varchar2  Default NULL,
 P_Description                      IN Varchar2  Default NULL,
 p_Code_Id                          IN Number    Default NULL,
 P_Hierarchy_version_id             IN Number    Default NULL,
 P_Parent_Hierarchy_id              IN Number    Default NULL,
 P_Hierarchy_Id                     IN Number    Default NULL,
 p_Object_Version_Number            IN Number    Default NULL,
 p_Business_group_Id                IN Number  ,
 p_Effective_Date                   IN Date) Is

 l_Hierarchy_id              Per_Gen_Hierarchy.Hierarchy_Id%TYPE;
 l_Hierarchy_Version_id      Per_Gen_Hierarchy_Versions.Hierarchy_version_Id%TYPE;
 l_HObject_version_Number    Per_Gen_Hierarchy.Object_version_Number%TYPE;
 l_Object_version_Number     Per_Gen_Hierarchy.Object_version_Number%TYPE;
 l_VObject_version_Number    Per_Gen_Hierarchy.Object_version_Number%TYPE;
 l_Hierarchy_Node_id         Per_Gen_Hierarchy_Nodes.Hierarchy_Node_Id%TYPE;
 /* l_Node_id                   Pqh_de_operations.Operation_Id%TYPE; */
 l_version_count             Number(15);

Cursor C1 IS
 Select Hierarchy_Node_id, Object_version_number
   From Per_gen_Hierarchy_Nodes a
  Start with Hierarchy_Node_Id        = P_Hierarchy_Id
 Connect  by Parent_Hierarchy_Node_Id = Prior Hierarchy_Node_id
 Order By Nvl(Parent_Hierarchy_Node_Id,0) Desc;

Cursor C2 is
 Select Pgh.Hierarchy_id, pgh.Object_version_number hovn,
        pgv.Hierarchy_version_id, pgv.Object_Version_number vovn
   From Per_Gen_hierarchy_Versions pgv, Per_gen_hierarchy pgh
  Where Hierarchy_Version_id = P_Hierarchy_version_id
    and pgv.Hierarchy_id = pgh.Hierarchy_id;

Cursor C3 is
 Select Hierarchy_Node_Id, Object_Version_Number
   From Per_Gen_Hierarchy_Nodes
  Start With Hierarchy_Version_id = P_Hierarchy_Version_id
    and Parent_hierarchy_node_id is NULL
Connect By Parent_hierarchy_Node_id = Prior Hierarchy_Node_id
  Order By Nvl(Parent_Hierarchy_Node_id,0) Desc;

Cursor C4 is
Select count(*)
  From Per_Gen_Hierarchy_Versions pgv, Per_Gen_Hierarchy pgh
 Where pgh.Hierarchy_id = (Select Hierarchy_id
                           From   Per_Gen_Hierarchy_Versions
                           Where Hierarchy_Version_Id = P_Hierarchy_Version_Id)
   and pgv.hierarchy_id = pgh.hierarchy_id;


Begin

If p_Type = 'P' and  P_Trntype = 'I' Then

   Per_hierarchy_api.CREATE_HIERARCHY
   (P_HIERARCHY_ID               => l_Hierarchy_id     ,
    P_BUSINESS_GROUP_ID          => p_Business_group_Id,
    P_NAME                       => P_Description      ,
    P_TYPE                       => 'OPERATION_PLAN'   ,
    P_OBJECT_VERSION_NUMBER      => l_HObject_version_Number,
    P_EFFECTIVE_DATE             => p_Effective_Date);

   Per_hierarchy_versions_api.create_hierarchy_versions
   (P_HIERARCHY_VERSION_ID       => l_Hierarchy_Version_id,
    P_BUSINESS_GROUP_ID          => p_Business_group_Id,
    P_VERSION_NUMBER             => 1,
    P_HIERARCHY_ID               => l_Hierarchy_id,
    P_DATE_FROM                  => P_EFFECTIVE_DATE,
    P_OBJECT_VERSION_NUMBER      => l_VObject_version_Number ,
    P_STATUS                     => 'A',
    P_VALIDATE_FLAG              => 'Y',
    P_EFFECTIVE_DATE             => p_Effective_Date);

ElsIf  P_Trntype = 'R' Then
    --Get the number of versions for the hierarchy
    Open C4;
    Fetch C4 into l_version_count;
    Close C4;
    For C2Rec in C2
    Loop

       For C3rec in C3
       Loop
         l_Object_Version_Number := C3rec.Object_version_Number;
         Per_Hierarchy_Nodes_api.DELETE_HIERARCHY_NODES
        (P_Hierarchy_Node_Id      => C3rec.Hierarchy_Node_id,
         P_Object_Version_Number  => l_Object_Version_Number);
       End Loop;

       l_object_version_number := c2rec.vovn;
       Per_Hierarchy_versions_api.DELETE_HIERARCHY_VERSIONS
       (P_HIERARCHY_VERSION_ID   => C2rec.Hierarchy_version_id,
        P_OBJECT_VERSION_NUMBER  => l_Object_version_Number,
        P_EFFECTIVE_DATE         => P_Effective_Date);

       if(l_version_count < 2) then
         l_object_version_number := c2rec.hovn;
         Per_Hierarchy_api.Delete_Hierarchy
         (P_Hierarchy_Id          => C2rec.Hierarchy_id,
          P_Object_Version_Number => l_Object_Version_Number);
       End if;
    End Loop;

ElsIf p_Type = 'G' and  P_Trntype = 'I' Then

  /*  PQH_DE_OPERATION_GROUPS_API.INSERT_OPERATION_GROUPS
   (P_EFFECTIVE_DATE            => P_EFFECTIVE_DATE,
    P_OPERATION_GROUP_CODE      => P_Code,
    P_DESCRIPTION               => P_Description,
    P_BUSINESS_GROUP_ID         => P_BUSINESS_GROUP_ID,
    P_OPERATION_GROUP_ID        => l_Node_id,
    P_OBJECT_VERSION_NUMBER     => l_Object_version_Number); */

    Per_Hierarchy_Nodes_Api.create_hierarchy_nodes
    (P_HIERARCHY_NODE_ID        => l_Hierarchy_Node_id,
     P_BUSINESS_GROUP_ID        => P_BUSINESS_GROUP_ID,
     P_ENTITY_ID                => P_Code,
     P_HIERARCHY_VERSION_ID     => P_Hierarchy_version_id,
     P_NODE_TYPE                => 'OPR_GROUP',
     P_SEQ                      => Node_Sequence(P_Hierarchy_version_id,P_Parent_Hierarchy_Id),
     P_PARENT_HIERARCHY_NODE_ID => P_Parent_Hierarchy_Id,
     P_OBJECT_VERSION_NUMBER    => l_VObject_version_Number,
     P_EFFECTIVE_DATE           => p_Effective_Date);

ElsIf p_Type = 'G' and  P_Trntype = 'U' Then

      l_Object_version_Number :=  P_Object_version_Number;

 /*    PQH_DE_OPERATION_GROUPS_API.UPDATE_OPERATION_GROUPS
     (P_EFFECTIVE_DATE          => P_EFFECTIVE_DATE,
      P_OPERATION_GROUP_ID      => P_Code_Id,
      P_OBJECT_VERSION_NUMBER   => l_Object_Version_Number,
      P_OPERATION_GROUP_CODE    => P_Code,
      P_DESCRIPTION             => P_Description); */


ElsIf p_Type = 'O' and  P_Trntype = 'I' Then

  /*  PQH_DE_OPERATIONS_API.INSERT_OPERATIONS
    (P_EFFECTIVE_DATE           => P_EFFECTIVE_DATE,
     P_OPERATION_NUMBER         => P_Code,
     P_DESCRIPTION              => P_Description,
     P_OPERATION_ID             => L_Node_id,
     P_OBJECT_VERSION_NUMBER    => l_Object_version_Number); */

    Per_Hierarchy_Nodes_Api.create_hierarchy_nodes
    (P_HIERARCHY_NODE_ID        => l_Hierarchy_Node_id,
     P_BUSINESS_GROUP_ID        => P_BUSINESS_GROUP_ID,
     P_ENTITY_ID                => P_Code,
     P_HIERARCHY_VERSION_ID     => P_Hierarchy_version_id,
     P_NODE_TYPE                => 'OPR_OPTS',
     P_SEQ                      => Node_Sequence(P_Hierarchy_version_id,P_Parent_Hierarchy_Id),
     P_PARENT_HIERARCHY_NODE_ID => P_Parent_Hierarchy_Id,
     P_OBJECT_VERSION_NUMBER    => l_VObject_version_Number,
     P_EFFECTIVE_DATE           => p_Effective_Date);

ElsIf p_Type = 'O' and  P_Trntype = 'U' Then

    l_Object_version_Number :=  P_Object_version_Number;

  /*  PQH_DE_OPERATIONS_API.UPDATE_OPERATIONS
    (P_EFFECTIVE_DATE           => P_EFFECTIVE_DATE,
     P_OPERATION_NUMBER         => P_Code,
     P_DESCRIPTION              => P_Description,
     P_OPERATION_ID             => P_Code_Id,
     P_OBJECT_VERSION_NUMBER    => l_Object_Version_Number); */

ElsIf p_Type = 'J' and  P_Trntype = 'I' Then

  /*  PQH_DE_TKTDTLS_API.INSERT_TKT_DTLS
    (P_EFFECTIVE_DATE           => P_EFFECTIVE_DATE,
     P_TATIGKEIT_NUMBER         => P_Code,
     P_DESCRIPTION              => P_Description,
     P_TATIGKEIT_DETAIL_ID      => L_Node_id,
     P_OBJECT_VERSION_NUMBER    => l_Object_version_Number); */

    Per_Hierarchy_Nodes_Api.create_hierarchy_nodes
    (P_HIERARCHY_NODE_ID        => l_Hierarchy_Node_id,
     P_BUSINESS_GROUP_ID        => P_BUSINESS_GROUP_ID,
     P_ENTITY_ID                => P_Code,
     P_HIERARCHY_VERSION_ID     => P_Hierarchy_version_id,
     P_NODE_TYPE                => 'OPR_JOB_DTLS',
     P_SEQ                      => Node_Sequence(P_Hierarchy_version_id,P_Parent_Hierarchy_Id),
     P_PARENT_HIERARCHY_NODE_ID => P_Parent_Hierarchy_Id,
     P_OBJECT_VERSION_NUMBER    => l_VObject_version_Number,
     P_EFFECTIVE_DATE           => p_Effective_Date);

ElsIf p_Type = 'J' and  P_Trntype = 'U' Then

     l_Object_version_Number :=  P_Object_version_Number;

   /*   PQH_DE_TKTDTLS_API.UPDATE_TKT_DTLS
     (P_EFFECTIVE_DATE          => P_EFFECTIVE_DATE,
      P_TATIGKEIT_NUMBER        => P_Code,
      P_DESCRIPTION             => P_Description,
      P_TATIGKEIT_DETAIL_ID     => P_Code_Id,
      P_OBJECT_VERSION_NUMBER   => l_Object_Version_Number); */

ElsIf p_Type = 'F' and  P_Trntype = 'I' Then

    Per_Hierarchy_Nodes_Api.create_hierarchy_nodes
    (P_HIERARCHY_NODE_ID        => l_Hierarchy_Node_id,
     P_BUSINESS_GROUP_ID        => P_BUSINESS_GROUP_ID,
     P_ENTITY_ID                => P_Code,
     P_HIERARCHY_VERSION_ID     => P_Hierarchy_version_id,
     P_NODE_TYPE                => 'OPR_JOB_FTR',
     P_SEQ                      => Node_Sequence(P_Hierarchy_version_id,P_Parent_Hierarchy_Id),
     P_PARENT_HIERARCHY_NODE_ID => P_Parent_Hierarchy_Id,
     P_OBJECT_VERSION_NUMBER    => l_VObject_version_Number,
     P_EFFECTIVE_DATE           => p_Effective_Date);

ElsIf P_Trntype = 'S' Then

     null;

    /*  PQH_DE_OPR_GRP.copy_Hierarchy
     (P_Hierarchy_version_id     => P_Hierarchy_version_id,
      P_Parent_Hierarchy_id      => P_Parent_Hierarchy_id,
      P_Hierarchy_Id             => P_Hierarchy_Id,
      p_Business_group_Id        => P_BUSINESS_GROUP_ID,
      p_Effective_Date           =>  p_Effective_Date); */

ElsIf P_Trntype = 'D' Then

   For C1rec in C1
   Loop

      l_Object_version_Number :=  C1rec.Object_version_Number;

      Per_Hierarchy_Nodes_Api.DELETE_HIERARCHY_NODES
      (P_HIERARCHY_NODE_ID      =>  C1rec.Hierarchy_Node_Id,
       P_OBJECT_VERSION_NUMBER  =>  l_Object_Version_Number);

   End Loop;

End If;
End;

Procedure Copy_Hierarchy_version
(P_Type                             IN Varchar2,
 P_Name                             IN Varchar2 Default NULL,
 P_Date_From                        IN Date     Default NULL,
 P_Date_To                          IN Date     Default NULL,
 P_Hierarchy_Id                     IN Number   Default NULL,
 P_Hierarchy_Version_Id             IN Number   Default NULL,
 P_Version_Number                   IN Number   Default NULL,
 P_Business_Group_id                IN Number  ,
 P_Effective_Date                   IN Date    ,
 P_New_hierarchy_Id                OUT NOCOPY Number  ,
 P_New_Hierarchy_Version_Id        OUT NOCOPY Number) Is

 Cursor Hierarchy is
 Select Type,     ATTRIBUTE_CATEGORY, ATTRIBUTE1   , ATTRIBUTE2   , ATTRIBUTE3   , ATTRIBUTE4   , ATTRIBUTE5   , ATTRIBUTE6   , ATTRIBUTE7   , ATTRIBUTE8   ,
        ATTRIBUTE9   , ATTRIBUTE10  , ATTRIBUTE11  , ATTRIBUTE12  , ATTRIBUTE13  , ATTRIBUTE14  , ATTRIBUTE15  , ATTRIBUTE16  , ATTRIBUTE17  , ATTRIBUTE18  ,
        ATTRIBUTE19  , ATTRIBUTE20  , ATTRIBUTE21  , ATTRIBUTE22  , ATTRIBUTE23  , ATTRIBUTE24  , ATTRIBUTE25  , ATTRIBUTE26  , ATTRIBUTE27  , ATTRIBUTE28  ,
        ATTRIBUTE29  , ATTRIBUTE30  , INFORMATION1 , INFORMATION2 , INFORMATION3 , INFORMATION4 , INFORMATION5 , INFORMATION6 , INFORMATION7 , INFORMATION8 ,
        INFORMATION9 , INFORMATION10, INFORMATION11, INFORMATION12, INFORMATION13, INFORMATION14, INFORMATION15, INFORMATION16, INFORMATION17, INFORMATION18,
        INFORMATION19, INFORMATION20, INFORMATION21, INFORMATION22, INFORMATION23, INFORMATION24, INFORMATION25, INFORMATION26, INFORMATION27, INFORMATION28,
        INFORMATION29, INFORMATION30, INFORMATION_CATEGORY
   From Per_Gen_Hierarchy
  Where Hierarchy_id = P_Hierarchy_Id;

 Cursor Hierarchy_version is
 Select Hierarchy_Version_id, VERSION_NUMBER, HIERARCHY_ID , DATE_FROM    , DATE_TO      , STATUS       , VALIDATE_FLAG, ATTRIBUTE_CATEGORY,
        ATTRIBUTE1    , ATTRIBUTE2   , ATTRIBUTE3   , ATTRIBUTE4   , ATTRIBUTE5   , ATTRIBUTE6   , ATTRIBUTE7   , ATTRIBUTE8   ,
        ATTRIBUTE9    , ATTRIBUTE10  , ATTRIBUTE11  , ATTRIBUTE12  , ATTRIBUTE13  , ATTRIBUTE14  , ATTRIBUTE15  , ATTRIBUTE16  , ATTRIBUTE17  , ATTRIBUTE18  ,
        ATTRIBUTE19   , ATTRIBUTE20  , ATTRIBUTE21  , ATTRIBUTE22  , ATTRIBUTE23  , ATTRIBUTE24  , ATTRIBUTE25  , ATTRIBUTE26  , ATTRIBUTE27  , ATTRIBUTE28  ,
        ATTRIBUTE29   , ATTRIBUTE30  , INFORMATION1 , INFORMATION2 , INFORMATION3 , INFORMATION4 , INFORMATION5 , INFORMATION6 , INFORMATION7 , INFORMATION8 ,
        INFORMATION9  , INFORMATION10, INFORMATION11, INFORMATION12, INFORMATION13, INFORMATION14, INFORMATION15, INFORMATION16, INFORMATION17, INFORMATION18,
        INFORMATION19 , INFORMATION20, INFORMATION21, INFORMATION22, INFORMATION23, INFORMATION24, INFORMATION25, INFORMATION26, INFORMATION27, INFORMATION28,
        INFORMATION29 , INFORMATION30, INFORMATION_CATEGORY
   From Per_Gen_Hierarchy_Versions
  Where ((P_Hierarchy_Version_Id is not NULL and Hierarchy_Version_Id = p_Hierarchy_Version_Id)
   or (Hierarchy_Id = P_Hierarchy_Id and  P_Effective_Date between Date_From and Nvl(Date_To,p_Effective_Date)));

  Cursor Nodes(C_Hierarchy_Version_id In NUMBER) is
  Select Hierarchy_Node_id
    From Per_Gen_Hierarchy_Nodes
   Where Hierarchy_Version_id = C_Hierarchy_version_id
     and Parent_Hierarchy_Node_Id is NULL;

  l_hierarchy_id               Per_Gen_Hierarchy.Hierarchy_id%TYPE;
  l_Hierarchy_version_id       Per_Gen_Hierarchy_Versions.Hierarchy_Version_Id%TYPE;
  l_Object_version_Number      Per_Gen_hierarchy.Object_Version_Number%TYPE;

 Begin

  If P_Type = 'H' Then

     For Hierarchy_Rec in Hierarchy
     Loop
        Per_hierarchy_api.CREATE_HIERARCHY
       (P_HIERARCHY_ID               => l_Hierarchy_id     ,
        P_BUSINESS_GROUP_ID          => p_Business_group_Id,
        P_NAME                       => P_Name             ,
        P_TYPE                       => Hierarchy_rec.Type ,
        P_OBJECT_VERSION_NUMBER      => l_Object_version_Number,
        P_ATTRIBUTE_CATEGORY         => Hierarchy_rec.Attribute_Category,
        P_ATTRIBUTE1                 => Hierarchy_rec.Attribute1,
        P_ATTRIBUTE2                 => Hierarchy_rec.Attribute2,
        P_ATTRIBUTE3                 => Hierarchy_rec.Attribute3,
        P_ATTRIBUTE4                 => Hierarchy_rec.Attribute4,
        P_ATTRIBUTE5                 => Hierarchy_rec.Attribute5,
        P_ATTRIBUTE6                 => Hierarchy_rec.Attribute6,
        P_ATTRIBUTE7                 => Hierarchy_rec.Attribute7,
        P_ATTRIBUTE8                 => Hierarchy_rec.Attribute8,
        P_ATTRIBUTE9                 => Hierarchy_rec.Attribute9,
        P_ATTRIBUTE10                => Hierarchy_rec.Attribute10,
        P_ATTRIBUTE11                => Hierarchy_rec.Attribute11,
        P_ATTRIBUTE12                => Hierarchy_rec.Attribute12,
        P_ATTRIBUTE13                => Hierarchy_rec.Attribute13,
        P_ATTRIBUTE14                => Hierarchy_rec.Attribute14,
        P_ATTRIBUTE15                => Hierarchy_rec.Attribute15,
        P_ATTRIBUTE16                => Hierarchy_rec.Attribute16,
        P_ATTRIBUTE17                => Hierarchy_rec.Attribute17,
        P_ATTRIBUTE18                => Hierarchy_rec.Attribute18,
        P_ATTRIBUTE19                => Hierarchy_rec.Attribute19,
        P_ATTRIBUTE20                => Hierarchy_rec.Attribute20,
        P_ATTRIBUTE21                => Hierarchy_rec.Attribute21,
        P_ATTRIBUTE22                => Hierarchy_rec.Attribute22,
        P_ATTRIBUTE23                => Hierarchy_rec.Attribute23,
        P_ATTRIBUTE24                => Hierarchy_rec.Attribute24,
        P_ATTRIBUTE25                => Hierarchy_rec.Attribute25,
        P_ATTRIBUTE26                => Hierarchy_rec.Attribute26,
        P_ATTRIBUTE27                => Hierarchy_rec.Attribute27,
        P_ATTRIBUTE28                => Hierarchy_rec.Attribute28,
        P_ATTRIBUTE29                => Hierarchy_rec.Attribute29,
        P_ATTRIBUTE30                => Hierarchy_rec.Attribute30,
        P_INFORMATION_CATEGORY       => Hierarchy_rec.Information_Category,
        P_INFORMATION1               => Hierarchy_rec.Information1,
        P_INFORMATION2               => Hierarchy_rec.Information2,
        P_INFORMATION3               => Hierarchy_rec.Information3,
        P_INFORMATION4               => Hierarchy_rec.Information4,
        P_INFORMATION5               => Hierarchy_rec.Information5,
        P_INFORMATION6               => Hierarchy_rec.Information6,
        P_INFORMATION7               => Hierarchy_rec.Information7,
        P_INFORMATION8               => Hierarchy_rec.Information8,
        P_INFORMATION9               => Hierarchy_rec.Information9,
        P_INFORMATION10              => Hierarchy_rec.Information10,
        P_INFORMATION11              => Hierarchy_rec.Information11,
        P_INFORMATION12              => Hierarchy_rec.Information12,
        P_INFORMATION13              => Hierarchy_rec.Information13,
        P_INFORMATION14              => Hierarchy_rec.Information14,
        P_INFORMATION15              => Hierarchy_rec.Information15,
        P_INFORMATION16              => Hierarchy_rec.Information16,
        P_INFORMATION17              => Hierarchy_rec.Information17,
        P_INFORMATION18              => Hierarchy_rec.Information18,
        P_INFORMATION19              => Hierarchy_rec.Information19,
        P_INFORMATION20              => Hierarchy_rec.Information20,
        P_INFORMATION21              => Hierarchy_rec.Information21,
        P_INFORMATION22              => Hierarchy_rec.Information22,
        P_INFORMATION23              => Hierarchy_rec.Information23,
        P_INFORMATION24              => Hierarchy_rec.Information24,
        P_INFORMATION25              => Hierarchy_rec.Information25,
        P_INFORMATION26              => Hierarchy_rec.Information26,
        P_INFORMATION27              => Hierarchy_rec.Information27,
        P_INFORMATION28              => Hierarchy_rec.Information28,
        P_INFORMATION29              => Hierarchy_rec.Information29,
        P_INFORMATION30              => Hierarchy_rec.Information30,
        P_EFFECTIVE_DATE             => p_Effective_Date);
        l_Object_version_Number := NULL;
     End Loop;
     P_New_Hierarchy_Id := l_Hierarchy_id;
   End If;

   If  P_Type in ('H','V') then


     For Hierarchy_Ver_rec in Hierarchy_version Loop
        Per_hierarchy_versions_api.create_hierarchy_versions
       (P_HIERARCHY_VERSION_ID       => l_Hierarchy_Version_id,
        P_BUSINESS_GROUP_ID          => p_Business_group_Id,
        P_VERSION_NUMBER             => Nvl(P_Version_Number,1),
        P_HIERARCHY_ID               => Nvl(l_Hierarchy_id,Hierarchy_Ver_Rec.Hierarchy_Id),
        P_DATE_FROM                  => Nvl(P_Date_From,P_EFFECTIVE_DATE),
        P_DATE_TO                    => P_Date_To,
        P_OBJECT_VERSION_NUMBER      => l_Object_version_Number ,
        P_STATUS                     => 'A',
        P_VALIDATE_FLAG              => 'Y',
        P_ATTRIBUTE_CATEGORY         => Hierarchy_Ver_rec.Attribute_Category,
        P_ATTRIBUTE1                 => Hierarchy_Ver_rec.Attribute1,
        P_ATTRIBUTE2                 => Hierarchy_Ver_rec.Attribute2,
        P_ATTRIBUTE3                 => Hierarchy_Ver_rec.Attribute3,
        P_ATTRIBUTE4                 => Hierarchy_Ver_rec.Attribute4,
        P_ATTRIBUTE5                 => Hierarchy_Ver_rec.Attribute5,
        P_ATTRIBUTE6                 => Hierarchy_Ver_rec.Attribute6,
        P_ATTRIBUTE7                 => Hierarchy_Ver_rec.Attribute7,
        P_ATTRIBUTE8                 => Hierarchy_Ver_rec.Attribute8,
        P_ATTRIBUTE9                 => Hierarchy_Ver_rec.Attribute9,
        P_ATTRIBUTE10                => Hierarchy_Ver_rec.Attribute10,
        P_ATTRIBUTE11                => Hierarchy_Ver_rec.Attribute11,
        P_ATTRIBUTE12                => Hierarchy_Ver_rec.Attribute12,
        P_ATTRIBUTE13                => Hierarchy_Ver_rec.Attribute13,
        P_ATTRIBUTE14                => Hierarchy_Ver_rec.Attribute14,
        P_ATTRIBUTE15                => Hierarchy_Ver_rec.Attribute15,
        P_ATTRIBUTE16                => Hierarchy_Ver_rec.Attribute16,
        P_ATTRIBUTE17                => Hierarchy_Ver_rec.Attribute17,
        P_ATTRIBUTE18                => Hierarchy_Ver_rec.Attribute18,
        P_ATTRIBUTE19                => Hierarchy_Ver_rec.Attribute19,
        P_ATTRIBUTE20                => Hierarchy_Ver_rec.Attribute20,
        P_ATTRIBUTE21                => Hierarchy_Ver_rec.Attribute21,
        P_ATTRIBUTE22                => Hierarchy_Ver_rec.Attribute22,
        P_ATTRIBUTE23                => Hierarchy_Ver_rec.Attribute23,
        P_ATTRIBUTE24                => Hierarchy_Ver_rec.Attribute24,
        P_ATTRIBUTE25                => Hierarchy_Ver_rec.Attribute25,
        P_ATTRIBUTE26                => Hierarchy_Ver_rec.Attribute26,
        P_ATTRIBUTE27                => Hierarchy_Ver_rec.Attribute27,
        P_ATTRIBUTE28                => Hierarchy_Ver_rec.Attribute28,
        P_ATTRIBUTE29                => Hierarchy_Ver_rec.Attribute29,
        P_ATTRIBUTE30                => Hierarchy_Ver_rec.Attribute30,
        P_INFORMATION_CATEGORY       => Hierarchy_Ver_rec.Information_Category,
        P_INFORMATION1               => Hierarchy_Ver_rec.Information1,
        P_INFORMATION2               => Hierarchy_Ver_rec.Information2,
        P_INFORMATION3               => Hierarchy_Ver_rec.Information3,
        P_INFORMATION4               => Hierarchy_Ver_rec.Information4,
        P_INFORMATION5               => Hierarchy_Ver_Rec.Information5,
        P_INFORMATION6               => Hierarchy_Ver_Rec.Information6,
        P_INFORMATION7               => Hierarchy_Ver_Rec.Information7,
        P_INFORMATION8               => Hierarchy_Ver_Rec.Information8,
        P_INFORMATION9               => Hierarchy_Ver_Rec.Information9,
        P_INFORMATION10              => Hierarchy_Ver_Rec.Information10,
        P_INFORMATION11              => Hierarchy_Ver_Rec.Information11,
        P_INFORMATION12              => Hierarchy_Ver_Rec.Information12,
        P_INFORMATION13              => Hierarchy_Ver_Rec.Information13,
        P_INFORMATION14              => Hierarchy_Ver_Rec.Information14,
        P_INFORMATION15              => Hierarchy_Ver_Rec.Information15,
        P_INFORMATION16              => Hierarchy_Ver_Rec.Information16,
        P_INFORMATION17              => Hierarchy_Ver_Rec.Information17,
        P_INFORMATION18              => Hierarchy_Ver_Rec.Information18,
        P_INFORMATION19              => Hierarchy_Ver_Rec.Information19,
        P_INFORMATION20              => Hierarchy_Ver_Rec.Information20,
        P_INFORMATION21              => Hierarchy_Ver_Rec.Information21,
        P_INFORMATION22              => Hierarchy_Ver_Rec.Information22,
        P_INFORMATION23              => Hierarchy_Ver_Rec.Information23,
        P_INFORMATION24              => Hierarchy_Ver_Rec.Information24,
        P_INFORMATION25              => Hierarchy_Ver_Rec.Information25,
        P_INFORMATION26              => Hierarchy_Ver_Rec.Information26,
        P_INFORMATION27              => Hierarchy_Ver_Rec.Information27,
        P_INFORMATION28              => Hierarchy_Ver_Rec.Information28,
        P_INFORMATION29              => Hierarchy_Ver_Rec.Information29,
        P_INFORMATION30              => Hierarchy_Ver_Rec.Information30,
        P_EFFECTIVE_DATE             => p_Effective_Date);
        P_New_Hierarchy_Version_Id := l_Hierarchy_Version_id;
        For Node_Rec in Nodes(Hierarchy_Ver_Rec.Hierarchy_Version_id)
        Loop
           Pqh_De_Opr_Grp.copy_Hierarchy
          (P_Hierarchy_version_id             => l_Hierarchy_Version_Id,
           P_Parent_Hierarchy_id              => NULL,
           P_Hierarchy_Id                     => Node_rec.Hierarchy_Node_id,
           p_Business_group_Id                => P_Business_group_id,
           p_Effective_Date                   => P_Effective_Date);
        End Loop;

     End Loop;

  End If;
exception when others then
p_new_hierarchy_id := null;
p_new_hierarchy_version_id := null;
raise;

 End;
End;

/
