--------------------------------------------------------
--  DDL for Package WSM_JOBCOPIES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSM_JOBCOPIES_PVT" AUTHID CURRENT_USER AS
/* $Header: WSMVCPYS.pls 120.2.12000000.1 2007/01/12 05:37:38 appldev ship $ */

g_debug      VARCHAR2(1);

PROCEDURE Create_JobCopies  (x_err_buf              OUT NOCOPY VARCHAR2,
                             x_err_code             OUT NOCOPY NUMBER,
                             p_wip_entity_id        IN  NUMBER,
                             p_org_id               IN  NUMBER,
                             p_primary_item_id      IN  NUMBER,
                             p_routing_item_id      IN  NUMBER,
                             p_alt_rtg_desig        IN  VARCHAR2,
                             p_rtg_seq_id           IN  NUMBER, -- Will be NULL till reqd for some functionality
                             p_common_rtg_seq_id    IN  NUMBER,
                             p_rtg_rev_date         IN  DATE,
                             p_bill_item_id         IN  NUMBER,
                             p_alt_bom_desig        IN  VARCHAR2,
                             p_bill_seq_id          IN  NUMBER,
                             p_common_bill_seq_id   IN  NUMBER,
                             p_bom_rev_date         IN  DATE,
                             p_wip_supply_type      IN  NUMBER,
                             p_last_update_date     IN  DATE,
                             p_last_updated_by      IN  NUMBER,
                             p_last_update_login    IN  NUMBER,
                             p_creation_date        IN  DATE,
                             p_created_by           IN  NUMBER,
                             p_request_id           IN  NUMBER,
                             p_program_app_id       IN  NUMBER,
                             p_program_id           IN  NUMBER,
                             p_program_update_date  IN  DATE,
                             p_inf_sch_flag         IN  VARCHAR2,   --Y/N
                             p_inf_sch_mode         IN  NUMBER,     --NULL/FORWARDS/BACKWARDS/MIDPOINT_FORWARDS/MIDPOINT_BACKWARDS/CURRENT_OP
                             p_inf_sch_date         IN  DATE,        --based on mode, this will be start/completion date
			     p_new_job	            IN  NUMBER DEFAULT NULL,
			     p_insert_wip	    IN  NUMBER DEFAULT NULL,
                             p_phantom_exists       IN  NUMBER DEFAULT NULL,
			     p_charges_exist	    IN  NUMBER DEFAULT NULL
                            );

PROCEDURE Create_RepJobCopies (x_err_buf              OUT NOCOPY VARCHAR2,
                               x_err_code             OUT NOCOPY NUMBER,
                               p_rep_wip_entity_id    IN  NUMBER,
                               p_new_wip_entity_id    IN  NUMBER,
                               p_last_update_date     IN  DATE,
                               p_last_updated_by      IN  NUMBER,
                               p_last_update_login    IN  NUMBER,
                               p_creation_date        IN  DATE,
                               p_created_by           IN  NUMBER,
                               p_request_id           IN  NUMBER,
                               p_program_app_id       IN  NUMBER,
                               p_program_id           IN  NUMBER,
                               p_program_update_date  IN  DATE,
                               p_inf_sch_flag         IN  VARCHAR2,--Y/N
                               p_inf_sch_mode         IN  NUMBER,  --NULL/MIDPOINT_FORWARDS/CURRENT_OP
                               p_inf_sch_date         IN  DATE     --based on mode, this will be start/completion date
                              );

PROCEDURE Upgrade_JobCopies (x_err_buf              OUT NOCOPY VARCHAR2,
                             x_err_code             OUT NOCOPY NUMBER
                            );
PROCEDURE process_wip_info(    p_wip_entity_id        IN  NUMBER,
                               p_org_id               IN  NUMBER,
			       p_last_update_date     IN  DATE,
			       p_last_updated_by      IN  NUMBER,
			       p_last_update_login    IN  NUMBER,
			       p_creation_date        IN  DATE,
			       p_created_by           IN  NUMBER,
			       p_request_id           IN  NUMBER,
			       p_program_app_id       IN  NUMBER,
			       p_program_id           IN  NUMBER,
			       p_program_update_date  IN  DATE,
			       p_phantom_exists	      IN  NUMBER,
			       p_current_op_seq_num   IN  NUMBER,
			       x_err_buf              OUT NOCOPY VARCHAR2,
			       x_err_code             OUT NOCOPY NUMBER);

FUNCTION max_res_seq (p_op_seq_id  NUMBER) return NUMBER;

END WSM_JobCopies_PVT;

 

/
