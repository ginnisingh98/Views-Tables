--------------------------------------------------------
--  DDL for Package Body OKS_COV_ENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_COV_ENT_PVT" AS
/* $Header: OKSRCENB.pls 120.3.12010000.2 2010/05/03 12:34:58 vgujarat ship $ */

 PROCEDURE Get_default_react_resolve_by
    (p_api_version                in  number
    ,p_init_msg_list              in  varchar2
    ,p_inp_rec                    in  gdrt_inp_rec_type
    ,x_return_status              out nocopy varchar2
    ,x_msg_count                  out nocopy number
    ,x_msg_data                   out nocopy varchar2
    ,x_react_rec                  out nocopy rcn_rsn_rec_type
    ,x_resolve_rec                out nocopy rcn_rsn_rec_type)
   IS

    Lx_SVL_Id                  CONSTANT Gx_OKS_Id           := p_inp_rec.Coverage_Template_Id; --p_inp_rec.Contract_Line_Id;
    Lx_BusiProc_Id             CONSTANT Gx_BusProcess_Id    := p_inp_rec.Business_Process_Id;
    Lx_Severity_Id             CONSTANT Gx_Severity_Id      := p_inp_rec.Severity_id;
    Ld_Request_Date            CONSTANT DATE                := nvl(p_inp_rec.Request_Date,sysdate);
    Lx_Request_TZone_Id        CONSTANT Gx_TimeZoneId       := p_inp_rec.Time_Zone_Id;
    Lx_ReactReso_Category      CONSTANT VARCHAR2(30)        := 'RCN_RSN'; --Gx_Rule_Category := p_inp_rec.category_rcn_rsn;
    Lx_Set_ExcepionStack       CONSTANT Gx_Boolean          := G_TRUE;
    Lv_Option                  CONSTANT VARCHAR2(10)        := null; --p_inp_rec.compute_option;
    Lv_Template_YN             CONSTANT VARCHAR2(1)         := 'Y';

    /*vgujarat - modified for access hour ER 9675504*/
    Lx_cust_id                 CONSTANT NUMBER              := p_inp_rec.cust_id;
    Lx_cust_site_id            CONSTANT NUMBER              := p_inp_rec.cust_site_id;
    Lx_cust_loc_id             CONSTANT NUMBER              := p_inp_rec.cust_loc_id;

    Lx_React_Durn              Gx_ReactDurn;
    Lx_React_UOM               Gx_ReactUOM;
    Lv_React_Day               VARCHAR2(25);
    Ld_React_By_DateTime       DATE;
    Ld_React_Start_DateTime    DATE;

    Lx_Resol_Durn              Gx_ReactDurn;
    Lx_Resol_UOM               Gx_ReactUOM;
    Lv_Resol_Day               VARCHAR2(25);
    Ld_Resol_By_DateTime       DATE;
    Ld_Resol_Start_DateTime    DATE;

    Lx_Result                  Gx_Boolean DEFAULT G_TRUE;
    Lx_Return_Status           Gx_Ret_Sts DEFAULT G_RET_STS_SUCCESS;

    -- Added for 12.0 ENT-TZ project (JVARGHES)
    Lx_Dates_In_Input_TZ       CONSTANT VARCHAR2(1)  := p_inp_rec.Dates_In_Input_TZ;
    --

  BEGIN
    /*vgujarat - modified for access hour ER 9675504*/
    OKS_ENTITLEMENTS_PVT.Get_ReactResol_By_DateTime
      (P_API_Version		    => P_API_Version
      ,P_Init_Msg_List	        => P_Init_Msg_List
      ,P_SVL_Id	                => Lx_SVL_Id
      ,P_BusiProc_Id	        => Lx_BusiProc_Id
      ,P_Severity_Id	        => Lx_Severity_Id
      ,P_Request_Date	        => Ld_Request_Date
      ,P_Request_TZone_Id       => Lx_Request_TZone_Id
      ,P_Dates_In_Input_TZ      => Lx_Dates_In_Input_TZ  -- Added for 12.0 ENT-TZ project (JVARGHES)
      ,P_Option                 => Lv_Option
      ,P_Rcn_Rsn_Flag           => Lx_ReactReso_Category
      ,P_Set_ExcepionStack      => Lx_Set_ExcepionStack
      ,P_Template_YN            => Lv_Template_YN -- for default coverage functionality
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
      ,X_Msg_count		        => X_Msg_Count
      ,X_Msg_Data		        => X_Msg_Data
      ,X_Result                 => Lx_Result
      ,X_Return_Status          => Lx_Return_Status
      ,P_cust_id                => Lx_cust_id
      ,P_cust_site_id           => Lx_cust_site_id
      ,P_cust_loc_id            => Lx_cust_loc_id);

    x_react_rec.by_date_start    :=  Ld_React_Start_DateTime;
    x_react_rec.by_date_end      :=  Ld_React_By_DateTime;

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
	,P_Token2_Value   => 'Get_default_react_resolve_by');

      X_Return_Status     := G_RET_STS_UNEXP_ERROR;

 END Get_default_react_resolve_by;

END OKS_COV_ENT_PVT;

/
