--------------------------------------------------------
--  DDL for Package OKS_ENTITLEMENTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_ENTITLEMENTS_PVT" AUTHID CURRENT_USER AS
/* $Header: OKSRENTS.pls 120.7.12010000.3 2010/05/04 10:51:58 vgujarat ship $ */

  SUBTYPE Gx_Boolean         IS VARCHAR2(1);
  SUBTYPE Gx_YesNo           IS VARCHAR2(1);
  SUBTYPE Gx_Ret_Sts         IS VARCHAR2(1);
  SUBTYPE Gx_ExceptionMsg    IS VARCHAR2(200);
  SUBTYPE Gx_TimeZoneId      IS NUMBER; --OKX_TIMEZONES_V.TIMEZONE_ID%TYPE;
  SUBTYPE Gx_ReactDurn       IS NUMBER(15,2);--OKC_REACT_INTERVALS.DURATION%TYPE;
  SUBTYPE Gx_ReactUOM        IS VARCHAR2(3); --OKC_REACT_INTERVALS.UOM_CODE%TYPE;
  SUBTYPE Gx_OKS_Id          IS NUMBER;
  SUBTYPE Gx_BusProcess_Id   IS NUMBER; --OKX_BUS_PROCESSES_V.ID1%TYPE;
  SUBTYPE Gx_Severity_Id     IS NUMBER; --OKX_INCIDENT_SEVERITS_V.ID1%TYPE;
  SUBTYPE Gx_JTOT_ObjCode    IS VARCHAR2(30); --JTF_OBJECTS_B.OBJECT_CODE%TYPE;
  SUBTYPE Gx_Rule_Id         IS NUMBER; --OKC_RULES_B.ID%TYPE;
  SUBTYPE Gx_Rule_Category   IS VARCHAR2(90); --OKC_RULES_B.RULE_INFORMATION_CATEGORY%TYPE;
  SUBTYPE Gx_TimeValue_Type  IS VARCHAR2(10); --OKC_TIMEVALUES_B.TVE_TYPE%TYPE;

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

-----------------------------------------------------------------------------------------------------------------------

  SUBTYPE INP_REC_BP         IS OKS_ENTITLEMENTS_PUB.INP_REC_BP;
  SUBTYPE OUTPUT_TBL_BP      IS OKS_ENTITLEMENTS_PUB.OUTPUT_TBL_BP;
  SUBTYPE OUTPUT_TBL_BT      IS OKS_ENTITLEMENTS_PUB.OUTPUT_TBL_BT;
  SUBTYPE OUTPUT_TBL_BR      IS OKS_ENTITLEMENTS_PUB.OUTPUT_TBL_BR;


-----------------------------------------------------------------------------------------------------------------------*
  SUBTYPE inp_cont_rec_type        IS OKS_ENTITLEMENTS_PUB.inp_cont_rec_type;
  SUBTYPE output_tbl_contract      IS OKS_ENTITLEMENTS_PUB.output_tbl_contract;
  SUBTYPE covlvl_id_tbl            IS OKS_ENTITLEMENTS_PUB.covlvl_id_tbl;
  SUBTYPE covlevel_tbl_type        IS OKS_ENTITLEMENTS_PUB.covlevel_tbl_type;

  SUBTYPE srchline_inpcontrec_type IS OKS_ENTITLEMENTS_PUB.srchline_inpcontrec_type;

  SUBTYPE srchline_inpcontlinerec_type  IS OKS_ENTITLEMENTS_PUB.srchline_inpcontlinerec_type;
  SUBTYPE srchline_covlvl_id_tbl    IS OKS_ENTITLEMENTS_PUB.srchline_covlvl_id_tbl;
  SUBTYPE output_tbl_contractline   IS OKS_ENTITLEMENTS_PUB.output_tbl_contractline;

  SUBTYPE srchline_inpcontlinerec_TBL IS OKS_ENTITLEMENTS_PUB.srchline_inpcontlinerec_TBL;

  /*vgujarat - modified for access hour ER 9675504*/
  TYPE Inp_rec_getcont02 IS RECORD
    (Contract_Number           OKC_K_HEADERS_B.CONTRACT_NUMBER%TYPE
    ,Contract_Number_Modifier  OKC_K_HEADERS_B.CONTRACT_NUMBER%TYPE
    ,Service_Line_Id           NUMBER
    ,Party_Id		       NUMBER
    ,Site_Id		       NUMBER
    ,Cust_Acct_Id	             NUMBER
    ,System_Id		       NUMBER
    ,Item_Id		       NUMBER
    ,Product_Id		       NUMBER
    ,Incident_Date             DATE            -- Added for 12.0 ENT-TZ project (JVARGHES)
    ,Request_Date              DATE
    ,Request_Date_Start        DATE
    ,Request_Date_End          DATE
    ,Business_Process_Id       NUMBER
    ,Severity_Id               NUMBER
    ,Time_Zone_Id              NUMBER
    ,Dates_In_Input_TZ         VARCHAR2(1)     -- Added for 12.0 ENT-TZ project (JVARGHES)
    ,Calc_RespTime_Flag        VARCHAR2(1)
    ,Validate_Flag             VARCHAR2(1)
    ,Validate_Eff_Flag         VARCHAR2(1)
    ,Sort_Key                  VARCHAR2(10)
    ,cust_id                   NUMBER  DEFAULT NULL   --access hour
    ,cust_site_id              NUMBER  DEFAULT null   --access hour
    ,cust_loc_id               NUMBER  DEFAULT null); --access hour

  TYPE GR_Bp_CoverTime IS RECORD
    (Rv_Cover_Day         VARCHAR2(25)
    ,Rv_Cover_From        VARCHAR2(25)
    ,Rv_Cover_To          VARCHAR2(25)
    ,Rx_Cover_TZoneId     Gx_TimeZoneId
    ,Ri_Cover_Day         INTEGER(1)
    ,Ri_ReqDay_Relative   INTEGER(1)
    );

  TYPE GR_Bp_Reaction IS RECORD
    (Rv_React_Day         VARCHAR2(25)
    ,Rx_React_Durn        Gx_ReactDurn
    ,Rx_React_UOM         Gx_ReactUOM
    ,Ri_React_Day         INTEGER(1)
    ,Ri_ReqDay_Relative   INTEGER(1)
    );

  TYPE GR_Contract_Ref IS RECORD
    (Rx_Chr_Id            Gx_OKS_Id
    ,Rx_Cle_Id            Gx_OKS_Id
    ,Rx_Pty_Id            Gx_OKS_Id
    );

  TYPE GR_ContItem_Ref IS RECORD
    (Rx_Obj1Id1      Gx_Itm_Obj1Id1
    ,Rx_Obj1Id2      Gx_Itm_Obj1Id2
    ,Rx_ObjCode      Gx_JTOT_ObjCode
    );

  TYPE Idx_Rec IS RECORD
    (Contract_Id                    NUMBER
	,Contract_Number                OKC_K_HEADERS_B.CONTRACT_NUMBER%TYPE
    ,Contract_Number_Modifier       OKC_K_HEADERS_B.CONTRACT_NUMBER_MODIFIER%TYPE
    ,Sts_Code                       OKC_K_LINES_B.STS_CODE%TYPE
    ,Authoring_Org_Id               NUMBER
    ,Inv_Organization_Id            NUMBER
    ,HDR_End_Date                   DATE--grace period changes
	,Service_Line_Id                NUMBER
    ,SV_Start_Date                  DATE
	,SV_End_Date                    DATE
    ,SV_Date_Terminated             DATE
    ,CL_Sts_Code                    OKC_K_LINES_B.STS_CODE%TYPE
	,CovLvl_Line_Id                 NUMBER
    ,CL_Start_Date                  DATE
	,CL_End_Date                    DATE
    ,CL_Date_Terminated             DATE
    ,Warranty_Flag                  VARCHAR2(1)
    ,PM_Program_Id                  VARCHAR2(40)
    ,PM_Schedule_Exists             VARCHAR2(450)
    ,Scs_Code                       OKC_K_HEADERS_B.SCS_CODE%TYPE
    ,Estimated_Amount               OKC_K_HEADERS_B.Estimated_Amount%TYPE
    ,HD_Start_Date                  DATE
	,HD_End_Date                    DATE
    ,Cognomen                       OKC_K_HEADERS_TL.Cognomen%TYPE
    ,short_description              OKC_K_HEADERS_TL.short_description%TYPE
    ,HD_Currency_code               VARCHAR2(15));

   TYPE Day_Cover_Rec IS RECORD
    (Day_Cover_From                 VARCHAR2(30)
    ,Day_Cover_To                   VARCHAR2(30));

   TYPE Day_Cover_Tbl IS TABLE OF Day_Cover_Rec INDEX BY BINARY_INTEGER;

   TYPE G_STATUS_REC IS RECORD
    (CODE                           OKC_STATUSES_V.CODE%TYPE
	,MEANING                        OKC_STATUSES_V.MEANING%TYPE);

   TYPE G_STATUS_TBL IS TABLE OF G_STATUS_REC INDEX BY BINARY_INTEGER;

   l_status_tab                     G_STATUS_TBL;

   TYPE line_id_rec IS RECORD
    (line_id                NUMBER);

   TYPE line_id_tbl IS TABLE OF line_id_rec INDEX BY BINARY_INTEGER;

   TYPE Rle_Lkup_REC IS RECORD
    (CODE                           FND_LOOKUPS.LOOKUP_CODE%TYPE
	,MEANING                        FND_LOOKUPS.MEANING%TYPE);

   TYPE Rle_Lkup_TBL IS TABLE OF Rle_Lkup_REC INDEX BY BINARY_INTEGER;

