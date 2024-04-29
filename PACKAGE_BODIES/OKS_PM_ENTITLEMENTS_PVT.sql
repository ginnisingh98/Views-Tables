--------------------------------------------------------
--  DDL for Package Body OKS_PM_ENTITLEMENTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_PM_ENTITLEMENTS_PVT" AS
/* $Header: OKSRPMEB.pls 120.5 2006/07/10 13:15:30 jvorugan noship $ */
PROCEDURE Get_PMContracts_02_Format
    (P_Contracts            IN  OKS_ENTITLEMENTS_PVT.GT_Contract_Ref
    ,P_BusiProc_Id	        IN  Gx_BusProcess_Id
    ,P_Severity_Id	        IN  Gx_Severity_Id
    ,P_Request_TZone_Id	    IN  Gx_TimeZoneId
    ,P_Request_Date         IN  DATE
    ,P_Request_Date_Start   IN  DATE
    ,P_Request_Date_End     IN  DATE
    ,P_Calc_RespTime_YN     IN  VARCHAR2
    ,P_Validate_Eff         IN  VARCHAR2
    ,P_Validate_Flag        IN  VARCHAR2
    ,P_SrvLine_Flag         IN  VARCHAR2
    ,P_Sort_Key             IN  VARCHAR2
    ,X_Contracts_02         out nocopy OKS_ENTITLEMENTS_PUB.Get_ConTop_Tbl
    ,X_Activities_02        out nocopy OKS_PM_ENTITLEMENTS_PUB.Get_Activityop_Tbl
    ,X_Result               out nocopy Gx_Boolean
    ,X_Return_Status   	    out nocopy Gx_Ret_Sts)
  IS


--
-- Modified for 12.0 Coverage Rearch project (JVARGHES)
--
/*
    CURSOR Lx_Csr_Contracts(Cx_Chr_Id IN Gx_OKS_Id, Cx_SrvLine_Id IN Gx_OKS_Id
                           ,Cx_CovLvlLine_Id IN Gx_OKS_Id, Cx_BP_Id IN Gx_BusProcess_Id,Cv_Cont_Pty_Id IN VARCHAR2) IS
     SELECT  HD.Id Contract_Id
	        ,HD.Contract_Number
            ,HD.Contract_Number_Modifier
            ,HD.Sts_Code
            ,HD.Authoring_Org_Id
            ,HD.Inv_Organization_Id
            ,HD.End_Date HDR_End_Date --grace period changes
	        ,SV.Id Service_Line_Id
            ,SV.Start_Date SV_Start_Date
	        ,OKS_ENTITLEMENTS_PVT.Get_End_Date_Time(SV.End_Date) SV_End_Date
            ,OKS_ENTITLEMENTS_PVT.Get_End_Date_Time(SV.Date_Terminated) SV_Date_Terminated
            ,CL.Sts_Code CL_Sts_Code
	        ,CL.Id CovLvl_Line_Id
            ,CL.Start_Date CL_Start_Date
	        ,OKS_ENTITLEMENTS_PVT.Get_End_Date_Time(CL.End_Date) CL_End_Date
            ,OKS_ENTITLEMENTS_PVT.Get_End_Date_Time(CL.Date_Terminated) CL_Date_Terminated
       --   ,DECODE(SV.Lse_Id,14,'Y','N') Warranty_Flag
            ,DECODE(SV.Lse_Id, 14, 'Y', 15, 'Y', 16, 'Y', 17, 'Y', 18, 'Y', 'N') Warranty_Flag
            ,okscov.pm_program_id  PM_Program_Id --rul.object1_id1  PM_Program_Id
            ,okscov.pm_sch_exists_yn PM_Schedule_Exists --rul.rule_information2 PM_Schedule_Exists
        FROM Okc_K_Headers_B HD
            ,Okc_K_Lines_B SV
            ,Okc_K_Lines_B CL
            ,okc_k_lines_v cov
--            ,okc_rule_groups_b rgp  -- 11.5.10 rule rearchitecture changes
--            ,okc_rules_b rul    -- 11.5.10 rule rearchitecture changes
            ,oks_k_lines_b okscov -- 11.5.10 rule rearchitecture changes
       WHERE sv.id = cov.cle_id
--  rule rearchitecture changes
         and cov.id = okscov.cle_id
         and okscov.pm_program_id is not null
--         AND cov.id = rgp.cle_id
--         AND rgp.id = rul.rgp_id
--         AND cov.dnz_chr_id = rgp.dnz_chr_id
--         AND rul.rule_information_category = 'PMP'
--  rule rearchitecture changes
         AND HD.Id = Cx_Chr_Id
         AND HD.Scs_Code IN ('SERVICE','WARRANTY')
         AND HD.Id > -1
         AND HD.Template_YN <> 'Y'
         AND SV.Dnz_Chr_Id = HD.Id
         AND SV.Cle_Id IS NULL
         AND SV.Chr_Id = HD.Id
         AND SV.Lse_ID IN (1,14,19)
         AND SV.Id = NVL(Cx_SrvLine_Id,SV.Id)
         AND CL.Cle_Id = SV.Id
         AND CL.Lse_ID IN (7,8,9,10,11,35,18,25)
         AND CL.Id = NVL(Cx_CovLvlLine_Id, CL.Id)
         AND (Cv_Cont_Pty_Id IS NULL
             OR
             EXISTS   (SELECT '*'
                         FROM Okc_K_Party_Roles_B PR
                        WHERE PR.Chr_Id = HD.Id
                          AND PR.Cle_Id IS NULL
                          AND PR.Dnz_Chr_Id = HD.Id
                          AND PR.Object1_Id1 = Cv_Cont_Pty_Id
                          AND PR.Object1_Id2 = '#'
                          AND PR.Jtot_Object1_Code = 'OKX_PARTY'
                          AND PR.Rle_Code <> 'VENDOR'))
         AND (Cx_BP_Id IS NULL
              OR
              EXISTS (SELECT '*'
                       FROM Okc_K_Items ITM
                           ,Okc_K_Lines_B BPL
                           ,Okc_K_Lines_B CV
                      WHERE CV.Cle_Id  = SV.Id
                        AND CV.Lse_Id IN (2,15,20)
                        AND BPL.Cle_Id = CV.Id
                        AND ITM.Cle_Id = BPL.Id
                        AND ITM.Object1_Id1 =   TO_CHAR(Cx_BP_Id)
                        AND ITM.Object1_Id2 = '#'
                       AND ITM.Jtot_Object1_Code = 'OKX_BUSIPROC'));
*/

--
-- Modified for 12.0 Coverage Rearch project (JVARGHES)
--

    CURSOR Lx_Csr_Contracts(Cx_Chr_Id IN Gx_OKS_Id, Cx_SrvLine_Id IN Gx_OKS_Id
                           ,Cx_CovLvlLine_Id IN Gx_OKS_Id, Cx_BP_Id IN Gx_BusProcess_Id,Cv_Cont_Pty_Id IN VARCHAR2) IS
     SELECT  HD.Id Contract_Id
	      ,HD.Contract_Number
            ,HD.Contract_Number_Modifier
            ,HD.Sts_Code
            ,HD.Authoring_Org_Id
            ,HD.Inv_Organization_Id
            ,HD.End_Date HDR_End_Date --grace period changes
	      ,SV.Id Service_Line_Id
            ,SV.Start_Date SV_Start_Date
	      ,OKS_ENTITLEMENTS_PVT.Get_End_Date_Time(SV.End_Date) SV_End_Date
            ,OKS_ENTITLEMENTS_PVT.Get_End_Date_Time(SV.Date_Terminated) SV_Date_Terminated
            ,CL.Sts_Code CL_Sts_Code
	      ,CL.Id CovLvl_Line_Id
            ,CL.Start_Date CL_Start_Date
	      ,OKS_ENTITLEMENTS_PVT.Get_End_Date_Time(CL.End_Date) CL_End_Date
            ,OKS_ENTITLEMENTS_PVT.Get_End_Date_Time(CL.Date_Terminated) CL_Date_Terminated
            ,DECODE(SV.Lse_Id, 14, 'Y', 15, 'Y', 16, 'Y', 17, 'Y', 18, 'Y', 'N') Warranty_Flag
            ,okssrv.pm_program_id  PM_Program_Id --rul.object1_id1  PM_Program_Id
            ,okssrv.pm_sch_exists_yn PM_Schedule_Exists --rul.rule_information2 PM_Schedule_Exists
        FROM Okc_K_Headers_ALL_B HD  -- Modified for 12.0 MOAC project (JVARGHES)
            ,Okc_K_Lines_B SV
            ,Okc_K_Lines_B CL
            ,oks_k_lines_b okssrv
       WHERE sv.id = okssrv.cle_id
         and okssrv.pm_program_id is not null
         AND HD.Id = Cx_Chr_Id
         AND HD.Scs_Code IN ('SERVICE','WARRANTY')
         AND HD.Id > -1
         AND HD.Template_YN <> 'Y'
         AND SV.Dnz_Chr_Id = HD.Id
         AND SV.Cle_Id IS NULL
         AND SV.Chr_Id = HD.Id
         AND SV.Lse_ID IN (1,14,19)
         AND SV.Id = NVL(Cx_SrvLine_Id,SV.Id)
         AND CL.Cle_Id = SV.Id
         AND CL.Lse_ID IN (7,8,9,10,11,35,18,25)
         AND CL.Id = NVL(Cx_CovLvlLine_Id, CL.Id)
         AND (Cv_Cont_Pty_Id IS NULL
             OR
             EXISTS   (SELECT '*'
                         FROM Okc_K_Party_Roles_B PR
                        WHERE PR.Chr_Id = HD.Id
                          AND PR.Cle_Id IS NULL
                          AND PR.Dnz_Chr_Id = HD.Id
                          AND PR.Object1_Id1 = Cv_Cont_Pty_Id
                          AND PR.Object1_Id2 = '#'
                          AND PR.Jtot_Object1_Code = 'OKX_PARTY'
                          AND PR.Rle_Code <> 'VENDOR'))
         AND (Cx_BP_Id IS NULL
              OR
              EXISTS (SELECT '*'
                       FROM Okc_K_Items ITM
                           ,Okc_K_Lines_B BPL
                      WHERE BPL.Cle_Id = OKSSRV.Coverage_ID
                        AND BPL.Lse_Id IN (3,16,21)
                        AND ITM.Cle_Id = BPL.Id
                        AND ITM.Object1_Id1 =   TO_CHAR(Cx_BP_Id)
                        AND ITM.Object1_Id2 = '#'
                       AND ITM.Jtot_Object1_Code = 'OKX_BUSIPROC'));

