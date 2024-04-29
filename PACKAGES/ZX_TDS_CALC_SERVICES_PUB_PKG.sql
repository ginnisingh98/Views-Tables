--------------------------------------------------------
--  DDL for Package ZX_TDS_CALC_SERVICES_PUB_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_TDS_CALC_SERVICES_PUB_PKG" AUTHID CURRENT_USER AS
/* $Header: zxdwtxcalsrvpubs.pls 120.48.12010000.3 2010/02/12 11:54:25 msakalab ship $ */


 /* ======================================================================*
  | Memory Structures                                                     |
  * ======================================================================*/

 TYPE transaction_rec_type IS RECORD
     (SUBSCRIBER_PARTY_ID                NUMBER,
      APPLICATION_ID                     NUMBER,
      ENTITY_CODE                        VARCHAR2(30),
      EVENT_CLASS_CODE                   VARCHAR2(30),
      EVENT_TYPE_CODE                    VARCHAR2(30),
      TRANSACTION_ID			 NUMBER,
      TAX_EVENT_CLASS_CODE               VARCHAR2(30),
      TAX_EVENT_TYPE_CODE                VARCHAR2(30),
      SUB_PARTY_TAX_PROF_ID              NUMBER
     );

 TYPE event_class_rec_type IS RECORD
     (SUB_PARTY_TAX_PROF_ID             NUMBER,
      APPLICATION_ID                    NUMBER,
      ENTITY_CODE                       VARCHAR2(30),
      EVENT_CLASS_CODE                  VARCHAR2(30),
      TAX_EVENT_CLASS_CODE              VARCHAR2(30),
      Det_Factor_Templ_Code		VARCHAR2(80),
      TAX_LINES_SUM_TEMPLATE		VARCHAR2(80),
      REC_TAX_LINES_SUM_TEMPLATE	VARCHAR2(80),
      NON_REC_TAX_LINES_SUM_TEMPLATE	VARCHAR2(80),
      Rounding_Level_Code			VARCHAR2(30),
      ROUNDING_LEVEL_HIER1		VARCHAR2(30),
      ROUNDING_LEVEL_HIER2		VARCHAR2(30),
      ROUNDING_LEVEL_HIER3		VARCHAR2(30),
      ROUNDING_LEVEL_HIER4		VARCHAR2(30),
      ROUNDING_LEVEL_HIER5		VARCHAR2(30),
      Allow_Manual_Lin_Recalc_Flag		VARCHAR2(30),
      Allow_Manual_Lines_Flag		VARCHAR2(30),
      Allow_Override_Flag			VARCHAR2(30),
      SHIP_TO_PARTY_SOURCE               VARCHAR2(80),
      SHIP_FROM_PARTY_SOURCE             VARCHAR2(80),
      POA_PARTY_SOURCE                   VARCHAR2(80),
      POO_PARTY_SOURCE                   VARCHAR2(80),
      PAYING_PARTY_SOURCE                VARCHAR2(80),
      OWN_HQ_PARTY_SOURCE                VARCHAR2(80),
      TRAD_HQ_PARTY_SOURCE               VARCHAR2(80),
      POI_PARTY_SOURCE                   VARCHAR2(80),
      POD_PARTY_SOURCE                   VARCHAR2(80),
      BILL_TO_PARTY_SOURCE               VARCHAR2(80),
      BILL_FROM_PARTY_SOURCE             VARCHAR2(80),
      TTL_TRNS_PARTY_SOURCE              VARCHAR2(80),
      RECORD_FLAG                        VARCHAR2(1),
      UPDATE_FLAG                        VARCHAR2(1),
      CREATE_FLAG                        VARCHAR2(1),
      CANCEL_DELETE_FLAG                 VARCHAR2(1),
      OVERRIDE_LEVEL                     VARCHAR2(30)
     );

 TYPE detail_tax_lines_tbl_type IS TABLE OF zx_detail_tax_lines_gt%ROWTYPE
   INDEX BY BINARY_INTEGER;

 TYPE sum_tax_line_tbl_type IS TABLE OF zx_lines_summary%ROWTYPE
   INDEX BY BINARY_INTEGER;

 TYPE tax_regime_rec_type IS RECORD
     (TAX_REGIME_PRECEDENCE		NUMBER,
      TAX_REGIME_ID			NUMBER,
      TAX_PROVIDER_ID 		        NUMBER,
      PARENT_REGIME_ID                  NUMBER
     );

  TYPE tax_regime_tbl_type IS TABLE OF tax_regime_rec_type
    INDEX BY BINARY_INTEGER;


  TYPE detail_tax_regime_rec_type IS RECORD
     (TRX_LINE_INDEX                    BINARY_INTEGER,
      TAX_REGIME_PRECEDENCE		NUMBER,
      TAX_REGIME_ID			NUMBER
     );

  TYPE detail_tax_regime_tbl_type IS TABLE OF detail_tax_regime_rec_type
    INDEX BY BINARY_INTEGER;

  TYPE subscriber_rec_type IS RECORD
     (SUB_PARTY_TAX_PROF_ID              NUMBER,
       TAX_REGIME_ID			 NUMBER,
      OWN_SUB_PARTY_TAX_PROF_ID          NUMBER,
      SUBSCRIPTION_LEVEL                 NUMBER
     );

 TYPE subscriber_tbl_type IS TABLE OF subscriber_rec_type
   INDEX BY BINARY_INTEGER;


 /* ======================================================================*
  |  Structures for caching                                               |
  * ======================================================================*/


 -- Tax lines Cache

 TYPE trx_tax_info_rec IS RECORD (
 tax_info		ZX_LINES%ROWTYPE
  );

 TYPE trx_tax_info_rec_tbl IS TABLE OF trx_tax_info_rec
   INDEX BY BINARY_INTEGER;

 -- Template evaluation cache
 TYPE trx_line_cond_grp_eval_rec IS RECORD(
	det_factor_templ_code  zx_det_factor_templ_b.det_factor_templ_code%TYPE,
        trx_line_index         BINARY_INTEGER,
        application_id         zx_lines.application_id%TYPE,
        tax_event_class_code   zx_lines.tax_event_class_code%TYPE,
	condition_group_code   zx_condition_groups_b.condition_group_code%TYPE,
        result                 boolean);

 TYPE trx_line_cond_grp_eval_tbl IS TABLE OF trx_line_cond_grp_eval_rec
   INDEX BY BINARY_INTEGER;

 -- Jurisdiction information cache
 TYPE zx_jurisdiction_info_rec IS RECORD (
	location_id	hz_locations.location_id%TYPE,
	location_type	varchar2(100),
	application_id	number,
	event_class	varchar2(30),
	tax		zx_taxes_b.tax%TYPE,
	tax_regime_code	zx_regimes_b.tax_regime_code%TYPE,
	jurisdiction_id	zx_jurisdictions_b.tax_jurisdiction_id%TYPE);

 TYPE zx_jurisdiction_info_cache IS TABLE OF zx_jurisdiction_info_rec
   INDEX BY BINARY_INTEGER;

 -- Fiscal classification info cache
 --TYPE classification_rec IS TABLE OF VARCHAR2(30);

 -- Tax Regime information cache
 TYPE zx_regime_info_cache IS TABLE OF zx_regimes_b%ROWTYPE
   INDEX BY BINARY_INTEGER;

 -- TSRM numeric parameter cache
 TYPE tsrm_num_value_tbl IS TABLE OF zx_conditions.numeric_value%TYPE
   INDEX BY BINARY_INTEGER;

 -- TSRM  alphanumeric parameter and trx alphanumeric value cache
 TYPE tsrm_alphanum_value_tbl IS TABLE OF zx_conditions.alphanumeric_value%TYPE
   INDEX BY BINARY_INTEGER;

 -- Reporting code info Cache for Legal Message Columns
 TYPE zx_rep_code_info_rec IS RECORD (
    result_id ZX_PROCESS_RESULTS.RESULT_ID%TYPE,
    reporting_code_id ZX_REPORTING_CODES_B.REPORTING_CODE_ID%TYPE
  );

 TYPE zx_rep_code_tbl IS TABLE OF zx_rep_code_info_rec
   INDEX BY BINARY_INTEGER;

 /* ======================================================================*
  |  Global Structures                                                    |
  * ======================================================================*/

 g_detail_tax_lines_tbl		      detail_tax_lines_tbl_type;
 g_check_cond_grp_tbl		        trx_line_cond_grp_eval_tbl;
 g_fsc_tbl			                ZX_TCM_CONTROL_PKG.zx_fsc_class_info_cache;
 g_tsrm_num_value_tbl		        tsrm_num_value_tbl;
 g_tsrm_alphanum_value_tbl	    tsrm_alphanum_value_tbl;
 g_trx_alphanum_value_tbl       tsrm_alphanum_value_tbl;
 g_msg_context_info_rec         ZX_API_PUB.CONTEXT_INFO_REC_TYPE;
 g_zx_rep_code_tbl              zx_rep_code_tbl;