-----------------------------------------------------------------------------------------------------------------------*

  TYPE GT_Bp_CoverTimes IS TABLE OF GR_Bp_CoverTime INDEX BY BINARY_INTEGER;
  TYPE GT_Bp_Reactions  IS TABLE OF GR_Bp_Reaction INDEX BY BINARY_INTEGER;

  TYPE GT_Contract_Ref IS TABLE OF GR_Contract_Ref INDEX BY BINARY_INTEGER;
  TYPE GT_ContItem_Ref IS TABLE OF GR_ContItem_Ref INDEX BY BINARY_INTEGER;

  TYPE GR_PARENT_Ref IS RECORD
    (RX_Object_ID Gx_Itm_Obj1Id1
    ,RX_Subject_ID Gx_Itm_Obj1Id1);

  TYPE GT_PARENT_Ref   IS TABLE OF GR_PARENT_Ref INDEX BY BINARY_INTEGER;

  TYPE GR_INSTANCES IS RECORD
    (RX_Inst_ID    Gx_Itm_Obj1Id1);

  TYPE GT_INSTANCES   IS TABLE OF GR_INSTANCES INDEX BY BINARY_INTEGER;

  TYPE ii_relationship_rec IS RECORD
   (
       RELATIONSHIP_ID                 NUMBER,
       RELATIONSHIP_TYPE_CODE          VARCHAR2(30),
       OBJECT_ID                       NUMBER,
       SUBJECT_ID                      NUMBER,
       SUBJECT_HAS_CHILD               VARCHAR2(1),
       POSITION_REFERENCE              VARCHAR2(30),
       ACTIVE_START_DATE               DATE,
       ACTIVE_END_DATE                 DATE,
       DISPLAY_ORDER                   NUMBER,
       MANDATORY_FLAG                  VARCHAR2(1),
       PARENT_TBL_INDEX                NUMBER,
       PROCESSED_FLAG                  VARCHAR2(1),
       INTERFACE_ID                    NUMBER
   );

  TYPE  ii_relationship_tbl      IS TABLE OF ii_relationship_rec INDEX BY BINARY_INTEGER;

-----------------------------------------------------------------------------------------------------------------------*

  G_RET_STS_SUCCESS        CONSTANT Gx_Ret_Sts    := OKC_API.G_RET_STS_SUCCESS;
  G_RET_STS_ERROR	   CONSTANT Gx_Ret_Sts    := OKC_API.G_RET_STS_ERROR;
  G_RET_STS_UNEXP_ERROR    CONSTANT Gx_Ret_Sts    := OKC_API.G_RET_STS_UNEXP_ERROR;

  G_TRUE                   CONSTANT Gx_Boolean    := OKC_API.G_TRUE;
  G_FALSE                  CONSTANT Gx_Boolean    := OKC_API.G_FALSE;


  G_REQUIRED_VALUE         CONSTANT VARCHAR2(200) := OKC_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE          CONSTANT VARCHAR2(200) := OKC_API.G_INVALID_VALUE;

  G_COL_NAME_TOKEN         CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN     CONSTANT VARCHAR2(200) := OKC_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN      CONSTANT VARCHAR2(200) := OKC_API.G_CHILD_TABLE_TOKEN;
  G_NO_PARENT_RECORD       CONSTANT VARCHAR2(200) := 'OKS_NO_PARENT_RECORD';

  G_UNEXPECTED_ERROR       CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN          CONSTANT VARCHAR2(200) := 'ERROR_MESSAGE';  --'SQLerrm';
  G_SQLCODE_TOKEN          CONSTANT VARCHAR2(200) := 'ERROR_CODE';     --'SQLcode';

  G_DEBUG_TOKEN            CONSTANT VARCHAR2(200) := 'OKS_ENT_DEBUG';
  G_PACKAGE_TOKEN          CONSTANT VARCHAR2(200) := 'Package';
  G_PROGRAM_TOKEN          CONSTANT VARCHAR2(200) := 'Program';
  G_PKG_NAME	           CONSTANT VARCHAR2(200) := 'OKS_ENTITLEMENTS_PUB';
  G_APP_NAME_OKS	   CONSTANT VARCHAR2(3)   := 'OKS';
  G_APP_NAME_OKC	   CONSTANT VARCHAR2(3)   := 'OKC';

  G_LINE_STYLE_SERVICE         CONSTANT Gx_OKS_Id  := 1;
  G_LINE_STYLE_SRV_COVERAGE    CONSTANT Gx_OKS_Id  := 2;
  G_LINE_STYLE_WARRANTY        CONSTANT Gx_OKS_Id  := 14;
  G_LINE_STYLE_WAR_COVERAGE    CONSTANT Gx_OKS_Id  := 15;
  G_LINE_STYLE_EXT_WARRANTY    CONSTANT Gx_OKS_Id  := 19;
  G_LINE_STYLE_EWT_COVERAGE    CONSTANT Gx_OKS_Id  := 20;
  G_LINE_STYLE_USAGE           CONSTANT Gx_OKS_Id  := 12;

  G_JTOT_OBJ_BUSIPROC          CONSTANT Gx_JTOT_ObjCode := 'OKX_BUSIPROC';
  G_JTOT_OBJ_REACTIME          CONSTANT Gx_JTOT_ObjCode := 'OKX_REACTIME';
  G_JTOT_OBJ_PARTY             CONSTANT Gx_JTOT_ObjCode := 'OKX_PARTY';

  G_RUL_CATEGORY_REACTION      CONSTANT Gx_Rule_Category := 'RCN';
  G_RUL_CATEGORY_RESOLUTION    CONSTANT Gx_Rule_Category := 'RSN';
  G_RUL_CATEGORY_REACT_RESOLVE CONSTANT Gx_Rule_Category := 'RCN_RSN';

