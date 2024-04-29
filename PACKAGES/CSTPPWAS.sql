--------------------------------------------------------
--  DDL for Package CSTPPWAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSTPPWAS" AUTHID CURRENT_USER AS
/* $Header: CSTPWASS.pls 120.3 2005/11/29 00:39:21 skayitha noship $*/

/*----------------------------------------------------------------------------*
 |   PUBLIC VARIABLES/TYPES                                                   |
 *----------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------*
|  PUBLIC PROCEDURE                                                          |
|       process_nonreworkassembly_txns                                       |
*----------------------------------------------------------------------------*/

PROCEDURE process_nonreworkassembly_txns(
       p_pac_period_id               IN           NUMBER,
       p_start_date                  IN           DATE,
       p_end_date                    IN           DATE,
       p_prior_period_id             IN           NUMBER,
       p_item_id                     IN           NUMBER,
       p_cost_group_id               IN           NUMBER,
       p_cost_type_id                IN           NUMBER,
       p_legal_entity                IN           NUMBER,
       p_cost_method                 IN           NUMBER,
       p_pac_rates_id                IN           NUMBER,
       p_master_org_id               IN           NUMBER,
       p_material_relief_algorithm   IN           NUMBER,
       p_uom_control                 IN           NUMBER,
       p_low_level_code              IN           NUMBER,
       p_user_id                     IN           NUMBER,
       p_login_id                    IN           NUMBER,
       p_request_id                  IN           NUMBER,
       p_prog_id                     IN           NUMBER DEFAULT -1,
       p_prog_app_id                 IN           NUMBER DEFAULT -1,
       x_err_num                     OUT NOCOPY   NUMBER,
       x_err_code                    OUT NOCOPY   VARCHAR2,
       x_err_msg                     OUT NOCOPY   VARCHAR2);

/*---------------------------------------------------------------------------*
|  PUBLIC PROCEDURE                                                          |
|       process_reworkassembly_txns                                          |
*----------------------------------------------------------------------------*/

PROCEDURE process_reworkassembly_txns(
       p_pac_period_id                IN            NUMBER,
       p_start_date                   IN            DATE,
       p_end_date                     IN            DATE,
       p_prior_period_id              IN            NUMBER,
       p_item_id                      IN            NUMBER,
       p_cost_group_id                IN            NUMBER,
       p_cost_type_id                 IN            NUMBER,
       p_legal_entity                 IN            NUMBER,
       p_cost_method                  IN            NUMBER,
       p_pac_rates_id                 IN            NUMBER,
       p_master_org_id                IN            NUMBER,
       p_material_relief_algorithm    IN            NUMBER,
       p_uom_control                  IN            NUMBER,
       p_low_level_code               IN            NUMBER,
       p_user_id                      IN            NUMBER,
       p_login_id                     IN            NUMBER,
       p_request_id                   IN            NUMBER,
       p_prog_id                      IN            NUMBER DEFAULT -1,
       p_prog_app_id                  IN            NUMBER DEFAULT -1,
       x_err_num                      OUT NOCOPY    NUMBER,
       x_err_code                     OUT NOCOPY    VARCHAR2,
       x_err_msg                      OUT NOCOPY    VARCHAR2);

/*---------------------------------------------------------------------------*
|  PUBLIC PROCEDURE                                                          |
|       check_expense_flags                                                  |
|   utility procedure to return item and expense flags                       |
|                                                                            |
*----------------------------------------------------------------------------*/

PROCEDURE check_expense_flags(
        p_item_id               IN             NUMBER,
        p_subinv                IN             VARCHAR2,
        p_org_id                IN             NUMBER,
        x_exp_item              OUT NOCOPY     NUMBER,
        x_exp_flag              OUT NOCOPY     NUMBER,
        x_err_num               OUT NOCOPY     NUMBER,
        x_err_code              OUT NOCOPY     VARCHAR2,
        x_err_msg               OUT NOCOPY     VARCHAR2);

END CSTPPWAS;


 

/
