--------------------------------------------------------
--  DDL for Package ICX_CAT_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_CAT_UTIL_PVT" AUTHID CURRENT_USER AS
/* $Header: ICXVUTLS.pls 120.14.12010000.4 2014/09/25 17:18:31 prilamur ship $*/

g_apps_schema_name      VARCHAR2(20) := NULL;
g_icx_schema_name       VARCHAR2(20) := NULL;

TYPE g_who_columns_rec_type IS RECORD
(
  user_id                       NUMBER,
  login_id                      NUMBER,
  internal_request_id		NUMBER,
  request_id                    NUMBER,
  program_application_id        NUMBER,
  program_id                    NUMBER,
  program_login_id              NUMBER
);

g_who_columns_rec       g_who_columns_rec_type;

g_batch_size            NUMBER;

g_COMMIT                VARCHAR2(1)     := FND_API.G_FALSE;

--Used to find out which cursor is processed currently
g_BPACsr_const          VARCHAR2(15)    := 'BPA';
g_QuoteCsr_const        VARCHAR2(15)    := 'Quote';
g_GBPACsr_const         VARCHAR2(15)    := 'GBPA';
g_ReqTemplateCsr_const  VARCHAR2(15)    := 'ReqTemplate';
g_MasterItemCsr_const   VARCHAR2(15)    := 'MASTER_ITEM';
g_PODoc_const           VARCHAR2(15)    := 'PO_DOCUMENTS';
g_ItemCatgChange_const  BOOLEAN         := FALSE;

g_upgrade_const         VARCHAR2(15)    := 'UPGRADE';
g_online_const          VARCHAR2(15)    := 'ONLINE';
g_NULL_NUMBER           NUMBER          := -2;
g_NULL_CHAR             VARCHAR2(10)    := '-2';
g_upgrade_user          NUMBER          := -12;

--Global variables for purchasing category set info
g_category_set_id       NUMBER;
g_validate_flag         VARCHAR2(1);
g_structure_id          NUMBER;

-- Global variable for master items concatenated segment clause
g_mi_concat_seg_clause        VARCHAR2(2000)  :=  NULL;

-- Global variable for the base language
g_base_language         fnd_languages.language_code%TYPE;

-- Global variables for the values of item_type
g_purchase_item_type            CONSTANT VARCHAR2(8) := 'PURCHASE';
g_internal_item_type            CONSTANT VARCHAR2(8) := 'INTERNAL';
g_both_item_type                CONSTANT VARCHAR2(8) := 'BOTH';

-- Global constants used by data migration to decide whether to update
-- the description or not
-- Rules currently are for extracted items:
-- Donot update the description for base language, update the description for other languages;
g_donot_update_description      CONSTANT VARCHAR2(25) := 'DONOT_UPDATE_DESCRIPTION';
g_update_description            CONSTANT VARCHAR2(25) := 'UPDATE_DESCRIPTION';

-- Global variables for updating the job details in icx_cat_r12_upgrade_job
-- These variables are used by upgrade program
g_upgrade_program               CONSTANT VARCHAR2(20) := 'UPGRADE';
g_icx_final_upg_program         CONSTANT VARCHAR2(20) := 'ICX-FINAL-UPG';
g_pre_upgrade_program           CONSTANT VARCHAR2(20) := 'PRE-UPGRADE';
g_data_exception_program        CONSTANT VARCHAR2(20) := 'DATA-EXCEPTION';
-- Child process job types
g_child_data_excptn_program     CONSTANT VARCHAR2(20) := 'CHILD-DATAEXPTN';
g_child_upg_bpa_program         CONSTANT VARCHAR2(20) := 'CHILD-BLANKET';
g_child_upg_quote_program       CONSTANT VARCHAR2(20) := 'CHILD-QUOTE';
g_child_upg_rt_program          CONSTANT VARCHAR2(20) := 'CHILD-REQTMPLTE';
g_child_upg_mi_program          CONSTANT VARCHAR2(20) := 'CHILD-MASTERITM';
-- Jobs submitted from ad-parallel workers
g_upg_podoc_program             CONSTANT VARCHAR2(20) := 'PODOC-UPG';
g_upg_rt_program                CONSTANT VARCHAR2(20) := 'REQTMPLTE-UPG';
g_upg_mi_program                CONSTANT VARCHAR2(20) := 'MASTERITM-UPG';
-- PO Pass1 and Final Upgrade jobs
g_po_existing_upg_program       CONSTANT VARCHAR2(20) := 'PO-EXISTING-UPG';
g_po_final_upg_program          CONSTANT VARCHAR2(20) := 'PO-FINAL-UPG';
g_current_program               VARCHAR2(20);
g_job_type                      VARCHAR2(20);
g_job_running_status            CONSTANT VARCHAR2(1) := 'R';
g_job_complete_status           CONSTANT VARCHAR2(1) := 'C';
g_job_failed_status             CONSTANT VARCHAR2(1) := 'F';
g_job_paused_status             CONSTANT VARCHAR2(1) := 'U';
g_job_current_status            VARCHAR2(1) := NULL;
g_job_number                    NUMBER;
g_job_complete_date             DATE    := NULL;
g_job_pdoi_update_date          DATE    := NULL;
g_job_pdoi_complete_date        DATE    := NULL;
g_job_bpa_complete_date         DATE    := NULL;
g_job_quote_complete_date       DATE    := NULL;
g_job_reqtmplt_complete_date    DATE    := NULL;
g_job_mi_complete_date          DATE    := NULL;

g_snap_shot_too_old     EXCEPTION;
PRAGMA EXCEPTION_INIT(g_snap_shot_too_old, -1555);

-- function to get the apps schema name
FUNCTION getAppsSchemaName
  RETURN VARCHAR2;

