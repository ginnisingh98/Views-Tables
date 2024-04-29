--------------------------------------------------------
--  DDL for Package EGO_BULKLOAD_ENTITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EGO_BULKLOAD_ENTITIES" AUTHID CURRENT_USER AS
/* $Header: EGOBKUPS.pls 120.5 2007/07/12 12:12:47 rsoundar ship $ */

PROCEDURE BulkLoadEntities(
  ERRBUF                  OUT NOCOPY VARCHAR2,
  RETCODE                 OUT NOCOPY VARCHAR2,
  result_format_usage_id  IN  NUMBER,
  user_id                 IN  NUMBER,
  language                IN  VARCHAR2,
  resp_id                 IN  NUMBER,
  appl_id                 IN  NUMBER,
  p_start_upload          IN  VARCHAR2,
  p_data_set_id           IN  NUMBER
  );

/*
 * This Procedure is called from Excel Import
 * it will launch the concurrent program and call API to update
 * the request id into ego_import_batches_b table
 */
PROCEDURE Run_Import_Program(
          p_resultfmt_usage_id            IN  NUMBER,
          p_user_id                       IN  NUMBER,
          p_language                      IN  VARCHAR2,
          p_resp_id                       IN  NUMBER,
          p_appl_id                       IN  NUMBER,
          p_run_from                      IN  VARCHAR2,
          p_create_new_batch              IN  VARCHAR2,
          p_batch_id                      IN  NUMBER,
          p_batch_name                    IN  VARCHAR2,
          p_auto_imp_on_data_load         IN  VARCHAR2,
          p_auto_match_on_data_load       IN  VARCHAR2,
          p_change_order_option           IN  VARCHAR2,
          p_add_all_items_to_CO           IN  VARCHAR2,
          p_change_order_category         IN  VARCHAR2,
          p_change_order_type             IN  VARCHAR2,
          p_change_order_name             IN  VARCHAR2,
          p_change_order_number           IN  VARCHAR2,
          p_change_order_desc             IN  VARCHAR2,
          p_schedule_date									IN  DATE,
          p_nir_option                      IN VARCHAR2,
          x_request_id                    OUT NOCOPY NUMBER);

END EGO_BULKLOAD_ENTITIES;

/
