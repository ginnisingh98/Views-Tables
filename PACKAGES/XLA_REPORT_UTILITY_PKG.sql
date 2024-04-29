--------------------------------------------------------
--  DDL for Package XLA_REPORT_UTILITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_REPORT_UTILITY_PKG" AUTHID CURRENT_USER AS
-- $Header: xlarputl.pkh 120.3.12010000.4 2009/04/17 09:08:59 svellani ship $
/*===========================================================================+
|  Copyright (c) 2003 Oracle Corporation BelmFont, California, USA           |
|                          ALL rights reserved.                              |
+============================================================================+
| FILENAME                                                                   |
|    xlarputl.pkh                                                            |
|                                                                            |
| PACKAGE NAME                                                               |
|     xla_report_utility_pkg                                                 |
|                                                                            |
| DESCRIPTION                                                                |
|     Package specification. This provides routines that support reports     |
|                                                                            |
| HISTORY                                                                    |
|     04/15/2005  V. Kumar        Created                                    |
|     12/23/2005  V. Kumar        Added function get_transaction_id          |
|     06/23/2006  V. Kumar        Added function get_conc_segments           |
|     02/16/2009  N. K. Surana    Overloading function get_transaction_id    |
|                                 to support more than 50 event classes per  |
|                                 application id required for FSAH           |
+===========================================================================*/

PROCEDURE get_acct_qualifier_segs
       (p_coa_id                 IN         NUMBER
       ,p_balance_segment        OUT NOCOPY VARCHAR2
       ,p_account_segment        OUT NOCOPY VARCHAR2
       ,p_cost_center_segment    OUT NOCOPY VARCHAR2
       ,p_management_segment     OUT NOCOPY VARCHAR2
       ,p_intercompany_segment   OUT NOCOPY VARCHAR2);

FUNCTION get_ccid_desc
       (p_coa_id               IN NUMBER
       ,p_ccid                 IN NUMBER)
RETURN VARCHAR2;

PROCEDURE get_transaction_id
       (p_application_id         IN INTEGER
       ,p_entity_code            IN VARCHAR2
       ,p_event_class_code       IN VARCHAR2
       ,p_reporting_view_name    IN VARCHAR2
       ,p_select_str             OUT NOCOPY VARCHAR2
       ,p_from_str               OUT NOCOPY VARCHAR2
       ,p_where_str              OUT NOCOPY VARCHAR2);


 PROCEDURE get_segment_info
  (p_coa_id                     IN  NUMBER
  ,p_balancing_segment          IN VARCHAR2
  ,p_account_segment	        IN  VARCHAR2
  ,p_costcenter_segment         IN VARCHAR2
  ,p_management_segment         IN VARCHAR2
  ,p_intercompany_segment       IN VARCHAR2
  ,p_alias_balancing_segment    IN VARCHAR2
  ,p_alias_account_segment      IN  VARCHAR2
  ,p_alias_costcenter_segment   IN VARCHAR2
  ,p_alias_management_segment   IN VARCHAR2
  ,p_alias_intercompany_segment IN VARCHAR2
  ,p_seg_desc_column 		OUT NOCOPY VARCHAR2
  ,p_seg_desc_from  	        OUT NOCOPY VARCHAR2
  ,p_seg_desc_join  		OUT NOCOPY VARCHAR2
  ,p_hint           		OUT NOCOPY VARCHAR2);

PROCEDURE clob_to_file
        (p_xml_clob IN CLOB);

FUNCTION get_anc_filter
       (p_anc_level                  IN VARCHAR2
       ,p_table_alias                IN VARCHAR2
       ,p_anc_detail_code            IN VARCHAR2
       ,p_anc_detail_value           IN VARCHAR2)
RETURN VARCHAR2;

FUNCTION get_ledger_id
       (p_ledger_id               IN NUMBER)
RETURN NUMBER;

FUNCTION get_ledger_object_type
       (p_ledger_id               IN NUMBER)
RETURN VARCHAR2;

FUNCTION is_primary_ledger (p_ledger_id IN NUMBER)
RETURN NUMBER;

FUNCTION get_transaction_id( p_resp_application_id  IN NUMBER
                         ,p_ledger_id           IN NUMBER )
RETURN VARCHAR2;

--Added for Bug 7580995
PROCEDURE get_transaction_id(p_resp_application_id  IN NUMBER
                           ,p_ledger_id           IN NUMBER
                           ,p_trx_identifiers_1   OUT NOCOPY VARCHAR2
                           ,p_trx_identifiers_2   OUT NOCOPY VARCHAR2
                           ,p_trx_identifiers_3   OUT NOCOPY VARCHAR2
                           ,p_trx_identifiers_4   OUT NOCOPY VARCHAR2
                           ,p_trx_identifiers_5   OUT NOCOPY VARCHAR2);

--
-- Function to return Concatenated segment string for COA
--
FUNCTION get_conc_segments(p_coa_id      NUMBER
                          ,p_table_alias VARCHAR2)
RETURN VARCHAR2;

END  xla_report_utility_pkg;

/
