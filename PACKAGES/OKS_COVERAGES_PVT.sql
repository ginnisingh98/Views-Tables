--------------------------------------------------------
--  DDL for Package OKS_COVERAGES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_COVERAGES_PVT" AUTHID CURRENT_USER AS
/* $Header: OKSRMCVS.pls 120.5.12000000.1 2007/01/16 22:11:14 appldev ship $*/

TYPE jtf_note_rec_type IS RECORD(
    JTF_NOTE_ID    NUMBER,
    SOURCE_OBJECT_CODE  VARCHAR2(240),
    NOTE_STATUS         VARCHAR2(240),
    NOTE_TYPE           VARCHAR2(240),
    NOTES               VARCHAR2(2000),
    NOTES_DETAIL        VARCHAR2(32767),
    -- Modified by Jvorugan for Bug:4489214 who columns not to be populated from old contract
  /*  Created_By          NUMBER,
    LAst_Updated_By     Number,
    LAst_Update_Login   Number  */
    ENTERED_BY          NUMBER,
    ENTERED_DATE        DATE );
    -- End of changes for Bug:4489214

TYPE jtf_note_tbl_type IS TABLE of jtf_note_rec_type INDEX BY BINARY_INTEGER;
L_Notes_TBL jtf_note_tbl_type;

TYPE ac_rec_type IS RECORD(Svc_cle_Id NUMBER,
                           Tmp_cle_Id NUMBER,
                           Start_date  Date,
                           End_Date    Date,
                           RLE_CODE    VARCHAR2(40));
ac_rec_in    ac_rec_type;
  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP			CONSTANT VARCHAR2(200) := OKC_API.G_FND_APP;
  G_FORM_UNABLE_TO_RESERVE_REC	CONSTANT VARCHAR2(200) := OKC_API.G_FORM_UNABLE_TO_RESERVE_REC;
  G_FORM_RECORD_DELETED		CONSTANT VARCHAR2(200) := OKC_API.G_FORM_RECORD_DELETED;
  G_FORM_RECORD_CHANGED		CONSTANT VARCHAR2(200) := OKC_API.G_FORM_RECORD_CHANGED;
  G_RECORD_LOGICALLY_DELETED	CONSTANT VARCHAR2(200) := OKC_API.G_RECORD_LOGICALLY_DELETED;
  G_REQUIRED_VALUE		CONSTANT VARCHAR2(200) := OKC_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE		CONSTANT VARCHAR2(200) := OKC_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_CHILD_TABLE_TOKEN;
  G_UNEXPECTED_ERROR            CONSTANT VARCHAR2(200) := 'OKS_UNEXP_ERROR';
  G_SQLERRM_TOKEN               CONSTANT VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN               CONSTANT VARCHAR2(200) := 'SQLcode';
  ------------------------------------------------------------------------------------
  -- GLOBAL EXCEPTION
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;
  G_EXCEPTION_RULE_UPDATE   	EXCEPTION;
  G_EXCEPTION_BRS_UPDATE        EXCEPTION;

  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKS_COVERAGES_PVT';
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  ---------------------------------------------------------------------------

  G_DEBUG_ENABLED                       VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

PROCEDURE Validate_svc_cle_id(
    p_ac_rec            IN ac_rec_type,
    x_return_status 	OUT NOCOPY VARCHAR2);
PROCEDURE Validate_Tmp_cle_id(
    p_ac_rec            IN ac_rec_type,
    x_template_yn       OUT NOCOPY VARCHAR2,
    x_return_status 	OUT NOCOPY VARCHAR2);
PROCEDURE Validate_Line_id(
    p_line_id          IN NUMBER,
    x_return_status 	OUT NOCOPY VARCHAR2);
PROCEDURE CREATE_ACTUAL_COVERAGE(
    p_api_version     IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_ac_rec_in             IN  ac_rec_type,
    p_restricted_update     IN VARCHAR2 DEFAULT 'F',
    x_Actual_coverage_id    OUT NOCOPY NUMBER);
PROCEDURE Undo_Header(
    p_api_version	    IN  NUMBER,
    p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    P_Header_id    	    IN NUMBER);
PROCEDURE Undo_Line(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    P_Line_Id               IN NUMBER);

    /* New one with validate status  */
PROCEDURE Undo_Line(
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    p_validate_status       IN VARCHAR2 DEFAULT 'N',
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    P_Line_Id               IN NUMBER);

