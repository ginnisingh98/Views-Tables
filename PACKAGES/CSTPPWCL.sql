--------------------------------------------------------
--  DDL for Package CSTPPWCL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSTPPWCL" AUTHID CURRENT_USER AS
/* $Header: CSTPWCLS.pls 115.4 2002/11/11 22:25:45 awwang ship $*/

/*----------------------------------------------------------------------------*
 |   PUBLIC VARIABLES/TYPES	      					      |
 *----------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------*
|  PUBLIC PROCEDURE                                                          |
|       process_wip_close_txns                                               |
*----------------------------------------------------------------------------*/

PROCEDURE process_wip_close_txns(
        p_pac_period_id         IN      NUMBER,
        p_start_date            IN      DATE,
        p_end_date              IN      DATE,
        p_cost_group_id         IN      NUMBER,
        p_cost_type_id          IN      NUMBER,
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
|       flush_wip_costs                                                      |
*----------------------------------------------------------------------------*/

PROCEDURE flush_wip_costs(
        p_pac_period_id         IN      NUMBER,
        p_cost_group_id         IN      NUMBER,
        p_entity_id             IN      NUMBER,
        p_user_id               IN      NUMBER,
        p_login_id              IN      NUMBER,
        p_request_id            IN      NUMBER,
        p_prog_id               IN      NUMBER DEFAULT -1,
        p_prog_app_id           IN      NUMBER DEFAULT -1,
        x_err_num               OUT NOCOPY     NUMBER,
        x_err_code              OUT NOCOPY     VARCHAR2,
        x_err_msg               OUT NOCOPY     VARCHAR2);


END CSTPPWCL;

 

/