/* ======================================================================*
 |  Global Constants                                                     |
 * ======================================================================*/

 g_lines_per_commit            CONSTANT NUMBER       :=  1000;

 -- Tax Hold Code and Tax Hold Release Code
 g_tax_variance_hold           CONSTANT VARCHAR2(30) := 'TAX VARIANCE';
 g_tax_amt_range_hold          CONSTANT VARCHAR2(30) := 'TAX AMOUNT RANGE';
 g_tax_variance_corrected      CONSTANT VARCHAR2(30) := 'TAX VARIANCE CORRECTED';
 g_tax_amt_range_corrected     CONSTANT VARCHAR2(30) := 'TAX AMOUNT RANGE CORRECTED';

 -- numeric value for the tax hold_code
 g_tax_variance_hold_val           CONSTANT  NUMBER := 1;
 g_tax_amt_range_hold_val          CONSTANT  NUMBER := 2;
 g_tax_variance_corrected_val      CONSTANT NUMBER := 1;
 g_tax_amt_range_corrected_val     CONSTANT  NUMBER := 2;


/* ======================================================================*
  |  Global Variable                                                     |
  * =====================================================================*/

 g_max_tax_line_number		zx_lines.tax_line_number%TYPE;
 g_trx_lines_counter		NUMBER;

 g_rounding_level		ZX_PARTY_TAX_PROFILE.ROUNDING_LEVEL_CODE%TYPE;
 g_rounding_rule                ZX_PARTY_TAX_PROFILE.ROUNDING_RULE_CODE%TYPE;
 g_rnd_lvl_party_tax_prof_id	ZX_PARTY_TAX_PROFILE.PARTY_TAX_PROFILE_ID%TYPE;
 g_rounding_lvl_party_type      ZX_LINES.ROUNDING_LVL_PARTY_TYPE%TYPE;
 g_ln_action_cancel_exist_flg   VARCHAR2(1);
 g_ln_action_discard_exist_flg  VARCHAR2(1);
 g_ln_action_nochange_exist_flg  VARCHAR2(1);
 --Bug 8736358
 g_ln_action_update_exist_flg  VARCHAR2(1);
 g_process_copy_and_create_flg  VARCHAR2(1);
 g_process_for_appl_flg         ZX_PARTY_TAX_PROFILE.PROCESS_FOR_APPLICABILITY_FLAG%TYPE;
 g_reference_doc_exist_flg      VARCHAR2(1);

 -- added for bug fix 5417887
 g_ctrl_total_line_tx_amt_flg   VARCHAR2(1);
 g_ctrl_total_hdr_tx_amt_flg    VARCHAR2(1);

 -- added for bug 5684123
 g_overridden_tax_ln_exist_flg  VARCHAR2(1);

