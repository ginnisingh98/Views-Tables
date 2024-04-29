--------------------------------------------------------
--  DDL for Package OKS_PM_PROGRAMS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_PM_PROGRAMS_PVT" AUTHID CURRENT_USER AS
/* $Header: OKSRPMPS.pls 120.1 2005/07/01 07:44:44 jvorugan noship $ */
  ---------   ------      ------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			         CONSTANT VARCHAR2(200) := 'OKS_PM_PROGRAMS_PVT';
  G_APP_NAME			         CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  G_APP_NAME_OKS		         CONSTANT VARCHAR2(3)   :=  'OKS';
  G_UNEXPECTED_ERROR             CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
  G_EXCEPTION_HALT_VALIDATION	 EXCEPTION;
  G_SQLERRM_TOKEN                CONSTANT VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN                CONSTANT VARCHAR2(200) := 'SQLcode';
  G_REQUIRED_VALUE				 CONSTANT VARCHAR2(200) := OKC_API.G_REQUIRED_VALUE;
  G_COL_NAME_TOKEN				CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;

--for debug log
  G_DEBUG_ENABLED                       VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

-- Global Data Structures

   TYPE pms_rec_type is RECORD
   (SCHEDULE_DATE OKS_PM_SCHEDULES.SCHEDULE_DATE%TYPE);

   TYPE pms_tbl_type  is TABLE of  pms_rec_type INDEX BY BINARY_INTEGER;
   subtype pmstapi_rec_type is OKS_PMS_PVT.oks_pm_schedules_rec_type;

--Added for QA Check
   TYPE act_rec_type is RECORD
   (ACTIVITY_ID OKX_PM_ACTIVITIES_V.ID1%TYPE);

   TYPE act_tbl_type  is TABLE of  act_rec_type INDEX BY BINARY_INTEGER;

   TYPE pmsch_refresh_rec_type is RECORD
   (SEQ_NO                          NUMBER          DEFAULT NULL
   ,RULE_ID                         NUMBER          DEFAULT NULL
   --ph2
   ,PMP_RULE_ID                     NUMBER          DEFAULT NULL
   ,PMA_RULE_ID                     NUMBER          DEFAULT NULL
   ,OBJECT_VERSION_NUMBER           NUMBER(9)       DEFAULT NULL
   ,DNZ_CHR_ID                      NUMBER          DEFAULT NULL
   ,CLE_ID                          NUMBER          DEFAULT NULL
   ,SCH_SEQUENCE                    NUMBER          DEFAULT NULL
   ,SCHEDULE_DATE                   DATE            DEFAULT NULL
   ,SCHEDULE_DATE_FROM              DATE            DEFAULT NULL
   ,SCHEDULE_DATE_TO                DATE            DEFAULT NULL
   ,ACTIVITY_LINE_ID                NUMBER          DEFAULT NULL
   ,STREAM_LINE_ID                  NUMBER          DEFAULT NULL
   ,PROGRAM_ID                      NUMBER          DEFAULT NULL
   );

   TYPE pmsch_refresh_tbl_type  is TABLE of  pmsch_refresh_rec_type INDEX BY BINARY_INTEGER;

   TYPE rule_act_rec is RECORD
   (CTR_START           NUMBER,
    CTR_END             NUMBER,
    START_DATE          DATE,
    END_DATE            DATE,
    SCH_AUTO            OKC_RULES_B.RULE_INFORMATION9%TYPE,
    ACTION              VARCHAR2(30));

   TYPE rule_act_tbl  is TABLE of  rule_act_rec INDEX BY BINARY_INTEGER;

   TYPE pma_rec_type is RECORD
   (ACTIVITY_LINE_ID OKS_PM_ACTIVITIES.ID%TYPE);

   TYPE pma_tbl_type IS TABLE OF pma_rec_type INDEX BY BINARY_INTEGER;

   TYPE pm_rec_type is RECORD
   ( ID NUMBER,
     TYPE VARCHAR2(80));

   TYPE pm_tbl_type IS TABLE OF pm_rec_type INDEX BY BINARY_INTEGER;

   PROCEDURE  GENERATE_SCHEDULE
        (p_api_version           IN NUMBER,
         p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
         x_return_status         OUT NOCOPY VARCHAR2,
         x_msg_count             OUT NOCOPY NUMBER,
         x_msg_data              OUT NOCOPY VARCHAR2,
         p_periods               IN NUMBER,
         p_start_date            IN DATE,
         p_end_date              IN DATE,
         p_duration              IN NUMBER,
         p_period                IN VARCHAR2,
         p_first_sch_date        IN DATE,
         x_periods               OUT NOCOPY NUMBER,
         x_last_date             OUT NOCOPY DATE,
         x_pms_tbl               OUT NOCOPY pms_tbl_type);

   PROCEDURE RENEW_PM_PROGRAM_SCHEDULE
       (p_api_version           IN NUMBER,
        p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
        x_return_status         OUT NOCOPY VARCHAR2,
        x_msg_count             OUT NOCOPY NUMBER,
        x_msg_data              OUT NOCOPY VARCHAR2,
        p_contract_line_id      IN NUMBER);

   PROCEDURE ADJUST_PM_PROGRAM_SCHEDULE
       (p_api_version           IN NUMBER,
        p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
        p_contract_line_id      IN NUMBER,
        p_new_start_date        IN DATE,
        p_new_end_date          IN DATE,
        x_return_status         OUT NOCOPY VARCHAR2,
        x_msg_count             OUT NOCOPY NUMBER,
        x_msg_data              OUT NOCOPY VARCHAR2);