-- addition due to grace period changes starts
  G_RUL_CATEGORY_GRACE         CONSTANT Gx_Rule_Category := 'GPR';
  G_GRACE_PROFILE_SET                   VARCHAR2(1);
  G_CONTRACT_END_DATE                   DATE;
  G_CONTRACT_ID                         Gx_OKS_Id;
-- addition due to grace period changes ends

  G_TIMEVALUE_TYPE_IGS         CONSTANT Gx_TimeValue_Type := 'IGS';
  G_TIMEVALUE_TYPE_TGD         CONSTANT Gx_TimeValue_Type := 'TGD';

  G_BEST                       CONSTANT VARCHAR2(10):= 'BEST';
  G_FIRST                      CONSTANT VARCHAR2(10):= 'FIRST';
  G_YES                        CONSTANT Gx_YesNo := 'Y';
  G_NO                         CONSTANT Gx_YesNo := 'N';

  G_RESOLUTION_TIME            CONSTANT VARCHAR2(10):= 'RSN';
  G_REACTION_TIME              CONSTANT VARCHAR2(10):= 'RCN';
  G_COVERAGE_TYPE_IMP_LEVEL    CONSTANT VARCHAR2(10):= 'COVTYP_IMP';
  G_NO_SORT_KEY                CONSTANT VARCHAR2(10):= 'NO_KEY';
-- addition for PROCEDURE Default_Contract_line_CSI starts
  G_CALLED_FROM_DEF_CONLINECSI          VARCHAR2(1);
-- addition for PROCEDURE Default_Contract_line_CSI ends

  G_Service_Line_Data                   VARCHAR2(1);
  G_Header_Data                         VARCHAR2(1);

-----------------------------------------------------------------------------------------------------------------------*

  PROCEDURE Validate_Required_NumValue
    (P_Num_Value              IN  NUMBER
    ,P_Set_ExcepionStack      IN  Gx_Boolean
    ,P_ExcepionMsg            IN  Gx_ExceptionMsg
    ,X_Result                 out nocopy Gx_Boolean
    ,X_Return_Status   	      out nocopy Gx_Ret_Sts);

  PROCEDURE Validate_Required_DateValue
    (P_Date_Value             IN  DATE
    ,P_Set_ExcepionStack      IN  Gx_Boolean
    ,P_ExcepionMsg            IN  Gx_ExceptionMsg
    ,X_Result                 out nocopy Gx_Boolean
    ,X_Return_Status   	      out nocopy Gx_Ret_Sts);

  PROCEDURE Validate_Required_CharValue
    (P_Char_Value             IN  VARCHAR2
    ,P_Set_ExcepionStack      IN  Gx_Boolean
    ,P_ExcepionMsg            IN  Gx_ExceptionMsg
    ,X_Result                 out nocopy Gx_Boolean
    ,X_Return_Status   	      out nocopy Gx_Ret_Sts);

  PROCEDURE Validate_Required_RT_Tokens
    (P_SVL_Id	                IN  Gx_OKS_Id
    ,P_BusiProc_Id	        IN  Gx_BusProcess_Id
    ,P_Severity_Id		IN  Gx_Severity_Id
    ,P_Request_Date		IN  DATE
    ,P_Request_TZone_id		IN  Gx_TimeZoneId
    ,P_template_YN          in varchar2 -- for default coverage functionality
    ,P_Set_ExcepionStack        IN  Gx_Boolean
    ,X_Result                   out nocopy Gx_Boolean
    ,X_Return_Status 	        out nocopy Gx_Ret_Sts);


  PROCEDURE Validate_Service_Line
    (P_SVL_Id	              IN  Gx_OKS_Id
    ,P_Set_ExcepionStack        IN  Gx_Boolean
    ,X_CVL_Id	              OUT	nocopy NUMBER     -- Added for 12.0 Coverage Rearch project (JVARGHES)
    ,X_Std_Cov_YN	              OUT	nocopy VARCHAR2   -- Added for 12.0 Coverage Rearch project (JVARGHES)
    ,X_SVL_Start                out nocopy DATE
    ,X_SVL_End                  out nocopy DATE
    ,X_SVL_Terminated           out nocopy DATE
    ,X_Result                   out nocopy Gx_Boolean
    ,X_Return_Status 	        out nocopy Gx_Ret_Sts);

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
    ,X_Return_Status 	    out nocopy Gx_Ret_Sts);

--
-- Added for 12.0 Coverage Rearch project (JVARGHES)
--

  PROCEDURE Get_BP_Line_Start_Offset
    (P_BPL_Id	              IN  Gx_OKS_Id
    ,P_SVL_Start	              IN	DATE
    ,X_BPL_OFS_Start	        OUT	NOCOPY DATE
    ,X_BPL_OFS_Duration	        OUT	NOCOPY NUMBER
    ,X_BPL_OFS_UOM	        OUT	NOCOPY VARCHAR2
    ,X_Return_Status 	        out nocopy Gx_Ret_Sts);

  PROCEDURE Validate_BusinessProcess_Line
    (P_BPL_Id	                IN  Gx_OKS_Id
    ,P_Set_ExcepionStack        IN  Gx_Boolean
    ,X_BPL_Start                out nocopy DATE
    ,X_BPL_End                  out nocopy DATE
    ,X_BPL_Terminated           out nocopy DATE
    ,X_Result                   out nocopy Gx_Boolean
    ,X_Return_Status 	        out nocopy Gx_Ret_Sts);

  PROCEDURE Validate_Contract_BP
    (P_CVL_Id	            IN  Gx_OKS_Id -- P_SVL_Id	IN  Gx_OKS_Id
    ,P_BP_Id	            IN  Gx_BusProcess_Id
    ,P_BP_ObjCode           IN  Gx_JTOT_ObjCode
    ,P_Set_ExcepionStack    IN  Gx_Boolean
    ,X_BPL_Id               OUT nocopy Gx_OKS_Id
    ,X_BPL_Start            OUT nocopy DATE
    ,X_BPL_End              OUT nocopy DATE
    ,X_BPL_Terminated       OUT nocopy DATE
    ,X_Result               OUT nocopy Gx_Boolean
    ,X_Return_Status 	    OUT nocopy Gx_Ret_Sts);


  PROCEDURE Get_Effective_End_Date
    (P_Start_Date            IN  DATE
    ,P_End_Date              IN  DATE
    ,P_Termination_Date      IN  DATE
    ,P_EndDate_Required      IN  Gx_Boolean
    ,P_Set_ExcepionStack     IN  Gx_Boolean
    ,P_ExcepionMsg           IN  Gx_ExceptionMsg
    ,X_EffEnd_Date           out nocopy DATE
    ,X_Result                out nocopy Gx_Boolean
    ,X_Return_Status  	     out nocopy Gx_Ret_Sts);

  PROCEDURE Convert_TimeZone
    (P_API_Version	IN  NUMBER
    ,P_Init_Msg_List    IN  VARCHAR2
    ,p_Source_Date      IN  DATE
    ,P_Source_Tz_Id     IN  Gx_TimeZoneId
    ,P_Dest_Tz_Id       IN  Gx_TimeZoneId
    ,X_Dest_Date        out nocopy DATE
    ,X_Msg_Count        out nocopy NUMBER
    ,X_Msg_Data		OUT nocopy VARCHAR2
    ,X_Return_Status 	OUT nocopy Gx_Ret_Sts);

  PROCEDURE Validate_Effectivity
    (P_Request_Date	    IN  DATE
    ,P_Start_DateTime       IN  DATE
    ,P_End_DateTime         IN  DATE
    ,P_Set_ExcepionStack    IN  Gx_Boolean
    ,P_CL_Msg_TokenValue    IN  Gx_ExceptionMsg
    ,X_Result               out nocopy Gx_Boolean
    ,X_Return_Status 	    out nocopy Gx_Ret_Sts);

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
    ,X_Return_Status 	     out nocopy Gx_Ret_Sts);

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
    ,X_Return_Status      out nocopy Gx_Ret_Sts);

