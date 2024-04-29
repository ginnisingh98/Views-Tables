--------------------------------------------------------
--  DDL for Package XLA_THIRD_PARTY_MERGE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_THIRD_PARTY_MERGE_PUB" AUTHID CURRENT_USER AS
-- $Header: xlamergp.pkh 120.0 2005/10/28 22:21:08 weshen noship $
/*===========================================================================+
|                Copyright (c) 2005 Oracle Corporation                       |
|                       Redwood Shores, CA, USA                              |
|                         All rights reserved.                               |
+============================================================================+
| FILENAME                                                                   |
|    xlamergp.pkh                                                            |
|                                                                            |
| PACKAGE NAME                                                               |
|    xla_third_party_merge_pub                                               |
|                                                                            |
| DESCRIPTION                                                                |
|    This is a public package for product teams, which contains all the      |
|    APIs required for creating Third Party Merge events.                    |
|                                                                            |
|    Note: the APIs do not excute COMMIT or ROLLBACK.                        |
|                                                                            |
|    These public APIs are wrapper over public routines of                   |
|    xla_third_party_merge                                                   |
|                                                                            |
| HISTORY                                                                    |
|    08-Sep-05 L. Poon         Created                                       |
+===========================================================================*/

-------------------------------------------------------------------------------
-- Global variables
-------------------------------------------------------------------------------
G_RET_STS_SUCCESS     CONSTANT VARCHAR2(1)	:=  'S';
G_RET_STS_WARN        CONSTANT VARCHAR2(1)	:=  'W';
G_RET_STS_ERROR	      CONSTANT VARCHAR2(1)	:=  'E';
G_RET_STS_UNEXP_ERROR CONSTANT VARCHAR2(1)	:=  'U';

-------------------------------------------------------------------------------
-- Global types
-------------------------------------------------------------------------------
TYPE t_event_ids IS TABLE OF NUMBER(15) INDEX BY BINARY_INTEGER;

-------------------------------------------------------------------------------
-- Third party merge event creation routine
-------------------------------------------------------------------------------
PROCEDURE third_party_merge
 (  x_errbuf                    OUT NOCOPY VARCHAR2
  , x_retcode                   OUT NOCOPY VARCHAR2
  , x_event_ids                 OUT NOCOPY t_event_ids
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
-- Create third party merge accounting routine - called by SRS
-------------------------------------------------------------------------------
PROCEDURE create_accounting
 (  x_errbuf                    OUT NOCOPY VARCHAR2
  , x_retcode                   OUT NOCOPY VARCHAR2
  , p_application_id            IN INTEGER
  , p_event_id                  IN INTEGER DEFAULT NULL
  , p_accounting_mode           IN VARCHAR2
  , p_transfer_to_gl_flag       IN VARCHAR2
  , p_post_in_gl_flag           IN VARCHAR2
  , p_merge_event_set_id        IN INTEGER DEFAULT NULL);

END xla_third_party_merge_pub;
 

/
