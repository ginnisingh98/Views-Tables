--------------------------------------------------------
--  DDL for Package QP_BULK_LOADER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_BULK_LOADER_PUB" AUTHID CURRENT_USER AS
/* $Header: QPXVBLKS.pls 120.6.12010000.1 2008/07/28 11:58:13 appldev ship $ */

   TYPE num_type      IS TABLE OF Number         INDEX BY BINARY_INTEGER;
   TYPE char_type     IS TABLE OF Varchar2(1)    INDEX BY BINARY_INTEGER;
   TYPE char30_type   IS TABLE OF Varchar2(30)   INDEX BY BINARY_INTEGER;
   TYPE char2_type    IS TABLE OF Varchar2(2)    INDEX BY BINARY_INTEGER;
   TYPE char240_type  IS TABLE OF Varchar2(240)  INDEX BY BINARY_INTEGER;
   TYPE char4_type    IS TABLE OF Varchar2(4)    INDEX BY BINARY_INTEGER;
   TYPE char3_type    IS TABLE OF Varchar2(3)    INDEX BY BINARY_INTEGER;
   TYPE char50_type   IS TABLE OF Varchar2(50)   INDEX BY BINARY_INTEGER;
   TYPE char2000_type IS TABLE OF Varchar2(2000) INDEX BY BINARY_INTEGER;
   TYPE char10_type   IS TABLE OF Varchar2(10)   INDEX BY BINARY_INTEGER;
   TYPE real_type     IS TABLE OF Number(32,10)  INDEX BY BINARY_INTEGER;
   TYPE date_type     IS TABLE OF Date           INDEX BY BINARY_INTEGER;

TYPE HEADER_REC_TYPE IS RECORD
(
 list_header_id                           num_type,
 creation_date                            date_type,
 created_by                               num_type,
 last_update_date                         date_type,
 last_updated_by                          num_type,
 last_update_login                        num_type,
 program_application_id                   num_type,
 program_id                               num_type,
 program_update_date                      date_type,
 request_id                               num_type,
 list_type_code                           char30_type,
 start_date_active                        char30_type,
 end_date_active                          char30_type,
 source_lang                              char4_type,
 automatic_flag                           char_type,
 name                                     char240_type,
 description                              char2000_type,
 currency_code                            char30_type,
 version_no                               char30_type,
 rounding_factor                          num_type,
 ship_method_code                         char30_type,
 freight_terms_code                       char30_type,
 terms_id                                 num_type,
 comments                                 char2000_type,
 discount_lines_flag                      char_type,
 gsa_indicator                            char_type,
 prorate_flag                             char30_type,
 source_system_code                       char30_type,
 ask_for_flag                             char_type,
 active_flag                              char_type,
 parent_list_header_id                    num_type,
 active_date_first_type                   char30_type,
 start_date_active_first                  date_type,
 end_date_active_first                    date_type,
 active_date_second_type                  char30_type,
 start_date_active_second                 date_type,
 end_date_active_second                   date_type,
 context                                  char30_type,
 attribute1                               char240_type,
 attribute2                               char240_type,
 attribute3                               char240_type,
 attribute4                               char240_type,
 attribute5                               char240_type,
 attribute6                               char240_type,
 attribute7                               char240_type,
 attribute8                               char240_type,
 attribute9                               char240_type,
 attribute10                              char240_type,
 attribute11                              char240_type,
 attribute12                              char240_type,
 attribute13                              char240_type,
 attribute14                              char240_type,
 attribute15                              char240_type,
 language                                 char4_type,
 process_id                               num_type,
 process_type                             char30_type,
 interface_action_code                    char30_type,
 lock_flag                                char2_type,
 process_flag                             char2_type,
 delete_flag                              char2_type,
 process_status_flag                      char2_type,
 mobile_download                          char_type,
 currency_header_id                       num_type,
 pte_code                                 char30_type,
 list_source_code                         char30_type,
 orig_sys_header_ref                      char50_type,
 orig_org_id                              num_type,
 global_flag                              char_type
);