--
--

--
-- Modified for 12.0 Coverage Rearch project (JVARGHES)
--
/*
    CURSOR Lx_Csr_Activities(Cx_SrvLine_Id IN Gx_OKS_Id)
     IS
    SELECT
            cov.cle_Id SrvLine_Id,
            okscov.pm_program_id PROGRAM_ID, --pma.object3_id1 PROGRAM_ID,
            pmact.activity_id ACTIVITY_ID, --pma.object1_id1 ACTIVITY_ID,
            pmact.sch_exists_yn SCHEDULE_EXISTS --pma.rule_information3 SCHEDULE_EXISTS
    FROM
        OKC_K_lines_b cov,
-- rule rearchitecture changes
        oks_pm_activities pmact,
        oks_k_lines_b     okscov
--        OKC_Rule_Groups_B rgp,
--        OKC_rules_b pma
-- rule rearchitecture changes
    WHERE  cov.cle_Id     = Cx_SrvLine_Id
    AND    cov.lse_id      in (2,15,20)
-- rule rearchitecture changes
--    AND    cov.dnz_chr_id = rgp.dnz_chr_id
--    AND    cov.id         = rgp.cle_id
--    AND    rgp.id         = pma.rgp_id
--    AND   pma.rule_information_category='PMA'
--    AND   pma.rule_information1 = 'Y'
    and    cov.id = pmact.cle_id
    and    pmact.select_yn = 'Y'
    and    cov.id = okscov.cle_id;
-- rule rearchitecture changes
*/

--
-- Modified for 12.0 Coverage Rearch project (JVARGHES)
--

    CURSOR Lx_Csr_Activities(Cx_SrvLine_Id IN Gx_OKS_Id)
     IS
    SELECT
            srv.Id SrvLine_Id,
            okssrv.pm_program_id PROGRAM_ID,
            pmact.activity_id ACTIVITY_ID,
            pmact.sch_exists_yn SCHEDULE_EXISTS
    FROM
        OKC_K_lines_b srv,
        oks_pm_activities pmact,
        oks_k_lines_b     okssrv
    WHERE  srv.Id     = Cx_SrvLine_Id
    AND    srv.lse_id      in (1,14,19)
    and    srv.id = pmact.cle_id
    and    pmact.select_yn = 'Y'
    and    srv.id = okssrv.cle_id;

--
--

    Lx_Contracts             OKS_ENTITLEMENTS_PVT.GT_Contract_Ref DEFAULT P_Contracts;
    Ld_Request_Date          CONSTANT DATE := P_Request_Date;
    Ld_Request_Date_Start    CONSTANT DATE := P_Request_Date_Start;
    Ld_Request_Date_End      CONSTANT DATE := P_Request_Date_End;
    Lv_Validate_Flag         VARCHAR2(1) := P_Validate_Flag;
    Lv_SrvLine_Flag          CONSTANT VARCHAR2(1) := P_SrvLine_Flag;
    Lv_Sort_Key              CONSTANT VARCHAR2(10):= P_Sort_Key;

    Lx_BusiProc_Id	         CONSTANT Gx_BusProcess_Id := P_BusiProc_Id;
    Lx_Severity_Id	         CONSTANT Gx_Severity_Id := P_Severity_Id;
    Lx_Request_TZone_Id	     CONSTANT Gx_TimeZoneId := P_Request_TZone_Id;
    Lv_Calc_RespTime_YN      CONSTANT VARCHAR2(1) := P_Calc_RespTime_YN;
    Lv_Validate_Eff          CONSTANT VARCHAR2(1) := P_Validate_Eff;
    Lv_Cont_Pty_Id           VARCHAR2(100);

    Lx_Contracts_02          OKS_ENTITLEMENTS_PUB.Get_ConTop_Tbl;
    --ph2
    Lx_Activities_02          OKS_PM_ENTITLEMENTS_PUB.Get_Activityop_Tbl;
    Lx_Contracts_02_out      OKS_ENTITLEMENTS_PUB.Get_ConTop_Tbl;
    Lx_Contracts_02_Val      OKS_ENTITLEMENTS_PUB.Get_ConTop_Tbl;

    Lx_Idx_Rec               OKS_ENTITLEMENTS_PVT.Idx_Rec;

    Lx_Result                Gx_Boolean DEFAULT G_TRUE;
    Lx_Return_Status         Gx_Ret_Sts DEFAULT G_RET_STS_SUCCESS;

    Li_TableIdx              BINARY_INTEGER;
    Li_OutTab_Idx            BINARY_INTEGER := 0;
    --ph2
     Li_ActOutTab_Idx            BINARY_INTEGER := 0;
    Lv_Entile_Flag           VARCHAR2(1);
    Lv_Effective_Falg        VARCHAR2(1);

    Lx_SrvLine_Id            Gx_OKS_Id;
    Lx_CovLvlLine_Id         Gx_OKS_Id;

    Ln_Msg_Count	     NUMBER;
    Lv_Msg_Data		     VARCHAR2(2000);

    L_EXCEP_UNEXPECTED_ERR   EXCEPTION;

  BEGIN

    Li_TableIdx  := Lx_Contracts.FIRST;
--dbms_output.put_line('Value of Li_TableIdx='||Li_TableIdx);
    WHILE Li_TableIdx IS NOT NULL LOOP

      IF Lv_SrvLine_Flag = 'T' THEN

        Lx_SrvLine_Id     := Lx_Contracts(Li_TableIdx).Rx_Cle_Id;
        Lx_CovLvlLine_Id  := NULL;

      ELSE
        Lx_SrvLine_Id     := NULL;
        Lx_CovLvlLine_Id  := Lx_Contracts(Li_TableIdx).Rx_Cle_Id;
--        dbms_output.put_line('Value of cle_id '||Lx_Contracts(Li_TableIdx).Rx_Cle_Id);
      END IF;


      Lv_Cont_Pty_Id  := TO_CHAR(Lx_Contracts(Li_TableIdx).Rx_Pty_Id);
      FOR Idx IN Lx_Csr_Contracts(Lx_Contracts(Li_TableIdx).Rx_Chr_Id,Lx_SrvLine_Id,Lx_CovLvlLine_Id,Lx_BusiProc_Id,Lv_Cont_Pty_Id) LOOP

        --Lx_Idx_Rec     := Idx;
        Lx_Idx_Rec.Contract_Id                  := Idx.Contract_Id;
        Lx_Idx_Rec.Contract_Number              := Idx.Contract_Number;
        Lx_Idx_Rec.Contract_Number_Modifier     := Idx.Contract_Number_Modifier;
        Lx_Idx_Rec.Sts_Code                     := Idx.Sts_Code;
        Lx_Idx_Rec.Authoring_Org_Id             := Idx.Authoring_Org_Id;
        Lx_Idx_Rec.Inv_Organization_Id          := Idx.Inv_Organization_Id;
        Lx_Idx_Rec.HDR_End_Date                 := Idx.HDR_End_Date;
        Lx_Idx_Rec.Service_Line_Id              := Idx.Service_Line_Id;
        Lx_Idx_Rec.SV_Start_Date                := Idx.SV_Start_Date;
        Lx_Idx_Rec.SV_End_Date                  := Idx.SV_End_Date;
        Lx_Idx_Rec.SV_Date_Terminated           := Idx.SV_Date_Terminated;
        Lx_Idx_Rec.CL_Sts_Code                  := Idx.CL_Sts_Code;
        Lx_Idx_Rec.CovLvl_Line_Id               := Idx.CovLvl_Line_Id;
        Lx_Idx_Rec.CL_Start_Date                := Idx.CL_Start_Date;
        Lx_Idx_Rec.CL_End_Date                  := Idx.CL_End_Date;
        Lx_Idx_Rec.CL_Date_Terminated           := Idx.CL_Date_Terminated;
        Lx_Idx_Rec.Warranty_Flag                := Idx.Warranty_Flag;
        OKS_ENTITLEMENTS_PVT.Get_Cont02Format_Validation
            (P_Contracts            => Lx_Idx_Rec
            ,P_BusiProc_Id	        => Lx_BusiProc_Id
            ,P_Severity_Id	        => Lx_Severity_Id
            ,P_Request_TZone_Id	    => Lx_Request_TZone_Id
            ,P_Dates_In_Input_TZ    => 'Y'              -- Added for 12.0 ENT-TZ project (JVARGHES)
            ,P_Incident_Date        => Ld_Request_Date  -- Added for 12.0 ENT-TZ project (JVARGHES)
            ,P_Request_Date         => Ld_Request_Date
            ,P_Request_Date_Start   => Ld_Request_Date_Start
            ,P_Request_Date_End     => Ld_Request_Date_End
            ,P_Calc_RespTime_YN     => Lv_Calc_RespTime_YN
            ,P_Validate_Eff         => Lv_Validate_Eff
            ,P_Validate_Flag        => Lv_Validate_Flag
            ,P_SrvLine_Flag         => Lv_SrvLine_Flag
            ,P_Sort_Key             => Lv_Sort_Key
            ,X_Contracts_02         => Lx_Contracts_02_Val
            ,X_Result               => Lx_Result
            ,X_Return_Status   	    => Lx_Return_Status);
--            dbms_output.put_line('Status '||Lx_Return_Status);
            IF Lx_Contracts_02_Val.count >0 THEN --CK 12/21
         Li_OutTab_Idx := Li_OutTab_Idx + 1;

          Lx_Contracts_02(Li_OutTab_Idx).Contract_Id                 := Lx_Contracts_02_Val(1).Contract_Id;
