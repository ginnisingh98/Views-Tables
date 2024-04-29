--------------------------------------------------------
--  DDL for Package WSM_WLT_VALIDATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSM_WLT_VALIDATE_PVT" AUTHID CURRENT_USER as
/* $Header: WSMVVLDS.pls 120.4 2006/03/28 21:56:33 sthangad noship $ */

        -- ***data types for LBJ code-remove later when LBJ API coded
        type weid_tbl_type              is table of number              index by binary_integer;
        type job_name_tbl_type          is table of varchar2(240)       index by binary_integer;

        g_job_name_tbl          job_name_tbl_type;
        g_wip_entity_id_tbl     weid_tbl_type;
        -- ***end data types for LBJ code-remove later when LBJ API is coded

        -- Inserts the data into the base tables...
        Procedure insert_txn_data ( p_transaction_id            IN              NUMBER,
                                   p_wltx_header                IN              WSM_WIP_LOT_TXN_PVT.WLTX_TRANSACTIONS_REC_TYPE,
                                   p_wltx_starting_jobs_tbl     IN              WSM_WIP_LOT_TXN_PVT.WLTX_STARTING_JOBS_TBL_TYPE,
                                   p_wltx_resulting_jobs_tbl    IN              WSM_WIP_LOT_TXN_PVT.WLTX_RESULTING_JOBS_TBL_TYPE,
                                   x_return_status              OUT     NOCOPY  VARCHAR2,
                                   x_msg_count                  OUT     NOCOPY  NUMBER,
                                   x_msg_data                   OUT     NOCOPY  VARCHAR2
                                  );


        -- Validate the txn details passed
        Procedure validate_txn_header ( p_wltx_header      IN OUT NOCOPY WSM_WIP_LOT_TXN_PVT.WLTX_TRANSACTIONS_REC_TYPE,
                                        x_return_status    OUT  NOCOPY  VARCHAR2,
                                        x_msg_count        OUT  NOCOPY  NUMBER,
                                        x_msg_data         OUT  NOCOPY  VARCHAR2
                                        );

        -- ST : Fix for bug 4351071 --
        -- Added this procedure to validate the date information..
        -- i)  Txn date >= released_date
        -- ii) Txn date > last wip lot txn performed on this job...
        Procedure validate_sj_txn_date ( p_txn_date             IN           DATE    ,
                                         p_sj_wip_entity_id     IN           NUMBER  ,
                                         p_sj_wip_entity_name   IN           VARCHAR2,
                                         p_sj_date_released     IN           DATE    ,
                                         x_return_status        OUT  NOCOPY  VARCHAR2,
                                         x_msg_count            OUT  NOCOPY  NUMBER  ,
                                         x_msg_data             OUT  NOCOPY  VARCHAR2
                                        );

        -- derive Validate the starting job info
        Procedure derive_val_st_job_details(    p_txn_org_id                            IN              NUMBER,
                                                p_txn_type                              IN              NUMBER,
                                                -- ST : Added Txn date for bug 4351071
                                                p_txn_date                              IN              DATE,
                                                p_starting_job_rec                      IN OUT  NOCOPY  WSM_WIP_LOT_TXN_PVT.WLTX_STARTING_JOBS_REC_TYPE,
                                                x_return_status                         OUT     NOCOPY  VARCHAR2,
                                                x_msg_count                             OUT     NOCOPY  NUMBER,
                                                x_msg_data                              OUT     NOCOPY  VARCHAR2
                                              );
        -- derive Validate the starting job info ( overloaded for merge ) --
        Procedure derive_val_st_job_details(    p_txn_org_id                            IN              NUMBER,
                                                p_txn_type                              IN              NUMBER,
                                                -- ST : Added Txn date for bug 4351071
                                                p_txn_date                              IN              DATE,
                                                p_starting_jobs_tbl                     IN OUT  NOCOPY  WSM_WIP_LOT_TXN_PVT.WLTX_STARTING_JOBS_TBL_TYPE,
                                                p_rep_job_index                         OUT     NOCOPY  NUMBER,
                                                p_total_avail_quantity                  OUT     NOCOPY  NUMBER,
                                                p_total_net_quantity                    OUT     NOCOPY  NUMBER,
                                                x_job_serial_code                       OUT     NOCOPY  NUMBER,
                                                x_return_status                         OUT     NOCOPY  VARCHAR2,
                                                x_msg_count                             OUT     NOCOPY  NUMBER,
                                                x_msg_data                              OUT     NOCOPY  VARCHAR2
                                           );

        -- Default resulting job details for merge txn --
        Procedure derive_val_res_job_details(   p_txn_type              IN              NUMBER,
                                                p_txn_org_id            IN              NUMBER,
                                                p_starting_job_rec      IN              WSM_WIP_LOT_TXN_PVT.WLTX_STARTING_JOBS_REC_TYPE,
                                                p_job_quantity          IN              NUMBER,
                                                p_job_net_quantity      IN              NUMBER,
                                                -- ST : Serial Support : Added the below parameter..
                                                p_job_serial_code       IN              NUMBER,
                                                p_resulting_job_rec     IN OUT  NOCOPY  WSM_WIP_LOT_TXN_PVT.WLTX_RESULTING_JOBS_REC_TYPE,
                                                x_return_status         OUT     NOCOPY  VARCHAR2,
                                                x_msg_count             OUT     NOCOPY  NUMBER,
                                                x_msg_data              OUT     NOCOPY  VARCHAR2
                                            );

        -- Default resulting job details for bonus txn --
         Procedure derive_val_res_job_details(  p_txn_type              IN              NUMBER,
                                                p_txn_org_id            IN              NUMBER,
                                                p_transaction_date      IN              DATE,
                                                p_resulting_job_rec     IN OUT  NOCOPY  WSM_WIP_LOT_TXN_PVT.WLTX_RESULTING_JOBS_REC_TYPE,
                                                x_return_status         OUT     NOCOPY  VARCHAR2,
                                                x_msg_count             OUT     NOCOPY  NUMBER,
                                                x_msg_data              OUT     NOCOPY  VARCHAR2
                                           );

        -- for non-split non-merge transactions.... --
        Procedure derive_val_res_job_details(   p_txn_type              IN              NUMBER,
                                                p_txn_org_id            IN              NUMBER,
                                                p_transaction_date      IN              DATE,
                                                p_starting_job_rec      IN              WSM_WIP_LOT_TXN_PVT.WLTX_STARTING_JOBS_REC_TYPE,
                                                p_resulting_job_rec     IN OUT  NOCOPY  WSM_WIP_LOT_TXN_PVT.WLTX_RESULTING_JOBS_REC_TYPE,
                                                x_return_status         OUT     NOCOPY  VARCHAR2,
                                                x_msg_count             OUT     NOCOPY  NUMBER,
                                                x_msg_data              OUT     NOCOPY  VARCHAR2
                                            );


        -- Default resulting job details from the starting job for appropriate fields depending on txn ( overloaded for split) --
        Procedure derive_val_res_job_details(   p_txn_type              IN              NUMBER,
                                                p_txn_org_id            IN              NUMBER,
                                                p_starting_job_rec      IN              WSM_WIP_LOT_TXN_PVT.WLTX_STARTING_JOBS_REC_TYPE,
                                                p_resulting_jobs_tbl    IN OUT  NOCOPY  WSM_WIP_LOT_TXN_PVT.WLTX_RESULTING_JOBS_TBL_TYPE,
                                                x_return_status         OUT     NOCOPY  VARCHAR2,
                                                x_msg_count             OUT     NOCOPY  NUMBER,
                                                x_msg_data              OUT     NOCOPY  VARCHAR2
                                            );

        -- routing procedure..... --
        Procedure derive_val_routing_info (p_txn_org_id                         IN              NUMBER,
                                           p_sj_job_type                        IN              NUMBER,
                                           p_rj_primary_item_id                 IN              NUMBER,
                                           p_rj_rtg_reference_item              IN              VARCHAR2,
                                           p_rj_rtg_reference_id                IN OUT NOCOPY   NUMBER,
                                           p_rj_alternate_rtg_desig             IN OUT NOCOPY   VARCHAR2,
                                           p_rj_common_rtg_seq_id               IN OUT NOCOPY   NUMBER,
                                           p_rj_rtg_revision                    IN OUT NOCOPY   VARCHAR2,
                                           p_rj_rtg_revision_date               IN OUT NOCOPY   DATE,
                                           x_return_status                      OUT    NOCOPY   VARCHAR2,
                                           x_msg_count                          OUT    NOCOPY   NUMBER,
                                           x_msg_data                           OUT    NOCOPY   VARCHAR2
                                         );

        -- BOM procedure...... --
        Procedure derive_val_bom_info  (   p_txn_org_id                         IN              NUMBER,
                                           p_sj_job_type                        IN              NUMBER,
                                           p_rj_primary_item_id                 IN              NUMBER,
                                           p_rj_bom_reference_item              IN OUT NOCOPY   VARCHAR2,
                                           p_rj_bom_reference_id                IN OUT NOCOPY   NUMBER,
                                           p_rj_alternate_bom_desig             IN OUT NOCOPY   VARCHAR2,
                                           p_rj_common_bom_seq_id               IN OUT NOCOPY   NUMBER,
                                           p_rj_bom_revision                    IN OUT NOCOPY   VARCHAR2,
                                           p_rj_bom_revision_date               IN OUT NOCOPY   DATE,
                                           x_return_status                      OUT    NOCOPY   VARCHAR2,
                                           x_msg_count                          OUT    NOCOPY   NUMBER,
                                           x_msg_data                           OUT    NOCOPY   VARCHAR2
                                    );

        -- Validate the completion subinventory details.... --
        Procedure derive_val_compl_subinv(
                                         p_job_type                             IN              NUMBER,
                                         p_old_rtg_seq_id                       IN              NUMBER,
                                         p_new_rtg_seq_id                       IN              NUMBER,
                                         p_organization_id                      IN              NUMBER,
                                         p_primary_item_id                      IN              NUMBER,
                                         p_sj_completion_subinventory           IN              VARCHAR2,
                                         p_sj_completion_locator_id             IN              NUMBER,
                                         p_rj_alt_rtg_designator                IN              VARCHAR2,       -- Added for the bug 5094555
                                         p_rj_rtg_reference_item_id             IN              NUMBER,         -- Added for the bug 5094555
                                         p_rj_completion_subinventory           IN  OUT NOCOPY  VARCHAR2,
                                         p_rj_completion_locator_id             IN  OUT NOCOPY  NUMBER,
                                         p_rj_completion_locator                IN  OUT NOCOPY  VARCHAR2,
                                         x_return_status                        OUT     NOCOPY  VARCHAR2,
                                         x_msg_count                            OUT     NOCOPY  NUMBER,
                                         x_msg_data                             OUT     NOCOPY  VARCHAR2
                                       );

        Procedure derive_val_starting_op (   p_txn_org_id               IN              NUMBER,
                                             p_curr_op_seq_id           IN              NUMBER,
                                             p_curr_op_code             IN              VARCHAR2,
                                             p_curr_std_op_id           IN              NUMBER,
                                             p_curr_intra_op_step       IN              NUMBER,
                                             p_new_comm_rtg_seq_id      IN              NUMBER,
                                             p_new_rtg_rev_date         IN              DATE,
                                             p_new_op_seq_num           IN OUT NOCOPY   NUMBER,
                                             p_new_op_seq_id            IN OUT NOCOPY   NUMBER,
                                             p_new_std_op_id            IN OUT NOCOPY   NUMBER,
                                             p_new_op_seq_code          IN OUT NOCOPY   VARCHAR2,
                                             p_new_dept_id              IN OUT NOCOPY   NUMBER,
                                             x_return_status            OUT    NOCOPY   VARCHAR2,
                                             x_msg_count                OUT    NOCOPY   NUMBER,
                                             x_msg_data                 OUT    NOCOPY   VARCHAR2
                                          );



        Procedure derive_val_primary_item (  p_txn_org_id       IN              NUMBER,
                                             p_old_item_id      IN              NUMBER,
                                             p_new_item_name    IN              VARCHAR2,
                                             p_new_item_id      IN OUT NOCOPY   NUMBER,
                                             x_return_status    OUT NOCOPY      VARCHAR2,
                                             x_msg_count        OUT NOCOPY      NUMBER,
                                             x_msg_data         OUT NOCOPY      VARCHAR2
                                          );

        Procedure validate_network(     p_txn_org_id            IN              NUMBER  ,
                                        p_rtg_seq_id            IN              NUMBER  ,
                                        p_revision_date         IN              DATE    ,
                                        p_start_op_seq_num      IN OUT NOCOPY   NUMBER  ,
                                        p_start_op_seq_id       IN OUT NOCOPY   NUMBER  ,
                                        p_start_op_seq_code     IN OUT NOCOPY   VARCHAR2,
                                        p_dept_id               IN OUT NOCOPY   NUMBER  ,
                                        x_return_status         OUT NOCOPY      varchar2  ,
                                        x_msg_count             OUT NOCOPY      NUMBER  ,
                                        x_msg_data              OUT NOCOPY      VARCHAR2
                                );

end WSM_WLT_VALIDATE_PVT;

 

/
