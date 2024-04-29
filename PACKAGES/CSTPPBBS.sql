--------------------------------------------------------
--  DDL for Package CSTPPBBS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSTPPBBS" AUTHID CURRENT_USER AS
/* $Header: CSTPBBSS.pls 115.4 99/07/16 05:31:08 porting sh $*/

/*----------------------------------------------------------------------------*
 |   PUBLIC VARIABLES/TYPES	      					      |
 *----------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------*
|  PUBLIC PROCEDURE                                                          |
|       copy_prior_info                                                  |
*----------------------------------------------------------------------------*/
PROCEDURE copy_prior_info(
        i_pac_period_id         IN      NUMBER,
        i_prior_pac_period_id   IN      NUMBER,
        i_legal_entity          IN      NUMBER,
        i_cost_type_id		IN	NUMBER,
        i_cost_group_id         IN      NUMBER,
        i_cost_method           IN      NUMBER,
        i_user_id               IN      NUMBER,
        i_login_id              IN      NUMBER,
        i_request_id            IN      NUMBER,
        i_prog_id               IN      NUMBER DEFAULT -1,
        i_prog_app_id           IN      NUMBER DEFAULT -1,
        o_err_num               OUT     NUMBER,
        o_err_code              OUT     VARCHAR2,
        o_err_msg               OUT     VARCHAR2);

/*---------------------------------------------------------------------------*
 |  PRIVATE PROCEDURE                                                        |
 |     copy_prior_info_PWAC						     |
 |  Copy prior period data for Periodic Weighted Actual Costing              |
 *---------------------------------------------------------------------------*/
PROCEDURE copy_prior_info_PWAC(
        i_pac_period_id         IN      NUMBER,
        i_prior_pac_period_id   IN      NUMBER,
        i_legal_entity          IN      NUMBER,
        i_cost_type_id		IN	NUMBER,
        i_cost_group_id         IN      NUMBER,
        i_user_id               IN      NUMBER,
        i_login_id              IN      NUMBER,
        i_request_id            IN      NUMBER,
        i_prog_id               IN      NUMBER DEFAULT -1,
        i_prog_app_id           IN      NUMBER DEFAULT -1,
        o_err_num               OUT     NUMBER,
        o_err_code              OUT     VARCHAR2,
        o_err_msg               OUT     VARCHAR2);

END CSTPPBBS;

 

/