--          dbms_output.put_line('Contract id '||Lx_Contracts_02_Val(1).Contract_Id);
          Lx_Contracts_02(Li_OutTab_Idx).Contract_Number             := Lx_Contracts_02_Val(1).Contract_Number;
          Lx_Contracts_02(Li_OutTab_Idx).Contract_Number_Modifier    := Lx_Contracts_02_Val(1).Contract_Number_Modifier;
     --   Lx_Contracts_02(Li_OutTab_Idx).Sts_code                    := Lx_Contracts_02_Val(1).Sts_code;
          Lx_Contracts_02(Li_OutTab_Idx).Sts_code                    := Lx_Contracts_02_Val(1).Sts_code;
          Lx_Contracts_02(Li_OutTab_Idx).Service_Line_Id             := Lx_Contracts_02_Val(1).Service_Line_Id;
          Lx_Contracts_02(Li_OutTab_Idx).Service_Name                := Lx_Contracts_02_Val(1).Service_Name;
          Lx_Contracts_02(Li_OutTab_Idx).Service_Description         := Lx_Contracts_02_Val(1).Service_Description;
     --   Lx_Contracts_02(Li_OutTab_Idx).Service_Start_Date          := Lx_Contracts_02_Val(1).Service_Start_Date;
     --   Lx_Contracts_02(Li_OutTab_Idx).Service_End_Date            := Lx_Contracts_02_Val(1).Service_End_Date;
          Lx_Contracts_02(Li_OutTab_Idx).Service_Start_Date          := Lx_Contracts_02_Val(1).Service_Start_Date;
          Lx_Contracts_02(Li_OutTab_Idx).Service_End_Date            := Lx_Contracts_02_Val(1).Service_End_Date;
          Lx_Contracts_02(Li_OutTab_Idx).Coverage_Term_Line_Id       := Lx_Contracts_02_Val(1).Coverage_Term_Line_Id;
          Lx_Contracts_02(Li_OutTab_Idx).Coverage_Term_Name          := Lx_Contracts_02_Val(1).Coverage_Term_Name;
          Lx_Contracts_02(Li_OutTab_Idx).Coverage_Term_Description   := Lx_Contracts_02_Val(1).Coverage_Term_Description;
          Lx_Contracts_02(Li_OutTab_Idx).Warranty_Flag               := Lx_Contracts_02_Val(1).Warranty_Flag;
          Lx_Contracts_02(Li_OutTab_Idx).Eligible_For_Entitlement    := Lx_Contracts_02_Val(1).Eligible_For_Entitlement;
          Lx_Contracts_02(Li_OutTab_Idx).date_terminated	         := Lx_Contracts_02_Val(1).date_terminated;
          Lx_Contracts_02(Li_OutTab_Idx).PM_Program_Id	             := Lx_Contracts_02_Val(1).PM_Program_Id;
          Lx_Contracts_02(Li_OutTab_Idx).PM_Schedule_Exists	         := Lx_Contracts_02_Val(1).PM_Schedule_Exists;
          Lx_Contracts_02(Li_OutTab_Idx).Exp_Reaction_Time           := Lx_Contracts_02_Val(1).Exp_Reaction_Time;
          Lx_Contracts_02(Li_OutTab_Idx).Exp_Resolution_Time         := Lx_Contracts_02_Val(1).Exp_Resolution_Time;
          Lx_Contracts_02(Li_OutTab_Idx).Status_Code                 := Lx_Contracts_02_Val(1).Status_Code;
          Lx_Contracts_02(Li_OutTab_Idx).Status_Text                 := Lx_Contracts_02_Val(1).Status_Text;
          Lx_Contracts_02(Li_OutTab_Idx).Coverage_Type_Code          := Lx_Contracts_02_Val(1).Coverage_Type_Code;
          Lx_Contracts_02(Li_OutTab_Idx).Coverage_Type_Meaning       := Lx_Contracts_02_Val(1).Coverage_Type_Meaning;
          Lx_Contracts_02(Li_OutTab_Idx).coverage_Type_Imp_Level     := Lx_Contracts_02_Val(1).coverage_Type_Imp_Level;
          Lx_Contracts_02(Li_OutTab_Idx).PM_Program_Id	             := Idx.PM_Program_Id;
                    --03/15/04 modified to return program schedule exists
          Lx_Contracts_02(Li_OutTab_Idx).PM_Schedule_Exists	             := Idx.PM_Schedule_Exists;

        Lx_Contracts_02_Val.DELETE;

        IF Lx_Return_Status = G_RET_STS_UNEXP_ERROR THEN
            RAISE L_EXCEP_UNEXPECTED_ERR;
        END IF;

--Add code for ph2 here
--   IF Lx_SrvLine_Id is not NULL THEN
--      FOR ActIdx IN Lx_Csr_Activities(Lx_SrvLine_Id) LOOP
   IF Lx_Contracts_02(Li_OutTab_Idx).Service_Line_Id is not NULL
   AND Lx_Contracts_02(Li_OutTab_Idx).PM_Program_Id is not NULL
   THEN

--   IF Lx_Contracts_02(Li_OutTab_Idx).Service_Line_Id is not NULL THEN
      FOR ActIdx IN Lx_Csr_Activities(Lx_Contracts_02(Li_OutTab_Idx).Service_Line_Id) LOOP
          Li_ActOutTab_Idx := Li_ActOutTab_Idx + 1;
--          dbms_output.put_line('Act id '||ActIdx.Activity_Id);
          Lx_Activities_02(Li_ActOutTab_Idx).service_line_id                 := ActIdx.SrvLine_Id;
          Lx_Activities_02(Li_ActOutTab_Idx).PM_program_id                   := ActIdx.Program_Id;
          Lx_Activities_02(Li_ActOutTab_Idx).Activity_id                     := ActIdx.Activity_Id;
          Lx_Activities_02(Li_ActOutTab_Idx).Act_Schedule_Exists             := ActIdx.schedule_exists;

	  -- Added by Jvorugan for Bug:5357010
	  IF nvl(Idx.PM_Schedule_Exists,'!') = 'Y'
	  THEN
	     Lx_Activities_02(Li_ActOutTab_Idx).Act_Schedule_Exists  := 'Y';
	  END IF;
	  -- End of changes by Jvorugan
      END LOOP;
   END IF;
END IF;   --CK12/21
      END LOOP;
/*--Add code for ph2 here
--   IF Lx_SrvLine_Id is not NULL THEN
--      FOR ActIdx IN Lx_Csr_Activities(Lx_SrvLine_Id) LOOP
   IF Lx_Contracts_02(Li_OutTab_Idx).Service_Line_Id is not NULL THEN
      FOR ActIdx IN Lx_Csr_Activities(Lx_Contracts_02(Li_OutTab_Idx).Service_Line_Id) LOOP
          Li_ActOutTab_Idx := Li_ActOutTab_Idx + 1;
          Lx_Activities_02(Li_ActOutTab_Idx).service_line_id                 := ActIdx.SrvLine_Id;
          Lx_Activities_02(Li_ActOutTab_Idx).PM_program_id                   := ActIdx.Program_Id;
          Lx_Activities_02(Li_ActOutTab_Idx).Activity_id                     := ActIdx.Activity_Id;
          Lx_Activities_02(Li_ActOutTab_Idx).Act_Schedule_Exists             := ActIdx.schedule_exists;
      END LOOP;
   END IF;   */
      Li_TableIdx := Lx_Contracts.NEXT(Li_TableIdx);
    END LOOP;
--    dbms_output.put_line('Count after loop'||Lx_Contracts_02.count);
--    IF Lv_Sort_Key <> G_NO_SORT_KEY THEN
--    above IF commented and new one introduced , as sorting needs to be done when calculate response time flag
--    is 'Y' or sort key is sorting with importance level.
    IF (((Lv_Calc_RespTime_YN = 'N') AND (Lv_Sort_Key = 'COVTYP_IMP')) OR (Lv_Calc_RespTime_YN = 'Y')) THEN

      OKS_ENTITLEMENTS_PVT.Sort_Asc_GetContracts_02
        (P_Input_Tab          => Lx_Contracts_02
        ,P_Sort_Key           => Lv_Sort_Key
        ,X_Output_Tab         => Lx_Contracts_02_Out
        ,X_Result             => Lx_Result
        ,X_Return_Status      => Lx_Return_Status);
--      IF Lx_Result <> G_TRUE THEN
      IF Lx_Return_Status <> G_TRUE THEN -- modified SP
        RAISE L_EXCEP_UNEXPECTED_ERR;
      END IF;

    ELSE

      Lx_Contracts_02_out := Lx_Contracts_02;

    END IF;

--    dbms_output.put_line('Count in proc'||Lx_Contracts_02_Out.count);
--        dbms_output.put_line('Act Count in proc'||Lx_Activities_02.count);
    X_Contracts_02        := Lx_Contracts_02_Out;
        X_Activities_02        := Lx_Activities_02;
    X_Result              := Lx_Result;
    X_Return_Status       := Lx_Return_Status;


  EXCEPTION

    WHEN L_EXCEP_UNEXPECTED_ERR THEN

      X_Result           := Lx_Result;
      X_Return_Status    := Lx_Return_Status;

    WHEN OTHERS THEN

      OKC_API.SET_MESSAGE
        (P_App_Name	  => G_APP_NAME_OKC
	,P_Msg_Name	  => G_UNEXPECTED_ERROR
	,P_Token1	  => G_SQLCODE_TOKEN
	,P_Token1_Value	  => SQLCODE
	,P_Token2	  => G_SQLERRM_TOKEN
	,P_Token2_Value   => SQLERRM);

      OKC_API.SET_MESSAGE
        (P_App_Name	  => G_APP_NAME_OKC
	,P_Msg_Name	  => G_DEBUG_TOKEN
	,P_Token1	  => G_PACKAGE_TOKEN
	,P_Token1_Value	  => G_PKG_NAME
	,P_Token2	  => G_PROGRAM_TOKEN
	,P_Token2_Value   => 'Get_PMContracts_02_Format');

      X_Result          := G_FALSE;
      X_Return_Status   := G_RET_STS_UNEXP_ERROR;

  END Get_PMContracts_02_Format;

--ph 2
 PROCEDURE Get_PMContracts_02
    (P_API_Version		IN  NUMBER
    ,P_Init_Msg_List		IN  VARCHAR2
    ,P_Inp_Rec			IN  OKS_ENTITLEMENTS_PVT.Inp_rec_getcont02
    ,X_Return_Status 		out nocopy VARCHAR2
    ,X_Msg_Count		out nocopy NUMBER
    ,X_Msg_Data			out nocopy VARCHAR2
    ,X_Ent_Contracts		out nocopy OKS_ENTITLEMENTS_PUB.Get_ConTop_Tbl
    ,X_PM_Activities        out nocopy OKS_PM_ENTITLEMENTS_PUB.get_activityop_tbl)
  IS

    CURSOR Lx_SrvLine(Cx_SrvLine_Id IN Gx_OKS_Id) IS
      SELECT Dnz_Chr_Id
        FROM Okc_K_lines_B
       WHERE Id = Cx_SrvLine_Id;

    Lx_Inp_Rec		CONSTANT    OKS_ENTITLEMENTS_PVT.Inp_rec_getcont02 := P_Inp_Rec;
    Lx_Return_Status            Gx_Ret_Sts DEFAULT G_RET_STS_SUCCESS;
    Lx_Result                   Gx_Boolean DEFAULT G_TRUE;

    Lx_Ent_Contracts            OKS_ENTITLEMENTS_PUB.Get_ConTop_Tbl;