/*    --for upgrade from Phase I - this needs to be changed for rules rearchitecture
    PROCEDURE update_pmp_rule_id(p_api_version                   IN NUMBER,
                                   p_init_msg_list                 IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                   x_return_status                 OUT NOCOPY VARCHAR2,
                                   x_msg_count                     OUT NOCOPY NUMBER,
                                   x_msg_data                      OUT NOCOPY VARCHAR2);*/

    PROCEDURE  CREATE_PM_PROGRAM_SCHEDULE
       (p_api_version     IN NUMBER,
        p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
        x_return_status         OUT NOCOPY VARCHAR2,
        x_msg_count             OUT NOCOPY NUMBER,
        x_msg_data              OUT NOCOPY VARCHAR2,
        p_template_cle_id      IN NUMBER,
        p_cle_id                IN NUMBER, --instantiated cle id
        p_cov_start_date        IN DATE,
        p_cov_end_date          IN DATE);

   PROCEDURE REFRESH_PM_PROGRAM_SCHEDULE
       (p_api_version     IN NUMBER,
        p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
        x_return_status         OUT NOCOPY VARCHAR2,
        x_msg_count             OUT NOCOPY NUMBER,
        x_msg_data              OUT NOCOPY VARCHAR2,
        p_cov_tbl               IN okc_contract_pub.clev_tbl_type,
        p_pmlrulv_tbl           IN oks_pml_pvt.pmlv_tbl_type,
        x_pmlrulv_tbl           OUT NOCOPY oks_pml_pvt.pmlv_tbl_type,
        x_pmschv_tbl            OUT NOCOPY pmsch_refresh_tbl_type);

   PROCEDURE POPULATE_SCHEDULE
       (p_api_version     IN NUMBER,
        p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
        x_return_status         OUT NOCOPY VARCHAR2,
        x_msg_count             OUT NOCOPY NUMBER,
        x_msg_data              OUT NOCOPY VARCHAR2,
        p_pmlrulv_tbl           IN oks_pml_pvt.pmlv_tbl_type,
        p_sch_tbl               IN  OKS_PMS_PVT.oks_pm_schedules_v_tbl_type,
        p_pma_tbl               IN  pma_tbl_type,
        p_is_template           IN VARCHAR2);

   PROCEDURE migrate_to_program
          (    p_start_rowid IN ROWID,
               p_end_rowid IN ROWID,
               p_api_version                   IN NUMBER,
               p_init_msg_list                 IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
               x_msg_count                     OUT NOCOPY NUMBER,
               x_return_status OUT NOCOPY VARCHAR2,
               x_msg_data  OUT NOCOPY VARCHAR2);

   PROCEDURE migrate_to_activities
          (    p_start_rowid IN ROWID,
               p_end_rowid IN ROWID,
               p_api_version                   IN NUMBER,
               p_init_msg_list                 IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
               x_msg_count                     OUT NOCOPY NUMBER,
               x_return_status OUT NOCOPY VARCHAR2,
               x_msg_data  OUT NOCOPY VARCHAR2);

