--------------------------------------------------------
--  DDL for Package XLA_TRANSACTION_ID_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_TRANSACTION_ID_PKG" AUTHID CURRENT_USER AS
-- $Header: xlacmtid.pkh 120.6 2005/08/29 22:02:04 weshen ship $
/*===========================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                     |
|                       Redwood Shores, CA, USA                              |
|                         All rights reserved.                               |
+============================================================================+
| PACKAGE NAME                                                               |
|     xla_transaction_id_pkg                                                 |
|                                                                            |
| DESCRIPTION                                                                |
|     This package provides routines to handle transaction identifiers.      |
|                                                                            |
| HISTORY                                                                    |
|     10/07/2002  S. Singhania    Created                                    |
|     11/30/2002  S. Singhania    Added p_request_id parameter to            |
|                                   get_query_string.                        |
|     07/22/2003  S. Singhania    Added dbdrv command to the file            |
|     08/27/2003  S. Singhania    Replaced the funtion with the procedure    |
|                                   GET_QUERY_STRINGS so that the report     |
|                                   XLAACCPB.rdf can use this procedure to   |
|                                   build its query. bug # 3113574           |
|     07/20/2005  W. Shen         Change the get_transcation_identifiers     |
|                                   from procedure to function to return     |
|                                   some error result so it can be processed |
|                                   0-- success                              |
|                                   1-- fail                                 |
|                                                                            |
+===========================================================================*/

PROCEDURE get_query_strings
       (p_application_id         IN INTEGER
       ,p_entity_code            IN VARCHAR2
       ,p_event_class_code       IN VARCHAR2
       ,p_reporting_view_name    IN VARCHAR2
       ,p_request_id             IN NUMBER
       ,p_select_str             OUT NOCOPY VARCHAR2
       ,p_from_str               OUT NOCOPY VARCHAR2
       ,p_where_str              OUT NOCOPY VARCHAR2);

--FUNCTION get_query_string
--       (p_application_id         IN INTEGER
--       ,p_entity_code            IN VARCHAR2
--       ,p_event_class_code       IN VARCHAR2
--       ,p_reporting_view_name    IN VARCHAR2
--       ,p_request_id             IN NUMBER)
--RETURN VARCHAR2;
-- return 0 means success
-- return 1 means the query return more than 1 row
FUNCTION get_transaction_identifiers(
      p_application_id in INTEGER,
      p_entity_code in VARCHAR2,
      p_event_class_code in VARCHAR2,
      p_event_id in INTEGER,
      p_transactionid1_prompt out NOCOPY VARCHAR2,
      p_transactionid1_value out NOCOPY VARCHAR2,
      p_transactionid2_prompt out NOCOPY VARCHAR2,
      p_transactionid2_value out NOCOPY VARCHAR2,
      p_transactionid3_prompt out NOCOPY VARCHAR2,
      p_transactionid3_value out NOCOPY VARCHAR2,
      p_transactionid4_prompt out NOCOPY VARCHAR2,
      p_transactionid4_value out NOCOPY VARCHAR2,
      p_transactionid5_prompt out NOCOPY VARCHAR2,
      p_transactionid5_value out NOCOPY VARCHAR2,
      p_transactionid6_prompt out NOCOPY VARCHAR2,
      p_transactionid6_value out NOCOPY VARCHAR2,
      p_transactionid7_prompt out NOCOPY VARCHAR2,
      p_transactionid7_value out NOCOPY VARCHAR2,
      p_transactionid8_prompt out NOCOPY VARCHAR2,
      p_transactionid8_value out NOCOPY VARCHAR2,
      p_transactionid9_prompt out NOCOPY VARCHAR2,
      p_transactionid9_value out NOCOPY VARCHAR2,
      p_transactionid10_prompt out NOCOPY VARCHAR2,
      p_transactionid10_value out NOCOPY VARCHAR2) return NUMBER;


END xla_transaction_id_pkg;
 

/
