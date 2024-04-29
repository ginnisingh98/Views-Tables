--------------------------------------------------------
--  DDL for Package Body OKS_ENTITLEMENTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_ENTITLEMENTS_PVT" AS
/* $Header: OKSRENTB.pls 120.25.12010000.6 2010/05/04 10:53:35 vgujarat ship $ */

 covd_account_party_id VARCHAR2(40) := NULL; -- 4690940
 set_account_party_id  VARCHAR2(1) := 'F';   -- 4690940

 -- Bug Fix #5546615 hmnair
 G_Rel_Sun VARCHAR2(15) := Get_NLS_Day_Of_Week('SUN');
 G_Rel_Mon VARCHAR2(15) := Get_NLS_Day_Of_Week('MON');
 G_Rel_Tue VARCHAR2(15) := Get_NLS_Day_Of_Week('TUE');
 G_Rel_Wed VARCHAR2(15) := Get_NLS_Day_Of_Week('WED');
 G_Rel_Thu VARCHAR2(15) := Get_NLS_Day_Of_Week('THU');
 G_Rel_Fri VARCHAR2(15) := Get_NLS_Day_Of_Week('FRI');
 G_Rel_Sat VARCHAR2(15) := Get_NLS_Day_Of_Week('SAT');

 PROCEDURE Validate_Required_NumValue
    (P_Num_Value              IN  NUMBER
    ,P_Set_ExcepionStack      IN  Gx_Boolean
    ,P_ExcepionMsg            IN  Gx_ExceptionMsg
    ,X_Result                 out nocopy Gx_Boolean
    ,X_Return_Status   	      out nocopy Gx_Ret_Sts)
  IS

    Ln_Num_Value              CONSTANT NUMBER := P_Num_Value;
    Lx_Set_ExcepionStack      CONSTANT Gx_Boolean := P_Set_ExcepionStack;
    Lx_ExcepionMsg            CONSTANT Gx_ExceptionMsg := P_ExcepionMsg;

    Lx_Result                 Gx_Boolean;
    Lx_Return_Status          Gx_Ret_Sts;

    L_EXCEP_NULL_VALUE        EXCEPTION;

  BEGIN

    Lx_Result                 := G_TRUE;
    Lx_Return_Status          := G_RET_STS_SUCCESS;


    IF (Ln_Num_Value IS NULL) --OR (Ln_Num_Value = G_MISS_NUM)
    THEN

      RAISE L_EXCEP_NULL_VALUE;

    END IF;

    X_Result          := Lx_Result;
    X_Return_Status   := Lx_Return_Status;

  EXCEPTION

    WHEN L_EXCEP_NULL_VALUE THEN

      Lx_Result := G_FALSE;

      IF Lx_Set_ExcepionStack = G_TRUE THEN

        OKC_API.Set_Message
          (P_App_Name	  => G_APP_NAME_OKC
	  ,P_Msg_Name	  => G_REQUIRED_VALUE
	  ,P_Token1	  => G_COL_NAME_TOKEN
	  ,P_Token1_Value => Lx_ExcepionMsg);

        Lx_Return_Status := G_RET_STS_ERROR;

      END IF;

      X_Result        := Lx_Result;
      X_Return_Status := Lx_Return_Status;

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
	,P_Token2_Value   => 'Validate_Required_NumValue');

      X_Result        := G_FALSE;
      X_Return_Status := G_RET_STS_UNEXP_ERROR;

  END Validate_Required_NumValue;

-----------------------------------------------------------------------------------------------------------------------*

  PROCEDURE Validate_Required_DateValue
    (P_Date_Value             IN  DATE
    ,P_Set_ExcepionStack      IN  Gx_Boolean
    ,P_ExcepionMsg            IN  Gx_ExceptionMsg
    ,X_Result                 out nocopy Gx_Boolean
    ,X_Return_Status   	      out nocopy Gx_Ret_Sts)
  IS

    Ld_Date_Value             CONSTANT DATE := P_Date_Value;
    Lx_Set_ExcepionStack      CONSTANT Gx_Boolean := P_Set_ExcepionStack;
    Lx_ExcepionMsg            CONSTANT Gx_ExceptionMsg := P_ExcepionMsg;

    Lx_Result                 Gx_Boolean;
    Lx_Return_Status          Gx_Ret_Sts;

    L_EXCEP_NULL_VALUE        EXCEPTION;

  BEGIN

    Lx_Result                 := G_TRUE;
    Lx_Return_Status          := G_RET_STS_SUCCESS;

    IF (Ld_Date_Value IS NULL) --OR (Ld_Date_Value = G_MISS_DATE)
    THEN

      RAISE L_EXCEP_NULL_VALUE;

    END IF;

    X_Result          := Lx_Result;
    X_Return_Status   := Lx_Return_Status;

  EXCEPTION

    WHEN L_EXCEP_NULL_VALUE THEN

      Lx_Result := G_FALSE;

      IF Lx_Set_ExcepionStack = G_TRUE THEN

        OKC_API.Set_Message
          (P_App_Name	   => G_APP_NAME_OKC
	  ,P_Msg_Name	   => G_REQUIRED_VALUE
	  ,P_Token1	   => G_COL_NAME_TOKEN
	  ,P_Token1_Value  => Lx_ExcepionMsg);

        Lx_Return_Status := G_RET_STS_ERROR;

      END IF;

      X_Result          := Lx_Result;
      X_Return_Status   := Lx_Return_Status;

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
	,P_Token2_Value   => 'Validate_Required_DateValue');

      X_Result        := G_FALSE;
      X_Return_Status := G_RET_STS_UNEXP_ERROR;

  END Validate_Required_DateValue;

-----------------------------------------------------------------------------------------------------------------------*

  PROCEDURE Validate_Required_CharValue
    (P_Char_Value             IN  VARCHAR2
    ,P_Set_ExcepionStack      IN  Gx_Boolean
    ,P_ExcepionMsg            IN  Gx_ExceptionMsg
    ,X_Result                 out nocopy Gx_Boolean
    ,X_Return_Status   	      out nocopy Gx_Ret_Sts)
  IS

    Lv_Char_Value             CONSTANT VARCHAR2(10000) := P_Char_Value;
    Lx_Set_ExcepionStack      CONSTANT Gx_Boolean := P_Set_ExcepionStack;
    Lx_ExcepionMsg            CONSTANT Gx_ExceptionMsg := P_ExcepionMsg;

    Lx_Result                 Gx_Boolean;
    Lx_Return_Status          Gx_Ret_Sts;

    L_EXCEP_NULL_VALUE        EXCEPTION;

  BEGIN

    Lx_Result                 := G_TRUE;
    Lx_Return_Status          := G_RET_STS_SUCCESS;

    IF (Lv_Char_Value IS NULL) --OR (Lv_Char_Value = G_MISS_CHAR)
    THEN

      RAISE L_EXCEP_NULL_VALUE;

    END IF;

    X_Result          := Lx_Result;
    X_Return_Status   := Lx_Return_Status;

  EXCEPTION

    WHEN L_EXCEP_NULL_VALUE THEN

      Lx_Result := G_FALSE;

      IF Lx_Set_ExcepionStack = G_TRUE THEN

        OKC_API.Set_Message
          (P_App_Name	   => G_APP_NAME_OKC
	  ,P_Msg_Name	   => G_REQUIRED_VALUE
	  ,P_Token1	   => G_COL_NAME_TOKEN
	  ,P_Token1_Value  => Lx_ExcepionMsg);

        Lx_Return_Status := G_RET_STS_ERROR;

      END IF;

      X_Result          := Lx_Result;
      X_Return_Status   := Lx_Return_Status;

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
	,P_Token2_Value   => 'Validate_Required_CharValue');

      X_Result        := G_FALSE;
      X_Return_Status := G_RET_STS_UNEXP_ERROR;

  END Validate_Required_CharValue;

-----------------------------------------------------------------------------------------------------------------------*

  PROCEDURE Validate_Required_RT_Tokens
    (P_SVL_Id	                IN  Gx_OKS_Id
    ,P_BusiProc_Id	        IN  Gx_BusProcess_Id
    ,P_Severity_Id		IN  Gx_Severity_Id
    ,P_Request_Date		IN  DATE
    ,P_Request_TZone_id		IN  Gx_TimeZoneId
    ,P_template_YN          in varchar2 -- for default coverage functionality
    ,P_Set_ExcepionStack        IN  Gx_Boolean
    ,X_Result                   out nocopy Gx_Boolean
    ,X_Return_Status 	        out nocopy Gx_Ret_Sts
    )
  IS

    Lx_SVL_Id                 CONSTANT Gx_OKS_Id := P_SVL_Id;
    Lx_BusiProc_id            CONSTANT Gx_BusProcess_Id := P_BusiProc_Id;
    Lx_Severity_Id            CONSTANT Gx_Severity_Id := P_Severity_Id;
    Ld_Request_Date           CONSTANT DATE := P_Request_Date;
    Lx_Request_TZone_Id       CONSTANT Gx_TimeZoneId := P_Request_TZone_id;
    Lx_Set_ExcepionStack      CONSTANT Gx_Boolean := P_Set_ExcepionStack;
    Lx_Template_YN            CONSTANT Varchar2(1) := p_template_yn;

    Lx_Result                 Gx_Boolean;
    Lx_Return_Status          Gx_Ret_Sts;

    L_EXCEP_NULL_VALUE        EXCEPTION;

  BEGIN

    Lx_Result                 := G_TRUE;
    Lx_Return_Status          := G_RET_STS_SUCCESS;

   IF Lx_Template_YN = 'N' then

     Validate_Required_NumValue
       (P_Num_Value              => Lx_SVL_Id
       ,P_Set_ExcepionStack      => Lx_Set_ExcepionStack
       ,P_ExcepionMsg            => 'Contract Line'
       ,X_Result                 => Lx_result
       ,X_Return_Status   	=> Lx_Return_Status);

     IF Lx_result <> G_TRUE  THEN
        RAISE L_EXCEP_NULL_VALUE;
     END IF;

    ELSE

      Validate_Required_NumValue
       (P_Num_Value              => Lx_SVL_Id
       ,P_Set_ExcepionStack      => Lx_Set_ExcepionStack
       ,P_ExcepionMsg            => 'Coverage Template Line'
       ,X_Result                 => Lx_result
       ,X_Return_Status   	     => Lx_Return_Status);

     IF Lx_result <> G_TRUE  THEN
        RAISE L_EXCEP_NULL_VALUE;
     END IF;

    END IF;

    Validate_Required_NumValue
      (P_Num_Value              => Lx_BusiProc_id
      ,P_Set_ExcepionStack      => Lx_Set_ExcepionStack
      ,P_ExcepionMsg            => 'Business Process'
      ,X_Result                 => Lx_result
      ,X_Return_Status   	=> Lx_Return_Status);

    IF Lx_result <> G_TRUE  THEN
       RAISE L_EXCEP_NULL_VALUE;
    END IF;

    Validate_Required_NumValue
      (P_Num_Value              => Lx_Severity_Id
      ,P_Set_ExcepionStack      => Lx_Set_ExcepionStack
      ,P_ExcepionMsg            => 'Severity'
      ,X_Result                 => Lx_result
      ,X_Return_Status   	=> Lx_Return_Status);

    IF Lx_result <> G_TRUE  THEN
       RAISE L_EXCEP_NULL_VALUE;
    END IF;

    Validate_Required_NumValue
      (P_Num_Value              => Lx_Request_TZone_Id
      ,P_Set_ExcepionStack      => Lx_Set_ExcepionStack
      ,P_ExcepionMsg            => 'Time Zone'
      ,X_Result                 => Lx_result
      ,X_Return_Status   	=> Lx_Return_Status);

    IF Lx_result <> G_TRUE  THEN
       RAISE L_EXCEP_NULL_VALUE;
    END IF;

    Validate_Required_DateValue
      (P_Date_Value             => Ld_Request_Date
      ,P_Set_ExcepionStack      => Lx_Set_ExcepionStack
      ,P_ExcepionMsg            => 'Request Date'
      ,X_Result                 => Lx_result
      ,X_Return_Status   	=> Lx_Return_Status);

    IF Lx_result <> G_TRUE  THEN
       RAISE L_EXCEP_NULL_VALUE;
    END IF;

    X_Result        := Lx_Result;
    X_Return_Status := Lx_Return_Status;

  EXCEPTION

    WHEN L_EXCEP_NULL_VALUE THEN

      X_Result        := Lx_Result;
      X_Return_Status := Lx_Return_Status;

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
	,P_Token2_Value   => 'Validate_Required_RT_Tokens');

      X_Result        := G_FALSE;
      X_Return_Status := G_RET_STS_UNEXP_ERROR;

  END Validate_Required_RT_Tokens;

-----------------------------------------------------------------------------------------------------------------------*

  FUNCTION Get_End_Date_Time
    (P_Date_Value IN DATE) Return Date
  IS

    l_trunc_date         Varchar2(30);
    l_date_value         Date;

  BEGIN

    If P_Date_Value is Not Null Then
      l_trunc_date := to_char(P_Date_Value,'MM-DD-YYYY')||' '||'23:59:59';
      l_Date_Value := to_date(l_trunc_date,'MM-DD-YYYY HH24:MI:SS');
      Return(l_Date_Value);
    Else
      Return(P_Date_Value);
    End If;

  END Get_End_Date_Time;

-----------------------------------------------------------------------------------------------------------------------*

  PROCEDURE Validate_Service_Line
    (P_SVL_Id	              IN  Gx_OKS_Id
    ,P_Set_ExcepionStack        IN  Gx_Boolean
    ,X_CVL_Id	              OUT	nocopy NUMBER     -- Added for 12.0 Coverage Rearch project (JVARGHES)
    ,X_Std_Cov_YN	              OUT	nocopy VARCHAR2   -- Added for 12.0 Coverage Rearch project (JVARGHES)
    ,X_SVL_Start                out nocopy DATE
    ,X_SVL_End                  out nocopy DATE
    ,X_SVL_Terminated           out nocopy DATE
    ,X_Result                   out nocopy Gx_Boolean
    ,X_Return_Status 	        out nocopy Gx_Ret_Sts)
  IS

    -- Modified for 12.0 Coverage Rearch project (JVARGHES)

    CURSOR Lx_Csr_SVL(Cx_SVL_Id IN Gx_OKS_Id) IS
    SELECT SVL.Start_Date
          ,Get_End_Date_Time(SVL.End_Date) End_Date
          ,Get_End_Date_Time(SVL.Date_Terminated) Date_Terminated
          ,KSL.Coverage_Id
          ,KSL.Standard_Cov_YN
      FROM Okc_K_Lines_B SVL
          ,Oks_K_Lines_B KSL
     WHERE SVL.Id = Cx_SVL_Id
       AND SVL.Id = KSL.Cle_ID
       AND SVL.Lse_Id IN (G_LINE_STYLE_SERVICE
                         ,G_LINE_STYLE_WARRANTY
                         ,G_LINE_STYLE_EXT_WARRANTY) ;
    --

    Lx_SVL_Id                CONSTANT Gx_OKS_Id := P_SVL_Id;
    Lx_Set_ExcepionStack     CONSTANT Gx_Boolean := P_Set_ExcepionStack;

    -- Added for 12.0 Coverage Rearch project (JVARGHES)
    Ln_CVL_Id                NUMBER;
    Lv_Std_Cov_YN            VARCHAR2(1);
    --

    Ld_SVL_Start             DATE;
    Ld_SVL_End               DATE;
    Ld_SVL_Terminated        DATE;
    Lx_Result                Gx_Boolean;
    Lx_Return_Status         Gx_Ret_Sts;
    Lx_ExcepionMsg           Gx_ExceptionMsg;

    L_EXCEP_NO_DATA_FOUND    EXCEPTION;

  BEGIN

    Lx_Result                := G_TRUE;
    Lx_Return_Status         := G_RET_STS_SUCCESS;

    OPEN Lx_Csr_SVL(Lx_SVL_Id);
    FETCH Lx_Csr_SVL INTO Ld_SVL_Start,Ld_SVL_End,Ld_SVL_Terminated,Ln_CVL_Id,Lv_Std_Cov_YN;

    IF Lx_Csr_SVL%NOTFOUND THEN

      CLOSE Lx_Csr_SVL;

      Lx_ExcepionMsg := 'Contract Line';
      RAISE L_EXCEP_NO_DATA_FOUND;

    END IF;

    CLOSE Lx_Csr_SVL;

    -- Added for 12.0 Coverage Rearch project (JVARGHES)
    X_CVL_Id          := Ln_CVL_Id;
    X_Std_Cov_YN      := Lv_Std_Cov_YN;
    --

    X_SVL_Start       := Ld_SVL_Start;
    X_SVL_End         := Ld_SVL_End;
    X_SVL_Terminated  := Ld_SVL_Terminated;
    X_Result          := Lx_Result;
    X_Return_Status   := Lx_Return_Status;

  EXCEPTION

    WHEN L_EXCEP_NO_DATA_FOUND THEN

      Lx_Result   := G_FALSE;

      IF Lx_Set_ExcepionStack = G_TRUE THEN

        OKC_API.SET_MESSAGE
          (p_app_name	   => G_APP_NAME_OKC
	  ,p_msg_name	   => G_INVALID_VALUE
	  ,p_token1	   => G_COL_NAME_TOKEN
	  ,p_token1_value  => Lx_ExcepionMsg);

        Lx_Return_Status  := G_RET_STS_ERROR;

      END IF;

      X_Result        := Lx_Result;
      X_Return_Status := Lx_Return_Status;

    WHEN OTHERS THEN

      IF Lx_Csr_SVL%ISOPEN THEN
        CLOSE Lx_Csr_SVL;
      END IF;

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
	,P_Token2_Value   => 'Validate_Service_Line');

      X_Result        := G_FALSE;
      X_Return_Status := G_RET_STS_UNEXP_ERROR;

  END Validate_Service_Line;

-----------------------------------------------------------------------------------------------------------------------*

  PROCEDURE Validate_Coverage_Line
    (P_CVL_Id	          IN  Gx_OKS_Id   -- Added for 12.0 Coverage Rearch project (JVARGHES)
  --,P_SVL_Id	          IN  Gx_OKS_Id   -- Modified for 12.0 Coverage Rearch project (JVARGHES)
  --,P_Template_YN          IN  varchar2    -- Modified for 12.0 Coverage Rearch project (JVARGHES)
    ,P_Set_ExcepionStack    IN  Gx_Boolean
  --,X_CVL_Id               out nocopy Gx_OKS_Id  -- Modified for 12.0 Coverage Rearch project (JVARGHES)
    ,X_CVL_Start            out nocopy DATE
    ,X_CVL_End              out nocopy DATE
    ,X_CVL_Terminated       out nocopy DATE
    ,X_Result               out nocopy Gx_Boolean
    ,X_Return_Status 	    out nocopy Gx_Ret_Sts)

  IS

    -- Modified for 12.0 Coverage Rearch project (JVARGHES)
    --
    --CURSOR Lx_Csr_CVL(Cx_SVL_Id IN Gx_OKS_Id) IS
    --SELECT CVL.Id
    --		, CVL.Start_Date
    --		, Get_End_Date_Time(CVL.End_Date) End_Date
    --		, Get_End_Date_Time(CVL.Date_Terminated) Date_Terminated
    --  FROM Okc_K_Lines_B CVL
    -- WHERE CVL.Cle_id = Cx_SVL_Id
    --   AND Lse_Id IN (G_LINE_STYLE_SRV_COVERAGE
    --                 ,G_LINE_STYLE_WAR_COVERAGE
    --                 ,G_LINE_STYLE_EWT_COVERAGE);
    --
    --CURSOR Lx_Csr_Temp_CVL(Cx_COV_Id IN Gx_OKS_Id) IS
    --SELECT CVL.Id
    --		, CVL.Start_Date
    --		, Get_End_Date_Time(CVL.End_Date) End_Date
    --		, Get_End_Date_Time(CVL.Date_Terminated) Date_Terminated
    --  FROM Okc_K_Lines_B CVL
    -- WHERE CVL.Id = Cx_COV_Id
    --   AND Lse_Id IN (G_LINE_STYLE_SRV_COVERAGE
    --                 ,G_LINE_STYLE_WAR_COVERAGE
    --                 ,G_LINE_STYLE_EWT_COVERAGE);
    --
    -- Added for 12.0 Coverage Rearch project (JVARGHES)
    --

    CURSOR Lx_Csr_CVL(Cx_CVL_Id IN Gx_OKS_Id) IS
    SELECT CVL.Start_Date
	    ,Get_End_Date_Time(CVL.End_Date) End_Date
	    ,Get_End_Date_Time(CVL.Date_Terminated) Date_Terminated
      FROM Okc_K_Lines_B CVL
     WHERE CVL.Id = Cx_CVL_Id
       AND Lse_Id IN (G_LINE_STYLE_SRV_COVERAGE
                     ,G_LINE_STYLE_WAR_COVERAGE
                     ,G_LINE_STYLE_EWT_COVERAGE);

    --

    -- Lx_SVL_Id             CONSTANT Gx_OKS_Id := P_SVL_Id;  -- Modified for 12.0 Coverage Rearch project (JVARGHES)

    Lx_CVL_Id                CONSTANT Gx_OKS_Id := P_CVL_Id;
    Lx_Set_ExcepionStack     CONSTANT Gx_Boolean := P_Set_ExcepionStack;

    -- Lx_CVL_Id             Gx_OKS_Id;  -- Modified for1 2.0 Coverage Rearch project (JVARGHES)
    -- Lx_Template_YN        CONSTANT varchar2(1) := P_Template_YN; -- Modified for 12.0 Coverage Rearch project (JVARGHES)

    Ld_CVL_Start             DATE;
    Ld_CVL_End               DATE;
    Ld_CVL_Terminated        DATE;

    Lx_Result                Gx_Boolean;
    Lx_Return_Status         Gx_Ret_Sts;
    Lx_ExcepionMsg           Gx_ExceptionMsg;

    L_EXCEP_NO_DATA_FOUND    EXCEPTION;

  BEGIN

    Lx_Result                := G_TRUE;
    Lx_Return_Status         := G_RET_STS_SUCCESS;

    --
    -- Modified for 12.0 Coverage Rearch project (JVARGHES)
    --
    --IF Lx_Template_YN = 'N' THEN
    --
    --    OPEN Lx_Csr_CVL(Lx_SVL_Id);
    --    FETCH Lx_Csr_CVL INTO Lx_CVL_Id,Ld_CVL_Start,Ld_CVL_End,Ld_CVL_Terminated;
    --
    --    IF Lx_Csr_CVL%NOTFOUND THEN
    --
    --      CLOSE Lx_Csr_CVL;
    --      Lx_ExcepionMsg  := 'Coverage';
    --      RAISE L_EXCEP_NO_DATA_FOUND;
    --
    --    END IF;
    --
    --    CLOSE Lx_Csr_CVL;
    --
    --ELSE
    --
    --    OPEN Lx_Csr_Temp_CVL(Lx_SVL_Id);
    --    FETCH Lx_Csr_Temp_CVL INTO Lx_CVL_Id,Ld_CVL_Start,Ld_CVL_End,Ld_CVL_Terminated;
    --
    --    IF Lx_Csr_Temp_CVL%NOTFOUND THEN
    --
    --      CLOSE Lx_Csr_Temp_CVL;
    --      Lx_ExcepionMsg  := 'Coverage Template ';
    --      RAISE L_EXCEP_NO_DATA_FOUND;
    --
    --    END IF;
    --
    --    CLOSE Lx_Csr_Temp_CVL;
    --
    --END IF;

    -- Added for 12.0 Coverage Rearch project (JVARGHES)

    OPEN Lx_Csr_CVL(Lx_CVL_Id);
    FETCH Lx_Csr_CVL INTO Ld_CVL_Start,Ld_CVL_End,Ld_CVL_Terminated;

    IF Lx_Csr_CVL%NOTFOUND THEN

       CLOSE Lx_Csr_CVL;
       Lx_ExcepionMsg  := 'Coverage';
       RAISE L_EXCEP_NO_DATA_FOUND;

    END IF;

    CLOSE Lx_Csr_CVL;

    --
    -- X_CVL_Id           := Lx_CVL_Id;  --Modified for 12.0 Coverage Rearch project (JVARGHES)

    X_CVL_Start           := Ld_CVL_Start;
    X_CVL_End             := Ld_CVL_End;
    X_CVL_Terminated      := Ld_CVL_Terminated;

    X_Result              := Lx_Result;
    X_Return_Status 	  := Lx_Return_Status;

  EXCEPTION

    WHEN L_EXCEP_NO_DATA_FOUND THEN

      Lx_Result   := G_FALSE;

      IF Lx_Set_ExcepionStack = G_TRUE THEN

        OKC_API.SET_MESSAGE
          (P_App_Name	   => G_APP_NAME_OKC
	  ,P_Msg_Name	   => G_REQUIRED_VALUE
	  ,P_Token1	   => G_COL_NAME_TOKEN
	  ,P_Token1_Value  => Lx_ExcepionMsg);

        Lx_Return_Status  := G_RET_STS_ERROR;

      END IF;

      X_Result              := Lx_Result;
      X_Return_Status 	    := Lx_Return_Status;

    WHEN OTHERS THEN

      IF Lx_Csr_CVL%ISOPEN THEN
        CLOSE Lx_Csr_CVL;
      END IF;

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
	,P_Token2_Value   => 'Validate_Coverage_Line');

      X_Result              := G_FALSE;
      X_Return_Status       := G_RET_STS_UNEXP_ERROR;

  END Validate_Coverage_Line;

-----------------------------------------------------------------------------------------------------------------------*
--
-- Added for 12.0 Coverage Rearch project (JVARGHES)
--

  PROCEDURE Get_BP_Line_Start_Offset
    (P_BPL_Id	              IN  Gx_OKS_Id
    ,P_SVL_Start	              IN	DATE
    ,X_BPL_OFS_Start	        OUT	NOCOPY DATE
    ,X_BPL_OFS_Duration	        OUT	NOCOPY NUMBER
    ,X_BPL_OFS_UOM	        OUT	NOCOPY VARCHAR2
    ,X_Return_Status 	        out nocopy Gx_Ret_Sts)
  IS

    CURSOR Lx_Csr_BPL(Cx_BPL_Id IN Gx_OKS_Id) IS
    SELECT BPL.Offset_Duration
          ,BPL.Offset_period
      FROM Oks_K_Lines_B BPL
     WHERE BPL.Cle_Id = Cx_BPL_Id;

    Lx_BPL_Id                CONSTANT Gx_OKS_Id := P_BPL_Id;
    Ld_SVL_Start             CONSTANT DATE := P_SVL_Start;

    Ld_BPL_OFS_Start         DATE;
    Ln_BPL_OFS_Duration      NUMBER;
    Lv_BPL_OFS_UOM           VARCHAR2(100);

    Lx_Return_Status         Gx_Ret_Sts;

  BEGIN

    Lx_Return_Status         := G_RET_STS_SUCCESS;

    OPEN Lx_Csr_BPL(Lx_BPL_Id);
    FETCH Lx_Csr_BPL INTO Ln_BPL_OFS_Duration,Lv_BPL_OFS_UOM;

    CLOSE Lx_Csr_BPL;

    IF (Lv_BPL_OFS_UOM IS NOT NULL) AND (Ln_BPL_OFS_Duration IS NOT NULL) THEN

      Ld_BPL_OFS_Start  := OKC_Time_Util_Pub.Get_EndDate(P_Start_Date => Ld_SVL_Start
                                                        ,P_Timeunit   => Lv_BPL_OFS_UOM
                                                        ,P_Duration   => Ln_BPL_OFS_Duration);
      Ld_BPL_OFS_Start  := Ld_BPL_OFS_Start + 1;

    ELSE

      Ld_BPL_OFS_Start  := Ld_SVL_Start;

    END IF;

    X_BPL_OFS_Start    := Ld_BPL_OFS_Start;
    X_BPL_OFS_Duration := Ln_BPL_OFS_Duration;
    X_BPL_OFS_UOM      := Lv_BPL_OFS_UOM;
    X_Return_Status    := Lx_Return_Status;

  EXCEPTION

    WHEN OTHERS THEN

      IF Lx_Csr_BPL%ISOPEN THEN
        CLOSE Lx_Csr_BPL;
      END IF;

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
	,P_Token2_Value   => 'Get_BP_Line_Start_Offset');

      X_Return_Status := G_RET_STS_UNEXP_ERROR;

  END Get_BP_Line_Start_Offset;

-----------------------------------------------------------------------------------------------------------------------*


  PROCEDURE Validate_BusinessProcess_Line
    (P_BPL_Id	                IN  Gx_OKS_Id
    ,P_Set_ExcepionStack        IN  Gx_Boolean
    ,X_BPL_Start                out nocopy DATE
    ,X_BPL_End                  out nocopy DATE
    ,X_BPL_Terminated           out nocopy DATE
    ,X_Result                   out nocopy Gx_Boolean
    ,X_Return_Status 	        out nocopy Gx_Ret_Sts)
  IS

    CURSOR Lx_Csr_BPL(Cx_BPL_Id IN Gx_OKS_Id) IS
    SELECT BPL.Start_Date
          ,Get_End_Date_Time(BPL.End_Date) End_Date
          ,Get_End_Date_Time(BPL.Date_Terminated) Date_Terminated
      FROM Okc_K_Lines_B BPL
     WHERE BPL.Id = Cx_BPL_Id
       AND BPL.Lse_Id IN (3,16,21);

    Lx_BPL_Id                CONSTANT Gx_OKS_Id := P_BPL_Id;
    Lx_Set_ExcepionStack     CONSTANT Gx_Boolean := P_Set_ExcepionStack;

    Ld_BPL_Start             DATE;
    Ld_BPL_End               DATE;
    Ld_BPL_Terminated        DATE;
    Lx_Result                Gx_Boolean;
    Lx_Return_Status         Gx_Ret_Sts;
    Lx_ExcepionMsg           Gx_ExceptionMsg;

    L_EXCEP_NO_DATA_FOUND    EXCEPTION;

  BEGIN

    Lx_Result                := G_TRUE;
    Lx_Return_Status         := G_RET_STS_SUCCESS;

    OPEN Lx_Csr_BPL(Lx_BPL_Id);
    FETCH Lx_Csr_BPL INTO Ld_BPL_Start,Ld_BPL_End,Ld_BPL_Terminated;

    IF Lx_Csr_BPL%NOTFOUND THEN

      CLOSE Lx_Csr_BPL;

      Lx_ExcepionMsg := 'Contract Business Process Line';
      RAISE L_EXCEP_NO_DATA_FOUND;

    END IF;

    CLOSE Lx_Csr_BPL;

    X_BPL_Start       := Ld_BPL_Start;
    X_BpL_End         := Ld_BPL_End;
    X_BPL_Terminated  := Ld_BPL_Terminated;
    X_Result          := Lx_Result;
    X_Return_Status   := Lx_Return_Status;

  EXCEPTION

    WHEN L_EXCEP_NO_DATA_FOUND THEN

      Lx_Result   := G_FALSE;

      IF Lx_Set_ExcepionStack = G_TRUE THEN

        OKC_API.SET_MESSAGE
          (p_app_name	   => G_APP_NAME_OKC
	  ,p_msg_name	   => G_INVALID_VALUE
	  ,p_token1	   => G_COL_NAME_TOKEN
	  ,p_token1_value  => Lx_ExcepionMsg);

        Lx_Return_Status  := G_RET_STS_ERROR;

      END IF;

      X_Result        := Lx_Result;
      X_Return_Status := Lx_Return_Status;

    WHEN OTHERS THEN

      IF Lx_Csr_BPL%ISOPEN THEN
        CLOSE Lx_Csr_BPL;
      END IF;

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
	,P_Token2_Value   => 'Validate_BusinessProcess_Line');

      X_Result        := G_FALSE;
      X_Return_Status := G_RET_STS_UNEXP_ERROR;

  END Validate_BusinessProcess_Line;

-----------------------------------------------------------------------------------------------------------------------*

  PROCEDURE Validate_Contract_BP
    (P_CVL_Id	            IN  Gx_OKS_Id      --P_SVL_Id   IN  Gx_OKS_Id
    ,P_BP_Id	            IN  Gx_BusProcess_Id
    ,P_BP_ObjCode           IN  Gx_JTOT_ObjCode
    ,P_Set_ExcepionStack    IN  Gx_Boolean
    ,X_BPL_Id               OUT nocopy Gx_OKS_Id
    ,X_BPL_Start            OUT nocopy DATE
    ,X_BPL_End              OUT nocopy DATE
    ,X_BPL_Terminated       OUT nocopy DATE
    ,X_Result               OUT nocopy Gx_Boolean
    ,X_Return_Status 	    OUT nocopy Gx_Ret_Sts)
  IS

  /**
   bug 3202650: The purpose is to suppress index on ITM.object1_id1,ITM.jtot_object1_code and let
   index on ITM.cle_id be used to improve the cardinality on OKC_K_ITEMS during row source operation.

  **/

      CURSOR Lx_Csr_BPL(Cx_CVL_Id IN Gx_OKS_Id,Cx_BP_Id IN Gx_BusProcess_Id,Cx_BP_ObjCode IN Gx_JTOT_ObjCode) IS
      SELECT BPL.Id
            ,BPL.Start_Date
            ,Get_End_Date_Time(BPL.End_Date) End_Date
            ,Get_End_Date_Time(BPL.Date_Terminated) Date_Terminated
	FROM Okc_K_Lines_B BPL,
             Okc_K_Lines_B CVL
	WHERE CVL.id = Cx_CVL_Id
	AND BPL.Cle_Id = CVL.Id
	AND EXISTS ( SELECT '*'
			FROM Okc_K_Items ITM
			WHERE ITM.Cle_id = BPL.Id
			AND ITM.Object1_Id1 = Cx_BP_Id -- TO_CHAR(Cx_BP_Id) commented due to bug 3202650
			AND ITM.Object1_Id2 = '#'
			AND ITM.Jtot_Object1_Code = Cx_BP_ObjCode);

    --Lx_SVL_Id              CONSTANT Gx_OKS_Id := P_SVL_Id;
    Lx_CVL_Id              CONSTANT Gx_OKS_Id := P_CVL_Id;
    Lx_BP_Id               CONSTANT Gx_BusProcess_Id := P_BP_Id;
    Lx_BP_ObjCode          CONSTANT Gx_JTOT_ObjCode := P_BP_ObjCode;
    Lx_Set_ExcepionStack   CONSTANT Gx_Boolean := P_Set_ExcepionStack;

    Lx_BPL_Id              Gx_OKS_Id;
    Ld_BPL_Start           DATE;
    Ld_BPL_End             DATE;
    Ld_BPL_Terminated      DATE;

    Lx_Result              Gx_Boolean;
    Lx_Return_Status       Gx_Ret_Sts;

    Lx_ExcepionMsg         Gx_ExceptionMsg;

    L_EXCEP_NO_DATA_FOUND    EXCEPTION;

  BEGIN

    Lx_Result              := G_TRUE;
    Lx_Return_Status       := G_RET_STS_SUCCESS;

--    OPEN Lx_Csr_BPL(Lx_SVL_Id,Lx_BP_Id,Lx_BP_ObjCode);
    OPEN Lx_Csr_BPL(Lx_CVL_Id,Lx_BP_Id,Lx_BP_ObjCode);
    FETCH Lx_Csr_BPL INTO Lx_BPL_Id,Ld_BPL_Start,Ld_BPL_End,Ld_BPL_Terminated;

    IF Lx_Csr_BPL%NOTFOUND THEN

      CLOSE Lx_Csr_BPL;
      Lx_ExcepionMsg := 'Business Process';
      RAISE L_EXCEP_NO_DATA_FOUND;

    END IF;

    CLOSE Lx_Csr_BPL;

    X_BPL_Id              := Lx_BPL_Id;
    X_BPL_Start           := Ld_BPL_Start;
    X_BPL_End             := Ld_BPL_End;
    X_BPL_Terminated      := Ld_BPL_Terminated;
    X_Result              := Lx_Result;
    X_Return_Status 	  := Lx_Return_Status;

  EXCEPTION

    WHEN L_EXCEP_NO_DATA_FOUND THEN

      Lx_Result   := G_FALSE;

      IF Lx_Set_ExcepionStack = G_TRUE THEN

        OKC_API.SET_MESSAGE
          (p_app_name	   => G_APP_NAME_OKC
	  ,p_msg_name	   => G_INVALID_VALUE
          ,p_token1	   => G_COL_NAME_TOKEN
	  ,p_token1_value  => Lx_ExcepionMsg);

        Lx_Return_Status  := G_RET_STS_ERROR;

      END IF;

      X_Result              := Lx_Result;
      X_Return_Status 	    := Lx_Return_Status;

    WHEN OTHERS THEN

      IF Lx_Csr_BPL%ISOPEN THEN
        CLOSE Lx_Csr_BPL;
      END IF;

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
	,P_Token2_Value   => 'Validate_Contract_BP');

      X_Result             := G_FALSE;
      X_Return_Status 	  := G_RET_STS_UNEXP_ERROR;

  END Validate_Contract_BP;

-----------------------------------------------------------------------------------------------------------------------

  PROCEDURE Get_Effective_End_Date
    (P_Start_Date            IN  DATE
    ,P_End_Date              IN  DATE
    ,P_Termination_Date      IN  DATE
    ,P_EndDate_Required      IN  Gx_Boolean
    ,P_Set_ExcepionStack     IN  Gx_Boolean
    ,P_ExcepionMsg           IN  Gx_ExceptionMsg
    ,X_EffEnd_Date           out nocopy DATE
    ,X_Result                out nocopy Gx_Boolean
    ,X_Return_Status  	     out nocopy Gx_Ret_Sts)

  IS

    Ld_Start_Date            CONSTANT DATE:= P_Start_Date;
    Ld_End_Date              CONSTANT DATE:= P_End_Date;
    Ld_Termination_Date      CONSTANT DATE:= P_Termination_Date;
    Ld_EndDate_Required      CONSTANT Gx_Boolean := P_EndDate_Required;
    Lx_Set_ExcepionStack     CONSTANT Gx_Boolean := P_Set_ExcepionStack;

    Lx_ExcepionMsg           CONSTANT Gx_ExceptionMsg := P_ExcepionMsg;
    Lx_Final_Msg             Gx_ExceptionMsg;

    Ld_EffEnd_Date           DATE;
    Lx_Result                Gx_Boolean;
    Lx_Return_Status         Gx_Ret_Sts;

    Lx_End_Date_Null         Gx_Boolean;
    Lx_Termination_Date_Null Gx_Boolean;

    L_EXCEP_NULL_VALUE       EXCEPTION ;
    L_EXCEP_UNEXPECTED_ERR   EXCEPTION ;

  BEGIN

    Lx_Result                := G_TRUE;
    Lx_Return_Status         := G_RET_STS_SUCCESS;

    Lx_End_Date_Null         := G_FALSE;
    Lx_Termination_Date_Null := G_FALSE;

    Lx_Final_Msg   := Lx_ExcepionMsg||' Start Date';

    Validate_Required_DateValue
      (P_Date_Value           => Ld_Start_Date
      ,P_Set_ExcepionStack    => Lx_Set_ExcepionStack
      ,P_ExcepionMsg          => Lx_Final_Msg
      ,X_Result               => Lx_Result
      ,X_Return_Status        => Lx_Return_Status);

    IF Lx_result <> G_TRUE  THEN
      RAISE L_EXCEP_NULL_VALUE;
    END IF;

    Lx_Final_Msg   := Lx_ExcepionMsg||' End Date';

    Validate_Required_DateValue
      (P_Date_Value           => Ld_End_Date
      ,P_Set_ExcepionStack    => G_FALSE
      ,P_ExcepionMsg          => Lx_Final_Msg
      ,X_Result               => Lx_Result
      ,X_Return_Status        => Lx_Return_Status);

    IF Lx_result <> G_TRUE  THEN

      Lx_End_Date_Null  := G_TRUE;

      IF Lx_Return_Status = G_RET_STS_UNEXP_ERROR THEN
        RAISE L_EXCEP_UNEXPECTED_ERR;
      END IF;

    END IF;

    Lx_Final_Msg   := Lx_ExcepionMsg||' Termination Date';

    Validate_Required_DateValue
      (P_Date_Value           => Ld_Termination_Date
      ,P_Set_ExcepionStack    => G_FALSE
      ,P_ExcepionMsg          => Lx_Final_Msg
      ,X_Result               => Lx_Result
      ,X_Return_Status        => Lx_Return_Status);

    IF Lx_result <> G_TRUE  THEN

      Lx_Termination_Date_Null  := G_TRUE;

      IF Lx_Return_Status = G_RET_STS_UNEXP_ERROR THEN
        RAISE L_EXCEP_UNEXPECTED_ERR;
      END IF;

    END IF;

    IF Lx_Termination_Date_Null <> G_TRUE  THEN
-- grace period is not allowed if the line is terminated
      IF Lx_End_Date_Null = G_TRUE THEN
        Ld_EffEnd_Date        := Ld_Termination_Date;
      ELSE

        IF Ld_Termination_Date < Ld_End_Date THEN
          Ld_EffEnd_Date      := Ld_Termination_Date;
        ELSE
          Ld_EffEnd_Date      := Ld_End_Date;
        END IF;

      END IF;

    ELSE
      Ld_EffEnd_Date          := Ld_End_Date;

      -- grace period changes starts

     IF G_GRACE_PROFILE_SET = 'Y' THEN

     -- grace period changes are done only if line end date matches contract end date

        IF  trunc(Ld_EffEnd_Date) = trunc(G_CONTRACT_END_DATE) AND Ld_Termination_Date IS NULL THEN
            Ld_EffEnd_Date := Get_Final_End_Date(G_CONTRACT_ID,Ld_EffEnd_Date);
        END IF;

      END IF;

-- grace period changes ends

    END IF;

    IF Ld_EndDate_Required = G_TRUE THEN

      Lx_Final_Msg          := Lx_ExcepionMsg||' End date or Termination date';

      Validate_Required_DateValue
        (P_Date_Value           => Ld_EffEnd_Date
        ,P_Set_ExcepionStack    => Lx_Set_ExcepionStack
        ,P_ExcepionMsg          => Lx_Final_Msg
        ,X_Result               => Lx_result
        ,X_Return_Status   	=> Lx_Return_Status);

      IF Lx_result <> G_TRUE  THEN
        RAISE L_EXCEP_NULL_VALUE;
      END IF;

    END IF;

    Lx_Result               := G_TRUE;
    Lx_Return_Status        := G_RET_STS_SUCCESS;

    X_EffEnd_Date           := Ld_EffEnd_Date;
    X_Result                := Lx_Result;
    X_Return_Status  	    := Lx_Return_Status;

  EXCEPTION

    WHEN L_EXCEP_NULL_VALUE OR L_EXCEP_UNEXPECTED_ERR THEN

      X_Result              := Lx_Result;
      X_Return_Status 	    := Lx_Return_Status;

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
	,P_Token2_Value   => 'Get_Effective_End_Date');

      X_Result              := G_FALSE;
      X_Return_Status 	   := G_RET_STS_UNEXP_ERROR;

  END Get_Effective_End_Date;

-----------------------------------------------------------------------------------------------------------------------*

  PROCEDURE Get_BP_CoverTimeZone_Line
    (P_BPL_Id	             IN  Gx_OKS_Id
    ,P_Set_ExcepionStack     IN  Gx_Boolean
    ,X_BP_CVTLine_Id	     out nocopy Gx_OKS_Id
    ,X_BP_Tz_Id              out nocopy Gx_TimeZoneId
    ,X_Result                out nocopy Gx_Boolean
    ,X_Return_Status 	     out nocopy Gx_Ret_Sts)
  IS

    CURSOR Lx_Csr_BP_CVT(Cx_BPL_Id IN  Gx_OKS_Id) IS
      SELECT OCT.Id
            ,OCT.TimeZone_Id BP_Tzone_Id
        FROM Oks_Coverage_Timezones OCT
       WHERE OCT.CLE_ID = Cx_BPL_Id
         AND OCT.Default_YN = 'Y';

    Lx_BPL_Id             CONSTANT Gx_OKS_Id := P_BPL_Id;
    Lx_Set_ExcepionStack  CONSTANT Gx_Boolean := P_Set_ExcepionStack;

    Lx_BP_CVTLine_Id	  Gx_OKS_Id;
    Lx_BP_Tz_Id           Gx_TimeZoneId;
    Lx_Result             Gx_Boolean;
    Lx_Return_Status      Gx_Ret_Sts;
    Lx_ExcepionMsg        Gx_ExceptionMsg;

    L_EXCEP_NO_DATA_FOUND    EXCEPTION;
    L_EXCEP_NULL_VALUE       EXCEPTION;

  BEGIN

    Lx_Result             := G_TRUE;
    Lx_Return_Status      := G_RET_STS_SUCCESS;

    OPEN Lx_Csr_BP_CVT(Lx_BPL_Id);
    FETCH Lx_Csr_BP_CVT INTO Lx_BP_CVTLine_Id,Lx_BP_Tz_Id;

    IF Lx_Csr_BP_CVT%NOTFOUND  THEN

      Lx_ExcepionMsg := 'Cover Time';
      RAISE L_EXCEP_NO_DATA_FOUND;

    ELSE

      Validate_Required_NumValue
        (P_Num_Value            => Lx_BP_Tz_Id
        ,P_Set_ExcepionStack    => Lx_Set_ExcepionStack
        ,P_ExcepionMsg          => 'Cover Time - Time Zone'
        ,X_Result               => Lx_result
        ,X_Return_Status   	=> Lx_Return_Status);

      IF Lx_Result <> G_TRUE THEN
        RAISE L_EXCEP_NULL_VALUE;
      END IF;

    END IF;

    CLOSE Lx_Csr_BP_CVT;

    X_BP_CVTLine_Id     := Lx_BP_CVTLine_Id;
    X_BP_Tz_Id          := Lx_BP_Tz_Id;
    X_Result            := Lx_Result;
    X_Return_Status     := Lx_Return_Status;

  EXCEPTION

    WHEN L_EXCEP_NO_DATA_FOUND THEN

      IF Lx_Csr_BP_CVT%ISOPEN THEN
        CLOSE Lx_Csr_BP_CVT;
      END IF;

      Lx_Result   := G_FALSE;

      IF Lx_Set_ExcepionStack = G_TRUE THEN

        OKC_API.SET_MESSAGE
          (P_app_name	   => G_APP_NAME_OKC
      	  ,P_msg_name	   => G_REQUIRED_VALUE
          ,P_token1	   => G_COL_NAME_TOKEN
  	      ,P_token1_value  => Lx_ExcepionMsg);

        Lx_Return_Status  := G_RET_STS_ERROR;

      END IF;

      X_Result            := Lx_Result;
      X_Return_Status     := Lx_Return_Status;

    WHEN L_EXCEP_NULL_VALUE THEN

      IF Lx_Csr_BP_CVT%ISOPEN THEN
        CLOSE Lx_Csr_BP_CVT;
      END IF;

      X_Result             := Lx_Result;
      X_Return_Status 	   := Lx_Return_Status;

    WHEN OTHERS THEN

      IF Lx_Csr_BP_CVT%ISOPEN THEN
        CLOSE Lx_Csr_BP_CVT;
      END IF;

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
	,P_Token2_Value   => 'Get_BP_CoverTimeZone_Line');

      X_Result            := G_FALSE;
      X_Return_Status     := G_RET_STS_UNEXP_ERROR;

  END Get_BP_CoverTimeZone_Line;

-----------------------------------------------------------------------------------------------------------------------*

  PROCEDURE Convert_TimeZone
    (P_API_Version	IN  NUMBER
    ,P_Init_Msg_List    IN  VARCHAR2
    ,p_Source_Date      IN  DATE
    ,P_Source_Tz_Id     IN  Gx_TimeZoneId
    ,P_Dest_Tz_Id       IN  Gx_TimeZoneId
    ,X_Dest_Date        out nocopy DATE
    ,X_Msg_Count        out nocopy NUMBER
    ,X_Msg_Data		out nocopy VARCHAR2
    ,X_Return_Status 	out nocopy Gx_Ret_Sts)

  IS
  BEGIN

    OKX_GATEWAY.OKX_TIMEZONE_GETTIME
      (P_API_Version	 => P_API_Version
      ,P_Init_Msg_List	 => P_Init_Msg_List
      ,P_Source_Tz_Id	 => P_Source_Tz_Id
      ,P_Dest_Ts_Id	 => P_Dest_Tz_Id
      ,P_Source_Day_Time => p_Source_Date
      ,X_Dest_Day_Time	 => X_Dest_Date
      ,X_Return_Status	 => X_Return_Status
      ,X_Msg_Count	 => X_Msg_Count
      ,X_Msg_Data	 => X_Msg_Data);

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
	,P_Token2_Value   => 'Convert_TimeZone');

      X_Return_Status 	  := G_RET_STS_UNEXP_ERROR;

  END Convert_TimeZone;

-----------------------------------------------------------------------------------------------------------------------*

  PROCEDURE Validate_Effectivity
    (P_Request_Date	    IN  DATE
    ,P_Start_DateTime       IN  DATE
    ,P_End_DateTime         IN  DATE
    ,P_Set_ExcepionStack    IN  Gx_Boolean
    ,P_CL_Msg_TokenValue    IN  Gx_ExceptionMsg
    ,X_Result               out nocopy Gx_Boolean
    ,X_Return_Status 	    out nocopy Gx_Ret_Sts)

  IS

    Ld_Request_Date          CONSTANT DATE := P_Request_Date;
    Ld_Start_DateTime        CONSTANT DATE := P_Start_DateTime;
    Ld_End_DateTime          CONSTANT DATE := P_End_DateTime;
    Lx_Set_ExcepionStack     CONSTANT Gx_Boolean := P_Set_ExcepionStack;
    Lx_CL_Msg_TokenValue     CONSTANT Gx_ExceptionMsg := P_CL_Msg_TokenValue;

    Lx_Result                Gx_Boolean;
    Lx_Return_Status         Gx_Ret_Sts;
    Lx_Msg_TokenVal_Start    Gx_ExceptionMsg;
    Lx_Msg_TokenVal_End      Gx_ExceptionMsg;

    L_EXCEP_NOT_EFFECTIVE    EXCEPTION;

  BEGIN

    Lx_Result                := G_TRUE;
    Lx_Return_Status         := G_RET_STS_SUCCESS;

    IF Ld_Request_Date BETWEEN Ld_Start_DateTime AND Ld_End_DateTime THEN

      NULL;

    ELSE

      Lx_Msg_TokenVal_Start  := Lx_CL_Msg_TokenValue||' Start Date/Time';
      Lx_Msg_TokenVal_End    := ' End Date/Time';

      RAISE L_EXCEP_NOT_EFFECTIVE;

    END IF;

    X_Result              := Lx_Result;
    X_Return_Status 	  := Lx_Return_Status;

  EXCEPTION

    WHEN L_EXCEP_NOT_EFFECTIVE THEN

      Lx_Result   := G_FALSE;

      IF Lx_Set_ExcepionStack = G_TRUE THEN

          OKC_API.SET_MESSAGE
          (p_app_name	   => G_APP_NAME_OKS
	  ,p_msg_name	   => 'OKS_INVALID_REQ_DT'
	  ,p_token1	   => 'DATE1'
          ,p_token1_value  => ''''||TO_CHAR(Ld_Request_Date,'YYYY/MM/DD HH24:MI:SS')||''''
	  ,p_token2	   => 'STARTDATE'
	  ,p_token2_value  => Lx_Msg_TokenVal_Start
	  ,p_token3	   => 'DATE2'
	  ,p_token3_value  => ''''||TO_CHAR(Ld_Start_DateTime,'YYYY/MM/DD HH24:MI:SS')||''''
	  ,p_token4	   => 'ENDDATE'
	  ,p_token4_value  => Lx_Msg_TokenVal_End
	  ,p_token5  	   => 'DATE3'
          ,p_token5_value  => ''''||TO_CHAR(Ld_End_DateTime,'YYYY/MM/DD HH24:MI:SS')||'''');

        Lx_Return_Status  := G_RET_STS_ERROR;

      END IF;

      X_Result             := Lx_Result;
      X_Return_Status 	   := Lx_Return_Status;

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
	,P_Token2_Value   => 'Validate_Effectivity');

      X_Result             := G_FALSE;
      X_Return_Status 	  := G_RET_STS_UNEXP_ERROR;

  END Validate_Effectivity;

-----------------------------------------------------------------------------------------------------------------------*

-- 11.5.10 rule rearchitecture changes ...the procedure will get only reaction time line id and not rule_id

  PROCEDURE Get_BP_ReactResolTime_Line
    (P_BPL_Id	             IN  Gx_OKS_Id
    ,P_Severity_Id	         IN  Gx_Severity_Id
    ,P_TimeType_Category     IN  Varchar2 --Gx_TimeType_Category
    ,P_Active_YN             IN  Gx_YesNo
    ,P_Set_ExcepionStack     IN  Gx_Boolean
    ,X_RTL_Id                out nocopy Gx_OKS_Id
    ,X_RTL_Start             out nocopy DATE
    ,X_RTL_End               out nocopy DATE
    ,X_RTL_Terminated        out nocopy DATE
    ,X_RTL_Line_Id	         out nocopy Gx_OKS_Id
    ,X_RTL_WT_YN             out nocopy Gx_YesNo
    ,X_Result                out nocopy Gx_Boolean
    ,X_Return_Status 	     out nocopy Gx_Ret_Sts)

  IS

    CURSOR Lx_Csr_RTL_Line(Cx_BPL_Id         IN Gx_OKS_Id
                          ,Cx_Severity_Id    IN Gx_Severity_Id
                          ,Cx_TimeType_Category IN Varchar2
                          ,Cx_Active_YN      IN Gx_YesNo
                          )
    IS
      SELECT RTL.Id
            ,RTL.Start_Date
            ,Get_End_Date_Time(RTL.End_Date) End_Date
            ,Get_End_Date_Time(RTL.Date_Terminated) Date_Terminated
            ,OKSRTL.Work_Thru_YN Work_Through_YN
        FROM Okc_K_Lines_B RTL
            ,Okc_K_Lines_B BPL
            ,oks_k_lines_b OKSRTL
            ,oks_action_time_types ACT
            ,oks_action_times ACM
       WHERE BPL.Id                         = Cx_BPL_Id
         AND RTL.Cle_Id                     = BPL.Id
         AND OKSRTL.Cle_Id                  = RTL.Id
         AND RTL.lse_id                     in (4,17,22)
         AND OKSRTL.incident_severity_id    = Cx_Severity_Id
         AND OKSRTL.react_active_yn         = Cx_Active_YN
         AND ACT.cle_id                     = RTL.id
         AND ACT.action_type_code           = Cx_TimeType_Category
         and ACT.id                         = ACM.cov_action_type_id
         and (ACM.sun_duration is not null or
              ACM.mon_duration is not null or
              ACM.tue_duration is not null or
              ACM.wed_duration is not null or
              ACM.thu_duration is not null or
              ACM.fri_duration is not null or
              ACM.sat_duration is not null);



    Lx_BPL_Id             CONSTANT Gx_OKS_Id := P_BPL_Id;
    Lx_Severity_Id        CONSTANT Gx_Severity_Id := P_Severity_Id;
    Lx_TimeType_Category  CONSTANT Varchar2(30) := P_TimeType_Category; --Gx_Rule_Category := P_Rule_Category;
    Lx_Active_YN          CONSTANT Gx_YesNo := P_Active_YN;

    Lx_Set_ExcepionStack  CONSTANT Gx_Boolean := P_Set_ExcepionStack;

    Lx_RTL_Id             Gx_OKS_Id;
    Ld_RTL_Start          DATE;
    Ld_RTL_End            DATE;
    Ld_RTL_Terminated     DATE;
    Lx_RTL_WT_YN          Gx_YesNo;

    Lx_Result             Gx_Boolean;
    Lx_Return_Status      Gx_Ret_Sts;
    Lx_ExcepionMsg        Gx_ExceptionMsg;

    L_EXCEP_NO_DATA_FOUND  EXCEPTION;

  BEGIN

    Lx_Result             := G_TRUE;
    Lx_Return_Status      := G_RET_STS_SUCCESS;

    OPEN Lx_Csr_RTL_Line(Lx_BPL_Id,Lx_Severity_Id,Lx_TimeType_Category,Lx_Active_YN);

    FETCH Lx_Csr_RTL_Line INTO Lx_RTL_Id,Ld_RTL_Start,LD_RTL_End,Ld_RTL_Terminated,Lx_RTL_WT_YN;

    IF Lx_Csr_RTL_Line%NOTFOUND  THEN

      CLOSE Lx_Csr_RTL_Line;

      IF Lx_TimeType_Category = G_RUL_CATEGORY_REACTION THEN
        Lx_ExcepionMsg := 'Reaction Time - Severity';
      ELSE
        Lx_ExcepionMsg := 'Resolution Time - Severity';
      END IF;

      RAISE L_EXCEP_NO_DATA_FOUND;

    END IF;

    CLOSE Lx_Csr_RTL_Line;

    X_RTL_Id            := Lx_RTL_Id;
    X_RTL_Start         := Ld_RTL_Start;
    X_RTL_End           := Ld_RTL_End;
    X_RTL_Terminated    := Ld_RTL_Terminated;
    X_RTL_Line_Id       := Lx_RTL_Id;
    X_RTL_WT_YN         := Lx_RTL_WT_YN;
    X_Result            := Lx_Result;
    X_Return_Status     := Lx_Return_Status;

  EXCEPTION

    WHEN L_EXCEP_NO_DATA_FOUND THEN

      Lx_Result   := G_FALSE;

      IF Lx_Set_ExcepionStack = G_TRUE THEN

        OKC_API.SET_MESSAGE
          (P_app_name	   => G_APP_NAME_OKC
	  ,P_msg_name	   => G_REQUIRED_VALUE
	  ,P_token1	   => G_COL_NAME_TOKEN
	  ,P_token1_value  => Lx_ExcepionMsg);

        Lx_Return_Status  := G_RET_STS_ERROR;

      END IF;

      X_Result            := Lx_Result;
      X_Return_Status     := Lx_Return_Status;

    WHEN OTHERS THEN

      IF Lx_Csr_RTL_Line%ISOPEN THEN
        CLOSE Lx_Csr_RTL_Line;
      END IF;

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
	,P_Token2_Value   => 'Get_BP_ReactResolTime_Line');

     X_Result            := G_FALSE;
     X_Return_Status     := G_RET_STS_UNEXP_ERROR;

  END Get_BP_ReactResolTime_Line;

-----------------------------------------------------------------------------------------------------------------------

  PROCEDURE Get_Cont_Effective_Dates
    (P_SVL_Start          IN DATE
    ,P_SVL_End            IN DATE
    ,P_CVL_Start          IN DATE
    ,P_CVL_End            IN DATE
    ,P_BPL_Start          IN DATE
    ,P_BPL_End            IN DATE
    ,P_RTL_Start          IN DATE
    ,P_RTL_End            IN DATE
    ,P_Set_ExcepionStack  IN  Gx_Boolean
    ,X_Cont_EffStart      out nocopy DATE
    ,X_Cont_EffEnd        out nocopy DATE
    ,X_Result             out nocopy Gx_Boolean
    ,X_Return_Status      out nocopy Gx_Ret_Sts)
  IS

    CURSOR Lx_Csr_RTL_EffDates(Cd_SVL_Start IN DATE
                              ,Cd_SVL_End   IN DATE
                              ,Cd_CVL_Start IN DATE
                              ,Cd_CVL_End   IN DATE
                              ,Cd_BPL_Start IN DATE
                              ,Cd_BPL_End   IN DATE
                              ,Cd_RTL_Start IN DATE
                              ,Cd_RTL_End   IN DATE)
    IS
      SELECT MAX(Start_Date), MIN(End_Date)
        FROM ( SELECT Cd_SVL_Start Start_Date, Cd_SVL_End End_Date FROM DUAL
               UNION
               SELECT Cd_CVL_Start Start_Date, Cd_CVL_End End_Date FROM DUAL
               UNION
               SELECT Cd_BPL_Start Start_Date, Cd_BPL_End End_Date FROM DUAL
               UNION
               SELECT Cd_RTL_Start Start_Date, Cd_RTL_End End_Date FROM DUAL);

    Ld_SVL_Start          CONSTANT DATE := P_SVL_Start;
    Ld_SVL_End            CONSTANT DATE := P_SVL_End;
    Ld_CVL_Start          CONSTANT DATE := P_CVL_Start;
    Ld_CVL_End            CONSTANT DATE := P_CVL_End;
    Ld_BPL_Start          CONSTANT DATE := P_BPL_Start;
    Ld_BPL_End            CONSTANT DATE := P_BPL_End;
    Ld_RTL_Start          CONSTANT DATE := P_RTL_Start;
    Ld_RTL_End            CONSTANT DATE := P_RTL_End ;

    Lx_Set_ExcepionStack  CONSTANT Gx_Boolean := P_Set_ExcepionStack;

    Ld_Cont_EffStart      DATE;
    Ld_Cont_EffEnd        DATE;
    Lx_Result             Gx_Boolean;
    Lx_Return_Status      Gx_Ret_Sts;

    Lx_Msg_TokenVal       Gx_ExceptionMsg;

    L_EXCEP_NO_DATA_FOUND EXCEPTION;
    L_EXCEP_NO_EFF_DATE   EXCEPTION;

  BEGIN

    Lx_Result             := G_TRUE;
    Lx_Return_Status      := G_RET_STS_SUCCESS;

    OPEN Lx_Csr_RTL_EffDates(Ld_SVL_Start,Ld_SVL_End,Ld_CVL_Start,Ld_CVL_End
                            ,Ld_BPL_Start,Ld_BPL_End,Ld_RTL_Start,Ld_RTL_End);

    FETCH Lx_Csr_RTL_EffDates INTO Ld_Cont_EffStart,Ld_Cont_EffEnd;

    IF Lx_Csr_RTL_EffDates%NOTFOUND THEN

      Lx_Msg_TokenVal     := 'Contract - Effectivity Dates';
      RAISE L_EXCEP_NO_DATA_FOUND;

    ELSE

      Lx_Msg_TokenVal   := 'Contract - Effective Start Date';

      Validate_Required_DateValue
        (P_Date_Value           => Ld_Cont_EffStart
        ,P_Set_ExcepionStack    => Lx_Set_ExcepionStack
        ,P_ExcepionMsg          => Lx_Msg_TokenVal
        ,X_Result               => Lx_result
        ,X_Return_Status   	=> Lx_Return_Status);

      IF Lx_Result <> G_TRUE  THEN
        RAISE L_EXCEP_NO_EFF_DATE;
      END IF;

      Lx_Msg_TokenVal   := 'Contract - Effective End Date';

      Validate_Required_DateValue
        (P_Date_Value           => Ld_Cont_EffEnd
        ,P_Set_ExcepionStack    => Lx_Set_ExcepionStack
        ,P_ExcepionMsg          => Lx_Msg_TokenVal
        ,X_Result               => Lx_result
        ,X_Return_Status   	=> Lx_Return_Status);

      IF Lx_Result <> G_TRUE  THEN
        RAISE L_EXCEP_NO_EFF_DATE;
      END IF;

    END IF;

    CLOSE Lx_Csr_RTL_EffDates;

    X_Cont_EffStart      := Ld_Cont_EffStart;
    X_Cont_EffEnd        := Ld_Cont_EffEnd;
    X_Result             := Lx_Result;
    X_Return_Status      := Lx_Return_Status;

  EXCEPTION

    WHEN L_EXCEP_NO_DATA_FOUND THEN

      IF Lx_Csr_RTL_EffDates%ISOPEN THEN
        CLOSE Lx_Csr_RTL_EffDates;
      END IF;

      Lx_Result           := G_FALSE;

      IF Lx_Set_ExcepionStack = G_TRUE THEN

        OKC_API.SET_MESSAGE
          (P_app_name	   => G_APP_NAME_OKC
	  ,P_msg_name	   => G_REQUIRED_VALUE
          ,P_token1	   => G_COL_NAME_TOKEN
	  ,P_token1_value  => Lx_Msg_TokenVal);

        Lx_Return_Status    := G_RET_STS_ERROR;

      END IF;

      X_Result             := Lx_Result;
      X_Return_Status      := Lx_Return_Status;

    WHEN L_EXCEP_NO_EFF_DATE THEN

      IF Lx_Csr_RTL_EffDates%ISOPEN THEN
        CLOSE Lx_Csr_RTL_EffDates;
      END IF;

      X_Result             := Lx_Result;
      X_Return_Status      := Lx_Return_Status;

    WHEN OTHERS THEN

      IF Lx_Csr_RTL_EffDates%ISOPEN THEN
        CLOSE Lx_Csr_RTL_EffDates;
      END IF;

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
	,P_Token2_Value   => 'Get_Cont_Effective_Dates');

     X_Result            := G_FALSE;
     X_Return_Status     := G_RET_STS_UNEXP_ERROR;

  END Get_Cont_Effective_Dates;

-----------------------------------------------------------------------------------------------------------------------*
    /*vgujarat - modified for access hour ER 9675504*/
  PROCEDURE Get_BP_Cover_Times
    (P_BP_CVTLine_Id	  IN  Gx_OKS_Id
    ,P_Request_Date       IN  DATE
    ,P_CovDay_DispFmt     IN  VARCHAR2
    ,P_Set_ExcepionStack  IN  Gx_Boolean
    ,X_BP_CovTimes        out nocopy Gt_Bp_CoverTimes
    ,X_Result             out nocopy Gx_Boolean
    ,X_Return_Status      out nocopy Gx_Ret_Sts
    ,P_cust_id                  IN NUMBER DEFAULT NULL
    ,P_cust_site_id             IN NUMBER DEFAULT NULL
    ,P_cust_loc_id              IN NUMBER DEFAULT NULL)
  IS

    CURSOR Lx_Csr_BP_CovTimes(Cx_BP_CVTLine_Id IN Gx_OKS_Id,
                              Cx_sunday_flag     in varchar2,
                              Cx_monday_flag     in varchar2,
                              Cx_tuesday_flag    in varchar2,
                              Cx_wednesday_flag  in varchar2,
                              Cx_thursday_flag   in varchar2,
                              Cx_friday_flag     in varchar2,
                              Cx_saturday_flag   in varchar2)
     IS
    SELECT LPAD(TO_CHAR(CVT.START_HOUR), 2, '0')||LPAD(TO_CHAR(CVT.START_MINUTE), 2, '0') BP_Cover_From
            ,LPAD(TO_CHAR(CVT.END_HOUR), 2, '0')||LPAD(TO_CHAR(CVT.END_MINUTE), 2, '0') BP_Cover_To
            ,((CVT.START_HOUR)*60+(CVT.START_MINUTE)) BP_Cover_From_num
    FROM  Oks_Coverage_Times CVT
    WHERE CVT.cov_tze_line_id        =  Cx_BP_CVTLine_Id
    And (
        decode(Cx_sunday_flag,'Y',CVT.sunday_yn,'N','#')        =      decode(Cx_sunday_flag,'Y','Y','N','#')
    and decode(Cx_monday_flag,'Y', CVT.monday_yn,'N','#')       =      decode(Cx_monday_flag,'Y','Y','N','#')
    and decode(Cx_tuesday_flag,'Y', CVT.tuesday_yn,'N','#')     =      decode(Cx_tuesday_flag,'Y','Y','N','#')
    and decode(Cx_wednesday_flag,'Y', CVT.wednesday_yn,'N','#') =      decode(Cx_wednesday_flag,'Y','Y','N','#')
    and decode(Cx_thursday_flag,'Y', CVT.thursday_yn,'N','#')   =      decode(Cx_thursday_flag,'Y','Y','N','#')
    and decode(Cx_friday_flag,'Y', CVT.friday_yn,'N','#')       =      decode(Cx_friday_flag,'Y','Y','N','#')
    and decode(Cx_saturday_flag,'Y', CVT.saturday_yn,'N','#')   =      decode(Cx_saturday_flag,'Y','Y','N','#')
	    )
    order by BP_Cover_From_num;


    Lx_BP_CVTLine_Id      CONSTANT Gx_OKS_Id := P_BP_CVTLine_Id;
    Ld_Request_Date       CONSTANT DATE := P_Request_Date;
    Lv_CovDay_DispFmt     CONSTANT VARCHAR2(15) := P_CovDay_DispFmt;
    Lx_Set_ExcepionStack  CONSTANT Gx_Boolean := P_Set_ExcepionStack;

    /*vgujarat - modified for access hour ER 9675504*/
    Lx_cust_id                 CONSTANT NUMBER              := P_cust_id;
    Lx_cust_site_id            CONSTANT NUMBER              := P_cust_site_id;
    Lx_cust_loc_id             CONSTANT NUMBER              := P_cust_loc_id;

    Lx_BP_CovTimes        Gt_Bp_CoverTimes;
    Lx_Result             Gx_Boolean;
    Lx_Return_Status      Gx_Ret_Sts;
    Lx_ExcepionMsg        Gx_ExceptionMsg;

    Li_TableIdx           BINARY_INTEGER;
    Li_RowCount           INTEGER(10);

    Lx_Request_date_Num   number;

    -- Added by JVARGHES

    Ld_Run_Date              DATE;
    Ln_CoverDay_Num          NUMBER;
    Lv_CoverDay_NLS_Char     VARCHAR2(30);
    Lv_CoverDay_USA_DY_Char  VARCHAR2(30);
    Ln_ReqDay_Relative       NUMBER;
    --

    Lx_sunday_flag        varchar2(1);
    Lx_monday_flag        varchar2(1);
    Lx_tuesday_flag       varchar2(1);
    Lx_wednesday_flag     varchar2(1);
    Lx_thursday_flag      varchar2(1);
    Lx_friday_flag        varchar2(1);
    Lx_saturday_flag      varchar2(1);

    week_ctr              number;

    L_EXCEP_NO_COVER_TIME  EXCEPTION;

/*vgujarat - modified for access hour ER 9675504*/

	l_access_hours CSF_MAP_ACC_HRS_PKG.access_hours_rec;

	l_sw_first_start varchar2(4);
	l_sw_first_end varchar2(4);
	l_sw_second_start varchar2(4);
	l_sw_second_end varchar2(4);

	l_ah_first_start_hrsmin varchar2(4);
	l_ah_first_end_hrsmin varchar2(4);
	l_ah_second_start_hrsmin varchar2(4);
	l_ah_second_end_hrsmin varchar2(4);

	l_day_first_start  varchar2(50);
	l_day_first_end   varchar2(50);
	l_day_second_start varchar2(50);
	l_day_second_end  varchar2(50);

	l_day varchar2(15);


	TYPE ah_time_rec IS RECORD
	    (access_day         INTEGER(1)
	    ,first_start        VARCHAR2(4)
	    ,first_end          VARCHAR2(4)
	    ,second_start       VARCHAR2(4)
	    ,second_end         VARCHAR2(4)
	    );

	TYPE ah_time_tbl_type IS TABLE OF ah_time_rec INDEX BY BINARY_INTEGER;

	ah_time_tbl ah_time_tbl_type ;

		TYPE ah_window_rec IS RECORD
	    (ah_cover_from        VARCHAR2(4)
	    ,ah_cover_to          VARCHAR2(4)
	    );

	TYPE ah_window_tbl_type IS TABLE OF ah_window_rec INDEX BY BINARY_INTEGER;

	ah_window_tbl ah_window_tbl_type ;

	temp_start       VARCHAR2(4);
    temp_end         VARCHAR2(4);
    final_bp_cover_from VARCHAR2(4);
    final_bp_cover_to   VARCHAR2(4);

 /*vgujarat - modified for access hour ER 9675504*/

  BEGIN

    Lx_Result             := G_TRUE;
    Lx_Return_Status      := G_RET_STS_SUCCESS;

    Li_RowCount           := 0;

    Lx_sunday_flag        := 'N';
    Lx_monday_flag        := 'N';
    Lx_tuesday_flag       := 'N';
    Lx_wednesday_flag     := 'N';
    Lx_thursday_flag      := 'N';
    Lx_friday_flag        := 'N';
    Lx_saturday_flag      := 'N';

    week_ctr              := 0;

    Li_TableIdx  := 0;

   while week_ctr < 7 loop

/* -- Commented out JVARGHES on Mar 07, 2005.
   -- for the resolution of Bug# 4191909.

    Lx_Request_date_Num := to_number(to_char(Ld_Request_Date+week_ctr,'D'));

    Lx_sunday_flag        := 'N';
    Lx_monday_flag        := 'N';
    Lx_tuesday_flag       := 'N';
    Lx_wednesday_flag     := 'N';
    Lx_thursday_flag      := 'N';
    Lx_friday_flag        := 'N';
    Lx_saturday_flag      := 'N';

    if Lx_Request_date_Num = 1 then
         Lx_sunday_flag      := 'Y';
    elsif Lx_Request_date_Num = 2 then
         Lx_monday_flag      := 'Y';
    elsif Lx_Request_date_Num = 3 then
         Lx_tuesday_flag     := 'Y';
    elsif Lx_Request_date_Num = 4 then
         Lx_wednesday_flag   := 'Y';
    elsif Lx_Request_date_Num = 5 then
         Lx_thursday_flag    := 'Y';
    elsif Lx_Request_date_Num = 6 then
         Lx_friday_flag      := 'Y';
    elsif Lx_Request_date_Num = 7 then
         Lx_saturday_flag    := 'Y';
    end if;
*/

   -- Added by JVARGHES on Mar 07, 2005.
   -- for the resolution of Bug# 4191909.

    Lx_Sunday_Flag        := 'N';
    Lx_Monday_Flag        := 'N';
    Lx_Tuesday_Flag       := 'N';
    Lx_Wednesday_Flag     := 'N';
    Lx_Thursday_Flag      := 'N';
    Lx_Friday_Flag        := 'N';
    Lx_Saturday_Flag      := 'N';

    Ld_Run_Date           := Ld_Request_Date+Week_Ctr;
    Ln_CoverDay_Num       := TO_NUMBER(TO_CHAR(Ld_Run_Date,'D'));
    Lv_CoverDay_NLS_Char  := TO_CHAR(Ld_Run_Date,Lv_CovDay_DispFmt);
    Lv_CoverDay_USA_DY_Char  := TO_CHAR(Ld_Run_Date,'DY','NLS_DATE_LANGUAGE = AMERICAN');

    IF Lv_CoverDay_USA_DY_Char = 'SUN' THEN
       Lx_Sunday_Flag      := 'Y';
    ELSIF Lv_CoverDay_USA_DY_Char = 'MON' THEN
       Lx_Monday_Flag      := 'Y';
    ELSIF Lv_CoverDay_USA_DY_Char = 'TUE' THEN
       Lx_Tuesday_Flag     := 'Y';
    ELSIF Lv_CoverDay_USA_DY_Char = 'WED' THEN
       Lx_Wednesday_Flag   := 'Y';
    ELSIF Lv_CoverDay_USA_DY_Char = 'THU' THEN
       Lx_Thursday_Flag    := 'Y';
    ELSIF Lv_CoverDay_USA_DY_Char = 'FRI' THEN
       Lx_Friday_Flag      := 'Y';
    ELSIF Lv_CoverDay_USA_DY_Char = 'SAT' THEN
       Lx_Saturday_Flag    := 'Y';
    END IF;

    Ln_ReqDay_Relative     := Week_Ctr+1;

   --

/*vgujarat - modified for access hour ER 9675504*/
----------------------------Access Hours Code Change starts here --------------------------------------
/*
Reg :The application should take the access hours into account when calculating SLAs on the SR.

The Respond by and Resolve by dates should be pushed out when customer site is unavailable between the time the service request is logged and the Respond by time.

1.Get the Access Hour information from the api CSF_MAP_ACC_HRS_PKG.Query_ROW
2.For each and every day concatenate the hour and minute portion of first_start,first_end,second_start and second_end
    ex) if 09:30 = > 0930
3.Calculate the Service Window which is derived from the covered time and the access hours
4.Pass this calculated service window to the OUT variable X_BP_CovTimes

*/


-- If the newly added profile 'Service: Include Access Hours in SLA' is set to Yes then access hours is taken into consideration

   If (fnd_profile.value('CS_SR_INCLUDE_ACCESS_HOURS_IN_SLA') = 'Y') AND (Lx_cust_id IS NOT NULL OR Lx_cust_site_id IS NOT NULL OR Lx_cust_loc_id IS NOT NULL) THEN



    -- Calling the Field Service API to get the Access Hours detail
    CSF_MAP_ACC_HRS_PKG.Query_ROW(
                              p_customer_id          => Lx_cust_id,
			      p_customer_site_id     => Lx_cust_site_id,
			      p_customer_location_id => Lx_cust_loc_id,
			      x_access_hours         => l_access_hours
			      );

    FOR i in 1..7 LOOP


	if i=1 then
	   l_day := 'SUNDAY';

	    l_ah_first_start_hrsmin  := to_char(l_access_hours.SUNDAY_FIRST_START,'hh24') ||
                 	                    to_char(l_access_hours.SUNDAY_FIRST_START,'mi');

		l_ah_first_end_hrsmin    := to_char(l_access_hours.SUNDAY_FIRST_END,'hh24') ||
					    to_char(l_access_hours.SUNDAY_FIRST_END,'mi');


		l_ah_second_start_hrsmin := to_char(l_access_hours.SUNDAY_SECOND_START,'hh24') ||
					    to_char(l_access_hours.SUNDAY_SECOND_START,'mi');

		l_ah_second_end_hrsmin   := to_char(l_access_hours.SUNDAY_SECOND_END,'hh24') ||
					    to_char(l_access_hours.SUNDAY_SECOND_END,'mi');

		   ah_time_tbl(i).access_day     := i;
		   ah_time_tbl(i).first_start    := l_ah_first_start_hrsmin;
		   ah_time_tbl(i).first_end      := l_ah_first_end_hrsmin;
		   ah_time_tbl(i).second_start   := l_ah_second_start_hrsmin;
		   ah_time_tbl(i).second_end     := l_ah_second_end_hrsmin;

	end if;

	if i=2 then l_day := 'MONDAY';

	    l_ah_first_start_hrsmin  := to_char(l_access_hours.MONDAY_FIRST_START,'hh24') ||
                 	                    to_char(l_access_hours.MONDAY_FIRST_START,'mi');

		l_ah_first_end_hrsmin    := to_char(l_access_hours.MONDAY_FIRST_END,'hh24') ||
					    to_char(l_access_hours.MONDAY_FIRST_END,'mi');


		l_ah_second_start_hrsmin := to_char(l_access_hours.MONDAY_SECOND_START,'hh24') ||
					    to_char(l_access_hours.MONDAY_SECOND_START,'mi');

		l_ah_second_end_hrsmin   := to_char(l_access_hours.MONDAY_SECOND_END,'hh24') ||
					    to_char(l_access_hours.MONDAY_SECOND_END,'mi');

		   ah_time_tbl(i).access_day     := i;
		   ah_time_tbl(i).first_start    := l_ah_first_start_hrsmin;
		   ah_time_tbl(i).first_end      := l_ah_first_end_hrsmin;
		   ah_time_tbl(i).second_start   := l_ah_second_start_hrsmin;
		   ah_time_tbl(i).second_end     := l_ah_second_end_hrsmin;

	end if;

	if i=3 then l_day := 'TUESDAY';

	        l_ah_first_start_hrsmin  := to_char(l_access_hours.TUESDAY_FIRST_START,'hh24') ||
                 	                    to_char(l_access_hours.TUESDAY_FIRST_START,'mi');

		l_ah_first_end_hrsmin    := to_char(l_access_hours.TUESDAY_FIRST_END,'hh24') ||
					    to_char(l_access_hours.TUESDAY_FIRST_END,'mi');


		l_ah_second_start_hrsmin := to_char(l_access_hours.TUESDAY_SECOND_START,'hh24') ||
					    to_char(l_access_hours.TUESDAY_SECOND_START,'mi');

		l_ah_second_end_hrsmin   := to_char(l_access_hours.TUESDAY_SECOND_END,'hh24') ||
					    to_char(l_access_hours.TUESDAY_SECOND_END,'mi');

		   ah_time_tbl(i).access_day     := i;
		   ah_time_tbl(i).first_start    := l_ah_first_start_hrsmin;
		   ah_time_tbl(i).first_end      := l_ah_first_end_hrsmin;
		   ah_time_tbl(i).second_start   := l_ah_second_start_hrsmin;
		   ah_time_tbl(i).second_end     := l_ah_second_end_hrsmin;

	end if;

	if i=4 then l_day := 'WEDNESDAY';
	        l_ah_first_start_hrsmin  := to_char(l_access_hours.WEDNESDAY_FIRST_START,'hh24') ||
                 	                    to_char(l_access_hours.WEDNESDAY_FIRST_START,'mi');

		l_ah_first_end_hrsmin    := to_char(l_access_hours.WEDNESDAY_FIRST_END,'hh24') ||
					    to_char(l_access_hours.WEDNESDAY_FIRST_END,'mi');


		l_ah_second_start_hrsmin := to_char(l_access_hours.WEDNESDAY_SECOND_START,'hh24') ||
					    to_char(l_access_hours.WEDNESDAY_SECOND_START,'mi');

		l_ah_second_end_hrsmin   := to_char(l_access_hours.WEDNESDAY_SECOND_END,'hh24') ||
					    to_char(l_access_hours.WEDNESDAY_SECOND_END,'mi');

		   ah_time_tbl(i).access_day     := i;
		   ah_time_tbl(i).first_start    := l_ah_first_start_hrsmin;
		   ah_time_tbl(i).first_end      := l_ah_first_end_hrsmin;
		   ah_time_tbl(i).second_start   := l_ah_second_start_hrsmin;
		   ah_time_tbl(i).second_end     := l_ah_second_end_hrsmin;

	end if;

	if i=5 then l_day := 'THURSDAY';
	       l_ah_first_start_hrsmin  := to_char(l_access_hours.THURSDAY_FIRST_START,'hh24') ||
                 	                    to_char(l_access_hours.THURSDAY_FIRST_START,'mi');

		l_ah_first_end_hrsmin    := to_char(l_access_hours.THURSDAY_FIRST_END,'hh24') ||
					    to_char(l_access_hours.THURSDAY_FIRST_END,'mi');


		l_ah_second_start_hrsmin := to_char(l_access_hours.THURSDAY_SECOND_START,'hh24') ||
					    to_char(l_access_hours.THURSDAY_SECOND_START,'mi');

		l_ah_second_end_hrsmin   := to_char(l_access_hours.THURSDAY_SECOND_END,'hh24') ||
					    to_char(l_access_hours.THURSDAY_SECOND_END,'mi');

		   ah_time_tbl(i).access_day     := i;
		   ah_time_tbl(i).first_start    := l_ah_first_start_hrsmin;
		   ah_time_tbl(i).first_end      := l_ah_first_end_hrsmin;
		   ah_time_tbl(i).second_start   := l_ah_second_start_hrsmin;
		   ah_time_tbl(i).second_end     := l_ah_second_end_hrsmin;

	end if;

	if i=6 then l_day := 'FRIDAY';
	        l_ah_first_start_hrsmin  := to_char(l_access_hours.FRIDAY_FIRST_START,'hh24') ||
                 	                    to_char(l_access_hours.FRIDAY_FIRST_START,'mi');

		l_ah_first_end_hrsmin    := to_char(l_access_hours.FRIDAY_FIRST_END,'hh24') ||
					    to_char(l_access_hours.FRIDAY_FIRST_END,'mi');


		l_ah_second_start_hrsmin := to_char(l_access_hours.FRIDAY_SECOND_START,'hh24') ||
					    to_char(l_access_hours.FRIDAY_SECOND_START,'mi');

		l_ah_second_end_hrsmin   := to_char(l_access_hours.FRIDAY_SECOND_END,'hh24') ||
					    to_char(l_access_hours.FRIDAY_SECOND_END,'mi');

		   ah_time_tbl(i).access_day     := i;
		   ah_time_tbl(i).first_start    := l_ah_first_start_hrsmin;
		   ah_time_tbl(i).first_end      := l_ah_first_end_hrsmin;
		   ah_time_tbl(i).second_start   := l_ah_second_start_hrsmin;
		   ah_time_tbl(i).second_end     := l_ah_second_end_hrsmin;
	end if;

	if i=7 then l_day := 'SATURDAY';

	        l_ah_first_start_hrsmin  := to_char(l_access_hours.SATURDAY_FIRST_START,'hh24') ||
                 	                    to_char(l_access_hours.SATURDAY_FIRST_START,'mi');

		l_ah_first_end_hrsmin    := to_char(l_access_hours.SATURDAY_FIRST_END,'hh24') ||
					    to_char(l_access_hours.SATURDAY_FIRST_END,'mi');


		l_ah_second_start_hrsmin := to_char(l_access_hours.SATURDAY_SECOND_START,'hh24') ||
					    to_char(l_access_hours.SATURDAY_SECOND_START,'mi');

		l_ah_second_end_hrsmin   := to_char(l_access_hours.SATURDAY_SECOND_END,'hh24') ||
					    to_char(l_access_hours.SATURDAY_SECOND_END,'mi');

		   ah_time_tbl(i).access_day     := i;
		   ah_time_tbl(i).first_start    := l_ah_first_start_hrsmin;
		   ah_time_tbl(i).first_end      := l_ah_first_end_hrsmin;
		   ah_time_tbl(i).second_start   := l_ah_second_start_hrsmin;
		   ah_time_tbl(i).second_end     := l_ah_second_end_hrsmin;
	end if;
   END LOOP;



     FOR Idx IN Lx_Csr_BP_CovTimes(Lx_BP_CVTLine_Id,
                                   Lx_sunday_flag,Lx_monday_flag,Lx_tuesday_flag,
                                   Lx_wednesday_flag,Lx_thursday_flag,Lx_friday_flag,
                                   Lx_saturday_flag) LOOP

      Li_TableIdx    := Li_TableIdx + 1;

  --  Modified by JVARGHES on Mar 07, 2005.
  --  for the resolution of Bug# 4191909

  --  Lx_BP_CovTimes(Li_TableIdx).Rv_Cover_Day       := to_char(Ld_Request_Date+week_ctr,Lv_CovDay_DispFmt); --Idx.BP_CoverDay_Char;
  --  Lx_BP_CovTimes(Li_TableIdx).Ri_Cover_Day       := Lx_Request_date_Num; --Idx.BP_CoverDay_Num;
  --  Lx_BP_CovTimes(Li_TableIdx).Ri_ReqDay_Relative := week_ctr+1; --Idx.BP_ReqDay_Ralative;
      /*access hour window to be considered*/
	  /*logic starts here*/
	  if Lx_sunday_flag = 'Y' then

		   ah_window_tbl(1).ah_cover_from    := ah_time_tbl(1).first_start;
		   ah_window_tbl(1).ah_cover_to      := ah_time_tbl(1).first_end;
		   ah_window_tbl(2).ah_cover_from   := ah_time_tbl(1).second_start;
		   ah_window_tbl(2).ah_cover_to     := ah_time_tbl(1).second_end;

      elsif Lx_monday_flag = 'Y' then
	  	   ah_window_tbl(1).ah_cover_from    := ah_time_tbl(2).first_start;
		   ah_window_tbl(1).ah_cover_to      := ah_time_tbl(2).first_end;
		   ah_window_tbl(2).ah_cover_from   := ah_time_tbl(2).second_start;
		   ah_window_tbl(2).ah_cover_to     := ah_time_tbl(2).second_end;

      elsif Lx_tuesday_flag = 'Y' then
		   ah_window_tbl(1).ah_cover_from    := ah_time_tbl(3).first_start;
		   ah_window_tbl(1).ah_cover_to      := ah_time_tbl(3).first_end;
		   ah_window_tbl(2).ah_cover_from   := ah_time_tbl(3).second_start;
		   ah_window_tbl(2).ah_cover_to     := ah_time_tbl(3).second_end;

       elsif Lx_wednesday_flag = 'Y' then
		   ah_window_tbl(1).ah_cover_from    := ah_time_tbl(4).first_start;
		   ah_window_tbl(1).ah_cover_to      := ah_time_tbl(4).first_end;
		   ah_window_tbl(2).ah_cover_from   := ah_time_tbl(4).second_start;
		   ah_window_tbl(2).ah_cover_to     := ah_time_tbl(4).second_end;

       elsif Lx_thursday_flag = 'Y' then
		   ah_window_tbl(1).ah_cover_from    := ah_time_tbl(5).first_start;
		   ah_window_tbl(1).ah_cover_to      := ah_time_tbl(5).first_end;
		   ah_window_tbl(2).ah_cover_from   := ah_time_tbl(5).second_start;
		   ah_window_tbl(2).ah_cover_to     := ah_time_tbl(5).second_end;

       elsif Lx_friday_flag = 'Y' then
		   ah_window_tbl(1).ah_cover_from    := ah_time_tbl(6).first_start;
		   ah_window_tbl(1).ah_cover_to      := ah_time_tbl(6).first_end;
		   ah_window_tbl(2).ah_cover_from   := ah_time_tbl(6).second_start;
		   ah_window_tbl(2).ah_cover_to     := ah_time_tbl(6).second_end;

        elsif Lx_saturday_flag = 'Y' then
		   ah_window_tbl(1).ah_cover_from    := ah_time_tbl(7).first_start;
		   ah_window_tbl(1).ah_cover_to      := ah_time_tbl(7).first_end;
		   ah_window_tbl(2).ah_cover_from   := ah_time_tbl(7).second_start;
		   ah_window_tbl(2).ah_cover_to     := ah_time_tbl(7).second_end;
        end if;

        for j in ah_window_tbl.first..ah_window_tbl.last loop
          temp_start := Greatest(Idx.bp_cover_from,ah_window_tbl(j).ah_cover_from);
            if temp_start = ah_window_tbl(j).ah_cover_from then
	           if temp_start <= Idx.bp_cover_to then
                 final_bp_cover_from := temp_start;

		          temp_end := least(Idx.bp_cover_to,ah_window_tbl(j).ah_cover_to);
		          final_bp_cover_to := temp_end;
	           end if;
	        else
	           if temp_start <= ah_window_tbl(j).ah_cover_to then
                 final_bp_cover_from := temp_start;

		         temp_end := least(Idx.bp_cover_to,ah_window_tbl(j).ah_cover_to);
		         final_bp_cover_to := temp_end;
	           end if;
	        end if;
        end loop;

	  /*logic ends here*/

      Lx_BP_CovTimes(Li_TableIdx).Rv_Cover_Day       := Lv_CoverDay_NLS_Char;
      Lx_BP_CovTimes(Li_TableIdx).Ri_Cover_Day       := Ln_CoverDay_Num;
      Lx_BP_CovTimes(Li_TableIdx).Ri_ReqDay_Relative := Ln_ReqDay_Relative;
      Lx_BP_CovTimes(Li_TableIdx).Rv_Cover_From      := final_bp_cover_from;
      Lx_BP_CovTimes(Li_TableIdx).Rv_Cover_To        := final_bp_cover_to;
      Lx_BP_CovTimes(Li_TableIdx).Rx_Cover_TZoneId   := null; -- Idx.BP_Tzone_Id; not required because already fetched

      Li_RowCount    := Li_TableIdx;

     END LOOP;

   ELSE /*If fnd_profile.value('CS_SR_INCLUDE_ACCESS_HOURS_IN_SLA') = 'Yes'*/
        FOR Idx IN Lx_Csr_BP_CovTimes(Lx_BP_CVTLine_Id,
                                   Lx_sunday_flag,Lx_monday_flag,Lx_tuesday_flag,
                                   Lx_wednesday_flag,Lx_thursday_flag,Lx_friday_flag,
                                   Lx_saturday_flag) LOOP

      Li_TableIdx    := Li_TableIdx + 1;

  --  Modified by JVARGHES on Mar 07, 2005.
  --  for the resolution of Bug# 4191909

  --  Lx_BP_CovTimes(Li_TableIdx).Rv_Cover_Day       := to_char(Ld_Request_Date+week_ctr,Lv_CovDay_DispFmt); --Idx.BP_CoverDay_Char;
  --  Lx_BP_CovTimes(Li_TableIdx).Ri_Cover_Day       := Lx_Request_date_Num; --Idx.BP_CoverDay_Num;
  --  Lx_BP_CovTimes(Li_TableIdx).Ri_ReqDay_Relative := week_ctr+1; --Idx.BP_ReqDay_Ralative;


      Lx_BP_CovTimes(Li_TableIdx).Rv_Cover_Day       := Lv_CoverDay_NLS_Char;
      Lx_BP_CovTimes(Li_TableIdx).Ri_Cover_Day       := Ln_CoverDay_Num;
      Lx_BP_CovTimes(Li_TableIdx).Ri_ReqDay_Relative := Ln_ReqDay_Relative;
      Lx_BP_CovTimes(Li_TableIdx).Rv_Cover_From      := Idx.BP_Cover_From;
      Lx_BP_CovTimes(Li_TableIdx).Rv_Cover_To        := Idx.BP_Cover_To;
      Lx_BP_CovTimes(Li_TableIdx).Rx_Cover_TZoneId   := null; -- Idx.BP_Tzone_Id; not required because already fetched

      Li_RowCount    := Li_TableIdx;

     END LOOP;
    END IF; /*If fnd_profile.value('CS_SR_INCLUDE_ACCESS_HOURS_IN_SLA') = 'Yes'*/
/*vgujarat - modified for access hour ER 9675504*/
     week_ctr   := week_ctr+1;

    end loop;

    IF Li_RowCount = 0  THEN

      Lx_ExcepionMsg   := 'Cover Time';
      RAISE L_EXCEP_NO_COVER_TIME;

    END IF;

    X_BP_CovTimes    := Lx_BP_CovTimes;
    X_Result         := Lx_Result;
    X_Return_Status  := Lx_Return_Status;

  EXCEPTION

    WHEN L_EXCEP_NO_COVER_TIME THEN

      Lx_Result        := G_FALSE;

      IF Lx_Set_ExcepionStack = G_TRUE THEN

        OKC_API.SET_MESSAGE
          (P_App_Name	   => G_APP_NAME_OKC
	  ,P_Msg_Name	   => G_REQUIRED_VALUE
	  ,P_Token1	   => G_COL_NAME_TOKEN
	  ,P_Token1_Value  => Lx_ExcepionMsg);

        Lx_Return_Status := G_RET_STS_ERROR;

      END IF;

      X_Result         := Lx_Result;
      X_Return_Status  := Lx_Return_Status;

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
	,P_Token2_Value   => 'Get_BP_Cover_Times');

     X_Result            := G_FALSE;
     X_Return_Status     := G_RET_STS_UNEXP_ERROR;

  END Get_BP_Cover_Times;

-----------------------------------------------------------------------------------------------------------------------*

  PROCEDURE Get_BP_Reaction_Times
    (P_RTL_Line_Id        IN  Gx_OKS_Id
    ,P_Request_Date       IN  DATE
    ,P_TimeType_Category  IN  Varchar2 --Gx_TimeType_Category
    ,P_ReactDay_DispFmt   IN  VARCHAR2
    ,P_Set_ExcepionStack  IN  Gx_Boolean
    ,X_Reaction_Attribs   out nocopy GT_Bp_Reactions
    ,X_Result             out nocopy Gx_Boolean
    ,X_Return_Status      out nocopy Gx_Ret_Sts)
  IS

    CURSOR Lx_Csr_React_Attribs(Cx_RTLLine_Id IN Gx_OKS_Id,Cx_TimeType_Category IN Varchar2)  IS
      SELECT OAT.SUN_DURATION SUN_DURATION,
             OAT.MON_DURATION MON_DURATION,
             OAT.TUE_DURATION TUE_DURATION,
             OAT.WED_DURATION WED_DURATION,
             OAT.THU_DURATION THU_DURATION,
             OAT.FRI_DURATION FRI_DURATION,
             OAT.SAT_DURATION SAT_DURATION,
             OAT.UOM_CODE UOM_CODE
       FROM Oks_action_time_types OATT
           ,Oks_action_times OAT
      WHERE OATT.Cle_Id = Cx_RTLLine_Id
        AND OATT.action_type_code = Cx_TimeType_Category
        AND OAT.cov_action_type_id = OATT.Id;

    -- Added by JVARGHES on Mar 07, 2005.
    -- for the resolution of Bug# 4191909.
    -- Created seperate Cursor for bug fix #5546615 hmnair
    /* CURSOR c_NLS_Day(Cd_Request_Date IN DATE, Cv_USA_DY_Char IN VARCHAR2) IS
      SELECT TO_CHAR(NEXT_DAY(Cd_Request_Date,Get_NLS_Day_Of_Week(Cv_USA_DY_Char)),'DY')React_Day_Char
            ,TO_CHAR(NEXT_DAY(Cd_Request_Date,Get_NLS_Day_Of_Week(Cv_USA_DY_Char)),'D') React_Day_Num
            , DECODE(SIGN((TO_NUMBER(TO_CHAR(NEXT_DAY(Cd_Request_Date,Get_NLS_Day_Of_Week(Cv_USA_DY_Char)),'D')) - TO_NUMBER(TO_CHAR(Cd_Request_Date,'D')))+1),1
                   ,TO_NUMBER(TO_CHAR(NEXT_DAY(Cd_Request_Date,Get_NLS_Day_Of_Week(Cv_USA_DY_Char)),'D')) - TO_NUMBER(TO_CHAR(Cd_Request_Date,'D'))
                   ,TO_NUMBER(TO_CHAR(NEXT_DAY(Cd_Request_Date,Get_NLS_Day_Of_Week(Cv_USA_DY_Char)),'D')) - TO_NUMBER(TO_CHAR(Cd_Request_Date,'D')) + 7) ReqDay_Relative
      FROM DUAL; */

      CURSOR c_NLS_Day(Cd_Request_Date IN DATE, Cv_USA_DY_Char IN VARCHAR2) IS
      SELECT TO_CHAR(NEXT_DAY(Cd_Request_Date,Cv_USA_DY_Char),'DY')React_Day_Char
            ,TO_CHAR(NEXT_DAY(Cd_Request_Date,Cv_USA_DY_Char),'D') React_Day_Num
            , DECODE(SIGN((TO_NUMBER(TO_CHAR(NEXT_DAY(Cd_Request_Date,Cv_USA_DY_Char),'D')) - TO_NUMBER(TO_CHAR(Cd_Request_Date,'D')))+1),1
                   ,TO_NUMBER(TO_CHAR(NEXT_DAY(Cd_Request_Date,Cv_USA_DY_Char),'D')) - TO_NUMBER(TO_CHAR(Cd_Request_Date,'D'))
                   ,TO_NUMBER(TO_CHAR(NEXT_DAY(Cd_Request_Date,Cv_USA_DY_Char),'D')) - TO_NUMBER(TO_CHAR(Cd_Request_Date,'D')) + 7) ReqDay_Relative
      FROM DUAL;


    --

    Lx_RTL_Line_Id          CONSTANT Gx_OKS_Id := P_RTL_Line_Id;
    Ld_Request_Date         CONSTANT DATE := P_Request_Date;
    Lx_TimeType_Category    CONSTANT varchar2(30) := P_TimeType_Category;
    Lv_CovDay_DispFmt       CONSTANT VARCHAR2(15) := P_ReactDay_DispFmt;
    Lx_Set_ExcepionStack    CONSTANT Gx_Boolean := P_Set_ExcepionStack;

    Lx_Reaction_Attribs     GT_Bp_Reactions;
    Lx_Result               Gx_Boolean;
    Lx_Return_Status        Gx_Ret_Sts;
    Lx_ExcepionMsg          Gx_ExceptionMsg;

    Li_TableIdx             BINARY_INTEGER;
    Lx_Request_date_Num     number;
    Li_RowCount             INTEGER(10);
    week_ctr                number;

    -- Added by JVARGHES on Mar 07, 2005.
    -- for the resolution of Bug# 4191909.

    Lv_React_Day_NLS_Char   VARCHAR2(30);
    Ln_React_Day_Num        NUMBER;
    Ln_Req_Day_Relative     NUMBER;

    --

    Lx_Sort_Tab             GT_Bp_Reactions;

    Li_TableIdx_Out         BINARY_INTEGER;
    Li_TableIdx_In          BINARY_INTEGER;

    Lx_Temp_ReacAttribs     GR_Bp_Reaction;

    Lv_Composit_Val1        number;
    Lv_Composit_Val2        number;

    L_EXCEP_NO_REACT_TIME   EXCEPTION;

  BEGIN

    Lx_Result               := G_TRUE;
    Lx_Return_Status        := G_RET_STS_SUCCESS;

    Lx_Request_date_Num     := 0;
    Li_RowCount             := 0;
    week_ctr                := 0;

    Li_TableIdx := 0;

    Lx_Request_date_Num := to_number(to_char(Ld_Request_Date,'D'));

    FOR Idx IN Lx_Csr_React_Attribs(Lx_RTL_Line_Id,Lx_TimeType_Category)  LOOP

       if Idx.Sun_Duration is not null then

            Li_TableIdx   := Li_TableIdx + 1;

         -- Added by JVARGHES on Mar 07, 2005.
         -- for the resolution of Bug# 4191909.

            OPEN c_NLS_Day(Cd_Request_Date => Ld_Request_Date, Cv_USA_DY_Char => G_Rel_Sun);
            FETCH c_NLS_Day INTO Lv_React_Day_NLS_Char, Ln_React_Day_Num, Ln_Req_Day_Relative;
            CLOSE c_NLS_Day;

        --  Lx_Reaction_Attribs(Li_TableIdx).Rv_React_Day   := to_char(Ld_Request_Date-Lx_Request_date_Num+1,'DY'); --Idx.React_Day_Char;
            Lx_Reaction_Attribs(Li_TableIdx).Rv_React_Day   := Lv_React_Day_NLS_Char;
            Lx_Reaction_Attribs(Li_TableIdx).Rx_React_Durn  := Idx.Sun_Duration;
            Lx_Reaction_Attribs(Li_TableIdx).Rx_React_UOM   := Idx.UOM_Code;
        --  Lx_Reaction_Attribs(Li_TableIdx).Ri_React_Day   := 1; --Idx.React_Day_Num;
            Lx_Reaction_Attribs(Li_TableIdx).Ri_React_Day   := Ln_React_Day_Num;
            Lx_Reaction_Attribs(Li_TableIdx).Ri_ReqDay_Relative := Ln_Req_Day_Relative;

        /*
            if Lx_Request_date_Num <= 1 then
                Lx_Reaction_Attribs(Li_TableIdx).Ri_ReqDay_Relative  := 1-Lx_Request_date_Num; ----Idx.ReqDay_Relative;
            else
                Lx_Reaction_Attribs(Li_TableIdx).Ri_ReqDay_Relative  := 7-(Lx_Request_date_Num-1);
            end if;
        */

       end if;

       if Idx.Mon_Duration is not null then

            Li_TableIdx   := Li_TableIdx + 1;

         -- Added by JVARGHES on Mar 07, 2005.
         -- for the resolution of Bug# 4191909.

            OPEN c_NLS_Day(Cd_Request_Date => Ld_Request_Date, Cv_USA_DY_Char => G_Rel_Mon);
            FETCH c_NLS_Day INTO Lv_React_Day_NLS_Char, Ln_React_Day_Num, Ln_Req_Day_Relative;
            CLOSE c_NLS_Day;

         -- Lx_Reaction_Attribs(Li_TableIdx).Rv_React_Day        := to_char(Ld_Request_Date-Lx_Request_date_Num+2,'DY'); --Idx.React_Day_Char;
            Lx_Reaction_Attribs(Li_TableIdx).Rv_React_Day        := Lv_React_Day_NLS_Char;
            Lx_Reaction_Attribs(Li_TableIdx).Rx_React_Durn       := Idx.Mon_Duration;
            Lx_Reaction_Attribs(Li_TableIdx).Rx_React_UOM        := Idx.UOM_Code;
         -- Lx_Reaction_Attribs(Li_TableIdx).Ri_React_Day        := 2; --Idx.React_Day_Num;
            Lx_Reaction_Attribs(Li_TableIdx).Ri_React_Day        := Ln_React_Day_Num;
            Lx_Reaction_Attribs(Li_TableIdx).Ri_ReqDay_Relative  :=  Ln_Req_Day_Relative;

         /*
            if Lx_Request_date_Num <= 2 then
                Lx_Reaction_Attribs(Li_TableIdx).Ri_ReqDay_Relative  := 2-Lx_Request_date_Num; ----Idx.ReqDay_Relative;
            else
                Lx_Reaction_Attribs(Li_TableIdx).Ri_ReqDay_Relative  := 7-(Lx_Request_date_Num-2);
            end if;
         */

       end if;

       if Idx.Tue_Duration is not null then

            Li_TableIdx   := Li_TableIdx + 1;

         -- Added by JVARGHES on Mar 07, 2005.
         -- for the resolution of Bug# 4191909.

            OPEN c_NLS_Day(Cd_Request_Date => Ld_Request_Date, Cv_USA_DY_Char => G_Rel_Tue);
            FETCH c_NLS_Day INTO Lv_React_Day_NLS_Char, Ln_React_Day_Num, Ln_Req_Day_Relative;
            CLOSE c_NLS_Day;

         -- Lx_Reaction_Attribs(Li_TableIdx).Rv_React_Day        := to_char(Ld_Request_Date-Lx_Request_date_Num+3,'DY'); --Idx.React_Day_Char;
            Lx_Reaction_Attribs(Li_TableIdx).Rv_React_Day        := Lv_React_Day_NLS_Char;
            Lx_Reaction_Attribs(Li_TableIdx).Rx_React_Durn       := Idx.Tue_Duration;
            Lx_Reaction_Attribs(Li_TableIdx).Rx_React_UOM        := Idx.UOM_Code;
         -- Lx_Reaction_Attribs(Li_TableIdx).Ri_React_Day        := 3; --Idx.React_Day_Num;
            Lx_Reaction_Attribs(Li_TableIdx).Ri_React_Day        := Ln_React_Day_Num;
            Lx_Reaction_Attribs(Li_TableIdx).Ri_ReqDay_Relative  := Ln_Req_Day_Relative;

         /*
            if Lx_Request_date_Num <= 3 then
                Lx_Reaction_Attribs(Li_TableIdx).Ri_ReqDay_Relative  := 3-Lx_Request_date_Num; ----Idx.ReqDay_Relative;
            else
                Lx_Reaction_Attribs(Li_TableIdx).Ri_ReqDay_Relative  := 7-(Lx_Request_date_Num-3);
            end if;
         */


       end if;

       if Idx.Wed_Duration is not null then

           Li_TableIdx   := Li_TableIdx + 1;

         -- Added by JVARGHES on Mar 07, 2005.
         -- for the resolution of Bug# 4191909.

            OPEN c_NLS_Day(Cd_Request_Date => Ld_Request_Date, Cv_USA_DY_Char => G_Rel_Wed);
            FETCH c_NLS_Day INTO Lv_React_Day_NLS_Char, Ln_React_Day_Num, Ln_Req_Day_Relative;
            CLOSE c_NLS_Day;

         -- Lx_Reaction_Attribs(Li_TableIdx).Rv_React_Day        := to_char(Ld_Request_Date-Lx_Request_date_Num+4,'DY'); --Idx.React_Day_Char;
            Lx_Reaction_Attribs(Li_TableIdx).Rv_React_Day        := Lv_React_Day_NLS_Char;
            Lx_Reaction_Attribs(Li_TableIdx).Rx_React_Durn       := Idx.Wed_Duration;
            Lx_Reaction_Attribs(Li_TableIdx).Rx_React_UOM        := Idx.UOM_Code;
         -- Lx_Reaction_Attribs(Li_TableIdx).Ri_React_Day        := 4; --Idx.React_Day_Num;
            Lx_Reaction_Attribs(Li_TableIdx).Ri_React_Day        := Ln_React_Day_Num;
            Lx_Reaction_Attribs(Li_TableIdx).Ri_ReqDay_Relative  := Ln_Req_Day_Relative;

         /*
            if Lx_Request_date_Num <= 4 then
                Lx_Reaction_Attribs(Li_TableIdx).Ri_ReqDay_Relative  := 4-Lx_Request_date_Num; ----Idx.ReqDay_Relative;
            else
                Lx_Reaction_Attribs(Li_TableIdx).Ri_ReqDay_Relative  := 7-(Lx_Request_date_Num-4);
            end if;
         */

       end if;

       if Idx.Thu_Duration is not null then

           Li_TableIdx   := Li_TableIdx + 1;

         -- Added by JVARGHES on Mar 07, 2005.
         -- for the resolution of Bug# 4191909.

            OPEN c_NLS_Day(Cd_Request_Date => Ld_Request_Date, Cv_USA_DY_Char => G_Rel_Thu);
            FETCH c_NLS_Day INTO Lv_React_Day_NLS_Char, Ln_React_Day_Num, Ln_Req_Day_Relative;
            CLOSE c_NLS_Day;

         -- Lx_Reaction_Attribs(Li_TableIdx).Rv_React_Day        := to_char(Ld_Request_Date-Lx_Request_date_Num+5,'DY'); --Idx.React_Day_Char;
            Lx_Reaction_Attribs(Li_TableIdx).Rv_React_Day        := Lv_React_Day_NLS_Char;
            Lx_Reaction_Attribs(Li_TableIdx).Rx_React_Durn       := Idx.Thu_Duration;
            Lx_Reaction_Attribs(Li_TableIdx).Rx_React_UOM        := Idx.UOM_Code;
         -- Lx_Reaction_Attribs(Li_TableIdx).Ri_React_Day        := 5; --Idx.React_Day_Num;
            Lx_Reaction_Attribs(Li_TableIdx).Ri_React_Day        := Ln_React_Day_Num;
            Lx_Reaction_Attribs(Li_TableIdx).Ri_ReqDay_Relative  := Ln_Req_Day_Relative;

         /*
            if Lx_Request_date_Num <= 5 then
                Lx_Reaction_Attribs(Li_TableIdx).Ri_ReqDay_Relative  := 5-Lx_Request_date_Num; ----Idx.ReqDay_Relative;
            else
                Lx_Reaction_Attribs(Li_TableIdx).Ri_ReqDay_Relative  := 7-(Lx_Request_date_Num-5);
            end if;
         */

       end if;

       if Idx.Fri_Duration is not null then

           Li_TableIdx   := Li_TableIdx + 1;

         -- Added by JVARGHES on Mar 07, 2005.
         -- for the resolution of Bug# 4191909.

            OPEN c_NLS_Day(Cd_Request_Date => Ld_Request_Date, Cv_USA_DY_Char => G_Rel_Fri);
            FETCH c_NLS_Day INTO Lv_React_Day_NLS_Char, Ln_React_Day_Num, Ln_Req_Day_Relative;
            CLOSE c_NLS_Day;

         -- Lx_Reaction_Attribs(Li_TableIdx).Rv_React_Day        := to_char(Ld_Request_Date-Lx_Request_date_Num+6,'DY'); --Idx.React_Day_Char;
            Lx_Reaction_Attribs(Li_TableIdx).Rv_React_Day        := Lv_React_Day_NLS_Char;
            Lx_Reaction_Attribs(Li_TableIdx).Rx_React_Durn       := Idx.Fri_Duration;
            Lx_Reaction_Attribs(Li_TableIdx).Rx_React_UOM        := Idx.UOM_Code;
         -- Lx_Reaction_Attribs(Li_TableIdx).Ri_React_Day        := 6; --Idx.React_Day_Num;
            Lx_Reaction_Attribs(Li_TableIdx).Ri_React_Day        := Ln_React_Day_Num;
            Lx_Reaction_Attribs(Li_TableIdx).Ri_ReqDay_Relative  := Ln_Req_Day_Relative;

         /*
            if Lx_Request_date_Num <= 6 then
                Lx_Reaction_Attribs(Li_TableIdx).Ri_ReqDay_Relative  := 6-Lx_Request_date_Num; ----Idx.ReqDay_Relative;
            else
                Lx_Reaction_Attribs(Li_TableIdx).Ri_ReqDay_Relative  := 7-(Lx_Request_date_Num-6);
            end if;

         */

       end if;

       if Idx.Sat_Duration is not null then

           Li_TableIdx   := Li_TableIdx + 1;

         -- Added by JVARGHES on Mar 07, 2005.
         -- for the resolution of Bug# 4191909.

            OPEN c_NLS_Day(Cd_Request_Date => Ld_Request_Date, Cv_USA_DY_Char => G_Rel_Sat);
            FETCH c_NLS_Day INTO Lv_React_Day_NLS_Char, Ln_React_Day_Num, Ln_Req_Day_Relative;
            CLOSE c_NLS_Day;

         -- Lx_Reaction_Attribs(Li_TableIdx).Rv_React_Day        := to_char(Ld_Request_Date-Lx_Request_date_Num+7,'DY'); --Idx.React_Day_Char;
            Lx_Reaction_Attribs(Li_TableIdx).Rv_React_Day        := Lv_React_Day_NLS_Char;
            Lx_Reaction_Attribs(Li_TableIdx).Rx_React_Durn       := Idx.Sat_Duration;
            Lx_Reaction_Attribs(Li_TableIdx).Rx_React_UOM        := Idx.UOM_Code;
         -- Lx_Reaction_Attribs(Li_TableIdx).Ri_React_Day        := 7; --Idx.React_Day_Num;
            Lx_Reaction_Attribs(Li_TableIdx).Ri_React_Day        :=  Ln_React_Day_Num;
            Lx_Reaction_Attribs(Li_TableIdx).Ri_ReqDay_Relative  := Ln_Req_Day_Relative;

         /*
            if Lx_Request_date_Num <= 7 then
                Lx_Reaction_Attribs(Li_TableIdx).Ri_ReqDay_Relative  := 7-Lx_Request_date_Num; ----Idx.ReqDay_Relative;
            else
                Lx_Reaction_Attribs(Li_TableIdx).Ri_ReqDay_Relative  := 7-(Lx_Request_date_Num-7);
            end if;

         */

       end if;

       Li_RowCount   := Li_TableIdx;

    END LOOP;

    IF (Li_RowCount = 0 )  THEN

      Lx_ExcepionMsg := 'Reaction Time';
      RAISE L_EXCEP_NO_REACT_TIME;

    END IF;

    -- sorting based on relative to request date (Ri_ReqDay_Relative)

    Lx_Sort_Tab      := Lx_Reaction_Attribs;
    Li_TableIdx_Out  := Lx_Sort_Tab.FIRST;

    WHILE Li_TableIdx_Out IS NOT NULL LOOP
      Li_TableIdx_In  := Li_TableIdx_Out;
      WHILE Li_TableIdx_In IS NOT NULL LOOP
        Lv_Composit_Val1  := Lx_Sort_Tab(Li_TableIdx_Out).Ri_ReqDay_Relative;
        Lv_Composit_Val2  := Lx_Sort_Tab(Li_TableIdx_In).Ri_ReqDay_Relative;

        IF Lv_Composit_Val1 > Lv_Composit_Val2 THEN
          Lx_Temp_ReacAttribs           := Lx_Sort_Tab(Li_TableIdx_Out);
          Lx_Sort_Tab(Li_TableIdx_Out)  := Lx_Sort_Tab(Li_TableIdx_In);
          Lx_Sort_Tab(Li_TableIdx_In)   := Lx_Temp_ReacAttribs;
        END IF;

         Li_TableIdx_In  := Lx_Sort_Tab.NEXT(Li_TableIdx_In);
      END LOOP;
      Li_TableIdx_Out := Lx_Sort_Tab.NEXT(Li_TableIdx_Out);
    END LOOP;

    Lx_Reaction_Attribs.DELETE;
    Lx_Reaction_Attribs   := Lx_Sort_Tab;

    X_Reaction_Attribs := Lx_Reaction_Attribs;
    X_Result           := Lx_Result;
    X_Return_Status    := Lx_Return_Status;

  EXCEPTION

    WHEN L_EXCEP_NO_REACT_TIME THEN

      Lx_Result   := G_FALSE;

      IF Lx_Set_ExcepionStack = G_TRUE THEN

        OKC_API.SET_MESSAGE(p_app_name	    => G_APP_NAME_OKC
	  		   ,p_msg_name	    => G_REQUIRED_VALUE
			   ,p_token1	    => G_COL_NAME_TOKEN
			   ,p_token1_value  => Lx_ExcepionMsg);

        Lx_Return_Status  := G_RET_STS_ERROR;

      END IF;

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
	,P_Token2_Value   => 'Get_BP_Reaction_Times');

     X_Result            := G_FALSE;
     X_Return_Status     := G_RET_STS_UNEXP_ERROR;

  END Get_BP_Reaction_Times;

-----------------------------------------------------------------------------------------------------------------------*

  PROCEDURE Get_Reactn_Durn_In_Days
    (P_React_Durn	    IN  Gx_ReactDurn
    ,P_React_UOM 	    IN  Gx_ReactUOM
    ,P_Set_ExcepionStack    IN  Gx_Boolean
    ,X_React_Durn_In_Days   out nocopy NUMBER
    ,X_Result               out nocopy Gx_Boolean
    ,X_Return_Status        out nocopy Gx_Ret_Sts)
  IS

      CURSOR Lx_Csr_React_Tce_code(Lx_React_UOM IN VARCHAR2)  IS
      SELECT TCU.TCE_CODE Tce_Code
       FROM  Okx_Units_Of_Measure_V UOM
            ,Okc_Time_Code_Units_V TCU
       WHERE UOM.UOM_CODE = Lx_React_UOM
       AND   TCU.UOM_CODE = UOM.UOM_CODE
       AND   TCU.quantity = 1
       AND   TCU.tce_code = 'MINUTE';



    Lx_React_Durn           CONSTANT Gx_ReactDurn := NVL(P_React_Durn,0);
    Lx_React_UOM            CONSTANT Gx_ReactUOM  := P_React_UOM;
    Lx_Set_ExcepionStack    CONSTANT Gx_Boolean := P_Set_ExcepionStack;

    Ln_React_Durn_In_Days   NUMBER;
    Lx_Result               Gx_Boolean;
    Lx_Return_Status        Gx_Ret_Sts;
    Lx_ExcepionMsg          Gx_ExceptionMsg;
    Lx_count                NUMBER;

    L_EXCEP_UNKNOWN_UOM     EXCEPTION;



  BEGIN

    Lx_Result               := G_TRUE;
    Lx_Return_Status        := G_RET_STS_SUCCESS;

    Lx_count                := 0;

  FOR Lx_Csr_Rec in Lx_Csr_React_Tce_code(Lx_React_UOM) LOOP

   Lx_count := Lx_count + 1;

  END LOOP;

  IF Lx_count > 0 THEN

    Ln_React_Durn_In_Days := Lx_React_Durn/(24*60);

  ELSE

     RAISE L_EXCEP_UNKNOWN_UOM;

  END IF;

    X_React_Durn_In_Days  := Ln_React_Durn_In_Days;
    X_Result              := Lx_Result;
    X_Return_Status       := Lx_Return_Status;

  EXCEPTION

    WHEN  L_EXCEP_UNKNOWN_UOM THEN

      Lx_Result             := G_FALSE;

      IF Lx_Set_ExcepionStack = G_TRUE THEN

        OKC_API.SET_MESSAGE(p_app_name	    => G_APP_NAME_OKC
	  		   ,p_msg_name	    => G_INVALID_VALUE
			   ,p_token1	    => G_COL_NAME_TOKEN
			   ,p_token1_value  => Lx_ExcepionMsg);

        Lx_Return_Status  := G_RET_STS_ERROR;

      END IF;

      X_Result              := Lx_Result;
      X_Return_Status       := Lx_Return_Status;

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
	,P_Token2_Value   => 'Get_Reactn_Durn_In_Days');

      X_Result            := G_FALSE;
      X_Return_Status     := G_RET_STS_UNEXP_ERROR;

  END Get_Reactn_Durn_In_Days;

-----------------------------------------------------------------------------------------------------------------------*

  PROCEDURE Get_Cover_Day_Attribs
    (P_BP_CovTimes          IN  GT_Bp_CoverTimes
    ,P_Req_Cover_Date       IN  DATE --P_Req_Cover_Day        IN  INTEGER
    ,P_Set_ExcepionStack    IN  Gx_Boolean
    ,P_Check_Day            IN  Varchar2-- default 'N'
    ,X_Day_Cover_tbl        out nocopy Day_Cover_Tbl
    ,X_Result               out nocopy Gx_Boolean
    ,X_Return_Status        out nocopy Gx_Ret_Sts)
  IS
    Lx_BP_CovTimes          GT_Bp_CoverTimes;
    Li_Req_Cover_Day        INTEGER(1);
    Li_Req_Cover_Date       CONSTANT DATE := P_Req_Cover_Date;

    Lx_Set_ExcepionStack    CONSTANT Gx_Boolean := P_Set_ExcepionStack;
    Li_Check_Day            CONSTANT VARCHAR2(1) := nvl(P_Check_Day,'N');

    Lv_Day_Cover_From       VARCHAR2(25);
    Lv_Day_Cover_To         VARCHAR2(25);
    Li_Cover_Day            INTEGER(1);

    Lv_Day_Cover_Tbl        Day_Cover_Tbl; --VARCHAR2(6);
    Lv_DayCov_Ctr           number;

    Li_Coverage_Exists      varchar2(1);
    Li_Req_Cover_Date_Num   NUMBER;

    Lx_Result               Gx_Boolean;
    Lx_Return_Status        Gx_Ret_Sts;
    Li_Bp_CoverTbl_Idx      BINARY_INTEGER;

    Lx_Msg_TokenVal         Gx_ExceptionMsg;
    L_EXCEP_NO_COVER_TIME   EXCEPTION;
    L_EXCEP_NULL_VALUE      EXCEPTION;

  BEGIN

    Lx_BP_CovTimes          := P_BP_CovTimes;
    Lv_DayCov_Ctr           := 0;
    Li_Coverage_Exists      := 'N';

    Lx_Result               := G_TRUE;
    Lx_Return_Status        := G_RET_STS_SUCCESS;

    Li_Req_Cover_Day    :=  to_number(to_char(Li_Req_Cover_Date,'D'));
    Li_Bp_CoverTbl_Idx  :=  Lx_BP_CovTimes.FIRST;

    WHILE Li_Bp_CoverTbl_Idx IS NOT NULL LOOP

      IF Li_Check_Day = 'N' THEN

        IF Li_Coverage_Exists  = 'N' then

            Li_Req_Cover_Date_Num    := to_number(LPAD(to_char(Li_Req_Cover_Date,'HH24'),2,'0')||
                                        LPAD(to_char(Li_Req_Cover_Date,'MI'),2,'0'));
/*
            IF  ((Lx_BP_CovTimes(Li_Bp_CoverTbl_Idx).Ri_Cover_day = Li_Req_Cover_Day)
            and (Li_Req_Cover_Date_Num >= to_number(Lx_BP_CovTimes(Li_Bp_CoverTbl_Idx).Rv_Cover_From))
            and (Li_Req_Cover_Date_Num <= to_number(Lx_BP_CovTimes(Li_Bp_CoverTbl_Idx).Rv_Cover_To))) THEN
*/
            IF  ((Lx_BP_CovTimes(Li_Bp_CoverTbl_Idx).Ri_Cover_day = Li_Req_Cover_Day)
            and (Li_Req_Cover_Date_Num >= to_number(Lx_BP_CovTimes(Li_Bp_CoverTbl_Idx).Rv_Cover_From))
            and (Li_Req_Cover_Date_Num <= to_number(Lx_BP_CovTimes(Li_Bp_CoverTbl_Idx).Rv_Cover_To))) OR
            ((Lx_BP_CovTimes(Li_Bp_CoverTbl_Idx).Ri_Cover_day = Li_Req_Cover_Day)
            and (Li_Req_Cover_Date_Num <= to_number(Lx_BP_CovTimes(Li_Bp_CoverTbl_Idx).Rv_Cover_From))) THEN

                Li_Coverage_Exists  := 'Y';

                Lv_DayCov_Ctr   := Lv_DayCov_Ctr + 1;

                Lv_Day_Cover_Tbl(Lv_DayCov_Ctr).Day_Cover_From  := Lx_BP_CovTimes(Li_Bp_CoverTbl_Idx).Rv_Cover_From;
                Lv_Day_Cover_Tbl(Lv_DayCov_Ctr).Day_Cover_To    := Lx_BP_CovTimes(Li_Bp_CoverTbl_Idx).Rv_Cover_To;

            END IF;

         ELSE -- IF Li_Coverage_Exists  = 'Y' then

            IF  (Lx_BP_CovTimes(Li_Bp_CoverTbl_Idx).Ri_Cover_day = Li_Req_Cover_Day) THEN

                Li_Coverage_Exists  := 'Y';

                Lv_DayCov_Ctr   := Lv_DayCov_Ctr + 1;

                Lv_Day_Cover_Tbl(Lv_DayCov_Ctr).Day_Cover_From  := Lx_BP_CovTimes(Li_Bp_CoverTbl_Idx).Rv_Cover_From;
                Lv_Day_Cover_Tbl(Lv_DayCov_Ctr).Day_Cover_To    := Lx_BP_CovTimes(Li_Bp_CoverTbl_Idx).Rv_Cover_To;

            END IF;

         END IF;

      ELSE -- IF Li_Check_Day = 'Y' THEN

        IF  (Lx_BP_CovTimes(Li_Bp_CoverTbl_Idx).Ri_Cover_day = Li_Req_Cover_Day) THEN

            Li_Coverage_Exists  := 'Y';

            Lv_DayCov_Ctr   := Lv_DayCov_Ctr + 1;

            Lv_Day_Cover_Tbl(Lv_DayCov_Ctr).Day_Cover_From  := Lx_BP_CovTimes(Li_Bp_CoverTbl_Idx).Rv_Cover_From;
            Lv_Day_Cover_Tbl(Lv_DayCov_Ctr).Day_Cover_To    := Lx_BP_CovTimes(Li_Bp_CoverTbl_Idx).Rv_Cover_To;


        END IF;

      END IF;


      Li_Bp_CoverTbl_Idx   := Lx_BP_CovTimes.NEXT(Li_Bp_CoverTbl_Idx);

    END LOOP;


    IF Li_Coverage_Exists  = 'N'  THEN

      Lx_Msg_TokenVal   := 'Day Cover Time';
      RAISE L_EXCEP_NO_COVER_TIME;

    END IF;

    X_Day_Cover_Tbl       := Lv_Day_Cover_Tbl;
    X_Result              := Lx_Result;
    X_Return_Status       := Lx_Return_Status;

  EXCEPTION

    WHEN  L_EXCEP_NO_COVER_TIME  THEN

      Lx_Result         := G_FALSE;

      IF Lx_Set_ExcepionStack = G_TRUE THEN

        OKC_API.SET_MESSAGE(p_app_name	    => G_APP_NAME_OKC
	  		   ,p_msg_name	    => G_REQUIRED_VALUE
			   ,p_token1	    => G_COL_NAME_TOKEN
			   ,p_token1_value  => Lx_Msg_TokenVal);

        Lx_Return_Status  := G_RET_STS_ERROR;

      END IF;

      X_Result              := Lx_Result;
      X_Return_Status       := Lx_Return_Status;

    WHEN L_EXCEP_NULL_VALUE THEN

      X_Result              := Lx_Result;
      X_Return_Status       := Lx_Return_Status;

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
	,P_Token2_Value   => 'Get_Cover_Day_Attribs');

      X_Result            := G_FALSE;
      X_Return_Status     := G_RET_STS_UNEXP_ERROR;

  END Get_Cover_Day_Attribs;

-----------------------------------------------------------------------------------------------------------------------*
  PROCEDURE Compute_Day_React_By_DateTime
    (P_Req_DateTime	    IN  DATE
    ,P_Cover_EffStart       IN  DATE
    ,P_Cover_EffEnd         IN  DATE
    ,P_BP_Work_Through      IN  Gx_YesNo
    ,P_BP_Cover_Times       IN  GT_Bp_CoverTimes
    ,P_React_Durn_In_Days   IN  NUMBER
    ,P_Template_YN          IN  VARCHAR2
    ,P_Set_ExcepionStack    IN  Gx_Boolean
    ,P_Check_Day            IN  Varchar2
    ,X_React_By_DateTime    out nocopy DATE
    ,X_React_Start_DateTime out nocopy DATE
    ,X_Result               out nocopy Gx_Boolean
    ,X_Return_Status        out nocopy Gx_Ret_Sts)
  IS

    Ld_Req_DateTime         CONSTANT DATE := P_Req_DateTime;
    Ld_Cover_EffStart       CONSTANT DATE := P_Cover_EffStart;
    Ld_Cover_EffEnd         CONSTANT DATE := P_Cover_EffEnd;
    Lx_BP_Work_Through      CONSTANT Gx_YesNo := P_BP_Work_Through;
    Ln_React_Durn_In_Days   CONSTANT NUMBER := P_React_Durn_In_Days;
    Lx_BP_Cover_Times       GT_Bp_CoverTimes;
    Lx_Set_ExcepionStack    CONSTANT Gx_Boolean := P_Set_ExcepionStack;
    Lv_Template_YN          VARCHAR2(1);
    Lv_Check_Day            VARCHAR2(1);

    Ld_React_By_DateTime    DATE;
    Ld_React_Start_DateTime DATE;
    Lx_Result               Gx_Boolean;
    Lx_Return_Status        Gx_Ret_Sts;

    Lv_Day_Cover_From       VARCHAR2(25);
    Lv_Day_Cover_To         VARCHAR2(25);
    Lv_Day_Cover_Tbl        Day_Cover_Tbl; -- 11.5.10 mutiple time zone changes
    Lv_DayCov_Idx           BINARY_INTEGER; -- 11.5.10 mutiple time zone changes

    Ld_Day_Reactn_Start     DATE;
    Ld_Day_Reactn_End       DATE;
    Ld_Day_Reactn_EffStart  DATE;

    Li_Balance_ReactTime    NUMBER;
    Ld_Run_DateTime         DATE;
    Li_Run_React_Day        INTEGER(1);

    Li_LoopCount            INTEGER(1);

    L_EXCEP_NO_COVER_REMAINS EXCEPTION;
    L_EXCEP_NO_COVER_DEFINED EXCEPTION;
    L_EXCEP_UNEXPECTED_ERR   EXCEPTION;

  BEGIN

    Lx_BP_Cover_Times       := P_BP_Cover_Times;
    Lv_Check_Day            := nvl(P_Check_Day,'N');
    Lv_Template_YN          := nvl(P_Template_YN,'N');

    Lx_Result               := G_TRUE;
    Lx_Return_Status        := G_RET_STS_SUCCESS;

    Li_Balance_ReactTime    := Ln_React_Durn_In_Days;
    Ld_Run_DateTime         := Ld_Req_DateTime;

    Li_LoopCount            := 0;

--    dbms_output.put_line('Value of Ld_Run_DateTime='||to_char(Ld_Run_DateTime,'dd-mon-yyyy hh24:mi'));

    WHILE Li_Balance_ReactTime > 0 LOOP

--    dbms_output.put_line('Value of Li_Balance_ReactTime='||Li_Balance_ReactTime);

      Get_Cover_Day_Attribs
        (P_BP_CovTimes       => Lx_BP_Cover_Times
        ,P_Req_Cover_Date    => Ld_Run_DateTime --Li_Run_React_Day
        ,P_Set_ExcepionStack => G_FALSE
        ,P_Check_Day         => Lv_Check_Day
        ,X_Day_Cover_tbl     => Lv_Day_Cover_Tbl
        ,X_Result            => Lx_Result
        ,X_Return_Status     => Lx_Return_Status);


      IF Lx_Result = G_TRUE THEN

--dbms_output.put_line('Value of Li_LoopCount='||Li_LoopCount);

       Li_LoopCount    := 0;
       Lv_DayCov_Idx := Lv_Day_Cover_Tbl.FIRST;

--dbms_output.put_line('Value of Lv_DayCov_Idx='||Lv_DayCov_Idx);

       while Lv_DayCov_Idx is not null loop


        Ld_Day_Reactn_Start  := TO_DATE(TO_CHAR(Ld_Run_DateTime,'YYYYMMDD')||
                                    Lv_Day_Cover_Tbl(Lv_DayCov_Idx).Day_Cover_From,'YYYYMMDDHH24MISS');
        Ld_Day_Reactn_End    := TO_DATE(TO_CHAR(Ld_Run_DateTime,'YYYYMMDD')||
                                    Lv_Day_Cover_Tbl(Lv_DayCov_Idx).Day_Cover_To,'YYYYMMDDHH24MISS');


--dbms_output.put_line('Value of Ld_Run_DateTime='||to_char(Ld_Run_DateTime,'dd-mon-yyyy hh24:mi'));
--dbms_output.put_line('Value of Ld_Day_Reactn_Start='||to_char(Ld_Day_Reactn_Start,'dd-mon-yyyy hh24:mi'));
--dbms_output.put_line('Value of Ld_Day_Reactn_End='||to_char(Ld_Day_Reactn_End,'dd-mon-yyyy hh24:mi'));


        IF Ld_Run_DateTime <= Ld_Day_Reactn_End  THEN

          IF Ld_React_Start_DateTime IS NULL THEN

            IF Ld_Run_DateTime < Ld_Day_Reactn_Start THEN

                Ld_Day_Reactn_EffStart  := Ld_Day_Reactn_Start;

            ELSE

                Ld_Day_Reactn_EffStart  := Ld_Run_DateTime;

            END IF;

          ELSE

            Ld_Day_Reactn_EffStart  := Ld_Day_Reactn_Start;

          END IF;

--dbms_output.put_line('Value of Li_Balance_ReactTime='||Li_Balance_ReactTime);

          Ld_React_By_DateTime := Ld_Day_Reactn_EffStart + Li_Balance_ReactTime;

          IF NVL(Lx_BP_Work_Through,G_NO) = G_YES THEN

            Li_Balance_ReactTime  := 0;

          ELSE

            IF Ld_React_By_DateTime  > Ld_Day_Reactn_End  THEN

              Li_Balance_ReactTime := Ld_React_By_DateTime - Ld_Day_Reactn_End;
              Ld_React_By_DateTime := Ld_Day_Reactn_End;

            ELSE
              Li_Balance_ReactTime := 0;
            END IF;

          END IF;

--dbms_output.put_line('Value of Ld_Day_Reactn_EffStart='||to_char(Ld_Day_Reactn_EffStart,'dd-mon-yyyy hh24:mi'));
--dbms_output.put_line('Value of Ld_React_By_DateTime='||to_char(Ld_React_By_DateTime,'dd-mon-yyyy hh24:mi'));

--dbms_output.put_line('Value of Lv_Template_YN='||Lv_Template_YN);

          IF Lv_Template_YN = 'N' THEN -- for default coverage functionality

            Validate_Effectivity
            (P_Request_Date	    => Ld_React_By_DateTime
            ,P_Start_DateTime       => Ld_Cover_EffStart
            ,P_End_DateTime         => Ld_Cover_EffEnd
            ,P_Set_ExcepionStack    => Lx_Set_ExcepionStack
            ,P_CL_Msg_TokenValue    => 'Coverage'
            ,X_Result               => Lx_result
            ,X_Return_Status 	    => Lx_Return_Status);

            IF Lx_result <> G_TRUE THEN
                RAISE L_EXCEP_NO_COVER_REMAINS;
            END IF;

          END IF;

          IF Ld_React_Start_DateTime IS NULL THEN

            Ld_React_Start_DateTime := Ld_Day_Reactn_EffStart;

          END IF;

        END IF;


        if Li_Balance_ReactTime > 0 then
            Lv_DayCov_Idx := Lv_Day_Cover_Tbl.NEXT(Lv_DayCov_Idx);
        else
            exit; -- from loop
        end if;
       end loop;

      ELSE

        IF Lx_Return_Status = G_RET_STS_UNEXP_ERROR  THEN
          RAISE L_EXCEP_UNEXPECTED_ERR;
        END IF;

        Li_LoopCount    := Li_LoopCount + 1;

        IF Li_LoopCount > 7 THEN

          RAISE L_EXCEP_NO_COVER_DEFINED;

        END IF;

      END IF;

      Ld_Run_DateTime := TRUNC(Ld_Run_DateTime,'DD') + 1;
      Lv_Check_Day       := 'Y';

    END LOOP;

    IF Li_Balance_ReactTime > 0 THEN

      RAISE L_EXCEP_NO_COVER_DEFINED;

    END IF;

    X_React_By_DateTime    := Ld_React_By_DateTime;
    X_React_Start_DateTime := Ld_React_Start_DateTime;
    X_Result               := Lx_Result;
    X_Return_Status        := Lx_Return_Status;

  EXCEPTION

    WHEN L_EXCEP_UNEXPECTED_ERR OR L_EXCEP_NO_COVER_REMAINS THEN

      X_Result             := Lx_Result;
      X_Return_Status      := Lx_Return_Status;

    WHEN L_EXCEP_NO_COVER_DEFINED THEN

      Lx_Result := G_FALSE;

      IF Lx_Set_ExcepionStack = G_TRUE THEN

        OKC_API.SET_MESSAGE
          (p_app_name	  => G_APP_NAME_OKC
	  ,p_msg_name	  => G_REQUIRED_VALUE
	  ,p_token1	  => G_COL_NAME_TOKEN
	  ,p_token1_value => 'Day Cover Time');

        Lx_Return_Status := G_RET_STS_ERROR;

      END IF;

      X_Result            := Lx_Result;
      X_Return_Status     := Lx_Return_Status;

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
	,P_Token2_Value   => 'Compute_Day_React_By_DateTime');

     X_Result            := G_FALSE;
     X_Return_Status     := G_RET_STS_UNEXP_ERROR;

  END Compute_Day_React_By_DateTime;

-----------------------------------------------------------------------------------------------------------------------*
  PROCEDURE Compute_React_By_DateTime
    (P_Request_DateTime	    IN  DATE
    ,P_Cover_EffStart       IN  DATE
    ,P_Cover_EffEnd         IN  DATE
    ,P_BP_Work_Through      IN  Gx_YesNo
    ,P_BP_Cover_Times       IN  GT_Bp_CoverTimes
    ,P_Reaction_Attribs     IN  GT_Bp_Reactions
    ,P_Option               IN  VARCHAR2
    ,P_Template_YN          IN  VARCHAR2
    ,P_Set_ExcepionStack    IN  Gx_Boolean
    ,X_React_Durn	        out nocopy Gx_ReactDurn
    ,X_React_UOM 	        out nocopy Gx_ReactUOM
    ,X_React_Day            out nocopy VARCHAR2
    ,X_React_By_DateTime    out nocopy DATE
    ,X_React_Start_DateTime out nocopy DATE
    ,X_Result               out nocopy Gx_Boolean
    ,X_Return_Status        out nocopy Gx_Ret_Sts)
  IS

    Ld_Request_DateTime        CONSTANT DATE := P_Request_DateTime;
    Ld_Cover_EffStart          CONSTANT DATE := P_Cover_EffStart;
    Ld_Cover_EffEnd            CONSTANT DATE := P_Cover_EffEnd;
    Lx_BP_Work_Through         CONSTANT Gx_YesNo := P_BP_Work_Through;
    Lv_Option                  CONSTANT VARCHAR2(10) := P_Option;
    Lv_Template_YN             VARCHAR2(1);
    Lx_Set_ExcepionStack       CONSTANT Gx_Boolean := P_Set_ExcepionStack;

    Lx_Reaction_Attribs        GT_Bp_Reactions;
    Lx_BP_Cover_Times          GT_Bp_CoverTimes;

    Lx_React_Durn              Gx_ReactDurn;
    Lx_React_UOM               Gx_ReactUOM;
    Lv_React_Day               VARCHAR2(25);
    Ld_React_By_DateTime       DATE;
    Ld_React_Start_DateTime    DATE;

    Lx_React_Durn_X            Gx_ReactDurn;
    Lx_React_UOM_X             Gx_ReactUOM;
    Lv_React_Day_X             VARCHAR2(25);
    Ld_React_By_DateTime_X     DATE;
    Ld_React_Start_DateTime_X  DATE;

    Lx_Result                  Gx_Boolean;
    Lx_Return_Status           Gx_Ret_Sts;

    Li_React_Day               INTEGER(1);
    Li_ReqDay_Relative         INTEGER(1);

    Li_Bp_RactTbl_Idx          BINARY_INTEGER;
    Ld_Run_DateTime            DATE;

    Li_React_Durn_Days         NUMBER;
    Lv_Check_Day               VARCHAR2(1);

    L_EXCEP_UNEXPECTED_ERR     EXCEPTION;
    L_EXCEP_NO_COVER_REMAINS   EXCEPTION;
    L_EXCEP_NO_REACTION_TIME   EXCEPTION;

 BEGIN

    Lv_Template_YN             := nvl(P_Template_YN,'N');

    Lx_Reaction_Attribs        := P_Reaction_Attribs;
    Lx_BP_Cover_Times          := P_BP_Cover_Times;

    Lx_Result                  := G_TRUE;
    Lx_Return_Status           := G_RET_STS_SUCCESS;

    Li_Bp_RactTbl_Idx          := Lx_Reaction_Attribs.FIRST;
    Ld_Run_DateTime            := Ld_Request_DateTime;

    WHILE Li_Bp_RactTbl_Idx IS NOT NULL LOOP

      Lx_React_Durn      := Lx_Reaction_Attribs(Li_Bp_RactTbl_Idx).Rx_React_Durn;
      Lx_React_UOM       := Lx_Reaction_Attribs(Li_Bp_RactTbl_Idx).Rx_React_UOM;
      Li_React_Day       := Lx_Reaction_Attribs(Li_Bp_RactTbl_Idx).Ri_React_Day;
      Li_ReqDay_Relative := Lx_Reaction_Attribs(Li_Bp_RactTbl_Idx).Ri_ReqDay_Relative;
      Lv_React_Day       := Lx_Reaction_Attribs(Li_Bp_RactTbl_Idx).Rv_React_Day;

--      dbms_output.put_line('Value of Li_ReqDay_Relative='||Li_ReqDay_Relative);

      IF Li_React_Day IS NOT NULL AND Lx_React_Durn IS NOT NULL AND Lx_React_UOM IS NOT NULL THEN

        Get_Reactn_Durn_In_Days
          (P_React_Durn	         => Lx_React_Durn
          ,P_React_UOM 	         => Lx_React_UOM
          ,P_Set_ExcepionStack   => G_FALSE
          ,X_React_Durn_In_Days  => Li_React_Durn_Days
          ,X_Result              => Lx_Result
          ,X_Return_Status       => Lx_Return_Status);

        IF Lx_Result = G_TRUE THEN

          IF Li_ReqDay_Relative > 0 THEN
            Ld_Run_DateTime  := TRUNC(Ld_Run_DateTime,'DD') + Li_ReqDay_Relative;
            Lv_Check_Day     := 'Y';
          ELSE
            Lv_Check_Day     := 'N';
          END IF;

          EXIT WHEN Ld_React_By_DateTime_X <= Ld_Run_DateTime;


          IF Lv_Template_YN = 'N' THEN  -- for default coverage functionality

            Validate_Effectivity
            (P_Request_Date	    => Ld_Run_DateTime
            ,P_Start_DateTime       => Ld_Cover_EffStart
            ,P_End_DateTime         => Ld_Cover_EffEnd
            ,P_Set_ExcepionStack    => Lx_Set_ExcepionStack
            ,P_CL_Msg_TokenValue    => 'Coverage'
            ,X_Result               => Lx_result
            ,X_Return_Status 	    => Lx_Return_Status);

            IF Lx_result <> G_TRUE THEN
                RAISE L_EXCEP_NO_COVER_REMAINS;
            END IF;

          END IF;

--dbms_output.put_line('Value of Ld_Run_DateTime='||to_char(Ld_Run_DateTime,'dd-mon-yyyy hh24:mi'));
--dbms_output.put_line('Value of Ld_Cover_EffStart='||to_char(Ld_Cover_EffStart,'dd-mon-yyyy hh24:mi'));
--dbms_output.put_line('Value of Ld_Cover_EffEnd='||to_char(Ld_Cover_EffEnd,'dd-mon-yyyy hh24:mi'));
--dbms_output.put_line('Value of Lx_BP_Work_Through='||Lx_BP_Work_Through);
--dbms_output.put_line('Value of Li_React_Durn_Days='||Li_React_Durn_Days);
--dbms_output.put_line('Value of Lv_Template_YN='||Lv_Template_YN);

          Compute_Day_React_By_DateTime
            (P_Req_DateTime	    => Ld_Run_DateTime
            ,P_Cover_EffStart       => Ld_Cover_EffStart
            ,P_Cover_EffEnd         => Ld_Cover_EffEnd
            ,P_BP_Work_Through      => Lx_BP_Work_Through
            ,P_BP_Cover_Times       => Lx_BP_Cover_Times
            ,P_React_Durn_In_Days   => Li_React_Durn_Days
            ,P_Template_YN          => Lv_Template_YN -- for default coverage functionality
            ,P_Set_ExcepionStack    => G_FALSE
            ,P_Check_Day            => Lv_Check_Day
            ,X_React_By_DateTime    => Ld_React_By_DateTime
            ,X_React_Start_DateTime => Ld_React_Start_DateTime
            ,X_Result               => Lx_Result
            ,X_Return_Status        => Lx_Return_Status);

--dbms_output.put_line('Value of Ld_React_By_DateTime='||to_char(Ld_React_By_DateTime,'dd-mon-yyyy hh24:mi'));
--dbms_output.put_line('Value of Ld_React_Start_DateTime='||to_char(Ld_React_Start_DateTime,'dd-mon-yyyy hh24:mi'));


          IF Lx_Result <> G_TRUE  THEN
            RAISE L_EXCEP_UNEXPECTED_ERR;
          END IF;

          IF Ld_React_By_DateTime < Ld_React_By_DateTime_X OR Ld_React_By_DateTime_X IS NULL THEN
            Lx_React_Durn_X           := Lx_React_Durn;
            Lx_React_UOM_X            := Lx_React_UOM;
            Lv_React_Day_X            := Lv_React_Day;
            Ld_React_By_DateTime_X    := Ld_React_By_DateTime;
            Ld_React_Start_DateTime_X := Ld_React_Start_DateTime;
          END IF;

          IF Lv_Option = G_FIRST THEN
            EXIT;
          END IF;

        END IF;
      END IF;

      Li_Bp_RactTbl_Idx   := Lx_Reaction_Attribs.NEXT(Li_Bp_RactTbl_Idx);

    END LOOP;

    IF (Ld_React_By_DateTime_X IS NULL)
    THEN
      RAISE L_EXCEP_NO_REACTION_TIME;
    END IF;

    X_React_Durn	    := Lx_React_Durn_X;
    X_React_UOM 	    := Lx_React_UOM_X;
    X_React_Day             := Lv_React_Day_X;
    X_React_By_DateTime     := Ld_React_By_DateTime_X;
    X_React_Start_DateTime  := Ld_React_Start_DateTime_X;
    X_Result                := Lx_Result;
    X_Return_Status         := Lx_Return_Status;

  EXCEPTION

    WHEN L_EXCEP_UNEXPECTED_ERR OR L_EXCEP_NO_COVER_REMAINS THEN

      X_Result            := Lx_Result;
      X_Return_Status     := Lx_Return_Status;

    WHEN L_EXCEP_NO_REACTION_TIME THEN

      Lx_Result := G_FALSE;

      IF Lx_Set_ExcepionStack = G_TRUE THEN

        OKC_API.SET_MESSAGE
          (p_app_name	  => G_APP_NAME_OKC
	  ,p_msg_name	  => G_REQUIRED_VALUE
	  ,p_token1	  => G_COL_NAME_TOKEN
	  ,p_token1_value => 'Day Reaction Time');

        Lx_Return_Status := G_RET_STS_ERROR;

      END IF;

      X_Result            := Lx_Result;
      X_Return_Status     := Lx_Return_Status;

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
	,P_Token2_Value   => 'Compute_React_By_DateTime');

      X_Result            := G_FALSE;
      X_Return_Status     := G_RET_STS_UNEXP_ERROR;

  END Compute_React_By_DateTime;

-----------------------------------------------------------------------------------------------------------------------*
    /*vgujarat - modified for access hour ER 9675504*/
  PROCEDURE Get_ReactResol_By_DateTime
    (P_API_Version		IN  NUMBER
    ,P_Init_Msg_List		IN  VARCHAR2
    ,P_SVL_Id	        IN  Gx_OKS_Id -- can be service line id or coverage line id depending on P_Template_YN is 'N' or, 'Y'
    ,P_BusiProc_Id	        IN  Gx_BusProcess_Id
    ,P_Severity_Id		IN  Gx_Severity_Id
    ,P_Request_Date		IN  DATE
    ,P_Request_TZone_id		IN  Gx_TimeZoneId
    ,P_Dates_In_Input_TZ      IN VARCHAR2       -- Added for 12.0 ENT-TZ project (JVARGHES)
    ,P_template_YN              IN  VARCHAR2 -- for default coverage enhancement
    ,P_Option                   IN  VARCHAR2
    ,P_Rcn_Rsn_Flag             IN  VARCHAR2
    ,P_Set_ExcepionStack        IN  Gx_Boolean
    ,X_React_Durn	        out nocopy Gx_ReactDurn
    ,X_React_UOM 	        out nocopy Gx_ReactUOM
    ,X_React_Day                out nocopy VARCHAR2
    ,X_React_By_DateTime        out nocopy DATE
    ,X_React_Start_DateTime     out nocopy DATE
    ,X_Resolve_Durn	        out nocopy Gx_ReactDurn
    ,X_Resolve_UOM 	        out nocopy Gx_ReactUOM
    ,X_Resolve_Day              out nocopy VARCHAR2
    ,X_Resolve_By_DateTime      out nocopy DATE
    ,X_Resolve_Start_DateTime   out nocopy DATE
    ,X_Msg_count		OUT NOCOPY Number
    ,X_Msg_data			OUT NOCOPY Varchar2
    ,X_Result                   out nocopy Gx_Boolean
    ,X_Return_Status            out nocopy Gx_Ret_Sts
    ,P_cust_id                  IN NUMBER DEFAULT NULL
    ,P_cust_site_id             IN NUMBER DEFAULT NULL
    ,P_cust_loc_id              IN NUMBER DEFAULT NULL)
  IS

----------------------------11.5.10 multiple coverage time zone enhancements -------------------

    CURSOR Get_Cov_Timezones(P_BPL_Id in number) IS
       select  oct.id,
               oct.timezone_id,
               oct.default_yn,
               okslb.APPLY_DEFAULT_TIMEZONE
        from   okc_k_lines_b okclb,
               oks_k_lines_b okslb,
               oks_coverage_timezones oct
        where  okclb.id = P_BPL_Id
        and    okslb.cle_id = okclb.id
        and    oct.cle_id = okclb.id;

----------------------------11.5.10 multiple coverage time zone enhancements -------------------

    Lx_SVL_Id                  CONSTANT Gx_OKS_Id := P_SVL_Id;
    Lx_BusiProc_Id             CONSTANT Gx_BusProcess_Id := P_BusiProc_Id;
    Lx_Severity_Id             CONSTANT Gx_Severity_Id := P_Severity_Id;
    Ld_Request_Date            DATE;
    Lx_Request_TZone_Id        CONSTANT Gx_TimeZoneId := P_Request_TZone_id;
    Lx_ReactReso_ObjCode       CONSTANT Gx_JTOT_ObjCode := G_JTOT_OBJ_REACTIME;
    Lx_Set_ExcepionStack       CONSTANT Gx_Boolean := P_Set_ExcepionStack;
    Lv_Option                  CONSTANT VARCHAR2(10) := P_Option;
    Lv_Rcn_Rsn_Flag            CONSTANT Gx_Rule_Category := NVL(P_Rcn_Rsn_Flag,G_RUL_CATEGORY_REACT_RESOLVE);
    Lv_Template_YN             VARCHAR2(1); -- default coverage functionality

    /*vgujarat - modified for access hour ER 9675504*/
    Lx_cust_id                 CONSTANT NUMBER              := P_cust_id;
    Lx_cust_site_id            CONSTANT NUMBER              := P_cust_site_id;
    Lx_cust_loc_id             CONSTANT NUMBER              := P_cust_loc_id;

    Lx_React_Durn                Gx_ReactDurn;
    Lx_React_UOM                 Gx_ReactUOM;
    Lv_React_Day                 VARCHAR2(25);
    Ld_React_By_DateTime         DATE;
    Ld_React_Start_DateTime      DATE;
    Ld_TZ_React_By_DateTime      DATE;
    Ld_TZ_React_Start_DateTime   DATE;

    Lx_Resolve_Durn              Gx_ReactDurn;
    Lx_Resolve_UOM               Gx_ReactUOM;
    Lv_Resolve_Day               VARCHAR2(25);
    Ld_Resolve_By_DateTime       DATE;
    Ld_Resolve_Start_DateTime    DATE;
    Ld_TZ_Resolve_By_DateTime    DATE;
    Ld_TZ_Resolve_Start_DateTime DATE;

    Lx_Result                  Gx_Boolean;
    Lx_Result1                 Gx_Boolean;
    Lx_Result2                 Gx_Boolean;
    Lx_Result3                 Gx_Boolean;
    Lx_Result4                 Gx_Boolean;

    Lx_Return_Status           Gx_Ret_Sts;

    Ld_SVL_Start               DATE;
    Ld_SVL_End                 DATE;
    Ld_SVL_Terminated          DATE;
    Ld_SVL_EffEnd_Date         DATE;

    Lx_CVL_Id                  Gx_OKS_Id;
    Ld_CVL_Start               DATE;
    Ld_CVL_End                 DATE;
    Ld_CVL_Terminated          DATE;
    Ld_CVL_EffEnd_Date         DATE;

    Lx_BPL_Id                  Gx_OKS_Id;
    Ld_BPL_Start               DATE;
    Ld_BPL_End                 DATE;
    Ld_BPL_Terminated          DATE;
    Ld_BPL_EffEnd_Date         DATE;

--    Lx_BP_CVTRule_Id	       Gx_Rule_Id;
    Lx_BP_CVTLine_Id           Gx_OKS_Id;
    Lx_BP_Tz_Id                Gx_TimeZoneId;

    Ld_TzCont_Req_Date         DATE;

    Lx_RTL_Id                  Gx_OKS_Id;
    Ld_RTL_Start               DATE;
    Ld_RTL_End                 DATE;
    Ld_RTL_Terminated          DATE;

--    Lx_RTL_RCN_Rule_Id	       Gx_Rule_Id;
    Lx_RTL_RCN_Line_Id	       Gx_OKS_Id;  -- 11.5.10 addition for enhancements
    Lx_RTL_RCN_WT_YN           Gx_YesNo;
    Lx_RTL_RCN_Id              Gx_OKS_Id;
    Ld_RTL_RCN_Start           DATE;
    Ld_RTL_RCN_End             DATE;
    Ld_RTL_RCN_Terminated      DATE;

--    Lx_RTL_RSN_Rule_Id	       Gx_Rule_Id;
    Lx_RTL_RSN_Line_Id	       Gx_OKS_Id; -- 11.5.10 addition for enhancements
    Lx_RTL_RSN_WT_YN           Gx_YesNo;
    Lx_RTL_RSN_Id              Gx_OKS_Id;
    Ld_RTL_RSN_Start           DATE;
    Ld_RTL_RSN_End             DATE;
    Ld_RTL_RSN_Terminated      DATE;

    Ld_RTL_EffEnd_Date         DATE;

    Ld_Cont_EffStart           DATE;
    Ld_Cont_EffEnd             DATE;

    Lx_BP_CovTimes             GT_Bp_CoverTimes;
    Lx_Reaction_Attribs        GT_Bp_Reactions;
    Lx_Resolution_Attribs      GT_Bp_Reactions;

----------------------------11.5.10 multiple coverage time zone enhancements -------------------
    Lx_Use_TZE_Id              number;
    Lx_TZE_Mtch_Exists         varchar2(1);
    Lx_Def_TZE_Id              number;
    Lx_Apply_Def_Tze           varchar2(1);
    Lx_Use_TZE_Line_Id         number;
    Lx_Def_TZE_Line_Id         number;
----------------------------11.5.10 multiple coverage time zone enhancements -------------------

    L_EXCEP_NULL_VALUE         EXCEPTION;
    L_EXCEP_NO_DATA_FOUND      EXCEPTION;
    L_EXCEP_NOT_EFFECTIVE      EXCEPTION;
    L_EXCEP_UNEXPECTED_ERR     EXCEPTION;

    -- Added for 12.0 ENT-TZ project (JVARGHES)

    ln_Param_DatesTZ            NUMBER;
    ln_CovTZ                    NUMBER;

    -- Added for 12.0 Coverage Rearch project (JVARGHES)

    Lv_Std_Cov_YN              VARCHAR2(10);

    Ld_BPL_OFS_Start	       DATE;
    Ln_BPL_OFS_Duration	       NUMBER;
    Lv_BPL_OFS_UOM             VARCHAR2(100);
    --

  BEGIN

    Ld_Request_Date            := nvl(P_Request_Date,sysdate);
    Lv_Template_YN             := nvl(P_template_YN,'N'); -- default coverage functionality

    Lx_Result                  := G_TRUE;
    Lx_Result1                 := G_FALSE;
    Lx_Result2                 := G_FALSE;
    Lx_Result3                 := G_FALSE;
    Lx_Result4                 := G_FALSE;

    Lx_Return_Status           := G_RET_STS_SUCCESS;

    Validate_Required_RT_Tokens
      (P_SVL_Id	                => Lx_SVL_Id -- Lx_SVL_Id
      ,P_BusiProc_Id	        => Lx_BusiProc_id
      ,P_Severity_Id		=> Lx_Severity_Id
      ,P_Request_Date		=> Ld_Request_Date
      ,P_Request_TZone_id	=> Lx_Request_TZone_Id
      ,P_template_YN          => Lv_Template_YN -- for default coverage functionality
      ,P_Set_ExcepionStack      => Lx_Set_ExcepionStack
      ,X_Result                 => Lx_Result
      ,X_Return_Status 	        => Lx_Return_Status);

    IF Lx_Result <> G_TRUE  THEN
      RAISE L_EXCEP_NULL_VALUE;
    END IF;

    IF Lv_Template_YN = 'N' THEN

       -- Modified for 12.0 Coverage Rearch project (JVARGHES)
       --
       --   Validate_Service_Line
       --    (P_SVL_Id	              => Lx_SVL_Id --Lx_SVL_Id
       --    ,P_Set_ExcepionStack      => Lx_Set_ExcepionStack
       --    ,X_SVL_Start              => Ld_SVL_Start
       --    ,X_SVL_End                => Ld_SVL_End
       --    ,X_SVL_Terminated         => Ld_SVL_Terminated
       --    ,X_Result                 => Lx_Result
       --    ,X_Return_Status 	        => Lx_Return_Status);
       --
       -- Added for 12.0 Coverage Rearch project (JVARGHES)
       --

        Validate_Service_Line
         (P_SVL_Id	           => Lx_SVL_Id
         ,P_Set_ExcepionStack      => Lx_Set_ExcepionStack
         ,X_CVL_Id	           => Lx_CVL_Id
         ,X_Std_Cov_YN	           => Lv_Std_Cov_YN
         ,X_SVL_Start              => Ld_SVL_Start
         ,X_SVL_End                => Ld_SVL_End
         ,X_SVL_Terminated         => Ld_SVL_Terminated
         ,X_Result                 => Lx_Result
         ,X_Return_Status 	     => Lx_Return_Status);

        --

        IF Lx_Result <> G_TRUE  THEN
          RAISE L_EXCEP_NO_DATA_FOUND;
        END IF;

        Get_Effective_End_Date
        (P_Start_Date             => Ld_SVL_Start
        ,P_End_Date               => Ld_SVL_End
        ,P_Termination_Date       => Ld_SVL_Terminated
        ,P_EndDate_Required       => G_TRUE
        ,P_Set_ExcepionStack      => Lx_Set_ExcepionStack
        ,P_ExcepionMsg            => 'Service Line'
        ,X_EffEnd_Date            => Ld_SVL_EffEnd_Date
        ,X_Result                 => Lx_Result
        ,X_Return_Status  	    => Lx_Return_Status);

        IF Lx_Result <> G_TRUE  THEN
          RAISE L_EXCEP_NULL_VALUE;
        END IF;

    -- Added for 12.0 Coverage Rearch project (JVARGHES)

    ELSE

      Lx_CVL_Id  := Lx_SVL_Id;

    END IF;
    --
    --
    -- Modified for 12.0 Coverage Rearch project (JVARGHES)
    --
    -- Validate_Coverage_Line
    --  (P_SVL_Id	                => Lx_SVL_Id --Lx_SVL_Id
    --  ,P_Template_YN            => Lv_Template_YN -- for default coverage functionality
    --  ,P_Set_ExcepionStack      => Lx_Set_ExcepionStack
    --  ,X_CVL_Id                 => Lx_CVL_Id
    --  ,X_CVL_Start              => Ld_CVL_Start
    --  ,X_CVL_End                => Ld_CVL_End
    --  ,X_CVL_Terminated         => Ld_CVL_Terminated
    --  ,X_Result                 => Lx_Result
    --  ,X_Return_Status 	    => Lx_Return_Status);
    --
    -- Added for 12.0 Coverage Rearch project (JVARGHES)
    --

    Validate_Coverage_Line
     (P_CVL_Id	             => Lx_CVL_Id
     ,P_Set_ExcepionStack      => Lx_Set_ExcepionStack
     ,X_CVL_Start              => Ld_CVL_Start
     ,X_CVL_End                => Ld_CVL_End
     ,X_CVL_Terminated         => Ld_CVL_Terminated
     ,X_Result                 => Lx_Result
     ,X_Return_Status 	       => Lx_Return_Status);

    IF Lx_Result <> G_TRUE  THEN
      RAISE L_EXCEP_NO_DATA_FOUND;
    END IF;

    IF NVL(Lv_Std_Cov_YN,'*') = 'Y'
    THEN

      Ld_CVL_Start      := Ld_SVL_Start;
      Ld_CVL_End        := Ld_SVL_End;
      Ld_CVL_Terminated := Ld_SVL_Terminated;

    END IF;

    --
    --

    IF Lv_Template_YN = 'N' THEN -- for default coverage fucntionality

        Get_Effective_End_Date
         (P_Start_Date             => Ld_CVL_Start
         ,P_End_Date               => Ld_CVL_End
         ,P_Termination_Date       => Ld_CVL_Terminated
         ,P_EndDate_Required       => G_TRUE
         ,P_Set_ExcepionStack      => Lx_Set_ExcepionStack
         ,P_ExcepionMsg            => 'Coverage Line'
         ,X_EffEnd_Date            => Ld_CVL_EffEnd_Date
         ,X_Result                 => Lx_Result
         ,X_Return_Status  	     => Lx_Return_Status);

        IF Lx_Result <> G_TRUE  THEN
          RAISE L_EXCEP_NULL_VALUE;
        END IF;

    END IF;


    Validate_Contract_BP
      (P_CVL_Id	              => Lx_CVL_Id -- P_SVL_Id   => Lx_SVL_Id
      ,P_BP_Id	              => Lx_BusiProc_Id
      ,P_BP_ObjCode             => G_JTOT_OBJ_BUSIPROC
      ,P_Set_ExcepionStack      => Lx_Set_ExcepionStack
      ,X_BPL_Id                 => Lx_BPL_Id
      ,X_BPL_Start              => Ld_BPL_Start
      ,X_BPL_End                => Ld_BPL_End
      ,X_BPL_Terminated         => Ld_BPL_Terminated
      ,X_Result                 => Lx_Result
      ,X_Return_Status 	        => Lx_Return_Status);

      IF Lx_Result <> G_TRUE  THEN
        RAISE L_EXCEP_NO_DATA_FOUND;
      END IF;

    --
    -- Added for 12.0 Coverage Rearch project (JVARGHES)
    --

    IF NVL(Lv_Std_Cov_YN,'*') = 'Y'
    THEN

      Get_BP_Line_Start_Offset
       (P_BPL_Id	              => Lx_BPL_Id
       ,P_SVL_Start	        => Ld_SVL_Start
       ,X_BPL_OFS_Start	        => Ld_BPL_Start
       ,X_BPL_OFS_Duration	  => Ln_BPL_OFS_Duration
       ,X_BPL_OFS_UOM	        => Lv_BPL_OFS_UOM
       ,X_Return_Status 	  => Lx_Return_Status);

      IF X_Return_Status <> G_RET_STS_SUCCESS THEN
        RAISE L_EXCEP_NO_DATA_FOUND;
      END IF;

       Ld_BPL_End        := Ld_SVL_End;
       Ld_BPL_Terminated := Ld_SVL_Terminated;

    END IF;

    --

      IF Lv_Template_YN = 'N' THEN  -- for default coverage fucntionality

       Get_Effective_End_Date
        (P_Start_Date             => Ld_BPL_Start
        ,P_End_Date               => Ld_BPL_End
        ,P_Termination_Date       => Ld_BPL_Terminated
        ,P_EndDate_Required       => G_TRUE
        ,P_Set_ExcepionStack      => Lx_Set_ExcepionStack
        ,P_ExcepionMsg            => 'Business Process Line'
        ,X_EffEnd_Date            => Ld_BPL_EffEnd_Date
        ,X_Result                 => Lx_Result
        ,X_Return_Status  	      => Lx_Return_Status);

        IF Lx_Result <> G_TRUE  THEN
            RAISE L_EXCEP_NULL_VALUE;
        END IF;

       END IF;

----------------------------11.5.10 select coverage time zone starts -------------------

   Lx_Use_TZE_Id          := null;
   Lx_TZE_Mtch_Exists     := 'N';
   Lx_Def_TZE_Id          := null;
   Lx_Apply_Def_Tze       := null;
   Lx_Use_TZE_Line_Id     := null;
   Lx_Def_TZE_Line_Id     := null;

   for Cov_Timezones_rec in Get_Cov_Timezones(Lx_BPL_Id) loop

     if Lx_Request_TZone_Id = Cov_Timezones_rec.timezone_id then

       Lx_Use_TZE_Id        := Lx_Request_TZone_Id;
       Lx_TZE_Mtch_Exists   := 'Y';
       Lx_Use_TZE_Line_Id   := Cov_Timezones_rec.id;

       exit;

     end if;

     if Cov_Timezones_rec.default_yn =  'Y' then

       Lx_Def_TZE_Id        := Cov_Timezones_rec.timezone_id;
       Lx_Def_TZE_Line_Id   := Cov_Timezones_rec.id;

     end if;

     Lx_Apply_Def_Tze       := Cov_Timezones_rec.APPLY_DEFAULT_TIMEZONE;

   end loop;

   if Lx_Use_TZE_Id is null then

      if Lx_Apply_Def_Tze = 'Y' then

      -- Lx_Use_TZE_Id          := Lx_Def_TZE_Id;           -- Bug# 5137665
         Lx_Use_TZE_Id          := Lx_Request_TZone_Id;     -- Bug# 5137665
         Lx_TZE_Mtch_Exists     := 'Y';
         Lx_Use_TZE_Line_Id     := Lx_Def_TZE_Line_Id;

      end if;

   end if;

   if Lx_Use_TZE_Line_Id is null then

     Lx_Use_TZE_Line_Id     := Lx_Def_TZE_Line_Id;

   end if;

   -- Commented for 12.0 ENT-TZ project (JVARGHES)
   --
   --if Lx_Use_TZE_Id is null then
   --
   -- Convert_TimeZone
   --   (P_API_Version	        => P_API_Version
   --   ,P_Init_Msg_List          => P_Init_Msg_List
   --   ,P_Source_Date            => Ld_Request_Date
   --   ,P_Source_Tz_Id           => Lx_Request_TZone_Id
   --   ,P_Dest_Tz_Id             => Lx_Def_TZE_Id --Lx_BP_Tz_Id --11.5.10 multiple coverage time zone enhancements
   --   ,X_Dest_Date              => Ld_TzCont_Req_Date
   --   ,X_Msg_Count              => X_Msg_count
   --   ,X_Msg_Data		    => X_Msg_Data
   --   ,X_Return_Status 	    => Lx_Return_Status);
   --
   -- IF Lx_Return_Status <> G_RET_STS_SUCCESS  THEN
   --   RAISE L_EXCEP_NO_DATA_FOUND;
   -- END IF;
   --
   -- else
   --
   --     Ld_TzCont_Req_Date := Ld_Request_Date;
   --
   -- end if;
   --
   -- Added for 12.0 ENT-TZ project (JVARGHES)
   --

   IF NVL(P_DATES_IN_INPUT_TZ,'Y') =  'N' THEN
     ln_Param_DatesTZ :=  fnd_profile.VALUE ('SERVER_TIMEZONE_ID');
   ELSE
     ln_Param_DatesTZ :=  Lx_Request_TZone_id;
   END IF;

   ln_CovTZ           := NVL(Lx_Use_TZE_Id, Lx_Def_TZE_Id);

   IF NVL(ln_Param_DatesTZ,-99) = NVL(ln_CovTZ,-11)  THEN

      Ld_TzCont_Req_Date := Ld_Request_Date;

   ELSE

     Convert_TimeZone
      (P_API_Version	        => P_API_Version
      ,P_Init_Msg_List          => P_Init_Msg_List
      ,P_Source_Date            => Ld_Request_Date
      ,P_Source_Tz_Id           => ln_Param_DatesTZ
      ,P_Dest_Tz_Id             => ln_CovTZ
      ,X_Dest_Date              => Ld_TzCont_Req_Date
      ,X_Msg_Count              => X_Msg_count
      ,X_Msg_Data		        => X_Msg_Data
      ,X_Return_Status 	        => Lx_Return_Status);

     IF Lx_Return_Status <> G_RET_STS_SUCCESS  THEN
       RAISE L_EXCEP_NO_DATA_FOUND;
     END IF;

   END IF;

   --
   --
----------------------------11.5.10 select coverage time zone ends -------------------

    IF Lv_Template_YN = 'N' THEN  -- for default coverage functionality

      Validate_Effectivity
      (P_Request_Date	        => Ld_TzCont_Req_Date
      ,P_Start_DateTime         => Ld_SVL_Start
      ,P_End_DateTime           => Ld_SVL_EffEnd_Date
      ,P_Set_ExcepionStack      => Lx_Set_ExcepionStack
      ,P_CL_Msg_TokenValue      => 'Service Line'
      ,X_Result                 => Lx_Result
      ,X_Return_Status 	        => Lx_Return_Status);

      IF Lx_Result <> G_TRUE  THEN
        RAISE L_EXCEP_NOT_EFFECTIVE;
      END IF;

      Validate_Effectivity
      (P_Request_Date	        => Ld_TzCont_Req_Date
      ,P_Start_DateTime         => Ld_CVL_Start
      ,P_End_DateTime           => Ld_CVL_EffEnd_Date
      ,P_Set_ExcepionStack      => Lx_Set_ExcepionStack
      ,P_CL_Msg_TokenValue      => 'Coverage Line'
      ,X_Result                 => Lx_Result
      ,X_Return_Status 	        => Lx_Return_Status);

      IF Lx_Result <> G_TRUE  THEN
        RAISE L_EXCEP_NOT_EFFECTIVE;
      END IF;

      Validate_Effectivity
      (P_Request_Date	        => Ld_TzCont_Req_Date
      ,P_Start_DateTime         => Ld_BPL_Start
      ,P_End_DateTime           => Ld_BPL_EffEnd_Date
      ,P_Set_ExcepionStack      => Lx_Set_ExcepionStack
      ,P_CL_Msg_TokenValue      => 'Business Process Line'
      ,X_Result                 => Lx_Result
      ,X_Return_Status 	        => Lx_Return_Status);

      IF Lx_Result <> G_TRUE  THEN
        RAISE L_EXCEP_NOT_EFFECTIVE;
      END IF;

    END IF;

    IF Lv_Rcn_Rsn_Flag = G_RUL_CATEGORY_REACTION OR Lv_Rcn_Rsn_Flag = G_RUL_CATEGORY_REACT_RESOLVE THEN

      Get_BP_ReactResolTime_Line
        (P_BPL_Id	             => Lx_BPL_Id
        ,P_Severity_Id	         => Lx_Severity_Id
        ,P_TimeType_Category     => G_RUL_CATEGORY_REACTION
        ,P_Active_YN             => G_YES
        ,P_Set_ExcepionStack     => Lx_Set_ExcepionStack
        ,X_RTL_Id                => Lx_RTL_RCN_Id
        ,X_RTL_Start             => Ld_RTL_RCN_Start
        ,X_RTL_End               => Ld_RTL_RCN_End
        ,X_RTL_Terminated        => Ld_RTL_RCN_Terminated
        ,X_RTL_Line_Id	         => Lx_RTL_RCN_Line_Id
        ,X_RTL_WT_YN             => Lx_RTL_RCN_WT_YN
        ,X_Result                => Lx_Result1
        ,X_Return_Status 	     => Lx_Return_Status);

      IF Lx_Return_Status = G_RET_STS_UNEXP_ERROR  THEN
        Lx_Result         := Lx_Result1;
        RAISE L_EXCEP_UNEXPECTED_ERR;
      END IF;

    END IF;

    IF Lv_Rcn_Rsn_Flag = G_RUL_CATEGORY_RESOLUTION OR Lv_Rcn_Rsn_Flag = G_RUL_CATEGORY_REACT_RESOLVE THEN

      Get_BP_ReactResolTime_Line
        (P_BPL_Id	             => Lx_BPL_Id
        ,P_Severity_Id	         => Lx_Severity_Id
        ,P_TimeType_Category     => G_RUL_CATEGORY_RESOLUTION
        ,P_Active_YN             => G_YES
        ,P_Set_ExcepionStack     => Lx_Set_ExcepionStack
        ,X_RTL_Id                => Lx_RTL_RSN_Id
        ,X_RTL_Start             => Ld_RTL_RSN_Start
        ,X_RTL_End               => Ld_RTL_RSN_End
        ,X_RTL_Terminated        => Ld_RTL_RSN_Terminated
        ,X_RTL_Line_Id	         => Lx_RTL_RSN_Line_Id
        ,X_RTL_WT_YN             => Lx_RTL_RSN_WT_YN
        ,X_Result                => Lx_Result2
        ,X_Return_Status 	     => Lx_Return_Status);

      IF Lx_Return_Status = G_RET_STS_UNEXP_ERROR  THEN
        Lx_Result         := Lx_Result2;
        RAISE L_EXCEP_UNEXPECTED_ERR;
      END IF;

    END IF;

    IF Lx_Result1 = G_FALSE AND Lx_Result2 = G_FALSE THEN
      Lx_Result         := G_FALSE;
      RAISE L_EXCEP_NO_DATA_FOUND;
    ELSE
      Lx_Result         := G_TRUE;
    --Lx_Return_Status  := G_RET_STS_SUCCESS;
    END IF;

    IF Lx_Result1 = G_TRUE  THEN

      Lx_RTL_Id             := Lx_RTL_RCN_Id;
      Ld_RTL_Start          := Ld_RTL_RCN_Start;
      Ld_RTL_End            := Ld_RTL_RCN_End;
      Ld_RTL_Terminated     := Ld_RTL_RCN_Terminated;

    ELSIF Lx_Result2 = G_TRUE  THEN

      Lx_RTL_Id             := Lx_RTL_RSN_Id;
      Ld_RTL_Start          := Ld_RTL_RSN_Start;
      Ld_RTL_End            := Ld_RTL_RSN_End;
      Ld_RTL_Terminated     := Ld_RTL_RSN_Terminated;

    END IF;

    --
    -- Added for 12.0 Coverage Rearch project (JVARGHES)
    --

    IF NVL(Lv_Std_Cov_YN,'*') = 'Y'
    THEN

      Ld_RTL_Start      := Ld_BPL_Start;
      Ld_RTL_End        := Ld_BPL_End ;
      Ld_RTL_Terminated := Ld_BPL_Terminated;

    END IF;

    --

    IF Lv_Template_YN = 'N' THEN -- for default coverage functionality

      Get_Effective_End_Date
      (P_Start_Date             => Ld_RTL_Start
      ,P_End_Date               => Ld_RTL_End
      ,P_Termination_Date       => Ld_RTL_Terminated
      ,P_EndDate_Required       => G_FALSE
      ,P_Set_ExcepionStack      => Lx_Set_ExcepionStack
      ,P_ExcepionMsg            => 'Reaction/Resolution Time Line'
      ,X_EffEnd_Date            => Ld_RTL_EffEnd_Date
      ,X_Result                 => Lx_Result
      ,X_Return_Status  	=> Lx_Return_Status);

      IF Lx_Result <> G_TRUE  THEN
        RAISE L_EXCEP_NULL_VALUE;
      END IF;

      Validate_Effectivity
      (P_Request_Date	        => Ld_TzCont_Req_Date
      ,P_Start_DateTime         => Ld_RTL_Start
      ,P_End_DateTime           => Ld_RTL_EffEnd_Date
      ,P_Set_ExcepionStack      => Lx_Set_ExcepionStack
      ,P_CL_Msg_TokenValue      => 'Reaction/Resolution Time Line'
      ,X_Result                 => Lx_Result
      ,X_Return_Status 	        => Lx_Return_Status);

      IF Lx_Result <> G_TRUE  THEN
        RAISE L_EXCEP_NOT_EFFECTIVE;
      END IF;

     Get_Cont_Effective_Dates
      (P_SVL_Start             => Ld_SVL_Start
      ,P_SVL_End               => Ld_SVL_EffEnd_Date
      ,P_CVL_Start             => Ld_CVL_Start
      ,P_CVL_End               => Ld_CVL_EffEnd_Date
      ,P_BPL_Start             => Ld_BPL_Start
      ,P_BPL_End               => Ld_BPL_EffEnd_Date
      ,P_RTL_Start             => Ld_RTL_Start
      ,P_RTL_End               => Ld_RTL_EffEnd_Date
      ,P_Set_ExcepionStack     => Lx_Set_ExcepionStack
      ,X_Cont_EffStart         => Ld_Cont_EffStart
      ,X_Cont_EffEnd           => Ld_Cont_EffEnd
      ,X_Result                => Lx_Result
      ,X_Return_Status         => Lx_Return_Status);

      IF Lx_Result <> G_TRUE  THEN
        RAISE L_EXCEP_NOT_EFFECTIVE;
      END IF;

    END IF;

-- to include multiple time zones enhancement and architecture changes in 11.5.10
-- Lx_BP_CVTRule_Id is replaced by Lx_Use_TZE_Line_Id

    /*vgujarat - modified for access hour ER 9675504*/
    Get_BP_Cover_Times
      (P_BP_CVTLine_Id	      => Lx_Use_TZE_Line_Id -- Lx_BP_CVTRule_Id
      ,P_Request_Date         => Ld_TzCont_Req_Date
      ,P_CovDay_DispFmt       => 'DY'
      ,P_Set_ExcepionStack    => Lx_Set_ExcepionStack
      ,X_BP_CovTimes          => Lx_BP_CovTimes
      ,X_Result               => Lx_Result
      ,X_Return_Status        => Lx_Return_Status
      ,P_cust_id              => Lx_cust_id
      ,P_cust_site_id         => Lx_cust_site_id
      ,P_cust_loc_id          => Lx_cust_loc_id);
    IF Lx_Result <> G_TRUE  THEN
      RAISE L_EXCEP_NO_DATA_FOUND;
    END IF;

    --**Push Requset date to Next available Cover Day and Time.

    IF Lx_RTL_RCN_Line_Id IS NOT NULL THEN

      Get_BP_Reaction_Times
        (P_RTL_Line_Id          => Lx_RTL_RCN_Line_Id -- P_RTL_Rule_Id => Lx_RTL_RCN_Rule_Id--  11.5.10 changes
        ,P_Request_Date         => Ld_TzCont_Req_Date
        ,P_TimeType_Category    => 'RCN' -- 11.5.10 new addition
        ,P_ReactDay_DispFmt     => 'DY'
        ,P_Set_ExcepionStack    => Lx_Set_ExcepionStack
        ,X_Reaction_Attribs     => Lx_Reaction_Attribs
        ,X_Result               => Lx_Result3
        ,X_Return_Status        => Lx_Return_Status);


      IF Lx_Result3 = G_TRUE  THEN

        Compute_React_By_DateTime
          (P_Request_DateTime     => Ld_TzCont_Req_Date
          ,P_Cover_EffStart       => Ld_Cont_EffStart
          ,P_Cover_EffEnd         => Ld_Cont_EffEnd
          ,P_BP_Work_Through      => Lx_RTL_RCN_WT_YN
          ,P_BP_Cover_Times       => Lx_BP_CovTimes
          ,P_Reaction_Attribs     => Lx_Reaction_Attribs
          ,P_Option               => Lv_Option
          ,P_Template_YN          => Lv_template_YN -- default coverage
          ,P_Set_ExcepionStack    => Lx_Set_ExcepionStack
          ,X_React_Durn	          => Lx_React_Durn
          ,X_React_UOM 	          => Lx_React_UOM
          ,X_React_Day            => Lv_React_Day
          ,X_React_By_DateTime    => Ld_React_By_DateTime
          ,X_React_Start_DateTime => Ld_React_Start_DateTime
          ,X_Result               => Lx_Result
          ,X_Return_Status        => Lx_Return_Status);

       IF Lx_Result <> G_TRUE  THEN
         RAISE L_EXCEP_NO_DATA_FOUND;
       END IF;

  --
  -- Commented out for 12.0 ENT-TZ project (JVARGHES)
  --
  --     IF Lx_TZE_Mtch_Exists = 'N' then -- 11.5.10 multiple time zone enhancement
  --
  --      Convert_TimeZone
  --       (P_API_Version	         => P_API_Version
  --       ,P_Init_Msg_List        => P_Init_Msg_List
  --       ,P_Source_Date          => Ld_React_By_DateTime
  --       ,P_Source_Tz_Id         => Lx_Def_TZE_Id --Lx_BP_Tz_Id
  --       ,P_Dest_Tz_Id           => Lx_Request_TZone_Id
  --       ,X_Dest_Date            => Ld_TZ_React_By_DateTime
  --       ,X_Msg_Count            => X_Msg_count
  --       ,X_Msg_Data		     => X_Msg_Data
  --       ,X_Return_Status 	     => Lx_Return_Status);
  --
  --      IF Lx_Return_Status <> G_RET_STS_SUCCESS  THEN
  --        RAISE L_EXCEP_NO_DATA_FOUND;
  --      END IF;
  --
  --      Convert_TimeZone
  --       (P_API_Version	         => P_API_Version
  --       ,P_Init_Msg_List        => P_Init_Msg_List
  --       ,P_Source_Date          => Ld_React_Start_DateTime
  --       ,P_Source_Tz_Id         => Lx_Def_TZE_Id --Lx_BP_Tz_Id
  --       ,P_Dest_Tz_Id           => Lx_Request_TZone_Id
  --       ,X_Dest_Date            => Ld_TZ_React_Start_DateTime
  --       ,X_Msg_Count            => X_Msg_count
  --       ,X_Msg_Data		     => X_Msg_Data
  --       ,X_Return_Status 	     => Lx_Return_Status);
  --
  --      IF Lx_Return_Status <> G_RET_STS_SUCCESS  THEN
  --        RAISE L_EXCEP_NO_DATA_FOUND;
  --      END IF;
  --
  --    ELSE -- 11.5.10 multiple time zone enhancement
  --
  --        Ld_TZ_React_Start_DateTime := Ld_React_Start_DateTime;
  --        Ld_TZ_React_By_DateTime    := Ld_React_By_DateTime;
  --
  --     END IF;
  --
  --  Added for 12.0 ENT-TZ project (JVARGHES)
  --

   IF NVL(ln_Param_DatesTZ,-99) = NVL(ln_CovTZ,-11)  THEN

      Ld_TZ_React_By_DateTime    := Ld_React_By_DateTime;
      Ld_TZ_React_Start_DateTime := Ld_React_Start_DateTime;

   ELSE

     Convert_TimeZone
      (P_API_Version	        => P_API_Version
      ,P_Init_Msg_List          => P_Init_Msg_List
      ,P_Source_Date            => Ld_React_By_DateTime
      ,P_Source_Tz_Id           => ln_CovTZ
      ,P_Dest_Tz_Id             => ln_Param_DatesTZ
      ,X_Dest_Date              => Ld_TZ_React_By_DateTime
      ,X_Msg_Count              => X_Msg_count
      ,X_Msg_Data		        => X_Msg_Data
      ,X_Return_Status 	        => Lx_Return_Status);

     IF Lx_Return_Status <> G_RET_STS_SUCCESS  THEN
       RAISE L_EXCEP_NO_DATA_FOUND;
     END IF;

     Convert_TimeZone
      (P_API_Version	        => P_API_Version
      ,P_Init_Msg_List          => P_Init_Msg_List
      ,P_Source_Date            => Ld_React_Start_DateTime
      ,P_Source_Tz_Id           => ln_CovTZ
      ,P_Dest_Tz_Id             => ln_Param_DatesTZ
      ,X_Dest_Date              => Ld_TZ_React_Start_DateTime
      ,X_Msg_Count              => X_Msg_count
      ,X_Msg_Data		        => X_Msg_Data
      ,X_Return_Status 	        => Lx_Return_Status);

     IF Lx_Return_Status <> G_RET_STS_SUCCESS  THEN
       RAISE L_EXCEP_NO_DATA_FOUND;
     END IF;

   END IF;

  --
  --

      ELSE

        IF Lx_Return_Status = G_RET_STS_UNEXP_ERROR THEN
          RAISE L_EXCEP_UNEXPECTED_ERR;
        END IF;

      END IF;

    END IF;

    IF Lx_RTL_RSN_Line_Id IS NOT NULL THEN

      Get_BP_Reaction_Times
        (P_RTL_Line_Id          => Lx_RTL_RSN_Line_Id -- P_RTL_Rule_Id  => Lx_RTL_RSN_Rule_Id -- 11.5.10 changes
        ,P_Request_Date         => Ld_TzCont_Req_Date
        ,P_TimeType_Category    => 'RSN' -- 11.5.10 new addition
        ,P_ReactDay_DispFmt     => 'DY'
        ,P_Set_ExcepionStack    => Lx_Set_ExcepionStack
        ,X_Reaction_Attribs     => Lx_Resolution_Attribs
        ,X_Result               => Lx_Result4
        ,X_Return_Status        => Lx_Return_Status);

      IF Lx_Result4 = G_TRUE  THEN

        Compute_React_By_DateTime
          (P_Request_DateTime     => Ld_TzCont_Req_Date
          ,P_Cover_EffStart       => Ld_Cont_EffStart
          ,P_Cover_EffEnd         => Ld_Cont_EffEnd
          ,P_BP_Work_Through      => Lx_RTL_RSN_WT_YN
          ,P_BP_Cover_Times       => Lx_BP_CovTimes
          ,P_Reaction_Attribs     => Lx_Resolution_Attribs
          ,P_Option               => Lv_Option
          ,P_Template_YN          => Lv_template_YN -- default coverage
          ,P_Set_ExcepionStack    => Lx_Set_ExcepionStack
          ,X_React_Durn	          => Lx_Resolve_Durn
          ,X_React_UOM 	          => Lx_Resolve_UOM
          ,X_React_Day            => Lv_Resolve_Day
          ,X_React_By_DateTime    => Ld_Resolve_By_DateTime
          ,X_React_Start_DateTime => Ld_Resolve_Start_DateTime
          ,X_Result               => Lx_Result
          ,X_Return_Status        => Lx_Return_Status);

        IF Lx_Result <> G_TRUE  THEN
          RAISE L_EXCEP_NO_DATA_FOUND;
        END IF;


  --
  -- Commented out for 12.0 ENT-TZ project (JVARGHES)
  --
  --
  --      IF Lx_TZE_Mtch_Exists = 'N' then -- 11.5.10 multiple time zone enhancement
  --
  --       Convert_TimeZone
  --        (P_API_Version	      => P_API_Version
  --        ,P_Init_Msg_List        => P_Init_Msg_List
  --        ,P_Source_Date          => Ld_Resolve_By_DateTime
  --        ,P_Source_Tz_Id         => Lx_Def_TZE_Id --Lx_BP_Tz_Id
  --        ,P_Dest_Tz_Id           => Lx_Request_TZone_Id
  --        ,X_Dest_Date            => Ld_TZ_Resolve_By_DateTime
  --        ,X_Msg_Count            => X_Msg_count
  --        ,X_Msg_Data		      => X_Msg_Data
  --        ,X_Return_Status 	      => Lx_Return_Status);
  --
  --       IF Lx_Return_Status <> G_RET_STS_SUCCESS  THEN
  --        RAISE L_EXCEP_NO_DATA_FOUND;
  --       END IF;
  --
  --       Convert_TimeZone
  --        (P_API_Version	      => P_API_Version
  --        ,P_Init_Msg_List        => P_Init_Msg_List
  --        ,P_Source_Date          => Ld_Resolve_Start_DateTime
  --        ,P_Source_Tz_Id         => Lx_Def_TZE_Id --Lx_BP_Tz_Id
  --        ,P_Dest_Tz_Id           => Lx_Request_TZone_Id
  --        ,X_Dest_Date            => Ld_TZ_Resolve_Start_DateTime
  --        ,X_Msg_Count            => X_Msg_count
  --        ,X_Msg_Data		      => X_Msg_Data
  --        ,X_Return_Status 	      => Lx_Return_Status);
  --
  --       IF Lx_Return_Status <> G_RET_STS_SUCCESS  THEN
  --         RAISE L_EXCEP_NO_DATA_FOUND;
  --       END IF;
  --
  --      ELSE -- 11.5.10 multiple time zone enhancement
  --
  --         Ld_TZ_Resolve_Start_DateTime := Ld_Resolve_Start_DateTime;
  --         Ld_TZ_Resolve_By_DateTime    := Ld_Resolve_By_DateTime;
  --
  --      END IF;
  --
  --
  --  Added for 12.0 ENT-TZ project (JVARGHES)
  --

   IF NVL(ln_Param_DatesTZ,-99) = NVL(ln_CovTZ,-11)  THEN

      Ld_TZ_Resolve_By_DateTime    := Ld_Resolve_By_DateTime;
      Ld_TZ_Resolve_Start_DateTime := Ld_Resolve_Start_DateTime;


   ELSE

     Convert_TimeZone
      (P_API_Version	        => P_API_Version
      ,P_Init_Msg_List          => P_Init_Msg_List
      ,P_Source_Date            => Ld_Resolve_By_DateTime
      ,P_Source_Tz_Id           => ln_CovTZ
      ,P_Dest_Tz_Id             => ln_Param_DatesTZ
      ,X_Dest_Date              => Ld_TZ_Resolve_By_DateTime
      ,X_Msg_Count              => X_Msg_count
      ,X_Msg_Data		        => X_Msg_Data
      ,X_Return_Status 	        => Lx_Return_Status);

     IF Lx_Return_Status <> G_RET_STS_SUCCESS  THEN
       RAISE L_EXCEP_NO_DATA_FOUND;
     END IF;

     Convert_TimeZone
      (P_API_Version	        => P_API_Version
      ,P_Init_Msg_List          => P_Init_Msg_List
      ,P_Source_Date            => Ld_Resolve_Start_DateTime
      ,P_Source_Tz_Id           => ln_CovTZ
      ,P_Dest_Tz_Id             => ln_Param_DatesTZ
      ,X_Dest_Date              => Ld_TZ_Resolve_Start_DateTime
      ,X_Msg_Count              => X_Msg_count
      ,X_Msg_Data		        => X_Msg_Data
      ,X_Return_Status 	        => Lx_Return_Status);

     IF Lx_Return_Status <> G_RET_STS_SUCCESS  THEN
       RAISE L_EXCEP_NO_DATA_FOUND;
     END IF;

   END IF;

  --
  --
      ELSE

         IF Lx_Return_Status = G_RET_STS_UNEXP_ERROR THEN
           RAISE L_EXCEP_UNEXPECTED_ERR;
         END IF;

      END IF;

    END IF;

    IF Lx_Result3 = G_FALSE AND Lx_Result4 = G_FALSE THEN
      Lx_Result         := G_FALSE;
      RAISE L_EXCEP_NO_DATA_FOUND;
    END IF;

    X_React_Durn	        := Lx_React_Durn;
    X_React_UOM 	        := Lx_React_UOM;
    X_React_Day                 := Lv_React_Day;
    X_React_By_DateTime         := Ld_TZ_React_By_DateTime;
    X_React_Start_DateTime      := Ld_TZ_React_Start_DateTime;

    X_Resolve_Durn	        := Lx_Resolve_Durn;
    X_Resolve_UOM 	        := Lx_Resolve_UOM;
    X_Resolve_Day               := Lv_Resolve_Day;
    X_Resolve_By_DateTime       := Ld_TZ_Resolve_By_DateTime;
    X_Resolve_Start_DateTime    := Ld_TZ_Resolve_Start_DateTime;

    X_Result                    := Lx_Result;
    X_Return_Status             := Lx_Return_Status;

  EXCEPTION

    WHEN L_EXCEP_NULL_VALUE OR L_EXCEP_NO_DATA_FOUND OR L_EXCEP_NOT_EFFECTIVE OR L_EXCEP_UNEXPECTED_ERR THEN

      X_Result            := Lx_Result;
      X_Return_Status 	  := Lx_Return_Status;

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
	,P_Token2_Value   => 'Get_ReactResol_By_DateTime');

     X_Result            := G_FALSE;
     X_Return_Status     := G_RET_STS_UNEXP_ERROR;

  END Get_ReactResol_By_DateTime;

-----------------------------------------------------------------------------------------------------------------------*
    /*vgujarat - modified for access hour ER 9675504*/
  PROCEDURE Check_Reaction_Times
    (P_API_Version		IN  NUMBER
    ,P_Init_Msg_List		IN  VARCHAR2
    ,P_Business_Process_Id	IN  NUMBER
    ,P_Request_Date		IN  DATE
    ,P_Sr_Severity		IN  NUMBER
    ,P_Time_Zone_Id		IN  NUMBER
    ,P_Dates_In_Input_TZ      IN VARCHAR2    -- Added for 12.0 ENT-TZ project (JVARGHES)
    ,P_Contract_Line_Id	        IN  NUMBER
    ,X_Return_Status 		OUT NOCOPY VARCHAR2
    ,X_Msg_Count		OUT NOCOPY NUMBER
    ,X_Msg_Data			OUT NOCOPY VARCHAR2
    ,X_React_Within		OUT NOCOPY NUMBER
    ,X_React_TUOM		OUT NOCOPY VARCHAR2
    ,X_React_By_Date		OUT NOCOPY DATE
    ,P_cust_id                  IN NUMBER DEFAULT NULL
    ,P_cust_site_id             IN NUMBER DEFAULT NULL
    ,P_cust_loc_id              IN NUMBER DEFAULT NULL)
  IS

    Lv_React_Day                VARCHAR2(20);
    Ld_React_Start_DateTime     DATE;

    /*vgujarat - modified for access hour ER 9675504*/
    Lx_cust_id                 CONSTANT NUMBER              := P_cust_id;
    Lx_cust_site_id            CONSTANT NUMBER              := P_cust_site_id;
    Lx_cust_loc_id             CONSTANT NUMBER              := P_cust_loc_id;

    Lx_Resolve_Durn	        Gx_ReactDurn;
    Lx_Resolve_UOM 	        Gx_ReactUOM;
    Lv_Resolve_Day              VARCHAR2(20);
    Ld_Resolve_By_DateTime      DATE;
    Ld_Resolve_Start_DateTime   DATE;

    Lx_Result                   Gx_Boolean;

  BEGIN

    Lx_Result                   := G_TRUE;
    /*vgujarat - modified for access hour ER 9675504*/
    Get_ReactResol_By_DateTime
      (P_API_Version		=> P_API_Version
      ,P_Init_Msg_List		=> P_Init_Msg_List
      ,P_SVL_Id	            => P_Contract_Line_Id
      ,P_BusiProc_Id	      => P_Business_Process_Id
      ,P_Severity_Id		=> P_Sr_Severity
      ,P_Request_Date		=> P_Request_Date
      ,P_Request_TZone_id	=> P_Time_Zone_Id
	,P_Dates_In_Input_TZ    => P_Dates_In_Input_TZ   -- Added for 12.0 ENT-TZ project (JVARGHES)
      ,P_template_YN          => 'N'
      ,P_Option                 => G_FIRST
      ,P_Rcn_Rsn_Flag           => G_RUL_CATEGORY_REACTION
      ,P_Set_ExcepionStack      => G_TRUE
      ,X_React_Durn	        => X_React_Within
      ,X_React_UOM 	        => X_React_TUOM
      ,X_React_Day              => Lv_React_Day
      ,X_React_By_DateTime      => X_React_By_Date
      ,X_React_Start_DateTime   => Ld_React_Start_DateTime
      ,X_Resolve_Durn	        => Lx_Resolve_Durn
      ,X_Resolve_UOM 	        => Lx_Resolve_UOM
      ,X_Resolve_Day            => Lv_Resolve_Day
      ,X_Resolve_By_DateTime    => Ld_Resolve_By_DateTime
      ,X_Resolve_Start_DateTime => Ld_Resolve_Start_DateTime
      ,X_Msg_count		=> X_Msg_Count
      ,X_Msg_Data		=> X_Msg_Data
      ,X_Result                 => Lx_Result
      ,X_Return_Status          => X_Return_Status
      ,P_cust_id             => Lx_cust_id
      ,P_cust_site_id        => Lx_cust_site_id
      ,P_cust_loc_id         => Lx_cust_loc_id);

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
	,P_Token2_Value   => 'Check_Reaction_Times');

     X_Return_Status     := G_RET_STS_UNEXP_ERROR;

  END Check_Reaction_Times;

-----------------------------------------------------------------------------------------------------------------------*
   /*vgujarat - modified for access hour ER 9675504*/
  PROCEDURE get_react_resolve_by_time
    (p_api_version		in  number
    ,p_init_msg_list		in  varchar2
    ,p_inp_rec                  in  grt_inp_rec_type
    ,x_return_status 		out nocopy varchar2
    ,x_msg_count		out nocopy number
    ,x_msg_data			out nocopy varchar2
    ,x_react_rec                out nocopy rcn_rsn_rec_type
    ,x_resolve_rec              out nocopy rcn_rsn_rec_type)

  IS

    Lx_SVL_Id                  CONSTANT Gx_OKS_Id := p_inp_rec.Contract_Line_Id;
    Lx_BusiProc_Id             CONSTANT Gx_BusProcess_Id := p_inp_rec.Business_Process_Id;
    Lx_Severity_Id             CONSTANT Gx_Severity_Id := p_inp_rec.Severity_id;
    Ld_Request_Date            CONSTANT DATE := nvl(p_inp_rec.Request_Date,sysdate);
    Lx_Request_TZone_Id        CONSTANT Gx_TimeZoneId := p_inp_rec.Time_Zone_Id;
    Lx_ReactReso_ObjCode       CONSTANT Gx_JTOT_ObjCode := G_JTOT_OBJ_REACTIME;
    Lx_ReactReso_Category      CONSTANT Gx_Rule_Category := p_inp_rec.category_rcn_rsn;
    Lx_Set_ExcepionStack       CONSTANT Gx_Boolean := G_TRUE;
    Lv_Option                  CONSTANT VARCHAR2(10) := p_inp_rec.compute_option;

    /*vgujarat - modified for access hour ER 9675504*/
    Lx_cust_id                 CONSTANT NUMBER              := p_inp_rec.cust_id;
    Lx_cust_site_id            CONSTANT NUMBER              := p_inp_rec.cust_site_id;
    Lx_cust_loc_id             CONSTANT NUMBER              := p_inp_rec.cust_loc_id;

    Lx_React_Durn              Gx_ReactDurn;
    Lx_React_UOM               Gx_ReactUOM;
    Lv_React_Day               VARCHAR2(9);
    Ld_React_By_DateTime       DATE;
    Ld_React_Start_DateTime    DATE;

    Lx_Resol_Durn              Gx_ReactDurn;
    Lx_Resol_UOM               Gx_ReactUOM;
    Lv_Resol_Day               VARCHAR2(9);
    Ld_Resol_By_DateTime       DATE;
    Ld_Resol_Start_DateTime    DATE;

    Lx_Result                  Gx_Boolean;
    Lx_Return_Status           Gx_Ret_Sts;

    -- Added for 12.0 ENT-TZ project (JVARGHES)

    Lv_Dates_In_Input_TZ       CONSTANT VARCHAR2(1) := p_inp_rec.Dates_In_Input_TZ;
    --

  BEGIN

    Lx_Result                  := G_TRUE;
    Lx_Return_Status           := G_RET_STS_SUCCESS;
  /*vgujarat - modified for access hour ER 9675504*/
    Get_ReactResol_By_DateTime
      (P_API_Version  		    => P_API_Version
      ,P_Init_Msg_List	        => P_Init_Msg_List
      ,P_SVL_Id               => Lx_SVL_Id
      ,P_BusiProc_Id	        => Lx_BusiProc_Id
      ,P_Severity_Id	        => Lx_Severity_Id
      ,P_Request_Date	        => Ld_Request_Date
      ,P_Request_TZone_Id       => Lx_Request_TZone_Id
      ,P_Dates_In_Input_TZ      => Lv_Dates_In_Input_TZ  -- Added for 12.0 ENT-TZ project (JVARGHES)
      ,P_template_YN            => 'N'
      ,P_Option                 => Lv_Option
      ,P_Rcn_Rsn_Flag           => Lx_ReactReso_Category
      ,P_Set_ExcepionStack      => Lx_Set_ExcepionStack
      ,X_React_Durn	            => Lx_React_Durn
      ,X_React_UOM 	            => Lx_React_UOM
      ,X_React_Day              => Lv_React_Day
      ,X_React_By_DateTime      => Ld_React_By_DateTime
      ,X_React_Start_DateTime   => Ld_React_Start_DateTime
      ,X_Resolve_Durn	        => Lx_Resol_Durn
      ,X_Resolve_UOM 	        => Lx_Resol_UOM
      ,X_Resolve_Day            => Lv_Resol_Day
      ,X_Resolve_By_DateTime    => Ld_Resol_By_DateTime
      ,X_Resolve_Start_DateTime => Ld_Resol_Start_DateTime
      ,X_Msg_count		=> X_Msg_Count
      ,X_Msg_Data		=> X_Msg_Data
      ,X_Result                 => Lx_Result
      ,X_Return_Status          => Lx_Return_Status
      ,P_cust_id                => Lx_cust_id
      ,P_cust_site_id           => Lx_cust_site_id
      ,P_cust_loc_id            => Lx_cust_loc_id);

    x_react_rec.duration         :=  Lx_React_Durn;
    x_react_rec.uom              :=  Lx_React_UOM;
    x_react_rec.by_date_start    :=  Ld_React_Start_DateTime;
    x_react_rec.by_date_end      :=  Ld_React_By_DateTime;

    x_resolve_rec.duration       :=  Lx_Resol_Durn;
    x_resolve_rec.uom            :=  Lx_Resol_UOM;
    x_resolve_rec.by_date_start  :=  Ld_Resol_Start_DateTime;
    x_resolve_rec.by_date_end    :=  Ld_Resol_By_DateTime;

    x_return_status              :=  Lx_Return_Status;

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
	,P_Token2_Value   => 'get_react_resolve_by_time');

      X_Return_Status     := G_RET_STS_UNEXP_ERROR;

  END get_react_resolve_by_time;

-----------------------------------------------------------------------------------------------------------------------*

  PROCEDURE Validate_Required_CT_Tokens
    (P_SVL_Id	                IN  Gx_OKS_Id
    ,P_BusiProc_Id	        IN  Gx_BusProcess_Id
    ,P_Request_Date		IN  DATE
    ,P_Request_TZone_id		IN  Gx_TimeZoneId
    ,P_Set_ExcepionStack        IN  Gx_Boolean
    ,X_Result                   out nocopy Gx_Boolean
    ,X_Return_Status 	        out nocopy Gx_Ret_Sts)
  IS

    Lx_SVL_Id                 CONSTANT Gx_OKS_Id := P_SVL_Id;
    Lx_BusiProc_id            CONSTANT Gx_BusProcess_Id := P_BusiProc_Id;
    Ld_Request_Date           DATE;
    Lx_Request_TZone_Id       CONSTANT Gx_TimeZoneId := P_Request_TZone_id;
    Lx_Set_ExcepionStack      CONSTANT Gx_Boolean := P_Set_ExcepionStack;

    Lx_Result                 Gx_Boolean;
    Lx_Return_Status          Gx_Ret_Sts;

    L_EXCEP_NULL_VALUE        EXCEPTION;

  BEGIN

    Ld_Request_Date           := nvl(P_Request_Date,sysdate);

    Lx_Result                 := G_TRUE;
    Lx_Return_Status          := G_RET_STS_SUCCESS;

    Validate_Required_NumValue
      (P_Num_Value              => Lx_SVL_Id
      ,P_Set_ExcepionStack      => Lx_Set_ExcepionStack
      ,P_ExcepionMsg            => 'Contract Line'
      ,X_Result                 => Lx_result
      ,X_Return_Status   	=> Lx_Return_Status);

    IF Lx_result <> G_TRUE  THEN
       RAISE L_EXCEP_NULL_VALUE;
    END IF;

    Validate_Required_NumValue
      (P_Num_Value              => Lx_BusiProc_Id
      ,P_Set_ExcepionStack      => Lx_Set_ExcepionStack
      ,P_ExcepionMsg            => 'Business Process'
      ,X_Result                 => Lx_result
      ,X_Return_Status   	=> Lx_Return_Status);

    IF Lx_result <> G_TRUE  THEN
       RAISE L_EXCEP_NULL_VALUE;
    END IF;

    Validate_Required_NumValue
      (P_Num_Value              => Lx_Request_TZone_Id
      ,P_Set_ExcepionStack      => Lx_Set_ExcepionStack
      ,P_ExcepionMsg            => 'Time Zone'
      ,X_Result                 => Lx_result
      ,X_Return_Status   	=> Lx_Return_Status);

    IF Lx_result <> G_TRUE  THEN
       RAISE L_EXCEP_NULL_VALUE;
    END IF;

    Validate_Required_DateValue
      (P_Date_Value             => Ld_Request_Date
      ,P_Set_ExcepionStack      => Lx_Set_ExcepionStack
      ,P_ExcepionMsg            => 'Request Date'
      ,X_Result                 => Lx_result
      ,X_Return_Status   	=> Lx_Return_Status);

    IF Lx_result <> G_TRUE  THEN
       RAISE L_EXCEP_NULL_VALUE;
    END IF;

    X_Result          := Lx_Result;
    X_Return_Status   := Lx_Return_Status;

  EXCEPTION

    WHEN L_EXCEP_NULL_VALUE THEN

      X_Result        := Lx_Result;
      X_Return_Status := Lx_Return_Status;

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
	,P_Token2_Value   => 'Validate_Required_CT_Tokens');

      X_Result        := G_FALSE;
      X_Return_Status := G_RET_STS_UNEXP_ERROR;

  END Validate_Required_CT_Tokens;

-----------------------------------------------------------------------------------------------------------------------*

  PROCEDURE Get_Coverage_Times
    (P_API_Version		IN  NUMBER
    ,P_Init_Msg_List		IN  VARCHAR2
    ,P_SVL_Id	                IN  Gx_OKS_Id
    ,P_BusiProc_Id	        IN  Gx_BusProcess_Id
    ,P_Request_Date		IN  DATE
    ,P_Request_TZone_id		IN  Gx_TimeZoneId
    ,P_Dates_In_Input_TZ      IN VARCHAR2    -- Added for 12.0 ENT-TZ project (JVARGHES)
    ,P_Set_ExcepionStack        IN  Gx_Boolean
    ,X_Day_Cover_From           out nocopy DATE
    ,X_Day_Cover_To             out nocopy DATE
    ,X_Covered                  out nocopy Gx_Boolean
    ,X_Msg_count		OUT NOCOPY NUMBER
    ,X_Msg_data			OUT NOCOPY VARCHAR2
    ,X_Result                   out nocopy Gx_Boolean
    ,X_Return_Status            out nocopy Gx_Ret_Sts)
  IS


----------------------------11.5.10 multiple coverage time zone enhancements -------------------

    CURSOR Get_Cov_Timezones(P_BPL_Id in number) IS
       select  oct.id,
               oct.timezone_id,
               oct.default_yn,
               okslb.APPLY_DEFAULT_TIMEZONE
        from   okc_k_lines_b okclb,
               oks_k_lines_b okslb,
               oks_coverage_timezones oct
        where  okclb.id = P_BPL_Id
        and    okslb.cle_id = okclb.id
        and    oct.cle_id = okclb.id;

    Lx_Use_TZE_Id              number;
    Lx_TZE_Mtch_Exists         varchar2(1);
    Lx_Def_TZE_Id              number;
    Lx_Apply_Def_Tze           varchar2(1);
    Lx_Use_TZE_Line_Id         number;
    Lx_Def_TZE_Line_Id         number;

----------------------------11.5.10 multiple coverage time zone enhancements -------------------

    Lx_SVL_Id                  CONSTANT Gx_OKS_Id := P_SVL_Id;
    Lx_BusiProc_Id             CONSTANT Gx_BusProcess_Id := P_BusiProc_Id;
    Ld_Request_Date            DATE;
    Lx_Request_TZone_Id        CONSTANT Gx_TimeZoneId := P_Request_TZone_id;
    Lx_Set_ExcepionStack       CONSTANT Gx_Boolean := P_Set_ExcepionStack;
    Lv_Check_Day               VARCHAR2(1);

    Lv_Day_Cover_Tbl           Day_Cover_Tbl; -- 11.5.10 mutiple time zone changes
    Lv_DayCov_Idx              BINARY_INTEGER; -- 11.5.10 mutiple time zone changes


    Lv_Day_Cover_From          VARCHAR2(25);
    Lv_Day_Cover_To            VARCHAR2(25);

    Ld_Day_Cover_From          DATE;
    Ld_Day_Cover_To            DATE;
    Ld_Day_Cover_EffFrom       DATE;
    Ld_Day_Cover_EffTo         DATE;

    Ld_Tz_Day_Cover_From       DATE;
    Ld_Tz_Day_Cover_To         DATE;

    Lx_Covered                 Gx_Boolean;

    Lx_Result                  Gx_Boolean;
    Lx_Return_Status           Gx_Ret_Sts;

    Ld_SVL_Start               DATE;
    Ld_SVL_End                 DATE;
    Ld_SVL_Terminated          DATE;
    Ld_SVL_EffEnd_Date         DATE;

    Lx_CVL_Id                  Gx_OKS_Id;
    Ld_CVL_Start               DATE;
    Ld_CVL_End                 DATE;
    Ld_CVL_Terminated          DATE;
    Ld_CVL_EffEnd_Date         DATE;

    Lx_BPL_Id                  Gx_OKS_Id;
    Ld_BPL_Start               DATE;
    Ld_BPL_End                 DATE;
    Ld_BPL_Terminated          DATE;
    Ld_BPL_EffEnd_Date         DATE;

--    Lx_BP_CVTRule_Id	       Gx_Rule_Id;
    Lx_BP_Tz_Id                Gx_TimeZoneId;
    Ld_TzCont_Req_Date         DATE;
    Li_TzCont_Req_Date         INTEGER(1);

    Ld_Cont_EffStart           DATE;
    Ld_Cont_EffEnd             DATE;

    Lx_BP_CovTimes             GT_Bp_CoverTimes;

    Lx_ExcepionMsg             Gx_ExceptionMsg;

    L_EXCEP_NULL_VALUE         EXCEPTION;
    L_EXCEP_NO_DATA_FOUND      EXCEPTION;
    L_EXCEP_NOT_EFFECTIVE      EXCEPTION;
    L_EXCEP_UNEXPECTED_ERR     EXCEPTION;
    L_EXCEP_NO_DAY_COVER       EXCEPTION;

    -- Added for 12.0 ENT-TZ project (JVARGHES)

    ln_Param_DatesTZ            NUMBER;
    ln_CovTZ                    NUMBER;

    -- Added for 12.0 Coverage Rearch project (JVARGHES)

    Lv_Std_Cov_YN              VARCHAR2(10);
    Ld_BPL_OFS_Start	       DATE;
    Ln_BPL_OFS_Duration	       NUMBER;
    Lv_BPL_OFS_UOM             VARCHAR2(100);
    --

  BEGIN

    Ld_Request_Date            :=  nvl(P_Request_Date,sysdate);
    Lv_Check_Day               := 'N';

    Lx_Result                  := G_TRUE;
    Lx_Return_Status           := G_RET_STS_SUCCESS;

    G_GRACE_PROFILE_SET      := fnd_profile.value('OKS_ENABLE_GRACE_PERIOD');

    Validate_Required_CT_Tokens
      (P_SVL_Id	                => Lx_SVL_Id
      ,P_BusiProc_Id	        => Lx_BusiProc_id
      ,P_Request_Date		    => Ld_Request_Date
      ,P_Request_TZone_id	    => Lx_Request_TZone_Id
      ,P_Set_ExcepionStack      => Lx_Set_ExcepionStack
      ,X_Result                 => Lx_Result
      ,X_Return_Status 	        => Lx_Return_Status);

    IF Lx_Result <> G_TRUE  THEN
      RAISE L_EXCEP_NULL_VALUE;
    END IF;

   -- Modified for 12.0 Coverage Rearch project (JVARGHES)
   --
   -- Validate_Service_Line
   --   (P_SVL_Id	              => Lx_SVL_Id
   --   ,P_Set_ExcepionStack      => Lx_Set_ExcepionStack
   --   ,X_SVL_Start              => Ld_SVL_Start
   --   ,X_SVL_End                => Ld_SVL_End
   --   ,X_SVL_Terminated         => Ld_SVL_Terminated
   --   ,X_Result                 => Lx_Result
   --   ,X_Return_Status 	        => Lx_Return_Status);
   --
   -- Added for 12.0 Coverage Rearch project (JVARGHES)
   --

     Validate_Service_Line
        (P_SVL_Id	           => Lx_SVL_Id
        ,P_Set_ExcepionStack      => Lx_Set_ExcepionStack
        ,X_CVL_Id	           => Lx_CVL_Id
        ,X_Std_Cov_YN	           => Lv_Std_Cov_YN
        ,X_SVL_Start              => Ld_SVL_Start
        ,X_SVL_End                => Ld_SVL_End
        ,X_SVL_Terminated         => Ld_SVL_Terminated
        ,X_Result                 => Lx_Result
        ,X_Return_Status 	     => Lx_Return_Status);

   --

    IF Lx_Result <> G_TRUE  THEN
      RAISE L_EXCEP_NO_DATA_FOUND;
    END IF;

    Get_Effective_End_Date
      (P_Start_Date             => Ld_SVL_Start
      ,P_End_Date               => Ld_SVL_End
      ,P_Termination_Date       => Ld_SVL_Terminated
      ,P_EndDate_Required       => G_TRUE
      ,P_Set_ExcepionStack      => Lx_Set_ExcepionStack
      ,P_ExcepionMsg            => 'Service Line'
      ,X_EffEnd_Date            => Ld_SVL_EffEnd_Date
      ,X_Result                 => Lx_Result
      ,X_Return_Status  	=> Lx_Return_Status);


    IF Lx_Result <> G_TRUE  THEN
      RAISE L_EXCEP_NULL_VALUE;
    END IF;

    --
    -- Modified for 12.0 Coverage Rearch project (JVARGHES)
    --
    --
    --Validate_Coverage_Line
    --  (P_SVL_Id	              => Lx_SVL_Id
    -- ,P_template_YN            => 'N'
    --  ,P_Set_ExcepionStack      => Lx_Set_ExcepionStack
    --  ,X_CVL_Id                 => Lx_CVL_Id
    --  ,X_CVL_Start              => Ld_CVL_Start
    --  ,X_CVL_End                => Ld_CVL_End
    --  ,X_CVL_Terminated         => Ld_CVL_Terminated
    --  ,X_Result                 => Lx_Result
    --  ,X_Return_Status 	        => Lx_Return_Status);
    --
    -- Added for 12.0 Coverage Rearch project (JVARGHES)
    --

    Validate_Coverage_Line
     (P_CVL_Id	             => Lx_CVL_Id
     ,P_Set_ExcepionStack      => Lx_Set_ExcepionStack
     ,X_CVL_Start              => Ld_CVL_Start
     ,X_CVL_End                => Ld_CVL_End
     ,X_CVL_Terminated         => Ld_CVL_Terminated
     ,X_Result                 => Lx_Result
     ,X_Return_Status 	       => Lx_Return_Status);

    IF Lx_Result <> G_TRUE  THEN
      RAISE L_EXCEP_NO_DATA_FOUND;
    END IF;

    IF NVL(Lv_Std_Cov_YN,'*') = 'Y'
    THEN

      Ld_CVL_Start      := Ld_SVL_Start;
      Ld_CVL_End        := Ld_SVL_End;
      Ld_CVL_Terminated := Ld_SVL_Terminated;

    END IF;

    --
    --

    Get_Effective_End_Date
      (P_Start_Date             => Ld_CVL_Start
      ,P_End_Date               => Ld_CVL_End
      ,P_Termination_Date       => Ld_CVL_Terminated
      ,P_EndDate_Required       => G_TRUE
      ,P_Set_ExcepionStack      => Lx_Set_ExcepionStack
      ,P_ExcepionMsg            => 'Coverage Line'
      ,X_EffEnd_Date            => Ld_CVL_EffEnd_Date
      ,X_Result                 => Lx_Result
      ,X_Return_Status  	=> Lx_Return_Status);

    IF Lx_Result <> G_TRUE  THEN
      RAISE L_EXCEP_NULL_VALUE;
    END IF;

    Validate_Contract_BP
      (P_CVL_Id	              => Lx_CVL_Id    --P_SVL_Id	     => Lx_SVL_Id
      ,P_BP_Id	              => Lx_BusiProc_Id
      ,P_BP_ObjCode             => G_JTOT_OBJ_BUSIPROC
      ,P_Set_ExcepionStack      => Lx_Set_ExcepionStack
      ,X_BPL_Id                 => Lx_BPL_Id
      ,X_BPL_Start              => Ld_BPL_Start
      ,X_BPL_End                => Ld_BPL_End
      ,X_BPL_Terminated         => Ld_BPL_Terminated
      ,X_Result                 => Lx_Result
      ,X_Return_Status 	        => Lx_Return_Status);

    IF Lx_Result <> G_TRUE  THEN
      RAISE L_EXCEP_NO_DATA_FOUND;
    END IF;

    --
    -- Added for 12.0 Coverage Rearch project (JVARGHES)
    --

    IF NVL(Lv_Std_Cov_YN,'*') = 'Y'
    THEN

      Get_BP_Line_Start_Offset
       (P_BPL_Id	              => Lx_BPL_Id
       ,P_SVL_Start	        => Ld_SVL_Start
       ,X_BPL_OFS_Start	        => Ld_BPL_Start
       ,X_BPL_OFS_Duration	  => Ln_BPL_OFS_Duration
       ,X_BPL_OFS_UOM	        => Lv_BPL_OFS_UOM
       ,X_Return_Status 	  => Lx_Return_Status);

      IF X_Return_Status <> G_RET_STS_SUCCESS  THEN
        RAISE L_EXCEP_NO_DATA_FOUND;
      END IF;

       Ld_BPL_End        := Ld_SVL_End;
       Ld_BPL_Terminated := Ld_SVL_Terminated;

    END IF;

    --

    Get_Effective_End_Date
      (P_Start_Date             => Ld_BPL_Start
      ,P_End_Date               => Ld_BPL_End
      ,P_Termination_Date       => Ld_BPL_Terminated
      ,P_EndDate_Required       => G_TRUE
      ,P_Set_ExcepionStack      => Lx_Set_ExcepionStack
      ,P_ExcepionMsg            => 'Business Process Line'
      ,X_EffEnd_Date            => Ld_BPL_EffEnd_Date
      ,X_Result                 => Lx_Result
      ,X_Return_Status  	=> Lx_Return_Status);

    IF Lx_Result <> G_TRUE  THEN
      RAISE L_EXCEP_NULL_VALUE;
    END IF;

----------------------------11.5.10 select coverage time zone starts -------------------

    Lx_Use_TZE_Id          := null;
    Lx_TZE_Mtch_Exists     := 'N';
    Lx_Def_TZE_Id          := null;
    Lx_Apply_Def_Tze       := null;
    Lx_Use_TZE_Line_Id     := null;
    Lx_Def_TZE_Line_Id     := null;


   for Cov_Timezones_rec in Get_Cov_Timezones(Lx_BPL_Id) loop

    if Lx_Request_TZone_Id =  Cov_Timezones_rec.timezone_id then

     Lx_Use_TZE_Id          := Lx_Request_TZone_Id;
     Lx_TZE_Mtch_Exists     := 'Y';
     Lx_Use_TZE_Line_Id     := Cov_Timezones_rec.id;
     exit;

    end if;

    if Cov_Timezones_rec.default_yn =  'Y' then

     Lx_Def_TZE_Id          := Cov_Timezones_rec.timezone_id;
     Lx_Def_TZE_Line_Id     := Cov_Timezones_rec.id;

    end if;

    Lx_Apply_Def_Tze        := Cov_Timezones_rec.APPLY_DEFAULT_TIMEZONE;

   end loop;

   if Lx_Use_TZE_Id is null then

        if  Lx_Apply_Def_Tze = 'Y' then

            -- Lx_Use_TZE_Id          := Lx_Def_TZE_Id;  -- Bug# 5137665
               Lx_Use_TZE_Id          := Lx_Request_TZone_Id;
               Lx_TZE_Mtch_Exists     := 'Y';
               Lx_Use_TZE_Line_Id     := Lx_Def_TZE_Line_Id;
        end if;

   end if;

   if Lx_Use_TZE_Line_Id is null then

       Lx_Use_TZE_Line_Id     := Lx_Def_TZE_Line_Id;

   end if;

  --
  -- Commented out for 12.0 ENT-TZ project (JVARGHES)
  --
  --
  -- if Lx_Use_TZE_Id is null then
  --
  --  Convert_TimeZone
  --    (P_API_Version	        => P_API_Version
  --    ,P_Init_Msg_List          => P_Init_Msg_List
  --    ,P_Source_Date            => Ld_Request_Date
  --   ,P_Source_Tz_Id           => Lx_Request_TZone_Id
  --    ,P_Dest_Tz_Id             => Lx_Def_TZE_Id --Lx_BP_Tz_Id --11.5.10 multiple coverage time zone enhancements
  --    ,X_Dest_Date              => Ld_TzCont_Req_Date
  --    ,X_Msg_Count              => X_Msg_count
  --    ,X_Msg_Data		        => X_Msg_Data
  --    ,X_Return_Status 	        => Lx_Return_Status);
  --
  --  IF Lx_Return_Status <> G_RET_STS_SUCCESS  THEN
  --    RAISE L_EXCEP_NO_DATA_FOUND;
  --  END IF;
  --
  --  else
  --
  --      Ld_TzCont_Req_Date := Ld_Request_Date;
  --
  --  end if;
  --
  --
  --
  -- Added for 12.0 ENT-TZ project (JVARGHES)
  --

   IF NVL(P_DATES_IN_INPUT_TZ,'Y') =  'N' THEN
     ln_Param_DatesTZ :=  fnd_profile.VALUE ('SERVER_TIMEZONE_ID');
   ELSE
     ln_Param_DatesTZ :=  Lx_Request_TZone_id;
   END IF;

   ln_CovTZ           := NVL(Lx_Use_TZE_Id, Lx_Def_TZE_Id);

   IF NVL(ln_Param_DatesTZ,-99) = NVL(ln_CovTZ,-11)  THEN

      Ld_TzCont_Req_Date := Ld_Request_Date;

   ELSE

     Convert_TimeZone
      (P_API_Version	        => P_API_Version
      ,P_Init_Msg_List          => P_Init_Msg_List
      ,P_Source_Date            => Ld_Request_Date
      ,P_Source_Tz_Id           => ln_Param_DatesTZ
      ,P_Dest_Tz_Id             => ln_CovTZ
      ,X_Dest_Date              => Ld_TzCont_Req_Date
      ,X_Msg_Count              => X_Msg_count
      ,X_Msg_Data		        => X_Msg_Data
      ,X_Return_Status 	        => Lx_Return_Status);

     IF Lx_Return_Status <> G_RET_STS_SUCCESS  THEN
       RAISE L_EXCEP_NO_DATA_FOUND;
     END IF;

   END IF;

   --
   --

    Validate_Effectivity
      (P_Request_Date	        => Ld_TzCont_Req_Date
      ,P_Start_DateTime         => Ld_SVL_Start
      ,P_End_DateTime           => Ld_SVL_EffEnd_Date
      ,P_Set_ExcepionStack      => Lx_Set_ExcepionStack
      ,P_CL_Msg_TokenValue      => 'Service Line'
      ,X_Result                 => Lx_Result
      ,X_Return_Status 	        => Lx_Return_Status);

    IF Lx_Result <> G_TRUE  THEN
      RAISE L_EXCEP_NOT_EFFECTIVE;
    END IF;

    Validate_Effectivity
      (P_Request_Date	        => Ld_TzCont_Req_Date
      ,P_Start_DateTime         => Ld_CVL_Start
      ,P_End_DateTime           => Ld_CVL_EffEnd_Date
      ,P_Set_ExcepionStack      => Lx_Set_ExcepionStack
      ,P_CL_Msg_TokenValue      => 'Coverage Line'
      ,X_Result                 => Lx_Result
      ,X_Return_Status 	        => Lx_Return_Status);

    IF Lx_Result <> G_TRUE  THEN
      RAISE L_EXCEP_NOT_EFFECTIVE;
    END IF;

    Validate_Effectivity
      (P_Request_Date	        => Ld_TzCont_Req_Date
      ,P_Start_DateTime         => Ld_BPL_Start
      ,P_End_DateTime           => Ld_BPL_EffEnd_Date
      ,P_Set_ExcepionStack      => Lx_Set_ExcepionStack
      ,P_CL_Msg_TokenValue      => 'Business Process Line'
      ,X_Result                 => Lx_Result
      ,X_Return_Status 	        => Lx_Return_Status);

    IF Lx_Result <> G_TRUE  THEN
      RAISE L_EXCEP_NOT_EFFECTIVE;
    END IF;

    Get_BP_Cover_Times
      (P_BP_CVTLine_Id	      => Lx_Use_TZE_Line_Id -- Lx_BP_CVTRule_Id
      ,P_Request_Date         => Ld_TzCont_Req_Date
      ,P_CovDay_DispFmt       => 'DY'
      ,P_Set_ExcepionStack    => Lx_Set_ExcepionStack
      ,X_BP_CovTimes          => Lx_BP_CovTimes
      ,X_Result               => Lx_Result
      ,X_Return_Status        => Lx_Return_Status);

    IF Lx_Result <> G_TRUE  THEN
      RAISE L_EXCEP_NO_DATA_FOUND;
    END IF;


    Get_Cover_Day_Attribs
      (P_BP_CovTimes       => Lx_BP_CovTimes
      ,P_Req_Cover_Date    => Ld_TzCont_Req_Date --Li_Run_React_Day
      ,P_Set_ExcepionStack => G_FALSE
      ,P_Check_Day         => Lv_Check_Day
      ,X_Day_Cover_tbl     => Lv_Day_Cover_Tbl
      ,X_Result            => Lx_Result
      ,X_Return_Status     => Lx_Return_Status);

    IF Lx_Result <> G_TRUE  THEN
      RAISE L_EXCEP_NO_DATA_FOUND;
    END IF;

    Lv_DayCov_Idx := Lv_Day_Cover_Tbl.FIRST;

    Ld_Day_Cover_From  := TO_DATE(TO_CHAR(Ld_TzCont_Req_Date,'YYYYMMDD')||Lv_Day_Cover_Tbl(Lv_DayCov_Idx).Day_Cover_From,'YYYYMMDDHH24MISS');
    Ld_Day_Cover_To    := TO_DATE(TO_CHAR(Ld_TzCont_Req_Date,'YYYYMMDD')||Lv_Day_Cover_Tbl(Lv_DayCov_Idx).Day_Cover_To,'YYYYMMDDHH24MISS');

    Get_Cont_Effective_Dates
      (P_SVL_Start             => Ld_SVL_Start
      ,P_SVL_End               => Ld_SVL_EffEnd_Date
      ,P_CVL_Start             => Ld_CVL_Start
      ,P_CVL_End               => Ld_CVL_EffEnd_Date
      ,P_BPL_Start             => Ld_BPL_Start
      ,P_BPL_End               => Ld_BPL_EffEnd_Date
      ,P_RTL_Start             => NULL
      ,P_RTL_End               => NULL
      ,P_Set_ExcepionStack     => Lx_Set_ExcepionStack
      ,X_Cont_EffStart         => Ld_Cont_EffStart
      ,X_Cont_EffEnd           => Ld_Cont_EffEnd
      ,X_Result                => Lx_Result
      ,X_Return_Status         => Lx_Return_Status);

    IF Lx_Result <> G_TRUE  THEN
      RAISE L_EXCEP_NOT_EFFECTIVE;
    END IF;

    IF Ld_Day_Cover_From > Ld_Cont_EffEnd  THEN

      Lx_Covered  := G_FALSE;
      Lx_ExcepionMsg := 'Business Process - Cover Time';

      RAISE L_EXCEP_NO_DAY_COVER;

    ELSE

      IF Ld_Day_Cover_From > Ld_Cont_EffStart  THEN
        Ld_Day_Cover_EffFrom := Ld_Day_Cover_From;
      ELSE
        Ld_Day_Cover_EffFrom := Ld_Cont_EffStart;
      END IF;

      IF Ld_Day_Cover_To < Ld_Cont_EffEnd  THEN
        Ld_Day_Cover_EffTo   := Ld_Day_Cover_To;
      ELSE
        Ld_Day_Cover_EffTo   := Ld_Cont_EffEnd;
      END IF;

    END IF;

    Validate_Effectivity
      (P_Request_Date	        => Ld_TzCont_Req_Date
      ,P_Start_DateTime         => Ld_Day_Cover_EffFrom
      ,P_End_DateTime           => Ld_Day_Cover_EffTo
      ,P_Set_ExcepionStack      => G_FALSE
      ,P_CL_Msg_TokenValue      => 'Business Process'
      ,X_Result                 => Lx_Result
      ,X_Return_Status 	        => Lx_Return_Status);

    IF Lx_Result = G_TRUE  THEN

      Lx_Covered  := G_TRUE;

    ELSE

      Lx_Covered  := G_FALSE;

      IF Lx_Return_Status = G_RET_STS_UNEXP_ERROR THEN
        RAISE L_EXCEP_UNEXPECTED_ERR;
      END IF;

    END IF;


  --
  -- Commented out for 12.0 ENT-TZ project (JVARGHES)
  --
  --
  --  IF Lx_TZE_Mtch_Exists = 'N' then -- 11.5.10 multiple time zone enhancement
  --
  --      Convert_TimeZone
  --      (P_API_Version	          => P_API_Version
  --      ,P_Init_Msg_List          => P_Init_Msg_List
  --      ,P_Source_Date            => Ld_Day_Cover_EffFrom
  --      ,P_Source_Tz_Id           => Lx_Def_TZE_Id --Lx_BP_Tz_Id
  --      ,P_Dest_Tz_Id             => Lx_Request_TZone_Id
  --      ,X_Dest_Date              => Ld_Tz_Day_Cover_From
  --      ,X_Msg_Count              => X_Msg_count
  --      ,X_Msg_Data		          => X_Msg_Data
  --      ,X_Return_Status 	      => Lx_Return_Status);
  --
  --       IF Lx_Return_Status <> G_RET_STS_SUCCESS  THEN
  --         RAISE L_EXCEP_NO_DATA_FOUND;
  --       END IF;
  --
  --      Convert_TimeZone
  --      (P_API_Version	            => P_API_Version
  --      ,P_Init_Msg_List            => P_Init_Msg_List
  --      ,P_Source_Date              => Ld_Day_Cover_EffTo
  --      ,P_Source_Tz_Id             => Lx_Def_TZE_Id --Lx_BP_Tz_Id
  --      ,P_Dest_Tz_Id               => Lx_Request_TZone_Id
  --      ,X_Dest_Date                => Ld_Tz_Day_Cover_To
  --      ,X_Msg_Count                => X_Msg_count
  --      ,X_Msg_Data		            => X_Msg_Data
  --      ,X_Return_Status 	        => Lx_Return_Status);
  --
  --
  --       IF Lx_Return_Status <> G_RET_STS_SUCCESS  THEN
  --         RAISE L_EXCEP_NO_DATA_FOUND;
  --       END IF;
  --
  --       ELSE -- 11.5.10 multiple time zone enhancement
  --
  --         Ld_Tz_Day_Cover_From     := Ld_Day_Cover_EffFrom;
  --         Ld_Tz_Day_Cover_To       := Ld_Day_Cover_EffTo;
  --
  --      END IF;
  --
  --
  --  Added for 12.0 ENT-TZ project (JVARGHES)
  --
   IF NVL(ln_Param_DatesTZ,-99) = NVL(ln_CovTZ,-11)  THEN

      Ld_Tz_Day_Cover_From     := Ld_Day_Cover_EffFrom;
      Ld_Tz_Day_Cover_To       := Ld_Day_Cover_EffTo;

   ELSE

     Convert_TimeZone
      (P_API_Version	        => P_API_Version
      ,P_Init_Msg_List          => P_Init_Msg_List
      ,P_Source_Date            => Ld_Day_Cover_EffFrom
      ,P_Source_Tz_Id           => ln_CovTZ
      ,P_Dest_Tz_Id             => ln_Param_DatesTZ
      ,X_Dest_Date              => Ld_Tz_Day_Cover_From
      ,X_Msg_Count              => X_Msg_count
      ,X_Msg_Data		        => X_Msg_Data
      ,X_Return_Status 	        => Lx_Return_Status);

     IF Lx_Return_Status <> G_RET_STS_SUCCESS  THEN
       RAISE L_EXCEP_NO_DATA_FOUND;
     END IF;

     Convert_TimeZone
      (P_API_Version	        => P_API_Version
      ,P_Init_Msg_List          => P_Init_Msg_List
      ,P_Source_Date            => Ld_Day_Cover_EffTo
      ,P_Source_Tz_Id           => ln_CovTZ
      ,P_Dest_Tz_Id             => ln_Param_DatesTZ
      ,X_Dest_Date              => Ld_Tz_Day_Cover_To
      ,X_Msg_Count              => X_Msg_count
      ,X_Msg_Data		        => X_Msg_Data
      ,X_Return_Status 	        => Lx_Return_Status);

     IF Lx_Return_Status <> G_RET_STS_SUCCESS  THEN
       RAISE L_EXCEP_NO_DATA_FOUND;
     END IF;

   END IF;

   --
   --

    X_Day_Cover_From           := Ld_Tz_Day_Cover_From;
    X_Day_Cover_To             := Ld_Tz_Day_Cover_To;
    X_Covered                  := Lx_Covered;
    X_Result                   := Lx_Result;
    X_Return_Status            := Lx_Return_Status;

  EXCEPTION

    WHEN L_EXCEP_NULL_VALUE OR L_EXCEP_NO_DATA_FOUND OR L_EXCEP_NOT_EFFECTIVE OR L_EXCEP_UNEXPECTED_ERR THEN

      X_Result           := Lx_Result;
      X_Return_Status    := Lx_Return_Status;

    WHEN L_EXCEP_NO_DAY_COVER THEN

      Lx_Result         := G_FALSE;

      IF Lx_Set_ExcepionStack = G_TRUE THEN

        OKC_API.SET_MESSAGE(p_app_name	    => G_APP_NAME_OKC
	  		   ,p_msg_name	    => G_REQUIRED_VALUE
			   ,p_token1	    => G_COL_NAME_TOKEN
			   ,p_token1_value  => Lx_ExcepionMsg);

        Lx_Return_Status  := G_RET_STS_ERROR;

      END IF;

      X_Result              := Lx_Result;
      X_Return_Status       := Lx_Return_Status;

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
	,P_Token2_Value   => 'Get_Coverage_Times');

      X_Result        := G_FALSE;
      X_Return_Status := G_RET_STS_UNEXP_ERROR;

  END Get_Coverage_Times;

-----------------------------------------------------------------------------------------------------------------------*

  PROCEDURE Check_Coverage_Times
    (P_API_Version		IN  NUMBER
    ,P_Init_Msg_List		IN  VARCHAR2
    ,P_Business_Process_Id	IN  NUMBER
    ,P_Request_Date		IN  DATE
    ,P_Time_Zone_Id		IN  NUMBER
    ,P_Dates_In_Input_TZ      IN VARCHAR2    -- Added for 12.0 ENT-TZ project (JVARGHES)
    ,P_Contract_Line_Id	        IN  NUMBER
    ,X_Return_Status 		OUT NOCOPY VARCHAR2
    ,X_Msg_Count		OUT NOCOPY NUMBER
    ,X_Msg_Data			OUT NOCOPY VARCHAR2
    ,X_Covered_YN		OUT NOCOPY VARCHAR2)
  IS

    Ld_Day_Cover_From           DATE;
    Ld_Day_Cover_To             DATE;
    Lx_Covered                  Gx_Boolean;
    Lx_Result                   Gx_Boolean;

  BEGIN

    Get_Coverage_Times
      (P_API_Version		=> P_API_Version
      ,P_Init_Msg_List		=> P_Init_Msg_List
      ,P_SVL_Id	                => P_Contract_Line_Id
      ,P_BusiProc_Id	        => P_Business_Process_Id
      ,P_Request_Date		=> NVL(P_Request_Date,SYSDATE)
      ,P_Request_TZone_id	=> P_Time_Zone_Id
      ,P_Dates_In_Input_TZ      => P_Dates_In_Input_TZ  -- Added for 12.0 ENT-TZ project (JVARGHES)
      ,P_Set_ExcepionStack      => G_TRUE
      ,X_Day_Cover_From         => Ld_Day_Cover_From
      ,X_Day_Cover_To           => Ld_Day_Cover_To
      ,X_Covered                => Lx_Covered
      ,X_Msg_Count		=> X_Msg_Count
      ,X_Msg_Data		=> X_Msg_Data
      ,X_Result                 => Lx_Result
      ,X_Return_Status          => X_Return_Status);

    IF Lx_Covered = G_TRUE THEN
      X_Covered_YN   := G_YES;
    ELSE
      X_Covered_YN   := G_NO;
    END IF;


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
	,P_Token2_Value   => 'Check_Coverage_Times');

      --X_Result        := G_FALSE;
      X_Return_Status := G_RET_STS_UNEXP_ERROR;

  END Check_Coverage_Times;

-----------------------------------------------------------------------------------------------------------------------*

  PROCEDURE Get_Contract_Header_Details
    (P_API_Version		IN  NUMBER
    ,P_Init_Msg_List		IN  VARCHAR2
    ,P_Chr_Id                   IN  Gx_OKS_Id
    ,P_Chr_Sts_Code             IN  Gx_Chr_StsCode
    ,P_Chr_Type                 IN  Gx_Chr_Type
    ,P_Chr_EndDate              IN  DATE
    ,P_Chr_PartyId              IN  Gx_Chr_PartyId
    ,X_Contract_Headers  	OUT NOCOPY Hdr_Tbl_Type
    ,X_Msg_Count		OUT NOCOPY NUMBER
    ,X_Msg_Data			OUT NOCOPY VARCHAR2
    ,X_Result                   out nocopy Gx_Boolean
    ,X_Return_Status            out nocopy Gx_Ret_Sts)
  IS



    CURSOR Lx_Csr_Chr(Cx_Chr_Id IN Gx_OKS_Id, Cx_Chr_Sts_Code IN Gx_Chr_StsCode, Cx_Chr_Type IN Gx_Chr_Type
		     ,Cd_Chr_EndDate IN DATE, Cx_Chr_PartyId IN Gx_Chr_PartyId) IS
    SELECT AUTHORING_ORG_ID
	  ,HDR.ID
	  ,HDR.CONTRACT_NUMBER
	  ,HDR.CONTRACT_NUMBER_MODIFIER
      ,HDT.SHORT_DESCRIPTION
	  ,HDR.STS_CODE
	  ,HDR.CHR_TYPE
	  ,HDR.TEMPLATE_YN
	  ,HDR.TEMPLATE_USED
	  ,HDR.START_DATE
	  ,Get_End_Date_Time(HDR.END_DATE) End_Date
	  ,HDR.CHR_ID_AWARD
	  ,HDR.CUST_PO_NUMBER
	  ,HDR.AUTO_RENEW_DAYS
	  ,HDR.QCL_ID
      ,HDR.ESTIMATED_AMOUNT -- 11.5.10 changes
      ,PTY.OBJECT1_ID1 PARTY_ID
      ,HDR.bill_to_site_use_id bill_to_site_use_id -- 11.5.10 changes
      ,HDR.ship_to_site_use_id ship_to_site_use_id -- 11.5.10 changes
      ,HDR.currency_code currency_code -- 11.5.10 changes
      ,OKSHDR.acct_rule_id acct_rule_id -- 11.5.10 changes
      ,HDR.inv_rule_id inv_rule_id -- 11.5.10 changes
      ,HDR.payment_term_id payment_term_id -- 11.5.10 changes
      ,OKSHDR.billing_profile_id billing_profile_id -- 11.5.10 changes
      ,OKSHDR.tax_exemption_id tax_exemption_id -- 11.5.10 changes
      ,OKSHDR.tax_status tax_status -- 11.5.10 changes
      ,HDR.conversion_type conversion_type -- 11.5.10 changes
       FROM OKC_K_PARTY_ROLES_B PTY
          ,OKC_K_HEADERS_TL HDT
          ,OKC_K_HEADERS_ALL_B HDR  --,OKC_K_HEADERS_B HDR  -- Modified for 12.0 MOAC project (JVARGHES)
          ,OKS_K_HEADERS_B OKSHDR -- 11.5.10 changes
     WHERE    HDR.ID                = NVL(Cx_Chr_Id,HDR.ID)
	  AND HDR.END_DATE          = NVL(Cd_Chr_EndDate,HDR.END_DATE)
	  AND HDR.STS_CODE          = NVL(Cx_Chr_Sts_Code,HDR.STS_CODE)
	  AND HDR.CHR_TYPE          = NVL(Cx_Chr_Type,HDR.CHR_TYPE)
      AND HDR.START_DATE        IS NOT NULL
      AND HDR.END_DATE          IS NOT NULL
      AND HDR.TEMPLATE_YN       = G_NO
      AND HDT.ID                = HDR.ID
      AND HDT.LANGUAGE          = USERENV('LANG')
      AND PTY.CHR_ID            = HDR.ID
      AND PTY.OBJECT1_ID1       = NVL(Cx_Chr_PartyId, PTY.OBJECT1_ID1)
      AND HDR.ID                = OKSHDR.CHR_ID
      AND PTY.JTOT_OBJECT1_CODE = G_JTOT_OBJ_PARTY;


    Lx_Chr_Id                   CONSTANT Gx_OKS_Id := P_Chr_Id;
    Lx_Chr_Sts_Code             CONSTANT Gx_Chr_StsCode := P_Chr_Sts_Code;
    Lx_Chr_Type                 CONSTANT Gx_Chr_Type := P_Chr_Type;
    Ld_Chr_EndDate              CONSTANT DATE := P_Chr_EndDate;
    Lx_Chr_PartyId              CONSTANT Gx_Chr_PartyId := P_Chr_PartyId;

    Lx_Contract_Headers	        Hdr_Tbl_Type;
    Lx_Result                   Gx_Boolean;
    Lx_Return_Status            Gx_Ret_Sts;

    Li_TableIdx                 BINARY_INTEGER;

  BEGIN

    Lx_Result                   := G_TRUE;
    Lx_Return_Status            := G_RET_STS_SUCCESS;

    Li_TableIdx  := 0;

    FOR Idx IN Lx_Csr_Chr(Lx_Chr_Id, Lx_Chr_Sts_Code, Lx_Chr_Type, Ld_Chr_EndDate, Lx_Chr_PartyId )  LOOP

      Li_TableIdx   := Li_TableIdx + 1;

      Lx_Contract_Headers(Li_TableIdx).Org_Id                   := Idx.Authoring_Org_Id;
      Lx_Contract_Headers(Li_TableIdx).Contract_Id	            := Idx.Id;
      Lx_Contract_Headers(Li_TableIdx).Contract_Number          := Idx.Contract_Number;
      Lx_Contract_Headers(Li_TableIdx).Contract_Number_Modifier := Idx.Contract_Number_Modifier;
      Lx_Contract_Headers(Li_TableIdx).Short_Description        := Idx.Short_Description;
      Lx_Contract_Headers(Li_TableIdx).Contract_Amount	        := Idx.Estimated_amount; --11.5.10 changes..OKS_ENT_UTIL_PVT.Get_Contract_Amount(Idx.Id);
      Lx_Contract_Headers(Li_TableIdx).Contract_Status_Code     := Idx.Sts_Code;
      Lx_Contract_Headers(Li_TableIdx).Contract_Type	        := Idx.Chr_Type;
      Lx_Contract_Headers(Li_TableIdx).Party_Id		            := TO_NUMBER(Idx.Party_Id);
      Lx_Contract_Headers(Li_TableIdx).Template_YN	            := Idx.Template_YN;
      Lx_Contract_Headers(Li_TableIdx).Template_Used	        := Idx.Template_Used;
      Lx_Contract_Headers(Li_TableIdx).Duration		            := TO_NUMBER(OKS_ENT_UTIL_PVT.Get_Duration_Period
                                                                                               (Idx.Start_Date,Idx.End_Date,'D'));
      Lx_Contract_Headers(Li_TableIdx).Period_Code	            := OKS_ENT_UTIL_PVT.Get_Duration_Period
                                                                                     (Idx.Start_Date,Idx.End_Date,'P');
      Lx_Contract_Headers(Li_TableIdx).Start_Date_Active        := Idx.Start_Date;
      Lx_Contract_Headers(Li_TableIdx).End_Date_Active	        := Idx.End_Date;
      Lx_Contract_Headers(Li_TableIdx).Bill_To_Site_Use_Id      := Idx.bill_to_site_use_id; --TO_NUMBER(OKS_ENT_UTIL_PVT.Get_BilltoShipto(Idx.Id,NULL,'OKX_BILLTO')); --from okc_k_headers_b
      Lx_Contract_Headers(Li_TableIdx).Ship_To_Site_Use_Id      := Idx.ship_to_site_use_id; --TO_NUMBER(OKS_ENT_UTIL_PVT.Get_BilltoShipto(Idx.Id,NULL,'OKX_SHIPTO')); --from okc_k_headers_b
      Lx_Contract_Headers(Li_TableIdx).Agreement_Id	            := OKS_ENT_UTIL_PVT.Get_Agreement(Idx.Id);
      Lx_Contract_Headers(Li_TableIdx).Price_List_Id	        := TO_NUMBER(OKS_ENT_UTIL_PVT.Get_PriceList(Idx.Id,NULL,'P')); --from okc_k_headers_b.price_list_id
      Lx_Contract_Headers(Li_TableIdx).Modifier   	            := null; -- does not exist in 11.5.10 --TO_NUMBER(OKS_ENT_UTIL_PVT.Get_Discount(Idx.Id,NULL));
      Lx_Contract_Headers(Li_TableIdx).Currency_Code	        := Idx.Currency_code; --SUBSTR(OKS_ENT_UTIL_PVT.Get_PriceList(Idx.Id,NULL,'C'),1,30); -- from okc_k_headers_b.currency_code
      Lx_Contract_Headers(Li_TableIdx).Accounting_Rule_Id       := Idx.acct_rule_id;  --TO_NUMBER(OKS_ENT_UTIL_PVT.Get_Acc_Rule(Idx.Id,NULL)); -- oks_k_headers_b.acct_rule_id
      Lx_Contract_Headers(Li_TableIdx).Invoicing_Rule_Id        := Idx.inv_rule_id;  --TO_NUMBER(OKS_ENT_UTIL_PVT.Get_Inv_Rule(Idx.Id,NULL)); -- okc_k_headers_b.inv_rule_id
      Lx_Contract_Headers(Li_TableIdx).Terms_Id		            := Idx.payment_term_id; --TO_NUMBER(OKS_ENT_UTIL_PVT.Get_Terms(Idx.Id,NULL)); --okc_k_headers_b.payment_term_id
      Lx_Contract_Headers(Li_TableIdx).PO_Number	            := Idx.Cust_PO_Number;
      Lx_Contract_Headers(Li_TableIdx).Billing_Profile_Id       := Idx.Billing_profile_id; --TO_NUMBER(OKS_ENT_UTIL_PVT.Get_BillingProfile(Idx.Id,NULL)); --oks_k_header_b.billing_profile_id
      Lx_Contract_Headers(Li_TableIdx).Billing_Frequency        := null; -- does not exist in 11.5.10 --SUBSTR(OKS_ENT_UTIL_PVT.Get_BillingSchedule(Idx.Id,NULL,'F'),1,25); --null
      Lx_Contract_Headers(Li_TableIdx).Billing_Method	        := null; -- does not exist in 11.5.10 --SUBSTR(OKS_ENT_UTIL_PVT.Get_BillingSchedule(Idx.Id,NULL,'M'),1,3); --null
      Lx_Contract_Headers(Li_TableIdx).Regular_Offset_Days      := null; -- does not exist in 11.5.10 --TO_NUMBER(OKS_ENT_UTIL_PVT.Get_BillingSchedule(Idx.Id,NULL,'R'));--null
      Lx_Contract_Headers(Li_TableIdx).First_Bill_To 	        := null; -- does not exist in 11.5.10 --TO_DATE(OKS_ENT_UTIL_PVT.Get_BillingSchedule
                                                                                             --(Idx.Id,NULL,'T'),'YYYY/MM/DD HH24:MI:SS'); --null
      Lx_Contract_Headers(Li_TableIdx).First_Bill_On 	        := null; -- does not exist in 11.5.10 --TO_DATE(OKS_ENT_UTIL_PVT.Get_BillingSchedule
								                                          ---(Idx.Id,NULL,'O'),'YYYY/MM/DD HH24:MI:SS'); --null
      Lx_Contract_Headers(Li_TableIdx).Auto_Renew_Before_Days   := Idx.Auto_Renew_Days;
      Lx_Contract_Headers(Li_TableIdx).QA_Check_List_Id	        := Idx.Qcl_Id;
      Lx_Contract_Headers(Li_TableIdx).Renewal_Note	            := OKS_ENT_UTIL_PVT.Get_RenterNotes(Idx.Id,'RENEW');
      Lx_Contract_Headers(Li_TableIdx).Termination_Note	        := OKS_ENT_UTIL_PVT.Get_RenterNotes(Idx.Id,'TER');
      Lx_Contract_Headers(Li_TableIdx).Tax_Exemption            := Idx.tax_exemption_id; --OKS_ENT_UTIL_PVT.Get_TaxRule(Idx.Id,'TE'); --oks_k_headers_b.tax_exemption_id
      Lx_Contract_Headers(Li_TableIdx).Tax_Status               := Idx.tax_status; --OKS_ENT_UTIL_PVT.Get_TaxRule(Idx.Id,'TS'); --oks_k_headers_b.tax_status
      Lx_Contract_Headers(Li_TableIdx).Conversion_Type          := Idx.conversion_type; --OKS_ENT_UTIL_PVT.Get_ConvRule(Idx.Id); --okc_k_headers_b.conversion_type

    END LOOP;

    X_Contract_Headers    := Lx_Contract_Headers;
    X_Result              := Lx_Result;
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
	,P_Token2_Value   => 'Get_Contract_Header_Details');

      X_Result        := G_FALSE;
      X_Return_Status := G_RET_STS_UNEXP_ERROR;

  END Get_Contract_Header_Details;

-----------------------------------------------------------------------------------------------------------------------*

  PROCEDURE Get_All_Contracts
    (P_API_Version	       IN  NUMBER
    ,P_Init_Msg_List	       IN  VARCHAR2
    ,P_Inp_Rec		       IN  Inp_Rec_Type
    ,X_Return_Status           out nocopy VARCHAR2
    ,X_Msg_Count	       out nocopy NUMBER
    ,X_Msg_Data		       out nocopy VARCHAR2
    ,X_All_Contracts	       out nocopy Hdr_Tbl_Type)
  IS

    Lx_Result                  Gx_Boolean;
    Lx_Inp_Rec                 Inp_Rec_Type;

  BEGIN

    Lx_Inp_Rec                 := P_Inp_Rec;

    Get_Contract_Header_Details
      (P_API_Version		=> P_API_Version
      ,P_Init_Msg_List		=> P_Init_Msg_List
      ,P_Chr_Id                 => Lx_Inp_Rec.Contract_Id
      ,P_Chr_Sts_Code           => Lx_Inp_Rec.Contract_Status_Code
      ,P_Chr_Type               => Lx_Inp_Rec.Contract_Type_Code
      ,P_Chr_EndDate            => Lx_Inp_Rec.End_Date_Active
      ,P_Chr_PartyId            => Lx_Inp_Rec.Party_Id
      ,X_Contract_Headers  	=> X_All_Contracts
      ,X_Msg_Count		=> X_Msg_Count
      ,X_Msg_Data		=> X_Msg_Data
      ,X_Result                 => Lx_Result
      ,X_Return_Status          => X_Return_Status);

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
	,P_Token2_Value   => 'Get_All_Contracts');

      --X_Result        := G_FALSE;
      X_Return_Status := G_RET_STS_UNEXP_ERROR;

  END Get_All_Contracts;

-----------------------------------------------------------------------------------------------------------------------*

  PROCEDURE Get_Contract_Line_Details
    (P_API_Version		IN  NUMBER
    ,P_Init_Msg_List		IN  VARCHAR2
    ,P_Cle_Id	                IN  Gx_OKS_Id
    ,X_Contract_Lines		OUT NOCOPY Line_Tbl_Type
    ,X_Msg_Count		OUT NOCOPY NUMBER
    ,X_Msg_Data			OUT NOCOPY VARCHAR2
    ,X_Result                   out nocopy Gx_Boolean
    ,X_Return_Status            out nocopy Gx_Ret_Sts)
  IS

    CURSOR Lx_Csr_Cle(Cx_Cle_Id IN Gx_OKS_Id) IS
    SELECT LIN.ID
	  ,LIN.CLE_ID
	  ,LIN.DNZ_CHR_ID
	  ,LIN.STS_CODE
	  ,LIN.START_DATE
	  ,Get_End_Date_Time(LIN.END_DATE) End_Date
	  ,Get_End_Date_Time(LIN.DATE_TERMINATED) Date_Terminated
	  ,LIN.PRICE_NEGOTIATED
	  ,STL.NAME
	  ,LIN.bill_to_site_use_id bill_to_site_use_id -- 11.5.10 changes
	  ,LIN.ship_to_site_use_id ship_to_site_use_id -- 11.5.10 changes
	  ,OKSLIN.discount_list discount_list -- 11.5.10 changes
	  ,LIN.price_list_id price_list_id -- 11.5.10 changes
      FROM OKC_K_HEADERS_ALL_B HDR -- OKC_K_HEADERS_B HDR  -- Modified for 12.0 MOAC project (JVARGHES)
          ,OKC_LINE_STYLES_V STL
	      ,OKC_K_LINES_B LIN
	      ,OKS_K_LINES_B OKSLIN  -- 11.5.10 changes
     WHERE    LIN.ID           = Cx_Cle_Id   --Commented by Jvorugan NVL(Cx_Cle_Id, LIN.ID)
          AND LIN.START_DATE   IS NOT NULL
          AND LIN.END_DATE     IS NOT NULL
    	  AND STL.ID           = LIN.LSE_ID
          AND HDR.ID           = LIN.DNZ_CHR_ID
          AND HDR.TEMPLATE_YN  = G_NO
          AND OKSLIN.CLE_ID    = LIN.Id;

-- Added by Jvorugan for Bug:4998337
    CURSOR Lx_Csr_noCle IS
    SELECT LIN.ID
	  ,LIN.CLE_ID
	  ,LIN.DNZ_CHR_ID
	  ,LIN.STS_CODE
	  ,LIN.START_DATE
	  ,Get_End_Date_Time(LIN.END_DATE) End_Date
	  ,Get_End_Date_Time(LIN.DATE_TERMINATED) Date_Terminated
	  ,LIN.PRICE_NEGOTIATED
	  ,STL.NAME
	  ,LIN.bill_to_site_use_id bill_to_site_use_id -- 11.5.10 changes
	  ,LIN.ship_to_site_use_id ship_to_site_use_id -- 11.5.10 changes
	  ,OKSLIN.discount_list discount_list -- 11.5.10 changes
	  ,LIN.price_list_id price_list_id -- 11.5.10 changes
      FROM OKC_K_HEADERS_ALL_B HDR -- OKC_K_HEADERS_B HDR  -- Modified for 12.0 MOAC project (JVARGHES)
          ,OKC_LINE_STYLES_V STL
	      ,OKC_K_LINES_B LIN
	      ,OKS_K_LINES_B OKSLIN  -- 11.5.10 changes
     WHERE  --  LIN.ID           = NVL(Cx_Cle_Id, LIN.ID)
          LIN.START_DATE   IS NOT NULL
          AND LIN.END_DATE     IS NOT NULL
    	  AND STL.ID           = LIN.LSE_ID
          AND HDR.ID           = LIN.DNZ_CHR_ID
          AND HDR.TEMPLATE_YN  = G_NO
          AND OKSLIN.CLE_ID    = LIN.Id;


    Lx_Cle_Id	                CONSTANT Gx_OKS_Id := P_Cle_Id;

    Lx_Contract_Lines		Line_Tbl_Type;
    Lx_Result                   Gx_Boolean;
    Lx_Return_Status            Gx_Ret_Sts;

    Li_TableIdx                 BINARY_INTEGER;

  BEGIN

    Lx_Result                   := G_TRUE;
    Lx_Return_Status            := G_RET_STS_SUCCESS;

    Li_TableIdx  := 0;

/* Added by Jvorugan for perf bug:4998337.
  If lx_cle_id is not null  then only passing the value.
  This is to avoid full table scan on okc_k_headers_all_b, okc_k_lines_b, oks_k_lines_b
*/

  IF Lx_Cle_Id IS NULL
  THEN
     FOR Idx IN Lx_Csr_noCle  LOOP

      Li_TableIdx   :=  Li_TableIdx + 1;

      Lx_Contract_Lines(Li_TableIdx).Contract_Line_Id         := Idx.Id;
      Lx_Contract_Lines(Li_TableIdx).Contract_Parent_Line_Id  := Idx.Cle_Id;
      Lx_Contract_Lines(Li_TableIdx).Contract_Id                  := Idx.Dnz_Chr_Id;
      Lx_Contract_Lines(Li_TableIdx).Line_Status_Code         := Idx.Sts_Code;
      Lx_Contract_Lines(Li_TableIdx).Duration                     := TO_NUMBER(OKS_ENT_UTIL_PVT.Get_Duration_Period
                                                                                              (Idx.Start_Date,Idx.End_Date,'D'));
      Lx_Contract_Lines(Li_TableIdx).Period_Code                  := OKS_ENT_UTIL_PVT.Get_Duration_Period
                                                                                    (Idx.Start_Date,Idx.End_Date,'P');
      Lx_Contract_Lines(Li_TableIdx).Start_Date_Active        := Idx.Start_Date;
      Lx_Contract_Lines(Li_TableIdx).End_Date_Active          := Idx.End_Date;
      Lx_Contract_Lines(Li_TableIdx).Line_Name                := Idx.Name;
      Lx_Contract_Lines(Li_TableIdx).Bill_To_Site_Use_Id      := Idx.Bill_To_Site_Use_Id; --TO_NUMBER(OKS_ENT_UTIL_PVT.Get_BilltoShipto
                                                                                                                                 --(NULL,Idx.Id,'OKX_BILLTO')); -- okc_k_lines_b.bill_to_site_use_id
      Lx_Contract_Lines(Li_TableIdx).Ship_To_Site_Use_Id      := Idx.Ship_To_Site_Use_Id; --TO_NUMBER(OKS_ENT_UTIL_PVT.Get_BilltoShipto
                                                                                                                --(NULL,Idx.Id,'OKX_SHIPTO')); --okc_k_lines_b.ship_to_site_use_id
      Lx_Contract_Lines(Li_TableIdx).Modifier                 := Idx.discount_list; --TO_NUMBER(OKS_ENT_UTIL_PVT.Get_Discount(NULL,Idx.Id)); --oks_k_lines_b.discount_list
      Lx_Contract_Lines(Li_TableIdx).Price_List_Id                := Idx.price_list_id; --TO_NUMBER(OKS_ENT_UTIL_PVT.Get_PriceList(NULL,Idx.Id,'P')); --okc_k_lines_b.price_list_id
      Lx_Contract_Lines(Li_TableIdx).Price_Negotiated         := Idx.Price_Negotiated;
      Lx_Contract_Lines(Li_TableIdx).Billing_Profile_Id       := null; -- does not exist in 11.5.10 --TO_NUMBER(OKS_ENT_UTIL_PVT.Get_BillingProfile(NULL,Idx.Id)); --null
      Lx_Contract_Lines(Li_TableIdx).Billing_Frequency        := null; -- does not exist in 11.5.10 --SUBSTR(OKS_ENT_UTIL_PVT.Get_BillingSchedule(NULL,Idx.Id,'F'),1,25); --null
      Lx_Contract_Lines(Li_TableIdx).Billing_Method               := null; -- does not exist in 11.5.10 --SUBSTR(OKS_ENT_UTIL_PVT.Get_BillingSchedule(NULL,Idx.Id,'M'),1,3); --null
      Lx_Contract_Lines(Li_TableIdx).Regular_Offset_Days      := null; -- does not exist in 11.5.10 --TO_NUMBER(OKS_ENT_UTIL_PVT.Get_BillingSchedule(NULL,Idx.Id,'R')); --null
      Lx_Contract_Lines(Li_TableIdx).First_Bill_To                := null; -- does not exist in 11.5.10 --TO_DATE(OKS_ENT_UTIL_PVT.Get_BillingSchedule
                                                                                            --(NULL,Idx.Id,'T'),'YYYY/MM/DD HH24:MI:SS'); --null
      Lx_Contract_Lines(Li_TableIdx).First_Bill_On                := null; -- does not exist in 11.5.10 --TO_DATE(OKS_ENT_UTIL_PVT.Get_BillingSchedule
                                                                                                                            --(NULL,Idx.Id,'O'),'YYYY/MM/DD HH24:MI:SS'); --null
      Lx_Contract_Lines(Li_TableIdx).Termination_Date         := Idx.Date_Terminated;

    END LOOP;

  ELSE

    FOR Idx IN Lx_Csr_Cle(Lx_Cle_Id)  LOOP

      Li_TableIdx   :=  Li_TableIdx + 1;

      Lx_Contract_Lines(Li_TableIdx).Contract_Line_Id         := Idx.Id;
      Lx_Contract_Lines(Li_TableIdx).Contract_Parent_Line_Id  := Idx.Cle_Id;
      Lx_Contract_Lines(Li_TableIdx).Contract_Id                  := Idx.Dnz_Chr_Id;
      Lx_Contract_Lines(Li_TableIdx).Line_Status_Code         := Idx.Sts_Code;
      Lx_Contract_Lines(Li_TableIdx).Duration                     := TO_NUMBER(OKS_ENT_UTIL_PVT.Get_Duration_Period
                                                                                              (Idx.Start_Date,Idx.End_Date,'D'));
      Lx_Contract_Lines(Li_TableIdx).Period_Code                  := OKS_ENT_UTIL_PVT.Get_Duration_Period
                                                                                    (Idx.Start_Date,Idx.End_Date,'P');
      Lx_Contract_Lines(Li_TableIdx).Start_Date_Active        := Idx.Start_Date;
      Lx_Contract_Lines(Li_TableIdx).End_Date_Active          := Idx.End_Date;
      Lx_Contract_Lines(Li_TableIdx).Line_Name                := Idx.Name;
      Lx_Contract_Lines(Li_TableIdx).Bill_To_Site_Use_Id      := Idx.Bill_To_Site_Use_Id; --TO_NUMBER(OKS_ENT_UTIL_PVT.Get_BilltoShipto
                                                                                                                                 --(NULL,Idx.Id,'OKX_BILLTO')); -- okc_k_lines_b.bill_to_site_use_id
      Lx_Contract_Lines(Li_TableIdx).Ship_To_Site_Use_Id      := Idx.Ship_To_Site_Use_Id; --TO_NUMBER(OKS_ENT_UTIL_PVT.Get_BilltoShipto
                                                                                                                --(NULL,Idx.Id,'OKX_SHIPTO')); --okc_k_lines_b.ship_to_site_use_id
      Lx_Contract_Lines(Li_TableIdx).Modifier                 := Idx.discount_list; --TO_NUMBER(OKS_ENT_UTIL_PVT.Get_Discount(NULL,Idx.Id)); --oks_k_lines_b.discount_list
      Lx_Contract_Lines(Li_TableIdx).Price_List_Id                := Idx.price_list_id; --TO_NUMBER(OKS_ENT_UTIL_PVT.Get_PriceList(NULL,Idx.Id,'P')); --okc_k_lines_b.price_list_id
      Lx_Contract_Lines(Li_TableIdx).Price_Negotiated         := Idx.Price_Negotiated;
      Lx_Contract_Lines(Li_TableIdx).Billing_Profile_Id       := null; -- does not exist in 11.5.10 --TO_NUMBER(OKS_ENT_UTIL_PVT.Get_BillingProfile(NULL,Idx.Id)); --null
      Lx_Contract_Lines(Li_TableIdx).Billing_Frequency        := null; -- does not exist in 11.5.10 --SUBSTR(OKS_ENT_UTIL_PVT.Get_BillingSchedule(NULL,Idx.Id,'F'),1,25); --null
      Lx_Contract_Lines(Li_TableIdx).Billing_Method               := null; -- does not exist in 11.5.10 --SUBSTR(OKS_ENT_UTIL_PVT.Get_BillingSchedule(NULL,Idx.Id,'M'),1,3); --null
      Lx_Contract_Lines(Li_TableIdx).Regular_Offset_Days      := null; -- does not exist in 11.5.10 --TO_NUMBER(OKS_ENT_UTIL_PVT.Get_BillingSchedule(NULL,Idx.Id,'R')); --null
      Lx_Contract_Lines(Li_TableIdx).First_Bill_To                := null; -- does not exist in 11.5.10 --TO_DATE(OKS_ENT_UTIL_PVT.Get_BillingSchedule
                                                                                            --(NULL,Idx.Id,'T'),'YYYY/MM/DD HH24:MI:SS'); --null
      Lx_Contract_Lines(Li_TableIdx).First_Bill_On                := null; -- does not exist in 11.5.10 --TO_DATE(OKS_ENT_UTIL_PVT.Get_BillingSchedule
                                                                                                                            --(NULL,Idx.Id,'O'),'YYYY/MM/DD HH24:MI:SS'); --null
      Lx_Contract_Lines(Li_TableIdx).Termination_Date         := Idx.Date_Terminated;

    END LOOP;

   END IF; -- lx_Cle_id is null

   /* Commented by Jvorugan for Bug:4998337
      FOR Idx IN Lx_Csr_Cle(Lx_Cle_Id)  LOOP

      Li_TableIdx   :=  Li_TableIdx + 1;

      Lx_Contract_Lines(Li_TableIdx).Contract_Line_Id	      := Idx.Id;
      Lx_Contract_Lines(Li_TableIdx).Contract_Parent_Line_Id  := Idx.Cle_Id;
      Lx_Contract_Lines(Li_TableIdx).Contract_Id	          := Idx.Dnz_Chr_Id;
      Lx_Contract_Lines(Li_TableIdx).Line_Status_Code	      := Idx.Sts_Code;
      Lx_Contract_Lines(Li_TableIdx).Duration		          := TO_NUMBER(OKS_ENT_UTIL_PVT.Get_Duration_Period
                                                                                              (Idx.Start_Date,Idx.End_Date,'D'));
      Lx_Contract_Lines(Li_TableIdx).Period_Code	          := OKS_ENT_UTIL_PVT.Get_Duration_Period
                                                                                    (Idx.Start_Date,Idx.End_Date,'P');
      Lx_Contract_Lines(Li_TableIdx).Start_Date_Active	      := Idx.Start_Date;
      Lx_Contract_Lines(Li_TableIdx).End_Date_Active	      := Idx.End_Date;
      Lx_Contract_Lines(Li_TableIdx).Line_Name                := Idx.Name;
      Lx_Contract_Lines(Li_TableIdx).Bill_To_Site_Use_Id      := Idx.Bill_To_Site_Use_Id; --TO_NUMBER(OKS_ENT_UTIL_PVT.Get_BilltoShipto
                											                         --(NULL,Idx.Id,'OKX_BILLTO')); -- okc_k_lines_b.bill_to_site_use_id
      Lx_Contract_Lines(Li_TableIdx).Ship_To_Site_Use_Id      := Idx.Ship_To_Site_Use_Id; --TO_NUMBER(OKS_ENT_UTIL_PVT.Get_BilltoShipto
				    				                                                --(NULL,Idx.Id,'OKX_SHIPTO')); --okc_k_lines_b.ship_to_site_use_id
      Lx_Contract_Lines(Li_TableIdx).Modifier        	      := Idx.discount_list; --TO_NUMBER(OKS_ENT_UTIL_PVT.Get_Discount(NULL,Idx.Id)); --oks_k_lines_b.discount_list
      Lx_Contract_Lines(Li_TableIdx).Price_List_Id	          := Idx.price_list_id; --TO_NUMBER(OKS_ENT_UTIL_PVT.Get_PriceList(NULL,Idx.Id,'P')); --okc_k_lines_b.price_list_id
      Lx_Contract_Lines(Li_TableIdx).Price_Negotiated	      := Idx.Price_Negotiated;
      Lx_Contract_Lines(Li_TableIdx).Billing_Profile_Id	      := null; -- does not exist in 11.5.10 --TO_NUMBER(OKS_ENT_UTIL_PVT.Get_BillingProfile(NULL,Idx.Id)); --null
      Lx_Contract_Lines(Li_TableIdx).Billing_Frequency	      := null; -- does not exist in 11.5.10 --SUBSTR(OKS_ENT_UTIL_PVT.Get_BillingSchedule(NULL,Idx.Id,'F'),1,25); --null
      Lx_Contract_Lines(Li_TableIdx).Billing_Method	          := null; -- does not exist in 11.5.10 --SUBSTR(OKS_ENT_UTIL_PVT.Get_BillingSchedule(NULL,Idx.Id,'M'),1,3); --null
      Lx_Contract_Lines(Li_TableIdx).Regular_Offset_Days      := null; -- does not exist in 11.5.10 --TO_NUMBER(OKS_ENT_UTIL_PVT.Get_BillingSchedule(NULL,Idx.Id,'R')); --null
      Lx_Contract_Lines(Li_TableIdx).First_Bill_To 	          := null; -- does not exist in 11.5.10 --TO_DATE(OKS_ENT_UTIL_PVT.Get_BillingSchedule
                                                                                            --(NULL,Idx.Id,'T'),'YYYY/MM/DD HH24:MI:SS'); --null
      Lx_Contract_Lines(Li_TableIdx).First_Bill_On 	          := null; -- does not exist in 11.5.10 --TO_DATE(OKS_ENT_UTIL_PVT.Get_BillingSchedule
								                                                            --(NULL,Idx.Id,'O'),'YYYY/MM/DD HH24:MI:SS'); --null
      Lx_Contract_Lines(Li_TableIdx).Termination_Date	      := Idx.Date_Terminated;

    END LOOP;

    */

    X_Contract_Lines      := Lx_Contract_Lines;
    X_Result              := Lx_Result;
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
	,P_Token2_Value   => 'Get_Contract_Line_Details');

      X_Result         := G_FALSE;
      X_Return_Status  := G_RET_STS_UNEXP_ERROR;

  END Get_Contract_Line_Details;

-----------------------------------------------------------------------------------------------------------------------*

  PROCEDURE Get_Contract_Details
    (P_API_Version		IN  NUMBER
    ,P_Init_Msg_List		IN  VARCHAR2
    ,P_Contract_Line_Id	        IN  NUMBER
    ,X_Return_Status 		OUT NOCOPY VARCHAR2
    ,X_Msg_Count		OUT NOCOPY NUMBER
    ,X_Msg_Data			OUT NOCOPY VARCHAR2
    ,X_All_Lines		OUT NOCOPY Line_Tbl_Type)
  IS

    Lx_Result                   Gx_Boolean;

  BEGIN

    Get_Contract_Line_Details
      (P_API_Version		=> P_API_Version
      ,P_Init_Msg_List		=> P_Init_Msg_List
      ,P_Cle_Id	                => P_Contract_Line_Id
      ,X_Contract_Lines		=> X_All_Lines
      ,X_Msg_Count		=> X_Msg_Count
      ,X_Msg_Data		=> X_Msg_Data
      ,X_Result                 => Lx_Result
      ,X_Return_Status          => X_Return_Status);

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
	,P_Token2_Value   => 'Get_Contract_Details');

      --X_Result         := G_FALSE;
      X_Return_Status  := G_RET_STS_UNEXP_ERROR;

  END Get_Contract_Details;

-----------------------------------------------------------------------------------------------------------------------*

  PROCEDURE Get_Coverage_Level_Details
    (P_API_Version		IN  NUMBER
    ,P_Init_Msg_List		IN  VARCHAR2
    ,P_Cle_Id	                IN  Gx_OKS_Id
    ,X_Covered_Levels 	        out nocopy Clvl_Tbl_Type
    ,X_Msg_Count		OUT NOCOPY NUMBER
    ,X_Msg_Data			OUT NOCOPY VARCHAR2
    ,X_Result                   out nocopy Gx_Boolean
    ,X_Return_Status            out nocopy Gx_Ret_Sts)
  IS

    CURSOR Lx_Csr_CovLvl(Cx_Cle_Id IN Gx_OKS_Id) IS
    SELECT LIN.ROWID
	  ,LIN.ID
	  ,LIN.DNZ_CHR_ID
	  ,LIN.CLE_ID
	  ,LIN.PRICE_NEGOTIATED
	  ,STL.NAME
      ,HDR.AUTHORING_ORG_ID ORG_ID
      ,HDR.INV_ORGANIZATION_ID ORGANIZATION_ID
    FROM OKC_K_HEADERS_ALL_B HDR  -- OKC_K_HEADERS_B HDR  -- Modified for 12.0 MOAC project (JVARGHES)
	    ,OKC_LINE_STYLES_V STL
        ,OKC_K_LINES_B LIN
        ,OKS_K_LINES_B OKSLIN --11.5.10 changes
    WHERE LIN.ID        = Cx_Cle_Id    -- COmmented by Jvorugan for bug:4998337 NVL(Cx_Cle_Id, LIN.ID)
      AND LIN.LSE_ID    IN (7, 8, 9, 10, 11, 13, 18, 25, 35)
	  AND STL.ID        = LIN.LSE_ID
      AND HDR.ID        = LIN.DNZ_CHR_ID
      AND OKSLIN.CLE_ID = LIN.ID;

-- Added by Jvorugan for perf bug:4998337
    CURSOR Lx_Csr_CovLvl_noCle_id  IS
    SELECT LIN.ROWID
          ,LIN.ID
          ,LIN.DNZ_CHR_ID
          ,LIN.CLE_ID
          ,LIN.PRICE_NEGOTIATED
          ,STL.NAME
      ,HDR.AUTHORING_ORG_ID ORG_ID
      ,HDR.INV_ORGANIZATION_ID ORGANIZATION_ID
    FROM OKC_K_HEADERS_ALL_B HDR  -- OKC_K_HEADERS_B HDR  -- Modified for 12.0 MOAC project (JVARGHES)
            ,OKC_LINE_STYLES_V STL
        ,OKC_K_LINES_B LIN
        ,OKS_K_LINES_B OKSLIN --11.5.10 changes
    WHERE -- LIN.ID        = NVL(Cx_Cle_Id, LIN.ID)
        LIN.LSE_ID    IN (7, 8, 9, 10, 11, 13, 18, 25, 35)
        AND STL.ID        = LIN.LSE_ID
        AND HDR.ID        = LIN.DNZ_CHR_ID
        AND OKSLIN.CLE_ID = LIN.ID;


    ----CSI schema change uptake----
/*
    CURSOR Lx_Csr_CovProd(Cn_Prod_Id NUMBER,Cn_Org_Id NUMBER,Ln_Organization_Id NUMBER) IS
      SELECT CP.Name
        FROM OKX_CUSTOMER_PRODUCTS_V CP
       WHERE     CP.Id1             = Cn_Prod_Id
             AND CP.Org_Id          = Cn_Org_Id
             AND CP.Organization_Id = Ln_Organization_Id;
*/

    CURSOR Lx_Csr_CovProd(Cn_Prod_Id NUMBER,Cn_Org_Id NUMBER,Ln_Organization_Id NUMBER) IS
        SELECT MSI.DESCRIPTION Name
        FROM   CSI_ITEM_INSTANCES CSI,
	           CSI_I_ORG_ASSIGNMENTS CIOA,
               MTL_SYSTEM_ITEMS_B_KFV MSI
        WHERE  CSI.INSTANCE_ID                 = Cn_Prod_Id
        AND    CSI.INSTANCE_ID                 = CIOA.INSTANCE_ID(+)
        AND    CIOA.RELATIONSHIP_TYPE_CODE (+) = 'SOLD_FROM'
        AND    CSI.INVENTORY_ITEM_ID           = MSI.INVENTORY_ITEM_ID
        AND    CIOA.OPERATING_UNIT_ID          = Cn_Org_Id
        AND    CSI.INV_MASTER_ORGANIZATION_ID  = Ln_Organization_Id;

    Lx_Cle_Id	                CONSTANT Gx_OKS_Id := P_Cle_Id;
    Lx_Covered_Levels 	        Clvl_Tbl_Type;

    Lx_Prod_Rec		        OKS_ENT_UTIL_PVT.L_Pdt_Rec;
    Lx_Item_Rec		        OKS_ENT_UTIL_PVT.L_Inv_Rec;
    Lx_Sys_Rec		        OKS_ENT_UTIL_PVT.L_Sys_Rec;
    Lx_Party_Rec                OKS_ENT_UTIL_PVT.L_Party_Rec;
    Lx_CustAc_Rec               OKS_ENT_UTIL_PVT.L_Cust_Rec;
    Lx_Site_Rec                 OKS_ENT_UTIL_PVT.L_Site_Rec;
    Lx_QtyRate_Rec	        OKS_ENT_UTIL_PVT.L_QtyRate_Rec;

    Lx_Result                   Gx_Boolean;
    Lx_Return_Status            Gx_Ret_Sts;

    --Lv_Prod_Name                OKX_CUSTOMER_PRODUCTS_V.Name%TYPE;  --VARCHAR2(500);
    Lv_Prod_Name                  MTL_SYSTEM_ITEMS_B_KFV.description%TYPE;  --VARCHAR2(500);
    Ln_ListPrice		NUMBER;
    Li_TableIdx                 BINARY_INTEGER;

  BEGIN

    Lx_Result                   := G_TRUE;
    Lx_Return_Status            := G_RET_STS_SUCCESS;

    Li_TableIdx  := 0;

/* Modified by Jvorugan for perg bug:4998337.
If lx_cle_id is not null, then only passing the value.
This is to avoid full table scan on okc_k_headers_all_b,okc_k_lines_b due to nvl condition
*/

IF Lx_Cle_Id IS NULL
THEN
    FOR Idx IN Lx_Csr_CovLvl_noCle_id  LOOP

      Li_TableIdx                     := Li_TableIdx + 1;

      Lv_Prod_Name                    := NULL;
      Lx_Prod_Rec		      := OKS_ENT_UTIL_PVT.Get_Product(Idx.Id);

      IF Lx_Prod_Rec.Product_Id IS NOT NULL THEN
        OPEN  Lx_Csr_CovProd (Lx_Prod_Rec.Product_Id,Idx.Org_Id,Idx.Organization_Id);
        FETCH Lx_Csr_CovProd INTO Lv_Prod_Name;
        CLOSE Lx_Csr_CovProd;
      END IF;

      Lx_Item_Rec	                          := OKS_ENT_UTIL_PVT.Get_InvItem(Idx.Id,Idx.Organization_Id);
      Lx_Sys_Rec		                      := OKS_ENT_UTIL_PVT.Get_System(Idx.Id,Idx.Org_Id);

      Lx_Party_Rec	                          := OKS_ENT_UTIL_PVT.Get_CLvl_Party(Idx.Id);
      Lx_CustAc_Rec                           := OKS_ENT_UTIL_PVT.Get_CLvl_Customer(Idx.Id);
      Lx_Site_Rec 	                          := OKS_ENT_UTIL_PVT.Get_CLvl_Site(Idx.Id, Idx.Org_Id);

--      Lx_QtyRate_Rec	                      := OKS_ENT_UTIL_PVT.Get_QtyRate_Rule(Idx.Id); --null oks_k_lines_b , okc_k_lines_b
--      Ln_ListPrice		                  := TO_NUMBER(OKS_ENT_UTIL_PVT.Get_PriceList(NULL,Idx.Id,'P'));

      Lx_Covered_Levels(Li_TableIdx).Row_Id		               := Idx.RowId;
      Lx_Covered_Levels(Li_TableIdx).Line_Id		           := Idx.Id;
      Lx_Covered_Levels(Li_TableIdx).Header_Id		           := Idx.Dnz_Chr_Id;
      Lx_Covered_Levels(Li_TableIdx).Parent_Line_Id	           := Idx.Cle_Id;
      Lx_Covered_Levels(Li_TableIdx).Line_Level		           := Idx.Name;
      Lx_Covered_Levels(Li_TableIdx).Cp_Id		               := Lx_Prod_Rec.Product_Id;
      Lx_Covered_Levels(Li_TableIdx).Quantity		           := Lx_Prod_Rec.Product_Qty;
      Lx_Covered_Levels(Li_TableIdx).Cp_Name                   := Lv_Prod_Name;
      Lx_Covered_Levels(Li_TableIdx).Inv_Item_Id               := Lx_Item_Rec.Inv_Item_Id;
      Lx_Covered_Levels(Li_TableIdx).item_name	               := Lx_Item_Rec.Item_name;
      Lx_Covered_Levels(Li_TableIdx).system_id	               := Lx_Sys_Rec.System_Id;
      Lx_Covered_Levels(Li_TableIdx).system_name	           := Lx_Sys_Rec.System_Name;
      Lx_Covered_Levels(Li_TableIdx).Site_Id	               := Lx_Site_Rec.Site_Id;
      Lx_Covered_Levels(Li_TableIdx).Site_Name	               := Lx_Site_Rec.Site_Name;
      Lx_Covered_Levels(Li_TableIdx).Party_Id	               := Lx_Party_Rec.Party_Id;
      Lx_Covered_Levels(Li_TableIdx).Party_Name	               := Lx_Party_Rec.Party_Name;
      Lx_Covered_Levels(Li_TableIdx).Customer_Id	           := Lx_CustAc_Rec.Customer_Id;
      Lx_Covered_Levels(Li_TableIdx).Customer_Name	           := Lx_CustAc_Rec.Customer_Name;
      Lx_Covered_Levels(Li_TableIdx).List_Price		           := Ln_ListPrice;
      Lx_Covered_Levels(Li_TableIdx).Price_Negotiated	       := Idx.Price_Negotiated;
      Lx_Covered_Levels(Li_TableIdx).Line_Name		           := Idx.Name;
      Lx_Covered_Levels(Li_TableIdx).Default_AMCV_Flag	       := Lx_QtyRate_Rec.Default_AMCV_Flag;
      Lx_Covered_Levels(Li_TableIdx).Default_Qty	           := Lx_QtyRate_Rec.Default_Qty;
      Lx_Covered_Levels(Li_TableIdx).Default_UOM	           := Lx_QtyRate_Rec.Default_UOM;
      Lx_Covered_Levels(Li_TableIdx).Default_Duration	       := Lx_QtyRate_Rec.Default_Duration;
      Lx_Covered_Levels(Li_TableIdx).Default_Period	           := Lx_QtyRate_Rec.Default_Period;
      Lx_Covered_Levels(Li_TableIdx).Minimum_Qty	           := Lx_QtyRate_Rec.Minimum_Qty;
      Lx_Covered_Levels(Li_TableIdx).Minimum_UOM	           := Lx_QtyRate_Rec.Minimum_UOM;
      Lx_Covered_Levels(Li_TableIdx).Minimum_Duration	       := Lx_QtyRate_Rec.Minimum_Duration;
      Lx_Covered_Levels(Li_TableIdx).Minimum_Period	           := Lx_QtyRate_Rec.Minimum_Period;
      Lx_Covered_Levels(Li_TableIdx).Fixed_Qty		           := Lx_QtyRate_Rec.Fixed_Qty;
      Lx_Covered_Levels(Li_TableIdx).Fixed_UOM		           := Lx_QtyRate_Rec.Fixed_UOM;
      Lx_Covered_Levels(Li_TableIdx).Fixed_Duration	           := Lx_QtyRate_Rec.Fixed_Duration;
      Lx_Covered_Levels(Li_TableIdx).Fixed_Period	           := Lx_QtyRate_Rec.Fixed_Period;
      Lx_Covered_Levels(Li_TableIdx).Level_Flag		           := Lx_QtyRate_Rec.Level_Flag;

    END LOOP;

ELSE  -- if lx_cle_id is not null

    FOR Idx IN Lx_Csr_CovLvl(Lx_Cle_Id)  LOOP

      Li_TableIdx                     := Li_TableIdx + 1;

      Lv_Prod_Name                    := NULL;
      Lx_Prod_Rec		      := OKS_ENT_UTIL_PVT.Get_Product(Idx.Id);

      IF Lx_Prod_Rec.Product_Id IS NOT NULL THEN
        OPEN  Lx_Csr_CovProd (Lx_Prod_Rec.Product_Id,Idx.Org_Id,Idx.Organization_Id);
        FETCH Lx_Csr_CovProd INTO Lv_Prod_Name;
        CLOSE Lx_Csr_CovProd;
      END IF;

      Lx_Item_Rec	                          := OKS_ENT_UTIL_PVT.Get_InvItem(Idx.Id,Idx.Organization_Id);
      Lx_Sys_Rec		                      := OKS_ENT_UTIL_PVT.Get_System(Idx.Id,Idx.Org_Id);

      Lx_Party_Rec	                          := OKS_ENT_UTIL_PVT.Get_CLvl_Party(Idx.Id);
      Lx_CustAc_Rec                           := OKS_ENT_UTIL_PVT.Get_CLvl_Customer(Idx.Id);
      Lx_Site_Rec 	                          := OKS_ENT_UTIL_PVT.Get_CLvl_Site(Idx.Id, Idx.Org_Id);

--      Lx_QtyRate_Rec	                      := OKS_ENT_UTIL_PVT.Get_QtyRate_Rule(Idx.Id); --null oks_k_lines_b , okc_k_lines_b
--      Ln_ListPrice		                  := TO_NUMBER(OKS_ENT_UTIL_PVT.Get_PriceList(NULL,Idx.Id,'P'));

      Lx_Covered_Levels(Li_TableIdx).Row_Id		               := Idx.RowId;
      Lx_Covered_Levels(Li_TableIdx).Line_Id		           := Idx.Id;
      Lx_Covered_Levels(Li_TableIdx).Header_Id		           := Idx.Dnz_Chr_Id;
      Lx_Covered_Levels(Li_TableIdx).Parent_Line_Id	           := Idx.Cle_Id;
      Lx_Covered_Levels(Li_TableIdx).Line_Level		           := Idx.Name;
      Lx_Covered_Levels(Li_TableIdx).Cp_Id		               := Lx_Prod_Rec.Product_Id;
      Lx_Covered_Levels(Li_TableIdx).Quantity		           := Lx_Prod_Rec.Product_Qty;
      Lx_Covered_Levels(Li_TableIdx).Cp_Name                   := Lv_Prod_Name;
      Lx_Covered_Levels(Li_TableIdx).Inv_Item_Id               := Lx_Item_Rec.Inv_Item_Id;
      Lx_Covered_Levels(Li_TableIdx).item_name	               := Lx_Item_Rec.Item_name;
      Lx_Covered_Levels(Li_TableIdx).system_id	               := Lx_Sys_Rec.System_Id;
      Lx_Covered_Levels(Li_TableIdx).system_name	           := Lx_Sys_Rec.System_Name;
      Lx_Covered_Levels(Li_TableIdx).Site_Id	               := Lx_Site_Rec.Site_Id;
      Lx_Covered_Levels(Li_TableIdx).Site_Name	               := Lx_Site_Rec.Site_Name;
      Lx_Covered_Levels(Li_TableIdx).Party_Id	               := Lx_Party_Rec.Party_Id;
      Lx_Covered_Levels(Li_TableIdx).Party_Name	               := Lx_Party_Rec.Party_Name;
      Lx_Covered_Levels(Li_TableIdx).Customer_Id	           := Lx_CustAc_Rec.Customer_Id;
      Lx_Covered_Levels(Li_TableIdx).Customer_Name	           := Lx_CustAc_Rec.Customer_Name;
      Lx_Covered_Levels(Li_TableIdx).List_Price		           := Ln_ListPrice;
      Lx_Covered_Levels(Li_TableIdx).Price_Negotiated	       := Idx.Price_Negotiated;
      Lx_Covered_Levels(Li_TableIdx).Line_Name		           := Idx.Name;
      Lx_Covered_Levels(Li_TableIdx).Default_AMCV_Flag	       := Lx_QtyRate_Rec.Default_AMCV_Flag;
      Lx_Covered_Levels(Li_TableIdx).Default_Qty	           := Lx_QtyRate_Rec.Default_Qty;
      Lx_Covered_Levels(Li_TableIdx).Default_UOM	           := Lx_QtyRate_Rec.Default_UOM;
      Lx_Covered_Levels(Li_TableIdx).Default_Duration	       := Lx_QtyRate_Rec.Default_Duration;
      Lx_Covered_Levels(Li_TableIdx).Default_Period	           := Lx_QtyRate_Rec.Default_Period;
      Lx_Covered_Levels(Li_TableIdx).Minimum_Qty	           := Lx_QtyRate_Rec.Minimum_Qty;
      Lx_Covered_Levels(Li_TableIdx).Minimum_UOM	           := Lx_QtyRate_Rec.Minimum_UOM;
      Lx_Covered_Levels(Li_TableIdx).Minimum_Duration	       := Lx_QtyRate_Rec.Minimum_Duration;
      Lx_Covered_Levels(Li_TableIdx).Minimum_Period	           := Lx_QtyRate_Rec.Minimum_Period;
      Lx_Covered_Levels(Li_TableIdx).Fixed_Qty		           := Lx_QtyRate_Rec.Fixed_Qty;
      Lx_Covered_Levels(Li_TableIdx).Fixed_UOM		           := Lx_QtyRate_Rec.Fixed_UOM;
      Lx_Covered_Levels(Li_TableIdx).Fixed_Duration	           := Lx_QtyRate_Rec.Fixed_Duration;
      Lx_Covered_Levels(Li_TableIdx).Fixed_Period	           := Lx_QtyRate_Rec.Fixed_Period;
      Lx_Covered_Levels(Li_TableIdx).Level_Flag		           := Lx_QtyRate_Rec.Level_Flag;

    END LOOP;
 END IF; -- End of lx_cle_id is null

/* Commented by Jvorugan for Bug:4998337
   FOR Idx IN Lx_Csr_CovLvl(Lx_Cle_Id)  LOOP

      Li_TableIdx                     := Li_TableIdx + 1;

      Lv_Prod_Name                    := NULL;
      Lx_Prod_Rec                     := OKS_ENT_UTIL_PVT.Get_Product(Idx.Id);

      IF Lx_Prod_Rec.Product_Id IS NOT NULL THEN
        OPEN  Lx_Csr_CovProd (Lx_Prod_Rec.Product_Id,Idx.Org_Id,Idx.Organization_Id);
        FETCH Lx_Csr_CovProd INTO Lv_Prod_Name;
        CLOSE Lx_Csr_CovProd;
      END IF;

      Lx_Item_Rec                                 := OKS_ENT_UTIL_PVT.Get_InvItem(Idx.Id,Idx.Organization_Id);
      Lx_Sys_Rec                                      := OKS_ENT_UTIL_PVT.Get_System(Idx.Id,Idx.Org_Id);

      Lx_Party_Rec                                := OKS_ENT_UTIL_PVT.Get_CLvl_Party(Idx.Id);
      Lx_CustAc_Rec                           := OKS_ENT_UTIL_PVT.Get_CLvl_Customer(Idx.Id);
      Lx_Site_Rec                                 := OKS_ENT_UTIL_PVT.Get_CLvl_Site(Idx.Id, Idx.Org_Id);

--      Lx_QtyRate_Rec                        := OKS_ENT_UTIL_PVT.Get_QtyRate_Rule(Idx.Id); --null oks_k_lines_b , okc_k_lines_b
--      Ln_ListPrice                              := TO_NUMBER(OKS_ENT_UTIL_PVT.Get_PriceList(NULL,Idx.Id,'P'));

      Lx_Covered_Levels(Li_TableIdx).Row_Id                            := Idx.RowId;
      Lx_Covered_Levels(Li_TableIdx).Line_Id                       := Idx.Id;
      Lx_Covered_Levels(Li_TableIdx).Header_Id                     := Idx.Dnz_Chr_Id;
      Lx_Covered_Levels(Li_TableIdx).Parent_Line_Id                := Idx.Cle_Id;
      Lx_Covered_Levels(Li_TableIdx).Line_Level                    := Idx.Name;
      Lx_Covered_Levels(Li_TableIdx).Cp_Id                             := Lx_Prod_Rec.Product_Id;
      Lx_Covered_Levels(Li_TableIdx).Quantity                      := Lx_Prod_Rec.Product_Qty;
      Lx_Covered_Levels(Li_TableIdx).Cp_Name                   := Lv_Prod_Name;
      Lx_Covered_Levels(Li_TableIdx).Inv_Item_Id               := Lx_Item_Rec.Inv_Item_Id;
      Lx_Covered_Levels(Li_TableIdx).item_name                 := Lx_Item_Rec.Item_name;
      Lx_Covered_Levels(Li_TableIdx).system_id                 := Lx_Sys_Rec.System_Id;
      Lx_Covered_Levels(Li_TableIdx).system_name                   := Lx_Sys_Rec.System_Name;
      Lx_Covered_Levels(Li_TableIdx).Site_Id                   := Lx_Site_Rec.Site_Id;
      Lx_Covered_Levels(Li_TableIdx).Site_Name                 := Lx_Site_Rec.Site_Name;
      Lx_Covered_Levels(Li_TableIdx).Party_Id                  := Lx_Party_Rec.Party_Id;
      Lx_Covered_Levels(Li_TableIdx).Party_Name                := Lx_Party_Rec.Party_Name;
      Lx_Covered_Levels(Li_TableIdx).Customer_Id                   := Lx_CustAc_Rec.Customer_Id;
      Lx_Covered_Levels(Li_TableIdx).Customer_Name                 := Lx_CustAc_Rec.Customer_Name;
      Lx_Covered_Levels(Li_TableIdx).List_Price                    := Ln_ListPrice;
      Lx_Covered_Levels(Li_TableIdx).Price_Negotiated          := Idx.Price_Negotiated;
      Lx_Covered_Levels(Li_TableIdx).Line_Name                     := Idx.Name;
      Lx_Covered_Levels(Li_TableIdx).Default_AMCV_Flag         := Lx_QtyRate_Rec.Default_AMCV_Flag;
      Lx_Covered_Levels(Li_TableIdx).Default_Qty                   := Lx_QtyRate_Rec.Default_Qty;
      Lx_Covered_Levels(Li_TableIdx).Default_UOM                   := Lx_QtyRate_Rec.Default_UOM;
      Lx_Covered_Levels(Li_TableIdx).Default_Duration          := Lx_QtyRate_Rec.Default_Duration;
      Lx_Covered_Levels(Li_TableIdx).Default_Period                := Lx_QtyRate_Rec.Default_Period;
      Lx_Covered_Levels(Li_TableIdx).Minimum_Qty                   := Lx_QtyRate_Rec.Minimum_Qty;
      Lx_Covered_Levels(Li_TableIdx).Minimum_UOM                   := Lx_QtyRate_Rec.Minimum_UOM;
      Lx_Covered_Levels(Li_TableIdx).Minimum_Duration          := Lx_QtyRate_Rec.Minimum_Duration;
      Lx_Covered_Levels(Li_TableIdx).Minimum_Period                := Lx_QtyRate_Rec.Minimum_Period;
      Lx_Covered_Levels(Li_TableIdx).Fixed_Qty                     := Lx_QtyRate_Rec.Fixed_Qty;
      Lx_Covered_Levels(Li_TableIdx).Fixed_UOM                     := Lx_QtyRate_Rec.Fixed_UOM;
      Lx_Covered_Levels(Li_TableIdx).Fixed_Duration                := Lx_QtyRate_Rec.Fixed_Duration;
      Lx_Covered_Levels(Li_TableIdx).Fixed_Period                  := Lx_QtyRate_Rec.Fixed_Period;
      Lx_Covered_Levels(Li_TableIdx).Level_Flag                    := Lx_QtyRate_Rec.Level_Flag;

    END LOOP;
  */

    X_Covered_Levels      := Lx_Covered_Levels;
    X_Result              := Lx_Result;
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
	,P_Token2_Value   => 'Get_Coverage_Level_Details');

      X_Result         := G_FALSE;
      X_Return_Status  := G_RET_STS_UNEXP_ERROR;

  END Get_Coverage_Level_Details;

-----------------------------------------------------------------------------------------------------------------------*

  PROCEDURE Get_Coverage_Levels
    (P_API_Version		IN  NUMBER
    ,P_Init_Msg_List		IN  VARCHAR2
    ,P_Contract_Line_Id	        IN  NUMBER
    ,X_Return_Status 		OUT NOCOPY VARCHAR2
    ,X_Msg_Count		OUT NOCOPY NUMBER
    ,X_Msg_Data			OUT NOCOPY VARCHAR2
    ,X_Covered_Levels		OUT NOCOPY Clvl_Tbl_Type)
  IS

    Lx_Result                   Gx_Boolean;

  BEGIN

    Get_Coverage_Level_Details
      (P_API_Version		  => P_API_Version
      ,P_Init_Msg_List		  => P_Init_Msg_List
      ,P_Cle_Id	                  => P_Contract_Line_Id
      ,X_Covered_Levels 	  => X_Covered_Levels
      ,X_Msg_Count		  => X_Msg_Count
      ,X_Msg_Data		  => X_Msg_Data
      ,X_Result                   => Lx_Result
      ,X_Return_Status            => X_Return_Status);

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
	,P_Token2_Value   => 'Get_Coverage_Levels');

      --X_Result         := G_FALSE;
      X_Return_Status  := G_RET_STS_UNEXP_ERROR;

  END Get_Coverage_Levels;

-----------------------------------------------------------------------------------------------------------------------*

  PROCEDURE Get_Coverage_Type_Attribs
    (P_CVL_Id                   IN  Gx_OKS_Id
    ,P_Set_ExcepionStack        IN  Gx_Boolean
    ,X_Cov_Type_Code            out nocopy VARCHAR2
    ,X_Cov_Type_Meaning         out nocopy VARCHAR2
    ,X_Cov_Type_Description     out nocopy VARCHAR2
    ,X_Cov_Type_Imp_Level       out nocopy VARCHAR2
    ,X_Result                   out nocopy Gx_Boolean
    ,X_Return_Status            out nocopy Gx_Ret_Sts)
  IS

    CURSOR Lx_Csr_CovType(Cx_CVL_Id IN Gx_OKS_Id) IS
    SELECT CVT.Code
          ,CVT.Meaning
          ,CVT.Description
          ,CVT.Importance_Level
      FROM OKS_K_Lines_B OKSLB
          ,OKS_Cov_Types_V CVT
     WHERE OKSLB.Cle_Id = Cx_CVL_Id
       AND OKSLB.Coverage_Type = CVT.Code;

    Lx_CVL_Id	                CONSTANT Gx_OKS_Id := P_CVL_Id;
    Lx_Set_ExcepionStack        CONSTANT Gx_Boolean := P_Set_ExcepionStack;

    Lx_Cov_Type_Code            Oks_Cov_Types_B.Code%TYPE;
    Lx_Cov_Type_Meaning         Oks_Cov_Types_TL.Meaning%TYPE;
    Lx_Cov_Type_Description     Oks_Cov_Types_TL.Description%TYPE;
    Lx_Cov_Type_Imp_Level       Oks_Cov_Types_B.Importance_Level%TYPE;

    Lx_Result                   Gx_Boolean;
    Lx_Return_Status            Gx_Ret_Sts;

    L_EXCEP_NO_DATA_FOUND       EXCEPTION;

  BEGIN

    Lx_Result                   := G_TRUE;
    Lx_Return_Status            := G_RET_STS_SUCCESS;

    OPEN Lx_Csr_CovType(Lx_CVL_Id);
    FETCH Lx_Csr_CovType INTO Lx_Cov_Type_Code,Lx_Cov_Type_Meaning,Lx_Cov_Type_Description,Lx_Cov_Type_Imp_Level;

    IF Lx_Csr_CovType%NOTFOUND THEN

      CLOSE Lx_Csr_CovType;
      RAISE L_EXCEP_NO_DATA_FOUND;

    END IF;

    CLOSE Lx_Csr_CovType;

    X_Cov_Type_Code         :=  Lx_Cov_Type_Code;
    X_Cov_Type_Meaning      :=  Lx_Cov_Type_Meaning;
    X_Cov_Type_Description  :=  Lx_Cov_Type_Description;
    X_Cov_Type_Imp_Level    :=  Lx_Cov_Type_Imp_Level;

    X_Result                := Lx_Result;
    X_Return_Status         := Lx_Return_Status;

  EXCEPTION

    WHEN L_EXCEP_NO_DATA_FOUND THEN

      Lx_Result   := G_FALSE;

      IF Lx_Set_ExcepionStack = G_TRUE THEN

        OKC_API.SET_MESSAGE
          (p_app_name	   => G_APP_NAME_OKC
	  ,p_msg_name	   => G_INVALID_VALUE
	  ,p_token1	   => G_COL_NAME_TOKEN
	  ,p_token1_value  => 'Coverage Type');

        Lx_Return_Status  := G_RET_STS_ERROR;

      END IF;

      X_Result            := Lx_Result;
      X_Return_Status     := Lx_Return_Status;

    WHEN OTHERS THEN

      IF Lx_Csr_CovType%ISOPEN THEN
        CLOSE Lx_Csr_CovType;
      END IF;

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
	,P_Token2_Value   => 'Get_Coverage_Type_Attribs');

      X_Result            := G_FALSE;
      X_Return_Status     := G_RET_STS_UNEXP_ERROR;

  END Get_Coverage_Type_Attribs;

-----------------------------------------------------------------------------------------------------------------------*

  PROCEDURE Get_Cont_Coverage_Type
    (P_API_Version		IN  NUMBER
    ,P_Init_Msg_List		IN  VARCHAR2
    ,P_SVL_Id                   IN  Gx_OKS_Id
    ,P_Set_ExcepionStack        IN  Gx_Boolean
    ,X_Coverage_Type            out nocopy CovType_Rec_Type
    ,X_Msg_Count		OUT NOCOPY NUMBER
    ,X_Msg_Data			OUT NOCOPY VARCHAR2
    ,X_Result                   out nocopy Gx_Boolean
    ,X_Return_Status            out nocopy Gx_Ret_Sts)
  IS

    Lx_SVL_Id	                CONSTANT Gx_OKS_Id := P_SVL_Id;
    Lx_Set_ExcepionStack        CONSTANT Gx_Boolean := P_Set_ExcepionStack;

    Ld_SVL_Start                DATE;
    Ld_SVL_End                  DATE;
    Ld_SVL_Terminated           DATE;

    Lx_CVL_Id                   Gx_OKS_Id;
    Ld_CVL_Start                DATE;
    Ld_CVL_End                  DATE;
    Ld_CVL_Terminated           DATE;

    Lx_Cov_Type_Code            Oks_Cov_Types_B.Code%TYPE;
    Lx_Cov_Type_Meaning         Oks_Cov_Types_TL.Meaning%TYPE;
    Lx_Cov_Type_Description     Oks_Cov_Types_TL.Description%TYPE;
    Lx_Cov_Type_Imp_Level       Oks_Cov_Types_B.Importance_Level%TYPE;

    Lx_Result                   Gx_Boolean;
    Lx_Return_Status            Gx_Ret_Sts;

    L_EXCEP_NULL_VALUE          EXCEPTION;
    L_EXCEP_NO_DATA_FOUND       EXCEPTION;

    -- Added for 12.0 Coverage Rearch project (JVARGHES)

    Lv_Std_Cov_YN              VARCHAR2(10);

    --

  BEGIN

    Lx_Result                   := G_TRUE;
    Lx_Return_Status            := G_RET_STS_SUCCESS;

    Validate_Required_NumValue
      (P_Num_Value             => Lx_SVL_Id
      ,P_Set_ExcepionStack     => Lx_Set_ExcepionStack
      ,P_ExcepionMsg           => 'Contract Line'
      ,X_Result                => Lx_result
      ,X_Return_Status         => Lx_Return_Status);

    IF Lx_result <> G_TRUE  THEN
       RAISE L_EXCEP_NULL_VALUE;
    END IF;

    --
    -- Modified for 12.0 Coverage Rearch project (JVARGHES)
    --
    --Validate_Service_Line
    --  (P_SVL_Id	                => Lx_SVL_Id
    --  ,P_Set_ExcepionStack      => Lx_Set_ExcepionStack
    --  ,X_SVL_Start              => Ld_SVL_Start
    --  ,X_SVL_End                => Ld_SVL_End
    --  ,X_SVL_Terminated         => Ld_SVL_Terminated
    --  ,X_Result                 => Lx_Result
    --  ,X_Return_Status 	    => Lx_Return_Status);
    --
    -- Added for 12.0 Coverage Rearch project (JVARGHES)
    --
    --

      Validate_Service_Line
        (P_SVL_Id	           => Lx_SVL_Id
        ,P_Set_ExcepionStack => Lx_Set_ExcepionStack
        ,X_CVL_Id	           => Lx_CVL_Id
        ,X_Std_Cov_YN	     => Lv_Std_Cov_YN
        ,X_SVL_Start         => Ld_SVL_Start
        ,X_SVL_End           => Ld_SVL_End
        ,X_SVL_Terminated    => Ld_SVL_Terminated
        ,X_Result            => Lx_Result
        ,X_Return_Status     => Lx_Return_Status);

    --

    IF Lx_Result <> G_TRUE  THEN
      RAISE L_EXCEP_NO_DATA_FOUND;
    END IF;

    --
    -- Modified for 12.0 Coverage Rearch project (JVARGHES)
    --
    --Validate_Coverage_Line
    --  (P_SVL_Id	              =>  Lx_SVL_Id
    --  ,P_template_YN            => 'N'
    --  ,P_Set_ExcepionStack      => G_FALSE
    --  ,X_CVL_Id                 => Lx_CVL_Id
    --  ,X_CVL_Start              => Ld_CVL_Start
    --  ,X_CVL_End                => Ld_CVL_End
    --  ,X_CVL_Terminated         => Ld_CVL_Terminated
    --  ,X_Result                 => Lx_Result
    --  ,X_Return_Status 	        => Lx_Return_Status);
    --
    --
    -- Added for 12.0 Coverage Rearch project (JVARGHES)
    --

    Validate_Coverage_Line
     (P_CVL_Id	             => Lx_CVL_Id
     ,P_Set_ExcepionStack      => Lx_Set_ExcepionStack
     ,X_CVL_Start              => Ld_CVL_Start
     ,X_CVL_End                => Ld_CVL_End
     ,X_CVL_Terminated         => Ld_CVL_Terminated
     ,X_Result                 => Lx_Result
     ,X_Return_Status 	       => Lx_Return_Status);

    IF Lx_Result <> G_TRUE  THEN
      RAISE L_EXCEP_NO_DATA_FOUND;
    END IF;

    IF NVL(Lv_Std_Cov_YN,'*') = 'Y'
    THEN

      Ld_CVL_Start      := Ld_SVL_Start;
      Ld_CVL_End        := Ld_SVL_End;
      Ld_CVL_Terminated := Ld_SVL_Terminated;

    END IF;

    --
    --

    Get_Coverage_Type_Attribs
      (P_CVL_Id                => Lx_CVL_Id
      ,P_Set_ExcepionStack     => G_FALSE
      ,X_Cov_Type_Code         => Lx_Cov_Type_Code
      ,X_Cov_Type_Meaning      => Lx_Cov_Type_Meaning
      ,X_Cov_Type_Description  => Lx_Cov_Type_Description
      ,X_Cov_Type_Imp_Level    => Lx_Cov_Type_Imp_Level
      ,X_Result                => Lx_Result
      ,X_Return_Status         => Lx_Return_Status);

    IF Lx_Result <> G_TRUE  THEN
      RAISE L_EXCEP_NO_DATA_FOUND;
    END IF;

    X_Coverage_Type.Code             :=  Lx_Cov_Type_Code;
    X_Coverage_Type.Meaning          :=  Lx_Cov_Type_Meaning;
    X_Coverage_Type.Importance_Level :=  Lx_Cov_Type_Imp_Level;

    X_Result                         := Lx_Result;
    X_Return_Status                  := Lx_Return_Status;

  EXCEPTION

    WHEN L_EXCEP_NULL_VALUE OR L_EXCEP_NO_DATA_FOUND THEN

      X_Result            := Lx_Result;
      X_Return_Status     := Lx_Return_Status;

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
	,P_Token2_Value   => 'Get_Cont_Coverage_Type');

      X_Result            := G_FALSE;
      X_Return_Status     := G_RET_STS_UNEXP_ERROR;

  END Get_Cont_Coverage_Type;

-----------------------------------------------------------------------------------------------------------------------*

  PROCEDURE Get_Coverage_Type
    (P_API_Version		IN  NUMBER
    ,P_Init_Msg_List		IN  VARCHAR2
    ,P_Contract_Line_Id	        IN  NUMBER
    ,X_Return_Status 		OUT NOCOPY VARCHAR2
    ,X_Msg_Count 	        out nocopy NUMBER
    ,X_Msg_Data		        out nocopy VARCHAR2
    ,X_Coverage_Type		OUT NOCOPY CovType_Rec_Type)

  IS

    Lx_Result                   Gx_Boolean;

  BEGIN

    Get_Cont_Coverage_Type
      (P_API_Version		=> P_API_Version
      ,P_Init_Msg_List		=> P_Init_Msg_List
      ,P_SVL_Id                 => P_Contract_Line_Id
      ,P_Set_ExcepionStack      => G_TRUE
      ,X_Coverage_Type          => X_Coverage_Type
      ,X_Msg_Count		=> X_Msg_Count
      ,X_Msg_Data		=> X_Msg_Data
      ,X_Result                 => Lx_Result
      ,X_Return_Status          => X_Return_Status);

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
	,P_Token2_Value   => 'Get_Coverage_Type');

      --X_Result         := G_FALSE;
      X_Return_Status  := G_RET_STS_UNEXP_ERROR;

  END Get_Coverage_Type;

-----------------------------------------------------------------------------------------------------------------------*

  PROCEDURE Get_Cont_Preferred_Engineers
    (P_API_Version		IN  NUMBER
    ,P_Init_Msg_List		IN  VARCHAR2
    ,P_SVL_Id	                IN  Gx_OKS_Id
    ,P_business_process_id		IN		NUMBER		-- added for 11.5.9 (patchset I) enhancement # 2467065
    ,P_request_date		      IN		DATE	    -- added for 11.5.9 (patchset I) enhancement # 2467065
    ,P_Set_ExcepionStack        IN  Gx_Boolean
    ,X_Pref_Engineers		OUT NOCOPY PrfEng_Tbl_Type
    ,X_Msg_Count		OUT NOCOPY NUMBER
    ,X_Msg_Data			OUT NOCOPY VARCHAR2
    ,X_Result                   out nocopy Gx_Boolean
    ,X_Return_Status            out nocopy Gx_Ret_Sts)
  IS

    --
    -- Modified for 12.0 Coverage Rearch project (JVARGHES)
    --

/*
    CURSOR Lx_Csr_PrefEngrs(Cx_SBL_Id IN Gx_OKS_Id,Ld_Request_Date IN Date) IS
    SELECT RSC.resource_id Resource_Id
   	      ,decode(RSC.category,'EMPLOYEE','RS_EMPLOYEE',RSC.category) Resource_Type
                    -- ,decode(RSC.Resource_Type,'EMPLOYEE','RS_EMPLOYEE',RSC.Resource_Type) Resource_Type
          ,cimbp.object1_id1
          ,con.primary_yn
          ,con.resource_class
      FROM JTF_RS_RESOURCE_EXTNS RSC --OKX_Resources_V RSC
          ,OKC_Contacts CON
          ,OKC_K_Party_Roles_B ROL
          ,OKC_K_Lines_B BPL
          ,OKC_K_Lines_B SBL
          ,OKC_K_Lines_B COV
          ,okc_k_items cimbp
     WHERE SBL.Id         = Cx_SBL_Id
       AND SBL.Lse_Id     IN (1,14,19)
       and cov.cle_id     = sbl.id
       and cov.lse_id     in (2,15,20)
       AND BPL.cle_id     = COV.id
       AND BPL.Lse_Id     IN (3,16,21)
       and bpl.id         = cimbp.cle_id
       and cimbp.object1_id1 = nvl(p_business_process_id,cimbp.object1_id1)
       AND trunc(nvl(Ld_Request_Date,sysdate)) >= trunc(bpl.start_date)
       and trunc(nvl(Ld_Request_Date,sysdate)) <= trunc(oks_entitlements_pvt.get_final_end_date(bpl.dnz_chr_id,bpl.end_date)) -- uptake grace period
       AND ROL.Cle_Id     = BPL.Id
       AND CON.Cpl_Id     = ROL.Id
       AND CON.Jtot_Object1_Code = 'OKX_RESOURCE'
       AND RSC.resource_id        = CON.Object1_Id1
		AND SBL.dnz_chr_id = BPL.dnz_chr_id
       	AND SBL.dnz_chr_id = COV.dnz_chr_id
       	AND BPL.dnz_chr_id = ROL.dnz_chr_id
       	AND ROL.dnz_chr_id = CON.dnz_chr_id

    UNION ALL

    SELECT RSG.Id1 Resource_Id
          ,RSG.Resource_Type Resource_Type
          ,cimbp.object1_id1
          ,con.primary_yn
          ,con.resource_class
      FROM OKS_Resource_Groups_V RSG
          ,OKC_Contacts CON
          ,OKC_K_Party_Roles_B ROL
          ,OKC_K_Lines_B BPL
          ,OKC_K_Lines_B SBL
          ,OKC_K_Lines_B COV
          ,okc_k_items cimbp
    WHERE  SBL.Id            = Cx_SBL_Id
       AND SBL.Lse_Id        IN (1,14,19)
       and cov.cle_id        = sbl.id
       and cov.lse_id        in (2,15,20)
       AND BPL.cle_id        = COV.id
       AND BPL.Lse_Id        IN (3,16,21)
       and bpl.id            = cimbp.cle_id
       and cimbp.object1_id1 = nvl(p_business_process_id,cimbp.object1_id1)
       AND trunc(nvl(Ld_Request_Date,sysdate)) >= trunc(bpl.start_date)
       and trunc(nvl(Ld_Request_Date,sysdate)) <= trunc(get_final_end_date(bpl.dnz_chr_id,bpl.end_date)) -- uptake grace period
       AND ROL.Cle_Id     = BPL.Id
       AND CON.Cpl_Id     = ROL.Id
       AND CON.Jtot_Object1_Code = 'OKS_RSCGROUP'
       AND RSG.Id1        = CON.Object1_Id1
       AND RSG.Id2        = CON.Object1_Id2
		AND SBL.dnz_chr_id = BPL.dnz_chr_id
       	AND SBL.dnz_chr_id = COV.dnz_chr_id
       	AND BPL.dnz_chr_id = ROL.dnz_chr_id
       	AND ROL.dnz_chr_id = CON.dnz_chr_id;
*/

    --
    -- Modified for 12.0 Coverage Rearch project (JVARGHES)
    --

    CURSOR Lx_Csr_PrefEngrs(Cx_SBL_Id IN Gx_OKS_Id) IS
    SELECT RSC.resource_id Resource_Id
          ,decode(RSC.category,'EMPLOYEE','RS_EMPLOYEE',RSC.category) Resource_Type
          -- ,decode(RSC.Resource_Type,'EMPLOYEE','RS_EMPLOYEE',RSC.Resource_Type) Resource_Type
          ,cimbp.object1_id1
          ,con.primary_yn
          ,con.resource_class
          ,bpl.start_date bpl_start_date
          ,bpl.end_date bpl_end_date
          ,ksl.Standard_Cov_YN Standard_Cov_YN
          ,bpl.id bpl_id
          ,ksl.dnz_chr_id ksl_dnz_chr_id

      FROM JTF_RS_RESOURCE_EXTNS RSC --OKX_Resources_V RSC
          ,OKC_Contacts CON
          ,OKC_K_Party_Roles_B ROL
          ,OKC_K_Lines_B BPL
          ,okc_k_items cimbp
          ,oks_k_lines_b ksl
     WHERE ksl.cle_id     = Cx_SBL_Id
       AND BPL.cle_id     = ksl.Coverage_Id
       AND BPL.Lse_Id     IN (3,16,21)
       and bpl.id         = cimbp.cle_id
       and cimbp.object1_id1 = nvl(p_business_process_id,cimbp.object1_id1)
       AND ROL.Cle_Id     = BPL.Id
       AND CON.Cpl_Id     = ROL.Id
       AND CON.Jtot_Object1_Code = 'OKX_RESOURCE'
       AND RSC.resource_id        = CON.Object1_Id1
       --	AND BPL.dnz_chr_id = COV.dnz_chr_id
       	AND BPL.dnz_chr_id = ROL.dnz_chr_id
       	AND ROL.dnz_chr_id = CON.dnz_chr_id

    UNION ALL

    SELECT RSG.Id1 Resource_Id
          ,RSG.Resource_Type Resource_Type
          ,cimbp.object1_id1
          ,con.primary_yn
          ,con.resource_class
          ,bpl.start_date bpl_start_date
          ,bpl.end_date bpl_end_date
          ,ksl.Standard_Cov_YN  Standard_Cov_YN
          ,bpl.id bpl_id
          ,ksl.dnz_chr_id ksl_dnz_chr_id

      FROM OKS_Resource_Groups_V RSG
          ,OKC_Contacts CON
          ,OKC_K_Party_Roles_B ROL
          ,OKC_K_Lines_B BPL
          ,okc_k_items cimbp
          ,oks_k_lines_b ksl
    WHERE  ksl.cle_id     = Cx_SBL_Id
       AND BPL.cle_id     = ksl.Coverage_Id
       AND BPL.Lse_Id        IN (3,16,21)
       and bpl.id            = cimbp.cle_id
       and cimbp.object1_id1 = nvl(p_business_process_id,cimbp.object1_id1)
       AND ROL.Cle_Id     = BPL.Id
       AND CON.Cpl_Id     = ROL.Id
       AND CON.Jtot_Object1_Code = 'OKS_RSCGROUP'
       AND RSG.Id1        = CON.Object1_Id1
       AND RSG.Id2        = CON.Object1_Id2
       --	AND BPL.dnz_chr_id = COV.dnz_chr_id
       	AND BPL.dnz_chr_id = ROL.dnz_chr_id
       	AND ROL.dnz_chr_id = CON.dnz_chr_id;

--
--

    Lx_SBL_Id	              CONSTANT Gx_OKS_Id := P_SVL_Id;
    Lx_Set_ExcepionStack        CONSTANT Gx_Boolean := P_Set_ExcepionStack;
    Ld_Request_Date             CONSTANT Date := nvl(P_request_date,sysdate);
    Lx_Pref_Engineers 	        PrfEng_Tbl_Type;

    Li_TableIdx                 BINARY_INTEGER;

    Ld_SVL_Start                DATE;
    Ld_SVL_End                  DATE;
    Ld_SVL_Terminated           DATE;

    Ld_BPL_Start                DATE;
    Ld_BPL_End                  DATE;
    Ld_BPL_Terminated           DATE;

    Lx_Result                   Gx_Boolean;
    Lx_Return_Status            Gx_Ret_Sts;

    L_EXCEP_NULL_VALUE              EXCEPTION;
    L_EXCEP_UNEXPECTED_ERR          EXCEPTION;
    L_EXCEP_INVALID_CONTRACT_LINE   EXCEPTION;

    --
    -- Added for 12.0 Coverage Rearch project (JVARGHES)
    --

    Ln_CVL_Id                  NUMBER;
    Lv_Std_Cov_YN              VARCHAR2(10);

    --
    -- Added for 12.0 Coverage Rearch project (JVARGHES)
    --

    Ld_BPL_OFS_Start	       DATE;
    Ln_BPL_OFS_Duration	       NUMBER;
    Lv_BPL_OFS_UOM             VARCHAR2(100);

    L_EXCEP_NO_DATA_FOUND    EXCEPTION;
    --

  BEGIN

    Lx_Result                   := G_TRUE;
    Lx_Return_Status            := G_RET_STS_SUCCESS;

    G_GRACE_PROFILE_SET      := fnd_profile.value('OKS_ENABLE_GRACE_PERIOD');

    Validate_Required_NumValue
      (P_Num_Value           => Lx_SBL_Id
      ,P_Set_ExcepionStack   => Lx_Set_ExcepionStack
      ,P_ExcepionMsg         => 'Contract - Service/Business Process Line'
      ,X_Result              => Lx_result
      ,X_Return_Status       => Lx_Return_Status);

    IF Lx_result <> G_TRUE  THEN
      RAISE L_EXCEP_NULL_VALUE;
    END IF;

--
-- Modified for 12.0 Coverage Rearch project (JVARGHES)
--
--    Validate_Service_Line
--      (P_SVL_Id	              => Lx_SBL_Id
--      ,P_Set_ExcepionStack    => G_FALSE
--      ,X_SVL_Start            => Ld_SVL_Start
--      ,X_SVL_End              => Ld_SVL_End
--      ,X_SVL_Terminated       => Ld_SVL_Terminated
--     ,X_Result               => Lx_result
--      ,X_Return_Status 	      => Lx_Return_Status );
--
--
-- Added for 12.0 Coverage Rearch project (JVARGHES)
--
    Validate_Service_Line
      (P_SVL_Id	            => Lx_SBL_Id
      ,P_Set_ExcepionStack    => G_FALSE
      ,X_CVL_Id	            => Ln_CVL_Id
      ,X_Std_Cov_YN	      => Lv_Std_Cov_YN
      ,X_SVL_Start            => Ld_SVL_Start
      ,X_SVL_End              => Ld_SVL_End
      ,X_SVL_Terminated       => Ld_SVL_Terminated
      ,X_Result               => Lx_result
      ,X_Return_Status 	      => Lx_Return_Status );

--
--

    IF Lx_result <> G_TRUE  THEN
      RAISE L_EXCEP_NULL_VALUE;
    END IF;

    Li_TableIdx  := 0;

    FOR Idx IN Lx_Csr_PrefEngrs(Lx_SBL_Id) LOOP

--
-- Added for 12.0 Coverage Rearch project (JVARGHES)
--

      IF Idx.Standard_Cov_YN = 'Y' THEN

        Get_BP_Line_Start_Offset
         (P_BPL_Id	        => Idx.BPL_Id
         ,P_SVL_Start	        => Ld_SVL_Start
         ,X_BPL_OFS_Start	  => Ld_BPL_Start
         ,X_BPL_OFS_Duration	  => Ln_BPL_OFS_Duration
         ,X_BPL_OFS_UOM	        => Lv_BPL_OFS_UOM
         ,X_Return_Status 	  => Lx_Return_Status);

        IF Lx_Return_Status<> G_RET_STS_SUCCESS  THEN
           RAISE L_EXCEP_NO_DATA_FOUND;
         END IF;

         Ld_BPL_End    := Ld_SVL_End;

      ELSE

         Ld_BPL_Start  := Idx.BPL_Start_date;
         Ld_BPL_End    := Idx.BPL_End_Date;

      END IF;

   ld_bpl_end := oks_entitlements_pvt.get_final_end_date(idx.ksl_dnz_chr_id,Ld_BPL_End );

--

   IF trunc(nvl(Ld_Request_Date,sysdate)) between trunc(Ld_BPL_Start) and trunc(ld_bpl_end) then  -- Added for Coverage Rearch project (JVARGHES)

      Li_TableIdx           := Li_TableIdx + 1;

      Lx_Pref_Engineers(Li_TableIdx).Engineer_Id            := Idx.Resource_Id;
      Lx_Pref_Engineers(Li_TableIdx).Resource_Type          := Idx.Resource_Type;
      Lx_Pref_Engineers(Li_TableIdx).business_process_id    := to_number(Idx.object1_id1);
      Lx_Pref_Engineers(Li_TableIdx).primary_flag           := Idx.primary_yn;
      Lx_Pref_Engineers(Li_TableIdx).resource_class         := Idx.resource_class;

   END IF; -- Coverage Rearch project (JVARGHES)

    END LOOP;

    X_Pref_Engineers        := Lx_Pref_Engineers;
    X_Result                := Lx_Result;
    X_Return_Status         := Lx_Return_Status;

  EXCEPTION

    WHEN L_EXCEP_NULL_VALUE OR L_EXCEP_UNEXPECTED_ERR  THEN

      X_Result              := Lx_Result;
      X_Return_Status       := Lx_Return_Status;

    WHEN L_EXCEP_INVALID_CONTRACT_LINE THEN

      Lx_Result  := G_FALSE;

      IF Lx_Set_ExcepionStack = G_TRUE THEN

	OKC_API.SET_MESSAGE
          (P_App_Name	        => G_APP_NAME_OKC
          ,P_Msg_Name	        => G_INVALID_VALUE
	  ,P_Token1		=> G_COL_NAME_TOKEN
	  ,P_Token1_Value	=> 'Contract - Service/Business Process Line');

	Lx_Return_Status := G_RET_STS_ERROR;

      END IF;

      X_Result              := Lx_Result;
      X_Return_Status       := Lx_Return_Status;

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
	,P_Token2_Value   => 'Get_Cont_Preferred_Engineers');

      X_Result         := G_FALSE;
      X_Return_Status  := G_RET_STS_UNEXP_ERROR;

  END Get_Cont_Preferred_Engineers;

-----------------------------------------------------------------------------------------------------------------------*

  PROCEDURE get_preferred_engineers
	(p_api_version		IN  Number
	,p_init_msg_list		IN  Varchar2
	,p_contract_line_id	       IN  Number
    ,P_business_process_id		IN		NUMBER		-- added for 11.5.9 (patchset I) enhancement # 2467065
	,P_request_date		      IN		DATE	    -- added for 11.5.9 (patchset I) enhancement # 2467065
	,x_return_status 		out nocopy Varchar2
	,x_msg_count		out nocopy Number
	,x_msg_data			out nocopy Varchar2
	,x_prf_engineers		out nocopy prfeng_tbl_type)
  IS
    Lx_Result                   Gx_Boolean;
  BEGIN

    Get_Cont_Preferred_Engineers
      (P_API_Version		=> P_API_Version
      ,P_Init_Msg_List		=> P_Init_Msg_List
      ,P_SVL_Id	                => P_Contract_Line_Id
      ,P_business_process_id	=> P_business_process_id	-- added for 11.5.9 (patchset I) enhancement # 2467065
	  ,P_request_date		    => P_request_date    -- added for 11.5.9 (patchset I) enhancement # 2467065
      ,P_Set_ExcepionStack      => G_TRUE
      ,X_Pref_Engineers		=> X_Prf_Engineers
      ,X_Msg_Count		=> X_Msg_Count
      ,X_Msg_Data		=> X_Msg_Data
      ,X_Result                 => Lx_Result
      ,X_Return_Status          => X_Return_Status);

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
	,P_Token2_Value   => 'Get_Preferred_Engineers');

      --X_Result         := G_FALSE;
      X_Return_Status  := G_RET_STS_UNEXP_ERROR;

  END Get_Preferred_Engineers;

-----------------------------------------------------------------------------------------------------------------------*

   PROCEDURE Get_Contract_Contacts
    (P_API_Version		IN  NUMBER
    ,P_Init_Msg_List		IN  VARCHAR2
    ,P_Chr_Id                   IN  Gx_OKS_Id
    ,P_Cle_Id	                IN  Gx_OKS_Id
    ,X_Cont_Contacts		OUT NOCOPY Ent_Contact_Tbl
    ,X_Msg_Count		OUT NOCOPY NUMBER
    ,X_Msg_Data			OUT NOCOPY VARCHAR2
    ,X_Result                   out nocopy Gx_Boolean
    ,X_Return_Status            out nocopy Gx_Ret_Sts)
  IS

   -- getting resource based contacts for contract id.

    CURSOR Lx_Csr_Chr_RscContacts(Cx_Chr_Id IN  Gx_OKS_Id) IS
      SELECT PR.DNZ_CHR_ID CONTRACT_ID
	    ,CS.RESOURCE_ID	   CONTACT_ID
	    ,CS.CATEGORY RSC_CATEGORY
        ,NULL 	   CONTACT_NAME
	    ,PR.ID	   CONTACT_ROLE_ID
	    ,CO.CRO_CODE   CONTACT_ROLE_CODE
          ,HDR.ORG_ID  ORG_ID -- Modified for 12.0 MOAC project (JVARGHES)
	FROM JTF_RS_RESOURCE_EXTNS CS --OKX_RESOURCES_V CS
	    ,OKC_CONTACTS CO
	    ,OKC_K_PARTY_ROLES_B  PR
          ,OKC_K_HEADERS_ALL_B HDR  -- Modified for 12.0 MOAC project (JVARGHES)
       WHERE     PR.DNZ_CHR_ID  = Cx_Chr_Id

       -- Modified for 12.0 MOAC project (JVARGHES)
         AND HDR.ID = Cx_Chr_Id
         AND HDR.ID = PR.Dnz_Chr_Id

         and co.dnz_chr_id = pr.dnz_chr_id
	     AND CO.CPL_ID      = PR.ID
	     AND CO.OBJECT1_ID1	= CS.RESOURCE_ID --CS.ID1
	     AND CO.OBJECT1_ID2	= '#' --CS.ID2
         AND CO.JTOT_OBJECT1_CODE = 'OKX_RESOURCE';

   -- getting po agents based contacts for contract id.

    CURSOR Lx_Csr_Chr_POAContacts(Cx_Chr_Id IN  Gx_OKS_Id) IS
      SELECT PR.DNZ_CHR_ID CONTRACT_ID
	    ,POA.AGENT_ID  CONTACT_ID
	    ,'PO_AGENT' RSC_CATEGORY
        ,PER.FULL_NAME	   CONTACT_NAME
	    ,PR.ID	   CONTACT_ROLE_ID
	    ,CO.CRO_CODE   CONTACT_ROLE_CODE
	FROM PO_AGENTS POA --OKX_BUYERS_V CS
        ,PER_ALL_PEOPLE_F PER
	    ,OKC_CONTACTS CO
	    ,OKC_K_PARTY_ROLES_B  PR
       WHERE PR.DNZ_CHR_ID  = Cx_Chr_Id
         and co.dnz_chr_id = pr.dnz_chr_id
	     AND CO.CPL_ID      = PR.ID
	     AND CO.OBJECT1_ID1	= POA.AGENT_ID --CS.ID1
	     AND CO.OBJECT1_ID2	= '#' --CS.ID2
         AND CO.JTOT_OBJECT1_CODE = 'OKX_BUYER'
         and POA.AGENT_ID      =   PER.PERSON_ID
         and PER.EFFECTIVE_START_DATE = (SELECT MAX(A.EFFECTIVE_START_DATE) FROM PER_ALL_PEOPLE_F A
                                  WHERE A.PERSON_ID = PER.PERSON_ID);

   -- getting sales persons based contacts for contract id.

    CURSOR Lx_Csr_Chr_SRPContacts(Cx_Chr_Id IN  Gx_OKS_Id) IS
      SELECT PR.DNZ_CHR_ID CONTRACT_ID
	    ,S.SALESREP_ID	   CONTACT_ID
	    ,CS.CATEGORY RSC_CATEGORY
            ,TL.RESOURCE_NAME	   CONTACT_NAME
	    ,PR.ID	   CONTACT_ROLE_ID
	    ,CO.CRO_CODE   CONTACT_ROLE_CODE
	FROM JTF_RS_RESOURCE_EXTNS CS
            ,JTF_RS_SALESREPS S
            ,JTF_RS_RESOURCE_EXTNS_TL TL     -- Bug Fix #5442182 hmnair
	    ,OKC_CONTACTS CO
	    ,OKC_K_PARTY_ROLES_B  PR
            ,OKC_K_HEADERS_ALL_B HDR  -- Modified for 12.0 MOAC project (JVARGHES)
       WHERE PR.DNZ_CHR_ID  = Cx_Chr_Id
             AND co.dnz_chr_id = pr.dnz_chr_id
	     AND CO.CPL_ID      = PR.ID
	     AND CO.OBJECT1_ID1	= S.SALESREP_ID --CS.ID1
	     AND CO.OBJECT1_ID2	= '#' --CS.ID2
             AND CO.JTOT_OBJECT1_CODE = 'OKX_SALEPERS'

       -- Modified for 12.0 MOAC project (JVARGHES)
         AND HDR.ID = Cx_Chr_Id
         AND HDR.ID = PR.Dnz_Chr_Id
         AND S.ORG_ID = HDR.ORG_ID
       -- AND (S.ORG_ID = SYS_CONTEXT('OKC_CONTEXT','ORG_ID') OR  NVL(SYS_CONTEXT('OKC_CONTEXT','ORG_ID'),-99) = -99)
         AND S.RESOURCE_ID = CS.RESOURCE_ID
         AND CS.CATEGORY in ('EMPLOYEE','OTHER','PARTY','PARTNER','SUPPLIER_CONTACT')
         AND TL.RESOURCE_ID = CS.RESOURCE_ID  -- Bug Fix #5442182 hmnair
         AND TL.LANGUAGE = USERENV('LANG')
         AND TL.CATEGORY = CS.CATEGORY;

   -- getting resource based contacts for contract line id.

    CURSOR Lx_Csr_Cle_RscContacts(Cx_Cle_Id IN  Gx_OKS_Id,Cx_Chr_Id IN  Gx_OKS_Id) IS
      SELECT PR.DNZ_CHR_ID CONTRACT_ID
	    ,CS.RESOURCE_ID	   CONTACT_ID
	    ,CS.CATEGORY RSC_CATEGORY
          ,NULL 	   CONTACT_NAME
	    ,PR.ID	   CONTACT_ROLE_ID
	    ,CO.CRO_CODE   CONTACT_ROLE_CODE
          ,HDR.ORG_ID  ORG_ID -- Modified for 12.0 MOAC project (JVARGHES)
	FROM JTF_RS_RESOURCE_EXTNS CS --OKX_RESOURCES_V CS
	    ,OKC_CONTACTS CO
	    ,OKC_K_PARTY_ROLES_B  PR
          ,OKC_K_HEADERS_ALL_B HDR  -- Modified for 12.0 MOAC project (JVARGHES)
       WHERE  PR.DNZ_CHR_ID  = Cx_Chr_Id
         and PR.CLE_ID  = Cx_Cle_Id

         -- Modified for 12.0 MOAC project (JVARGHES)
         AND HDR.ID = Cx_Chr_Id
         AND HDR.ID = PR.Dnz_Chr_Id
         --
         and co.dnz_chr_id = pr.dnz_chr_id
	     AND CO.CPL_ID      = PR.ID
	     AND CO.OBJECT1_ID1	= CS.RESOURCE_ID --CS.ID1
	     AND CO.OBJECT1_ID2	= '#' --CS.ID2
         AND CO.JTOT_OBJECT1_CODE = 'OKX_RESOURCE';

   -- getting po agents based contacts for contract line id.

    CURSOR Lx_Csr_Cle_POAContacts(Cx_Cle_Id IN  Gx_OKS_Id,Cx_Chr_Id IN  Gx_OKS_Id) IS
      SELECT PR.DNZ_CHR_ID CONTRACT_ID
	    ,POA.AGENT_ID  CONTACT_ID
	    ,'PO_AGENT' RSC_CATEGORY
        ,PER.FULL_NAME	   CONTACT_NAME
	    ,PR.ID	   CONTACT_ROLE_ID
	    ,CO.CRO_CODE   CONTACT_ROLE_CODE
	FROM PO_AGENTS POA --OKX_BUYERS_V CS
        ,PER_ALL_PEOPLE_F PER
	    ,OKC_CONTACTS CO
	    ,OKC_K_PARTY_ROLES_B  PR
       WHERE PR.DNZ_CHR_ID  = Cx_Chr_Id
         and PR.CLE_ID  = Cx_Cle_Id
         and co.dnz_chr_id = pr.dnz_chr_id
	     AND CO.CPL_ID      = PR.ID
	     AND CO.OBJECT1_ID1	= POA.AGENT_ID --CS.ID1
	     AND CO.OBJECT1_ID2	= '#' --CS.ID2
         AND CO.JTOT_OBJECT1_CODE = 'OKX_BUYER'
         and POA.AGENT_ID      =   PER.PERSON_ID
         and PER.EFFECTIVE_START_DATE = (SELECT MAX(A.EFFECTIVE_START_DATE) FROM PER_ALL_PEOPLE_F A
                                  WHERE A.PERSON_ID = PER.PERSON_ID);


   -- getting sales persons based contacts for contract line id.

    CURSOR Lx_Csr_Cle_SRPContacts(Cx_Cle_Id IN  Gx_OKS_Id,Cx_Chr_Id IN  Gx_OKS_Id) IS
      SELECT PR.DNZ_CHR_ID CONTRACT_ID
	    ,S.SALESREP_ID	   CONTACT_ID
	    ,CS.CATEGORY RSC_CATEGORY
            ,TL.RESOURCE_NAME	   CONTACT_NAME   -- Bug Fix #5442182 hmnair
	    ,PR.ID	   CONTACT_ROLE_ID
	    ,CO.CRO_CODE   CONTACT_ROLE_CODE
	FROM JTF_RS_RESOURCE_EXTNS CS
            ,JTF_RS_SALESREPS S
            ,JTF_RS_RESOURCE_EXTNS_TL TL         -- Bug Fix #5442182 hmnair
	    ,OKC_CONTACTS CO
	    ,OKC_K_PARTY_ROLES_B  PR
            ,OKC_K_HEADERS_ALL_B HDR  -- Modified for 12.0 MOAC project (JVARGHES)
       WHERE PR.DNZ_CHR_ID  = Cx_Chr_Id
         and PR.CLE_ID  = Cx_Cle_Id
         and co.dnz_chr_id = pr.dnz_chr_id
	     AND CO.CPL_ID      = PR.ID
	     AND CO.OBJECT1_ID1	= S.SALESREP_ID --CS.ID1
	     AND CO.OBJECT1_ID2	= '#' --CS.ID2
         AND CO.JTOT_OBJECT1_CODE = 'OKX_SALEPERS'

     --  Modified for 12.0 MOAC project (JVARGHES)
         AND HDR.ID = Cx_Chr_Id
         AND HDR.ID = PR.Dnz_Chr_Id
         AND S.ORG_ID = HDR.Org_ID
     --  AND (S.ORG_ID = SYS_CONTEXT('OKC_CONTEXT','ORG_ID') OR  NVL(SYS_CONTEXT('OKC_CONTEXT','ORG_ID'),-99) = -99)
         AND S.RESOURCE_ID = CS.RESOURCE_ID
         AND CS.CATEGORY in ('EMPLOYEE','OTHER','PARTY','PARTNER','SUPPLIER_CONTACT')
         AND TL.RESOURCE_ID = CS.RESOURCE_ID     -- Bug Fix #5442182 hmnair
         AND TL.LANGUAGE = USERENV('LANG')
         AND TL.CATEGORY = CS.CATEGORY;


   CURSOR Lx_Csr_dnz_Chr(Cx_Cle_Id IN  Gx_OKS_Id) IS
      SELECT CLE.DNZ_CHR_ID CONTRACT_ID
      FROM   Okc_K_lines_B cle
      WHERE  cle.id = Cx_Cle_Id
      AND    rownum = 1;

-- for category 'SUPPLIER_CONTACT'

   CURSOR Lx_Csr_vndr_name(Cx_Resource_Id IN  number, cn_org_id in number) IS
      SELECT  C.LAST_NAME NAME
      FROM    JTF_RS_RESOURCE_EXTNS RSC ,
              PO_VENDOR_SITES_ALL S ,
              PO_VENDOR_CONTACTS C
      WHERE   RSC.RESOURCE_ID =    Cx_Resource_Id
      and     C.VENDOR_CONTACT_ID = RSC.SOURCE_ID
      and     S.VENDOR_SITE_ID = C.VENDOR_SITE_ID
      AND      S.ORG_ID = cn_org_id ;   -- Modified for 12.0 MOAC project (JVARGHES)
    --  AND     S.ORG_ID = sys_context('OKC_CONTEXT','ORG_ID');  -- Modified for 12.0 MOAC project (JVARGHES)

-- for category 'EMPLOYEE'

   CURSOR Lx_Csr_emp_name(Cx_Resource_Id IN  number) IS
      SELECT  PER.FULL_NAME NAME
      FROM    JTF_RS_RESOURCE_EXTNS RSC ,
              FND_USER U ,
              PER_ALL_PEOPLE_F PER
      WHERE   PER.PERSON_ID   =   RSC.SOURCE_ID
      and     U.USER_ID       =   RSC.USER_ID
      and     RSC.RESOURCE_ID =    Cx_Resource_Id
      and     PER.EFFECTIVE_START_DATE = (SELECT MAX(A.EFFECTIVE_START_DATE) FROM PER_ALL_PEOPLE_F A
                                  WHERE A.PERSON_ID = PER.PERSON_ID);

 -- for category 'PARTNER', 'PARTY'

   CURSOR Lx_Csr_pty_name(Cx_Resource_Id IN  number) IS
      SELECT PARTY.PARTY_NAME NAME
      FROM   JTF_RS_RESOURCE_EXTNS RSC ,
             FND_USER U ,
             HZ_PARTIES PARTY
      WHERE  RSC.CATEGORY IN ( 'PARTNER', 'PARTY')
      AND    PARTY.PARTY_ID = RSC.SOURCE_ID
      AND    U.USER_ID      = RSC.USER_ID
      and    RSC.RESOURCE_ID = Cx_Resource_Id;


 -- for category 'OTHER'

    CURSOR Lx_Csr_oth_name(Cx_Resource_Id IN  number, cn_org_id in number) IS
      SELECT TL.RESOURCE_NAME NAME         -- Bug Fix #5442182 hmnair
      FROM   JTF_RS_RESOURCE_EXTNS RSC ,
             FND_USER U ,
             JTF_RS_SALESREPS SRP
             ,JTF_RS_RESOURCE_EXTNS_TL TL    -- Bug Fix #5442182 hmnair
      WHERE  RSC.CATEGORY = 'OTHER'
      AND    SRP.RESOURCE_ID   = RSC.RESOURCE_ID
      AND    U.USER_ID = RSC.USER_ID
      AND    SRP.Org_ID = Cn_Org_Id    -- Modified for 12.0 MOAC project (JVARGHES)
      --AND    SRP.ORG_ID = sys_context  ('OKC_CONTEXT', 'ORG_ID') -- Modified for 12.0 MOAC project (JVARGHES)
      AND    TL.RESOURCE_ID = RSC.RESOURCE_ID   -- Bug Fix #5442182 hmnair
      AND    TL.LANGUAGE = USERENV('LANG')
      AND    TL.CATEGORY = RSC.CATEGORY
      and    RSC.RESOURCE_ID = Cx_Resource_Id;

-- cursor for building role meanings plsql table

    CURSOR Lx_Csr_Rle_lkup IS
      SELECT LU.LOOKUP_CODE CODE,
             LU.MEANING MEANING
      FROM   fnd_lookups lu
      WHERE  LU.LOOKUP_TYPE	= 'OKC_CONTACT_ROLE';


    Lx_Chr_Id                   CONSTANT Gx_OKS_Id := P_Chr_Id;
    Lx_Cle_Id	                CONSTANT Gx_OKS_Id := P_Cle_Id;

    Lx_Dnz_Chr_Id               Gx_OKS_Id ;

    Lx_Cont_Contacts		    Ent_Contact_Tbl;
    Lx_Result                   Gx_Boolean;
    Lx_Return_Status            Gx_Ret_Sts;
    l_Rle_Lkup_TBL              Rle_Lkup_TBL;

    Li_TableIdx                 BINARY_INTEGER;
    i                           BINARY_INTEGER;

  BEGIN

    Lx_Result                   := G_TRUE;
    Lx_Return_Status            := G_RET_STS_SUCCESS;

    i                           := 0;

   -- getting dnz_chr_id if cle_id passed to be used in sqls for performance reasons

    IF Lx_Cle_Id IS NOT NULL THEN

      FOR Idx IN Lx_Csr_dnz_Chr(Lx_Cle_Id) LOOP

         Lx_Dnz_Chr_Id  := Idx.Contract_Id;

      END LOOP;

    END IF;

    -- building role meaning plsql table for performance reasons.

    for Rle_lkup in Lx_Csr_Rle_lkup  loop
        i                          := i + 1;
        l_Rle_Lkup_TBL(i).code     := Rle_lkup.code;
        l_Rle_Lkup_TBL(i).meaning  := Rle_lkup.meaning;

    end loop;

    -- actual processing starts here..

    Li_TableIdx  := 0;

    -- building contacts output plsql table for jtf resource based contacts
    IF Lx_Cle_Id IS NOT NULL THEN

     FOR Idx IN Lx_Csr_Cle_RscContacts(Lx_Cle_Id,Lx_Dnz_Chr_Id) LOOP

        if Idx.Rsc_Category = 'SUPPLIER_CONTACT' then
            for Lx_Rec_vndr_name in Lx_Csr_vndr_name(Idx.Contact_Id, idx.org_id) loop
                for  i in l_Rle_Lkup_TBL.first..l_Rle_Lkup_TBL.last loop
                    if Idx.Contact_Role_Code = l_Rle_Lkup_TBL(i).code then
                        Li_TableIdx   := Li_TableIdx + 1;
                    	Lx_Cont_Contacts(Li_TableIdx).Contract_Id	 := Idx.Contract_Id;
                    	Lx_Cont_Contacts(Li_TableIdx).Contact_Id	 := Idx.Contact_Id;
                        Lx_Cont_Contacts(Li_TableIdx).Contact_Name  := Lx_Rec_vndr_name.name;
                    	Lx_Cont_Contacts(Li_TableIdx).Contact_Role_Id    := Idx.Contact_Role_Id;
                    	Lx_Cont_Contacts(Li_TableIdx).Contact_Role_Code  := Idx.Contact_Role_Code;
                        Lx_Cont_Contacts(Li_TableIdx).Contact_Role_Name  := l_Rle_Lkup_TBL(i).meaning;
                    end if;
                end loop;
            end loop;
        end if;

        if Idx.Rsc_Category = 'EMPLOYEE' then
            for Lx_rec_emp_name in Lx_Csr_emp_name(Idx.Contact_Id) loop
                for  i in l_Rle_Lkup_TBL.first..l_Rle_Lkup_TBL.last loop
                    if Idx.Contact_Role_Code = l_Rle_Lkup_TBL(i).code then
                        Li_TableIdx   := Li_TableIdx + 1;
                    	Lx_Cont_Contacts(Li_TableIdx).Contract_Id	 := Idx.Contract_Id;
                    	Lx_Cont_Contacts(Li_TableIdx).Contact_Id	 := Idx.Contact_Id;
                        Lx_Cont_Contacts(Li_TableIdx).Contact_Name  := Lx_rec_emp_name.name;
                    	Lx_Cont_Contacts(Li_TableIdx).Contact_Role_Id    := Idx.Contact_Role_Id;
                    	Lx_Cont_Contacts(Li_TableIdx).Contact_Role_Code  := Idx.Contact_Role_Code;
                        Lx_Cont_Contacts(Li_TableIdx).Contact_Role_Name  := l_Rle_Lkup_TBL(i).meaning;
                    end if;
                end loop;
            end loop;
        end if;


        if Idx.Rsc_Category in ('PARTNER','PARTY') then
            for Lx_rec_pty_name in Lx_Csr_pty_name(Idx.Contact_Id) loop
                for  i in l_Rle_Lkup_TBL.first..l_Rle_Lkup_TBL.last loop
                    if Idx.Contact_Role_Code = l_Rle_Lkup_TBL(i).code then
                        Li_TableIdx   := Li_TableIdx + 1;
                    	Lx_Cont_Contacts(Li_TableIdx).Contract_Id	 := Idx.Contract_Id;
                    	Lx_Cont_Contacts(Li_TableIdx).Contact_Id	 := Idx.Contact_Id;
                        Lx_Cont_Contacts(Li_TableIdx).Contact_Name  := Lx_rec_pty_name.name;
                    	Lx_Cont_Contacts(Li_TableIdx).Contact_Role_Id    := Idx.Contact_Role_Id;
                    	Lx_Cont_Contacts(Li_TableIdx).Contact_Role_Code  := Idx.Contact_Role_Code;
                        Lx_Cont_Contacts(Li_TableIdx).Contact_Role_Name  := l_Rle_Lkup_TBL(i).meaning;
                    end if;
                end loop;
            end loop;
        end if;

        if Idx.Rsc_Category = ('OTHER') then
            for Lx_rec_oth_name in Lx_Csr_oth_name(Idx.Contact_Id, idx.org_id) loop
                for  i in l_Rle_Lkup_TBL.first..l_Rle_Lkup_TBL.last loop
                    if Idx.Contact_Role_Code = l_Rle_Lkup_TBL(i).code then
                        Li_TableIdx   := Li_TableIdx + 1;
                    	Lx_Cont_Contacts(Li_TableIdx).Contract_Id	 := Idx.Contract_Id;
                    	Lx_Cont_Contacts(Li_TableIdx).Contact_Id	 := Idx.Contact_Id;
                        Lx_Cont_Contacts(Li_TableIdx).Contact_Name  := Lx_rec_oth_name.name;
                    	Lx_Cont_Contacts(Li_TableIdx).Contact_Role_Id    := Idx.Contact_Role_Id;
                    	Lx_Cont_Contacts(Li_TableIdx).Contact_Role_Code  := Idx.Contact_Role_Code;
                        Lx_Cont_Contacts(Li_TableIdx).Contact_Role_Name  := l_Rle_Lkup_TBL(i).meaning;
                    end if;
                end loop;
            end loop;
        end if;

    END LOOP;

    -- building contacts output plsql table for buyers based contacts

    FOR Idx IN Lx_Csr_Cle_POAContacts(Lx_Cle_Id,Lx_Dnz_Chr_Id) LOOP
        for  i in l_Rle_Lkup_TBL.first..l_Rle_Lkup_TBL.last loop
             if Idx.Contact_Role_Code = l_Rle_Lkup_TBL(i).code then
                        Li_TableIdx   := Li_TableIdx + 1;
                    	Lx_Cont_Contacts(Li_TableIdx).Contract_Id	     := Idx.Contract_Id;
                    	Lx_Cont_Contacts(Li_TableIdx).Contact_Id	     := Idx.Contact_Id;
                        Lx_Cont_Contacts(Li_TableIdx).Contact_Name       := Idx.contact_name;
                    	Lx_Cont_Contacts(Li_TableIdx).Contact_Role_Id    := Idx.Contact_Role_Id;
                    	Lx_Cont_Contacts(Li_TableIdx).Contact_Role_Code  := Idx.Contact_Role_Code;
                        Lx_Cont_Contacts(Li_TableIdx).Contact_Role_Name  := l_Rle_Lkup_TBL(i).meaning;
              end if;
        end loop;
    END LOOP;

    -- building contacts output plsql table for sales persons based contacts

    FOR Idx IN Lx_Csr_Cle_SRPContacts(Lx_Cle_Id,Lx_Dnz_Chr_Id) LOOP
        for  i in l_Rle_Lkup_TBL.first..l_Rle_Lkup_TBL.last loop
             if Idx.Contact_Role_Code = l_Rle_Lkup_TBL(i).code then
                        Li_TableIdx   := Li_TableIdx + 1;
                    	Lx_Cont_Contacts(Li_TableIdx).Contract_Id	     := Idx.Contract_Id;
                    	Lx_Cont_Contacts(Li_TableIdx).Contact_Id	     := Idx.Contact_Id;
                        Lx_Cont_Contacts(Li_TableIdx).Contact_Name       := Idx.contact_name;
                    	Lx_Cont_Contacts(Li_TableIdx).Contact_Role_Id    := Idx.Contact_Role_Id;
                    	Lx_Cont_Contacts(Li_TableIdx).Contact_Role_Code  := Idx.Contact_Role_Code;
                        Lx_Cont_Contacts(Li_TableIdx).Contact_Role_Name  := l_Rle_Lkup_TBL(i).meaning;
              end if;
        end loop;
     END LOOP;

    else

     FOR Idx IN Lx_Csr_Chr_RscContacts(Lx_Chr_Id) LOOP

        if Idx.Rsc_Category = 'SUPPLIER_CONTACT' then
            for Lx_Rec_vndr_name in Lx_Csr_vndr_name(Idx.Contact_Id, idx.org_id) loop
                for  i in l_Rle_Lkup_TBL.first..l_Rle_Lkup_TBL.last loop
                    if Idx.Contact_Role_Code = l_Rle_Lkup_TBL(i).code then
                        Li_TableIdx   := Li_TableIdx + 1;
                    	Lx_Cont_Contacts(Li_TableIdx).Contract_Id	 := Idx.Contract_Id;
                    	Lx_Cont_Contacts(Li_TableIdx).Contact_Id	 := Idx.Contact_Id;
                        Lx_Cont_Contacts(Li_TableIdx).Contact_Name  := Lx_Rec_vndr_name.name;
                    	Lx_Cont_Contacts(Li_TableIdx).Contact_Role_Id    := Idx.Contact_Role_Id;
                    	Lx_Cont_Contacts(Li_TableIdx).Contact_Role_Code  := Idx.Contact_Role_Code;
                        Lx_Cont_Contacts(Li_TableIdx).Contact_Role_Name  := l_Rle_Lkup_TBL(i).meaning;
                    end if;
                end loop;
            end loop;
        end if;

        if Idx.Rsc_Category = 'EMPLOYEE' then
            for Lx_rec_emp_name in Lx_Csr_emp_name(Idx.Contact_Id) loop
                for  i in l_Rle_Lkup_TBL.first..l_Rle_Lkup_TBL.last loop
                    if Idx.Contact_Role_Code = l_Rle_Lkup_TBL(i).code then
                        Li_TableIdx   := Li_TableIdx + 1;
                    	Lx_Cont_Contacts(Li_TableIdx).Contract_Id	 := Idx.Contract_Id;
                    	Lx_Cont_Contacts(Li_TableIdx).Contact_Id	 := Idx.Contact_Id;
                        Lx_Cont_Contacts(Li_TableIdx).Contact_Name  := Lx_rec_emp_name.name;
                    	Lx_Cont_Contacts(Li_TableIdx).Contact_Role_Id    := Idx.Contact_Role_Id;
                    	Lx_Cont_Contacts(Li_TableIdx).Contact_Role_Code  := Idx.Contact_Role_Code;
                        Lx_Cont_Contacts(Li_TableIdx).Contact_Role_Name  := l_Rle_Lkup_TBL(i).meaning;
                    end if;
                end loop;
            end loop;
        end if;


        if Idx.Rsc_Category in ('PARTNER','PARTY') then
            for Lx_rec_pty_name in Lx_Csr_pty_name(Idx.Contact_Id) loop
                for  i in l_Rle_Lkup_TBL.first..l_Rle_Lkup_TBL.last loop
                    if Idx.Contact_Role_Code = l_Rle_Lkup_TBL(i).code then
                        Li_TableIdx   := Li_TableIdx + 1;
                    	Lx_Cont_Contacts(Li_TableIdx).Contract_Id	 := Idx.Contract_Id;
                    	Lx_Cont_Contacts(Li_TableIdx).Contact_Id	 := Idx.Contact_Id;
                        Lx_Cont_Contacts(Li_TableIdx).Contact_Name  := Lx_rec_pty_name.name;
                    	Lx_Cont_Contacts(Li_TableIdx).Contact_Role_Id    := Idx.Contact_Role_Id;
                    	Lx_Cont_Contacts(Li_TableIdx).Contact_Role_Code  := Idx.Contact_Role_Code;
                        Lx_Cont_Contacts(Li_TableIdx).Contact_Role_Name  := l_Rle_Lkup_TBL(i).meaning;
                    end if;
                end loop;
            end loop;
        end if;

        if Idx.Rsc_Category = ('OTHER') then
            for Lx_rec_oth_name in Lx_Csr_oth_name(Idx.Contact_Id, idx.org_id) loop
                for  i in l_Rle_Lkup_TBL.first..l_Rle_Lkup_TBL.last loop
                    if Idx.Contact_Role_Code = l_Rle_Lkup_TBL(i).code then
                        Li_TableIdx   := Li_TableIdx + 1;
                    	Lx_Cont_Contacts(Li_TableIdx).Contract_Id	 := Idx.Contract_Id;
                    	Lx_Cont_Contacts(Li_TableIdx).Contact_Id	 := Idx.Contact_Id;
                        Lx_Cont_Contacts(Li_TableIdx).Contact_Name  := Lx_rec_oth_name.name;
                    	Lx_Cont_Contacts(Li_TableIdx).Contact_Role_Id    := Idx.Contact_Role_Id;
                    	Lx_Cont_Contacts(Li_TableIdx).Contact_Role_Code  := Idx.Contact_Role_Code;
                        Lx_Cont_Contacts(Li_TableIdx).Contact_Role_Name  := l_Rle_Lkup_TBL(i).meaning;
                    end if;
                end loop;
            end loop;
        end if;

    END LOOP;

    -- building contacts output plsql table for buyers based contacts

    FOR Idx IN Lx_Csr_Chr_POAContacts(Lx_Chr_Id) LOOP
        for  i in l_Rle_Lkup_TBL.first..l_Rle_Lkup_TBL.last loop
             if Idx.Contact_Role_Code = l_Rle_Lkup_TBL(i).code then
                        Li_TableIdx   := Li_TableIdx + 1;
                    	Lx_Cont_Contacts(Li_TableIdx).Contract_Id	     := Idx.Contract_Id;
                    	Lx_Cont_Contacts(Li_TableIdx).Contact_Id	     := Idx.Contact_Id;
                        Lx_Cont_Contacts(Li_TableIdx).Contact_Name       := Idx.contact_name;
                    	Lx_Cont_Contacts(Li_TableIdx).Contact_Role_Id    := Idx.Contact_Role_Id;
                    	Lx_Cont_Contacts(Li_TableIdx).Contact_Role_Code  := Idx.Contact_Role_Code;
                        Lx_Cont_Contacts(Li_TableIdx).Contact_Role_Name  := l_Rle_Lkup_TBL(i).meaning;
              end if;
        end loop;
    END LOOP;

    -- building contacts output plsql table for sales persons based contacts

    FOR Idx IN Lx_Csr_Chr_SRPContacts(Lx_Chr_Id) LOOP
        for  i in l_Rle_Lkup_TBL.first..l_Rle_Lkup_TBL.last loop
             if Idx.Contact_Role_Code = l_Rle_Lkup_TBL(i).code then
                        Li_TableIdx   := Li_TableIdx + 1;
                    	Lx_Cont_Contacts(Li_TableIdx).Contract_Id	     := Idx.Contract_Id;
                    	Lx_Cont_Contacts(Li_TableIdx).Contact_Id	     := Idx.Contact_Id;
                        Lx_Cont_Contacts(Li_TableIdx).Contact_Name       := Idx.contact_name;
                    	Lx_Cont_Contacts(Li_TableIdx).Contact_Role_Id    := Idx.Contact_Role_Id;
                    	Lx_Cont_Contacts(Li_TableIdx).Contact_Role_Code  := Idx.Contact_Role_Code;
                        Lx_Cont_Contacts(Li_TableIdx).Contact_Role_Name  := l_Rle_Lkup_TBL(i).meaning;
              end if;
        end loop;
     END LOOP;

   end if;

    X_Cont_Contacts       := Lx_Cont_Contacts;
    X_Result              := Lx_Result;
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
	,P_Token2_Value   => 'Get_Contract_Contacts');

      X_Result         := G_FALSE;
      X_Return_Status  := G_RET_STS_UNEXP_ERROR;

  END Get_Contract_Contacts;

-----------------------------------------------------------------------------------------------------------------------*

  PROCEDURE Get_Contacts
    (P_API_Version		IN  NUMBER
    ,P_Init_Msg_List		IN  VARCHAR2
    ,P_Contract_Id		IN  NUMBER
    ,P_Contract_Line_Id	        IN  NUMBER
    ,X_Return_Status 		OUT NOCOPY VARCHAR2
    ,X_Msg_Count		OUT NOCOPY NUMBER
    ,X_Msg_Data			OUT NOCOPY VARCHAR2
    ,X_Ent_Contacts		OUT NOCOPY Ent_Contact_Tbl)
  IS

    Lx_Result                   Gx_Boolean;

  BEGIN

    Get_Contract_Contacts
      (P_API_Version		=> P_API_Version
      ,P_Init_Msg_List		=> P_Init_Msg_List
      ,P_Chr_Id                 => P_Contract_Id
      ,P_Cle_Id	                => P_Contract_Line_Id
      ,X_Cont_Contacts		=> X_Ent_Contacts
      ,X_Msg_Count		=> X_Msg_Count
      ,X_Msg_Data		=> X_Msg_Data
      ,X_Result                 => Lx_Result
      ,X_Return_Status          => X_Return_Status);

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
	,P_Token2_Value   => 'Get_Contacts');

      --X_Result         := G_FALSE;
      X_Return_Status  := G_RET_STS_UNEXP_ERROR;

  END Get_Contacts;

-----------------------------------------------------------------------------------------------------------------------*

  PROCEDURE Append_ContItem_PlSql_Table
    (P_Input_Tab          IN  GT_ContItem_Ref
    ,P_Append_Tab         IN  GT_ContItem_Ref
    ,X_Output_Tab         out nocopy GT_ContItem_Ref
    ,X_Result             out nocopy Gx_Boolean
    ,X_Return_Status   	  out nocopy Gx_Ret_Sts)
  IS

    Lx_Input_Tab          GT_ContItem_Ref;
    Lx_Output_Tab         GT_ContItem_Ref;

    Li_In_TableIdx        BINARY_INTEGER;
    Li_Out_TableIdx       BINARY_INTEGER;

    Lx_Result             Gx_Boolean;
    Lx_Return_Status      Gx_Ret_Sts;

  BEGIN

    Lx_Input_Tab          := P_Input_Tab;
    Lx_Output_Tab         := P_Append_Tab;

    Lx_Result             := G_TRUE;
    Lx_Return_Status      := G_RET_STS_SUCCESS;

    Li_In_TableIdx       := Lx_Input_Tab.FIRST;
    Li_Out_TableIdx      := NVL(Lx_Output_Tab.LAST,0);

    WHILE Li_In_TableIdx IS NOT NULL LOOP

      Li_Out_TableIdx                := Li_Out_TableIdx + 1;
      Lx_Output_Tab(Li_Out_TableIdx) := Lx_Input_Tab(Li_In_TableIdx);
      Li_In_TableIdx                 := Lx_Input_Tab.NEXT(Li_In_TableIdx);

    END LOOP;

    X_Output_Tab          := Lx_Output_Tab;

    X_Result              := Lx_Result;
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
	,P_Token2_Value   => 'Append_ContItem_PlSql_Table');

      X_Result         := G_FALSE;
      X_Return_Status  := G_RET_STS_UNEXP_ERROR;

  END Append_ContItem_PlSql_Table;

-----------------------------------------------------------------------------------------------------------------------*

  PROCEDURE Get_Item_CovLevels
    (P_CovItem_Obj_Id         IN  Gx_OKS_Id
    ,P_Organization_Id        IN  NUMBER
    ,X_Item_CovLevels         out nocopy GT_ContItem_Ref
    ,X_Result                 out nocopy Gx_Boolean
    ,X_Return_Status   	      out nocopy Gx_Ret_Sts)
  IS

    CURSOR Lx_Csr_CovItem(Cx_CovItem_Id IN Gx_OKS_Id
                         ,Cn_Organization_Id IN NUMBER) IS
      SELECT '*'
        FROM Okx_System_Items_V CI
       WHERE CI.Id1 = Cx_CovItem_Id
     --  AND CI.Id2 = Cn_Organization_Id               -- Bug# 4735542
         AND CI.Serviceable_Product_Flag ='Y';
     --  AND CI.Organization_Id = Cn_Organization_Id;  -- Bug# 4735542

    Lx_CovItem_Obj_Id         CONSTANT Gx_OKS_Id := P_CovItem_Obj_Id;
    Ln_Organization_Id        CONSTANT NUMBER := P_Organization_Id;

    Lx_Item_CovLevels         GT_ContItem_Ref;
    Lv_Dummy                  VARCHAR2(1);
    Lx_Result                 Gx_Boolean;
    Lx_Return_Status          Gx_Ret_Sts;
    Li_TableIdx               BINARY_INTEGER;

    L_EXCEP_NO_DATA_FOUND     EXCEPTION;

  BEGIN

    Lx_Result                 := G_TRUE;
    Lx_Return_Status          := G_RET_STS_SUCCESS;

    OPEN Lx_Csr_CovItem(Lx_CovItem_Obj_Id,Ln_organization_Id);
    FETCH Lx_Csr_CovItem INTO Lv_Dummy;

    IF Lx_Csr_CovItem%NOTFOUND THEN
      RAISE L_EXCEP_NO_DATA_FOUND;
    END IF;

    CLOSE Lx_Csr_CovItem;

    Li_TableIdx  := 1;

    Lx_Item_CovLevels(Li_TableIdx).Rx_Obj1Id1  := Lx_CovItem_Obj_Id;
    Lx_Item_CovLevels(Li_TableIdx).Rx_Obj1Id2  := Ln_organization_Id;
    Lx_Item_CovLevels(Li_TableIdx).Rx_ObjCode  := 'OKX_COVITEM';

    X_Item_CovLevels      := Lx_Item_CovLevels;
    X_Result              := Lx_Result;
    X_Return_Status       := Lx_Return_Status;

  EXCEPTION

    WHEN L_EXCEP_NO_DATA_FOUND THEN

      IF Lx_Csr_CovItem%ISOPEN THEN
        CLOSE Lx_Csr_CovItem;
      END IF;

      X_Result            := G_TRUE;
      X_Return_Status     := G_TRUE;

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
	,P_Token2_Value   => 'Get_Item_CovLevels');

      X_Result         := G_FALSE;
      X_Return_Status  := G_RET_STS_UNEXP_ERROR;

  END Get_Item_CovLevels;

-----------------------------------------------------------------------------------------------------------------------*

  PROCEDURE Get_Party_CovLevels
    (P_CovParty_Obj_Id        IN  Gx_OKS_Id
    ,X_Party_CovLevels        out nocopy GT_ContItem_Ref
    ,X_Result                 out nocopy Gx_Boolean
    ,X_Return_Status   	      out nocopy Gx_Ret_Sts)
  IS

    CURSOR Lx_Csr_CovParty(Cx_CovParty_Id IN Gx_OKS_Id ) IS
      SELECT '*'
        FROM Okx_Parties_V PY
       WHERE PY.Id1 = Cx_CovParty_Id
         AND PY.Id2 = '#';

    Lx_CovParty_Obj_Id        CONSTANT Gx_OKS_Id := P_CovParty_Obj_Id;

    Lx_Party_CovLevels        GT_ContItem_Ref;
    Lv_Dummy                  VARCHAR2(1);
    Lx_Result                 Gx_Boolean;
    Lx_Return_Status          Gx_Ret_Sts;

    Li_TableIdx               BINARY_INTEGER;
    L_EXCEP_NO_DATA_FOUND     EXCEPTION;

  BEGIN

    Lx_Result                 := G_TRUE;
    Lx_Return_Status          := G_RET_STS_SUCCESS;

    OPEN Lx_Csr_CovParty(Lx_CovParty_Obj_Id);
    FETCH Lx_Csr_CovParty INTO Lv_Dummy;

    IF Lx_Csr_CovParty%NOTFOUND THEN
      RAISE L_EXCEP_NO_DATA_FOUND;
    END IF;

    CLOSE Lx_Csr_CovParty;

    Li_TableIdx  := 1;

    Lx_Party_CovLevels(Li_TableIdx).Rx_Obj1Id1  := Lx_CovParty_Obj_Id;
    Lx_Party_CovLevels(Li_TableIdx).Rx_Obj1Id2  := '#';
    Lx_Party_CovLevels(Li_TableIdx).Rx_ObjCode  := 'OKX_PARTY';

    X_Party_CovLevels     := Lx_Party_CovLevels;
    X_Result              := Lx_Result;
    X_Return_Status       := Lx_Return_Status;

  EXCEPTION

    WHEN L_EXCEP_NO_DATA_FOUND THEN

      IF Lx_Csr_CovParty%ISOPEN THEN
        CLOSE Lx_Csr_CovParty;
      END IF;

      X_Result              := G_TRUE;
      X_Return_Status       := G_TRUE;

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
	,P_Token2_Value   => 'Get_Party_CovLevels');

      X_Result         := G_FALSE;
      X_Return_Status  := G_RET_STS_UNEXP_ERROR;

  END Get_Party_CovLevels;

-----------------------------------------------------------------------------------------------------------------------*

  PROCEDURE Get_Customer_CovLevels
    (P_CovCust_Obj_Id         IN  Gx_OKS_Id
    ,X_Party_Id               out nocopy Gx_OKS_Id
    ,X_Customer_CovLevels     out nocopy GT_ContItem_Ref
    ,X_Result                 out nocopy Gx_Boolean
    ,X_Return_Status   	      out nocopy Gx_Ret_Sts)
  IS

    CURSOR Lx_Csr_CovCust(Cx_CovCust_Id IN Gx_OKS_Id) IS
      SELECT CA.Party_Id
        FROM Okx_Customer_Accounts_V CA
       WHERE CA.Id1 = Cx_CovCust_Id
         AND CA.Id2 = '#';

    Lx_CovCust_Obj_Id         CONSTANT Gx_OKS_Id := P_CovCust_Obj_Id;

    Lx_Customer_CovLevels     GT_ContItem_Ref;
    Lx_Customer_CovLevels_Out GT_ContItem_Ref;
    Lx_Customer_Party         GT_ContItem_Ref;

    Lx_Result                 Gx_Boolean;
    Lx_Return_Status          Gx_Ret_Sts;

    Lx_Party_Id               Okx_Customer_Accounts_V.Party_Id%TYPE;

    Li_TableIdx               BINARY_INTEGER;
    L_EXCEP_UNEXPECTED_ERR    EXCEPTION;
    L_EXCEP_NO_DATA_FOUND     EXCEPTION;

  BEGIN

    Lx_Result                 := G_TRUE;
    Lx_Return_Status          := G_RET_STS_SUCCESS;

    OPEN Lx_Csr_CovCust(Lx_CovCust_Obj_Id);
    FETCH Lx_Csr_CovCust INTO Lx_Party_Id;

    IF Lx_Csr_CovCust%NOTFOUND THEN
      RAISE L_EXCEP_NO_DATA_FOUND;
    END IF;

    CLOSE Lx_Csr_CovCust;

    Li_TableIdx  := 1;
    Lx_Customer_CovLevels(Li_TableIdx).Rx_Obj1Id1  := Lx_CovCust_Obj_Id;
    Lx_Customer_CovLevels(Li_TableIdx).Rx_Obj1Id2  := '#';
    Lx_Customer_CovLevels(Li_TableIdx).Rx_ObjCode  := 'OKX_CUSTACCT';

    IF (set_account_party_id = 'T') THEN
       covd_account_party_id := Lx_Party_Id;  -- store the account_party_id to compare with site party_id #4690940
    END IF;

    Get_Party_CovLevels
      (P_CovParty_Obj_Id    => Lx_Party_Id
      ,X_Party_CovLevels    => Lx_Customer_Party
      ,X_Result             => Lx_Result
      ,X_Return_Status      => Lx_Return_Status);

    IF Lx_Result <> G_TRUE THEN
      RAISE L_EXCEP_UNEXPECTED_ERR;
    END IF;

    Append_ContItem_PlSql_Table
      (P_Input_Tab          => Lx_Customer_Party
      ,P_Append_Tab         => Lx_Customer_CovLevels
      ,X_Output_Tab         => Lx_Customer_CovLevels_Out
      ,X_Result             => Lx_Result
      ,X_Return_Status      => Lx_Return_Status);

    IF Lx_Result <> G_TRUE THEN
      RAISE L_EXCEP_UNEXPECTED_ERR;
    END IF;

    Lx_Customer_CovLevels  := Lx_Customer_CovLevels_Out;

    X_Party_Id             := Lx_Party_Id;
    X_Customer_CovLevels   := Lx_Customer_CovLevels;
    X_Result               := Lx_Result;
    X_Return_Status        := Lx_Return_Status;

  EXCEPTION

    WHEN L_EXCEP_NO_DATA_FOUND THEN

      IF Lx_Csr_CovCust%ISOPEN THEN
        CLOSE Lx_Csr_CovCust;
      END IF;

      X_Result              := G_TRUE;
      X_Return_Status       := G_TRUE;

    WHEN L_EXCEP_UNEXPECTED_ERR THEN

      X_Result              := Lx_Result;
      X_Return_Status       := Lx_Return_Status;

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
	,P_Token2_Value   => 'Get_Customer_CovLevels');

      X_Result             := G_FALSE;
      X_Return_Status      := G_RET_STS_UNEXP_ERROR;

  END Get_Customer_CovLevels;

-----------------------------------------------------------------------------------------------------------------------*

  PROCEDURE Get_Site_CovLevels
    (P_CovSite_Obj_Id         IN  Gx_OKS_Id
    ,P_Org_Id                 IN  NUMBER
    ,X_Site_CovLevels         out nocopy GT_ContItem_Ref
    ,X_Result                 out nocopy Gx_Boolean
    ,X_Return_Status   	      out nocopy Gx_Ret_Sts)
  IS


    CURSOR Lx_Csr_CovSite(Cx_CovSite_Id IN Gx_OKS_Id
                         ,Cn_Org_Id IN NUMBER) IS
      SELECT PS.Id1
            ,PS.Id2
            ,PS.Party_Id
        FROM Okx_Party_Sites_V PS
       WHERE PS.Id1 = Cx_CovSite_Id;

    Lx_CovSite_Obj_Id         CONSTANT Gx_OKS_Id := P_CovSite_Obj_Id;
    Ln_Org_Id                 CONSTANT NUMBER := P_Org_Id;

    Lx_Site_CovLevels         GT_ContItem_Ref;
    Lx_Site_CovLevels_Out     GT_ContItem_Ref;
    Lx_Site_Customer          GT_ContItem_Ref;
    Lx_Site_Party             GT_ContItem_Ref;

    Lx_Result                 Gx_Boolean;
    Lx_Return_Status          Gx_Ret_Sts;

    Lx_Cust_Account_Id        Okx_Cust_Site_Uses_V.Cust_Account_Id%TYPE;
    Lx_Party_Id               Okx_Cust_Site_Uses_V.Party_Id%TYPE;
    Lx_Party_Id_Dummy         Okx_Customer_Accounts_V.Party_Id%TYPE;

    Li_TableIdx               BINARY_INTEGER;

    L_EXCEP_UNEXPECTED_ERR    EXCEPTION;

  BEGIN

    Lx_Result                 := G_TRUE;
    Lx_Return_Status          := G_RET_STS_SUCCESS;

    FOR IDX IN Lx_Csr_CovSite(Lx_CovSite_Obj_Id,Ln_Org_Id) LOOP

      Li_TableIdx  := NVL(Lx_Site_CovLevels.LAST,0) + 1;

      Lx_Site_CovLevels(Li_TableIdx).Rx_Obj1Id1  := Idx.Id1;
      Lx_Site_CovLevels(Li_TableIdx).Rx_Obj1Id2  := Idx.Id2;
      Lx_Site_CovLevels(Li_TableIdx).Rx_ObjCode  := 'OKX_PARTYSITE';

--      Get_Party_CovLevels
--        (P_CovParty_Obj_Id    => Idx.Party_Id
--        ,X_Party_CovLevels    => Lx_Site_Party
--        ,X_Result             => Lx_Result
--        ,X_Return_Status      => Lx_Return_Status);
--
--

      IF covd_account_party_id IS NOT NULL THEN                -- #4690940 start
	    IF covd_account_party_id <> Idx.Party_Id THEN
	       Get_Party_CovLevels
		              (P_CovParty_Obj_Id    => Idx.Party_Id
				    ,X_Party_CovLevels    => Lx_Site_Party
				    ,X_Result             => Lx_Result
				    ,X_Return_Status      => Lx_Return_Status);
	    END IF;
	 ELSE
         Get_Party_CovLevels
            (P_CovParty_Obj_Id    => Idx.Party_Id
             ,X_Party_CovLevels    => Lx_Site_Party
             ,X_Result             => Lx_Result
             ,X_Return_Status      => Lx_Return_Status);
      END IF;                                                  --#4690940 end

--

      IF Lx_Result <> G_TRUE THEN
        RAISE L_EXCEP_UNEXPECTED_ERR;
      END IF;

      Append_ContItem_PlSql_Table
        (P_Input_Tab          => Lx_Site_Party
        ,P_Append_Tab         => Lx_Site_CovLevels
        ,X_Output_Tab         => Lx_Site_CovLevels_Out
        ,X_Result             => Lx_Result
        ,X_Return_Status      => Lx_Return_Status);

      IF Lx_Result <> G_TRUE THEN
        RAISE L_EXCEP_UNEXPECTED_ERR;
      END IF;

      Lx_Site_CovLevels      := Lx_Site_CovLevels_Out;

    END LOOP;

    X_Site_CovLevels      := Lx_Site_CovLevels;
    X_Result              := Lx_Result;
    X_Return_Status       := Lx_Return_Status;

  EXCEPTION

    WHEN L_EXCEP_UNEXPECTED_ERR THEN

      X_Result            := Lx_Result;
      X_Return_Status     := Lx_Return_Status;

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
	,P_Token2_Value   => 'Get_Site_CovLevels');

      X_Result           := G_FALSE;
      X_Return_Status    := G_RET_STS_UNEXP_ERROR;

  END Get_Site_CovLevels;

-----------------------------------------------------------------------------------------------------------------------*

  PROCEDURE Get_System_CovLevels
    (P_CovSys_Obj_Id          IN  Gx_OKS_Id
    ,P_Org_Id                 IN  NUMBER
    ,X_System_CovLevels       out nocopy GT_ContItem_Ref
    ,X_Result                 out nocopy Gx_Boolean
    ,X_Return_Status   	      out nocopy Gx_Ret_Sts)
  IS

    CURSOR Lx_Csr_CovSys(Cx_CovSys_Id IN Gx_OKS_Id                 --Modified for New Install Base.
                        ,Cn_Org_Id IN NUMBER) IS
      SELECT CSISYS.System_Id System_Id,
             CSISYS.Customer_Id,
             CSISYS.Install_Site_Use_Id
        FROM CSI_SYSTEMS_B CSISYS
        connect by prior parent_system_id = system_id
        start with system_id = Cx_CovSys_Id;

    Lx_CovSys_Obj_Id          CONSTANT Gx_OKS_Id := P_CovSys_Obj_Id;
    Ln_org_Id                 CONSTANT NUMBER := P_Org_Id;

    Lx_System_CovLevels       GT_ContItem_Ref;
    Lx_System_CovLevels_Out   GT_ContItem_Ref;

    Lx_System_Customer        GT_ContItem_Ref;
    Lx_System_Site            GT_ContItem_Ref;

    Lx_Party_Id               Okx_Customer_Accounts_V.Party_Id%TYPE;

    Lx_Result                 Gx_Boolean;
    Lx_Return_Status          Gx_Ret_Sts;

    Li_TableIdx               BINARY_INTEGER;
    L_EXCEP_UNEXPECTED_ERR    EXCEPTION;

  BEGIN

    Lx_Result                 := G_TRUE;
    Lx_Return_Status          := G_RET_STS_SUCCESS;

    FOR Idx IN Lx_Csr_CovSys(Lx_CovSys_Obj_Id,Ln_Org_Id) LOOP

      Li_TableIdx  := NVL(Lx_System_CovLevels.LAST,0) + 1;

      Lx_System_CovLevels(Li_TableIdx).Rx_Obj1Id1  := Idx.System_Id;
      Lx_System_CovLevels(Li_TableIdx).Rx_Obj1Id2  := '#';
      Lx_System_CovLevels(Li_TableIdx).Rx_ObjCode  := 'OKX_COVSYST';

      Get_Customer_CovLevels
        (P_CovCust_Obj_Id     => Idx.Customer_Id
        ,X_Party_Id           => Lx_Party_Id
        ,X_Customer_CovLevels => Lx_System_Customer
        ,X_Result             => Lx_Result
        ,X_Return_Status      => Lx_Return_Status);

      IF Lx_Result <> G_TRUE THEN
        RAISE L_EXCEP_UNEXPECTED_ERR;
      END IF;

      Append_ContItem_PlSql_Table
        (P_Input_Tab          => Lx_System_Customer
        ,P_Append_Tab         => Lx_System_CovLevels
        ,X_Output_Tab         => Lx_System_CovLevels_Out
        ,X_Result             => Lx_Result
        ,X_Return_Status      => Lx_Return_Status);

      IF Lx_Result <> G_TRUE THEN
        RAISE L_EXCEP_UNEXPECTED_ERR;
      END IF;

      Lx_System_CovLevels     := Lx_System_CovLevels_Out;

      Get_Site_CovLevels
        (P_CovSite_Obj_Id     => Idx.Install_Site_Use_Id
        ,P_Org_Id             => Ln_org_Id
        ,X_Site_CovLevels     => Lx_System_Site
        ,X_Result             => Lx_Result
        ,X_Return_Status      => Lx_Return_Status);

      IF Lx_Result <> G_TRUE THEN
        RAISE L_EXCEP_UNEXPECTED_ERR;
      END IF;

      Append_ContItem_PlSql_Table
        (P_Input_Tab          => Lx_System_Site
        ,P_Append_Tab         => Lx_System_CovLevels
        ,X_Output_Tab         => Lx_System_CovLevels_out
        ,X_Result             => Lx_Result
        ,X_Return_Status      => Lx_Return_Status);

      IF Lx_Result <> G_TRUE THEN
        RAISE L_EXCEP_UNEXPECTED_ERR;
      END IF;

      Lx_System_CovLevels     := Lx_System_CovLevels_Out;

    END LOOP;

    X_System_CovLevels      := Lx_System_CovLevels;
    X_Result                := Lx_Result;
    X_Return_Status         := Lx_Return_Status;

  EXCEPTION

    WHEN L_EXCEP_UNEXPECTED_ERR THEN

      X_Result              := Lx_Result;
      X_Return_Status       := Lx_Return_Status;

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
	,P_Token2_Value   => 'Get_System_CovLevels');

      X_Result         := G_FALSE;
      X_Return_Status  := G_RET_STS_UNEXP_ERROR;

  END Get_System_CovLevels;

-----------------------------------------------------------------------------------------------------------------------*

/**********************************************************
** This Procedure gets all the parents traversing up     **
** for a given child(subject) with the relationship type **
** COMPONENT-OF. It stops traversing when the top-most   **
** is reached or the relationship is broken.             **
***********************************************************/

-- added procedure Get_All_Parents to fix bug 3583486.

  PROCEDURE Get_All_Parents
   (
    p_api_version      IN  NUMBER,
    p_commit           IN  VARCHAR2,
    p_init_msg_list    IN  VARCHAR2,
    p_validation_level IN  NUMBER,
    p_subject_id       IN  NUMBER,
    x_rel_tbl          OUT NOCOPY ii_relationship_tbl,
    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_count        OUT NOCOPY NUMBER,
    x_msg_data         OUT NOCOPY VARCHAR2
   ) IS

   l_api_version            CONSTANT NUMBER := 1.0;
   l_api_name               CONSTANT VARCHAR2(30) := 'GET_ALL_PARENTS';
   l_ctr                    NUMBER;
   l_object_id              NUMBER;
   l_subject_id             NUMBER;
   l_exists                 VARCHAR2(1);
   l_relationship_id        NUMBER;
   l_rel_type_code          CONSTANT VARCHAR2(30) := 'COMPONENT-OF';

   L_EXCEP_CYCLIC_DATA      EXCEPTION;
   Lx_ExcepionMsg           Varchar2(1000);
   Lx_Return_Status         Varchar2(1);

BEGIN

   l_ctr               := 0;

   -- Check for freeze_flag in csi_install_parameters is set to 'Y', not required.
   -- csi_utility_grp.check_ib_active;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   l_subject_id := p_subject_id;

   LOOP
      Begin
	 select relationship_id,object_id
	 into l_relationship_id,l_object_id
	 from CSI_II_RELATIONSHIPS
	 where subject_id = l_subject_id
	 and   relationship_type_code = l_rel_type_code
	 and   ((active_end_date is null) or (active_end_date > sysdate));
	 --
	 l_ctr := l_ctr + 1;
	 x_rel_tbl(l_ctr).subject_id := l_subject_id;
	 x_rel_tbl(l_ctr).object_id := l_object_id;
	 x_rel_tbl(l_ctr).relationship_id := l_relationship_id;
	 x_rel_tbl(l_ctr).relationship_type_code := l_rel_type_code;
	 --
         -- Just in case a cycle exists because of bad data the following check will break
         -- the loop.
	 l_exists := 'N';
	 IF x_rel_tbl.count > 0 THEN
	    FOR j in x_rel_tbl.FIRST .. x_rel_tbl.LAST Loop
	       IF l_object_id = x_rel_tbl(j).subject_id THEN
    		  l_exists        := 'Y';
              Lx_ExcepionMsg  := 'OBJECT_ID in Relationship Id: '||x_rel_tbl(l_ctr).relationship_id||
                                 ' and SUBJECT_ID in Relationship Id: '||x_rel_tbl(j).relationship_id||
                                 ' is in a cyclic relationship';
     		  exit;
	       END IF;
	    End Loop;
	 END IF;
	 --
	 IF l_exists = 'Y' THEN
--	    exit;
        RAISE L_EXCEP_CYCLIC_DATA;
	 END IF;
	 --
	 l_subject_id := l_object_id;
      Exception
	 when no_data_found then
	    exit;
      End;
   END LOOP;
   -- End of API body


  EXCEPTION

    WHEN L_EXCEP_CYCLIC_DATA THEN

        OKC_API.SET_MESSAGE
          (p_app_name	   => G_APP_NAME_OKC
     	  ,p_msg_name	   => G_INVALID_VALUE
	      ,p_token1	       => G_COL_NAME_TOKEN
	      ,p_token1_value  => Lx_ExcepionMsg);

        Lx_Return_Status  := G_RET_STS_ERROR;

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
	,P_Token2_Value   => 'Get_All_Parents');

      X_Return_Status := G_RET_STS_UNEXP_ERROR;

END Get_All_Parents;

------------------------------------------------------------------------------------------------------

PROCEDURE Get_Product_CovLevels
    (P_CovProd_Obj_Id         IN  Gx_OKS_Id
    ,P_Organization_Id        IN  NUMBER
    ,P_Org_Id                 IN  NUMBER
    ,X_Party_Id               out nocopy Gx_OKS_Id
    ,X_Product_CovLevels      out nocopy GT_ContItem_Ref
    ,X_Result                 out nocopy Gx_Boolean
    ,X_Return_Status   	      out nocopy Gx_Ret_Sts)
  IS

/*
CURSOR Lx_Csr_PARPROD (Cx_CovProd_Id IN Gx_OKS_Id ) IS
	SELECT  object_id,
		subject_id
	FROM csi_ii_relationships
        connect by prior    object_id = subject_id
        start with subject_id = Cx_CovProd_Id
	UNION
	SELECT  instance_id object_id,
--		null subject_id
        -1 subject_id --bug 2740241
	FROM csi_item_instances
	where instance_id = Cx_CovProd_Id;
*/

CURSOR Lx_Csr_CovProd(Cx_CovProd_Id IN Gx_OKS_Id
                         ,Cn_Organization_Id IN NUMBER
                         ,Cn_Org_Id IN NUMBER) IS
	SELECT  CSI.Inventory_item_id Inventory_item_id,
	      	CSI.System_id System_id,
        	CSI.Owner_party_account_id Owner_party_account_id, --CSI.Owner_party_id Owner_party_id
        	CSI.install_location_id install_location_id,
        	CSI.INSTALL_LOCATION_TYPE_CODE install_location_type_code
	FROM    CSI_ITEM_INSTANCES CSI
	WHERE   CSI.INSTANCE_ID  = Cx_CovProd_Id;





    Lx_CovProd_Obj_Id         CONSTANT Gx_OKS_Id := P_CovProd_Obj_Id;
    Ln_organization_Id        CONSTANT NUMBER := P_Organization_Id;
    Ln_Org_Id                 CONSTANT NUMBER := P_Org_Id;

    Lx_Product_CovLevels      GT_ContItem_Ref;
    Lx_Product_CovLevels_Out  GT_ContItem_Ref;
    Lx_Product_Customer       GT_ContItem_Ref;
    Lx_Product_Site           GT_ContItem_Ref;
    Lx_Product_Item           GT_ContItem_Ref;
    Lx_Product_System         GT_ContItem_Ref;

    Lx_Result                 Gx_Boolean;
    Lx_Return_Status          Gx_Ret_Sts;

/* ---CSI Uptake ----
    Lx_Inv_Item_Id            Okx_Customer_Products_V.Inventory_Item_Id%TYPE;
    Lx_System_Id              Okx_Customer_Products_V.System_Id%TYPE;
    Lx_Customer_Id            Okx_Customer_Products_V.Customer_Id%TYPE;
    Lx_Site_Id                Okx_Customer_Products_V.Install_Site_Use_Id%TYPE;
*/

    Lx_Party_Id               Okx_Customer_Accounts_V.Party_Id%TYPE;
    Lx_Inv_Item_Id            CSI_ITEM_INSTANCES.Inventory_Item_Id%TYPE;
    Lx_System_Id              CSI_ITEM_INSTANCES.System_Id%TYPE;
    Lx_Customer_Id            CSI_ITEM_INSTANCES.Owner_Party_Id%TYPE;
    Lx_Site_Id                CSI_ITEM_INSTANCES.Install_location_id%TYPE;
    Lx_Site_Type_Code         CSI_ITEM_INSTANCES.Install_location_type_code%TYPE;

    Lx_PARENT_OBJ             GT_PARENT_Ref;
    Li_PAR_Idx                BINARY_INTEGER;

    Lx_INSTANCES              GT_INSTANCES;
    Li_INST_Idx               BINARY_INTEGER;

    L_rel_tbl                 ii_relationship_tbl;
    Li_RelTbl_Idx             BINARY_INTEGER;
    L_msg_count               number;
    L_msg_data                VARCHAR2(1000);
    Li_TableIdx               BINARY_INTEGER;

    L_EXCEP_UNEXPECTED_ERR    EXCEPTION;
    L_EXCEP_NO_DATA_FOUND     EXCEPTION;

  BEGIN

    Lx_Result                 := G_TRUE;
    Lx_Return_Status          := G_RET_STS_SUCCESS;

/*
    Li_PAR_Idx := 0;

    FOR Lx_Csr_PARPROD_REC in Lx_Csr_PARPROD(Lx_CovProd_Obj_Id) LOOP


      Li_PAR_Idx  := Li_PAR_Idx + 1;
      Lx_PARENT_OBJ(Li_PAR_Idx).Rx_object_id := Lx_Csr_PARPROD_REC.object_id;

      Lx_PARENT_OBJ(Li_PAR_Idx).Rx_subject_id := Lx_Csr_PARPROD_REC.subject_id;

    END LOOP;
*/

    Li_INST_Idx  := 1;

    Lx_INSTANCES(Li_INST_Idx).RX_Inst_ID := Lx_CovProd_Obj_Id;

-- call to get_all_parents to add the parent instances to Lx_INSTANCES

    Get_All_Parents
     (
     p_api_version      => 1.0,
     p_commit           => G_FALSE,
     p_init_msg_list    => 'T',
     p_validation_level => FND_API.G_VALID_LEVEL_FULL,
     p_subject_id       => Lx_CovProd_Obj_Id,
     x_rel_tbl          => L_rel_tbl,
     x_return_status    => Lx_return_status,
     x_msg_count        => L_msg_count,
     x_msg_data         => L_msg_data
     );

    IF Lx_return_status <> 'S' THEN
      RAISE L_EXCEP_UNEXPECTED_ERR;
    END IF;

    IF L_rel_tbl.count > 0 THEN

      Li_RelTbl_Idx     := L_rel_tbl.FIRST;

      WHILE Li_RelTbl_Idx IS NOT NULL  LOOP

          Li_INST_Idx   := Li_INST_Idx + 1;

          Lx_INSTANCES(Li_INST_Idx).RX_Inst_ID    := L_rel_tbl(Li_RelTbl_Idx).object_id;

          Li_RelTbl_Idx  := L_rel_tbl.NEXT(Li_RelTbl_Idx);

      END LOOP;

    END IF;

    Li_TableIdx  := 1;

  IF Lx_INSTANCES.COUNT > 0 THEN -- added while fixing bug 2740241

   FOR i in Lx_INSTANCES.FIRST .. Lx_INSTANCES.LAST LOOP

    OPEN Lx_Csr_CovProd(Lx_INSTANCES(i).RX_Inst_ID,Ln_organization_Id,Ln_Org_Id);

    FETCH Lx_Csr_CovProd INTO Lx_Inv_Item_Id,Lx_System_Id,Lx_Customer_Id,Lx_Site_Id,Lx_Site_Type_Code;

    IF Lx_Csr_CovProd%NOTFOUND THEN
      RAISE L_EXCEP_NO_DATA_FOUND;
    END IF;

    Lx_Product_CovLevels(Li_TableIdx).Rx_Obj1Id1  := Lx_INSTANCES(i).RX_Inst_ID;
    Lx_Product_CovLevels(Li_TableIdx).Rx_Obj1Id2  := '#';
    Lx_Product_CovLevels(Li_TableIdx).Rx_ObjCode  := 'OKX_CUSTPROD';

    Get_Item_CovLevels
      (P_CovItem_Obj_Id     => Lx_Inv_Item_Id
      ,P_Organization_Id    => Ln_Organization_Id
      ,X_Item_CovLevels     => Lx_Product_Item
      ,X_Result             => Lx_Result
      ,X_Return_Status      => Lx_Return_Status);

    IF Lx_Result <> G_TRUE THEN
      RAISE L_EXCEP_UNEXPECTED_ERR;
    END IF;

    Append_ContItem_PlSql_Table
      (P_Input_Tab          => Lx_Product_Item
      ,P_Append_Tab         => Lx_Product_CovLevels
      ,X_Output_Tab         => Lx_Product_CovLevels_Out
      ,X_Result             => Lx_Result
      ,X_Return_Status      => Lx_Return_Status);

    IF Lx_Result <> G_TRUE THEN
      RAISE L_EXCEP_UNEXPECTED_ERR;
    END IF;

    Lx_Product_CovLevels  :=  Lx_Product_CovLevels_Out;

    Get_System_CovLevels
      (P_CovSys_Obj_Id      => Lx_System_Id
      ,P_Org_Id             => Ln_Org_Id
      ,X_System_CovLevels   => Lx_Product_System
      ,X_Result             => Lx_Result
      ,X_Return_Status      => Lx_Return_Status);

    IF Lx_Result <> G_TRUE THEN
      RAISE L_EXCEP_UNEXPECTED_ERR;
    END IF;

    Append_ContItem_PlSql_Table
      (P_Input_Tab          => Lx_Product_System
      ,P_Append_Tab         => Lx_Product_CovLevels
      ,X_Output_Tab         => Lx_Product_CovLevels_Out
      ,X_Result             => Lx_Result
      ,X_Return_Status      => Lx_Return_Status);

    IF Lx_Result <> G_TRUE THEN
      RAISE L_EXCEP_UNEXPECTED_ERR;
    END IF;

    Lx_Product_CovLevels  :=  Lx_Product_CovLevels_Out;

    Get_Customer_CovLevels
      (P_CovCust_Obj_Id     => Lx_Customer_Id
      ,X_Party_Id           => Lx_Party_Id
      ,X_Customer_CovLevels => Lx_Product_Customer
      ,X_Result             => Lx_Result
      ,X_Return_Status      => Lx_Return_Status);

    IF Lx_Result <> G_TRUE THEN
      RAISE L_EXCEP_UNEXPECTED_ERR;
    END IF;

    Append_ContItem_PlSql_Table
      (P_Input_Tab          => Lx_Product_Customer
      ,P_Append_Tab         => Lx_Product_CovLevels
      ,X_Output_Tab         => Lx_Product_CovLevels_Out
      ,X_Result             => Lx_Result
      ,X_Return_Status      => Lx_Return_Status);

    IF Lx_Result <> G_TRUE THEN
      RAISE L_EXCEP_UNEXPECTED_ERR;
    END IF;

    Lx_Product_CovLevels  :=  Lx_Product_CovLevels_Out;

  If Lx_Site_Type_Code = 'HZ_PARTY_SITES' Then

    Get_Site_CovLevels
      (P_CovSite_Obj_Id     => Lx_Site_Id
      ,P_Org_Id             => Ln_Org_Id
      ,X_Site_CovLevels     => Lx_Product_Site
      ,X_Result             => Lx_Result
      ,X_Return_Status      => Lx_Return_Status);

    IF Lx_Result <> G_TRUE THEN
      RAISE L_EXCEP_UNEXPECTED_ERR;
    END IF;

    Append_ContItem_PlSql_Table
      (P_Input_Tab          => Lx_Product_Site
      ,P_Append_Tab         => Lx_Product_CovLevels
      ,X_Output_Tab         => Lx_Product_CovLevels_Out
      ,X_Result             => Lx_Result
      ,X_Return_Status      => Lx_Return_Status);

    IF Lx_Result <> G_TRUE THEN
      RAISE L_EXCEP_UNEXPECTED_ERR;
    END IF;

    Lx_Product_CovLevels  :=  Lx_Product_CovLevels_Out;

   END IF; -- Lx_Site_Type_Code = 'HZ_PARTY_SITES'

   Li_TableIdx  := Lx_Product_CovLevels.LAST + 1;

   CLOSE Lx_Csr_CovProd;

  END LOOP;

 END IF;

    Lx_Product_CovLevels  :=  Lx_Product_CovLevels_Out;

    X_Party_Id            := Lx_Party_Id;
    X_Product_CovLevels   := Lx_Product_CovLevels;
    X_Result              := Lx_Result;
    X_Return_Status       := Lx_Return_Status;

  EXCEPTION

    WHEN L_EXCEP_NO_DATA_FOUND THEN

      IF Lx_Csr_CovProd%ISOPEN THEN
        CLOSE Lx_Csr_CovProd;
      END IF;

      X_Result              := G_TRUE;
      X_Return_Status       := G_TRUE;

    WHEN L_EXCEP_UNEXPECTED_ERR THEN

      X_Result              := Lx_Result;
      X_Return_Status       := Lx_Return_Status;

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
	,P_Token2_Value   => 'Get_Product_CovLevels');

      X_Result         := G_FALSE;
      X_Return_Status  := G_RET_STS_UNEXP_ERROR;

  END Get_Product_CovLevels;

/*--------------------------------------------------*/


  PROCEDURE Sort_Asc_ContItem_PlSql_Table
    (P_Input_Tab          IN  GT_ContItem_Ref
    ,X_Output_Tab         out nocopy GT_ContItem_Ref
    ,X_Result             out nocopy Gx_Boolean
    ,X_Return_Status   	  out nocopy Gx_Ret_Sts)  IS

    Lx_Sort_Tab           GT_ContItem_Ref;
    Lx_Result             Gx_Boolean;
    Lx_Return_Status      Gx_Ret_Sts;

    Li_TableIdx_Out       BINARY_INTEGER;
    Li_TableIdx_In        BINARY_INTEGER;

    Lx_Temp_ContItem      GR_ContItem_Ref;

    Lv_Composit_Val1      VARCHAR2(300);
    Lv_Composit_Val2      VARCHAR2(300);

  BEGIN

    Lx_Sort_Tab           := P_Input_Tab;
    Lx_Result             := G_TRUE;
    Lx_Return_Status      := G_RET_STS_SUCCESS;

    Li_TableIdx_Out  := Lx_Sort_Tab.FIRST;

    WHILE Li_TableIdx_Out IS NOT NULL LOOP

      Li_TableIdx_In  := Li_TableIdx_Out;

      WHILE Li_TableIdx_In IS NOT NULL LOOP

        Lv_Composit_Val1  := Lx_Sort_Tab(Li_TableIdx_Out).Rx_ObjCode||Lx_Sort_Tab(Li_TableIdx_Out).Rx_Obj1Id1
                             ||Lx_Sort_Tab(Li_TableIdx_Out).Rx_Obj1Id2;

        Lv_Composit_Val2  := Lx_Sort_Tab(Li_TableIdx_In).Rx_ObjCode||Lx_Sort_Tab(Li_TableIdx_In).Rx_Obj1Id1
                             ||Lx_Sort_Tab(Li_TableIdx_In).Rx_Obj1Id2;

        IF Lv_Composit_Val1 > Lv_Composit_Val2 THEN

          Lx_Temp_ContItem              := Lx_Sort_Tab(Li_TableIdx_Out);
          Lx_Sort_Tab(Li_TableIdx_Out)  := Lx_Sort_Tab(Li_TableIdx_In);
          Lx_Sort_Tab(Li_TableIdx_In)   := Lx_Temp_ContItem;

        END IF;

        Li_TableIdx_In  := Lx_Sort_Tab.NEXT(Li_TableIdx_In);

      END LOOP;

      Li_TableIdx_Out := Lx_Sort_Tab.NEXT(Li_TableIdx_Out);

    END LOOP;

    X_Output_Tab          := Lx_Sort_Tab;
    X_Result              := Lx_Result;
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
	,P_Token2_Value   => 'Sort_Asc_ContItem_PlSql_Table');

      X_Result           := G_FALSE;
      X_Return_Status    := G_RET_STS_UNEXP_ERROR;

  END Sort_Asc_ContItem_PlSql_Table;

-----------------------------------------------------------------------------------------------------------------------*

  PROCEDURE Dedup_ContItem_PlSql_Table
    (P_Input_Tab          IN  GT_ContItem_Ref
    ,X_Output_Tab         out nocopy GT_ContItem_Ref
    ,X_Result             out nocopy Gx_Boolean
    ,X_Return_Status   	  out nocopy Gx_Ret_Sts)  IS

    Lx_DeDup_Tab          GT_ContItem_Ref;
    Lx_Result             Gx_Boolean;
    Lx_Return_Status      Gx_Ret_Sts;

    Li_TableIdx           BINARY_INTEGER;

    Lx_Temp_ContItem      GR_ContItem_Ref;

    Lv_Composit_Val1      VARCHAR2(300);
    Lv_Composit_Val2      VARCHAR2(300);

  BEGIN

    Lx_DeDup_Tab          := P_Input_Tab;
    Lx_Result             := G_TRUE;
    Lx_Return_Status      := G_RET_STS_SUCCESS;

    Li_TableIdx          := Lx_DeDup_Tab.FIRST;

    WHILE Li_TableIdx IS NOT NULL LOOP

      Lv_Composit_Val1   := Lx_DeDup_Tab(Li_TableIdx).Rx_ObjCode||Lx_DeDup_Tab(Li_TableIdx).Rx_Obj1Id1
                           ||Lx_DeDup_Tab(Li_TableIdx).Rx_Obj1Id2;

      Lv_Composit_Val2   := Lx_Temp_ContItem.Rx_ObjCode||Lx_Temp_ContItem.Rx_Obj1Id1||Lx_Temp_ContItem.Rx_Obj1Id2;

      IF Lv_Composit_Val1 = Lv_Composit_Val2 THEN
        Lx_DeDup_Tab.DELETE(Li_TableIdx);
      ELSE
        Lx_Temp_ContItem  := Lx_DeDup_Tab(Li_TableIdx);
      END IF;

      Li_TableIdx         := Lx_DeDup_Tab.NEXT(Li_TableIdx);

    END LOOP;

    X_Output_Tab          := Lx_DeDup_Tab;
    X_Result              := Lx_Result;
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
	,P_Token2_Value   => 'Dedup_ContItem_PlSql_Table');

      X_Result         := G_FALSE;
      X_Return_Status  := G_RET_STS_UNEXP_ERROR;

  END Dedup_ContItem_PlSql_Table;

-----------------------------------------------------------------------------------------------------------------------*

  PROCEDURE Get_CovLevel_Contracts
    (P_CovLevel_Items         IN  GT_ContItem_Ref
    ,P_Party_Id               IN  Gx_OKS_Id
    ,X_CovLevel_Contracts     OUT NOCOPY GT_Contract_Ref
    ,X_Result                 OUT nocopy Gx_Boolean
    ,X_Return_Status   	      OUT nocopy Gx_Ret_Sts)
  IS

-- bug 3045667 needed resolution as pre filtering records based on party id
-- if the object_code = 'OKX_COVITEM' for performance improvements. used exists clause.


    CURSOR Lx_Csr_CovLvlOthr_Contracts(Cx_CovLevel_Obj_Id1 IN Gx_OKS_Id
                                    ,Cv_CovLevel_Obj_Id2 IN VARCHAR2
                                    ,Cx_CovLevel_Obj_Code IN Gx_JTOT_ObjCode) IS
       SELECT DISTINCT IT.Dnz_Chr_Id Dnz_Chr_Id, IT.Cle_Id
         FROM OKC_K_ITEMS IT
        WHERE IT.Object1_Id1  = TO_CHAR(Cx_CovLevel_Obj_Id1)
          AND (IT.Object1_Id2 = Cv_CovLevel_Obj_Id2 OR Cv_CovLevel_Obj_Id2 = '#')
          AND IT.Jtot_Object1_Code = Cx_CovLevel_Obj_Code;

     --bug 9083530 Added hints to the query to improve performance.
    CURSOR Lx_Csr_CovLvlItem_Contracts(Cx_CovLevel_Obj_Id1 IN Gx_OKS_Id
                                    ,Cv_CovLevel_Obj_Id2 IN VARCHAR2
                                    ,Cx_CovLevel_Obj_Code IN Gx_JTOT_ObjCode) IS
       SELECT /*+ index(IT OKC_K_ITEMS_N2) */ DISTINCT IT.Dnz_Chr_Id Dnz_Chr_Id, IT.Cle_Id
         FROM OKC_K_ITEMS IT
        WHERE IT.Object1_Id1  = TO_CHAR(Cx_CovLevel_Obj_Id1)
   --     AND (IT.Object1_Id2 = Cv_CovLevel_Obj_Id2 OR Cv_CovLevel_Obj_Id2 = '#')  -- BUG# 4735542
          AND IT.Jtot_Object1_Code = Cx_CovLevel_Obj_Code
          AND EXISTS (SELECT/*+ push_subq no_unnest */ '*'
                       FROM OKC_K_PARTY_ROLES_B PR
                      WHERE PR.CHR_ID = IT.DNZ_CHR_ID
                        AND PR.CLE_ID IS NULL
                        AND PR.DNZ_CHR_ID = IT.DNZ_CHR_ID
                        AND PR.OBJECT1_ID1 = TO_CHAR(p_party_id)
                        AND PR.OBJECT1_ID2 = '#'
                        AND PR.JTOT_OBJECT1_CODE = 'OKX_PARTY'
                        AND PR.RLE_CODE <> 'VENDOR' );

    Lx_Party_Id                 CONSTANT Gx_OKS_Id := P_Party_Id;
    Lx_CovLevel_Items           GT_ContItem_Ref;
    Lx_CovLevel_SortItems       GT_ContItem_Ref;
    Lx_CovLevel_DeDupItems      GT_ContItem_Ref;

    Lx_CovLvlOth_DeDupItems     GT_ContItem_Ref;
    Lx_CovLvlItem_DeDupItems    GT_ContItem_Ref;

    Lx_CovLevel_Obj_Id1         Gx_OKS_Id ;
    Lv_CovLevel_Obj_Id2         VARCHAR2(200) ;
    Lx_CovLevel_Obj_Code        Gx_JTOT_ObjCode ;

    Lx_CovLevel_Contracts       GT_Contract_Ref;

    Lx_Result                   Gx_Boolean;
    Lx_Return_Status            Gx_Ret_Sts;

    Li_TableIdx                 BINARY_INTEGER;
    Li_TabIdx_DeDup             BINARY_INTEGER;

    j                           number;
    k                           number;

    L_EXCEP_UNEXPECTED_ERR      EXCEPTION;

  BEGIN

    Lx_CovLevel_Items           := P_CovLevel_Items;

    Lx_Result                   := G_TRUE;
    Lx_Return_Status            := G_RET_STS_SUCCESS;

    Li_TableIdx                 := 0;
    j                           := 0;
    k                           := 0;

    Sort_Asc_ContItem_PlSql_Table
      (P_Input_Tab          => Lx_CovLevel_Items
      ,X_Output_Tab         => Lx_CovLevel_SortItems
      ,X_Result             => Lx_Result
      ,X_Return_Status      => Lx_Return_Status);

    IF Lx_Result <> G_TRUE THEN
      RAISE L_EXCEP_UNEXPECTED_ERR;
    END IF;

    Dedup_ContItem_PlSql_Table
      (P_Input_Tab          => Lx_CovLevel_SortItems
      ,X_Output_Tab         => Lx_CovLevel_DeDupItems
      ,X_Result             => Lx_Result
      ,X_Return_Status      => Lx_Return_Status);

    IF Lx_Result <> G_TRUE THEN
      RAISE L_EXCEP_UNEXPECTED_ERR;
    END IF;

  -- added due to bug 3045667
--    IF Lx_CovLevel_DeDupItems.COUNT > 0 THEN  -- fixed dated july 30, 2003
--     FOR i in Lx_CovLevel_DeDupItems.first..Lx_CovLevel_DeDupItems.last LOOP

     Li_TabIdx_DeDup        := Lx_CovLevel_DeDupItems.FIRST;
     Li_TableIdx            := 0; --NVL(Lx_CovLevel_Contracts.FIRST,0);

     WHILE Li_TabIdx_DeDup IS NOT NULL  LOOP

	  Li_TableIdx	:= Li_TableIdx + 1;

        IF Lx_CovLevel_DeDupItems(Li_TabIdx_DeDup).Rx_ObjCode = 'OKX_COVITEM' THEN
            Lx_CovLvlItem_DeDupItems(Li_TableIdx).Rx_Obj1Id1  := Lx_CovLevel_DeDupItems(Li_TabIdx_DeDup).Rx_Obj1Id1;
            Lx_CovLvlItem_DeDupItems(Li_TableIdx).Rx_Obj1Id2  := Lx_CovLevel_DeDupItems(Li_TabIdx_DeDup).Rx_Obj1Id2;
            Lx_CovLvlItem_DeDupItems(Li_TableIdx).Rx_ObjCode  := Lx_CovLevel_DeDupItems(Li_TabIdx_DeDup).Rx_ObjCode;
        ELSE
            Lx_CovLvlOth_DeDupItems(Li_TableIdx).Rx_Obj1Id1  := Lx_CovLevel_DeDupItems(Li_TabIdx_DeDup).Rx_Obj1Id1;
            Lx_CovLvlOth_DeDupItems(Li_TableIdx).Rx_Obj1Id2  := Lx_CovLevel_DeDupItems(Li_TabIdx_DeDup).Rx_Obj1Id2;
            Lx_CovLvlOth_DeDupItems(Li_TableIdx).Rx_ObjCode  := Lx_CovLevel_DeDupItems(Li_TabIdx_DeDup).Rx_ObjCode;
        END IF;

        Li_TabIdx_DeDup  := Lx_CovLevel_DeDupItems.NEXT(Li_TabIdx_DeDup);

	END LOOP;

--     END LOOP;
--    END IF;

    IF Lx_CovLvlOth_DeDupItems.count > 0 THEN -- bug 3045667

     Li_TabIdx_DeDup        := Lx_CovLvlOth_DeDupItems.FIRST;
     Li_TableIdx            := 0; --NVL(Lx_CovLevel_Contracts.FIRST,0);

     WHILE Li_TabIdx_DeDup IS NOT NULL  LOOP

      Lx_CovLevel_Obj_Id1  := Lx_CovLvlOth_DeDupItems(Li_TabIdx_DeDup).Rx_Obj1Id1;
      Lv_CovLevel_Obj_Id2  := Lx_CovLvlOth_DeDupItems(Li_TabIdx_DeDup).Rx_Obj1Id2;
      Lx_CovLevel_Obj_Code := Lx_CovLvlOth_DeDupItems(Li_TabIdx_DeDup).Rx_ObjCode;

      FOR Idx IN Lx_Csr_CovLvlOthr_Contracts(Lx_CovLevel_Obj_Id1,Lv_CovLevel_Obj_Id2,Lx_CovLevel_Obj_Code) LOOP

        Li_TableIdx   := Li_TableIdx + 1;
        Lx_CovLevel_Contracts(Li_TableIdx).Rx_Chr_Id := Idx.Dnz_Chr_Id;
        Lx_CovLevel_Contracts(Li_TableIdx).Rx_Cle_Id := Idx.Cle_Id;

        IF Lx_CovLevel_Obj_Code = 'OKX_COVITEM' THEN
          Lx_CovLevel_Contracts(Li_TableIdx).Rx_Pty_Id := Lx_Party_Id;
        ELSE
          Lx_CovLevel_Contracts(Li_TableIdx).Rx_Pty_Id := NULL;
        END IF;

      END LOOP;

      Li_TabIdx_DeDup  := Lx_CovLvlOth_DeDupItems.NEXT(Li_TabIdx_DeDup);

     END LOOP;

    END IF;

    IF Lx_CovLvlItem_DeDupItems.count > 0 THEN

     Li_TabIdx_DeDup        := Lx_CovLvlItem_DeDupItems.FIRST;
     Li_TableIdx            := nvl(Li_TableIdx,0); --NVL(Lx_covLevel_Contracts.LAST,0);

     WHILE Li_TabIdx_DeDup IS NOT NULL  LOOP

      Lx_CovLevel_Obj_Id1  := Lx_CovLvlItem_DeDupItems(Li_TabIdx_DeDup).Rx_Obj1Id1;
      Lv_CovLevel_Obj_Id2  := Lx_CovLvlItem_DeDupItems(Li_TabIdx_DeDup).Rx_Obj1Id2;
      Lx_CovLevel_Obj_Code := Lx_CovLvlItem_DeDupItems(Li_TabIdx_DeDup).Rx_ObjCode;

      FOR Idx IN Lx_Csr_CovLvlItem_Contracts(Lx_CovLevel_Obj_Id1,Lv_CovLevel_Obj_Id2,Lx_CovLevel_Obj_Code) LOOP

        Li_TableIdx   := Li_TableIdx + 1;
        Lx_CovLevel_Contracts(Li_TableIdx).Rx_Chr_Id := Idx.Dnz_Chr_Id;
        Lx_CovLevel_Contracts(Li_TableIdx).Rx_Cle_Id := Idx.Cle_Id;

        IF Lx_CovLevel_Obj_Code = 'OKX_COVITEM' THEN
          Lx_CovLevel_Contracts(Li_TableIdx).Rx_Pty_Id := Lx_Party_Id;
        ELSE
          Lx_CovLevel_Contracts(Li_TableIdx).Rx_Pty_Id := NULL;
        END IF;

      END LOOP;

      Li_TabIdx_DeDup  := Lx_CovLvlItem_DeDupItems.NEXT(Li_TabIdx_DeDup);

     END LOOP;

    END IF;


    X_CovLevel_Contracts  := Lx_CovLevel_Contracts;
    X_Result              := Lx_Result;
    X_Return_Status       := Lx_Return_Status;

  EXCEPTION

    WHEN L_EXCEP_UNEXPECTED_ERR THEN

      X_Result              := Lx_Result;
      X_Return_Status       := Lx_Return_Status;

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
	,P_Token2_Value   => 'Get_CovLevel_Contracts');

      X_Result         := G_FALSE;
      X_Return_Status  := G_RET_STS_UNEXP_ERROR;

  END Get_CovLevel_Contracts;

-----------------------------------------------------------------------------------------------------------------------*

  PROCEDURE Get_CovProd_Contracts
    (P_CovProd_Obj_Id         IN  Gx_OKS_Id
    ,P_Organization_Id        IN  NUMBER
    ,P_Org_Id                 IN  NUMBER
    ,X_CovProd_Contracts      out nocopy GT_Contract_Ref
    ,X_Result                 out nocopy Gx_Boolean
    ,X_Return_Status   	      out nocopy Gx_Ret_Sts)
  IS

    Lx_CovProd_Obj_Id         CONSTANT Gx_OKS_Id := P_CovProd_Obj_Id;
    Ln_Organization_Id        CONSTANT NUMBER := P_Organization_Id;
    Ln_Org_Id                 CONSTANT NUMBER := P_Org_Id;

    Lx_Party_Id               Okx_Customer_Accounts_V.Party_Id%TYPE;

    Lx_Product_CovLevels      GT_ContItem_Ref;
    Lx_CovProd_Contracts      GT_Contract_Ref;

    Lx_Result                 Gx_Boolean;
    Lx_Return_Status          Gx_Ret_Sts;

    L_EXCEP_UNEXPECTED_ERR    EXCEPTION;

  BEGIN

    Lx_Result                 := G_TRUE;
    Lx_Return_Status          := G_RET_STS_SUCCESS;

    Get_Product_CovLevels
      (P_CovProd_Obj_Id      => Lx_CovProd_Obj_Id
      ,P_Organization_Id     => Ln_Organization_Id
      ,P_Org_Id              => Ln_Org_Id
      ,X_Party_Id            => Lx_Party_Id
      ,X_Product_CovLevels   => Lx_Product_CovLevels
      ,X_Result              => Lx_Result
      ,X_Return_Status       => Lx_Return_Status);

    IF Lx_Result <> G_TRUE THEN
      RAISE L_EXCEP_UNEXPECTED_ERR;
    END IF;

    Get_CovLevel_Contracts
      (P_CovLevel_Items      => Lx_Product_CovLevels
      ,P_Party_Id            => Lx_Party_Id
      ,X_CovLevel_Contracts  => Lx_CovProd_Contracts
      ,X_Result              => Lx_Result
      ,X_Return_Status       => Lx_Return_Status);

    IF Lx_Result <> G_TRUE THEN
      RAISE L_EXCEP_UNEXPECTED_ERR;
    END IF;

    X_CovProd_Contracts   := Lx_CovProd_Contracts;
    X_Result              := Lx_Result;
    X_Return_Status       := Lx_Return_Status;

  EXCEPTION

    WHEN L_EXCEP_UNEXPECTED_ERR THEN

      X_Result            := Lx_Result;
      X_Return_Status     := Lx_Return_Status;

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
	,P_Token2_Value   => 'Get_CovProd_Contracts');

      X_Result           := G_FALSE;
      X_Return_Status    := G_RET_STS_UNEXP_ERROR;

  END Get_CovProd_Contracts;

-----------------------------------------------------------------------------------------------------------------------*

  PROCEDURE Get_CovItem_Contracts
    (P_CovItem_Obj_Id         IN  Gx_OKS_Id
    ,P_Organization_Id        IN  NUMBER
    ,P_Party_Id               IN  Gx_OKS_Id
    ,X_CovItem_Contracts      out nocopy GT_Contract_Ref
    ,X_Result                 out nocopy Gx_Boolean
    ,X_Return_Status   	      out nocopy Gx_Ret_Sts)
  IS

    Lx_CovItem_Obj_Id         CONSTANT Gx_OKS_Id := P_CovItem_Obj_Id;
    Ln_Organization_Id        CONSTANT NUMBER := P_Organization_Id;
    Lx_Party_Id               CONSTANT Gx_OKS_Id := P_Party_Id;

    Lx_Item_CovLevels         GT_ContItem_Ref;
    Lx_CovItem_Contracts      GT_Contract_Ref;

    Lx_Result                 Gx_Boolean;
    Lx_Return_Status          Gx_Ret_Sts;

    L_EXCEP_UNEXPECTED_ERR    EXCEPTION;

  BEGIN

    Lx_Result                 := G_TRUE;
    Lx_Return_Status          := G_RET_STS_SUCCESS;

    Get_Item_CovLevels
      (P_CovItem_Obj_Id      => Lx_CovItem_Obj_Id
      ,P_Organization_Id     => Ln_Organization_Id
      ,X_Item_CovLevels      => Lx_Item_CovLevels
      ,X_Result              => Lx_Result
      ,X_Return_Status       => Lx_Return_Status);

    IF Lx_Result <> G_TRUE THEN
      RAISE L_EXCEP_UNEXPECTED_ERR;
    END IF;

    Get_CovLevel_Contracts
      (P_CovLevel_Items      => Lx_Item_CovLevels
      ,P_Party_Id            => Lx_Party_Id
      ,X_CovLevel_Contracts  => Lx_CovItem_Contracts
      ,X_Result              => Lx_Result
      ,X_Return_Status       => Lx_Return_Status);

    IF Lx_Result <> G_TRUE THEN
      RAISE L_EXCEP_UNEXPECTED_ERR;
    END IF;

    X_CovItem_Contracts    := Lx_CovItem_Contracts;
    X_Result               := Lx_Result;
    X_Return_Status        := Lx_Return_Status;

  EXCEPTION

    WHEN L_EXCEP_UNEXPECTED_ERR THEN

      X_Result              := Lx_Result;
      X_Return_Status       := Lx_Return_Status;

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
	,P_Token2_Value   => 'Get_CovItem_Contracts');

      X_Result         := G_FALSE;
      X_Return_Status  := G_RET_STS_UNEXP_ERROR;

  END Get_CovItem_Contracts;

-----------------------------------------------------------------------------------------------------------------------*

  PROCEDURE Get_CovSys_Contracts
    (P_CovSys_Obj_Id          IN  Gx_OKS_Id
    ,P_Org_Id                 IN  NUMBER
    ,X_CovSys_Contracts       out nocopy GT_Contract_Ref
    ,X_Result                 out nocopy Gx_Boolean
    ,X_Return_Status   	      out nocopy Gx_Ret_Sts)
  IS

    Lx_CovSys_Obj_Id          CONSTANT Gx_OKS_Id := P_CovSys_Obj_Id;
    Ln_Org_Id                 CONSTANT NUMBER := P_Org_Id;

    Lx_System_CovLevels       GT_ContItem_Ref;
    Lx_CovSys_Contracts       GT_Contract_Ref;

    Lx_Result                 Gx_Boolean;
    Lx_Return_Status          Gx_Ret_Sts;

    L_EXCEP_UNEXPECTED_ERR    EXCEPTION;

  BEGIN

    Lx_Result                 := G_TRUE;
    Lx_Return_Status          := G_RET_STS_SUCCESS;

    Get_System_CovLevels
      (P_CovSys_Obj_Id       => Lx_CovSys_Obj_Id
      ,P_Org_Id              => Ln_Org_Id
      ,X_System_CovLevels    => Lx_System_CovLevels
      ,X_Result              => Lx_Result
      ,X_Return_Status       => Lx_Return_Status );

    IF Lx_Result <> G_TRUE THEN
      RAISE L_EXCEP_UNEXPECTED_ERR;
    END IF;

    Get_CovLevel_Contracts
      (P_CovLevel_Items      => Lx_System_CovLevels
      ,P_Party_Id            => NULL
      ,X_CovLevel_Contracts  => Lx_CovSys_Contracts
      ,X_Result              => Lx_Result
      ,X_Return_Status       => Lx_Return_Status);

    IF Lx_Result <> G_TRUE THEN
      RAISE L_EXCEP_UNEXPECTED_ERR;
    END IF;

    X_CovSys_Contracts    := Lx_CovSys_Contracts;
    X_Result              := Lx_Result;
    X_Return_Status       := Lx_Return_Status;

  EXCEPTION

    WHEN L_EXCEP_UNEXPECTED_ERR THEN

      X_Result              := Lx_Result;
      X_Return_Status       := Lx_Return_Status;

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
	,P_Token2_Value   => 'Get_CovSys_Contracts');

      X_Result         := G_FALSE;
      X_Return_Status  := G_RET_STS_UNEXP_ERROR;

  END Get_CovSys_Contracts;

-----------------------------------------------------------------------------------------------------------------------*

  PROCEDURE Get_CovSite_Contracts
    (P_CovSite_Obj_Id         IN  Gx_OKS_Id
    ,P_Org_Id                 IN  NUMBER
    ,X_CovSite_Contracts      out nocopy GT_Contract_Ref
    ,X_Result                 out nocopy Gx_Boolean
    ,X_Return_Status   	      out nocopy Gx_Ret_Sts)
  IS

    Lx_CovSite_Obj_Id         CONSTANT Gx_OKS_Id := P_CovSite_Obj_Id;
    Ln_Org_Id                 CONSTANT NUMBER := P_Org_Id;

    Lx_Site_CovLevels         GT_ContItem_Ref;
    Lx_CovSite_Contracts      GT_Contract_Ref;

    Lx_Result                 Gx_Boolean;
    Lx_Return_Status          Gx_Ret_Sts;

    L_EXCEP_UNEXPECTED_ERR    EXCEPTION;

  BEGIN

    Lx_Result                 := G_TRUE;
    Lx_Return_Status          := G_RET_STS_SUCCESS;

    Get_Site_CovLevels
      (P_CovSite_Obj_Id      => Lx_CovSite_Obj_Id
      ,P_Org_Id              => Ln_Org_Id
      ,X_Site_CovLevels      => Lx_Site_CovLevels
      ,X_Result              => Lx_Result
      ,X_Return_Status       => Lx_Return_Status );

    IF Lx_Result <> G_TRUE THEN
      RAISE L_EXCEP_UNEXPECTED_ERR;
    END IF;

    Get_CovLevel_Contracts
      (P_CovLevel_Items      => Lx_Site_CovLevels
      ,P_Party_Id            => NULL
      ,X_CovLevel_Contracts  => Lx_CovSite_Contracts
      ,X_Result              => Lx_Result
      ,X_Return_Status       => Lx_Return_Status);

    IF Lx_Result <> G_TRUE THEN
      RAISE L_EXCEP_UNEXPECTED_ERR;
    END IF;

    X_CovSite_Contracts   := Lx_CovSite_Contracts;
    X_Result              := Lx_Result;
    X_Return_Status       := Lx_Return_Status;

  EXCEPTION

    WHEN L_EXCEP_UNEXPECTED_ERR THEN

      X_Result            := Lx_Result;
      X_Return_Status     := Lx_Return_Status;

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
	,P_Token2_Value   => 'Get_CovSite_Contracts');

      X_Result           := G_FALSE;
      X_Return_Status    := G_RET_STS_UNEXP_ERROR;

  END Get_CovSite_Contracts;

-----------------------------------------------------------------------------------------------------------------------*

  PROCEDURE Get_CovCust_Contracts
    (P_CovCust_Obj_Id         IN  Gx_OKS_Id
    ,X_CovCust_Contracts      out nocopy GT_Contract_Ref
    ,X_Result                 out nocopy Gx_Boolean
    ,X_Return_Status   	      out nocopy Gx_Ret_Sts)
  IS

    Lx_CovCust_Obj_Id         CONSTANT Gx_OKS_Id := P_CovCust_Obj_Id;

    Lx_Cust_CovLevels         GT_ContItem_Ref;
    Lx_CovCust_Contracts      GT_Contract_Ref;

    Lx_Party_Id               Okx_Customer_Accounts_V.Party_Id%TYPE;

    Lx_Result                 Gx_Boolean;
    Lx_Return_Status          Gx_Ret_Sts;

    L_EXCEP_UNEXPECTED_ERR    EXCEPTION;

  BEGIN

    Lx_Result                 := G_TRUE;
    Lx_Return_Status          := G_RET_STS_SUCCESS;

    Get_Customer_CovLevels
      (P_CovCust_Obj_Id      => Lx_CovCust_Obj_Id
      ,X_Party_Id            => Lx_Party_Id
      ,X_Customer_CovLevels  => Lx_Cust_CovLevels
      ,X_Result              => Lx_Result
      ,X_Return_Status       => Lx_Return_Status );

    IF Lx_Result <> G_TRUE THEN
      RAISE L_EXCEP_UNEXPECTED_ERR;
    END IF;

    Get_CovLevel_Contracts
      (P_CovLevel_Items      => Lx_Cust_CovLevels
      ,P_Party_Id            => NULL
      ,X_CovLevel_Contracts  => Lx_CovCust_Contracts
      ,X_Result              => Lx_Result
      ,X_Return_Status       => Lx_Return_Status);

    IF Lx_Result <> G_TRUE THEN
      RAISE L_EXCEP_UNEXPECTED_ERR;
    END IF;

    X_CovCust_Contracts    := Lx_CovCust_Contracts;
    X_Result               := Lx_Result;
    X_Return_Status        := Lx_Return_Status;

  EXCEPTION

    WHEN L_EXCEP_UNEXPECTED_ERR THEN

      X_Result              := Lx_Result;
      X_Return_Status       := Lx_Return_Status;

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
	,P_Token2_Value   => 'Get_CovCust_Contracts');

      X_Result             := G_FALSE;
      X_Return_Status      := G_RET_STS_UNEXP_ERROR;

  END Get_CovCust_Contracts;

-----------------------------------------------------------------------------------------------------------------------*

  PROCEDURE Get_CovParty_Contracts
    (P_CovParty_Obj_Id        IN  Gx_OKS_Id
    ,X_CovParty_Contracts     out nocopy GT_Contract_Ref
    ,X_Result                 out nocopy Gx_Boolean
    ,X_Return_Status   	      out nocopy Gx_Ret_Sts)
  IS

    Lx_CovParty_Obj_Id        CONSTANT Gx_OKS_Id := P_CovParty_Obj_Id;

    Lx_Party_CovLevels        GT_ContItem_Ref;
    Lx_CovParty_Contracts     GT_Contract_Ref;

    Lx_Result                 Gx_Boolean;
    Lx_Return_Status          Gx_Ret_Sts;

    L_EXCEP_UNEXPECTED_ERR    EXCEPTION;

  BEGIN

    Lx_Result                 := G_TRUE;
    Lx_Return_Status          := G_RET_STS_SUCCESS;

    Get_Party_CovLevels
      (P_CovParty_Obj_Id     => Lx_CovParty_Obj_Id
      ,X_Party_CovLevels     => Lx_Party_CovLevels
      ,X_Result              => Lx_Result
      ,X_Return_Status       => Lx_Return_Status );

    IF Lx_Result <> G_TRUE THEN
      RAISE L_EXCEP_UNEXPECTED_ERR;
    END IF;

    Get_CovLevel_Contracts
      (P_CovLevel_Items      => Lx_Party_CovLevels
      ,P_Party_Id            => NULL
      ,X_CovLevel_Contracts  => Lx_CovParty_Contracts
      ,X_Result              => Lx_Result
      ,X_Return_Status       => Lx_Return_Status);

    IF Lx_Result <> G_TRUE THEN
      RAISE L_EXCEP_UNEXPECTED_ERR;
    END IF;

    X_CovParty_Contracts  := Lx_CovParty_Contracts;
    X_Result              := Lx_Result;
    X_Return_Status       := Lx_Return_Status;

  EXCEPTION

    WHEN L_EXCEP_UNEXPECTED_ERR THEN

      X_Result            := Lx_Result;
      X_Return_Status     := Lx_Return_Status;

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
	,P_Token2_Value   => 'Get_CovParty_Contracts');

      X_Result          := G_FALSE;
      X_Return_Status   := G_RET_STS_UNEXP_ERROR;

  END Get_CovParty_Contracts;

-----------------------------------------------------------------------------------------------------------------------*

  PROCEDURE Get_CovLvlLine_Contracts
    (P_CovLvlLine_Id          IN  Gx_OKS_Id
    ,X_Contracts              out nocopy GT_Contract_Ref
    ,X_Result                 out nocopy Gx_Boolean
    ,X_Return_Status   	      out nocopy Gx_Ret_Sts)
  IS

    CURSOR Lx_Csr_Contracts(Cx_CovLvlLine_Id IN Gx_OKS_Id) IS
      SELECT Dnz_Chr_Id, Id
        FROM Okc_K_Lines_B
       WHERE Id = Cx_CovLvlLine_Id
         AND Lse_Id In (7,8,9,10,11,35,18,25);

    Lx_CovLvlLine_Id         CONSTANT Gx_OKS_Id := P_CovLvlLine_Id;

    Lx_Contracts             GT_Contract_Ref;
    Li_TableIdx              BINARY_INTEGER;

    Lx_Result                 Gx_Boolean;
    Lx_Return_Status          Gx_Ret_Sts;

  BEGIN

    Lx_Result                 := G_TRUE;
    Lx_Return_Status          := G_RET_STS_SUCCESS;

    Li_TableIdx          := 0;

    FOR Idx IN Lx_Csr_Contracts(Lx_CovLvlLine_Id) LOOP

      Li_TableIdx  := Li_TableIdx + 1;
      Lx_Contracts(Li_TableIdx).Rx_Chr_Id := Idx.Dnz_Chr_Id;
      Lx_Contracts(Li_TableIdx).Rx_Cle_Id := Idx.Id;
      Lx_Contracts(Li_TableIdx).Rx_Pty_Id := NULL;

    END LOOP;

    X_Contracts          := Lx_Contracts;
    X_Result             := Lx_Result;
    X_Return_Status      := Lx_Return_Status;

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
	,P_Token2_Value   => 'Get_CovLvlLine_Contracts');

      X_Result          := G_FALSE;
      X_Return_Status   := G_RET_STS_UNEXP_ERROR;

  END Get_CovLvlLine_Contracts;

-----------------------------------------------------------------------------------------------------------------------*

  PROCEDURE Get_SrvLine_Contracts
    (P_SrvLine_Id             IN  Gx_OKS_Id
    ,X_Contracts              out nocopy GT_Contract_Ref
    ,X_Result                 out nocopy Gx_Boolean
    ,X_Return_Status   	      out nocopy Gx_Ret_Sts)
  IS

    CURSOR Lx_Csr_Contracts(Cx_SrvLine_Id IN Gx_OKS_Id) IS
      SELECT Dnz_Chr_Id, Id
        FROM Okc_K_Lines_B
       WHERE Id = Cx_SrvLine_Id
         AND Lse_Id In (1,14,19);

    Lx_SrvLine_Id            CONSTANT Gx_OKS_Id := P_SrvLine_Id;
    Lx_Contracts             GT_Contract_Ref;
    Li_TableIdx              BINARY_INTEGER;

    Lx_Result                 Gx_Boolean;
    Lx_Return_Status          Gx_Ret_Sts;

  BEGIN

    Lx_Result                 := G_TRUE;
    Lx_Return_Status          := G_RET_STS_SUCCESS;

    Li_TableIdx          := 0;

    FOR Idx IN Lx_Csr_Contracts(Lx_SrvLine_Id) LOOP

      Li_TableIdx  := Li_TableIdx + 1;
      Lx_Contracts(Li_TableIdx).Rx_Chr_Id := Idx.Dnz_Chr_Id;
      Lx_Contracts(Li_TableIdx).Rx_Cle_Id := Idx.Id;
      Lx_Contracts(Li_TableIdx).Rx_Pty_Id := NULL;

    END LOOP;

    X_Contracts          := Lx_Contracts;
    X_Result             := Lx_Result;
    X_Return_Status      := Lx_Return_Status;

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
	,P_Token2_Value   => 'Get_SrvLine_Contracts');

      X_Result          := G_FALSE;
      X_Return_Status   := G_RET_STS_UNEXP_ERROR;

  END Get_SrvLine_Contracts;

-----------------------------------------------------------------------------------------------------------------------*

  PROCEDURE Get_Contracts_Id
    (P_Contract_Num           IN  VARCHAR2
    ,P_Contract_Num_Modifier  IN  VARCHAR2
    ,X_Contracts              out nocopy GT_Contract_Ref
    ,X_Result                 out nocopy Gx_Boolean
    ,X_Return_Status   	      out nocopy Gx_Ret_Sts)
  IS

-- cursor modified to fix bug 3041443

    CURSOR Lx_Csr_Contracts(Cv_Contract_Num IN VARCHAR2, Cv_Contract_Num_Modifier IN VARCHAR2) IS
      SELECT Id
        FROM OKC_K_HEADERS_ALL_B  -- OKC_K_HEADERS_B HDR  -- Modified for 12.0 MOAC project (JVARGHES)
       WHERE Contract_Number = Cv_Contract_Num
         --AND (Cv_Contract_Num_Modifier IS NULL OR Contract_Number_Modifier = Cv_Contract_Num_Modifier);
         --AND nvl(Contract_Number_Modifier,-99) = nvl(Cv_Contract_Num_Modifier,-99)
         AND nvl(Contract_Number_Modifier,'#') = nvl(Cv_Contract_Num_Modifier,nvl(Contract_Number_Modifier,'#'));

    Lv_Contract_Num            CONSTANT VARCHAR2(120) := P_Contract_Num;
    Lv_Contract_Num_Modifier   CONSTANT VARCHAR2(120) := P_Contract_Num_Modifier;

    Lx_Contracts               GT_Contract_Ref;
    Li_TableIdx                BINARY_INTEGER;

    Lx_Result                 Gx_Boolean;
    Lx_Return_Status          Gx_Ret_Sts;

  BEGIN

    Lx_Result                 := G_TRUE;
    Lx_Return_Status          := G_RET_STS_SUCCESS;

    Li_TableIdx           := 0;

    FOR Idx IN Lx_Csr_Contracts(Lv_Contract_Num, Lv_Contract_Num_Modifier) LOOP

      Li_TableIdx  := Li_TableIdx + 1;
      Lx_Contracts(Li_TableIdx).Rx_Chr_Id := Idx.Id;
      Lx_Contracts(Li_TableIdx).Rx_Cle_Id := NULL;
      Lx_Contracts(Li_TableIdx).Rx_Pty_Id := NULL;

    END LOOP;

    X_Contracts          := Lx_Contracts;
    X_Result             := Lx_Result;
    X_Return_Status      := Lx_Return_Status;

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
	,P_Token2_Value   => 'Get_Contracts_Id');

      X_Result            := G_FALSE;
      X_Return_Status     := G_RET_STS_UNEXP_ERROR;

  END Get_Contracts_Id;

-----------------------------------------------------------------------------------------------------------------------*

  PROCEDURE Get_Service_Line_Details
    (P_SrvLine_Id       IN  Gx_OKS_Id
    ,P_Organization_Id  IN  NUMBER
    ,X_Name             out nocopy VARCHAR2
    ,X_Description      out nocopy VARCHAR2
    ,X_Start_Date       out nocopy DATE
    ,X_End_Date         out nocopy DATE
    ,X_Date_Terminated  out nocopy DATE
    ,X_Eff_End_Date     out nocopy DATE
    ,X_Result           out nocopy Gx_Boolean
    ,X_Return_Status   	out nocopy Gx_Ret_Sts)
  IS

    CURSOR Lx_Csr_SrvItem (Cx_SrvLine_Id In Gx_OKS_Id, Cn_Organization_Id IN NUMBER) IS
      SELECT XI.Name
            ,XI.Description
            ,SV.Start_Date
            ,Get_End_Date_Time(SV.End_Date) End_Date
            ,Get_End_Date_Time(SV.Date_Terminated) Date_Terminated
        FROM Okx_System_Items_V XI
            ,Okc_K_Items IT
            ,Okc_K_Lines_B SV
       WHERE SV.Id = Cx_SrvLine_Id
         AND SV.Lse_Id IN (1,14,19)
         AND IT.Cle_Id = SV.Id
   --    AND IT.Jtot_Object1_Code IN ('OKX_SERVICE','OKX_WARRANTY')
         AND XI.Id1 = IT.Object1_Id1
         AND XI.Id2 = IT.Object1_Id2
         AND XI.Service_Item_Flag = 'Y'
         AND XI.Organization_Id = Cn_Organization_Id;

    Lx_SrvLine_Id            CONSTANT Gx_OKS_Id := P_SrvLine_Id;
    Ln_Organization_Id       CONSTANT NUMBER := P_Organization_Id;
    Lv_Name                  Okx_System_Items_V.Name%TYPE;         --VARCHAR2(240);
    Lv_Description           Okx_System_Items_V.Description%TYPE;  --VARCHAR2(40);
    Ld_Start_Date            DATE;
    Ld_End_Date              DATE;
    Ld_Date_Terminated       DATE;
    Ld_Eff_End_Date          DATE;

    Lx_Result                 Gx_Boolean;
    Lx_Return_Status          Gx_Ret_Sts;

  BEGIN

    Lx_Result                 := G_TRUE;
    Lx_Return_Status          := G_RET_STS_SUCCESS;

    OPEN Lx_Csr_SrvItem (Lx_SrvLine_Id,Ln_Organization_Id);
    FETCH Lx_Csr_SrvItem INTO Lv_Name, Lv_Description,Ld_Start_Date,Ld_End_Date,Ld_Date_Terminated;
    CLOSE Lx_Csr_SrvItem;

    IF Ld_Date_Terminated < Ld_End_Date THEN
      Ld_Eff_End_Date := Ld_Date_Terminated;
   -- grace period not allowed for terminated line
    ELSE
      Ld_Eff_End_Date := Ld_End_Date;

   -- grace period changes starts
      IF G_GRACE_PROFILE_SET = 'Y' AND Ld_Date_Terminated IS NULL THEN
-- grace period changes are done only if line end date matches contract end date
        IF  trunc(Ld_Eff_End_Date) = trunc(G_CONTRACT_END_DATE) THEN
            Ld_Eff_End_Date := Get_Final_End_Date(G_CONTRACT_ID,Ld_Eff_End_Date);
        END IF;

      END IF;
-- grace period changes ends

    END IF;

    X_Name               := Lv_Name;
    X_Description        := Lv_Description;

    X_Start_Date         := Ld_Start_Date;
    X_End_Date           := Ld_End_Date;
    X_Date_Terminated    := Ld_Date_Terminated;
    X_Eff_End_Date       := Ld_Eff_End_Date;

    X_Result             := Lx_Result;
    X_Return_Status      := Lx_Return_Status;

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
	,P_Token2_Value   => 'Get_Service_Line_Details');

      X_Result          := G_FALSE;
      X_Return_Status   := G_RET_STS_UNEXP_ERROR;

  END Get_Service_Line_Details;

-----------------------------------------------------------------------------------------------------------------------*

  PROCEDURE Get_Coverage_Line_Details
    (P_SrvLine_Id       IN  Gx_OKS_Id
    ,P_Organization_Id  IN  NUMBER
    ,X_Cov_Id           out nocopy Gx_OKS_Id
    ,X_Name             out nocopy VARCHAR2
    ,X_Description      out nocopy VARCHAR2
    ,X_Start_Date       out nocopy DATE
    ,X_End_Date         out nocopy DATE
    ,X_Date_Terminated  out nocopy DATE
    ,X_Eff_End_Date     out nocopy DATE
    ,X_Result           out nocopy Gx_Boolean
    ,X_Return_Status   	out nocopy Gx_Ret_Sts)

  IS
    --
    -- Modified for 12.0 Coverage Rearch project (JVARGHES)
    --
    --
    --CURSOR Lx_Csr_CovItem(Cx_SrvLine_Id IN  Gx_OKS_Id) IS
    --  SELECT Id
    --	    ,Name
    --	    ,Item_Description
    --	    ,Start_Date
    --    ,Get_End_Date_Time(End_Date) End_Date
    --      ,Get_End_Date_Time(Date_Terminated) Date_Terminated
    --   FROM  Okc_K_Lines_V
    --  WHERE  Cle_Id = Cx_SrvLine_Id
    --    AND  Lse_Id IN (2,15,20);
    --
    -- Added for 12.0 Coverage Rearch project (JVARGHES)
    --
    --
    CURSOR Lx_Csr_CovItem(Cx_SrvLine_Id IN  Gx_OKS_Id) IS
      SELECT COV.Id
	      ,COV.Name
	      ,COV.Item_Description
	      ,COV.Start_Date
	      ,Get_End_Date_Time(COV.End_Date) End_Date
            ,Get_End_Date_Time(COV.Date_Terminated) Date_Terminated
            ,KSL.Standard_COV_YN
	      ,SVL.Start_Date
	      ,Get_End_Date_Time(SVL.End_Date) End_Date
            ,Get_End_Date_Time(SVL.Date_Terminated) Date_Terminated
       FROM  Okc_K_Lines_B SVL
            ,Oks_K_Lines_B KSL
            ,Okc_K_Lines_V COV
      WHERE SVL.Id = Cx_SrvLine_Id
        AND SVL.Lse_Id in (1,14,19)
        AND KSL.Cle_Id = SVL.Id
        AND COV.ID = KSL.Coverage_Id
	  AND COV.Lse_Id IN (2,15,20);
    --

    Lx_SrvLine_Id            CONSTANT Gx_OKS_Id := P_SrvLine_Id;
    Ln_Organization_Id       CONSTANT NUMBER := P_Organization_Id;
    Lx_Cov_Id                Gx_OKS_Id;
    Lv_Name                  Okc_K_Lines_V.Name%TYPE;              --VARCHAR2(240);
    Lv_Description           Okc_K_Lines_V.Item_Description%TYPE;  --VARCHAR2(1995);
    Ld_Start_Date            DATE;
    Ld_End_Date              DATE;
    Ld_Date_Terminated       DATE;
    Ld_Eff_End_Date          DATE;

    Lx_Result                 Gx_Boolean;
    Lx_Return_Status          Gx_Ret_Sts;

    -- Added for 12.0 Coverage Rearch project (JVARGHES)

    Lv_Std_Cov_YN              VARCHAR2(10);

    Ld_SVL_Start_Date          DATE;
    Ld_SVL_End_Date            DATE;
    Ld_SVL_Date_Terminated     DATE;

    --

  BEGIN

    Lx_Result                 := G_TRUE;
    Lx_Return_Status          := G_RET_STS_SUCCESS;

    OPEN Lx_Csr_CovItem (Lx_SrvLine_Id);

    --
    -- Modified for 12.0 Coverage Rearch project (JVARGHES)
    --
    -- FETCH Lx_Csr_CovItem INTO Lx_Cov_Id,Lv_Name,Lv_Description
    --                         ,Ld_Start_Date,Ld_End_Date,Ld_Date_Terminated;
    --
    --
    FETCH Lx_Csr_CovItem INTO Lx_Cov_Id,Lv_Name,Lv_Description
                             ,Ld_Start_Date,Ld_End_Date,Ld_Date_Terminated,Lv_Std_Cov_YN
                             ,Ld_SVL_Start_Date,Ld_SVL_End_Date,Ld_SVL_Date_Terminated;

    --
    --
    CLOSE Lx_Csr_CovItem;

    --
    -- Modified for 12.0 Coverage Rearch project (JVARGHES)
    --

    IF NVL(Lv_Std_Cov_YN,'*') = 'Y' THEN

      Ld_Start_Date      := Ld_SVL_Start_Date;
      Ld_End_Date        := Ld_SVL_End_Date;
      Ld_Date_Terminated := Ld_SVL_Date_Terminated;

    END IF;

    --

    IF Ld_Date_Terminated < Ld_End_Date THEN
      Ld_Eff_End_Date := Ld_Date_Terminated;
-- grace period changes not allowed for terminated line
    ELSE
      Ld_Eff_End_Date := Ld_End_Date;

-- grace period changes starts

      IF G_GRACE_PROFILE_SET = 'Y' AND Ld_Date_Terminated IS NULL THEN
-- grace period changes are done only if line end date matches contract end date

         IF  trunc(Ld_Eff_End_Date) = trunc(G_CONTRACT_END_DATE) THEN
             Ld_Eff_End_Date := Get_Final_End_Date(G_CONTRACT_ID,Ld_Eff_End_Date);
         END IF;

      END IF;
-- grace period changes ends

    END IF;

    X_Cov_Id             := Lx_Cov_Id;
    X_Name               := Lv_Name;
    X_Description        := Lv_Description;
    X_Start_Date         := Ld_Start_Date;
    X_End_Date           := Ld_End_Date;
    X_Date_Terminated    := Ld_Date_Terminated;
    X_Eff_End_Date       := Ld_Eff_End_Date;

    X_Result             := Lx_Result;
    X_Return_Status      := Lx_Return_Status;

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
	,P_Token2_Value   => 'Get_Coverage_Line_Details');

      X_Result            := G_FALSE;
      X_Return_Status     := G_RET_STS_UNEXP_ERROR;

  END Get_Coverage_Line_Details;

-----------------------------------------------------------------------------------------------------------------------*

  PROCEDURE Sort_Asc_GetContracts_01
    (P_Input_Tab          IN  Ent_Cont_Tbl
    ,X_Output_Tab         out nocopy Ent_Cont_Tbl
    ,X_Result             out nocopy Gx_Boolean
    ,X_Return_Status   	  out nocopy Gx_Ret_Sts)  IS

    Lx_Sort_Tab           Ent_Cont_Tbl;

    Li_TableIdx_Out       BINARY_INTEGER;
    Li_TableIdx_In        BINARY_INTEGER;

    Lx_Temp_ContItem      Ent_Cont_Rec;

    Lv_Composit_Val1      VARCHAR2(1000);     --VARCHAR2(600);
    Lv_Composit_Val2      VARCHAR2(1000);     --VARCHAR2(600);

    Lx_Result                 Gx_Boolean;
    Lx_Return_Status          Gx_Ret_Sts;

  BEGIN

    Lx_Sort_Tab               := P_Input_Tab;
    Lx_Result                 := G_TRUE;
    Lx_Return_Status          := G_RET_STS_SUCCESS;

    Li_TableIdx_Out  := Lx_Sort_Tab.FIRST;

    WHILE Li_TableIdx_Out IS NOT NULL LOOP

      Li_TableIdx_In  := Li_TableIdx_Out;

      WHILE Li_TableIdx_In IS NOT NULL LOOP

        Lv_Composit_Val1  := RPAD(Lx_Sort_Tab(Li_TableIdx_Out).Contract_Number,120,' ')
                              ||RPAD(Lx_Sort_Tab(Li_TableIdx_Out).Service_Name,250,' ')           --150
                              ||RPAD(Lx_Sort_Tab(Li_TableIdx_Out).Coverage_Term_Name,250,' ')     --150
                              ||RPAD(Lx_Sort_Tab(Li_TableIdx_Out).Coverage_Level,250,' ');        --150

        Lv_Composit_Val2  := RPAD(Lx_Sort_Tab(Li_TableIdx_In).Contract_Number,120,' ')
                              ||RPAD(Lx_Sort_Tab(Li_TableIdx_In).Service_Name,250,' ')            --150
                              ||RPAD(Lx_Sort_Tab(Li_TableIdx_In).Coverage_Term_Name,250,' ')      --150
                              ||RPAD(Lx_Sort_Tab(Li_TableIdx_In).Coverage_Level,250,' ');         --150

        IF Lv_Composit_Val1 > Lv_Composit_Val2 THEN

          Lx_Temp_ContItem              := Lx_Sort_Tab(Li_TableIdx_Out);
          Lx_Sort_Tab(Li_TableIdx_Out)  := Lx_Sort_Tab(Li_TableIdx_In);
          Lx_Sort_Tab(Li_TableIdx_In)   := Lx_Temp_ContItem;

        END IF;

        Li_TableIdx_In  := Lx_Sort_Tab.NEXT(Li_TableIdx_In);

      END LOOP;

      Li_TableIdx_Out := Lx_Sort_Tab.NEXT(Li_TableIdx_Out);

    END LOOP;

    X_Output_Tab          := Lx_Sort_Tab;
    X_Result              := Lx_Result;
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
	,P_Token2_Value   => 'Sort_Asc_GetContracts_01');

      X_Result           := G_FALSE;
      X_Return_Status    := G_RET_STS_UNEXP_ERROR;

  END Sort_Asc_GetContracts_01;

-----------------------------------------------------------------------------------------------------------------------*

  PROCEDURE Get_Prof_Service_Name_And_Desc
    (P_Profile_Value    IN  VARCHAR2
    ,P_Db_Srv_Name      IN  VARCHAR2
    ,P_Db_Srv_Desc      IN  VARCHAR2
    ,X_Prof_Srv_Name    out nocopy VARCHAR2
    ,X_Prof_Srv_Desc    out nocopy VARCHAR2
    ,X_Result           out nocopy Gx_Boolean
    ,X_Return_Status   	out nocopy Gx_Ret_Sts)
  IS

    Lv_Prof_Value       CONSTANT VARCHAR2(300) := P_Profile_Value;
    Lv_Db_Srv_Name      CONSTANT VARCHAR2(300) := P_Db_Srv_Name;
    Lv_Db_Srv_Desc      CONSTANT VARCHAR2(300) := P_Db_Srv_Desc;

    Lv_Prof_Srv_Name    VARCHAR2(300);
    Lv_Prof_Srv_Desc    VARCHAR2(300);

    Lx_Result                 Gx_Boolean;
    Lx_Return_Status          Gx_Ret_Sts;

  BEGIN

    Lx_Result                 := G_TRUE;
    Lx_Return_Status          := G_RET_STS_SUCCESS;

    IF Lv_Prof_Value = 'DISPLAY_NAME' THEN

      Lv_Prof_Srv_Name := Lv_Db_Srv_Name;--Lv_Db_Srv_Desc;-- no swapping to be done anymore
      Lv_Prof_Srv_Desc := Lv_Db_Srv_Desc;--Lv_Db_Srv_Name;-- no swapping to be done anymore

    ELSE

      Lv_Prof_Srv_Name := Lv_Db_Srv_Name;
      Lv_Prof_Srv_Desc := Lv_Db_Srv_Desc;

    END IF;

    X_Prof_Srv_Name    := Lv_Prof_Srv_Name;
    X_Prof_Srv_Desc    := Lv_Prof_Srv_Desc;
    X_Result           := Lx_Result;
    X_Return_Status    := Lx_Return_Status;

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
	,P_Token2_Value   => 'Get_Prof_Service_Name_And_Desc');

      X_Result          := G_FALSE;
      X_Return_Status   := G_RET_STS_UNEXP_ERROR;

  END Get_Prof_Service_Name_And_Desc;

-----------------------------------------------------------------------------------------------------------------------*

  PROCEDURE Get_Contracts_01_Format
    (P_Contracts        IN  GT_Contract_Ref
    ,P_Request_Date     IN  DATE
    ,P_Validate_Flag    IN  VARCHAR2
    ,P_Chr_Id_Flag      IN  VARCHAR2             --Bug# 4719510 (JVARGHES)
    ,X_Contracts_01     out nocopy Ent_Cont_Tbl
    ,X_Result           out nocopy Gx_Boolean
    ,X_Return_Status   	out nocopy Gx_Ret_Sts)
  IS

    CURSOR Lx_Csr_Contracts(Cx_Chr_Id IN Gx_OKS_Id, Cx_Cle_Id IN Gx_OKS_Id,Cv_Cont_Pty_Id IN VARCHAR2
                           ,Cx_Lang in VARCHAR2) IS
      SELECT HD.Id Contract_Id
            ,HD.Contract_Number
            ,HD.Contract_Number_Modifier
            ,HD.Authoring_Org_Id
            ,HD.Inv_Organization_Id
            ,HD.End_Date HDR_End_Date --grace period changes
	    ,CL.Cle_Id Service_Line_Id
	    ,CL.Id Coverage_Level_Line_Id
            ,SB.Lty_Code Coverage_Level_Code
            ,ST.Name Coverage_Level
            ,CL.Start_Date
	    ,Get_End_Date_Time(CL.End_Date) End_Date
            ,Get_End_Date_Time(CL.Date_Terminated) Date_Terminated
	    ,IT.Object1_Id1 Coverage_Level_Id
	    ,DECODE(SB.Id, 14, 'Y', 15, 'Y', 16, 'Y', 17, 'Y', 18, 'Y', 'N') Warranty_Flag
       FROM  OKC_K_HEADERS_ALL_B HD  -- OKC_K_HEADERS_B HDR  -- Modified for 12.0 MOAC project (JVARGHES)
	    ,Okc_Line_Styles_B SB
	    ,Okc_Line_Styles_TL ST
	    ,Okc_K_Items IT
            ,Okc_K_Lines_B CL
       WHERE CL.Id = NVL(Cx_Cle_Id, CL.Id)
         AND CL.Dnz_Chr_Id = Cx_Chr_Id
         AND CL.Lse_ID IN (7,8,9,10,11,35,18,25)
         AND IT.Cle_Id = CL.Id
         AND SB.Id = CL.Lse_Id
         AND ST.Id = SB.Id
         and st.language = Cx_Lang
         AND HD.Id = CL.Dnz_Chr_Id
         AND HD.Scs_Code IN ('SERVICE','WARRANTY')
         AND HD.Id > -1
         AND HD.Template_YN <> 'Y'
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
                          AND PR.RLE_CODE <> 'VENDOR' ));

    Lx_Contracts             GT_Contract_Ref;
    Ld_Request_Date          DATE;
    Lv_Validate_Flag         VARCHAR2(1);

    Lv_Cont_Pty_Id           VARCHAR2(100);

    Lx_Contracts_01          Ent_Cont_Tbl;
    Lx_Contracts_01_Out      Ent_Cont_Tbl;

    Li_TableIdx              BINARY_INTEGER;
    Li_OutTab_Idx            BINARY_INTEGER;
    Lv_Entile_Flag           VARCHAR2(1);
    Lv_Effective_Falg        VARCHAR2(1);

    Ld_CovLvl_Eff_End_Date   DATE;

    Lv_Srv_Name              Okx_System_Items_V.Name%TYPE;          --VARCHAR2(150) ;
    Lv_Srv_Description       Okx_System_Items_V.Description%TYPE;   --VARCHAR2(1995);
    Lv_Prof_Srv_Name         VARCHAR2(300) ;
    Lv_Prof_Srv_Desc         VARCHAR2(300);

    Ld_Srv_Start_Date        DATE;
    Ld_Srv_End_Date          DATE;
    Ld_Srv_Date_Terminated   DATE;
    Ld_Srv_Eff_End_Date      DATE;

    Lx_Cov_Id                Gx_OKS_Id;
    Lv_Cov_Name              Okc_K_Lines_V.Name%TYPE;               --VARCHAR2(150) ;
    Lv_Cov_Description       Okc_K_Lines_V.Item_Description%TYPE;   --VARCHAR2(1995);
    Ld_Cov_Start_Date        DATE;
    Ld_Cov_End_Date          DATE;
    Ld_Cov_Date_Terminated   DATE;
    Ld_Cov_Eff_End_Date      DATE;

    Lx_Cov_Type_Code         Oks_Cov_Types_B.Code%TYPE;
    Lx_Cov_Type_Meaning      Oks_Cov_Types_TL.Meaning%TYPE;
    Lx_Cov_Type_Description  Oks_Cov_Types_TL.Description%TYPE;
    Lx_Cov_Type_Imp_Level    Oks_Cov_Types_B.Importance_Level%TYPE;

    Lv_Prof_Name             CONSTANT VARCHAR2(300) := 'OKS_ITEM_DISPLAY_PREFERENCE';
    Lv_Prof_Value            VARCHAR2(300);

    Lx_Lang                  CONSTANT VARCHAR2(30) := userenv('LANG');

    L_EXCEP_UNEXPECTED_ERR   EXCEPTION;

    Lx_Result                 Gx_Boolean;
    Lx_Return_Status          Gx_Ret_Sts;

  BEGIN

    Lx_Result                 := G_FALSE; -- #5092665 hmnair        /*Bug:6767455*/
    Lx_Return_Status          := G_RET_STS_SUCCESS;

    Lx_Contracts              := P_Contracts;

    Lv_Validate_Flag          := nvl(P_Validate_Flag,'N');
    Li_OutTab_Idx             := 0;

    Ld_Request_Date           := nvl(P_Request_Date,sysdate);

    --
    IF Lv_Validate_Flag = 'Y' THEN
       Lv_Validate_Flag := 'T';
    END IF;
    --
    FND_PROFILE.Get(Lv_Prof_Name, Lv_Prof_Value);
    --

    Li_TableIdx  := Lx_Contracts.FIRST;

    WHILE Li_TableIdx IS NOT NULL LOOP

      Lv_Cont_Pty_Id  := TO_CHAR(Lx_Contracts(Li_TableIdx).Rx_Pty_Id);

      FOR Idx IN Lx_Csr_Contracts(Lx_Contracts(Li_TableIdx).Rx_Chr_Id, Lx_Contracts(Li_TableIdx).Rx_Cle_Id,
                                  Lv_Cont_Pty_Id,Lx_Lang) LOOP

        Lv_Srv_Name              := NULL;
        Lv_Srv_Description       := NULL;
        Ld_Srv_Start_Date        := NULL;
        Ld_Srv_End_Date          := NULL;
        Ld_Srv_Date_Terminated   := NULL;
        Ld_Srv_Eff_End_Date      := NULL;

        Lx_Cov_Id                := NULL;
        Lv_Cov_Name              := NULL;
        Lv_Cov_Description       := NULL;
        Ld_Cov_Start_Date        := NULL;
        Ld_Cov_End_Date          := NULL;
        Ld_Cov_Date_Terminated   := NULL;
        Ld_Cov_Eff_End_Date      := NULL;

        IF Idx.Date_Terminated < Idx.End_Date THEN
        -- grace period not allowed for terminated line
          Ld_CovLvl_Eff_End_Date := Idx.Date_Terminated;
        ELSE
          Ld_CovLvl_Eff_End_Date := Idx.End_Date;
        -- grace period changes starts

          IF G_GRACE_PROFILE_SET = 'Y' AND Idx.Date_Terminated IS NULL THEN
-- grace period changes are done only if line end date matches contract end date

            G_CONTRACT_END_DATE := Idx.HDR_End_Date;
            G_CONTRACT_ID       := Idx.Contract_Id;

           IF  trunc(Ld_CovLvl_Eff_End_Date) = trunc(Idx.HDR_End_Date) THEN
               Ld_CovLvl_Eff_End_Date := Get_Final_End_Date(Idx.Contract_Id,Ld_CovLvl_Eff_End_Date);
           END IF;

          END IF;
-- grace period changes ends
        END IF;
--following procedure modified for grace period changes

        Get_Service_Line_Details
          (P_SrvLine_Id       => Idx.Service_Line_Id
          ,P_Organization_Id  => Idx.Inv_Organization_Id
          ,X_Name             => Lv_Srv_Name
          ,X_Description      => Lv_Srv_Description
          ,X_Start_Date       => Ld_Srv_Start_Date
          ,X_End_Date         => Ld_Srv_End_Date
          ,X_Date_Terminated  => Ld_Srv_Date_Terminated
          ,X_Eff_End_Date     => Ld_Srv_Eff_End_Date
          ,X_Result           => Lx_Result
          ,X_Return_Status    => Lx_Return_Status);

        IF Lx_Result <> G_TRUE THEN
          RAISE L_EXCEP_UNEXPECTED_ERR;
        END IF;
--following procedure modified for grace period changes

        Get_Coverage_Line_Details
          (P_SrvLine_Id       => Idx.Service_Line_Id
          ,P_Organization_Id  => Idx.Inv_Organization_Id
          ,X_Cov_Id           => Lx_Cov_Id
          ,X_Name             => Lv_Cov_Name
          ,X_Description      => Lv_Cov_Description
          ,X_Start_Date       => Ld_Cov_Start_Date
          ,X_End_Date         => Ld_Cov_End_Date
          ,X_Date_Terminated  => Ld_Cov_Date_Terminated
          ,X_Eff_End_Date     => Ld_Cov_Eff_End_Date
          ,X_Result           => Lx_Result
          ,X_Return_Status    => Lx_Return_Status);

        IF Lx_Result <> G_TRUE THEN
          RAISE L_EXCEP_UNEXPECTED_ERR;
        END IF;

        IF (Ld_Request_Date BETWEEN Ld_Srv_Start_Date AND Ld_Srv_Eff_End_Date)
           AND
           (Ld_Request_Date BETWEEN Idx.Start_Date AND Ld_CovLvl_Eff_End_Date)
           AND
           (Ld_Request_Date BETWEEN Ld_Cov_Start_Date AND Ld_Cov_Eff_End_Date)  THEN

          Lv_Effective_Falg := 'T';
        ELSE
          Lv_Effective_Falg := 'F';
        END IF;

        Lv_Entile_Flag := OKC_ASSENT_PUB.LINE_OPERATION_ALLOWED(Idx.Service_Line_Id, 'ENTITLE');

        IF (Lv_Validate_Flag = 'T' AND Lv_Effective_Falg = 'T' AND Lv_Entile_Flag = 'T') OR (Lv_Validate_Flag <> 'T') THEN

          Get_Prof_Service_Name_And_Desc
            (P_Profile_Value    => Lv_Prof_Value
            ,P_Db_Srv_Name      => Lv_Srv_Name
            ,P_Db_Srv_Desc      => Lv_Srv_Description
            ,X_Prof_Srv_Name    => Lv_Prof_Srv_Name
            ,X_Prof_Srv_Desc    => Lv_Prof_Srv_Desc
            ,X_Result           => Lx_Result
            ,X_Return_Status   	=> Lx_Return_Status);

          IF Lx_Result <> G_TRUE THEN
            RAISE L_EXCEP_UNEXPECTED_ERR;
          END IF;

          Li_OutTab_Idx := Li_OutTab_Idx + 1;

          Lx_Contracts_01(Li_OutTab_Idx).Contract_Id                 := Idx.Contract_Id;
          Lx_Contracts_01(Li_OutTab_Idx).Contract_Number             := Idx.Contract_Number;
          Lx_Contracts_01(Li_OutTab_Idx).Contract_Number_Modifier    := Idx.Contract_Number_Modifier;
          Lx_Contracts_01(Li_OutTab_Idx).Service_Line_Id             := Idx.Service_Line_Id;
          Lx_Contracts_01(Li_OutTab_Idx).Service_Name                := Lv_Prof_Srv_Name;           --Lv_Srv_Name;
          Lx_Contracts_01(Li_OutTab_Idx).Service_Description         := Lv_Prof_Srv_Desc;           --Lv_Srv_Description;
          Lx_Contracts_01(Li_OutTab_Idx).Coverage_Term_Line_Id       := Lx_Cov_Id;
          Lx_Contracts_01(Li_OutTab_Idx).Coverage_Term_Name          := Lv_Cov_Name;
          Lx_Contracts_01(Li_OutTab_Idx).Coverage_Term_Description   := Lv_Cov_Description;
          Lx_Contracts_01(Li_OutTab_Idx).Coverage_Level_Line_Id      := Idx.Coverage_Level_Line_Id;
          Lx_Contracts_01(Li_OutTab_Idx).Coverage_Level              := Idx.Coverage_Level;
          Lx_Contracts_01(Li_OutTab_Idx).Coverage_Level_Code         := Idx.Coverage_Level_Code;
          Lx_Contracts_01(Li_OutTab_Idx).Coverage_Level_Start_Date   := Idx.Start_Date;
          Lx_Contracts_01(Li_OutTab_Idx).Coverage_Level_End_Date     := Idx.End_Date;
          Lx_Contracts_01(Li_OutTab_Idx).Coverage_Level_Id           := Idx.Coverage_Level_Id;
          Lx_Contracts_01(Li_OutTab_Idx).Warranty_Flag               := Idx.Warranty_Flag;
          Lx_Contracts_01(Li_OutTab_Idx).Eligible_For_Entitlement    := Lv_Entile_Flag;

          Get_Coverage_Type_Attribs
              (P_CVL_Id                => Lx_Cov_Id --Lx_CovLine_Id
              ,P_Set_ExcepionStack     => G_FALSE
              ,X_Cov_Type_Code         => Lx_Cov_Type_Code
              ,X_Cov_Type_Meaning      => Lx_Cov_Type_Meaning
              ,X_Cov_Type_Description  => Lx_Cov_Type_Description
              ,X_Cov_Type_Imp_Level    => Lx_Cov_Type_Imp_Level
              ,X_Result                => Lx_Result
              ,X_Return_Status         => Lx_Return_Status);

            IF Lx_Return_Status = G_RET_STS_UNEXP_ERROR THEN
              RAISE L_EXCEP_UNEXPECTED_ERR;
            END IF;

            Lx_Contracts_01(Li_OutTab_Idx).Coverage_Type_Code      :=  Lx_Cov_Type_Code;
            Lx_Contracts_01(Li_OutTab_Idx).Coverage_Type_Meaning   :=  Lx_Cov_Type_Meaning;
            Lx_Contracts_01(Li_OutTab_Idx).coverage_Type_Imp_Level :=  Lx_Cov_Type_Imp_Level;

        END IF;

      END LOOP;

      Li_TableIdx := Lx_Contracts.NEXT(Li_TableIdx);

    END LOOP;

    IF NVL(P_Chr_Id_Flag,'N') = 'Y'  THEN    --Bug# 4719510 (JVARGHES)

      X_Contracts_01     := Lx_Contracts_01;

    ELSE                                     --Bug# 4719510 (JVARGHES)

      Sort_Asc_GetContracts_01
        (P_Input_Tab          => Lx_Contracts_01
        ,X_Output_Tab         => Lx_Contracts_01_Out
        ,X_Result             => Lx_Result
        ,X_Return_Status      => Lx_Return_Status);

      IF Lx_Result <> G_TRUE THEN
        RAISE L_EXCEP_UNEXPECTED_ERR;
      END IF;

      X_Contracts_01     := Lx_Contracts_01_Out;

    END IF;                                 --Bug# 4719510 (JVARGHES)

    X_Result             := G_TRUE;         -- Bug #5092665 hmnair           /*Bug:6767455*/
    X_Return_Status      := Lx_Return_Status;

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
	,P_Token2_Value   => 'Get_Contracts_01_Format');

      X_Result          := G_FALSE;
      X_Return_Status   := G_RET_STS_UNEXP_ERROR;

  END Get_Contracts_01_Format;

-----------------------------------------------------------------------------------------------------------------------*

  PROCEDURE Get_Contracts_01
    (P_API_Version		IN  NUMBER
    ,P_Init_Msg_List		IN  VARCHAR2
    ,P_Inp_Rec			IN  Inp_Cont_Rec
    ,X_Return_Status 		OUT NOCOPY VARCHAR2
    ,X_Msg_Count		OUT NOCOPY NUMBER
    ,X_Msg_Data			OUT NOCOPY VARCHAR2
    ,X_Ent_Contracts		OUT NOCOPY Ent_Cont_Tbl)
  IS

    Lx_Inp_Rec			CONSTANT Inp_Cont_Rec := P_Inp_Rec;

    Lx_Ent_Contracts            Ent_Cont_Tbl;

    Lx_Contracts                GT_Contract_Ref;

    Ln_Organization_Id          NUMBER;
    Ln_Org_Id                   NUMBER;

    Lv_Chr_Id_Flag              VARCHAR2(10);   --Bug# 4719510 (JVARGHES)

    L_EXCEP_UNEXPECTED_ERR      EXCEPTION;

    Lx_Result                 Gx_Boolean;
    Lx_Return_Status          Gx_Ret_Sts;

  BEGIN

    Lx_Result                 := G_TRUE;
    Lx_Return_Status          := G_RET_STS_SUCCESS;


 -- Bug# 4735542.
 -- Ln_Organization_Id       := SYS_CONTEXT('OKC_CONTEXT','ORGANIZATION_ID');

 -- Modified for 12.0 MOAC project (JVARGHES)
 -- Ln_Org_Id                := SYS_CONTEXT('OKC_CONTEXT','ORG_ID');
 --

    G_GRACE_PROFILE_SET      := fnd_profile.value('OKS_ENABLE_GRACE_PERIOD');

    Lv_Chr_Id_Flag           := 'N';  --Bug# 4719510 (JVARGHES)

    IF Lx_Inp_Rec.Coverage_Level_Line_Id IS NOT NULL THEN

      Get_CovLvlLine_Contracts
        (P_CovLvlLine_Id          => Lx_Inp_Rec.Coverage_Level_Line_Id
        ,X_Contracts              => Lx_Contracts
        ,X_Result                 => Lx_Result
        ,X_Return_Status   	  => Lx_Return_Status);

      IF Lx_Result <> G_TRUE THEN
        RAISE L_EXCEP_UNEXPECTED_ERR;
      END IF;

    ELSIF Lx_Inp_Rec.Contract_Number IS NOT NULL THEN

      Lv_Chr_Id_Flag             := 'Y';  --Bug# 4719510 (JVARGHES)

      Get_Contracts_Id
        (P_Contract_Num           => Lx_Inp_Rec.Contract_Number
        ,P_Contract_Num_Modifier  => Lx_Inp_Rec.Contract_Number_Modifier --NULL
        ,X_Contracts              => Lx_Contracts
        ,X_Result                 => Lx_Result
        ,X_Return_Status   	  => Lx_Return_Status);

      IF Lx_Result <> G_TRUE THEN
        RAISE L_EXCEP_UNEXPECTED_ERR;
      END IF;

    ELSIF Lx_Inp_Rec.Product_Id IS NOT NULL THEN

      Get_CovProd_Contracts
        (P_CovProd_Obj_Id         => Lx_Inp_Rec.Product_Id
        ,P_Organization_Id        => Ln_Organization_Id
        ,P_Org_Id                 => Ln_Org_Id
        ,X_CovProd_Contracts      => Lx_Contracts
        ,X_Result                 => Lx_Result
        ,X_Return_Status   	  => Lx_Return_Status);

      IF Lx_Result <> G_TRUE THEN
        RAISE L_EXCEP_UNEXPECTED_ERR;
      END IF;

    ELSIF Lx_Inp_Rec.Item_Id IS NOT NULL THEN

      Get_CovItem_Contracts
        (P_CovItem_Obj_Id         => Lx_Inp_Rec.Item_Id
        ,P_Organization_Id        => Ln_Organization_Id
        ,P_Party_Id               => Lx_Inp_Rec.Party_Id
        ,X_CovItem_Contracts      => Lx_Contracts
        ,X_Result                 => Lx_Result
        ,X_Return_Status   	  => Lx_Return_Status);

      IF Lx_Result <> G_TRUE THEN
        RAISE L_EXCEP_UNEXPECTED_ERR;
      END IF;

    ELSIF Lx_Inp_Rec.System_Id IS NOT NULL THEN

      Get_CovSys_Contracts
        (P_CovSys_Obj_Id          => Lx_Inp_Rec.System_Id
        ,P_Org_Id                 => Ln_Org_Id
        ,X_CovSys_Contracts       => Lx_Contracts
        ,X_Result                 => Lx_Result
        ,X_Return_Status   	  => Lx_Return_Status);

      IF Lx_Result <> G_TRUE THEN
        RAISE L_EXCEP_UNEXPECTED_ERR;
      END IF;

    ELSIF Lx_Inp_Rec.Cust_Acct_Id IS NOT NULL THEN

      Get_CovCust_Contracts
        (P_CovCust_Obj_Id         => Lx_Inp_Rec.Cust_Acct_Id
        ,X_CovCust_Contracts      => Lx_Contracts
        ,X_Result                 => Lx_Result
        ,X_Return_Status   	  => Lx_Return_Status);

      IF Lx_Result <> G_TRUE THEN
        RAISE L_EXCEP_UNEXPECTED_ERR;
      END IF;

    ELSIF Lx_Inp_Rec.Site_Id IS NOT NULL THEN

      Get_CovSite_Contracts
        (P_CovSite_Obj_Id         => Lx_Inp_Rec.Site_Id
        ,P_Org_Id                 => Ln_Org_Id
        ,X_CovSite_Contracts      => Lx_Contracts
        ,X_Result                 => Lx_Result
        ,X_Return_Status   	  => Lx_Return_Status);

      IF Lx_Result <> G_TRUE THEN
        RAISE L_EXCEP_UNEXPECTED_ERR;
      END IF;

    ELSIF Lx_Inp_Rec.Party_Id IS NOT NULL THEN

      Get_CovParty_Contracts
        (P_CovParty_Obj_Id        => Lx_Inp_Rec.Party_Id
        ,X_CovParty_Contracts     => Lx_Contracts
        ,X_Result                 => Lx_Result
        ,X_Return_Status   	  => Lx_Return_Status);

      IF Lx_Result <> G_TRUE THEN
        RAISE L_EXCEP_UNEXPECTED_ERR;
      END IF;

    END IF;

    Get_Contracts_01_Format
      (P_Contracts           => Lx_Contracts
      ,P_Request_Date        => Lx_Inp_Rec.Request_Date
      ,P_Validate_Flag       => Lx_Inp_Rec.Validate_Flag
      ,P_Chr_Id_Flag         => Lv_Chr_Id_Flag                 --Bug# 4719510 (JVARGHES)
      ,X_Contracts_01        => Lx_Ent_Contracts
      ,X_Result              => Lx_Result
      ,X_Return_Status       => Lx_Return_Status);

    IF Lx_Result <> G_TRUE THEN
      RAISE L_EXCEP_UNEXPECTED_ERR;
    END IF;

    X_Ent_Contracts       := Lx_Ent_Contracts;
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
	,P_Token2_Value   => 'get_contracts_01');

      --X_Result        := G_FALSE;
      X_Return_Status   := G_RET_STS_UNEXP_ERROR;

  END get_contracts_01;

-----------------------------------------------------------------------------------------------------------------------*

  PROCEDURE Get_Contracts
    (P_API_Version		IN  NUMBER
    ,P_Init_Msg_List		IN  VARCHAR2
    ,P_Inp_Rec			IN  Inp_Cont_Rec
    ,X_Return_Status 		OUT NOCOPY VARCHAR2
    ,X_Msg_Count		      OUT NOCOPY NUMBER
    ,X_Msg_Data			OUT NOCOPY VARCHAR2
    ,X_Ent_Contracts		OUT NOCOPY Ent_Cont_Tbl)
  IS

    Lx_Inp_Rec                  Inp_Cont_Rec;

  BEGIN

    Lx_Inp_Rec        := P_Inp_Rec;

    -- Bug# 4735542.
    -- okc_context.set_okc_org_context;

    IF Lx_Inp_Rec.Request_Date IS NULL THEN
      Lx_Inp_Rec.Request_Date := SYSDATE;
    END IF;

    Get_Contracts_01
      (P_API_Version		=> P_API_Version
      ,P_Init_Msg_List		=> P_Init_Msg_List
      ,P_Inp_Rec		=> Lx_Inp_Rec
      ,X_Return_Status 		=> X_Return_Status
      ,X_Msg_Count		=> X_Msg_Count
      ,X_Msg_Data		=> X_Msg_Data
      ,X_Ent_Contracts		=> X_Ent_Contracts);

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
	,P_Token2_Value   => 'Get_Contracts-Ent_Cont_Tbl');

      --X_Result           := G_FALSE;
      X_Return_Status    := G_RET_STS_UNEXP_ERROR;

  END Get_Contracts;

-----------------------------------------------------------------------------------------------------------------------*

  PROCEDURE Sort_Asc_GetContracts_02
    (P_Input_Tab          IN  Get_ConTop_Tbl
    ,P_Sort_Key           IN  VARCHAR2
    ,X_Output_Tab         out nocopy Get_ConTop_Tbl
    ,X_Result             out nocopy Gx_Boolean
    ,X_Return_Status   	  out nocopy Gx_Ret_Sts)
  IS

    Lv_Sort_Key           CONSTANT VARCHAR2(10) := P_Sort_Key;

    Lx_Sort_Tab           Get_ConTop_Tbl;

    Li_TableIdx_Out       BINARY_INTEGER;
    Li_TableIdx_In        BINARY_INTEGER;

    Lx_Temp_ContItem      Get_ConTop_Rec;

    Lv_Composit_Val1      DATE;
    Lv_Composit_Val1_Num  NUMBER;

    Lv_Composit_Val2      DATE;
    Lv_Composit_Val2_Num  NUMBER;

    Lx_Result                 Gx_Boolean;
    Lx_Return_Status          Gx_Ret_Sts;

  BEGIN

    Lx_Result                 := G_TRUE;
    Lx_Return_Status          := G_RET_STS_SUCCESS;

    Lx_Sort_Tab               := P_Input_Tab;

    Li_TableIdx_Out  := Lx_Sort_Tab.FIRST;

    WHILE Li_TableIdx_Out IS NOT NULL LOOP

      Li_TableIdx_In  := Li_TableIdx_Out;

      WHILE Li_TableIdx_In IS NOT NULL LOOP

        IF Lv_Sort_Key IN (G_RESOLUTION_TIME,G_REACTION_TIME) THEN

          IF Lv_Sort_Key = G_REACTION_TIME THEN
            Lv_Composit_Val1  := Lx_Sort_Tab(Li_TableIdx_Out).Exp_Reaction_Time;
          ELSE
            Lv_Composit_Val1  := Lx_Sort_Tab(Li_TableIdx_Out).Exp_Resolution_Time;
          END IF;

          IF Lv_Composit_Val1 IS NOT NULL THEN
            Lv_Composit_Val1_Num  := TO_NUMBER(TO_CHAR(Lv_Composit_Val1,'YYYYMMDDHH24MISS'));
          ELSE
            -- Lv_Composit_Val1_Num  := NULL; --G_MISS_NUM;   -- Bug# 4896181
               Lv_Composit_Val1_Num  := 99999999999999;       -- Bug# 4896181
          END IF;

          IF Lv_Sort_Key = G_REACTION_TIME THEN
            Lv_Composit_Val2  := Lx_Sort_Tab(Li_TableIdx_In).Exp_Reaction_Time;
          ELSE
            Lv_Composit_Val2  := Lx_Sort_Tab(Li_TableIdx_In).Exp_Resolution_Time;
          END IF;

          IF Lv_Composit_Val2 IS NOT NULL THEN
            Lv_Composit_Val2_Num  := TO_NUMBER(TO_CHAR(Lv_Composit_Val2,'YYYYMMDDHH24MISS'));
          ELSE
           -- Lv_Composit_Val2_Num  := NULL; --G_MISS_NUM;  -- Bug# 4896181
           Lv_Composit_Val2_Num  := 99999999999999;         -- Bug# 4896181
          END IF;

        ELSIF Lv_Sort_Key = G_COVERAGE_TYPE_IMP_LEVEL THEN

          -- Bug# 4896181
          -- Lv_Composit_Val1_Num  := NVL(Lx_Sort_Tab(Li_TableIdx_Out).Coverage_Type_Imp_Level,NULL --G_MISS_NUM);
          -- Lv_Composit_Val2_Num  := NVL(Lx_Sort_Tab(Li_TableIdx_In).Coverage_Type_Imp_Level,NULL --G_MISS_NUM) ;

             Lv_Composit_Val1_Num  := NVL(Lx_Sort_Tab(Li_TableIdx_Out).Coverage_Type_Imp_Level,99999999999999);
             Lv_Composit_Val2_Num  := NVL(Lx_Sort_Tab(Li_TableIdx_In).Coverage_Type_Imp_Level,99999999999999);


        END IF;

        IF Lv_Composit_Val1_Num > Lv_Composit_Val2_Num THEN

          Lx_Temp_ContItem              := Lx_Sort_Tab(Li_TableIdx_Out);
          Lx_Sort_Tab(Li_TableIdx_Out)  := Lx_Sort_Tab(Li_TableIdx_In);
          Lx_Sort_Tab(Li_TableIdx_In)   := Lx_Temp_ContItem;

        END IF;

        Li_TableIdx_In  := Lx_Sort_Tab.NEXT(Li_TableIdx_In);

      END LOOP;

      Li_TableIdx_Out := Lx_Sort_Tab.NEXT(Li_TableIdx_Out);

    END LOOP;

    X_Output_Tab          := Lx_Sort_Tab;
    X_Result              := Lx_Result;
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
	,P_Token2_Value   => 'Sort_Asc_GetContracts_02');

      X_Result           := G_FALSE;
      X_Return_Status    := G_RET_STS_UNEXP_ERROR;

  END Sort_Asc_GetContracts_02;

-----------------------------------------------------------------------------------------------------------------------*
    /*vgujarat - modified for access hour ER 9675504*/
  PROCEDURE Get_Contracts_02_Format
    (P_Contracts            IN  GT_Contract_Ref
    ,P_BusiProc_Id	    IN  Gx_BusProcess_Id
    ,P_Severity_Id	    IN  Gx_Severity_Id
    ,P_Request_TZone_Id	    IN  Gx_TimeZoneId
    ,P_Dates_In_Input_TZ    IN VARCHAR2    -- Added for 12.0 ENT-TZ project (JVARGHES)
    ,P_Incident_Date        IN  DATE       -- Added for 12.0 ENT-TZ project (JVARGHES)
    ,P_Request_Date         IN  DATE
    ,P_Calc_RespTime_YN     IN  VARCHAR2
    ,P_Validate_Eff         IN  VARCHAR2
    ,P_Validate_Flag        IN  VARCHAR2
    ,P_SrvLine_Flag         IN  VARCHAR2
    ,P_Sort_Key             IN  VARCHAR2
    ,X_Contracts_02         out nocopy Get_ConTop_Tbl
    ,X_Result               out nocopy Gx_Boolean
    ,X_Return_Status   	    out nocopy Gx_Ret_Sts
    ,P_cust_id                  IN NUMBER DEFAULT NULL
    ,P_cust_site_id             IN NUMBER DEFAULT NULL
    ,P_cust_loc_id              IN NUMBER DEFAULT NULL)
  IS

-- cursor for Cx_SrvLine_Id  is not null and Cx_CovLvlLine_Id is null

    CURSOR Lx_Csr_Contracts1(Cx_Chr_Id IN Gx_OKS_Id, Cx_SrvLine_Id IN Gx_OKS_Id
                           ,Cx_CovLvlLine_Id IN Gx_OKS_Id, Cx_BP_Id IN Gx_BusProcess_Id,Cv_Cont_Pty_Id IN VARCHAR2) IS
      SELECT HD.Id Contract_Id
	    ,HD.Contract_Number
            ,HD.Contract_Number_Modifier
            ,HD.Sts_Code
            ,HD.Authoring_Org_Id
            ,HD.Inv_Organization_Id
            ,HD.End_Date HDR_End_Date --grace period changes
	    ,SV.Id Service_Line_Id
            ,SV.Start_Date SV_Start_Date
	    ,Get_End_Date_Time(SV.End_Date) SV_End_Date
            ,Get_End_Date_Time(SV.Date_Terminated) SV_Date_Terminated
            ,CL.Sts_Code CL_Sts_Code
	    ,CL.Id CovLvl_Line_Id
            ,CL.Start_Date CL_Start_Date
	    ,Get_End_Date_Time(CL.End_Date) CL_End_Date
            ,Get_End_Date_Time(CL.Date_Terminated) CL_Date_Terminated
       --   ,DECODE(SV.Lse_Id,14,'Y','N') Warranty_Flag
            ,DECODE(SV.Lse_Id, 14, 'Y', 15, 'Y', 16, 'Y', 17, 'Y', 18, 'Y', 'N') Warranty_Flag
        FROM OKC_K_HEADERS_ALL_B HD  -- OKC_K_HEADERS_B HDR  -- Modified for 12.0 MOAC project (JVARGHES)
            ,Okc_K_Lines_B SV
            ,Okc_K_Lines_B CL
       WHERE HD.Id = Cx_Chr_Id
         AND HD.Scs_Code IN ('SERVICE','WARRANTY')
         AND HD.Id > -1
         AND HD.Template_YN <> 'Y'
         AND SV.Dnz_Chr_Id = HD.Id
         AND SV.Cle_Id IS NULL
         AND SV.Chr_Id = HD.Id
         AND SV.Lse_ID IN (1,14,19)
         AND SV.Id = Cx_SrvLine_Id --NVL(Cx_SrvLine_Id,SV.Id)
         AND CL.Cle_Id = SV.Id
         AND CL.Lse_ID IN (7,8,9,10,11,35,18,25)
         AND (Cx_BP_Id IS NULL
              OR
              EXISTS (SELECT '*'            -- Modified for 12.0 Coverage Rearch project (JVARGHES)
                       FROM Okc_K_Items ITM
                           ,Okc_K_Lines_B BPL
                           ,Oks_K_Lines_B KSL
                      WHERE KSL.Cle_Id = SV.Id
                        AND BPL.Cle_Id = KSL.Coverage_ID
                        AND ITM.Cle_Id = BPL.Id
                        AND ITM.OBJECT1_ID1||''  = TO_CHAR(Cx_BP_Id)
                        AND ITM.Object1_Id2 = '#'
                        AND ITM.JTOT_OBJECT1_CODE||'' = 'OKX_BUSIPROC'
                        ));
      --
      -- Modified for 12.0 Coverage Rearch project (JVARGHES)
      --
      --        EXISTS (SELECT '*'
      --                 FROM Okc_K_Items ITM
      --                     ,Okc_K_Lines_B BPL
      --                     ,Okc_K_Lines_B CV
      --                WHERE CV.Cle_Id  = SV.Id
      --                  AND CV.Lse_Id IN (2,15,20)
      --                  AND BPL.Cle_Id = CV.Id
      --                  AND ITM.Cle_Id = BPL.Id
      --                 -- AND ITM.Object1_Id1 = TO_CHAR(Cx_BP_Id)
      --                  AND ITM.OBJECT1_ID1||''  = TO_CHAR(Cx_BP_Id)
      --                  AND ITM.Object1_Id2 = '#'
      --                 -- AND ITM.Jtot_Object1_Code = 'OKX_BUSIPROC'
      --                  AND ITM.JTOT_OBJECT1_CODE||'' = 'OKX_BUSIPROC'
      --                  ));
      --
      --

-- cursor for Cx_SrvLine_Id  is  null and Cx_CovLvlLine_Id is not null

    CURSOR Lx_Csr_Contracts2(Cx_Chr_Id IN Gx_OKS_Id, Cx_SrvLine_Id IN Gx_OKS_Id
                           ,Cx_CovLvlLine_Id IN Gx_OKS_Id, Cx_BP_Id IN Gx_BusProcess_Id,Cv_Cont_Pty_Id IN VARCHAR2) IS
      SELECT HD.Id Contract_Id
	    ,HD.Contract_Number
            ,HD.Contract_Number_Modifier
            ,HD.Sts_Code
            ,HD.Authoring_Org_Id
            ,HD.Inv_Organization_Id
            ,HD.End_Date HDR_End_Date --grace period changes
	    ,SV.Id Service_Line_Id
            ,SV.Start_Date SV_Start_Date
	    ,Get_End_Date_Time(SV.End_Date) SV_End_Date
            ,Get_End_Date_Time(SV.Date_Terminated) SV_Date_Terminated
            ,CL.Sts_Code CL_Sts_Code
	    ,CL.Id CovLvl_Line_Id
            ,CL.Start_Date CL_Start_Date
	    ,Get_End_Date_Time(CL.End_Date) CL_End_Date
            ,Get_End_Date_Time(CL.Date_Terminated) CL_Date_Terminated
       --   ,DECODE(SV.Lse_Id,14,'Y','N') Warranty_Flag
            ,DECODE(SV.Lse_Id, 14, 'Y', 15, 'Y', 16, 'Y', 17, 'Y', 18, 'Y', 'N') Warranty_Flag
        FROM OKC_K_HEADERS_ALL_B HD  -- OKC_K_HEADERS_B HDR  -- Modified for 12.0 MOAC project (JVARGHES)
            ,Okc_K_Lines_B SV
            ,Okc_K_Lines_B CL
       WHERE HD.Id = Cx_Chr_Id
         AND HD.Scs_Code IN ('SERVICE','WARRANTY')
         AND HD.Id > -1
         AND HD.Template_YN <> 'Y'
         AND SV.Dnz_Chr_Id = HD.Id
         AND SV.Cle_Id IS NULL
         AND SV.Chr_Id = HD.Id
         AND SV.Lse_ID IN (1,14,19)
         AND CL.Cle_Id = SV.Id
         AND CL.Lse_ID IN (7,8,9,10,11,35,18,25)
         AND CL.Id = Cx_CovLvlLine_Id
         AND (Cx_BP_Id IS NULL
              OR
              EXISTS (SELECT '*'            -- Modified for 12.0 Coverage Rearch project (JVARGHES)
                       FROM Okc_K_Items ITM
                           ,Okc_K_Lines_B BPL
                           ,Oks_K_Lines_B KSL
                      WHERE KSL.Cle_Id = SV.Id
                        AND BPL.Cle_Id = KSL.Coverage_ID
                        AND ITM.Cle_Id = BPL.Id
                        AND ITM.OBJECT1_ID1||''  = TO_CHAR(Cx_BP_Id)
                        AND ITM.Object1_Id2 = '#'
                        AND ITM.JTOT_OBJECT1_CODE||'' = 'OKX_BUSIPROC'
                        ));
    --
    -- Modified for 12.0 Coverage Rearch project (JVARGHES)
    --
    --         EXISTS (SELECT '*'
    --                   FROM Okc_K_Items ITM
    --                       ,Okc_K_Lines_B BPL
    --                       ,Okc_K_Lines_B CV
    --                  WHERE CV.Cle_Id  = SV.Id
    --                    AND CV.Lse_Id IN (2,15,20)
    --                    AND BPL.Cle_Id = CV.Id
    --                    AND ITM.Cle_Id = BPL.Id
    --                   -- AND ITM.Object1_Id1 = TO_CHAR(Cx_BP_Id)
    --                    AND ITM.OBJECT1_ID1||''  = TO_CHAR(Cx_BP_Id)
    --                    AND ITM.Object1_Id2 = '#'
    --                   -- AND ITM.Jtot_Object1_Code = 'OKX_BUSIPROC'
    --                    AND ITM.JTOT_OBJECT1_CODE||'' = 'OKX_BUSIPROC'
    --                    ));
    --
    --

-- cursor for Cx_SrvLine_Id  is  not null and Cx_CovLvlLine_Id is not null

    CURSOR Lx_Csr_Contracts3(Cx_Chr_Id IN Gx_OKS_Id, Cx_SrvLine_Id IN Gx_OKS_Id
                           ,Cx_CovLvlLine_Id IN Gx_OKS_Id, Cx_BP_Id IN Gx_BusProcess_Id,Cv_Cont_Pty_Id IN VARCHAR2) IS
      SELECT HD.Id Contract_Id
	    ,HD.Contract_Number
            ,HD.Contract_Number_Modifier
            ,HD.Sts_Code
            ,HD.Authoring_Org_Id
            ,HD.Inv_Organization_Id
            ,HD.End_Date HDR_End_Date --grace period changes
	    ,SV.Id Service_Line_Id
            ,SV.Start_Date SV_Start_Date
	    ,Get_End_Date_Time(SV.End_Date) SV_End_Date
            ,Get_End_Date_Time(SV.Date_Terminated) SV_Date_Terminated
            ,CL.Sts_Code CL_Sts_Code
	    ,CL.Id CovLvl_Line_Id
            ,CL.Start_Date CL_Start_Date
	    ,Get_End_Date_Time(CL.End_Date) CL_End_Date
            ,Get_End_Date_Time(CL.Date_Terminated) CL_Date_Terminated
       --   ,DECODE(SV.Lse_Id,14,'Y','N') Warranty_Flag
            ,DECODE(SV.Lse_Id, 14, 'Y', 15, 'Y', 16, 'Y', 17, 'Y', 18, 'Y', 'N') Warranty_Flag
        FROM OKC_K_HEADERS_ALL_B HD -- OKC_K_HEADERS_B HDR  -- Modified for 12.0 MOAC project (JVARGHES)
            ,Okc_K_Lines_B SV
            ,Okc_K_Lines_B CL
       WHERE HD.Id = Cx_Chr_Id
         AND HD.Scs_Code IN ('SERVICE','WARRANTY')
         AND HD.Id > -1
         AND HD.Template_YN <> 'Y'
         AND SV.Dnz_Chr_Id = HD.Id
         AND SV.Cle_Id IS NULL
         AND SV.Chr_Id = HD.Id
         AND SV.Lse_ID IN (1,14,19)
         AND SV.Id = Cx_SrvLine_Id
         AND CL.Cle_Id = SV.Id
         AND CL.Lse_ID IN (7,8,9,10,11,35,18,25)
         AND CL.Id = Cx_CovLvlLine_Id
         AND (Cx_BP_Id IS NULL
              OR
              EXISTS (SELECT '*'            -- Modified for 12.0 Coverage Rearch project (JVARGHES)
                       FROM Okc_K_Items ITM
                           ,Okc_K_Lines_B BPL
                           ,Oks_K_Lines_B KSL
                      WHERE KSL.Cle_Id = SV.Id
                        AND BPL.Cle_Id = KSL.Coverage_ID
                        AND ITM.Cle_Id = BPL.Id
                        AND ITM.OBJECT1_ID1||''  = TO_CHAR(Cx_BP_Id)
                        AND ITM.Object1_Id2 = '#'
                        AND ITM.JTOT_OBJECT1_CODE||'' = 'OKX_BUSIPROC'
                        ));
      --
      -- Modified for 12.0 Coverage Rearch project (JVARGHES)
      --
      --      EXISTS (SELECT '*'
      --                FROM Okc_K_Items ITM
      --                     ,Okc_K_Lines_B BPL
      --                     ,Okc_K_Lines_B CV
      --                WHERE CV.Cle_Id  = SV.Id
      --                  AND CV.Lse_Id IN (2,15,20)
      --                  AND BPL.Cle_Id = CV.Id
      --                  AND ITM.Cle_Id = BPL.Id
      --                 -- AND ITM.Object1_Id1 = TO_CHAR(Cx_BP_Id)
      --                  AND ITM.OBJECT1_ID1||''  = TO_CHAR(Cx_BP_Id)
      --                  AND ITM.Object1_Id2 = '#'
      --                 -- AND ITM.Jtot_Object1_Code = 'OKX_BUSIPROC'
      --                  AND ITM.JTOT_OBJECT1_CODE||'' = 'OKX_BUSIPROC'
      --                  ));
      --

-- cursor for Cx_SrvLine_Id  is  null and Cx_CovLvlLine_Id is null

    CURSOR Lx_Csr_Contracts4(Cx_Chr_Id IN Gx_OKS_Id, Cx_SrvLine_Id IN Gx_OKS_Id
                           ,Cx_CovLvlLine_Id IN Gx_OKS_Id, Cx_BP_Id IN Gx_BusProcess_Id,Cv_Cont_Pty_Id IN VARCHAR2) IS
      SELECT HD.Id Contract_Id
	    ,HD.Contract_Number
            ,HD.Contract_Number_Modifier
            ,HD.Sts_Code
            ,HD.Authoring_Org_Id
            ,HD.Inv_Organization_Id
            ,HD.End_Date HDR_End_Date --grace period changes
	    ,SV.Id Service_Line_Id
            ,SV.Start_Date SV_Start_Date
	    ,Get_End_Date_Time(SV.End_Date) SV_End_Date
            ,Get_End_Date_Time(SV.Date_Terminated) SV_Date_Terminated
            ,CL.Sts_Code CL_Sts_Code
	    ,CL.Id CovLvl_Line_Id
            ,CL.Start_Date CL_Start_Date
	    ,Get_End_Date_Time(CL.End_Date) CL_End_Date
            ,Get_End_Date_Time(CL.Date_Terminated) CL_Date_Terminated
       --   ,DECODE(SV.Lse_Id,14,'Y','N') Warranty_Flag
            ,DECODE(SV.Lse_Id, 14, 'Y', 15, 'Y', 16, 'Y', 17, 'Y', 18, 'Y', 'N') Warranty_Flag
        FROM OKC_K_HEADERS_ALL_B HD  -- OKC_K_HEADERS_B HDR  -- Modified for 12.0 MOAC project (JVARGHES)
            ,Okc_K_Lines_B SV
            ,Okc_K_Lines_B CL
       WHERE HD.Id = Cx_Chr_Id
         AND HD.Scs_Code IN ('SERVICE','WARRANTY')
         AND HD.Id > -1
         AND HD.Template_YN <> 'Y'
         AND SV.Dnz_Chr_Id = HD.Id
         AND SV.Cle_Id IS NULL
         AND SV.Chr_Id = HD.Id
         AND SV.Lse_ID IN (1,14,19)
         AND CL.Cle_Id = SV.Id
         AND CL.Lse_ID IN (7,8,9,10,11,35,18,25)
         AND (Cx_BP_Id IS NULL
              OR
              EXISTS (SELECT '*'            -- Modified for 12.0 Coverage Rearch project (JVARGHES)
                       FROM Okc_K_Items ITM
                           ,Okc_K_Lines_B BPL
                           ,Oks_K_Lines_B KSL
                      WHERE KSL.Cle_Id = SV.Id
                        AND BPL.Cle_Id = KSL.Coverage_ID
                        AND ITM.Cle_Id = BPL.Id
                        AND ITM.OBJECT1_ID1||''  = TO_CHAR(Cx_BP_Id)
                        AND ITM.Object1_Id2 = '#'
                        AND ITM.JTOT_OBJECT1_CODE||'' = 'OKX_BUSIPROC'
                        ));
      --
      -- Modified for 12.0 Coverage Rearch project (JVARGHES)
      --
      --
      --        EXISTS (SELECT '*'
      --                 FROM Okc_K_Items ITM
      --                     ,Okc_K_Lines_B BPL
      --                     ,Okc_K_Lines_B CV
      --                WHERE CV.Cle_Id  = SV.Id
      --                  AND CV.Lse_Id IN (2,15,20)
      --                  AND BPL.Cle_Id = CV.Id
      --                  AND ITM.Cle_Id = BPL.Id
      --                 -- AND ITM.Object1_Id1 = TO_CHAR(Cx_BP_Id)
      --                  AND ITM.OBJECT1_ID1||''  = TO_CHAR(Cx_BP_Id)
      --                  AND ITM.Object1_Id2 = '#'
      --                 -- AND ITM.Jtot_Object1_Code = 'OKX_BUSIPROC'
      --                  AND ITM.JTOT_OBJECT1_CODE||'' = 'OKX_BUSIPROC'
      --                  ));
      --

    Lx_Contracts             GT_Contract_Ref;
    Ld_Request_Date          DATE;
    Lv_Validate_Flag         VARCHAR2(1);
    Lv_SrvLine_Flag          CONSTANT VARCHAR2(1) := P_SrvLine_Flag;
    Lv_Sort_Key              CONSTANT VARCHAR2(10):= P_Sort_Key;

    Lx_BusiProc_Id	     CONSTANT Gx_BusProcess_Id := P_BusiProc_Id;
    Lx_Severity_Id	     CONSTANT Gx_Severity_Id := P_Severity_Id;
    Lx_Request_TZone_Id	     CONSTANT Gx_TimeZoneId := P_Request_TZone_Id;
    Lv_Calc_RespTime_YN      CONSTANT VARCHAR2(1) := P_Calc_RespTime_YN;
    Lv_Validate_Eff          CONSTANT VARCHAR2(1) := P_Validate_Eff;
    Lv_Cont_Pty_Id           VARCHAR2(100);

    /*vgujarat - modified for access hour ER 9675504*/
    Lx_cust_id               NUMBER := P_cust_id;      --access hour
    Lx_cust_site_id          NUMBER := P_cust_site_id; --access hour
    Lx_cust_loc_id           NUMBER := P_cust_loc_id;  --access hour

    Lx_Contracts_02          Get_ConTop_Tbl;
    Lx_Contracts_02_Out      Get_ConTop_Tbl;
    Lx_Contracts_02_Val      Get_ConTop_Tbl;

    Lx_Idx_Rec               Idx_Rec;

    Lx_Result                Gx_Boolean;
    Lx_Return_Status         Gx_Ret_Sts;
    Lx_Result1               Gx_Boolean;
    Lx_Return_Status1        Gx_Ret_Sts;
    Lx_Result2               Gx_Boolean;
    Lx_Return_Status2        Gx_Ret_Sts;
    Lx_Result3               Gx_Boolean;
    Lx_Return_Status3        Gx_Ret_Sts;

    Lx_Cov_Type_Code         Oks_Cov_Types_B.Code%TYPE;
    Lx_Cov_Type_Meaning      Oks_Cov_Types_TL.Meaning%TYPE;
    Lx_Cov_Type_Description  Oks_Cov_Types_TL.Description%TYPE;
    Lx_Cov_Type_Imp_Level    Oks_Cov_Types_B.Importance_Level%TYPE;

    Li_TableIdx              BINARY_INTEGER;
    Li_OutTab_Idx            BINARY_INTEGER;
    Lv_Entile_Flag           VARCHAR2(1);
    Lv_Effective_Falg        VARCHAR2(1);

    Lx_SrvLine_Id            Gx_OKS_Id;
    Lx_CovLvlLine_Id         Gx_OKS_Id;

    Ld_SRV_Eff_End_Date      DATE;
    Ld_COV_Eff_End_Date      DATE;
    Ld_CVL_Eff_End_Date      DATE;

    Lv_Srv_Name              Okx_System_Items_V.Name%TYPE;            --VARCHAR2(150) ;
    Lv_Srv_Description       Okx_System_Items_V.Description%TYPE;     --VARCHAR2(1995);
    Lv_Prof_Srv_Name         VARCHAR2(300) ;
    Lv_Prof_Srv_Desc         VARCHAR2(300);

    Lv_Cov_Name              Okc_K_Lines_V.Name%TYPE;                 --VARCHAR2(150) ;
    Lv_Cov_Description       Okc_K_Lines_V.Item_Description%TYPE;     --VARCHAR2(1995);

    Lx_React_Durn	     Gx_ReactDurn;
    Lx_React_UOM 	     Gx_ReactUOM;
    Lv_React_Day             VARCHAR2(20);
    Ld_React_By_DateTime     DATE;
    Ld_React_Start_DateTime  DATE;

    Lx_Resln_Durn	     Gx_ReactDurn;
    Lx_Resln_UOM 	     Gx_ReactUOM;
    Lv_Resln_Day             VARCHAR2(20);
    Ld_Resln_By_DateTime     DATE;
    Ld_Resln_Start_DateTime  DATE;

    Ln_Msg_Count	     NUMBER;
    Lv_Msg_Data		     VARCHAR2(2000);

    Lv_RCN_RSN_Flag          VARCHAR2(10);
    Lb_RSN_CTXT_Exists       BOOLEAN;

    Lx_CovLine_Id            Gx_OKS_Id;
    Ld_Cov_StDate            DATE;
    Ld_Cov_EdDate            DATE;
    Ld_Cov_TnDate            DATE;
    Lv_Cov_Check             VARCHAR2(1);

    Lv_Prof_Name             CONSTANT VARCHAR2(300) := 'OKS_ITEM_DISPLAY_PREFERENCE';
    Lv_Prof_Value            VARCHAR2(300);

    -- Added for 12.0 ENT-TZ project (JVARGHES)

    Lv_Dates_In_Input_TZ    VARCHAR2(1);
    Ld_INCIDENT_DATE        DATE;

    --

    L_EXCEP_UNEXPECTED_ERR   EXCEPTION;

  BEGIN

    Lx_Contracts             := P_Contracts;
    Ld_Request_Date          := nvl(P_Request_Date,sysdate);
    Lv_Validate_Flag         := P_Validate_Flag;

    -- Added for 12.0 ENT-TZ project (JVARGHES)

    Lv_Dates_In_Input_TZ     := P_Dates_In_Input_TZ;
    Ld_Incident_Date         := P_Incident_Date;

    --

    Lx_Result                := G_TRUE;
    Lx_Return_Status         := G_RET_STS_SUCCESS;
    Lx_Result1               := G_TRUE;
    Lx_Return_Status1        := G_RET_STS_SUCCESS;
    Lx_Result2               := G_TRUE;
    Lx_Return_Status2        := G_RET_STS_SUCCESS;
    Lx_Result3               := G_TRUE;
    Lx_Return_Status3        := G_RET_STS_SUCCESS;

    Li_OutTab_Idx            := 0;


    Li_TableIdx  := Lx_Contracts.FIRST;

    WHILE Li_TableIdx IS NOT NULL LOOP

      IF Lv_SrvLine_Flag = 'T' THEN

        Lx_SrvLine_Id     := Lx_Contracts(Li_TableIdx).Rx_Cle_Id;
        Lx_CovLvlLine_Id  := NULL;

      ELSE

        Lx_SrvLine_Id     := NULL;
        Lx_CovLvlLine_Id  := Lx_Contracts(Li_TableIdx).Rx_Cle_Id;

      END IF;

      Lv_Cont_Pty_Id  := TO_CHAR(Lx_Contracts(Li_TableIdx).Rx_Pty_Id);

   IF Lx_SrvLine_Id  is  not null and Lx_CovLvlLine_Id is null then
      FOR Idx IN Lx_Csr_Contracts1(Lx_Contracts(Li_TableIdx).Rx_Chr_Id,Lx_SrvLine_Id,Lx_CovLvlLine_Id,Lx_BusiProc_Id,Lv_Cont_Pty_Id) LOOP

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

    /*vgujarat - modified for access hour ER 9675504*/
        Get_Cont02Format_Validation
            (P_Contracts            => Lx_Idx_Rec
            ,P_BusiProc_Id	      => Lx_BusiProc_Id
            ,P_Severity_Id	      => Lx_Severity_Id
            ,P_Request_TZone_Id	=> Lx_Request_TZone_Id
    	      ,P_Dates_In_Input_TZ    => Lv_Dates_In_Input_TZ      -- Added for 12.0 ENT-TZ project (JVARGHES)
	      ,P_Incident_Date        => Ld_Incident_Date          -- Added for 12.0 ENT-TZ project (JVARGHES)
            ,P_Request_Date         => Ld_Request_Date
            ,P_Request_Date_Start   => NULL
            ,P_Request_Date_End     => NULL
            ,P_Calc_RespTime_YN     => Lv_Calc_RespTime_YN
            ,P_Validate_Eff         => Lv_Validate_Eff
            ,P_Validate_Flag        => Lv_Validate_Flag
            ,P_SrvLine_Flag         => Lv_SrvLine_Flag
            ,P_Sort_Key             => Lv_Sort_Key
            ,X_Contracts_02         => Lx_Contracts_02_Val
            ,X_Result               => Lx_Result
            ,X_Return_Status   	    => Lx_Return_Status
            ,P_cust_id              => Lx_cust_id         --access hour
            ,P_cust_site_id         => Lx_cust_site_id    --access hour
            ,P_cust_loc_id          => Lx_cust_loc_id);   --access hour

        IF Lx_Contracts_02_Val.COUNT > 0 THEN

         Li_OutTab_Idx := Li_OutTab_Idx + 1;

          Lx_Contracts_02(Li_OutTab_Idx).Contract_Id                 := Lx_Contracts_02_Val(1).Contract_Id;
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
          Lx_Contracts_02(Li_OutTab_Idx).Exp_Reaction_Time           := Lx_Contracts_02_Val(1).Exp_Reaction_Time;
          Lx_Contracts_02(Li_OutTab_Idx).Exp_Resolution_Time         := Lx_Contracts_02_Val(1).Exp_Resolution_Time;
          Lx_Contracts_02(Li_OutTab_Idx).Status_Code                 := Lx_Contracts_02_Val(1).Status_Code;
          Lx_Contracts_02(Li_OutTab_Idx).Status_Text                 := Lx_Contracts_02_Val(1).Status_Text;
          Lx_Contracts_02(Li_OutTab_Idx).Coverage_Type_Code          := Lx_Contracts_02_Val(1).Coverage_Type_Code;
          Lx_Contracts_02(Li_OutTab_Idx).Coverage_Type_Meaning       := Lx_Contracts_02_Val(1).Coverage_Type_Meaning;
          Lx_Contracts_02(Li_OutTab_Idx).coverage_Type_Imp_Level     := Lx_Contracts_02_Val(1).coverage_Type_Imp_Level;

          Lx_Contracts_02(Li_OutTab_Idx).service_po_number           := Lx_Contracts_02_Val(1).service_po_number;
          Lx_Contracts_02(Li_OutTab_Idx).service_po_required_flag    := Lx_Contracts_02_Val(1).service_po_required_flag;

          --Added for IB OA Pages (JVARGHES)
          Lx_Contracts_02(Li_OutTab_Idx).CovLvl_Line_Id              := Lx_Contracts_02_Val(1).CovLvl_Line_Id;
          --

          Lx_Contracts_02_Val.DELETE;

       END IF;

        IF Lx_Return_Status = G_RET_STS_UNEXP_ERROR THEN
            RAISE L_EXCEP_UNEXPECTED_ERR;
        END IF;

      END LOOP;

      Li_TableIdx := Lx_Contracts.NEXT(Li_TableIdx);


   ELSIF Lx_SrvLine_Id  is   null and Lx_CovLvlLine_Id is not null then


      FOR Idx IN Lx_Csr_Contracts2(Lx_Contracts(Li_TableIdx).Rx_Chr_Id,Lx_SrvLine_Id,Lx_CovLvlLine_Id,Lx_BusiProc_Id,Lv_Cont_Pty_Id) LOOP

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

    /*vgujarat - modified for access hour ER 9675504*/
        Get_Cont02Format_Validation
            (P_Contracts            => Lx_Idx_Rec
            ,P_BusiProc_Id	        => Lx_BusiProc_Id
            ,P_Severity_Id	        => Lx_Severity_Id
            ,P_Request_TZone_Id	    => Lx_Request_TZone_Id
    	      ,P_Dates_In_Input_TZ    => Lv_Dates_In_Input_TZ      -- Added for 12.0 ENT-TZ project (JVARGHES)
	      ,P_Incident_Date        => Ld_Incident_Date          -- Added for 12.0 ENT-TZ project (JVARGHES)
            ,P_Request_Date         => Ld_Request_Date
            ,P_Request_Date_Start   => NULL
            ,P_Request_Date_End     => NULL
            ,P_Calc_RespTime_YN     => Lv_Calc_RespTime_YN
            ,P_Validate_Eff         => Lv_Validate_Eff
            ,P_Validate_Flag        => Lv_Validate_Flag
            ,P_SrvLine_Flag         => Lv_SrvLine_Flag
            ,P_Sort_Key             => Lv_Sort_Key
            ,X_Contracts_02         => Lx_Contracts_02_Val
            ,X_Result               => Lx_Result
            ,X_Return_Status   	    => Lx_Return_Status
            ,P_cust_id              => Lx_cust_id         --access hour
            ,P_cust_site_id         => Lx_cust_site_id    --access hour
            ,P_cust_loc_id          => Lx_cust_loc_id);   --access hour

        IF Lx_Contracts_02_Val.COUNT > 0 THEN

         Li_OutTab_Idx := Li_OutTab_Idx + 1;

          Lx_Contracts_02(Li_OutTab_Idx).Contract_Id                 := Lx_Contracts_02_Val(1).Contract_Id;
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
          Lx_Contracts_02(Li_OutTab_Idx).Exp_Reaction_Time           := Lx_Contracts_02_Val(1).Exp_Reaction_Time;
          Lx_Contracts_02(Li_OutTab_Idx).Exp_Resolution_Time         := Lx_Contracts_02_Val(1).Exp_Resolution_Time;
          Lx_Contracts_02(Li_OutTab_Idx).Status_Code                 := Lx_Contracts_02_Val(1).Status_Code;
          Lx_Contracts_02(Li_OutTab_Idx).Status_Text                 := Lx_Contracts_02_Val(1).Status_Text;
          Lx_Contracts_02(Li_OutTab_Idx).Coverage_Type_Code          := Lx_Contracts_02_Val(1).Coverage_Type_Code;
          Lx_Contracts_02(Li_OutTab_Idx).Coverage_Type_Meaning       := Lx_Contracts_02_Val(1).Coverage_Type_Meaning;
          Lx_Contracts_02(Li_OutTab_Idx).coverage_Type_Imp_Level     := Lx_Contracts_02_Val(1).coverage_Type_Imp_Level;

          Lx_Contracts_02(Li_OutTab_Idx).service_po_number           := Lx_Contracts_02_Val(1).service_po_number;
          Lx_Contracts_02(Li_OutTab_Idx).service_po_required_flag    := Lx_Contracts_02_Val(1).service_po_required_flag;

          --Added for IB OA Pages (JVARGHES)
          Lx_Contracts_02(Li_OutTab_Idx).CovLvl_Line_Id              := Lx_Contracts_02_Val(1).CovLvl_Line_Id;
          --

          Lx_Contracts_02_Val.DELETE;

       END IF;

        IF Lx_Return_Status = G_RET_STS_UNEXP_ERROR THEN
            RAISE L_EXCEP_UNEXPECTED_ERR;
        END IF;

      END LOOP;

      Li_TableIdx := Lx_Contracts.NEXT(Li_TableIdx);


   ELSIF Lx_SrvLine_Id  is   not null and Lx_CovLvlLine_Id is not null then


      FOR Idx IN Lx_Csr_Contracts3(Lx_Contracts(Li_TableIdx).Rx_Chr_Id,Lx_SrvLine_Id,Lx_CovLvlLine_Id,Lx_BusiProc_Id,Lv_Cont_Pty_Id) LOOP

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

    /*vgujarat - modified for access hour ER 9675504*/
        Get_Cont02Format_Validation
            (P_Contracts            => Lx_Idx_Rec
            ,P_BusiProc_Id	        => Lx_BusiProc_Id
            ,P_Severity_Id	        => Lx_Severity_Id
            ,P_Request_TZone_Id	    => Lx_Request_TZone_Id
    	      ,P_Dates_In_Input_TZ    => Lv_Dates_In_Input_TZ      -- Added for 12.0 ENT-TZ project (JVARGHES)
	      ,P_Incident_Date        => Ld_Incident_Date          -- Added for 12.0 ENT-TZ project (JVARGHES)
            ,P_Request_Date         => Ld_Request_Date
            ,P_Request_Date_Start   => NULL
            ,P_Request_Date_End     => NULL
            ,P_Calc_RespTime_YN     => Lv_Calc_RespTime_YN
            ,P_Validate_Eff         => Lv_Validate_Eff
            ,P_Validate_Flag        => Lv_Validate_Flag
            ,P_SrvLine_Flag         => Lv_SrvLine_Flag
            ,P_Sort_Key             => Lv_Sort_Key
            ,X_Contracts_02         => Lx_Contracts_02_Val
            ,X_Result               => Lx_Result
            ,X_Return_Status   	    => Lx_Return_Status
            ,P_cust_id              => Lx_cust_id         --access hour
            ,P_cust_site_id         => Lx_cust_site_id    --access hour
            ,P_cust_loc_id          => Lx_cust_loc_id);   --access hour
        IF Lx_Contracts_02_Val.COUNT > 0 THEN

         Li_OutTab_Idx := Li_OutTab_Idx + 1;

          Lx_Contracts_02(Li_OutTab_Idx).Contract_Id                 := Lx_Contracts_02_Val(1).Contract_Id;
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
          Lx_Contracts_02(Li_OutTab_Idx).Exp_Reaction_Time           := Lx_Contracts_02_Val(1).Exp_Reaction_Time;
          Lx_Contracts_02(Li_OutTab_Idx).Exp_Resolution_Time         := Lx_Contracts_02_Val(1).Exp_Resolution_Time;
          Lx_Contracts_02(Li_OutTab_Idx).Status_Code                 := Lx_Contracts_02_Val(1).Status_Code;
          Lx_Contracts_02(Li_OutTab_Idx).Status_Text                 := Lx_Contracts_02_Val(1).Status_Text;
          Lx_Contracts_02(Li_OutTab_Idx).Coverage_Type_Code          := Lx_Contracts_02_Val(1).Coverage_Type_Code;
          Lx_Contracts_02(Li_OutTab_Idx).Coverage_Type_Meaning       := Lx_Contracts_02_Val(1).Coverage_Type_Meaning;
          Lx_Contracts_02(Li_OutTab_Idx).coverage_Type_Imp_Level     := Lx_Contracts_02_Val(1).coverage_Type_Imp_Level;

          Lx_Contracts_02(Li_OutTab_Idx).service_po_number           := Lx_Contracts_02_Val(1).service_po_number;
          Lx_Contracts_02(Li_OutTab_Idx).service_po_required_flag    := Lx_Contracts_02_Val(1).service_po_required_flag;

          --Added for IB OA Pages (JVARGHES)
          Lx_Contracts_02(Li_OutTab_Idx).CovLvl_Line_Id              := Lx_Contracts_02_Val(1).CovLvl_Line_Id;
          --

          Lx_Contracts_02_Val.DELETE;

       END IF;

        IF Lx_Return_Status = G_RET_STS_UNEXP_ERROR THEN
            RAISE L_EXCEP_UNEXPECTED_ERR;
        END IF;

      END LOOP;

      Li_TableIdx := Lx_Contracts.NEXT(Li_TableIdx);


   ELSIF Lx_SrvLine_Id  is  null and Lx_CovLvlLine_Id is null then


      FOR Idx IN Lx_Csr_Contracts4(Lx_Contracts(Li_TableIdx).Rx_Chr_Id,Lx_SrvLine_Id,Lx_CovLvlLine_Id,Lx_BusiProc_Id,Lv_Cont_Pty_Id) LOOP

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

    /*vgujarat - modified for access hour ER 9675504*/
        Get_Cont02Format_Validation
            (P_Contracts            => Lx_Idx_Rec
            ,P_BusiProc_Id	        => Lx_BusiProc_Id
            ,P_Severity_Id	        => Lx_Severity_Id
            ,P_Request_TZone_Id	    => Lx_Request_TZone_Id
    	      ,P_Dates_In_Input_TZ    => Lv_Dates_In_Input_TZ      -- Added for 12.0 ENT-TZ project (JVARGHES)
	      ,P_Incident_Date        => Ld_Incident_Date          -- Added for 12.0 ENT-TZ project (JVARGHES)
            ,P_Request_Date         => Ld_Request_Date
            ,P_Request_Date_Start   => NULL
            ,P_Request_Date_End     => NULL
            ,P_Calc_RespTime_YN     => Lv_Calc_RespTime_YN
            ,P_Validate_Eff         => Lv_Validate_Eff
            ,P_Validate_Flag        => Lv_Validate_Flag
            ,P_SrvLine_Flag         => Lv_SrvLine_Flag
            ,P_Sort_Key             => Lv_Sort_Key
            ,X_Contracts_02         => Lx_Contracts_02_Val
            ,X_Result               => Lx_Result
            ,X_Return_Status   	    => Lx_Return_Status
            ,P_cust_id              => Lx_cust_id         --access hour
            ,P_cust_site_id         => Lx_cust_site_id    --access hour
            ,P_cust_loc_id          => Lx_cust_loc_id);   --access hour

        IF Lx_Contracts_02_Val.COUNT > 0 THEN

         Li_OutTab_Idx := Li_OutTab_Idx + 1;

          Lx_Contracts_02(Li_OutTab_Idx).Contract_Id                 := Lx_Contracts_02_Val(1).Contract_Id;
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
          Lx_Contracts_02(Li_OutTab_Idx).Exp_Reaction_Time           := Lx_Contracts_02_Val(1).Exp_Reaction_Time;
          Lx_Contracts_02(Li_OutTab_Idx).Exp_Resolution_Time         := Lx_Contracts_02_Val(1).Exp_Resolution_Time;
          Lx_Contracts_02(Li_OutTab_Idx).Status_Code                 := Lx_Contracts_02_Val(1).Status_Code;
          Lx_Contracts_02(Li_OutTab_Idx).Status_Text                 := Lx_Contracts_02_Val(1).Status_Text;
          Lx_Contracts_02(Li_OutTab_Idx).Coverage_Type_Code          := Lx_Contracts_02_Val(1).Coverage_Type_Code;
          Lx_Contracts_02(Li_OutTab_Idx).Coverage_Type_Meaning       := Lx_Contracts_02_Val(1).Coverage_Type_Meaning;
          Lx_Contracts_02(Li_OutTab_Idx).coverage_Type_Imp_Level     := Lx_Contracts_02_Val(1).coverage_Type_Imp_Level;

          Lx_Contracts_02(Li_OutTab_Idx).service_po_number           := Lx_Contracts_02_Val(1).service_po_number;
          Lx_Contracts_02(Li_OutTab_Idx).service_po_required_flag    := Lx_Contracts_02_Val(1).service_po_required_flag;

          --Added for IB OA Pages (JVARGHES)
          Lx_Contracts_02(Li_OutTab_Idx).CovLvl_Line_Id              := Lx_Contracts_02_Val(1).CovLvl_Line_Id;
          --

          Lx_Contracts_02_Val.DELETE;

       END IF;

        IF Lx_Return_Status = G_RET_STS_UNEXP_ERROR THEN
            RAISE L_EXCEP_UNEXPECTED_ERR;
        END IF;

      END LOOP;

      Li_TableIdx := Lx_Contracts.NEXT(Li_TableIdx);


   END IF;

END LOOP;


--    IF Lv_Sort_Key <> G_NO_SORT_KEY THEN
--    above IF commented and new one introduced , as sorting needs to be done when calculate response time flag
--    is 'Y' or sort key is sorting with importance level.
    IF (((Lv_Calc_RespTime_YN = 'N') AND (Lv_Sort_Key = 'COVTYP_IMP')) OR (Lv_Calc_RespTime_YN = 'Y')) THEN

      Sort_Asc_GetContracts_02
        (P_Input_Tab          => Lx_Contracts_02
        ,P_Sort_Key           => Lv_Sort_Key
        ,X_Output_Tab         => Lx_Contracts_02_Out
        ,X_Result             => Lx_Result
        ,X_Return_Status      => Lx_Return_Status);

      IF Lx_Result <> G_TRUE THEN
        RAISE L_EXCEP_UNEXPECTED_ERR;
      END IF;

    ELSE

      Lx_Contracts_02_Out := Lx_Contracts_02;

    END IF;


    X_Contracts_02        := Lx_Contracts_02_Out;
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
	,P_Token2_Value   => 'Get_Contracts_02_Format');

      X_Result          := G_FALSE;
      X_Return_Status   := G_RET_STS_UNEXP_ERROR;

  END Get_Contracts_02_Format;

-----------------------------------------------------------------------------------------------------------------------*

  PROCEDURE Append_Contract_PlSql_Table
    (P_Input_Tab          IN  GT_Contract_Ref
    ,P_Append_Tab         IN  GT_Contract_Ref
    ,X_Output_Tab         out nocopy GT_Contract_Ref
    ,X_Result             out nocopy Gx_Boolean
    ,X_Return_Status   	  out nocopy Gx_Ret_Sts)
  IS

    Lx_Input_Tab          GT_Contract_Ref;
    Lx_Output_Tab         GT_Contract_Ref;

    Li_In_TableIdx        BINARY_INTEGER;
    Li_Out_TableIdx       BINARY_INTEGER;

    Lx_Result             Gx_Boolean;
    Lx_Return_Status      Gx_Ret_Sts;

  BEGIN

    Lx_Input_Tab          := P_Input_Tab;
    Lx_Output_Tab         := P_Append_Tab;

    Lx_Result             := G_TRUE;
    Lx_Return_Status      := G_RET_STS_SUCCESS;

    Li_In_TableIdx       := Lx_Input_Tab.FIRST;
    Li_Out_TableIdx      := NVL(Lx_Output_Tab.LAST,0);

    WHILE Li_In_TableIdx IS NOT NULL LOOP

      Li_Out_TableIdx                := Li_Out_TableIdx + 1;
      Lx_Output_Tab(Li_Out_TableIdx) := Lx_Input_Tab(Li_In_TableIdx);
      Li_In_TableIdx                 := Lx_Input_Tab.NEXT(Li_In_TableIdx);

    END LOOP;

    X_Output_Tab          := Lx_Output_Tab;

    X_Result              := Lx_Result;
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
	,P_Token2_Value   => 'Append_Contract_PlSql_Table');

      X_Result         := G_FALSE;
      X_Return_Status  := G_RET_STS_UNEXP_ERROR;

  END Append_Contract_PlSql_Table;

-----------------------------------------------------------------------------------------------------------------------*
/*vgujarat - modified for access hour ER 9675504*/
  PROCEDURE Get_Contracts_02
    (P_API_Version		IN  NUMBER
    ,P_Init_Msg_List		IN  VARCHAR2
    ,P_Inp_Rec			IN  Inp_rec_getcont02
    ,X_Return_Status 		OUT NOCOPY VARCHAR2
    ,X_Msg_Count		OUT NOCOPY NUMBER
    ,X_Msg_Data			OUT NOCOPY VARCHAR2
    ,X_Ent_Contracts		OUT NOCOPY Get_ConTop_Tbl)
  IS

    CURSOR Lx_SrvLine(Cx_SrvLine_Id IN Gx_OKS_Id) IS
      SELECT Dnz_Chr_Id
        FROM Okc_K_lines_B
       WHERE Id = Cx_SrvLine_Id;

    Lx_Inp_Rec		 	  CONSTANT Inp_rec_getcont02 := P_Inp_Rec;

    Lx_Ent_Contracts            Get_ConTop_Tbl;
    Lx_Contracts                GT_Contract_Ref;
    Lx_Contracts_Temp           GT_Contract_Ref;
    Lx_Contracts_Temp1          GT_Contract_Ref;  --Bug# 4690940
    Lx_Contracts_Temp2          GT_Contract_Ref;  --Bug# 4690940

    Lx_Contracts_Out            GT_Contract_Ref;
    Lv_SrvLine_Flag             VARCHAR2(1);

    Ln_Organization_Id          NUMBER;
    Ln_Org_Id                   NUMBER;
    Ln_Chr_Id                   NUMBER;

    Li_TableIdx                 BINARY_INTEGER;

    L_EXCEP_UNEXPECTED_ERR      EXCEPTION;

    Lx_Result             Gx_Boolean;
    Lx_Return_Status      Gx_Ret_Sts;

  BEGIN

    Lx_Result             := G_TRUE;
    Lx_Return_Status      := G_RET_STS_SUCCESS;
    Lv_SrvLine_Flag       := 'F';

--  Bug# 4735542
--  Ln_Organization_Id          := SYS_CONTEXT('OKC_CONTEXT','ORGANIZATION_ID');

--  Modified for 12.0 MOAC project (JVARGHES)
--  Ln_Org_Id                   := SYS_CONTEXT('OKC_CONTEXT','ORG_ID');
--
    G_GRACE_PROFILE_SET         := fnd_profile.value('OKS_ENABLE_GRACE_PERIOD');

    IF Lx_Inp_Rec.Calc_RespTime_Flag = 'Y' THEN

      Validate_Required_NumValue
        (P_Num_Value              => Lx_Inp_Rec.Business_Process_Id
        ,P_Set_ExcepionStack      => G_TRUE
        ,P_ExcepionMsg            => 'Business Process'
        ,X_Result                 => Lx_Result
        ,X_Return_Status   	  => Lx_Return_Status);

      IF Lx_Result <> G_TRUE THEN
        RAISE L_EXCEP_UNEXPECTED_ERR;
      END IF;

      Validate_Required_NumValue
        (P_Num_Value              => Lx_Inp_Rec.Severity_Id
        ,P_Set_ExcepionStack      => G_TRUE
        ,P_ExcepionMsg            => 'Severity'
        ,X_Result                 => Lx_Result
        ,X_Return_Status   	  => Lx_Return_Status);

      IF Lx_Result <> G_TRUE THEN
        RAISE L_EXCEP_UNEXPECTED_ERR;
      END IF;

      Validate_Required_NumValue
        (P_Num_Value              => Lx_Inp_Rec.Time_Zone_Id
        ,P_Set_ExcepionStack      => G_TRUE
        ,P_ExcepionMsg            => 'Time Zone'
        ,X_Result                 => Lx_Result
        ,X_Return_Status   	  => Lx_Return_Status);

      IF Lx_Result <> G_TRUE THEN
        RAISE L_EXCEP_UNEXPECTED_ERR;
      END IF;

    END IF;

    IF Lx_Inp_Rec.Service_Line_Id IS NOT NULL THEN

      OPEN Lx_SrvLine(Lx_Inp_Rec.Service_Line_Id);
      FETCH Lx_SrvLine INTO Ln_Chr_Id;
      CLOSE Lx_SrvLine;

      Li_TableIdx                         := NVL(Lx_Contracts.LAST,0) + 1;
      Lx_Contracts(Li_TableIdx).Rx_Chr_Id := Ln_Chr_Id;
      Lx_Contracts(Li_TableIdx).Rx_Cle_Id := Lx_Inp_Rec.Service_Line_Id;

      Lv_SrvLine_Flag  := 'T';

    ELSIF Lx_Inp_Rec.Contract_Number IS NOT NULL THEN

      Get_Contracts_Id
        (P_Contract_Num           => Lx_Inp_Rec.Contract_Number
        ,P_Contract_Num_Modifier  => Lx_Inp_Rec.Contract_Number_Modifier
        ,X_Contracts              => Lx_Contracts
        ,X_Result                 => Lx_Result
        ,X_Return_Status   	  => Lx_Return_Status);

      IF Lx_Result <> G_TRUE THEN
        RAISE L_EXCEP_UNEXPECTED_ERR;
      END IF;

    ELSIF Lx_Inp_Rec.Product_Id IS NOT NULL THEN

      Get_CovProd_Contracts
        (P_CovProd_Obj_Id         => Lx_Inp_Rec.Product_Id
        ,P_Organization_Id        => Ln_Organization_Id
        ,P_Org_Id                 => Ln_Org_Id
        ,X_CovProd_Contracts      => Lx_Contracts
        ,X_Result                 => Lx_Result
        ,X_Return_Status   	  => Lx_Return_Status);

      IF Lx_Result <> G_TRUE THEN
        RAISE L_EXCEP_UNEXPECTED_ERR;
      END IF;

    ELSE

      IF Lx_Inp_Rec.Item_Id IS NOT NULL THEN

        Get_CovItem_Contracts
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

      IF Lx_Inp_Rec.System_Id IS NOT NULL THEN

        Get_CovSys_Contracts
          (P_CovSys_Obj_Id          => Lx_Inp_Rec.System_Id
          ,P_Org_Id                 => Ln_Org_Id
          ,X_CovSys_Contracts       => Lx_Contracts_Temp
          ,X_Result                 => Lx_Result
          ,X_Return_Status   	    => Lx_Return_Status);

        IF Lx_Result <> G_TRUE THEN
          RAISE L_EXCEP_UNEXPECTED_ERR;
        END IF;

   --
   --

   -- ELSIF Lx_Inp_Rec.Cust_Acct_Id IS NOT NULL THEN  --Modified for fix of bug# 4690940.
      ELSIF (Lx_Inp_Rec.Cust_Acct_Id IS NOT NULL)
         OR (Lx_Inp_Rec.Site_Id IS NOT NULL)  THEN

        set_account_party_id := 'T';

        IF Lx_Inp_Rec.Cust_Acct_Id IS NOT NULL THEN

          Get_CovCust_Contracts
            (P_CovCust_Obj_Id       => Lx_Inp_Rec.Cust_Acct_Id
            ,X_CovCust_Contracts    => Lx_Contracts_Temp1  --Modified for fix of bug# 4690940.
            ,X_Result               => Lx_Result
            ,X_Return_Status   	=> Lx_Return_Status);

          IF Lx_Result <> G_TRUE THEN
            RAISE L_EXCEP_UNEXPECTED_ERR;
          END IF;

        END IF;

   -- ELSIF Lx_Inp_Rec.Site_Id IS NOT NULL THEN

        IF Lx_Inp_Rec.Site_Id IS NOT NULL THEN

          Get_CovSite_Contracts
            (P_CovSite_Obj_Id         => Lx_Inp_Rec.Site_Id
            ,P_Org_Id                 => Ln_Org_Id
            ,X_CovSite_Contracts      => Lx_Contracts_Temp2  --Modified for fix of bug# 4690940.
            ,X_Result                 => Lx_Result
            ,X_Return_Status   	  => Lx_Return_Status);

          IF Lx_Result <> G_TRUE THEN
            RAISE L_EXCEP_UNEXPECTED_ERR;
          END IF;

        END IF;

        covd_account_party_id := NULL;  -- #4690940
	  set_account_party_id  := 'F';

	   -- Append account and site rows  #4690940
	   Append_Contract_PlSql_Table
	           (P_Input_Tab          => Lx_Contracts_Temp1
		      ,P_Append_Tab         => Lx_Contracts_Temp2
		      ,X_Output_Tab         => Lx_Contracts_Temp
		      ,X_Result             => Lx_Result
		      ,X_Return_Status      => Lx_Return_Status);


  --
  --
      ELSIF Lx_Inp_Rec.Party_Id IS NOT NULL THEN

        Get_CovParty_Contracts
          (P_CovParty_Obj_Id        => Lx_Inp_Rec.Party_Id
          ,X_CovParty_Contracts     => Lx_Contracts_Temp
          ,X_Result                 => Lx_Result
          ,X_Return_Status   	    => Lx_Return_Status);

        IF Lx_Result <> G_TRUE THEN
          RAISE L_EXCEP_UNEXPECTED_ERR;
        END IF;

      END IF;

    END IF;

     Append_Contract_PlSql_Table
        (P_Input_Tab          => Lx_Contracts_Temp
        ,P_Append_Tab         => Lx_Contracts
        ,X_Output_Tab         => Lx_Contracts_Out
        ,X_Result             => Lx_Result
        ,X_Return_Status      => Lx_Return_Status);

      IF Lx_Result <> G_TRUE THEN
        RAISE L_EXCEP_UNEXPECTED_ERR;
      END IF;
/*vgujarat - modified for access hour ER 9675504*/
    Get_Contracts_02_Format
      (P_Contracts          => Lx_Contracts_Out
      ,P_BusiProc_Id	    => Lx_Inp_Rec.Business_Process_Id
      ,P_Severity_Id	    => Lx_Inp_Rec.Severity_Id
      ,P_Request_TZone_Id   => Lx_Inp_Rec.Time_Zone_Id
      ,P_Dates_In_Input_TZ  => Lx_Inp_Rec.Dates_In_Input_TZ    -- Added for 12.0 ENT-TZ project (JVARGHES)
      ,P_Incident_Date      => Lx_Inp_Rec.Incident_Date        -- Added for 12.0 ENT-TZ project (JVARGHES)
      ,P_Request_Date       => Lx_Inp_Rec.Request_Date
      ,P_Calc_RespTime_YN   => Lx_Inp_Rec.Calc_RespTime_Flag
      ,P_Validate_Eff       => Lx_Inp_Rec.Validate_Eff_Flag
      ,P_Validate_Flag      => Lx_Inp_Rec.Validate_Flag
      ,P_SrvLine_Flag       => Lv_SrvLine_Flag
      ,P_Sort_Key           => Lx_Inp_Rec.Sort_Key
      ,X_Contracts_02       => Lx_Ent_Contracts
      ,X_Result             => Lx_Result
      ,X_Return_Status      => Lx_Return_Status
      ,P_cust_id            => Lx_Inp_Rec.cust_id
      ,P_cust_site_id       => Lx_Inp_Rec.cust_site_id
      ,P_cust_loc_id        => Lx_Inp_Rec.cust_loc_id);

    X_Ent_Contracts       := Lx_Ent_Contracts;
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
	,P_Token2_Value   => 'Get_Contracts_02');

      --X_Result        := G_FALSE;
      X_Return_Status   := G_RET_STS_UNEXP_ERROR;

  END Get_Contracts_02;

-----------------------------------------------------------------------------------------------------------------------*
/*vgujarat - modified for access hour ER 9675504*/
  PROCEDURE Get_Contracts
    (P_Api_Version		IN  NUMBER
    ,P_Init_Msg_List		IN  VARCHAR2
    ,P_Inp_Rec			IN  Get_ContIn_Rec
    ,X_Return_Status 		OUT NOCOPY VARCHAR2
    ,X_Msg_Count		      OUT NOCOPY NUMBER
    ,X_Msg_Data			OUT NOCOPY VARCHAR2
    ,X_Ent_Contracts		OUT NOCOPY Get_ConTop_Tbl)
  IS

    Lx_Inp_Rec                Get_ContIn_Rec;
    Lx_ContInp_Rec            Inp_rec_getCont02;

  BEGIN

    Lx_Inp_Rec                := P_Inp_Rec;

 --  Bug# 4735542
 --  okc_context.set_okc_org_context;

    Lx_ContInp_Rec.Contract_Number          :=  Lx_Inp_Rec.Contract_Number;
    Lx_ContInp_Rec.Contract_Number_Modifier :=  Lx_Inp_Rec.contract_number_modifier ;
    Lx_ContInp_Rec.Service_Line_Id          :=  Lx_Inp_Rec.Service_Line_Id;
    Lx_ContInp_Rec.Party_Id                 :=  Lx_Inp_Rec.Party_Id;
    Lx_ContInp_Rec.Site_Id                  :=  Lx_Inp_Rec.Site_Id;
    Lx_ContInp_Rec.Cust_Acct_Id             :=  Lx_Inp_Rec.Cust_Acct_Id;
    Lx_ContInp_Rec.System_Id                :=  Lx_Inp_Rec.System_Id;
    Lx_ContInp_Rec.Item_Id	              :=  Lx_Inp_Rec.Item_Id;
    Lx_ContInp_Rec.Product_Id	              :=  Lx_Inp_Rec.Product_Id;

    -- Added for 12.0 ENT-TZ project (JVARGHES)
    Lx_ContInp_Rec.INCIDENT_DATE            :=  P_Inp_Rec.INCIDENT_DATE;
    --

    Lx_ContInp_Rec.Request_Date             :=  Lx_Inp_Rec.Request_Date;
    Lx_ContInp_Rec.Business_Process_Id	  :=  Lx_Inp_Rec.Business_Process_Id;
    Lx_ContInp_Rec.Severity_Id	        :=  Lx_Inp_Rec.Severity_Id;
    Lx_ContInp_Rec.Time_Zone_Id             :=  Lx_Inp_Rec.Time_Zone_Id;

    -- Added for 12.0 ENT-TZ project (JVARGHES)
    Lx_ContInp_Rec. Dates_In_Input_TZ :=  P_Inp_Rec. Dates_In_Input_TZ;
    --

    Lx_ContInp_Rec.Calc_RespTime_Flag	  :=  Lx_Inp_Rec.Calc_RespTime_Flag;
    Lx_ContInp_Rec.Validate_Flag	        :=  Lx_Inp_Rec.Validate_Flag;
    Lx_ContInp_Rec.Validate_Eff_Flag        :=  'T';
    Lx_ContInp_Rec.Sort_Key                 :=  NVL(Lx_Inp_Rec.Sort_Key,G_RESOLUTION_TIME);

 /*vgujarat - modified for access hour ER 9675504*/
    Lx_ContInp_Rec.cust_id	  :=  Lx_Inp_Rec.cust_id;
    Lx_ContInp_Rec.cust_site_id	        :=  Lx_Inp_Rec.cust_site_id;
    Lx_ContInp_Rec.cust_loc_id             :=  Lx_Inp_Rec.cust_loc_id;

    IF Lx_ContInp_Rec.Request_Date IS NULL THEN
      Lx_ContInp_Rec.Request_Date := SYSDATE;
    END IF;

    Get_Contracts_02
      (P_API_Version		=> P_Api_Version
      ,P_Init_Msg_List		=> P_Init_Msg_List
      ,P_Inp_Rec		      => Lx_ContInp_Rec
      ,X_Return_Status 		=> X_Return_Status
      ,X_Msg_Count		=> X_Msg_Count
      ,X_Msg_Data		      => X_Msg_Data
      ,X_Ent_Contracts		=> X_Ent_Contracts);

  EXCEPTION

    WHEN OTHERS THEN

      OKC_API.SET_MESSAGE
        (P_App_Name	  => G_APP_NAME_OKC
	  ,P_Msg_Name	  => G_UNEXPECTED_ERROR
	  ,P_Token1	        => G_SQLCODE_TOKEN
	  ,P_Token1_Value	  => SQLCODE
	  ,P_Token2	        => G_SQLERRM_TOKEN
	  ,P_Token2_Value   => SQLERRM);

      OKC_API.SET_MESSAGE
        (P_App_Name	  => G_APP_NAME_OKC
  	  ,P_Msg_Name	  => G_DEBUG_TOKEN
	  ,P_Token1	        => G_PACKAGE_TOKEN
	  ,P_Token1_Value	  => G_PKG_NAME
	  ,P_Token2	        => G_PROGRAM_TOKEN
	  ,P_Token2_Value   => 'Get_Contracts-Get_ConTop_Tbl');

      --X_Result        := G_FALSE;
      X_Return_Status   := G_RET_STS_UNEXP_ERROR;

  END Get_Contracts;

-----------------------------------------------------------------------------------------------------------------------*

  PROCEDURE Get_Contracts
    (P_Api_Version		IN  NUMBER
    ,P_Init_Msg_List		IN  VARCHAR2
    ,P_Inp_Rec			IN  Input_Rec_IB
    ,X_Return_Status 		OUT NOCOPY VARCHAR2
    ,X_Msg_Count		OUT NOCOPY NUMBER
    ,X_Msg_Data			OUT NOCOPY VARCHAR2
    ,X_Ent_Contracts		OUT NOCOPY Output_Tbl_IB)
  IS

    Lx_Inp_Rec                  Input_Rec_IB;
    Lx_ContInp_Rec              Inp_rec_getCont02;
    Lx_Contracts		Get_ConTop_Tbl;
    Lx_Ent_Contracts		Output_Tbl_IB;

    Li_TableIdx1                BINARY_INTEGER;
    Li_TableIdx2                BINARY_INTEGER;

  BEGIN

    Lx_Inp_Rec                              := P_Inp_Rec;

 -- Bug# 4735542
 -- okc_context.set_okc_org_context;

    Lx_ContInp_Rec.Contract_Number          :=  Lx_Inp_Rec.Contract_Number;
    Lx_ContInp_Rec.Contract_Number_Modifier :=  Lx_Inp_Rec.Contract_Number_Modifier;
    Lx_ContInp_Rec.Service_Line_Id          :=  Lx_Inp_Rec.Service_Line_Id;
    Lx_ContInp_Rec.Party_Id                 :=  Lx_Inp_Rec.Party_Id;
    Lx_ContInp_Rec.Site_Id                  :=  Lx_Inp_Rec.Site_Id;
    Lx_ContInp_Rec.Cust_Acct_Id             :=  Lx_Inp_Rec.Cust_Acct_Id;
    Lx_ContInp_Rec.System_Id                :=  Lx_Inp_Rec.System_Id;
    Lx_ContInp_Rec.Item_Id	            :=  Lx_Inp_Rec.Item_Id;
    Lx_ContInp_Rec.Product_Id	            :=  Lx_Inp_Rec.Product_Id;
    Lx_ContInp_Rec.Request_Date             :=  SYSDATE;
    Lx_ContInp_Rec.Business_Process_Id	    :=  Lx_Inp_Rec.Business_Process_Id;
    Lx_ContInp_Rec.Severity_Id	            :=  Lx_Inp_Rec.Severity_Id;
    Lx_ContInp_Rec.Time_Zone_Id             :=  Lx_Inp_Rec.Time_Zone_Id;
    Lx_ContInp_Rec.Calc_RespTime_Flag	    :=  Lx_Inp_Rec.Calc_RespTime_Flag;
    Lx_ContInp_Rec.Validate_Flag	    :=  Lx_Inp_Rec.Validate_Flag;
    Lx_ContInp_Rec.Validate_Eff_Flag        :=  'F';
    Lx_ContInp_Rec.Sort_Key                 :=  G_NO_SORT_KEY;

    Get_Contracts_02
      (P_API_Version		=> P_Api_Version
      ,P_Init_Msg_List		=> P_Init_Msg_List
      ,P_Inp_Rec		=> Lx_ContInp_Rec
      ,X_Return_Status 		=> X_Return_Status
      ,X_Msg_Count		=> X_Msg_Count
      ,X_Msg_Data		=> X_Msg_Data
      ,X_Ent_Contracts		=> Lx_Contracts);

    Li_TableIdx1       :=  Lx_Contracts.FIRST;
    Li_TableIdx2       :=  0;

    WHILE Li_TableIdx1 IS NOT NULL LOOP

      Li_TableIdx2  :=     Li_TableIdx2 + 1;

      Lx_Ent_Contracts(Li_TableIdx2).Contract_Id                 := Lx_Contracts(Li_TableIdx1).Contract_Id;
      Lx_Ent_Contracts(Li_TableIdx2).Contract_Number             := Lx_Contracts(Li_TableIdx1).Contract_Number;
      Lx_Ent_Contracts(Li_TableIdx2).Contract_Number_Modifier    := Lx_Contracts(Li_TableIdx1).Contract_Number_Modifier;
      Lx_Ent_Contracts(Li_TableIdx2).Sts_code                    := Lx_Contracts(Li_TableIdx1).Sts_code;
      Lx_Ent_Contracts(Li_TableIdx2).Service_Line_Id             := Lx_Contracts(Li_TableIdx1).Service_Line_Id;
      Lx_Ent_Contracts(Li_TableIdx2).Service_Name                := Lx_Contracts(Li_TableIdx1).Service_Name;
      Lx_Ent_Contracts(Li_TableIdx2).Service_Description         := Lx_Contracts(Li_TableIdx1).Service_Description;
      Lx_Ent_Contracts(Li_TableIdx2).Service_Start_Date          := Lx_Contracts(Li_TableIdx1).Service_Start_Date;
      Lx_Ent_Contracts(Li_TableIdx2).Service_End_Date            := Lx_Contracts(Li_TableIdx1).Service_End_Date;
      Lx_Ent_Contracts(Li_TableIdx2).Coverage_Term_Line_Id       := Lx_Contracts(Li_TableIdx1).Coverage_Term_Line_Id;
      Lx_Ent_Contracts(Li_TableIdx2).Coverage_Term_Name          := Lx_Contracts(Li_TableIdx1).Coverage_Term_Name;

      Lx_Ent_Contracts(Li_TableIdx2).Coverage_Type_Code          := Lx_Contracts(Li_TableIdx1).Coverage_Type_Code;
      Lx_Ent_Contracts(Li_TableIdx2).Coverage_Type_Imp_level     := Lx_Contracts(Li_TableIdx1).Coverage_Type_Imp_level;

      Lx_Ent_Contracts(Li_TableIdx2).Coverage_Term_Description   := Lx_Contracts(Li_TableIdx1).Coverage_Term_Description;
      Lx_Ent_Contracts(Li_TableIdx2).Warranty_Flag               := Lx_Contracts(Li_TableIdx1).Warranty_Flag;
      Lx_Ent_Contracts(Li_TableIdx2).Eligible_For_Entitlement    := Lx_Contracts(Li_TableIdx1).Eligible_For_Entitlement;
      Lx_Ent_Contracts(Li_TableIdx2).Exp_Reaction_Time           := Lx_Contracts(Li_TableIdx1).Exp_Reaction_Time;
      Lx_Ent_Contracts(Li_TableIdx2).Exp_Resolution_Time         := Lx_Contracts(Li_TableIdx1).Exp_Resolution_Time;
      Lx_Ent_Contracts(Li_TableIdx2).Status_Code                 := Lx_Contracts(Li_TableIdx1).Status_Code;
      Lx_Ent_Contracts(Li_TableIdx2).Status_Text                 := Lx_Contracts(Li_TableIdx1).Status_Text;
      Lx_Ent_Contracts(Li_TableIdx2).date_terminated             := Lx_Contracts(Li_TableIdx1).date_terminated;

      -- Added for 12.0 ENT-TZ project (JVARGHES)
      Lx_Ent_Contracts(Li_TableIdx2).CovLvl_Line_Id              := Lx_Contracts(Li_TableIdx1).CovLvl_Line_Id;
      --

      Li_TableIdx1       :=  Lx_Contracts.NEXT(Li_TableIdx1);

    END LOOP;

    X_Ent_Contracts   :=  Lx_Ent_Contracts;

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
	,P_Token2_Value   => 'Get_Contracts-Output_Tbl_IB');

      --X_Result        := G_FALSE;
      X_Return_Status   := G_RET_STS_UNEXP_ERROR;

  END Get_Contracts;

-----------------------------------------------------------------------------------------------------------------------*

  PROCEDURE Sort_Asc_GetContracts_03
    (P_Input_Tab          IN  Output_Tbl_EntFrm
    ,X_Output_Tab         out nocopy Output_Tbl_EntFrm
    ,X_Result             out nocopy Gx_Boolean
    ,X_Return_Status   	  out nocopy Gx_Ret_Sts)
  IS

    Lx_Sort_Tab           Output_Tbl_EntFrm;
    Lx_Result             Gx_Boolean;
    Lx_Return_Status      Gx_Ret_Sts;

    Li_TableIdx_Out       BINARY_INTEGER;
    Li_TableIdx_In        BINARY_INTEGER;

    Lx_Temp_ContItem      output_rec_entfrm;

    Lv_Compare_Val1      VARCHAR2(120);
    Lv_Compare_Val2      VARCHAR2(120);


  BEGIN

    Lx_Sort_Tab           := P_Input_Tab;
    Lx_Result             := G_TRUE;
    Lx_Return_Status      := G_RET_STS_SUCCESS;

    Li_TableIdx_Out  := Lx_Sort_Tab.FIRST;

    WHILE Li_TableIdx_Out IS NOT NULL LOOP

      Li_TableIdx_In  := Li_TableIdx_Out;

      WHILE Li_TableIdx_In IS NOT NULL LOOP

        Lv_Compare_Val1  := Lx_Sort_Tab(Li_TableIdx_Out).Contract_Number;
        Lv_Compare_Val2  := Lx_Sort_Tab(Li_TableIdx_In).Contract_Number;

        IF Lv_Compare_Val1 > Lv_Compare_Val2 THEN

          Lx_Temp_ContItem              := Lx_Sort_Tab(Li_TableIdx_Out);
          Lx_Sort_Tab(Li_TableIdx_Out)  := Lx_Sort_Tab(Li_TableIdx_In);
          Lx_Sort_Tab(Li_TableIdx_In)   := Lx_Temp_ContItem;

        END IF;

        Li_TableIdx_In  := Lx_Sort_Tab.NEXT(Li_TableIdx_In);

      END LOOP;

      Li_TableIdx_Out := Lx_Sort_Tab.NEXT(Li_TableIdx_Out);

    END LOOP;

    X_Output_Tab          := Lx_Sort_Tab;
    X_Result              := Lx_Result;
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
	,P_Token2_Value   => 'Sort_Asc_GetContracts_03');

      X_Result           := G_FALSE;
      X_Return_Status    := G_RET_STS_UNEXP_ERROR;

  END Sort_Asc_GetContracts_03;

-----------------------------------------------------------------------------------------------------------------------*

  PROCEDURE Get_Contracts_03_Format
    (P_Contracts            IN  GT_Contract_Ref
    ,P_Con_Number           IN  VARCHAR2
    ,P_Con_Number_Modifier  IN  VARCHAR2
    ,P_Con_Customer_Id      IN  NUMBER
    ,P_Service_Item_Id      IN  NUMBER
    ,P_Organization_Id      IN  NUMBER
    ,P_Request_Date         IN  DATE
    ,P_Validate_Eff         IN  VARCHAR2
    ,X_Contracts_03         out nocopy Output_Tbl_EntFrm
    ,X_Result               out nocopy Gx_Boolean
    ,X_Return_Status   	    out nocopy Gx_Ret_Sts)
  IS

    CURSOR Lx_Csr_Contracts(Cx_Chr_Id IN Gx_OKS_Id, Cv_Con_Number IN VARCHAR2, Cv_Con_Number_Modifier IN VARCHAR2,
                            Cv_Con_Cusomer_Id IN VARCHAR2, Cv_Service_Item_Id IN VARCHAR2, Cn_Organization_Id IN NUMBER) IS
      SELECT HB.Id Contract_Id
            ,HB.Contract_Number Contract_Number
            ,HB.Contract_Number_Modifier Contract_Number_Modifier
            ,HT.Cognomen Contract_Known_As
            ,HT.Short_Description Contract_Short_Description
            ,HB.Sts_Code Contract_Status_Code
            ,HB.Start_Date Contract_Start_Date
            ,Get_End_Date_Time(HB.End_Date) Contract_End_Date
            ,Get_End_Date_Time(HB.Date_Terminated) Contract_Terminated_Date
        FROM Okc_K_Headers_TL HT
            ,OKC_K_HEADERS_ALL_B  HB  -- OKC_K_HEADERS_B HB  -- Modified for 12.0 MOAC project (JVARGHES)
       WHERE HB.Id = NVL(Cx_Chr_Id,HB.Id)
         AND HB.Contract_Number = NVL(Cv_Con_Number,HB.Contract_Number)
         AND (Cv_Con_Number_Modifier IS NULL OR HB.Contract_Number_Modifier = Cv_Con_Number_Modifier)
         AND (Cv_Con_Cusomer_Id IS NULL
             OR
             HB.Id IN ( SELECT PR.Chr_Id
                        FROM Okx_Parties_V PX
                            ,Okc_K_Party_Roles_B PR
                       WHERE PR.Object1_Id1 = NVL(Cv_Con_Cusomer_Id,PR.Object1_Id1)  --PR.Chr_Id = HB.Id
                         AND PR.Rle_Code = 'CUSTOMER'
                         AND PR.Jtot_Object1_Code = 'OKX_PARTY'
                         AND PX.Id1 = TO_NUMBER(PR.Object1_Id1)
                         AND PX.Id2 = PR.Object1_Id2 ))
         AND (Cv_Service_Item_Id IS NULL
             OR
             HB.Id IN ( SELECT SV.Chr_Id
                        FROM Okx_System_Items_V XI
                            ,Okc_K_Items IT
                            ,Okc_K_Lines_B SV
                       WHERE SV.Lse_ID IN (1,14,19)  --SV.Chr_Id = HB.Id
                         AND IT.Cle_Id = SV.Id
                         AND IT.Object1_Id1 = NVL(Cv_Service_Item_Id,IT.Object1_Id1)
                         AND IT.Jtot_Object1_Code IN ('OKX_SERVICE','OKX_WARRANTY')
                         AND XI.Id1 = TO_NUMBER(IT.Object1_Id1)
                         AND XI.Id2 = IT.Object1_Id2
                         AND XI.Service_Item_Flag = 'Y'
                      -- AND XI.Organization_Id = Cn_Organization_Id  --Bug# 4735542.
                         ))
         AND HB.Scs_Code IN ('SERVICE','WARRANTY')
         AND HB.Id  > -1
         AND HB.Template_YN <> 'Y'
         AND HB.Id  = HT.Id
         AND HT.Language = USERENV('LANG');

    Lx_Contracts             GT_Contract_Ref;

    Lv_Con_Number            CONSTANT VARCHAR2(120) := P_Con_Number;
    Lv_Con_Number_Modifier   CONSTANT VARCHAR2(120) := P_Con_Number_Modifier;
    Ln_Con_Customer_Id                NUMBER;
    Ln_Service_Item_Id       CONSTANT NUMBER := P_Service_Item_Id;
    Ln_Organization_Id       CONSTANT NUMBER := P_Organization_Id;
    Ld_Request_Date          CONSTANT DATE := P_Request_Date;
    Lv_Validate_Eff          VARCHAR2(1);
    Ln_Party_Id              NUMBER;

    Lx_Contracts_03          Output_Tbl_EntFrm;
    Lx_Contracts_03_Out      Output_Tbl_EntFrm;

    Ld_Con_Eff_End_Date      DATE;
    Lv_Effective_Falg        VARCHAR2(1);

    Lx_Chr_Id                Gx_OKS_Id;

    Lx_Result                Gx_Boolean;
    Lx_Return_Status         Gx_Ret_Sts;
    Li_TableIdx              BINARY_INTEGER;
    Li_OutTab_Idx            BINARY_INTEGER;

    L_EXCEP_UNEXPECTED_ERR   EXCEPTION;

  BEGIN

    Lx_Contracts             := P_Contracts;
    Ln_Con_Customer_Id       := P_Con_Customer_Id;
    Lv_Validate_Eff          := P_Validate_Eff;

    Lx_Result                := G_TRUE;
    Lx_Return_Status         := G_RET_STS_SUCCESS;
    Li_OutTab_Idx            := 0;

    --
    IF Lv_Validate_Eff = 'Y' THEN
      Lv_Validate_Eff := 'T';
    END IF;
    --

    Li_TableIdx  := Lx_Contracts.FIRST;

    WHILE Li_TableIdx IS NOT NULL LOOP

      Lx_Chr_Id           := Lx_Contracts(Li_TableIdx).Rx_Chr_Id;
      Ln_Party_Id         := Lx_Contracts(Li_TableIdx).Rx_Pty_Id;
      Ln_Con_Customer_Id  := NVL(Ln_Con_Customer_Id,Ln_Party_Id);

      FOR Idx IN Lx_Csr_Contracts(Lx_Chr_Id,Lv_Con_Number,Lv_Con_Number_Modifier,
                                  TO_CHAR(Ln_Con_Customer_Id),TO_CHAR(Ln_Service_Item_Id),Ln_Organization_Id) LOOP

        IF Lv_Validate_Eff = 'T' THEN

          IF Idx.Contract_Terminated_Date < Idx.Contract_End_Date THEN
            Ld_Con_Eff_End_Date := Idx.Contract_Terminated_Date;
          ELSE
            Ld_Con_Eff_End_Date := Idx.Contract_End_Date;

      -- grace period changes starts

            IF G_GRACE_PROFILE_SET = 'Y' AND Idx.Contract_Terminated_Date IS NULL THEN

              G_CONTRACT_END_DATE := Ld_Con_Eff_End_Date;
              G_CONTRACT_ID       := Idx.Contract_Id;

              Ld_Con_Eff_End_Date := Get_Final_End_Date(Idx.Contract_Id,Ld_Con_Eff_End_Date);

            END IF;

      -- grace period changes ends
          END IF;

          IF (Ld_Request_Date BETWEEN Idx.Contract_Start_Date AND Ld_Con_Eff_End_Date) THEN
            Lv_Effective_Falg := 'T';
          ELSE
            Lv_Effective_Falg := 'F';
          END IF;

        END IF;

        IF (Lv_Validate_Eff = 'T' AND Lv_Effective_Falg = 'T' ) OR (Lv_Validate_Eff <> 'T') THEN

          Li_OutTab_Idx := Li_OutTab_Idx + 1;

          Lx_Contracts_03(Li_OutTab_Idx).Contract_Id                 := Idx.Contract_Id;
          Lx_Contracts_03(Li_OutTab_Idx).Contract_Number             := Idx.Contract_Number;
          Lx_Contracts_03(Li_OutTab_Idx).Contract_Number_Modifier    := Idx.Contract_Number_Modifier;
          Lx_Contracts_03(Li_OutTab_Idx).Contract_Known_As           := Idx.Contract_Known_As;
          Lx_Contracts_03(Li_OutTab_Idx).Contract_Short_Description  := Idx.Contract_Short_Description;
          Lx_Contracts_03(Li_OutTab_Idx).Contract_Status_Code        := Idx.Contract_Status_Code;
          Lx_Contracts_03(Li_OutTab_Idx).Contract_Start_Date         := Idx.Contract_Start_Date;
          Lx_Contracts_03(Li_OutTab_Idx).Contract_End_Date           := Idx.Contract_End_Date;
          Lx_Contracts_03(Li_OutTab_Idx).Contract_Terminated_Date    := Idx.Contract_Terminated_Date;

        END IF;

      END LOOP;

      Li_TableIdx := Lx_Contracts.NEXT(Li_TableIdx);

    END LOOP;

    Sort_Asc_GetContracts_03
      (P_Input_Tab          => Lx_Contracts_03
      ,X_Output_Tab         => Lx_Contracts_03_Out
      ,X_Result             => Lx_Result
      ,X_Return_Status      => Lx_Return_Status);

    IF Lx_Result <> G_TRUE THEN
      RAISE L_EXCEP_UNEXPECTED_ERR;
    END IF;

    X_Contracts_03       := Lx_Contracts_03_Out;
    X_Result             := Lx_Result;
    X_Return_Status      := Lx_Return_Status;

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
	,P_Token2_Value   => 'Get_Contracts_03_Format');

      X_Result          := G_FALSE;
      X_Return_Status   := G_RET_STS_UNEXP_ERROR;

  END Get_Contracts_03_Format;

-----------------------------------------------------------------------------------------------------------------------*

  PROCEDURE Sort_Asc_ContRef_PlSql_Table
    (P_Input_Tab          IN  GT_Contract_Ref
    ,X_Output_Tab         out nocopy GT_Contract_Ref
    ,X_Result             out nocopy Gx_Boolean
    ,X_Return_Status   	  out nocopy Gx_Ret_Sts)  IS

    Lx_Sort_Tab           GT_Contract_Ref;
    Lx_Result             Gx_Boolean;
    Lx_Return_Status      Gx_Ret_Sts;

    Li_TableIdx_Out       BINARY_INTEGER;
    Li_TableIdx_In        BINARY_INTEGER;

    Lx_Temp_ContRef       GR_Contract_Ref;

    Lv_Compare_Val1       NUMBER;
    Lv_Compare_Val2       NUMBER;

  BEGIN

    Lx_Sort_Tab           := P_Input_Tab;
    Lx_Result             := G_TRUE;
    Lx_Return_Status      := G_RET_STS_SUCCESS;

    Li_TableIdx_Out  := Lx_Sort_Tab.FIRST;

    WHILE Li_TableIdx_Out IS NOT NULL LOOP

      Li_TableIdx_In  := Li_TableIdx_Out;

      WHILE Li_TableIdx_In IS NOT NULL LOOP

        Lv_Compare_Val1  := Lx_Sort_Tab(Li_TableIdx_Out).Rx_Chr_Id;
        Lv_Compare_Val2  := Lx_Sort_Tab(Li_TableIdx_In).Rx_Chr_Id;

        IF Lv_Compare_Val1 > Lv_Compare_Val2 THEN

          Lx_Temp_ContRef               := Lx_Sort_Tab(Li_TableIdx_Out);
          Lx_Sort_Tab(Li_TableIdx_Out)  := Lx_Sort_Tab(Li_TableIdx_In);
          Lx_Sort_Tab(Li_TableIdx_In)   := Lx_Temp_ContRef;

        END IF;

        Li_TableIdx_In  := Lx_Sort_Tab.NEXT(Li_TableIdx_In);

      END LOOP;

      Li_TableIdx_Out := Lx_Sort_Tab.NEXT(Li_TableIdx_Out);

    END LOOP;

    X_Output_Tab          := Lx_Sort_Tab;
    X_Result              := Lx_Result;
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
	,P_Token2_Value   => 'Sort_Asc_ContRef_PlSql_Table');

      X_Result           := G_FALSE;
      X_Return_Status    := G_RET_STS_UNEXP_ERROR;

  END Sort_Asc_ContRef_PlSql_Table;

-----------------------------------------------------------------------------------------------------------------------*

  PROCEDURE Dedup_ContItem_PlSql_Table
    (P_Input_Tab          IN  GT_Contract_Ref
    ,X_Output_Tab         out nocopy GT_Contract_Ref
    ,X_Result             out nocopy Gx_Boolean
    ,X_Return_Status   	  out nocopy Gx_Ret_Sts)  IS

    Lx_DeDup_Tab          GT_Contract_Ref;
    Lx_Result             Gx_Boolean;
    Lx_Return_Status      Gx_Ret_Sts;

    Lx_Temp_ContRef       GR_Contract_Ref;

    Li_TableIdx           BINARY_INTEGER;
    Lv_Compare_Val1       VARCHAR2(300);
    Lv_Compare_Val2       VARCHAR2(300);

  BEGIN

    Lx_DeDup_Tab          := P_Input_Tab;
    Lx_Result             := G_TRUE;
    Lx_Return_Status      := G_RET_STS_SUCCESS;

    Li_TableIdx           := Lx_DeDup_Tab.FIRST;

    WHILE Li_TableIdx IS NOT NULL LOOP

      Lv_Compare_Val1     := Lx_DeDup_Tab(Li_TableIdx).Rx_Chr_Id;
      Lv_Compare_Val2     := Lx_Temp_ContRef.Rx_Chr_Id;

      IF Lv_Compare_Val1 = Lv_Compare_Val2 THEN
        Lx_DeDup_Tab.DELETE(Li_TableIdx);
      ELSE
        Lx_Temp_ContRef   := Lx_DeDup_Tab(Li_TableIdx);
      END IF;

      Li_TableIdx         := Lx_DeDup_Tab.NEXT(Li_TableIdx);

    END LOOP;

    X_Output_Tab          := Lx_DeDup_Tab;
    X_Result              := Lx_Result;
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
	,P_Token2_Value   => 'Dedup_ContItem_PlSql_Table');

      X_Result         := G_FALSE;
      X_Return_Status  := G_RET_STS_UNEXP_ERROR;

  END Dedup_ContItem_PlSql_Table;

-----------------------------------------------------------------------------------------------------------------------*

  PROCEDURE Get_Contracts_03
    (P_API_Version		IN  NUMBER
    ,P_Init_Msg_List		IN  VARCHAR2
    ,P_Inp_Rec			IN  Input_Rec_EntFrm
    ,X_Return_Status 		OUT NOCOPY VARCHAR2
    ,X_Msg_Count		OUT NOCOPY NUMBER
    ,X_Msg_Data			OUT NOCOPY VARCHAR2
    ,X_Ent_Contracts		OUT NOCOPY Output_Tbl_EntFrm)
  IS

    Lx_Inp_Rec			CONSTANT Input_Rec_EntFrm := P_Inp_Rec;
    Lx_Return_Status            Gx_Ret_Sts;
    Lx_Result                   Gx_Boolean;

    Lx_Ent_Contracts            Output_Tbl_EntFrm;
    Lx_Contracts                GT_Contract_Ref;
    Lx_Contracts_Out            GT_Contract_Ref;

    Ln_Organization_Id          NUMBER;
    Ln_Org_Id                   NUMBER;
    Lv_CovLvl_Flag              VARCHAR2(1);

    L_EXCEP_UNEXPECTED_ERR      EXCEPTION;

  BEGIN

    Lx_Return_Status            := G_RET_STS_SUCCESS;
    Lx_Result                   := G_TRUE;

    Lv_CovLvl_Flag              := 'F';

 -- Bug# 4735542
 -- Ln_Organization_Id          := SYS_CONTEXT('OKC_CONTEXT','ORGANIZATION_ID');

 -- Modified for 12.0 MOAC project (JVARGHES)
 -- Ln_Org_Id                   := SYS_CONTEXT('OKC_CONTEXT','ORG_ID');
 --
    G_GRACE_PROFILE_SET         := fnd_profile.value('OKS_ENABLE_GRACE_PERIOD');

    IF Lx_Inp_Rec.CovLvl_Product_Id IS NOT NULL THEN

      Get_CovProd_Contracts
        (P_CovProd_Obj_Id         => Lx_Inp_Rec.CovLvl_Product_Id
        ,P_Organization_Id        => Ln_Organization_Id
        ,P_Org_Id                 => Ln_Org_Id
        ,X_CovProd_Contracts      => Lx_Contracts
        ,X_Result                 => Lx_Result
        ,X_Return_Status   	  => Lx_Return_Status);

      IF Lx_Result <> G_TRUE THEN
        RAISE L_EXCEP_UNEXPECTED_ERR;
      END IF;

      Lv_CovLvl_Flag            := 'T';

    ELSIF Lx_Inp_Rec.CovLvl_Item_Id IS NOT NULL THEN

      Get_CovItem_Contracts
        (P_CovItem_Obj_Id         => Lx_Inp_Rec.CovLvl_Item_Id
        ,P_Organization_Id        => Ln_Organization_Id
        ,P_Party_Id               => Lx_Inp_Rec.CovLvl_Party_Id
        ,X_CovItem_Contracts      => Lx_Contracts
        ,X_Result                 => Lx_Result
        ,X_Return_Status   	  => Lx_Return_Status);

      IF Lx_Result <> G_TRUE THEN
        RAISE L_EXCEP_UNEXPECTED_ERR;
      END IF;

      Lv_CovLvl_Flag            := 'T';

    ELSIF Lx_Inp_Rec.CovLvl_System_Id IS NOT NULL THEN

      Get_CovSys_Contracts
        (P_CovSys_Obj_Id          => Lx_Inp_Rec.CovLvl_System_Id
        ,P_Org_Id                 => Ln_Org_Id
        ,X_CovSys_Contracts       => Lx_Contracts
        ,X_Result                 => Lx_Result
        ,X_Return_Status   	  => Lx_Return_Status);

      IF Lx_Result <> G_TRUE THEN
        RAISE L_EXCEP_UNEXPECTED_ERR;
      END IF;

      Lv_CovLvl_Flag            := 'T';

    ELSIF Lx_Inp_Rec.CovLvl_Cust_Acct_Id IS NOT NULL THEN

      Get_CovCust_Contracts
        (P_CovCust_Obj_Id         => Lx_Inp_Rec.CovLvl_Cust_Acct_Id
        ,X_CovCust_Contracts      => Lx_Contracts
        ,X_Result                 => Lx_Result
        ,X_Return_Status   	  => Lx_Return_Status);

      IF Lx_Result <> G_TRUE THEN
        RAISE L_EXCEP_UNEXPECTED_ERR;
      END IF;

      Lv_CovLvl_Flag            := 'T';

    ELSIF Lx_Inp_Rec.CovLvl_Site_Id IS NOT NULL THEN

      Get_CovSite_Contracts
        (P_CovSite_Obj_Id         => Lx_Inp_Rec.CovLvl_Site_Id
        ,P_Org_Id                 => Ln_Org_Id
        ,X_CovSite_Contracts      => Lx_Contracts
        ,X_Result                 => Lx_Result
        ,X_Return_Status   	  => Lx_Return_Status);

      IF Lx_Result <> G_TRUE THEN
        RAISE L_EXCEP_UNEXPECTED_ERR;
      END IF;

      Lv_CovLvl_Flag            := 'T';

    ELSIF Lx_Inp_Rec.CovLvl_Party_Id IS NOT NULL THEN

      Get_CovParty_Contracts
        (P_CovParty_Obj_Id        => Lx_Inp_Rec.CovLvl_Party_Id
        ,X_CovParty_Contracts     => Lx_Contracts
        ,X_Result                 => Lx_Result
        ,X_Return_Status   	  => Lx_Return_Status);

      IF Lx_Result <> G_TRUE THEN
        RAISE L_EXCEP_UNEXPECTED_ERR;
      END IF;

      Lv_CovLvl_Flag            := 'T';

    END IF;

    IF Lx_Contracts.Count > 0 THEN

      Sort_Asc_ContRef_PlSql_Table
        (P_Input_Tab          => Lx_Contracts
        ,X_Output_Tab         => Lx_Contracts_Out
        ,X_Result             => Lx_Result
        ,X_Return_Status      => Lx_Return_Status);

      IF Lx_Result <> G_TRUE THEN
        RAISE L_EXCEP_UNEXPECTED_ERR;
      END IF;

      Lx_Contracts           :=  Lx_Contracts_Out;

      Dedup_ContItem_PlSql_Table
        (P_Input_Tab          => Lx_Contracts
        ,X_Output_Tab         => Lx_Contracts_Out
        ,X_Result             => Lx_Result
        ,X_Return_Status      => Lx_Return_Status);

      IF Lx_Result <> G_TRUE THEN
        RAISE L_EXCEP_UNEXPECTED_ERR;
      END IF;

    ELSE

      IF Lv_CovLvl_Flag <> 'T' THEN
        Lx_Contracts_Out(1).Rx_Cle_Id :=  NULL; --G_MISS_NUM;
      END IF;

    END IF;

    Get_Contracts_03_Format
      (P_Contracts            => Lx_Contracts_Out
      ,P_Con_Number           => Lx_Inp_Rec.Contract_Number
      ,P_Con_Number_Modifier  => Lx_Inp_Rec.Contract_Number_Modifier
      ,P_Con_Customer_Id      => Lx_Inp_Rec.Contract_Customer_Id
      ,P_Service_Item_Id      => Lx_Inp_Rec.Contract_Service_Item_Id
      ,P_Organization_Id      => Ln_Organization_Id
      ,P_Request_Date         => Lx_Inp_Rec.Request_Date
      ,P_Validate_Eff         => Lx_Inp_Rec.Validate_Effectivity
      ,X_Contracts_03         => Lx_Ent_Contracts
      ,X_Result               => Lx_Result
      ,X_Return_Status        => Lx_Return_Status);

    IF Lx_Result <> G_TRUE THEN
      RAISE L_EXCEP_UNEXPECTED_ERR;
    END IF;

    X_Ent_Contracts       := Lx_Ent_Contracts;
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
	,P_Token2_Value   => 'Get_Contracts_03');

      --X_Result        := G_FALSE;
      X_Return_Status   := G_RET_STS_UNEXP_ERROR;

  END Get_Contracts_03;

-----------------------------------------------------------------------------------------------------------------------*

  PROCEDURE Get_Contracts
    (P_API_Version	  IN  NUMBER
    ,P_Init_Msg_List	  IN  VARCHAR2
    ,P_Inp_Rec		  IN  Input_Rec_EntFrm
    ,X_Return_Status 	  out nocopy VARCHAR2
    ,X_Msg_Count	  out nocopy NUMBER
    ,X_Msg_Data		  out nocopy VARCHAR2
    ,X_Ent_Contracts	  out nocopy Output_Tbl_EntFrm)
  IS

    Lx_Inp_Rec            Input_Rec_EntFrm;

  BEGIN

    Lx_Inp_Rec            := P_Inp_Rec;

 -- Bug# 4735542
 -- okc_context.set_okc_org_context;

    IF Lx_Inp_Rec.Request_Date IS NULL THEN
      Lx_Inp_Rec.Request_Date := SYSDATE;
    END IF;

    Get_Contracts_03
      (P_API_Version	  => P_API_Version
      ,P_Init_Msg_List	  => P_Init_Msg_List
      ,P_Inp_Rec	  => Lx_Inp_Rec
      ,X_Return_Status 	  => X_Return_Status
      ,X_Msg_Count	  => X_Msg_Count
      ,X_Msg_Data	  => X_Msg_Data
      ,X_Ent_Contracts	  => X_Ent_Contracts);

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
	,P_Token2_Value   => 'Get_Contracts-Output_Tbl_EntFrm');

      --X_Result           := G_FALSE;
      X_Return_Status    := G_RET_STS_UNEXP_ERROR;

  END Get_Contracts;

-----------------------------------------------------------------------------------------------------------------------*
/*
As per ER# 2165039 this procedure (Get_HighImp_CP_Contract)
when called by IB (Installed Base) will return a record based on
following conditions:

1.Only the Covered level of 'Covered Product' would be considered.
3.Always return only one row, based on the highest importance level (1 being
the highest)- loosing the visibility to other contract lines covering the same
instance.
4.Returns only one row- system picked, even if there are multiple rows selected
for the criteria.
*/

 PROCEDURE Get_HighImp_CP_Contract
    (P_API_Version		    IN  NUMBER
    ,P_Init_Msg_List		IN  VARCHAR2
    ,P_Customer_product_Id	IN  NUMBER
    ,X_Return_Status 		OUT NOCOPY VARCHAR2
    ,X_Msg_Count 	        out nocopy NUMBER
    ,X_Msg_Data		        out nocopy VARCHAR2
    ,X_Importance_Lvl		OUT NOCOPY OKS_ENTITLEMENTS_PUB.High_Imp_level_K_rec)

  IS

  CURSOR Cur_ImplvlExists is
    select count(*) cnt
    from   oks_cov_types_v
    where importance_level is NOT NULL;
--
--
-- Modified for 12.0 Coverage Rearch project (JVARGHES)
--
--
--  CURSOR Cur_HighImpCont is
--    select  okh.contract_number,
--            okh.contract_number_modifier,
--            okh.start_date,
--            okh.end_date,
--            cvt.meaning,
--            cvt.importance_level,
--            okh.estimated_amount,
--            okh.sts_code
--    from    OKC_K_HEADERS_ALL_B okh,
--            okc_k_lines_b cle,
--            okc_k_lines_b cle_cov,
--            oks_k_lines_b okscle_cov,
--            okc_k_lines_b cle_cvl,
--            okc_k_items cim,
--            okc_statuses_v sts,
--            oks_cov_types_v cvt
--    where   cle.chr_id = okh.id
--    and     okh.sts_code = sts.code
--    and     sts.ste_code = 'ACTIVE'
--    and     cle_cov.cle_id = cle.id
--    and     cle_cov.lse_id in (2,15,20)
--    and     okscle_cov.cle_id = cle_cov.id
--    and     okscle_cov.coverage_type = cvt.code
--    and     cle_cvl.cle_id = cle.id
--    and     cle_cvl.lse_id in (9,18,25)
--    and     cle_cvl.id = cim.cle_id
--    and     cim.object1_id1 = P_Customer_product_Id
--    order by cvt.importance_level;
--
-- Modified for 12.0 Coverage Rearch project (JVARGHES)
--
--
  CURSOR Cur_HighImpCont IS
    select  okh.contract_number,
            okh.contract_number_modifier,
            okh.start_date,
            okh.end_date,
            cvt.meaning,
            cvt.importance_level,
            okh.estimated_amount,
            okh.sts_code
    from    OKC_K_HEADERS_ALL_B okh, -- OKC_K_HEADERS_B HDR  -- Modified for 12.0 MOAC project (JVARGHES)
            okc_k_lines_b cle,
            oks_k_lines_b cle_ksl,
            oks_k_lines_b okscle_cov,
            okc_k_lines_b cle_cvl,
            okc_k_items cim,
            okc_statuses_v sts,
            oks_cov_types_v cvt
    where   cle.chr_id = okh.id
    and     okh.sts_code = sts.code
    and     sts.ste_code = 'ACTIVE'
    and     cle_ksl.cle_id = cle.id
    and     okscle_cov.cle_id = cle_ksl.coverage_id
    and     okscle_cov.coverage_type = cvt.code
    and     cle_cvl.cle_id = cle.id
    and     cle_cvl.lse_id in (9,18,25)
    and     cle_cvl.id = cim.cle_id
    and     cim.object1_id1 = P_Customer_product_Id
    order by cvt.importance_level;
  --
  --
  -- Modified for 12.0 Coverage Rearch project (JVARGHES)
  --
  --
  --CURSOR Cur_CpCont is
  --  select  okh.contract_number,
  --          okh.contract_number_modifier,
  --          okh.start_date,
  --          okh.end_date,
  --          covtyp.meaning,
  --          covtyp.importance_level importance_level,
  --          okh.estimated_amount,
  --          okh.sts_code
  --  from    OKC_K_HEADERS_ALL_B okh,
  --          okc_k_lines_b cle,
  --          okc_k_lines_b cle_cov,
  --          oks_k_lines_b okscle_cov,
  --          okc_k_lines_b cle_cvl,
  --          okc_k_items cim,
  --          okc_statuses_v sts,
  --          oks_cov_types_v covtyp
  --  where   cle.chr_id = okh.id
  --  and     okh.sts_code = sts.code
  --  and     sts.ste_code = 'ACTIVE'
  --  and     cle_cov.cle_id = cle.id
  --  and     cle_cov.lse_id in (2,15,20)
  --  and     okscle_cov.cle_id = cle_cov.id
  --  and     okscle_cov.coverage_type = covtyp.code
  --  and     cle_cvl.cle_id = cle.id
  --  and     cle_cvl.lse_id in (9,18,25)
  --  and     cle_cvl.id = cim.cle_id
  --  and     cim.object1_id1 = P_Customer_product_Id
  --  and     rownum =1;
  --
  --
  --
  -- Modified for 12.0 Coverage Rearch project (JVARGHES)
  --
  --
  CURSOR Cur_CpCont is
    select  okh.contract_number,
            okh.contract_number_modifier,
            okh.start_date,
            okh.end_date,
            covtyp.meaning,
            covtyp.importance_level importance_level,
            okh.estimated_amount,
            okh.sts_code
    from    OKC_K_HEADERS_ALL_B okh, -- OKC_K_HEADERS_B okh  -- Modified for 12.0 MOAC project (JVARGHES)
            okc_k_lines_b cle,
            oks_k_lines_b cle_ksl,
            oks_k_lines_b okscle_cov,
            okc_k_lines_b cle_cvl,
            okc_k_items cim,
            okc_statuses_v sts,
            oks_cov_types_v covtyp
    where   cle.chr_id = okh.id
    and     okh.sts_code = sts.code
    and     sts.ste_code = 'ACTIVE'
    and     cle_ksl.cle_id = cle.id
    and     okscle_cov.cle_id = cle_ksl.coverage_id
    and     okscle_cov.coverage_type = covtyp.code
    and     cle_cvl.cle_id = cle.id
    and     cle_cvl.lse_id in (9,18,25)
    and     cle_cvl.id = cim.cle_id
    and     cim.object1_id1 = P_Customer_product_Id
    and     rownum =1;
   --
   --

    Lx_Result                   Gx_Boolean;

  BEGIN


    FOR Implvl_rec in Cur_ImplvlExists LOOP

       If  Implvl_rec.cnt >0 then

         FOR HighImpCont_rec in Cur_HighImpCont LOOP

            X_Importance_Lvl.contract_number            :=     HighImpCont_rec.contract_number;
            X_Importance_Lvl.contract_number_modifier   :=     HighImpCont_rec.contract_number_modifier;
            X_Importance_Lvl.contract_status_code       :=     HighImpCont_rec.sts_code;
            X_Importance_Lvl.contract_start_date        :=     HighImpCont_rec.start_date;
            X_Importance_Lvl.contract_end_date          :=     HighImpCont_rec.end_date;
            X_Importance_Lvl.contract_amount            :=     HighImpCont_rec.estimated_amount;
            X_Importance_Lvl.coverage_type              :=     HighImpCont_rec.meaning;
            X_Importance_Lvl.coverage_imp_level         :=     HighImpCont_rec.importance_level;
          exit;
         END LOOP;

        else

         FOR CpCont_rec in Cur_CpCont LOOP

            X_Importance_Lvl.contract_number            :=     CpCont_rec.contract_number;
            X_Importance_Lvl.contract_number_modifier   :=     CpCont_rec.contract_number_modifier;
            X_Importance_Lvl.contract_status_code       :=     CpCont_rec.sts_code;
            X_Importance_Lvl.contract_start_date        :=     CpCont_rec.start_date;
            X_Importance_Lvl.contract_end_date          :=     CpCont_rec.end_date;
            X_Importance_Lvl.contract_amount            :=     CpCont_rec.estimated_amount;
            X_Importance_Lvl.coverage_type              :=     CpCont_rec.meaning;
            X_Importance_Lvl.coverage_imp_level         :=     CpCont_rec.importance_level;

         END LOOP;

        end if;

     END LOOP;


    X_Return_Status  := G_RET_STS_SUCCESS;

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
	,P_Token2_Value   => 'Get_HighImp_CP_Contract');

      --X_Result         := G_FALSE;
      X_Return_Status  := G_RET_STS_UNEXP_ERROR;

  END Get_HighImp_CP_Contract;

 FUNCTION Get_Final_End_Date(
    P_Contract_Id IN number,
    P_Enddate IN DATE) Return Date is

  CURSOR Lx_Csr_HDR_Grace(Cx_HDR_Id IN Gx_OKS_Id) IS
    SELECT Grace_Duration Duration
          ,Grace_Period TimeUnit
      FROM Oks_K_Headers_B OKH
     WHERE OKH.chr_Id = Cx_HDR_Id;

  L_Date    DATE;

  BEGIN

  L_Date    := P_Enddate;

   IF G_GRACE_PROFILE_SET IS NULL THEN  -- Bug 5003767
     G_GRACE_PROFILE_SET :=  fnd_profile.value('OKS_ENABLE_GRACE_PERIOD');
   END IF;

   IF G_GRACE_PROFILE_SET = 'Y' then
    FOR Idx in Lx_Csr_HDR_Grace(P_Contract_Id) LOOP

	    if Idx.TimeUnit is not null and
      	 Idx.duration is not null then

	    	L_Date := OKC_TIME_UTIL_PVT.get_enddate(
      	        P_Enddate,
            	  Idx.TimeUnit,
                    Idx.Duration) + 1;


	    end if;
    END LOOP;
   END IF;

   RETURN L_Date;

  END Get_Final_End_Date;


-----------------------------------------------------------------------------------------------------------------------*


  PROCEDURE OKS_VALIDATE_SYSTEM
    (P_API_Version		    IN  NUMBER
    ,P_Init_Msg_List		IN  VARCHAR2
    ,P_System_Id	        IN  NUMBER
    ,P_Request_Date         IN  DATE
    ,P_Update_Only_Check    IN  VARCHAR2
    ,X_Return_Status 		OUT NOCOPY VARCHAR2
    ,X_Msg_Count 	        out nocopy NUMBER
    ,X_Msg_Data		        out nocopy VARCHAR2
    ,X_System_Valid		OUT NOCOPY VARCHAR2) IS

   CURSOR Lx_Csr_SysProd(Cx_System_id IN VARCHAR2) IS
	   SELECT CSI.instance_id CP_Id
             ,CSI.System_Id System_Id
       FROM   CSI_ITEM_INSTANCES CSI
       WHERE  CSI.System_id =  (Cx_System_Id);


   CURSOR Check_update_only(p_coverage_id IN Gx_OKS_Id) IS
       SELECT 'Y'
       FROM  okc_k_lines_v bp,
             okc_k_items cim,
             cs_business_processes cbp
       WHERE bp.cle_id = p_coverage_id
       AND   cim.cle_id = bp.id
       AND   cbp.business_process_id = cim.object1_id1
       AND   cim.jtot_object1_code = 'OKX_BUSIPROC'
       AND   (cbp.service_request_flag = 'Y'
              OR cbp.depot_repair_flag = 'Y'
              OR cbp.field_service_flag = 'Y')
       AND   ROWNUM = 1;

    Lx_system_valid             Gx_Boolean;

    l_system_id                 CONSTANT NUMBER := p_system_id;
    l_request_date              CONSTANT DATE := nvl(p_request_date,sysdate);
    l_update_only_check         CONSTANT VARCHAR2(1) := nvl(p_update_only_check,'N');
    l_out_validate_csi          VARCHAR2(1);

    Li_TableIdx                 BINARY_INTEGER;
    Lx_System_CovLevels         GT_ContItem_Ref;
    Lx_Prod_CovLevels           GT_ContItem_Ref;
    Lx_CovSys_Contracts         GT_Contract_Ref;
    Lx_CustProd_Contracts       GT_Contract_Ref;
    Lx_Result                   Gx_Boolean;
    Lx_Return_Status            Gx_Ret_Sts;
    Lx_Ent_Contracts            Get_ConTop_Tbl ;
    Lx_ExcepionMsg              Gx_ExceptionMsg;
    L_EXCEP_NO_DATA_FOUND       EXCEPTION;
    L_EXCEP_UNEXPECTED_ERR      EXCEPTION;
    L_VALIDATE_CSI              EXCEPTION;
    i                           NUMBER;

    X_out_paramter_csi          VARCHAR2(1);

    BEGIN

     Lx_system_valid             := G_FALSE;
     Lx_Result                   := G_TRUE;
     Lx_Return_Status            := G_RET_STS_SUCCESS;

     l_out_validate_csi          := 'N';

     Li_TableIdx  := 1;

     Lx_System_CovLevels(Li_TableIdx).Rx_Obj1Id1  := l_system_id;

     Lx_System_CovLevels(Li_TableIdx).Rx_Obj1Id2  := '#';
     Lx_System_CovLevels(Li_TableIdx).Rx_ObjCode  := 'OKX_COVSYST';


      Get_CovLevel_Contracts
      (P_CovLevel_Items      => Lx_System_CovLevels
      ,P_Party_Id            => NULL
      ,X_CovLevel_Contracts  => Lx_CovSys_Contracts
      ,X_Result              => Lx_Result
      ,X_Return_Status       => Lx_Return_Status);

        IF Lx_Result <> G_TRUE THEN
              RAISE L_EXCEP_UNEXPECTED_ERR;
        END IF;


      Get_Contracts_02_Format
      (P_Contracts          => Lx_CovSys_Contracts
      ,P_BusiProc_Id	    => NULL
      ,P_Severity_Id	    => NULL
      ,P_Request_TZone_Id   => NULL
      ,P_Dates_In_Input_TZ  => 'Y'             -- Added for 12.0 ENT-TZ project (JVARGHES)
      ,P_Incident_Date      => l_request_date  -- Added for 12.0 ENT-TZ project (JVARGHES)
      ,P_Request_Date       => l_request_date
      ,P_Calc_RespTime_YN   => 'N'
      ,P_Validate_Eff       => 'T'
      ,P_Validate_Flag      => 'Y'
      ,P_SrvLine_Flag       => 'F'
      ,P_Sort_Key           => NULL
      ,X_Contracts_02       => Lx_Ent_Contracts
      ,X_Result             => Lx_Result
      ,X_Return_Status      => Lx_Return_Status);

        IF Lx_Result <> G_TRUE THEN
               RAISE L_EXCEP_UNEXPECTED_ERR;
        END IF;

        IF Lx_Ent_Contracts.count > 0 THEN

          IF l_update_only_check <> 'Y' then
             l_out_validate_csi := 'Y';
             --RETURN l_out_validate_csi;
			x_system_valid := l_out_validate_csi;
			RAISE L_VALIDATE_CSI;
          ELSE
             i := 1;
             LOOP
               FOR bp_rec IN Check_update_only(Lx_Ent_Contracts(i).coverage_term_line_id)
               LOOP
                l_out_validate_csi := 'Y';
                --RETURN l_out_validate_csi;
			x_system_valid := l_out_validate_csi;
			RAISE L_VALIDATE_CSI;
               END LOOP;

               IF (i = Lx_Ent_Contracts.last) THEN
                EXIT;
               END IF;
                i := Lx_Ent_Contracts.next(i);
             END LOOP;
           END IF;

         END IF;

         Li_TableIdx := 0;

         FOR Itm in Lx_Csr_SysProd(l_System_id)
         LOOP
            Li_TableIdx := Li_TableIdx + 1;

            Lx_Prod_CovLevels(Li_TableIdx).Rx_Obj1Id1  := Itm.CP_Id;
            Lx_Prod_CovLevels(Li_TableIdx).Rx_Obj1Id2  := '#';
            Lx_Prod_CovLevels(Li_TableIdx).Rx_ObjCode  := 'OKX_CUSTPROD';

              Get_CovLevel_Contracts
                  (P_CovLevel_Items      => Lx_Prod_CovLevels
                  ,P_Party_Id            => NULL
                  ,X_CovLevel_Contracts  => Lx_CustProd_Contracts
                  ,X_Result              => Lx_Result
                  ,X_Return_Status       => Lx_Return_Status);


               IF Lx_Result <> G_TRUE THEN
                    RAISE L_EXCEP_UNEXPECTED_ERR;
               END IF;

              Get_Contracts_02_Format
                  (P_Contracts          => Lx_CustProd_Contracts
                  ,P_BusiProc_Id	    => NULL
                  ,P_Severity_Id	    => NULL
                  ,P_Request_TZone_Id   => NULL
                  ,P_Dates_In_Input_TZ  => 'Y'             -- Added for 12.0 ENT-TZ project (JVARGHES)
                  ,P_Incident_Date      => l_request_date  -- Added for 12.0 ENT-TZ project (JVARGHES)
                  ,P_Request_Date       => l_request_date
                  ,P_Calc_RespTime_YN   => 'N'
                  ,P_Validate_Eff       => 'T'
                  ,P_Validate_Flag      => 'Y'
                  ,P_SrvLine_Flag       => 'F'
                  ,P_Sort_Key           => NULL
                  ,X_Contracts_02       => Lx_Ent_Contracts
                  ,X_Result             => Lx_Result
                  ,X_Return_Status      => Lx_Return_Status);


               IF Lx_Result <> G_TRUE THEN
                    RAISE L_EXCEP_UNEXPECTED_ERR;
               END IF;

               IF Lx_Ent_Contracts.count > 0 THEN
                 IF l_update_only_check <> 'Y' THEN
                    l_out_validate_csi := 'Y';
                    --RETURN l_out_validate_csi;
			x_system_valid := l_out_validate_csi;
			RAISE L_VALIDATE_CSI;
                 ELSE
                    i := 1;
                    LOOP
                      FOR bp_rec IN Check_update_only(Lx_Ent_Contracts(i).coverage_term_line_id)
                      LOOP
                         l_out_validate_csi := 'Y';
                         --RETURN l_out_validate_csi;
			x_system_valid := l_out_validate_csi;
			RAISE L_VALIDATE_CSI;
                      END LOOP;
                      IF (i = Lx_Ent_Contracts.last) THEN
                        EXIT;
                      END IF;
                          i := Lx_Ent_Contracts.next(i);
                    END LOOP;
                  END IF;
                END IF;

            END LOOP;

            --RETURN l_out_validate_csi;
			x_system_valid := l_out_validate_csi;
			RAISE L_VALIDATE_CSI;

  EXCEPTION

	WHEN L_VALIDATE_CSI THEN
		x_return_status := G_RET_STS_SUCCESS;

    WHEN L_EXCEP_UNEXPECTED_ERR THEN

       --RETURN l_out_validate_csi;
			x_system_valid := l_out_validate_csi;
			x_return_status := G_RET_STS_UNEXP_ERROR;

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
    	,P_Token2_Value   => 'OKS_VALIDATE_SYSTEM');

    --RETURN l_out_validate_csi;
			x_system_valid := l_out_validate_csi;
			x_return_status := G_RET_STS_UNEXP_ERROR;

  END OKS_VALIDATE_SYSTEM;

  PROCEDURE Get_CSI_LatestEdDtdKLines_02
    (P_Input_Tab          IN  Get_ConTop_Tbl
    ,X_Output_Tab         out nocopy Get_ConTop_Tbl
    ,X_Result             out nocopy Gx_Boolean
    ,X_Return_Status   	  out nocopy Gx_Ret_Sts)
  IS

    Lx_Sort_Tab           Get_ConTop_Tbl;
    Lx_Sort_Tab_Out       Get_ConTop_Tbl;
    Lx_Result             Gx_Boolean;
    Lx_Return_Status      Gx_Ret_Sts;

    Li_TableIdx_Out       BINARY_INTEGER;
    Li_TableIdx_In        BINARY_INTEGER;

    Lx_Temp_ContItem      Get_ConTop_Rec;

    Lv_Composit_Val1      DATE;
    Lv_Composit_Val1_Num  NUMBER;

    Lv_Composit_Val2      DATE;
    Lv_Composit_Val2_Num  NUMBER;

    i                     NUMBER;
    j                     NUMBER;
    Lx_KLine_EdDt         DATE;

  BEGIN

    Lx_Sort_Tab           := P_Input_Tab;
    Lx_Result             := G_TRUE;
    Lx_Return_Status      := G_RET_STS_SUCCESS;

    Li_TableIdx_Out  := Lx_Sort_Tab.FIRST;

-- Sorting Contract lines with latest end dates

    WHILE Li_TableIdx_Out IS NOT NULL LOOP

      Li_TableIdx_In  := Li_TableIdx_Out;

      WHILE Li_TableIdx_In IS NOT NULL LOOP

        Lv_Composit_Val1  := Lx_Sort_Tab(Li_TableIdx_Out).Service_End_Date;
        Lv_Composit_Val1_Num  := TO_NUMBER(TO_CHAR(Lv_Composit_Val1,'YYYYMMDDHH24MISS'));
        Lv_Composit_Val2  := Lx_Sort_Tab(Li_TableIdx_In).Service_End_Date;
        Lv_Composit_Val2_Num  := TO_NUMBER(TO_CHAR(Lv_Composit_Val2,'YYYYMMDDHH24MISS'));

        IF Lv_Composit_Val1_Num < Lv_Composit_Val2_Num THEN

          Lx_Temp_ContItem              := Lx_Sort_Tab(Li_TableIdx_Out);
          Lx_Sort_Tab(Li_TableIdx_Out)  := Lx_Sort_Tab(Li_TableIdx_In);
          Lx_Sort_Tab(Li_TableIdx_In)   := Lx_Temp_ContItem;

        END IF;

        Li_TableIdx_In  := Lx_Sort_Tab.NEXT(Li_TableIdx_In);

      END LOOP;

      Li_TableIdx_Out := Lx_Sort_Tab.NEXT(Li_TableIdx_Out);

    END LOOP;



-- keeping contract lines with latest end date

    i                 := Lx_Sort_Tab.First;
    j                 := 1;
    Lx_KLine_EdDt     := Lx_Sort_Tab(i).Service_End_Date;

    WHILE i IS NOT NULL LOOP
        IF Lx_KLine_EdDt <> Lx_Sort_Tab(i).Service_End_Date THEN
           EXIT;
        ELSE
           Lx_Sort_Tab_Out(j)  := Lx_Sort_Tab(i);
           i := Lx_Sort_Tab.Next(i);
           j := j+1 ; --Lx_Sort_Tab_Out.Next(j);
        END IF;
    END LOOP;

    X_Output_Tab          := Lx_Sort_Tab_Out;
    X_Result              := Lx_Result;
    X_Return_Status       := Lx_Return_Status;

    Lx_Sort_Tab.DELETE;

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
	,P_Token2_Value   => 'Get_CSI_LatestEdDtdKLines_02');

      X_Result           := G_FALSE;
      X_Return_Status    := G_RET_STS_UNEXP_ERROR;

  END Get_CSI_LatestEdDtdKLines_02;

  PROCEDURE Sort_CSI_KLineId_02
    (P_Input_Tab          IN  Get_ConTop_Tbl
    ,X_Output_Tab         out nocopy Get_ConTop_Tbl
    ,X_Result             out nocopy Gx_Boolean
    ,X_Return_Status   	  out nocopy Gx_Ret_Sts)
  IS

    Lx_Sort_Tab           Get_ConTop_Tbl;
    Lx_Result             Gx_Boolean;
    Lx_Return_Status      Gx_Ret_Sts;

    Li_TableIdx_Out       BINARY_INTEGER;
    Li_TableIdx_In        BINARY_INTEGER;

    Lx_Temp_ContItem      Get_ConTop_Rec;

    Lv_Composit_Val1      DATE;
    Lv_Composit_Val1_Num  NUMBER;

    Lv_Composit_Val2      DATE;
    Lv_Composit_Val2_Num  NUMBER;

  BEGIN

    Lx_Sort_Tab           := P_Input_Tab;
    Lx_Result             := G_TRUE;
    Lx_Return_Status      := G_RET_STS_SUCCESS;

    Li_TableIdx_Out  := Lx_Sort_Tab.FIRST;

    WHILE Li_TableIdx_Out IS NOT NULL LOOP

      Li_TableIdx_In  := Li_TableIdx_Out;

      WHILE Li_TableIdx_In IS NOT NULL LOOP

        Lv_Composit_Val1_Num  := Lx_Sort_Tab(Li_TableIdx_Out).Service_Line_Id;
        Lv_Composit_Val2_Num  := Lx_Sort_Tab(Li_TableIdx_In).Service_Line_Id;

        IF Lv_Composit_Val1_Num > Lv_Composit_Val2_Num THEN

          Lx_Temp_ContItem              := Lx_Sort_Tab(Li_TableIdx_Out);
          Lx_Sort_Tab(Li_TableIdx_Out)  := Lx_Sort_Tab(Li_TableIdx_In);
          Lx_Sort_Tab(Li_TableIdx_In)   := Lx_Temp_ContItem;

        END IF;

        Li_TableIdx_In  := Lx_Sort_Tab.NEXT(Li_TableIdx_In);

      END LOOP;

      Li_TableIdx_Out := Lx_Sort_Tab.NEXT(Li_TableIdx_Out);

    END LOOP;

    X_Output_Tab          := Lx_Sort_Tab;
    X_Result              := Lx_Result;
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
	,P_Token2_Value   => 'Sort_CSI_KLineId_02');

      X_Result           := G_FALSE;
      X_Return_Status    := G_RET_STS_UNEXP_ERROR;

  END Sort_CSI_KLineId_02;


  PROCEDURE Dedup_CSICP_KLine_PlSql_Table
    (P_Input_Tab          IN  GT_Contract_Ref
    ,X_Output_Tab         out nocopy GT_Contract_Ref
    ,X_Result             out nocopy Gx_Boolean
    ,X_Return_Status   	  out nocopy Gx_Ret_Sts)  IS

    Lx_DeDup_Tab          GT_Contract_Ref;
    Lx_Result             Gx_Boolean;
    Lx_Return_Status      Gx_Ret_Sts;

    Lx_Temp_ContRef       GR_Contract_Ref;

    Li_TableIdx           BINARY_INTEGER;
    Lv_Compare_Val1       VARCHAR2(300);
    Lv_Compare_Val2       VARCHAR2(300);

  BEGIN

    Lx_DeDup_Tab          := P_Input_Tab;
    Lx_Result             := G_TRUE;
    Lx_Return_Status      := G_RET_STS_SUCCESS;

    Li_TableIdx           := Lx_DeDup_Tab.FIRST;

    WHILE Li_TableIdx IS NOT NULL LOOP

      Lv_Compare_Val1     := Lx_DeDup_Tab(Li_TableIdx).Rx_Cle_Id;
      Lv_Compare_Val2     := Lx_Temp_ContRef.Rx_Cle_Id;

      IF Lv_Compare_Val1 = Lv_Compare_Val2 THEN
        Lx_DeDup_Tab.DELETE(Li_TableIdx);
      ELSE
        Lx_Temp_ContRef   := Lx_DeDup_Tab(Li_TableIdx);
      END IF;

      Li_TableIdx         := Lx_DeDup_Tab.NEXT(Li_TableIdx);

    END LOOP;

    X_Output_Tab          := Lx_DeDup_Tab;
    X_Result              := Lx_Result;
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
	,P_Token2_Value   => 'Dedup_CSICP_KLine_PlSql_Table');

      X_Result         := G_FALSE;
      X_Return_Status  := G_RET_STS_UNEXP_ERROR;

  END Dedup_CSICP_KLine_PlSql_Table;

  -----------------------------------------------------------------------------------------------------------------------*

  PROCEDURE Get_Sort_CSI_ImpLvl
    (P_Contracts            IN  Get_ConTop_Tbl
    ,X_Contracts_02         out nocopy Get_ConTop_Tbl
    ,X_Result               out nocopy Gx_Boolean
    ,X_Return_Status   	    out nocopy Gx_Ret_Sts)
  IS

    Lx_Contracts             Get_ConTop_Tbl;
    Lx_Contracts_01          Get_ConTop_Tbl;
    Lx_Contracts_01_Out      Get_ConTop_Tbl;
    Lx_Contracts_02          Get_ConTop_Tbl;


    Lx_Result                Gx_Boolean;
    Lx_Return_Status         Gx_Ret_Sts;

    Lx_Cov_Type_Code         Oks_Cov_Types_B.Code%TYPE;
    Lx_Cov_Type_Meaning      Oks_Cov_Types_TL.Meaning%TYPE;
    Lx_Cov_Type_Description  Oks_Cov_Types_TL.Description%TYPE;
    Lx_Cov_Type_Imp_Level    Oks_Cov_Types_B.Importance_Level%TYPE;


    Li_OutTab_Idx            BINARY_INTEGER;
    i                        NUMBER ;
    j                        NUMBER ;
    Lx_Imp_Level             NUMBER;

    Ln_Msg_Count	     NUMBER;
    Lv_Msg_Data		     VARCHAR2(2000);

    L_EXCEP_UNEXPECTED_ERR   EXCEPTION;

  BEGIN

    Lx_Contracts             := P_Contracts;
    Lx_Result                := G_TRUE;
    Lx_Return_Status         := G_RET_STS_SUCCESS;
    Li_OutTab_Idx            := 1;

        Lx_Contracts_01 := Lx_Contracts;

-- getting importance level for all Contract lines

        WHILE Li_OutTab_Idx IS NOT NULL LOOP

            Get_Coverage_Type_Attribs
              (P_CVL_Id                => Lx_Contracts_01(Li_OutTab_Idx).Coverage_Term_Line_Id
              ,P_Set_ExcepionStack     => G_FALSE
              ,X_Cov_Type_Code         => Lx_Cov_Type_Code
              ,X_Cov_Type_Meaning      => Lx_Cov_Type_Meaning
              ,X_Cov_Type_Description  => Lx_Cov_Type_Description
              ,X_Cov_Type_Imp_Level    => Lx_Cov_Type_Imp_Level
              ,X_Result                => Lx_Result
              ,X_Return_Status         => Lx_Return_Status);

            IF Lx_Return_Status = G_RET_STS_UNEXP_ERROR THEN
              RAISE L_EXCEP_UNEXPECTED_ERR;
            END IF;

            Lx_Contracts_01(Li_OutTab_Idx).Coverage_Type_Code      :=  Lx_Cov_Type_Code;
            Lx_Contracts_01(Li_OutTab_Idx).Coverage_Type_Meaning   :=  Lx_Cov_Type_Meaning;
            Lx_Contracts_01(Li_OutTab_Idx).coverage_Type_Imp_Level :=  Lx_Cov_Type_Imp_Level;

           Li_OutTab_Idx := Lx_Contracts_01.NEXT(Li_OutTab_Idx);

        END LOOP;

-- Sorting importance level for all Contract lines

        Sort_Asc_GetContracts_02
        (P_Input_Tab          => Lx_Contracts_01
        ,P_Sort_Key           => G_COVERAGE_TYPE_IMP_LEVEL --Lv_Sort_Key
        ,X_Output_Tab         => Lx_Contracts_01_Out
        ,X_Result             => Lx_Result
        ,X_Return_Status      => Lx_Return_Status);

        IF Lx_Result <> G_TRUE THEN
            RAISE L_EXCEP_UNEXPECTED_ERR;
        END IF;

        Lx_Contracts_01.DELETE;
        Lx_Contracts_01 := Lx_Contracts_01_Out;
        Lx_Contracts_01_Out.DELETE;

-- Keeping all Contract lines with highest importance level

        i                 := Lx_Contracts_01.First;
        j                 := 1;
        Lx_Imp_Level      := nvl(Lx_Contracts_01(i).coverage_Type_Imp_Level,-9999);

        WHILE i IS NOT NULL LOOP

            IF Lx_Imp_Level <> nvl(Lx_Contracts_01(i).coverage_Type_Imp_Level,-9999) THEN
               EXIT;
            ELSE
               Lx_Contracts_02(j) := Lx_Contracts_01(i);
               i := Lx_Contracts_01.Next(i);
               j := j+1;
            END IF;
        END LOOP;
        X_Contracts_02        := Lx_Contracts_02;
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
	,P_Token2_Value   => 'Get_Sort_CSI_ImpLvl');

      X_Result          := G_FALSE;
      X_Return_Status   := G_RET_STS_UNEXP_ERROR;

  END Get_Sort_CSI_ImpLvl;

  -----------------------------------------------------------------------------------------------------------------------*

  PROCEDURE Get_CSI_KLine_PrefGrps
    (P_Contracts            IN  Get_ConTop_Tbl
    ,X_Contracts_02         out nocopy Get_ConTop_Tbl
    ,X_Result               out nocopy Gx_Boolean
    ,X_Return_Status   	    out nocopy Gx_Ret_Sts)
  IS

    CURSOR Check_Preferred_Group(p_coverage_id IN Gx_OKS_Id,p_chr_id in Gx_OKS_Id) IS
       SELECT  COUNT(*) Pref_Grp_Cnt --CON.OBJECT1_ID1
       FROM    OKC_K_LINES_B CVL,
               OKC_K_LINES_B BPL,
               OKC_K_PARTY_ROLES_B CPL,
               OKC_CONTACTS CON
       WHERE   CVL.ID = p_coverage_id
       AND     BPL.CLE_ID = CVL.ID
       AND     BPL.LSE_ID in (3,16,21)
       AND     BPL.ID = CPL.CLE_ID
       AND     CPL.ID = CON.CPL_ID
       and     con.dnz_chr_id = p_chr_id
       AND     CON.JTOT_OBJECT1_CODE = 'OKS_RSCGROUP';


    Lx_Contracts             Get_ConTop_Tbl;
    Lx_Contracts_02          Get_ConTop_Tbl;

    Lx_Result                Gx_Boolean;
    Lx_Return_Status         Gx_Ret_Sts;

    Lx_Cov_Type_Code         Oks_Cov_Types_B.Code%TYPE;
    Lx_Cov_Type_Meaning      Oks_Cov_Types_TL.Meaning%TYPE;
    Lx_Cov_Type_Description  Oks_Cov_Types_TL.Description%TYPE;
    Lx_Cov_Type_Imp_Level    Oks_Cov_Types_B.Importance_Level%TYPE;


    Li_OutTab_Idx            BINARY_INTEGER;
    i                        NUMBER;
    j                        NUMBER;

    Ln_Msg_Count	     NUMBER;
    Lv_Msg_Data		     VARCHAR2(2000);

    L_EXCEP_UNEXPECTED_ERR   EXCEPTION;

  BEGIN

    Lx_Contracts             := P_Contracts;
    Lx_Result                := G_TRUE;
    Lx_Return_Status         := G_RET_STS_SUCCESS;
    Li_OutTab_Idx            := 1;

         i                 := Lx_Contracts.First;
         j                 := 1;

         WHILE i IS NOT NULL LOOP  -- building table of records having contract lines
                                                  -- with preferred group
             FOR Pref_Grp_Rec in Check_Preferred_Group(Lx_Contracts(i).Coverage_Term_Line_Id,
                                                       Lx_Contracts(i).Contract_Id) LOOP

                 IF Pref_Grp_Rec.Pref_Grp_Cnt >= 1 THEN
                    Lx_Contracts_02(j) := Lx_Contracts(i);
                 END IF;
             END LOOP;
             i := Lx_Contracts.Next(i);
             j := j+1;
         END LOOP;

-- Logic here is if there any contract line with preferred group then that is the ouput otherwise all
-- Input Contract lines are without preferred groups and hence all of them are tie candidates

         IF Lx_Contracts_02.COUNT > 0 THEN
           X_Contracts_02       := Lx_Contracts_02;
         ELSE
           X_Contracts_02       := Lx_Contracts;
         END IF;

         Lx_Contracts_02.DELETE;
         Lx_Contracts.DELETE;

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
	,P_Token2_Value   => 'Get_CSI_KLine_PrefGrps');

      X_Result          := G_FALSE;
      X_Return_Status   := G_RET_STS_UNEXP_ERROR;

  END Get_CSI_KLine_PrefGrps;


  PROCEDURE Default_Contline_System
    (P_API_Version		    IN  NUMBER
    ,P_Init_Msg_List		IN  VARCHAR2
    ,P_System_Id	        IN  NUMBER
    ,P_Request_Date         IN  DATE
    ,X_Return_Status 		OUT NOCOPY VARCHAR2
    ,X_Msg_Count 	        out nocopy NUMBER
    ,X_Msg_Data		        out nocopy VARCHAR2
    ,X_Ent_Contracts		OUT NOCOPY Default_Contline_System_Rec) IS

   CURSOR Lx_Csr_SysProd(Cx_System_id IN VARCHAR2) IS
       SELECT CSI.instance_id CP_Id,
              CSI.System_Id System_Id
       FROM   CSI_ITEM_INSTANCES CSI
       WHERE  CSI.System_id =  (Cx_System_Id);

    l_system_id                 NUMBER;
    l_request_date              DATE;

    Li_TableIdx                 BINARY_INTEGER;
    Lx_System_CovLevels         GT_ContItem_Ref;
    Lx_Prod_CovLevels           GT_ContItem_Ref;
    Lx_CovSys_Contracts         GT_Contract_Ref;
    Lx_CustProd_Contracts       GT_Contract_Ref;
    Lx_Contracts                GT_Contract_Ref;
    Lx_Contracts_Out            GT_Contract_Ref;
    Lx_Result                   Gx_Boolean;
    Lx_Return_Status            Gx_Ret_Sts;

    Lx_Ent_Contracts            Get_ConTop_Tbl ;
    Lx_Ent_Contracts_01         Get_ConTop_Tbl ;
    Lx_Ent_Contracts_02         Get_ConTop_Tbl ;
    Lx_Ent_Contracts2           Get_ConTop_Tbl ;

    Lx_ExcepionMsg              Gx_ExceptionMsg;
    L_EXCEP_NO_DATA_FOUND       EXCEPTION;
    L_EXCEP_UNEXPECTED_ERR      EXCEPTION;
    L_DEF_CONTRACT_LINE         EXCEPTION;
    i                           NUMBER;
    j                           NUMBER;
    l_imp_level                 NUMBER;
    l_KLine_EdDt                DATE;

    BEGIN


    l_system_id                 := p_system_id;
    l_request_date              := p_request_date;
    Lx_Result                   := G_TRUE;
    Lx_Return_Status            := G_RET_STS_SUCCESS;

     Li_TableIdx  := 1;

     Lx_System_CovLevels(Li_TableIdx).Rx_Obj1Id1  := l_system_id;
     Lx_System_CovLevels(Li_TableIdx).Rx_Obj1Id2  := '#';
     Lx_System_CovLevels(Li_TableIdx).Rx_ObjCode  := 'OKX_COVSYST';

-- Gets all the contract lines for the covered system_id

      Get_CovLevel_Contracts
      (P_CovLevel_Items      => Lx_System_CovLevels
      ,P_Party_Id            => NULL
      ,X_CovLevel_Contracts  => Lx_CovSys_Contracts
      ,X_Result              => Lx_Result
      ,X_Return_Status       => Lx_Return_Status);

        IF Lx_Result <> G_TRUE THEN
              RAISE L_EXCEP_UNEXPECTED_ERR;
        END IF;

--- Gets the all the valid contract lines and detailed information

      Get_Contracts_02_Format
      (P_Contracts          => Lx_CovSys_Contracts
      ,P_BusiProc_Id	    => NULL
      ,P_Severity_Id	    => NULL
      ,P_Request_TZone_Id   => NULL
      ,P_Dates_In_Input_TZ  => 'Y'             -- Added for 12.0 ENT-TZ project (JVARGHES)
      ,P_Incident_Date      => l_request_date  -- Added for 12.0 ENT-TZ project (JVARGHES)
      ,P_Request_Date       => l_request_date
      ,P_Calc_RespTime_YN   => 'N'
      ,P_Validate_Eff       => 'T'
      ,P_Validate_Flag      => 'Y'
      ,P_SrvLine_Flag       => 'F'
      ,P_Sort_Key           => NULL --'COVTYP_IMP' --NULL
      ,X_Contracts_02       => Lx_Ent_Contracts
      ,X_Result             => Lx_Result
      ,X_Return_Status      => Lx_Return_Status);


        IF Lx_Result <> G_TRUE THEN
               RAISE L_EXCEP_UNEXPECTED_ERR;
        END IF;

        IF      Lx_Ent_Contracts.COUNT = 1 THEN -- only one direct record for system id

                    X_Ent_Contracts := Lx_Ent_Contracts(1);
                    RAISE L_DEF_CONTRACT_LINE;

        ELSIF   Lx_Ent_Contracts.COUNT > 1 THEN -- more than one direct record for system id

-- Sorts all the contract lines with highest importance level and then returns contract lines with highest
-- importance level


                 Get_Sort_CSI_ImpLvl
                    (P_Contracts            => Lx_Ent_Contracts
                    ,X_Contracts_02         => Lx_Ent_Contracts2
                    ,X_Result               => Lx_Result
                    ,X_Return_Status   	    => Lx_Return_Status);

                IF Lx_Result <> G_TRUE THEN
                   RAISE L_EXCEP_UNEXPECTED_ERR;
                END IF;

                Lx_Ent_Contracts.DELETE;
                Lx_Ent_Contracts := Lx_Ent_Contracts2;
                Lx_Ent_Contracts2.DELETE;


                IF    Lx_Ent_Contracts.COUNT = 1 THEN -- one record with highest importance level

                        X_Ent_Contracts := Lx_Ent_Contracts(1);
                        RAISE L_DEF_CONTRACT_LINE;

                ELSIF  Lx_Ent_Contracts.COUNT >1 THEN -- more than one record with highest importance level
                                                      -- ; Tie exists

                        -- Gets all the contract lines with preferred groups

                        Get_CSI_KLine_PrefGrps
                            (P_Contracts            => Lx_Ent_Contracts
                            ,X_Contracts_02         => Lx_Ent_Contracts_01
                            ,X_Result               => Lx_Result
                            ,X_Return_Status   	    => Lx_Return_Status);

                        IF Lx_Result <> G_TRUE THEN
                            RAISE L_EXCEP_UNEXPECTED_ERR;
                        END IF;

                        Lx_Ent_Contracts.DELETE;

                        IF     Lx_Ent_Contracts_01.COUNT = 1 THEN -- one record with preferred group

                                X_Ent_Contracts := Lx_Ent_Contracts_01(1);
                                RAISE L_DEF_CONTRACT_LINE;

                        ELSIF  (Lx_Ent_Contracts_01.COUNT >1 )THEN -- more than one record or,
                                                                   -- no record with preferred group
                                                                   --   (the above proc. returns all); Tie exists

                           -- Getting contract lines  with latest end date

                                 Get_CSI_LatestEdDtdKLines_02
                                      (P_Input_Tab          => Lx_Ent_Contracts_01
                                      ,X_Output_Tab         => Lx_Ent_Contracts_02
                                      ,X_Result             => Lx_Result
                                      ,X_Return_Status      => Lx_Return_Status);


                                IF Lx_Result <> G_TRUE THEN
                                    RAISE L_EXCEP_UNEXPECTED_ERR;
                                END IF;


                                IF   Lx_Ent_Contracts_02.COUNT >= 1 THEN --only one contract line with same
                                                                        --latest end date ,
                                                                        -- in case,more than one contract line with
                                                                         --same latest end date; return first one

                                      X_Ent_Contracts := Lx_Ent_Contracts_02(1);
                                      RAISE L_DEF_CONTRACT_LINE;

 --                               ELSIF Lx_Ent_Contracts_02.COUNT > 1 THEN --more than one contract line with
                                                                         --same latest end date; Tie exists


  --                                    NULL;  -- Automatically goes to indirect lines logic

                                END IF; --line latest end date comparison ends

                        END IF; -- preferred group comparison ends

--              ELSIF  Lx_Ent_Contracts.COUNT =0 THEN -- no record with highest importance level  (probably N/A)
  --                      NULL;
                END IF; -- highest importance level comparison ends

--        ELSIF   Lx_Ent_Contracts.COUNT = 0 THEN -- no direct record for system id

--                NULL;  -- Automatically goes to indirect lines logic

        END IF;

        Lx_Ent_Contracts.DELETE;
        Lx_Ent_Contracts_01.DELETE;
        Lx_Ent_Contracts_02.DELETE;

----- Indirect lines logic starts

        Li_TableIdx := 0;

---   Following loop gets all the contract lines for all the covered customer products for a system id

        FOR Itm in Lx_Csr_SysProd(l_System_id)
        LOOP

            Li_TableIdx := Li_TableIdx + 1;

            Lx_Prod_CovLevels(Li_TableIdx).Rx_Obj1Id1  := Itm.CP_Id;
            Lx_Prod_CovLevels(Li_TableIdx).Rx_Obj1Id2  := '#';
            Lx_Prod_CovLevels(Li_TableIdx).Rx_ObjCode  := 'OKX_CUSTPROD';

        END LOOP;

               Get_CovLevel_Contracts
                  (P_CovLevel_Items      => Lx_Prod_CovLevels
                  ,P_Party_Id            => NULL
                  ,X_CovLevel_Contracts  => Lx_CustProd_Contracts
                  ,X_Result              => Lx_Result
                  ,X_Return_Status       => Lx_Return_Status);

         Lx_Contracts :=  Lx_CustProd_Contracts;
         Lx_CustProd_Contracts.DELETE;

 --- Removes all the duplicate contract lines

         Dedup_CSICP_KLine_PlSql_Table
                    (P_Input_Tab          => Lx_Contracts
                    ,X_Output_Tab         => Lx_Contracts_Out
                    ,X_Result             => Lx_Result
                    ,X_Return_Status   	  => Lx_Return_Status);


         IF Lx_Result <> G_TRUE THEN
              RAISE L_EXCEP_UNEXPECTED_ERR;
         END IF;

         Lx_Contracts :=  Lx_Contracts_Out;
         Lx_Contracts_Out.DELETE;

--- Gets the all the valid contract lines and detailed information

              Get_Contracts_02_Format
                  (P_Contracts          => Lx_Contracts
                  ,P_BusiProc_Id	    => NULL
                  ,P_Severity_Id	    => NULL
                  ,P_Request_TZone_Id   => NULL
                  ,P_Request_Date       => l_request_date
                  ,P_Dates_In_Input_TZ  => 'Y'             -- Added for 12.0 ENT-TZ project (JVARGHES)
                  ,P_Incident_Date      => l_request_date  -- Added for 12.0 ENT-TZ project (JVARGHES)
                  ,P_Calc_RespTime_YN   => 'N'
                  ,P_Validate_Eff       => 'T'
                  ,P_Validate_Flag      => 'Y'
                  ,P_SrvLine_Flag       => 'F'
                  ,P_Sort_Key           => NULL --'COVTYP_IMP' --NULL
                  ,X_Contracts_02       => Lx_Ent_Contracts
                  ,X_Result             => Lx_Result
                  ,X_Return_Status      => Lx_Return_Status);


           IF Lx_Result <> G_TRUE THEN
                RAISE L_EXCEP_UNEXPECTED_ERR;
           END IF;

        IF      Lx_Ent_Contracts.COUNT = 1 THEN -- only one indirect record for cp_ids of the system id

                    X_Ent_Contracts := Lx_Ent_Contracts(1);
                    RAISE L_DEF_CONTRACT_LINE;

        ELSIF   Lx_Ent_Contracts.COUNT > 1 THEN -- more than one indirect record for cp_ids of the system id

-- Sorts all the contract lines with highest importance level and then returns contract lines with highest
-- importance level


                Get_Sort_CSI_ImpLvl
                    (P_Contracts            => Lx_Ent_Contracts
                    ,X_Contracts_02         => Lx_Ent_Contracts2
                    ,X_Result               => Lx_Result
                    ,X_Return_Status   	    => Lx_Return_Status);


                IF Lx_Result <> G_TRUE THEN
                   RAISE L_EXCEP_UNEXPECTED_ERR;
                END IF;

                Lx_Ent_Contracts.DELETE;
                Lx_Ent_Contracts := Lx_Ent_Contracts2;
                Lx_Ent_Contracts2.DELETE;

                IF    Lx_Ent_Contracts.COUNT = 1 THEN -- one record with highest importance level

                        X_Ent_Contracts := Lx_Ent_Contracts(1);
                        RAISE L_DEF_CONTRACT_LINE;

                ELSIF  Lx_Ent_Contracts.COUNT >1 THEN -- more than one record with highest importance level
                                                      -- ; Tie exists

                      -- Gets all the contract lines with preferred groups

                        Get_CSI_KLine_PrefGrps
                            (P_Contracts            => Lx_Ent_Contracts
                            ,X_Contracts_02         => Lx_Ent_Contracts_01
                            ,X_Result               => Lx_Result
                            ,X_Return_Status   	    => Lx_Return_Status);


                        IF Lx_Result <> G_TRUE THEN
                            RAISE L_EXCEP_UNEXPECTED_ERR;
                        END IF;

                        Lx_Ent_Contracts.DELETE;

                        IF     Lx_Ent_Contracts_01.COUNT = 1 THEN -- one record with preferred group


                                X_Ent_Contracts := Lx_Ent_Contracts_01(1);
                                RAISE L_DEF_CONTRACT_LINE;

                        ELSIF  (Lx_Ent_Contracts_01.COUNT >1 )THEN -- more than one record or,
                                                                   -- no record with preferred group
                                                                   --   (the above proc. returns all); Tie exists

                           -- Getting contract lines  with latest end date

                                 Get_CSI_LatestEdDtdKLines_02
                                      (P_Input_Tab          => Lx_Ent_Contracts_01
                                      ,X_Output_Tab         => Lx_Ent_Contracts_02
                                      ,X_Result             => Lx_Result
                                      ,X_Return_Status      => Lx_Return_Status);


                                IF Lx_Result <> G_TRUE THEN
                                    RAISE L_EXCEP_UNEXPECTED_ERR;
                                END IF;


                                IF   Lx_Ent_Contracts_02.COUNT >= 1 THEN --only one contract line with same
                                                                        --latest end date ,
                                                                        -- in case,more than one contract line with
                                                                         --same latest end date; return first one

                                      X_Ent_Contracts := Lx_Ent_Contracts_02(1);
                                      RAISE L_DEF_CONTRACT_LINE;

 --                               ELSIF Lx_Ent_Contracts_02.COUNT > 1 THEN --more than one contract line with
                                                                         --same latest end date; Tie exists

  --                                    NULL;  -- Automatically goes to indirect lines logic

                                END IF; --line latest end date comparison ends

                        END IF; -- preferred group comparison ends

--              ELSIF  Lx_Ent_Contracts.COUNT =0 THEN -- no record with highest importance level  (probably N/A)
  --                      NULL;
                END IF; -- highest importance level comparison ends

--        ELSIF   Lx_Ent_Contracts.COUNT = 0 THEN -- no direct record for system id

--                NULL;  -- Automatically goes to indirect lines logic

        END IF;


  EXCEPTION

    WHEN L_DEF_CONTRACT_LINE THEN

        X_Return_Status    := G_RET_STS_SUCCESS;

    WHEN L_EXCEP_UNEXPECTED_ERR THEN

        X_Return_Status    := G_RET_STS_UNEXP_ERROR;

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
    	,P_Token2_Value   => 'Default_Contract_line_CSI');

        X_Return_Status    := G_RET_STS_UNEXP_ERROR;


  END Default_Contline_System;

    /*vgujarat - modified for access hour ER 9675504*/
  PROCEDURE Get_Cont02Format_Validation
    (P_Contracts            IN  Idx_Rec
    ,P_BusiProc_Id	        IN  Gx_BusProcess_Id
    ,P_Severity_Id	        IN  Gx_Severity_Id
    ,P_Request_TZone_Id	    IN  Gx_TimeZoneId
    ,P_Dates_In_Input_TZ    IN VARCHAR2    -- Added for 12.0 ENT-TZ project (JVARGHES)
    ,P_Incident_Date        IN  DATE       -- Added for 12.0 ENT-TZ project (JVARGHES)
    ,P_Request_Date         IN  DATE
    ,P_Request_Date_Start   IN  DATE
    ,P_Request_Date_End     IN  DATE
    ,P_Calc_RespTime_YN     IN  VARCHAR2
    ,P_Validate_Eff         IN  VARCHAR2
    ,P_Validate_Flag        IN  VARCHAR2
    ,P_SrvLine_Flag         IN  VARCHAR2
    ,P_Sort_Key             IN  VARCHAR2
    ,X_Contracts_02         out nocopy Get_ConTop_Tbl
    ,X_Result               out nocopy Gx_Boolean
    ,X_Return_Status   	    out nocopy Gx_Ret_Sts
    ,P_cust_id                  IN NUMBER DEFAULT NULL
    ,P_cust_site_id             IN NUMBER DEFAULT NULL
    ,P_cust_loc_id              IN NUMBER DEFAULT NULL) IS

--
-- Modified for 12.0 Coverage Rearch project (JVARGHES)
--
--
--   CURSOR Lx_Csr_CovItem(Cx_SrvLine_Id IN  Gx_OKS_Id) IS
--      SELECT Name
--	    ,Item_Description
--          ,Id Coverage_Line_Id
--          ,Start_Date CV_Start_Date
--	    ,Get_End_Date_Time(End_Date) Cv_End_Date
--          ,Get_End_Date_Time(Date_Terminated) CV_Date_Terminated
--       FROM  Okc_K_Lines_V
--      WHERE  Cle_Id = Cx_SrvLine_Id
--	AND  Lse_Id IN (2,15,20);
--
--
-- Added for 12.0 Coverage Rearch project (JVARGHES)
--
    CURSOR Lx_Csr_CovItem(Cx_SrvLine_Id IN  Gx_OKS_Id) IS
    SELECT CVL.Name
	    ,CVL.Item_Description
          ,CVL.Id Coverage_Line_Id
          ,CVL.Start_Date CV_Start_Date
	    ,Get_End_Date_Time(CVL.End_Date) Cv_End_Date
          ,Get_End_Date_Time(CVL.Date_Terminated) CV_Date_Terminated
          ,KSL.Standard_Cov_YN
       FROM  OKS_K_LINES_B KSL
            ,Okc_K_Lines_V CVL
      WHERE KSL.Cle_Id = Cx_SrvLine_Id
        AND KSL.Coverage_Id = CVL.Id
  	  AND CVL.Lse_Id IN (2,15,20);

--
--

-- replaced following cursor because of bug 3248293

    CURSOR Lx_Csr_SrvItem (Cx_SrvLine_Id In Gx_OKS_Id, Cn_Organization_Id IN NUMBER) IS
      SELECT mtl.concatenated_segments Name
            ,mtl.description Description
        FROM mtl_system_items_b_kfv mtl
            ,Okc_K_Items IT
       WHERE IT.Cle_Id = Cx_SrvLine_Id
         AND IT.Jtot_Object1_Code IN ('OKX_SERVICE','OKX_WARRANTY')
         AND mtl.inventory_item_id = IT.Object1_Id1
         AND mtl.organization_id = IT.Object1_Id2
         AND mtl.Service_Item_Flag = 'Y';
--         AND mtl.Organization_Id = Cn_Organization_Id;

--  The above validation "AND mtl.Organization_Id = Cn_Organization_Id"
--  in this cursor Lx_Csr_SrvItem  commented out . The fix is for bug 3248293.
--  it is possible to have ext. warranty lines having different inv_organization_id
--  than the contract header inv_organization_id

    Lx_Contracts             Idx_Rec;
    Ld_Request_Date          CONSTANT DATE := P_Request_Date;
    Ld_Request_Date_Start    CONSTANT DATE := P_Request_Date_Start;
    Ld_Request_Date_End      CONSTANT DATE := P_Request_Date_End;
    Lv_Validate_Flag         VARCHAR2(1);
    Lv_SrvLine_Flag          CONSTANT VARCHAR2(1) := P_SrvLine_Flag;
    Lv_Sort_Key              CONSTANT VARCHAR2(10):= P_Sort_Key;

    Lx_BusiProc_Id	         CONSTANT Gx_BusProcess_Id := P_BusiProc_Id;
    Lx_Severity_Id	         CONSTANT Gx_Severity_Id := P_Severity_Id;
    Lx_Request_TZone_Id	     CONSTANT Gx_TimeZoneId := P_Request_TZone_Id;
    Lv_Calc_RespTime_YN      CONSTANT VARCHAR2(1) := P_Calc_RespTime_YN;
    Lv_Validate_Eff          CONSTANT VARCHAR2(1) := P_Validate_Eff;
    Lv_Cont_Pty_Id           VARCHAR2(100);

    /*vgujarat - modified for access hour ER 9675504*/
    Lx_cust_id                 CONSTANT NUMBER              := P_cust_id;
    Lx_cust_site_id            CONSTANT NUMBER              := P_cust_site_id;
    Lx_cust_loc_id             CONSTANT NUMBER              := P_cust_loc_id;

    Lx_Contracts_02          Get_ConTop_Tbl;
    Lx_Contracts_02_Out      Get_ConTop_Tbl;

    Lx_Result                Gx_Boolean;
    Lx_Return_Status         Gx_Ret_Sts;
    Lx_Result1               Gx_Boolean;
    Lx_Return_Status1        Gx_Ret_Sts;
    Lx_Result2               Gx_Boolean;
    Lx_Return_Status2        Gx_Ret_Sts;
    Lx_Result3               Gx_Boolean;
    Lx_Return_Status3        Gx_Ret_Sts;

    Lx_Cov_Type_Code         Oks_Cov_Types_B.Code%TYPE;
    Lx_Cov_Type_Meaning      Oks_Cov_Types_TL.Meaning%TYPE;
    Lx_Cov_Type_Description  Oks_Cov_Types_TL.Description%TYPE;
    Lx_Cov_Type_Imp_Level    Oks_Cov_Types_B.Importance_Level%TYPE;

    Li_TableIdx              BINARY_INTEGER;
    Li_OutTab_Idx            BINARY_INTEGER;
    Lv_Entile_Flag           VARCHAR2(1);
    Lv_Effective_Falg        VARCHAR2(1);

    Lx_SrvLine_Id            Gx_OKS_Id;
    Lx_CovLvlLine_Id         Gx_OKS_Id;

    Ld_SRV_Eff_End_Date      DATE;
    Ld_COV_Eff_End_Date      DATE;
    Ld_CVL_Eff_End_Date      DATE;

    Lv_Srv_Name              VARCHAR2(300) ; --Okx_System_Items_V.Name%TYPE;            --VARCHAR2(150) ;
    Lv_Srv_Description       VARCHAR2(300) ; --Okx_System_Items_V.Description%TYPE;     --VARCHAR2(1995);
    Lv_Prof_Srv_Name         VARCHAR2(300) ;
    Lv_Prof_Srv_Desc         VARCHAR2(300);

    Lv_Cov_Name              Okc_K_Lines_V.Name%TYPE;                 --VARCHAR2(150) ;
    Lv_Cov_Description       Okc_K_Lines_V.Item_Description%TYPE;     --VARCHAR2(1995);

    Lx_React_Durn	         Gx_ReactDurn;
    Lx_React_UOM 	         Gx_ReactUOM;
    Lv_React_Day             VARCHAR2(20);
    Ld_React_By_DateTime     DATE;
    Ld_React_Start_DateTime  DATE;

    Lx_Resln_Durn	         Gx_ReactDurn;
    Lx_Resln_UOM 	         Gx_ReactUOM;
    Lv_Resln_Day             VARCHAR2(20);
    Ld_Resln_By_DateTime     DATE;
    Ld_Resln_Start_DateTime  DATE;

    Ln_Msg_Count	         NUMBER;
    Lv_Msg_Data		         VARCHAR2(2000);

    Lv_RCN_RSN_Flag          VARCHAR2(10);
    Lb_RSN_CTXT_Exists       BOOLEAN;

    Lx_CovLine_Id            Gx_OKS_Id;
    Ld_Cov_StDate            DATE;
    Ld_Cov_EdDate            DATE;
    Ld_Cov_TnDate            DATE;
    Lv_Cov_Check             VARCHAR2(1);

    Lv_Prof_Name             CONSTANT VARCHAR2(300) := 'OKS_ITEM_DISPLAY_PREFERENCE';
    Lv_Prof_Value            VARCHAR2(300);
    Lx_Service_PO            VARCHAR2(450);
    Lx_Service_PO_Required   VARCHAR2(450);

    L_EXCEP_UNEXPECTED_ERR   EXCEPTION;

    -- Added for 12.0 ENT-TZ project (JVARGHES)

    Ld_Incident_Date        DATE;
    Ld_Reported_Date        DATE;
    Lv_Dates_In_Input_TZ    VARCHAR2(1);

    --
    -- Modified for 12.0 Coverage Rearch project (JVARGHES)
    --

    Lv_Standard_Cov_YN      VARCHAR2(10);

    --

  BEGIN


    Lx_Contracts             := P_Contracts;
    Lv_Validate_Flag         := P_Validate_Flag;
    Lx_Result                := G_TRUE;
    Lx_Return_Status         := G_RET_STS_SUCCESS;
    Lx_Result1               := G_TRUE;
    Lx_Return_Status1        := G_RET_STS_SUCCESS;
    Lx_Result2               := G_TRUE;
    Lx_Return_Status2        := G_RET_STS_SUCCESS;
    Lx_Result3               := G_TRUE;
    Lx_Return_Status3        := G_RET_STS_SUCCESS;
    Li_OutTab_Idx            := 0;


   -- Added for 12.0 ENT-TZ project (JVARGHES)

   Ld_Incident_Date          := NVL(p_Incident_Date,Ld_Request_Date);
   Ld_Reported_Date          := Ld_Request_Date;
   Lv_Dates_In_Input_TZ      := P_Dates_In_Input_TZ;

   --

-- 11.5.10 --no more check required if RSN rule exists as rules architecture no more exist in 11.5.10

--    Lb_RSN_CTXT_Exists  := FND_FLEX_DSC_API.CONTEXT_EXISTS('OKS','OKS Rule Developer DF','RSN');
    ---
    FND_PROFILE.Get(Lv_Prof_Name, Lv_Prof_Value);
    ---

    IF Lv_Validate_Flag = 'Y' THEN
       Lv_Validate_Flag := 'T';
    END IF;
    ---

--    IF Lb_RSN_CTXT_Exists THEN
      Lv_RCN_RSN_Flag   := G_RUL_CATEGORY_REACT_RESOLVE;
--    ELSE
--      Lv_RCN_RSN_Flag   := G_RUL_CATEGORY_REACTION;
--    END IF;

        --
        -- Modified for 12.0 Coverage Rearch project (JVARGHES)
        --

        OPEN Lx_Csr_CovItem(Lx_Contracts.Service_Line_Id);
        FETCH Lx_Csr_CovItem INTO Lv_Cov_Name,Lv_Cov_Description,Lx_CovLine_Id
                                  ,Ld_Cov_StDate,Ld_Cov_EdDate,Ld_Cov_TnDate, Lv_Standard_Cov_YN;

        --
        --

        IF Lx_Csr_CovItem%NOTFOUND THEN
          Lv_Cov_Check := 'N';
        ELSE
          Lv_Cov_Check := 'Y';
        END IF;

        CLOSE Lx_Csr_CovItem;

        --
        -- Added for 12.0 Coverage Rearch project (JVARGHES)
        --

        IF Lv_Standard_Cov_YN = 'Y'
        THEN
          Ld_Cov_StDate := Lx_Contracts.Sv_Start_Date;
          Ld_Cov_EdDate := Lx_Contracts.Sv_End_Date;
          Ld_Cov_TnDate := Lx_Contracts.SV_Date_Terminated;
        END IF;

        --
        --
        --

        IF Lv_Validate_Eff = 'T' THEN

          IF Lx_Contracts.SV_Date_Terminated < Lx_Contracts.Sv_End_Date THEN
            Ld_SRV_Eff_End_Date := Lx_Contracts.SV_Date_Terminated;
          ELSE
            Ld_SRV_Eff_End_Date := Lx_Contracts.Sv_End_Date;

      -- grace period changes starts

            IF G_GRACE_PROFILE_SET = 'Y' AND Lx_Contracts.SV_Date_Terminated IS NULL THEN
-- grace period changes are done only if line end date matches contract end date

              G_CONTRACT_END_DATE := Lx_Contracts.HDR_End_Date;
              G_CONTRACT_ID       := Lx_Contracts.Contract_Id;

              IF  trunc(Ld_SRV_Eff_End_Date) = trunc(Lx_Contracts.HDR_End_Date) THEN
                Ld_SRV_Eff_End_Date := Get_Final_End_Date(Lx_Contracts.Contract_Id,Ld_SRV_Eff_End_Date);
              END IF;

            END IF;

      -- grace period changes ends
          END IF;

          IF Ld_Cov_TnDate < Ld_Cov_EdDate THEN
            Ld_COV_Eff_End_Date := Ld_Cov_TnDate;
          ELSE
            Ld_COV_Eff_End_Date := Ld_Cov_EdDate;

      -- grace period changes starts

            IF G_GRACE_PROFILE_SET = 'Y' AND Ld_COV_TnDate IS NULL THEN
-- grace period changes are done only if line end date matches contract end date

              G_CONTRACT_END_DATE := Lx_Contracts.HDR_End_Date;
              G_CONTRACT_ID       := Lx_Contracts.Contract_Id;

              IF  trunc(Ld_COV_Eff_End_Date) = trunc(Lx_Contracts.HDR_End_Date) THEN
                  Ld_COV_Eff_End_Date := Get_Final_End_Date(Lx_Contracts.Contract_Id,Ld_COV_Eff_End_Date);
              END IF;

            END IF;

      -- grace period changes ends
          END IF;

          IF Lx_Contracts.CL_Date_Terminated < Lx_Contracts.CL_End_Date THEN
            Ld_CVL_Eff_End_Date := Lx_Contracts.CL_Date_Terminated;
          ELSE
            Ld_CVL_Eff_End_Date := Lx_Contracts.CL_End_Date;

      -- grace period changes starts

            IF G_GRACE_PROFILE_SET = 'Y' AND Lx_Contracts.CL_Date_Terminated IS NULL THEN
-- grace period changes are done only if line end date matches contract end date

              G_CONTRACT_END_DATE := Lx_Contracts.HDR_End_Date;
              G_CONTRACT_ID       := Lx_Contracts.Contract_Id;

              IF  trunc(Ld_CVL_Eff_End_Date) = trunc(Lx_Contracts.HDR_End_Date) THEN
                  Ld_CVL_Eff_End_Date := Get_Final_End_Date(Lx_Contracts.Contract_Id,Ld_CVL_Eff_End_Date);
              END IF;

            END IF;

      -- grace period changes ends
          END IF;

--
--  Commented out for 12.0 ENT-TZ project (JVARGHES)
--
--          IF ((Ld_Request_Date BETWEEN Lx_Contracts.SV_Start_Date AND Ld_Srv_Eff_End_Date)
--             AND
--             ((Ld_Request_Date BETWEEN Ld_Cov_StDate AND Ld_Cov_Eff_End_Date) OR (Lv_Cov_Check = 'N'))
--             AND
--             (Ld_Request_Date BETWEEN Lx_Contracts.CL_Start_Date AND Ld_CVL_Eff_End_Date))
--                                                OR
--              ((Ld_Request_Date_Start BETWEEN Lx_Contracts.SV_Start_Date AND Ld_Srv_Eff_End_Date)
--             AND
--             ((Ld_Request_Date_Start BETWEEN Ld_Cov_StDate AND Ld_Cov_Eff_End_Date) OR (Lv_Cov_Check = 'N'))
--             AND
--             (Ld_Request_Date_Start BETWEEN Lx_Contracts.CL_Start_Date AND Ld_CVL_Eff_End_Date))
--                                                OR
--              ((Ld_Request_Date_End BETWEEN Lx_Contracts.SV_Start_Date AND Ld_Srv_Eff_End_Date)
--             AND
--             ((Ld_Request_Date_End BETWEEN Ld_Cov_StDate AND Ld_Cov_Eff_End_Date) OR (Lv_Cov_Check = 'N'))
--             AND
--             (Ld_Request_Date_End BETWEEN Lx_Contracts.CL_Start_Date AND Ld_CVL_Eff_End_Date))
--          THEN
--            Lv_Effective_Falg := 'T';
--          ELSE
--            Lv_Effective_Falg := 'F';
--          END IF;
--
--
-- Added for 12.0 ENT-TZ project (JVARGHES)
--
         IF ((Ld_Incident_Date BETWEEN Lx_Contracts.SV_Start_Date AND Ld_Srv_Eff_End_Date)
             AND
             ((Ld_Incident_Date BETWEEN Ld_Cov_StDate AND Ld_Cov_Eff_End_Date) OR (Lv_Cov_Check = 'N'))
             AND
             (Ld_Incident_Date BETWEEN Lx_Contracts.CL_Start_Date AND Ld_CVL_Eff_End_Date))
                                                OR
	     -- Added by Jvorugan for Bug:5174820
          -- Added by Jvorugan for Bug:5174820
	   ((Ld_Request_Date_Start <= Lx_Contracts.SV_Start_Date AND Ld_Request_Date_End >= Ld_Srv_Eff_End_Date)
             AND
             ((Ld_Request_Date_Start <= Ld_Cov_StDate AND Ld_Request_Date_End >= Ld_Cov_Eff_End_Date) OR (Lv_Cov_Check = 'N'))
             AND
             (Ld_Request_Date_Start <= Lx_Contracts.CL_Start_Date AND Ld_Request_Date_End >= Ld_CVL_Eff_End_Date))

	 -- End of changes by Jvorugan
       /*  Commented by Jvorugan for Bug:5174820
           ((Ld_Request_Date_Start BETWEEN Lx_Contracts.SV_Start_Date AND Ld_Srv_Eff_End_Date)
             AND
             ((Ld_Request_Date_Start BETWEEN Ld_Cov_StDate AND Ld_Cov_Eff_End_Date) OR (Lv_Cov_Check = 'N'))
             AND
             (Ld_Request_Date_Start BETWEEN Lx_Contracts.CL_Start_Date AND Ld_CVL_Eff_End_Date))
                                                OR
              ((Ld_Request_Date_End BETWEEN Lx_Contracts.SV_Start_Date AND Ld_Srv_Eff_End_Date)
             AND
             ((Ld_Request_Date_End BETWEEN Ld_Cov_StDate AND Ld_Cov_Eff_End_Date) OR (Lv_Cov_Check = 'N'))
             AND
             (Ld_Request_Date_End BETWEEN Lx_Contracts.CL_Start_Date AND Ld_CVL_Eff_End_Date))   */
          THEN
            Lv_Effective_Falg := 'T';
          ELSE
            Lv_Effective_Falg := 'F';
          END IF;
--
        ELSE
          Lv_Effective_Falg := 'T';
        END IF;


        Lv_Entile_Flag := OKC_ASSENT_PUB.LINE_OPERATION_ALLOWED(Lx_Contracts.Service_Line_Id, 'ENTITLE');

        IF (Lv_Validate_Flag = 'T' AND Lv_Effective_Falg = 'T' AND Lv_Entile_Flag = 'T') OR (Lv_Validate_Flag <> 'T') THEN

          OPEN Lx_Csr_SrvItem (Lx_Contracts.Service_Line_Id, Lx_Contracts.Inv_Organization_Id);
          FETCH Lx_Csr_SrvItem INTO Lv_Srv_Name, Lv_Srv_Description;
          CLOSE Lx_Csr_SrvItem;

-- commented because of bug 3248293. no more name and description swapping needed.

/*
          Get_Prof_Service_Name_And_Desc
            (P_Profile_Value    => Lv_Prof_Value
            ,P_Db_Srv_Name      => Lv_Srv_Name
            ,P_Db_Srv_Desc      => Lv_Srv_Description
            ,X_Prof_Srv_Name    => Lv_Prof_Srv_Name
            ,X_Prof_Srv_Desc    => Lv_Prof_Srv_Desc
            ,X_Result           => Lx_Result3
            ,X_Return_Status   	=> Lx_Return_Status3);

          IF Lx_Return_Status3 = G_RET_STS_UNEXP_ERROR THEN
            RAISE L_EXCEP_UNEXPECTED_ERR;
          END IF;
*/

          Li_OutTab_Idx := Li_OutTab_Idx + 1;

          Lx_Contracts_02(Li_OutTab_Idx).Contract_Id                 := Lx_Contracts.Contract_Id;
          Lx_Contracts_02(Li_OutTab_Idx).Contract_Number             := Lx_Contracts.Contract_Number;
          Lx_Contracts_02(Li_OutTab_Idx).Contract_Number_Modifier    := Lx_Contracts.Contract_Number_Modifier;
     --   Lx_Contracts_02(Li_OutTab_Idx).Sts_code                    := Lx_Contracts.Sts_code;
          Lx_Contracts_02(Li_OutTab_Idx).Sts_code                    := Lx_Contracts.CL_Sts_code;
          Lx_Contracts_02(Li_OutTab_Idx).Service_Line_Id             := Lx_Contracts.Service_Line_Id;

-- replaced because of bug 3248293

          Lx_Contracts_02(Li_OutTab_Idx).Service_Name                := Lv_Srv_Name; --Lv_Prof_Srv_Name;
          Lx_Contracts_02(Li_OutTab_Idx).Service_Description         := Lv_Srv_Description; --Lv_Prof_Srv_Desc;

     --   Lx_Contracts_02(Li_OutTab_Idx).Service_Start_Date          := Lx_Contracts.SV_Start_Date;
     --   Lx_Contracts_02(Li_OutTab_Idx).Service_End_Date            := Lx_Contracts.SV_End_Date;
          Lx_Contracts_02(Li_OutTab_Idx).Service_Start_Date          := Lx_Contracts.CL_Start_Date;
          Lx_Contracts_02(Li_OutTab_Idx).Service_End_Date            := Lx_Contracts.CL_End_Date;
          Lx_Contracts_02(Li_OutTab_Idx).Coverage_Term_Line_Id       := Lx_CovLine_Id;
          Lx_Contracts_02(Li_OutTab_Idx).Coverage_Term_Name          := Lv_Cov_Name;
          Lx_Contracts_02(Li_OutTab_Idx).Coverage_Term_Description   := Lv_Cov_Description;
          Lx_Contracts_02(Li_OutTab_Idx).Warranty_Flag               := Lx_Contracts.Warranty_Flag;
          Lx_Contracts_02(Li_OutTab_Idx).Eligible_For_Entitlement    := Lv_Entile_Flag;
          Lx_Contracts_02(Li_OutTab_Idx).date_terminated	         := Lx_Contracts.cl_date_terminated; --Lx_Contracts.sv_date_terminated;
          Lx_Contracts_02(Li_OutTab_Idx).PM_Program_Id	             := Lx_Contracts.PM_Program_Id;
          Lx_Contracts_02(Li_OutTab_Idx).PM_Schedule_Exists	         := Lx_Contracts.PM_Schedule_Exists;

          -- Added for 12.0 ENT-TZ project (JVARGHES)
          Lx_Contracts_02(Li_OutTab_Idx).CovLvl_Line_Id              := Lx_Contracts.CovLvl_Line_Id;
          --

--dbms_output.put_line('Value of Lv_Calc_RespTime_YN='||Lv_Calc_RespTime_YN);
          IF Lv_Calc_RespTime_YN = 'Y' THEN
            /*vgujarat - modified for access hour ER 9675504*/
            Get_ReactResol_By_DateTime
              (P_API_Version		=> 1.0
              ,P_Init_Msg_List	        => 'F'
              ,P_SVL_Id	                => Lx_Contracts.Service_Line_Id
              ,P_BusiProc_Id	        => Lx_BusiProc_Id
              ,P_Severity_Id	        => Lx_Severity_Id
          --  ,P_Request_Date	        => Ld_Request_Date
              ,P_Request_Date	        => Ld_Reported_Date      -- Added for 12.0 ENT-TZ project (JVARGHES)
              ,P_Request_TZone_Id     => Lx_Request_TZone_Id
	        ,P_Dates_In_Input_TZ    => Lv_Dates_In_Input_TZ  -- Added for 12.0 ENT-TZ project (JVARGHES)
              ,P_template_YN            => 'N'
              ,P_Option                 => G_FIRST
              ,P_Rcn_Rsn_Flag           => Lv_RCN_RSN_Flag
              ,P_Set_ExcepionStack      => G_FALSE
              ,X_React_Durn	            => Lx_React_Durn
              ,X_React_UOM 	            => Lx_React_UOM
              ,X_React_Day              => Lv_React_Day
              ,X_React_By_DateTime      => Ld_React_By_DateTime
              ,X_React_Start_DateTime   => Ld_React_Start_DateTime
              ,X_Resolve_Durn	        => Lx_Resln_Durn
              ,X_Resolve_UOM 	        => Lx_Resln_UOM
              ,X_Resolve_Day            => Lv_Resln_Day
              ,X_Resolve_By_DateTime    => Ld_Resln_By_DateTime
              ,X_Resolve_Start_DateTime => Ld_Resln_Start_DateTime
              ,X_Msg_count		        => Ln_Msg_Count
              ,X_Msg_Data		        => Lv_Msg_Data
              ,X_Result                 => Lx_Result1
              ,X_Return_Status          => Lx_Return_Status1
              ,P_cust_id                => Lx_cust_id        --access hour
              ,P_cust_site_id           => Lx_cust_site_id   --access hour
              ,P_cust_loc_id            => Lx_cust_loc_id);  --access hour

            IF Lx_Return_Status1 = G_RET_STS_UNEXP_ERROR THEN
              RAISE L_EXCEP_UNEXPECTED_ERR;
            END IF;

            Lx_Contracts_02(Li_OutTab_Idx).Exp_Reaction_Time      :=  Ld_React_By_DateTime;

            -->> Included for backward compatibility of this API
            -- no more backward compatibility required for 11.5.10 onwards so resolution time will always be assigned
            -- resolution time
/*
            IF Lb_RSN_CTXT_Exists THEN
              Lx_Contracts_02(Li_OutTab_Idx).Exp_Resolution_Time  :=  Ld_Resln_By_DateTime;
            ELSE
              Lx_Contracts_02(Li_OutTab_Idx).Exp_Resolution_Time  :=  Ld_React_By_DateTime;
            END IF;
*/
            Lx_Contracts_02(Li_OutTab_Idx).Exp_Resolution_Time  :=  Ld_Resln_By_DateTime;
            --<< Included for backward compatibility of this API

            Lx_Contracts_02(Li_OutTab_Idx).Status_Code            :=  Lx_Return_Status1;
            Lx_Contracts_02(Li_OutTab_Idx).Status_Text            :=  Lv_Msg_Data;

            --<<Following only applicable for Service Request API.
            ----That is the reason this code is placed in this IF statement

            Get_Coverage_Type_Attribs
              (P_CVL_Id                => Lx_CovLine_Id
              ,P_Set_ExcepionStack     => G_FALSE
              ,X_Cov_Type_Code         => Lx_Cov_Type_Code
              ,X_Cov_Type_Meaning      => Lx_Cov_Type_Meaning
              ,X_Cov_Type_Description  => Lx_Cov_Type_Description
              ,X_Cov_Type_Imp_Level    => Lx_Cov_Type_Imp_Level
              ,X_Result                => Lx_Result2
              ,X_Return_Status         => Lx_Return_Status2);

            IF Lx_Return_Status2 = G_RET_STS_UNEXP_ERROR THEN
              RAISE L_EXCEP_UNEXPECTED_ERR;
            END IF;

            Lx_Contracts_02(Li_OutTab_Idx).Coverage_Type_Code      :=  Lx_Cov_Type_Code;
            Lx_Contracts_02(Li_OutTab_Idx).Coverage_Type_Meaning   :=  Lx_Cov_Type_Meaning;
            Lx_Contracts_02(Li_OutTab_Idx).coverage_Type_Imp_Level :=  Lx_Cov_Type_Imp_Level;

            ----End for Service Request.>>

          END IF;

-- addition for "getting coverage type and importance level even if calculate response time is not required" starts

          IF (Lv_Calc_RespTime_YN = 'N') AND (Lv_Sort_Key = 'COVTYP_IMP') THEN --

           Get_Coverage_Type_Attribs
              (P_CVL_Id                => Lx_CovLine_Id
              ,P_Set_ExcepionStack     => G_FALSE
              ,X_Cov_Type_Code         => Lx_Cov_Type_Code
              ,X_Cov_Type_Meaning      => Lx_Cov_Type_Meaning
              ,X_Cov_Type_Description  => Lx_Cov_Type_Description
              ,X_Cov_Type_Imp_Level    => Lx_Cov_Type_Imp_Level
              ,X_Result                => Lx_Result2
              ,X_Return_Status         => Lx_Return_Status2);

            IF Lx_Return_Status2 = G_RET_STS_UNEXP_ERROR THEN
              RAISE L_EXCEP_UNEXPECTED_ERR;
            END IF;

            Lx_Contracts_02(Li_OutTab_Idx).Coverage_Type_Code      :=  Lx_Cov_Type_Code;
            Lx_Contracts_02(Li_OutTab_Idx).Coverage_Type_Meaning   :=  Lx_Cov_Type_Meaning;
            Lx_Contracts_02(Li_OutTab_Idx).coverage_Type_Imp_Level :=  Lx_Cov_Type_Imp_Level;
          END IF;

-- addition for "getting coverage type and importance level even if calculate response time is not required" ends

          Get_Service_PO
              (P_CHR_Id                => Lx_Contracts.Contract_Id
              ,P_Set_ExcepionStack     => G_FALSE
              ,X_Service_PO            => Lx_Service_PO
              ,X_Service_PO_Required   => Lx_Service_PO_Required
              ,X_Result                => Lx_Result
              ,X_Return_Status         => Lx_Return_Status);

            IF Lx_Return_Status = G_RET_STS_UNEXP_ERROR THEN
              RAISE L_EXCEP_UNEXPECTED_ERR;
            END IF;

            Lx_Contracts_02(Li_OutTab_Idx).service_PO_number            :=  Lx_Service_PO;
            Lx_Contracts_02(Li_OutTab_Idx).service_PO_required_flag     :=  Lx_Service_PO_Required;

        END IF;

        X_Contracts_02        := Lx_Contracts_02;
        X_Result              := Lx_Result;
        X_Return_Status       := Lx_Return_Status;

  EXCEPTION

    WHEN L_EXCEP_UNEXPECTED_ERR THEN

        X_Return_Status    := G_RET_STS_UNEXP_ERROR;

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
    	,P_Token2_Value   => 'Get_Cont02Format_Validation');

        X_Return_Status    := G_RET_STS_UNEXP_ERROR;

END Get_Cont02Format_Validation;

PROCEDURE Get_cov_txn_groups
    (p_api_version		IN  Number
	,p_init_msg_list		IN  Varchar2
	,p_inp_rec_bp		IN  INP_REC_BP
	,x_return_status 	OUT NOCOPY Varchar2
	,x_msg_count		OUT NOCOPY Number
	,x_msg_data			OUT NOCOPY Varchar2
	,x_cov_txn_grp_lines	OUT NOCOPY OUTPUT_TBL_BP)
IS

--
-- Modified for 12.0 Coverage Rearch project (JVARGHES)
--
--    CURSOR cur_bp (p_line_id in number,p_chk_def in varchar2,p_sr_enabled varchar2,p_dr_enabled varchar2,p_fs_enabled varchar2) is
--        select 	lines2.id id,
--            	lines2.start_date start_date,
--                lines2.end_date end_date,
--            	to_number(items.object1_id1) object1_id1 ,
--                lines2.dnz_chr_id
--        from    okc_k_lines_v lines,
--                okc_k_lines_v lines2,
--                okc_k_items items,
--                cs_business_processes bp
--        where   lines.cle_id        = p_line_id
--        and     lines.id            = lines2.cle_id
--        and     lines.lse_id        in (2,15,20)
--        and     lines2.id           = items.cle_id
--        and     lines2.lse_id       in (3,16,21)
--        and     items.object1_id1   = bp.business_process_id
--        and     items.object1_id2   = '#'
--        and     items.jtot_object1_code     = 'OKX_BUSIPROC'
--        and     bp.service_request_flag     =
--				decode(p_chk_def,'Y',
--				decode(p_sr_enabled,null,bp.service_request_flag,p_sr_enabled),
--				bp.service_request_flag)
--        and     bp.depot_repair_flag        =
--				decode(p_chk_def,'Y',
--				decode(p_dr_enabled,null,bp.depot_repair_flag,p_dr_enabled),
--				bp.depot_repair_flag)
--        and     bp.field_service_flag       =
--				decode(p_chk_def,'Y',
--				decode(p_fs_enabled,null,bp.field_service_flag,p_fs_enabled),
--				bp.field_service_flag);
--
--
-- Modified for 12.0 Coverage Rearch project (JVARGHES)
--
--
    CURSOR cur_bp (p_line_id in number,p_chk_def in varchar2,p_sr_enabled varchar2
                  ,p_dr_enabled IN varchar2,p_fs_enabled IN varchar2) is
        select  lines2.id id,
                decode(ksl.Standard_Cov_YN, 'Y',lines.start_date,lines2.start_date) start_date,
                decode(ksl.Standard_Cov_YN, 'Y',lines.end_date,lines2.end_date) end_date,
                to_number(items.object1_id1) object1_id1,
                lines.dnz_chr_id,
                ksl.Standard_Cov_YN Standard_Cov_YN
        from    okc_k_lines_b lines,
                oks_k_lines_b KSL,
                okc_k_lines_v lines2,
                okc_k_items items,
                cs_business_processes bp
        where   lines.id           = p_line_id
        and     lines.lse_id in (1,14,19)
        and     KSL.cle_id         = lines.id
        and     KSL.Coverage_Id    = lines2.cle_Id
        and     lines2.id           = items.cle_id
        and     lines2.lse_id       in (3,16,21)
        and     items.object1_id1   = bp.business_process_id
        and     items.object1_id2   = '#'
        and     items.jtot_object1_code     = 'OKX_BUSIPROC'
        and     bp.service_request_flag     =
				decode(p_chk_def,'Y',
				decode(p_sr_enabled,null,bp.service_request_flag,p_sr_enabled),
				bp.service_request_flag)
        and     bp.depot_repair_flag        =
				decode(p_chk_def,'Y',
				decode(p_dr_enabled,null,bp.depot_repair_flag,p_dr_enabled),
				bp.depot_repair_flag)
        and     bp.field_service_flag       =
				decode(p_chk_def,'Y',
				decode(p_fs_enabled,null,bp.field_service_flag,p_fs_enabled),
				bp.field_service_flag);

--
--

    CURSOR cur_hdr (p_line_id in number) is
        select  hdr.id id,
                hdr.start_date start_date,
                hdr.end_date  end_date
        from    OKC_K_HEADERS_ALL_B hdr, --,OKC_K_HEADERS_B HDR  -- Modified for 12.0 MOAC project (JVARGHES)
                okc_k_lines_v lines
        where   lines.chr_id = hdr.id
        and     lines.dnz_chr_id = hdr.id
        and     lines.id = p_line_id;

    G_CONTRACT_END_DATE             date;
    G_CONTRACT_ID                   number;
    G_GRACE_PROFILE_SET             varchar2(1);

    p_id                            number;
    p_bp_id                         number;
    i                               number;

    HDR                             cur_hdr%rowtype;

    Lx_Result                       Gx_Boolean;
    Lx_Return_Status                Gx_Ret_Sts;

    -- Added for 12.0 Coverage Rearch project (JVARGHES)

    Lv_Std_Cov_YN              VARCHAR2(10);

    Ld_BPL_Start_Date	       DATE;
    Ln_BPL_OFS_Duration	       NUMBER;
    Lv_BPL_OFS_UOM             VARCHAR2(100);

    L_EXCEP_NO_DATA_FOUND    EXCEPTION;
   --

BEGIN

    G_GRACE_PROFILE_SET             := NULL;
    i                               := 0;
    Lx_Result                       := G_TRUE;
    Lx_Return_Status                := G_RET_STS_SUCCESS;

    OKS_ENTITLEMENTS_PVT.G_GRACE_PROFILE_SET := fnd_profile.value('OKS_ENABLE_GRACE_PERIOD');

	IF OKS_ENTITLEMENTS_PVT.G_GRACE_PROFILE_SET = 'Y' THEN
	  FOR Hdr_rec in  cur_hdr (p_inp_rec_bp.contract_line_id) LOOP
	      HDR := Hdr_rec;
	  END LOOP;
	END IF;

	FOR l_bp_out in cur_bp(p_inp_rec_bp.contract_line_id,p_inp_rec_bp.check_bp_def,
                        p_inp_rec_bp.sr_enabled,p_inp_rec_bp.dr_enabled,p_inp_rec_bp.fs_enabled) LOOP

     --
     -- Modified for 12.0 Coverage Rearch project (JVARGHES)
     --

      IF l_bp_out.Standard_Cov_YN = 'Y'
      THEN

        Get_BP_Line_Start_Offset
         (P_BPL_Id	        => l_bp_out.Id
         ,P_SVL_Start	        => l_bp_out.Start_date
         ,X_BPL_OFS_Start	  => Ld_BPL_Start_date
         ,X_BPL_OFS_Duration	  => Ln_BPL_OFS_Duration
         ,X_BPL_OFS_UOM	        => Lv_BPL_OFS_UOM
         ,X_Return_Status 	  => Lx_Return_Status);

        IF Lx_Return_Status<> G_RET_STS_SUCCESS  THEN
          RAISE L_EXCEP_NO_DATA_FOUND;
        END IF;

      ELSE

        Ld_BPL_Start_date  := l_bp_out.Start_date;

      END IF;

      --
      --

    	i := i + 1;
    	x_cov_txn_grp_lines(i).cov_txn_grp_line_id := l_bp_out.id;
	    x_cov_txn_grp_lines(i).bp_id               := l_bp_out.object1_id1;

   --	x_cov_txn_grp_lines(i).start_date          := l_bp_out.start_date;  -- Modified for 12.0 Coverage Rearch project (JVARGHES)
   	x_cov_txn_grp_lines(i).start_date          := Ld_BPL_Start_date;    -- Modified for 12.0 Coverage Rearch project (JVARGHES)


    	IF OKS_ENTITLEMENTS_PVT.G_GRACE_PROFILE_SET = 'Y' THEN
    		  IF (trunc(HDR.end_date) = trunc(l_bp_out.end_date)) then
		       	x_cov_txn_grp_lines(i).end_date := OKS_ENTITLEMENTS_PVT.Get_Final_End_Date(l_bp_out.dnz_chr_id,
                                                                                        l_bp_out.end_date);
    		  ELSE
	          	x_cov_txn_grp_lines(i).end_date := l_bp_out.end_date;
	       	  END IF;
        ELSE
    			x_cov_txn_grp_lines(i).end_date := l_bp_out.end_date;
        END IF;

	END LOOP;

        X_Return_Status   := Lx_Return_Status;

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
	,P_Token2_Value   => 'Get_cov_txn_groups');

     X_Return_Status     := G_RET_STS_UNEXP_ERROR;

END Get_cov_txn_groups;

PROCEDURE Get_txn_billing_types
    (p_api_version		IN  Number
	,p_init_msg_list		IN  Varchar2
	,p_cov_txngrp_line_id		IN  number
    ,p_return_bill_rates_YN   IN  Varchar2
	,x_return_status 		OUT NOCOPY Varchar2
	,x_msg_count		OUT NOCOPY Number
	,x_msg_data			OUT NOCOPY Varchar2
	,x_txn_bill_types		OUT NOCOPY output_tbl_bt
    ,x_txn_bill_rates   out nocopy output_tbl_br)
IS


cursor cur_bt (p_txn_grp_line_id in number) is
select  lines.id id,
        lines2.id bt_line_id,
        lines.start_date start_date,
        lines.end_date end_date ,
        items2.object1_id1 bt_object1_id1,
        items2.jtot_object1_code jtot_object1_code,
        okslines2.discount_amount, -- rul.rule_information2 rule_information2,
        okslines2.discount_percent -- rul.rule_information4 rule_information4
from    okc_k_lines_v lines,
        okc_k_lines_v lines2,
        okc_k_items items2,
        oks_k_lines_b okslines2
--        okc_rule_groups_b rgp,
--        okc_rules_b rul
where   lines.id     = p_txn_grp_line_id
and     lines.lse_id in (3,16,21)
and     lines2.cle_id = lines.id
and     lines2.id = items2.cle_id
and     lines2.lse_id in (5,23,59)
and     items2.jtot_object1_code = 'OKX_BILLTYPE'
and     lines2.id  = okslines2.cle_id;


cursor cur_br (p_bill_type_id in number) is
select oksbsch.BT_CLE_ID bt_line_id,
       oksbsch.CLE_ID br_line_id,
       oksbsch.ID br_schedule_id,
       oksbsch.BILL_RATE_CODE bill_rate,
       oksbsch.FLAT_RATE flat_rate,
       oksbsch.UOM uom,
       oksbsch.PERCENT_OVER_LIST_PRICE percent_over_list_price,
       oksbsch.START_HOUR start_hour,
       oksbsch.START_MINUTE start_minute,
       oksbsch.END_HOUR end_hour,
       oksbsch.END_MINUTE end_minute,
       oksbsch.MONDAY_FLAG monday_flag,
       oksbsch.TUESDAY_FLAG tuesday_flag,
       oksbsch.WEDNESDAY_FLAG wednesday_flag,
       oksbsch.THURSDAY_FLAG thursday_flag,
       oksbsch.FRIDAY_FLAG friday_flag,
       oksbsch.SATURDAY_FLAG saturday_flag,
       oksbsch.SUNDAY_FLAG sunday_flag,
       to_number(oksbsch.OBJECT1_ID2) labor_item_org_id,
       to_number(oksbsch.OBJECT1_ID1) labor_item_id,
       oksbsch.HOLIDAY_YN holiday_yn
from   okc_k_lines_v lines,
       okc_k_lines_v lines2,
       oks_billrate_schedules oksbsch
--       okc_rule_groups_v rgp,
--       okc_rules_b rules
where  lines.id = p_bill_type_id
and    lines.id = lines2.cle_id
and    lines2.id = oksbsch.cle_id;

   G_CONTRACT_END_DATE          date;
   G_CONTRACT_ID                number;

   p_id                         number;
   p_bp_id                      number;

   i                            number;
   j                            number;

   l_bp_object1_id1             number;
   l_bt_object1_id1             number;

   Lx_Result                    Gx_Boolean;
   Lx_Return_Status             Gx_Ret_Sts;


begin

   i                            := 0;
   j                            := 0;
   Lx_Result                    := G_TRUE;
   Lx_Return_Status             := G_RET_STS_SUCCESS;

  FOR bt_rec in cur_bt(p_cov_txngrp_line_id)
  LOOP
            i := i + 1;
            x_txn_bill_types(i).Txn_BT_line_id       := Bt_rec.bt_line_id;
            x_txn_bill_types(i).txn_bill_type_id     := Bt_rec.bt_object1_id1;
            x_txn_bill_types(i).Covered_upto_amount  := Bt_rec.discount_amount; --Bt_rec.rule_information2;
            x_txn_bill_types(i).percent_covered      := Bt_rec.discount_percent; --Bt_rec.rule_information4;

          if p_return_bill_rates_YN = 'Y' then

            FOR br_rec in cur_br(Bt_rec.bt_line_id)
            LOOP

                j:= j + 1;

                x_txn_bill_rates(j).BT_line_id                  := BR_rec.bt_line_id;
                x_txn_bill_rates(j).Br_line_id                  := BR_rec.br_line_id;
                x_txn_bill_rates(j).br_schedule_id              := BR_rec.br_schedule_id;
                x_txn_bill_rates(j).bill_rate                   := BR_rec.bill_rate;
                x_txn_bill_rates(j).flat_rate                   := BR_rec.flat_rate;
                x_txn_bill_rates(j).uom                         := BR_rec.uom;
                x_txn_bill_rates(j).percent_over_list_price     := BR_rec.percent_over_list_price;
                x_txn_bill_rates(j).start_hour                  := BR_rec.start_hour;
                x_txn_bill_rates(j).start_minute                := BR_rec.start_minute;
                x_txn_bill_rates(j).end_hour                    := BR_rec.end_hour;
                x_txn_bill_rates(j).end_minute                  := BR_rec.end_minute;
                x_txn_bill_rates(j).monday_flag                 := BR_rec.monday_flag;
                x_txn_bill_rates(j).tuesday_flag                := BR_rec.tuesday_flag;
                x_txn_bill_rates(j).wednesday_flag              := BR_rec.wednesday_flag;
                x_txn_bill_rates(j).thursday_flag               := BR_rec.thursday_flag;
                x_txn_bill_rates(j).friday_flag                 := BR_rec.friday_flag;
                x_txn_bill_rates(j).saturday_flag               := BR_rec.saturday_flag;
                x_txn_bill_rates(j).sunday_flag                 := BR_rec.sunday_flag;
                x_txn_bill_rates(j).labor_item_org_id           := BR_rec.labor_item_org_id;
                x_txn_bill_rates(j).labor_item_id               := BR_rec.labor_item_id;
                x_txn_bill_rates(j).holiday_yn                  := BR_rec.holiday_yn ;

            end loop;
          end if;
        end loop;

    X_Return_Status   := Lx_Return_Status;

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
	,P_Token2_Value   => 'Get_txn_billing_types');

   --  X_Result            := G_FALSE;
     X_Return_Status     := G_RET_STS_UNEXP_ERROR;

END Get_txn_billing_types;

PROCEDURE Search_Contracts_01_Format
    (P_Contracts            IN  GT_Contract_Ref
    ,P_Contract_rec	        IN  inp_cont_rec_type
    ,P_Request_Date         IN  DATE
    ,P_Contract_Id          IN  NUMBER
    ,P_Validate_Eff         IN  VARCHAR2
    ,P_Validate_Flag        IN  VARCHAR2
    ,P_SrvLine_Flag         IN  VARCHAR2
    ,P_Sort_Key             IN  VARCHAR2
    ,X_Contracts_02         out nocopy Output_Tbl_Contract
    ,X_Result               out nocopy Gx_Boolean
    ,X_Return_Status   	    out nocopy Gx_Ret_Sts)
  IS

    CURSOR Lx_Csr_Contracts(Cx_Chr_Id IN Gx_OKS_Id, Cx_SrvLine_Id IN Gx_OKS_Id
                           ,Cx_CovLvlLine_Id IN Gx_OKS_Id,Cv_Cont_Pty_Id IN VARCHAR2
                           ,Cx_Start_Date_From IN Date,Cx_Start_Date_To IN Date
                           ,Cx_End_Date_From IN Date,Cx_End_Date_To IN Date
                           ,Cx_Date_Terminated_From IN Date,Cx_Date_Terminated_To IN Date,
                           Cx_HD_Sts_Code IN VARCHAR2) IS
      SELECT HD.Id Contract_Id
     	    ,HD.Contract_Number
            ,HD.Contract_Number_Modifier
            ,HD.Sts_Code
            ,HD.Authoring_Org_Id
            ,HD.Inv_Organization_Id
            ,HD.End_Date HDR_End_Date --grace period changes
    	    ,SV.Id Service_Line_Id
            ,SV.Start_Date SV_Start_Date
	        ,Get_End_Date_Time(SV.End_Date) SV_End_Date
            ,Get_End_Date_Time(SV.Date_Terminated) SV_Date_Terminated
            ,CL.Sts_Code CL_Sts_Code
	        ,CL.Id CovLvl_Line_Id
            ,CL.Start_Date CL_Start_Date
	        ,Get_End_Date_Time(CL.End_Date) CL_End_Date
            ,Get_End_Date_Time(CL.Date_Terminated) CL_Date_Terminated
            ,DECODE(SV.Lse_Id, 14, 'Y', 15, 'Y', 16, 'Y', 17, 'Y', 18, 'Y', 'N') Warranty_Flag
            ,HD.Scs_Code Scs_Code
            ,HD.Estimated_Amount Estimated_Amount
            ,HD.Start_Date HD_Start_Date
	        ,HD.End_Date HD_End_Date
            ,HD.Date_Terminated HD_Date_Terminated
            ,HDT.Cognomen Cognomen  -- HD.Cognomen Cognomen -- Modified for 12.0 MOAC project (JVARGHES)
            ,HDT.short_description short_description -- HD.short_description  -- Modified for 12.0 MOAC project (JVARGHES)
            ,HD.currency_code HD_currency_code
            ,CAT.meaning HD_cat_meaning
            ,STS.meaning HD_sts_meaning
        FROM OKC_K_HEADERS_ALL_B HD   -- Modified for 12.0 MOAC project (JVARGHES)
            ,OKC_K_HEADERS_TL HDT     -- Okc_K_Headers_V HD   -- Modified for 12.0 MOAC project (JVARGHES)
            ,Okc_K_Lines_B SV
            ,Okc_K_Lines_B CL
            ,okc_subclasses_v CAT
            ,okc_statuses_v STS
       WHERE HD.Id = Cx_Chr_Id
         AND HD.Scs_Code IN ('SERVICE','WARRANTY')
         AND HDT.ID         = HD.ID                    -- Modified for 12.0 MOAC project (JVARGHES)
         AND HDT.LANGUAGE   = USERENV('LANG')          -- Modified for 12.0 MOAC project (JVARGHES)
         AND HD.Sts_code = STS.code
         AND HD.Scs_code = CAT.code
         AND HD.Id > -1
         AND HD.Template_YN <> 'Y'
         AND (trunc(HD.Start_Date) between
            nvl(trunc(Cx_Start_Date_From),nvl(trunc(Cx_Start_Date_To),trunc(HD.Start_Date))) and
            nvl(trunc(Cx_Start_Date_To),nvl(trunc(Cx_Start_Date_From),trunc(HD.Start_Date))))
         AND (trunc(HD.End_Date) between
            nvl(trunc(Cx_End_Date_From),nvl(trunc(Cx_End_Date_To),trunc(HD.End_Date))) and
            nvl(trunc(Cx_End_Date_To),nvl(trunc(Cx_End_Date_From),trunc(HD.End_Date))))
        AND ((trunc(HD.Date_Terminated) IS NULL)OR
         ((trunc(HD.Date_Terminated) between
            nvl(trunc(Cx_Date_Terminated_From),nvl(trunc(Cx_Date_Terminated_To),trunc(HD.Date_Terminated))) and
            nvl(trunc(Cx_Date_Terminated_To),nvl(trunc(Cx_Date_Terminated_From),trunc(HD.Date_Terminated))))))
         AND HD.Sts_code = nvl(Cx_HD_Sts_Code,HD.Sts_code)
         AND SV.Dnz_Chr_Id = HD.Id
         AND SV.Cle_Id IS NULL
         AND SV.Chr_Id = HD.Id
         AND SV.Lse_ID IN (1,14,19)
         AND SV.Id = NVL(Cx_SrvLine_Id,SV.Id)
         AND CL.Cle_Id = SV.Id
         AND CL.Lse_ID IN (7,8,9,10,11,35,18,25)
         AND CL.Id = NVL(Cx_CovLvlLine_Id, CL.Id)
         AND EXISTS   (SELECT '*'
                         FROM Okc_K_Party_Roles_B PR
                        WHERE PR.Chr_Id = HD.Id
                          AND PR.Cle_Id IS NULL
                          AND PR.Dnz_Chr_Id = HD.Id
                          AND PR.Object1_Id1 = Cv_Cont_Pty_Id
                          AND PR.Object1_Id2 = '#'
                          AND PR.Jtot_Object1_Code = 'OKX_PARTY'
                          AND PR.RLE_CODE <> 'VENDOR' );


    CURSOR Lx_Csr_Contracts1(Cx_Chr_Id IN Gx_OKS_Id,Cv_Cont_Pty_Id IN VARCHAR2
                           ,Cx_Start_Date_From IN Date,Cx_Start_Date_To IN Date
                           ,Cx_End_Date_From IN Date,Cx_End_Date_To IN Date
                           ,Cx_Date_Terminated_From IN Date,Cx_Date_Terminated_To IN Date,
                           Cx_HD_Sts_Code IN VARCHAR2) IS

      SELECT HD.Id Contract_Id
     	    ,HD.Contract_Number
            ,HD.Contract_Number_Modifier
            ,HD.Sts_Code
            ,HD.End_Date HDR_End_Date --grace period changes
    	    ,HD.Scs_Code Scs_Code
            ,HD.Estimated_Amount Estimated_Amount
            ,HD.Start_Date HD_Start_Date
	        ,HD.End_Date HD_End_Date
            ,HD.Date_Terminated HD_Date_Terminated
            ,HDT.Cognomen Cognomen  -- HD.Cognomen Cognomen -- Modified for 12.0 MOAC project (JVARGHES)
            ,HDT.short_description short_description -- HD.short_description  -- Modified for 12.0 MOAC project (JVARGHES)
            ,HD.currency_code HD_currency_code
            ,CAT.meaning HD_cat_meaning
            ,STS.meaning HD_sts_meaning
        FROM OKC_K_HEADERS_ALL_B HD   -- Modified for 12.0 MOAC project (JVARGHES)
            ,OKC_K_HEADERS_TL HDT     -- Okc_K_Headers_V HD   -- Modified for 12.0 MOAC project (JVARGHES)
            ,okc_subclasses_v CAT
            ,okc_statuses_v STS
       WHERE HD.Id = nvl(Cx_Chr_Id,HD.Id)
         AND HD.Scs_Code IN ('SERVICE','WARRANTY')
         AND HDT.ID         = HD.ID                    -- Modified for 12.0 MOAC project (JVARGHES)
         AND HDT.LANGUAGE   = USERENV('LANG')          -- Modified for 12.0 MOAC project (JVARGHES)
         AND HD.Sts_code = STS.code
         AND HD.Scs_code = CAT.code
         AND HD.Id > -1
         AND HD.Template_YN <> 'Y'
         AND (trunc(HD.Start_Date) between
            nvl(trunc(Cx_Start_Date_From),nvl(trunc(Cx_Start_Date_To),trunc(HD.Start_Date))) and
            nvl(trunc(Cx_Start_Date_To),nvl(trunc(Cx_Start_Date_From),trunc(HD.Start_Date))))
         AND (trunc(HD.End_Date) between
            nvl(trunc(Cx_End_Date_From),nvl(trunc(Cx_End_Date_To),trunc(HD.End_Date))) and
            nvl(trunc(Cx_End_Date_To),nvl(trunc(Cx_End_Date_From),trunc(HD.End_Date))))
         AND ((trunc(HD.Date_Terminated) IS NULL)OR
         ((trunc(HD.Date_Terminated) between
            nvl(trunc(Cx_Date_Terminated_From),nvl(trunc(Cx_Date_Terminated_To),trunc(HD.Date_Terminated))) and
            nvl(trunc(Cx_Date_Terminated_To),nvl(trunc(Cx_Date_Terminated_From),trunc(HD.Date_Terminated))))))
         AND HD.Sts_code = nvl(Cx_HD_Sts_Code,HD.Sts_code)
         AND EXISTS   (SELECT '*'
                         FROM Okc_K_Party_Roles_B PR
                        WHERE PR.Chr_Id = HD.Id
                          AND PR.Cle_Id IS NULL
                          AND PR.Dnz_Chr_Id = HD.Id
                          AND PR.Object1_Id1 = Cv_Cont_Pty_Id
                          AND PR.Object1_Id2 = '#'
                          AND PR.Jtot_Object1_Code = 'OKX_PARTY'
                          AND PR.RLE_CODE <> 'VENDOR' );

    Lx_Contracts             GT_Contract_Ref;
    Lx_Contract_rec          inp_cont_rec_type;
    Ld_Request_Date          CONSTANT DATE := nvl(P_Request_Date,sysdate);
    Lv_Contract_Id           NUMBER ;
    Lv_Validate_Flag         VARCHAR2(1);
    Lv_SrvLine_Flag          CONSTANT VARCHAR2(1) := P_SrvLine_Flag;
    Lv_Sort_Key              CONSTANT VARCHAR2(10):= P_Sort_Key;

    Lv_Validate_Eff          CONSTANT VARCHAR2(1) := P_Validate_Eff;
    Lv_Cont_Pty_Id           VARCHAR2(100);

    Lx_Contracts_02          Output_Tbl_Contract;
    Lx_Contracts_02_Out      Output_Tbl_Contract;
    Lx_Contracts_02_Val      Get_Contop_Tbl;

    Lx_Idx_Rec               Idx_Rec;

    Lx_Result                Gx_Boolean;
    Lx_Return_Status         Gx_Ret_Sts;
    Lx_Result1               Gx_Boolean;
    Lx_Return_Status1        Gx_Ret_Sts;
    Lx_Result2               Gx_Boolean;
    Lx_Return_Status2        Gx_Ret_Sts;
    Lx_Result3               Gx_Boolean;
    Lx_Return_Status3        Gx_Ret_Sts;

    Lx_Cov_Type_Code         Oks_Cov_Types_B.Code%TYPE;
    Lx_Cov_Type_Meaning      Oks_Cov_Types_TL.Meaning%TYPE;
    Lx_Cov_Type_Description  Oks_Cov_Types_TL.Description%TYPE;
    Lx_Cov_Type_Imp_Level    Oks_Cov_Types_B.Importance_Level%TYPE;

    Li_TableIdx              BINARY_INTEGER;
    Li_OutTab_Idx            BINARY_INTEGER;
    Lv_Entile_Flag           VARCHAR2(1);
    Lv_Effective_Falg        VARCHAR2(1);

    Lx_SrvLine_Id            Gx_OKS_Id;
    Lx_CovLvlLine_Id         Gx_OKS_Id;

    Ld_SRV_Eff_End_Date      DATE;
    Ld_COV_Eff_End_Date      DATE;
    Ld_CVL_Eff_End_Date      DATE;

    Lv_Srv_Name              Okx_System_Items_V.Name%TYPE;            --VARCHAR2(150) ;
    Lv_Srv_Description       Okx_System_Items_V.Description%TYPE;     --VARCHAR2(1995);
    Lv_Prof_Srv_Name         VARCHAR2(300) ;
    Lv_Prof_Srv_Desc         VARCHAR2(300);

    Lv_Cov_Name              Okc_K_Lines_V.Name%TYPE;                 --VARCHAR2(150) ;
    Lv_Cov_Description       Okc_K_Lines_V.Item_Description%TYPE;     --VARCHAR2(1995);

    Lx_React_Durn	     Gx_ReactDurn;
    Lx_React_UOM 	     Gx_ReactUOM;
    Lv_React_Day             VARCHAR2(20);
    Ld_React_By_DateTime     DATE;
    Ld_React_Start_DateTime  DATE;

    Lx_Resln_Durn	     Gx_ReactDurn;
    Lx_Resln_UOM 	     Gx_ReactUOM;
    Lv_Resln_Day             VARCHAR2(20);
    Ld_Resln_By_DateTime     DATE;
    Ld_Resln_Start_DateTime  DATE;

    Ln_Msg_Count	     NUMBER;
    Lv_Msg_Data		     VARCHAR2(2000);

    Lv_RCN_RSN_Flag          VARCHAR2(10);
    Lb_RSN_CTXT_Exists       BOOLEAN;

    Lx_CovLine_Id            Gx_OKS_Id;
    Ld_Cov_StDate            DATE;
    Ld_Cov_EdDate            DATE;
    Ld_Cov_TnDate            DATE;
    Lv_Cov_Check             VARCHAR2(1);

    Lx_Contract_Id           NUMBER;
    Lx_Valid_K               VARCHAR2(1);

    Lv_Prof_Name             CONSTANT VARCHAR2(300) := 'OKS_ITEM_DISPLAY_PREFERENCE';
    Lv_Prof_Value            VARCHAR2(300);

    L_EXCEP_UNEXPECTED_ERR   EXCEPTION;

  BEGIN

    Lx_Contracts             := P_Contracts;
    Lx_Contract_rec          := P_Contract_rec;
    Lv_Contract_Id           := P_Contract_Id;
    Lv_Validate_Flag         := P_Validate_Flag;
    Lx_Result                := G_TRUE;
    Lx_Return_Status         := G_RET_STS_SUCCESS;
    Lx_Result1               := G_TRUE;
    Lx_Return_Status1        := G_RET_STS_SUCCESS;
    Lx_Result2               := G_TRUE;
    Lx_Return_Status2        := G_RET_STS_SUCCESS;
    Lx_Result3               := G_TRUE;
    Lx_Return_Status3        := G_RET_STS_SUCCESS;
    Li_OutTab_Idx            := 0;
    Lx_Contract_Id           := -99999;
    Lx_Valid_K               := 'F';

    IF  Lx_Contracts.COUNT > 0 AND Lv_Validate_Flag = 'T' AND Lv_Validate_Eff = 'T' THEN

     Li_TableIdx  := Lx_Contracts.FIRST;

     WHILE Li_TableIdx IS NOT NULL LOOP

      IF Lv_SrvLine_Flag = 'T' THEN

        Lx_SrvLine_Id     := Lx_Contracts(Li_TableIdx).Rx_Cle_Id;
        Lx_CovLvlLine_Id  := NULL;

      ELSE

        Lx_SrvLine_Id     := NULL;
        Lx_CovLvlLine_Id  := Lx_Contracts(Li_TableIdx).Rx_Cle_Id;

      END IF;

      Lv_Cont_Pty_Id  := TO_CHAR(Lx_Contract_rec.Contract_Party_Id);

      FOR Idx IN Lx_Csr_Contracts(Lx_Contracts(Li_TableIdx).Rx_Chr_Id,Lx_SrvLine_Id,Lx_CovLvlLine_Id,Lv_Cont_Pty_Id
                                 ,Lx_Contract_rec.Start_Date_From,Lx_Contract_rec.Start_Date_To
                                 ,Lx_Contract_rec.End_Date_From,Lx_Contract_rec.End_Date_To
                                 ,Lx_Contract_rec.Date_Terminated_From,Lx_Contract_rec.Date_Terminated_To,
                                 Lx_Contract_rec.Contract_Status_Code) LOOP


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
        Lx_Idx_Rec.HD_currency_code             := Idx.HD_currency_code;


        IF (Lx_Contract_Id <> Lx_Idx_Rec.Contract_Id) OR (Lx_Valid_K = 'F') THEN

         Get_Cont02Format_Validation
            (P_Contracts            => Lx_Idx_Rec
            ,P_BusiProc_Id	        => NULL
            ,P_Severity_Id	        => NULL
            ,P_Request_TZone_Id	    => NULL
            ,P_Dates_In_Input_TZ    => 'Y'              -- Added for 12.0 ENT-TZ project (JVARGHES)
            ,P_Incident_Date        => ld_request_date  -- Added for 12.0 ENT-TZ project (JVARGHES)
            ,P_Request_Date         => Ld_Request_Date
            ,P_Request_Date_Start   => NULL
            ,P_Request_Date_End     => NULL
            ,P_Calc_RespTime_YN     => NULL
            ,P_Validate_Eff         => Lv_Validate_Eff
            ,P_Validate_Flag        => Lv_Validate_Flag
            ,P_SrvLine_Flag         => Lv_SrvLine_Flag
            ,P_Sort_Key             => Lv_Sort_Key
            ,X_Contracts_02         => Lx_Contracts_02_Val
            ,X_Result               => Lx_Result
            ,X_Return_Status   	    => Lx_Return_Status);

        END IF;

        IF (Lx_Contract_Id <> Lx_Idx_Rec.Contract_Id) THEN

            Lx_Contract_Id := Lx_Idx_Rec.Contract_Id;
            Lx_Valid_K    := 'F';

        END IF;

        IF Lx_Contracts_02_Val.COUNT > 0 THEN

         Lx_Valid_K    := 'T';

         Li_OutTab_Idx := Li_OutTab_Idx + 1;

          Lx_Contracts_02(Li_OutTab_Idx).Contract_Number             := Lx_Contracts_02_Val(1).Contract_Number;
          Lx_Contracts_02(Li_OutTab_Idx).Contract_Number_Modifier    := Lx_Contracts_02_Val(1).Contract_Number_Modifier;
          Lx_Contracts_02(Li_OutTab_Idx).contract_status_code        := Lx_Contracts_02_Val(1).Sts_code;
          Lx_Contracts_02(Li_OutTab_Idx).contract_category           := Idx.scs_code;
          Lx_Contracts_02(Li_OutTab_Idx).known_as                    := Idx.cognomen;
          Lx_Contracts_02(Li_OutTab_Idx).short_description           := Idx.short_description;
          Lx_Contracts_02(Li_OutTab_Idx).start_date                  := Idx.HD_start_date;
          Lx_Contracts_02(Li_OutTab_Idx).end_date                    := Idx.HD_end_date;
          Lx_Contracts_02(Li_OutTab_Idx).date_terminated             := Idx.HD_date_terminated;
          Lx_Contracts_02(Li_OutTab_Idx).contract_amount             := Idx.estimated_amount;
          Lx_Contracts_02(Li_OutTab_Idx).currency_code               := Idx.HD_Currency_code;
          Lx_Contracts_02(Li_OutTab_Idx).HD_sts_meaning              := Idx.HD_sts_meaning;
          Lx_Contracts_02(Li_OutTab_Idx).HD_cat_meaning              := Idx.HD_cat_meaning;

         Lx_Contracts_02_Val.DELETE;

        END IF;

        IF Lx_Return_Status = G_RET_STS_UNEXP_ERROR THEN
            RAISE L_EXCEP_UNEXPECTED_ERR;
        END IF;

      END LOOP;

      Li_TableIdx := Lx_Contracts.NEXT(Li_TableIdx);

    END LOOP;

   ELSIF  Lx_Contracts.COUNT > 0 AND Lv_Validate_Flag = 'F' AND Lv_Validate_Eff = 'F' THEN

     Li_TableIdx  := Lx_Contracts.FIRST;

     WHILE Li_TableIdx IS NOT NULL LOOP

      IF Lv_SrvLine_Flag = 'T' THEN

        Lx_SrvLine_Id     := Lx_Contracts(Li_TableIdx).Rx_Cle_Id;
        Lx_CovLvlLine_Id  := NULL;

      ELSE

        Lx_SrvLine_Id     := NULL;
        Lx_CovLvlLine_Id  := Lx_Contracts(Li_TableIdx).Rx_Cle_Id;

      END IF;

      Lv_Cont_Pty_Id  := TO_CHAR(Lx_Contract_rec.Contract_Party_Id);

      FOR Idx IN Lx_Csr_Contracts1(Lx_Contracts(Li_TableIdx).Rx_Chr_Id,Lv_Cont_Pty_Id
                                 ,Lx_Contract_rec.Start_Date_From,Lx_Contract_rec.Start_Date_To
                                 ,Lx_Contract_rec.End_Date_From,Lx_Contract_rec.End_Date_To
                                 ,Lx_Contract_rec.Date_Terminated_From,Lx_Contract_rec.Date_Terminated_To,
                                 Lx_Contract_rec.Contract_Status_Code) LOOP


         Li_OutTab_Idx := Li_OutTab_Idx + 1;

          Lx_Contracts_02(Li_OutTab_Idx).Contract_Number             := Idx.Contract_Number;
          Lx_Contracts_02(Li_OutTab_Idx).Contract_Number_Modifier    := Idx.Contract_Number_Modifier;
          Lx_Contracts_02(Li_OutTab_Idx).contract_status_code        := Idx.Sts_code;
          Lx_Contracts_02(Li_OutTab_Idx).contract_category           := Idx.scs_code;
          Lx_Contracts_02(Li_OutTab_Idx).known_as                    := Idx.cognomen;
          Lx_Contracts_02(Li_OutTab_Idx).short_description           := Idx.short_description;
          Lx_Contracts_02(Li_OutTab_Idx).start_date                  := Idx.HD_start_date;
          Lx_Contracts_02(Li_OutTab_Idx).end_date                    := Idx.HD_end_date;
          Lx_Contracts_02(Li_OutTab_Idx).date_terminated             := Idx.HD_date_terminated;
          Lx_Contracts_02(Li_OutTab_Idx).contract_amount             := Idx.estimated_amount;
          Lx_Contracts_02(Li_OutTab_Idx).currency_code               := Idx.HD_Currency_code;
          Lx_Contracts_02(Li_OutTab_Idx).HD_sts_meaning              := Idx.HD_sts_meaning;
          Lx_Contracts_02(Li_OutTab_Idx).HD_cat_meaning              := Idx.HD_cat_meaning;


      END LOOP;

      Li_TableIdx := Lx_Contracts.NEXT(Li_TableIdx);

     END LOOP;

    ELSIF Lx_Contracts.COUNT = 0 AND Lv_Validate_Flag = 'F' AND Lv_Validate_Eff = 'F' THEN

      Lv_Cont_Pty_Id  := TO_CHAR(Lx_Contract_rec.Contract_Party_Id);

      FOR Idx IN Lx_Csr_Contracts1(Lv_Contract_Id,Lv_Cont_Pty_Id
                                 ,Lx_Contract_rec.Start_Date_From,Lx_Contract_rec.Start_Date_To
                                 ,Lx_Contract_rec.End_Date_From,Lx_Contract_rec.End_Date_To
                                 ,Lx_Contract_rec.Date_Terminated_From,Lx_Contract_rec.Date_Terminated_To,
                                 Lx_Contract_rec.Contract_Status_Code) LOOP



         Li_OutTab_Idx := Li_OutTab_Idx + 1;

          Lx_Contracts_02(Li_OutTab_Idx).Contract_Number             := Idx.Contract_Number;
          Lx_Contracts_02(Li_OutTab_Idx).Contract_Number_Modifier    := Idx.Contract_Number_Modifier;
          Lx_Contracts_02(Li_OutTab_Idx).contract_status_code        := Idx.Sts_code;
          Lx_Contracts_02(Li_OutTab_Idx).contract_category           := Idx.scs_code;
          Lx_Contracts_02(Li_OutTab_Idx).known_as                    := Idx.cognomen;
          Lx_Contracts_02(Li_OutTab_Idx).short_description           := Idx.short_description;
          Lx_Contracts_02(Li_OutTab_Idx).start_date                  := Idx.HD_start_date;
          Lx_Contracts_02(Li_OutTab_Idx).end_date                    := Idx.HD_end_date;
          Lx_Contracts_02(Li_OutTab_Idx).date_terminated             := Idx.HD_date_terminated;
          Lx_Contracts_02(Li_OutTab_Idx).contract_amount             := Idx.estimated_amount;
          Lx_Contracts_02(Li_OutTab_Idx).currency_code               := Idx.HD_Currency_code;
          Lx_Contracts_02(Li_OutTab_Idx).HD_sts_meaning              := Idx.HD_sts_meaning;
          Lx_Contracts_02(Li_OutTab_Idx).HD_cat_meaning              := Idx.HD_cat_meaning;

    END LOOP;

   END IF;

    Lx_Contracts_02_Out := Lx_Contracts_02;

    X_Contracts_02        := Lx_Contracts_02_Out;
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
	,P_Token2_Value   => 'Search_Contracts_01_Format');

      X_Result          := G_FALSE;
      X_Return_Status   := G_RET_STS_UNEXP_ERROR;

  END Search_Contracts_01_Format;


PROCEDURE Search_Contracts
    (p_api_version         IN  Number
    ,p_init_msg_list       IN  Varchar2
    ,p_contract_rec        IN  inp_cont_rec_type
    ,p_clvl_id_tbl         IN  covlvl_id_tbl
    ,x_return_status       out nocopy Varchar2
    ,x_msg_count           out nocopy Number
    ,x_msg_data            out nocopy Varchar2
    ,x_contract_tbl        out nocopy output_tbl_contract) IS


    Lx_Inp_Rec_02     CONSTANT  inp_cont_rec_type   := p_contract_rec;
    Lx_Inp_Tbl_03               covlvl_id_tbl;
    Lx_Return_Status            Gx_Ret_Sts;
    Lx_Result                   Gx_Boolean;
    Lv_Request_date	            date;

    Lx_Ent_Contracts            output_tbl_contract;
    Lx_Contracts                GT_Contract_Ref;
    Lx_Contracts_Temp           GT_Contract_Ref;
    Lx_Contracts_Out            GT_Contract_Ref;
    Lx_Contracts_02             GT_Contract_Ref;
    Lx_Contracts_Prev           GT_Contract_Ref;
    Lx_Contracts_ContNum        GT_Contract_Ref;

    Lx_Contract_Id              NUMBER;

    Lv_SrvLine_Flag             VARCHAR2(1);

    Ln_Organization_Id          NUMBER;
    Ln_Org_Id                   NUMBER;
    Ln_Chr_Id                   NUMBER;

    Lx_Validate_Eff             VARCHAR2(1);
    Lx_Validate_Flag            VARCHAR2(1);

    i                           NUMBER;
    j                           NUMBER;
    Lx_Chr_Id                   NUMBER;

    Li_TableIdx                 BINARY_INTEGER;

    L_EXCEP_UNEXPECTED_ERR      EXCEPTION;

  BEGIN

    Lx_Inp_Tbl_03               :=  p_clvl_id_tbl;
    Lx_Return_Status            :=  G_RET_STS_SUCCESS;
    Lx_Result                   :=  G_TRUE;
    Lv_SrvLine_Flag             := 'F';
    Lx_Validate_Eff             := 'F';
    Lx_Validate_Flag            := 'F';
    Lx_Chr_Id                   := -99999;

 -- Bug# 4735542
 -- OKC_CONTEXT.set_okc_org_context(p_org_id => NULL,p_organization_id => NULL);
 -- Ln_Organization_Id          := SYS_CONTEXT('OKC_CONTEXT','ORGANIZATION_ID');

 -- Modified for 12.0 MOAC project (JVARGHES)
 -- Ln_Org_Id                   := SYS_CONTEXT('OKC_CONTEXT','ORG_ID');
 --
    G_GRACE_PROFILE_SET         := fnd_profile.value('OKS_ENABLE_GRACE_PERIOD');

    if Lx_Inp_Rec_02.request_date is null then
	    Lv_request_date := sysdate;
    end if;

    IF ((Lx_Inp_Rec_02.Contract_Number IS NOT NULL) --AND (Lx_Inp_Rec_02.Contract_Number_Modifier IS NOT NULL)
    ) THEN

     Get_Contracts_Id
        (P_Contract_Num           => Lx_Inp_Rec_02.Contract_Number
        ,P_Contract_Num_Modifier  => Lx_Inp_Rec_02.Contract_Number_Modifier
        ,X_Contracts              => Lx_Contracts_ContNum
        ,X_Result                 => Lx_Result
        ,X_Return_Status   	      => Lx_Return_Status);

      IF Lx_Result <> G_TRUE THEN
        RAISE L_EXCEP_UNEXPECTED_ERR;
      END IF;

      IF Lx_Contracts_ContNum.COUNT > 0 THEN
       Lx_Contract_Id  := Lx_Contracts_ContNum(1).Rx_Chr_Id;
      END IF;

    END IF;

    IF Lx_Inp_Tbl_03.COUNT > 0 THEN

    FOR i in Lx_Inp_Tbl_03.FIRST..Lx_Inp_Tbl_03.LAST  LOOP

     IF Lx_Inp_Tbl_03(i).covlvl_code = 'OKX_CUSTPROD' THEN

      Get_CovProd_Contracts
        (P_CovProd_Obj_Id         => Lx_Inp_Tbl_03(i).covlvl_id
        ,P_Organization_Id        => Ln_Organization_Id
        ,P_Org_Id                 => Ln_Org_Id
        ,X_CovProd_Contracts      => Lx_Contracts
        ,X_Result                 => Lx_Result
        ,X_Return_Status   	  => Lx_Return_Status);

      IF Lx_Result <> G_TRUE THEN
        RAISE L_EXCEP_UNEXPECTED_ERR;
      END IF;

     ELSE

      IF Lx_Inp_Tbl_03(i).covlvl_code = 'OKX_COVITEM' THEN

        Get_CovItem_Contracts
          (P_CovItem_Obj_Id         => Lx_Inp_Tbl_03(i).covlvl_id
          ,P_Organization_Id        => Ln_Organization_Id
          ,P_Party_Id               => Lx_Inp_Rec_02.Contract_Party_Id --Lx_Inp_Rec.Party_Id
          ,X_CovItem_Contracts      => Lx_Contracts
          ,X_Result                 => Lx_Result
          ,X_Return_Status   	    => Lx_Return_Status);

        IF Lx_Result <> G_TRUE THEN
          RAISE L_EXCEP_UNEXPECTED_ERR;
        END IF;

      END IF;

      IF Lx_Inp_Tbl_03(i).covlvl_code = 'OKX_COVSYST' THEN

        Get_CovSys_Contracts
          (P_CovSys_Obj_Id          => Lx_Inp_Tbl_03(i).covlvl_id
          ,P_Org_Id                 => Ln_Org_Id
          ,X_CovSys_Contracts       => Lx_Contracts_Temp
          ,X_Result                 => Lx_Result
          ,X_Return_Status   	    => Lx_Return_Status);

        IF Lx_Result <> G_TRUE THEN
          RAISE L_EXCEP_UNEXPECTED_ERR;
        END IF;

      ELSIF Lx_Inp_Tbl_03(i).covlvl_code = 'OKX_CUSTACCT' THEN

        Get_CovCust_Contracts
          (P_CovCust_Obj_Id         => Lx_Inp_Tbl_03(i).covlvl_id
          ,X_CovCust_Contracts      => Lx_Contracts_Temp
          ,X_Result                 => Lx_Result
          ,X_Return_Status   	    => Lx_Return_Status);

        IF Lx_Result <> G_TRUE THEN
          RAISE L_EXCEP_UNEXPECTED_ERR;
        END IF;

      ELSIF Lx_Inp_Tbl_03(i).covlvl_code = 'OKX_PARTYSITE' THEN

        Get_CovSite_Contracts
          (P_CovSite_Obj_Id         => Lx_Inp_Tbl_03(i).covlvl_id
          ,P_Org_Id                 => Ln_Org_Id
          ,X_CovSite_Contracts      => Lx_Contracts_Temp
          ,X_Result                 => Lx_Result
          ,X_Return_Status   	    => Lx_Return_Status);

        IF Lx_Result <> G_TRUE THEN
          RAISE L_EXCEP_UNEXPECTED_ERR;
        END IF;

      ELSIF Lx_Inp_Tbl_03(i).covlvl_code = 'OKX_PARTY' THEN

        Get_CovParty_Contracts
          (P_CovParty_Obj_Id        => Lx_Inp_Tbl_03(i).covlvl_id
          ,X_CovParty_Contracts     => Lx_Contracts_Temp
          ,X_Result                 => Lx_Result
          ,X_Return_Status   	    => Lx_Return_Status);

        IF Lx_Result <> G_TRUE THEN
          RAISE L_EXCEP_UNEXPECTED_ERR;
        END IF;

      END IF;

    END IF;

    Append_Contract_PlSql_Table
        (P_Input_Tab          => Lx_Contracts_Temp
        ,P_Append_Tab         => Lx_Contracts
        ,X_Output_Tab         => Lx_Contracts_Out
        ,X_Result             => Lx_Result
        ,X_Return_Status      => Lx_Return_Status);

      IF Lx_Result <> G_TRUE THEN
        RAISE L_EXCEP_UNEXPECTED_ERR;
      END IF;

    Lx_Contracts_Temp.DELETE;
    Lx_Contracts.DELETE;

    Lx_Contracts :=     Lx_Contracts_Out;

    Lx_Contracts_Out.DELETE;

    IF i = 1 THEN
        Lx_Contracts_Prev :=  Lx_Contracts;
    ELSE

        Append_Contract_PlSql_Table
        (P_Input_Tab          => Lx_Contracts_Prev
        ,P_Append_Tab         => Lx_Contracts
        ,X_Output_Tab         => Lx_Contracts_Out
        ,X_Result             => Lx_Result
        ,X_Return_Status      => Lx_Return_Status);

      IF Lx_Result <> G_TRUE THEN
        RAISE L_EXCEP_UNEXPECTED_ERR;
      END IF;

      Lx_Contracts_Prev.DELETE;
      Lx_Contracts_Prev := Lx_Contracts_Out;

     END IF;

    END LOOP;

    Lx_Contracts_Out := Lx_Contracts_Prev;
    Lx_Contracts_Prev.DELETE;

    Lx_Contracts.DELETE;
    Lx_Contracts := Lx_Contracts_Out;
    Lx_Contracts_Out.DELETE;

    IF Lx_Contracts.COUNT > 1 THEN
     Sort_Asc_ContRef_PlSql_Table
        (P_Input_Tab          => Lx_Contracts
        ,X_Output_Tab         => Lx_Contracts_Out
        ,X_Result             => Lx_Result
        ,X_Return_Status      => Lx_Return_Status);

     IF Lx_Result <> G_TRUE THEN
        RAISE L_EXCEP_UNEXPECTED_ERR;
     END IF;
    END IF;


    IF Lx_Contracts_Out.COUNT > 0 THEN
     FOR i in Lx_Contracts_Out.FIRST..Lx_Contracts_Out.LAST LOOP
       Lx_Contracts_Out(i).Rx_Pty_Id := Lx_Inp_Rec_02.Contract_Party_Id;
     END LOOP;
    END IF;


    IF Lx_Inp_Rec_02.Entitlement_Check_YN = 'Y' THEN

        Lx_Validate_Eff    := 'T';
        Lx_Validate_Flag   := 'T';

    ELSE

        Lx_Validate_Eff    := 'F';
        Lx_Validate_Flag   := 'F';

        IF Lx_Contracts_Out.COUNT > 0 THEN

          i                 := Lx_Contracts_Out.First;
          j                 := 1;

          WHILE i IS NOT NULL LOOP

               IF Lx_Chr_Id <> Lx_Contracts_Out(i).Rx_Chr_Id THEN

                   Lx_Contracts_02(j) := Lx_Contracts_Out(i);
                   Lx_Chr_Id          := Lx_Contracts_Out(i).Rx_Chr_Id;

               END IF;

                i := Lx_Contracts_Out.Next(i);
                j := j+1;

           END LOOP;

           Lx_Contracts_Out.DELETE;
           Lx_Contracts_Out := Lx_Contracts_02;
           Lx_Contracts_02.DELETE;

         END IF;

      END IF;

      IF Lx_Contracts_ContNum.COUNT > 0 THEN

      Lx_Chr_Id := Lx_Contracts_ContNum(1).Rx_Chr_Id;

        IF Lx_Contracts_Out.COUNT > 0 THEN

        i                 := Lx_Contracts_Out.First;
        j                 := 1;

        WHILE i IS NOT NULL LOOP

               IF Lx_Chr_Id = Lx_Contracts_Out(i).Rx_Chr_Id THEN

                   Lx_Contracts_02(j) := Lx_Contracts_Out(i);

               END IF;

                i := Lx_Contracts_Out.Next(i);
                j := j+1;

        END LOOP;

           Lx_Contracts_Out.DELETE;
           Lx_Contracts_Out := Lx_Contracts_02;
           Lx_Contracts_02.DELETE;

        END IF;

      END IF;

    ELSE --Lx_Inp_Tbl_03.COUNT = 0 case

        Lx_Validate_Eff    := 'F';
        Lx_Validate_Flag   := 'F';

    END IF; --Lx_Inp_Tbl_03.COUNT check ends


  IF ((Lx_Inp_Tbl_03.COUNT <> 0 and Lx_Contracts_Out.COUNT <> 0)
      OR
     (Lx_Inp_Tbl_03.COUNT = 0)) THEN


   Search_Contracts_01_Format
    (P_Contracts            =>  Lx_Contracts_Out
    ,P_Contract_rec         =>  Lx_Inp_Rec_02
    ,P_Request_Date         =>  Lv_Request_Date --Lx_Inp_Rec_02.Request_Date
    ,P_Contract_Id          =>  Lx_Contract_Id
    ,P_Validate_Eff         =>  Lx_Validate_Eff
    ,P_Validate_Flag        =>  Lx_Validate_Flag
    ,P_SrvLine_Flag         =>  'N'
    ,P_Sort_Key             =>  NULL
    ,X_Contracts_02         =>  Lx_Ent_Contracts
    ,X_Result               =>  Lx_Result
    ,X_Return_Status   	    =>  Lx_Return_Status);

    IF Lx_Result <> G_TRUE THEN
        RAISE L_EXCEP_UNEXPECTED_ERR;
    END IF;

    X_Contract_tbl        := Lx_Ent_Contracts;
    X_Return_Status       := Lx_Return_Status;

  ELSE

 --   X_Contract_tbl        := Lx_Ent_Contracts;
    X_Return_Status       := Lx_Return_Status;

  END IF;


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
	,P_Token2_Value   => 'Search_Contracts');

   --  X_Result            := G_FALSE;
     X_Return_Status     := G_RET_STS_UNEXP_ERROR;

END  Search_Contracts;

PROCEDURE Get_Contracts_Expiration
    (p_api_version              IN  Number
    ,p_init_msg_list            IN  Varchar2
    ,p_contract_id              IN  Number
    ,x_return_status            out nocopy Varchar2
    ,x_msg_count                out nocopy Number
    ,x_msg_data                 out nocopy Varchar2
    ,x_contract_end_date        out nocopy date
    ,x_Contract_Grace_Duration  out nocopy number
    ,x_Contract_Grace_Period    out nocopy VARCHAR2)

    IS

    CURSOR KHDR_Date IS
    select  end_date
    from    OKC_K_HEADERS_ALL_B  -- OKC_K_HEADERS_B   -- Modified for 12.0 MOAC project (JVARGHES)
    where   id = p_contract_id;

    Lx_CHR_Id	                CONSTANT Gx_OKS_Id := p_contract_id;

    Lx_Result                   Gx_Boolean;
    Lx_Return_Status            Gx_Ret_Sts;

    L_EXCEP_UNEXPECTED_ERR      EXCEPTION;

    G_GRACE_PROFILE_SET         VARCHAR2(1);

BEGIN

    Lx_Result                   := G_TRUE;
    Lx_Return_Status            := G_RET_STS_SUCCESS;

    G_GRACE_PROFILE_SET         := fnd_profile.value('OKS_ENABLE_GRACE_PERIOD');

  for KHDR_Date_rec in KHDR_Date loop

    x_contract_end_date := KHDR_Date_rec.end_date;

  end loop;

IF	(G_GRACE_PROFILE_SET = 'Y') THEN

  Get_Contract_Grace
    (P_Contract_Id              => p_contract_id
    ,P_Set_ExcepionStack        => G_FALSE
    ,x_grace_period             => x_Contract_Grace_Period
    ,x_grace_duration           => x_Contract_Grace_Duration
    ,X_Result                   => Lx_Result
    ,X_Return_Status            => Lx_Return_Status);

  IF Lx_Result <> G_TRUE THEN
     RAISE L_EXCEP_UNEXPECTED_ERR;
  END IF;

END IF;

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
	,P_Token2_Value   => 'Get_Contracts_Expiration');

   --  X_Result            := G_FALSE;
     X_Return_Status     := G_RET_STS_UNEXP_ERROR;

END  Get_Contracts_Expiration;

PROCEDURE Get_Service_PO
    (P_CHR_Id                   IN  Gx_OKS_Id
    ,P_Set_ExcepionStack        IN  Gx_Boolean
    ,X_Service_PO               out nocopy VARCHAR2
    ,X_Service_PO_required      out nocopy VARCHAR2
    ,X_Result                   out nocopy Gx_Boolean
    ,X_Return_Status            out nocopy Gx_Ret_Sts)
  IS



    CURSOR Lx_Csr_SvcPO(Cx_CHR_Id IN Gx_OKS_Id) IS
				SELECT service_po_number,service_po_required
				FROM	OKS_K_Headers_B CHR
				WHERE	CHR.chr_Id = Cx_CHR_Id;

    Lx_CHR_Id	                CONSTANT Gx_OKS_Id := P_CHR_Id;
    Lx_Set_ExcepionStack        CONSTANT Gx_Boolean := P_Set_ExcepionStack;

    Lx_Service_PO               Oks_K_headers_b.service_po_number%TYPE;
    Lx_Service_PO_Required      Oks_K_headers_b.service_po_required%TYPE;


    Lx_Result                   Gx_Boolean;
    Lx_Return_Status            Gx_Ret_Sts;

    L_EXCEP_NO_DATA_FOUND       EXCEPTION;

  BEGIN

    Lx_Result                   := G_TRUE;
    Lx_Return_Status            := G_RET_STS_SUCCESS;

    OPEN Lx_Csr_SvcPO(Lx_CHR_Id);
    FETCH Lx_Csr_SvcPO INTO Lx_Service_PO,Lx_Service_PO_Required;

    IF Lx_Csr_SvcPO%NOTFOUND THEN

      CLOSE Lx_Csr_SvcPO;
      RAISE L_EXCEP_NO_DATA_FOUND;

    END IF;

    CLOSE Lx_Csr_SvcPO;

    X_Service_PO            :=  Lx_Service_PO;
    X_Service_PO_Required   :=  Lx_Service_PO_Required;

    X_Result                := Lx_Result;
    X_Return_Status         := Lx_Return_Status;

  EXCEPTION

    WHEN L_EXCEP_NO_DATA_FOUND THEN

      Lx_Result   := G_FALSE;

      IF Lx_Set_ExcepionStack = G_TRUE THEN

        OKC_API.SET_MESSAGE
          (p_app_name	   => G_APP_NAME_OKC
	  ,p_msg_name	   => G_INVALID_VALUE
	  ,p_token1	   => G_COL_NAME_TOKEN
	  ,p_token1_value  => 'Service PO');

        Lx_Return_Status  := G_RET_STS_ERROR;

      END IF;

      X_Result            := Lx_Result;
      X_Return_Status     := Lx_Return_Status;

    WHEN OTHERS THEN

      IF Lx_Csr_SvcPO%ISOPEN THEN
        CLOSE Lx_Csr_SvcPO;
      END IF;

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
	,P_Token2_Value   => 'Get_Service_PO');

      X_Result            := G_FALSE;
      X_Return_Status     := G_RET_STS_UNEXP_ERROR;

END Get_Service_PO;

PROCEDURE Get_Contract_Grace
    (P_Contract_Id              IN number
    ,P_Set_ExcepionStack        IN  Gx_Boolean
    ,x_grace_period             OUT NOCOPY varchar2
    ,x_grace_duration           OUT NOCOPY number
    ,X_Result                   out nocopy Gx_Boolean
    ,X_Return_Status            out nocopy Gx_Ret_Sts)
    IS

  CURSOR Lx_Csr_HDR_Grace(Cx_HDR_Id IN Gx_OKS_Id) IS
    SELECT Grace_Duration Duration
          ,Grace_Period TimeUnit
      FROM Oks_K_Headers_B OKH
     WHERE OKH.chr_Id = Cx_HDR_Id;

    Lx_CHR_Id	                CONSTANT Gx_OKS_Id  := P_Contract_id;
    Lx_Set_ExcepionStack        CONSTANT Gx_Boolean := P_Set_ExcepionStack;

--    Lx_Service_PO               Okc_Rules_B.Rule_Information1%TYPE;

    Lx_Result                   Gx_Boolean;
    Lx_Return_Status            Gx_Ret_Sts;

    L_EXCEP_NO_DATA_FOUND       EXCEPTION;

BEGIN

    Lx_Result                   := G_TRUE;
    Lx_Return_Status            := G_RET_STS_SUCCESS;

--   IF G_GRACE_PROFILE_SET = 'Y' then
    FOR Idx in Lx_Csr_HDR_Grace(Lx_CHR_Id) LOOP

    x_grace_period      := Idx.TimeUnit;
    x_grace_duration    := Idx.Duration;

    END LOOP;
--   END IF;

   X_Result            := Lx_Result;
   X_Return_Status     := Lx_Return_Status;

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
	,P_Token2_Value   => 'Get_Contract_Grace');

      X_Result            := G_FALSE;
      X_Return_Status     := G_RET_STS_UNEXP_ERROR;


END Get_Contract_Grace;

--================================================================

PROCEDURE VALIDATE_CONTRACT_LINE
    (p_api_version          IN  NUMBER
    ,p_init_msg_list        IN  VARCHAR2
    ,p_contract_line_id     IN  NUMBER
    ,p_busiproc_id          IN  NUMBER
    ,p_request_date         IN  DATE
    ,p_covlevel_tbl_in      IN covlevel_tbl_type
    ,p_verify_combination   IN VARCHAR2
    ,x_return_status        OUT nocopy Varchar2
    ,x_msg_count            OUT nocopy Number
    ,x_msg_data             OUT nocopy Varchar2
    ,x_covlevel_tbl_out     OUT NOCOPY  covlevel_tbl_type
    ,x_combination_valid    OUT NOCOPY VARCHAR2)



    IS

    Lx_Result                 VARCHAR2(1);
    x_result                  VARCHAR2(1);
    Lx_Return_Status          VARCHAR2(1);

    L_EXCEP_NULL_VALUE          EXCEPTION;
    EXCEPTION_HALT_VALIDATION   EXCEPTION;
    L_EXCEP_UNEXPECTED_ERR      EXCEPTION;
    Lx_Set_ExcepionStack        VARCHAR2(1);

     l_busiproc_id           VARCHAR2(30);
     l_request_date          DATE;
     l_contract_line_id      NUMBER;
     l_busiproc_match        VARCHAR2(1);
     j                       NUMBER ;

     Lx_Party_Id             Okx_Customer_Accounts_V.Party_Id%TYPE;
     Lx_Product_CovLevels    OKS_ENTITLEMENTS_PVT.GT_ContItem_Ref;
     Lx_Item_CovLevels       OKS_ENTITLEMENTS_PVT.GT_ContItem_Ref;
     Lx_System_CovLevels     OKS_ENTITLEMENTS_PVT.GT_ContItem_Ref;
     Lx_Cust_CovLevels       OKS_ENTITLEMENTS_PVT.GT_ContItem_Ref;
     Lx_Site_CovLevels       OKS_ENTITLEMENTS_PVT.GT_ContItem_Ref;
     Lx_Party_CovLevels      OKS_ENTITLEMENTS_PVT.GT_ContItem_Ref;
     l_jtot_object1_code     VARCHAR2(30);

     prod_index              NUMBER;
     system_index            NUMBER;
     l_check_system          VARCHAR2(1);
     l_check_custprod        VARCHAR2(1);
     partysite_index         NUMBER;
     l_check_site            VARCHAR2(1);
     l_check_party           VARCHAR2(1);
     party_index             NUMBER;
     l_org_id                NUMBER;
     l_inv_org_id            NUMBER;

     Ln_Organization_Id       NUMBER;
     Ln_Org_Id                NUMBER;
     item_index              NUMBER;
     l_check_item            VARCHAR2(1);
     l_check_cust            VARCHAR2(1);
     custacct_index          NUMBER;
     k                       NUMBER;

     CURSOR CUR_GET_ORG_ID(l_contract_line_id IN NUMBER) IS
     SELECT hdr.AUTHORING_ORG_ID, hdr.INV_ORGANIZATION_ID
     FROM OKC_K_HEADERS_ALL_B hdr, OKC_K_LINES_B lines
     WHERE lines.id = l_contract_line_id
     AND   lines.chr_id = hdr.id ;


     FUNCTION VALIDATE_BUSINESS_PROCESS(P_CONTRACT_LINE_ID IN NUMBER
                                        ,P_BUSIPROC_ID     IN VARCHAR2
                                        ,P_EFFECTIVE_DATE  IN DATE) RETURN VARCHAR2 IS


-- Commented out by JVARGHES on Apr 12, 2005
-- For the fix of bug# 4282785
/*
      CURSOR CUR_GET_BP(p_contract_line_id IN NUMBER, p_effective_date IN DATE) IS
       SELECT   lines1.chr_id  chr_id,
                lines2.id bp_line_id,
                lines2.start_date start_date,
                lines2.end_date end_date,
                items.object1_id1
       FROM     OKC_K_LINES_B lines1,
                OKC_K_LINES_B lines2,
                OKC_K_LINES_B lines3,
                OKC_K_ITEMS   items
        WHERE   lines1.id  = p_contract_line_id
        AND     lines2.cle_id = lines1.id
        AND     lines2.lse_id IN (2,15,20)
        AND     lines3.cle_id = lines2.id
        AND     lines3.lse_id IN (3,16,21)
        AND     items.cle_id = lines3.id
        AND     items.dnz_chr_id = lines3.dnz_chr_id
        AND     items.jtot_object1_code = 'OKX_BUSIPROC'
        AND     items.object1_id1 = p_busiproc_id
        and     items.object1_id2 = '#' -- new where clause added to address performance bug 3755019
        AND     trunc(p_effective_date) BETWEEN NVL(lines3.start_date, trunc(sysdate))
                                        AND     NVL(lines3.end_date, trunc(sysdate)) ;
*/

-- Modified by JVARGHES on Apr 12, 2005
-- For the fix of bug# 4282785

--
-- Modified for 12.0 Coverage Rearch project (JVARGHES)
--

      CURSOR CUR_GET_BP(p_contract_line_id IN NUMBER) IS
       SELECT /*+ ordered use_nl(lines1,KSL,lines3,items) index(items okc_k_items_n1) */ -- Bug Fix:5694209
               decode(KSL.Standard_Cov_YN,'Y', lines1.start_date,lines3.start_date) start_date
              ,decode(KSL.Standard_Cov_YN,'Y', lines1.end_date,lines3.end_date) end_date
              , lines3.id bpl_id
              , ksl.Standard_Cov_YN Standard_Cov_YN
       FROM     OKC_K_LINES_B lines1,
                OKS_K_LINES_B KSL,
                OKC_K_LINES_B lines3,
                OKC_K_ITEMS   items
        WHERE   lines1.id = p_contract_line_id
        AND     lines1.lse_id IN (1,14,19)
        and     ksl.cle_id  = lines1.id
        AND     lines3.cle_id = KSL.Coverage_Id
        AND     lines3.lse_id IN (3,16,21)
        AND     items.cle_id = lines3.id
        AND     items.dnz_chr_id = lines3.dnz_chr_id
        AND     items.jtot_object1_code = 'OKX_BUSIPROC'
        AND     items.object1_id1 = p_busiproc_id
        and     items.object1_id2 = '#' -- new where clause added to address performance bug 3755019
        AND     ROWNUM <= 1;

--

     l_busiproc_id             VARCHAR2(30);
     l_effective_date          DATE;
     l_contract_line_id        NUMBER;
     x_busiproc_match          VARCHAR2(1);


      --
      -- Modified for 12.0 Coverage Rearch project (JVARGHES)
      --

      Ld_BPL_Start	       DATE;
      Ln_BPL_OFS_Duration	 NUMBER;
      Lv_BPL_OFS_UOM           VARCHAR2(100);

      Lx_Return_Status         VARCHAR2(10);

      L_EXCEP_NO_DATA_FOUND    EXCEPTION;
      --
      --

    BEGIN

      x_busiproc_match := 'N';

      l_busiproc_id         := P_BUSIPROC_ID ;
      l_effective_date      := P_EFFECTIVE_DATE ;
      l_contract_line_id    := P_CONTRACT_LINE_ID ;


-- Comented out by JVARGHES on Apr 12, 2005
-- For the fix of bug# 4282785

/*
     FOR bp_rec IN CUR_GET_BP(l_contract_line_id, l_effective_date)
      LOOP
      x_busiproc_match := 'Y' ;
     END LOOP ;
*/

-- Modified by JVARGHES on Apr 12, 2005
-- For the fix of bug# 4282785

--
-- Modified for 12.0 Coverage Rearch project (JVARGHES)
--
--     OPEN CUR_GET_BP(p_contract_line_id  => l_contract_line_id, p_effective_date => l_effective_date);
--     FETCH CUR_GET_BP INTO x_busiproc_match;
--
--     IF CUR_GET_BP%FOUND THEN
--       x_busiproc_match := 'Y';
--     ELSE
--       x_busiproc_match := 'N';
--     END IF;
--
--     CLOSE CUR_GET_BP;
--
--
-- Modified for 12.0 Coverage Rearch project (JVARGHES)
--

      x_busiproc_match := 'N';

      FOR bp_rec IN CUR_GET_BP(p_contract_line_id  => l_contract_line_id)
      LOOP

          IF bp_rec.Standard_Cov_YN = 'Y' THEN

             Get_BP_Line_Start_Offset
              (P_BPL_Id	        => bp_rec.BPL_Id
              ,P_SVL_Start	        => bp_rec.start_date
              ,X_BPL_OFS_Start	  => Ld_BPL_Start
              ,X_BPL_OFS_Duration	  => Ln_BPL_OFS_Duration
              ,X_BPL_OFS_UOM	  => Lv_BPL_OFS_UOM
              ,X_Return_Status 	  => Lx_Return_Status);

             IF Lx_Return_Status<> G_RET_STS_SUCCESS  THEN
               RAISE L_EXCEP_NO_DATA_FOUND;
             END IF;

          ELSE

             Ld_BPL_Start := bp_rec.start_date;

          END IF;

          IF l_effective_date between NVL(Ld_BPL_Start,trunc(sysdate))
                                   AND  NVL(bp_rec.end_date, trunc(sysdate))  THEN
            x_busiproc_match := 'Y';
            EXIT;

          END IF;

      END LOOP;

--
--
      RETURN x_busiproc_match ;

    END VALIDATE_BUSINESS_PROCESS;


    FUNCTION VALIDATE_COVLEVELS(p_contract_line_id IN NUMBER,
                              p_object1_id1      IN VARCHAR2,
                              p_object1_id2      IN VARCHAR2,
                              p_object_code      IN VARCHAR2)
                              RETURN VARCHAR2 IS

        CURSOR CUR_GET_COVLEVELS(l_contract_line_id IN NUMBER, l_object1_id1 IN VARCHAR2, l_object1_id2 IN VARCHAR2,
                             l_object_code IN VARCHAR2) IS

            SELECT 'X'
            FROM    OKC_K_LINES_B lines1,
                    OKC_K_LINES_B lines2,
                    OKC_K_ITEMS  items
              WHERE lines1.id                 = l_contract_line_id
                AND lines2.cle_id             = lines1.id
                AND lines2.dnz_chr_id         = lines1.chr_id
                AND items.cle_id              = lines2.id
                AND items.object1_id1         = l_object1_id1
                AND items.object1_id2         = l_object1_id2
                AND items.jtot_object1_code   = l_object_code ;


        lx_contract_line_id    NUMBER;
        lx_object1_id1         VARCHAR2(40);
        lx_object1_id2         VARCHAR2(200);
        lx_object_code         VARCHAR2(30);
        x_covlevel_exist       VARCHAR2(1);
        l_dummy                VARCHAR2(1);

        BEGIN

          lx_contract_line_id := p_contract_line_id;
          lx_object1_id1      := p_object1_id1;
          lx_object1_id2      := p_object1_id2;
          lx_object_code      := p_object_code;

          OPEN CUR_GET_COVLEVELS(lx_contract_line_id, lx_object1_id1,lx_object1_id2,lx_object_code);
          FETCH CUR_GET_COVLEVELS INTO l_dummy;
          CLOSE CUR_GET_COVLEVELS;

          IF l_dummy = 'X' THEN
            x_covlevel_exist := 'Y';
          ELSE
            x_covlevel_exist := 'N';
          END IF ;

         RETURN x_covlevel_exist ;

    END VALIDATE_COVLEVELS ;


   BEGIN

    Lx_Result                 := OKC_API.G_TRUE;
    x_result                  := OKC_API.G_TRUE;
    Lx_Set_ExcepionStack      := OKC_API.G_TRUE;

         -- check that the p_contract_line_id is not null

    OKS_ENTITLEMENTS_PVT.Validate_Required_NumValue
      (P_Num_Value              => p_contract_line_id
      ,P_Set_ExcepionStack      => Lx_Set_ExcepionStack
      ,P_ExcepionMsg            => 'Contract Line'
      ,X_Result                 => Lx_result
      ,X_Return_Status   	    => Lx_Return_Status);

    IF Lx_result <> G_TRUE  THEN
      RAISE L_EXCEP_NULL_VALUE;
    END IF;

    OPEN  CUR_GET_ORG_ID(p_contract_line_id);
    FETCH CUR_GET_ORG_ID  INTO  l_org_id, l_inv_org_id;
    CLOSE CUR_GET_ORG_ID;

   IF p_busiproc_id IS NOT NULL THEN
    l_busiproc_id       := TO_CHAR(p_busiproc_id) ;
    l_request_date      := nvl(p_request_date,sysdate);
    l_contract_line_id  := p_contract_line_id ;

   l_busiproc_match:=  VALIDATE_BUSINESS_PROCESS(P_CONTRACT_LINE_ID  => l_contract_line_id,
                                                 P_BUSIPROC_ID       => l_busiproc_id,
                                                 P_EFFECTIVE_DATE    => l_request_date);



  -- if the call TO above function returns 'N', update the input cov level tbl to N

    IF l_busiproc_match = 'N' THEN

     x_covlevel_tbl_out := p_covlevel_tbl_in ;

     j:= x_covlevel_tbl_out.FIRST;

     FOR covlevel_rec in x_covlevel_tbl_out.FIRST..x_covlevel_tbl_out.LAST
     LOOP
        x_covlevel_tbl_out(j).covered_yn  := 'N';
        j:= j + 1 ;
     END LOOP ;

     IF p_verify_combination = 'Y' THEN
            x_combination_valid:= 'N';
     END IF ;

     RAISE EXCEPTION_HALT_VALIDATION;

    END IF;

    IF (p_busiproc_id IS NULL) OR
       (p_busiproc_id IS NOT NULL and l_busiproc_match = 'Y') THEN -- CHECK THE INPUT COVLEVEL TBL fucntion return Y

      IF p_covlevel_tbl_in.COUNT > 0 THEN

        Ln_Organization_Id          := l_inv_org_id ;
        Ln_Org_Id                   := l_org_id;

        x_covlevel_tbl_out := p_covlevel_tbl_in ;

        FOR i in  p_covlevel_tbl_in.FIRST .. p_covlevel_tbl_in.LAST LOOP

          IF p_covlevel_tbl_in(i).covlevel_code = 'OKX_CUSTPROD' THEN

            l_jtot_object1_code := 'OKX_CUSTPROD';

            OKS_ENTITLEMENTS_PVT.Get_Product_CovLevels
    		     (P_CovProd_Obj_Id      => p_covlevel_tbl_in(i).covlevel_id, -- l_jtot_object1_code,
	            P_Organization_Id     => Ln_Organization_Id,
                  P_Org_Id              => Ln_Org_Id,
                  X_Party_Id            => Lx_Party_Id,
                  X_Product_CovLevels   => Lx_Product_CovLevels,
                  X_Result              => Lx_Result,
                  X_Return_Status       => Lx_Return_Status);

               IF Lx_Result <> G_TRUE THEN
       	        	RAISE L_EXCEP_UNEXPECTED_ERR;
        	   END IF;

        	   IF LX_PRODUCT_COVLEVELS.COUNT > 0 THEN

		         FOR prod_index in Lx_Product_CovLevels.FIRST .. Lx_Product_CovLevels.LAST LOOP

                        l_check_custprod := VALIDATE_COVLEVELS(p_contract_line_id,
                                               LX_PRODUCT_COVLEVELS(prod_index).RX_OBJ1ID1,
                                               LX_PRODUCT_COVLEVELS(prod_index).RX_OBJ1ID2,
                                               LX_PRODUCT_COVLEVELS(prod_index).RX_OBJCODE);

                        IF l_check_custprod = 'Y' THEN
                             x_covlevel_tbl_out(i).covered_yn :='Y';
                             EXIT ;
                        ELSE
                             x_covlevel_tbl_out(i).covered_yn :='N';
                        END IF ;

                 END LOOP ; -- END LOOP FOR LX_PRODUCT_COVLEVELS

                END IF ; -- END IF LX_PRODUCT_COVLEVELS.COUNT > 0

          ELSIF  p_covlevel_tbl_in(i).covlevel_code = 'OKX_COVITEM' THEN

                l_jtot_object1_code := 'OKX_COVITEM';

                OKS_ENTITLEMENTS_PVT.Get_Item_CovLevels(P_CovItem_Obj_Id      => p_covlevel_tbl_in(i).covlevel_id,
                                                     P_Organization_Id     => Ln_Organization_Id,
                                                     X_Item_CovLevels      => Lx_Item_CovLevels,
                                                     X_Result              => Lx_Result,
                                                     X_Return_Status       => Lx_Return_Status);


                IF Lx_Result <> G_TRUE THEN
                   RAISE L_EXCEP_UNEXPECTED_ERR;
                END IF;

                IF LX_ITEM_COVLEVELS.COUNT > 0 THEN

                   FOR item_index in Lx_Item_CovLevels.FIRST .. Lx_Item_CovLevels.LAST  LOOP

                      l_check_item :=   VALIDATE_COVLEVELS(p_contract_line_id,
                                               LX_ITEM_COVLEVELS(item_index).RX_OBJ1ID1,
                                               LX_ITEM_COVLEVELS(item_index).RX_OBJ1ID2,
                                               LX_ITEM_COVLEVELS(item_index).RX_OBJCODE);

                        IF l_check_item = 'Y' THEN
                           x_covlevel_tbl_out(i).covered_yn :='Y';
                           EXIT ;
                        ELSE
                            x_covlevel_tbl_out(i).covered_yn :='N';
                        END IF ;

                    END LOOP ;

                END IF ;  -- END IF FOR LX_ITEM_COVLEVELS.COUNT > 0

          ELSIF  p_covlevel_tbl_in(i).covlevel_code = 'OKX_COVSYST' THEN

                l_jtot_object1_code := 'OKX_COVSYST';

                OKS_ENTITLEMENTS_PVT.Get_System_CovLevels(P_CovSys_Obj_Id       => p_covlevel_tbl_in(i).covlevel_id,
                                                               P_Org_Id              => Ln_Org_Id,
                                                               X_System_CovLevels    => Lx_System_CovLevels,
                                                               X_Result              => Lx_Result,
                                                               X_Return_Status       => Lx_Return_Status );

                IF Lx_Result <> G_TRUE THEN
                   RAISE L_EXCEP_UNEXPECTED_ERR;
                END IF;

                IF LX_SYSTEM_COVLEVELS.COUNT > 0 THEN

                     FOR system_index in Lx_System_CovLevels.FIRST .. Lx_System_CovLevels.LAST  LOOP

                         l_check_system := VALIDATE_COVLEVELS(p_contract_line_id,
                                               LX_SYSTEM_COVLEVELS(system_index).RX_OBJ1ID1,
                                               LX_SYSTEM_COVLEVELS(system_index).RX_OBJ1ID2,
                                               LX_SYSTEM_COVLEVELS(system_index).RX_OBJCODE);

                         IF l_check_system = 'Y' THEN
                              x_covlevel_tbl_out(i).covered_yn :='Y';
                             EXIT ;
                         ELSE
                             x_covlevel_tbl_out(i).covered_yn :='N';
                         END IF ;

                     END LOOP ;

                 END IF ;  -- END IF FOR LX_SYSTEM_COVLEVELS.COUNT > 0

          ELSIF  p_covlevel_tbl_in(i).covlevel_code = 'OKX_CUSTACCT' THEN

                 l_jtot_object1_code := 'OKX_CUSTACCT';

                 OKS_ENTITLEMENTS_PVT.Get_Customer_CovLevels(P_CovCust_Obj_Id      => p_covlevel_tbl_in(i).covlevel_id,
                                                                     X_Party_Id            => Lx_Party_Id,
                                                                     X_Customer_CovLevels  => Lx_Cust_CovLevels,
                                                                     X_Result              => Lx_Result,
                                                                     X_Return_Status       => Lx_Return_Status );
                 IF Lx_Result <> G_TRUE THEN
                      RAISE L_EXCEP_UNEXPECTED_ERR;
                 END IF;

                 IF LX_CUST_COVLEVELS.COUNT > 0 THEN

                     FOR custacct_index in Lx_Cust_CovLevels.FIRST .. Lx_Cust_CovLevels.LAST LOOP

                         l_check_cust := VALIDATE_COVLEVELS(p_contract_line_id,
                                               LX_CUST_COVLEVELS(custacct_index).RX_OBJ1ID1,
                                               LX_CUST_COVLEVELS(custacct_index).RX_OBJ1ID2,
                                               LX_CUST_COVLEVELS(custacct_index).RX_OBJCODE);

                        IF l_check_cust = 'Y' THEN
                            x_covlevel_tbl_out(i).covered_yn :='Y';
                            EXIT ;
                        ELSE
                            x_covlevel_tbl_out(i).covered_yn :='N';
                        END IF ;

                     END LOOP ;

                  END IF ;  -- END IF FOR LX_CUST_COVLEVELS.COUNT > 0

          ELSIF   p_covlevel_tbl_in(i).covlevel_code = 'OKX_PARTYSITE' THEN

                  l_jtot_object1_code := 'OKX_PARTYSITE';

                  OKS_ENTITLEMENTS_PVT.Get_Site_CovLevels(P_CovSite_Obj_Id      => p_covlevel_tbl_in(i).covlevel_id,
                                                             P_Org_Id              => Ln_Org_Id,
                                                             X_Site_CovLevels      => Lx_Site_CovLevels,
                                                             X_Result              => Lx_Result,
                                                             X_Return_Status       => Lx_Return_Status );

                  IF Lx_Result <> G_TRUE THEN
                         RAISE L_EXCEP_UNEXPECTED_ERR;
                  END IF;

                  IF LX_SITE_COVLEVELS.COUNT > 0 THEN

                    FOR partysite_index in Lx_Site_CovLevels.FIRST .. Lx_Site_CovLevels.LAST  LOOP

                       l_check_site := VALIDATE_COVLEVELS(p_contract_line_id,
                                               LX_SITE_COVLEVELS(partysite_index).RX_OBJ1ID1,
                                               LX_SITE_COVLEVELS(partysite_index).RX_OBJ1ID2,
                                               LX_SITE_COVLEVELS(partysite_index).RX_OBJCODE);


                        IF l_check_site = 'Y' THEN
                            x_covlevel_tbl_out(i).covered_yn :='Y';
                            EXIT ;
                        ELSE
                            x_covlevel_tbl_out(i).covered_yn :='N';
                        END IF ;

                    END LOOP ;

                   END IF ;  -- END IF FOR LX_SITE_COVLEVELS.COUNT > 0

           ELSIF  p_covlevel_tbl_in(i).covlevel_code = 'OKX_PARTY' THEN

                   l_jtot_object1_code := 'OKX_PARTY';

                   OKS_ENTITLEMENTS_PVT.Get_Party_CovLevels(P_CovParty_Obj_Id     => p_covlevel_tbl_in(i).covlevel_id,
                                                             X_Party_CovLevels     => Lx_Party_CovLevels,
                                                             X_Result              => Lx_Result,
                                                             X_Return_Status       => Lx_Return_Status );

                   IF Lx_Result <> G_TRUE THEN
                       RAISE L_EXCEP_UNEXPECTED_ERR;
                   END IF;

                   IF LX_PARTY_COVLEVELS.COUNT > 0 THEN

                     FOR party_index in Lx_Party_CovLevels.FIRST .. Lx_Party_CovLevels.LAST LOOP

                        l_check_party := VALIDATE_COVLEVELS(p_contract_line_id,
                                               LX_PARTY_COVLEVELS(party_index).RX_OBJ1ID1,
                                               LX_PARTY_COVLEVELS(party_index).RX_OBJ1ID2,
                                               LX_PARTY_COVLEVELS(party_index).RX_OBJCODE);

                        IF l_check_party = 'Y' THEN
                            x_covlevel_tbl_out(i).covered_yn :='Y';
                            EXIT ;
                        ELSE
                            x_covlevel_tbl_out(i).covered_yn :='N';
                        END IF ;

                     END LOOP ;

                   END IF ;  -- END IF FOR LX_PARTY_COVLEVELS.COUNT > 0

          END IF ;

     END LOOP ;

  -- check here for combination..


  IF p_verify_combination = 'Y' THEN

    k := x_covlevel_tbl_out.first ;

         x_combination_valid:= 'N';

         FOR  out_rec IN x_covlevel_tbl_out.FIRST .. x_covlevel_tbl_out.LAST
         LOOP
		/*
                IF x_covlevel_tbl_out(k).covered_yn = 'N'  THEN
                   x_combination_valid:= 'N';
                   EXIT;
                END IF ;
		*/

/********************************************************************************
              The logic is changed as that is what is required.
              If contract line covers any one of the input covered level records in
              , that is covered_yn = 'Y' , then  as per the new
              inputs from the Service Request at a later date, the contract line
              should be considered valid and x_combination_valid should return 'Y'.
********************************************************************************/

                IF x_covlevel_tbl_out(k).covered_yn = 'Y' THEN
                   x_combination_valid:= 'Y';
                   EXIT;
                END IF ;

           k := x_covlevel_tbl_out.NEXT(k);
       END LOOP ;
     END IF ;
  END IF ;
  END IF ;
  END IF ;

LX_PRODUCT_COVLEVELS.DELETE;
LX_ITEM_COVLEVELS.DELETE;
LX_SYSTEM_COVLEVELS.DELETE;
LX_CUST_COVLEVELS.DELETE;
LX_SITE_COVLEVELS.DELETE;
LX_PARTY_COVLEVELS.DELETE;

x_return_status:= OKC_API.G_RET_STS_SUCCESS ;



    EXCEPTION

        WHEN L_EXCEP_NULL_VALUE THEN
        X_Result        := Lx_Result;
        X_Return_Status := Lx_Return_Status;

        WHEN EXCEPTION_HALT_VALIDATION THEN

        X_Return_Status := OKC_API.G_RET_STS_SUCCESS;
        x_combination_valid := 'N';
        x_covlevel_tbl_out := p_covlevel_tbl_in;

      WHEN    L_EXCEP_UNEXPECTED_ERR THEN
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        x_combination_valid := 'N';
        x_covlevel_tbl_out := p_covlevel_tbl_in;

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
	,P_Token2_Value   => 'Validate_Required_RT_Tokens');

      X_Result        := G_FALSE;
      X_Return_Status := G_RET_STS_UNEXP_ERROR;


    END VALIDATE_CONTRACT_LINE;


-- Added by JVARGHES on Feb 03, 2005.
-- for the resolution of Bug# 3796499.

  FUNCTION Get_NLS_Day_of_Week(P_Day_of_Week IN VARCHAR2) RETURN VARCHAR2 IS

    CURSOR C1(Cv_Day_of_Week IN VARCHAR2) IS
           SELECT
             DECODE(Cv_Day_of_Week
                   ,TO_CHAR(SYSDATE,  'DY','NLS_DATE_LANGUAGE = AMERICAN'),TO_CHAR(SYSDATE,  'DY')
                   ,TO_CHAR(SYSDATE+1,'DY','NLS_DATE_LANGUAGE = AMERICAN'),TO_CHAR(SYSDATE+1,'DY')
                   ,TO_CHAR(SYSDATE+2,'DY','NLS_DATE_LANGUAGE = AMERICAN'),TO_CHAR(SYSDATE+2,'DY')
                   ,TO_CHAR(SYSDATE+3,'DY','NLS_DATE_LANGUAGE = AMERICAN'),TO_CHAR(SYSDATE+3,'DY')
                   ,TO_CHAR(SYSDATE+4,'DY','NLS_DATE_LANGUAGE = AMERICAN'),TO_CHAR(SYSDATE+4,'DY')
                   ,TO_CHAR(SYSDATE+5,'DY','NLS_DATE_LANGUAGE = AMERICAN'),TO_CHAR(SYSDATE+5,'DY')
                   ,TO_CHAR(SYSDATE+6,'DY','NLS_DATE_LANGUAGE = AMERICAN'),TO_CHAR(SYSDATE+6,'DY')
                   ,'-1')
           FROM DUAL;

    lv_Result   VARCHAR2(50);

  BEGIN

    OPEN C1(Cv_Day_of_Week => P_Day_of_Week);
    FETCH C1 INTO lv_Result;
    CLOSE C1;

    RETURN lv_Result;

  END Get_NLS_Day_of_Week;

/*
-- Comment out by JVARGHES on Mar 07, 2005.
-- for the resolution of Bug# 4191909.

    FUNCTION Get_NLS_day_of_week(
      P_day_of_week IN Varchar2) Return Varchar2 is

      l_daynum       number;
      l_daychar      varchar2(100);
      l_daypsdchar   varchar2(100);
      l_daypsdnum    number;
      l_dayrtnchar   varchar2(100);



    BEGIN

      l_daynum       := null;
      l_daychar      := null;
      l_daypsdchar   := P_day_of_week;
      l_daypsdnum    := null;
      l_dayrtnchar   := null;


         if l_daypsdchar = 'SUN' then
            l_daypsdnum := 1;
         elsif l_daypsdchar = 'MON' then
            l_daypsdnum := 2;
         elsif l_daypsdchar = 'TUE' then
            l_daypsdnum := 3;
         elsif l_daypsdchar = 'WED' then
            l_daypsdnum := 4;
         elsif l_daypsdchar = 'THU' then
            l_daypsdnum := 5;
         elsif l_daypsdchar = 'FRI' then
            l_daypsdnum := 6;
         elsif l_daypsdchar = 'SAT' then
            l_daypsdnum := 7;
         end if;


         for i in 0..6 loop


           l_daynum 	:= to_number(to_char(sysdate+i,'D'));
           l_daychar 	:= to_char(sysdate+i,'DY');


          if l_daypsdnum = l_daynum then
            l_dayrtnchar := l_daychar;
            exit;
          end if;

        end loop;

        if l_dayrtnchar is null then
          l_dayrtnchar := 'NOTVALID';
        end if;

        return l_dayrtnchar;

 END Get_NLS_day_of_week;

*/

PROCEDURE    Get_Valid_Line(
                            PHd_Id          IN    NUMBER,
                            PHd_Start_Date  IN    Date,
                            PHd_END_Date    IN    Date,
                            PSv_Start_Date  IN    Date,
                            PSv_End_Date    IN    Date,
                            PSv_Term_Date   IN    Date,
                            PIt_Start_Date  IN    Date,
                            PIt_End_Date    IN    Date,
                            PIt_Term_Date   IN    Date,
                            PCo_Start_Date  IN    Date,
                            PCo_End_Date    IN    Date,
                            PCo_Term_Date   IN    Date,
                            P_Request_Date  IN    Date,
                            X_Valid_line    OUT NOCOPY  VARCHAR2,
                            X_return_Status OUT NOCOPY  VARCHAR2) IS



Lv_Request_Date     Constant Date :=    trunc(nvl(p_request_date,SYSDATE));
LHd_END_Date        Constant Date :=    PHd_END_Date       ;
LSv_Start_Date      Constant Date :=    PSv_Start_Date     ;
LSv_End_Date        Constant Date :=    PSv_End_Date       ;
LSv_Term_Date       Constant Date :=    PSv_Term_Date      ;
LIt_Start_Date      Constant Date :=    PIt_Start_Date     ;
LIt_End_Date        Constant Date :=    PIt_End_Date       ;
LIt_Term_Date       Constant Date :=    PIt_Term_Date      ;
LCo_Start_Date      Constant Date :=    PCo_Start_Date     ;
LCo_End_Date        Constant Date :=    PCo_End_Date       ;
LCo_Term_Date       Constant Date :=    PCo_Term_Date      ;
LHd_Id              Constant NUMBER   := PHd_Id;
LSv_Eff_End_Date    Date;
LCo_Eff_End_Date    Date;
LIt_Eff_End_Date    Date;

BEGIN

        IF LSv_Term_Date  < LSv_End_Date THEN
            LSv_Eff_End_Date := LSv_Term_Date;
        ELSE
            LSv_Eff_End_Date := LSv_End_Date;

              -- grace period changes starts

            IF G_GRACE_PROFILE_SET = 'Y' AND LSv_Term_Date IS NULL THEN
                -- grace period changes are done only if line end date matches contract end date

              IF  trunc(LSv_Eff_End_Date) = trunc(LHd_END_Date) THEN
        --- truncating the dates to remove accidental existence of time components in dates.
                LSv_Eff_End_Date := trunc(Get_Final_End_Date(LHd_Id,LSv_Eff_End_Date));
              END IF;

            END IF;

          -- grace period changes ends
        END IF;

        IF LCo_Term_Date < LCo_End_Date THEN
            LCo_Eff_End_Date := LCo_Term_Date;
        ELSE
            LCo_Eff_End_Date := LCo_End_Date;

              -- grace period changes starts

            IF G_GRACE_PROFILE_SET = 'Y' AND LCo_Term_Date IS NULL THEN
                IF  trunc(LCo_Eff_End_Date) = trunc(LHd_END_Date) THEN
        --- truncating the dates to remove accidental existence of time components in dates.
                      LCo_Eff_End_Date := trunc(Get_Final_End_Date(LHd_Id,LCo_Eff_End_Date));
                END IF;
            END IF;

      -- grace period changes ends
        END IF;


        IF LIt_Term_Date < LIt_End_Date THEN
            LIt_Eff_End_Date := LIt_Term_Date;
        ELSE
            LIt_Eff_End_Date := LIt_End_Date;

              -- grace period changes starts

            IF G_GRACE_PROFILE_SET = 'Y' AND LIt_Term_Date IS NULL THEN
                -- grace period changes are done only if line end date matches contract end date
                IF  trunc(LIt_Eff_End_Date) = trunc(LHd_END_Date) THEN
        --- truncating the dates to remove accidental existence of time components in dates.
                   LIt_Eff_End_Date := trunc(Get_Final_End_Date(LHd_Id,LIt_Eff_End_Date));
                END IF;
            END IF;
        END IF;


        IF ((Lv_Request_Date BETWEEN LSv_Start_Date AND LSv_Eff_End_Date)
             AND
             (Lv_Request_Date BETWEEN LIt_Start_Date AND LIt_Eff_End_Date)
             AND
             (Lv_Request_Date BETWEEN LCo_Start_Date AND LCo_Eff_End_Date)) THEN

             X_Valid_line    := 'T';

        END IF;

    X_return_Status := 'S'; --LX_return_Status;

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
	,P_Token2_Value   => 'Get_Valid_Line');

    X_Return_Status     := G_RET_STS_UNEXP_ERROR;

END get_valid_line;


PROCEDURE Get_Contract_ID
    (P_contract_id            IN  NUMBER
    ,P_Contract_Num           IN  VARCHAR2
    ,P_Contract_Num_Modifier  IN  VARCHAR2
    ,P_START_DATE_FROM        IN  DATE
    ,P_START_DATE_TO          IN  DATE
    ,P_END_DATE_FROM          IN  DATE
    ,P_END_DATE_TO            IN  DATE
    ,P_DATE_TERMINATE_FROM    IN  DATE
    ,P_DATE_TERMINATE_TO      IN  DATE
    ,P_STATUS                 IN  VARCHAR2
    ,P_Cont_Pty_Id            IN  NUMBER
    ,P_cont_renewal_code      IN  VARCHAR2
    ,p_authoring_org_id       in  number
    ,p_contract_grp_id        in  number -- additional header level criteria added dtd Dec 17th, 2003
    ,X_Contracts              OUT NOCOPY GT_Contract_Ref
    ,X_Result                 OUT NOCOPY Gx_Boolean
    ,X_Return_Status   	      OUT NOCOPY Gx_Ret_Sts) IS

    /*Bug:6767455*/
    CURSOR Lx_Csr_terdt_Contracts(  Cv_Contract_Id           IN NUMBER,
 	                             Cv_Contract_Num          IN VARCHAR2,
 	                             Cv_Contract_Num_Modifier IN VARCHAR2,
 	                             Cv_START_DATE_FROM          IN DATE,
 	                             Cv_START_DATE_TO            IN DATE,
 	                             Cv_END_DATE_FROM            IN DATE,
 	                             Cv_END_DATE_TO              IN DATE,
 	                             Cv_DATE_TERMINATE_FROM      IN DATE,
 	                             Cv_DATE_TERMINATE_TO        IN DATE,
 	                             Cv_STATUS                   IN VARCHAR2,
 	                             Cv_Cont_Pty_Id              IN NUMBER,
 	                             Cv_cont_renewal_code        IN VARCHAR2,
 	                             Cv_authoring_org_id         in number,
 	                             Cv_contract_grp_id          in number) IS
 	             SELECT /*+ leading(b) use_nl(b oksb)  */    b.Id Id,                      -- 11.5.10 rule rearchitecture changes
 	                       b.renewal_type_code,          -- Added by Jyothi for perf bug:4991724
 	                         oksb.electronic_renewal_flag  -- Added by Jyothi for perf bug:4991724
 	             FROM     OKC_K_HEADERS_ALL_B B,            --Okc_K_Headers_B B, /*Bug:6767455*/
 	                     oks_k_headers_b oksb          -- 11.5.10 rule rearchitecture changes
 	             WHERE   b.id = oksb.chr_id            -- 11.5.10 rule rearchitecture changes
 	             AND     B.Start_Date BETWEEN Cv_Start_Date_From AND Cv_Start_Date_to
 	             AND     B.End_Date BETWEEN Cv_End_Date_From AND Cv_End_Date_To
 	             AND     B.Date_Terminated BETWEEN Cv_Date_Terminate_From AND Cv_Date_Terminate_To
 	             AND     sts_code = nvl(Cv_STATUS,B.Sts_Code)
 	             and     authoring_org_id = nvl(cv_authoring_org_id,authoring_org_id); -- multi org security check

 /*Bug:6767455*/
  CURSOR Lx_Csr_noHdr_Contracts(  Cv_Contract_Id           IN NUMBER,
                            Cv_Contract_Num          IN VARCHAR2,
                            Cv_Contract_Num_Modifier IN VARCHAR2,
                            Cv_START_DATE_FROM          IN DATE,
                            Cv_START_DATE_TO            IN DATE,
                            Cv_END_DATE_FROM            IN DATE,
                            Cv_END_DATE_TO              IN DATE,
                            Cv_DATE_TERMINATE_FROM      IN DATE,
                            Cv_DATE_TERMINATE_TO        IN DATE,
                            Cv_STATUS                   IN VARCHAR2,
                            Cv_Cont_Pty_Id              IN NUMBER,
                            Cv_cont_renewal_code        IN VARCHAR2,
                            Cv_authoring_org_id         in number,
                            Cv_contract_grp_id          in number) IS
              /*Bug:6767455*/
               SELECT   /*+ leading(b) use_nl(b oksb)  */  b.Id Id,                      -- 11.5.10 rule rearchitecture changes
 	                       b.renewal_type_code,          -- Added by Jyothi for perf bug:4991724
 	                         oksb.electronic_renewal_flag  -- Added by Jyothi for perf bug:4991724
 	             FROM    OKC_K_HEADERS_ALL_B B,  -- OKC_K_HEADERS_B B  -- Modified for 12.0 MOAC project   /*Bug:6767455*/
 	                     oks_k_headers_b oksb          -- 11.5.10 rule rearchitecture changes
 	             WHERE   b.id = oksb.chr_id            -- 11.5.10 rule rearchitecture changes
 	             AND     B.Start_Date BETWEEN Cv_Start_Date_From AND Cv_Start_Date_to
 	             AND     B.End_Date BETWEEN Cv_End_Date_From AND Cv_End_Date_To
 	             AND     sts_code = nvl(Cv_STATUS,B.Sts_Code)
 	             and     authoring_org_id = nvl(cv_authoring_org_id,authoring_org_id); -- multi org security check

 	   CURSOR Lx_Csr_Hdr_Contracts(  Cv_Contract_Id           IN NUMBER,
 	                             Cv_Contract_Num          IN VARCHAR2,
 	                             Cv_Contract_Num_Modifier IN VARCHAR2,
 	                             Cv_START_DATE_FROM          IN DATE,
 	                             Cv_START_DATE_TO            IN DATE,
 	                             Cv_END_DATE_FROM            IN DATE,
 	                             Cv_END_DATE_TO              IN DATE,
 	                             Cv_DATE_TERMINATE_FROM      IN DATE,
 	                             Cv_DATE_TERMINATE_TO        IN DATE,
 	                             Cv_STATUS                   IN VARCHAR2,
 	                             Cv_Cont_Pty_Id              IN NUMBER,
 	                             Cv_cont_renewal_code        IN VARCHAR2,
 	                             Cv_authoring_org_id         in number,
 	                             Cv_contract_grp_id          in number) IS
 	             SELECT /*+ leading(b) use_nl(b oksb) */
 	                     b.Id Id,                       -- 11.5.10 rule rearchitecture changes
 	                       b.renewal_type_code,           -- Added by Jvorugan for perf bug:4991724
 	                         oksb.electronic_renewal_flag   -- Added by Jvorugan for perf bug:4991724
            FROM    OKC_K_HEADERS_ALL_B B,  -- OKC_K_HEADERS_B B  -- Modified for 12.0 MOAC project (JVARGHES)
                    oks_k_headers_b oksb -- 11.5.10 rule rearchitecture changes
            WHERE   B.Id = Cv_Contract_Id --B.Id --nvl(Cv_Contract_Id,B.Id)          /*Added for Bug:6767455*/
            and     Contract_Number = nvl(Cv_Contract_Num,Contract_Number)
            --AND     nvl(Contract_Number_Modifier,-99) = nvl(Cv_Contract_Num_Modifier,nvl(Contract_Number_Modifier,-99))
            AND     ( (Cv_Contract_Num_Modifier IS NULL)
 	                      OR (Contract_Number_Modifier = Cv_Contract_Num_Modifier))
            and     b.id         = oksb.chr_id -- 11.5.10 rule rearchitecture changes
        --- truncating the dates to remove accidental existence of time components in dates.
        /*Modified for Bug:6767455*/
           /* AND     trunc(B.Start_Date) >= nvl(trunc(Cv_Start_Date_From),trunc(B.Start_Date))
            and     trunc(B.Start_Date) <= nvl(trunc(Cv_Start_Date_to),trunc(B.Start_Date))
            AND     trunc(B.End_Date)   >= nvl(trunc(Cv_End_Date_From),trunc(B.End_Date))
            AND     trunc(B.End_Date)   <= nvl(trunc(Cv_End_Date_To),trunc(B.End_Date))
            AND     nvl(trunc(B.Date_Terminated),nvl(trunc(Cv_Date_Terminate_From)-1,nvl(trunc(Cv_Date_Terminate_To)+1,trunc(sysdate)))) >=
                     nvl(trunc(Cv_Date_Terminate_From),nvl(trunc(B.Date_Terminated),trunc(sysdate)))
            AND     nvl(trunc(B.Date_Terminated),nvl(trunc(Cv_Date_Terminate_From)-1,nvl(trunc(Cv_Date_Terminate_To)+1,trunc(sysdate)))) <=
                     nvl(trunc(Cv_Date_Terminate_To),nvl(trunc(B.Date_Terminated),trunc(sysdate)))*/
           AND     B.Start_Date >= NVL(trunc(Cv_Start_Date_From),B.Start_Date)
 	             AND     B.Start_Date <= NVL((trunc(Cv_Start_Date_to)+0.99998843),B.Start_Date)
 	             AND     B.End_Date >= NVL(trunc(Cv_End_Date_From),B.End_Date)
 	             AND     B.End_Date <= NVL((trunc(Cv_End_Date_To)+0.99998843),B.End_Date)
 	             AND     ((Cv_Date_Terminate_From IS NULL) OR
 	                     (B.Date_Terminated >= trunc(Cv_Date_Terminate_From)))
 	             AND     ((Cv_Date_Terminate_To IS NULL) OR
 	                     (B.Date_Terminated <= (trunc(Cv_Date_Terminate_To)+0.99998843)))
 	 /*Modified for Bug:6767455*/
            AND     Sts_Code    = nvl(Cv_STATUS,B.Sts_Code)
            and     authoring_org_id = nvl(cv_authoring_org_id,authoring_org_id) -- multi org security check
            AND      (Cv_Cont_Pty_Id IS NULL
 	               OR
            EXISTS
                        (SELECT 'x'
                            FROM Okc_K_Party_Roles_B PR
                            WHERE pr.Cle_Id IS NULL
			                AND PR.Dnz_Chr_Id = b.Id
                           -- AND to_number(PR.Object1_Id1) = nvl(Cv_Cont_Pty_Id,to_number(PR.Object1_Id1))
                             AND PR.Object1_Id1 = TO_CHAR(Cv_Cont_Pty_Id)
                            AND PR.Object1_Id2 = '#'
                            AND PR.Jtot_Object1_Code = 'OKX_PARTY'
                            AND PR.RLE_CODE <> 'VENDOR' ))
-- where clause for contract group added dtd Dec 17th, 2003
            AND    (Cv_contract_grp_id is null
                    OR
                    EXISTS (SELECT 'x'
                            FROM Okc_K_grpings grpng
                            WHERE grpng.included_chr_id = b.id
                            and   grpng.cgp_parent_id = Cv_contract_grp_id ));
    --        and   nvl(b.renewal_type_code,'#') = nvl(Cv_cont_renewal_code,nvl(b.renewal_type_code,'#'))
            /*Added for Bug:6767455

           AND     ((Cv_cont_renewal_code IS NULL)
                       OR
                       (Cv_cont_renewal_code IS NOT NULL and Cv_cont_renewal_code not in ('ERN','NSR')
                         AND nvl(b.renewal_type_code,'#') = Cv_cont_renewal_code)
                       OR
                       (Cv_cont_renewal_code IS NOT NULL and Cv_cont_renewal_code = 'ERN'
                         AND nvl(b.renewal_type_code,'#') = 'NSR'
                         and nvl(oksb.electronic_renewal_flag,'N') = 'Y')
                       OR
                       (Cv_cont_renewal_code IS NOT NULL and Cv_cont_renewal_code = 'NSR'
                         AND nvl(b.renewal_type_code,'#') = 'NSR'
                         and nvl(oksb.electronic_renewal_flag,'N') = 'N'));
           */
  CURSOR Lx_Csr_Party_Contracts(Cv_Contract_Num          IN VARCHAR2,
 	                                  Cv_Contract_Num_Modifier IN VARCHAR2,
 	                                  Cv_START_DATE_FROM          IN DATE,
 	                                  Cv_START_DATE_TO            IN DATE,
 	                                  Cv_END_DATE_FROM            IN DATE,
 	                                  Cv_END_DATE_TO              IN DATE,
 	                                  Cv_DATE_TERMINATE_FROM      IN DATE,
 	                                  Cv_DATE_TERMINATE_TO        IN DATE,
 	                                  Cv_STATUS                   IN VARCHAR2,
 	                                  Cv_Cont_Pty_Id              IN NUMBER,
 	                                  Cv_cont_renewal_code        IN VARCHAR2,
 	                                  Cv_authoring_org_id         in number,
 	                                  Cv_contract_grp_id          in number) IS
 	             SELECT  /*+ leading(pr) use_nl(pr b oksb) */ b.Id Id,                      -- 11.5.10 rule rearchitecture changes
 	                       b.renewal_type_code,          -- Added by Jyothi for perf bug:4991724
 	                         oksb.electronic_renewal_flag  -- Added by Jyothi for perf bug:4991724
 	             FROM    OKC_K_HEADERS_ALL_B B,  -- OKC_K_HEADERS_B B  -- Modified for 12.0 MOAC project (JVARGHES)
 	                     oks_k_headers_b oksb,          -- 11.5.10 rule rearchitecture changes
 	                     Okc_K_Party_Roles_B PR
 	             WHERE   PR.Object1_Id1 = TO_CHAR(Cv_Cont_Pty_Id)
 	             AND     PR.Object1_Id2 = '#'
 	             AND     PR.Jtot_Object1_Code = 'OKX_PARTY'
 	             AND     PR.RLE_CODE <> 'VENDOR'
 	             AND     PR.Cle_Id IS NULL
 	             AND     B.ID = PR.DNZ_CHR_ID
 	             AND     B.ID = PR.CHR_ID
 	         --    AND     Contract_Number = nvl(Cv_Contract_Num,Contract_Number)
 	         --    AND     ( (Cv_Contract_Num_Modifier IS NULL)
 	         --             OR (Contract_Number_Modifier = Cv_Contract_Num_Modifier))
 	             AND     B.id = oksb.chr_id            -- 11.5.10 rule rearchitecture changes
 	             AND     B.Start_Date >= NVL(trunc(Cv_Start_Date_From),B.Start_Date)
 	             AND     B.Start_Date <= NVL((trunc(Cv_Start_Date_to)+0.99998843),B.Start_Date)
 	             AND     B.End_Date >= NVL(trunc(Cv_End_Date_From),B.End_Date)
 	             AND     B.End_Date <= NVL((trunc(Cv_End_Date_To)+0.99998843),B.End_Date)
 	             AND     ((Cv_Date_Terminate_From IS NULL) OR
 	                     (B.Date_Terminated >= trunc(Cv_Date_Terminate_From)))
 	             AND     ((Cv_Date_Terminate_To IS NULL) OR
 	                     (B.Date_Terminated <= (trunc(Cv_Date_Terminate_To)+0.99998843)))
 	             AND     sts_code = nvl(Cv_STATUS,B.Sts_Code)
 	             AND     authoring_org_id = nvl(cv_authoring_org_id,authoring_org_id); -- multi org security check

 	     -- hmnair - Added for bug fix #

 	      CURSOR Lx_Csr_Group_Contracts(Cv_Contract_Num          IN VARCHAR2,
 	                                    Cv_Contract_Num_Modifier IN VARCHAR2,
 	                                    Cv_START_DATE_FROM          IN DATE,
 	                                    Cv_START_DATE_TO            IN DATE,
 	                                    Cv_END_DATE_FROM            IN DATE,
 	                                    Cv_END_DATE_TO              IN DATE,
 	                                    Cv_DATE_TERMINATE_FROM      IN DATE,
 	                                    Cv_DATE_TERMINATE_TO        IN DATE,
 	                                    Cv_STATUS                   IN VARCHAR2,
 	                                    Cv_Cont_Pty_Id              IN NUMBER,
 	                                    Cv_cont_renewal_code        IN VARCHAR2,
 	                                    Cv_authoring_org_id         in number,
 	                                    Cv_contract_grp_id          in number) IS
 	             SELECT  /*+ leading(grpng) use_nl(grpng b oksb) */ b.Id Id,                      -- 11.5.10 rule rearchitecture changes
 	                       b.renewal_type_code,          -- Added by Jyothi for perf bug:4991724
 	                         oksb.electronic_renewal_flag  -- Added by Jyothi for perf bug:4991724
 	             FROM    OKC_K_HEADERS_ALL_B B,  -- OKC_K_HEADERS_B B  -- Modified for 12.0 MOAC project (JVARGHES)
 	                     oks_k_headers_b oksb,          -- 11.5.10 rule rearchitecture changes
 	                     Okc_K_grpings grpng
 	             WHERE   grpng.cgp_parent_id = Cv_contract_grp_id
 	             AND     B.ID = grpng.included_chr_id
 	           --  AND     Contract_Number = nvl(Cv_Contract_Num,Contract_Number)
 	           --  AND     ( (Cv_Contract_Num_Modifier IS NULL)
 	           --           OR (Contract_Number_Modifier = Cv_Contract_Num_Modifier))
 	             AND     B.id = oksb.chr_id            -- 11.5.10 rule rearchitecture changes
 	             AND     B.Start_Date >= NVL(trunc(Cv_Start_Date_From),B.Start_Date)
 	             AND     B.Start_Date <= NVL((trunc(Cv_Start_Date_to)+0.99998843),B.Start_Date)
 	             AND     B.End_Date >= NVL(trunc(Cv_End_Date_From),B.End_Date)
 	             AND     B.End_Date <= NVL((trunc(Cv_End_Date_To)+0.99998843),B.End_Date)
 	             AND     ((Cv_Date_Terminate_From IS NULL) OR
 	                     (B.Date_Terminated >= trunc(Cv_Date_Terminate_From)))
 	             AND     ((Cv_Date_Terminate_To IS NULL) OR
 	                     (B.Date_Terminated <= (trunc(Cv_Date_Terminate_To)+0.99998843)))
 	             AND     sts_code = nvl(Cv_STATUS,B.Sts_Code)
 	             AND     authoring_org_id = nvl(cv_authoring_org_id,authoring_org_id); -- multi org security check

 	     -- hmnair - Added for bug fix #

 	      CURSOR Lx_Csr_Party_Group_Contracts(Cv_Contract_Num          IN VARCHAR2,
 	                                          Cv_Contract_Num_Modifier IN VARCHAR2,
 	                                          Cv_START_DATE_FROM          IN DATE,
 	                                          Cv_START_DATE_TO            IN DATE,
 	                                          Cv_END_DATE_FROM            IN DATE,
 	                                          Cv_END_DATE_TO              IN DATE,
 	                                          Cv_DATE_TERMINATE_FROM      IN DATE,
 	                                          Cv_DATE_TERMINATE_TO        IN DATE,
 	                                          Cv_STATUS                   IN VARCHAR2,
 	                                          Cv_Cont_Pty_Id              IN NUMBER,
 	                                          Cv_cont_renewal_code        IN VARCHAR2,
 	                                          Cv_authoring_org_id         in number,
 	                                          Cv_contract_grp_id          in number) IS
 	             SELECT  /*+ ordered use_nl(pr grpng b oksb) */ b.Id Id,                      -- 11.5.10 rule rearchitecture changes
 	                       b.renewal_type_code,          -- Added by Jyothi for perf bug:4991724
 	                         oksb.electronic_renewal_flag  -- Added by Jyothi for perf bug:4991724

 	             FROM    Okc_K_Party_Roles_B PR,
 	                     Okc_K_grpings grpng,
 	                     OKC_K_HEADERS_ALL_B B,  -- OKC_K_HEADERS_B B  -- Modified for 12.0 MOAC project (JVARGHES)
 	                     oks_k_headers_b oksb          -- 11.5.10 rule rearchitecture changes

 	             WHERE   PR.Object1_Id1 = TO_CHAR(Cv_Cont_Pty_Id)
 	             AND     PR.Object1_Id2 = '#'
 	             AND     PR.Jtot_Object1_Code = 'OKX_PARTY'
 	             AND     PR.RLE_CODE <> 'VENDOR'
 	             AND     PR.Cle_Id IS NULL
 	             AND     B.ID = PR.DNZ_CHR_ID
 	             AND     B.ID = PR.CHR_ID
 	          --   AND     Contract_Number = nvl(Cv_Contract_Num,Contract_Number)
 	          --   AND     ( (Cv_Contract_Num_Modifier IS NULL)
 	          --            OR (Contract_Number_Modifier = Cv_Contract_Num_Modifier))
 	             AND     B.id = oksb.chr_id            -- 11.5.10 rule rearchitecture changes
 	             AND     B.Start_Date >= NVL(trunc(Cv_Start_Date_From),B.Start_Date)
 	             AND     B.Start_Date <= NVL((trunc(Cv_Start_Date_to)+0.99998843),B.Start_Date)
 	             AND     B.End_Date >= NVL(trunc(Cv_End_Date_From),B.End_Date)
 	             AND     B.End_Date <= NVL((trunc(Cv_End_Date_To)+0.99998843),B.End_Date)
 	             AND     ((Cv_Date_Terminate_From IS NULL) OR
 	                     (B.Date_Terminated >= trunc(Cv_Date_Terminate_From)))
 	             AND     ((Cv_Date_Terminate_To IS NULL) OR
 	                     (B.Date_Terminated <= (trunc(Cv_Date_Terminate_To)+0.99998843)))
 	             AND     sts_code = nvl(Cv_STATUS,B.Sts_Code)
 	             AND     authoring_org_id = nvl(cv_authoring_org_id,authoring_org_id)    -- multi org security check
 	             AND     grpng.included_chr_id = b.ID
 	             AND     grpng.included_chr_id = PR.DNZ_CHR_ID
 	             AND     grpng.cgp_parent_id = Cv_contract_grp_id;

 	             --Added for bug fix -- hmnair
 	             CURSOR Lx_Csr_KNum_Mod_Contracts(Cv_Contract_Num          IN VARCHAR2,
 	                             Cv_Contract_Num_Modifier IN VARCHAR2,
 	                             Cv_START_DATE_FROM          IN DATE,
 	                             Cv_START_DATE_TO            IN DATE,
 	                             Cv_END_DATE_FROM            IN DATE,
 	                             Cv_END_DATE_TO              IN DATE,
 	                             Cv_DATE_TERMINATE_FROM      IN DATE,
 	                             Cv_DATE_TERMINATE_TO        IN DATE,
 	                             Cv_STATUS                   IN VARCHAR2,
 	                             Cv_Cont_Pty_Id              IN NUMBER,
 	                             Cv_cont_renewal_code        IN VARCHAR2,
 	                             Cv_authoring_org_id         in number,
 	                             Cv_contract_grp_id          in number) IS
 	             SELECT /*+ leadin(b) use_nl(b oksb) */ b.Id Id,                      -- 11.5.10 rule rearchitecture changes
 	                       b.renewal_type_code,          -- Added by Jyothi for perf bug:4991724
 	                         oksb.electronic_renewal_flag  -- Added by Jyothi for perf bug:4991724
 	             FROM    OKC_K_HEADERS_ALL_B B,  -- OKC_K_HEADERS_B B  -- Modified for 12.0 MOAC project (JVARGHES)
 	                     oks_k_headers_b oksb          -- 11.5.10 rule rearchitecture changes
 	             WHERE   Contract_Number = Cv_Contract_Num
 	    --         AND     ( (Cv_Contract_Num_Modifier IS NULL)
 	               AND    Contract_Number_Modifier = Cv_Contract_Num_Modifier
 	               AND     b.id = oksb.chr_id            -- 11.5.10 rule rearchitecture changes
 	    --
 	    --  Modified by JVARGHES on 23/May/2006 for fix of bug# 4991724
 	    --       AND     trunc(B.Start_Date) >= nvl(trunc(Cv_Start_Date_From),trunc(B.Start_Date))  -- truncating the dates to remove
 	    --       and     trunc(B.Start_Date) <= nvl(trunc(Cv_Start_Date_to),trunc(B.Start_Date))    -- accidental existence of time components in dates.
 	    --       AND     trunc(B.End_Date)   >= nvl(trunc(Cv_End_Date_From),trunc(B.End_Date))
 	    --       AND     trunc(B.End_Date)   <= nvl(trunc(Cv_End_Date_To),trunc(B.End_Date))
 	    --       AND     nvl(trunc(B.Date_Terminated),nvl(trunc(Cv_Date_Terminate_From)-1,nvl(trunc(Cv_Date_Terminate_To)+1,trunc(sysdate)))) >=
 	    --               nvl(trunc(Cv_Date_Terminate_From),nvl(trunc(B.Date_Terminated),trunc(sysdate)))
 	    --       AND     nvl(trunc(B.Date_Terminated),nvl(trunc(Cv_Date_Terminate_From)-1,nvl(trunc(Cv_Date_Terminate_To)+1,trunc(sysdate)))) <=
 	    --               nvl(trunc(Cv_Date_Terminate_To),nvl(trunc(B.Date_Terminated),trunc(sysdate)))
 	             AND     B.Start_Date >= NVL(trunc(Cv_Start_Date_From),B.Start_Date)
 	             AND     B.Start_Date <= NVL((trunc(Cv_Start_Date_to)+0.99998843),B.Start_Date)
 	             AND     B.End_Date >= NVL(trunc(Cv_End_Date_From),B.End_Date)
 	             AND     B.End_Date <= NVL((trunc(Cv_End_Date_To)+0.99998843),B.End_Date)
 	             AND     ((Cv_Date_Terminate_From IS NULL) OR
 	                     (B.Date_Terminated >= trunc(Cv_Date_Terminate_From)))
 	             AND     ((Cv_Date_Terminate_To IS NULL) OR
 	                     (B.Date_Terminated <= (trunc(Cv_Date_Terminate_To)+0.99998843)))
 	    --
 	    --  Modified by JVARGHES on 23/May/2006 for fix of bug# 4991724
 	    --
 	             AND     sts_code = nvl(Cv_STATUS,B.Sts_Code)
 	             AND     authoring_org_id = nvl(cv_authoring_org_id,authoring_org_id) -- multi org security check
 	             AND    (Cv_Cont_Pty_Id IS NULL
                               OR
                              EXISTS (SELECT 'x'
                               FROM Okc_K_Party_Roles_B PR
 	                       WHERE pr.Cle_Id IS NULL
 	                       AND PR.Dnz_Chr_Id = b.Id
 	               --    AND to_number(PR.Object1_Id1) = nvl(Cv_Cont_Pty_Id,to_number(PR.Object1_Id1))
 	                       AND PR.Object1_Id1 = TO_CHAR(Cv_Cont_Pty_Id)
 	                        AND PR.Object1_Id2 = '#'
 	                        AND PR.Jtot_Object1_Code = 'OKX_PARTY'
 	                        AND PR.RLE_CODE <> 'VENDOR'))
 	                      AND    (Cv_contract_grp_id is null     --  Where clause for contract group added dtd Dec 17th, 2003
                                  OR
                          EXISTS (SELECT 'x'
                          FROM Okc_K_grpings grpng
                          WHERE grpng.included_chr_id = b.id
                          AND   grpng.cgp_parent_id = Cv_contract_grp_id ));
                          /*Added for Bug:6767455*/
  CURSOR Lx_Csr_ContractNum_Contracts(Cv_Contract_Num         IN VARCHAR2,
                            Cv_Contract_Num_Modifier IN VARCHAR2,
                            Cv_START_DATE_FROM          IN DATE,
                            Cv_START_DATE_TO            IN DATE,
                            Cv_END_DATE_FROM            IN DATE,
                            Cv_END_DATE_TO              IN DATE,
                            Cv_DATE_TERMINATE_FROM      IN DATE,
                            Cv_DATE_TERMINATE_TO        IN DATE,
                            Cv_STATUS                   IN VARCHAR2,
                            Cv_Cont_Pty_Id              IN NUMBER,
                            Cv_cont_renewal_code        IN VARCHAR2,
                            Cv_authoring_org_id         in number,
                            Cv_contract_grp_id          in number) IS
            SELECT  /*+ leadin(b) use_nl(b oksb) */ b.Id Id,  -- 11.5.10 rule rearchitecture changes
                    b.renewal_type_code,          -- Added by Jyothi for perf bug:4991724
 	            oksb.electronic_renewal_flag  -- Added by Jyothi for perf bug:4991724
            FROM    OKC_K_HEADERS_ALL_B B,  -- OKC_K_HEADERS_B B  -- Modified for 12.0 MOAC project (JVARGHES)
                    oks_k_headers_b oksb -- 11.5.10 rule rearchitecture changes
             WHERE   Contract_Number = Cv_Contract_Num
            /*and     Contract_Number = nvl(Cv_Contract_Num,Contract_Number)
            AND     nvl(Contract_Number_Modifier,-99) = nvl(Cv_Contract_Num_Modifier,nvl(Contract_Number_Modifier,-99))*/
            and     b.id         = oksb.chr_id
        --- truncating the dates to remove accidental existence of time components in dates.
        /*Commented for Bug:6767455
            AND     trunc(B.Start_Date) >= nvl(trunc(Cv_Start_Date_From),trunc(B.Start_Date))
            and     trunc(B.Start_Date) <= nvl(trunc(Cv_Start_Date_to),trunc(B.Start_Date))
            AND     trunc(B.End_Date)   >= nvl(trunc(Cv_End_Date_From),trunc(B.End_Date))
            AND     trunc(B.End_Date)   <= nvl(trunc(Cv_End_Date_To),trunc(B.End_Date))
            AND     nvl(trunc(B.Date_Terminated),nvl(trunc(Cv_Date_Terminate_From)-1,nvl(trunc(Cv_Date_Terminate_To)+1,trunc(sysdate)))) >=
                     nvl(trunc(Cv_Date_Terminate_From),nvl(trunc(B.Date_Terminated),trunc(sysdate)))
            AND     nvl(trunc(B.Date_Terminated),nvl(trunc(Cv_Date_Terminate_From)-1,nvl(trunc(Cv_Date_Terminate_To)+1,trunc(sysdate)))) <=
                     nvl(trunc(Cv_Date_Terminate_To),nvl(trunc(B.Date_Terminated),trunc(sysdate)))*/
             AND     B.Start_Date >= NVL(trunc(Cv_Start_Date_From),B.Start_Date)
             AND     B.Start_Date <= NVL((trunc(Cv_Start_Date_to)+0.99998843),B.Start_Date)
 	     AND     B.End_Date >= NVL(trunc(Cv_End_Date_From),B.End_Date)
 	     AND     B.End_Date <= NVL((trunc(Cv_End_Date_To)+0.99998843),B.End_Date)
 	     AND     ((Cv_Date_Terminate_From IS NULL) OR
 	                     (B.Date_Terminated >= trunc(Cv_Date_Terminate_From)))
 	    AND     ((Cv_Date_Terminate_To IS NULL) OR
 	                     (B.Date_Terminated <= (trunc(Cv_Date_Terminate_To)+0.99998843)))
            AND     Sts_Code    = nvl(Cv_STATUS,B.Sts_Code)
            and     authoring_org_id = nvl(cv_authoring_org_id,authoring_org_id) -- multi org security check
            AND    (Cv_Cont_Pty_Id IS NULL
                     OR
                     EXISTS
                        (SELECT 'x'
                            FROM Okc_K_Party_Roles_B PR
                            WHERE pr.Cle_Id IS NULL
			                AND PR.Dnz_Chr_Id = b.Id
                            --AND to_number(PR.Object1_Id1) = nvl(Cv_Cont_Pty_Id,to_number(PR.Object1_Id1))
                            AND PR.Object1_Id1 = TO_CHAR(Cv_Cont_Pty_Id)
                            AND PR.Object1_Id2 = '#'
                            AND PR.Jtot_Object1_Code = 'OKX_PARTY'
                            AND PR.RLE_CODE <> 'VENDOR' ))
-- where clause for contract group added dtd Dec 17th, 2003
            AND    (Cv_contract_grp_id is null
                    OR
                    EXISTS (SELECT 'x'
                            FROM Okc_K_grpings grpng
                            WHERE grpng.included_chr_id = b.id
                            and   grpng.cgp_parent_id = Cv_contract_grp_id ));
                            /*commented for bug:6767455
    --        and   nvl(b.renewal_type_code,'#') = nvl(Cv_cont_renewal_code,nvl(b.renewal_type_code,'#'))
            AND     ((Cv_cont_renewal_code IS NULL)
                       OR
                       (Cv_cont_renewal_code IS NOT NULL and Cv_cont_renewal_code not in ('ERN','NSR')
                         AND nvl(b.renewal_type_code,'#') = Cv_cont_renewal_code)
                       OR
                       (Cv_cont_renewal_code IS NOT NULL and Cv_cont_renewal_code = 'ERN'
                         AND nvl(b.renewal_type_code,'#') = 'NSR'
                         and nvl(oksb.electronic_renewal_flag,'N') = 'Y')
                       OR
                       (Cv_cont_renewal_code IS NOT NULL and Cv_cont_renewal_code = 'NSR'
                         AND nvl(b.renewal_type_code,'#') = 'NSR'
                         and nvl(oksb.electronic_renewal_flag,'N') = 'N'));*/

    Lv_Contract_Id              CONSTANT NUMBER :=    P_Contract_Id;
    Lv_Contract_Num             CONSTANT VARCHAR2(120) :=    P_Contract_Num;
    Lv_Contract_Num_Modifier    CONSTANT VARCHAR2(120) :=    P_Contract_Num_Modifier;
    Lv_START_FROM_DATE          DATE;
    Lv_START_TO_DATE            DATE;
    Lv_END_FROM_DATE             DATE;
    Lv_END_TO_DATE               DATE;
    Lv_FROM_TERMINATE_DATE       DATE;
    Lv_TO_TERMINATE_DATE         DATE;
    Lv_STATUS                   CONSTANT VARCHAR2(120) :=    P_STATUS;
    Lv_Cont_Pty_Id              CONSTANT NUMBER        :=    P_Cont_Pty_Id;
    Lv_Cont_Renewal_Code        CONSTANT VARCHAR2(120) :=    P_cont_renewal_code;
    Lv_authoring_org_id         CONSTANT number        :=    P_authoring_org_id;
    Lv_contract_grp_id          CONSTANT number        :=    P_contract_grp_id;
    Lx_Result                  Gx_Boolean;
    Lx_Return_Status           Gx_Ret_Sts;

    l_last_date                DATE;
    l_first_date               DATE;

    Lx_Contracts               GT_Contract_Ref;
    Li_TableIdx                BINARY_INTEGER;

  BEGIN
    l_last_date                  :=   TO_DATE(5373484,'j');
    l_first_date                 :=   TO_DATE(1,'j');
    Lv_START_FROM_DATE           :=    P_START_DATE_FROM;
    Lv_START_TO_DATE             :=    P_START_DATE_TO;
    Lv_END_FROM_DATE             :=    P_END_DATE_FROM;
    Lv_END_TO_DATE               :=    P_END_DATE_TO;
    Lv_FROM_TERMINATE_DATE       :=    P_DATE_TERMINATE_FROM;
    Lv_TO_TERMINATE_DATE         :=    P_DATE_TERMINATE_TO;
    Lx_Result                    :=    G_TRUE;
    Lx_Return_Status             :=    G_RET_STS_SUCCESS;

    Li_TableIdx           := 0;

    if Lv_Contract_Id is not null then
        FOR Idx IN Lx_Csr_Hdr_Contracts(Lv_Contract_Id,
                                    Lv_Contract_Num,
                                    Lv_Contract_Num_Modifier,
                                    Lv_START_FROM_DATE,
                                    Lv_START_TO_DATE,
                                    Lv_END_FROM_DATE,
                                    Lv_END_TO_DATE,
                                    Lv_FROM_TERMINATE_DATE,
                                    Lv_TO_TERMINATE_DATE,
                                    Lv_STATUS,
                                    Lv_Cont_Pty_Id,
                                    Lv_Cont_Renewal_Code,
                                    Lv_authoring_org_id,
                                    Lv_contract_grp_id) LOOP
                 IF ((Lv_Cont_Renewal_Code IS NULL)                                  /*Added for bug:6767455*/
 	                        OR
 	                        (Lv_Cont_Renewal_Code IS NOT NULL and Lv_Cont_Renewal_Code not in ('ERN','NSR')
 	                          AND nvl(Idx.renewal_type_code,'#') = Lv_Cont_Renewal_Code)
 	                        OR
 	                        (Lv_Cont_Renewal_Code IS NOT NULL and Lv_Cont_Renewal_Code = 'ERN'
 	                          AND nvl(Idx.renewal_type_code,'#') = 'NSR'
 	                          and nvl(Idx.electronic_renewal_flag,'N') = 'Y')
 	                        OR
 	                        (Lv_Cont_Renewal_Code IS NOT NULL and Lv_Cont_Renewal_Code = 'NSR'
 	                          AND nvl(Idx.renewal_type_code,'#') = 'NSR'
 	                          and nvl(Idx.electronic_renewal_flag,'N') = 'N'))
 	            THEN
            Li_TableIdx  := Li_TableIdx + 1;
            Lx_Contracts(Li_TableIdx).Rx_Chr_Id := Idx.Id;
            END IF;

        END LOOP;
    ELSIF (Lv_Contract_Num IS NOT NULL AND Lv_Contract_Num_Modifier IS NOT NULL )THEN          /*Added for bug:6767455*/
        FOR Idx IN Lx_Csr_KNum_Mod_Contracts(Lv_Contract_Num,
                                    Lv_Contract_Num_Modifier,
                                    Lv_START_FROM_DATE,
                                    Lv_START_TO_DATE,
                                    Lv_END_FROM_DATE,
                                    Lv_END_TO_DATE,
                                    Lv_FROM_TERMINATE_DATE,
                                    Lv_TO_TERMINATE_DATE,
                                    Lv_STATUS,
                                    Lv_Cont_Pty_Id,
                                    Lv_Cont_Renewal_Code,
                                    Lv_authoring_org_id,
                                    Lv_contract_grp_id) LOOP
       IF  ((Lv_Cont_Renewal_Code IS NULL)
 	                        OR
 	                        (Lv_Cont_Renewal_Code IS NOT NULL and Lv_Cont_Renewal_Code not in ('ERN','NSR')
 	                          AND nvl(Idx.renewal_type_code,'#') = Lv_Cont_Renewal_Code)
 	                        OR
 	                        (Lv_Cont_Renewal_Code IS NOT NULL and Lv_Cont_Renewal_Code = 'ERN'
 	                          AND nvl(Idx.renewal_type_code,'#') = 'NSR'
 	                          and nvl(Idx.electronic_renewal_flag,'N') = 'Y')
 	                        OR
 	                        (Lv_Cont_Renewal_Code IS NOT NULL and Lv_Cont_Renewal_Code = 'NSR'
 	                          AND nvl(Idx.renewal_type_code,'#') = 'NSR'
 	                          and nvl(Idx.electronic_renewal_flag,'N') = 'N'))
 	           THEN

            Li_TableIdx  := Li_TableIdx + 1;
            Lx_Contracts(Li_TableIdx).Rx_Chr_Id := Idx.Id;
     END IF;

        END LOOP;

  ELSIF Lv_Contract_Num IS NOT NULL THEN
    FOR Idx IN Lx_Csr_ContractNum_Contracts(Lv_Contract_Num,
                      Lv_Contract_Num_Modifier,
                      Lv_START_FROM_DATE,
                      Lv_START_TO_DATE,
                       Lv_END_FROM_DATE,
                       Lv_END_TO_DATE,
                       Lv_FROM_TERMINATE_DATE,
 	                Lv_TO_TERMINATE_DATE,
 	               Lv_STATUS,
 	                Lv_Cont_Pty_Id,
 	                Lv_Cont_Renewal_Code,
 	                Lv_authoring_org_id,
 	                Lv_contract_grp_id) LOOP
 	           IF  ((Lv_Cont_Renewal_Code IS NULL)
 	                        OR
 	                        (Lv_Cont_Renewal_Code IS NOT NULL and Lv_Cont_Renewal_Code not in ('ERN','NSR')
 	                          AND nvl(Idx.renewal_type_code,'#') = Lv_Cont_Renewal_Code)
 	                        OR
 	                        (Lv_Cont_Renewal_Code IS NOT NULL and Lv_Cont_Renewal_Code = 'ERN'
 	                          AND nvl(Idx.renewal_type_code,'#') = 'NSR'
 	                          and nvl(Idx.electronic_renewal_flag,'N') = 'Y')
 	                        OR
 	                        (Lv_Cont_Renewal_Code IS NOT NULL and Lv_Cont_Renewal_Code = 'NSR'
 	                          AND nvl(Idx.renewal_type_code,'#') = 'NSR'
 	                          and nvl(Idx.electronic_renewal_flag,'N') = 'N'))
 	           THEN
                     Li_TableIdx  := Li_TableIdx + 1;
 	               Lx_Contracts(Li_TableIdx).Rx_Chr_Id := Idx.Id;
 	           END IF;
           END LOOP;

   /* commented for bug:6767455  OKC_API.SET_MESSAGE
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
	,P_Token2_Value   => 'Get_Contract_Id');

    X_Result            := G_FALSE;
    X_Return_Status     := G_RET_STS_UNEXP_ERROR;

END Get_Contract_ID;*/
 ELSIF (Lv_Cont_Pty_Id IS NOT NULL AND Lv_contract_grp_id IS NOT NULL) THEN
  FOR Idx IN Lx_Csr_Party_Group_Contracts(Lv_Contract_Num,
                                Lv_Contract_Num_Modifier,
                                Lv_START_FROM_DATE,
                                Lv_START_TO_DATE,
                                Lv_END_FROM_DATE,
                                Lv_END_TO_DATE,
                                Lv_FROM_TERMINATE_DATE,
 	                        Lv_TO_TERMINATE_DATE,
 	                        Lv_STATUS,
 	                        Lv_Cont_Pty_Id,
 	                        Lv_Cont_Renewal_Code,
 	                        Lv_authoring_org_id,
 	                        Lv_contract_grp_id) LOOP
 	           IF  ((Lv_Cont_Renewal_Code IS NULL)
 	                        OR
 	                        (Lv_Cont_Renewal_Code IS NOT NULL and Lv_Cont_Renewal_Code not in ('ERN','NSR')
 	                          AND nvl(Idx.renewal_type_code,'#') = Lv_Cont_Renewal_Code)
 	                        OR
 	                        (Lv_Cont_Renewal_Code IS NOT NULL and Lv_Cont_Renewal_Code = 'ERN'
 	                          AND nvl(Idx.renewal_type_code,'#') = 'NSR'
 	                          and nvl(Idx.electronic_renewal_flag,'N') = 'Y')
 	                        OR
 	                        (Lv_Cont_Renewal_Code IS NOT NULL and Lv_Cont_Renewal_Code = 'NSR'
 	                          AND nvl(Idx.renewal_type_code,'#') = 'NSR'
 	                          and nvl(Idx.electronic_renewal_flag,'N') = 'N'))
 	           THEN
                   Li_TableIdx  := Li_TableIdx + 1;
                   Lx_Contracts(Li_TableIdx).Rx_Chr_Id := Idx.Id;
                    END IF;
                 END LOOP;
 	     ELSIF (Lv_Cont_Pty_Id IS NOT NULL) THEN
 	            FOR Idx IN Lx_Csr_Party_Contracts(Lv_Contract_Num,
 	                                     Lv_Contract_Num_Modifier,
 	                                     Lv_START_FROM_DATE,
 	                                     Lv_START_TO_DATE,
 	                                     Lv_END_FROM_DATE,
 	                                     Lv_END_TO_DATE,
 	                                     Lv_FROM_TERMINATE_DATE,
 	                                     Lv_TO_TERMINATE_DATE,
 	                                     Lv_STATUS,
 	                                     Lv_Cont_Pty_Id,
 	                                     Lv_Cont_Renewal_Code,
 	                                     Lv_authoring_org_id,
 	                                     Lv_contract_grp_id) LOOP
 	           IF  ((Lv_Cont_Renewal_Code IS NULL)
 	                        OR
 	                        (Lv_Cont_Renewal_Code IS NOT NULL and Lv_Cont_Renewal_Code not in ('ERN','NSR')
 	                          AND nvl(Idx.renewal_type_code,'#') = Lv_Cont_Renewal_Code)
 	                        OR
 	                        (Lv_Cont_Renewal_Code IS NOT NULL and Lv_Cont_Renewal_Code = 'ERN'
 	                          AND nvl(Idx.renewal_type_code,'#') = 'NSR'
 	                          and nvl(Idx.electronic_renewal_flag,'N') = 'Y')
 	                        OR
 	                        (Lv_Cont_Renewal_Code IS NOT NULL and Lv_Cont_Renewal_Code = 'NSR'
 	                          AND nvl(Idx.renewal_type_code,'#') = 'NSR'
 	                          and nvl(Idx.electronic_renewal_flag,'N') = 'N'))
 	           THEN
                         Li_TableIdx  := Li_TableIdx + 1;
                         Lx_Contracts(Li_TableIdx).Rx_Chr_Id := Idx.Id;
                         END IF;
                          END LOOP;
ELSIF (Lv_contract_grp_id IS NOT NULL) THEN
 FOR Idx IN Lx_Csr_Group_Contracts(Lv_Contract_Num,
                                   Lv_Contract_Num_Modifier,
 	                           Lv_START_FROM_DATE,
 	                           Lv_START_TO_DATE,
 	                           Lv_END_FROM_DATE,
 	                           Lv_END_TO_DATE,
 	                           Lv_FROM_TERMINATE_DATE,
 	                           Lv_TO_TERMINATE_DATE,
 	                           Lv_STATUS,
 	                           Lv_Cont_Pty_Id,
 	                           Lv_Cont_Renewal_Code,
 	                           Lv_authoring_org_id,
 	                           Lv_contract_grp_id) LOOP
 	           IF  ((Lv_Cont_Renewal_Code IS NULL)
 	                        OR
 	                        (Lv_Cont_Renewal_Code IS NOT NULL and Lv_Cont_Renewal_Code not in ('ERN','NSR')
 	                          AND nvl(Idx.renewal_type_code,'#') = Lv_Cont_Renewal_Code)
 	                        OR
 	                        (Lv_Cont_Renewal_Code IS NOT NULL and Lv_Cont_Renewal_Code = 'ERN'
 	                          AND nvl(Idx.renewal_type_code,'#') = 'NSR'
 	                          and nvl(Idx.electronic_renewal_flag,'N') = 'Y')
 	                        OR
 	                        (Lv_Cont_Renewal_Code IS NOT NULL and Lv_Cont_Renewal_Code = 'NSR'
 	                          AND nvl(Idx.renewal_type_code,'#') = 'NSR'
 	                          and nvl(Idx.electronic_renewal_flag,'N') = 'N'))
 	           THEN

 	               Li_TableIdx  := Li_TableIdx + 1;
 	               Lx_Contracts(Li_TableIdx).Rx_Chr_Id := Idx.Id;
 	           END IF;

 	         END LOOP;
 	     ELSIF (Lv_FROM_TERMINATE_DATE IS NOT NULL OR Lv_TO_TERMINATE_DATE IS NOT NULL) THEN     /*Added for bug:6767455*/

 	         IF (Lv_START_FROM_DATE IS NULL) THEN
 	             Lv_START_FROM_DATE := l_first_date;
 	         END IF;

 	         IF (Lv_START_TO_DATE IS NULL) THEN
 	             Lv_START_TO_DATE := l_last_date;
 	         END IF;

 	         IF (Lv_END_FROM_DATE IS NULL) THEN
 	             Lv_END_FROM_DATE := l_first_date;
 	          END IF;

 	         IF (Lv_END_TO_DATE IS NULL) THEN
 	             Lv_END_TO_DATE := l_last_date;
 	         END IF;

 	         IF (Lv_FROM_TERMINATE_DATE IS NULL) THEN
 	             Lv_FROM_TERMINATE_DATE := l_first_date;
 	         END IF;

 	         IF (Lv_TO_TERMINATE_DATE IS NULL) THEN
 	             Lv_TO_TERMINATE_DATE := l_last_date;
 	         END IF;


 	         Lv_START_FROM_DATE := TRUNC(Lv_START_FROM_DATE);
 	         Lv_END_FROM_DATE   := TRUNC(Lv_END_FROM_DATE);
 	         Lv_START_TO_DATE   := TRUNC(Lv_START_TO_DATE) + 0.99998843;
 	         Lv_END_TO_DATE     := TRUNC(Lv_END_TO_DATE) + 0.99998843;
 	         Lv_TO_TERMINATE_DATE   := TRUNC(Lv_TO_TERMINATE_DATE) + 0.99998843;                    /*Added for bug:6767455*/
 	         Lv_FROM_TERMINATE_DATE := TRUNC(Lv_FROM_TERMINATE_DATE);


 	         FOR Idx IN Lx_Csr_terdt_Contracts(Lv_Contract_Id,
 	                                     Lv_Contract_Num,
 	                                     Lv_Contract_Num_Modifier,
 	                                     Lv_START_FROM_DATE,
 	                                     Lv_START_TO_DATE,
 	                                     Lv_END_FROM_DATE,
 	                                     Lv_END_TO_DATE,
 	                                     Lv_FROM_TERMINATE_DATE,
 	                                     Lv_TO_TERMINATE_DATE,
 	                                     Lv_STATUS,
 	                                     Lv_Cont_Pty_Id,
 	                                     Lv_Cont_Renewal_Code,
 	                                     Lv_authoring_org_id,
 	                                     Lv_contract_grp_id) LOOP
 	           IF  ((Lv_Cont_Renewal_Code IS NULL)
 	                        OR
 	                        (Lv_Cont_Renewal_Code IS NOT NULL and Lv_Cont_Renewal_Code not in ('ERN','NSR')
 	                          AND nvl(Idx.renewal_type_code,'#') = Lv_Cont_Renewal_Code)
 	                        OR
 	                        (Lv_Cont_Renewal_Code IS NOT NULL and Lv_Cont_Renewal_Code = 'ERN'
 	                          AND nvl(Idx.renewal_type_code,'#') = 'NSR'
 	                          and nvl(Idx.electronic_renewal_flag,'N') = 'Y')
 	                        OR
 	                        (Lv_Cont_Renewal_Code IS NOT NULL and Lv_Cont_Renewal_Code = 'NSR'
 	                          AND nvl(Idx.renewal_type_code,'#') = 'NSR'
 	                          and nvl(Idx.electronic_renewal_flag,'N') = 'N'))
 	           THEN

 	               Li_TableIdx  := Li_TableIdx + 1;
 	               Lx_Contracts(Li_TableIdx).Rx_Chr_Id := Idx.Id;
 	           END IF;

 	         END LOOP;
 	     ELSE
 	         IF (Lv_START_FROM_DATE IS NULL) THEN
 	             Lv_START_FROM_DATE := l_first_date;
 	         END IF;

 	         IF (Lv_START_TO_DATE IS NULL) THEN
 	             Lv_START_TO_DATE := l_last_date;
 	         END IF;

 	         IF (Lv_END_FROM_DATE IS NULL) THEN
 	             Lv_END_FROM_DATE := l_first_date;
 	          END IF;

 	         IF (Lv_END_TO_DATE IS NULL) THEN
 	             Lv_END_TO_DATE := l_last_date;
 	         END IF;


 	         Lv_START_FROM_DATE := TRUNC(Lv_START_FROM_DATE);
 	         Lv_END_FROM_DATE   := TRUNC(Lv_END_FROM_DATE);
 	         Lv_START_TO_DATE   := TRUNC(Lv_START_TO_DATE) + 0.99998843;
 	         Lv_END_TO_DATE     := TRUNC(Lv_END_TO_DATE) + 0.99998843;

 	         FOR Idx IN Lx_Csr_NoHdr_Contracts(Lv_Contract_Id,
 	                                     Lv_Contract_Num,
 	                                     Lv_Contract_Num_Modifier,
 	                                     Lv_START_FROM_DATE,
 	                                     Lv_START_TO_DATE,
 	                                     Lv_END_FROM_DATE,
 	                                     Lv_END_TO_DATE,
 	                                     Lv_FROM_TERMINATE_DATE,
 	                                     Lv_TO_TERMINATE_DATE,
 	                                     Lv_STATUS,
 	                                     Lv_Cont_Pty_Id,
 	                                     Lv_Cont_Renewal_Code,
 	                                     Lv_authoring_org_id,
 	                                     Lv_contract_grp_id) LOOP
 	           IF  ((Lv_Cont_Renewal_Code IS NULL)
 	                        OR
 	                        (Lv_Cont_Renewal_Code IS NOT NULL and Lv_Cont_Renewal_Code not in ('ERN','NSR')
 	                          AND nvl(Idx.renewal_type_code,'#') = Lv_Cont_Renewal_Code)
 	                        OR
 	                        (Lv_Cont_Renewal_Code IS NOT NULL and Lv_Cont_Renewal_Code = 'ERN'
 	                          AND nvl(Idx.renewal_type_code,'#') = 'NSR'
 	                          and nvl(Idx.electronic_renewal_flag,'N') = 'Y')
 	                        OR
 	                        (Lv_Cont_Renewal_Code IS NOT NULL and Lv_Cont_Renewal_Code = 'NSR'
 	                          AND nvl(Idx.renewal_type_code,'#') = 'NSR'
 	                          and nvl(Idx.electronic_renewal_flag,'N') = 'N'))
 	           THEN

 	               Li_TableIdx  := Li_TableIdx + 1;
 	               Lx_Contracts(Li_TableIdx).Rx_Chr_Id := Idx.Id;
 	           END IF;

 	         END LOOP;
 	     END IF;

 	     X_Contracts          := Lx_Contracts;
 	     X_Result             := Lx_Result;
 	     X_Return_Status      := Lx_Return_Status;


 	   EXCEPTION

 	     WHEN OTHERS THEN

 	     OKC_API.SET_MESSAGE
 	     (P_App_Name   => G_APP_NAME_OKC
 	         ,P_Msg_Name          => G_UNEXPECTED_ERROR
 	         ,P_Token1          => G_SQLCODE_TOKEN
 	         ,P_Token1_Value          => SQLCODE
 	         ,P_Token2          => G_SQLERRM_TOKEN
 	         ,P_Token2_Value   => SQLERRM);

 	     OKC_API.SET_MESSAGE
 	     (P_App_Name   => G_APP_NAME_OKC
 	         ,P_Msg_Name          => G_DEBUG_TOKEN
 	         ,P_Token1          => G_PACKAGE_TOKEN
 	         ,P_Token1_Value          => G_PKG_NAME
 	         ,P_Token2          => G_PROGRAM_TOKEN
 	         ,P_Token2_Value   => 'Get_Contract_Id');

 	     X_Result            := G_FALSE;
 	     X_Return_Status     := G_RET_STS_UNEXP_ERROR;

 	 END Get_Contract_ID;

 	 PROCEDURE Dedup_Service_Line_PlSql_Table
 	     (P_Input_Tab          IN  output_tbl_contractline
 	     ,X_Output_Tab         OUT NOCOPY output_tbl_contractline
 	     ,X_Result             OUT NOCOPY Gx_Boolean
 	     ,X_Return_Status      OUT NOCOPY Gx_Ret_Sts)  IS

 	     Lx_DeDup_Tab          output_tbl_contractline;
 	     Lx_DeDup_Tab2         output_tbl_contractline ;
 	     Lx_Result             Gx_Boolean;
 	     Lx_Return_Status      Gx_Ret_Sts;
             Lx_Temp_ContRef       OKS_ENTITLEMENTS_PUB.output_rec_contractline;
             Li_TableIdx            BINARY_INTEGER;
    Li_TableIdx_Out        BINARY_INTEGER;
    Li_TableIdx_In         BINARY_INTEGER;

    Lv_Compare_Val1       OKC_K_LINES_B.ID%TYPE;--VARCHAR2(300);
    Lv_Compare_Val2       OKC_K_LINES_B.ID%TYPE;--VARCHAR2(300);
    K                     NUMBER;
    L_Found               VARCHAR2(1);

BEGIN

    Lx_DeDup_Tab          := P_Input_Tab;
    Lx_Result             := G_TRUE;
    Lx_Return_Status      := G_RET_STS_SUCCESS;
    K                     := 1;
    L_Found               := 'N';

    FOR I IN Lx_DeDup_Tab.FIRST .. Lx_DeDup_Tab.LAST LOOP

        IF Lx_DeDup_Tab2.COUNT > 0 THEN
            L_Found := 'N';
            FOR J IN Lx_DeDup_Tab2.FIRST .. Lx_DeDup_Tab2.LAST LOOP
                IF   Lx_DeDup_Tab(I).Service_ID = Lx_DeDup_Tab2(J).Service_Id THEN

                    L_Found := 'Y';

                END IF;

            END LOOP;
                IF L_Found = 'N' THEN

                    K := K + 1;
                    Lx_DeDup_Tab2(K) := Lx_DeDup_Tab(I);

                END IF;

        ELSE
            Lx_DeDup_Tab2(1) := Lx_DeDup_Tab(I);

        END IF;
    END LOOP;


    Lx_DeDup_Tab.DELETE;
    Lx_DeDup_Tab := Lx_DeDup_Tab2;
    X_Output_Tab          := Lx_DeDup_Tab;
    X_Result              := Lx_Result;
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
	,P_Token2_Value   => 'Dedup_Service_Line_PlSql_Table');

      X_Result         := G_FALSE;
      X_Return_Status  := G_RET_STS_UNEXP_ERROR;

END Dedup_Service_Line_PlSql_Table;

PROCEDURE Get_Contract_Lines
            (P_Contracts               IN      GT_Contract_Ref
            ,P_Contract_line_Rec       IN      srchline_inpcontlinerec_type
            ,P_Covlevel_lines_passed   IN      varchar2
            ,P_Request_Date            IN      DATE
            ,P_Entitlement_Check_YN    IN      Varchar2
            ,p_authoring_org_id        in      number
            ,X_Contracts_02            OUT     nocopy output_tbl_contractline
            ,X_Result                  OUT     nocopy Gx_Boolean
            ,X_Return_Status           OUT     nocopy Gx_Ret_Sts) IS



--
-- Modified for 12.0 Coverage Rearch project (JVARGHES)
--

/*

CURSOR  get_Contract_cur   (P_Id IN NUMBER,
                            P_Cle_Id IN NUMBER,
                            P_Service_Item_id IN NUMBER,
                            P_Sts_Code          IN VARCHAR2,
                            P_Start_Date_From  IN DATE,
                            P_Start_Date_TO    IN DATE,
                            P_END_Date_From    IN DATE,
                            P_END_Date_TO      IN DATE,
                            P_Cov_type          IN VARCHAR2,
                            P_Bill_To           IN VARCHAR2,
                            P_Ship_To           IN VARCHAR2,
                            P_renewal_code      IN VARCHAR2,
                            p_authoring_org_id  in number) IS
        SELECT Hd.Id    Id,
               Hd.Contract_Number   Contract_Number,
               Hd.Contract_Number_Modifier Contract_Number_Modifier,
               Hd.Short_Description Short_Description,
               Hd.Start_Date    Hd_Start_Date,
               Hd.End_Date      Hd_End_Date,
               hd.scs_code      hd_scs_code,
               Sv.Id Service_ID,
               Sv.Line_Number Line_Number,
        --- truncating the dates to remove accidental existence of time components in dates.
               trunc(Sv.Start_Date) Start_Date,
               trunc(Sv.End_Date) End_Date,
               trunc(Sv.Date_Terminated) Date_Terminated,
               Sv.Sts_code Sts_code,
               SYS.description     Name,
        --- truncating the dates to remove accidental existence of time components in dates.
               trunc(Clv.Start_Date) Item_Start_Date,
               trunc(Clv.End_Date)   Item_End_Date,
               trunc(Clv.Date_Terminated)  Item_Date_Terminated,
               cov.id       cov_line_id,
               Cov.Name     Cov_Name,
        --- truncating the dates to remove accidental existence of time components in dates.
               trunc(Cov.Start_Date) Cov_Start_Date,
               trunc(Cov.End_Date)   Cov_End_Date,
               trunc(Cov.Date_Terminated) Cov_Date_Terminated,
               Sv.Lse_Id    Service_Lse_Id
        FROM    OKC_K_HEADERS_V HD,
                OKC_K_LINES_V Sv,
                OKC_K_LINES_V Cov,
                oks_k_lines_b okscov, --11.5.10 rule rearchitecture changes
                OKC_K_LINES_V Clv,
                OKC_K_ITEMS  items,
                Okx_System_Items_V sys
        WHERE   Hd.Id = Sv.chr_id
        AND     Hd.Id = nvl(P_Id,Hd.Id)
        and     hd.authoring_org_id  = nvl(p_authoring_org_id,hd.authoring_org_id) -- multi org security check
        AND     Sv.lse_id in (1,14,19)
        AND     Sv.id = items.cle_id
        AND     Sv.dnz_chr_id = items.dnz_chr_id
        AND     sys.id1 =  to_number(items.object1_id1)
        AND     sys.id2 =  to_number(items.object1_id2)
        AND     items.dnz_chr_id = Hd.Id
        AND     to_number(items.object1_id1) = nvl(P_service_Item_id,to_number(items.object1_id1))
        AND     items.JTOT_OBJECT1_CODE   in ('OKX_SERVICE','OKX_WARRANTY')
        AND     items.object1_id2 = sys.id2 --'204'
        AND     Sv.Sts_code = nvl(p_Sts_Code,Sv.Sts_code)
        --- truncating the dates to remove accidental existence of time components in dates.
        AND     trunc(sv.Start_Date) >= nvl(trunc(P_Start_Date_From),trunc(sv.Start_Date))
        and     trunc(sv.Start_Date) <= nvl(trunc(P_Start_Date_to),trunc(sv.Start_Date))
        AND     trunc(sv.End_Date)   >= nvl(trunc(P_End_Date_From),trunc(sv.End_Date))
        and     trunc(sv.End_Date)   <= nvl(trunc(P_End_Date_To),trunc(sv.End_Date))
        AND     Cov.lse_id in (2,15,20)
        AND     Cov.cle_id = Sv.id
        AND     Cov.dnz_chr_Id = Sv.dnz_chr_Id
        and     okscov.cle_id = cov.id --11.5.10 rule rearchitecture changes
        AND     clv.id = P_Cle_Id --nvl(P_Cle_Id,clv.id)
        AND     clv.lse_id in (7,8,9,10,11,18,25,35)
        AND     clv.dnz_chr_id = Sv.dnz_chr_id
        AND     clv.dnz_chr_id = Hd.Id
        AND     clv.cle_id  = Sv.Id
        and     nvl(okscov.coverage_type,'#') = nvl(p_cov_type,nvl(okscov.coverage_type,'#'))--11.5.10 rule rearchitecture changes
        and     nvl(sv.bill_to_site_use_id,-99) = nvl(p_bill_to,nvl(sv.bill_to_site_use_id,-99))--11.5.10 rule rearchitecture changes
        and     nvl(sv.ship_to_site_use_id,-99) = nvl(p_ship_to,nvl(sv.ship_to_site_use_id,-99))--11.5.10 rule rearchitecture changes
        and     nvl(sv.line_renewal_type_code,'#') = nvl(p_renewal_code,nvl(sv.line_renewal_type_code,'#'))--11.5.10 rule rearchitecture changes
        order by sv.id;
*/

--
-- Modified for 12.0 Coverage Rearch project (JVARGHES)
--
/*Added for bug:6767455*/
CURSOR  get_Contract_noitem_cur(P_Id IN NUMBER,
                            P_Cle_Id IN NUMBER,
                            P_Sts_Code          IN VARCHAR2,
                            P_Start_Date_From  IN DATE,
                            P_Start_Date_TO    IN DATE,
                            P_END_Date_From    IN DATE,
                            P_END_Date_TO      IN DATE,
                            P_Cov_type          IN VARCHAR2,
                            P_Bill_To           IN VARCHAR2,
                            P_Ship_To           IN VARCHAR2,
                            P_renewal_code      IN VARCHAR2,
                            p_authoring_org_id  in number) IS
        SELECT /*+ leading(clv) use_nl(clv sv items sys hd cov okscov ) */
               Hd.Id    Id,
               Hd.Contract_Number   Contract_Number,
               Hd.Contract_Number_Modifier Contract_Number_Modifier,
               HdT.Short_Description Short_Description,  /*bug 7412576*/
               Hd.Start_Date    Hd_Start_Date,
               Hd.End_Date      Hd_End_Date,
               hd.scs_code      hd_scs_code,
	       hd.org_id        org_id, /*bug:7363217*/
               Sv.Id Service_ID,
               Sv.Line_Number Line_Number,
        --- truncating the dates to remove accidental existence of time components in dates.
               trunc(Sv.Start_Date) Start_Date,
               trunc(Sv.End_Date) End_Date,
               trunc(Sv.Date_Terminated) Date_Terminated,
               Sv.Sts_code Sts_code,
               SYS.concatenated_segments     Name,
        --- truncating the dates to remove accidental existence of time components in dates.
               trunc(Clv.Start_Date) Item_Start_Date,
               trunc(Clv.End_Date)   Item_End_Date,
               trunc(Clv.Date_Terminated)  Item_Date_Terminated,
               cov.id       cov_line_id,
               Cov.Name     Cov_Name,
        --- truncating the dates to remove accidental existence of time components in dates.
               /*trunc(Cov.Start_Date) Cov_Start_Date,
               trunc(Cov.End_Date)   Cov_End_Date,
               trunc(Cov.Date_Terminated) Cov_Date_Terminated,*/  /*bug 7412576*/
	       trunc(DECODE(KSL.Standard_Cov_YN,'Y',SV.Start_Date,Cov.Start_Date)) Cov_Start_Date,
               trunc(DECODE(KSL.Standard_Cov_YN,'Y',SV.END_Date,Cov.END_Date)) Cov_END_Date,
               trunc(DECODE(KSL.Standard_Cov_YN,'Y',SV.Date_Terminated,Cov.Date_Terminated)) Cov_Date_Terminated,
               Sv.Lse_Id    Service_Lse_Id
        FROM OKC_K_HEADERS_ALL_B HD,
                 OKC_K_HEADERS_TL HDT,       /*bug 7412576 OKC_K_HEADERS_V HD,*/
                OKC_K_LINES_B Sv,
                OKC_K_LINES_V Cov,
                 oks_k_lines_b  ksl,
                oks_k_lines_B okscov, --11.5.10 rule rearchitecture changes
                OKC_K_LINES_B Clv,
                OKC_K_ITEMS  items,
                MTL_SYSTEM_ITEMS_B_KFV sys
        WHERE   HDT.ID         = HD.ID
         AND     HDT.LANGUAGE   = USERENV('LANG')
         AND     Hd.Id = Sv.chr_id
        AND     Hd.Id = nvl(P_Id,Hd.Id)
        and     hd.authoring_org_id  = nvl(p_authoring_org_id,hd.authoring_org_id) -- multi org security check
        AND     Sv.lse_id in (1,14,19)
        AND     Sv.id = items.cle_id
        AND     Sv.dnz_chr_id = items.dnz_chr_id
        AND     sys.inventory_item_id =  to_number(items.object1_id1)
        AND     sys.organization_id =  to_number(items.object1_id2)
        AND     items.dnz_chr_id = Hd.Id
        AND     items.JTOT_OBJECT1_CODE  in ('OKX_SERVICE','OKX_WARRANTY')
        -- AND     items.object1_id2 = sys.id2 --'204'
        AND     Sv.Sts_code = nvl(p_Sts_Code,Sv.Sts_code)
        --- truncating the dates to remove accidental existence of time components in dates.
--      AND     trunc(sv.Start_Date) >= nvl(trunc(P_Start_Date_From),trunc(sv.Start_Date))
--      and     trunc(sv.Start_Date) <= nvl(trunc(P_Start_Date_to),trunc(sv.Start_Date))
--      AND     trunc(sv.End_Date)   >= nvl(trunc(P_End_Date_From),trunc(sv.End_Date))
--      and     trunc(sv.End_Date)   <= nvl(trunc(P_End_Date_To),trunc(sv.End_Date))
        AND     sv.Start_Date between P_Start_Date_From and P_Start_Date_to
        AND     sv.End_Date between P_End_Date_From and P_End_Date_To
       AND     ksl.cle_id = sv.id
        and     ksl.Coverage_Id = COV.Id    /*bug 7412576*/
        AND     Cov.lse_id in (2,15,20)
       /* AND     Cov.cle_id = Sv.id
        AND     Cov.dnz_chr_Id = Sv.dnz_chr_Id   */   /*bug 7412576*/
        and     okscov.cle_id = cov.id             -- 11.5.10 rule rearchitecture changes
        AND     clv.id = P_Cle_Id                   -- nvl(P_Cle_Id,clv.id)
        AND     clv.lse_id in (7,8,9,10,11,18,25,35)
        AND     clv.dnz_chr_id = Sv.dnz_chr_id
        AND     clv.dnz_chr_id = Hd.Id
        AND     clv.cle_id  = Sv.Id
        and     nvl(okscov.coverage_type,'#') = nvl(p_cov_type,nvl(okscov.coverage_type,'#'))--11.5.10 rule rearchitecture changes
 --     and     nvl(sv.bill_to_site_use_id,-99) = nvl(p_bill_to,nvl(sv.bill_to_site_use_id,-99))--11.5.10 rule rearchitecture changes
 --     and     nvl(sv.ship_to_site_use_id,-99) = nvl(p_ship_to,nvl(sv.ship_to_site_use_id,-99))--11.5.10 rule rearchitecture changes
        and     ((p_bill_to IS NULL) OR (sv.bill_to_site_use_id = p_bill_to)) --11.5.10 rule rearchitecture changes
        and     ((p_ship_to IS NULL) OR (sv.ship_to_site_use_id = p_ship_to))
        and     nvl(sv.line_renewal_type_code,'#') = nvl(p_renewal_code,nvl(sv.line_renewal_type_code,'#'))--11.5.10 rule rearchitecture changes
        order by sv.id;
        /*Added for bug:6767455*/
CURSOR  get_Contract_cur   (P_Id IN NUMBER,
                            P_Cle_Id IN NUMBER,
                            P_Service_Item_id IN NUMBER,
                            P_Sts_Code          IN VARCHAR2,
                            P_Start_Date_From  IN DATE,
                            P_Start_Date_TO    IN DATE,
                            P_END_Date_From    IN DATE,
                            P_END_Date_TO      IN DATE,
                            P_Cov_type          IN VARCHAR2,
                            P_Bill_To           IN VARCHAR2,
                            P_Ship_To           IN VARCHAR2,
                            P_renewal_code      IN VARCHAR2,
                            p_authoring_org_id  in number) IS
        SELECT /*+ leading(clv) use_nl(clv sv items sys hd cov okscov) index(items okc_k_items_n1)*/
                Hd.Id    Id,
               Hd.Contract_Number   Contract_Number,
               Hd.Contract_Number_Modifier Contract_Number_Modifier,
               HdT.Short_Description Short_Description, -- HdT.Short_Description -- Modified for 12.0 MOAC project (JVARGHES)
               Hd.Start_Date    Hd_Start_Date,
               Hd.End_Date      Hd_End_Date,
               hd.scs_code      hd_scs_code,
               hd.org_id        org_id,                 -- Modified for 12.0 MOAC project (JVARGHES)
               Sv.Id Service_ID,
               Sv.Line_Number Line_Number,
        --- truncating the dates to remove accidental existence of time components in dates.
               trunc(Sv.Start_Date) Start_Date,
               trunc(Sv.End_Date) End_Date,
               trunc(Sv.Date_Terminated) Date_Terminated,
               Sv.Sts_code Sts_code,
               SYS.concatenated_segments    Name,
        --- truncating the dates to remove accidental existence of time components in dates.
               trunc(Clv.Start_Date) Item_Start_Date,
               trunc(Clv.End_Date)   Item_End_Date,
               trunc(Clv.Date_Terminated)  Item_Date_Terminated,
               cov.id       cov_line_id,
               Cov.Name     Cov_Name,
        --- truncating the dates to remove accidental existence of time components in dates.
               trunc(DECODE(KSL.Standard_Cov_YN,'Y',SV.Start_Date,Cov.Start_Date)) Cov_Start_Date,
               trunc(DECODE(KSL.Standard_Cov_YN,'Y',SV.END_Date,Cov.END_Date)) Cov_END_Date,
               trunc(DECODE(KSL.Standard_Cov_YN,'Y',SV.Date_Terminated,Cov.Date_Terminated)) Cov_Date_Terminated,
               Sv.Lse_Id    Service_Lse_Id
        FROM    OKC_K_HEADERS_ALL_B HD,   -- Modified for 12.0 MOAC project (JVARGHES)
                OKC_K_HEADERS_TL HDT,     -- Okc_K_Headers_V HD   -- Modified for 12.0 MOAC project (JVARGHES)
                OKC_K_LINES_B Sv,
                OKS_K_LINES_B KSL,
                OKC_K_LINES_V Cov,
                oks_k_lines_B okscov, --11.5.10 rule rearchitecture changes
                OKC_K_LINES_B Clv,
                OKC_K_ITEMS  items,
                MTL_SYSTEM_ITEMS_B_KFV sys
        WHERE   Hd.Id = Sv.chr_id
        AND     HDT.ID         = HD.ID                    -- Modified for 12.0 MOAC project (JVARGHES)
        AND     HDT.LANGUAGE   = USERENV('LANG')          -- Modified for 12.0 MOAC project (JVARGHES)
        AND     Hd.Id = nvl(P_Id,Hd.Id)
        and     hd.authoring_org_id  = nvl(p_authoring_org_id,hd.authoring_org_id) -- multi org security check
        AND     Sv.lse_id in (1,14,19)
        AND     Sv.id = items.cle_id
        AND     Sv.dnz_chr_id = items.dnz_chr_id
        /*AND     sys.id1 =  to_number(items.object1_id1)
        AND     sys.id2 =  to_number(items.object1_id2)*/
        AND     sys.inventory_item_id =  to_number(items.object1_id1)
        AND     sys.organization_id =  to_number(items.object1_id2)
        AND     items.dnz_chr_id = Hd.Id
        --AND     to_number(items.object1_id1) = nvl(P_service_Item_id,to_number(items.object1_id1))
        AND     items.object1_id1 = to_number(P_service_Item_id)
        AND     items.JTOT_OBJECT1_CODE   in ('OKX_SERVICE','OKX_WARRANTY')
        --AND     items.object1_id2 = sys.id2 --'204'
        AND     Sv.Sts_code = nvl(p_Sts_Code,Sv.Sts_code)
        --- truncating the dates to remove accidental existence of time components in dates.
        /*AND     trunc(sv.Start_Date) >= nvl(trunc(P_Start_Date_From),trunc(sv.Start_Date))
        and     trunc(sv.Start_Date) <= nvl(trunc(P_Start_Date_to),trunc(sv.Start_Date))
        AND     trunc(sv.End_Date)   >= nvl(trunc(P_End_Date_From),trunc(sv.End_Date))
        and     trunc(sv.End_Date)   <= nvl(trunc(P_End_Date_To),trunc(sv.End_Date))*/
        AND     sv.Start_Date between P_Start_Date_From and P_Start_Date_to
        AND     sv.End_Date between P_End_Date_From and P_End_Date_To
        AND     ksl.cle_id = sv.id
        and     ksl.Coverage_Id = COV.Id
        AND     Cov.lse_id in (2,15,20)
        and     okscov.cle_id = cov.id --11.5.10 rule rearchitecture changes
        AND     clv.id = P_Cle_Id --nvl(P_Cle_Id,clv.id)
        AND     clv.lse_id in (7,8,9,10,11,18,25,35)
        AND     clv.dnz_chr_id = Sv.dnz_chr_id
        AND     clv.dnz_chr_id = Hd.Id
        AND     clv.cle_id  = Sv.Id
        and     nvl(okscov.coverage_type,'#') = nvl(p_cov_type,nvl(okscov.coverage_type,'#'))--11.5.10 rule rearchitecture changes
        /*and     nvl(sv.bill_to_site_use_id,-99) = nvl(p_bill_to,nvl(sv.bill_to_site_use_id,-99))--11.5.10 rule rearchitecture changes
        and     nvl(sv.ship_to_site_use_id,-99) = nvl(p_ship_to,nvl(sv.ship_to_site_use_id,-99))--11.5.10 rule rearchitecture changes*/
        and     ((p_bill_to IS NULL) OR (sv.bill_to_site_use_id = p_bill_to)) --11.5.10 rule rearchitecture changes
        and     ((p_ship_to IS NULL) OR (sv.ship_to_site_use_id = p_ship_to))
        and     nvl(sv.line_renewal_type_code,'#') = nvl(p_renewal_code,nvl(sv.line_renewal_type_code,'#'))--11.5.10 rule rearchitecture changes
        order by sv.id;
CURSOR  get_Contract_noclvl_noitem_cur   (P_Id IN NUMBER,
                            P_Cle_Id IN NUMBER,
                            P_Sts_Code          IN VARCHAR2,
                            P_Start_Date_From  IN DATE,
                            P_Start_Date_TO    IN DATE,
                            P_END_Date_From    IN DATE,
                            P_END_Date_TO      IN DATE,
                            P_Cov_type          IN VARCHAR2,
                            P_Bill_To           IN VARCHAR2,
                            P_Ship_To           IN VARCHAR2,
                            P_renewal_code      IN VARCHAR2,
                            p_authoring_org_id  in number) IS
        SELECT /*+ leading(sv) use_nl(sv items sys hd cov okscov) */
               Hd.Id    Id,
               Hd.Contract_Number   Contract_Number,
               Hd.Contract_Number_Modifier Contract_Number_Modifier,
               HdT.Short_Description Short_Description,         /*bug 7412576*/
               Hd.Start_Date    Hd_Start_Date,
               Hd.End_Date      Hd_End_Date,
               hd.scs_code      hd_scs_code,
               hd.org_id        org_id, /*bug:7363217*/
               Sv.Id Service_ID,
               Sv.Line_Number Line_Number,
        --- truncating the dates to remove accidental existence of time components in dates.
               trunc(Sv.Start_Date) Start_Date,
               trunc(Sv.End_Date) End_Date,
               trunc(Sv.Date_Terminated) Date_Terminated,
               Sv.Sts_code Sts_code,
               SYS.concatenated_segments     Name,
               cov.id       cov_line_id,
               Cov.Name     Cov_Name,
        --- truncating the dates to remove accidental existence of time components in dates.
               /*trunc(Cov.Start_Date) Cov_Start_Date,
               trunc(Cov.End_Date)   Cov_End_Date,
               trunc(Cov.Date_Terminated) Cov_Date_Terminated,*/     /*bug 7412576*/
	       trunc(DECODE(KSL.Standard_Cov_YN,'Y',SV.Start_Date,Cov.Start_Date)) Cov_Start_Date,
               trunc(DECODE(KSL.Standard_Cov_YN,'Y',SV.END_Date,Cov.END_Date)) Cov_END_Date,
               trunc(DECODE(KSL.Standard_Cov_YN,'Y',SV.Date_Terminated,Cov.Date_Terminated)) Cov_Date_Terminated,
               Sv.Lse_Id    Service_Lse_Id
        FROM    OKC_K_HEADERS_ALL_B HD,
                OKC_K_HEADERS_TL HDT, /*OKC_K_HEADERS_V HD,*/  /*bug 7412576*/
                OKC_K_LINES_B Sv,
                OKS_K_LINES_B KSL,
                OKC_K_LINES_V Cov,
                oks_k_lines_b okscov,--11.5.10 rule rearchitecture changes
                OKC_K_ITEMS  items,
                MTL_SYSTEM_ITEMS_B_KFV sys
        WHERE   Hd.Id = Sv.chr_id
        AND     HDT.ID = HD.ID
        AND     HDT.LANGUAGE   = USERENV('LANG')    /*bug 7412576*/
        AND     Hd.id = SV.DNZ_CHR_ID
        AND     Hd.Id = nvl(P_Id,Hd.Id)
        and     hd.authoring_org_id  = nvl(p_authoring_org_id,hd.authoring_org_id) -- multi org security check
        AND     Sv.lse_id in (1,14,19)
        AND     Sv.id = items.cle_id
        AND     Sv.dnz_chr_id = items.dnz_chr_id
        AND     sys.inventory_item_id =  to_number(items.object1_id1)
        AND     sys.organization_id =  to_number(items.object1_id2)
        AND     items.dnz_chr_id = Hd.Id
        AND     items.JTOT_OBJECT1_CODE   in ('OKX_SERVICE','OKX_WARRANTY')
     --   AND     items.object1_id2 = sys.id2 --'204'
        AND     Sv.Sts_code = nvl(p_Sts_Code,Sv.Sts_code)
        --- truncating the dates to remove accidental existence of time components in dates.
--      AND     trunc(sv.Start_Date) >= nvl(trunc(P_Start_Date_From),trunc(sv.Start_Date))
--      and     trunc(sv.Start_Date) <= nvl(trunc(P_Start_Date_to),trunc(sv.Start_Date))
--      AND     trunc(sv.End_Date)   >= nvl(trunc(P_End_Date_From),trunc(sv.End_Date))
--      and     trunc(sv.End_Date)   <= nvl(trunc(P_End_Date_To),trunc(sv.End_Date))
        AND     sv.Start_Date between P_Start_Date_From and P_Start_Date_to
        AND     sv.End_Date between P_End_Date_From and P_End_Date_To
        AND     ksl.cle_id = sv.id
        and     ksl.Coverage_Id = COV.Id
        AND     Cov.lse_id in (2,15,20)
      /*  AND     Cov.cle_id = Sv.id
        AND     Cov.dnz_chr_Id = Sv.dnz_chr_Id*/          /*bug 7412576*/
        and     okscov.cle_id = cov.id --11.5.10 rule rearchitecture changes
        and     nvl(okscov.coverage_type,'#') = nvl(p_cov_type,nvl(okscov.coverage_type,'#'))--11.5.10 rule rearchitecture changes
--      and     nvl(sv.bill_to_site_use_id,-99) = nvl(p_bill_to,nvl(sv.bill_to_site_use_id,-99))--11.5.10 rule rearchitecture changes
--      and     nvl(sv.ship_to_site_use_id,-99) = nvl(p_ship_to,nvl(sv.ship_to_site_use_id,-99))--11.5.10 rule rearchitecture changes
        and     ((p_bill_to IS NULL) OR (sv.bill_to_site_use_id = p_bill_to)) --11.5.10 rule rearchitecture changes
        and     ((p_ship_to IS NULL) OR (sv.ship_to_site_use_id = p_ship_to))
        and     nvl(sv.line_renewal_type_code,'#') = nvl(p_renewal_code,nvl(sv.line_renewal_type_code,'#'))--11.5.10 rule rearchitecture changes
        order by sv.id;

CURSOR  get_Cont_noclvl_chr_noitem_cur   (P_Id IN NUMBER,
                            P_Cle_Id IN NUMBER,                     -- not being used anywhere
                            P_Sts_Code          IN VARCHAR2,
                            P_Start_Date_From  IN DATE,
                            P_Start_Date_TO    IN DATE,
                            P_END_Date_From    IN DATE,
                            P_END_Date_TO      IN DATE,
                            P_Cov_type          IN VARCHAR2,
                            P_Bill_To           IN VARCHAR2,
                            P_Ship_To           IN VARCHAR2,
                            P_renewal_code      IN VARCHAR2,
                            p_authoring_org_id  in number) IS
        SELECT /*+ leading(hd) use_nl(hd sv items sys cov okscov) */
               Hd.Id    Id,
               Hd.Contract_Number   Contract_Number,
               Hd.Contract_Number_Modifier Contract_Number_Modifier,
               HdT.Short_Description Short_Description,    /*bug 7412576*/
               Hd.Start_Date    Hd_Start_Date,
               Hd.End_Date      Hd_End_Date,
               hd.scs_code      hd_scs_code,
               hd.org_id        org_id, /*bug:7363217*/
               Sv.Id Service_ID,
               Sv.Line_Number Line_Number,
        --- truncating the dates to remove accidental existence of time components in dates.
               trunc(Sv.Start_Date) Start_Date,
               trunc(Sv.End_Date) End_Date,
               trunc(Sv.Date_Terminated) Date_Terminated,
               Sv.Sts_code Sts_code,
               SYS.concatenated_segments     Name,
               cov.id       cov_line_id,
               Cov.Name     Cov_Name,
        --- truncating the dates to remove accidental existence of time components in dates.

	      /* trunc(Cov.Start_Date) Cov_Start_Date,
               trunc(Cov.End_Date)   Cov_End_Date,
               trunc(Cov.Date_Terminated) Cov_Date_Terminated,*/        /*bug 7412576*/
               trunc(DECODE(KSL.Standard_Cov_YN,'Y',SV.Start_Date,Cov.Start_Date)) Cov_Start_Date,
               trunc(DECODE(KSL.Standard_Cov_YN,'Y',SV.END_Date,Cov.END_Date)) Cov_END_Date,
               trunc(DECODE(KSL.Standard_Cov_YN,'Y',SV.Date_Terminated,Cov.Date_Terminated)) Cov_Date_Terminated,
               Sv.Lse_Id    Service_Lse_Id
        FROM     OKC_K_HEADERS_ALL_B HD,
                OKC_K_HEADERS_TL HDT,/*OKC_K_HEADERS_V HD,*/ /*bug 7412576*/
                OKC_K_LINES_B Sv,
                OKS_K_LINES_B KSL,
                OKC_K_LINES_V Cov,
                oks_k_lines_b okscov, --11.5.10 rule rearchitecture changes
                OKC_K_ITEMS  items,
                MTL_SYSTEM_ITEMS_B_KFV  sys
        WHERE   Hd.Id = Sv.chr_id
        AND   HDT.ID = HD.ID
        AND   HDT.LANGUAGE   = USERENV('LANG')
        AND     Hd.id = SV.DNZ_CHR_ID
        AND     Hd.Id = P_ID                    -- nvl(P_Id,Hd.Id)
        and     hd.authoring_org_id  = nvl(p_authoring_org_id,hd.authoring_org_id) -- multi org security check
        AND     Sv.lse_id in (1,14,19)
        AND     Sv.id = items.cle_id
        AND     Sv.dnz_chr_id = items.dnz_chr_id
        AND     sys.inventory_item_id =  to_number(items.object1_id1)
        AND     sys.organization_id =  to_number(items.object1_id2)
        AND     items.dnz_chr_id = Hd.Id
        AND     items.JTOT_OBJECT1_CODE   in ('OKX_SERVICE','OKX_WARRANTY')
       -- AND     items.object1_id2 = sys.id2 --'204'
        AND     Sv.Sts_code = nvl(p_Sts_Code,Sv.Sts_code)
        --- truncating the dates to remove accidental existence of time components in dates.
--      AND     trunc(sv.Start_Date) >= nvl(trunc(P_Start_Date_From),trunc(sv.Start_Date))
--      and     trunc(sv.Start_Date) <= nvl(trunc(P_Start_Date_to),trunc(sv.Start_Date))
--      AND     trunc(sv.End_Date)   >= nvl(trunc(P_End_Date_From),trunc(sv.End_Date))
--      and     trunc(sv.End_Date)   <= nvl(trunc(P_End_Date_To),trunc(sv.End_Date))
        AND     sv.Start_Date between P_Start_Date_From and P_Start_Date_to
        AND     sv.End_Date between P_End_Date_From and P_End_Date_To
        AND     ksl.cle_id = sv.id
        and     ksl.Coverage_Id = COV.Id
        AND     Cov.lse_id in (2,15,20)
       /* AND     Cov.cle_id = Sv.id
        AND     Cov.dnz_chr_Id = Sv.dnz_chr_Id*/   /*bug 7412576*/
        and     okscov.cle_id = cov.id --11.5.10 rule rearchitecture changes
        and     nvl(okscov.coverage_type,'#') = nvl(p_cov_type,nvl(okscov.coverage_type,'#'))--11.5.10 rule rearchitecture changes
--      and     nvl(sv.bill_to_site_use_id,-99) = nvl(p_bill_to,nvl(sv.bill_to_site_use_id,-99))--11.5.10 rule rearchitecture changes
--      and     nvl(sv.ship_to_site_use_id,-99) = nvl(p_ship_to,nvl(sv.ship_to_site_use_id,-99))--11.5.10 rule rearchitecture changes
        and     ((p_bill_to IS NULL) OR (sv.bill_to_site_use_id = p_bill_to)) --11.5.10 rule rearchitecture changes
        and     ((p_ship_to IS NULL) OR (sv.ship_to_site_use_id = p_ship_to))
        and     nvl(sv.line_renewal_type_code,'#') = nvl(p_renewal_code,nvl(sv.line_renewal_type_code,'#'))--11.5.10 rule rearchitecture changes
        order by sv.id;

        /*modified for bug:8700389*/
         CURSOR  get_Cont_noclvl_kid_noitem_cur(P_Id IN NUMBER,
 	                             P_Start_Date_From  IN DATE,
 	                             P_Start_Date_TO    IN DATE,
 	                             P_END_Date_From    IN DATE,
 	                             P_END_Date_TO      IN DATE) IS
 	         SELECT /*+ leading(hd) use_nl(hd sv items sys cov okscov) index(Cov okc_k_lines_b_n2)*/
 	                Hd.Id    Id,
 	                Hd.Contract_Number   Contract_Number,
 	                Hd.Contract_Number_Modifier Contract_Number_Modifier,
 	                HDT.SHORT_DESCRIPTION SHORT_DESCRIPTION,
 	                Hd.Start_Date    Hd_Start_Date,
 	                Hd.End_Date      Hd_End_Date,
 	                hd.scs_code      hd_scs_code,
                        hd.org_id        org_id,
 	                Sv.Id Service_ID,
 	                Sv.Line_Number Line_Number,
 	                trunc(Sv.Start_Date) Start_Date,
 	                trunc(Sv.End_Date) End_Date,
 	                trunc(Sv.Date_Terminated) Date_Terminated,
 	                Sv.Sts_code Sts_code,
 	                SYS.concatenated_segments     Name,
 	                cov.id       cov_line_id,
 	                COVTL.NAME COV_NAME,
 	               /* trunc(Cov.Start_Date) Cov_Start_Date,
 	                trunc(Cov.End_Date)   Cov_End_Date,
 	                trunc(Cov.Date_Terminated) Cov_Date_Terminated,*/
                        trunc(DECODE(KSL.Standard_Cov_YN,'Y',SV.Start_Date,Cov.Start_Date)) Cov_Start_Date,
                        trunc(DECODE(KSL.Standard_Cov_YN,'Y',SV.END_Date,Cov.END_Date)) Cov_END_Date,
                        trunc(DECODE(KSL.Standard_Cov_YN,'Y',SV.Date_Terminated,Cov.Date_Terminated)) Cov_Date_Terminated,
 	                Sv.Lse_Id    Service_Lse_Id
 	         FROM    OKC_K_HEADERS_ALL_B HD,        /*modified for bug:8700389*/
 	                 OKC_K_HEADERS_TL HDT,
 	                 OKC_K_LINES_B Sv,
                         OKS_K_LINES_B KSL,
 	                 OKC_K_LINES_B Cov,
 	                 OKC_K_LINES_TL COVTL,
 	                 oks_k_lines_b okscov, --11.5.10 rule rearchitecture changes
 	                 OKC_K_ITEMS  items,
 	                 MTL_SYSTEM_ITEMS_B_KFV  sys
 	         WHERE   Hd.Id = Sv.chr_id
 	         AND     Hd.id = SV.DNZ_CHR_ID
 	         AND     Hd.Id = P_ID                    -- nvl(P_Id,Hd.Id)
 	         AND     HD.ID=HDT.ID
 	         AND     HDT.LANGUAGE = USERENV('LANG')
 	         AND     Sv.lse_id in (1,14,19)
 	         AND     Sv.id = items.cle_id
 	         AND     Sv.dnz_chr_id = items.dnz_chr_id
 	         AND     sys.inventory_item_id =  to_number(items.object1_id1)
 	         AND     sys.organization_id =  to_number(items.object1_id2)
 	         AND     items.dnz_chr_id = Hd.Id
 	         AND     items.JTOT_OBJECT1_CODE   in ('OKX_SERVICE','OKX_WARRANTY')
 	         AND     sv.Start_Date between P_Start_Date_From and P_Start_Date_to
 	         AND     sv.End_Date between P_End_Date_From and P_End_Date_To
                 AND     ksl.cle_id = sv.id
                 AND     ksl.Coverage_Id = COV.Id
                 AND     Cov.lse_id in (2,15,20)
 	         /*AND     Cov.cle_id = Sv.id
 	         AND     Cov.dnz_chr_Id = Sv.dnz_chr_Id*/
 	         AND     COVTL.ID=COV.ID
 	         AND     COVTL.LANGUAGE = USERENV('LANG')
 	         and     okscov.cle_id = cov.id --11.5.10 rule rearchitecture changes
 	         order by sv.id;

CURSOR  get_Contract_noclvl_cur   (P_Id IN NUMBER,
                            P_Cle_Id IN NUMBER,
                            P_Service_Item_id IN NUMBER,
                            P_Sts_Code          IN VARCHAR2,
                            P_Start_Date_From  IN DATE,
                            P_Start_Date_TO    IN DATE,
                            P_END_Date_From    IN DATE,
                            P_END_Date_TO      IN DATE,
                            P_Cov_type          IN VARCHAR2,
                            P_Bill_To           IN VARCHAR2,
                            P_Ship_To           IN VARCHAR2,
                            P_renewal_code      IN VARCHAR2,
                            p_authoring_org_id  in number) IS
        SELECT /*+ leading(sv) use_nl(sv items sys hd cov okscov) index(items okc_k_items_n1)*/
                Hd.Id    Id,
               Hd.Contract_Number   Contract_Number,
               Hd.Contract_Number_Modifier Contract_Number_Modifier,
               HdT.Short_Description Short_Description, -- HdT.Short_Description -- Modified for 12.0 MOAC project (JVARGHES)
               Hd.Start_Date    Hd_Start_Date,
               Hd.End_Date      Hd_End_Date,
               hd.scs_code      hd_scs_code,
               hd.org_id        org_id,                 -- Modified for 12.0 MOAC project (JVARGHES)
               Sv.Id Service_ID,
               Sv.Line_Number Line_Number,
        --- truncating the dates to remove accidental existence of time components in dates.
               trunc(Sv.Start_Date) Start_Date,
               trunc(Sv.End_Date) End_Date,
               trunc(Sv.Date_Terminated) Date_Terminated,
               Sv.Sts_code Sts_code,
               SYS.concatenated_segments     Name,
               cov.id       cov_line_id,
               Cov.Name     Cov_Name,
        --- truncating the dates to remove accidental existence of time components in dates.
               trunc(DECODE(KSL.Standard_Cov_YN,'Y',SV.Start_Date,Cov.Start_Date)) Cov_Start_Date,
               trunc(DECODE(KSL.Standard_Cov_YN,'Y',SV.END_Date,Cov.END_Date)) Cov_END_Date,
               trunc(DECODE(KSL.Standard_Cov_YN,'Y',SV.Date_Terminated,Cov.Date_Terminated)) Cov_Date_Terminated,
               Sv.Lse_Id    Service_Lse_Id
        FROM    OKC_K_HEADERS_ALL_B HD,   -- Modified for 12.0 MOAC project (JVARGHES)
               OKC_K_HEADERS_TL HDT,     -- Okc_K_Headers_V HD   -- Modified for 12.0 MOAC project (JVARGHES)
                OKC_K_LINES_B Sv,
                OKC_K_LINES_V Cov,
                oks_k_lines_b  ksl,
                oks_k_lines_b okscov, --11.5.10 rule rearchitecture changes
                OKC_K_ITEMS  items,
                MTL_SYSTEM_ITEMS_B_KFV sys
        WHERE   Hd.Id = Sv.chr_id
        AND     Hd.id = SV.DNZ_CHR_ID
        AND     HDT.ID         = HD.ID                    -- Modified for 12.0 MOAC project (JVARGHES)
        AND     HDT.LANGUAGE   = USERENV('LANG')          -- Modified for 12.0 MOAC project (JVARGHES)
        AND     Hd.Id = nvl(P_Id,Hd.Id)
        and     hd.authoring_org_id  = nvl(p_authoring_org_id,hd.authoring_org_id) -- multi org security check
        AND     Sv.lse_id in (1,14,19)
        AND     Sv.id = items.cle_id
        AND     Sv.dnz_chr_id = items.dnz_chr_id
       /*AND     sys.id1 =  to_number(items.object1_id1)
        AND     sys.id2 =  to_number(items.object1_id2)*/    /*Bug:6767455*/
        AND     sys.inventory_item_id =  to_number(items.object1_id1)
        AND     sys.organization_id =  to_number(items.object1_id2)
        AND     items.dnz_chr_id = Hd.Id
        AND     items.object1_id1 = to_number(P_service_Item_id)
        AND     items.JTOT_OBJECT1_CODE   in ('OKX_SERVICE','OKX_WARRANTY')
       -- AND     items.object1_id2 = sys.id2 --'204'
        AND     Sv.Sts_code = nvl(p_Sts_Code,Sv.Sts_code)
        --- truncating the dates to remove accidental existence of time components in dates.
 --     AND     trunc(sv.Start_Date) >= nvl(trunc(P_Start_Date_From),trunc(sv.Start_Date))
 --     and     trunc(sv.Start_Date) <= nvl(trunc(P_Start_Date_to),trunc(sv.Start_Date))
 --     AND     trunc(sv.End_Date)   >= nvl(trunc(P_End_Date_From),trunc(sv.End_Date))
 --     and     trunc(sv.End_Date)   <= nvl(trunc(P_End_Date_To),trunc(sv.End_Date))
        AND     sv.Start_Date between P_Start_Date_From and P_Start_Date_to
        AND     sv.End_Date between P_End_Date_From and P_End_Date_To
       AND     ksl.cle_id = sv.id
        and     ksl.Coverage_Id = COV.Id
        AND     Cov.lse_id in (2,15,20)
        /*AND     Cov.cle_id = Sv.id
        AND     Cov.dnz_chr_Id = Sv.dnz_chr_Id*/         /*bug 7412576*/
        and     okscov.cle_id = cov.id --11.5.10 rule rearchitecture changes
        and     nvl(okscov.coverage_type,'#') = nvl(p_cov_type,nvl(okscov.coverage_type,'#'))--11.5.10 rule rearchitecture changes
 --     and     nvl(sv.bill_to_site_use_id,-99) = nvl(p_bill_to,nvl(sv.bill_to_site_use_id,-99))--11.5.10 rule rearchitecture changes
 --     and     nvl(sv.ship_to_site_use_id,-99) = nvl(p_ship_to,nvl(sv.ship_to_site_use_id,-99))--11.5.10 rule rearchitecture changes
        and     ((p_bill_to IS NULL) OR (sv.bill_to_site_use_id = p_bill_to)) --11.5.10 rule rearchitecture changes
        and     ((p_ship_to IS NULL) OR (sv.ship_to_site_use_id = p_ship_to))
        and     nvl(sv.line_renewal_type_code,'#') = nvl(p_renewal_code,nvl(sv.line_renewal_type_code,'#'))--11.5.10 rule rearchitecture changes
        order by sv.id;

CURSOR  get_Cont_noclvl_chr_cur   (P_Id IN NUMBER,
                            P_Cle_Id IN NUMBER,                  -- not being used anywhere
                            P_Service_Item_id IN NUMBER,
                            P_Sts_Code          IN VARCHAR2,
                            P_Start_Date_From  IN DATE,
                            P_Start_Date_TO    IN DATE,
                            P_END_Date_From    IN DATE,
                            P_END_Date_TO      IN DATE,
                            P_Cov_type          IN VARCHAR2,
                            P_Bill_To           IN VARCHAR2,
                            P_Ship_To           IN VARCHAR2,
                            P_renewal_code      IN VARCHAR2,
                            p_authoring_org_id  in number) IS
        SELECT /*+ leading(hd) use_nl(hd sv items sys cov okscov) index(items okc_k_items_n1)*/
               Hd.Id    Id,
               Hd.Contract_Number   Contract_Number,
               Hd.Contract_Number_Modifier Contract_Number_Modifier,
               HdT.Short_Description Short_Description,        /*bug 7412576*/
               Hd.Start_Date    Hd_Start_Date,
               Hd.End_Date      Hd_End_Date,
               hd.scs_code      hd_scs_code,
              hd.org_id        org_id, /*bug:7363217*/
               Sv.Id Service_ID,
               Sv.Line_Number Line_Number,
        --- truncating the dates to remove accidental existence of time components in dates.
               trunc(Sv.Start_Date) Start_Date,
               trunc(Sv.End_Date) End_Date,
               trunc(Sv.Date_Terminated) Date_Terminated,
               Sv.Sts_code Sts_code,
               SYS.concatenated_segments     Name,
               cov.id       cov_line_id,
               Cov.Name     Cov_Name,
        --- truncating the dates to remove accidental existence of time components in dates.
               /*trunc(Cov.Start_Date) Cov_Start_Date,
               trunc(Cov.End_Date)   Cov_End_Date,
               trunc(Cov.Date_Terminated) Cov_Date_Terminated,*/  /*bug 7412576*/
               trunc(DECODE(KSL.Standard_Cov_YN,'Y',SV.Start_Date,Cov.Start_Date)) Cov_Start_Date,
               trunc(DECODE(KSL.Standard_Cov_YN,'Y',SV.END_Date,Cov.END_Date)) Cov_END_Date,
               trunc(DECODE(KSL.Standard_Cov_YN,'Y',SV.Date_Terminated,Cov.Date_Terminated)) Cov_Date_Terminated,
               Sv.Lse_Id    Service_Lse_Id
        FROM    OKC_K_HEADERS_ALL_B HD,
                OKC_K_HEADERS_TL HDT,     /*OKC_K_HEADERS_V HD,*/ /*bug 7412576*/
                OKC_K_LINES_B Sv,
                OKC_K_LINES_V Cov,
                 oks_k_lines_b  ksl,
                oks_k_lines_b okscov, --11.5.10 rule rearchitecture changes
                OKC_K_ITEMS  items,
                MTL_SYSTEM_ITEMS_B_KFV sys
        WHERE   Hd.Id = Sv.chr_id
        AND     HDT.ID = HD.ID
       AND     HDT.LANGUAGE   = USERENV('LANG')        /*bug 7412576*/
        AND     Hd.id = SV.DNZ_CHR_ID
        AND     Hd.Id = p_id                -- nvl(P_Id,Hd.Id)
        and     hd.authoring_org_id  = nvl(p_authoring_org_id,hd.authoring_org_id) -- multi org security check
        AND     Sv.lse_id in (1,14,19)
        AND     Sv.id = items.cle_id
        AND     Sv.dnz_chr_id = items.dnz_chr_id
        AND     sys.inventory_item_id =  to_number(items.object1_id1)
        AND     sys.organization_id =  to_number(items.object1_id2)
        AND     items.dnz_chr_id = Hd.Id
        --AND     to_number(items.object1_id1) = nvl(P_service_Item_id,to_number(items.object1_id1))
         AND     items.object1_id1 = to_number(P_service_Item_id)
        AND     items.JTOT_OBJECT1_CODE   in ('OKX_SERVICE','OKX_WARRANTY')
       --AND     items.object1_id2 = sys.id2 --'204'
        AND     Sv.Sts_code = nvl(p_Sts_Code,Sv.Sts_code)
        --- truncating the dates to remove accidental existence of time components in dates.
        /*AND     trunc(sv.Start_Date) >= nvl(trunc(P_Start_Date_From),trunc(sv.Start_Date))
        and     trunc(sv.Start_Date) <= nvl(trunc(P_Start_Date_to),trunc(sv.Start_Date))
        AND     trunc(sv.End_Date)   >= nvl(trunc(P_End_Date_From),trunc(sv.End_Date))
        and     trunc(sv.End_Date)   <= nvl(trunc(P_End_Date_To),trunc(sv.End_Date))*/
        AND     sv.Start_Date between P_Start_Date_From and P_Start_Date_to
        AND     sv.End_Date between P_End_Date_From and P_End_Date_To
        AND     ksl.cle_id = sv.id
        and     ksl.Coverage_Id = COV.Id              /*commented for bug:6767455*/ /*bug 7412576*/
        AND     Cov.lse_id in (2,15,20)
       /* AND     Cov.cle_id = Sv.id
        AND     Cov.dnz_chr_Id = Sv.dnz_chr_Id*/
        and     okscov.cle_id = cov.id --11.5.10 rule rearchitecture changes
        and     nvl(okscov.coverage_type,'#') = nvl(p_cov_type,nvl(okscov.coverage_type,'#'))--11.5.10 rule rearchitecture changes
        /*and     nvl(sv.bill_to_site_use_id,-99) = nvl(p_bill_to,nvl(sv.bill_to_site_use_id,-99))--11.5.10 rule rearchitecture changes
        and     nvl(sv.ship_to_site_use_id,-99) = nvl(p_ship_to,nvl(sv.ship_to_site_use_id,-99))--11.5.10 rule rearchitecture changes*/
        and     ((p_bill_to IS NULL) OR (sv.bill_to_site_use_id = p_bill_to)) --11.5.10 rule rearchitecture changes
        and     ((p_ship_to IS NULL) OR (sv.ship_to_site_use_id = p_ship_to))
        and     nvl(sv.line_renewal_type_code,'#') = nvl(p_renewal_code,nvl(sv.line_renewal_type_code,'#'))--11.5.10 rule rearchitecture changes
        order by sv.id;
Type l_num_tbl is table of NUMBER index  by BINARY_INTEGER ;                      /* Added for bug:6767455*/
  Type l_date_tbl is table of DATE index  by BINARY_INTEGER ;
  Type l_chr_tbl is table of Varchar2(600) index  by BINARY_INTEGER ;

  Id                        l_num_tbl;
  contract_number           l_chr_tbl;
  Contract_Number_Modifier  l_chr_tbl;
  Short_Description         l_chr_tbl;
  Hd_Start_Date             l_date_tbl;
  Hd_End_Date               l_date_tbl;
  hd_scs_code               l_chr_tbl;
  org_id                    l_num_tbl;
  Service_ID                l_num_tbl;
  Line_Number               l_num_tbl;
  Start_Date                l_date_tbl;
  End_Date                  l_date_tbl;
  Date_Terminated           l_date_tbl;
  Sts_code                  l_chr_tbl;
  Name                      l_chr_tbl;
  Item_Start_Date           l_date_tbl;
  Item_End_Date             l_date_tbl;
  Item_Date_Terminated      l_date_tbl;
  cov_line_id               l_num_tbl;
  Cov_Name                  l_chr_tbl;
  Cov_Start_Date            l_date_tbl;
  Cov_End_Date              l_date_tbl;
  Cov_Date_Terminated       l_date_tbl;
  Service_Lse_Id            l_num_tbl;

    Lv_Contracts                GT_Contract_Ref;
    Lv_Contract_line_Rec        srchline_inpcontlinerec_type;
    Lv_Request_Date             Date;
    Lv_Contracts_02             output_tbl_contractline ;
    Lv_Contracts_02_Out         output_tbl_contractline ;

    Lv_Entitlment_Check         CONSTANT    VARCHAR2(1) := P_Entitlement_Check_YN;
    Lv_authoring_org_id         CONSTANT    number := P_authoring_org_id; -- multi org security check
    Lv_covlevel_lines_passed    CONSTANT    VARCHAR2(1) := P_Covlevel_lines_passed;

    Lx_Result                   Gx_Boolean;
    Lx_Return_Status            Gx_Ret_Sts;

    Lx_counter                  Binary_Integer;
    Lv_Entile_Flag              VARCHAR2(1);
    L_Profile_Flag              VARCHAR2(1);
    L_return_Status             VARCHAR2(1);
    Lx_service_id               number;
    L_valid_line                varchar2(1);
    L_line_id_tbl               Line_id_tbl;
    l_last_date                 DATE;
    l_first_date                DATE;

   -- Modified for 12.0 MOAC project (JVARGHES)
   --

    CURSOR c_OU(c_Org_Id IN NUMBER)
    IS SELECT OU.Name
         FROM HR_ALL_ORGANIZATION_UNITS_TL OU
        WHERE OU.ORGANIZATION_ID = c_Org_Id
          AND OU.LANGUAGE = USERENV('LANG');
   --
   --

    FUNCTION Get_Line_Styles(P_lse_id IN NUMBER) Return Varchar2 is

        CURSOR get_line_style (lse_id IN NUMBER) IS
        SELECT  Id,NAME
        FROM    OKC_LINE_STYLES_V
        WHERE   ID = lse_id;

        L_Lse_Id       NUMBER;
        L_style_name   VARCHAR2(100);
    BEGIN
        L_Lse_Id       := P_lse_id;
        L_style_name   := NULL;

        FOR get_line_style_rec in get_line_style(l_Lse_id) LOOP
            l_style_name := get_line_style_rec.NAME;

        END LOOP;
        RETURN l_style_name;
    END Get_Line_Styles;

    PROCEDURE Fetch_Sts_Meaning IS

        CURSOR GET_STATUS_CUR IS
         SELECT CODE,MEANING
         FROM   OKC_STATUSES_V ;

        i Number;
    BEGIN
        i := 1;
        l_status_tab.DELETE;

        FOR GET_STATUS_REC IN GET_STATUS_CUR   LOOP
            l_status_tab(i).Code := GET_STATUS_REC.CODE;
            l_status_tab(i).Meaning := GET_STATUS_REC.MEANING;
            i := i+1;
        END LOOP;

    END Fetch_Sts_Meaning;

    FUNCTION    Get_Sts_Meaning (L_CODE IN VARCHAR2) RETURN VARCHAR2 IS
    BEGIN
        FOR I IN L_STATUS_TAB.FIRST .. L_STATUS_TAB.LAST LOOP
            IF l_Code = L_STATUS_TAB(i).CODE THEN
                    RETURN L_STATUS_TAB(i).MEANING;
            END IF;
        END LOOP;
    END Get_Sts_Meaning;

    FUNCTION  Get_Line_Processed (p_line_id IN VARCHAR2,
                              p_line_id_tbl IN OUT NOCOPY line_id_tbl ) RETURN VARCHAR2 IS

        l_line_processed        varchar2(1);

    BEGIN
        l_line_processed        := 'N';
        if p_line_id_tbl.count > 0 then
             for i in p_line_id_tbl.first..p_line_id_tbl.last loop
                if p_line_id = p_line_id_tbl(i).line_id then
                   l_line_processed := 'Y';
                   exit;
                end if;
             end loop;
             if  l_line_processed = 'N' then
                p_line_id_tbl(l_line_id_tbl.last+1).line_id    := p_line_id;
             end if;
        else
             p_line_id_tbl(1).line_id    := p_line_id;
        end if;
        return l_line_processed;
    END Get_Line_Processed;


BEGIN

    Lv_Contracts                := P_Contracts;
    Lv_Contract_line_Rec        := P_Contract_line_Rec;
    Lv_Request_Date             := nvl(P_Request_Date,sysdate);
    Lx_Result                   := G_TRUE;
    Lx_Return_Status            := G_RET_STS_SUCCESS;
    Lx_counter                  := 1;
    Lx_service_id               := -99;
    l_last_date                  :=   TO_DATE(5373484,'j');
    l_first_date                 :=   TO_DATE(1,'j');

        IF (Lv_Contract_line_Rec.Start_Date_From IS NULL) THEN
            Lv_Contract_line_Rec.Start_Date_From := l_first_date;
        END IF;
 IF (Lv_Contract_line_Rec.Start_Date_To IS NULL) THEN
            Lv_Contract_line_Rec.Start_Date_To := l_last_date;
        END IF;

        IF (Lv_Contract_line_Rec.End_Date_From IS NULL) THEN
            Lv_Contract_line_Rec.End_Date_From := l_first_date;
        END IF;

        IF (Lv_Contract_line_Rec.End_Date_To IS NULL) THEN
            Lv_Contract_line_Rec.End_Date_To := l_last_date;
        END IF;


        Lv_Contract_line_Rec.Start_Date_From := TRUNC(Lv_Contract_line_Rec.Start_Date_From);
        Lv_Contract_line_Rec.End_Date_From   := TRUNC(Lv_Contract_line_Rec.End_Date_From);
        Lv_Contract_line_Rec.Start_Date_To   := TRUNC(Lv_Contract_line_Rec.Start_Date_To) + 0.99998843;
        Lv_Contract_line_Rec.End_Date_To     := TRUNC(Lv_Contract_line_Rec.End_Date_To) + 0.99998843;
    Fetch_Sts_Meaning;

    G_GRACE_PROFILE_SET          := fnd_profile.value('OKS_ENABLE_GRACE_PERIOD');

    Lv_Contracts_02.DELETE;

  IF Lv_Contracts.COUNT = 0 THEN
/*Added for bug:6767455*/
 /* Added by Jvorugan for Bug:4991724
       If service_item_id is not null, then only passing the value.
       This is to avoid full table scan on okc_k_items due to nvl condition on service_item_id*/

    IF Lv_Contract_line_Rec.Service_Item_ID IS NULL
    THEN
       open get_Contract_noclvl_noitem_cur(NULL,
                                        NULL,
                                        Lv_Contract_line_Rec.Contract_Line_Status_Code,
                                        Lv_Contract_line_Rec.Start_Date_From,
                                        Lv_Contract_line_Rec.Start_Date_To,
                                        Lv_Contract_line_Rec.End_Date_From,
                                        Lv_Contract_line_Rec.End_Date_To,
                                        Lv_Contract_line_Rec.Coverage_Type_Code,
                                        Lv_Contract_line_Rec.Line_Bill_To_Site_Id,
                                        Lv_Contract_line_Rec.Line_Ship_To_Site_Id,
                                        Lv_Contract_line_Rec.line_renewal_type_code,
                                        Lv_authoring_org_id);
       fetch get_Contract_noclvl_noitem_cur BULK COLLECT into   Id,
                                                   contract_number,
                                                   contract_Number_Modifier,
                                                   Short_Description,
                                                   Hd_Start_Date,
                                                   Hd_End_Date,
                                                   hd_scs_code,
                                                    org_id,         /*bug:7363217*/
                                                   Service_ID,
                                                   Line_Number,
                                                   Start_Date,
                                                   End_Date,
                                                   Date_Terminated,
                                                   Sts_code,
                                                   Name,
                                                   cov_line_id,
                                                   Cov_Name,
                                                   Cov_Start_Date,
                                                   Cov_End_Date,
                                                   Cov_Date_Terminated,
                                                   Service_Lse_Id;
        close get_Contract_noclvl_noitem_cur;
     ELSE
        open get_Contract_noclvl_cur(NULL,
                                        NULL,
                                        Lv_Contract_line_Rec.Service_Item_ID,
                                        Lv_Contract_line_Rec.Contract_Line_Status_Code,
                                        Lv_Contract_line_Rec.Start_Date_From,
                                        Lv_Contract_line_Rec.Start_Date_To,
                                        Lv_Contract_line_Rec.End_Date_From,
                                        Lv_Contract_line_Rec.End_Date_To,
                                        Lv_Contract_line_Rec.Coverage_Type_Code,
                                        Lv_Contract_line_Rec.Line_Bill_To_Site_Id,
                                        Lv_Contract_line_Rec.Line_Ship_To_Site_Id,
                                        Lv_Contract_line_Rec.line_renewal_type_code,
                                        Lv_authoring_org_id);
        fetch get_Contract_noclvl_cur BULK COLLECT into         Id,
                                                   contract_number,
                                                   contract_Number_Modifier,
                                                   Short_Description,
                                                   Hd_Start_Date,
                                                   Hd_End_Date,
                                                   hd_scs_code,
                                                   org_id,         /*bug:6767455*/
                                                   Service_ID,
                                                   Line_Number,
                                                   Start_Date,
                                                   End_Date,
                                                   Date_Terminated,
                                                   Sts_code,
                                                   Name,
                                                   cov_line_id,
                                                   Cov_Name,
                                                   Cov_Start_Date,
                                                   Cov_End_Date,
                                                   Cov_Date_Terminated,
                                                   Service_Lse_Id;
	        close get_Contract_noclvl_cur;

     END IF;

   IF Id.count >0
   THEN
      FOR i in Id.FIRST..ID.LAST
      LOOP

           if nvl(lx_service_id,-99) <>Service_ID(i) then
            Lv_Contracts_02(lx_counter).Contract_Number                 :=  contract_number(i);
            Lv_Contracts_02(lx_counter).Contract_Number_Modifier        :=  contract_Number_Modifier(i);
            Lv_Contracts_02(lx_counter).Contract_Description            :=  Short_Description(i);
            Lv_Contracts_02(lx_counter).Contract_Line_Number            :=  Line_Number(i);
            Lv_Contracts_02(lx_counter).Line_Start_Date                 :=  Start_Date(i);
            Lv_Contracts_02(lx_counter).Line_End_Date                   :=  End_Date(i);
            Lv_Contracts_02(lx_counter).Contract_line_Status_code       :=  Get_Sts_Meaning(Sts_code(i));--Idx.Sts_code;
            Lv_Contracts_02(lx_counter).Service_name                    :=  name(i);
            Lv_Contracts_02(lx_counter).Coverage_name                   :=  Cov_name(i);
            Lv_Contracts_02(lx_counter).Service_Id                      :=  Service_ID(i);
            Lv_Contracts_02(lx_counter).Service_Lse_ID                  :=  Service_Lse_Id(i);
            Lv_Contracts_02(lx_counter).contract_line_type              :=  Get_Line_Styles(Service_Lse_Id(i));
            Lv_Contracts_02(lx_counter).contract_id                     :=  Id(i);
            Lv_Contracts_02(lx_counter).coverage_line_id                :=  cov_line_Id(i);
            Lv_Contracts_02(lx_counter).scs_code                        :=  hd_scs_code(i);

            /*bug:7363217*/
            --
            Lv_Contracts_02(lx_counter).OPERATING_UNIT                  :=  org_id(i);
            OPEN c_OU(org_id(i));
            FETCH c_OU INTO Lv_Contracts_02(lx_counter).OPERATING_UNIT_NAME;
            CLOSE c_OU;

            lx_counter :=lx_counter  + 1 ;
            lx_service_id := service_id(i);

            end if;
      END LOOP;
   END IF;


   /* commented  for  Bug:6767455
            For Idx In get_Contract_noclvl_cur(NULL,
                                        NULL,
                                        Lv_Contract_line_Rec.Service_Item_ID,
                                        Lv_Contract_line_Rec.Contract_Line_Status_Code,
                                        Lv_Contract_line_Rec.Start_Date_From,
                                        Lv_Contract_line_Rec.Start_Date_To,
                                        Lv_Contract_line_Rec.End_Date_From,
                                        Lv_Contract_line_Rec.End_Date_To,
                                        Lv_Contract_line_Rec.Coverage_Type_Code,
                                        Lv_Contract_line_Rec.Line_Bill_To_Site_Id,
                                        Lv_Contract_line_Rec.Line_Ship_To_Site_Id,
                                        Lv_Contract_line_Rec.line_renewal_type_code,
                                        Lv_authoring_org_id) LOOP


            if nvl(lx_service_id,-99) <> Idx.Service_id then

            Lv_Contracts_02(lx_counter).Contract_Number                 :=  Idx.Contract_Number;
            Lv_Contracts_02(lx_counter).Contract_Number_Modifier        :=  Idx.Contract_Number_Modifier;
            Lv_Contracts_02(lx_counter).Contract_Description            :=  Idx.Short_Description;
            Lv_Contracts_02(lx_counter).Contract_Line_Number            :=  Idx.Line_Number;
            Lv_Contracts_02(lx_counter).Line_Start_Date                 :=  Idx.Start_Date;
            Lv_Contracts_02(lx_counter).Line_End_Date                   :=  Idx.End_Date;
            Lv_Contracts_02(lx_counter).Contract_line_Status_code       :=  Get_Sts_Meaning(Idx.Sts_code);--Idx.Sts_code;
            Lv_Contracts_02(lx_counter).Service_name                    :=  Idx.name;
            Lv_Contracts_02(lx_counter).Coverage_name                   :=  Idx.Cov_name;
            Lv_Contracts_02(lx_counter).Service_Id                      :=  Idx.Service_ID;
            Lv_Contracts_02(lx_counter).Service_Lse_ID                  :=  Idx.Service_Lse_Id;
            Lv_Contracts_02(lx_counter).contract_line_type              :=  Get_Line_Styles(Idx.Service_Lse_Id);
            Lv_Contracts_02(lx_counter).contract_id                     :=  Idx.Id;
            Lv_Contracts_02(lx_counter).coverage_line_id                :=  Idx.cov_line_Id;
            Lv_Contracts_02(lx_counter).scs_code                        :=  Idx.hd_scs_code;

            --
            -- Modified for 12.0 MOAC project (JVARGHES)
            --
            Lv_Contracts_02(lx_counter).OPERATING_UNIT                  :=  Idx.org_id;
            OPEN c_OU(Idx.org_id);
            FETCH c_OU INTO Lv_Contracts_02(lx_counter).OPERATING_UNIT_NAME;
            CLOSE c_OU;
            --
            --

            lx_counter :=lx_counter  + 1 ;
            lx_service_id := Idx.service_id;

            end if;

    END LOOP;
*/
    END IF;

    IF  Lv_Contracts.COUNT > 0 and Lv_covlevel_lines_passed = 'Y' THEN

      FOR I In Lv_Contracts.FIRST .. Lv_Contracts.LAST LOOP

-- checking if covered level line id processed
      If Get_Line_Processed (p_line_id        => Lv_Contracts(i).Rx_Cle_ID,
                             p_line_id_tbl    => l_line_id_tbl) = 'N' then
 /* Added  for Bug:6767455
       If service_item_id is not null, then only passing the value.
       This is to avoid full table scan on okc_k_items due to nvl condition on service_item_id*/

       IF Lv_Contract_line_Rec.Service_Item_ID IS NULL
       THEN
           open get_Contract_noitem_cur(Lv_Contracts(i).Rx_Chr_ID,
                                    Lv_Contracts(i).Rx_Cle_ID,
                                    Lv_Contract_line_Rec.Contract_Line_Status_Code,
                                    Lv_Contract_line_Rec.Start_Date_From,
                                    Lv_Contract_line_Rec.Start_Date_To,
                                    Lv_Contract_line_Rec.End_Date_From,
                                    Lv_Contract_line_Rec.End_Date_To,
                                    Lv_Contract_line_Rec.Coverage_Type_Code,
                                    Lv_Contract_line_Rec.Line_Bill_To_Site_Id,
                                    Lv_Contract_line_Rec.Line_Ship_To_Site_Id,
                                    Lv_Contract_line_Rec.line_renewal_type_code,
                                    Lv_authoring_org_id);
	   fetch get_Contract_noitem_cur bulk collect into Id,
                                                   contract_number,
                                                   contract_Number_Modifier,
                                                   Short_Description,
                                                   Hd_Start_Date,
                                                   Hd_End_Date,
                                                   hd_scs_code,
                                                   org_id,         /*bug:7363217*/
                                                   Service_ID,
                                                   Line_Number,
                                                   Start_Date,
                                                   End_Date,
                                                   Date_Terminated,
                                                   Sts_code,
                                                   Name,
                                                   Item_Start_Date,
                                                   Item_End_Date,
                                                   Item_Date_Terminated,
                                                   cov_line_id,
                                                   Cov_Name,
                                                   Cov_Start_Date,
                                                   Cov_End_Date,
                                                   Cov_Date_Terminated,
                                                   Service_Lse_Id;
	   close  get_Contract_noitem_cur;
        ELSE
           open get_Contract_cur   (Lv_Contracts(i).Rx_Chr_ID,
                                    Lv_Contracts(i).Rx_Cle_ID,
                                    Lv_Contract_line_Rec.Service_Item_ID,
                                    Lv_Contract_line_Rec.Contract_Line_Status_Code,
                                    Lv_Contract_line_Rec.Start_Date_From,
                                    Lv_Contract_line_Rec.Start_Date_To,
                                    Lv_Contract_line_Rec.End_Date_From,
                                    Lv_Contract_line_Rec.End_Date_To,
                                    Lv_Contract_line_Rec.Coverage_Type_Code,
                                    Lv_Contract_line_Rec.Line_Bill_To_Site_Id,
                                    Lv_Contract_line_Rec.Line_Ship_To_Site_Id,
                                    Lv_Contract_line_Rec.line_renewal_type_code,
                                    Lv_authoring_org_id);
	   fetch get_Contract_cur  bulk collect into Id,
                                                   contract_number,
                                                   contract_Number_Modifier,
                                                   Short_Description,
                                                   Hd_Start_Date,
                                                   Hd_End_Date,
                                                   hd_scs_code,
                                                   org_id,     /*Bug:6767455*/
                                                   Service_ID,
                                                   Line_Number,
                                                   Start_Date,
                                                   End_Date,
                                                   Date_Terminated,
                                                   Sts_code,
                                                   Name,
	                         Item_Start_Date,
                                                   Item_End_Date,
                                                   Item_Date_Terminated,
                                                   cov_line_id,
                                                   Cov_Name,
                                                   Cov_Start_Date,
                                                   Cov_End_Date,
                                                   Cov_Date_Terminated,
                                                   Service_Lse_Id;
	   close  get_Contract_cur;
	END IF;
   IF Id.count >0
   THEN

      FOR i in Id.FIRST..Id.LAST
      LOOP

	if nvl(lx_service_id,-99) <> service_id(i)then

	   IF Lv_Entitlment_Check = 'Y' THEN             --Lv_Entitlment_Check = 'Y'

            Get_Valid_Line(
                            PHd_Id              =>Id(i),
                            PHd_Start_Date      =>Hd_Start_Date(i),
                            PHd_END_Date        =>Hd_End_Date(i),
                            PSv_Start_Date      =>Start_Date(i),
                            PSv_End_Date        =>End_Date(i),
                            PSv_Term_Date       =>Date_Terminated(i),
                            PIt_Start_Date      =>Item_Start_Date(i),
                            PIt_End_Date        =>Item_End_Date(i),
                            PIt_Term_Date       =>Item_Date_Terminated(i),
                            PCo_Start_Date      =>Cov_Start_Date(i),
                            PCo_End_Date        =>Cov_End_Date(i),
                            PCo_Term_Date       =>Cov_Date_Terminated(i),
                            P_Request_Date      =>Lv_Request_Date,
                            X_valid_line        =>L_valid_line,
                            X_return_Status     =>L_return_Status);

          Lv_Entile_Flag := OKC_ASSENT_PUB.LINE_OPERATION_ALLOWED(Service_ID(i), 'ENTITLE');

            IF ((Lv_Entile_Flag = 'T') AND (L_valid_line = 'T'))  THEN  --Lv_Entile_Flag = 'T'

            Lv_Contracts_02(lx_counter).Contract_Number                 :=  Contract_Number(i);
            Lv_Contracts_02(lx_counter).Contract_Number_Modifier        :=  Contract_Number_Modifier(i);
            Lv_Contracts_02(lx_counter).Contract_Description            :=  Short_Description(i);
            Lv_Contracts_02(lx_counter).Contract_Line_Number            :=  Line_Number(i);
            Lv_Contracts_02(lx_counter).Line_Start_Date                 :=  Start_Date(i);
            Lv_Contracts_02(lx_counter).Line_End_Date                   :=  End_Date(i);
            Lv_Contracts_02(lx_counter).Contract_line_Status_code       :=  Get_Sts_Meaning(Sts_code(i));--Idx.Sts_code;
            Lv_Contracts_02(lx_counter).Service_name                    :=  name(i);
            Lv_Contracts_02(lx_counter).Coverage_name                   :=  Cov_name(i);
            Lv_Contracts_02(lx_counter).Service_Id                      :=  Service_ID(i);
            Lv_Contracts_02(lx_counter).Service_Lse_ID                  :=  Service_Lse_Id(i);
            Lv_Contracts_02(lx_counter).contract_line_type              :=  Get_Line_Styles(Service_Lse_Id(i));
            Lv_Contracts_02(lx_counter).contract_id                     :=  Id(i);
            Lv_Contracts_02(lx_counter).coverage_line_id                :=  cov_line_Id(i);
            Lv_Contracts_02(lx_counter).scs_code                        :=  hd_scs_code(i);
           /*bug:7363217*/
            --
            Lv_Contracts_02(lx_counter).OPERATING_UNIT                  :=  org_id(i);
            OPEN c_OU(org_id(i));
            FETCH c_OU INTO Lv_Contracts_02(lx_counter).OPERATING_UNIT_NAME;
            CLOSE c_OU;
            lx_counter :=lx_counter  + 1 ;

             END IF; ----Lv_Entile_Flag = 'T'
           ELSE  ----Lv_Entitlment_Check = 'Y'

            Lv_Contracts_02(lx_counter).Contract_Number                 :=  Contract_Number(i);
            Lv_Contracts_02(lx_counter).Contract_Number_Modifier        :=  Contract_Number_Modifier(i);
            Lv_Contracts_02(lx_counter).Contract_Description            :=  Short_Description(i);
            Lv_Contracts_02(lx_counter).Contract_Line_Number            :=  Line_Number(i);
            Lv_Contracts_02(lx_counter).Line_Start_Date                 :=  Start_Date(i);
            Lv_Contracts_02(lx_counter).Line_End_Date                   :=   End_Date(i);
            Lv_Contracts_02(lx_counter).Contract_line_Status_code       :=  Get_Sts_Meaning(Sts_code(i));--Idx.Sts_code;
            Lv_Contracts_02(lx_counter).Service_name                    :=   name(i);
            Lv_Contracts_02(lx_counter).Coverage_name                   :=  Cov_name(i);
            Lv_Contracts_02(lx_counter).Service_Id                      :=  Service_ID(i);
            Lv_Contracts_02(lx_counter).Service_Lse_ID                  := Service_Lse_Id(i);
            Lv_Contracts_02(lx_counter).contract_line_type              :=  Get_Line_Styles(Service_Lse_Id(i));
            Lv_Contracts_02(lx_counter).contract_id                     :=  Id(i);
            Lv_Contracts_02(lx_counter).coverage_line_id                :=  cov_line_Id(i);
            Lv_Contracts_02(lx_counter).scs_code                        :=  hd_scs_code(i);

	    /*bug:7363217*/
            --
            Lv_Contracts_02(lx_counter).OPERATING_UNIT                  :=  org_id(i);
            OPEN c_OU(org_id(i));
            FETCH c_OU INTO Lv_Contracts_02(lx_counter).OPERATING_UNIT_NAME;
            CLOSE c_OU;
            lx_counter :=lx_counter  + 1 ;

           END IF;  --Lv_Entitlment_Check = 'Y'

        lx_service_id := service_id(i);

       end if;

      END LOOP;

    END IF;  -- Id.count >0


    /* commented  for perf bug:6767455
        For Idx In get_Contract_cur(Lv_Contracts(i).Rx_Chr_ID,
                                    Lv_Contracts(i).Rx_Cle_ID,
                                    Lv_Contract_line_Rec.Service_Item_ID,
                                    Lv_Contract_line_Rec.Contract_Line_Status_Code,
                                    Lv_Contract_line_Rec.Start_Date_From,
                                    Lv_Contract_line_Rec.Start_Date_To,
                                    Lv_Contract_line_Rec.End_Date_From,
                                    Lv_Contract_line_Rec.End_Date_To,
                                    Lv_Contract_line_Rec.Coverage_Type_Code,
                                    Lv_Contract_line_Rec.Line_Bill_To_Site_Id,
                                    Lv_Contract_line_Rec.Line_Ship_To_Site_Id,
                                    Lv_Contract_line_Rec.line_renewal_type_code,
                                    Lv_authoring_org_id) LOOP


        if nvl(lx_service_id,-99) <> Idx.service_id then

          IF Lv_Entitlment_Check = 'Y' THEN             --Lv_Entitlment_Check = 'Y'

            Get_Valid_Line(
                            PHd_Id              =>Idx.Id,
                            PHd_Start_Date      =>Idx.Hd_Start_Date,
                            PHd_END_Date        =>Idx.Hd_End_Date,
                            PSv_Start_Date      =>Idx.Start_Date,
                            PSv_End_Date        =>Idx.End_Date,
                            PSv_Term_Date       =>Idx.Date_Terminated,
                            PIt_Start_Date      =>Idx.Item_Start_Date,
                            PIt_End_Date        =>Idx.Item_End_Date,
                            PIt_Term_Date       =>Idx.Item_Date_Terminated,
                            PCo_Start_Date      =>Idx.Cov_Start_Date,
                            PCo_End_Date        =>Idx.Cov_End_Date,
                            PCo_Term_Date       =>Idx.Cov_Date_Terminated,
                            P_Request_Date      =>Lv_Request_Date,
                            X_valid_line        =>L_valid_line,
                            X_return_Status     =>L_return_Status);

          Lv_Entile_Flag := OKC_ASSENT_PUB.LINE_OPERATION_ALLOWED(Idx.Service_ID, 'ENTITLE');

            IF ((Lv_Entile_Flag = 'T') AND (L_valid_line = 'T'))  THEN  --Lv_Entile_Flag = 'T'

            Lv_Contracts_02(lx_counter).Contract_Number                 :=  Idx.Contract_Number;
            Lv_Contracts_02(lx_counter).Contract_Number_Modifier        :=  Idx.Contract_Number_Modifier;
            Lv_Contracts_02(lx_counter).Contract_Description            :=  Idx.Short_Description;
            Lv_Contracts_02(lx_counter).Contract_Line_Number            :=  Idx.Line_Number;
            Lv_Contracts_02(lx_counter).Line_Start_Date                 :=  Idx.Start_Date;
            Lv_Contracts_02(lx_counter).Line_End_Date                   :=  Idx.End_Date;
            Lv_Contracts_02(lx_counter).Contract_line_Status_code       :=  Get_Sts_Meaning(Idx.Sts_code);--Idx.Sts_code;
            Lv_Contracts_02(lx_counter).Service_name                    :=  Idx.name;
            Lv_Contracts_02(lx_counter).Coverage_name                   :=  Idx.Cov_name;
            Lv_Contracts_02(lx_counter).Service_Id                      :=  Idx.Service_ID;
            Lv_Contracts_02(lx_counter).Service_Lse_ID                  :=  Idx.Service_Lse_Id;
            Lv_Contracts_02(lx_counter).contract_line_type              :=  Get_Line_Styles(Idx.Service_Lse_Id);
            Lv_Contracts_02(lx_counter).contract_id                     :=  Idx.Id;
            Lv_Contracts_02(lx_counter).coverage_line_id                :=  Idx.cov_line_Id;
            Lv_Contracts_02(lx_counter).scs_code                        :=  Idx.hd_scs_code;

            --
            -- Modified for 12.0 MOAC project (JVARGHES)
            --
            Lv_Contracts_02(lx_counter).OPERATING_UNIT                  :=  Idx.org_id;
            OPEN c_OU(Idx.org_id);
            FETCH c_OU INTO Lv_Contracts_02(lx_counter).OPERATING_UNIT_NAME;
            CLOSE c_OU;
            --
            --

            lx_counter :=lx_counter  + 1 ;

            END IF; ----Lv_Entile_Flag = 'T'

        ELSE  ----Lv_Entitlment_Check = 'Y'

            Lv_Contracts_02(lx_counter).Contract_Number                 :=  Idx.Contract_Number;
            Lv_Contracts_02(lx_counter).Contract_Number_Modifier        :=  Idx.Contract_Number_Modifier;
            Lv_Contracts_02(lx_counter).Contract_Description            :=  Idx.Short_Description;
            Lv_Contracts_02(lx_counter).Contract_Line_Number            :=  Idx.Line_Number;
            Lv_Contracts_02(lx_counter).Line_Start_Date                 :=  Idx.Start_Date;
            Lv_Contracts_02(lx_counter).Line_End_Date                   :=  Idx.End_Date;
            Lv_Contracts_02(lx_counter).Contract_line_Status_code       :=  Get_Sts_Meaning(Idx.Sts_code);--Idx.Sts_code;
            Lv_Contracts_02(lx_counter).Service_name                    :=  Idx.name;
            Lv_Contracts_02(lx_counter).Coverage_name                   :=  Idx.Cov_name;
            Lv_Contracts_02(lx_counter).Service_Id                      :=  Idx.Service_ID;
            Lv_Contracts_02(lx_counter).Service_Lse_ID                  :=  Idx.Service_Lse_Id;
            Lv_Contracts_02(lx_counter).contract_line_type              :=  Get_Line_Styles(Idx.Service_Lse_Id);
            Lv_Contracts_02(lx_counter).contract_id                     :=  Idx.Id;
            Lv_Contracts_02(lx_counter).coverage_line_id                :=  Idx.cov_line_Id;
            Lv_Contracts_02(lx_counter).scs_code                        :=  Idx.hd_scs_code;

            --
            -- Modified for 12.0 MOAC project (JVARGHES)
            --
            Lv_Contracts_02(lx_counter).OPERATING_UNIT                  :=  Idx.org_id;
            OPEN c_OU(Idx.org_id);
            FETCH c_OU INTO Lv_Contracts_02(lx_counter).OPERATING_UNIT_NAME;
            CLOSE c_OU;
            --
            --

            lx_counter :=lx_counter  + 1 ;

        END IF;  --Lv_Entitlment_Check = 'Y'

        lx_service_id := Idx.service_id;

       end if;

      END LOOP;*/

-- checking if covered level line id processed
     END If;

    END LOOP;

    END IF;


    IF  Lv_Contracts.COUNT > 0 and Lv_covlevel_lines_passed = 'N' THEN
    FOR I In Lv_Contracts.FIRST .. Lv_Contracts.LAST LOOP
    /* Added by Jvorugan for Bug:4991724
       If service_item_id is not null, then only passing the value.
       This is to avoid full table scan on okc_k_items due to nvl condition on service_item_id*/

    IF Lv_Contract_line_Rec.Service_Item_ID IS NULL
    THEN

       IF Lv_Contracts(i).Rx_Chr_ID IS NOT NULL THEN

                  /*harlaksh modified for bug 8700389*/
 	           If ((Lv_authoring_org_id IS NULL) AND
 	            (Lv_Contract_line_Rec.Contract_Line_Status_Code IS NULL) AND
 	            (Lv_Contract_line_Rec.Coverage_Type_Code IS NULL) AND
 	            (Lv_Contract_line_Rec.Line_Bill_To_Site_Id IS NULL) AND
 	            (Lv_Contract_line_Rec.Line_Ship_To_Site_Id IS NULL) AND
 	            (Lv_Contract_line_Rec.line_renewal_type_code IS NULL))
 	           THEN
 	                /*CALL NEW CURSOR*/
 	                open get_Cont_noclvl_kid_noitem_cur(Lv_Contracts(i).Rx_Chr_ID,
 	                                                Lv_Contract_line_Rec.Start_Date_From,
 	                                                Lv_Contract_line_Rec.Start_Date_To,
 	                                                Lv_Contract_line_Rec.End_Date_From,
 	                                                Lv_Contract_line_Rec.End_Date_To);

 	                fetch get_Cont_noclvl_kid_noitem_cur BULK COLLECT into   Id,
 	                                                               contract_number,
 	                                                               contract_Number_Modifier,
 	                                                               Short_Description,
 	                                                               Hd_Start_Date,
 	                                                               Hd_End_Date,
 	                                                               hd_scs_code,
                                                                       org_id,
 	                                                               Service_ID,
 	                                                               Line_Number,
 	                                                               Start_Date,
 	                                                               End_Date,
 	                                                               Date_Terminated,
 	                                                               Sts_code,
 	                                                               Name,
 	                                                               cov_line_id,
 	                                                               Cov_Name,
 	                                                               Cov_Start_Date,
 	                                                               Cov_End_Date,
 	                                                               Cov_Date_Terminated,
 	                                                               Service_Lse_Id;
 	                close get_Cont_noclvl_kid_noitem_cur;

 	 ELSE

       open get_Cont_noclvl_chr_noitem_cur(Lv_Contracts(i).Rx_Chr_ID,
                                    Lv_Contracts(i).Rx_Cle_ID,
                                    Lv_Contract_line_Rec.Contract_Line_Status_Code,
                                    Lv_Contract_line_Rec.Start_Date_From,
                                    Lv_Contract_line_Rec.Start_Date_To,
                                    Lv_Contract_line_Rec.End_Date_From,
                                    Lv_Contract_line_Rec.End_Date_To,
                                    Lv_Contract_line_Rec.Coverage_Type_Code,
                                    Lv_Contract_line_Rec.Line_Bill_To_Site_Id,
                                    Lv_Contract_line_Rec.Line_Ship_To_Site_Id,
                                    Lv_Contract_line_Rec.line_renewal_type_code,
                                    Lv_authoring_org_id);

       fetch get_Cont_noclvl_chr_noitem_cur BULK COLLECT into   Id,
                                                   contract_number,
                                                   contract_Number_Modifier,
                                                   Short_Description,
                                                   Hd_Start_Date,
                                                   Hd_End_Date,
                                                   hd_scs_code,
	                          org_id,         /*bug:7363217*/
                                                   Service_ID,
                                                   Line_Number,
                                                   Start_Date,
                                                   End_Date,
                                                   Date_Terminated,
                                                   Sts_code,
                                                   Name,
                                                   cov_line_id,
                                                   Cov_Name,
                                                   Cov_Start_Date,
                                                   Cov_End_Date,
                                                   Cov_Date_Terminated,
                                                   Service_Lse_Id;
        close get_Cont_noclvl_chr_noitem_cur;
 END IF;           /*modified for bug:8700389*/
       ELSE

       open get_Contract_noclvl_noitem_cur(Lv_Contracts(i).Rx_Chr_ID,
                                    Lv_Contracts(i).Rx_Cle_ID,
                                    Lv_Contract_line_Rec.Contract_Line_Status_Code,
                                    Lv_Contract_line_Rec.Start_Date_From,
                                    Lv_Contract_line_Rec.Start_Date_To,
                                    Lv_Contract_line_Rec.End_Date_From,
                                    Lv_Contract_line_Rec.End_Date_To,
                                    Lv_Contract_line_Rec.Coverage_Type_Code,
                                    Lv_Contract_line_Rec.Line_Bill_To_Site_Id,
                                    Lv_Contract_line_Rec.Line_Ship_To_Site_Id,
                                    Lv_Contract_line_Rec.line_renewal_type_code,
                                    Lv_authoring_org_id);

       fetch get_Contract_noclvl_noitem_cur BULK COLLECT into   Id,
                                                   contract_number,
                                                   contract_Number_Modifier,
                                                   Short_Description,
                                                   Hd_Start_Date,
                                                   Hd_End_Date,
                                                   hd_scs_code,
	                          org_id,         /*bug:7363217*/
                                                   Service_ID,
                                                   Line_Number,
                                                   Start_Date,
                                                   End_Date,
                                                   Date_Terminated,
                                                   Sts_code,
                                                   Name,
                                                   cov_line_id,
                                                   Cov_Name,
                                                   Cov_Start_Date,
                                                   Cov_End_Date,
                                                   Cov_Date_Terminated,
                                                   Service_Lse_Id;
        close get_Contract_noclvl_noitem_cur;

        end if;

     ELSE

       IF Lv_Contracts(i).Rx_Chr_ID IS NOT NULL THEN

        open get_Cont_noclvl_chr_cur(Lv_Contracts(i).Rx_Chr_ID,
                                    Lv_Contracts(i).Rx_Cle_ID,
				            Lv_Contract_line_Rec.Service_Item_ID,
                                    Lv_Contract_line_Rec.Contract_Line_Status_Code,
                                    Lv_Contract_line_Rec.Start_Date_From,
                                    Lv_Contract_line_Rec.Start_Date_To,
                                    Lv_Contract_line_Rec.End_Date_From,
                                    Lv_Contract_line_Rec.End_Date_To,
                                    Lv_Contract_line_Rec.Coverage_Type_Code,
                                    Lv_Contract_line_Rec.Line_Bill_To_Site_Id,
                                    Lv_Contract_line_Rec.Line_Ship_To_Site_Id,
                                    Lv_Contract_line_Rec.line_renewal_type_code,
                                    Lv_authoring_org_id);

	fetch get_Cont_noclvl_chr_cur BULK COLLECT into Id,
                                                   contract_number,
                                                   contract_Number_Modifier,
                                                   Short_Description,
                                                   Hd_Start_Date,
                                                   Hd_End_Date,
                                                   hd_scs_code,
	                        org_id,         /*bug:7363217*/
                                                   Service_ID,
                                                   Line_Number,
                                                   Start_Date,
                                                   End_Date,
                                                   Date_Terminated,
                                                   Sts_code,
                                                   Name,
                                                   cov_line_id,
                                                   Cov_Name,
                                                   Cov_Start_Date,
                                                   Cov_End_Date,
                                                   Cov_Date_Terminated,
                                                   Service_Lse_Id;

        close get_Cont_noclvl_chr_cur;


       ELSE
        open get_Contract_noclvl_cur(Lv_Contracts(i).Rx_Chr_ID,
                                    Lv_Contracts(i).Rx_Cle_ID,
				    Lv_Contract_line_Rec.Service_Item_ID,
                                    Lv_Contract_line_Rec.Contract_Line_Status_Code,
                                    Lv_Contract_line_Rec.Start_Date_From,
                                    Lv_Contract_line_Rec.Start_Date_To,
                                    Lv_Contract_line_Rec.End_Date_From,
                                    Lv_Contract_line_Rec.End_Date_To,
                                    Lv_Contract_line_Rec.Coverage_Type_Code,
                                    Lv_Contract_line_Rec.Line_Bill_To_Site_Id,
                                    Lv_Contract_line_Rec.Line_Ship_To_Site_Id,
                                    Lv_Contract_line_Rec.line_renewal_type_code,
                                    Lv_authoring_org_id);

	fetch get_Contract_noclvl_cur BULK COLLECT into         Id,
                                                   contract_number,
                                                   contract_Number_Modifier,
                                                   Short_Description,
                                                   Hd_Start_Date,
                                                   Hd_End_Date,
                                                   hd_scs_code,
                                                   org_id,    /*Bug:6767455*/
                                                   Service_ID,
                                                   Line_Number,
                                                   Start_Date,
                                                   End_Date,
                                                   Date_Terminated,
                                                   Sts_code,
                                                   Name,
                                                   cov_line_id,
                                                   Cov_Name,
                                                   Cov_Start_Date,
                                                   Cov_End_Date,
                                                   Cov_Date_Terminated,
                                                   Service_Lse_Id;

        close get_Contract_noclvl_cur;

      END IF;

     END IF;

   IF Id.count >0
   THEN
      FOR i in Id.FIRST..ID.LAST
      LOOP

      if nvl(lx_service_id,-99) <> service_id(i) then
           /*modified for bug:8700389*/
        IF Lv_Entitlment_Check = 'Y' THEN
       Lv_Entile_Flag := OKC_ASSENT_PUB.LINE_OPERATION_ALLOWED(Service_ID(i), 'ENTITLE');

     IF (Lv_Entile_Flag = 'T')  THEN  --Lv_Entile_Flag = 'T'

            Lv_Contracts_02(lx_counter).Contract_Number                 :=  Contract_Number(i);
            Lv_Contracts_02(lx_counter).Contract_Number_Modifier        :=  Contract_Number_Modifier(i);
            Lv_Contracts_02(lx_counter).Contract_Description            :=  Short_Description(i);
            Lv_Contracts_02(lx_counter).Contract_Line_Number            :=  Line_Number(i);
            Lv_Contracts_02(lx_counter).Line_Start_Date                 :=  Start_Date(i);
            Lv_Contracts_02(lx_counter).Line_End_Date                   :=  End_Date(i);
            Lv_Contracts_02(lx_counter).Contract_line_Status_code       :=  Get_Sts_Meaning(Sts_code(i));--Idx.Sts_code;
            Lv_Contracts_02(lx_counter).Service_name                    :=  name(i);
            Lv_Contracts_02(lx_counter).Coverage_name                   :=  Cov_name(i);
            Lv_Contracts_02(lx_counter).Service_Id                      :=  Service_ID(i);
            Lv_Contracts_02(lx_counter).Service_Lse_ID                  :=  Service_Lse_Id(i);
            Lv_Contracts_02(lx_counter).contract_line_type              :=  Get_Line_Styles(Service_Lse_Id(i));
            Lv_Contracts_02(lx_counter).contract_id                     :=  Id(i);
            Lv_Contracts_02(lx_counter).coverage_line_id                :=  cov_line_Id(i);
            Lv_Contracts_02(lx_counter).scs_code                        :=  hd_scs_code(i);
          /*bug:7363217*/
            --
            Lv_Contracts_02(lx_counter).OPERATING_UNIT                  :=  org_id(i);
            OPEN c_OU(org_id(i));
            FETCH c_OU INTO Lv_Contracts_02(lx_counter).OPERATING_UNIT_NAME;
            CLOSE c_OU;
            lx_counter :=lx_counter  + 1 ;
    END IF; ----Lv_Entile_Flag = 'T'
 ELSE  ----Lv_Entitlment_Check = 'Y'
            Lv_Contracts_02(lx_counter).Contract_Number                 :=  Contract_Number(i);
            Lv_Contracts_02(lx_counter).Contract_Number_Modifier        :=  Contract_Number_Modifier(i);
            Lv_Contracts_02(lx_counter).Contract_Description            :=  Short_Description(i);
            Lv_Contracts_02(lx_counter).Contract_Line_Number            :=  Line_Number(i);
            Lv_Contracts_02(lx_counter).Line_Start_Date                 :=  Start_Date(i);
            Lv_Contracts_02(lx_counter).Line_End_Date                   :=  End_Date(i);
            Lv_Contracts_02(lx_counter).Contract_line_Status_code       :=  Get_Sts_Meaning(Sts_code(i));--Idx.Sts_code;
            Lv_Contracts_02(lx_counter).Service_name                    :=  name(i);
            Lv_Contracts_02(lx_counter).Coverage_name                   :=  Cov_name(i);
            Lv_Contracts_02(lx_counter).Service_Id                      :=  Service_ID(i);
            Lv_Contracts_02(lx_counter).Service_Lse_ID                  :=  Service_Lse_Id(i);
            Lv_Contracts_02(lx_counter).contract_line_type              :=  Get_Line_Styles(Service_Lse_Id(i));
            Lv_Contracts_02(lx_counter).contract_id                     :=  Id(i);
            Lv_Contracts_02(lx_counter).coverage_line_id                :=  cov_line_Id(i);
            Lv_Contracts_02(lx_counter).scs_code                        :=  hd_scs_code(i);

            Lv_Contracts_02(lx_counter).OPERATING_UNIT                  :=  org_id(i);
            OPEN c_OU(org_id(i));
            FETCH c_OU INTO Lv_Contracts_02(lx_counter).OPERATING_UNIT_NAME;
            CLOSE c_OU;
            lx_counter :=lx_counter  + 1 ;
        END IF;  --Lv_Entitlment_Check = 'Y'
           lx_service_id := service_id(i);
    end if;-- lx_service_id

      END LOOP;

    END IF;  -- Id.count >0
         /* commented for Bug:6767455
             For Idx In get_Contract_noclvl_cur(Lv_Contracts(i).Rx_Chr_ID,
                                    Lv_Contracts(i).Rx_Cle_ID,
                                    Lv_Contract_line_Rec.Service_Item_ID,
                                    Lv_Contract_line_Rec.Contract_Line_Status_Code,
                                    Lv_Contract_line_Rec.Start_Date_From,
                                    Lv_Contract_line_Rec.Start_Date_To,
                                    Lv_Contract_line_Rec.End_Date_From,
                                    Lv_Contract_line_Rec.End_Date_To,
                                    Lv_Contract_line_Rec.Coverage_Type_Code,
                                    Lv_Contract_line_Rec.Line_Bill_To_Site_Id,
                                    Lv_Contract_line_Rec.Line_Ship_To_Site_Id,
                                    Lv_Contract_line_Rec.line_renewal_type_code,
                                    Lv_authoring_org_id) LOOP


        if nvl(lx_service_id,-99) <> Idx.service_id then


            Lv_Contracts_02(lx_counter).Contract_Number                 :=  Idx.Contract_Number;
            Lv_Contracts_02(lx_counter).Contract_Number_Modifier        :=  Idx.Contract_Number_Modifier;
            Lv_Contracts_02(lx_counter).Contract_Description            :=  Idx.Short_Description;
            Lv_Contracts_02(lx_counter).Contract_Line_Number            :=  Idx.Line_Number;
            Lv_Contracts_02(lx_counter).Line_Start_Date                 :=  Idx.Start_Date;
            Lv_Contracts_02(lx_counter).Line_End_Date                   :=  Idx.End_Date;
            Lv_Contracts_02(lx_counter).Contract_line_Status_code       :=  Get_Sts_Meaning(Idx.Sts_code);--Idx.Sts_code;
            Lv_Contracts_02(lx_counter).Service_name                    :=  Idx.name;
            Lv_Contracts_02(lx_counter).Coverage_name                   :=  Idx.Cov_name;
            Lv_Contracts_02(lx_counter).Service_Id                      :=  Idx.Service_ID;
            Lv_Contracts_02(lx_counter).Service_Lse_ID                  :=  Idx.Service_Lse_Id;
            Lv_Contracts_02(lx_counter).contract_line_type              :=  Get_Line_Styles(Idx.Service_Lse_Id);
            Lv_Contracts_02(lx_counter).contract_id                     :=  Idx.Id;
            Lv_Contracts_02(lx_counter).coverage_line_id                :=  Idx.cov_line_Id;
            Lv_Contracts_02(lx_counter).scs_code                        :=  Idx.hd_scs_code;

            --
            -- Modified for 12.0 MOAC project (JVARGHES)
            --
            Lv_Contracts_02(lx_counter).OPERATING_UNIT                  :=  Idx.org_id;
            OPEN c_OU(Idx.org_id);
            FETCH c_OU INTO Lv_Contracts_02(lx_counter).OPERATING_UNIT_NAME;
            CLOSE c_OU;
            --
            --

            lx_counter :=lx_counter  + 1 ;

            lx_service_id := Idx.service_id;

       end if;

      END LOOP;
*/
    END LOOP;

    END IF;

    X_Contracts_02 := Lv_Contracts_02;
    X_Result        :=Lx_Result;
    X_Return_Status := Lx_Return_Status;

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
	,P_Token2_Value   => 'Get_Contract_Lines');

     X_Result            := G_FALSE;
     X_Return_Status     := G_RET_STS_UNEXP_ERROR;

END Get_Contract_Lines;

PROCEDURE Search_Contract_lines
    (p_api_version         		IN  Number
    ,p_init_msg_list       		IN  Varchar2
    ,p_contract_rec        		IN  srchline_inpcontrec_type
    ,p_contract_line_rec        IN  srchline_inpcontlinerec_type
    ,p_clvl_id_tbl         		IN  srchline_covlvl_id_tbl
    ,x_return_status       		out nocopy Varchar2
    ,x_msg_count           		out nocopy Number
    ,x_msg_data            		out nocopy Varchar2
    ,x_contract_tbl        		out nocopy output_tbl_contractline)IS

    i                           NUMBER;
    j                           NUMBER;
    l                           number;
    Lx_Chr_Id                   NUMBER;

    Lx_Inp_Rec_03               srchline_inpcontrec_type;
    Lx_Inp_Rec_02               srchline_inpcontlinerec_type;
    Lx_Inp_Tbl_01               srchline_covlvl_id_tbl;
    Lx_Ent_ContractLiness       output_tbl_contractline;

    Lx_request_date             date;


    Lx_Result                   Gx_Boolean;
    Lx_Return_Status            Gx_Ret_Sts;
    Ln_Org_Id                   NUMBER;
    Ln_Organization_Id          NUMBER;
    Lx_Contract_Id              NUMBER;


    L_EXCEP_UNEXPECTED_ERR      EXCEPTION;

    Lx_Contracts_02             GT_Contract_Ref;
    Lx_Contracts                GT_Contract_Ref;
    Lx_Contracts_Temp           GT_Contract_Ref;
    Lx_Contracts_Out            GT_Contract_Ref;
    Lx_Contracts_Line           GT_Contract_Ref;
    Lx_Contracts_Prev           GT_Contract_Ref;
    Lx_Contracts_ContNum        GT_Contract_Ref;

    Lx_Validate_Eff             VARCHAR2(1);
    Lx_Validate_Flag            VARCHAR2(1);

    Lx_Rec_Exists               VARCHAR2(1);

    Lx_Covlevel_lines_passed       VARCHAR2(1);

BEGIN  -- Main Begin for Search_Contract_line

    Lx_Chr_Id                   := -99999;
    Lx_Inp_Rec_03               := p_contract_rec;
    Lx_Inp_Rec_02               := p_contract_line_rec;
    Lx_Inp_Tbl_01               := p_clvl_id_tbl;
    Lx_request_date             := nvl(p_contract_rec.request_date,sysdate);
    Lx_Return_Status            := G_RET_STS_SUCCESS;
    Lx_Result                   := G_TRUE;
    Lx_Validate_Eff             := 'F';
    Lx_Validate_Flag            := 'F';
    Lx_Rec_Exists               := 'N';


 -- Bug# 4735542
 -- OKC_CONTEXT.set_okc_org_context;
 -- Ln_Organization_Id          := SYS_CONTEXT('OKC_CONTEXT','ORGANIZATION_ID');

 -- Modified for 12.0 MOAC project (JVARGHES)
 -- Ln_Org_Id                   := SYS_CONTEXT('OKC_CONTEXT','ORG_ID');
 --

    IF ((Lx_Inp_Rec_02.service_item_id              IS NULL) AND
        (Lx_Inp_Rec_02.contract_line_status_code    IS NULL) AND
        (Lx_Inp_Rec_02.coverage_type_code           IS NULL) AND
        (Lx_Inp_Rec_02.start_date_from              IS NULL) AND
        (Lx_Inp_Rec_02.start_date_to                IS NULL) AND
        (Lx_Inp_Rec_02.end_date_from                IS NULL) AND
        (Lx_Inp_Rec_02.end_date_to                  IS NULL) AND
        (Lx_Inp_Rec_02.line_bill_to_site_id         IS NULL) AND
        (Lx_Inp_Rec_02.line_ship_to_site_id         IS NULL) AND
        (Lx_Inp_Rec_02.line_renewal_type_code       IS NULL))   THEN


        G_Service_Line_Data := 'N';
    ELSE

        G_Service_Line_Data := 'Y';

    END IF;


    IF ((Lx_Inp_Rec_03.contract_id                  IS NULL) AND
        (Lx_Inp_Rec_03.contract_number              IS NULL) AND
        (Lx_Inp_Rec_03.contract_number_modifier     IS NULL) AND
        (Lx_Inp_Rec_03.contract_status_code         IS NULL) AND
        (Lx_Inp_Rec_03.start_date_from              IS NULL) AND
        (Lx_Inp_Rec_03.start_date_to                IS NULL) AND
        (Lx_Inp_Rec_03.end_date_from                IS NULL) AND
        (Lx_Inp_Rec_03.end_date_to                  IS NULL) AND
        (Lx_Inp_Rec_03.date_terminated_from         IS NULL) AND
        (Lx_Inp_Rec_03.date_terminated_to           IS NULL) AND
        (Lx_Inp_Rec_03.contract_party_id            IS NULL) AND
        (Lx_Inp_Rec_03.contract_renewal_type_code   IS NULL) AND
        (Lx_Inp_Rec_03.request_date                 IS NULL) AND
        (Lx_Inp_Rec_03.contract_group_id            IS NULL)) THEN

        G_Header_Data       := 'N' ;
    ELSE
        G_Header_Data       := 'Y' ;
    END IF;


    IF Lx_Inp_Tbl_01.COUNT > 0 THEN --Lx_Inp_Tbl_01.COUNT > 0

        FOR i in Lx_Inp_Tbl_01.FIRST..Lx_Inp_Tbl_01.LAST  LOOP  --1st LOOP

             IF Lx_Inp_Tbl_01(i).covlvl_code = 'OKX_CUSTPROD' THEN  -- 2nd if

                  Get_CovProd_Contracts
                    (P_CovProd_Obj_Id         => Lx_Inp_Tbl_01(i).covlvl_id1
                    ,P_Organization_Id        => Ln_Organization_Id   --Lx_Inp_Tbl_01(i).covlvl_id2
                    ,P_Org_Id                 => Ln_Org_Id
                    ,X_CovProd_Contracts      => Lx_Contracts
                    ,X_Result                 => Lx_Result
                    ,X_Return_Status   	  => Lx_Return_Status);

                  IF Lx_Result <> G_TRUE THEN
                    RAISE L_EXCEP_UNEXPECTED_ERR;
                  END IF;

            ELSIF Lx_Inp_Tbl_01(i).covlvl_code = 'OKX_COVITEM' THEN

                Get_CovItem_Contracts
                  (P_CovItem_Obj_Id         => Lx_Inp_Tbl_01(i).covlvl_id1
                  ,P_Organization_Id        => Lx_Inp_Tbl_01(i).covlvl_id2
                  ,P_Party_Id               => Lx_Inp_Rec_03.Contract_Party_Id
                  ,X_CovItem_Contracts      => Lx_Contracts
                  ,X_Result                 => Lx_Result
                  ,X_Return_Status   	    => Lx_Return_Status);

                IF Lx_Result <> G_TRUE THEN
                      RAISE L_EXCEP_UNEXPECTED_ERR;
                END IF;

         -- END IF;

             ELSIF Lx_Inp_Tbl_01(i).covlvl_code = 'OKX_COVSYST' THEN -- 3rd If

                Get_CovSys_Contracts
                  (P_CovSys_Obj_Id          => Lx_Inp_Tbl_01(i).covlvl_id1
                  ,P_Org_Id                 => Ln_Org_Id
                  ,X_CovSys_Contracts       => Lx_Contracts --_Temp
                  ,X_Result                 => Lx_Result
                  ,X_Return_Status   	    => Lx_Return_Status);

                IF Lx_Result <> G_TRUE THEN
                  RAISE L_EXCEP_UNEXPECTED_ERR;
                END IF;

            ELSIF Lx_Inp_Tbl_01(i).covlvl_code = 'OKX_CUSTACCT' THEN

                Get_CovCust_Contracts
              (P_CovCust_Obj_Id         => Lx_Inp_Tbl_01(i).covlvl_id1
              ,X_CovCust_Contracts      => Lx_Contracts --_Temp
              ,X_Result                 => Lx_Result
              ,X_Return_Status   	    => Lx_Return_Status);

            IF Lx_Result <> G_TRUE THEN
              RAISE L_EXCEP_UNEXPECTED_ERR;
            END IF;

            ELSIF Lx_Inp_Tbl_01(i).covlvl_code = 'OKX_PARTYSITE' THEN

                Get_CovSite_Contracts
              (P_CovSite_Obj_Id         => Lx_Inp_Tbl_01(i).covlvl_id1
              ,P_Org_Id                 => Ln_Org_Id
              ,X_CovSite_Contracts      => Lx_Contracts --_Temp
              ,X_Result                 => Lx_Result
              ,X_Return_Status   	    => Lx_Return_Status);

            IF Lx_Result <> G_TRUE THEN
              RAISE L_EXCEP_UNEXPECTED_ERR;
            END IF;

            ELSIF Lx_Inp_Tbl_01(i).covlvl_code = 'OKX_PARTY' THEN

            Get_CovParty_Contracts
              (P_CovParty_Obj_Id        => Lx_Inp_Tbl_01(i).covlvl_id1
              ,X_CovParty_Contracts     => Lx_Contracts --_Temp
              ,X_Result                 => Lx_Result
              ,X_Return_Status   	    => Lx_Return_Status);

            IF Lx_Result <> G_TRUE THEN
              RAISE L_EXCEP_UNEXPECTED_ERR;
            END IF;

            END IF;-- 3rd If


            IF i = Lx_Inp_Tbl_01.FIRST THEN  --4th IF
                Lx_Contracts_Prev :=  Lx_Contracts;
                Lx_Contracts.DELETE;

            ELSE

                Append_Contract_PlSql_Table
                (P_Input_Tab          => Lx_Contracts_Prev
                ,P_Append_Tab         => Lx_Contracts
                ,X_Output_Tab         => Lx_Contracts_Out
                ,X_Result             => Lx_Result
                ,X_Return_Status      => Lx_Return_Status);

                  IF Lx_Result <> G_TRUE THEN
                    RAISE L_EXCEP_UNEXPECTED_ERR;
                  END IF;

                    Lx_Contracts_Prev.DELETE;
                    Lx_Contracts_Prev := Lx_Contracts_Out;
                    Lx_Contracts_Out.DELETE;
                    Lx_Contracts.DELETE;

            END IF;  --4th IF

        --END IF;  -- 2nd if
        END LOOP;            --1st LOOP
        Lx_Contracts := Lx_Contracts_Prev;

    END IF;     --Lx_Inp_Tbl_01.COUNT > 0

    IF Lx_Contracts.COUNT > 1 THEN
     Sort_Asc_ContRef_PlSql_Table
        (P_Input_Tab          => Lx_Contracts
        ,X_Output_Tab         => Lx_Contracts_Out
        ,X_Result             => Lx_Result
        ,X_Return_Status      => Lx_Return_Status);


             IF Lx_Result <> G_TRUE THEN
                RAISE L_EXCEP_UNEXPECTED_ERR;
             END IF;
    ELSE
        Lx_Contracts_Out :=   Lx_Contracts;

    END IF;

    Lx_Contracts.DELETE;
    Lx_Contracts    := Lx_Contracts_Out; -- signifies covered level inputs entered but no covered level line exists



IF (((Lx_Inp_Rec_03.Contract_Number IS NOT NULL) AND (Lx_Inp_Rec_03.Contract_Number_modifier IS NOT NULL)) OR
    (Lx_Inp_Rec_03.Contract_Id IS NOT NULL)) THEN


    Get_Contract_Id
    (P_contract_id                  => Lx_Inp_Rec_03.Contract_Id
    ,P_Contract_Num                 => Lx_Inp_Rec_03.Contract_Number
    ,P_Contract_Num_Modifier        => Lx_Inp_Rec_03.Contract_Number_Modifier
    ,P_START_DATE_FROM              => Lx_Inp_Rec_03.START_DATE_FROM
    ,P_START_DATE_TO                => Lx_Inp_Rec_03.START_DATE_TO
    ,P_END_DATE_FROM                => Lx_Inp_Rec_03.END_DATE_FROM
    ,P_END_DATE_TO                  => Lx_Inp_Rec_03.END_DATE_TO
    ,P_DATE_TERMINATE_FROM          => Lx_Inp_Rec_03.DATE_TERMINATED_FROM
    ,P_DATE_TERMINATE_TO            => Lx_Inp_Rec_03.DATE_TERMINATED_TO
    ,P_STATUS                       => Lx_Inp_Rec_03.CONTRACT_STATUS_CODE
    ,P_Cont_Pty_Id                  => Lx_Inp_Rec_03.contract_party_id
    ,P_cont_renewal_code            => Lx_Inp_Rec_03.contract_renewal_type_code
    ,P_authoring_org_id             => Lx_Inp_Rec_03.authoring_org_id
    ,P_contract_grp_id              => Lx_Inp_Rec_03.contract_group_id -- additional header level criteria added dtd Dec 17th, 2003
    ,X_Contracts                    => Lx_Contracts_ContNum
    ,X_Result                       => Lx_Result
    ,X_Return_Status                => Lx_Return_Status);


        IF Lx_Result <> G_TRUE THEN
            RAISE L_EXCEP_UNEXPECTED_ERR;
        END IF;

    IF Lx_Contracts_ContNum.COUNT > 0 THEN  --Lx_Contracts_ContNum.COUNT > 0

        Lx_Chr_Id := Lx_Contracts_ContNum(1).Rx_Chr_Id;

        IF Lx_Contracts_Out.COUNT > 0 THEN

            i   := Lx_Contracts_Out.First;
            j   := 1;

            WHILE i IS NOT NULL LOOP

                IF Lx_Chr_Id = Lx_Contracts_Out(i).Rx_Chr_Id THEN

                    Lx_Contracts_02(j) := Lx_Contracts_Out(i);

                END IF;

                i := Lx_Contracts_Out.Next(i);
                j := j+1;

            END LOOP;

            Lx_Contracts_Out.DELETE;
            Lx_Contracts_Out := Lx_Contracts_02;
            Lx_Contracts_02.DELETE;

        ELSE

            Lx_Contracts_Out(1).Rx_Chr_Id :=   Lx_Chr_Id;
            Lx_Contracts_Out(1).Rx_Cle_Id :=   Lx_Contracts_ContNum(1).Rx_Cle_Id;

        END IF;
    ELSE
        Lx_Contracts_Out.DELETE;

    END IF;--Lx_Contracts_ContNum.COUNT > 0
END IF;  ----Lx_Inp_Rec_03.Contract_Number IS NOT NULL


IF ((Lx_Inp_Rec_03.Contract_id IS NULL) AND
    ((Lx_Inp_Rec_03.Contract_Number      Is NOT NULL) OR
     (Lx_Inp_Rec_03.Contract_Status_Code Is NOT NULL) OR
     (Lx_Inp_Rec_03.Start_Date_From      Is NOT NULL) OR
     (Lx_Inp_Rec_03.Start_Date_To        Is NOT NULL) OR
     (Lx_Inp_Rec_03.End_Date_From        Is NOT NULL) OR
     (Lx_Inp_Rec_03.End_Date_To          Is NOT NULL) OR
     (Lx_Inp_Rec_03.Date_Terminated_From Is NOT NULL) OR
     (Lx_Inp_Rec_03.Date_Terminated_To   Is NOT NULL) OR
     (Lx_Inp_Rec_03.contract_party_id    Is NOT NULL) OR
     (Lx_Inp_Rec_03.contract_group_id    Is NOT NULL) OR -- additional header level criteria added dtd Dec 17th, 2003
     (Lx_Inp_Rec_03.contract_renewal_type_code   Is NOT NULL))) THEN

    Get_Contract_Id
    (P_contract_id                  => NULL
    ,P_Contract_Num                 => Lx_Inp_Rec_03.Contract_Number
    ,P_Contract_Num_Modifier        => Lx_Inp_Rec_03.Contract_Number_Modifier
    ,P_START_DATE_FROM              => Lx_Inp_Rec_03.START_DATE_FROM
    ,P_START_DATE_TO                => Lx_Inp_Rec_03.START_DATE_TO
    ,P_END_DATE_FROM                => Lx_Inp_Rec_03.END_DATE_FROM
    ,P_END_DATE_TO                  => Lx_Inp_Rec_03.END_DATE_TO
    ,P_DATE_TERMINATE_FROM          => Lx_Inp_Rec_03.DATE_TERMINATED_FROM
    ,P_DATE_TERMINATE_TO            => Lx_Inp_Rec_03.DATE_TERMINATED_TO
    ,P_STATUS                       => Lx_Inp_Rec_03.CONTRACT_STATUS_CODE
    ,P_Cont_Pty_Id                  => Lx_Inp_Rec_03.contract_party_id
    ,P_cont_renewal_code            => Lx_Inp_Rec_03.contract_renewal_type_code
    ,P_authoring_org_id             => Lx_Inp_Rec_03.authoring_org_id
    ,P_contract_grp_id              => Lx_Inp_Rec_03.contract_group_id -- additional header level criteria added dtd Dec 17th, 2003
    ,X_Contracts                    => Lx_Contracts_ContNum
    ,X_Result                       => Lx_Result
    ,X_Return_Status                => Lx_Return_Status);


        IF Lx_Result <> G_TRUE THEN
            RAISE L_EXCEP_UNEXPECTED_ERR;
        END IF;


    l   := 0;

    IF Lx_Contracts_ContNum.COUNT > 0 THEN  --Lx_Contracts_ContNum.COUNT > 0

        IF Lx_Contracts_Out.COUNT > 0 THEN  --Lx_Contracts_Out.COUNT > 0

           FOR I in Lx_Contracts_ContNum.First .. Lx_Contracts_ContNum.LAST LOOP

            FOR K in Lx_Contracts_Out.FIRST .. Lx_Contracts_Out.LAST LOOP

                IF Lx_Contracts_ContNum(i).Rx_Chr_Id = Lx_Contracts_Out(k).Rx_Chr_Id THEN

                    l   := l+1;
                    Lx_Contracts_02(l).Rx_Chr_Id := Lx_Contracts_Out(k).Rx_Chr_Id;
                    Lx_Contracts_02(l).Rx_Cle_Id := Lx_Contracts_Out(k).Rx_Cle_Id;
                    Lx_Contracts_02(l).Rx_Pty_Id := Lx_Contracts_Out(k).Rx_Pty_Id;

                END IF;

            END LOOP;
           END LOOP;

            Lx_Contracts_Out.DELETE;
            Lx_Contracts_Out := Lx_Contracts_02;
            Lx_Contracts_02.DELETE;

        ELSE

            Lx_Contracts_Out := Lx_Contracts_ContNum;

        END IF;    --Lx_Contracts_Out.COUNT > 0

    ELSE

        Lx_Contracts_Out.DELETE;

    END IF;

END IF;


IF  (( Lx_Inp_Tbl_01.COUNT=0 and G_Header_Data ='N')  OR
     ( Lx_Inp_Tbl_01.COUNT >0 and G_Header_Data ='N' and Lx_Contracts.COUNT>0 )OR
     ( Lx_Inp_Tbl_01.COUNT >0 and G_Header_Data ='Y' and Lx_Contracts.COUNT>0 and Lx_Contracts_Out.COUNT>0 ) OR
     ( Lx_Inp_Tbl_01.COUNT =0 and G_Header_Data ='Y' and Lx_Contracts_Out.COUNT>0)) then

  if Lx_contracts.count > 0 then
    Lx_Covlevel_lines_passed := 'Y';
  else
    Lx_Covlevel_lines_passed := 'N';
  end if;

    Get_Contract_Lines
        (P_Contracts               =>  Lx_Contracts_Out
        ,P_Contract_line_Rec       =>  Lx_Inp_Rec_02
        ,p_Covlevel_lines_passed   =>  Lx_Covlevel_lines_passed
        ,P_Request_Date            =>  Lx_request_date --Lx_Inp_Rec_03.Request_Date
        ,P_Entitlement_Check_YN    =>  Lx_Inp_Rec_03.entitlement_check_YN
        ,P_authoring_org_id        =>  Lx_Inp_Rec_03.authoring_org_id -- multi org security check
        ,X_Contracts_02            =>  Lx_Ent_ContractLiness
        ,X_Result                  =>  Lx_Result
        ,X_Return_Status   	       =>  Lx_Return_Status)   ;

END IF;

        IF Lx_Result <> G_TRUE THEN
            RAISE L_EXCEP_UNEXPECTED_ERR;
        END IF;


    X_Contract_tbl        := Lx_Ent_ContractLiness;--Lx_Ent_Contracts;
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
	,P_Token2_Value   => 'Search_Contracts_Lines');

   --  X_Result            := G_FALSE;
     X_Return_Status     := G_RET_STS_UNEXP_ERROR;

END Search_Contract_lines; -- Main End for Search_Contract_line

-- Bug# 4899844

  FUNCTION Get_BPL_Offset_Start_Date
   (P_SVL_Start_Date IN DATE
   ,P_Offset_Timeunit IN VARCHAR2
   ,P_Offset_Duration IN NUMBER) RETURN DATE
  IS

   l_BPL_Offset_Start_Date  DATE;

  BEGIN

    IF (P_SVL_Start_Date IS NOT NULL)
     AND (P_Offset_Timeunit IS NOT NULL)
       AND (P_Offset_Timeunit IS NOT NULL) THEN

         l_BPL_Offset_Start_Date := OKC_Time_Util_Pub.Get_EndDate(P_SVL_Start_Date,P_Offset_Timeunit,P_Offset_Duration)+1;

    ELSE

         l_BPL_Offset_Start_Date  := P_SVL_Start_Date;

    END IF;

    RETURN l_BPL_Offset_Start_Date ;

  END Get_BPL_Offset_Start_Date;

--

END OKS_ENTITLEMENTS_PVT;

/