-- commented and replaced because of 11.5.10 rearchitecture changes

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
    ,P_cust_loc_id              IN NUMBER DEFAULT NULL);

-- commented and replaced because of 11.5.10 rearchitecture changes

  PROCEDURE Get_BP_Reaction_Times
    (P_RTL_Line_Id        IN  Gx_OKS_Id
    ,P_Request_Date       IN  DATE
    ,P_TimeType_Category  IN  Varchar2 --Gx_TimeType_Category
    ,P_ReactDay_DispFmt   IN  VARCHAR2
    ,P_Set_ExcepionStack  IN  Gx_Boolean
    ,X_Reaction_Attribs   out nocopy GT_Bp_Reactions
    ,X_Result             out nocopy Gx_Boolean
    ,X_Return_Status      out nocopy Gx_Ret_Sts);

  PROCEDURE Get_Reactn_Durn_In_Days
    (P_React_Durn	    IN  Gx_ReactDurn
    ,P_React_UOM 	    IN  Gx_ReactUOM
    ,P_Set_ExcepionStack    IN  Gx_Boolean
    ,X_React_Durn_In_Days   out nocopy NUMBER
    ,X_Result               out nocopy Gx_Boolean
    ,X_Return_Status        out nocopy Gx_Ret_Sts);

  PROCEDURE Get_Cover_Day_Attribs
    (P_BP_CovTimes          IN  GT_Bp_CoverTimes
    ,P_Req_Cover_Date       IN  DATE
    ,P_Set_ExcepionStack    IN  Gx_Boolean
    ,P_Check_Day            IN  Varchar2
    ,X_Day_Cover_tbl        out nocopy Day_Cover_Tbl
    ,X_Result               out nocopy Gx_Boolean
    ,X_Return_Status        out nocopy Gx_Ret_Sts);

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
    ,X_Return_Status        out nocopy Gx_Ret_Sts);

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
    ,X_React_Durn	    out nocopy Gx_ReactDurn
    ,X_React_UOM 	    out nocopy Gx_ReactUOM
    ,X_React_Day            out nocopy VARCHAR2
    ,X_React_By_DateTime    out nocopy DATE
    ,X_React_Start_DateTime out nocopy DATE
    ,X_Result               out nocopy Gx_Boolean
    ,X_Return_Status        out nocopy Gx_Ret_Sts);

    /*vgujarat - modified for access hour ER 9675504*/
  PROCEDURE Get_ReactResol_By_DateTime
    (P_API_Version		IN  NUMBER
    ,P_Init_Msg_List		IN  VARCHAR2
    ,P_SVL_Id	            IN  Gx_OKS_Id -- can be service line id or coverage line id depending on P_Template_YN is 'N' or, 'Y'
    ,P_BusiProc_Id	        IN  Gx_BusProcess_Id
    ,P_Severity_Id		IN  Gx_Severity_Id
    ,P_Request_Date		IN  DATE
    ,P_Request_TZone_id		IN  Gx_TimeZoneId
    ,P_Dates_In_Input_TZ      IN VARCHAR2    -- Added for 12.0 ENT-TZ project (JVARGHES)
    ,P_template_YN              IN  VARCHAR2  -- for default coverage enhancement
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
    ,P_cust_loc_id              IN NUMBER DEFAULT NULL);

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
    ,P_cust_loc_id              IN NUMBER DEFAULT NULL);

  PROCEDURE get_react_resolve_by_time
    (p_api_version		in  number
    ,p_init_msg_list		in  varchar2
    ,p_inp_rec                  in  grt_inp_rec_type
    ,x_return_status 		out nocopy varchar2
    ,x_msg_count		out nocopy number
    ,x_msg_data			out nocopy varchar2
    ,x_react_rec                out nocopy rcn_rsn_rec_type
    ,x_resolve_rec              out nocopy rcn_rsn_rec_type);

  PROCEDURE Validate_Required_CT_Tokens
    (P_SVL_Id	                IN  Gx_OKS_Id
    ,P_BusiProc_Id	        IN  Gx_BusProcess_Id
    ,P_Request_Date		IN  DATE
    ,P_Request_TZone_id		IN  Gx_TimeZoneId
    ,P_Set_ExcepionStack        IN  Gx_Boolean
    ,X_Result                   out nocopy Gx_Boolean
    ,X_Return_Status 	        out nocopy Gx_Ret_Sts);

  PROCEDURE Get_Coverage_Times
    (P_API_Version		IN  NUMBER
    ,P_Init_Msg_List		IN  VARCHAR2
    ,P_SVL_Id	              IN  Gx_OKS_Id
    ,P_BusiProc_Id	        IN  Gx_BusProcess_Id
    ,P_Request_Date		  IN  DATE
    ,P_Request_TZone_id		  IN  Gx_TimeZoneId
    ,P_Dates_In_Input_TZ        IN VARCHAR2    -- Added for 12.0 ENT-TZ project (JVARGHES)
    ,P_Set_ExcepionStack        IN  Gx_Boolean
    ,X_Day_Cover_From           out nocopy DATE
    ,X_Day_Cover_To             out nocopy DATE
    ,X_Covered                  out nocopy Gx_Boolean
    ,X_Msg_Count		OUT NOCOPY NUMBER
    ,X_Msg_Data			OUT NOCOPY VARCHAR2
    ,X_Result                   out nocopy Gx_Boolean
    ,X_Return_Status            out nocopy Gx_Ret_Sts);

  PROCEDURE Check_Coverage_Times
    (P_API_Version		IN  NUMBER
    ,P_Init_Msg_List		IN  VARCHAR2
    ,P_Business_Process_Id	IN  NUMBER
    ,P_Request_Date		IN  DATE
    ,P_Time_Zone_Id		IN  NUMBER
    ,P_Dates_In_Input_TZ      IN VARCHAR2    -- Added for 12.0 ENT-TZ project (JVARGHES)
    ,P_Contract_Line_Id	      IN  NUMBER
    ,X_Return_Status 		OUT NOCOPY VARCHAR2
    ,X_Msg_Count		OUT NOCOPY NUMBER
    ,X_Msg_Data			OUT NOCOPY VARCHAR2
    ,X_Covered_YN		OUT NOCOPY VARCHAR2);

  PROCEDURE Get_Contract_Header_Details
    (P_API_Version		IN  NUMBER
    ,P_Init_Msg_List		IN  VARCHAR2
    ,P_Chr_Id                   IN  Gx_OKS_Id
    ,P_Chr_Sts_Code             IN  Gx_Chr_StsCode
    ,P_Chr_Type                 IN  Gx_Chr_Type
    ,P_Chr_EndDate              IN  DATE
    ,P_Chr_PartyId              IN  Gx_Chr_PartyId
    ,X_Contract_Headers 	OUT NOCOPY Hdr_Tbl_Type
    ,X_Msg_Count		OUT NOCOPY NUMBER
    ,X_Msg_Data			OUT NOCOPY VARCHAR2
    ,X_Result                   out nocopy Gx_Boolean
    ,X_Return_Status            out nocopy Gx_Ret_Sts);

  PROCEDURE Get_All_Contracts
    (P_API_Version	       IN  NUMBER
    ,P_Init_Msg_List	       IN  VARCHAR2
    ,P_Inp_Rec		       IN  Inp_Rec_Type
    ,X_Return_Status           out nocopy VARCHAR2
    ,X_Msg_Count	       out nocopy NUMBER
    ,X_Msg_Data		       out nocopy VARCHAR2
    ,X_All_Contracts	       out nocopy Hdr_Tbl_Type);

  PROCEDURE Get_Contract_Line_Details
    (P_API_Version		IN  NUMBER
    ,P_Init_Msg_List		IN  VARCHAR2
    ,P_Cle_Id	                IN  Gx_OKS_Id
    ,X_Contract_Lines		OUT NOCOPY Line_Tbl_Type
    ,X_Msg_Count		OUT NOCOPY NUMBER
    ,X_Msg_Data			OUT NOCOPY VARCHAR2
    ,X_Result                   out nocopy Gx_Boolean
    ,X_Return_Status            out nocopy Gx_Ret_Sts);

  PROCEDURE Get_Contract_Details
    (P_API_Version		IN  NUMBER
    ,P_Init_Msg_List		IN  VARCHAR2
    ,P_Contract_Line_Id	        IN  NUMBER
    ,X_Return_Status 		OUT NOCOPY VARCHAR2
    ,X_Msg_Count		OUT NOCOPY NUMBER
    ,X_Msg_Data			OUT NOCOPY VARCHAR2
    ,X_All_Lines		OUT NOCOPY Line_Tbl_Type);

  PROCEDURE Get_Coverage_Level_Details
    (P_API_Version		IN  NUMBER
    ,P_Init_Msg_List		IN  VARCHAR2
    ,P_Cle_Id	                IN  Gx_OKS_Id
    ,X_Covered_Levels 	        out nocopy Clvl_Tbl_Type
    ,X_Msg_Count		OUT NOCOPY NUMBER
    ,X_Msg_Data			OUT NOCOPY VARCHAR2
    ,X_Result                   out nocopy Gx_Boolean
    ,X_Return_Status            out nocopy Gx_Ret_Sts);

  PROCEDURE Get_Coverage_Levels
    (P_API_Version		IN  NUMBER
    ,P_Init_Msg_List		IN  VARCHAR2
    ,P_Contract_Line_Id	        IN  NUMBER
    ,X_Return_Status 		OUT NOCOPY VARCHAR2
    ,X_Msg_Count		OUT NOCOPY NUMBER
    ,X_Msg_Data			OUT NOCOPY VARCHAR2
    ,X_Covered_Levels		OUT NOCOPY Clvl_Tbl_Type);

  PROCEDURE Get_Coverage_Type_Attribs
    (P_CVL_Id                   IN  Gx_OKS_Id
    ,P_Set_ExcepionStack        IN  Gx_Boolean
    ,X_Cov_Type_Code            out nocopy VARCHAR2
    ,X_Cov_Type_Meaning         out nocopy VARCHAR2
    ,X_Cov_Type_Description     out nocopy VARCHAR2
    ,X_Cov_Type_Imp_Level       out nocopy VARCHAR2
    ,X_Result                   out nocopy Gx_Boolean
    ,X_Return_Status            out nocopy Gx_Ret_Sts);

  PROCEDURE Get_Cont_Coverage_Type
    (P_API_Version		IN  NUMBER
    ,P_Init_Msg_List		IN  VARCHAR2
    ,P_SVL_Id                   IN  Gx_OKS_Id
    ,P_Set_ExcepionStack        IN  Gx_Boolean
    ,X_Coverage_Type            out nocopy CovType_Rec_Type
    ,X_Msg_Count		OUT NOCOPY NUMBER
    ,X_Msg_Data			OUT NOCOPY VARCHAR2
    ,X_Result                   out nocopy Gx_Boolean
    ,X_Return_Status            out nocopy Gx_Ret_Sts);

  PROCEDURE Get_Coverage_Type
    (P_API_Version		IN  NUMBER
    ,P_Init_Msg_List		IN  VARCHAR2
    ,P_Contract_Line_Id	        IN  NUMBER
    ,X_Return_Status 		OUT NOCOPY VARCHAR2
    ,X_Msg_Count 	        out nocopy NUMBER
    ,X_Msg_Data		        out nocopy VARCHAR2
    ,X_Coverage_Type		OUT NOCOPY CovType_Rec_Type);

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
    ,X_Return_Status            out nocopy Gx_Ret_Sts);

  PROCEDURE get_preferred_engineers
	(p_api_version		IN  Number
	,p_init_msg_list		IN  Varchar2
	,p_contract_line_id	       IN  Number
    ,P_business_process_id		IN		NUMBER		-- added for 11.5.9 (patchset I) enhancement # 2467065
	,P_request_date		      IN		DATE	    -- added for 11.5.9 (patchset I) enhancement # 2467065
	,x_return_status 		out nocopy Varchar2
	,x_msg_count		out nocopy Number
	,x_msg_data			out nocopy Varchar2
	,x_prf_engineers		out nocopy prfeng_tbl_type);


  PROCEDURE Get_Contract_Contacts
    (P_API_Version		IN  NUMBER
    ,P_Init_Msg_List		IN  VARCHAR2
    ,P_Chr_Id                   IN  Gx_OKS_Id
    ,P_Cle_Id	                IN  Gx_OKS_Id
    ,X_Cont_Contacts		OUT NOCOPY Ent_Contact_Tbl
    ,X_Msg_Count		OUT NOCOPY NUMBER
    ,X_Msg_Data			OUT NOCOPY VARCHAR2
    ,X_Result                   out nocopy Gx_Boolean
    ,X_Return_Status            out nocopy Gx_Ret_Sts);

  PROCEDURE Get_Contacts
    (P_API_Version		IN  NUMBER
    ,P_Init_Msg_List		IN  VARCHAR2
    ,P_Contract_Id		IN  NUMBER
    ,P_Contract_Line_Id	        IN  NUMBER
    ,X_Return_Status 		OUT NOCOPY VARCHAR2
    ,X_Msg_Count		OUT NOCOPY NUMBER
    ,X_Msg_Data			OUT NOCOPY VARCHAR2
    ,X_Ent_Contacts		OUT NOCOPY Ent_Contact_Tbl);

  PROCEDURE Append_ContItem_PlSql_Table
    (P_Input_Tab          IN  GT_ContItem_Ref
    ,P_Append_Tab         IN  GT_ContItem_Ref
    ,X_Output_Tab         out nocopy GT_ContItem_Ref
    ,X_Result             out nocopy Gx_Boolean
    ,X_Return_Status   	  out nocopy Gx_Ret_Sts);

  PROCEDURE Get_Item_CovLevels
    (P_CovItem_Obj_Id         IN  Gx_OKS_Id
    ,P_Organization_Id        IN  NUMBER
    ,X_Item_CovLevels         out nocopy GT_ContItem_Ref
    ,X_Result                 out nocopy Gx_Boolean
    ,X_Return_Status   	      out nocopy Gx_Ret_Sts);

  PROCEDURE Get_Party_CovLevels
    (P_CovParty_Obj_Id        IN  Gx_OKS_Id
    ,X_Party_CovLevels        out nocopy GT_ContItem_Ref
    ,X_Result                 out nocopy Gx_Boolean
    ,X_Return_Status   	      out nocopy Gx_Ret_Sts);

  PROCEDURE Get_Customer_CovLevels
    (P_CovCust_Obj_Id         IN  Gx_OKS_Id
    ,X_Party_Id               out nocopy Gx_OKS_Id
    ,X_Customer_CovLevels     out nocopy GT_ContItem_Ref
    ,X_Result                 out nocopy Gx_Boolean
    ,X_Return_Status   	      out nocopy Gx_Ret_Sts);

  PROCEDURE Get_Site_CovLevels
    (P_CovSite_Obj_Id         IN  Gx_OKS_Id
    ,P_Org_Id                 IN  NUMBER
    ,X_Site_CovLevels         out nocopy GT_ContItem_Ref
    ,X_Result                 out nocopy Gx_Boolean
    ,X_Return_Status   	      out nocopy Gx_Ret_Sts);

  PROCEDURE Get_System_CovLevels
    (P_CovSys_Obj_Id          IN  Gx_OKS_Id
    ,P_Org_Id                 IN  NUMBER
    ,X_System_CovLevels       out nocopy GT_ContItem_Ref
    ,X_Result                 out nocopy Gx_Boolean
    ,X_Return_Status   	      out nocopy Gx_Ret_Sts);

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
  );

  PROCEDURE Get_Product_CovLevels
    (P_CovProd_Obj_Id         IN  Gx_OKS_Id
    ,P_Organization_Id        IN  NUMBER
    ,P_Org_Id                 IN  NUMBER
    ,X_Party_Id               out nocopy Gx_OKS_Id
    ,X_Product_CovLevels      out nocopy GT_ContItem_Ref
    ,X_Result                 out nocopy Gx_Boolean
    ,X_Return_Status   	      out nocopy Gx_Ret_Sts);

  PROCEDURE Sort_Asc_ContItem_PlSql_Table
    (P_Input_Tab          IN  GT_ContItem_Ref
    ,X_Output_Tab         out nocopy GT_ContItem_Ref
    ,X_Result             out nocopy Gx_Boolean
    ,X_Return_Status   	  out nocopy Gx_Ret_Sts);

  PROCEDURE Dedup_ContItem_PlSql_Table
    (P_Input_Tab          IN  GT_ContItem_Ref
    ,X_Output_Tab         out nocopy GT_ContItem_Ref
    ,X_Result             out nocopy Gx_Boolean
    ,X_Return_Status   	  out nocopy Gx_Ret_Sts);

  PROCEDURE Get_CovLevel_Contracts
    (P_CovLevel_Items         IN  GT_ContItem_Ref
    ,P_Party_Id               IN  Gx_OKS_Id
    ,X_CovLevel_Contracts     out nocopy GT_Contract_Ref
    ,X_Result                 out nocopy Gx_Boolean
    ,X_Return_Status   	      out nocopy Gx_Ret_Sts);

  PROCEDURE Get_CovProd_Contracts
    (P_CovProd_Obj_Id         IN  Gx_OKS_Id
    ,P_Organization_Id        IN  NUMBER
    ,P_Org_Id                 IN  NUMBER
    ,X_CovProd_Contracts      out nocopy GT_Contract_Ref
    ,X_Result                 out nocopy Gx_Boolean
    ,X_Return_Status   	      out nocopy Gx_Ret_Sts);

  PROCEDURE Get_CovItem_Contracts
    (P_CovItem_Obj_Id         IN  Gx_OKS_Id
    ,P_Organization_Id        IN  NUMBER
    ,P_Party_Id               IN  Gx_OKS_Id
    ,X_CovItem_Contracts      out nocopy GT_Contract_Ref
    ,X_Result                 out nocopy Gx_Boolean
    ,X_Return_Status   	      out nocopy Gx_Ret_Sts);

  PROCEDURE Get_CovSys_Contracts
    (P_CovSys_Obj_Id          IN  Gx_OKS_Id
    ,P_Org_Id                 IN  NUMBER
    ,X_CovSys_Contracts       out nocopy GT_Contract_Ref
    ,X_Result                 out nocopy Gx_Boolean
    ,X_Return_Status   	      out nocopy Gx_Ret_Sts);

  PROCEDURE Get_CovSite_Contracts
    (P_CovSite_Obj_Id         IN  Gx_OKS_Id
    ,P_Org_Id                 IN  NUMBER
    ,X_CovSite_Contracts      out nocopy GT_Contract_Ref
    ,X_Result                 out nocopy Gx_Boolean
    ,X_Return_Status   	      out nocopy Gx_Ret_Sts);

  PROCEDURE Get_CovCust_Contracts
    (P_CovCust_Obj_Id         IN  Gx_OKS_Id
    ,X_CovCust_Contracts      out nocopy GT_Contract_Ref
    ,X_Result                 out nocopy Gx_Boolean
    ,X_Return_Status   	      out nocopy Gx_Ret_Sts);

  PROCEDURE Get_CovParty_Contracts
    (P_CovParty_Obj_Id        IN  Gx_OKS_Id
    ,X_CovParty_Contracts     out nocopy GT_Contract_Ref
    ,X_Result                 out nocopy Gx_Boolean
    ,X_Return_Status   	      out nocopy Gx_Ret_Sts);

  PROCEDURE Get_CovLvlLine_Contracts
    (P_CovLvlLine_Id          IN  Gx_OKS_Id
    ,X_Contracts              out nocopy GT_Contract_Ref
    ,X_Result                 out nocopy Gx_Boolean
    ,X_Return_Status   	      out nocopy Gx_Ret_Sts);

  PROCEDURE Get_Contracts_Id
    (P_Contract_Num           IN  VARCHAR2
    ,P_Contract_Num_Modifier  IN  VARCHAR2
    ,X_Contracts              out nocopy GT_Contract_Ref
    ,X_Result                 out nocopy Gx_Boolean
    ,X_Return_Status   	      out nocopy Gx_Ret_Sts);

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
    ,X_Return_Status   	OUT nocopy Gx_Ret_Sts);

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
    ,X_Return_Status   	OUT nocopy Gx_Ret_Sts);

  PROCEDURE Get_Contracts_01_Format
    (P_Contracts        IN  GT_Contract_Ref
    ,P_Request_Date     IN  DATE
    ,P_Validate_Flag    IN  VARCHAR2
    ,P_Chr_Id_Flag      IN  VARCHAR2             --Bug# 4719510 (JVARGHES)
    ,X_Contracts_01     out nocopy Ent_Cont_Tbl
    ,X_Result           out nocopy Gx_Boolean
    ,X_Return_Status   	OUT nocopy Gx_Ret_Sts);

  PROCEDURE Sort_Asc_GetContracts_01
    (P_Input_Tab          IN  Ent_Cont_Tbl
    ,X_Output_Tab         out nocopy Ent_Cont_Tbl
    ,X_Result             out nocopy Gx_Boolean
    ,X_Return_Status   	  out nocopy Gx_Ret_Sts);

  PROCEDURE Get_Contracts_01
    (P_API_Version		IN  NUMBER
    ,P_Init_Msg_List		IN  VARCHAR2
    ,P_Inp_Rec			IN  Inp_Cont_Rec
    ,X_Return_Status 		OUT NOCOPY VARCHAR2
    ,X_Msg_Count		OUT NOCOPY NUMBER
    ,X_Msg_Data			OUT NOCOPY VARCHAR2
    ,X_Ent_Contracts		OUT NOCOPY Ent_Cont_Tbl);

  PROCEDURE Get_Contracts
    (P_API_Version		IN  NUMBER
    ,P_Init_Msg_List		IN  VARCHAR2
    ,P_Inp_Rec			IN  Inp_Cont_Rec
    ,X_Return_Status 		OUT NOCOPY VARCHAR2
    ,X_Msg_Count		OUT NOCOPY NUMBER
    ,X_Msg_Data			OUT NOCOPY VARCHAR2
    ,X_Ent_Contracts		OUT NOCOPY Ent_Cont_Tbl);

    /*vgujarat - modified for access hour ER 9675504*/
  PROCEDURE Get_Contracts_02_Format
    (P_Contracts            IN  GT_Contract_Ref
    ,P_BusiProc_Id	    IN  Gx_BusProcess_Id
    ,P_Severity_Id	    IN  Gx_Severity_Id
    ,P_Request_TZone_Id	    IN  Gx_TimeZoneId
    ,P_Dates_In_Input_TZ    IN  VARCHAR2            -- Added for 12.0 ENT-TZ project (JVARGHES)
    ,P_Incident_Date        IN  DATE                -- Added for 12.0 ENT-TZ project (JVARGHES)
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
    ,P_cust_loc_id              IN NUMBER DEFAULT NULL);

  PROCEDURE Append_Contract_PlSql_Table
    (P_Input_Tab          IN  GT_Contract_Ref
    ,P_Append_Tab         IN  GT_Contract_Ref
    ,X_Output_Tab         out nocopy GT_Contract_Ref
    ,X_Result             out nocopy Gx_Boolean
    ,X_Return_Status   	  out nocopy Gx_Ret_Sts);

  PROCEDURE Sort_Asc_GetContracts_02
    (P_Input_Tab          IN  Get_ConTop_Tbl
    ,P_Sort_Key           IN  VARCHAR2
    ,X_Output_Tab         out nocopy Get_ConTop_Tbl
    ,X_Result             out nocopy Gx_Boolean
    ,X_Return_Status   	  out nocopy Gx_Ret_Sts);

  PROCEDURE Get_Contracts_02
    (P_API_Version		IN  NUMBER
    ,P_Init_Msg_List		IN  VARCHAR2
    ,P_Inp_Rec			IN  Inp_rec_getcont02
    ,X_Return_Status 		OUT NOCOPY VARCHAR2
    ,X_Msg_Count		OUT NOCOPY NUMBER
    ,X_Msg_Data			OUT NOCOPY VARCHAR2
    ,X_Ent_Contracts		OUT NOCOPY Get_ConTop_Tbl);

  PROCEDURE Get_Contracts
    (P_Api_Version		IN  NUMBER
    ,P_Init_Msg_List		IN  VARCHAR2
    ,P_Inp_Rec			IN  Get_ContIn_Rec
    ,X_Return_Status 		OUT NOCOPY VARCHAR2
    ,X_Msg_Count		OUT NOCOPY NUMBER
    ,X_Msg_Data			OUT NOCOPY VARCHAR2
    ,X_Ent_Contracts		OUT NOCOPY Get_ConTop_Tbl);

  PROCEDURE Get_Contracts
    (P_Api_Version		IN  NUMBER
    ,P_Init_Msg_List		IN  VARCHAR2
    ,P_Inp_Rec			IN  Input_Rec_IB
    ,X_Return_Status 		OUT NOCOPY VARCHAR2
    ,X_Msg_Count		OUT NOCOPY NUMBER
    ,X_Msg_Data			OUT NOCOPY VARCHAR2
    ,X_Ent_Contracts		OUT NOCOPY Output_Tbl_IB);

  PROCEDURE Sort_Asc_GetContracts_03
    (P_Input_Tab          IN  Output_Tbl_EntFrm
    ,X_Output_Tab         out nocopy Output_Tbl_EntFrm
    ,X_Result             out nocopy Gx_Boolean
    ,X_Return_Status   	  out nocopy Gx_Ret_Sts);

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
    ,X_Return_Status   	    out nocopy Gx_Ret_Sts);

  PROCEDURE Sort_Asc_ContRef_PlSql_Table
    (P_Input_Tab          IN  GT_Contract_Ref
    ,X_Output_Tab         out nocopy GT_Contract_Ref
    ,X_Result             out nocopy Gx_Boolean
    ,X_Return_Status   	  out nocopy Gx_Ret_Sts);

  PROCEDURE Dedup_ContItem_PlSql_Table
    (P_Input_Tab          IN  GT_Contract_Ref
    ,X_Output_Tab         out nocopy GT_Contract_Ref
    ,X_Result             out nocopy Gx_Boolean
    ,X_Return_Status   	  out nocopy Gx_Ret_Sts);

  PROCEDURE Get_Contracts_03
    (P_API_Version		IN  NUMBER
    ,P_Init_Msg_List	IN  VARCHAR2
    ,P_Inp_Rec			IN  Input_Rec_EntFrm
    ,X_Return_Status 	OUT NOCOPY VARCHAR2
    ,X_Msg_Count		OUT NOCOPY NUMBER
    ,X_Msg_Data			OUT NOCOPY VARCHAR2
    ,X_Ent_Contracts	OUT NOCOPY Output_Tbl_EntFrm);

  PROCEDURE Get_Contracts
    (P_API_Version		IN  NUMBER
    ,P_Init_Msg_List	IN  VARCHAR2
    ,P_Inp_Rec			IN  Input_Rec_EntFrm
    ,X_Return_Status 	OUT NOCOPY VARCHAR2
    ,X_Msg_Count		OUT NOCOPY NUMBER
    ,X_Msg_Data			OUT NOCOPY VARCHAR2
    ,X_Ent_Contracts	OUT NOCOPY Output_Tbl_EntFrm);

  PROCEDURE Get_Prof_Service_Name_And_Desc
    (P_Profile_Value    IN  VARCHAR2
    ,P_Db_Srv_Name      IN  VARCHAR2
    ,P_Db_Srv_Desc      IN  VARCHAR2
    ,X_Prof_Srv_Name    out nocopy VARCHAR2
    ,X_Prof_Srv_Desc    out nocopy VARCHAR2
    ,X_Result           out nocopy Gx_Boolean
    ,X_Return_Status   	OUT nocopy Gx_Ret_Sts);

  FUNCTION Get_End_Date_Time
    (P_Date_Value IN DATE) Return Date;

  PROCEDURE Get_HighImp_CP_Contract
    (P_API_Version		    IN  NUMBER
    ,P_Init_Msg_List		IN  VARCHAR2
    ,P_Customer_product_Id	IN  NUMBER
    ,X_Return_Status 		OUT NOCOPY VARCHAR2
    ,X_Msg_Count 	        out nocopy NUMBER
    ,X_Msg_Data		        out nocopy VARCHAR2
    ,X_Importance_Lvl		OUT NOCOPY OKS_ENTITLEMENTS_PUB.High_Imp_level_K_rec);

  FUNCTION Get_Final_End_Date(
    P_Contract_Id IN number,
    P_Enddate IN DATE) Return Date;

  PROCEDURE OKS_VALIDATE_SYSTEM
    (P_API_Version		    IN  NUMBER
    ,P_Init_Msg_List		IN  VARCHAR2
    ,P_System_Id	        IN  NUMBER
    ,P_Request_Date         IN  DATE
    ,P_Update_Only_Check    IN  VARCHAR2
    ,X_Return_Status 		OUT NOCOPY VARCHAR2
    ,X_Msg_Count 	        out nocopy NUMBER
    ,X_Msg_Data		        out nocopy VARCHAR2
    ,X_System_Valid		OUT NOCOPY VARCHAR2);

  PROCEDURE Get_CSI_LatestEdDtdKLines_02
    (P_Input_Tab          IN  Get_ConTop_Tbl
    ,X_Output_Tab         out nocopy Get_ConTop_Tbl
    ,X_Result             out nocopy Gx_Boolean
    ,X_Return_Status   	  out nocopy Gx_Ret_Sts);

  PROCEDURE Sort_CSI_KLineId_02
    (P_Input_Tab          IN  Get_ConTop_Tbl
    ,X_Output_Tab         out nocopy Get_ConTop_Tbl
    ,X_Result             out nocopy Gx_Boolean
    ,X_Return_Status   	  out nocopy Gx_Ret_Sts);

  PROCEDURE Dedup_CSICP_KLine_PlSql_Table
    (P_Input_Tab          IN  GT_Contract_Ref
    ,X_Output_Tab         out nocopy GT_Contract_Ref
    ,X_Result             out nocopy Gx_Boolean
    ,X_Return_Status   	  out nocopy Gx_Ret_Sts);

  PROCEDURE Get_Sort_CSI_ImpLvl
    (P_Contracts            IN  Get_ConTop_Tbl
    ,X_Contracts_02         out nocopy Get_ConTop_Tbl
    ,X_Result               out nocopy Gx_Boolean
    ,X_Return_Status   	    out nocopy Gx_Ret_Sts);

  PROCEDURE Default_Contline_System
    (P_API_Version		    IN  NUMBER
    ,P_Init_Msg_List		IN  VARCHAR2
    ,P_System_Id	        IN  NUMBER
    ,P_Request_Date         IN  DATE
    ,X_Return_Status 		OUT NOCOPY VARCHAR2
    ,X_Msg_Count 	        out nocopy NUMBER
    ,X_Msg_Data		        out nocopy VARCHAR2
    ,X_Ent_Contracts		OUT NOCOPY Default_Contline_System_Rec);

    /*vgujarat - modified for access hour ER 9675504*/
  PROCEDURE Get_Cont02Format_Validation
    (P_Contracts            IN  Idx_Rec
    ,P_BusiProc_Id	    IN  Gx_BusProcess_Id
    ,P_Severity_Id	    IN  Gx_Severity_Id
    ,P_Request_TZone_Id	    IN  Gx_TimeZoneId
    ,P_Dates_In_Input_TZ    IN VARCHAR2         -- Added for 12.0 ENT-TZ project (JVARGHES)
    ,P_Incident_Date        IN  DATE            -- Added for 12.0 ENT-TZ project (JVARGHES)
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
    ,P_cust_loc_id              IN NUMBER DEFAULT NULL);