PROCEDURE UNDO_EVENTS	(P_Kline_Id 	IN 	NUMBER,
			x_Return_Status	OUT NOCOPY	VARCHAR2,
			x_msg_data	OUT NOCOPY	VARCHAR2);

PROCEDURE UNDO_Counters	(P_Kline_Id 	IN 	  NUMBER,
			x_Return_Status	OUT NOCOPY	VARCHAR2,
			x_msg_data	OUT NOCOPY	VARCHAR2);
PROCEDURE Update_COVERAGE_Effectivity(
    p_api_version     IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_service_Line_Id          IN  NUMBER,
    p_New_Start_Date        IN DATE,
    p_New_End_Date           IN DATE) ;

PROCEDURE Init_CLEV(P_CLEV_tbl_in_Out IN OUT NOCOPY okc_contract_pub.Clev_tbl_type);
PROCEDURE Init_CTCV(P_CTCV_tbl_in_Out IN OUT NOCOPY okc_contract_party_pub.Ctcv_tbl_type);
PROCEDURE Init_CIMV(P_CIMV_tbl_in_Out IN OUT NOCOPY okc_contract_item_pub.Cimv_tbl_type);

/*
--PROCEDURE Init_RGPV(P_RGPV_tbl_in_out IN OUT NOCOPY okc_Rule_pub.Rgpv_tbl_type);
--PROCEDURE Init_RULV(P_RULV_tbl_in_out IN OUT NOCOPY okc_Rule_Pub.Rulv_tbl_type);
--PROCEDURE Init_ATEV(P_ATEV_tbl_in_Out IN OUT NOCOPY okc_article_pub.Atev_tbl_type);
--PROCEDURE Init_RILV(P_RILV_tbl_in_Out IN OUT NOCOPY okc_rule_pub.Rilv_tbl_type);
PROCEDURE Init_TGDV(P_TGDV_EXT_tbl_In_Out IN OUT NOCOPY okc_time_pub.TGDV_Ext_tbl_TYPE);
PROCEDURE Init_IGSV(P_IGSV_EXT_tbl_In_Out IN OUT NOCOPY okc_time_pub.Igsv_Ext_tbl_TYPE);
PROCEDURE Init_ISEV(P_ISEV_EXT_tbl_In_Out IN OUT NOCOPY okc_time_pub.Isev_Ext_tbl_TYPE);
--PROCEDURE Init_CTIV(P_CTIV_tbl_In_Out IN OUT NOCOPY okc_rule_pub.Ctiv_tbl_type);
*/

PROCEDURE INIT_BILL_RATE_LINE(x_bill_rate_tbl OUT NOCOPY  OKS_BRS_PVT.OKSBILLRATESCHEDULESVTBLTYPE);


PROCEDURE  CREATE_ADJUSTED_COVERAGE(
    p_api_version                   IN NUMBER,
    p_init_msg_list                 IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                 OUT NOCOPY VARCHAR2,
    x_msg_count                     OUT NOCOPY NUMBER,
    x_msg_data                      OUT NOCOPY VARCHAR2,
    P_Source_contract_Line_Id       IN NUMBER,
    P_Target_contract_Line_Id       IN NUMBER,
    x_Actual_coverage_id            OUT NOCOPY NUMBER);



   TYPE res_rec_type IS RECORD