--ph2
    Lx_PM_Activities           OKS_PM_ENTITLEMENTS_PUB.Get_Activityop_tbl;
    Lx_Contracts                OKS_ENTITLEMENTS_PVT.GT_Contract_Ref;
    Lx_Contracts_Temp           OKS_ENTITLEMENTS_PVT.GT_Contract_Ref;
    Lx_Contracts_out            OKS_ENTITLEMENTS_PVT.GT_Contract_Ref;
    Lv_SrvLine_Flag             VARCHAR2(1):= 'F';

    Ln_Organization_Id          NUMBER;
    Ln_Org_Id                   NUMBER;
    Ln_Chr_Id                   NUMBER;

    Li_TableIdx                 BINARY_INTEGER;

    L_EXCEP_UNEXPECTED_ERR      EXCEPTION;

  BEGIN

--  Bug# 4735542
--  Ln_Organization_Id                               := SYS_CONTEXT('OKC_CONTEXT','ORGANIZATION_ID');
--  Ln_Org_Id                                        := SYS_CONTEXT('OKC_CONTEXT','ORG_ID');

    OKS_ENTITLEMENTS_PVT.G_GRACE_PROFILE_SET         := fnd_profile.value('OKS_ENABLE_GRACE_PERIOD');

    IF Lx_Inp_Rec.Service_Line_Id IS NOT NULL THEN

      OPEN Lx_SrvLine(Lx_Inp_Rec.Service_Line_Id);
      FETCH Lx_SrvLine INTO Ln_Chr_Id;
      CLOSE Lx_SrvLine;

      Li_TableIdx                         := NVL(Lx_Contracts.LAST,0) + 1;
      Lx_Contracts(Li_TableIdx).Rx_Chr_Id := Ln_Chr_Id;
      Lx_Contracts(Li_TableIdx).Rx_Cle_Id := Lx_Inp_Rec.Service_Line_Id;

      Lv_SrvLine_Flag  := 'T';

    ELSIF Lx_Inp_Rec.Contract_Number IS NOT NULL THEN

      OKS_ENTITLEMENTS_PVT.Get_Contracts_Id
        (P_Contract_Num           => Lx_Inp_Rec.Contract_Number
        ,P_Contract_Num_Modifier  => Lx_Inp_Rec.Contract_Number_Modifier
        ,X_Contracts              => Lx_Contracts
        ,X_Result                 => Lx_Result
        ,X_Return_Status   	  => Lx_Return_Status);
--        dbms_output.put_line ('Contracts  from outer '||Lx_Contracts.count);
      IF Lx_Result <> G_TRUE THEN
        RAISE L_EXCEP_UNEXPECTED_ERR;
      END IF;

    ELSIF Lx_Inp_Rec.Product_Id IS NOT NULL THEN

      OKS_ENTITLEMENTS_PVT.Get_CovProd_Contracts
        (P_CovProd_Obj_Id         => Lx_Inp_Rec.Product_Id
        ,P_Organization_Id        => Ln_Organization_Id
        ,P_Org_Id                 => Ln_Org_Id
        ,X_CovProd_Contracts      => Lx_Contracts
        ,X_Result                 => Lx_Result
        ,X_Return_Status   	  => Lx_Return_Status);

--        dbms_output.put_line ('Contracts covprod from outer '||Lx_Contracts.count);
      IF Lx_Result <> G_TRUE THEN
        RAISE L_EXCEP_UNEXPECTED_ERR;
      END IF;

    ELSE

      IF Lx_Inp_Rec.Item_Id IS NOT NULL THEN

        OKS_ENTITLEMENTS_PVT.Get_CovItem_Contracts
          (P_CovItem_Obj_Id         => Lx_Inp_Rec.Item_Id
          ,P_Organization_Id        => Ln_Organization_Id
          ,P_Party_Id               => Lx_Inp_Rec.Party_Id
          ,X_CovItem_Contracts      => Lx_Contracts
          ,X_Result                 => Lx_Result
          ,X_Return_Status   	    => Lx_Return_Status);

        IF Lx_Result <> G_TRUE THEN
          RAISE L_EXCEP_UNEXPECTED_ERR;
        END IF;


      END IF;

      IF Lx_Inp_Rec.Party_Id IS NOT NULL THEN

        OKS_ENTITLEMENTS_PVT.Get_CovParty_Contracts
          (P_CovParty_Obj_Id        => Lx_Inp_Rec.Party_Id
          ,X_CovParty_Contracts     => Lx_Contracts_Temp
          ,X_Result                 => Lx_Result
          ,X_Return_Status   	    => Lx_Return_Status);

        IF Lx_Result <> G_TRUE THEN
          RAISE L_EXCEP_UNEXPECTED_ERR;
        END IF;

      END IF;

    END IF;

     OKS_ENTITLEMENTS_PVT.Append_Contract_PlSql_Table
        (P_Input_Tab          => Lx_Contracts_Temp
        ,P_Append_Tab         => Lx_Contracts
        ,X_Output_Tab         => Lx_Contracts_Out
        ,X_Result             => Lx_Result
        ,X_Return_Status      => Lx_Return_Status);

      IF Lx_Result <> G_TRUE THEN
        RAISE L_EXCEP_UNEXPECTED_ERR;
      END IF;
    Get_PMContracts_02_Format
      (P_Contracts          => Lx_Contracts_Out
      ,P_BusiProc_Id	    => Lx_Inp_Rec.Business_Process_Id
      ,P_Severity_Id	    => Lx_Inp_Rec.Severity_Id
      ,P_Request_TZone_Id   => Lx_Inp_Rec.Time_Zone_Id
      ,P_Request_Date       => Lx_Inp_Rec.Request_Date
      ,P_Request_Date_Start => Lx_Inp_Rec.Request_Date_start
      ,P_Request_Date_End   => Lx_Inp_Rec.Request_Date_end
      ,P_Calc_RespTime_YN   => Lx_Inp_Rec.Calc_RespTime_Flag
      ,P_Validate_Eff       => Lx_Inp_Rec.Validate_Eff_Flag
      ,P_Validate_Flag      => Lx_Inp_Rec.Validate_Flag
      ,P_SrvLine_Flag       => Lv_SrvLine_Flag
      ,P_Sort_Key           => Lx_Inp_Rec.Sort_Key
      ,X_Contracts_02       => Lx_Ent_Contracts
      ,X_Activities_02      => Lx_PM_Activities
      ,X_Result             => Lx_Result
      ,X_Return_Status      => Lx_Return_Status);

    X_Ent_Contracts       := Lx_Ent_Contracts;
    --ph2
    X_PM_Activities      := Lx_PM_Activities;
    X_Return_Status       := Lx_Return_Status;

  EXCEPTION

    WHEN L_EXCEP_UNEXPECTED_ERR THEN

      --X_Result         := Lx_Result;
      X_Return_Status    := Lx_Return_Status;

    WHEN OTHERS THEN

      OKC_API.SET_MESSAGE
        (P_App_Name	  => G_APP_NAME_OKC
	,P_Msg_Name	  => G_UNEXPECTED_ERROR
	,P_Token1	  => G_SQLCODE_TOKEN
	,P_Token1_Value	  => SQLCODE
	,P_Token2	  => G_SQLERRM_TOKEN
	,P_Token2_Value   => SQLERRM);

      OKC_API.SET_MESSAGE
        (P_App_Name	  => G_APP_NAME_OKC
	,P_Msg_Name	  => G_DEBUG_TOKEN
	,P_Token1	  => G_PACKAGE_TOKEN
	,P_Token1_Value	  => G_PKG_NAME
	,P_Token2	  => G_PROGRAM_TOKEN
	,P_Token2_Value   => 'Get_PMContracts_02');

      --X_Result        := G_FALSE;
      X_Return_Status   := G_RET_STS_UNEXP_ERROR;

  END Get_PMContracts_02;

    --Ph2
  PROCEDURE Get_PM_Contracts
    (p_api_version          IN  Number
    ,p_init_msg_list        IN  Varchar2
    ,p_inp_rec              IN  Get_pmcontin_rec
    ,x_return_status        out nocopy Varchar2
    ,x_msg_count            out nocopy Number
    ,x_msg_data             out nocopy Varchar2
    ,x_ent_contracts        out nocopy OKS_ENTITLEMENTS_PUB.get_contop_tbl
    ,x_pm_activities        out nocopy OKS_PM_ENTITLEMENTS_PUB.get_activityop_tbl)
  IS

    Lx_Inp_Rec                  Get_pmContIn_Rec := P_Inp_Rec;
    Lx_ContInp_Rec              OKS_ENTITLEMENTS_PVT.Inp_rec_getCont02;

  BEGIN

 -- Bug# 4735542
 -- okc_context.set_okc_org_context;

    Lx_ContInp_Rec.Contract_Number          :=  Lx_Inp_Rec.Contract_Number;
    Lx_ContInp_Rec.Contract_Number_Modifier :=  Lx_Inp_Rec.contract_number_modifier ;
    Lx_ContInp_Rec.Service_Line_Id          :=  Lx_Inp_Rec.Service_Line_Id;
    Lx_ContInp_Rec.Party_Id                 :=  Lx_Inp_Rec.Party_Id;
    Lx_ContInp_Rec.Site_Id                  :=  NULL;
    Lx_ContInp_Rec.Cust_Acct_Id             :=  NULL;
    Lx_ContInp_Rec.System_Id                :=  NULL;
    Lx_ContInp_Rec.Item_Id	                :=  Lx_Inp_Rec.Item_Id;
    Lx_ContInp_Rec.Product_Id	            :=  Lx_Inp_Rec.Product_Id;
    Lx_ContInp_Rec.Request_Date             :=  Lx_Inp_Rec.Request_Date;
    Lx_ContInp_Rec.Request_Date_Start       :=  Lx_Inp_Rec.Request_Date_Start;
    Lx_ContInp_Rec.Request_Date_End         :=  Lx_Inp_Rec.Request_Date_End;
    Lx_ContInp_Rec.Business_Process_Id	    :=  NULL;
    Lx_ContInp_Rec.Severity_Id	            :=  NULL;
    Lx_ContInp_Rec.Time_Zone_Id             :=  NULL;
    Lx_ContInp_Rec.Calc_RespTime_Flag	    :=  'N';
    Lx_ContInp_Rec.Validate_Flag	        :=  'Y';
    Lx_ContInp_Rec.Validate_Eff_Flag        :=  'T';
    Lx_ContInp_Rec.Sort_Key                 :=  NVL(Lx_Inp_Rec.Sort_Key,G_RESOLUTION_TIME);

    IF Lx_ContInp_Rec.Request_Date IS NULL THEN
      Lx_ContInp_Rec.Request_Date := SYSDATE;
    END IF;

    Get_PMContracts_02
      (P_API_Version		=> P_Api_Version
      ,P_Init_Msg_List		=> P_Init_Msg_List
      ,P_Inp_Rec		    => Lx_ContInp_Rec
      ,X_Return_Status 		=> X_Return_Status
      ,X_Msg_Count		    => X_Msg_Count
      ,X_Msg_Data		    => X_Msg_Data
      ,X_Ent_Contracts		=> X_Ent_Contracts
      ,X_PM_activities      => X_PM_Activities);


  EXCEPTION

    WHEN OTHERS THEN

      OKC_API.SET_MESSAGE
        (P_App_Name	  => G_APP_NAME_OKC
	,P_Msg_Name	  => G_UNEXPECTED_ERROR
	,P_Token1	  => G_SQLCODE_TOKEN
	,P_Token1_Value	  => SQLCODE
	,P_Token2	  => G_SQLERRM_TOKEN
	,P_Token2_Value   => SQLERRM);

      OKC_API.SET_MESSAGE
        (P_App_Name	  => G_APP_NAME_OKC
	,P_Msg_Name	  => G_DEBUG_TOKEN
	,P_Token1	  => G_PACKAGE_TOKEN
	,P_Token1_Value	  => G_PKG_NAME
	,P_Token2	  => G_PROGRAM_TOKEN
	,P_Token2_Value   => 'Get_PM_Contracts');

      --X_Result        := G_FALSE;
      X_Return_Status   := G_RET_STS_UNEXP_ERROR;

  END Get_PM_Contracts;