TYPE LINE_REC_TYPE IS RECORD
(
 list_line_id                             num_type
 ,creation_date                            date_type
 ,created_by                               num_type
 ,last_update_date                         date_type
 ,last_updated_by                          num_type
 ,last_update_login                        num_type
 ,program_application_id                   num_type
 ,program_id                               num_type
 ,program_update_date                      date_type
 ,request_id                               num_type
 ,list_header_id                           num_type
 ,list_line_type_code                      char30_type
 ,start_date_active                        date_type
 ,end_date_active                          date_type
 ,automatic_flag                           char_type
 ,modifier_level_code                      char30_type
 ,price_by_formula_id                      num_type
 ,list_price                               num_type
 ,list_price_uom_code                      char3_type
 ,primary_uom_flag                         char_type
 ,inventory_item_id                        num_type
 ,organization_id                          num_type
 ,related_item_id                          num_type
 ,relationship_type_id                     num_type
 ,substitution_context                     char30_type
 ,substitution_attribute                   char30_type
 ,substitution_value                       char240_type
 ,revision                                 char50_type
 ,revision_date                            date_type
 ,revision_reason_code                     char30_type
 ,price_break_type_code                    char30_type
 ,percent_price                            num_type
 ,number_effective_periods                 num_type
 ,effective_period_uom                     char3_type
 ,arithmetic_operator                      char30_type
 ,operand                                  real_type
 ,override_flag                            char_type
 ,print_on_invoice_flag                    char_type
 ,rebate_transaction_type_code             char30_type
 ,base_qty                                 num_type
 ,base_uom_code                            char3_type
 ,accrual_qty                              num_type
 ,accrual_uom_code                         char3_type
 ,estim_accrual_rate                       num_type
 ,process_id                               num_type
 ,process_type                             char30_type
 ,interface_action_code                    char30_type
 ,lock_flag                                char2_type
 ,process_flag                             char2_type
 ,delete_flag                              char2_type
 ,process_status_flag                      char2_type
 ,comments                                 char2000_type
 ,generate_using_formula_id                num_type
 ,reprice_flag                             char_type
 ,list_line_no                             char30_type
 ,estim_gl_value                           num_type
 ,benefit_price_list_line_id               num_type
 ,expiration_period_start_date             date_type
 ,number_expiration_periods                num_type
 ,expiration_period_uom                    char3_type
 ,expiration_date                          date_type
 ,accrual_flag                             char_type
 ,pricing_phase_id                         num_type
 ,pricing_group_sequence                   num_type
 ,incompatibility_grp_code                 char30_type
 ,product_precedence                       num_type
 ,proration_type_code                      char30_type
 ,accrual_conversion_rate                  num_type
 ,benefit_qty                              num_type
 ,benefit_uom_code                         char3_type
 ,recurring_flag                           char_type
 ,benefit_limit                            num_type
 ,charge_type_code                         char30_type
 ,charge_subtype_code                      char30_type
 ,include_on_returns_flag                  char_type
 ,qualification_ind                        num_type
 ,context                                  char30_type
 ,attribute1                               char240_type
 ,attribute2                               char240_type
 ,attribute3                               char240_type
 ,attribute4                               char240_type
 ,attribute5                               char240_type
 ,attribute6                               char240_type
 ,attribute7                               char240_type
 ,attribute8                               char240_type
 ,attribute9                               char240_type
 ,attribute10                              char240_type
 ,attribute11                              char240_type
 ,attribute12                              char240_type
 ,attribute13                              char240_type
 ,attribute14                              char240_type
 ,attribute15                              char240_type
 ,rltd_modifier_grp_no                     num_type
 ,rltd_modifier_grp_type                   char30_type
 ,price_break_header_ref                   char50_type
 ,pricing_phase_name                       char240_type
 ,recurring_value                          num_type
 ,net_amount_flag                          char_type
 ,price_by_formula                         char50_type
 ,generate_using_formula                   char50_type
 ,attribute_status                         char50_type
 ,orig_sys_line_ref                        char50_type
 ,orig_sys_header_ref                      char50_type
 --Bug#5359974 RAVI
 ,continuous_price_break_flag              char_type
);