procedure Get_cov_txn_groups
	(p_api_version		IN  Number
	,p_init_msg_list		IN  Varchar2
	,p_inp_rec_bp		IN  INP_REC_BP
	,x_return_status	OUT NOCOPY Varchar2
	,x_msg_count		OUT NOCOPY Number
	,x_msg_data			OUT NOCOPY Varchar2
	,x_cov_txn_grp_lines out nocopy OUTPUT_TBL_BP);

PROCEDURE Get_txn_billing_types
    (p_api_version		IN  Number
	,p_init_msg_list		IN  Varchar2
	,p_cov_txngrp_line_id		IN  number
    ,p_return_bill_rates_YN   IN  Varchar2
	,x_return_status 		OUT NOCOPY Varchar2
	,x_msg_count		OUT NOCOPY Number
	,x_msg_data			OUT NOCOPY Varchar2
	,x_txn_bill_types		OUT NOCOPY output_tbl_bt
    ,x_txn_bill_rates   out nocopy output_tbl_br);

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
    ,X_Return_Status   	    out nocopy Gx_Ret_Sts);

PROCEDURE Search_Contracts
    (p_api_version         IN  Number
    ,p_init_msg_list       IN  Varchar2
    ,p_contract_rec        IN  inp_cont_rec_type
    ,p_clvl_id_tbl         IN  covlvl_id_tbl
    ,x_return_status       out nocopy Varchar2
    ,x_msg_count           out nocopy Number
    ,x_msg_data            out nocopy Varchar2
    ,x_contract_tbl        out nocopy output_tbl_contract);

