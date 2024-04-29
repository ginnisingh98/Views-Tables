--------------------------------------------------------
--  DDL for Package CN_TRANSACTION_LOAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_TRANSACTION_LOAD_PKG" AUTHID CURRENT_USER AS
-- $Header: cnloads.pls 120.3 2005/08/10 03:44:59 hithanki noship $
-- +======================================================================+
-- |                Copyright (c) 1994 Oracle Corporation                 |
-- |                   Redwood Shores, California, USA                    |
-- |                        All rights reserved.                          |
-- +======================================================================+
--
-- Package Name
--   cn_transaction_load_pkg
-- Purpose
--   Procedures TO load trx FROM cn_comm_lines_api TO cn_commission_headers
-- History
--   10/21/99   Harlen Chen 	Created
--   08/28/01	Rao Chenna	acctd_transaction_amount column update logic
--   			        is modified.
-- Name:
--   Load
-- Purpose:
--   This procedure initiates a load from the API table.


PROCEDURE load (errbuf         OUT NOCOPY VARCHAR2,
		retcode        OUT NOCOPY NUMBER,
		p_salesrep_id  IN  NUMBER,
		pp_start_date  IN  VARCHAR2,
		pp_end_date    IN  VARCHAR2,
		p_cls_rol_flag IN  VARCHAR2,
		p_org_id       IN  NUMBER
		);


-- Name:
--   Load_Worker
-- Purpose:
--   This procedure is called by the concurrent program "CN_PROC_BATCHES_PKG.Runner"

PROCEDURE load_worker(p_physical_batch_id NUMBER,
		      p_salesrep_id       NUMBER,
		      p_start_date        DATE,
		      p_end_date          DATE,
		      p_cls_rol_flag      VARCHAR2);

-- Name:
--   check_api_data
-- Purpose:
--   check api data called by cn_transaction_load_pkg and cn_transaction_load_pub

PROCEDURE check_api_data(p_start_date  DATE,
			 p_end_date    DATE,
			 p_org_id      NUMBER);

PROCEDURE ASSIGN(p_logical_batch_id NUMBER, p_org_id NUMBER);

PROCEDURE Pre_Conc_Dispatch(p_salesrep_id NUMBER,
			    p_start_date  DATE ,
			    p_end_date    DATE ,
			    p_org_id      NUMBER);

PROCEDURE post_conc_dispatch(p_salesrep_id NUMBER,
			     p_start_date  DATE,
			     p_end_date    DATE ,
                             p_org_id      NUMBER);

PROCEDURE void_batches(p_physical_batch_id NUMBER,
		       p_logical_batch_id  NUMBER);

  END cn_transaction_load_pkg;

 

/
