--------------------------------------------------------
--  DDL for Package PA_BILL_REV_XLA_UPGRADE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_BILL_REV_XLA_UPGRADE" AUTHID CURRENT_USER AS
/* $Header: PAXBRU1S.pls 120.4 2006/01/18 00:39:24 rgandhi noship $ */

PROCEDURE GL_IMP_UPG_AD_PAR( p_table_owner   IN         VARCHAR2,
                             p_table_name    IN         VARCHAR2,
                             p_script_name   IN         VARCHAR2,
                             p_num_workers   IN         NUMBER,
                             p_worker_id     IN         NUMBER,
                             p_batch_size    IN         NUMBER,
                             p_min_header_id IN         NUMBER,
                             p_max_header_id IN         NUMBER,
			     p_batch_id      IN         NUMBER);

PROCEDURE REV_UPG_AD_PAR( p_table_owner  IN         VARCHAR2,
                          p_table_name   IN         VARCHAR2,
                          p_script_name  IN         VARCHAR2,
                          p_num_workers  IN         NUMBER,
                          p_worker_id    IN         NUMBER,
                          p_batch_size   IN         NUMBER,
                          p_batch_id     IN         NUMBER);

PROCEDURE UPGRADE_TRANSACTIONS(
                               p_start_rowid  IN         ROWID,
                               p_end_rowid    IN         ROWID,
                               p_batch_id     IN         NUMBER,
                               p_rows_process OUT NOCOPY NUMBER);

PROCEDURE REV_UPG_MC_AD_PAR( p_table_owner  IN         VARCHAR2,
                             p_table_name   IN         VARCHAR2,
                             p_script_name  IN         VARCHAR2,
                             p_num_workers  IN         NUMBER,
                             p_worker_id    IN         NUMBER,
                             p_batch_size   IN         NUMBER,
                             p_batch_id     IN         NUMBER);

PROCEDURE UPGRADE_MC_TRANSACTIONS( p_start_rowid IN ROWID,
                                   p_end_rowid   IN ROWID,
                                   p_batch_id    IN NUMBER,
                                   p_rows_process OUT NOCOPY NUMBER);

/* Called from concurrent program*/
PROCEDURE CON_UPGRADE_TRANSACTIONS;



END PA_BILL_REV_XLA_UPGRADE;

 

/
