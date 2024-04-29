--------------------------------------------------------
--  DDL for Package OKS_PM_ENTITLEMENTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_PM_ENTITLEMENTS_PVT" AUTHID CURRENT_USER AS
/* $Header: OKSRPMES.pls 120.0 2005/05/25 18:34:51 appldev noship $ */

-----------------------------------------------------------------------------------------------------------------------*

  SUBTYPE Gx_Boolean         IS VARCHAR2(1);
  SUBTYPE Gx_YesNo           IS VARCHAR2(1);
  SUBTYPE Gx_Ret_Sts         IS VARCHAR2(1);
  SUBTYPE Gx_ExceptionMsg    IS VARCHAR2(200);

-----------------------------------------------------------------------------------------------------------------------*

  SUBTYPE Gx_TimeZoneId      IS NUMBER; --OKX_TIMEZONES_V.TIMEZONE_ID%TYPE;
  SUBTYPE Gx_ReactDurn       IS number; --OKC_REACT_INTERVALS.DURATION%TYPE;
  SUBTYPE Gx_ReactUOM        IS varchar2(30); --OKC_REACT_INTERVALS.UOM_CODE%TYPE;
  SUBTYPE Gx_OKS_Id          IS NUMBER;
  SUBTYPE Gx_BusProcess_Id   IS NUMBER; --OKX_BUS_PROCESSES_V.ID1%TYPE;
  SUBTYPE Gx_Severity_Id     IS NUMBER; --OKX_INCIDENT_SEVERITS_V.ID1%TYPE;
  SUBTYPE Gx_JTOT_ObjCode    IS varchar2(30); --JTF_OBJECTS_B.OBJECT_CODE%TYPE;
  SUBTYPE Gx_Rule_Id         IS number; --OKC_RULES_B.ID%TYPE;
  SUBTYPE Gx_Rule_Category   IS varchar2(90); --OKC_RULES_B.RULE_INFORMATION_CATEGORY%TYPE;
  SUBTYPE Gx_TimeValue_Type  IS varchar2(30); --OKC_TIMEVALUES_B.TVE_TYPE%TYPE;

  SUBTYPE Gx_Chr_StsCode     IS OKC_K_HEADERS_B.STS_CODE%TYPE;
  SUBTYPE Gx_Chr_Type        IS OKC_K_HEADERS_B.CHR_TYPE%TYPE;
  SUBTYPE Gx_Chr_PartyId     IS OKC_K_PARTY_ROLES_B.OBJECT1_ID1%TYPE;

  SUBTYPE Gx_Itm_Obj1Id1     IS OKC_K_ITEMS.OBJECT1_ID1%TYPE;
  SUBTYPE Gx_Itm_Obj1Id2     IS OKC_K_ITEMS.OBJECT1_ID2%TYPE;

  SUBTYPE Inp_Rec_Type       IS OKS_ENTITLEMENTS_PUB.Inp_Rec_Type;
  SUBTYPE Hdr_Tbl_Type       IS OKS_ENTITLEMENTS_PUB.Hdr_Tbl_Type;

  SUBTYPE Line_Tbl_Type      IS OKS_ENTITLEMENTS_PUB.Line_Tbl_Type;

  SUBTYPE Clvl_Tbl_Type      IS OKS_ENTITLEMENTS_PUB.Clvl_Tbl_Type;
  SUBTYPE PrfEng_Tbl_Type    IS OKS_ENTITLEMENTS_PUB.PrfEng_Tbl_Type;
  SUBTYPE Ent_Contact_Tbl    IS OKS_ENTITLEMENTS_PUB.Ent_Contact_Tbl;

