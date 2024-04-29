--------------------------------------------------------
--  DDL for Package FEM_PL_INCR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FEM_PL_INCR_PKG" AUTHID CURRENT_USER AS
/* $Header: fem_pl_incr.pls 120.1 2006/02/27 17:34:26 gcheng noship $ */

---------------------
-- Public Procedures
---------------------

   PROCEDURE Exec_Lock_Exists
                (p_calling_context         IN  VARCHAR2 DEFAULT 'ENGINE',
                 p_object_id               IN  NUMBER,
                 p_obj_def_id              IN  NUMBER,
                 p_cal_period_id           IN  NUMBER,
                 p_ledger_id               IN  NUMBER,
                 p_dataset_code            IN  NUMBER,
                 p_source_system_code      IN  VARCHAR2 DEFAULT NULL,
                 p_table_name              IN  VARCHAR2 DEFAULT NULL,
                 p_exec_mode               IN  VARCHAR2,
                 x_exec_lock_exists        OUT NOCOPY VARCHAR2,
                 x_exec_state              OUT NOCOPY VARCHAR2,
                 x_prev_request_id         OUT NOCOPY NUMBER,
                 x_num_msg                 OUT NOCOPY NUMBER);

END FEM_PL_INCR_PKG;

 

/