(bp_id              OKC_K_ITEMS_V.OBJECT1_ID1%TYPE,
   cro_code            OKC_CONTACTS_V.CRO_CODE%TYPE,
   object1_id1         OKC_CONTACTS_V.object1_id1%TYPE,
   resource_class      OKC_CONTACTS_V.RESOURCE_CLASS%TYPE);

    TYPE res_tbl_type IS TABLE OF res_rec_type
    INDEX BY BINARY_INTEGER ;

    x_source_res_tbl_type  res_tbl_type;
    x_target_res_tbl_type  res_tbl_type;



    TYPE bp_rec_type IS RECORD
    (object1_id1         OKC_K_ITEMS_V.OBJECT1_ID1%TYPE,
     bp_line_id          OKC_K_LINES_V.ID%TYPE,
     start_date          DATE,
     end_date            DATE);

    TYPE bp_tbl_type IS TABLE OF bp_rec_type
    INDEX BY BINARY_INTEGER;

     x_source_bp_tbl_type  bp_tbl_type  ;
     x_target_bp_tbl_type  bp_tbl_type  ;

   TYPE bp_line_rec_type IS RECORD
     (bp_id                  OKC_K_ITEMS_V.OBJECT1_ID1%TYPE,
     src_bp_line_id          OKC_K_LINES_V.ID%TYPE,
     tgt_bp_line_id          OKC_K_LINES_V.ID%TYPE);

    TYPE bp_line_tbl_type IS TABLE OF bp_line_rec_type    INDEX BY BINARY_INTEGER;

    l_bp_tbl    bp_line_tbl_type;


     TYPE COVER_TIME_REC_TYPE IS RECORD
   (OBJECT1_ID1        OKC_K_ITEMS_V.OBJECT1_ID1%TYPE,
    START_DAY          OKC_TIMEVALUES_V.DAY_OF_WEEK%TYPE,
    START_HOUR         OKC_TIMEVALUES_V.HOUR%TYPE,
    START_MINUTE       OKC_TIMEVALUES_V.MINUTE%TYPE,
    END_DAY            OKC_TIMEVALUES_V.DAY_OF_WEEK%TYPE,
    END_HOUR           OKC_TIMEVALUES_V.HOUR%TYPE,
    END_MINUTE         OKC_TIMEVALUES_V.MINUTE%TYPE);

    TYPE COVER_TIME_TBL_TYPE IS TABLE OF COVER_TIME_REC_TYPE
    INDEX BY BINARY_INTEGER;

    x_source_cover_tbl       cover_time_tbl_type ;
    x_target_cover_tbl       cover_time_tbl_type ;



   TYPE brs_rec_type IS RECORD
  (START_HOUR                     OKS_BILLRATE_SCHEDULES.START_HOUR%TYPE,
   START_MINUTE                   OKS_BILLRATE_SCHEDULES.START_MINUTE%TYPE,
   END_HOUR                       OKS_BILLRATE_SCHEDULES.END_MINUTE%TYPE,
   END_MINUTE                     OKS_BILLRATE_SCHEDULES.END_MINUTE%TYPE,
   MONDAY_FLAG                    OKS_BILLRATE_SCHEDULES.MONDAY_FLAG%TYPE,
   TUESDAY_FLAG                   OKS_BILLRATE_SCHEDULES.TUESDAY_FLAG%TYPE,
   WEDNESDAY_FLAG                 OKS_BILLRATE_SCHEDULES.WEDNESDAY_FLAG%TYPE,
   THURSDAY_FLAG                  OKS_BILLRATE_SCHEDULES.THURSDAY_FLAG%TYPE,
   FRIDAY_FLAG                    OKS_BILLRATE_SCHEDULES.FRIDAY_FLAG%TYPE,
   SATURDAY_FLAG                  OKS_BILLRATE_SCHEDULES.SATURDAY_FLAG%TYPE,
   SUNDAY_FLAG                    OKS_BILLRATE_SCHEDULES.SUNDAY_FLAG%TYPE,
   OBJECT1_ID1                    OKS_BILLRATE_SCHEDULES.OBJECT1_ID1%TYPE,
   OBJECT1_ID2                    OKS_BILLRATE_SCHEDULES.OBJECT1_ID2%TYPE,
   JTOT_OBJECT1_CODE              OKS_BILLRATE_SCHEDULES.JTOT_OBJECT1_CODE%TYPE,
   BILL_RATE_CODE                 OKS_BILLRATE_SCHEDULES.BILL_RATE_CODE%TYPE,
   FLAT_RATE                      OKS_BILLRATE_SCHEDULES.FLAT_RATE%TYPE,
   UOM                            OKS_BILLRATE_SCHEDULES.UOM%TYPE,
   HOLIDAY_YN                     OKS_BILLRATE_SCHEDULES.HOLIDAY_YN%TYPE,
   PERCENT_OVER_LIST_PRICE        OKS_BILLRATE_SCHEDULES.PERCENT_OVER_LIST_PRICE%TYPE);

   TYPE brs_tbl_type IS TABLE OF brs_rec_type
   INDEX BY BINARY_INTEGER;

   x_source_brs_tbl   brs_tbl_type;
   x_target_brs_tbl   brs_tbl_type;


  TYPE  billrate_day_overlap_type IS RECORD