TYPE PRICING_ATTR_REC_TYPE IS RECORD
   (
    pricing_attribute_id                     num_type
    ,creation_date                      date_type
    ,created_by                               num_type
    ,last_update_date               date_type
    ,last_update_by                     num_type
    ,last_update_login                   num_type
    ,program_application_id                   num_type
    ,program_id                               num_type
    ,program_update_date                     date_type
    ,request_id                               num_type
    ,list_line_id                             num_type
    ,excluder_flag                            char_type
    ,accumulate_flag                          char_type
    ,product_attribute_context                char30_type
    ,product_attribute                            char30_type
    ,product_attr_value                       char240_type
    ,product_uom_code                         char3_type
    ,pricing_attribute_context                char30_type
    ,pricing_attribute                        char30_type
    ,pricing_attr_value_from                  char240_type
    ,pricing_attr_value_to                    char240_type
    ,attribute_grouping_no                    num_type
    ,product_attribute_datatype               char30_type
    ,pricing_attribute_datatype               char30_type
    ,comparison_operator_code                 char30_type
    ,list_header_id                           num_type
    ,pricing_phase_id                         num_type
    ,qualification_ind                        num_type
    ,pricing_attr_value_from_number           num_type
    ,pricing_attr_value_to_number             num_type
    ,context                                  char30_type
    ,attribute1                               char240_type
    ,attribute2                               char240_type
    ,attribute3                               char240_type
    ,attribute4                               char240_type
    ,attribute5                               char240_type
    ,attribute6                               char240_type
    ,attribute7                               char240_type
    ,attribute8                               char240_type
    ,attribute9                               char240_type
    ,attribute10                              char240_type
    ,attribute11                              char240_type
    ,attribute12                              char240_type
    ,attribute13                              char240_type
    ,attribute14                              char240_type
    ,attribute15                              char240_type
    ,process_id                               num_type
    ,process_type                             char30_type
    ,interface_action_code                    char30_type
    ,lock_flag                                char2_type
    ,process_flag                             char2_type
    ,delete_flag                              char2_type
    ,process_status_flag                      char2_type
    ,price_list_line_index                    num_type
    ,list_line_no                             char30_type
    ,orig_sys_pricing_attr_ref                char50_type
    ,product_attr_code                        char50_type
    ,product_attr_val_disp                    char50_type
    ,pricing_attr_code                        char50_type
    ,pricing_attr_value_from_disp             char50_type
    ,pricing_attr_value_to_disp               char50_type
    ,attribute_status                         char50_type
    ,orig_sys_line_ref                        char50_type
    ,orig_sys_header_ref                      char50_type
    );

TYPE QUALIFIER_REC_TYPE IS RECORD
   (
    qualifier_id                             num_type
    ,creation_date                            date_type
    ,created_by                               num_type
    ,last_update_date                         date_type
    ,last_update_by                           num_type
    ,request_id                               num_type
    ,program_application_id                   num_type
    ,program_id                               num_type
    ,program_update_date                      date_type
    ,last_update_login                        num_type
    ,qualifier_grouping_no                    num_type
    ,qualifier_context                        char30_type
    ,qualifier_attribute                      char30_type
    ,qualifier_attr_value                     char240_type
    ,qualifier_attr_value_to                  char240_type
    ,qualifier_datatype                       char10_type
    ,qualifier_precedence                     num_type
    ,comparison_operator_code                 char30_type
    ,excluder_flag                            char_type
    ,start_date_active                        date_type
    ,end_date_active                          date_type
    ,list_header_id                           num_type
    ,list_line_id                             num_type
    ,qualifier_rule_id                        num_type
    ,created_from_rule_id                     num_type
    ,active_flag                              char_type
    ,list_type_code                           char30_type
    ,qual_attr_value_from_number              num_type
    ,qual_attr_value_to_number                num_type
    ,qualifier_group_cnt                      num_type
    ,header_quals_exist_flag                  char_type
    ,context                                  char30_type
    ,attribute1                               char240_type
    ,attribute2                               char240_type
    ,attribute3                               char240_type
    ,attribute4                               char240_type
    ,attribute5                               char240_type
    ,attribute6                               char240_type
    ,attribute7                               char240_type
    ,attribute8                               char240_type
    ,attribute9                               char240_type
    ,attribute10                              char240_type
    ,attribute11                              char240_type
    ,attribute12                              char240_type
    ,attribute13                              char240_type
    ,attribute14                              char240_type
    ,attribute15                              char240_type
    ,process_id                               num_type
    ,process_type                             char30_type
    ,interface_action_code                    char30_type
    ,lock_flag                                char2_type
    ,process_flag                             char2_type
    ,delete_flag                              char2_type
    ,process_status_flag                      char2_type
    ,list_line_no                             char30_type
    ,ORIG_SYS_QUALIFIER_REF                   char50_type
    ,CREATED_FROM_RULE                        char50_type
    ,QUALIFIER_RULE                           char50_type
    ,QUALIFIER_ATTRIBUTE_CODE                 char50_type
    ,QUALIFIER_ATTR_VALUE_CODE                char50_type
    ,QUALIFIER_ATTR_VALUE_TO_CODE             char50_type
    ,ATTRIBUTE_STATUS                         char50_type
    ,ORIG_SYS_HEADER_REF                      char50_type
    ,orig_sys_line_ref                        char50_type
    ,QUALIFY_HIER_DESCENDENTS_FLAG            char_type
    );

