--------------------------------------------------------
--  DDL for Package CSTPPWRO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSTPPWRO" AUTHID CURRENT_USER AS
/* $Header: CSTPWROS.pls 115.5 2002/11/11 22:32:25 awwang ship $*/

/*----------------------------------------------------------------------------*
 |   PUBLIC VARIABLES/TYPES	      					      |
 *----------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------*
|  PUBLIC PROCEDURE                                                          |
|       check_pacwip_bal_record                                              |
*----------------------------------------------------------------------------*/
PROCEDURE check_pacwip_bal_record (
                        p_pac_period_id         IN      NUMBER,
                        p_cost_group_id         IN      NUMBER,
                        p_cost_type_id          IN      NUMBER,
                        p_org_id                IN      NUMBER,
                        p_entity_id             IN      NUMBER,
			p_entity_type		IN	NUMBER,
                        p_line_id               IN      NUMBER DEFAULT NULL,
                        p_op_seq                IN      NUMBER,
                        p_user_id               IN      NUMBER,
                        p_request_id            IN      NUMBER,
                        p_prog_app_id           IN      NUMBER DEFAULT -1,
                        p_prog_id               IN      NUMBER DEFAULT -1,
                        p_login_id              IN      NUMBER DEFAULT -1,
                        x_err_num               OUT NOCOPY     NUMBER,
                        x_err_code              OUT NOCOPY     VARCHAR2,
                        x_err_msg               OUT NOCOPY     VARCHAR2
                                );


/*---------------------------------------------------------------------------*
|  PUBLIC PROCEDURE                                                          |
|       get_adj_operations                                                   |
*----------------------------------------------------------------------------*/

PROCEDURE get_adj_operations (
                                p_entity_id     IN      NUMBER,
                                p_line_id       IN      NUMBER DEFAULT NULL,
				p_rep_sched_id	IN	NUMBER DEFAULT NULL,
                                p_op_seq        IN      NUMBER,
                                x_prev_op       OUT NOCOPY     NUMBER,
                                x_next_op       OUT NOCOPY     NUMBER,
                                x_err_num       OUT NOCOPY     NUMBER,
                                x_err_code      OUT NOCOPY     VARCHAR2,
                                x_err_msg       OUT NOCOPY     VARCHAR2);

/*---------------------------------------------------------------------------*
|  PUBLIC PROCEDURE                                                          |
|       build_wip_operation_qty                                              |
*----------------------------------------------------------------------------*/

PROCEDURE build_wip_operation_qty(
        p_pac_period_id         IN      NUMBER,
        p_start_date            IN      DATE,
        p_end_date              IN      DATE,
        p_cost_group_id         IN      NUMBER,
        p_cost_type_id          IN      NUMBER,
        p_entity_id             IN      NUMBER,
	p_entity_type		IN	NUMBER,
        p_user_id               IN      NUMBER,
        p_login_id              IN      NUMBER,
        p_request_id            IN      NUMBER,
        p_prog_id               IN      NUMBER DEFAULT -1,
        p_prog_app_id           IN      NUMBER DEFAULT -1,
        x_err_num               OUT NOCOPY     NUMBER,
        x_err_code              OUT NOCOPY     VARCHAR2,
        x_err_msg               OUT NOCOPY     VARCHAR2);

/*---------------------------------------------------------------------------*
|  PUBLIC PROCEDURE                                                          |
|       process_wip_resovhd_txns                                             |
*----------------------------------------------------------------------------*/

PROCEDURE process_wip_resovhd_txns(
        p_pac_period_id         IN      NUMBER,
        p_start_date            IN      DATE,
        p_end_date              IN      DATE,
        p_cost_group_id         IN      NUMBER,
        p_cost_type_id          IN      NUMBER,
        p_item_id               IN      NUMBER DEFAULT NULL,
        p_pac_ct_id             IN      NUMBER,
        p_user_id               IN      NUMBER,
        p_login_id              IN      NUMBER,
        p_request_id            IN      NUMBER,
        p_prog_id               IN      NUMBER,
        p_prog_app_id           IN      NUMBER,
        x_err_num               OUT NOCOPY     NUMBER,
        x_err_code              OUT NOCOPY     VARCHAR2,
        x_err_msg               OUT NOCOPY     VARCHAR2);

END CSTPPWRO;

 

/