PROCEDURE Get_Contracts_Expiration
    (p_api_version              IN  Number
    ,p_init_msg_list            IN  Varchar2
    ,p_contract_id              IN  Number
    ,x_return_status            out nocopy Varchar2
    ,x_msg_count                out nocopy Number
    ,x_msg_data                 out nocopy Varchar2
    ,x_contract_end_date        out nocopy date
    ,x_Contract_Grace_Duration  out nocopy number
    ,x_Contract_Grace_Period    out nocopy VARCHAR2);

PROCEDURE Get_Service_PO
    (P_CHR_Id                   IN  Gx_OKS_Id
    ,P_Set_ExcepionStack        IN  Gx_Boolean
    ,X_Service_PO               out nocopy VARCHAR2
    ,X_Service_PO_required      out nocopy VARCHAR2
    ,X_Result                   out nocopy Gx_Boolean
    ,X_Return_Status            out nocopy Gx_Ret_Sts);

PROCEDURE Get_Contract_Grace
    (P_Contract_Id              IN number
    ,P_Set_ExcepionStack        IN  Gx_Boolean
    ,x_grace_period             OUT NOCOPY varchar2
    ,x_grace_duration           OUT NOCOPY number
    ,X_Result                   out nocopy Gx_Boolean
    ,X_Return_Status            out nocopy Gx_Ret_Sts) ;