--New procedure to be called from coverage comparison code
    PROCEDURE check_pm_match
       ( p_api_version	                IN NUMBER,
        p_init_msg_list                 IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
        x_return_status                 OUT NOCOPY VARCHAR2,
        x_msg_count                     OUT NOCOPY NUMBER,
        x_msg_data                      OUT NOCOPY VARCHAR2,
        P_Source_coverage_Line_Id       IN NUMBER,
        P_Target_coverage_Line_Id       IN NUMBER,
        x_pm_match                      OUT  NOCOPY VARCHAR2);


   PROCEDURE check_pm_schedule
        (
        x_return_status            OUT NOCOPY VARCHAR2,
        p_chr_id                   IN  NUMBER);

   PROCEDURE check_pm_program_effectivity
        (
        x_return_status            OUT NOCOPY VARCHAR2,
        p_chr_id                   IN  NUMBER);
-- added new qa check

   PROCEDURE CHECK_PM_REQUIRED_VALUES (
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER);

--02/18/04 added new qa check
PROCEDURE check_pm_new_activities(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER);

   PROCEDURE UNDO_PM_LINE
        (
        p_api_version           IN NUMBER,
        p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
        x_return_status         OUT NOCOPY VARCHAR2,
        x_msg_count             OUT NOCOPY NUMBER,
        x_msg_data              OUT NOCOPY VARCHAR2,
        p_cle_id               IN NUMBER);

    PROCEDURE INIT_OKS_K_LINE(x_klnv_tbl  OUT NOCOPY OKS_KLN_PVT.klnv_tbl_type);
    PROCEDURE version_PM(
				p_api_version                  IN NUMBER,
				p_init_msg_list                IN VARCHAR2,
				x_return_status                OUT NOCOPY VARCHAR2,
                x_msg_count                    OUT NOCOPY NUMBER,
                x_msg_data                     OUT NOCOPY VARCHAR2,
                p_chr_id                          IN NUMBER,
                p_major_version                IN NUMBER);


    PROCEDURE Restore_PM(
				p_api_version                  IN NUMBER,
				p_init_msg_list                IN VARCHAR2,
				x_return_status                OUT NOCOPY VARCHAR2,
                x_msg_count                    OUT NOCOPY NUMBER,
                x_msg_data                     OUT NOCOPY VARCHAR2,
                p_chr_id                          IN NUMBER);


    PROCEDURE	Delete_PMHistory(
    			p_api_version                  IN NUMBER,
    			p_init_msg_list                IN VARCHAR2,
    			x_return_status                OUT NOCOPY VARCHAR2,
    			x_msg_count                    OUT NOCOPY NUMBER,
    			x_msg_data                     OUT NOCOPY VARCHAR2,
    			p_chr_id                       IN NUMBER);

    PROCEDURE Delete_PMSaved_Version(
                p_api_version                  IN NUMBER,
                p_init_msg_list                IN VARCHAR2,
                x_return_status                OUT NOCOPY VARCHAR2,
                x_msg_count                    OUT NOCOPY NUMBER,
                x_msg_data                     OUT NOCOPY VARCHAR2,
                p_chr_id                       IN NUMBER);

   -- New procedure for copying PM for coverage template
    PROCEDURE  Copy_PM_Template (
                p_api_version           IN NUMBER,
                p_init_msg_list         IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
                x_return_status         OUT NOCOPY VARCHAR2,
                x_msg_count             OUT NOCOPY NUMBER,
                x_msg_data              OUT NOCOPY VARCHAR2,
                p_old_coverage_id       IN NUMBER,
                p_new_coverage_id       IN NUMBER); --instantiated cle id


END OKS_PM_PROGRAMS_PVT;

 

/
