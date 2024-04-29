--------------------------------------------------------
--  DDL for Package CN_PURGE_TABLES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_PURGE_TABLES_PUB" AUTHID CURRENT_USER AS
  /* $Header: CNPTPRGS.pls 120.0.12010000.3 2010/06/17 05:12:19 sseshaiy noship $*/

  CN_PURGE_REQ_FIELD_NOT_SET_ER EXCEPTION;

  TYPE sub_program_id_type IS TABLE OF NUMBER;

-- API name  : archive_purge_cn_tables
-- Type : public.
-- Pre-reqs :
PROCEDURE archive_purge_cn_tables
  (
    errbuf OUT NOCOPY  VARCHAR2,
    retcode OUT NOCOPY VARCHAR2,
    p_run_mode          IN VARCHAR2,
    p_start_period_name IN VARCHAR2,
    p_end_period_name   IN VARCHAR2,
    p_org_id            IN NUMBER,
    p_table_space       IN VARCHAR2,
    p_no_of_workers     IN NUMBER,
    p_worker_id         IN NUMBER,
    p_batch_size        IN NUMBER );

END CN_PURGE_TABLES_PUB;

/