/* old  PROCEDURE Get_PM_Schedule
    (p_api_version          IN  Number
    ,p_init_msg_list        IN  Varchar2
    ,p_sch_rec              IN  inp_sch_rec
    ,x_return_status        out nocopy Varchar2
    ,x_msg_count            out nocopy Number
    ,x_msg_data             out nocopy Varchar2
    ,x_pm_schedule          out nocopy pm_sch_tbl_type)*/
--ph2
  PROCEDURE Get_PM_Schedule
    (p_api_version          IN  Number
    ,p_init_msg_list        IN  Varchar2
    ,p_sch_rec              IN  inp_sch_rec
    ,x_return_status        out nocopy Varchar2
    ,x_msg_count            out nocopy Number
    ,x_msg_data             out nocopy Varchar2
    ,x_pm_schedule          out nocopy pm_sch_tbl_type)
    IS
--ph2

--
-- Modified for 12.0 Coverage Rearch project (JVARGHES)
--
/*
CURSOR Lx_PM_Sch(Cx_SrvLine_Id IN Gx_OKS_Id, Cx_Program_Id IN NUMBER) IS -- To fetch schedule only for the program
    SELECT   cov.cle_Id SrvLine_Id,
             okscov.pm_program_id program_id, -- pmp.object1_id1 program_id,
             null ACTIVITY_ID,
             sch.SCHEDULE_DATE,
             sch.SCHEDULE_DATE_FROM,
             sch.SCHEDULE_DATE_TO,
             cov.end_date cov_end_date
      FROM   Okc_K_lines_B cov,
             Oks_PM_Schedules sch,
-- rule rearchitecure changes
--             okc_rule_groups_b rgp,
--             OKC_rules_b pmp
             oks_k_lines_b okscov
-- rule rearchitecture changes
      WHERE  cov.cle_Id      =Cx_SrvLine_Id      --nvl(Cx_SrvLine_Id,cov.cle_Id)
      AND    cov.lse_id      in (2,15,20)
      AND    cov.dnz_chr_id  = sch.dnz_chr_id
      AND    cov.id          = sch.cle_id
-- rule rearchitecture changes
      and    sch.activity_line_id is null
      and    cov.id          = okscov.cle_id
      and    okscov.pm_program_id = nvl(Cx_Program_Id,okscov.pm_program_id)
      --03/15 chkrishn added to sort schedules returned
      order by nvl(schedule_date,schedule_date_from);
--      AND    cov.dnz_chr_id = rgp.dnz_chr_id
--      AND    cov.id         = rgp.cle_id
--      AND    rgp.id = pmp.rgp_id
--      AND    pmp.object1_id1 = nvl(Cx_Program_Id,object1_id1)
--      AND    pmp.object1_id2 = '#'
--      AND    pmp.jtot_object1_code = 'OKX_PMPROG'
--      AND    pmp.rule_information_category='PMP'
--      AND    sch.pma_rule_id is null ;
-- rule rearchitecture changes
*/

--
-- Modified for 12.0 Coverage Rearch project (JVARGHES)
--

CURSOR Lx_PM_Sch(Cx_SrvLine_Id IN Gx_OKS_Id, Cx_Program_Id IN NUMBER) IS
    SELECT   srv.Id SrvLine_Id,
             okssrv.pm_program_id program_id,
             null ACTIVITY_ID,
             sch.SCHEDULE_DATE,
             sch.SCHEDULE_DATE_FROM,
             sch.SCHEDULE_DATE_TO,
             decode(okssrv.STANDARD_COV_YN,'Y',srv.end_date,cov.end_date) cov_end_date
      FROM   Okc_K_lines_B srv,
             Oks_PM_Schedules sch,
             oks_k_lines_b okssrv,
             okc_k_lines_b cov
      WHERE  srv.Id      = Cx_SrvLine_Id
      AND    srv.lse_id      in (1,14,19)
      AND    srv.dnz_chr_id  = sch.dnz_chr_id
      AND    srv.id          = sch.cle_id
      and    sch.activity_line_id is null
      and    srv.id          = okssrv.cle_id
      and    okssrv.pm_program_id = nvl(Cx_Program_Id,okssrv.pm_program_id)
      and    cov.id = okssrv.coverage_id
      and    cov.lse_id in (2,15,20)
      order by nvl(sch.schedule_date,sch.schedule_date_from);

--
--

--
-- Modified for 12.0 Coverage Rearch project (JVARGHES)
--
/*
CURSOR Lx_Activity_Sch(Cx_SrvLine_Id IN Gx_OKS_Id,Cx_Program_Id IN NUMBER, Cx_Activity_Id IN NUMBER) IS -- To fetch schedule only for activity
SELECT       cov.cle_Id SrvLine_Id,
             okscov.pm_program_id program_id,--pma.object3_id1 program_id,
             pmact.activity_id activity_id, --pma.object1_id1 activity_id,
             sch.SCHEDULE_DATE,
             sch.SCHEDULE_DATE_FROM,
             sch.SCHEDULE_DATE_TO,
             cov.end_date cov_end_date
      FROM   Okc_K_lines_B cov,
             Oks_PM_Schedules sch,
-- rule rearchitecure changes
--             okc_rule_groups_b rgp,
--             OKC_rules_b pma
             oks_k_lines_b okscov,
             oks_pm_activities pmact
-- rule  rearchitecture changes
      WHERE  cov.cle_Id      =Cx_SrvLine_Id      --nvl(Cx_SrvLine_Id,cov.cle_Id)
      AND    cov.lse_id      in (2,15,20)
      AND    cov.dnz_chr_id  = sch.dnz_chr_id
      AND    cov.id          = sch.cle_id
-- rule rearchitecure changes
      and    okscov.cle_id   = cov.id
      and    pmact.cle_id    = cov.id
      and    pmact.select_yn = 'Y'
      and    sch.activity_line_id = pmact.id
      and    okscov.pm_program_id = nvl(Cx_Program_Id,okscov.pm_program_id)
      and    pmact.activity_id = nvl(Cx_Activity_Id,pmact.activity_id)
      --03/15 chkrishn added to sort schedules returned
      order by nvl(schedule_date,schedule_date_from);
--      AND    cov.dnz_chr_id = rgp.dnz_chr_id
--      AND    cov.id         = rgp.cle_id
--      AND    rgp.id = pma.rgp_id
--      AND    pma.rule_information_category='PMA'
--      AND    pma.rule_information1 = 'Y'
--      AND    pma.id= sch.pma_rule_id
--      AND    pma.object1_id1= Cx_Activity_Id
--      AND    pma.object3_id1= nvl(Cx_Program_Id,pma.object3_id1)
--      AND    pma.id= sch.pma_rule_id;
-- rule rearchitecure changes
*/
--
-- Modified for 12.0 Coverage Rearch project (JVARGHES)
--

CURSOR Lx_Activity_Sch(Cx_SrvLine_Id IN Gx_OKS_Id,Cx_Program_Id IN NUMBER, Cx_Activity_Id IN NUMBER) IS -- To fetch schedule only for activity
SELECT       srv.Id SrvLine_Id,
             okssrv.pm_program_id program_id,
             pmact.activity_id activity_id,
             sch.SCHEDULE_DATE,
             sch.SCHEDULE_DATE_FROM,
             sch.SCHEDULE_DATE_TO,
             decode(okssrv.STANDARD_COV_YN,'Y',srv.end_date,cov.end_date) cov_end_date
      FROM   Okc_K_lines_B srv,
             Okc_K_lines_B cov,
             Oks_PM_Schedules sch,
             oks_k_lines_b okssrv,
             oks_pm_activities pmact
      WHERE  srv.Id      = Cx_SrvLine_Id
      AND    srv.lse_id      in (1,14,19)
      and    okssrv.cle_id   = srv.id
      and    cov.id          = okssrv.coverage_id
      AND    cov.lse_id      in (2,15,20)
      AND    srv.dnz_chr_id  = sch.dnz_chr_id
      AND    srv.id          = sch.cle_id
      and    pmact.cle_id    = srv.id
      and    pmact.select_yn = 'Y'
      and    sch.activity_line_id = pmact.id
      and    okssrv.pm_program_id = nvl(Cx_Program_Id,okssrv.pm_program_id)
      and    pmact.activity_id = nvl(Cx_Activity_Id,pmact.activity_id)
      order by nvl(sch.schedule_date,sch.schedule_date_from);

