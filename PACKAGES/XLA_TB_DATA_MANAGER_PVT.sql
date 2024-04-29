--------------------------------------------------------
--  DDL for Package XLA_TB_DATA_MANAGER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_TB_DATA_MANAGER_PVT" AUTHID CURRENT_USER AS
/* $Header: xlatbdmg.pkh 120.7.12010000.3 2009/02/20 12:05:35 nksurana ship $   */

TYPE r_definition_info IS RECORD
  (definition_code        VARCHAR2(30)
  ,ledger_id              NUMBER(15)
  ,je_source_name         VARCHAR2(30)
  ,enabled_flag           VARCHAR2(1)
  ,balance_side_code      VARCHAR2(30)
  ,defined_by_code        VARCHAR2(30)
  ,definition_status_code VARCHAR2(30)
  ,owner_code             VARCHAR2(30));

TYPE r_ledger_info IS RECORD
  (ledger_id              NUMBER(15)
  ,ledger_name            VARCHAR2(30)
  ,ledger_short_name      VARCHAR2(20)
  ,ledger_category_code   VARCHAR2(30)
  ,currency_code          VARCHAR2(15)
  ,coa_id                 NUMBER(15)
  ,object_type_code       VARCHAR2(1)
  ,processes              PLS_INTEGER
  ,processing_unit        PLS_INTEGER
  );

FUNCTION get_report_definition
  (p_definition_code IN  VARCHAR2)
RETURN r_definition_info;

FUNCTION get_ledger_info
  (p_ledger_id IN  NUMBER)
RETURN r_ledger_info;

PROCEDURE define_segment_ranges
   (p_definition_code VARCHAR2 );

--
-- p_gl_date_from/to needs to be VARCHAR
--
PROCEDURE upload
   (p_errbuf                   IN  OUT NOCOPY VARCHAR2
   ,p_retcode                  IN  OUT NOCOPY NUMBER
   ,p_application_id           IN  NUMBER    DEFAULT NULL
   ,p_ledger_id                IN  NUMBER
   ,p_group_id                 IN  NUMBER
   ,p_definition_code          IN  VARCHAR2  DEFAULT NULL
   ,p_process_mode_code        IN  VARCHAR2
   ,p_je_source_name           IN  VARCHAR2  DEFAULT NULL
   ,p_upg_batch_id             IN  NUMBER    DEFAULT NULL
   ,p_gl_date_from             IN  VARCHAR2  DEFAULT NULL
   ,p_gl_date_to               IN  VARCHAR2  DEFAULT NULL
   );

PROCEDURE worker_process
  (p_errbuf            OUT NOCOPY VARCHAR2
  ,p_retcode           OUT NOCOPY NUMBER
  ,p_ledger_id         IN  NUMBER
  ,p_group_id          IN  NUMBER
  ,p_definition_code   IN  VARCHAR2
  ,p_parent_request_id IN  PLS_INTEGER
  ,p_je_source_name    IN VARCHAR2 --bug#7320079
  );

PROCEDURE add_partition (p_definition_code  IN VARCHAR2 );

PROCEDURE drop_partition (p_definition_code IN VARCHAR2);

PROCEDURE delete_non_ui_rows (p_definition_code IN VARCHAR2);

PROCEDURE delete_trial_balances
  (p_definition_code  IN VARCHAR2);

PROCEDURE delete_trial_balances
  (p_application_id   IN NUMBER
  ,p_ae_header_id     IN NUMBER);

PROCEDURE recreate_trial_balances
  (p_application_id   IN NUMBER
  ,p_ae_header_id     IN NUMBER);

END XLA_TB_DATA_MANAGER_PVT;

/