TYPE thread_info_rec_type IS RECORD
   ( request_id        NUMBER
     ,total_lines      NUMBER:=0
   );

TYPE thread_info_tbl_type IS TABLE OF thread_info_rec_type INDEX BY BINARY_INTEGER;

G_THREAD_INFO_TABLE  thread_info_tbl_type;

G_INS_HEADER_REC  header_rec_type;
G_UDT_HEADER_REC  header_rec_type;

G_INS_LINE_REC line_rec_type;
G_UDT_LINE_REC line_rec_type;
G_UDT_LINE_REC_OLD line_rec_type; -- 6028305
G_INS_QUALIFIER_REC qualifier_rec_type;
G_UDT_QUALIFIER_REC qualifier_rec_type;
G_INS_PRICING_ATTR_REC pricing_attr_rec_type;
G_UDT_PRICING_ATTR_REC pricing_attr_rec_type;

G_QP_STATUS VARCHAR2(1):=NULL;
G_QP_DEBUG  VARCHAR2(1):='N';
G_QP_BATCH_SIZE NUMBER;
-- ENH duplicate line check flag RAVI
G_QP_ENABLE_DUP_LINE_CHECK  VARCHAR2(1):='Y';


   --ENH Update Functionality START RAVI
   /**
   During update the null columns in interface tables are populated from the
   qp tables. If the column is to be updated with null value then the following
   constants should be entered in the interface columns.
   **/
   G_NULL_DATE   CONSTANT DATE := to_date('01/01/1001', 'MM/DD/YYYY');
   G_NULL_CHAR   CONSTANT VARCHAR2(1) := 'Z';
   G_NULL_NUMBER CONSTANT NUMBER := 100010001000100010001000;

FUNCTION GET_NULL_DATE   RETURN DATE;
FUNCTION GET_NULL_CHAR   RETURN VARCHAR2;
FUNCTION GET_NULL_NUMBER RETURN NUMBER;

   --ENH Update Functionality END RAVI


-- ENH duplicate line check flag RAVI
PROCEDURE LOAD_PRICING_DATA
(
  err_buff     OUT NOCOPY  VARCHAR2
 ,retcode      OUT NOCOPY  NUMBER
 ,p_entity                 VARCHAR2
 ,p_entity_name		   VARCHAR2
 ,p_process_id	           NUMBER
 ,p_process_type           VARCHAR2
 ,p_process_parent	   VARCHAR2 DEFAULT 'Y'
 ,p_no_of_threads	   NUMBER   DEFAULT 1
 ,p_spawned_request	   VARCHAR2 DEFAULT 'N'
 ,p_request_id             NUMBER   DEFAULT NULL
 ,p_debug_on		   VARCHAR2
 ,p_enable_dup_ln_check		   VARCHAR2
);

PROCEDURE LOAD_LISTS
 (
        err_buff           OUT NOCOPY   VARCHAR2
	,retcode           OUT NOCOPY   NUMBER
	,p_entity_name                  VARCHAR2
	,p_process_id                   NUMBER
	,p_process_type                 VARCHAR2
	,p_process_parent               VARCHAR2
	,p_no_of_threads                NUMBER
	,p_spawned_request              VARCHAR2
	,p_request_id                   NUMBER   );

PROCEDURE PROCESS_HEADER
             (p_request_id   NUMBER);

PROCEDURE PROCESS_QUALIFIER
              (p_request_id   NUMBER);

PROCEDURE PROCESS_LINE
          (p_request_id NUMBER,
          p_process_parent varchar2); -- 6028305

PROCEDURE PROCESS_PRICING_ATTR
          (p_request_id NUMBER,
           p_process_parent varchar2); -- 6028305

PROCEDURE POST_CLEANUP
          (p_request_id NUMBER);

PROCEDURE POST_CLEANUP_LINE
          (p_request_id NUMBER);

PROCEDURE VALIDATE_LINES
          (p_request_id NUMBER);

PROCEDURE Delete_errored_records_parents
          (p_request_id NUMBER);

PROCEDURE ERRORS_TO_OUTPUT
          (p_request_id NUMBER);

PROCEDURE Purge
          (p_request_id NUMBER);

FUNCTION Get_QP_Status RETURN VARCHAR2;

PROCEDURE write_log
	 (log_text VARCHAR2);

PROCEDURE CLEAN_UP_CODE
          (l_request_id NUMBER);

END QP_BULK_LOADER_PUB;

/