--
--
--
-- Modified for 12.0 Coverage Rearch project (JVARGHES)
--

/*

CURSOR Lx_PM_act_Sch(Cx_SrvLine_Id IN Gx_OKS_Id, Cx_Program_Id IN NUMBER) IS -- To fetch schedules for all activities of a program
SELECT       cov.cle_Id SrvLine_Id,
             okscov.pm_program_id program_id, --pma.object3_id1 program_id,
             pmact.activity_id  activity_id, --    pma.object1_id1 activity_id,
             sch.SCHEDULE_DATE,
             sch.SCHEDULE_DATE_FROM,
             sch.SCHEDULE_DATE_TO,
             cov.end_date cov_end_date
      FROM   Okc_K_lines_B cov,
             Oks_PM_Schedules sch,
-- rule rearchitecture changes
--             okc_rule_groups_b rgp,
--             OKC_rules_b pma
             oks_k_lines_b okscov,
             oks_pm_activities pmact
-- rule rearchitecture changes
      WHERE  cov.cle_Id      =Cx_SrvLine_Id      --nvl(Cx_SrvLine_Id,cov.cle_Id)
      AND    cov.lse_id      in (2,15,20)
      AND    cov.dnz_chr_id  = sch.dnz_chr_id
      AND    cov.id          = sch.cle_id
-- rule rearchitecture changes
      and    okscov.cle_id   = cov.id
      and    okscov.pm_program_id = Cx_Program_Id
      and    pmact.cle_id    = cov.id
      and    pmact.select_yn = 'Y'
      and    pmact.id        = sch.activity_line_id
            --03/15 chkrishn added to sort schedules returned
      order by nvl(schedule_date,schedule_date_from);
--      AND    cov.dnz_chr_id = rgp.dnz_chr_id
--      AND    cov.id         = rgp.cle_id
--      AND    rgp.id = pma.rgp_id
--      AND    pma.rule_information_category='PMA'
--      AND    pma.rule_information1 = 'Y'
--      AND    pma.id= sch.pma_rule_id
--      AND    pma.object3_id1= Cx_Program_Id
--      AND    pma.id= sch.pma_rule_id;
-- rule rearchitecture changes
*/
--
-- Modified for 12.0 Coverage Rearch project (JVARGHES)
--
CURSOR Lx_PM_act_Sch(Cx_SrvLine_Id IN Gx_OKS_Id, Cx_Program_Id IN NUMBER) IS -- To fetch schedules for all activities of a program
SELECT       srv.Id SrvLine_Id,
             okssrv.pm_program_id program_id,
             pmact.activity_id  activity_id,
             sch.SCHEDULE_DATE,
             sch.SCHEDULE_DATE_FROM,
             sch.SCHEDULE_DATE_TO,
             decode(okssrv.STANDARD_COV_YN,'Y',srv.end_date,cov.end_date) cov_end_date
      FROM   Okc_K_lines_B srv,
             Okc_K_lines_B cov,
             Oks_PM_Schedules sch,
             oks_k_lines_b okssrv,
             oks_pm_activities pmact
      WHERE  srv.Id      = Cx_SrvLine_Id
      AND    srv.lse_id      in (1,14,19)
      and    srv.id          = okssrv.cle_id
      and    cov.id          = okssrv.coverage_id
      AND    cov.lse_id      in (2,15,20)
      AND    srv.dnz_chr_id  = sch.dnz_chr_id
      AND    srv.id          = sch.cle_id
      and    okssrv.pm_program_id = Cx_Program_Id
      and    pmact.cle_id    = srv.id
      and    pmact.select_yn = 'Y'
      and    pmact.id        = sch.activity_line_id
      order by nvl(sch.schedule_date,sch.schedule_date_from);
--
--
-- Added by Jvorugan for Bug:5357010
 cursor check_act_sch_exist(Cx_SrvLine_Id IN Gx_OKS_Id,Cx_Activity_Id IN NUMBER)
 is
   select pmact.sch_exists_yn
   from   Okc_K_lines_B srv,
          oks_pm_activities pmact
   where  srv.id = Cx_SrvLine_Id
   and    srv.lse_id in (1,14,19)
   and    pmact.cle_id    = srv.id
   and    pmact.select_yn = 'Y'
   and    pmact.activity_id = Cx_Activity_Id;

 l_act_sch_exist           varchar2(1);
-- End of changes by Jvorugan

    Lx_Sch_rec                     CONSTANT inp_sch_rec := p_sch_rec;
    Li_OutTab_Idx                  BINARY_INTEGER := 0;
    Lx_PM_Schedule                 pm_sch_tbl_type;
    Lx_Return_Status               Gx_Ret_Sts DEFAULT G_RET_STS_SUCCESS;
    Lx_Sch_Stdt                    DATE := nvl(Lx_Sch_rec.schedule_start_date,
                                                trunc(to_date('1901/01/01','YYYY/MM/DD')));
    Lx_Sch_Endt                    DATE := nvl(Lx_Sch_rec.schedule_end_date,
                                                trunc(to_date('2099/12/31','YYYY/MM/DD')));

  BEGIN
  --ph2
  IF Lx_Sch_rec.program_id is  null  AND Lx_Sch_rec.activity_id is null THEN
-- Validate that the contract_line_id and program_id are associated
   FOR Sch_Rec IN  Lx_PM_Sch(Lx_Sch_rec.service_line_id,Lx_Sch_rec.activity_id) LOOP

     IF  (trunc(Sch_Rec.SCHEDULE_DATE) <= trunc(Sch_Rec.cov_end_date) OR
           trunc(Sch_Rec.SCHEDULE_DATE_FROM) <= trunc(Sch_Rec.cov_end_date)) THEN

           IF ((trunc(Sch_Rec.SCHEDULE_DATE) >= trunc(Lx_Sch_Stdt) AND
               trunc(Sch_Rec.SCHEDULE_DATE) <= trunc(Lx_Sch_Endt)))
                OR
               ((trunc(Sch_Rec.SCHEDULE_DATE_FROM) >= trunc(Lx_Sch_Stdt) AND
               trunc(Sch_Rec.SCHEDULE_DATE_FROM) <= trunc(Lx_Sch_Endt))) THEN

                Li_OutTab_Idx := Li_OutTab_Idx + 1;

                Lx_PM_Schedule(Li_OutTab_Idx).service_line_id     := Sch_Rec.SrvLine_Id;
                --ph2
                Lx_PM_Schedule(Li_OutTab_Idx).Program_id          := Sch_Rec.Program_Id;
                Lx_PM_Schedule(Li_OutTab_Idx).Activity_id         := Sch_Rec.Activity_Id;
                Lx_PM_Schedule(Li_OutTab_Idx).schedule_on         := Sch_Rec.SCHEDULE_DATE;
                Lx_PM_Schedule(Li_OutTab_Idx).schedule_from       := Sch_Rec.SCHEDULE_DATE_FROM;
                IF Sch_Rec.SCHEDULE_DATE_TO is not null THEN
                  IF trunc(Sch_Rec.SCHEDULE_DATE_TO) <= trunc(Sch_Rec.cov_end_date) THEN
                    Lx_PM_Schedule(Li_OutTab_Idx).schedule_to    := Sch_Rec.SCHEDULE_DATE_TO;
                  ELSE
                    Lx_PM_Schedule(Li_OutTab_Idx).schedule_to    := Sch_Rec.cov_end_date;
                  END IF;
                END IF;
            END IF;

     END IF;
    END LOOP;
