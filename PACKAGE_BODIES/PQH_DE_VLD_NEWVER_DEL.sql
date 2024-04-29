--------------------------------------------------------
--  DDL for Package Body PQH_DE_VLD_NEWVER_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_DE_VLD_NEWVER_DEL" As
/* $Header: pqhverdl.pkb 115.2 2002/12/03 00:07:35 rpasapul noship $ */
 Procedure PQH_DE_CREATE_VERSION
 (p_WRKPLC_VLDTN_VER_ID In Number,
  P_Business_Group_Id   In Number)  is

 L_Wrkplc_Vldtn_Ver_Id            Pqh_De_Wrkplc_Vldtn_Vers.Wrkplc_Vldtn_Ver_Id%TYPE;
 l_object_Version_Number          Pqh_De_Wrkplc_Vldtn_Vers.object_Version_Number%TYPE;
 l_Opr_Object_Version_Number      Pqh_De_Wrkplc_Vldtn_Ops.object_Version_Number%TYPE;
 l_Wrkplc_Vldtn_Op_Id             Pqh_De_Wrkplc_Vldtn_Ops.Wrkplc_Vldtn_Op_Id%TYPE;
 l_Job_Object_Version_Number      Pqh_De_Wrkplc_Vldtn_Jobs.object_Version_Number%TYPE;
 l_Wrkplc_Vldtn_Job_Id            Pqh_De_Wrkplc_Vldtn_Jobs.Wrkplc_Vldtn_JOb_Id%TYPE;
 l_Jobftr_Object_Version_Number   Pqh_De_Wrkplc_Vldtn_JobFtrs.object_Version_Number%TYPE;
 l_Wrkplc_Vldtn_JobFTr_Id         Pqh_De_Wrkplc_Vldtn_JobFTRS.Wrkplc_Vldtn_JObFTr_Id%TYPE;
 l_WRKPLC_VLDTN_LVLNUM_Id         Pqh_de_Wrkplc_Vldtn_Lvlnums.WRKPLC_VLDTN_LVLNUM_Id%TYPE;
 l_Lvlnum_Object_Version_Number   Pqh_De_Wrkplc_Vldtn_Lvlnums.object_Version_Number%TYPE;


  Cursor wrkplc_vldtn_defn is
  Select b.Wrkplc_Vldtn_Id,VALIDATION_NAME, EMPLOYMENT_TYPE, REMUNERATION_REGULATION, WRKPLC_VLDTN_VER_ID, VERSION_NUMBER,
         REMUNERATION_JOB_DESCRIPTION, JOB_GROUP_ID, REMUNERATION_JOB_ID, DERIVED_GRADE_ID, DERIVED_CASE_GROUP_ID,
         DERIVED_SUBCASGRP_ID, USER_ENTERABLE_GRADE_ID, USER_ENTERABLE_CASE_GROUP_ID, USER_ENTERABLE_SUBCASGRP_ID,
         Tariff_contract_code, Tariff_Group_Code
   From  Pqh_De_Wrkplc_Vldtns b, Pqh_De_Wrkplc_Vldtn_Vers a
   Where a.WRKPLC_VLDTN_VER_ID = p_WRKPLC_VLDTN_VER_ID and
         a.Business_Group_Id   = P_Business_Group_Id   and
         b.Wrkplc_Vldtn_Id     = a.Wrkplc_Vldtn_Id     and
         b.Business_Group_Id   = a.Business_Group_Id;

 Cursor  Wrkplc_Vldtn_Oprs (p_WRKPLC_VLDTN_VER_ID In Number) is
 Select  WRKPLC_VLDTN_OP_ID, WRKPLC_OPERATION_ID, DESCRIPTION, UNIT_PERCENTAGE
   From  Pqh_De_Wrkplc_Vldtn_Ops
   Where Wrkplc_Vldtn_Ver_Id = P_Wrkplc_Vldtn_Ver_Id and
         Business_Group_id   = P_Business_Group_Id;

 Cursor  Wrkplc_Vldtn_Jobs (p_Wrkplc_Vldtn_Op_Id in Number) is
 Select  WRKPLC_VLDTN_JOB_ID, WRKPLC_JOB_ID, DESCRIPTION
   From  Pqh_De_Wrkplc_Vldtn_Jobs
  Where  Wrkplc_Vldtn_Op_Id = P_Wrkplc_Vldtn_Op_Id and
         Business_Group_Id  = p_Business_Group_Id;

 Cursor Wrkplc_Vldtn_JobFtrs (P_Wrkplc_Vldtn_OpJob_Id In Number,P_Wrkplc_Vldtn_OprJob_Type In Varchar2) is
 Select WRKPLC_VLDTN_JOBFTR_ID, JOB_FEATURE_CODE
   From PQH_DE_WRKPLC_VLDTN_JOBFTRS
  Where WRKPLC_VLDTN_OPR_JOB_TYPE = P_Wrkplc_Vldtn_OprJob_Type and
        WRKPLC_VLDTN_OPR_JOB_ID   = P_Wrkplc_Vldtn_OpJob_Id    and
        Business_group_id         = p_Business_group_id;

 Cursor Wrkplc_Vldtn_Lvlnum (p_WRKPLC_VLDTN_VER_ID In Number) is
 Select WRKPLC_VLDTN_LVLNUM_ID, LEVEL_NUMBER_ID, LEVEL_CODE_ID
   From Pqh_De_Wrkplc_Vldtn_Lvlnums
  where Wrkplc_Vldtn_Ver_id = p_WRKPLC_VLDTN_VER_ID and
        Business_group_Id   = p_Business_Group_Id;

 Begin
  For Defrec in wrkplc_vldtn_defn
  Loop
    -- Call Vldtn Definition Api
    -- Call Vldtn Version Api
  PQH_DE_VLDVER_API.Insert_Vldtn_Vern
  (p_effective_date                => Trunc(Sysdate)
  ,p_business_group_id             => p_Business_group_id
  ,p_WRKPLC_VLDTN_ID               => Defrec.Wrkplc_Vldtn_Id
  ,P_VERSION_NUMBER                => Defrec.version_number
  ,P_REMUNERATION_JOB_DESCRIPTION  => Defrec.REMUNERATION_JOB_DESCRIPTION
  ,P_TARIFF_CONTRACT_CODE          => Defrec.Tariff_Contract_Code
  ,P_TARIFF_GROUP_CODE             => Defrec.Tariff_Group_Code
  ,P_JOB_GROUP_ID                  => Defrec.Job_Group_Id
  ,P_REMUNERATION_JOB_ID           => Defrec.Remuneration_Job_Id
  ,P_DERIVED_GRADE_ID              => Defrec.Derived_Grade_Id
  ,P_DERIVED_CASE_GROUP_ID         => Defrec.Derived_Case_Group_Id
  ,P_DERIVED_SUBCASGRP_ID          => Defrec.Derived_Subcasgrp_Id
  ,P_USER_ENTERABLE_GRADE_ID       => Defrec.USER_ENTERABLE_GRADE_ID
  ,P_USER_ENTERABLE_CASE_GROUP_ID  => Defrec.USER_ENTERABLE_CASE_GROUP_ID
  ,P_USER_ENTERABLE_SUBCASGRP_ID   => Defrec.USER_ENTERABLE_SUBCASGRP_ID
  ,P_FREEZE                        => 'U'
  ,p_WRKPLC_VLDTN_VER_ID           => l_Wrkplc_Vldtn_ver_Id
  ,p_object_version_number         => l_Object_Version_Number);

    -- Employment Type White Collar Worker - Common Part

    If Defrec.Employment_type = 'WC' and Defrec.REMUNERATION_REGULATION = 'CP' Then
       For Oprrec in Wrkplc_Vldtn_Oprs(Defrec.WRKPLC_VLDTN_VER_ID)
       Loop
         --- Call Operation Api
         PQH_DE_VLDOPR_API.Insert_Vldtn_Oprn
         (p_effective_date         => Trunc(Sysdate)
         ,p_business_group_id      => P_Business_Group_Id
         ,p_WRKPLC_VLDTN_VER_ID    => l_Wrkplc_Vldtn_Ver_Id
         ,P_WRKPLC_OPERATION_ID    => Oprrec.Wrkplc_Operation_Id
         ,P_DESCRIPTION            => Oprrec.Description
         ,P_UNIT_PERCENTAGE        => Oprrec.Unit_Percentage
         ,P_WRKPLC_VLDTN_OP_ID     => l_Wrkplc_Vldtn_Op_Id
         ,p_object_version_number  => l_Opr_Object_Version_Number);

         For JobFtrRec in Wrkplc_Vldtn_JobFtrs(Oprrec.Wrkplc_Vldtn_Op_Id,'O')
         Loop
           -- Call Job Feature Api ---
           PQH_DE_VLDJOBFTR_API.Insert_Vldtn_JObftr
           (p_effective_date            => Trunc(Sysdate)
           ,p_business_group_id         => p_Business_Group_Id
           ,p_WRKPLC_VLDTN_OPR_JOB_ID   => l_Wrkplc_Vldtn_Op_Id
           ,P_JOB_FEATURE_CODE          => JobFtrRec.JOB_FEATURE_CODE
           ,P_Wrkplc_Vldtn_Opr_job_Type => 'O'
           ,P_WRKPLC_VLDTN_JObFTR_ID    => l_WRKPLC_VLDTN_JObFTR_ID
           ,p_object_version_number     => l_Jobftr_Object_Version_Number);
         End Loop;
         For Jobrec in Wrkplc_Vldtn_Jobs(Oprrec.Wrkplc_Vldtn_Op_Id)
         Loop
            PQH_DE_VLDJOB_API.Insert_Vldtn_JOb
            (p_effective_date           => Trunc(Sysdate)
            ,p_business_group_id        => p_Business_Group_Id
            ,p_WRKPLC_VLDTN_OP_ID       => l_Wrkplc_Vldtn_Op_Id
            ,P_WRKPLC_JOB_ID            => JobRec.Wrkplc_Job_Id
            ,P_DESCRIPTION              => Jobrec.Description
            ,P_WRKPLC_VLDTN_JOb_ID      => l_Wrkplc_Vldtn_Job_Id
            ,p_object_version_number    => l_Job_Object_Version_Number);

            For JobFtrRec in Wrkplc_Vldtn_JobFtrs(jobRec.WRKPLC_VLDTN_JOB_ID,'J')
            Loop
               -- Call Job Feature Api ---
                PQH_DE_VLDJOBFTR_API.Insert_Vldtn_JObftr
                (p_effective_date            => Trunc(Sysdate)
                ,p_business_group_id         => p_Business_Group_Id
                ,p_WRKPLC_VLDTN_OPR_JOB_ID   => l_Wrkplc_Vldtn_Op_Id
                ,P_JOB_FEATURE_CODE          => JobFtrRec.JOB_FEATURE_CODE
                ,P_Wrkplc_Vldtn_Opr_job_Type => 'J'
                ,P_WRKPLC_VLDTN_JObFTR_ID    => l_WRKPLC_VLDTN_JObFTR_ID
                ,p_object_version_number     => l_Jobftr_Object_Version_Number);
            End Loop;
         End Loop;
       End Loop;
    Elsif Defrec.Employment_type = 'CS' Then
       For LvlRec in Wrkplc_Vldtn_Lvlnum(Defrec.WRKPLC_VLDTN_VER_ID)
       Loop
          -- Call Level Number API
          PQH_DE_VLDLVL_API.Insert_Vldtn_Lvl
          (p_effective_date                => Trunc(Sysdate)
          ,p_business_group_id             => p_Business_Group_Id
          ,P_WRKPLC_VLDTN_VER_ID           => l_Wrkplc_Vldtn_Ver_Id
          ,P_LEVEL_NUMBER_ID               => lvlrec.LEVEL_NUMBER_ID
          ,P_LEVEL_CODE_ID                 => lvlrec.Level_Code_Id
          ,P_WRKPLC_VLDTN_LVLNUM_Id        => l_WRKPLC_VLDTN_LVLNUM_Id
          ,p_object_version_number         => l_lvlnum_Object_Version_Number);
       End Loop;
    End If;
  End Loop;
 End;

 Procedure PQH_DE_DELETE_VERSION
 (p_WRKPLC_VLDTN_VER_ID In Number,
  P_Business_Group_Id   In Number)  is

  Cursor wrkplc_vldtn_defn is
  Select b.Wrkplc_Vldtn_Id,VALIDATION_NAME, EMPLOYMENT_TYPE, REMUNERATION_REGULATION, WRKPLC_VLDTN_VER_ID, VERSION_NUMBER,
         REMUNERATION_JOB_DESCRIPTION, JOB_GROUP_ID, REMUNERATION_JOB_ID, DERIVED_GRADE_ID, DERIVED_CASE_GROUP_ID,
         DERIVED_SUBCASGRP_ID, USER_ENTERABLE_GRADE_ID, USER_ENTERABLE_CASE_GROUP_ID, USER_ENTERABLE_SUBCASGRP_ID, Freeze,
         a.Object_Version_Number Vers_ovn_Num, b.Object_Version_Number Def_ovn_Num
   From  Pqh_De_Wrkplc_Vldtns b, Pqh_De_Wrkplc_Vldtn_Vers a
   Where a.WRKPLC_VLDTN_VER_ID = p_WRKPLC_VLDTN_VER_ID and
         a.Business_Group_Id   = P_Business_Group_Id   and
         b.Wrkplc_Vldtn_Id     = a.Wrkplc_Vldtn_Id     and
         b.Business_Group_Id   = a.Business_Group_Id;

 Cursor  Wrkplc_Vldtn_Oprs (p_WRKPLC_VLDTN_VER_ID In Number) is
 Select  WRKPLC_VLDTN_OP_ID, WRKPLC_OPERATION_ID, DESCRIPTION, UNIT_PERCENTAGE, Object_Version_Number
   From  Pqh_De_Wrkplc_Vldtn_Ops
   Where Wrkplc_Vldtn_Ver_Id = P_Wrkplc_Vldtn_Ver_Id and
         Business_Group_id   = P_Business_Group_Id;

 Cursor  Wrkplc_Vldtn_Jobs (p_Wrkplc_Vldtn_Op_Id in Number) is
 Select  WRKPLC_VLDTN_JOB_ID, WRKPLC_JOB_ID, DESCRIPTION, Object_version_Number
   From  Pqh_De_Wrkplc_Vldtn_Jobs
  Where  Wrkplc_Vldtn_Op_Id = P_Wrkplc_Vldtn_Op_Id and
         Business_Group_Id  = p_Business_Group_Id;

 Cursor Wrkplc_Vldtn_JobFtrs (P_Wrkplc_Vldtn_OpJob_Id In Number,P_Wrkplc_Vldtn_OprJob_Type In Varchar2) is
 Select WRKPLC_VLDTN_JOBFTR_ID, JOB_FEATURE_CODE, Object_Version_Number
   From PQH_DE_WRKPLC_VLDTN_JOBFTRS
  Where WRKPLC_VLDTN_OPR_JOB_TYPE = P_Wrkplc_Vldtn_OprJob_Type and
        WRKPLC_VLDTN_OPR_JOB_ID   = P_Wrkplc_Vldtn_OpJob_Id    and
        Business_group_id         = p_Business_group_id;

 Cursor Wrkplc_Vldtn_Lvlnum (p_WRKPLC_VLDTN_VER_ID In Number) is
 Select WRKPLC_VLDTN_LVLNUM_ID, LEVEL_NUMBER_ID, LEVEL_CODE_ID, Object_Version_Number
   From Pqh_De_Wrkplc_Vldtn_Lvlnums
  where Wrkplc_Vldtn_Ver_id = p_WRKPLC_VLDTN_VER_ID and
        Business_group_Id   = p_Business_Group_Id;
 l_vldcnt                         Number;

 Begin
  For Defrec in wrkplc_vldtn_defn
  Loop

    If Defrec.Freeze = 'F' then
       Hr_utility.Set_message(8302,'DE_PQH_VERDEL');
       Hr_utility.raise_Error;

    Else
      -- Employment Type White Collar Worker - Common Part
      If Defrec.Employment_type = 'WC' and Defrec.REMUNERATION_REGULATION = 'CP' Then

         For Oprrec in Wrkplc_Vldtn_Oprs(Defrec.WRKPLC_VLDTN_VER_ID)
         Loop

           For JobFtrRec in Wrkplc_Vldtn_JobFtrs(Oprrec.Wrkplc_Vldtn_Op_Id,'O')
           Loop
             -- Call Job Feature Api ---
                PQH_DE_VLDJOBFTR_API.Delete_Vldtn_JobFtr
                (p_WRKPLC_VLDTN_JobFtr_Id        => Jobftrrec.WRKPLC_VLDTN_JOBFTR_ID
                ,p_object_version_number         => Jobftrrec.Object_Version_Number);
           End Loop;

           For Jobrec in Wrkplc_Vldtn_Jobs(Oprrec.Wrkplc_Vldtn_Op_Id)
           Loop

             For JobFtrRec in Wrkplc_Vldtn_JobFtrs(jobRec.WRKPLC_VLDTN_JOB_ID,'J')
             Loop
                 -- Call Job Feature Api ---
                PQH_DE_VLDJOBFTR_API.Delete_Vldtn_JobFtr
                (p_WRKPLC_VLDTN_JobFtr_Id        => Jobftrrec.WRKPLC_VLDTN_JOBFTR_ID
                ,p_object_version_number         => Jobftrrec.Object_Version_Number);

             End Loop;

               PQH_DE_VLDJOB_API.Delete_Vldtn_Job
               (p_WRKPLC_VLDTN_Job_Id           => Jobrec.WRKPLC_VLDTN_Job_Id
               ,p_object_version_number         => Jobrec.Object_Version_Number);

           End Loop;

           Pqh_de_vldopr_Api.delete_Vldtn_Oprn
           (p_WRKPLC_VLDTN_OP_ID          => oprrec.Wrkplc_vldtn_op_id
           ,p_object_version_number       => Oprrec.Object_version_number);

         End Loop;

      Elsif Defrec.Employment_type = 'CS' Then

         For LvlRec in Wrkplc_Vldtn_Lvlnum(Defrec.WRKPLC_VLDTN_VER_ID)
         Loop
           PQH_DE_VLDLVL_API.Delete_Vldtn_Lvl
           (P_WRKPLC_VLDTN_Lvlnum_Id      => Lvlrec.WRKPLC_VLDTN_Lvlnum_Id
           ,p_object_version_number       => Lvlrec.Object_Version_Number);
         End Loop;

      End If; --- Employment Type

    End If; -- Freeze

    PQH_DE_VLDVER_API.Delete_Vldtn_Vern
    (p_WRKPLC_VLDTN_VER_ID          => Defrec.WRKPLC_VLDTN_VER_ID
    ,p_object_version_number        => Defrec.Vers_ovn_Num);

    Select Count(*) into l_vldcnt
    from  Pqh_De_Wrkplc_Vldtn_vers
    Where WRKPLC_VLDTN_ID = Defrec.WRKPLC_VLDTN_ID;

    If Nvl(l_vldcnt,0) = 0 Then
       PQH_DE_VLDDEF_API.Delete_Vldtn_Defn
       (p_WRKPLC_VLDTN_ID             => Defrec.WRKPLC_VLDTN_ID
       ,p_object_version_number       => Defrec.Def_ovn_Num);
    End If;

  End Loop;
 End;

 Procedure PQH_DE_DELETE_OPERATION
 (p_WRKPLC_VLDTN_OP_ID  In Number,
  P_Business_Group_Id   In Number)  is

 Cursor  Wrkplc_Vldtn_Oprs is
 Select  WRKPLC_VLDTN_OP_ID, WRKPLC_OPERATION_ID, DESCRIPTION, UNIT_PERCENTAGE, Object_Version_Number
   From  Pqh_De_Wrkplc_Vldtn_Ops
   Where WRKPLC_VLDTN_OP_ID  = P_WRKPLC_VLDTN_OP_ID and
         Business_Group_id   = P_Business_Group_Id;

 Cursor  Wrkplc_Vldtn_Jobs (p_Wrkplc_Vldtn_Op_Id in Number) is
 Select  WRKPLC_VLDTN_JOB_ID, WRKPLC_JOB_ID, DESCRIPTION, Object_version_Number
   From  Pqh_De_Wrkplc_Vldtn_Jobs
  Where  Wrkplc_Vldtn_Op_Id = P_Wrkplc_Vldtn_Op_Id and
         Business_Group_Id  = p_Business_Group_Id;

 Cursor Wrkplc_Vldtn_JobFtrs (P_Wrkplc_Vldtn_OpJob_Id In Number,P_Wrkplc_Vldtn_OprJob_Type In Varchar2) is
 Select WRKPLC_VLDTN_JOBFTR_ID, JOB_FEATURE_CODE, Object_Version_Number
   From PQH_DE_WRKPLC_VLDTN_JOBFTRS
  Where WRKPLC_VLDTN_OPR_JOB_TYPE = P_Wrkplc_Vldtn_OprJob_Type and
        WRKPLC_VLDTN_OPR_JOB_ID   = P_Wrkplc_Vldtn_OpJob_Id    and
        Business_group_id         = p_Business_group_id;

 l_vldcnt                         Number;

 Begin
   For Oprrec in Wrkplc_Vldtn_Oprs
   Loop
      For JobFtrRec in Wrkplc_Vldtn_JobFtrs(Oprrec.Wrkplc_Vldtn_Op_Id,'O')
      Loop
         -- Call Job Feature Api ---
         PQH_DE_VLDJOBFTR_API.Delete_Vldtn_JobFtr
         (p_WRKPLC_VLDTN_JobFtr_Id        => Jobftrrec.WRKPLC_VLDTN_JOBFTR_ID
         ,p_object_version_number         => Jobftrrec.Object_Version_Number);
      End Loop;

      For Jobrec in Wrkplc_Vldtn_Jobs(Oprrec.Wrkplc_Vldtn_Op_Id)
      Loop
          For JobFtrRec in Wrkplc_Vldtn_JobFtrs(jobRec.WRKPLC_VLDTN_JOB_ID,'J')
          Loop
             -- Call Job Feature Api ---
              PQH_DE_VLDJOBFTR_API.Delete_Vldtn_JobFtr
              (p_WRKPLC_VLDTN_JobFtr_Id        => Jobftrrec.WRKPLC_VLDTN_JOBFTR_ID
              ,p_object_version_number         => Jobftrrec.Object_Version_Number);
           End Loop;
           PQH_DE_VLDJOB_API.Delete_Vldtn_Job
           (p_WRKPLC_VLDTN_Job_Id           => Jobrec.WRKPLC_VLDTN_Job_Id
            ,p_object_version_number         => Jobrec.Object_Version_Number);
      End Loop;

      Pqh_de_vldopr_Api.delete_Vldtn_Oprn
      (p_WRKPLC_VLDTN_OP_ID          => oprrec.Wrkplc_vldtn_op_id
      ,p_object_version_number       => Oprrec.Object_version_number);

   End Loop;

 End;