(monday_overlap  VARCHAR2(1),
 tuesday_overlap  VARCHAR2(1),
wednesday_overlap  VARCHAR2(1),
thursday_overlap  VARCHAR2(1),
friday_overlap  VARCHAR2(1),
saturday_overlap  VARCHAR2(1),
sunday_overlap  VARCHAR2(1));



  PROCEDURE Validate_billrate_schedule(p_billtype_line_id IN NUMBER,
                                     p_holiday_yn IN varchar2,
                                     x_days_overlap OUT  NOCOPY billrate_day_overlap_type,
                                     x_return_status OUT  NOCOPY VARCHAR2);

  PROCEDURE  OKS_MIGRATE_BILLRATES(
    p_api_version                   IN NUMBER,
    p_init_msg_list                 IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                 OUT NOCOPY VARCHAR2,
    x_msg_count                     OUT NOCOPY NUMBER,
    x_msg_data                      OUT NOCOPY VARCHAR2);

  PROCEDURE INIT_CONTRACT_LINE (x_clev_tbl OUT NOCOPY OKC_CONTRACT_PUB.clev_tbl_type);


  TYPE time_labor_rec IS RECORD
  (
  START_TIME           DATE,
 END_TIME             DATE,
 MONDAY_FLAG          VARCHAR2(1),
 TUESDAY_FLAG         VARCHAR2(1),
 WEDNESDAY_FLAG       VARCHAR2(1),
 THURSDAY_FLAG        VARCHAR2(1),
 FRIDAY_FLAG          VARCHAR2(1),
 SATURDAY_FLAG        VARCHAR2(1),
 SUNDAY_FLAG          VARCHAR2(1),
 HOLIDAY_FLAG         VARCHAR2(1),
 INVENTORY_ITEM_ID    NUMBER,
 LABOR_CODE           VARCHAR2(30));


   TYPE time_labor_tbl IS TABLE OF time_labor_rec
   INDEX BY BINARY_INTEGER;



  PROCEDURE OKS_BILLRATE_MAPPING(
                                p_api_version           IN NUMBER ,
                                p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                p_business_process_id   IN NUMBER,
                                p_time_labor_tbl_in     IN time_labor_tbl,
                                x_return_status         OUT NOCOPY VARCHAR2,
                                x_msg_count             OUT NOCOPY NUMBER,
                                x_msg_data              OUT NOCOPY VARCHAR2);

  PROCEDURE Copy_Coverage(p_api_version           IN   NUMBER,
                           p_init_msg_list        IN   VARCHAR2 DEFAULT OKC_API.G_FALSE,
                           x_return_status        OUT  NOCOPY   VARCHAR2,
                           x_msg_count            OUT  NOCOPY   NUMBER,
                           x_msg_data             OUT  NOCOPY   VARCHAR2,
                           p_contract_line_id     IN   NUMBER);


  PROCEDURE VALIDATE_COVERTIME(p_tze_line_id   IN NUMBER,
                               x_days_overlap  OUT  NOCOPY oks_coverages_pvt.billrate_day_overlap_type,
                               x_return_status OUT  NOCOPY VARCHAR2);


   PROCEDURE INIT_OKS_K_LINE(x_klnv_tbl  OUT NOCOPY  oks_kln_pvt.klnv_tbl_type);
   PROCEDURE INIT_OKS_TIMEZONE_LINE(x_timezone_tbl OUT NOCOPY oks_ctz_pvt.OksCoverageTimezonesVTblType);
   PROCEDURE INIT_OKS_COVER_TIME_LINE(x_cover_time_tbl OUT NOCOPY oks_cvt_pvt.oks_coverage_times_v_tbl_type);
   PROCEDURE INIT_OKS_ACT_TYPE(x_act_time_tbl OUT NOCOPY OKS_ACT_PVT.OksActionTimeTypesVTblType);
   PROCEDURE INIT_OKS_ACT_TIME(x_act_type_tbl OUT NOCOPY OKS_ACM_PVT.oks_action_times_v_tbl_type);


PROCEDURE  MIGRATE_PRIMARY_RESOURCES(p_api_version                   IN NUMBER,
                                          p_init_msg_list                 IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                          x_return_status                 OUT NOCOPY VARCHAR2,
                                          x_msg_count                     OUT NOCOPY NUMBER,
                                          x_msg_data                      OUT NOCOPY VARCHAR2) ;