-----------------------------------------------------------------------------------------------------------------------*

  SUBTYPE Inp_Cont_Rec       IS OKS_ENTITLEMENTS_PUB.Inp_Cont_Rec;
  SUBTYPE Get_ContIn_Rec     IS OKS_ENTITLEMENTS_PUB.Get_ContIn_Rec;
  SUBTYPE Input_Rec_IB       IS OKS_ENTITLEMENTS_PUB.Input_Rec_IB;

  SUBTYPE Ent_Cont_Rec       IS OKS_ENTITLEMENTS_PUB.Ent_Cont_Rec;
  SUBTYPE Ent_Cont_Tbl       IS OKS_ENTITLEMENTS_PUB.Ent_Cont_Tbl;

  SUBTYPE Get_ConTop_Rec     IS OKS_ENTITLEMENTS_PUB.Get_ConTop_Rec;
  SUBTYPE Get_ConTop_Tbl     IS OKS_ENTITLEMENTS_PUB.Get_ConTop_Tbl;

  SUBTYPE Output_Rec_IB      IS OKS_ENTITLEMENTS_PUB.Output_Rec_IB;
  SUBTYPE Output_Tbl_IB      IS OKS_ENTITLEMENTS_PUB.Output_Tbl_IB;

  SUBTYPE grt_inp_rec_type   IS OKS_ENTITLEMENTS_PUB.grt_inp_rec_type;
  SUBTYPE rcn_rsn_rec_type   IS OKS_ENTITLEMENTS_PUB.rcn_rsn_rec_type;

  SUBTYPE input_rec_entfrm   IS OKS_ENTITLEMENTS_PUB.input_rec_entfrm;
  SUBTYPE output_rec_entfrm  IS OKS_ENTITLEMENTS_PUB.output_rec_entfrm;
  SUBTYPE output_tbl_entfrm  IS OKS_ENTITLEMENTS_PUB.output_tbl_entfrm;

  SUBTYPE CovType_Rec_Type   IS OKS_ENTITLEMENTS_PUB.CovType_Rec_Type;
  SUBTYPE Default_Contline_System_Rec IS OKS_ENTITLEMENTS_PUB.Default_Contline_System_Rec;
  SUBTYPE Get_pmcontin_rec   IS OKS_PM_ENTITLEMENTS_PUB.Get_pmcontin_rec;
  SUBTYPE pm_sch_tbl_type    IS OKS_PM_ENTITLEMENTS_PUB.pm_sch_tbl_type;
  SUBTYPE inp_sch_rec        IS OKS_PM_ENTITLEMENTS_PUB.inp_sch_rec;


-----------------------------------------------------------------------------------------------------------------------*

--  TYPE GT_Bp_CoverTimes IS TABLE OF GR_Bp_CoverTime INDEX BY BINARY_INTEGER;
--  TYPE GT_Bp_Reactions  IS TABLE OF GR_Bp_Reaction INDEX BY BINARY_INTEGER;

--  TYPE GT_Contract_Ref IS TABLE OF GR_Contract_Ref INDEX BY BINARY_INTEGER;
--  TYPE GT_ContItem_Ref IS TABLE OF GR_ContItem_Ref INDEX BY BINARY_INTEGER;

-----------------------------------------------------------------------------------------------------------------------*

  G_RET_STS_SUCCESS        CONSTANT Gx_Ret_Sts    := OKC_API.G_RET_STS_SUCCESS;
  G_RET_STS_ERROR	       CONSTANT Gx_Ret_Sts    := OKC_API.G_RET_STS_ERROR;
  G_RET_STS_UNEXP_ERROR    CONSTANT Gx_Ret_Sts    := OKC_API.G_RET_STS_UNEXP_ERROR;

  G_TRUE                   CONSTANT Gx_Boolean    := OKC_API.G_TRUE;
  G_FALSE                  CONSTANT Gx_Boolean    := OKC_API.G_FALSE;