Procedure PQH_DE_DELETE_JOB
 (p_WRKPLC_VLDTN_JOB_ID  In Number,
  P_Business_Group_Id   In Number)  is

 Cursor  Wrkplc_Vldtn_Jobs  is
 Select  WRKPLC_VLDTN_JOB_ID, WRKPLC_JOB_ID, DESCRIPTION, Object_version_Number
   From  Pqh_De_Wrkplc_Vldtn_Jobs
  Where  Wrkplc_Vldtn_Job_Id = p_WRKPLC_VLDTN_JOB_ID and
         Business_Group_Id   = p_Business_Group_Id;

 Cursor Wrkplc_Vldtn_JobFtrs (P_Wrkplc_Vldtn_OpJob_Id In Number,P_Wrkplc_Vldtn_OprJob_Type In Varchar2) is
 Select WRKPLC_VLDTN_JOBFTR_ID, JOB_FEATURE_CODE, Object_Version_Number
   From PQH_DE_WRKPLC_VLDTN_JOBFTRS
  Where WRKPLC_VLDTN_OPR_JOB_TYPE = P_Wrkplc_Vldtn_OprJob_Type and
        WRKPLC_VLDTN_OPR_JOB_ID   = P_Wrkplc_Vldtn_OpJob_Id    and
        Business_group_id         = p_Business_group_id;

 l_vldcnt                         Number;

 Begin
  For Jobrec in Wrkplc_Vldtn_Jobs
  Loop
     For JobFtrRec in Wrkplc_Vldtn_JobFtrs(jobRec.WRKPLC_VLDTN_JOB_ID,'J')
     Loop
        -- Call Job Feature Api ---
        PQH_DE_VLDJOBFTR_API.Delete_Vldtn_JobFtr
        (p_WRKPLC_VLDTN_JobFtr_Id        => Jobftrrec.WRKPLC_VLDTN_JOBFTR_ID
        ,p_object_version_number         => Jobftrrec.Object_Version_Number);
     End Loop;
     PQH_DE_VLDJOB_API.Delete_Vldtn_Job
     (p_WRKPLC_VLDTN_Job_Id           => Jobrec.WRKPLC_VLDTN_Job_Id
     ,p_object_version_number         => Jobrec.Object_Version_Number);
  End Loop;
 End;

