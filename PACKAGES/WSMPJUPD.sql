--------------------------------------------------------
--  DDL for Package WSMPJUPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSMPJUPD" AUTHID CURRENT_USER AS
/* $Header: WSMJUPDS.pls 120.3.12000000.1 2007/01/12 05:35:46 appldev ship $ */

g_debug      VARCHAR2(1);
g_osp_exists NUMBER := 0;
g_copy_mode  NUMBER := NULL;   -- Added for APS-WLT
    -- 0=> no copies,
    -- 1=> copies after each transaction,
    -- 2=> copies at end (for interface only)
    -- Will remain NULL if JUPD is called through the form



PROCEDURE PROCESS_LOTS (p_copy_qa                       IN                      VARCHAR2,
                        p_txn_org_id                    IN                      NUMBER,
                        p_rep_job_index                 IN                      NUMBER,
                        p_wltx_header                   IN OUT  NOCOPY          WSM_WIP_LOT_TXN_PVT.WLTX_TRANSACTIONS_REC_TYPE,
                        p_wltx_starting_jobs_tbl        IN OUT  NOCOPY          WSM_WIP_LOT_TXN_PVT.WLTX_STARTING_JOBS_TBL_TYPE,
                        p_wltx_resulting_jobs_tbl       IN OUT  NOCOPY          WSM_WIP_LOT_TXN_PVT.WLTX_RESULTING_JOBS_TBL_TYPE,
                        p_secondary_qty_tbl             IN OUT  NOCOPY          WSM_WIP_LOT_TXN_PVT.WSM_JOB_SECONDARY_QTY_TBL_TYPE ,
                        -- p_txn_id                     OUT     NOCOPY          NUMBER, /* i dont think this is needed,,,, */
                        x_return_status                 OUT     NOCOPY          VARCHAR2,
                        x_msg_count                     OUT     NOCOPY          NUMBER,
                        x_error_msg                     OUT     NOCOPY          VARCHAR2
                       );


PROCEDURE CREATE_COPIES_OR_SET_COPY_DATA (p_txn_id                      IN  NUMBER,
                                          p_txn_type_id                 IN  NUMBER,
                                          p_copy_mode                   IN  NUMBER,
                                          p_rep_sj_index                IN  NUMBER,
                                          p_sj_as_rj_index              IN  NUMBER,
                                          p_wltx_starting_jobs_tbl      IN OUT  NOCOPY          WSM_WIP_LOT_TXN_PVT.WLTX_STARTING_JOBS_TBL_TYPE,
                                          p_wltx_resulting_jobs_tbl     IN OUT  NOCOPY          WSM_WIP_LOT_TXN_PVT.WLTX_RESULTING_JOBS_TBL_TYPE,
                                          x_err_code                    OUT NOCOPY              NUMBER,
                                          x_err_buf                     OUT NOCOPY              VARCHAR2,
                                          x_msg_count                   OUT NOCOPY              NUMBER);

PROCEDURE GET_JOB_CURR_OP_INFO(p_wip_entity_id      IN NUMBER,
                               p_op_seq_num         OUT NOCOPY NUMBER,
                               p_op_seq_id          OUT NOCOPY NUMBER,
                               p_std_op_id          OUT NOCOPY NUMBER,
                               p_intra_op           OUT NOCOPY NUMBER,
                               p_dept_id            OUT NOCOPY NUMBER,
                               p_op_qty             OUT NOCOPY NUMBER,
                               p_op_start_date      OUT NOCOPY DATE,
                               p_op_completion_date OUT NOCOPY DATE,
                               x_err_code           OUT NOCOPY NUMBER,
                               x_err_buf            OUT NOCOPY VARCHAR2,
                               x_msg_count          OUT NOCOPY NUMBER);

END WSMPJUPD;

 

/
