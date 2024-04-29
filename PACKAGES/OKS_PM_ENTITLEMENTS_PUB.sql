--------------------------------------------------------
--  DDL for Package OKS_PM_ENTITLEMENTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_PM_ENTITLEMENTS_PUB" AUTHID CURRENT_USER AS
/* $Header: OKSPPMES.pls 120.0 2005/05/25 18:10:31 appldev noship $ */

-- GLOBAL VARIABLES
  -------------------------------------------------------------------------------
  G_PKG_NAME	               CONSTANT VARCHAR2(200) := 'OKS_PM_ENTITLEMENTS_PUB';
  G_APP_NAME_OKS	               CONSTANT VARCHAR2(3)   :=  'OKS';
  G_APP_NAME_OKC	               CONSTANT VARCHAR2(3)   :=  'OKC';
  -------------------------------------------------------------------------------

  SUBTYPE hdr_rec_type   IS OKS_ENTITLEMENTS_PUB.hdr_rec_type;
  TYPE    hdr_tbl_type   IS TABLE OF hdr_rec_type INDEX BY BINARY_INTEGER;
  SUBTYPE inp_rec_type   IS OKS_ENTITLEMENTS_PUB.inp_rec_type;

  TYPE get_contop_rec IS RECORD
		(contract_id               Number
		,contract_number           OKC_K_HEADERS_B.CONTRACT_NUMBER%TYPE
		,contract_number_modifier  OKC_K_HEADERS_B.CONTRACT_NUMBER_MODIFIER%TYPE
		,sts_code                  OKC_K_HEADERS_B.STS_CODE%TYPE
        ,service_line_id           Number
		,service_name              VARCHAR2(300)  --OKX_SYSTEM_ITEMS_V.NAME%TYPE
		,service_description       VARCHAR2(300)  --OKX_SYSTEM_ITEMS_V.DESCRIPTION%TYPE
        ,coverage_term_line_id     Number
		,coverage_term_name        OKC_K_LINES_V.NAME%TYPE
		,coverage_term_description OKC_K_LINES_V.ITEM_DESCRIPTION%TYPE
        ,coverage_type_code            Oks_Cov_Types_B.Code%TYPE
        ,coverage_type_meaning         Oks_Cov_Types_TL.Meaning%TYPE
        ,coverage_type_imp_level       Oks_Cov_Types_B.Importance_Level%TYPE
        ,service_start_date        Date
        ,service_end_date          Date
		,warranty_flag             Varchar2(1)
		,eligible_for_entitlement  Varchar2(1)
        ,exp_reaction_time         Date
        ,exp_resolution_time       Date
        ,status_code               Varchar2(1)
        ,status_text               Varchar2(1995)
        , date_terminated		Date
        ,PM_Program_Id                  VARCHAR2(40)
        ,PM_Schedule_Exists             VARCHAR2(450)
		);
  TYPE get_contop_tbl IS TABLE OF get_contop_rec INDEX BY BINARY_INTEGER;


  TYPE get_activityop_rec IS RECORD
      (service_line_id           Number
      ,PM_Program_Id             Number
      ,Activity_id               Number
      ,Act_Schedule_Exists        VARCHAR2(1));

  TYPE get_activityop_tbl IS TABLE OF get_activityop_rec INDEX BY BINARY_INTEGER;

  TYPE get_pmcontin_rec IS RECORD
  (contract_number              OKC_K_HEADERS_B.CONTRACT_NUMBER%TYPE
  ,contract_number_modifier     OKC_K_HEADERS_B.CONTRACT_NUMBER_MODIFIER%TYPE
  ,service_line_id              Number
  ,party_id                     Number
  ,item_id                      Number
  ,product_id                   Number
  ,request_date                 Date
  ,request_date_start           Date
  ,request_date_end             Date
  ,sort_key                     VARCHAR2(10));

/*  Old Record Type
  TYPE pm_sch_rec_type IS RECORD
  (service_line_id             NUMBER
  ,schedule_on                  DATE
  ,schedule_from                DATE
  ,schedule_to                  DATE);
*/

/*New Record Type  For Phase 2*/
TYPE pm_sch_rec_type IS RECORD
  (service_line_id             NUMBER
  ,program_id                  NUMBER
  ,Activity_Id                 NUMBER
  ,schedule_on                  DATE
  ,schedule_from                DATE
  ,schedule_to                  DATE);

  TYPE pm_sch_tbl_type IS TABLE OF pm_sch_rec_type INDEX BY BINARY_INTEGER;

  TYPE inp_sch_rec IS RECORD
  (service_line_id             NUMBER
  ,program_id                  NUMBER
  ,activity_id                  NUMBER
  ,schedule_start_date          DATE
  ,schedule_end_date            DATE);

  G_BEST                       CONSTANT VARCHAR2(10):= 'BEST';
  G_FIRST                      CONSTANT VARCHAR2(10):= 'FIRST';
  G_REACTION                   CONSTANT VARCHAR2(30):= 'RCN';
  G_RESOLUTION                 CONSTANT VARCHAR2(30):= 'RSN';
  G_REACT_RESOLVE              CONSTANT VARCHAR2(30):= 'RCN_RSN';

  G_REACTION_TIME              CONSTANT VARCHAR2(10):= 'RCN';
  G_RESOLUTION_TIME            CONSTANT VARCHAR2(10):= 'RSN';
  G_COVERAGE_TYPE_IMP_LEVEL    CONSTANT VARCHAR2(10):= 'COVTYP_IMP';
  G_NO_SORT_KEY                CONSTANT VARCHAR2(10):= 'NO_KEY';

  --PROCEDURES and FUNCTIONS


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

/*  Old Record Type

  PROCEDURE Get_PM_Confirmation
    (p_api_version          IN  Number
    ,p_init_msg_list        IN  Varchar2
    ,p_service_line_id      IN  Number
    ,x_return_status        out nocopy Varchar2
    ,x_msg_count            out nocopy Number
    ,x_msg_data             out nocopy Varchar2
    ,x_pm_conf_reqd         out nocopy Varchar2);
*/

/*New Record Type  For Phase 2*/
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

END OKS_PM_ENTITLEMENTS_PUB;

 

/
