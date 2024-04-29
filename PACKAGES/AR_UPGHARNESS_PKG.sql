--------------------------------------------------------
--  DDL for Package AR_UPGHARNESS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_UPGHARNESS_PKG" AUTHID CURRENT_USER AS
/*$Header: ARXLAHNS.pls 120.3 2006/09/07 19:37:27 hyu noship $*/

PROCEDURE log(
   message      IN      VARCHAR2,
   newline      IN      BOOLEAN DEFAULT TRUE);

PROCEDURE outandlog(
   message      IN      VARCHAR2,
   newline      IN      BOOLEAN DEFAULT TRUE);

FUNCTION logerror(SQLERRM VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2;

PROCEDURE upgrade_by_request (
        errbuf         OUT NOCOPY   VARCHAR2,
        retcode        OUT NOCOPY   VARCHAR2,
        l_table_name   IN           VARCHAR2,
        l_script_name  IN           VARCHAR2,
        l_num_workers  IN           NUMBER,
        l_worker_id    IN           NUMBER,
        l_batch_size   IN           VARCHAR2,
		p_order_num    IN           NUMBER);

PROCEDURE ar_master_upg
 (errbuf         OUT NOCOPY   VARCHAR2,
  retcode        OUT NOCOPY   VARCHAR2,
  p_ledger_id    IN NUMBER,
  p_period_name  IN VARCHAR2,
  p_workers_num  IN NUMBER,
  p_batch_size   IN NUMBER);
/*
PROCEDURE ar_master_upg_parent
 (errbuf         OUT NOCOPY   VARCHAR2,
  retcode        OUT NOCOPY   VARCHAR2,
  p_ledger_id      IN NUMBER,
  p_period_name    IN VARCHAR2,
  p_workers_num    IN NUMBER,
  p_batch_size     IN NUMBER);
*/
END;

 

/
