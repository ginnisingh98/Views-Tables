--------------------------------------------------------
--  DDL for Package GMF_XLA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMF_XLA_PKG" AUTHID CURRENT_USER AS
/* $Header: GMFXLAPS.pls 120.3.12010000.1 2008/07/30 05:36:16 appldev ship $ */

  FUNCTION create_event
  (
      p_reference_no       IN           NUMBER
    , p_legal_entity_id    IN           NUMBER
    , p_ledger_id          IN           NUMBER
    , x_errbuf             OUT NOCOPY   VARCHAR2
  )
    RETURN NUMBER
  ;

  PROCEDURE update_extract_lines_table;
  PROCEDURE update_extract_headers_table;
  /* Bug 5668308: Added entity code as parameter to insert_into_xla_events_gt fn and
   * update_extract_gt procedures
   */
  FUNCTION insert_into_xla_events_gt (p_entity_code IN VARCHAR2) RETURN NUMBER;
  PROCEDURE update_extract_gt (
    p_what_to_update  IN VARCHAR2,
    p_entity_code     IN VARCHAR2
  );
  PROCEDURE merge_into_gtv;


  PROCEDURE preaccounting
   ( p_application_id       IN           NUMBER
   , p_ledger_id            IN           NUMBER
   , p_process_category     IN           VARCHAR2
   , p_end_date             IN           DATE
   , p_accounting_mode      IN           VARCHAR2
   , p_valuation_method     IN           VARCHAR2
   , p_security_id_int_1    IN           NUMBER
   , p_security_id_int_2    IN           NUMBER
   , p_security_id_int_3    IN           NUMBER
   , p_security_id_char_1   IN           VARCHAR2
   , p_security_id_char_2   IN           VARCHAR2
   , p_security_id_char_3   IN           VARCHAR2
   , p_report_request_id    IN           NUMBER
   );


  PROCEDURE extract
   ( p_application_id       IN           NUMBER
   , p_accounting_mode      IN           VARCHAR2
   );


  PROCEDURE postaccounting
   ( p_application_id       IN           NUMBER
   , p_ledger_id            IN           NUMBER
   , p_process_category     IN           VARCHAR2
   , p_end_date             IN           DATE
   , p_accounting_mode      IN           VARCHAR2
   , p_valuation_method     IN           VARCHAR2
   , p_security_id_int_1    IN           NUMBER
   , p_security_id_int_2    IN           NUMBER
   , p_security_id_int_3    IN           NUMBER
   , p_security_id_char_1   IN           VARCHAR2
   , p_security_id_char_2   IN           VARCHAR2
   , p_security_id_char_3   IN           VARCHAR2
   , p_report_request_id    IN           NUMBER
   );


  PROCEDURE postprocessing
   ( p_application_id       IN           NUMBER
   , p_accounting_mode      IN           VARCHAR2
   );

 PROCEDURE process_inv_txns(p_event VARCHAR2);  -- Inventory Txns
 PROCEDURE process_pur_txns(p_event VARCHAR2);  -- Purchasing Txns
 PROCEDURE process_pm_txns(p_event VARCHAR2);   -- Product Mgt Txns
 PROCEDURE process_om_txns(p_event VARCHAR2);   -- Order Mgt Txns
 PROCEDURE process_rval_txns(p_event VARCHAR2); -- Cost Reval Txns

 PROCEDURE DRILLDOWN
 (
   p_application_id      IN            INTEGER
 , p_ledger_id           IN            INTEGER
 , p_legal_entity_id     IN            INTEGER DEFAULT NULL
 , p_entity_code         IN            VARCHAR2
 , p_event_class_code    IN            VARCHAR2
 , p_event_type_code     IN            VARCHAR2
 , p_source_id_int_1     IN            INTEGER DEFAULT NULL
 , p_source_id_int_2     IN            INTEGER DEFAULT NULL
 , p_source_id_int_3     IN            INTEGER DEFAULT NULL
 , p_source_id_int_4     IN            INTEGER DEFAULT NULL
 , p_source_id_char_1    IN            VARCHAR2 DEFAULT NULL
 , p_source_id_char_2    IN            VARCHAR2 DEFAULT NULL
 , p_source_id_char_3    IN            VARCHAR2 DEFAULT NULL
 , p_source_id_char_4    IN            VARCHAR2 DEFAULT NULL
 , p_security_id_int_1   IN            INTEGER DEFAULT NULL
 , p_security_id_int_2   IN            INTEGER DEFAULT NULL
 , p_security_id_int_3   IN            INTEGER DEFAULT NULL
 , p_security_id_char_1  IN            VARCHAR2 DEFAULT NULL
 , p_security_id_char_2  IN            VARCHAR2 DEFAULT NULL
 , p_security_id_char_3  IN            VARCHAR2 DEFAULT NULL
 , p_valuation_method    IN            VARCHAR2 DEFAULT NULL
 , p_user_interface_type IN OUT NOCOPY VARCHAR2
 , p_function_name       IN OUT NOCOPY VARCHAR2
 , p_parameters          IN OUT NOCOPY VARCHAR2
 );

END GMF_XLA_PKG;

/
