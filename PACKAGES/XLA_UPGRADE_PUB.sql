--------------------------------------------------------
--  DDL for Package XLA_UPGRADE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_UPGRADE_PUB" AUTHID CURRENT_USER AS
-- $Header: xlaugupg.pkh 120.14.12010000.3 2009/08/12 15:42:17 vgopiset ship $
/*===========================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                     |
|                       Redwood Shores, CA, USA                              |
|                         All rights reserved.                               |
+============================================================================+
| FILENAME                                                                   |
|    xlaugupg.pkh                                                            |
|                                                                            |
| PACKAGE NAME                                                               |
|    XLA_UPGRADE_PUB                                                         |
|                                                                            |
| DESCRIPTION                                                                |
|    This is a XLA package which contains all the APIs required by the       |
|    product teams to validate data in journal entry tables and also to      |
|    input data in analytical criteria and ae segment values tables.         |
| HISTORY                                                                    |
|    15-Dec-04 G. Bellary      Created                                       |
|    23-Jun-05 V. Mahajan      Modified                                      |
|    04-Jan-06 Koushik VS      Modified Set_Status_Code to include number    |
|                              of workers and batch size.                    |
|    16-May-06 Jorge Larre     Add pre_upgrade_set_status_code               |
|    08-NOV-2006 Jorge Larre Bug 5648571: Obsolete the procedure             |
|     set_status_code. This change is to be in sync with xlaugupg.pkb.       |
|     The code is left commented in case we decide to use it again.          |
|    22-JUL-2009 VGOPISET      8717476 :Enabled SET_STATUS_CODE procedure to |
|                              run On Demand Upgrade by Concurrent Program   |
+===========================================================================*/

PROCEDURE Insert_Line_Criteria  (
          p_batch_id IN NUMBER
          , p_batch_size IN NUMBER
          , p_application_id IN NUMBER
          , p_error_detected OUT NOCOPY BOOLEAN
          , p_overwrite_flag IN BOOLEAN);

FUNCTION set_migration_status_code
(p_application_id   in number,
 p_set_of_books_id  in number,
 p_period_name      in varchar2 default null,
 p_period_year      in number   default null)
return varchar2;

-- Re-Enabled procedure for bug:8717476
PROCEDURE set_status_code
(p_errbuf                OUT NOCOPY VARCHAR2,
 p_retcode               OUT NOCOPY NUMBER,
 p_application_id        IN NUMBER,
 p_ledger_id             IN NUMBER,
 p_period_name           IN VARCHAR2,
 p_number_of_workers     IN NUMBER,
 p_batch_size            IN NUMBER);

 PROCEDURE Validate_Header_Line_Entries
 (p_application_id IN NUMBER,
  p_header_id      IN NUMBER );

PROCEDURE pre_upgrade_set_status_code
(p_error_buf             OUT NOCOPY VARCHAR2,
 p_retcode               OUT NOCOPY NUMBER,
 p_migrate_all_ledgers   IN VARCHAR2,
 p_dummy_parameter       IN VARCHAR2,
 p_ledger_id             IN NUMBER DEFAULT NULL,
 p_start_date            IN VARCHAR2);


END  XLA_UPGRADE_PUB;

/