-- function to get the icx schema name
FUNCTION getIcxSchemaName
  RETURN VARCHAR2;

FUNCTION getModuleNameForDebug
(       p_pkg_name      IN      VARCHAR2        ,
        p_proc_name     IN      VARCHAR2
)
  RETURN VARCHAR2;

PROCEDURE logProcBegin
(       p_pkg_name      IN      VARCHAR2        ,
        p_proc_name     IN      VARCHAR2        ,
        p_log_string    IN      VARCHAR2
);

PROCEDURE logProcEnd
(       p_pkg_name      IN      VARCHAR2        ,
        p_proc_name     IN      VARCHAR2        ,
        p_log_string    IN      VARCHAR2
);

PROCEDURE logUnexpectedException
(       p_pkg_name      IN      VARCHAR2        ,
        p_proc_name     IN      VARCHAR2        ,
        p_log_string    IN      VARCHAR2
);

PROCEDURE logPOSessionGTData
(       p_key           IN      NUMBER
);

PROCEDURE logMtlItemBulkloadRecsData
(       p_request_id    IN      NUMBER
);

PROCEDURE logAndCommitSnapShotTooOld
(       p_pkg_name      IN      VARCHAR2        ,
        p_api_name      IN      VARCHAR2        ,
        p_err_string    IN      VARCHAR2
);

FUNCTION getTimeDiff
(       p_start         IN      DATE            ,
        p_end           IN      DATE
)
  RETURN NUMBER;

FUNCTION getTimeStats
(       p_start         IN      DATE            ,
        p_end           IN      DATE
)
  RETURN VARCHAR2;

--------------------------------------------------------------
--               Get PL/SQL Table element Start             --
--------------------------------------------------------------
FUNCTION getTableElement
(       p_table         IN DBMS_SQL.NUMBER_TABLE        ,
        p_index         IN BINARY_INTEGER
)
  RETURN VARCHAR2;

FUNCTION getTableElement
(       p_table         IN DBMS_SQL.VARCHAR2_TABLE      ,
        p_index         IN BINARY_INTEGER
)
  RETURN VARCHAR2;

FUNCTION getTableElement
(       p_table         IN DBMS_SQL.UROWID_TABLE        ,
        p_index         IN BINARY_INTEGER
)
  RETURN VARCHAR2;

FUNCTION getTableElement
(       p_table         IN DBMS_SQL.DATE_TABLE          ,
        p_index         IN BINARY_INTEGER
)
  RETURN VARCHAR2;

FUNCTION checkValueExistsInTable
(       p_table         IN      DBMS_SQL.NUMBER_TABLE   ,
        p_value         IN      NUMBER
)
  RETURN VARCHAR2;

--------------------------------------------------------------
--                 Get PL/SQL Table element End             --
--------------------------------------------------------------

FUNCTION getPOCategoryIdFromIp
(       p_category_id   IN      NUMBER
)
  RETURN NUMBER;

FUNCTION getNextSequenceForWhoColumns
  RETURN NUMBER;

PROCEDURE setBatchSize
(       p_batch_size    IN      NUMBER DEFAULT NULL
);

PROCEDURE setCommitParameter
(       p_commit        IN      VARCHAR2 := FND_API.G_FALSE
);

PROCEDURE setWhoColumns
(       p_request_id    IN      NUMBER
);

PROCEDURE setBaseLanguage;

PROCEDURE getPurchasingCategorySetInfo;

PROCEDURE getMIConcatSegmentClause;

FUNCTION getR12UpgradeJobNumber
  RETURN NUMBER;

--
-- Function
--        get_message
-- Purpose
--	   Returns the corresponding value of the mesage name after   --
--	   substituting it with the token                             --

FUNCTION get_message (p_message_name in VARCHAR2,
		      p_token_name in VARCHAR2,
		      p_token_value in VARCHAR2) return VARCHAR2;

-- function to check if the item is valid to be shown in the search results page
FUNCTION is_item_valid_for_search
(
  p_source_type IN VARCHAR2,
  p_po_line_id IN NUMBER,
  p_req_template_name IN VARCHAR2,
  p_req_template_line_num IN NUMBER,
  p_category_id IN NUMBER,
  p_org_id IN NUMBER
)
RETURN NUMBER;

-- function to check if the category is valid
FUNCTION is_category_valid
(
  p_category_id IN NUMBER
)
RETURN NUMBER;

-- function to check if the req template line is valid
FUNCTION is_req_template_line_valid
(
  p_org_id IN NUMBER,
  p_req_template_name	IN VARCHAR2,
  p_req_template_line_num IN NUMBER
)
RETURN NUMBER;

-- function to check if the blanket is valid
FUNCTION is_blanket_valid
(
  p_po_line_id IN NUMBER,p_org_id   IN NUMBER

)
RETURN NUMBER;

-- function to check if the quotation is valid
FUNCTION is_quotation_valid
(
  p_po_line_id IN NUMBER
)
RETURN NUMBER;

-- function to get the conversion rate from the from_currency to the to_currency
FUNCTION get_rate
(
  p_from_currency VARCHAR2,
  p_to_currency VARCHAR2,
  p_rate_date DATE,
  p_rate_type VARCHAR2
)
RETURN NUMBER;

-- function to convert the amount from the from_currency to the to_currency
FUNCTION convert_amount
(
  p_from_currency VARCHAR2,
  p_to_currency	VARCHAR2,
  p_conversion_date DATE,
  p_conversion_type VARCHAR2,
  p_conversion_rate NUMBER,
  p_amount NUMBER
)
RETURN NUMBER;

--bug 19289104
PROCEDURE delete_action_history(p_object_id  IN NUMBER);

END ICX_CAT_UTIL_PVT;

/