--------------------CHECK COVERAGE MATCH------------------------------------------
TYPE oks_bp_rec IS RECORD
     (PRICE_LIST_ID            OKC_K_LINES_B.PRICE_LIST_ID%TYPE,
      OBJECT1_ID1              OKC_K_ITEMS.OBJECT1_ID1%TYPE,
      DISCOUNT_LIST            OKS_K_LINES_B.DISCOUNT_LIST%TYPE,
      OFFSET_DURATION          OKS_K_LINES_B.OFFSET_DURATION%TYPE,
      OFFSET_PERIOD            OKS_K_LINES_B.OFFSET_PERIOD%TYPE,
      ALLOW_BT_DISCOUNT        OKS_K_LINES_B.ALLOW_BT_DISCOUNT%TYPE,
      APPLY_DEFAULT_TIMEZONE   OKS_K_LINES_B.APPLY_DEFAULT_TIMEZONE%TYPE);

      TYPE oks_bp_tbl IS TABLE OF oks_bp_rec
      INDEX BY BINARY_INTEGER;

     x_source_bp_tbl oks_bp_tbl;
     x_target_bp_tbl oks_bp_tbl;

    TYPE bp_cover_time_rec IS RECORD
    (object1_id1   OKC_K_ITEMS.object1_id1%TYPE,
     timezone_id   OKS_COVERAGE_TIMEZONES.timezone_id%TYPE,
     default_yn    OKS_COVERAGE_TIMEZONES.default_yn%TYPE,
     start_hour    OKS_COVERAGE_TIMES.start_hour%TYPE,
     start_minute  OKS_COVERAGE_TIMES.start_minute%TYPE,
     end_hour      OKS_COVERAGE_TIMES.end_hour%TYPE,
     end_minute    OKS_COVERAGE_TIMES.end_minute%TYPE,
     monday_yn     OKS_COVERAGE_TIMES.monday_yn%TYPE,
     tuesday_yn    OKS_COVERAGE_TIMES.tuesday_yn%TYPE,
     wednesday_yn  OKS_COVERAGE_TIMES.wednesday_yn%TYPE,
     thursday_yn   OKS_COVERAGE_TIMES.thursday_yn%TYPE,
     friday_yn     OKS_COVERAGE_TIMES.friday_yn%TYPE,
     saturday_yn   OKS_COVERAGE_TIMES.saturday_yn%TYPE,
     sunday_yn     OKS_COVERAGE_TIMES.sunday_yn%TYPE);

      TYPE bp_cover_time_tbl IS TABLE OF bp_cover_time_rec
      INDEX BY BINARY_INTEGER;

      x_source_bp_cover_time_tbl  bp_cover_time_tbl;
      x_target_bp_cover_time_tbl  bp_cover_time_tbl;

           TYPE react_time_rec IS RECORD
     (incident_severity_id   OKS_K_LINES_V.INCIDENT_SEVERITY_ID%TYPE,
      pdf_id                 OKS_K_LINES_V.PDF_ID%TYPE,
      work_thru_yn           OKS_K_LINES_V.WORK_THRU_YN%TYPE,
      react_active_yn        OKS_K_LINES_V.REACT_ACTIVE_YN%TYPE,
      react_time_name        OKS_K_LINES_V.REACT_TIME_NAME%TYPE,
      action_type_code       OKS_ACTION_TIME_TYPES.ACTION_TYPE_CODE%TYPE,
      uom_code               OKS_ACTION_TIMES.UOM_CODE%TYPE,
      sun_duration           OKS_ACTION_TIMES.SUN_DURATION%TYPE,
      mon_duration           OKS_ACTION_TIMES.MON_DURATION%TYPE,
      tue_duration           OKS_ACTION_TIMES.TUE_DURATION%TYPE,
      wed_duration           OKS_ACTION_TIMES.WED_DURATION%TYPE,
      thu_duration           OKS_ACTION_TIMES.THU_DURATION%TYPE,
      fri_duration           OKS_ACTION_TIMES.FRI_DURATION%TYPE,
      sat_duration           OKS_ACTION_TIMES.SAT_DURATION%TYPE);

      TYPE react_time_tbl IS TABLE OF react_time_rec
      INDEX BY BINARY_INTEGER;

      x_source_react_time_tbl   react_time_tbl;
      x_target_react_time_tbl   react_time_tbl;

       TYPE bill_type_rec IS RECORD
  (object1_id1          OKC_K_ITEMS_V.OBJECT1_ID1%TYPE,
   bill_type_line_id    NUMBER,
   billing_type         VARCHAR2(30),
   discount_amount     OKS_K_LINES_B.DISCOUNT_AMOUNT%TYPE,
   discount_percent    OKS_K_LINES_B.DISCOUNT_PERCENT%TYPE);

   TYPE bill_type_tbl IS TABLE OF bill_type_rec   INDEX BY BINARY_INTEGER;

    x_source_bill_tbl  bill_type_tbl;
    x_target_bill_tbl  bill_type_tbl;