Procedure PQH_DE_IN_UP_CALL
 (
   P_EFFECTIVE_DATE            IN        	DATE
  ,P_BUSINESS_GROUP_ID         IN   		NUMBER
  ,P_WRKPLC_VLDTN_VER_ID       IN  		NUMBER
  ,P_LEVEL_NUMBER_ID           IN    		NUMBER
  ,P_LEVEL_CODE_ID             IN   		NUMBER
  ,P_WRKPLC_VLDTN_LVLNUM_ID    IN OUT NOCOPY   	NUMBER
  ,P_OBJECT_VERSION_NUMBER     IN OUT NOCOPY   	NUMBER
  ,P_RETURN_STATUS             OUT NOCOPY   	VARCHAR2
) is
 Cnt Number;
-- Variables for IN/OUT parameters
  l_wrkplc_vldtn_lvlnum_id number := P_WRKPLC_VLDTN_LVLNUM_ID;
  l_object_version_number  number := p_object_version_number;

 Cursor Chk_Ins_Upd(p_Wrkplc_Val_Ver_Id IN Number, p_Lvl_Code_Id IN Number, 			p_Lvl_Number_Id IN Number)
 is
 Select count(*)  from
        pqh_de_wrkplc_vldtn_lvlnums
  where WRKPLC_VLDTN_VER_ID             = p_Wrkplc_Val_Ver_Id
    and LEVEL_NUMBER_ID         	= p_Lvl_Number_Id
    and LEVEL_CODE_ID  			= p_Lvl_Code_Id;