ELSIF   Lx_Sch_rec.activity_id is not null THEN
      -- Added by Jvorugan for Bug:5357010
        -- If no schedules are defined for an activity, then
        -- derive the activity schedule from  the program
  open check_act_sch_exist(Lx_Sch_rec.service_line_id,Lx_Sch_rec.activity_id);
  fetch check_act_sch_exist into l_act_sch_exist;
  close check_act_sch_exist;
  IF nvl(l_act_sch_exist,'Y') = 'Y'
  THEN

    FOR ActSch_Rec IN  Lx_Activity_Sch(Lx_Sch_rec.service_line_id,Lx_Sch_rec.program_id,Lx_Sch_rec.activity_id) LOOP

     IF  (trunc(ActSch_Rec.SCHEDULE_DATE) <= trunc(ActSch_Rec.cov_end_date) OR
           trunc(ActSch_Rec.SCHEDULE_DATE_FROM) <= trunc(ActSch_Rec.cov_end_date)) THEN

           IF ((trunc(ActSch_Rec.SCHEDULE_DATE) >= trunc(Lx_Sch_Stdt) AND
               trunc(ActSch_Rec.SCHEDULE_DATE) <= trunc(Lx_Sch_Endt)))
                OR
               ((trunc(ActSch_Rec.SCHEDULE_DATE_FROM) >= trunc(Lx_Sch_Stdt) AND
               trunc(ActSch_Rec.SCHEDULE_DATE_FROM) <= trunc(Lx_Sch_Endt))) THEN

                Li_OutTab_Idx := Li_OutTab_Idx + 1;

                Lx_PM_Schedule(Li_OutTab_Idx).service_line_id     := ActSch_Rec.SrvLine_Id;
                --ph2
                Lx_PM_Schedule(Li_OutTab_Idx).Program_id          := ActSch_Rec.Program_Id;
                Lx_PM_Schedule(Li_OutTab_Idx).Activity_id         := ActSch_Rec.Activity_Id;
                Lx_PM_Schedule(Li_OutTab_Idx).schedule_on         := ActSch_Rec.SCHEDULE_DATE;
                Lx_PM_Schedule(Li_OutTab_Idx).schedule_from       := ActSch_Rec.SCHEDULE_DATE_FROM;

                IF ActSch_Rec.SCHEDULE_DATE_TO is not null THEN
                  IF trunc(ActSch_Rec.SCHEDULE_DATE_TO) <= trunc(ActSch_Rec.cov_end_date) THEN
                    Lx_PM_Schedule(Li_OutTab_Idx).schedule_to    := ActSch_Rec.SCHEDULE_DATE_TO;
                  ELSE
                    Lx_PM_Schedule(Li_OutTab_Idx).schedule_to    := ActSch_Rec.cov_end_date;
                  END IF;
                END IF;
            END IF;
            END IF;
        END LOOP;
   ELSE  -- no schedules are defined for activity.
     FOR Sch_Rec IN  Lx_PM_Sch(Lx_Sch_rec.service_line_id,Lx_Sch_rec.program_id) LOOP

         IF  (trunc(Sch_Rec.SCHEDULE_DATE) <= trunc(Sch_Rec.cov_end_date) OR
           trunc(Sch_Rec.SCHEDULE_DATE_FROM) <= trunc(Sch_Rec.cov_end_date)) THEN

           IF ((trunc(Sch_Rec.SCHEDULE_DATE) >= trunc(Lx_Sch_Stdt) AND
               trunc(Sch_Rec.SCHEDULE_DATE) <= trunc(Lx_Sch_Endt)))
                OR
               ((trunc(Sch_Rec.SCHEDULE_DATE_FROM) >= trunc(Lx_Sch_Stdt) AND
               trunc(Sch_Rec.SCHEDULE_DATE_FROM) <= trunc(Lx_Sch_Endt))) THEN

                Li_OutTab_Idx := Li_OutTab_Idx + 1;

                Lx_PM_Schedule(Li_OutTab_Idx).service_line_id     := Sch_Rec.SrvLine_Id;
                --ph2
                Lx_PM_Schedule(Li_OutTab_Idx).Program_id          := Sch_Rec.Program_Id;
                Lx_PM_Schedule(Li_OutTab_Idx).Activity_id         := Lx_Sch_rec.activity_id;
                Lx_PM_Schedule(Li_OutTab_Idx).schedule_on         := Sch_Rec.SCHEDULE_DATE;
                Lx_PM_Schedule(Li_OutTab_Idx).schedule_from       := Sch_Rec.SCHEDULE_DATE_FROM;

                IF Sch_Rec.SCHEDULE_DATE_TO is not null THEN
                  IF trunc(Sch_Rec.SCHEDULE_DATE_TO) <= trunc(Sch_Rec.cov_end_date) THEN
                    Lx_PM_Schedule(Li_OutTab_Idx).schedule_to    := Sch_Rec.SCHEDULE_DATE_TO;
                  ELSE
                    Lx_PM_Schedule(Li_OutTab_Idx).schedule_to    := Sch_Rec.cov_end_date;
                  END IF;
                END IF;

            END IF;
         END IF;
     END LOOP;

   END IF;  -- End of check for act_sch_exist

    ELSIF Lx_Sch_rec.program_id is  not null  AND Lx_Sch_rec.activity_id is null THEN
    FOR Sch_Rec IN  Lx_PM_Sch(Lx_Sch_rec.service_line_id,Lx_Sch_rec.program_id) LOOP

     IF  (trunc(Sch_Rec.SCHEDULE_DATE) <= trunc(Sch_Rec.cov_end_date) OR
           trunc(Sch_Rec.SCHEDULE_DATE_FROM) <= trunc(Sch_Rec.cov_end_date)) THEN

           IF ((trunc(Sch_Rec.SCHEDULE_DATE) >= trunc(Lx_Sch_Stdt) AND
               trunc(Sch_Rec.SCHEDULE_DATE) <= trunc(Lx_Sch_Endt)))
                OR
               ((trunc(Sch_Rec.SCHEDULE_DATE_FROM) >= trunc(Lx_Sch_Stdt) AND
               trunc(Sch_Rec.SCHEDULE_DATE_FROM) <= trunc(Lx_Sch_Endt))) THEN

                Li_OutTab_Idx := Li_OutTab_Idx + 1;

                Lx_PM_Schedule(Li_OutTab_Idx).service_line_id     := Sch_Rec.SrvLine_Id;
                --ph2
                Lx_PM_Schedule(Li_OutTab_Idx).Program_id          := Sch_Rec.Program_Id;
                Lx_PM_Schedule(Li_OutTab_Idx).Activity_id         := Sch_Rec.Activity_Id;
                Lx_PM_Schedule(Li_OutTab_Idx).schedule_on         := Sch_Rec.SCHEDULE_DATE;
                Lx_PM_Schedule(Li_OutTab_Idx).schedule_from       := Sch_Rec.SCHEDULE_DATE_FROM;

                IF Sch_Rec.SCHEDULE_DATE_TO is not null THEN
                  IF trunc(Sch_Rec.SCHEDULE_DATE_TO) <= trunc(Sch_Rec.cov_end_date) THEN
                    Lx_PM_Schedule(Li_OutTab_Idx).schedule_to    := Sch_Rec.SCHEDULE_DATE_TO;
                  ELSE
                    Lx_PM_Schedule(Li_OutTab_Idx).schedule_to    := Sch_Rec.cov_end_date;
                  END IF;
                END IF;

            END IF;

     END IF;
    END LOOP;
    FOR PActSch_Rec IN  Lx_PM_Act_Sch(Lx_Sch_rec.service_line_id,Lx_Sch_rec.program_id) LOOP

     IF  (trunc(PActSch_Rec.SCHEDULE_DATE) <= trunc(PActSch_Rec.cov_end_date) OR
           trunc(PActSch_Rec.SCHEDULE_DATE_FROM) <= trunc(PActSch_Rec.cov_end_date)) THEN

           IF ((trunc(PActSch_Rec.SCHEDULE_DATE) >= trunc(Lx_Sch_Stdt) AND
               trunc(PActSch_Rec.SCHEDULE_DATE) <= trunc(Lx_Sch_Endt)))
                OR
               ((trunc(PActSch_Rec.SCHEDULE_DATE_FROM) >= trunc(Lx_Sch_Stdt) AND
               trunc(PActSch_Rec.SCHEDULE_DATE_FROM) <= trunc(Lx_Sch_Endt))) THEN

                Li_OutTab_Idx := Li_OutTab_Idx + 1;

                Lx_PM_Schedule(Li_OutTab_Idx).service_line_id     := PActSch_Rec.SrvLine_Id;
                --ph2
                Lx_PM_Schedule(Li_OutTab_Idx).Program_id          := PActSch_Rec.Program_Id;
                Lx_PM_Schedule(Li_OutTab_Idx).Activity_id         := PActSch_Rec.Activity_Id;
                Lx_PM_Schedule(Li_OutTab_Idx).schedule_on         := PActSch_Rec.SCHEDULE_DATE;
                Lx_PM_Schedule(Li_OutTab_Idx).schedule_from       := PActSch_Rec.SCHEDULE_DATE_FROM;

                IF PActSch_Rec.SCHEDULE_DATE_TO is not null THEN
                  IF trunc(PActSch_Rec.SCHEDULE_DATE_TO) <= trunc(PActSch_Rec.cov_end_date) THEN
                    Lx_PM_Schedule(Li_OutTab_Idx).schedule_to    := PActSch_Rec.SCHEDULE_DATE_TO;
                  ELSE
                    Lx_PM_Schedule(Li_OutTab_Idx).schedule_to    := PActSch_Rec.cov_end_date;
                  END IF;
                END IF;
            END IF;
            END IF;
        END LOOP;

     END IF;
    x_pm_schedule         := Lx_PM_Schedule;
   X_Return_Status       := Lx_Return_Status;


--   END LOOP;

  EXCEPTION

    WHEN OTHERS THEN

      OKC_API.SET_MESSAGE
        (P_App_Name	  => G_APP_NAME_OKC
	,P_Msg_Name	  => G_UNEXPECTED_ERROR
	,P_Token1	  => G_SQLCODE_TOKEN
	,P_Token1_Value	  => SQLCODE
	,P_Token2	  => G_SQLERRM_TOKEN
	,P_Token2_Value   => SQLERRM);

      OKC_API.SET_MESSAGE
        (P_App_Name	  => G_APP_NAME_OKC
	,P_Msg_Name	  => G_DEBUG_TOKEN
	,P_Token1	  => G_PACKAGE_TOKEN
	,P_Token1_Value	  => G_PKG_NAME
	,P_Token2	  => G_PROGRAM_TOKEN
	,P_Token2_Value   => 'Get_PM_Schedule');

      --X_Result        := G_FALSE;
      X_Return_Status   := G_RET_STS_UNEXP_ERROR;

  END Get_PM_Schedule;


  PROCEDURE Get_PM_Confirmation
    (p_api_version          IN  Number
    ,p_init_msg_list        IN  Varchar2
    ,p_service_line_id      IN  Number
    ,p_program_id           IN  Number
    ,p_Activity_Id          IN  Number
    ,x_return_status        out nocopy Varchar2
    ,x_msg_count            out nocopy Number
    ,x_msg_data             out nocopy Varchar2
    ,x_pm_conf_reqd         out nocopy Varchar2)
  IS

--
-- Modified for 12.0 Coverage Rearch project (JVARGHES)
--
/*
      CURSOR Lx_PM_ConfReq(Cx_SrvLine_Id IN Gx_OKS_Id,CX_Program_Id IN NUMBER) IS
      SELECT pm_conf_req_yn PM_ConfReq --Rule_Information1 PM_ConfReq
      FROM   Okc_K_lines_B cle1,
             Okc_K_lines_B cle2,
-- rule rearchitecture changes
--             Okc_Rule_Groups_B rgp,
--             Okc_Rules_B rul
             oks_k_lines_b okscov
-- rule rearchitecture changes
      WHERE  cle1.Id         = Cx_SrvLine_Id
      AND    cle2.cle_Id     = cle1.Id
      AND    cle2.lse_id     in (2,15,20)
-- rule rearchitecture changes
      and    okscov.cle_id   = cle2.id
      AND    okscov.pm_program_id = nvl(CX_Program_Id,okscov.pm_program_id);
--      AND    cle2.dnz_chr_id = rgp.dnz_chr_id
--      AND    cle2.id         = rgp.cle_id
--      AND    rul.rgp_id      = rgp.id
--      AND    rul.object1_id1= nvl(CX_Program_Id,rul.object1_id1)
--      AND    rul.rule_information_category = 'PMP';
-- rule rearchitecture changes
*/
--
-- Modified for 12.0 Coverage Rearch project (JVARGHES)
--

      CURSOR Lx_PM_ConfReq(Cx_SrvLine_Id IN Gx_OKS_Id,CX_Program_Id IN NUMBER) IS
      SELECT pm_conf_req_yn PM_ConfReq --Rule_Information1 PM_ConfReq
      FROM   Okc_K_lines_B cle1,
             oks_k_lines_b okssrv
      WHERE  cle1.Id         = Cx_SrvLine_Id
      and    okssrv.cle_id   = cle1.id
      AND    okssrv.pm_program_id = nvl(CX_Program_Id,okssrv.pm_program_id);