/* ======================================================================*
  |  Public Procedures                                                   |
  * =====================================================================*/
PROCEDURE  get_tax_regimes (
  p_trx_line_index	    IN		    BINARY_INTEGER,
  p_event_class_rec	    IN  OUT NOCOPY  zx_api_pub.event_class_rec_type,
  x_return_status	    OUT NOCOPY      VARCHAR2);

PROCEDURE  calculate_tax (
  p_trx_line_index	    IN	            BINARY_INTEGER,
  p_event_class_rec	    IN  OUT NOCOPY  zx_api_pub.event_class_rec_type,
  x_return_status           OUT NOCOPY      VARCHAR2);

PROCEDURE  override_detail_tax_lines (
  p_trx_line_index	     IN	    	     BINARY_INTEGER,
  p_event_class_rec	     IN  OUT NOCOPY  zx_api_pub.event_class_rec_type,
  x_return_status            OUT NOCOPY      VARCHAR2);

PROCEDURE  tax_line_determination (
  p_event_class_rec	     IN  OUT NOCOPY  zx_api_pub.event_class_rec_type,
  x_return_status            OUT NOCOPY      VARCHAR2);

PROCEDURE  override_summary_tax_lines (
  p_trx_line_index	     IN		     BINARY_INTEGER,
  p_event_class_rec	     IN  OUT NOCOPY  zx_api_pub.event_class_rec_type,
  x_return_status            OUT NOCOPY      VARCHAR2 );