Procedure CHECK_COVERAGE_MATCH
   ( p_api_version	        IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    P_Source_contract_Line_Id       IN NUMBER,
    P_Target_contract_Line_Id       IN NUMBER,
    x_coverage_match         OUT NOCOPY VARCHAR2);

-- The Following API checks for the Business Procees Line Id IF Time Zone Exists.Returns 'Y' If exists else 'N'
Procedure CHECK_TimeZone_Exists
   ( p_api_version	        IN NUMBER,
    p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    P_BP_Line_ID       IN NUMBER,
    P_TimeZone_Id       IN NUMBER,
    x_TimeZone_Exists         OUT NOCOPY VARCHAR2);





PROCEDURE version_Coverage(
				p_api_version                  IN NUMBER,
				p_init_msg_list                IN VARCHAR2,
				x_return_status                OUT NOCOPY VARCHAR2,
                x_msg_count                    OUT NOCOPY NUMBER,
                x_msg_data                     OUT NOCOPY VARCHAR2,
                p_chr_id                          IN NUMBER,
                p_major_version                IN NUMBER);


PROCEDURE Restore_Coverage(
				p_api_version                  IN NUMBER,
				p_init_msg_list                IN VARCHAR2,
				x_return_status                OUT NOCOPY VARCHAR2,
                x_msg_count                    OUT NOCOPY NUMBER,
                x_msg_data                     OUT NOCOPY VARCHAR2,
                p_chr_id                          IN NUMBER);

PROCEDURE	Delete_History(
    			p_api_version                  IN NUMBER,
    			p_init_msg_list                IN VARCHAR2,
    			x_return_status                OUT NOCOPY VARCHAR2,
    			x_msg_count                    OUT NOCOPY NUMBER,
    			x_msg_data                     OUT NOCOPY VARCHAR2,
    			p_chr_id                       IN NUMBER);


PROCEDURE Delete_Saved_Version(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_id                       IN NUMBER);

PROCEDURE COPY_K_HDR_NOTES
           (p_api_version           IN NUMBER ,
            p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
            p_chr_id               IN NUMBER,
            x_return_status         OUT NOCOPY VARCHAR2,
            x_msg_count             OUT NOCOPY NUMBER,
            x_msg_data              OUT NOCOPY VARCHAR2);



PROCEDURE Update_dnz_chr_id
          (p_coverage_id          IN NUMBER ,
           p_dnz_chr_id           IN NUMBER);


PROCEDURE Create_K_coverage_ext(p_api_version          IN   NUMBER,
                                p_init_msg_list        IN   VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                p_src_line_id          IN   NUMBER,
                                p_tgt_line_id          IN   NUMBER,
                                x_return_status        OUT  NOCOPY   VARCHAR2,
                                x_msg_count            OUT  NOCOPY   NUMBER,
                                x_msg_data             OUT  NOCOPY   VARCHAR2);

PROCEDURE COPY_NOTES
           (p_api_version           IN NUMBER ,
            p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
            p_line_id               IN NUMBER,
            x_return_status         OUT NOCOPY VARCHAR2,
            x_msg_count             OUT NOCOPY NUMBER,
            x_msg_data              OUT NOCOPY VARCHAR2);
--New procedure for copy coverage functionality
PROCEDURE  COPY_STANDARD_COVERAGE(
    p_api_version                   IN NUMBER,
    p_init_msg_list                 IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                 OUT NOCOPY VARCHAR2,
    x_msg_count                     OUT NOCOPY NUMBER,
    x_msg_data                      OUT NOCOPY VARCHAR2,
    P_old_coverage_id               IN NUMBER,
    P_new_coverage_name             IN VARCHAR2,
    x_new_coverage_id               OUT NOCOPY NUMBER);

END OKS_COVERAGES_PVT;


 

/