--
--
--
-- Modified for 12.0 Coverage Rearch project (JVARGHES)
--
/*
      CURSOR Lx_Act_ConfReq(Cx_SrvLine_Id IN Gx_OKS_Id,CX_Program_Id IN NUMBER,CX_Activity_Id IN NUMBER) IS
      SELECT pmact.Conf_req_yn Act_ConfReq -- PMA.Rule_Information2 Act_ConfReq
      FROM   Okc_K_lines_B cle1,
             Okc_K_lines_B cle2,
-- rule rearchitecture changes
             oks_k_lines_b okscov,
             oks_pm_activities pmact
--             Okc_Rule_Groups_B rgp,
--             Okc_Rules_B pma
-- rule rearchitecture changes
      WHERE  cle1.Id         = Cx_SrvLine_Id
      AND    cle1.dnz_chr_id = cle2.dnz_chr_id
      AND    cle2.cle_Id     = cle1.Id
      AND    cle2.lse_id     in (2,15,20)
-- rule rearchitecture changes
      and    okscov.cle_id   = cle2.id
      and    okscov.pm_program_id = nvl(CX_Program_Id,okscov.pm_program_id)
      and    pmact.cle_id    = cle2.id
      and    pmact.select_yn = 'Y'
      and    pmact.activity_id = CX_Activity_Id;
--      AND    cle2.dnz_chr_id = rgp.dnz_chr_id
--      AND    cle2.id         = rgp.cle_id
--      AND    rgp.id = pma.rgp_id
--      AND    pma.object3_id1 = nvl(CX_Program_Id,pma.object3_id1)
--      and    pma.object1_id1 = CX_Activity_Id
--      AND    pma.rule_information_category = 'PMA';
-- rule rearchitecture changes
*/
--
-- Modified for 12.0 Coverage Rearch project (JVARGHES)
--
    CURSOR Lx_Act_ConfReq(Cx_SrvLine_Id IN Gx_OKS_Id,CX_Program_Id IN NUMBER,CX_Activity_Id IN NUMBER) IS
      SELECT pmact.Conf_req_yn Act_ConfReq -- PMA.Rule_Information2 Act_ConfReq
      FROM   Okc_K_lines_B cle1,
             oks_k_lines_b okssrv,
             oks_pm_activities pmact
      WHERE  cle1.Id         = Cx_SrvLine_Id
      and    okssrv.cle_id   = cle1.id
      and    okssrv.pm_program_id = nvl(CX_Program_Id,okssrv.pm_program_id)
      and    pmact.cle_id    = cle1.id
      and    pmact.select_yn = 'Y'
      and    pmact.activity_id = CX_Activity_Id;

--
-- Modified for 12.0 Coverage Rearch project (JVARGHES)
--

    Lx_SrvLine_Id                  NUMBER := p_service_line_id;
    --Added for ph2
    Lx_Program_Id                  NUMBER := p_program_id  ;
    Lx_Activity_Id                  NUMBER := p_activity_id  ;

    Lx_Return_Status               Gx_Ret_Sts DEFAULT G_RET_STS_SUCCESS;


  BEGIN

    x_pm_conf_reqd := 'N';

    IF Lx_Activity_Id is null THEN --Change for ph2

        FOR PM_ConfReq_rec IN  Lx_PM_ConfReq(Lx_SrvLine_Id,Lx_Program_Id) LOOP

             x_pm_conf_reqd    := PM_ConfReq_rec.PM_ConfReq;

        END LOOP;

    ELSE

        FOR Act_ConfReq_rec IN  Lx_Act_ConfReq(Lx_SrvLine_Id,Lx_Program_Id,Lx_Activity_Id) LOOP

             x_pm_conf_reqd    := Act_ConfReq_rec.Act_ConfReq;

        END LOOP;

    END IF;
   X_Return_Status       := Lx_Return_Status;

  EXCEPTION

    WHEN OTHERS THEN

      OKC_API.SET_MESSAGE
        (P_App_Name	  => G_APP_NAME_OKC
	,P_Msg_Name	  => G_UNEXPECTED_ERROR
	,P_Token1	  => G_SQLCODE_TOKEN
	,P_Token1_Value	  => SQLCODE
	,P_Token2	  => G_SQLERRM_TOKEN
	,P_Token2_Value   => SQLERRM);

      OKC_API.SET_MESSAGE
        (P_App_Name	  => G_APP_NAME_OKC
	,P_Msg_Name	  => G_DEBUG_TOKEN
	,P_Token1	  => G_PACKAGE_TOKEN
	,P_Token1_Value	  => G_PKG_NAME
	,P_Token2	  => G_PROGRAM_TOKEN
	,P_Token2_Value   => 'Get_PM_Confirmation');

      --X_Result        := G_FALSE;
      X_Return_Status   := G_RET_STS_UNEXP_ERROR;

  END Get_PM_Confirmation;
--chkrishn 02/25/2004 modified to accept p_pm_activity_id parameter
PROCEDURE Check_PM_Exists
    (p_api_version          IN  Number
    ,p_init_msg_list        IN  Varchar2
    ,p_pm_program_id        IN  Number default null
    ,p_pm_activity_id       IN  Number default null
    ,x_return_status        out nocopy Varchar2
    ,x_msg_count            out nocopy Number
    ,x_msg_data             out nocopy Varchar2
    ,x_pm_reference_exists  out nocopy Varchar2)
 IS

--
-- Modified for 12.0 Coverage Rearch project (JVARGHES)
--
/*
CURSOR Lx_PM_exist(Cx_PM_Id IN NUMBER) IS
SELECT sts.ste_code
from
     okc_k_lines_b cle,
     okc_k_lines_b covcle,
     oks_k_lines_b cov,
     okc_statuses_b sts
where
    cle.id=covcle.cle_id
    and covcle.id=cov.cle_id
    and cle.sts_code=sts.code
    and    sts.ste_code in ('ACTIVE','ENTERED','HOLD')
    and cov.pm_program_id=Cx_PM_Id;
*/
--
-- Modified for 12.0 Coverage Rearch project (JVARGHES)
--
CURSOR Lx_PM_exist(Cx_PM_Id IN NUMBER) IS
SELECT sts.ste_code
from
     okc_k_lines_b cle,
     oks_k_lines_b ksl,
     okc_statuses_b sts
where
      cle.id = ksl.cle_id
    and cle.sts_code=sts.code
    and    sts.ste_code in ('ACTIVE','ENTERED','HOLD')
    and ksl.pm_program_id = Cx_PM_Id;
--
--

--
-- Modified for 12.0 Coverage Rearch project (JVARGHES)
--
/*
CURSOR Lx_Act_exist(Cx_Act_Id IN NUMBER) IS
select
    sts.ste_code
from
     okc_k_lines_b cle,
     okc_k_lines_b covcle,
    oks_pm_activities act,
    okc_statuses_b sts
where
    cle.id=covcle.cle_id
    and cle.sts_code=sts.code
    and covcle.id=act.cle_id
    and  sts.ste_code in ('ACTIVE','ENTERED','HOLD')
    and act.activity_id=Cx_Act_Id;
*/
--
-- Modified for 12.0 Coverage Rearch project (JVARGHES)
--
CURSOR Lx_Act_exist(Cx_Act_Id IN NUMBER) IS
select
    sts.ste_code
from
     okc_k_lines_b cle,
    oks_pm_activities act,
    okc_statuses_b sts
where
       cle.sts_code = sts.code
    and cle.id = act.cle_id
    and  sts.ste_code in ('ACTIVE','ENTERED','HOLD')
    and act.activity_id = Cx_Act_Id;

--
--
    Lx_Return_Status          Gx_Ret_Sts DEFAULT G_RET_STS_SUCCESS;
    Lx_pm_exists            VARCHAR2(1) := 'N';
    L_EXCEP_UNEXPECTED_ERR   EXCEPTION;

 BEGIN
   --if neither activity id nor program id are passed , raise exception

   IF p_pm_program_id IS NULL and p_pm_activity_id is NULL THEN
      raise L_EXCEP_UNEXPECTED_ERR;
   END IF;

   IF p_pm_program_id IS NOT NULL THEN
     FOR PM_exists_rec IN  Lx_PM_exist(p_pm_program_id) LOOP
          X_Return_Status       := Lx_Return_Status;
          Lx_pm_exists         := 'Y';
          exit;
     END LOOP;

     x_pm_reference_exists := Lx_pm_exists;
     X_Return_Status       := Lx_Return_Status;
   END IF;
   IF p_pm_activity_id IS NOT NULL AND p_pm_program_id is null THEN
     FOR Act_exists_rec IN  Lx_Act_exist(p_pm_activity_id) LOOP
          X_Return_Status       := Lx_Return_Status;
          Lx_pm_exists         := 'Y';
          exit;
     END LOOP;

     x_pm_reference_exists := Lx_pm_exists;
     X_Return_Status       := Lx_Return_Status;
   END IF;


  EXCEPTION

    WHEN L_EXCEP_UNEXPECTED_ERR THEN
      OKC_API.SET_MESSAGE
        (P_App_Name	  => G_APP_NAME_OKC
    	,P_Msg_Name	  => G_DEBUG_TOKEN
	    ,P_Token1	  => G_PACKAGE_TOKEN
    	,P_Token1_Value	  => G_PKG_NAME
    	,P_Token2	  => G_PROGRAM_TOKEN
    	,P_Token2_Value   => 'Check_PM_Exists');

      X_Return_Status   := G_RET_STS_ERROR;

    WHEN OTHERS THEN

      OKC_API.SET_MESSAGE
        (P_App_Name	  => G_APP_NAME_OKC
	,P_Msg_Name	  => G_UNEXPECTED_ERROR
	,P_Token1	  => G_SQLCODE_TOKEN
	,P_Token1_Value	  => SQLCODE
	,P_Token2	  => G_SQLERRM_TOKEN
	,P_Token2_Value   => SQLERRM);

      OKC_API.SET_MESSAGE
        (P_App_Name	  => G_APP_NAME_OKC
	,P_Msg_Name	  => G_DEBUG_TOKEN
	,P_Token1	  => G_PACKAGE_TOKEN
	,P_Token1_Value	  => G_PKG_NAME
	,P_Token2	  => G_PROGRAM_TOKEN
	,P_Token2_Value   => 'Check_PM_Exists');

      X_Return_Status   := G_RET_STS_UNEXP_ERROR;

 END Check_PM_Exists;


END OKS_PM_ENTITLEMENTS_PVT;

/
