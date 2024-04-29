--------------------------------------------------------
--  DDL for Package XLA_THIRD_PARTY_MERGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_THIRD_PARTY_MERGE" AUTHID CURRENT_USER AS
-- $Header: xlamerge.pkh 120.0 2005/10/28 22:27:09 weshen noship $
/*===========================================================================+
|                Copyright (c) 2005 Oracle Corporation                       |
|                       Redwood Shores, CA, USA                              |
|                         All rights reserved.                               |
+============================================================================+
| FILENAME                                                                   |
|    xlamerge.pkh                                                            |
|                                                                            |
| PACKAGE NAME                                                               |
|    xla_third_party_merge                                                   |
|                                                                            |
| DESCRIPTION                                                                |
|    This is a XLA private package, which contains all the APIs required for |
|    creating Third Party Merge events.                                      |
|                                                                            |
|    The public wrapper called xla_third_party_merge_pub, is built based on  |
|    this package.                                                           |
|                                                                            |
|    Note:                                                                   |
|       - the APIs do not execute any COMMIT                                 |
|       - the APIs may perform ROLLBACK for what changes they have made      |
|       - these APIs are not supposed to raise any exception                 |
|                                                                            |
| HISTORY                                                                    |
|    08-Sep-05 L. Poon         Created                                       |
+===========================================================================*/

-------------------------------------------------------------------------------
-- Third party merge event creation routine
-------------------------------------------------------------------------------
PROCEDURE third_party_merge
 (  x_errbuf                    OUT NOCOPY VARCHAR2
  , x_retcode                   OUT NOCOPY VARCHAR2
  , x_event_ids                 OUT NOCOPY xla_third_party_merge_pub.t_event_ids
  , x_request_id                OUT NOCOPY INTEGER
  , p_source_application_id     IN INTEGER DEFAULT NULL
  , p_application_id            IN INTEGER
  , p_ledger_id                 IN INTEGER DEFAULT NULL
  , p_third_party_merge_date    IN DATE
  , p_third_party_type          IN VARCHAR2
  , p_original_third_party_id   IN INTEGER
  , p_original_site_id          IN INTEGER DEFAULT NULL
  , p_new_third_party_id        IN INTEGER
  , p_new_site_id               IN INTEGER DEFAULT NULL
  , p_type_of_third_party_merge IN VARCHAR2
  , p_mapping_flag              IN VARCHAR2
  , p_execution_mode            IN VARCHAR2
  , p_accounting_mode           IN VARCHAR2
  , p_transfer_to_gl_flag       IN VARCHAR2
  , p_post_in_gl_flag           IN VARCHAR2);

-------------------------------------------------------------------------------
-- Create third party merge accounting routine
-------------------------------------------------------------------------------
PROCEDURE create_accounting
 (  x_errbuf                    OUT NOCOPY VARCHAR2
  , x_retcode                   OUT NOCOPY VARCHAR2
  , p_application_id            IN INTEGER
  , p_event_id                  IN INTEGER DEFAULT NULL
  , p_accounting_mode           IN VARCHAR2
  , p_transfer_to_gl_flag       IN VARCHAR2
  , p_post_in_gl_flag           IN VARCHAR2
  , p_merge_event_set_id        IN INTEGER DEFAULT NULL
  , p_srs_flag                  IN VARCHAR2 DEFAULT NULL);

END xla_third_party_merge;
 

/