--  G_MISS_NUM               CONSTANT NUMBER        := OKC_API.G_MISS_NUM;
--  G_MISS_CHAR              CONSTANT VARCHAR2(1)   := OKC_API.G_MISS_CHAR;
--  G_MISS_DATE              CONSTANT DATE          := OKC_API.G_MISS_DATE;

  G_REQUIRED_VALUE         CONSTANT VARCHAR2(200) := OKC_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE          CONSTANT VARCHAR2(200) := OKC_API.G_INVALID_VALUE;

  G_COL_NAME_TOKEN         CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN     CONSTANT VARCHAR2(200) := OKC_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN      CONSTANT VARCHAR2(200) := OKC_API.G_CHILD_TABLE_TOKEN;
  G_NO_PARENT_RECORD       CONSTANT VARCHAR2(200) := 'OKS_NO_PARENT_RECORD';

  G_UNEXPECTED_ERROR       CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN          CONSTANT VARCHAR2(200) := 'ERROR_MESSAGE';  --'SQLerrm';
  G_SQLCODE_TOKEN          CONSTANT VARCHAR2(200) := 'ERROR_CODE';     --'SQLcode';

  G_DEBUG_TOKEN            CONSTANT VARCHAR2(200) := 'OKS_PM_ENT_DEBUG';
  G_PACKAGE_TOKEN          CONSTANT VARCHAR2(200) := 'Package';
  G_PROGRAM_TOKEN          CONSTANT VARCHAR2(200) := 'Program';
  G_PKG_NAME	           CONSTANT VARCHAR2(200) := 'OKS_PM_ENTITLEMENTS_PVT';
  G_APP_NAME_OKS	       CONSTANT VARCHAR2(3)   := 'OKS';
  G_APP_NAME_OKC	       CONSTANT VARCHAR2(3)   := 'OKC';

  G_RESOLUTION_TIME        CONSTANT VARCHAR2(10):= 'RSN';

-----------------------------------------------------------------------------------------------------------------------*

    PROCEDURE Get_PMContracts_02_Format --ph2
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
    ,X_Return_Status   	    out nocopy Gx_Ret_Sts);

     PROCEDURE Get_PMContracts_02
    (P_API_Version		IN  NUMBER
    ,P_Init_Msg_List		IN  VARCHAR2
    ,P_Inp_Rec			IN  OKS_ENTITLEMENTS_PVT.Inp_rec_getcont02
    ,X_Return_Status 		out nocopy VARCHAR2
    ,X_Msg_Count		out nocopy NUMBER
    ,X_Msg_Data			out nocopy VARCHAR2
    ,X_Ent_Contracts		out nocopy OKS_ENTITLEMENTS_PUB.Get_ConTop_Tbl
    ,X_PM_Activities        out nocopy OKS_PM_ENTITLEMENTS_PUB.get_activityop_tbl); -- New parameter added to return list of activities for contract_line and PM program

  PROCEDURE Get_PM_Contracts
    (p_api_version          IN  Number
    ,p_init_msg_list        IN  Varchar2
    ,p_inp_rec              IN  Get_pmcontin_rec
    ,x_return_status        out nocopy Varchar2
    ,x_msg_count            out nocopy Number
    ,x_msg_data             out nocopy Varchar2
    ,x_ent_contracts        out nocopy OKS_ENTITLEMENTS_PUB.get_contop_tbl
    ,x_pm_activities        out nocopy OKS_PM_ENTITLEMENTS_PUB.get_activityop_tbl); -- New parameter added to return list of activities for contract_line and PM program


 PROCEDURE Get_PM_Schedule
    (p_api_version          IN  Number
    ,p_init_msg_list        IN  Varchar2
    ,p_sch_rec              IN  inp_sch_rec
    ,x_return_status        out nocopy Varchar2
    ,x_msg_count            out nocopy Number
    ,x_msg_data             out nocopy Varchar2
    ,x_pm_schedule          out nocopy pm_sch_tbl_type);

PROCEDURE Get_PM_Confirmation
    (p_api_version          IN  Number
    ,p_init_msg_list        IN  Varchar2
    ,p_service_line_id      IN  Number -- This is mandatory
    ,p_program_id           IN  Number -- If this is passed and with no p_activity_id, the API will return confirmation_required flag for PM Program
    ,p_Activity_Id          IN  Number -- If this is passed, API will return confirmation_required flag for Activity
    ,x_return_status        out nocopy Varchar2
    ,x_msg_count            out nocopy Number
    ,x_msg_data             out nocopy Varchar2
    ,x_pm_conf_reqd         out nocopy Varchar2);

--chkrishn 02/26/2004 Added parameter p_pm_activity_id
PROCEDURE Check_PM_Exists
    (p_api_version          IN  Number
    ,p_init_msg_list        IN  Varchar2
    ,p_pm_program_id        IN  Number default null
    ,p_pm_activity_id       IN  Number default null
    ,x_return_status        out nocopy Varchar2
    ,x_msg_count            out nocopy Number
    ,x_msg_data             out nocopy Varchar2
    ,x_pm_reference_exists  out nocopy Varchar2);

END OKS_PM_ENTITLEMENTS_PVT;


 

/