PROCEDURE prorate_imported_sum_tax_lines (
 p_event_class_rec        IN 	       zx_api_pub.event_class_rec_type,
 x_return_status          OUT NOCOPY   VARCHAR2);

PROCEDURE  calculate_tax_for_import (
 p_trx_line_index	  IN	       BINARY_INTEGER,
 p_event_class_rec	  IN           zx_api_pub.event_class_rec_type,
 x_return_status          OUT NOCOPY   VARCHAR2);

PROCEDURE validate_document_for_tax (
  x_return_status	     OUT NOCOPY	    VARCHAR2);

PROCEDURE reverse_document (
  p_event_class_rec  IN         ZX_API_PUB.EVENT_CLASS_REC_TYPE,
  x_return_status    OUT NOCOPY VARCHAR2 );

PROCEDURE dump_detail_tax_lines_into_gt (
 p_detail_tax_lines_tbl	  IN OUT NOCOPY		detail_tax_lines_tbl_type,
 x_return_status	     OUT NOCOPY		VARCHAR2);

PROCEDURE dump_detail_tax_lines_into_gt (
 x_return_status	     OUT NOCOPY		VARCHAR2);

PROCEDURE update_exchange_rate (
  p_event_class_rec      	IN          ZX_API_PUB.EVENT_CLASS_REC_TYPE,
  p_ledger_id			IN          NUMBER,
  p_currency_conversion_rate    IN          NUMBER,
  p_currency_conversion_type    IN          VARCHAR2,
  p_currency_conversion_date    IN          DATE,
  x_return_status        	OUT NOCOPY  VARCHAR2 );

PROCEDURE initialize (
  p_event_class_rec        IN ZX_API_PUB.event_class_rec_type,
  p_init_level             IN VARCHAR2,
  x_return_status          OUT NOCOPY    VARCHAR2 );

PROCEDURE initialize;

PROCEDURE get_process_for_appl_flg (
  p_tax_prof_id   IN         NUMBER,
  x_return_status OUT NOCOPY VARCHAR2 );

FUNCTION get_rep_code_id(
  p_result_id            IN ZX_PROCESS_RESULTS.RESULT_ID%TYPE,
  p_date                 IN ZX_LINES.TRX_DATE%TYPE
) RETURN ZX_REPORTING_CODES_B.REPORTING_CODE_ID%TYPE;

END  ZX_TDS_CALC_SERVICES_PUB_PKG;


/