PROCEDURE VALIDATE_CONTRACT_LINE
    (p_api_version              IN  NUMBER
    ,p_init_msg_list            IN  VARCHAR2
    ,p_contract_line_id         IN  NUMBER
    ,p_busiproc_id              IN  NUMBER
    ,p_request_date             IN  DATE
    ,p_covlevel_tbl_in          IN  covlevel_tbl_type
    ,p_verify_combination       IN  VARCHAR2
    ,x_return_status            OUT nocopy Varchar2
    ,x_msg_count                OUT nocopy Number
    ,x_msg_data                 OUT nocopy Varchar2
    ,x_covlevel_tbl_out         OUT NOCOPY  covlevel_tbl_type
    ,x_combination_valid        OUT NOCOPY VARCHAR2);

FUNCTION Get_NLS_day_of_week(
      P_day_of_week IN Varchar2) Return Varchar2;

PROCEDURE Get_BP_CoverTimeZone_Line
    (P_BPL_Id	             IN  Gx_OKS_Id
    ,P_Set_ExcepionStack     IN  Gx_Boolean
    ,X_BP_CVTLine_Id	     out nocopy Gx_OKS_Id
    ,X_BP_Tz_Id              out nocopy Gx_TimeZoneId
    ,X_Result                out nocopy Gx_Boolean
    ,X_Return_Status 	     out nocopy Gx_Ret_Sts);

PROCEDURE Search_Contract_lines
    (p_api_version         		IN  Number
    ,p_init_msg_list       		IN  Varchar2
    ,p_contract_rec        		IN  srchline_inpcontrec_type
    ,p_contract_line_rec        IN  srchline_inpcontlinerec_type
    ,p_clvl_id_tbl         		IN  srchline_covlvl_id_tbl
    ,x_return_status       		out nocopy Varchar2
    ,x_msg_count           		out nocopy Number
    ,x_msg_data            		out nocopy Varchar2
    ,x_contract_tbl        		out nocopy output_tbl_contractline);

-- Bug# 4899844
FUNCTION Get_BPL_Offset_Start_Date
   (P_SVL_Start_Date IN DATE
   ,P_Offset_Timeunit IN VARCHAR2
   ,P_Offset_Duration IN NUMBER) RETURN DATE;

--

END OKS_ENTITLEMENTS_PVT;


/
