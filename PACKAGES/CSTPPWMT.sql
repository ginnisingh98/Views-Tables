--------------------------------------------------------
--  DDL for Package CSTPPWMT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSTPPWMT" AUTHID CURRENT_USER AS
/* $Header: CSTPWMTS.pls 120.3 2005/11/29 00:41:19 skayitha noship $*/

/*----------------------------------------------------------------------------*
 |   PUBLIC VARIABLES/TYPES                                                         |
 *----------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------*
|  PUBLIC PROCEDURE                                                          |
|       charge_wip_material                                                  |
*----------------------------------------------------------------------------*/

PROCEDURE charge_wip_material(
        p_pac_period_id              IN          NUMBER,
        p_cost_group_id              IN          NUMBER,
        p_txn_id                     IN          NUMBER,
        p_exp_item                   IN          NUMBER DEFAULT NULL,
        p_exp_flag                   IN          NUMBER DEFAULT NULL,
        p_legal_entity               IN          NUMBER,
        p_cost_type_id               IN          NUMBER,
        p_cost_method                IN          NUMBER,
        p_pac_rates_id               IN          NUMBER,
        p_master_org_id              IN          NUMBER,
        p_material_relief_algorithm  IN          NUMBER,
        p_uom_control                IN          NUMBER,
        p_user_id                    IN          NUMBER,
        p_login_id                   IN          NUMBER,
        p_request_id                 IN          NUMBER,
        p_prog_id                    IN          NUMBER,
        p_prog_app_id                IN          NUMBER,
        p_txn_category               IN          NUMBER,
        x_cost_method_hook           OUT NOCOPY  NUMBER,
        x_err_num                    OUT NOCOPY  NUMBER,
        x_err_code                   OUT NOCOPY  VARCHAR2,
        x_err_msg                    OUT NOCOPY  VARCHAR2);

/*---------------------------------------------------------------------------*
|  PUBLIC PROCEDURE                                                          |
|       charge_wip_pwac_cost                                                 |
*----------------------------------------------------------------------------*/
PROCEDURE charge_wip_pwac_cost(
        p_pac_period_id              IN          NUMBER,
        p_cost_group_id              IN          NUMBER,
        p_pri_qty                    IN          NUMBER,
        p_item_id                    IN          NUMBER,
        p_entity_id                  IN          NUMBER,
        p_line_id                    IN          NUMBER,
        p_op_seq                     IN          NUMBER,
        p_material_relief_algorithm  IN          NUMBER,
        p_user_id                    IN          NUMBER,
        p_login_id                   IN          NUMBER,
        p_request_id                 IN          NUMBER,
        p_prog_id                    IN          NUMBER,
        p_prog_app_id                IN          NUMBER,
        x_err_num                    OUT NOCOPY  NUMBER,
        x_err_code                   OUT NOCOPY  VARCHAR2,
        x_err_msg                    OUT NOCOPY  VARCHAR2,
        p_zero_cost_flag             IN          NUMBER := 0); -- Variable added for eAM support in PAC


END CSTPPWMT;

 

/
