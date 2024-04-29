--------------------------------------------------------
--  DDL for Package CSI_ML_PROGRAM_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_ML_PROGRAM_PUB" AUTHID CURRENT_USER AS
-- $Header: csimcons.pls 120.1 2006/02/03 15:26:31 sguthiva noship $

PROCEDURE execute_openinterface
 (
    errbuf                  OUT NOCOPY VARCHAR2,
    retcode                 OUT NOCOPY NUMBER,
    p_txn_from_date         IN     VARCHAR2,
    p_txn_to_date           IN     VARCHAR2,
    p_source_system_name    IN     VARCHAR2,
    p_batch_name            IN     VARCHAR2,
    p_resolve_ids           IN     VARCHAR2,
    p_purge_processed_recs  IN     VARCHAR2,
    p_reprocess_option      IN     VARCHAR2);

PROCEDURE execute_parallel_create
 (
    errbuf                  OUT NOCOPY VARCHAR2,
    retcode                 OUT NOCOPY NUMBER,
    p_txn_from_date         IN     VARCHAR2,
    p_txn_to_date           IN     VARCHAR2,
    p_source_system_name    IN     VARCHAR2,
    p_worker_count          IN     NUMBER,
    p_resolve_ids           IN     VARCHAR2,
    p_purge_processed_recs  IN     VARCHAR2);

END CSI_ML_PROGRAM_PUB;

 

/