Begin
 Open  Chk_Ins_Upd(P_WRKPLC_VLDTN_VER_ID, P_LEVEL_CODE_ID, P_LEVEL_NUMBER_ID);
 Fetch Chk_Ins_Upd into Cnt;
 Close Chk_Ins_Upd;
if(Cnt>0)
then
-- Calling the update Proc.

	pqh_de_vldlvl_swi.UPDATE_VLDTN_LVL
	 (
	   p_effective_date               	=> P_EFFECTIVE_DATE
	  ,p_business_group_id                  => P_BUSINESS_GROUP_ID
	  ,p_wrkplc_vldtn_ver_id                => P_WRKPLC_VLDTN_VER_ID
	  ,p_level_number_id                    => P_LEVEL_NUMBER_ID
	  ,p_level_code_id                      => P_LEVEL_CODE_ID
	  ,p_wrkplc_vldtn_lvlnum_id             => P_WRKPLC_VLDTN_LVLNUM_ID
	  ,p_object_version_number              => P_OBJECT_VERSION_NUMBER
	  ,p_return_status       		=> P_RETURN_STATUS
	 );



else

	pqh_de_vldlvl_swi.INSERT_VLDTN_LVL
	  (
	     p_effective_date               => P_EFFECTIVE_DATE
	    ,p_business_group_id            => P_BUSINESS_GROUP_ID
	    ,p_wrkplc_vldtn_ver_id          => P_WRKPLC_VLDTN_VER_ID
	    ,p_level_number_id              => P_LEVEL_NUMBER_ID
	    ,p_level_code_id                => P_LEVEL_CODE_ID
	    ,p_wrkplc_vldtn_lvlnum_id       => P_WRKPLC_VLDTN_LVLNUM_ID
	    ,p_object_version_number        => P_OBJECT_VERSION_NUMBER
            ,p_return_status                => P_RETURN_STATUS
          );
end if;
exception when others then
p_wrkplc_vldtn_lvlnum_id := L_WRKPLC_VLDTN_LVLNUM_ID;
p_object_version_number  := l_object_version_number;
--Intentionally not setting the return status to null as error status should be returned.
end PQH_DE_IN_UP_CALL;
 End;

/
