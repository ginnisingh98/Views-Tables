--------------------------------------------------------
--  DDL for Package FA_UPGHARNESS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_UPGHARNESS_PKG" AUTHID CURRENT_USER as
/* $Header: FAHAUPGS.pls 120.4.12010000.2 2009/07/19 12:51:29 glchen ship $   */

Procedure fa_master_upg (
  errbuf         OUT NOCOPY   VARCHAR2,
  retcode        OUT NOCOPY   VARCHAR2,
  p_workers_num  IN  NUMBER,
  p_batch_size   IN  NUMBER
);

Procedure upgrade_by_request (
  errbuf         OUT NOCOPY   VARCHAR2,
  retcode        OUT NOCOPY   VARCHAR2,
  p_workers_num  IN  NUMBER,
  p_worker_id    IN  NUMBER,
  p_batch_size   IN  NUMBER
);

Procedure upgrade_by_request2 (
  errbuf         OUT NOCOPY   VARCHAR2,
  retcode        OUT NOCOPY   VARCHAR2,
  p_workers_num  IN  NUMBER,
  p_worker_id    IN  NUMBER,
  p_batch_size   IN  NUMBER
);

Procedure fa_trx_upg (
  errbuf         OUT NOCOPY   VARCHAR2,
  retcode        OUT NOCOPY   VARCHAR2,
  p_script_name  IN  VARCHAR2,
  p_table_owner  IN  VARCHAR2,
  p_worker_id    IN  NUMBER,
  p_workers_num  IN  NUMBER,
  p_batch_size   IN  NUMBER
);

Procedure fa_trx2_upg (
  errbuf         OUT NOCOPY   VARCHAR2,
  retcode        OUT NOCOPY   VARCHAR2,
  p_worker_id    IN  NUMBER,
  p_workers_num  IN  NUMBER
);

Procedure fa_deprn_upg (
  errbuf         OUT NOCOPY   VARCHAR2,
  retcode        OUT NOCOPY   VARCHAR2,
  p_script_name  IN  VARCHAR2,
  p_mode         IN  VARCHAR2,
  p_table_owner  IN  VARCHAR2,
  p_worker_id    IN  NUMBER,
  p_workers_num  IN  NUMBER,
  p_batch_size   IN  NUMBER
);

Procedure fa_deprn2_upg (
  errbuf         OUT NOCOPY   VARCHAR2,
  retcode        OUT NOCOPY   VARCHAR2,
  p_worker_id    IN  NUMBER,
  p_workers_num  IN  NUMBER
);

END FA_UPGHARNESS_PKG;

/
